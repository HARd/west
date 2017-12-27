package wins 
{
	import api.ExternalApi;
	import buttons.Button;
	import buttons.MenuButton;
	import buttons.MoneyButton;
	import core.Load;
	import core.Post;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import ui.UserInterface;
	import units.Hut;

	public class SalesSetsWindow2 extends Window
	{
		private var items:Array = new Array();
		public var action:Object;
		private var container:Sprite;
		private var bulkset:Object;
		private var bulkCount:int;
		private var timerText:TextField;
		private var descriptionLabel:TextField;
		private var bulkSid:int;
		private var tempArr:Array;
		
		public function SalesSetsWindow2(settings:Object = null, _bulkSid:int = 1)
		{
			if (settings == null) {
				settings = new Object();
			}
			
			settings['width'] = 750;
			settings['height'] = 540;
			settings['title'] = Locale.__e("flash:1382952379793");
			settings["itemsOnPage"] = 4;
			
			//settings['hasPaginator'] = false;
			//settings['hasButtons'] = false;
			bulkset = { };
			bulkSid = _bulkSid;
			tempArr = [];
			
			for (var sid:* in App.data.bulks[bulkSid].items) {
				tempArr.push(App.data.bulks[bulkSid].items[sid]);
			}
			
			bulkCount = tempArr.length;
			
			/*for (var j:int = 0; j < bulkCount; j++) 
			{
				bulkset[j] = App.data.bulkset[j];
			}*/
			super(settings);
		}
		
		override public function drawArrows():void {
				
			paginator.drawArrow(bodyContainer, Paginator.LEFT,  0, 0, { scaleX: -1, scaleY:1 } );
			paginator.drawArrow(bodyContainer, Paginator.RIGHT, 0, 0, { scaleX:1, scaleY:1 } );
			
			var y:Number = (settings.height - paginator.arrowLeft.height) / 2 - 30;
			paginator.arrowLeft.x = -paginator.arrowLeft.width/2 + 22;
			paginator.arrowLeft.y = y;
			
			paginator.arrowRight.x = settings.width-paginator.arrowRight.width/2 - 22;
			paginator.arrowRight.y = y;
			
		}
		
		override public function drawBackground():void 
		{
			var background:Bitmap = backing(settings.width, settings.height, 45, 'shopBackingMain');
			layer.addChild(background);
		}
		
		public function changePromo(pID:String):void {
			
			App.self.setOffTimer(updateDuration);
			
			//action = App.data.promo[pID];
			//action.id = pID;
			
			//action.items[110] = 1;
			//action.items[111] = 1;
			
			//settings.content = initContent(action.items);
			//settings.bonus = initContent(action.bonus);
			
			//settings['L'] = settings.content.length + settings.bonus.length;
			//if (settings['L'] < 2) settings['L'] = 2;
			
			paginator.page = 0;
			paginator.itemsCount = bulkCount;
			paginator.update();
			
			contentChange();
			drawTime();
			
			App.self.setOnTimer(updateDuration);
			
			if(fader != null)
				onRefreshPosition();
				
			titleLabel.x = (settings.width - titleLabel.width) / 2;	
			_descriptionLabel.x = settings.width/2 - _descriptionLabel.width/2;
			exit.y -= 10;
			
			if (menuSprite != null){
				menuSprite.x = settings.width / 2 - (promoCount * 70) / 2 - 20;
			}
		}
		
		private function initContent(data:Object):Array
		{
			var result:Array = [];
			for (var sID:* in data) {
				result.push({sID:sID, count:data[sID], order:action.iorder[sID]});
			}
			
			result.sortOn('order');
			return result;
		}
		
		private var _descriptionLabel:TextField;
		override public function drawBody():void 
		{	
			
			titleLabel.y -= 10;
			paginator.y += 42;
			paginator.x -= 30;
			
			drawMirrowObjs('diamondsTop', settings.width / 2 - settings.titleWidth / 2 - 5, settings.width / 2 + settings.titleWidth / 2 + 5, -50, true, true);
			drawMirrowObjs('diamonds', 12, settings.width - 12, settings.height - 115);
			drawMirrowObjs('diamonds', 12, settings.width - 12, 50, false, false, false, 1, -1);
			
			var backing:Bitmap = Window.backing(700, 420, 43, 'shopBackingSmall');
			bodyContainer.addChild(backing);
			backing.x = (settings.width - backing.width) / 2;
			backing.y = 30;
			
			var ribbon:Bitmap = backingShort(settings.width + 150, 'questRibbon');
			ribbon.y = -10;
			ribbon.x = (settings.width - ribbon.width) / 2;
			bodyContainer.addChild(ribbon);
			
			var text:String = Locale.__e("flash:1393582651596");
			_descriptionLabel = drawText(text, {
				fontSize:28,
				autoSize:"left",
				textAlign:"center",
				color:0xffffff,
				borderColor:0x6d289a
			});
			
			_descriptionLabel.y = 3;
			
			bodyContainer.addChild(_descriptionLabel);
			
			container = new Sprite();
			bodyContainer.addChild(container);
			container.x = 50;
			container.y = 60;
			
			changePromo(settings['pID']);
			_descriptionLabel.x = settings.width / 2 - _descriptionLabel.width / 2;
			
		}
		
		override protected function onRefreshPosition(e:Event = null):void
		{ 		
			var stageWidth:int = App.self.stage.stageWidth;
			var stageHeight:int = App.self.stage.stageHeight;
			
			layer.x = (stageWidth - settings.width) / 2;
			layer.y = (stageHeight - settings.height) / 2;
			
			fader.width = stageWidth;
			fader.height = stageHeight;
		}
		
		private var promoCount:int = 0;
		private var menuSprite:Sprite
		private var bttns:Array = [];
		private function drawMenu():void {
			
			menuSprite = new Sprite();
			var X:int = 10;
						
			if (App.data.promo == null) return;
			
			for (var pID:* in App.user.promo) {
				
				var promo:Object = App.data.promo[pID];	
				
				if (App.user.promo[pID].status)	continue;
				if (App.time > App.user.promo[pID].started + promo.duration * 3600)	continue
			}
			
			bodyContainer.addChild(menuSprite);
			menuSprite.y = settings.height - 70;
			var bg:Bitmap = Window.backing((promoCount * 70) + 40, 70, 10, 'smallBacking');
			menuSprite.addChildAt(bg, 0);
			
			menuSprite.x = (settings.width - menuSprite.width) / 2 - 10;
		}
		
		public override function contentChange():void 
		{
			for each(var _item:ActionItem in items)
			{
				container.removeChild(_item);
				_item = null;
			}
			
			items = [];
			
			var Xs:int = 0;
			var Ys:int = 0;
			var X:int = 0;
			
			var itemNum:int = 0;
			for (var i:int = paginator.startCount; i < paginator.finishCount; i++)
			{
				var itemSid:int = tempArr[i];
				//if (!bulkset.hasOwnProperty(itemSid)) continue;
				
				var item:ActionItem = new ActionItem( itemSid);
				//public function ActionItem(_bulkSid:int, _item:Object, _itemSid:int ) {
				
				container.addChild(item);
				item.x = Xs;
				item.y = Ys;
								
				items.push(item);
				Xs += item.background.width + 4;
				
				if (itemNum == 1) {
					Xs = 0;
					Ys += item.background.height + 18;
				}
				itemNum++;
			}
			
			container.y = 56;
			container.x = 44;
		}
		
		private var timerContainer:Sprite;
		public function drawTime():void {
			
			if (timerContainer != null)
				bodyContainer.removeChild(timerContainer);
				
			timerContainer = new Sprite()
			
			var background:Bitmap = Window.backingShort(160, "salseTimeBg");
			timerContainer.addChild(background);
			background.x =  - background.width/2 + 10;
			background.y = 5//settings.height - background.height - 80;
			
			descriptionLabel = drawText(Locale.__e('flash:1393581955601'), {
				fontSize:30,
				textAlign:"left",
				color:0xffffff,
				borderColor:0x5a2910
			});
			descriptionLabel.x =  background.x + (background.width - descriptionLabel.textWidth) / 2;
			descriptionLabel.y = background.y - descriptionLabel.textHeight / 2;
			timerContainer.addChild(descriptionLabel);
			
			var actionTime:int;
			for (var sale:* in App.data.sales)
			{
				actionTime = App.data.sales[sale].time;
			}
			
			//App.data.bulks[bulkSid].duration * 60 * 60 - (App.time - App.data.bulks[bulkSid].time);
			App.data.bulks[bulkSid].duration;
			App.data;
			var time:int = App.data.bulks[bulkSid].duration * 60 * 60 - (App.time - App.data.bulks[bulkSid].time);
			timerText = Window.drawText(TimeConverter.timeToStr(time), {
				color:0xf8d74c,
				letterSpacing:3,
				textAlign:"center",
				fontSize:34,//30,
				borderColor:0x502f06
			});
			timerText.width = 200;
			timerText.y = background.y + 14;
			timerText.x = background.x - 20;
			
			timerContainer.addChild(timerText);
			
			bodyContainer.addChild(timerContainer);
			timerContainer.x = 12 + timerContainer.width/2;
			timerContainer.y = -10;
		}
		
		private var cont:Sprite;
		private function updateDuration():void {
			var actionTime:int;
			for (var sale:* in App.data.sales)
			{
				actionTime = App.data.sales[sale].time;
			}
			var time:int = App.data.bulks[bulkSid].duration * 60 * 60 - (App.time - App.data.bulks[bulkSid].time);
				timerText.text = TimeConverter.timeToStr(time);
			
			if (time <= 0) {
				descriptionLabel.visible = false;
				timerText.visible = false;
			}
		}
		
		public override function dispose():void
		{
			for each(var _item:ActionItem in items)
			{
				_item = null;
			}
			
			App.self.setOffTimer(updateDuration);
			super.dispose();
		}
	}
}

