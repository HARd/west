package wins 
{
	import buttons.ImageButton;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import units.Underground;
	public class UndergroundShopWindow extends Window
	{
		
		private var target:Underground;
		private var addBttn:ImageButton;
		private var currencyLabel:TextField;
		
		public function UndergroundShopWindow(settings:Object) 
		{
			if (!settings) settings = { };
			
			settings['width'] = 700;
			settings['height'] = 560;
			settings['title'] = Locale.__e('flash:1382952379765');
			settings['hasPaginator'] = true;
			settings['hasButtons'] = false;
			settings['itemsOnPage'] = 3;
			settings['content'] = [];
			
			target = settings.target;
			
			for each (var cr:* in target.info.crafting) {
				settings.content.push(cr);
			}
			
			super(settings);
			
			App.self.addEventListener(AppEvent.ON_CHANGE_STOCK, onStockChange);
		}
		
		override public function titleText(settings:Object):Sprite
		{
			var titleCont:Sprite = new Sprite();
			var mirrorDec:String = 'goldTitleDec2';
			var indent:int = -10;
			
			var textLabel:TextField = Window.drawText(settings.title, settings);
			if (this.settings.hasTitle == true && this.settings.titleDecorate == true) {
				drawMirrowObjs(mirrorDec, textLabel.x + (textLabel.width - textLabel.textWidth) / 2 - 75, textLabel.x + (textLabel.width - textLabel.textWidth) / 2 + textLabel.textWidth + 75, textLabel.y + (textLabel.height - 40) / 2 + indent, false, false, false, 1, 1, titleCont);
			}
			
			titleCont.mouseChildren = false;
			titleCont.mouseEnabled = false;
			titleCont.addChild(textLabel);
			
			return titleCont;
		}
		
		override public function drawBackground():void {
			background = backing2(settings.width, settings.height, 100, 'topBacking', 'bottomBacking3');
			layer.addChild(background);
		}
		
		override public function drawBody():void {
			var shine:Bitmap = new Bitmap(Window.texture('iconGlow'));
			shine.y -= 60;
			shine.scaleY = 0.8;
			bodyContainer.addChild(shine);
			
			var text:TextField = drawText(Locale.__e('flash:1425978184363'), {
				color:      	0xffffff,
				borderColor: 	0x854a3c,
				fontSize:		24
			});
			text.x = shine.x + (shine.width - text.textWidth) / 2;
			text.y -= 40;
			bodyContainer.addChild(text);
			
			var frank:Bitmap = new Bitmap(Window.texture('caveIdol'));
			frank.y = -15;
			frank.x += 15;
			bodyContainer.addChild(frank);
			
			currencyLabel = drawText(String(App.user.stock.count(target.money)), {
				color:      	0xffeb96,
				borderColor: 	0x414311,
				fontSize:		32
			});
			currencyLabel.x = shine.x + (shine.width - currencyLabel.textWidth) / 2 + 5;
			currencyLabel.y = -10;
			bodyContainer.addChild(currencyLabel);
			
			addBttn = new ImageButton(Window.texture('interAddBttnGreen'));
			addBttn.x = currencyLabel.x + currencyLabel.textWidth + 15;
			addBttn.y = currencyLabel.y;
			//bodyContainer.addChild(addBttn);
			
			addBttn.addEventListener(MouseEvent.CLICK, onAddCurrency);
			
			contentChange();
		}
		
		public function onAddCurrency(e:MouseEvent = null):void {
			var content:Array = PurchaseWindow.createContent('Energy', { view:App.data.storage[target.money].view } );
			if (content.length == 0) return;
			new PurchaseWindow( {
				width:595,
				itemsOnPage:content.length,
				content:content,
				title:Locale.__e("flash:1382969956057"),
				fontBorderColor:0xd49848,
				shadowColor:0x553c2f,
				shadowSize:4,
				description:Locale.__e("flash:1382952379757"),
				popup: true,
				closeAfterBuy: false,
				callback:function(sID:int):void {
					var object:* = App.data.storage[sID];
					App.user.stock.add(sID, object);
				}
			}).show();
			return;
		}
		
		private var items:Array;
		private var itemsContainer:Sprite = new Sprite();
		override public function contentChange():void {
			if (items) {
				for each(var _item:* in items) {
					itemsContainer.removeChild(_item);
					_item.dispose();
				}
			}
			items = [];
			
			bodyContainer.addChild(itemsContainer);
			itemsContainer.x = 75;
			itemsContainer.y = 50;
			
			var Xs:int = 0;
			for (var i:int = paginator.startCount; i < paginator.finishCount; i++)
			{
				var item:DecorItem = new DecorItem(this, { sID:settings.content[i] } );
				item.x = Xs;
				items.push(item);
				itemsContainer.addChild(item);
				
				Xs += item.bg.width + 20;
			}
		}
		
		public function onStockChange(e:AppEvent):void {
			if (!items) return;
			
			for each(var _item:* in items) {
				_item.stockChange();
			}
			
			currencyLabel.text = String(App.user.stock.count(target.money));
		}
		
		override public function dispose():void {
			if (items) {
				for each(var _item:* in items) {
					itemsContainer.removeChild(_item);
					_item.dispose();
				}
			}
			
			addBttn.removeEventListener(MouseEvent.CLICK, onAddCurrency);
			App.self.removeEventListener(AppEvent.ON_CHANGE_STOCK, onStockChange);
			UndergroundWindow.find = null;
			super.dispose();
		}
		
	}

}
import buttons.Button;
import core.Load;
import core.Size;
import flash.display.Bitmap;
import flash.display.SpreadMethod;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.text.TextField;
import ui.Hints;
import wins.Window;
import wins.ProgressBar;
import wins.SimpleWindow;
import wins.UndergroundWindow;

