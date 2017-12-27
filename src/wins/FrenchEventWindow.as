package wins 
{
	import buttons.ImageButton;
	import buttons.ImagesButton;
	import com.flashdynamix.motion.extras.BitmapTiler;
	import core.Load;
	import core.Size;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import wins.elements.RibbonItem;

	public class FrenchEventWindow extends Window 
	{
		public static var FRANKS:int = 2045;
		public static var MONEY_ICO:String = 'sweetMedalIco';
		public static var find:*;
		public static var showHelp:Boolean = true;
		
		private var ids:Array/* = [712, 710, 699, 783, 713, 725, 726, 727]*/;
		public var addBttn:ImageButton;
		public var franksLabel:TextField;
		public var infoBttn:ImageButton;
		
		public function FrenchEventWindow(settings:Object=null) 
		{
			if (settings == null) {
				settings = new Object();
			}
			
			settings['width'] = 755;
			settings['height'] = 580;// 610;
			settings['shadowSize'] = 3;
			settings['shadowBorderColor'] = 0x554234;
			settings['shadowColor'] = 0x554234;
			
			settings['title'] = Locale.__e("flash:1464078378618");
			settings['hasPaginator'] = true;
			settings['hasButtons'] = true;
			settings['itemsOnPage'] = 6;
			
			settings['content'] = [];
			
			if (App.data.options.hasOwnProperty('EventList')) {
				var eventList:Object = JSON.parse(App.data.options.EventList);
				if (eventList[0].hasOwnProperty('currency')) FrenchEventWindow.FRANKS = eventList[0].currency;
				if (eventList[0].hasOwnProperty('title')) settings['title'] = Locale.__e(eventList[0].title);
				if (eventList[0].hasOwnProperty('showHelp')) FrenchEventWindow.showHelp = eventList[0].showHelp;
				var items:Object = eventList[0].items;
				ids = [];
				for each (var itm:* in items) {
					if (!User.inUpdate(itm.sID)) continue;
					ids.push(itm.sID);
				}
			}
			
			for (var i:int = 0; i < ids.length; i++) {
				var item:Object = App.data.storage[ids[i]];
				item['sid'] = ids[i];
				if (item.hasOwnProperty('expire') && item.expire.hasOwnProperty(App.social) && item.expire[App.social] <= App.time && item.type != 'Fatman') {
					continue;
				}
				settings.content.push(item);
			}
			
			super(settings);
			
			App.self.addEventListener(AppEvent.ON_CHANGE_STOCK, onStockChange);
		}
		
		override public function drawBackground():void {
			//background = backing2(settings.width, settings.height, 50, 'iventShopBackingChocolateUP', 'iventShopBackingChocolateDown');
			background = backing2(settings.width, settings.height, 100, 'stockBackingTopWithoutSlate', 'stockBackingBot');
			//background.bitmapData.colorTransform(background.getBounds(background), new ColorTransform(0.8, 0.8, 0.8));
			layer.addChild(background);
			
			//drawMirrowObjs('saintPatrickDecorVertical', 10, settings.width - 10, settings.height - 135,false,false,false,1,1,layer);
			//drawMirrowObjs('decWeb', 10, settings.width - 10, settings.height - 135,false,false,false,1,1,layer);
		}
		
		override public function titleText(settings:Object):Sprite
		{
			var titleCont:Sprite = new Sprite();
			
			var textLabel:TextField = Window.drawText(settings.title, settings);
			if (this.settings.hasTitle == true && this.settings.titleDecorate == true) {
				//drawMirrowObjs('saintPatrickDecor', textLabel.x + (textLabel.width - textLabel.textWidth) / 2 - 150, textLabel.x + (textLabel.width - textLabel.textWidth) / 2 + textLabel.textWidth + 150, textLabel.y + (textLabel.height - 80) / 2, false, false, false, 1, 1, titleCont);
			}
			
			titleCont.mouseChildren = false;
			titleCont.mouseEnabled = false;
			titleCont.addChild(textLabel);
			
			return titleCont;
		}
		
		override public function drawBody():void {
			titleLabel.y += 15;
			RibbonItem.descriptionParams.fontSize = 25;
			RibbonItem.descriptionParams.shadowSize = 0;
			RibbonItem.titleParams.shadowSize = 0;
			RibbonItem.titleParams.color = 0xfdfbc7;
			RibbonItem.titleParams.borderColor = 0x92541d;
			
			RibbonItem.titleParams.fontSize = 25;
			
			var ribbon:RibbonItem;
			ribbon = new RibbonItem( { title:'', width:settings.width - 100, height:settings.height, decorated:false } );
			//ribbon.background.bitmapData.colorTransform(ribbon.background.getBounds(ribbon.background), new ColorTransform(0.8, 0.8, 0.8));
			ribbon.x += 50;
			ribbon.y -= 35;
			//bodyContainer.addChild(ribbon);
			
			
			var shine:Bitmap = new Bitmap(Window.texture('iconGlow'));
			shine.y -= 40;
			shine.scaleY = 0.8;
			bodyContainer.addChild(shine);
			
			var text:TextField = drawText(Locale.__e('flash:1425978184363'), {
				color:      	0xffffff,
				borderColor: 	0x854a3c,
				fontSize:		24
			});
			text.x = shine.x + (shine.width - text.textWidth) / 2;
			text.y -= 20;
			bodyContainer.addChild(text);
			
			//var frank:Bitmap = new Bitmap(Window.texture(MONEY_ICO));
			//frank.y += 5;
			//frank.x += 15;
			//bodyContainer.addChild(frank);
			
			var frank:Bitmap = new Bitmap();
			Load.loading(Config.getIcon(App.data.storage[FrenchEventWindow.FRANKS].type, App.data.storage[FrenchEventWindow.FRANKS].preview), function(data:*):void {
				frank.bitmapData = data.bitmapData;
				Size.size(frank, 50, 50);
				frank.smoothing = true;
				frank.x = 5;
				frank.y = 15;
				//frank.scaleX = frank.scaleY = 0.9;
				bodyContainer.addChild(frank);
			});
			
			franksLabel = drawText(String(App.user.stock.count(FRANKS)), {
				color:      	0xffeb96,
				borderColor: 	0x414311,
				fontSize:		32
			});
			franksLabel.x = shine.x + (shine.width - franksLabel.textWidth) / 2 + 5;
			franksLabel.y += 10;
			bodyContainer.addChild(franksLabel);
			
			addBttn = new ImageButton(Window.texture('interAddBttnGreen'));
			addBttn.x = franksLabel.x + franksLabel.textWidth + 15;
			addBttn.y = franksLabel.y;
			bodyContainer.addChild(addBttn);
			
			addBttn.addEventListener(MouseEvent.CLICK, onAddFranks);
			
			createInfoIcon();
			
			if (settings.content.length != 0) {
				if (FrenchEventWindow.find != 0) {
					for (var i:int = 0; i < settings.content.length; i++) {
						if (settings.content[i].sid == FrenchEventWindow.find) {
							paginator.page = int(int(i) / settings.itemsOnPage);
							break;
						}							
					}
				}
				paginator.itemsCount = settings.content.length;
				paginator.update();
				paginator.onPageCount = settings.itemsOnPage;
			}
			contentChange();
		}
		
		private function createInfoIcon():void 
		{			
			infoBttn = new ImagesButton(Window.texture('interHelpBttn'));			
			infoBttn.tip = function():Object { 
				return {
					title:Locale.__e("flash:1382952380254"),
					text:''
				};
			};
			
			infoBttn.addEventListener(MouseEvent.CLICK, onInfo);
			
			infoBttn.x = 600;
			infoBttn.y = -10;
			
			if (FrenchEventWindow.showHelp) bodyContainer.addChild(infoBttn);	
		}
		
		private function onInfo(e:Event = null):void 
		{
			new InfoWindow( {qID:'event'} ).show();
		}
		
		public function onAddFranks(e:MouseEvent = null):void {
			new PurchaseWindow( {
				width:595,
				itemsOnPage:3,
				content:PurchaseWindow.createContent("Energy", {view:'w_sweet_medal'}),
				title:Locale.__e("flash:1382969956057"),
				fontBorderColor:0xd49848,
				shadowColor:0x553c2f,
				shadowSize:4,
				description:Locale.__e("flash:1382952379757"),
				popup: true,
				closeAfterBuy: false,
				callback:function(sID:int):void {
					var object:* = App.data.storage[sID];
					App.user.stock.add(sID, object);
				}
			}).show();
			return;
		}
		
		private function onStockChange(e:AppEvent):void 
		{
			franksLabel.text = String(App.user.stock.count(FRANKS));
			contentChange();
		}
		
		public var items:Array = [];
		override public function contentChange():void {
			for each(var _item:* in items) {
				bodyContainer.removeChild(_item);
				_item.dispose();
			}
			items = [];
			//var X:int = 60;
			var X:int = 121;
			var Xs:int = X;
			//var Ys:int = 70;
			var Ys:int = 50;
			
			var itemNum:int = 0;
			for (var i:int = paginator.startCount; i < paginator.finishCount; i++) {
				var item:*;
				item = new EventShopItem(this, settings.content[i]);
				bodyContainer.addChildAt(item,1);
				item.x = Xs - 10;
				item.y = Ys;
				
				items.push(item);
				
				//Xs += item.background.width + 6;
				Xs += item.background.width + 26;
				
				if (itemNum == int(settings.itemsOnPage / 2) - 1)	{
					Xs = X;
					Ys += item.background.height + 15;
				}
				itemNum++;
			}
		}
		
		override public function drawArrows():void {
			super.drawArrows();			
			paginator.x = int((settings.width - paginator.width)/2 - 40);
			paginator.y = int(settings.height - paginator.height + 3);
		}
		
		override public function dispose():void {
			addBttn.removeEventListener(MouseEvent.CLICK, onAddFranks);
			App.self.removeEventListener(AppEvent.ON_CHANGE_STOCK, onStockChange);
			FrenchEventWindow.find = 0;
			super.dispose();
		}
	}

}

