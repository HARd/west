package wins 
{
	import buttons.IconButton;
	import buttons.ImageButton;
	import buttons.MoneyButton;
	import buttons.SimpleButton;
	import buttons.UpgradeButton;
	import core.Log;
	import core.Post;
	import units.Storehouse;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import ui.Hints;
	import ui.UserInterface;
	import units.Moneyhouse;
	import flash.utils.setTimeout;
	
	public class MoneyHouseWindow extends Window
	{
		private var arrFriends:Array = [];
		public var level:int = 0;
		
		private var openRooms:int = 0;
		
		private var upgradeBttn:UpgradeButton;
		
		private var crafted:int;
		private var timeToFinish:int;
		
		public function MoneyHouseWindow(settings:Object = null) 
		{
			if (settings == null) {
				settings = new Object();
			}
			settings['title'] = settings.title || 'Жилой дом';
			settings['width'] = 620;
			settings['height'] = 400;
			
			settings['background'] = 'tradepostBacking';
			settings['itemsOnPage'] = 7;
			settings["hasPaginator"] = true;
			settings['hasButtons'] = false;
			
			super(settings);
			
			level = settings.target.level;
			
			for (var fr:* in App.user.friends.data) {
				arrFriends.push(fr);
			}
			
			crafted = settings.target.crafted;
			timeToFinish = settings.info.devel.req[level].tm;
			
			getFriends();
			
		}
		
		private var backGround:Bitmap;
		override public function drawBackground():void 
		{	
			if (settings.info.sID == 177) 
			{
				settings.height = 600;
			}
			backGround = backing(settings.width, settings.height, 50, settings.background);
				layer.addChild(backGround);
				backGround.y -= 10;
			
			upperBackground = new Bitmap(Window.textures.storageUpperBacking);
				upperBackground.width = backGround.width - 5;
				layer.addChildAt(upperBackground,0);
				upperBackground.x = 0;
				upperBackground.y = -68;
				
			moneyBack = new Sprite();
				layer.addChild(moneyBack);	
				moneyBack.graphics.beginFill(0xf1c886);
				moneyBack.graphics.lineStyle(3, 0x885829);
				moneyBack.graphics.drawRoundRect(0, 0, 210, 50, 50);
				moneyBack.graphics.endFill();
				moneyBack.x = (settings.width - moneyBack.width) / 2;
				moneyBack.y = -10;
				
				titleLabel.y = -65;
				
			if(!settings.target.isConcierge)
				drawConcierge();
			else
				drawCurrrentConcierge();
		}
		
		override public function drawArrows():void {
				
			paginator.drawArrow(bodyContainer, Paginator.LEFT,  0, 0, { scaleX: -1, scaleY:1 } );
			paginator.drawArrow(bodyContainer, Paginator.RIGHT, 0, 0, { scaleX:1, scaleY:1 } );
			
			var y:Number = (settings.height - paginator.arrowLeft.height) / 2;
			paginator.arrowLeft.x = -paginator.arrowLeft.width/2 + 26;
			paginator.arrowLeft.y = y;
			
			paginator.arrowRight.x = settings.width-paginator.arrowRight.width/2 - 26;
			paginator.arrowRight.y = y;
			
			paginator.arrowLeft.y += 30;
			paginator.arrowRight.y += 30;
			
			paginator.arrowLeft.visible = false;
			paginator.arrowRight.visible = false;
		}
		
		override public function drawBody():void
		{
			this.y += 30;
			fader.y -= 30;
			//exit.x -= 8;
			exit.y -= 30;
			
			updatePaginator();
			
			drawMirrowObjs('diamondsTop', settings.width / 2 - settings.titleWidth / 2 - 5, settings.width / 2 + settings.titleWidth / 2 + 5, -100, true, true);
			
			
			drawDesc();
			
			drawProgress();
			
			var txtInfo:TextField = Window.drawText(Locale.__e("flash:1393581355710"), {
				fontSize:26,
				color:0xffffff,
				textAlign:"left",
				borderColor:0x816331
			});
			txtInfo.width = txtInfo.textWidth + 5;
			txtInfo.x = (settings.width - txtInfo.textWidth) / 2;
			txtInfo.y = 48;
			bodyContainer.addChild(txtInfo);
			
			createItems();
			
			if (level < settings.target.totalLevels) drawBttn();
		}
		
		private function drawCurrrentConcierge():void 
		{
			var icon:Bitmap = new Bitmap(Window.textures.doorMan1);
			bodyContainer.addChild(icon);
			icon.x = settings.width - 78;
			icon.y = settings.height - icon.height - 50;
			
			drawHelpButton();
		}
		
		private var bttnHelp:IconButton;
		private var hireBttn:MoneyButton;
		private function drawConcierge():void 
		{
			var icon:Bitmap = new Bitmap(Window.textures.doorMan2);
			var icoHolder:LayerX = new LayerX();
			icoHolder.addChild(icon)
			App.ui.staticGlow(icoHolder, { alpha:1, color:0xf7d61b, strength:30 } );
			
			icoHolder.tip = function():Object {
				return{
					title:Locale.__e('flash:1415112768617'),
					text:Locale.__e('flash:1415112804427')
				}
			}
			
			bodyContainer.addChild(icoHolder);
			icon.x = settings.width - 78;
			icon.y = settings.height - icon.height - 50;
			
			hireBttn = new MoneyButton( {
					caption		:Locale.__e('flash:1382952379751'),
					width		:150,
					height		:44,	
					fontSize	:24,
					countText	:String(App.data.storage[settings.target.sid].require[Stock.FANT]),
					multiline	:true,
					hasDotes    :false,
					greenDotes  :false,
					fontColor:				0xffffff,				
					fontBorderColor:		0x4d7d0e,
					fontCountSize: 24,
					fontCountColor	: 0xffffff,				
					fontCountBorder : 0x4d7d0e	
			});
			hireBttn.x = settings.width - hireBttn.width/2 - 8;
			hireBttn.y = settings.height - hireBttn.height - 50;
			
			bodyContainer.addChild(hireBttn);
			
			hireBttn.addEventListener(MouseEvent.CLICK, onHire);
			
			drawHelpButton();
		}
		
		private function drawHelpButton():void
		{
			bttnHelp = new IconButton(Window.textures.helpButton, {caption:''});
			bttnHelp.x = settings.width - bttnHelp.width - 104;
			bttnHelp.y = settings.height - bttnHelp.height - 50;
			bodyContainer.addChild(bttnHelp);
			
			bttnHelp.addEventListener(MouseEvent.CLICK, onHelp);
		}
		
		private function onHelp(e:MouseEvent):void 
		{
			new ConciergeHelpWindow({title:Locale.__e('flash:1410429947661')}).show();
		}
		
		private function onHire(e:MouseEvent):void 
		{
			settings.target.hireConcierge();
			close();
			setTimeout(function():void { new ConciergeHelpWindow( { type:'description' ,title:Locale.__e('flash:1410429947661') } ).show(); },1000 );
		}
		
		private function drawBttn():void 
		{
			upgradeBttn = new UpgradeButton(UpgradeButton.TYPE_ON,{
				caption: Locale.__e("flash:1393581373716"),
				widthButton:278,
				height:55,
				icon:Window.textures.upgradeArrow,
				fontBorderColor:0x002932,
				countText:"",
				fontSize:28,
				iconScale:0.95,
				radius:30,
				textAlign:'left',
				widthButton:230
			});
			//upgradeBttn.textLabel.x += 18;
			upgradeBttn.coinsIcon.x += 1;
			bodyContainer.addChild(upgradeBttn);
			upgradeBttn.x = (settings.width - upgradeBttn.width) / 2;
			if (settings.info.sID == 177) 
			{
				upgradeBttn.y = settings.height - 115;
			}	else
				upgradeBttn.y = settings.height - 115;
			
			//upgradeBttn.textLabel.x += 16;
			//
			//upgradeBttn.coinsIcon.x += 26;
			//upgradeBttn.countLabel.x += 83; upgradeBttn.countLabel.y += 10;
			//upgradeBttn.textLabel.x += 6;
			
			upgradeBttn.addEventListener(MouseEvent.CLICK, onUpgradeEvent);
			
			if (!settings.canBoost)
				upgradeBttn.visible = false;
		}
		
		private function onUpgradeEvent(e:MouseEvent):void 
		{
			new ConstructWindow( {
				title:settings.target.info.title,
				upgTime:settings.upgTime,
				request:settings.target.info.devel.obj[settings.target.level + 1],
				target:settings.target,
				win:this,
				onUpgrade:onUpgradeAction,
				hasDescription:true
			}).show();
		}
		
		private function onUpgradeAction(obj:Object = null, $fast:int = 0):void
		{
			if ($fast > 0)
			{
				settings.target.upgradeEvent(settings.request, $fast);
			}else
				settings.target.upgradeEvent(settings.target.info.devel.obj[settings.target.level + 1]);
				
			close();
		}
		
		private function updatePaginator():void 
		{
			settings.target
			settings.info
			var rooms:int = 1;
			openRooms = 1;
			
			for (var lvl:* in settings.info.devel.req) {
				if (lvl <= level) openRooms += settings.info.devel.req[lvl].c;
				
				rooms += settings.info.devel.req[lvl].c;
			}
			
			paginator.page = 0;
			paginator.onPageCount = settings.itemsOnPage;
			paginator.itemsCount = rooms;
			paginator.update();
		}
		
		private var arrItems:Array = [];
		private var itemsCont:Sprite = new Sprite();
		private var arrFriendsIds:Array = [];
		private function createItems():void 
		{
			
			var posX:int = 15;
			var posY:int = -35;
			var count:int = 0;
			
			
			elementsCount = paginator.finishCount;

			for (var i:int = paginator.startCount +1 ; i < elementsCount; i++){
				var idFr:String = '0';
				var closed:Boolean = false;
				
				if (i >= openRooms) {
					closed = true;
				}else if (i > 0) {
					idFr = String(arrFriendsIds[i - 1]);
				}
				
				var it:FriendItem = new FriendItem(this, idFr, i, closed, openAskWindow);
				itemsCont.addChild(it);
				arrItems.push(it);
				it.x = posX;
				it.y = posY;
				
				posX += it.width + 8;
				
				if (count == 2) {
					posX = 15
					posY += it.height + 5;
				}
				count++;
			}
			
			bodyContainer.addChild(itemsCont);
			itemsCont.x = 48;//(settings.width - itemsCont.width) / 2;
			itemsCont.y = 116;
			
			//if (arrItems.length < 4) {
				//
				//if (backGround && backGround.parent) {
					//backGround.parent.removeChild(backGround);
				//}
				//
				////backGround = backing(settings.width, 420, 50, settings.background);
				////layer.addChildAt(backGround, 0);
				//
				//this.y = 100;
				//fader.y = -100;
			//}
		}
		
		private function getFriends():void 
		{
			for (var fr:* in settings.target.friends) {
				arrFriendsIds.push(fr);
			}
			
			//settings.target.countOfFriends = arrFriendsIds.length + 1;
		}
		
		private function canAddFriend(sid:int):Boolean 
		{
			if (arrFriendsIds.indexOf(sid) == -1) return true;
			return false;
		}
		
		override public function contentChange():void 
		{
			for (var i:int = 0; i < arrItems.length; i++ ) {
				var item:FriendItem = arrItems[i];
				if (item.parent) item.parent.removeChild(item);
				item.dispose();
				item = null;
			}
			arrItems.splice(0, arrItems.length);
			
			itemsCont.parent.removeChild(itemsCont);
			itemsCont = null;
			itemsCont = new Sprite();
			
			
			createItems();
		}
		
		private var timer:TextField;
		private var progressBacking:Bitmap;
		private var progressBar:ProgressBar;
		private var acselerateBttn:MoneyButton;
		private function drawProgress():void 
		{
			var container:Sprite = new Sprite();
			
			progressBacking = Window.backingShort(346, "prograssBarBacking3");
			container.addChild(progressBacking);
			
			progressBar = new ProgressBar( { win:this, width:336, isTimer:false});
			progressBar.x = progressBacking.x - 2;
			progressBar.y = progressBacking.y - 2;
			
			
			container.addChild(progressBar);
			
			timer = Window.drawText(TimeConverter.timeToStr(127), {
				color:			0xffffff,
				borderColor:	0x875522,
				fontSize:		30
			});
			
			container.addChild(timer);
			timer.y = (progressBacking.height - timer.height)/2 + 4;
			timer.x = (progressBacking.width - timer.textWidth) / 2 + 5;
			
			timer.height = timer.textHeight;
			timer.width = timer.textWidth + 10;
			
			
			acselerateBttn = new MoneyButton( {
					caption		:Locale.__e('flash:1382952380104'),
					width		:136,
					height		:44,	
					fontSize	:24,
					countText	:String(getPriceAcselerate()),
					multiline	:true,
					hasDotes    :false,
					greenDotes  :false,
					fontColor:				0xffffff,				
					fontBorderColor:		0x4d7d0e,
					fontCountSize: 24,
					fontCountColor	: 0xffffff,				
					fontCountBorder : 0x4d7d0e	
			});
			acselerateBttn.x = progressBacking.width + 14;
			
			container.addChild(acselerateBttn);
			
			acselerateBttn.addEventListener(MouseEvent.CLICK, onAcselerate);
			
			bodyContainer.addChild(container);
			container.x = (settings.width - container.width) / 2;
			container.y = 0;
			
			if (!settings.canBoost) {
				container.x += 70;
				acselerateBttn.visible = false;
			}
			
			progressBar.start();
			progress();
			App.self.setOnTimer(progress);
		}
		
		private function onAcselerate(e:MouseEvent):void 
		{
			settings.target.onBoostEvent(priceBttn);
			
			Hints.minus(Stock.FANT, priceBttn, Window.localToGlobal(acselerateBttn), false, this);
			
			close();
		}
		
		private var priceSpeed:int = 0;
		private var priceBttn:int = 0;
		private function progress():void
		{
			var leftTime:int = crafted - App.time;
			
			if (leftTime <= 0) {
				leftTime = 0;
				App.self.setOffTimer(progress);
				close();
			}
			
			timer.text = TimeConverter.timeToStr(leftTime);
			
			progressBar.progress =  (timeToFinish - leftTime) / timeToFinish;
			
			priceSpeed = Math.ceil((crafted - App.time) / App.data.options['SpeedUpPrice']);
			if (acselerateBttn && priceBttn != priceSpeed && priceSpeed != 0) {
				priceBttn = priceSpeed;
				acselerateBttn.count = String(priceSpeed);
			}
		}
		
		
		private var txtMoney:TextField;
		private var upperBackground:Bitmap;
		private var moneyBack:Sprite;
		private var elementsCount:int;
		private function drawDesc():void 
		{
			var container:Sprite = new Sprite();
			
			var descMoney:TextField = Window.drawText(Locale.__e("flash:1393581333469"), {
				fontSize:34,
				color:0xffffff,
				textAlign:"left",
				borderColor:0x62370c
			});
			descMoney.width = descMoney.textWidth + 5;
			container.addChild(descMoney);
			
			var moneyIcon:Bitmap = new Bitmap(UserInterface.textures.coinsIcon);
			moneyIcon.x = descMoney.textWidth + 12;
			container.addChild(moneyIcon);
			
			txtMoney = Window.drawText(String(getMoneyCount()), {
				fontSize:34,
				color:0xffffff,
				textAlign:"left",
				borderColor:0x62370c
			});
			txtMoney.width = txtMoney.textWidth + 40;
			txtMoney.x = moneyIcon.x + moneyIcon.width + 6;
			container.addChild(txtMoney);
			
			bodyContainer.addChild(container);
			container.x = (settings.width - container.width) / 2 + 15;
			container.y = -55;
		}
		
		public function updateReward():void
		{
			txtMoney.text = String(getMoneyCount());
		}
		
		public function openAskWindow():void
		{
			//
		}
		
		public function putFriendInto(id:String):void
		{
			var friend:Object = App.user.friends.data[id];
			friend['settle'] = 1;
			arrFriendsIds.push(id);
			settings.target.countOfFriends = arrFriendsIds.length + 1;
			if (!settings.target.friends) settings.target.friends = { };
			settings.target.friends[id] = friend;
			contentChange();
			
			updateReward();
			
			Post.send({
				ctr:settings.target.type,
				act:'settle',
				uID:App.user.id,
				id:settings.target.id,
				wID:App.user.worldID,
				sID:settings.target.sid,
				fID:id
			}, onSettle);
		}
		
		private function onSettle(error:int, data:Object, params:Object):void 
		{
			if (error) {
				Errors.show(error, data);
				return;
			}
			
		}
		
		private function getPriceAcselerate():int 
		{
			return 15;
		}
		
		private function getMoneyCount():int
		{
			var val:int = settings.info.devel.open[level][Stock.COINS] * (arrFriendsIds.length + 1);
			return val;
		}
		
		override public function dispose():void
		{
			super.dispose();
			//txtMoney = null;
			//if (upgradeBttn) upgradeBttn.dispose();
			//upgradeBttn = null;
			if (arrFriends) arrFriends.splice(0, arrFriends.length);
			if (arrFriendsIds) arrFriendsIds.splice(0, arrFriendsIds.length);
			if (arrItems) {
				for (var i:int = 0; i < arrItems.length; i++ ) {
					arrItems[i].dispose();
					arrItems[i] = null;
				}
				arrItems.splice(0, arrItems.length);
			}
			arrFriendsIds = null;
			arrFriends = null;
			arrItems = null;
		}
		
	}

}

