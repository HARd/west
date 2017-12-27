package wins 
{
	import api.ExternalApi;
	import buttons.Button;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	/**
	 * ...
	 * @author 
	 */
	public class FriendsWindow extends Window
	{
		public var items:Array = [];
		public var inviteBttn:Button;
		
		public function FriendsWindow(settings:Object = null)
		{
			if (settings == null) {
				settings = new Object();
			}
			settings['popup'] = true;
			
			settings["width"] = 600;
			settings["height"] = 550;
			settings["title"] = Locale.__e("flash:1382952380120");
			settings["hasPaginator"] = true;
			settings["hasArrows"] = true;
			settings["itemsOnPage"] = 12;
			
			settings.content = [];
			settings.content = settings.content.concat(App.user.friends.keys);
			
			super(settings);
		}
		
		private function inviteEvent(e:MouseEvent):void {
			ExternalApi.apiInviteEvent();
		}
		
		override public function drawBody():void
		{
			paginator.itemsCount = settings.content.length;
			paginator.update();
			
			contentChange();
			
			inviteBttn = new Button( {
				caption:Locale.__e("flash:1382952379977"),
				width:160,
				height:30,
				fontSize:24
			});
			
			bodyContainer.addChild(inviteBttn);
			inviteBttn.x = (settings.width - inviteBttn.width) / 2;
			inviteBttn.y = 42;
			inviteBttn.addEventListener(MouseEvent.CLICK, inviteEvent);
		}
		
		override public function drawArrows():void {
			
			paginator.drawArrow(bodyContainer, Paginator.LEFT,  0, 0, { scaleX: -1, scaleY:1 } );
			paginator.drawArrow(bodyContainer, Paginator.RIGHT, 0, 0, { scaleX:1, scaleY:1 } );
			
			var y:Number = settings.height / 2 - paginator.arrowLeft.height;
			paginator.arrowLeft.x = 0;
			paginator.arrowLeft.y = y;
			
			paginator.arrowRight.x = settings.width - paginator.arrowLeft.width;
			paginator.arrowRight.y = y;
		}
		
		override public function contentChange():void {
			for each(var _item:* in items) {
				bodyContainer.removeChild(_item);
				_item.dispose();
			}
			items = [];
			var X:int = 84;
			var Xs:int = 84;
			var Ys:int = 90;
			
			var itemNum:int = 0;
			for (var i:int = paginator.startCount; i < paginator.finishCount; i++){
				
				var item:FriendItem = new FriendItem(this, settings.content[i]);
				
				bodyContainer.addChild(item);
				item.x = Xs;
				item.y = Ys;
								
				items.push(item);
				Xs += item.bg.width + 10;
				
				
				if (itemNum == 3 || itemNum == 7)
				{
					Xs = X;
					Ys += item.bg.height + 10;
				}
				itemNum++;
			}
			
			//sections[settings.section].page = paginator.page;
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
import wins.FriendsWindow;
import wins.Window;

internal class FriendItem extends Sprite
{
	private var window:FriendsWindow;
	public var bg:Bitmap;
	public var friend:Object;
	
	private var title:TextField;
	private var infoText:TextField;
	private var sprite:LayerX = new LayerX();
	private var avatar:Bitmap = new Bitmap();
	private var selectBttn:Button;
	public var _hire:uint = 0;
	public var hireTime:uint;
	
	public function FriendItem(window:FriendsWindow, data:Object)
	{
		this.friend = App.user.friends.data[data.uid];
		this.window = window;
		
		hireTime = App.data.options["BuildingHireTime"];
		
		bg = Window.backing(100, 100, 10, "bonusBacking");
		addChild(bg);
		addChild(sprite);
		sprite.addChild(avatar);
		
		title = Window.drawText(friend.first_name, App.self.userNameSettings( {
			fontSize:20,
			color:0x502f06,
			borderColor:0xf8f2e0
		}));
		
		addChild(title);
		title.x = (bg.width - title.textWidth) / 2;
		title.y = -5;
		
		//Load.loading(friend.photo, onLoad);
		new AvaLoad(friend.photo, onLoad);
		
		selectBttn = new Button({
			caption		:Locale.__e("flash:1382952379978"),
			fontSize	:18,
			width		:86,
			height		:26,
			onMouseDown	:onSelectClick
		});
		
		addChild(selectBttn);
		selectBttn.x = (bg.width - selectBttn.width) / 2;
		selectBttn.y = bg.height - selectBttn.height;
		
		var leftTime:int = (friend.hire + hireTime) - App.time;
		if (leftTime <= 0) {
			friend.hire = 0;
		}
		
		infoText = Window.drawText(TimeConverter.timeToStr(leftTime), {
			fontSize:20,
			color:0x898989,
			borderColor:0xf8f2e0
		});
		
		if (friend.hire == null || friend.hire == 0){
			hire = 0;
		}else{
			hire = friend.hire;
		}
		
		addChild(infoText);
		infoText.x = (bg.width - infoText.textWidth) / 2 - 3;
		infoText.y = bg.height - infoText.textHeight - 5;
		
		App.self.setOnTimer(onTimerEvent);
		
		sprite.tip = function():Object {
			return {
				title: (_hire==0)?Locale.__e("flash:1382952380120"):Locale.__e("flash:1382952380125")
			}
		}
	}
	
	private function onTimerEvent():void {
		var leftTime:int = (friend.hire + hireTime) - App.time;
		if (leftTime <= 0) {
			friend.hire = 0;
			hire = 0;
		}else {
			infoText.text = TimeConverter.timeToStr(leftTime);
		}
	}
	
	private function onSelectClick(e:MouseEvent):void
	{
		hire = App.time;
		friend.hire = App.time;
		window.settings.onSelectFriend(friend);
		window.settings.onClose = null;
		window.close();
	}
	
	public function set hire(value:uint):void
	{
		_hire = value;
		if (_hire != 0){
			selectBttn.visible = false;
			infoText.visible = true;
		}
		else
		{
			selectBttn.visible = true;
			infoText.visible = false;
		}
	}
	
	private function onLoad(data:*):void {
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
		App.self.setOffTimer(onTimerEvent);
		selectBttn.dispose();
	}
}