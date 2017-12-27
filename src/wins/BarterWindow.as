package wins {
	
	import buttons.Button;
	import core.Size;
	import flash.display.Bitmap;
	import flash.events.MouseEvent;
	import flash.text.TextField;

	public class BarterWindow extends Window {
		
		public static var history:int = 0;
		public var items:Vector.<BarterItems> = new Vector.<BarterItems>();
		public var mode:uint;
		public var openedActions:Array = [];
		public var barter:Object = { };
		private var nuggetIcon:Bitmap;
		private var nuggetInStock:TextField;
		public var find:Array = [];
		public static var findTargets:Array = [];
		
		public function BarterWindow(settings:Object = null):void {
			if (settings == null) {
				settings = new Object();
			}
			
			//settings["title"] = Locale.__e("flash:1382952379800");
			settings["title"] = settings.target.info.title;
			settings["width"] = 710;
			settings["height"] = 690;
			settings['background'] = 'storageBackingMain';
			settings["hasPaginator"] = true;
			settings["hasArrows"] = true;
			settings["itemsOnPage"] = 3;
			settings["page"] = history;
			settings['content'] = [];
			settings['shadowColor'] = 0x513f35;
			settings['shadowSize'] = 4;
			//updateContent();
			
			if (settings.hasOwnProperty('find') && (settings.find is Array)) {
				for (var i:int = 0; i < settings.find.length; i++)
					find.push(settings.find[i]);
			} else if (ProductionWindow.find) {
				find = [ProductionWindow.find];
				ProductionWindow.find = 0;
			} else {
				find.push(settings.find);
			}
			
			if (findTargets.length > 0) {
				for (var j:int = 0; j < findTargets.length; j++) {
					find.push(findTargets[j]);
				}
			}
			
			settings.target.helpTarget = find;
			findTargetPage(settings);
			
			barter = App.data.barter;
			
			super(settings);
		}
		
		private function findTargetPage(settings:Object):void {
			var content:Array = [];
			for (var bID:* in App.data.barter) {
				var item:Object = App.data.barter[bID];
				item['bID'] = bID;
				if (item.building == settings.target.sid)
					content.push(item);
			}
			content.sortOn('order', Array.NUMERIC);
			
			var finded:Boolean = false;
			for (var i:* in content) {
				for (var j:* in content[i].items) {
					if (settings.target.helpTarget == j) {
						history = int(int(i) / settings.itemsOnPage);
						settings.page = history;
						return;
					}
				}
			}
			
			for (var c:* in content) {
				for (var d:* in content[c].out) {
					if (settings.target.helpTarget == d) {
						history = int(int(c) / settings.itemsOnPage);
						settings.page = history;
						return;
					}
				}
			}
		}
		
		override public function dispose():void {
			super.dispose();
			for each(var item:* in items)
				item.dispose();
				
			findTargets = [];
		}
		
		private var titleBacking:Bitmap;
		override public function drawBackground():void {
			background = backing2(settings.width, settings.height, 100, 'stockBackingTopWithoutSlate', 'stockBackingBot');
			layer.addChild(background);
		}
		
		override public function drawTitle():void {
			titleLabel = titleText( {
				title				: settings.title,
				color				: settings.fontColor,
				multiline			: settings.multiline,			
				fontSize			: settings.fontSize,				
				textLeading	 		: settings.textLeading,				
				borderColor 		: settings.fontBorderColor,			
				borderSize 			: settings.fontBorderSize,	
				shadowColor			: settings.shadowColor,
				width				: settings.width - 140,
				textAlign			: 'center',
				sharpness 			: 50,
				thickness			: 50,
				border				: true,
				shadowSize			:4
			});
			titleLabel.x = (settings.width - titleLabel.width) * .5;
			titleLabel.y = - 15;
			titleLabel.mouseChildren = titleLabel.mouseEnabled = false;
			headerContainer.addChild(titleLabel);
			headerContainer.y = 37;
			headerContainer.mouseEnabled = false;
		}
		
		public function updateContent():void {
			settings.content = [];
			for (var bID:* in App.data.barter) {
				//if (bID == 120 || bID == 121 || bID == 122)
					//trace();
				
				var item:Object = App.data.barter[bID];
				var skip:Boolean = false;
				if (item.out is Object) {
					for (var itm:String in item.out) {
						if (!User.inUpdate(itm))
							skip = true;
					} 
				} else {
					if (!User.inUpdate(item.out))
						continue;
				}
				for (var it:String in item.items) {
					if (!User.inUpdate(it))
						skip = true;
				}
				if (item.hasOwnProperty('expire') && item.expire.hasOwnProperty(App.social) && item.expire[App.social] <= App.time) {
					skip = true;
				}
				if (skip) continue;
				item['bID'] = bID;
				if (item.building == settings.target.sid) {
					settings.content.push({
						order:	App.data.barter[bID].order,
						bID:	bID
					});
				}
			}
			settings.content.sortOn('order', Array.NUMERIC);
			
			var index:int = -1;
			var i:int;
			if (find.length > 0) {
				for (i = 0; i < settings.content.length; i++) {
					if (App.data.barter[settings.content[i].bID].hasOwnProperty('items')) {
						for (var s:* in App.data.barter[settings.content[i].bID].items) {
							if (find.indexOf(int(s)) >= 0) {
								index = i;
								break;
							}
						}
					}
					
					if (index >= 0 && index < settings.content.length) break;
				}
				
				if (index < 0 ) {
					for (i = 0; i < settings.content.length; i++) {
						if (App.data.barter[settings.content[i].bID].hasOwnProperty('out')) {
								var sID:String ='0';
								for (sID in  App.data.barter[settings.content[i].bID].out) break;
								if (find.indexOf(int(sID)) >= 0) {
									index = i;
									break;
								}
						}
						
						if (index >= 0 && index < settings.content.length) break;
					}
				}
			}
			
			if (index >= 0)
				paginator.page = Math.floor(index / paginator.onPageCount);
			
			paginator.itemsCount = settings.content.length;
			paginator.update();
		}
		
		override public function drawArrows():void {
			super.drawArrows();
			
			paginator.arrowLeft.x -= 20;
			paginator.arrowLeft.y -= 40;
			paginator.arrowRight.x += 20;
			paginator.arrowRight.y -= 40;
			
			paginator.x = int((settings.width - paginator.width)/2 - 40);
			paginator.y = int(settings.height - paginator.height - 15);
		}

		private var shelfBacking:Bitmap;
		private var shelfBacking2:Bitmap;
		override public function drawBody():void {
			shelfBacking = backingShort(settings.width - 26, 'barterCenterBacking', true);
			shelfBacking.x = 13;
			shelfBacking.y = 130;
			bodyContainer.addChild(shelfBacking);
			
			shelfBacking2 = backingShort(settings.width - 26, 'barterCenterBacking', true);
			shelfBacking2.x = 13;
			shelfBacking2.y = 315;
			bodyContainer.addChild(shelfBacking2);
			
			exit.x += 5;
			exit.y = - 10;
			
			var youHave:TextField = drawText(Locale.__e("flash:1425978184363"), {
				fontSize:26,
				autoSize:"left",
				textAlign:"center",
				color:0xffffff,
				borderColor:0x6c3311,
				shadowColor:0x6c3311,
				shadowSize:1
			});
			youHave.x = 25;
			youHave.y = 8;
			bodyContainer.addChild(youHave);
			
			//Nugget icon
			nuggetIcon = new Bitmap(Window.textures.goldenNuggetIco);
			if (settings.target.sid == 2561) {
				nuggetIcon = new Bitmap(Window.textures.platinum);
				Size.size(nuggetIcon, 27, 27);
				nuggetIcon.smoothing = true;
			}
			nuggetIcon.x = youHave.x + youHave.width + 5;
			nuggetIcon.y = youHave.y - 3;
			bodyContainer.addChild(nuggetIcon);
			
			//Nugget count
			nuggetInStock = drawText(String(App.user.stock.count(27)), {
				fontSize:36,
				autoSize:"center",
				textAlign:"center",
				color:0xffe13c,
				borderColor:0x5e2808,
				shadowColor:0x5e2808,
				shadowSize:1
			});
			if (settings.target.sid == 2561) {
				nuggetInStock.text = String(App.user.stock.count(2467));
			}
			nuggetInStock.x = nuggetIcon.x + nuggetIcon.width + 5;
			nuggetInStock.y = nuggetIcon.y - 3;
			nuggetInStock.width = nuggetInStock.textWidth;
			bodyContainer.addChild(nuggetInStock);
			
			if (settings.target.sid == 2561) {
				youHave.x -= 10;
				nuggetIcon.x -= 14;
				nuggetInStock.x -= 14;
			}
			
			paginator.page = settings.page;
			paginator.update();
			contentChange();
			
			if (settings.target.sid == 772) {
				youHave.visible = false;
				nuggetIcon.visible = false;
				nuggetInStock.visible = false;
			}
			
			drawBttns();
		}
		
		private function drawBttns():void {
			var bttnSettings:Object = {
				caption:Locale.__e("flash:1393580181245"),
				fontSize:30,
				width:140,
				height:46,
				hasDotes:false
			};
		}
		
		override public function contentChange():void {
			if (settings.target.sid == 2561) {
				nuggetInStock.text = String(App.user.stock.count(2467));
			}else {
				nuggetInStock.text = String(App.user.stock.count(27));
			}
			
			var item:BarterItems;
			for each(item in items) {
				bodyContainer.removeChild(item);
				item.dispose();
			}
			
			items = new Vector.<BarterItems>();
			updateContent();
			var Y:int = 0;
			var itemNum:int = 0;
			var locked:Boolean = true;
			for (var i:int = paginator.startCount; i < paginator.finishCount; i++) {
				item = new BarterItems(settings.content[i].bID, this/*, mode*/);
				item.x = 55;
				item.y = 60 + Y;
				Y += 186;
				bodyContainer.addChild(item);
				items.push(item);
				itemNum++;
			}
			
			settings.page = paginator.page;
			history = settings.page;
		}
		
		override public function close(e:MouseEvent = null):void {
			if (settings.target.sid == 772)
				settings.target.playShoot();
			super.close();
		}
	}
}

