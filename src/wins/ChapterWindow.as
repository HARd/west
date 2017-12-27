package wins 
{
	import com.greensock.TweenLite;
	import core.Load;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.utils.setTimeout;

	public class ChapterWindow extends Window
	{
		private var info:Object;
		
		public function ChapterWindow(settings:Object = null) 
		{
			if (settings == null) {
				settings = new Object();
			}
			
			info = App.data.chapters[settings['chapter']];
			
			settings['width'] 				= 500;
			settings['height'] 				= 400;
			settings['title'] 				= info.title;
			settings['hasPaginator'] 		= false;
			settings['hasExit'] 			= false;
			settings['hasTitle'] 			= false;
			settings['faderClickable'] 		= false;
			settings['escExit'] 			= false;
			settings['faderAlpha'] 			= 1;
			settings['faderColor'] 			= 0x8de8b6;
			settings['forcedClosing'] 		= true;
			settings['strong'] 				= true;
			settings['faderTime'] 			= 3;
			settings['delay'] 				= 2000;
			settings['animationShowSpeed'] 	= 2;
			settings['animationHideSpeed'] 	= 1.5;
			
			super(settings);
			
			SoundsManager.instance.playSFX('levelup');
		}
		
		private var image:Bitmap;
		
		override public function drawBackground():void {
			
		}
		
		private var preloader:Preloader = new Preloader();
		override public function drawBody():void {
			preloader = new Preloader();
			addChild(preloader);
			preloader.x = App.self.stage.stageWidth/ 2;
			preloader.y = App.self.stage.stageHeight/ 2 - 15;
			Load.loading(Config.getImage('chapters', info.preview), onImageLoad);
		}
		
		override public function startOpenAnimation():void {
			
		}
		
		public function onImageLoad(data:Bitmap):void {
			removeChild(preloader);
			preloader = null;
			image = new Bitmap(data.bitmapData);
			bodyContainer.addChild(image);
			image.smoothing = true;
			image.x = (settings.width - image.width) / 2;
			
			var _text:TextField = Window.drawText(settings['title'], {
				fontSize:22,
				autoSize:'left',
				borderColor:0x38342c
			});
			
			var bmd:BitmapData = new BitmapData(_text.width, _text.height, true, 0);
			bmd.draw(_text);
			var text:Bitmap = new Bitmap(bmd);
			text.smoothing = true;
			
			layer.addChild(text);
			text.x = (settings.width - text.width) / 2;
			text.y = image.height - text.height - 41;
			
			var textSettings:Object = 
			{
				title:App.data.chapters[settings['chapter']].description,
				fontSize	:32,
				color		:0x502f06,
				borderColor	:0xf7f2de,
				textAlign	: 'center',
				width		:image.width
			}
			
			var _title:Sprite = titleText(textSettings);
			var title:Bitmap = new Bitmap();
			bmd = new BitmapData(_title.width, _title.height, true, 0);
			bmd.draw(_title);
			title.bitmapData = bmd;
			title.smoothing = true;
			
			bodyContainer.addChild(title);
			title.x = (settings.width - title.width) / 2;
			title.y = image.height - title.height - 7;
			
			addEventListener(WindowEvent.ON_AFTER_OPEN, hideFader);
			
			super.startOpenAnimation();
		}
		
		private function hideFader(e:WindowEvent):void
		{
			settings['faderClickable'] 	= true;
			setTimeout(function():void {
				if (fader != null && fader.alpha == 1)
				{
					TweenLite.to(fader, 3, { alpha:0 } );
					fader.mouseEnabled = false;
				}
				setTimeout(close, 2000);
			}, 1000);
		}
		
		/*override public function close(e:MouseEvent=null):void {
			for (var i:int = 0; i < App.self.windowContainer.numChildren; i++) {
				var backWindow:* = App.self.windowContainer.getChildAt(i);
				if (backWindow is Window && backWindow.opened == false) {
					App.self.windowContainer.removeChild(backWindow);
					backWindow = null;
				}
			}
			
			super.close();
		}*/
	}
}