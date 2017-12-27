package wins {
	
	import api.ExternalApi;
	import buttons.Button;
	import core.Load;
	import core.Post;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.utils.setTimeout;
	import ui.UserInterface;
	
	public class SaleBoosterWindow extends Window {
		
		private var iconLink:String = '';
		public var icon:Bitmap;
		private var preloader:Preloader = new Preloader();
		
		protected var priceBttn:Button;
		public var titleField:TextField;
		public var descLabel:TextField;
		
		public var action:Object;
		public var checkBack:Bitmap;
		public var stripe:Bitmap;
		
		public var texts:Object = {
			//227: { 0: 'flash:1413192251710', 1: 'flash:1413192625775' },	// Нектар
			59: { 0: 'flash:1413192287727', 1: 'flash:1413192639034' },	// Монеты
			72: { 0: 'flash:1413192273749', 1: 'flash:1412866371989' },	// Опыт
			73: { 0: 'flash:1432809508782', 1: 'flash:1432809557260' },	// Энергия
			95: { 0: 'flash:1432809508782', 1: 'flash:1432991705981' }	// Энергия
		}
		public var diamondsCont:Sprite;
		
		public function SaleBoosterWindow(settings:Object) {
			settings["hasTitle"] = false;
			settings["width"] = settings.width || 440;
			settings["height"] = settings.height || 430;
			settings["hasPaginator"] = false;
			settings["background"] = 'alertBacking';
			
			action = App.data.actions[settings.pID];
			action['id'] = settings.pID;
			
			super(settings);
		}
		
		override public function drawTitle():void {
			
			var text1:String = (texts.hasOwnProperty(action.id)) ? texts[action.id]['0'] : '';
			titleLabel = titleText( {
				title				: Locale.__e(text1) || Locale.__e("flash:1396521604876"),
				color				: 0xffffff,
				multiline			: settings.multiline,			
				fontSize			: 44,
				textLeading	 		: settings.textLeading,	
				border				: true,
				borderColor 		: 0xc4964e,			
				borderSize 			: 4,	
				shadowColor			: 0x503f33,
				shadowSize			: 4,
				width				: settings.width - 140,
				textAlign			: 'center',
				sharpness 			: 50,
				thickness			: 50
			});
			titleLabel.x = (settings.width - titleLabel.width) / 2;
			titleLabel.y = - titleLabel.height / 2;
			titleLabel.mouseChildren = titleLabel.mouseEnabled = false;
			headerContainer.addChild(titleLabel);
			
			headerContainer.y = 22;
			headerContainer.mouseEnabled = false;
		}
		
		override public function drawBody():void {
			exit.y -= 5;
			exit.x += 30;
			
			checkBack = new Bitmap(Window.textures.boosterSaleBacking, 'auto', true);
			checkBack.x = (settings.width - checkBack.width) / 2;
			checkBack.y = 85;
			bodyContainer.addChild(checkBack);
			
			icon = new Bitmap();
			icon.x = checkBack.x + checkBack.width / 2;
			icon.y = checkBack.y + checkBack.height / 2;
			bodyContainer.addChild(icon);
			
			preloader.x = checkBack.x + checkBack.width / 2;
			preloader.y = checkBack.y + checkBack.height / 2;
			bodyContainer.addChild(preloader);
			
			stripe = Window.backingShort(settings.width + 160, 'ribbonYellow');
			stripe.scaleX = 0.8;
			stripe.x = (settings.width - stripe.width) / 2;
			stripe.y = 0;
			bodyContainer.addChild(stripe);			
			
			drawText1Title();
			
			var text2:String = (texts.hasOwnProperty(action.id)) ? texts[action.id]['1'] : '';
			descLabel = drawText(Locale.__e(text2), {
				fontSize:		23,
				color:			0xfedd42,
				borderColor:	0x532f1f,
				textAlign:		'center',
				width:			settings.width - 120,
				multiline:		true,
				wrap:			true
			});
			descLabel.x = (settings.width - descLabel.width) / 2;
			descLabel.y = 295;
			bodyContainer.addChild(descLabel);
			
			diamondsCont = new Sprite(); 
			bodyContainer.addChild(diamondsCont);			
			drawMirrowObjs('diamondsTop', settings.width / 2 - titleField.width / 2 + 12, settings.width / 2 + titleField.width / 2 - 12, titleField.y + 4, true, true,false,1,1, diamondsCont);
			
			drawBttn();
			
			iconLink = getIconLink();
			Load.loading(iconLink, onLoadIcon);
		}
		
		protected function drawText1Title():void {
			var text1:String = (texts.hasOwnProperty(action.id)) ? texts[action.id]['0'] : '';
			titleField = drawText(Locale.__e(text1), {
				color				: 0xffffff,
				fontSize			: 46,
				border				: true,
				borderColor 		: 0xc4964e,			
				borderSize 			: 4,	
				shadowColor			: 0x503f33,
				shadowSize			: 4,
				width				: settings.width - 140,
				textAlign			: 'center',
				sharpness 			: 50,
				thickness			: 50
			});
			titleField.x = stripe.x + (stripe.width - titleField.width) / 2;
			titleField.y = stripe.y + (stripe.height - titleField.height) / 2 - 17;
			bodyContainer.addChild(titleField);
		}
		
		protected function getIconLink():String {
			var sID:int = 0;
			for (var s:String in action.items) {
				sID = int(s);
				break;
			}
			return Config.getIcon(App.data.storage[sID].type, App.data.storage[sID].preview);
		}
		
		public function onLoadIcon(data:*):void {
			bodyContainer.removeChild(preloader);
			
			icon.bitmapData = data.bitmapData;
			icon.x += -icon.width / 2;
			icon.y += -icon.height / 2;
		}
		
		public function drawBttn():void {
			var fontSize:int = 36;
			if (App.lang == 'jp') fontSize = 26;
			var bttnSettings:Object = {
				fontSize:fontSize,
				width:220,
				height:58
				//hasDotes:true
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
			
			priceBttn.state = Button.DISABLED;
			//priceBttn.visible = false;
			setTimeout(function():void { priceBttn.state = Button.NORMAL; }, 2000);
			
			priceBttn.addEventListener(MouseEvent.CLICK, buyEvent);
		}
		
		private function redrawWindowHeight(_height:Number):void {
			settings.height = _height;
			drawBackground();
		}
		
		protected function buyEvent(e:MouseEvent):void {
			if (e.currentTarget.mode == Button.DISABLED) return;
			
			Payments.buy( {
				money:			'promo',
				price:			action.price[App.social],
				id:				action.id,
				title: 			(texts.hasOwnProperty(action.id)) ? Locale.__e(texts[action.id]['0']) : '',
				description: 	(texts.hasOwnProperty(action.id)) ? Locale.__e(texts[action.id]['1']) : '',
				callback: 		onBuyComplete,
				icon:			iconLink
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
		
		override public function close(e:MouseEvent = null):void {
			//App.user.boosterLimit = 0;
			
			super.close(e);
		}
		
		override public function show():void {
			if (App.user.id == '241769205') return;
			
			super.show();
		}
	}
}