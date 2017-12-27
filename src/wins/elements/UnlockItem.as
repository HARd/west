package wins.elements 
{
	/**
	 * ...
	 * @author 
	 */
	import buttons.Button;
	import buttons.ImageButton;
	import buttons.MoneyButton;
	import core.Load;
	import flash.display.Bitmap;
	import flash.filters.GlowFilter;
	import ui.UserInterface;
	import wins.MaterialItem;
	import wins.Window;

	public class UnlockItem extends MaterialItem
	{
		private var settings:Object;
		
		public function UnlockItem(settings:Object){
			
			this.settings = settings;
			super(settings);
			//bitmapDY = 20;
			background = Window.backing(150, 190, 10, "itemBacking");
			addChild(background);
			
			drawBitmap();
			drawTitle(settings.title);
			
			drawCount();
			count = settings['count'] || 0;
		}
		
		private function drawTitle(text:String):void
		{
			title = Window.drawText(text, {
				color:0x6d4b15,
				borderColor:0xfcf6e4,
				textAlign:"center",
				autoSize:"center",
				fontSize:22,
				multiline:true
			});
			
			title.wordWrap = true;
			title.width = background.width - 50;
			title.y = 10;
			title.x = 25;
			addChild(title);
		}
		
		override public function drawBitmap():void
		{
			sprTip.tip = function():Object {
				return {
					title: settings.title,
					text: settings.description
				};
			}
			
			bitmap = new Bitmap();
			sprTip.addChild(bitmap);
			addChild(sprTip);
			
			addChild(preloader);
			preloader.x = (background.width) / 2;
			preloader.y = (background.height) / 2;
			
			Load.loading(settings.iconUrl, onPreviewComplete);
		} 
		
		override public function checkStatus():void
		{
			status = MaterialItem.UNREADY;
			if(type == MaterialItem.IN){
				if (count >= need)
				{
					changeOnREADY()
				}
				else
				{
					changeOnUNREADY()
				}
			}
		}
		
		override public function changeOnREADY():void
		{
			status = MaterialItem.READY
			setText("count", count);
			
			var filter:GlowFilter = new GlowFilter(0x6d4b15, 1, 4, 4, 10, 1);
			count_txt.filters 	= [filter];
			vs_txt.filters 		= [filter];
			need_txt.filters 	= [filter];
			
			count_txt.textColor = 0xffdc39
			vs_txt.textColor 	= 0xffdc39
			need_txt.textColor 	= 0xffdc39
			
			countContainer.y = 150 - 4
		}
		
		override public function changeOnUNREADY():void
		{
			setText("count", count);
			
			status = MaterialItem.UNREADY;
						
			countContainer.y = 150 - 4
			var filter:GlowFilter = new GlowFilter(0x8c2a24, 1, 4, 4, 10, 1);
			
			count_txt.filters 	= [filter];
			vs_txt.filters 		= [filter];
			need_txt.filters 	= [filter];
			
			count_txt.textColor = 0xee9177;
			vs_txt.textColor 	= 0xee9177;
			need_txt.textColor 	= 0xee9177;
			
		}
	}
}