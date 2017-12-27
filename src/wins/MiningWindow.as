package wins 
{
	import core.Load;
	import flash.display.Bitmap;
	/**
	 * ...
	 * @author ...
	 */
	public class MiningWindow extends Window
	{
		private var preloader:Preloader = new Preloader();
		public var bitmap:Bitmap = null;
		public var sprTip:LayerX = new LayerX();
		
		public function MiningWindow(settings:Object = null)
		{
			if (settings == null) {
				settings = new Object();
			}
			
			settings["find"] = settings.find || null;
			settings['fontSize'] = 36;
			settings["title"] = App.data.storage[162].title;
			
			settings["width"] = 366;
			settings["height"] = 402;
			
			settings['hasPaginator'] = false;
			settings["returnCursor"] = false;
			
			super(settings);
			
			bitmap = new Bitmap();
			sprTip.addChild(bitmap);
			addChild(sprTip);
			
			addChild(preloader);
			preloader.x = (settings.width)/ 2;
			preloader.y = (settings.height)/ 2 - 5;
			
			//Load.loading(Config.getIcon(App.data.storage[sID].type, App.data.storage[sID].preview), onIconComplete);
		}
		
		private function onIconComplete(obj:Object):void 
		{
			if(contains(preloader)){
				removeChild(preloader);
			}
			bitmap.bitmapData = obj.bitmapData;
			bitmap.smoothing = true;
			if(bitmap.height > 100)
				bitmap.scaleX = bitmap.scaleY = 0.8;
			sprTip.x = (settings.width - bitmap.width) / 2;
			sprTip.y = (settings.height - bitmap.height) / 2 - 15;
		}
		
		override public function drawBackground():void 
		{
			var background:Bitmap = backing2(settings.width, settings.height, 40, "questsSmallBackingTopPiece", "questsSmallBackingBottomPiece");
			layer.addChild(background);
		}
		
		override public function drawBody():void {
			
			exit.y -= 15;
			titleLabel.y -= 4;
			
			drawBack();
			
		}
		
		public function drawBttns():void
		{
			
		}
		
		public function drawProgress():void
		{
			
		}
		
		public function drawBack():void
		{
			var bgItem:Bitmap = backing(296, 260, 50, "itemBacking");
			bgItem.x = (settings.width - bgItem.width) / 2;
			bgItem.y = 2;
			bodyContainer.addChildAt(bgItem, 0);
		}
		
	}

}