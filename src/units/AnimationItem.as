package units
{
	import core.Load;
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	
	/**
	 * ...
	 * @author 
	 */
	public class AnimationItem extends LayerX
	{
		public var textures:Object
		private var view:String
		private var onLoop:Function;
		private var settings:Object = {
			
		};
		private var framesType:String;
		private var direction:*;
		private var flip:Boolean = false;
		public var sid:int = 0;
		public var animated:Boolean = true;
		public var onClick:Function = null;
		
		public function AnimationItem(settings:Object = null) {
			
			view = settings.view;
			framesType = settings.framesType || view;
			touchable = settings.touchable || false;
			onClick = settings.onClick || null;
			
			if (settings.hasOwnProperty('onLoop'))
				onLoop = settings.onLoop;
				
			if (settings.hasOwnProperty('animated'))
				animated = settings.animated;
				
			if (settings.params) {
				if (settings.params.scale)
					this.scaleX = this.scaleY = settings.params.scale;
			}
			
			if (settings.type == 'Personage' || settings.type == 'Character' || settings.type == 'Clothes' || settings.type == 'Techno'){
				direction = settings.direction || 0;
				flip = settings.flip || false;
			}	
				
			Load.loading(Config.getSwf(settings.type, settings.view), onLoad);
			addEventListener(Event.REMOVED_FROM_STAGE, onRemoveFromStage);
			addEventListener(MouseEvent.CLICK, click);
			
			if (flip)	
				this.scaleX *= -1
		}
		
		public function get bmp():Bitmap {
			return bitmap;
		}
		
		public var touchable:Boolean = false;
		private var _touch:Boolean = false;
		public function set touch(touch:Boolean):void 
		{
			if (!touchable) return;
			
			_touch = touch;
			if (touch) {
				bitmap.filters = [new GlowFilter(0xFFFF00, 1, 6, 6, 7)]; 
			}else {
				bitmap.filters = null;
			}
		}
		
		public function click(e:MouseEvent):void {
			removeEventListener(MouseEvent.CLICK, click);
			if (_touch) {
				if (onClick != null)
					onClick();
			}
		}
		
		private function onLoad(data:*):void {
			textures = data;
			addAnimation();
			animate();
			if(animated)
				startAnimation();
				
			this.dispatchEvent(new Event(Event.COMPLETE));	
		}
		
		public function onRemoveFromStage(e:Event):void {
			stopAnimation();
			removeEventListener(Event.REMOVED_FROM_STAGE, onRemoveFromStage);
		}
		
		private var ax:int = 0;
		private var ay:int = 0;
		
		public var bitmap:Bitmap;
		public function addAnimation():void
		{
			bitmap = new Bitmap();
			addChild(bitmap);
			
			ax = textures.animation.ax;
			ay = textures.animation.ay;
		}
		
		public function startAnimation():void {
			App.self.setOnEnterFrame(animate);
		}
		public function stopAnimation():void {
			App.self.setOffEnterFrame(animate);
		}
		
		private var frame:int = 0;
		private function animate(e:Event = null):void
		{
			var cadr:uint 			= textures.animation.animations[framesType].chain[frame];
			//direction = 0;
			var frameObject:Object
				if(direction != null && direction != undefined)
					frameObject	= textures.animation.animations[framesType].frames[direction][cadr];
				else
					frameObject	= textures.animation.animations[framesType].frames[cadr];
					
				bitmap.bitmapData 	= frameObject.bmd;
				bitmap.smoothing 	= true;
				bitmap.x = frameObject.ox+ax;
				bitmap.y = frameObject.oy+ay;
				
			frame++;
			if (frame >= textures.animation.animations[framesType].chain.length)
			{
				frame = 0;
				if(onLoop != null) onLoop();
			}
		}
		
		public function dispose():void {
			stopAnimation();
			removeEventListener(MouseEvent.CLICK, click);
		}
		
		public static function getParams(type:String, view:String):Object {
			if (type == Building.BUILD) {
				switch(view) {
					case 'ether_mine':
							return { scale:0.6 }
						break;
					case 'storage1':
							return {scale:0.5}
						break;
				}
			}
			
			return { };
		}
	}
}