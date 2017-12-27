package wins.elements
{
	import buttons.Button;
	import core.Load;
	import core.Post;
	import core.Size;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import ui.Hints;
	import ui.UserInterface;
	import units.Anime;
	import wins.Window;

	public class DecorItem extends Sprite {

		public var textFramePars:Object = {
			width:155,
			height:80,
			_x:130,
			_y:36
		};
		
		public var description:TextField;
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
		private var sale:String;
		
		public function getHeight():int {
			return this.height;
		}

		public function DecorItem(settings:Object = null) {
			sID = settings.sid;
			
			item = App.data.storage[sID];
			for (var price:* in App.data.storage[sID].price) {
				oldPrice = App.data.storage[sID].price[price];
			};
			if (oldPrice == 0 && item.hasOwnProperty('instance')) {
				var countOnMap:int = World.getBuildingCount(uint(sID)) + App.user.stock.count(uint(sID));
				if (!item.instance.cost.hasOwnProperty(countOnMap + 1)) {
					while (!item.instance.cost.hasOwnProperty(countOnMap + 1) && countOnMap > 0) {
						countOnMap --;
					}
				}
				for (var prc:* in item.instance.cost[countOnMap+1]) {
					oldPrice = item.instance.cost[countOnMap+1][prc];
				};
			}
			for (var sale:* in App.data.sales) {
				if (App.data.sales[sale].time && App.data.sales[sale].time + App.data.sales[sale].duration * 3600 >= App.time && App.data.sales[sale].social.hasOwnProperty(App.social)) {
					currentSale = App.data.sales[sale];
					this.sale = sale;
					break;
				}
			}
			
			newPrice = currentSale.items[sID].price;
			
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
			drawDividers();
		}

		private function drawDividers():void {
			var devider1:Bitmap = new Bitmap(Window.textures.dividerLine);
			devider1.width = textFramePars.width;
			devider1.x = description.x + (description.width - devider1.width ) / 2;
			devider1.y = description.y - (textFramePars.height - description.height) / 2;
			devider1.alpha = 0.4;
			addChild(devider1);
			
			var devider2:Bitmap = new Bitmap(Window.textures.dividerLine);
			devider2.width = textFramePars.width;
			devider2.x = devider1.x;
			devider2.y = devider1.y + textFramePars.height;
			devider2.alpha = 0.4;
			addChild(devider2);
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
			bttn.y = bg.y + bg.height - bttn.height / 2 - 10;
			bttn.addEventListener(MouseEvent.CLICK, onBuy);
		}

		private function onBuy(e:MouseEvent):void 
		{
			if (!App.user.stock.take(Stock.FANT, newPrice))
				return;
			Post.send({
				'ctr':'sales',
				'act':'buy',
				'uID':App.user.id,
				'sID':this.sale,
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
			var title:TextField = Window.drawText(App.data.storage[sID].title,{
				fontSize	:28,
				width		:textFramePars.width,
				color		:0xfdfef8,
				borderColor	:0x7e3c08,
				autoSize	:"center"
			});
			addChild(title);
			title.width = title.textWidth + 5;
			title.x = bg.x + textFramePars._x + (textFramePars.width - title.width) / 2;
			title.y = bg.y + 10;
			
			var text:String = App.data.storage[sID].description;
			
			var descSize:int = 22;			
			do{
				description = Window.drawText(text,{
					fontSize	:descSize,
					width		:textFramePars.width,
					height		:textFramePars.height,
					color		:0xfdfef8,
					borderColor	:0x7e3c08,
					borderSize	:4,
					wrap		:true,
					textLeading	:-3,
					multiline	:true,
					multiline	:true,
					autoSize	:"left"
				});
				descSize -= 1;	
			}
			while (description.height > 80) 
			
			addChild(description);
			if (description.textHeight > 200) {
				var _texts:Array = text.split('.');
				description.text = _texts[0];
			}
			
			description.width = description.textWidth + 5;
			description.x = bg.x + textFramePars._x + (textFramePars.width - description.width) / 2;
			description.y = bg.y + textFramePars._y + (textFramePars.height - description.height) / 2;
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
				color		:0xffffff,
				borderColor	:0x6d4200,
				autoSize	:"center"
			});
			textContainer.addChild(oldPriceText);
			oldPriceText.x = icon.x + icon.width + 4;
			oldPriceText.y = icon.y + (icon.height - oldPriceText.height) / 2 + 4;
			
			var newPriceText:TextField = Window.drawText(String(newPrice),{
				fontSize	:26,
				color		:0xffffff,
				borderColor	:0x6d4200,
				autoSize	:"center"
			});
			textContainer.addChild(newPriceText);
			newPriceText.x = oldPriceText.x + oldPriceText.width + 6;
			newPriceText.y = icon.y + (icon.height - newPriceText.height) / 2 + 4;
			
			addChild(textContainer);
			
			textContainer.x = bg.x + textFramePars._x + (textFramePars.width - textContainer.width) / 2;;
			textContainer.y = bg.y + bg.height - textContainer.height - 40;
			
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
				var bonus:Object = App.data.treasures[decorItem.shake];	
				for each (var item:* in bonus)
				{
					for (var innerItem:* in item.item)
					{
						var sid:int = item.item[innerItem];
						if ((App.data.storage[sid].type != "Collection") && (App.data.storage[sid].mtype != 3)) {
							break;
						}
					}
				}
			}
		}

		private function drawBody():void 
		{
			var back:String = "itemBacking";
			if (currentSale.items[sID].decor != '' && currentSale.items[sID].decor == 1)
				back = "itemBackingGreen";
			bg = Window.backing(300, 200, 15, back);
			addChildAt(bg, 0);
			
			if (currentSale.items[sID].decor != '' && currentSale.items[sID].decor == 1) {
				var corner:Bitmap = new Bitmap(Window.textures.saleMinusFiftyPercentRibbon);
				corner.x = bg.x;
				corner.y = bg.y + 3;
				addChild(corner);
			}
			
			drawSpecialChest();
			
			if (App.data.storage[sID].type == 'Golden') {
				Load.loading(Config.getSwf(App.data.storage[sID].type, App.data.storage[sID].preview), onAnimComplete);
			} else {
				Load.loading(Config.getIcon(App.data.storage[sID].type, App.data.storage[sID].preview), onImageComplete);
			}
		}

		private function onImageComplete(data:*):void 
		{
			if(contains(preloader))
				removeChild(preloader);
				
			bitmap.bitmapData = data.bitmapData;
			Size.size(bitmap, 130, 190);
			bitmap.smoothing = true;
			bitmap.x = bg.x + (bg.width/2 - bitmap.width) / 2 - 3;
			bitmap.y = bg.y + (bg.height - bitmap.height) / 2;
		}
		
		private function onAnimComplete(swf:*):void 
		{
			if(contains(preloader))
				removeChild(preloader);
				
			var anime:Anime = new Anime(swf, { w:bg.width - 20, h:bg.height - 40 } );
			Size.size(anime, 130, 190);
			anime.x = bg.x + (bg.width/2 - anime.width) / 2 - 3;
			anime.y = bg.y + (bg.height - anime.height) / 2;
			addChild(anime);
		}

		public function dispose():void
		{
			removeChild(bitmap);
			removeChild(bg);
			if (bttn) bttn.removeEventListener(MouseEvent.CLICK, onBuy);
		}
	}
}