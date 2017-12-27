package wins 
{
	import buttons.ImageButton;
	import core.Load;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import wins.Window;
	import com.greensock.*; 
	import com.greensock.easing.*;
	/**
	 * ...
	 * @author 
	 */
	public class TradeWindow extends Window
	{
		
		//public var headerBackingTexture:String = 'tradingPostBackingMainHeader';
		
		public var titleBacking:Bitmap;
		public var tradeList:TradeList;
		
		public function TradeWindow(settings:Object) 
		{
			if (settings == null) {
				settings = new Object();
			}
			
			settings['width']			= 628; 
			settings['height']			= 650;
			settings['hasPaginator']	= false;
			settings["hasArrows"] 		= true;
			settings['content']			= [];
			settings['title']			= App.data.storage[179].title;//'Торговый пост';
			settings['background']		= 'tradingPostBackingMain';
			
			super(settings);
			
			App.self.addEventListener(AppEvent.ON_CHANGE_STOCK, onStockRefresh);
		}
		
		private function onStockRefresh(e:AppEvent):void 
		{
			tradeList.onStockRefresh();
		}
		override public function drawExit():void 
		{
			exit = new ImageButton(textures.closeBttn);
			headerContainer.addChild(exit);
			exit.x = settings.width - 49;
			exit.y = -20;
			exit.addEventListener(MouseEvent.CLICK, close);
		}
		
		override public function drawBody():void 
		{
			var mirrorsSpace1:int = -30;
			//var mirrorsSpace2:int = 107;
			var titleBackY:int = -100;
			//var titleBackWidth:int = 440;
			
			
			//titleBacking = drawTitleBacking(titleBackY, titleBackWidth);
			//titleBacking.x = int((settings.width - titleBackWidth) * 0.5);
			//titleBacking.y = titleBackY;
			//bodyContainer.addChild(titleBacking);
			
			drawMirrowObjs('drapery1', mirrorsSpace1 - 7, settings.width - mirrorsSpace1 + 12, titleBackY + 45);
			drawMirrowObjs('diamondsTop', settings.width / 2 - settings.titleWidth / 2 - 5, settings.width / 2 + settings.titleWidth / 2 + 5, -30, true, true);
			//drawMirrowObjs('drapery2', mirrorsSpace2, settings.width - mirrorsSpace2, titleBackY + 57);
			
			//var separator:Bitmap = Window.backingShort(280, 'separator2');//Window.separator(280, 0,0,0.6,);
			//separator.alpha = 0.5;
			//separator.x = (settings.width - separator.width) * 0.5;
			//separator.y = -30;
			//bodyContainer.addChild(separator);
			
			// рисование TradeList
			tradeList = new TradeList( {
				x:		45,
				y:		5,
				width:	690, //390,
				height: 440
			},
				this
			);
			
			/*var tradeInfo:Sprite = new TradeInfo( {
				x:		450,
				y:		0,
				width:	280,
				height: 440,
				
				title:	'Пирожки для бабушки',
				info:	'Собери указанный предмет и получи награду!',
				money:	'1500',
				exp:	'3000'
			} );
			
			bodyContainer.addChild(tradeInfo);*/
			bodyContainer.addChild(tradeList);
			
			//drawMirrowObjs('drapery1', mirrorsSpace1 - 7, settings.width - mirrorsSpace1 + 12, titleBackY + 45);
			
			drawHeader();
			
			
		}
		
		override public function drawHeader():void 
		{
			super.drawHeader();
			drawExit();
		}
		
		override public function drawTitle():void {
			titleLabel = titleText( {
					title				: settings.title,
					color				: settings.fontColor,
					multiline			: settings.multiline,
					fontSize			: 46,
					textLeading	 		: settings.textLeading,
					borderColor 		: 0xb98659,
					borderSize 			: 1,
					
					shadowBorderColor	: settings.shadowBorderColor || settings.fontColor,
					width				: settings.width - 140,
					textAlign			: 'center',
					sharpness 			: 50,
					thickness			: 50,
					border				: true
				})
				
				titleLabel.x = (settings.width - titleLabel.width) * .5;
				titleLabel.y = -5;
				headerContainer.addChild(titleLabel);
				var glowFilter:GlowFilter = new GlowFilter(0x6d3f23, 0.5, 5, 5, 2, 3);
				headerContainer.filters = [glowFilter];	
		}
		
		//public function drawTitleBacking(positionY:int, currWidth:int = 440):Bitmap {
			
			//var headerBackingLeft:Bitmap = Window.backing2(currWidth, textures[headerBackingTexture].height, textures[headerBackingTexture].width - 2, headerBackingTexture, headerBackingTexture);
			
			//var headerBackingLeft:Bitmap = new Bitmap(textures[headerBackingTexture], 'auto', true);
			//var headerBackingCenter:Bitmap;
			//var bmd:BitmapData = new BitmapData(1, headerBackingLeft.height, true, 0);
			//var headerBackingRight:Bitmap = new Bitmap(textures[headerBackingTexture]);
			
			//bmd.copyPixels(headerBackingLeft.bitmapData, new Rectangle(headerBackingLeft.width - 1, 0, headerBackingLeft.width, headerBackingLeft.height), new Point());
			//headerBackingCenter = new Bitmap(bmd);
			
			//if (currWidth < headerBackingLeft.width + headerBackingRight.width)
				//currWidth = headerBackingLeft.width + headerBackingRight.width;
			
			//headerBackingLeft.y = -1;
				
			//headerBackingRight.scaleX = -1;
			//headerBackingRight.x = currWidth;
			
			//headerBackingCenter.x = headerBackingLeft.x + headerBackingLeft.width;
			//headerBackingCenter.width = currWidth - headerBackingLeft.width - headerBackingRight.width;
			
			//var _titleBacking:Sprite = new Sprite();
			//_titleBacking.addChild(headerBackingLeft);
			//_titleBacking.addChild(headerBackingCenter);
			//_titleBacking.addChild(headerBackingRight);
			//_titleBacking.x = int((settings.width - currWidth) * 0.5);
			//_titleBacking.y = positionY;
			
			//var result:BitmapData = new BitmapData(_titleBacking.width, _titleBacking.height, true, 0);
			//result.draw(_titleBacking);
			
			//return new Bitmap(result);
			//bodyContainer.addChild(titleBacking);
		//}
		
		override public function dispose():void
		{
			tradeList.dispose();
			
			App.self.removeEventListener(AppEvent.ON_CHANGE_STOCK, onStockRefresh);
			
			super.dispose();
		}
	}
}

import buttons.Button;
import buttons.ImageButton;
import buttons.MoneySmallButton;
import com.flashdynamix.motion.plugins.SoundTween;
import com.greensock.easing.Quart;
import com.greensock.TweenLite;
import com.greensock.TweenMax;
import core.Load;
import core.Post;
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.filters.GlowFilter;
import flash.geom.Point;
import flash.text.TextField;
import flash.utils.clearInterval;
import flash.utils.clearTimeout;
import flash.utils.setInterval;
import flash.utils.setTimeout;
import ui.Hints;
import units.Trade;
import wins.TradeWindow;


internal class TradeInfo extends Sprite {
	
	public var settings:Object;
	
	//private var titleText:TextField;
	//private var infoText:TextField;
	private var moneyText:TextField;
	private var expText:TextField;
	//private var back:Bitmap;
	//private var backElements:Bitmap;
	private var coin:Bitmap;
	private var star:Bitmap;
	
