package wins 
{
	import adobe.utils.ProductManager;
	import buttons.Button;
	import buttons.MoneyButton;
	import core.Load;
	import core.Numbers;
	import core.Size;
	import core.TimeConverter;
	import flash.display.DisplayObject;
	import flash.display.GradientType;
	import flash.display.Shape;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import ui.Hints;
	import units.Building;
	import wins.elements.ProductionItem;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;

	public class StationProductionWindow extends Window
	{
		
		public var find:*;
		
		public static var container:Sprite;
		private var infoContainer:Sprite;
		private var itemContainer:Sprite;
		private var craftContainer:Sprite;
		private var productionEmptyLabel:TextField;
		
		private var craftBacking:Shape;
		private var craftIcon:Bitmap;
		private var craftLabel:TextField;
		private var infoLabel:TextField;
		private var craftProgressBar:ProgressBar;
		private var progressBarBacking:Bitmap;
		private var craftBoostBttn:MoneyButton;
		private var craftStorageBttn:Button;
		
		private var items:Vector.<StationItems> = new Vector.<StationItems>;
		public var crafts:Array = [];
		public var slotTime:Array = [];
		public var target:*;
		private var timerText:TextField;
		
		private var history:int = 0;
		
		public function StationProductionWindow(settings:Object = null) 
		{
			target = settings['target'];
			
			settings['title'] = (target && target.hasOwnProperty('info')) ? target.info.title : Locale.__e('flash:1382952380292');
			settings['width'] = settings.width || 680;
			settings['height'] = settings.height || 600;
			settings['hasPaginator'] = false;
			settings['itemsOnPage'] = 2;
			settings['page'] = history;
			settings['shadowSize'] = 4;
			settings['shadowColor'] = 0x543b36;
			
			if (!find && settings.hasOwnProperty('find')) {
				if (settings.find is Array) {
					find = settings.find[0];
				}else if (settings.find is int) {
					find = settings.find;
				}
			}
			
			if (settings.crafting) {
				var i:int = 0;
				for each(var pid:* in settings.crafting) {
					for (var slot:* in pid) {
						if (!App.data.crafting.hasOwnProperty(slot)) continue;
						
						var craft:Object = App.data.crafting[slot];
						var skip:Boolean = false;
						for (var sid:* in craft.items) {
							if (!User.inUpdate(sid))
								skip = true;
						}
						if (!User.inUpdate(craft.out))
							skip = true;
						
						if (!skip) {
							crafts.push(craft);
							slotTime.push({slot:i, crafted:pid[slot]});
							craft = null;
							i++;
						}
					}
				}
			}
			
			super(settings);
		}
		
		override public function drawBackground():void {
			background = backing2(settings.width, settings.height, 100, 'stockBackingTopWithoutSlate', 'stockBackingBot');
			layer.addChild(background);
		}
		
		override public function drawBody():void {
			titleLabel.y += 35;
			
			var backing:Bitmap = backingShort(settings.width - 26, 'barterCenterBacking');
			backing.x = 13;
			backing.y = settings.height - 420;
			bodyContainer.addChild(backing);
			
			container = new Sprite();
			container.x = 56;
			container.y = 20;
			bodyContainer.addChild(container);
			
			// Craft
			craftContainer = new Sprite();
			craftContainer.y = settings.height - 175;
			bodyContainer.addChild(craftContainer);
			
			itemContainer = new Sprite();
			itemContainer.y = settings.height - 175;
			bodyContainer.addChild(itemContainer);
			
			infoContainer = new Sprite();
			infoContainer.y = settings.height - 135;
			bodyContainer.addChild(infoContainer);
			
			infoLabel = drawText(Locale.__e('flash:1439978807587'), {
				width:		settings.width - 40,
				color:		0xfcfbe6,
				borderColor:0x592607,
				fontSize:	28,
				textAlign:	'center',
				shadowSize:	2
			});
			infoLabel.x = 20;
			infoLabel.y = 25;
			infoContainer.addChild(infoLabel);
			
			var contBack:Sprite = new Sprite();
			var back:Bitmap = Window.backing(200, 60, 50, 'itemBacking');
			contBack.addChild(back);
			contBack.x = settings.width / 2 - contBack.width / 2;
			contBack.y = 55;
			infoContainer.addChild(contBack);
			
			var time:int = App.nextMidnight - App.time;
			timerText = Window.drawText(TimeConverter.timeToStr(time), {
				color:0xffdb4b,
				letterSpacing:3,
				textAlign:"center",
				fontSize:36,
				borderColor:0x492318
			});
			timerText.width = 230;
			timerText.y = 10;
			timerText.x = contBack.width / 2 - timerText.width / 2;
			contBack.addChild(timerText);
			
			App.self.setOnTimer(updateDuration);
			
			contentChange();
		}
		
		private function updateDuration():void {
			var time:int = App.nextMidnight - App.time;
				timerText.text = TimeConverter.timeToStr(time);
		}
		
		override public function contentChange():void {
			var item:StationItems;
			for each(item in items) {
				bodyContainer.removeChild(item);
				item.dispose();
			}
			
			items = new Vector.<StationItems>();
			var Y:int = 0;
			var itemNum:int = 0;
			var locked:Boolean = true;
			for (var i:int = 0; i < crafts.length; i++) {				
				var craft:Object = crafts[i];
				item = new StationItems(this, {
					height:170,
					width:145,
					crafting:craft,
					craftData:crafts,
					crafted:slotTime[i].crafted,
					slot:slotTime[i].slot
				});
				item.x = 55;
				item.y = 100 + Y;
				Y += 230;
				bodyContainer.addChild(item);
				items.push(item);
				itemNum++;
			}
		}
		
		private function clear():void {
			while (items.length) {
				var item:StationItems = items.shift();
				item.dispose();
				if (container) {
					if (container.contains(item)) container.removeChild(item);
				}
				item = null;
			}
		}
		
		override public function dispose():void
		{
			clear();
			super.dispose();
		}
	}
}

