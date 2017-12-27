package wins 
{
	import buttons.Button;
	import core.Load;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.text.TextField;
	import ui.BitmapLoader;
	
	public class MinigameRewardWindow extends Window 
	{
		
		private var buyBttn:Button;
		public var character:Bitmap = new Bitmap();
		private var preloader:Preloader = new Preloader();	
		
		public function MinigameRewardWindow(settings:Object=null) 
		{
			
			settings['width'] = settings['width'] || 600;
			settings['height'] = settings['height'] || 390;
			settings['hasPaginator'] = settings['hasPaginator'] || false;
			settings['hasButtons'] = settings['hasButtons'] || false;
			settings['description'] = settings['description'] || 'No description';
			settings['popup'] = settings['popup'] || true;
			settings['price'] = settings['price'] || 999;
			settings['callback'] = settings['callback'];
			
			super(settings);
			
		}
		
		/*override public function drawFader():void {
			super.drawFader();
			layer.swapChildren(bodyContainer, headerContainer);
		}*/
		
		override public function drawBody():void {
			var back:Bitmap = backing(280, 260, 50, 'itemBacking');
			back.x = settings.width - back.width - 55;
			back.y = settings.height * 0.5 - back.height * 0.5 - 35;
			bodyContainer.addChild(back);
			
			var bitmap:BitmapLoader = new BitmapLoader(settings.link, 280, 280);
			bitmap.x = 15;
			bitmap.y = settings.height * 0.5 - bitmap.height * 0.5 - 35;
			bodyContainer.addChild(bitmap);
			
			bodyContainer.addChild(preloader);
			preloader.x = 38;
			preloader.y = 84;
			
			Load.loading(Config.getImage('content','CharPirate'), function(data:*):void { 
				bodyContainer.removeChild(preloader);
				
				character.bitmapData = data.bitmapData;
				character.x = -(character.width / 4) * 3 + 50;
				character.y = -170;
				bodyContainer.addChild(character);
			});		
			
			
			// Text
			var textCont:Sprite = new Sprite();
			bodyContainer.addChild(textCont);
			
			var titleLabel:TextField = drawText(settings.rewardTitle, {
				width:			back.width * 0.8,
				color:			0xffe455,
				borderColor:	0x622400,
				textAlign:		'center',
				fontSize:		28,
				filters: 		[new DropShadowFilter(1.5, 90, 0x622400, 1, 0, 0, 1, 1)]
			});
			textCont.addChild(titleLabel);
			
			var textLabel:TextField = drawText(settings.description, {
				width:			back.width * 0.8,
				color:			0xfff5ff,
				borderColor:	0x5e452f,
				textAlign:		'center',
				fontSize:		22,
				multiline:		true,
				wrap:			true
			});
			textLabel.y = titleLabel.y + titleLabel.height + 12;
			textCont.addChild(textLabel);
			
			textCont.x = back.x + back.width * 0.5 - textCont.width * 0.5;
			textCont.y = back.y + back.height * 0.5 - textCont.height * 0.5;
			
			
			buyBttn = new Button( {
				width:		160,
				height:		46,
				caption:	settings.price
			});
			buyBttn.x = settings.width * 0.5 - buyBttn.width * 0.5;
			buyBttn.y = settings.height - 100;
			buyBttn.textLabel.x += 20;
			buyBttn.textLabel.y += 2;
			buyBttn.addEventListener(MouseEvent.CLICK, onBuyEvent);
			bodyContainer.addChild(buyBttn);
			
			var currencyIcon:BitmapLoader = new BitmapLoader(settings.target.currency, 32, 32);
			currencyIcon.x = 40;
			currencyIcon.y = 8;
			buyBttn.addChild(currencyIcon);
			
			if (settings.target.tutorial) {
				buyBttn.showGlowing();
				//buyBttn.showPointing('bottom', buyBttn.x + buyBttn.width * 0.5 + 15, 20, bodyContainer);
			}
		}
		
		private function onBuyEvent(e:MouseEvent):void {
			if (!settings.target.checkVerify('confirm'))
				return;
			
			if (settings.callback != null && settings.callback is Function)
				settings.callback();
			
			close();
		}
		
		override public function dispose():void {
			super.dispose();
			
			buyBttn.removeEventListener(MouseEvent.CLICK, onBuyEvent);
			buyBttn.dispose();
			buyBttn = null;
		}
		
	}

}