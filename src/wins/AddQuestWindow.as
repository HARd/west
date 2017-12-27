package wins 
{
	import adobe.utils.CustomActions;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import ui.QuestIcon;
	import ui.UserInterface;

	public class AddQuestWindow extends Window 
	{
		private var icons:Vector.<QuestIcon> = new Vector.<QuestIcon>;
		private var timers:Vector.<TextField> = new Vector.<TextField>;
		public function AddQuestWindow(settings:Object=null) 
		{
			if (settings && settings['promoPanel']) {
				settings['promoPanelPosY'] = settings['promoPanelPosY'] || 20;
				if (this is SalePackWindow) {
					settings['promoPanelPosY'] = 70;
				}else if ((this is SaleGoldenWindow) || (this is EnlargeStorageWindow)) {
					settings['promoPanelPosY'] = 55;
				}
			}
			
			super(settings);
			
			if (settings['promoPanel']) 
				addEventListener(WindowEvent.ON_AFTER_OPEN, onOpen);
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
				
				var promo:SalesIcon = new SalesIcon(App.user.promos[i + promoBegin], App.user.promos[i + promoBegin].pID, { 
					sale:'promo',
					scale:0.5,
					text: false
				} );
				promo.x = i * promo.bg.width + 10;
				icons.push(promo);
				promoPanel.addChild(promo);
				
				var time:int = App.user.promos[i + promoBegin].begin_time + App.user.promos[i + promoBegin].duration * 3600 - App.time;
				var timeText:TextField = Window.drawText(TimeConverter.timeToStr(time), {
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
				timers[i].text = TimeConverter.timeToStr(time);
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
	}
}	