	//public var bttnComplete:Button;
	
	private var itemIngredientCont:Sprite;
	
	private const INDENT:int = 10;
	private const XPOS:int = 450;
	private const WIDTH:int = 280;
	private const HEIGHT:int = 440;
	private var window:TradeWindow;
	
	private var itemsList:TradeList;
	
	//
	private var urgentTimeTxt:TextField;
	private var urgentMoneyX:TextField;
	private var urgentExpX:TextField;
	private var urgentTimeImg:Bitmap;
	private var urgentMoneyImg:Bitmap;
	private var urgentExpImg:Bitmap;
	//
	
	public function TradeInfo(settings:Object, window:TradeWindow, list:TradeList):void {
		this.settings = settings;
		this.window = window;
		itemsList = list;
		drawBody();
		
		App.self.addEventListener(AppEvent.ON_TRADE_FLY_BACK, doClose);//canntTrade);
	}
	
	private function doClose(e:AppEvent):void 
	{
		App.self.setOffTimer(updateUrgentTime);
		//window.close();
	}
	
	private var rewCont:Sprite = new Sprite();
	public function drawBody():void {
		
		//back = Window.backing(WIDTH, 135, 50, 'tradePostDarkBacking');
		//back.x = XPOS;
		//back.y = 75;
		//back.alpha = 0.5;
		//backElements = Window.backing(WIDTH, 155, 50, 'itemBacking');
		//backElements.x = XPOS;
		//backElements.y = 225;
		
		//coin = new Bitmap(UserInterface.textures.coinsIcon, 'auto', true);
		//coin.x = back.x + 5;
		//coin.y = back.y + 84;
		//star = new Bitmap(UserInterface.textures.expIcon, 'auto', true);
		//star.scaleX = star.scaleY = 2.8;
		//star.x = back.x + 150;
		//star.y = back.y + 84;
		
		//titleText = Window.drawText( '', {
			//width:WIDTH,
			//fontSize:30,
			//autoSize:"center",
			//textAlign:"center",
			//color:0xFFFFFF,
			//borderColor:0x342820,
			//borderSize:4,
			//wrap:true
		//} );
		//titleText.x = back.x + 5;
		//titleText.y = 15;
		
		//infoText = Window.drawText( '', {
			//width:WIDTH - 30,
			//multiline:true,
			//fontSize:22,
			//autoSize:"center",
			//textAlign:"center",
			//color:0xffffff,
			//borderColor:0xffffff,
			//borderSize:4,
			//wrap:true
		//} );
		//infoText.x = 465;
		//infoText.y = 90;
		
		moneyText = Window.drawText( '', {
			width:80,
			fontSize:26,
			autoSize:"none",
			textAlign:"left",
			color:0x500d00,
			borderColor:0xFFFFFF,
			borderSize:4
		} );
		//moneyText.x = coin.x + coin.width + 5;
		//moneyText.y = coin.y + 5;
		
		expText = Window.drawText( '', {
			width:80,
			fontSize:26,
			autoSize:"none",
			textAlign:"left",
			color:0x500d00,
			borderColor:0xFFFFFF,
			borderSize:4
		} );
		//expText.x = star.x + star.width + 5;
		//expText.y = coin.y + 5;
		
		//bttnComplete = new Button( {
			//hasDotes	:true,
			//caption		:Locale.__e('flash:1393584053092'),
			//width		:150,
			//height		:48,
			//fontSize	:26,
			//multiline	:false,
			//bgColor		:[0xf5cf57, 0xe1a62b],
			//borderColor	:[0xfff17f, 0x9f7528],
			//fontColor	:0xFFFFFF,
			//fontBorderColor :0x814f31,
			//fontBorderSize	:3
		//} );
		//bttnComplete.x = XPOS + (WIDTH - bttnComplete.width) / 2;
		//bttnComplete.y = 390;
		
		
		//moneyText.x = coin.width + 5;
		//moneyText.y = 5;
		
		//star.x = moneyText.x + 90;
		
		//expText.x = star.x + star.width + 5;
		//expText.y = 5;
		
		//rewCont.addChild(coin);
		//rewCont.addChild(moneyText);
		//rewCont.addChild(star);
		//rewCont.addChild(expText);
		
		rewCont.x = 470;
		rewCont.y = 534;
		
		//addChild(back);
		//addChild(backElements);
		//addChild(titleText);
		//addChild(infoText);
		
		addChild(rewCont);
		//addChild(coin);
		//addChild(moneyText);
		//addChild(star);
		//addChild(expText);
		//addChild(bttnComplete);
		
		itemIngredientCont = new Sprite();
		addChild(itemIngredientCont);
		
		//urgent____________________________________________________
		urgentTimeImg = new Bitmap(Window.textures.instantsTimer);
		urgentTimeImg.x = 441;
		urgentTimeImg.y = 57;
		
		urgentMoneyImg = new Bitmap(Window.textures.specialMark);
		urgentMoneyImg.x = rewCont.x + moneyText.x + moneyText.textWidth + 10;
		urgentMoneyImg.y = rewCont.y + moneyText.y - 12;
		
		urgentExpImg = new Bitmap(Window.textures.specialMark);
		urgentExpImg.x = rewCont.x + expText.x + expText.textWidth + 10;
		urgentExpImg.y = rewCont.y + expText.y - 12;
		
		urgentTimeTxt = Window.drawText( '100', {
			width:80,
			fontSize:26,
			autoSize:"none",
			textAlign:"left",
			color:0xffffff,
			borderColor:0x500d00,
			borderSize:4
		} );
		urgentTimeTxt.x = urgentTimeImg.x + urgentTimeImg.width;
		urgentTimeTxt.y = urgentTimeImg.y + 6;
		
		urgentMoneyX = Window.drawText( 'x2', {
			width:80,
			fontSize:28,
			autoSize:"none",
			textAlign:"left",
			color:0xffffff,
			borderColor:0x500d00,
			borderSize:4
		} );
		
		urgentExpX = Window.drawText( 'x2', {
			width:80,
			fontSize:28,
			autoSize:"none",
			textAlign:"left",
			color:0xffffff,
			borderColor:0x500d00,
			borderSize:4
		} );
		
		addChild(urgentTimeImg);
		addChild(urgentMoneyImg);
		addChild(urgentExpImg);
		addChild(urgentTimeTxt);
		addChild(urgentMoneyX);
		addChild(urgentExpX);
		//______________________________________
		
		//bttnComplete.addEventListener(MouseEvent.CLICK, onSellEvent);
	}
	
	private function onSellEvent(e:MouseEvent):void 
	{
		if (e.currentTarget.mode == Button.DISABLED) return;
			e.currentTarget.state = Button.DISABLED;
		
		onSell(trade);
	}
	
	public function onSell(tradeItems:Object):void {
		if (!App.user.stock.takeAll(tradeItems.items))
			return;
			
		for (var i:int = 0; i < itemsList.bttnsList.length; i++) {
			itemsList.bttnsList[i].checkMarks();
		}
		
		window.settings.onSell(trade, tradeItems);
		window.close();
		App.map.focusedOn(window.settings.target);
	}
	
