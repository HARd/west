package com.flashdynamix.motion.effects.core {
	import flash.display.BitmapData;
	import flash.geom.*;
	
	import com.flashdynamix.motion.effects.IEffect;	

	/**
	 * Merges the red, green and blue channels of a BitmapData with another BitmapData
	 */
	public class MergeEffect implements IEffect {

		/**
		 * The source BitmapData to be used to merge onto the destination BitmapData.
		 */
		public var sourceBmd : BitmapData;
		/**
		 * A hexadecimal color which defines the amount of the red channel to merge.
		 * i.e. 0x80 will be 50%
		 */
		public var redMultiplier : uint;
		/**
		 * A hexadecimal color which defines the amount of the green channel to merge.
		 * i.e. 0x80 will be 50%
		 */
		public var greenMultiplier : uint;
		/**
		 * A hexadecimal color which defines the amount of the blue channel to merge.
		 * i.e. 0x80 will be 50%
		 */
		public var blueMultiplier : uint;
		/**
		 * A hexadecimal color which defines the amount of the alpha channel to merge.
		 * i.e. 0x80 will be 50%
		 */
		public var alphaMultiplier : uint;
		/**
		 * The destination point to draw the sourceRect from.
		 */
		public var point : Point;
		/**
		 * The clipping rectangle to use when merging the source BitmapData onto the destination BitmapData.
		 */
		public var clipRect : Rectangle;

		/**
		 * @param sourceBmd The source BitmapData to be used to merge onto the destination BitmapData.
		 * @param redMultiplier A hexadecimal color which defines the amount of the red channel to merge.
		 * @param greenMultiplier A hexadecimal color which defines the amount of the green channel to merge.
		 * @param blueMultiplier A hexadecimal color which defines the amount of the blue channel to merge.
		 * @param alphaMultiplier A hexadecimal color which defines the amount of the alpha channel to merge.
		 * @param point The destination point to draw the sourceRect from.
		 * @param clipRect The clipping rectangle to use when merging the source BitmapData onto the destination BitmapData.
		 */
		function MergeEffect(sourceBmd : BitmapData, redMultiplier : uint = 0, greenMultiplier : uint = 0, blueMultiplier : uint = 0, alphaMultiplier : uint = 0, point : Point = null, clipRect : Rectangle = null) {
			this.sourceBmd = sourceBmd;
			
			this.redMultiplier = redMultiplier;
			this.greenMultiplier = greenMultiplier;
			this.blueMultiplier = blueMultiplier;
			this.alphaMultiplier = alphaMultiplier;
			
			this.point = (point == null) ? new Point() : point;
			this.clipRect = (clipRect == null) ? sourceBmd.rect : clipRect;
		}

		/**
		 * Renders the MergeEffect to the specified BitmapData.
		 */
		public function render(bmd : BitmapData) : void {
			bmd.merge(sourceBmd, clipRect, point, redMultiplier, greenMultiplier, blueMultiplier, alphaMultiplier);
		}
	}
}
