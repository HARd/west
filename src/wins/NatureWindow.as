package wins
{
	import adobe.utils.CustomActions;
	import buttons.Button;
	import core.Load;
	import flash.display.Bitmap;
	import flash.events.MouseEvent;
	/**
	 * ...
	 * @author 
	 */
	public class NatureWindow extends Window 
	{
		
		public function NatureWindow(settings:Object) {
			
			settings['width'] = 450;
			settings['height'] = 350;
			settings['hasPaginator'] = false;
			settings['hasExit'] = false;
			settings['strong'] = true;
			
			super(settings);
			
			
		}
		
		private var bttn:Button
		override public function drawBody():void 
		{
			bttn = new Button( {
				caption:Locale.__e('flash:1382952380298')
			});
			
			bttn.x = (settings.width - bttn.width) / 2;
			bttn.y = settings.height - bttn.height - 40;
			bttn.addEventListener(MouseEvent.CLICK, onClick);
			
			preloader = new Preloader();
			bodyContainer.addChild(preloader);
			preloader.x = (settings.width)/ 2;
			preloader.y = (settings.height)/ 2 - 36;
			
			var bitmap:Bitmap = new Bitmap();
			Load.loading(Config.getImage('interface', 'nightmare'), function(data:Bitmap):void {
				bitmap.bitmapData = data.bitmapData;
				
				bitmap.x = (settings.width - bitmap.width) / 2;
				bitmap.y = (settings.height - bitmap.height) / 2 - 36;
				bodyContainer.removeChild(preloader);
				
				if (Nature.mode == Nature.HALLOWEEN){
					bitmap.scaleX = -1;
					bitmap.x += bitmap.width;
				}
			});
			
			bodyContainer.addChild(bitmap);
			bodyContainer.addChild(bttn);
		}
		public var preloader:Preloader;
		
		private function onClick(e:MouseEvent):void {
			settings.onOk();
		}
		
		
		override public function close(e:MouseEvent=null):void {
			settings.onClose();
			super.close()
		}
		
		override public function dispose():void {
			bttn.removeEventListener(MouseEvent.CLICK, onClick);
		}
		/*override public function drawBackground():void 
		{
			var background:Bitmap = backing(settings.width, settings.height, 50, "windowDarkBacking");
			layer.addChild(background);
		}*/
	}
	
}