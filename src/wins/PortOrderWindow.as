package wins 
{
	import adobe.utils.CustomActions;
	import buttons.Button;
	import buttons.MoneyButton;
	import com.greensock.easing.Elastic;
	import com.greensock.easing.Strong;
	import com.greensock.plugins.TransformAroundPointPlugin;
	import com.greensock.plugins.TweenPlugin;
	import com.greensock.TweenLite;
	import core.IsoConvert;
	import core.Post;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.utils.setTimeout;
	/**
	 * ...
	 * @author 
	 */
	public class PortOrderWindow extends Window
	{
		public static const MODE_WAIT:int = 1;
		public static const MODE_DONE:int = 2;
		
		
		public var mode:int;
		
		public var items:Vector.<TradeItem> = new Vector.<TradeItem>;
		
		private var itemsCont:Sprite = new Sprite();
		
		private var timer:TextField;
		
		private var bttnBoost:MoneyButton;
		private var bttnTake:Button;
		
		public var dataItems:Object = {};
		
		public var shipInd:int;
		
		public var window:*;
		
		public function PortOrderWindow(shipInd:int, mode:int, window:*, settings:Object = null) 
		{
			if (settings == null) {
				settings = new Object();
			}
			this.shipInd = shipInd;
			this.window = window;
			
			dataItems = App.user.tradeshop[shipInd].items;
			
			this.mode = mode;
			
			settings['width']			= 500; 
			if (mode == MODE_DONE) {
				settings['height']			= 250;
			}else {
				settings['height']			= 320;
			}
			
			
			settings['background']      = 'tradeportSmallBacking';// 'tradingPostBackingMain';
			
			settings['hasPaginator']	= false;
			settings["hasArrows"] 		= false;
			
			settings["popup"] 		= true;
			
			settings['title']			= Locale.__e('flash:1408027518943');
			
			super(settings);
		}
		
		override public function drawBackground():void {
				
			var background:Bitmap = backing(settings.width, settings.height, 25, settings.background);
			layer.addChild(background);
		}
			
		override public function drawBody():void 
		{
			titleLabel.y -= 2;
			exit.y -= 22;
			exit.x += 4;
			
			
			drawMirrowObjs('diamondsTop', settings.width / 2 - settings.titleWidth / 2 - 5, settings.width / 2 + settings.titleWidth / 2 + 5, -40, true, true);
			
			createItems();
			
			createByMode();
		}
		
		public function reDraw():void 
		{
			for (var i:int = 0; i < items.length; i++ ) {
				var item:TradeItem = items[i];
				item.parent.removeChild(item);
				item.dispose();
				item = null;
			}
			items = new Vector.<TradeItem>;
			
			if(timer && timer.parent)
				timer.parent.removeChild(timer);
			
			if(bttnBoost){
				bttnBoost.removeEventListener(MouseEvent.CLICK, onBoostEvent);
				bttnBoost.dispose();
				bttnBoost = null;
			}
			
			if(separator){
				separator.parent.removeChild(separator);
				separator = null;
			}
			
			if(bgTime){
				bgTime.parent.removeChild(bgTime);
				bgTime = null;
			}
			
			if(desc){
				desc.parent.removeChild(desc);
				desc = null;
			}
			
			createByMode();
			createItems();
		}
		
		private function createItems():void 
		{
			bodyContainer.addChild(itemsCont);
			
			var ind:int = 1;
			var posX:int = 0;
			for (var _id:* in dataItems) { 
				
				var dataItm:Object = dataItems[_id];
				
				var type:int = TradeItem.MODE_EMPTY;
				
				if (dataItm.sold)
					type = TradeItem.MODE_BOUGHT;
				else if(mode == MODE_DONE){
					type = TradeItem.MODE_RETURN;
				}else {
					type = TradeItem.MODE_NORMAL;
				}
				
				var item:TradeItem = new TradeItem(type, this, dataItm.idslot);
				items.push(item);
				
				itemsCont.addChild(item);
				item.x = posX;
				
				item.change({sid:dataItm.sid, price:dataItm.price, count:dataItm.count, type:'Material', preview:App.data.storage[dataItm.sid].preview});
				
				posX += item.width + 4;
				ind++;
			}
			
			if (ind < 4) {
				for (var i:int = ind; i <= 3; i++ ) {
					var item2:TradeItem = new TradeItem(TradeItem.MODE_EMPTY, this, 0);
					items.push(item2);
					
					itemsCont.addChild(item2);
					item2.x = posX;
					
					posX += item2.width + 4;
				}
			}
			
			
			itemsCont.x = (settings.width - itemsCont.width) / 2;
		}
		
		private function createByMode():void 
		{
			switch(mode) {
				case MODE_DONE:
					createDone();
				break;
				case MODE_WAIT:
					createWait();
				break;
			}
		}
		
		private function createDone():void 
		{
			itemsCont.y = 30;
			
			bttnTake = new Button( {
				caption:	Locale.__e("flash:1382952379737"),
				width:		184,
				height:		60,
				fontSize:	34
			});
			bttnTake.x = (settings.width - bttnTake.width) / 2;
			bttnTake.y = settings.height - bttnTake.height/2 - 50;
			
			bodyContainer.addChild(bttnTake);
			
			bttnTake.addEventListener(MouseEvent.CLICK, onTake);
		}
		
		private function onTake(e:MouseEvent):void 
		{
			//if (!App.user.stock.checkAll())
				//return;
				
			window.blockAll(); 
			
			close();
			
			settings.target.onTake(shipInd, dataItems, window.update);
		}
		
		private var finishTime:int;
		private var leftTime:int;
		private var totalTime:int;
		private var priceSpeed:int = 0;
		private var priceBttn:int = 0;
		
		private var separator:Bitmap;
		private var bgTime:Sprite;
		private var desc:TextField;
		private function createWait():void 
		{
			itemsCont.y = 18;
			
			totalTime = App.data.storage[settings.target.sid].time * 3600; // for test
			finishTime = settings.started + totalTime; // for test
			
			priceSpeed = Math.ceil((finishTime - App.time) / App.data.options['SpeedUpPrice']);
			
			bttnBoost = new MoneyButton({
				caption		:Locale.__e('flash:1382952380104'),
				width		:190,
				height		:52,	
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
			bodyContainer.addChild(bttnBoost);
			bttnBoost.x = (settings.width - bttnBoost.width) / 2;
			bttnBoost.y = settings.height - bttnBoost.height / 2 - 50;
			
			bttnBoost.addEventListener(MouseEvent.CLICK, onBoostEvent);
			
			bgTime = new Sprite();
			bodyContainer.addChild(bgTime);
			bgTime.graphics.beginFill(0xebd099);
			bgTime.graphics.drawRoundRect(0,0,180,52, 50, 50);
			bgTime.graphics.endFill();
			
			bgTime.x = (settings.width - bgTime.width) / 2;
			bgTime.y = settings.height - bgTime.height - 86;
			
			
			desc = Window.drawText(Locale.__e('flash:1393584125850'), {
				color:			0xffffff,
				borderColor:	0x54443a,
				fontSize:		30,
				textAlign:'center'
			});
			desc.width = desc.textWidth + 20;
			bodyContainer.addChild(desc);
			desc.x = (settings.width - desc.width) / 2;
			desc.y = bgTime.y - desc.textHeight - 6;
			
			
			timer = Window.drawText(TimeConverter.timeToStr(127), {
				color:			0xffd950,
				borderColor:	0x402016,
				fontSize:		40
			});
			
			bodyContainer.addChild(timer);
			timer.y = bgTime.y + (bgTime.height - timer.textHeight) / 2 + 2;
			timer.x = settings.width / 2 - timer.textWidth/2;
			
			timer.height = timer.textHeight;
			timer.width = timer.textWidth + 10;
			
			progress();
			App.self.setOnTimer(progress)
		}
		
		private function onBoostEvent(e:Event):void 
		{
			if (!App.user.stock.check(Stock.FANT, priceBttn)) return;
			
			window.blockAll();
			
			close();
			settings.target.onBoost(shipInd, window.update);
		}
		
		
		private function progress():void
		{
			leftTime = finishTime - App.time;
			
			if (leftTime <= 0) {
				leftTime = 0;
				App.self.setOffTimer(progress);
				mode = MODE_DONE;
				reDraw();
			}
		
			timer.text = TimeConverter.timeToStr(leftTime);
			
			
			priceSpeed = Math.ceil((finishTime - App.time) / App.data.options['SpeedUpPrice']);
			
			if (App.user.quests.tutorial)
				return;
		
			if (bttnBoost && priceBttn != priceSpeed && priceSpeed != 0) {
				priceBttn = priceSpeed;
				bttnBoost.count = String(priceSpeed);
			}
		}
		
		public function stateBttn(isNormal:Boolean):void
		{
			for (var i:int = 0; i < items.length; i++) {
				var item:TradeItem = items[i];
				if (item.bttnTake) {
					if (isNormal)
						item.bttnTake.state = Button.NORMAL;
					else
						item.bttnTake.state = Button.DISABLED;
				}
			}
		}
		
		override public function dispose():void
		{
			if (bttnBoost) {
				bttnBoost.removeEventListener(MouseEvent.CLICK, onBoostEvent);
				bttnBoost.dispose();
				bttnBoost = null
			}
			
			if (bttnTake) {
				bttnTake.removeEventListener(MouseEvent.CLICK, onTake);
				bttnTake.dispose();
				bttnTake = null
			}
			
			super.dispose();
		}
		
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
import wins.PortOrderWindow;
import wins.Window;


internal class TradeItem extends Sprite {
	
	public static const MODE_BOUGHT:int = 1;
	public static const MODE_NORMAL:int = 2;
	public static const MODE_RETURN:int = 3;
	public static const MODE_EMPTY:int = 4;
	
	public var isEmpty:Boolean = true;
	
	public var sid:int;
	public var id:int;
	public var pid:int;
	
	private var window:PortOrderWindow;
	private var item:Object;
	
	private var icon:Bitmap;
	private var background:Bitmap;
	
	private var descTxt:TextField;
	private var priceTxt:TextField;
	private var countTxt:TextField;
	
	private var countCont:Sprite = new Sprite();
	
	private var preloader:Preloader = new Preloader();
	
	private var price:int;
	public var count:int;
	
	public var mode:int;
	
	public var bttnTake:Button;
	
	
	public function TradeItem(mode:int, window:PortOrderWindow, id:int):void {
		this.window = window;
		this.mode = mode;
		this.id = id;
		
		drawBackground();
		
		icon = new Bitmap();
		addChild(icon);
		
		switch(mode) {
			case MODE_BOUGHT:
				drawPrice();
				drawMark();
			break;
			case MODE_RETURN:
				drawPrice();
			break;
			case MODE_NORMAL:
				drawPrice();
			break;
			case MODE_EMPTY:
				drawDesc();
			break;
		}
	}
	
	private function onTake(e:MouseEvent):void 
	{	
		if (bttnTake.mode == Button.DISABLED)
			return;
			
		var dataObj:Object = { };
		dataObj[sid] = count;
			
		
		if (mode != MODE_BOUGHT)
			return;
			
		window.stateBttn(false);
		
		Post.send({
			ctr:window.settings.target.type,
			act:'storage',
			uID:App.user.id,
			id:id,
			wID:App.user.worldID,
			sID:window.settings.target.sid,
			ship:window.shipInd
		}, onStorageEvent);			
	}
	
	private function onStorageEvent(error:int, data:Object, params:Object):void 
	{
		if (error)
		{
			Errors.show(error, data);
			return;
		}
		
		delete App.user.tradeshop[window.shipInd].items[id];
		
		window.dataItems = App.user.tradeshop[window.shipInd].items;
		
		Treasures.bonus(Treasures.convert(data.items), new Point(window.settings.target.x, window.settings.target.y));
		
		var countItems:int = 0;
		for (var _id:* in window.dataItems) {
			countItems++;
		}
		
		if (countItems < 1) {
			window.settings.target.setFree(window.shipInd);
			window.window.update();
			window.close();
			return;
		}
		
		window.reDraw();
	}
	
	private function drawMark():void 
	{
		var mark:Bitmap = new Bitmap(Window.textures.checkMarkBig);
		mark.x = (background.width - mark.width) / 2;
		mark.y = (background.height - mark.height) / 2;
		addChild(mark);
	}
	
	private function drawBackground():void 
	{
		background = Window.backing(106, 116, 10, 'shopBackingSmall2');
		addChild(background);
	}
	
	private function drawDesc():void 
	{
		descTxt =  Window.drawText(Locale.__e("flash:1407829337190"), {
				color:0xf4e7ba,
				fontSize:30,
				borderColor:0x2b3b64,
				borderSize:0,
				autoSize:"center",
				textAlign:"center"
			}
		);
		descTxt.wordWrap = true;
		descTxt.width = background.width - 16;
		descTxt.x = (background.width - descTxt.width) / 2;
		descTxt.y = (background.height - descTxt.height) / 2;
		addChild(descTxt);
	}
	
	private function drawPrice():void 
	{
		if (mode != MODE_BOUGHT) {
			var countBg:Bitmap = new Bitmap(Window.textures.itemNumRoundBakingLight);
			countBg.x =	-4;
			countBg.y = -4;
			countCont.addChild(countBg);
			
			countTxt = Window.drawText(String(count) , {
					color:0xffffff,
					fontSize:24,
					borderColor:0x815526,
					autoSize:"center"
				}
			);
			countCont.addChild(countTxt);
			countTxt.x = countBg.x + (countBg.width - countTxt.width) / 2;
			countTxt.y = countBg.y + (countBg.height - countTxt.height) / 2 + 2;
			
			addChild(countCont);
		}
		
		if(mode != MODE_RETURN){
			var bgPrice:Bitmap = Window.backing(68,33,10,"levelUpOpenBacking");
			addChild(bgPrice);
			bgPrice.x = (background.width - bgPrice.width) / 2 + 4;
			bgPrice.y = background.height - bgPrice.height / 2 - 6;
			
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
	}
	
	private function makeEmpty():void 
	{
		descTxt.visible = true;
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
		if (mode == MODE_EMPTY)
			return;
		
		isEmpty = false;
		
		//descTxt.visible = false;
		//countCont.visible = true;
		
		sid = item.sid;
		price = item.price;
		count = item.count;
		pid = item.pid;
		
		addChild(preloader);
		preloader.x = background.width / 2;
		preloader.y = background.height / 2;
		
		Load.loading(Config.getIcon(item.type, item.preview), onLoad);
		
		updatePrice();
	}
	
	private function updatePrice():void 
	{
		if(mode != MODE_RETURN)
			priceTxt.text = String(price);
			
		if(mode != MODE_BOUGHT)
			countTxt.text = String(count);
	}
	
	private function onLoad(data:*):void 
	{
		if(contains(preloader)){
			removeChild(preloader);
		}
		
		icon.bitmapData = data.bitmapData;
		icon.scaleX = icon.scaleY = 0.7;
		icon.smoothing = true;
		icon.x = (background.width - icon.width) / 2;								
		icon.y = (background.height - icon.height) / 2 - 6;
	}
	
	public function dispose():void
	{
		window = null;
		
		if (bttnTake) {
			bttnTake.removeEventListener(MouseEvent.CLICK, onTake);
			bttnTake.dispose();
			bttnTake = null;
		}
	}
}