import buttons.Button;
import buttons.ImageButton;
import buttons.MoneyButton;
import com.greensock.easing.Cubic;
import com.greensock.TweenLite;
import core.Load;
import core.Size;
import core.TimeConverter;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.geom.ColorTransform;
import flash.geom.Point;
import flash.text.TextField;
import flash.utils.setTimeout;
import ui.Cursor;
import ui.Hints;
import ui.UserInterface;
import units.AnimationItem;
import units.Anime;
import units.Anime2;
import units.Field;
import units.Techno;
import units.Unit;
import units.Walkgolden;
import wins.FrenchEventWindow;
import wins.LuckyBagWindow;
import wins.HeroWindow;
import wins.PurchaseWindow;
import wins.ShopWindow;
import wins.SimpleWindow;
import wins.Window;

internal class EventShopItem extends LayerX
{
	public var item:*;
	public var background:Bitmap;
	public var bitmap:Bitmap;
	public var title:TextField;
	public var priceBttn:Button;
	private var infoBttn:Button;
	private var loopBttn:ImageButton;
	public var window:*;
	
	public var moneyType:String = "coins";
	public var previewScale:Number = 1;
	
	private var preloader:Preloader = new Preloader();
	
	private var price:int = 0;
	
	public function EventShopItem(window:FrenchEventWindow, item:Object)
	{
		this.item = item;
		this.window = window;
		
		var backing:String = 'itemBacking';
		
		if (item.hasOwnProperty('backview')) {
			if (item.backview != '') backing = item.backview;
		}
			
		if (item.sid == 461) backing = 'itemBackingGreen';
		
		background = Window.backing(160, 200, 10, backing);
		//background.bitmapData.colorTransform(background.getBounds(background), new ColorTransform(0.85, 0.85, 0.85));
		addChild(background);
		
		if (item.type == 'Golden' || item.type == 'Gamble' || item.type == 'Walkgolden' || item.type == 'Thimbles' || [1005, 1008, 1009, 1044, 1045, 1055, 1056].indexOf(int(item.sid)) != -1 && [2158, 2159, 2160].indexOf(int(item.sid)) == -1) {
			setGold();
		}
		
		if ([2158, 2159, 2160].indexOf(int(item.sid)) != -1) {
			setBow();
		}
		
		addChild(preloader);
		preloader.x = (background.width)/ 2;
		preloader.y = (background.height)/ 2 - 15;
		
		bitmap = new Bitmap();
		if (item.type == "Golden" || item.type == 'Thimbles' || item.type == 'Gamble') {
			Load.loading(Config.getSwf(item.type, item.view), onAnimComplete);
		}else if (item.type == "Walkgolden") {
			Load.loading(Config.getSwf(item.type, item.view), onWalkAnimComplete);
		}else {
			Load.loading(Config.getIcon(item.type, item.preview), onImageLoad);
		}
		
		drawTitle();
		drawPrice();
		drawButton();
		
		tip = function():Object {
			return {
				title:item.title,
				text:item.description
			};
		};
		
		if (item.type == 'Box') {
			drawLoop();
		}
		
		if (item.hasOwnProperty('expire') && item.expire.hasOwnProperty(App.social) && item.type != 'Fatman') {
			if (item.expire[App.social] > App.time) {
				drawTimer();
			} else {
				priceBttn.state = Button.DISABLED;
			}
		}
	}
	