import buttons.Button;
import buttons.MoneyButton;
import buttons.MoneySmallButton;
import core.Load;
import core.Numbers;
import core.TimeConverter;
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.text.TextField;
import ui.Hints;
import wins.BarterWindow;
import wins.Window;
import wins.BonusList;

internal class BarterItems extends Sprite {
	
	public var barter:Object = { };
	public var background:Bitmap;
	public var exchangeBttn:Button;
	public var arrow:Bitmap;
	public var window:*;
	public var items:Vector.<BarterItem> = new Vector.<BarterItem>();
	public var bonusList:BonusList;
	public var bID:int;
	public var item:Object;
	private var _modeChange:Boolean = true;
	
	private var sID:String;
	private var sID2:String;
	private var count:int;
	private var count2:int;
	
	public var two_to_one:Boolean = false;
	
	public function BarterItems(bID:int, window:*) {
		//this.barter = barter;
		this.window = window;
		this.bID = bID;
		item = App.data.barter[bID];
		if (Numbers.countProps(item.out) == 2)
			two_to_one = true;
		
		for (sID in item.out) break;
		
		if (two_to_one) {
			sID = Numbers.getProp(item.out, 0).key;
			sID2 = Numbers.getProp(item.out, 1).key;
			
			count2 = item.out[sID2];
		}
		
		count = item.out[sID];
		
		background = Window.backing(660, 190, 40, 'shopBackingSmall1');
		//addChild(background);
		
		exchangeBttn = new Button({
			caption:Locale.__e("flash:1382952380010"),
			fontSize:24,
			width:130,
			hasDotes:false,
			height:44
		});
		exchangeBttn.x = 160;
		exchangeBttn.y = 70;
		addChild(exchangeBttn);
		exchangeBttn.addEventListener(MouseEvent.CLICK, onExchangeClick);
		
		arrow = new Bitmap(Window.textures.barterArrowYellow);
		createItems();
		arrow.x = 160;
		arrow.y = 20;
		addChild(arrow);
		
		if (two_to_one) {
			exchangeBttn.x = 312;
			arrow.x = 312;
			
			if (App.user.stock.check(int(sID), count, true) && App.user.stock.check(int(sID2), count2, true)) {
				modeChange = true;
			} else {
				modeChange = false;
			}
		} else {
			if (App.user.stock.check(int(sID), count, true)) {
				modeChange = true;
			} else {
				modeChange = false;
			}
		}
		
		var finded:Boolean = false;
		var find:Array = window.find;
		if (BarterWindow.findTargets.length > 0) {
			find = BarterWindow.findTargets;
		}
		if (find.length > 0) {
			if (find[0] == 0) {
				find.length = 0;
				return;
			}
			for (var cellID:* in item.items) {
				if (find.indexOf(int(cellID)) >= 0) {
					finded = true;
					exchangeBttn.showGlowing();
					window.find.length = 0;
				}
			}
			
			if (!finded) {
				for (var ids:* in item.out) {
					if (find.indexOf(int(ids)) >= 0) {
						finded = true;
						exchangeBttn.showGlowing();
						window.find.length = 0;
					}
				}
			}
		}
		
		if (item.hasOwnProperty('expire') && item.expire.hasOwnProperty(App.social)) {
			if (item.expire[App.social] > App.time) {
				drawTimer();
			} else {
				exchangeBttn.state = Button.DISABLED;
			}
		}
	}
	
