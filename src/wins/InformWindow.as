package wins 
{
	import buttons.Button;
	import core.Load;
	import flash.display.Bitmap;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	public class InformWindow extends Window 
	{
		private var bttn:Button;
		public function InformWindow(settings:Object=null) 
		{
			if (settings == null) {
				settings = new Object();
			}
			
			settings['background'] 		= 'alertBacking';
			settings['width'] 			= 585;
			settings['height'] 			= 485;
			settings['title'] 			= Locale.__e('flash:1455115172568');
			settings['hasPaginator'] 	= false;
			settings['hasExit'] 		= false;
			settings['hasTitle'] 		= true;
			settings['faderClickable'] 	= true;
			settings['faderAlpha'] 		= 0.6;
			settings['popup'] 			= true;
			settings['text']			= settings['text'] || Locale.__e('flash:1455113972017');
			settings['shadowColor'] 	= 0x513f35;
			settings['shadowSize'] 		= 4;
			
			super(settings);
		}
		
		override public function drawBody():void {
			var picture:Bitmap = new Bitmap();
			bodyContainer.addChild(picture);
			
			Load.loading(Config.getImageIcon('help', 'HelpCityPic','jpg'), function(data:*):void {
				picture.bitmapData = data.bitmapData;
				picture.x = (settings.width - picture.width) / 2;
				picture.y = 60;
			});
			
			var description:TextField = drawText(settings.text, {
				color:			0x572907,
				border:			false,
				width:			settings.width - 100,
				word:			true,
				multiline:		true,
				textAlign:		'center',
				fontSize:		32,
				textLeading:	-1
			});
			description.x = 50;
			description.y = 310;
			bodyContainer.addChild(description);
			
			bttn = new Button( { 
				caption:	Locale.__e('flash:1382952380242')
			} );
			bttn.x = (settings.width - bttn.width) / 2;
			bttn.y = settings.height - bttn.height;
			bodyContainer.addChild(bttn);
			bttn.addEventListener(MouseEvent.CLICK, close);
		}
		
		override public function close(e:MouseEvent = null):void {
			if (settings.hasOwnProperty('check') && settings.check != false) {
				if (App.user.settings.hasOwnProperty('inf')) {
					var array:Array = App.user.settings.inf.split('_');
					if (!array[2] || array[2] == '0') {
						if (array[1] == 0) {
							array[1] = 1;
						}else {
							array[2] = 1;
						}
						App.user.storageStore('inf', array.join('_'), true);
					}
				}else {
					App.user.storageStore('inf', '0_0_0', true);
				}
			}
			super.close();
		}
		
		override public function dispose():void {
			bttn.removeEventListener(MouseEvent.CLICK, close);
			super.dispose();
		}
		
		public static function checkTownInform():void {
			if (App.user.worldID == Travel.TOWN && App.user.mode == User.OWNER) {
				var canShow:Boolean = false;
				if (App.user.settings.hasOwnProperty('inf')) {
					var array:Array = App.user.settings.inf.split('_');
					if (!array[2] || array[2] == '0') canShow = true;
				}else {
					canShow = true;
				}
				
				if (canShow) {
					new InformWindow({check:true}).show();
				}
			}
		}
		
	}

}