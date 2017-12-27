package wins.elements 
{
	import buttons.Button;
	import buttons.ImageButton;
	import buttons.MoneyButton;
	import com.flashdynamix.motion.extras.BitmapTiler;
	import com.greensock.TweenMax;
	import core.Load;
	import core.Log;
	import core.Numbers;
	import core.Post;
	import core.TimeConverter;
	import core.Size;
	import flash.display.PixelSnapping;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import ui.Cursor;
	import ui.Hints;
	import ui.UserInterface;
	import units.Anime;
	import units.Character;
	import units.Factory;
	import units.Field;
	import units.Plant;
	import units.Techno;
	import units.Unit;
	import units.WorkerUnit;
	import wins.HeroWindow;
	import wins.ShopWindow;
	import wins.SimpleWindow;
	import wins.TravelWindow;
	import wins.UndergroundWindow;
	import wins.Window;
	import wins.WorldsWindow;
	import helpers.ExceptionsDefinitions;
	
	public class ShopItemNew extends LayerX {
		//flist открывать после
		public static const AFTER_QUEST:int = 0;
		
		// Тип поиска
		public const LAND:uint = 1;
		public const TERRITORY:uint = 2;
		
		public var item:*;
		public var background:Bitmap;
		public var bitmap:Bitmap;
		public var title:TextField;
		private var timerText:TextField;
		private var neededLabel:TextField;
		private var openText:TextField;
		public var priceBttn:Button;
		private var openBttn:MoneyButton;
		private var findBttn:Button;
		public var window:*;
		
		public var onBuyAction:Function;
		
		private var preloader:Preloader;
		private var countOnMap:int = 0;
		private var expire:int;
		
		public function ShopItemNew(item:*, window:*) {
			init(item, window);
			drawBacking();
			
			if (!onBuyActionFounded())
				return;
			
			if (sid == 1333)
				trace();
			loadPreview();
			drawItemTip();
			drawTitle();
			
			countOnMap = Map.countOnMap(item);
			
			drawItemStatus();
			drawAdditionalElements();
			
		}
		
		
		/**
		 * Storage ID
		 */
		public function get sid():int {
			return item.sid;
		}
		
		/**
		 * Инициализвция
		 * @param	item
		 * @param	window
		 */
		private function init(item:*, window:*):void
		{
			this.item = item;
			this.window = window;
			
			if (item.expire) {
				if (item.expire is int)
					expire = item.expire;
				else if (item.expire.hasOwnProperty(App.social) && expire is int)
					expire = expire;
			}
		}
		
		private function drawExpireTimer():void
		{
			if (expire) {
				if (expire > App.time) {
					drawTimer();
				} else {
					if (priceBttn) priceBttn.state = Button.DISABLED;
				}
			}
			
		}
		
		private function drawAdditionalElements():void
		{
			if (ExceptionsDefinitions.TYPES[4].indexOf(item.type) > -1 && item.hasOwnProperty('outs'))
				drawOuts();
			
			if (item['new'] == 1) {
				setNew();
			}
			
			if (window is ShopWindow) {
				if (window.currentMarket != ShopWindow.UPDATE || window.currentMarket != ShopWindow.UPDATE_ITEMS) {
					if (ShopWindow.shop[ShopWindow.UPDATE] && ShopWindow.shop[ShopWindow.UPDATE][0] && ShopWindow.shop[ShopWindow.UPDATE][0].data) {
						for each(var itm:Object in ShopWindow.shop[ShopWindow.UPDATE][0].data) {
							if (itm.sid == sid)
								setNew();
						}
					}
				}
			}
			
			if (ExceptionsDefinitions.TYPES[2].indexOf(item.type) > -1)
				setGold();
			
			if (ExceptionsDefinitions.TYPES[3].indexOf(item.type) > -1)
				drawTimeField();
			
			if (ExceptionsDefinitions.TYPES[5].indexOf(item.type) > -1 && App.isSocial('YB','MX','AI','GN'))
				drawHelp();
			
		}
		
		private function drawItemStatus():void
		{
			
			// Cbuilding потомки
			if (item.attachTo) {
				if (item.attachTo.length > 0) {
					var list:Array = Map.findUnits(item.attachTo);
					for (var i:int = 0; i < list.length; i++) {
						if (list[i].slotsCount > list[i].slotsBusy) {
							onBuyAction = list[0].buyItem;
							break;
						}
					}
				}
				
				// Если функция возврата не заполнена - ничего не рисовать
				if (onBuyAction == null) {
					//load();
					return;
				}
			}
			
			if (isExpired())
				return;
			
			if (unableOnMap())
				return;
				
			if (globalLimit()) {
				drawTextBought();
				return;
			}
			
			if (localLimit()) {
				drawTextBought();
				return;
			}
			
			if (unableOnlevel())
				return;
			
			if (unableOnQuest())
				return;
			
			if (!price && !socialprice)
				return;
			
			
			drawPriceBttn();
		}
		
		
		
		/**
		 * Цена
		 */
		private var __price:Object;
		public function get price():Object {
			if (__price)
				return __price;
			
			if (item.price)
				__price = item.price;
			
			if (item.currency)
				__price = item.currency;
			
			if (item.instance && item.instance.cost)
				__price = Storage.price(sid);
			
			return __price;
		}
		
		
		
		/**
		 * Цена
		 */
		public function get socialprice():int {
			if (item.socialprice && item.socialprice[App.social] > 0)
				return item.socialprice[App.social];
			
			return 0;
		}
		
		
		
		
		/**
		 * Доступен для покупки на этой карте (из перечня того что есть в карте на этой территории)
		 */
		private function unableOnMap():Boolean {
			
			var world:Object = App.data.storage[App.user.worldID];
			var shop:Object = world.shop;
			var lands:Array = [];
			var market:*;
			
			if (!shop)
				return true;
			
			if (item.type == Storage.LANDS) {
				if (sid != App.user.worldID) {
					drawFindButton(TERRITORY);
					return true;
				}
			}
			
			// Поиск объекта в локальном списке
			for (var i:int = 0; i < App.user.lands.length; i++) {
				var landID:int = App.user.lands[i];
				var land:Object = App.data.storage[landID];
				
				// В магазине
				if (land.stacks) {
					for each(var ID:* in land.stacks) {
						if (ID == sid)
							lands.push(landID);
					}
				}
				
				// На территории
				if (land.objects) {
					for each(ID in land.objects) {
						if (ID == sid)
							lands.push(landID);
					}
				}
			}
			if (lands.length > 0) {
				if (lands.indexOf(App.user.worldID) == -1) {
					drawFindButton(LAND);
					trace(sid, 'По магазину. По острову.');
					return true;
				}
				
				return false;
			}
			
			// Проверяем сперва магазин текущей локации
			for (market in shop) {
				if (market == ShopWindow.UPDATE) continue;
				if (shop[market][sid] == 1)
					return false;
			}
			
			// Проверяем все магазины локаций
			for (i = 0; i < App.user.lands.length; i++) {
				landID = App.user.lands[i];
				land = App.data.storage[landID];
				for (market in land.shop) {
					if (market == ShopWindow.UPDATE) continue;
					if (land.shop[market][sid] == 1) {
						lands.push(landID);
						
						if (landID == App.user.worldID)
							return false;
					}
				}
			}
			
			// Отобразить локации на которых оно есть
			drawLands(lands);
			
			trace(sid, 'По магазину');
			return true;
		}
		
		
		
		/**
		 * Время действия
		 */
		private var expireText:TextField;
		private function isExpired():Boolean {
			
			if (expire && expire < App.time) {
				
				if (expire > App.time) {
					drawExpireTimer();
				}else {
					
					expireText = Window.drawText(Locale.__e("flash:1466147553176"), {
						color:			0xfff2dd,
						borderColor:	0x7a602f,
						borderSize:		4,
						fontSize:		20,
						autoSize:		"center"
					});
					addChild(expireText);
					expireText.x = (background.width - expireText.textWidth) / 2;
					expireText.y = background.height - expireText.textHeight - 20;
					
					bitmap.alpha = 0.5;
				}
				
				return true;
			}
			
			return false;
		}
		
		
		
		/**
		 * Общий лимит покупки
		 */
		private function globalLimit():Boolean {
			if (sid == 3164 )
				trace();
			if (!item.gcount)
				return false;
			
			var count:int = Storage.shopLimit(sid);
			var limit:int = item.gcount;
			
			drawCountLabel(count, limit);
			
			if (!Storage.shopLimitCanBuy(sid) && count >= limit) {
				trace(sid, 'По лимиту покупки');
				return true;
			}
			
			return false;
		}
		
		
		
		/**
		 * Ограничение на карте
		 */
		private function localLimit():Boolean {
			
			//if (item.type == 'Tribute' && item.count > 0) {
				//drawCountLabel(countOnMap, item.count);
				//
				//if (item.count <= countOnMap)
					//return true;
				//
			//}else 
			if (sid == 3164 )
				trace();
			if (item.limit > 0) {
				drawCountLabel(countOnMap, item.limit);
				
				if (item.limit <= countOnMap)
					return true;
				
			}else if (item.instance && item.instance.limit && Numbers.countProps(item.instance.limit) > 0) {
				
				var value:int = Storage.maxOfKey(item.instance.limit, countOnMap + 1);
				if (!value)
					return false;
					
				var limit:int = Numbers.countProps(item.instance.limit) + Storage.maxOfKey(item.instance.limit, countOnMap + 1);
				
				drawCountLabel(countOnMap, limit);
				
				if (limit <= countOnMap)
					return true;
				
			}
			
			return false;
			
		}
		
		
		
		/**
		 * Не доступен до уровня
		 */
		private function unableOnlevel():Boolean {
			
			if (item.level && item.level > App.user.level && payForBuy < 1) {
				drawNeedTxt(item.level, 10, 190);
				drawOpenBttn();
				return true;
			}else if (	item.instance &&
						item.instance.level &&
						item.instance.level[countOnMap + 1] &&
						item.instance.level[countOnMap + 1] > App.user.level &&
						payForBuy < countOnMap + 1) {
				drawNeedTxt(item.instance.level[countOnMap + 1], 10, 190);
				drawOpenBttn();
				
				return true;
			}
			
			return false;
			
		}
		
		/**
		 * Заплатил за то, чтоб купить
		 */
		public function get payForBuy():int {
			//if (item.instance && App.user.shop[sid] >= countOnMap + 1)
				//return item.level;
			
			return (App.user.shop && App.user.shop[sid]) ? App.user.shop[sid] : 0;
		}
		
		
		
		/**
		 * Не доступен до квеста
		 */
		private function unableOnQuest():Boolean {
			
			return false;
			
		}
		
		
		
		private var landsContainer:Sprite;
		private function drawLands(lands:Array):void {
			
			if (/*!(Config.admin || App.self.flashVars.debug == 1) ||*/ !lands || lands.length == 0) return;
			lands.sort();
			
			clearLands();
			
			landsContainer = new Sprite();
			addChild(landsContainer);
			
			for (var i:int = 0; i < 2 && i < lands.length; i++) {
				var landItem:LandItem = new LandItem(lands[i], sid, window);
				landItem.x = landsContainer.numChildren * 48;
				landsContainer.addChild(landItem);
			}
			
			landsContainer.x = background.width * 0.5 - landsContainer.width * 0.5;
			landsContainer.y = background.height - 40;
		}
		private function clearLands():void {
			while (landsContainer && landsContainer.numChildren) {
				var child:* = landsContainer.getChildAt(0);
				if (child.hasOwnProperty('dispose') && child.dispose != null && child.dispose is Function)
					child.dispose();
				
				landsContainer.removeChild(child);
			}
		}
		
		
		
		
		
		// Куплено
		private var boughtText:TextField;
		private function drawTextBought():void {
			boughtText = Window.drawText(Locale.__e("flash:1396612413334"), {
				color:			0xfff2dd,
				borderColor:	0x7a602f,
				borderSize:		4,
				fontSize:		24,
				autoSize:		"center"
			});
			addChild(boughtText);
			boughtText.x = (background.width - boughtText.textWidth)/2;
			boughtText.y = background.height - boughtText.textHeight - 20;
			
			bitmap.alpha = 0.5;
		}
		
		
		// 1 из 3
		private var countLabel:TextField;
		private function drawCountLabel(buyed:int = 0, limit:int = 0):void {
			if (buyed > limit)
				buyed = limit;
			
			//if (countLabel)
				//return;
			
			if (countLabel && countLabel.parent) {
				countLabel.parent.removeChild(countLabel);
				countLabel = null;
			}
			
			if (limit <= 0)
				return;
			
			countLabel =  Window.drawText(buyed.toString() + '/' + limit.toString(), {
				fontSize:		26,
				color:			0xffffff,
				borderColor:	0x2D2D2D,
				autoSize:		'center'
			});
			countLabel.x = 100;
			countLabel.y = 120;
			addChild(countLabel);
		}
		
		
		// Поиск
		private var findTarget:uint;
		private function drawFindButton(target:uint):void {
			
			findTarget = target;
			
			findBttn = new Button({
				caption			:Locale.__e("flash:1405687705056"),
				fontSize		:18,
				radius      	:10,
				fontColor:		0xffffff,
				fontBorderColor:0x475465,
				borderColor:	[0xfff17f, 0xbf8122],
				bgColor:		[0x75c5f6,0x62b0e1],
				bevelColor:		[0xc6edfe,0x2470ac],
				width			:110,
				height			:35,
				fontSize		:15
			});
			findBttn.x = background.x + background.width / 2 - findBttn.width / 2;
			findBttn.y = 185;
			findBttn.addEventListener(MouseEvent.CLICK, onFind);
			addChild(findBttn);
		}
		private function onFind(e:MouseEvent):void {
			if (!findBttn) return;
			
			switch(findTarget) {
				case LAND:
					
					Find.find(sid);
					window.close();
					
					break;
				default:
					Find.find(sid);
					window.close();
			}
		}
		
		
		
		/**
		 * Tip
		 */
		private function drawItemTip():void
		{
			var defText:String = '';
			
			if ((item.type == 'Building' || item.type == 'Tstation') && item.devel.craft)
			{
				defText = Storage.getCrafts(item);
			}
			
			updateTip(item.title, item.description);
			
			if (defText.length > 0 && ExceptionsDefinitions.ITEMS[4].indexOf(item.type) == -1) {
				updateTip(item.title, Locale.__e('flash:1404823388967', [defText]));
			}
		}
		private function updateTip(tipTitle:String, tipText:String):void
		{
			tip = function():Object {
				return {
					title:tipTitle + ((Config.admin) ? sid.toString() : ''),
					text:tipText
				};
			};
		}
		
		
		/**
		 * Backing
		 */
		private var sprite:Sprite;
		private function drawBacking() : void
		{
			var backing:String = (item.hasOwnProperty('backview') && item.backview != '') ? item.backview : 'itemBacking';
			
			background = Window.backing(170, 210, 10, backing);
			addChild(background);
			
			sprite = new Sprite();
			addChild(sprite);
			
			if (Config.admin)
				sprite.addEventListener(MouseEvent.CLICK, onItemClick);
			
			bitmap = new Bitmap();
			sprite.addChild(bitmap);
		}
		
		
		
		private function loadPreview():void
		{
			var link:String = Config.getIcon(item.type, item.preview);
			
			if (ExceptionsDefinitions.TYPES[6].indexOf(item.type) > -1) {
				link = Config.getSwf(item.type, item.view);
			}else {
				if (item.type == 'Plant') {
					var out:Object = Plant.materialObject(item.sid);
					if (out) 
						link = Config.getIcon(out.type, out.preview);
				}
			}
			
			Load.loading(link, onLoad);
			
			drawPreloader();
		}
		
		private function onLoad(data:*):void {
			if (preloader) {
				if (sprite.contains(preloader)) sprite.removeChild(preloader);
				preloader = null;
			}
			
			if (data.hasOwnProperty('animation')) {
				drawAnimation(data);
			}else {
				drawPreview(data);
			}
		}
		
		private var anime:Anime;
		private function drawAnimation(swf:Object):void {
			anime = new Anime(swf, { w:background.width - 20, h:background.height - 40 } );
			anime.x = background.width * 0.5 - anime.width * 0.5;
			anime.y = background.height * 0.5 - anime.height * 0.5;
			sprite.addChild(anime);
		}
		private function drawPreview(bmp:Bitmap):void {
			bitmap.bitmapData = bmp.bitmapData;
			bitmap.smoothing = true;
			Size.size(bitmap, background.width * 0.8, background.height * 0.8);
			bitmap.x = background.width * 0.5 - bitmap.width * 0.5;
			bitmap.y = background.height * 0.5 - bitmap.height * 0.5;
		}
		
		private function onBuyActionFounded():Boolean
		{
			// Cbuilding потомки
			if (item.attachTo) {
				if (item.attachTo.length > 0) {
					var list:Array = Map.findUnits(item.attachTo);
					for (var i:int = 0; i < list.length; i++) {
						if (list[i].slotsCount > list[i].slotsBusy) {
							onBuyAction = list[0].buyItem;
							break;
						}
					}
				}
				
				return (onBuyAction != null)?true:false;
			}
			
			return true;
		}
		
		private function drawPreloader():void
		{
			if (bitmap.bitmapData || anime) return;
			
			preloader = new Preloader();
			preloader.x = (background.width)/ 2;
			preloader.y = (background.height)/ 2 - 15;
			sprite.addChild(preloader);
		}
		
		private function drawTimer():void {
			if (item.type == 'Happy') {
				var tID:int = 0;
				for (var topID:* in App.data.top) {
					if (App.data.top[topID].target == item.sid) {
						tID = topID;
						break;
					}
				}
				if (tID == 0) return;
			}
			timerText = Window.drawText(TimeConverter.timeToStr(expire - App.time), {
				color: 0xfff200,
				borderColor: 0x680000,
				fontSize: 26,
				textAlign: 'center',
				width: background.width
			});
			timerText.y = title.y + title.textHeight + 5;
			addChild(timerText);
			App.self.setOnTimer(updateTimer);
		}
		private function updateTimer():void {
			if (!timerText) return;
			
			var text:String = TimeConverter.timeToStr(expire - App.time);
			timerText.text = text;
			
			if (expire - App.time <= 0) {
				timerText.visible = false;
				App.self.setOffTimer(updateTimer);
				
				if (priceBttn)
					priceBttn.state = Button.DISABLED;
			}
		}
		
		private function drawHelp():void {
			var searchBttn:ImageButton = new ImageButton(UserInterface.textures.lens);
			searchBttn.x = 130;
			searchBttn.y = 10;
			searchBttn.addEventListener(MouseEvent.CLICK, showHelp);
			addChild(searchBttn);
		}
		
		private function showHelp(e:MouseEvent):void {
			var text:String;
			if (item.sid == 483)
				text = Locale.__e('flash:1449649687794');
			else if (item.sid == 976) {
				text = Locale.__e('flash:1449649890043');
			}else if (item.sid == 2018) {
				text = Locale.__e('flash:1465828699513');
			}
			new SimpleWindow( {
				width:450,
				height:600,
				label:SimpleWindow.ATTENTION,
				text:text,
				title:item.title,
				popup:true
			}).show();
			return;
		}
		
		private function drawVipUI():void 
		{
			if (App.user.stock.data.hasOwnProperty(item.sid) && App.user.stock.data[item.sid] > App.time) {
				boughtText = Window.drawText('', {
					color:0xfff2dd,
					borderColor:0x7a602f,
					borderSize:4,
					fontSize:24,
					textAlign:'center',
					width:background.width - 20
				});
				boughtText.x = (background.width - boughtText.width) / 2;
				boughtText.y = background.height - boughtText.textHeight - 20;
				addChild(boughtText);
				App.self.setOnTimer(vipTimer);
				vipTimer();
				
				if (!hasEventListener(Event.REMOVED_FROM_STAGE))
					addEventListener(Event.REMOVED_FROM_STAGE, onRemoveFromStage);
				
			}else {
				if (boughtText) {
					removeChild(boughtText);
					boughtText = null;
				}
				drawPriceBttn();
				App.self.setOffTimer(vipTimer);
			}
		}
		
		private function vipTimer():void {
			var time:int = App.user.stock.count(sid) - App.time;
			if (time <= 0) {
				drawVipUI();
			}else{
				boughtText.text = TimeConverter.timeToStr(time);
			}
		}
		
		private function onRemoveFromStage(event:Event):void {
			removeEventListener(Event.REMOVED_FROM_STAGE, onRemoveFromStage);
			
			if (item.type == 'Vip')
				App.self.setOffTimer(vipTimer);
		}
		
		private function drawOuts():void 
		{
			for (var key:* in item.outs) break;
			
			var cont:LayerX = new LayerX();
			var iconOut:Bitmap = new Bitmap();
			addChild(cont);
			cont.addChild(iconOut);
			
			cont.tip = function():Object { 
				return {
					title:App.data.storage[key].title,
					text:App.data.storage[key].description
				};
			}
			
			var txtCount:TextField = Window.drawText("x" + String(item.capacity), {
				color:0xffffff,
				borderColor:0x2b2929,
				textAlign:"center",
				autoSize:"center",
				fontSize:24
			});
			txtCount.width = txtCount.textWidth;
			
			priceLabel.y += 8;
			
			Load.loading(Config.getIcon(App.data.storage[key].type, App.data.storage[key].preview), function(data:*):void {
				iconOut.bitmapData = data.bitmapData;
				iconOut.scaleX = iconOut.scaleY = 0.36;
				iconOut.smoothing = true;
				
				iconOut.x = background.width - iconOut.width - 44;
				iconOut.y = background.height - iconOut.height/2 - 66;
				
				txtCount.x = iconOut.x + iconOut.width;
				txtCount.y = iconOut.y + (iconOut.height - txtCount.textHeight) / 2;
				addChild(txtCount);
			});
		}
		
		
		
		/**
		 * Ленточки (Новое, Золото)
		 */
		private var stripe:Bitmap;
		public function setGold():void {
			if (stripe) return;
			
			stripe = new Bitmap(Window.textures.goldRibbon);
			stripe.x = 2;
			stripe.y = 3;
			addChild(stripe);
		}
		public function setNew():void {
			stripe= new Bitmap(Window.textures.stripNew);
			stripe.x = 2;
			stripe.y = 3;
			addChildAt(stripe, 2);
		}
		
		private function drawTimeField():void {
			var container:Sprite = new Sprite();
			addChild(container);
			var icon:Bitmap = new Bitmap(Window.textures.timerSmall);
			container.addChild(icon);
			var time:TextField = Window.drawText(int(item.time/3600)+Locale.__e('flash:1382952379728'),{
				color:			0x6d4b15,
				borderColor:	0xfcf6e4,
				fontSize:		16,
				textAlign:		'left'
			});
			container.addChild(time);
			
			time.x = icon.width;
			time.y = (icon.height - time.textHeight) / 2;
			time.width = time.textWidth + 5;
			
			container.x = background.width - container.width - 15;
			container.y = title.y + title.height;
		}
		
		
		/**
		 * Очистка элемента магазина
		 */
		public function dispose():void {
			
			if (sprite)
				sprite.removeEventListener(MouseEvent.CLICK, onItemClick);
			
			if(priceBttn != null){
				priceBttn.removeEventListener(MouseEvent.CLICK, onBuyEvent);
				priceBttn.dispose();
				priceBttn = null;
			}
			
			if(openBttn != null){
				openBttn.removeEventListener(MouseEvent.CLICK, onOpenEvent);
				openBttn.dispose();
				openBttn = null;
			}
			
			if (findBttn) {
				findBttn.removeEventListener(MouseEvent.CLICK, onFind);
				findBttn.dispose();
				findBttn = null;
			}
			
			if (Quests.targetSettings != null) {
				Quests.targetSettings = null;
				if (App.user.quests.currentTarget == null) {
					QuestsRules.getQuestRule(App.user.quests.currentQID, App.user.quests.currentMID);
				}
			}
			
			if (timerText)
				App.self.setOffTimer(updateTimer);
			
			clearLands();
			
			removeChildren();
		}
		
		public function drawTitle():void {
			title = Window.drawText(String(item.title), {
				color:0x814f31,
				borderColor:0xfaf9ec,
				textAlign:"center",
				autoSize:"center",
				fontSize:23,
				textLeading:-6,
				multiline:true,
				wrap:true,
				width:background.width - 20
			});
			title.y = 10;
			title.x = (background.width - title.width)/2;
			addChild(title);
		}
		
		public function drawBuyedLabel():void {
			var label:TextField = Window.drawText(Locale.__e("flash:1382952380080"), {
				color:0x4A401F,
				borderSize:0,
				fontSize:14,
				autoSize:"center"
			});
			addChild(label);
			label.x = (background.width - label.width)/2;
			label.y = 152;
		}
		
		public var priceLabel:PriceLabelShop;
		public function drawPriceBttn():void {
			
			var bttnSettings:Object = {
				caption:	Locale.__e("flash:1382952379751"),
				fontSize:	27,
				width:		136,
				height:		42,
				hasDotes:	false
			};
			var countCurrency:int = 0;
			
			if (item.hasOwnProperty('socialprice') && item.socialprice.hasOwnProperty(App.social)) {
				
				priceBttn = new Button( {
					caption:	Payments.price(item.socialprice[App.social]),
					width:		136,
					height:		42,
					fontSize:	26,
					shadow:		true,
					type:		"green"
				});
				priceBttn.x = background.width/2 - priceBttn.width/2;
				priceBttn.y = background.height - 30;
				addChild(priceBttn);
				
				priceBttn.addEventListener(MouseEvent.CLICK, onSocialBuyClick);
				return;
			}
			
			for (var priceSID:* in price) {
				countCurrency = price[priceSID];
				break;
			}
			priceLabel = new PriceLabelShop(price);
			
			if (!priceLabel) return;
			
			if (priceSID == Stock.FANT || item.sid == 461){
				bttnSettings["bgColor"] = [0x9adc60, 0x5d9f3e];
				bttnSettings["borderColor"] = [0xbfeea8, 0x48882a];
				bttnSettings["bevelColor"] = [0xbfeea8, 0x48882a];
				bttnSettings["fontColor"] = 0xfbfaf6;
				bttnSettings["fontBorderColor"] = 0x3c7a24;
				bttnSettings["diamond"] = true;
				bttnSettings["countText"] = countCurrency;
			}
			
			priceLabel.x = 12;
			priceLabel.y = 168;
			priceLabel.scaleX = 1.2;
			priceLabel.scaleY = 1.1;
			
			addChild(priceLabel);
			
			priceBttn = new Button(bttnSettings);
			priceBttn.x = background.width/2 - priceBttn.width/2;
			priceBttn.y = background.height - priceBttn.height + 15;
			priceBttn.addEventListener(MouseEvent.CLICK, onBuyEvent);
			addChild(priceBttn);
			
			//время созревания растений
			if (item.market == 2) {
				var timeIcon:Bitmap = new Bitmap(Window.textures.timer);
				timeIcon.scaleX = timeIcon.scaleY = 0.7;
				timeIcon.smoothing = true;
				timeIcon.x = priceBttn.x + priceBttn.width / 2 + 10;
				timeIcon.y = priceBttn.y - timeIcon.height - 3;
				addChild(timeIcon);
				
				var maturationTime:int;
				
				if (item.hasOwnProperty('levelTime') && item.hasOwnProperty('levels')) {
					maturationTime = item.levelTime * item.levels;
				}
				
				if (item.hasOwnProperty('devel')) {
					if(item.devel.hasOwnProperty('req')) {
						maturationTime = item.devel.req[1].t;
					}
				}
				
				var textSize:int = 20;
				do {
					var timeLabel:TextField = Window.drawText(TimeConverter.timeToCuts(maturationTime, false, true), {
						fontSize:textSize,
						autoSize:"left",
						textAlign:"center",
						multiline:true,
						color:0xffffff,
						borderColor:0x6a351c,
						shadowColor:0x6a351c,
						shadowSize:1
					});
					if (textSize <= 14) {
						timeLabel.wordWrap = true;
						timeLabel.width = 41;
					} else {
						timeLabel.width = timeLabel.textWidth + 5;
					}
					timeLabel.x = timeIcon.x + timeIcon.width + 3;
					timeLabel.y = timeIcon.y + 8;
					textSize -= 1;
				} while (timeLabel.textWidth >= 40);
				addChild(timeLabel);
			}
			
		}
		
		
		private var openSprite:Sprite = new Sprite();
		private function drawNeedTxt(lvl:int, posX:int, posY:int):void
		{
			addChild(openSprite);
			openSprite.y = 170;
			
			neededLabel = Window.drawText(Locale.__e("flash:1382952380085",[lvl]), {
				color:0xc42f07,
				fontSize:19,
				borderColor:0xfcf5e5,
				textAlign:"center",
				borderSize:3
			});
			
			neededLabel.width = neededLabel.textWidth + 4;
			neededLabel.x = (background.width - neededLabel.width) / 2;
			neededLabel.y =  posY - 32;
			addChild(neededLabel);
		}
		
		public function drawOpenBttn():void {
			
			var settings:Object = { 
				fontSize:20, 
				autoSize:"left",
				color:0xc5f68f,
				borderColor:0x3f670f
			};
			
			var skip:int = 0;
			if (item.hasOwnProperty('skip') && item.skip > 0){
				skip = item.skip;
			}else if (item.instance && item.instance.p) {
				skip = Storage.maxOfKey(item.instance.p, Storage.instanceGet(sid) + 1);
			}
			
			if (skip <= 0)
				return;
			
			openBttn = new MoneyButton({
				caption:	Locale.__e("flash:1382952379890"),
				countText:	skip,
				width:		136,
				height:		42,
				fontSize:	24,
				radius:		20
			});
			
			openBttn.countLabel.x -= 4;
			openBttn.x = (background.width - openBttn.settings.width)/2;
			openBttn.y = background.height - openBttn.height/2 - 4;
			openBttn.addEventListener(MouseEvent.CLICK, onOpenEvent);
			addChild(openBttn);
		}
		
		private function get openSkip():int {
			if (item.hasOwnProperty('skip') && item.skip > 0){
				return item.skip;
			}else if (item.instance && item.instance.p) {
				return Storage.maxOfKey(item.instance.p, Storage.instanceGet(sid) + 1);
			}
			
			return 0;
		}
		private function onOpenEvent(e:MouseEvent):void {

			if (!openBttn || openBttn.mode == Button.DISABLED) return;
			openBttn.state = Button.DISABLED;
			
			if (openSkip == 0) {
				new SimpleWindow( {
					title:		item.title,
					text:		Locale.__e('flash:1479374513247')	// Не найдена цена открытия
				}).show();
				return;
			}
			
			if (App.user.stock.take(Stock.FANT, openSkip)) {
				Hints.minus(Stock.FANT, openSkip, Window.localToGlobal(e.currentTarget), false, window);
				
				Post.send( {
					ctr:	'user',
					act:	'open',
					uID:	App.user.id,
					sID:	item.sid,
					wID:	App.user.worldID,
					iID:	(item.instance) ? countOnMap + 1 : 1
				}, function(error:*, data:*, params:*):void {
					if (error) return;
					
					App.user.shop[item.sid] = (item.instance) ? countOnMap + 1 : 1;
					window.contentChange();
				});
			}else {
				openBttn.state = Button.NORMAL;
			}
		}
		
		private function onSocialBuyClick(e:MouseEvent):void {
			if (e.currentTarget.mode == Button.DISABLED) return;
			
			Payments.buy( {
				type:			'energy',
				id:				item.sid,
				price:			int(item.socialprice[App.social]),
				count:			1,
				title: 			Locale.__e('flash:1396521604876'),
				description: 	Locale.__e('flash:1393581986914'),
				callback:		function():void {
					Log.alert('onBuyComplete ShopItem');
					App.user.stock.add(item.out, item.count);
					onBuyComplete(0,0);
				},
				error:			function():void {
					window.close();
				},
				icon:			Config.getIcon(item.type, item.preview)
			});
		}
		
		private function onBuyEvent(e:MouseEvent):void {
			if (priceBttn.mode == Button.DISABLED) return;
			
			if ([2371].indexOf(int(item.sid)) != -1 && [112,1907,1569].indexOf(int(App.user.worldID)) == -1) {
				new SimpleWindow ( {
					text: Locale.__e('flash:1397124712139', [App.data.storage[item.sid].title]),
					title: Locale.__e('flash:1382952380254'),
					popup: true,
					confirm:function():void {
						Window.closeAll();
						TravelWindow.show( { findTargets:[112,1907,1569] } );
					}
				}).show();
				return;
			}
			if ((item.sid == 1970 || item.sid == 2258 || item.sid == 2090) && App.user.worldID != User.HOME_WORLD) {
				new SimpleWindow ( {
					text: Locale.__e('flash:1455190874281'),
					title: Locale.__e('flash:1382952380254'),
					popup: true,
					confirm:function():void {
						Window.closeAll();
						TravelWindow.show( { find:[112] } );
					}
				}).show();
				return;
			}
			
			if (item.sid == 1302 && App.user.worldID != User.HOME_WORLD) {
				new SimpleWindow( {
					title:item.title,
					text: Locale.__e('flash:1397124712139', item.title),
					popup:true
				}).show();
				return;
			}
			
			ShopWindow.currentBuyObject = { type:item.type, sid:item.sid };
			
			// Локальный магазин
			if (onBuyAction != null) {
				onBuyAction(item.sid);
				window.close();
				return;
			}
			
			var unit:Unit;
			if (item.type == 'Golden' && item.hasOwnProperty('capacity') && item.capacity != 0 && item.capacity != '') {
				new SimpleWindow( {
					popup:true,
					height:340,
					title:item.title,
					text:Locale.__e('flash:1475653349983', [item.title, String(item.capacity)]),
					confirm:function():void {
						Window.closeAll();
						unit = Unit.add( { sid:item.sid, buy:true } );
						unit.move = true;
						App.map.moved = unit;
					}
				}).show();
				return;
			}
			
			
			switch(item.type)
			{
				case "Material":
				case 'Vip':
					App.user.stock.buy(item.sid, 1);
					break;
				case "Boost":
				case "Energy":
					var sett:Object = null;
					if (App.data.storage[item.sid].out == Techno.TECHNO) {
						sett = { 
							ctr:'techno',
							wID:App.user.worldID,
							x:App.map.heroPosition.x,
							z:App.map.heroPosition.z,
							capacity:1
						};
						App.user.stock.pack(item.sid, onBuyComplete, function():void {
						}, sett);
					}else {
						App.user.stock.pack(item.sid);
					}
					break;
				case "Plant":
					unit = Unit.add( { sid:181, pID:item.sID, planted:0 } );
					unit.move = true;
					App.map.moved = unit;
					Cursor.material = item.sid;
					
					Field.exists = false;					
					break;
				case 'Clothing':
					new HeroWindow({find:item.sid}).show();
					break;
				case 'Animal':
					unit = Unit.add( { sid:item.sid, buy:true } );
					unit.move = true;
					App.map.moved = unit;
					break;
				case 'Decor':
					if (item.dtype == 2) {
						App.user.stock.buy(item.sid, 1);
						flyMaterial(item.sid);
						new SimpleWindow( {
							title:item.title,
							text: Locale.__e('flash:1382952379990'),
							popup:true
						}).show();
					} else {
						unit = Unit.add( { sid:item.sid, buy:true } );
						unit.move = true;
						App.map.moved = unit;
					}
					break;
				case 'Golden':
					if ((item.sid == 553 || item.sid == 554) && App.user.worldID != 555) {
						App.user.stock.buy(item.sid, 1);
						flyMaterial(item.sid);
						new SimpleWindow( {
							title:item.title,
							text: Locale.__e('flash:1382952379990'),
							popup:true
						}).show();
					} else {
						unit = Unit.add( { sid:item.sid, buy:true } );
						unit.move = true;
						App.map.moved = unit;
					}
					break;
				case 'Floors':
					{
						unit = Unit.add( { sid:item.sid, buy:true } );
						unit.move = true;
						App.map.moved = unit;
					}
					break;
				case 'Firework':
					if (item.sid == 1255 || item.sid == 1556) {
						App.user.stock.buy(item.sid, 1);
						flyMaterial(item.sid);
					} else {
						unit = Unit.add( { sid:item.sid, buy:true } );
						unit.move = true;
						App.map.moved = unit;
					}
					break;
				default:
					unit = Unit.add( { sid:item.sid, buy:true } );
					
					unit.move = true;
					App.map.moved = unit;
				break;
			}
			
			if ([2,23,55,5].indexOf(App.user.quests.currentQID) >= 0) {
				Tutorial.tutorialQuests();
			}
			
			var point:Point;
			if (item.type == "Energy") {
				point = localToGlobal(new Point(e.currentTarget.x, e.currentTarget.y));
				point.x += e.currentTarget.width / 2;
				Hints.minus(Stock.FANT, item.price[Stock.FANT], point);
				return;
			}
			
			if (item.type == 'Firework' && item.count == 0)
				return;
			
			if(item.type != "Material"){
				window.close();
			}else{
				point = localToGlobal(new Point(e.currentTarget.x, e.currentTarget.y));
				point.x += e.currentTarget.width / 2;
				Hints.minus(Stock.COINS, item.coins, point);
			}
		}
		
		public function flyMaterial(_sid:int):void
		{
			var item:BonusItem = new BonusItem(uint(_sid), 0);
			var point:Point = Window.localToGlobal(bitmap);
			point.y += bitmap.height / 2;
			item.cashMove(point, App.self.windowContainer);
		}
		
		private function onBuyComplete(sID:uint, rez:Object = null):void 
		{
			if (Techno.TECHNO == sID) {
				addChildrens(sID, rez.ids);
			}
		}
		
		private function addChildrens(_sid:uint, ids:Object):void 
		{
			var rel:Object = { };
			rel[Factory.TECHNO_FACTORY] = _sid;
			var position:Object = App.map.heroPosition;
			for (var i:* in ids){
				var unit:Unit = Unit.add( { sid:_sid, id:ids[i], x:position.x, z:position.z, rel:rel, finished:App.time + App.data.options.buyedTechnoTime } );
					(unit as WorkerUnit).born({capacity:1});
			}
		}
		
		
		/**
		 * Общая обработка
		 */
		private function onItemClick(e:MouseEvent):void {
			
			var list:Array = Map.findUnits([sid]);
			if (list.length > 0) {
				App.map.focusedOn(list[0], true);
				Window.closeAll();
			}else if (Storage.instanceMaps(sid).length > 0 && Storage.instanceMaps(sid).indexOf(App.user.worldID) == -1) {
				var mapID:int = Storage.instanceMaps(sid)[0];
				
				Window.closeAll();
				TravelWindow.show( { find:mapID } );
				
				Find.stepRequire = {
					sid:		sid,
					mapID:		mapID
				}
			}
			
		}
		
	}
}

