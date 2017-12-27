package wins 
{
	import adobe.utils.CustomActions;
	import buttons.Button;
	import buttons.ImageButton;
	import core.Load;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.text.TextField;
	import ui.UserInterface;
	
	public class HalloweenWindow extends Window 
	{
		private var windowBackground:Bitmap;
		private var timerLabel:TextField;
		
		private var ribbon:Bitmap;
		private var hwTitleLabel:TextField;
		
		private var signboard:Bitmap;
		private var signGlow:Bitmap;
		private var signIcon:Bitmap;
		private var signLabel:TextField;
		public var bttnPlus:Button;
		
		public var timeOfComplete:int = App.time + 14 * 86400;
		
		public function HalloweenWindow(settings:Object=null) 
		{
			if (!settings) settings = { };
			settings['width'] = 640;
			settings['height'] = 550;
			settings['title'] = Locale.__e('flash:1382952379765');
			settings['hasButtons'] = false;
			
			timeOfComplete = Events.timeOfComplete;
			
			super(settings);
			App.self.setOnTimer(timer);
		}
		
		override public function drawBackground():void {
			windowBackground = new Bitmap();
			layer.addChild(windowBackground);
			
			Load.loading(Config.getImage('content', 'halloweenWinBacking'), function(data:Bitmap):void {
				windowBackground.bitmapData = data.bitmapData;
			});
		}
		
		override public function drawTitle():void {}
		
		override public function drawBody():void {
			
			// Header
			ribbon = Window.backingShort(settings.width + 100, 'questRibbon');
			bodyContainer.addChild(ribbon);
			ribbon.x = (settings.width - ribbon.width) / 2;
			ribbon.y = -40;
			
			hwTitleLabel = drawText(settings.title, {
				width:			settings.width - 60,
				fontSize:		46,
				color:			0xfbfffd,
				borderColor:	0x8140a4,
				textAlign:		'center'
			});
			hwTitleLabel.x = (settings.width - hwTitleLabel.width) / 2;
			hwTitleLabel.y = ribbon.y + 12;
			bodyContainer.addChild(hwTitleLabel);
			
			signboard = Window.backingShort(150,'seedCounterBacking');
		//	signboard = new Bitmap();
			signboard.x = 20;
			signboard.y = -10;
			bodyContainer.addChild(signboard);
			/*Load.loading(Config.getImage('content', 'seedCounterBacking'), function(data:Bitmap):void {
				signboard.bitmapData = data.bitmapData;
				
				//signboard
			});*/
			
			
			var moneyCont:LayerX = new LayerX();
			bodyContainer.addChild(moneyCont);
			moneyCont.tip = function():Object {
				return {
					title:	App.data.storage[Stock.SEED].title,
					text:	App.data.storage[Stock.SEED].description
				}
			}
			
			signIcon = new Bitmap(Window.texture('halloweenMoney'), 'auto', true);
			moneyCont.addChild(signIcon);
			signIcon.x = signboard.x + 35 - signIcon.width / 2;
			signIcon.y = signboard.y + 32 - signIcon.height / 2;
			
			signLabel = drawText(countHWMoney, {
				color:			0xf9df68,
				borderColor:	0x8b431d,
				fontSize:		38,
				autoSize:		"center"
			});
			//signLabel.filters = signLabel.filters.concat(new 
			signLabel.x = signIcon.x + signIcon.width + 8;
			signLabel.y = signIcon.y + 2;
			bodyContainer.addChild(signLabel);
			
			bttnPlus = new ImageButton(Window.texture('robotPlusBttn'), {
			width:		44,
			height:		44,
			caption:	' + '
			});
			bttnPlus.x = 123;
			bttnPlus.y = 5;
			bodyContainer.addChild(bttnPlus);
			bttnPlus.addEventListener(MouseEvent.CLICK, onClickPlus);
			
			paginator.onPageCount = 1;
			paginator.itemsCount = 2;
			paginator.page = 0;
			paginator.update();
			
			createTimer();
			contentChange();
		}
		
		private function onClickPlus(e:MouseEvent):void 
		{
			if (App.user.quests.tutorial)
				return;
			
			new PurchaseWindow( {
				width:546,
				itemsOnPage:3,
				content:PurchaseWindow.createContent("Energy", {inguest:0, view:'seed'}),
				title:Locale.__e("flash:1414756616401"),
				description:Locale.__e("flash:1414756714202"),
				popup: true,
				callback:function(sID:int):void {
					var object:* = App.data.storage[sID];
					App.user.stock.add(sID, object);
					updateState();
				//	App.user.stock.
				}
			}).show();
			
		/*	this.close();
			new ShopWindow( { find:[665,666,667], forcedClosing:true } ).show();*/
		}
		
		/*override public function drawFader():void {
			super.drawFader();
			this.x -= 20;
			fader.x += 20;
		}*/
		
		public function get countHWMoney():String {
			return App.user.stock.count(Stock.COINS).toString();
		}
		
		public function timer():void {
			if (timeOfComplete - App.time < 0) {
				close();
			}else {
				if (timerLabel)
					timerLabel.text = getTime();
			}
		}
		
		private function createTimer():void {
			var timerCont:Sprite = new Sprite();
			bodyContainer.addChild(timerCont);
			
			var timerBack:Bitmap = new Bitmap();
			timerCont.addChild(timerBack);
			Load.loading(Config.getImage('content', 'halloweenTimerBacking'), function(data:Bitmap):void {
				timerBack.bitmapData = data.bitmapData;
			});
			
			var timerDescLabel:TextField = drawText(Locale.__e('flash:1393581955601'), {
				width:		100,
				textAlign:	'center',
				color:		0xf1ecd9,
				borderColor:0x513a1a,
				fontSize:	26
			});
			timerDescLabel.x = 30;
			timerDescLabel.y = -10;
			timerCont.addChild(timerDescLabel);
			
			timerLabel = drawText(getTime(), {
				width:		120,
				textAlign:	'center',
				color:		0xfff081,
				borderColor:0x47170b,
				fontSize:	40
			});
			timerLabel.x = 20;
			timerLabel.y = timerDescLabel.y + timerDescLabel.height - 10;
			timerCont.addChild(timerLabel);
			
			timerCont.x = (settings.width - timerCont.width) / 2;
			timerCont.y = settings.height - timerCont.height - 20;
		}
		private function getTime():String {
			return TimeConverter.timeToDays(timeOfComplete - App.time);
		}
		
		private var info:Array = [
			[
				{sID:646, x:446, y:242, label:'HallShopItem1'},
				{sID:662, x:251, y:207, label:'HallShopItem2'},
				{sID:611, x:57, y:256, label:'HallShopItem3'},
				{sID:603, x:364, y:40, label:'HallShopItem4'},
				{sID:626, x:144, y:40, label:'HallShopItem5' }
			],
			[
				{sID:685, x:262, y:55, label:'HallShopItem6'},
				{sID:681, x:105, y:235, label:'HallShopItem7'},
				{sID:682, x:415, y:235, label:'HallShopItem8'}
			]
		]
		private var items:Vector.<HWItem> = new Vector.<HWItem>;
		override public function contentChange():void {
			clear();
			
			for (var i:int = 0; i < this.info[paginator.page].length; i++) {
				var info:Object = this.info[paginator.page][i];
				var item:HWItem = new HWItem( {
					sID:		info.sID,
					window:		this,
					preview:	info.label
				});
				item.x = info.x;
				item.y = info.y;
				bodyContainer.addChild(item);
				items.push(item);
			}
		}
		
		public function updateState():void {
			signLabel.text = countHWMoney;
		}
		
		
		public function clear():void {
			while (items.length > 0) {
				var item:HWItem = items.shift();
				item.dispose();
			}
		}
		public function update():void {
			signLabel.text = countHWMoney;
		}
		public function blockAll(block:Boolean = true):void {
			for (var i:int = 0; i < items.length; i++) {
				if (block) {
					items[i].state = HWItem.DISABLE;
				}else {
					items[i].state = HWItem.ACTIVE;
				}
			}
		}
		
		override public function dispose():void {
			App.self.setOffTimer(timer);
			super.dispose();
		}
	}
}

