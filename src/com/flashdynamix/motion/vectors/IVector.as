package com.flashdynamix.motion.vectors {
	import flash.display.Graphics;
	import flash.geom.Rectangle;		

	public interface IVector {
		function draw(vector : Graphics, rect : Rectangle) : void;
	}
}
