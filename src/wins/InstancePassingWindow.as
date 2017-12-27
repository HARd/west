package wins 
{
	import adobe.utils.CustomActions;
	import buttons.Button;
	import buttons.ImageButton;
	import buttons.ImagesButton;
	import buttons.MoneyButton;
	import com.adobe.images.BitString;
	import com.flashdynamix.motion.extras.BitmapTiler;
	import com.google.analytics.utils.Variables;
	import com.greensock.TweenMax;
	import core.Post;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import ui.Hints;
	import ui.UserInterface;
	import units.Missionhouse;
	import wins.actions.BanksWindow;
	import wins.elements.BankMenu;
	/**
	 * ...
	 * @author ...
	 */
	public class InstancePassingWindow extends BuildingWindow 
	{
		//private var bodyContainer:Sprite = new Sprite();;
		private var backgound:Bitmap;
		private var title:TextField;
		public var arrOutItems:Array = [];
		private var outsCont:Sprite = new Sprite();
		private var info:Object;
		private var timeToEnd:int;
		private var startTime:int;
		private var persSidArr:Array = [];
		
		public function InstancePassingWindow(settings:Object=null) 
		{
			if (settings == null) {
				settings = new Object();
			}
			Missionhouse.windowOpened = true;
			info = settings;
			//addChild(bodyContainer);
			
			//drawBack();
			settings["width"] = 686;
			settings["height"] = 516;
			settings["hasPaginator"] = false;
			settings['title'] = info.target.roomInfo.title;
			
			super(settings);
			
			timeToEnd = info.roomInfo.time - App.data.storage[info.roomInfo.sID].term * getNumFriends();
			//info;
			drawTime();
			startTime = info.target.startTime;
			App.self.setOnTimer(work);
			
			drawHeroes();
			for (var key:* in App.user.rooms) {
				
				if (key == info.target.roomInfo.id) {
					for (var hr:* in App.user.rooms[key].pers) {
						persSidArr.push(App.user.rooms[key].pers[hr]);
						setHeroInto(App.user.rooms[key].pers[hr], true);
					}
				}
			}
			persSidArr;
			drawFriendsInfo();
			drawOuts();
			drawButton();
			showPersonages();
		}
		
		
		override public function drawBackground():void
		{
			backgound = new Bitmap(Window.textures.treasureBackground);
			layer.addChild(backgound);
			exit.x = backgound.x + backgound.width - 50;
			exit.y = 7;
			titleLabel.y += 10;
			drawMirrowObjs('diamondsTop', settings.width / 2 - settings.titleWidth / 2 - 5, settings.width / 2 + settings.titleWidth / 2 + 5, -25, true, true);
		}
		
		private var container:Sprite;
		private function showPersonages():void {
			container = new Sprite();
			var stand:Bitmap
			var icon:Bitmap;
			var persID:int;
			for (var i:int = 0; i < persSidArr.length; i++) 
			{
				stand = new Bitmap(Window.textures.buildingsActiveBacking);
				stand.scaleX = stand.scaleY = 0.8;
				//stand.alpha = 0.8;
				stand.x = 0 + (stand.width * i) + (15 * (i + 1));
				stand.smoothing = true;
				
				switch(App.data.storage[persSidArr[i]].preview) {
				case "man":
					icon =  new Bitmap(UserInterface.textures.manIcon);
					icon.x = stand.x + (stand.width - icon.width) / 2;
					icon.y = stand.y + (stand.height - icon.height) / 2 - 5;
				break;
				case "woman":
					icon =  new Bitmap(UserInterface.textures.womanIcon);
					icon.x = stand.x + (stand.width - icon.width) / 2 - 5;
					icon.y = stand.y + (stand.height - icon.height) / 2 - 7;
				break;
				case "stumpy":
					icon =  new Bitmap(UserInterface.textures.stumpyInstanceIco);
					icon.x = stand.x + (stand.width - icon.width) / 2 + 2;
					icon.y = stand.y + (stand.height - icon.height) / 2 - 12;
				break;
				case "bronco":
					icon =  new Bitmap(UserInterface.textures.engineerInstanceIco);
					icon.x = stand.x + (stand.width - icon.width) / 2 + 2;
					icon.y = stand.y + (stand.height - icon.height) / 2 - 12;
				break;
				default:
					icon =  new Bitmap(UserInterface.textures.womanIcon);
				}
			
			
			container.addChild(stand);
			container.addChild(icon);
		}
		
		stand.y = 0;
		
		bodyContainer.addChild(container);
		container.x = (settings.width - container.width) / 2 - 10;
		container.y = (settings.height - container.height) / 2 + 20;
		bodyContainer.addChild(container);
		}
		
		private var arrHeroes:Array = [];
		private var heroesCont:Sprite = new Sprite();
		public function drawHeroes():void
		{
			var xMargin:int = 60;
			var yMargin:int = 80;
			var paddingX:int = 0;
			var paddingY:int = 0;
			
			for (var i:int = 0; i < info.roomInfo.count; i++ ) {
				var hero:HeroItem = new HeroItem(i + 1, {target:this});
				arrHeroes.push(hero);
				if (i == 1) {
					paddingX = 23;
					paddingY = 37;
				}else if(i == 0){
					paddingX = 13;
					paddingY = 18;
				}else {
					paddingX = -40;
					paddingY = -20;
				}
				hero.x = xMargin * i + paddingX;
				hero.y = yMargin * i - paddingY;
				heroesCont.addChild(hero);
			}
			
			bodyContainer.addChild(heroesCont);
			//heroesCont.y = App.self.stage.stageHeight / 2 - 500;
			//heroesCont.x = App.self.stage.stageWidth / 2 + 150;
			heroesCont.x = (settings.width - heroesCont.width) / 2;
			heroesCont.y = (settings.height - heroesCont.height) / 2;
		}
		
		private function drawButton():void
		{
			var price:int = Math.ceil((startTime + timeToEnd - App.time) / App.data.options['SpeedUpPrice']);
			bttnImproveTime = new MoneyButton({
					caption			:Locale.__e('flash:1382952380104'),
					width			:180,
					height			:56,	
					fontSize		:28,
					fontCountSize	:28,
					countText		:String(price),
					multiline		:false,
					radius			:20,
					iconScale		:0.67,
					fontBorderColor:0x4d7d0e,
					fontCountBorder:0x4d7d0e
			});
				var txtWidth:int = bttnImproveTime.textLabel.width;
				//bttnImproveTime.textLabel.y -= 12;
				bttnImproveTime.textLabel.x = -30;
				//bttnImproveTime.coinsIcon.y += 12;
				bttnImproveTime.coinsIcon.x = bttnImproveTime.textLabel.x + bttnImproveTime.textLabel.textWidth + 10;
				//bttnImproveTime.countLabel.y += 12;
				bttnImproveTime.countLabel.x = bttnImproveTime.coinsIcon.x + bttnImproveTime.coinsIcon.width + 5;
				txtWidth = bttnImproveTime.textLabel.width;
				//if ((bttnImproveTime.coinsIcon.width + 6 + bttnImproveTime.countLabel.width) > txtWidth) {
					//txtWidth = bttnImproveTime.coinsIcon.width + 6 + bttnImproveTime.countLabel.width;
					//bttnImproveTime.textLabel.x = (txtWidth - bttnImproveTime.textLabel.width) / 2;
				//}
				bttnImproveTime.topLayer.x = (bttnImproveTime.settings.width - txtWidth) / 2;
				
			bttnImproveTime.x = (settings.width - bttnImproveTime.width) / 2;
			bttnImproveTime.y = settings.height - 75;
			
			bttnImproveTime.addEventListener(MouseEvent.CLICK, onImproveTime);
			
			bodyContainer.addChild(bttnImproveTime);
		}
		
		private function onImproveTime(e:MouseEvent):void 
		{
			if (bttnImproveTime.mode == Button.DISABLED) return;
			var price:int = Math.ceil((startTime + timeToEnd - App.time) / App.data.options['SpeedUpPrice']);
			if (!App.user.stock.takeAll( { 5:price } )) {
				close();
				BankMenu._currBtn = BankMenu.REALS;
				BanksWindow.history = { section:'Reals', page:0 };
				new BanksWindow().show();
				return;
			}
			
			Hints.minus(Stock.FANT, price, Window.localToGlobal(bttnImproveTime), true, this);
			bttnImproveTime.state = Button.DISABLED;
			
			Post.send({
				ctr:'missionhouse',
				act:'boost',
				uID:App.user.id,
				rID:info.roomInfo.id,
				type:'time'
			}, onImproveTimeComplete);
		}
		
		private function onImproveTimeComplete(error:int, data:Object, params:Object):void
		{
			if (error) {
					Errors.show(error, data, params);
					return;
				}
				
			if(App.user.rooms[info.roomInfo.id]['times'])
				App.user.rooms[info.roomInfo.id]['times'] ++;
			else
				App.user.rooms[info.roomInfo.id]['times'] = 1;
				
			startTime -= App.data.storage[info.roomInfo.id].time;
			info.target.updateTime(startTime);
			App.user.rooms[info.roomInfo.id].time = startTime;
			
			//App.ui.upPanel.setTimeToPersIcons(startTime, timeToEnd, info.target.sid);
			
			var time:int = startTime + timeToEnd - App.time;
			if (time > 0 && bttnImproveTime)
				bttnImproveTime.state = Button.NORMAL;
			close();
			
		}
		
		
		
		private function drawTime():void
		{
			timeContainer = new Sprite();
			var text:TextField  = Window.drawText(Locale.__e("flash:1405692111488"), {
				fontSize:28,
				color:0xFFFFFF,
				autoSize:"center",
				borderColor:0x6e3e0e
			});
			bodyContainer.addChild(text);
			text.x = (settings.width - text.width) / 2;
			text.y = settings.height - 180;
			
			var glowing:GlowFilter = new GlowFilter(0x6d3c14, 1, 4, 4, 8, 1, false, false);
			
			timeWork = Window.drawText(TimeConverter.timeToStr(timeToEnd), {//TimeConverter.timeToCuts(settings.roomInfo.time, true, true), {
				fontSize:50,
				color:0xfdfc7d,
				fontBorderSize:5,
				autoSize:"left",
				borderColor:0xc1892c
			});
			timeContainer.addChild(timeWork);
			bodyContainer.addChild(timeContainer);
			timeContainer.filters = [glowing];
			timeContainer.x = ( settings.width - timeContainer.width) / 2;
			timeContainer.y = settings.height - 150;
			//timeWork.text = TimeConverter.timeToStr((startTime + timeToEnd) - App.time);
			//bodyContainer.addChild(timeContainer);
			
		}
		
		public function work():void 
		{
			var time:int = startTime + timeToEnd - App.time;
			//var time:int = timeToEnd + App.time;
			if (time < 0) time = 0;
			timeWork.text = TimeConverter.timeToStr(time);
			//timeWork.x = -timeWork.width / 2;
			
			//if (time <= 0) {
				//isWork = false;
				//close();
			//}
		}
		
		private function drawOuts():void 
		{
			arrOutItems = [];
			var bgWidth:int = 242;
			//var bgHeight:int = 0;
			
			var itemsCont:Sprite = new Sprite();
			var count:int = 0;
			for (var key:* in info.roomInfo.outs) {
				var item:OutItem = new OutItem( { id:key, count:info.roomInfo.outs[key], target:this.info, window:this } );
				item.scaleX = item.scaleY = 0.9;
				item.updateProgress();
				arrOutItems.push(item);
				itemsCont.addChild(item);
				count++;
			}
			
			//if (count > 4) {
				//bgHeight = 270
			//}
			//else if (count > 2) {
				//bgHeight = 210;
			//}else {
				//bgHeight = 150;
			//}
			
			var underBg:Bitmap = Window.backing2(173, 236, 45, 'questTaskBackingTop', 'questTaskBackingBot');
			underBg.alpha = 0.2;
			//underBg.alpha = 1;
			outsCont.addChildAt(underBg, 0);
			//underBg.x = -22;
			
			
			var outsTitle:TextField = Window.drawText(Locale.__e("flash:1393580758703"), {
				fontSize:24,
				color:0xFFFFFF,
				autoSize:"left",
				borderColor:0x6a3e17
			});
			outsCont.addChild(outsTitle);
			outsTitle.x = (underBg.width - outsTitle.textWidth) / 2;
			outsTitle.y = underBg.y - 30;
			
			var arr:Array = [];
			for (var i:int = 0; i < arrOutItems.length; i++ ) {
				if (arrOutItems[i].count > 1) {
					arr.push(arrOutItems[i]);
					arrOutItems.splice(i, 1);
					i--;
				}
			}
			for ( i = 0; i < arrOutItems.length; i++ ) {
				arr.push(arrOutItems[i]);
			}
			arrOutItems.splice(0, arrOutItems.length);
			
			arrOutItems = arr;
			
			setPosition();
			outsCont.addChild(itemsCont);
			itemsCont.x = (bgWidth - itemsCont.width) / 2 - 15;
			itemsCont.y = 16;
			
			//outsCont.x = App.self.stage.stageWidth / 2 - 370;
			//outsCont.y = bottomBg.y + 32;
			outsCont.x = 45;
			outsCont.y = 85;
			//outsCont.y = 50;
			bodyContainer.addChild(outsCont);
		}
		
		
		
		public var arrHeroesSids:Array = [];
		public function setHeroInto(sid:int, addNow:Boolean = false):void 
		{
			var isPlased:Boolean = false;
			for ( var i:int = 0; i < arrHeroes.length; i++ ) {
				if (arrHeroes[i].empty) {
					arrHeroes[i].addHero(sid);
					arrHeroesSids.push(sid)
					//updateOuts();
					//updateBttns();
					// Убираем перса из списка
					//hidePersonage(sid);
					
					isPlased = true;
					break;
				}
			}
			
			if (!isPlased && arrHeroes.length > 0) {
				arrHeroes[0].onClose();
				arrHeroes[0].addHero(sid);
				arrHeroesSids.push(sid)
				//updateOuts();
				//updateBttns();
				// Убираем перса из списка
				//hidePersonage(sid);
			}
			
			//checkChooseText();
			
			//if (App.user.quests.tutorial)
				//App.tutorial.focusOnInstanseStart();
		}
		
		
		
		private function setPosition():void 
		{
			var posX:int = -10;
			var posy:int = 0;
			var Xs:int = -10;
			var Ys:int = 0;
			var count:int = 0;
			
			for (var i:int = 0; i < arrOutItems.length; i++ ) {
				
				arrOutItems[i].x = Xs;
				arrOutItems[i].y = Ys;
				
				Xs += arrOutItems[i].bg.width + 5;
				if (count == 1)	{
					Xs = posX;
					Ys += arrOutItems[i].bg.height - 5;
					count = 0;
				}else {
					count++;
				}
			}
			opened = false;
		}
		
		override public function drawBody():void 
		{
			
		}
		
		private function onExit(e:MouseEvent):void 
		{
			
		}
		
		private var inviteBttn:Button;
		private var friendsCont:Sprite = new Sprite();
		private var iconCont:ImagesButton;
		private var descFriends:TextField;
		private var rewardFriendsCont:Sprite = new Sprite();
		private var descFriendBonus:TextField;
		private var countFriends:TextField;
		//private var timeContainer:Sprite;
		private var timeWork:TextField;
		private var bttnImproveTime:MoneyButton;
		private var timeContainer:Sprite;
		
		public function drawFriendsInfo():void
		{
			var underBg:Bitmap = Window.backing2(173, 236, 45, 'questTaskBackingTop', 'questTaskBackingBot');
			underBg.alpha = 0.2;
			//underBg.alpha = 1;
			friendsCont.addChild(underBg);
			//underBg.x = -22;
			
			var title:TextField = Window.drawText(Locale.__e("flash:1393580724851") + ":", {
				fontSize:24,
				color:0xffffff,
				autoSize:"left",
				borderColor:0x734418
			});
			friendsCont.addChild(title);
			
			title.x = (underBg.width - title.textWidth) / 2;
			title.y = underBg.y - 30;
			
			countFriends = Window.drawText(String(getNumFriends()), {
				fontSize:40,
				color:0xffffff,
				autoSize:"left",
				borderColor:0x734418
			});
			friendsCont.addChild(countFriends);
			//iconCont.addChild(countFriends);
			
			
			iconCont = new ImagesButton( Window.textures.buildingsSlot, UserInterface.textures.friendsIcon, { 
				description		:"Облачко",
				params			:{ }
			});
			iconCont.iconBmp.y -= 10;
			iconCont.addEventListener(MouseEvent.CLICK, onShowFriens);
			
			iconCont.iconBmp.x += 3;
			iconCont.iconBmp.y += 4;
			
			iconCont.x = (underBg.width - iconCont.width) / 2 - 20;
			iconCont.y = title.textHeight - 15;
			friendsCont.addChild(iconCont);
			countFriends.x = iconCont.x + iconCont.width + 10;
			countFriends.y = iconCont.y + iconCont.height/2 - countFriends.textHeight/2;
			
			iconCont.tip = function():Object {
				return {
					title: Locale.__e('flash:1393580830674'),
					text: Locale.__e('flash:1393580862810')
				}
			};
			
			descFriends = Window.drawText(Locale.__e("flash:1405950547691"), {
				fontSize:22,
				color:0xf7fed5,
				autoSize:"center",
				borderColor:0x6b4013,
				multiline:true
			});
			descFriends.wordWrap = true;
			descFriends.width = 160;
			friendsCont.addChild(descFriends);
			
			descFriends.x = (underBg.width - descFriends.textWidth) / 2;
			descFriends.y = iconCont.y + iconCont.height - 5;
			
			inviteBttn = new Button( {
				caption:        Locale.__e('flash:1405687804221'),
				width:          140,
				height:         40,
				fontSize:		24,
				bgColor:		[0xffdf92,0xfdaf64],	
				borderColor:	[0xffeed8,0xc37841],
				bevelColor:		[0xffeed8,0xc37841],
				fontColor:0xffffff,
				fontBorderColor:0x9d5b38
			});
			friendsCont.addChild(inviteBttn);
			inviteBttn.x = (underBg.width - inviteBttn.width) / 2;
			inviteBttn.y = descFriends.y + descFriends.textHeight + 35;
			
			inviteBttn.addEventListener(MouseEvent.CLICK, onInvite);
			
			descFriendBonus = Window.drawText(Locale.__e("flash:1393580922905"), {
				fontSize:24,
				color:0xfefefe,
				autoSize:"left",
				borderColor:0x734318,
				multiline:true
			});
			friendsCont.addChild(descFriendBonus);
			descFriendBonus.x = (underBg.width - descFriendBonus.textWidth) / 2;
			descFriendBonus.y = iconCont.y + iconCont.height - 6;
			
			var iconChance:Bitmap = new Bitmap(UserInterface.textures.clever);
			//var iconTime:Bitmap = new Bitmap(Window.textures.timerYellow);
			//iconTime.scaleX = iconTime.scaleY = 1.2;
			//iconTime.smoothing = true;
			
			var chanceTxt:TextField = Window.drawText(String(getNumFriends()), {
				fontSize:34,
				color:0xfef015,
				autoSize:"left",
				borderColor:0x574003,
				multiline:true
			});
			
			//var timeTxt:TextField = Window.drawText(String(getNumFriends()), {
				//fontSize:34,
				//color:0xfef015,
				//autoSize:"left",
				//borderColor:0x574003,
				//multiline:true
			//});
			
			chanceTxt.x = iconChance.width + 3;
			chanceTxt.y = 3;
			
			//iconTime.x = chanceTxt.x + chanceTxt.textWidth + 38;
			
			//timeTxt.x = iconTime.x + iconTime.width + 3;
			//timeTxt.y = 3;
			
			rewardFriendsCont.addChild(iconChance);
			//rewardFriendsCont.addChild(iconTime);
			rewardFriendsCont.addChild(chanceTxt);
			//rewardFriendsCont.addChild(timeTxt);
			
			friendsCont.addChild(rewardFriendsCont);
			rewardFriendsCont.y = inviteBttn.y - rewardFriendsCont.height - 10;
			rewardFriendsCont.x = (underBg.width - rewardFriendsCont.width) / 2;
			
			if (getNumFriends() == 0) {
				changeVisFriends(false);
			}else {
				changeVisFriends(true);
			}
			
			friendsCont.x = settings.width - 223;
			friendsCont.y = 85;
			bodyContainer.addChild(friendsCont);
			//bottomsContainer.x = App.self.stage.stageWidth/2 - bottomsContainer.width/2 /*+ 50*/;
		}
		
		private function changeVisFriends(value:Boolean):void 
		{
			rewardFriendsCont.visible = value;
			descFriendBonus.visible = value;
			descFriends.visible = !value;
		}
		
		private function onInvite(e:MouseEvent):void 
		{
			new AskWindow(AskWindow.MODE_INVITE, {
				target:settings.target,
				title:Locale.__e('flash:1382952380197'), 
				friendException:settings.friendsData, 
				inviteTxt:Locale.__e("flash:1395846352679"),
				desc:Locale.__e("flash:1395846372271")
			} ).show();
		}
		
		private function onShowFriens(e:MouseEvent):void 
		{
			new InstanceInfoWindow({instance:info.target, target:this, friends:info.friendsData}).show();
		}
		
		public function getNumFriends():int 
		{
			var numFriends:int = 0;
			
			for (var key:* in info.friendsData) {
				numFriends++;
			}
			
			if (numFriends > info.roomInfo.limit) numFriends = info.roomInfo.limit;
			
			return numFriends;
		}
		override public function dispose():void
		{
			Missionhouse.windowOpened = false;
			super.dispose();
			
		}
		
	}

}


