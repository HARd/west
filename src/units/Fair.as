package units 
{
	import core.Load;
	import core.Post;
	import flash.display.Bitmap;
	import flash.geom.Point;
	import wins.FairChangeWindow;
	import wins.FairFriendsWindow;
	import wins.FairGuestWindow;
	import wins.SimpleWindow;
	
	public class Fair extends Building
	{
		public var view:int = 0;
		public var friends:Object;
		public var kicks:int = 0;
		
		public function Fair(object:Object)
		{
			view = object.view || 0;
			friends = object.guests || { };
			kicks = object.kicks || 0;
			
			super(object);
			craftLevels = 1;
			
			touchableInGuest = true;
			clickable = true;

			addView();
			if (formed) {
				moveable = false;
				stockable = false;
				removable = false;
			}
		}
		
		
		
		override public function setCraftLevels():void{
			craftLevels = 1;
		}
			
		override public function click():Boolean
		{
			if (App.user.mode == User.GUEST) {
				
				if (view == 0) {
					new SimpleWindow( {
						hasTitle:false,
						text:Locale.__e('flash:1417087399779')
					}).show();
					return true;
				}
				
				new FairGuestWindow( {
					width:			625,
					height:			330,
					title:			info.title,
					target:			this,
					hasPaginator:	false,
					hasButtons:		false
				}).show();
				
				return true;
			}
			
			return super.click();
		}

		public function addView():void 
		{
			if (view == 0) {
				if (viewBitmap != null){
					removeChild(viewBitmap);
					viewBitmap = null;
				}	
				return;
			}
			var swfView:String = info.form.req[view].v;
			Load.loading(Config.getSwf('Fair', swfView), onViewLoad);
		}
		
		private var viewTexture:*;
		private var viewBitmap:Bitmap;
		private function onViewLoad(data:*):void 
		{
			viewTexture = data;
			var viewData:Object = viewTexture.sprites[0];	
			
			viewBitmap = new Bitmap();	
			viewBitmap.bitmapData = viewData.bmp;
			viewBitmap.smoothing = true;
			
			addChild(viewBitmap);
			
			viewBitmap.x = viewData.dx;
			viewBitmap.y = viewData.dy;
		}
		
		override public function openProductionWindow():void 
		{
			if (view > 0) {
				new FairFriendsWindow( {
					width:			600,
					height:			490,
					title:			Locale.__e('flash:1417008887851'),//info.title,
					target:			this,
					hasPaginator:	true,
					hasButtons:		false
				}).show();
			}else{
				new FairChangeWindow({
					forms:			info.form,
					target:			this,
					openAction:		openAction,
					hasPaginator:	true,
					hasButtons:		true,
					find:			helpTarget
				}).show();
			}
		}
		
		public function openAction(id:int):void 
		{
			if (!App.user.stock.takeAll(info.form.obj[id]))
				return;
			
			Post.send({
				ctr:this.type,
				act:'open',
				uID:App.user.id,
				id:this.id,
				wID:App.user.worldID,
				sID:this.sid,
				view:id
			}, function(error:int, data:Object, params:Object):void 
			{
				if (error) {
					Errors.show(error, data);
					return;
				}
				
				view = id;
				addView();
			});
		}
		
		public function alwaysGive(id:*):Boolean {
			for (var _id:* in friends) {
				if (String(_id) == String(id) && friends[_id] > App.midnight)
					return true;
			}
			
			return false;
		}
		
		public function kickEvent(callback:Function, kID:*):void {
			
			var self:* = this;
			var sendObject:Object = {
				ctr:info.type,
				act:'kick',
				uID:App.owner.id,
				wID:App.owner.worldID,
				sID:this.sid,
				id:this.id,
				guest:App.user.id,
				mID:kID
			}
			
			Post.send(sendObject, function(error:int, data:Object, params:Object):void {
				if (error) {
					Errors.show(error, data);
					return;
				}
				
				if (callback != null) callback();
				
				if (data.hasOwnProperty("energy") && data.energy > 0)
					App.user.friends.updateOne(App.owner.id, "energy", data.energy);
					
				if (data.hasOwnProperty('bonus'))
					Treasures.bonus(data.bonus, new Point(self.x, self.y));
			});
		}
		
		public function boostEvent(callback:Function):void {
			
			var self:* = this;
			
			Post.send( {
				ctr:this.type,
				act:'boost',
				uID:App.user.id,
				id:this.id,
				wID:App.user.worldID,
				sID:this.sid
			}, function(error:int, data:Object, params:Object):void {
				if (error) return;
				
				kicks = data.kicks;
				callback();
			});
		}
		
		override public function storageEvent(value:int = 0):void {
			
			var self:* = this;
			var sendObject:Object = {
				ctr:this.type,
				act:'storage',
				uID:App.user.id,
				wID:App.user.worldID,
				sID:this.sid,
				id:this.id
			}
				
			Post.send(sendObject,
			function(error:int, data:Object, params:Object):void {
				
				if (error) {
					Errors.show(error, data);
					return;
				}
				
				if (data.hasOwnProperty('bonus'))
					Treasures.packageBonus(data.bonus, new Point(self.x, self.y));
				
				view = 0;
				self = null;
				friends = { };
				kicks = 0;
				addView();
			});
		}
	}	
}