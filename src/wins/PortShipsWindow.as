package wins 
{
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	/**
	 * ...
	 * @author 
	 */
	public class PortShipsWindow extends Window
	{
		public var items:Vector.<ShipItem> = new Vector.<ShipItem>;
		private var bg:Bitmap;
		public function PortShipsWindow(settings:Object = null) 
		{
			//settings['hasPaginator']	= false;
			//settings["hasArrows"] 		= false;
			
			//settings['title']			= Locale.__e("flash:1404827862321");
			
			super(settings);
			drawBody();
		}
		
		override public function drawBackground():void
		{
			
		}
		
		private var cont:Sprite;
		override public function drawBody():void 
		{
			cont = new Sprite();
			bg = Window.backing(740, 395, 10, "tradepostBacking");
			bg.smoothing = true;
			addChild(bg);
			var posX:int = 0;
			var posY:int = 0;
			
			for (var i:int = 0; i < 3; i++ ) {
				var item:ShipItem = new ShipItem(i+1, { }, this);
				item.x = posX;
				item.y = posY;
				cont.addChild(item);
				
				items.push(item);
				
				posX += item.width + 10;
			}
			
			bodyContainer.addChild(cont);
			cont.x = -150;
			cont.y = 100;
		}
		
		public function blockAll(isBlock:Boolean = true):void
		{
			for (var i:int = 0; i < items.length; i++ ) {
				items[i].isBlock = isBlock;
			}
		}
		
		public function update():void
		{
			removeItems();
			drawBody();
		}
		
		override public function close(e:MouseEvent=null):void
		{
			removeItems();
			items = null;
			
			super.close();
		}
		
		private function removeItems():void
		{
			if(items){
				for (var i:int = 0; i < items.length; i++ ) {
					items[i].dispose();
					items[i] = null;
				}
				items = new Vector.<ShipItem>;
			}
			
			if (cont && cont.parent)
				cont.parent.removeChild(cont);
				
			cont = null;
		}
		
	}

}
import buttons.ImageButton;
import buttons.MoneyButton;
import buttons.SimpleButton;
import com.greensock.TweenLite;
import core.Load;
import core.TimeConverter;
import flash.display.Bitmap;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.text.TextField;
import wins.PortShipsWindow;
import wins.Window;
import wins.PortSellWindow;
import wins.PortOrderWindow;
import wins.SimpleWindow;


internal class ShipItem extends SimpleButton {
	
	private static const MODE_BUY:int = 1;
	private static const MODE_FREE:int = 2;
	private static const MODE_BUSY:int = 3;
	private static const MODE_BOUGHT_BUSY:int = 4;
	private static const MODE_DONE:int = 5;
	
	private var preloader:Preloader = new Preloader();
	
	private var bg:Bitmap;
	
	private var contBttn:ImageButton;
	
	public var window:PortShipsWindow;
	
	public var id:int;
	
	public var  mode:int;
	
	private var target:*;
	
	private var timerText:TextField;
	
	private var _isBlock:Boolean = false;
	
	public function ShipItem(id:int, data:Object, window:PortShipsWindow):void {
		this.window = window;
		this.id = id;
		
		target = window.settings.target;
		
		setMode();
		
		drawBody();
	}
	
	private function drawBody():void 
	{
		bg = new Bitmap(Window.textures.mapBacking);
		addChild(bg);
		
		addChild(preloader);
		preloader.x = bg.width / 2;
		preloader.y = bg.height / 2;
		
		Load.loading(Config.getImage('port', 'ship_bg'), onLoadBg);
		Load.loading(Config.getImage('port', 'ship_'+id), onLoad);
	}
	
	private function setMode():void
	{
		//if (App.user.tradeshop[id] && App.user.tradeshop[id].start + App.data.storage[target.sid].time * 3600 <= App.time) {
			//mode = MODE_DONE;
		//}else if (App.user.tradeshop[id]) {
			//var isItemBought:Boolean = false;
			//for (var key:* in App.user.tradeshop[id].items) {
				//if(key != "start"){
					//if (App.user.tradeshop[id].items[key].hasOwnProperty('sold') && App.user.tradeshop[id].items[key].sold > 0) {
						//isItemBought = true;
					//}
				//}
			//}
			//
			//if (isItemBought) {
				//mode = MODE_BOUGHT_BUSY;
			//}else {
				//mode = MODE_BUSY;
			//}
			//
			//
		//}else if(id <= target.level + 1 - target.totalLevels){
			//mode = MODE_FREE;
		//}else {
			//mode = MODE_BUY;
		//}
	}
	
