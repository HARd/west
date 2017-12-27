package wins 
{
	import buttons.Button;
	import buttons.ImageButton;
	import core.Load;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import ui.Hints;
	import units.Underground;
	public class InvaderWindow extends Window 
	{
		public var payBttn:Button;
		public var openBttn:Button;
		public function InvaderWindow(settings:Object=null) 
		{
			if (settings == null) {
				settings = new Object();
			}
			
			settings['width'] 			= 620;
			settings['height'] 			= 430;
			settings['title'] 			= settings.title || Locale.__e('flash:1472475098054');
			settings['hasPaginator'] 	= false;
			settings['hasButtons']		= false;
			settings['background']		= 'goldBacking';
			settings['popup']			= true;
			
			super(settings);
		}
		
		override public function titleText(settings:Object):Sprite
		{
			var titleCont:Sprite = new Sprite();
			var mirrorDec:String = 'goldTitleDec';
			var indent:int = 0;
			
			var textLabel:TextField = Window.drawText(settings.title, settings);
			if (this.settings.hasTitle == true && this.settings.titleDecorate == true) {
				drawMirrowObjs(mirrorDec, textLabel.x + (textLabel.width - textLabel.textWidth) / 2 - 55, textLabel.x + (textLabel.width - textLabel.textWidth) / 2 + textLabel.textWidth + 55, textLabel.y + (textLabel.height - 40) / 2 + indent, false, false, false, 1, 1, titleCont);
			}
			
			titleCont.mouseChildren = false;
			titleCont.mouseEnabled = false;
			titleCont.addChild(textLabel);
			
			return titleCont;
		}
		
		private var separator:Bitmap;
		override public function drawBody():void {
			separator = Window.backingShort(settings.width - 100, 'dividerLine', false);
			separator.x = (settings.width - separator.width) / 2;;
			separator.y = 15;
			separator.alpha = 0.5;
			bodyContainer.addChild(separator);
			
			var separator2:Bitmap = Window.backingShort(settings.width - 100, 'dividerLine', false);
			separator2.scaleY = -1;
			separator2.x = (settings.width - separator2.width) / 2;;
			separator2.y = 230;
			separator2.alpha = 0.5;
			bodyContainer.addChild(separator2);
			
			var bg:Bitmap = Window.backing(settings.width - 100, separator2.y - separator.y, 50, 'fadeOutWhite');
			bg.alpha = 0.4;
			bg.x = separator.x;
			bg.y = separator.y;
			bodyContainer.addChild(bg);
			
			drawButtons();
			drawDescription();
			drawItems();
		}
		
		public var description:TextField;
		public function drawDescription():void {
			description = drawText(Locale.__e('flash:1472541976759'),{
				color:0x7e3918,
				borderColor:0xfdf7e9,
				textAlign:"center",
				autoSize:"center",
				fontSize:26,
				multiline:true,
				wrap:true,
				width: (payBttn.x - separator.x) * 0.73
			});
			description.x = payBttn.x - separator.x - description.textWidth;
			description.y = payBttn.y;
			bodyContainer.addChild(description);
		}
		
		public var items:Array = new Array();
		public var itemsSprite:Sprite = new Sprite();
		public function drawItems():void {
			var value:int = 0;
			for(var i:* in settings.item.require){
				var item:InvaderItem = new InvaderItem(this, {
					sID:i, 
					need:settings.item.require[i],
					onClick:onClick
				});
				item.x = 220 * value;
				itemsSprite.addChild(item);
				items.push(item);
				value++;
			}
			itemsSprite.x = separator.x + (separator.width - itemsSprite.width) / 2 + 20;
			itemsSprite.y = separator.y + 30;
			bodyContainer.addChild(itemsSprite);
		}
		
		private function onClick(e:MouseEvent):void {
			trace();
		}
		
		public function drawButtons():void {
			payBttn = new Button({
				caption:Locale.__e('flash:1478185422230'),//Locale.__e('flash:1383658502987'),
				textAlign:'left',
				width:145,
				height:44
			});
			payBttn.x = settings.width - payBttn.width - 55;
			payBttn.y = 250;
			payBttn.addEventListener(MouseEvent.CLICK, onPay);
			payBttn.textLabel.x -= 15;
			bodyContainer.addChild(payBttn);
			
			openBttn = new Button( {
				caption:Locale.__e('flash:1472633317917'),
				width:145,
				height:44
			});
			openBttn.x = settings.width - openBttn.width - 55;
			openBttn.y = 300;
			openBttn.addEventListener(MouseEvent.CLICK, onOpen);
			bodyContainer.addChild(openBttn);
			
			openBttn.state = (App.user.stock.checkAll(settings.item.require, true)) ? Button.NORMAL : Button.DISABLED;
			
			var link:String = Config.getIcon(App.data.storage[settings.target.burst].type, App.data.storage[settings.target.burst].preview);
			Load.loading(link, function(data:*):void {
				var bitmap:Bitmap = new Bitmap(data.bitmapData, 'auto', true);
				bitmap.scaleX = bitmap.scaleY = 0.3;
				bitmap.x = payBttn.width * 0.7;
				bitmap.y = (payBttn.height - bitmap.height) / 2;
				payBttn.addChild(bitmap);
			});
		}
		
		private function onPay(e:MouseEvent):void {
			if (settings.onBurst != null)
				settings.onBurst();
			
			close();
		}
		
		private function onOpen(e:MouseEvent):void {
			if (openBttn.mode == Button.DISABLED) {
				Hints.text(Locale.__e('flash:1472550235656'), 9, new Point(App.self.mouseX, App.self.mouseY));
				return;
			}
			openBttn.state = Button.DISABLED;
			
			if (settings.onKill != null)
				settings.onKill();
			
			close();
		}
		
		public function checkButton():void {
			openBttn.state = (App.user.stock.checkAll(settings.item.require, true)) ? Button.NORMAL : Button.DISABLED;
		}
		
		override public function dispose():void {
			super.dispose();
			
			payBttn.removeEventListener(MouseEvent.CLICK, onPay);
			openBttn.removeEventListener(MouseEvent.CLICK, onOpen);
		}
		
	}

}