import api.ExternalApi;
import buttons.Button;
import buttons.MixedButton;
import buttons.MixedButton2;
import core.Load;
import core.Post;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.filters.GlowFilter;
import flash.geom.Point;
import flash.text.TextField;
import ui.Hints;
import ui.UserInterface;
import wins.Window;
import wins.SimpleWindow;

internal class ActionItem extends Sprite {
		
		public var background:Bitmap;
		public var window:*;
		
		private var priceBttn:MixedButton2;
		
		private var bonus:Boolean = false;
		
		private var preloader:Preloader = new Preloader();
		
		private var item:Object;
		//private var currentItems:Object;
		private var sid:int;
		private var priceNew:int;
		private var priceOld:int;
		private var itemsCount:int;
		private var bulkSid:int;
		private var itemsArr:Array = [];
		private var order:int;
		
		
		//public function ActionItem(_bulkSid:int, _item:Object, _itemSid:int ) {
		public function ActionItem(_itemSid:int ) {
			this.item = App.data.bulkset[_itemSid];
			order = App.data.bulks[1].iorder[_itemSid];
			/*for each(var _order:* in App.data.bulks[_bulkSid].iorder) {
				if (App.data.bulks[_bulkSid].items[_order] == _itemSid) 
				{
					order = _order;
				}
			}*/
			sid = _itemSid;
			bulkSid = 1;
			//currentItems = items[sid-1].items;
			for (var itemSid:* in item) {
				itemsCount++;
			}
			
			rubyIcon = new Bitmap(UserInterface.textures.fantsIcon, "auto", true);
			var backType:String = 'itemBacking';
			background = Window.backing(330, 176, 10, backType);
			addChild(background);
			
			addChild(preloader);
			preloader.x = background.width / 2;
			preloader.y = background.height / 2;
			
			//drawPrice();
			
			createIcons();
			drawButton();
			drawPriceText();
		}
		
