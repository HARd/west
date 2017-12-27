package units {
	
	import buttons.Button;
	import buttons.ImageButton;
	import buttons.MoneyButton;
	import core.Log;
	import core.Size;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import ui.Hints;
	import ui.UserInterface;
	import units.Factory;
	import units.Techno;
	import units.Ttechno;
	import units.Unit;
	import units.Wigwam;
	import units.WorkerUnit;
	import wins.ShopWindow;
	import wins.Window;
	import core.Load;
	import com.greensock.*;
	
	public class PetFoodPurchaseItem extends Sprite {
		
		public var callback:Function;
		public var background:Shape;
		public var title:TextField;
		public var sID:int;
		public var bitmap:Bitmap;
		public var sprite:LayerX;
		public var coinsBttn:MoneyButton;
		public var banksBttn:Button;
		public var selectBttn:Button;
		public var moneyType:String;
		public var window:*;
		
		private var object:Object;
		private var id:uint;
		private var dY:int = -10;
		private var preloader:Preloader = new Preloader();
		public var _state:uint = 1;
		private var underIcon:Bitmap;
		private var objIcon:Object;
		private var price:int;
		private var drawDesc:Boolean = false;
		public var doGlow:Boolean = false;
		private var noTitle:Boolean = false;
		private var noDesc:Boolean = false;
		public var bgWidth:int = 152;
		private var feedPetCallback:Function;
		
		public function PetFoodPurchaseItem(sID:int, callback:Function, window:*, id:uint, doGlow:Boolean = false, noTitle:Boolean = false, noDesc:Boolean = false, feedPetCallback:Function = null) {
			this.id = id;
			this.sID = sID;
			this.callback = callback;
			this.window = window;
			this.doGlow = doGlow;
			this.noTitle = noTitle;
			this.noDesc = noDesc;
			this.feedPetCallback = feedPetCallback;
			var rad:int = 70;
			background = new Shape();
			background.graphics.beginFill(0xc8cabc, 1);
			background.graphics.drawCircle(70, 60, rad);
			background.graphics.endFill();
			addChild(background);
			window.settings.closeAfterBuy = false;
			//var shine:Bitmap = new Bitmap(Window.textures.glow);
			//shine.x = -10;
			//shine.y = -20;
			//shine.scaleX = shine.scaleY = 0.45;
			//shine.smoothing = true;
			//addChild(shine);
			
			sprite = new LayerX;
			addChild(sprite);
			
			bitmap = new Bitmap(null,"auto", true);
			sprite.addChild(bitmap);
			
			var searchBttn:ImageButton = new ImageButton(UserInterface.textures.lens);
			//searchBttn.addEventListener(MouseEvent.CLICK, onSearchOut);
			//if (App.data.storage[sID].out != Techno.TECHNO && App.data.storage[sID].out != Ttechno.TECHNO) 
			//addChild(searchBttn);
			//
			sprite.tip = function():Object {
				return {
					title:App.data.storage[sID].title,
					text:App.data.storage[sID].description
				};
			};
			
			preloader.x = (background.width)/ 2;
			preloader.y = (background.height) / 2 - 8;
			addChild(preloader);
			
			object = App.data.storage[sID];
			
			if (object.hasOwnProperty('price')) {
				price = object.price[Stock.FANT];
			} else {
				drawDesc = false;
				price = 1;
			}
			
			if(!noTitle) {
				title = Window.drawText(object.title, {
					multiline:true,
					textAlign:"center",
					textLeading: -10,
					fontSize:24,
					color:0xfaf9ec,//0xfff7fc,
					borderColor:0x814f31,//0x9b1356
					borderSize:2,
					shadowColor:0x814f31,
					shadowSize:2
				});
				title.wordWrap = true;
				title.height = title.textHeight+ 10;
				title.width = background.width - 4;
				title.x = (background.width - title.width) / 2;
				title.y = -title.textHeight - 15;
				if (title.textHeight > 20) {
					title.y += 20;
				}
				addChild(title);
			}
			
			if (window.settings.listType == "Hut")	drawSelectBttn();
			if (price == 0)							drawStockFull();
			else 									drawMoneyBttn();
			
			if (App.data.storage[sID].type == "Jam") {
				dY = -15
				drawCapacity();
			}
			
			if (object.type == 'Firework' || object.type == 'Material') {
				objIcon = App.data.storage[object.sID];
			} else {
				objIcon = App.data.storage[object.out];
			}
			
			if (!drawDesc && !noDesc) {
				if (App.data.storage[sID].view == 'Feed') {
					var count:int = object.count;
					if (!object.count) count = 1;
					var efirCount:TextField = Window.drawText('+' + count, {
						multiline:true,
						autoSize:"left",
						textAlign:"left",
						fontSize:28,
						color:Window.getTextColor(object.out).color,
						borderColor:Window.getTextColor(object.out).borderColor
					});
					var animalIcon:Bitmap;
					
					var _iconScale:Number = 0.5;
					switch (sID) 
					{
						case 281:
							animalIcon = new Bitmap(Window.textures.chickenIco);
							animalIcon.x = background.width - 50;
						break;
						case 282:
							animalIcon = new Bitmap(Window.textures.chickenIco);
							animalIcon.x = background.width - 50;
						break;
						case 283:
							animalIcon = new Bitmap(Window.textures.cowIco);
							animalIcon.x = background.width - 55;
						break;
						case 284:
							animalIcon = new Bitmap(Window.textures.cowIco);
							animalIcon.x = background.width - 55;
						break;
						case 328:
							animalIcon = new Bitmap(Window.textures.sheepIco);
							animalIcon.x = background.width - 65;
						break;case 329:
							animalIcon = new Bitmap(Window.textures.sheepIco);
							animalIcon.x = background.width - 65;
						break;
						case 347:
							animalIcon = new Bitmap(Window.textures.pigIco);
							animalIcon.x = background.width - 65;
						break;
						case 348:
							animalIcon = new Bitmap(Window.textures.pigIco);
							animalIcon.x = background.width - 65;
						break;
						case 370:
							animalIcon = new Bitmap(Window.textures.rabbitIco);
							animalIcon.scaleX = animalIcon.scaleY = 1.2;
							animalIcon.smoothing = true;
							animalIcon.x = background.width - 55;
						break;
						case 371:
							animalIcon = new Bitmap(Window.textures.rabbitIco);
							animalIcon.scaleX = animalIcon.scaleY = 1.2;
							animalIcon.smoothing = true;
							animalIcon.x = background.width - 55;
						break;
						case 405:
							animalIcon = new Bitmap(Window.textures.shepherdIco);
							animalIcon.x = background.width - 65;
						break;
						case 433:
							animalIcon = new Bitmap(Window.textures.snakeIco);
							animalIcon.x = background.width - 65;
						break;
						case 434:
							animalIcon = new Bitmap(Window.textures.snakeIco);
							animalIcon.x = background.width - 65;
						break;
						case 700:
							animalIcon = new Bitmap(UserInterface.textures.whitchCatHead);
							animalIcon.x = background.width - 65;
							_iconScale = 1;
						break;
						case 701:
							animalIcon = new Bitmap(UserInterface.textures.whitchCatHead);
							animalIcon.x = background.width - 65;
							_iconScale = 1;
						break;
						case 729:
							animalIcon = new Bitmap(UserInterface.textures.wispIco);
							animalIcon.x = background.width - 65;
							_iconScale = 1;
						break;
						case 730:
							animalIcon = new Bitmap(UserInterface.textures.wispIco);
							animalIcon.x = background.width - 65;
							_iconScale = 1;
						break;
						case 746:
							animalIcon = new Bitmap(UserInterface.textures.batterflyIco);
							animalIcon.x = background.width - 65;
							_iconScale = 1;
						break;
						case 747:
							animalIcon = new Bitmap(UserInterface.textures.batterflyIco);
							animalIcon.x = background.width - 65;
							_iconScale = 1;
						break;
					} 
					if (animalIcon != null) {
						
						animalIcon.scaleX = animalIcon.scaleY = _iconScale;
						animalIcon.smoothing = true;
						animalIcon.y = background.height - 115;
						addChild(animalIcon);
					}
					efirCount.wordWrap = true;
					efirCount.height = efirCount.textHeight;
					efirCount.width = efirCount.textWidth + 10;
					addChild(efirCount);
					efirCount.x = (background.width - efirCount.textWidth) / 2 - 3;
					efirCount.y += -2;
					
				} else {
					if (App.data.storage[sID].out == Techno.TECHNO) {
						onLoadOut(new Bitmap(UserInterface.textures.iconWorker));
					} else {
						Load.loading(Config.getIcon(objIcon.type, objIcon.preview), onLoadOut);
					}
				}
			}
			else if (drawDesc) 
				drawDescription();
			else if (noDesc && !noTitle)
				title.y = background.y + 5;
			
			Load.loading(Config.getIcon(object.type, object.preview), onLoad);
			
			if (App.data.storage[sID].out == Ttechno.TECHNO) {
				drawFindButton();
			}
			
			if (doGlow)
				glowing();
		}
		
		private function onSearchOut(e:MouseEvent):void {
			Window.closeAll();
			ShopWindow.findMaterialSource(App.data.storage[sID].out);
		}
		
		private function glowing():void {
			customGlowing(background, glowing);
			if (coinsBttn) {
				customGlowing(coinsBttn);
			}
			if (banksBttn) {
				customGlowing(banksBttn);
			}
		}
		
		private function customGlowing(target:*, callback:Function = null):void {
			TweenMax.to(target, 1, { glowFilter: { color:0xFFFF00, alpha:0.8, strength: 7, blurX:12, blurY:12 }, onComplete:function():void {
				TweenMax.to(target, 0.8, { glowFilter: { color:0xFFFF00, alpha:0.6, strength: 7, blurX:6, blurY:6 }, onComplete:function():void {
					if (callback != null) {
						callback();
					}
				}});
			}});
		}
		
		private function drawStockFull():void 
		{
			//var itemDesc:TextField = Window.drawText(Locale.__e('flash:1415105806365'), {
				//multiline:true,
				//autoSize:"center",
				//textAlign:"center",
				//fontSize:22,
				//color:Window.getTextColor(object.out).color,
				//borderColor:Window.getTextColor(object.out).borderColor
			//});
			//itemDesc.wordWrap = true;
			//itemDesc.height = itemDesc.textHeight;
			//itemDesc.width = itemDesc.textWidth+60;
					//
			//itemDesc.x = (background.width - itemDesc.width) / 2;
			//itemDesc.y = background.height - itemDesc.height - 5;
			//addChild(itemDesc);
		}
		
		private function drawDescription():void 
		{
			var itemDesc:TextField = Window.drawText(object.description, {
				multiline:true,
				autoSize:"center",
				textAlign:"center",
				fontSize:22,
				color:Window.getTextColor(object.out).color,
				borderColor:Window.getTextColor(object.out).borderColor
			});
			itemDesc.wordWrap = true;
			itemDesc.height = itemDesc.textHeight;
			itemDesc.width = itemDesc.textWidth+30;
					
			itemDesc.x = (background.width - itemDesc.width) / 2;
			itemDesc.y = 4;
			addChild(itemDesc);
		}
		
		private var feedsCount:TextField
		
		private function onLoadOut(data:*):void 
		{
			if (object.type == 'Firework')
				return;
			
			var spEfir:LayerX = new LayerX();
			spEfir.tip = function():Object {
				return {
					title:		objIcon.title,
					text:		objIcon.description
				}
			}
			
			var countTextSettings:Object;
			
			var viewEnergy:Object = {
				multiline:true,
				autoSize:"left",
				textAlign:"left",
				fontSize:32,
				color:0xffffff,
				borderColor:0x3453c6,
				shadowColor:0x3453c6,
				shadowSize:1
			};
			
			var viewFood:Object = {
				multiline:true,
				autoSize:"left",
				textAlign:"left",
				fontSize:32,
				color:0xf3feb0,
				borderColor:0x532d1a,
				shadowColor:0x532d1a,
				shadowSize:1
			};
			
			switch(App.data.storage[sID].view) {
				case 'energy':
					countTextSettings = viewEnergy;
				break;
				case 'food':
					countTextSettings = viewFood;
				break;
				case 'workers':
					countTextSettings = viewFood;
				break;
				default:
					countTextSettings = viewFood;
			}
			var count:int = object.count;
			if (!object.count) count = 1;
			var efirCount:TextField = Window.drawText('+' + count, countTextSettings);
			efirCount.wordWrap = true;
			efirCount.height = efirCount.textHeight;
			efirCount.width = efirCount.textWidth + 10;
			efirCount.y = 5;
			spEfir.addChild(efirCount);
			//WindowsLib.textures
			var iconEfir:Bitmap = new Bitmap(Window.textures.petEnergyIcon);
			iconEfir.x = efirCount.x + efirCount.width;
			//iconEfir.scaleX = iconEfir.scaleY = 0.4;
			Size.size(iconEfir, 45, 45);
			iconEfir.smoothing = true;
			spEfir.addChild(iconEfir);
			
			spEfir.x = (background.width - spEfir.width) / 2;
			spEfir.y = 90;
			addChild(spEfir);
			
			if (App.data.storage[sID].out == Ttechno.TECHNO) {
				efirCount.y = 5;
				spEfir.y = 105;
			}
			
			var obj:Object = App.data.storage[sID];
			if (App.user.stock.count(obj.out) - obj.count >= 0)
			{
				var textSettings:Object = {
					multiline:false,
					autoSize:"left",
					textAlign:"left",
					fontSize:24,
					color:0xffffff,
					borderColor:0x3453c6,
					shadowColor:0x3453c6,
					shadowSize:1
					};
				feedsCount = Window.drawText(String(Math.floor(App.user.stock.count(obj.out) / obj.count)) + "/ 1", textSettings);
				feedsCount.x = 0,
				feedsCount.y = efirCount.y + efirCount.height;
				spEfir.addChild(feedsCount);
			}
			else
			{
				drawFindButton();
			}
		}
		
		//private function drawFindButton():void
		//{
			//
		//}
		
		public function set state(value:uint):void
		{
			_state = value;
			if (_state){
				if(banksBttn)	banksBttn.state = Button.NORMAL;
				if(coinsBttn)	coinsBttn.state = Button.NORMAL;
			}else{ 
				if(banksBttn)	banksBttn.state = Button.DISABLED;
				if (coinsBttn)	coinsBttn.state = Button.DISABLED;
			}	
		}
		
		private function drawSelectBttn():void
		{
			selectBttn = new Button( {
				width:125,
				height:40,
				fontSize:24,
				bgColor		:[0xfdb29f, 0xed7483],
				borderColor	:[0xffffff, 0xffffff],
				bevelColor  :[0xfeb19f, 0xe87383],
				fontColor	:0xffffff,
				fontBorderColor :0x993a40,
				fontCountColor	:0xFFFFFF,
				fontCountBorder :0x354321,
				fontBorderSize	:3,
				caption:Locale.__e("flash:1382952380066")
			});
			
			selectBttn.x = (this.width - selectBttn.width)/2;
			selectBttn.y = 180;
			addChild(selectBttn);
			selectBttn.addEventListener(MouseEvent.CLICK, onSelectClick);
			
			moneyType = 'coins';
		}
		
		private var findBttn:Button;
		private function drawFindButton():void {
			findBttn = new Button({
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
			findBttn.x = (152 - findBttn.width) / 2 - 5;
			findBttn.y = 130;
			findBttn.addEventListener(MouseEvent.CLICK, onFind);
			addChild(findBttn);
			
			if (sID == 3023 || sID == 3024)
			{
				findBttn.visible = false;
			}
		}
		
		private function onFeedClick(e:MouseEvent):void
		{
			feedPetCallback(App.data.storage[sID].out, App.data.storage[sID].count);
			window.close();
		}
		
		private function drawMoneyBttn():void
		{
			var obj:Object = App.data.storage[sID];
			//;
			
			if (App.user.stock.count(obj.out) - obj.count >= 0)
			{
				var feedBtc:Button = new Button({
				fontSize:26,
				radius:14,
				caption:Locale.__e('flash:1428408092399'),
				fontSize:20,
				width			:132,
				height			:44
				});
				
				feedBtc.x = (this.width - feedBtc.width)/2;
				feedBtc.y = 160;
				
				addChild(feedBtc);
				
				feedBtc.addEventListener(MouseEvent.CLICK, onFeedClick);
			}
			else
			{
				var dy:int = 160;
				if (App.data.storage[sID].out == Ttechno.TECHNO) dy = 180;
				if (object.hasOwnProperty('socialprice') && object.socialprice.hasOwnProperty(App.social)) {
					var _count:Number = object.socialprice[App.social];
					
					banksBttn = new Button( {
						caption:Payments.price(_count),
						width			:132,
						height			:44,
						fontSize		:28,
						shadow:true,
						type:"green"
					});
					addChild(banksBttn);
					
					banksBttn.x = (this.width - banksBttn.width)/2;
					banksBttn.y = dy;
					
					moneyType = 'energy';
					banksBttn.addEventListener(MouseEvent.CLICK, onSocialBuyClick)
				}else{
					if (object.coins > 0)
					{
						coinsBttn = new MoneyButton( {
							countText:String(object.coins),
							width:125,
							height:46,
							caption:Locale.__e("flash:1382952379984"),
							shadow:true,
							fontCountSize:23,
							fontSize:24,
							type:"gold"
						});
						coinsBttn.x = (this.width - coinsBttn.width)/2;
						coinsBttn.y = dy;
						addChild(coinsBttn);
						coinsBttn.addEventListener(MouseEvent.CLICK, onBuyClick);
						
						moneyType = 'coins';
					} else {	
						if ( object.sID == 911 || object.sID == 2105) {
							if (App.user.stock.count(object.sID) > 0) {
								var takeBttn:Button = new Button({
									caption			:Locale.__e("flash:1412930855334"),
									radius      	:10,
									//fontColor:		0xffffff,
									//fontBorderColor:0x475465,
									//borderColor:	[0xfff17f, 0xbf8122],
									//bgColor:		[0x75c5f6,0x62b0e1],
									//bevelColor:		[0xc6edfe,0x2470ac],
									width			:132,
									height			:44,
									fontSize		:28
								});
								takeBttn.x = (152 - takeBttn.width) / 2 - 5;
								takeBttn.y = dy;
								
								takeBttn.addEventListener(MouseEvent.CLICK, onTake);
								addChild(takeBttn);
								return;
							} else {
								var askBttn:Button = new Button({
									caption			:Locale.__e("flash:1405687705056"),
									radius      	:10,
									fontColor:		0xffffff,
									fontBorderColor:0x475465,
									borderColor:	[0xfff17f, 0xbf8122],
									bgColor:		[0x75c5f6,0x62b0e1],
									bevelColor:		[0xc6edfe,0x2470ac],
									width			:132,
									height			:44,
									fontSize		:28
								});
								askBttn.x = (152 - askBttn.width) / 2 - 5;
								askBttn.y = dy;
								
								askBttn.addEventListener(MouseEvent.CLICK, onSearch);
								addChild(askBttn);
								return;
							}
						}
						banksBttn = new MoneyButton( {
							caption:Locale.__e('flash:1382952379751') + ':',
							countText:String(price),
							width:132,
							height:44,
							shadow:true,
							fontCountSize:23,
							fontSize:22,
							type:"green",
							radius:18,
							fontBorderColor:0x406903,
							fontCountBorder:0x406903,
							iconScale:0.65,
							fontCountSize:36
						});
						banksBttn.x = (152 - banksBttn.width) / 2 - 5;
						banksBttn.y = dy;
						addChild(banksBttn);
						banksBttn.addEventListener(MouseEvent.CLICK, onBuy1Click);
						
						if (!object.hasOwnProperty('price'))
						{
							banksBttn.visible = false;
						}
						moneyType = 'banknotes';
					}
				}
			}
		}
		
		private function onSearch(e:MouseEvent):void {
			window.close();
			ShopWindow.findMaterialSource(object.sID);
		}
		
		private function onTake(e:MouseEvent):void {
			window.close();
			var settings:Object = { sid:sID, fromStock:true };
				
			var unit:Unit = Unit.add(settings);
			unit.move = true;
			App.map.moved = unit;
		}
		
		public function dispose():void {
			if(coinsBttn != null){
				coinsBttn.removeEventListener(MouseEvent.CLICK, onBuyClick)
			}
			if(banksBttn != null){
				banksBttn.removeEventListener(MouseEvent.CLICK, onBuyClick)
			}
			if(selectBttn != null){
				selectBttn.removeEventListener(MouseEvent.CLICK, onSelectClick)
			}
			if (this.parent != null) {
				this.parent.removeChild(this);
			}
		}
		
		public function onFind(e:MouseEvent):void
		{
			/*var units2:Array = Map.findUnitsByType(['wigwam']);
			for each (var u:Wigwam in units2) {
				if (u.workers.length == 0) {
					App.map.focusedOn(u, true);
					return;
				}
			}
			
			var wigwams:Array = [];
			for (var s:* in App.data.storage) {
				if (App.data.storage[s].type == 'Wigwam') {
					wigwams.push(int(s));
				}
			}
			if (wigwams.length > 0) {
				Window.closeAll();
				ShopWindow.show({find:wigwams});
			}*/
			
			Find.find(sID);
		}
		
		public function onSelectClick(e:MouseEvent):void
		{
			if(callback != null) callback(this.sID);
			window.close();
		}
		
		private function onSocialBuyClick(e:MouseEvent):void {
			if (e.currentTarget.mode == Button.DISABLED) return;			
			var that:PetFoodPurchaseItem = this;
			Payments.buy( {
				type:			'energy',
				id:				sID,
				price:			int(object.socialprice[App.social]),
				count:			1,
				title: 			Locale.__e('flash:1396521604876'),
				description: 	Locale.__e('flash:1393581986914'),
				callback:		function():void {
					Log.alert('callback PurchaseItem');
					if (callback != null) callback(that.sID);
					App.user.stock.add(App.data.storage[that.sID].out, App.data.storage[that.sID].count);
				},
				error:			function():void {
					window.close();
				},
				icon:			Config.getIcon(object.type, object.preview)
			});
		}
		
		public function onBuy1Click(e:MouseEvent):void
		{
			if (e.currentTarget.mode == Button.DISABLED) return;
			
			var sett:Object = null;
			
			if (App.data.storage[this.sID].out == Techno.TECHNO) {
				sett = { 
					ctr:'techno',
					wID:App.user.worldID,
					x:App.map.heroPosition.x,
					z:App.map.heroPosition.z,
					capacity:1
				};
			}
			
			if (App.data.storage[this.sID].out == Ttechno.TECHNO) {
				sett = { 
					ctr:'ttechno',
					wID:App.user.worldID,
					x:App.map.heroPosition.x,
					z:App.map.heroPosition.z,
					capacity:1
				};
			}
			
			window.blokItems(false);
			App.user.stock.pack(this.sID, onBuyComplete, function():void {
				window.blokItems(true);
				//window.close();
			}, sett);
			if (window.settings.closeAfterBuy) window.close();
		}
		
		public function onBuyClick(e:MouseEvent):void
		{
			if (e.currentTarget.mode == Button.DISABLED) return;
			
			var sett:Object = null;
			
			if (App.data.storage[this.sID].out == Techno.TECHNO) {
				sett = { 
					ctr:'techno',
					wID:App.user.worldID,
					x:App.map.heroPosition.x,
					z:App.map.heroPosition.z,
					capacity:1
				};
			}
			
			if (App.data.storage[this.sID].out == Ttechno.TECHNO) {
				sett = { 
					ctr:'ttechno',
					wID:App.user.worldID,
					x:App.map.heroPosition.x,
					z:App.map.heroPosition.z,
					capacity:1
				};
			}
			
			window.blokItems(false);
			App.user.stock.pack(this.sID, onBuyComplete, function():void {
				window.blokItems(true);
				//window.close();
			}, sett);
			if (window.settings.closeAfterBuy) window.close();
		}
		
		private function onBuyComplete(sID:uint, rez:Object = null):void
		{
			if (callback != null) callback(sID);
			if (Techno.TECHNO == sID || App.data.storage[sID].type == 'Ttechno') {
				addChildrens(sID, rez.ids);
			} else if ([908, 912].indexOf(int(sID)) != -1) {
				var settings:Object = { sid:sID, fromStock:true };
				
				var unit:Unit = Unit.add(settings);
				unit.move = true;
				App.map.moved = unit;
				window.close();
			} else {
				var currentTarget:Button;
				if (banksBttn) currentTarget = banksBttn;
				if (coinsBttn) currentTarget = coinsBttn;
				
				var X:Number = App.self.mouseX - currentTarget.mouseX + currentTarget.width / 2;
				var Y:Number = App.self.mouseY - currentTarget.mouseY;
				
				Hints.plus(this.sID, 1, new Point(X,Y), true, App.self.tipsContainer);
				
				for (var _sid:* in object.price)
					Hints.minus(_sid, object.price[_sid], new Point(X, Y), false, App.self.tipsContainer);
			}
			
			if (sID != Techno.TECHNO){
				flyMaterial();
				window.blokItems(true);
			}
			
			window.removeItems();
			window.createItems();
			window.contentChange();
			window.updateViews();
			if (window.settings.closeAfterBuy)	window.close();
		}
		
		private function addChildrens(_sid:uint, ids:Object):void 
		{
			var rel:Object = { };
			rel[Factory.TECHNO_FACTORY] = _sid;
			var position:Object = App.map.heroPosition;
			for (var i:* in ids){
				var unit:Unit = Unit.add( { sid:_sid, id:ids[i], x:position.x, z:position.z, rel:rel, finished:App.time + App.data.options.buyedTechnoTime} );
			}
		}
		
		public function onLoad(data:*):void
		{
			removeChild(preloader);
			bitmap.bitmapData = data.bitmapData;
			bitmap.x = (background.width - bitmap.width) / 2;
			bitmap.y = (background.height - bitmap.height) / 2 - 12;
			if (sID == 370 || sID == 371) {
				bitmap.x = (background.width - bitmap.width) / 2 - 10;
			}
		}
			
		private function drawCapacity():void
		{
			var container:Sprite = new Sprite();
			
			var spoonIcon:Bitmap = new Bitmap();
			var _text:String;
			
			var textSettings:Object;
			textSettings = {
					color				: 0x614605,
					fontSize			: 16,
					borderColor 		: 0xf5efd9
				}
				
			if (object.view.indexOf('jam') != -1) {
				spoonIcon = new Bitmap(UserInterface.textures.spoonIcon);
				spoonIcon.scaleX = spoonIcon.scaleY = 0.25;
				switch(id)
				{
					case 0: _text = Locale.__e("flash:1382952380067"); break;
					case 1: _text = Locale.__e("flash:1382952380068"); break;
					case 2: _text = Locale.__e("flash:1382952380069"); break;
				}
			}else {
				spoonIcon = new Bitmap(UserInterface.textures.spoonIconFish);
				spoonIcon.scaleX = spoonIcon.scaleY = 0.35;
				switch(id)
				{
					case 0: _text = Locale.__e("flash:1382952380070"); break;
					case 1: _text = Locale.__e("flash:1382952380071"); break;
					case 2: _text = Locale.__e("flash:1382952380072"); break;
				}
			}
			spoonIcon.smoothing = true;
			
			var text:TextField = Window.drawText(_text + ":", textSettings);
			
			text.width 	= text.textWidth  + 4;
			text.height = text.textHeight;
			
			var countText:TextField = Window.drawText(String(App.data.storage[object.sID].capacity), textSettings);
			
			countText.height = countText.textHeight;
			countText.width = countText.textWidth + 4;
			countText.border = false;
			
			countText.x = text.width + 4;
			
			spoonIcon.x = countText.x + countText.width + 4;
			spoonIcon.y = countText.y + (countText.textHeight - spoonIcon.height)/2;
			
			container.addChild(text);
			container.addChild(countText);
			container.addChild(spoonIcon);
			
			addChild(container);
			container.x = (background.width - container.width) / 2;
			container.y = background.height - container.height - 28;
		}	
		private function flyMaterial():void
		{
			var _sID:uint = sID;
			if (App.data.storage[sID].type == 'Energy' && App.data.storage[sID].view == 'Energy' && !App.data.storage[sID].inguest){
				_sID = Stock.FANTASY;
			}
			if (App.data.storage[sID].type == 'Energy' && App.data.storage[sID].view == 'Energy' && App.data.storage[sID].inguest == 1){
				_sID = Stock.GUESTFANTASY;
			}
			if (App.data.storage[sID].type == 'Energy' && App.data.storage[sID].view == 'Feed' && !App.data.storage[sID].inguest){
				_sID = App.data.storage[sID].out;
			}
				
			var item:BonusItem = new BonusItem(_sID, 0);
			
			var point:Point = Window.localToGlobal(bitmap);
			item.cashMove(point, App.self.windowContainer);
		}
	}
}	