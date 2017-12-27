package com.flashdynamix.motion.effects.core {
	import flash.display.*;
	import flash.filters.*;
	import flash.geom.*;
	
	import com.flashdynamix.motion.effects.IEffect;	

	/**
	 * Applies a DisplacementMapFilter to a BitmapData
	 */
	public class DisplacementEffect extends FilterEffect implements IEffect {

		/**
		 * The displacement BitmapData to be used.
		 */
		public var mapBmd : BitmapData;
		/**
		 * The position of the displacement mapBmd.
		 */
		public var mapPoint : Point;

		/**
		 * @param mapBmd The displacement BitmapData to be used.
		 * 
		 * @param scaleX The multiplier to use to scale the x displacement result from the map calculation.
		 * 
		 * @param scaleY The multiplier to use to scale the y displacement result from the map calculation.
		 * 
		 * @param componentX Describes which color channel to use in the map image to displace the x result.<BR>
		 * Possible values are BitmapDataChannel constants:
		 * <ul>
		 * <li>BitmapDataChannel.ALPHA</li>
		 * <li>BitmapDataChannel.BLUE</li>
		 * <li>BitmapDataChannel.GREEN</li>
		 * <li>BitmapDataChannel.RED</li>
		 * </ul>
		 * 
		 * @param componentY Describes which color channel to use in the map image to displace the y result.<BR>
		 * Possible values are BitmapDataChannel constants:
		 * <ul>
		 * <li>BitmapDataChannel.ALPHA</li>
		 * <li>BitmapDataChannel.BLUE</li>
		 * <li>BitmapDataChannel.GREEN</li>
		 * <li>BitmapDataChannel.RED</li>
		 * </ul>
		 * 
		 * @param mode The mode for the filter.<BR>
		 * Possible values are DisplacementMapFilterMode constants:
		 * <ul>
		 * <li>DisplacementMapFilterMode.WRAP — Wraps the displacement value to the other side of the source image.</li>
		 * <li>DisplacementMapFilterMode.CLAMP — Clamps the displacement value to the edge of the source image.</li>
		 * <li>DisplacementMapFilterMode.IGNORE — If the displacement value is out of range, ignores the displacement and uses the source pixel.</li>
		 * <li>DisplacementMapFilterMode.COLOR — If the displacement value is outside the image, substitutes the values in the color and alpha properties.</li>
		 * </ul>
		 * 
		 * @param mapPoint A value that contains the offset of the upper-left corner of the target display object from the upper-left corner of the map image.
		 * 
		 * @param color Specifies what color to use for out-of-bounds displacements.<BR>
		 * Values are in hexadecimal format. The default value for color is 0.<BR>
		 * Use this property if the mode property is set to DisplacementMapFilterMode.COLOR.
		 * 
		 * @param alpha Specifies the alpha transparency value to use for out-of-bounds displacements.<BR>
		 * It is specified as a normalized value from 0.0 to 1.0. For example, .25 sets a transparency value of 25%.<BR>
		 * The default value is 0. Use this property if the mode property is set to DisplacementMapFilterMode.COLOR.
		 */
		function DisplacementEffect(mapBmd : BitmapData, scaleX : Number = 3, scaleY : Number = 3, componentX : uint = 1, componentY : uint = 1, mode : String = "clamp", mapPoint : Point = null, color : uint = 0, alpha : uint = 0) {
			this.mapBmd = mapBmd;
			this.mapPoint = (mapPoint == null) ? new Point() : mapPoint;
			
			super(new DisplacementMapFilter(mapBmd, mapPoint, componentX, componentY, scaleX, scaleY, mode, color, alpha));
		}

		/**
		 * Renders the DisplacementEffect on to the specified BitmapData
		 */
		override public function render(bmd : BitmapData) : void {
			DisplacementMapFilter(filter).mapPoint = mapPoint;
			
			super.render(bmd);
		}
	}
}
