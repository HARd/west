package wins 
{
	import adobe.utils.CustomActions;
	import api.ExternalApi;
	import buttons.Button;
	import buttons.MenuButton;
	import buttons.MoneyButton;
	import core.Load;
	import core.Log;
	import core.Post;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.utils.setTimeout;
	import units.Hut;
	import wins.elements.RewardListActive;

	public class FreebieWindow extends Window
	{
		private var items:Array = new Array();
		public var action:Object = {};
		private var container:Sprite;
		private var priceBttn:Button;
		private var timerText:TextField;
		private var descriptionLabel:TextField;
		private var okBttn:Button;
		private var rewardSprite:Sprite;
		private var bonusList:RewardList;
		
		public function FreebieWindow(settings:Object = null)
		{
			if (settings == null) {
				settings = new Object();
			}
			//App.user.freebie = {bookmark: 0,ID: '54787fec40b14',invite: 0,join: 0,started: 1428051979,status: 0,tell: 0,uID: '34182456'};
			action = App.data.freebie[settings['ID']];
			/*action = {
				bonus: { 196:3, 4:50, 3:5000 },
				bookmark:1,
				description:"Получай бонусы и еще чего - то",
				id:1,
				invite:1,
				join:1,
				social:"VK",
				tell:1,
				title:"Получи бесплатно",
				unlock:{level:0, quest:34}
			};*/
			action.id = settings['ID'];
			
			settings['width'] = 430;
			settings['height'] = 530;
						
			//settings['title'] = Locale.__e('flash:1383038587325');
			settings['title'] = action.title;
			settings['hasPaginator'] = false;
			settings['hasButtons'] = false;
			settings["background"] = 'alertBacking';
			settings['fontSize'] = 42;
			
			settings.content = initContent(action.items);
			settings.bonus = initContent(action.stage.bonus[1]);
			
			super(settings);
		}
		
		private function initContent(data:Object):Array
		{
			var result:Array = [];
			for (var item:* in data)
			{
				result.push({sID:item, count:data[item]});
			}
			
			return result;
		}
		
		private function drawReward():void {
			titleLabel.y += 75;
			
			rewardSprite = new Sprite();

			bonusList = new RewardList(action.stage.bonus[1], false, settings.width - 50, Locale.__e("flash:1382952380000"), 1, 42, 16, 36, "x");
			bonusList.y = 265;
			
			var separator:Bitmap = Window.backingShort(300, 'dividerLine', false);
			separator.x = 70;
			separator.y = bonusList.y + 45;
			separator.alpha = 0.5;
			bodyContainer.addChild(separator);
			
			var separator2:Bitmap = Window.backingShort(300, 'dividerLine', false);
			separator2.x = 70;
			separator2.y = bonusList.y + 170;
			separator2.alpha = 0.5;
			bodyContainer.addChild(separator2);
			
			bodyContainer.addChild(bonusList);
			
			okBttn = new Button( {
				caption:Locale.__e('flash:1382952379737'),
				fontSize:26,
				width:170,
				height:50,
				hasDotes:false
			});
			
			bodyContainer.addChild(okBttn);
			okBttn.x = (settings.width - okBttn.width) / 2;
			okBttn.y = settings.height - okBttn.height - 35;
			
			okBttn.addEventListener(MouseEvent.CLICK, onOkBttn);
			//okBttn.state = Button.DISABLED;
		}
		
		private function onOkBttn(e:MouseEvent):void {
			if (okBttn.mode == Button.DISABLED) 
				return;
				
			okBttn.state = Button.DISABLED;
			take();
		}
		
		public function checkComplete():void {
			var complete:Boolean = true;
			for each(var _item:* in items) {
				//_item.complete = true;
				if (_item.complete == false)
				{
					_item.complete = false;
					complete = false;
				}
			}
			//complete = true;
			if (complete) {
				okBttn.state = Button.NORMAL;
			}
			else{
				okBttn.state = Button.DISABLED;
			}
		}
		
		override public function drawBackground():void {
			
		}
		
		private var axeX:int
		override public function drawBody():void {
			
			//exit.y -= 14;
			exit.scaleX = exit.scaleY = 0.9;
			
			var bg:Bitmap = backing(settings.width, settings.height, 120, settings.background);
			layer.addChild(bg);
		
			/*var windowIcon:Bitmap = new Bitmap(Window.textures.sale01);
			layer.addChild(windowIcon);
			windowIcon.scaleX = windowIcon.scaleY = 0.8;
			windowIcon.smoothing = true;
			windowIcon.x = (bg.width - windowIcon.width) / 2;
			windowIcon.y = bg.y + 20;
			
			var background:Bitmap = backing(settings.width - 20, settings.height - 12, 120, "questsMainBacking");
			//bodyContainer.addChildAt(background, 0);
			background.x = (settings.width - background.width) / 2;
			background.y = (settings.height - background.height) / 2 - 31;*/
			
			var cauldronIcon:Bitmap = new Bitmap(Window.texture('treasure'));
			cauldronIcon.x = (settings.width - cauldronIcon.width) / 2;
			cauldronIcon.y = - cauldronIcon.height / 2;
			bodyContainer.addChild(cauldronIcon);
			var X:int = settings.width / 2;
			var Y:int = 0;
			
			var cont:Sprite = new Sprite();
			var types:Array = ['bookmark', 'invite', 'join', 'tell'];
			
			for (var i:int = 0; i < 4; i++)
			{
				if (action[types[i]] == 0) continue;
				var item:TaskItem = new TaskItem(types[i], this);
				item.x = X - item.bttn.width / 2;
				item.y = Y;
				
				Y += item.bttn.height + 4;
				
				cont.addChild(item);
				items.push(item);
			}
			
			bodyContainer.addChild(cont);
			
			if (item) cont.y = 100 + ((4 * item.bttn.height) / 2 - cont.height / 2);
			
			drawReward();
			checkComplete();
			
			//setTimeout(function():void{
			Load.loading(Config.getIcon('Reals', 'crystal_03'), function(data:Bitmap):void {
				var image:Bitmap = new Bitmap(data.bitmapData);
				image.smoothing = true;
				image.scaleX = image.scaleY = 0.9;
				bodyContainer.addChildAt(image, 0);
				image.x = settings.width / 2 - image.width / 2;
				image.y = -20;
			});
			//}, 200);
		}
		
		public function sendChanges(type:String, value:*):void {
			
			var sendObject:Object = {
				ctr:'freebie',
				act:'set',
				uID:App.user.id,
				fID:settings.ID
			}
			
			Log.alert('fID +' + settings.ID);
			sendObject[type] = value;
			
			Post.send( sendObject, 
			function(error:int, data:Object, params:Object):void {
				if (error) {
					Errors.show(error, data);
					return;
				}
			});
		}
		
		private function take():void {
			
			App.user.freebie.status = 1;
			
			var sendObject:Object = {
				ctr:'freebie',
				act:'take',
				uID:App.user.id,
				fID:settings.ID
			}
			
			Post.send( sendObject, 
			function(error:int, data:Object, params:Object):void {
				if (error) {
					Errors.show(error, data);
					return;
				}
				
				//App.user.stock.addAll(data.bonus);
				Treasures.bonus(Treasures.convert(data.bonus), new Point(okBttn.x + okBttn.width / 2, okBttn.y));
			});
			
			/*var childs:int = rewardSprite.numChildren;
			
			while(childs--) {
				var reward:RewardItem = rewardSprite.getChildAt(childs) as RewardItem;
				
				var item:BonusItem = new BonusItem(reward.sID, reward.count);
			
				var point:Point = Window.localToGlobal(reward);
				item.cashMove(point, App.self.windowContainer);
			}*/
			
			close();
		}
		
		public function get invitedFriends():int {
			var count:int = 0;
			for (var fid:* in App.user.socInvitesFrs) {
				if (int(App.user.socInvitesFrs[fid]) == 1)
					count++;
			}
			return count;
		}
	
		public override function dispose():void
		{
			for each(var _item:* in items)
			{
				_item.dispose();
				_item = null;
			}
			super.dispose();
		}
	}
}

