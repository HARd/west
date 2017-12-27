package units 
{
	import astar.AStarNodeVO;
	import core.IsoConvert;
	import core.Load;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filters.GlowFilter;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	import ui.SystemPanel;
	
	public class Eyes extends Sprite
	{
		public var cells:int;
		public var rows:int;
		
		public static function init():void {
			waitForNext();
		}
		
		private static var diametr:int = 20;
		private static var targets_sIDs:Array = [71, 72, 73, 93, 94, 95, 117, 116, 115, 74, 75, 76, 77, 78, 79, 80, 81, 66, 67, 68, 99, 101, 86,87,88];
		public static function generate():void {
			var Xs:int = App.user.hero.coords.x - diametr/2;
			var Zs:int = App.user.hero.coords.z - diametr/2;
			if (Xs <= 0) Xs = 1;
			if (Zs <= 0) Zs = 1;
			var Xf:int = Xs + diametr;
			var Zf:int = Zs + diametr;
			if (Xs > Map.cells) Xs = Map.cells - 1;
			if (Zs > Map.rows) Zs = Map.rows - 1;
			
			var resources:Array = [];
			
			var node:AStarNodeVO;
			for (var _x:int = Xs; _x < Xs + diametr; _x++) {
				for (var _z:int = Zs; _z < Zs + diametr; _z++) {
					node = App.map._aStarNodes[_x][_z];
					if (node.object == null) continue;
					if (node.object is Resource) {
						if (resources.indexOf(node.object) == -1) 
						{
							if (targets_sIDs.indexOf(node.object.sid) != -1)
								resources.push(node.object);
						}
					}else if (node.object is Building) {
						if (resources.indexOf(node.object) == -1) 
								resources.push(node.object);
					}
				}
			}
			if (resources.length == 0) {
				waitForNext();
				return;
			}
			var randomID:int = int(Math.random() * resources.length);
			new Eyes(resources[randomID]);
		}
		
		public static var _eyes:Array = []; 
		public static function dispose():void {
			for each(var eyes:Eyes in _eyes) {
				eyes.dispose();
			}
			_eyes = [];
			clearTimeout(timerID);
		}
		
		public function Eyes(target:*)
		{
			container = target;
			this.x = target.bitmap.x + target.bitmap.width / 2;
			this.y = target.bitmap.y + target.bitmap.height / 2;
			
			container.addChild(this);
			
			addEye(0);
			addEye(2);
			
			this.filters = [new GlowFilter(0x000000, 0.9, 15, 15, 2, 2, false)];
		}
		
		private var container:*;
		private var eyes:Array = [];

		private var X:int = 0;
		private var Y:int = 0;
		private function addEye(cadr:int):void
		{
			var eye:Eye = new Eye(cadr, this);
			addChild(eye);
			
			var scale:Number = 0.3 + (Math.random()*0.2 - 0.1);
			
			eye.scaleX = eye.scaleY = scale;
			eye.x = X;
			eye.y = Y;
			X += 17;
			//Y -= 7;
			eyes.push(eye);
		}
		
		public function dispose():void 
		{
			if (container.contains(this))
			{
				container.removeChild(this);
			}
			
			for each(var eye:Eye in eyes) {
				removeChild(eye);
				eye.dispose();
				eye = null;
			}
		}
		
		public static var timerID:int;
		public static function waitForNext():void 
		{
			var time:int = 2000 + Math.random() * 5000;
			timerID = setTimeout(generate, time);
		}
		
		public function wait():void {
			waitForNext();
			dispose();
		}
		
		public function next():void 
		{
			var position:Object = IsoConvert.isoToScreen(cells, rows, true);
			
			this.x = position.x;
			this.y = position.y;
			
			var viewportX:int = Map.mapWidth - (Map.mapWidth + App.map.x);
			var viewportY:int = Map.mapHeight - (Map.mapHeight + App.map.y);
			
			x = viewportX + Math.random() * App.self.stage.stageWidth;
			y = viewportY + Math.random() * App.self.stage.stageHeight;
			
			var cadr:int = 0;
			for each(var eye:Eye in eyes) {
				eye.frame = cadr;
				eye.startAnimation();
				cadr += 2;
			}
		}
	}
}


import core.Load;
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.events.Event;
import ui.SystemPanel;

internal class Eye extends Sprite
{
	private var textures:Object = null;
	private var _parent:*;
	public function Eye(cadr:int, _parent:*) 
	{
		this._parent = _parent;
		frame = cadr;
		Load.loading(Config.getSwf('Tools', 'eye'), onLoad);
	}
	
	private function onLoad(data:*):void {
		textures = data;
		addAnimation();
		startAnimation();
	}
	
	private var frameLength:int = 0;
	private var framesType:String = 'eye';
	private var bitmap:Bitmap;
	
	public function addAnimation():void
	{
		frameLength = textures.animation.animations[framesType].chain.length;
		bitmap = new Bitmap();
		addChild(bitmap);
	}
	
	public function startAnimation(random:Boolean = false):void
	{
		frameLength = textures.animation.animations[framesType].chain.length;
		
		if (random) {
			frame = int(Math.random() * frameLength);
		}
		
		App.self.setOnEnterFrame(animate);
		animated = true;
	}
	public var animated:Boolean = false;
	
	public function stopAnimation():void
	{
		animated = false;
		App.self.setOffEnterFrame(animate);
	}
	
	public var frame:int = 0;
	public function animate(e:Event = null):void
	{
		if (!SystemPanel.animate) return;
		
		var cadr:uint 			= textures.animation.animations[framesType].chain[frame];
		var frameObject:Object 	= textures.animation.animations[framesType].frames[cadr];
				
		bitmap.bitmapData = frameObject.bmd;
		bitmap.x = frameObject.ox;
		bitmap.y = frameObject.oy;
		bitmap.smoothing = true;
		
		frame ++;
		if (frame >= frameLength)
			wait();
			
	}
	
	private function wait():void {
		_parent.wait();
		stopAnimation();
	}
	
	public function dispose():void {
		stopAnimation();
	}
}