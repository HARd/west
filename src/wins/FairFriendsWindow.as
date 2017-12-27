package wins 
{
	import adobe.utils.CustomActions;
	import buttons.Button;
	import buttons.MoneyButton;
	import core.Load;
	import core.Numbers;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.text.TextField;
	
	public class FairFriendsWindow extends Window 
	{
		
		public var back:Bitmap;
		public var inviteBttn:Button;
		public var boostBttn:MoneyButton;
		public var textlabel:TextField;
		public var descLabel:TextField;
		public var viewTitleLabel:TextField;
		public var icon:Bitmap;
		
		private var container:Sprite;
		
		public function FairFriendsWindow(settings:Object=null) 
		{
			settings['background'] = settings['background'] || 'tradingPostBackingMain';
			settings.content = [];
			for (var s:* in settings.target.friends){
				settings.content.push(App.user.friends.data[s]);
			}
			super(settings);
			
		}
		
		override public function drawBody():void {
			
			exit.x += 4;
			exit.y -= 22;
			
			titleLabel.y -= 10;
			
			icon = new Bitmap();
			bodyContainer.addChild(icon);
			Load.loading(Config.getIcon(settings.target.type, settings.target.info.preview), onLoadIcon);
			
			drawMirrowObjs('storageWoodenDec', 2, settings.width, 20, false, false, false, 1, -1);
			drawMirrowObjs('storageWoodenDec', 2, settings.width, settings.height - 100, false, false, false, 1, 1);
			drawMirrowObjs('diamondsTop', settings.width / 2 - settings.titleWidth / 2 - 5, settings.width / 2 + settings.titleWidth / 2 + 5, -55, true, true);
			
			var separator:Bitmap = Window.backingShort(settings.width - 150, 'divider');
			separator.alpha = 0.6;
			separator.x = (settings.width - separator.width) / 2;
			separator.y = 30;
			bodyContainer.addChild(separator);
			
			var stripe:Bitmap = Window.backingShort(300, "yellowRibbon");
			stripe.x = (settings.width - stripe.width) / 2;
			stripe.y = separator.y + (separator.height - stripe.height) / 2;
			bodyContainer.addChild(stripe);
			
			viewTitleLabel = drawText(settings.target.info.form.req[settings.target.view].n, {
				autoSize:		'center',
				textAlign:		'center',
				color:			0xfffff6,
				borderColor:	0x864f30,
				fontSize:		24
			});
			viewTitleLabel.x = (settings.width - viewTitleLabel.width) / 2;
			viewTitleLabel.y = separator.y + (separator.height - viewTitleLabel.height) / 2 - 2;
			bodyContainer.addChild(viewTitleLabel);
			
			back = backing(settings.width - 100, 270, 50, 'storageBackingSmall');
			back.x = (settings.width - back.width) / 2;
			back.y = separator.y + separator.height + 26;
			bodyContainer.addChild(back);
			
			container = new Sprite();
			bodyContainer.addChild(container);
			
			descLabel = drawText(Locale.__e('flash:1417002969061'), {
				autoSize:		'center',
				textAlign:		'center',
				color:			0xf9ffff,
				borderColor:	0x6b3b13,
				fontSize:		26
			});
			descLabel.x = back.x + (back.width - descLabel.width) / 2;
			descLabel.y = back.y - descLabel.height / 2 + 4;
			bodyContainer.addChild(descLabel);
			
			inviteBttn = new Button( {
				width:		188,
				height:		42,
				caption:	Locale.__e('flash:1382952379977'),
				fontSize:	25
			});
			inviteBttn.x = (settings.width - inviteBttn.width) / 2;
			inviteBttn.y = back.y + back.height - 25;
			bodyContainer.addChild(inviteBttn);
			inviteBttn.addEventListener(MouseEvent.CLICK, onInvite);
			
			textlabel = drawText(Locale.__e('flash:1417002312603', [String(settings.target.kicks), String(settings.target.info.form.req[settings.target.view]['c'])]), {
				width:	280,
				textAlign:		'center',
				color:			0xf9ffff,
				borderColor:	0x6c3c0e,
				fontSize:		36
			});
			textlabel.y = back.y + back.height + 20;
			textlabel.filters = textlabel.filters.concat([new DropShadowFilter(3, 90, 0xb08759, 1, 0, 0)]);
			bodyContainer.addChild(textlabel);
			
			boostBttn = new MoneyButton( {
				width:		180,
				height:		44,
				fontSize:	25,
				countText:	settings.target.info.form.req[settings.target.view].s
			});
			boostBttn.y = textlabel.y;
			bodyContainer.addChild(boostBttn);
			textlabel.x = (settings.width - (textlabel.width + 10 + boostBttn.width)) / 2;
			boostBttn.x = textlabel.x + textlabel.width + 10;
			boostBttn.addEventListener(MouseEvent.CLICK, onBoost);
			
			paginator.itemsCount = settings.content.length;
			paginator.page = 0;
			paginator.onPageCount = 8;
			paginator.update();
			
			contentChange();
			
			upgradeBttn = new Button({
				caption		:Locale.__e('flash:1382952380146'),
				width		:190,
				height		:52,	
				fontSize	:26
			});
			bodyContainer.addChild(upgradeBttn);
			upgradeBttn.addEventListener(MouseEvent.CLICK, storageEvent);
			
			upgradeBttn.x = inviteBttn.x + (inviteBttn.width - upgradeBttn.width) / 2;
			upgradeBttn.y = inviteBttn.y + (inviteBttn.height - upgradeBttn.height) / 2;
			upgradeBttn.visible = false;
			
			
			refreshKicks();
		}
		public var upgradeBttn:Button;
		
		public function onLoadIcon(data:Bitmap):void {
			icon.bitmapData = data.bitmapData;
			icon.smoothing = true;
			icon.x = (settings.width - icon.width) / 2;
			icon.y = -icon.height / 2 + 10;
		}
		
		public function onBoost(e:MouseEvent):void 
		{
			settings.target.boostEvent(refreshKicks);
			boostBttn.visible = false;
		}
		
		public function onInvite(e:MouseEvent):void {
			//new AskWindow(AskWindow.MODE_NOTIFY, {
				//target:settings.target,
				//title:Locale.__e('flash:1382952380197'), 
				//friendException:settings.friendsData,
				//inviteTxt:Locale.__e("flash:1417020589452"),
				//desc:Locale.__e("flash:1417020589452")
			//} ).show();
			
			new AskWindow(AskWindow.MODE_INVITE, {
				target:settings.target,
				title:Locale.__e('flash:1382952380197'), 
				friendException:function(... args):void {
					trace(args);
				},
				inviteTxt:Locale.__e("flash:1395846352679"),
				desc:Locale.__e("flash:1417020589452"),
				noAllFriends:true
			} ).show();
		}
		
		public function storageEvent(e:MouseEvent):void {
			settings.target.storageEvent();
			close();
		}
		
		private function refreshKicks():void {
			var neededKicks:int = settings.target.info.form.req[settings.target.view]['c'];
			textlabel.text = Locale.__e('flash:1417002312603', [String(settings.target.kicks), String(neededKicks)]);
			
			if (neededKicks <= settings.target.kicks) {
				boostBttn.visible = false;
				upgradeBttn.visible = true;
				
				textlabel.x = (settings.width - textlabel.width) / 2;
			}
			else
			{
				boostBttn.visible = true;
				upgradeBttn.visible = false;
			}
		}		
		
		private const ITEMS_MARGIN:int = 10;
		private const ITEMS_WIDTH:int = 100;
		private const ITEMS_HEIGHT:int = 100;
		public var items:Array = [];
		override public function contentChange():void 
		{
			clear();
			
			for (var i:int = 0; i < 8; i++) {
				if (settings.content.length <= i + paginator.page * paginator.onPageCount) continue;
				
				var item:FriendItem = new FriendItem(this, settings.content[i]);
				item.x = back.x + 14 + (i % 4) * (ITEMS_WIDTH + ITEMS_MARGIN);
				item.y = back.y + 14 + Math.floor(i / 4) * (ITEMS_HEIGHT + ITEMS_MARGIN);
				container.addChild(item);
				items.push(item);
			}
		}
		public function clear():void {
			while (items.length > 0) {
				var item:FriendItem = items.shift();
				item.dispose();
				container.removeChild(item);
			}
		}
		
		override public function dispose():void {
			inviteBttn.dispose();
			boostBttn.dispose();
			
			super.dispose();
		}
		
	}

}


