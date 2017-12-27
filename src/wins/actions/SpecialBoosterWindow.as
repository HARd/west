package wins.actions 
{
	import buttons.Button;
	import core.Load;
	import flash.display.Bitmap;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import ui.UserInterface;
	import wins.Window;
	
	public class SpecialBoosterWindow extends Window 
	{
		private var action:Object = { };
		private var priceBttn:Button;
		public function SpecialBoosterWindow(settings:Object=null) 
		{
			settings["hasTitle"] = false;
			settings["title"] = Locale.__e('flash:1382952379793');
			settings["width"] = settings.width || 520;
			settings["height"] = settings.height || 430;
			settings["hasPaginator"] = false;
			settings["background"] = 'alertBacking';
			
			action = App.data.actions[settings.pID];
			action['id'] = settings.pID;
			
			super(settings);
		}
		
		override public function drawBody():void {
			var stripe:Bitmap = Window.backingShort(settings.width + 170, 'ribbonYellow');
			stripe.scaleX = 0.8;
			stripe.x = (settings.width - stripe.width) / 2;
			stripe.y = 10;
			
			var pic:Bitmap = new Bitmap();
			bodyContainer.addChild(pic);
			bodyContainer.addChild(stripe);
			Load.loading(Config.getImage('content', 'SaleBoosterPic', 'jpg'), function(data:*):void {
				pic.bitmapData = data.bitmapData;
				pic.x = (settings.width - pic.width) / 2;
				pic.y = 90;
			});
			
			var text1:TextField = drawText(Locale.__e('flash:1453393778302'), {
				color:0xffffff,
				borderColor:0x64210e,
				width:settings.width,
				textAlign:'center',
				fontSize:26
			});
			text1.y = (stripe.height - text1.textHeight) / 2;
			bodyContainer.addChild(text1);
			
			var text2:TextField = drawText(Locale.__e('flash:1453393829708'), {
				color:0x634425,
				border:false,
				width:settings.width - 100,
				textAlign:'center',
				fontSize:22,
				multiline:true,
				wrap:true
			});
			text2.x = 50;
			text2.y = 300;
			bodyContainer.addChild(text2);
			
			var separator:Bitmap = Window.backingShort(settings.width - 120, 'dividerLine', false);
			separator.x = 65;
			separator.y = 287;
			separator.alpha = 0.5;
			bodyContainer.addChild(separator);
			
			var separator2:Bitmap = Window.backingShort(settings.width - 120, 'dividerLine', false);
			separator2.scaleY = -1;
			separator2.x = 65;
			separator2.y = 365;
			separator2.alpha = 0.5;
			bodyContainer.addChild(separator2);
			
			var titleText:TextField = drawText(settings.title, {
				color				: 0xffffff,
				multiline			: settings.multiline,			
				fontSize			: 46,
				textLeading	 		: settings.textLeading,	
				border				: true,
				borderColor 		: 0xc4964e,			
				borderSize 			: 4,	
				shadowColor			: 0x503f33,
				shadowSize			: 4,
				width				: settings.width,
				textAlign			: 'center',
				sharpness 			: 50,
				thickness			: 50
			});
			titleText.y = 0;
			bodyContainer.addChild(titleText);
			drawMirrowObjs('titleDecRose', titleText.x + (titleText.width - titleText.textWidth) / 2 - 75, titleText.x + (titleText.width - titleText.textWidth) / 2 + titleText.textWidth + 75, titleText.y + (titleText.height - 40) / 2, false, false, false, 1, 1);
			
			drawBttn();
		}
		
		public function drawBttn():void {
			var fontSize:int = 36;
			if (App.lang == 'jp') fontSize = 26;
			var bttnSettings:Object = {
				fontSize:fontSize,
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
		
		protected function buyEvent(e:MouseEvent):void {
			if (e.currentTarget.mode == Button.DISABLED) return;
			
			var link:String = getIconLink();
			Payments.buy( {
				money:			'promo',
				price:			action.price[App.social],
				id:				action.id,
				title: 			Locale.__e('flash:1382952379793'),
				description: 	Locale.__e('flash:1382952380239'),
				callback: 		onBuyComplete,
				icon:			link
			});
		}
		
		protected function onBuyComplete(e:* = null):void {
			priceBttn.state = Button.DISABLED;
			
			// Преобразовать количество бустеров во время и запускаем их
			App.user.stock.addAll(action.items);
			App.user.activeBooster();
			App.user.boosterLimit = 0;
			
			close();
		}
		
		protected function getIconLink():String {
			var sID:int = 0;
			for (var s:String in action.items) {
				sID = int(s);
				break;
			}
			return Config.getIcon(App.data.storage[sID].type, App.data.storage[sID].preview);
		}
		
	}

}