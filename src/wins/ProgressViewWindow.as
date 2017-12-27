package wins 
{
	import buttons.Button;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.BevelFilter;
	import flash.filters.BitmapFilterType;
	import flash.filters.DropShadowFilter;
	import flash.text.TextField;
	
	public class ProgressViewWindow extends Window 
	{
		
		public var okBttn:Button;
		public var titlePole:TextField;
		public var progressLabel:TextField;
		public var checkBack:Bitmap;
		public var checkMark:Bitmap;
		public var progressBacking:Bitmap;
		//public var image:Bitmap;
		public var titleBacking:Bitmap;
		//public var overlay:Bitmap;
		protected var progressBar:ProgressBar;
		
		public function ProgressViewWindow(settings:Object = null) 
		{
			if (!settings) settings = { };
			settings['width'] = settings['width'] || 300;
			settings['height'] = settings['height'] || 270;
			settings['title'] = settings['update']['title'] || '';
			
			settings['hasPaginator'] = false;
			settings['hasExit'] = false;
			settings['background'] = 'questBacking';
			settings['popup'] = true;
			
			super(settings);
		}
		
		override public function drawTitle():void {}
		
		override public function drawBackground():void {
			var background:Bitmap = backing(settings.width, settings.height, 25, 'questBacking');
			layer.addChild(background);
		}
		
		override public function drawBody():void {
			
			okBttn = new Button( {
				caption:		Locale.__e('flash:1382952380298'),
				width:			185,
				height:			48
			});
			okBttn.x = (settings.width - okBttn.width) / 2;
			okBttn.y = settings.height - 30;
			bodyContainer.addChild(okBttn);
			okBttn.addEventListener(MouseEvent.CLICK, onOk);
			
			titleBacking = new Bitmap(Window.textures.chapterBack, 'auto', true);
			titleBacking.x = (settings.width - titleBacking.width) / 2;
			titleBacking.y = -140;
			bodyContainer.addChild(titleBacking);
			
			titlePole = drawText(settings.title, {
				width:			settings.width - 40,
				color:			0xfeffe6,
				borderColor:	0x542d6e, // ab46ea
				fontSize:		36,
				textAlign:		'center'
				//filters:		[new DropShadowFilter(3, 90, 0xab46ea]
			});
			titlePole.x = (settings.width - titlePole.width) / 2;
			titlePole.y = titleBacking.y + 240;
			bodyContainer.addChild(titlePole);
			
			var imageCont:Sprite = new Sprite();
			imageCont.x = settings.width / 2;
			imageCont.y = titleBacking.y + 155;
			bodyContainer.addChild(imageCont);
			//imageCont.filters = [new BevelFilter(8, 45, 16777215, 1, 0, 1, 8, 8, 1, 1, BitmapFilterType.INNER)];
			
			var imageMask:Shape = new Shape();
			imageMask.graphics.beginFill(0x000000, 1);
			imageMask.graphics.drawCircle(0, 0, 68);
			imageMask.graphics.endFill();
			imageMask.x = 0;
			imageMask.y = 0;
			/*imageMask.x = settings.width / 2;
			imageMask.y = titleBacking.y + 155;*/
			imageCont.addChild(imageMask);
			
			var image:Bitmap = new Bitmap(settings.image.bitmapData, 'auto', true);
			image.width = imageMask.width;
			image.scaleY = image.scaleX;
			image.x = -image.width / 2;
			image.y = -image.width / 2 - 15;
			//image.alpha = 0.6;
			image.mask = imageMask;
			imageCont.addChild(image);
			
			var overlay:Bitmap = new Bitmap(Window.textures.chapterLensOverlay, 'auto', true);
			overlay.x = -overlay.width / 2;
			overlay.y = -overlay.height / 2;
			imageCont.addChild(overlay);
			overlay.alpha = 0.5;
			
			if (settings.percent >= 1) {
				drawMirrowObjs('divider', 30, settings.width - 30, 185, false, false, false, 0.5);
				
				checkBack = new Bitmap(Window.textures.questCheckmarkSlot, 'auto', true);
				checkBack.x = (settings.width - checkBack.width) / 2;
				checkBack.y = 160;
				bodyContainer.addChild(checkBack);
				
				checkMark = new Bitmap(Window.textures.checkMark, 'auto', true);
				checkMark.x = (settings.width - checkMark.width) / 2 + 5;
				checkMark.y = 160;
				bodyContainer.addChild(checkMark);
			}else {
				progressLabel = drawText(Locale.__e('flash:1412073237690') + ':', {
					width:			settings.width - 20,
					fontSize:		26,
					color:			0xfffcfa,
					borderColor:	0x664510,
					textAlign:		'center'
				});
				progressLabel.x = (settings.width - progressLabel.width) / 2;
				progressLabel.y = titleBacking.y + titleBacking.height - 40;
				bodyContainer.addChild(progressLabel);
				
				progressBacking = Window.backingShort(settings.width - 26, "prograssBarBacking3");
				progressBacking.x = (settings.width - progressBacking.width) / 2;
				progressBacking.y = progressLabel.y + progressLabel.height - 4;
				bodyContainer.addChild(progressBacking);
				
				progressBar = new ProgressBar( {
					win:			this,
					width:			settings.width - 20,
					timeFormat:		3
				});
				progressBar.time = int(settings.percent * 100);
				progressBar.progress = settings.percent;
				progressBar.x = progressBacking.x - 2;
				progressBar.y = progressBacking.y - 2;
				progressBar.start();
				bodyContainer.addChild(progressBar);
			}
			
		}
		
		private function onOk(e:MouseEvent):void {
			close();
		}
		
		override public function dispose():void {
			okBttn.removeEventListener(MouseEvent.CLICK, onOk);
			okBttn.dispose();
			okBttn = null;
			
			super.dispose();
		}
	}

}