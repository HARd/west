package wins.elements 
{
	import core.AvaLoad;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.text.TextField;
	import ui.UserInterface;
	import wins.Window;

	public class FriendItem extends Sprite 
	{
		public var bg:Bitmap;
		public var friend:Object;
		public var mode:int;	
		
		private var title:TextField;
		private var sprite:Sprite = new Sprite();
		private var avatar:Bitmap = new Bitmap();
		private var data:Object;
		private var callBack:Function;
		
		public function FriendItem(data:Object )
		{
			this.data = data;
			this.friend = App.user.friends.data[data.uid];
			bg = new Bitmap(UserInterface.textures.friendSlot);
			addChild(bg);
			bg.width = 72;
			bg.height = 77;
			bg.smoothing = true;
			addChild(sprite);
			sprite.addChild(avatar);		
			
			if (friend.first_name != null || friend.aka != null || friend.photo != null) {
				drawAvatar();
			}else {
				App.self.setOnTimer(checkOnLoad);
			}
			
			var txtBttn:String;
		}
		
		public function getHeight():int {
			return this.height;
		}
		
		private function drawAvatar():void 
		{
			var nmTxt:String = (friend.first_name)?friend.first_name:(friend.aka)?friend.aka:"undefined";
			title = Window.drawText(nmTxt.substr(0,15), App.self.userNameSettings({
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
		
		private function checkOnLoad():void 
		{
			if (friend && friend.first_name != null) {
				App.self.setOffTimer(checkOnLoad);
				drawAvatar();
			}
		}
		
		public function get itemRect():Object
		{
			return {width:70,height:80};
		}
		
		public function set state(value:int):void 
		{
			
		}
		
		private function onLoad(data:*):void 
		{		
			var shape:Shape = new Shape();
			shape.graphics.beginFill(0x000000, 1);
			shape.graphics.drawRoundRect(0, 0, 72, 77, 12, 12);
			shape.graphics.endFill();
			sprite.mask = shape;
			sprite.addChild(shape);
			var avW:int = shape.width - 20;
			var avH:int = shape.height - 20;
			var scale_x:Number = avW / data.bitmapData.width;
			var scale_y:Number = avH / data.bitmapData.height;
			var matrix:Matrix = new Matrix();
			matrix.scale(scale_x, scale_y);
			var smallBMD:BitmapData = new BitmapData(avW , avH , true, 0x000000);
			smallBMD.draw(data.bitmapData, matrix, null, null, null, true);
			avatar.bitmapData = smallBMD;
			avatar.x = (shape.width - avatar.width) / 2;
			avatar.y = (shape.height - avatar.height) / 2;
			avatar.smoothing = true;
			
		}
		
		public function dispose():void
		{
			callBack = null;
			App.self.setOffTimer(checkOnLoad);
		}
	}

}