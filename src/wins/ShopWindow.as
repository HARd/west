package wins
{
	import adobe.utils.CustomActions;
	import api.ExternalApi;
	import buttons.MenuButton;
	import core.Load;
	import core.Numbers;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.geom.ColorTransform;
	import flash.utils.Dictionary;
	import ui.Cursor;
	import units.Animal;
	import units.Building;
	import units.Cbuilding;
	import units.Exchange;
	import units.Hero;
	import units.Plant;
	import units.Resource;
	import units.Tree;
	import units.Underground;
	import units.Walkgolden;
	import wins.elements.SearchShopPanel;
	import wins.elements.ShopItem;
	import wins.elements.ShopItemNew;
	import wins.elements.ShopMenu;

	/*
	    0 - невидимый
		1 - материалы
		2 - растения
		3 - декор
		4 - здания
		5 - персы
		6 - инструменты
		7 - дополнения
		8 - одежда
		13 - ресурсы
	*/	
	
	public class ShopWindow extends Window
	{
		
		// Типы магазинов
		public static const INVISIBLE:uint = 0;
		public static const MATERIALS:uint = 1;
		public static const PLANTS:uint = 2;
		public static const DECOR:uint = 3;
		public static const PRODUCTION:uint = 4;
		public static const IMPORTANT:uint = 7;
		public static const RESOURCES:uint = 13;
		public static const ANIMALS:uint = 14;
		public static const UPDATE:uint = 100;
		public static const UPDATE_ITEMS:uint = 101;
		
		public static var instance:ShopWindow;
		public static var shops:Object;
		public static var history:Object = { section:UPDATE, page:0 };
		
		public var icons:Array = [];
		public var items:Array = [];
		public var finded:Array = [];
		
		private var seachPanel:SearchShopPanel;
		
		private static var _currentBuyObject:Object = { type:null, sid:null };
		
		public function ShopWindow(settings:Object = null)
		{
			
			instance = this;
			
			_currentBuyObject.type = null;
			_currentBuyObject.sid = null;
			
			if (settings == null)
				settings = { };
			
			settings.section = settings.section || history.section; 
			settings.page = settings.page || history.page;
			
			settings.find = settings.find || null;
			
			settings["title"] = Locale.__e("flash:1382952379765");
			settings['fontSize'] = 46;
			
			settings["width"] = 800;
			settings["height"] = 620;
			
			settings["hasPaginator"] = true;
			settings["hasArrows"] = true;
			settings["itemsOnPage"] = 8;
			settings["returnCursor"] = false;
			
			if (App.user.quests.tutorial && App.tutorial)
				settings = App.tutorial.shopMode(settings);
			
			findTargetPage(settings);
			
			super(settings);
			
		}
		
		
		/**
		 * Общий вызов
		 * @param	settings
		 */
		public static function show(settings:Object = null):void {
			if (!ShopWindow.inited) return;
			new ShopWindow(settings).show();
		}
		
		
		
		/**
		 * Инициализация
		 */
		public static function init():void {
			
			if (shops) return;
			
			/*var temp:Object = { 0:[] };
			
			for (var lid:* in App.data.storage) {
				if (App.data.storage[lid].type == 'Lands') {
					temp[lid] = [];
				}
			}*/
			
			var mapInfo:Object = App.data.storage[App.user.worldID];
			var mapShop:Object = mapInfo.shop;
			var updateList:Array = [];
			var landUpdateList:Object = { };
			var sid:*;
			var newlyUnlockedItems:Array = [];
			
			User.inupdate = { };
			User.instay = { };
			shops = { };
			
			for (var updateID:* in App.data.updates) {
				
				var update:Object = App.data.updates[updateID];
				
				if (updateID == 'u5840cbf00456e')
					trace();
				
				// Не доступна или нет соц.сетей
				if (!update.social) continue;
				
				// Добавить в то что оставить, все что содержит сеть DM
				if (update.ext && update.ext.hasOwnProperty(App.social) && Numbers.countProps(update.stay) > 0) {
					for (sid in update.stay)
						User.instay[sid] = 1;
				}
				
				// Если этого обновления нет в соц. сети
				if (!update.social.hasOwnProperty(App.social)) continue;
				
				if (!App.data.updatelist[App.social] || App.data.updatelist[App.social][updateID] >= App.time)
					continue;
				
				// Обновления
				var updateObject:Object = {
					id:		updateID,
					data:	[],
					order:	(App.data.updatelist[App.social].hasOwnProperty(updateID)) ? App.data.updatelist[App.social][updateID] : update.order
				};
				var updatesItems:Array = [];
				var items:Object = update.items;
				var info:Object;
				
				for (sid in items) {
					
					if (sid == 2163)
						trace();
					
					info = App.data.storage[sid];
					
					if (!info) continue;
					
					User.inupdate[sid] = 1;
					
					if (info.hasOwnProperty("flist") && info.flist)
					{
						var itemUnlocked:Boolean = checkFlist(info.flist);
						if (!info.visible && itemUnlocked)
							newlyUnlockedItems.push(sid);
						App.data.storage[sid].visible = itemUnlocked;
					}
					
					if (!info.visible || info.type == Storage.COLLECTION || info.type == Storage.RESOURCE) continue;
					
					updateObject.data.push(info);
				}
				
				updateObject.data.sort(function(info1:Object, info2:Object):int {
					if (items[info1.sid] > items[info2.sid])
						return 1;
					
					if (items[info1.sid] < items[info2.sid])
						return -1;
					
					return 0;
				});
				
				updateList.push(updateObject);
				
				// Обновления привязанные к локациям (update.lands)
				if (Numbers.countProps(update.lands) > 0) {
					for each(var landID:* in update.lands) {
						if (!landUpdateList[landID])
							landUpdateList[landID] = [];
						
						landUpdateList[landID].push(updateObject);
					}
				}
				
				
			}
			
			//показываем новые предметы что открылись
			if (newlyUnlockedItems.length > 0)
			{
				new NewUnlockedItemsWindow({bonus:newlyUnlockedItems}).show();
			}
				
			// Общая сортировка
			updateList.sortOn('order', Array.NUMERIC | Array.DESCENDING);
			// Сортировка обновлений привязанных к локациям
			for (landID in landUpdateList) {
				landUpdateList[landID].sortOn('order', Array.NUMERIC | Array.DESCENDING);
			}
			
			
			
			
			
			
			// Магазин
			for each (landID in App.user.lands) {
				var land:Object = App.data.storage[landID];
				
				//if (landID == 555)
					//trace();
				
				if (!land || !User.inupdate.hasOwnProperty(landID)) continue;
				
				for (var market:* in land.shop) {
					
					// Пропустить и не добавлять разделы магазина
					if (App.self.flashVars.debug != 1 && market == RESOURCES) continue;
					
					var list:Array = [];
					
					for (sid in land.shop[market]) {
						
						if (!land.shop[market][sid]) continue;
						
						//if (landID == 2813 && sid == 160)
							//trace();
						
						info = App.data.storage[sid];
						if (!info) continue;						// Существует
						
						//temp[landID].push({ sid:sid, visible:info.visible, shop:info.market || 0 });
						
						info['sID'] = sid;
						
						if (!land.shop[market][sid]) continue;		// Доступен в магазине
						
						if (info.visible == 0 || info.type == Storage.COLLECTION) continue;
						if (!User.inupdate[sid]) continue;			// Пропустить все что не подвязано к обновлению
						if (info.attachTo) continue;				// Пропустить все что продается в сторонних магазинах
						
						list.push(info);
					}
					
					// Если в раздел магазина можно чтото добавить: Создатьраздел, добавить контент
					if (list.length > 0) {
						
						if (market == ANIMALS || market == IMPORTANT || market == PLANTS) {
							list.sortOn('order', Array.NUMERIC);
						}else {
							list.sortOn('order', Array.NUMERIC | Array.DESCENDING);
						}
						
						if (!shops[landID])
							shops[landID] = { };
						
						shops[landID][market] = list;
					}
				}
				
				// Добавить обновления в магазин без локального магазина
				if (shops[landID] && Numbers.countProps(shops[landID]) > 0) {
					// Если не локальный магазин
					if (land.lshop != 1) {
						shops[landID][UPDATE] = updateList;
					}else {
						if (landUpdateList[landID])
							shops[landID][UPDATE] = landUpdateList[landID];
					}
				}
				
			}
				
			/*for (sid in App.data.storage) {
				if (!User.inupdate[sid] && !User.instay[sid]) {
					temp[0].push({ sid:sid, visible:App.data.storage[sid].visible, shop:App.data.storage[sid].market || 0 });
				}
			}
			
			var showed:Array;
			var updateName:String;
			for (market in temp) {
				temp[market].sortOn(['sid', 'shop'], Array.NUMERIC);
				
				showed = [];
				
				trace();
				trace();
				trace((App.data.storage[market]) ? App.data.storage[market].title : market, market);
				
				for (sid in temp[market]) {
					if (showed.indexOf(temp[market][sid].sid) > -1) continue;
					showed.push(temp[market][sid].sid);
					
					updateName = null;
					
					if (User.inUpdate(temp[market][sid].sid)) {
						for each(update in App.data.update) {
							if (update.items) {
								for each (var t:* in update.items) {
									if (t == temp[market][sid].sid) {
										updateName = update.name + '(' + update.order + ')';
									}
								}
							}
							if (updateName) break;
							if (update.stay) {
								for each (t in update.stay) {
									if (t == temp[market][sid].sid) {
										updateName = update.name + '(' + update.order + ')' + '  ' + 'В оставленных';
									}
								}
							}
							if (updateName) break;
						}
					}
					if (!updateName) updateName = '';
					
					trace(temp[market][sid].sid, '  ', temp[market][sid].visible, '  ', App.data.storage[temp[market][sid].sid].type, '  ', getShop(temp[market][sid].shop) + '(' +temp[market][sid].shop+')', '  ', App.data.storage[temp[market][sid].sid].title, '  ', updateName);
				}
			}
			
			function getShop(shopID:int):String {
				if (shopID == 0) return 'Невид.';
				if (shopID == 1) return 'Матер.';
				if (shopID == 2) return 'Раст.';
				if (shopID == 3) return 'Декор.';
				if (shopID == 4) return 'Произв.';
				if (shopID == 14) return 'Живот.';
				if (shopID == 5) return 'Перс.';
				if (shopID == 7) return 'Важное';
				if (shopID == 10) return 'Сны';
				if (shopID == 11) return 'Зоны';
				if (shopID == 12) return 'Приб.';
				if (shopID == 13) return 'Ресур.';
				return 'Ничего';
			}*/
		}
		public static function get inited():Boolean {
			return Boolean(shops);
		}
		
		
		
		
		/**
		 * Текущий магазин
		 */
		public function get currentMarket():int {
			return settings.section;
		}
		public function set currentMarket(value:int):void {
			if (menu) menu.setMarket(value);
			
			settings.section = value;
			history.section = value;
		}
		
		
		
		/**
		 * Количество страниц
		 */
		public function get currentPages():int {
			return (currentMarket == UPDATE) ? 3 : settings.itemsOnPage;
		}
		
		
		
		
		/**
		 * Поиск в Магазине. Открывает магазин
		 */
		public static function find(targets:*):Boolean {
			if (!search(targets, false)) {
				new SimpleWindow( {
					title:		Locale.__e('flash:1382952379765'),
					text:		Locale.__e('flash:1479115635295')
				}).show();
				return false;
			}
			
			// Если найдет в магазине на текущем острове
			for each(var object:Object in searched) {
				if (object.land != App.user.worldID) continue;
				
				ShopWindow.show();
				return true;
			}
			
			// Если найдет в магазине на других островах
			var lands:Array = [];
			for each(object in searched) {
				lands.push(object.land);
			}
			lands.sort();
			if (lands.length > 0) {
				TravelWindow.show( { findTargets:[lands[0]] } );
			}
			
			return true;
		}
		
		
		
		
		/**
		 * Поиск в Магазине. Возвращает успешность поиска (Boolean)
		 */
		public static var searched:Array = [];
		public static function search(targets:*, currentLand:Boolean = true):Boolean {
			if (!(targets is Array)) {
				if (App.data.storage[targets])
					targets = [targets];
				else
					return false;
			}
			
			searched.length = 0;
			
			for (var landID:* in shops) {
				
				// Пропустить, если не на необходимой локации
				if (currentLand && landID != App.user.worldID)
					continue;
				
				for (var market:* in shops[landID]) {
					if (!shops[landID][market]) continue;
					for (var i:int = 0; i < shops[landID][market].length; i++) {
						var item:Object = shops[landID][market][i];
						var index:int;
						var object:Object;
						
						if (market == UPDATE && item.data is Array) {
							
							for (var j:int = 0; j < item.data.length; j++) {
								index = targets.indexOf(item.data[j].sid);
								if (index == -1) continue;
								
								object = {
									sid:		item.data[j].sid,
									position:	i,
									land:		landID,
									market:		market,
									update:		item.id
								}
								searched.push(object);
								//find = true;
							}
							
						}else{
						
							index = targets.indexOf(item.sid);
							if (index == -1) continue;
							
							object = {
								sid:		item.sid,
								position:	i,
								land:		landID,
								market:		market
							}
							searched.push(object);
							//find = true;
						}
					}
				}
			}
			
			// Очистка от тех поисков, при поиске в магазине текущей территории,
			// которые ведут на другие территории с локальными списками stacks и objects
			if (currentLand) {
				
				var inOtherLands:Array = [];
				
				for (i = 0; i < App.user.lands.length; i++) {
					
					landID = App.user.lands[i];
					var land:Object = App.data.storage[landID];
					
					if (landID == App.user.worldID) continue;
					if (!land) continue;
					
					// В магазине
					if (land.stacks) {
						for each(var ID:* in land.stacks)
							inOtherLands.push(ID);
					}
					
					// На территории
					if (land.objects) {
						for each(ID in land.objects)
							inOtherLands.push(ID);
					}
				}
				
				for (i = searched.length - 1; i > -1; i--) {
					if (inOtherLands.indexOf(searched[i].sid) == -1) continue;
					searched.splice(i, 1);
				}
			}
			
			return searched.length > 0;
		}
		
		
		
		/**
		 * Поиск по названию
		 */
		private var searchByTextMarket:int;
		private var searchByTextUpdate:String;
		private var searchByTextList:Array = [];
		public function searchByText(text:String):Boolean {
			
			// Поиск
			function search(shop:Array, text:String):void {
				for each(var item:Object in shop) {
					if ((item.title.toLowerCase().indexOf(text) > -1 || item.sid.toString().indexOf(text) > -1))
						searchByTextList.push(item);
				}
			}
			
			searchByTextMarket = 0
			searchByTextUpdate = null;
			searchByTextList.length = 0;
			
			if (!shops) return false;
			
			if (shops[App.user.worldID] && shops[App.user.worldID][currentMarket]) {
				search(shops[App.user.worldID][currentMarket], text);
				searchByTextMarket = currentMarket;
			}
			
			// Искать в других разделах, если на этом острове в этом разделе нет
			if (searchByTextList.length == 0 && shops[App.user.worldID]) {
				for (var market:* in shops[App.user.worldID]) {
					if (market == UPDATE || market == RESOURCES) continue;
					
					search(shops[App.user.worldID][market], text);
					
					// Если найдено в каком-то разделе - отменить
					if (searchByTextList.length > 0) {
						searchByTextMarket = market;
						break;
					}
				}
			}
			
			// Искать в обновлениях, если на этом острове нет в разделах
			if (searchByTextList.length == 0 && shops[App.user.worldID] && shops[App.user.worldID][UPDATE]) {
				var shop:Object = shops[App.user.worldID][UPDATE];
				
				for each(var update:Object in shop) {
					if (update.data is Array) {
						search(update.data, text);
						
						if (searchByTextList.length > 0) {
							searchByTextMarket = UPDATE_ITEMS;
							searchByTextUpdate = update.id;
							break;
						}
					}
				}
			}
			
			return searchByTextList.length > 0;
		}
		
		public static function reInit():void
		{
			shops = null;
			init();
		}
		
		/**
		 * Текущий магазин
		 */
		public static function get shop():Object {
			return shops[App.user.worldID];
		}
		
		private static function checkFlist(flist:Object):Boolean
		{
			for (var index:* in flist.f)
			{
				if (flist.f[index] == ShopItemNew.AFTER_QUEST)
				{
					var qID:* = flist.t[index];
					if (App.user.quests.data[qID] && App.user.quests.data[qID].finished > 0)
						return true;
				}
			}
			
			return false;
		}
		
		/**
		 * Поиск раздела и страницы из списка searched (заполняется методом search)
		 * @param	settings
		 */
		private function findTargetPage(settings:Object):void {
			
			var inUpdate:Boolean;
			var inMarket:Boolean;
			
			for each(var object:Object in searched) {
				if (object.land != App.user.worldID) continue;
				
				if (object.update && shop[UPDATE]) {
					
					if (inMarket) continue;
					
					for (var i:int = 0; i < shop[UPDATE].length; i++) {
						if (shop[UPDATE][i].id != object.update) continue;
						
						settings.section = UPDATE;
						settings.page = int(i / 3);
						
						finded.push(object.update);
						finded.push(object.sid);
						inUpdate = true;
						
						//break;
					}
					
				}else if (object.sid) {
					if (!inMarket) {
						settings.section = object.market;
						settings.page = int(object.position / settings.itemsOnPage);
						inMarket = true;
					}
					
					finded.push(object.sid);
					
				}
			}
		}
		
		public function clearFind():void {
			searched.length = 0;
		}
		
		override public function show():void {
			if (App.user.mode != User.OWNER) return;
			
			super.show();
		}
		
		
		override public function dispose():void {
			
			for each(var item:* in items) {
				if (item.parent != null) bodyContainer.removeChild(item);
				item.dispose();
				item = null;
			}
			
			for each(var icon:* in icons) {
				icon.dispose();
				icon = null;
			}
			
			clearFind();
			
			ShopWindow.instance = null;
			
			super.dispose();
		}
		
		override public function drawFader():void {
			super.drawFader();
			
			this.y += 20;
			fader.y -= 20;
		}
		
		override public function drawBody():void {
			
			var titleHeader:Bitmap = backingShort(510, 'shopTitleBacking');
			titleHeader.x = 150;
			titleHeader.y = -titleHeader.height - 10;
			bodyContainer.addChild(titleHeader);
			
			titleLabel.y -= 12;
			
			seachPanel = new SearchShopPanel( {
				win:this, 
				callback:showItem,
				stop:onStopFinding,
				hasIcon:false,
				caption:Locale.__e('flash:1405687705056')
			});
			seachPanel.y = settings.height - 100;
			seachPanel.x = 10;
			seachPanel.visible = false;
			bodyContainer.addChild(seachPanel);
			
			initSection();
			
			settings.content = shop[currentMarket];
			
			drawMenu();
			setContentSection(currentMarket, settings.page);
		}
		
		private function initSection():void {
			
			if (currentMarket == 0 || !shop.hasOwnProperty(currentMarket) || Numbers.countProps(shop[currentMarket]) == 0) {
				
				for (var section:* in shop) {
					if (Numbers.countProps(shop[section]) == 0 || section == 0) continue;
					settings.section = section;
					settings.page = 0;
					history.section = settings.section;
					history.page = 0;
					break;
				}
			}
			
		}
		
		private function showSeach(value:Boolean = true):void 
		{
			if (App.user.quests.tutorial)
				value = false;
			
			seachPanel.visible = value;
			if(seachPanel.isFocus)
				seachPanel.searchField.text = "";
			else
				seachPanel.searchField.text = seachPanel.settings.caption;
		}
		
		private function onStopFinding():void 
		{
			setContentSection(currentMarket,settings.page);
		}
		
		private function showItem(content:Array):void 
		{
			searchByText(seachPanel.searchField.text.toLowerCase());
			
			if (currentMarket != searchByTextMarket) {
				currentMarket = searchByTextMarket;
			}
			
			settings.content = searchByTextList;
			
			paginator.itemsCount = settings.content.length;
			paginator.update();
			contentChange();
		}
		
		private var menu:ShopMenu;
		public function drawMenu():void {
			menu = new ShopMenu(this);
			bodyContainer.addChild(menu);
		}
		
		
		public function setContentSection(section:*, page:Number = -1):Boolean {
			
			if (!shop) return false;
			
			if (shop.hasOwnProperty(section)) {
				
				currentMarket = section;
				settings.content = shop[section];
				
				history.page = page;
				
				paginator.page = (page >= 0 && history.page <= int(settings.content.length / currentPages)) ? history.page : 0;
				paginator.itemsCount = settings.content.length;
				
			}else {
				return false;
			}
			
			showSeach((currentMarket == UPDATE) ? false : true);
			
			paginator.onPageCount = currentPages;
			paginator.update();
			contentChange();
			
			return true;
		}
		
		public function setContentNews(item:Object):Boolean
		{
			
			currentMarket = UPDATE_ITEMS;
			settings.content = item.data;
			
			if (finded.indexOf(item.id) > -1) {
				for (var i:int = 0; i < settings.content.length; i++) {
					var object:Object = settings.content[i];
					if (finded.indexOf(object.sid) > -1)
						paginator.page = int(i / settings.itemsOnPage);
				}
			}else {
				paginator.page = 0;
			}
			
			paginator.onPageCount = settings.itemsOnPage;
			paginator.itemsCount = settings.content.length;
			paginator.update();
			
			contentChange();
			
			return true;
		}
		
		override public function drawBackground():void {
			background = backing2(settings.width, settings.height, 190, 'shopBackingTop', 'shopBackingBot');
			layer.addChild(background);
			
			//background.transform.colorTransform = new ColorTransform(1, 1, 1, 1, 128, 0, 0);
		}
		
		override public function contentChange():void {
			for each(var _item:* in items) {
				bodyContainer.removeChild(_item);
				_item.dispose();
			}
			items = [];
			var X:int = 60;
			var Xs:int = X;
			var Ys:int = 63;
			
			if (currentMarket == UPDATE) {
				X = 68;
				Ys = 58;
			}
			
			var itemNum:int = 0;
			for (var i:int = paginator.startCount; i < paginator.finishCount; i++){
			
				var item:*
				if (currentMarket == UPDATE) {
					item = new NewsItem(settings.content[i], this);
				}else {
					item = new ShopItemNew(settings.content[i], this);
				}
				
				bodyContainer.addChildAt(item,1);
				item.x = Xs - 10;
				item.y = Ys;
				
				items.push(item);
				
				Xs += item.background.width + 6;
				
				if (finded.indexOf(settings.content[i].sid) > -1 || finded.indexOf(settings.content[i].id) > -1)
					item.showGlowing();
				
				if (currentMarket == UPDATE) continue;
				
				if (itemNum == int(settings.itemsOnPage / 2) - 1)	{
					Xs = X;
					Ys += item.background.height + 15;
				}
				
				itemNum++;
			}
			
			if (currentMarket == UPDATE)
				showBestSellers();
			else
				hideBestSellers();
			
			if (currentMarket == UPDATE_ITEMS)
				return;
			
			if (!currentMarket)
				return;
			
			settings.page = paginator.page;
			history.page = settings.page;
			
			/*if (updateFind) {
				setContentNews(updateFind);
				updateFind = null;
			}*/
			
		}
		
		override public function drawArrows():void {
			
			paginator.drawArrow(bodyContainer, Paginator.LEFT,  0, 0, { scaleX: -1, scaleY:1 } );
			paginator.drawArrow(bodyContainer, Paginator.RIGHT, 0, 0, { scaleX:1, scaleY:1 } );
			
			var y:Number = (settings.height - paginator.arrowLeft.height) / 2 - 10;
			paginator.arrowLeft.x = 50 - paginator.arrowLeft.width;
			paginator.arrowLeft.y = y - 18;
			
			paginator.arrowRight.x = settings.width - 50;
			paginator.arrowRight.y = y - 18;
			
			paginator.x = (settings.width - paginator.width) / 2 - 30;
			paginator.y = settings.height - 30;
		}
		
		override public function drawTitle():void {
			titleLabel = titleText( {
				title				: settings.title,
				color				: settings.fontColor,
				multiline			: settings.multiline,			
				fontSize			: settings.fontSize,				
				textLeading	 		: settings.textLeading,				
				borderColor 		: settings.fontBorderColor,			
				borderSize 			: settings.fontBorderSize,	
				
				shadowBorderColor	: settings.shadowBorderColor || settings.fontColor,
				width				: settings.width - 140,
				textAlign			: 'center',
				sharpness 			: 50,
				thickness			: 50,
				border				: true,
				filters				: [new DropShadowFilter(5, 90, 0x4e3d29, 1, 0, 0)]
			});
			
			titleLabel.x = (settings.width - titleLabel.width) * .5;
			titleLabel.y = -16;
			headerContainer.addChild(titleLabel);
		}
		
		
		static public function set currentBuyObject(value:Object):void {
			_currentBuyObject = value;
		}
		static public function get currentBuyObject():Object {
			return _currentBuyObject;
		}
		
		
		public var bestBg:Bitmap = null;
		public var bestSellers:BestSellers = null;
		public function showBestSellers():void {
			
			if (bestSellers != null) return;
			bestSellers = new BestSellers(this);
			
			bestSellers.x = (settings.width - bestSellers.width) / 2;
			bestSellers.y = settings.height - 268;
			bodyContainer.addChild(bestSellers);
			
			paginator.visible = false;
		}
		
		public function hideBestSellers():void {
			if (bestSellers == null) return
			
			bestSellers.dispose();
			bodyContainer.removeChild(bestSellers);
			bestSellers = null;
			paginator.visible = true;
		}
		
		
		
		public static var help:int = 0;
		public static function findMaterialSource(sid:*):Boolean {
			
			// Сортирует массив объектов на карте по возрастанию удаленности от объекта unit
			var unit:* = App.user.hero;
			function remoteness(u1:*, u2:*):int {
				if (Math.sqrt((unit.x - u1.x) * (unit.x - u1.x) + (unit.y - u1.y) * (unit.y - u1.y)) > Math.sqrt((unit.x - u2.x) * (unit.x - u2.x) + (unit.y - u2.y) * (unit.y - u2.y))) {
					return 1;
				}else if (Math.sqrt((unit.x - u1.x) * (unit.x - u1.x) + (unit.y - u1.y) * (unit.y - u1.y)) < Math.sqrt((unit.x - u2.x) * (unit.x - u2.x) + (unit.y - u2.y) * (unit.y - u2.y))) {
					return -1;
				}else {
					return 0;
				}
			}
			
			if (App.data.storage[sid].type == 'Lands') {
				new TravelWindow( {
					find:sid
				}).show();
				return true;
			}
			
			var finded:Boolean;
			var wid:int;
			var world:Object;
			var bSID:String;
			var lands:Array = [];
			
			//if (App.data.storage[sid].type != 'Material') {
				for (wid = 0; wid < App.user.lands.length; wid++) {				
					world = App.data.storage[App.user.lands[wid]];
					if (!world.hasOwnProperty('stacks')) continue;
					for (bSID in world.stacks) {
						if (sid == world.stacks[bSID]) {
							lands.push(App.user.lands[wid]);
							
							/*if (App.user.worldID == App.user.lands[wid]) {
								finded = true;
								break;
							}
							
							Window.closeAll();
							new TravelWindow( {
								find:App.user.lands[wid],
								popup:true
							}).show();
							return true;*/
						}
					}
					
					//if (finded) break;
				}
				if (lands.length > 0) {
					if (lands.indexOf(App.user.worldID) == -1) {
						lands.sort();
						
						Window.closeAll();
						new TravelWindow( {
							find:	lands[0],
							popup:	true
						}).show();
						return true;
					}
				}
			//}
			
			if (App.data.storage[sid].type == 'Invader')
			{
				var invaderList:Object = JSON.parse(App.data.options.InvaderList) as Array;
				var invader:Object;
				for (var i:Object in invaderList) {
					if (invaderList[i].hasOwnProperty('finder') && invaderList[i].finder.indexOf(int (sid)) != -1) 
					{
						invader = invaderList[i];
						break;
					}
				}
				onMap = Map.findUnits(invader.SIDs);
				Window.closeAll();
				if ( onMap.length > 0 )
					App.map.focusedOn(onMap[0], true, null);
				else 
					new SimpleWindow({
						text:	Locale.__e(invader.finderLocal)
					}).show();
				return true;
			}
			
			if (sid == 2486 && App.user.worldID != User.HOME_WORLD) {
				var list:Array = new Array();
				
				for (var sID:* in App.data.storage) {
					var object:Object = App.data.storage[sID];
					object['sID'] = sID;
					
					if (object.type == 'Energy' && object.out == sid && User.inUpdate(sID)) {
						list.push(sID);
					}
				}
				new ShopWindow({find:list}).show();
				return true;
			}
			
			// Найти где крафтится
			var linked:Boolean = false; 
			var whereCraft:Array = [];
			var id:*;
			var index2:*;
			var info:Object;
			
			for (var s:* in App.data.storage) {
				info = App.data.storage[s];
				
				//if (s == 1366)
					//trace();
				
				if (info.type == 'Etherplant')
					continue;
				
				if (info.expire) {
					if (info.expire is int && info.expire < App.time)
						continue;
					else if (info.expire[App.social] && info.expire[App.social] > 0 && info.expire[App.social] < App.time)
						continue;
				}
				
				if (info.hasOwnProperty('outs')) {
					var outs:Object = App.data.storage[s].outs;
					for (id in outs) {
						if (int(id) == sid) {
							whereCraft.push(int(s));
							finded = true;
						}
					}
				}
				
				if (info.hasOwnProperty('devel') && info.devel.hasOwnProperty('rew')) {
					for (var craft_lvl:* in info.devel.rew) {
						for (id in info.devel.rew[craft_lvl]) {
							if (int(id) == int(sid)) {
								whereCraft.push(int(s));
								finded = true;
							}
						}
					}
				}
				
				if (info.type == 'Walkgolden' && info.hasOwnProperty('require')) {
					var treasure:Object = App.data.treasures[info.shake][info.shake].item;
					for each (id in treasure) {
						if (id == sid) {
							whereCraft.push(int(s));
							finded = true;
						}
						
						if (finded) break;
					}
				}
				
				if (info.type == 'Invader' && info.hasOwnProperty('require')) {
					for (var req:Object in info.devel.req)
					{
						var treasure2:Object = App.data.treasures[info.devel.req[1].treasure][info.devel.req[1].treasure].item;
						
						for each (id in treasure2) {
							if (id == sid) {
								whereCraft.push(int(s));
								finded = true;
							}
							
							if (finded) break;
						}
					}
				}
				
				// для Fatman
				if (info.foods) {
					for (id in info.foods) {
						var food:Object = App.data.storage[id];
						if (food && food.reward && food.reward.hasOwnProperty(sid)) {
							whereCraft.push(s);
							finded = true;
						}
					}
				}
				
				if (App.data.storage[s].type == 'Box' && App.data.storage[s].hasOwnProperty('devel') && App.data.storage[s].devel.hasOwnProperty('obj')) {
					for each(var decor:* in App.data.storage[s].devel.obj) {
						for (id in decor) {
							if (int(id) == int(sid)) {
								whereCraft.push(int(s));
								finded = true;
							}
							
							if (finded) break;
						}
					}
				}
				
				if (App.data.storage[s].hasOwnProperty('devel') && App.data.storage[s].devel.hasOwnProperty('exchange')) {
					for (var num:* in App.data.storage[s].devel.exchange) {
						for (id in App.data.storage[s].devel.exchange[num]) {
							var item2:Object = App.data.storage[s].devel.exchange[num][id];
							if (item2.sid == int(sid)) {
								whereCraft.push(int(s));
								finded = true;
							}
							
							if (finded) break;
						}
					}
				}
				
				if (App.data.storage[s].hasOwnProperty('devel')) {
					if (App.data.storage[s].devel.hasOwnProperty('tech')) {
						for (id in App.data.storage[s].devel.tech[1]) {
							var tech:Object = App.data.storage[App.data.storage[s].devel.tech[1][id]];
							for (var it:String in tech.devel.items) {
								var material:String;
								for (material in tech.devel.items[it]) {
									break;
								}
								if (int(material) == int(sid)) {
									whereCraft.push(int(s));
									finded = true;
								}
								
								if (finded) break;
							}
						}
					}
				}
				
				if (App.data.storage[s].type == 'Trap') {
					var ttreasure:Object = App.data.treasures[App.data.storage[s].treasure][App.data.storage[s].treasure].item;
					for each (id in ttreasure) {
						if (id == sid) {
							whereCraft.push(int(s));
							finded = true;
						}
						if (finded) break;
					}
				}
				
				if (App.data.storage[s].type == 'Barter') {
					//if (s == 2964)	
						//trace();
					
					var skp:Boolean;
					for (var bID:* in App.data.barter) {
						var itemBr:Object = App.data.barter[bID];
						if (itemBr.building != s) continue;
						
						// items - это out :)
						if (itemBr.items && itemBr.items.hasOwnProperty(sid)) {
							skp = false;
							for (var itm:String in itemBr.out) {
								if (!User.inUpdate(itm)) skp = true;
							}
							for (itm in itemBr.items) {
								if (!User.inUpdate(itm)) skp = true;
							}
							if (skp) continue;
							
							whereCraft.push(s);
							finded = true;
						}
					}
					
					
					
					/*var content:Array = [];
					for (var bID:* in App.data.barter) {
						var itemBr:Object = App.data.barter[bID];
						var skp:Boolean = false;
						if (itemBr.out is Object) {
							for (var itm:String in itemBr.out) {
								if (!User.inUpdate(itm)) skp = true;
							} 
						} else {
							if (!User.inUpdate(itemBr.out)) continue;
						}
						for (var ite:String in itemBr.items) {
							if (!User.inUpdate(ite)) skp = true;
						}
						if (skp) continue;
						itemBr['bID'] = bID;
						if (itemBr.building == int(s)) {
							content.push({
								order:	App.data.barter[bID].order,
								bID:	bID
							});
						}
					}
					
					var indexBr:int;
					for (indexBr = 0; indexBr < content.length; indexBr++) {
						if (App.data.barter[content[indexBr].bID].hasOwnProperty('items')) {
							for (id in App.data.barter[content[indexBr].bID].items) {
								if (sid == id) {
									whereCraft.push(int(s));
									finded = true;
									break;
								}
							}
						}
						
						if (finded) break;
					}
					
					if (!finded) {
						for (indexBr = 0; indexBr < content.length; indexBr++) {
							if (App.data.barter[content[indexBr].bID].hasOwnProperty('out')) {
									for (id in  App.data.barter[content[indexBr].bID].out) break;
									if (id == sid) {
										whereCraft.push(int(s));
										finded = true;
										break;
									}
							}
							
							if (finded) break;
						}
					}*/
				}
				
				if (/*!finded && */info.hasOwnProperty('devel') && info.devel.hasOwnProperty('craft')) {
					var crafting:Array = [];
					for (var craft_lvl2:* in info.devel.craft) {
						if (info.devel.craft[craft_lvl2] is Object) {
							for each (id in info.devel.craft[craft_lvl2]) {
								crafting.push(id);
							}
						}else {
							crafting = crafting.concat(info.devel.craft[craft_lvl2]);
						}
					}
					for each(var cft:* in crafting) {
						if (!App.data.crafting.hasOwnProperty(cft)) continue;
						
						if (App.data.crafting[cft].out == int(sid)) {
							var skip:Boolean = false;
							//TODO:crafts doesn't work if items 
							//for (id in App.data.crafting[cft].items) {
								//if (!User.inUpdate(id))
									//skip = true;
							//}
							if (!skip) {
								whereCraft.push(int(s));
								finded = true;
							}
						} else if (App.data.storage[App.data.crafting[cft].out].hasOwnProperty('bonus'))
						{
							var obj:Object = App.data.storage[App.data.crafting[cft].out].bonus;
							for (id in obj) {
								if (id == sid){
									whereCraft.push(int(s));
									finded = true;
								}
							}
						}
					}
				}
				
				if (App.data.storage[s].type == 'Rbuilding') {
					var sq:Object = App.data.storage[s];
					var asd:Object = sq.treasure;
					var asd2:Object = App.data.treasures[asd];
					var asd3:Object = App.data.storage[s].treasure;
					var rtreasure:Object = App.data.treasures[App.data.storage[s].treasure][App.data.storage[s].treasure].item;
					for each (id in rtreasure) {
						if (id == sid) {
							whereCraft.push(int(s));
							finded = true;
						}
						if (finded) break;
					}
				}
				
				if (App.data.storage[s].type == 'Underground') {
					var objects:Object = App.data.storage[s].crafting;
					for each (id in objects) {
						if (id == sid) {
							whereCraft.push(int(s));
							finded = true;
						}
						if (finded) break;
					}
				}
				
				if (App.data.storage[s].type == 'Shappy') {
					var topID:int = 0;
					for (id in App.data.top) {
						if (App.data.top[id].unit == s) {
							topID = id;
							break;
						}
					}
					if (topID != 0) {
						for each (var tr:* in App.data.top[topID].league.abonus[1].t) {
							var treasureAbonus:Object = Treasures.getTreasureItems(tr);
							if (treasureAbonus.hasOwnProperty(sid)) {
								finded = true;
								whereCraft.push(s);
							}
							if (finded) break;
						}
						for each (tr in App.data.top[topID].league.tbonus[1].t) {
							treasureAbonus = Treasures.getTreasureItems(tr);
							if (treasureAbonus.hasOwnProperty(sid)) {
								finded = true;
								whereCraft.push(s);
							}
							if (finded) break;
						}
					}
				}
			}
			
			
			// Найти по принадлежности к другим зданиям
			var parentWhereCraft:Array = [];
			for (index = 0; index < whereCraft.length; index++) {
				var childInfo:Object = App.data.storage[whereCraft[index]];
				if (!childInfo) continue;
				
				// По принадлежности к Cbuilding
				if (childInfo.hasOwnProperty('attachTo') && childInfo.attachTo is Array) {
					for (index2 = 0; index2 < childInfo.attachTo.length; index2++) {
						id = childInfo.attachTo[index2];
						if (parentWhereCraft.indexOf(id) == -1)
							parentWhereCraft.push(id);
					}
				}
			}
			if (parentWhereCraft.length > 0)
				whereCraft = parentWhereCraft;
			
			
			
			if (!finded && App.data.storage[sid].free == 1) {
				new SimpleWindow( {
					title: Locale.__e('flash:1431685989241'),
					text: Locale.__e('storage:504:description'),
					popup: true
				}).show();
				return true;
			}
			
			if (/*!finded && */App.data.storage[s].hasOwnProperty('devel') && App.data.storage[s].devel.hasOwnProperty('exchange')) {
				for (var lvlExch:Object in App.data.storage[s].devel.exchange) {
					for (var exch:Object in lvlExch) {
						if (exch.sid == sid ) {
							whereCraft.push(int(s));
							finded = true;
						}
					}
				}
			}
			
			// Найти в квестах
			if (!finded) {
				var q:*;
				for (q in App.user.quests.opened) {
					info = App.data.quests[App.user.quests.opened[q].id];
					if (info.bonus && info.bonus.materials) {
						if (sid in info.bonus.materials) {
							Window.closeAll();
							new SimpleWindow( {
								text:Locale.__e('flash:1455269552420'),
								title:Locale.__e('flash:1382952380254'),
								popup:true,
								confirm:function():void {
									App.ui.upPanel.checkQuests(App.user.quests.opened[q].id)
								}
							}).show();
							return true;
						}
					}
			    }
				if ((!App.data.storage[sid].hasOwnProperty('price') || App.data.storage[sid].price == '') && App.data.storage[sid].free != 1) {
					for (q in App.data.quests) {
						info = App.data.quests[q];
						if (info.bonus && info.bonus.materials) {
							if (sid in info.bonus.materials) {
								Window.closeAll();
								new SimpleWindow( {
									text:Locale.__e('flash:1455269552420'),
									title:Locale.__e('flash:1382952380254'),
									popup:true,
									confirm:function():void {
										//App.ui.upPanel.checkQuests(App.data.quests[q])
										new QuestsChaptersWindow({find:[q]}).show();
									}
								}).show();
								return true;
							}
						}
					}
				}
			}
			
			// Найти в рейтингах
			if (!finded) {
				var tname:*;
				var treasureT:Object;
				for (var tID:* in App.data.top) {
					var data:Object = App.data.top[tID];
					if (data.league.hasOwnProperty('tbonus')) {
						for each (tname in data.league.tbonus.t) {
							treasureT = App.data.treasures[tname][tname].item;
							for each (id in treasureT) {
								if (id == sid) {
									whereCraft.push(int(data.target));
									finded = true;
								}
							}
						}
					} else if (data.hasOwnProperty('league') && data.league.hasOwnProperty('tbonus')) {
						for (var lid:* in data.league.tbonus) {
							for each (tname in data.league.tbonus[lid].t) {
								treasureT = App.data.treasures[tname][tname].item;
								for each (id in treasureT) {
									if (id == sid) {
										whereCraft.push(int(data.target));
										finded = true;
									}
								}
							}
						}
					}
			    }
			}
			
			if (/*!finded && */App.data.storage[sid].type == 'Clothing') {
				App.map.focusedOn(App.user.hero, true, function():void {
					App.user.hero.click();
				});
				return true;
			}
			
			if (!finded && App.data.storage[sid].free != 1) {
				for (s in App.data.storage) {
					if (App.data.storage[s].type == 'Resource' && App.data.storage[s].hasOwnProperty('treasure') && App.data.storage[s].treasure != "") {
						var treasureR:Object = App.data.treasures[App.data.storage[s].treasure].kick.item;
						for each (id in treasureR) {
							if (id == sid) {
								whereCraft.push(int(s));
								finded = true;
							}
							
							if (finded) break;
						}
					}
					
					if (!finded && App.data.storage[s].hasOwnProperty('kicks')) {
						for (var kick:* in App.data.storage[s].kicks) {
							//if (s == 3006)
								//trace();
							
							var treasureName:String = App.data.storage[s].kicks[kick].b;
							var treasureK:Object = Treasures.getTreasureItems(treasureName);// App.data.treasures[App.data.storage[s].kicks[kick].b][App.data.storage[s].kicks[kick].b].item;
							for each (id in treasureK) {
								if (id == sid) {
									if (s == 2602) {
										SemiEventWindow.find = kick;
										whereCraft.push(int(s));
										finded = true;
									}else {
										new SimpleWindow( {
											popup:true,
											title:Locale.__e('flash:1382952380254'),
											text:Locale.__e('flash:1466584875439',  App.data.storage[s].title)
										}).show();
										return true;
									}
								}
							}
						}
					}
				}
			}
			
			if (!finded) {
				for (s in App.data.storage) {
					if (App.data.storage[s].hasOwnProperty('tower')) {
						for (var k:* in App.data.storage[s].tower) {
							var treasureKick:Object = App.data.treasures[App.data.storage[s].tower[k].t][App.data.storage[s].tower[k].t].item;
							for each (id in treasureKick) {
								if (id == sid) {
									finded = true;
									whereCraft.push(s);
									break;
								}
							}
							if (finded) break;
						}
					}
					if (finded) break;
				}
			}
			
			/*if (!finded) {
				for (s in App.data.storage) {
					if (App.data.storage[s].type == 'Shappy') {
						var topID:int = 0;
						for (id in App.data.top) {
							if (App.data.top[id].unit == s) {
								topID = id;
								break;
							}
						}
						if (topID != 0) {
							for each (var tr:* in App.data.top[topID].league.abonus[1].t) {
								var treasureAbonus:Object = App.data.treasures[tr][tr].item;
								for each (id in treasureAbonus) {
									if (id == sid) {
										finded = true;
										whereCraft.push(s);
										break;
									}
								}
								if (finded) break;
							}
						}
					}
					if (finded) break;
				}
			}*/
			
			if ([1986, 1987, 1988, 1989, 1990, 1991, 1992, 1993, 1994].indexOf(int(sid)) != -1) {
				finded = true;
				HappyWindow.depthShow = 2;
				HappyWindow.find = sid;
				whereCraft.push(1969);
			}
			
			if ([1717, 1718].indexOf(int(sid)) != -1) {
				finded = true;
				whereCraft.push(1738);
			}
			
			if ([2197, 2198, 2199].indexOf(int(sid)) != -1) {
				finded = true;
				whereCraft.push(2168);
			}
			
			if ([1735,1736,1712,1743,1741,1745,1744,1742,1746,1759,1758,1757,1756,1755,1754,1753,1752,1751].indexOf(int(sid)) != -1) {
				finded = true;
				HappyWindow.depthShow = 2;
				HappyWindow.find = sid;
				whereCraft.push(1711);
			}
			
			if ([2312,2313,2314,2315,2316,2317,2318,2319,2320,2323,2324,2325,2326,2327].indexOf(int(sid)) != -1) {
				finded = true;
				HappyWindow.depthShow = 2;
				HappyWindow.find = sid;
				whereCraft.push(2284);
			}
			
			if ([1737, 1713].indexOf(int(sid)) != -1) {
				finded = true;
				whereCraft.push(1711);
			}
			
			if ([869, 917, 946, 947, 948, 949].indexOf(int(sid)) != -1) {
				finded = true;
				whereCraft.push(935);
			}
			
			if ([1303, 1304, 1305, 1306,1290, 1291,1291, 1292, 1293,1289].indexOf(int(sid)) != -1) {
				finded = true;
				whereCraft.push(1302);
			}
			
			if ([1419,1417,1420,1421,1422,1423].indexOf(int(sid)) != -1) {
				finded = true;
				ExchangeWindow.depthShow = 2;
				whereCraft.push(797);
			}
			
			if ([1517,1519].indexOf(int(sid)) != -1) {
				finded = true;
				HappyWindow.depthShow = 2;
				whereCraft.push(1518);
			}
			
			if ([1520,1522,1524,1526,1527,1528].indexOf(int(sid)) != -1) {
				finded = true;
				whereCraft.push(1518);
			}
			
			if (sid == 682)
			{
				finded = true;
				whereCraft = [];
				whereCraft.push(552);
			}
			
			if ([1561,1545,1546,1547,1548,1550,1551,1552,1553,1950,1951,1952].indexOf(int(sid)) != -1) {
				finded = true;
				whereCraft.push(int(sid));
			}
			
			var quest:int = 0;
			//switch (int(sid)) {
				//case 2406: quest = 888; break;
				//case 2407: quest = 891; break;
				//case 2408: quest = 895; break;
				//case 2409: quest = 899; break;
				//case 2410: quest = 903; break;
				//case 2411: quest = 907; break;
				//case 2412: quest = 911; break;
				//case 2502: quest = 943; break;
				//case 2491: quest = 926; break;
			//}
			//if (quest != 0) {
				//new SimpleWindow( {
					//text:Locale.__e('flash:1455269552420'),
					//title:Locale.__e('flash:1382952380254'),
					//popup:true,
					//confirm:function():void {
						//App.ui.upPanel.checkQuests(quest)
					//}
				//}).show();
				//return true;
			//}
			
			if (App.data.options.hasOwnProperty('EventList')) {
				/*var items:Object = JSON.parse(App.data.options.EventList);
				for each (var eitem:* in items[0]) {
					if (int(eitem.sID) == sid || int(eitem.sID) == int(whereCraft[0])) {
						FrenchEventWindow.find = sid;
						new FrenchEventWindow().show();
						return true;
					}
				}*/
			}
			
			for each (var sp:Object in App.user.spawnUnits) {
				if (sp.sIDs.indexOf(int(sid)) != -1) {
					if (App.user.quests.data.hasOwnProperty(sp.qID) && App.user.quests.data[sp.qID].finished != 0) {
						if (!finded && int(sid) == 2372) {
							var bulls:Array = Map.findUnits([2372]);
							if (bulls.length == 0) {
								new SimpleWindow( {
									text:Locale.__e('flash:1470647868400'),
									title:Locale.__e('flash:1382952380254'),
									popup:true
								}).show();
							}else {
								App.map.focusedOn(bulls[0], true);
							}
						}
						if (!finded && [2566,2567,2568,2569].indexOf(int(sid))) {
							var finds:Array = Map.findUnits([sid]);
							if (finds.length != 0) {
								App.map.focusedOn(finds[0], true);
							}
						}
						continue;
					}
					new SimpleWindow( {
						text:Locale.__e('flash:1455269552420'),
						title:Locale.__e('flash:1382952380254'),
						popup:true,
						confirm:function():void {
							App.ui.upPanel.checkQuests(sp.qID)
						}
					}).show();
					break;
				}
			}
			
			// Если найдем к чему привязать, то finded поменять на противоположное
			if (finded) {
				//Window.closeAll();
				var onMap:Array = Map.findUnits(whereCraft);
				
				if (onMap.length > 0) {
					linked = true;
					
					if (unit) {
						onMap.sort(remoteness);
					}
					
					var index:int = 0;
					var hardLevel:int = 0;
					var clickOnFocus:Boolean = false;
					while (index < onMap.length) {
						if (onMap[index] is Resource || onMap[index] is Plant || onMap[index] is Walkgolden) {
							break;
						}else if ((onMap[index] is Animal) || (onMap[index] is Tree)) {
							if (hardLevel >= 1) {
								break;
							}else if (hardLevel == 0 && onMap[index].started < App.time) {
								break;
							}
						}else if (onMap[index] is Cbuilding) {
							clickOnFocus = true;
							
							/*if (onMap[index].level < onMap[index].totalLevels && containsMaxLevelBuilding(onMap)) {
								index++;
								continue;
							}*/
							if (hardLevel >= 3) {
								break;
							} else if (hardLevel == 2 && onMap[index].level >= onMap[index].totalLevels) {
								break;
							} else if (hardLevel == 1 && Numbers.countProps(onMap[index].slots) > 0) {
								break;
							} else if (hardLevel == 0 && onMap[index].hasOwnProperty('crafted') && onMap[index].crafted > 0 && onMap[index].crafted <= App.time) {
								break;
							}
						}else if (onMap[index] is Building) {
							clickOnFocus = true;
							
							/*if (onMap[index].level < onMap[index].totalLevels && containsMaxLevelBuilding(onMap)) {
								index++;
								continue;
							}*/
							if (hardLevel >= 2) {
								break;
							} else if (hardLevel == 1 && onMap[index].level >= onMap[index].totalLevels) {
								break;
							} else if (hardLevel == 0 && onMap[index].hasOwnProperty('crafted') && onMap[index].crafted > 0 && onMap[index].crafted <= App.time) {
								break;
							}
						}else {
							break;
						}
						
						index++;
						
						if (index >= onMap.length) {
							index = 0;
							hardLevel ++;
						}
					}
					
					if (onMap[index] is Exchange) {
						ExchangeWindow.find = sid;
					}
					
					if (onMap[index] is Building || onMap[index] is Cbuilding) {
						ProductionWindow.find = sid;
					}
					
					if (onMap[index] is Underground) {
						UndergroundWindow.find = sid;
					}
					
					App.map.focusedOn(onMap[index], true, function():void {
						if (clickOnFocus) {
							onMap[index].helpTarget = sid;
							onMap[index].click();
						}
					});
					
					Window.closeAll();
				}
				
				if (sid == Stock.COINS) {
					Window.closeAll();
					return false;
				}
				
				if (onMap.length == 0) {
					for each (var spawn:Object in App.user.spawnUnits) {
						if (spawn.sIDs.indexOf(int(sid)) != -1 || spawn.sIDs.indexOf(whereCraft[0]) != -1) {
							new TravelWindow( { 
								findTargets:spawn.lands, 
								popup:true
							} ).show();
							return true;
						}
					}
					if ([1888,1889,1960].indexOf(int(sid)) != -1) {
						Window.closeAll();
						new TravelWindow( { find:Travel.JOHNTOWN } ).show();
						return true;
					}
					if (whereCraft[0] == 1518) {
						new SimpleWindow ( {
							text: Locale.__e('flash:1455190957224'),
							title: Locale.__e('flash:1382952380254'),
							popup: true
						}).show();
						return true;
					}
					if (whereCraft[0] == 2259 || whereCraft[0] == 2260 || whereCraft[0] == 2261) {
						var location:int = User.HOME_WORLD;
						if (App.user.worldID == User.HOME_WORLD) location = Travel.JOHNTOWN;
						new TravelWindow( { 
							find:location, 
							popup:true
						} ).show();
						return true;
					}
					if (whereCraft[0] == 1711) {
						new SimpleWindow ( {
							height:400,
							text: Locale.__e('flash:1458037082237'),
							title: Locale.__e('flash:1382952380254'),
							popup: true
						}).show();
						return true;
					}
					
					for (wid = 0; wid < App.user.lands.length; wid++) {
						world = App.data.storage[App.user.lands[wid]];
						if (world.hasOwnProperty('stacks')) {
							for (bSID in world.stacks) {
								if (sid == world.stacks[bSID] || whereCraft[0] == world.stacks[bSID]) {
									if (App.user.worldID != App.user.lands[wid]) {
										Window.closeAll();
										new TravelWindow( {
											find:App.user.lands[wid],
											popup:true
										}).show();
										return true;
									}
								}
							}
						}
						
						if (world.hasOwnProperty('objects')) {
							for (bSID in world.objects) {
								if (sid == world.objects[bSID] || whereCraft[0] == world.objects[bSID]) {
									if (App.user.worldID != App.user.lands[wid]) {
										Window.closeAll();
										new TravelWindow( {
											find:App.user.lands[wid],
											popup:true
										}).show();
										return true;
									}
								}
							}
						}
					}
					
					Window.closeAll();
					var canBeInShop:Boolean = false;
					if (App.user.worldID != User.HOME_WORLD) {
						canBeInShop = Boolean(whereCraft.length);
						for (var j:int = 0; j < whereCraft.length; j++) {
							if ([2, 4, 14, 3].indexOf(App.data.storage[whereCraft[j]].market) == -1) {
								whereCraft.splice(j, 1);
								j--;
							}
						}
					}
					
					var idWorld:Array = [];
					for (var worldItem:* in App.user.instanceWorlds) {
						for (var item:* in App.user.instanceWorlds[worldItem]) {
							if ([int(sid)].indexOf(int(item)) != -1) {
								idWorld.push(worldItem);
							}
							if (whereCraft.indexOf(int(item)) != -1) {
								idWorld.push(worldItem);
							}
						}
					}
					if (idWorld.length != 0) {
						new TravelWindow( { findTargets:idWorld } ).show();
						return true;
					}
					
					if (canBeInShop || isResources(whereCraft)) {
						Find.find(whereCraft[0]);
						return true;
					}else {
						if (sid == 1934) {
							return false;
						}
						
						//if (DEV) {
							ShopWindow.find( whereCraft );
						//}else {
							//ShopWindow.show( { find:whereCraft } );
						//}
						
						//ShopWindow.show( { find:whereCraft } );
						
						linked = true;
					}
				}
			}else {
				if ([2566, 2567, 2568, 2569, 2603].indexOf(int(sid)) != -1) {
					var unts:Array = Map.findUnits([int(sid)]);
					var qw:int = 971;
					if ([2568, 2569].indexOf(int(sid)) != -1) qw = 973;
					if ([2603].indexOf(int(sid)) != -1) qw = 989;
					if (unts.length > 0) {
						App.map.focusedOn(unts[0], true);
					}else {
						Window.closeAll();
						new SimpleWindow( {
							text:Locale.__e('flash:1455269552420'),
							title:Locale.__e('flash:1382952380254'),
							popup:true,
							confirm:function():void {
								App.ui.upPanel.checkQuests(qw)
							}
						}).show();
					}
					return true;
				}
			}
			
			/*if (!finded && App.data.storage[sid].free == 1) {
				new SimpleWindow( {
					title: Locale.__e('flash:1431685989241'),
					text: Locale.__e('storage:504:description'),
					popup: true
				}).show();
			}*/
			
			return linked;
		}
		
		public static function isResources(wherecraft:Array):Boolean {
			for each (var itm:* in wherecraft) {
				if (App.data.storage[itm].type == 'Resource') return true;
			}
			return false;
		}
		
		public static function containsMaxLevelBuilding(obj:Array):Boolean {
			for each (var building:Building in obj) {
				if (building.level >= building.totalLevels)
					return true;
			}
			return false;
		}
	}
}


