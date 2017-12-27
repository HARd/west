package wins 
{
	import api.ExternalApi;
	import buttons.Button;
	import com.flashdynamix.motion.extras.BitmapTiler;
	import core.WallPost;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import ui.UserInterface;
	import wins.elements.SearchFriendsPanel;
	/**
	 * ...
	 * @author ...
	 */
	public class InstanceInfoWindow extends Window
	{
		public var items:Array = [];
		//private var seachPanel:SearchFriendsPanel;
		public var blokedStatus:Boolean = true;
		
		public var inviteBttn:Button;
		public var askBttn:Button;
		
		public function InstanceInfoWindow(settings:Object = null) 
		{
			if (settings == null) {
				settings = new Object();
			}
			settings['popup'] = true;
			settings["width"] = 526;
			settings["height"] = 572;
			settings["title"] = settings.title || Locale.__e("flash:1393580724851");
			settings["hasPaginator"] = true;
			settings["hasArrows"] = true;
			settings["itemsOnPage"] = 8;
			
			settings['background'] = "storageBackingMain";
			
			App.user.friends.keys
			settings.content = [];
			for(var item:* in App.user.friends.keys){
				for(var item2:* in settings.friends){
					if(App.user.friends.keys[item].uid == settings.friends[item2])settings.content.push(App.user.friends.keys[item]);
				}
			}
			
			super(settings);
		}
		
		private var bgBig:Bitmap;
		override public function drawBody():void
		{
			bgBig = Window.backing(460, 295, 20, "storageBackingSmall2");
			bgBig.x = (settings.width - bgBig.width) / 2;
			bgBig.y = settings.height - bgBig.height - 80;
			//bgBig.alpha = 0.7;
			bodyContainer.addChild(bgBig);
			
			setPaginatorCount();
			paginator.update();
			paginator.y += 53;
			
			if (settings.content.length > 0){
				contentChange();
			}else{
				var inviteText:TextField = drawText(Locale.__e('flash:1382952379976'),{
					fontSize:26,
					textAlign:"center",
					color:0xffffff,
					borderColor:0x794a1f,
					textLeading: 8,
					multiline:true
				});
				
				bodyContainer.addChild(inviteText);
				inviteText.wordWrap = true;
				inviteText.width = settings.width - 140;
				inviteText.height = inviteText.textHeight + 10;
				inviteText.x = (settings.width - inviteText.width) / 2;
				inviteText.y = bgBig.y + 48;
				paginator.visible = false;
				
				askBttn = new Button( {
					caption:Locale.__e("flash:1382952380230"),
					width:140,
					height:48,
					fontSize:26,
					hasDotes:false
				});
				
				bodyContainer.addChild(askBttn);
				askBttn.x = bgBig.x + (bgBig.width - askBttn.width) / 2;
				askBttn.y = inviteText.y + inviteText.textHeight + 20;
				askBttn.addEventListener(MouseEvent.CLICK, askEvent);
			}
			
			/////
			var cont:Sprite = new Sprite();
			
			var backing:Sprite = new Sprite();
			backing.graphics.beginFill(0xbba881, 1); //Last arg is the alpha
			backing.graphics.drawRoundRect(0, 0, 206, 70, 25, 25)
			backing.graphics.endFill();
			cont.addChild(backing);
			
			var descFriendBonus:TextField = Window.drawText(Locale.__e("flash:1395850471258"), {
				fontSize:24,
				color:0xffffff,
				autoSize:"left",
				borderColor:0x773c18,
				multiline:true
			});
			cont.addChild(descFriendBonus);
			descFriendBonus.x = (backing.width - descFriendBonus.textWidth) / 2;
			descFriendBonus.y = -descFriendBonus.textHeight/2 - 4;
			
			
			var iconsCont:Sprite = new Sprite();
			
			var iconChance:Bitmap = new Bitmap(UserInterface.textures.clever);
			//var iconTime:Bitmap = new Bitmap(Window.textures.timerYellow);
			
			var chanceTxt:TextField = Window.drawText(String(settings.target.getNumFriends()), {
				fontSize:34,
				color:0xffffff,
				autoSize:"left",
				borderColor:0x773c18,
				multiline:true
			});
			
			//var timeTxt:TextField = Window.drawText(String(settings.target.getNumFriends()), {
				//fontSize:34,
				//color:0xffffff,
				//autoSize:"left",
				//borderColor:0x773c18,
				//multiline:true
			//});
			
			chanceTxt.x = iconChance.width + 3;
			chanceTxt.y = 3;
			
			//iconTime.x = chanceTxt.x + chanceTxt.textWidth + 30;
			
			//timeTxt.x = iconTime.x + iconTime.width + 3;
			//timeTxt.y = 3;
			
			iconsCont.addChild(iconChance);
			//iconsCont.addChild(iconTime);
			iconsCont.addChild(chanceTxt);
			//iconsCont.addChild(timeTxt);
			
			cont.addChild(iconsCont);
			iconsCont.x = (backing.width - iconsCont.width) / 2;
			iconsCont.y = (backing.height - iconsCont.height) / 2 + 4;
			
			bodyContainer.addChild(cont);
			cont.x = 54;
			cont.y = 76;
			
			inviteBttn = new Button( {
				caption:Locale.__e("flash:1382952379977"),
				width:180,
				height:52,
				fontSize:26,
				hasDotes:false
			});
			
			bodyContainer.addChild(inviteBttn);
			inviteBttn.x = cont.x + cont.width + 30;
			inviteBttn.y = cont.y + (backing.height - inviteBttn.height) / 2;
			inviteBttn.addEventListener(MouseEvent.CLICK, inviteEvent);
			
			drawDesc();
			
			//seachPanel = new SearchFriendsPanel( {
				//win:this,
				//callback:refreshContent
			//});
			
			//bodyContainer.addChild(seachPanel);
			//seachPanel.x = 62;
			//seachPanel.y = 26;
			
			
			ExternalApi.onCloseApiWindow = function():void {
				blokedStatus = true;
				blokItems(blokedStatus);
			}
			
			drawMirrowObjs('diamondsTop', settings.width / 2 - settings.titleWidth / 2 - 5, settings.width / 2 + settings.titleWidth / 2 + 5, -45, true, true);
			drawMirrowObjs('diamonds',25, settings.width - 25, settings.height - 125);
		}
		
		private function askEvent(e:MouseEvent):void 
		{
			close();
			new AskWindow(AskWindow.MODE_INVITE, {
				title:Locale.__e('flash:1382952380197'), 
				friendException:settings.target.settings.friendsData, 
				inviteTxt:Locale.__e("flash:1395846352679"),
				desc:Locale.__e("flash:1395846372271")
			} ).show();
		}
		
		private function drawDesc():void 
		{
			var descFriends:TextField = Window.drawText(Locale.__e("flash:1395846372271"), {
				fontSize:23,
				color:0xffffff,
				autoSize:"center",
				textAlign:"center",
				borderColor:0x773c18,
				multiline:true
			});
			descFriends.wordWrap = true;
			descFriends.width = settings.width - 110;
			bodyContainer.addChild(descFriends);
			descFriends.x = (settings.width - descFriends.width) / 2;
			descFriends.y = 4;
		}
		
		/*private function refreshContent(friends:Array = null):void
		{
			if (friends.length == App.user.friends.keys.length) friends = null;
			if (friends == null)
			{
				settings.content = [];
				settings.content = settings.friends;// .concat(App.user.friends.keys);
				
				var L:uint = settings.content.length;
				for (var i:int = 0; i < L; i++)
				{
					settings.content[i]['order'] = int(Math.random() * L);
				}
				//settings.content.sortOn('order');
			}
			else
			{
				settings.content = [];
				settings.content = settings.friends;
				//settings.content.sortOn('level');
			}
			
			setPaginatorCount();
			paginator.update();
			contentChange();
		}*/
		
		private function setPaginatorCount():void
		{
			/*if (mode == MODE_PUT_IN_ROOM) {
				for (var fr:* in App.user.friends.data) {
					if (App.user.friends.data[fr].settle && App.user.friends.data[fr].settle == 1) {
						for (var i:int = 0; i < settings.content.length; i++ ) {
							if (settings.content[i].uid == fr) {
								settings.content.splice(i, 1);
							}
						}
						continue;
					}
				}
			}*/
			paginator.itemsCount = settings.content.length;
		}
		
		override public function drawArrows():void {
			
			paginator.drawArrow(bodyContainer, Paginator.LEFT,  0, 0, { scaleX: -1, scaleY:1 } );
			paginator.drawArrow(bodyContainer, Paginator.RIGHT, 0, 0, { scaleX:1, scaleY:1 } );
			
			var y:Number = settings.height/2 - paginator.arrowLeft.height
			paginator.arrowLeft.x = -20;
			paginator.arrowLeft.y = y;
			
			paginator.arrowRight.x = settings.width - paginator.arrowLeft.width + 20;
			paginator.arrowRight.y = y;
		}
		
		override public function contentChange():void {
			for each(var _item:* in items) {
				bodyContainer.removeChild(_item);
				_item.dispose();
			}
			items = [];
			
			var X:int = 56;
			var Xs:int = 56;
			var Ys:int = bgBig.y + 20;
			
			var itemNum:int = 0;
			for (var i:int = paginator.startCount; i < paginator.finishCount; i++){
				
				var item:FriendItem = new FriendItem(this, settings.content[i]);
				
				bodyContainer.addChild(item);
				item.x = Xs;
				item.y = Ys;
								
				items.push(item);
				Xs += item.bg.width + 14;
				
				
				if (itemNum == 3 || itemNum == 7)
				{
					Xs = X;
					Ys += item.bg.height + 20;
				}
				itemNum++;
			}
			settings.page = paginator.page;
		}
		
		public override function close(e:MouseEvent=null):void 
		{
			if (settings.onClose != null && settings.onClose is Function)
			{
				settings.onClose();
			}
			
			super.close();
		}
		
		public function blokItems(value:Boolean):void
		{
			var item:*;
			if (value)	for each(item in items) item.state = Window.ENABLED;
			else 		for each(item in items) item.state = Window.DISABLED;
		}
		
		private function inviteEvent(e:MouseEvent):void {
			if (inviteBttn.mode == Button.DISABLED) return;
			
			inviteBttn.state = Button.DISABLED;
			//ExternalApi.apiInviteEvent();
			//if(settings.instance)
			//		WallPost.makePost(WallPost.INSTANCE_INVATE_ALL, {sid:settings.instance.sid}); 
		}
		
		override public function dispose():void {
			ExternalApi.onCloseApiWindow = null
			for each(var item:* in items) {
				item.dispose();
			}
			
			if (inviteBttn) {
				inviteBttn.removeEventListener(MouseEvent.CLICK, inviteEvent);
				inviteBttn.dispose();
				inviteBttn = null;
			}
			if (askBttn) {
				askBttn.removeEventListener(MouseEvent.CLICK, askEvent);
				askBttn.dispose();
				askBttn = null;
			}
			
			
			super.dispose();
		}
	}
}

