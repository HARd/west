package buttons 
{
	import com.greensock.easing.*;
	import com.greensock.TweenLite;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.utils.clearInterval;
	import flash.utils.clearTimeout;
	import flash.utils.setInterval;
	import flash.utils.setTimeout;
	import silin.filters.ColorAdjust;	
	import ui.UserInterface;
	
	public class ImagesButton extends ImageButton
	{
		private var _icon:BitmapData;
		public var iconBmp:Bitmap;
		
		private var scaleIcon:Number;
		
		public var glowIcon:Sprite;
		
		public function ImagesButton(bitmapData:BitmapData, icon:BitmapData = null, settings:Object = null, _scale:Number = 1):void 
		{
			this._icon = icon;
			scaleIcon = _scale;
			
			if (settings == null) {
				settings = {};
			}
			
			settings['ix'] = settings.ix || 0;
			settings['iy'] = settings.iy || 0;
			
			super(bitmapData, settings);
			mouseChildren = false;
		}
		
		private var container:Sprite = new Sprite();
		public function addGlow(bmd:BitmapData, layer:int, scale:Number = 1, color:int = 0xffffff):void
		{
			//UserInterface.colorize(bmd, color, 1);
			var btm:Bitmap = new Bitmap(bmd);
			container = new Sprite();
			container.addChild(btm);
			btm.scaleX = btm.scaleY = scale;
			btm.smoothing = true;
			btm.x = -btm.width / 2;
			btm.y = -btm.height / 2;
			
			addChild(container);
			
			container.mouseChildren = false;
			container.mouseEnabled = false;
			
			container.x = iconBmp.x +iconBmp.width / 2 - 10;
			container.y = iconBmp.y +iconBmp.height / 2 - 10;
			
			glowIcon = container;
			glowIcon.visible = false;
			
			var iconCont:LayerX = new LayerX();
			addChild(iconCont);
			iconCont.addChild(iconBmp);
			
			App.self.setOnEnterFrame(rotateBtm);
			//this.startGlowing();
			
			var that:* = this;
			var startInterval:int = setInterval(function():void {
				clearInterval(startInterval);
				var interval:int = setInterval(function():void {
					iconCont.pluck(0, iconCont.width / 2, iconCont.height / 2);
				}, 10000);
			}, int(Math.random() * 3000));
		}
		
		private function rotateBtm(e:* = null):void {
			glowIcon.rotation +=1;
		}
		
		public function set iconScale(value:Number):void {
			iconBmp.scaleX = iconBmp.scaleY = value;
			iconBmp.x = (bitmap.width - iconBmp.width) / 2;
			iconBmp.y = (bitmap.height - iconBmp.height) / 2;
		}
		
		override protected function drawBottomLayer():void {
			super.drawBottomLayer();
			iconBmp = new Bitmap(_icon, "auto", true);
			bottomLayer.addChild(iconBmp);
			iconBmp.smoothing = true;
			iconBmp.scaleX = iconBmp.scaleY = scaleIcon;
			
			//if (iconBmp.width > iconBmp.height) {
				//iconBmp.width = 100;
				//iconBmp.scaleY = iconBmp.scaleX;
			//}else {
				//iconBmp.height = 100;
				//iconBmp.scaleX = iconBmp.scaleY;
			//}
			
			iconBmp.x = settings['ix'] || ((_bitmapData.width - iconBmp.width) / 2);
			iconBmp.y = settings['iy'] || ((_bitmapData.height - iconBmp.height) / 2) - 2;
		}	
		
		private var cont:Sprite = new Sprite();
		private var timeOut:uint = 0;
		private var time:Number = 0.5;
		public function startRotate(delay:uint, timeOut:int = 10000, time:Number = 0.5):void 
		{
			this.time = time;
			if(this.timeOut == 0){
				this.timeOut = timeOut;
				cont.addChild(bitmap);
				addChildAt(cont, 0);
				cont.x += bitmap.width / 2;
				cont.y += bitmap.height / 2;
				bitmap.x = - bitmap.width / 2;
				bitmap.y = - bitmap.height / 2;
			}
			
			timeout = setTimeout(rotate, delay+10);
		}
		
		public function stopRotate():void {
			if (timeout > 0)
				clearTimeout(timeout);
				
			if (tween != null)
				tween.kill();
				
			cont.rotation = 0;	
			timeout = 0;	
		}
		
		private var timeout:int = 0;
		private var tween:TweenLite = null
		private function rotate():void {
			tween = TweenLite.to(cont, time, { rotation:cont.rotation + 360 / 5, onComplete:function():void {
				timeout = setTimeout(rotate, timeOut);
			}});
		}
		
		public function set icon(icon:BitmapData):void {
			iconBmp.bitmapData = icon;
			iconBmp.x = (_bitmapData.width - iconBmp.bitmapData.width) / 2;
			iconBmp.y = (_bitmapData.height - iconBmp.bitmapData.height) / 2;
		}
		
		/*override public function disable():void {
			var mtrx:ColorAdjust;
			mtrx = new ColorAdjust();
			mtrx.saturation(0);
			iconBmp.filters = [mtrx.filter];
			this.mouseChildren = false;
		}*/
		
		override public function dispose():void
		{
			super.dispose();
		}
	}
}