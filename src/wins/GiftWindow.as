package wins {
	
	import adobe.utils.CustomActions;
	import api.ExternalApi;
	import buttons.Button;
	import buttons.ChangedButton;
	import buttons.CheckboxButton;
	import buttons.ImageButton;
	import buttons.MenuButton;
	import buttons.MixedButton;
	import buttons.MoneyButton;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.CapsStyle;
	import flash.display.LineScaleMode;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.StageDisplayState;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.filters.BevelFilter;
	import flash.filters.GradientBevelFilter;
	import flash.text.TextField;
	import flash.filters.BlurFilter;
	import flash.filters.GlowFilter;
	import flash.text.TextFieldType;
	import flash.ui.Mouse;
	import wins.elements.SearchFriendsPanel;

	public class GiftWindow extends Window {
		public static const FREE_GIFTS:int 	= 1;
		public static const MATERIALS:int 	= 2;
		public static const FRIENDS:int 	= 3;
		public static const ALLFRIENDS:int 	= 5;
		public static const COLLECTIONS:int = 4;
		
		private var messText:TextField;
		private var items:Array = [];
		
		private var paginatorUp:Paginator;
		private var paginatorDown:Paginator;
		public var seachPanel:SearchFriendsPanel;
		public var icon:Icon;
		
		private var filterBttn:Button;
		private var filterSendBttn:Button;
		private var sendAllBttn:Button;
		public var sendBttn:Button;
		
		private var bttnAllFriends:Button;
		private var bttnFriendsInGame:Button;
		
		public var menuBttn1:Button;
		public var menuBttn2:Button;
		public var menuBttn3:Button;
		public var menuBttns:Array = [];
		
		public var wishListFilter:Boolean = false;
		public var wishList:WishListPopUp = null;
		
		public var receivers:Array = [];
		
		private var checkBox:CheckboxButton;
		
		/**
		 * Конструктор
		 * @param	settings	настройки
		 */ 
		public function GiftWindow(settings:Object = null) {
			//App.social = 'FB';
			if (settings == null) {
				settings = new Object();
			}
			
			settings["title"]			= Locale.__e("flash:1382952380132");
			settings["width"]			= 560;
			settings["height"] 			= 610;
			settings["hasPaginator"] 	= false;
			settings["multiline"] 		= true;
			settings["textLeading"] 	= -6;
			
			if (settings.hasOwnProperty('forcedClosing'))
				settings["forcedClosing"] = settings.forcedClosing;
			else
				settings["forcedClosing"] = true;
			
			settings["iconLock"] 		= settings.iconLock || false;
			settings['background']      = 'alertBacking';
			//settings["iconMode"] 		= GiftWindow.MATERIALS;
			//settings["itemsMode"] 	= GiftWindow.FRIENDS;
			settings['shadowColor'] 	= 0x513f35;
			settings['shadowSize'] 		= 4;
			
			wishListFilter = settings['wishListFilter'] || false;
			
			super(settings);
		}
		
		private function initContent():void {
			initContentIcon();
			initContentItems();
		}
		
		private function initContentItems():void {
			settings.itemsContent 	= [];
			var sID:*;
			var i:int = 0;
			var index:uint = 0;
			
			// ITEMS
			switch(settings.itemsMode) {
				case GiftWindow.MATERIALS:
					for (sID in App.user.stock.data) {
						if (App.user.stock.data[sID] > 0 && [0, 1].indexOf(App.data.storage[sID].mtype) != -1)
							settings.itemsContent.push(sID);
					}
					break;
					
				case GiftWindow.COLLECTIONS:
					for (sID in App.user.stock.data) {
						if (App.user.stock.data[sID] > 0 && App.data.storage[sID].mtype == 4)
							settings.itemsContent.push(sID);
					}
					break;	
					
				case GiftWindow.FREE_GIFTS:
					for (sID in App.data.storage) {
						if (App.data.storage[sID].free == 1 && App.data.storage[sID].type == 'Material')
							if (User.inUpdate(sID))
								settings.itemsContent.push(sID);
					}
					break;
					
				case GiftWindow.FRIENDS:
					if (settings.iconMode == GiftWindow.FREE_GIFTS) {
						var id:*;
						for (id in App.user.friends.data) {
							if (settings.hasOwnProperty('uid') && settings.uid != id) continue;
							if (id && id != "1" && Gifts.canTakeFreeGift(id) == true) {
								settings.itemsContent.push(App.user.friends.data[id]);
							}
						}
					} else {
						for (id in App.user.friends.data) {
							if (settings.hasOwnProperty('uid') && settings.uid != id) continue;
							if (id && id != "1") {
								settings.itemsContent.push(App.user.friends.data[id]);
							}
						}
					}
					/*var _L:int = App.user.friends.keys.length;
					if (settings.iconMode == GiftWindow.FREE_GIFTS) {
						for (i = 0; i < _L; i++) {
							if (settings.hasOwnProperty('uid') && settings.uid != App.user.friends.keys[i].uid) continue;
							if (App.user.friends.keys[i].uid && App.user.friends.keys[i].uid != "1" && Gifts.canTakeFreeGift(App.user.friends.keys[i].uid) == true) {
								settings.itemsContent.push(App.user.friends.keys[i]);
							}
						}
					} else {
						for (i = 0; i < _L; i++) {
							if (settings.hasOwnProperty('uid') && settings.uid != App.user.friends.keys[i].uid) continue;
							if(App.user.friends.keys[i].uid && App.user.friends.keys[i].uid != "1") {
								settings.itemsContent.push(App.user.friends.keys[i]);
							}
						}
					}*/
					break;
					
				case GiftWindow.ALLFRIENDS:
					for (var fid:String in App.network.otherFriends) {
						settings.itemsContent.push(App.network.otherFriends[fid]);
					}	
					break;
			}
		}
		
		private function initContentIcon():void {
			settings.iconContent 	= [];
			var sID:*;
			var i:int = 0;
			var index:uint = 0;
			
			// ICON
			switch(settings.iconMode) {
				case GiftWindow.MATERIALS:
					for (sID in App.user.stock.data) {
						if (App.user.stock.data[sID] > 0 && [3,4,5].indexOf(App.data.storage[sID].mtype) == -1 && App.data.storage[sID].type == 'Material')
							if (sID != 686 && sID != 798 && sID != 911 && sID != 1255 && sID != Stock.SILVER_COIN)
								settings.iconContent.push(sID);
					}
					break;
				
				case GiftWindow.COLLECTIONS:
					for (sID in App.user.stock.data) {
						if (App.user.stock.data[sID] > 0 && App.data.storage[sID].mtype == 4)
							settings.iconContent.push(sID);
						}
					break;	
					
				case GiftWindow.FREE_GIFTS:
					for (sID in App.data.storage) {
						if (App.data.storage[sID].free == 1 && App.data.storage[sID].type == 'Material')
							if (User.inUpdate(sID))
								settings.iconContent.push(sID);
					}
					break;
					
				case GiftWindow.FRIENDS:
					var L:int = App.user.friends.keys.length;
					if (settings.itemsMode == GiftWindow.FREE_GIFTS) {
						for (i = 0; i < L; i++) {
							if (settings.hasOwnProperty('uid') && settings.uid != App.user.friends.keys[i].uid) continue;
							if (App.user.friends.keys[i].uid && App.user.friends.keys[i].uid != "1" && Gifts.canTakeFreeGift(App.user.friends.keys[i].uid) == true) {
								settings.iconContent.push(App.user.friends.keys[i]);
							}
						}
					} else {
						for (i = 0; i < L; i++) {
							if (settings.hasOwnProperty('uid') && settings.uid != App.user.friends.keys[i].uid) continue;
							if(App.user.friends.keys[i].uid && App.user.friends.keys[i].uid != "1"){
								settings.iconContent.push(App.user.friends.keys[i]);
							}
						}
					}
					settings.iconContent.unshift({level:App.user.friends.data[settings.uid].level, uid:settings.uid});
					break;	
			}
		}
		
		private function createMaterialsMenu():void
		{
			menuBttn1 = new Button({
				caption:Locale.__e("flash:1382952380112"),
				width:160,					
				height:58,	
				fontSize:24,
				type:FREE_GIFTS
			});
			
			menuBttn2 = new Button({
				caption:Locale.__e("flash:1382952380133"),
				width:160,					
				height:58,	
				fontSize:24,
				type:MATERIALS
			});
			
			menuBttn3 = new Button({
				caption:Locale.__e("flash:1382952379800"),
				width:160,					
				height:58,	
				fontSize:24,
				type:COLLECTIONS
			});
			
			menuBttns.push(menuBttn1);
			menuBttns.push(menuBttn2);
			menuBttns.push(menuBttn3);
			
			bodyContainer.addChild(menuBttn1);
			menuBttn1.x = 530;
			menuBttn1.y = 26;
			
			bodyContainer.addChild(menuBttn2);
			menuBttn2.x = 530;
			menuBttn2.y = 90;
			
			bodyContainer.addChild(menuBttn3);
			menuBttn3.x = 530;
			menuBttn3.y = 154;
			
			menuBttn1.addEventListener(MouseEvent.CLICK, onMenuClick);
			menuBttn2.addEventListener(MouseEvent.CLICK, onMenuClick);
			menuBttn3.addEventListener(MouseEvent.CLICK, onMenuClick);
			
			for each(var bttn:Button in menuBttns)
			{
				if (bttn.settings.type == settings.itemsMode)
				{
					bttn.dispatchEvent(new MouseEvent("click"));
				}
			}
		}
		
		private function onMenuClick(e:MouseEvent):void
		{
			if (e.currentTarget.mode == Button.DISABLED || e.currentTarget.mode == Button.ACTIVE) return;
			
			settings.itemsMode = e.currentTarget.settings.type;
			refreshContent();
			
			for each(var bttn:Button in menuBttns)
			{
				if (bttn.mode == Button.DISABLED) continue;
				bttn.state = Button.NORMAL;
				if (bttn.settings.type == settings.itemsMode)
				{
					bttn.state = Button.ACTIVE;
				}
			}
		}
		
		private function createBttns():void
		{
			var fontSize:int = 22;
			if (App.lang == 'jp') fontSize = 12;
			filterBttn = new Button({
				caption:Locale.__e("flash:1425392464722"),
				width:165,					
				height:45,	
				fontSize:fontSize,
				multiline:true,
				textAlign: "center",
				autoSize:	'center'
			});
			
			if (wishListFilter) {
				filterBttn.caption = Locale.__e('flash:1382952379718');
				filterBttn.textLabel.y -= 5;
			}else {
				filterBttn.textLabel.y -= 3;
			}
			
			filterSendBttn = new Button({
				caption:Locale.__e("flash:1460471017135"),
				fontSize:20,
				width:165,					
				height:45,	
				multiline:true
			});
			
			sendAllBttn = new Button({
				caption:Locale.__e("flash:1382952380136"),
				width:165,					
				height:45,	
				fontSize:24
			});
			
			if (settings.tutorial) {
				sendAllBttn.startGlowing();
				sendAllBttn.showPointing('top', 0, 0, sendAllBttn);
			}
			
			bttnAllFriends = new Button( {
				width:100,		
				fontSize : 20,
				offset : 20,
				icon : false,
				caption:Locale.__e("flash:1382952380139")
			});
			bttnAllFriends.visible = false;
			bttnFriendsInGame = new Button( {
				width:(App.SERVER == 'NK')?150:100,		
				fontSize : 20,
				offset : 20,
				icon : false,
				caption:Locale.__e("flash:1382952380138")
				
			});
			bttnFriendsInGame.visible = false;
			sendBttn = new Button({
				caption:Locale.__e("flash:1382952380137"),
				width:100,					
				height:48,	
				fontSize:20
			});
			
			bodyContainer.addChild(filterBttn);
			filterBttn.y = 15;
			
			if (settings.iconMode == GiftWindow.FREE_GIFTS)
				filterBttn.x = 252;
			else {
				seachPanel.y += 15;
				filterBttn.x = 252;
				filterBttn.y += 25;
			}
			
			filterBttn.x += 52;
			filterBttn.y += 34;
			
			bodyContainer.addChild(sendAllBttn);
			sendAllBttn.x = filterBttn.x;
			sendAllBttn.y = filterBttn.y + 50;
			
			bodyContainer.addChild(bttnAllFriends);
			
			bttnAllFriends.x = 280;
			bttnAllFriends.y = filterBttn.y + filterBttn.height + 12;
			
			bodyContainer.addChild(bttnFriendsInGame);
			
			bttnFriendsInGame.x = bttnAllFriends.x + bttnAllFriends.width + 12;;
			bttnFriendsInGame.y = bttnAllFriends.y;
			bttnFriendsInGame.state = Button.ACTIVE;
			settings.itemsMode = FRIENDS;
			
			bodyContainer.addChild(filterSendBttn);
			if (App.isSocial('FB')) filterSendBttn.visible = false;
			filterSendBttn.x = filterBttn.x;
			filterSendBttn.y = bttnFriendsInGame.y + bttnFriendsInGame.height /*+ 2*/;
			
			if (App.social == 'OK') {
				bttnFriendsInGame.visible = false;
				bttnAllFriends.visible = false;
			}
			if (App.SERVER == 'NK') {
				bttnAllFriends.visible = false;
				bttnFriendsInGame.x -= bttnAllFriends.width;
			}
			
			if(App.social == 'FB'){
				bodyContainer.addChild(sendBttn);
				sendBttn.x = (settings.width - sendBttn.width) / 2;
				sendBttn.y = settings.height - 170;
			}
			
			/*if(App.network.hasOwnProperty('otherFriends') && App.network['otherFriends'] != null){
				drawMenu();
			}*/
			
			filterSendBttn.state = Button.DISABLED;
			
			if (App.user.friends.keys.length - 1 <= Gifts.takedFreeGift.length)
				sendAllBttn.state = Button.DISABLED;
			
			bttnAllFriends.addEventListener(MouseEvent.CLICK, onAllFriends);
			bttnFriendsInGame.addEventListener(MouseEvent.CLICK, onFriendsInGame);
			sendAllBttn.addEventListener(MouseEvent.CLICK, onSendAllBttn);
			filterBttn.addEventListener(MouseEvent.CLICK, onFilterBttn);
			filterSendBttn.addEventListener(MouseEvent.CLICK, onFilterSendBttn);
			sendBttn.addEventListener(MouseEvent.CLICK, onSelectedSendBttn);
			
			sendBttn.state = Button.DISABLED;
			
			if (settings.iconMode != GiftWindow.FREE_GIFTS)
			{
				filterSendBttn.visible = false;
				sendAllBttn.visible = false;
			}
			
			if (App.social == 'FB' /*|| App.social == 'NK'*/) {
				bttnAllFriends.visible = false;
				bttnFriendsInGame.visible = false;
				sendAllBttn.visible = false;
				filterBttn.x = 317;
				filterBttn.y = 76;
				
				bodyContainer.addChild(sendBttn);
				sendBttn.x = (settings.width - sendBttn.width) / 2;
				sendBttn.y = settings.height - 150 + 70;
			}
		}
		
		private var countGiftsLeft:int;
		private var txtGiftsLeft:TextField;
		private function drawFreeGiftsCount():void
		{
			//var countBg:Sprite = new Sprite();
			//countBg.graphics.beginFill(0x000000, 1);
			//countBg.graphics.drawRoundRect(0, 0, 64, 56, 50, 50);
			//countBg.graphics.endFill();
			//countBg.x =	filterBttn.x + filterBttn.width + 14;
			//countBg.y = 22;
			var countBg:Bitmap = new Bitmap(Window.textures.questCheckmarkSlot);
			countBg.x =	filterBttn.x + filterBttn.width + 30;
			countBg.y = 25;
			countBg.scaleX = countBg.scaleY = 0.8;
			bodyContainer.addChild(countBg);
			
			var messTitle:TextField = Window.drawText(Locale.__e("flash:1393861373245"), {
					color:0xffffff,
					borderColor:0x6b3004,
					textAlign:"center",
					autoSize:"center",
					fontSize:20,
					textLeading:-6,
					multiline:true
				}
			);
			messTitle.wordWrap = true;
			messTitle.width = 80;
			messTitle.x = countBg.x + (countBg.width - messTitle.textWidth) / 2 - 10;
			messTitle.y = countBg.y - 33;
			bodyContainer.addChild(messTitle);
			
			txtGiftsLeft = Window.drawText("", {
					color:0xffffff,
					borderColor:0x6b3004,
					textAlign:"center",
					autoSize:"center",
					fontSize:32,
					textLeading:-6,
					multiline:true
				}
			);
			txtGiftsLeft.text = String(Gifts.freeGifts - Gifts.takedFreeGift.length);
			bodyContainer.addChild(txtGiftsLeft);
			txtGiftsLeft.x = countBg.x + (countBg.width - txtGiftsLeft.textWidth) / 2 - 2;
			txtGiftsLeft.y = countBg.y + 10;
		}
		
		public function updateFreeGifts():void
		{
			if (settings.iconMode == GiftWindow.FREE_GIFTS) {
				txtGiftsLeft.text = String(Gifts.freeGifts - Gifts.takedFreeGift.length);
			}
		}
		
		public var icons:Array = [];
		public function drawMenu():void {
			
			var menuSettings:Object = { };
			menuSettings[FRIENDS] 	= { order:1,	title:Locale.__e("flash:1382952380138") };
			menuSettings[ALLFRIENDS]= { order:2,	title:Locale.__e("flash:1382952380139") };
			
			var length:int = 0;
			for each(var bttn:Object in menuSettings) {
				length += bttn.title.length;
			}
			
			for (var item:* in menuSettings) {
				
				var settings:Object = menuSettings[item];
				settings['type'] = item;
				settings['onMouseDown'] = onMenuBttnSelect;
				settings['fontSize'] = 22;
				settings['offset'] = 20;
				settings['icon'] = false;
				
				icons.push(new MenuButton(settings));
			}
			icons.sortOn("order");
	
			var sprite:Sprite = new Sprite();
			
			var offset:int = 0;
			for (var i:int = 0; i < icons.length; i++)
			{
				if(i==0){
					icons[i].selected = true;
				}
				icons[i].x = offset;
				
				offset += icons[i].settings.width + 10;
				sprite.addChild(icons[i]);
			}
			bodyContainer.addChild(sprite);
			sprite.x = (this.settings.width - sprite.width) / 2 + 20;
			sprite.y = 210;
		}
		
		private function onFriendsInGame(e:MouseEvent):void 
		{
			if (bttnFriendsInGame.mode == Button.ACTIVE) return;
			
			bttnFriendsInGame.state = Button.ACTIVE;
			filterBttn.state = Button.NORMAL;
			bttnAllFriends.state = Button.NORMAL;
			settings.itemsMode = FRIENDS;
			refreshContent();
		}
		
		private function onAllFriends(e:MouseEvent):void 
		{
			if (bttnAllFriends.mode == Button.ACTIVE) return;
			
			bttnFriendsInGame.state = Button.NORMAL;
			filterBttn.state = Button.NORMAL;
			bttnAllFriends.state = Button.ACTIVE;
			settings.itemsMode = ALLFRIENDS;
			refreshContent();
		}
		
		private function onMenuBttnSelect(e:MouseEvent):void
		{
			e.currentTarget.selected = true;
			receivers = [];
			for each(var icon:MenuButton in icons) {
				icon.selected = false;
				if (icon.type == e.currentTarget.type) {
					icon.selected = true;
				}
			}
			
			//settings.iconMode = e.currentTarget.type;
			settings.itemsMode = e.currentTarget.type;
			if(settings.itemsMode == ALLFRIENDS){
				filterBttn.state = Button.DISABLED;
				if (settings.iconMode == FREE_GIFTS) {
					sendAllBttn.visible = false;
					filterSendBttn.visible = false;
				}
				
			} else {
				if (settings.iconMode == FREE_GIFTS) {
					sendAllBttn.visible = true;
					filterSendBttn.visible = true;
				}
				filterBttn.state = Button.NORMAL;
			}
			
			refreshContent();
			//setContentSection(e.currentTarget.type);
		}	
		
		private function onSendAllBttn(e:MouseEvent):void
		{
			if (e.currentTarget.mode == Button.DISABLED) return;
			
			var count:uint = /*App.user.friends.keys.length*/settings.itemsContent.length;// - Gifts.takedFreeGift.length;// - 1;
			
			new SimpleWindow( {
				title:Locale.__e("flash:1382952380140"),
				text:Locale.__e("flash:1382952380141",[icon.info.title, count]),
				label:SimpleWindow.MATERIAL,
				sID:icon.ID,
				dialog:true,
				popup:true,
				confirm:sendAllEvent
			}).show();
		}
		
		private function notifyFriends():Boolean
		{
			if (!checkBox) return false;
			if (checkBox.checked == 1) return true;
			else return false;
		}
		
		/**
		 * Отправляем вообще все друзьям кто еще не получил подарки
		 */
		private function sendAllEvent():void
		{
			var nextMidnight:uint = App.midnight + 24 * 3600;
			var receivers:Array = [];
			var L:int = settings.itemsContent.length;//App.user.friends.keys.length;
			
			//settings.itemsContent
			for (var i:int = 0; i < L; i++)
			{
				var uid:String = settings.itemsContent[i].uid;//App.user.friends.keys[i].uid;
				if (Gifts.takedFreeGift.indexOf(uid) == -1 && uid != "1")
				{
					receivers.push(uid);
					App.user.friends.data[uid]["gift"] = nextMidnight;
					Gifts.takedFreeGift.push(uid);
				}
			}
			
			Gifts.broadcast(icon.ID, receivers, Gifts.FREE, null, notifyFriends());
			refreshContent();
			//sendBttn.state = Button.DISABLED;
			
			paginatorUp.page++;
			paginatorUp.update();
			onUpChange();
			
			wishListFilter = false;
			onFilterBttn();
			
			if (settings.tutorial)
				close();
		}
		
		/**
		 * Отправляем по фильтру бесплатные
		 * @param	e
		 */
		private function onFilterSendBttn(e:MouseEvent, receivers:Array = null):void
		{
			if (e.currentTarget.mode == Button.DISABLED) return;
			var uid:String;
			var nextMidnight:uint = App.midnight + 24 * 3600;
			if(receivers == null){
				receivers = [];
				var L:int = settings.itemsContent.length;
				if (L == 0) return;
				var obj:Object = App.user.friends.data;
				for (var i:int = 0; i < L; i++)
				{
					uid = settings.itemsContent[i].uid;
					receivers.push(uid);
					App.user.friends.data[uid]["gift"] = nextMidnight;
					Gifts.takedFreeGift.push(uid);
				}
			}else {
				if(settings.itemsMode != ALLFRIENDS){
					for each(uid in receivers) {
						App.user.friends.data[uid]["gift"] = nextMidnight;
						Gifts.takedFreeGift.push(uid);
					}
				}
			}
			
			Gifts.broadcast(icon.ID, receivers, Gifts.FREE, null, notifyFriends());
			seachPanel.search(seachPanel.searchField.text);
			
			receivers = [];
			for each(var item:* in items) {
				if (item is FriendItem) {
					item.update();
				}
			}
			
			//if (settings.tutorial && !App.isSocial('OK', 'ML', 'FB', 'NK')){
				//new InviteLostFriendsWindow( { } ).show();
			//}
			
			//sendBttn.state = Button.DISABLED;
		}
		
		private function onSelectedSendBttn(e:MouseEvent):void
		{
			if (e.currentTarget.mode == Button.DISABLED) return;
			
			//Если подарок бесплатный
			if (settings.iconMode == FREE_GIFTS) {
				onFilterSendBttn(e, receivers);
				return;
			}
			//Если обычный
			App.user.stock.take(icon.ID, receivers.length);
			icon.change(icon.ID);
			
			Gifts.broadcast(icon.ID, receivers, Gifts.NORMAL, null, notifyFriends());
			seachPanel.search(seachPanel.searchField.text);
			
			if (icon.stockCountText.text == '0') {
				paginatorUp.page++;
				paginatorUp.update();
				onUpChange();
			}
			receivers = [];
			for each(var item:* in items) {
				if (item is FriendItem) {
					item.update();
				}
			}
			sendBttn.state = Button.DISABLED;
		}
		
		private function onFilterBttn(e:MouseEvent = null):void
		{		
			if (filterBttn.mode == Button.DISABLED) {
				return;
			}
			//filterBttn.textLabel.height = filterBttn.textLabel.textHeight + 4;
			
			receivers = [];
			
			wishListFilter = !wishListFilter;
			if (wishListFilter)
			{
				filterBttn.caption = Locale.__e("flash:1382952379718");
				bttnAllFriends.state = Button.NORMAL;
				bttnFriendsInGame.state = Button.NORMAL;
				filterSendBttn.state = Button.NORMAL;
				sendAllBttn.state = Button.DISABLED;
				filterBttn.textLabel.y -= 5;
			} else {
				filterBttn.caption = Locale.__e("flash:1425392464722");
				bttnAllFriends.state = Button.NORMAL;
				bttnFriendsInGame.state = Button.NORMAL;
				filterSendBttn.state = Button.DISABLED;
				sendAllBttn.state = Button.NORMAL;
				filterBttn.textLabel.y = filterBttn.bttnY;
				filterBttn.textLabel.y -= 3;
			}
			
			seachPanel.search(seachPanel.searchField.text);
			sendBttn.state = Button.DISABLED;
		}
		
		override public function drawBody():void {
			titleLabel.y = - 12;
			exit.x -= 5;
			exit.y -= 5;
			//exit.visible = false;
			
			createPaginators();
			initContent();
			
			if (settings.iconMode != FRIENDS && settings.iconMode != ALLFRIENDS) {
				var index:int = settings.iconContent.indexOf(settings.sID);
				paginatorUp.page = index;
			}
			if (settings.itemsMode == FRIENDS) {
				/*var length:int = settings.itemsContent.length;
				for (var i:int = 0; i < length; i++)
				{
					var order:int = Math.random() * length;
					settings.itemsContent[i]['order'] = order;
				}
				
				settings.itemsContent.sortOn('order');*/
				settings.itemsContent.sortOn(['level', 'uid']);
			}
			if (settings.itemsMode == ALLFRIENDS) {
				settings.itemsContent.sortOn('uid');
			}
			
			paginatorDown.itemsCount = settings.itemsContent.length;
			paginatorDown.update();
			paginatorUp.itemsCount = settings.iconContent.length;
			paginatorUp.update();
			
			drawBackings();
			
			addEventListener(WindowEvent.ON_AFTER_OPEN, onDownChange);
			addEventListener(WindowEvent.ON_AFTER_OPEN, onUpChange);
			
			seachPanel = new SearchFriendsPanel({
				win:this,
				callback:refreshContent
			});
			
			bodyContainer.addChild(seachPanel);
			seachPanel.x = 280-19;
			seachPanel.y = 144 - 139;
			
			seachPanel.bttnSearch.visible = false;
			
			icon = new Icon(this);
			bodyContainer.addChild(icon);
			icon.x = 75;
			icon.y = 0;
			
			if (settings.itemsMode != FRIENDS) {
				createMaterialsMenu();
			} else {
				createBttns();
			}
			
			createWishList();
			wantMoreFreeGifts();
			
			if(settings.find)
				seachPanel.search(settings.find, true);
				
				
			if (App.isSocial('YN','YB','MX','SP','AI')) return;
			
			checkBox = new CheckboxButton();
			checkBox.x = 120;
			checkBox.y = 164;
			checkBox.checked = 1;
			if (settings.iconMode != GiftWindow.FREE_GIFTS) {
				checkBox.x = 320;
				checkBox.y -= 10;
			}
			bodyContainer.addChild(checkBox);
		}
		
		public override function dispose():void
		{
			removeEventListener(WindowEvent.ON_AFTER_OPEN, onDownChange);
			removeEventListener(WindowEvent.ON_AFTER_OPEN, onUpChange);
			
			//messText.removeEventListener(Event.CHANGE, onInputEvent);
			//messText.removeEventListener(FocusEvent.FOCUS_IN, onFocusInEvent);
			//messText.removeEventListener(FocusEvent.FOCUS_OUT, onFocusOutEvent);
			
			if(sendAllBttn) sendAllBttn.removeEventListener(MouseEvent.CLICK, onSendAllBttn);
			
			for each(var item:* in items)	item.dispose();
			
			super.dispose();
			
			if (settings.tutorial && !App.isSocial('OK', 'FB', 'NK')){
				if (App.social == 'ML')
					ExternalApi.apiInviteEvent();
				//else
					//new InviteLostFriendsWindow( {desc:Locale.__e('flash:1407752973464'), tutorial:true } ).show();
			}
		}
		
		public function refreshContent(friends:Array = null):void
		{
			if (friends == null)
			{
				initContent();
			}
			else 
			{
				settings.itemsContent = friends;
			}
			
			if (settings.iconMode != FREE_GIFTS)
			{
				for (var i:int = 0; i < settings.itemsContent.length; i++) {
					settings.itemsContent[i]
				}
			}else if (settings.iconMode == GiftWindow.ALLFRIENDS){
				sendAllBttn.state = Button.DISABLED;
			}
			else
			{
				if(wishListFilter == false)	
					if (App.user.friends.keys.length - 1 <= Gifts.takedFreeGift.length) {
						
						sendAllBttn.state = Button.DISABLED;
					}
					else {
						
						sendAllBttn.state = Button.NORMAL;
					}
			}
			
			paginatorDown.itemsCount = settings.itemsContent.length;
			paginatorDown.update();
			onDownChange();
		}
		
		public function refreshIcon():void
		{
			initContentIcon();
			paginatorUp.itemsCount = settings.iconContent.length;
			paginatorUp.update();
			onUpChange();
			
			receivers = [];
			for each(var item:* in items) {
				if (item is FriendItem) {
					item.update();
				}
			}
			//update
		}
		
		public function blokItems(value:Boolean):void
		{
			var item:*;
			if (value)	for each(item in items) item.state = Window.ENABLED;
			else 		for each(item in items) item.state = Window.DISABLED;
		}
		
		public function createPaginators():void {
			
			paginatorUp = new Paginator(5, 1, 9, {
				hasArrow:true,
				hasButtons:false
			});
			
			paginatorDown = new Paginator(10, 8, 9, {
				hasArrow:true,
				hasButtons:true
			});
		
			paginatorUp.addEventListener(WindowEvent.ON_PAGE_CHANGE, onUpChange);
			paginatorDown.addEventListener(WindowEvent.ON_PAGE_CHANGE, onDownChange);
			
			if (!settings.iconLock)
			{
				paginatorUp.drawArrow(bottomContainer, Paginator.LEFT,  80,  110, {scaleX:-0.6, scaleY:0.6} );
				paginatorUp.drawArrow(bottomContainer, Paginator.RIGHT, 240, 110, {scaleX:0.6, scaleY:0.6} );
			}

			paginatorDown.drawArrow(bottomContainer, Paginator.LEFT,  -1, 346, { scaleX:-1, scaleY:1 } );
			paginatorDown.drawArrow(bottomContainer, Paginator.RIGHT, 480, 346, { scaleX:1, scaleY:1 } );
			bottomContainer.addChild(paginatorDown);
			paginatorDown.x = (settings.width - paginatorDown.width) / 2 - 32;
			paginatorDown.y = settings.height - paginatorDown.height - 32;
		}
		
		/**
		 * Смена страницы для нижнего пагинатора
		 * @param	e	событие смены страницы
		 */
		public function onDownChange(e:WindowEvent = null):void {
			//if (settings.iconMode == GiftWindow.FREE_GIFTS) {
				//if ((Gifts.freeGifts - Gifts.takedFreeGift.length) <= 0) {
					//wantMoreCont.visible = true;
				//}
			//}else {
				wantMoreCont.visible = false;
			//}
			
			var container:Sprite = new Sprite();
			
			for (var m:int = 0; m < items.length; m++)
			{
				items[m].parent.removeChild(items[m]);
				items[m] = null;
			}
			
			var itemNum:int = 0;
			items = [];
			
			if (wantMoreCont.visible) return;
			
			var Xs:int = 20;
			var Ys:int = 5;
			var X:int = Xs;
						
			for (var i:int = paginatorDown.startCount; i < paginatorDown.finishCount; i++)
			{
				var item:*;
				if (settings.itemsMode == GiftWindow.FRIENDS || settings.itemsMode == GiftWindow.ALLFRIENDS) {
					item = new FriendItem(settings.itemsContent[i], this);
				} else {
					item = new MaterialsItem(settings.itemsContent[i], this);
				}
				
				container.addChild(item);
					
				bodyContainer.addChild(container);
				item.x = X;
				item.y = Ys;
				items.push(item);
				
				X += item.bg.width + 12;
				if (itemNum == 3)
				{
					X = Xs;
					Ys += item.bg.height + 36;
				}
				
				container.x = 52;//.(settings.width - container.width ) / 2;
				container.y = 210;
				
				itemNum++;
			}
			
			if (items.length == 0)
				sendAllBttn.state = Button.DISABLED;
			/*else
				sendAllBttn.state = Button.NORMAL;*/
		}
		
		private var bttnWantMore:MoneyButton;
		private var wantMoreCont:Sprite = new Sprite();
		private function wantMoreFreeGifts():void 
		{
			var txtWant:TextField = Window.drawText(Locale.__e('flash:1393580635184'), {
				color:0xffffff,
				borderColor:0x7a4a1f,
				textAlign:"center",
				autoSize:"center",
				fontSize:28,
				textLeading:-1,
				multiline:true
			});
			txtWant.wordWrap = true;
			txtWant.width = 300;
			wantMoreCont.addChild(txtWant);
			txtWant.x = bgBig.x + (bgBig.width - txtWant.textWidth) / 2 - 24;
			txtWant.y = bgBig.y + 84;
			
			bttnWantMore = new MoneyButton( {
				title:Locale.__e('flash:1393580663937'),
				countText:'30',
				width:180,
				height:50,
				shadow:true,
				fontCountSize:28,
				fontSize:26,
				type:"green",
				radius:24,
				bgColor:[0xa8f84a, 0x74bc17],
				bevelColor:[0xcdfb97, 0x5f9c11],
				fontBorderColor:0x4d7d0e,
				fontCountBorder:0x40680b,
				fontCountColor:0xc7f78e,
				iconScale:0.8,
				textAlign: "center",
				hasDotes : false,
				greenDotes:false
			}); 
			
			bttnWantMore.addEventListener(MouseEvent.CLICK, onWantMore);
			bttnWantMore.visible = false;
			
			wantMoreCont.addChild(bttnWantMore);
			bttnWantMore.x = bgBig.x + (bgBig.width - bttnWantMore.width) / 2;
			bttnWantMore.y = txtWant.y + txtWant.textHeight + 32;
			
			bodyContainer.addChild(wantMoreCont);
			wantMoreCont.visible = false;
		}
		
		private function onWantMore(e:MouseEvent):void 
		{
			
		}
		
		/**
		 * Смена страницы для верхнего пагинатора
		 * @param	e	событие смены страницы
		 */
		public function onUpChange(e:WindowEvent = null):void 
		{
			//if (settings.iconContent.length == 0){
				//close();
				//return;
			//}
			
			receivers = [];
			for each(var item:* in items) {
				if (item is FriendItem) {
					item.update();
				}
			}
			
			if (sendBttn) sendBttn.mode = DISABLED;
			
			icon.change(settings.iconContent[paginatorUp.page]);
			if (wishListFilter) {
				seachPanel.search(seachPanel.searchField.text);
			}
		}
		
		private var bgBig:Bitmap;
		private var circle:Shape;
		public function drawBackings():void
		{
			var rad:int = 58;
			circle = new Shape();
			circle.graphics.beginFill(0xc7c9b9, 1);
			circle.graphics.drawCircle(175, 95, rad);
			circle.graphics.endFill();
			bodyContainer.addChild(circle);
			
			//сепараторы
			
			var separator:Bitmap = Window.backingShort(420, 'dividerLine', false);
			separator.x = 75;
			separator.y = 200;
			separator.alpha = 0.5;
			bodyContainer.addChild(separator);
			
			var separator2:Bitmap = Window.backingShort(420, 'dividerLine', false);
			//separator2.scaleY = -1;
			separator2.x = 75;
			separator2.y = 490 - 4;
			separator2.alpha = 0.5;
			bodyContainer.addChild(separator2);
			
			//var bg2:Bitmap = Window.backing(220, 130, 10, "speechBubbleMainBackingTop2");
			//bg2.x = 290;
			//bg2.y = 20;
			
			//var messTitle:TextField = Window.drawText(Locale.__e("flash:1382952380142"), {
					//color:0x6d4b15,
					//borderColor:0xfcf6e4,
					//textAlign:"center",
					//autoSize:"center",
					//fontSize:22
				//}
			//);
			
			/*messText = Window.drawText(Locale.__e("flash:1382952379738"), {
					//color:0x6d4b15,
					color:0x4f4f4f,
					borderColor:0xfcf6e4,
					border:false,
					textAlign:"left",
					fontSize:20,
					multiline:true,
					input:true
				}
			);
			
			messText.wordWrap = true;
			//messText.border = true;
			messText.width = 190;
			messText.height = messText.textHeight * 5;
			messText.addEventListener(Event.CHANGE, onInputEvent);
			messText.addEventListener(FocusEvent.FOCUS_IN, onFocusInEvent);
			messText.addEventListener(FocusEvent.FOCUS_OUT, onFocusOutEvent);
			messText.maxChars = 85;*/
			
			//messTitle.x = bg2.x + (bg2.width - messTitle.width)/2;
			//messTitle.y = 24;
			
			//messText.x = bg2.x + (bg2.width - messText.width)/2;
			//messText.y = 54;
			
			bgBig = Window.backing(settings.width - 60, 290, 20, "storageDarkBackingSlim");
			/*bgBig.x = (settings.width - bgBig.width) / 2;
			bgBig.y = 188;
			
			bodyContainer.addChild(bgBig);*/
		}
		
		private function onInputEvent(e:Event):void {
			
			Gifts.msg = e.currentTarget.text;
		}
		private function onFocusInEvent(e:Event):void {

			if (App.self.stage.displayState != StageDisplayState.NORMAL) {
				App.self.stage.displayState = StageDisplayState.NORMAL;
			}
			
			if(e.currentTarget.text == Locale.__e("flash:1382952379738"))	e.currentTarget.text = "";
		}
		private function onFocusOutEvent(e:Event):void {
			if(e.currentTarget.text == "" || e.currentTarget.text == " ") e.currentTarget.text = Locale.__e("flash:1382952379738");
		}
		
		public function createWishList():void
		{
			wishList = new WishListPopUp(this);
			bodyContainer.addChild(wishList);
			wishList.x = 52;
			wishList.y = 210;
		}
	}	
}

