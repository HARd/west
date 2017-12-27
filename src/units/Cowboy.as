package units 
{
	import astar.AStarNodeVO;
	import com.greensock.TweenLite;
	import core.Load;
	import core.Post;
	import flash.geom.Point;
	import wins.FurryWindow;
	import wins.SpeedWindow;
	/**
	 * ...
	 * @author ...
	 */
	public class Cowboy extends WorkerUnit
	{
		public static var cowboy:Cowboy;
		
		public var animal:Animal;
		
		private var started:int;
		private var finished:int;
		
		private var data:Object;
		
		private var hasProduct:Boolean = false;
		
		public function Cowboy(object:Object) 
		{
			started = object.started;
			finished = object.finished;
			
			data = object;
			
			super(object);
			
			App.user.cowboys.push(this);
			
			moveable = true;
			
			velocities = [0.05];
			info['area'] = { w:1, h:1 };
			
			tip = function():Object {
				
				return {
					title:info.title,
					text:info.description
				}
			}
			
			App.self.addEventListener(AppEvent.ON_MAP_COMPLETE, onMapComplete);	
		}
		
		public static function getBusyCowboys():int
		{
			var count:int = 0;
			for (var i:int = 0; i < App.user.cowboys.length; i++) 
			{
				if (!App.user.cowboys[i].isThisFree())
					count++;
			}
			
			return count;
		}
		
		private function onMapComplete(e:AppEvent):void 
		{
			App.self.removeEventListener(AppEvent.ON_MAP_COMPLETE, onMapComplete);	
		
			if (data.hasOwnProperty('target') && data.target != false) {
				for (var key:* in data.target)
					break;
				var anim:Animal = Map.findUnit(key, data.target[key]);
				animal = anim;
				if (!anim) {
					started = 0;
					finished = 0;
					animal = null;
					return;
				}
				animal = anim;
				animal.addCowboy(this);
				//animal.updateCount();
				goToJob();
			}
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
		
		override public function goOnRandomPlace():void 
		{
			var place:Object = findPlaceNearTarget(this, 5);
			initMove(
				place.x, 
				place.z,
				onGoOnRandomPlace
			);
		}
		
		override public function click():Boolean
		{
			if (App.user.mode == User.GUEST)
				return true;
			
			if (!animal) {
				if (hasProduct) 
					storage();
				new FurryWindow({
					title:info.title,
					info:info,
					mode:FurryWindow.COWBOW,
					target:this,
					bttnText:Locale.__e('flash:1409567527400')
				}).show();
			}else {
				if (hasProduct) {
					storage();
				}else {
					showSpeedWindow();
				}
			}
			
			return true;
		}
		
		public function showSpeedWindow():void 
		{
			var finishTime:int = finished;
			var totalTime:int = finishTime - started;
			
			new SpeedWindow( {
				title:info.title,
				target:this,
				info:info,
				finishTime:finishTime,
				totalTime:totalTime,
				speedKoef:info.skip,
				doBoost:boost
			}).show();
		}
		
		public function animalDone():void
		{
			hasProduct = true;
		}
		
		public function boost(price:int):void
		{
			if (!App.user.stock.take(Stock.FANT, price)) return;
			
			Post.send({
				ctr:this.type,
				act:'boost',
				uID:App.user.id,
				id:this.id,
				wID:App.user.worldID,
				sID:this.sid
			}, onBoostEvent);
		}
		
		private function onBoostEvent(error:int, data:Object, params:Object):void 
		{
			if (error)
			{
				Errors.show(error, data);
				return;
			}
			
			if (data.hasOwnProperty('bonus'))
				Treasures.bonus(Treasures.convert(data.bonus), new Point(this.x, this.y));
			
			animal.uninstall();
			animal = null;
			
			workStatus = WorkerUnit.FREE;
			goHome();
		}
		
		public function storage():void
		{
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
			
			hasProduct = false;
			
			if (data.hasOwnProperty('bonus'))
				Treasures.bonus(Treasures.convert(data.bonus), new Point(this.x, this.y));
			
			if(animal){
				if (data.count >= animal.info.count) {
					animal.uninstall();
					animal = null;
					workStatus = WorkerUnit.FREE;
					goHome();
				}else {
					animal.feeds = data.count;
				}
			}
		}
		
		public function tie(animal:Animal):void
		{
			this.animal = animal;
			var targetAnimal:Object = { };
			targetAnimal[animal.sid] = animal.id;
			Post.send({
				ctr:this.type,
				act:'tie',
				uID:App.user.id,
				id:this.id,
				wID:App.user.worldID,
				sID:this.sid,
				target:JSON.stringify(targetAnimal)
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
			
			goToJob();
		}
		
		private var jobPosition:Object;
		public function goToJob():void {
			stopRest();
			
			workStatus = BUSY;
			jobPosition = {x:animal.coords.x+1, z:animal.coords.z + 1};
			
			_move = false;
			
			initMove(
				jobPosition.x, 
				jobPosition.z,
				startWork
			);
		}
		
		override public function findPath(start:*, finish:*, _astar:*):Vector.<AStarNodeVO> {
			
			var needSplice:Boolean = checkOnSplice(start, finish);
			
			if (App.user.quests.tutorial && tm.currentTarget != null)
				tm.currentTarget.shortcutCheck = true;
				
			if (!needSplice) {
				var path:Vector.<AStarNodeVO> = _astar.search(start, finish);
				if (path == null) 
					return null;
					
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
		
		private function startWork():void 
		{
			framesType = 'stop_pause';
		}
		
		public function isThisFree():Boolean
		{
			var isFree:Boolean = true;
			
			if (animal)
				isFree = false;
				
			return isFree;
		}
		
		override public function set touch(touch:Boolean):void
		{
			if (App.user.mode == User.GUEST)
				return;
			
			stopWalking();
			onGoHomeComplete();
			
			super.touch = touch;
		}
		
	}

}