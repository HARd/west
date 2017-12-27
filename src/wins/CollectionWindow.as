package wins
{
	import buttons.Button;
	import flash.display.Bitmap;
	import flash.events.MouseEvent;

	public class CollectionWindow extends Window
	{
		private var separator:Bitmap;
		private var separator2:Bitmap;
		public static const COLLECTIONS:int = 0;
		public static const SELECT_COLLECTION:int = 1;
		public static const SELECT_ELEMENT:int = 2;
		public static const COLLECTION_SHOP:int = 3;
		public static const PATHFINDER:int = 4;
		
		public static var history:int = 0;
		public var items:Vector.<CollectionItems> = new Vector.<CollectionItems>();
		public var mode:uint;
		public var openedActions:Array = [];
		
		//public var exchangeBttn:Button;
		
		public function CollectionWindow(settings:Object = null):void
		{
			if (settings == null) {
				settings = new Object();
			}
			
			mode = settings.mode || COLLECTIONS;
			if (mode == PATHFINDER) 
			{
				for (var collID:* in settings.opened) {
					openedActions.push(settings.opened[collID]);
				}

			}
			settings["title"] = Locale.__e("flash:1382952379800");
			settings["width"] = 750;
			settings["height"] = 630;
			settings['background'] = 'storageBackingMain';
			settings["hasPaginator"] = true;
			settings["hasArrows"] = true;
			settings["itemsOnPage"] = 2;
			settings["page"] = history;
			settings['content'] = [];
			settings['shadowColor'] = 0x513f35;
			settings['shadowSize'] = 4;
			//settings['find'] = settings.find || null;
			//updateContent();
			
			if (settings.find) findTargetPage(settings);
			
			super(settings);
		}
		
		private function findTargetPage(settings:Object):void {
			var content:Array = [];
			for (var sID:* in App.data.storage) {
				var item:Object = App.data.storage[sID];
				item['sID'] = sID;
				if (item.type == 'Collection' && item.visible) {
					content.push(item);
					
					var full:Boolean = true;
					for each(var mID:int in item.materials) {
						if (App.user.stock.count(mID) == 0) {
							full = false;
							break;
						}
					}
					if (full && item.order > 0) {
						item.order *= -1;
					}else if (!full && item.order < 0) {
						item.order *= -1;
					}
				}
			}
			content.sortOn('order', Array.NUMERIC);
			
			for (var i:* in content) {
				
				var sid:int = content[i].sID;
				if (settings.find != null && settings.find.indexOf(sid) != -1) {
					
					history = int(int(i) / settings.itemsOnPage);
					settings.page = history;
					return;
				}
			}
		}
		
		public static function get count():int {
			var count:int = 0;
			for (var s:* in App.data.storage) { 
				if (App.data.storage[s].type == 'Collection') {
					if (!App.data.storage[s].hasOwnProperty('materials')) continue;
					var biggest:int = -1;
					for each (var cid:* in App.data.storage[s].materials) {
						if (!App.user.stock.data.hasOwnProperty(cid) || App.user.stock.data[cid] == 0) {
							biggest = 0;
							break;
						}
						if (biggest < 0 || biggest > App.user.stock.data[cid])
							biggest = App.user.stock.data[cid];
					}
					
					count += biggest;
				}
			}
			
			return count;
		}
		
		override public function dispose():void {
			
			super.dispose();
			
			for each(var item:* in items)	item.dispose();
		}
		
		private var titleBacking:Bitmap;
		override public function drawBackground():void {
			background = backing2(settings.width, settings.height, 100, 'shopBackingTop', 'shopBackingBot');
			layer.addChild(background);
			
			titleBacking = backingShort(235, 'stockTitleBacking', true);
			drawMirrowObjs('shopTitleBacking', (settings.width - 518) / 2, (settings.width - 518) / 2 + 518, -63, false, false, false, 1, 1, layer);
		}
		
		override public function drawTitle():void 
		{
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
			})
				
			titleLabel.x = (settings.width - titleLabel.width) * .5;
			titleLabel.y = -60;
			titleLabel.mouseChildren = titleLabel.mouseEnabled = false;
			headerContainer.addChild(titleLabel);
			headerContainer.y = 37;
			headerContainer.mouseEnabled = false;
		}
		
		public function updateContent():void {
			
			settings.content = [];
			for (var sID:* in App.data.storage) {
				var item:Object = App.data.storage[sID];
				item['sID'] = sID;
				
				if (item.type == Storage.COLLECTION && item.visible && User.inUpdate(sID)) {
					var full:Boolean = true;
					
					for each(var mID:int in item.materials) {
						if (App.user.stock.count(mID) == 0) {
							full = false;
							break;
						}
					}
					settings.content.push(item);
					
					if (full && item.order > 0) {
						item.order *= -1;
					}else if (!full && item.order < 0) {
						item.order *= -1;
					}
				}
			}
			settings.content.sortOn('order', Array.NUMERIC);
			
			paginator.itemsCount = settings.content.length;
			paginator.update();
		}
		
		override public function drawArrows():void {
			super.drawArrows();
			paginator.arrowLeft.y -= 60;			
			paginator.arrowLeft.x -= 20;			
			paginator.arrowRight.y -= 60;
			paginator.arrowRight.x += 20;
			
			paginator.x = int((settings.width - paginator.width)/2 - 40);
			paginator.y = int(settings.height - paginator.height + 4);
		}

		private var shelfBacking:Bitmap;
		override public function drawBody():void {
			shelfBacking = backingShort(settings.width - 10, 'collectionCenterBacking', true);
			shelfBacking.x = 5;
			shelfBacking.y = settings.height / 2 - 170;
			bodyContainer.addChild(shelfBacking);
			
			exit.x += 5;
			exit.y = -35;
			
			paginator.page = settings.page;
			paginator.update();
			contentChange();
			
			drawBttns();
		}
		
		private function drawBttns():void 
		{
			var bttnSettings:Object = {
				caption:Locale.__e("flash:1393580181245"),
				fontSize:30,
				width:140,
				height:46,
				hasDotes:false
			};
		}
		
		override public function contentChange():void {
			var item:CollectionItems;
			for each(item in items) {
				bodyContainer.removeChild(item);
				item.dispose();
			}
			
			items = new Vector.<CollectionItems>();
			updateContent();
			
			var itemNum:int = 0;
			var locked:Boolean = true;
			for (var i:int = paginator.startCount; i < paginator.finishCount; i++) {
				if (mode == PATHFINDER) {					
						if (openedActions.indexOf(settings.content[i].sID) != -1) 
							locked = false;
						else
							locked = true;
							
						item = new CollectionItems(settings.content[i], this, mode, locked);
				}else {
					item = new CollectionItems(settings.content[i], this, mode);
				}
				
				bodyContainer.addChild(item);
				item.x = (settings.width - item.width)/2;
				item.y = 24 + (item.height + 35) * itemNum;
				items.push(item);
				itemNum++;
			}
			
			settings.page = paginator.page;
			history = settings.page;
		}
		
		public static function completed():uint
		{
			var counter:int = 0;
			
			for (var sID:* in App.data.storage) {
				var item:Object = App.data.storage[sID];
				if (item.visible == 0) continue;
				
				if (item.type == 'Collection') {
					var min:int = -1;
					for each(var mID:int in item.materials) {
						if (min == -1) {
							min = App.user.stock.count(mID);
						}else{
							min = Math.min(min, App.user.stock.count(mID));
						}
						if(min == 0){
							break;
						}
					}
					if(min != -1){
						counter += min;
					}
				}
			}
				
			return counter;
		}
		
	}

}


