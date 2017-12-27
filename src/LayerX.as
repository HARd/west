package  
{
	import com.demonsters.debugger.MonsterDebuggerConnectionMobile;
	import com.greensock.plugins.TransformAroundPointPlugin;
	import com.greensock.plugins.TweenPlugin;
	import flash.display.Bitmap;
	import flash.display.GradientType;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.utils.setTimeout;
	import ui.UserInterface;
	import wins.Window;

	import com.greensock.*;
	import com.greensock.easing.*;
	import flash.display.Sprite;
	
	public class LayerX extends Sprite
	{
		
		public function LayerX() {
			TweenPlugin.activate([TransformAroundPointPlugin]);
		}
		
		public var tip:*;
		
		private var __tween:TweenMax;
		private var __tween2:TweenMax;
		private var __tween3:TweenMax;
		public var __arrow:Bitmap;
		private var __position:String;
		private var __glowingTimes:int;
		private var __container:* = null;
		
		public var __hasGlowing:Boolean = false;
		public var __hasPointing:Boolean = false;
		public var __hasAlphaEff:Boolean = false;

		
		public function showGlowing(times:int = 0):void
		{
			__glowingTimes = times;
			if (__hasGlowing) return;
			else startGlowing();
		}
	
		public var glowingColor:* = 0xFFFF00;
		public function startGlowing(color:* = null):void
		{
			if (color != null) glowingColor = color;
			__hasGlowing = true;
			__tween = TweenMax.to(this, 0.8, { glowFilter: { color:glowingColor, alpha:1, strength: 2, blurX:15, blurY:15}, onComplete:restartGlowing} );
		}
		
		public function restartGlowing():void
		{
			if (!this.parent) return;
			__glowingTimes --;
			if (__glowingTimes == 0) {
				__tween = TweenMax.to(this, 0.8, { glowFilter: { color:glowingColor, alpha:0, strength: 4, blurX:0, blurY:0 }, onComplete:function():void {
					filters = [];
				}} );
			}else{
				__tween = TweenMax.to(this, 0.8, { glowFilter: { color:glowingColor, alpha:0.7, strength: 4, blurX:6, blurY:6 }, onComplete:startGlowing } );	
			}
		}
		
		public function hideGlowing():void
		{
			__hasGlowing = false;
			if(__tween != null){
				__tween.complete(true, true);
				__tween.kill();
				__tween = null;
			}
			this.filters = null;
		}
		
		
		private var _alphaDelay:Number;
		private var _minAlpha:Number;
		public function startAlphaEff(color:* = null, minAlpha:Number = 0, delay:Number = 1):void
		{
			_alphaDelay = delay;
			_minAlpha = minAlpha;
			__hasAlphaEff = true;
			__tween = TweenMax.to(this, _alphaDelay, { alpha:1, onComplete:restartAlphaEff} );
		}
		
		private function startAgainAlphaEff():void {
			__tween = TweenMax.to(this, _alphaDelay, { alpha:1, onComplete:restartAlphaEff} );
		}
		
		public function restartAlphaEff():void
		{
			var that:* = this;
			setTimeout(function():void {
				__tween = TweenMax.to(that, _alphaDelay, { alpha:_minAlpha , onComplete:startAgainAlphaEff} );		
			}, 1000);
		}
		
		public function hideAlphaEff():void
		{
			__hasAlphaEff = false;
			if(__tween3 != null){
				__tween3.complete(true, true);
				__tween3.kill();
				__tween3 = null;
			}
			this.filters = null;
		}
		
		
		private var __y:int = 0;
		private var __x:int = 0;
		private var __deltaX:int = 0;
		private var __deltaY:int = 0;
		
		private var __arrowSprite:Sprite = new Sprite();
		
		public function set arrowVisible(value:Boolean):void {
			if (value == false) {
				__arrowSprite.visible = false;
			}else {
				__arrowSprite.visible = true;	
			}
		}
		
		public function showPointing(position:String="top", deltaX:int = 0, deltaY:int = 0, container:* = null, text:String = '', textSettings:Object = null, isQuest:Boolean = false):void
		{
			if (__hasPointing) return;
			
			__arrowSprite = new Sprite();
			__arrowSprite.mouseChildren = __arrowSprite.mouseEnabled = false;
			
			__deltaX = deltaX;
			__deltaY = deltaY;
			if (text != '' && (position == 'right' || position == 'left')){
				__arrow = new Bitmap(UserInterface.textures.questArrow);
			}else if (position == "targeting"){
				__arrow = new Bitmap();
				__arrowSprite.visible = false;
			}else{
				__arrow = new Bitmap(UserInterface.textures.tutorialArrow);
			}
			
			__arrow.smoothing = true;
			
			 
			var textLabel:TextField;
			if (text != '') {
				textLabel = Window.drawText(text, textSettings);
			}
			
			this.__position = position;
			
			if (__position == "bottom") {
				__arrow.rotation = -90;
				__arrow.x = -__arrow.width / 2;
				__arrow.y = __arrow.height;
				__arrowSprite.addChild(__arrow);
				
				__arrowSprite.x = x + this.width / 2 + __deltaX;
				__arrowSprite.y = y + 10 + __deltaY;
				
			}else if(__position == "right"){
				
				__arrow.rotation = 180;
				__arrow.x = __arrow.width;
				__arrow.y = __arrow.height / 2;
				__arrowSprite.addChild(__arrow);
				
				__arrowSprite.x = x + width + __deltaX;
				__arrowSprite.y = y + height / 2 + __deltaY;
				
				if (textLabel) {
					var matrix:Matrix = new Matrix();
					matrix.createGradientBox(100, __arrow.height - 4, 0);
					
					__arrowSprite.graphics.beginGradientFill(GradientType.LINEAR, [0xffffff, 0xffffff], [0.6, 0], [0, 255], matrix);
					__arrowSprite.graphics.drawRect(__arrow.width - 4, -__arrow.height / 2 + 2, 100, __arrow.height - 4);
					__arrowSprite.graphics.endFill();
					
					__arrowSprite.addChild(textLabel);
					textLabel.x = __arrow.x + 10;
					textLabel.y = __arrow.y - __arrow.height + (__arrow.height - textLabel.height) / 2 + 2;
				}
			}else if(__position == "left"){//right
				
				__arrowSprite.addChild(__arrow);
				__arrow.rotation = -180;
				__arrow.y = __arrow.height / 2;
				
				__arrowSprite.x = int(x + __deltaX) - 50;
				__arrowSprite.y = int(y + height / 2 + __deltaY - 4);
				
				if (textLabel) {
					__arrow.rotation = 0;
					__arrowSprite.addChild(textLabel);
					__arrow.y -= __arrow.height;
					__arrow.x -= __arrow.width;
					textLabel.x = __arrow.x - textLabel.width;
					textLabel.y =  textLabel.height / 2 - 30;
				}
				
			}else if (__position == "top") {
				__arrow.rotation = 90;
				__arrow.x = __arrow.width / 2;
				__arrow.y = -__arrow.height;
				__arrowSprite.addChild(__arrow);
				
				__arrowSprite.x = x + this.width / 2 + __deltaX;
				__arrowSprite.y = y - 10 + __deltaY;
			
			}else if (__position == "targeting") {
				__arrow.rotation = -90;
				__arrowSprite.addChild(__arrow);
				__arrow.x = -__arrow.width / 2;
				__arrow.y = -10;
				//__arrow.x = 0;
				//__arrow.y = 0;
				
				__arrowSprite.x = x + this.width / 2 + __deltaX - 4;
				__arrowSprite.y = y - 10 + __deltaY;
			
			}else {
				__arrowSprite.addChild(__arrow);
				__arrowSprite.x = x + __deltaX;
				__arrowSprite.y = y - 10 + __deltaY;
			}
			
			__x = __arrowSprite.x;
			__y = __arrowSprite.y;
			
			/*__arrowSprite.graphics.beginFill(0xff0000, 1);
			__arrowSprite.graphics.drawCircle(0, 0, 2);
			__arrowSprite.graphics.endFill();*/
			
			if (container == null) {
				App.map.mTreasure.addChild(__arrowSprite);
			}else {
				__container = container;
				__container.addChild(__arrowSprite);
				
				if (__container is Tutorial) {
					__arrowSprite.x = __deltaX;
					__arrowSprite.y = __deltaY;
				}
			}
			
			startPointing();
			__hasPointing = true;
		}
		
		private var targetingArrowY:Number = __y;
		public function startPointing():void
		{
			if (__position == "right") {//left
				__tween2 = TweenMax.to(__arrowSprite, 0.6, {x:__x + 40, onComplete:restartPointing, ease:Strong.easeInOut  } );
			}else if (__position == "left") {//right
				__tween2 = TweenMax.to(__arrowSprite, 0.6, { x:__x - 20, onComplete:restartPointing, ease:Strong.easeInOut  } );	
			}else if (__position == "targeting") { // targeting personage move 1
				__arrowSprite.alpha = 0;
				__tween2 = TweenMax.to(__arrowSprite, 1.2, {y:__y - 90, onComplete:targetingArrowMove1, ease:Linear.easeNone,  scaleX:1, scaleY:1, alpha:0});
			}else {
				__tween2 = TweenMax.to(__arrowSprite, 0.6, { y:__y -50, onComplete:restartPointing, ease:Strong.easeInOut  } );
			}
		}
		
		private function targetingArrowMove1():void // targeting personage move 2
		{
			__tween2 = TweenMax.to(__arrowSprite, 0.6, { y:__y + 25, onComplete:targetingArrowMove2, ease:Linear.easeNone,  scaleX:1, scaleY:1, alpha:0.85} );		
		}
		private function targetingArrowMove2():void // targeting personage move 3
		{
			__tween2 = TweenMax.to(__arrowSprite, 0.25, { y:__y + 50, onComplete:startPointing, ease:Linear.easeNone,  scaleX:1, scaleY:1, alpha:0} );		
		}

		
		public function restartPointing():void
		{
			if (__position == "right") {//left
				__tween2 = TweenMax.to(__arrowSprite, 0.6, { x:__x, onComplete:startPointing } );	
			}else if (__position == "left") {//right
				__tween2 = TweenMax.to(__arrowSprite, 0.6, { x:__x, onComplete:startPointing } );	
			}else {
				__tween2 = TweenMax.to(__arrowSprite, 0.6, { y:__y, onComplete:startPointing } );	
			}
		}
		
		public function hidePointing():void
		{
			__hasPointing = false;
			
			if(__tween2 != null){
				__tween2.complete(true, true);
				__tween2 = null;
				if (__container == null ) {
					if (__arrowSprite.parent) {
						var _parent:* = __arrowSprite.parent;
						_parent.removeChild(__arrowSprite);
					}
				}else {
					__container.removeChild(__arrowSprite);
					__container = null;
				}
			}
		}
		
		public var isPluck:Boolean = false;
		private var pluckY:Number;
		private var pluckX:Number;
		public function pluck(delay:uint = 0, xPos:int = 0, yPos:int = 0):void 
		{
			pluckY = yPos;
			pluckX = xPos;
			if (delay > 0)
				setTimeout(pluckIn, delay);
			else
				pluckIn();
		}
		 
		private var plackTween:TweenLite;
		private var tweenPlugin:TweenPlugin;
		private var sclKoef:int = 1;
		private function pluckIn():void {
			if (isPluck) return;
			
			isPluck = true;
			sclKoef = this.scaleX;
			
			var cslX:Number = sclKoef * 1.2;
			
			plackTween = TweenLite.to(this, 0.3, { transformAroundPoint: { point:new Point(pluckX, pluckY), scaleX:cslX, scaleY:0.8 }, ease:Strong.easeOut} );//1.2 0.8
			setTimeout(function():void {
				pluckOut();
			}, 200);
		}
		
		
		private var plackOutTween:TweenLite;
		private function pluckOut():void {
			var cslX:Number = sclKoef;
			plackOutTween = TweenLite.to(this, 1, { transformAroundPoint: { point:new Point(pluckX, pluckY), scaleX:cslX, scaleY:1 }, ease:Elastic.easeOut, onComplete:function():void { isPluck = false; } }  );
		}
		
		public function pluckDispose():void
		{
			//TweenPlugin.activate(
			//tweenPlugin.onComplete
			
			if (plackTween && plackTween.active) {
				
				plackTween.kill();
			}
			if (plackOutTween && plackOutTween.active) {
				plackOutTween.kill();
			}
			
			tweenPlugin = null;
			plackTween = null;
			plackOutTween = null;
		}
	}
}
