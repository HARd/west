package ui 
{
	import com.greensock.easing.Linear;
	import com.greensock.TweenLite;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextField;
	import wins.Window;
	
	public class ProgressBar extends Sprite
	{
		private var background:Bitmap;
		private var slider:Bitmap;
		private var sliderMask:Shape;
		private var text:TextField;
		public var maxWidth:int;
		private var time:int;
		private var value:Number = 0;
		private var _label:TextField;
		
		public var params:Object = {
			background:		'progressBarAction',
			barLine:		'progressBarActionLine',
			auto:			true,
			textUpdate:		false,
			removeOnComplete:true,
			ease:			Linear.easeOut
		}
		
		public function ProgressBar(time:uint, maxWidth:int = 0, params:Object = null) 
		{	
			if (!params) params = { };
			for (var s:* in params)
				this.params[s] = params[s];
			
			this.maxWidth = maxWidth;
			this.time = time;
			
			draw();
			
			if (this.params.auto) {
				start();
			}
		}
		
		private function draw():void {
			
			background = new Bitmap();
			if (Window.textures[params.background]) background.bitmapData = Window.textures[params.background];
			else if (UserInterface.textures[params.background]) background.bitmapData = UserInterface.textures[params.background];
			addChild(background);
			
			slider = new Bitmap();
			if (Window.textures[params.barLine]) slider.bitmapData = Window.textures[params.barLine];
			else if (UserInterface.textures[params.barLine]) slider.bitmapData = UserInterface.textures[params.barLine];
			slider.x = background.x + (background.width - slider.width) / 2;
			slider.y = background.y + (background.height - slider.height) / 2;
			addChild(slider);
			
			sliderMask = new Shape();
			sliderMask.graphics.beginFill(0xffffff, 1);
			sliderMask.graphics.drawRect(slider.x,slider.y,slider.width,slider.height);
			sliderMask.graphics.endFill();
			sliderMask.scaleX = 0;
			addChild(sliderMask);
			
			slider.mask = sliderMask;
			
			text = Window.drawText("", {
				fontSize:	18,
				color:		0x583c10,
				border:		false,
				autoSize:	"left"
			});
			addChild(text);
		}
		
		public function set label(value:String):void {
			text.text = value;
			text.x = background.x + (background.width - text.width) / 2;
			text.y = background.y + (background.height - text.height) / 2 + 1;
		}
		
		public function get label():String {
			return text.text;
		}
		
		private var tween:TweenLite = null;
		public function start(currentProgress:Number = 0):void {
			
			if (tween) {
				tween.kill();
				tween = null;
			}
			var currTime:Number = time;
			if (currentProgress > 0 && currentProgress < 1) {
				sliderMask.scaleX = currentProgress;
				currTime = time * (1 - currentProgress);
			}
			
			tween = TweenLite.to(sliderMask, currTime, { scaleX:1, ease:params.ease, onUpdate:function():void {
				if (params.textUpdate)
					label = TimeConverter.timeToStr(int(time - sliderMask.scaleX * time));
			}, onComplete:function():void {
				if (params.removeOnComplete)
					dispose();
				
				dispatchEvent(new Event(Event.COMPLETE));
			}});
			
		}
		
		public function dispose():void {
			if (tween) tween.kill();
			if (parent) parent.removeChild(this);
		}
		
	}

}