package wins 
{
	import api.ExternalApi;
	import buttons.Button;
	import buttons.MenuButton;
	import buttons.MoneyButton;
	import com.adobe.images.BitString;
	import core.Load;
	import core.Post;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import units.Hut;

	public class FreechoiseWindow extends Window
	{
		public var items:Array = new Array();
		public var back_3:Bitmap;
		public var bttn1:Button;
		public var bttn2:Button;
		private var axe1:int = 0;
		private var axe2:int = 0;
		private var WIDTH:uint;
		private var back_1:Bitmap;
		private var back_2:Bitmap;
		public var descriptionLabel1:TextField;
		public var descriptionLabel2:TextField;
		public var mode:uint = 0;
		public var sID:uint = 0;
		public var bitmap1:Bitmap;
		public var bitmap2:Bitmap;
	
		public function FreechoiseWindow(settings:Object = null) 
		{
			if (settings == null) {
				settings = new Object();
			}
			
			settings['width'] = 403;
			settings['height'] = 551;
			settings['title'] = Locale.__e('flash:1382952380285');
			settings['hasPaginator'] = false;
			settings['hasButtons'] = false;
			settings['freebieID'] = settings['freebieID'] || 0;
			
			super(settings);
		}
		
		
		override public function drawTitle():void {
			
			//var glowing:Bitmap = new Bitmap(Window.textures.actionGlow);
			//glowing.alpha = 0.8;
			//glowing.width = settings.width - 100;;
			//glowing.height = 180;
			//glowing.smoothing = true;
			//glowing.y = - glowing.height / 4 - 30;
			//glowing.x = (settings.width - glowing.width)/2;
			//headerContainer.addChild(glowing);
			super.drawTitle();
		}
		
		override public function drawBody():void {
			
			exit.y -= 10;
			exit.x += 40;
				
			drawBttns();
			
			
			Load.loading(Config.getImage('promo/images', 'treasures'), function(data:Bitmap):void {
				bitmap1 = new Bitmap(data.bitmapData);
				bodyContainer.addChild(bitmap1);
				bitmap1.scaleX = bitmap1.scaleY = 0.6;
				bitmap1.smoothing = true;
				bitmap1.x = axe1 - bitmap1.width/2;
				bitmap1.y = back_1.y - 110;
			});
			
			Load.loading(Config.getImage('promo/images', 'crystals'), function(data:Bitmap):void {
				bitmap2 = new Bitmap(data.bitmapData);
				bodyContainer.addChild(bitmap2);
				bitmap2.scaleX = bitmap2.scaleY = 0.9;
				bitmap2.smoothing = true;
				bitmap2.x = axe2 - bitmap2.width/2;
				bitmap2.y = back_2.y - 80;
			});
		}
		
		public function drawBttns():void {
			bttn1 = new Button( {
				caption:Locale.__e("flash:1383038713097"),
				fontSize:25,
				width:180,
				height:50
			});
			
			bodyContainer.addChild(bttn1);
			bttn1.x = axe1 - bttn1.width/2;
			bttn1.y = 150;
			
			bttn1.addEventListener(MouseEvent.CLICK, onClick1);
			
			bttn2 = new Button( {
				caption:Locale.__e("flash:1383038730757"),
				fontSize:25,
				width:180,
				height:50
			});
			
			bodyContainer.addChild(bttn2);
			bttn2.x = axe2 - bttn2.width/2;
			bttn2.y = 150;
			
			bttn2.addEventListener(MouseEvent.CLICK, onClick2);
		}
		
		public function onClick1(e:MouseEvent):void {
			if (e.currentTarget.mode == Button.DISABLED) return;
			close();
			ExternalApi.openLeads();
		}
		
		public function onClick2(e:MouseEvent):void {
			if (e.currentTarget.mode == Button.DISABLED) return;
			close();
			new FreebieWindow( { ID:settings.freebieID} ).show();
		}
		
		
		override public function drawBackground():void
		{
			
			var backing:Bitmap = Window.backing(settings.width, settings.height, 50, 'windowBacking');
			layer.addChild(backing);
			backing.y = 40;
			
			WIDTH = (backing.width - 75)/2;
			
			back_1 = Window.backing(WIDTH, 200, 10, "itemBacking");
			back_2 = Window.backing(WIDTH, 200, 10, "itemBacking");
			layer.addChild(back_1);
			layer.addChild(back_2);
			
			back_1.x = backing.x + 25;
			back_1.y = backing.y + 50;
			axe1 = back_1.x + back_1.width / 2;
			
			back_2.x = back_1.x + WIDTH + 25;
			back_2.y = back_1.y;
			axe2 = back_2.x + back_2.width / 2;
		}
		
		public override function dispose():void
		{
			super.dispose();
		}
	}
}