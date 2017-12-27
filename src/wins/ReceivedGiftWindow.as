package wins 
{
	import buttons.Button;
	import core.Load;
	import core.Numbers;
	import flash.display.Bitmap;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import ui.UserInterface;
	public class ReceivedGiftWindow extends Window 
	{
		private var bttnTake:Button;
		private var preloader:Preloader = new Preloader();
		public function ReceivedGiftWindow(settings:Object=null) 
		{
			if (settings == null) {
				settings = new Object();
			}
			
			settings['width'] 			= 465;
			settings['height'] 			= 390;
			settings['title'] 			= Locale.__e('flash:1406796969703');
			settings['hasPaginator'] 	= false;
			settings['hasButtons']		= false;
			settings['gift']			= settings.gift;
			
			super(settings);
		}
		
		private var pic:Bitmap;
		override public function drawBackground():void {
			
			var background:Bitmap = backing(settings.width, settings.height, 35, "alertBacking");
			bodyContainer.addChild(background);
			
			pic = new Bitmap(Window.textures.giftWinPic);
			pic.smoothing = true;
			pic.x = (settings.width - pic.width) / 2;
			pic.y -= 250;
			bodyContainer.addChild(pic);
			
			exit.visible = false;
		}
		
		override public function drawTitle():void {
			titleLabel = titleText( {
				title				: settings.title,
				color				: 0xffffff,
				multiline			: settings.multiline,			
				fontSize			: 40,
				textLeading	 		: settings.textLeading,	
				border				: true,
				borderColor 		: 0xc4964e,			
				borderSize 			: 4,	
				shadowColor			: 0x503f33,
				shadowSize			: 4,
				width				: settings.width - 70,
				textAlign			: 'center',
				sharpness 			: 50,
				thickness			: 50
			});
			titleLabel.x = (settings.width - titleLabel.width) / 2;
			titleLabel.y = - titleLabel.height / 2 + 65;
			titleLabel.mouseChildren = titleLabel.mouseEnabled = false;
			
			headerContainer.addChild(titleLabel);
		}
		
		override public function drawBody():void {
			var friend:FriendItem = new FriendItem( { uid:settings.gift.from } );
			friend.x = 80;
			friend.y = 90;
			bodyContainer.addChild(friend);
			
			var desc:TextField = drawText(Locale.__e('flash:1446050229008'), {
				color:		0xffe342,
				borderColor:0x4a2e18,
				fontSize:	22,
				textAlign:	'center'
			});
			desc.width = desc.textWidth + 5;
			desc.x = friend.x + friend.width + 25;
			desc.y = friend.y + 15;
			bodyContainer.addChild(desc);
			
			var friendData:Object =  App.user.friends.data[settings.gift.from];
			var first_Name:String = '';
			var last_Name:String = '';
			if (friendData.first_name && friendData.first_name.length > 0)
				first_Name = friendData.first_name;
			else if (friendData.aka && friendData.aka.length > 0) {
				first_Name = friendData.aka;
			}
			if (friendData.last_name && friendData.last_name.length > 0)
				last_Name = friendData.last_name;			
			
			if (first_Name.indexOf(' ') > 0) first_Name = first_Name.substring(0, first_Name.indexOf(' '));
			if (last_Name.indexOf(' ') > 0) last_Name = last_Name.substring(0, last_Name.indexOf(' '));
			
			var name:TextField = drawText(first_Name + ' ' + last_Name, {
				color:		0xffe342,
				borderColor:0x4a2e18,
				fontSize:	22,
				textAlign:	'center'
			});
			name.width = name.textWidth + 5;
			name.x = desc.x + (desc.width - name.width) / 2;
			name.y = desc.y + 30;
			bodyContainer.addChild(name);
			
			drawSet();
			
			bttnTake = new Button( {
				fontSize:	32,
				width:		186,
				height:		50,
				caption:	Locale.__e('flash:1404394519330')
			});
			bttnTake.x = (settings.width - bttnTake.width) / 2;
			bttnTake.y = settings.height - bttnTake.height - 10;
			bodyContainer.addChild(bttnTake);
			bttnTake.addEventListener(MouseEvent.CLICK, onTake);
		}
		
		private function drawSet():void {
			var sprite:LayerX = new LayerX();
			sprite.x = 100;
			sprite.y = 200;
			bodyContainer.addChild(sprite);
			
			var bitmap:Bitmap = new Bitmap();
			sprite.addChild(bitmap);
			
			preloader.x = 50;
			preloader.y = 50;
			sprite.addChild(preloader);
			
			var item:Object = App.data.storage[settings.gift.sID];
			Load.loading(Config.getIcon(item.type, item.view), function(data:*):void {
				if (preloader) sprite.removeChild(preloader);
				bitmap.bitmapData = data.bitmapData;
			});
			
			for (var bonus:String in item.price) {
				switch(int(bonus)) {
					case Stock.FANT:
						var pic:Bitmap = new Bitmap();
						pic.bitmapData = UserInterface.textures.fantsIcon;
						pic.smoothing = true;
						pic.scaleX = pic.scaleY = 0.7;
						pic.x = preloader.x + preloader.width + 20;
						pic.y = 20;
						sprite.addChild(pic);
						
						var bonusText:TextField;
						bonusText = Window.drawText(Numbers.moneyFormat(item.price[bonus]), {
							color:		0xb7eb87,
							borderColor:0x426b0f,
							fontSize:	24,
							textAlign:	'left'
						});
						bonusText.x = pic.x + pic.width + 10;
						bonusText.y = pic.y;
						sprite.addChild(bonusText);
						break;
					case Stock.FANTASY:
						var bonusText2:TextField;
						bonusText2 = Window.drawText('+' + Numbers.moneyFormat(item.price[bonus]), {
							color:		0xffffff,
							borderColor:0x3553c3,
							fontSize:	24,
							textAlign:	'left'
						});
						bonusText2.x = preloader.x + preloader.width + 20;
						bonusText2.y = 80;
						sprite.addChild(bonusText2);
						
						var pic2:Bitmap = new Bitmap();
						pic2.bitmapData = UserInterface.textures.energyIcon;
						pic2.smoothing = true;
						pic2.scaleX = pic2.scaleY = 0.7;
						pic2.x = bonusText2.x + bonusText2.textWidth + 10;
						pic2.y = bonusText2.y;
						sprite.addChild(pic2);
						break;
					case Stock.COINS:
						var pic3:Bitmap = new Bitmap();
						pic3.bitmapData = UserInterface.textures.coinsIcon;
						pic3.smoothing = true;
						pic3.scaleX = pic3.scaleY = 0.7;
						pic3.x = preloader.x + preloader.width + 20;
						pic3.y = 50;
						sprite.addChild(pic3);
						
						var bonusText3:TextField;
						bonusText3 = Window.drawText(Numbers.moneyFormat(item.price[bonus]), {
							color:		0xfede3b,
							borderColor:0x874509,
							fontSize:	24,
							textAlign:	'left'
						});
						bonusText3.x = pic3.x + pic3.width + 10;
						bonusText3.y = pic3.y;
						sprite.addChild(bonusText3);
						break;
				}
			}
		}
		
		private function onTake(e:MouseEvent = null):void {
			var targetPoint:Point = Window.localToGlobal(e.currentTarget);
			Gifts.take(settings.gift.gID, function(block:Boolean, data:Object = null):void 
			{				
				for (var sID:* in data) {
					//App.user.stock.add(sID, data[sID]);
					
					if (sID == Stock.FANT || sID == Stock.COINS || sID == Stock.FANTASY) {
						var item:*;
						item = new BonusItem(sID, data[sID]);
						item.cashMove(targetPoint, App.self.windowContainer)
					}
				}
			});
			
			close();
		}
		
		override public function dispose():void {
			bttnTake.removeEventListener(MouseEvent.CLICK, onTake);
			super.dispose();
		}
	}

}


