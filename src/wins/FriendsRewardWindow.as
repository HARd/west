package wins 
{
	import api.ExternalApi;
	import buttons.Button;
	import buttons.ImageButton;
	import buttons.MoneyButton;
	import com.flashdynamix.motion.extras.BitmapTiler;
	import core.Load;
	import core.Log;
	import core.Post;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.utils.setTimeout;
	import strings.Strings;

	public class FriendsRewardWindow extends Window
	{
		public var items:Array = new Array();
		private var back:Bitmap;
		private var okBttn:Button;
		public var currentDayItem:FriendRewardItem;
		public var friendsCount:int = 6;
		public var giftStage:int = 3;
		public var progressBar:ProgressBar;
		public var progressBacking:Bitmap;
		private var progressTitle:TextField;
		
		public function FriendsRewardWindow(settings:Object = null) 
		{
			if (settings == null) {
				settings = new Object();
			}
			
			//App.user.freebie = {bookmark: 0,ID: '54787fec40b14',invite: 0,join: 0,started: 1428051979,status: 3,tell: 0,uID: '34182456'};
			
			settings['width'] 				= 800;
			settings['height'] 				= 435;
			settings['title'] 				= Locale.__e("flash:1431434307700");
			settings['hasPaginator'] 		= false;
			settings['content'] 			= [];
			settings['fontSize'] 			= 48;
			settings['shadowBorderColor']   = 0x342411;
			settings['fontBorderSize'] 		= 4;
			
			var defContent:Object = 
			[ { bonus: { 3:5 }, stage:1,f:5, desc:'' },
			 { bonus: { 4:5 }, stage:2,f:10, desc:'' },
			 { bonus: { 5:10 }, stage:3,f:15, desc:'' },
			 { bonus: { 6:15 }, stage:4,f:20, desc:'' },
			 { bonus: { 10:13 }, stage:5,f:30, desc:'' } ];
			
			if (freebieValue) {
				for (var item:Object in freebieValue.bonus)
				{
					var rel:Object = { };
					rel = freebieValue.req[item];
					rel['bonus'] = (freebieValue.bonus[item]);
					rel['stage'] = item;
					var obj:Object = { };
			
					settings.content.push(rel);
				}
			} 
			
			super(settings);
			friendsCount = invitedFriends;
			giftStage = curStage;
		}
		
		private function get curStage():int 
		{
			var value:int = 0;
			for (var item:Object in settings.content)
			{
				if (int(settings.content[item].f)<=friendsCount&&(value<int(settings.content[item].f))) 
				{
					value = settings.content[item].f;
				} 
			}
			return value;
		}
		
		public static function get freebieValue():Object {
			var value:Object;
			if (App.data.hasOwnProperty('freebie')) {
				for each(var freebie:* in App.data.freebie) {
					if (freebie['social'] == App.social && freebie.hasOwnProperty('stage') && freebie.stage.hasOwnProperty('req')) {
						value = freebie.stage;
					}
					//value = { 'bonus': { '1':{'3':2000, '27':10, '150':20}, '2':{'27':25}, '3':{'105':5}, '4':{'49':10}, '5':{'229':5}}, 'req': {'1':{'f':5}, '2':{'f':15}, '3':{'f':30}, '4':{'f':50}, '5':{'f':75}}};
				}
			}
			return value;
		}
		
		public function get invitedFriends():int {
			var count:int = 0;
			for (var fid:* in App.user.socInvitesFrs) {
				if (int(App.user.socInvitesFrs[fid]) == 1)
					count++;
			}
			return count;
		}
		
		override public function drawBackground():void {

			back = Window.backing(settings.width, settings.height, 50, 'alertBacking');
			layer.addChild(back);			
		}
			
		private function get maxFriends():int
		{
			var count:int = 0;
			for (var i:* in settings.content) {
				if (settings.content[i].stage == App.user.freebie.status + 1) {
					count = settings.content[i].f;
					if (count == friendsCount) 
					{
						new FriendRewardWindow(settings.content[i], settings.ID).show();
					}
				}
			}
			
			return count;
		}
		
		override public function drawBody():void {
			Load.loading(Config.getImage('promo/images', 'crystals'), function(data:Bitmap):void {
					var image:Bitmap = new Bitmap(data.bitmapData);
					headerContainer.addChildAt(image, 0);
					image.x = settings.width / 2 - image.width / 2;
					image.y = -80;
			});
			
			drawItems();
			
			titleLabel.y += 10;
			
			var descLabel:TextField = Window.drawText(Locale.__e("flash:1393580882265"), {
				fontSize	:28,
				color		:0x72451C,
				borderColor	:0xFFFFFF,
				textAlign	:"center"
			});
			descLabel.width = descLabel.textWidth + 20;
			descLabel.x = titleLabel.x + (titleLabel.width - descLabel.width) / 2;
			descLabel.y = 25;
			
			var bg:Bitmap = Window.backing(settings.width - 140, 40, 50, "fadeOutWhite");
			bg.alpha = 0.3;
			bg.x = (settings.width - bg.width) * .5;
			bg.y = 20;
			bodyContainer.addChild(bg);
			
			bodyContainer.addChild(descLabel);
					
			progressBacking = Window.backingShort(470, "progBarBacking");
			progressBacking.x = (settings.width - progressBacking.width) / 2;
			progressBacking.y = 295;
			bodyContainer.addChild(progressBacking);
			
			progressBar = new ProgressBar( {win:this, width:486, isTimer:false} );
			progressBar.x = progressBacking.x - 8;
			progressBar.y = progressBacking.y - 4;
			progressBar.progress = friendsCount / maxFriends;
			progressBar.start();
			bodyContainer.addChild(progressBar);
			
			progressTitle = drawText(progressData, {
				fontSize:32,
				autoSize:"left",
				textAlign:"center",
				color:0xffffff,
				borderColor:0x6b340c,
				shadowColor:0x6b340c,
				shadowSize:1
			});
			progressTitle.x = progressBacking.x + progressBacking.width / 2 - progressTitle.width / 2;
			progressTitle.y = progressBacking.y - 2;
			progressTitle.width = 80;
			bodyContainer.addChild(progressTitle);
			
			okBttn = new Button( {
				caption:Locale.__e('flash:1382952380197'),
				fontSize:28,
				width:167,
				height:53
			});
			
			bodyContainer.addChild(okBttn);
			okBttn.x = (settings.width - okBttn.width) / 2;
			okBttn.y = settings.height - 90;
			okBttn.addEventListener(MouseEvent.CLICK, onOkBttn);
		}
		
		public function get progressData():String {
			return String(friendsCount) + '/' + String(maxFriends);
		}
		
		private function onOkBttn(e:MouseEvent):void {
			if (e.currentTarget.mode == Button.DISABLED) return;
			
			//e.currentTarget.state = Button.DISABLED
			
			//потом розкоментировать и приспособить AskWindow
			//начало
			if (App.isSocial('DM') || App.isSocial('VK')) {
				new AskWindow(AskWindow.MODE_NOTIFY_2,  { 
					title:Locale.__e('flash:1407159672690'), 
					inviteTxt:Locale.__e("flash:1407159700409"), 
					desc:Locale.__e("flash:1407155423881"),
					descY:30,
					height:530,
					itemsMode:5
				},  function(uid:*):void {
						ExternalApi.notifyFriend( {
							uid:	String(uid),
							text:	Locale.__e('flash:1408696336510'),
							type:	'gift'
						})
					//ExternalApi.notifyFriend({uid:uid, text:Locale.__e('flash:1407155160192'),callback:Post.statisticPost(Post.STATISTIC_INVITE)});
					} ).show();
			}
			
			if (App.isSocial('OK') || App.isSocial('ML')) {
				ExternalApi.apiInviteEvent();
			}
			//take();
			//конец
		}
		
		public function sendPost(uid:*):void {
		var message:String = Strings.__e("FreebieWindow_sendPost", [Config.appUrl]);
		var bitmap:Bitmap = new Bitmap(Window.textures.iPlay, "auto", true);
		
		if (bitmap != null) {
			ExternalApi.apiWallPostEvent(ExternalApi.GIFT, bitmap, String(uid), message, 0, null, {url:Config.appUrl});// , App.ui.bottomPanel.removePostPreloader);
				
			//ExternalApi.apiWallPostEvent(ExternalApi.PROMO, bitmap, String(App.user.id), message, 0, null, {url:Config.appUrl});
		}
	}
		
		private var container:Sprite;
		private var OffsetY:int = 35;
		private function drawItems():void {
			
			var centralBack:Bitmap = Window.backing(settings.width - 120, 153, 50, 'fadeOutWhite');
			bodyContainer.addChild(centralBack);
			centralBack.alpha = 0.3;
			centralBack.x = (settings.width - centralBack.width) / 2;
			centralBack.y = 120;
			
			var up_devider:Bitmap = new Bitmap(Window.textures.dividerLine);
			up_devider.x = centralBack.x;
			up_devider.y = centralBack.y - up_devider.height - 5;
			up_devider.width = settings.width - 150;
			up_devider.alpha = 0.6;
			
			bodyContainer.addChild(up_devider);
			
			var down_devider:Bitmap = new Bitmap(Window.textures.dividerLine);
			down_devider.x = up_devider.x;
			down_devider.width = up_devider.width;
			down_devider.y = centralBack.y + centralBack.height + 5;
			down_devider.alpha = 0.6;
			bodyContainer.addChild(down_devider);
			
			container = new Sprite();
			var X:int = 0;
			var Y:int = 0;
			
			for (var i:int = 0; i < 5; i++) {
				
				var item:FriendRewardItem = new FriendRewardItem(settings.content[i], this, i);	
				
				container.addChild(item);
				item.x = X;
				item.y = Y;
				
				X += item.circle.width + 15;
			}
			
			bodyContainer.addChild(container);
			container.x = (settings.width - container.width) / 2;
			container.y = 100;
		}
		
		public function take():void 
		{
/*			Post.send( {
				ctr:'user',
				act:'day',
				uID:App.user.id
			}, function(error:int, data:Object, params:Object):void {
				
				if (error) {
					Errors.show(error, data);
					return;
				}
				
				if (App.social == 'FB') {						
					ExternalApi.og('claim', 'daily_bonus');
				}
				
				App.user.stock.addAll(data.bonus);
				
				for (var _sid:* in data.bonus) {
					var item:BonusItem = new BonusItem(_sid, data.bonus[_sid]);
					var point:Point = Window.localToGlobal(currentDayItem);
					point.y += 80;
					item.cashMove(point, App.self.windowContainer);
				}
				
				setTimeout(close, 300);
			});*/
		}
		
		override public function dispose():void {
			while (container.numChildren > 0) {
				var _item:* = container.getChildAt(0);
				if (_item is FriendRewardItem) _item.dispose();
				container.removeChild(_item);
			}
			okBttn.removeEventListener(MouseEvent.CLICK, onOkBttn);
			
			super.dispose();
		}
	}
}	


