package com.flashdynamix.motion.effects {
	import flash.display.BitmapData;
	import flash.display.BitmapDataChannel;
	import flash.display.BlendMode;
	import flash.display.GradientType;
	import flash.display.Shape;
	import flash.filters.BlurFilter;
	import flash.filters.DisplacementMapFilter;
	import flash.filters.DisplacementMapFilterMode;
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	import com.flashdynamix.motion.effects.core.DisplacementEffect;	

	/**
	 * Applies a bulge effect of either a dent or indent to a BitmapData.
	 */
	public class BulgeEffect extends DisplacementEffect implements IEffect {

		/**
		 * The bulge's x position in pixels.
		 */
		public var x : Number = 0;
		/**
		 * The bulge's y position in pixels.
		 */
		public var y : Number = 0;
		/**
		 * How much blur is applied to the bulge effect.
		 */
		public var blur : Number = 40;
		/**
		 * The BitmapData to be applied a bulge effect.
		 */
		public var bmd : BitmapData;

		private var _dent : Boolean = false;

		/**
		 * @param bmd The BitmapData to which the bulge effect is applied.
		 * @param scaleX The amount of scaleX to be applied onto the bulge effect.
		 * @param scaleY The amount of scaleY to be applied onto the bulge effect.
		 */		public function BulgeEffect(bmd : BitmapData, dent : Boolean = true, scaleX : Number = 20, scaleY : Number = 20) {
			super(null, scaleX, scaleY, BitmapDataChannel.RED, BitmapDataChannel.GREEN, DisplacementMapFilterMode.CLAMP, mapPoint, 0, 0);
			this.bmd = bmd;
			this.dent = dent;
		}
		
		public function set dent(dent : Boolean) : void {
			_dent = dent;
			update();
		}

		/**
		 * Sets and returns whether the bulge effect is a dent or an indent.
		 */
		public function get dent() : Boolean {
			return _dent;
		}

		private function update() : void {
			
			var bmdWidth : int = bmd.width;			var bmdHeight : int = bmd.height;

			var mtx : Matrix = new Matrix();
			mtx.createGradientBox(bmdWidth, bmdHeight);
			var red : Shape = new Shape();
			var green : Shape = new Shape();
			
			var range : Array = [1, 1];
			var ratio : Array = [0x00, 0xFF];
			
			if(dent) {
				red.graphics.beginGradientFill(GradientType.LINEAR, [0x000000, 0xFF0000], range, ratio, mtx);
				red.graphics.drawRect(0, 0, bmdWidth, bmdHeight);
					
				mtx.rotate(Math.PI / 2);
				green.graphics.beginGradientFill(GradientType.LINEAR, [0x000000, 0x00FF00], range, ratio, mtx);
				green.graphics.drawRect(0, 0, bmdWidth, bmdHeight);
			} else {
				red.graphics.beginGradientFill(GradientType.LINEAR, [0xFF0000, 0x000000], range, ratio, mtx);
				red.graphics.drawRect(0, 0, bmdWidth, bmdHeight);
				
				mtx.rotate(Math.PI / 2);
				green.graphics.beginGradientFill(GradientType.LINEAR, [0x00FF00, 0x000000], range, ratio, mtx);
				green.graphics.drawRect(0, 0, bmdWidth, bmdHeight);
			}

			var pt : Point = new Point();
			mapBmd = new BitmapData(bmdWidth, bmdHeight, true, 0x00FFFFFF);
			
			var maskBmd : BitmapData = bmd.clone();
			maskBmd.applyFilter(maskBmd, maskBmd.rect, pt, new BlurFilter(blur, blur, 2));
			
			mapBmd.draw(green);
			mapBmd.draw(red, null, null, BlendMode.ADD);
			mapBmd.copyChannel(maskBmd, maskBmd.rect, pt, BitmapDataChannel.ALPHA, BitmapDataChannel.ALPHA);
			
			var finalBmd : BitmapData = new BitmapData(bmdWidth, bmdHeight, false, 0x00808080);
			finalBmd.draw(mapBmd);

			DisplacementMapFilter(filter).mapBitmap = finalBmd;
		}

		/**
		 * Renders the BulgeEffect to the specified BitmapData.
		 */
		override public function render(bmd : BitmapData) : void {
			mapPoint.x = x;
			mapPoint.y = y;
			super.render(bmd);
		}
	}
}
