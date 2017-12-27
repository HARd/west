package wins 
{
	import flash.display.Bitmap;
	import flash.events.MouseEvent;
	import flash.text.TextField;

	public class VisitWindow extends Window
	{
		
		public function VisitWindow(settings:Object = null) 
		{
			if (settings == null) {
				settings = new Object();
			}
			
			settings['width'] 			= 500;
			settings['height'] 			= 400;
			settings['title'] 			= settings['title'] ||  Locale.__e("flash:1382952380329");
			settings['hasPaginator'] 	= false;
			settings['hasExit'] 		= false;
			settings['hasTitle'] 		= false;
			settings['faderClickable'] 	= false;
			settings['escExit'] 		= false;
			settings['faderAlpha'] 		= 0.6;
			settings['background']		= settings.background || 'travelPic'
			
			super(settings);
		}
		
		override public function drawBackground():void {
			//var background:Bitmap = new Bitmap(Window.textures.gotoDream);
			var background:Bitmap = new Bitmap(Window.textures[settings.background]);
			layer.addChild(background);
			
			var text:TextField = Window.drawText(settings['title'], {
				fontSize:30,
				autoSize:'center',
				color:0xffffff,
				borderColor:0x86281e,
				borderSize:4,
				shadowColor:0x86281e,
				shadowSize:1
			});
			background.x -= 15;
			
			layer.addChild(text);
			text.x = (background.width - text.width) / 2/* - 15*/;
			text.y = background.height - text.height - 15;
		}
		
	}

}