package 
{
	import api.ExternalApi;
	import core.Post;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	import units.Exchange;
	import units.Field;
	import units.Techno;
	import units.Trade;
	import units.Tribute;
	import units.Ttechno;
	import units.Unit;
	import wins.actions.BanksWindow;
	import wins.elements.BankMenu;
	import wins.LevelBragWindow;
	import wins.LevelUpWindow;
	//import wins.LuckyBagWindow;
	import wins.PurchaseWindow;
	import wins.PuzzleMapWindow;
	import wins.ShopWindow;
	import wins.SimpleWindow;
	import wins.ThanksgivingEventWindow;
	import wins.Window;
	import wins.WindowEvent;

	public class Stock 
	{
		public static const EXP:uint = 2;
		public static const COINS:uint = 3;
		public static const FANT:uint = 4;
		public static const FRANKS:uint = 708;
		public static const ACTION:uint = 798;
		public static const HELLOWEEN_ICON:uint = 1006;
		public static const PATRICK_ICON:uint = 1675;
		public static const SILVER_COIN:uint = 1382;
		public static const SMILE_COIN:uint = 1777;
		public static const WHITE_GOLD:uint = 1460;
		public static const FANTASY:uint = 5;
		public static const ENERGY:uint = 5;
		public static const GUESTFANTASY:uint = 6;//Покупная энергия
		public static const FOOD:uint = 228;
		public static const COUNTER_GUESTFANTASY:uint = 1287;// Счетчик
		public static const FERTILIZER:uint = 269;
		public static const GOLDEN_NUGGET:uint = 27;
		public static const LIGHT_RESOURCE:uint = 1226;
		public static const COOKIE:uint = 2487;
		public static const VAUCHER:uint = 2486;
		public static const GOLD_COINS:uint = 2956;
		//public static const GUESTFANTASY:uint = 337;//Покупная энергия
		
		public static const SEA_STONE:uint = 1159;
		
		public static const ENERGY_CAPACITY_BONUS:uint = 343;
		
		public static const TECHNO:uint = 161;		 
		public static const PICK:uint = 15;			// Кирка
		public static const SEED:uint = 0;			// Зерно
		
		public var data:Object = null;
		//public var tempChests:Object = null;
		
		public var diffTime:int = 0;
		
		public static var energyRestoreTime:int = 0;
		
		/**
		 * Инициализация склада пользователя
		 * @param	data	объект склада
		 */
		public function Stock(data:Object)
		{
			var sID:String;
			for (sID in data) {
				//if (sID == 'obj' )
				//{
					//tempChests = data[sID];
				//}
				if (App.data.storage[sID] == null)
				{
					delete data[sID];
					continue;
				}
				data[sID] = data[sID];
			}
			this.data = data;
			
			energyRestoreTime = App.data.options['EnergyRestoreTime'];
			//maxEnergyOnLevel = App.data.levels[App.user.level].energy;
			//maxEnergyOnLevel = bonusEnergyCapacity;
		}
		
		public var socialEnergyBonus:uint = energyRestoreTime;
		public function checkEnergy():void {
			diffTime++;
			
			if (diffTime >= energyRestoreTime)
			{
				var energies:int = int(diffTime / energyRestoreTime);
				
				diffTime = diffTime % energyRestoreTime;
				checkSystem();
			}
			/*if (!data) return;
			if (data[FANTASY] >= maxEnergyOnLevel) {
				App.user.energy = 0;
				return;
			}else if (App.user.energy <= 0) {
				App.user.energy = App.time;
				checkSystem(true);
			}
			
			if (App.user.energy + energyRestoreTime <= App.time) {
				var energies:int = Math.floor((App.time - App.user.energy) / energyRestoreTime);
				App.user.energy = App.time + (App.time - App.user.energy) % energyRestoreTime;
				
				if (data[FANTASY] + energies >= maxEnergyOnLevel) {
					if (data[FANTASY] < maxEnergyOnLevel) data[FANTASY] = maxEnergyOnLevel;
					App.user.energy = 0;
				}
				
				checkSystem();
			}*/
		}
		
		public static var _value:int = 0;
		public static var _limit:int = 0;
		public static function set limit(value:int):void {
			if (value < _limit) 
				return;
			_limit = value;
		}
		public static function get limit():int {
			//if (User.inExpedition) {
				//return 999999999;
			//}
			return 999999999;
			return _limit + _overLimit;
		}
		
		public function get maxEnergyOnLevel():int {
			return App.data.levels[App.user.level].energy /*+ socialEnergyBonus*/ + ((data[Stock.ENERGY_CAPACITY_BONUS]) ? data[Stock.ENERGY_CAPACITY_BONUS] : 0);
		}
		
		/**
		 * Обновление склада
		 * @param	data	объект склада
		 */	
		public function bulkPost(needItems:Object, callBack:Function = null):void
		{
			Post.send({
				ctr:'stock',
				act:'bulk',
				uID:App.user.id,
				items:JSON.stringify(needItems)
			}, function(error:int, data:Object, params:Object):void {
				if (error)
				{
					Errors.show(error, data);
					return;
				}
				if (callBack != null)
					callBack();
			});
		}
		
		private function reinit(data:Object):void
		{
			this.data = data;
			App.ui.upPanel.update();
		}
		
		public function put(sID:uint, count:uint):void
		{
			data[sID] = count;
			App.ui.upPanel.update();
		}
		
		/**
		 * Возвращает кол-во текущего объекта на складе
		 * @param	sID	идентификатор объекта
		 * @return	uint	кол-во текущего объекта
		 */
		public function count(sID:uint):uint
		{
			if (sID == 752 || App.data.storage[sID].type == 'Building' || App.data.storage[sID].type == 'Tribute') {
				var count:int;
				if (!(data[sID] is int)) {
					for (var level:String in data[sID]) {
						count += data[sID][level]; 
					}
				}
				if (!count) count = data[sID];
				return data[sID] == null ? 0 : count;
			}
			return data[sID] == null ? 0 : data[sID]; 
		}
		
		/**
		 * Возвращает кол-во все виды варенья
		 * @return	Object	list:{sID:count}, totalCount
		 */
		public function jam(view:String = 'jam'):Object
		{
			var result:Object = {
				totalCount:0,
				list:{}
				}
			for (var sID:* in data)
			{
				if (App.data.storage[sID] == undefined) continue;
				
				var count:uint = count(sID)
				if (App.data.storage[sID].type == "Jam"){
					if (App.data.storage[sID].view == view) {
						if(count > 0){
							result.totalCount += count;
							result.list[sID] = count;
						}
					}
				}
			}
			
			return result;
		}
		
		/**
		 * Проверка кол-ва объекта на складе
		 * @param	sID	идентификатор объекта
		 * @param	count	требуемое кол-во
		 * @return	true, если есть требуемое кол-во, false, если нет
		 */
		public function check(sID:uint, count:uint = 1, dontShowWindows:Boolean = false, searchEnabled:Boolean = false):Boolean
		{
			if (sID == Ttechno.TECHNO)
				return true;
			
			if ((sID == 752 || App.data.storage[sID].type == 'Building' || App.data.storage[sID].type == 'Tribute') && data[sID] != null) {
				var cnt:int;
				for (var level:String in App.user.stock.data[sID]) {
					cnt = App.user.stock.data[sID][level]; 
					if (cnt > 0) break;
				}
				if (!cnt) cnt = App.user.stock.data[sID];
				if (cnt >= count) {
					return true;
				}
			}
			if (data[sID] != null && data[sID] >= count) {
				return true;
			}
			
			if (!dontShowWindows) {
				if (sID == COINS || sID == FANT)
				{
					if (sID == COINS){
						BankMenu._currBtn = BankMenu.COINS;
						BanksWindow.history = {section:'Coins',page:0};
					}else {
						BankMenu._currBtn = BankMenu.REALS;
						BanksWindow.history = {section:'Reals',page:0};
					}
					var text:String;
					switch(App.social) {
						case "PL":
							if (sID == COINS) {
								text = Locale.__e("flash:1382952379746");
							}else {
								text = Locale.__e("flash:1382952379749");
							}
							new SimpleWindow( {
								label:SimpleWindow.ATTENTION,
								text:text,
								buttonText:Locale.__e('flash:1382952379751'),
								ok:function():void {
									if (sID == COINS) {
										ExternalApi.apiBalanceEvent('coins');
									}else{
										ExternalApi.apiBalanceEvent('reals');
									}
								}
							}).show();
							break;
						case 'YB':
						case 'MX':
							Window.closeAll();
							text = Locale.__e("flash:1382952379749");
							new SimpleWindow( {
								label:SimpleWindow.ATTENTION,
								text:text,
								forcedClosing:true,
								buttonText:Locale.__e('flash:1382952379751'),
								confirm:function():void {
									new BanksWindow().show();
								}
							}).show();
							break;
							
						default:
							App.user.onStopEvent();
							App.ui.bottomPanel.cancelActions();
							if (!dontShowWindows) {
								if (!App.user.quests.tutorial)
									new BanksWindow().show();
							}
							break;
					}
				}else if(sID == FANTASY) {
					App.user.onStopEvent();
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
				}else if(sID == GUESTFANTASY){
					new PurchaseWindow( {
						width:716,
						itemsOnPage:3,
						content:PurchaseWindow.createContent("Energy", {view:'GuestEnergyGolden'}),
						title:Locale.__e("flash:1396252152417"),
						popup:true,
						description:Locale.__e("flash:1382952379757"),
						noDesc:false
					}).show();
					App.user.onStopEvent();
				}else if (sID == ACTION) {
						new PurchaseWindow( {
							width:620,
							itemsOnPage:2,
							content:PurchaseWindow.createContent('Energy', { view:'share' } ),
							title:App.data.storage[ACTION].title,
							fontBorderColor:0xd49848,
							shadowColor:0x553c2f,
							shadowSize:4,
							hasDescription:false,
							description:App.data.storage[ACTION].description,
							popup: true,
							closeAfterBuy:false
						}).show();
				}else {
					var content:Array = PurchaseWindow.createContent('Energy', { view:App.data.storage[sID].view } );
					if (content.length > 0 ) {
						new PurchaseWindow( {
							width:620,
							itemsOnPage:content.length,
							content:content,
							title:App.data.storage[sID].title,
							fontBorderColor:0xd49848,
							shadowColor:0x553c2f,
							shadowSize:4,
							hasDescription:false,
							description:App.data.storage[sID].description,
							popup: true,
							closeAfterBuy:false
						}).show();
					}
					else
					{
						if(searchEnabled)
							Find.find(sID);
					}
				}
			}
			return false;
		}
		
		public function checkAll(items:Object, dontShowWindows:Boolean = false, searchEnabled:Boolean = false):Boolean {
			for(var sID:* in items) {
				if (!check(sID, items[sID], dontShowWindows, searchEnabled)) return false;
			}
			return true;
		}
		
		/**
		 * Добавление объекта на склад в кол-ве count
		 * @param	sID	идентификатор объекта
		 * @param	count	его кол-во
		 */
		public function add(sID:uint, count:*, update:Boolean = true):void
		{
			if (data[sID] == null) data[sID] = 0;
			if ((sID == 752 || App.data.storage[sID].type == 'Building' || App.data.storage[sID].type == 'Tribute') && count != 1) {
				//data[sID] = {};
				var c:int = 0;
				if (data[sID] is int)
					c = data[sID];
				else if (data[sID].hasOwnProperty(count['lvl']))
					c = data[sID][count['lvl']];
				if (data[sID] is int) data[sID] = { };
				data[sID][count['lvl']] = count['cnt'] + c;
			} else {
				//data[sID] += count;
				data[sID] += int(boosted(sID, int(count)));
			}
			
			action(sID, 'add');
			
			var cntBuf:int;
			for (var topID:* in App.data.top) {
				if (App.data.top[topID].expire.s <= App.time && App.data.top[topID].expire.e >= App.time && App.data.storage[App.data.top[topID].target].type == 'Material' && App.data.top[topID].target == sID) {
					if (App.user.top.hasOwnProperty(topID) && App.user.top[topID].hasOwnProperty('count')) {
						cntBuf = App.user.top[topID].count + count;
					} else {
						App.user.top[topID] = { };
						App.user.top[topID]['count'] = 0;
					}
					App.user.top[topID].count = cntBuf;
				}
			}
			
			switch(sID) {
				case Stock.ACTION:
					for each (var top:Object in App.data.top) {
						if (top.unit == 797 && top.expire.s <= App.time && top.expire.e >= App.time) {
							Exchange.rate += count;
							if (App.user.top.hasOwnProperty(App.user.topID) && App.user.top[App.user.topID].hasOwnProperty('count')) {
								cntBuf = App.user.top[App.user.topID].count + count;
							} else {
								App.user.top[App.user.topID] = { };
								App.user.top[App.user.topID]['count'] = 0;
							}
							App.user.top[App.user.topID].count = cntBuf;
						}
					}
					
					break;
				case ThanksgivingEventWindow.MONEY:
					if (/*!App.isSocial('FB', 'NK', 'HV') && */ThanksgivingEventWindow.expireTop > App.time) {
						ThanksgivingEventWindow.rate += count;
						var cnt:int = count;
						if (App.user.top.hasOwnProperty(ThanksgivingEventWindow.topID) && App.user.top[ThanksgivingEventWindow.topID].hasOwnProperty('count')) {
							cnt = App.user.top[ThanksgivingEventWindow.topID].count + count;
						} else {
							App.user.top[ThanksgivingEventWindow.topID] = { };
							App.user.top[ThanksgivingEventWindow.topID]['count'] = 0;
						}
						App.user.top[ThanksgivingEventWindow.topID].count = cnt;
					}
					break;
				case Stock.EXP:
						var currentLevel:int = App.user.level;
						while (App.data.levels[App.user.level + 1] && data[sID] >= App.data.levels[App.user.level + 1].experience) {
							App.user.level++;
							//TODO выдаем тихо бонусы, чтобы не показывать кучу окон
							for (var _sID:* in App.data.levels[App.user.level].bonus)
							{
								App.user.stock.add(_sID, App.data.levels[App.user.level].bonus[_sID]);
							}
						}
						
						if (currentLevel < App.user.level) {
							App.self.dispatchEvent(new AppEvent(AppEvent.ON_LEVEL_UP));
							//TODO показываем окно с ревардами и текущим новым уровнем
							
							var bonus:int = 0;
							if (App.social == 'PL' && App.data.options['PlingaEnergyPlus'] != undefined) {
								bonus = App.data.options['PlingaEnergyPlus'];
							}
							if (App.social == 'FB' && App.data.options['FBEnergyPlus'] != undefined) {
								bonus = App.data.options['FBEnergyPlus'];
							}
							
							Post.addToArchive('level ' + App.user.level);
							var energy:int = App.data.levels[App.user.level].energy + bonus;
							if (data[FANTASY] < energy) {
								data[FANTASY] = energy;
								App.ui.upPanel.update();
							}
							Post.addToArchive(data[FANTASY] + ' > ' + energy);
							
							//делаем push в _6e
							if (App.social == 'FB') {
								ExternalApi.og('reach','level');
							}
							
							var win:LevelUpWindow = new LevelUpWindow( { } );
							win.show();
							win.addEventListener(WindowEvent.ON_AFTER_OPEN, onAfterOpening);
							function onAfterOpening(e:WindowEvent):void
							{
								win.removeEventListener(WindowEvent.ON_AFTER_OPEN, onAfterOpening);
								SoundsManager.instance.playSFX('level_Up');
							}
							
							//for (var i:int = 0; i < App.user.promos.length; i++ ) {
								//App.user.promos[i]['showed'] = true;
							//}
							
							App.user.quests.checkPromo(true);
							App.user.quests.getDaylics();
							App.ui.leftPanel.createDaylicsIcon();
							
							var checkMoneyLevel:Function = function():Boolean {
								//if (App.data.money[App.social] && App.data.money[App.social].enabled == 1 && App.data.money[App.social].date_from < App.time && App.data.money[App.social].date_to > App.time) {
									if (App.data.money[App.social] && App.data.money[App.social].hasOwnProperty('level') && (App.data.money[App.social].level is Array) && App.data.money[App.social].level.indexOf(App.user.level) >= 0)
										return true;
								//}
								
								return false;
							}
							
							if (App.user.money < App.time && checkMoneyLevel()) {
								Post.send( {
									ctr:		'user',
									act:		'money',
									uID:		App.user.id,
									enable:		1
								}, function(error:int, data:Object, params:Object):void {
									if (error)
									{
										Errors.show(error, data);
										return;
									}
									
									App.user.money = App.time + (App.data.money[App.social].duration || 24) * 3600;
									
									if (!App.isSocial('YN')) {
										if (!App.user.quests.tutorial)
											new BanksWindow().show();
									}
									
									App.ui.salesPanel.addBankSaleIcon();
								});	
							}
							
							var arrTrades:Array = Map.findUnits([Trade.TRADE_ID]);
							if (arrTrades.length == 0)
								break;
								
							var trade:Trade = arrTrades[0];
							
							Post.send({
								ctr:'Trade',
								act:'refresh',
								uID:App.user.id,
								wID:App.user.worldID,
								sID:trade.sid,
								id:trade.id
							}, function(error:int, data:Object, params:Object):void {
								if (error)
								{
									Errors.show(error, data);
									return;
								}
								if (data.cells != false) {
									var trade:Trade = arrTrades[0];
									var obj:Object = trade.trades;
									
									trade.trades = data.cells;
									
									for (var num:* in data.cells) {
									}
									
									var count:int = num+1;
									for (var item:* in obj) {
										trade.trades[count] = obj[item];
										count += 1;
									}
								}
								
							});	
						}
						
						//if(App.user.level >= 5){
							//for (var k:int = 0; k < App.user.friends.bragFriends.length; k++ ) {
								//var brFriend:Object = App.user.friends.bragFriends[k];
								//if (brFriend.exp && brFriend.exp < data[sID]) {
									//LevelBragWindow.init(k);
									//break;
								//}
							//}
						//}
					break;
				case Stock.FANTASY:
					App.self.dispatchEvent(new AppEvent(AppEvent.ON_CHANGE_FANTASY));
					break;
				case Stock.GUESTFANTASY:
					App.ui.leftPanel.showGuestEnergy();
					//App.ui.leftPanel.updateGuestReward();
					break;
				default:
					if(App.data.storage[sID].type == 'Vip')
						data[sID] = App.time + App.data.storage[sID].time;
					if (PuzzleMapWindow.checkAmuletPart(sID) && !App.isSocial('YB', 'MX')) {
						new PuzzleMapWindow( {find:sID} ).show();
					}
					if (sID == 1580 && App.user.worldID == 1569) {
						var settings:Object = { sid:1580, fromStock:true };
						var unit:Unit = Unit.add(settings);
						unit.moveable = true;
						unit.stockAction({coords:{x:81, z:139}});
						unit.placing(81, 0, 139);
						unit.moveable = false;
					}
					if (sID == 1624 && App.user.worldID == 1569) {
						var vagons:Array = Map.findUnits([1624]);
						var settingsVagon:Object = { sid:1624, fromStock:true };
						var unitVagon:Unit = Unit.add(settingsVagon);
						unitVagon.moveable = true;
						if (vagons.length == 0) {
							unitVagon.stockAction({coords:{x:81, z:126}});
							unitVagon.placing(81, 0, 126);
						}else {
							unitVagon.stockAction({coords:{x:81, z:113}});
							unitVagon.placing(81, 0, 113);
						}
						unitVagon.moveable = false;
					}
					checkCraft(sID);
					break;
			}
			
			if(update && App.ui.upPanel)
				App.ui.upPanel.update();
			
			if (App.ui.rightPanel) App.ui.rightPanel.update();
			stockChange();
		}
		
		public function addAll(items:Object):void {
			for (var sID:* in items) {
				add(sID, items[sID]);
			}
		}
		
		private function checkCraft(sid:int):void {
			if ([1588,1591].indexOf(sid) != -1) {
				var loko:Array = Map.findUnits([1580]);
				
				if (loko.length != 0) {
					setTimeout(function():void {
						loko[0].upgradeEvent(App.data.storage[1580].devel.obj[loko[0].level + 1]);
					}, 2000);
				}
			}
			if ([1621,1622].indexOf(sid) != -1) {
				var vagon:Array = Map.findUnits([1624]);
				
				if (vagon.length != 0) {
					if (vagon.length == 1) {
						setTimeout(function():void {
							vagon[0].upgradeEvent(App.data.storage[1624].devel.obj[vagon[0].level + 1]);
						}, 2000);
					}else {
						switch (sid) {
							case 1621:
								for each (var vag:Tribute in vagon) {
									if (vag.level == 0) {
										vag.upgradeEvent(App.data.storage[1624].devel.obj[vag.level + 1]);
										return;
									}
								}
								break;
							case 1622:
								for each (var vag1:Tribute in vagon) {
									if (vag1.level == 1) {
										vag1.upgradeEvent(App.data.storage[1624].devel.obj[vag1.level + 1]);
										return;
									}
								}
								break;
						}
					}
				}
			}
		}
		
		/**
		 * Удаление объекта со склада в указанном кол-ве
		 * @param	sID	идентификатор объекта
		 * @param	count	требуемое кол-во
		 * @return	true, если смогли взять, false, если не смогли
		 */
		public function take(sID:uint, count:uint, callback:Function = null):Boolean
		{
			if (check(sID, count))
			{
				action(sID, 'take');
				
				if (sID == Techno.TECHNO || sID == Ttechno.TECHNO)
					return true;
				
				/*if (sID == FANT && App.isSocial('MX', 'YB') && callback != null) {
					new SimpleWindow( {
						cancelText:		Locale.__e('flash:1382952380008'),
						title:			Locale.__e('flash:1448466133780'),
						confirmText:	Locale.__e('flash:1448466285460'),
						dialog:			true,
						popup:			true,
						confirm:		function():void {
							data[sID] -= count;
							App.ui.upPanel.update();
							stockChange();
							callback();
						},
						cancel:			function():void {},
						needCancelAfterClose:	true
					}).show();
					return false;
				} else*/ {
					if ((sID == 752 || App.data.storage[sID].type == 'Building' || App.data.storage[sID].type == 'Tribute') && data[sID] != null && !(App.user.stock.data[sID] is int)) {
						var cnt:int;
						for (var level:String in App.user.stock.data[sID]) {
							cnt = App.user.stock.data[sID][level]; 
							App.user.stock.data[sID][level] = cnt - count;
							break;
						}
					} else {
						data[sID] -= count;
					}
					
					switch(sID) {
						case Stock.FANTASY:
								if (data[sID] + count >= maxEnergyOnLevel && data[sID] < maxEnergyOnLevel) {
									diffTime = 0;
								}
								
								App.self.dispatchEvent(new AppEvent(AppEvent.ON_CHANGE_FANTASY));
							break;
						//case Stock.GUESTFANTASY:
								//App.ui.leftPanel.showGuestEnergy();
							//break;
							
						//	
						case Stock.GUESTFANTASY:
								App.ui.leftPanel.showGuestEnergy();
								if (App.isSocial('DM','VK','FS','ML','OK','FB','HV','NK','YN')) {
									if (App.user.stock.data.hasOwnProperty(COUNTER_GUESTFANTASY) && App.user.stock.data[COUNTER_GUESTFANTASY] <= App.ui.leftPanel.rel[App.ui.leftPanel.rel.length-1].count) {
										add(COUNTER_GUESTFANTASY, count);	
									}
								}
								App.ui.leftPanel.updateGuestReward();
							break;
						//	
							
					}
					
					App.ui.upPanel.update();
					stockChange();
					return true;
				}
			}
			
			return false;
		}
		
		/*public function canTakeFant():Boolean {
			var result:int = -1;
			var show:Boolean = false;
			while (result == -1) {
				if (!show) {
					show = true;
					new SimpleWindow( {
						dialog:			true,
						popup:			true,
						confirm:		function():void {
							result = 1;
						},
						cancel:			function():void {
							result = 0;
						},
						needCancelAfterClose:	true
					}).show();
				}
			}
			return Boolean(result);
		}*/
		
		public function takeAll(items:Object, dontShowWindows:Boolean = false, searchEnabled:Boolean = false):Boolean {
			if (!checkAll(items, dontShowWindows, searchEnabled)) return false;
			
			for (var sID:* in items) {
				if (!take(sID, items[sID])) 
				return false;
			}
			return true;
		}
		
		// Booster / Vip
		// Насколько ускорен получаемый sID
		public function boosted(sID:int, count:int):int {
			for (var s:String in data) {
				if (App.data.storage[s].type == 'Vip' && data[s] > App.time && App.data.storage[s].outs.hasOwnProperty(sID)&&sID!=Stock.FANTASY){
					return Math.round(count * (App.data.storage[s].outs[sID] + 100) / 100);
				}
			}
			
			return count;
		}
		
		/**
		 * Покупка объекта
		 * @param	sID	идентификатор объекта
		 * @param	count	требуемое кол-во
		 */
		public function buy(sID:uint, count:uint, callback:Function = null):void {
			
			var object:Object = App.data.storage[sID];
			var params:Object = { };
			var price:Object = {};
			
			params[sID] = this.count(sID);
			
			for (var _sid:* in object.price) {
				price[_sid] = object.price[_sid] * count;
			}
			
			if(takeAll(price)){
				//add(sID, count);
				
				if (callback != null)
				{
					params['callback'] = callback;
					params['price'] = price;
					//params['sID'] = sID;
					//params['count'] = count;
				}
				
				Post.send( {
					ctr:'stock',
					act:'buy',
					uID:App.user.id,
					sID:sID,
					count:count,
					wID:App.user.worldID
				},onBuyEvent, params);
			}
		}
		
		/**
		 * Покупка пакета материалов
		 * @param	sID	идентификатор объекта
		 */
		public function pack(sID:uint, callback:Function = null, fail:Function = null, sett:Object = null):void 
		{
			var object:Object = App.data.storage[sID];
			var price:Object;
			
			var settings:Object = { 
				ctr:'stock',
				act:'pack',
				uID:App.user.id,
				sID:sID,
				wID:App.user.worldID
			};
			
			if (sett) {
				for (var it:* in sett) {
					settings[it] = sett[it];
				}
			}
			
			if (object.hasOwnProperty('price')) price = object.price;
			else {
				var _price:int;
				object['count'] = App.user.stock.count(Stock.FANTASY);
				if (object['count'] > 0) _price = Math.ceil(object['count'] / 30);
				else _price = 0;
				
				settings['price'] = _price;
				settings['count'] = object['count'];
				
				price = { };
				price[Stock.FANT] = _price;
			}
			
			if (!takeAll(price) && fail != null) {
				fail();
				return;
			}
			
			if (!object.hasOwnProperty('out')){
				object['out'] = object.sID;
				if (object.type != 'Firework') {
					object['count'] = 1;
				}
			}
			
			if (settings.ctr == "stock")
				add(object.out, object.count);
			
			Post.send(settings, function(error:*, result:*, params:*):void {
				
				if (error) {
					Errors.show(error, data);
					return;
				}
				
				if (callback != null) {
					callback(object.out, result);
				}
				
				App.self.dispatchEvent(new AppEvent(AppEvent.ON_AFTER_PACK));
			});
				
		}
		
		//Распаковка паков из банка
		public function unpack(sID:uint, callback:Function = null, fail:Function = null, sett:Object = null):void {
			//var object:Object = App.data.storage[sID];
			var settings:Object = { 
				ctr:'stock',
				act:'sets',
				uID:App.user.id,
				sID:sID,
				count:1
			};
			
			Post.send(settings, function(error:*, result:*, params:*):void {
				if (error) {
					Errors.show(error, data);
					return;
				}
				
				if (callback != null) {
					callback(result.bonus);
				}
			});
		}
		
		public function unpackLuckyBag(sID:uint, callback:Function = null, fail:Function = null):void 
		{
			var object:Object = App.data.storage[sID];
			var settings:Object = { 
				ctr:'stock',
				act:'luckybag',
				uID:App.user.id,
				sID:sID
			};
			
			take(sID, 1);
			
			Post.send(settings, function(error:*, result:*, params:*):void {
				
				if (error) {
					Errors.show(error, data);
					return;
				}
				
				if (callback != null) {
					var items:Array = [];
					for (var item:* in result.bonus) {
						items.push({sid:item, count:result.bonus[item]});
					}
					
					//new LuckyBagWindow({ 
						//popup: true,
						//items: items	
					//}).show();
					
					addAll(result.bonus);
					
					callback(result.bonus);	
				}
			});
		}
		
		public function checkCollection(sID:uint):Boolean {
			var collection:Object = App.data.storage[sID];
			var materials:Object = { };
			for each(var mID:* in collection.materials){
				materials[mID] = 1;
			}
			return checkAll(materials);
		}
		
		public function exchange(sID:uint, callback:Function, count:int = 1):Boolean {
			
			var collection:Object = App.data.storage[sID];
			var materials:Object = { };
			for each(var mID:* in collection.materials){
				materials[mID] = count;
			}
			
			if (checkAll(sID)) {
				takeAll(materials);
			}else {
				return false;
			}
			
			Post.send( {
				ctr:'stock',
				act:'exchange',
				uID:App.user.id,
				sID:sID,
				count:count
			},onExchangeEvent, { sID:sID, callback:callback, count:count } );
			
			return true;
		}
		
		private function onExchangeEvent(error:int, data:Object, params:Object):void {
			
			var mID:*;
			var collection:Object = App.data.storage[params.sID];
			
			params.callback();
			
			if (error) {
				Errors.show(error, data);
				for each(mID in collection.materials){
					add(mID, 1);
				}
				return;
			}
			//Выдаем бонусы
			for (mID in collection.reward) {
				add(mID, collection.reward[mID] * params.count);
			}
			
		}
		
		/**
		 * flash:1382952380091 объекта
		 * @param	sID	идентификатор объекта
		 * @param	count	требуемое кол-во
		 */
		public function sell(sID:uint, count:uint, callback:Function = null):void {
			
			var object:Object = App.data.storage[sID];
			var price:Object = { };
			
			if (object.sale) {
				for (var s:String in object.sale) {
					price[s] = object.sale[s] * count;
				}
			}else if (object.cost) {
				price[COINS] = object.cost * count;
			}
			addAll(price);
			take(sID, count);
			
			var params:Object = { }
			params['callback'] = callback;
			Post.send({
				ctr:'stock',
				act:'sell',
				uID:App.user.id,
				sID:sID,
				count:count
			}, onSellEvent, params);
		}
		
		private function onSellEvent(error:int, data:Object, params:Object):void {
			var id:*;
			
			if (error) {
				//синхронflash:1382952379993ируем с сервером
				Errors.show(error, data);
				if (data) reinit(data);
				if (params) params.callback()
				return;
			}
			
			for (id in data) {
				if (typeof(id) == 'number' && this.data[id] != data[id]) {
					this.data[id] = data[id];
				}
			}
			
			if (params && params.callback != null) params.callback();
		}
		
		private function onBuyEvent(error:int, data:Object, params:Object):void {
			var id:*;
			
			if (error) {
				Errors.show(error, data);
				//Возвращаем как было
				for (id in params) {
					this.data[id] = params[id];
				}
				if (data) reinit(data);
				return; 
			}
			
			for (id in data) {
				if (App.data.storage[id].type == 'Vip' && this.data[id] > App.time) {
					App.user.activeBooster();
				}
					
				if (this.data[id] != data[id]) {
					this.data[id] = data[id];
					
				}
			}
			
			if (params.hasOwnProperty('callback')) {
				params.callback(params.price);
			}
			
			//if (params.hasOwnProperty('sID') && params.hasOwnProperty('count')) {
				//add(params.sID, params.count);
			//}
		}
		
		public function checkSystem(energyRestoreReset:Boolean = false):void
		{
			Post.send( {
				ctr:		'stock',
				act:		'system',
				uID:		App.user.id,
				r:			int(energyRestoreReset)
			},
			function(error:*, data:*, params:*):void {
				
				if (error) {
					Errors.show(error, data);
					return;
				}
				
				if (data == null) return;
				
				if(data.hasOwnProperty('gifts')){
					var hasGift:Boolean = false;
					
					for (var gID:String in data.gifts) {
						Gifts.addGift(gID, data.gifts[gID]);
						hasGift = true;
					}
					if (hasGift) {
						App.ui.glowing(App.ui.bottomPanel.bttnMainGifts, 0xFFFF00);
					}
						
					//App.user.gifts.sortOn("time", Array.DESCENDING);
					//if (App.user.gifts.length > App.user.giftsLimit/*App.data.options['GiftsLimit']*/) {
						//App.user.gifts.splice(45, App.user.gifts.length - 45);
						//if(App.ui) App.ui.rightPanel.update();
					//}
				}
				
				if(data.hasOwnProperty(Stock.FANTASY)){
					App.user.stock.data[Stock.FANTASY] = data[Stock.FANTASY];
					Post.addToArchive("server addOnTime  total:"+data[Stock.FANTASY]);
				}
				
				if (data.hasOwnProperty('restore')) {
					App.user.energy = data.restore;
					if (data[FANTASY] < maxEnergyOnLevel) diffTime = App.time - data.restore;
					if (diffTime > energyRestoreTime) diffTime = diffTime % energyRestoreTime;
					/*if (App.user.stock.data[Stock.FANTASY] >= maxEnergyOnLevel) {
						App.user.energy = 0;
					}else{
						App.user.energy = data.restore;
					}*/
				}	
				
				if(App.ui != null && App.ui.upPanel != null){
					App.ui.upPanel.update();
				}
			});
		}	
		
		public function setFantasy(count:uint):void
		{
			Post.addToArchive("take: " + App.user.stock.data[Stock.FANTASY] + " -> " + count);
			if (data[Stock.FANTASY] >= maxEnergyOnLevel && count < maxEnergyOnLevel) diffTime = energyRestoreTime;
			data[Stock.FANTASY] = count;
			if (App.user.energy == 0) {
				App.user.energy = App.time;
			}
			App.ui.upPanel.update();
			if (data[Stock.FANTASY] == 0) {
				App.user.onStopEvent();
				Post.clear();
				
				/*new PurchaseWindow( {
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
				}).show();*/
			}
		}
		
		public function charge(sID:uint, count:uint = 1):void {
			
			if (!take(sID, count)) return;
			if (App.data.storage[sID].type == 'Vip') {
				Post.send( {
					ctr:'stock',
					act:'recharge',
					sID:sID,
					uID:App.user.id,
					count:count
				},function(error:int, data:Object, params:Object):void {
					if (error) {
						Errors.show(error, data);
						App.user.boostCompleteTime = 0;
						return;
					}
					
					if (!App.user.stock.data[sID]) App.user.stock.data[sID] = 0;
					if (data[sID]) App.user.stock.data[sID] = data[sID];
					App.user.activeBooster();
					
					//var win:StockWindow = Window.isClass(StockWindow);
					//if (win) win.refresh();
				});
			}else{
			Post.send( {
				ctr:'stock',
				act:'charge',
				uID:App.user.id,
				sID:sID,
				count:count
			},function(error:*, result:*, params:*):void {
				
				if (error) {
					Errors.show(error, result);
					return;
				}
				
				/*if (result.hasOwnProperty(Stock.ENERGY_CAPACITY_BONUS)) {
					add(Stock.ENERGY_CAPACITY_BONUS, (result[Stock.ENERGY_CAPACITY_BONUS]-data[Stock.ENERGY_CAPACITY_BONUS]));
				}
				
				if (result.hasOwnProperty(Stock.FANTASY)) {
					data[Stock.FANTASY] = result[Stock.FANTASY];
					App.ui.upPanel.update();
				}*/
				
				if (!result) return;
				for (var prop:* in result) {
					if (!isNaN(int(prop))) {
						data[prop] = result[prop];
					}
				}
				
				if (result.hasOwnProperty(Stock.ENERGY_CAPACITY_BONUS))
					checkSystem();
					
				App.ui.upPanel.update();
			});
		}
		}
		
		public static function notAvailableItems():Array 
		{
			var updtItems:Array = [];
			if(App.data.updatelist.hasOwnProperty(App.social)) {
				for (var s:String in App.data.updatelist["DM"]) {
					if (!App.data.updates[s].social.hasOwnProperty(App.social)) {
						for(var sidItem:* in App.data.updates[s].items){
							updtItems.push(sidItem);
						}
					}
				}
			}
			return updtItems;
		}
		
		public function remove(sID:uint, count:int = 0):void {
			
			var countD:int = data[sID];
			
			if (countD - count <= 0)
				delete data[sID];
			else
				data[sID] -= count;
			
			Post.send( {
				ctr:'stock',
				act:'remove',
				uID:App.user.id,
				sID:sID,
				count:count
			},function(error:*, result:*, params:*):void 
			{
				if (error) {
					Errors.show(error, data);
					return;
				}
			});
		}
		
		public function get energy():int {
			return App.data.levels[App.user.level].energy;
		}
		
		// Stock change
		private var sct:int = 0;	// Изменение склада - отсрочка
		public function stockChange():void {
			if (sct != 0) clearTimeout(sct);
			sct = setTimeout(stockChangeDispatch, 100);
		}
		private function stockChangeDispatch():void {
			App.self.dispatchEvent(new AppEvent(AppEvent.ON_CHANGE_STOCK, false, false));
			clearTimeout(sct);
			sct = 0;
		}
		
		// Dispatch Stock take || add
		private var actionList:Array = [];
		public var actionTimer:int = 0;
		public function action(sid:int, action:String = ''):void {
			if (!App.user.quests.tutorial) {
				if (actionList.indexOf(sid) == -1) actionList.push(sid);
				actionTimer = App.time;
			}
		}
		public function dispatchAction():void {
			App.self.dispatchEvent(new AppEvent(AppEvent.ON_STOCK_ACTION, false, false, { sids:actionList, action:action } ));
			actionList = [];
		}
		//
		//public function addTempChests(data:*):void
		//{
			//for (var sid:* in data)
			//{
				//for (var index:* in data[sid])
				//{
					//App.user.stock.tempChests[sid][index] = data[sid][index];
				//}
				////App.user.stock.tempChests[sid] = data[sid];
			//}
			//trace();
		//}
	}	
}