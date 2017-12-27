package com.flashdynamix.motion.layers {
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	
	import com.flashdynamix.motion.effects.IEffect;
	import com.flashdynamix.motion.effects.core.DrawEffect;	

	/**
	 * The BitmapLayer class draws the IEffects in its list into a single BitmapData.<BR>
	 * Drawing to a Bitmap can result in significant frame rate improvements when the number
	 * of DisplayObjects is high, the number of filters is high or the type of filters used are processor
	 * intensive. 
	 */
	public class BitmapLayer extends Bitmap {

		/**
		 * The list of IEffects to be drawn on each render.
		 */
		public var list : Array = [];
		/**
		 * If this is set to true then on each render the BitmapData will be filled with the 
		 * bgColor.
		 */
		public var clearOnRender : Boolean = false;
		/**
		 * The hexadecimal color defining the color for the BitmapData.
		 */
		public var bgColor : uint;
		/**
		 * Whether the BitmapData uses transparency.
		 */
		public var transparent : Boolean = false;
		
		private var running : Boolean = false;
		private var _scale : Number = 1;

		/**
		 * @param width The width in pixels to render the BitmapLayer.
		 * @param height The height in pixels to render the BitmapLayer.
		 * @param scale The scale to render the BitmapLayer.
		 * @param bgColor The hexadecimal bgColor to render the BitmapData background color.
		 * @param transparent Whether the BitmapData uses transparency. Not using transparency can reduce artifacts
		 * on the BitmapData when using BlendModes like BlendMode.ADD or BlendMode.OVERLAY
		 * @param smoothing Whether the BitmapData uses pixel smoothing. This is useful if the BitmapLayer is animated.
		 */
		public function BitmapLayer(width : Number = 500, height : Number = 500, scale : Number = 1, bgColor : uint = 0x00FFFFFF, transparent : Boolean = true, smoothing : Boolean = false) {
			super(new BitmapData(width / scale, height / scale, transparent, bgColor), PixelSnapping.AUTO, smoothing);
			
			this.bgColor = bgColor;
			this.transparent = transparent;
			_scale = scale;
			
			super.scaleY = super.scaleX = _scale;
			
			startRender();
		}

		override public function set smoothing(flag : Boolean) : void {
			super.smoothing = flag;
			
			updateEffects();
		}

		override public function get smoothing() : Boolean {
			return super.smoothing;
		}

		public function set scale(amount : Number) : void {
			var currentScale : Number = _scale / 1;
			
			super.scaleY = super.scaleX = amount;
			_scale = amount;
			
			bitmapData = new BitmapData(bitmapData.width * currentScale / _scale, bitmapData.height * currentScale / _scale, transparent, bgColor);
			updateEffects();
		}

		public function get scale() : Number {
			return _scale;
		}

		public function set layerWidth(pixels : int) : void {
			bitmapData = new BitmapData(pixels / _scale, bitmapData.height, transparent, bgColor);
			updateEffects();
		}

		public function get layerWidth() : int {
			return bitmapData.width;
		}

		public function set layerHeight(pixels : int) : void {
			bitmapData = new BitmapData(bitmapData.width, pixels / _scale, transparent, bgColor);
			updateEffects();
		}

		public function get layerHeight() : int {
			return bitmapData.height;
		}

		/**
		 * @return the number of render IEffects in the list.
		 */
		public function get length() : int {
			return list.length;
		}

		/**
		 * Adds an IEffect into the list.
		 */
		public function add(effect : IEffect) : IEffect {
			list.push(effect);
			return effect;
		}

		/**
		 * Removes an IEffect from the list.
		 */
		public function remove(effect : IEffect) : Boolean {
			var idx : int = list.indexOf(effect);
			if(idx == -1) return false;
			list.splice(idx, 1);
			
			return true;
		}

		/**
		 * Removes all IEffects from the list.
		 */
		public function clear() : void {
			list.length = 0;
		}

		/**
		 * Returns an IEffect from the list at the specified index.
		 */
		public function item(index : int) : IEffect {
			return list[index];
		}

		/**
		 * Adds a DrawEffect for the specified IBitmapDrawable to the render list.
		 * @param item The IBitmapDrawable instance which will be used in the DrawEffect.
		 * @param matrix The translation Matrix used with the DrawEffect.
		 * @param rectangle The clipping Rectangle used with the DrawEffect.
		 * @param colorTransform The ColorTransform used with the DrawEffect.
		 * @param blendMode The BlendMode used with the DrawEffect.
		 * @param smoothing Whether the DrawEffect will be using smoothing on render to the BitmapData.
		 */
		public function draw(instance : IBitmapDrawable, matrix : Matrix = null, rectangle : Rectangle = null, colorTransform : ColorTransform = null, blendMode : String = "normal") : DrawEffect {
			if(rectangle == null) {
				rectangle = this.bitmapData.rect;
			}
			
			if(matrix == null) {
				matrix = new Matrix();
				matrix.scale(1 / _scale, 1 / _scale);
			}
			
			var drawEffect : DrawEffect = new DrawEffect(instance, matrix, rectangle, colorTransform, blendMode, smoothing);
			add(drawEffect);
			
			return drawEffect;
		}

		/**
		 * Starts rendering the BitmapLayer on construction rendering automatically starts.
		 */
		public function startRender() : void {
			if(running) return;
			
			running = true;
			addEvent(this, Event.ENTER_FRAME, render);
		}

		/**
		 * Stops rendering the BitmapLayer this can be resumed via the startRender method.
		 */
		public function stopRender() : void {
			if(!running) return;
			
			running = false;
			removeEvent(this, Event.ENTER_FRAME, render);
		}

		/**
		 * Renders all IEffects in the list. Triggering this method manually can be handy when
		 * confronting a situation where the renders do not need to be done on a ENTER_FRAME basis 
		 * or the developer would like custom control over when the render cycles occur.
		 */
		public function render(e : Event = null) : void {
			bitmapData.lock();
			
			if(clearOnRender) bitmapData.fillRect(bitmapData.rect, bgColor);
			
			var len : int = list.length;
			var i : int;
			for(i = 0;i < len; i++) IEffect(list[i]).render(bitmapData);
			
			bitmapData.unlock();
		}

		protected function addEvent(item : EventDispatcher, type : String, listener : Function, priority : int = 0, useWeakReference : Boolean = true) : void {
			item.addEventListener(type, listener, false, priority, useWeakReference);
		}

		protected function removeEvent(item : EventDispatcher, type : String, listener : Function) : void {
			item.removeEventListener(type, listener);
		}

		protected function updateEffects() : void {
			var len : int = list.length;
			var i : int;
			var effect : DrawEffect;
			
			for(i = 0;i < len; i++) {
				effect = list[i] as DrawEffect;
				if(effect) {
					effect.rect = bitmapData.rect;					effect.matrix.d = effect.matrix.a = 1 / _scale;
					effect.smoothing = smoothing;
				}
			}
			
			render();
		}

		/**
		 * Disposes the BitmapLayer read for garbage collection
		 */
		public function dispose() : void {
			stopRender();
			
			list = null;
		}

		override public function toString() : String {
			return "BitmapLayer {length:" + length + "}";
		}
	}
}
