package buttons 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import silin.filters.ColorAdjust;
	
	
	public class MixedButton extends Button
	{
		
		public var bitmapData:BitmapData;
		public var bitmapDataAdded:BitmapData;
				
		public function MixedButton(bitmapData:BitmapData, settings:Object = null, bitmapDataAdded:BitmapData = null) 
		{
			this.bitmapData = bitmapData;
			this.bitmapDataAdded = bitmapDataAdded;
			
			if (settings == null) {
				settings = new Object();
			}
			
			settings["width"] = settings.widthButton || bitmapData.width;
			settings["height"] = settings.heightButton || bitmapData.height;
			
			settings["scaleX"] = settings.scaleX == undefined?1:settings.scaleX;
			settings["scaleY"] = settings.scaleY == undefined?1:settings.scaleY;
			
			super(settings);
			
			if (bitmapDataAdded != null)
			{
				var bitmap:Bitmap = new Bitmap(bitmapDataAdded)
				topLayer.addChild(bitmap)
				
				if (settings.giftMode == "FREE")
				{
					bitmap.x = -36
					bitmap.y = -25
				}
				if (settings.giftMode == "TAKE")
				{
					bitmap.x = 113
					bitmap.y = -32
					bitmap.scaleX = bitmap.scaleY = 0.75
					bitmap.smoothing = true
				}
			}
			
			mouseChildren = false;
			
		}
		
		override protected function drawBottomLayer():void{
			var bitmap:Bitmap = new Bitmap(bitmapData,"auto",true);
						
			bottomLayer.addChild(bitmap);
			bitmap.x = (bottomLayer.width - bitmap.width) / 2;
			bitmap.y = (bottomLayer.height - bitmap.height) / 2;
						
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
				for each(var f:* in settings.filters) {
					bottomLayer.filters.push(f);
				}
			}
			
			addChild(bottomLayer);
		}	
		
		override public function enable():void {
			this.filters = [];
			this.mouseChildren = true;
			effect(0,1);
		}	
		
		override public function active():void {
			effect(-0.2, 0.2)
		}	
		
		override protected function MouseOver(e:MouseEvent):void {
			if(mode == Button.NORMAL){
				effect(0.1);
			}
		}
		
		override protected function MouseOut(e:MouseEvent):void {			
			if(mode == Button.NORMAL){
				effect(0,1);
			}
		}
		
		override protected function MouseDown(e:MouseEvent):void {			
			if(mode == Button.NORMAL){
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
		
		
	}

}