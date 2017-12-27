package wins.actions 
{
	import api.ExternalApi;
	import buttons.Button;
	import core.Post;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import ui.UserInterface;
	import wins.SaleBoosterWindow;
	import wins.Window;
	import wins.SimpleWindow;
	/**
	 * ...
	 * @author ...
	 */
	public class SingleSaleWindow extends SaleBoosterWindow 
	{
		private var glowShine:Bitmap;
		private var sID:int;
		
		public function SingleSaleWindow(settings:Object) 
		{
			this.sID = settings.itemSID;
			if (sID == 920 || sID == 1038) {
				settings["height"] = 440;
			} else if (sID == 933) {
				settings["height"] = 440;
				settings["width"] = 530;
			} else {
				settings["height"] = 360;
			}
			super(settings);
		}
		override public function onLoadIcon(data:*):void {
			super.onLoadIcon(data);
			if (sID == 920)
				icon.y = 45;
			else if (sID == 933)
				icon.y = -45;
			else
				icon.y -= 50;
		}
		
		override public function drawBody():void
		{
			super.drawBody();
			titleField.text = action.text1;
			descLabel.text = action.text2;
			descLabel.wordWrap = true;
			descLabel.height  = descLabel.textHeight + 200;
			descLabel.y -= 90;
			bodyContainer.removeChild(checkBack);
			stripe.y += 70;
			titleField.y += 70;
			diamondsCont.y += 75;
			icon.y -= 100;
			glowShine = new Bitmap(Window.textures.glowShine, 'auto', true);
			glowShine.scaleX = glowShine.scaleY = 0.8;
			glowShine.x = (settings.width - glowShine.width) / 2;
			glowShine.y = -93;
			bodyContainer.addChild(glowShine);
			
			bodyContainer.addChild(icon);
			if (sID == 920 || sID == 1038) {
				glowShine.visible = false;				
				var glow:Bitmap = new Bitmap(Window.textures.glow, 'auto', true);
				glow.scaleX = glow.scaleY = 0.8;
				glow.x = (settings.width - glow.width) / 2;
				glow.y = 0;
				bodyContainer.addChild(glow);
				
				bodyContainer.addChild(icon);
				
				bodyContainer.addChild(stripe);
				bodyContainer.addChild(titleField);
				bodyContainer.addChild(diamondsCont);
				
				descLabel.text = Locale.__e('flash:1408441188465');
				descLabel.textColor = 0xffffff;
				descLabel.y = 350;
				bodyContainer.addChild(descLabel);
				
				stripe.y = 250;
				titleField.y = 270;
				diamondsCont.y = 260;
				
				if (sID == 1038) {
					icon.y += 50;
				}
				
				drawAddons();
			}
			
			if (sID == 933) {
				glowShine.visible = false;				
				var glow2:Bitmap = new Bitmap(Window.textures.glow, 'auto', true);
				glow2.scaleX = glow2.scaleY = 0.8;
				glow2.x = (settings.width - glow2.width) / 2;
				glow2.y = 0;
				bodyContainer.addChild(glow2);
				
				bodyContainer.addChild(icon);
				
				bodyContainer.addChild(stripe);
				bodyContainer.addChild(titleField);
				diamondsCont.visible = false;
				
				descLabel.text = Locale.__e('flash:1408441188465');
				descLabel.textColor = 0xffffff;
				descLabel.y = 350;
				bodyContainer.addChild(descLabel);
				
				stripe.y = 250;
				titleField.y = 290;
				diamondsCont.y = 260;
				
				exit.x -= 40;
				exit.y += 10;
				
				icon.y += 100;
			}
			
			/*if (sID == 1038) {
				glowShine.visible = false;				
				var glow3:Bitmap = new Bitmap(Window.textures.glow, 'auto', true);
				glow3.scaleX = glow3.scaleY = 0.8;
				glow3.x = (settings.width - glow3.width) / 2;
				glow3.y = 0;
				bodyContainer.addChild(glow3);
				
				bodyContainer.addChild(icon);
				
				bodyContainer.addChild(stripe);
				bodyContainer.addChild(titleField);
				bodyContainer.addChild(diamondsCont);
				
				descLabel.text = Locale.__e('flash:1408441188465');
				descLabel.textColor = 0xffffff;
				descLabel.y = 270;
				bodyContainer.addChild(descLabel);
				
				exit.x -= 40;
				exit.y += 10;
				
				stripe.y = 170;
				titleField.y = 190;
				diamondsCont.y = 180;
				icon.y += 50;
				
				drawAddons();
			}*/
		}
		
		override protected function drawText1Title():void {
			if (sID == 933) {
				var text1:String = (texts.hasOwnProperty(action.id)) ? texts[action.id]['0'] : '';
				titleField = drawText(Locale.__e(text1), {
					color				: 0xfbd23c,
					fontSize			: 26,
					border				: true,
					borderColor 		: 0x603815,			
					borderSize 			: 4,	
					shadowColor			: 0x503f33,
					shadowSize			: 2,
					width				: settings.width - 50,
					textAlign			: 'center',
					sharpness 			: 50,
					thickness			: 50,
					multiline			: true
				});
				titleField.wordWrap = true;
				titleField.x = stripe.x + (stripe.width - titleField.width) / 2;
				titleField.y = stripe.y + (stripe.height - titleField.height) / 2 ;
				bodyContainer.addChild(titleField);
			} else {
				super.drawText1Title();
			}
		}
		
		private function drawAddons():void {
			var text1:String = Locale.__e('flash:1445520672616');
			var text2:String = Locale.__e('flash:1445520063519');
			var text3:String = Locale.__e('flash:1445520933460');
			
			if (sID == 1038) {
				text1 = Locale.__e('flash:1446117936441');
				text2 = Locale.__e('flash:1446117949239');
				text3 = Locale.__e('flash:1446117960007');
			}
			var sp1:Sprite = new Sprite();
			var label:Bitmap = new Bitmap(UserInterface.textures.saleLabelBank);
			label.smoothing = true;
			var textAction:TextField = Window.drawText(text1, {
				color: 0xffffff,
				borderColor: 0x765134,
				fontSize: 24,
				autoSize: 'center',
				textAlign: 'center',
				multiline: true
			});
			textAction.width = label.width;
			textAction.wordWrap = true;
			textAction.x = (label.width - textAction.textWidth) / 2 - label.width / 4;
			textAction.y = (label.height - textAction.textHeight) / 2;
			sp1.rotation = -10;
			sp1.x -= 20;
			sp1.y = 180;
			
			sp1.addChild(label);
			sp1.addChild(textAction);
			bodyContainer.addChild(sp1);
			
			var sp2:Sprite = new Sprite();
			var label2:Bitmap = new Bitmap(UserInterface.textures.saleLabelBank);
			label2.smoothing = true;
			var textAction2:TextField = Window.drawText(text2, {
				color: 0xffffff,
				borderColor: 0x765134,
				fontSize: 24,
				autoSize: 'center',
				textAlign: 'center',
				multiline: true
			});
			textAction2.width = label.width;
			textAction2.wordWrap = true;
			textAction2.x = (label2.width - textAction2.textWidth) / 2;
			textAction2.y = (label2.height - textAction2.textHeight) / 2;
			sp2.x -= 20;
			sp2.y = 0;
			
			sp2.addChild(label2);
			sp2.addChild(textAction2);
			bodyContainer.addChild(sp2);
			
			var sp3:Sprite = new Sprite();
			var label3:Bitmap = new Bitmap(UserInterface.textures.saleLabelBank);
			label3.smoothing = true;
			var textAction3:TextField = Window.drawText(text3, {
				color: 0xffffff,
				borderColor: 0x765134,
				fontSize: 24,
				autoSize: 'center',
				textAlign: 'center',
				multiline: true
			});
			textAction3.width = label.width;
			textAction3.wordWrap = true;
			textAction3.x = (label3.width - textAction3.textWidth) / 2;
			textAction3.y = (label3.height - textAction3.textHeight) / 2;
			sp3.rotation = 20;
			sp3.x = settings.width - label3.width + 20;
			sp3.y = 140;
			
			sp3.addChild(label3);
			sp3.addChild(textAction3);
			bodyContainer.addChild(sp3);
		}
		
		override public function drawBttn():void {
			var bttnSettings:Object = {
				fontSize:36,
				width:220,
				height:58
			};
			
			if (priceBttn != null)
				bodyContainer.removeChild(priceBttn);
			
			bttnSettings['caption'] = Payments.price(action.price[App.social]);
			priceBttn = new Button(bttnSettings);
			priceBttn.x = (settings.width - priceBttn.width) / 2;
			priceBttn.y = (settings.height - 60);
			bodyContainer.addChild(priceBttn);
			
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
			
			priceBttn.addEventListener(MouseEvent.CLICK, buyEvent);
		}
		
		override protected function getIconLink():String {
			if (sID == 933) {
				return Config.getImageIcon('promo/images', 'PyramidHeader');
			}
			
			if (sID == 1038) {
				return Config.getImageIcon('promo/images', 'bull');
			}
			
			return Config.getIcon(App.data.storage[sID].type, App.data.storage[sID].preview);
		}
		
		public function getIconUrl(promo:Object):String {
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
			
			if (sID == 933) return Config.getIcon('promo/images', 'PyramidHeader');
			
			return Config.getIcon(App.data.storage[sID].type, App.data.storage[sID].preview);
		}
		
	}

}