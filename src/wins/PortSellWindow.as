package wins 
{
	import buttons.Button;
	import com.flashdynamix.motion.extras.BitmapTiler;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	/**
	 * ...
	 * @author 
	 */
	public class PortSellWindow extends Window
	{
		public static const NUM_BUSKETS:int = 3;
		
		public var headerBackingTexture:String = 'tradingPostBackingMainHeader';
		
		public var titleBacking:Bitmap;
		
		public var stockMenu:StockMenu;
		public var sellMenu:SellMenu;
		public var basketMenu:BasketMenu;
		
		public var sellBttn:Button;
		
		public var shipId:int;
		
		public function PortSellWindow(shipId:int, settings:Object) 
		{
			if (settings == null) {
				settings = new Object();
			}
			
			this.shipId = shipId;
			
			settings['width']			= 740; 
			settings['height']			= 395;
			
			//settings['hasPaginator']	= false;
			settings["hasArrows"] 		= false;
			settings["hasButtons"] 		= false;
			settings['content']			= [];
			
			settings['title']			= Locale.__e('flash:1382952380091');
			settings['background']		= 'tradepostBacking';
			super(settings);
		}
		
		private var marginYTitle:int = 36;
		private var marginY:int = 30;
		override public function drawBackground():void
		{
			var upperBack:Bitmap = Window.backing(445, 445, 20, "tradepostBacking");
			layer.addChild(upperBack);
			upperBack.x += 170;
			upperBack.y -= 100;
			
			background = backing(740,395,10,"tradepostBacking");
			layer.addChild(background);
			background.x = upperBack.x + (upperBack.width - background.width) / 2;
			background.y += 60;
		}
		override public function drawBody():void 
		{
			titleLabel.y -= 100;
			titleLabel.x += 20;
			
			exit.y += 35;
			exit.x += 25;
			
			this.y += marginY;
			fader.y -= marginY;
			
			var mirrorsSpace1:int = -22;
			var mirrorsSpace2:int = 74;
			var titleBackY:int = -110;
			var titleBackWidth:int = 510;
			
			drawMirrowObjs('diamondsTop', settings.width / 2 - settings.titleWidth / 2 + 15, settings.width / 2 + settings.titleWidth / 2 + 25, -210, true, true);
			
			
			basketMenu = new BasketMenu(this, NUM_BUSKETS);
			bodyContainer.addChild(basketMenu);
			basketMenu.x = (settings.width - basketMenu.width) / 2;
			basketMenu.y = -100 - marginYTitle;
			
			stockMenu = new StockMenu(this);
			bodyContainer.addChild(stockMenu);
			stockMenu.x = 60;
			stockMenu.y = settings.height - stockMenu.height - 50 - marginY - marginYTitle;
			
			sellMenu = new SellMenu(this);
			bodyContainer.addChild(sellMenu);
			sellMenu.x = settings.width - sellMenu.width - 25;
			sellMenu.y = settings.height - sellMenu.height - 50;
			
			drawBttn();
		}
		
		private function drawBttn():void 
		{
			sellBttn = new Button( {
				caption:	Locale.__e("flash:1382952380137"),
				width:		184,
				height:		58,
				fontSize:	30
			});
			
			sellBttn.x = (settings.width - sellBttn.width) / 2 + 20;
			sellBttn.y = settings.height - sellBttn.height/2 - 50;
			bodyContainer.addChild(sellBttn);
			
			sellBttn.addEventListener(MouseEvent.CLICK, onSell);
			
			sellBttn.state = Button.DISABLED;
		}
		
		private function onSell(e:MouseEvent):void 
		{
			if (sellBttn.mode == Button.DISABLED)
				return;
				
			var data:Array = [];
			
			for (var i:int = 0; i < basketMenu.items.length; i++ ) {
				
				var item:BasketItem = basketMenu.items[i];
				
				if(!item.isEmpty){
					var obj:Object = { };
					obj['idslot'] = i;
					obj['sid'] = item.sid;
					obj['price'] = item.price;
					obj['count'] = item.count;
					obj['pid'] = Stock.COINS;
					obj['sold'] = 0;
					
					data.push(obj);
				}
			}
			
			close();
			settings.onSell(shipId, data);
		}
		
		public function canTrade():Boolean
		{
			var canTrade:Boolean = true;
			
			if (basketMenu.countItems >= NUM_BUSKETS)
				canTrade = false;
				
			return canTrade;
		}
		
		//public function drawTitleBacking(positionY:int, currWidth:int = 440):Bitmap 
		//{
			//var upperBack:Bitmap = Window.backing(445, 445, 20, "tradepostBacking");
			////var headerBackingLeft:Bitmap = new Bitmap(textures[headerBackingTexture], 'auto', true);
			////var headerBackingCenter:Bitmap;
			////var bmd:BitmapData = new BitmapData(1, headerBackingLeft.height, true, 0);
			////var headerBackingRight:Bitmap = new Bitmap(textures[headerBackingTexture]);
			////
			////bmd.copyPixels(headerBackingLeft.bitmapData, new Rectangle(headerBackingLeft.width - 1, 0, headerBackingLeft.width, headerBackingLeft.height), new Point());
			////headerBackingCenter = new Bitmap(bmd);
			////
			////if (currWidth < headerBackingLeft.width + headerBackingRight.width)
				////currWidth = headerBackingLeft.width + headerBackingRight.width;
				////
			////headerBackingRight.scaleX = -1;
			////headerBackingRight.x = currWidth;
			////
			////headerBackingCenter.x = headerBackingLeft.x + headerBackingLeft.width;
			////headerBackingCenter.width = currWidth - headerBackingLeft.width - headerBackingRight.width;
			////
			//var _titleBacking:Sprite = new Sprite();
			////_titleBacking.addChild(upperBack);
			////_titleBacking.addChild(headerBackingCenter);
			////_titleBacking.addChild(headerBackingRight);
			//_titleBacking.x = int((settings.width - currWidth) * 0.5);
			//_titleBacking.y = positionY;
			////
			//var result:BitmapData = new BitmapData(_titleBacking.width, _titleBacking.height, true, 0);
			//result.draw(_titleBacking);
			//
			//return new Bitmap(result);
		//}
		
		public function refreshSellMenu():void
		{
			sellMenu.change(stockMenu.focusItemId);
		}
		
		override public function dispose():void {
			
			sellMenu.dispose();
			basketMenu.dispose();
			stockMenu.dispose();
			
			super.dispose();
		}
		
	}

}



