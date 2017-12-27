package ui 
{
	import buttons.Button;
	import com.greensock.TweenLite;
	import core.Numbers;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.StageDisplayState;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import ui.BottomPanel;
	import buttons.ImageButton;
	import units.Mhelper;
	import wins.InvitesWindow;
	import wins.Window;
	
	public class FriendsPanel extends LayerX {
	
		public const FREE_FRIEND_CONT:int = 3;
		public const FRIENDS_LEFT_MARGIN:int = 64;
		public const FRIENDS_RIGHT_MARGIN:int = 64;
		public const FRIENDS_ITEMS_MARGIN:int = 3;
		
		public var allFriendsItems:Vector.<FriendItem> = new Vector.<FriendItem>();
		public var friendsItems:Vector.<FriendItem> = new Vector.<FriendItem>();
		private var bottomPanel:BottomPanel;
		private var bg:Bitmap;
		private var friendsCont:Sprite;
		private var friendsMask:Shape;
		public var opened:Boolean = false;
		
		public var start:int = 0;
		
		public var wishList:WishListPopUp = null;
		
		public function FriendsPanel(_parent:*) {
			bottomPanel = _parent;
			
			drawItems(width);
			initFriends();
			
			createWishList();
		}
		
		public function createWishList():void
		{
			wishList = new WishListPopUp(this);
			addChild(wishList);
			wishList.x = 52;
			wishList.y = -50;
		}
		
		public function resize(width:int = 400):void {
			drawItems(width);
			redrawFriends();
			showFriends();
		}
		
		private function dispose():void {
			
		}
		
		public var bttnPrev:ImageButton;
		public var bttnPrevSix:ImageButton;
		public var bttnPrevAll:ImageButton;
		public var bttnNext:ImageButton;
		public var bttnNextSix:ImageButton;
		public var bttnNextAll:ImageButton;
		public var exit:ImageButton;
		public var bttnBackPrev:Bitmap;
		public var bttnBackNext:Bitmap;
		
		
		private function drawBttns():void 
		{	
			if (bttnPrev) removeChild(bttnPrev);
			if (bttnPrevAll) removeChild(bttnPrevAll);
			if (bttnNext) removeChild(bttnNext);
			if (bttnNextAll) removeChild(bttnNextAll);
			
			bttnPrev 		= new ImageButton(UserInterface.textures.friendMove);
			bttnPrevAll 	= new ImageButton(UserInterface.textures.friendMoveAll);
			bttnNext 		= new ImageButton(UserInterface.textures.friendMove, {scaleX:-1});
			bttnNextAll		= new ImageButton(UserInterface.textures.friendMoveAll, {scaleX:-1});
			
			bttnPrev.addEventListener(MouseEvent.CLICK, onPrevEvent);
			bttnPrevAll.addEventListener(MouseEvent.CLICK, onPrevSixEvent);
			bttnNext.addEventListener(MouseEvent.CLICK, onNextEvent);
			bttnNextAll.addEventListener(MouseEvent.CLICK, onNextSixEvent);
			
			bttnPrev.x = bg.x + 43;
			bttnPrev.y = bg.y + 26;
			
			bttnPrevAll.x = bg.x + 33;
			bttnPrevAll.y = bg.y + 46;
			
			bttnNext.x = bg.x + bg.width - 60;
			bttnNext.y = bg.y + 26;
			
			bttnNextAll.x = bg.x + bg.width - 60;
			bttnNextAll.y = bg.y + 46;
			
			addChild(bttnPrev);
			addChild(bttnPrevAll);
			
			addChild(bttnNext);
			addChild(bttnNextAll);
		}
		
		private function onPrevEvent(e:MouseEvent):void {
			showFriends(-1);
		}
		private function onPrevSixEvent(e:MouseEvent):void {
			/*var i:int = 0;
			if (start > (friends.length - zzzfriends.length)) {
				i = start - (friends.length - zzzfriends.length);
			}else {
				i = friends.length;
			}
			showFriends(-i);*/
			showFriends(-6);
		}
		private function onNextEvent(e:MouseEvent):void {
			showFriends(+1);
		}
		private function onNextSixEvent(e:MouseEvent):void {
			/*var i:int = 0;
			if (start < (friends.length - zzzfriends.length)) {
				i = friends.length - zzzfriends.length - start;
			}else {
				i = friends.length;
			}
			showFriends(+i);*/
			showFriends(+6);
		}
		
		private var inviteMargin:int = 0;
		public var inviteBttn:ImageButton;
		private var counterBack:Bitmap;
		private var counterLabel:TextField;
		private function drawItems(width:int):void  {
			
			if (App.isSocial('YB','MX','AI','GN')) {
				width -= 60;
				if (width < 100) width = 100;
			}
			
			if (bg != null) removeChild(bg);
			bg = Window.backingShort(width, 'friendsPanelBacking');
			bg.y = -bg.height;
			addChild(bg);
			
			if (friendsCont) removeChild(friendsCont);
			if (!friendsCont) friendsCont = new Sprite();
			friendsCont.x = FRIENDS_LEFT_MARGIN;
			friendsCont.y = bg.y - 15;
			addChild(friendsCont);
			
			if (friendsMask) removeChild(friendsMask);
			friendsMask = new Shape();
			friendsMask.x = FRIENDS_LEFT_MARGIN;
			friendsMask.y = friendsCont.y - 20;
			friendsMask.graphics.beginFill(0xFF0000, 1);
			friendsMask.graphics.drawRect(0, 0, bg.width - FRIENDS_LEFT_MARGIN - FRIENDS_RIGHT_MARGIN, 110);
			friendsMask.graphics.endFill();
			addChild(friendsMask);
			friendsCont.mask = friendsMask;
			
			if (App.isSocial('YB','MX','AI','GN')) {
				if (!inviteBttn) {
					inviteBttn = drawInviteBttn();
				}else {
					removeChild(inviteBttn);
				}
				inviteBttn.x = width - 25;
				inviteBttn.y = -83;
				addChild(inviteBttn);
			}
			
			drawBttns();
			drawSearch();
		}
		
		
		public function initFriends():void {
			searchFriends();
		}
		
		private var searchBgPanel:Bitmap;
		
		private function drawSearch():void 
		{	
			if (bttnSearch != null)
				removeChild(bttnSearch);
				
			if (searchBgPanel != null)
				removeChild(searchBgPanel);
				
			bttnSearch =  new ImageButton(Window.textures.interSearchBttn);
			bttnSearch.x = bg.x + 28/* - 30*/;  
			bttnSearch.y = bg.y - 38/*- 58*/;
			
			//bttnSearch.x = bttnNextAll.x + bttnNextAll.width/2 - 44;
			//bttnSearch.y = -22;
			
			addChild(bttnSearch);
			bttnSearch.addEventListener(MouseEvent.CLICK, onSearchEvent);
			
			searchBgPanel = Window.backingShort(193, 'searchPanelBacking');
			searchBgPanel.x = bttnSearch.x /*+ 10*/;
			searchBgPanel.y =  bttnSearch.y + 1 - 20;
			addChildAt(searchBgPanel, 1);
			searchBgPanel.visible = false;
				
			bttnSearch.tip =  function():Object { return { title:Locale.__e("flash:1382952379771") }; }
			
			searchPanel.x = bttnSearch.x + 46;
			searchPanel.y =  bttnSearch.y + 10 - 20;
			addChild(searchPanel);
			
			if (searchBg != null)
			{
				searchPanel.removeChild(searchBg);
			}
			
			var searchBg:Shape = new Shape();
			searchBg.graphics.lineStyle(1, 0x47424e, 1, true);
			searchBg.graphics.beginFill(0xf3d8ab,1);
			searchBg.graphics.drawRoundRect(1, 0, 117, 18, 13, 13);
			searchBg.graphics.endFill();
			
			searchPanel.addChild(searchBg);
			
			if (bttnBreak != null)
				searchPanel.removeChild(bttnBreak);
			
			bttnBreak = new ImageButton(Window.textures.searchDeleteBttn/*, { scaleX:0.5, scaleY:0.5, shadow:true } */);	
			searchPanel.addChild(bttnBreak);
		
			bttnBreak.x = searchBgPanel.width - bttnBreak.width - 52;
			//bttnBreak.y = -2;
			bttnBreak.addEventListener(MouseEvent.CLICK, onBreakEvent);
			
			searchField = Window.drawText("",{ 
				color:0x604729,
				borderColor:0xf8f2e0,
				fontSize:16,
				input:true,
				border:false
			});
			
			searchField.width = bttnBreak.x - 2;
			searchField.height = searchField.textHeight + 2;
			searchField.x = 3;
			searchField.y = 0;
			
			searchPanel.addChild(searchField);
			searchPanel.visible = false;
			
			searchField.addEventListener(Event.CHANGE, onInputEvent);
			searchField.addEventListener(FocusEvent.FOCUS_IN, onFocusEvent);
			//searchField.addEventListener(TextEvent.TEXT_INPUT, onInputEvent);
		}
		
		private function onFocusEvent(e:FocusEvent):void {
			if (App.self.stage.displayState != StageDisplayState.NORMAL) {
				App.self.stage.displayState = StageDisplayState.NORMAL;
			}
		}
		private function onInputEvent(e:Event):void 
		{
			searchFriends(e.target.text);
		}
		
		private function onSearchEvent(e:MouseEvent):void {
			if (!searchPanel.visible) {
				searchField.text = "";
				
				TweenLite.to(bttnSearch, 0.5, {y:bttnSearch.y - 20, onComplete:function():void{
					searchPanel.visible = !searchPanel.visible;
					searchBgPanel.visible = !searchBgPanel.visible;
				} } );
			}else {
				TweenLite.to(bttnSearch, 0.5, { y:bttnSearch.y + 20 } );
				searchPanel.visible = !searchPanel.visible;
				searchBgPanel.visible = !searchBgPanel.visible;
				searchFriends();
			}
			
			//searchPanel.visible = !searchPanel.visible;
			//searchBgPanel.visible = !searchBgPanel.visible;
			
		}
		
		private function onBreakEvent(e:MouseEvent):void
		{
			searchField.text = "";
			searchFriends();
			searchPanel.visible = false;
			searchBgPanel.visible = !searchBgPanel.visible;
			TweenLite.to(bttnSearch, 0.5, { y:bttnSearch.y + 20 } );
		}
		
		public var friends:Array = [];
		public var zzzfriends:Array = [];
		public var searchPanel:Sprite = new Sprite();
		public var bttnSearch:ImageButton;
		public var bttnBreak:ImageButton;
		public var searchField:TextField;
		public function searchFriends(query:String = ""):void {
			friends = [];
			var friend:Object;
			zzzfriends = [];
			query = query.toLowerCase();
			var bot:Object;
			if(query == ""){
				for each(friend in App.user.friends.data){
					if (friend.uid == "1") {
						bot = friend;
					}else{
						if ((friend['lastvisit'] != undefined && friend.lastvisit < (App.time - App.data.options['LastVisitDays'])))
							zzzfriends.push(friend);
						else 
							friends.push(friend);
					}
				}
			}else {
				for each(friend in App.user.friends.data){
					if (!friend.hasOwnProperty('first_name') || !friend.hasOwnProperty('last_name')) {
						if (
							friend.aka.toLowerCase().indexOf(query) == 0 ||
							friend.uid.toString().toLowerCase().indexOf(query) == 0
						){
							if (friend.uid == "1") {
								bot = friend;
							}else{
								if ((friend['lastvisit'] != undefined && friend.lastvisit < (App.time - App.data.options['LastVisitDays'])))
									zzzfriends.push(friend);
								else 
									friends.push(friend);
							}
						}
					} else {
						if (
							friend.aka.toLowerCase().indexOf(query) == 0 ||
							friend.first_name.toLowerCase().indexOf(query) == 0 ||
							friend.last_name.toLowerCase().indexOf(query) == 0 ||
							friend.uid.toString().toLowerCase().indexOf(query) == 0
						){
							if (friend.uid == "1") {
								bot = friend;
							}else {
								if ((friend['lastvisit'] != undefined && friend.lastvisit < (App.time - App.data.options['LastVisitDays'])))
									zzzfriends.push(friend);
								else 
									friends.push(friend);
							}
						}
					}
				}
			}
		//	start = 0;
			
			zzzfriends.sortOn("level", Array.NUMERIC | Array.DESCENDING);
			
			friends.sortOn("level", Array.NUMERIC | Array.DESCENDING);
			var buf:Array = friends.concat(zzzfriends);
			friends = buf;
			if(bot){
				friends.unshift(bot);
			}
			
			showFriends();
		}
		private function redrawFriends():void {
			// Clear
			while (friendsItems.length > 0) {
				var item:FriendItem = friendsItems.shift();
				item.dispose();
			}
			
			for (var i:int = 0; i < friends.length; i++) {
				var friend:Object = friends[i];
				if (String(friend.id) == '1') continue;
				
				friendsItems.push(new FriendItem(this, friends[i]));
			}
			
			// Invite items
			var freeFriendCont:int = FREE_FRIEND_CONT;
			if (count > friendsItems.length + FREE_FRIEND_CONT)
				freeFriendCont = count - friendsItems.length;
			
			for (i = 0; i < freeFriendCont; i++) {
				friendsItems.push(new FriendItem(this, null));
			}
			
			//
			for (i = 0; i < friendsItems.length; i++) {
				friendsItems[i].x = margin + (margin + friendsItems[0].width) * i;
				friendsCont.addChild(friendsItems[i]);
			}
		}
		
		private function get count():int {
			if (friendsItems.length == 0) return  Math.floor((bg.width - FRIENDS_RIGHT_MARGIN - FRIENDS_LEFT_MARGIN) / 71);
			var _count:Number = (bg.width - FRIENDS_RIGHT_MARGIN - FRIENDS_LEFT_MARGIN) / friendsItems[0].width;
			if (_count < 1) _count = 0;
			
			return Math.floor(_count);
		}
		private function get margin():Number {
			var _count:Number = (bg.width - FRIENDS_RIGHT_MARGIN - FRIENDS_LEFT_MARGIN) / friendsItems[0].width;
			if (_count < 0) _count = 0;
			var _margin:Number = (bg.width - FRIENDS_RIGHT_MARGIN - FRIENDS_LEFT_MARGIN) * ((_count % 1) / _count) / Math.floor(_count + 1);
			
			return _margin;
		}
		
		private var moveTween:TweenLite;
		public function showFriends(shift:int = 0):void {
			if (friendsItems.length == 0) return;
			
			start += shift;
			
			if (start >= friends.length + FREE_FRIEND_CONT - count)
				start = friends.length + FREE_FRIEND_CONT - count;
			
			if (start <= 0) start = 0;
			
			redrawFriends();
			// Загрузка иконок
			for (var i:int = 0; i < friendsItems.length; i++) {
				if (i < start || i >= start + count) continue;
				friendsItems[i].load();
			}
			
			if (moveTween)
				moveTween.kill();
			
			moveTween = TweenLite.to(friendsCont, 0.2, { x: FRIENDS_LEFT_MARGIN - start * (friendsItems[0].w + margin), onComplete:function():void {
				moveTween = null;
			}} );
		}
		
		private function selectFriendItem(target:* = null):void
		{
			for each(var item:* in friendsItems)
			{
				if (item == target)
				{
					var scale:Number = 1.15;
					item.y = 24;
					item.x = item.px - 4;
					item.width = item.w * scale;
					item.height = item.h * scale;
				}
				else
				{
					item.width = item.w;
					item.height = item.h;
					item.y = 34;
					item.x = item.px
				}
			}
		}
		public function close(e:MouseEvent):void {
			App.ui.bottomPanel.hideFriendsPanel();
		}
		
		public function onVisitEvent(e:MouseEvent):void {
			if (Mhelper.waitForTarget) {
				Mhelper.waitForTarget = false;
				Mhelper.waitWorker.unselectPossibleTargets();
			}
			App.ui.eventIconCheck();
			if (App.user.quests.tutorial && !Tutorial.tutorialBttn(e.currentTarget))
				return;
			
			if (e.currentTarget.friend == null) 
			{
				onInviteEvent();
				return;
			}
			Travel.friend = e.currentTarget.friend;
			Travel.onVisitEvent(User.HOME_WORLD, true);
		}
		
		public function onInviteEvent(e:MouseEvent = null):void {
			bottomPanel.onInviteEvent(e);
		}
		
		private function drawInviteBttn():ImageButton {
			var imageBttn:ImageButton = new ImageButton(UserInterface.textures.friendFreeSlot);
			imageBttn.addEventListener(MouseEvent.CLICK, onInvite);
			
			var titleLabel:TextField = Window.drawText(Locale.__e('flash:1415782880933'), {
				fontSize:		16,
				color:			0xfcefc3,
				borderColor:	0x80480f,
				autoSize:		'center'
			});
			titleLabel.x = (imageBttn.width - titleLabel.width) / 2;
			titleLabel.y = 68;
			imageBttn.addChild(titleLabel);
			
			counterBack = new Bitmap(UserInterface.textures.counterBacking, 'auto', true);
			counterBack.x = 70;
			counterBack.y = 45;
			counterBack.name = 'counterBack';
			counterBack.visible = false;
			imageBttn.addChild(counterBack);
			
			counterLabel = Window.drawText('', {
				fontSize:		18,
				color:			0xfdfcc6,
				borderColor:	0x2d5d73,
				textAlign:		'center',
				width:			40
			});
			counterLabel.x = counterBack.x + (counterBack.width - counterLabel.width) / 2;
			counterLabel.y = counterBack.y + (counterBack.height - counterLabel.height) / 2 + 2;
			counterLabel.name = 'counter';
			counterLabel.visible = false;
			imageBttn.addChild(counterLabel);
			
			return imageBttn;
		}
		public function updateInviteCounter(e:Event = null):void {
			if (!App.invites || !App.invites.inited) return;
			
			var count:int = /*Numbers.countProps(App.invites.invited); +*/ Numbers.countProps(App.invites.requested);
			if (count > 0) {
				counterLabel.text = String(count);
				counterLabel.visible = true;
				counterBack.visible = true;
			}else {
				counterLabel.visible = false;
				counterBack.visible = false;
			}
		}
		private function onInvite(e:MouseEvent):void {
			if (App.user.mode == User.OWNER)
				new InvitesWindow().show();
		}
	}
}

