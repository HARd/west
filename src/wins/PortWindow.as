package wins 
{
	import flash.events.MouseEvent;
	/**
	 * ...
	 * @author 
	 */
	public class PortWindow extends Window
	{
		
		public var sellItem:SellItem;
		public var buyItem:BuyItem;
		
		//public var mode:int;
		
		public function PortWindow(/*mode:int,*/ settings:Object = null) 
		{
			if (settings == null) {
				settings = new Object();
			}	
			
			//this.mode = mode;
			
			settings['hasPaginator']	= false;
			settings["hasArrows"] 		= false;
			
			//settings['title']			= settings.target.info.title;
			
			super(settings);
		}
		
		override public function drawBackground():void {
		}
		override public function drawTitle():void {
		}
		
		override public function drawBody():void 
		{
			this.y += 40;
			fader.y -= 40;
			
			exit.x += 100;
			exit.y += 100;
			
			buyItem = new BuyItem(this);
			bodyContainer.addChild(buyItem);
			buyItem.x = 20;
			buyItem.y = -100;
			
			sellItem = new SellItem(/*mode, */this);
			bodyContainer.addChild(sellItem);
			sellItem.x = buyItem.x + (buyItem.width - sellItem.width) / 2 - 30;
			sellItem.y = 100;
		}
		
		public function blockAll(isBlock:Boolean = true):void
		{
			sellItem.isBlock = isBlock;
			buyItem.isBlock = isBlock;
		}
		
		public function update():void
		{
			if (!buyItem)
				return;
				
			if (sellItem) {
				if (sellItem.parent)
					sellItem.parent.removeChild(sellItem);
				sellItem.dispose();
			}
			sellItem = null;
			
			sellItem = new SellItem(this);
			bodyContainer.addChild(sellItem);
			sellItem.x = buyItem.x + (buyItem.width - sellItem.width) / 2 - 30;
			sellItem.y = 100;
		}
		
		override public function dispose():void
		{
			if(sellItem)
				sellItem.dispose();
			sellItem = null;
			
			if(buyItem)
				buyItem.dispose();
			buyItem = null;
			
			super.dispose();
		}
		
	}

}
import buttons.Button;
import buttons.ImageButton;
import buttons.MixedButton2;
import buttons.MoneyButton;
import buttons.SimpleButton;
import com.flashdynamix.motion.extras.BitmapTiler;
import com.google.analytics.core.ServerOperationMode;
import com.greensock.TweenLite;
import core.Load;
import core.Post;
import core.TimeConverter;
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.filters.ColorMatrixFilter;
import flash.geom.Point;
import flash.text.TextField;
import flash.utils.clearInterval;
import flash.utils.setInterval;
import ui.Hints;
import ui.UserInterface;
import units.Tradeshop;
import wins.PortWindow;
import wins.Window;
import wins.PortSellWindow;
import wins.PortOrderWindow;
import wins.PortBuyWindow;
import wins.PortShipsWindow;


internal class SellItem extends Sprite {
	
	public static const MODE_SELL:int = 1;
	public static const MODE_WAIT:int = 2;
	
	public var window:PortWindow;
	
	private var bg:Bitmap;
	
	private var contBttn:ImageButton;
	private var bttn:Button;
	
	private var preloader:Preloader = new Preloader();
	
	public var ships:Array = [];
	//public var mode:int;
	
	private var _isBlock:Boolean = false;
	
	private var timerText:TextField;
	
	public function SellItem(/*mode:int, */window:PortWindow):void {
		this.window = window;
		//this.mode = mode;
		
		drawBody();
		//drawBttn();
		drawShipIcons();
		
		//if (mode == MODE_WAIT)
			//drawProgress();
	}
	