import buttons.ImageButton;
import buttons.SimpleButton;
import com.greensock.easing.Bounce;
import com.greensock.TweenLite;
import com.greensock.TweenMax;
import core.Load;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.filters.GlowFilter;
import flash.geom.ColorTransform;
import flash.text.TextField;
import ui.Cursor;
import ui.UserInterface;
import units.AnimationItem;
import units.Personage;
import wins.InstancePassingWindow;
import wins.Window;

internal class OutItem extends Sprite {
	
	public var settings:Object = { };
	public var bg:Bitmap;
	public var progressBar:Bitmap;
	public var progressBarColor:Bitmap;
	
	public var count:int;
	
	private var countTxt:TextField;
	
	public var maskProgress:Sprite;
	public var sprTip:LayerX = new LayerX();
	
	public function OutItem(settings:Object) {
		
		this.settings = settings;
		count = settings.count;
		
		drawBody();
		
		updateProgress();
		
		sprTip.tip = function():Object {
			return {
				title: App.data.storage[settings.id].title,
				text: App.data.storage[settings.id].description
			};
		}
		
		Load.loading(Config.getIcon(App.data.storage[settings.id].type, App.data.storage[settings.id].preview), onPreviewComplete);
	}
	
	private function onPreviewComplete(data:Bitmap):void 
	{
		var icon:Bitmap = data;
		
		switch(settings.id) {
			case Stock.COINS:
				icon.height = bg.height - 18;
				icon.scaleX = icon.scaleY;
			break;
			case Stock.EXP:
				icon.height = bg.height - 18;
				icon.scaleX = icon.scaleY;
			break;
			case Stock.FANTASY:
				icon = new Bitmap(UserInterface.textures.energyIcon/*, "auto"*/);
				icon.height = bg.height - 18;
				icon.scaleX = icon.scaleY;
			break;
			default:
				if (icon.width > icon.height) {
					icon.width = bg.width - 5;
					icon.scaleY = icon.scaleX;
				}else{
					icon.height = bg.height - 5;
					icon.scaleX = icon.scaleY;
				}
		}
		icon.smoothing = true;
		addChildAt(sprTip, 2);
		sprTip.addChild(icon);
		sprTip.x = (bg.width - sprTip.width) / 2;
		sprTip.y = (bg.height - sprTip.height) / 2 - 3;
	}
	
