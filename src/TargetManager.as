package  
{
	import units.Personage;
	import units.Unit;
	/**
	 * ...
	 * @author 
	 */
	public class TargetManager
	{
		public static const FREE:int = 0;
		public static const BUSY:int = 1;
		public static const WORKING:int = 2;
		
		public var currentTarget:Object = null;
		public var status:int = FREE;
		
		private var queue:Array = [];
		private var owner:Personage;
		
		public function TargetManager(_owner:Personage):void
		{
			owner = _owner;
		}
		
		public function add(targetObject:Object):void
		{
			if (targetObject.isPriority)
				queue.unshift(targetObject);
			else 
				queue.push(targetObject);
			
			if (targetObject.hasOwnProperty('priority'))
				call(targetObject.priority);
			else
				call();
			
		}
		
		public function get length():int {
			return queue.length;
		}
		
		public function dispose():void {
			if (currentTarget == null) {
				return;
			}
			
			if (currentTarget.target.ordered) {
				currentTarget.target.ordered = false;
				currentTarget.target.worker = null;
				if (!currentTarget.target.formed) {
					currentTarget.target.uninstall();
				}
			}
			
			if (currentTarget.target.hasOwnProperty('reserved') && currentTarget.target.reserved > 0) {
				currentTarget.target.reserved = 0;
			}
			
			currentTarget = null;
			status = FREE;
			for each(var target:* in queue) {
				if (target.target.ordered) {
					target.target.ordered = false;
					target.target.worker = null;
					if (!target.target.formed) {
						target.target.uninstall();
					}
				}
				if (target.target.hasOwnProperty('reserved') && target.target.reserved > 0) {
					target.target.reserved = 0;
				}
			}
			queue = [];
			
		}
		
		public function call(priority:* = null):void
		{
			if (status == FREE || priority != null) {
				if (queue.length > 0){
					makeNext();
				}else{
					if (App.user.queue.length > 0)
					{
						queue.push(App.user.queue.shift());
						makeNext();
					}
					owner.beginLive();
				}
			}
		}
		
		private function makeNext():void
		{
			currentTarget 			= queue.shift();
			queue = queue.concat(App.user.takeTaskForTarget(currentTarget.target));
			
			var target:* 			= currentTarget.target;
			var jobPosition:Object 	= currentTarget.jobPosition;
			var callback:Function 	= currentTarget.callback;
			
			var positions:Object = Map.findNearestFreePosition( {x:target.coords.x + jobPosition.x, y:target.coords.z + jobPosition.y });
			//var cells:int 	= target.coords.x + jobPosition.x;
			//var rows:int 	= target.coords.z + jobPosition.y;
			
			status = BUSY;
			
			target.worker = owner;
			
			//owner.initMove(cells, rows, owner.onPathToTargetComplete);
			owner.initMove(positions.x, positions.y, owner.onPathToTargetComplete);
		}
		
		public function onTargetComplete():void
		{
			status = FREE;
			owner.framesDirection = currentTarget.jobPosition.direction;
			owner.framesFlip = currentTarget.jobPosition.flip;
			currentTarget.callback();
			
			if (currentTarget) currentTarget.target.worker = null;
			
			//if (currentTarget && currentTarget.target.hasOwnProperty('isTarget'))
				//currentTarget.target.isTarget = false;
			
			currentTarget = null;
			call();
		}	
		
		public function stop():void
		{
			queue = [];
			status = FREE;
		}
	}
}