import effects.Effect;
import flash.events.MouseEvent;
import ui.BitmapLoader;
import wins.TravelWindow;

internal class LandItem extends LayerX {
	
	private var image:BitmapLoader;
	private var worldID:int;
	private var itemID:int;
	private var window:*;
	private var info:Object;
	
	public function LandItem(worldID:int, itemID:int, window:*) {
		
		this.worldID = worldID;
		this.itemID = itemID;
		this.window = window;
		
		info = App.data.storage[worldID];
		if (!info) return;
		
		tip = function():Object {
			return { title:info.title, text:info.description };
		}
		
		image = new BitmapLoader(worldID, 44, 60);
		addChild(image);
		
		addEventListener(MouseEvent.CLICK, onClick);
		addEventListener(MouseEvent.ROLL_OVER, onOver);
		addEventListener(MouseEvent.ROLL_OUT, onOut);
	}
	
	private function onClick(e:MouseEvent):void {
		window.close();
		TravelWindow.show( { find:[worldID] } );
	}
	private function onOver(e:MouseEvent):void {
		Effect.light(this, 0.15);
	}
	private function onOut(e:MouseEvent):void {
		Effect.light(this);
	}
	
	public function dispose():void {
		removeEventListener(MouseEvent.CLICK, onClick);
		removeEventListener(MouseEvent.ROLL_OVER, onOver);
		removeEventListener(MouseEvent.ROLL_OUT, onOut);
		removeChildren();
	}
	
	
}