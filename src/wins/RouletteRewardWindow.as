package wins 
{
	import buttons.Button;
	import core.Load;
	import core.Size;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	public class RouletteRewardWindow extends Window 
	{
		private var okBttn:Button;
		public function RouletteRewardWindow(settings:Object=null) 
		{
			if (!settings) settings = { };
			
			settings['width'] = settings['width'] || 470;
			settings['height'] = settings['height'] || 400;
			settings['title'] = Locale.__e('flash:1431685989241');
			settings['hasPaginator'] = false;
			settings['background'] = 'alertBacking';
			
			super(settings);
		}
		
		override public function drawBody():void {
			exit.visible = false;
			titleLabel.visible = false;
			
			var pic:Bitmap = new Bitmap();
			bodyContainer.addChild(pic);
			
			var titleText:TextField = drawText(settings.title, {
				color				: 0xffffff,
				multiline			: settings.multiline,			
				fontSize			: 46,
				textLeading	 		: settings.textLeading,	
				border				: true,
				borderColor 		: 0xc4964e,			
				borderSize 			: 4,	
				shadowColor			: 0x503f33,
				shadowSize			: 4,
				width				: settings.width,
				textAlign			: 'center',
				sharpness 			: 50,
				thickness			: 50
			});
			titleText.y = 70;
			bodyContainer.addChild(titleText);
			
			okBttn = new Button( {
				height:47,
				caption:Locale.__e('flash:1404394519330')
			});
			okBttn.x = (settings.width - okBttn.width) / 2;
			okBttn.y = settings.height - okBttn.height * 2;
			okBttn.addEventListener(MouseEvent.CLICK, onOk);
			bodyContainer.addChild(okBttn);
			
			var separator:Bitmap = Window.backingShort(300, 'dividerLine', false);
			separator.x = 90;
			separator.y = 160;
			separator.alpha = 0.5;
			bodyContainer.addChild(separator);
			
			var separator2:Bitmap = Window.backingShort(300, 'dividerLine', false);
			separator2.scaleY = -1;
			separator2.x = 90;
			separator2.y = okBttn.y - 15;
			separator2.alpha = 0.5;
			bodyContainer.addChild(separator2);
			
			var textDesc:TextField = drawText(Locale.__e('flash:1382952380000'), {
				width:settings.width,
				textAlign:'center',
				fontSize:34,
				color:0xffdb7a,
				borderColor:0x60331c
			});
			textDesc.y = separator.y - textDesc.textHeight / 2;
			bodyContainer.addChild(textDesc);
			
			if (settings.hasOwnProperty('prize')){
				drawPrize();
			}
			
			Load.loading(Config.getImage('content', 'GiftWinPic1'), function(data:*):void {
				pic.bitmapData = data.bitmapData;
				pic.x = (settings.width - pic.width) / 2;
				pic.y = -pic.height + 170;
			});
		}
		
		private var sprite:LayerX = new LayerX();
		private function drawPrize():void {
			bodyContainer.addChild(sprite);
			
			for (var s:* in settings.prize) {
				var count:int = settings.prize[s];
			}
			
			var bg:Sprite = new Sprite();
			bg.graphics.beginFill(0xcbd4cf);
			bg.graphics.drawCircle(47, 100, 47);
			bg.graphics.endFill();
			bg.x = (settings.width - bg.width) / 2;
			bg.y = 126;
			sprite.addChild(bg);
			
			var countText:TextField = drawText(String(count) , {
				width:settings.width,
				textAlign:'center',
				fontSize:30,
				color:0xffffff,
				borderColor:0x60331c
			});
			countText.y = bg.y + bg.height + 35;
			sprite.addChild(countText);
			
			var titleText:TextField = drawText(String(App.data.storage[s].title) , {
				width:settings.width,
				textAlign:'center',
				fontSize:26,
				color:0xffffff,
				borderColor:0x60331c
			});
			titleText.y = bg.y + 42;
			sprite.addChild(titleText);
			
			var icon:Bitmap = new Bitmap();
			bg.addChild(icon);
			
			Load.loading(Config.getIcon(App.data.storage[s].type, App.data.storage[s].preview), function(data:*):void {
				icon.bitmapData = data.bitmapData;
				icon.smoothing = true;
				Size.size(icon, 80, 80);
				icon.x = (bg.width - icon.width) / 2;
				icon.y = (bg.height - icon.height) / 2 + 30;
			});
			
			sprite.tip = function():Object {
				return {
					title:App.data.storage[s].title,
					text:App.data.storage[s].description
				}
			}
		}
		
		private function onOk(e:MouseEvent):void {
			close();
		}
		
		override public function dispose():void {
			okBttn.removeEventListener(MouseEvent.CLICK, onOk);
			super.dispose();
		}
	}

}