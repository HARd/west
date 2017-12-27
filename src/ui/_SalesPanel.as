package ui 
{
	import buttons.ImagesButton;
	import core.CookieManager;
	import core.Load;
	import core.Post;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import flash.utils.setTimeout;
	import wins.BankSaleWindow;
	import wins.BigsaleWindow;
	import wins.actions.PromoWindow;
	import wins.actions.SaleLimitWindow;
	import wins.actions.SalesWindow;
	import wins.ThematicalSaleWindow;
	import wins.Window;
	/**
	 * ...
	 * @author 
	 */
	public class SalesPanel extends Sprite
	{
		public var promoIcons:Array = [];
		public var newPromo:Object = { };
		public var promoPanel:Sprite = new Sprite();
		
		public static var iconHeight:uint = 80;
		
		public var paginator:PromoPaginator;
		
		public function SalesPanel() 
		{
			
			paginator = new PromoPaginator(App.user.promos, 2, this);
			paginator.drawArrows();
			
			addChild(promoPanel);
			
			//if(App.data.promo){
				setTimeout(initPromo, 100);
			//}
		}
		
		public var bankSaleIcons:Array = [];
		public function addBankSaleIcon(btmd:BitmapData):void
		{
			var bttn:ImagesButton = getBankSaleIcon(bttn, btmd);
			bankSaleIcons.push(bttn);
			
			bttn.addEventListener(MouseEvent.CLICK, onPromoOpen);
			bttn.x = 35 - bttn.bitmap.width/2;
			
			bttn.startRotate(420);
			
			promoPanel.addChild(bttn);
			
			promoPanel.y = 160;
			
			saleLimit = 0;
			createPromoPanel();
		}
		
		public function initPromo():void {
			//createPromoPanel();
			//promoTime();
			App.user.quests.checkPromo();
		}
		
		private function startGlow(bttn:ImagesButton):void {
			bttn.showGlowing();
			bttn.showPointing("left", 0, promoPanel.y, App.ui.salesPanel, Locale.__e("flash:1382952379795"), {
				color:0xffd619,
				borderColor:0x7c3d1b,
				autoSize:"left",
				fontSize:24
			}, true);
		}
		
		public var iconDealSpot:*;
		public function createDealSpot(swf:*):void {
			iconDealSpot = swf;
			promoPanel.addChild(iconDealSpot);
			iconDealSpot.x = 120;
			iconDealSpot.y = 0;
		}
		
		/*private var promoIconId:uint = 0;
		private var promos:Array = [];
		public function createPromoPanel():void 
		{
			promos = [];
			if (App.data.promo == null) return;
			clearPromoPanel();
			promoIconId = 0;
			//if (App.user.quests.chapters.indexOf(2) != -1) {
				createBigSales();
				createSales();
			//}
			
			for (var pID:* in App.user.promo)
			{
				var promo:Object = App.data.promo[pID];
				if (App.user.promo[pID].status) continue;
				if (App.time > App.user.promo[pID].started + promo.duration * 3600) continue;
				promos.push({pID:pID, started:App.user.promo[pID].started});
			}
			
			promos.sortOn('started', Array.NUMERIC);
			promos.reverse();
			promos = promos.splice(0, 2);
			
			for (var i:int = 0; i < promos.length; i++) {
				pID = promos[i].pID;
				promo = App.data.promo[pID];
				var bttn:ImagesButton = getPromoIcons(bttn, promo, pID);
				promoIcons.push(bttn);
				
				bttn.addEventListener(MouseEvent.CLICK, onPromoOpen);
				bttn.x = 6;
				bttn.y = iconHeight * promoIconId;
				
				promoPanel.addChild(bttn);
				
				if (App.user.promo[pID].hasOwnProperty('new')) {
					if (App.time < App.user.promo[pID]['new'] + 20)
						startGlow(bttn);
				}
				//checkOnGlow('promo', bttn, pID);
				promoIconId++;
			}
			
			for (i = 0; i < promoIcons.length; i++)
				promoIcons[i].startRotate(i * 420);
			
			promoPanel.y = 160;
			
			
			if (promoIcons.length > 0) {
				promoTime();
				App.self.setOnTimer(promoTime);
			}
			else
			{
				App.self.setOffTimer(promoTime);
			}	
		}*/
		
		private var promoIconId:uint = 0;
		public var iconsPosY:int = 0;
		public function createPromoPanel(isLevelUp:Boolean = false, isPaginatorUpd:Boolean = false):void 
		{
			//if (App.user.quests.chapters.indexOf(2) < 0) return;
			
			promoIconId = 0;
			
			clearPromoPanel();
			createBigSales();
			createSales();
			//createBulks();
			
			iconsPosY = 0;
			var iconY:int = 0;// iconHeight;
			var limit:int = 3;
			
			if (promoIcons.length > 0) {
				iconY = iconHeight * (promoIcons.length) + 30;
			}else if (bankSaleIcons.length > 0) {
				iconY = (iconHeight + 20) * bankSaleIcons.length + 30;
			}
			
			iconsPosY = iconY;
			//promoPanel.y = iconHeight * (promoIcons.length + 1);
			promoPanel.y = 160;
			
			for (var i:int = paginator.startItem; i < paginator.endItem; i++)
			//for (var i:int = 0; i < limit; i++)
			{
				if (App.user.promos.length <= i) break;
				if	(App.user.promos[i].buy) {
					limit++;
					continue;
				}
				
				var pID:String = App.user.promos[i].pID;
				var promo:Object = App.data.actions[pID];
				var bttn:ImagesButton = getPromoIcons(bttn, App.user.promos[i], pID);
				promoIcons.push(bttn);
				bttn.addEventListener(MouseEvent.CLICK, onPromoOpen);
				bttn.x = 40 - bttn.bitmap.width/2;
				bttn.y = iconY;// iconHeight * promoIconId;
				
				promoPanel.addChild(bttn);
				
				iconY += bttn.bitmap.height + 4;
				//if (App.user.promo[pID].prime) {
				var obj:Object = App.user.promo[pID];
				if (App.user.promo[pID].begin_time + 15 > App.time) {
					startGlow(bttn);
				}
				//checkOnGlow('promo', bttn, pID);
				promoIconId++;
				
				if (isLevelUp && !App.user.promos[i].showed) {
					onPromoOpen(null, bttn);
				}
			}
			
			for (i = 0; i < promoIcons.length; i++) {
				promoIcons[i].startRotate(i * 420);
			}
			
				
			//promoPanel.y = 160;
			
			//promoPanel.y = 80;
			
			if (!isPaginatorUpd) {
				resize();
				
				paginator.resize(App.self.stage.stageHeight - iconY - 112);
			}
			
			if (promoIcons.length > 0) {
				promoTime();
				App.self.setOnTimer(promoTime);
			}
			else
			{
				App.self.setOffTimer(promoTime);
			}
		}
		
		
		public function checkOnGlow(type:String, bttn:ImagesButton, pID:*):void 
		{
			if (ExternalInterface.available) 
			{
				var pID:String = String(pID);
				var cookieName:String = pID + "_" + App.user.id;
				var value:String = CookieManager.read(cookieName);
				
				if (type == 'promo')
				{
					if (newPromo.hasOwnProperty(pID)) {
						if (App.time > newPromo[pID]) 
							return;
						
						Post.addToArchive('startGlow: '+ pID);
						startGlow(bttn);
						CookieManager.store(cookieName, '1');
						return;
					}
					else
					{
						if (value == '1') return;
						newPromo[pID] = App.time + 5;
						Post.addToArchive(pID + ' ' + App.data.promo[pID].title + ' : ' + value);
					}
				}
				else if (type == 'sale')
				{
					Post.addToArchive(pID + '  : ' + value);
					
					if (newPromo.hasOwnProperty(pID)) {
						if (App.time > newPromo[pID]) 
							return;
						
						startGlow(bttn);
						CookieManager.store(cookieName, '1');
						return;
					}
					else
					{
						if (value == '1') return;
						newPromo[pID] = App.time + 5;
					}
				}
				
				if (value != '1') {
					Post.addToArchive('startGlow: '+ pID);
					startGlow(bttn);
					CookieManager.store(cookieName, '1');
				}
			}
		}
		
		/*private function promoTime():void {
			for (var pID:* in App.user.promo)
			{
				var promo:Object = App.user.promo[pID];
				if (promo.status) 
					continue;
				
				if (App.time > promo.started + App.data.promo[pID].duration * 3600) {
					promo.status = 1;
					createPromoPanel();
				}
			}
		}*/
		
		private function promoTime():void {
			for (var pID:* in App.user.promo)
			{
				var promo:Object = App.data.actions[pID];
				
				if (promo.begin_time + promo.duration * 3600 < App.time) {
					App.user.updateActions();
					createPromoPanel();
				}
			}
		}
		
		/*public function onPromoOpen(e:MouseEvent = null):void {
			e.currentTarget.hideGlowing();
			e.currentTarget.hidePointing();
			
			var pID:String = e.currentTarget.settings.pID;
			
			if (App.data.promo.hasOwnProperty(pID)) {
				if (checkForOneItem(App.data.promo[pID].items)) {
					new SaleLimitWindow({pID:pID}).show();
				}else {
					new PromoWindow( { pID:pID } ).show();
				}
				return;
			}
			
			if (App.data.sales.hasOwnProperty(pID)) {
				new SalesWindow({
						ID:pID,
						action:App.data.sales[pID],
						mode:SalesWindow.SALES
					}).show();
				return;
			}
			
			if (App.data.bigsale.hasOwnProperty(e.currentTarget.settings.pID)){
				new BigsaleWindow( { sID:e.currentTarget.settings.pID } ).show();
				return;
			}
		}*/
		
		public function onPromoOpen(e:MouseEvent = null, bttn:* = null):void {
			var target:*;
			if (e) {
				target = e.currentTarget;
				target.hideGlowing();
				target.hidePointing();
			}
			else if (bttn) {
				target = bttn;
				//bttn.showPointing("left", 0, 0, bttn)
			}
			
			var pID:String = target.settings.pID;
			
			//e.currentTarget.hideGlowing();
			//e.currentTarget.hidePointing();
			//
			//var pID:String = e.currentTarget.settings.pID;
			//var target:* = e.currentTarget;
			
			if (target.settings['sale'] == 'bankSale'){
				new BankSaleWindow().show();
				return;
			}
			
			if (target.settings['sale'] == 'promo' && App.data.actions.hasOwnProperty(pID)){
				new PromoWindow( { pID:pID } ).show();
				//new ThematicalSaleWindow({ pID:pID }).show();
				App.user.unprimeAction(pID);
				return;
			}
			
			if (target.settings['sale'] == 'sales' && App.data.sales.hasOwnProperty(pID)) {
				new SalesWindow({
						ID:pID,
						action:App.data.sales[pID],
						mode:SalesWindow.SALES
					}).show();
				return;
			}
			
			if (target.settings['sale'] == 'bigsale' && App.data.bigsale.hasOwnProperty(pID)){
				new BigsaleWindow( { sID:pID } ).show();
				return;
			}
			
			if (App.data.bulks.hasOwnProperty(pID)) {
				
				new SalesWindow( {
					action:App.data.bulks[pID],
					pID:pID,
					mode:SalesWindow.BULKS,
					width:670,
					title:Locale.__e('flash:1385132402486')
				}).show();
				return;
			}
		}
		
		private function checkForOneItem(items:Object):Boolean 
		{
			var num:int = 0;
			for (var it:* in items) {
				num++;
			}
			if (num > 1) 
				return false;
				
			return true;
		}
		
		/*private function getPromoIcons(bttn:ImagesButton, item:Object, pID:String = ""):ImagesButton {
			
			var bitmap:Bitmap = new Bitmap(new BitmapData(75,75, true, 0), "auto", true);
			bttn = new ImagesButton(bitmap.bitmapData, null, { pID:pID } );
			
			for (var sID:* in item.items) break;
			var url:String = Config.getIcon(App.data.storage[sID].type, App.data.storage[sID].preview);
			
			var textSettings:Object = {
				text:Locale.__e("flash:1382952379793"),
				color:0xf0e6c1,
				fontSize:19,
				borderColor:0x634807,
				scale:0.5,
				textAlign:'center',
				multiline:true
			}
			
			var iconSettings:Object = {
				scale:0.5,
				filter:[new GlowFilter(0xf8da0f, 1, 4, 4, 8, 1)]
			}
			
			
			var title:TextField = Window.drawText(textSettings.text, textSettings);
			title.wordWrap = true;
			title.width = 60;
			//title.border = true;
			title.height = title.textHeight + 4;
			
			
			Load.loading(Config.getImage('promo/icons', item.preview), function(data:*):void {
				bttn.bitmapData = data.bitmapData;
				
				Load.loading(url, function(data:*):void {
					
					
					bttn.icon = data.bitmapData;
					bttn.iconBmp.scaleX = bttn.iconBmp.scaleY = iconSettings.scale;
					bttn.iconBmp.smoothing = true;
					bttn.iconBmp.filters = iconSettings.filter;
					bttn.iconBmp.x = (bttn.bitmap.width - bttn.iconBmp.width)/2;
					bttn.iconBmp.y = (bttn.bitmap.height - bttn.iconBmp.height) / 2;
					
					bttn.addChild(title);
					title.x = (bttn.bitmap.width - title.width)/2 - 2;
					title.y = (bttn.bitmap.height - title.height)/2 + 14;
					
					bttn.initHotspot();
				});
			});
			
			bttn.tip = function():Object {
						
				var text:String;
				var time:int = item.duration * 3600 - (App.time - App.user.promo[pID].started);
				if (time < 60)
					text = Locale.__e('flash:1382952379794',[TimeConverter.timeToCuts(time, true, true)]);
				else
					text = Locale.__e('flash:1382952379794',[TimeConverter.timeToCuts(time, true, true)]);
				
				return {
					title:Locale.__e(item.title),
					text:text,
					timer:true
				}
			};	
			
			return bttn;
		}*/
		
		private function getPromoIcons(bttn:ImagesButton, item:Object, pID:String = ""):ImagesButton {
			
			var textSettings:Object = {
				text:Locale.__e("flash:1382952379793"),
				color:0xf0e6c1,
				fontSize:19,
				borderColor:0x634807,
				scale:0.5,
				textAlign:'center',
				multiline:true
			}
			
			var iconSettings:Object = {
				scale:0.5
				//filter:[new GlowFilter(0xf8da0f, 1, 4, 4, 8, 1)]
			}
			
			var bitmap:Bitmap; 
			switch(item.preview) {
				case "star1":
					//bitmap = new Bitmap(new BitmapData(82, 79, true, 0), "auto", true);
					bitmap = new Bitmap(UserInterface.textures.saleBacking1);
					textSettings['color'] = 0xffffff;
					textSettings['borderColor'] = 0x6d2c08;
				break;
				case "star2":
					//bitmap = new Bitmap(new BitmapData(95, 92, true, 0), "auto", true);
					bitmap = new Bitmap(UserInterface.textures.saleBacking3);
					textSettings['color'] = 0xffffff;
					textSettings['borderColor'] = 0x23534a;
				break;
				case "round":
					//bitmap = new Bitmap(new BitmapData(85, 85, true, 0), "auto", true);
					bitmap = new Bitmap(UserInterface.textures.saleBacking2);
					textSettings['color'] = 0xffffff;
					textSettings['borderColor'] = 0x272a49;
				break;
				default:
					bitmap = new Bitmap(UserInterface.textures.saleBacking2);
					textSettings['color'] = 0xffffff;
					textSettings['borderColor'] = 0x272a49;
			}
			
			bttn = new ImagesButton(bitmap.bitmapData, null, { pID:pID, sale:'promo' } );
			
			var _items:Array = [];
			for (var sID:* in item.items) {
				_items.push( { sID:sID, order:item.iorder[sID] } );
			}
			_items.sortOn('order');
			sID = _items[0].sID;
			
			var url:String = Config.getIcon(App.data.storage[sID].type, App.data.storage[sID].preview);
			
			switch(sID) {
				case Stock.COINS:
					url = Config.getIcon("Coins", "gold_01");
				break;
				case Stock.FANT:
					url = Config.getIcon("Reals", "crystal_02");
				break;
			}
				
			title = Window.drawText(textSettings.text, textSettings), {
				fontSize:19,
				color:0xffffff,
				borderColor:0x68270d,
				textAlign:'center',
				multiline:true,
				width:70,
				distShadow:0
			};
			
			/*Load.loading(Config.getImageIcon('promo/bg', item.preview), function(data:*):void {
				bttn.bitmapData = data.bitmapData;*/
				
				Load.loading(url, function(data:*):void {
					
					bttn.icon = data.bitmapData;
					bttn.iconBmp.scaleX = bttn.iconBmp.scaleY = 0.5;
					bttn.iconBmp.smoothing = true;
					bttn.iconBmp.filters = iconSettings.filter;
					bttn.iconBmp.x = (bttn.bitmap.width - bttn.iconBmp.width) / 2 + 1;
					bttn.iconBmp.y = (bttn.bitmap.height - bttn.iconBmp.height) / 2;
					bttn.addChild(title);
					title.x = (bttn.bitmap.width - title.width)/2 - 4;
					title.y = (bttn.bitmap.height - title.height)/2 + 20;
					bttn.initHotspot();
				});
				
			//});
			
			bttn.tip = function():Object {
						
				var text:String;
				var time:int = item.duration * 3600 - (App.time - item.time/*App.user.promo[pID].begin_time*/);
				if (time < 60)
					text = Locale.__e('flash:1382952379794',[TimeConverter.timeToStr(time)]);
				else
					text = Locale.__e('flash:1382952379794',[TimeConverter.timeToStr(time)]);
				
				return {
					title:Locale.__e(item.title),
					text:text,
					timer:true
				}
			};
			
			return bttn;
		}
		
		//public function actionTimer():void 
		//{
			//var time:int = item.duration * 3600 - (App.time - App.user.promo[pID].begin_time);
			//if (time < 0) time = 0;
			//title.text = TimeConverter.timeToStr(time);
			////title.x = -timeWork.width / 2;
			//
			//if (time <= 0) {
				////isWork = false;
				//close();
			//}
		//}
		
		private function getSaleIcon(bttn:ImagesButton, item:Object, pID:String = ""):ImagesButton {
			
			var textSettings:Object = {
				text:Locale.__e("flash:1382952379793"),
				color:0xf0e6c1,
				fontSize:19,
				borderColor:0x634807,
				scale:0.5,
				textAlign:'center'
			}
			
			var iconSettings:Object = {
				scale:1,
				filter:[new GlowFilter(0xf8da0f, 1, 4, 4, 8, 1)]
			}
			
			var bitmap:Bitmap; 
			switch(item.bg) {
				case "star1":
					bitmap = new Bitmap(new BitmapData(82, 79, true, 0), "auto", true);
					//bitmap = new Bitmap(UserInterface.textures.saleBacking1);
					textSettings['color'] = 0xffffff;
					textSettings['borderColor'] = 0x6d2c08;
					iconSettings.scale = 0.9;
				break;
				case "star2":
					bitmap = new Bitmap(new BitmapData(95, 92, true, 0), "auto", true);
					//bitmap = new Bitmap(UserInterface.textures.saleBacking3);
					textSettings['color'] = 0xffffff;
					textSettings['borderColor'] = 0x23534a;
				break;
				case "round":
					bitmap = new Bitmap(new BitmapData(85, 85, true, 0), "auto", true);
					//bitmap = new Bitmap(UserInterface.textures.saleBacking2);
					textSettings['color'] = 0xffffff;
					textSettings['borderColor'] = 0x272a49;
				break;
			}
			bttn = new ImagesButton(bitmap.bitmapData, null, { pID:pID, sale:'sales' } );
			
			var url_icon:String = Config.getImageIcon('sales/image', item.image);
			var url_bg:String = Config.getImageIcon('sales/bg', item.bg);
			
			textSettings.text = "";// Locale.__e("");
			textSettings.fontSize = 19;
			//iconSettings.scale = 1;
			iconSettings.filter = [];
			
			var text:TextField = Window.drawText(textSettings.text, textSettings);
			bttn.addChild(text);
			//text.border = true;
			
			text.width = 95;
			text.x = -10;
			text.y = 45;
			/*var bmd:BitmapData = new BitmapData(text.textWidth + 15, text.textHeight +10, true,0);
			bmd.draw(cont);
			
			cont = null;
			text = null;
			var _bitmap:Bitmap = new Bitmap(bmd);*/
			
			Load.loading(url_bg, function(data:*):void {
				bttn.bitmapData = data.bitmapData;
				
				Load.loading(url_icon, function(data:*):void {
					
					bttn.icon = data.bitmapData;
					bttn.iconBmp.scaleX = bttn.iconBmp.scaleY = iconSettings.scale;
					bttn.iconBmp.smoothing = true;
					bttn.iconBmp.filters = iconSettings.filter;
					bttn.iconBmp.x = (bttn.bitmap.width - bttn.iconBmp.width) / 2;
					bttn.iconBmp.y = (bttn.bitmap.height - bttn.iconBmp.height) / 2;
					
					/*bttn.addChild(_bitmap);
					_bitmap.x = (bttn.bitmap.width - _bitmap.width) / 2;
					_bitmap.y = (bttn.bitmap.height - _bitmap.height) / 2 + 8;*/
					
					bttn.initHotspot();
				});
			});
			
			App.self.setOnTimer(_update);
			function _update():void 
			{
				var time:int = item.duration * 3600 - (App.time - item.time);
				text.text = TimeConverter.timeToStr(time);
				if (time < 0) {
					App.self.setOffTimer(_update);
					createPromoPanel();
				}
			}
			
			bttn.tip = function():Object {
						
				var text:String;
				var time:int = item.duration * 3600 - (App.time - item.time);
				if (time < 60)
					text = Locale.__e('flash:1382952379794',[TimeConverter.timeToCuts(time, true, true)]);
				else
					text = Locale.__e('flash:1382952379794',[TimeConverter.timeToCuts(time, true, true)]);
				
				return {
					title:Locale.__e(item.title),
					text:text,
					timer:true
				}
			};	
			
			return bttn;
		}
		
		private function getBankSaleIcon(bttn:ImagesButton, btmd:BitmapData):ImagesButton
		{
			var textSettings:Object = {
				text:Locale.__e("flash:1382952379793"),
				fontSize:19,
				color:0xffffff,
				borderColor:0x23534a,
				scale:0.5,
				textAlign:'center'
			}
			
			var iconSettings:Object = {
				scale:1,
				filter:[new GlowFilter(0xf8da0f, 1, 4, 4, 8, 1)]
			}
			
			bttn = new ImagesButton(btmd, null, { sale:'bankSale' } );
			
			var url_icon:String = Config.getImage('bankSale', "sale01");
			
			textSettings.text = "";// Locale.__e("");
			textSettings.fontSize = 19;
			iconSettings.filter = [];
			
			var text:TextField = Window.drawText(textSettings.text, textSettings);
			bttn.addChild(text);
			
			text.width = 95;
			text.x = -2;
			text.y = 60;
			
			Load.loading(url_icon, function(data:*):void {
				
				bttn.icon = data.bitmapData;
				bttn.iconBmp.scaleX = bttn.iconBmp.scaleY = iconSettings.scale;
				bttn.iconBmp.smoothing = true;
				bttn.iconBmp.filters = iconSettings.filter;
				bttn.iconBmp.x = (bttn.bitmap.width - bttn.iconBmp.width) / 2;
				bttn.iconBmp.y = (bttn.bitmap.height - bttn.iconBmp.height) / 2;
				
				bttn.initHotspot();
			});
			
			App.self.setOnTimer(_update);
			
			var timeToEnd:int = 0;
			if(App.data.money && App.data.money && App.time >= App.data.money.date_from && App.time < App.data.money.date_to && App.data.money.enabled == 1)
				timeToEnd = App.data.money.date_to;
			else if (App.user.money > App.time)
				timeToEnd = App.user.money;
			
			function _update():void 
			{
				var time:int = timeToEnd - App.time;
				text.text = TimeConverter.timeToStr(time);
				if (time < 0) {
					App.self.setOffTimer(_update);
					saleLimit = 1;
					for each(var bttnB:ImagesButton in bankSaleIcons) {
						bttnB.hidePointing();
						bttnB.hideGlowing();
						promoPanel.removeChild(bttnB);
					}
					
					bankSaleIcons = [];
					createPromoPanel();
				}
			}
			
			bttn.tip = function():Object {
						
				var text:String;
				var time:int = timeToEnd - App.time;
				if (time < 60)
					text = Locale.__e('flash:1382952379794',[TimeConverter.timeToCuts(time, true, true)]);
				else
					text = Locale.__e('flash:1382952379794',[TimeConverter.timeToCuts(time, true, true)]);
				
				return {
					title:Locale.__e("flash:1396606263756"),
					text:text,
					timer:true
				}
			};	
			
			return bttn;
		}
		
		public function clearIconsGlow():void {
			for (var i:int = 0; i < promoIcons.length; i++){
				promoIcons[i].hideGlowing();
				promoIcons[i].hidePointing();
			}	
		}
		
		private function clearPromoPanel():void {
			
			for each(var bttn:ImagesButton in promoIcons) {
				bttn.hidePointing();
				bttn.hideGlowing();
				promoPanel.removeChild(bttn);
			}
			
			promoIcons = [];
		}
		
		private var openSale:Boolean = false;
		private var saleLimit:int = 1;
		private var title:TextField;
		private function createSales():void {
			
			if (App.data.sales == null) 
				return;
				
			var iconY:int = 0;
			
			var countSales:int = 0;
			for (var saleID:* in App.data.sales) {
				if (countSales >= saleLimit)
					break;
				
				if (App.data.sales[saleID].hasOwnProperty('social') && !App.data.sales[saleID].social.hasOwnProperty(App.social)) 
				continue;
				
				var sale:Object = App.data.sales[saleID];
				if (sale.unlock.level > App.user.level)
					continue;
				if (App.time > sale.time + sale.duration * 3600)
					continue;
				
				var bttn:ImagesButton = getSaleIcon(bttn, sale, saleID);
				promoIcons.push(bttn);
				
				bttn.addEventListener(MouseEvent.CLICK, onPromoOpen);
				bttn.x = 40 - bttn.bitmap.width/2;
				//bttn.y = iconHeight * promoIconId;
				bttn.y = iconY;
				
				iconY += bttn.bitmap.height + 4;
				
				promoPanel.addChild(bttn);
				
				promoPanel.y = 160;
				if (App.data.sales[saleID].time + 15 > App.time) {
					startGlow(bttn);
				}
				//checkOnGlow('sale', bttn, saleID);
				
				promoIconId++;
				countSales++;
				
				if (!openSale) {
					openSale = true;
					//bttn.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
				}
			}
		}
		
		private function createBigSales():void
		{
			var sales:Array = [];
			var sale:Object;
			for (var sID:* in App.data.bigsale) {
				sale = App.data.bigsale[sID];
				if(sale.social == App.social)
					sales.push({sID:sID, order:sale.order, sale:sale});
			}
			sales.sortOn('order');
			for each(sale in sales)
			{
				if (App.time > sale.sale.time && App.time < sale.sale.time + sale.sale.duration * 3600)
				{
					var bttn:ImagesButton = getBigSaleIcon(bttn, sale.sale, sale.sID);
					promoIcons.push(bttn);
					
					bttn.addEventListener(MouseEvent.CLICK, onPromoOpen);
					bttn.x = 6;
					bttn.y = iconHeight * promoIconId;
					
					promoPanel.addChild(bttn);
					checkOnGlow('sale', bttn, sale.sID);
					
					promoIconId++;
					break;
				}
			}
		}
		
		private function getBigSaleIcon(bttn:ImagesButton, sale:Object, pID:String = ''):ImagesButton {
			
			var bitmap:Bitmap = new Bitmap(new BitmapData(75,75, true, 0), "auto", true);
			bttn = new ImagesButton(bitmap.bitmapData, null, { pID:pID } );
			
			var material:uint = sale.items[0].sID
			var url_icon:String = Config.getIcon(App.data.storage[material].type, App.data.storage[material].preview);
			var url_bg:String = Config.getImage('sales/bg', 'glow');
			
			var textSettings:Object = {
				text:"",
				color:0xf0e6c1,
				fontSize:19,
				borderColor:0x634807,
				scale:0.55,
				textAlign:'center'
			}
			
			var iconSettings:Object = {
				scale:0.55,
				filter:[new GlowFilter(0xf8da0f, 1, 4, 4, 8, 1)]
			}
			
			var text:TextField = Window.drawText(textSettings.text, textSettings);
			text.width = 95;
			text.x = -10;
			text.y = 45;
			
			Load.loading(url_bg, function(data:*):void {
				bttn.bitmapData = data.bitmapData;
				
				Load.loading(url_icon, function(data:*):void {
					bttn.icon = data.bitmapData;
					bttn.iconBmp.scaleX = bttn.iconBmp.scaleY = iconSettings.scale;
					bttn.iconBmp.smoothing = true;
					bttn.iconBmp.filters = iconSettings.filter;
					bttn.iconBmp.x = (bttn.bitmap.width - bttn.iconBmp.width)/2 - 5;
					bttn.iconBmp.y = (bttn.bitmap.height - bttn.iconBmp.height)/2 - 6;
					
					bttn.addChild(text);
					bttn.initHotspot();
				});
			});
			
			App.self.setOnTimer(update);
			
			function update():void {
				var time:int = sale.duration * 3600 - (App.time - sale.time);
				text.text = TimeConverter.timeToStr(time);
				if (time < 0) {
					App.self.setOffTimer(update);
					createPromoPanel();
				}
			}
			
			bttn.tip = function():Object {
				return {
					title:Locale.__e(sale.title)
				}
			};	
			
			return bttn;
		}
		
		public function hide():void {
			this.visible = false;
		}
		
		public function show():void {
			this.visible = true;
		}
		
		public function resize():void {
			this.x = App.self.stage.stageWidth - 82;
			
			
			//var newHeight:int = 0;
			//if (promoIcons.length > 0) {
				//newHeight = iconHeight * (promoIcons.length)
			//}else if (bankSaleIcons.length > 0) {
				//newHeight = (iconHeight + 20) * bankSaleIcons.length;
			//}
			//
			//paginator.resize(App.self.stage.stageHeight - newHeight - 82);
			trace();
		}
		
	}

}