import core.AvaLoad;
import core.Load;
import flash.display.Bitmap;
import flash.display.Shape;
import flash.display.Sprite;
import flash.text.TextField;
import wins.Window;
internal class FriendItem extends Sprite
{
	public var bg:Bitmap;
	public var friend:Object;
	
	private var title:TextField;
	private var sprite:LayerX = new LayerX();
	private var avatar:Bitmap = new Bitmap();
	
	public function FriendItem(data:Object)
	{
		this.friend = App.user.friends.data[data.uid];
		bg = new Bitmap(Window.textures.friendSlot);
		addChild(bg);
		addChild(sprite);
		sprite.addChild(avatar);
		
		var first_Name:String = '';
		if (friend.first_name && friend.first_name.length > 0)
			first_Name = friend.first_name;
		else if (friend.aka && friend.aka.length > 0) {
			first_Name = friend.aka;
		}
		
		if (first_Name.indexOf(' ') > 0) first_Name = first_Name.substring(0, first_Name.indexOf(' '));
		
		title = Window.drawText(first_Name, {
			fontSize:23,
			color:0xffffff,
			borderColor:0x4b2e1a,
			textAlign:"center",
			fontBorderSize:1,
			shadowColor:0x4b2e1a,
			shadowSize:1
		});
		addChild(title);		
		title.width = bg.width;
		title.height = title.textHeight;
		title.x = 0;
		title.y = -6;
		
		new AvaLoad(friend.photo, onLoad);
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
}