		private function drawPriceText():void
		{
			var cont:Sprite = new Sprite();
			
			var oldPrice:TextField = Window.drawText(Locale.__e("flash:1407398101201") + " " + String(App.data.bulkset[sid].price_old), {
							fontSize:22,
							autoSize:"left",
							color:0x000000,
							borderColor:0xffffff
						});
			oldPrice.x = 0;
			oldPrice.y = 0;
			cont.addChild(oldPrice);
			
			rubyIcon.x = oldPrice.x + oldPrice.width + 5;
			rubyIcon.y = oldPrice.y;
			rubyIcon.scaleX = rubyIcon.scaleY = 0.6;
			cont.addChild(rubyIcon);
			
			addChild(cont);
			cont.x = background.x + (background.width - cont.width) / 2;
			cont.y = background.y + background.height - 49;
			//var myShape:Shape = new Shape();
			//myShape.graphics.beginFill(0x00FF00);
			//myShape.graphics.lineStyle(4, 0x990000, .75);
			//myShape.graphics.moveTo(oldPrice.x, oldPrice.y + 1); 
			//myShape.graphics.lineTo(oldPrice.x + oldPrice.width, oldPrice.y + oldPrice.height - 1);
			//addChild(myShape);
		}
		
		
		private function drawButton():void
		{
			var rubyIcon:Bitmap = new Bitmap(UserInterface.textures.fantsIcon, "auto", true);
			priceBttn = new MixedButton2(rubyIcon,{
				//title: Locale.__e("flash:1393579961766"),
				title: String(App.data.bulkset[sid].price_new),
				width:166,
				height:43,
				countText:String(App.data.bulkset[sid].price_new),
				//hasText2:true,
				fontSize:32,
				borderSize:6,
				iconScale:0.95,
				radius:20,
				bgColor:[0xf5d057, 0xeeb331],
				bevelColor:[0xfeee7b, 0xbf7e1a],
				fontColor:0xffffff,
				fontBorderColor:0x814f31,
				fontCountColor:0xffffff,
				fontCountBorder:0x575757
				
			})
			
			addChild(priceBttn);
			priceBttn.x = background.x + (background.width - priceBttn.width) / 2;
			priceBttn.y = background.y + background.height - priceBttn.height / 2;
			priceBttn.coinsIcon.x += 100;
			//priceBttn.coinsIcon.y -= 2;
			priceBttn.coinsIcon.scaleX = priceBttn.coinsIcon.scaleY = 0.8;
			priceBttn.textLabel.x = priceBttn.coinsIcon.x - priceBttn.textLabel.width - 10;
			priceBttn.textLabel.y += 2;
			
			
			if (App.user.stock.data[Stock.FANT] < App.data.bulkset[sid].price_new) {
				priceBttn.state = Button.DISABLED
			}
			
			priceBttn.addEventListener(MouseEvent.CLICK, onBuy);
		}
		
