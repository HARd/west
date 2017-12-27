package wins 
{
	import buttons.Button;
	import buttons.MoneyButton;
	import core.Size;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import ui.Hints;
	public class SemiEventWindow extends Window 
	{
		public static var find:*;
		
		public var counterText:TextField;
		public var progressBar:ProgressBar;
		public var progressBacking:Bitmap;
		public var progressTitle:TextField;
		private var bttn:MoneyButton;
		public var floor:int = 0;
		
		public var info:Object;
		
		public function SemiEventWindow(settings:Object=null) 
		{
			if (settings == null) {
				settings = new Object();
			}
			
			info = settings.target.info;
			
			settings['width'] = 650;
			settings['height'] = 510;
			settings['shadowSize'] = 3;
			settings['shadowBorderColor'] = 0x554234;
			settings['shadowColor'] = 0x554234;
			
			settings['title'] = info.title;
			settings['description'] = settings.description || '';
			settings['hasPaginator'] = false;
			settings['hasButtons'] = false;
			
			if (settings.target.hasOwnProperty('floor'))
				floor = settings.target.floor;
			else
				floor = settings.target.level;
				
			if (!info.tower.hasOwnProperty(floor + 1)) {
				floor = 0;
			}
			
			super(settings);	
			createContent();
			
			if (settings.target.kicks >= info.tower[floor + 1].c) {
				blockItems(true);
			}
		}
		
		private function createContent():void {
			settings['content'] = [];
			for (var sID:* in info.kicks) {
				var obj:Object = { sID:sID, count:info.kicks[sID].c };
				if (info.kicks[sID].hasOwnProperty('t')) {
					obj['t'] = info.kicks[sID].t;
				}
				if (info.kicks[sID].hasOwnProperty('o')) {
					obj['o'] = info.kicks[sID].o;
				}
				if (info.kicks[sID].hasOwnProperty('k')) {
					obj['k'] = info.kicks[sID].k;
				}
				settings['content'].push(obj);
			}
				
			settings['content'].sortOn('o', Array.NUMERIC);
		}
		
		private var counterContainer:Sprite = new Sprite();
		override public function drawBody():void 
		{
			var glowBitmap:Bitmap = new Bitmap(Window.textures.glow);
			glowBitmap.scaleX = glowBitmap.scaleY = 0.40;
			glowBitmap.x += 60;
			glowBitmap.y += 20;
			bodyContainer.addChild(glowBitmap);
			
			var img:Bitmap = new Bitmap(Window.textures.treasure);
			if (settings.target.sid == 2371) img = new Bitmap(Window.textures.woodenChest);
			img.x += 75;
			img.y += 35;
			Size.size(img, 110, 110);
			bodyContainer.addChild(img);
			
			var desc:String = Locale.__e('flash:1436179970492');
			if (settings.target.sid == 934) desc = Locale.__e('flash:1444203265696');
			if (settings.target.sid == 2371) desc = Locale.__e('flash:1468929633532');
			if (settings.target.sid == 2602) desc = Locale.__e('flash:1471948934825');
			var description:TextField = Window.drawText(desc, {
				color:0x532b07,
				border:true,
				borderColor:0xfde1c9,
				fontSize:26,
				multiline:true,
				autoSize: 'center',
				textAlign:"center",
				thickness: 30,
				wrap:true,
				width:370
			});
			description.x = img.x + img.width + 20;
			description.y = 50;
			bodyContainer.addChild(description);
			
			bodyContainer.addChild(counterContainer);
			
			counterText = Window.drawText(Locale.__e('flash:1436184507316'), {
				color:0xffffff,
				borderColor:0x744207,
				fontSize:(App.lang == 'jp') ? 18 : 22,
				multiline:true,
				autoSize: 'center',
				textAlign:"center"
			});
			counterText.width = counterText.textWidth + 10;
			counterText.wordWrap = true;
			counterText.x = (settings.width - counterText.width) / 2 - 60;
			counterText.y = img.y + img.height - 10;
			counterContainer.addChild(counterText);
			
			if (App.lang == 'jp') counterText.x -= 15;
			
			var bttnSettings:Object = {
				caption:Locale.__e("flash:1382952380104"),
				width:110,
				height:40,
				fontSize:18
			};
			
			bttnSettings['bgColor'] = [0xa8f749, 0x74bc17];
			bttnSettings['borderColor'] = [0x5b7385, 0x5b7385];
			bttnSettings['bevelColor'] = [0xcefc97, 0x5f9c11];
			bttnSettings['fontColor'] = 0xffffff;			
			bttnSettings['fontBorderColor'] = 0x4d7d0e;
			bttnSettings['fontCountColor'] = 0xc7f78e;
			bttnSettings['fontCountBorder'] = 0x40680b;		
			bttnSettings['countText']	= info.tskip[Stock.FANT];
			
			bttn = new MoneyButton(bttnSettings);
			bttn.x = settings.width - bttn.width - 55;
			bttn.y = img.y + img.height - 20;
			bttn.addEventListener(MouseEvent.CLICK, onSpeed);
			counterContainer.addChild(bttn);
			
			var phase:TextField = Window.drawText(Locale.__e('flash:1436188159724', String(settings.target.floor + 1)), {
				color:0xffffff,
				borderColor:0x744207,
				fontSize: (App.lang == 'jp') ? 24 : 28,
				multiline:true,
				autoSize: 'center',
				textAlign:"center"
			});
			phase.wordWrap = true;
			phase.width = phase.textWidth + 10;
			phase.x = img.x + 10;
			phase.y = counterText.y + 30;
			bodyContainer.addChild(phase);
			
			progressBacking = Window.backingShort(400, "progBarBacking");
			progressBacking.x = phase.x + phase.width + 20;
			progressBacking.y = phase.y;
			bodyContainer.addChild(progressBacking);
			
			progressBar = new ProgressBar({win:this, width:416, isTimer:false});
			progressBar.x = progressBacking.x - 8;
			progressBar.y = progressBacking.y - 4;
			bodyContainer.addChild(progressBar);
			progressBar.progress = settings.target.kicks / info.tower[floor + 1].c;
			progressBar.start();
			
			progressTitle = drawText(progressData, {
				fontSize:32,
				autoSize:"left",
				textAlign:"center",
				color:0xffffff,
				borderColor:0x6b340c,
				shadowColor:0x6b340c,
				shadowSize:1
			});
			progressTitle.x = progressBacking.x + progressBacking.width / 2 - progressTitle.width / 2;
			progressTitle.y = progressBacking.y - 2;
			progressTitle.width = 80;
			bodyContainer.addChild(progressTitle);
			
			drawTime();			
			drawItems();
			
			counterContainer.x = (settings.width - counterContainer.width) / 2 - 175;
			counterContainer.y = 160;
			
			if (settings.target.timer == 0 || settings.target.timer + info.time - App.time <= 0) {
				counterContainer.visible = false;
				itemsContainer.visible = true;
				progressBar.visible = true;
				progressBacking.visible = true;
				progressTitle.visible = true;
			} else {
				blockItems(true);
				itemsContainer.visible = false;
				progressBar.visible = false;
				progressBacking.visible = false;
				progressTitle.visible = false;
			}
		}
		
		private var price:int = 0;
		protected function onSpeed(e:MouseEvent):void {
			price = info.tskip[Stock.FANT];
			
			if (!App.user.stock.check(Stock.FANT, price))
				return;
			
			if (e.currentTarget.mode == Button.DISABLED) return;
			e.currentTarget.state = Button.DISABLED;
			
			settings.buyKicks({
				callback:onBuyKicks
			});
		}
		
		private function onBuyKicks():void {			
			Hints.minus(Stock.FANT, price, Window.localToGlobal(bttn), false, this);
			App.user.stock.take(Stock.FANT, price);
			
			if (settings.target.timer != 0) {
				settings.target.timer = App.time - info.time;
			}
			
			counterContainer.visible = false;
			blockItems(false);
			updateCount();
		}
		
		public function get progressData():String {
			return String(settings.target.kicks) + '/' + String(info.tower[floor + 1].c);
		}
		
		protected var timerText:TextField;
		protected function drawTime():void {
			var time:int = settings.target.timer + info.time - App.time;
			timerText = Window.drawText(TimeConverter.timeToStr(time), {
				color:0xffef7e,
				letterSpacing:3,
				textAlign:"center",
				fontSize:34,
				borderColor:0x744207
			});
			timerText.width = 230;
			timerText.x = counterText.x + counterText.width - 50;
			timerText.y = counterText.y - 10;
			counterContainer.addChild(timerText);
			
			App.self.setOnTimer(updateDuration);
		}
		
		protected function updateDuration():void {
			var time:int =  settings.target.timer  + info.time - App.time;
			timerText.text = TimeConverter.timeToStr(time);
			
			if (time == 0) {
				blockItems(false);
				counterContainer.visible = false;
				itemsContainer.visible = true;
				updateCount();
			}
		}
		
		public function updateCount():void {
			progressTitle.text = progressData;
			progressBar.progress = settings.target.kicks / info.tower[floor + 1].c;
			progressBar.start();
			
			if (settings.target.timer == 0 || settings.target.timer + info.time - App.time <= 0) {
				counterContainer.visible = false;
				itemsContainer.visible = true;
				progressBar.visible = true;
				progressBacking.visible = true;
				progressTitle.visible = true;
			} else {
				counterContainer.visible = true;
				itemsContainer.visible = false;
				progressBar.visible = false;
				progressBacking.visible = false;
				progressTitle.visible = false;
				blockItems(true);
				bttn.state = Button.NORMAL;
			}
		}
		
		public function blockItems(value:Boolean):void {
			for each(var _item:EventItem in items) {
				if(value)
					_item.bttn.state = Button.DISABLED;
				else {
					_item.bttn.state = Button.NORMAL;
					_item.checkButton();
				}
			}
		}
		
		public function updateLevel():void {
			settings.upgradeEvent( {} );
			settings.content = [];
			close();
		}
		
		private var items:Array;
		public var itemsContainer:Sprite = new Sprite();
		public function drawItems():void {
			clearItems();
			
			var separator:Bitmap = Window.backingShort(settings.width - 120, 'dividerLine', false);
			separator.x = 5;
			separator.y = 10;
			separator.alpha = 0.5;
			itemsContainer.addChild(separator);
			
			var separator2:Bitmap = Window.backingShort(settings.width - 120, 'dividerLine', false);
			separator2.x = 5;
			separator2.y = 200;
			separator2.alpha = 0.5;
			itemsContainer.addChild(separator2);
			
			bodyContainer.addChild(itemsContainer);
			var target:*;
			var X:int = 0;
			var Xs:int = X;
			var Ys:int = 200;
			itemsContainer.x = 62;
			itemsContainer.y = Ys;
			if (settings.content.length == 0) return;
			for (var i:int = 0; i < 4; i++)
			{
				var item:EventItem = new EventItem(this, { info:settings.content[i]} );
				item.x = Xs;
				items.push(item);
				itemsContainer.addChild(item);
				
				Xs += item.bg.width + 15;
			}
		}
		
		public function clearItems():void {
			if (items) {
				for each(var _item:* in items) {
					itemsContainer.removeChild(_item);
					_item.dispose();
				}
			}
			items = [];
		}
		
		public override function dispose():void {
			clearItems();
			SemiEventWindow.find = null;			
			super.dispose();
		}
		
	}

}

