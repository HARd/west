package units 
{
	import astar.AStarNodeVO;
	import com.greensock.TweenLite;
	import core.Numbers;
	import core.Post;
	import core.TimeConverter;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.utils.clearInterval;
	import flash.utils.clearTimeout;
	import flash.utils.setInterval;
	import flash.utils.setTimeout;
	import flash.utils.Timer;
	import ui.UnitIcon;
	import wins.BuildingWindow;
	import wins.FurryWindow;
	import wins.PurchaseWindow;
	import wins.Window;
	/**
	 * ...
	 * @author 
	 */
	public class Techno extends WorkerUnit
	{
		public static const TECHNO:uint = 161;
		public static const KLIDE:uint = 277;
		public static const ETERNAL_TECHNO:uint = 1529;
		public static const LELIK:uint = 766;
		public static const BOLIK:uint = 765;
		
		public static var lelikBolik:Array;
		
		public static var needFocus:Boolean = true;
		
		public var capacity:int = -1;
		public var targetObject:Object = {};
		public var collector:Collector;
		public var finished:int = 0;
		public var hut:Hut;
		
		public var food:Object = null;
		public var time:int = 0;
		
		public function Techno(object:Object)
		{
			super(object);
			
			ended = object['ended'] || 0;
			info['area'] = {w:1, h:1};
			cells = rows = 1;
			velocities = [0.1];
				
			removable = false;	
			
			if (info.hasOwnProperty('foods') && info.hasOwnProperty('time')) {
				food = info.foods;
				time = info.time;
			}
			
			if (object.hungry) finished = object.hungry;
			
			if(object.capacity) capacity = object.capacity;
			if (object.hut) hut = object.hut;
			
			if (object.finished) {
				finished = object.finished;
			}
			
			// Добавить в глобальный список техно
			technoAdd(this);
			defaultStopCount = 2;
			
			tip = function():Object {				
				if (workEnded > App.time) {
					return {
						title:		info.title,
						text:		Locale.__e('flash:1424966767644') + '\n' + TimeConverter.timeToStr(workEnded - App.time),
						timer:		true
					}
				}
				
				
				var text:String = Locale.__e('flash:1434121794381');
				if (sid == LELIK || sid == BOLIK) text = Locale.__e('flash:1439453773853');
				var timer:Boolean = false;
				
				if (finished > 0) {
					var time:int = finished - App.time;
					if (time < 0) {
						time = 0;
						
					}else {
						text = Locale.__e('flash:1422023870394') + ':\n' + TimeConverter.timeToStr(time);
						timer = true;
					}
				}
				
				if (sid == KLIDE) {
					return {
						title:		info.title,
						text:		info.description
					}
				}
				
				return {
					title:		info.title,
					text:		text,
					timer:		timer
				}
			}
			
			moveable = false;
			if (object.fromStock) {
				moveable = true;
				clickable = true;
				touchable = true;
			}else {
				App.self.addEventListener(AppEvent.ON_MAP_COMPLETE, onGameComplete);
			}
			
			homeRadius = 3;
			
			App.self.addEventListener(AppEvent.ON_MOUSE_UP, onUp);
		}
		
		override public function addAnimation():void {	
			if(textures)
				super.addAnimation();	
		}
		
		private var contLight:LayerX;
		private function showBorders():void 
		{
			return;
			contLight = new LayerX();
			
			var sqSize:int = 30;
			
			var cont:Sprite = new Sprite();
			var sp:Sprite = new Sprite();
			sp.graphics.beginFill(0x89d93c);
			sp.graphics.drawRoundRect(0, 0,400,400,400,400);
			sp.rotation = 45;
			sp.alpha = 0.5;
			
			cont.addChild(sp);
			cont.height = 400 * 0.7;
			
			contLight.addChild(cont);
			
			contLight.y = -contLight.height / 2;
			
			addChildAt(contLight, 0);
		}
		
		override public function take():void {}
		override public function free():void {
			showBorders();
			//super.free();
		}
		
		protected function onUp(e:AppEvent):void 
		{
			if (isMoveThis) {
				this.move = false;
				App.map.moved = null;
				isMove = false;
				isMoveThis = false;
			}
			clearTimeout(intervalMove);
			isMove = false;
			isMoveThis = false;
		}
		
		protected var isMoveThis:Boolean = false;
		public static var isMove:Boolean = false;
		protected var intervalMove:int;
		override public function onDown():void 
		{
			if (workStatus == BUSY) return;
			
			if (App.user.mode == User.OWNER) {
				if (isMoveThis) {
					clearTimeout(intervalMove);
					isMove = false;
					isMoveThis = false
				}else{
					var that:Techno = this;
					intervalMove = setTimeout(function():void {
						isMove = true;
						isMoveThis = true;
						that.move = true;
						App.map.moved = that;
					}, 400);
				}
			}
		}
		
		override public function set touch(touch:Boolean):void
		{
			if (App.user.mode == User.GUEST)
				return;
				
			super.touch = touch;
		}
		
		override public function set move(move:Boolean):void {
			
			if (busy == BUSY)
				return;
			
			super.move = move;
			
			if (!move && isMoveThis)
				previousPlace();
		}
		
		override public function previousPlace():void {
			super.previousPlace();
			
			if (contLight) {
				removeChild(contLight);
				contLight = null;
			}
		}
		
		override public function onMoveAction(error:int, data:Object, params:Object):void 
		{
			if (contLight) {
				removeChild(contLight);
				contLight = null;
			}
			
			if (error) {
				Errors.show(error, data);
				
				free();
				_move = false;
				placing(prevCoords.x, prevCoords.y, prevCoords.z);
				take();
				state = DEFAULT;
				
				//TODO меняем координаты на старые
				return;
			}	
			this.cell = coords.x;
			this.row = coords.z;
			
			movePoint.x = coords.x;
			movePoint.y = coords.z;
			
			goHome();
			
			clearTimeout(intervalMove);
			isMove = false;
			isMoveThis = false
		}
		
		override public function click():Boolean
		{
			if (App.user.mode == User.GUEST) return false;
			
			if (hut != null) 
				hut.click();
			else if (isHungry() && food != null) {
				feedTechno();
			}
			
			return true;
		}
		
		protected function onGameComplete(e:AppEvent):void {
			App.self.removeEventListener(AppEvent.ON_MAP_COMPLETE, onGameComplete);
			
			if (busy == FREE)
				goHome();
		}
		
		override public function born(settings:Object = null):void 
		{
			this.alpha = 1;
			
			if (settings && settings['capacity'])
				capacity = settings.capacity;
			
			this.cell = coords.x;
			this.row = coords.z;
			
			var that:Techno = this;
			TweenLite.to(this, 1.8, { alpha:1, onComplete:function():void {
				if (technoContains(that)) {
					goHome();
				}
			}});
		}
		
		override public function uninstall():void {
			technoClear(this);
			
			if (target && target is Feed) target.uninstall();
			cell = 0;
			row = 0;
			App.self.removeEventListener(AppEvent.ON_MAP_COMPLETE, onGameComplete);
			
			App.self.removeEventListener(AppEvent.ON_MOUSE_UP, onUp);
			clearTimeout(intervalMove);
			
			super.uninstall();
			App.ui.upPanel.update();
		}
		
		public static function getBusyTechno():uint {
			var count:int = 0;
			for each( var bot:Techno in App.user.techno) {
				if (!bot.isFree())
					count ++;
			}
			
			return count;
		}
		
		public static function freeTechno():Array {
			var result:Array = [];
			for each(var bot:* in App.user.techno) {
				if (bot.isFree())
					result.push(bot);
			}
			
			return result;
		}
		
		public static function freeTechnoForWork():Array {
			var result:Array = [];
			for each(var bot:* in App.user.techno) {
				if (bot.isFreeForWork())
					result.push(bot);
			}
			
			return result;
		}
		
		public var collecterBonus:Boolean = false;
		public function setMoneyDone():void
		{
			if (App.user.mode == User.GUEST)
				return;
			
			collecterBonus = true;
		}
		
		public var target:*;
		private var jobPosition:Object;
		public function goToJob(target:*, order:int = 0):void {
			
			if (this.target != null && this.target is Feed) {
				this.target.completeFeedBuyWorker(this);
			}
			
			stopRest();
			this.target = target;
			workStatus = BUSY;
			ordrerPosition = order;
			jobPosition = target.getTechnoPosition(order);
			jobPosition.workType = testHireAniamtion(this, jobPosition.workType);
			
			_move = false;
			
			var place:Object;
			if (App.map._aStarParts[jobPosition.x][jobPosition.z].isWall ) {
				place = findPlaceNearTarget({info:{area:{w:1,h:1}},coords:{x:jobPosition.x, z:jobPosition.z}}, 1);
			}else {
				place = jobPosition;
			}
			
			clearIcon();
			
			initMove(
				place.x, 
				place.z,
				startWork
			);
			App.self.dispatchEvent(new AppEvent(AppEvent.ON_TECHNO_CHANGE));
		}
		
		private var onFeed:Function;
		private var targetAfterFeed:Building = null;
		public function goToFeed(target:*, onFeed:Function):void 
		{
			isTechnoGoingToFeed = true;
			this.onFeed = onFeed;
			stopRest();
			if (this.target is Building) {
				targetAfterFeed = this.target;
			}
			this.target = target;
			jobPosition = target.getTechnoPosition();
			
			_move = false;
			
			var place:Object;
			if (App.map._aStarParts[jobPosition.x][jobPosition.z].isWall ) {
				place = findPlaceNearTarget({info:{area:{w:1,h:1}},coords:{x:jobPosition.x, z:jobPosition.z}}, 1);
			}else {
				place = jobPosition;
			}
			
			initMove(
				place.x, 
				place.z,
				startFeed
			);
			App.self.dispatchEvent(new AppEvent(AppEvent.ON_TECHNO_CHANGE));
		}
		
		private var isTechnoGoingToFeed:Boolean = true;
		override public function checkOnSplice(start:*, finish:*):Boolean {
			if (target is Feed && isTechnoGoingToFeed) {
				isTechnoGoingToFeed = false;
				return true;
			}
			
			return false;
		}
		
		private function startFeed():void {
			
			rotateTo(target);
			
			_framesType = 'eat';
			frame = 0;
		}
		
		override public function findPath(start:*, finish:*, _astar:*):Vector.<AStarNodeVO> {
			var needSplice:Boolean = checkOnSplice(start, finish);
			
			if (App.user.quests.tutorial && tm.currentTarget != null)
				tm.currentTarget.shortcutCheck = true;
				
			if (!needSplice) {
				var path:Vector.<AStarNodeVO> = _astar.search(start, finish);
				if (path == null) 
					return null;
					
				var _shortcutDistance:int = shortcutDistance - int(Math.random() * 3) + 6;
					
				if (workStatus == BUSY && path.length > _shortcutDistance) {
					path = path.splice(path.length - _shortcutDistance, _shortcutDistance);
					placing(path[0].position.x, 0, path[0].position.y);
					alpha = 0;
					TweenLite.to(this, 1, { alpha:1 } );
					return path;
				}else {
					return path;
				}
			}else {
				placing(finish.position.x, 0, finish.position.y);
				cell = finish.position.x;
				row = finish.position.y;
				alpha = 0;
				TweenLite.to(this, 1, { alpha:1 } );
				return null;
			}
			
			return path;
		}
		
		public function fire(minusCapasity:int = 0):void {
			stopSound();
			workStatus = FREE;
			
			if (capacity > 0) capacity-=minusCapasity;
			
			if (capacity == 0) {
				removable = true;
				remove();
			}else {
				goHome();
			}
			App.self.dispatchEvent(new AppEvent(AppEvent.ON_TECHNO_CHANGE));
		}
		
		public var workInterval:int = 0;
		private function startWork():void {
			
			if (hasProduct) {
				framesType = STOP;
				return;
			}
			
			if(target && target.hasOwnProperty('targetWorker'))
				target.targetWorker = this;
			
			framesType = Personage.HARVEST;
			position = jobPosition;
			
			startSound(jobPosition.workType);	
			
			workInterval = setTimeout(pickUpBag, 3000);
		}
		
		private var onPickUpComplete:Function;
		private function pickUpBag():void 
		{
			clearTimeout(workInterval);
			if (workStatus == 0) 
			{
				goHome();
				return;
			}
			
			onPickUpComplete = goToTargetBack;
			framesType = 'carry_bag';
			frame = 0;
		}
		
		public var ordrerPosition:int = 0;
		private function goToTargetBack():void 
		{
			if (target is Feed) 
			{
				if (targetAfterFeed) 
				{
					target.uninstall();
					target = targetAfterFeed;
				}
				else return;
			}
			initMoveOnPath(target.workerPath[ordrerPosition][1], function():void {
				initMoveOnPath(target.workerPath[ordrerPosition][0], startWork);
			}, 'carry');
		}
		
		override public function generateStopCount():uint {
			return int(Math.random() * defaultStopCount) + defaultStopCount;
		}
		
		override public function generateRestCount():uint {
			return int(Math.random() * 2) + 1;
		}
		
		
		
		public function inViewport():Boolean 
		{
			var globalX:int = this.x * App.map.scaleX + App.map.x;
			var globalY:int = this.y * App.map.scaleY + App.map.y;
			
			if (globalX < -10 || globalX > App.self.stage.stageWidth + 10) 	return false;
			if (globalY < -10 || globalY > App.self.stage.stageHeight + 10) return false;
			
			return true;
		}
		
		public static function nearestTechnos(target:*, bots:Array, count:uint):Array {
			var resultTechnos:Array = [];
			var dist:int = 0;
			for each(var bot:Techno in bots){
				var _dist:int = Math.abs(bot.coords.x - target.coords.x) + Math.abs(bot.coords.z - target.coords.z);
				{
					resultTechnos.push( { bot:bot, dist:dist } );	
				}
			}
			
			resultTechnos.sortOn('dist', Array.NUMERIC);
			resultTechnos = resultTechnos.splice(0, count);
			return resultTechnos;
		}
		
		public static function getTechnoById(id:int):Techno
		{
			var techno:Techno;
			for (var i:int = 0; i < App.user.techno.length; i++) 
			{
				techno = App.user.techno[i];
				if (id == techno.id) {
					break;
				}
			}
			return techno;
		}
		
		public static function get count():int {
			return App.user.techno.length;
		}
		
		public static function randomSound(sid:uint, type:String):String {
			if (sounds[sid][type] is Array)
				return sounds[sid][type][int(Math.random() * sounds[sid][type].length)];
			else
				return sounds[sid][type];
		}
		
		
		override public function startSound(type:String):void {
			
			//if (!SoundsManager.instance.allowSFX) return;
			
			switch(type) {
				case Personage.BUILD:
						SoundsManager.instance.addDinamicEffect(sounds['build'], target);
					break;
				case Personage.WORK:
						SoundsManager.instance.addDinamicEffect(sounds['work'], target);
					break;
			}
		}
		
		public function stopSound():void {
			SoundsManager.instance.removeDinamicEffect(target);
		}
		
		public static var sounds:Object = {
			build:'robot_4',
			idle1:'robot_2',
			idle2:'robot_3',
			work:'robot_1'
		}
		
		public var countRes:int = 0;
		//- auto - выбор ресурса, параметры: uID, wID, sID, id (фурии), rID - sid ресурса, mID - id ресурса на карте, count - кол-во ресурса, ответ finished - время окончания работы фуриии
		//- storage - сбор собранных ресурсов, параметры: uID, wID, sID, id фурии, ответ bonus - собранные ресы с кладами
		public function autoEvent(target:Resource, count:int = 1):void {
			countRes = count;
			Post.send( {
				ctr:this.type,
				act:'auto',
				uID:App.user.id,
				wID:App.user.worldID,
				sID:this.sid,
				id:id,
				rID:target.sid,
				mID:target.id,
				count:count
			}, function(error:int, data:Object, params:Object):void{
				if (error) {
					Errors.show(error, data);
					return;
				}
				finished = data.finished;
				busy = BUSY;
				target.busy = 1;
				App.self.setOnTimer(work);
				goToJob(target);
			});
		}
		
		public function findResourceTarget():void {
			var isWork:Boolean = true;
			if (target == null) {
				var resource:Resource = Map.findUnit(targetObject.sid, targetObject.id);
				if (resource != null){
					target = resource;
					target.busy = 1;
					
					if (resource.hasOwnProperty('targetWorker'))
						resource.targetWorker = this;
					
					if (finished > App.time)
						goToJob(target);
				}else {
					busy  = FREE;
					finished = 0;
					isWork = false;
					_hasProduct = false;
				}
			}else {
				target.busy = 1;
				goToJob(target);
			}
			
			if(isWork){
				App.self.setOnTimer(work);
				work();
			}
		}
		
		public function startCollectorWork(targetSid:int, targetId:int, started:int, finished:int):void
		{
			target = Map.findUnit(targetSid, targetId);
			
			if (!target)
				return;
			
			this.finished = finished;
			
			target.furry = this;
			target.colector = collector;
			target.resetStart(started);
			target.removable = false;
			target.moveable = false;
			target.rotateable = false;
			target.stockable = false;
			
			if(target.crafted <= App.time && started < target.crafted)
				collector.doSync(id);
			
			goToJob(target);
			App.self.setOnTimer(work);
			work();
		}
		
		protected function work():void 
		{
			if (App.time > finished) {
				App.self.setOffTimer(work);
				//framesType = 'stop_pause';
				hasProduct = true;
				workStatus = 3;
				
				if(hut)	{
					goHome();
				}else{
					onApplyRemove();
				}
			}
		}
		
		protected var homeCoords:Object;
		public function collectorFinished():void
		{
			target.removable = true;
			target.moveable = true;
			target.rotateable = true;
			workStatus = FREE;
			hasProduct = false;
			target.busy = 0;
			target.colector = null;
			homeCoords = null;
			
			collector = null;
			target = null;
		}
		
		override public function goHome(_movePoint:Object = null):void
		{
			clearTimeout(timer);
			
			if (isRemove)
				return;
			
			if (move) {
				var time:uint = Math.random() * 5000 + 5000;
				timer = setTimeout(goHome, time);
				return;
			}
			
			if (workStatus == BUSY)
				return;
			
			var place:Object;
			if (_movePoint != null) {
				place = _movePoint;
			}else if (homeCoords != null) { 
				place = findPlaceNearTarget({info:homeCoords.info, coords:homeCoords.coords}, homeRadius);
			}else {
				place = findPlaceNearTarget({info:{area:{w:4,h:4}},coords:{x:this.movePoint.x, z:this.movePoint.y}}, homeRadius);
			}
			
			framesType = Personage.WALK;
			initMove(
				place.x,
				place.z,
				onGoHomeComplete
			);
		}
		
		override public function onGoHomeComplete():void 
		{
			super.onGoHomeComplete();
			checkOnHungry();
		}
		
		public function checkOnHungry():Boolean {
			if (isHungry()) { 
				if (hut != null) {
					drawIcon(UnitIcon.HUNGRY, hut.cost, 0);
					if (sid == 461) hut.updateLevel(false);
					else hut.updateLevel(false, 0);
				} else if (food != null) {
					for (var fID:* in food) {
						var count:int = food[fID];
					}
					drawIcon(UnitIcon.HUNGRY, fID, count);
				}
				else uninstall();
				return true;
			}else {
				clearIcon();
				if (hut != null) {
					if (sid == 461) hut.updateLevel(false);
					else hut.updateLevel(false, 1);
				}
				return false;
			}
		}
		
		public function isHungry():Boolean {
			if (finished >= 0 && sid != KLIDE) {
				if (App.time < finished)
					return false;
				else
					return true;
			}
			
			return false;
		}
		
		static public function getHungry():Array {
			var result:Array = [];
			for each(var bot:* in App.user.techno) {
				if (bot.isHungry())
					result.push(bot);
			}
			
			return result;
		}
		
		override public function isFree():Boolean {
			if((workStatus == FREE || (workEnded > 0 && workEnded < App.time)))
				return true;
			
			return false;	
		}
		
		public function isFreeForWork():Boolean {
			if((workStatus == FREE || (workEnded > 0 && workEnded < App.time)) && ((finished == 0 && sid == KLIDE) || (finished > 0 && App.time < finished)))
				return true;
			
			return false;	
		}
		
		private var _hasProduct:Boolean = false;
		
		public function set hasProduct(value:Boolean):void
		{
			_hasProduct = value;
			
			if (_hasProduct) {
				//showIcon('outs', storageEvent, AnimalCloud.MODE_DONE, 'productBacking2', 0.7);
				//goHome();
			}else {
				//
			}
		}
		
		public function get hasProduct():Boolean
		{
			return _hasProduct;
		}
		
		public function storageEvent(count:int = 1):void {
			if (collector) {
				collector.storageCollector(id);
				return;
			}
			
			
			var rew:Object = { };
			rew[target.sid] = countRes;
			
			if(target && target.hasOwnProperty('targetWorker'))
				target.targetWorker = null;
			
			var that:* = this;
			hasProduct = false;
			fire();
			Post.send( {
				ctr:this.type,
				act:'storage',
				uID:App.user.id,
				wID:App.user.worldID,
				sID:this.sid,
				id:id
			}, function(error:int, data:Object, params:Object):void{
				if (error) {
					Errors.show(error, data);
					return;
				}
				if (data.hasOwnProperty("bonus")){
					Treasures.bonus(data.bonus, new Point(that.x, that.y));
					fire(capacity);
				}
				if (target) {
					Capturer.testForCreate(target.coords);
					
					target.busy = 0;
					target.setCapacity(data.cap);
					target = null;
				}
				finished = 0;
				busy = 0;
			});
			
			
		}
		
		public function feedTechno():void {
			if (!App.user.stock.takeAll(food)) return;
			Post.send( {
				ctr:this.type,
				act:'feed',
				uID:App.user.id,
				wID:App.user.worldID,
				sID:this.sid,
				id:id
			}, function(error:int, data:Object, params:Object):void{
				if (error) {
					Errors.show(error, data);
					return;
				}
				
				finished = data.hungry;
				checkOnHungry();
			});
		}
		
		// Добавление и удаление техно
		private static var uiUpdateTimeout:int = 0;
		public static function technoAdd(techno:*):void {
			if (techno.formed && App.user.techno.indexOf(techno) < 0) {
				App.user.techno.push(techno);
				uiUpdate();
			}
		}
		public static function technoClear(techno:*):void {
			if (App.user.techno.indexOf(techno) >= 0) {
				App.user.techno.splice(App.user.techno.indexOf(techno), 1);
				uiUpdate();
			}
		}
		public static function technoContains(techno:*):Boolean {
			return (App.user.techno.indexOf(techno) >= 0) ? true : false;
		}
		private static function uiUpdate(now:Boolean = false):void {
			if (uiUpdateTimeout == 0) {
				uiUpdateTimeout = setTimeout(uiUpdate, 100, true);
			}else {
				clearTimeout(uiUpdateTimeout);
				if (now) {
					uiUpdateTimeout = 0;
					App.ui.upPanel.update();
				}else{
					uiUpdateTimeout = setTimeout(uiUpdate, 100, true);
				}
			}
		}
		
		// Найти рабочего, с минимальным временем работы, который может проработать 
		public static function findTechnosForCraft(fID:*, started:int = 0, target:* = null):* {
			if (!App.data.crafting.hasOwnProperty(fID)) return false;
			
			var craft:Object = App.data.crafting[fID];
			
			if (started <= 0) started = App.time;
			
			if (craft.hasOwnProperty('items')) {
				// Собираем из крафта всех рабочих и их количество
				var workers:Object = { };
				for (var sid:* in craft.items) {
					if (App.data.storage[sid].type == 'Techno' || App.data.storage[sid].type == 'Ttechno')
						workers[sid] = craft.items[sid];
				}
				
				// Если рабочие есть, пытаемся их нанять
				if (Numbers.countProps(workers) > 0) {
					var freeTechnos:Array = freeTechnoForWork();
					// Сортируем по возрастанию, но 0вые ставим в конец
					freeTechnos.sort(workerSorter);
					//App.user.techno.sort(workerSorter);
					
					var klide:Array = [];
					for (var k:int = 0; k < freeTechnos.length; k++) {
						if (freeTechnos[k].finished == 0 && freeTechnos[k].sid == KLIDE) {
							klide = freeTechnos.splice(k, 1);
							freeTechnos.push(klide[0]);
							klide = [];
							//break;
						}
					}
					
					// Готовим рабочих для нанимания
					var preparedWorkers:Array = [];
					for (var wid:* in workers) {
						// Если рабочие уже не нужны
						if (workers[wid] <= 0) continue;
						
						for (var i:int = 0; i < freeTechnos.length; i++) {
							// Если еще нужны рабочие для крафта, они не приготовлены для нанимания, соответствует по сиду, и достаточно времени работы для работы
							if (workers[wid] > 0 && preparedWorkers.indexOf(i) < 0 && /*freeTechnos[i].sid == wid &&*/ (freeTechnos[i].finished == 0 || (freeTechnos[i].finished > 0 && freeTechnos[i].finished > started + craft.time))) {
								workers[wid] --;
								preparedWorkers.push(i);
							}
						}
					}
					
					// Проверка или все нужные рабочие приготовлены
					var complete:Boolean = true;
					for (wid in workers) {
						if (workers[wid] > 0)
							complete = false;
					}
					
					// Создать спикок нанимаемых рабочих
					if (complete) {
						for (i = 0; i < preparedWorkers.length; i++) 
							preparedWorkers[i] = freeTechnos[preparedWorkers[i]];
						
						return preparedWorkers;
					}else {
						// Не достаточно свободных
						var technos:Array = freeTechno();
						var not_enough:int = 0;
						var hungry:int = 0;
						if (technos.length >= craft.items[wid]) {
							/*for (var j:int = 0; j < technos.length; j++) {
								// Если еще нужны рабочие для крафта, они не приготовлены для нанимания, соответствует по сиду, и достаточно времени работы для работы
								trace(isTechnoHungry(technos[j]));
								if ((technos[j].finished > 1 && technos[j].finished < started + craft.time) && !isTechnoHungry(technos[j])) {
									not_enough++;
								} else {
									hungry++;
								}
							}
							if (hungry > 1) {*/
								return 'busy_time';
							/*} else {
								return 'not_enough_time';
							}*/
							
						}
						
						if (count >= craft.items[wid]/* && (lelikBolik && count != lelikBolik.length)*/)
							return 'busy';
						
						return 'not_much';
					}
				}
			}
			
			return [];
			
			function workerSorter(a:*, b:*):int {
				if (a.finished == 0 || a.finished > b.finished) {
					return 1;
				}else if (/*b.finished == 0 || */a.finished < b.finished) {
					return -1;
				}else {
					return 0;
				}
			}
			
			function isTechnoHungry(techno:Object):Boolean {
				if (techno.finished > 0) {
					if (App.time < techno.finished)
						return false;
					else
						return true;
				}
				
				return false;
			}
		}
		
		// Найти рабочего, с минимальным временем работы, который может сходить в инстанс
		public static function findTechnosForWork(time:int, needCount:int, started:int = 0, target:* = null):* {			
			if (started <= 0) started = App.time;
			

				var workers:Object = { };
				workers[Ttechno.TECHNO] = needCount;
				var freeTechnos:Array = freeTechnoForWork();
				freeTechnos.sort(workerSorter);;
					
				var klide:Array = [];
				for (var k:int = 0; k < freeTechnos.length; k++) {
					if (freeTechnos[k].finished == 0 && freeTechnos[k].sid == KLIDE) {
						klide = freeTechnos.splice(k, 1);
						freeTechnos.push(klide[0]);
						klide = [];
					}
				}
					
			// Готовим рабочих для нанимания
			var preparedWorkers:Array = [];
			for (var wid:* in workers) {
				// Если рабочие уже не нужны
				if (workers[wid] <= 0) continue;
				
				for (var i:int = 0; i < freeTechnos.length; i++) {
					// Если еще нужны рабочие для крафта, они не приготовлены для нанимания, соответствует по сиду, и достаточно времени работы для работы
					if (workers[wid] > 0 && preparedWorkers.indexOf(i) < 0 && (freeTechnos[i].finished == 0 || (freeTechnos[i].finished > 0 && freeTechnos[i].finished > started + time))) {
						workers[wid] --;
						preparedWorkers.push(i);
					}
				}
			}
			
			// Проверка или все нужные рабочие приготовлены
			var complete:Boolean = true;
			for (wid in workers) {
				if (workers[wid] > 0)
					complete = false;
			}
			
			// Создать спикок нанимаемых рабочих
			if (complete) {
				for (i = 0; i < preparedWorkers.length; i++) 
					preparedWorkers[i] = freeTechnos[preparedWorkers[i]];
				
				return preparedWorkers;
			}else {
				// Не достаточно свободных
				var technos:Array = freeTechno();
				var not_enough:int = 0;
				var hungry:int = 0;
				if (technos.length >= needCount) {
					return 'busy_time';							
				}
				
				if (count >= needCount)
					return 'busy';
				
				return 'not_much';
			}
			
			return [];
			
			function workerSorter(a:*, b:*):int {
				if (a.finished == 0 || a.finished > b.finished) {
					return 1;
				}else if (a.finished < b.finished) {
					return -1;
				}else {
					return 0;
				}
			}
			
			function isTechnoHungry(techno:Object):Boolean {
				if (techno.finished > 0) {
					if (App.time < techno.finished)
						return false;
					else
						return true;
				}
				
				return false;
			}
		}
		
		public static function setBusy(technoList:Array, target:*, workEndTime:int = 0):void {
			if (workEndTime < App.time) return;
			
			for (var i:int = 0; i < technoList.length; i++) {
				if (technoList[i] is Techno || technoList[i] is Ttechno) {
					if (!technoList[i].targetObject) technoList[i].targetObject = { };
					technoList[i].targetObject.sid = target.sid;
					technoList[i].targetObject.id = target.id;
					technoList[i].workStatus = WorkerUnit.BUSY;
					technoList[i].workEnded = workEndTime;
					technoList[i].goToJob(target, i);
				}
			}
			
			App.ui.upPanel.update();
		}
		
		public static function setFree(target:*):void {
			for (var i:int = 0; i < App.user.techno.length; i++) {
				var techno:* =  App.user.techno[i];
				if (techno.targetObject && techno.targetObject.sid == target.sid && techno.targetObject.id == target.id) {
					techno.workStatus = WorkerUnit.FREE;
					techno.workEnded = 0;
					techno.targetObject = null;
					techno.target = null;
					techno.goHome();
				}
			}
			
			App.ui.upPanel.update();
		}
		
		override public function onLoop():void 
		{
			if (_framesType == 'eat') {
				target.completeFeedBuyWorker(this);
				workStatus = FREE;
				goHome();
				feedComplete();
			}
			
			if (_framesType == 'carry_bag' && onPickUpComplete != null)
				onPickUpComplete();
		}
		
		override public function get formed():Boolean {
			return true;
		}
		
		private function feedComplete():void 
		{
			drawIcon(UnitIcon.SMILE_POSITIVE, null, 0, {
				hiddenTimeout:2000,
				hidden:true
			});
			
			if (targetAfterFeed != null) {
				goToJob(targetAfterFeed, ordrerPosition);
			}
			
			App.ui.upPanel.update();
		}
		
		public static function addWorkers():void {
			if (App.user.worldID == Travel.RIVER && App.user.mode == User.OWNER) { 
				var qID:int = 297;
				if (!App.user.quests.data.hasOwnProperty(qID) || (App.user.quests.data.hasOwnProperty(qID) && App.user.quests.data[qID].finished <= 0))
				{
					Techno.lelikBolik = [];
					var worker:* = Unit.add( {
						sid:	Techno.BOLIK,
						id:		1,
						x:		87,
						z:		92
					});
					worker.framesType = Personage.HARVEST;
					worker.rotateTo( { x:10000 } );
					Techno.lelikBolik.push(worker);
					
					var worker1:* = Unit.add( {
						sid:	Techno.LELIK,
						id:		2,
						x:		85,
						z:		82
					});
					worker1.framesType = Personage.HARVEST;
					worker1.rotateTo( { x:10000 } );
					Techno.lelikBolik.push(worker1);
					
					App.self.addEventListener(AppEvent.ON_DELETE_FAKE_HUT, deleteWorkers);
				}
			}
		}
		
		public static function deleteWorkers(e:*):void {
			App.self.removeEventListener(AppEvent.ON_DELETE_FAKE_HUT, deleteWorkers);
			
			if (Techno.lelikBolik.length == 2) {
				Techno.lelikBolik[0].uninstall();
				Techno.lelikBolik[1].uninstall();
			}
			
			Techno.lelikBolik = [];
		}
	}
}