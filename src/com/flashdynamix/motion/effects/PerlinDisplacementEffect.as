package com.flashdynamix.motion.effects {
	import flash.display.*;
	import flash.geom.*;
	
	import com.flashdynamix.motion.effects.core.DisplacementEffect;	

	/**
	 * Applies a DisplacementMapFilter using Perlin noise to a BitmapData
	 */
	dynamic public class PerlinDisplacementEffect extends DisplacementEffect implements IEffect {

		/**
		 * An option for the movement option on the displacement<BR>
		 * This will move the displacement in the x,y direction specified by the speedX and speedY.
		 */
		public static const DIRECTION : String = "direction";
		/**
		 * An option for the movement option on the displacement.<BR>
		 * This will move the displacement in an orbit path along the radiusX and radiusY.<BR> 
		 * Rotating in an x direction and y direction specified by the speedX and speedY.<BR>
		 */
		public static const ORBIT : String = "orbit";
		/**
		 *  Frequency to use in the x direction.<BR>
		 *  For example, to generate a noise that is sized for a 64 x 128 image, pass the pixel width of 64 for the baseX value.
		 */
		public var baseX : int = 30;
		/**
		 * Frequency to use in the y direction.<BR>
		 * For example, to generate a noise that is sized for a 64 x 128 image, pass the pixel height of 128 for the baseY value.
		 */
		public var baseY : int = 40;
		/**
		 * The x speed direction the displacement is offsetted by on each render.<BR>
		 * The direction depends on the movement type.<BR>
		 * When the movement type is ORBIT it effects the speed of rotation in the x direction.<BR>
		 * When the movement type is DIRECTION it effects the offset speed in the x direction.
		 */
		public var speedX : Number = 0.01;
		/**
		 * The y speed direction the displacement is offsetted by on each render.
		 * The direction depends on the movement type.<BR>
		 * When the movement type is ORBIT it effects the speed of rotation in the y direction.<BR>
		 * When the movement type is DIRECTION it effects the offset speed in the y direction.
		 */
		public var speedY : Number = 0.01;
		/**
		 * The radiusX in pixels to be applied on to the displacement when the movement type is ORBIT.
		 */
		public var radiusX : Number = 3;
		/**
		 * The radiusY in pixels to be applied on to the displacement when the movement type is ORBIT.
		 */
		public var radiusY : Number = 3;
		/**
		 * The random seed number to generate the perlin noise.
		 */
		public var seed : int = 1;
		/**
		 * If the value is true, the method generates fractal noise; otherwise, it generates turbulence. 
		 * An image with turbulence has visible discontinuities in the gradient that can make it better approximate sharper visual effects like flames and ocean waves.
		 */
		public var fractalNoise : Boolean = false;
		/**
		 * Sets the perlin noise to render in grayscale.
		 */
		public var grayScale : Boolean = false;
		/**
		 *  If the value is true, the method attempts to smooth the transition edges of the image to create seamless textures for tiling as a bitmap fill.
		 */
		public var stitch : Boolean = true;
		/**
		 * The Channels which are rendered with the perlin noise : 
		 * <ul>
		 * <li>BitmapDataChannel.ALPHA</li>
		 * <li>BitmapDataChannel.BLUE</li>
		 * <li>BitmapDataChannel.GREEN</li>
		 * <li>BitmapDataChannel.RED</li>
		 * </ul>
		 */
		public var channelOptions : uint = BitmapDataChannel.RED;

		private var offsets : Array;
		private var octives : int = 2;
		private var incX : Number = 0;
		private var incY : Number = 0;
		private var offset : Function = orbit; 

		
		/**
		 * @param width The width in pixels to render the perlin noise.
		 * @param height The height in pixels to render the perlin noise.
		 * @param scaleX The multiplier to use to scale the x displacement result from the map calculation.
		 * @param scaleY The multiplier to use to scale the y displacement result from the map calculation.
		 * @param octives Number of octaves or individual noise functions to combine to create this noise.
		 */
		public function PerlinDisplacementEffect(width : int = 500, height : int = 500, scaleX : Number = 3, scaleY : Number = 3, octives : int = 2) {
			super(new BitmapData(width, height, true, 0x00FFFFFF), scaleX, scaleY);
			
			this.octives = octives;
			
			offsets = [];
			for (var i : int = 0;i < octives; i++) offsets.push(new Point());
		}

		/**
		 * Sets the movement type which will be applied on the displacement<BR>
		 * These options include :
		 * <ul>
		 * <li>DIRECTION</li>
		 * <li>ORBIT</li>
		 * </ul>
		 */
		public function set movement(type : String) : void {
			switch(type) {
				case DIRECTION:
					offset = direction;
					break;
				case ORBIT:
					offset = orbit;
					break;
			}
		}

		private function orbit() : void {
			incX += speedX;
			incY += speedY;
			
			for (var i : int = 0;i < octives; i++) {
				var cPt : Point = offsets[i];
				cPt.y += Math.sin(incY) * radiusY;
				cPt.x += Math.cos(incX) * radiusX;
			}
		}

		private function direction() : void {
			for (var i : int = 0;i < octives; i++) {
				var cPt : Point = offsets[i];
				cPt.y += speedY;
				cPt.x += speedX;
			}
		}

		/**
		 * Renders the PerlinDisplacementEffect on to the specified BitmapData.
		 */
		override public function render(bmd : BitmapData) : void {
			offset();
			
			mapBmd.perlinNoise(baseX, baseY, octives, seed, stitch, fractalNoise, channelOptions, grayScale, offsets);
			
			super.render(bmd);
		}
	}
}
