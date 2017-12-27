package buttons 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.text.TextFormat;
	
	
	public class IconButton extends Button
	{
		
		public var iconBg:Bitmap;
						
		public function IconButton(bitmapData:BitmapData, settings:Object = null) 
		{
			if (settings == null) {
				settings = new Object();
			}
						
			super(settings);
			
			iconBg = new Bitmap(bitmapData)
			bottomLayer.addChild(iconBg);
			
			textLabel.x = (iconBg.width - textLabel.width) / 2;
			textLabel.y = (iconBg.height - textLabel.height) / 2;
		}
		
		override protected function drawBottomLayer():void
		{
			addChildAt(bottomLayer, 0);
			
			if(iconBg)
				bottomLayer.addChild(iconBg);
			
			if(style){
				style.color = settings.fontColor; 
				textLabel.setTextFormat(style);
			}
			
			if (textLabel) {
				textFilter = new GlowFilter(settings.fontBorderColor, 1, settings.fontBorderSize, settings.fontBorderSize, 10, 1);
				var shadowFilter:DropShadowFilter = new DropShadowFilter(1,90,settings.fontBorderColor,0.9,2,2,2,1);
				textLabel.filters = [textFilter, shadowFilter];
			}
		}
		
		override protected function drawDownBottomLayer():void
		{
			bottomLayer.addChild(iconBg);
			
			addChildAt(bottomLayer, 0);
			
			if(style){
				style.color = settings.active.fontColor; 
				textLabel.setTextFormat(style);
			}
			if(textLabel){
				textFilter = new GlowFilter(settings.active.fontBorderColor, 1, settings.fontBorderSize, settings.fontBorderSize, 10, 1);
				var shadowFilter:DropShadowFilter = new DropShadowFilter(1,90,settings.active.fontBorderColor,0.9,2,2,2,1);
				textLabel.filters = [textFilter, shadowFilter];
			}
			if (settings.hasDotes) {
				bottomLayer.x = 10;
			}
		}	
		
	}

}