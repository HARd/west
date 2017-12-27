package wins 
{
	import buttons.Button;
	import buttons.ImageButton;
	import core.Load;
	import core.Numbers;
	import core.Post;
	import core.Size;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import ui.Hints;
	import units.Exchange;
	public class ExchangeWindow extends Window 
	{
		public static var history:int = 0;
		public static var find:*;
		public static var isInTop:Boolean = false;
		public static var depthShow:int = 0;
		
		public var franksLabel:TextField;
		
		public var currency:int = Stock.ACTION;
		private var barterInfo:Array = [];
		public var topBttn:ImageButton;
		public var topx:int = 100;
		
		private var upgradeButton:Button;
		public var addBttn:ImageButton;
		public var top:int = 3;
		
		public function ExchangeWindow(settings:Object=null) 
		{
			if (settings == null) {
				settings = new Object();
			}
			
			settings["width"] = 640;
			settings["height"] = 670;
			settings['background'] = 'storageBackingMain';
			settings["hasPaginator"] = true;
			settings["hasArrows"] = true;
			settings["hasButtons"] = false;
			settings["itemsOnPage"] = 6;
			settings["page"] = history;
			settings['content'] = [];
			settings['shadowColor'] = 0x513f35;
			settings['shadowSize'] = 4;
			
			top = settings['top'];
			
			try {
				//topx = settings.target.info.topx;
				currency = settings.target.currency;
			}catch(e:Error){}
			
			if (settings.target.info.devel.hasOwnProperty('exchange') && settings.target.info.devel.exchange.hasOwnProperty(settings.target.level)) {
				for (var id:* in settings.target.info.devel.exchange[settings.target.level]) {
					var item:Object = settings.target.info.devel.exchange[settings.target.level][id];
					if (!User.inUpdate(item.sid)) continue;
					if (item.hasOwnProperty('expire') && item.expire.hasOwnProperty(App.social) && item.expire[App.social] <= App.time && item.type != 'Fatman') {
						continue;
					}
					item['id'] = id;
					settings.content.push(item);
				}
			}
			
			//settings.content.sortOn('sid', Array.DESCENDING);
			settings["title"] = (currency == Stock.ACTION) ?Locale.__e("flash:1440150927787") : App.data.storage[settings.target.sid].title;
			
			checkBarters(settings.target.sid);
			
			super(settings);
			
			if (ExchangeWindow.depthShow > 0) {
				if (depthShow == 1) depthShow = 0;
				openTop();
			}
		}
		
		public function checkBarters(sid:int):void {
			var outID:*;
			for (var id:* in App.data.barter) {
				var barter:Object = App.data.barter[id];
				if (barter.building == sid) {
					outID = 0;
					
					var inUpdate:Boolean = true;
					for (outID in barter.out) {
						if (!User.inUpdate(outID))
							inUpdate = false;
					}
					if (inUpdate)
						barterInfo.push(barter);
				}
			}
		}
		
		override public function drawBackground():void {
			background = backing2(settings.width, settings.height, 180, 'shopBackingTop', 'backingBot');
			layer.addChild(background);
		}
		
		override public function drawBody():void {	
			titleLabel.y += 10;
			var backing:Bitmap = backingShort(settings.width, 'shopBackingBot');
			backing.x = 0;
			backing.y = settings.height - 425;
			bodyContainer.addChild(backing);
			
			var contBack:Sprite = new Sprite();
			var back:Bitmap = Window.backing(170, 60, 50, 'itemBacking');
			contBack.addChild(back);
			contBack.x = settings.width / 2 - contBack.width / 2;
			contBack.y = 390;
			bodyContainer.addChild(contBack);
			
			var text:TextField = drawText(Locale.__e('flash:1425978184363'), {
				color:      	0xffe641,
				borderColor: 	0x804d32,
				fontSize:		28
			});
			text.x = back.x - 88;
			text.y = (back.height - text.textHeight ) / 2;
			contBack.addChild(text);
			
			var frank:Bitmap;
			Load.loading(Config.getIcon(App.data.storage[currency].type, App.data.storage[currency].preview), function(data:Bitmap):void {
				frank = new Bitmap(data.bitmapData);
				Size.size(frank, 45, 45);
				frank.smoothing = true;
				frank.y = 5;
				frank.x = 20;
				contBack.addChild(frank);
			});
			
			var labelSettings:Object;
			if (currency == Stock.ACTION) {
				labelSettings = {
					color:      	0x6efffb,
					borderColor: 	0x113d7c,
					fontSize:		36
				};
			} else {
				labelSettings = {
					color:      	0xfffffd,
					borderColor: 	0x7c3f06,
					fontSize:		36
				};
			}
			franksLabel = drawText(String(App.user.stock.count(currency)), labelSettings);
			franksLabel.x = 75;
			franksLabel.y += 10;
			contBack.addChild(franksLabel);
			
			addBttn = new ImageButton(Window.texture('interAddBttnGreen'));
			addBttn.x = back.x + back.width - addBttn.width - 5;
			addBttn.y = franksLabel.y;
			if (!App.isSocial('MX','AI','YB','GN')) contBack.addChild(addBttn);
			
			addBttn.addEventListener(MouseEvent.CLICK, onAddCurrency);
			
			topBttn = new ImageButton(Window.texture('homeBttn'));
			topBttn.scaleX = topBttn.scaleY = 0.8;
			topBttn.x = 20;
			topBttn.y -= 30;
			bodyContainer.addChild(topBttn);
			topBttn.showGlowing();
			
			var topBttnText:TextField = Window.drawText(Locale.__e('flash:1440154414885'), {
				//width:			topBttn.width,
				textAlign:		'center',
				fontSize:		32,
				color:			0xFFFFFF,
				borderColor:	0x631d0b,
				shadowSize:		1
			});
			topBttnText.x = 20;
			topBttnText.y = (topBttn.height - topBttnText.height) / 2 + 10;
			topBttn.addChild(topBttnText);
			topBttn.visible = false;
			if (settings.target.sid == 797)
				topBttn.visible = true;
			
			topBttn.addEventListener(MouseEvent.CLICK, openTop);
			
			if (settings.content.length != 0) {
				if (ExchangeWindow.find != 0) {
					for (var i:int = 0; i < settings.content.length; i++) {
						if (settings.content[i].sid == ExchangeWindow.find) {
							paginator.page = int(int(i) / settings.itemsOnPage);
							break;
						}							
					}
				}
				paginator.itemsCount = settings.content.length;
				paginator.update();
				paginator.onPageCount = settings.itemsOnPage;
			}
			
			drawBarterItem();
			
			contentChange();
		}
		
		public function onAddCurrency(e:MouseEvent = null):void {
			var view:String = App.data.storage[currency].view;
			var content:Array = PurchaseWindow.createContent('Energy', { view:view } );
			new PurchaseWindow( {
				width:620,
				itemsOnPage:content.length,
				content:content,
				title:App.data.storage[currency].title,
				fontBorderColor:0xd49848,
				shadowColor:0x553c2f,
				shadowSize:4,
				hasDescription:false,
				description:App.data.storage[currency].description,
				popup: true,
				closeAfterBuy:false,
				callback:function(sID:int):void {
					//var object:* = App.data.storage[sID];
					//App.user.stock.add(sID, object);
					
					contentChange();	
					franksLabel.text = String(App.user.stock.count(currency));
				}
			}).show();
		}
		
		protected function openTop(e:MouseEvent = null):void {
			if (rateChecked == 0) {
				rateChecked = App.time;
				getRate(openTop);
				return;
			}
			
			rateChecked = 0;
			
			var desc:String = Locale.__e('flash:1440518562248');
			if (App.isSocial('YB', 'MX')) desc = Locale.__e('flash:1452782393780');
			new TopWindow( {
				title:			Locale.__e('flash:1452678912657'),
				description:	desc,
				target:			settings.target,
				points:			Exchange.rate,
				max:			topx,
				content:		Exchange.rates,
				material:		null,
				popup:			true,
				top:			this.top,
 				onInfo:			function():void {
					if (App.isSocial('YB', 'MX','AI')) {
						new InfoWindow({qID:'100500'}).show();
					}else {
						new TopRewardWindow( { topID: top } ).show();
					}
				}
			}).show();
		}
		
		override public function drawArrows():void {			
			paginator.drawArrow(bodyContainer, Paginator.LEFT,  0, 0, { scaleX: -1, scaleY:1 } );
			paginator.drawArrow(bodyContainer, Paginator.RIGHT, 0, 0, { scaleX:1, scaleY:1 } );
			
			var y:Number = (settings.height - paginator.arrowLeft.height) / 2 - settings.height / 4 + 30;
			paginator.arrowLeft.x = -paginator.arrowLeft.width / 2 + 16;
			paginator.arrowLeft.y = y;
			
			paginator.arrowRight.x = settings.width-paginator.arrowRight.width/2 - 16;
			paginator.arrowRight.y = y;
			
		}
		
		/*private function openTop(e:MouseEvent = null):void {
			new InfoWindow({qID:100500}).show();
		}*/
		
		private var item:BarterItems;
		public function drawBarterItem():void {
			if (item) {
				item.dispose();
				bodyContainer.removeChild(item);
			}
			
			for each(var barter:Object in barterInfo) break;
			if (!barter) {
				drawUpgrade();
				return;
			}
			
			item = new BarterItems(barter.ID, this);
			item.x = (settings.width - item.width) / 2;
			item.y = settings.height - 210;
			bodyContainer.addChild(item);
		}
		
		private function drawUpgrade():void {
			var upgradeLabel:TextField = drawText(Locale.__e('flash:1451296090050'), {
				color:0xfeffff,
				borderColor:0x5d250e,
				multiline:true,
				textAlign:"center",
				wrap:true,
				fontSize:30,
				width:350
			});
			upgradeLabel.x = (settings.width - upgradeLabel.width) / 2;
			upgradeLabel.y = settings.height - 210;
			bodyContainer.addChild(upgradeLabel);
			
			var upgradeParams:Object = {
				caption:Locale.__e('flash:1425574338255'),
				bgColor:[0x7bc9f9, 0x60aedf],
				bevelColor:[0xa5ddfb, 0x266fad],
				borderColor:[0xd5c2a9, 0xbca486],
				fontSize:26,
				fontBorderColor:0x40505f,
				shadowColor:0x40505f,
				shadowSize:4,
				width:210,
				height:52
			};
			upgradeButton = new Button(upgradeParams);
			upgradeButton.x = (settings.width - upgradeButton.width) / 2;
			upgradeButton.y = settings.height - upgradeButton.height * 1.5 - 10;
			
			if (settings.target.level == settings.target.totalLevels) {
				upgradeLabel.text = Locale.__e('flash:1451298865534');
				upgradeLabel.y = settings.height - 170;
				return;
			}
			drawMirrowObjs('upgradeDec', upgradeButton.x + 24, upgradeButton.x + upgradeButton.width - 24, upgradeButton.y, true, true, false);
			
			bodyContainer.addChild(upgradeButton);
			upgradeButton.addEventListener(MouseEvent.CLICK, onUpgradeButtonEvent);
			
			if (ExchangeWindow.find == settings.target.sid)
				upgradeButton.startGlowing();
		}
		
		private function onUpgradeButtonEvent(e:MouseEvent):void {
			var updateNumber:int = 1;
			var properties:Object = App.data.options.hasOwnProperty('updatesQueue') ? JSON.parse(App.data.options.updatesQueue) : {};
			if (properties.hasOwnProperty(App.social))
				updateNumber = properties[App.social];
				
			if (updateNumber == 1) {
				new SimpleWindow( {
					label:SimpleWindow.ATTENTION,
					title:Locale.__e("flash:1429185188688"),
					text:Locale.__e('flash:1429185230673'),
					height:300,
					popup:true
				}).show();
				return;
			} else {
				settings.target.openConstructWindow();
			}
			close();
		}
		
		public var items:Array = [];
		override public function contentChange():void {
			for each(var _item:* in items) {
				bodyContainer.removeChild(_item);
				_item.dispose();
			}
			items = [];
			var X:int = 70;
			var Xs:int = X;
			var Ys:int = 30;
			
			var itemNum:int = 0;
			for (var i:int = paginator.startCount; i < paginator.finishCount; i++){
				var item:*
				item = new EventShopItem(this, settings.content[i]);
				bodyContainer.addChildAt(item, 1);
				item.x = Xs - 10;
				item.y = Ys;
				
				items.push(item);
				
				Xs += item.background.width + 20;
				
				if (itemNum == int(settings.itemsOnPage / 2) - 1)	{
					Xs = X;
					Ys += item.background.height + 15;
				}
				itemNum++;
			}
		}
		
		public function onChange(id:int, callback:Function = null):void {
			settings.target.onChange(id, function():void {
				if (callback != null) callback();
				
				contentChange();
				
				franksLabel.text = String(App.user.stock.count(currency));
			});
		}
		
		public function onExchange(bID:int):void {
			settings.onExchange(bID, 
				function():void {
					contentChange();	
					franksLabel.text = String(App.user.stock.count(currency));
				}
			);
		}
		
		
		// Rate
		public static var rateChecked:int = 0;
		public static var rateSended:Object = {};
		private var onUpdateRate:Function;
		private function getRate(callback:Function = null):void {
			//if (rateChecked > 0) return;
			
			onUpdateRate = callback;
			
			Post.send( {
				ctr:		'top',
				act:		'users',
				uID:		App.user.id,
				tID:		top
				//rate:		settings.target.info.type + '_' + String(settings.target.sid)
			}, function(error:int, data:Object, params:Object):void {
				if (error) return;
				
				rateChecked = App.time;
				
				if (data.hasOwnProperty('users')) {
					Exchange.rates = data['users'] || { };
					
					for (var id:* in Exchange.rates) {
						if (App.user.id == id) {
							Exchange.rate = Exchange.rates[id]['points'];
							isInTop = true;
						}
						
						Exchange.rates[id]['uID'] = id;
					}
				}
				
				if (App.user.top.hasOwnProperty(top)) {
					Exchange.rate = (Exchange.rate > App.user.top[top].count) ? Exchange.rate : App.user.top[top].count;
				}
				
				/*if (Exchange.rate > 50) 
					isInTop = true;*/
				
				if (Numbers.countProps(Exchange.rates) > topx) {
					var array:Array = [];
					for (var s:* in Exchange.rates) {
						array.push(Exchange.rates[s]);
					}
					array.sortOn('points', Array.NUMERIC | Array.DESCENDING);
					array = array.splice(0, topx);
					for (s in Exchange.rates) {
						if (array.indexOf(Exchange.rates[s]) < 0)
							delete Exchange.rates[s];
					}
				}
				
				//changeRate();
				
				//if (settings.target.expire < App.time)
					//drawScore();
				
				if (onUpdateRate != null) {
					onUpdateRate();
					onUpdateRate = null;
				}
				
			});
		}
		
		override public function dispose():void {
			ExchangeWindow.find = 0;
			super.dispose();
		}
	}

}

