package wins 
{
	import buttons.Button;
	import buttons.UpgradeButton;
	import flash.display.Bitmap;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import ui.UserInterface;
	import units.Missionhouse;
	/**
	 * ...
	 * @author 
	 */
	public class TresureWindow extends Window
	{
		public static var isOpen:Boolean = false;
		
		public var textLabel:TextField = null;
		private var bitmapLabel:Bitmap = null;
		
		public function TresureWindow(settings:Object = null) 
		{
			if (settings == null) {
				settings = new Object();
			}
			
			settings["label"] 			= settings.label || null;
			settings['text'] 			= settings.text || '';
			settings['textAlign'] 		= settings.textAlign || 'center';
			settings['autoSize'] 		= settings.autoSize || 'center';
			settings['textSize'] 		= settings.textSize || 24;
			settings['padding'] 		= settings.padding || 20;
			settings['popup']			= true;
			settings['forcedClosing']	= settings.forcedClosing || false;
			settings['hasButtons']		= settings['hasButtons'] == null ? true : settings['hasButtons'];
			settings['buttonText']		= settings['buttonText'] || Locale.__e('flash:1394010224398');
			settings['instanceId'] = settings.instanceId;
			settings["width"]			= settings.width || 510;
			settings["height"] 			= settings.height || 200;
			settings["hasPaginator"] 	= false;
			settings["hasArrows"]		= false;
			settings["hasTitle"]		= true;
			settings['autoClose'] = true;
			settings["imageScale"]	 	= settings.imageScale || 1;
			if (!settings.hasOwnProperty("closeAfterOk"))
			{
				settings["closeAfterOk"] = true;
			}
			
			super(settings);
			
			isOpen = true;
		}
		
		override public function drawBackground():void 
		{
			var background:Bitmap = backing2(settings.width, settings.height, 45, "questsSmallBackingTopPiece", 'questsSmallBackingBottomPiece');// , "questsSmallBackingBottomPiece");
			layer.addChild(background);
		}
		
		override public function drawTitle():void 
		{
			drawImage();
			
			titleLabel = titleText( {
				title				: settings.title,
				color				: settings.fontColor,
				multiline			: true,			
				fontSize			: settings.fontSize,				
				textLeading	 		: settings.textLeading,				
				borderColor 		: settings.fontBorderColor,			
				borderSize 			: settings.fontBorderSize,	
				shadowBorderColor	: settings.shadowBorderColor || settings.fontColor,
				width				: settings.width - 80,
				textAlign			: 'center',
				sharpness 			: 50,
				thickness			: 50,
				border				: true
			})
			
			titleLabel.x = (settings.width - titleLabel.width) * .5;
			titleLabel.y = 14; //12
			bodyContainer.addChild(titleLabel);
		}
		
		override public function drawBody():void 
		{
			if (exit) exit.y -= 20;
			
			if (settings.label == null)
					titleLabel.y -= 50;
			
			textLabel = Window.drawText(settings.text, {
				fontSize:26,
				color:0xffffff,
				borderColor:0x855729,
				borderSize:4,
				fontSize:settings.textSize,
				textAlign:settings.textAlign,
				autoSize:settings.autoSize,
				multiline:true
			});
			
			textLabel.wordWrap = true;
			textLabel.mouseEnabled = false;
			textLabel.mouseWheelEnabled = false;
			textLabel.width = 400;
			textLabel.height = textLabel.textHeight + 4;
			
			textLabel.y = (settings.height - textLabel.height)/2 - 20;
			textLabel.x = (settings.width - textLabel.width) / 2;
			
			bodyContainer.addChild(textLabel);
			
			drawMirrowObjs('diamondsTop', settings.width / 2 - settings.titleWidth / 2 - 5, settings.width / 2 + settings.titleWidth / 2 + 5, settings.titleHeight/2 + titleLabel.y + 3, true, true, true);
			drawMirrowObjs('diamonds', -1, settings.width + 1, settings.height - 92);
			
			drawBttns();
		}
		
		private function drawImage():void 
		{
			bitmapLabel = new Bitmap();
			bitmapLabel.bitmapData = UserInterface.textures.tresure;
			bitmapLabel.smoothing = true;
			bodyContainer.addChild(bitmapLabel);
			bitmapLabel.x = (settings.width - bitmapLabel.width) / 2;
			bitmapLabel.y = -bitmapLabel.height/2 - 80;
			bitmapLabel.scaleX = bitmapLabel.scaleY = settings.imageScale;
		}
		
		public var OkBttn:UpgradeButton;
		public function drawBttns():void 
		{
			if (settings.hasButtons)
			{
				OkBttn = new UpgradeButton(UpgradeButton.TYPE_ON,{
					caption:settings.buttonText,
					width:236,
					height:55,
					fontBorderColor:0x002932,
					countText:"",
					fontSize:28,
					iconScale:0.95,
					radius:30,
					textAlign:'left',
					autoSize:'left',
					widthButton:230
				});
				OkBttn.textLabel.x = (OkBttn.bottomLayer.width - OkBttn.textLabel.width)/2;
				OkBttn.addEventListener(MouseEvent.CLICK, onOkBttn);
			
				bottomContainer.addChild(OkBttn);
				OkBttn.x = settings.width / 2 - OkBttn.width / 2;
			}
			
			bottomContainer.y = settings.height - bottomContainer.height / 2 + 7;
			bottomContainer.x = 0;
		}
		
		public function onOkBttn(e:MouseEvent):void {
			var arrInstance:Array = Map.findUnits([settings.instanceId]);
				
			if (arrInstance.length > 0) {
				var instance:Missionhouse = arrInstance[0];
				App.map.focusedOn( { x:instance.x + 20, y:instance.y + 50 }, false);
				
			}else {
				Travel.goTo(App.data.storage[settings.instanceId].land);
			}
			
			close();
		}
		
		override public function dispose():void {
			if(OkBttn != null){
				OkBttn.removeEventListener(MouseEvent.CLICK, onOkBttn);
			}
			isOpen = false;
			super.dispose();
		}
		
	}

}