import buttons.Button;
import buttons.ImageButton;
import buttons.PageButton;
import com.greensock.TweenLite;
import com.greensock.TweenMax;
import core.Load;
import flash.display.Bitmap;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.filters.GlowFilter;
import flash.geom.Point;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.utils.clearInterval;
import flash.utils.setInterval;
import ui.Cursor;
import ui.UserInterface;
import ui.WishList;
import units.Field;
import units.Unit;
import units.WorkerUnit;
import wins.Paginator;
import wins.Window;
import wins.WindowEvent;
import silin.filters.ColorAdjust;

internal class StockMenu extends Sprite {
	
	public var textLabel:TextField;
	public var icon:Bitmap;
	public var order:int = 0;
	public var title:String = "";
	public var selected:Boolean = false;
	public var window:PortSellWindow;
	
	
	public var items:Vector.<StockItem> = new Vector.<StockItem>();
	
	public var topCont:Sprite = new Sprite();
	public var botCont:Sprite = new Sprite();
	
	private var background:Bitmap;
	
	
	public var paginator:Paginator = null;	
	
	public var settings:Object = { };
	public var sections:Object = { };
	
	public var focusItem:StockItem;
	public var focusItemId:int = 0;
	
	public function StockMenu(window:PortSellWindow) {
		
		this.window = window;
			
		settings["section"] = "all"; 
		settings['content'] = { };
		settings['itemsOnPage'] = 6;
		
		settings['height'] = 320;
		settings['width'] = 448;
		
		createContent();
		
		addChild(botCont);
		addChild(topCont);
		
		createPaginator();
		drawArrows();
		
		drawBody();
		
		setContentSection(settings.section,settings.page);
		contentChange();
	}
	
	public function refresh(e:AppEvent = null):void // повесить на StockChange
	{
		setContentSection(settings.section,settings.page);
		
		for (var i:int = 0; i < settings.content.length; i++)
		{
			if (App.user.stock.count(settings.content[i].sid) == 0)
			{
				settings.content.splice(i, 1);
			}
		}
		
		//paginator.itemsCount = settings.content.length;
		//paginator.update();
		contentChange();
	}

	public function createContent():void {
			
		if (sections["all"] != null) return;
		
		sections = {
			"all":{items:new Array(),page:0},
			"harvest":{items:new Array(),page:0},
			"jam":{items:new Array(),page:0},
			"materials":{items:new Array(),page:0},
			"workers":{items:new Array(),page:0},
			"others":{items:new Array(),page:0}
		};
		
		var section:String = "all";
		
		for(var ID:* in App.user.stock.data) {
			var count:int = App.user.stock.data[ID];
			var item:Object = App.data.storage[ID];
			if(item == null)	continue;
			if (count < 1) 		continue;
			
			
			if (notShow(ID)) continue;
			
			switch(item.type){
				case 'Material':
			
					if (item.cost == 0)
						continue;
					
					if (item.mtype == 0) {
						section = "materials";
					}else if (item.mtype == 1) {
						section = "harvest";
					}else if (item.mtype == 3 || item.mtype == 4) {
						continue;
					}else{
						section = "others";
					}
					break;
				case 'Jam':
				case 'Clothing':
				case 'Lamp':
				case 'Guide':
				case 'Etherplant':
						continue;
					break;
				default:
					//section = "others";
					continue;
					break;	
			}
			
			item["sid"] = ID;
			sections[section].items.push(item);
			sections["all"].items.push(item);
		}
	}
	
	private function notShow(sID:int):Boolean 
	{
		switch(sID) {
			case 161:
			case 823:
			case 839:
					return true;
				break;
		}
		
		return false;
	}
	
	private function drawBody():void 
	{
		//background = Window.backing(200, 272, 10, "itemBacking");
		//background.smoothing = true;
		//botCont.addChild(background);
		//var bg:Bitmap = Window.backing(740, 395, 10, "tradepostBacking");
		//bg.smoothing = true;
		//botCont.addChild(bg);
		//background = Window.backing(settings.width, settings.height, 42, "tradePostBackingSmall");
		//botCont.addChild(background);
		
	}
	
