package units 
{
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import ui.SystemPanel;

	public class Anime2 extends Sprite
	{
		public var animation:Object;
		public var framesType:String;
		public var bitmap:Bitmap = new Bitmap();
		public var frameLength:int = 0;
		public var frame:int = 0;
		public var animated:Boolean = false;
		public var ax:int = 0;
		public var ay:int = 0;
		
		public function Anime2(animation:Object, framesType:String, ax:int = 0, ay:int = 0, scale:Number = 1)
		{
			this.ax = (ax == 0?animation.ax:ax);
			this.ay = (ay == 0?animation.ay:ay);
			
			this.animation = animation;
			this.framesType = framesType;
			addChild(bitmap);
			
			if (scale != 1)
				this.scaleX = this.scaleY = scale;
		}
		
		public function startAnimation(random:Boolean = false):void
		{
			if (animated) return;
			
			frameLength = animation.animation.animations[framesType].chain.length;
			
			if (random) {
				frame = int(Math.random() * frameLength);
			}
			
			App.self.setOnEnterFrame(animate);
			
			animated = true;
		}
		
		public function stopAnimation():void
		{
			animated = false;
			App.self.setOffEnterFrame(animate);
		}
		
		public function animate(e:Event = null):void
		{
			if (!SystemPanel.animate) return;
			
			var cadr:uint 			= animation.animation.animations[framesType].chain[frame];
			var frameObject:Object 	= animation.animation.animations[framesType].frames[cadr];
				
			bitmap.bitmapData = frameObject.bmd;
			bitmap.smoothing = true;
			bitmap.x = frameObject.ox+ax;
			bitmap.y = frameObject.oy+ay;
			
			frame ++;
			if (frame >= frameLength)
			{
				frame = 0;
				onLoop();
			}
		}
		
		public function onLoop():void {
			
		}
		
		public function dispose():void {
			stopAnimation();
		}
	}
}