import api.ExternalApi;
import buttons.Button;
import buttons.ImageButton;
import buttons.MoneyButton;
import buttons.MoneySmallButton;
import core.Load;
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.text.TextField;
import ui.Hints;
import wins.Window;
import wins.BonusList;
import wins.CollectionWindow;

internal class CollectionItems extends Sprite {
	
	public var collection:Object;
	public var background:Bitmap;
	public var title:TextField;
	public var exchangeBttn:Button;
	public var exchangeAllBttn:Button;
	public var arrow:Bitmap;
	public var window:*;
	public var items:Vector.<CollectionItem> = new Vector.<CollectionItem>();
	public var bonusList:BonusList;
	private var mode:int;
	private var locked:Boolean;
	private var _modeChange:Boolean = true;
	
	public function CollectionItems(collection:Object, window:*, mode:int, locked:Boolean = false) {
		this.collection = collection;
		this.window = window;
		this.mode = mode;
		this.locked = locked;
		
		background = Window.backing(663, 190, 40, 'shopBackingSmall1');
		//addChild(background);
						
		exchangeBttn = new Button( {
			caption:Locale.__e("flash:1382952380010"),
			fontSize:24,
			width:130,
			hasDotes:false,
			height:44
		});
		addChild(exchangeBttn);
		exchangeBttn.x = background.width - exchangeBttn.width - 16;
		exchangeBttn.y = background.height - exchangeBttn.height / 2;
		
		exchangeAllBttn = new Button( {
			caption:Locale.__e("flash:1459763693769"),
			fontSize:24,
			width:130,
			hasDotes:false,
			height:44
		});
		addChild(exchangeAllBttn);
		exchangeAllBttn.x = background.x + 16;
		exchangeAllBttn.y = background.height - exchangeAllBttn.height / 2;
		
		title = Window.drawText(collection.title, {
			color:0xffffff,
			borderColor:0x4b390f,
			fontSize:26,
			borderSize:4,
			autoSize:'left'
		});
		
		title.x = (background.width - title.width) / 2;
		title.y -= title.height - 6;
		addChild(title);
		
		var marginPnt:int = 3;
		
		var pnt:Bitmap = new Bitmap(Window.textures.itemBacking);
		pnt.alpha = 0.5;
		pnt.x = title.x - pnt.width - marginPnt;
		pnt.y = title.y + title.textHeight / 2 - pnt.height / 2;
		//addChild(pnt);
		
		var pnt2:Bitmap = new Bitmap(Window.textures.itemBacking);
		pnt2.alpha = 0.5;
		pnt2.x = title.x + title.textWidth + marginPnt + pnt.width;
		pnt2.y = title.y + title.textHeight / 2 - pnt2.height / 2;
		//addChild(pnt2);
		
		bonusList = new BonusList(collection.reward, true, {background:'collectionRewardBacking', titleBorderColor:0x191f37, bonusBorderColor:0x212747});
		addChild(bonusList);
		bonusList.x = (background.width - bonusList.width) / 2;
		bonusList.y = background.height - 30;
		
		createItems();
		
		arrow = new Bitmap(Window.textures.checkMark);
		arrow.x = 0; arrow.y = -16;
		addChild(arrow);
		
		exchangeBttn.addEventListener(MouseEvent.CLICK, onExchangeEvent);
		exchangeAllBttn.addEventListener(MouseEvent.CLICK, onExchangeAllEvent);
		
		if (App.user.stock.checkCollection(collection.sID)) {
			modeChange = true;
		}else {
			modeChange = false;
		}
		
	}
	
