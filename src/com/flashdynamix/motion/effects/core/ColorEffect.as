package com.flashdynamix.motion.effects.core {
	import flash.display.BitmapData;
	import flash.geom.*;
	import flash.utils.*;
	
	import com.flashdynamix.motion.effects.IEffect;	

	/**
	 * Applies a ColorTransform onto a BitmapData
	 */
	public class ColorEffect extends Proxy implements IEffect {
		/**
		 * The ColorTransform to apply onto the destination BitmapData.
		 */
		public var colorTransform : ColorTransform;
		/**
		 * @param colorTransform The ColorTransform to apply onto the destination BitmapData.
		 */
		public function ColorEffect(colorTransform : ColorTransform) {
			this.colorTransform = colorTransform;
		}
		override flash_proxy function setProperty(name : *, value : *) : void {
			colorTransform[name] = value;
		}
		override flash_proxy function getProperty(name : *) : * {
			return colorTransform[name];
		}
		/**
		 * Renders the ColorEffect to the specified BitmapData.
		 */
		public function render(bmd : BitmapData) : void {
			bmd.colorTransform(bmd.rect, colorTransform);
		}
	}
}
