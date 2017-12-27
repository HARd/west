package wins 
{
	import buttons.Button;
	import core.Load;
	import flash.display.Bitmap;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	/**
	 * ...
	 * @author ...
	 */
	public class InformWindow2 extends Window 
	{
		public static const BOAT_MODE:int = 1;
		public static const DAMBA_MODE:int = 2;
		private var bttn:Button;
		public function InformWindow2(settings:Object=null) 
		{
			if (settings == null) {
				settings = new Object();
			}
			
			settings['background'] 		= 'alertBacking';
			settings['width'] 			= 585;
			settings['height'] 			= 485;
			settings['title'] 			= Locale.__e('storage:315:title');//Locale.__e('flash:1461228262492');
			settings['hasPaginator'] 	= false;
			settings['hasExit'] 		= false;
			settings['hasTitle'] 		= true;
			settings['faderClickable'] 	= true;
			settings['faderAlpha'] 		= 0.6;
			settings['popup'] 			= true;
			settings['text']			= settings['text'] || Locale.__e('flash:1465215209848');//Locale.__e('flash:1461140994323');
			settings['mode']			= settings['mode'] || 0;
			settings['shadowColor'] = 0x513f35;
			settings['shadowSize'] = 4;
			
			if (settings.mode == BOAT_MODE) settings['width'] = 540;
			if (settings.mode == DAMBA_MODE) {
				settings['title'] = Locale.__e('flash:1461228262492');
				settings['background'] 	= 'goldBacking';
				settings['mirrorDecor'] 	= 'goldTitleDec';
			}
			super(settings);
		}
		
		override public function drawBody():void {
			var picture:Bitmap = new Bitmap();
			bodyContainer.addChild(picture);
			
			var pic:String = 'informer';
			var type:String = 'jpg';
			if (settings.mode == BOAT_MODE) pic = 'PicBoat';
			if (settings.mode == DAMBA_MODE) {
				pic = 'WDambaPic';
				type = 'png';
			}
			Load.loading(Config.getImageIcon('help', pic, type), function(data:*):void {
				picture.bitmapData = data.bitmapData;
				picture.x = (settings.width - picture.width) / 2;
				picture.y = 60;
			});
			
			var descSettings:Object = {
				color:			0x572907,
				border:			false,
				width:			settings.width - 100,
				word:			true,
				multiline:		true,
				textAlign:		'center',
				fontSize:		32,
				textLeading:	-1
			}
			var description:TextField = drawText(settings.text, descSettings);
			description.x = 50;
			description.y = 290;
			bodyContainer.addChild(description);
			
			if (settings.mode == DAMBA_MODE) {
				description.y = 320;
			}
			
			bttn = new Button( { 
				caption:	Locale.__e('flash:1382952380242'),
				width:180,
				height:50
			} );
			bttn.x = (settings.width - bttn.width) / 2;
			bttn.y = settings.height - bttn.height;
			bodyContainer.addChild(bttn);
			bttn.addEventListener(MouseEvent.CLICK, onClick);
			
			if (settings.mode == BOAT_MODE) {
				var addImage:Bitmap = new Bitmap();
				bodyContainer.addChild(addImage);
				
				Load.loading(Config.getImageIcon('help', 'BoatPic'), function(data:*):void {
					addImage.bitmapData = data.bitmapData;
					addImage.x = -130;
					addImage.y = 60;
				});
			}
		}
		
		public function onClick(e:MouseEvent):void {
			close();
			
			if (settings.mode == BOAT_MODE) {
				var boat:Array = Map.findUnits([315]);
				if (boat.length > 0) {
					App.map.focusedOn(boat[0], true);
				}
			} else if (settings.mode == DAMBA_MODE) {
				
			} else {
				var box:Array = Map.findUnits([2094]);
				if (box.length > 0) {
					App.map.focusedOn(box[0], true);
				}
			}
		}
		
		override public function close(e:MouseEvent = null):void {
			//if (App.user.settings.hasOwnProperty('inf3')) {
				//var array:Array = App.user.settings.inf3.split('_');
				//if (!array[2]) {
					//if (!array[1]) {
						//array[1] = App.time;
					//}else {
						//array[2] = App.time;
					//}
					//App.user.storageStore('inf3', array.join('_'), true);
				//}
			//}else {
				//App.user.storageStore('inf3', App.time + '_', true);
			//}
			super.close();
		}
		
	}

}