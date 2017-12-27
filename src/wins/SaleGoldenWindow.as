package wins 
{
	import api.ExternalApi;
	import buttons.Button;
	import core.Load;
	import core.Post;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import ui.UserInterface;
	/**
	 * ...
	 * @author ...
	 */
	public class SaleGoldenWindow extends Window
	{
		private var icon:Bitmap = new Bitmap();
		private var preloader:Preloader = new Preloader();
		
		private var priceBttn:Button;
		
		public var action:Object;
		
		public function SaleGoldenWindow(settings:Object) 
		{
			settings["title"] = Locale.__e("flash:1396521604876");
			settings["width"] = 450;
			settings["height"] = 400;
			settings["hasPaginator"] = false;
			settings["background"] = 'questBacking';
			
			action = App.data.actions[settings.pID];
			action['id'] = settings.pID;
			
			super(settings);
		}
		
		override public function drawBody():void 
		{
			exit.y -= 20;
			exit.x += 10;
			
			var effect:Bitmap = Window.backingShort(400, 'magicFog');
			bodyContainer.addChild(effect);
			effect.x = (settings.width - effect.width) / 2;
			effect.y = 10;
			
			bodyContainer.addChild(preloader);
			preloader.x = settings.width / 2;
			preloader.y = 140;
			
			Load.loading(Config.getImage('furry', 'furry1'), onLoadIcon);
			bodyContainer.addChild(icon);
			
			
			var stripe:Bitmap = Window.backingShort(settings.width + 160, 'questRibbon');
			bodyContainer.addChild(stripe);
			stripe.x = (settings.width - stripe.width) / 2;
			stripe.y = settings.height - 96;
			
			drawMirrowObjs('diamondsTop', settings.width / 2 - settings.titleWidth / 2 - 5, settings.width / 2 + settings.titleWidth / 2 + 5, -44, true, true);
			drawMirrowObjs('storageWoodenDec', -4, settings.width + 4, 44, false, false, false, 1, -1);
			
			drawTexts();
			drawBttn();
		}
		
		private function onLoadIcon(data:*):void 
		{
			bodyContainer.removeChild(preloader);
			
			icon.bitmapData = data.bitmapData;
			icon.x = (settings.width - icon.width) / 2;
			icon.y = 0;
		}
		
		private var texts:Object = {
			0:{txt:Locale.__e('flash:1406895121425'), bmd:Window.textures.saleTextBacking, scale:0.7, rotation:-18, x:-20, y:0},
			1:{txt:Locale.__e('flash:1406895143591'), bmd:Window.textures.saleTextBacking, scale:1, rotation:14, x:-40, y:60},
			2:{txt:Locale.__e('flash:1406895282697'), bmd:Window.textures.saleTextBacking, scale:0.7, rotation:-17, x:20, y:230},
			3:{txt:Locale.__e('flash:1406895320506'), bmd:Window.textures.saleTextBacking, scale:1, rotation:-13, x:326, y:36},
			4:{txt:Locale.__e('flash:1406895426655'), bmd:Window.textures.saleTextBacking, scale:1, rotation:8, x:330, y:150}
		}
		
		private function drawTexts():void 
		{
			for each(var data:* in texts) {
				drawOneTxt(data.txt, data.bmd, data.scale, data.rotation, data.x, data.y);
			}
			
			var txtDesc:TextField = Window.drawText(Locale.__e("flash:1406900643082"),{
				fontSize:28,
				color:0xfbffef,
				borderColor:0x8046ac,
				autoSize:"center"
			});
			txtDesc.width = 300;
			txtDesc.x = (settings.width - txtDesc.width) / 2;
			txtDesc.y = 320;
			bodyContainer.addChild(txtDesc);
		}
		
		private function drawOneTxt(txt:String, bg:BitmapData, _scale:Number, _rotation:int, xPos:int, yPos:int):void
		{
			var container:Sprite = new Sprite();
			bodyContainer.addChild(container);
			
			var bgTxt:Bitmap = new Bitmap(bg);
			bgTxt.scaleX = bgTxt.scaleY = _scale;
			bgTxt.smoothing = true;
			container.addChild(bgTxt);
			bgTxt.x = 25;
			var txtDesc:TextField = Window.drawText(txt,{
				fontSize:26,
				color:0xfeffe8,
				borderColor:0x754618,
				autoSize:"center",
				textAlign:'center',
				multiline:true,
				wrap:true,
				width:bg.width + 40
			});
			txtDesc.y = (bgTxt.height - txtDesc.textHeight) / 2;
			txtDesc.x = bgTxt.x +(bgTxt.width - txtDesc.width) / 2;
			container.addChild(txtDesc);
			
			
			
			container.rotation = _rotation;
			container.x = xPos;
			container.y = yPos;
		}
		
		private function drawBttn():void {
			
			var bttnSettings:Object = {
				fontSize:36,
				width:186,
				height:52
				//hasDotes:true
			};
			
			if (priceBttn != null)
				bodyContainer.removeChild(priceBttn);
			
			bttnSettings['caption'] = Payments.price(action.price[App.social]);
			priceBttn = new Button(bttnSettings);
			priceBttn.x = (settings.width - priceBttn.width) / 2;
			priceBttn.y = (settings.height - 45);
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
		
		private function buyEvent(e:MouseEvent):void
		{
			if (e.currentTarget.mode == Button.DISABLED) return;
			
			onBuyComplete();
			//descriptionLabel.visible = false;
			//timerText.visible = false;
			switch(App.social) {
				case 'PL':
					//if(!App.user.stock.check(Stock.FANT, action.price[App.social])){
						//close();
						
						//break;
					//}
				case 'YB':
					if(App.user.stock.take(Stock.FANT, action.price[App.social])){
						Post.send({
							ctr:'Promo',
							act:'buy',
							uID:App.user.id,
							pID:action.id,
							ext:App.social
						},function(error:*, data:*, params:*):void {
							onBuyComplete();
						});
					}else {
						close();
					}
					break;
				default:
					var object:Object;
					if (App.social == 'FB') {
						ExternalApi.apiNormalScreenEvent();
						object = {
							id:		 		action.id,
							type:			'promo',
							title: 			Locale.__e('flash:1382952379793'),
							description: 	Locale.__e('flash:1382952380239'),
							callback:		onBuyComplete
						};
					}else if (App.social == 'GN') {
						object = {
							itemId:		'promo_'+action.id,
							price:		int(action.price[App.self.flashVars.social]),
							amount:		1,
							itemName:	Locale.__e('flash:1382952379793'),
							callback: 	onBuyComplete
						};
					}else{
						object = {
							count:			1,
							money:			'promo',
							type:			'item',
							item:			'promo_'+action.id,
							votes:			int(action.price[App.self.flashVars.social]),
							title: 			Locale.__e('flash:1382952379793'),
							description: 	Locale.__e('flash:1382952380239'),
							callback: 		onBuyComplete
						}
					}
					ExternalApi.apiPromoEvent(object);
					break;
			}
		}
		
		private function onBuyComplete(e:* = null):void 
		{
			priceBttn.state = Button.DISABLED;
			
			App.user.stock.addAll(action.items);
			
			App.user.promo[action.id].buy = 1;
			App.user.buyPromo(action.id);
			App.ui.salesPanel.createPromoPanel();
			
			close();
			
			new SimpleWindow( {
				label:SimpleWindow.ATTENTION,
				title:Locale.__e("flash:1382952379735"),
				text:Locale.__e("flash:1382952379990")
			}).show();
		}
		
	}

}