import buttons.Button;
import com.adobe.images.BitString;
import core.AvaLoad;
import core.Log;
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.filters.GlowFilter;
import flash.text.TextField;
import units.Moneyhouse;
import wins.Window;
import wins.MoneyHouseWindow;


internal class FriendItem extends Sprite {
	
	private static const MODE_ALIEN:int = 0;
	private static const MODE_FRIEND:int = 1;
	private static const MODE_EMPTY:int = 2;
	private static const MODE_CLOSED:int = 3;
	
	public var mode:int;
	
	private var preloader:Preloader = new Preloader();
	private var friendId:String;
	private var numRoom:int;
	
	private var callBack:Function;
	private var window:MoneyHouseWindow;
	
	public function FriendItem(window:MoneyHouseWindow, id:String, numOfRoom:int, closed:Boolean = false, callBack:Function = null) 
	{
		friendId = id;
		numRoom = numOfRoom;
		this.callBack = callBack;
		this.window = window;
		
		if (numOfRoom == 0) {
			mode = MODE_ALIEN;
		}else if (closed) {
			mode = MODE_CLOSED;
		}else if (friendId != 'undefined') {
			mode = MODE_FRIEND;
		}else {
			mode = MODE_EMPTY;
		}
		
		drawBody();
	}
	
	private var bttnOpen:Button;
	private var avatar:Bitmap;
	private var maskIcon:Bitmap;
	private var bg:Bitmap;
	private var avatarBack:Bitmap
	private function drawBody():void 
	{	
		bg = new Bitmap(Window.textures.door);
			addChild(bg);
			
		switch(mode) {
			case MODE_ALIEN:
				var wicket:Bitmap = new Bitmap(Window.textures.wicket);
				wicket.x = 67;
				wicket.y = 50;
				addChild(wicket);
				drawReward();
			break;
		case MODE_FRIEND:
				avatarBack = new Bitmap(Window.textures.avatarMask);
				addChild(avatarBack);
				avatarBack.x = (bg.width - avatarBack.width) / 2;
				avatarBack.y = bg.height / 2 - avatarBack.height;
				
				var avatarGlowing:GlowFilter = new GlowFilter(0x6c502b, 1, 8, 8, 6, 1, false);
				avatarBack.filters = [avatarGlowing];
				addChild(preloader);
				preloader.x = (bg.width)/ 2;
				preloader.y = (bg.height) / 2 - 28;
				//
				avatar = new Bitmap();
				addChild(avatar);
				App.self.setOnTimer(checkOnLoad);
			
				drawReward();
			break;
			case MODE_CLOSED:
				var iconClosed:Bitmap = new Bitmap(Window.textures.closedSign);
				addChild(iconClosed);
				iconClosed.x = (bg.width - iconClosed.width) / 2;
				iconClosed.y = 123 - 85;
				
				var txtClosed:TextField = Window.drawText(Locale.__e('flash:1393581432581'), {
					color:			0xffffff,
					borderColor:	0x884f32,
					fontSize:		22
				});
				txtClosed.x = (bg.width - txtClosed.textWidth) / 2 - 2;
				txtClosed.y = 173 - 103;
				addChild(txtClosed);
			break;
			case MODE_EMPTY:
				bttnOpen = new Button( {
					width:		       96,				
					height:		       38,	
					fontColor:		   0xffffff,				
					fontBorderColor:   0x814f31,	
					caption:           Locale.__e('flash:1393580021031'),
					radius:			   18,		
					fontSize:		   25
				});
				addChild(bttnOpen);
				bttnOpen.x = (bg.width - bttnOpen.width) / 2;
				bttnOpen.y = 138;
				
				bttnOpen.addEventListener(MouseEvent.CLICK, onOpen);
				
				wicket = new Bitmap(Window.textures.wicket);
				wicket.x = 67;
				wicket.y = 50;
				addChild(wicket);
				
				//if (window.settings.target is Moneyhouse && window.settings.target.isConcierge)
					//bttnOpen.visible = false;
			break;
		}
	}
	