	private function sortArrItems():void 
	{
		var arr:Array = [];
		
		for ( var i:int = 0; i < itemsList.arrItems.length; i++ ) {
			if (itemsList.arrItems[i].mark.visible) {
				arr.push(itemsList.arrItems[i]);
				itemsList.arrItems.splice(i, 1);
				i--;
			}
		}
		for ( i = 0; i < itemsList.arrItems.length; i++ ) {
			arr.push(itemsList.arrItems[i]);
		}
		itemsList.arrItems.splice(0, itemsList.arrItems.length);
		itemsList.arrItems = arr;
	}
	//
	public function canntTrade(e:AppEvent = null):void
	{
		//if (!window.settings.target.isBonus) {
			//titleText.text = Locale.__e('flash:1393584091732');
			//infoText.text = Locale.__e('flash:1393584125850');
		//}else {
			//titleText.text = Locale.__e('flash:1393584137336');
			//infoText.text = Locale.__e('flash:1393584147951');
		//}
		//back.visible = false;
		//backElements.visible = false;
		//coin.visible = false;
		//moneyText.visible = false;
		//star.visible = false;
		//expText.visible = false;
		//bttnComplete.visible = false;
		//itemIngredientCont.visible = false;
		urgentTimeTxt.text = '';
		//drawElements( { items: { }} );
		urgentTimeTxt.visible = false;
		urgentMoneyX.visible = false;
		urgentExpX.visible = false;
		urgentTimeImg.visible = false;
		urgentMoneyImg.visible = false;
		urgentExpImg.visible = false;
	}
	
	private var trade:Object;
	public function setInfo(trade:Object):void {
		this.trade = trade;
		
		
			//titleText.text = trade.title;
			//infoText.text = trade.info;
		
		
		//titleText.text = trade.title;
		//infoText.text = trade.info;
		if(trade.ID != 0){
			moneyText.text = trade.reward[Stock.COINS];
			expText.text = trade.reward[Stock.EXP];
		}
		
		if (trade.ID == 0) {
			//back.visible = false;
			//backElements.visible = false;
			//infoText.visible = false;
			//coin.visible = false;
			//moneyText.visible = false;
			//star.visible = false;
			//expText.visible = false;
			//bttnComplete.visible = false;
			itemIngredientCont.visible = false;
			
			//titleText.y = (HEIGHT - titleText.height) / 2;
		}else {
			//back.visible = true;
			//backElements.visible = true;
			//infoText.visible = true;
			//coin.visible = true;
			//moneyText.visible = true;
			//star.visible = true;
			//expText.visible = true;
			//bttnComplete.visible = true;
			itemIngredientCont.visible = true;
			
			//titleText.y = 15;
		}
		showUrgentInfo(false);
		if (trade.urgent == 1 && trade.urgentTime > App.time) {
			//infoText.text = trade.infoUrgent;
			showUrgentInfo(true);
			urgentTimeTxt.text = TimeConverter.timeToStr(trade.urgentTime - App.time - 20);
		}
		
		drawElements(trade);
		
		checkOnComplete();
		
		if (!window.settings.target.canTrade) {
			canntTrade();
			return;
		}
	}
	
	public function updateUrgentTime(ugrTime:int, item:TradeItem):void
	{
		if (itemsList.itemFocus != item) return;
		urgentTimeTxt.text = TimeConverter.timeToStr(ugrTime - 20);
	}
	
	public function showUrgentInfo(value:Boolean):void
	{
		urgentTimeImg.visible = value;
		urgentTimeTxt.visible = value;
		urgentMoneyImg.visible = value;
		urgentExpImg.visible = value;
		urgentMoneyX.visible = value;
		urgentMoneyX.visible = value;
		urgentExpX.visible = value;
		urgentExpX.visible = value;
		if(value){
			urgentMoneyImg.x = rewCont.x + moneyText.x + moneyText.textWidth + 3;
			urgentExpImg.x = rewCont.x + expText.x + expText.textWidth + 3;
			//
			urgentMoneyX.x = urgentMoneyImg.x + 7;
			urgentMoneyX.y = urgentMoneyImg.y + 10;
			urgentExpX.x = urgentExpImg.x + 7;
			urgentExpX.y = urgentExpImg.y + 10;
		}
	}
	
	private function checkOnComplete():void {
		//if (!App.user.stock.checkAll(trade.items))
			//bttnComplete.state = Button.DISABLED;
		//else
			//bttnComplete.state = Button.NORMAL;
	}
	
	private function drawElements(trade:Object):void {
		const width:int = 85;
		var count:int = 0;
		
		if (itemIngredientCont.numChildren > 0)
			clearIngredients();
		
		for (var s:String in trade.items) {
			var ingredient:ItemElement = new ItemElement( {
				
				maxWidth:width,		// Не касается текста
				maxHeight:120,		// Не касается текста
				sid		:s,
				count	:trade.items[s]
			} );
			ingredient.x = width * count;
			
			itemIngredientCont.addChild(ingredient);
			
			count++;
		}
		
		if (width * count > WIDTH) {
			itemIngredientCont.x = XPOS + INDENT;
			itemIngredientCont.width = WIDTH;
			itemIngredientCont.scaleY = itemIngredientCont.scaleX;
			itemIngredientCont.y = 225 + INDENT + (155 - itemIngredientCont.height) / 2;
		}else {
			itemIngredientCont.x = XPOS + (WIDTH - width * count) / 2;
			itemIngredientCont.y = 225 + INDENT;
		}
	}
	public function clearIngredients():void {
		while (itemIngredientCont.numChildren > 0) {
			(itemIngredientCont.getChildAt(0) as ItemElement).dispose();
			itemIngredientCont.removeChildAt(0);
		}
	}
	
	public function dispose():void {
		clearIngredients();
		App.self.removeEventListener(AppEvent.ON_TRADE_FLY_BACK, canntTrade);
		//back.parent.removeChild(back);
		//backElements.parent.removeChild(backElements);
		//titleText.parent.removeChild(titleText);
		//infoText.parent.removeChild(infoText);
		//coin.parent.removeChild(coin);
		//moneyText.parent.removeChild(moneyText);
		//star.parent.removeChild(star);
		//expText.parent.removeChild(expText);
		//removeChild(bttnComplete);
		removeChild(itemIngredientCont);
		removeChild(rewCont);
		
		App.self.setOffTimer(updateUrgentTime);
		
		//back = null;
		//backElements = null;
		//titleText = null;
		//infoText = null;
		coin = null;
		moneyText = null;
		star = null;
		expText = null;
		//bttnComplete = null;
		itemIngredientCont = null;
	}
}


internal class ItemElement extends Sprite 
{
	
	private var ingedient:Bitmap;
	private var ingedientContainer:LayerX;
	private var mark:Bitmap;
	
	
	//private var tradeInfo:TradeInfo;
	
	
	private var info:Object;
	private var stock:uint;
	private var count:int;
	
	public function ItemElement(info:Object) 
	{
		this.info = info;
		
		stock = App.user.stock.count(info.sid);
		count = info.count;
		
		ingedientContainer = new LayerX();
		ingedientContainer.tip = function():Object {
				return {
					title:App.data.storage[info.sid].title,
					text:App.data.storage[info.sid].description
				}
			}
			
		ingedient = new Bitmap();
		Load.loading(Config.getIcon(App.data.storage[info.sid].type, App.data.storage[info.sid].view), onLoad);
		
		
		addChild(ingedientContainer);
		ingedientContainer.addChild(ingedient);
		//addChild(mark);
	}
	
