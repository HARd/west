package wins.actions 
{
	import api.ExternalApi;
	import buttons.Button;
	import buttons.MenuButton;
	import com.greensock.easing.Elastic;
	import com.greensock.TweenLite;
	import core.Load;
	import core.Numbers;
	import core.Size;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;
	import flash.text.TextField;
	import flash.utils.setTimeout;
	import ui.Cursor;
	import ui.UserInterface;
	import wins.elements.BankSetsItem;
	import wins.elements.BankUsualMenu;
	import wins.elements.BankUsualItem;
	import wins.elements.SetItem;
	import wins.Window;
	import wins.InformerWindow;
	import wins.Paginator;
	
	public class BanksWindow extends Window
	{
		public static const COINS:String = 'Coins';
		public static const REALS:String = 'Reals';
		public static const SETS:String = 'Sets';
		
		public static var shop:Object;
		public static var history:Object = { section:'Coins', page:0 };
		
		
		public var sections:Array = new Array();
		public var news:Object = {items:[],page:0};
		public var icons:Array = new Array();
		public var items:Array = [];
		
		private static var _currentBuyObject:Object = { type:null, sid:null };
		
		public function BanksWindow(settings:Object = null)
		{
			_currentBuyObject.type = null;
			_currentBuyObject.sid = null;
			
			if (settings == null) {
				settings = new Object();
			}
			
			settings["section"] = settings.section || history.section; 
			settings["page"] = settings.page || history.page;
			settings["popup"] = true;
			settings["title"] = Locale.__e("flash:1382952379979");
			settings["width"] = 680 + 50 * int(App.isSocial('YB','MX','GN'));
			settings["height"] = 640;
			settings["hasPaginator"] = true;
			settings["hasArrows"] = true;
			settings["itemsOnPage"] = 6;
			settings["returnCursor"] = false;
			settings['hasButtons'] = false;
			settings['shadowColor'] = 0x513f35;
			settings['shadowSize'] = 4;
			
			history.page		= settings.page;
			
			super(settings);
			
			history.section = settings["section"];
			
		}
		
		override public function show():void 
		{
			if (App.social == 'SP') {
				ExternalApi.apiBalanceEvent( { money:settings.section } );
				return;
			}
			super.show();
		}
		
		override public function drawBackground():void {
			if (!background) {
				background = new Bitmap();
				layer.addChild(background);
			}
			background.bitmapData = backing2(settings.width, settings.height, 50, "shopBackingTop","shopBackingBot").bitmapData;
		}
		
		private function checkUpdate(updateID:String):Boolean {
			
			var update:Object = App.data.updates[updateID];
			if (!update.hasOwnProperty('social') || !update.social.hasOwnProperty(App.social)) {
				
				for (var sID:* in App.data.updates[updateID].items) {
					if ((update.ext != null && update.ext.hasOwnProperty(App.social)) && (update.stay != null && update.stay[sID] != null))
					{
						
					}
					else
					{
						App.data.storage[sID].visible = 0;
					}
				}
				
				return false;
			}
			
			return true;
		}
		
		override public function dispose():void {
			
			App.self.setOffTimer(updateTimeAction);
			
			for each(var item:* in items) 
			{
				if(item && item.parent){
				bodyContainer.removeChild(item);
				item.dispose();
				item = null;
				}
			}
			
			for each(var icon:* in icons) {
				//bodyContainer.removeChild(icon);
				icon.dispose();
				icon = null;
			}
			
			super.dispose();
		}
		
		public var clickCont:LayerX;
		private var lable1:Bitmap;
		private var lable2:Bitmap;
		override public function drawBody():void {
			//drawBacking();
			drawMenu();
			
			var date:Date = new Date();
			
			if (App.social == 'OK' && App.data.options.hasOwnProperty('OKEvent')) {
				var ok_Events:Object = JSON.parse(App.data.options.OKEvent);
				
				for (var cond:String in ok_Events) {
					var month:int = date.getMonth();
					var day:int = date.getDate();
					var condList:Array = cond.split('.');
					if (condList.length >= 2 && int(condList[0]) == day && int(condList[1]) == month + 1) {
						var lable1:Bitmap = new Bitmap();
						Load.loading(Config.getImage('money', 'OK'), function(data:Bitmap):void {
							lable1.bitmapData = data.bitmapData;
							lable1.x = 40;
							lable1.y = 15;
						});
						
						var lable:Bitmap = new Bitmap();
						
						Load.loading(Config.getImage('money', ok_Events[cond]), function(data:Bitmap):void {
							lable.bitmapData = data.bitmapData;
							lable.smoothing = true;
							
							Size.size(lable, 100, 60, false);
							
							lable.x = 520;
							lable.y = 0;
						});
						clickCont = new LayerX();
						clickCont.addChild(lable);
						clickCont.addChild(lable1);
						bodyContainer.addChild(clickCont);
						clickCont.addEventListener(MouseEvent.CLICK, onClickContEvent);
						break;
					}
				}
			}
			
			checkAction();
			setContentSection(settings.section,settings.page);
			contentChange();
			
			exit.x += 5;
			exit.y -= 5;
			titleLabel.y -= 4;
			
			if(App.social == 'FB'){
				drawCards();
			}
			
			if (App.social == 'FB' && App.time > dateFromFB && App.time < dateToFB)  {
				drawTimer();
				App.self.setOnTimer(updateDuration);
			}
		}
		
		private var dateFromFB:int = 1455264000;
		private var dateToFB:int = 1455523200;
		private var timerTitle:TextField;
		private var timerText:TextField;
		private function drawTimer():void {
			
			var timerContainer:Sprite = new Sprite();
			timerContainer.mouseEnabled = false;
			timerContainer.x = -130;
			timerContainer.y = -15;
			bodyContainer.addChild(timerContainer);
			
			var glowing:Bitmap = new Bitmap(Window.textures.glow);
			timerContainer.addChild(glowing);
			glowing.smoothing = true;
			glowing.alpha = .5;
			glowing.scaleX = glowing.scaleY = 0.6;
			glowing.x = -20;
			glowing.y = -90;
			
			timerTitle = Window.drawText(Locale.__e('flash:1382952379793'),{
				color:0xffcc00,
				fontSize:53,
				borderColor:0x705535,
				borderSize:8
			});
			
			timerContainer.addChild(timerTitle);
			timerTitle.x = 5;
			timerTitle.y = 15;
			timerTitle.rotation = -30;
			
			var time:int = App.data.money.date_to - App.time;
			
			timerText = Window.drawText(TimeConverter.timeToStr(time), {
				color:0xf6f1df,
				letterSpacing:0,
				textAlign:"center",
				fontSize:26,
				borderColor:0x817043,
				borderSize:6
			});
			
			timerText.width = 230;
			timerText.y = 90;
			timerText.x = -10;
			timerText.rotation = -30
			timerContainer.addChild(timerText);
			
			var lable3:Bitmap = new Bitmap();
			Load.loading(Config.getImage('money', 'fb_sale'), function(data:Bitmap):void {
				lable3.bitmapData = data.bitmapData;
				lable3.x = 45;
				lable3.y = -25;
			});
			timerContainer.addChild(lable3);	
			
			timerText.y = 50;
			timerText.x = -25;
			timerText.rotation = 0;
			timerTitle.visible = false;
		}
		private function updateDuration():void {
			var time:int = dateToFB - App.time;
			timerText.text = TimeConverter.timeToStr(time);
			
			if (time <= 0) {
				timerText.visible = false;
				close();
			}
		}
		
		public var cardsLabel:Bitmap = new Bitmap();
		private function drawCards():void {
			if(!cardsLabel.parent){
				Load.loading(Config.getImage('interface', 'cards'), 
				function(data:Bitmap):void {
					cardsLabel.bitmapData = data.bitmapData;
					cardsLabel.x = 50;
					cardsLabel.y = 535;
					bodyContainer.addChild(cardsLabel);
					if (App.social == "FB") {
						cardsLabel.y = 535;
					}
					App.ui.flashGlowing(cardsLabel);
				} );
			}
			else {
				App.ui.glowing(cardsLabel);
			}
		}
		
		private function onClickContEvent(e:MouseEvent):void {
			for (var s:String in App.data.inform) {
				if (App.data.inform[s].enabled && App.data.inform[s].start < App.time && App.data.inform[s].finish > App.time && inSocial(App.data.inform[s].social)) {
					close();
					new InformerWindow({informer:App.data.inform[s]}).show();
					break;
				}
			}
			
			function inSocial(socials:Object):Boolean {
				for (var id:* in socials) {
					if (id == App.social || socials[id] == App.social)
						return true;
				}
				
				return false;
			}
		}
		
		private var actionCont:LayerX = new LayerX();
		private var actionTime:TextField;
		private var actionTitle:TextField;
		
		private var timeToActionEnd:int = 0;
		private function checkAction():void 
		{
			var money:Object;
			if (!App.data.money.hasOwnProperty(App.social)) return
				
				money = App.data.money[App.social];
				
				// Акция запускается если:
				//		- попадает в пределы времени;
				//		- достигнут уровень
				if ((money.enabled && money.date_to > App.time && money.date_from < App.time) || (App.user.money > App.time)){
					
					if(money && App.time > money.date_from && App.time < money.date_to && money.enabled == 1 && money.date_to > App.user.money)
						timeToActionEnd = money.date_to;
					else if (App.user.money > App.time)
						timeToActionEnd = App.user.money;
					
					var btmd:BitmapData = texture('glow');
					var invertTransform:ColorTransform = new ColorTransform();
					invertTransform.color = 0xffffff;
					btmd.colorTransform(btmd.rect, invertTransform);
					var glowBg:Bitmap = new Bitmap(btmd);
					glowBg.scaleX = glowBg.scaleY = 0.3;
					glowBg.smoothing = true;
					glowBg.alpha = 0.6;
					glowBg.y = 30;
					actionCont.addChild(glowBg);
					actionCont.mouseChildren = false;
					actionCont.mouseEnabled = false;
					actionCont.cacheAsBitmap = true;
					
					actionTitle = drawText(Locale.__e("flash:1382952379793"), {
						color:0xffffff,
						borderColor:0x7a4003,
						textAlign:"center",
						autoSize:"center",
						fontSize:32
					});
					actionTitle.y = 50;
					actionTitle.width = actionTitle.textWidth + 10;
					actionCont.addChild(actionTitle);
					
					actionTime = drawText(TimeConverter.timeToStr(timeToActionEnd - App.time), {
						color:0xffd950,
						borderColor:0x402016,
						textAlign:"center",
						autoSize:"center",
						fontSize:40
					});
					actionTime.y = actionTitle.y + actionTitle.textHeight - 4;
					actionTime.x = (glowBg.width - actionTime.width) / 2 - 20;
					actionTime.width = actionTime.textWidth + 10;
					actionCont.addChild(actionTime);
					
					actionTitle.x = actionTime.x + (actionTime.width - actionTitle.textWidth) / 2;
					
					App.self.setOnTimer(updateTimeAction);
					
					bodyContainer.addChild(actionCont);
					actionCont.rotation = -25;
					actionCont.x = 0;
					actionCont.y = -60;
				}
		}
		
		private function updateTimeAction():void
		{
			var timeAction:int = timeToActionEnd - App.time;
			if (timeAction < 0) {
				timeAction = 0;
				App.self.setOffTimer(updateTimeAction);
				actionCont.visible = false;
				contentChange();
				return;
			}
			actionTime.text = TimeConverter.timeToStr(timeAction);
		}
		
		private var menu:BankUsualMenu;
		private var giftCardButton:Button;
		public function drawMenu():void 
		{
			menu = new BankUsualMenu(this);
			bodyContainer.addChild(menu);
			if (App.social == "FB") {
				menu.x += 25;
				var gftParams:Object = {
					caption:Locale.__e('flash:1419420860172'),
					bgColor:[0xa8f84a, 0x74bc17],
					borderColor:[0xffffff, 0xffffff],
					bevelColor:[0xc8fa8f, 0x5f9c11],
					fontSize:22,
					fontBorderColor:0x4d7d0e,
					width:102,
					height:42
				}
				giftCardButton = new Button(gftParams);
				giftCardButton.x = 60;
				giftCardButton.y = 19;
				
				giftCardButton.addEventListener(MouseEvent.CLICK, ExternalApi.onReedem);
				bodyContainer.addChild(giftCardButton);
			}else {
				menu.x -= 20;
			}
			menu.y += 10;
		}
		
		public function setContentSection(section:*, page:Number = -1):Boolean
		{
			for each(var icon:MenuButton in icons) {
				icon.selected = false;
				if (icon.type == section) {
					icon.selected = true;
				}
			}
			
			//settings.content.splice(0, settings.content.length);
			settings.content = [];
			
			
			for (var sID:* in App.data.storage) {
				var object:Object = App.data.storage[sID];
				object['sid'] = sID;
				if (object.type == section) {
					settings.content.push(object); 
				}
			}
			history.section = section;
			history.page = page;
			
			paginator.itemsCount = settings.content.length;
			paginator.onPageCount = 6;
			if (history.section == 'Sets') {
				paginator.itemsCount = settings.content.length;
				paginator.onPageCount = 4;
			}
			paginator.update();
			
			contentChange();
			return true;
		}
		
		public function setContentNews(data:Array):Boolean
		{
			for each(var icon:MenuButton in icons) {
				icon.selected = false;
			}
			
			settings.content = data
			paginator.page = 0;
			
			//settings.section = 'Reals';
			//paginator.onPageCount = settings.itemsOnPage;
			//paginator.itemsCount = settings.content.length;
			/*if (history.section == 'Sets') {
				settings.content = [];
				var ln:uint = 0;
				for (var decoItm:String in currentSale.items) {
					settings.content.push(currentSale.items[decoItm])
					ln++;
				}
				paginator.onPageCount = 4;
				paginator.itemsCount = ln;
			}else {
				paginator.onPageCount = settings.itemsOnPage;
				paginator.itemsCount = settings.content.length;
			}*/
			
			paginator.onPageCount = settings.itemsOnPage;
			paginator.itemsCount = settings.content.length;
			paginator.update();
				
			contentChange();
			return true;
		}
		
		public function set paginatorType(value:String):void {
			var data:Object = {
				Coins: {
					itemsOnPage:6,
					itemsCount:settings.content.length
				},
				Reals: {
					itemsOnPage:6,
					itemsCount:settings.content.length
				},
				Sets: {
					itemsOnPage:4,
					itemsCount:currentSale.items.length
				}
			}
			
			var type:String = 'Coins'
			if (value)
				type = value;
				
				
			settings["itemsOnPage"] = data[type].itemsOnPage;
			paginator.onPageCount = settings.itemsOnPage;
			paginator.itemsCount = data[type].itemsCount;
			
			
			if (history.section == 'Sets') {
				settings.content = [];
				var ln:uint = 0;
				for (var decoItm:String in currentSale.items) {
					settings.content.push(currentSale.items[decoItm])
					ln++;
				}
				paginator.onPageCount = 4;
				paginator.itemsCount = ln;
			}else {
				paginator.onPageCount = 6;
				paginator.onPageCount = settings.itemsOnPage;
				paginator.itemsCount = settings.content.length;
			}
			//paginator.update();
			paginator.update();
		}
		
		public function get currentSale():Object {
			var currSale:Object = new Object();
			for (var decoActId:String in App.data.sales) {
				currSale = App.data.sales[decoActId];
				if ((App.time > currSale.time && App.time < currSale.time + currSale.duration * 3600) && currSale.social.hasOwnProperty(App.social)) {
					break;
				}
			}
			return currSale;
		}
		
		public function drawBacking():void {
			var backing:Bitmap = Window.backing(settings.width-54, 478, 25, 'shopBackingSmall');
			bodyContainer.addChild(backing);
			backing.x = settings.width/2 - backing.width/2;
			backing.y = 52;
		}
		
		public function DrawSets():void {
			//paginatorType = 'Sets';
			
			for each(var _item:* in items) {
				if(_item && _item.parent){
					bodyContainer.removeChild(_item);
					_item.dispose();
				}
			}
			
			removePremiumFlags();
			
			items = [];
			var X:int = 45;
			if (App.isSocial('MX')) X = 80;
			var Xs:int = X;
			var Ys:int = 68;
			
			settings.content.sortOn('order', Array.DESCENDING);
			
			var params:Object = {};
			if (App.isSocial('OK') && clickCont)
				params['glow'] = true;
			var padd:uint = 5;
			var vpadd:uint = 25;
			var itemNum:int = 0;
			var profitList:Array = [30, 50, 80, 100, 125];
			profitList.reverse();
			for (var i:uint = paginator.startCount; i < paginator.finishCount; i++) {
				
				var item:*
				
				params['profitValue'] = 0;
				
				params.isBestsell = (i == 0)?true:false;
				params.isActionGained = false/*(true)?true:false;*/

				if(i < profitList.length)
				params['profitValue'] = 0;/*profitList[i]*/;
				settings.content[i]['id'] = i;
				item = new SetItem(settings.content[i], this, params);
				
				bodyContainer.addChild(item);
				//item.x = Xs;
				//item.x = Xs;
				//item.y = Ys + padd;
				var mod:int = (i % 2);
				item.x = Xs + (item.settings.width + padd) * (i % 2) + padd+10;
				item.y = Ys + (item.settings.height + vpadd) * (int(i / 2)) + padd;
				
				items.push(item);
				
				//Xs += item.background.width + 2;
				//if (itemNum == int(settings.itemsOnPage / 2) - 1)	{
					//Xs = X;
					//Ys += item.background.height + 12;
				//}
				itemNum++;
				
				//setItemLabel(item);
			}
			
			
			if (settings.section == 101)
				return;
			
			settings.page = paginator.page;
			
		}
		
		public function removePremiumFlags():void {
			for (var i:int = 0; i < arrLabels.length; i++ ) {
				bodyContainer.removeChild(arrLabels[i]);
				arrLabels[i] = null;
			}
			arrLabels.splice(0, arrLabels.length);
			arrLabels = [];
			
			for (i = 0; i < arrHoles.length; i++ ) {
				bodyContainer.removeChild(arrHoles[i]);
				arrHoles[i] = null;
			}
			arrHoles.splice(0, arrHoles.length);
			arrHoles = [];
		}
		
		public function DrawMoney():void {
			//paginatorType = history.section;
			/*settings["itemsOnPage"] = 6;
			paginator.onPageCount = settings.itemsOnPage;
			paginator.itemsCount = settings.content.length;
			paginator.update();*/
			
			for each(var _item:* in items) {
				if(_item && _item.parent){
					bodyContainer.removeChild(_item);
					_item.dispose();
				}
			}
			
			removePremiumFlags();
			
			var profitList:Array = [30, 50, 80, 100, 125];
			if (App.isSocial('YB','GN')) {
				if (history.section == COINS)
					profitList = [25, 87.5, 100, 125];
				else 
					profitList = [25, 50, 81.25, 100, 125];
			}
			profitList.reverse();
			items = [];
			var X:int = 55;
			var Xs:int = X;
			var Ys:int = 60;
			
			settings.content.sortOn('order', Array.DESCENDING);
			
			var params:Object = {};
			if (App.isSocial('OK') && clickCont)
				params['glow'] = true;
			var padd:uint = 7;
			var itemNum:int = 0;
			
			//params['profitValue'] = 0;
			
			params.isBestsell = false;
			params.isActionGained = false;
			
			if (timeToActionEnd > App.time)
				params.isBestsell = true;
				
			for (var i:uint = paginator.startCount; i < paginator.finishCount; i++) {
				params['profitValue'] = profitList[i];
				var item:* = new BankUsualItem(settings.content[i], this, params);
				
				bodyContainer.addChild(item);
				//item.x = Xs;
				item.x = Xs;
				item.y = Ys + (item.settings.height + padd) * i + padd;
				
				items.push(item);
				
				//Xs += item.background.width + 2;
				//if (itemNum == int(settings.itemsOnPage / 2) - 1)	{
					//Xs = X;
					//Ys += item.background.height + 12;
				//}
				itemNum++;
				
				setItemLabel(item);
			}
			
			
			if (settings.section == 101)
				return;
			
			
			settings.page = paginator.page;
		}
		
		override public function contentChange():void {
			if (history.section == 'Sets') {
				DrawSets();
			}else {
				DrawMoney();
			}
		}

		private var arrLabels:Array = [];
		private var arrHoles:Array = [];
		private function setItemLabel(item:*):void 
		{
			if (item.isLabel1) {
				
				if (App.lang != 'ru') {
					if (App.lang != 'jp') {
						makeLabel(item, UserInterface.textures.labelBDEng);
					}else {
						makeLabel(item, UserInterface.textures.labelBDJap);
					}
				}else {
					makeLabel(item, UserInterface.textures.labelBD1);
				}
			}
			if (item.isLabel2) {
				if (App.lang != 'ru') {
					if (App.lang != 'jp') {
						makeLabel(item, UserInterface.textures.labelUCEng);
					}else {
						makeLabel(item, UserInterface.textures.labelUCJap);
					}
				}else {
					makeLabel(item, UserInterface.textures.labelUC1);
				}
			}
			
			addLabels();
		}
		
		private function addLabels():void 
		{
			for (var i:int = 0; i < arrLabels.length; i++ ) {
				var label:Sprite = arrLabels[i];
				bodyContainer.addChild(label);
				
			}
		}
		
		private function makeLabel(item:BankUsualItem, btmd:BitmapData):void
		{
			var cont:Sprite = new Sprite();
			var hole:Bitmap = new Bitmap(UserInterface.textures.hole);
			hole.x = item.x + item.settings.width - 23;
			hole.y = item.y /*+ item.height / 2 - 23*/+15;
			bodyContainer.addChild(hole);
			arrHoles.push(hole);
			
			var label:Bitmap = new Bitmap(btmd);
			label.smoothing = true;
			//label.rotation = -50;
			cont.addChild(label);
			
			cont.rotation = -50;
			cont.x = item.x + item.settings.width - 41 + 4;
			cont.y = item.y + 32 + 8;
			
			setTimeout(function():void {
				TweenLite.to(cont, 2, {x:cont.x - 6, y:cont.y - 8, rotation: -30, ease:Elastic.easeOut } );
			}, 200);
			
			arrLabels.push(cont);
		}
		
		override public function drawArrows():void {
			
			paginator.drawArrow(bodyContainer, Paginator.LEFT,  0, 0, { scaleX: -1, scaleY:1 } );
			paginator.drawArrow(bodyContainer, Paginator.RIGHT, 0, 0, { scaleX:1, scaleY:1 } );
			
			var y:Number = (settings.height - paginator.arrowLeft.height) / 2 - 10;
			paginator.arrowLeft.x = -35;
			paginator.arrowLeft.y = y-5;
			
			paginator.arrowRight.x = settings.width - paginator.arrowLeft.width + 35;
			paginator.arrowRight.y = y-5;
			
			paginator.y = settings.height - 44;
		}
		
		override public function close(e:MouseEvent=null):void {
			App.self.setOffTimer(updateDuration);
			App.self.dispatchEvent(new AppEvent(AppEvent.ON_CLOSE_BANK));
			if(giftCardButton && giftCardButton.parent)
				giftCardButton.removeEventListener(MouseEvent.CLICK, ExternalApi.onCardInfo);
			
			super.close(e);
		}
		
		static public function set currentBuyObject(value:Object):void
		{
			_currentBuyObject = value;
		}
		
		static public function get currentBuyObject():Object
		{
			return _currentBuyObject;
		}
		
		// SecurityFurry
		//private var secretFurry:OnAction;
		//private var clickTime:int = 0;
		//private function moveFurry():void {
			//TweenLite.to(secretFurry, 0.5, {x:-secretFurry.width + 75, y:secretFurry.y});
		//}
		//private function drawSecretFurry():void {
			//var haveBonus:Boolean = false;
			//if (App.data.hasOwnProperty('bonus')) {
				//for (var s:* in App.data.bonus) {
					//if (App.data.bonus[s].type == 'MPayment') {
						//haveBonus = true;
					//}
				//}
			//}
			//if (!haveBonus) return;
			//
			//secretFurry = new OnAction();
			//layer.addChildAt(secretFurry, 0);
			//layer.swapChildren(secretFurry, layer.getChildAt(0));
			//secretFurry.x = bodyContainer.x +40;
			//secretFurry.y = settings.height - secretFurry.height - 20;
			//
			//clickTime = App.time;
			//App.self.setOnTimer(addFurry);
		//}
		//private function addFurry():void {
			//var duration:int = 1;
			//var time:int = duration - (App.time - clickTime);
			//if (time < 0) {
				//App.self.setOffTimer(addFurry);
				//moveFurry();
				//clickTime = App.time;
				//App.self.setOnTimer(addText);
			//}
		//}
		//
		//private function addText():void {
			//var duration:int = 0.5;
			//var time:int = duration - (App.time - clickTime);
			//
			//if (time < 0) {
				//App.self.setOffTimer(addText);
				//
				//secretFurry.drawBody(2);
				//
				//clickTime = App.time;
				//App.self.setOnTimer(next);
				//
				//function next():void {
					//var duration:int = 1;
					//var time:int = duration - (App.time - clickTime);
					//if (time < 0) {
						//App.self.setOffTimer(next);
						//secretFurry.drawBody(3);
						//secretFurry.addEventListener(MouseEvent.CLICK, onSecretFurryClick);
					//}	
				//}
			//}
		//}
		//private function onSecretFurryClick(e:MouseEvent):void {
			////new BanksBonusWindow().show();
			//close();
		//}
	}
}