	private var timerText:TextField;
	private function drawTimer():void {
		timerText = Window.drawText(TimeConverter.timeToStr(item.expire[App.social] - App.time), {
			color: 0xfff200,
			borderColor: 0x680000,
			fontSize: 26,
			textAlign: 'center',
			width: background.width
		});
		timerText.y = title.y + title.textHeight + 5;
		addChild(timerText);
		App.self.setOnTimer(updateTimer);
	}
	
	private function updateTimer():void {
		if (timerText) {
			var text:String = TimeConverter.timeToStr(item.expire[App.social] - App.time);
			timerText.text = text;
			
			if (item.expire[App.social] - App.time <= 0) {
				timerText.visible = false;					
				App.self.setOffTimer(updateTimer);
				
				priceBttn.state = Button.DISABLED;
			}
		}
	}
	
	private function onWalkAnimComplete(swf:*):void 
	{
		removeChild(preloader);
		
		var anime:Anime = new Anime(swf, { w:background.width - 20, h:background.height - 40, walking:true} );
		anime.x = (background.width - anime.width) / 2;
		anime.y = (background.height - anime.height) / 2;
		addChildAt(anime,1);
	}
	
	private function onAnimComplete(swf:*):void 
	{
		removeChild(preloader);
		
		var anime:Anime = new Anime(swf, { w:background.width - 20, h:background.height - 40 } );
		if (item.sid == 1005) anime.scaleX = anime.scaleY = 0.8;
		anime.x = (background.width - anime.width) / 2;
		anime.y = (background.height - anime.height) / 2 /*- 10*/;
		addChildAt(anime,1);
	}
	
