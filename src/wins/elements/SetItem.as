package wins.elements 
{
	import api.ExternalApi;
	import buttons.Button;
	import com.flashdynamix.motion.extras.BitmapTiler;
	import core.Load;
	import core.Log;
	import core.Numbers;
	import core.Post;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import ui.UserInterface;
	import wins.AskWindow;
	import wins.Window;
	public class SetItem extends LayerX 
	{
		public var item:*;
		public var background:Bitmap;
		public var bitmap:Bitmap;
		public var title:TextField;
		public var preloader:Preloader = new Preloader();
		
		public var buyBttn:Button;
		public var giftBttn:Button;
		
		public var window:*;
		
		public var buyObject:Object;
		public var reward:Array;
		
		public var settings:Object = {
			height:207,
			width:275,
			icons:false,
			sale:false,
			profit:0,
			isBestsell:false,
			isActionGained:false
		}
		
		public function SetItem(item:*, window:*, _settings:Object = null) 
		{
			this.item = item;
			this.window = window;
			
			settings.profit = _settings.profitValue | 0;
			settings.isBestsell = true;
			settings.isActionGained = (_settings.isActionGained)?true:false;			
			if (_settings) {
				for (var s:String in _settings) {
					this.settings[s] = _settings[s];
				}
			}
			
			if (item && item.hasOwnProperty('reward') && item.reward!={}) {
				reward = [];
				for (var it:String in item.reward){
					reward[0] = it;
					break;
				}
			}
			
			setPriceData();
			buyObject = {
				type: 'Sets',
				count:	1,//item.price[priceData.sid] || 0, 
				votes:	item.socialprice[App.social] || 0, 
				extra:  item.extra || 1,
				id:		item.sid,
				title: Locale.__e(item.title)
			};
			
			background = Window.backing(settings.width, settings.height, 30, 'dialogueBacking');
			addChildAt(background, 0);
			
			drawTitle();
			drawSet();
			drawButtons();
		}
		
		private function drawButtons():void {
			var layer:Sprite = new Sprite();
			var bttnSettings:Object = {
				caption:Locale.__e('flash:1382952379751'),
				fontSize:21,
				width:110,
				height:42,
				hasDotes:false
			};			
			
			buyBttn = new Button(bttnSettings);			
			buyBttn.addEventListener(MouseEvent.CLICK, buyEvent);
			
			var bttnGiftSettings:Object = {
				caption:Locale.__e('flash:1382952380118'),
				fontSize:21,
				width:110,
				height:42,
				hasDotes:false
			};	
			bttnGiftSettings["bgColor"] = [0xfd91e6, 0xde4588];
			bttnGiftSettings["borderColor"] = [0xffffff, 0xffffff];	
			bttnGiftSettings["bevelColor"] = [0xffb3fd, 0xb52fa8];			
			bttnGiftSettings["fontBorderColor"] = 0x8e285a;
			
			giftBttn = new Button(bttnGiftSettings);
			giftBttn.x = buyBttn.width + 10;			
			giftBttn.addEventListener(MouseEvent.CLICK, giftEvent);
			
			var gift:Bitmap = new Bitmap(Window.texture('giftBttn'));
			gift.x = giftBttn.width - gift.width - 3;
			giftBttn.textLabel.x -= gift.width / 3;
			giftBttn.addChild(gift);
			
			layer.addChild(buyBttn);
			layer.addChild(giftBttn);
			layer.x = (settings.width - layer.width) / 2;
			layer.y = 185;
			addChild(layer);
		}
		
		private function drawTitle():void {
			title = Window.drawText(String(item.title), {
				color:0x763e1b,
				borderColor:0xf8fbe0,
				textAlign:"center",
				autoSize:"center",
				fontSize:23,
				textLeading:-6,
				multiline:true,
				wrap:true,
				width:background.width - 40
			});
			title.x = (background.width - title.width) / 2;
			title.y = 10;
			addChild(title);
		}
		
		private function drawSet():void {
			var sprite:LayerX = new LayerX();
			sprite.x = 10;
			sprite.y = 50;
			addChild(sprite);
			
			bitmap = new Bitmap();
			sprite.addChild(bitmap);
			
			preloader.x = 50;
			preloader.y = 50;
			sprite.addChild(preloader);
			Load.loading(Config.getIcon(item.type, item.view), function(data:*):void {
				if (preloader) sprite.removeChild(preloader);
				bitmap.bitmapData = data.bitmapData;
			});
			
			for (var bonus:String in item.price) {
				switch(int(bonus)) {
					case Stock.FANT:
						var pic:Bitmap = new Bitmap();
						pic.bitmapData = UserInterface.textures.fantsIcon;
						pic.smoothing = true;
						pic.scaleX = pic.scaleY = 0.7;
						pic.x = settings.width - 130;
						pic.y = 50;
						addChild(pic);
						
						var bonusText:TextField;
						bonusText = Window.drawText(Numbers.moneyFormat(item.price[bonus]), {
							color:		0xb7eb87,
							borderColor:0x426b0f,
							fontSize:	24,
							textAlign:	'left'
						});
						bonusText.x = pic.x + pic.width + 10;
						bonusText.y = pic.y;
						addChild(bonusText);
						break;
					case Stock.FANTASY:
						var bonusText2:TextField;
						bonusText2 = Window.drawText('+' + Numbers.moneyFormat(item.price[bonus]), {
							color:		0xffffff,
							borderColor:0x3553c3,
							fontSize:	24,
							textAlign:	'left'
						});
						bonusText2.x = settings.width - 130;
						bonusText2.y = 110;
						addChild(bonusText2);
						
						var pic2:Bitmap = new Bitmap();
						pic2.bitmapData = UserInterface.textures.energyIcon;
						pic2.smoothing = true;
						pic2.scaleX = pic2.scaleY = 0.7;
						pic2.x = bonusText2.x + bonusText2.textWidth + 10;
						pic2.y = bonusText2.y;
						addChild(pic2);
						break;
					case Stock.COINS:
						var pic3:Bitmap = new Bitmap();
						pic3.bitmapData = UserInterface.textures.coinsIcon;
						pic3.smoothing = true;
						pic3.scaleX = pic3.scaleY = 0.7;
						pic3.x = settings.width - 130;
						pic3.y = 80;
						addChild(pic3);
						
						var bonusText3:TextField;
						bonusText3 = Window.drawText(Numbers.moneyFormat(item.price[bonus]), {
							color:		0xfede3b,
							borderColor:0x874509,
							fontSize:	24,
							textAlign:	'left'
						});
						bonusText3.x = pic3.x + pic3.width + 10;
						bonusText3.y = pic3.y;
						addChild(bonusText3);
						break;
				}
			}
			
			var price:int = item.socialprice[App.social];
			var priceLabel:TextField = Window.drawText(Payments.price(item.socialprice[App.social]), {
				color:		0x7e1383,
				borderColor:0xffffff,
				fontSize:	24
			});
			priceLabel.width = priceLabel.textWidth + 5;
			priceLabel.x = (settings.width - priceLabel.textWidth) / 2;
			priceLabel.y = 155;
			addChild(priceLabel);
			
			if (App.isSocial('MX')) {
				var mxLogo:Bitmap = new Bitmap(UserInterface.textures.mixieLogo);
				mxLogo.scaleX = mxLogo.scaleY = 0.8;
				addChild(mxLogo);
				mxLogo.y = priceLabel.y - (mxLogo.height - priceLabel.height)/2;
				mxLogo.x = priceLabel.x-10;
				priceLabel.x = mxLogo.x + mxLogo.width + 5;
			}
			if (App.isSocial('SP')) {
				var spLogo:Bitmap = new Bitmap(UserInterface.textures.fantsIcon);
				addChild(spLogo);
				spLogo.y = priceLabel.y - (spLogo.height - priceLabel.height)/2;
				spLogo.x = priceLabel.x-10;
				priceLabel.x = spLogo.x + spLogo.width + 5;
			}
		}
		
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
					icon: 		Config.getIcon(item.type, item.view),
					type:		buyObject.type,
					count: 		buyObject.count + ((App.data.money.enabled && App.data.money.date_to > App.time)?buyObject.extra:0)
				};
			}else if (App.social == 'FB') {
				object = {
					id:		 	buyObject.id,
					type:		item.type,
					icon: 	Config.getIcon(item.type, item.view),
					callback: function():void {
						App.user.stock.add(buyObject.id, 1);
						App.user.stock.unpack(buyObject.id, function(bonus:Object):void {
							flyBonus(bonus);
							//Treasures.bonus(Treasures.convert(bonus), new Point(buyBttn.x, buyBttn.y));
						});
					}
				};
			}else {
				object = {
					money: 	buyObject.type,
					type:	'item',
					icon: 	Config.getIcon(item.type, item.view),
					item:	buyObject.type+"_"+buyObject.id,
					votes:	buyObject.votes,
					count: 	buyObject.count + ((App.data.money.enabled && App.data.money.date_to > App.time)?buyObject.extra:0),
					title:	buyObject.title,
					callback: function():void {
						App.user.stock.add(buyObject.id, 1);
						App.user.stock.unpack(buyObject.id, function(bonus:Object):void {
							flyBonus(bonus);
							//Treasures.bonus(Treasures.convert(bonus), new Point(buyBttn.x, buyBttn.y));
						});
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
					var flagCont:LayerX = new LayerX();
					var _point:Point = new Point(flagCont.x, flagCont.y);
					var itm:BonusItem = new BonusItem(reward[0], 1);
					itm.cashMove(_point, App.self.windowContainer);
					App.user.stock.add(reward[0], 1);
				}
			}
			ExternalApi.apiBalanceEvent(object);
		}
		
		private function flyBonus(data:Object):void {
			var targetPoint:Point = Window.localToGlobal(buyBttn);
			targetPoint.y += buyBttn.height / 2;
			for (var _sID:Object in data)
			{
				var sID:uint = Number(_sID);
				var item:*;
				
				item = new BonusItem(sID, data[_sID]);
				App.user.stock.add(sID, data[_sID]);	
				item.cashMove(targetPoint, App.self.windowContainer)		
			}
			SoundsManager.instance.playSFX('reward_1');
	}
		
		private function giftEvent(e:MouseEvent):void
		{
			new AskWindow(AskWindow.MODE_GIFT, {
				target:settings.target,
				title:Locale.__e('flash:1382952380012'), 
				friendException:function(... args):void {
					trace(args);
				},
				inviteTxt:Locale.__e("flash:1395846352679"),
				desc:Locale.__e("flash:1445870280083"),
				noAllFriends:true,
				callback:onSendGift
			} ).show();
		}
		
		private function onSendGift(uid:String):void {
			var object:Object;
			if (App.social == 'YB') {				
				object = {
					id:		 	buyObject.id,
					price:		buyObject.votes,
					type:		buyObject.type,
					icon: 	Config.getIcon(item.type, item.view),
					count: 		buyObject.count + ((App.data.money.enabled && App.data.money.date_to > App.time)?buyObject.extra:0)
				};
			}else if (App.social == 'FB') {
				object = {
					id:		 	buyObject.id,
					type:		item.type,
					icon: 	Config.getIcon(item.type, item.view),
					callback: function():void {
						Gifts.send(buyObject.id, uid, 1, Gifts.SPECIAL, null);
					}
				};
			}else {
				object = {
					money: 	buyObject.type,
					type:	'item',
					icon: 	Config.getIcon(item.type, item.view),
					item:	buyObject.type+"_"+buyObject.id,
					votes:	buyObject.votes,
					count: 	buyObject.count + ((App.data.money.enabled && App.data.money.date_to > App.time)?buyObject.extra:0),
					title:	buyObject.title,
					callback: function():void {
						Gifts.send(buyObject.id, uid, 1, Gifts.SPECIAL, null);
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
					var flagCont:LayerX = new LayerX();
					var _point:Point = new Point(flagCont.x, flagCont.y);
					var itm:BonusItem = new BonusItem(reward[0], 1);
					itm.cashMove(_point, App.self.windowContainer);
					App.user.stock.add(reward[0], 1);
				}
			}
			ExternalApi.apiBalanceEvent(object);
		}
		
		public function hasExtra():Boolean {
			var isExtra:Boolean = false;
			if (buyObject.extra && buyObject.extra > 0 && (App.time >= App.data.money.date_from && App.time < App.data.money.date_to && App.data.money.enabled == 1) || App.user.money > App.time) {
				isExtra = true;
				settings.isActionGained = true;
			}
			
			return isExtra;
		}		
		
		public function dispose():void {
			
		}
		
	}

}