import adobe.utils.CustomActions;
import buttons.Button;
import buttons.ImageButton;
import buttons.ImagesButton;
import buttons.PageButton;
import core.AvaLoad;
import core.Load;
import core.Log;
import core.TimeConverter;
import flash.display.Bitmap;
import flash.display.Shape;
import flash.display.Sprite;
import flash.display.StageDisplayState;
import flash.events.Event;
import flash.events.FocusEvent;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.geom.Point;
import flash.text.TextField;
import flash.utils.setTimeout;
import flash.utils.Timer;
import ui.Hints;
import ui.UserInterface;
import wins.GiftWindow;
import wins.Window;

internal class FriendItem extends Sprite
{
	private var window:GiftWindow;
	public var bg:Bitmap;
	public var friend:Object;
	public var uid:String;
	
	private var title:TextField;
	private var infoText:TextField;
	private var sprite:Sprite = new Sprite();
	private var avatar:Bitmap;
	private var sendBttn:Button;
	public var _hire:uint = 0;
	
	private var preloader:Preloader
	public var tickBttn:ImagesButton;
	
	private var timer:Timer;
	
	public function FriendItem(data:Object, window:GiftWindow)
	{
		this.window = window;
		this.uid = data.uid;
		
		if (window.settings.itemsMode == GiftWindow.ALLFRIENDS) {
			friend = data;
		}else{
			friend = App.user.friends.data[uid];
		}
		
		draw();
		
		sendBttn.state = Button.NORMAL;
		
		if(App.user.friends.hasOwnProperty(uid)){
			if (!Gifts.canTakeFreeGift(uid))
				sendBttn.state = Button.DISABLED;
		}	
		
		
		if(App.social == 'FB' /*|| App.social == 'NK'*/){
			var bgtick:Bitmap = Window.backing(40, 40, 10, "smallBacking");
			tickBttn = new ImagesButton(bgtick.bitmapData, Window.texture('checkmarkSlim'), { ix:9, iy: -1 } );
			addChild(tickBttn);
			tickBttn.x = (width - tickBttn.width) / 2 + 3;
			tickBttn.y = height - tickBttn.height / 2 - 16;
			
			tickBttn.iconBmp.visible = false;
			if (window.receivers.indexOf(uid) != -1) {
				tickBttn.iconBmp.visible = true;
			}
			tickBttn.onMouseDown = onSelectBttnClick;
		}else{	
			addChild(sendBttn);
		}
		
		addPreloader();
		//Load.loading(friend.photo, onLoad);
		new AvaLoad(friend.photo, onLoad);
	}
	
