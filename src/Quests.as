package
{
	import api.ExternalApi;
	import buttons.Button;
	import core.Log;
	import core.Numbers;
	import core.Post;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.utils.ByteArray;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	import ui.QuestIcon;
	import ui.QuestPanel;
	import units.Bridge;
	import units.Building;
	import units.Field;
	import units.Floors;
	import units.Golden;
	import units.Hero;
	import units.Hut;
	import units.Invader;
	import units.Personage;
	import units.Pigeon;
	import units.Techno;
	import units.Technological;
	import units.Underground;
	import units.Unit;
	import units.WorkerUnit;
	import units.Zoner;
	import wins.BarterWindow;
	import wins.ChapterWindow;
	import wins.CollectionWindow;
	import wins.DaylicWindow;
	import wins.ExchangeWindow;
	import wins.FreeGiftsWindow;
	import wins.FrenchEventWindow;
	import wins.GoalWindow;
	import wins.HelpWindow;
	import wins.HutHireWindow;
	import wins.HutWindow;
	import wins.InfoWindow;
	import wins.InviteSocialFriends;
	import wins.LevelUpWindow;
	import wins.OpenZoneWindow;
	import wins.Paginator;
	import wins.ProductionWindow;
	import wins.QuestRewardWindow;
	import wins.QuestWindow;
	import wins.ShopWindow;
	import wins.actions.ShareHeroWindow;
	import wins.ShopWindow;
	import wins.SimpleWindow;
	import wins.StockWindow;
	import wins.TopAwardWindow;
	import wins.TravelWindow;
	import wins.TutorialMessageWindow;
	import wins.UndergroundWindow;
	import wins.Window;
	import wins.WindowEvent;
	import wins.actions.ShareHeroWindow;
	
	public class Quests 
	{
		public var data:Object = { };
		
		public var opened:Array = [];
		public var needIntro:Boolean = false;
		
		public static var targetSettings:Object;
		
		public var chapters:Array = [];
		public var exclude:Object = { };
		
		public static var questMission:int = 0;
		
		public static var currentDID:int = 0;
		public var dayliInitable:Boolean = false;
		public var dayliPressent:uint;
		public var dayliLowestLevel:uint = 999;
		public static var daylicsComplete:Boolean = false;
		public static var daylics:Object = {};
		public static var daylicsList:Array = [];
		public var _dayliInit:Boolean = false;
		
		public static var currentDMID:int = 0;
		
		public function Quests(quests:Object)
		{
			if (quests) data = quests;
			
			for (var questID:* in App.data.quests) {
				if (!App.data.quests[questID].hasOwnProperty('ID'))
				delete App.data.quests[questID];
			}
			App.self.addEventListener(AppEvent.ON_UI_LOAD, init);
		}
		
		public function init(e:AppEvent):void {
			//if (App.user.id == '1' || App.user.id == '49') return;
			//Log.alert('QUESTS ' + App.SERVER);
			if (App.user.id == '1') return;
				//data
			for each(var item:Object in App.data.updates) {
				if (item['quests'] != undefined) {					
					var qID:* = item['quests'];
					var has:Boolean = false
					
					
					if (item['social'].hasOwnProperty(App.social))
						has = true;	
						
					if (!has)
						exclude[qID] = qID;
				}
			}
			
			// Записываем главы, которые нам встречались
			for (id in data) {
				if (App.data.quests[id] == null) {
					delete data[id];
					continue;
				}
				inNewChapter(App.data.quests[id].chapter)
			}
			
			for (var id:* in App.data.quests) {
				
				if (exclude[id] != undefined) {
					var parentID:int = App.data.quests[id].parent;
					var updateID:String = App.data.quests[id].update || null;
					//delete App.data.quests[id];
					deletedQuests.push(id);
					deleteAllChildrens(id, parentID, updateID);
					
				}	
				
				if (App.data.quests[id].hasOwnProperty('duration')) {
					if (App.user.quests.data.hasOwnProperty(id)) {
						if (App.data.quests[id].duration > 0 && App.user.quests.data[id].created + App.data.quests[id].duration * 3600 < App.time) {
							deletedQuests.push(id);
						}
					}
				}
				
				if (App.data.quests[id].hasOwnProperty('chapter') && App.data.chapters[App.data.quests[id].chapter].hasOwnProperty('level') && App.data.chapters[App.data.quests[id].chapter].level != 0 && App.data.chapters[App.data.quests[id].chapter].level > App.user.level) {
					//deletedQuests.push(id);
					continue;
				}
				
				openChilds(id);
				
				if (id == 516) {
					var info:Object = JSON.parse(App.data.quests[id].missions[1].target[1]);
					var qid:int = id;
					if (info.hasOwnProperty('time') && data.hasOwnProperty(id) && data[id].finished > 0 && data[id].finished < info.time) {
						if (data[id].hasOwnProperty('bonus') && data[id].bonus == 1) {
							
						} else {
							setTimeout(function():void {
								new TopAwardWindow( {
									sid:		info.bonus,
									qID:		qid,
									mID:		1
								}).show()
							}, 2000);
						}
					}
				}
			}
			
			removeDeletedQuests();
			// Проверяем акции
			getOpened();
			App.ui.leftPanel.questsPanel.refresh();
			
			if(App.data.hasOwnProperty('daylics'))
				getDaylics();
		}
		
		
		public function subtractEvent(qID:int, mID:int, callback:Function, type:String = 'quest'):Boolean {
			
			if (type == 'quest') 
			{
			if (data[qID] == undefined || data[qID].finished != 0) {
				return false;
			}
				
			}else if (App.user.daylics.quests[qID]== undefined || App.user.daylics.quests[qID][mID] != 0) {
				return false;
			
			}
			
			var mission:Object = App.data[type][qID].missions[mID];
			
			if (App.user.stock.take(mission.target[0], mission.need)) {
				
				Post.send( {
					ctr:'quest',
					act:(type =='quest')?'subtract':'dsubtract',
					uID:App.user.id,
					qID:qID,
					mID:mID
				}, function(error:*, result:*, params:*):void {
					
					if (error) {
						
					}else if (result&&App.self.getLength(result)) {
						data[qID][mID] = mission.need;
						callback(mID);
					}
					
				});
				
				return true;
			}
			
			return false;
		}
		
		public function get dayliInit():Boolean {
			return _dayliInit;
		}
		
		public function set dayliInit(value:Boolean):void {
			_dayliInit = value;
			App.ui.leftPanel.dayliState(value);
		}
		public function dayliProgress(state:Object):void {
			var finishedQuest:int = 0;
			for (var dID:String in state) {
				var missions:* = state[dID];
				
				if (missions is String && missions == "finished") {
					daylics[dID].finished = App.time;
					finishedQuest = int(dID);
					
					currentDID = 0;
					for (var i:int = 0; i < daylicsList.length; i ++) {
						if (daylicsList[i].finished == 0) {
							currentDID = daylicsList[i].dID;
							currentDMID = 0;
							break;
						}
					}
					
					for(var mid:String in daylics[dID].progress) {
						if (daylics[dID].progress[mid] < App.data.daylics[dID].missions[mid].need) {
							// Зачислить бонус по незачисленным миссиям
							App.user.stock.addAll(daylics[dID].missions[mid].bonus);
						}
					}
				}else{
					for (var mID:String in missions) {
						if (!daylics.hasOwnProperty(dID)) continue;
						if (daylics[dID].progress is Number) continue;
						
						daylics[dID].progress[mID] = missions[mID];
						if (daylics[dID].progress[mID] >= App.data.daylics[dID].missions[mID].need) {
							App.ui.leftPanel.startDaylicsGlow(true);
							// Зачислить бонус
							App.user.stock.addAll(daylics[dID].missions[mID].bonus);
							App.ui.upPanel.update();
						}
					}
				}
			}
			
			if (daylics[dID].finished > 0) {
				daylics[dID].progress = App.time;
				App.user.stock.addAll(daylics[dID].bonus);
			}
			
			// Проверить или не закончились на сегодня дейлики
			daylicsComplete = true;
			for (var did:String in daylics) {
				if (daylics[did].finished == 0) daylicsComplete = false;
			}
			
			var window:* = Window.isClass(DaylicWindow);
			if (window) {
				if (daylicsComplete) {
					window.close();
				}else {
					window.infoUpdate();
				}
				
				if (daylics[dID].finished > 0) {
					window.showTake(dID);
				}
			}
			if (finishedQuest > 0) {
				new QuestRewardWindow( { qID:finishedQuest, type:QuestRewardWindow.DAYLICS } ).show();
				App.ui.leftPanel.startDaylicsGlow(true);
			}
		}
		public function getDaylics(openWindow:Boolean = false):void {
			if (dayliInit) return;
			if (App.user.level < 12) return;
			daylicsInitable();
			if (tutorial || !dayliInitable) return;
			Post.send( {
				ctr:'user',
				act:'refreshdaylics',
				uID:App.user.id
			}, function(error:int, data:Object, params:Object):void {
				App.user.daylics = data.result;
				daylicsInit();
				if (dayliPressent is uint && dayliPressent == 0) {
					dayliPressent = 1;
					App.ui.leftPanel.startDaylicsGlow(true);
					if (App.user.level >= dayliLowestLevel) {
						new SimpleWindow( {
							title:		Locale.__e("flash:1443524094307"),
							text:		Locale.__e("flash:1443599234454"),
							label:		SimpleWindow.DAYLICS
						}).show();
					}else{
						new SimpleWindow( {
							title:		Locale.__e("flash:1443524094307"),
							text:		Locale.__e("flash:1443599234454"),
							label:		SimpleWindow.DAYLICS
						}).show();
					}
				}
				if(dayliInit && openWindow) {
					new DaylicWindow().show();
				}
			});
		}
		
		public function daylicsInitable():void {
			const numMissions:int = 1;
			var numQuests:uint = 0;
			
			if(App.user.daylics.hasOwnProperty('quests')) {
				for each (var value:* in App.user.daylics.quests) {
					numQuests++;
				}
				if (numQuests > 0) {
					dayliPressent = 1;
					dayliInitable = false;
					daylicsInit();
					return;
				}
			}
			dayliPressent = 0;
			
			for each(var daylic:Object in App.data.daylics) {
				if (!daylic.hasOwnProperty('missions')) continue;
				var totalAvailMissions:uint = 0;
				for (var s:String in daylic.missions) {
					if (dayliLowestLevel > daylic.missions[s].levelStart) dayliLowestLevel = daylic.missions[s].levelStart;
					if (App.user.level >= daylic.missions[s].levelStart && App.user.level <= daylic.missions[s].levelFinish) {
						totalAvailMissions++;
					}
				}
				
				if (totalAvailMissions >= numMissions) {
					numQuests++;
				}
			}
			
			if (numQuests >= 3) {
				dayliInitable = true;
			}
		}
		
		private function clone(object:Object):Object {
			var copier:ByteArray = new ByteArray();
			copier.writeObject(object);
			copier.position = 0;
			return	copier.readObject();
		}
		
		public function daylicsInit():void {
			if (!App.user.daylics) return;
			daylics = {};
			daylicsList = [];
			daylicsComplete = false;
			for (var did:String in App.user.daylics.quests) {
				var info:Object = App.user.daylics.quests[did];
				var daylic:Object = clone(App.data.daylics[did]);
				daylic['progress'] = App.user.daylics.quests[did];
				daylic['finished'] = 0;
				daylic['dID'] = did;
				
				if (!daylics.hasOwnProperty(did)) {
					daylics[did] = daylic;
					daylicsList.push(daylic);
				}
				
				daylicsComplete = true;
				for (var mid:String in daylic.missions) {
					if (daylic.progress is Number) {
						daylic.finished = App.time;
						continue;
					}else {
						if (!info.hasOwnProperty(mid)) { // || App.user.level < daylic.missions[mid].levelStart || App.user.level >= daylic.missions[mid].levelFinish
							delete daylic.missions[mid];
						}else {
							daylicsComplete = false;
						}
					}
					
					if (daylic.missions[mid] && daylic.missions[mid].need > daylic.progress[mid]) {
						if(currentDID == 0)
							currentDID = int(did);
					}
				}
			}
			daylicsList.sortOn('order', Array.NUMERIC);
			if (daylicsList.length > 0) {
				dayliInit = true;
			}
		}
		
		private function removeDeletedQuests():void {
			for each(var id:* in deletedQuests) {
				if (App.data.quests[id] != null)
					delete App.data.quests[id];
			}
			deletedQuests = [];
		}
		
		private var deletedQuests:Array = [];
		private function deleteAllChildrens(qID:int, parentID:int, updateID:String):void
		{
			if (updateID == null) return;
			
			var quest:Object;
			// Выбираем квесты этого обновления
			for (var id:* in App.data.quests)
			{
				quest = App.data.quests[id];
				if (quest.hasOwnProperty('update') && quest.update == updateID)
				{
					deletedQuests.push(id);
					//delete App.data.quests[id];
				}
			}
			/*
			// Определяем наследников этих квестов
			var childrens:Array = [];
			for (var _id:* in App.data.quests)
			{
				if (data.hasOwnProperty(_id)) // если уже открыт
					continue;
					
				quest = App.data.quests[_id];
				if (deletedQuests.indexOf(quest.parent) != -1) {
					quest.parent = parentID;
					childrens.push(_id);

				}
			}
			
			if(childrens.length > 0)
				openQuest(childrens);*/
		}
		
		public function checkPromo(isLevelUp:Boolean = false):void
		{
			/*if (App.user.promo == null) return;
			
			for (var pID:* in App.data.promo)
			{
				if (App.user.promo.hasOwnProperty(pID)) 
					continue;
					
				var promo:Object = App.data.promo[pID];
				
				if (App.user.level >= promo.unlock.level) {
					if (promo.unlock.quest == 0 || (data[promo.unlock.quest] != null && data[promo.unlock.quest].finished > 0)) {
						
						if (promo.hasOwnProperty('type') && promo.type == 1)
						{	
							if (promo.time + promo.duration * 3600 < App.time)
								continue;
								
							App.user.promo[pID] = {
								started:promo.time,
								status:0
							};
							App.user.promo[pID]['new'] = App.time;
						}
						else
						{
							App.user.promo[pID] = {
								started:App.time,
								status:0
							};
							App.user.promo[pID]['new'] = App.time;
							openPromo(pID);
						}
					}
				}
			}*/
			
			App.user.updateActions();
			if (App.ui) {
				setTimeout(function():void{
					App.ui.salesPanel.createPromoPanel(isLevelUp);
					//App.ui.salesPanel.y = 110;
					//App.ui.salesPanel.resize(App.self.stage.stageHeight - App.ui.salesPanel.y - 200);
				}, 10000);
			}
		}
		
		public function checkFakeHut():void {
			var qID:int = 297;
			if (App.user.quests.data.hasOwnProperty(qID) && App.user.quests.data[qID].finished > 0)
			{
				App.self.dispatchEvent(new AppEvent(AppEvent.ON_DELETE_FAKE_HUT));
			}
		}
		
		public function checkFreebie():void
		{
			var many:Boolean = false;
			var fast:Boolean = false;
			
			if(App.user.freebie == null || App.ui.bottomPanel != null || App.ui.bottomPanel.bttnFreebie != null){
				fast = false;
			}else{
				if(App.user.freebie.ID != 0 && App.data.freebie[App.user.freebie.ID].social == App.social){
					var neededQuest:int = App.data.freebie[App.user.freebie.ID].unlock.quest;
					var neededLevel:int = App.data.freebie[App.user.freebie.ID].unlock.level;
					if (App.user.quests.data.hasOwnProperty(neededQuest) && App.user.quests.data[neededQuest].finished > 0 && App.user.level >= neededLevel )
					{
						if (App.isSocial('DM')){
							fast = true;
						}
					}
				}
			}
			
			//many = false
			if (App.ui && (fast || many || App.isSocial('FB','VK','OK','FS','ML','DM'))) {
				App.ui.bottomPanel.addFreebie();	
			}
		}
		
		public function openPromo(pID:String):void {
			Post.send( {
				ctr:'promo',
				act:'open',
				uID:App.user.id,
				pID:pID
			}, function(error:int, data:Object, params:Object):void {
				
				if (error) {
					Errors.show(error, data);
					return;
				}
			});
		}
		
		public function getOpened():void {
			opened = [];
			currentQID = 0;
			var messages:Array = [];
			
			for (var id:* in App.data.quests) {
				
				//if (id == 1130)
					//trace();
				
				// Если сообщение, ни миссий, ни родителя - это квест для точек прохождения
				if (App.data.quests[id].type == 1 && App.data.quests[id].parent == 0 && !App.data.quests[id].missions && !App.data.quests[id].bonus) continue;
				if (App.data.quests[id].hasOwnProperty('chapter') && App.data.chapters[App.data.quests[id].chapter].hasOwnProperty('level') && App.data.chapters[App.data.quests[id].chapter].level != 0 && App.data.chapters[App.data.quests[id].chapter].level > App.user.level) continue;
				if (data[id] != undefined && data[id].finished == 0) {
					
					if(currentQID == 0){
						currentQID = id;
						for each(var miss:* in App.data.quests[id].missions) {
							if (!data[id][miss.ID]) {// == undefined
								currentMID = miss.ID;
								break;
							}
						}
					}
					
					if (App.data.quests[id].tutorial)
						tutorial = true;
					
					var questObject:Object = App.data.quests[id];
					
					if (questObject.hasOwnProperty('update')) {
						var updateID:String = questObject.update;
						if (App.data.updates.hasOwnProperty(updateID) && !App.data.updates[updateID].social.hasOwnProperty(App.social)) {
							continue;
						}
					}
					
					if (App.data.quests[id].hasOwnProperty('parent') && App.data.quests[id].parent == 0 && App.data.quests[id]['bland'] > 0) {
						if (!App.user.worlds.hasOwnProperty(App.data.quests[id].bland))
							continue;
					}else if (App.data.quests[id].hasOwnProperty('parent') && App.data.quests[id].parent != 0 && App.data.quests[id]['bland'] && (!data.hasOwnProperty(App.data.quests[id].parent) || data[App.data.quests[id].parent].finished == 0)) {
						continue;
					}
					
					opened.push({
						id:id, 
						character:App.data.quests[id].character, 
						order:App.data.quests[id].order,
						fresh: data[id]['fresh'] || false,
						type: App.data.quests[id].type
					});
					if (data[id]['fresh'] != undefined) {
						delete data[id]['fresh'];
					}
				}
			}
			
			opened.sortOn('order', Array.NUMERIC);
			
			Tutorial.tutorialQuests();
			
			if (App.map == null) {
				App.self.addEventListener(AppEvent.ON_MAP_COMPLETE, onMapComplete);
			}else{
				scoreOpened();
			}
		}
		
		private function onMapComplete(e:AppEvent):void {
			App.self.removeEventListener(AppEvent.ON_MAP_COMPLETE, onMapComplete);	
			scoreOpened();
		}
		
		public function countOfUnits(sid:*):int {
			var childs:int = App.map.mSort.numChildren;
			var unit:Unit;
			var count:uint = 0;
			while (childs--) {
				unit = App.map.mSort.getChildAt(childs) as Unit;
				if (unit.sid == sid) {
					count++;
				}
			}
			childs = App.map.mTreasure.numChildren
			count = 0;
			while (childs--) {
				unit = App.map.mTreasure.getChildAt(childs) as Unit;
				if (unit.sid == sid) {
					count++;
				}
			}
			return count;
		}
		
		
		private function isItemExpired(item:Object):Boolean
		{
			var expire:int;
			
			if (item.expire) {
				if (item.expire.hasOwnProperty(App.social) && expire is int)
					expire = expire;
				else
					return false;
			}
			
			if (expire) {
				if (expire > App.time) {
					return false;
				} else {
					return true;
				}
			}
			
			return false;
		}
		
		public function scoreOpened():void {
			if (App.user.mode == User.GUEST || App.user.quests.tutorial) return;
			
			var scored:Object = { };
			var send:Boolean = false;
			var exit:Boolean = false;
			var targetID:*;
			
			for each(var quest:* in opened) {
				var missions:Object = App.data.quests[quest.id].missions;
				if (quest.id == 1193) {
					trace();
				}
				for (var mID:* in missions) {
					exit = false;
					if (App.isSocial('FB')) {
						if (int(quest.id) == 921 && App.user.quests.data.hasOwnProperty(878) && App.user.quests.data[878].finished > 0) {
							for each(targetID in missions[mID].target) {
								if(scored[quest.id] == undefined){
									scored[quest.id] = { };
								}
								scored[quest.id][mID] = { };
								scored[quest.id][mID][targetID] = 1;
								
								exit = true;
								send = true;
							}
						}
						if (exit) continue;
					}
					
					if (missions[mID]['score'] != undefined && missions[mID].score) {
						
						if (quest.id == 1127)
							trace(quest);
						
						if (quest.id == 1073 && mID == 1 && App.user.worldID == 2813) {
							for each(targetID in missions[mID].target) break;
							
							if(!scored[quest.id]) scored[quest.id] = { };
							scored[quest.id][mID] = { };
							scored[quest.id][mID][targetID] = 1;
							
							exit = true;
							send = true;
						}
						
						if (missions[mID].event == 'zone') 
						{
							for each(targetID in missions[mID].target) {
								if (App.user.world.zones.indexOf(targetID) != -1) {
									if(scored[quest.id] == undefined){
										scored[quest.id] = { };
									}
									scored[quest.id][mID] = { };
									scored[quest.id][mID][targetID] = 1;
									
									exit = true;
									send = true;
								}
							}
						}
						
						if (exit) continue;
						
						if (missions[mID].controller == 'zoner' && missions[mID].event == 'upgrade') {
							for each(targetID in missions[mID].target) {
								var zoners:Array = Map.findUnits([targetID]);
								var zoner:Zoner;
								if (zoners.length > 0) { 
									zoner = zoners[0];
									if (zoner['level'] >= missions[mID].need) {
										if(scored[quest.id] == undefined){
											scored[quest.id] = { };
										}
										scored[quest.id][mID] = { };
										scored[quest.id][mID] = zoner['level'];
										//scored[quest.id][mID][sID] = zoner.id;
										exit = true;
										send = true;
									}
								} else {
									var index:int = 0;
									while (index < App.map.mField.numChildren) {
										currentTarget = App.map.mField.getChildAt(index);
										
										if (currentTarget.sid == targetID){
											zoners.push(currentTarget);
										}
										index++;
									}
									if (zoners.length > 0) { 
										zoner = zoners[0];
										if (zoner['level'] >= missions[mID].need) {
											if(scored[quest.id] == undefined){
												scored[quest.id] = { };
											}
											scored[quest.id][mID] = { };
											scored[quest.id][mID] = zoner['level'];
											//scored[quest.id][mID][sID] = zoner.id;
											exit = true;
											send = true;
										}
									}
								}
							}
						}
						
						if (exit) continue;
						
						////автозачет если target истекло время действия и, target построен удален, ограничен по количеству, количество превышено  и target нельзя уже построить
						//if (missions[mID].target && missions[mID].target.length > 0) {
							//for each(targetID in missions[mID].target) {
								//var info:Object = App.data.storage[targetID];
								//
								//if (info.hasOwnProperty("gcount") && !Storage.shopLimitCanBuy(targetID) || info..hasOwnProperty("expire")  && isItemExpired(info)) { 
									//if(scored[quest.id] == undefined){
										//scored[quest.id] = { };
									//}
									//scored[quest.id][mID] = { };
									//scored[quest.id][mID][targetID] = missions[mID].need;
									//exit = true;
									//send = true;
								//} 
							//}
						//}
						
						if (exit) continue;
						
						if (missions[mID].controller == 'top' && missions[mID].event == 'abonus') {
							for each(targetID in missions[mID].target) {
								var happy:Array = Map.findUnits([targetID]);
								if (happy.length > 0) { 
									var topID:int = happy[0].topID;
									if (App.user.top.hasOwnProperty(topID) && App.user.top[topID].hasOwnProperty('abonus') && App.user.top[topID].abonus + 1 >= missions[mID].need) {
										if(scored[quest.id] == undefined){
											scored[quest.id] = { };
										}
										scored[quest.id][mID] = { };
										scored[quest.id][mID] = missions[mID].need;
										exit = true;
										send = true;
									}
								} 
							}
						}
						
						if (exit) continue;
						
						if (missions[mID].controller == 'user' && missions[mID].event == 'state') {
							for each(targetID in missions[mID].target) {
								if (targetID == App.user.worldID) { 
									if(scored[quest.id] == undefined){
										scored[quest.id] = { };
									}
									scored[quest.id][mID] = { };
									scored[quest.id][mID][sID] = 0;
									exit = true;
									send = true;
								} 
							}
						}
						
						if (exit) continue;
						
						if (missions[mID].controller == 'exresource' && missions[mID].event == 'start') {
							for each(targetID in missions[mID].target) {
								var resources:Array = Map.findUnits([targetID]);
								if (resources.length > 0) continue;
								for each (var res:* in resources) {
									if (res.resource_state == 1) { 
										if(scored[quest.id] == undefined){
											scored[quest.id] = { };
										}
										scored[quest.id][mID] = { };
										scored[quest.id][mID][sID] = 0;
										exit = true;
										send = true;
									} 
								}
							}
						}
						
						if (exit) continue;
						
						if (missions[mID].controller == 'decor' && missions[mID].event == 'remove') {
							for each(targetID in missions[mID].target) {
								var decors:Array = Map.findUnits([targetID]);
								if (decors.length == 0 && App.user.worldID == 555) { 
										if(scored[quest.id] == undefined){
											scored[quest.id] = { };
										}
										scored[quest.id][mID] = { };
										scored[quest.id][mID][sID] = 0;
										exit = true;
										send = true;
								} 
							}
						}
						
						if (exit) continue;
						
						if (missions[mID].controller == 'happy' && (missions[mID].event == 'grow' || missions[mID].event == 'buy')) {
							if (data[quest.id][mID] >= missions[mID].need) 
								continue;
							for each(targetID in missions[mID].target) {
								var inf:Object = App.data.storage[targetID];
								var out:Array = Map.findUnits([inf.out]);
								if (out.length > 0) { 
									if(scored[quest.id] == undefined){
										scored[quest.id] = { };
									}
									scored[quest.id][mID] = { };
									scored[quest.id][mID][sID] = 0;
									exit = true;
									send = true;
								} 
							}
						}
						
						if (exit) continue;
						
						if (missions[mID].controller == 'resource' && missions[mID].event == 'remove') {
							for each(targetID in missions[mID].target) {
								var decor:Array = Map.findUnits([targetID]);
								if (decor.length == 0 && App.data.quests[quest.id].dream.indexOf(App.user.worldID) != -1) { 
										if(scored[quest.id] == undefined){
											scored[quest.id] = { };
										}
										scored[quest.id][mID] = { };
										scored[quest.id][mID][sID] = 0;
										exit = true;
										send = true;
								} 
							}
						}
						
						if (exit) continue;
						
						if (missions[mID].controller == 'underground' && missions[mID].event == 'go') {
							for each(targetID in missions[mID].map) {
								var under:Array = Map.findUnits([targetID]);
								for each (var target:Underground in under) {
									if (target.expire < App.time) continue;
									var tresNeed:int = 0;
									var tresCount:int = 0;
									var countSum:int = 0;
									for each(var tresID:* in missions[mID].target) {
										if (!target.grid) continue;
										for (var x:* in target.items){
											if(target.items[x] == tresID)
												tresNeed++;
										}
										for (var xt:* in target.grid){
											for (var y:* in target.grid[xt]){
												if(target.grid[xt][y])
													if (target.items[target.grid[xt][y].id] == tresID)
														tresCount++;
											}
										}
										countSum = tresNeed - tresCount;
										if (data[quest.id].hasOwnProperty(mID) && data[quest.id][mID] < missions[mID].need && countSum > data[quest.id][mID]) { 
												if(scored[quest.id] == undefined){
													scored[quest.id] = { };
												}
												//scored[quest.id][mID] = { };
												scored[quest.id][mID] = countSum;
												exit = true;
												send = true;
										}else if (!data[quest.id].hasOwnProperty(mID) && countSum > 0) {
											if(scored[quest.id] == undefined){
												scored[quest.id] = { };
											}
											data[quest.id][mID] = countSum;
											//scored[quest.id][mID] = { };
											scored[quest.id][mID] = countSum;
											exit = true;
											send = true;
										}
									}
								}
							}
						}
						
						if (exit) continue;
						
						if (missions[mID].controller == 'technological' && missions[mID].event == 'finished') {
							if (data[quest.id][mID] >= missions[mID].need) 
								continue;
							for each(var tarID:* in missions[mID].target) {
								var technologie:Array = Map.findUnits([tarID]);
								if (technologie.length > 0) { 
									for each (var build:Technological in technologie) {
										for (var prizeID:String in build.prizes) {
											var recipeTechno:Object = App.data.storage[prizeID];
											var countNeed:int = Numbers.countProps(recipeTechno.devel.point);
												if (countNeed == build.prizes[prizeID]) {
													if(scored[quest.id] == undefined){
														scored[quest.id] = { };
													}
													scored[quest.id][mID] = { };
													scored[quest.id][mID][sID] = 0;
													exit = true;
													send = true;
												}
											if (exit) continue;
										}
										if (exit) continue;
									}
									if (exit) continue;
								} 
							}
						}
						
						if (missions[mID].controller == 'technological' && missions[mID].event == 'storage') {
							if (data[quest.id][mID] >= missions[mID].need) 
								continue;
							for each(var trgID:* in missions[mID].target) {
								var techno:Array = Map.findUnits([trgID]);
								if (techno.length > 0) { 
									for each (var bulding:Technological in techno) {
										for each (var prize:Object in bulding.prizes) {
												if (prize >= missions[mID].need) {
													if(scored[quest.id] == undefined){
														scored[quest.id] = { };
													}
													scored[quest.id][mID] = { };
													scored[quest.id][mID][trgID] = 0;
													exit = true;
													send = true;
												}
											if (exit) continue;
										}
										if (exit) continue;
									}
									if (exit) continue;
								} 
							}
							
							if (!exit) {
								for each(var tID:* in missions[mID].target) {
									for each(var mapID:* in missions[mID].map) {
										var tech:Array = Map.findUnits([mapID]);
										if (tech.length > 0) { 
											for each (var buld:Technological in tech) {
												for (var prz:String in buld.prizes) {
													var recipe:Object = App.data.storage[prz];
													for (var it:* in recipe.devel.items) {
														if (buld.prizes[prz] < it)
															continue;
														
														for (var material:* in recipe.devel.items[it])
															break;
														
														if (int(material) == tID) {
															if (buld.prizes[int(prz)] >= missions[mID].need) {
																if(scored[quest.id] == undefined){
																	scored[quest.id] = { };
																}
																scored[quest.id][mID] = { };
																scored[quest.id][mID][mapID] = 0;
																exit = true;
																send = true;
															}
														}
													}
												}
												if (exit) continue;
											}
											if (exit) continue;
										} 
									}
								}
							}
						}
						
						if (exit) continue;
						
						if (missions[mID].controller == 'exchange' && missions[mID].event == 'change') {
							if (data[quest.id][mID] >= missions[mID].need) 
								continue;
							for each(var id:* in missions[mID].target) {
								var building:Array = Map.findUnits([id]);
								if (building.length != 0) { 
										if(scored[quest.id] == undefined){
											scored[quest.id] = { };
										}
										scored[quest.id][mID] = { };
										scored[quest.id][mID][id] = 1;
										exit = true;
										send = true;
								} else {
									if (App.user.stock.check(id)) {
										if(scored[quest.id] == undefined){
											scored[quest.id] = { };
										}
										scored[quest.id][mID] = { };
										scored[quest.id][mID][id] = 1;
										exit = true;
										send = true;
									}
								}
							}
						}
						
						
						if (exit) continue;
						
						if (missions[mID].controller == 'rbuilding' && missions[mID].event == 'upgrade') {
							if (data[quest.id][mID] >= missions[mID].need) 
								continue;
							for each(var rid:* in missions[mID].target) {
								var rbuilding:Array = Map.findUnits([rid]);
								if (rbuilding.length == 0 && App.user.worldID == 1801) { 
										if(scored[quest.id] == undefined){
											scored[quest.id] = { };
										}
										scored[quest.id][mID] = { };
										scored[quest.id][mID][rid] = 1;
										exit = true;
										send = true;
								}
							}
						}
						
						
						if (exit) continue;
						
						
						var childs:int; 
						var unit:Unit; 
						var _data:Array = [];
						
						
						childs = App.map.mSort.numChildren;
						while (childs--) {
							unit = App.map.mSort.getChildAt(childs) as Unit;
							if(unit != null)
								_data.push(unit)
						}
						
						childs = App.map.mLand.numChildren;
						while (childs--) {
							unit = App.map.mLand.getChildAt(childs) as Unit;
							if(unit != null)
								_data.push(unit)
						}
						
						childs = App.map.mTreasure.numChildren;
						while (childs--) {
							unit = App.map.mTreasure.getChildAt(childs) as Unit;
							if(unit != null)
								_data.push(unit)
						}
						
						childs = _data.length;
						exit = false;
						while (childs--) {
							
							//var unit:Unit = App.map.mSort.getChildAt(childs) as Unit;
							unit = _data[childs];
							
							//if (unit == null) continue;
							
							if (App.map._aStarNodes[unit.coords.x][unit.coords.z].open == false && unit.sid != 905) {
								continue;
							}
							
							for each(var sID:* in missions[mID].target){
								
								var need:int = missions[mID].need;
								var func:String = missions[mID].func;
								
								if (data[quest.id][mID] >= need) 
									continue;
									
								//if (data[quest.id].hasOwnProperty(mID) && data[quest.id][mID].hasOwnProperty(sID) && data[quest.id][mID][sID] >= need) {
									//continue;
								//}
								
								if (unit.sid == sID)
								{
									if (unit.sid == 3025)
										trace();
									
									var obj:Object = App.data.storage[sID];
									switch(missions[mID].event) {
										case 'buy': 
											if (['Building', 'Barter', 'Field', 'Factory', 'Mining', 'Moneyhouse', 'Golden', 'Storehouse', 'Fplant', 'Tradeshop', 'Fair', 'Castle', 'Floors', 'Changeable', 'Hut', 'Stall','Fatman','Tstation','Tribute','Technological','Happy','Exchange','Rbuilding','Efloors','Mfloors','Minigame','Buildgolden','Thappy','Shappy','Decor','Underground','Pethouse','Pfloors'].indexOf(unit.type) != -1) {
												if(scored[quest.id] == undefined){
													scored[quest.id] = { };
												}
												scored[quest.id][mID] = { };
												scored[quest.id][mID] = unit.id;
												//scored[quest.id][mID][sID] = unit.id;
												//exit = true;
												send = true;
											}
											break;
										case 'instance':
											if (['Building', 'Field', 'Factory', 'Mining', 'Moneyhouse', 'Golden', 'Storehouse'].indexOf(unit.type) != -1) {
												if(scored[quest.id] == undefined){
													scored[quest.id] = { };
												}
												var count:int = countOfUnits(sID);
												
												scored[quest.id][mID] = { };
												scored[quest.id][mID][sID] = count;
												//exit = true;
												send = true;
											}
											break;
										case 'finished':
											if (['Building', 'Field', 'Factory', 'Mining', 'Moneyhouse', 'Golden', 'Storehouse'].indexOf(unit.type) != -1) {
												if(scored[quest.id] == undefined){
													scored[quest.id] = { };
												}
												
												if(unit.hasOwnProperty('level') && unit.hasOwnProperty('totalLevels') && unit['level'] == unit['totalLevels']){
													count = countOfUnits(sID);
												
													scored[quest.id][mID] = { };
													scored[quest.id][mID][sID] = count;
													exit = true;
													send = true;
												}
											}
											break;
										case 'grow':
											if (['Floors','Mfloors'].indexOf(unit.type) != -1) {
												if (unit['floor'] >= missions[mID].need) {
													if(scored[quest.id] == undefined){
														scored[quest.id] = { };
													}
													scored[quest.id][mID] = { };
													scored[quest.id][mID][sID] = unit.id;
													exit = true;
													send = true;
												}else if (['Floors'].indexOf(unit.type) != -1 && unit['timer'] != 0) {
													if(scored[quest.id] == undefined){
														scored[quest.id] = { };
													}
													scored[quest.id][mID] = { };
													scored[quest.id][mID][sID] = unit.id;
													exit = true;
													send = true;
												}
											}
											if (['Happy'].indexOf(unit.type) != -1) {
												if (unit['level'] >= missions[mID].need) {
													if(scored[quest.id] == undefined){
														scored[quest.id] = { };
													}
													scored[quest.id][mID] = { };
													scored[quest.id][mID][sID] = unit.id;
													exit = true;
													send = true;
												}
											}
											break;
										case 'upgrade':
										case 'reward':
											if (['Building', 'Barter', 'Field', 'Factory', 'Golden', 'Tradeshop', 'Fair', 'Castle', 'Changeable', 'Zoner', 'Hut', 'Floors', 'Tstation','Tribute','Technological','Guide','Happy','Exchange','Rbuilding','Efloors','Stall','Mfloors','Minigame','Buildgolden','Thappy','Shappy','Cbuilding','Pethouse','Pfloors'].indexOf(unit.type) != -1) {
												if (unit['level'] >= missions[mID].need) {
												if(scored[quest.id] == undefined){
													scored[quest.id] = { };
												}
												scored[quest.id][mID] = { };
												scored[quest.id][mID] = unit['level'];
												//scored[quest.id][mID][sID] = unit.id;
												//exit = true;
												send = true;
												}
											}
											break;
										case 'create':
											if (['Animal'].indexOf(unit.type) != -1) {
												if(scored[quest.id] == undefined){
													scored[quest.id] = { };
												}
												scored[quest.id][mID] = { };
												scored[quest.id][mID][sID] = unit.id;
												exit = true;
												send = true;
											}
											break;
										case 'stock':
											if (['Bridge'].indexOf(unit.type) != -1) {
												if(Bridge(unit).isPierComplete())
												{
													if(scored[quest.id] == undefined){
														scored[quest.id] = { };
													}
													scored[quest.id][mID] = { };
													scored[quest.id][mID][sID] = unit.id;
													
													exit = true;
													send = true;
												}
											}
											if(['Building','Tribute','Floors'].indexOf(unit.type) != -1)
											{
												if(scored[quest.id] == undefined){
													scored[quest.id] = { };
												}
												scored[quest.id][mID] = { };
												scored[quest.id][mID][sID] = unit.id;
												
												exit = true;
												send = true;
											}
											break;
										case 'attach':
											
											if (['Cbuilding'].indexOf(unit.type) != -1) {
												trace();
											}
											
											break;
									}
								}
								if (exit) continue;
							}
							if (exit) continue;
						}		
					}
					/*if (send && data[quest.id][mID] >= App.data.quests[quest.id].missions[mID].need) {
						Post.send( {
							ctr:'quest',
							act:'score',
							uID:App.user.id,
							wID:App.user.worldID,
							score:JSON.stringify(scored)
						},function(error:*, data:*, params:*):void { send = false; } );
					}*/
				}	
			}
			if (send /*&& data[quest.id][mID] >= App.data.quests[quest.id].missions[mID].need*/) {
				Post.send( {
					ctr:'quest',
					act:'score',
					uID:App.user.id,
					wID:App.user.worldID,
					score:JSON.stringify(scored)
				},function(error:*, data:*, params:*):void {});
			}
		}	
		
		public function finishQuest(qID:int, mID:int):void
		{
			var obj:Object = { };
			obj[qID] = [mID];
			Post.send({
				ctr:'quest',
				act:'finish',
				uID:App.user.id,
				finished:JSON.stringify(obj)
			},function(error:*, data:*, params:*):void {});
		}	
		
		public function openQuest(childrens:Array):void 
		{
			var qIDs:Array = [];
			for (var i:int = 0; i < childrens.length; i++)
			{
				var qID:int = childrens[i];
				if (data[qID] == undefined)
				{
					qIDs.push(qID);
					data[qID] = { };
					data[qID]['finished'] = 0;
					data[qID]['fresh'] = true;
				}
			}
			
			if(qIDs.length > 0){
				Post.send( {
					ctr:'quest',
					act:'open',
					uID:App.user.id,
					qIDs:JSON.stringify(qIDs)
				},function(error:*, data:*, params:*):void {
					if (error) {
						Errors.show(error, data);
						return;
					}
					
					
					getOpened();
					App.ui.leftPanel.questsPanel.change();
				});
			}else {
				getOpened();
				App.ui.leftPanel.questsPanel.change();
			}
		}
		
		public function scoreQuest(qID:int, mID:int, id:int):void 
		{
			var scored:Object = { };
			if (data[qID].finished == 0)
			{
				scored[qID] = { };
				scored[qID][mID] = { };
				scored[qID][mID][id] = 1;
			}
			
			Post.send( {
				ctr:'quest',
				act:'score',
				uID:App.user.id,
				wID:App.user.worldID,
				score:JSON.stringify(scored)
			},function(error:*, data:*, params:*):void {
				if (error) {
					Errors.show(error, data);
					return;
				}
			});
		}
		
		public function initQuests():void {
			if (tutorial) return;
			
			// Если есть квесты и помощью, найти с самым маленьким ID и открыть с ним окно
			if (hasHelpInQuest) {
				Tutorial.showedQuests.push(hasHelpInQuest);
				openWindow(hasHelpInQuest);
			}
			
			openMessages();
		}
		
		private var shoewdFr:Boolean = false;
		private var alreadyShowed:Object = { };
		public function openMessages():void {
			for (var id:* in opened) {
				var qID:int = opened[id].id;
				var questInfo:Object = App.data.quests[qID];
				var stop:Boolean = false;
				
				if(opened[id].type > 0){
					switch (opened[id].type) {
						case 1:// Сообщения
							//new CharactersWindow( { qID:qID, mID:1 } ).show();
							if ( qID == 234) break;
							new TutorialMessageWindow( {
								title:			questInfo.title,
								description:	questInfo.description,
								personage:		(App.data.personages.hasOwnProperty(questInfo.character)) ? App.data.personages[questInfo.character].preview : App.data.personages[1].preview,
								callback:		function():void {
									readEvent(qID, function():void { } );
								}
							} ).show();
						break;
					case 2:// Начало цели
							Window.closeAll();
							new GoalWindow( { quest:App.data.quests[qID], width:595, height:360, popup:true } ).show();
							break;
						case 3:// Напоминание
							Window.closeAll();
							new GoalWindow( { quest:App.data.quests[qID], width:580, height:300, popup:true } ).show();
							break;
						case 4:// Награда
							Window.closeAll();
							new GoalWindow({quest:App.data.quests[qID], width:605, height:370, popup:true}).show();
						break;
					}
					
					App.ui.refresh();
					return;
				}
			}
		}
		
		public function isNew(qID:int):Boolean {
			for each(var quest:Object in opened) {
				if (qID == quest.id && quest.fresh && App.data.quests[qID].type != 1) {
					return true;
				}
			}
			return false;
		}
		
		public function isOpen(qID:int):Boolean {
			for each(var quest:Object in opened) {
				if (qID == quest.id && App.data.quests[qID].type != 1) {
					return true;
				}
			}
			return false;
		}
		
		public function openChilds(parentID:int = 0):void
		{
			var parentQuest:Object = data[parentID] || { };
			for (var qID:* in App.data.quests) {
				var quest:Object = App.data.quests[qID];
				
				if(((parentQuest['finished'] != undefined && parentQuest['finished'] > 0) || parentID == 0) && quest.parent == parentID){
					if(data[qID] == undefined){
						data[qID] = { };
						data[qID]['finished'] = 0;
						data[qID]['fresh'] = true;
						if(quest.hasOwnProperty('duration') && quest.duration > 0)
							data[qID]['created'] = App.time;
						
						if (App.ui.leftPanel) App.ui.leftPanel.resize();
						checkPromo();
						checkFreebie();
						checkFakeHut();
						
						if(data[qID] == 309){
							Events.initEvents();
						}
						//if (inNewChapter(quest.chapter)){
							//if (exclude.hasOwnProperty(quest.ID)) continue;
							//changeChapter(quest.chapter);
						//}
					}
				}
			}
		}
		
		private function inNewChapter(id:uint):Boolean
		{
			if (chapters.indexOf(id) == -1)
			{
				chapters.push(id);
				return true;
			}
			return false;
		}
		
		private function changeChapter(id:uint):void
		{
			new ChapterWindow( {
				chapter:id
			}).show();
			
			if (!App.user.quests.tutorial) {
				Pigeon.checkNews();
			}
			
			/*setTimeout(function():void {
				App.self.dispatchEvent(new AppEvent(AppEvent.ON_FINISH_TUTORIAL));
			},1000)*/
		}
		
		public function openWindow(qID:int):void {
			if (tutorial && hardTutorialQuestsList.indexOf(qID) == -1) return;
			
			for (var i:int = 0; i < App.self.windowContainer.numChildren; i++) {
				var window:* = App.self.windowContainer.getChildAt(i);
				if ((window is Window) && window.opened && window.settings.hasOwnProperty('qID') && window.settings.qID == qID) return;
			}
			
			//getOpened();
			if (App.data.quests[qID].bonus) {
				new QuestWindow( { qID:qID, popup:true } ).show();
			}
		}
		
		public function openPlusWindow(qID:int, others:Array = null):void {
			if (tutorial && hardTutorialQuestsList.indexOf(qID) == -1) return;
			
			for (var i:int = 0; i < App.self.windowContainer.numChildren; i++) {
				var window:* = App.self.windowContainer.getChildAt(i);
				if ((window is Window) && window.opened && window.settings.hasOwnProperty('qID') && window.settings.qID == qID) return;
			}
			
			//getOpened();
			if (App.data.quests[qID].bonus)
				new QuestWindow( { qID:qID, otherQuests:others } ).show();
		}
		
		private var timeGlowID:uint = 0;
		private var timeID:uint = 0;
		public function progress(state:Object):void {
			for (var qID:* in state) {
				var missions:Object = state[qID];
				var missionComplete:Boolean = false;
				for (var mID:* in missions) {
					if (!data.hasOwnProperty(qID)) {
						data[qID] = {
							finished:0
						}
					}
					data[qID][mID] = missions[mID];
					
					if (data[qID][mID] >= App.data.quests[qID].missions[mID].need) {
						missionComplete = true;
					}/*else if(App.data.quests[qID].tutorial && App.data.quests[qID].track){
						helpEvent(qID, mID);
					}*/
				}
				var finished:Boolean = true;
				for (mID in App.data.quests[qID].missions) {
					if ((data[qID][mID] == undefined || App.data.quests[qID].missions[mID].need > data[qID][mID]) || (App.data.quests[qID].duration > 0 && App.user.quests.data[qID].created + App.data.quests[qID].duration * 3600 < App.time)) {
						finished = false;
						break;
					}
				}
				
				if (finished == true) {
					if (data[qID].finished > 0) continue;
					data[qID].finished = App.time;
					
					
					//EWindow.testToShow(1, {qID:qID} );
					//Делаем push в _6e
					if (App.social == 'FB') {
						ExternalApi.og('complete','quest');
					}
					
					//App.user.stock.addAll(App.data.quests[qID].bonus.materials);
					
					if (!tutorial) {
						if (int(qID) == 537 || int(qID) == 632) {
							setTimeout(function():void {
								new QuestRewardWindow( {
									qID:qID,
									forcedClosing:true,
									strong:true,
									callback:onTakeEvent,
									finished:finished,
									missionComplete:missionComplete
								}).show();
							}, 5000);
						} else {
							new QuestRewardWindow( {
								qID:qID,
								forcedClosing:true,
								strong:true,
								callback:onTakeEvent,
								finished:finished,
								missionComplete:missionComplete
							}).show();
						}
					}
					
					
					if(InfoWindow.info.hasOwnProperty(qID) && qID != 1198) {
						new InfoWindow( {qID:String(qID)} ).show();
					}
					
					App.user.stock.addAll(App.data.quests[qID].bonus.materials);
					
					openChilds(qID);
					getOpened();
					openMessages();
					
					checkFakeHut();
					
					App.map.checkUnitsSpawn();
					
					clearTimeout(timeGlowID);
					clearTimeout(timeID);
					currentTarget = null;
					
					App.ui.leftPanel.resize();
					
				}else if (missionComplete) {
					//TODO показываем прогресс напротив иконки квеста
					if (App.ui && App.ui.leftPanel && !tutorial) {
						App.ui.leftPanel.questsPanel.focusedOnQuest(qID, QuestPanel.PROGRESS);
					}
				}
				
				if (Tutorial.mainTutorialComplete && helpInQuest(qID)) {
					
					// Определить или открыто окно QuestWindow
					var noQuestWindow:Boolean = true;
					if (App.self.windowContainer.numChildren > 0) {
						for (var i:int = 0; i < App.self.windowContainer.numChildren; i++) {
							var window:* = App.self.windowContainer.getChildAt(i);
							if ((window is QuestWindow) || (window is QuestRewardWindow) || (window is LevelUpWindow) || (window is GoalWindow))
								noQuestWindow = false;
						}
					}
					
					if (noQuestWindow) {
						var questID:int = 0;
						if (finished) {
							questID = hasHelpInQuest;
							if (Tutorial.showedQuests.indexOf(questID) >= 0) {
								questID = 0;
							}else {
								Tutorial.showedQuests.push(questID);
							}
						}else if(missionComplete){
							questID = qID;
						}
						
						if (questID) openWindow(questID);
					}
				}
				
				for (var ind:* in missions) {
					questMission = ind;
					break;
				}
				
			}
		}
		
		public function checkQuestsForTerritoty():void {
			var openQuests:Array = [];
			for (var id:* in App.data.quests) {					
				if (App.data.quests[id].hasOwnProperty('parent') && App.data.quests[id].parent == 0 && App.data.quests[id].hasOwnProperty('bland')) {
					if (App.user.worlds.hasOwnProperty(App.data.quests[id].bland)){ 
						openQuests.push(id);
					}
				}
			}
			
			if (openQuests.length != 0) {
				openQuest(openQuests);
			}
		}
		
		public function onTakeEvent(bonus:Object = null):void {
			//App.user.stock.addAll(bonus);
			
			ShopWindow.reInit();
			Invader.start();
		}
		
		public function silentRead(qID:int):void {
			Post.send( {
				ctr:'quest',
				act:'read',
				uID:App.user.id,
				qID:qID
			}, function(error:*, result:*, params:*):void {});
		}
		
		public function readEvent(qID:int, callback:Function):void {
			Post.send( {
				ctr:'quest',
				act:'read',
				uID:App.user.id,
				qID:qID
			}, function(error:*, result:*, params:*):void {
				if (result) {
					callback();
					data[qID]['finished'] = App.time;
					openChilds(qID);
					getOpened();
					
					if (Tutorial.mainTutorialComplete) {
						var questID:int = hasHelpInQuest;
						if (Tutorial.showedQuests.indexOf(questID) >= 0) {
							questID = 0;
						}else {
							Tutorial.showedQuests.push(questID);
						}
						
						if (questID) openWindow(questID);
					}
					
					App.ui.leftPanel.questsPanel.refresh();
					currentTarget = null;
					Tutorial.tutorialQuests();
					
					openMessages();
					
					if (qID == 423) App.user.stock.add(1091, 1);
					if (App.map.id == 1122 && App.user.quests.data.hasOwnProperty(423) && App.user.quests.data[423].finished > 0) {
						if (App.user.personages.length > 1) {
							var joe:* = App.user.personages.pop();
							joe.free();
							App.map.removeUnit(joe);
							
							//App.user.stock.add(1091, 1);
							if (App.user.stock.count(1091) > 0 ) {
								var settings:Object = { sid:1091, fromStock:true };
								var unit:Unit = Unit.add(settings);
								unit.stockAction({coords:{x:23, z:97}});
								unit.placing(23, 0, 97);
							}
						}
					}
				}
			});
			
			Invader.start();
		}
		
		public function skipEvent(qID:int, mID:int, callback:Function):Boolean {
			
			if (data[qID] == undefined || data[qID].finished != 0) {
				//TODO может быть нужно показывать окно о несоответсвии, если квест не открыт
				return false;
			}
			
			var mission:Object = App.data.quests[qID].missions[mID];
			
			if (App.user.stock.take(Stock.FANT, mission.skip)) {
				
				Post.send( {
					ctr:'quest',
					act:'skip',
					uID:App.user.id,
					qID:qID,
					mID:mID
				}, function(error:*, result:*, params:*):void {
					
					if (error) {
						App.user.stock.add(Stock.FANT, mission.skip);
					}else if (result) {
						data[qID][mID] = mission.need;
						
						callback(mID);
					}
					
				});
				
				return true;
			}
			
			return false;
			
		}
		
		public var win:*;
		
		public static var help:Boolean = false;
		public function helpEvent(qID:int, mID:int, dID:int = 0):void {
			var event:*;
			var value:*;
			var targets:Array = [];
			var mapTargets:Object;
			var searchByType:Boolean = false;
			var filter:Object;
			var all:Boolean = false;
			var questType:String = 'quests';
			var mission:Object;
			var id:*;
			
			if (dID == 1) {
				questType = 'daylics';
				//daylicsHelp = true;
				currentDMID = mID;
			}else {
				help = true;
				currentQID = qID;
				currentMID = mID;
			}
			
			mission = App.data[questType][qID].missions[mID];
			var tgs:Array = [];
			if (mission.map) {
				for each(id in mission.map) {
					tgs.push(id);
				}
			}else if (mission.target) {
				for each(id in mission.target) {
					tgs.push(id);
				}
			}
			targets.push( {
				event:		mission.find,
				targets:	tgs
			});
			
			if (mission.flist) {
				for (var s:* in mission.flist.f) {
					targets.push( {
						event:		mission.flist.f[s],
						targets:	[mission.flist.obj[s]]
					});
				}
			}
			
			var successHelp:Boolean = false;
			for (var i:int = 0; i < targets.length; i++) {
				successHelp = helpMissionTargets(mission, targets[i].event, targets[i].targets, qID, mID, questType);
				if (successHelp) break;
			}
			
			if (!successHelp) {
				if (targets.length > 0) {
					var __targets:Array = targets[targets.length - 1].targets;
					switch(targets[targets.length - 1].event) {
						case 1:
							new SimpleWindow( {
								title:Locale.__e("flash:1382952379744"),
								label:SimpleWindow.ERROR,
								text:Locale.__e("flash:1382952379745"),
								ok:function():void {
									
									if (App.user.level <= 2) {
										ExternalApi.sendmail( {
											title:'flash:1382952379745',
											text:App.self.flashVars['social'] + "  " + App.user.id
										});
									}else {
										var items:Array = [];
										for each(var sID:* in __targets) {
											if ((App.data.storage[sID] != undefined && App.data.storage[sID].market > 1 && App.data.storage[sID].visible > 0) || App.data.storage[sID].type == 'Animal' ) {
												items.push(sID);
											}
										}
										if(items.length > 0){
											var type:String = App.data.storage[items[0]] != undefined ? App.data.storage[items[0]].type : '';
											
											switch(type) {
												case '': break;
												case 'Animal': items = [54];
												default:
													ShopWindow.show( { find:items } );
													ShopWindow.instance.addEventListener(WindowEvent.ON_AFTER_OPEN, onAfterOpen);
													ShopWindow.instance.addEventListener(WindowEvent.ON_AFTER_CLOSE, onAfterClose);
													
													//win = new ShopWindow( { find:items } );
													//win.addEventListener(WindowEvent.ON_AFTER_OPEN, onAfterOpen);
													//win.addEventListener(WindowEvent.ON_AFTER_CLOSE, onAfterClose);
													//win.show();
											}
										}
									}
								}
							}).show();
							break;
						case 3:
							
							ShopWindow.show( { find:__targets } );
							ShopWindow.instance.addEventListener(WindowEvent.ON_AFTER_OPEN, onAfterOpen);
							ShopWindow.instance.addEventListener(WindowEvent.ON_AFTER_CLOSE, onAfterClose);
							
							//win = new ShopWindow( { find:__targets } );
							//win.addEventListener(WindowEvent.ON_AFTER_OPEN, onAfterOpen);
							//win.addEventListener(WindowEvent.ON_AFTER_CLOSE, onAfterClose);
							//win.show();
							break;
					}
				}
			}
			
		}
		
		/**
		 * 
		 * @param	mission			объект миссии
		 * @param	type			тип поиска
		 * @param	targets		список целей
		 * @return
		 */
		private function helpMissionTargets(mission:Object, type:int, targets:Array, qID:int, mID:int, questType:String):Boolean {
			var feedback:Boolean = false;
			var index:int = 0;
			var info:Object;
			
			var searchByType:Boolean = Boolean(mission.ontype) || false;
			var filter:Object = mission.filter;
			var all:Boolean = Boolean(mission.all) || false;
			
			switch(type) {
				case 0: break;
				case 1: // Поиск на карте
					if (qID == 54) {
						App.tutorial.quest54_1();
						return true;
					}
					
					if (!findTarget(targets, qID, mID, questType)) {
						feedback = false;
					}else {
						feedback = true;
					}
					
					/*if (!Find.find(targets[0]))
						feedback = false;*/
					
					
					
					break;
				case 2:	//В магазине
					
					if (App.data.quests[qID].tutorial) {
						
						currentTarget = App.ui.bottomPanel.bttnMainShop;
						currentTarget.showGlowing();
						
						currentTarget.showPointing("top", 0, 0, currentTarget.parent, '', null);
						
						targetSettings = { find:targets };
						currentTarget.addEventListener(MouseEvent.CLICK, onTargetClick, false, 3000);
						
						feedback = true;
					}else {
						
						//if (Config.admin || App.self.flashVars.debug == 1) {
							feedback = ShopWindow.find(targets);
						//}else{
						//
							//feedback = ShopWindow.search(targets);
							//
							//ShopWindow.show( { find:targets } );
							//ShopWindow.instance.addEventListener(WindowEvent.ON_AFTER_OPEN, onAfterOpen);
							//ShopWindow.instance.addEventListener(WindowEvent.ON_AFTER_CLOSE, onAfterClose);
							
							////win = new ShopWindow( { find:targets } );
							////win.addEventListener(WindowEvent.ON_AFTER_OPEN, onAfterOpen);
							////win.addEventListener(WindowEvent.ON_AFTER_CLOSE, onAfterClose);
							////win.show();
						//}
					}
					
					break; 
				case 3:	// На складе
					if (App.data[questType][qID].missions[mID].event == 'food') {
							var items:Array = Map.findUnits([160, 461]);							
							var huts:Array = [];
							
							for each (var itm:* in items) {
								var time:int = itm.workers[0].worker.finished - App.time;
								if (time > 0) {
									huts.push(itm);
								} 
							}
							
							if (huts.length > 0 ) {
								new HutWindow( {
									target:		huts[0],
									sID:		Techno.TECHNO,
									questHelp:  true,
									helpSID:    App.data[questType][qID].missions[mID].target[0]
								}).show();
							} else {
								new SimpleWindow( {
									title: Locale.__e('flash:1382952379828'),
									text: Locale.__e('flash:1437040752765'),
									popup: true
								}).show();
							}
							
							return true;
					}
					
					if (App.data[questType][qID].missions[mID].event == 'sell') {
						if (App.user.stock.count(targets[0]) <= 0) {
								ShopWindow.findMaterialSource(targets[0])
							return true;
						}
					}
					
					if (App.data[questType][qID].missions[mID].event == 'feed') {
						if (App.user.stock.count(targets[0]) <= 0) {
							var onMap:Array = Map.findUnits(targets);
							if (onMap.length == 0) {
								ShopWindow.findMaterialSource(targets[0])
							} else {
								App.map.focusedOn(onMap[0], true);
							}
							return true;
						}
					}
					
					win = new StockWindow( { find:targets, findEvent:App.data[questType][qID].missions[mID].event } );
					win.addEventListener(WindowEvent.ON_AFTER_OPEN, onAfterOpen);
					win.addEventListener(WindowEvent.ON_AFTER_CLOSE, onAfterClose);
					win.show();
					feedback = true;
					
					break; 
				case 4:	// В окне коллекций
					win = new CollectionWindow( { find:targets } );
					win.addEventListener(WindowEvent.ON_AFTER_OPEN, onAfterOpen);
					win.addEventListener(WindowEvent.ON_AFTER_CLOSE, onAfterClose);
					win.show();
					feedback = true;
					
					break; 
				case 5: // В окне варенья
					feedback = true;					
					break;
				case 6: // В бесплатных подарках
					win = new FreeGiftsWindow( { find:targets, mode:FreeGiftsWindow.FREE, icon:App.data[questType][qID].missions[mID].controller } );
					win.addEventListener(WindowEvent.ON_AFTER_OPEN, onAfterOpen);
					win.addEventListener(WindowEvent.ON_AFTER_CLOSE, onAfterClose);
					win.show();
					feedback = true;
					
					break; //В бесплатных подарках
				case 7:	// В принятых подарках
					win = new FreeGiftsWindow( { find:targets, mode:FreeGiftsWindow.TAKE } );
					win.addEventListener(WindowEvent.ON_AFTER_OPEN, onAfterOpen);
					win.addEventListener(WindowEvent.ON_AFTER_CLOSE, onAfterClose);
					win.show();
					feedback = true;
					
					break; 
				case 8: //В бесплатных подарках
					win = new FreeGiftsWindow( { find:targets, mode:FreeGiftsWindow.FREE, icon:'wishlist' } );
					win.addEventListener(WindowEvent.ON_AFTER_OPEN, onAfterOpen);
					win.addEventListener(WindowEvent.ON_AFTER_CLOSE, onAfterClose);
					win.show();
					feedback = true;
					
					break; 
				case 9: // В картах
					
					if (targets.indexOf(App.user.worldID) > -1) {
						feedback = false;
					}else{
						win = TravelWindow.show( { find:targets[0] } );
						win.addEventListener(WindowEvent.ON_AFTER_OPEN, onAfterOpen);
						win.addEventListener(WindowEvent.ON_AFTER_CLOSE, onAfterClose);
						feedback = true;
					}
					
					break;// В картах
				default:
					new SimpleWindow( {
						popup:	true,
						height:	300,
						width:	420,
						title:	Locale.__e('flash:1382952380254'),
						text:	mission.description
					}).show();
					feedback = true;
			}
			
			return feedback;
		}
		
		private function onTargetClick(e:MouseEvent):void {
			if (currentTarget == null) return;
			currentTarget.removeEventListener(MouseEvent.CLICK, onTargetClick);
			currentTarget.hidePointing();
			currentTarget.hideGlowing();
		}
		
		private function onFriendsIconClick(e:MouseEvent):void {
			onTargetClick(e);
			if (currentTarget == null) return;
			currentTarget = App.ui.bottomPanel.friendsPanel.friendsItems[0];
			currentTarget.showGlowing();
		}
		
		
		private function onOpenMaps(e:MouseEvent):void {
			onTargetClick(e);
		}
		
		
		private function filteredTarget(unit:Unit, filter:Object):Boolean {
			for (var field:String in filter) {
				var properties:Array = field.split(".");
				var value:* = filter[field];
				
				var target:* = unit;
				for each(var property:* in properties) {
					if (!target.hasOwnProperty(property)) 
						return false;
					
					target = target[property];
				}
				
				if (target != value)
					return false;	
			}
			
			return true;
		}
		
		public var targets:Array = [];
		public var currentTarget:*;
		//private var timeID:uint;
		public function findTarget(sIDs:Array, qID:int, mID:int, questType:String = 'quests'):Boolean {
			
			//var sPoint:Object = { x:App.user.hero.cell, z:App.user.hero.row };
			currentTarget = null;
			
			var sID:int;
			var approved:Array = [];	// Список объектов подходящих для поиска
			var personage:Hero;
			var mission:Object = App.data[questType][qID].missions[mID];
			
			// Если нужно найти похожие по типу объекты 
			if (mission.ontype) {
				var typeSID:int;
				for (var j:int = 0; j < mission.target; j++) {
					typeSID = mission.target[j];
					break;
				}
				if (App.data.storage.hasOwnProperty(typeSID)) {
					sIDs = [];
					for (var s:* in App.data.storage) {
						if (App.data.storage[s].type == App.data.storage[typeSID].type)
							sIDs.push(int(s));
					}
				}
			}
			
			if (mission.controller == 'roulette') {
				clearTimeout(timeID);
				App.ui.upPanel.rouletteBttn.showPointing("bottom", 0, 90, App.ui.upPanel, "", null, false);
				
				timeID = setTimeout(clear, 10000);
				return true;
			}
			
			//if (mission.controller == 'underground' && App.isSocial('FB','NK','SP','YB','MX','AI','GN')) {
				//UndergroundWindow.find = mission.target;
				//App.ui.upPanel.eventIcon.mouseClick();
				//return true;
			//}
			
			if (qID == 6) {
				if (mID == 1) {
					currentTarget = Map.findUnit(75, 1622);
				}else if (mID == 2) {
					currentTarget = Map.findUnit(125, 1586);
				}
			}
			
			if (qID == 447) {
				if (mID == 1) {
					currentTarget = Map.findUnit(1217, 92);
				}
			}
			
			if (qID == 301 && App.user.worldID == 767) {
				if (mID == 1) {
					var zoneID:int = 774;
					var data:Object = App.data.storage[zoneID];
					new OpenZoneWindow({
						title:App.data.storage[zoneID].title,
						sID:zoneID,
						requires:data.require,
						unlock:data.unlock,
						openZone:App.user.world.openZone,
						description:Locale.__e('flash:1439538711720')
					}).show();
					return true;
				}
			}
			
			if (qID == 343 && App.user.worldID == 903) {
				if (mID == 1) {
					currentTarget = Map.findUnit(371, 31);
					App.map.focusedOn(currentTarget, true, function():void {
						var zone:int = 907;
						var dat:Object = App.data.storage[zone];
						new OpenZoneWindow({
							title:App.data.storage[zone].title,
							sID:zone,
							requires:dat.require,
							unlock:dat.unlock,
							openZone:App.user.world.openZone,
							additionalPrice:App.data.storage[zone].price,
							description:Locale.__e('flash:1439538711720')
						}).show();
					});
					return true;
				}
			}
			
			if (qID == 486 && App.user.worldID == 1371) {
				if (mID == 1) {
					currentTarget = Map.findUnit(1364, 181);
					App.map.focusedOn(currentTarget, true, function():void {
						var zone:int = 1388;
						var dat:Object = App.data.storage[zone];
						new OpenZoneWindow({
							title:App.data.storage[zone].title,
							sID:zone,
							requires:dat.require,
							unlock:dat.unlock,
							openZone:App.user.world.openZone,
							additionalPrice:App.data.storage[zone].price,
							description:Locale.__e('flash:1439538711720')
						}).show();
					});
					return true;
				}
			}
			
			if (qID == 954 && App.user.worldID == Travel.SAN_MANSANO) {
				if (mID == 1) {
					currentTarget = Map.findUnit(370, 30);
					App.map.focusedOn(currentTarget, true, function():void {
						var zone:int = 2504;
						var dat:Object = App.data.storage[zone];
						new OpenZoneWindow({
							title:App.data.storage[zone].title,
							sID:zone,
							requires:dat.require,
							unlock:dat.unlock,
							openZone:App.user.world.openZone,
							additionalPrice:App.data.storage[zone].price,
							description:Locale.__e('flash:1439538711720')
						}).show();
					});
					return true;
				}
			}
			
			if (qID == 971 && App.user.worldID == Travel.SAN_MANSANO) {
				if (mID == 1) {
					currentTarget = Map.findUnit(2451, 1347);
					App.map.focusedOn(currentTarget, true, function():void {
						App.user.world.showOpenZoneWindow(2505);
						/*var zone:int = 2505;
						var dat:Object = App.data.storage[zone];
						new OpenZoneWindow({
							title:App.data.storage[zone].title,
							sID:zone,
							requires:dat.require,
							unlock:dat.unlock,
							openZone:App.user.world.openZone,
							additionalPrice:App.data.storage[zone].price,
							description:Locale.__e('flash:1439538711720')
						}).show();*/
					});
					return true;
				}
			}
			
			if (qID == 973 && App.user.worldID == Travel.SAN_MANSANO) {
				if (mID == 1) {
					currentTarget = Map.findUnit(2451, 1360);
					//currentTarget = Map.findUnit(2438, 179);
					App.map.focusedOn(currentTarget, true, function():void {
						App.user.world.showOpenZoneWindow(2506);
						/*var zone:int = 2506;
						var dat:Object = App.data.storage[zone];
						new OpenZoneWindow({
							title:App.data.storage[zone].title,
							sID:zone,
							requires:dat.require,
							unlock:dat.unlock,
							openZone:App.user.world.openZone,
							additionalPrice:App.data.storage[zone].price,
							description:Locale.__e('flash:1439538711720')
						}).show();*/
					});
					return true;
				}
			}
			
			if (qID == 1003 && App.user.worldID == Travel.SAN_MANSANO) {
				if (mID == 1) {
					currentTarget = Map.findUnit(2450, 1247);
					App.map.focusedOn(currentTarget, true, function():void {
						App.user.world.showOpenZoneWindow(2503);
					});
					return true;
				}
			}
			
			if (currentTarget) {
				App.map.focusedOn(currentTarget, true);
				return true;
			}
			
			
			var index:int = 0;
			while (index < App.map.mSort.numChildren) {
				currentTarget = App.map.mSort.getChildAt(index);
				
				if (sIDs.indexOf(currentTarget.sid) != -1){// && unit.open) {
					// Если нам нужно достичь такого же уровень, то ищем с меньшим уровнем
					//if (mission.func == 'equal' && mission.need > currentTarget.level) {
						approved.push(currentTarget);
					//}else {
						//approved.push(currentTarget);
					//}
				}
				
				index++;
			}
			
			index = 0;
			while (index < App.map.mTreasure.numChildren) {
				currentTarget = App.map.mTreasure.getChildAt(index);
				
				if (currentTarget.hasOwnProperty('sid') && sIDs.indexOf(currentTarget.sid) != -1){// && unit.open) {
					// Если нам нужно достичь такого же уровень, то ищем с меньшим уровнем
					//if (mission.func == 'equal' && mission.need > currentTarget.level) {
						approved.push(currentTarget);
					//}else {
						//approved.push(currentTarget);
					//}
				}
				
				index++;
			}
			
			if (approved.length == 0)
			{
				index = 0;
				while (index < App.map.mField.numChildren) {
					currentTarget = App.map.mField.getChildAt(index);
					
					if (sIDs.indexOf(currentTarget.sid) != -1){
						// Если нам нужно достичь такого же уровень, то ище с меньшим уровнем
						if (mission.func == 'equal' && mission.need > currentTarget.level) {
							approved.push(currentTarget);
						}else {
							approved.push(currentTarget);
						}
					}
					
					index++;
				}
			}
			
			// Для грядок
			//approved = approved.concat(Field.findFields());
			
			for (var i:int = 0; i < App.user.personages.length; i++) {
				if (!personage) personage = App.user.personages[i];
				if (App.user.personages[i].hasOwnProperty('main') && App.user.personages[i].main) personage = App.user.personages[i];
			}
			
			var distance:Number = 0;
			var targetID:int = 0;
			for (i = 0; i < approved.length; i++) {
				var predistance:Number = Math.sqrt((personage.x - approved[i].x) * (personage.x - approved[i].x) + (personage.y - approved[i].y) * (personage.y - approved[i].y));
				if (distance == 0 || predistance < distance) {
					distance = predistance;
					targetID = i;
				}
			}
			
			currentTarget = null;
			if (distance >= 0 && approved.length > 0) {
				
				currentTarget = approved[targetID];
				
				if (mission.controller == 'field' && mission.event == 'harvest') {
					for each (var field:* in approved) {
						if (field.ready) {
							currentTarget = field;
							break;
						}
					}
				}
				
				try {
					var unitInfo:Object = App.data.storage[currentTarget.sid];
					for (i = 0; i < mission.target.length; i++) {
						//if ((App.data.storage[mission.target[i]].type == 'Material' || App.data.storage[mission.target[i]].type == 'Pack' || App.data.storage[mission.target[i]].type == 'Decor' || App.data.storage[mission.target[i]].type == 'Box' || App.data.storage[mission.target[i]].type == 'Food')/* && unitInfo.devel.hasOwnProperty('craft')*/) {
							if (App.data.storage[currentTarget.sid].type == 'Exchange') {
								ExchangeWindow.find = mission.target[i];
							}
							if (App.data.storage[currentTarget.sid].type == 'Barter') {
								BarterWindow.findTargets = mission.target;
							}
							if (App.data.storage[currentTarget.sid].type == 'Underground') {
								UndergroundWindow.find = mission.target;
							}
							
							if (qID == 595 && mID == 1) {
								var vagons:Array = Map.findUnits([1624]);
								if (vagons.length == 0) {
									ProductionWindow.find = 1621;
								}else {
									ProductionWindow.find = 1622;
								}
							}else if (qID == 571 && mID == 1) {
								var trains:Array = Map.findUnits([1580]);
								if (trains.length == 0) {
									ProductionWindow.find = 1586;
								}else {
									if (trains[0].level == 0)
										ProductionWindow.find = 1588;
									else
										ProductionWindow.find = 1591;
								}
							}else if (qID == 598 && mID == 2) {
								ProductionWindow.find = 1620;
							}else if (qID == 599 && mID == 2) {
								ProductionWindow.find = 1621;
							}else if (qID == 600 && mID == 2) {
								ProductionWindow.find = 1622;
							}else {
								ProductionWindow.find = mission.target[i];
							}
							break;
						//}
					}
				
				}catch (e:*) { }
				App.map.focusedOn(currentTarget, true, function():void 
				{
					if (App.user.quests.tutorial) 
						return;
						
					if (currentTarget is Building) {
						currentTarget.click();
					}
				});
				
				return true;
			}else if (mission.flist && Numbers.countProps(mission.flist.f) > 0) {
				//
			}else if (!tutorial) {
				
				// Если перечень искомых ID не содержится в доступных разделах магазина, вырезать их
				var canBeInShop:Boolean = Boolean(sIDs.length);
				for (i = 0; i < sIDs.length; i++) {
					if ([2, 4, 14, 3].indexOf(App.data.storage[sIDs[i]].market) == -1) {
						sIDs.splice(i, 1);
						i--;
					}
				}
				
				if (sIDs.length > 0 || mission.target[0] == 1359) {
					if (sIDs[0] == 286) {
						if (App.user.worldID == Travel.SAN_MANSANO) {
							return false;
						}
						if (!ShopWindow.findMaterialSource(sIDs[0]))
							ShopWindow.find(sIDs);
							//new ShopWindow( {find:sIDs}).show();
					} else {
						if (!ShopWindow.findMaterialSource(mission.target[0]))
							ShopWindow.find(sIDs);
							//new ShopWindow( {find:sIDs}).show();
					}
				}else if (canBeInShop) {
					if (mission.target[0] == 816 || mission.target[0] == 817 || mission.target[0] == 815) {
						if (App.user.stock.check(mission.target[0])) {
							new StockWindow({find:[mission.target[0]]}).show();
						}
					} else {
						if ([515, 516, 508].indexOf(int(qID)) != -1) {
							TravelWindow.show( { findTargets:[112, 903, 932, 1122, 1371] } );
							return true;
						}
						if ([543].indexOf(int(qID)) != -1) {
							if (App.user.worldID != 1371) {
								TravelWindow.show( { findTargets:[1371] } );
							} else {
								ShopWindow.findMaterialSource(mission.target[0])
							}
							return true;
						}
						if ([790,796].indexOf(int(qID)) != -1) {
							FrenchEventWindow.find = mission.target;
							new FrenchEventWindow().show();
							return true;
						}
						//ShopWindow.showLocationWindow();
						return false;
					}
				}else {
					var idWorld:Array = [];
					for (var worldItem:* in App.user.instanceWorlds) {
						for (var item:* in App.user.instanceWorlds[worldItem]) {
							if (sIDs.indexOf(int(item)) != -1) {
								idWorld.push(worldItem);
							}
						}
					}
					if (idWorld.length != 0) {
						TravelWindow.show( { findTargets:idWorld } );
						return true;
					}
				}
				
				return true;
			}
			
			return false;
			
		}
		
		public function clear():void {
			clearTimeout(timeID);
			App.ui.upPanel.rouletteBttn.hideGlowing();
			App.ui.upPanel.rouletteBttn.hidePointing();
		}
		
		private function hideTargetGlowing(item:*):void {
			setTimeout(function():void {
				item.unit.hidePointing();
				item.unit.hideGlowing();
			}, 3000);
		}
		
		/*
		public var fader:Sprite = new Sprite();
		public function showFader():void {
			if (App.self.faderContainer.contains(fader)) {
				return;
			}
						
			fader.graphics.beginFill(0x000000,0);
			fader.graphics.drawRect(0, 0, App.self.stage.stageWidth, App.self.stage.stageHeight);
			fader.graphics.endFill();

			App.self.faderContainer.addChild(fader);
		}
		
		public function hideFader():void {
			if(App.self.faderContainer.contains(fader)){
				App.self.faderContainer.removeChild(fader);	
			}
		}
		*/
		
		public var track:Boolean = false;
		public var lock:Boolean = false;
		public function startTrack():void {	
			if (track == false) {
				trace('startTrack');
				track = true;
				App.self.stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseEvent, false, 1000);
				App.self.stage.addEventListener(MouseEvent.MOUSE_UP, onMouseEvent, false, 1000);
				App.self.stage.addEventListener(MouseEvent.CLICK, onMouseEvent, false, 1000);
				App.self.stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove, false, 1000);
				App.self.stage.addEventListener(MouseEvent.DOUBLE_CLICK, onMouseDouble, false, 1000);
			}
		}
		
		public function stopTrack():void {		
			trace('stopTrack');
			track = false;
			App.self.stage.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseEvent);
			App.self.stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseEvent);
			App.self.stage.removeEventListener(MouseEvent.CLICK, onMouseEvent);
			App.self.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			App.self.stage.removeEventListener(MouseEvent.DOUBLE_CLICK, onMouseDouble);
		}
		
		private function onMouseDouble(e:MouseEvent):void {
			e.stopImmediatePropagation();
		}
		
		private function onMouseMove(e:MouseEvent):void {
			App.self.moveCounter  = 0;
		}
		
		public static var lockButtons:Boolean = false;
		public var lastTarget:*;
		private function onMouseEvent(e:MouseEvent):void {
			
			//trace(e.type);
			if (e.type == MouseEvent.MOUSE_UP) {
				var objects:Array = App.self.getObjectsUnderPoint(new Point(App.self.mouseX, App.self.mouseY));
				Tutorial.initTargets(objects);
			}
			
			e.stopImmediatePropagation();
			e.stopPropagation();
			return;
		}
		
		public static var _lockFuckAll:Boolean = false;
		public function unlockFuckAll():void 
		{
			_lockFuckAll = false;
			lockButtons = false;
		}
		
		public function lockFuckAll():void 
		{
			_lockFuckAll = true;
			lockButtons = true;
		}
		
		public var currentQID:int = 0;
		public var currentMID:int = 0;
		public function continueTutorial():void
		{
			/*if (currentQID == 2 && !QuestsRules.fullscreen && App.social == 'PL') {
				if (!App.ui.systemPanel.bttnSystemFullscreen.__hasGlowing)
				{
					App.ui.systemPanel.bttnSystemFullscreen.showGlowing();
					App.ui.systemPanel.bttnSystemFullscreen.showPointing("right",0,60,App.ui.systemPanel, "", null, true);
					QuestsRules.getQuestRule(1, 1);
				}
				startTrack();
				currentTarget = App.ui.systemPanel.bttnSystemFullscreen;
				tutorial = true;
				return;
			}*/
			
			/*tutorial = false; 
			if (currentQID == 0 || !App.data.quests[currentQID].tutorial) {
				return;
			}else {
				tutorial = true;
			}
			
			if(App.data.quests[currentQID].track){
				startTrack();
			}*/
			
			/*lock = false;
			getOpened();
			if(opened.length > 0 && App.ui.leftPanel.questsPanel){
				for each(var questIcon:QuestIcon in App.ui.leftPanel.questsPanel.icons) {
					var bttn:QuestIcon = questIcon;
					
					if (bttn.qID == opened[0].id && data[opened[0].id].finished == 0) {
						
						App.ui.refresh();
						
						if (App.data.quests[currentQID].track) {
							switch(currentQID) {
								case 1:
										App.user.quests.helpEvent(currentQID, currentMID);
									break;	
								case 82:
								case 84:
								case 87:
								case 89:
								case 97:	
										App.user.quests.helpEvent(currentQID, currentMID);
									break;
								case 85:
										if(currentMID == 1){
											//App.tutorial.hide();
											//	App.user.quests.lockFuckAll();
											App.user.quests.helpEvent(currentQID, currentMID);
										}else {
											QuestsRules.getQuestRule(currentQID, currentMID);
										}
									break;	
								default:
										bttn.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
									break;	
							}
						}else{
							bttn.showGlowing();
							if (tutorial) {
								bttn.showPointing("left", 0, 0, questIcon, '', null, true);
							}else{
								bttn.showPointing("left", 0, 0, questIcon, Locale.__e("flash:1382952379743"), {
									color:0xf3c769,
									borderColor:0x322204,
									autoSize:"left",
									fontSize:24
								},true);
							}
							currentTarget = bttn;
						}
						break;
					}
				}
			}*/
		}
		
		//public function glowHelp(window:QuestWindow):void {
		public function glowHelp(window:ShareHeroWindow):void {
			for each(var mission:* in window.missions) {
				if (mission.helpBttn != null) {
					currentQID = mission.qID;
					currentMID = mission.mID;
					
					mission.helpBttn.showGlowing();
					mission.helpBttn.showPointing("top", 0, 30, mission.helpBttn.parent);
					currentTarget = mission.helpBttn;
					
					break;
				}
			}
		}
		
		private function onAfterOpen(e:WindowEvent):void 
		{
			//if (currentTarget == null) {
				//QuestsRules.getQuestRule(currentQID, currentMID);
			//}
		}
		
		private function onAfterClose(e:WindowEvent):void {
			if (currentTarget == null) {
				QuestsRules.getQuestRule(currentQID, currentMID);
			}
		}
		
		private var _tutorial:Boolean = false;
		public function set tutorial(value:Boolean):void {
			if (_tutorial == value) return;
			
			_tutorial = value;
			
			if (_tutorial) {
				Paginator.block = 1;
				startTrack();
			}else {
				Paginator.block = 0;
				stopTrack();
			}
		}
		public function get tutorial():Boolean {
			return _tutorial;
		}
		
		//private static var easyTutorialQuestsList:Array = [1, 2, 3, 4, 5, 12, 54, 23, 55, 27, 31, 32];
		public static var easyTutorialQuestsList:Array = [1,12,5,2,6,54,22,23,51,52,53,54,8,31,32,33,62];
		public static var hardTutorialQuestsList:Array = [54,32];//28
		public static function helpInQuest(qID:int = 0):Boolean {
			if (easyTutorialQuestsList.indexOf(qID) >= 0)
				return true;
			
			return false;
		}
		public static function get hasHelpInQuest():int {
			for (var i:int = 0; i < App.user.quests.opened.length; i++) {
				if (hardTutorialQuestsList.indexOf(App.user.quests.opened[i].id) >= 0 && App.ui.leftPanel.questsPanel.availableInWorld(App.user.quests.opened[i]))
					return hardTutorialQuestsList[hardTutorialQuestsList.indexOf(App.user.quests.opened[i].id)];
			}
			
			
			for (i = 0; i < App.user.quests.opened.length; i++) {
				if (easyTutorialQuestsList.indexOf(App.user.quests.opened[i].id) >= 0 && App.ui.leftPanel.questsPanel.availableInWorld(App.user.quests.opened[i]))
					return easyTutorialQuestsList[easyTutorialQuestsList.indexOf(App.user.quests.opened[i].id)];
			}
			
			/*for (var g:int = 0, h:int = 10; g > h; g++, h--) {
				trace(g, h);
			}*/
			
			return 0;
		}
	}

}