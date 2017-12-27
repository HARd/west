package com.flashdynamix.motion.layers {
	import flash.display.*;
	import flash.events.*;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;	

	/**
	 * This Class is not ready for public use
	 */	public class BitmapFillLayer extends Shape {

		public var clearOnRender : Boolean = true;
		public var running : Boolean = false;
		public var items : Array = [];

		private var _width : int;
		private var _height : int;

		public function BitmapFillLayer(width : int = 500, height : int = 500) {
			_width = width;
			_height = height;
			
			start();
		}

		public function get length() : int {
			return items.length;
		}

		public function start() : void {
			if(running) return;
			
			running = true;
			addEvent(this, Event.ENTER_FRAME, render);
		}

		public function stop() : void {
			if(!running) return;
			
			running = false;
			removeEvent(this, Event.ENTER_FRAME, render);
		}

		public function add(bmd : BitmapData, rect : Rectangle, mtx : Matrix = null) : Object {
			var item : Object = {bmd:bmd, rect:rect, mtx:mtx};
			items.push(item);
			return item;
		}

		public function remove(item : Object) : Boolean {
			var idx : int = items.indexOf(item);
			if(idx == -1) return false;
			items.splice(idx, 1);
			
			return true;
		}

		public function item(idx : int) : Object {
			return items[idx];
		}

		private function render(e : Event) : void {
			if(clearOnRender) graphics.clear();
			
			var len : int = items.length;
			var obj : Object;
			var rect : Rectangle;
			var mtx : Matrix;
			var i : int;
			
			for(i = 0;i < len; i++) {
				obj = item(i);
				rect = obj["rect"];
				mtx = obj["mtx"];
				
				graphics.beginBitmapFill(obj["bmd"], obj["mtx"], false, false);
				graphics.drawRect(rect.x, rect.y, rect.width, rect.height);
			}
			
			graphics.endFill();
		}

		protected function addEvent(item : EventDispatcher, type : String, listener : Function, priority : int = 0, useWeakReference : Boolean = true) : void {
			item.addEventListener(type, listener, false, priority, useWeakReference);
		}

		protected function removeEvent(item : EventDispatcher, type : String, listener : Function) : void {
			item.removeEventListener(type, listener);
		}
	}
}
