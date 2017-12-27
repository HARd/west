package com.pathfinder
{
	public class Node extends Coordinate
	{
		public var parent:Node;
		public var isWalkable:Boolean;
		public var f:Number;
		public var g:Number;

		public function Node( p_x:int, p_y:int, p_isWalkable:Boolean = true )
		{
			isWalkable = p_isWalkable;
			super( p_x, p_y );
		}

		override public function toString():String
		{
			var l_result:String;
			l_result = "[Node(" + x + "," + y + ")";
			if ( parent != null )
			{
				l_result += ", parent=(" + parent.x + "," + parent.y + ")";
			}
			l_result += ", " + ( isWalkable ? "W" : "X" );
			l_result += ", f=" + f;
			l_result += ", g=" + g;
			l_result += "]";
			return l_result;
		}
	}
}