	public function drawBody():void
	{
		bg = new Bitmap(Window.textures.productBacking2);
		bg.width = 72; bg.height = 76;
		bg.smoothing = true;
		bg.alpha = 0.5;
		addChild(bg);
		
		progressBar = new Bitmap(Window.textures.roundProgressBar);
		progressBar.x = (bg.width - progressBar.width) / 2;
		progressBar.y = bg.height / 2 - 4;
		progressBar.alpha = 0.5;
		progressBar.smoothing = true;
		
		progressBarColor = new Bitmap(Window.textures.roundProgressBarGreen);
		progressBarColor.x = (bg.width - progressBarColor.width) / 2;
		progressBarColor.y = bg.height / 2 -2;
		progressBarColor.smoothing = true;
		progressBarColor.visible = false;
		
		addChild(progressBar);
		addChild(progressBarColor);	
		
		if(settings.count > 1){
			countTxt = Window.drawText(String(settings.count), {
				fontSize:24,
				color:0xfff116,
				autoSize:"left",
				borderColor:0x3d2500
			});
			addChild(countTxt);
			countTxt.x = (bg.width - countTxt.textWidth) / 2 - 2;
			countTxt.y = bg.height - countTxt.textHeight - 20;
		}
	}
	
	private var percent:int = 0;
	public function updateProgress(value:int = 0):void
	{
		var doGlow:Boolean = true;
		if (percent == 100) doGlow = false;
		
		if (maskProgress && contains(maskProgress)) removeChild(maskProgress);
		
		percent = 0;
		var value:int = 0;
	
		if (App.user.rooms && App.user.rooms[settings.target.roomInfo.id]) {
			//увеличение дропа, от нажатия кнопки увеличить шанс
			value = App.user.rooms[settings.target.roomInfo.id]['drop'];
			percent += value;
			
			//увеличение за счет друзей
			percent +=  settings.window.getNumFriends() * App.data.storage[settings.target.roomInfo.id].percent;
		}
		
		
		for (var i:int = 0; i < settings.window.arrHeroesSids.length; i++ ) {
			var key:int = settings.window.arrHeroesSids[i];
			if(App.data.storage[settings.id].personages[key])
				percent += App.data.storage[settings.id].personages[key];	
		}
		
		if (percent > 100)
			percent = 100;
		
		var posRadius:int = 180 - Math.round(1.8 * percent);
		
		var color:uint = setProgressColor(percent);
		
		maskProgress = drawSegment(posRadius, 180, bg.height / 2 + 5, bg.width / 2, bg.width / 2, 2, 0xEEEEEE, 0x003da8);
		addChildAt(maskProgress, 0);
		
		progressBarColor.mask = maskProgress;
		progressBarColor.visible = true;
		
		if(doGlow)customGlowing(progressBarColor, color);
	}
	
