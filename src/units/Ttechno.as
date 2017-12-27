package units 
{
	import astar.AStarNodeVO;
	import com.greensock.easing.Strong;
	import com.greensock.TweenLite;
	import core.Load;
	import core.Post;
	import core.TimeConverter;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filters.BlurFilter;
	import flash.geom.Point;
	import flash.utils.clearInterval;
	import flash.utils.clearTimeout;
	import flash.utils.setInterval;
	import flash.utils.setTimeout;
	import flash.utils.Timer;
	//import ui.AnimalCloud;
	import ui.ProgressBar;
	import wins.FurryWindow;
	import wins.HeroWindow;
	import wins.PurchaseWindow;
	import wins.SimpleWindow;
	import wins.Window;
	/**
	 * ...
	 * @author 
	 */
	public class Ttechno extends WorkerUnit
	{
		public static const TECHNO:uint = 2413;
		public static const RES_TECHNO:uint = 2540;
		public static const TECHNO_ANIMATIONS:Array = new Array( 'cut', 'fish', 'mine', 'rest', 'rest1', 'stop_pause', 'walk' );
		
		public var capacity:int = -1;
		public var targetObject:Object = null;
		
		public var countCap:int = -1;
		public var _wigwam:Boolean = false;
		public var progressBar:ProgressBar;
		
		public function Ttechno(object:Object)
		{
			onPathComplete = function():void { prevCoords = coords; moveAction() };
			super(object);
			
			info['area'] = {w:1, h:1};
			cells = rows = 1;
			velocities = [0.1];
			
			removable = false;
			
			if (object.capacity && (App.user.mode != User.GUEST)) capacity = object.capacity;
			if (object.hasOwnProperty('created')) this.created = object.created;
			
			if (object.finished) {
				targetObject = { };
				targetObject['sid'] = object.rID;
				targetObject['id'] = object.mID;
				prevCoords = Hut.homeCoords(object.rID).coords;
				finished = object.finished;
			}
				
			if(!object.hasOwnProperty('spirit')){
				App.user.techno.push(this);
				App.ui.upPanel.update();
			}
			defaultStopCount = 2;
			
			
				if (capacity >= 0 && (App.user.mode != User.GUEST)) { id
					if (created > 0 && App.time < created + App.data.options.buyedTechnoTime) {
						
					} else {
						//addTimerToDeath();
						App.self.setOnTimer(addTimerToDeath);
					}
				}
			
				
			tip = function():Object {
				
				var status:String = Locale.__e("flash:1394010518091");
				if (workStatus == BUSY)
					status = Locale.__e("flash:1394010372134");
					
				if (finished > 0) {
					status = Locale.__e("flash:1470306202155") + " " + TimeConverter.timeToStr(finished - App.time);
				}
				
				if (created > 0) {
					status = Locale.__e("flash:1470306202155")+" " + TimeConverter.timeToStr(created + App.data.options.buyedTechnoTime - App.time);
				}
				
				if (workEnded > 0 && workEnded > App.time) {
					status = Locale.__e("flash:1470306202155") + " " + TimeConverter.timeToStr(workEnded - App.time);
				}
				
				if (capacity >= 0) {
					var countToDelete:Number = capacity - App.time;
					if (countToDelete>0) 
					{
						status = Locale.__e("flash:1427874686387")+" " + TimeConverter.timeToStr(capacity - App.time);
					}else 
					{
						//status = Locale.__e("flash:1393581955601")
					}
					
				}
				
				if (hasProduct)
					status = Locale.__e("flash:1416924639077");
					
				return {
					title:info.title,
					text:status,
					timer:true
				}
			}
			
			if (_opening) {
				//opening();
			}else{
				//App.self.addEventListener(AppEvent.ON_GAME_COMPLETE, onGameComplete)
				if (object.fromStock) {
					moveable = true;
				}else{
					App.self.addEventListener(AppEvent.ON_MAP_COMPLETE, onGameComplete);
				}
			}
			moveable = true;
			
			App.self.addEventListener(AppEvent.ON_MOUSE_UP, onUp);
		}
		
		private function addTimerToDeath():void {	
			if (App.user.mode == User.GUEST) return; id
			
			var wigwamOnMap:Array = Map.findUnitsByType(['Wigwam']);
			var toRemove:Boolean = true;
			for (var i:int = 0; i < wigwamOnMap.length; i++) {
				for each (var worker:* in wigwamOnMap[i].workers) {
					if (worker == this.id) {
						toRemove = false;
						continue;
						
					}
				}
				
			}
			if (created > 0 && created + App.data.options.buyedTechnoTime < App.time && toRemove) {
				if (workStatus != WorkerUnit.BUSY) {
					workStatus = WorkerUnit.BUSY;
					visible = false;
					removable = true;
					remove();
					
					App.self.setOffTimer(addTimerToDeath);
				}
			}else {
				
			}
		}
				
		private var _opening:Boolean = false;
		private function opening():void {
			workStatus = BUSY;
			_opening = true;
			framesType = 'opening';
		}
		
		public function showOpen():void {
			_opening = false;
			framesType = 'opening';
			addAnimation();
			if(shadow)shadow.visible = true;
		}
		
		override public function addAnimation():void
		{
			if (_opening) {
				framesType = 'opening';
				update();
				return;
			}
				
			if(textures)
				super.addAnimation();	
		}
		
		override public function createShadow():void 
		{
			super.createShadow();
			
			if (_opening)
				shadow.visible = false;
		}
		
		private var contLight:LayerX;
		private function showBorders():void 
		{
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
		
		override public function beginLive():void {
		
		}
		
		
		override public function free():void {
			showBorders();
			super.free();
		}
		
		private function onUp(e:AppEvent):void 
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
		
		private var isMoveThis:Boolean = false;
		public static var isMove:Boolean = false;
		private var intervalMove:int;
		
		override public function onDown():void 
		{
			if (workStatus == BUSY) return;
			
			if (App.user.mode == User.OWNER) {
				if (isMoveThis) {
					clearTimeout(intervalMove);
					isMove = false;
					isMoveThis = false
				}else{
					var that:Ttechno = this;
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
			if(workStatus != BUSY){
				stopWalking();
				onGoHomeComplete();
			}
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
			}else {
				place = findPlaceNearTarget({info:{area:{w:1,h:1}},coords:{x:this.movePoint.x, z:this.movePoint.y}}, homeRadius);
			}
			
			if (targetObject && targetObject.hasOwnProperty('sid') != -1) {
				place = findPlaceNearTarget( { info: { area: { w:1, h:1 }},
							coords: {
								x:Hut.homeCoords(targetObject.sid).coords.x,
								z:Hut.homeCoords(targetObject.sid).coords.z
									}}, homeRadius);
				}
			
			framesType = Personage.WALK;
			initMove(
				place.x,
				place.z,
				onGoHomeComplete
			);
			
		}
		
		public function goToAndHide(target:*, radius:int=2):void 
		{
			stopRest();
			this.target = target;
			workStatus = BUSY;
			jobPosition = findPlaceNearTarget(target, radius);
			
			_move = false;
			
			initMove(
				jobPosition.x, 
				jobPosition.z,
				hideThis
			);
		}
		
			override public function setRest():void {
			var randomID:int = int(Math.random() * rests.length);
			if (rests[randomID] =='rest') 
			{
			randomID = int(Math.random() * rests.length);
			}
			var randomRest:String = rests[randomID];
			restCount = generateRestCount();
			framesType = randomRest;
			startSound(randomRest);
		}
		
		private function hideThis():void 
		{
			this.visible = false;
			stopRest();
		}
		
		override public function click():Boolean
		{
			if (hasProduct) {
				storageEvent();
				return true;
			}
			
			var that:Ttechno = this;
						
			clearTimeout(intervalMove);
			
			if(isMoveThis){
				this.move = false;
				App.map.moved = null;
				isMove = false;
				isMoveThis = false
				return true;
			}
			return true;
		}
		
		private function onGameComplete(e:AppEvent):void {
			App.self.removeEventListener(AppEvent.ON_MAP_COMPLETE, onGameComplete);
			
			if (finished > 0) {
				busy = BUSY;
				prevCoords = Hut.homeCoords(targetObject.sID).coords;
				goHome();
				findResourceTarget();
				return;
			}
			
			if (busy == FREE){
				goHome();
			}
		}
		
		override public function born(settings:Object = null):void 
		{
			this.alpha = 0;
			
			if (settings && settings['capacity'] && (App.user.mode != User.GUEST))
				capacity = settings.capacity;
			
			this.cell = coords.x;
			this.row = coords.z;
			
			if (capacity >= 0 && (App.user.mode != User.GUEST)) {
				addTimerToDeath();
				App.self.setOnTimer(addTimerToDeath);
			}
				
		//	moveAction();
			if (_opening) {
				this.alpha = 1;
				//showOpen();
				return;
			}
				
			var that:Ttechno = this;
			TweenLite.to(this, 1.8, { alpha:1, onComplete:function():void {
				App.map.focusedOn(that, false);
				that.showGlowing();
				setTimeout(function():void{
				that.hideGlowing();
				},5000);
				
				var index:int = App.user.techno.indexOf(that)
				if (index != -1)
					goHome();
			}});
		}
		
		override public function uninstall():void {
			/*if (info && info.hasOwnProperty('ask') && info.ask == true)
			{
			
			}
			else
			{
				var wigwamOnMap:Array = Map.findUnitsByType(['Wigwam']);
				var doNotRemove:Boolean = false;
				for (var i:int = 0; i < wigwamOnMap.length; i++) 
				{
					
						for each (var worker:* in wigwamOnMap[i].workers)
						{
							if (worker == this.id&&wigwamOnMap[i].finished>App.time) 
							{
								doNotRemove = true;
								continue
								
							}
						}
					
				}
				if (!doNotRemove&&this.id!=0&&this.id!=1) 
				{
					//onApplyRemove(callback)
				}else 
				{
					if (!this.visible) 
					{
					visible = true;	
					
					}
					if (_wigwam) 
					{
					_wigwam = false;	
					}
					if (workStatus == BUSY) 
					{
					workStatus	= FREE;
					}
					if (busy == BUSY) 
					{
					busy = FREE;	
					}
					
					return
				}
				
			}*/
			
			var index:int = App.user.techno.indexOf(this)
			if (index != -1)
			App.user.techno.splice(index, 1);
			cell = 0;
			row = 0;
			App.self.removeEventListener(AppEvent.ON_MAP_COMPLETE, onGameComplete);
			
			App.self.removeEventListener(AppEvent.ON_MOUSE_UP, onUp);
			
			super.uninstall();
			App.ui.upPanel.update();
		}
		
		public static function getBusyTechno():uint {
			var count:int = 0;
			for each( var bot:Ttechno in App.user.techno) {
				if (!bot.isFree()) 
				{						
					count ++;
				}				
			}			
			return count;
		}		
		
		public static function freeTechno():Array {
			var result:Array = [];
			for each(var bot:Ttechno in App.user.techno) {
				if (bot.isFree())
					result.push(bot);
			}
			
			return result;
		}
		
		public function isHungry():Boolean {
			return false;
		}
			
		public static function wigwamWaiting():Array 
		{
			var result:Array = [];
			for each(var bot:Ttechno in App.user.techno) {
				if (bot.isWigwam())
					result.push(bot);
			}
			
			return result;
		}
		
		public static function stopBusyTechno():void
		{
			for each(var bot:Ttechno in App.user.techno) {
				
				//bot.workerFree();
				bot.tm.dispose();
			}
		}
		
		override public function onPathToTargetComplete():void
		{
			workStatus = BUSY;
			startJob();
		}
		
		
		public function workerFree():void 
		{
			framesType = STOP;
			workStatus = FREE;
			goHome();
			
		}
		
		public var target:*;
		private var jobPosition:Object;
		public function goToJob(target:*, order:int=0):void {
			stopRest();
			this.target = target;
			workStatus = BUSY;
			jobPosition = target.getTechnoPosition(order);
			
			_move = false;
			
			initMove(
				jobPosition.x, 
				jobPosition.z,
				startWork
			);
			App.self.dispatchEvent(new AppEvent(AppEvent.ON_TECHNO_CHANGE));
		}
		
		/**
		 * Выполняем действие
		 */
		
		public function startJob():void
		{
	
			var jobTime:int = tm.currentTarget.target.info.jobtime;
			if (jobTime <= 0) jobTime = 2;
			if (progressBar == null) {
				progressBar = new ProgressBar(jobTime, 110);
			}
			
			if (tm.currentTarget == null) {
				return;
			}
			
			if (tm.currentTarget.onStart)	
				tm.currentTarget.onStart();
			
//			framesType = tm.currentTarget.event;
			var ft:String = tm.currentTarget.event;
			framesType = ft;
			
			position = tm.currentTarget.jobPosition;
			
			switch(ft) 
			{
				case "gather": 
						progressBar.label = Locale.__e('flash:1382952379925'); 
						SoundsManager.instance.playSFX('harvest', this);
					break;
				case "plant": 
						progressBar.label = Locale.__e('flash:1382952379925'); 
						SoundsManager.instance.playSFX('harvest', this);
					break;
				case "water": 
						progressBar.label = Locale.__e('flash:1382952379925'); 
						SoundsManager.instance.playSFX('water', this);
					break;	
				default : 		
						progressBar.label = Locale.__e('flash:1382952379926'); 
					break;
			}
			
			progressBar.x = x - progressBar.maxWidth / 2; 
			progressBar.y = y - height - 10;
			
			App.map.mTreasure.addChild(progressBar);
			
			progressBar.addEventListener(AppEvent.ON_FINISH, finishJob);
			progressBar.start();
		}
		
		override public function findPath(start:*, finish:*, _astar:*):Vector.<AStarNodeVO> {
			
			var needSplice:Boolean = checkOnSplice(start, finish);
			
			if (App.user.quests.tutorial && tm.currentTarget != null)
				tm.currentTarget.shortcutCheck = true;
				
			if (!needSplice) {
				var path:Vector.<AStarNodeVO> = _astar.search(start, finish);
				if (path == null) 
					return null;
				//if(path[0].coords.x==0){}
				if (workStatus == BUSY && path.length > shortcutDistance) {
					path = path.splice(path.length - shortcutDistance, shortcutDistance);
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
			disposeSparks();
			tm.stop();
			//target = null;
			
			//worldId = 0;
			
		//	if (capacity > 0) capacity-=minusCapasity;
			
			if ((capacity == 0) && (App.user.mode != User.GUEST)) {
				removable = true;
				remove();
			}else {
				goHome();
			}
			App.self.dispatchEvent(new AppEvent(AppEvent.ON_TECHNO_CHANGE));
		}
		
		override public function addTarget(targetObject:Object):Boolean
		{
			if (!targetObject.target.info.kick.hasOwnProperty(App.data.storage[App.user.worldID].cookie[0])) 
			{
				return false
			}
			if(App.user.stock.count(App.data.storage[App.user.worldID].cookie[0])>=targetObject.target.info.kick[App.data.storage[App.user.worldID].cookie[0]]){
				tm.add(targetObject);
				return true;
			} else {
				workerFree();
				targetObject.target.canceled = true;
				//setTimeout(function():void{
				//targetObject.target.reserved = 0;
				//targetObject.target.balance = true;
				//targetObject.target.moveable = true;
				//targetObject.target.move = false;
				//targetObject.target.ordered = false;
				//targetObject.target.redrawCount();
				//},10);
				
				showPurchWnd();
				return false;
			}
		}
		
		public function isFreeForWork():Boolean {
			var wigwams:Array = Map.findUnits([2340, 2414]);
			var hut:Wigwam;
			var exit:Boolean = false;
			for each (var w:Wigwam in wigwams) {
				for each (var worker:* in w.workers) {
					if (worker == this.id) {
						hut = w;
						exit = true;
						break;
					}
				}
				if (exit) break;
			}
			if(workStatus == FREE || (workEnded > 0 && workEnded < App.time && (hut && hut.finished > 0 && App.time < hut.finished) && workStatus != BUSY))
				return true;
			
			return false;	
		}
		
		private function startWork():void {
			
			if (hasProduct) {
				framesType = 'stop_pause';
				return;
			}
			
			if(target && target.hasOwnProperty('targetWorker'))
				target.targetWorker = this;
				
			framesType = jobPosition.workType;
			if (target is Building) {
				//framesType = (Math.random() * 2 > 1)?'craft':'craft1';
				framesType = 'harvest';
			}
			
			position = jobPosition;
			
			//if (capacity > 0) capacity--;
			
			if (jobPosition.workType == Personage.BUILD) {
				startSparks();	
			}
				
			startSound(jobPosition.workType);	
		}
		
		override public function generateStopCount():uint {
			return int(Math.random() * 2) + 1;;
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
		
		public static function nearlestTechno(target:*, bots:Array):Ttechno {
			var resultTechno:Ttechno;
			var dist:int = 0;
			for each(var bot:Ttechno in bots){
				var _dist:int = Math.abs(bot.coords.x - target.coords.x) + Math.abs(bot.coords.z - target.coords.z);
				if (dist == 0 || dist > _dist) {
					dist = _dist;
					resultTechno = bot;
				}
			}
			
			return resultTechno;
		}
		
		public static function nearestTechnos(target:*, bots:Array, count:uint):Array {
			var resultTechnos:Array = [];
			var dist:int = 0;
			for each(var bot:Ttechno in bots){
				var _dist:int = Math.abs(bot.coords.x - target.coords.x) + Math.abs(bot.coords.z - target.coords.z);
				{
					resultTechnos.push( { bot:bot, dist:dist } );	
				}
			}
			
			resultTechnos.sortOn('dist', Array.NUMERIC);
			resultTechnos = resultTechnos.splice(0, count);
			return resultTechnos;
		}
		
		public static function showPurchWnd():void {
			new PurchaseWindow( {
				/*width:560,
				height:320,
				itemsOnPage:3,
				useText:true,
				//shortWindow:true,
				cookWindow:true,
				columnsNum:3,
				scaleVal:1,
				noDesc:true,
				closeAfterBuy:true,
				description:Locale.__e('flash:1393599816743'),
				content:PurchaseWindow.createContent("Energy", { view:['Cookies'] } ),
			//	find:Stock.COOKIE,
				title:App.data.storage[150].title, // 
				//description:Locale.__e("flash:1382952379757"),
				popup: true*/
				
				width:530,
				height:620,
				itemsOnPage:6,
				useText:true,
				//shortWindow:true,
				cookWindow:true,
				shortWindow:true,
				columnsNum:3,
				scaleVal:1,
				noDesc:false,
				closeAfterBuy:false,
				autoClose:false,
				description:Locale.__e('flash:1393599816743'),
				content:PurchaseWindow.createContent("Energy", {view:['slave','Cookies']}),
				title:App.data.storage[150].title, // 
				//description:Locale.__e("flash:1382952379757"),
				popup: true,
				find:0,
				splitWindow:true,
				titleSplit:Locale.__e('flash:1422628903758'),
				descriptionSplit:Locale.__e('flash:1422628646880'),
				itemHeight:220,
				itemWidth:143,
				itemIconScale:0.8,
				offsetY:30
			}).show();
			
		}
		
		public static function takeTechno(needTechno:int, target:*):Array 
		{
			var bots:Array = Ttechno.freeTechno();
			if (bots.length == 0) {
				new PurchaseWindow( {
					width:560,
					height:320,
					itemsOnPage:3,
					useText:true,
					cookWindow:true,
					columnsNum:3,
					scaleVal:1,
					noDesc:true,
					closeAfterBuy:false,
					autoClose:false,
					description:Locale.__e('flash:1422628646880'),
					content:PurchaseWindow.createContent("Energy", {view:['slave']}),
					title:Locale.__e('flash:1422628903758'),
					popup: true,
					callback:function(sID:int):void {
						var object:* = App.data.storage[sID];
						App.user.stock.add(sID, object);
					}
					
				}).show();			
			}
			
			var _technos:Array = Ttechno.nearestTechnos(target, bots, needTechno);
			return _technos;
		}
		
		private var sparksContainer:Sprite;
		private var sparksInterval:int = 0;
		public function startSparks():void 
		{
			if (sparksContainer != null)
				disposeSparks();
			
			sparksContainer = new Sprite();
			addChildAt(sparksContainer, 0);
			generateSpark();
			sparksInterval = setInterval(generateSpark, 1000);
			
			if(framesFlip == 0){
				sparksContainer.x = -50;
				sparksContainer.y = -60;
			}else {
				sparksContainer.scaleX = -1;
				sparksContainer.x = 50;
				sparksContainer.y = -60;
			}
		}
		
		private function generateSpark():void 
		{
			var spark:AnimationItem = new AnimationItem( { type:'Effects', view:'spark', onLoop:function():void {
					spark.dispose();
					if(spark && spark.parent)spark.parent.removeChild(spark);
				}});
				
			var random:int = Math.random();
			if (Math.random() > 0.5)
				spark.scaleX = -1;
			
			sparksContainer.addChild(spark);
			spark.x = int(Math.random() * 50) - 25;
			spark.y = int(Math.random() * 50) - 25;
		}
		
		public static function randomSound(sid:uint, type:String):String {
			if (sounds[sid][type] is Array)
				return sounds[sid][type][int(Math.random() * sounds[sid][type].length)];
			else
				return sounds[sid][type];
		}
		
		
		
		private function disposeSparks():void {
			if (sparksInterval > 0)
				clearInterval(sparksInterval);
				
			if (sparksContainer) {
				removeChild(sparksContainer);
				sparksContainer = null;
			}
		}
		
		override public function startSound(type:String):void {
			
			//if (!SoundsManager.instance.allowSFX) return;
			
			switch(type) {
				case Personage.BUILD:
				//		SoundsManager.instance.addDinamicEffect(sounds['build'], target);
					break;
				case Personage.WORK:
				//		SoundsManager.instance.addDinamicEffect(sounds['work'], target);
					break;
				case 'rest':
				//		SoundsManager.instance.playSFX(sounds['idle1'], this);
					break
				case 'rest2':
				//		SoundsManager.instance.playSFX(sounds['idle2'], this);
					break	
			}
		}
		
		public function stopSound():void {
			SoundsManager.instance.removeDinamicEffect(target);
		}
		
		public static var sounds:Object = {
			build:'robot_4',
			/*idle1:'robot_2',
			idle2:'robot_3',*/
			work:'robot_1'
		}
		
		public var countRes:int = 0;
		//- auto - выбор ресурса, параметры: uID, wID, sID, id (фурии), rID - sid ресурса, mID - id ресурса на карте, count - кол-во ресурса, ответ finished - время окончания работы фуриии
		//- storage - сбор собранных ресурсов, параметры: uID, wID, sID, id фурии, ответ bonus - собранные ресы с кладами
		public function autoEvent(target:Resource, count:int = 1):void {
			countRes = count;
			targetObject = { };
			targetObject['sid'] = target.sid;
			targetObject['id'] = target.id;
			
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
				if(data.hasOwnProperty('rID')){
					targetObject = { };
					targetObject['sid'] = data.rID;
					targetObject['id'] = data.mID;
				}
				
				finished = data.finished;
				busy = BUSY;
				target.busy = 1;
				App.self.setOnTimer(work); countCap = count;
				goToJob(target);
			});
		}
		
		public var finished:uint = 0;
		public function findResourceTarget():void {
			if (target == null) {
				var resource:Resource = Map.findUnit(Hut.getByRecource(targetObject.sid), targetObject.id);
				if (resource != null) {

					target = resource;
					target.busy = 1;
					goToJob(target);
					if (resource.hasOwnProperty('targetWorker'))
						resource.targetWorker = this;
				}
			}else {
				target.busy = 1;
				goToJob(target);
			}
			
			App.self.setOnTimer(work);
			work();
		}
		
		private function work():void {
			if (App.time > finished || App.time > workEnded) {
				App.self.setOffTimer(work);
				//framesType = 'stop_pause';				
				var rID:uint;
				hasProduct = true;
				workStatus = 3;
				if (App.user.mode != User.GUEST)
				capacity = countCap;
				if (target != undefined) {
					rID = target.info.sID
				}else {
					rID = targetObject.sid;
					target = {info:{sID:rID} };
				}

				prevCoords = Hut.homeCoords(rID).coords;
				//targetObject = {}
				//targetObject.sid = rID;
			//	var hID:* = Hut.getByRecource(rID);
				
			//	var ob:* = Map.findUnits([hID])[0];
				//ob = Hut.HUT_INST[hID];
			//	ob.setIcon(rID);
				goHome();
			}
		}
		
		public function isWigwam():Boolean {
			if(_wigwam == true)
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
				//if (cloudAnimal) {
					//cloudAnimal.dispose();
					//cloudAnimal = null;
				//}
			}
		}
		
		public function get hasProduct():Boolean
		{
			return _hasProduct;
		}
		
		public function wigwam(value:Boolean):void 
		{
			_wigwam = value;
			workStatus = BUSY;
			busy = BUSY;
			this.visible = false;
			uninstall();
		}
		
		
		
		public function storageEvent(count:int = 1, tresPoint:Point = null):void {
			
			var rew:Object = { };
			rew[target.info.sid] = countRes;
			
			if (!App.user.stock.takeAll(rew))
				return;
				
			if(target && target.targetWorker)
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
					Treasures.bonus(data.bonus,(tresPoint)?tresPoint:new Point(that.x, that.y));
					//fire(capacity);
				}
				if(target){
					target.busy = 0;
					//target.setCapacity(data.cap);
					target = null;
				}
				finished = 0;
				busy = 0;
			});
		}
		
		//private var cloudAnimal:AnimalCloud;
		private function showIcon(typeItem:String, callBack:Function, mode:int, btmDataName:String = 'productBacking2', scaleIcon:Number = 0.6):void 
		{
			if (App.user.mode == User.GUEST)
				return;
			
			//if (cloudAnimal) {
				//cloudAnimal.dispose();
				//cloudAnimal = null;
			//}
			
			//Hut.setResIcon(target.sid);
			/*cloudAnimal = new AnimalCloud(callBack, this, target.sid, mode, {scaleIcon:scaleIcon});
			cloudAnimal.create(btmDataName);
			cloudAnimal.show();
			cloudAnimal.x = - 30;
			cloudAnimal.y = - 120;
			cloudAnimal.pluck(30);*/
		}
		
		override public function onLoop():void 
		{
			if (_framesType == 'opening') {
				workStatus = FREE;
				var rId:uint = targetObject.sid;
				var hPoint:* = Hut.homeCoords(rId);
				goHome({
					x:hPoint.coords.x-1, 
					z:hPoint.coords.z-1
				});
				//QuestsRules.furryComplete();
				return;
			}
			super.onLoop();
		}
		
		override public function remove(_callback:Function = null):void
		{
			if (App.user.mode == User.GUEST)
				return;
				
			var callback:Function = _callback;
			
			if (info && info.hasOwnProperty('ask') && info.ask == true)
			{
				
				
				if (App.data.storage[info.sID].type == 'Building'&&Map.findUnits([info.sID]).length<=1) {
				
				}else 
				{
				new SimpleWindow({title: Locale.__e("flash:1382952379842"), text: Locale.__e("flash:1382952379968", [info.title]), label: SimpleWindow.ATTENTION, dialog: true, isImg: true, confirm: function():void
					{
						onApplyRemove(callback);
					}}).show();	
				}
			}
			else
			{
				var wigwamOnMap:Array = Map.findUnitsByType(['Wigwam']);
				var doNotRemove:Boolean = false;
				for (var i:int = 0; i < wigwamOnMap.length; i++) 
				{
					
						for each (var worker:* in wigwamOnMap[i].workers)
						{
							if (worker == this.id) 
							{
								doNotRemove = true;
								
							}
						}
					
				}
				if (!doNotRemove && this.id != 0 && this.id != 1) 
				{
					onApplyRemove(callback)
				}
				
			}
		}
	}
}