import adobe.utils.CustomActions;
import core.Load;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.filters.GlowFilter;
import flash.geom.ColorTransform;
import flash.geom.Matrix;
import flash.text.TextField;
import flash.utils.clearInterval;
import flash.utils.setInterval;
import ui.UserInterface;
import wins.FriendsRewardWindow;
import wins.Window;
	

internal class FriendRewardItem extends LayerX {
	
	private var item:Object;
	public var circle:Shape;
	public var win:FriendsRewardWindow;
	private var title:TextField;
	private var sID:uint;
	private var count:uint;
	private var bitmap:Bitmap;
	private var status:int = 0;
	public var itemDay:int;
	private var check:Bitmap = new Bitmap(Window.textures.checkMark);
	private var layer:LayerX;
	private var intervalPluck:int;
	public var isCurrent:Boolean = false;
	
	public function FriendRewardItem(item:Object, win:FriendsRewardWindow,numb:int = 0) {
		
		this.win = win;
		this.item = item;
		
		if (numb > App.user.freebie.status) {
			status = 2;
		}
		if (numb < App.user.freebie.status) {
			status = 0;
		}
		
		if (numb == App.user.freebie.status) {
			status = 1;
			isCurrent = true;
		}
		
		circle = new Shape();
		
		if (status == 1) {
			circle.graphics.beginFill(0xb1c0b9, 1);
			circle.graphics.drawCircle(80, 100, 70);
			circle.graphics.endFill();
			circle.x += 15;
		} else {
			circle.graphics.beginFill(0xb1c0b9, 1);
			circle.graphics.drawCircle(80, 100, 55);
			circle.graphics.endFill();
		}
		
		addChild(circle);
		circle.x -= 25;
		
		layer = new LayerX();
		addChild(layer);
		bitmap = new Bitmap();
		if (isCurrent) {
			var gf:GlowEffect = new GlowEffect();
			gf.scaleX = gf.scaleY = 1.2;
			gf.x = circle.width / 2;
			gf.y = 200/ 2;
			layer.addChild(gf);
			gf.start();
		}
		layer.addChild(bitmap);
		
		if (item == null) return;
		
		for (var _sID:* in item.bonus) break;
			sID = _sID;
		count = item.bonus[_sID];
		
		drawTitle();		
		
		Load.loading(Config.getIcon(App.data.storage[sID].type, App.data.storage[sID].preview), function(data:Bitmap):void {
			bitmap.bitmapData = data.bitmapData;
			var needScale:Number = Math.max(data.width / circle.width, data.height / circle.height);
			if (needScale > 1){
				var scale:Number = 1 / needScale;
				var matrix:Matrix = new Matrix();
				matrix.scale(scale, scale);
				var smallBMD:BitmapData = new BitmapData(data.width * scale, data.height * scale, true, 0x000000);
				smallBMD.draw(data, matrix, null, null, null, true);
				bitmap.bitmapData = smallBMD;
			}
			if(sID == Stock.EXP)
				bitmap.scaleX = bitmap.scaleY = 0.8;
			else
				bitmap.scaleX = bitmap.scaleY = 0.9;
			bitmap.smoothing = true;
			bitmap.x = (circle.width - bitmap.width) / 2;
			bitmap.y = (200 - bitmap.height) / 2;
			if (status == 1) startPluck();
			if (sID == Stock.FANT) return;
		});
		drawMark();
		drawCount();
		if (status == 2) {
			UserInterface.effect(circle, 0, 0.4);
		}
	}
	
