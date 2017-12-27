package wins.elements 
{
	
	import buttons.ImageButton;
	import buttons.MixedButton;
	import com.greensock.TweenLite;
	import core.Load;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import wins.Window;

	public class MapIcon extends LayerX
	{
		public var worldID:uint;
		public var _open:Boolean = false;
		public var lock:Bitmap;
		public var round:Sprite;
		public var unready:Boolean = false;
		public var bitmap:*;
		public var id:int = 0;
		
		
		private var _dX:int = 0;
		private var _dY:int = 0;
		public function get open():Boolean {
			return _open;
		}
		public function set open(value:Boolean):void {
			_open = value;
			if (_open) {
				
				bitmap.tip = function():Object {
					return {
						title:world.title,
						text:Locale.__e('flash:1382952380052')
					}
				}
				
				if (lock != null) lock.visible = false;
			}
			else
			{
				addSmallLock();
				bitmap.tip = function():Object {
					return {
						title:world.title,
						text:Locale.__e('flash:1382952380059')
					}
				}
			}
		}
		
		private var world:Object;
		private var window:*;
		public function MapIcon(worldID:uint, window:*)
		{
			this.window = window;
			this.id = id;
			var color:* = 0xFF0000;
			this.worldID = worldID;
			
			world = App.data.storage[worldID];
			
			/*if (worldID == User.HOME_WORLD) {
				bitmap = new MixedButton(Window.textures.bubble, { caption:Locale.__e("flash:1382952380060"), fontSize:26 } );
				bitmap.textLabel.x -= 2;
				bitmap.textLabel.height = bitmap.textLabel.textHeight + 2;
			}else{*/
				bitmap = new ImageButton(Window.textures.bubble);
			//}
			
			_dX = - Window.textures.bubble.width / 2;
			_dY = - Window.textures.bubble.height / 2;
			
			addChild(bitmap);
			bitmap.x = _dX;
			bitmap.y = _dY;
			
			if (world.preview != 'empty' && world.visible != 0){
				Load.loading(Config.getIcon('Dreams', world.preview), function onLoad(data:Bitmap):void {
					bitmap.bitmapData = data.bitmapData;
					bitmap.x = - bitmap.width/2;
					bitmap.y = - bitmap.height/2;
				});
			}	
			
			if ((world.require == null || world.visible == 0))// && worldID != User.HOME_WORLD) 
			{
				addLock();
				unready = true;
				
				bitmap.tip = function():Object {
					return {
						title:'',
						text:Locale.__e('flash:1382952380061')
					}
				}
				
				return;
			}
			
			
			if (App.user.mode == User.OWNER) {
				if (World.isOpen(worldID)) {
					color = 0x0000FF;
					open = true;
				}
				else {
					open = false;
				}
			}
			else
			{
				if (App.owner.worlds.hasOwnProperty(worldID)) {
					color = 0x0000FF;
					open = true;
				}
				else
				{
					open = false;
				}
			}
			
			
			
			if (Quests.help) {
				var qID:int = App.user.quests.currentQID;
				var mID:int = App.user.quests.currentMID;
				var targets:Object = App.data.quests[qID].missions[mID].target;
				for each(var sid:* in targets){
					if(worldID == sid){
						if (worldID != App.user.worldID){
							startGlowing();
						}
					}
				}
			}
		}
		
		public function removeArrows():void {
			for each(var arrow:* in arrows) {
				removeChild(arrow);
			}
			arrows = [];
		}
		
		private var arrows:Array = [];
		public function drawArrowTo(targetIcon:MapIcon):void {
			var a:Number = targetIcon.x - this.x;
			var b:Number = targetIcon.y - this.y;
			var rad:Number = Math.acos(b / Math.sqrt(a * a + b * b));
			var angle:int = (180 * rad / Math.PI);
			
			var sector:int = 0;
			if (targetIcon.x > this.x)
				angle = 90 - angle;
			else	
				angle = angle + 90; 
			
			var arrow:Sprite = new Sprite();
			var line:Shape = new Shape();
			
			var _bitmap:Bitmap = new Bitmap(Window.textures.worldsArrow);
			_bitmap.scaleX = _bitmap.scaleY = 1;
			_bitmap.smoothing = true;
			_bitmap.y = - _bitmap.height - Window.textures.bubble.height/2 + 8;
			_bitmap.x = - _bitmap.width/2;
			 
			arrow.addChild(_bitmap);
			addChildAt(arrow, 0);
			arrows.push(arrow);
			arrow.x = 0;
			arrow.y = 0;
			arrow.rotation = angle + 90;
			arrow.alpha = 0;
			TweenLite.to(arrow, 0.3, { alpha:1 } );
		}
		
		private function addSmallLock():void {
			lock = new Bitmap(Window.textures.lockIcon);
			lock.scaleX = lock.scaleY = 0.5;
			lock.smoothing = true
			lock.x = -lock.width/2;
			lock.y = 20;
			addChild(lock); 
		}
		
		private function addLock():void {
			lock = new Bitmap(Window.textures.lockIcon);
			lock.scaleX = lock.scaleY = 0.7;
			lock.smoothing = true
			lock.x = -lock.width / 2;
			lock.y = -lock.height / 2;
			addChild(lock); 
		}
	}
}	