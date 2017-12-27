package com.flashdynamix.motion.effects.core {
	import flash.display.BitmapData;
	import flash.geom.*;

	import com.flashdynamix.motion.effects.IEffect;	

	/**
	 * Applies a seeded Dissolve effect on to a BitmapData
	 */
	public class DissolveEffect implements IEffect {

		/**
		 * The number of steps required to disolve a BitmapData from the original BitmapData to the destination BitmapData.
		 */
		public var steps : Number;
		/**
		 * The seed to use when rendering the dissolve effect this can be any number between 0 to int.MAX_VALUE.
		 */
		public var seed : int;
		/**
		 * The amount of offset which can be used to randomize the dissolve effect on each render from the seed value.
		 */
		public var seedOffset : int;
		/**
		 * The color used to fill for pixels when the source and dissolve BitmapData are the same.
		 */
		public var fillColor : uint;
		/**
		 * This BitmapData is used for the dissolved pixels.<BR>
		 * If you wish to dissolve to transparent pixels then create a BitmapData of transparent pixels.
		 */
		public var destBmd : BitmapData;
		/**
		 * The position from which to draw the dissolve effect.
		 */
		public var point : Point = new Point( );
		
		/**
		 * @param destBmd This BitmapData is used for the dissolved pixels.<BR>
		 * If you wish to dissolve to transparent pixels then create a BitmapData of transparent pixels.
		 * @param steps The number of steps required to disolve a BitmapData from the origion BitmapData to the destination BitmapData.
		 * @param seed The seed to use when rendering the dissolve effect this can be any number between 0 to int.MAX_VALUE
		 * @param seedOffset The amount of offset which can be used to randomize the dissolve effect on each render from the seed value
		 * @param fillColor The color used to fill for pixels when the source and dissolve BitmapData are the same
		 */		function DissolveEffect(destBmd : BitmapData, steps : Number = 10, seed : int = 0, seedOffset : int = int.MAX_VALUE, fillColor : uint = 0x00FFFFFF) {
			this.steps = steps;
			this.seed = seed;
			this.seedOffset = seedOffset;
			this.fillColor = fillColor;
			this.destBmd = destBmd;
		}

		/**
		 * Renders the DissolveEffect on to the specified BitmapData.
		 */		public function render(bmd : BitmapData) : void {
			bmd.pixelDissolve( destBmd , bmd.rect , point , seed + (Math.random( ) * seedOffset) , (bmd.width * bmd.height) / steps , fillColor );
		}
	}
}
