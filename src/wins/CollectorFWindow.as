package wins 
{
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import units.Moneyhouse;
	import units.Techno;
	/**
	 * ...
	 * @author ...
	 */
	public class CollectorFWindow extends Window
	{
		private var items:Vector.<ItemWork> = new Vector.<ItemWork>;
		
		private var itemsCont:Sprite = new Sprite();
		
		public var furry:Techno;
		
		public function CollectorFWindow(settings:Object = null) 
		{
			if (settings == null) {
				settings = new Object();
			}
			
			settings["width"] = 705;
			settings["height"] = 605;
			settings["title"] = Locale.__e('flash:1409135552193');
			settings['numItems'] = 4;
			settings['hasPaginator'] = false;
			
			var arr:Array = Techno.freeTechno();
			if (arr.length > 0)
				furry = arr[0];
			
			super(settings);
		}
		
		private var bg:Bitmap;
		override public function drawBody():void {
			
			bg = backing(settings.width - 80, settings.height - 120, 100, 'shopBackingSmall');
			bodyContainer.addChild(bg);
			
			bg.x = settings.width - bg.width >> 1;
			bg.y = 30;
			
			var desc:TextField = drawText(Locale.__e('flash:1409131223040'), {
				fontSize:26,
				color:0xffffff,
				borderColor:0x423a0b,
				autoSize:'center'
			});
			desc.width = settings.width;
			desc.x = settings.width - desc.width >> 1;
			desc.y = -4;
			bodyContainer.addChild(desc);
			
			drawMirrowObjs('diamondsTop', settings.width / 2 - settings.titleWidth / 2 - 5, settings.width / 2 + settings.titleWidth / 2 + 5, -45, true, true);
			drawMirrowObjs('diamonds', 20, settings.width - 20, 44, false, false, false, 1, -1);
			drawMirrowObjs('diamonds', 20, settings.width - 20, settings.height - 124);
			
			createItems();
		}
		
		private function createItems():void
		{
			bodyContainer.addChild(itemsCont);
			
			var posX:int = 0;
			var posY:int = 0;
			App.data.storage
			for (var i:int = 0; i < settings.numItems; i++) 
			{
				var item:ItemWork = new ItemWork(this, settings.info.sessions[i], i);
				
				item.x = posX;
				item.y = posY;
				
				posX += item.bg.width + 10;
				
				if (i == 1) {
					posX = 0;
					posY += item.bg.height + 10;
				}
				
				itemsCont.addChild(item);
				items.push(item);
			}
			
			itemsCont.x = settings.width - itemsCont.width >> 1;
			itemsCont.y = bg.y + (bg.height - (item.bg.height*2 + 10)  >> 1);
		}
		
		override public function dispose():void
		{
			var len:int = items.length;
			for (var i:int = 0; i < len; i++) 
			{
				items[i].dispose();
				items[i] = null;
			}
			
			Moneyhouse.collector = null;
			super.dispose();
		}
		
	}

}
import buttons.Button;
import core.Load;
import core.Post;
import core.TimeConverter;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.text.TextField;
import ui.UserInterface;
import units.Moneyhouse;
import units.WorkerUnit;
import wins.CollectorFWindow;
import wins.Window;

internal class ItemWork extends Sprite {
	
	public var bg:Bitmap;
	
	private var icon:Bitmap;
	
	private var window:CollectorFWindow;
	
	private var hireBttn:Button;
	
	private var data:Object;
	
	private var id:int;
	
	private var price:int;
	private var time:int;
	private var typeCurrency:int;
	
	public function ItemWork(window:CollectorFWindow, data:Object, id:int) {
		this.window = window;
		this.data = data;
		this.id = id;
		
		price = data.c;
		time = data.t;
		typeCurrency = data.m;
		
		drawBody();
		drawPriceInfo();
		drawTimeInfo();
		drawBttn();
		
		icon = new Bitmap();
		addChild(icon);
		
		Load.loading(Config.getIcon('Coins', 'gold_0' + (id+1)), onLoadIcon); 
	}
	
	private function onLoadIcon(data:*):void 
	{
		icon.bitmapData = data.bitmapData;
		icon.x = -10;
		icon.y = 14;
	}
	
	private function drawBody():void 
	{
		bg = Window.backing(280, 212, 40, 'itemBacking');
		addChild(bg);
		
	}
	
	private function drawTimeInfo():void 
	{
		var timeIcon:Bitmap = new Bitmap(Window.textures.timerBrown);
		//timeIcon.scaleX = furryIcon.scaleY = 0.7;
		timeIcon.x = 150;
		timeIcon.y = 20;
		addChild(timeIcon);
		
		var timeTxt:TextField =  Window.drawText(TimeConverter.timeToCuts(time, true, true), {
				color:0xffffff,
				fontSize:30,
				borderColor:0x5d381e,
				autoSize:"left",
				textAlign:"left"
			}
		);
		timeTxt.width = timeTxt.textWidth + 10;
		timeTxt.x = timeIcon.x + timeIcon.width + 4;;
		timeTxt.y = timeIcon.y;
		addChild(timeTxt);
	}
	
