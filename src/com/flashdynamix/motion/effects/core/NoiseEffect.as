package com.flashdynamix.motion.effects.core {
	import flash.display.BitmapData;
	import flash.display.BitmapDataChannel;
	
	import com.flashdynamix.motion.effects.IEffect;	

	/**
	 * Applies a static noise effect on to the BitmapData
	 */
	public class NoiseEffect implements IEffect {

		/**
		 * The seed to use when rendering the noise effect this can be any number between 0 to int.MAX_VALUE.
		 */
		public var seed : int = 0;
		/**
		 * The amount of offset which can be used to randomize the noise effect on each render from the seed value.
		 */
		public var seedOffset : int = int.MAX_VALUE;
		/**
		 *  The lowest value to generate for each channel (0 to 255)
		 */
		public var low : int = 0;
		/**
		 * The highest value to generate for each channel (0 to 255)
		 */
		public var high : int = 255;
		/**
		 * A Boolean value. If the value is true, a grayscale image is created by setting all of the color channels to the same value. <BR>
		 * The alpha channel selection is not affected by setting this parameter to true.
		 */
		public var grayScale : Boolean = true;
		/**
		 * A number that can be a combination of any of the four color channel values :
		 * <ul>
		 * <li>BitmapDataChannel.RED</li>
		 * <li>BitmapDataChannel.BLUE</li>
		 * <li>BitmapDataChannel.GREEN</li>
		 * <li>BitmapDataChannel.ALPHA</li>
		 * </ul>
		 * You can use the bitwise OR operator (|) to combine channel values.
		 */
		public var channelOptions : uint = BitmapDataChannel.RED | BitmapDataChannel.GREEN | BitmapDataChannel.BLUE;

		public function NoiseEffect() {
		}

		/**
		 * Renders the static noise effect onto the BitmapData.
		 */
		public function render(bmd : BitmapData) : void {
			bmd.noise(seed + (seedOffset * Math.random()), low, high, channelOptions, grayScale);
		}
	}
}
