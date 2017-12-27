package com.flashdynamix.motion.effects.core {
	import flash.display.BitmapData;
	import flash.geom.*;
	
	import com.flashdynamix.motion.effects.IEffect;	

	/**
	 * Applies a threshold effects on to the BitmapData
	 */
	public class ThresholdEffect implements IEffect {

		/**
		 * One of the following comparison operators, passed as a String: "<", "<=", ">", ">=", "==", "!="
		 */
		public var operation : String = "<=";
		/**
		 * The 32-bit color value that each pixel is tested against to see if it meets or exceeds the threshhold.
		 */
		public var threshold : uint = 0x50FFFFFF;
		/**
		 * The 32-bit color value that a pixel is set to if the threshold test succeeds.<BR>
		 * The default value is 0x00000000.
		 */
		public var replaceColor : uint = 0x00FFFFFF;
		/**
		 * The mask to use to isolate a 32-bit color component.
		 */
		public var maskColor : uint = 0xFFFFFFFF;
		/**
		 * If the value is true, pixel values from the source image are copied to the destination when the threshold test fails.<BR>
		 * If the value is false, the source image is not copied when the threshold test fails.
		 */
		public var copySource : Boolean = false;
		/**
		 * The point within the destination image (the current BitmapData instance) that corresponds to the upper-left corner of the source rectangle.
		 */
		public var point : Point = new Point();

		/**
		 * @param operation One of the following comparison operators, passed as a String: "<", "<=", ">", ">=", "==", "!="
		 * @param threshold The 32-bit color value that each pixel is tested against to see if it meets or exceeds the threshhold.
		 * @param replaceColor The 32-bit color value that a pixel is set to if the threshold test succeeds.
		 * @param maskColor The mask to use to isolate a 32-bit color component.
		 * @param copySource If the value is true, pixel values from the source image are copied to the destination when the threshold test fails.
		 */
		public function ThresholdEffect(operation : String = "<=", threshold : uint = 0x50FFFFFF, replaceColor : uint = 0x00FFFFFF, maskColor : uint = 0xFFFFFFFF, copySource : Boolean = false) {
			this.operation = operation;
			this.threshold = threshold;
			this.replaceColor = replaceColor;
			this.maskColor = maskColor;
			this.copySource = copySource;
		}

		/**
		 * Renders the ThresholdEffect on to the specified BitmapData.
		 */
		public function render(bmd : BitmapData) : void {
			bmd.threshold(bmd, bmd.rect, point, operation, threshold, replaceColor, maskColor, copySource);
		}
	}
}