	private function onLoad(data:Bitmap):void {
		//if(ingedient){
			//ingedient.bitmapData = data.bitmapData;
			//ingedient.smoothing = true;
			//ingedient.scaleX = ingedient.scaleY = 0.7;
			//ingedient.x = (info.maxWidth - ingedient.width) / 2;
			//ingedient.y = 50 - ingedient.height / 2;
		//}
	}
	
	public function dispose():void {
		removeChild(ingedientContainer);
		//removeChild(onStock);
		//removeChild(onRecipe);
		//removeChild(mark);
		
		//ingedient = null;
		//onStock = null;
		//onRecipe = null;
		//mark = null;
	}	
}



import buttons.MoneyButton;
import core.Load;
import core.TimeConverter;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.text.TextField;
import ui.UserInterface;
import wins.Window;
import wins.TradeWindow;

internal class TradeList extends Sprite {
	
	public const ITEM_SCALE:Number = 1/*.07*/;
	
	public var settings:Object;
	private var defaulInfo:Object = { id:0, sid:0, time:0, money:0, exp:0, items: {}, title:Locale.__e('flash:1393584171115'), info:' '};
	
	public var clickBlock:Boolean = false;
	public var bttnsList:Vector.<TradeItem>;
	
	public var itemFocus:TradeItem;
	
	private var offset:Boolean = true;
	private var itemPos:int = 0;
	private var itemsInfoList:Array;
	private var hasTimer:Boolean = false;
	
	private var background:Bitmap;
	private var itemContainer:Sprite;
	public var tradeInfo:TradeInfo;
	private var window:TradeWindow;
	
	public var arrItems:Array = [];
	
	private var info:Object;

	public function TradeList (settings:Object, window:TradeWindow) {
		this.settings = settings;
		this.window = window;
		getItems();
		drawBody();
	}
	
	public function onStockRefresh():void
	{
		for (var i:int = 0; i < arrItemsAll.length; i++ ) {
			arrItemsAll[i].updateInfo(arrItemsAll[i].trade);
		}
	}
	
	private function drawBody():void {
		//background = Window.backing(390, settings.height, 40, 'tradePostBackingSmall');
		//background.x = settings.x;
		//background.y = settings.y;
		//addChild(background);
		
		tradeInfo = new TradeInfo({}, window, this);
		addChild(tradeInfo);
		
		drawItems();
		
		//tradeInfo = new TradeInfo({}, window, this);
		//addChild(tradeInfo);
		var isFocused:Boolean = false;
		if (arrItems.length > 0) {
			for (var i:int = 0; i < arrItems.length; i++ ) {
				//if (arrItems[i].isReady) {
					//isFocused = true;
					//setItemInFocus(arrItems[i]);
					//break;
				//}
				if (arrItems[i].percentDone == getMaxPercent()) {
					isFocused = true;
					setItemInFocus(arrItems[i]);
					break;
				}
			}
			if(!isFocused)setItemInFocus(arrItems[0]);
		}
		else tradeInfo.setInfo({ID:0, title:Locale.__e('flash:1393584218977'), info:'cdscds'});
	}
	
	private function getMaxPercent():int
	{
		var maxPerc:int = 0;
		for (var i:int = 0; i < arrItems.length; i++ ) {
			if (maxPerc < arrItems[i].percentDone)
				maxPerc = arrItems[i].percentDone;
		}
		
		return maxPerc;
	}
	
	private function getItems():void {
		// Принудительное присвоение значений массиву todo
		if (!App.data.hasOwnProperty('trades'))
			return;
		
		itemsInfoList = [];
		
		var tradesTr:Object = window.settings.target.trades;
		for (var id:* in tradesTr) {
			var ID:int = tradesTr[id].ID;
			
			var trade:Object = { 
					ID:ID,
					time:tradesTr[id]['time'],
					title:App.data.trades[ID]['title'],
					iorder:App.data.trades[ID]['iorder'],
					items:tradesTr[id]['items'],
					reward:tradesTr[id]['reward'],
					urgent:tradesTr[id]['urgent'],
					info:Locale.__e('flash:1393584248113'),
					infoUrgent:Locale.__e('flash:1393584267727')
				};
				
			if (tradesTr[id]['urgent'] == 1) {
				var urgentTime:int = App.data.trades[ID].time + tradesTr[id]['time'];
				trade['urgentTime'] = urgentTime;
			}
				
			itemsInfoList.push(trade);	
		}
		
		/*itemsInfoList = [
			{id:0, sid:134, time:App.time - 60, money: 1000, exp: 3000, items: {134:3, 133:2, 132:4}, title:'Пирожки для бабушки', info:'Собери указанный предмет и получи награду!'},
			{id:0, sid:133, time:App.time - 60, money: 1500, exp: 3000, items: {131:3, 130:2, 129:4}, title:'Пирожки для бабушки', info:'Собери указанный предмет и получи награду!'},
			{id:0, sid:126, time:App.time - 60, money: 91800, exp: 30000, items: {128:3, 127:2, 126:4}, title:'Пирожки для бабушки', info:'Собери указанный предмет и получи награду!'},
			{id:0, sid:102, time:App.time - 60, money: 2, exp: 30000, items: {124:3, 125:2, 124:4}, title:'Пирожки для бабушки', info:'Собери указанный предмет и получи награду!'},
			{id:0, sid:127, time:App.time + 10, money: 10000, exp: 99999, items: {124:3, 123:2, 122:4}, title:'Пирожки для бабушки', info:'Собери указанный предмет и получи награду!'},
			{id:0, sid:128, time:App.time + 20, money: 1000, exp: 3000, items: {130:3, 128:2, 129:4}, title:'Пирожки для бабушки', info:'Собери указанный предмет и получи награду!'}
		];*/
	}
	
	private var arrItemsAll:Array = [];
		
	public function drawItems():void 
	{
		const itemsLimit:int = 9;
		const itemTopSpace:int = 15;
		const itemLSpace:int = 5;
		const itemHSpace:int = 10;
		const itemWidth:int = 169;
		const itemHeight:int = 166;
		this.info = info;
		if (itemContainer && itemContainer.numChildren > 0)
			clearItemContainer();
		
		bttnsList = new Vector.<TradeItem>();
		
		itemContainer = new Sprite();
		var itemsLength:int = itemsInfoList.length;
		
		if (itemsLength > itemsLimit) itemsLength = itemsLimit;		// Принудительное ограничение количества объектов до 9
		for (var i:int = 0; i < itemsLength; i++) 
		{
			var trade:Object = itemsInfoList[i];
			var test:Number = i % 3;
			var item:TradeItem = new TradeItem( {
				window	:window,
				x		: (itemWidth + itemHSpace) * test + itemWidth / 2 + settings.x + itemLSpace,
				y		: (itemHeight + itemHSpace) * Math.floor(i / 3) + itemHeight / 2 + settings.y + itemTopSpace + 35,
				width	: itemWidth,
				height	: itemHeight,
				center	: true,
				trade	: trade,
				tradeInfo	: tradeInfo,
				onMoneyAccelerate : onMoneyAccelerate,
				//onClick	: onItemClick,
				onClose	: onItemClose,
				removeItem:removeItemFromArray,
				addItem:addItemToArray,
				setItemInFocus:setItemInFocus,
				arrItems:arrItems,
				onSell:window.settings.onSell,
				visMark:window.settings.visMark,
				unVisMark:window.settings.unVisMark,
				target:window.settings.target
			});
			
			item.pos = i;
			itemContainer.addChild(item);
			
			arrItemsAll.push(item);
			
			if (!offset && i == itemPos)
				setItemInFocus(item, true);
				
			if (item.drawBody()) {
				bttnsList.push(item);
			}
		}
		addChild(itemContainer);
	}
	
