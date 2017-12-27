package wins 
{
	import buttons.Button;
	import buttons.MoneyButton;
	import core.Size;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	public class ClipperRequireWindow extends Window 
	{
		private var sID:int;
		private var bitmap:Bitmap;
		private var bttnFind:Button;
		private var bttnGo:Button;
		private var bttnBuy:MoneyButton;
		protected var requireLabel:TextField;
		protected var separator:Bitmap;
		protected var separator2:Bitmap;
		private var countLabel:TextField;
		private var have:int;
		private var need:int;
		public function ClipperRequireWindow(settings:Object=null) 
		{
			if (settings == null) {
				settings = new Object();
			}
			
			settings["width"]	= settings.width || 430;
			settings["height"] 	= settings.height || 380;
			settings['title'] 	= settings.title;
			settings['sID'] 	= settings.sID || 0;
			settings["hasPaginator"] 	= false;
			settings["hasArrows"]		= false;
			
			have = App.user.stock.count(settings.sID);
			if (have > 0) have = 1;
			need = 1;
			
			super(settings);			
		}
		
		override public function drawBody():void {		
			if (settings.bitmap) {
				var imgCont:Sprite = new Sprite();
				
				var circle:Shape = new Shape();
				circle.graphics.beginFill(0xc8cabc, 1);
				circle.graphics.drawCircle(0, 0, 56);
				circle.graphics.endFill();
				circle.x = 56;
				circle.y = 80;
				imgCont.addChild(circle);
				
				var img:Bitmap = new Bitmap(settings.bitmap.bitmapData);
				Size.size(img, 140, 140);
				img.smoothing = true;
				
				imgCont.addChild(img);
				
				imgCont.x = (settings.width - imgCont.width) / 2;
				imgCont.y = (settings.height - imgCont.height) / 2 - 30;
				
				bodyContainer.addChild(imgCont);
			}
			
			var descriptionLabel:TextField = drawText(settings.text, {
				fontSize:24,
				autoSize:"left",
				textAlign:"center",
				color:0x5b2b03,
				borderColor:0xf8e6d8
			});
			descriptionLabel.x = (settings.width - descriptionLabel.width) / 2;
			descriptionLabel.y = 20;
			bodyContainer.addChild(descriptionLabel);
			
			if (settings.sID != 933) descriptionLabel.visible = false;
			
			separator = Window.backingShort(285, 'dividerLine', false);
			separator.x = (settings.width - separator.width) / 2;
			separator.y = 85;
			separator.alpha = 0.5;
			bodyContainer.addChild(separator);
			
			requireLabel = drawText(Locale.__e("flash:1423742002798") + ':', {
				fontSize:32,
				autoSize:"left",
				textAlign:"center",
				color:0xfdfba8,
				borderSize:3,
				borderColor:0x4f2a17,
				shadowSize:2,
				shadowColor:0x4f2a17
			});
			requireLabel.x = (settings.width - requireLabel.width) / 2;
			requireLabel.y = 50;
			bodyContainer.addChild(requireLabel);
			
			separator2 = Window.backingShort(285, 'dividerLine', false);
			separator2.x = (settings.width - separator2.width) / 2;
			separator2.y = 260;
			separator2.alpha = 0.5;
			bodyContainer.addChild(separator2);
			
			drawCount();
			drawTitleItem();
			
			bttnFind = new Button({
				caption			:Locale.__e("flash:1405687705056"),
				radius      	:10,
				fontColor:		0xffffff,
				fontBorderColor:0x475465,
				borderColor:	[0xfff17f, 0xbf8122],
				bgColor:		[0x75c5f6,0x62b0e1],
				bevelColor:		[0xc6edfe,0x2470ac],
				width			:180,
				height			:37,
				fontSize		:20
			});
			bttnFind.x = (settings.width - bttnFind.width) / 2;
			bttnFind.y = settings.height - bttnFind.height * 2 - 40;
			bodyContainer.addChild(bttnFind);
			bttnFind.addEventListener(MouseEvent.CLICK, onFind);
			
			bttnBuy = new MoneyButton({
				caption			:Locale.__e("flash:1382952380083"),
				radius      	:10,
				fontColor:		0xffffff,
				fontBorderColor:0x475465,
				width			:180,
				height			:45,
				fontSize		:20,
				countText		:App.data.storage[settings.sID].price[Stock.FANT]
			});
			bttnBuy.x = (settings.width - bttnBuy.width) / 2;
			bttnBuy.y = bttnFind.y + bttnFind.height /*+ 5*/;
			bodyContainer.addChild(bttnBuy);
			bttnBuy.addEventListener(MouseEvent.CLICK, onBuy);
			
			bttnGo = new Button({
				caption			:Locale.__e("flash:1394010224398"),
				radius      	:10,
				width			:180,
				height			:45,
				fontSize		:26
			});
			bttnGo.x = (settings.width - bttnGo.width) / 2;
			bttnGo.y = settings.height - bttnGo.height * 2;
			bodyContainer.addChild(bttnGo);
			bttnGo.addEventListener(MouseEvent.CLICK, onGo);
			
			if (settings.search) {
				bttnFind.visible = true;
				bttnBuy.visible = true;
				bttnGo.visible = false;
			} else {
				bttnFind.visible = false;
				bttnBuy.visible = false;
				bttnGo.visible = true;
			}
		}
		
		public function drawTitleItem():void {
			var titleLabel:TextField = Window.drawText(App.data.storage[settings.sID].title + ':', {
				fontSize:24,
				autoSize:"left",
				textAlign:"center",
				color:0x763c17,
				borderColor:0xf5f2e9
			});
			titleLabel.x = (settings.width - titleLabel.width) / 2;
			titleLabel.y = 85;
			bodyContainer.addChild(titleLabel);
		}
		
		public function drawCount():void {
			if (have < need) {
				countLabel = Window.drawText(String(have) + '/' + String(need), {
					fontSize:36,
					autoSize:"left",
					textAlign:"center",
					color:0xe78f79,
					borderColor:0x742226
				});
				countLabel.x = (settings.width - countLabel.width) / 2;
				countLabel.y = 220;
			} else {
				countLabel = Window.drawText(String(have) + '/' + String(need), {
					fontSize:36,
					autoSize:"left",
					textAlign:"center",
					color:0xffdd33,
					borderColor:0x664816
				});
				countLabel.x = (settings.width - countLabel.width) / 2;
				countLabel.y = 220;
			}
			
			bodyContainer.addChild(countLabel);
		}
		
		private function onFind(e:MouseEvent):void {
			if (settings.onFind) settings.onFind();			
			close();
		}
		
		private function onBuy(e:MouseEvent):void {
			if (settings.onBuy) {
				App.user.stock.buy(settings.sID, 1, settings.onBuy);			
			} else {
				App.user.stock.buy(settings.sID, 1);
			}
			close();
		}
		
		private function onGo(e:MouseEvent):void {
			if (settings.onGo) settings.onGo();			
			close();
		}
		
		override public function close(e:MouseEvent = null):void {
			bttnFind.removeEventListener(MouseEvent.CLICK, onFind);
			bttnGo.removeEventListener(MouseEvent.CLICK, onGo);
			super.close();
		}
	}

}