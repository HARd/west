package wins 
{
	import api.com.odnoklassniki.events.ApiCallbackEvent;
	import buttons.Button;
	import buttons.ImageButton;
	import core.Load;
	import core.Size;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import ui.UserInterface;
	import units.Resourcehouse;
	public class ResourcehouseWindow extends Window 
	{
		public var target:Resourcehouse;
		public var currency:int;
		private var curIco:Bitmap;
		private var curLabel:TextField;
		private var addBttn:ImageButton;
		private var upgradeButton:Button;
		public function ResourcehouseWindow(settings:Object=null) 
		{
			if (settings == null) {
				settings = new Object();
			}
			
			settings["width"] = 640;
			settings["height"] = 610;
			settings["background"] = 'goldBacking';
			settings["hasPaginator"] = true;
			settings["hasArrows"] = true;
			settings["itemsOnPage"] = 3;
			settings["content"] = [];
			
			if (settings.hasOwnProperty('target')) this.target = settings.target;
			settings['title'] = target.info.title;
			
			for (var i:int = 0; i < target.info.devel.req[target.level].sl; i++) {
				var obj:Object = { };
				if (settings.slots.hasOwnProperty(i + 1)) {
					obj['time'] = settings.slots[i + 1];
				}
				settings.content.push(obj);
			}
			
			super(settings);
			
			for (var s:* in target.currPrice) {
				currency = s;
			}
			
			App.self.addEventListener(AppEvent.ON_CHANGE_STOCK, onStockChange);
		}
		
		override public function drawBody():void {
			var desc:TextField = drawText(Locale.__e('flash:1470653299999'), {
				width:settings.width - 200,
				color:0x5e3b15,
				border:false,
				fontSize:25,
				textAlign:'center'
			});
			desc.x = 150;
			desc.y = 10;
			bodyContainer.addChild(desc);
			
			addCurrency();
			contentChange();
			
			if (target.level == target.totalLevels)
				return;
				
			var upgradeParams:Object = {
				caption:Locale.__e('flash:1425574338255'),
				bgColor:[0x7bc9f9, 0x60aedf],
				bevelColor:[0xa5ddfb, 0x266fad],
				borderColor:[0xd5c2a9, 0xbca486],
				fontSize:26,
				fontBorderColor:0x40505f,
				shadowColor:0x40505f,
				shadowSize:4,
				width:210,
				height:52
			};
			upgradeButton = new Button(upgradeParams);
			upgradeButton.x = settings.width / 2 - upgradeButton.width / 2;
			upgradeButton.y = settings.height - upgradeButton.height - 10;
			
			bodyContainer.addChild(upgradeButton);
			upgradeButton.addEventListener(MouseEvent.CLICK, onUpgradeButtonEvent);
		}
		
		private function addCurrency():void {
			var shine:Bitmap = new Bitmap(Window.texture('iconGlow'));
			shine.y -= 40;
			shine.scaleY = 0.8;
			bodyContainer.addChild(shine);
			
			var text:TextField = drawText(Locale.__e('flash:1425978184363'), {
				color:      	0xffffff,
				borderColor: 	0x854a3c,
				fontSize:		24
			});
			text.x = shine.x + (shine.width - text.textWidth) / 2;
			text.y -= 20;
			bodyContainer.addChild(text);
			
			curIco = new Bitmap();			
			Load.loading(Config.getIcon(App.data.storage[currency].type, App.data.storage[currency].preview), function(data:*):void {
				curIco.bitmapData = data.bitmapData;
				Size.size(curIco, 50, 50);
				curIco.y += 5;
				curIco.x += 15;
				bodyContainer.addChild(curIco);
			});
			
			curLabel = drawText(String(App.user.stock.count(currency)), {
				color:      	0xffeb96,
				borderColor: 	0x414311,
				fontSize:		32
			});
			curLabel.x = shine.x + (shine.width - curLabel.textWidth) / 2 + 5;
			curLabel.y += 10;
			bodyContainer.addChild(curLabel);
			
			addBttn = new ImageButton(Window.texture('interAddBttnGreen'));
			addBttn.x = curLabel.x + curLabel.textWidth + 15;
			addBttn.y = curLabel.y;
			bodyContainer.addChild(addBttn);
			
			addBttn.addEventListener(MouseEvent.CLICK, onAddCurrency);
			
			var helpBttn:ImageButton = new ImageButton(UserInterface.textures.lens);
			helpBttn.x = 535;
			helpBttn.y = -15;
			helpBttn.addEventListener(MouseEvent.CLICK, onHelp);
			bodyContainer.addChild(helpBttn);
		}
		
		private function onAddCurrency(e:MouseEvent):void {
			var content:Array = PurchaseWindow.createContent("Energy", {view:App.data.storage[currency].preview})
			new PurchaseWindow( {
				width:595,
				itemsOnPage:content.length,
				content:content,
				title:App.data.storage[currency].title,
				fontBorderColor:0xd49848,
				shadowColor:0x553c2f,
				shadowSize:4,
				description:App.data.storage[currency].description,
				popup: true,
				closeAfterBuy: false,
				callback:function(sID:int):void {
					var object:* = App.data.storage[sID];
					App.user.stock.add(sID, object);
				}
			}).show();
			return;
		}
		
		private function onHelp(e:MouseEvent):void {
			new SimpleWindow( {
				label:SimpleWindow.ATTENTION,
				text:Locale.__e('flash:1470752900845'),
				title:Locale.__e('flash:1382952379893'),
				popup:true
			}).show();
		}
		
		private function onUpgradeButtonEvent(e:MouseEvent):void {
			for each (var slot:* in target.slots) {
				if (slot + target.worktime > App.time) {
					new SimpleWindow( {
						label:SimpleWindow.ATTENTION,
						text:Locale.__e('flash:1470818409192'),
						title:Locale.__e('flash:1382952379893'),
						popup:true
					}).show();
					return;
				} else if (slot > 0 && slot + target.worktime <= App.time) {
					new SimpleWindow( {
						label:SimpleWindow.ATTENTION,
						text:Locale.__e('flash:1472197424684'),
						title:Locale.__e('flash:1382952379893'),
						popup:true
					}).show();
					glowSlots();
					return;
				}
			}
			target.openConstructWindow();
			close();
		}
		
		private function onStockChange(e:AppEvent):void {
			if (curLabel) curLabel.text = String(App.user.stock.count(currency));
		}
		
		private function glowSlots():void {
			if (items) {
				for each(var _item:* in items) {
					_item.glowButton();
				}
			}
		}
		
		private var items:Array;
		private var itemsContainer:Sprite = new Sprite();
		override public function contentChange():void {
			if (items) {
				for each(var _item:* in items) {
					itemsContainer.removeChild(_item);
					_item.dispose();
				}
			}
			items = [];
			
			bodyContainer.addChild(itemsContainer);
			var target:*;
			var X:int = 0;
			var Ys:int = 35;
			itemsContainer.y = Ys;
			if (settings.content.length < 1) return;
			for (var i:int = paginator.startCount; i < paginator.finishCount; i++)
			{
				var time:int = (settings.content[i].hasOwnProperty('time')) ? settings.content[i].time : 0;
				var item:WorkerSlot = new WorkerSlot(this, { slot:i + 1, start:time } );
				item.y = Ys;
				items.push(item);
				itemsContainer.addChild(item);
				
				Ys += 135 + 15;
			}
			
			if (settings.content.length < 4) itemsContainer.x = (settings.width - itemsContainer.width) / 2;
		}
		
		override public function drawArrows():void 
		{			
			paginator.drawArrow(bottomContainer, Paginator.LEFT,  0, 0, { scaleX: -1, scaleY:1 } );
			paginator.drawArrow(bottomContainer, Paginator.RIGHT, 0, 0, { scaleX:1, scaleY:1 } );
			
			var y:int = (settings.height - paginator.arrowLeft.height) / 2 + 45;
			paginator.arrowLeft.x = -40;
			paginator.arrowLeft.y = y + 5;
			
			paginator.arrowRight.x = settings.width - paginator.arrowRight.width + 15;
			paginator.arrowRight.y = y + 5;
			
			paginator.x = int((settings.width - paginator.width)/2 - 30);
			paginator.y = int(settings.height - paginator.height - 15);
		}
		
		public override function dispose():void {
			if (items) {
				for each(var _item:* in items) {
					itemsContainer.removeChild(_item);
					_item.dispose();
				}
			}
			items = [];
			
			super.dispose();
		}
	}

}
import buttons.Button;
import buttons.MoneyButton;
import core.Load;
import core.Size;
import core.TimeConverter;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.text.TextField;
import wins.ProgressBar;
import wins.Window;