	private function onImageLoad(data:Bitmap):void {
		removeChild(preloader);item
		
		bitmap.bitmapData = data.bitmapData;
		bitmap.smoothing = true;
		Size.size(bitmap, background.width * 0.85, background.height * 0.85);
		bitmap.x = background.x + background.width * 0.5 - bitmap.width * 0.5;
		bitmap.y = background.y + background.height * 0.5 - bitmap.height * 0.5 - 10;
		if (item.sid == 1010) bitmap.y += 10;
		
		addChildAt(bitmap,1);
	}
	
	private function drawTitle():void {
		title = Window.drawText(item.title, {
			color:       0x7c391f,
			borderColor: 0xf7f5e9,
			fontSize:	 23,
			shadowSize:  1,
			autoSize:	 'center'
		});
		title.x = background.x + (background.width - title.textWidth) / 2;
		title.y += 5;
		addChild(title);
	}
	
	public var money_sid:*;
	private function drawPrice():void {
		var frank:Bitmap = new Bitmap();
		Load.loading(Config.getIcon(App.data.storage[FrenchEventWindow.FRANKS].type, App.data.storage[FrenchEventWindow.FRANKS].preview), function(data:*):void {
			frank.bitmapData = data.bitmapData;
			Size.size(frank, 40, 40);
			frank.smoothing = true;
			frank.x += 15;
			frank.y = background.height - 75;
			//frank.scaleX = frank.scaleY = 0.9;
			addChild(frank);
		});
		//var frank:Bitmap = new Bitmap(Window.texture(FrenchEventWindow.MONEY_ICO));
		//frank.x += 15;
		//frank.y = background.height - 75;
		//frank.scaleX = frank.scaleY = 0.9;
		//addChild(frank);
		
		var bttnSettings:Object = {
			color:      	0xffeb96,
			borderColor: 	0x414311,
			fontSize:		26,
			textAlign:		'left'
		}
		
		var price:Object = item.price;
	
		for (money_sid in price) {
			if (App.user.stock.count(FrenchEventWindow.FRANKS) >= price[money_sid]) {
				bttnSettings["color"] = 0xfdf087;
				bttnSettings["borderColor"] = 0x3b3900;
				bttnSettings["fontSize"] = 26;
			} else {
				bttnSettings["color"] = 0xffa883;				
				bttnSettings["borderColor"] = 0x4f1804;
				bttnSettings["fontSize"] = 26;
			}
		}
		
		if (item.hasOwnProperty('gcount') && item.gcount != 0) {
			var countInstance:int = item.gcount;
			var count:int = World.getBuildingCount(item.sid) + App.user.stock.count(item.sid);
			if (Storage.isShopLimited(item.sid))
				count = Storage.shopLimit(item.sid);
			
			var txt:String = String(count) + "/" + countInstance;
			
			var counterLabel:TextField = Window.drawText(txt, {
				fontSize:23,
				color:0xffffff,
				borderColor:0x2D2D2D,
				autoSize:"left"
			});
			
			counterLabel.x = 113;
			counterLabel.y = 135;
			addChild(counterLabel);
		}
		
		if (price == null ) {
			if (item.hasOwnProperty('instance')) {
				var countOnMap:int = World.getBuildingCount(item.sid) + App.user.stock.count(item.sid);
				if (!item.instance.cost.hasOwnProperty(countOnMap + 1)) {
					while (!item.instance.cost.hasOwnProperty(countOnMap + 1) && countOnMap > 0) {
						countOnMap --;
					}
				}
				
				price = item.instance.cost[countOnMap+1];
				
				for (money_sid in price) {
					if (App.user.stock.count(FrenchEventWindow.FRANKS) >= price[money_sid]) {
						bttnSettings["color"] = 0xfdf087;
						bttnSettings["borderColor"] = 0x3b3900;
						bttnSettings["fontSize"] = 26;
					} else {
						bttnSettings["color"] = 0xffa883;				
						bttnSettings["borderColor"] = 0x4f1804;
						bttnSettings["fontSize"] = 26;
					}
				}
			}
		}
		
		if (price) {
			this.price = price[money_sid];
		} else {
			if (item.hasOwnProperty('currency')) {
				this.price = item.currency[FrenchEventWindow.FRANKS];
				
				if (App.user.stock.count(FrenchEventWindow.FRANKS) >= this.price) {
					bttnSettings["color"] = 0xfdf087;
					bttnSettings["borderColor"] = 0x3b3900;
					bttnSettings["fontSize"] = 26;
				} else {
					bttnSettings["color"] = 0xffa883;				
					bttnSettings["borderColor"] = 0x4f1804;
					bttnSettings["fontSize"] = 26;
				}
			}
		}
		
		var franksLabel:TextField = Window.drawText(String(this.price), bttnSettings);
		franksLabel.x = 55;// frank.x + frank.width;
		franksLabel.y = background.height - 75 + 10;// frank.y + 10;
		addChild(franksLabel);
	}
	
