package effects 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.display.Sprite;
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.events.Event;
    import flash.filters.GlowFilter;
    import flash.filters.BlurFilter;
    import flash.display.BlendMode;
    import flash.geom.ColorTransform;
	import flash.utils.setInterval;
	import flash.utils.setTimeout;
	
	
	public class FlashLight extends Sprite 
	{
		private var interval:int;
		private var frames:int;
		private var line:Number;
		private var fromX:int;
		private var fromY:int;
		private var toX:int;
		private var toY:int;
		private var step:int;
		private var offset:int;
		private var blur:int;
		private var flashLightColor:uint;
		private var glow:int;
		private var glowStrength:int;
		private var glowColor:uint;
		private var curve:int;
		private var frameEvery:int = 2;
		
		private var path:int;
		
		public var layer:Array = new Array();
		public function FlashLight(info:Object):void 
		{
			interval = 1000 * (info.interval || 1);
			frames = info.frames || 10;
			line = info.line || 1.5;
			fromX = info.fromX || 0;
			fromY = info.fromY || 0;
			toX = info.toX || 100;
			toY = info.toY || 0;
			step = info.step || 30;
			offset = info.offset || 30;
			blur = info.blur || 0;
			flashLightColor = info.color || 0xFFFFFF;
			glow = info.glow || 30;
			glowStrength = info.glowStrength || 20;
			glowColor = info.glowColor || 0x4411FF;
			curve = info.curve || 0;
			
			path = toX - fromX;
			
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			layer[0] = new Bitmap(new BitmapData(path, 200, true, 0));
            layer[0].filters = [new BlurFilter(blur,blur,1)]
            layer[1] = new Sprite();
            layer[1].filters = [new BlurFilter(blur,blur,1), new GlowFilter(glowColor, 1, glow, glow, glowStrength, 3)]
            addChild(layer[0]);
            addChild(layer[1]);
			
			//setInterval(loop, 100);
            startShock();
		}
		
		private var counter:int = 0;
		private function startShock():void {
			counter = 0;
			addEventListener(Event.ENTER_FRAME, loop);
		}
		
		private function stopShock():void {
			layer[1].graphics.clear();
			removeEventListener(Event.ENTER_FRAME, loop);
			
			setTimeout(startShock, interval);
		}
		
		private var pause:int = 0;
		public function loop(e:* = null):void {
			if (pause == 0) lightning(layer[1]);
			pause++;
			if (pause >= frameEvery) pause = 0;
			counter++;
			
			if (counter > frames)
				stopShock();
			//var cash:BitmapData = new BitmapData(400, 200, true, 0x00000000);
			//cash.draw(this, null, new ColorTransform(1,1,1,0.9), BlendMode.ADD);
			//layer[0].bitmapData = cash;
        }
		
		 public function lightning(tg:Sprite):void{
			var xx:Number = fromX;
			var yy:Number = fromY;
			var way:Number = 0;
			tg.graphics.clear();
			tg.graphics.moveTo(xx, yy);
			while (xx < toX) {
				way = (fromX - xx) / (fromX - toX);
				xx += random(step) + step * 0.2 + 1;
				yy = fromY - (offset / 2) + random(offset) + (toY - fromY) * way - curve * Math.sin(way * 3.14);
				if (xx < toX) {
					tg.graphics.lineStyle(line,flashLightColor,1);
					tg.graphics.lineTo(xx, yy);
				}
			}
			
			tg.graphics.lineStyle(line, flashLightColor, 1);
			tg.graphics.lineTo(toX, toY);
        }
		
        public function random(n:Number):Number{
            return int(Math.random() * n);
        }
	}

}