	private function onOpen(e:MouseEvent):void 
	{
		if (callBack != null) callBack();
	}
	
	private function drawReward():void
	{
		var back:Sprite = new Sprite();
        back.graphics.beginFill(0xe4bc77);
		back.alpha = 0.7;
        //back.graphics.lineStyle(borderSize, borderColor);
        back.graphics.drawRoundRect(28, 142, 99, 34, 40);
        back.graphics.endFill();
		addChild(back);
		
		var txtReward:TextField = Window.drawText('+' + String(window.settings.info.devel.open[window.level][Stock.COINS]), {
			color:			0xffffff,
			borderColor:	0x523b19,
			fontSize:		28,
			borderSize: 2
		});
		txtReward.x = 39;
		txtReward.y = 141;
		addChild(txtReward);
		
		var coin:Bitmap = new Bitmap(Window.textures.coin);
		coin.x = txtReward.x + txtReward.textWidth + 10;
		coin.y = 143;
		coin.scaleX = coin.scaleY = 0.8;
		coin.smoothing = true;
		addChild(coin);
	}
	
	private function checkOnLoad():void 
	{
		//Log.alert('_CHECK___friendId -= ' + friendId);
		//Log.alert(App.user.friends.data);
		if (App.user.friends.data.hasOwnProperty(friendId) && App.user.friends.data[friendId].hasOwnProperty('first_name'))
		{
			App.self.setOffTimer(checkOnLoad);
			removeChild(preloader);
			drawAvatar();
		}
	}
	