	private var boughtText:TextField;
	private function drawButton():void {
		var bttnSettings:Object = {
			caption:Locale.__e("flash:1382952379751"),
			fontSize:27,
			width:136,
			height:42,
			hasDotes:false
		};
			
		priceBttn = new Button(bttnSettings);
		addChild(priceBttn);
		
		priceBttn.x = background.width/2 - priceBttn.width/2;
		priceBttn.y = background.height - priceBttn.height + 15;
		
		priceBttn.addEventListener(MouseEvent.CLICK, onBuyEvent);
		
		if (item.type == 'Vip') {
			if (App.user.stock.data.hasOwnProperty(item.sid) && App.user.stock.data[item.sid] > App.time) {
				boughtText = Window.drawText('', {
					color:0xfff2dd,
					borderColor:0x7a602f,
					borderSize:4,
					fontSize:24,
					textAlign:'center',
					width:background.width - 20
				});
				boughtText.x = (background.width - boughtText.width) / 2;
				boughtText.y = background.height - boughtText.textHeight - 20;
				addChild(boughtText);
				App.self.setOnTimer(vipTimer);
				vipTimer();
				
				priceBttn.visible = false;
				
			}else {
				if (boughtText) {
					removeChild(boughtText);
					boughtText = null;
				}
				priceBttn.visible = true;
				App.self.setOffTimer(vipTimer);
			}
		}
		
		/*if (App.user.stock.count(FrenchEventWindow.FRANKS) < price) {
			priceBttn.state = Button.DISABLED;
		}*/
		if (FrenchEventWindow.find && FrenchEventWindow.find == item.sid) {
			priceBttn.showGlowing();
			FrenchEventWindow.find = 0;
		}else if (FrenchEventWindow.find is Array && FrenchEventWindow.find.indexOf(int(item.sid)) != -1) {
			priceBttn.showGlowing();
		}
	}
	
