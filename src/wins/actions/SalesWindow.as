package wins.actions 
{
	import api.ExternalApi;
	import buttons.Button;
	import buttons.MenuButton;
	import buttons.MoneyButton;
	import core.Load;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import units.Hut;
	import wins.AddWindow;
	import wins.Window;
	import wins.Paginator;
	
	public class SalesWindow extends AddWindow
	{	
		private var items:Array = new Array();
		private var container:Sprite;
		private var timerText:TextField;
		private var descriptionLabel:TextField;
		
		public static const SALES:String = 'sales';
		public static const BULKS:String = 'bulks';
		public var mode:String;
	
		public function SalesWindow(settings:Object = null)
		{
			if (settings == null) {
				settings = new Object();
			}
			
			action = settings.action;
			
			
			action.id = settings['ID'];
			mode = settings.mode;
			
			settings['width'] = settings.width || 766;
			settings['height'] = settings.height || 500;
			
			settings['title'] = settings.title || Locale.__e('flash:1382952380262');
			settings['hasPaginator'] = true;
			settings['hasButtons'] = true;
			//settings['fontColor'] = 0xffcc00;
			//settings['fontSize'] = 60;
			//settings['fontBorderColor'] = 0x705535;
			//settings['shadowBorderColor'] = 0x342411;
			//settings['fontBorderSize'] = 8;
			settings['itemsOnPage'] = 4;
			settings['promoPanel'] = true;
			
			settings.content = initContent(action.items);
			settings.bonus = initContent(action.bonus);
			
			//settings['L'] = settings.content.length + settings.bonus.length;
			//if (settings['L'] < 2) settings['L'] = 2;
			
			//settings.width = 130 * settings['L'] + 130;
			super(settings);
		}
		
		private function initContent(data:Object):Array
		{
			var result:Array = [];
			var sID:*;
			if(mode == SALES){
				for (sID in data)
					result.push( { sID:sID, count:data[sID], order:action.iorder[sID] } );
			}else{
				for (sID in data)
					result.push( { sID:data[sID], count:1, order:action.iorder[sID] } );
			}
			
			result.sortOn('order', Array.NUMERIC);
			return result;
		}
		
		private var glowing:Bitmap;
		private var stars:Bitmap;
		private var axeX:int
		override public function drawBody():void {
			
			titleLabel.y -= 10;
			
			paginator.y -= 56;
			exit.y -= 10;
			
			
			container = new Sprite();
			bodyContainer.addChild(container);
			
			contentChange();
			
			if(settings.content.length < 4)
				settings.width = container.width + 120;
			
			var background:Bitmap;
			if (mode == BULKS) {
				background = backing(settings.width, settings.height, 50, 'windowMain');
			}else {
				background = backing2(settings.width, settings.height, 45, 'questsSmallBackingTopPiece', 'questsSmallBackingBottomPiece');
			}
			layer.addChild(background);
			
			if(settings.content.length < 4){
				container.x = (settings.width - container.width) / 2;
				titleLabel.x = (settings.width - titleLabel.width) / 2;
				paginator.x = (settings.width - paginator.width) / 2;
				exit.x = settings.width - 50;
			}
			
			var bgUnder:Bitmap = backing(settings.width - 60, 300, 40, 'shopBackingSmall');
			bgUnder.x = (settings.width - bgUnder.width) / 2;
			bgUnder.y = 20;
			bgUnder.alpha = 0.5;
			bodyContainer.addChildAt(bgUnder, 0);
			
			
			var descriptionLabel:TextField = drawText(Locale.__e("flash:1393583201665"), {
				fontSize:26,
				autoSize:"left",
				textAlign:"center",
				color:0xffffff,
				borderColor:0x175d8e
			});
			descriptionLabel.y = 3;
			descriptionLabel.x = (settings.width - descriptionLabel.textWidth) / 2;
			bodyContainer.addChild(descriptionLabel);
			
			var ribbonW:int = settings.width - 80;
			if (ribbonW < descriptionLabel.textWidth + 160)
				ribbonW = descriptionLabel.textWidth + 160;
				
			var ribbon:Bitmap = backingShort(ribbonW, 'blueRibbon2');
			ribbon.y = -10;
			ribbon.x = (settings.width - ribbon.width) / 2;
			bodyContainer.addChildAt(ribbon, 1);
			
			
			if(settings['L'] <= 3)
				axeX = settings.width - 170;
			else
				axeX = settings.width - 190;
				
			drawTime();
			
			
			if (glowing == null)
			{
				glowing = Window.backingShort(0, 'saleGlowPiece');
				bodyContainer.addChildAt(glowing, 0);
			}
			
			if (stars == null) {
				stars = Window.backingShort(760, 'decorStars');
				bodyContainer.addChildAt(stars, 1);
			}
			stars.smoothing = true;
			if (stars.width > settings.width - 40) stars.width = settings.width - 40;
			
			stars.x = 10;
			stars.y = settings.height - stars.height - 38;
			
			glowing.alpha = 0.85;
			glowing.x = (settings.width - glowing.width)/2;
			glowing.y = settings.height - glowing.height - 38;
			glowing.smoothing = true;
			
			drawMirrowObjs('diamondsTop', settings.width / 2 - settings.titleWidth / 2 - 3, settings.width / 2 + settings.titleWidth / 2 + 5, -56, true, true);
			drawMirrowObjs('diamonds', -30, settings.width + 30, settings.height - 121);
			drawMirrowObjs('diamonds', -26, settings.width + 26, 50, false, false, false, 1, -1);
		
			App.self.setOnTimer(updateDuration);
		}
		
		/*private function drawImage():void {
			if(action.image != null && (action.image != " " || action.image != "")){
				Load.loading(Config.getImage('promo/images', action.image), function(data:Bitmap):void {
					
					var image:Bitmap = new Bitmap(data.bitmapData);
					bodyContainer.addChildAt(image, 0);
					image.x = 20;
					image.y = 185;
					if (action.image == 'bigPanda') {
						image.x = -200;
						image.y = -20;
						//this.x += 100;
					}
				});
			}else{
				axeX = settings.width / 2;
			}
			
			var glowing:Bitmap = new Bitmap(Window.textures.actionGlow);
			layer.addChildAt(glowing, 0);
			
			
			glowing.alpha = 0.85;
			glowing.x = axeX - glowing.width/2 + bodyContainer.x;
			glowing.y = 265 + bodyContainer.y;
			glowing.smoothing = true;
			
			if (action.image == 'bigPanda') {
			
			}
			
			glowing.width = (settings.width - 100);
			glowing.x = 50;
			axeX = settings.width / 2;
		}*/
		
		override public function drawArrows():void {
			
			paginator.drawArrow(bodyContainer, Paginator.LEFT,  0, 0, { scaleX: -1, scaleY:1 } );
			paginator.drawArrow(bodyContainer, Paginator.RIGHT, 0, 0, { scaleX:1, scaleY:1 } );
			
			var y:Number = settings.height / 2 - paginator.arrowLeft.height + 102;
			paginator.arrowLeft.x = -20;
			paginator.arrowLeft.y = y;
			
			paginator.arrowRight.x = settings.width - paginator.arrowLeft.width + 20;
			paginator.arrowRight.y = y;
		}
		
		public override function contentChange():void 
		{
			for each(var _item:* in items)
			{
				container.removeChild(_item);
				_item = null;
			}
			
			items = [];
			
			var Xs:int = 0;
			var Ys:int = 0;
			var X:int = 0;
			var item:*;
			
			var itemNum:int = 0;
			for (var i:int = paginator.startCount; i < paginator.finishCount; i++)
			{
				if(mode == SALES)
					item = new SaleItem(settings.content[i], this);
				else
					item = new BulkItem(settings.content[i], this);
				
				container.addChild(item);
				item.x = Xs;
				item.y = Ys;
								
				items.push(item);
				Xs += item.background.width + 6;
				
				itemNum++;
			}
			
		
			container.x = (settings.width - container.width) / 2;//170 * (settings.content.length + settings.bonus.length)) / 2;
			container.y = 52;
		}
		
		override public function drawBackground():void 
		{
			//var background:Bitmap;
			//if (mode == BULKS) {
				//background = backing(settings.width, settings.height, 50, 'windowMain');
			//}else {
				//background = backing2(settings.width, settings.height, 45, 'questsSmallBackingTopPiece', 'questsSmallBackingBottomPiece');
			//}
			//layer.addChild(background);
		}
		
		private var timeConteiner:Sprite
		public function drawTime():void 
		{	
			if (timeConteiner != null)
				bodyContainer.removeChild(timeConteiner);
				
			timeConteiner = new Sprite()
			
			var background:Bitmap = Window.backingShort(200, "timeBg");
			timeConteiner.addChild(background);
			//background.x =  - background.width/2;
			//background.y = settings.height - background.height - 80;
			
			descriptionLabel = drawText(Locale.__e('flash:1393581955601'), {
				fontSize:30,
				textAlign:"left",
				color:0xffffff,
				borderColor:0x2b3b64
			});
			descriptionLabel.x =  background.x + (background.width - descriptionLabel.textWidth) / 2;
			descriptionLabel.y = background.y - descriptionLabel.textHeight / 2;
			timeConteiner.addChild(descriptionLabel);
			
			var time:int = action.duration * 60 * 60 - (App.time - action.time);
			//timerText = Window.drawText(TimeConverter.timeToCuts(time, true, true), {
			timerText = Window.drawText(TimeConverter.timeToStr(time), {
				color:0xf8d74c,
				letterSpacing:3,
				textAlign:"center",
				fontSize:34,//30,
				borderColor:0x502f06
			});
			timerText.width = 200;
			timerText.y = background.y + 14;
			timerText.x = background.x;
			
			timeConteiner.addChild(timerText);
			
			bodyContainer.addChild(timeConteiner);
			timeConteiner.x = (settings.width - timeConteiner.width) / 2;
			timeConteiner.y = settings.height - timeConteiner.height - 40;
			
		}
		
		private function updateDuration():void {
			var time:int = action.duration * 60 * 60 - (App.time - action.time);
				timerText.text = TimeConverter.timeToStr(time);
			
			if (time <= 0) {
				descriptionLabel.visible = false;
				timerText.visible = false;
			}
		}
		
		public override function dispose():void
		{
			for each(var _item:* in items)
			{
				_item = null;
			}
			
			App.self.setOffTimer(updateDuration);
			super.dispose();
		}
	}
}