internal class WorkerSlot extends Sprite
{
	public var sWidth:int = 525;
	public var sHeight:int = 130;
	private var window:*;
	private var background:Bitmap;
	private var materialBack:Bitmap;
	private var startBttn:Button;
	private var storageBttn:Button;
	private var speedBttn:MoneyButton;
	private var progressBar:ProgressBar;
	private var progressBacking:Bitmap;
	
	public var slot:uint;
	public var startTime:uint = 0;
	public function WorkerSlot(window:*, data:Object)
	{
		this.window = window;
		this.slot = data.slot;
		this.startTime = data.start;
		
		var separator:Bitmap = Window.backingShort(sWidth, 'dividerLine', false);
		separator.x = 5;
		separator.y = 5;
		separator.alpha = 0.5;
		addChild(separator);
		
		var separator2:Bitmap = Window.backingShort(sWidth, 'dividerLine', false);
		separator2.scaleY = -1;
		separator2.x = separator.x;
		separator2.y = 135;
		separator2.alpha = 0.5;
		addChild(separator2);
		
		drawWorker();
		drawNeed();
		drawMaterial();
		drawButtons();
		
		checkSlot();
	}
	
	private function drawWorker():void {
		background = Window.backing(sHeight, 145, 10, 'itemBacking');
		background.y = -5;
		addChild(background);
		
		Load.loading(Config.getImage('content', 'WORKER1PIC'), onLoad);
	}
	