	private function createPaginator():void 
	{	
		paginator = new Paginator(settings.content.length || 10, settings.itemsOnPage, 9, { hasButtons:false } );
		paginator.hasButtons = false;
		paginator.buttonsCount = 0;
		paginator.x = int((settings.width - paginator.width)/2);
		paginator.y = int(settings.height - paginator.height - 46);
		
		paginator.addEventListener(WindowEvent.ON_PAGE_CHANGE, contentChange);
					
		topCont.addChild(paginator);
	}
	
	private function drawArrows():void 
	{
		paginator.drawArrow(topCont, Paginator.LEFT,  0, 0, { scaleX: -0.8, scaleY:0.8 } );
		paginator.drawArrow(topCont, Paginator.RIGHT, 0, 0, { scaleX:0.8, scaleY:0.8 } );
		
		var y:Number = (settings.height - paginator.arrowLeft.height) / 2;
		paginator.arrowLeft.x = -paginator.arrowLeft.width/2 + 28;
		paginator.arrowLeft.y = y;
		
		paginator.arrowRight.x = settings.width-paginator.arrowRight.width/2 - 15;
		paginator.arrowRight.y = y;
	}
		
	public function setContentSection(section:*, page:int = -1):Boolean 
	{
		if (sections.hasOwnProperty(section)) {
			settings.section = section;
			settings.content = [];
			
			var arr:Vector.<BasketItem> = window.basketMenu.items;
			
			for (var i:int = 0; i < sections[section].items.length; i++)
			{
				var sID:uint = sections[section].items[i].sid;
				
				var count:int = App.user.stock.count(sID);
				
				for (var j:int = 0; j < arr.length; j++ ) {
					if (arr[j].sid == sID) {
						count -= arr[j].count;
					}
				}
				
				if (count > 0 && App.data.storage[sID].mtype != 5)
					settings.content.push(sections[section].items[i]);
				else if (focusItem && focusItem.sid == sID) {
					focusItemId = 0;
					focusItem = null;
				}
			}
			
			paginator.page = page == -1 ? sections[section].page : page;
			paginator.itemsCount = settings.content.length;
			paginator.update();
			
		}else {
			return false;
		}
		
		contentChange();	
		
		return true
	}
	
	public function contentChange(event:* = null):void 
	{
		for each(var _item:StockItem in items) {
			botCont.removeChild(_item);
			_item.dispose();
			_item = null;
		}
		
		items = new Vector.<StockItem>();
		var X:int = 16;
		var Xs:int = 16;
		var Ys:int = 17;
		
		var itemNum:int = 0;
		for (var i:int = paginator.startCount; i < paginator.finishCount; i++){
			
			var item:StockItem = new StockItem(settings.content[i], this);
			
			botCont.addChild(item);
			item.x = Xs;
			item.y = Ys;
			
			if (focusItemId == item.sid)
				item.setInFocus();
				
			items.push(item);
			Xs += item.background.width+10;
			if (itemNum == int(settings.itemsOnPage / 2) - 1)	{
				Xs = X;
				Ys += item.background.height+12;
			}
			itemNum++;
		}
		
		sections[settings.section].page = paginator.page;
		settings.page = paginator.page;
	}
	
	
	public function dispose():void 
	{
		if (paginator != null) {
			paginator.dispose();
			paginator = null;
		}
		
		for (var i:int = 0; i < items.length; i++ ) {
			items[i].dispose();
			items[i] = null;
		}
		items.splice(0, items.length);
		items = null;
		
		focusItem = null;
		
		window = null;
	}
	
	public function removeFocus():void
	{
		if (focusItem) {
			focusItem.isFocused = false;
			TweenMax.to(focusItem, 0.1, { glowFilter: { remove:true }, x:focusItem.x + 6, y:focusItem.y + 6, scaleX:1, scaleY:1 } );
			
			focusItem.drawBg();
		}
	}
}



import wins.GiftWindow;
import wins.RewardWindow
import wins.SimpleWindow;
import wins.StockDeleteWindow;

internal class StockItem extends Sprite {
	
	private static const ITEM_SCALE:Number = 1.1;
	
	public var item:*;
	public var background:Bitmap;
	public var bitmap:Bitmap;
	public var title:TextField;
	public var window:StockMenu;
	
	private var preloader:Preloader = new Preloader();
	
	public var isFocused:Boolean = false;
	
	public var sid:int;
	
	public function StockItem(item:*, window:StockMenu):void {
		
		this.item = item;
		this.window = window;
		this.sid = item.sid;
		
		background = Window.backing(132, 136, 40, "itemBacking");
		addChild(background);
		
		var sprite:LayerX = new LayerX();
		addChild(sprite);
		
		bitmap = new Bitmap();
		sprite.addChild(bitmap);
		
		sprite.tip = function():Object { 
			return {
				title:item.title,
				text:item.description
			};
		};
		
		addChild(preloader);
		preloader.x = background.width / 2;
		preloader.y = background.height / 2;
		
		Load.loading(Config.getIcon(item.type, item.preview), onPreviewComplete);
			
		drawCount();
		
		addEventListener(MouseEvent.CLICK, onClick);
	}
	
	public function refresh():void
	{
		drawCount();
	}
	
	public function dispose():void 
	{
		window = null;
		
		removeEventListener(MouseEvent.CLICK, onClick);
	}
	
	private function onClick(e:MouseEvent):void 
	{
		setInFocus();
		
		if(window.window.canTrade())
			window.window.refreshSellMenu();
	}
	
