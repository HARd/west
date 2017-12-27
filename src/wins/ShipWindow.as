package wins 
{
	import buttons.Button;
	import buttons.ImageButton;
	import buttons.ImagesButton;
	import buttons.UpgradeButton;
	import core.Load;
	import core.Numbers;
	import core.Post;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.text.TextField;
	import units.Guide;
	//import units.Port;
	
	public class ShipWindow extends Window 
	{
		public static var shipID:int = 2092;
		
		public var hold:StockList;		// Трюм
		public var stock:StockList;		// Склад
		private var upgradeBttn:Button;
		private var moveAllBttn:Button;
		public var infoBttn:ImageButton;
		public var upArrowIcon:Bitmap;
		private var holdDescLabel:TextField;
		private var preloader:Preloader = new Preloader();
		
		public var block:Boolean = false;
		
		public function ShipWindow(settings:Object=null) 
		{
			if (!settings) settings = { };
			settings['width'] = settings['width'] || 820;
			settings['height'] = settings['height'] || 550;
			settings['hasTitle'] = false;
			settings['hasPaginator'] = false;
			
			super(settings);
		}
		
		override public function drawBackground():void {
			//
		}
		
		override public function drawBody():void {
			exit.x -= 6;
			exit.y -= 10;			
			hold = new StockList( {
				title:		Locale.__e('flash:1408027518943'),
				window:		this,
				content:	getHold(),
				backing:	'rouletteBackingTop',
				backingBottom:	'rouletteBackingBot',
				titleDecor:	true,
				upDecor:	false,
				type:		ShipTransferWindow.TO_STOCK
			});
			bodyContainer.addChild(hold);			
			//hold.paginator.y -= 15;
			
			holdDescLabel = drawText(Locale.__e('flash:1464959253220'), {
				fontSize:		27,
				color:			0xffffff,
				borderColor:	0x885631,
				textAlign:		'center',
				autoSize:		'center',
				multiline:		true
			});
			holdDescLabel.wordWrap = true;
			holdDescLabel.width = hold.width - 80;
			holdDescLabel.x = hold.x + (hold.width - holdDescLabel.width) / 2;
			holdDescLabel.y = hold.y + (hold.height - holdDescLabel.height) / 2;
			bodyContainer.addChild(holdDescLabel);
			
			stock = new StockList( {
				title:		Locale.__e('flash:1382952379767'),
				window:		this,
				content:	getStock(),
				backing:	'shopBackingTop',
				backingBottom:	'shopBackingBot',
				titleDecor:	true,
				upDecor:	false,
				roofTile:	'tentRoof',
				type:		ShipTransferWindow.FROM_STOCK
			} );
			stock.x = 420;
			bodyContainer.addChild(stock);
			
			var arrows:Sprite = new Sprite();
			var arrowUp:Bitmap = new Bitmap(Window.textures.travBalanceArrow, 'auto', true);
			arrowUp.alpha = 0.9;
			arrowUp.rotation = 15;
			arrows.addChild(arrowUp);
			arrows.x = (settings.width - arrows.width) / 2 + 25;
			arrows.y = (settings.height - arrows.height) / 2 + 25;
			bodyContainer.addChild(arrows);
			
			moveAllBttn = new Button( {
				caption:		Locale.__e('flash:1464959396234'),
				width:			120,
				height:			36,
				fontSize:		21,
				radius:			12
			});
			moveAllBttn.x = hold.x + moveAllBttn.width + 20;
			moveAllBttn.y = hold.y + hold.height - 100;
			bodyContainer.addChild(moveAllBttn);
			moveAllBttn.addEventListener(MouseEvent.CLICK, onMoveAll);
			
			//Кнопка "Улучшить рюкзак"			
			upgradeBttn = new Button({  
				caption: Locale.__e("flash:1393580216438"),
				width:(App.lang == 'jp') ? 130 : 100,
				height:36,
				textAlign: "center",
				fontBorderColor:0x002932,
				fontSize:21,
				color: 0xcaebfc,
				bgColor : [0x97c9fe, 0x5e8ef4],
				borderColor : [0xffdad3, 0xc25c62],
				bevelColor : [0xb3dcfc, 0x376dda],
				fontColor : 0xffffff
			});
				
			upgradeBttn.addEventListener(MouseEvent.CLICK, upgradeAction);
			//upgradeBttn.state = Button.DISABLED;
			
			if (App.lang == 'jp') {
				upgradeBttn.x = (hold.x + upgradeBttn.width / 2) - 35;
			} else {
				upgradeBttn.x = hold.x + upgradeBttn.width / 2; 
			}
			
			upgradeBttn.y = hold.y + upgradeBttn.height * 2 - 20;
			//upgradeBttn.textLabel.x = hold.x + 26;			
			bodyContainer.addChild(upgradeBttn);	
			
			updateStocks();
			createInfoIcon();
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
			
			infoBttn.x = 490;
			infoBttn.y = 50;
			
			bodyContainer.addChild(infoBttn);	
		}
		
		private function onInfo(e:Event = null):void 
		{
			new InfoWindow( {qID:'ship'} ).show();
		}
		
		public function upgradeAction(e:MouseEvent):void 
		{
			if (e.currentTarget.mode == Button.DISABLED) return;
			upgradeShip(updateStocks);
		}
		
		private var upgradeCallback:Function;
		public function upgradeShip(callback:Function = null):void {
			upgradeCallback = callback;
			
			var target:Object = { sid:shipID, level:App.user.ministock.level , viewID:id, totalLevels:Numbers.countProps(App.data.storage[shipID].devel.obj), info: App.data.storage[shipID]};
			
			new ConstructWindow( {
				title:			App.data.storage[shipID].title,
				upgTime:		0,
				request:		target.info.devel.obj[App.user.ministock.level + 1],
				target:			target,
				useRequires:	true,
				win:			null,
				onUpgrade:		actionShipUpgrade,
				height:	420,
				hasDescription:	true,
				bttnTxt:		'flash:1382952379890',
				noSkip:			true
			}).show();
		}
		
		public function actionShipUpgrade(require:Object):void 
		{
			if (!App.user.stock.checkAll(require)) return;
			App.user.stock.takeAll(require);
			
			Post.send( {
				ctr:	'user',
				act:	'ship',
				sID:	shipID,
				uID:	App.user.id,
				wID:    App.user.worldID
			}, onShipUpgrade);
		}
		
		private function onShipUpgrade(error:int, data:Object, params:Object):void
		{
			if (error) return;
			
			App.user.ministock.level++;
			
			if (settings.target && (settings.target is Guide)) {
				settings.target.updateLevel();
			}
			
			if (upgradeCallback != null)
			{
				upgradeCallback();
				upgradeCallback = null;
			}
		}
		
		private function onMoveAll(e:MouseEvent = null):void {
			//if (mainStockFull()) return;
			
			moveAll();
		}
		private function moveAll():void {
			if (Numbers.countProps(App.user.ministock.items) > 0) {
				var list:Array = [];
				for (var s:* in App.user.ministock.items) {
					if (App.user.ministock.items[s] == 0) continue;
					list.push( { sid:int(s), count:App.user.ministock.items[s], order:App.data.storage[s].order } );
				}
				
				list.sortOn('order', Array.NUMERIC);
				
				var items:Object = { };
				var volume:int = 0;
				for (var i:int = 0; i < list.length; i++) {
					//if (Stock._limit - Stock._value - volume > 0) {
						var count:int = list[i].count;
						//count = Stock._limit - Stock._value - volume;
						//
						//volume += count;
						items[list[i].sid] = count;
					//}else {
						//break;
					//}
				}
				
				unloadHold(items);
			}
		}
		
		override public function drawFader():void {
			super.drawFader();
			this.y -= 40;
			fader.y += 40;
		}
		
		private function getHold():Array {
			var list:Array = [];
			
			if (App.user.ministock && App.user.ministock['items']) {
				for (var s:* in App.user.ministock.items) {
					if (App.user.ministock.items[s] == 0) continue;
					
					list.push( { sid:int(s), count:App.user.ministock.items[s], order:App.data.storage[s].order } );
				}
			}
			
			return list;
		}
		
		private function getStock():Array {
			var list:Array = [];
			
			for (var s:* in App.user.stock.data) {
				if (App.user.stock.data[s] == 0) continue; 
				
				switch(App.data.storage[s].type) {
					case 'Material':
						if (!User.inExpedition && App.data.storage[s].mtype == 4) continue;
						if (App.data.storage[s].mtype != 3) {
							list.push({sid:int(s), count:App.user.stock.data[s], order:App.data.storage[s].order});
						}
						break;
					case 'Firework':
					case 'Decor':
					case 'Golden':
					case 'Box':
					case 'Booker':
						list.push( { sid:int(s), count:App.user.stock.data[s], order:App.data.storage[s].order } );
						break;
				}
				
			}
			list.sortOn('order', Array.NUMERIC);
			return list;
		}
		
		public function loadHold(items:Object = null):void {
			if (Numbers.countProps(items) > 0 && App.user.stock.checkAll(items)) {
				block = true;
				
				Post.send( {
					ctr:		'user',
					act:		'load',
					uID:		App.user.id,
					wID:		App.map.id,
					items:		JSON.stringify(items)
				}, function (error:int, data:Object, params:Object):void {
					block = false;
					
					if (error) return;
					
					for (var s:* in items) {
						if (!App.user.ministock) App.user.ministock = { };
						if (!App.user.ministock['items']) App.user.ministock['items'] = { };
						if (!App.user.ministock.items.hasOwnProperty(s)) App.user.ministock.items[s] = 0;
						App.user.ministock.items[s] += items[s];
					}
					App.user.stock.takeAll(items);
					
					hold.data = getHold();
					stock.data = getStock();
					hold.contentChange();
					stock.contentChange();
					
					updateStocks();
				});
			}
		}
		
		public function unloadHold(items:Object):void {
			if (Numbers.countProps(items) > 0) {
				block = true;
				
				Post.send( {
					ctr:		'user',
					act:		'unload',
					uID:		App.user.id,
					wID:		App.map.id,
					items:		JSON.stringify(items)
				}, function (error:int, data:Object, params:Object):void {
					block = false;
					
					if (error) return;
					
					for (var s:* in items) {
						App.user.ministock.items[s] -= items[s];
						if (App.user.ministock.items[s] == 0) {
							delete App.user.ministock.items[s];
						}
					}
					App.user.stock.addAll(items);
					
					hold.data = getHold();
					stock.data = getStock();
					hold.contentChange();
					stock.contentChange();
					
					updateStocks();
				});
			}
		}
		
		public function exchange(type:*, sid:int, count:int):void {
			new ShipTransferWindow( {
				callback:		onExchange,
				type:			type,
				sID:			sid,
				count:			count,
				max:			getMax()
			}).show();
			
			function getMax():int {
				if (type == ShipTransferWindow.FROM_STOCK) {
					return limitMinistock - countMinistock;
				}else {
					return countMinistock;
				}
				
				return 0;
			}
		}
		public function onExchange(type:*, sid:int, count:int):void {
			var items:Object = { };
			items[sid] = count;
			
			switch(type) {
				case ShipTransferWindow.FROM_STOCK:
					loadHold(items);
					break;
				case ShipTransferWindow.TO_STOCK:
					unloadHold(items);
					break;
			}
		}
		
		public function updateStocks():void {
			if (countMinistock > 0) {
				holdDescLabel.visible = false;
			}else {
				holdDescLabel.visible = true;
			}
			
			hold.countLabel.text = String(countMinistock) + '/' + String(limitMinistock);
			
			if (App.data.storage[App.user.worldID].size == World.MINI) {
				stock.countLabel.text = '';//String(Stock._value);
			}else{
				stock.countLabel.text = '';// String(Stock._value) + '/' + String(Stock.limit);
			}
			
			if (upgradeBttn) {
				if (App.data.storage[shipID].devel.req.hasOwnProperty(App.user.ministock.level + 1)) {
					upgradeBttn.settings.tips = makeTips();
				}else {
					upgradeBttn.visible = false;
				}
			}
		}
		static public function get limitMinistock():int {
			var value:int = 0;
			for (var lvl:* in App.data.storage[shipID].devel.req){
				if (int(lvl) <= App.user.ministock.level) value += App.data.storage[shipID].devel.req[lvl].c;
			}
			return value;
		}
		static public function get countMinistock():int {
			var value:int = 0;
			for (var s:* in App.user.ministock.items) {
				value += App.user.ministock.items[s];
			}
			return value;
		}
		
		private function mainStockFull():Boolean {
			if (countMinistock > Stock.limit - Stock._value) {
				new SimpleWindow( {
					title:		Locale.__e('flash:1382952379767'),
					text:		Locale.__e('flash:1419259351177'),
					popup:		true,
					dialog:		true,
					confirmText:Locale.__e('flash:1419257349967'),
					confirm:	function():void {
						moveAll();
					}
				}).show();
				return true;
			}
			
			return false;
		}
		
		private function makeTips():Object {
			if (App.user.ministock.level != App.self.getLength(App.data.storage[shipID].devel.req))
			{
				return { title:App.data.storage[shipID].title, text:Locale.__e('flash:1464964959168', [App.data.storage[shipID].devel.req[App.user.ministock.level + 1].c]) };
			} else {
				return { title:App.data.storage[shipID].title, text:Locale.__e('flash:1464964959168', [App.data.storage[shipID].devel.req[App.user.ministock.level].c]) };
			}
		}
		
		
		//public function set block(value:Boolean):void 
		
		override public function dispose():void {
			if(upgradeBttn) upgradeBttn.removeEventListener(MouseEvent.CLICK, upgradeAction);
			super.dispose();
		}
	}
}