import buttons.ImageButton;
import com.greensock.TweenLite;
import core.AvaLoad;
import core.Load;
import core.Log;
import core.TimeConverter;
import flash.display.Bitmap;
import flash.display.Shape;
import flash.display.Sprite;
import flash.display.StageDisplayState;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.filters.DropShadowFilter;
import flash.filters.GlowFilter;
import flash.text.TextField;
import flash.utils.Timer;
import silin.filters.ColorAdjust;
import ui.UserInterface;
import wins.GiftItemWindow;
import wins.GiftWindow;
import wins.SimpleWindow;
import wins.Window;

internal class FriendItem extends LayerX {
	
	public var sprite:Sprite = new Sprite();
	public var avatar:Bitmap = new Bitmap(null, "auto", true);
	public var legs:Bitmap = new Bitmap(UserInterface.textures.friendVisited);
	public var zzz:Bitmap = new Bitmap(UserInterface.textures.interSleepIco);
	public var friend:Object;
	
	public var w:uint = 0;
	public var h:uint = 0;
	public var px:Number = 0;
	
	public var type:String;
	
	public var friendsBackingBmp:Bitmap;
	public var friendsPanel:*;
	
	public var uid:String;
	
	public function FriendItem(panel:*, friend:Object = null, type:String = 'default'):void {
		this.friend = friend;
		this.type = type;
		this.friendsPanel = panel;
		
		if(friend != null && friend.hasOwnProperty('uid'))
			uid = friend.uid;
		
		friendsBackingBmp = new Bitmap(UserInterface.textures.friendFreeSlot);
		addChild(friendsBackingBmp);
		
		if(friend != null){
			
			var first_Name:String = '';
			if (friend.first_name && friend.first_name.length > 0)
				first_Name = friend.first_name;
			else if (friend.aka && friend.aka.length > 0) {
				first_Name = friend.aka;
			}
			
			//Log.alert('FIRST NAME' + first_Name);
			if (first_Name.indexOf(' ') > 0) first_Name = first_Name.substring(0, first_Name.indexOf(' '));
			var name:TextField = Window.drawText(first_Name, App.self.userNameSettings( {
				width:			friendsBackingBmp.width + 6,
				fontSize:		16,
				color:			0xffffff,
				borderColor:	0x5d411e,
				autoSize:		"center",
				textAlign:		"center",
				multiline:		true,
				wrap:			true,
				shadowSize:		1.5
			}));
			
			addChild(sprite);
			sprite.x = 11;
			sprite.y = 10;
			sprite.addChild(avatar);
			addChild(name);
			
			name.x = (friendsBackingBmp.width - name.width) / 2;
			name.y = -10;
			
			var star:Bitmap = new Bitmap(UserInterface.textures.friendsLevel);
			star.smoothing = true;
			star.x = width - star.width - 4;
			star.y = height - star.height - 6;
			addChild(star);
			
			var level:TextField = Window.drawText(String(friend.level || 0), {
				fontSize:		17,
				color:			0x643113,
				borderSize:		0,
				autoSize:		'left',
				multiline:		true,
				wrap:			true
			});
			level.x = star.x + star.width / 2 - level.width / 2 - 1;
			level.y = star.y + 2;
			addChild(level);
			
			addChild(zzz);
			zzz.visible = false;
			zzz.y = star.y - 40;
			zzz.x = 15;
			
			addChild(legs);
			legs.visible = false;
			legs.y = star.y + 2;
			legs.x = 3;
			legs.filters = [new GlowFilter(0xd8c5a6, 1, 2, 2, 5, 1)];
			
			if (friend['visited'] != undefined && friend.visited > App.midnight) {
				legs.visible = true;
			}
			if ((friend['lastvisit'] != undefined && friend.lastvisit < (App.time - App.data.options['LastVisitDays'])) && friend.uid != '1'){
				zzz.visible = true;	
				
				if (App.isSocial('YB','MX','SP','HV','YN','AI','GN')) {
					zzz.visible = false;	
				}
			}
		}else {
			friendsBackingBmp.bitmapData = UserInterface.textures.friendFreeSlot;
			var textLabel:String = Locale.__e('flash:1382952379777');
			if(type == 'manage'){
				textLabel = Locale.__e('flash:1382952379778');
			}
			var text:TextField = Window.drawText(textLabel, {
				width:			friendsBackingBmp.width,
				fontSize:		17,
				color:			0xfceecf,
				borderColor:	0xbba275,
				textAlign:		"center",
				textLeading:	-6,
				multiline:		true,
				wrap:			true,
				shadowSize:		1.5
			});
			text.x = friendsBackingBmp.x;
			text.y = 24;
			
			var container:Sprite = new Sprite();
			addChild(container);
			container.addChild(text);
			container.filters = [new DropShadowFilter(3, 45, 0, 0.2, 5,5)];
		}
		
		w = this.width;
		h = this.height;
		
		addEventListener(MouseEvent.MOUSE_OVER, onOverEvent);
		addEventListener(MouseEvent.MOUSE_OUT, onOutEvent);
		addEventListener(MouseEvent.CLICK, onClick);
		
		mouseChildren = false;
		
		var that:FriendItem = this;
		tip = function():Object {
			if (type == 'manage') {
				return {
					title: Locale.__e('flash:1382952379779')
				};
			}
			
			/*return {
				title: 'Друг',
				text:	'Я заходил к нему: ' + TimeConverter.timeToStr(App.time - that.friend.visited) + '\n' + 'Энергия обновится: ' + TimeConverter.timeToStr(App.nextMidnight - App.time),
				timer:	true
			};*/
			
			return {
				title: that.friend != null ? Locale.__e('flash:1382952379780') : Locale.__e('flash:1382952379781')
			};
		}
	}
	
