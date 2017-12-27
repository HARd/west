package ui {
	
	import adobe.utils.CustomActions;
	import buttons.Button;
	import buttons.ImageButton;
	import com.adobe.images.BitString;
	import com.greensock.TweenLite;
	import core.Load;
	import core.Numbers;
	import core.TimeConverter;
	import effects.BoostEffect;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.text.TextField;
	import flash.utils.Timer;
	import helpers.FrameRater;
	import units.Exchange;
	import units.Happy;
	import units.Techno;
	import wins.HalloweenWindow;
	import wins.ShopWindow;
	import wins.actions.BanksWindow;
	import wins.CalendarWindow;
	import wins.ChooseBoxWindow;
	import wins.ExchangeWindow;
	import wins.FiestaWindow;
	import wins.FrenchEventWindow;
	import wins.LevelUpWindow;
	import wins.PurchaseWindow;
	import wins.RouletteWindow;
	import wins.ShopWindow;
	import wins.SimpleWindow;
	import wins.StockWindow;
	import wins.ThanksgivingEventWindow;
	import wins.TravelWindow;
	import wins.Window;
	
	public class UpPanel extends Sprite {
		
		public var coinsPanel:Panel;
		public var fantsPanel:Panel;
		public var workersPanel:Panel;
		public var energyPanel:Panel;
		public var expPanel:Panel;
		public var guestPanel:GuestPanel;
		public var levelLabel:TextField;
		
		public var guestWakeUpPanel:Sprite;		
		public var guestButton:Button;
		private var bg:Bitmap;
		
		public var coinsBoost:BoostEffect;
		public var expBoost:BoostEffect;
		public var energyBoost:BoostEffect;
		
		public var eventBttn:ImageButton;
		public var eventIcon:EventIcon;
		
		public var calendarBttn:ImageButton;
		public var rouletteBttn:ImageButton;
		
		//
		public var leftCont:Sprite = new Sprite();
		public var rightCont:Sprite = new Sprite();
		public var worldPanel:WorldPanel = new WorldPanel();
		//
		
		public var help:LayerX;
		private var timer:Timer = new Timer(2000, 1);
		
		public function UpPanel() {
			draw();
			App.self.addEventListener(AppEvent.ON_CHANGE_STOCK, update);
		}
		
		private function draw():void {
			coinsPanel = new Panel(Panel.COINS, {onClick:onCoinsEvent, tip: {text:Locale.__e('flash:1428498131656')}});
			fantsPanel = new Panel(Panel.FANTS, {onClick:onFantsEvent, tip: {text:Locale.__e('flash:1428498235467')}});
			workersPanel = new Panel(Panel.WORKERS, { onClick:onWorkersEvent, tip: { text:Locale.__e('flash:1428498282109') }/*, itemTip: {text:Locale.__e('flash:1429171645892') + '\n\n' + Locale.__e('flash:1433919651624',Techno.freeTechno.length) + '\n' + Locale.__e('flash:1433919809958') + '\n' + Locale.__e('flash:1433919938191',Techno.count)}*/});
			energyPanel = new Panel(Panel.ENERGY, {onClick:onEnergyEvent, tip: {text:Locale.__e('flash:1428498328901')}});
			expPanel = new Panel(Panel.EXP, {onClick:onExpEvent});
			
			coinsBoost = new BoostEffect(-3, 12);
			expBoost = new BoostEffect(-3, 12);
			energyBoost = new BoostEffect( -3,12/*, true*/);
			coinsPanel.addChild(coinsBoost);
			expPanel.addChild(expBoost);
			energyPanel.addChild(energyBoost);
			
			coinsPanel.tip = function():Object {
				var text:String = Locale.__e('flash:1382952379825');
				var timer:Boolean = false;
				for (var id:String in App.user.stock.data) {
					if (App.data.storage[id].type == 'Vip' && App.user.stock.data[id] > App.time) {
						for (var out:* in App.data.storage[id].outs) break;
						if (out != Stock.COINS) continue;
						var percent:int = App.data.storage[id].outs[Stock.COINS];
						text = Locale.__e('flash:1413277595939', [String(percent), TimeConverter.timeToStr(App.user.stock.data[id] - App.time)]) + '\n' + text;
						timer = true;
					}
				}
				var title:String = App.data.storage[Stock.COINS].title;
				
				title = App.data.storage[coinsPanel.coinsVars[coinsPanel.position]].title;
				text = App.data.storage[coinsPanel.coinsVars[coinsPanel.position]].description;
				
				return {
					title:title,
					text:text,
					timer:timer
				}
				//return { title:App.data.storage[Stock.COINS].title, text:App.data.storage[Stock.COINS].description };
			}
			fantsPanel.tip = function():Object {
				return { title:App.data.storage[Stock.FANT].title, text:App.data.storage[Stock.FANT].description };
			}
			if (App.isSocial('VK','FS','ML','OK','DM')/*App.user.worldID == Travel.SAN_MANSANO*/) {
				workersPanel.tip = function():Object {
					return { text:Locale.__e('flash:1429171645892') + '\n\n' + Locale.__e('flash:1470211399883', Techno.freeTechno().length.toString()) + '\n' + Locale.__e('flash:1470211462887', Techno.getHungry().length.toString()) + '\n' + Locale.__e('flash:1470211519554', Techno.count.toString()) };
				}
			}else {
				workersPanel.tip = function():Object {
					return { text:Locale.__e('flash:1429171645892') + '\n\n' + Locale.__e('flash:1433919651624', Techno.freeTechno().length.toString()) + '\n' + Locale.__e('flash:1433919809958', Techno.getHungry().length.toString()) + '\n' + Locale.__e('flash:1433919938191', Techno.count.toString()) };
				}
			}
			energyPanel.tip = function():Object {
				var text:String = App.data.storage[Stock.ENERGY].description;
				var title:String = App.data.storage[Stock.ENERGY].title + ' ' + App.user.stock.count(Stock.ENERGY) + '/' + App.user.stock.maxEnergyOnLevel;
				var timer:Boolean = false;
				if (App.user.stock.count(Stock.FANTASY) < App.user.stock.maxEnergyOnLevel) {
					var time:int =  (Stock.energyRestoreTime - App.user.stock.diffTime);
					if (time < 0) time = 0;
					if (time > Stock.energyRestoreTime) time = Stock.energyRestoreTime;
					text = TimeConverter.timeToStr(time) + '\n' + text;
					timer = true;
				}
				
				for (var id:String in App.user.stock.data) {
					if (App.data.storage[id].type == 'Vip' && App.user.stock.data[id] > App.time) {
						for (var out:* in App.data.storage[id].outs) break;
						if (out != Stock.ENERGY) continue;
						var percent:int = App.data.storage[id].outs[Stock.ENERGY];
						text = Locale.__e('flash:1413277595939', [String(percent), TimeConverter.timeToStr(App.user.stock.data[id] - App.time)]) + '\n' + text;
						timer = true;
					}
				}
				
				return { title:title, text:text, timer:timer };
			}
			expPanel.tip = function():Object {
				if (!App.data.levels.hasOwnProperty(App.user.level + 1)) return null;
				var diffExp:int = App.data.levels[App.user.level + 1].experience || 0; 
				diffExp -= App.user.stock.count(Stock.EXP);
				diffExp = diffExp > 0?diffExp:0;
								
				var text:String = Locale.__e('flash:1382952379834', [diffExp, App.user.level + 1]);
				var timer:Boolean = false;
				for (var id:String in App.user.stock.data) {
					if (App.data.storage[id].type == 'Vip' && App.user.stock.data[id] > App.time) {
						for (var out:* in App.data.storage[id].outs) break;
						if (out != Stock.EXP) continue;
						var percent:int = App.data.storage[id].outs[Stock.EXP];
						text = Locale.__e('flash:1413277595939', [String(percent), TimeConverter.timeToStr(App.user.stock.data[id] - App.time)]) + '\n' + text;
						timer = true;
					}
				}
				
				return {
					title:App.data.storage[Stock.EXP].title,
					text:text,
					timer:timer
				}
			}
			expPanel.addEventListener(MouseEvent.CLICK, onKeyLevelShow);
			
			drawBankSale();
			calendarBttn	= new ImageButton(UserInterface.textures.interCalendarIco);
			calendarBttn.addEventListener(MouseEvent.CLICK, onCalendarEvent);
			
			rouletteBttn   = new ImageButton(Window.texture('rouletteIco'));
			rouletteBttn.addEventListener(MouseEvent.CLICK, onRouletteEvent);
			rouletteBttn.showGlowing();
			rouletteBttn.tip = function():Object {
				return {
					title:Locale.__e('flash:1458406437401'),
					text:Locale.__e('flash:1452699034116')
				}
			}
			
			addChild(coinsPanel);
			addChild(fantsPanel);
			addChild(workersPanel);
			addChild(energyPanel);
			addChild(expPanel);
			
			addChild(leftCont);
			addChild(rightCont);
			addChild(worldPanel);
			
			calendarBttn.tip = function():Object {
				return {
					title:Locale.__e('flash:1439979200514'),
					text:Locale.__e('flash:1439995877903')
				}
			}
			calendarBttn.x = App.self.stage.stageWidth - calendarBttn.width - 190; // (jamBttn.visible ? jamBttn.width + 18 : fishBttn.width + 18);
			calendarBttn.y = 60;
			addChild(calendarBttn);
			
			rouletteBttn.x = calendarBttn.x - rouletteBttn.width - 10; // (jamBttn.visible ? jamBttn.width + 18 : fishBttn.width + 18);
			rouletteBttn.y = 59;
			addChild(rouletteBttn);
			if (!App.data.hasOwnProperty('roulette') || !App.data.roulette[1] || App.data.roulette[1].social.indexOf(App.social) == -1 || !App.data.roulette[1].active) {
				rouletteBttn.visible = false;
			}
			
			//if (App.isSocial('MX', 'AI')) calendarBttn.visible = false;
			
			levelLabel = Window.drawText(App.user.level.toString(), {
				color:			0xfff9e7,
				borderColor:	0x97480f,
				fontSize:		26,
				shadowSize:		2,
				width:			50,
				textAlign:		'center'
			});
			levelLabel.x = -7;
			levelLabel.y = 6;
			expPanel.addChild(levelLabel);
			
			// Guest
			guestPanel = new GuestPanel();
			addChild(guestPanel);
			guestPanel.visible = false;
			
			//if (Events.timeOfComplete > App.time) {
				//addEventButton();
			//}
			//
			//for (var topID:* in App.data.top) {
				//if (App.data.top[topID].hasOwnProperty('expire') && App.data.top[topID].expire.s < App.time && App.data.top[topID].expire.e > App.time) {
					//addTopBttn(topID);
				//}
			//}
			//var expire:uint = (App.data.hasOwnProperty('top') && App.data.top.hasOwnProperty(App.user.topID)/* && App.data.storage[App.data.top[App.user.topID].target].type == 'Material'*/) ? App.data.top[App.user.topID].expire.e : 0;
			//if (expire > App.time) {
				////addThanksEventButton(expire);
			//}
			
			//addMDayBox();
			
		}
		
		private function onRouletteEvent(e:MouseEvent):void {
			rouletteBttn.hidePointing();
			if (!App.user.quests.tutorial)  {
				new RouletteWindow().show();
			}
		}
		
		private function onCalendarEvent(e:MouseEvent):void 
		{
			if (!App.user.quests.tutorial)  {
				new CalendarWindow().show();
			}
			
		}
		
		//iconImage - картинка для иконки (берется из папки /resources/images/content/)
		//priority - приоритет на показ иконки (показывается всегда ТОЛЬКО одна с НАИВЫСШИМ приоритетом)
		//event - true иконка привязана к ивенту
		//ownerID - айди объекта, привязанного к иконке
		//updateID - айди обновления, привязанного к иконке
		//topID - айди топа, привязанного к иконке
		//social - ограничение по сетям
		//target - цель для поиска при клике на иконку (дополнительный параметр)
		public function checkGameIcon():void {
			if (!App.data.options.hasOwnProperty('GameIcons')) return;
			
			var info:Object;
			var icons:Array = [];
			
			try {
				info = JSON.parse(App.data.options.GameIcons);
			}catch (e:Error) {
				info = { };
			}
			
			for each (var icon:Object in info) {
				var expire:int = 0;
				if (icon.hasOwnProperty('event') && icon.event == true){
					expire = Events.timeOfComplete;
				}else if (icon.hasOwnProperty('ownerID')) {
					if (!App.data.storage.hasOwnProperty(icon.ownerID)) continue;
					if (icon.hasOwnProperty('updateID')) {
						if (App.data.updatelist.hasOwnProperty(App.social) && !App.data.updatelist[App.social].hasOwnProperty(icon.updateID)) {
							continue;
						}
					}
					var owner:Object = App.data.storage[icon.ownerID];
					
					if (owner && User.inUpdate(icon.ownerID) && owner.hasOwnProperty('expire')) {
						if (owner.expire.hasOwnProperty(App.social)) {
							expire = owner.expire[App.social];
						} else {
							expire = owner.expire;
						}
					} else {
						continue;
					}
					
				}
				
				if (icon.hasOwnProperty('updateID')) {
					if (App.data.updatelist.hasOwnProperty(App.social) && App.data.updatelist[App.social].hasOwnProperty(icon.updateID)) {
						if (!expire)
							expire = App.data.updatelist[App.social][icon.updateID] + 86400 * 14;
					} else {
						continue;
					}
				}
				
				if (icon.hasOwnProperty('topID')) {
					if (App.data.top.hasOwnProperty(icon.topID) && App.data.top[icon.topID].hasOwnProperty('expire') && App.data.top[icon.topID].expire.hasOwnProperty('e')) {
						expire = App.data.top[icon.topID].expire.e;
					}else {
						continue;
					}
				}
				
				if (expire == 0 || expire <= App.time) continue;
				
				if (icon.hasOwnProperty('social') && icon.social.indexOf(App.social) == -1) {
					continue;
				}
				
				icon['expire'] = expire;
				icons.push(icon);
			}
			
			icons.sortOn('priority', Array.DESCENDING);
			
			if (icons.length > 0 ) showGameIcon(icons[0]);
		}
		
		private var gameIcon:EventIcon;
		private function showGameIcon(icon:Object):void {
			if (gameIcon) return;
			
			gameIcon = new EventIcon( {
				icon:			icon.iconImage,
				endTime:		icon.expire,
				onClick:		function():void {
					if (App.user.quests.tutorial) return;
					if (App.user.mode != User.OWNER) return;
					
					var unit:Array;
					var worldID:int = 0;
					var worldItem:*;
					var target:*;
					var item:*;
					if (icon.hasOwnProperty('event') && icon.event == true){
						new FrenchEventWindow().show();
						return;
					}else if (icon.hasOwnProperty('target')) {
						target = icon.target;
					} else if (icon.hasOwnProperty('ownerID') && User.inUpdate(icon.ownerID)) {
						target = icon.ownerID;
					}else if (icon.hasOwnProperty('topID')) {
						if (App.data.storage[App.data.top[icon.topID].target].type == 'Material') 
							target = App.data.top[icon.topID].unit;
						else 
							target = App.data.top[icon.topID].target;
					}
					
					if (target) {
						unit = Map.findUnits([target]);
						if (unit.length > 0 ) {
							App.map.focusedOn(unit[0], true, function():void {
								unit[0].click();
							});
						}else {
							for (worldItem in App.user.instanceWorlds) {
								for (item in App.user.instanceWorlds[worldItem]) {
									if (item == target) {
										worldID = worldItem;
									}
								}
							}
							if (worldID != 0) {
								TravelWindow.show({find:worldID});
							}else {
								if (App.user.worldID != User.HOME_WORLD) {
									TravelWindow.show({find:User.HOME_WORLD});
								}else {
									ShopWindow.find(target);
								}
							}
						}
					} else {
						ShopWindow.show( { section:100 } );
					}
				}
			});
			gameIcon.x = 75;
			gameIcon.y = 44;
			addChild(gameIcon);
		}
		
		//public function addEventButton():void {
			//eventIcon = new EventIcon( {
				//icon:			'eventIcon10',
				//endTime:		Events.timeOfComplete,
				//onClick:		function():void {
					
					//new HalloweenWindow().show();
					//new ShopWindow({find:[2964]}).show();
					
					// Поиск Эйб
					//Find.find(2964);
					//ShopWindow.findMaterialSource(2964);
					
					/*if (App.user.quests.tutorial) return;
					if (App.user.mode != User.OWNER) return;
					
					if (App.isSocial('FB', 'NK', 'SP', 'YB', 'MX', 'AI', 'GN')) {
						if (User.mine) {
							User.mine.openProductionWindow();
						}else {
							if (App.user.quests.data.hasOwnProperty(1002) && App.user.quests.data[1002].finished != 0) {
								if (App.user.worldID != User.HOME_WORLD) {
									new TravelWindow( { find:User.HOME_WORLD } ).show();
								} else {
									App.map.checkUnitsSpawn();
								}
							}else {
								if (App.user.worldID != User.HOME_WORLD) {
									new TravelWindow( { find:User.HOME_WORLD } ).show();
								}else {
									new SimpleWindow( {
										text:Locale.__e('flash:1455269552420'),
										title:Locale.__e('flash:1382952380254'),
										popup:true,
										confirm:function():void {
											checkQuests(1002);
										}
									}).show();
								}
							}
						}
						return;
					}
					
					if (App.user.worldID == Travel.SAN_MANSANO) {
						var unit:Array = Map.findUnits([2570]);
						if (unit.length > 0 ) {
							App.map.focusedOn(unit[0], true, function():void {
								unit[0].click();
							});
						}else {
							new SimpleWindow( {
								text:Locale.__e('flash:1455269552420'),
								title:Locale.__e('flash:1382952380254'),
								popup:true,
								confirm:function():void {
									checkQuests(1003);
								}
							}).show();
						}
					}else {
						new TravelWindow( { find:Travel.SAN_MANSANO} ).show();
					}*/
				//}
			//});
			//eventIcon.x = 75;
			//eventIcon.y = 44;
			//addChild(eventIcon);
			/*eventIcon = new EventIcon( {
				icon:			'EventValentinesDeyIco2',
				endTime:		App.data.top[6].expire.e,
				onClick:		function():void {
					//new FrenchEventWindow().show();
					if (App.user.mode != User.OWNER || App.user.worldID != User.HOME_WORLD) return;
					var unit:Array = Map.findUnits([1518]);
					if (unit.length > 0 ) {
						App.map.focusedOn(unit[0], true, function():void {
							if (unit[0] is Exchange)
								ExchangeWindow.depthShow = 1;
							unit[0].click();
						});
					}else {
						if (App.user.quests.data.hasOwnProperty(533) && App.user.quests.data[533].finished != 0) {
							new StockWindow( { find:[1518] } ).show();
						}else {
							new SimpleWindow( {
								text:Locale.__e('flash:1455269552420'),
								title:Locale.__e('flash:1382952380254'),
								popup:true,
								confirm:checkQuests
							}).show();
						}
					}
				}
			});
			eventIcon.x = 75;
			eventIcon.y = 44;
			addChild(eventIcon);*/
		//}
		public function deleteEventButton():void {
			if (eventIcon) {
				removeChild(eventIcon);
				eventIcon = null;
			}
		}
		
		private var dayBoxBttn:ImageButton;
		private var dayBonus:Object;
		private var dayBonusID:int;
		public function addMDayBox():void {
			var date:Date = new Date();
			var day:int = date.day;
			dayBonus = null;
			
			for (var b:* in App.data.bonus) {
				if (App.data.bonus[b].type == 'MDay' && App.data.bonus[b].day == day) {
					dayBonus = App.data.bonus[b];
					dayBonusID = int(b);
					break;
				}
			}
			
			if (dayBonus) {
				if (!dayBoxBttn) {
					dayBoxBttn = new ImageButton(UserInterface.textures.iconCollection);
					dayBoxBttn.addEventListener(MouseEvent.CLICK, onDayBoxEvent);
					dayBoxBttn.x = calendarBttn.x - dayBoxBttn.width - 10; // (jamBttn.visible ? jamBttn.width + 18 : fishBttn.width + 18);
					dayBoxBttn.y = 59;
					addChild(dayBoxBttn);
				}
			}
		}
		
		private function onDayBoxEvent(e:MouseEvent):void {
			new ChooseBoxWindow({bonus:dayBonus, id:dayBonusID}).show();
		}
		
		public function checkQuests(qID:int = 534):void {
			if (App.user.quests.data.hasOwnProperty(qID) && App.user.quests.data[qID].finished == 0) {
				for each (var icon:QuestIcon in App.ui.leftPanel.questsPanel.icons) {
					if (icon.qID == qID) {
						//icon.glowIcon('');
						icon.onQuestOpen();
					} else if (icon.otherItems) {
						for each (var other:* in icon.otherItems) {
							if (other.id == qID) {
								App.user.quests.openWindow(other.id);
							}
						}
					}
				}
			} else if (App.data.quests[qID].hasOwnProperty('parent') && App.data.quests[qID].parent != 0) {
				checkQuests(App.data.quests[qID].parent)
			}
		}
		
		private function addThanksEventButton(time:int = 0):void {
			eventIcon = new EventIcon( {
				icon:			'EventThx',
				endTime:		time,
				onClick:		function():void {
					new ThanksgivingEventWindow().show();
					/*var updatelist:Array = [];
					var update:Object;
					if(App.data.updatelist.hasOwnProperty(App.social)) {
						for (var s:String in App.data.updatelist[App.social]) {
							if (!App.data.updates.hasOwnProperty(s)) continue;
							if (!App.data.updates[s].social.hasOwnProperty(App.social)) continue;
							updatelist.push( {
								nid: s,
								update: App.data.updates[s],
								order: App.data.updatelist[App.social][s]
							});
						}
						updatelist.sortOn('order', Array.NUMERIC);
						updatelist.reverse();
					}
					if (updatelist[0])
					{
						update = updatelist[0].update;
						update['nid'] = updatelist[0].nid;
					}
					
					if (update == null) return;
					var count:int;
					var _cookie:String = App.user.storageRead('upd', '');
					var cookie:Array = _cookie.split("_");
					
					if (cookie.length == 0 || cookie[0] != update.nid) {
						cookie[0] = update.nid;
						cookie[1] = count;
						if (cookie[2]) cookie[2] = 0;
					}else {
						cookie[1] = int(cookie[1]) + 1;
						count = cookie[1];
					}
					App.user.storageStore('upd', cookie.join('_'));				
					Load.loading(Config.getImageIcon('updates/images', update.preview), function(data:Bitmap):void {
						new FiestaWindow( { news:update } ).show();
					});*/
					//var unit:Array = Map.findUnits([797]);
					//if (unit.length > 0 ) {
						//App.map.focusedOn(unit[0], true, function():void {
							//if (unit[0] is Exchange)
								//ExchangeWindow.depthShow = 1;
							//unit[0].click();
						//});
					//}else {
						//new ShopWindow( { find:[797] } ).show();
					//}
				}
			});
			eventIcon.x = 75;
			eventIcon.y = 44;
			addChild(eventIcon);
		}
		
		public function onKeyLevelShow(e:MouseEvent):void {
			if (App.user.quests.tutorial) return;
			new LevelUpWindow({nextKeyLevel:true}).show();
		}
		
		private function drawBankSale():void {
			var money:Object;
			if (!App.data.money.hasOwnProperty(App.social)) return
				
				money = App.data.money[App.social];
				
				// Акция запускается если:
				//		- попадает в пределы времени;
				//		- достигнут уровень
				if ((money.enabled && money.date_to > App.time && money.date_from < App.time) || (App.user.money > App.time)){
					showBankRibbon();
				} 
		}
		
		private var bmp:Bitmap;
		public function showBankRibbon():void {
			if (bmp) return;
			var back:Sprite = new Sprite();
			bmp = new Bitmap(UserInterface.textures.interBankSale);
			back.x = coinsPanel.x + coinsPanel.width - 40;
			back.y = coinsPanel.y + coinsPanel.height - 15;
			addChildAt(back,0);
			back.addChild(bmp);
			
			if (App.isSocial('YB')) {
				back.x -= 10;
				back.y -= 10;
			}
			
			var textAction:TextField = Window.drawText(Locale.__e('flash:1396521604876'), {
				color       : 0xffffff,
				borderColor : 0x8e1b00
			});
			textAction.x = (bmp.width - textAction.textWidth) * 0.5;
			textAction.y = (bmp.height - textAction.textHeight) * 0.5;
			back.addChild(textAction);
			back.addEventListener(MouseEvent.CLICK, onBankClick);
		}
		
		private function onBankClick(e:MouseEvent):void {
			BanksWindow.history = {section:'Reals',page:0};
			new BanksWindow().show();
		}
		
		public function hideWakeUpPanel():void {
			if(guestPanel != null){
				guestPanel.hideAwake();
			}
		}
		//
		//private function guestAction(Event:MouseEvent):void {
			//guestButton.state = Button.DISABLED;  // need to make button like disable
			//App.self.sendPostWake();			
		//}
		
		public function update(... args):void {
			coinsPanel.setText(Numbers.moneyFormat(App.user.stock.data[Stock.COINS]));
			if (App.user.worldID == Travel.SAN_MANSANO) {
				coinsPanel.showMoneyType(4);
			} else {
				coinsPanel.showMoneyType(0);
			}
			fantsPanel.setText(Numbers.moneyFormat(App.user.stock.data[Stock.FANT]));
			workersPanel.updateIcon();
			workersPanel.setText(Techno.freeTechno().length + '/' + Techno.count);
			energyPanel.setText(String(App.user.stock.data[Stock.ENERGY]));
			energyPanel.updateSlider();
			expPanel.setText(Numbers.moneyFormat(App.user.stock.data[Stock.EXP]));
			expPanel.updateSlider();
			levelLabel.text = App.user.level.toString();
			
			App.ui.systemPanel.resize();
		}
		
		public function resize():void {
			coinsPanel.x = 5;
			coinsPanel.y = 4;
			fantsPanel.x = coinsPanel.x + coinsPanel.width + 10;
			fantsPanel.y = 4;
			workersPanel.x = fantsPanel.x + fantsPanel.width + 10;
			workersPanel.y = 4;
			expPanel.x = App.self.stage.stageWidth - expPanel.width - 10;
			expPanel.y = 4;
			energyPanel.x = expPanel.x - 10 - energyPanel.width;
			energyPanel.y = 4;
			
			guestPanel.x = (App.self.stage.stageWidth - fantsPanel.width) / 2;
			guestPanel.y = 4;
			
			worldPanel.resize();
			
			if(guestWakeUpPanel != null){
				guestWakeUpPanel.x = (App.self.stage.stageWidth - guestWakeUpPanel.width)/2 + 65;
				guestWakeUpPanel.y = guestPanel.y + guestPanel.height;
			} 
			
			if (rouletteBttn.__hasPointing) {
				rouletteBttn.hidePointing();
				App.ui.upPanel.rouletteBttn.showPointing("bottom",0,90,App.ui.upPanel, "", null, false);
			}
			
			App.ui.systemPanel.resize();
		}
		
		public function show(mode:int = 0):void {
			if (App.ui.mode == UserInterface.GUEST) {
				coinsPanel.visible = true;
				fantsPanel.visible = true;
				workersPanel.visible = false;
				energyPanel.visible = false;
				expPanel.visible = true;
				guestPanel.visible = true;
			} else {
				coinsPanel.visible = true;
				fantsPanel.visible = true;
				workersPanel.visible = true;
				energyPanel.visible = true;
				expPanel.visible = true;
				guestPanel.visible = false;
			}
			
			resize();
		}
		
		public function hide():void {
			
		}
		
		public function onCoinsEvent(e:MouseEvent = null):void {
			App.ui.bottomPanel.changeCursorPanelState(true);
			if (App.user.worldID == Travel.SAN_MANSANO) {
				var content:Array = PurchaseWindow.createContent('Energy', { view:App.data.storage[Stock.VAUCHER].view } );
				if (content.length > 0 ) {
					new PurchaseWindow( {
						width:620,
						itemsOnPage:content.length,
						content:content,
						title:App.data.storage[Stock.VAUCHER].title,
						fontBorderColor:0xd49848,
						shadowColor:0x553c2f,
						shadowSize:4,
						hasDescription:false,
						description:App.data.storage[Stock.VAUCHER].description,
						popup: true,
						closeAfterBuy:false
					}).show();
					return;
				}
			}
			
			BanksWindow.history = {section:'Coins',page:0};
			new BanksWindow().show();
		}
		
		public function onFantsEvent(e:MouseEvent = null):void {
			App.ui.bottomPanel.changeCursorPanelState(true);
			BanksWindow.history = {section:'Reals',page:0};
			new BanksWindow().show();
		}
		
		public function onWorkersEvent(e:MouseEvent = null):void {
			if (App.user.worldID != 112 && App.user.worldID != 767 && App.user.worldID != 903 && App.user.worldID != 1371 && App.user.worldID != 1569 && App.user.worldID != 418 && App.user.worldID != 1907 && App.user.worldID != 2501  && App.user.worldID != 2813) {
				new SimpleWindow ( {
					label:SimpleWindow.ATTENTION,
					title:Locale.__e('flash:1382952379893'),
					text:Locale.__e('flash:1432300164937')
				}).show();
				return;
			}
			App.ui.bottomPanel.changeCursorPanelState(true);
			var workerName:String = 'workers';
			if (App.user.worldID == Travel.SAN_MANSANO) workerName = 'worker_staratel';
			var content:Array = PurchaseWindow.createContent('Energy', { view:workerName } );
			new PurchaseWindow( {
				width:595,
				itemsOnPage:App.user.worldID == Travel.SAN_MANSANO ? content.length : 3,
				content:content,
				title:App.user.worldID == Travel.SAN_MANSANO ? Locale.__e('flash:1470210237983') : Locale.__e("flash:1382952379828"),
				fontBorderColor:0xd49848,
				shadowColor:0x553c2f,
				shadowSize:4,
				hasDescription:App.user.worldID == Travel.SAN_MANSANO ? false : true,
				description:Locale.__e("flash:1427363516041"),
				popup: true,
				callback:function(sID:int):void {
					var object:* = App.data.storage[sID];
					App.user.stock.add(sID, object);
				}
			}).show();
		}
		
		public function onEnergyEvent(e:MouseEvent = null):void {
			App.ui.bottomPanel.changeCursorPanelState(true);
			new PurchaseWindow( {
				width:595,
				itemsOnPage:3,
				content:PurchaseWindow.createContent("Energy", {view:'energy'}),
				title:Locale.__e("flash:1382952379756"),
				fontBorderColor:0xd49848,
				shadowColor:0x553c2f,
				shadowSize:4,
				description:Locale.__e("flash:1382952379757"),
				popup: true,
				callback:function(sID:int):void {
					var object:* = App.data.storage[sID];
					App.user.stock.add(sID, object);
				}
			}).show();
			
			return;
		}
		
		public function onExpEvent(e:MouseEvent = null):void {
			App.ui.bottomPanel.changeCursorPanelState(true);
			new SimpleWindow( {
				title:		'Alert',
				text:		'Under construction'
			}).show();
		}
		// Guest panel
		
		
		public function showHelp(message:String, width:int = 250):void
		{
			if (help != null && contains(help)) {
				help.hideGlowing();
				removeChild(help);
			}
			help = null;
			
			var text:TextField = Window.drawText(message,
			{
				color:0xfbf6d6,
				borderColor:0x5c4126,
				fontSize:38
			});
			
			text.height 	= text.textHeight;
			text.width 		= text.textWidth + 5;
			//text.x = paddingX;
			//text.y = paddingY;
			
			if (width == 0) {
				if (text.width > 250) {
					width = text.width + 40;
				}else {
					width = 250;
				}
			}
			
			help = new LayerX();
			var backing:Bitmap = Window.backing(width, 60, 10, "searchPanelBackingPiece");
			help.addChild(backing);
			backing.alpha = 0.9;
			
			text.x = (backing.width - text.width) / 2;
			text.y = (backing.height - text.height) / 2;
			
			help.addChild(text);
			addChild(help);
			
			help.x = (App.self.stage.stageWidth - help.width) / 2;
			help.y = 110;
			help.alpha = 0;
			if (help) {
				TweenLite.to(help, 0.7, { alpha:1, onComplete:function():void { if(help) help.startGlowing(); }} );
			}
			
			/*timer.addEventListener(TimerEvent.TIMER, hideHelp);
			timer.start();*/
		}
		
		public function hideHelp(e:TimerEvent = null):void
		{
			timer.reset();
			timer.removeEventListener(TimerEvent.TIMER, hideHelp);
			
			if (help != null)
			{
				TweenLite.to(help, 1, { alpha:0, onComplete:function():void
				{
					if (help != null && contains(help)) {
						help.hideGlowing();
						removeChild(help);
					}
					help = null;
				}});
			}
		}
		private var confirmCallback:Function;
		public var confirmBttn:Button;
		public function showConfirm(callback:Function = null, hideOnClick:Boolean = true):void {
			confirmCallback = callback;
			this.hideOnClick = hideOnClick;
			
			if (confirmBttn) return;
			
			confirmBttn = new Button( {
				width: 		160,
				height:		44,
				caption:	Locale.__e('flash:1382952379978')
			});
			
			confirmBttn.x = (App.self.stage.stageWidth - confirmBttn.width) / 2;
			if ( cancelBttn )
			{
				cancelBttn.x += cancelBttn.width /2 + 10;
				confirmBttn.x -= confirmBttn.width/2 - 10;
			}
			confirmBttn.y = 176;
			confirmBttn.addEventListener(MouseEvent.CLICK, onConfirm);
			addChild(confirmBttn);
		}
		private function onConfirm(e:MouseEvent):void {
			if (confirmCallback != null) confirmCallback();
			if (hideOnClick) hideCancel();
		}
		
		private var cancelCallback:Function;
		private var hideOnClick:Boolean = true;
		public var cancelBttn:Button;
		public function showCancel(callback:Function = null, hideOnClick:Boolean = true):void {
			cancelCallback = callback;
			this.hideOnClick = hideOnClick;
			
			if (cancelBttn) return;
			
			cancelBttn = new Button( {
				width: 		160,
				height:		44,
				caption:	Locale.__e('flash:1396963190624')
			});
			cancelBttn.x = (App.self.stage.stageWidth - cancelBttn.width) / 2;
			cancelBttn.y = 176;
			cancelBttn.addEventListener(MouseEvent.CLICK, onCancel);
			addChild(cancelBttn);
		}
		public function hideCancel():void {
			if (cancelBttn) {
				if (contains(cancelBttn)) removeChild(cancelBttn);
				cancelBttn.removeEventListener(MouseEvent.CLICK, onCancel);
				cancelBttn.dispose();
				cancelBttn = null;
			}
			if (confirmBttn)
			{
				if (contains(confirmBttn)) removeChild(confirmBttn);
				confirmBttn.removeEventListener(MouseEvent.CLICK, onConfirm);
				confirmBttn.dispose();
				confirmBttn = null;
			}
		}
		private function onCancel(e:MouseEvent):void {
			if (cancelCallback != null) cancelCallback();
			if (hideOnClick) hideCancel();
		}
	}
}


