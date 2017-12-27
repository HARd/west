package wins 
{
	import buttons.Button;
	import buttons.MoneyButton;
	import core.Load;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	/**
	 * ...
	 * @author 
	 */
	public class BoostWindow extends Window
	{
		private var desc:TextField;
		
		public var boostBttn:MoneyButton;
		
		public function BoostWindow(settings:Object = null) 
		{
			settings["width"] = 484;
			settings["height"] = 192;
			settings["fontSize"] = 38,	
			settings["hasPaginator"] = false;
			settings["popup"] = true;
		
			super(settings);	
		}
		
		override public function drawBackground():void {
			var background:Bitmap = backing2(settings.width, settings.height, 40, "questsSmallBackingTopPiece", "questsSmallBackingBottomPiece");
			layer.addChild(background);
		}
		
		override public function drawExit():void {
			super.drawExit();
			
			exit.x = settings.width - exit.width + 12;
			exit.y = -12;
		}
		
		private var bitmap:Bitmap;
		override public function drawBody():void 
		{
			titleLabel.y += 4;
			
			
			//var background:Bitmap = Window.backing(settings.width - 22, settings.height - 13, 10, "questsMainBacking2");
			////bodyContainer.addChild(background);
			//background.x = (settings.width - background.width)/2;
			//background.y = -23;
			
			
			var btmd:BitmapData;
			if (settings.btmdIcon){
				//btmd = settings.btmdIcon;
				
				bitmap = new Bitmap();
				bodyContainer.addChild(bitmap);
				bitmap.smoothing = true;
				
				Load.loading(Config.getIcon(settings.btmdIconType, settings.btmdIcon), onPreviewComplete);
				
			}else{
				btmd = settings.target.bitmap.bitmapData;
				bitmap = new Bitmap(btmd);
				bodyContainer.addChild(bitmap);
				bitmap.scaleX = bitmap.scaleY = 0.9;
				bitmap.smoothing = true;
				bitmap.x = (settings.width - bitmap.width) / 2;
				bitmap.y = 30 - bitmap.height;
			}
			
			desc = Window.drawText(settings.desc, {
				color:0xffffff,
				borderColor:0x6b340c,  
				fontSize:26,
				autoSize:"center",
				textAlign:"center",
				multiline:true,
				wrap:true
			});
			bodyContainer.addChild(desc);
			desc.width = settings.width - 80;
			desc.x = (settings.width - desc.textWidth) / 2 - 8;
			desc.y = (settings.height - desc.textHeight) / 2 - 30;
			
			
			boostBttn = new MoneyButton( {
				title: Locale.__e("flash:1382952380104"),
				countText:settings.request,
				width:192,
				height:56,
				fontSize:32,
				fontCountSize:32,
				radius:26,
				
				bgColor:[0xa8f84a, 0x73bb16],
				borderColor:[0xffffff, 0xffffff],
				bevelColor:[0xcefc97, 0x5f9c11],	
				
				fontColor:0xffffff,			
				fontBorderColor:0x2b784f,
			
				fontCountColor:0xffffff,				
				fontCountBorder:0x2b784f,
				iconScale:0.8
			})
			
			bodyContainer.addChild(boostBttn);
			boostBttn.x = (settings.width - boostBttn.width)/2;
			boostBttn.y = settings.height - boostBttn.height - 10;
			boostBttn.countLabel.width = boostBttn.countLabel.textWidth + 5;
			
			boostBttn.addEventListener(MouseEvent.CLICK, onBoostEvent);
			
			
			drawMirrowObjs('diamondsTop', settings.width / 2 - settings.titleWidth / 2 - 5, settings.width / 2 + settings.titleWidth / 2 + 5, -35, true, true);
			drawMirrowObjs('storageWoodenDec', -5, settings.width + 5, settings.height - 100);
			
		}
		
		public function onPreviewComplete(data:Bitmap):void
		{
			bitmap.bitmapData = data.bitmapData;
			bitmap.x = (settings.width - bitmap.width) / 2;
			bitmap.y = 30 - bitmap.height;
		}
		
		private function onBoostEvent(e:MouseEvent = null):void
		{
			if (e.currentTarget.mode == Button.DISABLED) return;
			close();
			e.currentTarget.state = Button.DISABLED;
			settings.onUpgrade();
		}
		
		override public function dispose():void
		{
			if(boostBttn)boostBttn.removeEventListener(MouseEvent.CLICK, onBoostEvent);
			boostBttn = null;
			super.dispose();
		}
		
	}

}