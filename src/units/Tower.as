package units
{
	import core.Post;
	import flash.geom.Point;
	import wins.ShareGuestWindow;
	import wins.SimpleWindow;
	import wins.TowerWindow;
	/**
	 * ...
	 * @author 
	 */
	public class Tower extends Share
	{
		public var kicksLimit:int = 0;
		
		public function Tower(settings:Object) 
		{
			
			super(settings);
			
			for each(var lvl:String in info.tower){
				totalLevels++;
			}	
			
			//totalLevels--;
			
			kicksLimit = info.tower[totalLevels].c;
		}
		
		//floor
		
		override public function click():Boolean 
		{
			if (!clickable || id == 0) return false;
				
			if (App.user.mode == User.OWNER)
			{
				new TowerWindow( {
					target:this,
					storageEvent:storageAction,
					upgradeEvent:upgradeEvent,
					buyKicks:buyKicks
				} ).show();
			}
			else
			{	
				if (info.tower[level + 1] == undefined) {
					// Больше стучать нельзя
					new SimpleWindow( {
						label:SimpleWindow.ATTENTION,
						text:Locale.__e('flash:1382952379909',[info.title])
					}).show();
					return true;
				}
				
				if (kicks >= info.tower[level+1].c)
				{
					// Больше стучать нельзя
					new SimpleWindow( {
						label:SimpleWindow.ATTENTION,
						title:Locale.__e('flash:1382952379908'),
						text:Locale.__e('flash:1382952379910',[info.title])
					}).show();
				}
				else
				{
					new ShareGuestWindow({
						target:this,
						kickEvent:kickEvent
					}).show();
				}
			}
			return true;
		}
		
		override public function upgradeEvent(params:Object, $fast:int = 0):void {
			
			gloweble = true;
			var self:Tower = this;
			//flag = false;
			
			Post.send( {
				ctr:this.type,
				act:'upgrade',
				uID:App.user.id,
				id:this.id,
				wID:App.user.worldID,
				sID:this.sid
			},function(error:int, data:Object, params:Object):void {
				if (error) {
					Errors.show(error, data);
					return;
				}
				guests = { };
				level = data.level;
				updateLevel(true);
				
				if(data.hasOwnProperty('bonus'))
					Treasures.bonus(data.bonus, new Point(self.x, self.y));
			});
		}
		
		public function buyKicks(params:Object):void {
			
			var callback:Function = params.callback;
			
			Post.send( {
				ctr:this.type,
				act:'boost',
				uID:App.user.id,
				id:this.id,
				wID:App.user.worldID,
				sID:this.sid
			},function(error:int, data:Object, params:Object):void {
				if (error) {
					Errors.show(error, data);
					return;
				}
				
				if (data.hasOwnProperty(Stock.FANT))
					App.user.stock.put(Stock.FANT, data[Stock.FANT]);
				
				kicks = data.kicks;
				//flag = Cloud.TRIBUTE;
				callback();
			});
		}
		
		override public function onLoad(data:*):void
		{
			super.onLoad(data);
			touchableInGuest = true;
			//flag = false;
			
			/*if (App.user.mode == User.GUEST) {
				touchableInGuest = true;
				flag = false;
				if (info.tower[level + 1] != undefined) {
					if (kicks < info.tower[level + 1].c){
						flag = Cloud.HAND;
					}
				}	
			}
			else
			{
				flag = Cloud.TRIBUTE;
				if (info.tower[level + 1] != undefined)
					if (kicks < info.tower[level + 1].c)
						flag = false;
			}*/
		}
		
		override public function storageAction(boost:uint, callback:Function):void {
			
			var self:Share = this;
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
				
				callback(Stock.FANT, boost);
				
				if (data.hasOwnProperty(Stock.FANT))
					App.user.stock.data[Stock.FANT] = data[Stock.FANT];
				
				if (data.hasOwnProperty('bonus'))
					Treasures.packageBonus(data.bonus, new Point(self.x, self.y));
				
				uninstall();
				self = null;
			});
		}
		
		override public function refresh():void {
			//touchableInGuest = false;
		}
	}
}