internal class DecorItem extends LayerX {
	
	public var bg:Bitmap;
	public var icon:Bitmap;
	public var window:*;
	public var sID:int;
	public var info:Object;
	public var countPrice:int;
	public var sidPrice:*;
	public var takeBttn:Button;
	private var preloader:Preloader = new Preloader();
	private var progressBar:ProgressBar;
	private var progressBacking:Bitmap;
	private var progressTitle:TextField;
	private var iconSprite:LayerX = new LayerX();
	
	public function DecorItem(window:*, data:Object):void {
		this.window = window;
		this.sID = data.sID;
		
		info = App.data.storage[sID];
		
		bg = Window.backing(170, 210, 10, 'itemBacking');
		addChild(bg);
		
		addChild(iconSprite);
		
		drawTitle();
		drawPrice();
		drawLimit();
		
		preloader.x = (bg.width - preloader.width) / 2;
		preloader.y = (bg.height - preloader.height) / 2;
		addChild(preloader);
		
		Load.loading(Config.getIcon(App.data.storage[sID].type, App.data.storage[sID].preview), onLoad);
		
		drawFragment();
	}
	
	public function onLoad(data:*):void {
		
		if (preloader) {
			removeChild(preloader);
		}
		
		icon = new Bitmap(data.bitmapData);
		icon.x = (bg.width - icon.width) / 2.
		icon.y = (bg.height - icon.height) / 2;
		iconSprite.addChild(icon);
		
		iconSprite.tip = function():Object {
			return {
				title:App.data.storage[sID].title,
				text:App.data.storage[sID].description
			}
		}
		
		if (UndergroundWindow.find == sID) {
			iconSprite.startGlowing();
		}else if ((UndergroundWindow.find is Array) && UndergroundWindow.find.indexOf(sID) != -1) {
			iconSprite.startGlowing();		}
	}
	
	public function drawTitle():void {
		var title:TextField = Window.drawText(App.data.storage[sID].title, {
			width:bg.width - 20,
			fontSize:24,
			color:0x703611,
			borderColor:0xffffff,
			multiline:true,
			wrap:true,
			textAlign:'center'
		});
		title.x = 10;
		title.y = 7;
		addChild(title);
	}
	
	public function drawLimit():void {
		var title:TextField = Window.drawText(Storage.shopLimit(sID) + "/"+ info.gcount, {
			fontSize:		26,
			color:			0xffffff,
			borderColor:	0x2D2D2D,
			autoSize:		'center'
		});
		title.x = 120;
		title.y = 120;
		addChild(title);
	}
	