import buttons.Button;
import core.Load;
import flash.display.Bitmap;
import flash.events.MouseEvent;
import flash.text.TextField;
import ui.SystemPanel;
import ui.UserInterface;
import units.Anime;
import units.Unit;
import wins.HalloweenWindow;
import wins.Window;
import wins.ShopWindow;
import wins.PurchaseWindow;

internal class HWItem extends LayerX {
	
	public static const ACTIVE:uint = 0;
	public static const DISABLE:uint = 1;
	
	public var textLabel:TextField;
	public var glow:Bitmap;
	public var sprite:LayerX;
	public var bttn:Button;
	
	
	private var bitmap:Bitmap;
	private var anime:Anime;
	private var preloader:Preloader;
	
	public var sID:int;
	public var info:Object;
	private var preview:String;
	public var window:HalloweenWindow;
	
	private var pwidth:int = 140;
	private var pheight:int = 180;
	private var _state:uint = 0;
	
	public function HWItem(params:Object):void {
		window = params.window;
		sID = params.sID;
		preview = params.preview;
		info = App.data.storage[sID] || null;
		
		if (!info) return;
		
		draw();
		
		tip = function():Object {
			return {
				title:info.title,
				text:info.description
			}
		}
	}
	
	public function set state(v:uint):void {
		bttn.state = Button.NORMAL;
		/*
		if (v == _state) return;
		_state = v;
		
		if (_state == ACTIVE) {
			if (canBuy)
				bttn.state = Button.NORMAL;
		}else {
			bttn.state = Button.DISABLED;
		}*/
	}
	public function get state():uint {
		return _state;
	}
	
