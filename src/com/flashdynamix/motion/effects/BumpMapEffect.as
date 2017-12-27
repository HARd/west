package com.flashdynamix.motion.effects {
	import flash.display.*;
	import flash.filters.ConvolutionFilter;
	import flash.filters.DisplacementMapFilter;
	import flash.filters.DisplacementMapFilterMode;
	import flash.geom.Point;
	
	import com.flashdynamix.motion.effects.IEffect;
	import com.flashdynamix.motion.effects.core.DisplacementEffect;	

	/**
	 * The BumpMap Effect applies a pseudo lighting effect to the BitmapData.<BR>
	 * This is done via providing 2 BitmapDatas: a BumpMap, and a LightMap.<BR>
	 * The BumpMap is used to apply texture onto to the lighting effect to simulate the effect of light on a textured surface.<BR>
	 * The LightMap is used for the lighting color. Best results for this are achieved by using a vignette.
	 */
	public class BumpMapEffect extends DisplacementEffect implements IEffect {

		private const MTX_X : Array = [0, 0, 0,
									   1, 0, -1,
									   0, 0, 0];

		private const MTX_Y : Array = [0, 1, 0,
									   0, 0, 0,
									   0, -1, 0];

		private var lightBmd : BitmapData;

		
		/**
		 * @param bumpMap Is used to apply texture onto to the lighting effect to simulate the effect of light on a textured surface.
		 * @param lightMap Is used for the lighting color. Best results for this is by using a vignette.
		 * @param mapPoint The position of the lightMap, this controls the lights position on the bumpMap.
		 */
		public function BumpMapEffect(bumpMap : BitmapData, lightMap : BitmapData, mapPoint : Point = null) {
			var cv : ConvolutionFilter = new ConvolutionFilter(3, 3, [], 1, 255 / 2, true, true, 0x00000000, 0);
			var outputBmd : BitmapData = new BitmapData(bumpMap.width, bumpMap.height, false, 0x00FFFFFF);
			
			super(outputBmd, 255, 255, BitmapDataChannel.RED, BitmapDataChannel.GREEN, DisplacementMapFilterMode.CLAMP, mapPoint);
			
			lightBmd = lightMap;
			var bumpBmd : BitmapData = bumpMap;
			
			var tempBmd : BitmapData = bumpBmd.clone();
			cv.matrix = MTX_X;
			tempBmd.applyFilter(tempBmd, tempBmd.rect, pt, cv);
			outputBmd.copyPixels(tempBmd, tempBmd.rect, pt);
			
			tempBmd = bumpBmd.clone();
			cv.matrix = MTX_Y;
			tempBmd.applyFilter(tempBmd, tempBmd.rect, pt, cv);
			outputBmd.copyChannel(tempBmd, tempBmd.rect, pt, BitmapDataChannel.RED, BitmapDataChannel.GREEN);
		}

		/**
		 * Renders the BumpMapEffect to the specified BitmapData.
		 */
		override public function render(bmd : BitmapData) : void {
			DisplacementMapFilter(filter).mapPoint = mapPoint;
			bmd.applyFilter(lightBmd, lightBmd.rect, pt, filter);
		}
	}
}