	private var timerText:TextField;
	private function drawTimer():void {
		timerText = Window.drawText(TimeConverter.timeToStr(item.expire[App.social] - App.time), {
			color: 0xfff200,
			borderColor: 0x680000,
			fontSize: 26,
			textAlign: 'center',
			width: background.width
		});
		timerText.y = arrow.y - timerText.textHeight - 5;
		addChild(timerText);
		App.self.setOnTimer(updateTimer);
	}
	
	private function updateTimer():void {
		if (timerText) {
			var text:String = TimeConverter.timeToStr(item.expire[App.social] - App.time);
			timerText.text = text;
			
			if (item.expire[App.social] - App.time <= 0) {
				timerText.visible = false;					
				App.self.setOffTimer(updateTimer);
				
				exchangeBttn.state = Button.DISABLED;
			}
		}
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
		for each(var item:BarterItem in items) {
			item.dispose();
		}
	}
	
	public var cont:Sprite;
	public var cont2:Sprite;
	public function createItems():void {
		var i:int = 0;
		var icnt:int = 0;
		var bg:Bitmap;
		var barterItem:BarterItem;
		if (two_to_one) {
			cont = new Sprite();
			cont.x = -6;
			bg = Window.backing(300, 128, 10, "itemBacking");
			cont.addChild(bg);
			addChild(cont);
			
			var mark:Bitmap;
			mark = new Bitmap(Window.textures.plus);
			mark.x = 130;
			mark.y = 40;
			addChild(mark);
			
			i = 0;
			barterItem = new BarterItem({sID:int(sID), count:count}, this, BarterItem.IN, true);
			items.push(barterItem);
			barterItem.x = 140 * i;
			barterItem.y = 0;
			i++;
			addChild(barterItem);
			barterItem.check();
			barterItem.modeChanges();
			
			barterItem = new BarterItem({sID:int(sID2), count:count2}, this, BarterItem.IN, true);
			items.push(barterItem);
			barterItem.x = 140 * i;
			barterItem.y = 0;
			i++;
			addChild(barterItem);
			barterItem.check();
			barterItem.modeChanges();
			
			
			cont2 = new Sprite();
			cont2.x = 454;
			bg = Window.backing(150, 128, 10, "itemBacking");
			cont2.addChild(bg);
			
			i = 0;
			icnt = 0;
			for (var _sID:* in item.items) {
				barterItem = new BarterItem({sID:_sID, count:item.items[_sID]}, this, BarterItem.OUT);
				items.push(barterItem);
				barterItem.x = 140 * i;
				barterItem.y = 0;
				i++;
				icnt++;
				cont2.addChild(barterItem);
				barterItem.check();
				barterItem.modeChanges();
			}
			addChild(cont2);
			////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		} else {
			i = 0;
			barterItem = new BarterItem({sID:int(sID), count:count}, this, BarterItem.IN);
			items.push(barterItem);
			barterItem.x = 140 * i;
			barterItem.y = 0;
			i++;
			addChild(barterItem);
			barterItem.check();
			barterItem.modeChanges();
			
			cont = new Sprite();
			cont.x = 300;
			bg = Window.backing(300, 128, 10, "itemBacking");
			cont.addChild(bg);
			
			i = 0;
			icnt = 0;
			for (var __sID:* in item.items) {
				barterItem = new BarterItem({sID:__sID, count:item.items[__sID]}, this, BarterItem.OUT);
				items.push(barterItem);
				barterItem.x = 140 * i;
				barterItem.y = 0;
				i++;
				icnt++;
				cont.addChild(barterItem);
				barterItem.check();
				barterItem.modeChanges();
			}
			addChild(cont);
			if (icnt == 1) {
				barterItem.x += (bg.width - barterItem.width) / 2;
			}
		}
	}
	
