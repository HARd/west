package com.flashdynamix.motion.extras {
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	
	import com.flashdynamix.motion.*;
	import com.flashdynamix.motion.guides.Direction2D;
	import com.flashdynamix.utils.MultiTypeObjectPool;
	
	import fl.motion.easing.*;	

	/**
	 * This is used as a particle emitter for Objects of a specified DisplayObject Class
	 */
	public class Emitter extends Sprite {

		/**
		 * The distance in pixels to start the particle Object at.
		 */
		public var startDistance : Number = 0;
		/**
		 * The angle in degrees to allow the particles to move to :<BR>
		 * <ul>
		 * <li>"0-360" allows for any random rotation.</li>
		 * <li>"-90-90" only allows for a random rotation between -90 and 90.</li>
		 * <li>90 only allows for particles to move at a rotation value of 90 degree.s</li>
		 * </ul>
		 */
		public var angle : *;
		/**
		 * The distance to allow particles to move to :<BR>
		 * <ul>
		 * <li>"10-100" allows for particles to move a distance between 10 and 100 pixels.</li> 
		 * <li>100 only allows for particles to move a distance of 100 pixels.</li>
		 * </ul>
		 */
		public var distance : *;
		/**
		 * The time in seconds it takes for a particle to get to its end position.
		 */
		public var speed : Number;
		/**
		 * How many particles are created on each ENTER_FRAME.
		 */
		public var frequency : int;
		/**
		 * How often particles are created on each ENTER_FRAME.<BR>
		 * If 0.5 particles will only be created half the time. By default this is set to 1.
		 */
		public var random : Number;
		/**
		 * Additional properties to tween during the particle's lifespan.<BR>
		 * i.e. {scaleX:2, scaleY:2} would scale the DisplayObject by a factor of 2 over its lifespan.
		 */
		public var target : Object;
		/**
		 * The ease equation used for the particle motion animations
		 */
		public var ease : Function = Linear.easeNone;
		/**
		 * The amount of delay in seconds before a particle begins to move to its target destination.
		 */
		public var delay : Number = 0;
		/**
		 * Allows for tweening the particles color over its lifespan.<BR>
		 * This value can be an Object defining the target redOffset, blueOffset, greenOffset etc.<BR>
		 * Or it can be a ColorTransform defining the end color.
		 */
		public var endColor : ColorTransform;
		/**
		 * Defines whether the Emitter is rendering.
		 */
		public var running : Boolean = false;
		/**
		 * The container Sprite for particles.
		 */
		public var holder : Sprite;

		private var tween : TweensyGroup;
		private var pool : MultiTypeObjectPool;
		private var Particle : Class;

		/**
		 * @param Particle The DisplayObject Class used to construct particles.
		 * @param target Additional properties to tween during the particle's lifespan.<BR>
		 * i.e. {scaleX:2, scaleY:2} would scale the DisplayObject by a factor of 2 over its lifespan.
		 * @param frequency How many particles are created on each ENTER_FRAME.
		 * @param random How often particles are created on each ENTER_FRAME.<BR>
		 * If 0.5 particles will only be created half the time. By default this is set to 1.
		 * @param angle The angle in degrees to allow the particles to move to:<BR>
		 * <ul>
		 * <li>"0-360" allows for any random rotation.</li>
		 * <li>"-90-90" only allows for a random rotation between -90 and 90.</li>
		 * <li>90 only allows for particles to move at a rotation value of 90 degrees.</li>
		 * </ul>
		 * @param distance The distance to allow particles to move to:<BR>
		 * <ul>
		 * <li>"10-100" allows for particles to move a distance between 10 and 100 pixels.</li> 
		 * <li>100 only allows for particles to move a distance of 100 pixels.</li>
		 * </ul>
		 * @param speed The time in seconds it takes for a particle to get to its end position.
		 * @param blendMode The BlendMode applied to the particle.
		 */
		public function Emitter(Particle : Class, target : Object = null, frequency : int = 5, random : Number = 1, angle : * = "0,360", distance : * = 20, speed : Number = 1, blendMode : String = "normal") {
			this.Particle = Particle;
			this.target = target;
			this.frequency = frequency;
			this.random = random;
			this.angle = angle;
			this.distance = distance;
			this.speed = speed;
			this.blendMode = blendMode;
			
			holder = new Sprite();
			tween = new TweensyGroup(false, true);
			pool = new MultiTypeObjectPool(TweensyTimeline, Particle);
			
			start();
		}

		/**
		 * Sets the scale of the Emitter this affects the transform of the Emitter which is then applied.
		 * to particles as they are created
		 */
		public function set scale(num : Number) : void {
			this.scaleY = this.scaleX = num;
		}

		/**
		 * Gets the scale of the Emmitter.
		 */
		public function get scale() : Number {
			return this.scaleY;
		}

		public function set secondsPerFrame(spf : Number) : void {
			tween.secondsPerFrame = spf;
		}

		public function get secondsPerFrame() : Number {
			return tween.secondsPerFrame;
		}

		public function set refreshType(type : String) : void {
			tween.refreshType = type;
		}

		/**
		 * The timing system currently in use.<BR>
		 * This can be either :
		 * <ul>
		 * <li>Tweensy.TIME</li>
		 * <li>Tweensy.FRAME</li>
		 * </ul>
		 * 
		 * @see com.flashdynamix.motion.Tweensy#FRAME
		 * @see com.flashdynamix.motion.Tweensy#TIME
		 * @see com.flashdynamix.motion.TweensyGroup#secondsPerFrame
		 */
		public function get refreshType() : String {
			return tween.refreshType;
		}

		/**
		 * Pauses all playing particle tweens.
		 */
		public function pause() : void {
			tween.pause();
		}

		/**
		 * Resumes all paused particle tweens.
		 */
		public function resume() : void {
			tween.resume();
		}

		/**
		 * Starts adding particle tweens on each ENTER_FRAME.
		 */
		public function start() : void {
			if(running) return;
			running = true;
			addEvent(this, Event.ENTER_FRAME, draw);
		}

		/**
		 * Stops adding particle tweens on each ENTER_FRAME. Though doesnt stop current particle tweens.
		 */
		public function stop() : void {
			if(!running) return;
			running = false;
			
			removeEvent(this, Event.ENTER_FRAME, draw);
		}

		/**
		 * Clones the Emmitter and returns a new instance.
		 */
		public function clone() : Emitter {
			return new Emitter(Particle, target, frequency, random, angle, distance, speed, blendMode);
		}

		private function draw(e : Event) : void {
			if(random < Math.random() || tween.paused) return;
			
			var timeline : TweensyTimeline = pool.checkOut(TweensyTimeline);
			timeline.duration = speed;
			timeline.ease = ease;
			timeline.delayStart = delay;
			var items : Array = [];
			var pos : Object = {position:1};
			var i : int;
			
			for(i = 0;i < frequency; i++) {
				var item : DisplayObject = pool.checkOut(Particle) as DisplayObject;
				
				item.blendMode = this.blendMode;
				item.transform = this.transform;

				if(target) timeline.to(item, target, null);
				timeline.to(new Direction2D(item, angle, distance, startDistance), pos);
				if(endColor) timeline.to(item.transform.colorTransform, endColor, item);
				
				items[i] = item;
				holder.addChild(item);
			}
			
			if(timeline.tweens > 0) {
				timeline.onComplete = _removeChildren;
				timeline.onCompleteParams = items;
				
				tween.add(timeline);
			}
		}

		private function _removeChildren(...items : Array) : void {
			var len : int = items.length;
			var item : DisplayObject;
			var i : int;
			
			for(i = 0;i < len; i++) {
				item = items[i];
				
				holder.removeChild(item);
				pool.checkIn(item);
			}
		}

		protected function addEvent(item : EventDispatcher, type : String, liststener : Function, priority : int = 0, useWeakReference : Boolean = true) : void {
			item.addEventListener(type, liststener, false, priority, useWeakReference);
		}

		protected function removeEvent(item : EventDispatcher, type : String, listener : Function) : void {
			item.removeEventListener(type, listener);
		}

		/**
		 * Disposes the Emitter Class ready for garbage collection
		 */
		public function dispose() : void {
			pool.dispose();
			tween.dispose();
			
			holder = null;
			pool = null;
			tween = null;
			endColor = null;
			target = null;
		}
	}
}