	private function drawProgress():void 
	{
		var desc:TextField = Window.drawText(Locale.__e('flash:1401445002043'), {
			fontSize:30,
			textAlign:"center",
			autoSize:"center",
			color:0xffffff,
			borderColor:0x2b3b64,
			multiline:true,
			wrap:true,
			width:180
		});
		//desc.wordWrap = true;
		//desc.width = 180;
		
		desc.x =  bg.x + (bg.width - desc.width) / 2;
		desc.y = 90;
		addChild(desc);
		
		var bgTime:Bitmap = Window.backingShort(150, "timeBg");
			addChild(bgTime);
			bgTime.x =  (bg.width - bgTime.width)/2;
			bgTime.y = desc.y + desc.height + 4;
		
		var time:int = window.settings.target.startedTrade + App.data.storage[window.settings.target.sid].time * 3600 - App.time;
			
		timerText = Window.drawText(TimeConverter.timeToStr(time), {
			color:0xffffff,
			letterSpacing:3,
			textAlign:"center",
			fontSize:42,
			borderColor:0x6b340c
		});
		timerText.width = 200;
		timerText.y = bgTime.y + 14;
		timerText.x = bgTime.x + (bgTime.width - timerText.textWidth)/2;
		addChild(timerText);
		
		updateDuration();
		App.self.setOnTimer(updateDuration);
	}
	
	private function updateDuration():void {
		var time:int = window.settings.target.startedTrade + App.data.storage[window.settings.target.sid].time * 3600 - App.time;
		timerText.text = TimeConverter.timeToStr(time);
		
		if (time <= 0) {
			App.self.setOffTimer(updateDuration);
			window.close();
		}
	}
	
	private function drawBody():void 
	{
		bg = Window.backing(740, 395, 10, "tradepostBacking");
		bg.smoothing = true;
		addChild(bg);
		
		//addChild(preloader);
		//preloader.x = bg.width / 2;
		//preloader.y = bg.height / 2;
		
		//Load.loading(Config.getImage('port', 'ship_bg'), onLoad);
		
	}
	
	private function drawShipIcons():void 
	{
		var cont:Sprite = new Sprite();
		addChild(cont);
		
		var posX:int = 0;
		for (var i:int = 0; i < 3; i++ ) {//поменять
			var shipItem:ShipItem = new ShipItem(i+1, this, window);
			cont.addChild(shipItem);
			
			shipItem.x = posX;
			
			ships.push(shipItem);
			
			posX += shipItem.bg.width + 12;
		}
		
		cont.x = (bg.width - (shipItem.bg.width * 3 + 24)) / 2;
		cont.y = bg.y + (bg.height - cont.height) / 2;
	}
	
	//private function onLoad(data:*):void 
	//{
		//removeChild(preloader);
		//
		//contBttn = new ImageButton(data.bitmapData);
		//
		////if(mode == MODE_SELL)
			//contBttn.addEventListener(MouseEvent.CLICK, onSell);
		////else
			////contBttn.state = Button.DISABLED;
		//
		//
		//contBttn.x = (bg.width - contBttn.width) / 2 + 4;
		//contBttn.y = (bg.height - contBttn.height) / 2 - 18;
		//addChildAt(contBttn, 1);
	//}
	
	private function drawBttn():void 
	{
		var bttnSettings:Object = {
			caption:	Locale.__e("flash:1382952380228"),//flash:1382952380277
			width:		166,
			height:		52,
			fontSize:	30,
			hasDotes:true
		};
		
		//if (mode == MODE_WAIT)
			//bttnSettings.caption = Locale.__e('flash:1382952380228');
		
		bttn = new Button(bttnSettings);
		
		bttn.addEventListener(MouseEvent.CLICK, onSell);
		
		bttn.x = (bg.width - bttn.width) / 2;
		bttn.y = bg.height - 24;
		addChild(bttn);
	}
	
	private function onSell(e:MouseEvent):void 
	{	
		if (_isBlock) return;
		//if (window.settings.target.mode == Tradeshop.MODE_FREE) {
			
			//window.close();
			//
			//new PortShipsWindow({target:window.settings.target, onSell:window.settings.onSell}).show();
			
			//new PortSellWindow( {   // перенести
				//target:window.settings.target,
				//onSell:window.settings.onSell
			//}).show();
			
			
		//}else {
			
			//Post.send({
				//ctr:window.settings.target.type,
				//act:'check',
				//uID:App.user.id
			//}, onOpenOrderEvent);			
		//}
		
		bttn.state = Button.DISABLED;
	}
	
