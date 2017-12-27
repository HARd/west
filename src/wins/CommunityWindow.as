package wins 
{
	import buttons.Button;
	import buttons.CheckboxButton;
	import core.Load;
	import flash.display.Bitmap;
	import flash.events.MouseEvent;
	import flash.net.navigateToURL;
	import flash.net.URLRequest;
	import flash.text.TextField;
	/**
	 * ...
	 * @author 
	 */
	public class CommunityWindow extends Window
	{
		public static var isShowed:Boolean = false;
		
		public var okBttn:Button;
		
		private var txtLabel:TextField;
		private var descLabel:TextField;
		
		private var checkBox:CheckboxButton

		
		public function CommunityWindow(settings:Object = null) 
		{
			if (settings == null) {
				settings = new Object();
			}
			
			settings['width'] = 445;
			settings['height'] = 363;
			
			settings['title'] = "";
			settings['hasButtons'] = false;
			settings['hasPaginator'] = false;
			
			super(settings);
			
			isShowed = true;
		}
		
		private var background:Bitmap;
		override public function drawBackground():void {
			background = backing(settings.width, settings.height, 45, "questBacking");
			//background = backing(445, 363, 45, "questBacking");
			layer.addChildAt(background, 0);
			
			var woodenDec:Bitmap = new Bitmap(Window.textures.storageWoodenDec);
			var woodenDec2:Bitmap = new Bitmap(Window.textures.storageWoodenDec);
			woodenDec.x = background.x;
			woodenDec2.x = background.x + background.width;
			woodenDec.scaleY = woodenDec2.scaleY = -1;
			woodenDec2.scaleX = -1;
			woodenDec.y = woodenDec2.y = background.y + 70;
			layer.addChild(woodenDec);
			layer.addChild(woodenDec2);
			
			
			//drawMirrowObjs('storageWoodenDec', -26, settings.width + 26, 55, false, false, false, 1, -1);
			
			
			var backImage:Bitmap = new Bitmap(Window.textures.communityEvent);
			layer.addChild(backImage);
			backImage.x = background.x + (background.width - backImage.width) / 2 - 65;
			backImage.y = background.y + (background.height - backImage.height) / 2 - 30;
		}
		
		//private var preloader:Preloader = new Preloader();
				
		override public function drawBody():void {
			exit.y -= 22;
			//exit.x = background.x;
			//exit.y = background.y;
			
			//bodyContainer.addChild(preloader);
			//preloader.x = settings.width/2;
			//preloader.y = 184;
			
			//var stars:Bitmap = new Bitmap(Window.textures.decorStars);
			//stars.y = settings.height - stars.height - 20;
			//stars.x = (settings.width - stars.width) / 2;
			//bodyContainer.addChild(stars);
			
			okBttn = new Button( {
				borderColor:			[0xfeee7b,0xb27a1a],
				fontColor:				0xffffff,
				fontBorderColor:		0x814f31,
				bgColor:				[0xf5d159, 0xedb130],
				width:162,
				height:50,
				fontSize:32,
				hasDotes:false,
				caption:Locale.__e("flash:1406302453974")
			});
			bodyContainer.addChild(okBttn);
			okBttn.addEventListener(MouseEvent.CLICK, onTakeEvent);
			
			
			var icon:Bitmap = new Bitmap();
			bodyContainer.addChild(icon);
			//Load.loading(Config.getImageIcon('comunity', 'comunity'), function(data:*):void {
				//icon.bitmapData = data.bitmapData;
				//icon.x = (settings.width - icon.width) / 2;
				//icon.y = 16;
			//});
			
			drawMessage();
			

			drawMirrowObjs('storageWoodenDec', -4, settings.width + 4, settings.height - 102);
			
			okBttn.x = (settings.width - okBttn.width)/2;
			okBttn.y = settings.height - okBttn.height - 24;
			
			
			checkBox = new CheckboxButton( { captionChecked:Locale.__e('flash:1406303043769'), captionUnchecked:Locale.__e('flash:1406303043769'), txtX:24, txtY:3 } );
			bodyContainer.addChild(checkBox);
			checkBox.x = (settings.width - checkBox.width) / 2 + 37;
			checkBox.y = okBttn.y - checkBox.height;
		}
		
		private function onTakeEvent(e:MouseEvent):void {
			if (checkBox.checked == CheckboxButton.CHECKED)
				onTellEvent(e);
			
			close();
		}
		
		private function onTellEvent(e:MouseEvent):void {
			App.user.storageStore('gw', 0, true);
			navigateToURL(new URLRequest(App.self.flashVars.group), "_blank");
			
			close();
		}
		
		
		private function drawMessage():void {
				descLabel = Window.drawText(Locale.__e('flash:1406298737129'), {
				fontSize:26,
				color:0xffe491, 
				borderColor:0x5a2f03,
				multiline:true,
				textAlign:"center"
			});
				
			descLabel.wordWrap = true;
			descLabel.width = 360;
			descLabel.height = descLabel.textHeight + 10;
			
			
			descLabel.y = settings.height - 180;
			descLabel.x = (settings.width - descLabel.width) / 2;
			
			bodyContainer.addChild(descLabel);
		}
		
		override public function dispose():void {
			okBttn.removeEventListener(MouseEvent.CLICK, close);
			
			super.dispose();
		}
		
	}

}
