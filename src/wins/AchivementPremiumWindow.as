package wins 
{
	import buttons.Button;
	import flash.display.Bitmap;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	/**
	 * ...
	 * @author ...
	 */
	public class AchivementPremiumWindow extends Window
	{
		public var textLabel:TextField = null;
		private var bitmapLabel:Bitmap = null;
		private var back:Bitmap;
		
		public function AchivementPremiumWindow(settings:Object = null) 
		{
			if (settings == null) {
				settings = new Object();
			}
			
			settings['hasTitle']		= settings.hasTitle || false;
			settings["title"] 			= Locale.__e('flash:1382952379735');;
			settings['text'] 			= settings.text || '';
			settings['textAlign'] 		= settings.textAlign || 'center';
			settings['autoSize'] 		= settings.autoSize || 'center';
			settings['textSize'] 		= settings.textSize || 24;
			settings['padding'] 		= settings.padding || 20;
			settings['faderAsClose']	= settings.faderAsClose || false;
			settings['faderClickable']	= settings.faderClickable || false;
			settings['closeAfterOk']	= settings.closeAfterOk || false;
			settings['escExit']			= false;
			settings['popup']			= settings.popup || true;
			settings['forcedClosing']	= settings.forcedClosing || false;
			settings['hasButtons']		= settings['hasButtons'] == null ? true : settings['hasButtons'];
			settings['buttonText']		= settings['buttonText'] || Locale.__e('flash:1382952380298');
			settings['ok']				= settings.ok || null;
			settings["width"]			= settings.width || 481;
			settings["height"] 			= settings.height || 207;
			settings["hasPaginator"] 	= false;
			settings["hasArrows"]		= false;
			settings["hasTitle"]		= true;
			settings["hasExit"]			= settings.hasExit || false;
			settings["image"]	 		= settings.image || null;
			settings["imageX"]	 		= settings.imageX || 0;
			settings["imageY"]	 		= settings.imageY || 0;
			settings["imageScale"]	 	= settings.imageScale || 1;
			settings["textPaddingY"]	= settings.textPaddingY || 0;
			settings["textPaddingX"]	= settings.textPaddingX || 0;
			settings["bttnPaddingY"]	= settings.bttnPaddingY || 0;
			
			if (settings.isPopup)
				settings['popup'] = true;
			if (!settings.hasOwnProperty("closeAfterOk"))
				settings["closeAfterOk"] = true;
			
			super(settings);
		}
		
		override public function drawBackground():void 
		{
			
		}
		
		override public function drawTitle():void 
		{
			titleLabel = titleText( {
				title				: settings.title,                               
				color				: settings.fontColor,
				borderColor 		: 0xaa6ed2,	
				multiline			: true,			
				fontSize			: settings.fontSize,				
				textLeading	 		: settings.textLeading,					
				borderSize 			: settings.fontBorderSize,	
				shadowBorderColor	: settings.shadowBorderColor || settings.fontColor,
				width				: settings.width - 80,
				textAlign			: 'center',
				sharpness 			: 50,
				thickness			: 50,
				border				: true
			})
			
			titleLabel.x = (settings.width - titleLabel.width) * .5;
			titleLabel.y = 25;
			var textFilter:GlowFilter = new GlowFilter(0x7a3cab, 1, 6, 6, 10, 1);
			titleLabel.filters = [textFilter];
			
			var descText:TextField = Window.drawText(Locale.__e("flash:1404212292872"), {
				color:0x65371b,
				borderColor:0xeed3a4,
				width:255,
				fontSize:28,
				wrap:true,
				multiline:true,	
				textAlign:"center",
				autoSize:"center"
			});
			descText.x = settings.width / 3 + 15;
			descText.y = (settings.height - descText.textHeight)/2;
			
			
			bodyContainer.addChild(titleLabel);
			bodyContainer.addChild(descText);
		}
		
		
		override public function drawBody():void 
		{
			if (exit)
			{
				exit.y += 0;
				exit.x += 55;
			}
			back = backing2(settings.width, settings.height, 45, "questsSmallBackingTopPiece", 'questsSmallBackingBottomPiece');	
			var ribbon:Bitmap = backingShort(back.width + 160, 'questRibbon');
			ribbon.y = -35;
			ribbon.x = (settings.width - ribbon.width) / 2;
			
			bodyContainer.addChildAt(ribbon,0);
			bodyContainer.addChildAt(back, 0);
			titleLabel.y -= 50;
			
			var icon:Bitmap = new Bitmap(Window.textures.achievementCup);
			bodyContainer.addChild(icon);
			icon.x = -25;
			icon.y = -5;
			
			drawBttns();
			
		}
		
		public var OkBttn:Button;
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
				OkBttn.x = settings.width / 2 - OkBttn.width / 2;
				
			}
			
			bottomContainer.y = settings.height - bottomContainer.height/2 - 18 + settings.bttnPaddingY + 5;
			bottomContainer.x = 0;
		}
		
		public function onOkBttn(e:MouseEvent):void {
			close();
			if(App.ui.bottomPanel.friendsPanel.opened == true)	App.ui.bottomPanel.hideFriendsPanel();
			//App.ui.bottomPanel.bttns[3].showPointing("top",-180,0,App.ui.bottomPanel.bttns[3], "", null, false);
		}
		
		override public function dispose():void {
			if(OkBttn != null){
				OkBttn.removeEventListener(MouseEvent.CLICK, onOkBttn);
			}
			super.dispose();
		}
		
	}

}