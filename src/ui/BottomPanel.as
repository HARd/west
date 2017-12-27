package ui 
{
	import api.ExternalApi;
	import buttons.Button;
	import buttons.ImagesButton;
	import com.greensock.easing.Back;
	import com.greensock.TweenLite;
	import core.Load;
	import core.Numbers;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.utils.clearInterval;
	import flash.utils.setInterval;
	import flash.utils.setTimeout;
	import units.Field;
	import wins.CollectionWindow;
	import wins.elements.PostPreloader;
	import wins.FBFreebieWindow;
	import wins.FreeGiftsWindow;
	import wins.GroupWindow;
	import wins.InfoWindow;
	import wins.newFreebie.NewFreebieModel;
	import wins.newFreebie.NewFreebieWindow;
	import wins.PurchaseWindow;
	import wins.ShipWindow;
	import wins.ShopWindow;
	import wins.SimpleWindow;
	import wins.StockWindow;
	import wins.TravelWindow;
	import wins.Window;
	
	public class BottomPanel extends Sprite
	{
		public static var communityAdd:Boolean = false;
		
		private var leftContainer:Sprite;
		private var rightContainer:Sprite;
		private var rightGuestContainer:Sprite;
		private var leftBacking:Sprite;
		private var rightBacking:Sprite;
		private var rightGuestBacking:Bitmap;
		
		public var bttnFreebie:ImagesButton;
		public var bttnCommunity:ImagesButton;
		public var bttnMainStock:ImagesButton;
		public var bttnMainHome:ImagesButton;
		public var bttnCollection:ImagesButton;
		public var bttnMainShop:ImagesButton;
		public var bttnMainGifts:ImagesButton;
		public var giftsCounter:IconCounter;
		public var collectionCounter:IconCounter;
		
		public var bttnMainMap:ImagesButton;
		public var bttnStop:ImagesButton;
		public var bttnGuestStop:ImagesButton;
		public var bttnCursors:ImagesButton;
		
		public var bttnExpHome:ImagesButton;
		public var bttnExpHelp:ImagesButton;
		public var bttnExpMove:ImagesButton;
		public var bttnExpStock:ImagesButton;
		public var bttnExpDynamite:ImagesButton;
		
		public var bttnResHelp:ImagesButton;
		
		public var homeBttn:Button;
		
		public var textCollection:TextField;
		public var textGifts:TextField;
		public var collectionCounterContainer:Sprite;
		public var giftCounterContainer:Sprite;
		
		public var friendsPanel:FriendsPanel;
		public var cursorPanel:Sprite;
		
		private var objects:Vector.<Sprite> = new Vector.<Sprite>;
		
		public function BottomPanel() {
			draw();
			resize();
		}
		
		public function draw():void {
			// Friends
			friendsPanel = new FriendsPanel(this);
			addChild(friendsPanel);
			
			
			// Corner elements
			leftContainer = new Sprite();
			addChild(leftContainer);
			
			leftBacking = new Sprite();
			fillBySectors(leftBacking, UserInterface.textures.backingLeft);
			leftBacking.x = -1;
			leftBacking.y = -leftBacking.height + 1;
			leftContainer.addChild(leftBacking);
			
			rightContainer = new Sprite();
			addChild(rightContainer);
			
			rightBacking = new Sprite();
			fillBySectors(rightBacking, UserInterface.textures.backingRight);
			rightBacking.x = -rightBacking.width + 1;
			rightBacking.y = -rightBacking.height + 1;
			rightContainer.addChild(rightBacking);
			
			bttnMainMap = new ImagesButton(UserInterface.textures.bttnMap, UserInterface.textures.iconMap, {onClick:onMap, tip: {title:Locale.__e('flash:1396961967928'), text:Locale.__e('flash:1428501372225')}});
			bttnMainGifts = new ImagesButton(UserInterface.textures.bttnGift, UserInterface.textures.iconGift, {onClick:onGift, tip: {title:Locale.__e('flash:1382952379798'), text:Locale.__e('flash:1428499741349')}});
			bttnCollection = new ImagesButton(UserInterface.textures.bttnCollection, UserInterface.textures.iconCollection, {onClick:onCollection, tip: {title:Locale.__e('flash:1382952379800'), text:Locale.__e('flash:1429170282650')}});
			bttnMainStock = new ImagesButton(UserInterface.textures.bttnStorage, UserInterface.textures.iconStorage, {onClick:onStock, tip: {title:Locale.__e('flash:1382952379767'), text:Locale.__e('flash:1428499670248')}});
			bttnMainShop = new ImagesButton(UserInterface.textures.bttnShop, UserInterface.textures.iconShop, {onClick:onShop, tip: {title:Locale.__e('flash:1382952379765'), text:Locale.__e('flash:1428499126465')}});
			bttnStop = new ImagesButton(UserInterface.textures.bttnStop, UserInterface.textures.iconStop, {onClick:onStop, ix:9, iy:9, tip: {title:Locale.__e('flash:1428567496794'), text:Locale.__e('flash:1428498579083')}});
			bttnCursors = new ImagesButton(UserInterface.textures.bttnCursor, UserInterface.textures.iconCursor, {onClick:onCursors, tip: {title:Locale.__e('flash:1382952379760'), text:Locale.__e('flash:1428498649978')}});
			
			bttnMainMap.x = leftBacking.x + 4;
			bttnMainMap.y = leftBacking.y + 24;
			bttnMainGifts.x = leftBacking.x + 6;
			bttnMainGifts.y = leftBacking.y + 88;
			bttnCollection.x = leftBacking.x + 85;
			bttnCollection.y = leftBacking.y + 99;
			bttnMainStock.x = rightBacking.x + 142;
			bttnMainStock.y = rightBacking.y + 22;
			bttnMainShop.x = rightBacking.x + 139;
			bttnMainShop.y = rightBacking.y + 91;
			bttnCursors.x = rightBacking.x + 75;
			bttnCursors.y = rightBacking.y + 104;
			bttnStop.x = rightBacking.x + 25;
			bttnStop.y = rightBacking.y + 113;
			
			homeBttn = new Button( {
					width:		180,
					height:		52,
					caption:	Locale.__e("flash:1382952379764"),
					fontSize:	22,
					multiline:  true,
					bgColor:	[0x96c9da,0x77a1af],
					borderColor:[0xffeede,0xbcbaa6],
					fontBorderColor: 0x426e7b,
					bevelColor:	[0xbadff1,0x4f8198]
			});
			homeBttn.scaleX = homeBttn.scaleY = 0.9;
			homeBttn.x = (friendsPanel.width - homeBttn.width) / 2;
			homeBttn.y = friendsPanel.y - 25;
			homeBttn.addEventListener(MouseEvent.CLICK, onRelocateHome);
			addChild(homeBttn);
			
			leftContainer.addChild(bttnMainMap);
			leftContainer.addChild(bttnMainGifts);
			leftContainer.addChild(bttnCollection);
			rightContainer.addChild(bttnMainStock);
			rightContainer.addChild(bttnMainShop);
			rightContainer.addChild(bttnCursors);
			rightContainer.addChild(bttnStop);
			
			giftsCounter = new IconCounter();
			leftContainer.addChild(giftsCounter);
			giftsCounter.x = bttnMainGifts.x + 42;
			giftsCounter.y = bttnMainGifts.y  - 4;
			
			setGiftsCount(App.user.gifts.length);
			
			drawTextOnBttn(Locale.__e('flash:1396961967928'), bttnMainMap);	// Карта - flash:1396961967928
			drawTextOnBttn(Locale.__e('flash:1382952379798'), bttnMainGifts);	// Подарки - flash:1382952379798
			drawTextOnBttn(Locale.__e('flash:1382952379800'), bttnCollection);	// Коллекции - flash:1382952379800
			drawTextOnBttn(Locale.__e('flash:1382952379765'), bttnMainShop);	// Магазин - flash:1382952379765
			drawTextOnBttn(Locale.__e('flash:1382952379767'), bttnMainStock);	// Склад - flash:1382952379767
			
			collectionCounter = new IconCounter();
			leftContainer.addChild(collectionCounter);
			collectionCounter.x = bttnCollection.x + 38;
			collectionCounter.y = bttnCollection.y  - 4;
			
			setCollectionCount(CollectionWindow.count);
			
			// Guest
			rightGuestContainer = new Sprite();
			addChild(rightGuestContainer);
			
			rightGuestBacking = new Bitmap(UserInterface.textures.backingRightGuest);
			rightGuestBacking.x = -rightGuestBacking.width + 1;
			rightGuestBacking.y = -rightGuestBacking.height + 1;
			rightGuestContainer.addChild(rightGuestBacking);
			
			bttnMainHome = new ImagesButton(Window.textures.homeBttn, null, {onClick:onHome});
			bttnMainHome.x = rightGuestBacking.x + 87;
			bttnMainHome.y = rightGuestBacking.y + 39;
			rightGuestContainer.addChild(bttnMainHome);
			
			var homeBttnText:TextField = Window.drawText(Locale.__e('flash:1382952379764'), {
				width:			bttnMainHome.width,
				textAlign:		'center',
				fontSize:		32,
				color:			0xFFFFFF,
				borderColor:	0x631d0b,
				shadowSize:		2
			});
			homeBttnText.y = (bttnMainHome.height - homeBttnText.height) / 2 + 2;
			bttnMainHome.addChild(homeBttnText);
			
			
			bttnExpHome = new ImagesButton(Window.textures.homeBttn, null, {onClick:onExpHome});
			bttnExpHome.x = 20;
			bttnExpHome.y = App.self.stage.stageHeight - bttnExpHome.height - 20;
			addChild(bttnExpHome);
			
			var expBttnText:TextField = Window.drawText(Locale.__e('flash:1382952379764'), {
				width:			bttnExpHome.width,
				textAlign:		'center',
				fontSize:		32,
				color:			0xFFFFFF,
				borderColor:	0x631d0b,
				shadowSize:		2
			});
			expBttnText.y = (bttnExpHome.height - expBttnText.height) / 2 + 2;
			bttnExpHome.addChild(expBttnText);
			bttnExpHome.visible = false;
			
			bttnExpHelp = new ImagesButton(Window.texture('interHelpBttn'), null, { onClick:onHelp } );
			bttnExpHelp.x = bttnExpHome.x + bttnExpHome.width + 10;
			bttnExpHelp.y = bttnExpHome.y;
			addChild(bttnExpHelp);
			bttnExpHelp.visible = false;
			
			bttnExpMove = new ImagesButton(UserInterface.textures.bttnCursor, UserInterface.textures.cursorIconMove, {onClick:onMoveCursor, tip:{title:Locale.__e('flash:1382952379760'), text:Locale.__e('flash:1428498649978')}});
			bttnExpMove.x = rightBacking.x + 75;
			bttnExpMove.y = rightBacking.y + 104;
			rightContainer.addChild(bttnExpMove);
			bttnExpMove.visible = false;
			
			bttnExpStock = new ImagesButton(UserInterface.textures.bttnShop, UserInterface.textures.iconStorage, {onClick:/*onShop*/onMiniStock, tip: {title:Locale.__e('flash:1382952379767'), text:Locale.__e('flash:1428499670248')}});
			bttnExpStock.x = rightBacking.x + 139;
			bttnExpStock.y = rightBacking.y + 91;
			rightContainer.addChild(bttnExpStock);
			bttnExpStock.visible = false;
			drawTextOnBttn(Locale.__e('flash:1465302993851'), bttnExpStock);	// Палатка
			
			bttnExpDynamite = new ImagesButton(UserInterface.textures.bttnStorage, UserInterface.textures.interExpDynamiteIco, {onClick:onDynamite, tip: {title:Locale.__e('storage:911:title')/*, text:Locale.__e('flash:1428499670248')*/}});
			bttnExpDynamite.x = rightBacking.x + 142;
			bttnExpDynamite.y = rightBacking.y + 22;
			rightContainer.addChild(bttnExpDynamite);
			bttnExpDynamite.visible = false;
			drawTextOnBttn(Locale.__e('storage:911:title'), bttnExpDynamite);	// Динамит
			
			
			bttnGuestStop = new ImagesButton(UserInterface.textures.bttnStop, UserInterface.textures.iconStop, {onClick:onStop, ix:9, iy:9});
			bttnGuestStop.x = rightGuestBacking.x + 35;
			bttnGuestStop.y = rightGuestBacking.y + 63;
			rightGuestContainer.addChild(bttnGuestStop);
			
			// Cursors
			drawCursorPanel();
			
			friendsPanel.visible = true;
			leftContainer.visible = true;
			rightContainer.visible = true;
			rightGuestContainer.visible = false;
			
			if (App.user.worldID == Travel.KLIDE_HOUSE) homeBttn.visible = true;
			else homeBttn.visible = false;
			
			objects.push(leftContainer, rightContainer, rightGuestContainer, friendsPanel);
		}
		
		private function drawTextOnBttn(text:String = '', bttn:ImagesButton = null):void {
			if (text.length == 0 || !bttn) return;
			
			var textLabel:TextField = Window.drawText(text, {
				autoSize:		'left',
				color:			0xffffff,
				borderColor:	0x5d411e,
				fontSize:		16,
				borderSize:		2,
				filters:		[new DropShadowFilter(2, 90, 0x5d411e, 1, 0, 0)]
			});
			textLabel.x = (bttn.width - textLabel.width) / 2;
			textLabel.y = bttn.height - textLabel.height;
			bttn.addChild(textLabel);
		}
		
		private function fillBySectors(container:Sprite, bitmapData:BitmapData, sector:int = 20):void {
			var pos:int = 0;
			while (pos < bitmapData.width) {
				var lowestZero:int = bitmapData.height;
				for (var cell:int = 0; cell < sector; cell++) {
					for (var i:int = 0; i < bitmapData.height; i++) {
						if (bitmapData.getPixel(pos + cell, i) > 0 && i < lowestZero)
							lowestZero = i;
					}
				}
				
				var tempBitmapData:BitmapData = new BitmapData(sector, bitmapData.height - lowestZero, true);
				tempBitmapData.copyPixels(bitmapData, new Rectangle(pos, lowestZero, sector, bitmapData.height - lowestZero), new Point(0, 0));
				
				var tempBitmap:Bitmap = new Bitmap(tempBitmapData);
				tempBitmap.x = pos;
				tempBitmap.y = lowestZero;
				container.addChild(tempBitmap);
				
				pos += sector;
				
				if (pos + sector > bitmapData.width)
					sector = bitmapData.width - pos;
			}
		}
		
		public function resize():void {
			leftContainer.y = App.self.stage.stageHeight;
			rightContainer.y = App.self.stage.stageHeight;
			rightGuestContainer.y = App.self.stage.stageHeight;
			
			friendsPanel.y = App.self.stage.stageHeight;
			
			if (App.ui.mode == UserInterface.OWNER) {
				leftContainer.x = 0;
				rightContainer.x = App.self.stage.stageWidth;
				rightGuestContainer.x = App.self.stage.stageWidth + rightGuestContainer.width;
				
				friendsPanel.x = leftContainer.width - 25;
				friendsPanel.resize(App.self.stage.stageWidth - (leftContainer.width - 25) - (rightContainer.width - 25));
			}else if (App.ui.mode == UserInterface.GUEST){
				leftContainer.x = -leftContainer.width;
				rightContainer.x = App.self.stage.stageWidth + rightContainer.width;
				rightGuestContainer.x = App.self.stage.stageWidth;
				
				friendsPanel.x = 0;
				friendsPanel.resize(App.self.stage.stageWidth - (rightGuestContainer.width - 20));
			}
			
			homeBttn.x = (rightContainer.x - leftContainer.width) / 2;
			homeBttn.y = friendsPanel.y - friendsPanel.height - 40;
			
			bttnExpHome.y = App.self.stage.stageHeight - bttnExpHome.height - 20;
			bttnExpHelp.x = bttnExpHome.x + bttnExpHome.width + 10;
			bttnExpHelp.y = bttnExpHome.y;
		}
		
		private function onRelocateHome(e:MouseEvent):void {
			if (homeBttn.mode == Button.DISABLED) return;
			
			if (App.user.worldID != User.HOME_WORLD) {
				Travel.goTo(User.HOME_WORLD);
				homeBttn.visible = false;
			}
		}
		
		public function showHomeButton(value:Boolean = true):void {
			homeBttn.visible = value;
		}
		
		private var res:Array = [];
		private var resSID:int;
		private var showResHelp:Boolean = false;
		public function showResourceHelp(show:Boolean, sid:int = 1928, icon:String = 'SearchMaterialsIcon'):void {
			res = Map.findUnits([sid]);
			showResHelp = show;
			if (bttnResHelp) {
				if (res.length == 0) {
					bttnResHelp.visible = false;
				} else bttnResHelp.visible = show;
				return;
			}
			
			if (res.length == 0) return;
			
			resSID = sid;			
			Load.loading(Config.getImageIcon('help',icon), function(data:*):void {
				bttnResHelp = new ImagesButton(data.bitmapData);
				
				bttnResHelp.visible = showResHelp;
				leftContainer.addChild(bttnResHelp);
				bttnResHelp.x = bttnCollection.x;
				bttnResHelp.y = bttnCollection.y - bttnResHelp.height - 15;
				bttnResHelp.addEventListener(MouseEvent.CLICK, onResHelp);
			});
		}
		
		private function onResHelp(e:MouseEvent):void {
			if (!resSID) return;
			var res:Array = Map.findUnits([resSID]);			
			if (res.length == 0) {
				var wid:int;
				var world:Object;
				var bSID:String;
				for (wid = 0; wid < App.user.lands.length; wid++) {				
					world = App.data.storage[App.user.lands[wid]];
					if (!world.hasOwnProperty('stacks')) continue;
					for (bSID in world.stacks) {
						if (resSID == world.stacks[bSID]) {							
							Window.closeAll();
							TravelWindow.show( {
								find:App.user.lands[wid],
								popup:true
							});
							return;
						}
					}
				}
				
				var text:String = Locale.__e('flash:1382952379745');
				if (resSID == 2395) text = Locale.__e('flash:1471506015466');
				new SimpleWindow( {
					text:text,
					title:Locale.__e('flash:1382952380254'),
					popup:true
				}).show();
				return;
			}
			
			App.map.focusedOn(res[int(Math.random() * res.length)], true);
		}
		
		public function addCommunityButton():void {	
			if (bttnCommunity != null) {
				return;
			}
			
			bttnCommunity = new ImagesButton(UserInterface.textures.community, null, {tip: {title:Locale.__e('flash:1382952380109')}});
			bttnCommunity.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void {
				new GroupWindow().show();
			});
			
			bttnCommunity.x = rightBacking.x + 136;
			bttnCommunity.y = rightBacking.y - bttnCommunity.height * 2;
			rightContainer.addChild(bttnCommunity);
		}
		
		public function addFreebie():void {
			if (bttnFreebie != null) {
				return;
			}
			
			var sp:Sprite = new Sprite();
			var bmp:Bitmap = new Bitmap(UserInterface.textures.freebyBttn);
			var pic:Bitmap = new Bitmap();
			var txt:TextField = Window.drawText(Locale.__e('flash:1382952380285'), {
				color:    		0xffffff,
				borderColor:    0x3b4a09,
				fontSize:       16,
				multiline:		true,
				autosize:		'center'
			});
			txt.wordWrap =  true;
			txt.width = txt.textWidth + 5;
			txt.x = (bmp.width - txt.textWidth) / 2;
			txt.y = bmp.height - txt.textHeight;
			sp.addChild(bmp);
			sp.addChild(pic);
			sp.addChild(txt);
			if (txt.textWidth > sp.width) sp.width = txt.textWidth;
			
			Load.loading(Config.getIcon(App.data.storage[Stock.FANT].type, App.data.storage[Stock.FANT].preview), function(data:Bitmap):void {
				pic.bitmapData = data.bitmapData;
				pic.scaleX = pic.scaleY = 0.6;
				pic.x = (bmp.width - pic.width) / 2;
				pic.y = (bmp.height - pic.height) / 2;
				pic.smoothing = true;
				var bmd:BitmapData = new BitmapData(sp.width, sp.height, true, 0xffffff);
				bmd.draw(sp);
				
				bttnFreebie = new ImagesButton(bmd, null, {tip: { title:Locale.__e('award:1:title')}} );
				
				if(App.user.freebie){
					bttnFreebie.settings['ID'] = App.user.freebie.ID || 0;
				}
				bttnFreebie.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void {
					bttnFreebie.hideGlowing();
					bttnFreebie.hidePointing();
					onFreebie(e);
				});
				
				bttnFreebie.x = rightBacking.x + 130;
				bttnFreebie.y = rightBacking.y - bttnFreebie.height + 5;
				rightContainer.addChild(bttnFreebie);
			});
		}
		
		public function hideFreebie():void {
			removeChild(bttnFreebie);
			bttnFreebie.removeEventListener(MouseEvent.CLICK, onFreebie);
			bttnFreebie = null;
		}
		
		// Buttons click
		public function onFreebie(e:MouseEvent):void {
			changeCursorPanelState(true);
			
			if (!App.USE_NEW_FREEBIE) {
				new FBFreebieWindow().show();
			}
			else {
				if (NewFreebieModel.instance.isNewFreebieAvailable)
					new NewFreebieWindow({ ID:e.currentTarget.settings.ID }).show();
				else 
					new FBFreebieWindow().show();
			}
		}
		
		public function onMap():void {
			changeCursorPanelState(true);
			TravelWindow.show({navigateTo:App.user.worldID});			
		}
		public function onGift():void {
			changeCursorPanelState(true);
			new FreeGiftsWindow().show();
		}
		public function onCollection():void {
			changeCursorPanelState(true);
			new CollectionWindow().show();
		}
		public function onStock():void {
			changeCursorPanelState(true);
			new StockWindow().show();
		}
		public function onMiniStock():void {
			changeCursorPanelState(true);
			new StockWindow({mode:StockWindow.MINISTOCK}).show();
		}
		public function onShop():void {
			changeCursorPanelState(true);
			ShopWindow.show();
			cancelActions();
		}
		public function onStop():void {
			changeCursorPanelState(true);
			App.user.onStopEvent();
			cancelActions();
		}
		public function onCursors():void {
			if (!cancelActions()) {
				changeCursorPanelState();
				App.self.addEventListener(AppEvent.ON_MOUSE_UP, onCursorsPanelHide);
			}
		}
		public function onDynamite():void {
			var cont:Array = PurchaseWindow.createContent('Energy', { view:'w_little_dinamite0' } );
			new PurchaseWindow( {
				width:620,
				itemsOnPage:cont.length,
				content:cont,
				title:Locale.__e('storage:911:title'),
				fontBorderColor:0xd49848,
				shadowColor:0x553c2f,
				shadowSize:4,
				hasDescription:true,
				description:Locale.__e('flash:1442409835783'),
				popup: true,
				callback:function(sID:int):void {
					var object:* = App.data.storage[sID];
					App.user.stock.add(sID, object);
				}
			}).show();
		}
		
		private function onCursorsPanelHide(e:AppEvent):void {
			changeCursorPanelState(true);
		}		
		
		public function cancelActions():Boolean {
			var cancel:Boolean = false;
			
			if (App.map.moved != null) {
				App.map.moved.previousPlace();
				cancel = true;
			}
			
			if (Cursor.material) {
				Field.clearBoost();
				Cursor.material = 0;
				cancel = true;
			}
			
			if (Cursor.image) {
				Cursor.image = null;
				cancel = true;
			}
			
			if (ShopWindow.currentBuyObject.type != null) {
				ShopWindow.currentBuyObject.type = null;
				ShopWindow.currentBuyObject.sid = 0;
				cancel = true;
			}
			
			if (Cursor.type != 'default') {
				Cursor.type = "default";
				cancel = true;
			}
			
			if (AnimalIcon.multiClickState)
				cancel = true;
			
			AnimalIcon.resetMultiClick();
			
			return cancel;
		}
		
		private function onHome():void {
			var targetWorld:int = (App.owner && App.user.worlds.hasOwnProperty(App.owner.worldID)) ? App.owner.worldID : User.HOME_WORLD;
			Travel.goHome();
		}
		
		private function onExpHome():void {
			if (((App.user.ministock.hasOwnProperty('items')) ? (ShipWindow.countMinistock == ShipWindow.limitMinistock) : 0) || !User.inExpedition) {
				Travel.goHome();
			}else {
				if(User.inExpedition){
					new SimpleWindow( {
						title:Locale.__e('flash:1465481680863'),
						text:Locale.__e('flash:1465481614368'),								
						hasTitle:true,
						label:SimpleWindow.ATTENTION,
						textSize:(App.isSocial('AI','YB','MX','GN')) ? 28 : 24,
						dialog:true,
						expImg:true,
						height:300,
						confirm:function():void {
							Travel.goHome();
						}
					}).show();
				}
			}		 
		}
		
		private function onHelp():void {
			new InfoWindow( {qID:'expedition' + String(App.user.worldID)} ).show();
		}
		
		public function setCollectionCount(value:int):void {
			if (value < 0) value = 0;
			collectionCounter.count = value;
		}
		
		public function setGiftsCount(value:int):void {
			if (value < 0) value = 0;
			giftsCounter.count = value;
		}
		
		
		// Cursors
		private function drawCursorPanel():void {
			cursorPanel = new Sprite();
			cursorPanel.alpha = 0.2;
			cursorPanel.scaleY = 0.2;
			
			var backing:Bitmap = new Bitmap(Window.textures.cursorMenuBacking, 'auto', true);
			backing.x = -backing.width / 2;
			backing.y = -backing.height;
			cursorPanel.addChild(backing);
			
			var bitmapDataBacking:BitmapData = new BitmapData(50, 50, true, 0x00000000);
			var moveCursor:ImagesButton = new ImagesButton(bitmapDataBacking, UserInterface.textures.cursorIconMove, {onClick:onMoveCursor});
			var removeCursor:ImagesButton = new ImagesButton(bitmapDataBacking, UserInterface.textures.cursorIconDelete, {onClick:onRemoveCursor});
			var stockCursor:ImagesButton = new ImagesButton(bitmapDataBacking, UserInterface.textures.cursorIconStorage, {onClick:onStockCursor});
			var rotateCursor:ImagesButton = new ImagesButton(bitmapDataBacking, UserInterface.textures.cursorIconRotare, {onClick:onRotateCursor});
			
			cursorPanel.addChild(stockCursor);
			stockCursor.x = backing.x + 4;
			stockCursor.y = backing.y + 9;
			stockCursor.tip =  function():Object { return { title:Locale.__e("flash:1382952379772") }; }
			
			cursorPanel.addChild(rotateCursor);
			rotateCursor.x = backing.x + 4;
			rotateCursor.y = backing.y + 62;
			rotateCursor.tip =  function():Object {return {title:Locale.__e("flash:1382952379773")};}
			
			cursorPanel.addChild(moveCursor);
			moveCursor.x = backing.x + 4;
			moveCursor.y = backing.y + 115;
			moveCursor.tip =  function():Object { return { title:Locale.__e("flash:1382952379775") }; }
			
			cursorPanel.addChild(removeCursor);
			removeCursor.x = backing.x + 4;
			removeCursor.y = backing.y + 168;
			removeCursor.tip =  function():Object {return {title:Locale.__e("flash:1382952379774")};}
		}
		private function onMoveCursor():void {
			Cursor.type = "move";
			changeCursorPanelState(true);
		}
		private function onStockCursor():void {
			Cursor.type = "stock";
			Cursor.toStock = true;
			changeCursorPanelState(true);
		}
		private function onRotateCursor():void {
			Cursor.type = "rotate";
			changeCursorPanelState(true);
		}
		private function onRemoveCursor():void {
			Cursor.type = "remove";
			changeCursorPanelState(true);
		}
		
		// Cursor panel
		private var cursorPanelState:Boolean = false;
		private var cursorPanelTween:TweenLite;
		public function changeCursorPanelState(hide:Boolean = false):void {
			if (hide && !cursorPanelState) return;
			
			cursorPanelState = !cursorPanelState;
			cursorPanelRedraw();
		}
		private function cursorPanelRedraw():void {
			if (cursorPanelTween) {
				cursorPanelTween.kill();
				cursorPanelTween = null;
			}
			
			cursorPanel.x = bttnCursors.x + bttnCursors.width / 2;
			cursorPanel.y = bttnCursors.y - 4;
			
			if (cursorPanelState) {
				if (!rightContainer.contains(cursorPanel))
					rightContainer.addChild(cursorPanel);
				
				TweenLite.to(cursorPanel, 0.1, { alpha:1, scaleY:1, onComplete:function():void {
					cursorPanelTween = null;
				}});
			}else {
				TweenLite.to(cursorPanel, 0.1, { alpha:0.2, scaleY:0.2, onComplete:function():void {
					cursorPanelTween = null;
					if (rightContainer.contains(cursorPanel)) rightContainer.removeChild(cursorPanel);
				}});
			}
		}
		
		
		//
		public function hide():void {
			for (var i:int = 0; i < objects.length; i++) {
				objects[i].visible = false;
			}
		}
		public function show(state:int = 0):void {
			if (state == UserInterface.OWNER) {
				friendsPanel.visible = true;
				leftContainer.visible = true;
				rightContainer.visible = true;
				rightGuestContainer.visible = false;
			}else if (state == UserInterface.GUEST) {
				friendsPanel.visible = true;
				leftContainer.visible = false;
				rightContainer.visible = false;
				rightGuestContainer.visible = true;
			}else {
				friendsPanel.visible = false;
				leftContainer.visible = false;
				rightContainer.visible = false;
				rightGuestContainer.visible = false;
			}
			
			resize();
		}
		
		public function showExpeditionPanel(show:Boolean = true):void 
		{
			friendsPanel.visible = !show;
			if (bttnFreebie) bttnFreebie.visible = !show;
			if (bttnCommunity) bttnCommunity.visible = !show;
			
			leftBacking.visible = !show;
			bttnMainMap.visible = !show;
			bttnMainGifts.visible = !show;
			bttnCollection.visible = !show;
			collectionCounter.visible = !show;
			giftsCounter.visible = !show;
			bttnCursors.visible = !show;
			bttnMainShop.visible = !show;
			bttnMainStock.visible = !show;
			
			bttnExpHome.visible = show;
			bttnExpHelp.visible = show;
			bttnExpMove.visible = show;
			bttnExpStock.visible = show;
			bttnExpDynamite.visible = show;
			
			if (App.ui.upPanel.eventIcon) App.ui.upPanel.eventIcon.visible = !show;
			
			if (App.user.worldID == Travel.DEEP_JOUNGLE) bttnExpHelp.visible = false;
			
			if (bttnExpHelp.visible && App.user.worldID != Travel.DEEP_JOUNGLE) {
				var save:Boolean = false;
				if (App.user.settings.hasOwnProperty('infExp1')) {
					var obj:Object = App.user.settings.infExp1;
					var count:int = Numbers.countProps(obj);
					if (count >= 21) return;
					
					var i:int = 0;
					for each (var item:Object in obj) {
						if (item.time < App.nextMidnight) {
							i++;
						}
					}
					if (i < 3) save = true;
					else return;
				}else {
					save = true;
				}
				
				if (save) {
					if (App.user.settings.hasOwnProperty('infExp1')) {
						var saveObj:Object = App.user.settings.infExp1;
						var saveCount:int = Numbers.countProps(saveObj);
						saveObj[saveCount + 1] = {'time':App.time};
						App.user.storageStore('infExp1', saveObj, true);
					}else {
						var sv:Object = { };
						sv['1'] = {'time':App.time};
						App.user.storageStore('infExp1', sv, true);
					}
					
					setTimeout(function():void {
						onHelp();
					}, 3000);
				}
			}
		}
		
		private function hideMove(object:Sprite):void {
			var params:Object;
			if (object == friendsPanel) {
				params = { y:App.self.stage.stageHeight + friendsPanel.height, onCompleteParams:[friendsPanel], onComplete:onHideMoveComplete };
			}else if (object == leftContainer) {
				params = { x:- leftContainer.width, onCompleteParams:[leftContainer], onComplete:onHideMoveComplete };
			}else if (object == rightContainer) {
				params = { x:App.self.stage.stageWidth + rightContainer.width, onCompleteParams:[rightContainer], onComplete:onHideMoveComplete };
			}else if (object == rightGuestContainer) {
				params = { x:App.self.stage.stageWidth + rightGuestContainer.width, onCompleteParams:[rightGuestContainer], onComplete:onHideMoveComplete };
			}else {
				object.visible = false;
			}
			
			if (params)
				TweenLite.to(object, 0.2, params);
		}
		private function onHideMoveComplete(... args):void {
			args[0].visible = false;
		}
		
		private function showMove(object:Sprite):void {
			object.visible = true;
			var params:Object;
			if (object == friendsPanel) {
				params = { y:App.self.stage.stageHeight, ease:Back.easeOut, onCompleteParams:[friendsPanel], onComplete:onShowMoveComplete };
			}else if (object == leftContainer) {
				params = { x:0, ease:Back.easeOut, onCompleteParams:[leftContainer], onComplete:onShowMoveComplete };
			}else if (object == rightContainer) {
				params = { x:App.self.stage.stageWidth, ease:Back.easeOut, onCompleteParams:[rightContainer], onComplete:onShowMoveComplete };
			}else if (object == rightGuestContainer) {
				params = { x:App.self.stage.stageWidth, ease:Back.easeOut, onCompleteParams:[rightGuestContainer], onComplete:onShowMoveComplete };
			}
			
			if (params)
				TweenLite.to(object, 0.2, params);
		}
		private function onShowMoveComplete(... args):void {
			//
		}
		
		public function hideFriendsPanel():void { }
		
		public function showOwnerPanel():void { }
		
		public function showGuestPanel():void { }
		
		
		private var timeToPostShow:int = 500;
		private var postInterval:int;
		private var postPreloader:PostPreloader;
		private var title:TextField = null;
		public function addPostPreloader():void {
			clearInterval(postInterval);
			postInterval = setInterval(function():void{
			removePostPreloader();
			postPreloader = new PostPreloader();
			App.self.addChild(postPreloader);
			postPreloader.x = 0;
			postPreloader.y = App.self.stage.stageHeight - postPreloader.height + 8;
			}, timeToPostShow);
		}
		
		public function removePostPreloader():void {
			clearInterval(postInterval);
			if (postPreloader && postPreloader.parent)
				postPreloader.parent.removeChild(postPreloader);
				
			postPreloader = null;
		}
		
		
		public function onInviteEvent(e:MouseEvent = null):void {
			ExternalApi.apiInviteEvent();
		}
		
		public function update():void {
			setGiftsCount(App.user.gifts.length);
		}
		
	}
}