	private function drawMark():void 
	{
		if (status != 1) {
			var shadow:Shape = new Shape();
			shadow.graphics.beginFill(0x000000, 1);
			shadow.graphics.drawCircle(80, 100, 55);
			shadow.graphics.endFill();
			shadow.alpha = 0.3;
			shadow.x -= 25;
			addChild(shadow);
		}
		if (status == 0 && !isCurrent){
			UserInterface.effect(circle, 0, 0.8);
			addChild(check);
		}
		check.x = (circle.width - check.width) / 2;
		check.y = (200 - check.height) / 2;
	}
		
	private function drawTitle():void
	{
		var fontSize:int = 24;
		var borderColor:uint = 0x97662b;
		if (status == 1) {
			fontSize = 30;
			borderColor = 0x7f400b;
		}
		title = Window.drawText(Locale.__e('flash:1431438412849',[item.f]), {
			color:0xffffff,
			borderColor:borderColor,
			textAlign:"center",
			autoSize:"center",
			fontSize:fontSize,
			textLeading:-6,
			multiline:false
		});
		title.wordWrap = true;
		title.y = -20;
		if (status == 1) {
			title.y = -30;
			
			var bg:Bitmap = Window.backing(title.textWidth * 1.5, 50, 50, "fadeOutYellow");
			bg.alpha = 0.8;
			bg.x = title.x;
			bg.y = title.y - 10;
			addChild(bg);
		}
		title.x = (circle.width - title.width) / 2;
		
		addChild(title)
	}
	