	private var focusColor:int = 0xdede09;
	public function setInFocus():void
	{
		if(!isFocused){
			isFocused = true;
			window.removeFocus();
			window.focusItem = this;
			window.focusItemId = item.sid;
			
			var pnt:Point = new Point(this.x, this.y);
			TweenMax.to(this, 0.1, { glowFilter: { color:focusColor, alpha:1, blurX:5, blurY:5, strength:18 }, x:pnt.x - 6, y:pnt.y - 6, scaleX:ITEM_SCALE, scaleY:ITEM_SCALE } );
			
			drawBg(true);
		}
	}
	
	public function drawBg(clicked:Boolean = false):void
	{
		var bg:Bitmap;
		
		if (clicked) 
			bg = Window.backing(132, 136, 40, 'shopSpecialBacking');
		else 
			bg = Window.backing(132, 136, 40, 'itemBacking');
		
		background.bitmapData = bg.bitmapData;
		background.smoothing = true;
	}
	
	private var countOnStock:TextField = null;
	private function drawCount():void {
		
		if (countOnStock) {
			countOnStock.parent.removeChild(countOnStock);
			countOnStock = null;
		}
		
		var count:int = App.user.stock.data[item.sid];
		var arr:Vector.<BasketItem> = window.window.basketMenu.items;
		
		for (var i:int = 0; i < arr.length; i++ ) {
			if (arr[i].sid == sid) {
				count -= arr[i].count;
			}
		}
		
		countOnStock = Window.drawText('x' + count, {
			color:0xefcfad9,
			borderColor:0x764a3e,  
			fontSize:28,
			autoSize:"left"
		});
		
		var width:int = countOnStock.width + 24 > 30?countOnStock.width + 24:30;
		
		addChild(countOnStock);
		countOnStock.x = background.width - countOnStock.width - 16;
		countOnStock.y = background.height - countOnStock.height - 14;
	}
	
	private function onPreviewComplete(data:Bitmap):void
	{
		removeChild(preloader);
		
		bitmap.bitmapData = data.bitmapData;
		bitmap.scaleX = bitmap.scaleY = 0.8;
		bitmap.smoothing = true;
		bitmap.x = (background.width - bitmap.width) / 2;
		bitmap.y = (background.height - bitmap.height) / 2;
	}
	
	private function glowing():void {
		customGlowing(background, glowing);
	}
	
	private function customGlowing(target:*, callback:Function = null):void {
		TweenMax.to(target, 1, { glowFilter: { color:0xFFFF00, alpha:0.8, strength: 7, blurX:12, blurY:12 }, onComplete:function():void {
			TweenMax.to(target, 0.8, { glowFilter: { color:0xFFFF00, alpha:0.6, strength: 7, blurX:6, blurY:6 }, onComplete:function():void {
				if (callback != null) {
					callback();
				}
			}});	
		}});
	}	
}


import ui.UserInterface;

internal class SellMenu extends Sprite
{
	public var info:Object;
	public var win:PortSellWindow;
	public var bitmap:Bitmap;
	public var title:TextField;
	public var countText:TextField;
	public var stockCountText:TextField;
	public var emptyText:TextField;
	public var ID:*;
	
	public var count:uint = 0;
	public var priceSetter:PriceSetter = null;
	
	public var bttnOnSell:Button;
	
	private var plus:PageButton;
	private var minus:PageButton;
	private var _counter:Sprite;
	private var stockCountBg:Bitmap;
	private var stockCount:uint = 0;
	
	private var preloader:Preloader = new Preloader();
	
	private var background:Bitmap;
	
	
	public function SellMenu(window:PortSellWindow)
	{
		win = window;
		
		background = Window.backing(170, 170, 35, 'shopBackingSmall2');
		addChild(background);
		
		bitmap = new Bitmap();
		addChild(bitmap);
		
		//title = Window.drawText("", {
			//color:0xffffff,
			//borderColor:0x56351b,
			//textAlign:"center",
			//autoSize:"center",
			//fontSize:24,
			//multiline:true
		//});
		//
		//title.wordWrap = true;
		//title.width = 150;
		
		drawEmptyText();
			
		drawCounter();
		
		//addChild(title);
		
		drawPrice();
		
		drawBttn();
	}
	
	private function drawEmptyText():void 
	{
		emptyText =  Window.drawText(Locale.__e("flash:1407840280321"), {
				color:0xf2e5b6,
				fontSize:30,
				borderColor:0x2b3b64,
				borderSize:0,
				autoSize:"center",
				textAlign:"center"
			}
		);
		emptyText.wordWrap = true;
		emptyText.width = background.width - 30;
		emptyText.x = (background.width - emptyText.width) / 2;
		emptyText.y = (background.height - emptyText.height) / 2;
		addChild(emptyText);
	}
	
	private function drawBttn():void 
	{
		bttnOnSell = new Button( {
			caption:	Locale.__e("flash:1407840351335"),
			width:		166,
			height:		50,
			fontSize:	30
		});
		
		bttnOnSell.x = (background.width - bttnOnSell.width) / 2;
		bttnOnSell.y = priceSetter.y + priceSetter.height + 10;
		addChild(bttnOnSell);
		
		bttnOnSell.addEventListener(MouseEvent.CLICK, addToBasket);
		
		bttnOnSell.state = Button.DISABLED;
	}
	
