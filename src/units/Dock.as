package units
{
	import astar.AStarNodeVO;
	import flash.events.Event;
	import flash.geom.Point;
	import ui.Cursor;
	import wins.BuildingConstructWindow;
	import wins.SimpleWindow;
	
	public class Dock extends Building{

		public function Dock(object:Object)
		{
			super(object);
			moveable = false;
			removable = false;
			stockable = false;
			rotateable = false;
		}
		
		override public function calcState(node:AStarNodeVO):int
		{
			//return EMPTY;
			if (info.base != null && info.base == 1) 
			{
				for (var i:uint = 0; i < cells; i++) {
					for (var j:uint = 0; j < rows; j++) {
						node = App.map._aStarNodes[coords.x + i][coords.z + j];
						//if (node.b != 0 || node.open == false) {
						if (node.w != 1 || node.object != null || node.open == false) {
							return OCCUPIED;
						}
					}
				}
				return EMPTY;
			}
			else
			{
				return super.calcState(node);
			}
		}
		
		override public function click():Boolean {
			
			if(level < totalLevels){
				new BuildingConstructWindow({
					title:info.title,
					level:Number(level),
					totalLevels:Number(totalLevels),
					devels:info.devel[level+1],
					bonus:info.bonus,
					target:this,
					upgradeCallback:upgradeEvent
				}).show();
			}
			else
			{
				if (App.user.hero.transport != null) {
					var point:Object = boatPoint();
					var that:Dock = this;
					App.user.hero.initMove(point.x, point.z, function():void {
						App.user.hero.transport.removeHeroFromBoard(that);	
					});
				}else {
					new SimpleWindow( {
						title:info.title,
						label:SimpleWindow.ATTENTION,
						text:Locale.__e('flash:1383558733975')
					}).show();
				}
				
				Transport.hideGlowDocks();
			}
			return true;
		}
		
		override public function findJobPosition():Object
		{
			var _x:int = -1;
			var _y:int = int(info.area.w/2);
			var _flip:int = 0;
			
			if (rotate) {
				_y = -1;
				_x = int(info.area.h/2);
			}
					
			if (info.view == 'doks') {
				_x = -1;
				_y = 6;
				_flip = 1;
			}
			
			return {
				x: 		_x,
				y: 		_y,
				flip: 	_flip
			}
		}
		
		override public function set touch(touch:Boolean):void 
		{
			if (!touchable) 
				return;
			
			if ((!moveable && Cursor.type == 'move') ||
				(!removable && Cursor.type == 'remove') ||
				(!rotateable && Cursor.type == 'rotate'))// ||
				//(!touchableCursor.type == 'default')
			{
				//if (info.view != 'pier')
					return;
			}
			
			
			if (Cursor.type == 'stock' && stockable == false) return;
			
			if (!touchable || (App.user.mode == User.GUEST && touchableInGuest == false)) return;
			
			_touch = touch;
			
			if (touch) {
				if(state == DEFAULT){
					state = TOCHED;
				}else if (state == HIGHLIGHTED) {
					state = IDENTIFIED;
				}
				
			}else {
				if(state == TOCHED){
					state = DEFAULT;
				}else if (state == IDENTIFIED) {
					state = HIGHLIGHTED;
				}
			}
		}
		
		public function heroPoint():Object {
			
			var _x:int = coords.x - 1;
			var _z:int = coords.z + int(info.area.h / 2);
			
			if (rotate) {
				_x = coords.x + int(info.area.w / 2)
				_z = coords.z - 1;
			}
			
			return {
				x: _x,
				z: _z
			}
			
		}
		
		public function boatPoint():Object {
			
			var _x:int = coords.x + info.area.w + 1;
			var _z:int = coords.z + int(info.area.h / 2);
			if (rotate) {
				_x = coords.x + int(info.area.w / 2);
				_z = coords.z + info.area.h + 1;
			}
			
			if (info.view == 'doks') {
				_z -= 2;
			}
			
			return {
				x: _x,
				z: _z
			}
		}
		
		public function show():void {
			showGlowing();
		}
		public function hide():void {
			hideGlowing();
		}
	}
}