import buttons.Button;
import buttons.MoneyButton;
import buttons.MoneySmallButton;
import core.Load;
import core.Numbers;
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.text.TextField;
import ui.Hints;
import wins.Window;
import wins.BonusList;
import wins.ProgressBar;

internal class StationItems extends Sprite {
	
	public var background:Bitmap;
	public var exchangeBttn:Button;
	public var storageBttn:Button;
	public var buyBttn:MoneySmallButton;
	public var arrow:Bitmap;
	public var window:*;
	public var items:Vector.<StationItem> = new Vector.<StationItem>();
	private var _modeChange:Boolean = true;	
	public var recipe:Object;
	private var changeText:TextField;
	private var crafted:int;
	private var slot:int;
	
	public function StationItems(window:*,  _settings:Object = null) {
		this.window = window;
		recipe = _settings.crafting;
		
		crafted = _settings.crafted;
		slot = _settings.slot;
		
		background = Window.backing(660, 190, 40, 'shopBackingSmall1');
		
		exchangeBttn = new Button({
			caption:Locale.__e("flash:1382952380010"),
			fontSize:24,
			width:130,
			hasDotes:false,
			height:44
		});
		exchangeBttn.x = 120;
		exchangeBttn.y = 70;
		addChild(exchangeBttn);
		exchangeBttn.addEventListener(MouseEvent.CLICK, onExchangeClick);
		
		arrow = new Bitmap(Window.textures.barterArrowYellow);
		createItems();
		arrow.x = 120;
		arrow.y = 20;
		addChild(arrow);
		
		exchangeBttn.x = 290;
		arrow.x = 290;
		
		var checkCount:int = 0;
		var count:int = 0;
		for (var sid:* in recipe.items) {
			count++;
			if (App.user.stock.check(int(sid), recipe.items[sid], true))
				checkCount++;
		}
		
		if (checkCount == count) 
			modeChange = true;
		else 
			modeChange = false;
		
		changeText = Window.drawText(Locale.__e('flash:1439982761901'), {
			color:		0xffffff,
			borderColor:0x7f5434,
			fontSize:	26,
			autoSize:	'left'
		});
		changeText.x = 20;
		changeText.y = -35;
		addChild(changeText);
		
		
		var bttnSettings:Object = {
			caption     :Locale.__e("flash:1382952379751"),
			width		:60,
			height		:38,	
			fontSize	:24,
			scale		:0.8,
			hasDotes    :false
		}		
		bttnSettings['type'] = 'real';
		bttnSettings['countText'] = 1;
		bttnSettings["bgColor"] = [0xa9f84a, 0x73bb16];
		bttnSettings["borderColor"] = [0xffffff, 0xffffff];
		bttnSettings["bevelColor"] = [0xc5fe78, 0x405c1a];
		bttnSettings["fontColor"] = 0xffffff;				
		bttnSettings["fontBorderColor"] = 0x354321;
		bttnSettings['greenDotes'] = false;
		
		buyBttn = new MoneySmallButton(bttnSettings);
		buyBttn.tip = function():Object { 
			return {
				title:Locale.__e("flash:1382952379751")
			};
		};
		buyBttn.x = changeText.textWidth + 30;
		buyBttn.y = changeText.y - 5;
		buyBttn.coinsIcon.y -= 6;
		buyBttn.addEventListener(MouseEvent.CLICK, onChangeAction);
		addChild(buyBttn);
		
		var finded:Boolean = false;
		if (window.find != null) {
			for (var cellID:* in recipe.items) {
				if (window.find == cellID) {
					finded = true;
					exchangeBttn.showGlowing();
					window.find.length = 0;
				}
			}
			
			if (!finded) {
				if (window.find == recipe.out) {
					finded = true;
					exchangeBttn.showGlowing();
					window.find.length = 0;
				}
			}
		}
		
		if (crafted > 0 && crafted > App.time) waitingForTrain();
	}
	