import com.google.analytics.debug.VisualDebugMode;
import core.Load;
import effects.Effect;
import flash.display.Bitmap;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.filters.DropShadowFilter;
import flash.filters.GlowFilter;
import flash.geom.Rectangle;
import flash.text.TextField;
import silin.filters.ColorAdjust;
import wins.elements.SearchMaterialPanel;
import wins.ShipWindow;
import wins.Window;
import wins.Paginator;
import wins.WindowEvent;

internal class StockList extends Sprite {
	
	public var titleLabel:TextField;
	public var background:Bitmap;
	public var paginator:Paginator;
	public var container:Sprite;
	
	public var data:Array;
	public var items:Vector.<MaterialItem> = new Vector.<MaterialItem>;
	public var window:ShipWindow;
	public var type:*;
	public var countLabel:TextField;
	public var separator:Bitmap;
	
	public var params:Object = { };
	public var sections:Object = { };
	public var settings:Object = { };
	public var history:Object = { section:"all", page:0 };
	private var _searchPanel:SearchMaterialPanel;
	
	public function StockList(params:Object):void {
		sections = {
			"all":{items:new Array(),page:0}
		}
		settings['section'] = "all";
		
		for (var s:* in params)
			this.params[s] = params[s];
		
		window = params.window as ShipWindow;
		data = params.content || [];
		type = params.type;
		
		for each (var itm:Object in params.content) {
			var it:Object = App.data.storage[itm.sid];
			it['sid'] = itm.sid;
			it['count'] = itm.count;
			sections['all']['items'].push(it);
		}
		
		if (params.hasOwnProperty('backingBottom')) {
			background = Window.backing2(400, 630, 50, params.backing, params.backingBottom);
		}else {
			background = Window.backing(400, 630, 50, params.backing);
		}
		addChild(background);
		
		if (params['prebacking']) {
			var background2:Bitmap = Window.backing(320, 455, 50, params.prebacking);
			background2.x = (background.width - background2.width) / 2;
			background2.y = 94;
			addChild(background2);
		}
		
		if (params['roofTile']) {
			var roofCont:Sprite = new Sprite();
			addChild(roofCont);
			window.drawMirrowObjs(params['roofTile'], -10, 698 - 10, -35, false, false, false, 1, 1, roofCont);
			roofCont.scaleX = roofCont.scaleY = 0.59;
		}
		
		titleLabel = Window.drawText(params['title'], {
			fontSize:		46,
			color:			0xffffff,
			borderColor:	0xb48d62,
			autoSize:		'center'
		});
		titleLabel.filters = titleLabel.filters.concat([new DropShadowFilter(4, 90, 0x8a572a, 1, 0, 0)]);
		titleLabel.x = background.x + (background.width - titleLabel.width) / 2;
		titleLabel.y = background.y - 10;
		addChild(titleLabel);
		
		countLabel = Window.drawText('', {
			fontSize:		34,
			color:			0xffffff,
			borderColor:	0xb48d62,
			textAlign:		'center',
			width:			200
		});
		countLabel.filters = countLabel.filters.concat([new DropShadowFilter(4, 90, 0x8a572a, 1, 0, 0)]);
		countLabel.x = 0;
		countLabel.y = 5;
		addChild(countLabel);
		
		container = new Sprite();
		addChild(container);			
		
		drawPaginator();
		contentChange();		
		
		_searchPanel = new SearchMaterialPanel( {
				win:this, 
				callback:showFinded,
				stop:onStopFinding,
				hasIcon:false,
				caption:Locale.__e('flash:1382952380300')
			});
		_searchPanel.x = (background.width - _searchPanel.width) / 2 + 19;
		_searchPanel.y = background.y + 40;
		this.addChild(_searchPanel);
	}
	
