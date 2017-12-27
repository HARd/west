package wins.elements
{
	import api.ExternalApi;
	import buttons.Button;
	import core.Load;
	import core.Numbers;
	import core.Post;
	import core.Size;
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
	import wins.Window;

	public class BankSetsItem extends LayerX {
		
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
		
		public var buyObject:Object;
		
		public var settings:Object = {
			height:207,
			width:275,
			icons:false,
			sale:false,
			profit:0,
			isBestsell:false,
			isActionGained:false
		}
		
		public var reward:Array;
		
		public function BankSetsItem(item:*, window:*, _settings:Object = null) {
			
			this.item = item;
			this.window = window;
			if (item && item.hasOwnProperty('reward') && item.reward!={}) {
				reward = [];
				//var itnm:uint
				for (var it:String in item.reward){
					reward[0] = it;
					break;
				}
			}
			settings.profit = _settings.profitValue | 0;
			settings.isBestsell = true;/*(_settings.isBestsell)?true:false*/;
			settings.isActionGained = (_settings.isActionGained)?true:false;
			setPriceData();
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
				type: itemType,
				count:	item.price[priceData.sid] || 0, 
				votes:	item.socialprice[App.social] || 0, 
				extra:  item.extra || 1,
				id:		item.sid,
				title: Locale.__e(item.title)
			};
			
			if (_settings) {
				for (var s:String in _settings) {
					this.settings[s] = _settings[s];
				}
			}
			
			if (this.settings['glow']) {
				if (item.hasOwnProperty('socialprice') && item.socialprice.hasOwnProperty(App.social) && int(item.socialprice[App.social]) >= 50) {
					startGlowing();
				}
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
			
			background = Window.backing(settings.width, settings.height, 30, 'dialogueBacking');
			
			var clt:ColorTransform = new ColorTransform(1.0, 1.0, 0.7);
			//background.transform.colorTransform = clt;
			addChildAt(background, 0);
			
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
			
			drawTitle();
			
			//addChild(preloader);
			//preloader.x = (background.width)/ 2;
			//preloader.y = (background.height)/ 2 - 15;
			
			var short:Boolean = false;
			
			//Load.loading(Config.getIcon(item.type, item.preview), onPreviewComplete);
			
			hasExtra();
			
			checkLabels();
			drawIcons();
			drawCount();
			drawBttn();
		}
		
		public var flagCont:LayerX = new LayerX();
		
		public var premiumCont:Sprite = new Sprite();
		private function drawPremium():void {
			
			if (settings.isActionGained) {
				var superLabel:Bitmap = new Bitmap(UserInterface.textures.saleLabelBank);
				premiumCont.addChild(superLabel);
				
				var newStripe:Bitmap = new Bitmap(UserInterface.textures.bonusRedRibbon);
				newStripe.x = background.x;
				newStripe.y = background.y;
				addChild(newStripe);
				
				var bcount:uint = 0;
				
				profitLabel.visible = false;
				superLabel.x = background.x + 175;
				var coin:Bitmap = new Bitmap();
				
				for (var __sid:* in item.bonus) {
					bcount = item.bonus[__sid];
					break;
				}
				switch(__sid) {
					case Stock.FANT:
						coin.bitmapData = UserInterface.textures.fantsIcon;
						coin.scaleX = coin.scaleY = 0.7;
						coin.smoothing = true;
						break;
					case Stock.COINS:
						coin.bitmapData = UserInterface.textures.coinsIcon;
						coin.scaleX = coin.scaleY = 0.7;
						coin.smoothing = true;
						break;	
					default:
						Load.loading(Config.getIcon(App.data.storage[__sid].type, App.data.storage[__sid].preview), function(data:Bitmap):void {
							coin.bitmapData = data.bitmapData;
							var scale:Number = 30 / Math.max(coin.width, 30);
							coin.scaleX = coin.scaleY = scale;
							coin.smoothing = true;
						});
						break
				}
				//var coin:Bitmap = new Bitmap(UserInterface.textures.coinsIcon)
				coin.x = superLabel.x + 32;
				coin.y = superLabel.y + 29;
				
				superLabel.y += 15;
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
				//coin.scaleX = coin.scaleY = 0.7;
				//coin.smoothing = true;
				plusLabel.x = coin.x - 20;
				plusLabel.y = coin.y;
				
				prmsPlusFree.textAlign = 'center'
				var freeLabel:TextField = Window.drawText("\n" + Locale.__e('flash:1382952380285') + '!', prmsPlusFree)
				freeLabel.x = plusLabel.x;
				freeLabel.y = plusLabel.y;
				
				var prmsCountLbl:Object = {
					color:0xfade59,
					borderColor:0x793900,
					width:92,
					border:true,
					multilnine:true,
					wrap:true,
					textAlign:"left",
					autoSize:"center",
					fontSize:24
				}
				var bonusValue:TextField = Window.drawText(String(bcount), prmsCountLbl);
				//bonusValue.border = true;
				bonusValue.x = coin.x + 25;
				bonusValue.y = coin.y;
				premiumCont.addChild(plusLabel);
				premiumCont.addChild(freeLabel);
				premiumCont.addChild(coin);
				premiumCont.addChild(bonusValue);
				addChild(premiumCont);
				
			}
		}
		
		//public function get bonusVal():uint {
			//return item.extra;
		//}
		
		public var profitLabel:TextField = new TextField();
		
		private function checkLabels():void
		{
			if (settings.profit && settings.profit!= 0) {
				var prfVal:uint = settings.profit;
				var prms:Object = {
					color:0xd62d4e,
					border:false,
					textAlign:"center",
					autoSize:"center",
					fontSize:24
				}
				
				profitLabel = Window.drawText( Locale.__e('flash:1419254677876') + " " + prfVal + "%", prms );
				if(App.social == 'FB'){
					profitLabel = Window.drawText( prfVal + "% " + Locale.__e('flash:1419254677876'), prms );
				}else {
					profitLabel = Window.drawText( Locale.__e('flash:1419254677876') + " " + prfVal + "%", prms );
				}
				profitLabel.x = background.x + 191;
				profitLabel.y = background.y + (background.height - profitLabel.height) / 2;
				addChild(profitLabel);
			}
			
			var type:String;
			var price:Number = item.socialprice[App.social];
			
			if(settings.isActionGained)
				profitLabel.visible = false;
			type = 'Sets'
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
		
		public var priceIcon:Bitmap = new Bitmap();
		public var rewardIcon:Bitmap = new Bitmap();
		public var priceGlow:Bitmap;
		public var priceData:Object = {
			sid:0,
			count:0
		}
		
		public function setPriceData():void {
			var priceSid:String = '';
			var priceCount:uint = 0;
			for (priceSid in item.price) {
				priceCount = item.price[priceSid];
			}
			priceData.sid = priceSid;
			priceData.count = priceCount;
		}
		
		public function drawIcons():void {
			priceGlow = new Bitmap(Window.textures.glow, 'auto', true);
			priceGlow.width = 120;
			priceGlow.height = 120;
			priceGlow.y = 15;
			addChild(priceGlow);
			
			addChild(priceIcon);
			addChild(rewardIcon);
			drawPriceIcon();
			drawRewardIcon();
			var plus:Bitmap = new Bitmap(Window.textures.plus);
			plus.x = background.x + (background.width - plus.width) / 2;
			plus.y = background.y + (background.height - plus.height) / 2;
			addChild(plus);
		}
		
		private var scaleVal:Number = 1;
		private function drawPriceIcon():void {
			Load.loading(priceIconPath, function(data:Bitmap):void {
				priceIcon.bitmapData = data.bitmapData;
				priceIcon.smoothing = true;
				priceIcon.scaleX = priceIcon.scaleY = 0.75;
				priceIcon.x = background.x + (background.width / 2 - priceIcon.width) / 2 - 10;
				priceIcon.y = background.y + (background.height - priceIcon.height) / 2 - 15;
				App.ui.flashGlowing(priceIcon);
			});
		}
		
		private function drawRewardIcon():void {
			Load.loading(rewIconPath, function(data:Bitmap):void {
				rewardIcon.bitmapData = data.bitmapData;
				rewardIcon.smoothing = true;
				Size.size(rewardIcon, 114, 170);
				rewardIcon.x = background.x + 220 - rewardIcon.width / 2;
				rewardIcon.y = background.y + (background.height - rewardIcon.height) / 2;
				if (settings.isActionGained)
					rewardIcon.y += 30;
				App.ui.flashGlowing(rewardIcon);
			});
		}
		
		private function get rewIconPath():String {
			var item:Object = App.data.storage[reward[0]];
			return Config.getIcon(item.type,item.view);
		}
		
		private function get itemType():String {
			var type:String = '';
			if (priceData.sid == Stock.COINS)
				type = 'Coins';
			if (priceData.sid == Stock.FANT)
				type = 'Reals';
			return type;
		}
		
		private function get priceIconPath():String {
			var type:String = itemType;

			var moneyList:Array = [];
			for (var itm:String in App.data.storage) {
				if (App.data.storage[itm].type == type) {
					moneyList.push(App.data.storage[itm]);
				}
			}
			moneyList.sortOn('price');
			/*for (var i:int = 0; i < moneyList.length - 1; i++) {
				for (var j:int = 0; j < moneyList.length - 1; j++) {
					if (moneyList[j].price[priceData.sid] < moneyList[j+1].price[priceData.sid]) {
						var buff:* = moneyList[j].price[priceData.sid];
						moneyList[j].price[priceData.sid] = moneyList[j + 1].price[priceData.sid];
						moneyList[j + 1].price[priceData.sid] = buff;
					}
				}
			}*/
			var finalView:String = '';
			var theMost:uint = priceData.count;
			for (itm in moneyList) {
				if (priceData.count > moneyList[itm].price[priceData.sid]) {
					finalView = moneyList[itm].preview;
				}
			}
			if (item.type == 'Sets') {
				moneyList.sortOn('order', Array.NUMERIC | Array.DESCENDING);
				finalView = moneyList[item.id + 2].preview;
			}else if (finalView == '') {
				finalView = moneyList[0].preview;
			}
			return Config.getIcon(type, finalView);
		}
		
		public function drawBttn():void
		{
			
			var priceVal:String = Payments.price(item.socialprice[App.social]);
			var bttnSettings:Object = {
				caption:priceVal,
				fontSize:24,
				width:150,
				height:46,
				hasDotes:false
			};
			
			switch(item.type) {
				case BanksWindow.COINS:
					
				break;
				case BanksWindow.SETS:
				case BanksWindow.REALS:
					bttnSettings["bgColor"] = [0xfdb29f, 0xed7483];
					bttnSettings["borderColor"] = [0xffffff, 0xffffff];	
					bttnSettings["bevelColor"] = [0xfeb19f, 0xe87383];	
					bttnSettings["fontColor"] = 0xffffff;			
					bttnSettings["fontBorderColor"] = 0x993a40;
					bttnSettings["greenDotes"] = false;					
				break;
			}
			
			var pvalPars:Object = {
					color:0x793900,
					border:false,
					textAlign:"left",
					autoSize:"center",
					fontSize:22
				};
			
			var priceLabel:TextField = Window.drawText(priceVal, pvalPars)
			
			//addChild(priceLabel);
			priceLabel.x = 312;
			priceLabel.y = background.y + (background.height - priceLabel.height)/2
			
			buyBttn = new Button(bttnSettings);
			addChild(buyBttn);
			buyBttn.x = 72;
			buyBttn.y = 185;
			
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
			addChild(title)
		}
		
		//var isExtra:Boolean = true;
		private function drawCount():void
		{	
			var ind:int;
			var icon:Bitmap;
			
			var sighnTxt:String = "x";
			switch(item.type) {
				case 'Reals':
					ind = Stock.FANT;
					icon = new Bitmap(UserInterface.textures.fantsIcon);
				break;
				case 'Coins':
					ind = Stock.COINS;
					icon = new Bitmap(UserInterface.textures.coinsIcon);
				break;
				case 'Sets':
					ind = priceData.sid;
					icon = (itemType=='Reals')?new Bitmap(UserInterface.textures.fantsIcon):new Bitmap(UserInterface.textures.coinsIcon);
				break;
			}
			
			var counterLabel:TextField;
			counterLabel = Window.drawText(sighnTxt + String(item.price[ind])/*(item.price[ind] + ((App.data.money[App.social].enabled && App.data.money[App.social].date_to > App.time)?buyObject.extra:0))*/, {
				fontSize:34,
				color:(itemType=='Reals')?0xffffff:0xf5cf57,
				borderColor:0x7b4004,
				autoSize:"left"
			});
			counterLabel.x = background.x + 60;
			counterLabel.y = background.y + 144;
			
			icon.x = counterLabel.x - icon.width - 4;
			icon.y = counterLabel.y + (counterLabel.textHeight - icon.height) / 2;
			addChild(icon);
			addChild(counterLabel);
			
			if(settings.isActionGained)
				drawPremium();
		}
		
		public function hasExtra():Boolean {
			var isExtra:Boolean = false;
			if (buyObject.extra && buyObject.extra > 0 && (App.time >= App.data.money.date_from && App.time < App.data.money.date_to && App.data.money.enabled == 1) || App.user.money > App.time) {
				isExtra = true;
				settings.isActionGained = true;
			}
			
			return isExtra;
		}
		
		
		private function buyEvent(e:MouseEvent):void
		{
			var object:Object;
			if (App.social == 'YB') {
				
				if (buyObject.type == 'coins') {
					if(App.user.stock.take(Stock.FANT, buyObject.votes)){
						
						var point:Point = Window.localToGlobal(buyBttn);
						
						Post.send({
							'ctr':'stock',
							'act':'coins',
							'uID':App.user.id,
							'cID':buyObject.id
						}, function(error:*, result:*, params:*):void {
							if (error) {
								Errors.show(error, result);
								return;
							}
							var count:int = buyObject.count + ((App.data.money.enabled && App.data.money.date_to > App.time)?buyObject.extra:0);
							
							var item:BonusItem = new BonusItem(Stock.COINS, count);
							item.cashMove(point, App.self.windowContainer);
							
							//if (reward) {
								//var itm:BonusItem = new BonusItem(reward[0], 1);
								//itm.cashMove(point, App.self.windowContainer);
								//App.user.stock.put(reward[0], 1);
								//
							//}
							
							
							App.user.stock.put(Stock.COINS, result[Stock.COINS] || App.user.stock.count(Stock.COINS));
						});
					}
					return;
				}
				
				object = {
					id:		 	buyObject.id,
					price:		buyObject.votes,
					type:		buyObject.type,
					count: 		buyObject.count + ((App.data.money.enabled && App.data.money.date_to > App.time)?buyObject.extra:0)
				};
			}else if (App.social == 'FB') {
				object = {
					id:		 	buyObject.id,
					type:		item.type,
					callback: function():void {
						bonusAnim();
					}
				};
			}else {
				//App.data.storage
				object = {
					//money: 	App.data.storage[buyObject.id].type,//buyObject.type,
					money: 	buyObject.type,
					type:	'item',
					item:	buyObject.type+"_"+buyObject.id,
					votes:	buyObject.votes,
					count: 	buyObject.count + ((App.data.money.enabled && App.data.money.date_to > App.time)?buyObject.extra:0),
					title:	buyObject.title,
					callback: function():void {
						bonusAnim();
					}
				}
			}
			
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
				var _item:BonusItem = new BonusItem(idItem, 1);
				_item.cashMove(point, App.self.windowContainer);
				
				if (item.hasOwnProperty('bonus') && hasExtra()) {
					App.user.stock.addAll(item.bonus);
				}
				
				
				if (reward) {
					var _point:Point = new Point(flagCont.x, flagCont.y);
					var itm:BonusItem = new BonusItem(reward[0], 1);
					itm.cashMove(_point, App.self.windowContainer);
					App.user.stock.add(reward[0], 1);
					
					
					//App.user.stock.add(
					//(reward[0], 1);
				}
			}
			ExternalApi.apiBalanceEvent(object);
		}
		
	}
}	