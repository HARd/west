package wins 
{
	import buttons.Button;
	import buttons.HardButton;
	import core.Load;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import ui.UserInterface;
	import units.Techno;
	/**
	 * ...
	 * @author ...
	 */
	public class FurryWorkWindow extends Window
	{
		private var background:Bitmap;
		private var robotIcon:Bitmap;
		private var robotCounter:TextField;
		private var textSettings:Object;
		private var bitmap:Bitmap;
		private var background2:Bitmap;
		private var speedUp:HardButton;
		private var skipPrice:int;
		private var bgProgress:Bitmap;
		private var crafted:int;
		private var timeToFinish:int;
		public var simpleWindow:Boolean 		= true;
		public var choosingWindow:Boolean		= false;
		public var collectingWindow:Boolean 	= false;
		
		public function FurryWorkWindow(settings:Object = null) 
		{
			if (settings == null) {
				settings = new Object();
			}
			
			settings["width"] = 366;
			settings["height"] = 346;
			settings["title"] = Locale.__e("Местный раб");
			settings["fontSize"] = 150;
			settings["hasPaginator"] = false;
			
			super(settings);
		}
		
		override public function drawBackground():void 
		{
			background = backing(settings.width, settings.height+45, 20, "storageBackingMain");
			layer.addChildAt(background,0);
		}
	
		override public function drawBody():void 
		{
			titleLabel.y = 0;
			background2 = Window.backing(205, 178, 30, "storageDarkBackingSlim");

			background2.x = (settings.width/2 - background2.width / 2);
			background2.y = (settings.height/2 - background2.height / 2) + 20;
			layer.addChild(background2);
			
			drawMirrowObjs('diamonds', 24, settings.width - 24, 58, false, false, false,1,-1 );
			drawMirrowObjs('storageWoodenDec', 5, settings.width - 5, settings.height - 65);
			
			drawButtons();
			shopBusyFurry();
			drawItems();
			addProgressBar();
		}
		
		private var timer:TextField;
		private var progressBacking:Bitmap;
		private var progressBar:ProgressBar;
		private function addProgressBar():void 
		{
			var container:Sprite = new Sprite();
			
			progressBacking = Window.backingShort(settings.width - 80, "prograssBarBacking3");
			container.addChild(progressBacking);
			
			progressBar = new ProgressBar( { win:this, width:336, isTimer:false});
			progressBar.x = progressBacking.x - 2;
			progressBar.y = progressBacking.y - 2;
			
			container.addChild(progressBar);
			
			timer = Window.drawText(TimeConverter.timeToStr(127), {
				color:			0xffffff,
				borderColor:	0x875522,
				fontSize:		30
			});
			
			container.addChild(timer);
			
			timer.y = (progressBacking.height - timer.height)/2 + 4;
			timer.x = (progressBacking.width - timer.textWidth) / 2 + 5;
			timer.height = timer.textHeight;
			timer.width = timer.textWidth + 10;
			
			bodyContainer.addChild(container);
			container.x = (settings.width - container.width) / 2 + 20;
			container.y = 260;
			
			//progressBar.start();
			//progress();
			//App.self.setOnTimer(progress);
		}
		private var priceSpeed:int = 0;
		private var priceBttn:int = 0;
		private function progress():void 
		{
			//crafted = /*settings.target.crafted*/;
			var leftTime:int = crafted - App.time;
			
			if (leftTime <= 0) {
				leftTime = 0;
				App.self.setOffTimer(progress);
				close();
			}
			timer.text = TimeConverter.timeToStr(leftTime);
			progressBar.progress =  (timeToFinish - leftTime) / timeToFinish;
			priceSpeed = Math.ceil((crafted - App.time) / App.data.options['SpeedUpPrice']);
			if (speedUp && priceBttn != priceSpeed && priceSpeed != 0) {
				priceBttn = priceSpeed;
				speedUp.count = String(priceSpeed);
			}
		}
		
		public function drawItems():void
		{	
			bitmap = new Bitmap();
			settings.target;
			bitmap.bitmapData = settings.target.bitmap.bitmapData; //////////////////графика элемента, который Фури собирает
			bitmap.smoothing = true;
			bitmap.scaleX = bitmap.scaleY = 0.7;
			bitmap.x = (settings.width - bitmap.width) / 2;
			bitmap.y = 130 - bitmap.height / 2;
			bodyContainer.addChild(bitmap);			
		}
		
		private function drawButtons():void 
		{
			speedUp = new HardButton({ 
				caption:Locale.__e("flash:1382952380021"),
				width			:150,
				height			:63,	
				fontSize		:22,
				textLeading		: -5,
				countText		:skipPrice,
				multiline		:true,
				radius			:20,
				iconScale		:0.67,
				fontBorderColor :0x4d7d0e,
				fontCountBorder :0x4d7d0e
			});
			speedUp.count = String(skipPrice);	
			speedUp.x = settings.width/2 - speedUp.width/2;
			speedUp.y = settings.height - speedUp.height/2;
			speedUp.addEventListener(MouseEvent.CLICK, onSpeedUp);
			
			bodyContainer.addChild(speedUp);
		}
		
		private function onSpeedUp(e:MouseEvent):void 
		{
			//simpleWindow = true;
			//choosingWindow = false;
			//collectingWindow = false;
			////dispose();
			//clearWindow();
			//drawBody();
		}
		
		private function shopBusyFurry():void
		{
			textSettings = {
				color:0xFFFFFF,
				borderColor:0x4b2e1a,
				fontSize:32,
				textAlign:"center"
			};
			robotIcon = new Bitmap(UserInterface.textures.robotIcon);
			robotCounter = Window.drawText("-/-", textSettings);
			robotCounter.text 	=  Techno.getBusyTechno() + "/" + App.user.techno.length;
			
			layer.addChild(robotIcon);
			layer.addChild(robotCounter);
			
			
			robotIcon.x = settings.width/2 - 50;
			robotIcon.y = 55;
			
			robotCounter.x = robotIcon.x + robotIcon.width - 20;
			robotCounter.y = robotIcon.y + 7;
		}
		override public function drawExit():void {
			super.drawExit();
			exit.x = settings.width - exit.width;
			exit.y = 0;
		}
		
		public function clearWindow():void
		{
			speedUp.removeEventListener(MouseEvent.CLICK, onSpeedUp);
			layer.removeChild(background2);
			layer.removeChild(robotIcon);
			layer.removeChild(robotCounter);
			bodyContainer.removeChild(bitmap);
		}
		
		override public function dispose():void
		{
			super.dispose();
		}
	}

}