	private function onStopFinding():void {
		data = params.content || [];
		contentChange();
	}
	
	private function showFinded(contents:Array):void {
		data = contents;
		paginator.itemsCount = contents.length;
		paginator.update();		
		contentChange();
	}	

	public function contentChange(e:WindowEvent = null):void {
		clear();
		paginator.itemsCount = data.length;
		paginator.update();
		
		for (var i:int = 0; i < paginator.onPageCount; i++) {
			var index:int = i + paginator.page * paginator.onPageCount;
			
			if (data.length <= index) continue;
			
			var item:MaterialItem = new MaterialItem( {
				sid:		data[index].sid,
				count:		data[index].count
			});
			item.x = 60 + (i % 2) * (item.background.width + 14);
			item.y = 106 + Math.floor(i / 2) * (item.background.height + 14);
			item.addEventListener(Event.CHANGE, onMaterialItemChange);
			container.addChild(item);
			items.push(item);
			
		}
	}
	
	private function onMaterialItemChange(e:Event):void {
		if (window.block) return;
		
		var item:MaterialItem = e.currentTarget as MaterialItem;
		window.exchange(type, item.sid, item.count);
	}
	
	private function clear():void {
		while (items.length > 0) {
			var item:MaterialItem = items.shift();
			item.removeEventListener(Event.CHANGE, onMaterialItemChange);
			item.dispose();
		}
		//sections['all'].items = [];
	}
	
