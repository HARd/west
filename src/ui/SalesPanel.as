package ui 
{
	import buttons.ImageButton;
	import buttons.ImagesButton;
	import com.greensock.easing.Cubic;
	import com.greensock.TweenLite;
	import core.CookieManager;
	import core.Load;
	import core.Numbers;
	import core.Post;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	import units.Character;
	import wins.actions.AnySalesWindow;
	import wins.actions.FattyActionWindow;
	import wins.AddWindow;
	import wins.BankSaleWindow;
	import wins.actions.BanksWindow;
	import wins.BigsaleWindow;
	import wins.actions.BuffetActionWindow;
	import wins.actions.EnlargeStorageWindow;
	import wins.actions.NewSpecialActionWindow;
	import wins.Paginator;
	import wins.actions.PromoWindow;
	import wins.SaleGoldenWindow;
	import wins.actions.SaleLimitWindow;
	import wins.actions.SalesWindow;
	import wins.actions.ShareHeroWindow;
	import wins.actions.SingleSaleWindow;
	import wins.actions.SpecialActionWindow;
	import wins.actions.SpecialBoosterWindow;
	import wins.actions.TemporaryActionWindow;
	import wins.ThematicalSaleWindow;
	import wins.actions.UniqueActionWindow;
	import wins.actions.WholeSaleWindow;
	import wins.Window;
	import wins.WindowEvent;
	import wins.actions.ZoneSaleWindow;
	import wins.actions.WanimalWindow; 
	import wins.TripleSaleWindow;
	
	public class SalesPanel extends Sprite
	{
		private var SALES_ICON_MARGIN:int = 5;
		public var icons:Vector.<SalesIcon> = new Vector.<SalesIcon>;
		public var panelHeight:int = 0;
		public var iconsCount:int = 0;		
		private var iconsTopLimit:int = 2;
		
		public var promoIcons:Array = [];
		public var newPromo:Object = { };
		public var promoPanel:Sprite = new Sprite();
		
		public var paginator:Paginator;
		private var maska:Shape = new Shape();
		
		public var showRibbon:Boolean = false;
		
		public function SalesPanel() 
		{
			addChild(promoPanel);
			
			maska = new Shape();
			maska.graphics.beginFill(0xff0000, 0.3);
			maska.graphics.drawRect(-100, 0, 500, 300);
			maska.graphics.endFill();
			addChild(maska);
			promoPanel.mask = maska;
			
			paginator = new Paginator(0, 1, 0, {
				hasPoints:		false,
				hasButtons:		false
			});
			paginator.drawArrow(this, Paginator.LEFT, 0, 0, {
				texture:		Window.textures.smallArrow
			});
			paginator.drawArrow(this, Paginator.RIGHT, 0, 0, {
				texture:		Window.textures.smallArrow,
				scaleX:			1,
				scaleY:			-1
			});
			paginator.addEventListener(WindowEvent.ON_PAGE_CHANGE, onPageChange);			
			addEventListener(MouseEvent.MOUSE_WHEEL, onWheel);
			
			setTimeout(initPromo, 100);
		}
		
		private var moveTween:TweenLite;
		private function onPageChange(e:WindowEvent = null):void {
			if (moveTween) moveTween.kill();
			
			moveTween = TweenLite.to(promoPanel, 0.2, { ease:Cubic.easeOut, y: maska.y - (SalesIcon.HEIGHT + SALES_ICON_MARGIN) * paginator.page, onComplete:function():void {
				moveTween = null;
			}} );
		}
		private function onWheel(e:MouseEvent):void {
			if (e.delta > 0 && paginator.page > 0) {
				paginator.page --;
				paginator.update();
				onPageChange();
			}else if (e.delta < 0 && paginator.page + iconsCount < icons.length) {
				paginator.page ++;
				paginator.update();
				onPageChange();
			}
		}
		
		
		public function openSaleWindow(e:MouseEvent):void {
			e.stopImmediatePropagation();
			new AnySalesWindow().show();
		}
		
		public var bankSaleIcons:Array = [];
		public var isBankAdd:Boolean = false;
		public function addBankSaleIcon():void
		{
			App.ui.showBankIcon();
		}
		
		public function initPromo():void {
			App.user.quests.checkPromo();
		}
		
		public function createPromoPanel(isLevelUp:Boolean = false, isPaginatorUpd:Boolean = false):void 
		{
			if (App.user.quests.tutorial) {
				paginator.arrowLeft.visible = false;
				paginator.arrowRight.visible = false;
				return;
			}
				
			updateSales(isLevelUp);	
		}
		
		public function updateSales(isLevelUp:Boolean = false):void
		{
			//return;
			if (App.user.quests.tutorial)
				return;
			
			clearPromoPanel();
			
			createVIP();
			createPremium();
			createSales();
			createBulks();
			createBigSales();			
			createPromos(isLevelUp);
			
			paginatorUpdate();
		}
		
		private function paginatorUpdate():void {
			iconsCount = Math.floor(panelHeight / (SalesIcon.HEIGHT + SALES_ICON_MARGIN));
			if (promoPanel.height >= panelHeight) {
				iconsCount = Math.floor((panelHeight - paginator.arrowLeft.height - paginator.arrowRight.height) / (SalesIcon.HEIGHT + SALES_ICON_MARGIN));
			}
			
			paginator.itemsCount = (icons.length - iconsCount > 0) ? (icons.length - iconsCount + 1) : 0;
			paginator.update();
			
			if (icons.length <= 0 || promoPanel.height <= panelHeight) {
				maska.y = 0;
				maska.height = panelHeight;
				paginator.visible = false;
				promoPanel.y = (panelHeight - promoPanel.height) / 2;
			}else {
				maska.y = paginator.arrowLeft.height + (panelHeight - paginator.arrowLeft.height - paginator.arrowRight.height - (SalesIcon.HEIGHT + SALES_ICON_MARGIN) * iconsCount) / 2;
				maska.height = (SalesIcon.HEIGHT + SALES_ICON_MARGIN) * iconsCount;
				paginator.visible = true;
				promoPanel.y = maska.y - (SalesIcon.HEIGHT + SALES_ICON_MARGIN - 5) * paginator.page;
			}
			
			paginator.arrowLeft.x = (SalesIcon.HEIGHT - paginator.arrowLeft.height) / 2 - 10;
			paginator.arrowRight.x = (SalesIcon.HEIGHT - paginator.arrowRight.height) / 2 - 10;
			paginator.arrowLeft.y = maska.y - paginator.arrowLeft.height;
			paginator.arrowRight.y = maska.y + maska.height;
		}
		
		public function checkOnGlow(type:String, bttn:*, pID:*):void 
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
						
						Post.addToArchive('startGlow: ' + pID);
						bttn.startGlowing();
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
						
						bttn.startGlowing();
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
					Post.addToArchive('startGlow: ' + pID);
					bttn.startGlowing();
					CookieManager.store(cookieName, '1');
				}
			}
		}
	
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
		
		public static var isSaleWindow:Boolean = false;
		public function onPromoOpen(e:MouseEvent = null, bttn:* = null):void {	
			if (App.user.quests.tutorial) return;
			if (e && !bttn)
			{
				Window.closeAll();
			}
			
			var target:*;
			if (e) {
				target = e.currentTarget;
				if (e.currentTarget.settings.sale == 'bigSale') {
					target.hidePointing();
				} else {
					target.hideGlowing();
					target.hidePointing();
				}
			}
			else if (bttn) {
				target = bttn;
			}
			App.ui.bottomPanel.changeCursorPanelState(true);
			var pID:String; 
			if (target.hasOwnProperty('pID')) pID = target.pID;
				isSaleWindow = true;
			
			var action:Object = App.data.actions[pID];
			
			// Проверка если есть зона и она открыта			
			if(App.data.actions.hasOwnProperty(pID)){
				var action2:Object = App.data.actions[pID];
				for (var _sid:* in action2.items) {
					if (App.data.storage[_sid].type == 'Zones') {
						new ZoneSaleWindow( { pID:pID } ).show();
						return;
					}
				}
			}
			if (TripleSaleWindow.showSale(int(pID)))
			{
				//
				return;
			}
			
			if (pID == '1822' || pID == '1895') {
				new UniqueActionWindow( {
					pID:pID
				}).show();
				return;
			}
			
			if (pID == '1624') {
				new SpecialBoosterWindow( {
					pID:pID
				}).show();
				return;
			}
			
			if (pID == '10'){
				new WholeSaleWindow( {
					pID:pID,
					description:Locale.__e('flash:1429109385005')
				}).show();
				return;
			}
			
			if (pID == '12'){
				new WholeSaleWindow( {
					pID:pID,
					description:Locale.__e('flash:1429109618437')
				}).show();
				return;
			}
			
			if (pID == '283'){
				new ShareHeroWindow({pID:pID}).show();
				return;
			}
			
			var itemSID:int = 0;
			if (App.data.actions.hasOwnProperty(pID)) {
				for (var obj:String in App.data.actions[pID].items) {
					itemSID = int(obj);
					break;
				}
			}
			if (pID == '614' || itemSID == 920 || itemSID == 933 || itemSID == 1038){
				new SingleSaleWindow({pID:pID, itemSID:itemSID}).show();
				return;
			}
			
			if (pID == '40' || pID == '41' || pID == '42' || pID == '43'){
				new WanimalWindow({pID:pID}).show();
				return;
			}
			
			if ([113,114,115,116,119,120,159,347,669,920].indexOf(int(pID)) != -1 && target.settings['sale'] == 'promo'){
				new SpecialActionWindow({pID:pID}).show();
				return;
			}
			
			if (App.data.actions.hasOwnProperty(pID) && App.data.actions[pID].type == 10) {
				new NewSpecialActionWindow( { pID:pID } ).show();
				return;
			}
			
			if (target.settings['sale'] == 'buffet'){
				new BuffetActionWindow({pID:pID}).show();
				return;
			}
			
			if (target.settings['sale'] == 'premium'){
				new SaleLimitWindow({pID:pID}).show();
				return;
			}
			
			if (target.settings['sale'] == 'bankSale') {
				BanksWindow.history = {section:'Reals',page:0};
				new BanksWindow().show();
				return;
			}
			
			if (target.settings['out'] == 365) {
				new EnlargeStorageWindow( { pID:pID } ).show();
				return;
			}
			
			if (target.settings['sale'] == 'promo' && App.data.actions.hasOwnProperty(pID)) {
				if (int(action.bg) == AddWindow.MODE_ACTION_NEW) {
					new FattyActionWindow( { pID:pID } ).show();
				}else {
					new PromoWindow( { pID:pID } ).show();
				}
				App.user.unprimeAction(pID);
				return;
			}
			
			if (target.settings['sale'] == 'sales' && App.data.sales.hasOwnProperty(pID)) {
					new AnySalesWindow({
						ID:pID,
						action:App.data.sales[pID]
					}).show();
				return;
			}
			
			if (target.settings['sale'] == 'bigSale' && App.data.bigsale.hasOwnProperty(pID)) {
				new AnySalesWindow( { sID:pID, mode:AnySalesWindow.THEMATIC, action:App.data.bigsale[pID]} ).show();
				return;
			}
			
			if (target.settings['sale'] == 'vip' && App.data.actions.hasOwnProperty(pID)){
				new TemporaryActionWindow().show();
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
		
		public function onBulksOpen(e:MouseEvent):void {
			e.currentTarget.hideGlowing();
			e.currentTarget.hidePointing();
			
			var pID:String = e.currentTarget.pID;
			
			if (App.data.bulks.hasOwnProperty(pID)) {
				new wins.actions.AnySalesWindow( {
					pID:			pID,
					mode:			AnySalesWindow.PACK,
					action:			{ 
						time:	App.data.bulks[pID].time,
						duration:		App.data.bulks[pID].duration
					}
				}).show();
				return;
			}
		}
		
		private var bookerIcon:SalesIcon;
		private function createVIP():void 
		{
			if (App.user.boostPromos.length == 0) 
				return;
				
			var iconX:int = 34;
			
			for (var i:int = 0; i < App.user.boostPromos.length; i++ ) {
				
				if (App.user.boostPromos[i].buy > 0)
					continue;
					
				for (var k:int = 0; k < App.user.arrHeroesInRoom.length; k++ ) {
					if (App.user.arrHeroesInRoom[k] == App.user.boostPromos[i].sid)
						isDeniy = true;
				}
				
				var isDeniy:Boolean = false;
				for (var j:int = 0; j < App.user.characters.length; j++ ) {
					if (App.user.characters[i].sid == App.user.boostPromos[i].sid)
						isDeniy = true;
				}
				if (isDeniy)
					continue;
				
				if (App.user.boostPromos[i].hasOwnProperty('social') && !App.user.boostPromos[i].social.hasOwnProperty(App.social)) 
					continue;
				
				var sale:Object = App.user.boostPromos[i];
				if (sale.unlock.level > App.user.level)
					continue;
				if (App.time > sale.time + sale.duration * 3600 && [59,72,73,95].indexOf(int(App.user.boostPromos[i].pID)) != -1)
					continue;
					
				App.ui.addBookerIcon(sale, App.user.boostPromos[i].pID);
				
				/*bookerIcon = new SalesIcon(sale,  App.user.boostPromos[i].pID, {
					sale:'vip',
					scale: 1
				});
				//icons.push(bttn);
				
				bookerIcon.x = iconX - bookerIcon.bg.width/2;				
				bookerIcon.y = (icons.length - 1) * (QuestIcon.HEIGHT + SALES_ICON_MARGIN);
				
				promoPanel.addChild(bookerIcon);
				
				if (App.user.boostPromos[i].time + 15 > App.time) {
					bookerIcon.startGlowing();
				}*/
			}
		}
		
		private var premiumLimit:int = 1;
		private function createPremium():void 
		{
			if (App.user.premiumPromos.length == 0 /*|| numUpIcons >= iconsTopLimit*/) 
				return;
				
			var iconX:int = 34;
			var countPrimium:int = 0;
			
			for (var i:int = 0; i < App.user.premiumPromos.length; i++ ) {
				if (countPrimium >= premiumLimit)
					break;
				
				if (App.user.premiumPromos[i].buy > 0)
					continue;
					
				for (var k:int = 0; k < App.user.arrHeroesInRoom.length; k++ ) {
					if (App.user.arrHeroesInRoom[k] == App.user.premiumPromos[i].sid)
						isDeniy = true;
				}
				
				var isDeniy:Boolean = false;
				for (var j:int = 0; j < App.user.characters.length; j++ ) {
					if (App.user.characters[i].sid == App.user.premiumPromos[i].sid)
						isDeniy = true;
				}
				if (isDeniy)
					continue;
				
				if (App.user.premiumPromos[i].hasOwnProperty('social') && !App.user.premiumPromos[i].social.hasOwnProperty(App.social)) 
				continue;
				
				
				var sale:Object = App.user.premiumPromos[i];
				if (sale.unlock.level > App.user.level)
					continue;
				if (App.time > sale.time + sale.duration * 3600)
					continue;
					
				var bttn:SalesIcon = new SalesIcon(sale,  App.user.premiumPromos[i].pID, {
					sale:'premium',
					scale: 1
				});
				icons.push(bttn);
				
				bttn.x = iconX - bttn.bg.width/2;				
				bttn.y = (icons.length - 1) * (SalesIcon.HEIGHT + SALES_ICON_MARGIN);
				
				promoPanel.addChild(bttn);
				
				if (App.user.premiumPromos[i].time + 15 > App.time) {
					bttn.startGlowing();
				}
				
				countPrimium++;
			}
		}
	
		private var openSale:Boolean = false;
		private var saleLimit:int = 1;
		private function createSales():void {
			
			if (App.data.sales == null) 
				return;
				
			var iconX:int = 34;
			
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
				
				var bttn:SalesIcon = new SalesIcon(sale, saleID, {
					sale:'sales',
					scale: 0.5
				});
				
				promoIcons.push(bttn);
				icons.push(bttn);
				
				bttn.y = (icons.length - 1) * (SalesIcon.HEIGHT + SALES_ICON_MARGIN);
				bttn.x = iconX - bttn.bg.width/2;
				promoPanel.addChild(bttn);
				
				if (App.data.sales[saleID].time + 15 > App.time) {
					bttn.startGlowing();
				}
				
				countSales++;
				
				if (!openSale) {
					openSale = true;
				}
			}
		}
		
		private var setsIcons:Array = [];
		private function createBulks():void {
			
			if (App.user.id != '120635122' && App.user.level < 5) 
				return;
			
			for (var bulkID:* in App.data.bulks) {
				var bulk:Object = App.data.bulks[bulkID];
				if (bulk.social.hasOwnProperty(App.social)) 
				{
					if (bulk.time + (bulk.duration * 3600) <= App.time)
						continue;
						
					bulk['bg'] = 'interSaleBackingYellow';
					bulk['image'] = 'sets_icon'; 
					var bttn:SalesIcon = new SalesIcon (bulk, bulkID, {
						sale:'bulk',
						scale: 0.6
					});
					setsIcons.push(bttn);
					icons.push(bttn);
					
					bttn.x = 34 - bttn.bg.width/2;
					bttn.y = (icons.length - 1) * (SalesIcon.HEIGHT + SALES_ICON_MARGIN);
					
					promoPanel.addChild(bttn);
					checkOnGlow('sale', bttn, bulkID);	
				}
			}
		}
		
		private function createBigSales():void
		{
			if (App.user.level < 5)
				return;
				
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
					if ([11,12,13,14,15,21,22,23,24].indexOf(sale.sID) != -1) showRibbon = true;
					var bttn:SalesIcon = new SalesIcon(sale.sale, sale.sID, {
						sale: 'bigSale',
						scale: 0.55
					});
					promoIcons.push(bttn);
					icons.push(bttn);
					
					bttn.x = 34 - bttn.bg.width/2;
					bttn.y = (icons.length - 1) * (SalesIcon.HEIGHT + SALES_ICON_MARGIN);
					
					promoPanel.addChild(bttn);
					checkOnGlow('sale', bttn, sale.sID);
					break;
				}
			}
			
			if (showRibbon) {
				App.ui.upPanel.showBankRibbon();
			}
		}
		
		public function createPromos(isLevelUp:Boolean = false):void
		{
			var limit:int = 3;
			App.user.promos.sortOn('order', Array.NUMERIC | Array.DESCENDING);
			
			for (var i:int = 0; i < App.user.promos.length; i++)
			{
				if (App.user.promos.length <= i) break;
				if	(App.user.promos[i].buy) {
					limit++;
					continue;
				}
				
				var pID:String = App.user.promos[i].pID;
				var promo:Object = App.data.actions[pID];
				
				/*if (promo.unlock.level > App.user.level)
					continue;
				if (App.time > promo.time + promo.duration * 3600)
					continue;*/
				var saleType:String = 'promo';
				if ([1186,1030,1483,1485,1487,1489,1491,1493,1495,1497,1499,1501,1503,2673].indexOf(int(App.user.promos[i].pID)) != -1) {
					saleType = 'vip';
				}
				if (App.user.promos[i].type == 9) {
					saleType = 'buffet';
				}
				
				var bttn:SalesIcon = new SalesIcon(App.user.promos[i], pID, {
					sale:saleType,
					scale:0.5
				});
				promoIcons.push(bttn);
				icons.push(bttn);
				
				bttn.x = 34 - bttn.bg.width/2;
				bttn.y = (icons.length - 1) * (SalesIcon.HEIGHT + SALES_ICON_MARGIN);
				
				promoPanel.addChild(bttn);
				
				var obj:Object = App.user.promo[pID];
				if (App.user.promo[pID].begin_time + 15 > App.time) {
					bttn.startGlowing();
				}
				
				var currentPromo:Object = App.user.promos[i];
				// Проверяем, если акция открылась на этом уровне - то открываем окно с акцией.
				if (isLevelUp && (App.time <= currentPromo.begin_time + 15) && App.user.level == currentPromo.unlock.level) {
					onPromoOpen(null, bttn);
				}
			}
			
			if (isBankAdd) {
				isBankAdd = false;
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
		
		public function clearIconsGlow():void {
			for (var i:int = 0; i < promoIcons.length; i++) {
				if (promoIcons[i].settings.sale == 'bigSale') {
					promoIcons[i].hidePointing();
				} else {
					promoIcons[i].hideGlowing();
					promoIcons[i].hidePointing();
				}
			}	
		}
		
		private function clearPromoPanel():void {
			
			for each(var bttn:* in promoIcons) {
				bttn.hidePointing();
				bttn.hideGlowing();
				promoPanel.removeChild(bttn);
			}
			for each(bttn in setsIcons) {
				bttn.hidePointing();
				bttn.hideGlowing();
				promoPanel.removeChild(bttn);
			}
			removeIcons();
			setsIcons = [];
			promoIcons = [];
			icons = new Vector.<SalesIcon>;
		}
		
		private function removeIcons():void {
			while(icons.length) {
				var icon:SalesIcon = icons.shift();
				icon.dispose();
				icon = null;
			}
		}
		
		public function hide():void {
			this.visible = false;
		}
		
		public function show():void {
			this.visible = true;
		}
		
		public function resize(height:int = 0):void {
			this.x = App.self.stage.stageWidth - 82;
			
			if (height == 0) {
				if (panelHeight == 0) {
					panelHeight = App.self.stage.stageHeight;
				}else {
					if (height != 0)
						panelHeight = height;
				}
			}else {
				panelHeight = height;
			}
			
			createPromoPanel();			
		}
		
	}

}