		private function onBuy(e:MouseEvent):void 
		{
			if (App.user.stock.data[Stock.FANT] < App.data.bulkset[sid].price_new) {
				return
			}
			if (!App.user.stock.check(Stock.FANT, App.data.bulkset[sid].price_new)) return;
			
			App.user.stock.take(Stock.FANT, App.data.bulkset[sid].price_new);
			trace("Совершаем покупку оптового набора");
			App.data.bulks
			App.data.bulkset
			Post.send({
				ctr:'bulks',
				act:'buy',
				uID:App.user.id,
				sID:bulkSid,
				//mID:sid
				mID:order
			}, onBuyEvent);
			
			Hints.minus(Stock.FANT, App.data.bulkset[sid].price_new, Window.localToGlobal(e.currentTarget), false);
		}
		
		private function onBuyEvent(error:int, data:Object, params:Object):void 
		{
			if (error)
			{
				Errors.show(error, data);
				return;
			}
			trace();
			
			App.user.stock.addAll(App.data.bulkset[sid].items);
			
			take(App.data.bulkset[sid].items, priceBttn);			
		}
		
		private function take(items:Object, target:*):void {
			for(var i:String in items) {
				var item:BonusItem = new BonusItem(uint(i), items[i]);
				var point:Point = Window.localToGlobal(target);
				item.cashMove(point, App.self.windowContainer);
			}
		}
		
