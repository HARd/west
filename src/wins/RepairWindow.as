package wins 
{
	import buttons.Button;
	import buttons.ImageButton;
	import buttons.MoneyButton;
	import core.Load;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import ui.UserInterface;
	import units.Boiler;
	import units.Tribute;
	
	public class RepairWindow extends Window
	{
		
		public var item:Object;
		
		public var bitmap:Bitmap;
		public var title:TextField;
		public var repairBttn:Button;
		
		private var buyBttn:MoneyButton;
		private var container:Sprite;
		private var items:Array = [];
		
		public function RepairWindow(settings:Object = null):void
		{
			if (settings == null) {
				settings = new Object();
			}
			
			settings['sID'] = settings.sID || 0;
			
			settings["width"] = 500;
			settings["height"] = 340;
			settings["popup"] = true;
			settings["fontSize"] = 36;
			settings["callback"] = settings["callback"] || null;
			
			settings["hasPaginator"] = false;
			
			super(settings);	
		}
		
		override public function drawBackground():void {
			var background:Bitmap = backing(settings.width, settings.height, 10, "windowBacking");
			layer.addChild(background);
		}
		
		override public function drawExit():void {
			super.drawExit();
			
			exit.x = settings.width - exit.width + 12;
			exit.y = -12;
		}
		
		override public function drawBody():void {
			
			titleLabel.y = -20;
			
			/*background = Window.backing(270, 220, 10, "itemBacking");
			bodyContainer.addChild(background);
			background.x = (settings.width - background.width)/2;
			background.y = 20;
			
			bitmap = new Bitmap(settings.target.bitmap.bitmapData);
			bitmap.scaleX = 0.7;
			bitmap.scaleY = 0.7;
			bitmap.smoothing = true;
			
			bitmap.x = (settings.width - bitmap.width) / 2;
			bitmap.y = 130 - bitmap.height/ 2;
			
			bodyContainer.addChild(bitmap);
			
			drawDescription();*/
			
			createItems();
			drawBttns();
			checkDevels();
		}
		
		public override function close(e:MouseEvent = null):void
		{
			if (settings.onClose) settings.onClose();
			super.close();
		}
		
		private function drawBttns():void
		{
			var develText:TextField = drawText(
				Locale.__e("flash:1382952380257"), 
				{
					fontSize	:24,
					color		:0xfcf5e5,
					borderColor	:0x604b22,
					autoSize	:"left"
				}
			)
				
			develText.x = settings['width'] / 2 - develText.width / 2;
			develText.y = 5;	
			bodyContainer.addChild(develText);
			
			
			repairBttn = new Button({
				caption		:Locale.__e("flash:1382952379934"),
				width		:160,
				height		:42,	
				fontSize	:23
			});
			
			repairBttn.x = (settings.width - repairBttn.width) / 2;
			repairBttn.y = 260;
			
			bodyContainer.addChild(repairBttn);
			repairBttn.addEventListener(MouseEvent.CLICK, onRepair)
		}
		
		private function onRepair(e:MouseEvent):void
		{
			if (e.currentTarget.mode == Button.DISABLED) return;
			settings.onRepair();
			close();
		}
		
		public function createItems():void{
			
			container = new Sprite();
			bodyContainer.addChild(container);
			
			var X:int = 0;
			var Y:int = 0;
			for (var sID:* in settings.price)
			{
				var count:uint = settings.price[sID];
				
				var item:MaterialItem = new MaterialItem({
					sID:sID,
					need:count,
					window:this,
					type:MaterialItem.IN
				});
				
				container.addChild(item);
				items.push(item);
				item.addEventListener(WindowEvent.ON_CONTENT_UPDATE, checkDevels);
				
				item.x = X;
				item.y = Y;
				
				X += item.width + 8;
				
				item.checkStatus();
			};
			var itemNum:int = 0;
			
			container.addChild(item);
			container.x = (settings.width - container.width)/2
			container.y = 30;
		}
		
		private function checkDevels(e:* = null):Boolean{
			
			var check:Boolean = true;
			
			for (var sID:* in settings.price)
			{
				var needBuyCount:int = 0;
				var count:int = settings.price[sID];
				
				var countOnStock:int = App.user.stock.count(sID);
				
				if (countOnStock < count)
				{
					check = false;
				}
			}
				
			if (check == true)
				repairBttn.state = Button.NORMAL;
			else
				repairBttn.state = Button.DISABLED;
				
			return check;
		}
		/*
		public function drawDescription():void {
			
			var text:String = Locale.__e("flash:1382952380258");
			
			if (settings.target is Boiler)
				text = Locale.__e("flash:1382952380259");
			
			var descriptionLabel:TextField = drawText(Locale.__e("flash:1382952380258"), {
				fontSize:24,
				autoSize:"left",
				textAlign:"center",
				color:0x5a524c,
				borderColor:0xfaf1df
			});
			descriptionLabel.x = (settings.width - descriptionLabel.width) / 2;
			descriptionLabel.y = 240;
						
			descriptionLabel.width = settings.width - 80;
			
			bodyContainer.addChild(descriptionLabel);
		}
		*/
		
		override public function dispose():void
		{
			super.dispose();
		}
	}		
}