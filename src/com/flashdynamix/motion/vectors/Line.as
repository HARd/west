package com.flashdynamix.motion.vectors {
	import flash.display.Graphics;
	import flash.geom.Point;
	import flash.geom.Rectangle;	

	/**
	 * Defines a straight Line vector path to be drawn by a VectorLayer.
	 */
	public class Line implements IVector {

		/**
		 * The style parameters to use when the line is drawn via the Graphics.lineStyle method.
		 */
		public var style : Array = [1, 0xFFFFFF];
		/**
		 * A list of Points defining the path
		 */
		public var pts : Array;

		/**
		 * @param pts A list of Points defining the Line path.
		 */
		public function Line(...pts : Array) {
			this.pts = pts;
		}

		/**
		 * @return The Point at the specified index.
		 */
		public function index(index : int) : Point {
			return pts[index];
		}

		/**
		 * Adds a Point into the Line path at the specified index.
		 * @param index The index at which to insert the Point.
		 * @param pt The Point to insert at the index.
		 */
		public function addAt(index : int, pt : Point) : void {
			pts.splice(index, 0, pt);
		}

		/**
		 * Pushes a Point into the Line path.
		 * @param pt The Point which will be added to the end of the Line path.
		 */
		public function push(pt : Point) : void {
			pts.push(pt);
		}

		/**
		 * Unshifts a Point from the Line path.
		 * @param pt The Point which will be unshifted to the Line path.
		 */
		public function unshift(pt : Point) : void {
			pts.unshift(pt);
		}

		/**
		 * Removes a Point from the Line path.
		 * @param pt The Point you would like to remove from the Line path.
		 */
		public function remove(pt : Point) : void {
			var index : int = pts.indexOf(pt);
			if(index != -1) removeAt(index, 1);
		}

		/**
		 * Removes one or more Points at the specified index and count from the Line path. 
		 * @param index The index to start removing nodes from the Line path.
		 * @param count the Number of nodes to remove from the Line path. If this is 0 no nodes are removed.
		 * 
		 */
		public function removeAt(index : int, count : int = 1) : void {
			pts.splice(index, count);
		}

		/**
		 * @return The number of nodes in the Line path.
		 */
		public function get length() : int {
			return pts.length;
		}

		/**
		 * Will draw the Line path into the Graphics instance provided.
		 */
		public function draw(vector : Graphics, rect : Rectangle) : void {
			vector.lineStyle.apply(null, style);
			
			var pt : Point = pts[int(0)];
			vector.moveTo(pt.x, pt.y);
			for(var i : int = 1;i < pts.length; i++) {
				pt = pts[i];
				vector.lineTo(pt.x, pt.y);
			}
		}
	}
}