	public function onChangeAction(e:MouseEvent = null):void {
		window.close();
		window.target.changeSlot(slot);
	}
	
	public function set modeChange(value:Boolean):void {
		_modeChange = value;
		if (value == true) {
			arrow.alpha = 1;
			exchangeBttn.state = Button.NORMAL;
			exchangeBttn.mode = Button.NORMAL;
		} else {
			arrow.alpha = 0.5;
			exchangeBttn.state = Button.DISABLED;
			exchangeBttn.mode = Button.DISABLED;
		}
	}

	public function dispose():void {
		for each(var item:StationItem in items) {
			item.dispose();
		}
	}
	
	public var cont:Sprite;
	public var outItem:OutItem;
	public var mark:Bitmap;
	private var progressBar:ProgressBar;
	public function createItems():void {
		var i:int = 0;
		var icnt:int = 0;
		var bg:Bitmap;
		var barterItem:StationItem;
		cont = new Sprite();
		cont.x = -6;
		bg = Window.backing(280, 128, 10, "itemBacking");
		cont.addChild(bg);
		addChild(cont);
		
		mark = new Bitmap(Window.textures.plus);
		mark.x = 110;
		mark.y = 40;
		addChild(mark);
		
		for (var sid:* in recipe.items) {
			barterItem = new StationItem({sID:sid, count:recipe.items[sid]}, this, StationItem.IN, true);
			items.push(barterItem);
			barterItem.x = 130 * i;
			barterItem.y = 0;
			i++;
			addChild(barterItem);
			barterItem.check();
			barterItem.modeChanges();
		}
		
		outItem = new OutItem({sID:recipe.out, count:recipe.count}, this);
		outItem.x = 434;
		outItem.y -= 34;
		addChild(outItem);
		
		if (progressContainer) progressContainer.visible = false;
		if (storageBttn) storageBttn.visible = false;
	}
	