	public function update():void {
		if(App.social == 'FB'){
			tickBttn.iconBmp.visible = false;
			if (window.receivers.indexOf(uid) != -1) {
				tickBttn.iconBmp.visible = true;
			}
			
			if (window.receivers.length == 0) {
				window.sendBttn.state = Button.DISABLED;
			}
		}
	}
	
	private function draw():void
	{
		if(App.social == 'FB'){
			bg = new Bitmap(Window.textures.friendSlot);//Window.backing(100, 108, 10, "itemBackingOff");
		}else {
			bg = new Bitmap(Window.textures.friendSlot);//Window.backing(100, 120, 10, "itemBackingOff");
		}
		
		addChild(bg);
		addChild(sprite);
		
		var shape:Shape = new Shape();
		shape.graphics.beginFill(0x000000, 1);
		shape.graphics.drawRoundRect(15, 15, 70, 70, 15, 15);
		shape.graphics.endFill();
		sprite.mask = shape;
		sprite.addChild(shape);
		shape.x -= 3;
		
		if (App.isSocial('GN') && friend.aka) 
		{
			friend.first_name = friend.aka;
		}	
		
		var first_Name:String = '';
		if (friend.first_name && friend.first_name.length > 0)
			first_Name = friend.first_name;
		else if (friend.aka && friend.aka.length > 0) {
			first_Name = friend.aka;
		}
		
		if (first_Name.indexOf(' ') > 0) first_Name = first_Name.substring(0, first_Name.indexOf(' '));
		title = Window.drawText(first_Name, App.self.userNameSettings({
			fontSize:22,
			color:0xFFFFFF,
			borderColor:0x4b2e1a,
			wrap:true,
			width:bg.width,
			textAlign:'center'
		}));
		
		title.mouseEnabled = false;
		title.x = (bg.width - title.width) / 2;
		title.y = -8;
		addChild(title);
					
		var textSize:int = 20;
		if (App.isSocial('NK')) textSize = 17;
		if (App.isSocial('YB')) textSize = 12;
		sendBttn = new Button({
			caption		:Locale.__e("flash:1382952380118"),
			fontSize	:textSize,
			width		:bg.width,
			height		:36,
			onMouseDown	:onSendBttnClick
		});
				
		sendBttn.x = (bg.width - sendBttn.width) / 2;
		sendBttn.y = bg.height - 9;// - sendBttn.height;
		
		if (window.settings.itemsMode != GiftWindow.ALLFRIENDS) {
			sprite.addEventListener(MouseEvent.MOUSE_OVER, onOver);
			sprite.addEventListener(MouseEvent.MOUSE_OUT, onOut);
		}
	}
	