import buttons.Button;
import buttons.MoneyButton;
import com.greensock.TweenLite;
import core.Load;
import core.Numbers;
import flash.display.Bitmap;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.text.TextField;
import ui.Hints;
import ui.UserInterface;
import wins.InvaderWindow;
import wins.ShopWindow;
import wins.Window;

internal class InvaderItem extends Sprite
{
	public var item:Object;
	public var settings:Object = {};
	public var bitmap:Bitmap;
	private var icon:Bitmap;
	public var title:TextField;
	private var findBttn:Button;
	private var buyBttn:MoneyButton;
	private var window:InvaderWindow;
	
	public function InvaderItem(window:InvaderWindow, settings:Object = null):void
	{
		if (settings == null) {
			settings = new Object();
		}
		
		settings['sID'] = settings.sID || 0;
		item = App.data.storage[settings.sID];
		this.window = window;
		
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
		
		this.settings = settings;
		
		drawBody();
	}
		
	private var preloader:Preloader = new Preloader();
	
	
	private var shape:Shape;
	public function drawBody():void {
		
		shape = new Shape();
		shape.graphics.beginFill(0xc7c9b9, 1);
		shape.graphics.drawCircle(0, 0, 70);
		shape.graphics.endFill();
		addChild(shape);
		shape.x = shape.width / 2;
		shape.y = shape.height / 2;
	
		var sprite:LayerX = new LayerX();
		addChild(sprite);
	
		bitmap = new Bitmap();
		sprite.addChild(bitmap);
		sprite.addEventListener(MouseEvent.CLICK, onFind);
	
		sprite.tip = function():Object { 
			return {
				title:item.title,
				text:item.description
			};
		};
	
		drawTitleItem();
		
		addChild(preloader);
		preloader.x = shape.x - shape.width / 2 + (shape.width - preloader.width) / 2;
		preloader.y = shape.y - shape.height / 2 + (shape.height - preloader.height) / 2;
		Load.loading(Config.getIcon(item.type, item.preview), function(data:Bitmap):void 
		{
			removeChild(preloader);
			bitmap.bitmapData = data.bitmapData;
			bitmap.x = shape.x - bitmap.width / 2;
			bitmap.y = shape.y - bitmap.height / 2;
			drawCounter();
			//drawButton();
		});
		
		findBttn = new Button( {
			caption			:Locale.__e("flash:1405687705056"),
			fontSize		:18,
			radius      	:10,
			fontColor:		0xffffff,
			fontBorderColor:0x475465,
			borderColor:	[0xfff17f, 0xbf8122],
			bgColor:		[0x75c5f6,0x62b0e1],
			bevelColor:		[0xc6edfe,0x2470ac],
			width			:110,
			height			:27,
			fontSize		:15
		});
		findBttn.x = (shape.width - findBttn.width) / 2;
		findBttn.y = 123;
		findBttn.addEventListener(MouseEvent.CLICK, onFind);
		
		var priceList:Object = Storage.price(settings.sID);
		var price:int = 0;
		var s:*;
		for (s in priceList) {
			price = priceList[s];
		}
				
		buyBttn = new MoneyButton( {
			caption			:Locale.__e("flash:1382952379751"),
			radius      	:10,
			width			:110,
			height			:35,
			fontSize		:18,
			countText		:price * (settings.need - App.user.stock.count(settings.sID))
		});
		buyBttn.x = (shape.width - buyBttn.width) / 2;
		buyBttn.y = 150;
		buyBttn.addEventListener(MouseEvent.CLICK, onBuy);
		if (App.user.stock.count(settings.sID) < settings.need) {
			addChild(buyBttn);
			addChild(findBttn);
		}
	}
	