import buttons.Button;
import buttons.ImageButton;
import core.AvaLoad;
import core.Numbers;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.GradientType;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.filters.GlowFilter;
import flash.geom.Matrix;
import flash.text.TextField;
import flash.utils.clearTimeout;
import flash.utils.setTimeout;
import wins.Window;
import ui.UserInterface;

internal class Panel extends LayerX {
	
	public static const COINS:String = 'coins';
	public static const FANTS:String = 'fants';
	public static const ENERGY:String = 'energy';
	public static const EXP:String = 'exp';
	public static const WORKERS:String = 'workers';
	
	private var backing:Bitmap;
	private var icon:Bitmap;
	public var text:TextField;
	public var bttn:ImageButton;
	public var slider:Sprite;
	
	public var type:String;
	
	public var coinsVars:Array = [Stock.COINS, Stock.GOLDEN_NUGGET, Stock.ACTION, Stock.SILVER_COIN, Stock.VAUCHER];
	private var coinsViews:Array = ['coinsIcon', 'goldenNuggetIco', 'shareIco', 'silverCoin', 'voucherIco'];
	
	public var params:Object = {
		width:		160,
		height:		38,
		backing:	'panelMoney',
		iconView:	'coinsIcon',
		bttnView:	'addBttnYellow',
		fontSize:	22,
		fontColor:	0xfedb38,
		fontBorderColor:	0x80470b
	}
	
	
	public function Panel(type:String = 'coins', params:Object = null) {
		if (params) {
			for (var prop:* in params)
				this.params[prop] = params[prop];
		}
		
		this.type = type;
		
		init();
		draw();
	}
	
