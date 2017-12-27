package effects
{
	import flash.display.Sprite;
	import flash.events.Event;

	/**
	 * ...
	 * @author 
	 */
	public class Sparks extends Sprite 
	{
		private var cont:Sprite;
		public function Sparks():void 
		{
			var L:int = 20;
			for (var i:int = 0; i < L; i++) {
				var star:Spark = new Spark(i, L);
				addChild(star);
			}
		}
		
		public function dispose():void {
			
		}
	}
	
}

	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.utils.setTimeout;
	
	internal class Spark extends Sprite {
		
		//[Embed(source = "spark.png", mimeType = "image/png")]
		[Embed(source = "Spark.png", mimeType = "image/png")]
		private var Exp:Class;
		
		private var bitmap:Bitmap;
		private var maxX:int = 100;
		private var dX:int = 7;
		private var dScale:Number = 0.05;//0.05;
		private var dAlpha:Number = 0.12;//0.1;
		private var maxScale:Number;
		
		public function Spark(i:int, L:int):void {
			setTimeout(go, Math.random() * 50);
			this.rotation = 360 / L * i;
		}
		
		private function onFrame(e:Event):void {
			
			if (bitmap.x > maxX) {
				dispose();
				return;
			}
			
			bitmap.x += dX;
			bitmap.scaleX += dScale;
			bitmap.scaleY = bitmap.scaleX;
			bitmap.alpha -= dAlpha;
			bitmap.rotation +=5;
		}
		
		private function dispose():void {
			removeEventListener(Event.ENTER_FRAME, onFrame)
		}
		
		private function go():void {
			
			bitmap = new Bitmap(new Exp().bitmapData);
			addChild(bitmap);
			bitmap.smoothing = true;
			bitmap.alpha = 1;
			var scale:Number = 1;// + Math.random() * 0.25;
			bitmap.scaleX = bitmap.scaleY = scale;
			addEventListener(Event.ENTER_FRAME, onFrame)
		}
	}