	private function onExchangeClick(e:MouseEvent):void {
		if (exchangeBttn.mode == Button.DISABLED)
			return;
		
		exchangeBttn.state = Button.DISABLED;
		window.settings.onExchange(bID);
		
		for each(var _item:BarterItem in items) {
			_item.cash();
		}
		
		window.contentChange();
	}
}


internal class BarterItem extends LayerX {
	
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
	
	public function BarterItem(itm:Object, window:*, mode:int = IN, tio:Boolean = false) {
		this.sID = itm.sID;
		this.count = itm.count;
		this.window = window;
		this.mode = mode;
		this.tio = tio;
		
		background = Window.backing(150, 128, 10, "itemBacking");
		
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
		
		if(mode == IN)
			drawButtons();
		
		addChild(preloader);
		preloader.x = (background.width) / 2;
		preloader.y = (background.height) / 2;
		
		Load.loading(Config.getIcon(material.type, material.preview), onLoad);
		drawCount();
		
		function shuffle(a:*,b:*):int {
			var num : int = Math.round(Math.random() * 2) - 1;
			return num;
		}
		
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
		
		if (price == 0) {
			return;
		}
		
		bttnSettings['type'] = 'real';
		bttnSettings['countText'] = price;
		bttnSettings["bgColor"] = [0xa9f84a, 0x73bb16];
		bttnSettings["borderColor"] = [0xffffff, 0xffffff];
		bttnSettings["bevelColor"] = [0xc5fe78, 0x405c1a];
		bttnSettings["fontColor"] = 0xffffff;				
		bttnSettings["fontBorderColor"] = 0x354321;
		bttnSettings['greenDotes'] = false;
		findBttn = new Button({
				caption			:Locale.__e("flash:1405687705056"),
				fontSize		:15,
				radius      	:10,
				fontColor:		0xffffff,
				fontBorderColor:0x475465,
				borderColor:	[0xfff17f, 0xbf8122],
				bgColor:		[0x75c5f6,0x62b0e1],
				bevelColor:		[0xc6edfe,0x2470ac],
				width			:94,
				height			:30,
				fontSize		:15
			});
		buyBttn = new MoneySmallButton(bttnSettings);
		buyBttn.tip = function():Object { 
			return {
				title:Locale.__e("flash:1382952379751")/*,
				text:Locale.__e("flash:1410432789818")*/
			};
		};
		buyBttn.coinsIcon.y -= 6;
		buyBttn.addEventListener(MouseEvent.CLICK, onBuyAction);
		addChild(buyBttn);
		addChild(findBttn);
		findBttn.addEventListener(MouseEvent.CLICK, onFindAction);
		if (App.user.stock.check(sID, count, true)) {
			buyBttn.visible = false;
			findBttn.visible = false;
		}
	}
	
