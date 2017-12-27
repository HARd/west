package effects 
{
	import com.greensock.easing.Bounce;
	import com.greensock.easing.Cubic;
	import com.greensock.TweenMax;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	import wins.Window;
	
	public class BoostEffect extends Sprite 
	{
		
		public var lights:Bitmap;
		public var text:TextField;
		
		public function BoostEffect(x:int = 0, y:int = 0) {
			
			super();
			
			this.x = x;
			this.y = y;
			
			var scale:Number = 0.75;
			
			var sprite:Sprite = new Sprite();
			var bitmap2:Bitmap = new Bitmap(Window.textures.itemBacking, 'auto', true);
			//bitmap2.bitmapData.fillRect(new Rectangle(0, 0, bitmap2.width, bitmap2.height), 0xffff0000);
			bitmap2.scaleX = bitmap2.scaleY = 0.25;
			bitmap2.alpha = 0.7;
			bitmap2.y = 5;
			sprite.addChild(bitmap2);
			var bmd:BitmapData = new BitmapData(sprite.width, sprite.height, true, 0);
			bmd.draw(sprite);
			
			lights = new Bitmap(bmd, 'auto', true);
			lights.x = (50 - lights.width) / 2;
			lights.y = -int(lights.height / 2);
			
			text = Window.drawText('', {
				fontSize:	16,
				color:		0xffea71,
				borderColor:0x720413,
				autoSize:	'none',
				textAlign:	'center',
				width:		50
			});
			
			addChild(lights);
			addChild(text);
			
			alpha = 0;
			visible = false;
		}
		
		public var interval:uint = 0;
		private const showAlpha:Number = 1;
		private const hideAlpha:Number = 0.2;
		public function start():void {
			if (interval) clearTimeout(interval);
			TweenMax.killTweensOf(lights);
			if (!visible) visible = true;
			var target:* = (alpha == 0) ? this : lights;
			textJump();
			TweenMax.to(target, showAlpha - target.alpha, { alpha:showAlpha, onComplete:function():void {
				TweenMax.to(lights, lights.alpha - hideAlpha, { alpha:hideAlpha, onComplete:function():void {
					interval = setTimeout(function():void {
						clearTimeout(interval);
						start();
					}, 250);
				}})	
			}});
		}
		public function stop():void {
			if (interval) clearTimeout(interval);
			TweenMax.killTweensOf(this);
			TweenMax.killTweensOf(lights);
			if (lights.alpha == 0) return;
			TweenMax.to(this, this.alpha, { alpha:0, onComplete:function():void {
				lights.alpha = 1;
				alpha = 0;
				visible = false;
			}});
		}
		
		public var noJump:int = 0;
		public function textJump():void {
			if (noJump > 0) {
				noJump--;
				return;
			}
			noJump = 3;
			
			TweenMax.to(text, 0.4, { y:12, ease:Cubic.easeOut, onComplete:function():void {
				TweenMax.to(text, 0.75, { y:18, ease:Bounce.easeOut } );
			}});
		}
		
		public function formatText(value:String):String {
			if (int(value) > 100) return 'x' + String(Math.floor((100 + int(value))/100));
			return '+' + value + '%';
		}
		
		public function show(text:*, format:Boolean = true):void {
			if (format)
				this.text.text = formatText(String(text));
			else 
				this.text.text = String(text);
			if(!visible) start();
		}
		public function hide():void {
			if(visible) stop();
		}
	}

}