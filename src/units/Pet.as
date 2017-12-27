package units 
{
	import astar.AStar;
	import com.greensock.TweenLite;
	import core.Post;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	//import wins.JamWindow;
	import astar.AStarNodeVO;
	import ui.Hints;
	/**
	 * ...
	 * @author 
	 */
	public class Pet extends Personage
	{
		public var timeID:uint;
		public var returnID:uint;
		public static var radius:uint = 50;
		
		public static const BUNNY:uint = 342;
		public static const MOLE:uint = 343;
		
		
		override public function onLoop():void{
			loop();
		}
		
		private var loop:Function = function():void {};
		private function replaceOnLoop():void {
			visible = false;
			stopAnimation();
			timeID = setTimeout(goto, 5000 + int(Math.random() * 8000));
		}
		
		public static function findStartPositions():Array {
			var freeNodes:Array = [];
			
			for (var z:int = -radius; z < radius; z++ ) {
				for (var x:int = -radius; x < radius; x++ ) {
					
					if (x == 0 || z == 0) continue;
					
					var newX:int = (App.map.heroPosition.x - x) > 3?(App.map.heroPosition.x - x):3;
					var newZ:int = (App.map.heroPosition.z - z) > 3?(App.map.heroPosition.z - z):3;
					
					newZ = newZ > Map.rows-3?Map.rows-3:newZ;
					newX = newX > Map.cells-3?Map.cells-3:newX;
					
					var node:AStarNodeVO = App.map._aStarNodes[newX][newZ]; 
					
					if (node.isWall != true) {
						freeNodes.push(node);
					}
				}
			}
				
			return freeNodes;	
		}
		
		public static function addPets(sid:uint, count:int = 1):void 
		{
			var startPositions:Array = findStartPositions();
			for (var i:int = 0; i < count; i++ ) 
			{
				var unit:Object = { sid:sid, x:App.map.heroPosition.x + 1, z:App.map.heroPosition.z + 1 };
				if (startPositions.length > 0) {
					var j:int = int(Math.random() * startPositions.length);
					unit.x = startPositions[j].position.x;
					unit.z = startPositions[j].position.y;
					startPositions.splice(j, 1);
				}
				
				new Pet(unit);
			}
		}
		
		public function Pet(object:Object)
		{
			super(object);
			
			velocity = 0.02;
			
			switch(sid) {
				case BUNNY:
					velocity = 0.03;
				break;
				case MOLE:
					velocity = 0;
					loop = replaceOnLoop;
				break;
				default:
					velocity = 0.03;
				break;
			}
			
			takeable 			= false;
			clickable 			= false;
			touchable			= false;
			touchableInGuest 	= false;
			transable 			= false;
			removable 			= false;
			moveable			= false;
			rotateable			= false;
			
			tm = new TargetManager(this);
			framesType = 'stop_pause';
			
			Unit.sorting(this);
			
			if(velocity > 0)
				goto();
			
			//timeID = setTimeout(hide, 50000 + int(Math.random() * 20000));
			App.map.addEventListener(Event.REMOVED_FROM_STAGE, onRemoveMap);
		}
		
		public function onRemoveMap(e:Event):void {
			App.map.removeEventListener(Event.REMOVED_FROM_STAGE, onRemoveMap);
			clearTimeout(returnID);
			clearTimeout(timeID);
		}
		
		public function hide():void {
			
			returnID = setTimeout(function():void {
				addPets(sid,1);
			}, 120000 + int(Math.random() * 120000));
			
			TweenLite.to(this, 0.8, { alpha:0, onComplete:function():void {
				uninstall();
			}});
		}
		
		public function goto():void
		{
			var target:Object = findNextPosition();	
			if (target == null) {
				hide();
				return;
			}
			
			if (velocity == 0) {
				visible = true;
				startAnimation();
				placing(target.position.x, 0, target.position.y);
				Unit.sorting(this);
				return;
			}
			
			framesType = 'walk';
			initMove(target.position.x, target.position.y, onStop);
		}
		
		private function findNextPosition():Object 
		{
			var freeNodes:Array = [];
			for (var z:int = -radius; z < radius; z++ ) {
				for (var x:int = -radius; x < radius; x++ ) {
					if (x == 0 || z == 0) continue;
					
					var newX:int = (coords.x - x) > 3?(coords.x - x):3;
					var newZ:int = (coords.z - z) > 3?(coords.z - z):3;
					
					newZ = newZ > Map.rows-3?Map.rows-3:newZ;
					newX = newX > Map.cells-3?Map.cells-3:newX;
					
					var node:AStarNodeVO = App.map._aStarNodes[newX][newZ]; 
					
					if (node.isWall != true)
						freeNodes.push(node);
				}
			}
			
			if (freeNodes.length > 0) {
				var j:int = int(Math.random() * freeNodes.length);
				return freeNodes[j];
			}
			
			return null;
		}
		
		/**
		 * Вычисляем маршрут
		 * @param	cell
		 * @param	row
		 */
		override public function initMove(cell:int, row:int, _onPathComplete:Function = null):void {
			
			//Не пересчитываем маршрут, если идем в ту же клетку
			onPathComplete = _onPathComplete;
			
			if (_walk) {
				if (path[path.length - 1].position.x == cell && path[path.length - 1].position.y == row) {
					return;
				}
			}
			
			if (!(cell in App.map._aStarNodes)) {
				return;
			}
			if (!(row in App.map._aStarNodes[cell])) {
				return;
			}
			
			if (App.map._aStarParts[cell][row].isWall ){
				walking();
				return;
			}
			
			path = App.map._astar.search(App.map._aStarNodes[this.cell][this.row], App.map._aStarNodes[cell][row]);
			
			if (path == null) {
				//trace('Не могу туда пройти по-нормальному!');
				path = App.map._astarReserve.search(App.map._aStarParts[this.cell][this.row], App.map._aStarParts[cell][row]);
				
				if(path == null){
					hide();
					return;
				}
			}
			
			pathCounter = 1;
			t = 0;
			walking();
		}
		
		
		override public function onStop():void
		{
			framesType = 'stop_pause';
			timeID = setTimeout(goto, 5000 + int(Math.random() * 8000));
		}
		
		override public function click():Boolean {
			if (!super.click()) return false;
			
			if (! App.user.stock.check(Stock.FANTASY, 1)) return false;
			
			Post.send( {
				ctr:'Gift',
				act:'light',
				uID:App.user.id,
				sID:sid
			}, onLightAction);
			
			clickable = false;
			touchable = false;
			ordered = true;
			
			return true;
		}
		
		private function onLightAction(error:int, data:Object, params:Object = null):void
		{
			if (error)
			{
				if (error == 23 || error == 19)
				{
					uninstall();
					return;
				}
				
				Errors.show(error, data);
				return;
			}
			
			Hints.minus(Stock.FANTASY, 1, new Point(this.x*App.map.scaleX + App.map.x, this.y*App.map.scaleY + App.map.y), true);
			
			if (data.hasOwnProperty("bonus")) {
				Treasures.bonus(data.bonus, new Point(this.x, this.y));
				SoundsManager.instance.playSFX('bonus');
			}
			uninstall();
			
			if (data.hasOwnProperty(Stock.FANTASY)) {
				App.user.stock.setFantasy(data[Stock.FANTASY]);
			}
			
			/*returnID = setTimeout(function():void {
				addFrogs(1);
			}, 120000 + int(Math.random() * 120000));*/
			
		}
		
		override public function uninstall():void {
			clearTimeout(timeID);
			super.uninstall();
		}
		
	}
}