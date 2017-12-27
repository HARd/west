package wins.elements 
{
	import api.ExternalApi;
	import buttons.Button;
	import core.Load;
	import core.Log;
	import core.Numbers;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import flash.text.TextField;
	import ui.UserInterface;
	import units.Field;
	import units.Techno;
	import wins.actions.BanksWindow;
	import wins.SimpleWindow;
	import wins.Window;

	public class BankUsualItem extends LayerX {
		
		public var item:*;
		public var background:Bitmap;
		public var bitmap:Bitmap;
		public var title:TextField;
		public var buyBttn:Button;
		public var window:*;
		public var moneyType:String = "coins";
		public var previewScale:Number = 1;
		
		private var needTechno:int = 0;
		
		public var isLabel1:Boolean = false;  // just for test
		public var isLabel2:Boolean = false;   // just for test
		
		private var preloader:Preloader = new Preloader();
		public var confirmed:Boolean = false;
		
		public var buyObject:Object;
		
		public var settings:Object = {
			height:70,
			width:560 + 50*int(App.isSocial('YB','MX')),
			icons:false,
			sale:false,
			profit:0,
			isBestsell:false,
			isActionGained:false
		}
		
		public var reward:Array;
		
		public function BankUsualItem(item:*, window:*, _settings:Object = null) {
			
			this.item = item;
			this.window = window;
			if (item.hasOwnProperty('reward') && item.reward!={}) {
				reward = [];
				//var itnm:uint
				for (var it:String in item.reward){
					reward[0] = it;
					break;
				}
			}
			settings.profit = _settings.profitValue | 0;
			settings.isBestsell =_settings.isBestsell || false;
			settings.isActionGained = _settings.isActionGained || false;
			var ind:int  = 0;
			switch(item.type) {
				case 'Reals':
					ind = Stock.FANT;
				break;
				case 'Coins':
					ind = Stock.COINS;
				break;
			}
			
			buyObject = {
				type: item.type,
				count:	item.price[ind] || 0, 
				votes:	item.socialprice[(App.social == 'DM') ? 'VK' : App.social] || 0, 
				extra:  item.extra,
				id:		item.sid,
				title:	Locale.__e(item.title),
				description: Locale.__e(item.description),
				icon:	Config.getIcon(item.type, item.preview)
			};
			
			if (_settings) {
				for (var s:String in _settings) {
					this.settings[s] = _settings[s];
				}
			}
			
			if (this.settings['glow']) {
				if (Number(item.socialprice[(App.social == 'DM') ? 'VK' : App.social]) >= 50) {
					startGlowing();
				}
			}
			
			if (buyObject.extra && buyObject.extra > 0 && (App.data.money.hasOwnProperty(App.social) && App.time >= App.data.money[App.social].date_from < App.time && App.time < App.data.money[App.social].date_to > App.time && App.data.money[App.social].enabled == 1) || App.user.money > App.time) {
				//isExtra = true;
				settings.isActionGained = true;
			}
			
			/*if (_settings == null) {
				this.settings = new Object();
				
				this.settings = {
					height:216,
					width:186,
					icons:true,
					sale:false
				}
			}else {
				this.settings = _settings;
			}*/
			
			background = Window.backingShort(settings.width,'bankItemBacking');
			addChildAt(background, 0);
			
			if(reward)
				drawFlag();
			
			if (item['new'] == 1) {
				var newStripe:Bitmap = new Bitmap(Window.textures.stripNew);
				newStripe.x = 2;
				newStripe.y = 3;
				addChild(newStripe);
			}
			
			var sprite:LayerX = new LayerX();
			addChild(sprite);
			
			bitmap = new Bitmap();
			sprite.addChild(bitmap);
			
			sprite.tip = function():Object { 
				
				if (item.type == "Plant")
				{
					return {
						title:item.title,
						text:Locale.__e("flash:1382952380075", [TimeConverter.timeToCuts(item.levelTime * item.levels), item.experience, App.data.storage[item.out].cost])
					};
				}
				else if (item.type == "Decor")
				{
					return {
						title:item.title,
						text:Locale.__e("flash:1382952380076", item.experience)
					};
				}
				else
				{
					return {
						title:item.title,
						text:item.description
					};
				}
			};
			
			var short:Boolean = false;
			
			drawBttn();
			
			drawCount();
			
			checkLabels();
		}
		
		public var flagCont:LayerX = new LayerX();
		public static var currView:String = 'unicorn';
		public static var presIco:Object = new Object();
		public function drawFlag():void {
			if (settings.isBestsell) {
				var flagLabel:Bitmap = new Bitmap(UserInterface.textures.bankItemBackingBonus);
				flagCont.addChild(flagLabel);
				addChild(flagCont);
				var presentIco:Bitmap = new Bitmap();
				presentIco.x = flagLabel.x - flagLabel.width + 48;
				presentIco.y = flagLabel.y -44;
				var prcSetts:Object = {
						fontSize: 23,
						border:true,
						color:0xcd2a45,
						borderColor:0xfafff3,
						textAlign:'center'
					};
				var prsntLabel:TextField = Window.drawText(Locale.__e('flash:1419420860172') + '!', prcSetts);
				//prsntLabel.border = true;
				prsntLabel.x = presentIco.x - 10;
				var preCurrView:String = App.data.storage[reward[0]].view;
				if(!presIco.hasOwnProperty(preCurrView)){
						Load.loading(Config.getImage('interface', preCurrView),
									function(data:Bitmap):void {
											presentIco.bitmapData = data.bitmapData;
											presIco[preCurrView] = new Bitmap();
											presIco[preCurrView].bitmapData = data.bitmapData;
											flagCont.addChild(presentIco);
											flagCont.addChild(prsntLabel);
											prsntLabel.y = flagLabel.y + flagLabel.height - prsntLabel.height - 10;
											App.ui.flashGlowing(flagCont);
										});
				}else {
					presentIco.bitmapData = presIco[preCurrView].bitmapData;
					flagCont.addChild(presentIco);
					flagCont.addChild(prsntLabel);
					prsntLabel.y = flagLabel.y + flagLabel.height - prsntLabel.height - 10;
				}
				currView = preCurrView;
				var item:Object = App.data.storage[reward[0]];
				flagCont.tip = function():Object {
					return{
					title:item.title,
					text:item.description
					}
				}
				flagLabel.x = background.x - flagLabel.width * 0.9;
				//swapChildren(flagCont, background);
				flagCont.x += 70;
				flagCont.y -= 6;
			}	
		}
		
		public var premiumCont:Sprite = new Sprite();
		private function drawPremium():void {

			if (settings.isActionGained || settings.isBestsell) {
				var superLabel:Bitmap = new Bitmap(UserInterface.textures.saleLabelBank);
				premiumCont.addChild(superLabel);
				
				//superLabel.addEventListener(MouseEvent.CLICK, buyEvent);
				
				
				var newStripe:Bitmap = new Bitmap(UserInterface.textures.bonusRedRibbon);
				newStripe.x = background.x;
				newStripe.y = background.y;
				addChild(newStripe);
				
				profitLabel.visible = false;
				superLabel.x = background.x + 175;
				var coin:Bitmap = new Bitmap(UserInterface.textures.coinsIcon)
				if (item.type == "Reals")
				coin = new Bitmap(UserInterface.textures.fantsIcon);
				coin.smoothing = true;

				//var coin:Bitmap = new Bitmap(UserInterface.textures.coinsIcon)
				coin.x = superLabel.x + 32;
				coin.y = superLabel.y + 14;
				
				superLabel.y -= 5;
				superLabel.x -= 5;
				var prmsPlusFree:Object = {
					color:0xd62d4e,
					borderColor:0xfff59d,
					width:92,
					border:true,
					multilnine:true,
					wrap:true,
					textAlign:"left",
					autoSize:"center",
					fontSize:22
				}
				var plusLabel:TextField = Window.drawText("+", prmsPlusFree)
				
				//plusFreeLabel.border = true;
				coin.scaleX = coin.scaleY = 0.7;
				plusLabel.x = coin.x - 20;
				plusLabel.y = coin.y;
				
				prmsPlusFree.textAlign = 'center'
				var freeLabel:TextField = Window.drawText("\n" + Locale.__e('flash:1382952380285') + '!', prmsPlusFree)
				freeLabel.x = plusLabel.x;
				freeLabel.y = plusLabel.y;
				
				var bcount:uint = bonusVal;
				
				var prmsCountLbl:Object = {
					//color:0xfce450,
					color:(item.type=='Reals')?0xbbef8b:0xffde3b,
					////////////////////////////////////////////////
					borderColor:(item.type=='Reals')?0x3f6808:0x753a00,
					width:92,
					border:true,
					multilnine:true,
					wrap:true,
					textAlign:"left",
					autoSize:"center",
					fontSize:24,
					shadowColor:0x45680e,
					shadowSize:1
				}
				var bonusValue:TextField = Window.drawText(String(bcount), prmsCountLbl);
				//bonusValue.border = true;
				premiumCont.x += 20*int(App.isSocial('MX','YB'))
				bonusValue.x = coin.x + 25;
				bonusValue.y = coin.y;
				premiumCont.addChild(plusLabel);
				premiumCont.addChild(freeLabel);
				premiumCont.addChild(coin);
				premiumCont.addChild(bonusValue);
				addChild(premiumCont);
			}
		}
		
		public function get bonusVal():uint {
			return item.extra;
		}
		
		public var profitLabel:TextField = new TextField();
		public var includedLabel:TextField = new TextField();
		
		private function checkLabels():void
		{
			if (settings.isActionGained || settings.isBestsell) return;
			if (settings.profit && settings.profit!= 0) {
				var prfVal:Number = settings.profitValue;
				var prms:Object = {
					color:0xd62d4e,
					border:false,
					textAlign:"center",
					autoSize:"center",
					fontSize:22//24
				}
				
				profitLabel = Window.drawText( Locale.__e('flash:1419254677876') + " " + String(prfVal) + "%", prms );
				includedLabel = Window.drawText(Locale.__e('flash:1446452717215'), prms);
				if(App.social == 'FB'){
					profitLabel = Window.drawText( prfVal + "% " + Locale.__e('flash:1419254677876'), prms );
				}else {
					profitLabel = Window.drawText( Locale.__e('flash:1419254677876') + " " + prfVal + "%", prms );
				}
				profitLabel.x = background.x + 200 - 30;
				if (App.lang == 'jp') profitLabel.x = background.x + 200;
				profitLabel.y = background.y + (background.height - profitLabel.height) / 2;
				addChild(profitLabel);
				
				//if (App.isSocial('YB')) {
					includedLabel.x = profitLabel.x + (profitLabel.width - includedLabel.textWidth) / 2;
					includedLabel.y = profitLabel.y + 15;
					addChild(includedLabel);
				//}
			}
			
			var type:String;
			var price:Number = buyObject.votes;
			
			if(settings.isActionGained)
				profitLabel.visible = false;
			if (item.type == "Reals")
				type = 'reals';
			else if (item.type == "Coins")
				type = 'coins';
				
			if (item.offertype) {
				if (item.offertype == 1) {
					isLabel1 = true;
				}else if (item.offertype == 2) {
					isLabel2 = true;
				}
			}
		}
		
		public function drawBttn():void
		{
			var text:String;
			var price:Number = buyObject.votes;
			var fontSize:int = 22;
			
			//text = 'flash:1382952379751'
			var priceVal:String = Payments.price(price);
			
			var bttnSettings:Object = {
				caption:Locale.__e('flash:1382952379751'),
				fontSize:24,
				width:109,
				height:41,
				hasDotes:false
			};
			
			switch(item.type) {
				case BanksWindow.COINS:
					
				break;
				case BanksWindow.REALS:
					bttnSettings["bgColor"] = [0xa2f545, 0x7bc21e];
					bttnSettings["borderColor"] = [0xffffff, 0xffffff];
					bttnSettings["bevelColor"] = [0xcefd93, 0x609d14];
					bttnSettings["fontColor"] = 0xffffff;
					bttnSettings["fontBorderColor"] = 0x4d8314;
					bttnSettings["greenDotes"] = false;
				break;
				case BanksWindow.SETS:
					
				break;
			}
			
			var pvalPars:Object = {
					color:0x793900,
					border:false,
					textAlign:"left",
					autoSize:"center",
					fontSize:fontSize
				};
				
			if (App.isSocial('GN')) pvalPars['fontSize'] = 19;
			
			var priceLabel:TextField = Window.drawText(priceVal, pvalPars)

			addChild(priceLabel);
			priceLabel.x = 306 + 30 * int(App.isSocial('MX', 'YB', 'NK' ,'GN'));
			if (App.isSocial('GN')) priceLabel.x = 300;
			priceLabel.y = background.y + (background.height - priceLabel.height) / 2
			
			if (App.isSocial('MX')) {
				var mxLogo:Bitmap = new Bitmap(UserInterface.textures.mixieLogo);
				addChild(mxLogo);
				mxLogo.y = priceLabel.y - (mxLogo.height - priceLabel.height)/2;
				mxLogo.x = priceLabel.x-10;
				priceLabel.x = mxLogo.x + mxLogo.width + 5;
			}
			
			buyBttn = new Button(bttnSettings);
			addChild(buyBttn);
			buyBttn.x = background.x + background.width - buyBttn.width - 35;
			buyBttn.y = (background.height - buyBttn.height)/2;
			
			buyBttn.addEventListener(MouseEvent.CLICK, buyEvent);
		}
		
		private var dY:int = -22;
		public function onPreviewComplete(data:Bitmap):void
		{
			removeChild(preloader);
			var centerY:int = 90;
			
			bitmap.bitmapData = data.bitmapData;
			bitmap.scaleX = bitmap.scaleY = previewScale;
			bitmap.smoothing = true;
			bitmap.x = (background.width - bitmap.width) / 2;
			if (item.type == 'Resource') centerY = 110;
			bitmap.y = centerY - bitmap.height / 2 + 6;
			
			//bitmap.filters = [new GlowFilter(0x93b0e0, 1, 40, 40)]
		}
		
		public function dispose():void {
			if(buyBttn != null){
				buyBttn.removeEventListener(MouseEvent.CLICK, buyEvent);
			}
			
			if (Quests.targetSettings != null) {
				Quests.targetSettings = null;
				if (App.user.quests.currentTarget == null) {
					QuestsRules.getQuestRule(App.user.quests.currentQID, App.user.quests.currentMID);
				}
			}
		}
		
		public function drawTitle():void {
			title = Window.drawText(String(item.title), {
				color:0xffffff,
				borderColor:0x7b4004,
				textAlign:"center",
				autoSize:"center",
				fontSize:24,
				textLeading:-6,
				multiline:true,
				wrap:true,
				width:background.width - 40
			});
			title.y = 5;
			title.x = (background.width - title.width)/2;
			addChild(title);
		}
		
		//var isExtra:Boolean = true;
		private function drawCount():void
		{	
			var ind:int;
			var icon:Bitmap;
			
			switch(item.type) {
				case 'Reals':
					ind = Stock.FANT;
					icon = new Bitmap(UserInterface.textures.fantsIcon);
				break;
				case 'Coins':
					ind = Stock.COINS;
					icon = new Bitmap(UserInterface.textures.coinsIcon);
				break;
			}
			
			var counterLabel:TextField;
			counterLabel = Window.drawText(Numbers.moneyFormat(int(item.price[ind]))/*(item.price[ind] + ((App.data.money[App.social].enabled && App.data.money[App.social].date_to > App.time)?buyObject.extra:0))*/, {
				fontSize:34,
				color:(item.type=='Reals')?0xbbef8b:0xffde3b,
				//borderColor:0x45680e,
				borderColor:(item.type=='Reals')?0x3f6808:0x753a00,
				autoSize:"left",
				shadowColor:0x45680e,
				shadowSize:1
			});
			counterLabel.x = background.x + 75;
			counterLabel.y = (background.height - counterLabel.height) / 2 + 4;
			
			addChild(counterLabel);
			
			/*var isExtra:Boolean = false;
			if (buyObject.extra && buyObject.extra > 0 && (App.time >= App.data.money.date_from && App.time < App.data.money.date_to && App.data.money.enabled == 1) || App.user.money > App.time) {
				
				var contCount:Sprite = new Sprite();
				var extraTxt:TextField = Window.drawText("+" + String(buyObject.extra), {
					fontSize:34,
					color:0x6ce8de,
					borderColor:0x0e4067,
					autoSize:"left"
				});
				contCount.addChild(counterLabel);
				counterLabel.x = 0;
				counterLabel.y = -counterLabel.textHeight / 2;
				extraTxt.x = counterLabel.textWidth + 5;
				extraTxt.y = counterLabel.y + counterLabel.textHeight/2;
				contCount.addChild(extraTxt);
				addChild(contCount);
				if (settings.sale) {
					contCount.x = (settings.width - contCount.width) / 2;
					contCount.y = 164;
				}else {
					contCount.x = (settings.width - contCount.width) / 2;//background.width - contCount.width - 26;
					contCount.y = 142;
				}
				
				isExtra = true;
				settings.isActionGained = true;
			}*/
			
			icon.x = counterLabel.x - 4 - icon.width;
			icon.y = counterLabel.y + (counterLabel.textHeight - icon.height) / 2;
			addChild(icon);
			
			if(settings.isActionGained || settings.isBestsell)
				drawPremium();
		}
		
		private function buyEvent(e:MouseEvent):void {
			Log.alert('BUY ITEM');
			Log.alert(buyObject);	
			
			if (!confirmed && App.isSocial('GN')) 
			{
				confirmPayment();
				return;	
			}
			
			if (confirmed) 
			{
				confirmed = false;
			}
			
			Payments.buy( {
				type:			'item',
				id:				buyObject.id,
				money:			buyObject.type,
				price:			buyObject.votes,
				count:			buyObject.count + (((App.data.money[App.social].enabled && App.data.money[App.social].date_to > App.time) || App.user.money > App.time)?buyObject.extra:0),
				extra:			buyObject.extra,
				title: 			buyObject.title,
				description: 	buyObject.description,
				callback:		function():void {
					bonusAnim();
				},
				icon:			buyObject.icon
			});		
			
			var bonusAnim:Function = function():void {
				var idItem:int;
				if (buyObject.type == 'Coins')
					idItem = Stock.COINS;
				else
					idItem = Stock.FANT;
				
				var point:Point = Window.localToGlobal(buyBttn);
				if (settings.isBestsell) {
					point.x -= 121;
				}
				var item:BonusItem = new BonusItem(idItem, 1);
				item.cashMove(point, App.self.windowContainer);
				
				
				if (reward) {
					var _point:Point = new Point(flagCont.x, flagCont.y);
					var itm:BonusItem = new BonusItem(reward[0], 1);
					itm.cashMove(_point, App.self.windowContainer);
					//App.user.stock.put(reward[0], 1);
					App.user.stock.add(reward[0], 1);
					//(reward[0], 1);
				}
			}
		}
		
		private function confirmPayment():void 
		{
			new SimpleWindow( {
				popup:			true,
				title:			Locale.__e('flash:1382952379893'),
				text:			Locale.__e('flash:1469797714670'),
				dialog:			true,
				height:			250,
				faderAsClose        :false,
				faderClickable      :false,
				confirm:function():void {
					confirmed = true;
					buyEvent(null);
				},
				cancel:function():void {
					Window.closeAll();
					return;
				}
			}).show();
		}
		
	}
}	