package com.flashdynamix.motion.effects {
	import flash.display.BitmapData;
	import flash.filters.ColorMatrixFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Point;

	import com.flashdynamix.motion.effects.IEffect;	

	/**
	 * @author FlashDynamix
	 */
	public class XRayEffect implements IEffect {

		private var ct : ColorTransform;
		private var colorMtx : ColorMatrixFilter;
		private var pt : Point;

		public function XRayEffect() {
			pt = new Point();
			ct = new ColorTransform(-2, -2, -2, 1, 0xFF, 0xFF, 0xFF);
			
			var m : Array = [];
			m = m.concat([0.3, 0.59, 0.11, 0, 0]); 
			m = m.concat([0.3, 0.59, 0.11, 0, 50]); 
			m = m.concat([0.3, 0.59, 0.11, 0, 90]); 
			m = m.concat([0, 0, 0, 1, 0]); 
			
			colorMtx = new ColorMatrixFilter(m);
		}

		public function render(bmd : BitmapData) : void {
			bmd.colorTransform(bmd.rect, ct);
			bmd.applyFilter(bmd, bmd.rect, pt, colorMtx);
		}
	}
}