	private function drawLoop():void {
		loopBttn = new ImageButton(UserInterface.textures.lens);
		loopBttn.x = 10;
		loopBttn.y = 27;
		addChild(loopBttn);
		
		loopBttn.addEventListener(MouseEvent.CLICK, onLoop);
	}
	
	private function vipTimer():void {
		var time:int = App.user.stock.data[item.sid] - App.time;
		if (time <= 0) {
			drawButton();
		}else{
			boughtText.text = TimeConverter.timeToStr(time);
		}
	}
	
	private function onBuyEvent(e:MouseEvent):void {
		if (e.currentTarget.mode == Button.DISABLED) return;
		if (App.user.stock.count(FrenchEventWindow.FRANKS) < price) {
			window.onAddFranks();
			return;
		}
		ShopWindow.currentBuyObject = { type:item.type, sid:item.sid };
		var unit:Unit;
		switch(item.type)
		{
			case "Material":
			case 'Vip':
			case 'Accelerator':
			case 'Firework':
			case 'Box':
				App.user.stock.buy(item.sid, 1);
				break;
			case "Boost":
			case "Energy":
				var sett:Object = null;
				if (App.data.storage[item.sid].out == Techno.TECHNO) {
					sett = { 
						ctr:'techno',
						wID:App.user.worldID,
						x:App.map.heroPosition.x,
						z:App.map.heroPosition.z,
						capacity:1
					};
					App.user.stock.pack(item.sid, onBuyComplete, function():void {
					}, sett);
				}else {
					App.user.stock.pack(item.sid);
				}
				break;
			case "Plant":
				unit = Unit.add( { sid:181, pID:item.sID, planted:0 } );
				unit.move = true;
				App.map.moved = unit;
				Cursor.material = item.sid;
				
				Field.exists = false;
				
				break;
			case 'Clothing':
				new HeroWindow({find:item.sid}).show();
				break;
			case 'Animal':
				unit = Unit.add( { sid:item.sid, buy:true } );
				unit.move = true;
				App.map.moved = unit;
				break;
			case 'Decor':
				if (item.dtype == 2) {
					App.user.stock.buy(item.sid, 1);
					flyMaterial(item.sid);
					new SimpleWindow( {
						title:item.title,
						text: Locale.__e('flash:1382952379990'),
						popup:true
					}).show();
				} else {
					unit = Unit.add( { sid:item.sid, buy:true } );
					unit.move = true;
					App.map.moved = unit;
				}
				break;
			case 'Golden':
				if ((item.sid == 553 || item.sid == 554) && App.user.worldID != 555) {
					App.user.stock.buy(item.sid, 1);
					flyMaterial(item.sid);
					new SimpleWindow( {
						title:item.title,
						text: Locale.__e('flash:1382952379990'),
						popup:true
					}).show();
				} else {
					unit = Unit.add( { sid:item.sid, buy:true } );
					unit.move = true;
					App.map.moved = unit;
				}
				break;
			default:
				unit = Unit.add( { sid:item.sid, buy:true } );
				
				unit.move = true;
				App.map.moved = unit;
			break;
		}
		
		/*if ([2,23,55,5].indexOf(App.user.quests.currentQID) >= 0) {
			Tutorial.tutorialQuests();
		}*/
		
		if(item.type != "Material" && item.type != "Accelerator" && item.type != "Box" && item.type != "Firework"){
			window.close();
		}else{
			/*var point:Point = localToGlobal(new Point(e.currentTarget.x, e.currentTarget.y));
			point.x += e.currentTarget.width / 2;
			Hints.minus(Stock.COINS, item.coins, point);*/
			if (item.type == 'Box') {
				rewardW = new Bitmap;
				rewardW.bitmapData = bitmap.bitmapData;
				wauEffect();
			}else {
				flyMaterial(item.sid);
			}
		}
	}
	
	private function onBuyComplete(sID:uint, rez:Object = null):void 
	{
		var item:Object = App.data.storage[sID];
		if (item.type == 'Accelerator' /*|| item.type == 'Box'*/) {
			flyMaterial(sID);
		}
	}
	
