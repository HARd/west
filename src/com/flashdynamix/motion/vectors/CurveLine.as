package com.flashdynamix.motion.vectors {
	import flash.display.Graphics;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import com.flashdynamix.motion.vectors.Line;	

	/**
	 * Defines a CurveLine vector path to be drawn by a VectorLayer.
	 */
	public class CurveLine extends Line implements IVector {

		/**
		 * Whether the pts in the CurveLine will be used as control points or through points.
		 */
		public var through : Boolean = false;

		/**
		 * @param through Whether the pts in the CurveLine will be used as control points or through points.
		 * @param pts A list of Points defining the CurveLine path.
		 */
		public function CurveLine(through : Boolean = false, ...pts : Array) {
			super(pts);
			this.through = through;
			this.pts = pts;
		}

		/**
		 * Draws the CurveLine path into the Graphics instance provided.
		 */
		override public function draw(vector : Graphics, rect : Rectangle) : void {
			if(pts.length <= 2) return;
			
			var pt : Point = index(0);
			var cPt : Point;
			
			vector.lineStyle.apply(null, style);
			vector.moveTo(pt.x, pt.y);
			
			if(through) {
				cPt = index(2).subtract(pt);
				cPt.x /= 4;
				cPt.y /= 4;
				cPt = index(1).subtract(cPt);
				
				pt = index(1);
				
				vector.curveTo(cPt.x, cPt.y, pt.x, pt.y);
				
				for(var i : int = 1;i < pts.length - 1; i++) {
					cPt = index(i).add(index(i).subtract(cPt));
					pt = index(i + 1);
					
					vector.curveTo(cPt.x, cPt.y, pt.x, pt.y);
				}
			} else {
				for(var j : int = 1;j < pts.length - 1; j += 2) {
					cPt = index(j);
					pt = index(j + 1);
					
					vector.curveTo(cPt.x, cPt.y, pt.x, pt.y);
				}
			}
		}
	}
}
