package com.flashdynamix.motion.effects.core {
	import flash.display.*;
	import flash.geom.*;
	
	import com.flashdynamix.motion.effects.IEffect;	

	/**
	 * Draws an IBitmapDrawable onto a BitmapData with options to apply a Matrix transformation, 
	 * ColorTransform, BlendMode or clipping Rectangle onto the drawn BitmapData.
	 */
	public class DrawEffect implements IEffect {

		/**
		 * The source IBitmapDrawable to be drawn onto the BitmapData on render.
		 */		public var source : IBitmapDrawable;
		/**
		 * The Matrix transformation to be used on render of the IBitmapDrawable to the BitmapData.
		 */		public var matrix : Matrix;
		/**
		 * The ColorTransform to be used on render of the IBitmapDrawable to the BitmapData.
		 */		public var colorTransform : ColorTransform;
		/**
		 * The BlendMode to be used on render of the IBitmapDrawable to the BitmapData.
		 */		public var blendMode : String = BlendMode.NORMAL;
		/**
		 * The clipping Rectangle to be used on render of the IBitmapDrawable to the BitmapData.
		 */		public var rect : Rectangle;
		/**
		 * Whether the BitmapData will be drawn with pixel smoothing.
		 */		public var smoothing : Boolean = false;

		/**
		 * @param source The source IBitmapDrawable to be drawn onto the BitmapData on render.
		 * @param matrix The Matrix transformation to be used on render of the IBitmapDrawable to the BitmapData.
		 * @param clipRect The clipping Rectangle to be used on render of the IBitmapDrawable to the BitmapData.
		 * @param colorTransform The ColorTransform to be used on render of the IBitmapDrawable to the BitmapData.
		 * @param blendMode The BlendMode to be used on render of the IBitmapDrawable to the BitmapData.
		 * @param smoothing Whether the BitmapData will be drawn with pixel smoothing.
		 */		public function DrawEffect(source : IBitmapDrawable, matrix : Matrix = null, rect : Rectangle = null, colorTransform : ColorTransform = null, blendMode : String = "normal", smoothing : Boolean = false) {
			this.source = source;
			this.matrix = (matrix == null) ? new Matrix() : matrix;
			this.colorTransform = (colorTransform == null) ? new ColorTransform() : colorTransform;
			this.blendMode = blendMode;
			this.rect = rect;
			this.smoothing = smoothing;
		}

		/**
		 * Renders the DrawEffect on to the specified BitmapData.
		 */		public function render(bmd : BitmapData) : void {
			bmd.draw(source, matrix, colorTransform, blendMode, rect, smoothing);
		}
	}
}
