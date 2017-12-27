package wins 
{
	import buttons.Button;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	/**
	 * ...
	 * @author ...
	 */
	public class BestFriendsWindow extends Window 
	{
		private var back:Bitmap;
		private var friendsContainer:Sprite;
		//private var friend:Friend;
		private var friendsArr:Array;
		private var friendsSidArr:Array;
		private var bestFriendsObj:Object;
		private var fid:String;
		
		
		public function BestFriendsWindow(settings:Object=null) 
		{
			if (settings == null) {
				settings = new Object();
			}
			settings['width'] = 668;
			settings['height'] = 575;
						
			settings['title'] = Locale.__e("flash:1406623755604");
			settings['hasPaginator'] = false;
			settings['hasButtons'] = false;
			super(settings);
			App.user;
			if (App.user.hasOwnProperty('bestFriends'))
				bestFriendsObj = App.user.bestFriends;
				
			var Obj:Object = { };
			for (var i:* in bestFriendsObj) {
				if (App.user.friends.data[i]) 
				{
					Obj[i] = bestFriendsObj[i];
				}
			}
			bestFriendsObj = Obj;
		}
		
		override public function drawTitle():void {
		}
		
		override public function drawBackground():void 
		{
			var background:Bitmap = backing(settings.width, settings.height, 35, "storageBackingMain");
			background.y += 40;
			layer.addChild(background);
		}
		
		override public function drawBody():void 
		{
			exit.y += 25;
			
			back = backing(612, 470, 35, "storageBackingSmall");
			back.x = (settings.width - back.width) / 2;
			back.y = (settings.height - back.height) / 2 + 40;
			bodyContainer.addChild(back);
			
			
			var titleContainer:Sprite = new Sprite();
			var titleText:TextField = Window.drawText(settings.title, {
				color		:0xffffff,
				borderColor	:0xa87749,
				textAlign	:"center",
				autoSize	:"center",
				fontSize	:48
			});
				titleContainer.addChild(titleText);
				titleText.x = (settings.width - titleText.width) / 2;
				titleText.y = (settings.height - titleText.height) / 2 - 250;
				titleContainer.filters = [new GlowFilter(0x855729, 1, 4, 4, 8, 1)];
			bodyContainer.addChild(titleContainer);
			
			drawMirrowObjs('diamondsTop', titleText.x - 5, titleText.x + titleText.width + 5,titleText.y + 10, true, true);

			
			var descLabel:TextField = Window.drawText(Locale.__e('flash:1406624169962'), {
				color		:0xffffff,
				borderColor	:0x735829,
				borderSize	:4,
				textAlign	:"center",
				autoSize	:"center",
				fontSize	:24
			});
			bodyContainer.addChild(descLabel);
			descLabel.x = (settings.width - descLabel.width) / 2;
			descLabel.y = (settings.height - descLabel.height) / 2 - 215;
			
			
			drawMirrowObjs('storageWoodenDec', 0, settings.width, settings.height - 60);
			drawMirrowObjs('storageWoodenDec', 0, settings.width, 95, false, false, false, 1, -1);
			
			drawElements(6, bestFriendsObj);
		}
		
		private function drawElements(bfCount:int, bestFriendsObj:Object = null):void 
		{
			var Xs:int = 0;
			var Ys:int = 0;
			var X:int = Xs;
			
			friendsContainer = new Sprite();
			friendsSidArr = [];
			friendsArr = [];
			
			var Obj:Object = { };
			for (var key:* in bestFriendsObj) {
				if (App.user.friends.data[key]) 
				{
					Obj[key] = bestFriendsObj[key];
				}
			}
			bestFriendsObj = Obj;
		
			for (var friendSid:* in bestFriendsObj)
			{
				friendsSidArr.push(friendSid);
			}
			for (var i:int = 0; i < bfCount; i++) 
			{
				var friend:Friend;
				fid = friendsSidArr[i];
				if (fid) {
					friend = new Friend(fid, bestFriendsObj, this);	
				}else {
					friend = new Friend("", bestFriendsObj, this);
				}
				friendsArr.push(friend);
				friendsContainer.addChild(friend);
				
				friend.x = int(Xs);
				friend.y = int(Ys);
				
				Xs += 286;
				
				if ((i - 1) % 2 == 0){
					Xs = X;
					Ys += 127 + 24;
				}
			}
			bodyContainer.addChild(friendsContainer);
			friendsContainer.x = 55;
			friendsContainer.y = 112;
		}
		
		public function refresh(bfCount:int, bestFriends:Object):void
		{
			for (var i:int = 0; i < bfCount; i++) 
			{
				friendsArr[i].dispose();
				if (friendsArr[i].parent) 
				{
					friendsArr[i].parent.removeChild(friendsArr[i]);	
				}
				friendsArr[i] = null;
			}
			friendsArr = [];
			bodyContainer.removeChild(friendsContainer);
			friendsContainer = null;
			drawElements(bfCount, bestFriends);
			
		}
		override public function dispose():void
		{
			super.dispose();
			
		}
	}
	

}
import buttons.Button;
import buttons.ImageButton;
import core.AvaLoad;
import core.Load;
import core.Post;
import core.WallPost;
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.filters.GlowFilter;
import flash.geom.Point;
import flash.text.TextField;
import ui.Hints;
import wins.BestFriendsWindow;
import wins.Window;
import wins.AskWindow;
import wins.InviteLostFriendsWindow;
import wins.ErrorWindow;

