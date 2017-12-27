package units 
{
	import com.greensock.TweenMax;
	import core.Load;
	import flash.display.Bitmap;
	import flash.display.DisplayObjectContainer;
	
	public class FarmPlant extends Bitmap{
		
		private var _level:uint = 0;
		public var farm:Farm;
		public var info:Object;
		public var sid:uint = 0;
		public var planted:int = 0;
		public var type:String = "Plant";
		public var textures:Object;
		
		public var levelData:Object;
		public var glowed:Boolean = false;
		
		public var point:Object;
		
		override public function get parent():DisplayObjectContainer
		{
			return farm;
		}
		
		public function FarmPlant(object:Object)
		{
			sid = object.sid;
			planted = object.planted;
			point = object.point;
			
			info = App.data.storage[this.sid];
			farm = object.farm;
			name = 'plant';
			this.x = farm.dx;
			this.x = farm.dy;
			
			Load.loading(Config.getSwf(type, info.view), onLoad);
		}
		
		public function get index():int {
			return farm.index;
		}
		
		public function set index(index:int):void {
			farm.index = index;
		}
		
		public function get depth():int {
			return farm.depth;
		}
		
		public function glowing():void {
			glowed = true; 
			var that:FarmPlant = this;
			TweenMax.to(this, 0.8, { glowFilter: { color:0xFFFF00, alpha:1, strength: 6, blurX:15, blurY:15 }, onComplete:function():void {
				TweenMax.to(that, 0.8, { glowFilter: { color:0xFFFF00, alpha:0, strength: 4, blurX:6, blurY:6 }, onComplete:function():void {
					that.filters = [];
					glowed = false;
				}});	
			}});
		}
		
		
		public function growth():void {
			if (level >= info['levels']) {
				App.self.setOffTimer(growth);
			}
		}
		
		public function get level():uint {
			var grownTime:int;
			//var s:int = App.time-planted;
			var currentLevel:uint = int((App.time - planted) / info.levelTime);
			
			if (_level != currentLevel) {
				_level = currentLevel > info.levels ? info.levels : currentLevel;
				updateLevel();
			}
			return _level;
		}
		
		public function set level(level:uint):void {
			_level = level;
		}
		
		public function get ready():Boolean {
			return _level == info.levels;
		}
		
		private function onLoad(data:*):void {
			
			textures = data;
			if(level < info['levels']){
				App.self.setOnTimer(growth);
			}
			updateLevel();
		}
		
		private function updateLevel():void {
			levelData = textures.sprites[_level];
			bitmapData = levelData.bmp;
			x = levelData.dx + point.x;
			y = levelData.dy + point.y;
		}
	}
}