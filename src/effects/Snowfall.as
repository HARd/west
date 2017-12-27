package effects 
{
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import com.greensock.TweenLite;
	import flash.utils.setInterval;
	
	public class Snowfall extends Sprite 
	{
		private const maxCount:int = 50;
		
		private var speed:Number = 2;
		private var count:int = 0;
		private var frame:int = 0;
		private var snowballs:Vector.<Snowball> = new Vector.<Snowball>;
		
		public function Snowfall() 
		{
			//setInterval(create, 100);
			
			App.self.setOnEnterFrame(updateSnowfall);
			this.addEventListener(Event.REMOVED_FROM_STAGE, onRemoveFromStage)
		}
		
		/*private function create():void {
			if (!visible) return;
			
			var snowball:Snowball = new Snowball();
			snowball.x = Math.random() * App.self.stage.stageWidth;
			snowball.y = 0;
			
			addChild(snowball);
			
			TweenLite.to(snowball, App.self.stage.stageHeight * 0.02, { y:App.self.stage.stageHeight, onCompleteParams:[snowball], onComplete:function(... args):void {
				snowball = args[0];
				
				if (snowball.parent) {
					snowball.parent.removeChild(snowball);
					snowball = null;
				}
			}} );
		}*/
		
		public function updateSnowfall(e:*):void {
			frame++;
			if (frame >= 1000) frame = 0;
			
			if (count < maxCount && frame % 10 == 0) {
				var snowball:Snowball = new Snowball();
				snowball.x = Math.random() * App.self.stage.stageWidth;
				snowball.y = 0;
				
				addChild(snowball);
				snowballs.push(snowball);
				count++;
			}
			
			for (var index:* in snowballs) {
				if (!snowballs[index]) continue;
				snowballs[index].y += speed * snowballs[index].scaleX;
				snowballs[index].x += snowballs[index].a * Math.sin(snowballs[index].t);
				
				if (snowballs[index].y >= App.self.stage.stageHeight) {
					var ball:Shape = snowballs[index]; 
					snowballs.splice(int(index), 1);
					if (ball.parent) {
						ball.parent.removeChild(ball);
						ball = null;
					}
					
					count--;
				}
			}
		}
		
		public function hide():void {
			this.visible = false;
		}
		
		public function show():void {
			this.visible = true;
		}
		
		private function onRemoveFromStage(e:Events):void {
			snowballs = null;
			App.self.setOffEnterFrame(updateSnowfall);
		}
		
	}

}

import flash.display.Shape;

internal class Snowball extends Shape {
	
	public var a:int;
	public var t:int;
	
	public function Snowball() {
		//bg = new Sprite();
		graphics.beginFill(0xcbd4cf);
		graphics.drawCircle(0, 0, Math.random() * 3);
		graphics.endFill();
		//scaleX = scaleY = 0.6 + Math.random() * 0.5;
		
		//addChild(bg);
		
		a = 1 + Math.random() * 1;
		t = Math.random() * 10;
	}

}
