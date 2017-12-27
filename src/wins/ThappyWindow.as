package wins 
{
	import buttons.Button;
	import buttons.ImageButton;
	import com.flashdynamix.motion.extras.BitmapTiler;
	import core.Load;
	import core.Numbers;
	import core.Post;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import ui.UserInterface;
	import units.Happy;
	import units.Thappy;
	/**
	 * ...
	 * @author ...
	 */
	public class ThappyWindow extends HappyWindow
	{
		private var thappy:Thappy;
		private var info2:Object;
		private var preloader:Preloader;
		private var helpBttn:ImageButton;
		public function ThappyWindow(settings:Object=null) 
		{
			settings['width'] = 700;
			settings['height'] = 580;
			thappy = settings.target;
			super(settings);
			info2 = settings;
			
		}
		protected var teamID:int;
		
		override public function drawBody():void {
			teamID = settings.target.team;
			
			drawState();			
			drawKicks();			
			drawTimer();
			drawScore();			
			drawTeamScore();
			
			helpBttn = new ImageButton(Window.textures.interHelpBttn);
			helpBttn.x = exit.x - exit.width - 6;;
			helpBttn.y = -34;
			bodyContainer.addChild(helpBttn);
			helpBttn.addEventListener(MouseEvent.CLICK, onHelp);
			updateReward();
			rewardBttn = new ImageButton(Window.texture('showMeBttn'));
			rewardBttn.x = settings.width - rewardBttn.width - 70;
			rewardBttn.y = settings.height - 420;
			rewardBttn.addEventListener(MouseEvent.CLICK, function ():void { new TeamsRewardItems( thappy.team, settings).show() } );
			bodyContainer.addChild(rewardBttn);
			var topBttnText:String = Locale.__e('flash:1466770966609') ;
			if ( topBttnText.indexOf('10') != -1) {
				topBttnText = topBttnText.replace('10', '100');
			}
			if (!topBttn) {
				topBttn = new ImageButton(Window.texture('homeBttn'));
				topBttn.scaleX = topBttn.scaleY = 0.8;
				
				var topText:TextField = Window.drawText(Locale.__e('flash:1440154414885'), {
					textAlign:		'center',
					fontSize:		32,
					color:			0xFFFFFF,
					borderColor:	0x631d0b,
					shadowSize:		1
				});
				topText.x = 20;
				topText.y = (topBttn.height - topText.height) / 2 + 10;
				topBttn.addChild(topText);
			
				topBttn.addEventListener(MouseEvent.CLICK, onTop100);
			}
			topBttn.x = 75;
			topBttn.y = 30;
			bodyContainer.addChild(topBttn);
		}
		
		override protected function drawTimer():void {
			var timerBacking:Bitmap = new Bitmap(Window.textures.glow, 'auto', true);// Window.backingShort(150, 'seedCounterBacking');
			timerBacking.width = 150;
			timerBacking.scaleY = timerBacking.scaleX;
			timerBacking.scaleY = 0.3;
			timerBacking.x = (settings.width - timerBacking.width) / 2;
			timerBacking.y = -10;
			timerBacking.alpha = 0.7;
			bodyContainer.addChild(timerBacking);
			
			var timerDescLabel:TextField = drawText(Locale.__e('flash:1393581955601'), {
				width:			timerBacking.width,
				textAlign:		'center',
				fontSize:		26,
				color:			0xfffcff,
				borderColor:	0x5b3300
			});
			timerDescLabel.x = timerBacking.x + (timerBacking.width - timerDescLabel.width) / 2;
			timerDescLabel.y = timerBacking.y + 20;
			bodyContainer.addChild(timerDescLabel);
			
			timerLabel = drawText('00:00:00', {
				width:			timerBacking.width + 50,
				textAlign:		'center',
				fontSize:		40,
				color:			0xffd855,
				borderColor:	0x3f1b05
			});
			timerLabel.x = (settings.width - timerLabel.width) / 2;
			timerLabel.y = 40;
			bodyContainer.addChild(timerLabel);
			
			if (settings.target.expire < App.time) {
				timerBacking.visible = false;
				timerDescLabel.visible = false;
				timerLabel.visible = false;
			}
		}
		protected function drawState():void {			
			var descLabelText:String = info['text2'];			
			var descLabel:TextField = drawText(descLabelText, {
				textAlign:		'center',
				autoSize:		'center',
				fontSize:		24,
				color:			0xfffcff,
				borderColor:	0x6b401a,
				distShadow:		0
			});
			
			descLabel.wordWrap = true;
			
			bodyContainer.addChild(descLabel);
			
			descLabel.width = 420  - 130;
			
			descLabel.x = 120;
			descLabel.y = 100;		
			
			rewardBacking = backing(140, 175, 10, 'itemBacking');
			rewardBacking.x = settings.width - rewardBacking.width - 75;
			rewardBacking.y = 50;
			bodyContainer.addChild(rewardBacking);
			
			rewardDescLabel = drawText(Locale.__e('flash:1382952380000'), {
				textAlign:		'center',
				fontSize:		30,
				color:			0x814f31,
				borderColor:	0xffffff,
				width:			rewardBacking.width,
				distShadow:		0
			});
			rewardDescLabel.x = rewardBacking.x + (rewardBacking.width - rewardDescLabel.width) / 2;
			rewardDescLabel.y = rewardBacking.y;
			bodyContainer.addChild(rewardDescLabel);
			
			levelLabel = drawText(Locale.__e('flash:1436188159724',String(settings.target.upgrade + 1)), {
				width:			150,
				textAlign:		'center',
				fontSize:		24,
				color:			0xfffcff,
				borderColor:	0x5b3300
			});
			levelLabel.x = rewardDescLabel.x + (rewardDescLabel.width - levelLabel.width) / 2;
			levelLabel.y = 20;
			bodyContainer.addChild(levelLabel);
		}
		override protected function getReward():int {
			if (info.teams[teamID].levels.t[settings.target.upgrade]) {
				var trName:String = info.teams[teamID].levels.t[settings.target.upgrade];
				var treasure:Object = App.data.treasures[trName][trName];
				for each(var s:* in treasure.item) return int(s);
			} 
			
			for (s in info.teams[teamID].bonus) return int(s);
			
			return 2314;
		}
		
		override protected function drawScore():void {
			if (!scorePanel) {
				scorePanel = new Sprite();
				scorePanel.x = 50;
				scorePanel.y = 135;
				bodyContainer.addChild(scorePanel);
			}
			var topBttnText:String = Locale.__e('flash:1466774451771');
			if (!top100Bttn) {
				top100Bttn = new Button( {
					width:		160,
					height:		42,
					caption:	topBttnText
				});
				top100Bttn.x = (settings.width - top100Bttn.width) / 2 - 50;
				top100Bttn.y = 325;
				top100Bttn.addEventListener(MouseEvent.CLICK, onTopEvent);
			}
			
			top100Bttn.visible = false;
			if (!upgradeBttn) {
					upgradeBttn = new Button( {
						width:		110,
						height:		32,
						fontSize:	24,
						caption:	Locale.__e('flash:1382952379737')
					});
					upgradeBttn.addEventListener(MouseEvent.CLICK, onUpgrade);
					upgradeBttn.state = Button.DISABLED;
					upgradeBttn.x = rewardBacking.x + rewardBacking.width / 2 - upgradeBttn.width / 2;
					upgradeBttn.y = rewardBacking.y + rewardBacking.height  - upgradeBttn.height / 2 - 5;
					bodyContainer.addChild(upgradeBttn);
			}
			
			if (scorePanel.numChildren > 0) {
				while (scorePanel.numChildren > 0) {
					var item:* = scorePanel.getChildAt(0);
					scorePanel.removeChild(item);
				}
			}
			
			if (settings.target.canUpgrade && settings.target.expire > App.time) {
				
				blockItems(true);
				upgradeBttn.state = Button.NORMAL;
				
			} else if (settings.target.upgrade < Numbers.countProps(info.teams[teamID].levels.t) && settings.target.expire > App.time) {
				var progressBacking:Bitmap = Window.backingShort(330, "progBarBacking");
				progressBacking.x = 50;
				progressBacking.y = 75;
				scorePanel.addChild(progressBacking);
				
				progressBar = new ProgressBar( { win:this, width:progressBacking.width + 16, isTimer:false} );
				progressBar.x = progressBacking.x - 8;
				progressBar.y = progressBacking.y - 4;
				scorePanel.addChild(progressBar);
				progressBar.progress = settings.target.kicks / settings.target.kicksNeed;
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
				scorePanel.addChild(progressTitle);
				
				progress();
				if (top100Bttn) {
					top100Bttn.visible = true;				
					scorePanel.addChild(top100Bttn);
				}
				
			} else if (canTakeMainReward) {
				upgradeBttn.state = Button.NORMAL;
			} else {
				upgradeBttn.state = Button.DISABLED;
				var scoreDescLabelText:String = Locale.__e('flash:1443192620496');
				
				var scoreDescLabel:TextField = drawText(scoreDescLabelText, {
					width:			120,
					textAlign:		'center',
					fontSize:		32,
					color:			0xfffcff,
					borderColor:	0x5b3300
				});
				scoreDescLabel.x = 50;
				scoreDescLabel.y = 75;
				scorePanel.addChild(scoreDescLabel);
				scoreLabel = drawText(String(settings.target.rate[teamID]), {
					width:			120,
					textAlign:		'center',
					fontSize:		44,
					color:			0xf5ce4f,
					borderColor:	0x71371f
				});
				scoreLabel.x = scoreDescLabel.x + scoreDescLabel.width;
				scoreLabel.y = scoreDescLabel.y + scoreDescLabel.height/2 - scoreLabel.height/2 + 5;
				scorePanel.addChild(scoreLabel);
				if (top100Bttn) {
					top100Bttn.visible = true;
					scorePanel.addChild(top100Bttn);
				}
				changeRate();
			}
			
			if (getReward() == 0) {
				upgradeBttn.visible = false;
				rewardBacking.visible = false;
				rewardDescLabel.visible = false;
				levelLabel.visible = false;
			}
			
		}
		
		private var oneTeamScore:TextField;
		private var secTeamScore:TextField;
		private function drawTeamScore():void {
			if (!oneTeamScore) {
				oneTeamScore = Window.drawText(App.data.storage[thappy.sid].teams[1].info.title + ": " + thappy.rate[1], {
					color:		0xd3ff78,
					borderColor:0x0f4d0c,
					fontSize:	26
				});
				oneTeamScore.width = oneTeamScore.textWidth + 10;
				oneTeamScore.x = 50;
				oneTeamScore.y = 465;
				bodyContainer.addChild(oneTeamScore);
			} else {
				oneTeamScore.text = App.data.storage[thappy.sid].teams[1].info.title + ": " + thappy.rate[1];
			}
			
			if (!secTeamScore) {
				secTeamScore = Window.drawText(App.data.storage[thappy.sid].teams[2].info.title + ": " + thappy.rate[2], {
					color:		0x77ffff,
					borderColor:0x0a3f75,
					fontSize:	28
				});
				secTeamScore.width = secTeamScore.textWidth + 10;
				secTeamScore.x = 435;
				secTeamScore.y = 465;
				bodyContainer.addChild(secTeamScore);
			} else {
				secTeamScore.text = App.data.storage[thappy.sid].teams[2].info.title + ": " + thappy.rate[2];
			}
		}
		
		override protected function onTop100(e:MouseEvent = null):void {
			if (thappy.rateChecked == 0) {
				thappy.rateChecked = App.time;
				getRate(onTop100);
				return;
			}
			
			thappy.rateChecked = 0;
			//changeRate();
			
			var content:Array = [];
			for (var s:* in Happy.users) {
				var user:Object = Happy.users[s];
				user['uID'] = s;
				content.push(user);
			}
			
			if (settings.target.topID >= 8 && settings.target.topID != 9 && settings.target.topID != 11 && settings.target.topID != 13) {
				new TopLeaguesWindow( {
					title:			settings.title,
					description:	App.data.top[topID].description,
					points:			HappyWindow.rate,
					max:			topx,
					target:			settings.target,
					content:		HappyWindow.rates,
					material:		null,
					popup:			true,
					topID:			settings.target.topID,
					onInfo:			function():void {
						
					}
				}).show();
			} else {
				new TopWindow( {
					title:			settings.title,
					description:	App.data.top[topID].description,
					points:			HappyWindow.rate,
					max:			topx,
					target:			settings.target,
					content:		HappyWindow.rates,
					material:		null,
					popup:			true,
					onInfo:			function():void {
						new InfoWindow( {
							popup:true,
							qID:'top' + topID
						}).show();
					}
				}).show();
			}			
		}
		
		override protected function progress():void {
			if (progressBar){
				progressBar.progress = settings.target.kicks / settings.target.kicksNeed;
				/*if (settings.target.kicks > settings.target.kicksNeed) {
					settings.target.kicks = settings.target.kicksNeed;
				}*/
				progressTitle.text = String(settings.target.kicks) + ' / ' + String(settings.target.kicksNeed);
			}
		}
		protected function onUpgradeComplete(bonus:Object = null):void {
			if (bonus && Numbers.countProps(bonus) > 0) {
				wauEffect();
				App.user.stock.addAll(bonus);
			}
			
			levelLabel.text = Locale.__e('flash:1436188159724', settings.target.upgrade + 1);
			drawScore();
			updateReward();
			blockItems(false);
			close();
			
			if (settings.target.upgrade >=settings.target.info.teams.levels[teamID].t.length ) {
				changeRate();
			}
		}
		override public function get canTakeMainReward():Boolean {
			return false;
		}
		
		protected function timer():void {
			timerLabel.text = TimeConverter.timeToDays((settings.target.expire < App.time) ? 0 : (settings.target.expire - App.time));
		}
		private var itemsKick:Vector.<KickItem> = new Vector.<KickItem>;
		private var rewardBttn:Button;
		private var topBttn:ImageButton;
		override public function drawKicks():void {
			clearKicks();
			var rewards:Array = [];
			for (var s:String in info.kicks) {
				var object:Object = info.kicks[s];
				object['id'] = s;
				rewards.push(object);
			}
			
			rewards.sortOn('o', Array.NUMERIC);
			
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
			itemsContainer.y = 250;
			var X:int = 20;
			var Xs:int = X;
			for (var i:int = 0; i < rewards.length; i++) {
				var item:KickItem = new KickItem(rewards[i], this);
				item.x = Xs;
				itemsContainer.addChild(item);
				itemsKick.push(item);
				
				Xs += item.bg.width + 15;
			}
			
			itemsContainer.x = (settings.width - itemsContainer.width) / 2;
		}
		
		override public function changeRate():void {
			if ( scoreLabel != null )
				scoreLabel.text = String(settings.target.kicks);// String(thappy.rate[thappy.team]);
		}
		protected function onTopEvent(e:MouseEvent = null):void {
			thappy.getCommandRate(showIslandCWindow);
			function showIslandCWindow():void
			{
				var win:Object = new IslandChallengeWindow ({
						callback:null,
						target:settings.target,
						popup:true,
						title:Locale.__e ("flash:1466774992523"),
						mode:IslandChallengeWindow.CHALLENGE
					});
				win.show();
			}			
		}
		override protected function onHelp(e:MouseEvent):void {
			new InfoWindow( {
				popup:true,
				qID:'tophelp13'
			}).show();
		}
		public function getRate(callback:Function = null):void {
			
			function onGetRate():void
			{
				changeRate();
				if (callback != null)
					callback();
			}
			thappy.getRate(onGetRate);
		}
		
		/*override public function kick():void {
			progress();
			App.ui.upPanel.update();
			
			if (settings.target.canUpgrade) {
				blockItems(true);
				drawScore();
			}else {
				blockItems(false);
				changeRate();
			}
		}*/
	
		override public function dispose():void 
		{
			super.dispose();
			thappy = null;
		}
	}

}
import buttons.Button;
import buttons.MoneyButton;
import core.Load;
import core.Numbers;
import core.Size;
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.text.TextField;
import ui.Hints;
import ui.UserInterface;
import wins.Window;
import wins.ShopWindow;
import wins.actions.BanksWindow;
import flash.geom.Point;


