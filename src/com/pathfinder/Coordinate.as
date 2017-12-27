package com.pathfinder
{
	public class Coordinate
	{
		public var x:int;
		public var y:int;

		public function Coordinate( p_x:int = 0, p_y:int = 0 )
		{
			x = p_x;
			y = p_y;
		}

		public function isEqualTo(p_coordinate:Coordinate):Boolean
		{
			return ( ( x == p_coordinate.x ) && ( y == p_coordinate.y ) );
		}

		public function toString():String
		{
			return "(" + x + "," + y + ")";
		}

		public function clone():Coordinate
		{
			return new Coordinate( x, y );
		}
	}
}