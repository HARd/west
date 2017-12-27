package com.flashdynamix.motion.vectors {
	import flash.display.Graphics;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;	

	/**
	 * Defines a Gradient vector to be drawn by a VectorLayer.
	 */
	public class Gradient implements IVector {

		/**
		 * Defines the type of Gradient - this can be:
		 * <ul>
		 * <li>GradientType.LINEAR</li>
		 * <li>GradientType.RADIAL</li>
		 * </ul>
		 */
		public var type : String;
		/**
		 * An Array of RGB hexadecimal color values to be used in the gradient;
		 * for example, red is 0xFF0000, blue is 0x0000FF, and so on.<BR>
		 * You can specify up to 15 colors. For each color, be sure you specify a corresponding value in the alphas and ratios parameters.
		 */
		public var colors : Array;
		/**
		 * An Array of alpha values for the corresponding colors in the colors Array; valid values are 0 to 1.<BR> 
		 * If the value is less than 0, the default is 0. If the value is greater than 1, the default is 1. 
		 */
		public var alphas : Array;
		/**
		 * An Array of color distribution ratios; valid values are 0 to 255.<BR>
		 * This value defines the percentage of the width where the color is sampled at 100%.<BR>
		 * The value 0 represents the left-hand position in the gradient box, and 255 represents the right-hand position in the gradient box.
		 */
		public var ratios : Array;
		/**
		 * A value from the SpreadMethod class that specifies which spread method to use: 
		 * <ul>
		 * <li>SpreadMethod.PAD</li>
		 * <li>SpreadMethod.REFLECT</li>
		 * <li>SpreadMethod.REPLAY</li>
		 * </ul>
		 */
		public var spreadMethod : String;
		/**
		 * A value from the InterpolationMethod class that specifies which value to use:
		 * <ul>
		 * <li>InterpolationMethod.linearRGB</li>
		 * <li>InterpolationMethod.RGB</li>
		 * </ul>
		 */
		public var interpolationMethod : String;
		/**
		 * A number that controls the location of the focal point of the gradient.<BR> 
		 * 0 means that the focal point is in the center.<BR>
		 * 1 means that the focal point is at one border of the gradient circle.<BR>
		 * -1 means that the focal point is at the other border of the gradient circle.<BR>
		 * A value less than -1 or greater than 1 is rounded to -1 or 1.<BR>
		 */
		public var focalPointRatio : Number;

		private var matrix : Matrix;
		private var _rotation : Number;
		private var _x : Number;
		private var _y : Number;
		private var _width : Number;
		private var _height : Number;
		private var degreeRad : Number = Math.PI / 180;
		private var radDegree : Number = 180 / Math.PI;

		/**
		 * @param x The current x position in pixels for the Gradient.
		 * @param y The current y position in pixels for the Gradient.
		 * @param width The current width in pixels for the Gradient.
		 * @param height The current height in pixels for the Gradient.
		 * @param rotation The current rotation in degrees for the Gradient.
		 * @param colors An Array of RGB hexadecimal color values to be used in the gradient.
		 * @param alphas An Array of alpha values for the corresponding colors in the colors Array.
		 * @param ratios An Array of color distribution ratios; valid values are 0 to 255.
		 * @param type Defines the type of Gradient - this can be either GradientType.LINEAR or GradientType.RADIAL.
		 * @param spreadMethod A value from the SpreadMethod class that specifies which spread method to use this can be either SpreadMethod.PAD, SpreadMethod.REFLECT, or SpreadMethod.REPLAY.
		 * @param interpolationMethod A value from the InterpolationMethod class that specifies which value to use this can be either InterpolationMethod.linearRGB or InterpolationMethod.RGB.
		 * @param focalPointRatio A number that controls the location of the focal point of the Gradient.
		 */
		public function Gradient(x : Number, y : Number, width : Number, height : Number, rotation : Number, colors : Array, alphas : Array, ratios : Array, type : String = "linear", spreadMethod : String = "pad", interpolationMethod : String = "rgb", focalPointRatio : Number = 0) {
			_x = x;
			_y = y;
			_width = width;
			_height = height;
			_rotation = rotation * degreeRad;
			
			this.colors = colors;
			this.alphas = alphas;
			this.ratios = ratios;
			this.type = type;
			this.spreadMethod = spreadMethod;
			this.interpolationMethod = interpolationMethod;
			this.focalPointRatio = focalPointRatio;
			
			matrix = new Matrix();
			update();
		}

		/**
		 * Set the rotation of the Gradient in degrees.
		 */
		public function set rotation(degrees : Number) : void {
			_rotation = degrees * degreeRad;
			update();
		}

		/**
		 * @return The rotation of the Gradient in degrees.
		 */
		public function get rotation() : Number {
			return _rotation * radDegree;
		}

		/**
		 * Set the x position of the Gradient in pixels.
		 */
		public function set x(num : Number) : void {
			_x = num;
			update();
		}

		/**
		 * @return The x position of the Gradient in pixels.
		 */
		public function get x() : Number {
			return _x;
		}

		/**
		 * Set the y position of the Gradient in pixels.
		 */
		public function set y(num : Number) : void {
			_y = num;
			update();
		}

		/**
		 * @return The y position of the Gradient in pixels.
		 */
		public function get y() : Number {
			return _y;
		}

		/**
		 * Set the width of the Gradient in pixels.
		 */
		public function set width(num : Number) : void {
			_width = num;
			update();
		}

		/**
		 * @return Gets the width of the Gradient in pixels.
		 */
		public function get width() : Number {
			return _width;
		}

		/**
		 * Set the height of the Gradient in pixels.
		 */
		public function set height(num : Number) : void {
			_height = num;
			update();
		}

		/**
		 * @return Gets the height of the Gradient in pixels.
		 */
		public function get height() : Number {
			return _height;
		}

		/**
		 * Draws the Gradient into the Graphics instance provided.
		 */
		public function draw(vector : Graphics, rect : Rectangle) : void {
			vector.beginGradientFill(type, colors, alphas, ratios, matrix, spreadMethod, interpolationMethod, focalPointRatio);
			vector.drawRect(0, 0, rect.width, rect.height);
		}

		private function update() : void {
			matrix.createGradientBox(_width, _height, _rotation, _x, _y);
		}
	}
}
