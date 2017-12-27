package com.flashdynamix.motion.effects {
	import flash.display.BitmapData;
	import flash.geom.Matrix;

	import com.flashdynamix.motion.effects.IEffect;	

	/**
	 * Applies a pixelation effect on to a BitmapData
	 */
	public class PixelateEffect implements IEffect {

		/**
		 * The amount of pixelation scale to be applied on the result image.<BR>
		 * An amount of 1 will return a BitmapData at its native resolution.
		 */
		public var amount : Number = 50;
		
		public function PixelateEffect() {
		}

		/**
		 * Renders a pixelation effect on to the specified BitmapData.
		 */
		public function render(bmd : BitmapData) : void {
			var pixelBmd : BitmapData = new BitmapData( bmd.width / amount , bmd.height / amount , false , 0x00FFFFFF );
			
			var pxMtx : Matrix = new Matrix( );
			pxMtx.scale( 1 / amount , 1 / amount );
			
			pixelBmd.draw( bmd , pxMtx );
			
			var mtx : Matrix = new Matrix( );
			mtx.scale( bmd.width / pixelBmd.width , bmd.height / pixelBmd.height );
			
			bmd.fillRect( bmd.rect , 0x00FFFFFF );
			bmd.draw( pixelBmd , mtx );
		}
	}
}