	public var priceSprite:Sprite = new Sprite();
	public function drawPrice():void {
		addChild(priceSprite);
		
		var price:Object = info.price;
		for (sidPrice in price) {
			countPrice = price[sidPrice];
		}
		
		progressBacking = Window.backingShort(bg.width - 45, "progBarBacking");
		progressBacking.x = (bg.width - progressBacking.width) / 2 + 17;
		progressBacking.y = bg.height - progressBacking.height - 7;
		priceSprite.addChild(progressBacking);
		
		progressBar = new ProgressBar({win:window, width:bg.width - 45 + 16, isTimer:false});
		progressBar.x = progressBacking.x - 8;
		progressBar.y = progressBacking.y - 4;
		priceSprite.addChild(progressBar);
		progressBar.progress = App.user.stock.count(sidPrice) / countPrice;
		progressBar.start();
		
		progressTitle = Window.drawText(progressData, {
			fontSize:24,
			autoSize:"left",
			textAlign:"center",
			color:0xffffff,
			borderColor:0x6b340c,
			shadowColor:0x6b340c,
			shadowSize:1
		});
		progressTitle.x = progressBacking.x + progressBacking.width / 2 - progressTitle.width / 2;
		progressTitle.y = progressBacking.y + 2;
		progressTitle.width = 80;
		priceSprite.addChild(progressTitle);
		
		var progressIco:Bitmap = new Bitmap();
		priceSprite.addChild(progressIco);
		
		Load.loading(Config.getIcon(App.data.storage[sidPrice].type, App.data.storage[sidPrice].preview), function(data:*):void {
			progressIco.bitmapData = data.bitmapData;
			Size.size(progressIco, 30, 30);
			progressIco.smoothing = true;
			progressIco.x = 7;
			progressIco.y = progressBacking.y;
		});
		
		takeBttn = new Button( {
			caption:Locale.__e('flash:1382952379737'),
			width:140,
			height:40
		});
		takeBttn.x = (bg.width - takeBttn.width) / 2;
		takeBttn.y = bg.height - takeBttn.height - 7;
		takeBttn.addEventListener(MouseEvent.CLICK, onTake);
		addChild(takeBttn);
		
		//if (info.hasOwnProperty('gcount')) {
			//var maxCount:int = info.gcount;
			//var instCount:int = Storage.shopLimit(sID) || 0;
			
			if (info.gcount > 0 && Storage.shopLimit(sID) >= info.gcount) {
				takeBttn.state = Button.DISABLED;
			}
		//}
		
		stockChange();
	}
	
	private function onTake(e:MouseEvent):void {
		if (takeBttn.mode == Button.DISABLED) return;
		takeBttn.state = Button.DISABLED;
		
		if (!App.user.stock.checkAll(App.data.storage[sID].price)) return;
		
		App.user.stock.buy(sID, 1, onTakeAction);
		flyMaterial(sID);
	}
	
	private function onTakeAction(price:Object = null):void {
		for (var sid:* in price) break;
		if (App.data.storage[sid])
			Hints.minus(sid, price[sid], new Point(App.self.mouseX, App.self.mouseY));
		
		if (Storage.isShopLimited(sID) && ['Floors','Walkgolden','Booker','Golden'].indexOf(App.data.storage[sID].type) != -1) {
			Storage.shopLimitBuy(sID);
			App.user.updateActions();
			App.ui.salesPanel.updateSales();
			App.user.storageStore('shopLimit', Storage.shopLimitList, true);
		}
		
		priceBttn.state = Button.DISABLED;
	}
	
	public function flyMaterial(_sid:int):void
	{
		var item:BonusItem = new BonusItem(uint(_sid), 0);
		
		var point:Point = Window.localToGlobal(icon);
		point.y += icon.height / 2;
		
		item.cashMove(point, App.self.windowContainer);
	}
	
	public function get progressData():String {
		return String(App.user.stock.count(sidPrice)) + ' / ' + String(countPrice);
	}
	
	public function stockChange():void {
		progressTitle.text = progressData;
		progressBar.progress = App.user.stock.count(sidPrice) / countPrice;
		
		if (App.user.stock.count(sidPrice) >= countPrice) {
			priceSprite.visible = false;
			takeBttn.visible = true;
		} else {
			priceSprite.visible = true;
			takeBttn.visible = false;
		}
	}
	
