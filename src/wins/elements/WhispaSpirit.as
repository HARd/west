package wins.elements
{
	import adobe.utils.CustomActions;
	import com.greensock.TweenLite;
	import core.Load;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	
	/**
	 * ...
	 * @author 
	 */
	public class WhispaSpirit extends Sprite
	{
		
		public function WhispaSpirit() 
		{
			Load.loading(Config.getSwf('Tools', 'energy'), onLoad);
		}
		
		private var degree:Number = 0;
		private var radian:Number = 0;
		
		public var animationFuncitons:Array = [
			function(radian:Number):Number { return -Math.sin(radian) * Math.cos(radian); },
			function(radian:Number):Number { return Math.sin(radian) * Math.cos(radian); },
			function(radian:Number):Number { return Math.cos(radian) * Math.cos(radian); },
			function(radian:Number):Number { return -Math.cos(radian) * Math.cos(radian); },
			function(radian:Number):Number { return Math.cos(radian); },
			function(radian:Number):Number { return -Math.cos(radian); },
			function(radian:Number):Number { return Math.sin(radian); },
			function(radian:Number):Number { return -Math.sin(radian); }
		];
		
		public var spirit:Spirit;
		private function onLoad(data:*):void 
		{
			spirit = new Spirit(data)
			addChild(spirit);
			spirit.scaleX = spirit.scaleY = 1.5;
			App.self.setOnEnterFrame(move);
		}
		
		private var speed:Number = 2;
		private var radius:Number = 100;
		private function move(e:* = null):void 
		{
			degree += speed;
			
			if (degree > 360) {
				degree = 0;
			}
				
			radian = (degree / 180) * Math.PI;
				
			var funcX:Function = animationFuncitons[1];//animationFuncitons[int(Math.random() * animationFuncitons.length)];
			var funcY:Function = animationFuncitons[2];//animationFuncitons[int(Math.random() * animationFuncitons.length)];;
				
			spirit.x = (funcX(radian) * radius)// - radius/2;
			spirit.y = (funcY(radian) * radius) - radius/2;
		}
		
		public function dispose():void {
			App.self.setOffEnterFrame(move);
			spirit.dispose();
			removeChild(spirit);
			spirit = null;
		}
		
		import com.greensock.easing.*
		public function flyTo(icon:*):void {
			TweenLite.to(this, 2,{ x:icon.x, y:icon.y, ease:Strong.easeOut } );
		}
	}
}

import flash.display.Bitmap;
import flash.display.Sprite;
import flash.events.Event;

internal class Spirit extends Sprite 
{
	private var textures:Object;
	public function Spirit(data:Object) {
		textures = data
		addAnimation();
		startAnimation();
	}
	private var frameLength:int;
	private var bitmap:Bitmap;
	public function addAnimation():void
	{
		bitmap = new Bitmap();
		addChild(bitmap);
	}
	
	private var framesType:String = 'energy';
	public function startAnimation():void 
	{
		frameLength = textures.animation.animations[framesType].chain.length;
		frame = int(Math.random() * frameLength);
		App.self.setOnEnterFrame(animate);
		animated = true;
	}
	
	private var frame:int = 0;
	public function animate(e:Event = null):void
	{
		var cadr:uint = textures.animation.animations[framesType].chain[frame];
		var frameObject:Object 	= textures.animation.animations[framesType].frames[cadr];
				
		bitmap.bitmapData = frameObject.bmd;
		bitmap.x = frameObject.ox; 
		bitmap.y = frameObject.oy;
				
		bitmap.smoothing = true;
		frame ++ ;
		if (frame >= frameLength)
			frame = 0;
	}
	
	public var animated:Boolean = false;
	public function stopAnimation():void
	{
		animated = false;
		App.self.setOffEnterFrame(animate);
	}
	
	public function dispose():void {
		App.self.setOffEnterFrame(animate);
	}
}