	public function set state(value:int):void
	{
		if (value == Window.DISABLED)
		{
			sendBttn.state = Button.DISABLED;
		}
		else
		{
			sendBttn.state = Button.NORMAL;
		}
	}
	
	private function removePreloader():void
	{
		if (preloader != null)
		{
			removeChild(preloader);
			preloader = null;
		}
	}
	
	private function addPreloader():void
	{
		if (preloader == null) {
			removePreloader();
			preloader = new Preloader();
		}
		
		addChild(preloader);
		
		preloader.scaleX = preloader.scaleY = 0.8;
		preloader.x = (bg.width) / 2;
		preloader.y = (bg.height) / 2 - 10;
	}
	
	private function onSelectBttnClick(e:MouseEvent):void
	{
		if (e.currentTarget.mode == Button.DISABLED) return;
		var index:int = window.receivers.indexOf(uid);
		if (index == -1){
			if (window.icon.iconMode != GiftWindow.FREE_GIFTS && (App.user.stock.count(window.icon.ID) <= window.receivers.length)) {
				Hints.text(Locale.__e('flash:1382952380143'), Hints.TEXT_RED,  Window.localToGlobal(tickBttn), false, App.self.windowContainer);
				return;
			}
			if (window.receivers.length >= 25) {
				Hints.text(Locale.__e('flash:1382952380144'), Hints.TEXT_RED,  Window.localToGlobal(tickBttn), false, App.self.windowContainer);
				return;
			}
			window.receivers.push(uid);
			
			window.sendBttn.state = Button.NORMAL;
			
			tickBttn.iconBmp.visible = true;
		}else {
			window.receivers.splice(index,1);
			tickBttn.iconBmp.visible = false;
			
			if (window.receivers.length == 0) {
				window.sendBttn.state = Button.DISABLED;
			}
		}
		
		window.icon.countText.text = String(window.receivers.length);
		window.icon.stockCountText.text = String(App.user.stock.count(window.icon.ID) - window.receivers.length);
	}
	
