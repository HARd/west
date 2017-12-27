package wins.actions 
{
	import api.ExternalApi;
	import buttons.Button;
	import buttons.MenuButton;
	import buttons.MoneyButton;
	import core.Load;
	import core.Post;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.text.TextField;
	import ui.UserInterface;
	import units.Hut;
	import wins.Window;
	
	public class ZoneSaleWindow extends SaleLimitWindow
	{
		
		private var item:Object;
		public function ZoneSaleWindow(settings:Object = null)
		{
			if (settings == null) {
				settings = new Object();
			}
			
			item = App.data.actions[settings.pID];
			for (var _sid:* in item.items) {
				settings['title'] = App.data.storage[_sid].title;
				break;
			}
			settings['width'] = 445;
			settings['height'] = 400;
			
			super(settings);
		}
		
		override public function drawBody():void 
		{
			titleLabel.y -= 10;
			
			drawMirrowObjs('diamondsTop', settings.width / 2 - settings.titleWidth / 2 - 5, settings.width / 2 + settings.titleWidth / 2 + 5, -50, true, true);

			drawMirrowObjs('storageWoodenDec', 2, settings.width, 37, false, false, false, 1, -1);
			
			ribbon = backingShort(625, 'questRibbon');
			ribbon.y = settings.height - ribbon.height - 10;
			ribbon.x = (settings.width - ribbon.width) / 2;
			bodyContainer.addChild(ribbon);
			
			container = new Sprite();
			bodyContainer.addChild(container);
			container.x = 50;
			container.y = 60;
			
			if (settings.pID == "126") {
				container.y = 90;
			}
			
			changePromo(settings['pID']);
			
			drawBttm(0, 0);
		}
		
		override public function drawTime():void {
			super.drawTime();
			//timerContainer.visible = false;
		
		}
		
		public override function contentChange():void 
		{
			Load.loading(Config.getImage('promo/images', 'buyZoneImage'), function(data:Bitmap):void {
				var image:Bitmap = new Bitmap(data.bitmapData);
				bodyContainer.addChild(image);
				image.x = (settings.width - image.width) / 2;
			});
		}
		
		
		override public function drawDescription():void 
		{
			var fontSize:int = 26;
			
			desc = Window.drawText(Locale.__e('flash:1413368249559') , {
				color:0xffffff,
				borderColor:0x8140a7,
				textAlign:"center",
				autoSize:"center",
				fontSize:fontSize,
				textLeading: -6,
				wrap:true,
				multiline:true
			});
			desc.wordWrap = true;
			desc.width = settings.width - 60;
			desc.y = 300;
			desc.x = (settings.width - desc.width) / 2;
			bodyContainer.addChild(desc);
			
		}
		
		override public function drawBttm(py:int = 0, ph:int = 0 ):void {
			drawDescription();
			priceBttn.y = settings.height - 60;
		}
	}	
}