	public var craftBoostBttn:MoneyButton;
	public var progressContainer:Sprite;
	public function waitingForTrain():void {
		for each (var item:StationItem in items) {
			item.visible = false;
		}
		cont.visible = false;
		exchangeBttn.visible = false;
		arrow.visible = false;
		buyBttn.visible = false;
		mark.visible = false;
		changeText.text = (window.target.sid == 794) ? Locale.__e('flash:1439990221919') : Locale.__e('flash:1443168688097');
		changeText.x = window.settings.width / 2 - changeText.textWidth / 2;
		changeText.y += 20;
		
		progressContainer = new Sprite();
		addChild(progressContainer);
		
		var progressBarBacking:Bitmap = Window.backingShort(180, 'progBarBacking');
		progressContainer.addChild(progressBarBacking);
		
		progressBar = new ProgressBar( {
			width:			194,
			win:			window,
			isTimer:		true
		});
		progressBar.x = progressBarBacking.x - 8;
		progressBar.y = progressBarBacking.y - 4;
		progressContainer.addChild(progressBar);
		progressContainer.x = window.settings.width / 2 - progressContainer.width / 2;
		progressContainer.y += 30;
		progressBar.start();
		
		craftBoostBttn = new MoneyButton( {
			width:		100,
			height:		64,
			caption:	Locale.__e('flash:1382952380104'),
			multiline:	true,
			fontSize:	24
		});
		craftBoostBttn.x = progressBar.width + 25;
		craftBoostBttn.y = progressBar.y;
		craftBoostBttn.addEventListener(MouseEvent.CLICK, onCraftBoost);
		progressContainer.addChild(craftBoostBttn);
		
		outItem.x = 0;
		
		if (storageBttn) storageBttn.visible = false;
		timer();
		App.self.setOnTimer(timer);
	}
	
	private function onCraftBoost(e:MouseEvent = null):void {
		var count:int = Numbers.speedUpPrice(crafted - App.time);
		App.user.stock.take(Stock.FANT, count);
		window.target.onBoost(slot);
		window.close();
	}
	
	private function timer():void {
		if (recipe && crafted >= App.time) {
			progressBar.progress = (App.time - (crafted - recipe.time)) /recipe.time;
			progressBar.time = crafted - App.time;
			craftBoostBttn.countLabelText = Numbers.speedUpPrice(crafted - App.time);
		} else {
			App.self.setOffTimer(timer);
			showProduct();
		}
	}
		
	private function showProduct():void {
		for each (var item:StationItem in items) {
			item.visible = false;
		}
		cont.visible = false;
		exchangeBttn.visible = false;
		arrow.visible = false;
		buyBttn.visible = false;
		mark.visible = false;
		changeText.text = Locale.__e('flash:1439994112857');
		changeText.x = window.settings.width / 2 - changeText.textWidth / 2;
		changeText.y += 20;
		
		outItem.x = 0;
		
		if (progressContainer) progressContainer.visible = false;
		
		storageBttn = new Button({
			caption:Locale.__e("flash:1382952379737"),
			fontSize:24,
			width:130,
			hasDotes:false,
			height:44
		});
		storageBttn.x = window.settings.width / 2 - storageBttn.width / 2;
		storageBttn.y = 70;
		addChild(storageBttn);
		storageBttn.addEventListener(MouseEvent.CLICK, onStorageClick);
	}
	
	private function onStorageClick(e:MouseEvent):void {
		window.close();
		window.target.storageEvent();
	}
	
	private function onExchangeClick(e:MouseEvent):void {
		if (exchangeBttn.mode == Button.DISABLED)
			return;
		
		exchangeBttn.state = Button.DISABLED;
		window.target.onCraft(recipe.ID, slot);
		
		waitingForTrain();	
		window.contentChange();
	}
}


internal class StationItem extends LayerX {
	
	public static const IN:int = 0;
	public static const OUT:int = 1;
	
	public var background:Bitmap;
	public var bitmap:Bitmap;
	public var title:TextField;
	public var material:Object;
	public var sID:int;
	public var buyBttn:MoneySmallButton;
	public var countOnStock:TextField;
	public var window:*;
	
	private var mode:int;
	private var preloader:Preloader = new Preloader();
	private var count:int;
	private var colorCount:int;
	private var findBttn:Button;
	private var tio:Boolean;
	