	private function onSendBttnClick(e:MouseEvent):void
	{
		if (e.currentTarget.mode == Button.DISABLED) return;
		
		window.blokItems(false);
		
		//App.user.friends.data[uid]['gift'] = App.time + 86400;
		
		var callback:Function
		if (window.settings.iconMode == GiftWindow.FREE_GIFTS) {
			callback = onSendEvent;
			Gifts.send(window.icon.ID, uid, window.icon.count, Gifts.FREE, callback);
		}else {
			//callback = window.refreshContent;
			callback = onSendEvent;
			Gifts.send(window.icon.ID, uid, window.icon.count, Gifts.NORMAL, callback);
		}
			
		callback();
		
		/*if (window.settings.iconMode == GiftWindow.FREE_GIFTS) {
			//Gifts.freeGifts --;
			//if (Gifts.freeGifts < 0) Gifts.freeGifts = 0;
			window.updateFreeGifts();
		}*/
	}
	
	private function onSendEvent():void
	{
		if (App.data.storage[window.icon.ID].type == 'Sets') App.user.stock.take(window.icon.ID, window.icon.count);
		window.refreshIcon();
		window.seachPanel.search(window.seachPanel.searchField.text);
	}
		
	private function onLoad(data:*):void {
		removePreloader();
		
		avatar = new Bitmap();
		avatar.bitmapData = data.bitmapData;
		avatar.smoothing = true;
		sprite.addChild(avatar);
		
		avatar.width = 70;
		avatar.height = 70;
		
		avatar.x = 12;
		avatar.y = 15;
	}
	