import buttons.Button;
import core.Load;
import core.Post;
import flash.display.Bitmap;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.filters.GlowFilter;
import flash.geom.Point;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import ui.Cursor;
import ui.Hints;
import ui.UserInterface;
import units.Field;
import units.*;
import wins.elements.Bar;
import wins.elements.PriceLabel;
import wins.Window;
import wins.ShopWindow;
import wins.SimpleWindow;
import wins.actions.SalesWindow;

internal class SaleItem extends LayerX {
		
		public var count:uint;
		public var sID:uint;
		public var background:Bitmap;
		public var bitmap:Bitmap;
		public var title:TextField;
		public var window:*;
		public var item:Object;
		private var preloader:Preloader = new Preloader();
		
		public function SaleItem(item:Object, window:*, bonus:Boolean = false) {
			
			sID = item.sID;
			count = item.count;
			this.window = window;
			this.item = App.data.storage[sID];
			var backType:String = 'shopSpecialBacking';
			//if (!bonus)
			//	backType = 'bonusBacking'
			
			background = Window.backing(170, 234, 10, backType);
			addChild(background);
			
			var sprite:LayerX = new LayerX();
			addChild(sprite);
			
			bitmap = new Bitmap();
			sprite.addChild(bitmap);
			
			drawTitle();
			//drawInfo();
			drawCount();
			drawBttn();
			
			addChild(preloader);
			preloader.x = (150)/ 2;
			preloader.y = (background.height)/ 2 - 15;
			
			Load.loading(Config.getIcon(App.data.storage[sID].type, App.data.storage[sID].preview), onPreviewComplete);
			
			//if(App.data.storage[sID].type == 'Golden'){
				//var label:Bitmap = new Bitmap(UserInterface.textures.collectionIcon);
				//addChild(label);
				//label.smoothing = true;
				//label.x = background.width - label.width + 8;
				//label.y = background.height - label.height - 50;
			//}
			
			sprite.tip = _tip;
		}
		