	private function onLoadBg(data:*):void 
	{
		var bgShip:Bitmap = new Bitmap();
		bgShip.bitmapData = data.bitmapData;
		
		
		bgShip.x = (bg.width - bgShip.width) / 2 + 4;
		bgShip.y = (bg.height - bgShip.height) / 2 - 18;
		addChildAt(bgShip, 1);
	}
	
	private function onLoad(data:*):void 
	{
		removeChild(preloader);
		
		contBttn = new ImageButton(data.bitmapData);
		
		
		contBttn.addEventListener(MouseEvent.CLICK, onClick);
		
		
		contBttn.x = (bg.width - contBttn.width) / 2 + 13;
		contBttn.y = (bg.height - contBttn.height) / 2 - 23;
		addChildAt(contBttn, 2);
		
		drawByMode();
	}
	
	private function drawByMode():void 
	{
		switch(mode) {
			case MODE_BUY:
				drawBuy();
			break;
			case MODE_FREE:
				
			break;
			case MODE_BUSY:
			case MODE_BOUGHT_BUSY:
				drawProgress();
			break;
			case MODE_DONE:
				var arrow:Bitmap = new Bitmap(Window.textures.markBig);
				arrow.smoothing = true;
				addChild(arrow);
				arrow.x = (contBttn.width - arrow.width) / 2 + 20;
				arrow.y = (contBttn.height - arrow.height) / 2 + 2;
			break;
		}
	}
	
	private var buyBttn:MoneyButton;
	private function drawBuy():void 
	{
		if (target.level >= id){
			var plusIcon:Bitmap = new Bitmap(Window.textures.plusOne);
			plusIcon.x = (bg.width - plusIcon.width) / 2;
			plusIcon.y = (bg.height - plusIcon.height) / 2 - 6;
			addChild(plusIcon);
			
			buyBttn = new MoneyButton({
				caption		:Locale.__e('flash:1382952379751'),
				width		:190,
				height		:52,	
				fontSize	:28,
				fontCountSize:28,
				radius		:25,
				countText	:App.data.storage[target.sid].devel.obj[target.level+1][Stock.FANT],
				iconScale	:0.8,
				multiline	:true,
				setWidth:	false,
				
				fontColor:0xffffff,
				fontBorderColor:0x2b784f,
				fontCountColor:0xffffff,
				fontCountBorder:0x2b784f
			});
			addChild(buyBttn);
			buyBttn.x = (bg.width - buyBttn.width) / 2;
			buyBttn.y = bg.height - 30;
			
			buyBttn.addEventListener(MouseEvent.CLICK, onClick);
		}else {
			var lock:Bitmap = new Bitmap();
			addChild(lock);
			Load.loading(Config.getImage('interface', 'lock'), function(data:Bitmap):void {
				lock.bitmapData = data.bitmapData;
				lock.x = (bg.width - lock.width) / 2;
				lock.y = (bg.height - lock.height) / 2 - 16;
				lock.smoothing = true;
			});
		}
	}
	