	private function drawPaginator():void {
		paginator = new Paginator(data.length, 6, 3);
		paginator.x = 102;
		paginator.y = background.height - 32;
		paginator.addEventListener(WindowEvent.ON_PAGE_CHANGE, contentChange);
		paginator.update();
		addChild(paginator);
		
		paginator.drawArrow(this, Paginator.LEFT,  0, 0, { scaleX: -0.85, scaleY:0.85 } );
		paginator.drawArrow(this, Paginator.RIGHT, 0, 0, { scaleX:0.85, scaleY:0.85 } );
		
		paginator.arrowLeft.x = 20;
		paginator.arrowLeft.y = background.height - paginator.arrowRight.height - 16;
		
		paginator.arrowRight.x = background.width - paginator.arrowRight.width - 8;
		paginator.arrowRight.y = background.height - paginator.arrowRight.height - 16;
		
		paginator.pointsLeft.x -= 14;
		paginator.pointsRight.x += 10;
	}
	
	public function dispose():void {
		clear();
		paginator.removeEventListener(WindowEvent.ON_PAGE_CHANGE, contentChange);
		paginator.dispose();
	}
}



internal class MaterialItem extends LayerX {
	
	public static var checked:MaterialItem;
	
	public var sid:int;
	public var count:int = 0;
	public var info:Object;
	public var title:String;
	public var order:int;
	
