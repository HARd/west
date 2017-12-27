package wins 
{
	import buttons.Button;
	import buttons.MoneyButton;
	import core.Load;
	import core.Size;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import ui.Hints;
	import units.Techno;
	import units.Unit;
	public class BuyItemWindow extends Window 
	{
		private var sID:int;
		private var bttnBuy:MoneyButton;
		private var bttnFind:Button;
		protected var requireLabel:TextField;
		protected var separator:Bitmap;
		protected var separator2:Bitmap;
		private var countLabel:TextField;
		private var have:int;
		private var need:int;
		
		private var img:Bitmap;
		private var item:Object;
		private var imgCont:Sprite = new Sprite();
		public function BuyItemWindow(settings:Object=null) 
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
			
			this.sID = settings.sID;
			
			have = App.user.stock.count(settings.sID);
			need = 1;			
				
			var circle:Shape = new Shape();
			circle.graphics.beginFill(0xc8cabc, 1);
			circle.graphics.drawCircle(0, 0, 56);
			circle.graphics.endFill();
			circle.x = 56;
			circle.y = 80;
			imgCont.addChild(circle);
			
			img = new Bitmap();			
			imgCont.addChild(img);
			
			imgCont.x = (settings.width - imgCont.width) / 2;
			imgCont.y = (settings.height - imgCont.height) / 2 - 30;
			
			
			
			item = App.data.storage[sID];
			Load.loading(Config.getIcon(item.type, item.preview), onLoad);
			
			super(settings);			
		}
		
		private function onLoad(data:*):void {
			img.bitmapData = data.bitmapData;
			
			Size.size(img, 140, 140);
			img.smoothing = true;
			img.x = (imgCont.width - img.width) / 2;
			img.y = (imgCont.height - img.height) / 2;
		}
		
		override public function drawBody():void {		
			bodyContainer.addChild(imgCont);
			
			separator = Window.backingShort(285, 'dividerLine', false);
			separator.x = (settings.width - separator.width) / 2;
			separator.y = 75;
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
			requireLabel.y = 20;
			bodyContainer.addChild(requireLabel);
			
			separator2 = Window.backingShort(285, 'dividerLine', false);
			separator2.x = (settings.width - separator2.width) / 2;
			separator2.y = 250;
			separator2.alpha = 0.5;
			bodyContainer.addChild(separator2);
			
			drawCount();
			drawTitleItem();
			
			bttnBuy = new MoneyButton({
				caption			:Locale.__e("flash:1382952379751"),
				countText		:String(item.price[Stock.FANT]),
				radius      	:10,
				width			:180,
				height			:45,
				fontSize		:26
			});
			bttnBuy.x = (settings.width - bttnBuy.width) / 2;
			bttnBuy.y = settings.height - bttnBuy.height * 2 + 5;
			bodyContainer.addChild(bttnBuy);
			bttnBuy.addEventListener(MouseEvent.CLICK, onBuy);
			
			bttnFind = new Button({
				caption			:Locale.__e("flash:1405687705056"),
				radius      	:10,
				fontColor:		0xffffff,
				fontBorderColor:0x475465,
				borderColor:	[0xfff17f, 0xbf8122],
				bgColor:		[0x75c5f6,0x62b0e1],
				bevelColor:		[0xc6edfe,0x2470ac],
				width			:100,
				height			:35,
				fontSize		:20
			});
			bttnFind.x = (settings.width - bttnFind.width) / 2;
			bttnFind.y = bttnBuy.y - bttnBuy.height + 10;
			bodyContainer.addChild(bttnFind);
			bttnFind.addEventListener(MouseEvent.CLICK, onFind);
			
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
			if (countLabel) {
				bodyContainer.removeChild(countLabel);
			}
			have = App.user.stock.count(sID);
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
			ShopWindow.findMaterialSource(sID);			
			close();
		}
		
		private function onBuy(e:MouseEvent):void {
			if (e.currentTarget.mode == Button.DISABLED) return;
			
			App.user.stock.buy(this.sID, 1, onBuyComplete);
			//if (window.settings.closeAfterBuy) window.close();
		}
		
		private function onBuyComplete(sID:uint, rez:Object = null):void
		{
			if (settings.callback != null) settings.callback(sID);
			/*if (Techno.TECHNO == sID) {
				addChildrens(sID, rez.ids);
			} else */if ([908, 912].indexOf(int(sID)) != -1) {
				var settings:Object = { sid:sID, fromStock:true };
				
				var unit:Unit = Unit.add(settings);
				unit.move = true;
				App.map.moved = unit;
				close();
			} else {
				var currentTarget:Button = bttnBuy;
				
				var X:Number = App.self.mouseX - currentTarget.mouseX + currentTarget.width / 2;
				var Y:Number = App.self.mouseY - currentTarget.mouseY;
				
				Hints.plus(this.sID, 1, new Point(X,Y), true, App.self.tipsContainer);
				
				for (var _sid:* in item.price)
					Hints.minus(_sid, item.price[_sid], new Point(X, Y), false, App.self.tipsContainer);
			}
			
			if (sID != Techno.TECHNO){
				flyMaterial();
			}
			
			drawCount();
			
			//window.removeItems();
			//window.createItems();
			//window.contentChange();
			//if (window.settings.closeAfterBuy)	window.close();
		}
		
		override public function close(e:MouseEvent = null):void {
			bttnBuy.removeEventListener(MouseEvent.CLICK, onBuy);
			super.close();
		}
		
		private function flyMaterial():void
		{
			var _sID:uint = sID;
			if (App.data.storage[sID].type == 'Energy' && App.data.storage[sID].view == 'Energy' && !App.data.storage[sID].inguest){
				_sID = Stock.FANTASY;
			}
			if (App.data.storage[sID].type == 'Energy' && App.data.storage[sID].view == 'Energy' && App.data.storage[sID].inguest == 1){
				_sID = Stock.GUESTFANTASY;
			}
			if (App.data.storage[sID].type == 'Energy' && App.data.storage[sID].view == 'Feed' && !App.data.storage[sID].inguest){
				_sID = App.data.storage[sID].out;
			}
				
			var item:BonusItem = new BonusItem(_sID, 0);
			
			var point:Point = Window.localToGlobal(img);
			item.cashMove(point, App.self.windowContainer);
		}
	}

}