import buttons.Button;
import buttons.ImageButton;
import buttons.MoneyButton;
import buttons.MoneySmallButton;
import core.Load;
import core.Size;
import core.TimeConverter;
import effects.Effect;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.ui.Mouse;
import ui.BitmapLoader;
import ui.Cursor;
import ui.Hints;
import units.Anime;
import units.Field;
import units.Unit;
import wins.Window;
import wins.ShopWindow;
import wins.SimpleWindow;

internal class NewsItem extends LayerX {
	
	public var item:*;
	public var update:*;
	public var background:Bitmap;
	public var bttn:Bitmap;
	public var preloader:Preloader = new Preloader();
	public var title:TextField;
	public var priceBttn:Button;
	public var openBttn:Button;
	public var window:*;
	private var maska:Shape;
	
	public function NewsItem(item:*, window:*) {
			
		this.item = item;
		this.window = window;
		
		update = App.data.updates[item.id];
		
		background = Window.backing(220, 274, 10, "itemBacking");
		addChild(background);
		
		var sprite:Sprite = new Sprite();
		addChild(sprite);
		
		maska = new Shape();
		maska.graphics.beginFill(0xFFFFFF, 1);
		maska.graphics.drawRoundRect(0, 0, background.width-20, background.height-20, 30, 30);
		maska.graphics.endFill();
		
		maska.x = (background.width - maska.width) / 2;
		maska.y = (background.height - maska.height) / 2;
		
		bttn = new Bitmap();
		addChild(bttn);		
		addChild(maska)
		bttn.mask = maska
		
		addChild(preloader);
		preloader.x = (background.width)/ 2;
		preloader.y = (background.height)/ 2 - 15;
		
		Load.loading(Config.getImageIcon('updates/icons', update.preview, 'jpg'), onLoad);
		
		addEventListener(MouseEvent.CLICK, onClick);
		addEventListener(MouseEvent.ROLL_OVER, onOver);
		addEventListener(MouseEvent.ROLL_OUT, onOut);
		
		drawTitle();
	}
	