	private function drawPrice():void 
	{
		priceSetter = new PriceSetter(this);
		priceSetter.x = (background.width - priceSetter.width) / 2 + 8;
		priceSetter.y = background.height + 14;
		addChild(priceSetter);
	}
	
	private function drawCounter():void
	{
		_counter = new Sprite();
		
		var bttnsSettings:Object = {
			caption:'+', 
			height:25,
			bevelColor:[0xfff17f, 0xb37c22],
			bgColor:[0xf4ce55, 0xefb635],
			borderColor:[0x6e7050, 0x6e6e4f],
			fontColor:0xffffff,
			fontBorderColor:0x814f31,
			active:{
				bgColor:				[0xefb635,0xc88d09],
				borderColor:			[0x8b7a51,0x8b7a51],	
				bevelColor:				[0xbf7e1a,0x905904],	
				fontColor:				0xffffff,				
				fontBorderColor:		0x48597c				
			}
		}
		
		plus = new PageButton( bttnsSettings);
		bttnsSettings["caption"] = '-';
		minus = new PageButton( bttnsSettings);
		
		plus.addEventListener(MouseEvent.CLICK, onPlus);
		minus.addEventListener(MouseEvent.CLICK, onMinus);
		
		minus.x = -minus.width - 22;
		plus.x = 22;
		minus.y = -30;
		plus.y = -30;
		
		var countBg:Sprite = new Sprite();
		countBg.graphics.beginFill(0xbd9a5d);
        countBg.graphics.drawCircle(18, 18, 18);
        countBg.graphics.endFill();
		countBg.x =	-countBg.width/2;
		countBg.y = -37;
		
		_counter.visible = false;
		
		countText = Window.drawText("", {
				color:0xffffff,
				fontSize:24,
				borderColor:0x633e19,
				autoSize:"center"
			}
		);
			
		countText.x = countBg.x + (countBg.width + countText.textWidth)/2 - 13;
		countText.y = countBg.y + (countBg.height + countText.textHeight)/2 - 13;
		countText.width = countBg.width - 10;
		
		stockCountBg = new Bitmap(Window.textures['itemNumRoundBakingLight']);//new Sprite();
        //stockCountBg.graphics.beginFill(0xc7b362);
        //stockCountBg.graphics.drawCircle(23, 33, 20);
        //stockCountBg.graphics.endFill();
		stockCountBg.x = background.width - stockCountBg.width + 1;
		stockCountBg.y = -4;
		
		stockCountText = Window.drawText("", {
				color:0xffffff,
				fontSize:24,
				borderColor:0x855729,
				autoSize:"center"
			}
		);	
			
		stockCountText.x = stockCountBg.x + (stockCountBg.width + stockCountText.textWidth) / 2 - 2;
		stockCountText.y = stockCountBg.y + (stockCountBg.height + stockCountText.textHeight) / 2 - 14;
		
		counter = false;
		
		_counter.addChild(countBg);
		_counter.addChild(plus);
		_counter.addChild(minus);
		_counter.addChild(countText);
		
		addChild(_counter);
			
		
		_counter.x = background.width / 2;
		_counter.y = background.height - 9;
		
		
		addChild(stockCountBg);
		addChild(stockCountText);
	}
	
	public function change(data:*):void
	{
		emptyText.visible = false;
		bitmap.visible = true;
		//title.visible = true;
		_counter.visible = true;
		
		this.ID = data;
		info = App.data.storage[ID];
		//title.text = info.title;
		
		addChild(preloader);
		preloader.x = 100;
		
		preloader.y = 85;
		
		Load.loading(Config.getIcon(info.type, info.preview), onLoad);
		
		
		stockCount = App.user.stock.data[ID];
		
		var arr:Vector.<BasketItem> = win.basketMenu.items;
		
		for (var i:int = 0; i < arr.length; i++ ) {
			if (arr[i].sid == ID) {
				stockCount -= arr[i].count;
			}
		}
		
		
		if (stockCount <= 0)
			makeEmpty();
		
/*		if (App.social == 'FB')
			count = 0;
		else
*/			count = 1;
		
		counter = true;
		refreshCounters(true);
		
		//title.x = (background.width - title.width) / 2;
		//title.y = 6;
	}
	
	public function makeEmpty():void
	{
		emptyText.visible = true;
		bitmap.visible = false;
		//title.visible = false;
		_counter.visible = false;
		stockCountBg.visible = false;
		stockCountText.visible = false;
		
		if (win.canTrade())
			emptyText.text = Locale.__e('flash:1407829337190');
		else
			emptyText.text = Locale.__e('flash:1401373627393');
		
		priceSetter.setPrice(0, 0, true);
		
		bttnOnSell.state = Button.DISABLED;
	}
		
	public function onLoad(data:Bitmap):void
	{
		if(contains(preloader)){
			removeChild(preloader);
		}
		
		bitmap.bitmapData = data.bitmapData;
		bitmap.x = (background.width - bitmap.width) / 2;								
		bitmap.y = (background.height - bitmap.height) / 2 - 10;
	}
	
	private function set counter(value:Boolean):void
	{
		if (value){
			//_counter.visible 		= true;
			stockCountText.visible 	= true;
			stockCountBg.visible 	= true;
		}else{
			//_counter.visible 		= false;
			stockCountText.visible 	= false;
			stockCountBg.visible 	= false;
		}
	}
	