	private function drawCount():void
	{
		var countText:TextField = Window.drawText("x" + String(count), {
			color:0xffffff,
			borderColor:0x682f1e,
			textAlign:"left",
			autoSize:"center",
			fontSize:28,
			textLeading: -6,
			width:80
		});
		countText.y = 150 - countText.height / 2;
		countText.x = circle.width / 2 + 10;
		addChild(countText)
		
	}
	
	public function startPluck():void {
		intervalPluck = setInterval(randomPluck, Math.random()* 5000 + 2000);
	}
	
	private function randomPluck():void
	{
		layer.pluck(30, layer.width / 2, layer.height / 2 + 50);
	}
	
	public function dispose():void {
		clearInterval(intervalPluck);
		layer.pluckDispose();
	}
}

internal class GlowEffect extends Sprite {
	private var glowBitmap:Bitmap = new Bitmap(Window.textures.iconGlow);
	private var glowCont:Sprite = new Sprite();
	
	public function GlowEffect():void {
		addChild(glowCont);
		glowBitmap.x = -glowBitmap.width / 2;
		glowBitmap.y = -glowBitmap.height / 2;
		glowCont.addChild(glowBitmap);
	}
	
	public function start():void {
		var that:GlowEffect = this;
		
		App.self.setOnEnterFrame(function():void {
			if (that && that.parent) {
				glowCont.rotation++;
			}else {
				App.self.setOffEnterFrame(arguments.callee);
			}
		});
	}
	
}