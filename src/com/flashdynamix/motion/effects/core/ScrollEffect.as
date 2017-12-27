package com.flashdynamix.motion.effects.core {
	import flash.display.BitmapData;
	
	import com.flashdynamix.motion.effects.IEffect;	

	/**
	 * Scrolls the BitmapData in either an x or y direction
	 */
	public class ScrollEffect implements IEffect {

		/**
		 * The x scroll amount in pixels.
		 */
		public var xDir : int;
		/**
		 * The y scroll amount in pixels.
		 */
		public var yDir : int;

		/**
		 * @param xDir The x scroll amount in pixels.
		 * @param yDir The y scroll amount in pixels.
		 */
		function ScrollEffect(xDir : int = 0, yDir : int = 0) {
			this.xDir = xDir;
			this.yDir = yDir;
		}

		/**
		 * Scrolls the specified BitmapData in either an x or y direction.
		 */
		public function render(bmd : BitmapData) : void {
			bmd.scroll(xDir, yDir);
		}
	}
}