	private function addItemToArray(item:TradeItem):void 
	{
		var ind:int = arrItems.indexOf(item);
		if (ind == -1) 
			arrItems.push(item);
	}
	
	private function removeItemFromArray(item:TradeItem):void 
	{
		var ind:int = arrItems.indexOf(item);
		if (ind != -1) 
			arrItems.splice(ind, 1);
	}
	
	private function clearItemContainer():void {
		while (itemContainer.numChildren > 0) {
			(itemContainer.getChildAt(0) as TradeItem).dispose();
			itemContainer.removeChildAt(0);
		}
	}
	private function timeUpdate():void {
		for (var i:int = 0; i < bttnsList.length; i++) {
			if (bttnsList[i].settings.time <= App.time) {
				if (bttnsList[i] == itemFocus) {
					offset = false;
					itemPos = getItemPosition(bttnsList[i]);
				}
				drawItems();
				return;
			}
			bttnsList[i].updateTime();
		}
	}
	
	//private function onItemClick(item:TradeItem):void {
		//setItemInFocus(item);
	//}
	private function onItemClose(item:TradeItem):void {
		
		for (var i:int = 0; i <  arrItems.length; i++ ) {
			if (itemFocus != arrItems[i]) {
				arrItems[i].scaleX = arrItems[i].scaleY = 1;
				arrItems[i].filters = [];//[GlowFilter(0xffffff, 0, 1, 1)]
			}
		}
		
		if (arrItems.length > 0) {
			//for (i = 0; i <  arrItems.length; i++ ) {
				//if (arrItems[i] != item) {
					//break;
				//}
			//}
			
			
			//if (arrItems.length == 1 && arrItems[0] == item) {
				//if (itemFocus) itemFocus.scaleX = itemFocus.scaleY = 1;
				//itemFocus = null;
				//tradeInfo.setInfo( { ID:0, title:'Ничего нет', info:'cdscds' } );
			//}else {
				setItemInFocus(arrItems[0]);
			//}
		}
		else {
			if (itemFocus) {
				itemFocus.scaleX = itemFocus.scaleY = 1;
				itemFocus.filters = [];
			}
			itemFocus = null;
			tradeInfo.setInfo({ID:0, title:Locale.__e('flash:1393584218977'), info:'cdscds'});
		}
		
		
		//drawItems();
	}
	
	private function onMoneyAccelerate(item:TradeItem):void {
		 //Post.send('tralala', accelerateHandler, { sid: item.settings.sid } );
		
		//itemsInfoList[getItemPosition(item)].time = App.time - 1;
		//onTimeExpired(item);
		
		//arrItems.push(item);
		
		//itemFocus = null;
		for (var i:int = 0; i <  arrItems.length; i++ ) {
			arrItems[i].scaleX = arrItems[i].scaleY = 1;
		}
		setItemInFocus(item);
	}
	private function onTimeExpired(item:TradeItem):void {
		drawItems();
	}
	private function accelerateHandler(data:*):void {
		// TODO Доделать обработчик ускорения
		trace(data.toString());
	}
	
	private function getItemInfo(item:TradeItem):Object {
		for (var i:int = 0; i < itemContainer.numChildren; i++) {
			if (itemContainer.getChildAt(i) == item)
				return itemsInfoList[i];
		}
		return defaulInfo;
	}
	private function getItemPosition(item:TradeItem):int {
		for (var i:int = 0; i < itemContainer.numChildren; i++) {
			if (itemContainer.getChildAt(i) == item)
				return i;
		}
		return -1;
	}
	public function setItemInFocus(item:TradeItem, instantly:Boolean = false):void {
		if (!instantly && itemFocus && itemFocus == item)
			return;
			
		item.drawBg(true);	
		
		if (instantly) {
			offset = true;
			item.scaleX = ITEM_SCALE;
			item.scaleY = ITEM_SCALE;
			itemFocus = item;
		} else {
			var color:uint = 0x7abd1e;
			if (itemFocus) {
				itemFocus.drawBg();	
				//TweenMax.to(itemFocus, 0.1, {glowFilter:{color:color, alpha:0, blurX:1, blurY:1}, scaleX:1, scaleY:1} );
			}
			itemFocus = item;
			//TweenMax.to(itemFocus, 0.1, {glowFilter:{color:color, alpha:1, blurX:4, blurY:4, strength:18}, scaleX:ITEM_SCALE, scaleY:ITEM_SCALE} );
		}
			
		if(item.settings.trade.time <= App.time)
			tradeInfo.setInfo(item.settings.trade);//(getItemInfo(item));
		else
			tradeInfo.setInfo({ID:0, title:Locale.__e('flash:1393584218977'), info:'cdscds'});
			//tradeInfo.setInfo(defaulInfo);
	}
	
	public function dispose():void {
		
		for (var i:int = 0; i < arrItemsAll.length; i++ ) {
			arrItemsAll[i].dispose();
			arrItemsAll[i] = null;
		}
		arrItemsAll.splice(0, arrItemsAll.length);
		arrItemsAll = [];
		
		if (tradeInfo) {
			tradeInfo.dispose();
			tradeInfo = null;
		}
	}
}


import flash.display.Bitmap;
import flash.display.Sprite;
import wins.Window;

internal class TradeItem extends LayerX {
	public var settings:Object;
	private var info:Object;
	public var time:int = 0;
	
	public static const WAIT:String = 'wait';
	public static const READY:String = 'ready';
	public static const COMPLETEABLE:String = 'completeable';
	
	private var _state:String = WAIT;
	
	public var background:Bitmap = new Bitmap();
	private var itemElement:Bitmap = new Bitmap();
	
	//private var itemCont:Sprite;
	
	private var itemReadyCont:Sprite;
	private var itemUnReadyCont:Sprite;
	
	private var bttnClose:LayerX;
	private var bttnCloseB:Button;
	private var completeIcon:Bitmap;
	private var coin:Bitmap;
	private var star:Bitmap;	
	private var moneyText:TextField;
	private var expText:TextField;
	private var titleText:TextField;
	private var timerText:TextField;
	private var bttnMoney:MoneyButton;	
	public var trade:Object;
	public var mark:Bitmap = new Bitmap;	
	public var timeImg:LayerX = new LayerX();
	public var urgentTime:int = 0;	
	public var pos:int;
	public var percentDone:int = 0;		
	private var onStock:TextField;
	private var onRecipe:TextField;
	private var stock:uint;
	private var count:int;
	private var window:TradeWindow;
	
	
	private var canBeBought:Boolean;
	
	
	private var buyBttn:Button;
	private var buyBttnNow:MoneySmallButton;
	
	
	public function TradeItem(settings:Object) {
		this.settings = settings;
		this.trade = settings.trade;
		
		for (var sid:* in trade.items) {
			info = App.data.storage[sid];
			break;	
		}	
		
		count = trade.items[sid];
		stock = App.user.stock.data[sid];
			
		this.addEventListener(MouseEvent.MOUSE_OVER, onMouseOverHandler);
		this.addEventListener(MouseEvent.MOUSE_OUT, onMouseOutHandler);
		
		percentDone = getPercent();
	}