	private function autoSize(txt:TextField):void 
	{
	  //You set this according to your TextField's dimensions
		var maxTextWidth:int = 145; 
		var maxTextHeight:int = 30; 

		var f:TextFormat = txt.getTextFormat();

		while (txt.textWidth > maxTextWidth || txt.textHeight > maxTextHeight) {
		f.size = int(f.size) - 1;
		txt.setTextFormat(f);
		}
	}
	
	private var timer:TextField;
	private var bg:Bitmap;
	private function drawTitle():void {
		
		var title:TextField = Window.drawText(String(update.title), {
			color:0xfffea5,
			borderSize:2,
			borderColor:0x4e2811,
			textAlign:"center",
			autoSize:"center",
			fontSize:26,
			textLeading:-6,
			multiline:true,
			shadowColor:0x4e2811,
			shadowSize:2
		});
		
		//autoSize(title);
		//scaleTextToFitInTextField(title);
		//scaleTextFieldToFitText(title);
		
		title.wordWrap = true;
		title.width = background.width - 50;
		title.y = 20;
		title.x = 25;
		addChild(title);
		
		if (Events.timeOfComplete > App.time && (item.id == '5624df420f093' || item.id == '562de476e0f54')) {
			bg = Window.backing(background.width, 30, 50, 'fadeOutYellow');
			bg.alpha = 0.5;
			bg.y = background.y + background.height - 50;
			addChild(bg);
			
			timer = Window.drawText(Locale.__e('flash:1393581955601') + TimeConverter.timeToStr(Events.timeOfComplete - App.time), {
				color:0xffde00,
				borderSize:2,
				borderColor:0x65340d,
				textAlign:"center",
				autoSize:"center",
				fontSize:22,
				textLeading:-6,
				multiline:true,
				shadowColor:0x4e2811,
				shadowSize:2
			});
			timer.wordWrap = true;
			timer.width = background.width - 50;
			timer.y = background.y + background.height - 50;
			timer.x = 25;
			addChild(timer);
			
			App.self.setOnTimer(updateTime);
		}
	}
	
