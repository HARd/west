package wins 
{
	import adobe.utils.CustomActions;
	import flash.events.MouseEvent;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import ui.SalesIcon;
	import ui.UserInterface;
	import wins.actions.EnlargeStorageWindow;
	import wins.Window;
	import buttons.Button;
	
	public class AddWindow extends Window 
	{
		
		public static const MODE_ACTION_DEFAULT:uint = 0;
		public static const MODE_ACTION_NEW:uint = 1;
		
		private var icons:Vector.<SalesIcon> = new Vector.<SalesIcon>;
		private var timers:Vector.<TextField> = new Vector.<TextField>;
		
		public var action:Object;
		public var itemSID:Object;
		
		public function AddWindow(settings:Object=null) 
		{
			if (settings && settings['promoPanel']) {
				settings['promoPanelPosY'] = settings['promoPanelPosY'] || 20;
				if (this is SalePackWindow) {
					settings['promoPanelPosY'] = 70;
				}else if ((this is SaleGoldenWindow) || (this is EnlargeStorageWindow)) {
					settings['promoPanelPosY'] = 55;
				}
			}
			
			initAction(settings);
			
			super(settings);
			
			if (settings['promoPanel']) 
				addEventListener(WindowEvent.ON_AFTER_OPEN, onOpen);
		}
		
		public function initAction(settings:Object):void {
			
			if (settings.action) {
				action = settings.action;
				return;
			}
			
			action = App.data.actions[settings['pID']];
			action.id = settings['pID'];
			for (itemSID in action.items) break;
			
		}
		
		override public function drawFader():void {
			super.drawFader();
			
			if (settings['promoPanel']) {
				this.y -= settings.promoPanelPosY;
				fader.y += settings.promoPanelPosY;
			}
		}
		
		private var promoPanel:Sprite;
		private var promoBack:Bitmap;
		private var promoPaginator:Paginator;
		private const PROMOS:int = 8;
		private var promoBegin:int = 0;
		public function drawPromoPanel():void {
			promoPanelClear();
			
			if (!promoPanel) {
				promoBack = new Bitmap();
				bodyContainer.addChild(promoBack);
				
				promoPanel = new Sprite();
				bodyContainer.addChild(promoPanel);
			}
			
			for (var i:int = 0; i < App.user.promos.length; i++) {
				if (i >= PROMOS || App.user.promos.length <= i + promoBegin) continue;
				
				var promoInfo:Object = App.user.promos[i + promoBegin];
				promoInfo['sale'] = 'promo';
				
				var sale:String = 'promo';
				if (App.user.promos[i].type == 9) {
					sale = 'buffet';
				}
				var promo:SalesIcon = new SalesIcon(App.user.promos[i + promoBegin], App.user.promos[i + promoBegin].pID, { 
					sale:sale,
					scale:0.5,
					text: false
				} );
				promo.x = i * promo.bg.width + 10;
				icons.push(promo);
				promoPanel.addChild(promo);
				
				var time:int = App.user.promos[i + promoBegin].begin_time + App.user.promos[i + promoBegin].duration * 3600 - App.time;
				var str:String = TimeConverter.timeToStr(time);
				if (App.user.promos[i + promoBegin].duration == 999 || time != 0) str = '';
				var timeText:TextField = Window.drawText(str, {
					color: 0xffd958,
					borderColor: 0x693d00
				});
				timeText.x = i * promo.bg.width + 15;
				timeText.y = promo.y + promo.height - 10;
				timers.push(timeText);
				promoPanel.addChild(timeText);
				
				if (settings['pID'] == App.user.promos[i + promoBegin].pID) {
					promo.startGlowing();
				}
			}
			
			promoPanel.x = (settings.width - promoPanel.width) / 2;
			promoPanel.y = settings.height + settings.promoPanelPosY - 30;
			
			if (!promoBack.bitmapData) {
				promoBack.bitmapData = Window.backing(promoPanel.width + 10, 88, 30, 'fadeOutWhite').bitmapData;
				promoBack.x = promoPanel.x - 3;
				promoBack.y = promoPanel.y - 4;
				promoBack.alpha = 0.5;
			}
			
			if ( App.user.promos.length == 0) {
				promoBack.visible = false;
			}
			
			if (App.user.promos.length - PROMOS > 0 && !promoPaginator) {
				promoPaginator = new Paginator(App.user.promos.length - PROMOS + 1, 1, 0, {
					hasButtons:		false
				});
				promoPaginator.drawArrow(bodyContainer, Paginator.LEFT, promoPanel.x - 44, promoPanel.y + 10, { scaleX: -0.6, scaleY:0.8 } );
				promoPaginator.drawArrow(bodyContainer, Paginator.RIGHT, promoPanel.x + promoPanel.width, promoPanel.y + 10, { scaleX:0.6, scaleY:0.8 } );
				promoPaginator.addEventListener(WindowEvent.ON_PAGE_CHANGE, onPaginatorPageChange);
			}
			
			App.self.setOnTimer(updateTimers);
		}
		private function onPaginatorPageChange(e:WindowEvent = null):void {
			promoBegin = promoPaginator.page;
			drawPromoPanel();
		}
		private function promoPanelClear():void {
			if (promoPanel) {
				for each (var icon:SalesIcon in icons) {
					icon.dispose();
				}
				for (var i:int = 0; i < timers.length; i++) {
					timers[i].text = '';
					timers[i].parent.removeChild(timers[i]);
				}
				icons = new Vector.<SalesIcon>;
				timers = new Vector.<TextField>;
			}
		}
		private function onOpen(e:WindowEvent = null):void {
			drawPromoPanel();
		}
		
		private function updateTimers():void {
			for (var i:int = 0; i < icons.length; i++) {
				var time:int = icons[i].item.begin_time + icons[i].item.duration * 3600 - App.time;
				if (icons[i].item.duration == 999 || time <= 0) {
					timers[i].text = '';
				}else {
					timers[i].text = TimeConverter.timeToStr(time);
				}
			}
		}
		
		override public function dispose():void {
			if (promoPaginator) {
				promoPaginator.removeEventListener(WindowEvent.ON_PAGE_CHANGE, onPaginatorPageChange);
				promoPaginator.dispose();
			}
			
			App.self.setOffTimer(updateTimers);
			removeEventListener(WindowEvent.ON_AFTER_OPEN, onOpen);
			promoPanelClear();
			super.dispose();
		}
		
		public function getIconUrl(promo:Object):String {
			if (promo.hasOwnProperty('iorder')) {
				var _items:Array = [];
				for (var sID:* in promo.items) {
					_items.push( { sID:sID, order:promo.iorder[sID] } );
				}
				_items.sortOn('order');
				sID = _items[0].sID;
			}else {
				sID = promo.items[0].sID;
			}
			var url:String = Config.getIcon(App.data.storage[sID].type, App.data.storage[sID].preview);
			switch(sID) {
				case Stock.COINS:
					url = Config.getIcon("Coins", "gold_02");
				break;
				case Stock.FANT:
					url = Config.getIcon("Reals", "crystal_03");
				break;
			}
			
			return url;
		}
		//TODO::
		//actions parcing
		protected var priceBttn:Button;
		private var cont:Sprite;
		
		protected function drawButton(bttnSettings:Object):void
		{
			if (priceBttn != null)
				bodyContainer.removeChild(priceBttn);
			
			priceBttn = new Button(bttnSettings);
			bodyContainer.addChild(priceBttn);
			
			priceBttn.x = bttnSettings.x;
			priceBttn.y = bttnSettings.y;
			
			if (settings.addBtnContainer)
			{
				if (cont != null)
					bodyContainer.removeChild(cont);
					
				cont = new Sprite();
				
				bodyContainer.addChild(cont);
				cont.x = priceBttn.x + priceBttn.width / 2 - cont.width / 2;
				cont.y = priceBttn.y - 30;
			}
			else
			{
				bodyContainer.addChild(priceBttn);
			}
			
			if (settings.addLogo)
			{
			
				if (App.isSocial('MX')) {
					addButtonLogo(UserInterface.textures.mixieLogo, 0.8);
				}
				if (App.isSocial('SP')) {
					addButtonLogo(UserInterface.textures.fantsIcon);
				}
			}
			
			priceBttn.addEventListener(MouseEvent.CLICK, bttnSettings.callback);
		}
		
		protected function addButtonLogo(bmd:BitmapData, scale:Number = 1 ):void
		{
			var logo:Bitmap = new Bitmap(bmd);
			logo.scaleX = logo.scaleY = scale;
			priceBttn.addChild(logo);
			
			logo.y = priceBttn.textLabel.y - (logo.height - priceBttn.textLabel.height)/2;
			logo.x = priceBttn.textLabel.x-10;
			priceBttn.textLabel.x = logo.x + logo.width + 5;
		}
		
		
		protected function buyEvent(e:MouseEvent):void
		{
			if (e.currentTarget.mode == Button.DISABLED) 
				return;
			
			priceBttn.state = Button.DISABLED;
			
			Payments.buy( {
				type:			'promo',
				id:				action.id,
				price:			int(action.price[App.social]),
				count:			1,
				title: 			Locale.__e('flash:1382952379793'),
				description: 	Locale.__e('flash:1382952380239'),
				callback:		onBuyComplete,
				error:			function():void {
					close();
				},
				icon:			getIconUrl(action)
			});
		}
		
		protected function onBuyComplete(e:* = null):void 
		{
			priceBttn.state = Button.NORMAL;
			
			// Открыть зону и убрать ее из списка зачисления на склад
			for (var s:String in action.items) {
				if (App.data.storage[s].type == 'Zones') {
					if (App.user.world.zones.indexOf(int(s)) < 0) {
						App.user.world.onOpenZone(0, { }, { sID:int(s), require:{} } );
					}
					delete action.items[s];
				}
			}
			
			App.user.stock.addAll(action.items);
			App.user.stock.addAll(action.bonus);
			
			for (var item:* in action.items) {
				var bonus:BonusItem = new BonusItem(item, action.items[item]);
				var point:Point = Window.localToGlobal(priceBttn);
					bonus.cashMove(point, App.self.windowContainer);
			}
			
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