import buttons.Button;
import buttons.MoneyButton;
import core.Load;
import core.Size;
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.text.TextField;
import ui.Hints;
import ui.UserInterface;
import wins.SemiEventWindow;
import wins.SimpleWindow;
import wins.ShopWindow;
import wins.Window;

internal class EventItem extends Sprite
{
	public var window:*;
	public var item:Object;
	public var bg:Sprite;
	private var bitmap:Bitmap;
	private var sID:uint;
	private var info:Object;
	public var bttn:Button;
	public var bttnFind:Button;
	public var glow:Boolean = false;
	
	public function EventItem(window:SemiEventWindow, data:Object)
	{
		this.info = data.info;
		this.sID = data.info.sID;
		this.item = App.data.storage[data.info.sID];
		this.window = window;
		
		bg = new Sprite();
		bg.graphics.beginFill(0xcbd4cf);
		bg.graphics.drawCircle(60, 100, 60);
		bg.graphics.endFill();
		addChild(bg);
		
		Load.loading(Config.getIcon(item.type, item.preview), onLoad);
		
		if (SemiEventWindow.find) {
			if (uint(SemiEventWindow.find) == sID) {
				glow = true;
				SemiEventWindow.find = null;
			}
		}
		
		drawTitle();
		drawBttn();
		drawCount();
	}
	
