package wins 
{
	import api.ExternalApi;
	import buttons.Button;
	import buttons.ImagesButton;
	import core.Post;
	import core.WallPost;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import wins.elements.SearchFriendsPanel;
	import core.Log;
	/**
	 * ...
	 * @author ...
	 */
	public class InviteLostFriendsWindow extends Window
	{
		public var sendBttn:Button;
		
		public var friends:Array = [];
		public var receivers:Array = [];
		
		public var items:Array = [];
		
		private var container:Sprite = new Sprite();
		
		public var tickBttn:ImagesButton;
		private var tickText:TextField;
		
		public var seachPanel:SearchFriendsPanel;
		
		public var isAllChecked:Boolean = true;
		
		
		public function InviteLostFriendsWindow(settings:Object) 
		{
			
			if(settings.desc)
				settings["title"]			= settings.desc;
			else 
				settings["title"]			= Locale.__e("flash:1406630729567");
			
			settings["width"]			= 616;
			settings["height"] 			= 460;
			settings["hasButtons"] 	= false;
			settings["fontSize"] 	= 34;
			
			settings["popup"] 	= true;
			
			settings["fontColor"] 	= 0xfffde7;
			settings["fontBorderColor"] 	= 0x5a2a79;
			settings["fontBorderGlow"] 	= 0;
			settings["fontBorderSize"] 	= 1;
			
			settings['itemsOnPage'] = 10;
			
			settings["textLeading"] 	= -6;
			
			settings["forcedClosing"] = true;
			
			settings['itemsMode'] = GiftWindow.ALLFRIENDS;
			
			settings['background']      = 'storageBackingMain';
			
			super(settings);
			
			
		}
		
		private function initContent():void
		{
			for (var fid:* in App.network.otherFriends) 
			{
				var friend:Object = {
					uid:		App.network.otherFriends[fid]
				}
				
				friends.push(friend);
			}
			
			paginator.itemsCount = friends.length;
			paginator.update();
			
			checkAll();
			
			checkBttnBox();
		}
		
		override public function drawArrows():void {
				
			super.drawArrows();
		
			paginator.arrowLeft.y -= 20;
			paginator.arrowRight.y -= 20;
		}
		
		override public function contentChange():void 
		{
			for (var m:int = 0; m < items.length; m++)
			{
				items[m].dispose();
				items[m].parent.removeChild(items[m]);
				items[m] = null;
			}
			
			var itemNum:int = 0;
			items = [];
			
			var Xs:int = 0;
			var Ys:int = 0;
			var X:int = 0;
						
			for (var i:int = paginator.startCount; i < paginator.finishCount; i++)
			{
				var item:*;
				
				item = new FriendItem(friends[i], this);
				
				container.addChild(item);
					
				item.x = X;
				item.y = Ys;
				items.push(item);
				
				X += item.bg.width + 6;
				if (itemNum == 4)
				{
					X = Xs;
					Ys += item.bg.height + 36;
				}
				
				itemNum++;
			}
			
			if (items.length == 0)
				sendBttn.state = Button.DISABLED;
			else 
				sendBttn.state = Button.NORMAL;
		}
		
		private function refreshContent(newFriends:Array):void 
		{
			friends = [];
			
			tickBttn.iconBmp.visible = true;
			
			var _L:int = newFriends.length;
			
			for (var i:int = 0; i < _L; i++)
			{
				if (newFriends[i].uid && newFriends[i].uid != "1")
				{
					friends.push(newFriends[i]);
				}
			}
			
			paginator.itemsCount = friends.length;
			paginator.update();
			
			checkAll();
			
			checkBttnBox();
		}
		
		override public function drawBody():void
		{
			exit.y -= 44;
			
			this.y += 90;
			fader.y -= 90;
			
			var bg:Bitmap = Window.backing(530, 300, 30, 'storageBackingSmall');
			bodyContainer.addChild(bg);
			bg.x = (settings.width - bg.width) / 2;
			bg.y = settings.height - bg.height - 90;
			
			var icon:Bitmap = new Bitmap(Window.textures.inviteFuryBack);
			layer.addChild(icon);
			icon.x = (settings.width - icon.width) / 2;
			icon.y = -270;
			
			var stripe:Bitmap = Window.backingShort(settings.width + 160, 'questRibbon');
			bodyContainer.addChild(stripe);
			stripe.x = (settings.width - stripe.width) / 2;
			stripe.y = -56;
			
			bodyContainer.addChild(container);
			container.x = bg.x + 19;
			container.y = bg.y + 18;
			
			seachPanel = new SearchFriendsPanel({
				win:this,
				callback:refreshContent
			});
			
			bodyContainer.addChild(seachPanel);
			seachPanel.x = 90;
			seachPanel.y = 26;
			
			drawBttn();
			
			initContent();
		}
		
		private function drawBttn():void 
		{
			sendBttn = new Button({
				caption:Locale.__e("flash:1382952380197"),
				width:190,					
				height:52,	
				fontSize:30
			});
			
			bodyContainer.addChild(sendBttn);
			sendBttn.x = (settings.width - sendBttn.width) / 2;
			sendBttn.y = settings.height - sendBttn.height - 26;
			
			if (settings.tutorial) {
				sendBttn.startGlowing();
				sendBttn.showPointing('top', 0, 0, sendBttn);
			}
			
			sendBttn.addEventListener(MouseEvent.CLICK, onSend);
			
			var bgtick:Bitmap = new Bitmap(Window.textures.roundCheck);
			tickBttn = new ImagesButton(bgtick.bitmapData, Window.textures.checkmarkSlim, { ix:5, iy: -14 }, 0.7 );
			bodyContainer.addChild(tickBttn);
			tickBttn.x = 380;
			tickBttn.y = 35;
			
			tickBttn.visible = false;
			tickBttn.onMouseDown = onSelectBttnClick;
			
			
			tickText = Window.drawText(Locale.__e("flash:1406627330998"), {
				color:0x6f340a,
				borderColor:0xede4cf,
				textAlign:"left",
				autoSize:"left",
				fontSize:25
				}
			);
			
			tickText.width = tickText.textWidth + 10;
			tickText.x = tickBttn.x + tickBttn.width + 4;
			tickText.y = tickBttn.y + 3;
			bodyContainer.addChild(tickText);
			tickText.visible = false;
		}
		
		private function onSend(e:MouseEvent):void 
		{
			Post.send({
				'ctr':'notify',
				'act':'notify',
				'uID':App.user.id,
				'name':'invite',
				'friends':JSON.stringify(receivers)
			}, function(error:*, data:*, params:*):void {
				if (error)
				{
					Errors.show(error, data);
					return;
				}
			});
			
			close();
			
			//for (var i:int = 0; i < receivers.length; i++) 
			//{
				//WallPost.makePost(WallPost.FRIEND, { uid:receivers[i] } );
				//ExternalApi.notifyFriend({uid:receivers[i], text:Locale.__e('привет'), callback:Post.statisticPost(Post.STATISTIC_INVITE)});
			//}
		}
		
		private function onSelectBttnClick(e:MouseEvent = null):void
		{
			if (isAllChecked)
				unCheckAll();
			else
				checkAll();
		}
		
		private function checkBttnBox():void
		{
			if (friends.length > 0) {
				tickBttn.visible = true;
				tickText.visible = true;
			}else {
				tickBttn.visible = false;
				tickText.visible = false;
			}
		}
		
		private function checkAll():void
		{
			isAllChecked = true;
			for (var i:int = 0; i < friends.length; i++) 
			{
				var uid:String = friends[i].uid;
				var index:int = receivers.indexOf(uid);
				if (index == -1){
					receivers.push(uid);
				}
			}
			tickBttn.iconBmp.visible = true;
			sendBttn.state = Button.NORMAL;
			
			contentChange();
		}
		
		private function unCheckAll():void
		{
			isAllChecked = false;
			receivers = [];
			
			tickBttn.iconBmp.visible = false;
			sendBttn.state = Button.DISABLED;
			
			contentChange();
		}
	}
}

