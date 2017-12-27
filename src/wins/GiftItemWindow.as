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
	import ui.UserInterface;
	
	public class GiftItemWindow extends Window
	{
		
		public var item:Object;
		
		public var bitmap:Bitmap;
		public var title:TextField;
		public var priceBttn:Button;
		public var placeBttn:Button;
		public var applyBttn:Button;
		public var wishBttn:ImageButton;
		public var giftBttn:ImageButton;
		public var sellPrice:TextField;
		public var price:int;
		
		public var plusBttn:ImageButton;
		public var minusBttn:ImageButton;
		
		public var plus10Bttn:Button;
		public var minus10Bttn:Button;
		
		public var countCalc:TextField;
		public var countOnStock:TextField;
		
		public function GiftItemWindow(settings:Object = null):void
		{
			if (settings == null) {
				settings = new Object();
			}
			
			settings['sID'] = settings.sID || 0;
			
			item = App.data.storage[settings.sID];
			
			settings["title"] = Locale.__e("flash:1382952380130");
			
			settings["width"] = 298;
			settings["height"] = 282;
			settings["popup"] = true;
			settings["fontSize"] = 28;
			settings["callback"] = settings["callback"] || null;
			
			settings["hasPaginator"] = false;
			
			super(settings);
		}
		
		override public function drawBackground():void {
			var background:Bitmap = backing(settings.width, settings.height, 10, "alertBacking");
			layer.addChild(background);
		}
		
		override public function drawExit():void {
			super.drawExit();
			
			exit.scaleX = exit.scaleY = 0.8;
		}
		
		private var preloader:Preloader = new Preloader();
		override public function drawBody():void {
			
			titleLabel.y = 0;
			titleLabel.x += 40;
			
			background = Window.backing(198, 198, 10, "shopBackingSmall2");
			background.alpha = 0;
			bodyContainer.addChild(background);
			background.x = (settings.width - background.width)/2;
			background.y = (settings.height - background.height)/3;
		
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
			preloader.y = (settings.height - background.height)/3 - 20 + background.y;
			Load.loading(Config.getIcon(item.type, item.preview), onLoad);
			
			price = item.cost;
			
			if (item.type == "e") {
				priceBttn.visible = false;
			}else{
				drawCalculator();
			}
			
			drawCount();
			
			addEventListener(MouseEvent.MOUSE_OVER, onOverEvent);
			addEventListener(MouseEvent.MOUSE_OUT, onOutEvent);
		}
			
		public function onLoad(data:Bitmap):void
		{
			removeChild(preloader);
			
			bitmap.bitmapData = data.bitmapData;
			bitmap.x = (settings.width - bitmap.width)/2;
			bitmap.y = (background.height - bitmap.height) / 2 - 10 + background.y;
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
			
			priceBttn.removeEventListener(MouseEvent.CLICK, onGiftEvent);
			
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
				fontSize:24,
				multiline:true
			});
			title.wordWrap = true;
			title.width = background.width - 50;
			title.y = background.y + 10;
			title.x = 75;
			bodyContainer.addChild(title);
		}
		
		public function drawCount():void {
			
			countOnStock = Window.drawText(String(App.user.stock.data[settings.sID] - 1), {
				color:0xfffdfb,
				borderColor:0x89562b,
				fontSize:24,
				autoSize:"center"
			});
			
			var width:int = countOnStock.width + 24 > 30?countOnStock.width + 24:30;
			//var bg:Bitmap = Window.backing(width, 40, 10, "smallBacking");
			
			//bodyContainer.addChild(bg);
			//bg.x = background.width - bg.width - 2;
			//bg.y = 50;
			
			var circleSprite:Sprite = new Sprite();
			var bg:Shape = new Shape();
			bg.graphics.beginFill(0xbc8e41);
			bg.graphics.drawCircle(0, 0, 20);
			
			var bg2:Shape = new Shape();
			bg.graphics.beginFill(0xefd099);
			bg.graphics.drawCircle(0, 0, 17);
				
			circleSprite.addChild(bg);
			circleSprite.addChild(bg2);
			circleSprite.x = 48;
			circleSprite.y = -10;
			bg.x = background.width - 25;
			bg2.x = background.width - 25;
			bg.y = background.y + 40;
			bg2.y = background.y + 40;
			
			circleSprite.addChild(countOnStock);
			bodyContainer.addChild(circleSprite);
			//bodyContainer.addChild(countOnStock);
			countOnStock.x = bg.x - countOnStock.textWidth/2 - 2;
			countOnStock.y = bg.y - countOnStock.textHeight/2;
			
			if (countOnStock.text == "0") {
				plusBttn.state = Button.DISABLED;
				plus10Bttn.state = Button.DISABLED;
			}
		}
		
		public function drawSellPrice():void {
			
			var icon:Bitmap;
			var settings:Object = {  };
			
			icon = new Bitmap(UserInterface.textures.coinsIcon, "auto", true);
			icon.scaleX = icon.scaleY = 0.7;
			
			icon.x = 90;
			icon.y = 208;

			bodyContainer.addChild(icon);
					
			sellPrice = Window.drawText(String(price), {
				fontSize:20, 
				autoSize:"left",
				color:0xffdc39,
				borderColor:0x6d4b15
			});
			bodyContainer.addChild(sellPrice);
			sellPrice.x = 116;
			sellPrice.y = 209;
			
			var open:TextField = Window.drawText(Locale.__e("flash:1382952380131"), {
				color:0x4A401F,
				borderSize:0,
				fontSize:22,
				autoSize:"left"
			});
			bodyContainer.addChild(open);
			open.x = 34;
			open.y = 206;
			
		}
		
		public function drawCalculator():void {
			
			//var countBg:Bitmap = Window.backing(50, 40, 10, "smallBacking");
			//countBg.x = background.x + (background.width - countBg.width) / 2;
			//countBg.y = 150;
			//bodyContainer.addChild(countBg);
			
			var countBg:Shape = new Shape();
			countBg.graphics.beginFill(0xc29f5f);
			countBg.graphics.drawCircle(18, 18, 18);
			countBg.x = background.x + (background.width - countBg.width) / 2;
			countBg.y = 170;
			bodyContainer.addChild(countBg);
			
			countCalc = Window.drawText("1", {
				color:0xfeffff,
				borderColor:0x572c26,
				fontSize:24,
				textAlign:"center"
			});
			
			bodyContainer.addChild(countCalc);
			countCalc.width = countBg.width;
			countCalc.height = countCalc.textHeight;
			countCalc.x = countBg.x + (countBg.width - countCalc.width) / 2;
			countCalc.y = countBg.y + (countBg.height - countCalc.height) / 2;
			
			
			
			var settings:Object = {
				caption		:"+",
				bgColor		:[0xD2C7AB,0xD2C7AB],
				width		:26,
				height		:26,	
				borderColor	:[0x474337,0x474337],
				fontSize	:18,
				fontColor	:0xcec080,
				fontBorderColor:0x6d4b15,
				shadow		:true,
				radius		:10
			};
			
			
			plusBttn = new ImageButton(Window.texture('itemWindow'));
			
			plusBttn.y = countBg.y + (countBg.height - plusBttn.height) / 2;
			plusBttn.x = countBg.x + countBg.width + 3;
			
			minusBttn = new ImageButton(Window.texture('itemWindow'));
			
			minusBttn.y = countBg.y + (countBg.height - minusBttn.height) / 2;
			minusBttn.x = countBg.x - minusBttn.width - 3;
			
			
			bodyContainer.addChild(plusBttn);
			bodyContainer.addChild(minusBttn);
			
			// Plus10  Minus10
			settings["caption"] = "+10";
			settings["fontSize"] = 16;
			plus10Bttn = new Button(settings);
			
			plus10Bttn.y = 138;
			plus10Bttn.x = countBg.x + countBg.width + plus10Bttn.width + 14;
			plus10Bttn.textLabel.x -= 3;
			plus10Bttn.textLabel.width += 8;
				
			settings["caption"] = "-10";
			minus10Bttn = new Button(settings);
			
			minus10Bttn.y = 138;
			minus10Bttn.x = countBg.x - (minus10Bttn.width)*2 - 18;
			
			bodyContainer.addChild(plus10Bttn);
			bodyContainer.addChild(minus10Bttn);
			
			plus10Bttn.visible = false;
			minus10Bttn.visible = false;
			
			minusBttn.state = Button.DISABLED;
			minus10Bttn.state = Button.DISABLED;
			
			plusBttn.addEventListener(MouseEvent.CLICK, onPlusEvent);
			minusBttn.addEventListener(MouseEvent.CLICK, onMinusEvent);
			plus10Bttn.addEventListener(MouseEvent.CLICK, onPlus10Event);
			minus10Bttn.addEventListener(MouseEvent.CLICK, onMinus10Event);
		}
		
		public function drawBttns():void {
			
			//Кнопка "flash:1382952380277"
			priceBttn = new Button( {
				caption:Locale.__e("flash:1382952380118"),
				fontSize:30,
				width:150,
				height:45
			});
			
			bodyContainer.addChild(priceBttn);
			priceBttn.x = (settings.width - priceBttn.width) / 2;
			priceBttn.y = settings.height - priceBttn.height - 23;
			priceBttn.addEventListener(MouseEvent.CLICK, onGiftEvent);
		}
		
		private function onGiftEvent(e:MouseEvent):void {
			
			if (e.currentTarget.mode == Button.DISABLED) return;
			
			priceBttn.state = Button.DISABLED;
			var X:int = this.x + e.currentTarget.x + e.currentTarget.width - 20;
			var Y:int = this.y + e.currentTarget.y - e.currentTarget.height + 80;
			
			var count:int = int(countCalc.text);
			
			Gifts.send(settings.sID, settings.fID, count, Gifts.NORMAL, onGiftComplete);
		}
		
		private function onGiftComplete():void
		{
			if (settings.callback) settings.callback();
			this.close();
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
			
			var count:int = int(countCalc.text) + 1;
			if (count > item.count) {
				count = item.count;
			}
			
			countOnStock.text = int(countOnStock.text) > 0?String(int(countOnStock.text) - 1):"0";
			var instock:int = App.user.stock.data[settings.sID];
			
			countCalc.text = String(count);
			//sellPrice.text = String(count * price);
			if (count >= instock) {
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
			countOnStock.text = int(countOnStock.text) < instock?String(int(countOnStock.text) + 1):String(instock);
			
			countCalc.text = String(count);	
			//sellPrice.text = String(count * price);
			if (count < 2) {
				minusBttn.state = Button.DISABLED;
				minus10Bttn.state = Button.DISABLED;
			}
			if (count < instock) {
				plusBttn.state = Button.NORMAL;
				plus10Bttn.state = Button.NORMAL;
			}
		}
		
		private function onPlus10Event(e:MouseEvent):void {
			var count:int = int(countCalc.text) + 10;
			if (count > item.count) {
				count = item.count;
			}
			
			countCalc.text = String(count);
			//sellPrice.text = String(count * price);
			if (count >= item.count) {
				plusBttn.state = Button.DISABLED;
				plus10Bttn.state = Button.DISABLED;
			}
			if(count > 1){
				minusBttn.state = Button.NORMAL;
				minus10Bttn.state = Button.NORMAL;
			}
		}
		
		private function onMinus10Event(e:MouseEvent):void {
			var count:int = int(countCalc.text) - 10;
			if (count < 1) {
				count = 1;
			}
			countCalc.text = String(count);
			//sellPrice.text = String(count * price);
			if (count < 2) {
				minusBttn.state = Button.DISABLED;
				minus10Bttn.state = Button.DISABLED;
			}
			if (count < item.count) {
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
