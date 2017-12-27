package com.flashdynamix.motion.effects.core {
	import flash.display.BitmapData;
	
	import com.flashdynamix.motion.effects.IEffect;	

	/**
	 * Draws a 32-bit hexadecimal colored pixel at an x,y co-ord
	 */
	public class PixelEffect implements IEffect {

		/**
		 * The hexadecimal color to draw the pixel with.
		 */
		public var color : uint;
		/**
		 * The x position in pixels to draw onto the BitmapData.
		 */
		public var x : Number;
		/**
		 * The y position in pixels to draw onto the BitmapData.
		 */
		public var y : Number;

		/**
		 * @param color The hexadecimal color to draw the pixel with.
		 * @param x The x position in pixels to draw onto the BitmapData.
		 * @param y The y position in pixels to draw onto the BitmapData.
		 */	
		public function PixelEffect(color : uint, x : Number,y : Number) {
			this.color = color;
			this.x = x;
			this.y = y;
		}

		/**
		 * Renders a 32-bit hexadecimal colored pixel at an x,y co-ord on to the specified BitmapData.
		 */
		public function render(bmd : BitmapData) : void {
			bmd.setPixel32(x, y, color);
		}
	}
}