	//private function onOpenOrderEvent(error:int, data:Object, params:Object):void 
	//{
		//if (error)
		//{
			//Errors.show(error, data);
			//return;
		//}
		//window.close();
		//
		//App.user.tradeshop.items = data.items;
		//
		//new PortOrderWindow(PortOrderWindow.MODE_WAIT, { target:window.settings.target, started:window.settings.target.startedTrade } ).show();
	//}
	
	public function dispose():void
	{
		for (var i:int = 0; i < ships.length; i++ ) {
			ships[i].dispose();
			ships[i] = null;
		}
		ships = null;
		
		if(bttn){
			bttn.removeEventListener(MouseEvent.CLICK, onSell);
			bttn.dispose();
		}
		bttn = null;
		
		if(contBttn){
			contBttn.removeEventListener(MouseEvent.CLICK, onSell);
			contBttn.dispose();
			contBttn = null;
		}
		
		App.self.setOffTimer(updateDuration);
		
		if (this.parent)
			this.parent.removeChild(this);
		
		window = null;
	}
	
	public function set isBlock(value:Boolean):void 
	{
		_isBlock = value;
		
		for (var i:int = 0; i < ships.length; i++ ) {
			ships[i].isBlock = value;
		}
	}
	
}

internal class ShipItem extends SimpleButton {
	
	public static const MODE_BUY:int = 1;
	public static const MODE_FREE:int = 2;
	public static const MODE_BUSY:int = 3;
	public static const MODE_BOUGHT_BUSY:int = 4;
	public static const MODE_DONE:int = 5;
	
	public var window:SellItem;
	public var portWindow:PortWindow;
	
	public var id:int;
	public var  mode:int;
	
	private var target:*;
	private var dataItems:Object;
	
	private var _isBlock:Boolean = false;
	
	public function ShipItem(ind:int, window:SellItem, portWindow:PortWindow):void {
		id = ind;
		this.window = window;
		this.portWindow = portWindow;
		
		for (var _ind:* in App.user.tradeshop) {
			if (_ind == ind) 
			{
				dataItems = App.user.tradeshop[ind].items;
			}
		}
		
		target = window.window.settings.target;
		drawBody();
		setMode();
		drawElements();
		drawItem();
		
		drawByMode();
		
		addEventListener(MouseEvent.CLICK, onClick);
	}
	
	private var tweenOverTime:TweenLite;
	private var tweenOverItems:TweenLite;
	private var tweenOutTime:TweenLite;
	private var tweenOutItems:TweenLite;
	override public function onOut(e:MouseEvent):void 
	{
		super.onOut(e);
		
		if (sentItemsCont && timerText) {
			tweenOutItems = TweenLite.to(sentItemsCont, 0.2, {alpha:0, onComplete:function():void{tweenOutItems = null}});
			tweenOutTime = TweenLite.to(timerText, 0.2, {y:icon.y + icon.height + 10, onComplete:function():void{tweenOutTime = null}});
		}
	}
	
	override public function onOver(e:MouseEvent):void 
	{
		super.onOver(e);
		
		endTweens();
		
		if (sentItemsCont && timerText) {
			tweenOverItems = TweenLite.to(sentItemsCont, 0.2, {alpha:1, onComplete:function():void{tweenOverItems = null}});
			tweenOverTime = TweenLite.to(timerText, 0.2, {y:icon.y + icon.height - 40, onComplete:function():void{tweenOverTime = null}});
		}
	}
	
	private function endTweens():void 
	{
		if (tweenOverItems) {
			tweenOverItems.complete();
			tweenOverItems = null;
		}
		if (tweenOverTime) {
			tweenOverTime.complete();
			tweenOverTime = null;
		}
		if (tweenOutItems) {
			tweenOutItems.complete();
			tweenOutItems = null;
		}
		if (tweenOutTime) {
			tweenOutTime.complete();
			tweenOutTime = null;
		}
	}
	
	private function drawBody():void 
	{
		bg = Window.backing(200, 282, 10, "itemBacking");
		bg.smoothing = true;
		addChild(bg);
	}
	