	private function customGlowing(target:*, color:uint):void {
		TweenMax.to(target, 0.6, { glowFilter: { color:color, alpha:0.8, strength: 7, blurX:12, blurY:12 }, onComplete:function():void {
			TweenMax.to(target, 0.5, { glowFilter: { color:color, alpha:0, strength:1, blurX:1, blurY:1 }, onComplete:function():void {
			}});
		}});
	}
	
	private function setProgressColor(percent:int):uint 
	{
		var color:uint;
		if (percent >= 86) {
			color = 0x73bb16;//0x18a117;
		}else if (percent >= 60) {
			color = 0x99bf38;
		}else if (percent >= 40) {
			color = 0xf3c21a;
		}else if (percent > 20) {
			color = 0xd65d22;
		}else {
			color = 0xf03d21;
		}
		
		var colorTr:ColorTransform = new ColorTransform();
		colorTr.color = color;
		
		progressBarColor.transform.colorTransform = colorTr;
		
		return color;
	}
	
	public function drawSegment(startAngle:Number, endAngle:Number, segmentRadius:Number, xpos:Number, ypos:Number, step:Number, lineColor:Number, fillColor:Number):Sprite {
		 var holder:Sprite = new Sprite();
		 
		 holder.graphics.lineStyle(2, lineColor);
		 holder.graphics.beginFill(fillColor);
		 
		 var originalEnd:Number = -1;
		 if(startAngle > endAngle){
			  originalEnd = endAngle;
			  endAngle = 360;
		 }
		 var degreesPerRadian:Number = Math.PI / 180;
		 var theta:Number;
		 startAngle *= degreesPerRadian;
		 endAngle *= degreesPerRadian;
		 step *= degreesPerRadian;

		 
		 holder.graphics.moveTo(xpos, ypos);
		 for (theta = startAngle; theta < endAngle; theta += Math.min(step, (endAngle - theta))) {
			  holder.graphics.lineTo(xpos + segmentRadius * Math.cos(theta), ypos + segmentRadius * Math.sin(theta));
		 }
		 holder.graphics.lineTo(xpos + segmentRadius * Math.cos(endAngle), ypos + segmentRadius * Math.sin(endAngle));

		 if(originalEnd > -1){ 
			  startAngle = 0;
			  endAngle = originalEnd * degreesPerRadian;
			  for (theta = startAngle; theta < endAngle; theta += Math.min(step, endAngle - theta)) {
				   holder.graphics.lineTo(xpos + segmentRadius * Math.cos(theta), ypos + segmentRadius * Math.sin(theta));
			  }
			  holder.graphics.lineTo(xpos + segmentRadius * Math.cos(endAngle), ypos + segmentRadius * Math.sin(endAngle));
		 }
		 holder.graphics.lineTo(xpos, ypos);
		 holder.graphics.endFill();
		 
		return holder;
    }
	