	private function updateTime():void {
		if (timer) {
			if (Events.timeOfComplete > App.time) {
				timer.text = Locale.__e('flash:1393581955601') + TimeConverter.timeToStr(Events.timeOfComplete - App.time);
			}else {
				timer.visible = false;
				bg.visible = false;
				App.self.setOffTimer(updateTime);
			}
		}
	}
	
	private function onLoad(data:Bitmap):void {
		
		removeChild(preloader);
		
		bttn.bitmapData = data.bitmapData
		bttn.x = (background.width - bttn.width) / 2;
		bttn.y = (background.height - bttn.height) / 2;
		
	}
	
	private function onClick(e:MouseEvent = null):void {
		window.setContentNews(item);
	}
	private function onOver(e:MouseEvent):void {
		Effect.light(this, 0.1);
	}
	private function onOut(e:MouseEvent):void {
		Effect.light(this);
	}
	
	public function dispose():void {
		App.self.setOffTimer(updateTime);
		removeEventListener(MouseEvent.CLICK, onClick);
		removeEventListener(MouseEvent.ROLL_OVER, onOver);
		removeEventListener(MouseEvent.ROLL_OUT, onOut);
	}
}


internal class BestSellers extends Sprite {
	public var win:*;
	public var bg:Bitmap;
	public var items:Array = [];
	public var content:Array = [];
	
