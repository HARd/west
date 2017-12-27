package com.flashdynamix.motion.effects.core {
	import flash.display.BitmapData;
	import flash.filters.BitmapFilter;
	import flash.geom.*;
	import flash.utils.*;
	
	import com.flashdynamix.motion.effects.IEffect;	

	/**
	 * Applies a BitmapFilter to a BitmapData
	 */
	public class FilterEffect extends Proxy implements IEffect {

		/**
		 * The BitmapFilter to apply onto the BitmapData.
		 */
		public var filter : BitmapFilter;
		/**
		 * The Point from which to apply the BitmapFilter
		 */
		public var pt : Point = new Point();

		/**
		 * @param filter The BitmapFilter to apply onto the BitmapData.
		 */
		public function FilterEffect(filter : BitmapFilter) {
			this.filter = filter;
		}

		override flash_proxy function setProperty(name : *, value : *) : void {
			filter[name] = value;
		}

		override flash_proxy function getProperty(name : *) : * {
			return filter[name];
		}

		/**
		 * Renders the FilterEffect on to the specified BitmapData.
		 */
		public function render(bmd : BitmapData) : void {
			bmd.applyFilter(bmd, bmd.rect, pt, filter);
		}
	}
}
