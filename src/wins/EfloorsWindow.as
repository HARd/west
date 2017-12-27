package wins 
{
	import api.ExternalApi;
	import buttons.Button;
	import buttons.MoneyButton;
	import flash.display.Bitmap;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import ui.Hints;

	public class EfloorsWindow extends Window 
	{
		private var presentsText:TextField;
		private var	presentsCount:TextField;
		private var emptyText:TextField;
		private var separator:Bitmap;
		private var separator2:Bitmap;
		private var items:Array;
		private var inviteButton:Button;
		private var takeButton:Button;
		private var speedBttn:MoneyButton;
		
		public function EfloorsWindow(settings:Object=null) {
			if (settings == null) {
				settings = { };
			}
			
			settings['width'] 			= 590;
			settings['height']			= 525;
			settings['hasArrows']		= true;
			settings['hasPaginator']	= true;
			settings['hasButtons']		= false;
			settings['background'] 		= 'indianBacking';
			settings['title'] 			= settings.target.info.title;
			settings['content']			= [];
			
			for (var _uid:* in settings.target.guests) 
			{
				if (!App.user.friends.data.hasOwnProperty(_uid)) continue;
				settings['content'].push( { uid:_uid, time:settings.target.guests[_uid] } );
			}
				
			settings['itemsOnPage']		= 8;
			super(settings);
		}
		
		override public function drawBody():void {
			drawLines();
			drawTop();
			drawButton();
			if (settings.content.length > 0) {
				contentChange();
			}
			else {
				drawEmpty();
			}
		}
		
		private function buyKickEvent(e:MouseEvent):void {
			if (!App.user.stock.check(Stock.FANT, settings.target.info.skip))
				return;
			
			if (e.currentTarget.mode == Button.DISABLED) return;
			e.currentTarget.state = Button.DISABLED;
			
			settings.buyKicks({
				callback:onBuyKicks
			});
		}
		
		private function onBuyKicks():void {		
			Hints.minus(Stock.FANT, settings.target.info.skip, Window.localToGlobal(speedBttn), false, this);
			App.user.stock.take(Stock.FANT, settings.target.info.skip);
			
			presentsText.text = Locale.__e("flash:1447671450340") + ' ' + String(settings.target.kicks) + "/" +  String(settings.target.kicksLimit);
			speedBttn.visible = false;
			if (inviteButton) inviteButton.visible = false;
			drawButton();
		}
		
		override public function contentChange():void {
			if (settings.content.length == 0) {
				return;
			}
			if (emptyText != null) {
				bodyContainer.removeChild(emptyText);
				emptyText = null;
			}
			for each(var _item:* in items) {
				bodyContainer.removeChild(_item);
				_item.dispose();
			}
			items = [];
			
			var X:int = 86;
			var Xs:int = 86;
			var Ys:int = separator.y + 27;
			
			var itemNum:int = 0;
			for (var i:int = paginator.startCount; i < paginator.finishCount; i++){
				if (!settings.content[i]) continue;
				var item:FriendItem = new FriendItem(this, settings.content[i]);
				
				bodyContainer.addChild(item);
				item.x = Xs;
				item.y = Ys;
				
				items.push(item);
				Xs += item.bg.width + 14;
				
				if (itemNum == 3)
				{
					Xs = X;
					Ys += item.bg.height + 15;
				}
				
				itemNum++;
			}
			settings.page = paginator.page;
		}
		
		private function drawTop():void {
			var count1:int = settings.target.kicks;
			var count2:int = settings.target.kicksLimit;
			if (count1 > count2) count1 = count2;
			presentsText = Window.drawText(Locale.__e("flash:1447671450340")+' '+ count1.toString() + "/" + count2.toString(), {
				fontSize:30,
				color:0xffda6f,
				borderSize: 4,	
				borderColor:0x6b3922,
				multiline:false
			});
			presentsText.width = presentsText.textWidth + 30;
			presentsText.x = (settings.width - presentsText.width) / 2;;
			presentsText.y = 35;
			bodyContainer.addChild(presentsText);
			
			
			var middleText:TextField = Window.drawText(Locale.__e('flash:1447671480017'), {
				fontSize:28,
				borderSize: 4,	
				borderColor:0x6b3922,
				multiline:false	
			});
			
			middleText.width = middleText.textWidth + 6;
			middleText.x = (settings.width - middleText.width) / 2;;
			middleText.y = 87;
			bodyContainer.addChild(middleText);
		}
		
		private function drawLines():void {
			separator = Window.backingShort(460, 'dividerLine', false);
			separator.x = (settings.width - separator.width) / 2;
			separator.y = 110;
			separator.alpha = 0.5;
			bodyContainer.addChild(separator);
			
			separator2 = Window.backingShort(460, 'dividerLine', false);
			separator2.scaleY = -1;
			separator2.x = (settings.width - separator2.width) / 2;
			separator2.y = 380;
			separator2.alpha = 0.5;
			bodyContainer.addChild(separator2);
		}
		
		private function drawButton():void {
			var skipPrice:int = settings.target.info.skip;
			speedBttn = new MoneyButton({
				caption		:Locale.__e('flash:1382952380021'),
				width		:190,
				height		:50,	
				fontSize	:26,
				countText	:skipPrice,
				iconScale	:0.6,
				
				bgColor:[0xa8f749, 0x74bc17],
				borderColor:[0x5b7385, 0x5b7385],
				bevelColor:[0xcefc97, 0x5f9c11],
				fontColor:0xffffff,			
				fontBorderColor:0x4d7d0e,
				
				fontCountColor:0xc7f78e,
				fontCountBorder:0x40680b		
			});
			speedBttn.x = 90;
			speedBttn.y = separator2.y + 5;
			bodyContainer.addChild(speedBttn);
			
			speedBttn.addEventListener(MouseEvent.CLICK, buyKickEvent);
			
			if (settings.target.kicks < settings.target.kicksLimit) {
				inviteButton = new Button( {
					width:190,
					height:50,
					fontSize:28,
					caption:Locale.__e("flash:1382952380197")
				});
				inviteButton.x = speedBttn.x + speedBttn.width + 20;
				inviteButton.y = separator2.y + 5;
				bodyContainer.addChild(inviteButton);
				
				inviteButton.addEventListener(MouseEvent.CLICK, onNotify);
			} else {
				takeButton = new Button( {
					width:190,
					height:50,
					fontSize:28,
					caption:Locale.__e("flash:1393579618588")
				});
				takeButton.x = (settings.width - takeButton.width) / 2;
				takeButton.y = separator2.y + 5;
				bodyContainer.addChild(takeButton);
				
				takeButton.addEventListener(MouseEvent.CLICK, onTake);
				
				if (speedBttn) speedBttn.visible = false;
			}
		}
		
		private function onNotify(e:MouseEvent):void {
			switch(App.self.flashVars.social) {
				case 'VK':
				case 'DM':
				case 'FS':
					new AskWindow(AskWindow.MODE_INVITE_INGAME, {
						target:settings.target,
						title:Locale.__e('flash:1382952380197'), 
						friendException:settings.friendsData, 
						inviteTxt:Locale.__e("flash:1395846352679"),
						desc:Locale.__e('storage:376:text4')
					},
					function(uid:*):void {
						ExternalApi.notifyFriend( {
							uid:	String(uid),
							text:	Locale.__e('flash:1382952379703'),
							type:	'gift'
						})
					}).show();
					break;
				default:
					ExternalApi.apiInviteEvent();
			}
		}
		
		private function onTake(e:MouseEvent):void {
			if (e.currentTarget.mode == Button.DISABLED) return;
			e.currentTarget.state = Button.DISABLED;
			
			settings.storageEvent(0, onStorageEventComplete);
			//settings.upgradeEvent({});
		}
		
		public function onStorageEventComplete(sID:uint, price:uint, bonus:Object = null):void {
			if (bonus) {
				Treasures.bonus(bonus, new Point(settings.target.x, settings.target.y));
			}
			if (price == 0 ) {
				close();
				return;
			}
			var X:Number = App.self.mouseX - takeButton.mouseX + takeButton.width / 2;
			var Y:Number = App.self.mouseY - takeButton.mouseY;
			Hints.minus(sID, price, new Point(X, Y), false, App.self.tipsContainer);
			close();
		}
		
		private function drawEmpty():void {
			paginator.itemsCount = settings.content.length;
			paginator.update();
				
			emptyText = Window.drawText(Locale.__e('flash:1447671501723'), {
				color:0x532e02,
				border:true,
				fontSize:28,
				multiline:true,
				borderColor:0xfce8cd,
				borderSize: 1,	
				textAlign:"center"
			});
			emptyText.width = settings.width - 200;
			emptyText.height = 100;
			emptyText.wordWrap = true;
			emptyText.x = (settings.width - emptyText.width) / 2;
			emptyText.y = separator.y + (separator2.y - separator.y - emptyText.height) / 2;
			bodyContainer.addChild(emptyText);
		}
		
		override public function dispose():void {
			if (inviteButton) inviteButton.removeEventListener(MouseEvent.CLICK, onNotify);
			if (takeButton) takeButton.removeEventListener(MouseEvent.CLICK, onTake);
			if (speedBttn) speedBttn.removeEventListener(MouseEvent.CLICK, buyKickEvent);
			super.dispose();
		}
	}
}

