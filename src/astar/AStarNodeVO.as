package astar
{
	import core.IsoTile;
	import flash.geom.Point;
	import units.Freezer;
	import units.Unit;
	
	public class AStarNodeVO
	{
		
		public var
			h : uint,
			f : uint,
			g : uint,
			cost : uint,
			visited : Boolean,
			closed : Boolean,
			isWall : Boolean,
			position : Point,
			parent : AStarNodeVO,
			next : AStarNodeVO,
			neighbors : Vector.<AStarNodeVO>,
			zone : uint,
			object : Unit,
			tile : IsoTile,
			open:Boolean = false,
			z : int,
			b : int,
			p : int,
			w : int,
			freezers:Vector.<Freezer>;
		
		public function AStarNodeVO(cost:uint = 1)
		{
			this.cost = cost;
		}
	}
}