	public var background:Bitmap;
	public var bitmap:Bitmap;
	public var countLabel:TextField;
	private var preloader:Preloader;
	
	public function MaterialItem(params:Object):void {
		
		background = Window.backing(134, 134, 50, 'itemBacking');
		addChild(background);
		
		sid = params['sid'];
		count = params['count'];
		if (!App.data.storage.hasOwnProperty(sid)) return;
		info = App.data.storage[sid];
		title = info.title;
		order = info.order;
		
		tip = function():Object {
			return {
				title:	info.title,
				text:	info.description
			}
		}
		
		bitmap = new Bitmap();
		addChild(bitmap);
		
		Load.loading(Config.getIcon(info.type, info.preview), onLoad);
		if (!bitmap.bitmapData) {
			preloader = new Preloader();
			preloader.x = background.width / 2;
			preloader.y = background.height / 2;
			addChild(preloader);
		}
		
		countLabel = Window.drawText('x' + String(count), {
			width:			110,
			fontSize:		30,
			color:			0xf8ffff,
			borderColor:	0x88542d,
			textAlign:		'right'
		});
		countLabel.x = 0;
		countLabel.y = background.height - countLabel.height;
		addChild(countLabel);
		
		drawTitle();
		
		addEventListener(MouseEvent.CLICK, onClick);
		addEventListener(MouseEvent.MOUSE_OVER, onOver);
		addEventListener(MouseEvent.MOUSE_OUT, onOut);
	}
	