	public function draw():void {
		glow = new Bitmap(Window.textures.glow, 'auto', true);
		glow.alpha = 0.75;
		glow.width = pwidth;
		glow.height = pheight;
		addChild(glow);
		
		preloader = new Preloader();
		preloader.x = pwidth / 2;
		preloader.y = pheight / 2;
		addChild(preloader);
		
		sprite = new LayerX();
		addChild(sprite);
		
		var link:String;
		if (preview.length > 0) {
			link = Config.getImage('content', preview);
		}else {
			link = Config.getIcon(info.type, info.preview);
		}
		
		Load.loading(link, onPreviewComplete);
		
		bttn = new Button( {
			width:		100,
			height:		44,
			caption:	String(getPrice()) + '   '
		});
		bttn.x = (pwidth - bttn.width) / 2;
		bttn.y = pheight - bttn.height / 2 + 8;
		addChild(bttn);
		bttn.addEventListener(MouseEvent.CLICK, onClick);
		
				
		textLabel = Window.drawText(info.title, {
			color:			0x654804,
			borderColor:	0xfff5ec,
			fintSize:		30,
			width:			140,
			multiline:		true,
			textAlign:		'center'
		});
		
		textLabel.wordWrap = true;
		textLabel.x = (pwidth - textLabel.width) / 2;
		textLabel.y = bttn.y - textLabel.height - 4;
		addChild(textLabel);
		
		var currency:Bitmap = new Bitmap(Window.texture('halloweenMoney'), 'auto', true);
		currency.scaleX = currency.scaleY = 0.6;
		currency.x = bttn.x + bttn.width - currency.width - 20;
		currency.y = bttn.y + (bttn.height - currency.height) / 2;
		addChild(currency);
		
		initBttnState();
		
		sprite.tip = function():Object {
			return {
				title:info.title,
				text:info.description
			}
		}
	}
	
	private function onClickPlus(e:MouseEvent):void 
	{
		
	}
	
	public function getPrice():int {
		for (var pr_sid:* in info.price) {
			return info.price[pr_sid];
		}
		
		return 0;
	}
	
	public function onClick(e:MouseEvent):void 
	{
	//	if (bttn.mode == Button.DISABLED) return;
		if (!canBuy)
		{
			
			new PurchaseWindow( {
				width:546,
				itemsOnPage:3,
				content:PurchaseWindow.createContent("Energy", {inguest:0, view:'seed'}),
				title:Locale.__e("flash:1414756616401"),
				description:Locale.__e("flash:1414756714202"),
				popup: true,
				callback:function(sID:int):void {
					var object:* = App.data.storage[sID];
					App.user.stock.add(sID, object);
					updateState();
				
				}
			}).show();
			
			
			return
		}
		window.blockAll();
		
		if (info.type == 'Clothing') {
			App.user.stock.buy(sID, 1);
			window.close();
			return;
		}
		
		var unit:Unit = Unit.add( { sid:sID, buy:true } );
		unit.move = true;
		App.map.moved = unit;
		
		window.close();
	}
	
	public function get canBuy():Boolean {
		if (App.user.stock.check(Stock.COINS, getPrice()))
			return true;
		
	/*	super.close();
		new ShopWindow( { find:[665,666,667], forcedClosing:true } ).show();
	*/	
					
		
				
		return false;
	}
	
	private function updateState():void {
		window.updateState();
	}
	
	private function initBttnState():void {
		if (bttn) state = (canBuy) ? ACTIVE : DISABLE;
	}
	
	private var scales:Object = {
		1683:		{ scale:1.2, x: -10, y: -10 },
		1804:		{ x:30 }
	}
	
	public function onPreviewComplete(data:Bitmap):void
	{
		removeChild(preloader);
		
		bitmap = new Bitmap();
		bitmap.bitmapData = data.bitmapData;
		bitmap.scaleX = bitmap.scaleY = 1;
		bitmap.smoothing = true;
		bitmap.x = (pwidth - bitmap.width)/ 2;
		bitmap.y = (pheight - bitmap.height) / 2;
		sprite.addChild(bitmap);
	}
	
	public function dispose():void {
		if (bttn) {
			bttn.removeEventListener(MouseEvent.CLICK, onClick);
		}
		
		if (parent) {
			parent.removeChild(this);
		}
	}
}