	private function set modeChange(value:Boolean):void
	{
		_modeChange = value;
		if (value == true) {
			exchangeBttn.visible = true;
			exchangeAllBttn.visible = true;
			arrow.visible = true;
		}else {
			exchangeBttn.visible = false;
			exchangeAllBttn.visible = false;
			arrow.visible = false;
		}
	}

	public function dispose():void {
		exchangeBttn.removeEventListener(MouseEvent.CLICK, onExchangeEvent);
		exchangeAllBttn.removeEventListener(MouseEvent.CLICK, onExchangeAllEvent);
		
		for each(var item:CollectionItem in items) {
			item.dispose();
		}
	}
	
	public function createItems():void {
		
		var i:int = 0;
		for each(var sID:* in collection.materials) {
			var item:CollectionItem = new CollectionItem(sID, window, mode, locked);
			items.push(item);
			item.x = 3 + 135 * i;
			item.y = 3;
			i++;
			addChild(item);
			item.check();
			item.modeChanges();
		}
	}
	
	private function onExchangeEvent(e:MouseEvent):void {
		//exchangeBttn.state = Button.DISABLED;
		exchangeBttn.visible = false;
		exchangeAllBttn.visible = false;
		bonusList.take();
		
		flyMaterial(e);
		
		//Делаем push в _6e
		if (App.social == 'FB') {
			ExternalApi.og('gather','collection');
		}
		
		App.user.stock.exchange(collection.sID, onExchangeResponse);
	}
	
