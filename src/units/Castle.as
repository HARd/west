package units 
{
	import com.greensock.TweenLite;
	import core.Numbers;
	import core.Post;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.geom.Point;
	import wins.CastleGuestWindow;
	import wins.CastleWindow;
	import wins.ConstructWindow;
	import wins.SimpleWindow;
	
	public class Castle extends Building 
	{
		
		private var _tribute:Object = {};
		public var friends:Object;
		public var view:int;
		public var views:Array = [];
		
		public function Castle(object:Object) 
		{
			_tribute = object.tribute || {};
			friends = object.friends || {};
			view = object.view || 1;
			
			addViews(object.views);
			
			if (views.indexOf(1) == -1) views.push(1);
			
			super(object);
			
			if (formed) {
				touchableInGuest = true;
				clickable = true;
				stockable = false;
				rotateable = false;
				moveable = false;
				removable = false;
			}
			
			craftLevels = 1;
			
			if (object['buy'] == true) hasUpgraded = true;
			if (object['fromStock'] == true) hasUpgraded = true;
		}
		
		override public function load():void {
			//drawPreview();
			super.load();
		}
		
		override public function onLoad(data:*):void {
			//clearPreview();
			super.onLoad(data);
		}
		
		override public function click():Boolean {
			if (App.user.mode == User.GUEST) {
				
				if (level < totalLevels) {
					new SimpleWindow( {
						hasTitle:false,
						text:Locale.__e('flash:1417093589664')
					}).show();
					return true;
				}
				
				if (tribute >= limit) {
					new SimpleWindow( {
						title:		info.title,
						text:		Locale.__e('flash:1416840472190'),
						label:		SimpleWindow.MATERIAL,
						sID:		sid
					}).show();
				}else if (alwaysGive(App.user.id)) {
					new SimpleWindow( {
						title:		info.title,
						text:		Locale.__e('flash:1416840433180'),
						label:		SimpleWindow.MATERIAL,
						sID:		sid
					}).show();
					
				}else{
					new CastleGuestWindow( {
						target:		this
					}).show();
				}
				
				return true;
			}
			
			return super.click();
		}
		
		override public function openProductionWindow():void {
			new CastleWindow( {
				target:				this,
				storageAction:		storageAction
			}).show();
		}
		
		override public function updateLevel(checkRotate:Boolean = false):void 
		{
			if (textures == null) return;
			
			var levelData:Object;
			if (this.level && info.devel && info.devel.req.hasOwnProperty(this.level + view - 1) && info.devel.req[this.level].hasOwnProperty("s")) {
				levelData = textures.sprites[info.devel.req[this.level].s];
			}else{
				levelData = textures.sprites[this.level + view - 2];
			}
			
			if (levelData == null)
				levelData = textures.sprites[0];
			
			if (checkRotate && rotate == true) {
				flip();
			}
			
			if (this.level != 0 && gloweble)
			{
				var backBitmap:Bitmap = new Bitmap(bitmap.bitmapData);
				backBitmap.x = bitmap.x;
				backBitmap.y = bitmap.y;
				addChildAt(backBitmap, 0);
				
				bitmap.alpha = 0;
				
				//App.ui.flashGlowing(this, 0xFFF000)//0x6fefff);
				
				TweenLite.to(bitmap, 0.4, { alpha:1, onComplete:function():void {
					removeChild(backBitmap);
					backBitmap = null;
				}});
				
				gloweble = false;
			}
			
			draw(levelData.bmp, levelData.dx, levelData.dy);
			
			checkOnAnimationInit();
			
		}
		
		override public function checkOnAnimationInit():void {
			if (level >= totalLevels) {
				initAnimation();
				startAnimation();
			}
		}
		
		private var storageCallback:Function = null;
		public function storageAction(callback:Function = null):void {
			storageCallback = callback;
			
			if (Numbers.countProps(_tribute) > 0) {
				Post.send( {
					ctr:this.type,
					act:'storage',
					uID:App.user.id,
					id:this.id,
					wID:App.user.worldID,
					sID:this.sid
				}, onStorageAction);
			}
		}
		private function onStorageAction(error:int, data:Object, params:Object):void {
			if (error) return;
			
			App.user.stock.addAll(_tribute);
			_tribute = { };
			
			if (storageCallback != null) storageCallback();
			storageCallback = null;
			
		}
		
		// Отправить подарок
		private var tributeCallback:Function = null;
		public function tributeAction(callback:Function, nodeID:*):void {
			tributeCallback = callback;
			
			Post.send( {
				ctr:this.type,
				act:'tribute',
				uID:App.owner.id,
				id:this.id,
				wID:App.map.id,
				sID:this.sid,
				guest:App.user.id,
				idx:String(nodeID)
			}, onTributeAction);
		}
		private function onTributeAction(error:int, data:Object, params:Object):void {
			if (error) return;
			
			if (tributeCallback != null) tributeCallback();
			tributeCallback = null;
			
			//App.user.stock.take(sID, count);
			friends[App.user.id] = App.time;
			
			if (data.hasOwnProperty('bonus'))
				Treasures.bonus(data.bonus, new Point(this.x, this.y));
		}
		
		// Открыть вид
		private var openCallback:Function = null;
		private var viewForOpen:*;
		public function openAction(callback:Function, view:*):void {
			openCallback = callback;
			viewForOpen = view;
			
			if (!info.form.view.hasOwnProperty(view)) {
				trace('НЕИЗВЕСТНЫЙ VIEW !!');
				return;
			}
			
			Post.send( {
				ctr:this.type,
				act:'open',
				uID:App.user.id,
				id:this.id,
				wID:App.user.worldID,
				sID:this.sid,
				view:view
			}, onOpenAction);
		}
		private function onOpenAction(error:int, data:Object, params:Object):void {
			if (error) return;
			
			if (views.indexOf(int(viewForOpen)) == -1)
				views.push(int(viewForOpen));
			
			if (openCallback != null) openCallback();
			openCallback = null;
		}
		
		// Cvtybnm dbl
		private var viewCallback:Function = null;
		public function viewAction(callback:Function, nodeID:*):void {
			viewCallback = callback;
			
			Post.send( {
				ctr:this.type,
				act:'view',
				uID:App.user.id,
				id:this.id,
				wID:App.user.worldID,
				sID:this.sid,
				guest:App.owner.id,
				idx:String(nodeID)
			}, onOpenAction);
		}
		private function onViewAction(error:int, data:Object, params:Object):void {
			if (error) return;
			
			if (viewCallback != null) viewCallback();
			viewCallback = null;
			
			if (data.hasOwnProperty('bonus'))
				Treasures.bonus(data.bonus, new Point(this.x, this.y));
		}
		
		
		
		public function addViews(object:* = null):void {
			if (object == null) return;
			
			for (var s:* in object) {
				if (views.indexOf(int(s)) == -1)
					views.push(int(s));
			}
		}
		private var setViewCallback:Function;
		public function setView(id:*, callback:Function = null):void {
			setViewCallback = callback;
			
			if (views.indexOf(int(id)) == -1) {
				openView(id);
				return;
			}
			
			if (view == int(id)) return;
			view = int(id);
			updateLevel();
			setViewCallback();
		}
		
		private function openView(id:*):void {
			var target:Object = { sid:sid, level:level, viewID:id, totalLevels:totalLevels, type:type, views:views, info: { devel: { obj:info.form.obj, req: { 6: { t:0, l:0 }}, skip: { 6:0 }}, form: info.form }};
			
			new ConstructWindow( {
				title:			info.title,
				upgTime:		0,
				request:		info.form.obj[id],
				target:			target,
				win:			null,
				onUpgrade:		function():void {
					openAction(setViewCallback, id);
				},
				hasDescription:	true,
				bttnTxt:		'flash:1382952379890',
				noSkip:			true
			}).show();
		}
		
		public function alwaysGive(id:*):Boolean {
			for (var _id:* in friends) {
				if (String(_id) == String(id) && friends[_id] > App.midnight)
					return true;
			}
			
			return false;
		}
		
		public function get limit():int {
			return info.form.req[view]['l'];
		}
		
		public function get tribute():int {
			for (var s:* in _tribute) return _tribute[s];
			return 0;
		}
		
		/*public function drawPreview():void {
			var shape:Shape = new Shape();
			shape.name = 'preview';
			shape.graphics.beginFill(0x00FF00, 0.3);
			shape.graphics.lineStyle(1, 0x00FF00, 0.6);
			shape.graphics.moveTo(0, 0);
			shape.graphics.lineTo( -20 * cells, 10 * rows);
			shape.graphics.lineTo( -20 * cells + 20 * rows, 10 * rows + 10 * cells);
			shape.graphics.lineTo( 20 * rows, 10 * cells);
			shape.graphics.lineTo(0, 0);
			shape.graphics.endFill();
			addChild(shape);
		}
		public function clearPreview():void {
			var shape:Shape = getChildByName('preview') as Shape;
			removeChild(shape);
		}*/
	}

}