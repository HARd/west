package wins 
{
	import buttons.Button;
	import com.greensock.easing.Back;
	import com.greensock.TweenLite;
	import core.Load;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.utils.setTimeout;
	
	public class TutorialMessageWindow extends Window 
	{
		
		public static var side:int = 1;
		
		private var persImage:Bitmap;
		private var okBttn:Button;
		
		public var personage:int = 0;
		public var container:Sprite = new Sprite();
		
		
		public function TutorialMessageWindow(settings:Object=null) 
		{
			if (!settings) settings = { };
			
			settings['width'] = 900;
			settings['hasPaginator'] = false;
			settings['hasClose'] = false;
			settings['hasTitle'] = false;
			settings['escExit'] = false;
			settings['hasExit'] = false;
			settings['faderClickable'] = (Config.admin) ? true : false;
			settings['faderAlpha'] = 0.45;
			settings['hasAnimations'] = false;
			
			settings['title'] = settings['title'] || '';
			settings['description'] = settings['description'] || '';
			
			super(settings);
			
			side = (side + 1) % 2;
			
			App.self.stage.addEventListener(Event.FULLSCREEN, onFullscreen);
		}
		
		override public function drawBackground():void { }
		
		override public function drawBody():void {
			
			persImage = new Bitmap();
			addChild(persImage);
			
			addChild(container);
			
			var fontSize:int = 25;
			var description:String = settings.description;
			if (App.lang == 'jp') {
				fontSize = 30;
				description = Storage.japanFormat(description, 30);
			}
			var textLabel:TextField = drawText(description, {
				width:			440,
				autoSize:		'center',
				textAlign:		'center',
				fontSize:		fontSize,
				color:			0x532c0b,
				borderColor:	0xfae8d2,
				multiline:		true,
				wrap:			true
			});
			textLabel.wordWrap = true;
			textLabel.multiline = true;
			
			textLabel.x = (side) ? 100 : 390;
			textLabel.y = 50;
			
			var back:Bitmap = backing(textLabel.width + 80, textLabel.height + 100, 50, 'dialogueBacking');
			back.x = textLabel.x - 40;
			back.y = textLabel.y - 50;
			
			var decor1:Bitmap = new Bitmap(Window.texture('dialogueBackingDec'));
			decor1.x = back.x - 14;
			decor1.y = back.y;
			
			var decor2:Bitmap = new Bitmap(Window.texture('dialogueBackingDec'));
			decor2.scaleX = decor2.scaleY = -1;
			decor2.x = back.x + back.width + 14;
			decor2.y = back.y + back.height;
			
			var upLine:Bitmap = new Bitmap(Window.textures.dividerLine);
			upLine.width = textLabel.width;
			upLine.scaleY = -1;
			upLine.alpha = 0.4;
			upLine.x = textLabel.x;
			upLine.y = textLabel.y - 25;
			
			var downLine:Bitmap = new Bitmap(Window.textures.dividerLine);
			downLine.width = textLabel.width;
			downLine.alpha = 0.4;
			downLine.x = textLabel.x;
			downLine.y = textLabel.y + textLabel.height + 28;
			
			var titleLabel:TextField = drawText(settings.title, {
				autoSize:		'center',
				fontSize:		48,
				color:			0xfefcff,
				borderColor:	0xb48849,
				shadowSize:		4,
				shadowColor:	0x513a32
			});
			titleLabel.x = textLabel.x + (textLabel.width - titleLabel.width) / 2;
			titleLabel.y = textLabel.y - 75;
			
			okBttn = new Button( {
				width:		160,
				height:		46,
				caption:	Locale.__e('flash:1382952380242')
			});
			okBttn.name = 'tmw_okBttn';
			okBttn.x = textLabel.x + (textLabel.width - okBttn.width) / 2;
			okBttn.y = textLabel.y + textLabel.height + okBttn.height - 32;
			okBttn.addEventListener(MouseEvent.CLICK, onClick);
			
			
			container.addChild(back);
			container.addChild(decor1);
			container.addChild(decor2);
			container.addChild(textLabel);
			container.addChild(upLine);
			container.addChild(downLine);
			drawMirrowObjs('titleDecRose', titleLabel.x - 70, titleLabel.x + titleLabel.width + 70, titleLabel.y + 10, false, false, false, 1, 1, container);
			container.addChild(titleLabel);
			container.addChild(okBttn);
			
			container.x = (App.self.stage.stageWidth - settings.width) / 2;
			container.y = App.self.stage.stageHeight;
			
			setTimeout(function():void {
				TweenLite.to(container, 0.5, { 
					y:		App.self.stage.stageHeight - container.height,
					ease:	Back.easeOut
				} );
			}, 300);
			
			Load.loading(Config.getImageIcon('quests/preview', settings.personage), function(data:Bitmap):void {
				persImage.bitmapData = data.bitmapData;
				persImage.scaleX = (side) ? -1 : 1;
				persImage.x = (side) ? (container.x + container.width + 40 + persImage.width) : (container.x + 390 - persImage.width - 40);
				persImage.y = App.self.stage.stageHeight;// container.y - 115;
				
				TweenLite.to(persImage, 0.5, { 
					y:		(container.height + 130 > persImage.height) ? (App.self.stage.stageHeight - container.height / 2 - persImage.height / 2 - 15) : (App.self.stage.stageHeight - container.height - 170),
					ease:	Back.easeOut
				} );
			} );
		}
		
		private function onClick(e:MouseEvent):void {
			if (settings.callback && (settings.callback is Function)) {
				settings.callback();
			}
			
			close();
		}
		
		private function onFullscreen(e:Event):void {
			setTimeout(function():void {
				TweenLite.to(container, 0.5, { 
					x:		(App.self.stage.stageWidth - settings.width) / 2,
					y:		App.self.stage.stageHeight - container.height,
					ease:	Back.easeOut
				} );
				
				TweenLite.to(persImage, 0.5, { 
					x:		container.x - persImage.width,
					y:		(container.height + 130 > persImage.height) ? (App.self.stage.stageHeight - container.height / 2 - persImage.height / 2 - 15) : (App.self.stage.stageHeight - container.height - 170),
					ease:	Back.easeOut
				} );
			}, 300);
		}
		
		override public function dispose():void {
			if (okBttn) okBttn.removeEventListener(MouseEvent.CLICK, onClick);
			
			super.dispose();
		}
	}

}