	public function dispose():void
	{
		if (bg && contains(bg)) removeChild(bg);
		bg = null;
		
		if (progressBar && contains(progressBar)) removeChild(progressBar);
		progressBar = null;
		
		if (progressBarColor && contains(progressBarColor)) removeChild(progressBarColor);
		progressBarColor = null;
		
		if (countTxt && contains(countTxt)) removeChild(countTxt);
		countTxt = null;
		
		if (maskProgress && contains(maskProgress)) removeChild(maskProgress);
		maskProgress = null;
	}
}



internal class HeroItem extends Sprite {
	
	public static const TYPE_1:int = 1;
	public static const TYPE_2:int = 2;
	public static const TYPE_3:int = 3;
	
	public var settings:Object = { };
	public var type:int;
	
	public var exit:ImageButton	= null;
	private var container:SimpleButton = new SimpleButton();//Sprite = new Sprite();
	
	private var _empty:Boolean = true;
	public var heroSid:int = 0;
	
	public function HeroItem(type:int, settings:Object = null) {
		
		this.settings = settings;
		this.type = type;
		drawBody();
	}
	
	//private var icon:Bitmap;
	private var icon:AnimationItem;
	private var bg:Bitmap;
	private function drawBody():void 
	{
		bg = new Bitmap(Window.textures.stand);
		//bg.width = 72; bg.height = 76;
		bg.x = -bg.width / 2;
		bg.y = -1 * bg.height / 5;
		bg.smoothing = true;
		
		exit = new ImageButton(Window.textures.closeBttn);
		exit.scaleX = exit.scaleY = 0.5;
		exit.x = bg.width - 17;
		//exit.onClick = onClose;
		
		exit.addEventListener(MouseEvent.MOUSE_UP, onClose);
		exit.visible = false;
		
		//container.addChild(bg);
		container.addEventListener(MouseEvent.MOUSE_UP, onClose);
		addChild(container);
		container.mouseEnabled = false;

		//addChild(exit);
	}
	