	private function drawPriceInfo():void 
	{
		var priceSettings:Object = { 
			color:0xfedb38,
			fontSize:26,
			borderColor:0x6d4b15,
			autoSize:"left",
			textAlign:"left"
		};
		
		var bgPrice:Sprite = new Sprite();
		bgPrice.graphics.beginFill(0xc9d6cf);
		bgPrice.graphics.drawRoundRect(0, 0, 144, 86, 30, 30);
		bgPrice.graphics.endFill();
		
		bgPrice.x = bg.width - bgPrice.width - 20;
		bgPrice.y = bg.height - bgPrice.height - 50;
		addChild(bgPrice);
		
		var descTxt:TextField =  Window.drawText(Locale.__e('flash:1383042563368'), {
				color:0x5b311b,
				fontSize:26,
				borderColor:0xffffff,
				autoSize:"center",
				textAlign:"center"
			}
		);
		descTxt.width = descTxt.textWidth + 10;
		descTxt.x = bgPrice.x + (bgPrice.width - descTxt.width >> 1);
		descTxt.y = bgPrice.y - 18;
		addChild(descTxt);
		
		var furryIcon:Bitmap = new Bitmap(UserInterface.textures.robotIcon);
		furryIcon.scaleX = furryIcon.scaleY = 0.7;
		furryIcon.x = bgPrice.x + 24;
		furryIcon.y = bgPrice.y + 8;
		addChild(furryIcon);
		
		var btmd:BitmapData;
		if (typeCurrency == Stock.COINS) {
			btmd = UserInterface.textures.coinsIcon;
		}else {
			btmd = UserInterface.textures.fantsIcon;
			priceSettings['borderColor'] = 0x923258;
			priceSettings['color'] = 0xfbafc9;
		}
		
		var coin:Bitmap = new Bitmap(btmd);
		coin.scaleX = coin.scaleY = 0.7;
		coin.smoothing = true;
		addChild(coin);
		
		coin.x = bgPrice.x + 24;
		coin.y = furryIcon.y + furryIcon.height + 10;
		
		var contSettings:Object = { 
			color:0xfcfad9,
			fontSize:26,
			borderColor:0x4c2d11,
			autoSize:"left",
			textAlign:"left"
		};
		
		if (!window.furry) {
			contSettings['color'] = 0xcc1836;
		}
		
		var countTxt:TextField =  Window.drawText('1', contSettings);
		countTxt.width = countTxt.textWidth + 10;
		countTxt.x = furryIcon.x + furryIcon.width + 4;;
		countTxt.y = furryIcon.y + 3;
		addChild(countTxt);
		
		
		var priceTxt:TextField =  Window.drawText(String(price), priceSettings);
		priceTxt.width = priceTxt.textWidth + 10;
		priceTxt.x = coin.x + coin.width + 3;
		priceTxt.y = coin.y;
		addChild(priceTxt);
	}
	
	private function drawBttn():void 
	{
		var bttnSettings:Object = { 
			width:180,
			height:48,
			caption:Locale.__e('flash:1409132154322')
		};
		
		if (typeCurrency == Stock.FANT) {
			bttnSettings["bgColor"]         = [0xa8f84a, 0x74bc17];
			bttnSettings["borderColor"]     = [0xffffff, 0xffffff];
			bttnSettings["bevelColor"]      = [0xc8fa8f, 0x5f9c11];
			bttnSettings["fontColor"]       = 0xffffff;				
			bttnSettings["fontBorderColor"] = 0x4d7d0e;
		}
		
		hireBttn = new Button(bttnSettings);
		hireBttn.x = bg.width - hireBttn.width >> 1;
		hireBttn.y = bg.height - 38;
		addChild(hireBttn);
		
		hireBttn.addEventListener(MouseEvent.CLICK, onHire);
		
		if (!window.furry)
			hireBttn.state = Button.DISABLED;
	}
	
	private function onHire(e:MouseEvent):void 
	{
		if (hireBttn.mode == Button.DISABLED || !App.user.stock.take(typeCurrency, price)) return;
		
		hireBttn.state = Button.DISABLED;
		
		var worker:Object = { };
		worker[window.furry.sid] = window.furry.id;
		
		var target:Object = { };
		target[window.settings.target.sid] = window.settings.target.id;
		
		Post.send({
			ctr:'Collector',
			act:'hire',
			uID:App.user.id,
			wID:App.user.worldID,
			sID:Moneyhouse.collector.sid,
			id:Moneyhouse.collector.id,
			worker:JSON.stringify(worker),
			target:JSON.stringify(target),
			session:id,
			worker:window.furry.id
		}, onHireEvent);			
	}
	
	private function onHireEvent(error:int, data:Object, params:Object):void 
	{
		if (error)
		{
			Errors.show(error, data);
			return;
		}
		
		//Moneyhouse.collector.started = data.started;
		//Moneyhouse.collector.time = data.finished - data.started;
		//Moneyhouse.collector.furry = window.furry;
		//Moneyhouse.collector.target = window.settings.target;
		//window.settings.target.furry = window.furry;
		Moneyhouse.collector.addFurry(window.furry);
		window.furry.collector = Moneyhouse.collector;
		window.furry.startCollectorWork(window.settings.target.sid, window.settings.target.id, App.time, App.time + time);
		//window.furry.goToJob(window.settings.target, WorkerUnit.BUSY);
		
		window.close();
	}
	
	public function dispose():void
	{
		window = null;
		
		if (hireBttn) {
			hireBttn.removeEventListener(MouseEvent.CLICK, onHire);
			hireBttn.dispose();
		}
		hireBttn = null;
	}
}