	private function onExchangeAllEvent(e:MouseEvent):void {
		//exchangeBttn.state = Button.DISABLED;
		exchangeBttn.visible = false;
		exchangeAllBttn.visible = false;
		bonusList.take();
		
		flyMaterial(e);
		
		//Делаем push в _6e
		if (App.social == 'FB') {
			ExternalApi.og('gather','collection');
		}
		
		App.user.stock.exchange(collection.sID, onExchangeResponse, checkCount());
	}
	
	private function flyMaterial(e:MouseEvent):void {
		var point:Point = Window.localToGlobal(e.currentTarget);
		point.y += 20;
		
		for (var _sid:* in collection.reward) {
			var item:BonusItem = new BonusItem(_sid, collection.reward[_sid]);
			point.x += 80;
			item.cashMove(point, App.self.windowContainer);
		}
	}
	
	private function onExchangeResponse():void {
		exchangeBttn.state = Button.NORMAL;
		
		for each(var item:CollectionItem in items) {
			item.check();
		}
		
		if (App.user.stock.checkCollection(collection.sID)) {
			modeChange = true;
		}else {
			modeChange = false;
		}
		
		App.ui.rightPanel.update();
		
		window.contentChange();
	}
	
	private function checkCount():int {
		var cnt:int = items[0].count;
		for each(var item:CollectionItem in items) {
			if (item.count < cnt)
				cnt = item.count;
		}
		return cnt;
	}
}

import wins.GiftWindow;

internal class CollectionItem extends LayerX {
	
	public var background:Bitmap;
	public var bitmap:Bitmap;
	public var title:TextField;
	public var material:Object;
	public var sID:int;
	public var count:int;
	public var giftBttn:ImageButton;
	public var buyBttn:MoneySmallButton;
	public var wishlistBttn:ImageButton;
	public var countOnStock:TextField;
	public var window:*;
	
	private var mode:int;
	private var preloader:Preloader = new Preloader();
	private var locked:Boolean;
	private var findBttn:Button;
		