	public var rewardW:Bitmap;
	private function wauEffect(e:MouseEvent =  null):void {
		var count:int = 1;
		if (rewardW.bitmapData != null) {
			var rewardCont:Sprite = new Sprite();
			App.self.windowContainer.addChild(rewardCont);
			
			var glowCont:Sprite = new Sprite();
			glowCont.alpha = 0.6;
			glowCont.scaleX = glowCont.scaleY = 0.5;
			rewardCont.addChild(glowCont);
			
			var glow:Bitmap = new Bitmap(Window.textures.actionGlow);
			glow.x = -glow.width / 2;
			glow.y = -glow.height + 90;
			glowCont.addChild(glow);
			
			var glow2:Bitmap = new Bitmap(Window.textures.actionGlow);
			glow2.scaleY = -1;
			glow2.x = -glow2.width / 2;
			glow2.y = glow.height - 90;
			glowCont.addChild(glow2);
			
			var bitmap:Bitmap = new Bitmap(new BitmapData(rewardW.width, rewardW.height, true, 0));
			bitmap.bitmapData = rewardW.bitmapData;
			bitmap.smoothing = true;
			bitmap.x = -bitmap.width / 2;
			bitmap.y = -bitmap.height / 2;
			rewardCont.addChild(bitmap);
			
			var countText:TextField = Window.drawText('x' + String(count), {
				fontSize:		32,
				color:			0xffffff
			});
			countText.x = bitmap.x + bitmap.width - countText.textWidth;
			countText.y = bitmap.y + bitmap.height - 10;
			rewardCont.addChild(countText);
			
			if (e) {
				rewardCont.x = e.target.parent.x + e.target.parent.width / 2 ;
				rewardCont.y = e.target.parent.y + e.target.parent.height / 2 ;
			} else {
				rewardCont.x = rewardCont.y = 0;
			}
			
			function rotate():void {
				glowCont.rotation += 1.5;
			}
			
			App.self.setOnEnterFrame(rotate);
			
			count = 0;
			TweenLite.to(rewardCont, 0.5, { x:App.self.stage.stageWidth / 2, y:App.self.stage.stageHeight / 2, scaleX:1.25, scaleY:1.25, ease:Cubic.easeInOut, onComplete:function():void {
				setTimeout(function():void {
					App.self.setOffEnterFrame(rotate);
					glowCont.alpha = 0;
					var bttn:* = App.ui.bottomPanel.bttnMainStock;
					var _p:Object = { x:App.ui.bottomPanel.x + bttn.parent.x + bttn.x + bttn.width / 2, y:App.ui.bottomPanel.y + bttn.parent.y + bttn.y + bttn.height / 2};
					SoundsManager.instance.playSFX('takeResource');
					TweenLite.to(rewardCont, 0.3, { ease:Cubic.easeOut, scaleX:0.7, scaleY:0.7, x:_p.x, y:_p.y, onComplete:function():void {
						TweenLite.to(rewardCont, 0.1, { alpha:0, onComplete:function():void {App.self.windowContainer.removeChild(rewardCont);}} );
					}} );
				}, 3000)
			}} );
		}
	}
	
	private function onLoop(e:MouseEvent):void {
		var items:Array = [];
		for each(var decor:* in item.devel.obj) {
			for (var decorID:* in decor) {
				items.push({sid:decorID, count:decor[decorID]});
			}
		}
		new LuckyBagWindow( {
			popup:true,
			width:500,
			height:300,
			hasButtons:false,
			title:Locale.__e('flash:1382952380294'),
			items:items
		}).show();
	}
	
	public function flyMaterial(_sid:int):void
	{
		var item:BonusItem = new BonusItem(uint(_sid), 0);
		
		var point:Point = Window.localToGlobal(bitmap);
		point.y += bitmap.height / 2;
		
		item.cashMove(point, App.self.windowContainer);
	}
	
	public function setGold():void {
		var newStripe:Bitmap = new Bitmap(Window.textures.goldRibbon);
		newStripe.x = 2;
		newStripe.y = 3;
		
		addChildAt(newStripe,1);
	}
	
	private function setBow():void {
		var newBow:Bitmap = new Bitmap(Window.textures.bowRibbonPic);
		newBow.x = 2;
		newBow.y = 3;
		
		addChildAt(newBow,1);
	}
	
	public function dispose():void {
		priceBttn.removeEventListener(MouseEvent.CLICK, onBuyEvent);
	}
}