	private function onClick(e:MouseEvent):void 
	{
		if (e.currentTarget.mode == Button.DISABLED) return;
		
		switch(info.t) {
			case 2:
				if (!App.user.stock.checkAll(item.price)) {
					notEnoughMaterials();
					return;
				}
			break;
			case 3:
				if (!App.user.stock.check(sID, 1)) { 
					notEnoughMaterials();
					return;
				}
			break;
		}
		
		var sendObject:Object = {
			act:'kick',
			uID:App.user.id,
			wID:App.user.worldID,
			guest:App.user.id
		};
		
		window.blockItems(true);
		window.settings.kickEvent(sID, onKickEventComplete, info.t, sendObject, info.count);
	}
	
	private function onFind(e:MouseEvent):void {
		ShopWindow.findMaterialSource(sID);
		window.close();
	}
	
	private function notEnoughMaterials():void {
		window.close();
		//new SimpleWindow( {
			//text: Locale.__e('flash:1428055030855'),
			//title: Locale.__e('flash:1407829337190')
		//}).show();
	}
	
	private function onKickEventComplete(bonus:Object = null):void {
		var sID:uint;
		var price:uint;
		if (info.t == 1) {
			window.close();
			return;
		}
		else if (info.t == 2) {
			sID = Stock.FANT;
			price = item.price[sID];
		}
		else if (info.t == 3) {
			sID = this.sID;
			price = info.count;
		}	
		
		var X:Number = App.self.mouseX - bttn.mouseX + bttn.width / 2;
		var Y:Number = App.self.mouseY - bttn.mouseY;
		Hints.minus(sID, price, new Point(X, Y), false, App.self.tipsContainer);
		
		if (bonus){
			flyBonus(bonus);
		}
		window.blockItems(false);
		window.updateCount();
		if (window.settings.target.kicks >= window.info.tower[window.floor + 1].c && window.settings.target.timer == 0) {
			window.updateLevel();
		}
		if (window.settings.target.kicks >= window.settings.target.kicksLimit ) {
			window.settings.storageEvent(0, onStorageEventComplete);
		}
		drawCount();
	}	
	