	private var buyBttn:MoneyButton;
	private var speedUpBttn:MoneyButton;
	private function drawElements():void
	{
		var bttnSettings:Object = {
			caption:	Locale.__e("flash:1382952380137"),
			width:		165,
			height:		49,
			fontSize:	26
		};
		var icon:Bitmap = new Bitmap(UserInterface.textures.fantsIcon, "auto", true);	
		switch (mode) 
		{
			case MODE_FREE:
				var freeText:TextField = Window.drawText(Locale.__e('flash:1394010518091'), {
					fontSize	:32,
					textAlign	:"center",
					color		:0x967454,
					borderColor	:0xf0d7ac,
					borderSize	:0
				});
				addChild(freeText);
				freeText.width = freeText.textWidth + 20;
				freeText.x = bg.x + (bg.width - freeText.width) / 2 ;
				freeText.y = bg.y + (bg.height - freeText.height) / 2 + 75;
				
				bttnSettings.caption = Locale.__e('flash:1382952380137');
				var bttn:Button = new Button(bttnSettings);
				addChild(bttn);
				bttn.x = bg.x + (bg.width - bttn.width) / 2;
				bttn.y = bg.y + bg.height - bttn.height / 2 - 15;
				//bttn.addEventListener(MouseEvent.CLICK, onClick);
				
			break;
		case MODE_BOUGHT_BUSY:
			//var totalTime:int = App.data.storage[350].time * 3600; // for test time = 3
			//var finishTime:int = App.user.tradeshop[id].start + totalTime; // for test
			//var priceSpeed:int = Math.ceil((finishTime - App.time) / App.data.options['SpeedUpPrice']);
				//speedUpBttn = new MoneyButton(/*icon,*/{
					//title			: Locale.__e("flash:1382952380104"),
					//width			:165,
					//height			:49,
					//countText		:priceSpeed,
					//fontSize		:28,
					//fontCountSize	:30,
					//hasText2		:true,
					//iconScale		:0.8,
					//bgColor			:[0xa7f648, 0x6fb415],
					//bevelColor:		[0xc6ea8d, 0x7b9b3e],
					//fontColor		:0xffffff,
					//fontBorderColor	:0x2b784f,
					//fontCountColor	:0x000000,
					//fontCountBorder	:0x2b784f
				//})
				//addChild(speedUpBttn);
				//speedUpBttn.x = bg.x + (bg.width - speedUpBttn.width) / 2 + 10;
				//speedUpBttn.y = bg.y + bg.height - speedUpBttn.height / 2 - 15;
			break;
		case MODE_BUY:
			if (window.window.settings.target.level >= id-1){
				buyBttn = new MoneyButton({
					title			: Locale.__e("flash:1382952379751"),
					width			:165,
					height			:49,
					countText		:App.data.storage[window.window.settings.target.sid].devel.obj[window.window.settings.target.level+1][Stock.FANT],//"15"/*buyShipPrice*/,
					fontSize		:28,
					fontCountSize	:30,
					textAlign		:"left",
					hasText2		:true,
					iconScale		:0.8
				})
				addChild(buyBttn);
				buyBttn.x = bg.x + (bg.width - buyBttn.width) / 2;
				buyBttn.y = bg.y + bg.height - buyBttn.height / 2 - 10;
			}
			break;
		}
		
	}
	private function setMode():void
	{
		if (App.user.tradeshop[id] && App.user.tradeshop[id].start + App.data.storage[target.sid].time * 3600 <= App.time) {
			mode = MODE_DONE;
		}else if (App.user.tradeshop[id]) {
			var isItemBought:Boolean = false;
			for (var key:* in App.user.tradeshop[id].items) {
				if(key != "start"){
					if (App.user.tradeshop[id].items[key].hasOwnProperty('sold') && App.user.tradeshop[id].items[key].sold > 0) {
						isItemBought = true;
					}
				}
			}
			
			if (isItemBought) {
				mode = MODE_BOUGHT_BUSY;
			}else {
				mode = MODE_BUSY;
			}
			
			
		}else if(id <= target.level + 1 - target.totalLevels){
			mode = MODE_FREE;
		}else {
			mode = MODE_BUY;
		}
	}
	