import buttons.Button;
import core.Log;
import core.AvaLoad;
import core.Load;
import core.Post;
import core.TimeConverter;
import core.WallPost;
import flash.display.Bitmap;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.text.TextField;
import units.Tree;
import wins.AskWindow;
import wins.Window;

internal class FriendItem extends Sprite
{
	private var window:*;
	public var bg:Bitmap;
	public var friend:Object;
	
	private var title:TextField;
	private var infoText:TextField;
	private var sprite:Sprite = new Sprite();
	private var avatar:Bitmap = new Bitmap();
	private var selectBttn:Button;
	private var data:Object;
	
	private var preloader:Preloader = new Preloader();
	
	private var callBack:Function;
	
	public function FriendItem(window:*, data:Object)
	{
		this.data = data;
		this.friend = App.user.friends.data[data.uid];
		
		this.window = window;
		this.callBack = callBack;
		
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
		/*
		var txtBttn:String;
		switch(mode) {
			case AskWindow.MODE_ASK:
				txtBttn = Locale.__e("flash:1382952379978");
			break;
			case AskWindow.MODE_INVITE:
				//txtBttn = Locale.__e("flash:1382952380197");
				txtBttn = Locale.__e("flash:1382952380230");
			break;
			case AskWindow.MODE_PUT_IN_ROOM:
				txtBttn = Locale.__e("flash:1393580021031");
			break;
			case AskWindow.MODE_INVITE_BEST_FRIEND:
				txtBttn = Locale.__e("flash:1382952380230");
			break;
			case AskWindow.MODE_NOTIFY_2:
			case AskWindow.MODE_NOTIFY:
				txtBttn = Locale.__e("flash:1382952380230");
			break;
		}
		
		selectBttn = new Button({
			caption		:txtBttn,
			fontSize	:20,
			width		:bg.width,
			height		:36,	
			onMouseDown	:onSelectClick
		});
		addChild(selectBttn);*/
		
		//selectBttn.x = (bg.width - selectBttn.width) / 2;
		//selectBttn.y = bg.height - 4;
		//
		//if(!window.blokedStatus)
			//selectBttn.state = Button.DISABLED;
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
		if (friend && friend.first_name != null) {
			App.self.setOffTimer(checkOnLoad);
			drawAvatar();
		}
	}
	
	public function set state(value:int):void {
		selectBttn.state = value;
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
		callBack = null;
		App.self.setOffTimer(checkOnLoad);
		selectBttn.dispose();
	}
}