	public function BestSellers(win:*) {
		for each(var sid:* in App.data.bestsellers) {
			var item:Object = App.data.storage[sid];
			if (item != null && item.visible != 0) {
				if (item.hasOwnProperty('instance') && (World.getBuildingCount(sid) >= getInstanceNum(sid) || App.user.level < item.instance.level[World.getBuildingCount(sid) + 1])) 
					continue;
				
				if ((item.type == 'Resource' || item.type == 'Decor') && App.user.level < item.level)
					continue;
				
				item.id = sid;
				item['_order'] = int(Math.random() * 100);
				content.push(item);
			} 
		}
		
		content.sortOn('_order');
		
		this.win = win;
		
		drawItems();
		drawTitle();
	}
	
	private function getInstanceNum(sid:int):int {
		var count:int = 0;
		var test:* = App.data.storage[sid].instance['level']
		for each(var inst:* in App.data.storage[sid].instance['level']) {
			count++;
		}
		return count;
	}
	
	public function drawItems():void {
		var cont:Sprite = new Sprite();
		var X:int = 0;
		
		var _length:int = Math.min(5, content.length);
		for (var i:int = 0; i < _length; i++) {
			var item:BestSellerItem = new BestSellerItem(content[i], this);
			cont.addChild(item);
			item.x = X;
			X += item.bg.width + 1;
		}
		
		cont.y = 12;
		addChild(cont);
	}
	
