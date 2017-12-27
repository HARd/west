package com.pathfinder
{
	import flash.display.Sprite;
	public class MapData extends Sprite
	{	
		public var rows:int;
		public var cells:int;

		private static var _THRESHOLD:Number = 0.1;
		
		private var _mapData:Vector.<Boolean>;
		
		public function MapData(p_cells:int, p_rows:int, _mapData:Vector.<Boolean>)
		{
			this._mapData = _mapData;
			cells = p_cells;
			rows = p_rows;
		}
		
		public function take(p_x:int, p_y:int):void {
			_mapData[ ( p_y * cells ) + p_x] = false;
		}
		public function free(p_x:int, p_y:int):void {
			_mapData[ ( p_y * cells ) + p_x] = true;
		}
		
		public function isWalkable( p_x:int, p_y:int ):Boolean
		{
			return _mapData[ ( p_y * cells ) + p_x];
		}
	}
}
	