		private function _tip():Object {
			return {
					title:this.item.title,
					text:this.item.description
				}
		}
		
		public function onPreviewComplete(data:Bitmap):void
		{
			removeChild(preloader);
			
			bitmap.bitmapData = data.bitmapData;
			//bitmap.scaleX = bitmap.scaleY = 0.8;
			bitmap.smoothing = true;
			bitmap.x = (background.width - bitmap.width) / 2;
			bitmap.y = (background.height - bitmap.height) / 2 - 16;
			bitmap.filters = [new GlowFilter(0xffffff, 1, 50, 50)];
		}
		
		public var priceBttn:Button
		public function drawBttn():void
		{
			priceBttn = new Button( {
				caption:Locale.__e("flash:1382952379751"),
				fontSize:24,
				width:124,
				hasDotes:false,
				height:40,
				greenDotes:false,
				bgColor:				[0xa8f84a,0x74bc17],	
				borderColor:			[0x4d7b83,0x4d7b83],	
				bevelColor:				[0xc8fa8f, 0x5f9c11],
				fontColor:				0xffffff,				
				fontBorderColor:		0x4d7d0e
			});
			addChild(priceBttn);
			priceBttn.x = (background.width - priceBttn.width) / 2;
			priceBttn.y = background.height - priceBttn.height / 2 - 4;// - 16;
			
			priceBttn.addEventListener(MouseEvent.CLICK, onBuyEvent);
		}
		
