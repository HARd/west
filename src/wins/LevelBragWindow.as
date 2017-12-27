package wins 
{
	import buttons.Button;
	import core.AvaLoad;
	import core.WallPost;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import ui.UserInterface;
	/**
	 * ...
	 * @author ...
	 */
	public class LevelBragWindow extends Window
	{
		private static const MAX_SHOWED:int = 1;
		private static var countShoewd:int = 0;
		private static var counter:int = 0;
		
		private static var shoewd:Boolean = false;
		public static function init(indFriend:int):void
		{
			if (!shoewd && countShoewd < MAX_SHOWED && counter == 0) {
				var fr:Object = App.user.friends.bragFriends[indFriend];
				App.user.friends.bragFriends.splice(indFriend, 1);
				new LevelBragWindow( { friend:fr } ).show();
				countShoewd++;
			}
			
			counter++;
			
			if (counter >= MAX_SHOWED)
				counter = 0;
				
			if (countShoewd >= MAX_SHOWED) {
				App.user.friends.bragFriends = [];
			}
		}
		
		
		public var bragBttn:Button;
		
		public var friend:Object;
		
		public function LevelBragWindow(settings:Object) 
		{	
			settings["width"]			= 400;
			settings["height"] 			= 310;
			settings["hasPaginator"] 	= false;
			settings["hasTitle"] 		= false;
			settings["popup"] 			= true;
			settings["forcedClosing"] 	= true;
			settings['background']      = 'dialogueBacking';
			
			friend = settings.friend;
			
			super(settings);
			
			shoewd = true;
		}
		
		private var bgAva:Bitmap;
		private var bgAva2:Bitmap;
		private var avaCont:Sprite = new Sprite();
		private var avaCont2:Sprite = new Sprite();
		private var avatar:Bitmap = new Bitmap();
		private var avatar2:Bitmap = new Bitmap();
		private var preloader:Preloader = new Preloader();
		private var preloader2:Preloader = new Preloader();
		override public function drawBody():void
		{
			exit.y -= 28;
			exit.x += 12;
			
			var stripe:Bitmap = Window.backingShort(settings.width + 60, 'questRibbon');
			bodyContainer.addChild(stripe);
			stripe.x = (settings.width - stripe.width) / 2;
			stripe.y = 20;
			
			var separator:Bitmap = Window.backingShort(200, 'divider', false);
			bodyContainer.addChild(separator);
			separator.alpha = 0.8;
			separator.x = 30;
			separator.y = 156;
			
			var separator2:Bitmap = Window.backingShort(200, 'divider', false);
			bodyContainer.addChild(separator2);
			separator2.scaleX = -1;
			separator2.alpha = 0.8;
			separator2.x = 370;
			separator2.y = 156;
			
			bgAva = new Bitmap(Window.textures.referalRoundBacking);
			bgAva.scaleX = bgAva.scaleY = 0.65;
			bgAva.smoothing = true;
			bodyContainer.addChild(bgAva);
			bgAva.x = (settings.width - bgAva.width) / 2;
			bgAva.y = -14;
			
			bgAva2 = new Bitmap(Window.textures.referalRoundBacking);
			bgAva2.scaleX = bgAva2.scaleY = 0.5;
			bgAva2.smoothing = true;
			bodyContainer.addChild(bgAva2);
			bgAva2.x = (settings.width - bgAva2.width) / 2;
			bgAva2.y = 120;
			
			bodyContainer.addChild(avaCont); 
			bodyContainer.addChild(avaCont2);
			avaCont.addChild(avatar);
			avaCont2.addChild(avatar2);
			
			var crown:Bitmap = new Bitmap(Window.textures.crown);
			bodyContainer.addChild(crown);
			crown.x = (settings.width - crown.width) / 2;
			crown.y = bgAva.y - crown.height + 8;
			
			drawMirrowObjs('flowersDecor', 40, settings.width - 40, -8);
			
			drawAvatars();
			drawBttn();
			drawDesc();
		}
		
		private function drawAvatars():void 
		{
			bodyContainer.addChild(preloader);
			bodyContainer.addChild(preloader2);
			
			preloader.x = settings.width / 2;
			preloader.y = bgAva.y + bgAva.height / 2;
			preloader2.x = settings.width / 2;
			preloader2.y = bgAva2.y + bgAva2.height / 2;
			
			var star1:Bitmap = new Bitmap(UserInterface.textures.expIcon);
			star1.scaleX = star1.scaleY = 0.9;
			star1.smoothing = true;
			star1.x = bgAva.x + bgAva.width - star1.width / 2 - 7;
			star1.y = bgAva.y;
			bodyContainer.addChild(star1);
			
			
			var lvlTxt1:TextField =  Window.drawText(String(App.user.level), {
					color:0xfefdcf,
					fontSize:23,
					borderColor:0x6c330e,
					autoSize:"center",
					textAlign:"center"
				}
			);
			lvlTxt1.width = 90;
			lvlTxt1.x = star1.x +(star1.width - lvlTxt1.width) / 2 + 2;
			lvlTxt1.y = star1.y +(star1.height - lvlTxt1.textHeight) / 2;
			bodyContainer.addChild(lvlTxt1);
			
			var expTxt1:TextField =  Window.drawText(String(App.user.stock.count(Stock.EXP)), {
					color:0xfefdcf,
					fontSize:30,
					borderColor:0x5d0368,
					autoSize:"center",
					textAlign:"center"
				}
			);
			expTxt1.width = 140;
			expTxt1.x = bgAva.x +(bgAva.width - expTxt1.width) / 2;
			expTxt1.y = bgAva.y + bgAva.height - 16;
			bodyContainer.addChild(expTxt1);
			
			var star2:Bitmap = new Bitmap(UserInterface.textures.expIcon);
			star2.scaleX = star2.scaleY = 0.7;
			star2.smoothing = true;
			star2.x = bgAva2.x + bgAva2.width - star2.width / 2 - 5;
			star2.y = bgAva2.y;
			bodyContainer.addChild(star2);
			
			
			var lvlTxt2:TextField =  Window.drawText(String(friend.level), {
					color:0xfefdcf,
					fontSize:20,
					borderColor:0x6c330e,
					autoSize:"center",
					textAlign:"center"
				}
			);
			lvlTxt2.width = 90;
			lvlTxt2.x = star2.x +(star2.width - lvlTxt2.width) / 2 + 1;
			lvlTxt2.y = star2.y +(star2.height - lvlTxt2.textHeight) / 2;
			bodyContainer.addChild(lvlTxt2);
			
			var expTxt2:TextField =  Window.drawText(String(friend.exp), {
					color:0xfefdcf,
					fontSize:26,
					borderColor:0x5d0368,
					autoSize:"center",
					textAlign:"center"
				}
			);
			expTxt2.width = 140;
			expTxt2.x = bgAva2.x +(bgAva2.width - expTxt2.width) / 2;
			expTxt2.y = bgAva2.y + bgAva2.height - 14;
			bodyContainer.addChild(expTxt2);
			
			
			new AvaLoad(App.user.photo, onLoadUser);
			new AvaLoad(friend.photo, onLoadFriend);
		}
		
		private function onLoadUser(data:*):void 
		{
			bodyContainer.removeChild(preloader);
		
			avatar.bitmapData = data.bitmapData;
			avatar.smoothing = true;
			
			var shape:Shape = new Shape();
			shape.graphics.beginFill(0x000000, 1);
			shape.graphics.drawCircle(38, 38, 38);
			shape.graphics.endFill();
			avaCont.mask = shape;
			avaCont.addChild(shape);
			
			var scale:Number = 1.8;
			
			avatar.width *= scale;
			avatar.height *= scale;
			
			shape.x = (avatar.width - shape.width) / 2;
			shape.y = (avatar.height - shape.height) / 2;
			
			avaCont.x = bgAva.x + (bgAva.width - avaCont.width) / 2;
			avaCont.y = bgAva.y + (bgAva.height - avaCont.height) / 2;
		}
		
		private function onLoadFriend(data:*):void 
		{
			bodyContainer.removeChild(preloader2);
		
			avatar2.bitmapData = data.bitmapData;
			avatar2.smoothing = true;
			
			var shape:Shape = new Shape();
			shape.graphics.beginFill(0x000000, 1);
			shape.graphics.drawCircle(28, 28, 28);
			shape.graphics.endFill();
			avaCont2.mask = shape;
			avaCont2.addChild(shape);
			
			var scale:Number = 1.3;
			
			avatar2.width *= scale;
			avatar2.height *= scale;
			
			shape.x = (avatar2.width - shape.width) / 2;
			shape.y = (avatar2.height - shape.height) / 2;
			
			avaCont2.x = bgAva2.x + (bgAva2.width - avaCont2.width) / 2;
			avaCont2.y = bgAva2.y + (bgAva2.height - avaCont2.height) / 2;
		}
		
		private function drawBttn():void 
		{
			bragBttn = new Button({
				caption:Locale.__e("flash:1406705225306"),
				width:190,					
				height:52,	
				fontSize:32
			});
			
			bodyContainer.addChild(bragBttn);
			bragBttn.x = (settings.width - bragBttn.width) / 2;
			bragBttn.y = settings.height - bragBttn.height + 16;
			
			bragBttn.addEventListener(MouseEvent.CLICK, onBrag);
		}
		
		private function drawDesc():void 
		{
			var desc:TextField =  Window.drawText(Locale.__e("flash:1406711374783", [friend.first_name]), {
					color:0x624512,
					fontSize:26,
					borderColor:0xffe8b9,
					autoSize:"center",
					textAlign:"center",
					multiline:true,
					wrap:true
				}
			);
			desc.width = settings.width - 60;
			desc.x = (settings.width - desc.width) / 2;
			desc.y = 210;
			bodyContainer.addChild(desc);
		}
		
		private function onBrag(e:MouseEvent):void 
		{
			WallPost.makePost(WallPost.FRIEND_BRAG, {uid:friend.uid});
			
			close();
		}
		
		override public function dispose():void
		{
			shoewd = false;
			if(bragBttn){
				bragBttn.removeEventListener(MouseEvent.CLICK, onBrag);
				bragBttn.dispose();
			}
			bragBttn = null;
			
			super.dispose();
		}
		
	}

}