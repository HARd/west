package effects{
	import flash.display.*;
	import flash.events.*;
	import flash.filters.BlurFilter;
	import flash.geom.ColorTransform;
	import flash.utils.getDefinitionByName;
	
	import com.flashdynamix.motion.*;
	import com.flashdynamix.motion.effects.core.*;
	import com.flashdynamix.motion.extras.Emitter;
	import com.flashdynamix.motion.guides.Orbit2D;
	import com.flashdynamix.motion.layers.BitmapLayer;
	import com.flashdynamix.utils.SWFProfiler;
	
	import fl.motion.easing.Linear;	

	/**
	 * @author shanem
	 */
	public class OrbitingMagicFX extends Sprite {

		private var tween : TweensyGroup;
		private var emittor : Emitter;
		private var layer : BitmapLayer;
		private var ct : ColorTransform;
		private var bf : BlurFilter;

		public function OrbitingMagicFX() {
			//SWFProfiler.init(this);
			
			tween = new TweensyGroup(false, true);
			bf = new BlurFilter(20, 20, 1);
			ct = new ColorTransform(0.15, 1, 1, 1, 13, -115, -255, 0);
			
			layer = new BitmapLayer(200, 200);
			layer.add(new ColorEffect(new ColorTransform(1, 1, 1, 0.9)));
			layer.add(new FilterEffect(bf));
			
			//stage.quality = StageQuality.LOW;
			
			//var Box : Class = getDefinitionByName("Box") as Class;
			
			emittor = new Emitter(Box as Class, {scaleX:0.1, scaleY:0.1}, 1, 1, 270, "30, 90", 0.7, BlendMode.ADD);
			emittor.delay = .2;
			emittor.transform.colorTransform = ct;
			emittor.endColor = new ColorTransform(1, 1, -0.375, 1, 255, -198, -255, -50);
			
			var orb : Orbit2D = new Orbit2D(emittor, 50, 50, 275, 200);
			tween.to(orb, {degree:360}, 1, Linear.easeNone, 0, null, onComplete).repeatType = TweensyTimeline.NONE;
			tween.to(orb, {radiusX:'50'}, 2, Linear.easeNone).repeatType = TweensyTimeline.YOYO;
			tween.to(orb, { radiusY:'50' }, 4, Linear.easeNone).repeatType = TweensyTimeline.YOYO;
			
						
			layer.draw(emittor.holder);
				
			addChildAt(layer, 0);
		}
		
		private function onComplete():void
		{
			
		}

		protected function addEvent(item : EventDispatcher, type : String, liststener : Function, priority : int = 0, useWeakReference : Boolean = true) : void {
			item.addEventListener(type, liststener, false, priority, useWeakReference);
		}

		protected function removeEvent(item : EventDispatcher, type : String, listener : Function) : void {
			item.removeEventListener(type, listener);
		}
	}
}
