package wins.actions 
{
	import buttons.Button;
	import core.Load;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import ui.UserInterface;
	import wins.AddWindow;
	import wins.Window;
	import wins.SimpleWindow;
	
	public class SpecialActionWindow extends AddWindow 
	{
		private var desriptionTexts:Object = {
			'113':{text1:'flash:1433426575880', text2:'flash:1433426613742'},
			'114':{text1:'flash:1433426680206', text2:'flash:1433426751422'},
			'115':{text1:'flash:1433427277654', text2:'flash:1433427297494'},
			'116':{text1:'flash:1433419652057', text2:'flash:1433419691881'},
			'119':{text1:'flash:1434096407816', text2:'flash:1434096431430'},
			'120':{text1:'flash:1434096407816', text2:'flash:1434096431430'},
			'159':{text1:'flash:1434957860631', text2:'flash:1434957907032'},
			'347':{text1:'flash:1439205567295', text2:'flash:1439205723810'},
			'669':{text1:'flash:1443692080196', text2:'flash:1443692095042'},
			'920':{text1:'flash:1433426575880', text2:'flash:1433426613742'}
		}
		
		private var titleTexts:Object = {
			'113':'flash:1434631636393',
			'114':'flash:1434631659289',
			'115':'flash:1434631682313',
			'116':'flash:1434631702607',
			'119':'flash:1434631723152',
			'120':'flash:1434631744848',
			'159':'flash:1434957840533',
			'347':'flash:1439205844577',
			'669':'storage:845:title',
			'920':'flash:1434631636393'
		}
		
		public function SpecialActionWindow(settings:Object=null) 
		{
			if (settings == null) {
				settings = new Object();
			}
			
			settings['width'] = 570;
			settings['height'] = 340;
			
			changePromo(settings['pID']);
						
			settings['title'] = Locale.__e(titleTexts[action.id]);
			settings['hasPaginator'] = false;
			settings['hasButtons'] = false;
			settings['fontColor'] = 0xffcc00;
			settings['fontSize'] = 48;
			settings['fontBorderColor'] = 0x705535;
			settings['shadowBorderColor'] = 0x342411;
			settings['fontBorderSize'] = 8;
			settings['promoPanel'] = true;
			
			super(settings);
		}
		 
		override public function drawBody():void {
			titleLabel.x += 5;
			titleLabel.y += 100;
			var sp:Sprite = new Sprite();
			var label:Bitmap = new Bitmap(UserInterface.textures.saleLabelBank);
			label.smoothing = true;
			var txtSize:int = 28;
			//do {
			var textAction:TextField = Window.drawText(Locale.__e('flash:1396521604876'), {
				color: 0xffffff,
				borderColor: 0x765134,
				fontSize: 28
			});
			textAction.width = textAction.textWidth + 5;
			textAction.x = (label.width - textAction.textWidth) / 2;
			textAction.y = (label.height - textAction.textHeight) / 2;
			sp.rotation = -30;
			sp.x -= 40;
			
			sp.addChild(label);
			sp.addChild(textAction);
			bodyContainer.addChild(sp);
			
			drawImage();
			drawDescription();
			drawButton2();
			
			this.y += 50;
			fader.y -= 50;
		}
		
		private function drawImage():void {
			var image:Bitmap = new Bitmap();
			var url:String = Config.getImage('sales/image', action.pID);
			
			Load.loading(url, function(data:*):void {
				image.bitmapData = data.bitmapData;
				image.x = (settings.width - image.width) / 2;
				image.y = titleLabel.y - image.height;
				
				bodyContainer.addChild(image);
			});
		}
		
		private function drawDescription():void {
			var separator:Bitmap = Window.backingShort(titleLabel.width - 20, 'dividerLine', false);
			separator.x = titleLabel.x + 10;
			separator.y = titleLabel.y + 35;
			separator.alpha = 0.7;
			bodyContainer.addChild(separator);
			
			var separator2:Bitmap = Window.backingShort(titleLabel.width - 20, 'dividerLine', false);
			separator2.x = titleLabel.x + 10;
			separator2.y = titleLabel.y + titleLabel.height + 70;
			separator2.alpha = 0.7;
			bodyContainer.addChild(separator2);
			
			var progressBacking:Bitmap = Window.backing(400, 80, 50, "fadeOutWhite");
			progressBacking.x = (settings.width - progressBacking.width) / 2;
			progressBacking.y = separator.y + separator.height + 3;
			progressBacking.alpha = 0.3;
			bodyContainer.addChild(progressBacking);
			
			var txt:String = '';
			for (var item:* in desriptionTexts) {
				if (item == action.pID) {
					var texts:Object = desriptionTexts[item];
					txt += ' - ' + Locale.__e(texts.text1) + '\n - ' + Locale.__e(texts.text2);
				}
			}
			
			var font:int = 26;
			if (settings.pID == 347) font = 24;
			var descText:TextField = Window.drawText(txt, {
				color				:0x542d0a,
				border				:false,
				fontSize			:font,
				autoSize			:"center",
				textAlign			:"left",
				multiline  			:true,
				wrap				:true,
				width				:400,
				textLeading			:3
			});
			descText.x = (settings.width - descText.textWidth) / 2;
			descText.y = separator.y + separator.height + 7;
			bodyContainer.addChild(descText);
			
			var sumText:TextField = Window.drawText(Locale.__e('flash:1408441188465'), {
				color				:0x542d0a,
				border				:false,
				fontSize			:24,
				autoSize			:"center",
				textAlign			:"left"
			});
			sumText.x = (settings.width - sumText.textWidth) / 2;
			sumText.y = separator2.y + 15;
			bodyContainer.addChild(sumText);
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
		}
		
		public function changePromo(pID:String):void {
			action = App.data.actions[pID];
			action.id = pID;
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