	private var icon:Bitmap;
	private function drawItem():void 
	{
		icon  = new Bitmap(Window.textures['boatIcon_' + id]);
		icon.scaleX *= -0.8;
		icon.scaleY = 0.8;
		icon.smoothing = true;
		icon.x = (bg.width - icon.width) / 2 + 150;
		addChild(icon);
	}
	
	private var incomeTxt:TextField;
	private var takeBttn:Button;
	private function drawByMode():void 
	{
		switch(mode) {
			case MODE_BUY:
				var iconOver:Bitmap = new Bitmap();
				if (target.level >= id){
					iconOver.bitmapData = Window.textures.plusOneSmall;
					iconOver.scaleX = iconOver.scaleY = 0.7;
					iconOver.smoothing = true;
				}else {
					iconOver.bitmapData = Window.textures.bigLock;
					iconOver.scaleX = iconOver.scaleY = 0.9;
					iconOver.smoothing = true;
				}
				iconOver.x = (bg.width - iconOver.width) / 2;
				iconOver.y = (bg.height - iconOver.height) / 2 + 50;
				addChild(iconOver);
			break;
			case MODE_FREE:
				
			break;
			case MODE_BUSY:
			case MODE_BOUGHT_BUSY:
				drawProgress();
				drawSentItems();
				drawBttn();
			break;
			case MODE_DONE:
				drawSentItems();
				sentItemsCont.alpha = 1;
				
				takeBttn = new Button( {
					height:49,
					width:165,
					caption:Locale.__e('flash:1382952379737')
				});
				takeBttn.x = (bg.width - takeBttn.width) / 2;
				takeBttn.y = bg.y + bg.height - takeBttn.height / 2 - 15;
				addChild(takeBttn);
				
				takeBttn.addEventListener(MouseEvent.CLICK, onTake, false, 500);
			break;
		}
		
		
		
		if (mode != MODE_BUY && mode != MODE_FREE) {
			var icon:Bitmap = new Bitmap(UserInterface.textures.coinsIcon);
			
			addChild(icon);
			
			var countIncome:int = 0;
			
			for each(var itemData:* in dataItems) {
				if (itemData.sold != 0)
					countIncome += itemData.price;
			}
			
			incomeTxt = Window.drawText(String(countIncome), {
				color:0xfdd21e,
				textAlign:"left",
				fontSize:36,
				borderColor:0x774702
			});
			incomeTxt.width = incomeTxt.textWidth + 10;
			addChild(incomeTxt);
			
			incomeTxt.x = bg.width - incomeTxt.width - 10;
			incomeTxt.y = 10;
			
			icon.x = incomeTxt.x - icon.width;
			icon.y = 10;
		}
	}
	
	private function onTake(e:MouseEvent):void 
	{
		e.stopImmediatePropagation();
		
		window.window.blockAll(); 
			
		window.window.settings.target.onTake(id, dataItems, window.window.update);
	}
	
	private function drawBttn():void 
	{
		//App.user.tradeshop[ind].start  start = 1407854155 [0x53ea264b]  App.time
		var totalTime:int = App.data.storage[350].time * 3600; // for test time = 3
		var finishTime:int = App.user.tradeshop[id].start + totalTime; // for test
		priceSpeed = Math.ceil((finishTime - App.time) / App.data.options['SpeedUpPrice']);
				bttnBoost = new MoneyButton({
				caption		:Locale.__e('flash:1382952380104'),
				width		:166,
				height		:50,	
				fontSize	:28,
				fontCountSize:28,
				radius		:25,
				countText	:priceSpeed,
				iconScale	:0.8,
				multiline	:true,
				setWidth:	false,
				
				fontColor:0xffffff,
				fontBorderColor:0x2b784f,
				fontCountColor:0xffffff,
				fontCountBorder:0x2b784f
			});
			addChild(bttnBoost);
			bttnBoost.x = (bg.width - bttnBoost.width) / 2;
			bttnBoost.y = bg.height - bttnBoost.height / 2 - 10;
			
			bttnBoost.addEventListener(MouseEvent.CLICK, onBoostEvent, false, 500);
	}
	
