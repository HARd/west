package units 
{
	import com.greensock.TweenMax;
	import core.Load;
	import flash.display.Bitmap;
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	
	public class Plant extends Bitmap{
		
		public var field:Field;
		private var _level:int = 0;
		public var info:Object;
		public var sid:uint = 0;
		public var planted:int = 0;
		public var type:String = "Plant";
		public var textures:Object;
		
		public var levelData:Object;
		public var glowed:Boolean = false;
		
		public var layer:String = Map.LAYER_SORT;
		
		/*override public function get parent():DisplayObjectContainer
		{
			return field;
		}*/
		
		public function get coords():Object {
			return field.coords;
		}
		
		public function Plant(object:Object)
		{
			sid = object.sid;
			planted = object.planted;
			
			info = App.data.storage[this.sid];
			if (!info['levels']) info['levels'] = 2;
			
			field = object.field;
			name = 'plant';
			this.x = field.x;
			this.y = field.y;
			
			Load.loading(Config.getSwf(type, info.view), onLoad);
			addEventListener(Event.REMOVED_FROM_STAGE, onRemoveFromStage);
		}
		
		public function onRemoveFromStage(e:Event):void {
			App.self.setOffTimer(growth);
			removeEventListener(Event.REMOVED_FROM_STAGE, onRemoveFromStage);
		}
		
		public function get index():int {
			return field.index;
		}
		
		public function set index(index:int):void {
			field.index = index;
		}
		
		public function get depth():int {
			return field.depth;
		}
		
		public function get open():Boolean {
			return field.open;
		}
		
		public function glowing():void {
			glowed = true; 
			var that:Plant = this;
			TweenMax.to(this, 0.8, { glowFilter: { color:0xFFFF00, alpha:1, strength: 6, blurX:15, blurY:15 }, onComplete:function():void {
				TweenMax.to(that, 0.8, { glowFilter: { color:0xFFFF00, alpha:0, strength: 4, blurX:6, blurY:6 }, onComplete:function():void {
					that.filters = [];
					glowed = false;
				}});	
			}});
		}
		
		
		public function growth():void {
			if (level >= info.levels) {
				App.self.setOffTimer(growth);
			}
		}
		
		public function get level():uint {
			var currentLevel:int = int((App.time - planted) / info.levelTime);
			
			if (planted == 0 || currentLevel < 0) currentLevel = 0;
			if (currentLevel >= info.levels) currentLevel = info.levels;
			if (_level != currentLevel) {
				_level = currentLevel;
				updateLevel();
			}
			
			return currentLevel;
		}
		
		public function set level(level:uint):void {
			//
		}
		
		public function get ready():Boolean {
			return level >= info.levels;
		}
		
		private function onLoad(data:*):void {
			textures = data;
			if(level < info.levels){
				App.self.setOnTimer(growth);
			}
			updateLevel();
		}
		
		private function updateLevel():void {
			if (!textures || !textures.sprites) return;
			levelData = textures.sprites[_level];
			bitmapData = levelData.bmp;
			x = levelData.dx + field.x + 2;
			y = levelData.dy + field.y - 6;
			//App.map.allSorting();
		}
		
		public static function materialObject(plantID:*):Object {
			var object:Object;
			if (App.data.storage.hasOwnProperty(plantID)) {
				var info:Object = App.data.storage[plantID];
				
				if (info.hasOwnProperty('iouts')) {
					var min:int = 10;
					for (var s:* in info.iouts) {
						if (int(s) < min) min = int(s);
					}
					object = App.data.storage[info.iouts[min]];
				} else if (info.hasOwnProperty('out')) {
					if (info.out != '') {
						object = App.data.storage[info.out];
					} else if (info.hasOwnProperty('outs')) {
						var min1:int = 10;
						for (var s1:* in info.outs) {
							if (int(s1) < min1) 
								min1 = int(s1);
						}
						object = App.data.storage[info.outs[min1]];
					}
				} 
			}
			return object;
		}
	}
}