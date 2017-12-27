package ui 
{
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.text.TextField;
	import wins.Window;
	/**
	 * ...
	 * @author ...
	 */
	public class IconCounter extends Sprite
	{
		private var bg:Bitmap;
		private var counter:TextField;
		public function IconCounter() 
		{
			bg = new Bitmap(UserInterface.textures.counterBacking);
			
			var textSettings:Object = {
				color:0xffffff,
				borderColor:0x9a0000,
				fontSize:16,
				textAlign:"center"
			};
			
			counter = Window.drawText(String(25), textSettings);
			counter.width = bg.width + 6;
			counter.height = counter.textHeight;
			counter.x = -3;
			counter.y = 3;
			
			addChild(bg);
			addChild(counter);
		}
		
		public function set count(value:int):void {
			counter.text = String(value)
			
			if (value == 0) {
				counter.visible = false;
				bg.visible = false;
			} else {				
				counter.visible = true;
				bg.visible = true;
			}
		}
	}
}