	private var loaded:Boolean = false;
	public function load():void {
		if (loaded) return;
		loaded = true;
		
		if(friend && friend["photo"] != undefined)
			new AvaLoad(friend.photo, onLoad);
	}
	
	private function onOverEvent(e:MouseEvent):void {
		for each(var item:FriendItem in friendsPanel.friendsItems) {
			item.friendsBackingBmp.filters = [];
		}
		
		var mtrx:ColorAdjust;
		mtrx = new ColorAdjust();
		mtrx.saturation(1);
		mtrx.brightness(0.1);
		friendsBackingBmp.filters = [mtrx.filter];
		if (avatar != null) avatar.filters = [mtrx.filter];
		
		friendsPanel.wishList.show(this);
	}
	
	private function onOutEvent(e:MouseEvent):void {
		for each(var item:FriendItem in friendsPanel.friendsItems) {
			item.friendsBackingBmp.filters = [];
			if(avatar != null) avatar.filters = [];
		}
		
		friendsPanel.wishList.hide();
	}
	
	private function onClick(e:MouseEvent):void {
		if (App.user.quests.tutorial && !Tutorial.tutorialBttn(this))
			return;
		
		if (!App.user.quests.data.hasOwnProperty(22) && uid) {
			new SimpleWindow( {
				title:		Locale.__e('flash:1426783114960'),
				text:		Locale.__e('flash:1426783136884')
			}).show();
			return;
		}
		
		friendsPanel.onVisitEvent(e);
		
		if (App.tutorial) {
			Tutorial.circleFocusOff(true);
			Tutorial.missHandlers.length = 0;
		}
	}
	