	private var isOver:Boolean;
	private function onMouseOverHandler(e:MouseEvent):void 
	{
		if (canBeBought == true && stock >= count) 
		{
			isOver = true;
			TweenLite.to(mark, 0.5, { x:mark.x, y:itemElement.y + 45 } );
			TweenLite.to(bttnClose, 0.3, { alpha:1 } );
		}
	}
	
	private function onMouseOutHandler(e:MouseEvent):void 
	{
		isOver = false;
		setTimeout(function():void {
			if (canBeBought == true && stock >= count) 
			{
				if (isOver == true)
					return
				TweenLite.to(mark, 0.5, { x:mark.x, y:itemElement.y + 10 } );
				TweenLite.to(bttnClose, 0.15, {alpha:0});
			}
		}, 200);
	}

	public function drawBttn():void {
		
		var isBuyNow:Boolean = false;
		
		var bttnSettings:Object = {
			caption     :Locale.__e("flash:1382952380277"),
			width		:123,
			height		:35,	
			fontSize	:24,
			scale		:0.8,
			hasDotes    :false
		}
		
		buyBttn = new Button(bttnSettings);
		addChild(buyBttn);
		buyBttn.x = -60;
		buyBttn.y = 57;
		
		if (stock < count)
		{
			canBeBought = false;
			buyBttn.state = Button.DISABLED;
		}else
		{
			canBeBought = true;
			buyBttn.state = Button.NORMAL;
		}
		
		buyBttn.addEventListener(MouseEvent.CLICK, onSellItem);
	}
	
	private function onSellItem(e:MouseEvent):void 
	{	
		if (e.currentTarget.mode == Button.DISABLED) return;
			e.currentTarget.state = Button.DISABLED;
		
		flyMaterial();
		onSell(trade);
		
		refresh();
	}
	private function flyMaterial():void
	{ 	
		var item1:BonusItem = new BonusItem(Stock.COINS, /*trade.reward[Stock.COINS]*/Treasures.NOMINAL_3);
		var item2:BonusItem = new BonusItem(Stock.EXP, /*trade.reward[Stock.EXP]*/Treasures.NOMINAL_3);
		
		var point1:Point = Window.localToGlobal(coin);
		var point2:Point = Window.localToGlobal(star);
		
		item1.cashMove(point1, App.self.windowContainer);
		item2.cashMove(point2, App.self.windowContainer);
	}
	
	private var isBought:Boolean = false;
	private function refresh():void 
	{
		isBought = true;
		
		drawBg();
		
		coin.visible = false;
		star.visible = false;
		moneyText.visible = false;
		expText.visible = false;
		mark.visible = false;
		buyBttn.visible = false;
		onStock.visible = false;
		onRecipe.visible = false;
		
		boughtText = Window.drawText(Locale.__e("flash:1403518557570"), {
			fontSize:	30,
			textAlign:	"center",
			color:		0xFFFFFF,
			borderColor:0x794400,
			borderSize:	5
		});
		boughtText.width = boughtText.textWidth + 10;
		boughtText.x = (background.width - boughtText.width) / 2;
		boughtText.y = 115;
		itemReadyCont.addChild(boughtText);
		
		//hideItem();
	}
	
	private function hideItem():void 
	{
		TweenLite.to(itemReadyCont, 1, { autoAlpha:0, ease:Quart.easeInOut } );
		//updateItem();
	}
	
	private function updateItem():void
	{
		//if (!App.user.stock.takeAll({5:App.data.options['TradeRefreshSkip']}))
		//return;
			
		//trade['urgentTime'] -= App.data.options['TradeRefreshTime'];
		
		coin.visible = true;
		star.visible = true;
		moneyText.visible = true;
		expText.visible = true;
		mark.visible = true;
		buyBttn.visible = true;
		onStock.visible = true;
		onRecipe.visible = true;
	}
	
	private function onSell(trade:Object):void 
	{
		if (!App.user.stock.takeAll(trade.items))
			return;
			
		if (App.user.quests.tutorial){
			settings.window.settings.onSell(trade, trade);
			settings.window.close();
		}else {
			bttnCloseB.visible = false;
			settings.window.settings.onSell(trade, trade, updateIcon);
		}
	}

	
	public function getPercent():int
	{
		var perc:int = 0;
		
		var totalCount:int = 0;
		var doneCount:int = 0;
		for (var id:* in trade.items) {
			totalCount += trade.items[id];
			var haveItms:int = 0;
			if (App.user.stock.data[id])
				haveItms = App.user.stock.data[id];
				
			if (trade.items[id] <= haveItms)
				doneCount += trade.items[id];
			else 
				doneCount += haveItms;
		}
		
		perc = doneCount / totalCount * 100;
		
		return perc;
	}
	
	public function checkMarks():void
	{
		if (App.user.stock.checkAll(trade.items)) {
			mark.visible = true;
			//bttnClose.visible = false;
			bttnClose.alpha = 0;
			//Trade.visMark(pos);
			settings.visMark(pos);
		}
		else {
			//Trade.unVisMark(pos);
			bttnClose.alpha = 1;
			settings.unVisMark(pos);
			mark.visible = false;
		}
	}
	
	public function updateInfo(trade:Object):void
	{
		for (var sid:* in trade.items) {
			info = App.data.storage[sid];
			break;	
		}	
		stock = App.user.stock.data[sid];
		count = trade.items[sid];
		Load.loading(Config.getIcon(info.type, info.view), itemLoadComplete);
		moneyText.text = trade.reward[Stock.COINS];
		expText.text = trade.reward[Stock.EXP];

		onRecipe.text = '/ ' + String(count);
		onStock.text = String(stock);
		
		if (stock < count)
			{	
				onStock.textColor = 0xf17458;
				canBeBought = false;
				buyBttn.state = Button.DISABLED;
			}else
			{
				onStock.textColor = 0xfcffff;
				canBeBought = true;
				buyBttn.state = Button.NORMAL;
			}
		
		onStock.x = -75;
		onStock.y = -75;
		onRecipe.x = onStock.x + onStock.width;
		onRecipe.y = onStock.y;
		
		checkMarks();
		
		drawBg();
		
		if (trade.time > App.time) {
			updateTime();
			setItemReady(false);
			App.self.setOnTimer(updateTime);
		}
	}
	
	public function drawBg(clicked:Boolean = false):void
	{
		if (background && background.parent) background.parent.removeChild(background);
		background = null;
		
		if (/*clicked*/canBeBought == true || stock >= count || isBought) {
			background = Window.backing(settings.width, settings.height, 43, 'shopSpecialBacking');
			itemReadyCont.addChildAt(background, 0);
			if (bttnClose != null)
			{	
				//bttnClose.visible = false;
				bttnClose.alpha = 0;
			}
		}else{
			background = Window.backing(settings.width, settings.height, 43, 'itemBacking');
			itemReadyCont.addChildAt(background, 0);
		}
	}
	
