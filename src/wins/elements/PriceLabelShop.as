package wins.elements 
{
	import core.Load;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.filters.DropShadowFilter;
	import flash.geom.Matrix;
	import flash.text.TextField;
	import ui.BitmapLoader;
	import ui.UserInterface;
	import wins.Window;
	/**
	 * ...
	 * @author ...
	 */
	public class PriceLabelShop extends LayerX
	{
		public var icon:Bitmap;
		public var text:TextField;
		
		private var iconSize:int = 30;
		private var num:int = 0;
		
		public function PriceLabelShop(price:Object) 
		{
			if (price == null) return;
			var count:int = 0;
			
			for (var sID:* in price) {
				count = price[sID];
				
				if (sID == null) return;
				
				if (int(sID) == Stock.FANT) {
					icon = new Bitmap(UserInterface.textures.fantsIcon, 'auto', true);
				}else if (int(sID) == Stock.COINS) {
					icon = new Bitmap(UserInterface.textures.coinsIcon, 'auto', true);
				}else if (int(sID) == Stock.ACTION) {
					icon = new Bitmap(UserInterface.textures.shareIco, 'auto', true);
				}else if (int(sID) == Stock.HELLOWEEN_ICON) {
					icon = new Bitmap(UserInterface.textures.helloweenMoneyIco, 'auto', true);
				}else if (int(sID) == Stock.SILVER_COIN) {
					icon = new Bitmap(UserInterface.textures.silverCoin, 'auto', true);
				}else if (int(sID) == Stock.PATRICK_ICON) {
					icon = new Bitmap(Window.textures.patricCoinIco, 'auto', true);
				}else if (int(sID) == Stock.SMILE_COIN) {
					icon = new Bitmap(Window.textures.smileIco, 'auto', true);
				}else if (int(sID) == Stock.VAUCHER) {
					icon = new Bitmap(UserInterface.textures.voucherIco, 'auto', true);
				}else {
					var bitmapIcon:BitmapLoader = new BitmapLoader(sID, iconSize, iconSize);
					bitmapIcon.x = 6;
					bitmapIcon.y = -20;
					addChild(bitmapIcon);
					
					icon = new Bitmap(new BitmapData(iconSize,iconSize,true,0), "auto", true);
					//addChild(icon);
					//Load.loading(Config.getIcon(App.data.storage[sID].type, App.data.storage[sID].preview), onLoad);
				}
				
				if (icon.width > icon.height) {
					icon.width = iconSize;
					icon.scaleY = icon.scaleX;
				}else {
					icon.height = iconSize;
					icon.scaleX = icon.scaleY;
				}
				
				addChild(icon);
				
				var settings:Object = {
					fontSize:20,
					autoSize:"left",
					color:0xffdc39,
					borderColor:0x6d4b15
				}
				
				if (sID == Stock.FANT) {
					settings["color"]	 	= 0xb7ee88;
					settings["borderColor"] = 0x436710;
				}
				
				if (sID == Stock.FANTASY) {
					settings["color"]	 	= 0xfefdcf;
					settings["borderColor"] = 0x775002;
				}
				
				settings['filters'] = [new DropShadowFilter(1, 90, settings["borderColor"], 1, 0, 0)];
				text = Window.drawText(String(count), settings);
				
				addChild(text);
				text.height = text.textHeight;
				
				
				icon.scaleX = icon.scaleY;
				icon.smoothing = true;
				
				icon.x = 6;
				icon.y = 0 - (icon.height +2) * num;
				
				text.x = icon.width + 8;
				text.y = icon.height / 2 - text.textHeight / 2 - (text.height-2) * num;
				
				num++;
				
			}
			
			if (App.data.storage[sID]) {
				tip = function():Object {
					return {
						title:		App.data.storage[sID].title,
						text:		App.data.storage[sID].desc
					}
				}
			}
			
			if (num == 1) {
				icon.y -= 20;
				text.y -= 20;
			}
		}
		
		public function getNum():int
		{
			return num;
		}
		
		private function onLoad(data:Bitmap):void {
			var lowestScaleParams:Number = iconSize / data.width;
			circleMinimize(data.bitmapData, lowestScaleParams);
			/*if (lowestScaleParams < 0) {
				trace(lowestScaleParams);
			}
			if (lowestScaleParams > icon.height / data.height) lowestScaleParams = icon.width / data.width;*/
			//icon.bitmapData.draw(data, new Matrix(lowestScaleParams, 0, 0, lowestScaleParams), null, null, null, true);
		}
		private function circleMinimize(source:BitmapData, finishSize:Number):void {
			var bmd:BitmapData;
			if (finishSize < 0.75) {
				bmd = new BitmapData(Math.ceil(source.width * 0.75), Math.ceil(source.height * 0.75), true, 0);
				bmd.draw(source, new Matrix(0.75, 0, 0, 0.75), null, null, null, true);
				finishSize *= 1.5;
				circleMinimize(bmd, finishSize);
			}else {
				bmd = new BitmapData(Math.ceil(source.width * finishSize), Math.ceil(source.height * finishSize), true, 0);
				bmd.draw(source, new Matrix(finishSize, 0, 0, finishSize), null, null, null, true);
				icon.bitmapData = bmd;
			}
		}
	}

}