	private function onLoad(data:*):void {
		if(data is Bitmap){
			avatar.bitmapData = data.bitmapData;
			avatar.smoothing = true;
		}
		
		avatar.alpha = 0;
		TweenLite.to(avatar, 0.5, { alpha:1 } );
		
		/*var shape:Shape = new Shape();
		shape.graphics.beginFill(0x000000, 1);
		shape.graphics.drawRoundRect(0, 0, 50, 50,20, 20);
		shape.graphics.endFill();
		sprite.mask = shape;
		sprite.addChild(shape);*/
	}
	
	public function dispose():void {
		removeEventListener(MouseEvent.MOUSE_OVER, onOverEvent);
		removeEventListener(MouseEvent.MOUSE_OUT, onOutEvent);
		
		if (parent) parent.removeChild(this);
		
		if (__hasPointing) hidePointing();
	}
}

import ui.FriendsPanel;

internal class WishListPopUp extends Sprite
{
	private var showed:Boolean = false;
	private var items:Array = [];
	private var container:Sprite;
	private var overed:Boolean = false;
	private var overTimer:Timer = new Timer(250, 1);
	public var window:FriendsPanel;
	public var callback:Function;
	public var uid:String;

	public function WishListPopUp(window:FriendsPanel)
	{
		this.window = window;
		callback = function():void{
			//window.refreshContent();
			//window.onUpChange();
		}
		overTimer.addEventListener(TimerEvent.TIMER, dispose)
	}
	
