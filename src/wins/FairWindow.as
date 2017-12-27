package wins 
{
	import buttons.UpgradeButton;
	import flash.display.Bitmap;
	
	public class FairWindow extends Window 
	{
		
		private var storageBttn:UpgradeButton;
		
		public function FairWindow(settings:Object=null) 
		{
			
			settings['background'] = settings['background'] || '';
			
			super(settings);
			
			
			
		}
		
		override public function drawBody():void {
			
			var back:Bitmap = backing2(settings.width, settings.height, 40, "questsSmallBackingTopPiece", "questsSmallBackingBottomPiece");
			bodyContainer.addChild(back);
			
			
			
		}
		
	}

}