internal class Friend extends Sprite
{
	private var back:Bitmap;
	private var presentBack:Bitmap;
	private var iconBack:Bitmap;
	private var avatar:Bitmap;
	private var fid:String;
	private var bestFriends:Object;
	private var friendsStatus:int;
	private var lastVisit:int;
	private var descLabel:TextField;
	private var bestFriendsWindow:BestFriendsWindow;
	private var contentState:String;
	private var bfCount:int = 6;
	private var inviteBttn:Button;
	private var takeBttn:Button;
	private var elements:Array = [];
	private var closeBttn:ImageButton;
	private var wakeUpBttn:Button;
	
	public function Friend(_fid:String, _bestFriends:Object, _window:*)
	{
		bestFriendsWindow = _window;
		drawBack();
		if (_fid != "") {
			fid = _fid;
		}
		bestFriends = _bestFriends;
		if (bestFriends != null && fid != null) {
			friendsStatus = bestFriends[fid].status;	
			lastVisit = bestFriends[fid].reward;
		}
		
		checkState();
	}
	
	private function checkState():void 
	{  
		if (bestFriends == null || fid == null) {
			contentState = "INVITE";//1
		}
		
		if (bestFriends != null) {
			if (friendsStatus != 0 && App.time >= (lastVisit + 86400)) {//2 
				contentState = "WAKE_UP"; 
			}
			if (friendsStatus == 1 && fid != null && bestFriends[fid].reward < App.midnight){ //3
				contentState = "PRESENT";
			}
			if (friendsStatus == 0 && fid != null) {//4
				contentState = "INVITE_SEND";
			}
			if (friendsStatus == 1 && contentState != "PRESENT") {//5
				contentState = "NO_PRESENT";
			}
		}		
		drawContent(contentState ,fid);
	}
	
	private function drawBack():void 
	{
		back = Window.backing(269, 127, 25, 'itemBacking');
		addChild(back);
		elements.push(back);
	}
		
	private function drawContent(state:String, fid:String):void 
	{
		switch (state) 
		{
			case "INVITE":
					drawFriend(state);
					drawButton(state);
					drawText(state);
				break;
			case "WAKE_UP":
					drawFriend(state, fid);
					drawText(state, fid);
					drawButton(state);
					drawClose();
				break;
			case "PRESENT":
					drawFriend(state, fid);
					drawText(state, fid);
					//drawPresent();
					drawButton(state);
					drawClose();
				break;
			case "INVITE_SEND":
					drawFriend(state, fid);
					drawText(state, fid);
					drawClose();
				break;
			case "NO_PRESENT":
					drawFriend(state, fid);
					drawText(state, fid);
					drawClose();
				break;
		}
	}
	
	//private var iconBm:Bitmap = new Bitmap();
	
	//public var preloader:Preloader = new Preloader();
	//
	//private function drawPresent(sid:int = 6, count:int = 12):void 
	//{
		//presentBack = Window.backing(129, 108, 15, 'shopBackingSmall2');
		//presentBack.x = back.x + (back.width - presentBack.width) / 2 + back.width / 5;
		//presentBack.y = back.y + (back.height - presentBack.height)/ 2;
		//addChild(presentBack);
		//
		//preloader.x = presentBack.x + (presentBack.width - preloader.width)/ 2 + 60;
		//preloader.y = presentBack.y + (presentBack.height - preloader.height) / 2 + 60;
		//addChild(preloader);
		//Load.loading(Config.getIcon(App.data.storage[sid].type, App.data.storage[sid].preview), onLoadIcon);
		//addChild(iconBm);
		//
		//var countText:TextField = Window.drawText(String(count), {
				//color		:0xfcfad9,
				//borderColor	:0x764a3e,
				//textAlign	:"center",
				//autoSize	:"center",
				//fontSize	:30
			//}); 
		//countText.x = presentBack.x + presentBack.width - 40;
		//countText.y = presentBack.y + presentBack.height - 40;
		//addChild(countText);
	//}
	//private function onLoadIcon(data:Bitmap):void 
	//{
		//removeChild(preloader);
		//iconBm.bitmapData = data.bitmapData;
		//
		//iconBm.x = 140;
		//iconBm.y = 20;
	//}
	
