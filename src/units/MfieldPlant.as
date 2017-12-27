package units {
	
	import core.Load;
	import flash.display.Bitmap;
	import flash.display.DisplayObjectContainer;
	
	public class MfieldPlant extends Bitmap {
		
		public var info:Object;
		public var sid:uint = 0;
		public var planted:int = 0;
		public var type:String = "Plant";
		public var slot:int = 0;
		public var textures:Object;
		public var levelData:Object;
		public var glowed:Boolean = false;
		public var point:Object;
		
		private var _mfield:Mfield;
		private var _level:uint = 0;
		
		public function MfieldPlant(object:Object) {
			
			sid = object.sid;
			planted = object.planted;
			point = object.point;
			
			info = App.data.storage[this.sid];
			_mfield = object.mfield;
			name = 'plant';
			this.x = _mfield.dx;
			this.x = _mfield.dy;
			
			Load.loading(Config.getSwf(type, info.view), onLoad);
		}
		
		override public function get parent():DisplayObjectContainer {
			return _mfield;
		}
		
		public function get index():int {
			return _mfield.index;
		}
		
		public function set index(value:int):void {
			_mfield.index = value;
		}
		
		public function get depth():int {
			return _mfield.depth;
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
		
		protected function onLoad(data:*):void {
			
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