import buttons.Button;
import buttons.ImagesButton;
import core.AvaLoad;
import flash.display.Bitmap;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.text.TextField;
import ui.UserInterface;
import wins.InviteLostFriendsWindow;
import wins.Window;

internal class FriendItem extends Sprite
{
	private var window:InviteLostFriendsWindow;
	public var bg:Bitmap;
	public var friend:Object;
	public var uid:String;
	
	private var title:TextField;
	private var sprite:Sprite = new Sprite();
	private var avatar:Bitmap;
	
	private var preloader:Preloader
	public var tickBttn:ImagesButton;
	
	public function FriendItem(data:Object, window:InviteLostFriendsWindow)
	{
		this.window = window;
		this.uid = data.uid;
		
		//friend = App.user.friends.data[uid];
		friend = data;//App.user.friends.data[uid];
		
		draw();
		
		var bgtick:Bitmap = new Bitmap(Window.textures.roundCheck);
		tickBttn = new ImagesButton(bgtick.bitmapData, Window.textures.checkmarkSlim, { ix:5, iy: -14 }, 0.7 );
		addChild(tickBttn);
		tickBttn.x = (width - tickBttn.width) / 2 + 3;
		tickBttn.y = height - tickBttn.height / 2 + 6;
		
		tickBttn.iconBmp.visible = false;
		if (window.receivers.indexOf(uid) != -1) {
			tickBttn.iconBmp.visible = true;
		}
		tickBttn.onMouseDown = onSelectBttnClick;
		
		addPreloader();
		
		new AvaLoad(friend.photo, onLoad);
	}
	