import core.AvaLoad;
import flash.display.Bitmap;
import flash.display.Shape;
import flash.display.Sprite;
import flash.text.TextField;
import wins.EfloorsWindow;
import wins.Window;

internal class FriendItem extends Sprite
{
	private var window:EfloorsWindow;
	public var bg:Bitmap;
	public var friend:Object;
	
	private var title:TextField;
	private var infoText:TextField;
	private var sprite:Sprite = new Sprite();
	private var avatar:Bitmap = new Bitmap();
	private var data:Object;
	private var preloader:Preloader = new Preloader();
	
	public function FriendItem(window:EfloorsWindow, data:Object)
	{
		this.data = data;
		this.friend = App.user.friends.data[data.uid];
		
		this.window = window;
		
		bg = new Bitmap(Window.texture('friendSlot'));
		addChild(bg);
		addChild(sprite);
		sprite.addChild(avatar);
		
		addChild(preloader);
		preloader.x = (bg.width)/ 2;
		preloader.y = (bg.height) / 2;
		
		if (friend.first_name != null || friend.aka != null) {
			drawAvatar();
		}else {
			App.self.setOnTimer(checkOnLoad);
		}
	}
	
	private function drawAvatar():void 
	{
		var first_Name:String = '';
		if (friend.first_name && friend.first_name.length > 0)
			first_Name = friend.first_name;
		else if (friend.aka && friend.aka.length > 0) {
			first_Name = friend.aka;
		}
		
		if (first_Name.indexOf(' ') > 0) first_Name = first_Name.substring(0, first_Name.indexOf(' '));
		title = Window.drawText(first_Name.substr(0,15), App.self.userNameSettings({
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
	
	public function dispose():void{
		App.self.setOffTimer(checkOnLoad);
	}
}