	public function init():void {
		switch(type) {
			case FANTS:
				params.backing = 'panelBucks';
				params.iconView = 'fantsIcon';
				params.bttnView = 'addBttnGreen';
				params.width = 140;
				params.fontColor = 0xd0ff74;
				params.fontBorderColor = 0x26600a;
				break;
			case ENERGY:
				params.backing = 'panelEnergy';
				params.iconView = 'energyIcon';
				params.bttnView = 'addBttnBlue';
				params.width = 170;
				params.fontSize = 20;
				params.fontColor = 0xebffff;
				params.fontBorderColor = 0x335bc7;
				break;
			case EXP:
				params.backing = 'panelExp';
				params.iconView = 'expIcon';
				params.bttnView = '';
				params.width = 210;
				params.fontSize = 20;
				params.fontColor = 0xfff2c8;
				params.fontBorderColor = 0x97480f;
				break;
			case WORKERS:
				params.backing = 'panelWorkers';
				params.iconView = 'iconWorker';
				params.bttnView = 'addBttnWhite';
				params.width = 140;
				params.fontColor = 0xfff2c6;
				params.fontBorderColor = 0x774b23;
				break;
		}
	}
	
	public function draw():void {
		var s:Shape = new Shape();
		s.graphics.beginFill(0xFF0000, 0.3);
		s.graphics.drawRect(0, 0, params.width, params.height);
		s.graphics.endFill();
		//addChild(s);
		
		
		backing = new Bitmap(UserInterface.textures[params.backing]);
		backing.x = (params.width - backing.width) / 2;
		addChild(backing);
		if (type == EXP || type == ENERGY) {
			slider = new Sprite();
			addChild(slider);
			updateSlider();
		}
		
		text = Window.drawText('', {
			width:			backing.width, //params.width,
			textAlign:		'center',
			color:			params.fontColor,
			borderColor:	params.fontBorderColor,
			fontSize:		params.fontSize,
			shadowSize:		1
		});
		text.x = backing.x;
		text.y = backing.y + (backing.height - text.height) / 2 + 2;
		addChild(text);
		
		if (UserInterface.textures.hasOwnProperty(params.iconView)) {
			icon = new Bitmap(UserInterface.textures[params.iconView]);
			addChild(icon);
		} else if (Window.textures.hasOwnProperty(params.iconView)) {
			icon = new Bitmap(Window.textures[params.iconView]);
			addChild(icon);
		}
		
		if (params.hasOwnProperty('itemTip')) {
			tip = function():Object {
				return params.itemTip;
			}
		}
		
		if (UserInterface.textures.hasOwnProperty(params.bttnView)) {
			bttn = new ImageButton(UserInterface.textures[params.bttnView]);
			bttn.x = backing.x + backing.width - 15;
			bttn.y = backing.y + (backing.height - bttn.height) / 2;
			//bttn.addEventListener(MouseEvent.CLICK, onClick);
			this.addEventListener(MouseEvent.CLICK, onClick);
			addChild(bttn);
			
			if (params.hasOwnProperty('tip')) {
				bttn.tip = function():Object {
					return params.tip;
				}
			}
		}
		
		if (type == COINS) {
			var coinsSprite:Sprite = new Sprite();
			addChild(coinsSprite);
			
			coinsSprite.addChild(backing);
			coinsSprite.addChild(icon);
			coinsSprite.addChild(text);
			this.removeEventListener(MouseEvent.CLICK, onClick);
			
			addChild(bttn);
			bttn.addEventListener(MouseEvent.CLICK, onClick);
			coinsSprite.addEventListener(MouseEvent.CLICK, onMoneyEvent);
		}
	}
	