import api.ExternalApi;
import buttons.Button;
import core.Log;
import core.Post;
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.net.navigateToURL;
import flash.net.URLRequest;
import flash.text.TextField;
import strings.Strings;
import ui.UserInterface;
import wins.AskWindow;
import wins.Window;
import wins.FreebieWindow;

internal class TaskItem extends Sprite {
	
	public var background:Bitmap
	private var title:String = '';
	private var type:String = '';
	private var win:FreebieWindow;
	public var bttn:Button;
	private var check:Bitmap = new Bitmap(Window.textures.checkmarkSlim);
	public var _complete:Boolean = false;
	public var onClickFunction:Function;
	
	public function TaskItem(type:String, win:*) {
		
		this.type = type;
		this.win = win;
		
		switch(type) 
		{
			case 'bookmark':	title = Locale.__e('flash:1382952380107'); 					break;
			case 'invite':		title = Locale.__e('flash:1382952380108', [win.action.invite]);	break;
			case 'join':		title = Locale.__e('flash:1382952380109');						break;
			case 'tell':		title = Locale.__e('flash:1382952380110');					break;
		}
		
		bttn = new Button({
			caption			:title,
			multiline		:true,
			fontSize		:20,
			height			:45,
			width			:230,
			bgColor			:[0xfeda91, 0xfdb66a],	
			borderColor		:[0xffc289, 0xc27644],
			bevelColor		:[0xffc289, 0xc27644],
			fontColor		:0xffffff,			
			fontBorderColor	:0xa05d36,
			active:{
				bgColor:				[0xe19a53,0xeaab6e],
				borderColor:			[0xc27b45,0xffc285],	//Цвета градиента
				bevelColor:				[0xc27b45,0xffc285],	
				fontColor:				0xffffff,				//Цвет шрифта
				fontBorderColor:		0xa05d36				//Цвет обводки шрифта		
			}
			//borderColor:			[0x9f9171,0x9f9171],
			//fontColor:				0x4c4404,
			//fontBorderColor:		0xefe7d4,
			//bgColor:				[0xe3d5b5, 0xc0b292]
			//bgColor :[0x83caf7, 0x5dabdd],
			//fontColor:0xffffff,			
			//borderColor:[0xc2e2f4, 0x3384b2],
			//fontBorderColor:0x426da1
		});	
		bttn.textLabel.y -= 2;
		
		bttn.addEventListener(MouseEvent.CLICK, onClick);
		
		addChild(bttn);
		
		check.x = bttn.width - 26;
		check.y = bttn.height / 2 - check.height / 2 - 10;
		check.smoothing = true;
		
		addChild(check);
		check.visible = false;
		
		checkOnComplete();
	}
	