	private function onFind(e:MouseEvent):void {
		Window.closeAll();
		ShopWindow.findMaterialSource(settings.sID);
	}
	
	private var pnt:Point;
	private function onBuy(e:MouseEvent):void {
		var _x:int = App.self.tipsContainer.mouseX - buyBttn.mouseX;
		var _y:int = App.self.tipsContainer.mouseY - buyBttn.mouseY;
		
		pnt = new Point(_x, _y);
		pnt.x += buyBttn.width / 2;
		pnt.y += -20;
			
		var def:int = need - count;
		e.currentTarget.state = Button.DISABLED;
		App.user.stock.buy(settings.sID, def, onBuyEvent);
	}
	
	private function onBuyEvent(price:Object):void
	{
		for (var sid:* in price) {
			Hints.minus(sid, price[sid], pnt, false);
			break;
		}
		
		buyBttn.visible = false;
		findBttn.visible = false;
		drawCounter();
		window.checkButton();
	}
	
	private var count:int;
	private var need:int;
	private var counterLabel:TextField;
	public function drawCounter():void {
		count = App.user.stock.data[settings.sID];
		need = settings.need;
		if (counterLabel) {
			counterLabel.text = count + '/' + need;
		}else {
			counterLabel = Window.drawText(count + '/' + need, {
				fontSize:30,
				width:150,
				height:45
			});
			counterLabel.x = shape.x - shape.width / 2 + (shape.width - counterLabel.textWidth) / 2;
			counterLabel.y = shape.y + shape.height / 2 - 45;
			addChild(counterLabel);
		}
	}

	public function dispose():void {	
		findBttn.removeEventListener(MouseEvent.CLICK, onFind);
		
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
		title.width = shape.width + 20;
		title.y = shape.y - shape.height / 2 - 15;
		title.x = shape.x - shape.width / 2 + (shape.width - title.width)/2;
		addChild(title);
	}
}