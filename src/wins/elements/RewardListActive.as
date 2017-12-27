package wins.elements 
{
	import com.greensock.TweenLite;
	import core.Load;
	import flash.display.Bitmap;
	import flash.display.GradientType;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.text.TextField;
	import flash.utils.clearInterval;
	import flash.utils.clearTimeout;
	import flash.utils.setInterval;
	import flash.utils.setTimeout;
	import wins.Window;
	public class RewardListActive extends LayerX {
		
		public var backing:Bitmap;
		private var _mask:Sprite;
		private var move:Sprite;
		
		public var items:Vector.<Bitmap>;
		public var params:Object = {
				backing:	'windowBacking',
				backingVisible:false,
				random:		true,
				time:		5,
				padding:	26
			};
		public var rewards:Object = { };
		private var moving:Boolean = false;
		
		public function RewardListActive(width:Number = 80, height:Number = 80, rewards:Object = null, params:Object = null) {
			if (params) {
				for (var s:String in params) {
					this.params[s] = params[s];
				}
			}
			this.params['width'] = width;
			this.params['height'] = height;
			this.rewards = rewards;
			
			items = new Vector.<Bitmap>();
			
			draw();
			//start();
		}
		
		private function draw():void {
			backing = Window.backing(params.width, params.height, 10, params.backing);
			backing.visible = params.backingVisible;
			addChild(backing);
			
			move = new Sprite();
			addChild(move);
			
			_mask = new Sprite();
			_mask.graphics.lineStyle(0,0,0);
			var matrix:Matrix = new Matrix();
			matrix.createGradientBox(params.width, params.height);
			
			_mask.graphics.beginGradientFill(GradientType.LINEAR,[0xFFFFFF,0xFFFFFF,0xFFFFFF,0xFFFFFF],[0,1,1,0],[0,10,245,255],matrix);
			_mask.graphics.drawRect(0,0,params.width,params.height);
			_mask.graphics.endFill();
			addChild(_mask);
			move.mask = _mask;
			
			var count:int = 0;
			for (var s:String in rewards) {
				createItem(count, s, rewards[s]);
				count++;
			}
		}
		
		private function createItem(count:int, id:String, num:int):void {
			var item:Bitmap = new Bitmap();
			item.x = params.width * count;
			items.push(item);
			move.addChild(item);
			
			var preloader:Preloader = new Preloader();
			preloader.x = count * params.width + params.width / 2;
			preloader.y = params.height / 2;
			preloader.scaleX = preloader.scaleY = 0.6;
			move.addChild(preloader);
			
			var text:TextField = Window.drawText((num > 0) ? String(num) : '', {
				fontSize:		22,
				color:			0x604729,
				borderColor:	0xf6f0c1,
				borderSize:		4,
				width:			params.width - 20,
				autoSize:		'right'
			});
			text.x = params.width - 14 - text.width;
			text.y = params.height - text.height;
			move.addChild(text);
			
			if(App.data.storage.hasOwnProperty(id)) {
				Load.loading(Config.getIcon(App.data.storage[id].type, App.data.storage[id].preview), function(data:Bitmap):void {
					move.removeChild(preloader);
					
					item.bitmapData = data.bitmapData;
					item.smoothing = true;
					
					if (item.width > params.width - params.padding) {
						item.width = params.width - params.padding;
						item.scaleY = item.scaleX;
						if (item.height > params.height - params.padding) {
							item.height = params.height - params.padding;
							item.scaleX = item.scaleY;
						}
					}
					item.x = (params.width - item.width) / 2;
					item.y = (params.height - item.height) / 2;
				});
			}
		}
		
		private function letMove():void {
			var toX:int = 0;
			if (Math.abs(move.x) / params.width < items.length - 1) {
				toX = move.x - params.width;
			}
			moving = true;
			TweenLite.to(move, 0.25, { x:toX, onComplete:function():void {
				moving = false;
			}} );
		}
		
		private var timeout:int = 0;
		private var interval:int = 0;
		private function start():void {
			if (items.length > 1) {
				timeout = setTimeout(function():void {
					if (timeout) clearTimeout(timeout);
					interval = setInterval(letMove, params.time * 1000);
				}, Math.floor(params.time * 1000 * Math.random()));
			}
		}
		
		public function dispose():void {
			if (timeout) clearTimeout(timeout);
			if (interval) clearInterval(interval);
			if (moving) TweenLite.killTweensOf(move);
		}
	}

}