import buttons.Button;
import core.AvaLoad;
import core.Load;
import core.TimeConverter;
import flash.display.Bitmap;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.text.TextField;
import ui.UserInterface;
import wins.InstanceInfoWindow;
import wins.Window;

internal class FriendItem extends Sprite
{
	private var window:InstanceInfoWindow;
	public var bg:Bitmap;
	public var friend:Object;
	
	private var title:TextField;
	private var infoText:TextField;
	private var sprite:Sprite = new Sprite();
	private var avatar:Bitmap = new Bitmap();
	private var data:Object;
	
	private var preloader:Preloader = new Preloader();
	
	
	public function FriendItem(window:InstanceInfoWindow, data:Object)
	{
		this.data = data;
		this.friend = App.user.friends.data[data.uid];
		this.window = window;
		
		//bg = new Bitmap(UserInterface.textures.friendsBacking);
		bg = new Bitmap(Window.textures.persIcon);
		addChild(bg);
		addChild(sprite);
		sprite.addChild(avatar);
		
		addChild(preloader);
		preloader.x = (bg.width)/ 2;
		preloader.y = (bg.height) / 2;
		
		if (friend.first_name != null) {
			drawAvatar();
		}else {
			App.self.setOnTimer(checkOnLoad);
		}
		
	}
	