	public function onStorageEventComplete(sID:uint, price:uint, bonus:Object = null):void {	
		if (bonus) {
			flyBonus(bonus);
		}
		
		window.updateCount();
		
		if (price == 0 ) {
			return;
		}
		
		var X:Number = App.self.mouseX - bttn.mouseX + bttn.width / 2;
		var Y:Number = App.self.mouseY - bttn.mouseY;
		Hints.minus(sID, price, new Point(X, Y), false, App.self.tipsContainer);
	}
	
	private function flyBonus(data:Object):void {
		var targetPoint:Point = Window.localToGlobal(bttn);
			targetPoint.y += bttn.height / 2;
			for (var _sID:Object in data)
			{
				var sID:uint = Number(_sID);
				for (var _nominal:* in data[sID]) {
					var nominal:uint = Number(_nominal);
					var count:uint = Number(data[sID][_nominal]);
				}
				
				var item:*;
				
				for (var i:int = 0; i < count; i++) {
					item = new BonusItem(sID, nominal);
					App.user.stock.add(sID, nominal);	
					item.cashMove(targetPoint, App.self.windowContainer)
				}			
			}
			SoundsManager.instance.playSFX('reward_1');
	}
	
	private var sprite:LayerX;
	private function onLoad(data:Bitmap):void {
		sprite = new LayerX();
		sprite.tip = function():Object {
			return {
				title: item.title,
				text: item.description
			};
		}
		
		bitmap = new Bitmap(data.bitmapData);
		Size.size(bitmap, 120, 120);
		bitmap.smoothing = true;
		sprite.x = (bg.width - bitmap.width) / 2;
		sprite.y = (bg.height - bitmap.height) / 2 + 35;
		sprite.addChild(bitmap);
		addChildAt(sprite, 1);
		
		sprite.addEventListener(MouseEvent.CLICK, searchEvent);
	}
	