	private function onLoad(data:*):void {
		var pic:Bitmap = new Bitmap(data.bitmapData);
		pic.x = 10;
		pic.y = -10;
		addChild(pic);
	}
	
	private var materialSprite:Sprite = new Sprite();
	private function drawMaterial():void {
		addChild(materialSprite);
		
		progressBacking = Window.backingShort(290, "progBarBacking");
		progressBacking.x = background.x + background.width + ((sWidth - background.width) - progressBacking.width) / 2;
		progressBacking.y = (sHeight - progressBacking.height) / 2;
		materialSprite.addChild(progressBacking);
		
		progressBar = new ProgressBar({win:window, width:306, isTimer:true});
		progressBar.x = progressBacking.x - 8;
		progressBar.y = progressBacking.y - 4;
		materialSprite.addChild(progressBar);
		progressBar.start();
		
		speedBttn = new MoneyButton( {
			caption		:Locale.__e('flash:1382952380021'),
			width		:180,
			height		:40,	
			fontSize	:26,
			countText	:window.target.info.devel.req[window.target.level].skip,
			iconScale	:0.6
		});
		speedBttn.x = progressBacking.x + (progressBacking.width - speedBttn.width) / 2;
		speedBttn.y = progressBacking.y + progressBacking.height + 7;
		speedBttn.addEventListener(MouseEvent.CLICK, onSpeed);
		materialSprite.addChild(speedBttn);
		
		App.self.setOnTimer(progress);
	}
	
	private function progress():void {
		if (!progressBar) return;
		if (startTime + window.target.worktime > App.time) {
			progressBar.progress = (App.time - startTime ) / window.target.worktime;
			progressBar.time = startTime + window.target.worktime - App.time;
			
		}
		
		checkSlot();
	}
	
	private function drawButtons():void {
		startBttn = new Button( {
			caption:Locale.__e('flash:1470732370605')
		});
		startBttn.x = background.x + background.width + ((sWidth - background.width) - startBttn.width) / 2;
		startBttn.y = (sHeight - startBttn.height) / 2;
		startBttn.addEventListener(MouseEvent.CLICK, onStart);
		addChild(startBttn);
		
		storageBttn = new Button( {
			caption:Locale.__e('flash:1401955132276')
		});
		storageBttn.x = background.x + background.width + ((sWidth - background.width) - storageBttn.width) / 2;
		storageBttn.y = (sHeight - storageBttn.height) / 2;
		storageBttn.addEventListener(MouseEvent.CLICK, onStorage);
		addChild(storageBttn);
	}
	
	public function glowButton():void {
		if (storageBttn) storageBttn.startGlowing();
	}
	
	private var needSprite:Sprite = new Sprite();
	private function drawNeed():void {
		addChild(needSprite);
		
		var needText:TextField = Window.drawText(Locale.__e('flash:1383042563368'), {
			color:0xffffff,
			borderColor:0x5a3c20,
			fontSize:26
		});
		needText.x = sWidth - needText.textWidth - 10;
		needText.y = (sHeight - needText.textHeight) / 2 - 25;
		needSprite.addChild(needText);
		
		var ico:Bitmap = new Bitmap();
		Load.loading(Config.getIcon(App.data.storage[window.currency].type, App.data.storage[window.currency].preview), function(data:*):void {
			ico.bitmapData = data.bitmapData;
			Size.size(ico, 50, 50);
			ico.x = sWidth - ico.width - 5;
			ico.y = needText.y + needText.textHeight + 7;
			needSprite.addChild(ico);
		})
		
		var needCount:TextField = Window.drawText(window.target.currPrice[window.currency], {
			color:0xffffff,
			borderColor:0x5a3c20,
			fontSize:34
		});
		needCount.x = sWidth - needCount.textWidth - 60;
		needCount.y = needText.y + needText.textHeight + 15;
		needSprite.addChild(needCount);
	}
	
	public function onStart(e:MouseEvent):void {
		window.target.startSlot(slot, checkSlot);
	}
	
	public function onStorage(e:MouseEvent):void {
		window.target.storageAction(slot, checkSlot);
	}
	
	public function onSpeed(e:MouseEvent):void {
		window.target.boostAction(slot, checkSlot);
	}
	
	public function checkSlot(time:int = -1):void {
		if (time != -1) this.startTime = time;
		
		if (startTime + window.target.worktime > App.time) {
			materialSprite.visible = true;
			startBttn.visible = false;
			storageBttn.visible = false;
			needSprite.visible = false;
		}else if (startTime == 0) {
			materialSprite.visible = false;
			startBttn.visible = true;
			storageBttn.visible = false;
			needSprite.visible = true;
		}else {
			materialSprite.visible = false;
			startBttn.visible = false;
			storageBttn.visible = true;
			needSprite.visible = false;
		}
	}
	
	public function dispose():void {
		App.self.setOffTimer(progress);
	}
}