		public function drawTitle():void {
			title = Window.drawText(String(item.title), {
				color:0x6d4b15,
				borderColor:0xfcf6e4,
				textAlign:"center",
				autoSize:"center",
				fontSize:24,
				textLeading:-6,
				multiline:true
			});
			title.wordWrap = true;
			title.width = background.width - 20;//150 - 20;
			title.y = 10;
			title.x = 10;
			addChild(title);
		}
		
		/*public var description:TextField;
		public function drawInfo():void {
			description = Window.drawText(String(item.description), {
				color:0x6d4b15,
				borderColor:0xfcf6e4,
				//textAlign:"center",
				//autoSize:"center",
				fontSize:17,
				textLeading:-6,
				multiline:true
			});
			description.border = false;
			description.wordWrap = true;
			description.width = background.width / 2// - 20;
			description.height = 100//description.textHeight + 5;//background.height - 20;
			description.y = 25;
			description.x = background.width - description.width - 7;
			//addChild(description);
		}*/
		
		public function drawCount():void {
			
			var priceLabel1:PriceLabelSales = new PriceLabelSales(item.price);
				priceLabel1.x = (background.width - priceLabel1.width) / 2 - 10;
				priceLabel1.y = background.height - priceLabel1.height - 28;
				addChild(priceLabel1);
				//priceLabel1.text.alpha = 0.7;
				
			var settings:Object = {
				fontSize:26,
				autoSize:"left",
				color:0xffdc39,
				borderColor:0x6d4b15
			}
				
			if (priceLabel1.moneyType == Stock.FANT)
			{
				settings["color"]	 	= 0xDCFA9B;
				settings["borderColor"] = 0x3c5411;
			}
			
			var text:TextField = Window.drawText(String(count), settings);
			text.x = priceLabel1.x + priceLabel1.width + 2;
			text.y = priceLabel1.y + priceLabel1.height - text.textHeight - 3;
			addChild(text);
				
			var startCoords:Object = {
				x:priceLabel1.x - 2,
				y:priceLabel1.y + 20
			}
			
			var endCoords:Object = {
				x:priceLabel1.x + priceLabel1.lineWidth + 8,
				y:priceLabel1.y + 20
			}
				
			var line:Sprite = new Sprite();	
			line.graphics.lineStyle(2, 0xFF0000);
			line.graphics.moveTo(startCoords.x, startCoords.y);
			line.graphics.lineTo(endCoords.x, endCoords.y);
			
			addChild(line);
		}
		