	public function show(target:FriendItem):void
	{
		if (!target.uid)
			return;
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
		
		if (App.self.stage.displayState != StageDisplayState.NORMAL) {
			this.x = target.x + (target.width - this.width) / 2 + 64 - App.ui.bottomPanel.friendsPanel.start * 73.3;
		} else {
			if (App.isSocial('FB')) {
				this.x = target.x + (target.width - this.width) / 2 + 64 - App.ui.bottomPanel.friendsPanel.start * 72.7;
			} else {
				this.x = target.x + (target.width - this.width) / 2 + 64 - App.ui.bottomPanel.friendsPanel.start * 71.14;
			}
		}
		//this.x = target.x + (target.width - this.width)/2 + 4;
		this.y = target.y - 95 - this.height;
		
		showed = true;
		window.setChildIndex(this, window.numChildren-1);
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

import flash.display.BitmapData;
internal class WishListItem extends Sprite
{
	private var bitmap:Bitmap;
	private var bg:ImageButton;
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
			bg = new ImageButton(Window.texture('wishlistHasBttn'));
		}else
		{
			bg = new ImageButton(Window.textures.cursorsPanelItemBg);
		}
		
		bg.addEventListener(MouseEvent.CLICK, onClick);
		
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
		/*new GiftItemWindow( {
			sID:sID,
			fID:uid,
			callback:function():void {
				wList.callback();
			}
		}).show();*/
		
		// Если материал бесплатынй и если я не дарил этому другу, подаить
		// Иначе попробывать подарить со склада
		var info:Object = App.data.storage[sID];
		if (info.hasOwnProperty('free') && info.free == 1) {
			if (Gifts.takedFreeGift.indexOf(uid) == -1) {
				new GiftWindow( {
					uid:		uid,
					sID:		this.sID,
					iconMode:	GiftWindow.FREE_GIFTS,
					itemsMode:	GiftWindow.FRIENDS
				}).show();
			}else {
				var window:Window = new SimpleWindow( {
					title:		info.title,
					text:		Locale.__e('flash:1428067685417'),
					dialog:		true,
					confirm:	function():void {
						window.close();
						
						takeGift();
					}
				});
				window.show();
			}
		}else {
			if (info.mtype == 4) {
				new GiftWindow( {
					iconMode:GiftWindow.COLLECTIONS,
					itemsMode:GiftWindow.FRIENDS,
					sID:sID
				}).show();
			}else {
				takeGift();
			}
		}
		
		function takeGift():void {
			if (App.user.stock.count(sID) > 0) {
				new GiftWindow( {
					itemsMode:		GiftWindow.FRIENDS,
					iconMode:		GiftWindow.MATERIALS,
					sID:			sID,
					uid:			uid
				}).show();
			}else{
				new SimpleWindow( {
					title:		App.data.storage[sID].title,
					text:		Locale.__e('flash:1428055030855')
				}).show();
			}
		}
	}
	
	public function dispose():void
	{
		bg.removeEventListener(MouseEvent.CLICK, onClick);
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