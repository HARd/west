package wins
{
	import buttons.Button;
	import buttons.ImageButton;
	import com.greensock.TweenLite;
	import core.Load;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	import ui.UserInterface;
	import wins.elements.StockCounter;
	
	public class SellItemWindow extends Window
	{
		public var item:Object;
		
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
		
		public function SellItemWindow(settings:Object = null):void
		{
			if (settings == null) {
				settings = new Object();
			}
			
			settings['sID'] = settings.sID || 0;
			App.data.storage;		
			item = App.data.storage[settings.sID];

			
			settings["title"] = Locale.__e("flash:1382952380277");
			settings["titleDecorate"] = false;
			
			settings["width"] = 310;
			settings["height"] = 305;
			settings["popup"] = true;
			settings["fontSize"] = 44;
			settings["callback"] = settings["callback"] || null;
			settings["background"] = 'alertBacking'
			settings["hasPaginator"] = false;
			settings["smallExit"] = true;
			settings['shadowColor'] = 0x513f35;
			settings['shadowSize'] = 4;
			
			super(settings);
		}
			
		private var preloader:Preloader = new Preloader();
		
		
		private var shape:Shape;
		override public function drawBody():void {
			titleLabel.y = -4;
			
			shape = new Shape();
			shape.graphics.beginFill(0xc7c9b9, 1);
			shape.graphics.drawCircle(0, 0, 60);
			shape.graphics.endFill();
			bodyContainer.addChild(shape);
			shape.x = settings.width / 2;
			shape.y = settings.height / 2 - 65;
			
			//background = Window.backing(198, 198, 10, "shopBackingSmall2");
			//bodyContainer.addChild(background);
			//background.x = settings.width/2;
			//background.y = settings.height/2 -20;
		
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
			preloader.y = (background.height - preloader.height) / 2 - 35 + background.y;
			Load.loading(Config.getIcon(item.type, item.preview), function(data:Bitmap):void 
			{
				removeChild(preloader);
				bitmap.bitmapData = data.bitmapData;
				bitmap.x = shape.x - bitmap.width / 2;
				bitmap.y = shape.y - bitmap.height / 2;
			});
			
			//price = item.cost;
			if (item.cost) {
				price = Math.round(item.cost);
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
				plusBttn.removeEventListener(MouseEvent.MOUSE_DOWN, onPlusEvent);
				minusBttn.removeEventListener(MouseEvent.MOUSE_DOWN, onMinusEvent);
				plus10Bttn.removeEventListener(MouseEvent.MOUSE_DOWN, onPlus10Event);
				minus10Bttn.removeEventListener(MouseEvent.MOUSE_DOWN, onMinus10Event);
				
				plusBttn.removeEventListener(MouseEvent.MOUSE_UP, onStopEvent);
				minusBttn.removeEventListener(MouseEvent.MOUSE_UP, onStopEvent);
				plus10Bttn.removeEventListener(MouseEvent.MOUSE_UP, onStopEvent);
				minus10Bttn.removeEventListener(MouseEvent.MOUSE_UP, onStopEvent);
			}
			
			priceBttn.removeEventListener(MouseEvent.CLICK, onSellEvent);
			
			if (settings.callback != null) {
				settings.callback();
			}
		}
		
		public function drawTitleItem():void {
			
			title = Window.drawText(item.title, {
				color:0x7e3918,
				borderColor:0xfdf7e9,
				textAlign:"center",
				autoSize:"center",
				fontSize:26,
				multiline:true
			});
			title.wordWrap = true;
			title.width = background.width - 50;
			title.y = background.y + 15;
			title.x = (background.width - title.width)/2 + 5;
			bodyContainer.addChild(title);
		}
		
		private var counter:StockCounter;
		public function drawCount():void {
			counter = new StockCounter();
			counter.count = (App.user.stock.data[settings.sID] - 1);
			counter.x = 75;
			counter.y = 34;
			bodyContainer.addChild(counter);
			
			if (counter.count == 0) {
				plusBttn.state = Button.DISABLED;
				plus10Bttn.state = Button.DISABLED;
				counter.visible = false;
			}
		}
		
		public function drawSellPrice():void {
			
			var settings:Object = {  };
			
			if (!icon) icon = new Bitmap(UserInterface.textures.coinsIcon);
			drawSellSize();
			
			icon.x = 150;
			icon.y = 181;
			
			bodyContainer.addChild(icon);
			
			sellPrice = Window.drawText(String(price), {
				fontSize:22, 
				autoSize:"left",
				color:0xffdc39,
				borderColor:0x794909
			});
			bodyContainer.addChild(sellPrice);
			sellPrice.x = icon.x + icon.width + 5;
			sellPrice.y = icon.y + 3;
			
			var open:TextField = Window.drawText(Locale.__e("flash:1382952380131"), {
				color:0x643519,
				border:false,
				fontSize:24,
				autoSize:"left"
			});
			bodyContainer.addChild(open);
			open.x = icon.x - open.textWidth - 6;
			open.y = 186;
			
			if (App.isSocial('NK')) open.x -= 10;
		}
		
		private function drawSellSize():void {
			//icon.height = 30;
			icon.scaleX = icon.scaleY = 0.8;
			icon.smoothing = true;
		}
		
		public var calc:Sprite;
		public function drawCalculator():void {
			
			//return;
			calc = new Sprite();
			bodyContainer.addChild(calc);
			
			var countBg:Shape = new Shape();
			countBg.graphics.beginFill(0xd2ac7c);
			countBg.graphics.drawCircle(0, 0, 18);
			countBg.graphics.endFill();
			
			countBg.x = 0
			countBg.y = 0;
			calc.addChild(countBg);
			
			countCalc = Window.drawText("1", {
				color:0xfeffff,
				borderColor:0x572c26,
				fontSize:24,
				textAlign:"center"
			});
			
			countCalc.width = countBg.width;
			countCalc.height = countCalc.textHeight;
			calc.addChild(countCalc);
			countCalc.x = - countBg.width / 2;
			countCalc.y = - countBg.height / 2 + 5;
			
			calc.x = shape.x;
			calc.y = shape.y + shape.height / 2 + 12;
			
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
			minus10Bttn.x = background.x + 65;
			minus10Bttn.y = 147;
			bodyContainer.addChild(minus10Bttn);
			
			minusBttn = new Button(setM);
			minusBttn.x = minus10Bttn.x + minus10Bttn.width + 3;
			minusBttn.y = minus10Bttn.y;
			bodyContainer.addChild(minusBttn);
			
			plusBttn = new Button(setP);
			plusBttn.x = minusBttn.x + 70;
			plusBttn.y = minus10Bttn.y;
			bodyContainer.addChild(plusBttn);
			
			plus10Bttn = new Button(setP10);
			plus10Bttn.x = plusBttn.x + plusBttn.width + 3;
			plus10Bttn.y = minus10Bttn.y;
			bodyContainer.addChild(plus10Bttn);
			
			// Plus10  Minus10
			//settings["caption"] = "+10";
			//settings["fontSize"] = 16;
			//plus10Bttn = new Button(settings);
			
			//plus10Bttn.textLabel.x -= 3;
			//plus10Bttn.textLabel.width += 8;
				
			//settings["caption"] = "-10";
			//minus10Bttn = new Button(settings);
			
			//plus10Bttn.visible = false;
			//minus10Bttn.visible = false;
			
			minusBttn.state = Button.DISABLED;
			minus10Bttn.state = Button.DISABLED;
			
			plusBttn.addEventListener(MouseEvent.MOUSE_DOWN, onPlusEvent);
			minusBttn.addEventListener(MouseEvent.MOUSE_DOWN, onMinusEvent);
			plus10Bttn.addEventListener(MouseEvent.MOUSE_DOWN, onPlus10Event);
			minus10Bttn.addEventListener(MouseEvent.MOUSE_DOWN, onMinus10Event);
			
			plusBttn.addEventListener(MouseEvent.MOUSE_UP, onStopEvent);
			minusBttn.addEventListener(MouseEvent.MOUSE_UP, onStopEvent);
			plus10Bttn.addEventListener(MouseEvent.MOUSE_UP, onStopEvent);
			minus10Bttn.addEventListener(MouseEvent.MOUSE_UP, onStopEvent);
		}
		
		public function drawBttns():void {
			
			//Кнопка "flash:1382952380277"
			priceBttn = new Button( {
				caption:Locale.__e("flash:1382952380277"),
				fontSize:30,
				width:150,
				height:45
			});
			bodyContainer.addChild(priceBttn);
			priceBttn.x = (settings.width - priceBttn.width) / 2;
			priceBttn.y = settings.height - priceBttn.height - 40;
			priceBttn.addEventListener(MouseEvent.CLICK, onSellEvent);
		}
		
		private function onSellEvent(e:MouseEvent):void {
			
			if (e.currentTarget.mode == Button.DISABLED) return;
			
			priceBttn.state = Button.DISABLED;
			var X:int = this.x + e.currentTarget.x + e.currentTarget.width - 20;
			var Y:int = this.y + e.currentTarget.y - e.currentTarget.height + 80;
			
			var count:int = int(countCalc.text);
			
			App.user.stock.sell(item.sid, count, onSellComplete);
			
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
			if (App.user.stock.count(item.sid) == 0){
				this.close();
				return;
			};
			//counter.count = int(App.user.stock.count(item.sid) - 1);
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
		
		private var timeout:int = 0;
		private var timeoutIncrement:int = 0;
		private var timeoutDelay:int = 0;
		private const TIME_MAX:int = 1000;
		private const TIME_MIN:int = 20;
		
		private function startCircleIncrement(increment:int = 0):void {
			if (timeout > 0) stopCircleIncrement();
			timeoutIncrement = increment;
			timeoutDelay = TIME_MAX;
			startTimeout();
		}
		private function stopCircleIncrement():void {
			if (timeout) clearTimeout(timeout);
		}
		private function startTimeout():void {
			
			timeoutDelay = timeoutDelay / 2;
			if (timeoutDelay < TIME_MIN) timeoutDelay = TIME_MIN;
			
			var count:int = int(countCalc.text) + timeoutIncrement;
			
			plusBttn.state = Button.NORMAL;
			plus10Bttn.state = Button.NORMAL;
			minusBttn.state = Button.NORMAL;
			minus10Bttn.state = Button.NORMAL;
			
			if (count >= App.user.stock.data[settings.sID]) {
				if (count > App.user.stock.data[settings.sID]) {
					count = App.user.stock.data[settings.sID];
					timeoutIncrement = 0;
				}
				
				plusBttn.state = Button.DISABLED;
				plus10Bttn.state = Button.DISABLED;
			}else if (count <= 1) {
				if (count < 1) {
					count = 1;
					timeoutIncrement = 0;
				}
				
				minusBttn.state = Button.DISABLED;
				minus10Bttn.state = Button.DISABLED;
			}
			
			countCalc.text = String(count);
			sellPrice.text = String(count * price);
			var instock:int = App.user.stock.data[settings.sID];
			counter.count = counter.count < instock?int(counter.count - timeoutIncrement):instock;
			//if (countOnStock) countOnStock.text = String(App.user.stock.data[settings.sID] - count);
			checkOnEmpty();
			
			
			if ([-10,-1,1,10].indexOf(timeoutIncrement) >= 0) {
				timeout = setTimeout(startTimeout, timeoutDelay);
			}
		}
		
		private function onStopEvent(e:MouseEvent):void {
			stopCircleIncrement();
		}
		
		private function onPlusEvent(e:MouseEvent):void {
			
			if (e.currentTarget.mode == Button.DISABLED) return;
			startCircleIncrement(1);
			
			//var count:int = int(countCalc.text) + 1;
			//if (count > item.count) {
				//count = item.count;
			//}
			//
			//counter.count = counter.count > 0?(counter.count - 1):0;
			//var instock:int = App.user.stock.data[settings.sID];
			//
			//countCalc.text = String(count);
			//sellPrice.text = String(count * price);
			//if (count >= instock) {
				//plusBttn.state = Button.DISABLED;
				//plus10Bttn.state = Button.DISABLED;
			//}
			//if(count > 1){
				//minusBttn.state = Button.NORMAL;
				//minus10Bttn.state = Button.NORMAL;
			//}
			//
			//checkOnEmpty();
		}
		
		private function onMinusEvent(e:MouseEvent):void {
			
			if (e.currentTarget.mode == Button.DISABLED) return;
			startCircleIncrement( -1);
			
			//var count:int = int(countCalc.text) - 1;
			//if (count < 1) {
				//count = 1;
			//}
			//
			//var instock:int = App.user.stock.data[settings.sID];
			//counter.count = counter.count < instock?int(counter.count + 1):instock;
			//
			//countCalc.text = String(count);	
			//sellPrice.text = String(count * price);
			//if (count < 2) {
				//minusBttn.state = Button.DISABLED;
				//minus10Bttn.state = Button.DISABLED;
			//}
			//if (count < instock) {
				//plusBttn.state = Button.NORMAL;
				//plus10Bttn.state = Button.NORMAL;
			//}
			//
			//checkOnEmpty();
		}
		
		private function onPlus10Event(e:MouseEvent):void 
		{
			if (e.currentTarget.mode == Button.DISABLED) return;
			startCircleIncrement(10);
			
			//var count:int = int(countCalc.text);
			//
			//var instock:int = App.user.stock.data[settings.sID] - count;
			//var toCounter:int = 0;
			//if (instock - 10 >= 0)
				//toCounter = 10;
			//else
				//toCounter = instock;
				//
			//instock -= toCounter;
			//
			//counter.count = instock;
			//
			//count += toCounter;
			//
			//countCalc.text = String(count);
			//sellPrice.text = String(count * price);
			//
			//if (count >= App.user.stock.data[settings.sID]) {
				//plusBttn.state = Button.DISABLED;
				//plus10Bttn.state = Button.DISABLED;
			//}
			//if(count > 1){
				//minusBttn.state = Button.NORMAL;
				//minus10Bttn.state = Button.NORMAL;
			//}
			//
			//checkOnEmpty();
		}
		
		private function onMinus10Event(e:MouseEvent):void {
			
			if (e.currentTarget.mode == Button.DISABLED) return;
			startCircleIncrement( -10);
			
			//var count:int = int(countCalc.text) - 10;
			//if (count < 1) {
				//count = 1;
			//}
			//
			//var instock:int = App.user.stock.data[settings.sID];
			//counter.count = int(counter.count + 10) < instock ? int(counter.count) + 10 : instock-1;
			//
			//countCalc.text = String(count);	
			//sellPrice.text = String(count * price);
			//
			//if (count < 2) {
				//minusBttn.state = Button.DISABLED;
				//minus10Bttn.state = Button.DISABLED;
			//}
			//if (count < App.user.stock.data[settings.sID]) {
				//plusBttn.state = Button.NORMAL;
				//plus10Bttn.state = Button.NORMAL;
			//}
			//
			//checkOnEmpty();
		}
		
		public function checkOnEmpty():void {
			if (counter.count == 0)
				counter.visible = false;
			else
				counter.visible = true;
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