	private function drawTitle():void {
		
		bg = Window.backing(380, 24, 50, 'fadeOutWhite');
		bg.x = (this.width - bg.width) / 2;
		bg.y = -18 + 3;
		bg.alpha = 0.3;
		addChild(bg);
		
		var title:TextField = Window.drawText(Locale.__e('flash:1382952380296'), {
			color:0xfffea5,
			borderSize:2,
			borderColor:0x4e2811,
			textAlign:"center",
			autoSize:"center",
			fontSize:24,
			textLeading:-6,
			multiline:true,
			shadowColor:4e2811,
			shadowSize:2
		});
		title.wordWrap = true;
		title.width = bg.width;
		title.y = -18;
		title.x = bg.x;
		
		addChild(title);
	}
	
	public function dispose():void {
		for each(var _item:* in items) {
			_item.dispose();
		}
	}
}


internal class BestSellerItem extends Sprite {
	
	public var bg:Bitmap;
	public var item:Object;
	private var bitmap:Bitmap;
	private var buyBttn:*;
	private var buyBttnNow:MoneySmallButton;
	private var _parent:*;
	private var preloader:Preloader = new Preloader();
	private var sprite:LayerX;
	
	public function BestSellerItem(item:Object, parent:*) {
		this._parent = parent;
		this.item = item;
		bg = Window.backing(136, 145, 15, 'itemBacking');
		addChild(bg);
		
		sprite = new LayerX();
		addChild(sprite);
			
		bitmap = new Bitmap();
		sprite.addChild(bitmap);
			
		sprite.tip = function():Object { 
			
			if (item.type == "Plant") {
				return {
					title:item.title,
					text:Locale.__e("flash:1382952380297", [TimeConverter.timeToCuts(item.levelTime * item.levels), item.experience, App.data.storage[item.out].cost])
				};
			} else if (item.type == "Decor") {
				return {
					title:item.title,
					text:Locale.__e("flash:1382952380076", [String(item.experience)])
				}	
			} else {
				return {
					title:item.title,
					text:item.description
				};
			}
		};
		
		drawTitle();
		drawBttn();
		
		addChild(preloader);
		preloader.x = (bg.width)/ 2;
		preloader.y = (bg.height)/ 2;
		
		if (item.type == 'Golden') {
			Load.loading(Config.getSwf(item.type, item.preview), onLoadAnimate);
		} else{
			Load.loading(Config.getIcon(item.type, item.preview), onLoad);
		}
	}
	