	public var position:int = 0;
	private var timeout:int = 0;
	public function onMoneyEvent(e:MouseEvent = null):void {
		var index:int = coinsVars.length;
		while (true) {
			position ++;
			if (position >= coinsVars.length) {
				position = 0;
			}
			
			if (index <= 0 || App.user.stock.data[coinsVars[position]])
				break;
			
			index--;
		}
		
		showMoneyType(position);
	}
	public function showMoneyType(pos:int = 0):void {
		if (timeout) {
			clearTimeout(timeout);
			timeout = 0;
		}
		if (App.user.worldID == Travel.SAN_MANSANO) {
			if (pos != 4) {
				timeout = setTimeout(showMoneyType, 10000, 4);
			}else {
				position = 4;
			}
		} else {
			if (pos != 0) {
				timeout = setTimeout(showMoneyType, 10000, 0);
			}else {
				position = 0;
			}
		}
		
		if (UserInterface.textures.hasOwnProperty(coinsViews[pos]))
			icon.bitmapData = UserInterface.textures[coinsViews[pos]];
		else if (Window.textures.hasOwnProperty(coinsViews[pos]))
			icon.bitmapData = Window.textures[coinsViews[pos]];
		icon.smoothing = true;
		setText(Numbers.moneyFormat(App.user.stock.count(coinsVars[pos])));
	}
	
