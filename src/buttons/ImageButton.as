package buttons 
{
	import com.greensock.TweenMax;
	import effects.Effect;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.GradientType;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.text.AntiAliasType;
	import flash.text.StaticText;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import silin.filters.ColorAdjust;
	
	
	public class ImageButton extends Button
	{
		public var _bitmapData:BitmapData;
		public var bitmap:Bitmap;
		public var _selected:Boolean = false;
				
		public function ImageButton(bitmapData:BitmapData, settings:Object = null):void 
		{
			this._bitmapData = bitmapData;
			if (settings == null) {
				settings = new Object();
			}
			settings["widthButton"] = settings.widthButton || bitmapData.width;
			settings["heightButton"] = settings.heightButton || bitmapData.height;
			
			settings["scaleX"] = settings.scaleX == undefined?1:settings.scaleX;
			settings["scaleY"] = settings.scaleY == undefined?1:settings.scaleY;
			
			super(settings);
			
			mouseChildren = false;
		}
		
		public function set bitmapData(bmd:BitmapData):void
		{
			_bitmapData = bmd;
			bitmap.bitmapData = _bitmapData;
			bitmap.smoothing = true;
			bitmap.x = (bottomLayer.width  - bitmap.width) * 0.5;
			bitmap.y = (bottomLayer.height - bitmap.height) * 0.5;
		}
		
		override protected function drawBottomLayer():void{
			bitmap = new Bitmap(_bitmapData,"auto",true)						
			bottomLayer.addChild(bitmap);
			bitmap.x = (bottomLayer.width  - bitmap.width) * 0.5;
			bitmap.y = (bottomLayer.height - bitmap.height) * 0.5;
						
			bitmap.scaleX = settings.scaleX;
			if(settings.scaleX < 0){
				bitmap.x += -bitmap.width * settings.scaleX;
			}
		
			bitmap.scaleY = settings.scaleY;
			if(settings.scaleY < 0){
				bitmap.y += -bitmap.height * settings.scaleY;
			}
			

			if(settings.shadow){
				if(settings.shadowFilter ==null){
					var filter:DropShadowFilter = new DropShadowFilter(0, 90, 0x000000, 1, 5, 5, 0.5);
					bitmap.filters = [filter];
				}else {
					bitmap.filters = [settings.shadowFilter];
				}
			}
			
			if (settings.filters != null) {
				for each(var _filter:* in settings.filters) {
					bottomLayer.filters.push(_filter);
				}
			}
			
			addChild(bottomLayer);
		}	
		
		/*
		override protected function drawMiddleLayer() {
		}
		*/
		
		override protected function drawTopLayer():void {
		}
		
		override protected function MouseOver(e:MouseEvent):void {
			if(mode == Button.NORMAL){
				effect(0.1);
			}
		}
		
		override protected function MouseOut(e:MouseEvent):void {			
			if(mode == Button.NORMAL){
				effect(0);
			}
		}
		
		override protected function MouseDown(e:MouseEvent):void {			
			if(mode == Button.NORMAL){
				stop = true;
				effect( -0.1);
				SoundsManager.instance.playSFX(settings.sound);	
				if(onMouseDown != null){
					onMouseDown(e);
				}					
			}
		}
		
		override protected function MouseUp(e:MouseEvent):void {			
			if(mode == Button.NORMAL){
				effect(0.1);
				if(onMouseUp != null){
					onMouseUp(e);
				}
			}
		}
		
		public function set selected(value:Boolean):void {		
			_selected = value;
			if (_selected)
				state = Button.ACTIVE;
			else
				state = Button.NORMAL;
		}
		
		override public function active():void {
			drawDownBottomLayer();
		}
		
		override protected function redrawBottomLayer():void {
			Effect.light(bitmap, 0);
		}
		
		override protected function drawDownBottomLayer():void {
			Effect.light(bitmap, -0.15);
		}
		
		public var stop:Boolean = false;
		public function glowing():void{
			if (!stop) {
				var that:ImageButton = this;
				TweenMax.to(that, 0.6, { glowFilter: { color:0xFFFF00, alpha:0.8, strength: 7, blurX:30, blurY:30 }, onComplete:function():void {
					TweenMax.to(that, 0.6, { glowFilter: { color:0xFFFF00, alpha:0.4, strength: 4, blurX:15, blurY:15 }, onComplete:function():void {
						glowing();
					}});	
				}});
			}else {
				filters = [];
			}
		}

	}

}