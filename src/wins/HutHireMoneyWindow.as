package wins 
{
	import buttons.Button;
	import buttons.ImageButton;
	import buttons.MixedButton2;
	import core.Numbers;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.utils.clearTimeout;
	import flash.utils.getTimer;
	import flash.utils.setInterval;
	import flash.utils.setTimeout;
	import units.Hut;
	import wins.actions.BanksWindow;
	/**
	 * ...
	 * @author ...
	 */
	public class HutHireMoneyWindow extends Window 
	{
		//public var stockFood:int = 0;
		public var hut:Hut;
		public var takenFood:int = 0;
		public var needFood:int = 0;
		
		public var progressBar:ProgressBar;
		public var progressBacking:Bitmap;
		private var progressTitle:TextField;
		private var moneyCount:TextField;
		
		private var addMoneyBttn:ImageButton;
		
		private var viewImage:Sprite = new Sprite();
		
		public function HutHireMoneyWindow(settings:Object=null) 
		{
			if (settings == null) {
				settings = new Object();
			}
			
			hut = settings['target'];
			settings['width'] 			= 690;
			settings['height'] 			= 420;
			settings['sID'] 			= settings.sID || 0;
			settings['title'] 			= Locale.__e('flash:1439213845694');
			settings['hasPaginator'] 	= true;
			settings['hasButtons']		= false;
			settings['itemsOnPage'] 	= 10;
			settings['shadowColor'] 	= 0x513f35;
			settings['shadowSize'] 		= 4;
			
			super(settings);
			
			//stockFood = App.user.stock.count(hut.cost);// App.user.stock.count(Stock.FOOD);
			takenFood = 0;// settings.target.energy;
			needFood = hut.info.devel.req[settings.target.level].energy; //100;
		}
		
		public function get stockFood():int {
			return App.user.stock.data[hut.cost] - takenFood;
		}
		
		override public function drawBody():void {
			titleLabel.y += 7;
			
			var container:Sprite = new Sprite();
			bodyContainer.addChild(container);
			
			var timeDescText:TextField = drawText(Locale.__e('flash:1439213954864'), {
				color:			0x72390e,
				borderColor:	0xffffff,
				fontSize:		26,
				autoSize:		'center',
				textAlign:		'left',
				borderSize:		4
			});
			timeDescText.x = 0;
			timeDescText.width = timeDescText.textWidth + 5;
			container.addChild(timeDescText);
			
			var timeIcon:Bitmap = new Bitmap(Window.textures.timerSmall);
			timeIcon.x = timeDescText.x + timeDescText.width + 10;
			container.addChild(timeIcon);
			
			var time:int = 0; 
			try {
				time = hut.info.devel.req[hut.level].time;
			}catch (e:Error) { }
			
			var timeText:TextField = drawText(TimeConverter.timeToCuts(time, false, true), {
				autoSize:		'left',
				color:			0xffffff,
				borderColor:	0x553317,
				fontSize:		23,
				shadowSize:		1.5
			});
			timeText.x = timeIcon.x + timeIcon.width + 6;
			container.addChild(timeText);
			
			container.x = settings.width * 0.5 - container.width * 0.5;
			container.y = 80;
			
			var separator:Bitmap = Window.backingShort(titleLabel.width - 20, 'dividerLine', false);
			separator.x = titleLabel.x + 10;
			separator.y = container.y + 35;
			separator.alpha = 0.7;
			bodyContainer.addChild(separator);
			
			viewImage.graphics.beginFill(0xc8cabc, 1);
			viewImage.graphics.drawRoundRect(0, 0, 520, 92, 36);
			
			viewImage.x = (settings.width - viewImage.width) / 2;
			viewImage.y = separator.y + 20;
			bodyContainer.addChild(viewImage);
			
			var haveText:TextField = drawText(Locale.__e('flash:1425978184363'), {
				color:			0xffffff,
				borderColor:	0x532f19,
				fontSize:		24
			});
			haveText.width = haveText.textWidth + 5;
			haveText.x = (viewImage.width - haveText.width) / 2;
			haveText.y = 7;
			viewImage.addChild(haveText);
			
			var moneyContainer:Sprite = new Sprite();
			var moneyIcon:Bitmap = new Bitmap(Window.textures.moneyIco);
			moneyContainer.addChild(moneyIcon);
			
			moneyCount = drawText(Numbers.moneyFormat(stockFood), {
				color:			0xf7feba,
				borderColor:	0x523219,
				fontSize:		32
			});
			moneyCount.width = moneyCount.textWidth + 5;
			moneyCount.x = moneyIcon.x + moneyIcon.width + 5;
			moneyContainer.addChild(moneyCount);
			
			addMoneyBttn = new ImageButton(Window.texture('interAddBttnYellow'));
			addMoneyBttn.addEventListener(MouseEvent.CLICK, onAddMoney);
			addMoneyBttn.x = moneyCount.x + moneyCount.width + 5;
			moneyContainer.addChild(addMoneyBttn);
			
			moneyContainer.x = (viewImage.width - moneyContainer.width) / 2;
			moneyContainer.y = (viewImage.height - haveText.y) / 2;
			viewImage.addChild(moneyContainer);
			
			var needText:TextField = drawText(Locale.__e('flash:1439218489359'), {
				color:			0xffffff,
				borderColor:	0x532f19,
				fontSize:		26
			});
			needText.width = needText.textWidth + 5;
			needText.x = (settings.width - needText.width) / 4;
			needText.y = viewImage.y + viewImage.height + 10;
			bodyContainer.addChild(needText);
			
			
			var moneyIcon2:Bitmap = new Bitmap(Window.texture('moneyIco'));
			moneyIcon2.x = 60;
			moneyIcon2.y = needText.y + needText.textHeight + 10;
			bodyContainer.addChild(moneyIcon2);
			
			progressBacking = Window.backingShort(230, "progBarBacking");
			progressBacking.x = moneyIcon2.x + moneyIcon2.width + 5;
			progressBacking.y = moneyIcon2.y + 7;
			bodyContainer.addChild(progressBacking);
			
			progressBar = new ProgressBar({win:this, width:246, isTimer:false});
			progressBar.x = progressBacking.x - 8;
			progressBar.y = progressBacking.y - 4;
			bodyContainer.addChild(progressBar);
			progressBar.progress = takenFood / needFood;
			progressBar.start();
			
			progressTitle = drawText(progressData, {
				width:progressBacking.width,
				fontSize:32,
				textAlign:"center",
				color:0xffffff,
				borderColor:0x6b340c,
				shadowColor:0x6b340c,
				shadowSize:1
			});
			progressTitle.x = progressBacking.x + progressBacking.width / 2 - progressTitle.width / 2;
			progressTitle.y = progressBacking.y - 2;
			//progressTitle.width = 80;
			bodyContainer.addChild(progressTitle);
			
			drawButtons();
		}
		
		private var payBttn:Button;
		private var addOneBttn:Button;
		private var addAllBttn:Button;
		private var upgradeButton:Button;
		private function drawButtons():void {
			payBttn = new Button({
				width:178,
				fontSize:26,
				radius:14,
				caption:Locale.__e("flash:1439220742762"),
				fontSize:20,
				height:54
			});
			/*payBttn.x = (settings.width - payBttn.width) / 2 + (settings.width - payBttn.width) / 4;
			payBttn.y = viewImage.y + viewImage.height + 40;*/
			payBttn.x = settings.width / 2 - payBttn.width / 2;
			payBttn.y = settings.height - payBttn.height * 1.5 - 10;
			bodyContainer.addChild(payBttn);
			payBttn.addEventListener(MouseEvent.CLICK, onPayClick);
			
			/*addOneBttn = new Button({
				width:94,
				radius:14,
				caption:'+1  ',
				fontSize:20,
				height:48
			});
			addOneBttn.x = (settings.width - addOneBttn.width) / 2 + (settings.width - payBttn.width) / 7;
			addOneBttn.y = viewImage.y + viewImage.height + 45;
			bodyContainer.addChild(addOneBttn);
			addOneBttn.addEventListener(MouseEvent.MOUSE_DOWN, onAddOneDown);
			addOneBttn.addEventListener(MouseEvent.MOUSE_UP, onAddOneUp);
			
			var moneyIcon:Bitmap = new Bitmap(Window.textures.moneyIco);
			moneyIcon.scaleX = moneyIcon.scaleY = 0.8;
			moneyIcon.smoothing = true;
			moneyIcon.x = addOneBttn.width / 2 + 10;
			moneyIcon.y = addOneBttn.height / 2 - moneyIcon.height / 2;
			addOneBttn.addChild(moneyIcon);*/
			
			addAllBttn = new Button({
				width:138,
				fontSize:22,
				radius:14,
				caption:Locale.__e('flash:1439222022784') + '   ',
				height:48
			});
			addAllBttn.x = (settings.width - payBttn.width) / 2 + (settings.width - payBttn.width) / 4;//addOneBttn.x + addOneBttn.width + 10;
			addAllBttn.y = viewImage.y + viewImage.height + 45;
			bodyContainer.addChild(addAllBttn);
			addAllBttn.addEventListener(MouseEvent.CLICK, onAddAllClick);
			
			var moneyIcon2:Bitmap = new Bitmap(Window.textures.moneyIco);
			moneyIcon2.scaleX = moneyIcon2.scaleY = 0.8;
			moneyIcon2.smoothing = true;
			moneyIcon2.x = addAllBttn.width / 2 + 30;
			moneyIcon2.y = addAllBttn.height / 2 - moneyIcon2.height / 2;
			addAllBttn.addChild(moneyIcon2);
			
			payBttn.visible = false;
			
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
			upgradeButton.y = 20;//settings.height - upgradeButton.height * 1.5 - 10;
			upgradeButton.addEventListener(MouseEvent.CLICK, onUpgradeClick);
			
			if (hut.level == hut.totalLevels)
				return;
			drawMirrowObjs('upgradeDec', upgradeButton.x + 24, upgradeButton.x + upgradeButton.width - 24, upgradeButton.y, true, true, false);
			bodyContainer.addChild(upgradeButton);
		}
		
		protected function update():void {
			progressTitle.text = progressData;
			moneyCount.text = Numbers.moneyFormat(stockFood);
			progressBar.progress = takenFood / needFood;
			
			if (takenFood >= needFood) {
				payBttn.visible = true;
				addAllBttn.state = Button.DISABLED;
				//addOneBttn.visible = false;
			}else {
				payBttn.visible = false;
				addAllBttn.state = Button.NORMAL;
				//addOneBttn.visible = true;
			}
		}
		
		protected function onAddMoney(e:MouseEvent):void {
			BanksWindow.history = {section:'Coins',page:0};
			new BanksWindow({popup:true}).show();
		}
		
		public function get progressData():String {
			return String(takenFood) + '/' + String(needFood);
		}
		
		// Добавляет одну еду
		private var interval:uint = 0;
		private var intervalTime:Number = 1000;
		protected function onAddOneDown(e:MouseEvent):void {
			intervalTime = 1000;
			
			if (interval == 0) {
				interval = setTimeout(addOne, intervalTime);
			}
		}
		protected function onAddOneUp(e:MouseEvent):void {
			if (interval > 0) {
				clearTimeout(interval);
			}
			
			addOne();
			clearTimeout(interval);
			interval = 0;
		}
		private function addOne():void {
			if (takenFood < needFood) {
				takenFood ++;
				update();
			}
			
			if (intervalTime == 1000) {
				intervalTime = 330;
			}else if(intervalTime > 2) {
				intervalTime *= 0.9;
			}
			
			interval = setTimeout(addOne, int(intervalTime));
		}
		
		// Добавляет максимум еды
		protected function onAddAllClick(e:MouseEvent):void {
			if (needFood - takenFood <= stockFood) {
				takenFood = needFood;
				update();
			}
		}
		
		// Покормить рабочего
		private function onPayClick(e:MouseEvent):void {
			if (payBttn.mode == Button.DISABLED) return;
			payBttn.state = Button.DISABLED;
			
			if (takenFood >= needFood) {
				hut.hire(takenFood, [], false);
				close();
			}
		}
		
		// Улучшение
		private function onUpgradeClick(e:MouseEvent):void {
			if (upgradeButton.mode == Button.DISABLED) return;
			upgradeButton.state = Button.DISABLED;
			close();
			hut.openUpgradeWindow(316);
		}
		
		override public function dispose():void {
			//addOneBttn.removeEventListener(MouseEvent.MOUSE_DOWN, onAddOneDown);
			//addOneBttn.removeEventListener(MouseEvent.MOUSE_UP, onAddOneUp);
			payBttn.removeEventListener(MouseEvent.MOUSE_UP, onPayClick);
			upgradeButton.removeEventListener(MouseEvent.CLICK, onUpgradeClick);
			
			addMoneyBttn.removeEventListener(MouseEvent.CLICK, onAddMoney);
			
			super.dispose();
		}
	}

}