		private var arrIcons:Array = [];
		private function createIcons():void 
		{
			var count:int;
			
			var order:int;
			for (var sid:* in item.items) {
				order = item.iorder[sid];
				count = item.items[sid];
				var icon:SetIcon = new SetIcon(sid,count,order, this);
				arrIcons.push(icon);
			}
			arrIcons.sortOn("order", Array.NUMERIC);
			
			setPositions();
		}
		
		private var iconsCont:Sprite = new Sprite();
		private var countIcons:int = 0;
		public function setPositions():void
		{
			countIcons += 1;
			
			if (countIcons >= arrIcons.length) {
				var posX:int = 0;
				for (var i:int = 0; i < arrIcons.length; i++ ) {
					
					var icon:SetIcon = arrIcons[i];
					iconsCont.y = 8;
					if (arrIcons.length == 4) {
						
						icon.scaleX = icon.scaleY = 0.8;
						iconsCont.y = 25;
					}
					icon.x = posX + 10;
					iconsCont.addChild(icon);
					
					posX += icon.width - 10;
				}
				
				if(contains(preloader))removeChild(preloader);
				
				addChild(iconsCont);
				iconsCont.x = (background.width - iconsCont.width) / 2;
				
			}
		}
		
	private var cont:Sprite;
	private var rubyIcon:Bitmap;
}

internal class SetIcon extends LayerX
{
	public var item:Object;
	public var bitmap:Bitmap;
	
	private var preloader:Preloader = new Preloader();
	
	private var target:ActionItem;
	public var order:int;
	public var sid:int;
	//public function SetIcon(item:Object, cont:ActionItem)
	public function SetIcon(iconSid:int, count:int, order:int, cont:ActionItem)
	{
		this.item = item;
		this.order = order;
		sid = iconSid;
		target = cont;
		
		addChild(preloader);
		preloader.x = 50;
		preloader.y = 70;	
		
		var sprite:LayerX = new LayerX();
		addChild(sprite);
		
		bitmap = new Bitmap();
		sprite.addChild(bitmap);
		
		drawTitle(iconSid);
		drawCount(count);
		
		Load.loading(Config.getIcon(App.data.storage[iconSid].type, App.data.storage[iconSid].preview), onPreviewComplete);
	}
	
	private var bitmapHeight:int = 84;
	public function onPreviewComplete(data:Bitmap):void
	{
		removeChild(preloader);
		
		bitmap.bitmapData = data.bitmapData;
		bitmap.height = bitmapHeight;
		bitmap.scaleX = bitmap.scaleY = 0.8;
		bitmap.smoothing = true;
		bitmap.y = 26;
		
		//countText.width = bitmap.width - 10;
		//title.width = bitmap.width - 10;
		//title.x = (bitmap.width - title.width) / 2;
		//countText.x = (bitmap.width - countText.width) / 2;
		
		target.setPositions();
	}
	
	private var title:TextField;
	public function drawTitle(sid:int):void 
	{
		title = Window.drawText(String(App.data.storage[sid].title), {
			color:0x814f31,
			borderColor:0xfcf6e4,
			textAlign:"center",
			autoSize:"center",
			fontSize:20,
			textLeading: -6,
			wrap:true,
			multiline:true
		});
		//title.wordWrap = true;
		title.width = 100;
		title.y = 0;
		title.x = -10;
		addChild(title);
	}
	
	private var countText:TextField;
	public function drawCount(count:int):void {
		countText = Window.drawText('x' + String(count), {
			color:0xffffff,
			borderColor:0x41332b,
			textAlign:"center",
			autoSize:"center",
			fontSize:24,
			textLeading:-6,
			multiline:true
		});
		countText.wordWrap = true;
		countText.width = bitmap.width - 10;
		countText.y = bitmapHeight + 10;
		countText.x = 5;
		addChild(countText);
	}
	
	
}