	private var priceBttn:Button;
	private var priceIcon:Bitmap;
	private var fragmentSprite:LayerX = new LayerX();
	public function drawFragment():void {
		addChild(fragmentSprite);
		
		var back:Bitmap = Window.backing(170, 170, 10, 'itemBacking');
		back.y = bg.height + 20;
		fragmentSprite.addChild(back);
		
		var title:TextField = Window.drawText(App.data.storage[sidPrice].title, {
			width:back.width - 10,
			fontSize:22,
			color:0x703611,
			borderColor:0xffffff,
			multiline:true,
			wrap:true,
			textAlign:'center'
		});
		title.x = 5;
		title.y = back.y + 10;
		fragmentSprite.addChild(title);
		
		priceBttn = new Button( {
			caption:Locale.__e('flash:1382952379751'),
			width:140,
			height:40
		});
		priceBttn.x = (back.width - priceBttn.width) / 2;
		priceBttn.y = back.y + back.height - priceBttn.height / 2;
		priceBttn.addEventListener(MouseEvent.CLICK, onBuy);
		fragmentSprite.addChild(priceBttn);
		
		Load.loading(Config.getIcon(App.data.storage[sidPrice].type, App.data.storage[sidPrice].preview), function(data:*):void {
			priceIcon = new Bitmap(data.bitmapData);
			Size.size(priceIcon, 70, 70);
			priceIcon.smoothing = true;
			priceIcon.x = (back.width - priceIcon.width) / 2;
			priceIcon.y = back.y + (back.height - priceIcon.height) / 2 - 10;
			fragmentSprite.addChild(priceIcon);
		});
		
		fragmentSprite.tip = function():Object {
			return {
				title:App.data.storage[sidPrice].title,
				text:App.data.storage[sidPrice].description
			}
		}
		
		drawFragmentPrice();
		
		//if (info.hasOwnProperty('gcount')) {
			//var maxCount:int = App.data.storage[sID].gcount;
			//var instCount:int = Storage.shopLimit(sID) || 0;
			
			if (info.gcount > 0 && Storage.shopLimit(sID) >= info.gcount) {
				priceBttn.state = Button.DISABLED;
			}
		//}
	}
	
	private var fPriceSprite:Sprite = new Sprite();
	private var priceSID:*;
	private var priceCount:int;
	private function drawFragmentPrice():void {
		addChild(fPriceSprite);
		
		var icon:Bitmap = new Bitmap();
		fPriceSprite.addChild(icon);
		
		var price:Object = App.data.storage[sidPrice].price;
		for (priceSID in price) {
			priceCount = price[priceSID];
		}
		
		var pTitle:TextField = Window.drawText(String(priceCount), {
			color:0xffffff,
			borderColor:0x804b2c,
			fontSize:26
		});
		fPriceSprite.addChild(pTitle);
		
		if (App.data.storage[priceSID]) {
			Load.loading(Config.getIcon(App.data.storage[priceSID].type, App.data.storage[priceSID].preview), function(data:*):void {
				icon.bitmapData = data.bitmapData;
				Size.size(icon, 30, 30);
				icon.x = pTitle.textWidth + 7;
				icon.smoothing = true;
			});
		}
		
		fPriceSprite.x = (bg.width - (30 + pTitle.textWidth + 7)) / 2;
		fPriceSprite.y = priceBttn.y - 35;
	}
	
	private function onBuy(e:MouseEvent):void {
		if (priceBttn && priceBttn.mode == Button.DISABLED) return;
		priceBttn.state = Button.DISABLED;
		
		if (!App.user.stock.checkAll(App.data.storage[sidPrice].price)) {
			new SimpleWindow( {
				popup:true,
				text:Locale.__e('flash:1472638724975'),
				title:Locale.__e('flash:1382952379893')
			}).show();
			return;
		}
		
		
		Hints.minus(priceSID, priceCount, localToGlobal(new Point(priceBttn.x + priceBttn.width * 0.5, priceBttn.y + 30)));
		priceBttn.state = Button.DISABLED;
		
		App.user.stock.buy(sidPrice, 1, onBuyAction);
	}
	
	private function onBuyAction(price:Object):void {
		Hints.plus(sidPrice, 1, localToGlobal(new Point(priceBttn.x + priceBttn.width * 0.5, priceBttn.y)));
		
		priceBttn.state = Button.NORMAL;
	}
	
	public function dispose():void {
		if (takeBttn) takeBttn.removeEventListener(MouseEvent.CLICK, onTake);
		if (priceBttn) priceBttn.removeEventListener(MouseEvent.CLICK, onBuy);
	}
}