	private function drawBttn():void 
	{
		var bttnSettings:Object = {
			caption:Locale.__e("flash:1382952379978"),
			width:115,
			height:40,
			fontSize:22
		}
		
		if(item.real == 0 || info.t == 1){
			bttnSettings['borderColor'] = [0xaff1f9, 0x005387];
			bttnSettings['bgColor'] = [0x70c6fe, 0x765ad7];
			bttnSettings['fontColor'] = 0x453b5f;
			bttnSettings['fontBorderColor'] = 0xe3eff1;
			
			bttn = new Button(bttnSettings);
		}
		
		if (item.real || info.t == 2) {
			
			bttnSettings['bgColor'] = [0xa8f749, 0x74bc17];
			bttnSettings['borderColor'] = [0x5b7385, 0x5b7385];
			bttnSettings['bevelColor'] = [0xcefc97, 0x5f9c11];
			bttnSettings['fontColor'] = 0xffffff;			
			bttnSettings['fontBorderColor'] = 0x4d7d0e;
			bttnSettings['fontCountColor'] = 0xc7f78e;
			bttnSettings['fontCountBorder'] = 0x40680b;		
			bttnSettings['countText']	= item.price[Stock.FANT];
			
			bttn = new MoneyButton(bttnSettings);
		}
		
		if (info.t == 3) {
			bttn = new Button(bttnSettings);
		}
		
		addChild(bttn);
		bttn.x = (bg.width - bttn.width) / 2;
		bttn.y = bg.height + 30;
		bttn.addEventListener(MouseEvent.CLICK, onClick);
		
		bttnFind = new Button({
			caption			:Locale.__e("flash:1405687705056"),
			fontColor:		0xffffff,
			fontBorderColor:0x475465,
			borderColor:	[0xfff17f, 0xbf8122],
			bgColor:		[0x75c5f6,0x62b0e1],
			bevelColor:		[0xc6edfe,0x2470ac],
			width			:115,
			height			:40,
			fontSize		:22
		});
		addChild(bttnFind);
		bttnFind.x = (bg.width - bttnFind.width) / 2;
		bttnFind.y = bg.height + 30;
		bttnFind.addEventListener(MouseEvent.CLICK, onFind);
		bttnFind.visible = false;
		
		checkButton();
	}
	
	public function checkButton():void {
		switch(info.t) {
			case 1:
				bttn.state = Button.ACTIVE;
				bttn.visible = true;
				bttnFind.visible = false;
				
				if (glow) bttn.showGlowing();
			break;
			case 2:
				if (!App.user.stock.checkAll(item.price,true)) {
					if (glow) bttn.showGlowing();
				}
			break;
			case 3:
				if (!App.user.stock.check(sID, 1)) { 
					bttn.state = Button.DISABLED;
					bttn.visible = false;
					bttnFind.visible = true;
					if (glow) bttnFind.showGlowing();
				} else {
					if (glow) bttn.showGlowing();
				}
			break;
		}
	}
	
	public function drawTitle():void {
		var textTitle:TextField = Window.drawText(item.title + ' +' + info.k, {
			width:130,
			wrap:true,
			textAlign:'center',
			color:0xffffff,
			fontSize:22,
			borderColor:0x7b3e07,
			multiline:true
		});
		textTitle.x = (bg.width - textTitle.width) / 2;
		textTitle.y += 20;
		addChild(textTitle);
	}
	
	private var textCount:TextField ;
	public function drawCount():void {		
		var count:int = App.user.stock.count(sID);
		var countText:String = 'x' + String(count);
		if (count < 1) {
			countText = '';
		}
		if (textCount) {
			removeChild(textCount);
			textCount = null;
		}
		textCount = Window.drawText(countText, {
			color:0xffffff,
			fontSize:30,
			borderColor:0x7b3e07
		});
		textCount.width = textCount.textWidth + 10;
		textCount.x = bg.x + bg.width - textCount.width;
		textCount.y = bg.y + bg.height - 10;
		addChild(textCount);
	}
	
	private function searchEvent(e:MouseEvent):void {
		Window.closeAll();
		ShopWindow.findMaterialSource(sID);
	}
	
	public function dispose():void {
		if (bttn) bttn.removeEventListener(MouseEvent.CLICK, onClick);
		if (sprite) sprite.removeEventListener(MouseEvent.CLICK, searchEvent);
		if (bttnFind) bttnFind.removeEventListener(MouseEvent.CLICK, onFind);
	}
}