package com.flashdynamix.motion.effects.core {
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.geom.*;
	import com.flashdynamix.motion.effects.IEffect;	
	/**
	 * Copys a BitmapData onto another BitmapData, this method for drawing is an extremely efficient way of updating the 
	 * display in Flash, although CopyEffect has limitations, which is part of the reason why it's so much faster. 
	 * CopyEffect can only use a x,y position transform unlike the DrawEffect which can accept a matrix and color transformations. 
	 * This means that scale, rotation, skew, alpha and color transformations can not be done with a CopyEffect.
	 */
	public class CopyEffect implements IEffect {
		/**
		 * The source BitmapData to copy onto the destination BitmapData.
		 */
		public var sourceBmd : BitmapData;
		/**
		 * The clipping rectangle to use when drawing the source BitmapData onto the destination BitmapData.
		 */
		public var sourceRect : Rectangle;
		/**
		 * The destination point to draw the sourceRect from.
		 */
		public var point : Point;
		/**
		 * The alphaBmd ALPHA channel to use when copying the BitmapData, if one is desired other than the ALPHA.
		 * channel in the sourceBmd 
		 */
		public var alphaBmd : BitmapData;
		/**
		 * The point to draw the ALPHA channel from using the alphaBmd.
		 */
		public var alphaPt : Point;
		/**
		 * Whether both ALPHA channels are merged between the sourceBmd and the alphaBmd.
		 */
		public var mergeAlpha : Boolean;
		/**
		 * @param sourceBmd The source BitmapData to copy onto the destination BitmapData.
		 * @param sourceRect The clipping rectangle to use when drawing the source BitmapData onto the destination BitmapData.
		 * @param point The destination point to draw the sourceRect from.
		 * @param alphaBmd The alphaBmd ALPHA channel to use when copying the BitmapData if another is desired other than the ALPHA
		 * channel in the sourceBmd.
		 * @param alphaPt The point to draw the ALPHA channel from using the alphaBmd.
		 * @param mergeAlpha Whether both ALPHA channels are merged between the sourceBmd and the alphaBmd.
		 */
		public function CopyEffect(source : DisplayObject, ct : ColorTransform, mtx : Matrix, sourceRect : Rectangle = null, point : Point = null, alphaBmd : BitmapData = null, alphaPt : Point = null, mergeAlpha : Boolean = false) {
			this.sourceBmd = new BitmapData(source.width, source.height, true, 0x00FFFFFF);
			this.sourceBmd.draw(source, mtx, ct);
			
			this.sourceRect = (sourceRect == null) ? sourceBmd.rect : sourceRect;
			this.point = (point == null) ? new Point() : point;
			this.alphaBmd = alphaBmd;
			this.alphaPt = alphaPt;
			this.mergeAlpha = mergeAlpha;
		}
		/**
		 * Renders the CopyEffect to the specified BitmapData.
		 */
		public function render(bmd : BitmapData) : void {
			bmd.copyPixels(sourceBmd, sourceRect, point, alphaBmd, alphaPt, mergeAlpha);
		}
	}
}
