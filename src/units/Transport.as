package units
{
	import astar.AStar;
	import astar.AStarNodeVO;
	import core.IsoConvert;
	import core.Load;
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import ui.Cursor;
	import wins.SimpleWindow;
	
	public class Transport extends WUnit
	{
		public var dock:*;
		public static var boat:Transport;
		public static function addTransport(object:Object):void {
			object['id'] = 1;
			boat = new Transport(object);
			Unit.sorting(boat);
		}
		
		public function Transport(object:Object)
		{
			this.dock = object.dock;
			dock.touchable = false;
			dock.clickable = false;
			
			layer = Map.LAYER_SORT;
			if (App.data.storage[object.sid].dtype == 1)
				layer = Map.LAYER_LAND;
			
			object['hasLoader'] = false;
			super(object);
			
			touchableInGuest = false;
			multiple = false;
			stockable = false;
			transable = false;
			
			Load.loading(Config.getSwf('Transport', 'boat'), onLoad);
			
			tip = function():Object {
				return {
					title:info.title,
					text:info.description
				};
			};
		}
		
		override public function initMove(cell:int, row:int, _onPathComplete:Function = null):void {
			
			//Не пересчитываем маршрут, если идем в ту же клетку
			bitmap.visible = true;
			onPathComplete = function():void {
				bitmap.visible = false;
				_onPathComplete();
			}
			
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
			
			var _astar:AStar = App.map._astarWater;
			var _aStarNodes:Vector.<Vector.<AStarNodeVO>> = App.map._aStarWaterNodes;
			if (_aStarNodes[cell][row].isWall){
				walking();
				return;
			}
				
			path = _astar.search(_aStarNodes[this.cell][this.row], _aStarNodes[cell][row]);
				
			if (path == null) {
				trace('Не могу туда пройти по-нормальному!');
				//App.map._astarReserve.reload();
				
				if(path == null){
					this._walk = false;
					pathCounter = 1;
					t = 0;
					App.self.setOffEnterFrame(walk);
					trace('Не могу туда пройти!');
					return;
				}
			}
			
			
			/*for each(var node:* in path) {
				var _tile:Bitmap = new Bitmap(IsoTile._tile);
				_tile.x = node.tile.x - IsoTile.width*.5;
				_tile.y = node.tile.y;
				App.map.mLand.addChild(_tile);
			}*/
			
			pathCounter = 1;
			t = 0;
			walking();
		}
		
		override public function take():void {
			
		}
		
		override public function free():void {
			
		}
		
		override public function set state(state:uint):void {
			if (_state == state) return;
			
			switch(state) {
				case OCCUPIED: baseBitmap.filters = [new GlowFilter(0xFF0000,1, 6,6,7)]; break;
				case EMPTY: baseBitmap.filters = [new GlowFilter(0x00FF00,1, 6,6,7)]; break;
				case TOCHED: baseBitmap.filters = [new GlowFilter(0xFFFF00,1, 6,6,7)]; break;
				case HIGHLIGHTED: baseBitmap.filters = [new GlowFilter(0x88ffed,0.6, 6,6,7)]; break;
				case IDENTIFIED: baseBitmap.filters = [new GlowFilter(0x88ffed,1, 8,8,10)]; break;
				case DEFAULT: baseBitmap.filters = []; break;
			}
			_state = state;
		}
		
		override public function get bmp():Bitmap {
			if (bitmap.bitmapData && bitmap.bitmapData.getPixel(bitmap.mouseX, bitmap.mouseY) != 0) 			
				return bitmap;
			if (baseBitmap && baseBitmap.bitmapData && baseBitmap.bitmapData.getPixel(baseBitmap.mouseX, baseBitmap.mouseY) != 0) 	
				return baseBitmap;
				
			return bitmap;
		}
		
		private var baseBitmap:Bitmap;
		public function onLoad(data:*):void {
			textures = data;
			var levelData:Object = textures.sprites[0];
			
			addAnimation();
			position = { flip:RIGHT, direction:FACE };
			super.update();
			
			bitmap.visible = false;
			
			baseBitmap = new Bitmap(levelData.bmp);
			baseBitmap.x = levelData.dx;
			baseBitmap.y = levelData.dy;
			addChildAt(baseBitmap, 0);
			
			//framesType = 'move';
			/*if (textures && textures.hasOwnProperty('animation')) {
				addAnimation();
				//startAnimation(true);
			}*/
		}
		
		public override function update(e:Event = null):void {
			
			if(bitmap.visible)	super.update(e);
			
			var bitmapObject:Object = textures.sprites[framesDirection];
			baseBitmap.bitmapData = bitmapObject.bmp;
			baseBitmap.scaleX = sign;
			baseBitmap.x = bitmapObject.dx * sign;
			baseBitmap.y = bitmapObject.dy;
			
			if (hasHero) {
				App.user.hero.position = { 
					flip:framesFlip,
					direction:framesDirection
				};
			}
		}
		
		override public function set touch(touch:Boolean):void {
			if ((!moveable && Cursor.type == 'move') ||
				(!removable && Cursor.type == 'remove') ||
				(!rotateable && Cursor.type == 'rotate'))
			{
					return;
			}
			
			super.touch = touch;
		}
		
		override public function click():Boolean 
		{
			//var dock:* = findNearlstDock();
			if (dock == null) {
				new SimpleWindow( {
					title:Locale.__e('flash:1396608507381'),
					label:SimpleWindow.ATTENTION
				}).show();
			}
			
			var position:Object = dock.findJobPosition();
			var point:Object = {
				x:dock.coords.x + position.x,
				z:dock.coords.z + position.y
			}
		
			App.user.onStopEvent();
			this.ordered = true;
			var that:Transport = this;
			App.user.hero.tm.status = TargetManager.BUSY;
			App.user.hero.tm.currentTarget = {target:that};
			App.user.hero.initMove(point.x, point.z, function():void {
				that.ordered = false;
				App.user.hero.tm.status = TargetManager.FREE;
				addHeroOnBoard();
			});	
			
			return true;
		}
		
		public var hasHero:Boolean = false;
		private function addHeroOnBoard():void {
			hasHero = true;
			this.clickable = false;
			this.touchable = false;
			App.map.mSort.removeChild(App.user.hero);
			this.addChild(App.user.hero);
			App.user.hero.transport = this;
			
			//App.user.hero.framesType = Hero.STOP;
			App.user.hero.startAnimation();
			App.user.hero.x = 0;
			App.user.hero.y = -25;
			
			showGlowDocks(this.dock);
			this.dock.touchable = true;
			this.dock.clickable = true;
			this.dock = null;
		}
		
		public function removeHeroFromBoard(dock:Dock):void {
			hasHero = false;
			this.removeChild(App.user.hero);
			App.map.mSort.addChild(App.user.hero);
			App.user.hero.transport = null;
			App.user.hero.framesType = Personage.STOP;
			this.clickable = true;
			this.touchable = true;
			
			this.dock = dock;
			hideGlowDocks();
			
			var point:Object = dock.heroPoint();
			var _point:Object = IsoConvert.isoToScreen(point.x, point.z, true);
			App.user.hero.x = _point.x;
			App.user.hero.y = _point.y;
			
			App.user.hero.cell = point.x;
			App.user.hero.row = point.z;
			
			dock.touchable = false;
			dock.clickable = false;
			dock.state = DEFAULT;
		}
		
		public static function showGlowDocks(dock:Dock = null):void 
		{
			var targets:Array = Map.findUnitsByType(['Dock']);
			for each(var _dock:Dock in targets) {
				if (_dock != dock)
					_dock.show();
			}	
		}
		
		public static function hideGlowDocks():void{
			var targets:Array = Map.findUnitsByType(['Dock']);
			for each(var _dock:Dock in targets) {
					_dock.hide();
			}	
		}
	}
}