	/*private function onFindAction(e:MouseEvent):void {
		window.settings.target.work(sID);
		window.close();
	}*/
	private function onFindAction(e:MouseEvent):void {
		Find.find(sID);
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
	
	public function cash():void
	{
		if (mode == IN) return;
		
		var item:BonusItem = new BonusItem(sID, count);
		var point:Point = Window.localToGlobal(bitmap);
		item.cashMove(point, App.self.windowContainer);
		Hints.plus(sID, count, point, true, App.self.tipsContainer);
	}
	
	public var searchBttn:MoneyButton
	public function modeChanges():void {
		if (mode == OUT) {
			//не отображать кнопки
			if (buyBttn) buyBttn.visible = false;
			if (findBttn) findBttn.visible = false;
		}
	}
	
	private function onSearchBttn(e:MouseEvent):void {
		window.close();
		if (window.settings.onSearch != null) 
			window.settings.onSearch(window.mode, sID);
	}
	
	private function onLoad(data:Bitmap):void {
		removeChild(preloader);
		bitmap.bitmapData = data.bitmapData;
		bitmap.smoothing = true;
		bitmap.scaleX = bitmap.scaleY = 1;
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
		if(mode == IN) {
			if (!App.user.stock.check(sID, count, true)) {
				tSett.color = 0xff816e;
			} else {
				tSett.color = 0xade63f;
			}
		}
		
		countOnStock = Window.drawText('x' + count, tSett);
		
		if (mode == IN && tio) {
			tSett.fontSize = 34;
			countOnStock = Window.drawText(App.user.stock.count(sID) + '/' + count, tSett);
		}
		
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
			fontSize:42,
			autoSize:"left",
			shadowColor:0x41332b,
			shadowSize:1
		},
		1: {
			color:0xFFFFFF,
			borderColor:0x41332b,
			fontSize:42,
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
			findBttn.x = (background.width - findBttn.width) / 2;
			findBttn.y = background.height - findBttn.height + 17 - buyBttn.height - 5;
		}
	}
	
	private function onWishlistEvent(e:MouseEvent):void {
		App.wl.show(sID, e);
	}
	
	public function dispose():void {
		//
	}
}