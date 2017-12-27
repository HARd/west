package units 
{
	import com.greensock.TweenLite;
	import core.Load;
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	import flash.utils.Timer;
	import silin.filters.ColorAdjust;
	import ui.SystemPanel;
	public class Butterfly extends AUnit
	{
				
		private var degree:Number = 0;
		private var radian:Number = 0;
		private var speed:Number = 0;
		private var frameObject:Object;
		private var sign:int = 1;
		private var direction:int = Math.random() > 0.5?1: -1;		
		
		private var colors:Array = [0, 0xffff00, 0x00ffff, 0xff00ff];
		private var color:uint = 0;
	
		private var viewportX:int;
		private var viewportY:int;
		
		private var timer:Timer;
		private var timeID:uint;
		private var sitting:Boolean = false;
		private var fly:Boolean = false;
		//private var views:Array = ['butterfly', 'butterfly2' , 'butterfly', 'butterfly2', 'fly'];
		private var views:Array = ['butterfly_blue', 'butterfly_red' , 'butterfly_yellow'];
		private var view:String;
		
		public function Butterfly(object:Object) 
		{
			layer = Map.LAYER_TREASURE;
			
			super(object);
			touchable 	= false;
			transable 	= false;
			removable 	= false;
			clickable 	= false;
			rotateable 	= false;
			takeable 	= false;
			
			cells = 1;
			rows = 1;
			
			var id:int = Math.random() * 4;
			color = colors[id];
			
			type = "Nature";
			framesType = "back";
			alpha = 0;
			
			removeChild(loader);
			loader = null;
			
			view = views[int(Math.random() * views.length)];
			Load.loading(Config.getSwf(type,view), onLoad);
			addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
			
			/*if(color != 0){
				var mtrx:ColorAdjust;
				mtrx = new ColorAdjust();
				mtrx.colorize(color);
				mtrx.brightness(0.1);
				this.filters = [mtrx.filter];
			}*/
		}
		
		public function dispose():void {
			removeEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
			clearTimeout(timeID);
			if (App.map.mTreasure.contains(this)) {
				App.map.mTreasure.removeChild(this);
			}
		}
		
		private function onMouseOver(e:MouseEvent):void
		{
			if (sitting == true && fly == false ) {
				delay = false;
				fly = false;
				sitting = false;
				TweenLite.to(this, 0.8, { alpha:0, onComplete:stopAnimation } );
			}
		}
		
		private var chain:Array = [];
		private var sittingChain:Array = [];
		
		public override function onLoad(data:*):void {
			textures = data;
			addAnimation();
			
			chain = textures.animation.animations[framesType].chain;
			for (var i:* in chain){
				sittingChain.push(chain[i]);
				sittingChain.push(chain[i]);
				sittingChain.push(chain[i]);
			}
			
			onRestartEvent();
		}
		
		//private function onRestartEvent(e:TimerEvent):void {
		private var delay:Boolean = false;
		private function onRestartEvent():void {
			var randTime:int = Math.random() * 4000 + 4000;
			speed = 0.1 + Math.random();
			if (delay == true && fly == false) {
				randTime = 3000;
				delay = false;
				fly = false;
				sitting = false;
				TweenLite.to(this, 0.8, { alpha:0, onComplete:stopAnimation } );	
			}else if (sitting == false && fly == true ) {
				sitting = true;
				if (view == 'fly')
					sitting = false;
					
				fly = false;
			}else if (sitting == true && fly == false ) {
				sitting = false;
				delay = true;
			}else if(delay == false && sitting == false && fly == false){
				startFly();
				fly = true;
			}
			
			timeID = setTimeout(onRestartEvent, randTime);
		}
		
		public function startFly():void {
			stopAnimation();
			viewportX = Map.mapWidth - (Map.mapWidth + App.map.x);
			viewportY = Map.mapHeight - (Map.mapHeight + App.map.y);
			
			x = viewportX + Math.random() * App.self.stage.stageWidth;
			y = viewportY + Math.random() * App.self.stage.stageHeight;
			
			speed = 0.1 + Math.random();
			startAnimation();
			TweenLite.to(this, 0.8, { alpha:1 } );	
		}
		
		override public function addAnimation():void
		{
			animationBitmap = new Bitmap();
			animationBitmap.x = textures.animation.ax;
			animationBitmap.y = textures.animation.ay;
			
			
			degree = 0;
			
			addChild(animationBitmap);
		}
		
		private var sitted:int = 0;
		private var oldCadr:int = -1;
		override public function animate(e:Event = null, forceAnimate:Boolean = false):void
		{
			if (!SystemPanel.animate && !forceAnimate || alpha == 0) return;
			
			if(sitting == false){
				degree += speed*direction;
				radian = (degree / 45) * Math.PI;
				
				if (degree >= 90 || degree <= -90) {
					direction = direction * -1;
				}
		
				x = x + Math.sin(radian) * Math.cos(radian / 2);
				y = y + Math.sin(radian) * Math.cos(radian * 2) * 2 * direction;
				
				framesType = 'back';
				
				if (degree<0){ 
					if (animationBitmap.scaleX != -1){
						frame = 0;
						animationBitmap.scaleX = -1;
						sign = -1;
					}
				}else {
					if (animationBitmap.scaleX != 1){
						frame = 0;
						animationBitmap.scaleX = 1;
						sign = 1;
					}
				}	
			}
				
			var cadr:uint;
			if(sitting == false){
				cadr = chain[frame];
			}else {
				cadr = sittingChain[frame];
			}
			
			if (oldCadr != cadr) {
				oldCadr = cadr;
				frameObject 	= textures.animation.animations[framesType].frames[0][cadr];
				
				animationBitmap.bitmapData = frameObject.bmd;
				animationBitmap.x = frameObject.ox*sign ;
				animationBitmap.y = frameObject.oy;
				
			}
			
			if(sitting && frame == 18 && sitted <= 40) {
				sitted++;
				if (sitted > 40) {
					sitted = 0;
					frame++;
				}
			}else{
				frame++;
			}
			
			
			
			if(!sitting && frame >= chain.length){
				frame = 0;
			}else if(sitting && frame >= sittingChain.length) {
				frame = 0;	
			}	
		}
		
		
		
	}

}