	private function checkOnComplete():void {
		
		function bookmarkChange(response:*):void {
			Post.addToArchive('\n showSettingsBox: ' + JSON.stringify(response));
			if (response == '1') {
				App.user.freebie['bookmark'] = 1;
				complete = true;
			}else{
				App.user.freebie['bookmark'] = 0;
				complete = false;
			}
			
			win.checkComplete();
			win.sendChanges('bookmark', App.user.freebie['bookmark']);
		}
		
		switch(type) 
		{
			case 'bookmark':
				ExternalApi.addSettingsCallback(bookmarkChange);
				ExternalApi.getAppPermission();
				
				onClickFunction = function():void {
					bttn.state = Button.NORMAL;
					ExternalApi.showSettingsBox();
				}
				if (App.user.freebie['bookmark'] >=  win.action['bookmark']) 
					complete = true;
					
				break;
				
			case 'invite':
				onClickFunction = ExternalApi.apiInviteEvent;
				
				if (win.invitedFriends >= win.action.stage.req[1].f)
					complete = true;
				
				break;
				
			case 'join':
				onClickFunction = function():void {
					navigateToURL(new URLRequest(App.self.flashVars.group), "_blank");
					win.close();
				}
				
				ExternalApi.checkGroupMember(function(resonse:*):void {
					Log.alert('\n checkGroupMember Freebie: ' + JSON.stringify(resonse));
					if (resonse == 1) {
						complete = true;
						win.checkComplete();
						App.user.freebie['join'] = 1;
						win.sendChanges('join', 1);
					}
					else {
						App.user.freebie['join'] = 0;
						win.sendChanges('join', 0);
					}
				});
				
				if (App.user.freebie['join'] >=  win.action['join']) //расскомитить
					complete = true;
				
				break;
				
			case 'tell':
				//onClickFunction = win.sendPost;
				onClickFunction = function():void {
					
					sendPost();
					//onPostComplete( { post_id:7 } );
				}
				
				Log.alert('INFO');
				Log.alert(App.user.freebie);
				Log.alert(win.action);
				
				if (App.user.freebie['tell'] >=  win.action['tell']) //расскомитить
					complete = true;
					
				break;
		}
	}
	
	public function set complete(value:Boolean):void {
		
		_complete = value;
		
		if(value)
				state = Button.ACTIVE;
			else
				state = Button.NORMAL;
	}
	
	public function get complete():Boolean {
		return _complete;
	}
	
	private function onClick(e:MouseEvent):void {
		
		if (e.currentTarget.mode == Button.NORMAL) {
			//e.currentTarget.mode = Button.DISABLED;
			onClickFunction();
		}
	}
	
	public function dispose():void {
		bttn.removeEventListener(MouseEvent.CLICK, onClick);
	}
	
	public function set state(value:uint):void {
		
		if (value == Button.ACTIVE) {
			bttn.state = value;
			check.visible = true;
		}else{
			check.visible = false;
			bttn.state = value;
		}
	}
	
	public function sendPost():void 
	{
		//var message:String = Locale.__e("flash:1382952380041 играю в \"flash:1382952379705\". %s", [Config.appUrl]);
		var message:String = Strings.__e("FreebieWindow_sendPost", [Config.appUrl]);
		var bitmap:Bitmap = new Bitmap(UserInterface.textures.goldenLogo, "auto", true);
		
		if (bitmap != null) {
			ExternalApi.apiWallPostEvent(ExternalApi.PROMO, bitmap, String(App.user.id), message, 0, onPostComplete, {url:Config.appUrl});
		}
	}
	
	public function onPostComplete(result:*):void
	{
		if (App.social == "ML" && result.status != "publishSuccess")
			return;
		
		switch(App.self.flashVars.social)
		{
			case "VK":
					if (result != null && result.hasOwnProperty('post_id')) {
						App.user.freebie['tell'] = 1;
						win.sendChanges('tell', 1);
						complete = true;
					}
				break;
			case "OK":
					if (result != null && result != "null") {
						App.user.freebie['tell'] = 1;
						win.sendChanges('tell', 1);
						complete = true;
					}
				break;
			case "ML":
					if (result != null && result != "null") {
						App.user.freebie['tell'] = 1;
						win.sendChanges('tell', 1);
						complete = true;
					}
				break;
			case "FS":
				if (result) {
					App.user.freebie['tell'] = 1;
					win.sendChanges('tell', 1);
					complete = true;
				}
				break;	
		}
		win.checkComplete();
	}
}