	public function StationItem(itm:Object, window:*, mode:int = IN, tio:Boolean = false) {
		this.sID = itm.sID;
		this.count = itm.count;
		this.window = window;
		this.mode = mode;
		this.tio = tio;
		
		background = Window.backing(140, 128, 10, "itemBacking");
		
		if(mode == IN && tio == false)
			addChild(background);
		
		bitmap = new Bitmap(null, "auto", true);
		addChild(bitmap);
		
		material = App.data.storage[sID];
		
		title = Window.drawText(material.title, {
			color:0x814f31,
			borderColor:0xfaf9ec,
			fontSize:20,
			multiline:true,
			textAlign:"center",
			wrap:true,
			width:background.width - 20
		});
		title.x = 10;
		title.y = 10;
		addChild(title);
		drawButtons();
		
		addChild(preloader);
		preloader.x = (background.width) / 2;
		preloader.y = (background.height) / 2;
		
		Load.loading(Config.getIcon(material.type, material.view), onLoad);
		drawCount();
		
		tip = function():Object {
			return{
				title:material.title,
				text:material.description
			}
		}
	}
	
	
	private var price:int;
	private var neededCount:int;
	private function drawButtons():void {
		var bttnSettings:Object = {
			caption     :Locale.__e("flash:1382952379751"),
			width		:100,
			height		:38,	
			fontSize	:24,
			scale		:0.8,
			hasDotes    :false
		}
		
		neededCount = count - App.user.stock.count(sID);
		if (App.data.storage[sID].hasOwnProperty('price'))
			price = neededCount * App.data.storage[sID].price[Stock.FANT];
		else 
			price = 0;
		
		bttnSettings['type'] = 'real';
		bttnSettings['countText'] = price;
		bttnSettings["bgColor"] = [0xa9f84a, 0x73bb16];
		bttnSettings["borderColor"] = [0xffffff, 0xffffff];
		bttnSettings["bevelColor"] = [0xc5fe78, 0x405c1a];
		bttnSettings["fontColor"] = 0xffffff;				
		bttnSettings["fontBorderColor"] = 0x354321;
		bttnSettings['greenDotes'] = false;
		
		buyBttn = new MoneySmallButton(bttnSettings);
		buyBttn.tip = function():Object { 
			return {
				title:Locale.__e("flash:1382952379751")
			};
		};
		buyBttn.coinsIcon.y -= 6;
		buyBttn.addEventListener(MouseEvent.CLICK, onBuyAction);
		addChild(buyBttn);
		
		if (App.user.stock.check(sID, count, true)) {
			buyBttn.visible = false;
		}
	}
	
	private function onBuyAction(e:MouseEvent):void {
		if (e.currentTarget.mode == Button.DISABLED) return;
		
		if (!App.user.stock.check(Stock.FANT, price))
			return;
		
		if (!countOnStock)
			drawCount(true);
		
		App.user.stock.buy(sID, neededCount, function():void {
			
			var item:BonusItem = new BonusItem(sID, 1);
			var point:Point = Window.localToGlobal(buyBttn);
			item.cashMove(point, App.self.windowContainer);
		  
			Hints.plus(sID, neededCount, point, true, App.self.tipsContainer);
			Hints.minus(Stock.FANT, price, point, false, App.self.tipsContainer);	
			
			window.window.contentChange();
		});
	}
	
	public function modeChanges():void {
		if (mode == OUT) {
			if(buyBttn) buyBttn.visible = false;
		}
	}
	
	private function onLoad(data:Bitmap):void {
		removeChild(preloader);
		bitmap.bitmapData = data.bitmapData;
		bitmap.smoothing = true;
		bitmap.scaleX = bitmap.scaleY = 0.7;
		bitmap.x = (background.width - bitmap.width) / 2;
		bitmap.y = (background.height - bitmap.height) / 2;
	}
	
	public function drawCount(ignore:Boolean = false):void {
		if (count == 0 && !ignore)
			colorCount = 0xff816e;
		
		var counterSprite:LayerX = new LayerX();
		counterSprite.tip = function():Object { 
			return {
				title:"",
				text:Locale.__e("flash:1382952380305")
			};
		};
		
		var tSett:Object = textSettings[mode];
		if (!App.user.stock.check(sID, count, true)) {
			tSett.color = 0xff816e;
		} else {
			tSett.color = 0xade63f;
		}
		countOnStock = Window.drawText(App.user.stock.count(sID) + '/' + count, tSett);
		
		counterSprite.x = background.width - counterSprite.width - 30;
		counterSprite.y = 130;
		addChild(counterSprite);
		
		countOnStock.x = counterSprite.x + (counterSprite.width - countOnStock.width) / 2 - 5;
		countOnStock.y = counterSprite.y - 56;
		addChild(countOnStock);
	}
	