import core.Load;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.filters.GlowFilter;
import flash.text.TextField;
import ui.UserInterface;
import wins.Window;

internal class OnAction extends Sprite{
	
	private var skin:Bitmap,
				skinData:BitmapData,
				skinData1:BitmapData,
				skinData2:BitmapData,
				textBack:Bitmap,
				text:TextField,
				state:int,
				icon:Bitmap,
				iconCont:Sprite;
				
	public var actionSid:String = "140",
			   clicked:Boolean = false;
	
	public function OnAction() {
		drawBody();
	}
	
	public function drawBody(_state:int = 1):void
	{
		state = _state;
		if (skin == null) {
			skin = new Bitmap();
			skinData1 = Window.textures.furOff;
			skinData2 = Window.textures.furOn;
		}
		addChild(skin);
		
		iconCont = new Sprite();
		icon = new Bitmap();
		addChild(iconCont);
		iconCont.addChild(icon);
		
		switch (state) 
		{
			case 1:
			case 2:
					skin.bitmapData = skinData1;
			break;
			case 3:
				skin.bitmapData = skinData2;
				if (textBack != null && text!= null) {
					removeChild(textBack);
					removeChild(text);
				}
				addIcon(new Bitmap(UserInterface.textures.tresure));
				//Load.loading(Config.getIcon(App.data.storage[actionSid].type, App.data.storage[actionSid].preview), addIcon);
			break;
		}		
		
		if (state == 2) {
			addText();
		}
	}
	
	private function addIcon(data:Bitmap):void 
	{
		icon.bitmapData = data.bitmapData;
		icon.scaleX = icon.scaleY = 0.27;
		icon.smoothing = true;
		iconCont.filters = [new GlowFilter(0xe1a63e, 1, 8, 8, 6)];
		iconCont.y = skin.y + (skin.height - iconCont.height) / 2 + 45;
		iconCont.x += 10;
	}
	
	private function addText():void 
	{
		textBack = new Bitmap(Window.textures.textBubble);
		textBack.x = skin.x - textBack.width + 85;
		textBack.y = skin.y + textBack.height + 55;
		addChild(textBack);
		
		
		text = Window.drawText(Locale.__e("flash:1409912913722"), {
			color:0x603a23,
			borderColor:0xffe8c4,
			borderSize:3,
			fontSize:24,
			autoSize:"center"
		});
		addChild(text);
		text.x = textBack.x + (textBack.width - text.width) / 2;
		text.y = textBack.y + (textBack.height - text.height) / 2 + 8;
	}
}