	private function onBoostEvent(e:MouseEvent):void 
	{
		e.stopImmediatePropagation();
		if (!App.user.stock.check(Stock.FANT, priceSpeed)) return;
		
		if(!App.user.quests.tutorial)
			Hints.minus(Stock.FANT, priceSpeed, Window.localToGlobal(bttnBoost), true);
		
		portWindow.blockAll();
		
		
		portWindow.settings.target.onBoost(id, portWindow.update);
	}
	
	private var sentItemsCont:Sprite;
	private var back:Bitmap;
	private var itemCont:Sprite = new Sprite();
	private var setItems:Vector.<TradeItem> = new Vector.<TradeItem>;
	private function drawSentItems():void 
	{
		sentItemsCont = new Sprite();
		sentItemsCont.mouseEnabled = sentItemsCont.mouseChildren = false;
		addChild(sentItemsCont);
		
		
		back = Window.backing(180,60,5,"searchPanelBackingPiece");
		sentItemsCont.addChild(back);
		
		var tradeItem:TradeItem;
		itemCont = new Sprite();
		for (var id:* in dataItems) {
			var dataItm:Object = dataItems[id];
			tradeItem = new TradeItem(this, dataItm.sid, dataItm.sold, mode);
			tradeItem.scaleX = tradeItem.scaleY = 0.9;
			itemCont.addChild(tradeItem);
			
			setItems.push(tradeItem);
		}
		sentItemsCont.addChild(itemCont);
		setItemsCoords();
		setCoords();
		
		sentItemsCont.x = bg.x + (bg.width - /*sentItemsCont.width*/180) / 2;
		sentItemsCont.y = icon.y + icon.height + 3;
		
		sentItemsCont.alpha = 0;
	}
	
	public function setItemsCoords():void 
	{
		var deltaX:int = 0;
		for (var i:int = 0; i < setItems.length; i++ ) {
			setItems[i].x = deltaX;
			deltaX += setItems[i].width + 5;
		}
		itemCont.x = back.x + (back.width - itemCont.width) / 2;
		itemCont.y = back.y + (back.height - itemCont.height) / 2;
	}
	
	public function setCoords():void
	{
		sentItemsCont.x = bg.x + (bg.width - back.width) / 2;
		sentItemsCont.y = icon.y + icon.height + 3;
	}
	
	private var timerText:TextField;
	public var bg:Bitmap;
	private var bttnBoost:MoneyButton;
	private var priceSpeed:int;
	private function drawProgress():void 
	{
		var time:int = App.user.tradeshop[id].start + App.data.storage[target.sid].time * 3600 - App.time;
			
		timerText = Window.drawText(TimeConverter.timeToStr(time), {
			color:0xffffff,
			textAlign:"center",
			fontSize:42,
			borderColor:0x6b340c
		});
		timerText.width = icon.width + 16;
		//timerText.y = icon.y + icon.height - 40;
		timerText.y = icon.y + icon.height+ 10;
		timerText.x = bg.x + (bg.width - timerText.width) / 2;
		addChild(timerText);
		
		updateDuration();
		App.self.setOnTimer(updateDuration);
	}
	
	private function updateDuration():void 
	{
		var time:int = App.user.tradeshop[id].start + App.data.storage[target.sid].time * 3600 - App.time;
		timerText.text = TimeConverter.timeToStr(time);
		
		if(bttnBoost){
			priceSpeed = Math.ceil((time) / App.data.options['SpeedUpPrice']);
			bttnBoost.count = String(priceSpeed);
		}
		
		if (time <= 0) {
			App.self.setOffTimer(updateDuration);
			window.window.update();
		}
	}
	