	public function onPlus(e:MouseEvent = null):void
	{
		if (e.currentTarget.mode == Button.DISABLED) return;
		
		if (stockCount - count - 1 >= 0)
		{
			count		+= 1;
			refreshCounters();
		}
	}
	
	public function onMinus(e:MouseEvent = null):void
	{
		if (e.currentTarget.mode == Button.DISABLED) return;
		
		if (count - 1 >= 0)
		{
			count		-= 1;
			refreshCounters();
		}
	}
	
	private function refreshCounters(isNew:Boolean = false):void
	{
		if (count == 1) 			minus.state = Button.DISABLED;
		else 						minus.state = Button.NORMAL;
		
		if (count == stockCount || count >= 10) 	plus.state = Button.DISABLED;
		else	 									plus.state = Button.NORMAL;
		
		countText.text 		= String(count);
		stockCountText.text = String(stockCount - count);
		
		if (stockCount - count <= 0 || _counter.visible == false) {
			stockCountText.visible 	= false;
			stockCountBg.visible 	= false;
		}
		else
		{
			stockCountText.visible 	= true;
			stockCountBg.visible 	= true;
		}
		
		if (stockCount > 0) {
			bttnOnSell.state = Button.NORMAL;
			priceSetter.setPrice(info.cost, count, isNew);
		}
	}
	
	private function addToBasket(e:MouseEvent):void 
	{
		if (bttnOnSell.mode == Button.DISABLED)
			return;
		
		var data:Object = { 
			price:priceSetter.price,
			count:count,
			preview:info.preview,
			type:info.type,
			sid:info.sid
		};
		
		win.basketMenu.addItem(data);
		win.stockMenu.setContentSection("all");
		
		if (win.canTrade())
			win.sellMenu.change(info.sid);
		else
			win.sellMenu.makeEmpty();
	}
	
	public function dispose():void
	{
		if(plus){
			plus.removeEventListener(MouseEvent.CLICK, onPlus);
			plus.dispose();
		}
		if(minus){
			minus.removeEventListener(MouseEvent.CLICK, onMinus);
			minus.dispose();
		}
		
		plus = null;
		minus = null;
		
		if(priceSetter)
			priceSetter.dispose();
		priceSetter = null;
		
		win = null;
	}
}


internal class PriceSetter extends Sprite {
	
	public var price:int = 0;
	
	private var bgPrice:Bitmap;
	
	private var plus:PageButton;
	private var minus:PageButton;
	
	private var priceCountText:TextField;
	
	private var minPrice:int = 0;
	private var maxPrice:int = 0;
	
	private var window:SellMenu;
	
	public function PriceSetter(window:SellMenu):void {
		this.window = window;
		
		//bgPrice = Window.backingShort(120, "greyPiece");
		bgPrice = new Bitmap(Window.textures.portCoinsBack);
		//bgPrice = Window.backing(117,53,10,"portCoinsBack");
		addChild(bgPrice);
		
		drawBttns();
		drawCountText();
	}
	
	private function drawCountText():void 
	{
		var icon:Bitmap = new Bitmap(UserInterface.textures.coinsIcon);
		icon.y = bgPrice.y + (bgPrice.height - icon.height) / 2;
		icon.x = bgPrice.x - icon.width / 2 + 10;
		addChild(icon);
		
		priceCountText = Window.drawText(String(price) , {
				color:0xfedb38,
				fontSize:40,
				borderColor:0x684e1e,
				autoSize:"center"
			}
		);
		addChild(priceCountText);
		priceCountText.x = bgPrice.x + (bgPrice.width - priceCountText.width) / 2 + 4;
		priceCountText.y = bgPrice.y + (bgPrice.height - priceCountText.height) / 2 + 3;
	}
	
	private function drawBttns():void 
	{
		var bttnsSettings:Object = {
			caption:'+', 
			height:25,
			bevelColor:[0xfff17f, 0xb37c22],
			bgColor:[0xf4ce55, 0xefb635],
			borderColor:[0x6e7050, 0x6e6e4f],
			fontColor:0xffffff,
			fontBorderColor:0x814f31,
			active:{
				bgColor:				[0xefb635,0xc88d09],
				borderColor:			[0x8b7a51,0x8b7a51],	
				bevelColor:				[0xbf7e1a,0x905904],	
				fontColor:				0xffffff,				
				fontBorderColor:		0x48597c				
			}
		}
		
		plus = new PageButton( bttnsSettings);
		bttnsSettings["caption"] = '-';
		minus = new PageButton( bttnsSettings);
		
		plus.addEventListener(MouseEvent.MOUSE_DOWN, onPlus);
		minus.addEventListener(MouseEvent.MOUSE_DOWN, onMinus);
		
		plus.state = Button.DISABLED;
		minus.state = Button.DISABLED;
		
		plus.x = bgPrice.width + 2;
		plus.y = 1;
		
		minus.x = bgPrice.width + 2;
		minus.y = plus.y + plus.height + 2;
		
		addChild(plus);
		addChild(minus);
		
		App.self.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
	}
	
	private var timeChange:int = 100;
	private var koefChange:int = 2;
	private var intervalPlus:int;
	private var intervalMinus:int;
	private function onMouseUp(e:MouseEvent):void 
	{
		clearInterval(intervalPlus);
		clearInterval(intervalMinus);
		timeChange = 100;
	}
	
	private function onMinus(e:MouseEvent = null):void 
	{
		if (minus.mode == Button.DISABLED) return;
		
		if (price > minPrice)
		{
			price -= 1;
			onCountChange(false);
		}
	}
	
