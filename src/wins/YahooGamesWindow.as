package wins 
{
	
	import buttons.Button;
	import buttons.ImageButton;
	import core.Load;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.net.navigateToURL;
	import flash.net.URLRequest;
	import flash.text.TextField;
	/**
	 * ...
	 * @author ...
	 */
	
	public class YahooGamesWindow extends Window
	{
		
		public function YahooGamesWindow() 
		{
			if (settings == null) {
				settings = new Object();
			}
			
			settings['width'] = 240;
			settings['height'] = 224;
			//settings['background'] = 'achievementUnlockBacking';
			settings['hasPaginator'] = false;
			settings['title'] = '';
		
			super(settings);
			_drawBody()
		}
		
		override public function drawBody():void 
		{
		}
		
		public function _drawBody():void 
		{
			var _window:Bitmap = new Bitmap();
			bodyContainer.addChild(_window);
			Load.loading(Config.getImage('content', 'Win_Yhoo'), function(data:*):void {
							_window.bitmapData = data.bitmapData;
							
							_window.x =( settings.width - _window.width )/2;
							_window.y = (settings.height - _window.height) / 2-10;
							_drawLogo()
						})
		}
		
		private function _drawLogo():void 
		{
			var _logo:Bitmap = new Bitmap();
			bodyContainer.addChild(_logo);
			Load.loading(Config.getImage('content', 'Logo_Yahoo'), function(data:*):void {
						_logo.bitmapData = data.bitmapData;
						//_logo.scaleX = _logo.scaleY = 0.5;
						//_logo.smoothing = true;
						_logo.x =( settings.width - _logo.width )/2;
						_logo.y =-270;
						_drawBttn()
					})
		}
		
		private function _drawBttn():void 
		{
			//var _bttn:Bitmap = new Bitmap();
			////addChild(bttn);
			//Load.loading(Config.getImage('content', 'BttnFB_yahoo'), function(data:*):void {
						//_bttn.bitmapData = data.bitmapData;
						////_bttn.x =( settings.width - _bttn.width )/2;
						////_bttn.y += 90;
						////_bttn.addEventListener(MouseEvent.CLICK,onClick);
						//var bttn:ImageButton = new ImageButton(data.bitmapData);
						//bodyContainer.addChild(bttn);
						//bttn.x =( settings.width - bttn.width )/2;
						//bttn.y += 65;
						//bttn.addEventListener(MouseEvent.CLICK,onClick);
					//});
			//
			//this.show();
			//
			//var descTitle:TextField = Window.drawText('Dear player, \n \n We regret to inform you, that Yahoo Games site is being shut down on May 13th, 2016 \n Until that time you can keep playing GOLDEN FRONTIER here or enjoy your favourite game on Facebook. \n \n Play now on Facebook and get guaranteed gifts!', {
				//autoSize:'none',
				////fontFamily :'fontArial',
				//fontSize:22,
				//color:0x624512,
				//textAlign:"left",
				//multiline			: false,	
				//wrap:true,
				//width:400,
				////height:300,
				////borderColor:0x3e2a26
				//border: false
			//});
			//descTitle.x = -65;
			//descTitle.y = -140;
			//bodyContainer.addChild(descTitle);
			
			var goBttn:Button = new Button( {
				caption:'Install the app on Facebook',
				fontSize:28,
				bevelColor: [0x4f7fc3,0x395b9c],
				bgColor: [0x4f7fc3, 0x395b9c],
				width:200
			});
			goBttn.x = (settings.width - goBttn.width) / 2;
			goBttn.y += 65;
			bodyContainer.addChild(goBttn);
			goBttn.addEventListener(MouseEvent.CLICK, onClick);
			
			/*var giftBttn:Button = new Button( {
				caption:'Get your bonus!',
				fontSize:28
			});
			giftBttn.x = goBttn.x + goBttn.width + 10;
			giftBttn.y += 65;
			bodyContainer.addChild(giftBttn);
			giftBttn.addEventListener(MouseEvent.CLICK, onClickGift);*/
			
			this.show();
			
			var descTitle:TextField = Window.drawText('Dear player, \n \n We regret to inform you, that Yahoo Games site is being shut down on May 13th, 2016 \n Until that time you can keep playing GOLDEN FRONTIER here or enjoy your favourite game on Facebook.', {
				autoSize:'none',
				//fontFamily :'fontArial',
				fontSize:22,
				color:0x624512,
				textAlign:"left",
				multiline			: false,	
				wrap:true,
				width:400,
				//height:300,
				//borderColor:0x3e2a26
				border: false
			});
			descTitle.x = -65;
			descTitle.y = -140;
			bodyContainer.addChild(descTitle);
		}
		
		private function onClick(e:MouseEvent):void {
			//navigateToURL(new URLRequest('https://apps.facebook.com/goldenfrontier/'));
			//close();
			//navigateToURL(new URLRequest('https://apps.facebook.com/goldenfrontier/'));
			new SimpleWindow( {
				popup:true,
				dialog:true,
				height:350,
				text:'Whether you already have a Facebook account or not, your in-game progress will be replaced or transferred from Yahoo Games site.',
				title:'Important!',
				confirm:function():void {
					var url:String = 'https://apps.facebook.com/goldenfrontier/?eref=viral' + App.user.id + 'z';
					navigateToURL(new URLRequest(url));
				},
				cancel:function():void {
					Window.closeAll();
				}
			}).show();
		}
		
		private function onClickGift(e:MouseEvent):void {
			//navigateToURL(new URLRequest('https://apps.facebook.com/goldenfrontier/'));
			close();
			navigateToURL(new URLRequest('https://apps.facebook.com/goldenfrontier/?ref=bonusb56e2e8a7b835az'));
		}
		
		public static function  ShowYahooGamesWindow():void
		{
			new YahooGamesWindow();
		}
	
		override public function drawTitle():void 
		{
		}
		
	
		
		override public function drawExit():void {
			exit = new ImageButton(textures.closeBttn);
			headerContainer.addChild(exit);
			exit.x = settings.width + 145;
			exit.y =-175;
			exit.addEventListener(MouseEvent.MOUSE_DOWN, close);
		}
		
	}

}