	private function onOver(e:MouseEvent):void
	{
		window.wishList.show(this);
	}
	
	private function onOut(e:MouseEvent):void
	{
		window.wishList.hide();
	}
	
	public function dispose():void
	{
		if (window.settings.itemsMode != GiftWindow.ALLFRIENDS) {
			sprite.removeEventListener(MouseEvent.MOUSE_OVER, onOver);
			sprite.removeEventListener(MouseEvent.MOUSE_OUT, onOut);
		}
	}
}

import buttons.Button;
import buttons.ImageButton;
import core.Load;
import core.TimeConverter;
import flash.display.Bitmap;
import flash.display.Shape;
import flash.display.Sprite;
import flash.display.StageDisplayState;
import flash.events.Event;
import flash.events.FocusEvent;
import flash.events.MouseEvent;
import flash.text.TextField;
import wins.GiftWindow;
import wins.Window;
import wins.GiftItemWindow;

internal class MaterialsItem extends Sprite
{
	private var window:GiftWindow;
	public var bg:Bitmap;
	public var friend:Object;
	public var sID:uint;
	
	private var title:TextField;
	private var infoText:TextField;
	private var bitmap:Bitmap = new Bitmap();
	private var sendBttn:Button;
	public var _hire:uint = 0;
	private var preloader:Preloader = new Preloader();
	
	public function MaterialsItem(sID:uint, window:GiftWindow)
	{
		this.window = window;
		
		draw();
		
		addChild(preloader);
		preloader.x = bg.width / 2;
		preloader.y = bg.height / 2 - 10;
		
		sendBttn.state = Button.NORMAL;
		this.sID = sID;
		title.text = App.data.storage[sID].title;
		title.x = -5;
		title.height = title.textHeight+5;
		addChild(sendBttn);		
		Load.loading(Config.getIcon(App.data.storage[sID].type, App.data.storage[sID].preview),onLoad);
	}
	
	private function draw():void
	{
		bg = Window.backing(100, 120, 10, "textBacking");
		addChild(bg);
		addChild(bitmap);
		
		title = Window.drawText("",
				{
					fontSize:20,
					color:0x502f06,
					borderColor:0xf8f2e0,
					textAlign:"center",
					multiline:true,
					textLeading:-6
				});
				
		title.wordWrap = true;	
		title.width = 110;
		addChild(title);
		title.y = -5;
		title.x = -5;
		
		sendBttn = new Button({
					caption		:Locale.__e("flash:1382952380118"),
					fontSize	:18,
					width		:86,
					height		:26,
					onMouseDown	:onSendBttnClick
				});
				
		sendBttn.x = (bg.width - sendBttn.width) / 2;
		sendBttn.y = bg.height - sendBttn.height;
	}
	
	public function set state(value:int):void
	{
		if (value == Window.DISABLED)
		{
			sendBttn.state = Button.DISABLED;
		}
		else
		{
			sendBttn.state = Button.NORMAL;
		}
	}
	
	private function onLoad(data:*):void {
		
		if (this.contains(preloader))
		{
			removeChild(preloader);
		}
				
		bitmap.bitmapData = data.bitmapData;
		bitmap.scaleX = bitmap.scaleY = 0.7;
		bitmap.smoothing = true;
		
		bitmap.x = (bg.width - bitmap.width) / 2;
		bitmap.y = (bg.height - bitmap.height) / 2 - 8;
	}
	
	private function onSendBttnClick(e:MouseEvent):void
	{
		if (e.currentTarget.mode == Button.DISABLED) return;
		
		if (App.data.storage[sID].free == 1 && window.settings.itemsMode == GiftWindow.FREE_GIFTS)
		{
			
			Gifts.send(sID, window.settings.uid, 1, Gifts.FREE, window.refreshContent);
			
			window.menuBttn1.state = Button.DISABLED;
			window.menuBttn2.dispatchEvent(new MouseEvent("click"));
		}
		else
		{
			new GiftItemWindow( { 
				sID:sID,
				fID:window.settings.uid,
				callback:function():void {
					window.refreshIcon();
					window.refreshContent();
				}
			}).show();
		}
			
		window.blokItems(false);
	}
	
	public function dispose():void
	{
		
	}
}

import ui.UserInterface;
import buttons.ImageButton;

internal class Icon extends Sprite
{
	public var info:Object;
	public var win:*;
	public var bitmap:Bitmap;
	public var title:TextField;
	public var countText:TextField;
	public var stockCountText:TextField;
	public var sID:uint;
	public var ID:*;
	public var uid:String;
	public var iconMode:uint;
	
	//private var plus:PageButton;
	//private var minus:PageButton;
	public var plus:Button;
	public var minus:Button;
	public var plus10:Button;
	public var minus10:Button;
	private var _counter:Sprite;
	private var stockCountBg:Sprite;
	
	private var stockCount:uint = 0;
	public var count:uint = 0;
	public var shape:Shape;
	public var sprite:Sprite;
	public var avatar:Bitmap;
	public var wishList:WishList = null;
	
	private var preloader:Preloader = new Preloader();
	private var stockCountInnerBg:Sprite;
	private var countInnerBg:Sprite;
	