	private function onLoad(data:Bitmap):void {
		removeChild(preloader);
		bitmap.bitmapData = data.bitmapData;
		bitmap.smoothing = true;
		
		Size.size(bitmap, bg.width - 10, bg.height);
		
		bitmap.x = (bg.width - bitmap.width) / 2;
		bitmap.y = (bg.height - bitmap.height) / 2;
	}
	
	private function onLoadAnimate(swf:*):void {
		removeChild(preloader);
		
		var anime:Anime = new Anime(swf, { w:bg.width - 20, h:bg.height - 40 } );
		anime.x = (bg.width - anime.width) / 2;
		anime.y = (bg.height - anime.height) / 2;
		sprite.addChildAt(anime,1);
	}
	
	public function drawTitle():void {
		var title:TextField = Window.drawText(String(item.title), {
			color:0x814f31,
			borderColor:0xfcf6e4,
			textAlign:"center",
			//autoSize:"center",
			fontSize:22,
			textLeading:-8,
			multiline:true,
			wrap:true,
			width:bg.width
		});
		title.wordWrap = true;
		//title.width = bg.width - 10;
		title.y = 5;// (bg.width - title.width) / 2;
		title.x = (bg.width - title.width)/2;
		addChild(title);
	}
	
	public var money_sid:*;
	public function drawBttn():void {
		var bttnSettings:Object = {
			caption     :Locale.__e("flash:1382952379751"),
			width		:118,
			height		:43,
			fontSize	:24,
			scale		:0.8,
			hasDotes    :false
		}
		
		var price:Object = item.price;
	
		for (money_sid in price) {
			if (int(money_sid) == Stock.FANT) {
				bttnSettings['type'] = 'real';
				bttnSettings['countText'] = price[money_sid];
				bttnSettings["bgColor"] = [0x9ff143, 0x7cc320];
				bttnSettings["borderColor"] = [0xc4bea6, 0x947a45];
				bttnSettings["bevelColor"] = [0xd8fc94, 0x449209];
				bttnSettings["fontColor"] = 0xbaee8a;				
				bttnSettings["fontBorderColor"] = 0x40680b;
				bttnSettings["fontSize"] = 26;
			} else {
				bttnSettings['type'] = 'coins';
				bttnSettings['countText'] = price[money_sid];
				bttnSettings["fontColor"] = 0xfedb38;				
				bttnSettings["fontBorderColor"] = 0x80470b;
				bttnSettings["fontSize"] = 26;
			}
		}
		
		if (price == null ) {
			if (item.hasOwnProperty('instance')) {
				var countOnMap:int = World.getBuildingCount(item.sid) + App.user.stock.count(item.sid);
				if (!item.instance.cost.hasOwnProperty(countOnMap + 1)) {
					while (!item.instance.cost.hasOwnProperty(countOnMap + 1) && countOnMap > 0) {
						countOnMap --;
					}
				}
				
				price = item.instance.cost[countOnMap+1];
				for  (var sID:* in item.instance.cost[countOnMap+1]) {
					if (sID == Stock.FANT) {
						/*count = sID;
						sidColor = sID;*/
						break;
					}
				}
				
				for (money_sid in price) {
					if (int(money_sid) == Stock.FANT) {
						bttnSettings['type'] = 'real';
						bttnSettings['countText'] = price[money_sid];
						bttnSettings["bgColor"] = [0x9ff143, 0x7cc320];
						bttnSettings["borderColor"] = [0xc4bea6, 0x947a45];
						bttnSettings["bevelColor"] = [0xd8fc94, 0x449209];
						bttnSettings["fontColor"] = 0xbaee8a;				
						bttnSettings["fontBorderColor"] = 0x40680b;
						bttnSettings["fontSize"] = 26;
					} else {
						bttnSettings['type'] = 'coins';
						bttnSettings['countText'] = price[money_sid];
						bttnSettings["fontColor"] = 0xfedb38;				
						bttnSettings["fontBorderColor"] = 0x80470b;
						bttnSettings["fontSize"] = 26;
					}
				}
			}
		}
		
		buyBttn = new MoneySmallButton(bttnSettings);
		buyBttn.x = (bg.width - buyBttn.width) / 2;
		buyBttn.y = bg.height - 24;
		buyBttn.coinsIcon.y -= 3;
		buyBttn.countLabel.y += 2;
		addChild(buyBttn);
		buyBttn.addEventListener(MouseEvent.CLICK, onBuyNow);
		
	}
	