	public function drawBody():Boolean 
	{
		this.x = settings.x;
		this.y = settings.y;
		itemReadyCont = new Sprite();
		itemReadyCont.x =  - (settings.center ? (settings.width / 2) : 0);
		itemReadyCont.y =  - (settings.center ? (settings.height / 2) : 0);
		addChild(itemReadyCont);
		
		drawBg();
		
		
		itemUnReadyCont = new Sprite();
		itemUnReadyCont.x =  - (settings.center ? (settings.width / 2) : 0);
		itemUnReadyCont.y =  - (settings.center ? (settings.height / 2) : 0);
		addChild(itemUnReadyCont);
		
		var background2:Bitmap = Window.backing(settings.width, settings.height, 43, 'itemBacking');  // бекграунд ожидающего элемента
		background2.alpha = 0.5;
		itemUnReadyCont.addChild(background2);
		
		Load.loading(Config.getIcon(info.type, info.view), itemLoadComplete);
			
			bttnClose = new LayerX();
			bttnCloseB = new ImageButton(Window.textures.closeBttnSmall);
			//if (count > stock)
			//{
				bttnClose.addChild(bttnCloseB);
			//}
			
			bttnClose.y = itemReadyCont.y - 8;
			bttnClose.x = itemReadyCont.x + settings.width - bttnClose.width + 8;
			bttnClose.addEventListener(MouseEvent.CLICK, closeClick);
			
			if (Trade.saleItemId == trade.ID)
				//bttnClose.visible = false;
				bttnClose.alpha = 0;
			
			completeIcon = new Bitmap(UserInterface.textures.tick, 'auto', true);
			completeIcon.visible = false;
			completeIcon.x = (settings.width - completeIcon.width) / 2;
			completeIcon.y = (settings.height - completeIcon.height) / 2;
			
			coin = new Bitmap(UserInterface.textures.coinsIcon, 'auto', true);
			coin.scaleX = coin.scaleY = 0.80;
			star = new Bitmap(UserInterface.textures.expIcon, 'auto', true);
			star.scaleX = star.scaleY = 0.70;
			drawBttn();
		
			moneyText = Window.drawText(trade.reward[Stock.COINS], {
				width:50,
				fontSize:25,
				autoSize:"none",
				textAlign:"center",
				color:0xFFFFFF,
				borderColor:0x794400,
				borderSize:4
			}	);
			expText = Window.drawText(trade.reward[Stock.EXP], {//settings.exp
				width:50,
				fontSize:25,
				autoSize:"none",
				textAlign:"center",
				color:0xFFFFFF,
				borderColor:0x794400,
				borderSize:4
			}	);

			if (stock < count)
			{	
				onStock = Window.drawText((String(stock)), {
					width:60,
					fontSize:29,
					autoSize:"right",
					color:0xf17458,
					borderColor:0x612c1e,
					borderSize:4
					}	);
			}else
			{
				onStock = Window.drawText((String(stock)), {
					width:50,
					fontSize:29,
					autoSize:"left",
					color:0xfcffff,
					borderColor:0x612c1e,
					borderSize:4
					}	);
			}
			
			
			onRecipe = Window.drawText( '/ ' + String(count), {
				width:50,
				fontSize:29,
				autoSize:"left",
				color:0xfcffff,
				borderColor:0x612c1e,
				borderSize:4
			}	);
			
			
			
			onStock.x = -75;
			onStock.y = -75;
			onRecipe.x = onStock.x + onStock.width;
			onRecipe.y = onStock.y;
			var contRew:Sprite = new Sprite();
			
			coin.x = (settings.width - (coin.width + moneyText.width + star.width + expText.width)) / 2 + 18;
			coin.y = settings.height - 62;
			moneyText.x = coin.x + coin.width/2 + 2;
			moneyText.y = coin.y + 3;
			star.x = moneyText.x + moneyText.width + 8;
			star.y = settings.height - 62;
			expText.x = star.x + star.width/2 + 2;
			expText.y = star.y + 4;
			
			
			
			
			elementCont.addChild(itemElement);
			//elementCont.mouseEnabled = false;
			itemReadyCont.addChild(elementCont);
			itemReadyCont.addChild(mark);
			itemReadyCont.addChild(coin);
			itemReadyCont.addChild(moneyText);
			itemReadyCont.addChild(star);
			itemReadyCont.addChild(expText);
			addChild(onStock);
			addChild(onRecipe);
			itemReadyCont.addChild(completeIcon);
			addChild(bttnClose);
			
			elementCont.tip = function():Object { 
				return {
					title:info.title,
					text:info.description
				};
			};
			
			titleText = Window.drawText(Locale.__e('flash:1393584008748'), {
				width:settings.width,
				fontSize:27,
				autoSize:"center",
				color:0xf8f7d9,
				borderColor:0x5e2400,
				borderSize:4
			} );
			titleText.x = (settings.width - titleText.width) / 2;
			titleText.y = 20;
			//
			timerText = Window.drawText(String(trade.time - App.time), {
				width:settings.width,
				fontSize:36,
				autoSize:"center",
				color:0xffd303,
				borderColor:0x612503,
				borderSize:5
			} );
			timerText.x = (settings.width - timerText.width) / 2;
			timerText.y = 60;
			// Ускорить
			bttnMoney = new MoneyButton( {
					caption		:Locale.__e('flash:1382952380104'),
					width		:143,
					height		:37,	
					fontSize	:24,
					countText	:App.data.options['TradeRefreshSkip'], //material.real,
					multiline	:false,
					bgColor		:[0xa2f144, 0x7ac31d],
					borderColor	:[0xffffff, 0xffffff],
					bevelColor  :[0xb4e181, 0x5f9c11],
					fontColor	:0xffffff,
					fontBorderColor :0x497c13,
					fontCountColor	:0xFFFFFF,
					fontCountBorder :0x497c13,
					fontBorderSize	:3
					
					
					//bttnSettings["bgColor"] = [0xfdb29f, 0xed7483];
				//bttnSettings["borderColor"] = [0xffffff, 0xffffff];
				//bttnSettings["bevelColor"] = [0xfeb19f, 0xe87383];	
				//bttnSettings["fontColor"] = 0xffffff;			
				//bttnSettings["fontBorderColor"] = 0x993a40;
				//bttnSettings["greenDotes"] = false;
					
					
					
			});
			bttnMoney.x = 13;
			bttnMoney.y = 110;
			
			bttnMoney.addEventListener(MouseEvent.CLICK, moneyClick);
	
			itemUnReadyCont.addChild(titleText);
			itemUnReadyCont.addChild(timerText);
			itemUnReadyCont.addChild(bttnMoney);
			
			//itemReadyCont.addEventListener(MouseEvent.CLICK, itemClick);
			
			addChild(timeImg);
			timeImg.x = -this.width/2 + 8;
			timeImg.y = -this.height / 2 + 8;
			timeImg.visible = false;
			timeImg.mouseChildren = timeImg.mouseEnabled = false;
			
			var timeBtmp:Bitmap = new Bitmap(Window.textures.instantsTimer);
			timeBtmp.smoothing = true;
			timeImg.addChild(timeBtmp);
			timeImg.tip = function():Object { 
				return {
					title:Locale.__e('flash:1393584347112'),
					text:Locale.__e('flash:1393584363926'),
					timer:true
				};
			};
			
			if (trade.urgent == 1) showUrgentInfo(true);
			
			if (App.time >= trade.time) {
				setItemReady(true);
				checkMarks();
				if (App.user.quests.tutorial)
					showTutorialGlow();
				return true
				
			}
			updateTime();
			App.self.setOnTimer(updateTime);
			setItemReady(false);
			
			return false;
	}
	
	private function showTutorialGlow():void
	{
		startGlowing();
		App.user.quests.currentTarget = buyBttn;
		App.user.quests.lock = false;
		Quests.lockButtons = false;
		
		var that:* = this;
	}
	
