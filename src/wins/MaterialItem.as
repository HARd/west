package wins{
	import buttons.Button;
	import buttons.ImageButton;
	import buttons.MoneyButton;
	import core.Load;
	import core.Numbers;
	import core.WallPost;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.ui.Mouse;
	import flash.utils.clearInterval;
	import flash.utils.getQualifiedClassName;
	import flash.utils.setInterval;
	import flash.utils.setTimeout;
	import ui.Hints;
	import ui.UserInterface;
	import ui.WishList;
	import units.Animal;
	import wins.actions.BanksWindow;
	import wins.elements.BankMenu;
	import wins.Window;
	
	public class MaterialItem extends Sprite
	{ 
		public static const IN:int = 1;
		public static const OUT:int = 2;
		public static const READY:int = 1;
		public static const UNREADY:int = 2;
		
		public var background:Bitmap;
		public var title:TextField;
		
		public var countContainer:Sprite = new Sprite;
		public var count_txt:TextField;
		public var vs_txt:TextField;
		public var need_txt:TextField;
		public var inStock:TextField;
		public var inStockLabel:Sprite;
		
		public var need:int
		public var count:int
		
		public var sID:uint;
		public var info:Object;
		public var bitmap:Bitmap;
		
		public var coinsBttn:MoneyButton;
		
		public var moneyType:String;
		public var status:int = MaterialItem.UNREADY;
		
		public var buyBttn:MoneyButton;
		public var askBttn:Button;
		public var wishBttn:ImageButton;
		public var searchBttn:ImageButton;
		public var cookBttn:Button;
		
		public var type:int;
		public var win:Window;
		public var outCount:int;
		
		public var bitmapDY:int = 0;
		
		public var animalLabel:TextField;
		public var thinkBttn:Button;
		
		public var titleColor:int;
		public var titleBorderColor:int;
		
		private var settings:Object = { };
		private var backingColor:uint;
		private var backingRadius:uint;
		
		public var buyable:Boolean = true;
		
		public function MaterialItem(settings:Object){
			
			this.sID = settings.sID || 0;
			this.need = settings.need || 0;
			this.type = settings.type || MaterialItem.IN;
			this.win = settings.window || null;
			this.outCount = settings.outCount || 1;
			this.bitmapDY = settings.bitmapDY || -10;
			
			this.settings = settings;
			
			titleColor = settings.color || 0x814f31;
			titleBorderColor = settings.borderColor || 0xfdf5ea;
			backingColor = settings.backingColor || 0xefc99a;
			backingRadius = settings.backingRadius || 55;
			
			info = App.data.storage[sID];
			if (!info.price || (!info.price.hasOwnProperty(Stock.FANT) && !info.price.hasOwnProperty(Stock.ACTION)))
				buyable = false;
			
			if (info) init();
		}
		
		private function init():void {
			App.self.addEventListener(AppEvent.ON_CHANGE_STOCK, onStockEvent);
			
			background = new Bitmap(new BitmapData(backingRadius * 2, backingRadius * 2, true, 0xffffff));
			background.x = 20;
			background.y = 20;
			addChild(background);
			
			var shape:Shape = new Shape();
			shape.graphics.beginFill(backingColor, 1);
			shape.graphics.drawCircle(backingRadius, backingRadius, backingRadius);
			shape.graphics.endFill();
			background.bitmapData.draw(shape);
			
			drawBitmap();
			drawTitle();
			drawCount();
			drawBttns();
			
			checkStatus();
		}
		
		private function onStockEvent(e:AppEvent):void {
			checkStatus();
		}
		
		private var _state:uint = UNREADY;
		
		private function drawTitle():void
		{
			title = Window.drawText(App.data.storage[sID].title, {
				color:			titleColor,
				borderColor:	titleBorderColor,
				textAlign:		"center",
				autoSize:		"center",
				fontSize:		24,
				textLeading:	-6,
				multiline:		true,
				wrap:			true,
				width:			130
			});
			
			title.x = background.x + (background.width - title.width) / 2;
			title.y = -10;
			addChild(title);
		}
		
		private var bankBttn:Button;
		private function drawBttns():void
		{
			if (type == MaterialItem.IN) {
				
				wishBttn = new ImageButton(UserInterface.textures.addBttnYellow);
				wishBttn.scaleX = 0.85;
				wishBttn.scaleY = 0.85;
				wishBttn.x = -10;
				wishBttn.y = 15;
				
				addChild(wishBttn);
				wishBttn.tip = function():Object { 
					return {
						title:"",
						text:Locale.__e("flash:1382952380013")
					};
				};
				
				if (sID == Stock.FANT || info.mtype == 5 || info.type == "Energy") wishBttn.visible = false;
				
				searchBttn = new ImageButton(UserInterface.textures.lens);
				searchBttn.x = wishBttn.x;
				searchBttn.y = wishBttn.y + wishBttn.height + 6;
				addChild(searchBttn);
				searchBttn.tip = function():Object {
					return {
						title:"",
						text:Locale.__e("flash:1427813835004")
					};
				}
				
				askBttn = new Button({
					caption			:Locale.__e("flash:1405687705056"),
					fontSize		:15,
					radius      	:10,
					fontColor:		0xffffff,
					fontBorderColor:0x475465,
					borderColor:	[0xfff17f, 0xbf8122],
					bgColor:		[0x75c5f6,0x62b0e1],
					bevelColor:		[0xc6edfe,0x2470ac],
					width			:94,
					height			:30,
					fontSize		:15
				});
				askBttn.x = background.x + background.width / 2 - askBttn.width / 2;
				askBttn.y = 135;
				
				var priceList:Object = Storage.price(sID);
				var price:int = 0;
				
				for (var s:* in priceList)
					price = priceList[s];
				
				var settings:Object = {
					caption		:Locale.__e('flash:1382952379751'),
					width		:112,
					height		:40,
					fontSize	:22,
					radius		:16,
					countText	:price * (need - count),
					multiline	:true
				};
				if (s == Stock.ACTION) {
					settings['type'] = 'actions';
					settings['iconScale'] = 0.25;
					settings['bgColor']  = [0xa6edb5, 0x62be8b];
					settings['bevelColor'] = [0xd5fef0, 0x3c9672];
				}
				buyBttn = new MoneyButton(settings);
				buyBttn.x = background.x + (background.width - buyBttn.width) / 2;
				buyBttn.y = askBttn.y + askBttn.height + 1;
				addChild(buyBttn);
				buyBttn.addEventListener(MouseEvent.CLICK, buyEvent);
				addChild(askBttn);
				
				askBttn.addEventListener(MouseEvent.CLICK, askEvent);
				wishBttn.addEventListener(MouseEvent.CLICK, wishesEvent);
				searchBttn.addEventListener(MouseEvent.CLICK, searchEvent);
				
				if (buyable) {
					buyBttn.visible = true;
					askBttn.visible = true;
					searchBttn.visible = true;
				}else {
					buyBttn.visible = false;
					//askBttn.visible = false;
					askBttn.y += 15;
					searchBttn.visible = false;
				}
				
			}else {
				if (outCount > 1)
				{
					var outCount_txt:TextField = Window.drawText("x "+String(outCount),{
						fontSize		:20,
						color			:0xffdc39,
						borderColor		:0x6d4b15,
						textAlign:"right"
					});
					outCount_txt.width = 140;					
					addChild(outCount_txt);
					
					//outCount_txt.border = true
					outCount_txt.x = 10;
					outCount_txt.y = 125;					
				}						
				
				cookBttn = new Button({
					caption:Locale.__e('flash:1382952380036'),
					width:116,
					height:36,
					radius:25,
					shadow:true
				});
				cookBttn.x = background.width / 2 - cookBttn.width / 2;
				cookBttn.y = 174;
			
				addChild(cookBttn);
			}
		}
		
		private function showBank(e:MouseEvent):void 
		{
			switch(bankBttn.order) {
				case 1:
					BankMenu._currBtn = BankMenu.REALS;
					BanksWindow.history = {section:'Reals',page:0};
					new BanksWindow({popup:true}).show();
				break;
				case 2:
					BankMenu._currBtn = BankMenu.COINS;
					BanksWindow.history = {section:'Coins',page:0};
					new BanksWindow({popup:true}).show();
				break;
				case 3:
					new PurchaseWindow( {
						popup:true,
						width:716,
						itemsOnPage:4,
						content:PurchaseWindow.createContent("Energy", {inguest:0, view:'Energy'}),
						title:Locale.__e("flash:1382952379756"),
						description:Locale.__e("flash:1382952379757"),
						callback:function(sID:int):void {
							var object:* = App.data.storage[sID];
							App.user.stock.add(sID, object);
						}
					}).show();
				break;
			}
		}
		
		private var intervalPluck:int;
		public var preloader:Preloader = new Preloader();
		public var sprTip:LayerX = new LayerX();
		public function drawBitmap():void
		{
			
			sprTip.tip = function():Object {
				return {
					title: info.title,
					text: info.description
				};
			}
			sprTip.addEventListener(MouseEvent.CLICK, askEvent);
			
			bitmap = new Bitmap();
			sprTip.addChild(bitmap);
			addChild(sprTip);
			
			if (App.user.stock.count(sID) < need) {
				setTimeout(setPluck, 2000);
			}
			
			addChild(preloader);
			preloader.x = background.x + (background.width / 2);
			preloader.y = (background.height) / 2;
			Load.loading(Config.getIcon(info.type, info.preview), onPreviewComplete);
		}
		
		public function doPluck():void
		{
			if (App.user.stock.count(sID) < need && !sprTip.isPluck) {
				sprTip.pluck(30, sprTip.width / 2, sprTip.height / 2 + 50);
			}
		}
		
		private function setPluck():void 
		{
			if(!sprTip.isPluck)sprTip.pluck(30, sprTip.width / 2, sprTip.height / 2 + 50);
			if (App.user.stock.count(sID) < need) {
				intervalPluck = setInterval(randomPluck, Math.random()* 5000 + 2000);
			}
		}
		
		private function randomPluck():void
		{
			if (App.user.stock.count(sID) >= need) {
				clearInterval(intervalPluck);
			}
			if (!sprTip.isPluck) {
				sprTip.pluck(30, sprTip.width / 2, sprTip.height / 2 + 50);
			}
		}
		
		public function onPreviewComplete(data:Bitmap):void
		{
			removeChild(preloader);
			bitmap.bitmapData = data.bitmapData;
			bitmap.smoothing = true;
			//bitmap.scaleX = bitmap.scaleY = 0.9;
			sprTip.x = background.x + (background.width - bitmap.width)/ 2;
			sprTip.y = background.y + (background.height - bitmap.height) / 2 + bitmapDY;
		}
		
		public function drawAnimalInfo():void {
			animalLabel = Window.drawText(Locale.__e("flash:1382952380225"),{
				fontSize		:18,
				color			:0xee9177,
				borderColor		:0x8c2a24,
				autoSize:"left"
			});
			
			
			addChild(animalLabel);
			animalLabel.x = (background.width - animalLabel.width) / 2;
			animalLabel.y = 136;
			
			thinkBttn = new Button({
				caption		:Locale.__e("flash:1382952380226"),
				width		:104,
				height		:30,	
				fontSize	:22
			});
			thinkBttn.x = (background.width - thinkBttn.width) / 2;
			thinkBttn.y = 160;
			addChild(thinkBttn);
			
			thinkBttn.addEventListener(MouseEvent.CLICK, onThinkEvent);
		}
		
		private function onThinkEvent(e:MouseEvent):void {
			//new ShopWindow( { find:[Stock.SPHERE], forcedClosing:true } ).show();
		}
		
		public function drawCount():void {
			
			count = App.user.stock.count(sID);
			
			var color:uint = 0xef7563;
			var borderColor:uint = 0x623126;
			if (count >= need) {
				color = 0xfedc34;
				borderColor = 0x694c14;
			}
			
			if (contains(countContainer)) {
				countContainer.removeChild(count_txt);
				countContainer.removeChild(vs_txt);
				countContainer.removeChild(need_txt);
				
				removeChild(countContainer);
			}
			
			count_txt = Window.drawText(String(count),{
				fontSize		:30,
				color			:color,
				borderColor		:borderColor,
				autoSize:"left"
			});
			
			vs_txt = Window.drawText(" / ", {
				fontSize		:25,
				color			:color,
				borderColor		:borderColor,
				autoSize:"left"
			});
			
			need_txt = Window.drawText(String(need),{
				fontSize		:30,
				color			:color,
				borderColor		:borderColor,
				autoSize:"left"
			});							
			
			
			countContainer.addChild(count_txt);
			countContainer.addChild(vs_txt);
			countContainer.addChild(need_txt);
			
			addChild(countContainer);
			
			refreshCountPosition();
		}
		
		public function setText(type:String, txt:*):void
		{
			switch(type)
			{
				case "count":
					count_txt.text = String(txt)
					count = Number(txt)
					break
				case "need":
					need_txt.text = String(txt)
					need = Number(txt)
					break
			}
			
			refreshCountPosition()
		}
		
		
		private function refreshCountPosition():void {
			
			count_txt.y = -16;
			count_txt.x = 0;
			vs_txt.x = count_txt.x + count_txt.textWidth;
			vs_txt.y = count_txt.y;
			need_txt.x = vs_txt.x + vs_txt.textWidth;
			need_txt.y = count_txt.y;
			
			countContainer.x = background.x + (background.width - countContainer.width) / 2;
			if (status == READY/* || !buyable*/) {
				countContainer.y = 150;
			}else{
				countContainer.y = 120;
			}
		}
		
		public function checkStatus():void
		{
			if (App.user.stock.check(sID, need, true) && status != READY) {
				changeOnREADY();
			}else if (!App.user.stock.check(sID, need, true) && status != UNREADY){
				changeOnUNREADY();
			}
		}
		
		public function changeOnREADY():void
		{
			clearInterval(intervalPluck);
			status = MaterialItem.READY;
			
			buyBttn.visible = false;
			askBttn.visible = false;
			searchBttn.visible = false;
			drawCount();
		}
		
		public function changeOnUNREADY():void {
			setText("count", count);
			status = MaterialItem.UNREADY;
			
			if (buyable) {
				buyBttn.visible = true;
				askBttn.visible = true;
				searchBttn.visible = true;
			}else {
				buyBttn.visible = false;
				askBttn.visible = false;
				searchBttn.visible = false;
			}
			drawCount();
		}
		
		private function askEvent(e:MouseEvent):void {
			Window.closeAll();
			ShopWindow.findMaterialSource(sID);
		}
		
		private function searchEvent(e:MouseEvent):void {
			WallPost.makePost(WallPost.ASK, {
				sid:		sID,
				bitmapData:	bitmap.bitmapData,
				message:	Locale.__e('flash:1427814478007', [info.title])
			});
		}
		
		private function wishesEvent(e:MouseEvent):void {
			App.wl.show(sID, e);
		}
		
		private function giftEvent(e:MouseEvent):void
		{
			
		}
		
		private var pnt:Point;
		/**
		 * Покупка материала flash:1382952379984 деньги
		 * @param	e
		 */
		private function buyEvent(e:MouseEvent):void
		{
			if (e.currentTarget.mode == Button.DISABLED) return;
			
			if (settings.hasOwnProperty('disableAll'))
				settings.disableAll(true);
				
			var _x:int = App.self.tipsContainer.mouseX - buyBttn.mouseX;
			var _y:int = App.self.tipsContainer.mouseY - buyBttn.mouseY;
			
			pnt = new Point(_x, _y);
			pnt.x += buyBttn.width / 2;
			pnt.y += -20;
			
			var def:int = need - count;
			e.currentTarget.state = Button.DISABLED;
			App.user.stock.buy(sID, def, onBuyEvent);
		}
		
		private function onBuyEvent(price:Object):void
		{
			for (var sid:* in price) {
				Hints.minus(sid, price[sid], pnt, false);
				break;
			}
			
			clearInterval(intervalPluck);
			
			count = App.user.stock.count(sID);
			changeOnREADY();
			dispatchEvent(new WindowEvent(WindowEvent.ON_CONTENT_UPDATE));
			
			if (settings.hasOwnProperty('disableAll'))
				settings.disableAll(false);
		}
		
		public function dispose():void
		{
			App.self.removeEventListener(AppEvent.ON_CHANGE_STOCK, onStockEvent);
			clearInterval(intervalPluck);
			
			if (searchBttn) searchBttn.removeEventListener(MouseEvent.CLICK, searchEvent);
			if (sprTip) sprTip.removeEventListener(MouseEvent.CLICK, askEvent);
			if (askBttn) askBttn.removeEventListener(MouseEvent.CLICK, askEvent);
			if (wishBttn) wishBttn.removeEventListener(MouseEvent.CLICK, wishesEvent);
			if (buyBttn) buyBttn.removeEventListener(MouseEvent.CLICK, buyEvent);
			if (thinkBttn) thinkBttn.removeEventListener(MouseEvent.CLICK, onThinkEvent);
		}
	}
}