import buttons.ImageButton;
import flash.display.Sprite;
import flash.events.MouseEvent;
import wins.Window;
import ui.QuestIcon;
import ui.SalesPanel;

internal class PromoPaginator extends Sprite{
	
	public var startItem:uint = 0;
	public var endItem:uint = 0;
	public var length:uint = 0;
	public var itemsOnPage:uint = 0;
	
	public var _parent:SalesPanel;
	public var data:Array;
	
	public function PromoPaginator(data:Array, itemsOnPage:uint, _parent:SalesPanel) {
		
		this._parent = _parent;
		this.data = data;
		length = data.length;
		startItem = 0;
		this.itemsOnPage = itemsOnPage;
		endItem = startItem + itemsOnPage;
		trace();
	}
	
	public function up(e:* = null):void {
		if (startItem > 0) {
			startItem --;
			endItem = startItem + itemsOnPage;
			change();
		}
	}
	
	public function down(e:* = null):void {
		startItem ++;
		endItem = startItem + itemsOnPage;
		//if (endItem > App.user.quests.opened.length) 
		//	endItem = App.user.quests.opened.length;
			
		change();
	}
	
	public function change():void {
		
		length = App.user.promos.length;
		
		if (startItem == 0){
			arrowUp.visible = false;
		}else{
			arrowUp.visible = true;
		}	
		
		if(startItem + itemsOnPage >= length)
			arrowDown.visible = false;
		else
			arrowDown.visible = true;
		
		_parent.createPromoPanel(false, true);
	}
	
	public var arrowUp:ImageButton;
	public var arrowDown:ImageButton;
	
	public function drawArrows():void
	{
		if (arrowUp == null && arrowDown == null)
		{
			arrowUp = new ImageButton(Window.textures.arrowUp, {scaleX:1, scaleY:1, sound:'arrow_bttn'});
			arrowDown = new ImageButton(Window.textures.arrowUp, {scaleX:1, scaleY:-1, sound:'arrow_bttn'});
			
			_parent.promoPanel.addChild(arrowUp);
			arrowUp.x = 22;
			
			_parent.promoPanel.addChild(arrowDown);
			arrowDown.x = 22;
			
			arrowUp.addEventListener(MouseEvent.CLICK, up);
			arrowDown.addEventListener(MouseEvent.CLICK, down);
		}
		
		setArrowsPosition();
	}
	
	public function resize(_height:uint):void {
		itemsOnPage = 2//Math.floor(_height / 90)//QuestIcon.HEIGHT);
		startItem = 0;
		endItem = startItem + itemsOnPage;
		setArrowsPosition();
		change();
	}
	
	public function setArrowsPosition():void {
		
		arrowUp.y 	= _parent.iconsPosY - arrowUp.height - 14;
		arrowDown.y = 310;
		trace();
	}
}