	private function onPlus(e:MouseEvent = null):void 
	{
		if (plus.mode == Button.DISABLED) return;
		
		if (price < maxPrice)
		{
			price += 1;
			onCountChange(true);
		}
	}
	
	private function onCountChange(isPlus:Boolean):void
	{
		clearInterval(intervalPlus);
		clearInterval(intervalMinus);
		
		update();
		updateBttns();
		
		if (isPlus) {
			intervalPlus = setInterval(onPlus, timeChange);
		}else {
			intervalMinus = setInterval(onMinus, timeChange);
		}
		
		timeChange -= koefChange;
		if (timeChange < 1)
			timeChange = 1;
	}
	
	private function updateBttns():void
	{
		if (price == maxPrice) {
			clearInterval(intervalPlus);
			plus.state = Button.DISABLED;
		}
		else 
			plus.state = Button.NORMAL;
			
		if (price == minPrice) {
			clearInterval(intervalMinus);
			minus.state = Button.DISABLED;
		}
		else 
			minus.state = Button.NORMAL;
	}
	
	private var currCount:int = 0;
	public function setPrice(itemPrice:int, count:int, isNew:Boolean = false):void
	{
		//price = value;
		//
		//minPrice = Math.floor(value - value/5);
		//maxPrice = Math.ceil(value + value/2);
		
		if (isNew) {
			currCount = count;
			price = itemPrice * count;
			minPrice = Math.floor(price - price/5);
			maxPrice = Math.ceil(price + price/2);
		}else {
			price = price / currCount * count;
			
			var averadgePrice:int = itemPrice * count; 
			minPrice = Math.floor(averadgePrice - averadgePrice/5);
			maxPrice = Math.ceil(averadgePrice + averadgePrice / 2);
			
			currCount = count;
		}
		
		if (itemPrice > 0 && minPrice < 1)
			minPrice = 1;
			
		if (price > maxPrice)
			price = maxPrice;
			
		if (price < minPrice) {
			price = minPrice;
		}
		
		update();
		updateBttns();
	}
	
	public function update():void
	{
		priceCountText.text = String(price);
	}
	
	public function dispose():void 
	{
		clearInterval(intervalPlus);
		clearInterval(intervalMinus);
		
		App.self.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		plus.removeEventListener(MouseEvent.MOUSE_DOWN, onPlus);
		minus.removeEventListener(MouseEvent.MOUSE_DOWN, onMinus);
		
		plus.dispose();
		minus.dispose();
		
		plus = null;
		minus = null;
		
		window = null;
	}
}

import wins.PortSellWindow;

internal class BasketMenu extends Sprite {
	
	public var window:PortSellWindow;
	
	public var countItems:int;
	
	public var items:Vector.<BasketItem> = new Vector.<BasketItem>;
	
	public function BasketMenu(window:PortSellWindow, numItems:int = 3):void {
		this.window = window;
		
		createItems(numItems);
	}
	
	private function createItems(numItems:int):void 
	{
		var posX:int = 30;
		var posY:int = -20;
		var marginX:int = 2;
		
		for (var i:int = 0; i < numItems; i++ ) {
			var item:BasketItem = new BasketItem(this, i+1);
			items.push(item);
			
			item.x = posX;
			item.y = posY;
			addChild(item);
			
			posX += item.width + 4;// - 30;
		}
	}
	
	public function addItem(data:Object):void
	{
		window.sellBttn.state = Button.NORMAL;
		
		countItems++;
		
		for (var i:int = 0; i < items.length; i++ ) {
			if (items[i].isEmpty) {
				items[i].change(data);
				break;
			}	
		}
	}
	
	public function checkEmpty():Boolean
	{
		var empty:Boolean = true;
		
		for (var i:int = 0; i < items.length; i++ ) {
			if (!items[i].isEmpty) {
				empty = false;
				break;
			}	
		}
		
		return empty;
	}
	
	public function removeItem():void
	{
		countItems--;
	}
	
	public function dispose():void
	{
		for (var i:int = 0; i < items.length; i++ ) {
			items[i].dispose();	
			items[i] = null;
		}
		items.splice(0, items.length);
		items = null;
		
		window = null;
	}
	
}


internal class BasketItem extends Sprite {
	
	public var isEmpty:Boolean = true;
	
	public var sid:int;
	public var id:int;
	
	private var window:BasketMenu;
	private var item:Object;
	
	private var icon:Bitmap;
	private var background:Bitmap;
	
	private var descTxt:TextField;
	private var priceTxt:TextField;
	private var countTxt:TextField;
	
	private var countCont:Sprite = new Sprite();
	
	private var closeBttn:ImageButton;
	
	private var preloader:Preloader = new Preloader();
	
	public var price:int;
	public var count:int;
	
	public function BasketItem(window:BasketMenu, id:int):void {
		this.window = window;
		
		this.id = id;
		
		drawBackground();
		
		icon = new Bitmap();
		icon.smoothing = true;
		addChild(icon);
		
		drawDesc();
		drawPrice();
		drawCloseBttn();
	}
	
	private function drawBackground():void 
	{
		background = Window.backing(107, 115, 10, 'shopBackingSmall2');
		addChild(background);
		//background.x += 40;
		//background.y -= 30;
	}
	
