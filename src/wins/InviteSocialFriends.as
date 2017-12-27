package wins 
{
	import api.ExternalApi;
	import api.OKApi;
	import buttons.Button;
	import buttons.ImageButton;
	import buttons.ImagesButton;
	import core.AvaLoad;
	import core.Load;
	import core.Log;
	import core.Post;
	import flash.display.Bitmap;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.text.TextField;
	import ui.Hints;
	import ui.UserInterface;
	/**
	 * ...
	 * @author ...
	 */
	public class InviteSocialFriends extends Window 
	{
		public var capasitySprite:LayerX = new LayerX();
		private var capasitySlider:Sprite = new Sprite();
		private var capasityCounter:TextField;
		private var takeBttn:Button;
		public var capasityBar:Bitmap;
		//public var capasityBar:Bitmap;
		
		public var currFriends:int = 0;
		public var needFriends:int = 0;
		
		public var achive:Object;
		public var mission:Object;
		public var numMission:int = 0;
		
		public var idMission:int = 21;
		
		public function InviteSocialFriends(settings:Object=null) 
		{
			if (settings == null) {
				settings = new Object();
			}
			settings['width'] = 403;
			settings['height'] = 491;
			settings['fontSize'] = 40;
			settings['fontColor'] = 0xffffff;
			settings['fontBorderColor'] = 0x5a2a79;
			settings['shadowBorderColor'] = 0xad52e2;
			
			settings['title'] = Locale.__e("flash:1406562866197");
			settings['hasPaginator'] = false;
			settings['hasButtons'] = false;
			super(settings);
			
			for (var ach:* in App.data.ach) {
				if (App.data.ach[ach].ID == idMission)
					achive = App.data.ach[ach];
			}
			
			numMission = getMission();
			
			var count:int = 1;
			for (var mis:* in achive.missions) {
				if (count == numMission) {
					mission = achive.missions[mis];
					break;
				}
				count++;
			}
			
			needFriends = achive.missions[numMission].need;
		}
		
		public static function canShow():Boolean
		{
			var missID:int = 21;
			var missNum:int = 1;
			var achiveT:Object;
			for (var ach:* in App.data.ach) {
				if (App.data.ach[ach].ID == missID)
					achiveT = App.data.ach[ach];
			}
			if (!achiveT)
				return false;
			
			
			for (var cnt:* in App.user.ach[missID]) {
				if (App.user.ach[missID][cnt] > 1000000000)
					missNum++;
			}
			
			if (missNum == 0) missNum = 1;
			
			var numTotal:int = 0;
			for (var cnt2:* in achiveT.missions) {
				numTotal++;
			}
			
			if (missNum <= numTotal) 
				return  true;
				
			return false;
		}
		
		private function getMission():int 
		{
			var num:int = 1;
			for (var cnt:* in App.user.ach[idMission]) {
				if (App.user.ach[idMission][cnt] > 1000000000)
					num++;
			}
			
			if (num == 0) num = 1;
			return num;
		}
		
		override public function drawExit():void {
		}
		override public function drawTitle():void {
		}
		
		override public function drawBackground():void 
		{
			var background:Bitmap = backing(settings.width, settings.height, 45, "questBacking");
			background.y += 40;
			layer.addChild(background);
		}
		
		override public function drawBody():void 
		{
			var rewardBack:Bitmap = backing(321, 163, 45, "dialogueBacking");
			rewardBack.x = (settings.width - rewardBack.width) / 2;
			rewardBack.y = (settings.height - rewardBack.height) / 2 + 145;
			bodyContainer.addChild(rewardBack);
			
			Load.loading(Config.getIcon('Reals', 'crystal_01'), function(data:Bitmap):void {
				var image:Bitmap = new Bitmap(data.bitmapData);
				image.smoothing = true;
				bodyContainer.addChild(image);
				image.x = rewardBack.x + (rewardBack.width - image.width) / 2;
				image.y = rewardBack.y + (rewardBack.height - image.height) / 2;
				
				var prizeCount:TextField = Window.drawText("x" + achive.missions[numMission].bonus[Stock.FANT], {
				color		:0xffffff,
				borderColor	:0x41332b,
				textAlign	:"center",
				autoSize	:"center",
				fontSize	:32
				});
				prizeCount.x = rewardBack.x + (rewardBack.width - prizeCount.width) / 2 + 50;
				prizeCount.y = rewardBack.y + rewardBack.height - 60;
				bodyContainer.addChild(prizeCount);
			});
			
			//addSlider();
			
			var rewardTitle:TextField = Window.drawText(Locale.__e('flash:1382952380000'), {
				color		:0xffffff,
				borderColor	:0x5d3c03,
				textAlign	:"center",
				autoSize	:"center",
				fontSize	:32
			});
			rewardTitle.x = rewardBack.x + (rewardBack.width - rewardTitle.width) / 2;
			rewardTitle.y = rewardBack.y - 20;
			bodyContainer.addChild(rewardTitle);
			
			
			var titleContainer:Sprite = new Sprite();
			var titleText:TextField = Window.drawText(Locale.__e('flash:1382952380285'), {
				color		:0xffffff,
				borderColor	:0xa87749,
				textAlign	:"center",
				autoSize	:"center",
				fontSize	:44
			});
				titleContainer.addChild(titleText);
				titleText.x = (settings.width - titleText.width) / 2;
				titleText.y = (settings.height - titleText.height) / 2 - 205;
				titleContainer.filters = [new GlowFilter(0x855729, 1, 4, 4, 8, 1)];
			bodyContainer.addChild(titleContainer);
			
			var descLabel:TextField = Window.drawText(Locale.__e('flash:1407155423881'), {
				color		:0xffffff,
				borderColor	:0x7d622e,
				textAlign	:"center",
				autoSize	:"center",
				fontSize	:24,
				textLeading	: 0,
				width		:280,
				wrap		:true,
				multiline	:true
			});
			bodyContainer.addChild(descLabel);
			descLabel.x = (settings.width - descLabel.width) / 2 + 45;
			descLabel.y = (settings.height - descLabel.height) / 2 - 130;
			
			
			
			drawMirrowObjs('diamondsTop', titleText.x - 5, titleText.x + titleText.width + 5, titleText.y + 8, true, true);
			drawMirrowObjs('storageWoodenDec',0, settings.width, settings.height - 30);
			drawMirrowObjs('storageWoodenDec', 0, settings.width, 110, false, false, false, 1, -1);
			
			
			drawButtons();
			addSlider();
		}
		
		private function addSlider():void
		{
			capasityBar = new Bitmap(Window.textures.prograssBarBacking);			
			capasityBar.x;
			capasityBar.y = 22;
			capasityBar.width = 353;
			Window.slider(capasitySlider, 60, 60, "progressBar", false, 0, 337);
			
			bodyContainer.addChild(capasitySprite);
			
			capasitySprite.x = (settings.width - capasityBar.width) / 2; 
			capasitySprite.y = (settings.height - capasityBar.height) / 2 - 65; 
			
			var textSettings:Object = {
				color:0xffffff,
				borderColor:0x644b2b,
				fontSize:32,
				textAlign:"center"
			};
			
			capasityCounter = Window.drawText(currFriends +'/'+ needFriends, textSettings); 
			capasityCounter.width = 120;
			capasityCounter.height = capasityCounter.textHeight;
			
			capasitySprite.mouseChildren = false;
			capasitySprite.addChild(capasityBar);
			capasitySprite.addChild(capasitySlider);
			capasitySprite.addChild(capasityCounter);
			
			capasitySlider.x = capasityBar.x + 8; 
			capasitySlider.y = capasityBar.y + 6;
			
			
			capasityCounter.x = capasityBar.width / 2 - capasityCounter.width / 2; 
			capasityCounter.y = capasityBar.y - capasityBar.height / 2 + capasityCounter.textHeight / 2 + 8;
			
			updateCapasity();
		}
		
		public function updateCapasity():void
		{
			if (capasitySlider) {
				
				currFriends = 0;
					
				for (var key:* in App.user.socInvitesFrs) {
					if (App.user.socInvitesFrs[key] == 1) {
						currFriends++;
					}
				}
				
				if (currFriends > needFriends)
					currFriends = needFriends;
				
				Window.slider(capasitySlider, currFriends, needFriends, "progressBar", false, 0, 337);
				
				if(capasityCounter){
					capasityCounter.text = currFriends +'/' + needFriends;
					capasityCounter.x = capasityBar.width / 2 - capasityCounter.width / 2;
				}
				
				if (currFriends >= needFriends) {
					takeBttn.state = Button.NORMAL;
				}
			}
		}
		
		private function drawButtons():void
		{
			var iconCont:ImageButton = new ImagesButton( Window.textures.buildingsSlot, UserInterface.textures.friendsIcon, { 
				description		:"Облачко",
				params			:{ }
			});
			iconCont.bitmap.x = -3
			iconCont.bitmap.y = 6;
			iconCont.addEventListener(MouseEvent.CLICK, onShowFriens);
			iconCont.x = settings.width/3 - iconCont.width;
			iconCont.y = settings.height/3 - iconCont.height;
			bodyContainer.addChild(iconCont);
			
			var separator:Bitmap = Window.backingShort(settings.width - 60, 'divider');
			separator.alpha = 0.9;
			bodyContainer.addChild(separator);
			separator.x = (settings.width - separator.width) / 2;
			separator.y = (settings.height - separator.height) / 2 + 15;
			
			var inviteBttn:Button  = new Button( {
					bevelColor		:[0xfeee7b, 0xbf7e1a],
					bgColor			:[0xf5d058, 0xeeb331],
					fontColor		:0xffffff,
					fontBorderColor	:0xa05d36,
					fontBorderSize	:3,
					width			:160,
					height			:47,
					fontSize		:26,
					caption			:Locale.__e("flash:1382952380197")
				});				
			bodyContainer.addChild(inviteBttn);
			inviteBttn.x = (settings.width - inviteBttn.width) / 2;
			inviteBttn.y = (settings.height - inviteBttn.height) / 2 + 15;
				
			takeBttn  = new Button( {
					bevelColor		:[0xffc8a8, 0xd04b27],
					bgColor			:[0xffcbae, 0xf55e43],
					fontColor		:0xffffff,
					fontBorderColor	:0x814f31,
					fontBorderSize	:3,
					width			:160,
					height			:47,
					fontSize		:26,
					caption			:Locale.__e("flash:1382952379737")
				});	
				//takeBttn.x = inviteBttn.x + inviteBttn.width + 17;
				bodyContainer.addChild(takeBttn);
				takeBttn.x = (settings.width - takeBttn.width) / 2;
				takeBttn.y = (settings.height - inviteBttn.height) / 2 + 250;
				
			takeBttn.state = Button.DISABLED;
			
			inviteBttn.addEventListener(MouseEvent.CLICK, onShowFriends);
			takeBttn.addEventListener(MouseEvent.CLICK, onTake);
		}
		
		private function showInviteCallback(e:*):void {
			Log.alert('showInviteCallback');
			Log.alert(e.data);
			
			Post.send( {
				ctr:'user',
				act:'setinvite',
				uID:App.user.id,
				fID:e.data
			},function(error:*, data:*, params:*):void {
				if (error) {
					Errors.show(error, data);
					return;
				}
			});
		}
		
		private function onShowFriends(e:MouseEvent):void 
		{
			if (App.social == "OK"){
				OKApi.showInviteCallback = showInviteCallback;
				ExternalApi.apiInviteEvent();
			}else{
				new AskWindow(AskWindow.MODE_NOTIFY_2,  { 
					title:Locale.__e('flash:1407159672690'), 
					inviteTxt:Locale.__e("flash:1407159700409"), 
					desc:Locale.__e("flash:1408542375687"),
					descY:30,
					height:530
				},  function(uid:String):void {
						ExternalApi.notifyFriend({uid:uid, text:Locale.__e('flash:1407155160192'),callback:Post.statisticPost(Post.STATISTIC_INVITE)});
					} ).show();
			}
		}
		
		private function onTake(e:MouseEvent):void 
		{
			if (takeBttn.mode == Button.DISABLED) 
				return;
				
			takeBttn.state = Button.DISABLED;
			take();
		}
		
		private function take():void 
		{
			var indMission:int;
			var count:int = 1;
			
			Post.send({
				ctr:'ach',
				act:'take',
				uID:App.user.id,
				qID:idMission,
				mID:numMission
			}, onTakeBonus);
			
		}
		
		private function onTakeBonus(error:int, data:Object, params:Object):void 
		{
			if (error) {
				Errors.show(error, data);
				return;
			}	
			if (data.bonus) {
				for (var bns:* in data.bonus) {
					App.user.stock.add(bns, data.bonus[bns]);
					
					var pnt:Point = Window.localToGlobal(takeBttn)
					var pntThis:Point = new Point(pnt.x, pnt.y + 10);
					Hints.plus(bns, data.bonus[bns], pntThis, false, this);
					
					flyMaterial();
				}
			}
			
			App.user.ach[idMission][numMission] = App.time;
			App.user.quests.checkFreebie();
			close();
		}
		
		private function flyMaterial():void
		{
			for (var _ind:* in mission.bonus) {
				break;
			}
			
			var item:BonusItem = new BonusItem(_ind, 0);
			
			var point:Point = Window.localToGlobal(takeBttn);
			item.cashMove(point, App.self.windowContainer);
		}
		
	}

}