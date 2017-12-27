package com.pathfinder
{
	
	import com.pathfinder.MapData;
	
	public class Pathfinder
	{
		private static var _COST_ADJACENT:int = 10;
		private static var _COST_DIAGIONAL:int = 14;

		private var _map:MapData;
		private var _timeOutDuration:int;
		private var _cols:int;
		private var _rows:int;
		private var _nodes:Vector.<Vector.<Node>>;
		
		private var _openList:Vector.<Node>;
		private var _closedList:Vector.<Node>;
		private var _isCompleted:Boolean;
		
		private var _startNode:Node;
		private var _destNode:Node;
		public static var self:Pathfinder;
		
		public static function init(_mapData:MapData):void {
			self = new Pathfinder(_mapData);
		}
		
		
		/*public static function findPath(start:Object, finish:Object):Vector.<AStarNodeVO> {
			
			var startNode:Coordinate = new Coordinate(start.x, start.z);
			var finishNode:Coordinate = new Coordinate(finish.x, finish.z);
			
			var path:Vector.<Coordinate> = self.createPath(startNode, finishNode);
			if (path == null) 
				return null;
				
			var _path:Vector.<AStarNodeVO> = new Vector.<AStarNodeVO>();
			for (var i:int = 0; i < path.length; i++) {
				var coord:Coordinate = path[i];
				var _node:AStarNodeVO = App.map._aStarNodes[coord.x][coord.y];
				_path.push(_node);
			}
			
			return _path;
		}*/
		
		public function Pathfinder(_map:MapData, p_timeOutDuration:int = 10000)
		{
			configure(_map, p_timeOutDuration );
		}

		public function configure( _map:MapData, p_timeOutDuration:int = 10000 ):void
		{
			this._map = _map;
			this._timeOutDuration = p_timeOutDuration;
			_nodes = new Vector.<Vector.<Node>>
			_cols = _map.cells;
			_rows = _map.rows;
			
			for (var l_ix:int = 0; l_ix < _cols; l_ix++)
			{
				var l_line:Vector.<Node> = _nodes[l_ix] = new Vector.<Node>;
				for (var l_iy:int = 0; l_iy < _rows; l_iy++)
				{
					l_line[l_iy] = new Node( l_ix, l_iy, _map.isWalkable( l_ix, l_iy ));
				}
			}
		}

		private var p_heuristic:String = EHeuristic.PRODUCT;
		private function _getCost( p_node1:Node, p_node2:Node):Number
		{
			switch( p_heuristic )
			{
				case EHeuristic.DIAGONAL		: return  _getCostDiagonal( p_node1, p_node2 );
				case EHeuristic.PRODUCT 		: return  _getCostProduct( p_node1, p_node2 );
				case EHeuristic.EUCLIDIAN 		: return  _getCostEuclidian( p_node1, p_node2 );
				case EHeuristic.MANHATTAN		: return  _getCostManhattan( p_node1, p_node2 );
			}
			
			return  _getCostDiagonal( p_node1, p_node2 );
		}
		
		private function _getCostDiagonal( p_node1:Node, p_node2:Node ):Number
		{
			var l_dx:int = _intAbs( p_node1.x - p_node2.x );
			var l_dy:int = _intAbs( p_node1.y - p_node2.y );
			var l_diag:int = _intMin( l_dx, l_dy );
			var l_straight:int = l_dx + l_dy;
			return ( _COST_ADJACENT * ( l_straight - ( 2 * l_diag ) ) ) + ( _COST_DIAGIONAL * l_diag );
		}

		private function _getCostProduct( p_node1:Node, p_node2:Node ):Number
		{
			var l_dx1:int = _intAbs( p_node1.x - _destNode.x );
			var l_dy1:int = _intAbs( p_node1.y - _destNode.y );
			var l_dx2:int = _intAbs( _startNode.x - _destNode.x );
			var l_dy2:int = _intAbs( _startNode.y - _destNode.y );
			var l_cross:Number = _intAbs( ( l_dx1 * l_dy2 ) - ( l_dx2 * l_dy1 ) ) * .01;
			return _getCostDiagonal( p_node1, p_node2 ) + l_cross;
		}

		private function _getCostEuclidian( p_node1:Node, p_node2:Node ):Number
		{
			var l_dx:int = _intAbs( p_node1.x - p_node2.x );
			var l_dy:int = _intAbs( p_node1.y - p_node2.y );
			return Math.sqrt( ( l_dx * l_dx ) + ( l_dy * l_dy ) ) * _COST_ADJACENT;
		}

		private function _getCostManhattan( p_node1:Node, p_node2:Node ):Number
		{
			var l_dx:int = p_node1.x - p_node2.x;
			var l_dy:int = p_node1.y - p_node2.y;
			return ( ( l_dx > 0 ? l_dx : -l_dx ) + ( l_dy > 0 ? l_dy : -l_dy ) ) * _COST_ADJACENT;
		}

		/**
		 * Calculates an A Star path between two nodes on a boolean map
		 * @param	p_start	The starting node
		 * @param	p_dest	The destination node
		 * @param	p_heuristic	The method of A Star used
		 * @param	p_isDiagonalEnabled	Set to true to ensure only up, left, down, right movements are allowed
		 * @param	p_isMapDynamic	Set to true to force fresh lookups from IMap.isWalkable() for each node's isWalkable property (e.g. for a dynamically changing map)
		 * @return	An array of coordinates from start to destination, or null if no path was found within the time limit
		 */
		public function createPath( p_start:Coordinate, p_dest:Coordinate, p_heuristic:String = EHeuristic.PRODUCT, p_isDiagonalEnabled:Boolean = true, p_isMapDynamic:Boolean = false ):Vector.<Coordinate>
		{
			if ( !_map.isWalkable( p_start.x, p_start.y ) || !_map.isWalkable( p_dest.x, p_dest.y ) || p_start.isEqualTo( p_dest ) )
			{
				return null;
			}
			_openList = new Vector.<Node>();
			_closedList = new Vector.<Node>();
			_startNode = _nodes[p_start.x][p_start.y];
			_destNode = _nodes[p_dest.x][p_dest.y];
			_startNode.g = 0;
			_startNode.f = _getCost( _startNode, _destNode );
			_openList.push( _startNode );
			return _searchPath( p_heuristic, p_isDiagonalEnabled, p_isMapDynamic );
		}

		private function _getPath():Vector.<Coordinate>
		{
			var l_path:Vector.<Coordinate> = new Vector.<Coordinate>();
			var l_node:Node = _destNode;
			l_path[0] = l_node.clone();
			do
			{
				l_node = l_node.parent;
				l_path.unshift( l_node.clone() );
				if ( l_node == _startNode )
				{
					break;
				}
			}
			while ( true );
			return l_path;
		}

		private function _searchPath( p_heuristic:String, p_isDiagonalEnabled:Boolean = true, p_isMapDynamic:Boolean = false ):Vector.<Coordinate>
		{
			var l_minX:int, l_maxX:int, l_minY:int, l_maxY:int;
			var l_isWalkable:Boolean;
			var l_g:Number, l_f:Number, l_cost:Number;
			var l_nextNode:Node = null;
			var l_currentNode:Node = _startNode;
			//var l_startTime = Timer.stamp();
			_isCompleted = false;
			while ( !_isCompleted )
			{
				l_minX = l_currentNode.x - 1 < 0 ? 0 : l_currentNode.x - 1;
				l_maxX = l_currentNode.x + 1 >= _cols ? _cols - 1 : l_currentNode.x + 1;
				l_minY = l_currentNode.y - 1 < 0 ? 0 : l_currentNode.y - 1;
				l_maxY = l_currentNode.y + 1 >= _rows ? _rows - 1 : l_currentNode.y + 1;
				for ( var l_iy:int = l_minY;  l_iy < ( l_maxY + 1 ); l_iy++)
				{
					for ( var l_ix :int = l_minX;  l_ix  < ( l_maxX + 1 ); l_ix ++)
					{
						l_nextNode = _nodes[l_ix][l_iy];
						l_isWalkable = ( !p_isMapDynamic && l_nextNode.isWalkable ) || ( p_isMapDynamic && _map.isWalkable( l_ix, l_iy ) );
						if ( ( l_nextNode == l_currentNode ) || !l_isWalkable )
						{
							continue;
						}
						l_cost = _COST_ADJACENT;
						if ( !( ( l_currentNode.x == l_nextNode.x ) || ( l_currentNode.y == l_nextNode.y ) ) )
						{
							if ( !p_isDiagonalEnabled  )
							{
								continue;
							}
							l_cost = _COST_DIAGIONAL;
						}
						l_g = l_currentNode.g + l_cost;
						l_f = l_g + _getCost( l_nextNode, _destNode);
						if ( ( _openList.indexOf( l_nextNode ) != -1 ) || ( _closedList.indexOf( l_nextNode ) != -1 ) )
						{
							if ( l_nextNode.f > l_f )
							{
								l_nextNode.f = l_f;
								l_nextNode.g = l_g;
								l_nextNode.parent = l_currentNode;
							}
						}
						else
						{
							l_nextNode.f = l_f;
							l_nextNode.g = l_g;
							l_nextNode.parent = l_currentNode;
							_openList.push( l_nextNode );
						}
					}
					//_info.timeElapsed = Std.int( ( Timer.stamp() - l_startTime ) * 1000 );
					//if ( _info.timeElapsed > _timeOutDuration )
					//{
						//return null;
					//}
				}
				_closedList.push( l_currentNode );
				if ( _openList.length == 0 )
				{
					return null;
				}
				_openList.sort( _sort );
				l_currentNode = _openList.shift();
				if ( l_currentNode == _destNode )
				{
					_isCompleted = true;
				}
			}
			//_info.timeElapsed = Std.int( ( Timer.stamp() - l_startTime ) * 1000 );
			var l_path:Vector.<Coordinate> = _getPath();
			//_info.pathLength = l_path.length;
			return l_path;
		}
		
		private function _sort( p_x:Node, p_y:Node ):int
		{
			return ( p_x.f > p_y.f ) ? 1 : ( p_x.f < p_y.f ) ? -1 : 0;
		}
		
		private function _intAbs( p_value:int ):int
		{
			return ( p_value < 0 ) ? -p_value : p_value;
		}

		private function _intMin( p_v1:int, p_v2:int ):int
		{
			return ( p_v1 < p_v2 ) ? p_v1 : p_v2;
		}
	}
}