internal class KickItem extends LayerX{
	
	public var window:*;
	public var item:Object;
	public var bg:Sprite;
	private var bitmap:Bitmap;
	private var sID:uint;
	public var bttn:Button;
	public var bttnFind:Button;
	private var count:uint;
	private var nodeID:String;
	private var type:uint;
	private var k:uint;
	
	public function KickItem(obj:Object, window:*) {
		this.sID = obj.id;
		this.count = obj.c;
		this.nodeID = obj.id;
		this.k = obj.k;
		this.item = App.data.storage[sID];
		this.window = window;
		type = obj.t;
		
		bg = new Sprite();
		bg.graphics.beginFill(0xcbd4cf);
		bg.graphics.drawCircle(60, 100, 60);
		bg.graphics.endFill();
		addChild(bg);
		
		bitmap = new Bitmap();
		addChild(bitmap);
		
		drawTitle();
		drawBttn();
		drawLabel();
		
		Load.loading(Config.getIcon(item.type, item.preview), onLoad);
		
		tip = function():Object {
			return {
				title: item.title,
				text: item.description
			}
		}
	}
	
	private function drawBttn():void {
		var bttnSettings:Object = {
			caption:Locale.__e("flash:1382952379978"),
			width:115,
			height:40,
			fontSize:22
		}
		
		if(item.real == 0 || type == 1){
			bttnSettings['borderColor'] = [0xaff1f9, 0x005387];
			bttnSettings['bgColor'] = [0x70c6fe, 0x765ad7];
			bttnSettings['fontColor'] = 0x453b5f;
			bttnSettings['fontBorderColor'] = 0xe3eff1;
			
			bttn = new Button(bttnSettings);
		}
		
		if (item.real || type == 2) {
			
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
		
		if (type == 3) {
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
		
		checkButtonsStatus();
	}
	
	public function checkButtonsStatus():void {
		if (window.settings.target.expire < App.time || window.settings.target.canUpgrade) {
			bttn.state = Button.DISABLED;
			return;
		}
		
		if (type == 2) {
			bttn.state = Button.NORMAL;
			bttn.visible = true;
			bttnFind.visible = false;
		}else if (type == 3) {
			if (App.user.stock.count(sID) < price) {
				bttn.state = Button.DISABLED;
				bttn.visible = false;
				bttnFind.visible = true;
			}else {
				bttn.state = Button.NORMAL;
				bttn.visible = true;
				bttnFind.visible = false;
			}
		}
	}
	
	private function onClick(e:MouseEvent):void {
		if (e.currentTarget.mode == Button.DISABLED) return;
		
		e.currentTarget.state = Button.DISABLED;
		
		if (currency == Stock.FANT && App.user.stock.count(Stock.FANT) < price) {
			window.close();
			new BanksWindow().show();
			return;
		}
		if (type == 3 && App.user.stock.count(sID) < 1 && ShopWindow.findMaterialSource(sID))  {
			window.close();
			return;
		}
		
		window.blockItems();
		window.settings.target.kickAction(sID, onKickEventComplete);
	}
	
	private function onKickEventComplete(bonus:Object = null):void {
		App.user.stock.take(currency, price);
		
		var X:Number = App.self.mouseX - bttn.mouseX + bttn.width / 2;
		var Y:Number = App.self.mouseY - bttn.mouseY;
		Hints.minus(currency, price, new Point(X, Y), false, App.self.tipsContainer);
		
		//if (Numbers.countProps(bonus) > 0) {
			//BonusItem.takeRewards(bonus, bttn, 20);
		//}
		if (bonus){
			flyBonus(bonus);
		}
		
		stockCount.text = 'x' + App.user.stock.count(sID);
		
		checkButtonsStatus();			
		window.kick();
	}	
	
	private function flyBonus(data:Object):void {
		var targetPoint:Point = Window.localToGlobal(bttn);
		targetPoint.y += bttn.height / 2;
		for (var _sID:Object in data)
		{
			var sID:uint = Number(_sID);
			for (var _nominal:* in data[sID])
			{
				var nominal:uint = Number(_nominal);
				var count:uint = Number(data[sID][_nominal]);
			}
			
			var item:*;
			
			for (var i:int = 0; i < count; i++)
			{
				item = new BonusItem(sID, nominal);
				App.user.stock.add(sID, nominal);	
				item.cashMove(targetPoint, App.self.windowContainer)
			}			
		}
		SoundsManager.instance.playSFX('reward_1');
	}
	
	private function onFind(e:MouseEvent):void {
		ShopWindow.findMaterialSource(sID);
		window.close();
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
		sprite.x = (bg.width - bitmap.width) / 2;
		sprite.y = (bg.height - bitmap.height) / 2 + 35;
		sprite.addChild(bitmap);
		addChildAt(sprite, 1);
		bitmap.smoothing = true;
		
		sprite.addEventListener(MouseEvent.CLICK, searchEvent);
	}
	
	private function searchEvent(e:MouseEvent):void {
		ShopWindow.findMaterialSource(sID);
	}
	
	public function dispose():void {
		bttn.removeEventListener(MouseEvent.CLICK, onClick);
	}
	
	public function drawTitle():void {
		var title:TextField = Window.drawText(item.title + ' +' + k, {
			color:0x814f31,
			borderColor:0xffffff,
			textAlign:"center",
			autoSize:"center",
			fontSize:22,
			textLeading:-6,
			multiline:true,
			distShadow:0
		});
		title.wordWrap = true;
		title.width = bg.width - 10;
		title.height = title.textHeight;
		title.x = 5;
		title.y = 15;
		addChild(title);
	}
	
	private var stockCount:TextField
	public function drawLabel():void 
	{
		var count:int = App.user.stock.count(sID);
		var countText:String = 'x' + String(count);
		if (count < 1) {
			countText = '';
		}
		if (stockCount) {
			removeChild(stockCount);
			stockCount = null;
		}
		stockCount = Window.drawText(countText, {
			color:0xffffff,
			fontSize:30,
			borderColor:0x7b3e07
		});
		stockCount.width = stockCount.textWidth + 10;
		stockCount.x = bg.x + bg.width - stockCount.width;
		stockCount.y = bg.y + bg.height - 10;
		
		if (type == 2)
			return;
		addChild(stockCount);
	}
	
	private function get price():int {
		if (type == 2) {
			for (var s:* in item.price) break;
			return item.price[s];
		}
		
		return 1;
	}
	private function get currency():int {
		if (type == 2) {
			for (var s:* in item.price) break;
			return int(s);
		}
		
		return sID;
	}
}