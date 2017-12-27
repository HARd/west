package wins.actions 
{
	import buttons.Button;
	import core.Load;
	import flash.display.Bitmap;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import ui.UserInterface;
	import wins.AddWindow;
	import wins.Window;
	import wins.SimpleWindow;
	
	public class UniqueActionWindow extends AddWindow 
	{
		public function UniqueActionWindow(settings:Object=null) 
		{
			if (settings == null) {
				settings = new Object();
			}
			
			settings['width'] = 600;
			settings['height'] = 430;
			
			initAction(settings);
			
			settings['title'] = Locale.__e(App.data.storage[itemSID].title);
			settings['hasPaginator'] = false;
			settings['hasButtons'] = false;
			settings['fontSize'] = 48;
			settings['fontBorderSize'] = 8;
			settings['promoPanel'] = true;
			
			super(settings);
			
			trace();
		}
		
		override public function drawBody():void {
			titleLabel.x += 60;
			
			var glowShine:Bitmap = new Bitmap(Window.textures.glow, 'auto', true);
			glowShine.x = -50;
			glowShine.y = -70;
			bodyContainer.addChild(glowShine);
			
			var pic:Bitmap = new Bitmap();
			bodyContainer.addChild(pic);
			
			var stripe:Bitmap = Window.backingShort(settings.width + 260, 'ribbonYellow');
			stripe.scaleX = 0.8;
			stripe.x = (settings.width - stripe.width) / 2;
			stripe.y = 220;
			bodyContainer.addChild(stripe);
			
			var stripeText:TextField = Window.drawText(Locale.__e('flash:1456154780412'), {
				color				:0xffffff,
				borderColor			:0x542d0a,
				fontSize			:32,
				//autoSize			:"center",
				textAlign			:"center",
				width				:settings.width
			});
			stripeText.y = stripe.y + (stripe.height - stripeText.textHeight) / 3;
			bodyContainer.addChild(stripeText);
			var picture:String = 'SaleSafePic';
			if (action.pID == 1895) picture = 'w_bs_house01';
			Load.loading(Config.getImage('content', picture), function(data:*):void {
				pic.bitmapData = data.bitmapData;
				
				if (action.pID == 1895) {
					pic.x -= 100;
					pic.y = -160;
				}else {
					pic.y = -40;
				}
			});
			
			drawDescription();
			drawButton2();
		}
		
		private function drawDescription():void {
			var descWidth:int = 250;
			var separator:Bitmap = Window.backingShort(descWidth, 'dividerLine', false);
			separator.x = settings.width / 2 - 20;
			separator.y = titleLabel.y + 55;
			separator.alpha = 0.7;
			bodyContainer.addChild(separator);
			
			var separator2:Bitmap = Window.backingShort(descWidth, 'dividerLine', false);
			separator2.x = settings.width / 2 - 20;
			separator2.y = separator.y + separator.height + 160;
			separator2.alpha = 0.7;
			bodyContainer.addChild(separator2);
			
			var progressBacking:Bitmap = Window.backing(descWidth, 160, 50, "fadeOutWhite");
			progressBacking.x = settings.width / 2 - 20;
			progressBacking.y = separator.y + separator.height + 3;
			progressBacking.alpha = 0.3;
			bodyContainer.addChild(progressBacking);
			
			var descText:TextField = Window.drawText(App.data.storage[itemSID].description, {
				color				:0x542d0a,
				border				:false,
				fontSize			:24,
				autoSize			:"center",
				textAlign			:"left",
				multiline  			:true,
				wrap				:true,
				width				:descWidth + 50,
				textLeading			:3
			});
			descText.x = separator.x + (separator.width - descText.textWidth) / 2;
			descText.y = separator.y + separator.height + 7;
			bodyContainer.addChild(descText);
		}
		
		private function drawButton2():void
		{
			var bttnSettings:Object = {
				fontSize:30,
				width:194,
				height:53
			};
			
			if (priceBttn != null)
				bodyContainer.removeChild(priceBttn);
			
			bttnSettings['caption'] = Payments.price(action.price[App.social]);
			
			priceBttn = new Button(bttnSettings);
			priceBttn.x = (settings.width - priceBttn.width) / 2;
			priceBttn.y = settings.height - priceBttn.height - 35;
			bodyContainer.addChild(priceBttn);
			priceBttn.addEventListener(MouseEvent.CLICK, buyEvent);
			
			if (App.isSocial('MX')) {
				var mxLogo:Bitmap = new Bitmap(UserInterface.textures.mixieLogo);
				mxLogo.scaleX = mxLogo.scaleY = 0.8;
				priceBttn.addChild(mxLogo);
				mxLogo.y = priceBttn.textLabel.y - (mxLogo.height - priceBttn.textLabel.height)/2;
				mxLogo.x = priceBttn.textLabel.x-10;
				priceBttn.textLabel.x = mxLogo.x + mxLogo.width + 5;
			}
			if (App.isSocial('SP')) {
				var spLogo:Bitmap = new Bitmap(UserInterface.textures.fantsIcon);
				priceBttn.addChild(spLogo);
				spLogo.y = priceBttn.textLabel.y - (spLogo.height - priceBttn.textLabel.height)/2;
				spLogo.x = priceBttn.textLabel.x-10;
				priceBttn.textLabel.x = spLogo.x + spLogo.width + 5;
			}
			
			/*var sumText:TextField = Window.drawText(Locale.__e('flash:1408441188465'), {
				color				:0x542d0a,
				border				:false,
				fontSize			:24,
				autoSize			:"center",
				textAlign			:"left"
			});
			sumText.x = (settings.width - sumText.textWidth) / 2;
			sumText.y = priceBttn.y - 25;
			bodyContainer.addChild(sumText);*/
		}
		
		override public function getIconUrl(promo:Object):String {
			if (promo.hasOwnProperty('iorder')) {
				var _items:Array = [];
				for (var sID:* in promo.items) {
					_items.push( { sID:sID, order:promo.iorder[sID] } );
				}
				_items.sortOn('order');
				sID = _items[0].sID;
			}else {
				sID = promo.items[0].sID;
			}
			
			return Config.getIcon(App.data.storage[sID].type, App.data.storage[sID].preview);
		}
	}

}