		private function onBuyEvent(e:MouseEvent):void {
			
			if (!App.user.stock.take(Stock.FANT, count))
				return;
			priceBttn.state = Button.DISABLED;
			Post.send({
				'ctr':'sales',
				'act':'buy',
				'uID':App.user.id,
				'sID':window.action.id,
				'mID':sID
			}, function(error:int, data:Object, params:Object):void {
				priceBttn.state = Button.NORMAL;
				if (error)
				{
					Errors.show(error, data);
					return;
				}
				
				var object:Object = item;
				var X:Number = App.self.mouseX - priceBttn.mouseX + priceBttn.width / 2;
				var Y:Number = App.self.mouseY - priceBttn.mouseY;
				
				Hints.plus(sID, 1, new Point(X,Y), true, App.self.tipsContainer);
				
				if (object.coins > 0)
					Hints.minus(Stock.COINS, count, new Point(X, Y), false, App.self.tipsContainer);
				else
					Hints.minus(Stock.FANT, count, new Point(X, Y), false, App.self.tipsContainer);
				
				App.user.stock.add(sID, 1);
				flyMaterial();
			});
		}
		
		private function flyMaterial():void
		{
			var _sID:uint = sID;
			if (item.type == 'Energy' && !item.inguest){
				_sID = Stock.FANTASY;
			}
			if (item.type == 'Energy' && item.inguest == 1){
				_sID = Stock.GUESTFANTASY;
			}
				
			var _item:BonusItem = new BonusItem(_sID, 0);
			
			var point:Point = Window.localToGlobal(bitmap);
			//point.x += bitmap.width / 2;
			point.y += bitmap.height / 2;
			_item.cashMove(point, App.self.windowContainer);
		}
}


import buttons.Button;
import core.Load;
import core.Post;
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.filters.GlowFilter;
import flash.geom.Point;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import ui.Cursor;
import ui.Hints;
import ui.UserInterface;
import units.Field;
import units.*;
import wins.elements.Bar;
import wins.elements.PriceLabel;
import wins.Window;
import wins.ShopWindow;
import wins.SimpleWindow;
import wins.actions.SalesWindow;

internal class BulkItem extends LayerX {
		
		public var count:uint;
		public var sID:uint;
		public var background:Bitmap;
		public var bitmap:Bitmap;
		public var title:TextField;
		public var window:*;
		public var item:Object;
		private var preloader:Preloader = new Preloader();
		private var content:Array = [];
		
		public function BulkItem(item:Object, window:*, bonus:Boolean = false) {
			
			sID = item.sID;
			count = item.count;
			this.window = window;
			
			this.item = App.data.bulkset[sID];
			//var backType:String = 'itemBacking';
			var backType:String = 'windowBacking';
			
			background = Window.backing(270, 160, 10, backType);//240
			addChild(background);
			
			var shape:Shape = new Shape();
			shape.graphics.beginFill(0x000000);
			shape.graphics.drawRoundRect(5, 5, background.width-10, background.height-10,30,30);
			shape.graphics.endFill();
			addChild(shape);
			
			var glowing:Bitmap = new Bitmap(Window.textures.productionReadyBacking2);
			glowing.alpha = 0.8;
			glowing.scaleX = glowing.scaleY = 0.9;
			glowing.y = - glowing.height / 4 + 40;
			glowing.x = (background.width - glowing.width)/2;
			addChild(glowing);
			
			glowing.mask = shape;
			
			var sprite:LayerX = new LayerX();
			addChild(sprite);
			
			
			for (var _sID:* in this.item.items)
				content.push( { sID:_sID, count:this.item.items[_sID], order:this.item.iorder[_sID] } );
			
			content.sortOn('order');
			var X:int = 0;
			var Y:int = 0;
			
			sprite.x = (background.width - 60 * content.length)/2 + 30;
			sprite.y = 55;//44;
			
			for (var i:int = 0; i < content.length; i++) {
				var materialItem:BulkSubItem = new BulkSubItem(content[i], this);
				sprite.addChild(materialItem);
				materialItem.x = X;
				materialItem.y = Y;
				X += 60;
				//if (i == 2){
				//	Y += 60;
				//	X = 0;
				//}	
			}
			
			drawTitle();
			drawCount();
			drawBttn();
			
			
			
			
			/*bitmap = new Bitmap();
			sprite.addChild(bitmap);
			
			
			drawInfo();
			drawCount();
			
			
			addChild(preloader);
			preloader.x = (150)/ 2;
			preloader.y = (background.height)/ 2 - 15;
			
			Load.loading(Config.getIcon(App.data.storage[sID].type, App.data.storage[sID].preview), onPreviewComplete);
			
			if(App.data.storage[sID].type == 'Golden'){
				var label:Bitmap = new Bitmap(Window.textures.goldLabel);
					addChild(label);
					label.smoothing = true;
					label.x = -11;
					label.y = 20;
			}
			
			sprite.tip = _tip;*/
		}
		
