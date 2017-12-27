package wins.elements {

	import com.greensock.TweenMax;
	import core.Load;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.text.TextField;
	import wins.Window;
	
	public class GuestRewardItem extends Sprite {
		
		private var window:Window;
		public var id:int;
		public var count:int;
		public var sid:int;
		private var _height:Number;
		private var _width:Number;
		private var canGlowing:Boolean = true;
		private var current:Boolean = false;
		//private var background:Bitmap;
		private var background:Shape;
		private var bitmap:Bitmap = new Bitmap();
		public var reward:Object = { };
		
		public function GuestRewardItem(id:int, reward:Object, window:Window, current:Boolean = false, doGlow:Boolean = false, showInfo:Boolean = true) {
			this.window = window;
			this.current = current;
			this.showInfo = showInfo;
			update(id, reward, doGlow);
		}
		
		public function update(id:int, reward:Object, doGlow:Boolean = false):void {
			this.reward = reward;
			this.id = id;
			for (var sid:* in reward.outs) {
				this.sid = sid; 
				this.count = reward.outs[sid];
				break;
			}
			clearBody();
			drawRewardInfo();
			
			if (doGlow) glowing();
		}
		
		private function clearBody():void {
			if (background && background.parent)
				background.parent.removeChild(background);
			background = null;
			
			if (bitmap && bitmap.parent)
				bitmap.parent.removeChild(bitmap);
			bitmap = new Bitmap();
		}
		
		private var offset:int = 20;
		private var showInfo:Boolean;
		private function drawRewardInfo():void {
			background = new Shape();
			background.graphics.beginFill(0xb1c0b9, 1);
			background.graphics.drawCircle(56, 56, 56);
			background.graphics.endFill();
			addChild(background);
			
			Load.loading(Config.getIcon(App.data.storage[sid].type, App.data.storage[sid].preview), onLoadImage);
			addChild(bitmap);
			
			for each(var counts:* in reward.outs)
				break;
			
			var count:TextField = Window.drawText('x' + counts, {
				color:			0xffffff,
				borderColor:	0x754108,
				borderSize:		2,
				shadowColor:	0x754108,
				shadowSize:		2,
				fontSize:		26
			});
			count.width = count.textWidth + 10;
			count.x = background.x + (background.width - count.textWidth) + 5;
			count.y = (background.height - count.height) + 5;
			addChild(count);
		}
		
		private function onLoadImage(data:Object):void {
			bitmap.bitmapData = data.bitmapData;
			if (bitmap.width > background.width - offset) {
				bitmap.width = 	background.width - offset;
				bitmap.scaleY = bitmap.scaleX;
			}
			if (bitmap.height > background.height - offset) {
				bitmap.height = background.height - offset;
				bitmap.scaleX = bitmap.scaleY;
			}
			bitmap.x = background.x + (background.width - bitmap.width) / 2;
			bitmap.y = (background.height - bitmap.height) / 2;
			bitmap.smoothing = true;
		}
		
		public function glowing():void {
			customGlowing(this, glowing);	
		}
		
		private function customGlowing(target:*, callback:Function = null):void {
			TweenMax.to(target, 1, { glowFilter: { color:0xFFFF00, alpha:0.8, strength: 7, blurX:12, blurY:12 }, onComplete:function():void {
				TweenMax.to(target, 0.8, { glowFilter: { color:0xFFFF00, alpha:0.6, strength: 7, blurX:6, blurY:6 }, onComplete:function():void {
					if (callback != null && canGlowing) {
						callback();
					}else if(!canGlowing){
						TweenMax.to(target, 0.8, { glowFilter: { color:0xFFFF00, alpha:0, strength: 7, blurX:1, blurY:1 } });
					}
				}});	
			}});
		}
		
		private function stopGlowing():void {
			canGlowing = false;
			window.settings.find = 0;
		}
		
		public function dispose():void {
			clearBody();
			window = null;
		}
		
		public override function get height():Number {
			return background.height;
		}
		
		public override function  get width():Number {
			return background.width;
		}
	}
}