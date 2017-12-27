package wins 
{
	import com.flashdynamix.motion.extras.BitmapTiler;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.text.TextField;
	import wins.elements.TimerUnit;
	/**
	 * ...
	 * @author ...
	 */
	public class SaleDecorWindow extends Window 
	{
		private var currentSale:Object;
		private var itemsArr:Array = [];
		private var addedItems:Array;
		private var container:Sprite;
		private var ribbon:Bitmap;
		//private var action:Object;
		
		public function SaleDecorWindow(settings:Object=null) 
		{
			if (settings == null) {
				settings = new Object();
			}
			currentSale = settings.action;
			addedItems = [];
			settings['width'] = 700;
			settings['height'] = 620;
						
			settings['title'] = Locale.__e('flash:1382952380262');
			settings['hasTitle'] = true;
			settings['hasPaginator'] = true;
			settings['hasButtons'] = true;
			settings['hasExit'] = true;
			settings['fontColor'] = 0xffffff;
			settings['fontSize'] = 52;
			settings['fontBorderColor'] = 0xb58255;
			settings['shadowBorderColor'] = 0x342411;
			settings['fontBorderSize'] = 4;
			settings['itemsOnPage'] = 4;
			super(settings);
			for (var item:* in currentSale.items) {
				itemsArr.push(item);
			}
			trace();
		}
		
		
		override public function drawBackground():void
		{
			background = backing(settings.width, settings.height, 25, "shopBackingMain");
			layer.addChild(background);
		}
		
		override public function drawBody():void
		{
			exit.y -= 10;
			
			var back:Bitmap = backing(settings.width - 60, settings.height - 100, 20, "shopBackingSmall1");
			bodyContainer.addChild(back);
			back.x = (settings.width - back.width) / 2;
			back.y = (settings.height - back.height) / 2 - 40;
			
			drawMirrowObjs('diamonds', 20, settings.width - 15, settings.height - 125,false,false,false,1,1,bodyContainer);
			drawMirrowObjs('diamonds', 20, settings.width - 15, 40, false, false, false, 1, -1,bodyContainer);
			ribbon = backingShort(settings.width + 100, 'questRibbon');
			bodyContainer.addChild(ribbon);
			ribbon.x = (settings.width - ribbon.width) / 2;
			ribbon.y = back.y - 5;
			
			setPaginatorCount();
			paginator.update();
			paginator.y += 53;
			drawTime();
			contentChange();
			
		}
		
		public var timerOne:TimerUnit;
		private function drawTime():void{
			timerOne = new TimerUnit( { time: { duration:currentSale.duration, started:currentSale.time } } );
			timerOne.start();
			bodyContainer.addChild(timerOne);
		}
		
		override public function contentChange():void {
			for each(var _item:* in addedItems){
				
				container.removeChild(_item);
				_item.dispose();
				_item = null;
			}

			addedItems = [];
			
			var decorItem:DecorItem;
			container = new Sprite();
			var X:int = 0;
			var Y:int = 0;
			var itemNum:int = 0;
			
			for (var i:int = paginator.startCount; i < paginator.finishCount; i++){
			{
				decorItem = new DecorItem(itemsArr[i]);
				decorItem.x = X;
				decorItem.y = Y;
				X += decorItem.bg.width + 10;
				container.addChild(decorItem);
				addedItems.push(decorItem);
				if (itemNum == 1 || itemNum == 3)
				{
					X = 0;
					Y += decorItem.bg.height + 20;
				}
				
				itemNum++;
				}
				bodyContainer.addChild(container);
				container.x = 46;// (settings.width - container.width) / 2;
				container.y = 75;// (settings.height - container.height) / 2 - 5;
			}
			settings.page = paginator.page;
		}
		
		private function setPaginatorCount():void
		{
			paginator.itemsCount = itemsArr.length;
		}
		override public function drawArrows():void {
			
			paginator.drawArrow(bodyContainer, Paginator.LEFT,  0, 0, { scaleX: -1, scaleY:1 } );
			paginator.drawArrow(bodyContainer, Paginator.RIGHT, 0, 0, { scaleX:1, scaleY:1 } );
			paginator.x = (settings.width - paginator.width)/2 - 30;
			paginator.y = settings.height - paginator.height - 7;
			var y:Number = settings.height/2 - paginator.arrowLeft.height
			paginator.arrowLeft.x = -40;
			paginator.arrowLeft.y = y + 20;
			
			paginator.arrowRight.x = settings.width - paginator.arrowLeft.width + 40;
			paginator.arrowRight.y = y + 20;
		}		
		
	}

}

