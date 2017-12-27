package wins.elements
{
	import buttons.Button;
	import buttons.MixedButton;
	import buttons.MixedButton2;
	import core.Load;
	import core.Post;
	import core.Size;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import ui.Hints;
	import ui.UserInterface;
	import wins.Window;

	public class PackItem extends Sprite {
		
		public var background:Bitmap;
		public var window:*;
		
		private var priceBttn:MixedButton2;
		private var bonus:Boolean = false;
		private var preloader:Preloader = new Preloader();
		private var item:Object;
		private var sid:int;
		private var priceNew:int;
		private var priceOld:int;
		private var itemsCount:int;
		private var bulkSid:int;
		private var itemsArr:Array = [];
		private var order:int;
		public var itemColor:int = 1;
		
		public function getHeight():int {
			return background.height + 15;
		}
		
		public function PackItem(settings:Object = null ) {
			itemColor = settings.pagePos;
			var _itemSid:int = settings._itemSid;
			this.item = App.data.bulkset[_itemSid];
			order = App.data.bulks[settings.bulkID].iorder[_itemSid];
			sid = _itemSid;
			bulkSid = settings.bulkID;
			for (var itemSid:* in item) {
				itemsCount++;
			}
			
			rubyIcon = new Bitmap(UserInterface.textures.fantsIcon, "auto", true);
			var backType:String = 'itemBacking';
			
			var bgW:int = 475;
			var bgH:int = 65;
			var bgSprite:Sprite = new Sprite();
			var bgg:Bitmap = Window.backingShort( bgW, 'fadeOutWhite');
			bgg.height = bgH;
			bgg.alpha = 0.5;
			bgSprite.addChild(bgg);
			
			var devider1:Bitmap = new Bitmap(Window.textures.dividerLine);
			devider1.width = bgW;
			bgSprite.addChild(devider1);
			var devider2:Bitmap = new Bitmap(Window.textures.dividerLine);
			devider2.width = bgW;			
			devider2.y = bgH - devider2.height;
			//devider2.scaleY = -1;
			bgSprite.addChild(devider2);
			
			background = new Bitmap(new BitmapData(bgW, bgH, true, 0xffffff));
			background.bitmapData.draw(bgSprite);
			Window.backing(330, 176, 10, backType);
			addChild(background);
			
			//addChild(preloader);
			//preloader.x = background.width / 2;
			//preloader.y = background.height / 2;
			
			createIcons();
			drawButton();
			//drawPriceText();
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
			cont.y = background.y + background.height - 50;
		}
		
		
		private function drawButton():void
		{
			var rubyIcon:Bitmap = new Bitmap(UserInterface.textures.fantsIcon, "auto", true);
			priceBttn = new MixedButton2(rubyIcon,{
				//title: Locale.__e("flash:1393579961766"),
				title: String(App.data.bulkset[sid].price_new),
				width:135,
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
				fontCountBorder:0x575757,
				diamond: true				
			})
			
			addChild(priceBttn);
			//priceBttn.x = background.x + (background.width - priceBttn.width) / 2;
			priceBttn.x = background.x + background.width - priceBttn.width + 10;
			priceBttn.y = background.y + background.height - priceBttn.height - 10;
			priceBttn.coinsIcon.x += 100;
			//priceBttn.coinsIcon.y -= 2;
			priceBttn.coinsIcon.scaleX = priceBttn.coinsIcon.scaleY = 0.8;
			priceBttn.textLabel.x = priceBttn.coinsIcon.x - priceBttn.textLabel.width - 10;
			priceBttn.textLabel.y += 2;
			
			var old_price:TextField = Window.drawText(Locale.__e('flash:1407398101201') + ' ' + App.data.bulkset[sid].price_old, {
				fontSize:		22,
				color:			0xffffff,
				borderColor:	0x814f31
			});
			old_price.width = old_price.textWidth + 10;
			old_price.x = priceBttn.x + (priceBttn.width - old_price.textWidth) / 2;
			old_price.y = priceBttn.y - 40;
			addChild(old_price);
			
			var moneyIcon:Bitmap = new Bitmap(UserInterface.textures.fantsIcon);
			Size.size(moneyIcon, 30, 30);
			moneyIcon.smoothing = true;
			moneyIcon.x = old_price.x + old_price.width;
			moneyIcon.y = old_price.y;
			addChild(moneyIcon);
			
			/*if (App.user.stock.data[Stock.FANT] < App.data.bulkset[sid].price_new) {
				priceBttn.state = Button.DISABLED
			}*/
			
			priceBttn.addEventListener(MouseEvent.CLICK, onBuy);
		}
		
		private function onBuy(e:MouseEvent):void 
		{
			/*if (App.user.stock.data[Stock.FANT] < App.data.bulkset[sid].price_new) {
				return;
			}*/
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
					iconsCont.y = -40;
					if (arrIcons.length == 4) {
						
						icon.scaleX = icon.scaleY = 0.8;
						iconsCont.y = 25;
					}
					icon.x = posX + 10;
					iconsCont.addChild(icon);
					
					posX += icon.width - 3;
				}
				
				//if(contains(preloader))removeChild(preloader);
				
				addChild(iconsCont);
				//iconsCont.x = (background.width - iconsCont.width) / 2;
				iconsCont.x = background.x;
			}
		}
		
	private var cont:Sprite;
	private var rubyIcon:Bitmap;
	}
}

import core.Load;
import flash.display.Bitmap;
import flash.display.Shape;
import flash.text.TextField;
import wins.elements.PackItem;
import wins.Window;
internal class SetIcon extends LayerX
{
	public var item:Object;
	public var bitmap:Bitmap;
	public var order:int;
	public var sid:int;
	
	private var preloader:Preloader = new Preloader();
	private var target:PackItem;
	private var background:Shape;
	
	public function SetIcon(iconSid:int, count:int, order:int, cont:*) {
		this.item = item;
		this.order = order;
		sid = iconSid;
		target = cont;
		
		addChild(preloader);
		preloader.x = 50;
		preloader.y = 70;
		
		var bgColor:uint;
		
		switch(cont.itemColor) {
			case 0:
				bgColor = 0xbdd9f1;
				break;
			case 1:
				bgColor = 0xc3e5b3;
				break;
			case 2:
				bgColor = 0xffc4b9;
				break;
		}
		
		var rad:int = 50;
		background = new Shape();
		background.graphics.beginFill(bgColor, 1);
		background.graphics.drawCircle(40, 70, rad);
		background.graphics.endFill();
		addChild(background);
		
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
		
		target.setPositions();
	}
	
	private var title:TextField;
	public function drawTitle(sid:int):void 
	{
		title = Window.drawText(String(App.data.storage[sid].title), {
			fontSize:22,
			textAlign:"center",
			autoSize:"center",
			//textLeading: -6,
			color:0x773c18,
			borderColor:0xfaf9ec,
			wrap:true,
			multiline:true
		});
		//title.wordWrap = true;
		title.width = 100;
		title.y = 0;
		//title.x = 13;
		title.x = background.x + background.width / 2 - title.width / 2 - 5;
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