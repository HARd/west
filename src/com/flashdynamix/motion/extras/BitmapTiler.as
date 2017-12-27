package com.flashdynamix.motion.extras {
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.geom.Matrix;	
	/**
	 * Allows for x,y scrolling tile animations.
	 */
	public class BitmapTiler extends Sprite {
		/**
		 * The BitmapData source for the scrolling tile.
		 */
		public var source : BitmapData;
		/**
		 * The tile width in pixels used.
		 */
		public var tileWidth : int;
		/**
		 * The tile height in pixels used.
		 */
		public var tileHeight : int;
		/**
		 * Whether the BitmapTiler applies smoothing.
		 */
		public var smooth : Boolean = false;
		private var _offsetX : Number = 0;
		private var _offsetY : Number = 0;
		private var mtx : Matrix = new Matrix();
		public function BitmapTiler(source : BitmapData, tileWidth : int = 0, tileHeight : int = 0) {
			this.source = source;
			this.tileWidth = (tileWidth == 0) ? source.width : tileWidth;
			this.tileHeight = (tileHeight == 0) ? source.height : tileHeight;
			
			refresh();
		}
		/**
		 * Sets the x offset in pixels for the bitmap tile. Increment this property to animate the tile in a left or right direction.
		 */
		public function set offsetX(num : Number) : void {
			_offsetX = num;
			refresh();
		}
		/**
		 * Gets the x offset for the bitmap tile in pixels
		 */
		public function get offsetX() : Number {
			return _offsetX;
		}
		/**
		 * Sets the y offset in pixels for the bitmap tile. Increment this property to animate the tile in a upwards or downwards direction.
		 */
		public function set offsetY(num : Number) : void {
			_offsetY = num;
			refresh();
		}
		/**
		 * Gets the y offset for the bitmap tile in pixels.
		 */
		public function get offsetY() : Number {
			return _offsetY;
		}
		private function refresh() : void {
			mtx.tx = _offsetX;
			mtx.ty = _offsetY;
			
			var vec : Graphics = this.graphics;
			vec.clear();
			vec.beginBitmapFill(source, mtx, true, smooth);
			vec.drawRect(0, 0, tileWidth, tileHeight);
			vec.endFill();
		}
	}
}