	public function addHero(sid:int):void
	{
		icon = new AnimationItem( {
			type:	App.data.storage[sid].type,
			view:	App.data.storage[sid].view,
			framesType:Personage.STOP,
			direction:0,
			flip:1
		}); 
		icon.x = (bg.width - icon.width) / 2 - 15;
		icon.y = (bg.height - icon.height) / 2 + 45;
		if (sid == 163)
		{
			icon.scaleX *= -0.8;
			icon.scaleY *= 0.8;
			icon.y = (bg.height - icon.height) / 2 + 40;
		}else icon.scaleX *= -1;
		heroSid = sid;
		
		//container.addChild(icon);
		empty = false;
		
		//if (!settings.target.isWork) exit.visible = true;
		
		App.ui.flashGlowing(container, 0x56ffff);
	}
	
	public function onClose(e:MouseEvent = null):void 
	{
		if (App.user.quests.tutorial)
			return;
		
		if (icon) {
			settings.target.removeHero(heroSid);
			settings.target.updateOuts();
			
			container.removeChild(icon);
			icon = null;
			empty = true;
			heroSid = 0;
			exit.visible = false;
		}
	}
	
	public function itemOff():void
	{
		this.visible = false;
	}
	
	public function exitOff():void
	{
		exit.visible = false;
	}
	
	public function getHeroSid():int
	{
		return heroSid;
	}
	
	public function get empty():Boolean 
	{
		return _empty;
	}
	
	public function set empty(value:Boolean):void 
	{
		_empty = value;
	}
	
	public function dispose():void
	{
		if (exit) {
			exit.removeEventListener(MouseEvent.MOUSE_UP, onClose);
			exit.dispose();
		}
		exit = null;
		
		if (container) {
			container.removeEventListener(MouseEvent.MOUSE_UP, onClose);
			container.dispose();
			if (contains(container)) removeChild(container);
		}
		container = null;
		
		if (bg && contains(bg) ) removeChild(bg);
		bg = null;
	}
	
}