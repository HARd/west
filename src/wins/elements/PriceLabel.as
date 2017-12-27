package wins.elements 
{
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.text.TextField;
	import ui.UserInterface;
	import wins.Window;
	/**
	 * ...
	 * @author 
	 */
	public class PriceLabel extends Sprite
	{
		public var icon:Bitmap = new Bitmap;
		public var text:TextField;
		
		public function PriceLabel(price:Object) 
		{
			if (price == null) return;
			var count:int = 0;
			var num:int = 0;
			for (var sID:* in price) {
				count = price[sID];
				break;
			}
			
			if (sID == null) sID = Stock.FANT;
			switch(sID) {
				case Stock.COINS:
					icon = new Bitmap(UserInterface.textures.coinsIcon, "auto", true);
					break;
				case Stock.FANT:
					icon = new Bitmap(UserInterface.textures.fantsIcon, "auto", true);
					break;	
				case Stock.FANTASY:
					icon = new Bitmap(UserInterface.textures.energyIcon, "auto", true);
					break;
			}
			
			addChild(icon);
			
			
			
			var settings:Object = {
					fontSize:24,
					autoSize:"left",
					color:0xffdc39,
					borderColor:0x6d4b15
				}
				
			if (sID == Stock.FANT)
			{
				settings["color"]	 	= 0xd0ff74;
				settings["borderColor"] = 0x26600a;
			}
			
			
			text = Window.drawText(String(count), settings);
			
			addChild(text);
			text.height = text.textHeight;
			
			
			icon.height = text.height - 3;
			icon.scaleX = icon.scaleY;
			icon.smoothing = true;
			
			icon.x = 0;
			icon.y = 0;
			
			text.x = icon.width + 5;
			text.y = icon.height / 2 - text.textHeight / 2;
			
			num++;
			
		}	
		
	}

}