	private function drawText(state:String, fid:String = null):void 
	{
		var text:String = Locale.__e("flash:1406628379562");
		var textLabel:TextField = Window.drawText(text, {
				color		:0x773c18,
				borderColor	:0xffffff,
				textAlign	:"center",
				autoSize	:"center",
				fontSize	:24
			});
		
	// 1contentState = "INVITE";
	//2contentState = "WAKE_UP"; 
	//3contentState = "PRESENT";
	//4contentState = "INVITE_SEND";
	//5contentState = "NO_PRESENT";
		switch (state) 
		{
			case "INVITE":
				textLabel.x = back.x + (back.width - textLabel.width) / 2 + 10;
				textLabel.y = back.y + 10;
				addChild(textLabel);
				elements.push(textLabel);
			break;
			case "WAKE_UP":
				textLabel.text = Locale.__e("flash:1406634797278");
				textLabel.multiline = true;
				textLabel.wordWrap = true;
				textLabel.textColor = 0x624512;
				textLabel.borderColor = 0xf0d6ab;
				textLabel.width = 100;
				textLabel.x = back.x + (back.width - textLabel.width) / 2 + 50;
				textLabel.y = back.y + 10;
				addChild(textLabel);
				elements.push(textLabel);
			break;
			case "PRESENT":
				textLabel.text = (App.user.friends.data[fid].first_name | App.user.friends.data[fid].aka)+"";
				textLabel.x = iconBack.x + (iconBack.width - textLabel.width) / 2;
				textLabel.y = 10;
				
				descLabel = Window.drawText(Locale.__e("flash:1406796969703"), {
				color		:0x773c18,
				borderColor	:0xffffff,
				textAlign	:"center",
				autoSize	:"center",
				//wrap		:true,
				//multiline	:true,
				//width		:110,
				fontSize	:24
				});
				descLabel.x = iconBack.x + (iconBack.width - descLabel.width) / 2 + 113;
				descLabel.y = back.y + (back.height - descLabel.height) / 2 - 17;
				
				addChild(textLabel);
				addChild(descLabel);
				elements.push(textLabel);
				elements.push(descLabel);
			break;
			case "INVITE_SEND":
				textLabel.text = App.user.friends.data[fid].first_name || "non";
				textLabel.x = back.x + (back.width - textLabel.width) / 2;
				textLabel.y = 10;
				
				descLabel = Window.drawText(Locale.__e("flash:1406648774876"), {
					color		:0x624616,
					borderColor	:0xffffff,
					borderSize	:0,
					textAlign	:"center",
					autoSize	:"center",
					wrap		:true,
					multiline	:true,
					width		:110,
					fontSize	:24
				});
				descLabel.x = iconBack.x + (iconBack.width - descLabel.width) / 2 + 110;
				descLabel.y = back.y + (back.height - descLabel.height) / 2 + 10;
				
				addChild(textLabel);
				addChild(descLabel);
				elements.push(textLabel);
				elements.push(descLabel);
			break;
			case "NO_PRESENT":
				textLabel.text = App.user.friends.data[fid].first_name || "non";
				textLabel.x = iconBack.x + (iconBack.width - textLabel.width) / 2;
				textLabel.y = 10;
				
				descLabel = Window.drawText(Locale.__e("flash:1406798915337"), {
				color		:0x624616,
				borderColor	:0xffffff,
				borderSize	:0,
				textAlign	:"center",
				autoSize	:"center",
				wrap		:true,
				multiline	:true,
				width		:110,
				fontSize	:24
				});
				descLabel.x = iconBack.x + (iconBack.width - descLabel.width) / 2 + 110;
				descLabel.y = back.y + (back.height - descLabel.height) / 2;
				
				addChild(textLabel);
				addChild(descLabel);
				elements.push(textLabel);
				elements.push(descLabel);
			break;
		}
		
	}