		public function drawTitle():void {
			title = Window.drawText(Locale.__e('flash:1385132998669'), {
				color:0x6d4b15,
				borderColor:0xfcf6e4,
				textAlign:"center",
				autoSize:"center",
				fontSize:24,
				textLeading:-6,
				multiline:true
			});
			title.wordWrap = true;
			title.width = background.width - 20;//150 - 20;
			title.y = -5;
			title.x = 10;
			addChild(title);
		}
		
		public function drawCount():void {
			
			var priceLabel1:PriceLabel = new PriceLabel(item);
				priceLabel1.x = (background.width - priceLabel1.width) / 2 - 10;
				priceLabel1.y = 100;
				addChild(priceLabel1);
				priceLabel1.text.alpha = 0.7;
				
			var settings:Object = {
				fontSize:26,
				autoSize:"left",
				color:0xffdc39,
				borderColor:0x6d4b15
			}
				
			settings["color"]	 	= 0xDCFA9B;
			settings["borderColor"] = 0x3c5411;
			
			var text:TextField = Window.drawText(String(item.price_new), settings);
			text.x = priceLabel1.x + priceLabel1.width + 7;
			text.y = priceLabel1.y + 2;
			addChild(text);
				
			var startCoords:Object = {
				x:priceLabel1.x + 37,
				y:priceLabel1.y + 7
			}
			
			var endCoords:Object = {
				x:priceLabel1.x + priceLabel1.width + 3,
				y:priceLabel1.y + 23
			}
				
			var line:Sprite = new Sprite();	
			line.graphics.lineStyle(2, 0xFF0000);
			line.graphics.moveTo(startCoords.x, startCoords.y);
			line.graphics.lineTo(endCoords.x, endCoords.y);
			
			addChild(line);
		}
		
		private function _tip():Object {
			return {
					title:this.item.title,
					text:this.item.description
				}
		}

		
		public var priceBttn:Button
		public function drawBttn():void {
			var bttnSettings:Object = {
				caption:Locale.__e("flash:1382952379751"),
				fontSize:22,
				width:94,
				height:30
			};
			
			priceBttn = new Button(bttnSettings);
			addChild(priceBttn);
			priceBttn.x = background.width/2 - priceBttn.width/2;
			priceBttn.y = background.height - 22;
			
			priceBttn.addEventListener(MouseEvent.CLICK, onBuyEvent);
		}
		
		private function onBuyEvent(e:MouseEvent):void {
			
			if (!App.user.stock.take(Stock.FANT, count))
				return;
			priceBttn.state = Button.DISABLED;
			Post.send({
				'ctr':'sales',
				'act':'buy',
				'uID':App.user.id,
				'sID':window.action.id,
				'mID':sID
			}, function(error:int, data:Object, params:Object):void {
				priceBttn.state = Button.NORMAL;
				if (error)
				{
					Errors.show(error, data);
					return;
				}
				
				var object:Object = item;
				var X:Number = App.self.mouseX - priceBttn.mouseX + priceBttn.width / 2;
				var Y:Number = App.self.mouseY - priceBttn.mouseY;
				
				Hints.plus(sID, 1, new Point(X,Y), true, App.self.tipsContainer);
				
				if (object.coins > 0)
					Hints.minus(Stock.COINS, count, new Point(X, Y), false, App.self.tipsContainer);
				else
					Hints.minus(Stock.FANT, count, new Point(X, Y), false, App.self.tipsContainer);
				
				App.user.stock.add(sID, 1);
				flyMaterial();
			});
		}
		
