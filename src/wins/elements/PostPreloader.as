package wins.elements 
{
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.filters.BlurFilter;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import wins.Window;
	/**
	 * ...
	 * @author 
	 */
	public class PostPreloader extends Sprite
	{
		private var preloader:Preloader = new Preloader();
		
		public function PostPreloader() 
		{
			drawBody();
		}
		
		private function drawBody():void 
		{
			var square:Bitmap = new Bitmap(Window.textures.downloadBacking);
			addChild(square);
			
			//square.filters = [new GlowFilter(0x1e1d1d, 1, 30, 30, 8, 1), new BlurFilter(30, 30)]
			
			addChild(preloader);
			preloader.scaleX = preloader.scaleY = 0.8;
			preloader.x = 50;
			preloader.y = 80;
			
			var txt:TextField = Window.drawText(Locale.__e("flash:1395217591849"), {
				color:0xffffff,
				borderColor:0x1d3b3d,
				fontSize:22,
				textAlign:"center"
			});
			addChild(txt);
			txt.x = preloader.x + preloader.width/2 + 10;
			txt.y = (square.height - txt.textHeight) / 2 + 16;
			
		}
		
		public function dispose():void
		{
			if(preloader && preloader.parent)preloader.parent.removeChild(preloader);
		}
		
	}

}