	private function drawButton(state:String):void 
	{
		switch (state) 
		{
			case "INVITE":
					inviteBttn  = new Button( {
					bevelColor		:[0xdbf3f3, 0x739dac],
					bgColor			:[0xade7f1, 0x91c8d5],
					fontColor		:0xffffff,
					fontBorderColor	:0x53828f,
					fontBorderSize	:3,
					width			:130,
					height			:50,
					fontSize		:26,
					caption			:Locale.__e("flash:1382952380197")
				});				
				addChild(inviteBttn);
				elements.push(inviteBttn);
				inviteBttn.x = 120;
				inviteBttn.y = back.y + (back.height - inviteBttn.height) / 2 + 10;
				var friendsCount:int;
				for (var friend:* in bestFriends) {
					friendsCount++;
				}
				if (friendsCount >= 6) {
					inviteBttn.state = Button.DISABLED;
				}
				inviteBttn.addEventListener(MouseEvent.CLICK, onInvite);
			break;
			case "WAKE_UP":
				wakeUpBttn  = new Button( {
					bevelColor		:[0xffeee2, 0xc07841],
					bgColor			:[0xffde93, 0xffaf63],
					fontColor		:0xffffff,
					fontBorderColor	:0xa05d36,
					fontBorderSize	:3,
					width			:130,
					height			:50,
					fontSize		:26,
					caption			:Locale.__e("flash:1406634917036")
				});				
				addChild(wakeUpBttn);
				elements.push(wakeUpBttn);
				wakeUpBttn.x = 120;
				wakeUpBttn.y = back.y + (back.height - wakeUpBttn.height) / 2 + 30;
				wakeUpBttn.addEventListener(MouseEvent.CLICK, onWakeUp);
			break;
			case "PRESENT":
				takeBttn  = new Button( {
					bevelColor		:[0xfeee7b, 0xbf7e1a],
					bgColor			:[0xf5d058, 0xeeb431],
					fontColor		:0xffffff,
					fontBorderColor	:0x814f31,
					fontBorderSize	:3,
					width			:130,
					height			:50,
					fontSize		:26,
					caption			:Locale.__e("flash:1382952379786")
				});				
				addChild(takeBttn);
				elements.push(takeBttn);
				
				takeBttn.x = 115;
				takeBttn.y = back.y + (back.height - takeBttn.height) / 2 + 27;
				takeBttn.addEventListener(MouseEvent.CLICK, onTakePresent);
			break;
		}
	}
	
	private function drawClose():void 
	{
		closeBttn = new ImageButton(Window.textures.closeBttnSmall);	
		addChild(closeBttn);
		elements.push(closeBttn);
		closeBttn.x = back.x + back.width - closeBttn.width / 2 - 10;
		closeBttn.y = back.y - 5;
		closeBttn.addEventListener(MouseEvent.CLICK, onDelete);
		
	}

	private function drawFriend(state:String, fid:String = null):void 
	{
		iconBack = new Bitmap(Window.textures.bFFAv);
		
		iconBack.filters = [new GlowFilter(0xbc934b, 1, 7, 7, 5, 1)];
		addChild(iconBack);
		elements.push(iconBack);
		iconBack.x = 30;
		iconBack.y = back.y + (back.height - iconBack.height) / 2 + 10;
		switch (state) 
		{
			case "INVITE":
			break;
			case "WAKE_UP":
			case "PRESENT":
			case "INVITE_SEND":
			case "NO_PRESENT":
				iconBack.y = back.y + (back.height - iconBack.height) / 2 + 10;
				avatar = new Bitmap();
				addChild(avatar);
				elements.push(avatar);
				App.self.setOnTimer(checkOnLoad);
			break;
		}
	}
	
	private function checkOnLoad():void 
	{	
		if (fid != null) {
			if (App.user.friends.data[fid].hasOwnProperty('first_name'))
			{
				App.self.setOffTimer(checkOnLoad);
				//removeChild(preloader);
				drawAvatar();
			}
		}
		
	}
	
	private function drawAvatar():void
	{
		var sender:Object = App.user.friends.data[fid];
		
		new AvaLoad(App.user.friends.data[fid].photo, onAvaLoad);
	}
	
