package units 
{
	import astar.AStar;
	import com.greensock.TweenLite;
	import com.greensock.TweenMax;
	import core.Post;
	import core.TimeConverter;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	import flash.utils.Timer;
	import wins.JamWindow;
	import astar.AStarNodeVO;
	import ui.Hints;
	/**
	 * ...
	 * @author 
	 */
	public class Frog extends Personage
	{
		public static var bears:Array = new Array();
		private var time:uint					= 1000;
		private var onTimerCallback:Function 	= null;
			
		public static const	ANIM_WALK:String 		= "walk";
		public static const	ANIM_STOP:String 		= "stop_pause";
			
		public static const ACTION_WALK:uint 		= 1;
		public static const ACTION_STOP:uint 		= 4;
				
		public var _action:uint = ACTION_WALK;
				
		private var timer:Timer; 
		private var direction:String = "";
		
		
		public var timeID:uint;
		public var returnID:uint;
		
		public static function addFrogs(count:int = 1):void {
			
			if (App.map._aStarWaterNodes == null) return;
			
			for (var i:int = 0; i < count;i++ ){
				
				var freeNodes:Array = [];
				var radius:int = 50;
				//Берем N клеток вверх-влево и вверх-вправо если они flash:1382952379984няты, 
				for (var z:int = -radius; z < radius; z++ ) {
					for (var x:int = -radius; x < radius; x++ ) {
						
						if (x == 0 || z == 0) continue;
						
						var newX:int = (App.user.hero.coords.x - x) > 3?(App.user.hero.coords.x - x):3;
						var newZ:int = (App.user.hero.coords.z - z) > 3?(App.user.hero.coords.z - z):3;
						
						newZ = newZ > Map.rows-3?Map.rows-3:newZ;
						newX = newX > Map.cells-3?Map.cells-3:newX;
						
						var node:AStarNodeVO = App.map._aStarNodes[newX][newZ]; 
						
						if (node.isWall != true) {
							freeNodes.push(node);
						}
					}
				}
				var unit:Object = { x:App.user.hero.coords.x+1, z:App.user.hero.coords.z+1 };
				if (freeNodes.length > 0) {
					var j:int = int(Math.random() * freeNodes.length);
					unit.x = freeNodes[j].position.x;
					unit.z = freeNodes[j].position.y;
				}
				unit['sid'] = 635;
				
				new Frog(unit);
			}
			
		}
		
		public function Frog(object:Object)
		{
			
			
			//App.data.storage[object.sid].view = 'beaver';
			
			super(object);
			velocity = 0.04;
			
			shadow.scaleX = shadow.scaleY = 1;
			shadow.alpha = 0.5;
			
			shadow.x = -shadow.width / 2;
			shadow.y = -10;
				
			takeable 			= false;
			clickable 			= true;
			touchable			= true;
			touchableInGuest 	= false;
			transable 			= false;
			removable 			= false;
			moveable			= true;
			rotateable			= false;
			
			hasMultipleAnimation = true;
			
			tm = new TargetManager(this);
			framesType = 'stop_pause';
			
			
			
			/*
			tip = function():Object { 
				var text:String = '';
				if (jam) {
					if(sid == Personage.BEAR)
						text = Locale.__e("flash:1382952379858", [jam]) + "\n";
					else
						text = Locale.__e("flash:1382952379859", [jam]) + "\n";
				}
				text += alert;
			
				if (started != 0) text += "\n" + TimeConverter.timeToStr((resource.info.jobtime + started) - App.time);
				return {
					title:info.title,
					text:text,
					timer:true
				};
			};
			*/
			
			Unit.sorting(this);
			
			
			timeID = setTimeout(hide, 50000 + int(Math.random() * 20000));
			
			alpha = 0;
			var that:Frog = this;
			TweenMax.to(this, 0.8, { alpha:1, glowFilter: { color:0x84dd2f, alpha:0.8, strength: 5, blurX:12, blurY:12 }, onComplete:function():void {
				TweenMax.to(that, 0.5, {  glowFilter: { color:0x84dd2f, alpha:0.1, strength: 5, blurX:2, blurY:2 }, onComplete:function():void {
					filters = [];
					jump();
				}});
			}});
			
			App.map.addEventListener(Event.REMOVED_FROM_STAGE, onRemoveMap);
		}
		
		public function onRemoveMap(e:Event):void {
			App.map.removeEventListener(Event.REMOVED_FROM_STAGE, onRemoveMap);
			clearTimeout(returnID);
			clearTimeout(timeID);
		}
		
		public function hide():void {
			TweenLite.to(this, 0.8, { alpha:0, onComplete:function():void {
				uninstall();
			}});
			
			returnID = setTimeout(function():void {
				addFrogs(1);
			}, 120000 + int(Math.random() * 120000));
		}
		
		public function jump():void {
			
			framesType = 'walk';
			var freeNodes:Array = [];
			var radius:int = 20;
			//Берем N клеток вверх-влево и вверх-вправо если они flash:1382952379984няты, 
			for (var z:int = -radius; z < radius; z++ ) {
				for (var x:int = -radius; x < radius; x++ ) {
					
					if (x == 0 || z == 0) continue;
					
					var newX:int = (coords.x - x) > 3?(coords.x - x):3;
					var newZ:int = (coords.z - z) > 3?(coords.z - z):3;
					
					newZ = newZ > Map.rows-3?Map.rows-3:newZ;
					newX = newX > Map.cells-3?Map.cells-3:newX;
					
					var node:AStarNodeVO = App.map._aStarNodes[newX][newZ]; 
					
					if (node.isWall != true) {
						freeNodes.push(node);
					}
				}
			}
			
			if (freeNodes.length > 0) {
				var j:int = int(Math.random() * freeNodes.length);
				initMove(freeNodes[j].position.x, freeNodes[j].position.y, onStop);
			}
			
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
		
		/**
		 
		 */ 
		override public function onStop():void
		{
			framesType = 'stop_pause';
			timeID = setTimeout(jump, 5000 + int(Math.random() * 8000));
		}
		
		/**
		 * Кликаем по голове
		 */
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
			
			returnID = setTimeout(function():void {
				addFrogs(1);
			}, 120000 + int(Math.random() * 120000));
			
		}
		
		override public function uninstall():void {
			clearTimeout(timeID);
			super.uninstall();
		}
		
	}
}