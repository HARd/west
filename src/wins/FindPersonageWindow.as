package wins 
{
	import buttons.Button;
	import flash.display.Bitmap;
	import flash.events.MouseEvent;
	/**
	 * ...
	 * @author 
	 */
	public class FindPersonageWindow extends Window
	{
		private var travelBttn:Button;
		
		public function FindPersonageWindow(settings:Object = null) 
		{
			settings["width"] = 404;
			settings["height"] = 260;
			settings["fontSize"] = 38,	
			settings["hasPaginator"] = false;
			
			super(settings);	
		}
		
		override public function drawBackground():void {
			var background:Bitmap = backing2(settings.width, settings.height, 40, "questsSmallBackingTopPiece", "questsSmallBackingBottomPiece");
			layer.addChild(background);
		}
		
		override public function drawExit():void {
			super.drawExit();
			
			exit.x = settings.width - exit.width + 12;
			exit.y = -12;
		}
		
		override public function drawBody():void 
		{
			titleLabel.y += 4;
			
			
			var background:Bitmap = Window.backing(settings.width - 22, settings.height - 13, 10, "questsMainBacking2");
			bodyContainer.addChild(background);
			background.x = (settings.width - background.width)/2;
			background.y = -23;
			
			var bitmap:Bitmap = new Bitmap(settings.target.bitmap.bitmapData);
			bodyContainer.addChild(bitmap);
			bitmap.scaleX = bitmap.scaleY = 0.9;
			bitmap.smoothing = true;
			bitmap.x = (settings.width - bitmap.width) / 2;
			bitmap.y = 30 - bitmap.height;
			
			
			//drawMirrowObjs('separator2', 150, 255, 34, true, true, false, 0.5);
			
			drawMirrowObjs('diamondsTop', settings.width / 2 - settings.titleWidth / 2 - 5, settings.width / 2 + settings.titleWidth / 2 + 5, -40, true, true);
			drawMirrowObjs('diamonds', -27, settings.width + 24, settings.height - 110);
			
			
			
			travelBttn = new Button( {
				caption:Locale.__e("flash:1393584440735"),
				fontSize:24,
				width:190,
				hasDotes:false,
				height:50
			});
			
			bodyContainer.addChild(travelBttn);
			travelBttn.x = (settings.width - travelBttn.width)/2;
			travelBttn.y = settings.height - travelBttn.height - 20;
			
			travelBttn.addEventListener(MouseEvent.CLICK, onTravel);
			
		}
	
		override public function dispose():void
		{
			if(travelBttn)travelBttn.removeEventListener(MouseEvent.CLICK, onTravel);
			travelBttn = null;
		
			super.dispose();
		}
		
		private function onTravel(e:MouseEvent):void 
		{
			
		}
		
	}

}