	private var finishTime:int;
	private var leftTime:int;
	private var totalTime:int;
	private var priceSpeed:int = 0;
	private var priceBttn:int = 0;
	private var bttnBoost:MoneyButton;
	private function drawProgress():void 
	{
		//var desc:TextField = Window.drawText(Locale.__e('flash:1401445002043'), {
			//fontSize:30,
			//textAlign:"center",
			//autoSize:"center",
			//color:0xffffff,
			//borderColor:0x2b3b64,
			//multiline:true,
			//wrap:true,
			//width:180
		//});
		//
		//desc.x =  bg.x + (bg.width - desc.width) / 2;
		//desc.y = 90;
		//addChild(desc);
		//
		//var bgTime:Bitmap = Window.backingShort(150, "timeBg");
			//addChild(bgTime);
			//bgTime.x =  (bg.width - bgTime.width)/2;
			//bgTime.y = desc.y + desc.height + 4;
		//
		//var time:int = App.user.tradeshop[id].start + App.data.storage[window.settings.target.sid].time * 3600 - App.time;
			//
		//timerText = Window.drawText(TimeConverter.timeToStr(time), {
			//color:0xf8d74c,
			//letterSpacing:3,
			//textAlign:"left",
			//fontSize:34,
			//borderColor:0x502f06
		//});
		//timerText.width = bgTime.width;
		//timerText.y = bgTime.y + 12;
		//timerText.x = bgTime.x + 13;
		//addChild(timerText);
		//
		//
		//totalTime = App.data.storage[target.sid].time * 3600; // for test
		//finishTime = App.user.tradeshop[id].start + totalTime; // for test
		//
		//priceSpeed = Math.ceil((finishTime - App.time) / App.data.options['SpeedUpPrice']);
		//
		//bttnBoost = new MoneyButton({
			//caption		:Locale.__e('flash:1404912134417'),
			//width		:190,
			//height		:52,	
			//fontSize	:28,
			//fontCountSize:28,
			//radius		:25,
			//countText	:priceSpeed,
			//iconScale	:0.8,
			//multiline	:true,
			//setWidth:	false,
			//
			//fontColor:0xffffff,
			//fontBorderColor:0x2b784f,
			//fontCountColor:0xffffff,
			//fontCountBorder:0x2b784f
		//});
		//addChild(bttnBoost);
		//bttnBoost.x = (bg.width - bttnBoost.width) / 2;
		//bttnBoost.y = bg.height - 30;
		//
		//bttnBoost.addEventListener(MouseEvent.CLICK, onBoostEvent);
		//
		//
		//updateDuration();
		//App.self.setOnTimer(updateDuration);
	}
	
	private function onBoostEvent(e:MouseEvent):void 
	{
		if (!App.user.stock.check(Stock.FANT, priceBttn)) return;
		
		window.blockAll();
		
		target.onBoost(id, window.update);
	}
	
	private function updateDuration():void {
		//var time:int = App.user.tradeshop[id].start + App.data.storage[window.settings.target.sid].time * 3600 - App.time;
		//timerText.text = TimeConverter.timeToStr(time);
		//
		//if (time <= 0) {
			//App.self.setOffTimer(updateDuration);
			//window.update();
		//}
	}
	
	private function onClick(e:MouseEvent):void 
	{	
		if (_isBlock) return;
		
		switch(mode) {
			case MODE_BUY:
				if (target.level >= id) {
					new SimpleWindow( {
						label:SimpleWindow.ATTENTION,
						title:Locale.__e('flash:1382952379751'),
						text:Locale.__e("flash:1404911152634"),
						dialog:true,
						//forcedClosing:true,
						popup:true,
						buttonText:Locale.__e('flash:1382952379751'),
						confirm:function():void {
							target.buyShip(id, window.update);
							window.blockAll();
						}
					}).show();
				}
			break;
			case MODE_FREE:
				new PortSellWindow(id, { 
					target:window.settings.target,
					onSell:window.settings.onSell
				}).show();
				window.close();
			break;
			case MODE_BUSY:
			case MODE_BOUGHT_BUSY:
				//new PortOrderWindow(id, PortOrderWindow.MODE_WAIT, window, {target:target, started:App.user.tradeshop[id].start}).show();
			break;
			case MODE_DONE:
				//new PortOrderWindow(id, PortOrderWindow.MODE_DONE, window, {target:target, started:App.user.tradeshop[id].start}).show();
			break;
		}
	}
	
	override public function dispose():void
	{
		App.self.setOffTimer(updateDuration);
		
		if (buyBttn) {
			buyBttn.removeEventListener(MouseEvent.CLICK, onClick);
			buyBttn.dispose();
			buyBttn = null;
		}
		
		if(bttnBoost){
			bttnBoost.removeEventListener(MouseEvent.CLICK, onBoostEvent);
			bttnBoost.dispose();
			bttnBoost = null;
		}
		
		if (this.parent)
			this.parent.removeChild(this);
		
		if(contBttn){
			contBttn.removeEventListener(MouseEvent.CLICK, onClick);
			contBttn.parent.removeChild(contBttn);
			contBttn = null;
		}
		
		super.dispose();
	}
	
	public function set isBlock(value:Boolean):void 
	{
		_isBlock = value;
	}
}