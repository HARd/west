package wins 
{
	import buttons.Button;
	import core.Load;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import wins.actions.BanksWindow;
	
	public class OfferWindow extends Window
	{
		private var container:Sprite;
		private var priceBttn:Button;
		private var timerText:TextField;
		private var descriptionLabel:TextField;
		private var tiemLabel:TextField;
		private var bitmap:Bitmap;
		
		public function OfferWindow(settings:Object = null)
		{
			if (settings == null) {
				settings = new Object();
			}
			
			settings['width'] = 450;
			settings['height'] = 470;
						
			settings['title'] = Locale.__e('flash:1382952380231');
			settings['hasPaginator'] = false;
			settings['hasButtons'] = false;
			settings['fontColor'] = 0xffcc00;
			settings['fontSize'] = 60;
			settings['fontBorderColor'] = 0x705535;
			settings['shadowBorderColor'] = 0x342411;
			settings['fontBorderSize'] = 8;
			
			super(settings);
		}
							
		override public function drawBody():void {
			
			titleLabel.y = 90;
			
			descriptionLabel = drawText(App.data.money.msg, {
				fontSize:26,
				autoSize:"left",
				textAlign:"center",
				color:0xf0e6c1,
				borderColor:0x502f06,
				multiple:true
			});
			descriptionLabel.wordWrap = true;
			descriptionLabel.width = settings.width - 80;
			descriptionLabel.x = (settings.width - descriptionLabel.width) / 2;
			descriptionLabel.y = titleLabel.y + 7 + (80 - descriptionLabel.textHeight)/2;
			
						
			bodyContainer.addChild(descriptionLabel);
			
			container = new Sprite();
			bodyContainer.addChild(container);
			container.x = 50;
			container.y = 60;
			
				
			var glowing:Bitmap = new Bitmap(Window.textures.actionGlow);
			bodyContainer.addChildAt(glowing, 0);
			
			glowing.alpha = 0.85;
			glowing.width = settings.width - 80;
			glowing.x = (settings.width - glowing.width)/2 + 6;
			glowing.y = descriptionLabel.y + descriptionLabel.height - 10;
			glowing.smoothing = true;
			
			
			
			drawPrice();
			drawTime();
			
			App.self.setOnTimer(updateDuration);
		}
		
		override public function drawBackground():void {
			var background:Bitmap = backing(settings.width, settings.height, 50, "windowActionBacking");
			layer.addChild(background);
			
			Load.loading(Config.getImage('promo/images', 'treasures'), function(data:*):void {
				bitmap = data;
				bitmap.scaleX = bitmap.scaleY = 0.8;
				bitmap.smoothing = true;
				layer.addChildAt(bitmap,1);
				bitmap.x = (settings.width - bitmap.width) / 2;
				bitmap.y = -bitmap.y / 2 - 60; 
			});
		}
		
		public function drawTime():void {
			
			var background:Bitmap = Window.backing(230, 130, 10, "itemBacking");
			background.scaleY = 0.86;
			bodyContainer.addChild(background);
			background.x = (settings.width - background.width)/2;
			background.y = 188;
			
			tiemLabel = drawText(Locale.__e('flash:1382952379969'), {
				fontSize:30,
				textAlign:"center",
				color:0xf0e6c1,
				borderColor:0x502f06
			});
			tiemLabel.width = 230;
			tiemLabel.x = (settings.width - background.width)/2;
			tiemLabel.y = background.y + 18;
			bodyContainer.addChild(tiemLabel);
			
			var time:int = App.data.money.date_to - App.time;
			timerText = Window.drawText(TimeConverter.timeToStr(time), {
				color:0xf8d74c,
				letterSpacing:3,
				textAlign:"center",
				fontSize:34,//30,
				borderColor:0x502f06
			});
			timerText.width = 230;
			timerText.y = background.y + 60;
			timerText.x = background.x;
			bodyContainer.addChild(timerText);
		}
		
		public function drawPrice():void {
			
			var bttnSettings:Object = {
				caption:Locale.__e("flash:1382952379970"),
				fontSize:26,
				width:166,
				height:45//,
				//borderColor:[0xaff1f9, 0x005387],
				//bgColor:[0x70c6fe, 0x765ad7],
				//fontColor:0x453b5f,
				//fontBorderColor:0xe3eff1
			};
			
			var text:String;
			
			priceBttn = new Button(bttnSettings);
			bodyContainer.addChild(priceBttn);
			
			priceBttn.x = (settings.width - priceBttn.width)/2;
			priceBttn.y = settings.height - 160;
			
			priceBttn.addEventListener(MouseEvent.CLICK, buyEvent);
			
		}
		
		private function buyEvent(e:MouseEvent):void {
			close();
			new BanksWindow().show();
		}
		
		private function updateDuration():void {
			var time:int = App.data.money.date_to - App.time;
			timerText.text = TimeConverter.timeToStr(time);
			
			if (time <= 0) {
				descriptionLabel.visible = false;
				timerText.visible = false;
			}
		}
		
		public override function dispose():void
		{
			App.self.setOffTimer(updateDuration);
			super.dispose();
		}
		
	}

}