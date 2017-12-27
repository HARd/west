package units 
{
	import astar.AStarNodeVO;
	import com.greensock.TweenLite;
	import core.Post;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	
	public class WorkerUnit extends Personage
	{
		public static const FREE:int = 0;
		public static const BUSY:int = 1;
		//public static const QUEUE:int = 2;
		
		public static var busy:uint = 0;
		
		public var walkable:Boolean = true;
		public var rel:Object;
		public var movePoint:Point = new Point();		// Точка установки
		
		public var ended:int = 0;
		public var workEnded:int = 0;
		
		public function WorkerUnit(object:Object, view:String = '') {
			
			this.rel = object.rel || {};
			this.created = object.created || 0;
			
			super(object, view);
			
			movePoint.x = object.x;
			movePoint.y = object.z;
			
			tm = new TargetManager(this);
			framesType = Personage.STOP;
		}
		
		override public function click():Boolean
		{
			return true;
		}
		
		public function born(settings:Object = null):void 
		{
			
		}
		
		override public function initMove(cell:int, row:int, _onPathComplete:Function = null):void {
			if ((this.cell != cell || this.row != row) && sid != 821) {
				framesType = Personage.WALK;
			}
			super.initMove(cell, row, _onPathComplete);
		}
		
		public function addTarget(targetObject:Object):Boolean
		{
			tm.add(targetObject);
			return true;
		}
		
		override public function onStop():void
		{
			framesType = Personage.STOP;
		}
		
		override public function onPathToTargetComplete():void
		{
			//startJob();
		}
		
		override public function walk(e:Event = null):* {
			velocity = velocities[0];
			super.walk();
		}
		
		public var _workStatus:uint = FREE;
		public function set workStatus(value:uint):void {
			_workStatus = value;
		}
		
		public function get workStatus():uint {
			return _workStatus;
		}
		
		public function isFree():Boolean {
			if(workStatus == FREE || (workEnded > 0 && workEnded < App.time))
				return true;
			
			return false;	
		}
		
		
		public var homeRadius:int = 5;
		public function goHome(_movePoint:Object = null):void
		{
			clearTimeout(timer);
			if (!walkable) return;
			
			if (_framesType != Personage.STOP) {
				var newtime:uint = Math.random() * 5000 + 5000;
				timer = setTimeout(goHome, newtime);
				return;
			}
			
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
			
			if (sid == 1127) return;
			framesType = Personage.WALK;
			initMove(
				place.x,
				place.z,
				onGoHomeComplete
			);
		}
		
		public function makeVoice():void {}
		
		public function stopRest():void {
			framesType = Personage.STOP;
			if (timer > 0)
				clearTimeout(timer);
		}
		
		public var timer:uint = 0;
		public function onGoHomeComplete():void {
			stopRest();
			
			var time:uint = Math.random() * 5000 + 5000;
			timer = setTimeout(goHome, time);
		}
		
		override public function stockAction(params:Object = null):void {
			
			if(App.user.stock.count(sid) > 0)
				App.user.stock.data[sid] -= 1;
			else
				return;
						
			Post.send( {
				ctr:this.type,
				act:'stock',
				uID:App.user.id,
				wID:App.user.worldID,
				sID:this.sid,
				x:coords.x,
				z:coords.z
			}, onStockAction);
			
			moveable = false;
		}
		
		override protected function onStockAction(error:int, data:Object, params:Object):void {
			if (error) {
				Errors.show(error, data);
				return;
			}
			
			this.id = data.id;
			App.map.moved = null;
			App.ui.glowing(this);
			cell = coords.x;
			row = coords.z;
			movePoint.x = coords.x;
			movePoint.y = coords.z;
			goHome();
		}
		
		override public function findPlaceNearTarget(target:*, radius:int = 3):Object
		{
			var places:Array = [];
			
			var targetX:int = target.coords.x;
			var targetZ:int = target.coords.z;
			
			var startX:int = targetX - radius;
			var startZ:int = targetZ - radius;
			
			if (startX <= 0) startX = 1;
			if (startZ <= 0) startZ = 1;
			
			var finishX:int = targetX + radius * 2 + target.info.area.w;
			var finishZ:int = targetZ + radius * 2 + target.info.area.h;
			
			if (finishX >= Map.cells) finishX = Map.cells - 1;
			if (finishZ >= Map.rows) finishZ = Map.rows - 1;
			
			for (var pX:int = startX; pX < finishX; pX++)
			{
				for (var pZ:int = startZ; pZ < finishZ; pZ++)
				{
					if ((coords.x <= pX && pX <= targetX +target.info.area.w) &&
					(coords.z <= pZ && pZ <= targetZ +target.info.area.h)){
						continue;
					}
					
					if (App.map._aStarNodes && App.map._aStarNodes[pX][pZ].isWall) 
						continue;
						
					if (App.map._aStarNodes && App.map._aStarNodes[pX][pZ].open == false) 
						continue;	
					
					places.push( { x:pX, z:pZ} );
				}
			}
			
			if (places.length == 0) {
				places.push( { x:coords.x, z:coords.z } );
			}
			var random:uint = int(Math.random() * (places.length - 1));
			return places[random];
		}
		
		public function goOnRandomPlace():void 
		{
			var place:Object = getRandomPlace();
			initMove(
				place.x, 
				place.z,
				onGoOnRandomPlace
			);
		}
		
		public function getRandomPlace():Object 
		{
			var i:int = 20;
			while (i > 0) {
				i--;
				var place:Object = nextPlace();
				if (App.map._aStarNodes[place.x][place.z].isWall) 
					continue;
				
				break;
			}
			
			return {
				x:place.x,
				z:place.z
			}
			
			function nextPlace():Object {
				var randomX:int = int(Math.random() * Map.cells);
				var randomZ:int = int(Math.random() * Map.rows);
				return {
					x:randomX,
					z:randomZ
				}
			}
		}
		
		private var _timer:uint = 0;
		public function onGoOnRandomPlace():void {
			framesType = STOP;
		}
		
		public var isRemove:Boolean = false;
		override public function uninstall():void {
			isRemove = true;
			clearTimeout(timer);
			super.uninstall();
		}
		
		public var shortcutDistance:int = 5;
		override public function findPath(start:*, finish:*, _astar:*):Vector.<AStarNodeVO> {
			
			var needSplice:Boolean = checkOnSplice(start, finish);
			
			if (App.user.quests.tutorial && tm.currentTarget != null)
				tm.currentTarget.shortcutCheck = true;
				
			if (!needSplice) {
				var path:Vector.<AStarNodeVO> = _astar.search(start, finish);
				if (path == null) 
					return null;
				
				if (path.length > shortcutDistance) {
					path = path.splice(path.length - shortcutDistance, shortcutDistance);
					placing(path[0].position.x, 0, path[0].position.y);
					alpha = 0;
					TweenLite.to(this, 1, { alpha:1 } );
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
		
		public function checkOnSplice(start:*, finish:*):Boolean {
			
			var zones:Array = [83, 180, 181, 182, 183, 184, 185, 186, 187, 613, 614, 615, 616, 617, 618, 619, 620, 621, 622];
			
			if (zones.indexOf(finish.z) != -1 || 
				zones.indexOf(start.z) != -1) {
					
				if (start.z != finish.z) {
					return true;
				}
			}
			
			return false;
		}
		
		public function finishJob(e:Event = null):void {
			
		}
	}
}
