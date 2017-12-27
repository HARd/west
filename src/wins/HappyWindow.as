package wins 
{
	import buttons.Button;
	import buttons.ImageButton;
	import buttons.SimpleButton;
	import com.greensock.easing.Cubic;
	import com.greensock.TweenLite;
	import core.Load;
	import core.Numbers;
	import core.Post;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormatAlign;
	import flash.utils.setTimeout;
	import ui.UserInterface;
	import units.Happy;
	
	public class HappyWindow extends Window
	{
		public static var rate:int = 0;
		public static var rates:Object = { };
		public static var topID:int = 8;
		public static var depthShow:int = 0;
		public static var find:int = 0;
		public var topx:int = 100;
		
		public var timerLabel:TextField;
		public var levelLabel:TextField;
		public var scoreLabel:TextField;
		
		public var image:Bitmap;
		private var preloader:Preloader;
		public var top100Bttn:Button;
		public var upgradeBttn:Button;
		
		private var toyContainer:Sprite;
		private var treeContainer:Sprite;
		private var scaleContainer:Sprite;
		private var kicksContainer:Sprite;
		protected var scorePanel:Sprite;
		protected var kicksBacking:Bitmap;
		protected var rewardBacking:Bitmap;
		
		protected var progressBar:ProgressBar;
		protected var progressBacking:Bitmap;
		protected var progressTitle:TextField;
		
		
		public var sid:int = 0;
		public var info:Object = { };
		
		public var topNumber:int = 100;
		
		public function HappyWindow(settings:Object=null) 
		{
			if (!settings) settings = { };
			
			settings['width'] = settings['width'] || 650;
			settings['height'] = settings['height'] || 550;
			settings['title'] = settings.target.info.title;
			settings['hasPaginator'] = false;
			settings['background'] = 'alertBacking';
			
			if (settings.target.sid == 935) settings['background'] = 'indianBacking';
			if (settings.target.sid == 1302) settings['background'] = 'winterBacking';
			
			sid = settings.target.sid;
			info = App.data.storage[sid];
			topNumber = info['topx'] || 25;
			
			super(settings);
			
			App.self.setOnTimer(timer);
			
			topID = settings.target.topID;
			
			//getRate();
			if (HappyWindow.depthShow > 0) {
				if (depthShow == 1) depthShow = 0;
				onTop100();
			}
		}
		
		override public function drawBody():void {
			exit.x += 0;
			exit.y -= 18;
			
			if (settings.background == 'indianBacking') exit.y += 18;
			
			drawState();			
			drawKicks();			
			drawScore();			
			drawTimer();
			
			if (settings.target.kicksNeed == 0 && settings.target.sid == 2687) {
				blockItems(true);
				rewardCont.visible = false;
				levelLabel.visible = false;
			}
		}
		
		protected function getReward():int {
			var items:Object;
			var s:*;
			if (info.tower.hasOwnProperty(settings.target.upgrade + 1)) {
				items = App.data.treasures[info.tower[settings.target.upgrade + 1].t][info.tower[settings.target.upgrade + 1].t].item;
				for each(s in items) {
					if (['Decor', 'Golden', 'Walkgolden','Floors','Box'].indexOf(App.data.storage[s].type) >= 0) {
						return int(s);
					}
				}
			}else {
				if (settings.target.sid == 1302)
					return 1290;
				if (settings.target.sid == 1518)
					return 1519;
				else {
					switch (settings.target.topID) {
						case 12:
							if (App.user.level <= App.data.top[settings.target.topID].league.lto[1]) {
								return 1994;
							}else if (App.user.level > App.data.top[settings.target.topID].league.lfrom[2] && App.user.level <= App.data.top[settings.target.topID].league.lto[2]) {
								return 1993;
							}else if (App.user.level > App.data.top[settings.target.topID].league.lfrom[3]) {
								return 1992;
							}
							break;
						case 14:
							for (var l:* in App.data.top[settings.target.topID].league.lfrom) {
								if (App.data.top[settings.target.topID].league.lfrom[l] < App.user.level && App.data.top[settings.target.topID].league.lto[l] > App.user.level) {
									break;
								}
							}
							items = App.data.treasures[App.data.top[settings.target.topID].league.tbonus[l].t[0]][App.data.top[settings.target.topID].league.tbonus[l].t[0]].item;
							for each(s in items) {
								if (['Decor', 'Golden', 'Walkgolden','Floors','Box'].indexOf(App.data.storage[s].type) >= 0) {
									return int(s);
								}
							}
							break;
					}
					return 869;
				}
				/*items = App.data.treasures[info.top['top10']][info.top['top10']].item;
				for each(s in items) {
					if (['Decor', 'Golden', 'Walkgolden'].indexOf(App.data.storage[s].type) >= 0) {
						return int(s);
					}
				}*/
			}
			
			return int(s);
		}
		
		private var rewardCont:LayerX;
		private var reward:Bitmap;
		protected function updateReward():void {
			/*if (!info.tower.hasOwnProperty(settings.target.upgrade + 1) && settings.target.upgrade >= Numbers.countProps(info.tower)) {
				if (rewardCont) {
					bodyContainer.removeChild(rewardCont);
				}
				return;
			}*/
			var sid:int = getReward();
			
			if (!rewardCont) {
				rewardCont = new LayerX();
				bodyContainer.addChild(rewardCont);
				
				reward = new Bitmap();
				rewardCont.addChild(reward);
			}
			
			if (!App.data.storage.hasOwnProperty(sid)) {
				reward.bitmapData = null;
				return;
			}
			
			rewardCont.x = rewardBacking.x;
			rewardCont.y = rewardBacking.y;
			rewardCont.tip = function():Object {
				return { title:App.data.storage[sid].title, text:App.data.storage[sid].description };
			}
			
			var preloader:Preloader = new Preloader();
			preloader.x = rewardBacking.width / 2;
			preloader.y = rewardBacking.height / 2;
			rewardCont.addChild(preloader);
			
			Load.loading(Config.getIcon(App.data.storage[sid].type, App.data.storage[sid].preview), function(data:Bitmap):void {
				rewardCont.removeChild(preloader);
				preloader = null;
				
				reward.bitmapData = data.bitmapData;
				reward.smoothing = true;
				
				if (reward.width > rewardBacking.width - 20) {
					reward.width = rewardBacking.width - 20;
					reward.scaleY = reward.scaleX;
				}
				if (reward.height > rewardBacking.height - 20) {
					reward.height = rewardBacking.height - 20;
					reward.scaleX = reward.scaleY;
				}
				if (sid == 869) reward.scaleX = reward.scaleY = 0.55;
				
				rewardCont.x = rewardBacking.x + (rewardBacking.width - reward.width) / 2;
				rewardCont.y = rewardBacking.y + (rewardBacking.height - reward.height) / 2 - 5;
			});
			
			bodyContainer.swapChildren(rewardCont, rewardDescLabel);
		}
		
		protected function drawTimer():void {
			if (settings.target.sid == 2687) return;
			var timerBacking:Bitmap = new Bitmap(Window.textures.glow, 'auto', true);// Window.backingShort(150, 'seedCounterBacking');
			timerBacking.width = 150;
			timerBacking.scaleY = timerBacking.scaleX;
			timerBacking.scaleY = 0.3;
			timerBacking.x = (settings.width - timerBacking.width) / 2;
			timerBacking.y = -20;
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
			timerLabel.y = 30;
			bodyContainer.addChild(timerLabel);
			
			if (settings.target.expire < App.time) {
				timerBacking.visible = false;
				timerDescLabel.visible = false;
				timerLabel.visible = false;
			}
		}
		
		protected var rewardDescLabel:TextField = new TextField();
		private function drawState():void {			
			var descLabelText:String = Locale.__e('flash:1443175349139');	
			if (settings.target.sid == 1302) descLabelText = Locale.__e('flash:1450263875420');
			if (settings.target.sid == 1518) descLabelText = Locale.__e('flash:1454424693911');
			if (settings.target.sid == 2687) descLabelText = settings.target.info.description;
			if (HappyWindow.topID) descLabelText = App.data.top[HappyWindow.topID].description;
			var descLabel:TextField = drawText(descLabelText, {
				color:0x532b07,
				border:true,
				borderColor:0xfde1c9,
				fontSize:21,
				multiline:true,
				autoSize: 'center',
				textAlign:"center",
				thickness: 30
			});
			descLabel.width = 345;
			descLabel.wordWrap = true;
			descLabel.x = 80;
			descLabel.y = 85;
			bodyContainer.addChild(descLabel);
			
			if (settings.target.sid == 1302) descLabel.y = 90;
			
			rewardBacking = backing(140, 175, 10, 'itemBacking');
			rewardBacking.x = settings.width - rewardBacking.width - 75;
			rewardBacking.y = 50;
			bodyContainer.addChild(rewardBacking);
			
			var sid:int = getReward();
			rewardDescLabel = drawText(App.data.storage[sid].title, {
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
			
			updateReward();
			
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
			
			if (!info.tower.hasOwnProperty(settings.target.upgrade + 1) && settings.target.upgrade >= Numbers.countProps(info.tower)) {
				if (settings.target.topID == 0) rewardBacking.visible = false;
				rewardDescLabel.visible = false;
			}
		}
		
		protected function drawScore():void {
			if (!scorePanel) {
				scorePanel = new Sprite();
				scorePanel.x = 50;
				scorePanel.y = 135;
				bodyContainer.addChild(scorePanel);
			}
			
			if (scorePanel.numChildren > 0) {
				while (scorePanel.numChildren > 0) {
					var item:* = scorePanel.getChildAt(0);
					scorePanel.removeChild(item);
				}
			}
			
			if (settings.target.canUpgrade && settings.target.expire > App.time || canTakeMainReward) {
				
				blockItems(true);
				
				if (canTakeMainReward) {
					if (upgradeBttn) 
						upgradeBttn.visible = false;
				} else {
					if (!upgradeBttn) {
						upgradeBttn = new Button( {
							caption:Locale.__e("flash:1382952379737"),
							width:105,
							height:35,
							fontSize:22
						});
						upgradeBttn.addEventListener(MouseEvent.CLICK, onUpgrade);
					}
					upgradeBttn.x = 453;// reward.x + (reward.width - upgradeBttn.width) / 2;
					upgradeBttn.y = 180;
					bodyContainer.addChild(upgradeBttn);
					upgradeBttn.showGlowing();
				}
				
			} else if (settings.target.upgrade < Numbers.countProps(info.tower) && settings.target.expire > App.time) {
				progressBacking = Window.backingShort(330, "progBarBacking");
				progressBacking.x = 75;
				progressBacking.y = 200;
				bodyContainer.addChild(progressBacking);
				
				progressBar = new ProgressBar({win:this, width:346, isTimer:false});
				progressBar.x = progressBacking.x - 8;
				progressBar.y = progressBacking.y - 4;
				bodyContainer.addChild(progressBar);
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
				bodyContainer.addChild(progressTitle);
			} else {		
				var scoreDescLabelText:String = Locale.__e('flash:1443192620496');				
				var scoreDescLabel:TextField = drawText(scoreDescLabelText, {
					width:			200,
					textAlign:		'center',
					fontSize:		26,
					color:			0xfffcff,
					borderColor:	0x5b3300
				});
				scoreDescLabel.x = 75;
				scoreDescLabel.y = 50;
				scorePanel.addChild(scoreDescLabel);
				
				scoreLabel = drawText(String(settings.target.kicks), {
					color:0xffeb7e,
					fontSize:36,
					autoSize: 'center',
					borderColor:0x76410d
				});
				scoreLabel.x = scoreDescLabel.x + scoreDescLabel.width;
				scoreLabel.y = scoreDescLabel.y;
				scorePanel.addChild(scoreLabel);
				
				if (!upgradeBttn) {
					upgradeBttn = new Button( {
						caption:Locale.__e("flash:1440499603885"),
						width:105,
						height:35,
						fontSize:22
					});
					upgradeBttn.addEventListener(MouseEvent.CLICK, onUpgrade);
				}
				upgradeBttn.x = 453;
				upgradeBttn.y = 180;
				bodyContainer.addChild(upgradeBttn);
				upgradeBttn.showGlowing();
				
				var topBttnText:TextField;
				
				if (!info.tower.hasOwnProperty(settings.target.upgrade + 1) && settings.target.upgrade >= Numbers.countProps(info.tower)) {
					upgradeBttn.hideGlowing();
					upgradeBttn.visible = false;
				}
			}
			
			if (!top100Bttn) {
				top100Bttn = new ImageButton(Window.texture('homeBttn'));
				top100Bttn.scaleX = top100Bttn.scaleY = 0.8;
				
				topBttnText = Window.drawText(Locale.__e('flash:1475056529571'),{//'flash:1440154414885'), {
					textAlign:		'center',
					fontSize:		32,
					color:			0xFFFFFF,
					borderColor:	0x631d0b,
					shadowSize:		1
				});
				topBttnText.x = 20;
				topBttnText.y = (top100Bttn.height - topBttnText.height) / 2 + 10;
				top100Bttn.addChild(topBttnText);
			
				top100Bttn.addEventListener(MouseEvent.CLICK, onTop100);
			}
			top100Bttn.x = 75;
			top100Bttn.y = 30;
			bodyContainer.addChild(top100Bttn);
			
			if (settings.target.sid == 2687)
				top100Bttn.visible = false;
			
			if (upgradeBttn) {
				if (settings.target.kicks < settings.target.kicksMax && settings.target.expire < App.time) {
					upgradeBttn.hideGlowing();
					upgradeBttn.state = Button.DISABLED;
					return
				}
				//trace(Numbers.countProps(Happy.users));
				if (Numbers.countProps(Happy.users) == 0) return;
				if ((!Happy.users.hasOwnProperty(App.user.id) || Happy.take == 1/*Happy.users[App.user.id]['take'] == 1*/) && settings.target.expire < App.time) {
					upgradeBttn.hideGlowing();
					upgradeBttn.state = Button.DISABLED;
				}
			}
		}
		
		public function get progressData():String {
			return String(settings.target.kicks) + ' / ' + String(settings.target.kicksNeed);
		}
		
		protected function progress():void {
			if (progressBar && info.tower.hasOwnProperty(settings.target.upgrade + 1)) {
				progressBar.progress = settings.target.kicks / settings.target.kicksNeed;
				if (settings.target.kicks > settings.target.kicksNeed) {
					settings.target.kicks = settings.target.kicksNeed;
				}
				progressTitle.text = String(settings.target.kicks) + ' / ' + String(settings.target.kicksNeed);
			}
		}
		
		private var items2:Vector.<KickItem> = new Vector.<KickItem>;
		public var itemsContainer:Sprite = new Sprite();
		public function drawKicks():void {
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
			var X:int = 0;
			var Xs:int = X;
			for (var i:int = 0; i < rewards.length; i++) {
				var item:KickItem = new KickItem(rewards[i], this);
				item.x = Xs;
				itemsContainer.addChild(item);
				items2.push(item);
				
				Xs += item.bg.width + 15;
			}
			
			itemsContainer.x = (settings.width - itemsContainer.width) / 2;
		}
		
		protected function clearKicks():void {
			while (items2.length > 0) {
				var item:KickItem = items2.shift();
				itemsContainer.removeChild(item);
				item.dispose();
			}
		}
		
		protected function onTop100(e:MouseEvent = null):void {
			//if (!HappyWindow.rates || Numbers.countProps(HappyWindow.rates) == 0) return;
			
			if (rateChecked == 0) {
				rateChecked = App.time;
				getRate(onTop100);
				return;
			}
			
			rateChecked = 0;
			//changeRate();
			
			var content:Array = [];
			for (var s:* in Happy.users) {
				var user:Object = Happy.users[s];
				user['uID'] = s;
				content.push(user);
			}
			
			var top100DescText:String = Locale.__e('flash:1443175349139');
			if (settings.target.sid == 1518) top100DescText = Locale.__e('flash:1454424636459');
			if (settings.target.topID >= 8 && settings.target.topID != 9 && settings.target.topID != 11 && settings.target.topID != 13) {
				new TopLeaguesWindow( {
					title:			settings.title,
					description:	top100DescText,
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
					description:	top100DescText,
					points:			HappyWindow.rate,
					max:			topx,
					target:			settings.target,
					content:		HappyWindow.rates,
					material:		null,
					popup:			true,
					onInfo:			function():void {
						if (settings.target.sid != 1518 && settings.target.sid != 935) {
							new TopRewardWindow().show();
						}else if (settings.target.sid == 935) {
							new InfoWindow( {
								popup:true,
								qID:'100600'
							}).show();
						}else {
							new InfoWindow( {
								popup:true,
								qID:'100300'
							}).show();
						}
					}
				}).show();
			}
			/*new TopHappyWindow( {
				target:			settings.target,
				content:		content,
				description:	top100DescText,
				max:			topNumber,
				field:			'attraction'
			}).show();*/
			
			//close();
		}
		
		protected function onUpgrade(e:MouseEvent):void {
			if (upgradeBttn.mode == Button.DISABLED) return;
			if (canTakeMainReward) 
				Happy.users[App.user.id]['take'] = 1;
			
			if (settings.target.upgrade >= settings.target.totalTowerLevels) {
				if (settings.target.sid == 1302) {
					new TopRewardWindow().show();
					return;
				}
				if (settings.target.expire - App.time <= 0)
					settings.target.onTakeBonus();
				else {
					if (settings.target.sid == 935) {
						new InfoWindow( {
							popup:true,
							qID:'100600'
						}).show();
					} else {
						new InfoWindow( {
							popup:true,
							qID:'100300'
						}).show();
					}
				}
				return;
			}
			
			settings.target.growAction(onUpgradeComplete);
		}
		
		private function onUpgradeComplete(bonus:Object = null):void {
			if (bonus && Numbers.countProps(bonus) > 0) {
				wauEffect();
				App.user.stock.addAll(bonus);
				//BonusItem.takeRewards(bonus, upgradeBttn, 0);
			}
			
			levelLabel.text = Locale.__e('flash:1436188159724', settings.target.upgrade + 1);
			drawScore();
			updateReward();
			blockItems(false);
			close();
			
			if (settings.target.upgrade >= Numbers.countProps(settings.target.info.tower) - 1) {
				//changeRate();
			}
		}
		
		protected function onHelp(e:MouseEvent):void {
			new SimpleWindow( {
				title:		settings.title,
				text:		App.data.storage[sid].text1,
				popup:		true,
				height:		420
			}).show();
		}
		
		public function blockItems(value:Boolean = true):void {
			for (var i:int = 0; i < items2.length; i++) {
				if (value) {
					items2[i].bttn.state = Button.DISABLED;
				}else {
					items2[i].checkButtonsStatus();
				}
			}
		}
		
		public function kick():void {
			progress();
			App.ui.upPanel.update();
			
			if (settings.target.canUpgrade) {
				blockItems(true);
				drawScore();
			}else {
				blockItems(false);
				if (scoreLabel) scoreLabel.text = String(settings.target.kicks);
			}
			
			if (settings.target.kicksNeed == 0 && settings.target.sid == 2687) {
				blockItems(true);
				rewardCont.visible = false;
				levelLabel.visible = false;
			}
		}
		
		private function timer():void {
			if (timerLabel) timerLabel.text = TimeConverter.timeToDays((settings.target.expire < App.time) ? 0 : (settings.target.expire - App.time));
		}
		
		override public function dispose():void {
			if (top100Bttn) top100Bttn.removeEventListener(MouseEvent.CLICK, onTop100);
			if (upgradeBttn) upgradeBttn.removeEventListener(MouseEvent.CLICK, onUpgrade);
			App.self.setOffTimer(timer);
			super.dispose();
		}
		
		protected function wauEffect():void {
			if (reward.bitmapData != null) {
				var rewardCont:Sprite = new Sprite();
				App.self.contextContainer.addChild(rewardCont);
				
				var glowCont:Sprite = new Sprite();
				glowCont.alpha = 0.6;
				glowCont.scaleX = glowCont.scaleY = 0.5;
				rewardCont.addChild(glowCont);
				
				var glow:Bitmap = new Bitmap(Window.textures.actionGlow);
				glow.x = -glow.width / 2;
				glow.y = -glow.height + 90;
				glowCont.addChild(glow);
				
				var glow2:Bitmap = new Bitmap(Window.textures.actionGlow);
				glow2.scaleY = -1;
				glow2.x = -glow2.width / 2;
				glow2.y = glow.height - 90;
				glowCont.addChild(glow2);
				
				var bitmap:Bitmap = new Bitmap(new BitmapData(reward.width, reward.height, true, 0));
				bitmap.bitmapData = reward.bitmapData;
				bitmap.smoothing = true;
				bitmap.x = -bitmap.width / 2;
				bitmap.y = -bitmap.height / 2;
				rewardCont.addChild(bitmap);
				
				rewardCont.x = layer.x + bodyContainer.x + this.rewardCont.x;
				rewardCont.y = layer.y + bodyContainer.y + this.rewardCont.y;
				
				function rotate():void {
					glowCont.rotation += 1.5;
				}
				
				App.self.setOnEnterFrame(rotate);
				
				TweenLite.to(rewardCont, 0.5, { x:App.self.stage.stageWidth / 2, y:App.self.stage.stageHeight / 2, scaleX:1.25, scaleY:1.25, ease:Cubic.easeInOut, onComplete:function():void {
					setTimeout(function():void {
						App.self.setOffEnterFrame(rotate);
						glowCont.alpha = 0;
						var bttn:* = App.ui.bottomPanel.bttnMainStock;
						var _p:Object = { x:App.ui.bottomPanel.x + bttn.parent.x + bttn.x + bttn.width / 2, y:App.ui.bottomPanel.y + bttn.parent.y + bttn.y + bttn.height / 2};
						SoundsManager.instance.playSFX('takeResource');
						TweenLite.to(rewardCont, 0.3, { ease:Cubic.easeOut, scaleX:0.7, scaleY:0.7, x:_p.x, y:_p.y, onComplete:function():void {
							TweenLite.to(rewardCont, 0.1, { alpha:0, onComplete:function():void {App.self.contextContainer.removeChild(rewardCont);}} );
						}} );
					}, 3000)
				}} );
			}
		}
		
		public function get canTakeMainReward():Boolean {
			if (settings.target.expire < App.time /*&& rateChecked > 0*/ && (Numbers.countProps(info.tower) /*- 1*/ == settings.target.upgrade) && settings.target.kicks >= settings.target.kicksMax && Happy.users.hasOwnProperty(App.user.id) && Happy.users[App.user.id]['take'] != 1)
				return true;
			
			return false;
		}
		
		public static var rateChecked:int = 0;
		private var onUpdateRate:Function;
		public function changeRate():void {
			return;
			//if (settings.target.kicks < settings.target.kicksMax) return;
			if (Happy.users.hasOwnProperty(App.user.id) && Happy.users[App.user.id].attraction == settings.target.kicks) return;
			
			if (!Happy.users.hasOwnProperty(App.user.id)) {
				if (Numbers.countProps(Happy.users) >= topNumber) {
					for (var id:* in Happy.users) {
						if (Happy.users[id].attraction < settings.target.kicks) {
							delete Happy.users[id];
						}
					}
				}
				
				if (Numbers.countProps(Happy.users) < topNumber) {
					Happy.users[App.user.id] = {
						first_name:		App.user.first_name,
						last_name:		App.user.last_name,
						photo:			App.user.photo,
						attraction:		0
					}
				}
			}
			
			if (Happy.users.hasOwnProperty(App.user.id)) {
				Happy.users[App.user.id].attraction = settings.target.kicks;
			}
			
			if (!Happy.users.hasOwnProperty(App.user.id) || Happy.take == 1/*Happy.users[App.user.id]['take'] == 1*/) {
					if (settings.target.expire < App.time){
					upgradeBttn.hideGlowing();
					upgradeBttn.state = Button.DISABLED;
				}
				return;
			}
			
			Post.send( {
				ctr:		'user',
				act:		'attraction',
				uID:		App.user.id,
				rate:		info.type + '_' + String(sid),
				rate_max:   topNumber,
				user:		JSON.stringify({first_name:App.user.first_name, last_name:App.user.last_name, photo:App.user.photo, attraction:settings.target.kicks })
			}, function(error:int, data:Object, params:Object):void {
				if (error) return;
				
				if (data['users']) settings.target.usersLength = data.users;
			});
		}
		private function getRate(callback:Function = null):void {
			//if (rateChecked > 0) return;
			//rateChecked = 0;
			
			onUpdateRate = callback;
			
			Post.send( {
				ctr:		'top',
				act:		'users',
				uID:		App.user.id,
				tID:		HappyWindow.topID,
				league:		App.user.level
			}, function(error:int, data:Object, params:Object):void {
				if (error) return;
				
				//rateChecked = App.time;
				
				if (data.hasOwnProperty('users')) {
					HappyWindow.rates = data['users'] || { };
					
					for (var id:* in HappyWindow.rates) {
						if (App.user.id == id) {
							HappyWindow.rate = HappyWindow.rates[id]['points'];
						}
						
						HappyWindow.rates[id]['uID'] = id;
					}
				}
				
				if (App.user.top.hasOwnProperty(HappyWindow.topID)) {
					HappyWindow.rate = (HappyWindow.rate > App.user.top[HappyWindow.topID].count) ? HappyWindow.rate : App.user.top[HappyWindow.topID].count;
				}
				
				if (Numbers.countProps(HappyWindow.rates) > topx) {
					var array:Array = [];
					for (var s:* in HappyWindow.rates) {
						array.push(HappyWindow.rates[s]);
					}
					array.sortOn('points', Array.NUMERIC | Array.DESCENDING);
					array = array.splice(0, topx);
					for (s in HappyWindow.rates) {
						if (array.indexOf(HappyWindow.rates[s]) < 0)
							delete HappyWindow.rates[s];
					}
				}
				
				if (onUpdateRate != null) {
					onUpdateRate();
					onUpdateRate = null;
				}
			});
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
import flash.geom.Point;
import flash.text.TextField;
import ui.Hints;
import wins.actions.BanksWindow;
import wins.elements.PriceLabel;
import wins.elements.PriceLabelShop;
import wins.ProductionWindow;
import wins.ShopWindow;
import wins.SimpleWindow;
import wins.Window;
internal class KickItem extends LayerX{
	
	public var window:*;
	public var item:Object;
	public var bg:Sprite;
	private var bitmap:Bitmap;
	private var sID:uint;
	public var bttn:Button;
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
	private var icon:Bitmap;
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
		
		checkButtonsStatus();
		
		/*if (type == 3 && App.data.storage[sID].hasOwnProperty('price')) {
			for (var currency:* in App.data.storage[sID].price) {
				var count:int = App.data.storage[sID].price[currency];
			}
			var buyBttn:Button = new Button({
				caption:Locale.__e('flash:1382952379751'),
				bgColor:[0xa6f949, 0x74bb15],
				borderColor:[0x000000, 0x000000],
				bevelColor:[0xbfeea8, 0x48882a],
				width:115,
				height:40,
				fontSize:22
			});
			addChild(buyBttn);
			buyBttn.textLabel.x = 5;
			buyBttn.x = (bg.width - buyBttn.width) / 2;
			buyBttn.y = bttn.y + bttn.height + 5;
			buyBttn.addEventListener(MouseEvent.CLICK, onBuy);
			
			var label:PriceLabelShop = new PriceLabelShop(App.data.storage[sID].price);
			buyBttn.addChild(label);
			label.x = buyBttn.width - label.width - 10;
			label.y = (buyBttn.height - label.height) / 2 + 10;
		}*/
	}
	
	private function onBuy(e:MouseEvent):void {
		
	}
	
	//private function onLoadIcon(data:Bitmap):void {
		//if (!data || !icon)
			//return;
			//
		//icon.bitmapData = data.bitmapData;		
		//icon.scaleX = icon.scaleY = 0.35;
		//icon.x = 20;
		//icon.y = 4;
		//icon.smoothing = true;
	//}
	//
	
	public function checkButtonsStatus():void {
		if (window.settings.target.expire < App.time || window.settings.target.canUpgrade) {
			bttn.state = Button.DISABLED;
			return;
		}
		
		if (type == 2) {
			bttn.state = Button.NORMAL;
		}else if (type == 3) {
			if (App.user.stock.count(sID) < price) {
				bttn.state = Button.NORMAL;
				bttn.caption = Locale.__e('flash:1405687705056');
			}else {
				bttn.state = Button.NORMAL;
				bttn.caption = Locale.__e("flash:1382952379978");
			}
		}
	}
	
	private function onClick(e:MouseEvent):void {
		if (e.currentTarget.mode == Button.DISABLED) return;
		if (type == 3) {
			if (App.user.stock.count(sID) < price) {
				if (!ShopWindow.findMaterialSource(sID)) {
					if ([1314,1316].indexOf(int(sID)) != -1) {
						var unit:Array = Map.findUnits([684]);
						if (unit.length > 0) {
							App.map.focusedOn(unit[0], true, function():void {
								ProductionWindow.find = [1297,1298,1299];
								unit[0].click();
							});
						}else {
							ShopWindow.show( { find:[684] } );
						}
					}
				} 
				window.close();
			}else {
				if (currency == Stock.FANT && App.user.stock.count(Stock.FANT) < price) {
					window.close();
					BanksWindow.history = {section:'Reals',page:0};
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
		} else {
			if (currency == Stock.FANT && App.user.stock.count(Stock.FANT) < price) {
				window.close();
				BanksWindow.history = {section:'Reals',page:0};
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
	}
	
	private function onKickEventComplete(bonus:Object = null):void {
		App.user.stock.take(currency, price);
		
		var X:Number = App.self.mouseX - bttn.mouseX + bttn.width / 2;
		var Y:Number = App.self.mouseY - bttn.mouseY;
		Hints.minus(currency, price, new Point(X, Y), false, App.self.tipsContainer);
		
		/*if (Numbers.countProps(bonus) > 0) {
			BonusItem.takeRewards(bonus, bttn, 20);
			App.user.stock.addAll(bonus);
		}*/
		
		if (bonus){
			flyBonus(bonus);
		}
		
		if (stockCount) stockCount.text = 'x' + App.user.stock.count(sID);
		window.kick();
		
		checkButtonsStatus();
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
	
	private var stockCount:TextField;
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
