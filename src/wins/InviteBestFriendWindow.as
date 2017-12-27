package wins 
{
	import buttons.Button;
	import core.AvaLoad;
	import core.Post;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	/**
	 * ...
	 * @author ...
	 */
	public class InviteBestFriendWindow extends Window 
	{
		private  var fid:String;
		private var avatar:Bitmap;
		private var upperPart:Bitmap;
		public function InviteBestFriendWindow(_fid:String,settings:Object=null) 
		{
			if (settings == null) {
				settings = new Object();
			}
			fid = _fid;
			settings['width'] = 445;
			settings['height'] = 165;
			settings['fontSize'] = 40;
			settings['fontColor'] = 0xffffff;
			settings['fontBorderColor'] = 0x5a2a79;
			settings['shadowBorderColor'] = 0xad52e2;
			
			settings['title'] = Locale.__e("flash:1406562866197");
			settings['hasPaginator'] = false;
			settings['hasButtons'] = false;
			super(settings);
			
		}
		
		override public function drawExit():void {
		}
		override public function drawTitle():void {
		}
		
		override public function drawBackground():void 
		{
			var background:Bitmap = backing(settings.width, settings.height, 45, "dialogueBacking");
			background.y += 40;
			layer.addChild(background);
		}
		
		override public function drawBody():void 
		{
			upperPart = new Bitmap(Window.textures.inviteFriend);
			upperPart.x = (settings.width - upperPart.width) / 2;
			upperPart.y = (settings.height - upperPart.height) / 2 - 100;
			bodyContainer.addChild(upperPart);
			
			var titleContainer:Sprite = new Sprite();
			var titleText:TextField = Window.drawText(Locale.__e('flash:1406562866197'), {
				color		:0xffffff,
				borderColor	:0x602d81,
				textAlign	:"center",
				autoSize	:"center",
				fontSize	:34
			});
				titleContainer.addChild(titleText);
				titleText.x = upperPart.x + (upperPart.width - titleText.width) / 2;
				titleText.y = upperPart.y + (upperPart.height - titleText.height) / 2 + 35;
				titleContainer.filters = [new GlowFilter(0xad52e2, 1, 4, 4, 8, 1)];
			bodyContainer.addChild(titleContainer);
			
			var descLabel:TextField = Window.drawText(Locale.__e('flash:1406620157485', [App.user.friends.data[fid].first_name]), {
				color		:0x624512,
				borderColor	:0x602d81,
				borderSize	:0,
				textAlign	:"center",
				autoSize	:"center",
				fontSize	:28,
				textLeading	: -6,
				width		:280,
				wrap		:true,
				multiline	:true
			});
			bodyContainer.addChild(descLabel);
			descLabel.x = (settings.width - descLabel.width) / 2;
			descLabel.y = (settings.height - descLabel.height) / 2 + 25;
			
			
			drawButtons();
			initAvatar(fid);
		}
		
		private function drawButtons():void
		{
			var buttonContainer:Sprite = new Sprite();
			var acceptButton:Button  = new Button( {
					bevelColor		:[0xfeee7b, 0xbf7e1a],
					bgColor			:[0xf5d058, 0xeeb331],
					fontColor		:0xffffff,
					fontBorderColor	:0x814f31,
					fontBorderSize	:3,
					width			:160,
					height			:45,
					fontSize		:26,
					caption			:Locale.__e("flash:1406618759807")
				});				
				buttonContainer.addChild(acceptButton);
				
			var declineButton:Button  = new Button( {
					bevelColor		:[0xffc8a8, 0xd04b27],
					bgColor			:[0xffcbae, 0xf55e43],
					fontColor		:0xffffff,
					fontBorderColor	:0x814f31,
					fontBorderSize	:3,
					width			:160,
					height			:45,
					fontSize		:26,
					caption			:Locale.__e("flash:1406618787023")
				});	
				declineButton.x = acceptButton.x + acceptButton.width + 17;
				buttonContainer.addChild(declineButton);
			
			buttonContainer.x = (settings.width - buttonContainer.width) / 2;
			buttonContainer.y = (settings.height - buttonContainer.height) / 2 + 100;
			bodyContainer.addChild(buttonContainer);
			
			
			acceptButton.addEventListener(MouseEvent.CLICK, onAccept);
			declineButton.addEventListener(MouseEvent.CLICK, onDecline);
		}
		
		private function initAvatar(fid:String):void
		{
			avatar = new Bitmap();
			bodyContainer.addChild(avatar);
			App.self.setOnTimer(checkOnLoad);
		}
		
		private function checkOnLoad():void 
		{	
			if (fid != null) {
				if (App.user.friends.data[fid].hasOwnProperty('first_name'))
				{
					App.self.setOffTimer(checkOnLoad);
					drawAvatar();
				}
			}
			
		}
	
		private function drawAvatar():void
		{
			var sender:Object = App.user.friends.data[fid];
			new AvaLoad(App.user.friends.data[fid].photo, onAvaLoad);
		}
		
		private function onAvaLoad(data:Bitmap):void
		{
			var mask:Sprite = new Sprite();
			mask.graphics.beginFill(0x000000, 1);
			mask.graphics.drawCircle(0, 0, 50);
			mask.graphics.endFill();
			mask.x = 30;
			mask.y = 10;
			mask.x = upperPart.x + (upperPart.width - mask.width) / 2 + 50;
			mask.y = upperPart.y + (upperPart.height - mask.height) / 2;
			
			avatar.scaleX = avatar.scaleY = 2;
			avatar.bitmapData = data.bitmapData;
			avatar.smoothing = true;
			avatar.x = mask.x + (mask.width - avatar.width) / 2 - 50;
			avatar.y = mask.y + (mask.height - avatar.height) / 2 - 50;
				
			bodyContainer.addChild(mask);
			avatar.mask = mask;
		}
		private function onAccept(e:MouseEvent):void 
		{
			Post.send( {
					ctr:'bestfriends',
					act:'accept',
					uID:App.user.id,
					fID:fid
				}, onAcceptBestFriend);
		}
		
		private function onAcceptBestFriend(error:*, result:*, params:Object):void
		{
			if (error) {
				Errors.show(error, result);
				return;
			}
			close();
		}
		
		private function onDecline(e:MouseEvent):void 
		{
			Post.send( {
					ctr:'bestfriends',
					act:'reject',
					uID:App.user.id,
					fID:fid
				}, onDeclineBestFriend);
			close();
		}
		
		private function onDeclineBestFriend(error:*, result:*, params:Object):void
		{
			if (error) {
				Errors.show(error, result);
				return;
			}
			
		}
		
	}

}