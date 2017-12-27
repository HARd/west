package units
{
	import api.ExternalApi;
	import astar.AStarNodeVO;
	import core.Load;
	import core.Post;
	import flash.events.Event;
	import flash.geom.Point;
	import ui.Cursor;
	import ui.Hints;
	import wins.ChooseDecorWindow;
	
	public class Decor extends AUnit{
		
		public var callback:Function = null;
		
		public function Decor(object:Object)
		{
			layer = Map.LAYER_SORT;
			if (App.data.storage[object.sid].dtype == 1 /*|| App.data.storage[object.sid].dtype == 2*/)
				layer = Map.LAYER_LAND;
			
			object['hasLoader'] = false;
			super(object);
			
			touchableInGuest = false;
			multiple = true;
			stockable = true;
			//touchable = false;
			
			if ([579, 580, 581, 582, 583, 584,782].indexOf(sid) != -1) {
				removable = false;
				stockable = false;
			}
			
			if (sid == 782) {
				rotateable = false;
				moveable = false;
			}
			
			/*if (info.dtype == 2) {
				touchable = true;
			}*/
			
			//transable = false;
			//if (info.view == 'cloudlet')
				
			
			Load.loading(Config.getSwf(type, info.view), onLoad);
			
			if(!formed) addEventListener(AppEvent.AFTER_BUY, onAfterBuy);
			tip = function():Object {
				return {
					title:info.title,
					text:info.description
				};
			};
			addEventListener(Event.REMOVED_FROM_STAGE, onRemoveFromStage);
		}
		
		override public function initAnimation():void {
			framesTypes = [];
			if (textures && textures.hasOwnProperty('animation')) {
				for (var frameType:String in textures.animation.animations) {
					framesTypes.push(frameType);
				}
				addAnimation();
				startAnimation(true);
			}
		}
		
		override public function take():void {
			if (info.dtype == 0 || info.dtype == 2) super.take();
		}
		override public function free():void {
			if (info.dtype == 0 || info.dtype == 2) super.free();
		}
		
		public function onAfterBuy(e:AppEvent):void
		{
			removeEventListener(AppEvent.AFTER_BUY, onAfterBuy);
			App.user.stock.add(Stock.EXP, info.experience);
			if(App.data.storage[sid].experience > 0)Hints.plus(Stock.EXP, App.data.storage[sid].experience, new Point(this.x * App.map.scaleX + App.map.x, this.y * App.map.scaleY + App.map.y), true);
			
			if (App.social == 'FB') {
				ExternalApi.og('buy','decoration');
			}
		}
		
		override public function onLoad(data:*):void {
			textures = data;
			var levelData:Object = textures.sprites[0];
			draw(levelData.bmp, levelData.dx, levelData.dy);
			
			framesType = info.view;
			if (textures && textures.hasOwnProperty('animation')) 
				initAnimation();
			if (User.inExpedition && !open && formed)
				visible = false;
			if (App.self.constructMode) visible = true;
		}
		
		override public function set touch(touch:Boolean):void {
			switch(Cursor.type) {
				case 'stock':
				case 'remove':
				case 'move':
				case 'rotate':
					super.touch = touch;
					break;
			}
			if (info.dtype == 2 || sid == 784)
				super.touch = touch;
		}
		
		override public function click():Boolean {
			if (info.dtype == 2) {
				new ChooseDecorWindow( {
					parentDecor: this,
					parentSID: this.sid,
					title: Locale.__e('flash:1435054686292')
				}).show();
				return true;
			}
			if (!super.click()) return false;
			
			return true;
		}
		
		private function onContextClick():void
		{
			trace("onContextClick");
		}
		
		override public function buyAction():void {
			//Hints.plus(Stock.EXP, info.experience, new Point(this.x*App.map.scaleX + App.map.x, this.y*App.map.scaleY + App.map.y),true);
			//App.user.stock.add(Stock.EXP, info.experience);
			super.buyAction();
		}
		
		override public function stockAction(params:Object = null):void {
			
			if (!App.user.stock.check(sid)) {
				//TODO показываем окно с ообщением, что на складе уже нет ничего
				return;
			}else if (!World.canBuilding(sid)) {
				uninstall();
				return;
			}
			
			if (params && params.coords) {
				coords.x = params.coords.x;
				coords.z = params.coords.z;
			}
			
			App.user.stock.take(sid, 1);
			
			Post.send( {
				ctr:this.type,
				act:'stock',
				uID:App.user.id,
				wID:App.user.worldID,
				sID:this.sid,
				x:coords.x,
				z:coords.z
			}, onStockAction);
		}
		
		override protected function onStockAction(error:int, data:Object, params:Object):void {
			if (error) {
				Errors.show(error, data);
				return;
			}
			
			this.id = data.id;
			if(!(multiple && App.user.stock.check(sid))){
				App.map.moved = null;
			}
			
			App.ui.glowing(this);
			World.addBuilding(this.sid);
			onAfterStock();
			
			if (callback != null) {
				callback();
				callback = null;
			}
		}
		
		override public function calcState(node:AStarNodeVO):int
		{
			if (App.self.constructMode) return EMPTY;
			if (info.dtype == 1/* || info.dtype == 2*/)
			{
				for (var i:uint = 0; i < cells; i++) {
					for (var j:uint = 0; j < rows; j++) {
						node = App.map._aStarNodes[coords.x + i][coords.z + j];
						if (node.b != 0 || node.open == false)
						{
							if (node.object && !(node.object is Resource))
									return EMPTY;
							
							return OCCUPIED;
						}
					}
				}
				
				return EMPTY;
			}
			else
			{
				return super.calcState(node);
			}
		}
	}
}