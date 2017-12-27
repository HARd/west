package units 
{
	import com.greensock.TweenLite;
	import core.IsoConvert;
	import core.Load;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	import ui.SystemPanel;
	public class Whispa extends Sprite
	{
	
		public static var textures:Object;
		public var framesType:String = "energy";
		
		public var framesTypes:Array = [];
		public var multipleAnime:Object = {};
		
		protected var frame:uint = 0;
		protected var frameLength:uint = 0;
		
		private var chain:Object;
		
		public var ax:int = 0;
		public var ay:int = 0;
		
		public var cells:int;
		public var rows:int;
		
		public var animated:Boolean = false;
		
		
		public var animationLayer:Sprite = new Sprite();
		public var animationPoints:Object = { };
		
		public var animationFuncitons:Array = [
			function(radian:Number):Number { return -Math.sin(radian) * Math.cos(radian); },
			function(radian:Number):Number { return Math.sin(radian) * Math.cos(radian); },
			function(radian:Number):Number { return Math.cos(radian) * Math.cos(radian); },
			function(radian:Number):Number { return -Math.cos(radian) * Math.cos(radian); },
			function(radian:Number):Number { return Math.cos(radian); },
			function(radian:Number):Number { return -Math.cos(radian); },
			function(radian:Number):Number { return Math.sin(radian); },
			function(radian:Number):Number { return -Math.sin(radian); }
		]
		
		public function Whispa(object:Object) 
		{
			cells = object.cells;			
			rows = object.rows;			
			Load.loading(Config.getSwf('Tools', 'energy'), onLoad);
		}
		
		private function onLoad(data:*):void {
			textures = data;
			addAnimation();
			startAnimation();
			
			Nature.change(this);
		}
		
		private var degree:Number = 0;
		private var radian:Number = 0;
		
		public function addAnimation():void
		{
			frameLength = textures.animation.animations[framesType].chain.length;
			var bitmap:Bitmap;
			addChild(animationLayer);
			var point:Object;
			for (var i:int = 0; i < cells; i++ ) {
				for (var j:int = 0; j < rows; j++ ) {
					if (j % 2 == 0) continue;
					point = IsoConvert.isoToScreen(i, j, true, true);
					bitmap = new Bitmap();
					bitmap.x = textures.animation.ax + point.x;
					bitmap.y = textures.animation.ay + point.y;
					
					animationPoints[animationLayer.numChildren] = {
						radius:30,// + Math.random() * 20,
						speed:1.25,
						funcX:animationFuncitons[int(Math.random() * animationFuncitons.length)],
						funcY:animationFuncitons[int(Math.random() * animationFuncitons.length)],
						x:textures.animation.ax+point.x, 
						y:textures.animation.ay+point.y,
						frame:int(Math.random() * frameLength),
						prev: -1,
						degree:0
					};
					animationLayer.addChild(bitmap);
				}
			}		
		}
		
		public function startAnimation(random:Boolean = false):void
		{
			frameLength = textures.animation.animations[framesType].chain.length;
			
			if (random) {
				frame = int(Math.random() * frameLength);
			}
			
			App.self.setOnEnterFrame(animate);
			animated = true;
		}
		
		public function stopAnimation():void
		{
			animated = false;
			App.self.setOffEnterFrame(animate);
		}

		
		//public var prevCadr:int = 0;
		public function animate(e:Event = null):void
		{
			if (!SystemPanel.animate) return;
			
			var childs:int = animationLayer.numChildren;
			var bitmap:Bitmap;
			var point:Object;
			while (childs--) {
				
				point = animationPoints[childs];
				
				point.degree += point.speed;
				
				if (point.degree > 360) {
					point.degree = 0;
				}
				
				var cadr:uint 			= textures.animation.animations[framesType].chain[point.frame];
				if(point.prev != cadr){
					point.prev = cadr;
					
					radian = (point.degree / 180) * Math.PI;
				
					var funcX:Function = point.funcX;
					var funcY:Function = point.funcY;
				
					var frameObject:Object 	= textures.animation.animations[framesType].frames[cadr];
					
					bitmap = animationLayer.getChildAt(childs) as Bitmap;
					bitmap.bitmapData = frameObject.bmd;
					
					bitmap.x = frameObject.ox + point.x + funcX(radian) * point.radius;
					bitmap.y = frameObject.oy + point.y + funcY(radian) * point.radius;
				}
				
				point.frame ++;
				if (point.frame >= frameLength)
				{
					point.frame = 0;
				}
			}
		}
		
		public var timeID:uint;
		public var delayID:uint;
		public function show():void {
			var viewportX:int = Map.mapWidth - (Map.mapWidth + App.map.x);
			var viewportY:int = Map.mapHeight - (Map.mapHeight + App.map.y);
			
			x = viewportX + Math.random() * App.self.stage.stageWidth;
			y = viewportY + Math.random() * App.self.stage.stageHeight;
			alpha = 0;
			TweenLite.to(this, 0.7, { alpha:1 } );
			
			App.map.mTreasure.addChild(this);
			var that:Whispa = this;
			
			timeID = setTimeout(function():void {
				TweenLite.to(that, 0.7, { alpha:0, onComplete:function():void {
					if(App.map.mTreasure.contains(that)){
						App.map.mTreasure.removeChild(that);
					}
					delayID = setTimeout(show, 5000);
				}});
			}, 4000 + Math.random() * 4000);
		}
		
		
		public function dispose():void {
			stopAnimation();
			clearTimeout(timeID);
			clearTimeout(delayID);
			if(App.map.mTreasure.contains(this)){
				App.map.mTreasure.removeChild(this);
			}
		}
		
		
	}

}