import buttons.Button;
import buttons.MoneyButton;
import core.Load;
import core.Size;
import core.TimeConverter;
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.text.TextField;
import ui.Cursor;
import ui.Hints;
import ui.UserInterface;
import units.Anime;
import units.Anime2;
import units.Field;
import units.Techno;
import units.Unit;
import wins.ExchangeWindow;
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
	public var multiLabel:TextField;
	public var priceBttn:Button;
	private var infoBttn:Button;
	public var window:*;
	
	public var moneyType:String = "coins";
	public var previewScale:Number = 1;
	
	private var preloader:Preloader = new Preloader();
	
	private var price:int = 0;
	
	public function EventShopItem(window:ExchangeWindow, item:Object)
	{
		this.item = item;
		this.window = window;
		
		price = item.price;
		
		var backing:String = 'itemBacking';
		
		background = Window.backing(160, 160, 10, backing);
		addChild(background);
		
		addChild(preloader);
		preloader.x = (background.width)/ 2;
		preloader.y = (background.height)/ 2 - 15;
		
		bitmap = new Bitmap();
		
		var info:Object = App.data.storage[item.sid];
		item.type = info.type;
		item.preview = info.preview;
		
		if (item.type == "Golden" || item.type == 'Thimbles' || item.type == 'Gamble') {
			Load.loading(Config.getSwf(item.type, item.preview), onAnimComplete);
		} else {
			Load.loading(Config.getIcon(item.type, item.preview), onImageLoad);
		}
		
		drawTitle();
		drawButton();
		
		var countOnMap:int = 0;
		var countUnits:Array;
		//App.user.storageStore('building_815', 0, true);
		if ([815,816,817,1353,1354,1355,1356,1357].indexOf(int(item.sid)) != -1) {
			var data:Object = App.user.storageRead('building_' + item.sid, 0);
			countUnits = Map.findUnits([int(item.sid)]);
			var cnt:int = countUnits.length;
			if (data == 0 && cnt > data) {
				data = cnt;
				App.user.storageStore('building_' + item.sid, data, true);
			}
			countOnMap = int(data);
			
			drawBoughtCount();
		}else {
			drawCount();
		}
		if (countOnMap >= 2) {
			priceBttn.visible = false;
			if (multiLabel) multiLabel.visible = false;
			drawBoughtText();
		}
		
		Load.loading(Config.getIcon(App.data.storage[window.currency].type , App.data.storage[window.currency].preview), onCurrencyLoad);
		
		//drawPrice();
		
		tip = function():Object {
			return {
				title:info.title,
				text:info.description
			};
		};
		
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
	
	private function drawBoughtText():void {
		boughtText = Window.drawText(Locale.__e("flash:1396612413334"), {
			color:0xfff2dd,
			borderColor:0x7a602f,
			borderSize:4,
			fontSize:24,
			autoSize:"center"
		});
		addChild(boughtText);
		boughtText.x = (background.width - boughtText.textWidth)/2;
		boughtText.y = background.height - boughtText.textHeight - 20;
		
		bitmap.alpha = 0.5;
	}
	
	private function drawBoughtCount():void {		
		var count:int = World.getBuildingCount(item.sid);
		if ([714, 738, 749, 815, 816, 817,1353,1354,1355,1356,1357].indexOf(int(item.sid)) != -1) {
			var data:Object = App.user.storageRead('building_' + item.sid, 0);
			var countUnits:Array = Map.findUnits([int(item.sid)]);
			if (int(data) >= countUnits.length + App.user.stock.count(item.sid))
				count = int(data);
			else 
				count = countUnits.length + App.user.stock.count(item.sid);
		}
		var txt:String = String(count) + "/" + 2;
			
		var counterLabel:TextField = Window.drawText(txt, {
			fontSize:24,
			color:0xffffff,
			borderColor:0x2D2D2D,
			autoSize:"left"
		});
		
		counterLabel.x = 120;
		counterLabel.y = 80;
		addChild(counterLabel);
	}
	
	private function onAnimComplete(swf:*):void 
	{
		removeChild(preloader);
		
		var anime:Anime = new Anime(swf, { w:background.width - 20, h:background.height - 40 } );
		anime.x = (background.width - anime.width) / 2;
		anime.y = (background.height - anime.height) / 2 - 10;
		addChildAt(anime,1);
	}
	
	private function onImageLoad(data:Bitmap):void {
		removeChild(preloader);
		
		bitmap.bitmapData = data.bitmapData;
		bitmap.smoothing = true;
		Size.size(bitmap, background.width * 0.85, background.height * 0.85);
		bitmap.x = background.x + background.width * 0.5 - bitmap.width * 0.5;
		bitmap.y = background.y + background.height * 0.5 - bitmap.height * 0.5 - 10;
		
		addChildAt(bitmap,1);
	}
	
	private function drawTitle():void {
		var text:String = '';
		if (App.data.storage[item.sid])
			text = App.data.storage[item.sid].title
		
		var title:TextField = Window.drawText(text, {
			color:       0x7c391f,
			borderColor: 0xf7f5e9,
			fontSize:	 23,
			shadowSize:  1,
			textAlign:	 'center',
			multiline:   true
		});
		title.wordWrap = true;
		title.width = background.width;
		title.height = title.textHeight + 4;
		title.y = 5;
		addChild(title);
	}
	
	public var money_sid:*;
	private function onCurrencyLoad(data:Bitmap):void {
		var frank:Bitmap = new Bitmap(data.bitmapData);
		Size.size(frank, 30,30);
		frank.x = 26;
		frank.y = 5;
		frank.smoothing = true;
		priceBttn.addChild(frank);
	}
	
	private var boughtText:TextField;
	private function drawButton():void {
		var bttnSettings:Object;
		if (window.settings.target.sid == 797) {
			bttnSettings = {
				caption:'',
				fontSize:27,
				width:116,
				height:42,
				hasDotes:false,
				bgColor:[0xa6edb5, 0x62be8b],
				bevelColor:[0xd5fef0,0x3c9672]
			};
		} else {
			bttnSettings = {
				caption:'',
				fontSize:27,
				width:116,
				height:42,
				hasDotes:false
			};
		}
			
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
		
		if (ExchangeWindow.find && ExchangeWindow.find == item.sid) {
			priceBttn.showGlowing();
			ExchangeWindow.find = 0;
		}
		
		var textSettings:Object = {
			color:      	0xffeb96,
			borderColor: 	0x414311,
			fontSize:		28,
			textAlign:		'left'
		}
		
		if (App.user.stock.count(window.currency) >= price) {
			textSettings["color"] = 0xffffff;
			textSettings["fontSize"] = 26;
		} else {
			textSettings["color"] = 0xffa883;				
			textSettings["fontSize"] = 26;
		}
		
		if (window.currency == Stock.ACTION)
			textSettings["borderColor"] = 0x0a4179;
		else 
			textSettings["borderColor"] = 0x813d0c;
		
		var franksLabel:TextField = Window.drawText(String(price), textSettings);
		franksLabel.x = 60;
		franksLabel.y = 7;
		priceBttn.addChild(franksLabel);
	}
	
	private function drawCount():void {
		multiLabel = Window.drawText('x' + String(item.count), {
			width:			background.width - 40,
			textAlign:		'right',
			fontSize:		26,
			color:			0x723d1b,
			borderColor:	0xfff8f3
		});
		multiLabel.x = background.x + background.width * 0.5 - multiLabel.width * 0.5;
		multiLabel.y = background.y + background.height - multiLabel.height - 30;
		addChild(multiLabel);
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
		
		if (!App.user.stock.check(window.currency, item.price, true)) {
			if (!App.isSocial('YB','MX','AI')) {
				window.onAddCurrency();
			}else {
				new SimpleWindow( {
					popup:true,
					text:Locale.__e('flash:1457690206563'),
					title:Locale.__e('flash:1382952379893')
				}).show();
			}
			return;
		}
		
		if (item.type == 'Building') {
			var unit:Unit = Unit.add( { sid:item.sid, buy:true, fromExchange:true } );
			
			unit.move = true;
			App.map.moved = unit;
			Window.closeAll();
			return;
		}
		
		priceBttn.state = Button.DISABLED;
		
		window.onChange(item.id, function():void {
			var reward:Object = { };
			reward[item.sid] = item.count;
			
			BonusItem.takeRewards(reward, priceBttn);
			Hints.minus(window.currency, item.price, new Point(320, 400), false, window.bodyContainer);
			
			if (App.user.stock.count(window.currency) >= item.price)
				priceBttn.state = Button.NORMAL;
			
			if ([714, 738, 749, 815, 816, 817,1353,1354,1355,1356,1357].indexOf(int(item.sid)) != -1) {
				var data:Object = App.user.storageRead('building_' + item.sid, 0);
				data += 1;
				App.user.storageStore('building_' + item.sid, data, true);
			}
		});
	}
	
	private function onBuyComplete(sID:uint, rez:Object = null):void 
	{
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
	
	public function dispose():void {
		priceBttn.removeEventListener(MouseEvent.CLICK, onBuyEvent);
	}
}

import buttons.Button;
import buttons.MoneyButton;
import buttons.MoneySmallButton;
import core.Load;
import core.Numbers;
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.text.TextField;
import ui.Hints;
import wins.Window;
import wins.BonusList;

internal class BarterItems extends Sprite {
	
	public var barter:Object = { };
	public var background:Bitmap;
	public var exchangeBttn:Button;
	public var arrow:Bitmap;
	public var window:*;
	public var items:Vector.<BarterItem> = new Vector.<BarterItem>();
	public var bonusList:BonusList;
	public var bID:int;
	public var item:Object;
	private var _modeChange:Boolean = true;
	
	private var sID:String;
	private var sID2:String;
	private var count:int;
	private var count2:int;
	
	public var two_to_one:Boolean = false;
	
	public function BarterItems(bID:int, window:*) {
		this.barter = barter;
		this.window = window;
		this.bID = bID;
		item = App.data.barter[bID];
		
		if (Numbers.countProps(item.out) == 2)
			two_to_one = true;
		
		for (sID in item.out) break;
		
		if (two_to_one) {
			sID = Numbers.getProp(item.out, 0).key;
			sID2 = Numbers.getProp(item.out, 1).key;
			
			count2 = item.out[sID2];
		}
		
		count = item.out[sID];
		
		background = Window.backing(660, 190, 40, 'shopBackingSmall1');
		//addChild(background);
		
		exchangeBttn = new Button({
			caption:Locale.__e("flash:1382952380010"),
			fontSize:24,
			width:130,
			hasDotes:false,
			height:44
		});
		exchangeBttn.x = 160;
		exchangeBttn.y = 70;
		addChild(exchangeBttn);
		exchangeBttn.addEventListener(MouseEvent.CLICK, onExchangeClick);
		
		arrow = new Bitmap(Window.textures.barterArrowYellow);
		createItems();
		arrow.x = 160;
		arrow.y = 20;
		addChild(arrow);
		
		if (two_to_one) {
			exchangeBttn.x = 297;
			arrow.x = 297;
			
			if (App.user.stock.check(int(sID), count, true) && App.user.stock.check(int(sID2), count2, true)) {
				modeChange = true;
			} else {
				modeChange = false;
			}
		} else {
			if (App.user.stock.check(int(sID), count)) {
				modeChange = true;
			} else {
				modeChange = false;
			}
		}
		
		var finded:Boolean = false;
		if (ExchangeWindow.find) {
			for (var cellID:* in item.items) {
				if ([ExchangeWindow.find].indexOf(int(cellID)) >= 0) {
					finded = true;
					exchangeBttn.showGlowing();
					ExchangeWindow.find = 0;
				}
			}
			
			if (!finded) {
				for (var ids:* in item.out) {
					if ([ExchangeWindow.find].indexOf(int(ids)) >= 0) {
						finded = true;
						exchangeBttn.showGlowing();
						ExchangeWindow.find = 0;
					}
				}
			}
		}
	}
	
	public function set modeChange(value:Boolean):void {
		_modeChange = value;
		if (value == true) {
			arrow.alpha = 1;
			exchangeBttn.state = Button.NORMAL;
			exchangeBttn.mode = Button.NORMAL;
		} else {
			arrow.alpha = 0.5;
			exchangeBttn.state = Button.DISABLED;
			exchangeBttn.mode = Button.DISABLED;
		}
	}

	public function dispose():void {
		for each(var item:BarterItem in items) {
			item.dispose();
		}
	}
	
	public var cont:Sprite;
	public var cont2:Sprite;
	public function createItems():void {
		var i:int = 0;
		var icnt:int = 0;
		var bg:Bitmap;
		var barterItem:BarterItem;
		if (two_to_one) {
			cont = new Sprite();
			cont.x = 5;
			bg = Window.backing(285, 128, 10, "itemBacking");
			cont.addChild(bg);
			addChild(cont);
			
			var mark:Bitmap;
			mark = new Bitmap(Window.textures.plus);
			mark.x = 130;
			mark.y = 40;
			addChild(mark);
			
			i = 0;
			barterItem = new BarterItem({sID:int(sID), count:count}, this, BarterItem.IN, true);
			items.push(barterItem);
			barterItem.x = 140 * i + 20;
			barterItem.y = 0;
			i++;
			addChild(barterItem);
			barterItem.check();
			barterItem.modeChanges();
			
			barterItem = new BarterItem({sID:int(sID2), count:count2}, this, BarterItem.IN, true);
			items.push(barterItem);
			barterItem.x = 140 * i + 20;
			barterItem.y = 0;
			i++;
			addChild(barterItem);
			barterItem.check();
			barterItem.modeChanges();
			
			
			cont2 = new Sprite();
			cont2.x = 435;
			bg = Window.backing(120, 128, 10, "itemBacking");
			cont2.addChild(bg);
			
			i = 0;
			icnt = 0;
			for (var _sID:* in item.items) {
				barterItem = new BarterItem({sID:_sID, count:item.items[_sID]}, this, BarterItem.OUT);
				items.push(barterItem);
				barterItem.x = 140 * i;
				barterItem.y = 0;
				i++;
				icnt++;
				cont2.addChild(barterItem);
				barterItem.check();
				barterItem.modeChanges();
			}
			addChild(cont2);
			////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		} else {
			i = 0;
			barterItem = new BarterItem({sID:int(sID), count:count}, this, BarterItem.IN);
			items.push(barterItem);
			barterItem.x = 140 * i;
			barterItem.y = 0;
			i++;
			addChild(barterItem);
			barterItem.check();
			barterItem.modeChanges();
			
			cont = new Sprite();
			cont.x = 300;
			bg = Window.backing(300, 128, 10, "itemBacking");
			cont.addChild(bg);
			
			i = 0;
			icnt = 0;
			for (var __sID:* in item.items) {
				barterItem = new BarterItem({sID:__sID, count:item.items[__sID]}, this, BarterItem.OUT);
				items.push(barterItem);
				barterItem.x = 140 * i;
				barterItem.y = 0;
				i++;
				icnt++;
				cont.addChild(barterItem);
				barterItem.check();
				barterItem.modeChanges();
			}
			addChild(cont);
			if (icnt == 1) {
				barterItem.x += (bg.width - barterItem.width) / 2;
			}
		}
	}
	
	private function onExchangeClick(e:MouseEvent):void {
		if (exchangeBttn.mode == Button.DISABLED)
			return;
		
		exchangeBttn.state = Button.DISABLED;
		window.onExchange(bID);
		
		for each(var _item:BarterItem in items) {
			_item.cash();
		}
		
		window.drawBarterItem();
	}
}


internal class BarterItem extends LayerX {
	
	public static const IN:int = 0;
	public static const OUT:int = 1;
	
	public var background:Bitmap;
	public var bitmap:Bitmap;
	public var title:TextField;
	public var material:Object;
	public var sID:int;
	public var buyBttn:MoneySmallButton;
	public var countOnStock:TextField;
	public var window:*;
	
	private var mode:int;
	private var preloader:Preloader = new Preloader();
	private var count:int;
	private var colorCount:int;
	private var findBttn:Button;
	private var tio:Boolean;
	
	public function BarterItem(itm:Object, window:*, mode:int = IN, tio:Boolean = false) {
		this.sID = itm.sID;
		this.count = itm.count;
		this.window = window;
		this.mode = mode;
		this.tio = tio;
		
		background = Window.backing(120, 128, 10, "itemBacking");
		
		if(mode == IN && tio == false)
			addChild(background);
		
		bitmap = new Bitmap(null, "auto", true);
		addChild(bitmap);
		
		material = App.data.storage[sID];
		
		title = Window.drawText(material.title, {
			color:0x814f31,
			borderColor:0xfaf9ec,
			fontSize:20,
			multiline:true,
			textAlign:"center",
			wrap:true,
			width:background.width - 20
		});
		title.x = 10;
		title.y = 10;
		addChild(title);
		
		if(mode == IN)
			drawButtons();
		
		addChild(preloader);
		preloader.x = (background.width) / 2;
		preloader.y = (background.height) / 2;
		
		Load.loading(Config.getIcon(material.type, material.view), onLoad);
		drawCount();
		
		function shuffle(a:*,b:*):int {
			var num : int = Math.round(Math.random() * 2) - 1;
			return num;
		}
		
		tip = function():Object {
			return{
				title:material.title,
				text:material.description
			}
		}
	}
	
	
	private var price:int;
	private var neededCount:int;
	private function drawButtons():void {
		var bttnSettings:Object = {
			caption     :Locale.__e("flash:1382952379751"),
			width		:100,
			height		:38,	
			fontSize	:24,
			scale		:0.8,
			hasDotes    :false
		}
		
		neededCount = count - App.user.stock.count(sID);
		if (App.data.storage[sID].hasOwnProperty('price'))
			price = neededCount * App.data.storage[sID].price[Stock.FANT];
		else 
			price = 0;
		
		bttnSettings['type'] = 'real';
		bttnSettings['countText'] = price;
		bttnSettings["bgColor"] = [0xa9f84a, 0x73bb16];
		bttnSettings["borderColor"] = [0xffffff, 0xffffff];
		bttnSettings["bevelColor"] = [0xc5fe78, 0x405c1a];
		bttnSettings["fontColor"] = 0xffffff;				
		bttnSettings["fontBorderColor"] = 0x354321;
		bttnSettings['greenDotes'] = false;
		
		findBttn = new Button(bttnSettings);
		buyBttn = new MoneySmallButton(bttnSettings);
		buyBttn.tip = function():Object { 
			return {
				title:Locale.__e("flash:1382952379751")/*,
				text:Locale.__e("flash:1410432789818")*/
			};
		};
		buyBttn.coinsIcon.y -= 6;
		
		buyBttn.addEventListener(MouseEvent.CLICK, onBuyAction);
		addChild(buyBttn);
		addChild(findBttn);
		
		if (App.user.stock.check(sID, count, true) || App.isSocial('YB','MX')) {
			buyBttn.visible = false;
		}
	}
	
	private function onFindAction(e:MouseEvent):void {
		window.settings.target.work(sID);
		window.close();
	}
	
	private function onBuyAction(e:MouseEvent):void {
		if (e.currentTarget.mode == Button.DISABLED) return;
		
		if (!App.user.stock.check(Stock.FANT, price))
			return;
		
		if (!countOnStock)
			drawCount(true);
		
		App.user.stock.buy(sID, neededCount, function():void {
			
			var item:BonusItem = new BonusItem(sID, 1);
			var point:Point = Window.localToGlobal(buyBttn);
			item.cashMove(point, App.self.windowContainer);
		  
			Hints.plus(sID, neededCount, point, true, App.self.tipsContainer);
			Hints.minus(Stock.FANT, price, point, false, App.self.tipsContainer);	
			
			window.window.drawBarterItem();
		});
	}
	
	public function cash():void
	{
		if (mode == IN) return;
		
		var item:BonusItem = new BonusItem(sID, count);
		var point:Point = Window.localToGlobal(bitmap);
		item.cashMove(point, App.self.windowContainer);
		Hints.plus(sID, count, point, true, App.self.tipsContainer);
	}
	
	public var searchBttn:MoneyButton
	public function modeChanges():void {
		if (mode == OUT) {
			//не отображать кнопки
			if(buyBttn) buyBttn.visible = false;
		}
	}
	
	private function onLoad(data:Bitmap):void {
		removeChild(preloader);
		bitmap.bitmapData = data.bitmapData;
		bitmap.smoothing = true;
		bitmap.scaleX = bitmap.scaleY = 0.9;
		bitmap.x = (background.width - bitmap.width) / 2;
		bitmap.y = (background.height - bitmap.height) / 2;
	}
	
	public function drawCount(ignore:Boolean = false):void {
		if (count == 0 && !ignore)
			colorCount = 0xff816e;
		
		var counterSprite:LayerX = new LayerX();
		counterSprite.tip = function():Object { 
			return {
				title:"",
				text:Locale.__e("flash:1382952380305")
			};
		};
		
		var tSett:Object = textSettings[mode];
		if(mode == IN) {
			if (!App.user.stock.check(sID, count, true)) {
				tSett.color = 0xff816e;
			} else {
				tSett.color = 0xade63f;
			}
		} else {
			tSett.color = 0x70ffff;
			tSett.borderColor = 0x0a4476;
		}
		
		countOnStock = Window.drawText('x' + count, tSett);
		
		if (mode == IN && tio) {
			tSett.fontSize = 34;
			countOnStock = Window.drawText(App.user.stock.count(sID) + '/' + count, tSett);
		}
		
		counterSprite.x = background.width - counterSprite.width - 30;
		counterSprite.y = 130;
		addChild(counterSprite);
		
		countOnStock.x = counterSprite.x + (counterSprite.width - countOnStock.width) / 2 - 5;
		countOnStock.y = counterSprite.y - 56;
		addChild(countOnStock);
	}
	
	private var textSettings:Object = {
		0:{
			color:0xade63f,
			borderColor:0x41332b,
			fontSize:42,
			autoSize:"left",
			shadowColor:0x41332b,
			shadowSize:1
		},
		1: {
			color:0xFFFFFF,
			borderColor:0x41332b,
			fontSize:42,
			autoSize:"left",
			shadowColor:0x41332b,
			shadowSize:1
		}
	}
	
	public function check():void {
		if(countOnStock) {
			'x' + String(count);
		} else if(countOnStock) {
			countOnStock.text = 'x' + String(count);
		}
		if (buyBttn != null) {
			buyBttn.x = (background.width - buyBttn.width) / 2;
			buyBttn.y = background.height - buyBttn.height + 17;
		}
	}
	
	public function dispose():void {
		//
	}
}