	private function onAvaLoad(data:Bitmap):void
	{
		var iconMask:Bitmap  = new Bitmap(Window.textures.bFFAv);
		iconMask.x = 30;
		iconMask.y = back.y + (back.height - iconMask.height) / 2 + 10;
		
		avatar.scaleX = avatar.scaleY = 1.4;
		avatar.bitmapData = data.bitmapData;
		avatar.smoothing = true;
		avatar.x = iconMask.x + (iconMask.width - avatar.width) / 2;
		avatar.y = iconMask.y + (iconMask.height - avatar.height) / 2;

			
		addChild(iconMask);
		elements.push(iconMask);
		avatar.mask = iconMask;
	}
	
	
	private function onInvite(e:MouseEvent):void 
	{
		if (inviteBttn.mode == Button.DISABLED)
			return
		trace("Приглашаем в лучшие друзья");
		var friendException:Object = new Object();
		for (var friend:* in bestFriends) {
			friendException[friend] = friend;
		}
		new AskWindow(AskWindow.MODE_INVITE_BEST_FRIEND, {
		//new InviteLostFriendsWindow(/*AskWindow.MODE_INVITE_BEST_FRIEND, */{
				title:Locale.__e('flash:1406630729567'), 
				width:616,
				height:460, 
				fontColor:0xffffff, 
				fontBorderColor:0x5b2a7a, 
				fontSize:32, 
				itemsOnPage:10, 
				//desc:Locale.__e("flash:1406643533177"),
				friendException:friendException
			}, callback ).show();
	}
	
	private function callback(fid:String):void
	{
		Post.send( {
					ctr:'bestfriends',
					act:'invite',
					uID:App.user.id,
					fID:fid
				}, onInviteBestFriend);
	}
	
	private function onInviteBestFriend(error:*, result:*, params:Object):void
	{
		if (error) {
			Errors.show(error, result);
			return;
		}
		App.user.bestFriends = result.bestfriends;
		bestFriendsWindow.refresh(bfCount, result.bestfriends);
	}
	
	private function onWakeUp(e:MouseEvent):void 
	{
		trace("Напоминаем об игре лучшему другу");
		WallPost.makePost(WallPost.BFFREMIND, { fID:fid} ); 
	}
	
	private function onTakePresent(e:MouseEvent):void 
	{	
		
		if (e.target.mode == Button.DISABLED) return;
		
		takeBttn.state = Button.DISABLED;
		trace("Принимаем подарок");
		Post.send( {
			ctr:'bestfriends',
			act:'storage',
			uID:App.user.id,
			fID:fid
		}, onStoragePresent);
	}
	
	private function drawStockFullWin():void 
	{
		var winSettings:Object = {
			text				:Locale.__e('flash:1406817330037'),
			buttonText			:Locale.__e('flash:1382952380298'),
			image				:Window.textures.errorStorage,
			imageX				: -78,
			imageY				: -76,
			textPaddingY        : -18,
			textPaddingX        : -10,
			hasExit             :true,
			faderAsClose        :true,
			faderClickable      :true,
			closeAfterOk        :true,
			isPopup             :true,
			bttnPaddingY        :25
		};
		
		new ErrorWindow(winSettings).show();
	}
	
	private function onStoragePresent(error:*, result:*, params:Object):void
	{
		if (error) {
			Errors.show(error, result);
			return;
		}
		
		if (result.bonus) {
			for (var bns:* in result.bonus) {
				App.user.stock.add(bns, result.bonus[bns]);
			}
			var pnt:Point = Window.localToGlobal(takeBttn);
			var pntThis:Point = new Point(pnt.x, pnt.y + 10);
			Hints.plus(bns, result.bonus[bns], pntThis, false);
			
			var item:BonusItem = new BonusItem(bns, 0);
			var point:Point = Window.localToGlobal(takeBttn);
			item.cashMove(point, App.self.windowContainer);
		}
		App.user.bestFriends[fid].reward = result.reward;
		bestFriendsWindow.refresh(bfCount, App.user.bestFriends);
	}
	
	private function onDelete(e:MouseEvent):void 
	{
		trace("Удаляем из лучших друзей");
		//delete(bestFriends[fid]);
		Post.send( {
					ctr:'bestfriends',
					act:'delete',
					uID:App.user.id,
					fID:fid
				}, onRejectBestFriend);
	}
	private function onRejectBestFriend(error:*, result:*, params:Object):void
	{
		if (error) {
			Errors.show(error, result);
			return;
		}
		
		App.user.bestFriends = result.bestfriends;
		bestFriendsWindow.refresh(bfCount, result.bestfriends);
	}
	
	public function dispose():void
	{
		if (inviteBttn != null)
			inviteBttn.removeEventListener(MouseEvent.CLICK, onInvite);
		if (takeBttn != null)
			takeBttn.removeEventListener(MouseEvent.CLICK, onTakePresent);
		if (wakeUpBttn != null)
			wakeUpBttn.removeEventListener(MouseEvent.CLICK, onWakeUp);
		if (closeBttn != null)
			closeBttn.removeEventListener(MouseEvent.CLICK, onDelete);
			
		for (var i:int = 0; i < elements.length; i++)
		{
			removeChild(elements[i]);
		}
		
		
		
	}
	
}