	public function onClick(e:MouseEvent):void {
		if (!App.user.quests.tutorial && params.onClick && (params.onClick is Function))
			params.onClick();
	}
	
	public function setText(value:*):void {
		text.text = String(value);
	}
	public function updateIcon():void {
		if (type == WORKERS) {
			var iconName:String = 'iconWorker';
			if (App.user.worldID == Travel.SAN_MANSANO) {
				iconName = 'workerIco';
			}
			
			if (icon) {
				removeChild(icon);
			}
			
			if (UserInterface.textures.hasOwnProperty(iconName)) {
				icon = new Bitmap(UserInterface.textures[iconName]);
				addChild(icon);
			} else if (Window.textures.hasOwnProperty(iconName)) {
				icon = new Bitmap(Window.textures[iconName]);
				addChild(icon);
			}
		}
	}
	public function updateSlider():void {
		if (type == ENERGY) {
			UserInterface.slider(slider, App.user.stock.data[Stock.ENERGY], App.user.stock.maxEnergyOnLevel, "progressBarEnergy");
			slider.x = backing.x + 21;
			slider.y = 7;
		}else if (type == EXP) {
			var maxExp:int = (App.data.levels[App.user.level + 1]) ? App.data.levels[App.user.level + 1].experience : 999999999999;
			var minExp:int = (App.data.levels[App.user.level]) ? App.data.levels[App.user.level].experience : App.user.stock.data[Stock.EXP];
			
			UserInterface.slider(slider, App.user.stock.data[Stock.EXP] - minExp, maxExp - minExp, "progressBarExp");
			slider.x = backing.x + 26;
			slider.y = 7;
		}
		if (slider.width > params.width) {
			var sc:int = 1;
			do {
				slider.scaleX = sc;
				sc -= 0.1;
			} while (slider.width > backing.width - 10)
		}
	}
}

