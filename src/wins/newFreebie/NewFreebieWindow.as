package wins.newFreebie 
{
	import api.ExternalApi;
	import api.MailApi;
	import api.OKApi;
	import buttons.Button;
	import buttons.ImageButton;
	import core.Load;
	import core.Log;
	import core.Post;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import wins.AskWindow;
	import wins.GiftWindow;
	import wins.InfoWindow;
	import wins.InvitesWindow;
	import wins.Window;
	
	public class NewFreebieWindow extends Window 
	{
		private var _helpBttn:ImageButton;
		private var _shareButton:Button;
		
		private var _titleBG:Bitmap;
		private var _titleTextSprite:Sprite;
		private var _descriptionText:TextField;
		private var _bitmapFurry:Bitmap;
		
		public function NewFreebieWindow(settings:Object=null) 
		{
			settings["hasPaginator"] = false;
			settings["width"] = 690;
			settings["height"] = 550;
			settings["background"] = "questBacking";
			settings["hasTitle"] = false;
			settings["title"] = Locale.__e("flash:1458913635651");
			
			
			super(settings);
		}
		
		override public function drawBackground():void {
			background = backing2(settings.width, settings.height, 50, 'shopBackingTop', 'shopBackingBot');
			layer.addChild(background);
		}
		
		override public function drawBody():void 
		{
			super.drawBody();
			
			exit.y += 10;
			
			_titleBG = Window.backing(590, 215, 50, "itemBacking");
			_titleBG.x = 50;
			_titleBG.y = 50;
			bodyContainer.addChild(_titleBG);
			
			// furry art
			_bitmapFurry = new Bitmap();
			_bitmapFurry.x = 40;
			_bitmapFurry.y = 40;
			bodyContainer.addChild(_bitmapFurry);
			
			Load.loading(Config.getImage('content', 'NewFribyPic1'), function(data:*):void {
				_bitmapFurry.bitmapData = data.bitmapData;
			});
			
			_titleTextSprite = titleText( {
					title				: settings.title,
					color				: 0xffffff,
					multiline			: settings.multiline,			
					fontSize			: 50,
					textLeading	 		: settings.textLeading,	
					border				: true,
					borderColor 		: 0xc4964e,			
					borderSize 			: 4,	
					shadowColor			: 0x503f33,
					shadowSize			: 4,
					width				: settings.width - 140,
					textAlign			: 'center',
					sharpness 			: 50,
					thickness			: 50
				});
				
			_titleTextSprite.x = (settings.width - _titleTextSprite.width) * .5;
			_titleTextSprite.y = -15;
			bodyContainer.addChild(_titleTextSprite);
			
			
			var titleBounds:Rectangle = _titleTextSprite.getBounds(bodyContainer);
			Window.addMirrowObjs(bodyContainer, "titleDecRose", titleBounds.x + 90, titleBounds.x + titleBounds.width - 90, titleBounds.y + 10);
			
			var descBg:Bitmap = Window.backing(380, 150, 50, "itemBacking");
			descBg.alpha = 0.3;
			descBg.x = 240;
			descBg.y = 100;
			bodyContainer.addChild(descBg);
			
			_descriptionText = Window.drawText(Locale.__e("flash:1458913696448"), {
				color:0xfff7e9,
				borderColor:0x673915,
				borderSize:6,
				wrap:true,
				multiline:true,
				width: descBg.width,
				height: descBg.height - 15,
				textAlign:"center",
				fontSize:25
			});
			_descriptionText.x = descBg.x + (descBg.width - _descriptionText.width) * .5;
			_descriptionText.y = descBg.y + (descBg.height - _descriptionText.height) * .5;
			bodyContainer.addChild(_descriptionText);
			
			
			_shareButton = new Button( { width:195, height:55, caption:Locale.__e("flash:1458913722744") } );
			_shareButton.x = (settings.width - _shareButton.width) * .5;
			_shareButton.y = settings.height - (_shareButton.height * .65) - 20;
			_shareButton.addEventListener(MouseEvent.CLICK, onShareButtonClick);
			bodyContainer.addChild(_shareButton);
			
			
			_helpBttn = new ImageButton(Window.textures["interHelpBttn"]);
			
			_helpBttn.addEventListener(MouseEvent.CLICK, onHelpBttnClick);
			_helpBttn.x = settings.width - _helpBttn.width - 70;
			_helpBttn.y = -5;
			bodyContainer.addChild(_helpBttn);
			
			contentChange();
		}
		
		override public function drawExit():void 
		{
			super.drawExit();
			exit.y -= 22;
		}
		
		private function onHelpBttnClick(e:MouseEvent):void 
		{
			new InfoWindow( { 
				popup:true,
				qID:'freebie'
			} ).show();
		}
		
		
		private var _rewardItems:Vector.<NewFreebieRewardItem>
		private const ICON_NAMES:Array = ["newFribyGiftPic1", "newFribyGiftPic2", "newFribyGiftPic3", "newFribyGiftPic4"];
		override public function contentChange():void 
		{			
			if (!_rewardItems)
				_rewardItems = new Vector.<NewFreebieRewardItem>();
			
				
			var currentItem:NewFreebieRewardItem;
			var length:int = _rewardItems.length;
			for (var i:int = 0; i < length; i++) 
			{
				currentItem = _rewardItems.shift();
				bodyContainer.removeChild(currentItem);
				currentItem.dispose();
			}
			
			var bounties:Vector.<BountyForLevel> = NewFreebieModel.instance.availableFreebies;
			bounties.sort(function (b1:BountyForLevel, b2:BountyForLevel):Number
			{
				if (b1.level < b2.level)
					return -1;
				else if (b1.level > b2.level)
					return 1;
					
				return 0;
			});
			
			var startX:int = 37;
			var startY:int = 270;
			
			var dX:int = 5;
			
			for (var j:int = 0; j < bounties.length; j++) 
			{
				currentItem = new NewFreebieRewardItem(bounties[j], ICON_NAMES[j]);
				currentItem.x = startX + ((currentItem.width + dX) * j);
				currentItem.y = startY;
				
				bodyContainer.addChild(currentItem);
				_rewardItems.push(currentItem);
			}
		}
		
		

		
		private function onShareButtonClick(e:MouseEvent):void 
		{
			close();
			
			if (App.social == "OK"){
				OKApi.showInviteCallback = showInviteCallback;
				ExternalApi.apiInviteEvent();
			}
			else if (App.social == "ML")
			{
				ExternalApi.apiInviteEvent({callback:showInviteCallback});
			}
			else if (App.social == "FB")
			{
				ExternalApi.apiInviteEvent();
			}
			else if (App.social == "VK")
			{
				ExternalApi.apiInviteEvent({callback:showInviteCallback});
			}
			else if (App.social == "FS")
			{
				ExternalApi.apiInviteEvent();
			}
			else if (App.social == "NK")
			{
				ExternalApi.apiInviteEvent({callback:showInviteCallback});
			}
			else{
				new AskWindow(AskWindow.MODE_NOTIFY_2,  { 
					title:Locale.__e('flash:1407159672690'), 
					inviteTxt:Locale.__e("flash:1407159700409"), 
					desc:Locale.__e("flash:1408542375687"),
					descY:30,
					height:530,
					itemsMode:GiftWindow.ALLFRIENDS
				},  function(uid:String):void {
						ExternalApi.notifyFriend({uid:uid, text:Locale.__e('flash:1458913795625'),callback:Post.statisticPost(Post.STATISTIC_INVITE)});
					} ).show();
			}
		}
		
		private function showInviteCallback(e:* = null):void {
			Log.alert('showInviteCallback');
			Log.alert(e.data);
			Log.alert(e);
			
			if (e.hasOwnProperty("status") && e.status == "opened")
				return;
				
			var friendID:String;
			if (App.social == "ML" && e && e is Array)
			{
				for each (friendID in e) 
				{
					Invites.postAboutInvite(friendID);
				}
			}
			else if (App.social == "FB" && e.to)
			{
				for each (friendID in e.to)
				{
					Invites.postAboutInvite(friendID);
				}
			}
			else
			{
				friendID = e.data;
				Invites.postAboutInvite(friendID);
			}
		}
		
		override public function dispose():void 
		{
			_shareButton.removeEventListener(MouseEvent.CLICK, onShareButtonClick);
			_helpBttn.removeEventListener(MouseEvent.CLICK, onHelpBttnClick);
			
			super.dispose();
		}	
	}
}