	private function onClick(e:MouseEvent):void 
	{
		if (_isBlock) return;
		
		switch(mode) {
			case MODE_BUY:
				if (window.window.settings.target.level >= id-1) {
					//window.window.close();
					//new PortShipsWindow({target:target, onSell:window.window.settings.onSell}).show();
					window.window.blockAll();
					window.window.settings.target.buyShip(id, window.window.update);
				}
			break;
			case MODE_FREE:
				new PortSellWindow(id, { 
					target:target,
					onSell:target.onSell
				}).show();
				window.window.close();
			break;
			case MODE_BUSY:
			case MODE_BOUGHT_BUSY:
				new PortOrderWindow(id, PortOrderWindow.MODE_WAIT, window.window, {target:target, started:App.user.tradeshop[id].start}).show();
			break;
			case MODE_DONE:
				new PortOrderWindow(id, PortOrderWindow.MODE_DONE, window.window, {target:target, started:App.user.tradeshop[id].start}).show();
			break;
		}
	}
	
	override public function dispose():void
	{
		if (takeBttn) {
			takeBttn.removeEventListener(MouseEvent.CLICK, onTake);
			takeBttn.dispose();
		}
		takeBttn = null;
		
		if (bttnBoost) {
			bttnBoost.addEventListener(MouseEvent.CLICK, onBoostEvent);
			bttnBoost.dispose();
		}
		bttnBoost = null;
		
		if (buyBttn) 
			buyBttn.dispose();
		buyBttn = null;
		
		if (speedUpBttn)
			speedUpBttn.dispose();
		speedUpBttn = null;
		
		for (var i:int = 0; i < setItems.length; i++) 
		{
			setItems[i].dispose();
		}
		
		App.self.setOffTimer(updateDuration);
		
		super.dispose();
		removeEventListener(MouseEvent.CLICK, onClick);
	}
	
	public function set isBlock(value:Boolean):void 
	{
		_isBlock = value;
	}
}

import buttons.Button;
import buttons.ImageButton;
import com.greensock.easing.Elastic;
import com.greensock.easing.Strong;
import com.greensock.plugins.TransformAroundPointPlugin;
import com.greensock.plugins.TweenPlugin;
import com.greensock.TweenLite;
import core.IsoConvert;
import core.Load;
import core.Post;
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.text.TextField;
import flash.utils.setTimeout;
import ui.UserInterface;
import wins.PortWindow;
import wins.PortOrderWindow;
import wins.Window;


internal class TradeItem extends Sprite {	
	public var sid:int;
	public var id:int;
	public var count:int;
	private var window:PortWindow;
	private var item:Object;
	private var icon:Bitmap;
	private var preloader:Preloader = new Preloader();
	private var price:int;
	private var isSold:Boolean;
	private var itemContainer:Sprite = new Sprite();
	
	private var parentClass:ShipItem;
	private var mode:int;
	
	public function TradeItem(parentClass:ShipItem, id:int, sold:int, mode:int):void {
		this.id = id;
		this.mode = mode;
		this.parentClass = parentClass;
		
		if (sold == 0) {
			isSold = false;
		}else
			isSold = true;
		
		addChild(itemContainer);
		icon = new Bitmap();
		itemContainer.addChild(icon);
		itemContainer.addChild(preloader);
		preloader.x = preloader.width / 2;
		preloader.y = preloader.height / 2;
		
		if(isSold && (mode == ShipItem.MODE_DONE || mode == ShipItem.MODE_BOUGHT_BUSY))
			drawMark();
		
		Load.loading(Config.getIcon(App.data.storage[id].type, App.data.storage[id].preview), onLoad);
	}
	
	private function drawMark():void 
	{
		var mark:Bitmap = new Bitmap(Window.textures.checkmarkSlim);
		mark.smoothing = true;
		mark.x = 15;
		itemContainer.addChild(mark);
	}
		
	private function onLoad(data:*):void 
	{
		if(preloader && contains(preloader)){
			itemContainer.removeChild(preloader);
		}
		
		icon.bitmapData = data.bitmapData;
		icon.scaleX = icon.scaleY = 0.6;
		icon.smoothing = true;
		
		parentClass.setItemsCoords();
		parentClass.setCoords();
	}
	
	public function dispose():void
	{
		window = null;
		preloader = null;
		
		if (icon && icon.parent)
			icon.parent.removeChild(icon);
		icon = null;
	}
}




internal class BuyItem extends Sprite {
	
