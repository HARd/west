package units 
{
	import astar.AStarNodeVO;
	import com.sociodox.theminer.data.InternalEventEntry;
	import core.IsoConvert;
	import core.IsoTile;
	import core.Load;
	import flash.display.Bitmap;
	import flash.events.Event;
	import ui.Cursor;
	import wins.BuildingConstructWindow;
	import wins.SimpleWindow;
	
	public class Bridge extends Building
	{
		public static var bridges:Object;
		public var line:String;
		public var hasSpirit:Boolean = true;
		
		public function Bridge(object:Object)
		{
			if (object.id)
				line = getLine(this, object.x, object.z);
				
			layer = Map.LAYER_SORT;
			if (object.sid == 776)// || object.sid == 851
				layer = Map.LAYER_LAND;
				
			if (object.hasOwnProperty('hasSpirit'))
				this.hasSpirit = hasSpirit;
				
			super(object);
			touchableInGuest = false;
			//popupBalance.visible = false;
			
			if(formed)	moveable = false;
			multiple = false;
			rotateable = false;
			removable = false;
			
			//trace('{x:' + coords.x + ', z:' + coords.z + ', id:'+object.id+', view:'+info.view+' }');
			
			if(formed){
				if(info.side == 1 || info.side == 2 || info.view == 'pier')
					App.self.addEventListener(AppEvent.ON_MAP_COMPLETE, onMapComplete);
			}	
		}
		
		private function getLine(bridge:Bridge, _x:int, _z:int):String {
			for (var lineName:String in bridges) {
				for each(var object:Object in bridges[lineName]) {
					if (object.x == _x && object.z == _z) {
						return lineName;
					}
				}
			}
			return null;
		}
		
		override public function onUpgradeEvent(error:int, data:Object, params:Object):void {
			super.onUpgradeEvent(error, data, params);
			// Проверяем при flash:1382952379984вершении строительства
			if (level == totalLevels){
				if (check()) {
					for each(var bridge:Object in bridges[line]){
						var _bridge:* = App.map._aStarNodes[bridge.x][bridge.z].object;
						if(_bridge is Bridge && _bridge.info.side == 0)
							App.ui.flashGlowing(_bridge);
					}	
				}
			}	
		}
		
		override public function remove(_callback:Function = null):void {
				super.remove(_callback);
		}
		
		override public function updateLevel(checkRotate:Boolean = false, mode:int = -1):void 
		{
			super.updateLevel(checkRotate)
			
			if (!formed) return;
			if (level != totalLevels) return;
			
			if (info.side == 1 || info.side == 2) 
			{
				var _x:int = 0;
				var _z:int = 0;
				if(rotate)
				{
					_x = coords.x + info.area.h;
					_z = coords.z ;
				}
				else
				{
					_x = coords.x;
					_z = coords.z + info.area.h;
				}
				
				
				var front:Bridge = new Bridge( {
					sid:info.front,
					x:_x,
					z:_z,
					rotate:this.rotate
				});
				
				front.clickable = false;
				front.touchable = false;
			}
			
			clickable = false;
			touchable = false;
		}
		
		public function onMapComplete(e:AppEvent):void {
			App.self.removeEventListener(AppEvent.ON_MAP_COMPLETE, onMapComplete);
			check();
		}
		
		private function check():Boolean 
		{
			if(info.view != 'pier'){
				// Проверяем собрана ли линия
				if (!isLineComplete(line, 'light')) 
					return false;
					
				// выстраеваем тайлики	
				buildBridgeTiles();
				
			}else {
				if(!isPierComplete())
					return false;
			}
			
			// освобождаем путь
			
			unlock(bridges[line]);
			return true;
		}
		
		public function isPierComplete():Boolean {
			var complete:Boolean = true;
			for (var i:int = 0; i < bridges['line1'].length; i++) {
				var place:Object = bridges['line1'][i];
				if (App.map._aStarNodes[place.x][place.z].object is Bridge) {
					
				}else {
					complete = false;
				}
			}
			return complete;
		}
		
		public function isLineComplete(line:String, type:String = 'light'):Boolean 
		{
			var complete:Boolean = false;
			if (type != 'light')
				return complete;
			
			var _bridges:Array = Map.findUnitsByType(['Bridge']);
			var lineBridges:Array = [];
			
			for each(var _bridge:Bridge in _bridges) {
				if (_bridge.line == line)
					lineBridges.push(_bridge);
			}
			
			_bridge = null;
			
			complete = true;
			for each(_bridge in lineBridges) {
				if (_bridge.info.side == 1 || _bridge.info.side == 2) {
					if (_bridge.level != _bridge.totalLevels)
						complete = false;
				}
			}
			
			return complete;
			
			/*for each(var place:Object in bridges[line]) 
			{
				var object:* = App.map._aStarNodes[place.x][place.z].object;
				if (object != null && object is Bridge) {
					
				}
				else
				{
					return false;
				}
			}
			
			unlock(bridges[line]);
			return true;*/
		}
		
		public function buildBridgeTiles():void 
		{
			var _tile:int = 631;
			if (info.front == 850 || info.front == 848)
				_tile = 851;
			
			for (var i:int = 1; i < bridges[line].length - 1; i++) {
				var _x:int = bridges[line][i].x;
				var _z:int = bridges[line][i].z;
				var _rotate:int = bridges[line][i].rotate;
				//if (App.map._aStarNodes[_x][_z].object == null) {
					var tile:Bridge = new Bridge( {
						sid:_tile,
						rotate:_rotate,
						x:_x,
						z:_z,
						hasSpirit:false
					});
					tile.clickable = false;
					tile.touchable = false;
					tile.take();
				/*}
				else
				{
					return;
				}*/
			}
			///bridges[line] = [bridges[line][0], bridges[line][bridges[line].length - 1]];
		}
		
		override public function onAfterBuy(e:AppEvent):void
		{
			super.onAfterBuy(e);
			
			// назначаем к какой линии принадлежит мост
			for (var i:int = 0; i < possiblePlaces.length; i++) {
				var place:Object = possiblePlaces[i].place;
				if (place.x == coords.x && place.z == coords.z) {
					line = possiblePlaces[i].line;
				}
			}
			//if(line != null)
				//Bridge.checkLine(line);
			hideSpirits();
		}
		
		public function hideSpirits():void {
			possiblePlaces = [];
			for each(var spirit:Spirit in spirits)
				App.map.mLand.removeChild(spirit);
				
			spirits = [];
		}
		
		public var possiblePlaces:Array = [];
		public var spirits:Array = [];
		override public function onLoad(data:*):void 
		{
			super.onLoad(data);
			
			if (info.view == 'pier') {
				defindLevel();
			}
		}
		
		private function drawSpririt(nextPlace:Object):void 
		{
			var levelData:Object = textures.sprites[this.level];
			var place:Object = IsoConvert.isoToScreen(nextPlace.x, nextPlace.z, true);
			var spirit:Spirit = new Spirit(levelData.bmp);
			spirit.x = place.x + levelData.dx;
			spirit.y = place.y + levelData.dy;
			
			App.map.mLand.addChildAt(spirit, 0);
			spirit.showGlowing();
			spirits.push(spirit);
			
			if (id == 0)
				App.map.focusedOn(spirit);
		}	
		
		public function defindLevel():void 
		{
			var place:Object
			if (formed) {
				place = {
					x:coords.x,
					z:coords.z
				}
			}
			else
			{
				possiblePlaces = Bridge.findPlaceBridges(info.view);
				if (possiblePlaces.length == 0)
					return;
					
				place = possiblePlaces[0].place;	
			}
			
			for (var j:int = 0; j<bridges['line1'].length; j++) {
				if (place.x == bridges['line1'][j].x) {
					if (place.z == bridges['line1'][j].z) {
						if (j == 0)
							level = 0;
						else if (j == bridges['line1'].length - 1)	
							level = 2;
						else
							level = 1;
					}
				}
			}
			updateLevel();
			
			if (hasSpirit && !formed)
				drawSpririt(place);
		}
		
		override public function calcDepth():void {
			
			var left:Object;
			var right:Object;
			
			if (info.side == 1 || info.side == 2) {
				left = { x:x - IsoTile.width * 1 * .5, y:y + IsoTile.height * 1 * .5 };
				right = { x:x + IsoTile.width * 1 * .5, y:y + IsoTile.height * 1 * .5 };
				depth = (left.x + right.x) + (left.y + right.y) * 100;
				return;
			}
			
			/*if (info.view.indexOf('front') == -1)
			{
				var left:Object = { x:x - IsoTile.width * -rows * .5, y:y + IsoTile.height * -rows * .5 };
				var right:Object = { x:x + IsoTile.width * cells * .5, y:y + IsoTile.height * cells * .5 };
				depth = (left.x + right.x) + (left.y + right.y) * 100;
			}*/
			if (info.side == 0) 
			{
				left = { x:x, y:y + 50};
				right = { x:x, y:y + 50};
				depth = (left.x + right.x) + (left.y + right.y) * 100;
				return;
			}
			
			super.calcDepth();
		}
		
		override public function uninstall():void {
			super.uninstall();
			hideSpirits();
		}
		
		override public function calcState(node:AStarNodeVO):int
		{
			//return EMPTY;
			if (info.view == 'pier') 
			{
				var check:Boolean = false;
				for each(var place:Object in possiblePlaces) {
					if (place.place.x == coords.x && place.place.z == coords.z) {
						
						check = true;
					}
				}
				if (!check) return OCCUPIED;
			}
			
			for (var i:uint = 0; i < cells; i++) {
				for (var j:uint = 0; j < rows; j++) {
					node = App.map._aStarNodes[coords.x + i][coords.z + j];
					if (node.open == false || node.object != null) {//node.w != 1 || 
						return OCCUPIED;
					}
				}
			}
			
			return EMPTY;
		}
		
		override public function click():Boolean
		{
			if (!clickable || id == 0 || (App.user.mode == User.GUEST && touchableInGuest == false)) return false;
			App.tips.hide();
				
			if (level < totalLevels) 
			{
				if (App.user.mode == User.OWNER)
				{
					// Открываем окно постройки
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
			}
			else
			{
				App.map.click();
				return false;
			}
			
			return true;
		}
		
		override public function set touch(touch:Boolean):void 
		{
			if ((!moveable && Cursor.type == 'move') ||
				(!removable && Cursor.type == 'remove') ||
				(!rotateable && Cursor.type == 'rotate'))// ||
				//(!touchableCursor.type == 'default')
			{
				//if (info.view != 'pier')
					return;
			}
			
			super.touch = touch;
		}
		
		override public function take():void 
		{
			
			//super.take();
			//	return;
			//unlock(App.map.info.bridges['line1']);
			
			//return;
			var node:AStarNodeVO;
			var part:AStarNodeVO;
			var water:AStarNodeVO;
			
			var nodes:Vector.<AStarNodeVO> = new Vector.<AStarNodeVO>();
			var parts:Vector.<AStarNodeVO> = new Vector.<AStarNodeVO>();
			var waters:Vector.<AStarNodeVO> = new Vector.<AStarNodeVO>();
			
			for (var i:int = -2; i < cells; i++) {//+2
				for (var j:int = -2; j < rows; j++) {//+2
					node = App.map._aStarNodes[coords.x + i][coords.z + j];
					nodes.push(node);
					//node.isWall = false;
					node.object = this;
					
					part = App.map._aStarParts[coords.x + i][coords.z + j];
					parts.push(part);
					//part.isWall = false;
					part.object = this;
					
					if (info.view == 'pier') {
						water = App.map._aStarWaterNodes[coords.x + i][coords.z + j];
//						part.isWall = true;
						water.object = this;
						water.isWall = true;
						waters.push(water);
					}
				}
			}
			
			if (info.view == 'pier') {
				App.map._astarWater.take(waters);
			}
		}
		
		public static function findPlaceBridges(view:String = "light"):Array 
		{
			if (bridges == null) return [];
			var _bridges:Array = [];
			
			if (view == 'pier')
				_bridges = Map.findUnitsByTypeinLand(['Bridge']);
			else
				_bridges = Map.findUnitsByType(['Bridge']);
			
			var result:Array = [];
			for (var lineName:String in bridges) 
			{
				var mapBridges:Array = bridges[lineName];
				for (var i:int = 0; i < mapBridges.length; i++) {
					var bridge:Bridge = findBridgeOnThisPlace(mapBridges[i]);
					if (bridge == null) {
						result.push( { place:mapBridges[i], line:lineName } );
						break;
					}
				}
			}
			return result;
			
			function findBridgeOnThisPlace(place:Object):Bridge
			{
				for (var i:int = 0; i < _bridges.length; i++) 
				{
					var bridge:Bridge = _bridges[i];
					if (bridge.coords.x == place.x && bridge.coords.z == place.z) 
					{
						return bridge;
					}
				}
				
				return null;
			}
		}
		
		public static function init(bridges:Object):void {
			
			Bridge.bridges = bridges;
			// блокируем лини переходов
			lockLines(bridges);
		}
		
		public static function lockLines(bridges:Object):void {
			for (var lineName:String in bridges) {
				lock(bridges[lineName]);
			}
		}
		
		private static function lock(bridges:Array):void {
			var node:AStarNodeVO;
			var part:AStarNodeVO;
			var nodes:Vector.<AStarNodeVO> = new Vector.<AStarNodeVO>();
			var parts:Vector.<AStarNodeVO> = new Vector.<AStarNodeVO>();
			for (var i:uint = 0; i < bridges.length; i++) {
				var bridge:Object = bridges[i];
				for (var _i:uint = 0; _i < 3; _i++) {
					for (var _j:uint = 0; _j < 3; _j++) {
						node = App.map._aStarNodes[bridge.x + _i][bridge.z + _j];
						node.isWall = true;
						nodes.push(node);
						
						part = App.map._aStarParts[bridge.x + _i][bridge.z + _j];
						part.isWall = true;
						parts.push(part);
					}
				}
			}	
			
			App.map._astar.take(nodes);
			App.map._astarReserve.take(parts);
		}
		
		private static function unlock(bridges:Array):void {
			var node:AStarNodeVO;
			var part:AStarNodeVO;
			var nodes:Vector.<AStarNodeVO> = new Vector.<AStarNodeVO>();
			var parts:Vector.<AStarNodeVO> = new Vector.<AStarNodeVO>();
			for (var i:uint = 0; i < bridges.length; i++) {
				var bridge:Object = bridges[i];
				for (var _i:uint = 0; _i < 3; _i++) {
					for (var _j:uint = 0; _j < 3; _j++) {
						node = App.map._aStarNodes[bridge.x + _i][bridge.z + _j];
						node.isWall = false;
						nodes.push(node);
						
						part = App.map._aStarParts[bridge.x + _i][bridge.z + _j];
						part.isWall = false;
						parts.push(part);
					}
				}
			}	
			
			App.map._astar.free(nodes);
			App.map._astarReserve.free(parts);
		}
		
		public static function showMessage():void 
		{
			if (!App.map.info.hasOwnProperty('bridges')) return;
			
			new SimpleWindow( {
				title:Locale.__e('flash:1382952379891'),
				label:SimpleWindow.ATTENTION,
				text:Locale.__e('flash:1382952379892')
			}).show();
			
		}
		
		override protected function onStockAction(error:int, data:Object, params:Object):void {
			if (error) {
				Errors.show(error, data);
				return;
			}
			
			App.map.moved = null;
			this.id = data.id;
			
			// назначаем к какой линии принадлежит мост
			for (var i:int = 0; i < possiblePlaces.length; i++) {
				var place:Object = possiblePlaces[i].place;
				if (place.x == coords.x && place.z == coords.z) {
					line = possiblePlaces[i].line;
				}
			}
			//if(line != null)
				//Bridge.checkLine(line);
			hideSpirits();
			clickable = false;
			touchable = false;
			state = DEFAULT;
			check();
			App.ui.flashGlowing(this);
		}
	}	
}
import flash.display.Bitmap;
import flash.display.BitmapData;

internal class Spirit extends LayerX
{
	private var bitmap:Bitmap = new Bitmap();
	public function Spirit(bmd:BitmapData) 
	{
		bitmap.bitmapData = bmd;
		bitmap.alpha = 0.5;
		addChild(bitmap);
	}
}