	private function drawAvatar():void 
	{
		title = Window.drawText(friend.first_name.substr(0,15), App.self.userNameSettings({
			fontSize:20,
			color:0x502f06,
			borderColor:0xf8f2e0,
			textAlign:'center'
		}));
		
		addChild(title);
		title.width = bg.width + 10;
		title.x = (bg.width - title.width) / 2;
		title.y = -5;
		
		new AvaLoad(friend.photo, onLoad);
	}
	
	private function checkOnLoad():void {
		if (friend.first_name != null) {
			App.self.setOffTimer(checkOnLoad);
			drawAvatar();
		}
	}
	
	private function onLoad(data:*):void {
		removeChild(preloader);
		
		avatar.bitmapData = data.bitmapData;
		avatar.smoothing = true;
		
		var shape:Shape = new Shape();
		shape.graphics.beginFill(0x000000, 1);
		shape.graphics.drawRoundRect(0, 0, 50, 50, 12, 12);
		shape.graphics.endFill();
		sprite.mask = shape;
		sprite.addChild(shape);
		
		var scale:Number = 1.5;
		
		sprite.width *= scale;
		sprite.height *= scale;
		
		sprite.x = (bg.width - sprite.width) / 2;
		sprite.y = (bg.height - sprite.height) / 2;
	}
	
	public function dispose():void
	{
		App.self.setOffTimer(checkOnLoad);
	}
}