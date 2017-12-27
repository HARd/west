package effects 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filters.BlurFilter;
	
	public class ParticleEffect extends Sprite
	{
		public static const UP_DOWN:String = 'up_down';
		
		private var bmd:BitmapData;
		private var cont:Sprite;
		
		private var list:Array;
		
		private var _width:Number = 60;
		private var _height:Number = 60;
		private var workWidth:Number = 300;
		private var workIndent:Number = 0.1;
		private var side:String = "";
		private var color:uint = 0x000000;
		
		private var maxParticleLength:int = 150;
		
		public function ParticleEffect(info:Object) 
		{
			//_width = info.width;
			//_height = info.height;
			side = UP_DOWN;//info.side;
			color = info.color;
			
			workWidth = (_width * (1 - workIndent * 2))
			
			/*var s:Shape = drawStar(5);*/
			var s:Shape = new Shape();
			s.graphics.beginFill(color, 0.8);
			s.graphics.drawCircle(2, 2, 2);
			s.graphics.endFill();
			s.filters = [new BlurFilter(3, 3, 1)];
			
			bmd = new BitmapData(s.width+4, s.height+4, true, 0);
			bmd.draw(s);
			
			init();
		}
		private function drawStar(radius:Number, color:uint = 0xFFFFFF, amount:Number = 0.5, rays:int = 5):Shape {
			var shape:Shape = new Shape();
			shape.graphics.beginFill(color, 1);
			shape.graphics.lineTo(0, radius);
			
			for (var j:int = 0; j < 360; j += 10) {
				trace(Math.sin(1.57 * j / 180));
			}
			
			for (var i:int = 0; i < rays; i++) {
				shape.graphics.moveTo(amount * radius * Math.sin(360 * ((i + 0.5) / rays) * Math.PI / 180), amount * radius * Math.cos(360 * ((i + 0.5) / rays) * Math.PI / 180));
				shape.graphics.moveTo(radius * Math.sin(360 * ((i + 1) / rays) * Math.PI / 180), radius * Math.cos(360 * ((i + 1) / rays) * Math.PI / 180));
			}
			
			shape.graphics.endFill();
			
			return shape;
		}
		
		public function init():void {
			cont = new Sprite();
			list = new Array();
			addChild(cont);
			addEventListener(Event.ENTER_FRAME, particleProgress);
		}
		
		public function dispose():void {
			if (hasEventListener(Event.ENTER_FRAME)) removeEventListener(Event.ENTER_FRAME, particleProgress);
			clearParticles();
			removeChild(cont);
		}
		
		private function particleProgress(e:Event):void {
			if (list.length < maxParticleLength && probability(6)) {
				createParticle();
			}
			
			for (var i:int = 0; i < list.length; i++) {
				if (side == UP_DOWN) {
					list[i].particle.y -= list[i].speed;
				}else{
					list[i].particle.y += list[i].speed;
				}
				
				if (list[i].state == 'inner') {
					list[i].particle.alpha += 0.1;
					if (list[i].particle.alpha >= 1) {
						list[i].state = 'live';
						list[i]['life'] = 5 + int(Math.random() * 5);
					}
				}else if (list[i].state == 'live') {
					list[i].life --;
					if (list[i].life <= 0 || list[i].particle.y + list[i].speed * 5 < 0) list[i].state = 'die';
				}else{
					list[i].particle.alpha -= 0.1;
					if (list[i].particle.alpha <= 0) {
						cont.removeChild(list[i].particle);
						list.splice(i, 1);
						i--;
					}
				}
			}
		}
		private function createParticle():void {
			var bitmap:Bitmap = new Bitmap();
			var speed:Number = Math.random() + 1;
			bitmap.bitmapData = bmd;
			//bitmap.alpha = 0;
			bitmap.x = Math.random() * workWidth + workIndent;
			bitmap.y = (side == UP_DOWN) ? (_width - Math.random() * 40 - workIndent) : (Math.random() * 20 + workIndent);
			list.push( { particle:bitmap, x:bitmap.x, y:0, alpha:1, state:'inner', speed: speed } );
			
			cont.addChild(bitmap);
		}
		public function clearParticles():void {
			while (list.length > 0) {
				cont.removeChild(list[0].particle);
				list.splice(0, 1);
			}
		}
		private function probability(value:int):Boolean {
			if (int(Math.random() * value) == 0) return true;
			return false;
		}
	}

}