import api.ExternalApi;
import buttons.Button;
import com.flashdynamix.motion.extras.BitmapTiler;
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
import flash.text.TextFieldAutoSize;
import ui.Hints;
import ui.UserInterface;
import wins.Window;
import wins.SaleDecorWindow;

internal class DecorItem extends Sprite {
		
		public var count:uint;
		public var sID:String;
		public var background:Bitmap;
		public var bitmap:Bitmap;
		public var title:TextField;
		public var window:*;
		public var item:Object;
		public var priceLabel1:TextField;
		public var priceLabel2:TextField;
		
		private var preloader:Preloader = new Preloader();
		public var bg:Bitmap;
		private var newPrice:int;
		private var oldPrice:int = 0;
		private var currentSale:Object;
		private var bttn:Button;
		
		public function DecorItem(sid:String) {
			sID = sid;
			
			item = App.data.storage[sID];
			for (var price:* in App.data.storage[sID].price) {
				oldPrice = App.data.storage[sID].price[price];
			};
			for (var sale:* in App.data.sales) {
				currentSale = App.data.sales[sale];
			}
			
			newPrice = currentSale.items[sID];
			
			if (oldPrice == 0) {
				oldPrice = newPrice + 20;
			}
			bitmap = new Bitmap();
			addChild(bitmap);
			
			addChild(preloader);
			preloader.scaleX = preloader.scaleY = 0.6;
			preloader.x = 70;
			preloader.y = 100;
			
			drawBody();
			drawPrice();
			drawText();
			drawButton();
		}
		
		private function drawButton():void
		{
			bttn = new Button({
				caption			:Locale.__e('flash:1382952379751'),
				width			:140,
				height			:40,
				fontSize		:24,
				hasDotes		:false,
				bgColor			:[0xa8f749,0x75bd17],
				bevelColor		:[0xc8fa8f,0x5f9c11],	
				fontColor		:0xffffff,
				fontBorderColor	:0x4d7d0e
			}); 
			addChild(bttn);
			bttn.x = bg.x + (bg.width - bttn.width) / 2;
			bttn.y = bg.y + bg.height - bttn.height / 2;
			bttn.addEventListener(MouseEvent.CLICK, onBuy);
		}
		
		private function onBuy(e:MouseEvent):void 
		{
			if (!App.user.stock.take(Stock.FANT, newPrice))
				return;
			for (var sale:* in App.data.sales) {
				currentSale = App.data.sales[sale];
			}
			Post.send({
				'ctr':'sales',
				'act':'buy',
				'uID':App.user.id,
				//'sID':window.action.id,
				'sID':sale,
				'mID':sID
			}, function(error:int, data:Object, params:Object):void {
				
				if (error)
				{
					Errors.show(error, data);
					return;
				}
				
				var object:Object = App.data.storage[sID];
				var X:Number = App.self.mouseX - bttn.mouseX + bttn.width / 2;
				var Y:Number = App.self.mouseY - bttn.mouseY;
				
				Hints.plus(uint(sID), 1, new Point(X,Y), true, App.self.tipsContainer);
				
				if (object.coins > 0)
					Hints.minus(Stock.COINS, newPrice, new Point(X, Y), false, App.self.tipsContainer);
				else
					Hints.minus(Stock.FANT, newPrice, new Point(X, Y), false, App.self.tipsContainer);
				
				App.user.stock.add(uint(sID), 1);
				flyMaterial();
			});
		}
		
		private function flyMaterial():void
		{
			var _sID:uint = uint(sID);
			if (item.type == 'Energy' && !item.inguest){
				_sID = Stock.FANTASY;
			}
			if (item.type == 'Energy' && item.inguest == 1){
				_sID = Stock.GUESTFANTASY;
			}
				
			var _item:BonusItem = new BonusItem(_sID, 0);
			
			var point:Point = Window.localToGlobal(bitmap);
			point.x += bitmap.width / 2;
			point.y += bitmap.height / 2;
			_item.cashMove(point, App.self.windowContainer);
		}
		