	private function drawDesc():void 
	{
		descTxt =  Window.drawText(Locale.__e("flash:1407829337190"), {
				color:0xf2e5b6,
				fontSize:30,
				borderColor:0x2b3b64,
				borderSize:0,
				autoSize:"center",
				textAlign:"center"
			}
		);
		descTxt.wordWrap = true;
		descTxt.width = background.width - 16;
		descTxt.x = (background.width - descTxt.width) / 2;// + 40;
		descTxt.y = (background.height - descTxt.height) / 2;// - 30;
		addChild(descTxt);
	}
	
	private function drawPrice():void 
	{
		//var countBg:Sprite = new Sprite();
		//countBg.graphics.beginFill(0xc7b362);
        //countBg.graphics.drawCircle(15, 15, 15);
        //countBg.graphics.endFill();
		//countBg.x =	6;
		//countBg.y = 6;
		var countBg:Bitmap = new Bitmap(Window.textures.itemNumRoundBakingLight);
		countBg.x = -4;
		countBg.y = -4;
		countCont.addChild(countBg);
		
		countTxt = Window.drawText(String(count) , {
				color:0xffffff,
				fontSize:24,
				borderColor:0x855729,
				autoSize:"center"
			}
		);
		countCont.addChild(countTxt);
		countTxt.x = countBg.x + (countBg.width - countTxt.width) / 2;
		countTxt.y = countBg.y + (countBg.height - countTxt.height) / 2 + 2;
		
		addChild(countCont);
		countCont.visible = false;
		
		//var bgPrice:Bitmap = Window.backingShort(68, "shopSpecialBacking");
		//var bgPrice:Bitmap = Window.backingShort(100, "shopSpecialBacking");
		var bgPrice:Bitmap = Window.backing(68,33,10,"levelUpOpenBacking");  // выбранные на продажу элементы searchPanelBackingPiece
		addChild(bgPrice);
		bgPrice.x = background.x + (background.width - bgPrice.width) / 2;
		bgPrice.y = background.height - bgPrice.height / 2 - 4;// - 30;
		//bgPrice.y = 300;
		
		var icon:Bitmap = new Bitmap(UserInterface.textures.coinsIcon);
		icon.scaleX = icon.scaleY = 0.7;
		icon.smoothing = true;
		icon.y = bgPrice.y + (bgPrice.height - icon.height) / 2;
		icon.x = bgPrice.x - icon.width / 2 + 10;
		addChild(icon);
		
		priceTxt = Window.drawText(String(price) , {
				color:0xfedb38,
				fontSize:24,
				borderColor:0x684e1e,
				autoSize:"center"
			}
		);
		addChild(priceTxt);
		priceTxt.x = bgPrice.x + (bgPrice.width - priceTxt.width) / 2 + 4;
		priceTxt.y = bgPrice.y + (bgPrice.height - priceTxt.height) / 2 + 3;
	}
	
	private function drawCloseBttn():void 
	{
		closeBttn = new ImageButton(Window.textures.closeBttnSmall, {scaleX:0.8, scaleY:0.8});
		addChild(closeBttn);
		closeBttn.tip = function():Object { 
			return {
				title:"",
				text:Locale.__e("flash:1382952379774")
			};
		};
		
		closeBttn.x = background.width - closeBttn.width +6;
		closeBttn.y = -5;
		
		closeBttn.addEventListener(MouseEvent.CLICK, onCloseEvent);
		
		closeBttn.visible = false;
	}
	
	private function onCloseEvent(e:MouseEvent):void 
	{
		makeEmpty();
		
		if (window.checkEmpty())
			window.window.sellBttn.state = Button.DISABLED;
		
		window.removeItem();
		window.window.stockMenu.setContentSection("all");
		
		var focusItem:StockItem = window.window.stockMenu.focusItem;
		
		if (!focusItem)
			window.window.sellMenu.makeEmpty();
		else
			window.window.sellMenu.change(focusItem.sid);
	}
	
	private function makeEmpty():void 
	{
		descTxt.visible = true;
		closeBttn.visible = false;
		countCont.visible = false;
		
		isEmpty = true;
		
		price = 0;
		count = 0;
		
		if (icon) {
			removeChild(icon);
			icon = null;
			icon = new Bitmap();
			addChildAt(icon, 1);
		}
		
		updatePrice();
	}
	
	public function change(item:Object):void
	{
		isEmpty = false;
		
		descTxt.visible = false;
		countCont.visible = true;
		closeBttn.visible = true;
		
		sid = item.sid;
		price = item.price;
		count = item.count;
		
		addChild(preloader);
		preloader.x = background.width / 2;
		preloader.y = background.height / 2;
		
		Load.loading(Config.getIcon(item.type, item.preview), onLoad);
		
		updatePrice();
	}
	
	private function updatePrice():void 
	{
		priceTxt.text = String(price);
		countTxt.text = String(count);
	}
	
	private function onLoad(data:*):void 
	{
		if(contains(preloader)){
			removeChild(preloader);
		}
		
		icon.bitmapData = data.bitmapData;
		icon.scaleX = icon.scaleY = 0.8;
		icon.smoothing = true;
		icon.x = (background.width - icon.width) / 2;								
		icon.y = (background.height - icon.height) / 2 - 4;
	}
	
	public function dispose():void
	{
		window = null;
		
		closeBttn.removeEventListener(MouseEvent.CLICK, onCloseEvent);
		closeBttn.dispose();
		closeBttn = null;
	}
}