	private var textSettings:Object = {
		0:{
			color:0xade63f,
			borderColor:0x41332b,
			fontSize:32,
			autoSize:"left",
			shadowColor:0x41332b,
			shadowSize:1
		},
		1: {
			color:0xFFFFFF,
			borderColor:0x41332b,
			fontSize:32,
			autoSize:"left",
			shadowColor:0x41332b,
			shadowSize:1
		}
	}
	
	public function check():void {
		if(countOnStock) {
			'x' + String(count);
		} else if(countOnStock) {
			countOnStock.text = 'x' + String(count);
		}
		if (buyBttn != null) {
			buyBttn.x = (background.width - buyBttn.width) / 2;
			buyBttn.y = background.height - buyBttn.height + 17;
		}
	}
	
	public function dispose():void {
		if (buyBttn) buyBttn.addEventListener(MouseEvent.CLICK, onBuyAction);
	}
}

internal class OutItem extends LayerX {
	public var background:Bitmap;
	public var bitmap:Bitmap;
	public var title:TextField;
	public var material:Object;
	public var sID:int;
	public var countOnStock:TextField;
	public var window:*;
	
	private var preloader:Preloader = new Preloader();
	private var count:int;
	
	public function OutItem(itm:Object, window:*) {
		this.sID = itm.sID;
		this.count = itm.count;
		this.window = window;
		
		background = Window.backing(142, 168, 10, "itemBacking");
		addChild(background);
		
		bitmap = new Bitmap(null, "auto", true);
		addChild(bitmap);
		
		material = App.data.storage[sID];
		
		title = Window.drawText(material.title, {
			color:0x814f31,
			borderColor:0xfaf9ec,
			fontSize:20,
			multiline:true,
			textAlign:"center",
			wrap:true,
			width:background.width - 20
		});
		title.x = 10;
		title.y = 10;
		addChild(title);
		
		addChild(preloader);
		preloader.x = (background.width) / 2;
		preloader.y = (background.height) / 2;
		
		Load.loading(Config.getIcon(material.type, material.view), onLoad);
		drawCount();
		
		tip = function():Object {
			return{
				title:material.title,
				text:material.description
			}
		}
	}
	
	public function cash():void
	{
		var item:BonusItem = new BonusItem(sID, count);
		var point:Point = Window.localToGlobal(bitmap);
		item.cashMove(point, App.self.windowContainer);
		Hints.plus(sID, count, point, true, App.self.tipsContainer);
	}
	
	private function onLoad(data:Bitmap):void {
		removeChild(preloader);
		bitmap.bitmapData = data.bitmapData;
		bitmap.smoothing = true;
		bitmap.x = (background.width - bitmap.width) / 2;
		bitmap.y = (background.height - bitmap.height) / 2;
	}
	
	public function drawCount(ignore:Boolean = false):void {		
		var counterSprite:LayerX = new LayerX();
		counterSprite.tip = function():Object { 
			return {
				title:"",
				text:Locale.__e("flash:1382952380305")
			};
		};
		
		countOnStock = Window.drawText('x' + count, {
			color:0xfbc92a,
			borderColor:0x463835,
			fontSize:42,
			autoSize:"left",
			shadowColor:0x41332b,
			shadowSize:1
		});		
		counterSprite.x = background.width - counterSprite.width - 30;
		counterSprite.y = 175;
		addChild(counterSprite);
		
		countOnStock.x = counterSprite.x + (counterSprite.width - countOnStock.width) / 2 - 5;
		countOnStock.y = counterSprite.y - 56;
		addChild(countOnStock);
	}
	
	public function dispose():void {
		//
	}
}