		private function flyMaterial():void
		{
			var _sID:uint = sID;
			if (item.type == 'Energy' && !item.inguest){
				_sID = Stock.FANTASY;
			}
			if (item.type == 'Energy' && item.inguest == 1){
				_sID = Stock.GUESTFANTASY;
			}
				
			var _item:BonusItem = new BonusItem(_sID, 0);
			
			var point:Point = Window.localToGlobal(bitmap);
			//point.x += bitmap.width / 2;
			point.y += bitmap.height / 2;
			_item.cashMove(point, App.self.windowContainer);
		}
}

internal class BulkSubItem extends LayerX
{
	public var sID:int;
	public var bg:Bitmap;
	private var bitmap:Bitmap;
	private var item:Object;
	private var count:int;
	
	public function BulkSubItem(item:Object, _parent:*) 
	{
		this.count = item.count;
		this.sID = item.sID;
		//bg = Window.backing(100, 100, 15, 'textSmallBacking');
		//addChild(bg)
		bitmap = new Bitmap();
		addChild(bitmap);
		Load.loading(Config.getIcon(App.data.storage[sID].type, App.data.storage[sID].preview), onLoad);
		drawCount();
		tip = function():Object {
			return{
				title:App.data.storage[this.sID].title,
				text:App.data.storage[this.sID].description
			}
		}
	}
	
	public function drawCount():void 
	{
		var settings:Object = {
			fontSize:20,
			textAlign:"center",
			color		:0xffdc39,
			borderColor	:0x6d4b15
		}
			
		var text:TextField = Window.drawText(String(count), settings);
		text.height = 20;
		text.width = 30;
		text.x = - 15;
		text.y = 12;
		addChild(text);
	}
	
	public function onLoad(data:Bitmap):void
	{
		bitmap.bitmapData = data.bitmapData;
		bitmap.scaleX = bitmap.scaleY = 0.6;
		bitmap.smoothing = true;
		bitmap.x = - bitmap.width / 2;
		bitmap.y = - bitmap.height / 2;
	}
}

internal class PriceLabelSales extends Sprite
{
	public var icon:Bitmap;
	public var icon2:Bitmap;
	public var text:TextField;
	
	public var moneyType:int;
	
	public var lineWidth:int;
	
	public function PriceLabelSales(price:Object) 
	{
		//if (price == 0) return;
		var count:int = 0;
		var num:int = 0;
		for (var sID:* in price) {
			count = price[sID];
			break;
		}
		moneyType = sID;
		if (sID == null) sID = Stock.FANT//return;
		switch(sID) {
			case Stock.COINS:
				icon = new Bitmap(UserInterface.textures.coinsIcon, "auto", true);
				icon2 = new Bitmap(UserInterface.textures.coinsIcon, "auto", true);
				icon.scaleX = icon.scaleY = 0.74;
				icon2.scaleX = icon2.scaleY = 0.84;
				break;
			case Stock.FANT:
				icon = new Bitmap(UserInterface.textures.fantsIcon, "auto", true);
				icon2 = new Bitmap(UserInterface.textures.fantsIcon, "auto", true);
				icon.scaleX = icon.scaleY = 0.7;
				icon2.scaleX = icon2.scaleY = 0.8;
				break;	
			case Stock.FANTASY:
				icon = new Bitmap(UserInterface.textures.energyIcon, "auto", true);
				icon2 = new Bitmap(UserInterface.textures.energyIcon, "auto", true);
				break;		
		}
		
		addChild(icon);
		addChild(icon2);
		
		var settings:Object = {
				fontSize:22,
				autoSize:"left",
				color:0xffdc39,
				borderColor:0x6d4b15
			}
			
		if (sID == Stock.FANT)
		{
			settings["color"]	 	= 0xDCFA9B;
			settings["borderColor"] = 0x3c5411;
		}
		
		
		text = Window.drawText(String(count), settings);
		
		addChild(text);
		text.height = text.textHeight;
		
		icon.smoothing = true;
		icon2.smoothing = true;
		
		icon.x = 0;
		icon.y = icon2.height - icon.height;
		
		text.x = icon.width + 2;
		text.y = icon.height - text.textHeight + 1;
		
		icon2.x = text.x + text.textWidth + 10;
		
		num++;
		
		
		lineWidth = icon.width + text.textWidth + 2;
	}	
	
}