internal class GuestPanel extends LayerX {
	
	public var image:Bitmap;
	public var imageBack:Shape;
	private var backing:Bitmap;
	private var textLabel:TextField;
	private var leftBttn:ImageButton;
	private var rightBttn:ImageButton;
	private var guestButton:Button;
	private var extraItem:ExtraItem;
	
	public var uid:*;
	private var friends:Array;
	private var friend:Object;
	
	public function GuestPanel() {
		friends = App.ui.bottomPanel.friendsPanel.friends;
		
		draw();
		
		App.self.addEventListener(AppEvent.ON_OWNER_COMPLETE, onOwnerComplete);
	}
	
	private function draw():void {
		
		backing = Window.backing(200, 100, 50, 'homePanelBacking');
		backing.x = 32;
		addChild(backing);
		
		imageBack = new Shape();
		imageBack.graphics.beginFill(0x424d59, 1);
		imageBack.graphics.drawRoundRect(0, 0, 54, 54, 4, 4);
		imageBack.graphics.endFill();
		imageBack.x = backing.x + 18;
		imageBack.y = backing.y + (backing.height - imageBack.height) / 2;
		addChild(imageBack);
		
		image = new Bitmap();
		addChild(image);
		image.filters = [new GlowFilter(0x424d59, 1, 2, 2, 16)];
		
		textLabel = Window.drawText(Locale.__e('flash:1396867993836', ['']), {
			width:		115,
			color:		0xFFFFFF,
			borderColor:0x4a4639,
			autoSize:	'center',
			textAlign:	'center',
			multiline:	true,
			wrap:		true
		});
		textLabel.x = backing.x + 75;
		textLabel.y = backing.y + (backing.height - textLabel.height) / 2 + 2;
		addChild(textLabel);
		
		leftBttn = new ImageButton(Window.textures.arrow, { scaleX: -0.6, scaleY:0.6 } );
		leftBttn.y = backing.y + (backing.height - leftBttn.height) / 2;
		leftBttn.addEventListener(MouseEvent.CLICK, onPrev);
		leftBttn.tip = prevTip;
		addChild(leftBttn);
		
		rightBttn = new ImageButton(Window.textures.arrow, { scaleX:0.6, scaleY:0.6 } );
		rightBttn.x = backing.x + backing.width - rightBttn.width + 50;
		rightBttn.y = backing.y + (backing.height - rightBttn.height) / 2;
		rightBttn.addEventListener(MouseEvent.CLICK, onNext);
		rightBttn.tip = nextTip;
		addChild(rightBttn);
	}
	private function updateBttnState():void {
		for (var i:int = 0; i < friends.length; i++) {
			if (String(friends[i].uid) == uid) {
				if (i > 0) {
					leftBttn.state = Button.NORMAL;
					leftBttn.alpha = 1;
				}else {
					leftBttn.state = Button.DISABLED;
					leftBttn.alpha = 0.5;
				}
				if (i < friends.length - 1) {
					rightBttn.state = Button.NORMAL;
					rightBttn.alpha = 1;
				}else {
					rightBttn.state = Button.DISABLED;
					rightBttn.alpha = 0.5;
				}
			}
		}
	}
	private function getFriendIndex(friendID:*):int {
		for (var i:int = 0; i < friends.length; i++) {
			if (String(friends[i].uid) == String(friendID)) {
				return i;
			}
		}
		
		return -1;
	}
	
