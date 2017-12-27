package wins.elements 
{
	import api.ExternalApi;
	import buttons.Button;
	import core.Load;
	import core.Post;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.text.TextField;
	import ui.UserInterface;
	import units.Field;
	import units.Techno;
	import wins.actions.BanksWindow;
	import wins.Window;

	public class BankItem extends LayerX {
		
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
		
		private var settings:Object = {
			height:216,
			width:186,
			icons:true,
			sale:false
		}
		
		public function BankItem(item:*, window:*, _settings:Object = null) {
			
			this.item = item;
			this.window = window;
			
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
				votes:	item.socialprice[App.social] || 0, 
				extra:  item.extra,
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
			
			background = Window.backing(settings.width, settings.height, 30, 'itemBacking');
			
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
			
			addChild(preloader);
			preloader.x = (background.width)/ 2;
			preloader.y = (background.height)/ 2 - 15;
			
			var short:Boolean = false;
			
			Load.loading(Config.getIcon(item.type, item.preview), onPreviewComplete);
			
		
			drawBttn();
			
			drawCount();
			
			checkLabels();
			
		}
		
		private function checkLabels():void 
		{
			var type:String;
			var price:Number = item.socialprice[App.social];
			
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
			var bttnSettings:Object = {
				caption:Payments.price(item.socialprice[App.social]),
				fontSize:24,
				width:130,
				height:46,
				hasDotes:false
			};
			
			switch(item.type) {
				case BanksWindow.COINS:
					
				break;
				case BanksWindow.REALS:
					bttnSettings["bgColor"] = [0xfdb29f, 0xed7483];
					bttnSettings["borderColor"] = [0xffffff, 0xffffff];	
					bttnSettings["bevelColor"] = [0xfeb19f, 0xe87383];	
					bttnSettings["fontColor"] = 0xffffff;			
					bttnSettings["fontBorderColor"] = 0x993a40;
					bttnSettings["greenDotes"] = false;					
				break;
				case BanksWindow.SETS:
					
				break;
			}
			
			buyBttn = new Button(bttnSettings);
			addChild(buyBttn);
			buyBttn.x = background.width/2 - buyBttn.width/2;
			buyBttn.y = background.height - buyBttn.height + 8;
			
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
			}
			
			//if (!settings.icons) {
				//sighnTxt = "x";
				//icon = null;
			//}
			
			var counterLabel:TextField;
			counterLabel = Window.drawText(sighnTxt + String(item.price[ind])/*(item.price[ind] + ((App.data.money[App.social].enabled && App.data.money[App.social].date_to > App.time)?buyObject.extra:0))*/, {
				fontSize:34,
				color:0xffffff,
				borderColor:0x7b4004,
				autoSize:"left"
			});
			counterLabel.x = background.width - counterLabel.textWidth - 26;
			counterLabel.y = 142;
			
			if (settings.sale) {
				counterLabel.y = 164;
			}
		
			addChild(counterLabel);
			
			
			var isExtra:Boolean = false;
			
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
			}
			
			/*if ((App.data.money.enabled && App.data.money.date_to > App.time)) {
				
			}*/
			
			
			if (icon) {
				icon.scaleX = icon.scaleY = 0.7;
				icon.smoothing = true;
				icon.filters = [new GlowFilter(0x7b4004, 1, 4, 4)];
				if(isExtra){
					icon.x = 0; //contCount.x - icon.width - 4;
					icon.y = counterLabel.y + 5;// contCount.y + (contCount.height - icon.height) / 2;
					contCount.addChild(icon);
					
					counterLabel.x += icon.width;
					extraTxt.x += icon.width;
					
					if (contCount.width > settings.width - 30) {
						
						var fontSizeCnt:int = 30;
						var fontSizeExtra:int = 34;
						var price:int = item.price[ind];
						var posYPrice:int = 0;
						var posYExtra:int = 0;
						
						if (price >= 10000) {
							fontSizeExtra = 28;
							fontSizeCnt = 24;
							posYPrice = 6;
							posYExtra = 4;
						}
						else if (price >= 1000) {
							fontSizeExtra = 30;
							fontSizeCnt = 26;
							posYPrice = 5;
							posYExtra = 3;
						}
						else if (price >= 100) {
							fontSizeExtra = 32;
							fontSizeCnt = 28;
							posYPrice = 4;
							posYExtra = 2;
						}
						
						
						counterLabel.parent.removeChild(counterLabel);
						counterLabel = null;
						counterLabel = Window.drawText(sighnTxt + String(item.price[ind])/*(item.price[ind] + ((App.data.money.enabled && App.data.money.date_to > App.time)?buyObject.extra:0))*/, {
							fontSize:fontSizeCnt,
							color:0xffffff,
							borderColor:0x7b4004,
							autoSize:"left"
						});
						counterLabel.x = icon.width;
						counterLabel.y = icon.y + icon.height/* + 3*/ - counterLabel.textHeight;
						contCount.addChild(counterLabel);
						extraTxt.x = counterLabel.textWidth + 5 + icon.width;
						
						extraTxt.parent.removeChild(extraTxt);
						extraTxt = null;
						extraTxt = Window.drawText("+" + String(buyObject.extra), {
							fontSize:fontSizeExtra,
							color:0x8fffff,
							borderColor:0x08355f,
							autoSize:"left"
						});
						extraTxt.x = counterLabel.x + counterLabel.textWidth + 5;
						extraTxt.y = icon.y + icon.height + 3 - extraTxt.textHeight + counterLabel.textHeight/2 + 5;
						contCount.addChild(extraTxt);
					}
					
					contCount.x = (settings.width - contCount.width) / 2;
				}else{
					icon.x = counterLabel.x - 4 - icon.width;
					icon.y = counterLabel.y + (counterLabel.textHeight - icon.height) / 2;
					addChild(icon);
				}
			}
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
					type:		buyObject.type
				};
			}else{
				object = {
					money: buyObject.type,
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
				var item:BonusItem = new BonusItem(idItem, 1);
				item.cashMove(point, App.self.windowContainer);
			}
			ExternalApi.apiBalanceEvent(object);
		}
		
	}
}	