	public function CollectionItem(sID:int, window:*, mode:int = 0, locked:Boolean = false ) {
		
		this.sID = sID;
		this.window = window;
		this.mode = mode;
		this.locked = locked;
		background = Window.backing(130, 146, 10, "itemBacking");
		addChild(background);
		
		bitmap = new Bitmap(null, "auto", true);
		addChild(bitmap);
		
		material = App.data.storage[sID];
		
		title = Window.drawText(material.title, {
			color:0x814f31,
			borderColor:0xfaf9ec,
			fontSize:17,
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
		
		Load.loading(Config.getIcon('Material', material.view), onLoad);
		
		drawCount();

		function shuffle(a:*,b:*):int {
			var num : int = Math.round(Math.random()*2)-1;
			return num;
		}
	
		var cID:int = material['collection'];
		var places:Array = [];
		if (App.data.collectionIndex[cID] != undefined) {
			for each(var id:* in App.data.collectionIndex[cID]){
				places.push(id);
			}
			places = places.sort(shuffle);
		}
		
		tip = function():Object {
			var text:String = Locale.__e('flash:1383041279569');
			var titles:Array = [];
			var max:int = 5;
			for each(var id:* in places) {
				if(App.data.storage[id] != undefined) {
					if (User.inupdate.hasOwnProperty(id) && titles.indexOf(App.data.storage[id].title) == -1) {
						titles.push(App.data.storage[id].title);
						max--;
					}
					if (max <= 0) {
						break;
					}
				}
			}
			text += titles.join(', ');
			return {
				title:material['title'],
				text:text
			}
		}
	}
	
	private function drawButtons():void 
	{
		if (mode == CollectionWindow.COLLECTION_SHOP) {
			var bttnSettings:Object = {
				caption     :Locale.__e("flash:1382952379751"),
				width		:100,
				height		:38,	
				fontSize	:24,
				scale		:0.8,
				hasDotes    :false
			}
			bttnSettings['type'] = 'real';
			bttnSettings['countText'] = App.data.storage[sID].cost;
			bttnSettings["bgColor"] = [0xa9f84a, 0x73bb16];
			bttnSettings["borderColor"] = [0xffffff, 0xffffff];
			bttnSettings["bevelColor"] = [0xc5fe78, 0x405c1a];
			bttnSettings["fontColor"] = 0xffffff;				
			bttnSettings["fontBorderColor"] = 0x354321;
			bttnSettings['greenDotes'] = false;
				
				
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
			if(App.user.stock.count(Stock.FANT) < App.data.storage[sID].cost)
			{
				buyBttn.state = Button.DISABLED;
				buyBttn.mode = Button.DISABLED;
			}
		}else if(mode == CollectionWindow.PATHFINDER){
			findBttn = new Button( {
				caption:Locale.__e("flash:1382952380073"),
				fontSize:24,
				width:100,
				hasDotes:false,
				height:38
			});
			addChild(findBttn);
			findBttn.addEventListener(MouseEvent.CLICK, onFindAction);
		}else {
			wishlistBttn = new ImageButton(Window.textures.interAddBttnYellow);
			wishlistBttn.tip = function():Object { 
				return {
					title:"",
					text:Locale.__e("flash:1382952380013")
				};
			};
			addChild(wishlistBttn);
			wishlistBttn.addEventListener(MouseEvent.CLICK, onWishlistEvent);
			
			giftBttn = new ImageButton(Window.textures.giftBttn, { scaleX:1, scaleY:1 } );
			giftBttn.tip = function():Object { 
				return {
					title:"",
					text:Locale.__e("flash:1382952380012")
				};
			};
			addChild(giftBttn);
			giftBttn.addEventListener(MouseEvent.CLICK, onGiftBttnEvent);
		}
	}
	
	private function onFindAction(e:MouseEvent):void 
	{
		window.settings.target.work(sID);
		window.close();
	}
	
	private function onBuyAction(e:MouseEvent):void 
	{
		if (e.currentTarget.mode == Button.DISABLED) return;
		
		if (!App.user.stock.take(Stock.FANT, App.data.storage[sID].cost))
			return;
		
		if (!countOnStock)
			drawCount(true);
			
		count += 1;
		countOnStock.text = 'x' + count;
		
		App.user.stock.add(sID, 1);
		window.contentChange();
		
		window.contentChange();
		
		window.settings.target.onBuy(sID);
		
		var item:BonusItem = new BonusItem(sID, 1);
		var point:Point = Window.localToGlobal(buyBttn);
		item.cashMove(point, App.self.windowContainer);
	  
		Hints.plus(sID, 1, point, true, App.self.tipsContainer);
		Hints.minus(Stock.FANT, App.data.storage[sID].cost, point, false, App.self.tipsContainer);	
	}
	
	public var searchBttn:MoneyButton
	public function modeChanges():void {
		
		if (window.mode == CollectionWindow.SELECT_COLLECTION) {
			wishlistBttn.x = (background.width - wishlistBttn.width) / 2;
			giftBttn.visible = false;
		}
		
		if (window.mode == CollectionWindow.SELECT_ELEMENT) {
			wishlistBttn.x = (background.width - wishlistBttn.width) / 2;
			giftBttn.visible = false;
			
			searchBttn = new MoneyButton( {
					caption		:Locale.__e('flash:1382952380015'),
					width		:121,
					height		:37,	
					fontSize	:18,
					countText	:material.real,
					multiline	:true
			});
			addChild(searchBttn);
			searchBttn.x = (background.width - searchBttn.width) / 2;
			searchBttn.y = background.height + 10;
			
			searchBttn.addEventListener(MouseEvent.CLICK, onSearchBttn)
		}
		
	}
	
	private function onSearchBttn(e:MouseEvent):void
	{
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
		
		count = App.user.stock.count(sID);
		if (count == 0 && !ignore) return;
		
		var counterSprite:LayerX = new LayerX();
		counterSprite.tip = function():Object { 
			return {
				title:"",
				text:Locale.__e("flash:1382952380305")
			};
		};
		
		countOnStock = Window.drawText('x' + count, {
			color:0xffffff,
			borderColor:0x764a3e,
			fontSize:26,
			autoSize:"left"
		});
		
		addChild(counterSprite);
		counterSprite.x = background.width - counterSprite.width - 30;
		counterSprite.y = 129;
		
		addChild(countOnStock);
		countOnStock.x = counterSprite.x + (counterSprite.width - countOnStock.width) / 2 + 5;
		countOnStock.y = counterSprite.y - 36;
	}
	
	public function check():void {
		if (mode == CollectionWindow.PATHFINDER && locked == true) {
			bitmap.alpha = 0.4;
			var lockIcon:Bitmap = new Bitmap(Window.textures.bigLock);
			addChild(lockIcon);
			lockIcon.x = background.x + (background.width - lockIcon.width) / 2;
			lockIcon.y = background.y + (background.height - lockIcon.height) / 2;
			findBttn.mode = Button.DISABLED;
			findBttn.state = Button.DISABLED;
		}
		if (mode != 3 && mode != 4) 
		{
			wishlistBttn.y = background.height - wishlistBttn.height + 13;
			
			var count:uint = App.user.stock.count(sID);
			if (count == 0) {  
				bitmap.alpha = 0.4;
				giftBttn.visible = false;
				wishlistBttn.x = (background.width - wishlistBttn.width) / 2;
				
				if(countOnStock)
					countOnStock.text = "0";
			}else {
				bitmap.alpha = 1;
				giftBttn.visible = true;
				wishlistBttn.x = (background.width - (giftBttn.width + wishlistBttn.width)) / 2;
				giftBttn.y = wishlistBttn.y - 2;
				
				giftBttn.x = wishlistBttn.x + wishlistBttn.width + 5;
				
				if(countOnStock)
					countOnStock.text = 'x' + String(count);
			}
		}else {
			if (buyBttn != null) 
			{
				buyBttn.visible = true;
				buyBttn.x = (background.width - buyBttn.width) / 2;
				buyBttn.y = background.height - buyBttn.height + 13;
			}
			if (findBttn != null) {
				//if (exchangeBttn != null)
					//exchangeBttn.visible = null;
				findBttn.visible = true;
				findBttn.x = (background.width - findBttn.width) / 2;
				findBttn.y = background.height - findBttn.height + 13;
			}
		}
	}
	
	private function onWishlistEvent(e:MouseEvent):void {
		App.wl.show(sID, e);
	}
	
	private function onGiftBttnEvent(e:MouseEvent):void {
		window.close();
		new GiftWindow( {
			iconMode:GiftWindow.COLLECTIONS,
			itemsMode:GiftWindow.FRIENDS,
			sID:sID
		}).show();
	}
	
	public function dispose():void {
		if (mode == 0) 
		{
			wishlistBttn.removeEventListener(MouseEvent.CLICK, onWishlistEvent);
			giftBttn.removeEventListener(MouseEvent.CLICK, onGiftBttnEvent);
		}
		
		if(searchBttn) searchBttn.removeEventListener(MouseEvent.CLICK, onSearchBttn);
	}
	
	
}