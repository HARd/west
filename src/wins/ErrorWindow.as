package wins 
{
	import buttons.Button;
	import flash.display.Bitmap;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	/**
	 * ...
	 * @author ...
	 */
	public class ErrorWindow extends Window
	{
		public var textLabel:TextField = null;
		private var bitmapLabel:Bitmap = null;
		private var back:Bitmap;
		
		public function ErrorWindow(settings:Object = null) 
		{
			if (settings == null) {
				settings = new Object();
			}
			
			settings['hasTitle']		= settings.hasTitle || false;
			settings["label"] 			= settings.label || null;
			settings['text'] 			= settings.text || '';
			settings['textAlign'] 		= settings.textAlign || 'center';
			settings['autoSize'] 		= settings.autoSize || 'center';
			settings['textSize'] 		= settings.textSize || 24;
			settings['padding'] 		= settings.padding || 20;
			
			settings['faderAsClose']	= settings.faderAsClose || false;
			settings['faderClickable']	= settings.faderClickable || false;
			settings['closeAfterOk']	= settings.closeAfterOk || false;
			settings['escExit']			= settings.escExit || false;
			settings['popup']			= settings.popup || true;
			settings['forcedClosing']	= settings.forcedClosing || false;
			
			settings['hasButtons']		= settings['hasButtons'] == null ? true : settings['hasButtons'];
			settings['buttonText']		= settings['buttonText'] || Locale.__e('flash:1382952380298');
			
			settings['ok']				= settings.ok || null;
			
			settings["width"]			= settings.width || 429;
			settings["height"] 			= settings.height || 207;
			
			settings["hasPaginator"] 	= false;
			settings["hasArrows"]		= false;
			
			settings["hasTitle"]		= true;
			settings["hasExit"]			= settings.hasExit || false;
			
			settings["hasStorageBtn"]	= settings.hasStorageBtn || false;
			settings['storageBtnText']	= settings['storageBtnText'] || Locale.__e('flash:1382952380298');
			
			settings["image"]	 		= settings.image || null;
			settings["imageX"]	 		= settings.imageX || 0;
			settings["imageY"]	 		= settings.imageY || 0;
			settings["imageScale"]	 	= settings.imageScale || 1;
			
			settings["textPaddingY"]	 	= settings.textPaddingY || 0;
			settings["textPaddingX"]	 	= settings.textPaddingX || 0;
			settings["bttnPaddingY"]	 	= settings.bttnPaddingY || 0;
			
			//if (settings.isPopup)
				//settings['popup'] = true;
			
			if (!settings.hasOwnProperty("closeAfterOk"))
			{
				settings["closeAfterOk"] = true;
			}
			
			super(settings);
		}
		
		override public function drawBackground():void 
		{
			//var background:Bitmap = backing2(settings.width, settings.height, 45, "questsSmallBackingTopPiece", 'questsSmallBackingBottomPiece');// , "questsSmallBackingBottomPiece");
			//bodyContainer.addChild(background);
		}
		/*override public function create():void 
		{
			super.create();
			drawTitle();
		}*/
		override public function drawTitle():void 
		{
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
	//			autoSize			: 'center',
				textAlign			: 'center',
				sharpness 			: 50,
				thickness			: 50,
				border				: true
			})
			
			titleLabel.x = (settings.width - titleLabel.width) * .5 + 40;
			titleLabel.y = 25;
			
			bodyContainer.addChild(titleLabel);
		}
		
		override public function drawBody():void 
		{
			if (exit)
			{
				exit.y += 0;
				exit.x += 55;
			}
			back = backing2(settings.width, settings.height, 45, "alertBacking", 'alertBacking');
			//drawMirrowObjs('storageWoodenDec', -5 + 50, settings.width + 5 + 50, 70, false, false, false, 1, -1);
			//drawMirrowObjs('storageWoodenDec', -5 + 50, settings.width + 5 + 50, settings.height - 80 + 6);
			back.x = (settings.width - back.width) / 2 + 50;
			back.y = (settings.height - back.height) / 2 -2;
			bodyContainer.addChildAt(back, 0);
			
			if (settings.label == null)
					titleLabel.y -= 50;
			
			textLabel = Window.drawText(settings.text, {
				fontSize:26,
				color:0x65371b,
				borderColor:0xe7c998,
				borderSize:4,
				fontSize:settings.textSize,
				textAlign:settings.textAlign,
				autoSize:settings.autoSize,
				multiline:true
			});

			textLabel.wordWrap = true;
			textLabel.mouseEnabled = false;
			textLabel.mouseWheelEnabled = false;
			textLabel.width = 350;
			textLabel.height = textLabel.textHeight + 4;
			
			//var y1:int = titleLabel.y + titleLabel.height;
			//var y2:int = bottomContainer.y;
			if (textLabel.length < 20)
			{
				textLabel.y = (settings.height - textLabel.height)/2/* + settings.textPaddingY + 10*/;
				textLabel.x = settings.width - textLabel.width - 30 + settings.textPaddingX + 30;
			}else {
				textLabel.y = (settings.height - textLabel.height)/2/* + settings.textPaddingY + 10*/;
				textLabel.x = settings.width - textLabel.width - 30 + settings.textPaddingX + 65;
			}
			
			drawMirrowObjs('diamondsTop', settings.width / 2 - settings.titleWidth / 2 - 5 + 40, settings.width / 2 + settings.titleWidth / 2 + 45, settings.titleHeight/2 + titleLabel.y + 5, true, true, true);
			drawImage();
			bodyContainer.addChild(textLabel);
			
			
			
			
			drawBttns();
			
		}
		
		private function drawImage():void 
		{
			if (settings.image == null) return;
			
			bitmapLabel = new Bitmap();
			bitmapLabel.bitmapData = settings.image;
			bitmapLabel.smoothing = true;
			bodyContainer.addChild(bitmapLabel);
			//bitmapLabel.x = settings.imageX - 25;
			bitmapLabel.x = back.x - bitmapLabel.width/2 - 35;
			//bitmapLabel.y = settings.imageY + 35;
			bitmapLabel.y = back.y - 30;
			bitmapLabel.scaleX = bitmapLabel.scaleY = settings.imageScale;
		}
		
		public var OkBttn:Button;
		public var UpgradeBttn:Button;
		public function drawBttns():void 
		{
			if (settings.hasButtons)
			{
				OkBttn = new Button( {
					caption:settings.buttonText,
					fontSize:32,
					width:180,
					hasDotes:false,
					height:46
				});
				OkBttn.addEventListener(MouseEvent.CLICK, onOkBttn);
			
				bottomContainer.addChild(OkBttn);
				OkBttn.x = settings.width / 2 - OkBttn.width / 2 + 40;
				
			}
			
			if (settings.hasStorageBtn)
			{
				UpgradeBttn = new Button( {
					caption:settings.storageBtnText,
					fontSize:32,
					width:180,
					hasDotes:false,
					height:46
				});
				UpgradeBttn.addEventListener(MouseEvent.CLICK, function():void {
						if (settings.onStorage != null)
							settings.onStorage();
						//new StockWindow({isStock:true}).show();
						close();
					});
			
				bottomContainer.addChild(UpgradeBttn);
				UpgradeBttn.x = OkBttn.x + OkBttn.width/2 + 10;
				OkBttn.x -= OkBttn.width/2 + 10;
			}
			
			bottomContainer.y = settings.height - bottomContainer.height/2 - 18 + settings.bttnPaddingY + 5;
			bottomContainer.x = 0;
		}
		
		public function onOkBttn(e:MouseEvent):void {
			if (settings.ok is Function) {
				settings.ok();
			}
			if(settings.closeAfterOk)
				close();
		}
		
		override public function dispose():void {
			if(OkBttn != null){
				OkBttn.removeEventListener(MouseEvent.CLICK, onOkBttn);
			}
			super.dispose();
		}
		
	}

}