	private function onBuyNow(e:MouseEvent):void {
		if (e.currentTarget.mode == Button.DISABLED) 
			return;
			
		e.currentTarget.state = Button.DISABLED;
		if (!App.user.stock.checkAll(item.price))
			return;
		
		ShopWindow.currentBuyObject = { type:item.type, sid:item.sid };
		
		var unit:Unit;
		switch(item.type) {
			case "Material":
				App.user.stock.buy(item.sid, 1, onBuyComplete);
				break;
			case "Boost":
			case "Energy":
				App.user.stock.pack(item.sid, onBuyComplete);
				break;
			default:
				if (item.sid == 54 && App.user.quests.data["16"] == undefined) {
					new SimpleWindow( {
						text:Locale.__e('flash:1383043022250', [App.data.quests[16].title]),
						label:SimpleWindow.ATTENTION
					}).show();
					break;
				}
				unit = Unit.add( { sid:item.sid, buy:true } );
				
				unit.move = true;
				App.map.moved = unit;
				
				
			break;
		}
		
		if(item.type != "Material"){
			_parent.win.close();
		}
	}
	
	public function onBuyComplete(type:*, price:uint = 0):void {
		var point:Point = new Point(App.self.mouseX - buyBttn.mouseX, App.self.mouseY - buyBttn.mouseY);
		point.x += buyBttn.width / 2;
		Hints.minus(money_sid, item.price[money_sid], point, false, App.self.tipsContainer);
		buyBttn.state = Button.NORMAL;
		
		flyMaterial();
	}
	
	private function onBuy(e:MouseEvent):void {
		_parent.win.close();
		new ShopWindow( { find:[item.sID], forcedClosing:true, popup: true } ).show();
	}
	
	public function dispose():void {
		if(buyBttn)buyBttn.removeEventListener(MouseEvent.CLICK, onBuy);
		if(buyBttnNow)buyBttn.removeEventListener(MouseEvent.CLICK, onBuyNow);
	}
	
	private function flyMaterial():void {
		var item:BonusItem = new BonusItem(item.sid, 0);
		
		var point:Point = Window.localToGlobal(bitmap);
		point.y += bitmap.height / 2;
		item.cashMove(point, App.self.windowContainer);
	}
}