	private function drawAvatar():void
	{
		var sender:Object = App.user.friends.data[friendId];
		Log.alert('_____friendId -= ' + friendId);
		Log.alert(App.user.friends.data);
		new AvaLoad(App.user.friends.data[friendId].photo, onAvaLoad,errCall);
	}
	
	private function errCall():void {
		if(preloader.parent)
		removeChild(preloader);
	}
	private function onAvaLoad(data:Bitmap):void
	{
		var sp:Sprite = new Sprite();
		sp.graphics.beginFill(0xFF794B);
		sp.graphics.drawRoundRectComplex(0, 0, avatarBack.width, avatarBack.height, 25, 25, 1, 1); 
		sp.graphics.endFill();
		
		sp.x = (bg.width - sp.width) / 2;
		sp.y = bg.height / 2 - sp.height;
		
		avatar.scaleX = avatar.scaleY = 1.4;
		avatar.bitmapData = data.bitmapData;
		avatar.smoothing = true;
		avatar.x = (bg.width - avatar.width) / 2;
		avatar.y = 34;
			
		addChild(sp);
		avatar.mask = sp;
	}
	
	public function dispose():void
	{
		App.self.setOffTimer(checkOnLoad);
		
		if (bttnOpen) {
			bttnOpen.removeEventListener(MouseEvent.CLICK, onOpen);
			removeChild(bttnOpen);
			bttnOpen.dispose();
			bttnOpen = null;
		}
		callBack = null;
		window = null;
	}
}