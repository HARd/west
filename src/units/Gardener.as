package units 
{
	import core.Load;
	import core.Post;
	import core.TimeConverter;
	import flash.geom.Point;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	import wins.FurryWindow;
	/**
	 * ...
	 * @author ...
	 */
	public class Gardener extends WorkerUnit 
	{
		
		public static var waitForTarget:Boolean = false;
		public static var waitWorker:*;
		public static var chooseTargets:Array = [];
		private static var countOfTargets:int = 0;
		
		private var started:int;
		private var finished:int;
		
		public var targets:Array = [];
		public var posibleTargets:Array = [];
		
		public function Gardener(object:Object) 
		{
			super(object);
			
			velocities = [0.05];
			info['area'] = { w:1, h:1 };
			
			moveable = true;
			
			if (object.hasOwnProperty('targets')) {
				for each(var s:Object in object.targets) {
					targets.push(s);
				}
			}
			started = object.started || 0;
			finished = object.finished || 0;
			
			tip = function():Object {
				
				if (started > 0 && App.time < finished) {
					return {
						title:info.title,
						text:TimeConverter.timeToStr(finished - App.time),
						timer:true
					}
				}else {
					return {
						title:info.title,
						text:info.description
					}
				}
			}
			
			for each(var _sid:* in info.targets) {
				posibleTargets.push(_sid);
			}
			
			App.self.addEventListener(AppEvent.ON_MAP_COMPLETE, onMapComplete);
		}
		
		private function onMapComplete(e:AppEvent):void {
			checkStatus();
		}
		private function lockTargets(lock:Boolean = true):void {
			for (var i:int = 0; i < targets.length; i++) {
				for (var s:String in targets[i]) break;
				var unit:* = Map.findUnit(int(s), targets[i][s]);
				if (unit && unit.hasOwnProperty('lock')) {
					unit.lock = lock;
				}
			}
		}
		public function checkStatus():void {
			// Еще работает
			if (started > 0 && App.time <= finished) {
				//showIcon('outs', storageAction, AnimalCloud.MODE_CRAFTING, 'productBacking2', {scaleIcon:0.7, timeDelay:4000, scaleBttn:1, skip:info.skip});
				//cloudAnimal.setProgress(started, finished);
				
				
				startTimer();
				lockTargets();
				
				if (workStatus == FREE) goToJob();
				workStatus = BUSY;
			}
			// Готов. Ожидает сбора
			else if (started > 0 && App.time > finished) {
				//showIcon('outs', storageAction, AnimalCloud.MODE_DONE, 'productBacking2', {scaleIcon:0.7, timeDelay:4000, scaleBttn:1, sid:getOuts()});
				
				workStatus = BUSY;
				lockTargets();
			}
			// Не занят
			else {
				hideIcon();
				lockTargets(false);
				workStatus = FREE;
				targets = [];
				goHome();
			}
		}
		/*private function showIcon(typeItem:String, callBack:Function, mode:int, btmDataName:String = 'productBacking2', params:Object = null):void 
		{
			if (App.user.mode == User.GUEST)
				return;
			
			if (!params) params = { };
			
			hideIcon();
			
			cloudAnimal = new AnimalCloud(callBack, this, (params['sid']) ? params.sid : sid, mode, params);
			cloudAnimal.create(btmDataName);
			cloudAnimal.show();
			cloudAnimal.x = - 30;
			cloudAnimal.y = - 160;
			
			if(mode == AnimalCloud.MODE_DONE)
				cloudAnimal.x = - 30;
			
			cloudAnimal.pluck(30);
		}*/
		private function hideIcon():void {
			/*if (cloudAnimal) {
				cloudAnimal.dispose();
				cloudAnimal = null;
			}*/
		}
		
		private var _timer:Boolean = false;
		private var _collectTimer:int = 15;
		private function startTimer():void {
			if (_timer) return;
			App.self.setOnTimer(workTimer);
		}
		private function stopTimer():void {
			App.self.setOffTimer(workTimer);
			_timer = false;
		}
		public function workTimer():void {
			_collectTimer ++;
			if (_collectTimer > 15) {
				treeCollect();
				_collectTimer = 0;
			}
			
			if (started > 0 && App.time > finished) {
				stopTimer();
				checkStatus();
			}
		}
		private function treeCollect():void {
			for (var i:int = 0; i < targets.length; i++) {
				for (var s:String in targets[i]) break;
				var unit:* = Map.findUnit(int(s), targets[i][s]);
				if (unit) {
					if (unit is Fplant && unit.hasProduct) {
						unit.hasProduct = false;
						if (unit.info.duration > 0) {
							while (unit.started < App.time) unit.started = unit.started + unit.info.duration;
						}
						App.self.setOnTimer(unit.work);
						if (unit.cloudAnimal) {
							unit.cloudAnimal.dispose();
							unit.cloudAnimal = null;
						}
					}
				}
			}
		}
		private function treeStart():void {
			for (var i:int = 0; i < targets.length; i++) {
				for (var s:String in targets[i]) break;
				var unit:* = Map.findUnit(int(s), targets[i][s]);
				if (unit) {
					if (unit is Fplant && unit.info.duration > 0) {
						unit.started = App.time + unit.info.duration;
						App.self.setOnTimer(unit.work);
					}
				}
			}
		}
		
		
		
		private function getOuts():int {
			var value:int = 3;
			for each(var object:Object in targets) {
				for (var _id:* in object) break;
				for (var out:* in App.data.storage[_id].outs) value = int(out);
			}
			return value;
		}
		
		override public function load():void
		{
			if (preloader) addChild(preloader);
			Load.loading(Config.getSwf(info.type, info.view), onLoad);
		}
		
		override public function onLoad(data:*):void {
			super.onLoad(data);
			goHome();
		}
		
		
		override public function click():Boolean
		{
			if (App.user.mode == User.GUEST)
				return true;
			
			
			if (started > 0 && App.time <= finished) {
				if (workStatus == BUSY && targets.length > 0) {
					new FurryWindow({
						title:info.title,
						info:info,
						mode:FurryWindow.FURRY_GARDENER,
						target:this,
						possibleTargets:[],
						bttnText:Locale.__e('flash:1416402563112')
					}).show();
				}
			}else if (started > 0 && App.time > finished) {
				storageAction();
			}else {
				countOfTargets = info.count;
				
				new FurryWindow({
					title:info.title,
					info:info,
					mode:FurryWindow.FURRY_GARDENER,
					target:this,
					possibleTargets:possibleTargets,
					bttnText:Locale.__e('flash:1416306272834')
				}).show();
			}
			
			return true;
		}
		
		override public function set touch(touch:Boolean):void {
			if (touch && started > 0 && App.time < finished) {
				/*showIcon('outs', storageAction, AnimalCloud.MODE_CRAFTING, 'productBacking2', {scaleIcon:0.7, timeDelay:4000, scaleBttn:1, skip:info.skip});
				cloudAnimal.setProgress(started, finished);*/
			}
			
			super.touch = touch;
		}
		
		public function get possibleTargets():Array {
			var array:Array = [];
			for each(var s:* in info.targets) {
				if (array.indexOf(int(s)) == -1) array.push(int(s));
			}
			return array;
		}
		
		// Назначить объекты на сбор
		public function tie(targets:Array = null):void {
			if (!targets) targets = [];
			if (targets.length == 0) return;
			
			for (var i:int = 0; i < targets.length; i++) {
				this.targets.push(targets[i]);
			}
			
			Post.send({
				ctr:this.type,
				act:'tie',
				uID:App.user.id,
				id:this.id,
				wID:App.user.worldID,
				sID:this.sid,
				targets:JSON.stringify(targets)
			}, onTieEvent);
		}
		private function onTieEvent(error:int, data:Object, params:Object):void 
		{
			if (error)
			{
				Errors.show(error, data);
				return;
			}
			
			started = data.started;
			finished = data.finished;
			
			checkStatus();
			goToJob();
			treeStart();
		}
		
		
		public function storageAction():void {
			//if (!App.user.stock.canTake(animal.info.outs)) return;
			
			Post.send({
				ctr:this.type,
				act:'storage',
				uID:App.user.id,
				id:this.id,
				wID:App.user.worldID,
				sID:this.sid
			}, onStorageEvent);
		}
		private function onStorageEvent(error:int, data:Object, params:Object):void 
		{
			if (error)
			{
				Errors.show(error, data);
				return;
			}
			
			started = App.time;
			finished = App.time + info.duration;
			
			if (data.hasOwnProperty('bonus'))
				Treasures.bonus(data.bonus, new Point(this.x, this.y));
			
			if (data.hasOwnProperty('reward'))
				Treasures.bonus(Treasures.convert(data.reward), new Point(this.x, this.y));
			
			treeStart();
			checkStatus();
		}
		
		
		public function unbindAction():void {
			//if (!App.user.stock.canTake(animal.info.outs)) return;
			
			Post.send({
				ctr:this.type,
				act:'unbind',
				uID:App.user.id,
				id:this.id,
				wID:App.user.worldID,
				sID:this.sid
			}, onUnbindAction);
		}
		private function onUnbindAction(error:int, data:Object, params:Object):void 
		{
			if (error) {
				Errors.show(error, data);
				return;
			}
			
			started = 0;
			finished = 0;
			
			checkStatus();
		}
		
		
		public function onBoostEvent(count:int = 0):void {
			if (!App.user.stock.take(Stock.FANT, info.skip)) return;
			
			var self:Gardener = this;
			
			Post.send({
				ctr:this.type,
				act:'boost',
				uID:App.user.id,
				id:this.id,
				wID:App.user.worldID,
				sID:this.sid
			}, function(error:*, data:*, params:*):void {
				
				if (error) {
					Errors.show(error, data);
					return;
				}
				
				started = App.time;
				finished = App.time + info.duration;
				treeStart();
				checkStatus();
				
				if (data.hasOwnProperty('bonus'))
					Treasures.bonus(data.bonus, new Point(self.x, self.y));
				
				if (data.hasOwnProperty('reward'))
					Treasures.bonus(Treasures.convert(data.reward), new Point(self.x, self.y));
				
				SoundsManager.instance.playSFX('bonusBoost');
			});
		}
		
		
		public var changeTargetSometime:Boolean = true;
		private var changeTargetTime:int = 30;
		private var changeTargetTimeout:int = 0;
		private var jobPosition:Object;
		private var jobTarget:Object;
		public function goToJob():void {
			if (targets.length == 0) return;
			stopRest();
			
			workStatus = BUSY;
			
			var index:int = Math.floor(Math.random() * targets.length);
			for (var sid:* in targets[index]) break;
			jobTarget = Map.findUnit(int(sid), targets[index][sid]);
			jobPosition = {x:jobTarget.coords.x + jobTarget.cells + 1, z:jobTarget.coords.z + /*jobTarget.rows + */1};
			
			_move = false;
			
			initMove(
				jobPosition.x, 
				jobPosition.z,
				startWork
			);
			
			if (changeTargetSometime && changeTargetTimeout == 0)
				changeTargetTimeout = setTimeout(changeTarget, changeTargetTime * 1000);
		}
		public function changeTarget():void {
			changeTargetTimeout = 0;
			stopRest();
			goToJob();
		}
		private function startWork():void 
		{
			framesType = 'work';
			framesFlip = WUnit.LEFT;
			bitmap.scaleX = 1;
			sign = 1;
		}
		
		// Добавить объект во временный список
		public static var clickCounter:int = 0;
		public static function addTarget(target:*):void {
			
			if (waitWorker.posibleTargets.indexOf(target.sid) == -1) return;
			
			if (waitForTarget && chooseTargets.length < countOfTargets && chooseTargets.indexOf(target) == -1) {
				chooseTargets.push(target);
			}
			
			if (chooseTargets.length >= countOfTargets) {
				
				showHelpTimeout(Locale.__e('flash:1416326811429', [chooseTargets.length, countOfTargets]));
				
				waitForTarget = false;
				if (waitWorker) {
					var targets:Object = [];
					for each (var unit:* in chooseTargets) {
						var object:Object = { };
						object[unit.sid] = unit.id;
						targets.push(object);
					}
					waitWorker.tie(targets);
				}
			}else {
				//App.ui.upPanel.showHelp(Locale.__e('flash:1416326811429', [chooseTargets.length, countOfTargets]), 0);
			}
		}
		
		private static var timeout:int = 0; 
		private static function showHelpTimeout(text:String, time:int = 2000):void {
			if (timeout > 0) {
				clearTimeout(timeout);
			}
			
			/*App.ui.upPanel.showHelp(text, 0);
			if (time > 0) {
				timeout = setTimeout(function():void {
					App.ui.upPanel.hideHelp();
					App.ui.upPanel.hideCancel();
					timeout = 0;
				}, time);
			}*/
		}
		
		public function onCancel():void {
			/*App.ui.upPanel.hideHelp();
			App.ui.upPanel.hideCancel();*/
			
			unselectTagrets();
		}
		public function unselectTagrets():void {
			var possibleTargets:Array = Map.findUnits(posibleTargets);
			for each(var res:* in possibleTargets)
			{
				if (res.state == res.HIGHLIGHTED) {
					res.state = res.DEFAULT;
					res.canAddWorker = false;
				}
			}
		}
	}

}