	public function Icon(window:*)
	{
		win 		= window;
		iconMode 	= win.settings.iconMode;
		
		bitmap = new Bitmap();
		addChild(bitmap);
		
		title = Window.drawText("", {
				color:0x773c18,
				borderColor:0xfaf9ec,
				textAlign:"center",
				autoSize:"center",
				fontSize:26,
				multiline:true
			});
			
			title.wordWrap = true;
			title.width = 150;
			
			
		if (iconMode == GiftWindow.FRIENDS)
		{
			avatar = new Bitmap();
			sprite = new Sprite();
			
			addChild(sprite);
			
			shape = new Shape();
			shape.graphics.beginFill(0x000000, 1);
			shape.graphics.drawRoundRect(0, 0, 100, 100, 15, 15);
			shape.graphics.endFill();
			sprite.mask = shape;
			
			sprite.addChild(avatar);
			sprite.addChild(shape);
			
			sprite.x = (200 - 100) / 2;
			sprite.y = 50;
		}
		else
		{
			drawCounter();
		}
		
		addChild(title);
	}
	
	public function drawWishList():void
	{
		if (wishList != null)
		{
			removeChild(wishList);
			wishList = null;
		}
		
		if (App.user.friends.data[ID].hasOwnProperty("wl"))
		{
			wishList = new WishList(App.user.friends.data[ID].wl, this);
			addChild(wishList);
			wishList.y = 136;
			sprite.y -= 15;
			wishList.x = (200 - wishList.width)/2;
		}
	}
	
	private function drawCounter():void
	{
		_counter = new Sprite();
		
		var countBg:Sprite = new Sprite();
		countBg.graphics.beginFill(0xc59a57);
        countBg.graphics.drawCircle(18, 18, 17);
        countBg.graphics.endFill();
		countBg.x =	-countBg.width/2 + 5;
		countBg.y = -2;
		
		countInnerBg = new Sprite();
		countBg.graphics.beginFill(0xd2ac7c);
        countBg.graphics.drawCircle(18, 18, 15);
        countBg.graphics.endFill();
		countBg.x =	-countBg.width/2 + 5;
		countBg.y = -2;
		/////////////////////////////////////////
		
		var setM10:Object = {
			caption			:"-10",
			bgColor			:[0xffe3af, 0xffb468],
			bevelColor		:[0xffeee0, 0xc0804e],
			borderColor		:[0xc3b197, 0xcab89f],
			width			:38,
			height			:26,
			fontSize		:18,
			fontColor		:0xffffff,
			fontBorderColor	:0xa05d36,
			shadow			:true,
			radius			:10,
			shadowColor		:0xa05d36,
			shadowSize		:3
		};
		var setM:Object = {
			caption			:"-",
			bgColor			:[0xffe3af, 0xffb468],
			bevelColor		:[0xffeee0, 0xc0804e],
			borderColor		:[0xc3b197, 0xcab89f],
			width			:28,
			height			:26,
			fontSize		:18,
			fontColor		:0xffffff,
			fontBorderColor	:0xa05d36,
			shadow			:true,
			radius			:10,
			shadowColor		:0xa05d36,
			shadowSize		:3
		};
		var setP:Object = {
			caption			:"+",
			bgColor			:[0xffe3af, 0xffb468],
			bevelColor		:[0xffeee0, 0xc0804e],
			borderColor		:[0xc3b197, 0xcab89f],
			width			:28,
			height			:26,
			fontSize		:18,
			fontColor		:0xffffff,
			fontBorderColor	:0xa05d36,
			shadow			:true,
			radius			:10,
			shadowColor		:0xa05d36,
			shadowSize		:3
		};
		var setP10:Object = {
			caption			:"+10",
			bgColor			:[0xffe3af, 0xffb468],
			bevelColor		:[0xffeee0, 0xc0804e],
			borderColor		:[0xc3b197, 0xcab89f],
			width			:38,
			height			:26,
			fontSize		:18,
			fontColor		:0xffffff,
			fontBorderColor	:0xa05d36,
			shadow			:true,
			radius			:10,
			shadowColor		:0xa05d36,
			shadowSize		:3
		};
		
		minus10 = new Button(setM10);
		minus10.x = countBg.x - 72;
		minus10.y = countBg.y + countBg.height / 2 - 10;
		addChild(minus10);
		
		minus = new Button(setM);
		minus.x = minus10.x + minus10.width + 3;
		minus.y = minus10.y;
		addChild(minus);
		
		plus = new Button(setP);
		plus.x = minus.x + 70;
		plus.y = minus10.y;
		addChild(plus);
		
		plus10 = new Button(setP10);
		plus10.x = plus.x + plus.width + 3;
		plus10.y = minus10.y;
		addChild(plus10);
		
		minus.state = Button.DISABLED;
		minus10.state = Button.DISABLED;
		
		plus.addEventListener(MouseEvent.CLICK, onPlus);
		minus.addEventListener(MouseEvent.CLICK, onMinus);
		plus10.addEventListener(MouseEvent.CLICK, onPlus10);
		minus10.addEventListener(MouseEvent.CLICK, onMinus10);
		/////////////////////////////////////////////////////
		
		_counter.visible = false;
		
		countText = Window.drawText("", {
				color:0xffffff,
				fontSize:20,
				borderColor:0x59331c,
				autoSize:"center",
				shadowColor:0x59331c,
				shadowSize:2
			}
		);
		
		countText.x = countInnerBg.x + (countInnerBg.width + countText.textWidth)/2 + 6;
		countText.y = countInnerBg.y + (countInnerBg.height + countText.textHeight)/2 + 6;
		countText.width = countInnerBg.width;
		
		stockCountBg = new Sprite();
        stockCountBg.graphics.beginFill(0xffecd4);
        stockCountBg.graphics.drawCircle(23, 33, 26);
        stockCountBg.graphics.endFill();
		stockCountBg.x = -16;
		stockCountBg.y = 6;
		
		stockCountInnerBg = new Sprite();
        stockCountInnerBg.graphics.beginFill(0x9ab3b0);
        stockCountInnerBg.graphics.drawCircle(23, 33, 22);
        stockCountInnerBg.graphics.endFill();
		stockCountInnerBg.x = -16;
		stockCountInnerBg.y = 6;
		
		stockCountText = Window.drawText("", {
			color:0xffffff,
			fontSize:26,
			borderColor:0x324540,
			autoSize:"center",
			shadowColor:0x324540,
			shadowSize:2
		});	
		stockCountText.x = stockCountBg.x + (stockCountBg.width - stockCountText.textWidth) / 2 - 6;
		stockCountText.y = stockCountBg.y + (stockCountBg.height - stockCountText.textHeight) / 2 - 6;
		
		counter = false;
		
		if (App.social != 'FB')
		{
			_counter.addChild(countInnerBg);
			_counter.addChild(countBg);
			
			_counter.addChild(minus10);
			_counter.addChild(minus);
			_counter.addChild(plus);
			_counter.addChild(plus10);
			_counter.addChild(countText);
			
			addChild(_counter);
		} else {
			plus.visible = false;
			plus10.visible = false;
			minus.visible = false;
			minus10.visible = false;
		}
		
		_counter.x = 94;
		_counter.y = 196 - _counter.height;
		
		addChild(stockCountBg);
		addChild(stockCountInnerBg);
		addChild(stockCountText);
	}
	
	public function change(data:*):void
	{
		/*this.ID = data.uid;
		Log.alert(data);
		Log.alert(App.user.friends.data);
		info = App.user.friends.data[ID];
		Log.alert(info);
		return;*/
		if (iconMode == GiftWindow.FRIENDS)
		{
			addChild(preloader);
			preloader.x = 100;
			preloader.y = 85;
			
			sprite.y = 50;
			this.ID = data.uid;
			this.uid = data.uid;
			info = App.user.friends.data[ID];
			title.text = info.first_name + " " + info.last_name;
			//Load.loading(info.photo, onLoadAvatar);

			new AvaLoad(info.photo, onLoadAvatar);
			
			if (!Gifts.canTakeFreeGift(data.uid))
			{
				win.menuBttn1.state = Button.DISABLED;
			}
			else
			{
				if(win.menuBttn1.mode == Button.DISABLED)
					win.menuBttn1.state = Button.NORMAL;
			}
			
			drawWishList();
		} else {
			this.ID = data;
			info = App.data.storage[ID];
			title.text = info.title;
			
			addChild(preloader);
			preloader.x = 100;
			if (iconMode == GiftWindow.FREE_GIFTS)	
				preloader.y = 100;
			else
				preloader.y = 85;
			
			Load.loading(Config.getIcon(info.type, info.preview), onLoad);
			
			if ((iconMode == GiftWindow.MATERIALS || iconMode == GiftWindow.COLLECTIONS))//App.social != 'FB' && 
			{
				
				stockCount = App.user.stock.data[ID];
				if (App.social == 'FB')
					count = 0;
				else
					count = 1;
				
				counter = true;
				refreshCounters();
			}
			else if(iconMode == GiftWindow.FREE_GIFTS)//(App.social == 'FB' || 
			{
				stockCount = App.user.stock.data[ID];
				count = 1;
				counter = false;
				refreshCounters();
			}
		}
		
		title.x = 103 - title.width / 2;
		title.y = 12;
	}
		