	private function draw():void
	{
		bg = new Bitmap(Window.textures.persIcon);
		
		addChild(bg);
		addChild(sprite);
		
		var shape:Shape = new Shape();
		shape.graphics.beginFill(0x000000, 1);
		shape.graphics.drawRoundRect(15, 15, 70, 70, 15, 15);
		shape.graphics.endFill();
		sprite.mask = shape;
		sprite.addChild(shape);
		shape.x -= 3;
		
		title = Window.drawText(friend.first_name, App.self.userNameSettings({
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
		
		//if (window.settings.itemsMode != GiftWindow.ALLFRIENDS) {
			//sprite.addEventListener(MouseEvent.MOUSE_OVER, onOver);
			//sprite.addEventListener(MouseEvent.MOUSE_OUT, onOut);
		//}
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
		preloader.x = preloader.width / 2 - 10;
		preloader.y = preloader.height / 2;
	}
	
	
	private function onSelectBttnClick(e:MouseEvent):void
	{
		if (e.currentTarget.mode == Button.DISABLED) return;
		var index:int = window.receivers.indexOf(uid);
		if (index == -1){
			//if (window.icon.iconMode != GiftWindow.FREE_GIFTS && (App.user.stock.count(window.icon.ID) <= window.receivers.length)) {
				//Hints.text(Locale.__e('flash:1382952380143'), Hints.TEXT_RED,  Window.localToGlobal(tickBttn), false, App.self.windowContainer);
				//return;
			//}
			//if (window.receivers.length >= 25) {
				//Hints.text(Locale.__e('flash:1382952380144'), Hints.TEXT_RED,  Window.localToGlobal(tickBttn), false, App.self.windowContainer);
				//return;
			//}
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
		
		//window.icon.countText.text = String(window.receivers.length);
		//window.icon.stockCountText.text = String(App.user.stock.count(window.icon.ID) - window.receivers.length);
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
		
		//for test 
		var txt:TextField = Window.drawText(friend['aka'], {
				fontSize:22,
				color:0xffffff,
				borderColor:0x000000,
				multiline:true,
				textAlign:"center",
				autoSize:"center"
		});
		txt.y = 20;
		sprite.addChild(txt);
		
	}
	
	//private function onOver(e:MouseEvent):void
	//{
		//window.wishList.show(this);
	//}
	//
	//private function onOut(e:MouseEvent):void
	//{
		//window.wishList.hide();
	//}
	
	public function dispose():void
	{
		//if (window.settings.itemsMode != GiftWindow.ALLFRIENDS) {
			//sprite.removeEventListener(MouseEvent.MOUSE_OVER, onOver);
			//sprite.removeEventListener(MouseEvent.MOUSE_OUT, onOut);
		//}
	}
}