package wins 
{
	import buttons.Button;
	import buttons.MoneyButton;
	import core.Load;
	import core.Post;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import ui.Hints;
	import units.Fatman;
	
	public class SingleBarterWindow extends Window 
	{
		public static const WAIT:String = 'wait';
		public static const GONE:String = 'gone';
		public static const EAT:String = 'eat';
		
		public var exchangeBttn:Button;
		public var boostBttn:Button;
		public var arrow:Bitmap;
		public var progressBar:ProgressBar;
		public var progressBacking:Bitmap;
		public var image:Bitmap;
		
		private var _modeChange:Boolean = true;
		public var items:Array;
		public var item:Object;
		
		public var target:Fatman;
		public var mode:String;
		public var totalTime:int = 0;
		public var food:Object;
		public var canFeed:Boolean = false;
		
		public function SingleBarterWindow(settings:Object=null) 
		{
			if (settings == null) {
				settings = new Object();
			}
			
			settings['width'] = 610;
			settings['height'] = 470;
			settings['shadowSize'] = 3;
			settings['shadowBorderColor'] = 0x554234;
			settings['shadowColor'] = 0x554234;
			
			settings['title'] = settings['target'].info.title;
			settings['hasPaginator'] = false;
			target = settings['target'];
			
			super(settings);
			
			totalTime = settings.totalTime;
			mode = settings['state'];
			food = settings['food'];	
		}
		
		override public function drawBackground():void {
			background = backing2(settings.width, settings.height, 100, 'stockBackingTopWithoutSlate', 'stockBackingBot');
			layer.addChild(background);
		}
		
		override public function drawBody():void {
			titleLabel.y += 37;
			exit.y += 25;
			
			var desc:TextField = drawText(target.info.description, {
				color:0xFFFFFF,
				borderColor:0x874c2a,
				fontSize:26,
				autoSize:"center",
				shadowColor:0x41332b,
				shadowSize:1,
				multiline:true,
				wrap:true,
				width:settings.width - 100,
				textAlign:'center'
			});
			desc.x = 50;
			desc.y = 65;
			bodyContainer.addChild(desc);
			
			exchangeBttn = new Button( {
				caption:Locale.__e("flash:1382952380010"),
				fontSize:24,
				width:130,
				hasDotes:false,
				height:44
			});
			exchangeBttn.x = (settings.width - exchangeBttn.width) / 2;
			exchangeBttn.y = (settings.height - exchangeBttn.height) / 2;
			bodyContainer.addChild(exchangeBttn);
			exchangeBttn.addEventListener(MouseEvent.CLICK, onExchangeClick);
			
			if (ProductionWindow.find == target.sid) {
				exchangeBttn.startGlowing();
				ProductionWindow.find = 0;
			}
			
			arrow = new Bitmap(Window.textures.barterArrowYellow);
			arrow.x = (settings.width - arrow.width) / 2;
			arrow.y = exchangeBttn.y - arrow.height - 20;
			bodyContainer.addChild(arrow);
			
			boostBttn = new MoneyButton( {
				width:			150,
				height:			44,
				countText:		App.data.storage[target.sid].skip,		// Fants
				caption:		Locale.__e('flash:1382952380021')
			});
			boostBttn.x = (settings.width - boostBttn.width) / 2;
			boostBttn.y = 304;
			bodyContainer.addChild(boostBttn);
			boostBttn.addEventListener(MouseEvent.CLICK, onBoost);
			
			if (mode == SingleBarterWindow.WAIT) {
				exchangeBttn.visible = true;
				arrow.visible = true;
				boostBttn.visible = false;
				
				createItems();
			} else if (mode == SingleBarterWindow.GONE) {
				exchangeBttn.visible = false;
				arrow.visible = false;
				boostBttn.visible = true;
				
				desc.text = Locale.__e('flash:1438243154595');
				progressBacking = Window.backingShort(290, "progBarBacking");
				progressBacking.x = (settings.width - 290) / 2;
				progressBacking.y = 260;
				bodyContainer.addChild(progressBacking);
			
				progressBar = new ProgressBar( { win:this, width:290 + 16 } );
				progressBar.x = (settings.width - progressBar.width) / 2;
				progressBar.y = 260 - 3;
				bodyContainer.addChild(progressBar);
				progressBar.start();
				
				Load.loading(Config.getImage('promo/images',target.info.view), function(data:Bitmap):void {
					image.bitmapData = data.bitmapData;
					image.scaleX = image.scaleY = 0.5;
					image.smoothing = true;
					image.x = (settings.width - image.width) / 2;
					image.y = (settings.height - image.height) / 2;
				})
				
				update();
			}
			
			if (totalTime == 0) {
				if (progressBar) progressBar.visible = false;
				if (progressBacking) progressBacking.visible = false;
				//if (desc) desc.visible = false;
				//if (infoLabel)infoLabel.y = 75 - infoLabel.height * 0.5;
			}
			
			App.self.setOnTimer(update);
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
		
		public var cont:Sprite;
		public function createItems():void {
			if (items) {
				for each(var _item:* in items) {
					_item.dispose();
				}
			}
			items = [];
			if (cont) {
				bodyContainer.removeChild(cont);
			}
			
			var requires:Object = food.need;
			
			var i:int = 0;
			for (var s:String in requires) {
				var barterItem:BarterItem = new BarterItem({sID:int(s),count:requires[s]}, this, BarterItem.IN);
				items.push(barterItem);
				barterItem.x = 70;
				barterItem.y = 135;
				i++;
				bodyContainer.addChild(barterItem);
				barterItem.check();
				barterItem.modeChanges();
					
				cont = new Sprite();
				cont.x = 378;
				var bg:Bitmap = Window.backing(161, 185, 10, "itemBacking");
				cont.addChild(bg);
				bg.y = 135;
				
				if (App.user.stock.check(uint(s), requires[s], true)) {
					modeChange = true;
				} else {
					modeChange = false;
				}
			}
			
			i = 0;
			var icnt:int = 0;
			for (var _sID:* in App.data.storage[food.sID].reward) {
				var info:Object = App.data.storage[s];
				
				barterItem = new BarterItem({sID:_sID,count:App.data.storage[food.sID].reward[_sID]}, this, BarterItem.OUT);
				items.push(barterItem);
				barterItem.x = 140 * i;
				barterItem.y = 135;
				i++;
				icnt++;
				cont.addChild(barterItem);
				barterItem.check();
				barterItem.modeChanges();
			}
			bodyContainer.addChild(cont);
			if (icnt == 1) {
				barterItem.x += (bg.width - barterItem.width) / 2;
			}
		}
		
		public function onBoost(e:MouseEvent):void {
			if (e.currentTarget.mode == Button.DISABLED) return;
			boostBttn.state = Button.DISABLED;
			
			var that:* = this;
			
			Post.send( {
				id:		target.id,
				uID:	App.user.id,
				sID:	target.sid,
				wID:	App.user.worldID,
				act:	'boost',
				ctr:	'Fatman'
			}, function(error:int, data:Object, params:Object):void {
				boostBttn.state = Button.NORMAL;
				if (error) return;
				
				Hints.minus(Stock.FANT, App.data.storage[target.sid].skip, Window.localToGlobal(boostBttn), false, that);
				
				App.user.stock.take(Stock.FANT, App.data.storage[target.sid].skip);
				target.serverTime = App.time;
				target.parseData(data);
				target.init();
				
				close();
			});
		}
		
		public function onExchangeClick(e:MouseEvent):void {
			if (e.currentTarget.mode == Button.DISABLED) return;
			exchangeBttn.state = Button.DISABLED;
			
			Post.send( {
				id:		target.id,
				uID:	App.user.id,
				sID:	target.sid,
				wID:	App.user.worldID,
				act:	'storage',
				ctr:	'Fatman'
			}, function(error:int, data:Object, params:Object):void {
				exchangeBttn.state = Button.NORMAL;
				
				if (error) {
					if (error == 79) {
						target.updateData();
						close();
					}
					
					return;
				}
				
				App.user.stock.takeAll(App.data.storage[food.sID].require);
				
				var rewards:Object = { };
				for (var s:String in App.data.storage[food.sID].reward) {
					rewards[s] = App.data.storage[food.sID].reward[s] + food.margin;
				}
				App.user.stock.addAll(rewards);
				
				take(rewards, exchangeBttn);
				
				if (totalTime <= 0) {
					target.updateData(true);
				}else{
					target.serverTime = App.time - totalTime;
					target.init(SingleBarterWindow.EAT, true);
				}
				
				close();
			});
		}
		
		private function take(items:Object, target:*):void {
			for(var i:String in items) {
				var item:BonusItem = new BonusItem(uint(i), items[i]);
				var point:Point = Window.localToGlobal(target);
				item.cashMove(point, App.self.windowContainer);
			}
		}
		
		public function get timer():int {
			var time:int = target.timeTo - App.time;
			if (time < 0) time = 0;
			return time;
		}
		
		public function update():void {
			if (mode == SingleBarterWindow.WAIT) {
				//timeLabel.text = TimeConverter.timeToStr(timer);
			}else if (mode == SingleBarterWindow.GONE) {
				progressBar.time = timer;
				progressBar.progress = (totalTime - timer) / totalTime;
			}
		}
		
		override public function dispose():void {
			super.dispose();
			if (boostBttn) boostBttn.removeEventListener(MouseEvent.CLICK, onBoost);
			if (exchangeBttn) exchangeBttn.removeEventListener(MouseEvent.CLICK, onExchangeClick);
			App.self.setOffTimer(update);
		}
		
	}

}
import buttons.Button;
import buttons.ImageButton;
import buttons.MoneyButton;
import buttons.MoneySmallButton;
import core.Load;
import flash.display.Bitmap;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.text.TextField;
import ui.Hints;
import ui.UserInterface;
import wins.ShopWindow;
import wins.Window;

internal class BarterItem extends LayerX {
	
	public static const IN:int = 0;
	public static const OUT:int = 1;
	
	public var background:Bitmap;
	public var bitmap:Bitmap;
	public var title:TextField;
	public var material:Object;
	public var sID:int;
	public var buyBttn:MoneyButton;
	public var srchBttn:Button;
	public var wishBttn:ImageButton;
	public var countOnStock:TextField;
	public var window:*;
	
	private var mode:int;
	private var preloader:Preloader = new Preloader();
	private var count:int;
	private var colorCount:int;
	private var findBttn:Button;
	
	public function BarterItem(itm:Object, window:*, mode:int = IN) {
		this.sID = itm.sID;
		this.count = itm.count;
		this.window = window;
		this.mode = mode;
		
		background = Window.backing(161, 185, 10, "itemBacking");
		
		if(mode == IN)
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
			width		:120,
			height		:40,	
			fontSize	:20,
			scale		:0.8,
			hasDotes    :false
		}
		
		neededCount = count - App.user.stock.count(sID);
		price = neededCount * App.data.storage[sID].price[Stock.FANT];
		
		bttnSettings['type'] = 'real';
		bttnSettings['countText'] = price;
		bttnSettings["bgColor"] = [0xa9f84a, 0x73bb16];
		bttnSettings["borderColor"] = [0xffffff, 0xffffff];
		bttnSettings["bevelColor"] = [0xc5fe78, 0x405c1a];
		bttnSettings["fontColor"] = 0xffffff;				
		bttnSettings['greenDotes'] = false;
		
		buyBttn = new MoneyButton(bttnSettings);
		buyBttn.tip = function():Object { 
			return {
				title:Locale.__e("flash:1382952379751")
			};
		};
		buyBttn.addEventListener(MouseEvent.CLICK, onBuyAction);
		addChild(buyBttn);
		
		srchBttn = new Button({
			caption			:Locale.__e("flash:1405687705056"),
			fontSize		:18,
			radius      	:10,
			fontColor:		0xffffff,
			fontBorderColor:0x475465,
			borderColor:	[0xfff17f, 0xbf8122],
			bgColor:		[0x75c5f6,0x62b0e1],
			bevelColor:		[0xc6edfe,0x2470ac],
			width			:90,
			height			:28,
			fontSize		:15
		});
		
		srchBttn.addEventListener(MouseEvent.CLICK, onFindAction);
		addChild(srchBttn);
		
		wishBttn = new ImageButton(UserInterface.textures.addBttnYellow);
		wishBttn.scaleX = 0.9;
		wishBttn.scaleY = 0.9;
		
		addChild(wishBttn);
		wishBttn.addEventListener(MouseEvent.CLICK, onWishlistEvent);
		wishBttn.tip = function():Object { 
			return {
				title:"",
				text:Locale.__e("flash:1382952380013")
			};
		};
	
		if (App.user.stock.check(sID, count, true)) {
			buyBttn.visible = false;
			srchBttn.visible = false;
			wishBttn.visible = false;
		}
	}
	
	private function onFindAction(e:MouseEvent):void {
		window.close();
		ShopWindow.findMaterialSource(sID);
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
			
			window.createItems();
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
	
	public var searchBttn:MoneyButton;
	public function modeChanges():void {
		if (mode == OUT) {
			//не отображать кнопки
			if(buyBttn) buyBttn.visible = false;
			if(srchBttn) srchBttn.visible = false;
			if(wishBttn) wishBttn.visible = false;
		}
	}
	
	private function onSearchBttn(e:MouseEvent):void {
		window.close();
		if (window.settings.onSearch != null) 
			window.settings.onSearch(window.mode, sID);
	}
	
	private function onLoad(data:Bitmap):void {
		removeChild(preloader);
		bitmap.bitmapData = data.bitmapData;
		bitmap.smoothing = true;
		bitmap.scaleX = bitmap.scaleY = 1;
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
		if(mode == IN){
			if (!App.user.stock.check(sID, count,true)) {
				tSett.color = 0xe98d74;
				tSett.borderColor = 0x7f3023;
			} else {
				tSett.color = 0xfed933;
				tSett.borderColor = 0x6b4a14;
			}
			countOnStock = Window.drawText(App.user.stock.count(sID) + '/' + String(count), tSett);
		} else {
			countOnStock = Window.drawText('x' + count, tSett);
		}
		
		counterSprite.x = background.width - counterSprite.width - 20;
		counterSprite.y = 185;
		addChild(counterSprite);
		
		addChild(countOnStock);
		if(mode == IN){
			countOnStock.x = (background.width - countOnStock.width) / 2;
			if (!App.user.stock.check(sID, count, true)) {
				countOnStock.y = counterSprite.y - 75;
			} else {
				countOnStock.y = counterSprite.y - 50;
			}
		} else {
			countOnStock.x = counterSprite.x + (counterSprite.width - countOnStock.width) / 2 - 20;
			countOnStock.y = counterSprite.y - 60;
		}
	}
	
	private var textSettings:Object = {
		0:{
			color:0xffdb2f,
			borderColor:0x6c4d14,
			fontSize:32,
			autoSize:"right",
			shadowColor:0x41332b,
			shadowSize:1
		},
		1: {
			color:0xFFFFFF,
			borderColor:0x41332b,
			fontSize:42,
			autoSize:"right",
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
			buyBttn.y = background.height - buyBttn.height + 32;
		}
		if (srchBttn != null) {
			srchBttn.x = (background.width - srchBttn.width) / 2;
			srchBttn.y = buyBttn.y - srchBttn.height + 4;
		}
		if (wishBttn) {
			wishBttn.x = -10;
			wishBttn.y = 30;
		}
	}
	
	private function onWishlistEvent(e:MouseEvent):void {
		App.wl.show(sID, e);
	}
	
	public function dispose():void {
		if (buyBttn) buyBttn.removeEventListener(MouseEvent.CLICK, onBuyAction);
		if (srchBttn) srchBttn.removeEventListener(MouseEvent.CLICK, onFindAction);
		if (wishBttn) wishBttn.removeEventListener(MouseEvent.CLICK, onWishlistEvent);
		
		for (var i:int = 0; i < numChildren; i ++) {
			this.removeChildAt(i);
		}
		
		if (this.parent != null) {
			this.parent.removeChild(this);
		}
	}
}