		private function drawText():void
		{
			if (sID == '438') {
				trace('');
			}
			var title:TextField = Window.drawText(App.data.storage[sID].title,{
				fontSize	:28,
				color		:0x773c18,
				borderColor	:0xffffff,
				autoSize	:"center"
			});
			addChild(title);
			title.x = bg.x + (bg.width - title.width) / 2;
			title.y = bg.y + 10;
			
			var text:String = App.data.storage[sID].description;
			
			var description:TextField = Window.drawText(text,{
				fontSize	:22,
				color		:0x734326,
				borderSize	:4,
				borderColor	:0xfadfa3,
				wrap		:true,
				textLeading	:-3,
				multiline	:true,
				autoSize	:"left"
			});
			addChild(description);
			
			if (description.textHeight > 200) {
				var _texts:Array = text.split('.');
				description.text = _texts[0];
			}
			
			description.width = 180;
			description.x = bg.x + bg.width/2 - 35;
			description.y = bg.y + (bg.height - description.height) / 2 - 10;
		}
		
		private function drawPrice():void 
		{
			var textContainer:Sprite = new Sprite();
			var icon:Bitmap = new Bitmap(UserInterface.textures.fantsIcon);
			textContainer.addChild(icon);
			icon.scaleX = icon.scaleY = 0.7;
			icon.smoothing = true;
			
			
			var oldPriceText:TextField = Window.drawText(String(oldPrice),{
				fontSize	:22,
				color		:0xffaec7,
				borderColor	:0x931d4e,
				autoSize	:"center"
			});
			textContainer.addChild(oldPriceText);
			oldPriceText.x = icon.x + icon.width + 4;
			oldPriceText.y = icon.y + (icon.height - oldPriceText.height) / 2 + 4;
			
			var newPriceText:TextField = Window.drawText(String(newPrice),{
				fontSize	:26,
				color		:0xffaec7,
				borderColor	:0x931d4e,
				autoSize	:"center"
			});
			textContainer.addChild(newPriceText);
			newPriceText.x = oldPriceText.x + oldPriceText.width + 6;
			newPriceText.y = icon.y + (icon.height - newPriceText.height) / 2 + 4;
			
			addChild(textContainer);
			textContainer.x = bg.x + (bg.width - textContainer.width) / 2;
			textContainer.y = bg.y + bg.height - textContainer.height - 20;
			
			var line:Shape = new Shape();
			line.graphics.lineStyle(4, 0xe31103, 0.75);
			line.graphics.beginFill(0x00FF00);
			line.graphics.moveTo(oldPriceText.x, oldPriceText.y + oldPriceText.height); 
			line.graphics.lineTo(oldPriceText.x + oldPriceText.width, oldPriceText.y);
			textContainer.addChild(line);
		}
		
		private function drawSpecialChest():void
		{
			var decorItem:Object = App.data.storage[sID];
			if (decorItem.type == 'Golden') {
				var sid:int;
				var bonus:Object = App.data.treasures[decorItem.shake];	
				for each (var item:* in bonus)
				{
					for (var innerItem:* in item.item)
					{
						sid = item.item[innerItem];
						if ((App.data.storage[sid].type != "Collection") &&
							(App.data.storage[sid].mtype != 3)) {
								break;
						}
					}
				}
			}
		}
		
		private function drawBody():void 
		{
			bg = Window.backing(300, 200, 15, "shopSpecialBacking1");
			addChildAt(bg, 0);
			
			var corner:Bitmap = new Bitmap(Window.textures.goldRibbon);
			addChild(corner);
			corner.x = bg.x + 3;
			corner.y = bg.y + 3;
			
			drawSpecialChest();
			
			Load.loading(Config.getIcon(App.data.storage[sID].type, App.data.storage[sID].preview), onImageComplete);
		}
		
		private function onImageComplete(data:Bitmap):void 
		{
			if(contains(preloader))
				removeChild(preloader);
				
			bitmap.bitmapData = data.bitmapData;
			bitmap.scaleX = bitmap.scaleY = 1;
			bitmap.smoothing = true;
			bitmap.x = bg.x + (bg.width/2 - bitmap.width) / 2;
			bitmap.y = bg.y + (bg.height - bitmap.height) / 2;
		}
		
		public function dispose():void
		{
			removeChild(bitmap);
			//bitmap = null;
			removeChild(bg);
			//bg = null;
			trace("dispose");
		}
}