	private var window:PortWindow;
	
	
	private var contBttn:ImageButton;
	private var bttn:Button;
	
	private var bg:Bitmap;
	
	private var preloader:Preloader = new Preloader();
	
	private var _isBlock:Boolean = false;
	
	public function BuyItem(window:PortWindow):void {
		this.window = window;
		
		drawBody();
		drawBttn();
	}
	
	private function drawBody():void 
	{
		bg = Window.backing(445, 500, 10, "tradepostBacking");
		bg.smoothing = true;
		addChild(bg);
		
		var titleText:TextField = Window.drawText(Locale.__e("flash:1407746200901"), {
			color			:0xffffff,
			borderColor		:0xb98659,
			textAlign		:"center",
			fontSize:48
		});
		titleText.width = titleText.textWidth + 20;
		titleText.x = bg.x +(bg.width - titleText.width) / 2;
		titleText.y = bg.y - 20;
		addChild(titleText);
		
		var backImage:Bitmap = new Bitmap(Window.textures.tradePortPic);
		backImage.x = bg.x - 45;
		backImage.y = bg.y + 20;
		addChild(backImage);
		//addChild(preloader);
		//preloader.x = bg.width / 2;
		//preloader.y = bg.height / 2;
		//
		//Load.loading(Config.getImage('port', 'trade'), onLoad);
	}
	
	//private function onLoad(data:*):void 
	//{
		//removeChild(preloader);
		//
		//contBttn = new ImageButton(data.bitmapData);
		//contBttn.addEventListener(MouseEvent.CLICK, onBuy);
		//contBttn.x = (bg.width - contBttn.width) / 2;
		//contBttn.y = (bg.height - contBttn.height) / 2 - 8;
		//addChild(contBttn);
	//}
	
	private function drawBttn():void 
	{
		bttn = new Button( {
			caption:	Locale.__e("flash:1407745575921"),
			width		:185,
			height		:69,
			textAlign	:"center",
			fontSize	:26
		});
		
		bttn.addEventListener(MouseEvent.CLICK, onBuy);
		
		bttn.x = (bg.width - bttn.width) / 2 + 70;
		bttn.y = bg.y + 100;
		addChild(bttn);
		
		var text:TextField = Window.drawText(Locale.__e("flash:1407745898903"), {
			color			:0xfff4b5,
			borderColor		:0xa27244,
			textAlign		:"center",
			fontSize:42
		});
		text.width = text.textWidth + 20;
		text.x = bttn.x +(bttn.width - text.width) / 2;
		text.y = bttn.y - 50;
		
		addChild(text);
	}
	
	private var intervalUpdate:int;
	public var canUpdate:Boolean = true;
	private function onBuy(e:MouseEvent):void 
	{
		//if (_isBlock) return;
		
		if (canUpdate) {
			canUpdate = false;
			
			intervalUpdate = setInterval(function():void { clearInterval(intervalUpdate); canUpdate = true }, 30000);
			
			Post.send({
				'ctr':window.settings.target.type,
				'act':'users',
				'uID':App.user.id,
				'sID':window.settings.target.sid,
				'wID':App.user.worldID,
				'level':App.user.level
			}, onUsersDataComplete);
		}else {
			openWindow();
		}
	}
	
	private function onUsersDataComplete(error:int, data:Object, params:Object):void 
	{
		if (error){
			Errors.show(error, data);
			return;
		}
		
		window.settings.target.dataUsers = data.slots;
		
		openWindow();
	}
	
	private function openWindow():void
	{
		window.close();
		new PortBuyWindow({target:window.settings.target}).show();
	}
	
	public function dispose():void
	{
		clearInterval(intervalUpdate);
		
		bttn.removeEventListener(MouseEvent.CLICK, onBuy);
		bttn.dispose();
		bttn = null;
		
		if(contBttn){
			contBttn.removeEventListener(MouseEvent.CLICK, onBuy);
			contBttn.dispose();
			contBttn = null;
		}
		
		window = null;
	}
	
	public function set isBlock(value:Boolean):void 
	{
		_isBlock = value;
	}
	
}