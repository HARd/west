package wins
{
	import buttons.Button;
	import buttons.IconButton;
	import buttons.ImageButton;
	import com.greensock.TweenLite;
	import core.Load;
	import core.Size;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import silin.utils.Hint;
	import ui.Hints;
	import ui.UserInterface;
	
	public class ShipTransferWindow extends Window
	{
		public var item:Object;
		
		public static const TO_STOCK:uint = 1;
		public static const FROM_STOCK:uint = 2;
		//public var background_:Bitmap;
		public var bitmap:Bitmap;
		private var icon:Bitmap;
		public var title:TextField;
		public var priceBttn:Button;
		public var placeBttn:Button;
		public var applyBttn:Button;
		public var wishBttn:ImageButton;
		public var giftBttn:ImageButton;
		public var sellPrice:TextField;
		public var price:int;
		
		public var plusBttn:Button;
		public var minusBttn:Button;
		
		public var plus10Bttn:Button;
		public var minus10Bttn:Button;
		
		public var countCalc:TextField;
		public var countOnStock:TextField;
		
		public function ShipTransferWindow(settings:Object = null):void
		{
			if (settings == null) {
				settings = new Object();
			}
			
			settings['sID'] = settings.sID || 0;	
			item = App.data.storage[settings.sID];
			
			settings["title"] = Locale.__e("flash:1464957509912");
			settings["hasTitle"] = false;
			
			settings["width"] = 310;
			settings["height"] = 305;
			settings["popup"] = true;
			settings["fontSize"] = 28;
			settings["callback"] = settings["callback"] || null;
			
			settings["hasPaginator"] = false;
			
			super(settings);
		}
		
		override public function drawBackground():void {
			background = backing(settings.width, settings.height, 50, "alertBacking");
			layer.addChild(background);
		}
		
		private var preloader:Preloader = new Preloader();		
		override public function drawBody():void {
			var sprite:LayerX = new LayerX();
			bodyContainer.addChild(sprite);
		
			bitmap = new Bitmap();
			sprite.addChild(bitmap);
		
			sprite.tip = function():Object { 
				return {
					title:item.title,
					text:item.description
				};
			};
		
			drawTitleItem();
			drawBttns();
			
			addChild(preloader);
			preloader.x = (settings.width - preloader.width)/ 2;
			preloader.y = (background.height - preloader.height) / 2 - 20 + background.y;
			
			var backImage:Bitmap = new Bitmap(new BitmapData(55 * 2, 55 * 2, true, 0xffffff));
			backImage.x = (background.width - backImage.width) / 2;
			backImage.y = (background.height - backImage.height) / 2 - 20;
			bodyContainer.addChildAt(backImage, 0);
			
			var shape:Shape = new Shape();
			shape.graphics.beginFill(0xc6c7b6, 1);
			shape.graphics.drawCircle(55, 55, 55);
			shape.graphics.endFill();
			backImage.bitmapData.draw(shape);
			
			Load.loading(Config.getIcon(item.type, item.preview), onLoad);
			
			if (item.cost) {
				price = Math.round(item.cost - (item.cost * 0.1));
			}else if (item.sale) {
				price = salePrice();
			}
			
			if (item.type == "e") {
				priceBttn.visible = false;
			}else{
				drawCalculator();
				drawSellPrice();
			}
			
			drawCount();
			
			if (settings['max'] > 0) {
				countOnStock.text = (int(countOnStock.text) > 0) ? String(int(countOnStock.text) - 1) : "0";
				countCalc.text = '1';
			}
			
			addEventListener(MouseEvent.MOUSE_OVER, onOverEvent);
			addEventListener(MouseEvent.MOUSE_OUT, onOutEvent);
		}
		
		public function salePrice():int {
			if (item.sale) {
				for (var s:String in item.sale) {
					switch(int(s)) {
						case Stock.FANT:
							onSaleIconLoad(new Bitmap(UserInterface.textures.fantsIcon, 'auto', true));
							break;
						default:
							Load.loading(Config.getIcon(App.data.storage[s].type, App.data.storage[s].preview), onSaleIconLoad);
					}
					return item.sale[s];
				}
			}
			
			return 0;
		}
		
		public function onLoad(data:Bitmap):void
		{
			removeChild(preloader);
			
			bitmap.bitmapData = data.bitmapData;
			Size.size(bitmap, 110, 110);
			bitmap.smoothing = true;
			bitmap.x = (settings.width - bitmap.width)/2;
			bitmap.y = (background.height - bitmap.height) / 2 - 20 + background.y;
		}
		public function onSaleIconLoad(data:Bitmap):void {
			if (!icon) {
				icon = new Bitmap(data.bitmapData, 'auto', true);
			}else {
				icon.bitmapData = data.bitmapData;
				icon.smoothing = true;
			}
			drawSellSize();
		}
	
		override public function dispose():void {
			super.dispose();
			
			removeEventListener(MouseEvent.MOUSE_OVER, onOverEvent);
			removeEventListener(MouseEvent.MOUSE_OUT, onOutEvent);
			
			if (plusBttn != null){
				plusBttn.removeEventListener(MouseEvent.CLICK, onPlusEvent);
				minusBttn.removeEventListener(MouseEvent.CLICK, onMinusEvent);
				plus10Bttn.removeEventListener(MouseEvent.CLICK, onPlus10Event);
				minus10Bttn.removeEventListener(MouseEvent.CLICK, onMinus10Event);
			}
			
			priceBttn.removeEventListener(MouseEvent.CLICK, onSend);
		}
		
		public function drawTitleItem():void {
			title = Window.drawText(item.title, {
				color:0x7e3918,
				borderColor:0xfdf7e9,
				textAlign:"center",
				autoSize:"center",
				fontSize:24,
				multiline:true,
				width:background.width - 170
			});
			title.wordWrap = true;
			title.x = 90;
			title.y = background.y + 50;
			bodyContainer.addChild(title);
		}
		
		public function drawCount():void {
			countOnStock = Window.drawText(String(settings['count']), {
				color:0xfffdfb,
				borderColor:0x89562b,
				fontSize:24,
				autoSize:"center"
			});
			
			var circleSprite:Sprite = new Sprite();
			var bg:Shape = new Shape();
			bg.graphics.beginFill(0xffebd4);
			bg.graphics.drawCircle(0, 0, 23);
			
			var bg2:Shape = new Shape();
			bg.graphics.beginFill(0x99b1ae);
			bg.graphics.drawCircle(0, 0, 20);
				
			circleSprite.addChild(bg);
			circleSprite.addChild(bg2);
			circleSprite.x = 48;
			circleSprite.y = -20;
			bg.x = background.x + 22;
			bg2.x = background.x + 22;
			bg.y = background.y + 85;
			bg2.y = background.y + 85;
			
			circleSprite.addChild(countOnStock);
			bodyContainer.addChild(circleSprite);
			
			countOnStock.x = bg.x - countOnStock.textWidth/2 - 2;
			countOnStock.y = bg.y - countOnStock.textHeight/2;
			
			if (countOnStock.text == "0") {
				plusBttn.state = Button.DISABLED;
				plus10Bttn.state = Button.DISABLED;
			}
		}
		
		public function drawSellPrice():void {
			return;
			var settings:Object = {  };
			
			if (!icon) icon = new Bitmap(UserInterface.textures.coinsIcon, "auto", true);
			drawSellSize();
			
			icon.x = 150;
			icon.y = 165;
			
			//bodyContainer.addChild(icon);
			
			sellPrice = Window.drawText(String(price), {
				fontSize:22, 
				autoSize:"left",
				color:0xffdc39,
				borderColor:0x794909
			});
			//bodyContainer.addChild(sellPrice);
			sellPrice.x = icon.x + icon.width + 5;
			sellPrice.y = icon.y + 1;
			
			var open:TextField = Window.drawText(Locale.__e("flash:1382952380131"), {
				color:0x783a15,
				borderColor:0xffe4ba,
				borderSize:3,
				fontSize:24,
				autoSize:"left"
			});
			//bodyContainer.addChild(open);
			open.x = 85;
			open.y = 165;
		}
		private function drawSellSize():void {
			icon.height = 30;
			icon.scaleX = icon.scaleY;
		}
		
		public function drawCalculator():void {
			var countBg:Shape = new Shape();
			countBg.graphics.beginFill(0xc29f5f);
			countBg.graphics.drawCircle(60, -18, 18);
			countBg.x = (background.width - countBg.width) / 2 - 40;
			countBg.y = 230;
			bodyContainer.addChild(countBg);
			
			countCalc = Window.drawText(String(0), {
				color:0xfeffff,
				borderColor:0x572c26,
				fontSize:24,
				textAlign:"center"
			});
			
			bodyContainer.addChild(countCalc);
			countCalc.width = countBg.width;
			countCalc.height = countCalc.textHeight;
			countCalc.x = countBg.x + countBg.width + 6;
			countCalc.y = countBg.y - countBg.height + 3;
			
			var setM10:Object = {
				caption			:"-10",
				bgColor			:[0xffe3af, 0xffb468],
				bevelColor		:[0xffeee0, 0xc0804e],
				borderColor		:[0xc3b197, 0xcab89f],
				width			:38,
				height			:26,
				fontSize		:18,
				fontColor		:0xffffff,
				fontBorderColor	:0xa05d36,
				shadow			:true,
				radius			:10,
				shadowColor		:0xa05d36,
				shadowSize		:3
			};
			var setM:Object = {
				caption			:"-",
				bgColor			:[0xffe3af, 0xffb468],
				bevelColor		:[0xffeee0, 0xc0804e],
				borderColor		:[0xc3b197, 0xcab89f],
				width			:28,
				height			:26,
				fontSize		:18,
				fontColor		:0xffffff,
				fontBorderColor	:0xa05d36,
				shadow			:true,
				radius			:10,
				shadowColor		:0xa05d36,
				shadowSize		:3
			};
			var setP:Object = {
				caption			:"+",
				bgColor			:[0xffe3af, 0xffb468],
				bevelColor		:[0xffeee0, 0xc0804e],
				borderColor		:[0xc3b197, 0xcab89f],
				width			:28,
				height			:26,
				fontSize		:18,
				fontColor		:0xffffff,
				fontBorderColor	:0xa05d36,
				shadow			:true,
				radius			:10,
				shadowColor		:0xa05d36,
				shadowSize		:3
			};
			var setP10:Object = {
				caption			:"+10",
				bgColor			:[0xffe3af, 0xffb468],
				bevelColor		:[0xffeee0, 0xc0804e],
				borderColor		:[0xc3b197, 0xcab89f],
				width			:38,
				height			:26,
				fontSize		:18,
				fontColor		:0xffffff,
				fontBorderColor	:0xa05d36,
				shadow			:true,
				radius			:10,
				shadowColor		:0xa05d36,
				shadowSize		:3
			};
			
			minus10Bttn = new Button(setM10);
			minus10Bttn.scaleX = 0.9;
			minus10Bttn.y = 200;
			minus10Bttn.x = background.x + 65;
			
			minusBttn = new Button(setM);
			minusBttn.scaleX = 0.9;
			minusBttn.y = minus10Bttn.y;
			minusBttn.x = minus10Bttn.x + minus10Bttn.width + 3;
			
			plus10Bttn = new Button(setP10);
			plus10Bttn.scaleX = 0.9;
			plus10Bttn.y = minus10Bttn.y;
			plus10Bttn.x = background.width - 95;
			
			plusBttn = new Button(setP);
			plusBttn.scaleX = 0.9;
			plusBttn.y = minus10Bttn.y;
			plusBttn.x = plus10Bttn.x - plusBttn.width - 3;				
			
			bodyContainer.addChild(plusBttn);
			bodyContainer.addChild(minusBttn);
			bodyContainer.addChild(plus10Bttn);
			bodyContainer.addChild(minus10Bttn);
			
			minusBttn.state = Button.DISABLED;
			minus10Bttn.state = Button.DISABLED;
			
			plusBttn.addEventListener(MouseEvent.CLICK, onPlusEvent);
			minusBttn.addEventListener(MouseEvent.CLICK, onMinusEvent);
			plus10Bttn.addEventListener(MouseEvent.CLICK, onPlus10Event);
			minus10Bttn.addEventListener(MouseEvent.CLICK, onMinus10Event);
		}
		
		public function drawBttns():void {
			//Кнопка "flash:1382952380277"
			var pbSttngs:Object = {
				caption:Locale.__e('flash:1382952379775'),
				fontSize:26,
				width:140,
				height:45
			}
			priceBttn = new Button(pbSttngs);			
			bodyContainer.addChild(priceBttn);
			priceBttn.x = (settings.width - priceBttn.width) / 2 ;
			priceBttn.y = settings.height - priceBttn.height - 10;
			priceBttn.addEventListener(MouseEvent.CLICK, onSend);
		}
		
		public function onSend(e:MouseEvent):void {
			if (settings.hasOwnProperty('max') && settings['max'] == 0) {
				Hints.text(Locale.__e('flash:1396250443959'), 6, new Point(this.mouseX, this.mouseY), false, this);
			}else{
				settings.callback(settings.type, settings.sID, int(countCalc.text));
				close();
			}
		}
		
		private function onSellEvent(e:MouseEvent):void {
			
			if (e.currentTarget.mode == Button.DISABLED) return;
			
			priceBttn.state = Button.DISABLED;
			var X:int = this.x + e.currentTarget.x + e.currentTarget.width - 20;
			var Y:int = this.y + e.currentTarget.y - e.currentTarget.height + 80;
			
			var count:int = int(countCalc.text);
			
			App.user.stock.sell(item.sID, count, onSellComplete);
			
			sellPrice.text = String(price);
		}
		
		private function onSellComplete():void
		{
			var _icon:Bitmap = new Bitmap(icon.bitmapData, 'auto', true);
			_icon.x = App.self.windowContainer.mouseX - priceBttn.mouseX + priceBttn.width/2;
			_icon.y = App.self.windowContainer.mouseY - priceBttn.mouseY + priceBttn.height/2;
			App.self.windowContainer.addChild(_icon);
			
			TweenLite.to(_icon, 0.8, { x:6, y:4, onComplete:function():void {
				App.self.windowContainer.removeChild(_icon);
				_icon = null;
				//window.animalEnergy.glowing();
			}});
			
			countCalc.text = "1";
			if (App.user.stock.count(item.ID) == 0){
				this.close();
				return;
			};
			countOnStock.text = String(App.user.stock.count(item.ID) - 1);
			priceBttn.state = Button.NORMAL;
		}
			
		private function onOverEvent(e:MouseEvent):void {
			if (minus10Bttn != null) {
				//	minus10Bttn.visible = true;
				//	plus10Bttn.visible = true;
			}
		}
		private function onOutEvent(e:MouseEvent):void {
			if (minus10Bttn != null) {
				//	minus10Bttn.visible = false;
				//	plus10Bttn.visible = false;
			}
		}
		
		private function onPlusEvent(e:MouseEvent):void {
			if (e.currentTarget.mode == Button.DISABLED) return;
			var currCnt:* = Math.min(settings.count, settings["max"]);
			var count:int = int(countCalc.text) + 1;
			if(count > currCnt) count = currCnt;
			
			countOnStock.text = String(settings.count - count);
			countCalc.text = String(count);
			
			if (count >= currCnt) {
				plusBttn.state = Button.DISABLED;
				plus10Bttn.state = Button.DISABLED;
			}
			if(count > 1){
				minusBttn.state = Button.NORMAL;
				minus10Bttn.state = Button.NORMAL;
			}
		}
		
		private function onMinusEvent(e:MouseEvent):void {
			
			if (e.currentTarget.mode == Button.DISABLED) return;
			
			var count:int = int(countCalc.text) - 1;
			if (count < 1) {
				count = 1;
			}
			
			var instock:int = App.user.stock.data[settings.sID];
			countOnStock.text = String(settings['count'] - count);
			
			countCalc.text = String(count);	
			sellPrice.text = String(count * price);
			if (count < 2) {
				minusBttn.state = Button.DISABLED;
				minus10Bttn.state = Button.DISABLED;
			}
			if (count < settings['count']) {
				plusBttn.state = Button.NORMAL;
				plus10Bttn.state = Button.NORMAL;
			}
		}
		
		private function onPlus10Event(e:MouseEvent):void {
			
			if (e.currentTarget.mode == Button.DISABLED) return;
			
			var currCnt:* = Math.min(settings.count , settings["max"]);
			var count:int = int(countCalc.text);
			count += 10;
			
			if (count > currCnt) {
				count = currCnt;
			}
			
			countOnStock.text = String(settings.count - count);
			countCalc.text = String(count);
			
			if (count >= settings.count || count >= settings["max"]) {
				plusBttn.state = Button.DISABLED;
				plus10Bttn.state = Button.DISABLED;
			}
			if(count > 1){
				minusBttn.state = Button.NORMAL;
				minus10Bttn.state = Button.NORMAL;
			}
		}
		
		private function onMinus10Event(e:MouseEvent):void {
			
			if (e.currentTarget.mode == Button.DISABLED) return;
			
			var count:int = int(countCalc.text) - 10;
			if (count < 1) {
				count = 1;
			}
			
			var instock:int = App.user.stock.data[settings.sID];
			countOnStock.text = String(settings['count'] - count);
			
			countCalc.text = String(count);	
			sellPrice.text = String(count * price);
			
			if (count < 2) {
				minusBttn.state = Button.DISABLED;
				minus10Bttn.state = Button.DISABLED;
			}
			if (count < settings.count && count < settings.max) {
				plusBttn.state = Button.NORMAL;
				plus10Bttn.state = Button.NORMAL;
			}
		}
		
		public function bttnsShowCheck(e:*=null):void
		{
			if (minus10Bttn != null) 
			{
				if (this.mouseY < 180 && this.mouseY > 145 && this.mouseX > 0 && this.mouseX < 180)
				{
					minus10Bttn.visible = true;
					plus10Bttn.visible = true;
				}
				else
				{
					minus10Bttn.visible = false;
					plus10Bttn.visible = false;
				}
			}
		}
	}
}