	public function onLoad(data:Bitmap):void
	{
		if(contains(preloader)){
			removeChild(preloader);
		}
		
		bitmap.bitmapData = data.bitmapData;
		bitmap.x = 100 - bitmap.width / 2;
		
		if (iconMode == GiftWindow.FREE_GIFTS)	
			bitmap.y = 100 - bitmap.height / 2;
		else 									
			bitmap.y = 85 - bitmap.height / 2;
	}
	
	private function onLoadAvatar(data:Bitmap):void
	{
		if(contains(preloader)){
			removeChild(preloader);
		}
		
		avatar.bitmapData = data.bitmapData;
		avatar.smoothing = true;
		
		avatar.width = 100;
		avatar.height = 100;
	}
	
	private function set counter(value:Boolean):void
	{
		if (value){
				_counter.visible 		= true;
				stockCountText.visible 	= true;
				stockCountBg.visible 	= true;
				stockCountInnerBg.visible 	= true;
		} else {
				_counter.visible 		= false;
				stockCountText.visible 	= false;
				stockCountBg.visible 	= false;
				stockCountInnerBg.visible 	= false;
		}
	}
	
	public function onPlus(e:MouseEvent = null):void
	{
		if (e.currentTarget.mode == Button.DISABLED) return;
		
		if (stockCount - count - 1 >= 0)
		{
			count += 1;
			refreshCounters();
		}
	}
	
	public function onPlus10(e:MouseEvent = null):void
	{
		if (e.currentTarget.mode == Button.DISABLED) return;
		
		if (stockCount - count - 10 >= 0)
		{
			count += 10;
			refreshCounters();
		}
	}
	
	public function onMinus(e:MouseEvent = null):void
	{
		if (e.currentTarget.mode == Button.DISABLED) return;
		
		if (count - 1 >= 0)
		{
			count -= 1;
			refreshCounters();
		}
	}
	
	public function onMinus10(e:MouseEvent = null):void
	{
		if (e.currentTarget.mode == Button.DISABLED) return;
		
		if (count - 10 >= 0)
		{
			count -= 10;
			refreshCounters();
		}
	}
	
	private function refreshCounters():void
	{
		if (count == 1) {
			minus.state = Button.DISABLED;
			minus10.state = Button.DISABLED;
		}
		if(count > 1) {
			minus.state = Button.NORMAL;
		}
		if (count > 10) {
			minus10.state = Button.NORMAL;
		}
		
		if (count == stockCount) {
			plus.state = Button.DISABLED;
			plus10.state = Button.DISABLED;
		}
		
		if (count + 10 > stockCount) {
			plus10.state = Button.DISABLED;
		}
		
		if(count + 1 <= stockCount) {
			plus.state = Button.NORMAL;
		}
		if (count + 10 <= stockCount) {
			plus10.state = Button.NORMAL;
		}
		
		countText.text 		= String(count);
		stockCountText.text = String(stockCount - count);
		
		if (stockCount - count <= 0 || _counter.visible == false) {
			stockCountText.visible 	= false;
			stockCountBg.visible 	= false;
			stockCountInnerBg.visible 	= false;
		} else {
			stockCountText.visible 	= true;
			stockCountBg.visible 	= true;
			stockCountInnerBg.visible 	= true;
		}
		
		Gifts.count = count;
		Gifts.sID = sID;
	}
	
	public function dispose():void
	{
		Gifts.clean();
		plus.removeEventListener(MouseEvent.CLICK, onPlus);
		minus.removeEventListener(MouseEvent.CLICK, onMinus);
		wishList.dispose();
	}
}

internal class WishListPopUp extends Sprite
{
	private var showed:Boolean = false;
	private var items:Array = [];
	private var container:Sprite;
	private var overed:Boolean = false;
	private var overTimer:Timer = new Timer(250, 1);
	public var window:GiftWindow
	public var callback:Function
	public var uid:String;

	public function WishListPopUp(window:GiftWindow)
	{
		this.window = window;
		callback = function():void{
			window.refreshContent();
			window.onUpChange();
		}
		overTimer.addEventListener(TimerEvent.TIMER, dispose)
	}
	
	public function show(target:FriendItem):void
	{
		if (!App.user.friends.data[target.uid].hasOwnProperty("wl")) return;
		
		uid = target.uid;
		var wlist:Object = App.user.friends.data[uid].wl;
		
		dispose();
		items = [];
			
		var X:int = 0;
		var Y:int = 0;
		
		for (var i:* in wlist)
		{
			var item:WishListItem = new WishListItem(wlist[i], this, uid);
			item.x = X;
			item.y = Y;
			item.addEventListener(MouseEvent.MOUSE_OVER, over);
			item.addEventListener(MouseEvent.MOUSE_OUT, out);
			
			items.push(item);
			X += 56;
			addChild(item);
		}
		
		this.x = target.x + (target.width - this.width)/2 - 12 + 67;
		this.y = target.y - 60 + 210;
		
		showed = true;
		window.bodyContainer.setChildIndex(this, window.bodyContainer.numChildren-1);
	}
	
	private function over(e:MouseEvent):void{
		overed = true;
	}
	
	private function out(e:MouseEvent):void{
		overed = false;
	}
	
	private function dispose(e:TimerEvent = null):void
	{
		overTimer.reset();
		if (overed)
		{
			overTimer.start();
			return;
		}
		
		for each(var _item:* in items)
		{
			_item.dispose();
			_item.removeEventListener(MouseEvent.MOUSE_OVER, over);
			_item.removeEventListener(MouseEvent.MOUSE_OUT, out);
			removeChild(_item);
			_item = null;
		}
		items = [];
		
		showed = false;
	}
	
	public function hide():void
	{
		overTimer.reset();
		overTimer.start();
	}
}

internal class WishList extends Sprite
{
	public var items:Array = [];
	public var icon:*;
	public var uid:String;
	public var callback:Function;

	public function WishList(wlist:Object, icon:*)
	{
		this.icon = icon;
		this.uid = icon.uid;
		var X:int = 0;
		var Y:int = 0;
		callback = function():void{
			icon.win.refreshIcon();
			icon.win.refreshContent();
			//icon.drawWishList();
		}
		
		for (var i:* in wlist)
		{
			var item:WishListItem = new WishListItem(wlist[i], this, uid);
			item.x = X;
			item.y = Y;
			items.push(item);
			X += 56;
			addChild(item);
		}
	}
	
	public function dispose():void
	{
		for each(var item:* in items)
		{
			item.dispose();
			item = null;
		}
	}
}

internal class WishListItem extends Sprite
{
	private var bitmap:Bitmap;
	private var bg:Bitmap;
	private var has:Boolean = false;
	private var preloader:Preloader = new Preloader();
	private var wList:*;
	private var sID:uint;
	private var uid:String;
		
	public function WishListItem(sID:uint, wList:*, uid:String)
	{
		this.wList = wList;
		this.sID = sID;
		this.uid = uid;
		
		if (App.user.stock.count(sID) > 0)
		{
			has = true;
			bg = new Bitmap(Window.textures.cursorsPanelItemBg);
			//bg = Window.backing(64, 64, 8, "textSmallBacking");
			bg.x = -2;
			bg.y = -2;
			this.addEventListener(MouseEvent.CLICK, onClick);
		}	
		else
			bg = new Bitmap(Window.textures.cursorsPanelItemBg);
			//bg = Window.backing(60, 60, 8, "bonusBacking");
		
		addChild(bg);
		
		bitmap = new Bitmap();
		addChild(bitmap);
		
		addChild(preloader);
		preloader.scaleX = preloader.scaleY = 0.4;
		preloader.x = 60/2;
		preloader.y = 60/2;
		
		Load.loading(Config.getIcon(App.data.storage[sID].type, App.data.storage[sID].preview), onLoad);
	}

	private function onClick(e:MouseEvent):void
	{
		new GiftItemWindow( {
			sID:sID,
			fID:uid,
			callback:function():void {
				wList.callback();
			}
		}).show();
	}
	
	public function dispose():void
	{
		this.removeEventListener(MouseEvent.CLICK, onClick);
	}
	
	private function onLoad(data:Bitmap):void
	{
		removeChild(preloader);
		
		bitmap.bitmapData = data.bitmapData;
		bitmap.scaleX = bitmap.scaleY = 0.4;
		bitmap.y = (60 - bitmap.height) / 2 - 5;
		bitmap.x = (60 - bitmap.width) / 2 - 5;
		bitmap.smoothing = true;
	}
}