	private function moneyClick(e:MouseEvent):void 
	{
		if (!App.user.stock.takeAll({5:App.data.options['TradeRefreshSkip']}))
		return;
			
		trade['urgentTime'] -= App.data.options['TradeRefreshTime'];
		
		bttnMoney.state = Button.DISABLED;
		
		Post.send({
			ctr:'Trade',
			act:'open',
			uID:App.user.id,
			tID:trade.ID,
			sID:settings.target.sid,
			wID:App.user.worldID,
			id:settings.target.id
		}, function(error:int, data:Object, params:Object):void {
			if (error)
			{
				Errors.show(error, data);
				return;
			}
			
			var point:Point = new Point(App.self.mouseX - bttnMoney.mouseX, App.self.mouseY - bttnMoney.mouseY);
			point.x += bttnMoney.width / 2;
			Hints.minus(Stock.FANT, App.data.options['TradeRefreshSkip'], point, false, App.self.tipsContainer);
			App.ui.upPanel.update();
			
			for (var trdObj:* in settings.target.trades) {
				if (settings.target.trades[trdObj].ID == trade.ID) {
					break;
				}
			}
			
			trade['time'] = App.time;
			
			App.self.setOffTimer(updateTime);
			settings.target.trades[trdObj] = trade;
			
			updateInfo(trade);
			setItemReady(true);
			bttnMoney.state = Button.NORMAL;
		});		
	}
	
	private var timeShowIcon:int;
	private function updateIcon(trade:Object):void
	{
		bttnCloseB.visible = false;
		var that:TradeItem = this;
		timeShowIcon = setTimeout(function():void {
			isBought = false;
			that.trade = trade;
			updateInfo(trade);
			setItemReady(true);
			bttnMoney.state = Button.NORMAL;
			if (boughtText)
				boughtText.parent.removeChild(boughtText);
				boughtText = null;
		}, 2000);
	}
	
	private function setFocus():void 
	{
		settings.onMoneyAccelerate(this);
	}
	
	//private function itemClick(e:MouseEvent):void {
		//settings.onClick(this);
		
		//drawBg(true);
	//}
	private function closeClick(e:MouseEvent):void 
	{
		urgentTime = 0;
		//Trade.unVisMark(pos);
		settings.unVisMark(pos);
		
		Post.send({
			ctr:'Trade',
			act:'reject',
			uID:App.user.id,
			tID:trade.ID,
			sID:settings.target.sid,
			wID:App.user.worldID,
			id:settings.target.id
		}, function(error:int, data:Object, params:Object):void {
			if (error)
			{
				Errors.show(error, data);
				return;
			}
		
			for (var trdObj:* in settings.target.trades) {
				if (settings.target.trades[trdObj].ID == trade.ID) {
					break;
				}
			}
			
			trade['items'] = data.cells[0].items;
			trade['reward'] = data.cells[0].reward;
			trade['ID'] = data.cells[0].ID;
			trade['time'] = data.cells[0].time;
			trade['urgent'] = data.cells[0].urgent;
			
			if (data.cells[0].urgent == 1) {
				urgentTime = App.data.trades[data.cells[0].ID].time + data.cells[0].time;
				trade['urgentTime'] = urgentTime;
			}
			
			settings.target.trades[trdObj] = trade;
			
			updateTime();
			App.self.setOnTimer(updateTime);
		
			setItemReady(false);
			onClose();
		});		
	}
	
	private function onClose():void
	{
		settings.onClose(this);
	}
	
	private function setItemReady(value:Boolean):void
	{	
		if (!value) 
			settings.removeItem(this);
		else {
			settings.addItem(this);
		}
		drawBg();
		
		coin.visible = value;
		star.visible = value;
		moneyText.visible = value;
		expText.visible = value;
		itemReadyCont.visible = value;
		itemUnReadyCont.visible = !value;
		bttnCloseB.visible = value;
		buyBttn.visible = value;
		onStock.visible = value;
		onRecipe.visible = value;
		
		
		if (canBeBought == false || stock < count) 
			bttnClose.alpha = 1;
		
		//if (!mark.visible)
			//bttnClose.visible = true;
		
		if (urgentTime > 0) {
			showUrgentInfo(true);
		}
		
		showUrgentInfo(false);
		
		if (value && trade.urgent == 1 && trade.urgentTime > App.time) {
			App.self.setOnTimer(updateUrgentTime);
			showUrgentInfo(true);
		}
		
		if (!value) 
			this.scaleX = this.scaleY = 1;
	}
	
	private function updateUrgentTime():void 
	{
		var urgTime:int = trade.urgentTime - App.time;
		settings.tradeInfo.updateUrgentTime(urgTime, this);
		if (urgTime - 20 <= 0) {
			App.self.setOffTimer(updateUrgentTime);
			showUrgentInfo(false);
			settings.tradeInfo.showUrgentInfo(false);
			trade['urgent'] = 0;
		}
	}
	
	private var pluckInterval:int;
	private function showUrgentInfo(value:Boolean):void 
	{
		timeImg.visible = value;
		if (value) {
			timeImg.pluck(500, -60, -10);
			pluckInterval = setInterval(function():void { timeImg.pluck(500, -60, -10); }, Math.random()*8000 + 3000);
		}else  {
			clearInterval(pluckInterval);
		}
	}
	
	private var elementCont:LayerX = new LayerX();
	private var boughtText:TextField;
	private var onOver:Boolean;
	private var bitmap:Bitmap;
	
	private function itemLoadComplete(data:Bitmap):void {
		itemElement.bitmapData = data.bitmapData;
		itemElement.smoothing = true;
		itemElement.y = -10;
		itemElement.width = data.width;
		itemElement.height = data.height;
		itemElement.scaleX = itemElement.scaleY = 0.9;
		elementCont.x = (settings.width - itemElement.width) / 2;
		elementCont.y = (settings.height - itemElement.height) / 2 - 10;
		
		mark.bitmapData = Window.textures.checkMark;
		mark.x = itemElement.x + 110;
		mark.y = itemElement.y + 10;
		
		mark.smoothing = true;
	}
	
	public function updateTime():void {
		if(timerText)
			timerText.text = getTime();
		else
			App.self.setOffTimer(updateTime);
	}
	private function getTime():String {
		time = trade.time - App.time;
		if ((trade.time - App.time) <= 0) {
			App.self.setOffTimer(updateTime);
			setItemReady(true);
			checkMarks();
			settings.setItemInFocus(this);
		}
		return TimeConverter.minutesToStr(time);
	}
	
	public function get state():String {
		return _state;
	}
	
	public function dispose():void {
		
		clearTimeout(timeShowIcon);
		
		if(bttnMoney) bttnMoney.removeEventListener(MouseEvent.CLICK, moneyClick);
		if(bttnClose) bttnClose.removeEventListener(MouseEvent.CLICK, closeClick);
		//itemReadyCont.removeEventListener(MouseEvent.CLICK, itemClick);
		
		App.self.setOffTimer(updateTime);
		App.self.setOffTimer(updateUrgentTime);
		boughtText = null;
		coin = null;
		star = null;
		moneyText = null;
		expText = null;
		titleText = null;
		timerText = null;
		onStock = null;
		onRecipe = null;
		bttnMoney = null;
		if (itemReadyCont && contains(itemReadyCont)) removeChild(itemReadyCont);
		if (itemUnReadyCont && contains(itemUnReadyCont)) removeChild(itemUnReadyCont);
		itemReadyCont = null;
		itemUnReadyCont = null;
	}
}