	public function onLoad(data:Bitmap):void {
		if (preloader) {
			removeChild(preloader);
			preloader = null;
		}
		
		bitmap.bitmapData = data.bitmapData;
		bitmap.smoothing = true;
		
		if (bitmap.width > background.width * 0.6) {
			bitmap.width = int(background.width * 0.6);
			bitmap.scaleY = bitmap.scaleX;
		}
		if (bitmap.height > background.height * 0.6) {
			bitmap.height = int(background.height * 0.6);
			bitmap.scaleX = bitmap.scaleY;
		}
		
		bitmap.x = background.x + (background.width - bitmap.width) / 2;
		bitmap.y = background.y + (background.height - bitmap.height) / 2;
		
	}
	
	private function drawTitle():void {
		var titleLabel:TextField = Window.drawText(String(info.title), {
			width:			background.width,
			fontSize:		20,
			color:			0x763b17,
			borderColor:	0xf9f8eb,
			textAlign:		'center'
		});
		titleLabel.y = 5;
		addChild(titleLabel);
	}
	
	private function onClick(e:MouseEvent):void {
		if (checked != this) {
			if (MaterialItem.checked) MaterialItem.checked.uncheck();
			MaterialItem.checked = this;
			check();
		}
		
		dispatchEvent(new Event(Event.CHANGE));
	}
	private function onOver(e:MouseEvent):void {
		effect(0.06);
	}
	private function onOut(e:MouseEvent):void {
		effect(0);
	}
	public function effect(count:Number = 0, saturation:Number = 1):void {
		var mtrx:ColorAdjust;
		mtrx = new ColorAdjust();
		mtrx.saturation(saturation);
		mtrx.brightness(count);
		this.filters = [mtrx.filter];
	}
	
	public function check():void {
		background.filters = [new GlowFilter(0xcbcc29, 1, 8, 8, 16)];
	}
	public function uncheck():void {
		background.filters = null;
	}
	
	public function dispose():void {
		removeEventListener(MouseEvent.CLICK, onClick);
		removeEventListener(MouseEvent.MOUSE_OVER, onOver);
		removeEventListener(MouseEvent.MOUSE_OUT, onOut);
		if (parent) parent.removeChild(this);
	}
	
}