	private function onPrev(e:MouseEvent):void {
		if (leftBttn.mode == Button.DISABLED) return;
		leftBttn.state = Button.DISABLED;
		rightBttn.state = Button.DISABLED;
		
		var find:Boolean = false;
		for (var i:int = 0; i < friends.length; i++) {
			if (friends[i].uid == uid) {
				find = true;
				break;
			}
		}
		
		if (find)
			load(friends[i - 1]);
	}
	private function onNext(e:MouseEvent):void {
		if (rightBttn.mode == Button.DISABLED) return;
		leftBttn.state = Button.DISABLED;
		rightBttn.state = Button.DISABLED;
		
		var find:Boolean = false;
		for (var i:int = 0; i < friends.length; i++) {
			if (friends[i].uid == uid) {
				find = true;
				break;
			}
		}
		
		if (find)
			load(friends[i + 1]);
	}
	
	private function prevTip():Object {
		var index:int = getFriendIndex(uid);
		if (index > 0) {
			var sprite:Sprite = getTipForFriend(friends[index - 1]);
			return { sprite:sprite };
		}
		
		return null;
	}
	private function nextTip():Object {
		var index:int = getFriendIndex(uid);
		if (index >= 0 && friends.length - 2 >= index) {
			var sprite:Sprite = getTipForFriend(friends[index + 1]);
			return { sprite:sprite };
		}
		
		return null;
	}
	private function getTipForFriend(friend:Object):Sprite {
		var sprite:Sprite = new Sprite();
		
		var matrix:Matrix = new Matrix();
		matrix.createGradientBox(60, 60, (Math.PI / 180) * 90, 0, 0);
		
		var shape:Shape = new Shape();
		shape.graphics.beginGradientFill(GradientType.LINEAR, [0xeed4a6, 0xeed4a6], [1, 1], [0, 255], matrix);
		shape.graphics.drawRoundRect(0, 0, 60, 60, 10);
		shape.graphics.endFill();
		shape.filters = [new GlowFilter(0x4c4725, 1, 4, 4, 3, 1)];
		shape.alpha = 0.8;
		sprite.addChild(shape);
		
		var image:Bitmap = new Bitmap(new BitmapData(50, 50, true, 0));
		image.x = 5;
		image.y = 5;
		sprite.addChild(image);
		new AvaLoad(friend['photo'], function(data:Bitmap):void {
			image.bitmapData = data.bitmapData;
		});
		
		var text:TextField = Window.drawText(friend['first_name'], App.self.userNameSettings( {
			width:			66,
			fontSize:		16,
			color:			0xffffff,
			borderColor:	0x5d411e,
			autoSize:		"center",
			textAlign:		"center",
			multiline:		true,
			wrap:			true,
			shadowSize:		1.5
		}));
		text.x = image.x + (image.width - text.width) / 2;
		text.y = -8;
		sprite.addChild(text);
		
		var star:Bitmap = new Bitmap(UserInterface.textures.friendsLevel);
		star.smoothing = true;
		star.x = shape.width - star.width + 4;
		star.y = shape.height - star.height + 2;
		sprite.addChild(star);
		
		var level:TextField = Window.drawText(String(friend['level']), {
			fontSize:		17,
			color:			0x643113,
			borderSize:		0,
			autoSize:		'left',
			multiline:		true,
			wrap:			true
		});
		level.x = star.x + star.width / 2 - level.width / 2 - 1;
		level.y = star.y + 2;
		sprite.addChild(level);
		
		return sprite;
	}
	
