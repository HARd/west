package com.flashdynamix.motion.layers {
	import flash.display.*;
	import flash.events.*;
	import flash.geom.Rectangle;

	import com.flashdynamix.motion.vectors.IVector;	

	/**
	 * The VectorLayer class draws the IVectors in its list to a single Graphics.<BR>
	 * Though using the VectorLayer can prove to be a very convient way to draw vectors
	 * it doesn't necessarily yield any amazing performance differences. This is until the 
	 * bitmapData property is used to get a bitmap render of the vector drawing allowing for
	 * further optimizations than the built-in cacheAsBitmap property can yield.
	 */
	public class VectorLayer extends Shape {

		
		/**
		 * The list of IVectors to be drawn on each render.
		 */
		public var list : Array = [];
		public var rect : Rectangle = new Rectangle(0, 0);

		private var running : Boolean = false;

		public function VectorLayer(width : int = 500, height : int = 500, bgColor : Object = null, cacheAsBitmap : Boolean = false) {
			rect.width = width;
			rect.height = height;
			
			this.cacheAsBitmap = cacheAsBitmap;
			this.opaqueBackground = bgColor;
			this.scrollRect = rect;
			
			startRender();
		}

		public function set layerWidth(pixels : int) : void {
			rect.width = pixels;
			
			render();
		}

		public function get layerWidth() : int {
			return rect.width;
		}

		public function set layerHeight(pixels : int) : void {
			rect.height = pixels;
			
			render();
		}

		public function get layerHeight() : int {
			return rect.height;
		}

		/**
		 * Returns a transparent BitmapData of the drawing.
		 * @return A transparent BitmapData of the drawing at the current width and height of the VectorLayer.<BR>
		 * If the width or height exceeds 2880 pixels this area will not be rendered.
		 */
		public function get bitmapData() : BitmapData {
			render();
			
			var bmpWidth : int = Math.min(2880, width);			var bmpHeight : int = Math.min(2880, height);
			
			var bmd : BitmapData = new BitmapData(bmpWidth, bmpHeight, true, 0x00FFFFFF);
			bmd.draw(this);
			
			return bmd;
		}

		/**
		 * Returns a transparent Bitmap of the drawing.
		 * @return A transparent Bitmap of the drawing at the current width and height of the VectorLayer.<BR>
		 * If the width or height exceeds 2880 pixels this area will not be rendered.
		 */
		public function get bitmap() : Bitmap {
			return new Bitmap(bitmapData, PixelSnapping.AUTO, false);
		}

		/**
		 * Adds an IVector into the list.
		 */
		public function add(vector : IVector) : IVector {
			list.push(vector);
			return vector;
		}

		/**
		 * Removes an IVector into the list.
		 */
		public function remove(vector : IVector) : Boolean {
			var idx : int = list.indexOf(vector);
			if(idx == -1) return false;
			list.splice(idx, 1);
			
			return true;
		}

		/**
		 * Removes all IVectors from the list.
		 */
		public function clear() : void {
			list.length = 0;
		}

		/**
		 * Starts rendering the VectorLayer on construction rendering automatically starts.
		 */
		public function startRender() : void {
			if(running) return;
			
			running = true;
			addEvent(this, Event.ENTER_FRAME, render);
		}

		/**
		 * Stops rendering the VectorLayer this can be resumed via the startRender method.
		 */
		public function stopRender() : void {
			if(!running) return;
			
			running = false;
			removeEvent(this, Event.ENTER_FRAME, render);
		}

		/*
		 * Renders all IVectors in the list. Triggering this method manually can be handy when 
		 * confronting a situation where the renders do not need to be done on a ENTER_FRAME basis 
		 * or the developer would like custom control over when the render cycles occur.
		 */
		public function render(e : Event = null) : void {
			graphics.clear();
			var len : int = list.length;
			var i : int;
			for(i = 0;i < len; i++) IVector(list[i]).draw(graphics, rect);
		}

		protected function addEvent(item : EventDispatcher, type : String, liststener : Function, priority : int = 0, useWeakReference : Boolean = true) : void {
			item.addEventListener(type, liststener, false, priority, useWeakReference);
		}

		protected function removeEvent(item : EventDispatcher, type : String, listener : Function) : void {
			item.removeEventListener(type, listener);
		}

		/**
		 * Disposes the VectorLayer ready for garbage collection.
		 */
		public function dispose() : void {
			stopRender();
			
			list = null;
		}

		override public function toString() : String {
			return "VectorLayer {length:" + length + "}";
		}
	}
}
