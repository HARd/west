package units
{
	import astar.AStarNodeVO;
	import core.Load;
	import core.Numbers;
	import core.Post;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import ui.UnitIcon;
	import wins.ConstructWindow;
	import wins.HutHireMoneyWindow;
	import wins.HutHireWindow;
	import wins.HutWindow;
	import wins.InfoWindow;
	import wins.SimpleWindow;
	import wins.TravelRequireWindow;
	
	public class Hut extends Building
	{
		public static const KLIDE_HOUSE:int = 278;
		public static const KLIDE_WORLD:int = 555;
		
		public static const WOOD:uint 		= 159;
		public static const STONE:uint 		= 108;
		public static const PROSPECTOR:uint = 52;
		public static const WATER:uint 		= 51;
		
		public static var WOOD_INST:Object = {};
		public static var MINE_INST:Object = {};
		public static var FISH_INST:Object = {};
		
		public static var WOOD_LIST:Array = new Array();
		public static var MINE_LIST:Array = new Array();
		
		public var energy:uint = 0;
		public var animal:uint = 0;
		public var base:uint = 0;
		public var price:Object = 0;
		public var time:uint = 0;
		public var finished:uint = 0;
		public var food:uint = 0;
		public var params:Object = null;
		public var technoToDelete:Array = new Array;
		public var workers:Object = { };
		public var workerUnits:Vector.<Techno> = new Vector.<Techno>;
		public var workerCount:int = 2;
		public var hutWindow:HutWindow;
		
		
		public function Hut(object:Object)
		{
			layer = Map.LAYER_SORT;
			
			energy = object.energy || 0;
			animal = object.animal || animal;
			price = App.data.storage[object.sid].price;
			time = App.data.storage[object.sid].time;
			
			super(object);
			
			if (object.hasOwnProperty('food'))
				food = object.food;
			
			stockable = false;//(sid == 160) ? true : false;
			if (sid == 752) stockable = true;
			rotateable = (sid == 160) ? true : false;
			
			totalLevels = 0;
			if (App.data.storage[sid].hasOwnProperty('devel')) {
				for (var level:* in App.data.storage[sid].devel.obj) {
					totalLevels++;
				}
			}
			touchableInGuest = true;
			
			if(level > 0 && sid != 304)
				workerCount = info.devel.req[level].limit;
			
			if (object.hasOwnProperty('workers'))
			{
				addWorkers(object.workers);
			}
			
			addTip();
			
			if (App.user.mode == User.OWNER)
				App.self.addEventListener(AppEvent.ON_MAP_COMPLETE, onMapComplete);
			
			if (sid == KLIDE_HOUSE && App.user.worldID == User.HOME_WORLD) {
				getMiniWorldInfo();
			}
			
			if (object.upgrade == 0 && sid != 461) hasUpgraded = false;
		}
		
		private function getMiniWorldInfo():void {
			if (App.user.worlds.hasOwnProperty(KLIDE_WORLD)) {
				var postObject:Object = {
					'ctr':'world',
					'act':'mini',
					'uID': App.user.id/*,
					"fields":"[\"world\",\"units\"]"*/
				}
				
				postObject['wID'] = KLIDE_WORLD;
				
				Post.send(postObject, onGetInfo);
			}
		}
		
		public static function homeCoords(rid:uint):Object
		{
			var cells:Object = { };
			if(rid){
			if (Hut.WOOD_LIST.indexOf(rid) != -1) {
				return Hut.WOOD_INST;
			}
			if (Hut.MINE_LIST.indexOf(rid) != -1) {
				return Hut.MINE_INST;
			}}
			return { coords:{x:5,z:5}};
		}
		public static function getByRecource(sid:uint):uint {
			
			if(Hut.WOOD_LIST.indexOf(sid)!=-1){
				return Hut.WOOD;
			}
			if(Hut.MINE_LIST.indexOf(sid)!=-1){
				return Hut.PROSPECTOR;
			}
			return 0;
		}
		
		public var miniWorldUnits:Object;
		private function onGetInfo(error:*, data:*, params:*):void {
			if (error) {
				//Errors.show(error, data);
				return;
			}
			
			var needIcon:Boolean = false;
			miniWorldUnits = data.units;
			
			for each (var unit:Object in miniWorldUnits) {
				if (['Golden', 'Building'].indexOf(App.data.storage[unit.sid].type) != -1) {
					if (unit.crafted <= App.time) {
						needIcon = true;
					}
				}
			}
			if (needIcon) {
				drawIcon(UnitIcon.REWARD, 2, 1, {
					glow:		true,
					onClick:    onTakeBonuses
				});
			}
		}
		
		private function onTakeBonuses():void {
			for each (var unit:Object in miniWorldUnits) {
				if (['Golden', 'Building'].indexOf(App.data.storage[unit.sid].type) != -1) {
					if (unit.crafted <= App.time) {
						Post.send({
							ctr:App.data.storage[unit.sid].type,
							act:'storage',
							uID:App.user.id,
							id:unit.id,
							wID:KLIDE_WORLD,
							sID:unit.sid
						}, onMiniStorageEvent);
					}
				}
			}
		}
		
		private function onMiniStorageEvent(error:int, data:Object, params:Object):void {
			clearIcon();
			var notConvert:Boolean = false;
			for (var _sID:Object in data.bonus)
			{
				var sID:uint = Number(_sID);
				for (var _nominal:* in data.bonus[sID])
				{
					notConvert = true;
					break;
				}
			}
			if (notConvert) Treasures.bonus(data.bonus, new Point(this.x, this.y));
			else Treasures.bonus(Treasures.convert(data.bonus), new Point(this.x, this.y));
			SoundsManager.instance.playSFX('bonus');
		}
		
		public function goOnFeed(feed:Feed):void 
		{
			hire(
				feed.energyObject.energy,
				feed.energyObject.friends,
				feed.energyObject.buy
			);	
			
			for each(var wObj:Object in workers) {
				var worker:Techno = wObj['worker'];
				worker.goToFeed(feed, function():void {
					
				});
			}
			
			App.self.dispatchEvent(new AppEvent(AppEvent.FEED_COMPLETE));
		}
		
		private var energyObject:Object;
		public function goOnPremiumFeed(feed:Feed):void 
		{
			App.user.stock.take(feed.energyObject.foodID, 1);
			
			this.energyObject = feed.energyObject;
			
			Post.send( {
				ctr:	info.type,
				act:	'food',
				uID:	App.user.id,
				wID:	App.user.worldID,
				sID:	this.sid,
				id:		id,
				mID:	feed.energyObject.foodID, 
				buy:	int(feed.energyObject.buy)
			}, onPremiumHireAction);	
			
			for each(var wObj:Object in workers) {
				var worker:Techno = wObj['worker'];
				worker.goToFeed(feed, function():void {
					
				});
			}
			
			App.self.dispatchEvent(new AppEvent(AppEvent.FEED_COMPLETE));
		}
		
		public function onPremiumHireAction(error:int, data:Object, params:Object):void
		{
			if (error) {
				Errors.show(error, data);
				return;
			}
			
			for each(var worker:Object in workers) {
				food = 1;
				trace(data.food - App.time);
				worker.finished = worker.finished + energyObject.duration;
				worker.worker.finished = worker.worker.finished + energyObject.duration;
			}
			
			energyObject = null;
		}
		
		override public function addGround():void {
			
		}
		
		override public function putAction():void {
			if (!stockable) {
				return;
			}
			if (ban) return;
			
			uninstall();
			if (sid == 752) {
				App.user.stock.add(sid, { lvl: this.level - 1, cnt:1 } );
			}
			else {
				App.user.stock.add(sid, 1);
			}
			
			Post.send( {
				ctr:this.type,
				act:'put',
				uID:App.user.id,
				wID:App.user.worldID,
				sID:this.sid,
				id:this.id,
				lvl:this.level - 1
			}, function(error:int, data:Object, params:Object):void {
					
			});
		}
		
		override protected function onStockAction(error:int, data:Object, params:Object):void {
			if (error) {
				return;
			}
			hasUpgraded = false;
			hasBuilded = true;
			upgradedTime = App.time - 1000;
			App.self.setOnTimer(upgraded);
			
			this.id = data.id;
			
			App.ui.glowing(this);
			World.addBuilding(this.sid);
			onAfterStock();
			
			if (sid == 752) {
				ban = true;
				App.self.setOnTimer(stockBan);
			}
			//super.onStockAction(error, data, params);
			/*hasUpgraded = false;
			hasBuilded = true;
			upgradedTime = App.time - 1000;
			App.self.setOnTimer(upgraded);*/
			
			/*this.level++;
			load();*/
		}
		
		private var second:int = 0;
		private var ban:Boolean = false;
		private function stockBan():void {
			second++;
			if (second >= 10) {
				ban = false;
				App.self.setOffTimer(stockBan);
				second = 0;
			}
		}
		
		public function addWorker(id:int, finished:uint):Techno {
			var worker:*;
			if (sid == 752) {
				var workerSID:uint;
				if (id == 0)  workerSID = Techno.BOLIK;
				else workerSID = Techno.LELIK;
				
				worker = Unit.add( {
					sid:	workerSID,
					id:		id,
					x:		coords.x + cells,
					z:		coords.z + rows,
					finished:		finished,
					hut:this
				});
				worker.goHome();
				return worker;
			}
			
			var workerCells:int = coords.x + cells;
			var workerRows:int = coords.z + rows;
			
			while (App.map._aStarNodes.length <= workerCells && workerCells > 0)
				workerCells--;
			
			while (App.map._aStarNodes[workerCells].length <= workerRows && workerRows > 0)
				workerRows--;
			
			worker = Unit.add( {
				sid:			Techno.TECHNO,
				id:				id,
				x:				workerCells,
				z:				workerRows,
				finished:		finished,
				hut:			this
			});
			//worker.goHome();
			return worker;
		}
		
		//public function get hutType():uint {
			//// Домик Клайда
			//if (sid == 278)
				//return KLIDE_HOUSE;
			//
			//return 0;
		//}
		
		public function openUpgradeWindow(sidKettle:int = 0):void {
			//clearIcon();
			
			new ConstructWindow({
				mode:ConstructWindow.UPGRADE,
				title:			info.title,
				upgTime:		info.devel.req[level + 1].t,
				request:		info.devel.obj[level + 1],
				reward:			{},//info.devel.rew[level + 1],
				target:			this,
				win:			this,
				timeWorkLabel:  Locale.__e("flash:1425658487183"),
				onUpgrade:		upgradeEvent,
				hasDescription:	true,
				sidKettle:		sidKettle
			}).show();
		}
		
		override public function openConstructWindow():Boolean 
		{
			if((level == 0 || (sid == 461 && level < 2)) && sid != KLIDE_HOUSE) {
				if (App.user.mode == User.OWNER)
				{
					if (hasUpgraded)
					{
						//setFlag(Cloud.CONSTRUCTING);
						drawIcon(UnitIcon.BUILD, null);
						
						new ConstructWindow( {
							title:			info.title,
							upgTime:		info.devel.req[level + 1].t,
							request:		info.devel.obj[level + 1],
							reward:			{},//info.devel.rew[level + 1],
							target:			this,
							win:			this,
							onUpgrade:		upgradeEvent,
							hasDescription:	true
						}).show();
						
						return true;
					}
				}
			}
			return false;
		}
		
		override public function onBonusEvent(error:int, data:Object, params:Object):void 
		{
			if (error) {
				Errors.show(error, data);
				return;
			}
			
			//sendPresent = false;
			removeEffect();
			showIcon();
			
			if (sid == 752) {
				this.level = data.level;
				updateLevel();
			}
			
			if (sid == 461) {
				this.level = data.level;
				load();
			}
			
			addWorkers(data.workers);
		}	
		
		public function onMapComplete(e:AppEvent = null):void {
			App.self.removeEventListener(AppEvent.ON_MAP_COMPLETE, onMapComplete);
			
			// Поиск работников на карте и добавление их в списки
			var sids:Array = [Techno.TECHNO, 277];
			/*for (var infoSid:* in info.outs)
				sids.push(int(infoSid));*/
			
			var unitList:Array = Map.findUnits(sids);
			for (var j:int = 0; j < unitList.length; j++) {
				if (sid == KLIDE_HOUSE) {
					if (unitList[j].sid != Stock.TECHNO || (unitList[j].sid == Stock.TECHNO && unitList[j].capacity > 0)) {
						workers[unitList[j].id] = { };
						workers[unitList[j].id]['worker'] = unitList[j];
						workerUnits.push(unitList[j]);
					}
				}else {
					for (var s:* in workers) {
						if (unitList[j].sid == workers[s].sid && unitList[j].id == workers[s].id) {
							workers[s].worker = unitList[j];
							workerUnits.push(unitList[j]);
							
							// Обновить время конца работы
							unitList[j].ended = unitList[j].created + info.time;
						}
					}
				}
			}
			unitList = null;
			
			// Таймер удаления работников
			App.self.setOnTimer(checkWorkerToRemove);
		}
		
	
		public function addWorkers(_workers:Object):void 
		{
			for (var w_id:* in _workers) {
				if (workers.hasOwnProperty(w_id))
					continue;
				
				var pers:Object = _workers[w_id];
				pers['id'] = w_id;
				if (pers.finished == 0)
					pers.finished = 1;
				pers['worker'] = addWorker(pers.id, pers.finished);
				workers[w_id] = pers;
			}
		}
		
		/**
		 * Удаление и увольнение работника
		 */
		public function removeWorker(worker:Techno):void {
			worker.uninstall();
		}
		public function removeWorkers():void {
			for (var w_id:* in workers) {
				var pers:Object = workers[w_id];
				removeWorker(pers.worker);
			}
			
			workers = null;
		}
		
		private function addTip():void
		{
			tip = function():Object {
				return {title: info.title, text: info.description}
			}
		}
		
		private function checkWorkerToRemove():void {
			for (var i:int = 0; i < workerUnits.length; i++) {
				if (sid == KLIDE_HOUSE) {
					if (workerUnits[i].capacity > 0 && workerUnits[i].capacity > App.time) 
						trace('Нужно удалить временного рабочего');
				}else if (workerUnits[i].created + info.time < App.time) {
					removeWorker(workerUnits[i]);
				}
			}
		}
		
		override public function onLoad(data:*):void {
			super.onLoad(data);
			
			updateLevel();
		}
		
		/**
		 * Нанять рабочего
		 * @param	params
		 */
		private var hireCallback:Function;
		public function hire(energy:int = 0, friends:Array = null, buy:Boolean = false, callback:Function = null):void {
			if (!friends) friends = [];
			hireCallback = callback;
			
			App.user.stock.take(cost, energy);
			//App.user.stock.take(Stock.FOOD, energy);
			//if (hutType != 0 || Numbers.countProps(workers) >= workerCount) return;
			
			Post.send( {
				ctr:	info.type,
				act:	'feed',
				uID:	App.user.id,
				wID:	App.user.worldID,
				sID:	this.sid,
				id:		id,
				energy:	energy,
				ids:	JSON.stringify(friends), 
				buy:	int(buy)
			}, onHireAction);
		}
		
		public function onHireAction(error:int, data:Object, params:Object):void
		{
			if (error) {
				Errors.show(error, data);
				return;
			}
			
			food = 0;
			for each(var worker:Object in workers) {
				worker.finished = data.finished;
				worker.worker.finished = data.finished;
			}
		}
		
		override protected function onBuyAction(error:int, data:Object, params:Object):void
		{
			if (error) {
				Errors.show(error, data);
				return;
			}
			
			id = data.id;
			
			addTip();
			var hasTechno:Boolean = false;
			var techno:Array = [];
			var reward:Object = info.outs;
			var _reward:Object = {};
			
			Treasures.bonus(Treasures.convert(_reward), new Point(this.x, this.y));
			
			removeEffect();
			
			openConstructWindow();
		}
		
		public function fireEvent(workerID:int, callback:Function = null):void {
			Post.send( {
				ctr:this.type,
				act:'fire',
				uID:App.user.id,
				wID:App.user.worldID,
				sID:this.sid,
				id:this.id,
				tID:workerID
			}, function(error:int, data:Object, params:Object = null):void {
					if (error) {
						Errors.show(error, data);
						return;
					}
					
					if (callback != null) callback();
				}
			);
		}
		
		public function getNearPosition():Object
		{
			var object:Object = {x: info.area.w + 1, z: info.area.h - 1};
			var tries:int = 50;
			
			while (true)
			{
				var _object:Object = find();
				if (App.map._aStarNodes[_object.x] && App.map._aStarNodes[_object.x][_object.z] && !App.map._aStarNodes[_object.x][_object.z].object && App.map._aStarNodes[_object.x][_object.z].open == true)
				{
					return _object;
				}
				
				tries--;
				if (tries <= 0)
					break;
			}
			
			function find():Object
			{
				var _x:int = coords.x - 5 + int(Math.random() * (info.area.w + 10));
				var _y:int = coords.z - 5 + int(Math.random() * (info.area.h + 10));
				
				return {x: _x, z: _y}
			}
			
			return object;
		}
		
		override public function openProductionWindow(settings:Object = null):void {
			if (sid == KLIDE_HOUSE) {
				/*new HutWindow( {
					target:		this,
					sID:		Techno.TECHNO,
					state:		KLIDE_HOUSE
				}).show();*/
				/*if (App.isSocial('FB')) {
					if (InfoWindow.info.hasOwnProperty(32)) {
						new InfoWindow( {
							qID:32,
							callback:onKlideClick
							} ).show();
					}
				} else {*/
					onKlideClick();
				//}
			}else if (!workers[0] && info.devel.req.hasOwnProperty(level + 1)) {
				if (App.user.mode == User.OWNER)
				{
					if (hasUpgraded)
					{
						drawIcon(UnitIcon.BUILD, null);
						
						new ConstructWindow( {
							title:			info.title,
							upgTime:		info.devel.req[level + 1].t,
							request:		info.devel.obj[level + 1],
							reward:			{},//info.devel.rew[level + 1],
							target:			this,
							win:			this,
							onUpgrade:		upgradeEvent,
							hasDescription:	true
						}).show();
						
						return;
					}
				}
			} else {
				if (Numbers.countProps(workers) > 0) {
					for (var s:* in workers) {
						if (workers[s].finished > App.time) {
							new HutWindow( {
								target:		this,
								sID:		Techno.TECHNO
							}).show();
							return;
						}
					}
				}
				
				// Кормление
				openHireWindow();
			}
		}
		
		public function openHireWindow():void {
			// Если наемникик работают за МОНЕТЫ
			if (cost == Stock.COINS) {
				new HutHireMoneyWindow( {
					target:		this,
					sID:		Techno.TECHNO
				}).show();
			}else{
				new HutHireWindow( {
					target:		this,
					sID:		Techno.TECHNO
				}).show();
			}
		}
		
		private function onKlideClick(e:MouseEvent = null):void {
			if (!App.user.quests.data.hasOwnProperty(216)) {
				new SimpleWindow( {
					title: Locale.__e('storage:278:title'),
					text: Locale.__e('flash:1435130693238'),
					textSize: 32
				}).show();
				return;
			}
			var sID:int = KLIDE_WORLD;
			if (!App.user.worlds.hasOwnProperty(sID)) {
				if (App.data.storage[sID].hasOwnProperty('require') && Numbers.countProps(App.data.storage[sID].require) > 0) {
					new TravelRequireWindow ( {
						sIDmap: sID,
						description: Locale.__e('flash:1432032135047'),
						callback: function():void {
							App.user.world.openWorld(sID, false, function():void {
								onKlideClick(e);
							});
						}
					}).show();
				}else {
					App.user.world.openWorld(sID, false, function():void {
						onKlideClick(e);
					});
				}
				return;
			}
			Travel.goTo(sID);
		}
		
		//override public function storageEvent(value:int = 0):void
		//{
			//if (technoToDelete.length == slaveCount)
			//{
				//for (var i:int = 0; i < technoToDelete.length; i++)
				//{
					//technoToDelete[i].remove;
				//}
				//
				//Post.send( {
					//ctr: info.type, 
					//act: 'reward',
					//uID: App.user.id,
					//id: id,
					//wID: App.user.worldID,
					//sID: this.sid
				//}, onStorageEvent);
			//}
		//}
		//
		//override public function onStorageEvent(error:int, data:Object, params:Object):void
		//{
			//if (error)
			//{
				//Errors.show(error, data);
				//return;
			//}
			//this.visible = false;
			//hasProduct = false;
			//
			//var outs:Object = Treasures.convert(info.outs)
			//Treasures.bonus(data.bonus, new Point(this.x, this.y));
			//uninstall();
		//}
		
		/*override public function calcState(node:AStarNodeVO):int
		{
			var state:uint = EMPTY;
			base = 0;
			for (var i:uint = 0; i < cells; i++)
			{
				for (var j:uint = 0; j < rows; j++)
				{
					node = App.map._aStarNodes[coords.x + i][coords.z + j];
					if (node.b != 0 || node.open == false)
					{
						state = OCCUPIED;
						
						break;
					}
				}
			}
			if (state == EMPTY)
				base = 0;
			
			if (state == OCCUPIED)
			{
				state = EMPTY;
				for (i = 0; i < cells; i++)
				{
					for (j = 0; j < rows; j++)
					{
						if (node.w != 1 || node.object != null || node.open == false)
						{
							state = OCCUPIED;
							break;
						}
					}
				}
				if (state == EMPTY)
					base = 1;
			}
			
			return state;
		
		}*/
		
		/*public function addLevel():void
		{
			var levelData:Object = textures.sprites[1];
			draw(levelData.bmp, levelData.dx, levelData.dy);
			
			if (textures.hasOwnProperty('animation'))
			{
				addAnimation();
				startAnimation(true);
			}
		}*/
		
		/*public function addSlaves():void
		{
			var levelData:Object = textures.sprites[1];
			draw(levelData.bmp, levelData.dx, levelData.dy);
			
			if (textures.hasOwnProperty('animation'))
			{
				addAnimation();
				startAnimation(true);
			}
		}*/
		
		public var mode:int = -1;
		override public function updateLevel(checkRotate:Boolean = false, mode:int = -1):void
		{
			if (mode != -1) this.mode = mode;
			if (level > totalLevels) {
				level = totalLevels;
			}
			
			if (textures == null)
				return;
			
			var levelData:Object;
			if (mode == -1) 
			{
				levelData = textures.sprites[level];
			} else
			{
				levelData = textures.sprites[mode];
			}
			
			if (levelData == null)
			{
				if (mode == -1)
					levelData = textures.sprites[0];
				else
					levelData = textures.sprites[mode];
			}
			
			if (checkRotate && rotate == true) {
				flip();
			}
			
			draw(levelData.bmp, levelData.dx, levelData.dy);
			
			checkOnAnimationInit();
		}
		
		override public function checkOnAnimationInit():void
		{
			if (textures && textures['animation']) {
				if (level == totalLevels - craftLevels)
				{
					initAnimation();
					beginAnimation();
				}
				if (crafted == 0)
				{
					finishAnimation();
				}
			}
			
			if (mode == 1) 
				startSmoke();
			else 
				stopSmoke();
			
		}
		
		override public function can():Boolean {
			if (hasBusyWorkers) return true;
			
			return super.can();
		}
		
		override public function click():Boolean
		{
			if (App.user.mode == User.GUEST) {
				guestClick();
				return true;
			}
			
			if (!isReadyToWork()) return true;
			
			//if (isBuilded()) return true;
			
			if (isPresent()) return true;
			
			if (openConstructWindow()) return true;
			
			openProductionWindow();
			
			return true;
		}
		
		override public function setCraftLevels():void {
			craftLevels = 2;
		}
		
		override public function uninstall():void {
			App.self.setOffTimer(checkWorkerToRemove);
			removeWorkers();
			finishAnimation();
			stopSmoke();
			super.uninstall();
		}
		
		override public function remove(callback:Function = null):void {
			
			// Есть занятые рабочие
			if (hasBusyWorkers) {
				new SimpleWindow( {
					title:		info.title,
					text:		Locale.__e('flash:1422975897516')
				}).show();
				return;
			}
			
			super.remove(callback);
		}
		
		public function get hasBusyWorkers():Boolean {
			for (var s:* in workers) {
				if (workers[s].worker.workStatus == WorkerUnit.BUSY && workers[s].worker.target)
					return true;
			}
			
			return false;
		}
		
		public function get cost():uint {
			if (info['require']) {
				for (var s:* in info.require) {
					if (App.data.storage[s])
						return int(s);
				}
			}
			
			return Stock.FOOD;
		}
	}
}