	public function load(friend:Object = null):void {
		if (!friend || !App.user.friends.data.hasOwnProperty(friend.uid)) return;
		
		if (friend && App.user.friends.data.hasOwnProperty(friend.uid)) {
			Travel.friend = friend;
			Travel.onVisitEvent(User.HOME_WORLD);
		}
	}
	
	private function onOwnerComplete(e:AppEvent):void {
		uid = App.owner.id;
		friend = App.user.friends.data[uid];
		
		if (guestButton) {
			guestButton.removeEventListener(MouseEvent.CLICK, guestAction);
			if (guestButton.parent) guestButton.parent.removeChild(guestButton);
			guestButton = null;
		}
		if (extraItem) {
			if (extraItem.parent) extraItem.parent.removeChild(extraItem);
			extraItem = null;
		}
		
		if (App.isSocial('YB','MX','SP','HV','YN','AI')) {
			removeChild(backing);
			backing = null;
			backing = Window.backing(200, 100, 50, 'homePanelBacking');
			backing.x = 32;
			addChildAt(backing, 0);
		}else {			
			if (App.user.friends.data[uid].lastvisit + App.data.options['LastVisitDays'] < App.time && uid != 1) {
				removeChild(backing);
				backing = null;
				backing = Window.backing(200, 150, 50, 'homePanelBacking');
				backing.x = 32;
				addChildAt(backing, 0);
				
				var guestButtonSettings:Object = {
					caption:Locale.__e('flash:1449486338094'),
					fontSize:23,
					width:140,
					height:43,
					hasDotes:false,
					textAlign:'center'
				};
				if ((App.user.friends.data[uid].alert + App.data.options['alerttime']) > App.time) {
					guestButtonSettings.caption = Locale.__e('flash:1449654596563');
				}
				
				guestButton = new Button(guestButtonSettings);  
				guestButton.x = backing.x + (backing.width - guestButton.width) / 2;
				guestButton.y = 90;
				addChild(guestButton);
				
				if ((App.user.friends.data[uid].alert + App.data.options['alerttime']) > App.time) {
					guestButton.state = Button.DISABLED;
				} else {
					guestButton.addEventListener(MouseEvent.CLICK, guestAction);
					
					extraItem = new ExtraItem();
					extraItem.x = guestButton.x + guestButton.width + 5;
					extraItem.y = guestButton.y + (guestButton.height - extraItem.height) / 2 + 10;
					addChild(extraItem);
				}
			} else {
				if (guestButton) {
					guestButton.removeEventListener(MouseEvent.CLICK, guestAction);
					if (guestButton.parent) guestButton.parent.removeChild(guestButton);
					guestButton = null;
				}
				if (extraItem) {
					if (extraItem.parent) extraItem.parent.removeChild(extraItem);
					extraItem = null;
				}
				
				removeChild(backing);
				backing = null;
				backing = Window.backing(200, 100, 50, 'homePanelBacking');
				backing.x = 32;
				addChildAt(backing, 0);
			}
		}
		
		var first_Name:String = '';
		if (friend.first_name && friend.first_name.length > 0)
			first_Name = friend.first_name;
		else if (friend.aka && friend.aka.length > 0) {
			first_Name = friend.aka;
		}
		
		if (first_Name.indexOf(' ') > 0) first_Name = first_Name.substring(0, first_Name.indexOf(' '));
		
		textLabel.text = Locale.__e('flash:1396867993836', [first_Name]);
		textLabel.x = backing.x + 75;
		textLabel.y = 30;//backing.y + (backing.height - textLabel.height) / 2 + 2;
		
		new AvaLoad(friend['photo'], onLoad);
		
		updateBttnState();
	}
	private function guestAction(e:MouseEvent):void {
		guestButton.state = Button.DISABLED;  // need to make button like disable
		App.self.sendPostWake();
	}
	public function hideAwake():void {
		if (friend) {
			if (guestButton) {
				guestButton.removeEventListener(MouseEvent.CLICK, guestAction);
				if (guestButton.parent) guestButton.parent.removeChild(guestButton);
				guestButton = null;
			}
			if (extraItem) {
				if (extraItem.parent) extraItem.parent.removeChild(extraItem);
				extraItem = null;
			}
			
			if (App.isSocial('FB', 'NK', 'HV', 'YB', 'MX', 'YN', 'SP', 'AI')) return;
			
			var guestButtonSettings:Object = {
				caption:Locale.__e('flash:1449654596563'),
				fontSize:23,
				width:140,
				height:43,
				hasDotes:false,
				textAlign:'center'
			};
			
			guestButton = new Button(guestButtonSettings);  
			guestButton.x = backing.x + (backing.width - guestButton.width) / 2;
			guestButton.y = 90;
			addChild(guestButton);
			guestButton.state = Button.DISABLED;
		}
	}
	private function onLoad(data:Bitmap):void {
		image.bitmapData = data.bitmapData;
		image.smoothing = true;
		image.x = imageBack.x + (imageBack.width - image.width) / 2;
		image.y = imageBack.y + (imageBack.height - image.height) / 2;
	}
	
}

import flash.display.Bitmap;
import flash.display.Sprite;
import flash.text.TextField;
import wins.Window;
import wins.RewardList;

internal class ExtraItem extends Sprite {
	
	public var extra:Object;
	public var bg:Bitmap;
	
	public function ExtraItem() {
		if (!App.data.options.hasOwnProperty('friendalertBonus') || App.user.quests.tutorial) return;
		
		extra = JSON.parse(App.data.options.friendalertBonus);
		
		bg = Window.backing(164, 85, 38, "shareBonusBacking");
		addChild(bg);
		drawTitle();
		drawReward();
	}
	
	private function drawTitle():void {
		var title:TextField = Window.drawText(Locale.__e("flash:1449655508990"), {
			fontSize	:17,
			color		:0x673a1f,
			borderColor	:0xffffff,
			textAlign   :'center',
			multiline   :true,
			wrap        :true
		});
		title.width = bg.width - 10;
		title.x = 5
		title.y = 6;
		addChild(title);
	}
	
	private function drawReward():void {
		var reward:RewardList = new RewardList(extra, false, 0, '', 1, 30, 16, 32, "x", 0.55, -8, 7, false, true);
		addChild(reward);
		reward.x = -10;
		reward.y = bg.height - reward.height - 10;
	}
	
	public function get newsBonus():Object {
		return extra;
	}
}