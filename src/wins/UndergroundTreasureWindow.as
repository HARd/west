package wins
{
	import buttons.Button;
	import core.Load;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import ui.Hints;
	
	/**
	 * ...
	 * @author ...
	 */
	public class UndergroundTreasureWindow extends Window
	{
		public var info:*;
		public var bitmap:Bitmap;
		
		public function UndergroundTreasureWindow(settings:*):void
		{
			if (!settings) settings = {};
			
			settings['width'] = 520;
			settings['height'] = 245;
			settings['background'] = 'goldBacking';
			settings['mirrorDecor'] = 'goldTitleDec';
			settings['hasPaginator'] = false;
			settings['hasButtons'] = false;
			settings['popup'] = true;
			info = settings.info;
			super(settings);
		}
		
		public var preloader:Preloader;
		
		override public function drawBody():void
		{
			super.drawBody();
			
			preloader = new Preloader();
			bodyContainer.addChild(preloader);
			Load.loading(Config.getImage('content', info.preview), onLoad);
			
			drawButtons();
		}
		
		public function onLoad(data:Bitmap):void
		{
			if (preloader)
				bodyContainer.removeChild(preloader);
			
			bitmap = new Bitmap(data.bitmapData);
			bodyContainer.addChild(bitmap);
			bitmap.x = 15;
			bitmap.y = -20;
		}
		
		public var lookBttn:Button;
		public var takeBttn:Button;
		
		public function drawButtons():void
		{
			lookBttn = new Button({width: 200, height: 50, caption: Locale.__e('flash:1382952380228'), bgColor: [0x84c9f3, 0x5cacdd]});
			lookBttn.x = 270;
			lookBttn.y = 30;
			bodyContainer.addChild(lookBttn);
			lookBttn.addEventListener(MouseEvent.CLICK, onLook);
			
			takeBttn = new Button({width: 200, height: 50, caption: Locale.__e('flash:1382952379890')});
			takeBttn.x = 270;
			takeBttn.y = lookBttn.y + lookBttn.height + 10;
			bodyContainer.addChild(takeBttn);
			takeBttn.addEventListener(MouseEvent.CLICK, onTake);
			
			if (settings.onTake == null)
				takeBttn.state = Button.DISABLED;
		}
		
		public function onLook(e:MouseEvent):void
		{
			if (lookBttn.mode == Button.DISABLED) return;
			//lookBttn.state = Button.DISABLED;
			
			settings.onLook();
			//close();
		}
		
		public function onTake(e:MouseEvent):void
		{
			if (takeBttn.mode == Button.DISABLED) {
				Hints.text(Locale.__e('flash:1472721701607'), 9, new Point(App.self.mouseX, App.self.mouseY));
				return;
			}
			takeBttn.state = Button.DISABLED;
			
			settings.onTake();
			close();
		}
	}

}