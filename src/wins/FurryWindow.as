package wins 
{
	import buttons.Button;
	import buttons.ImageButton;
	import buttons.MixedButton2;
	import com.flashdynamix.motion.extras.TextPress;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import flash.utils.setTimeout;
	import ui.UserInterface;
	import units.Animal;
	import units.Factory;
	import units.Moneyhouse;
	import units.Resource;
	import units.Techno;
	/**
	 * ...
	 * @author ...
	 */
	public class FurryWindow extends Window
	{
		private var robotIcon:Bitmap;
		private var robotCounter:TextField;
		private var timeLeft:TextField;
		private var textSettings:Object;
		private var bitmap:Bitmap;
		private var background2:Bitmap;
		private var separator:Bitmap;
		private var separator2:Bitmap;
		private var collectBttn:MixedButton2;
		
		public var plusBttn:ImageButton;
		public var minusBttn:ImageButton;
		public var minusBttn10:ImageButton;
		public var plusBttn10:ImageButton;
	
				
		public static const FURRY:int = 1;
		public static const RESOURCE:int = 2;
		public static const COLLECTOR:int = 3;
		public static const COWBOW:int = 4;
		public static const GOLDEN_FURRY:int = 5;
		public static const FURRY_FREE:int = 6;
		public static const FURRY_GARDENER:int = 7;
		
		public var neededResourse:int = -1;
		
		//public static const FURRY:int = 1;
		public var mode:int = FURRY
		
		public function FurryWindow(settings:Object = null) 
		{
			if (settings == null) {
				settings = new Object();
			}
			
			settings["width"] = 320;
			settings["height"] = 300;
			settings["title"] = settings.info.title;
			settings["fontSize"] = 150;
			settings["hasPaginator"] = false;
			mode = settings["mode"] || FURRY;
			settings["iconBuilding"] = settings.iconBuilding;
			
			for (var pr_sid:* in settings.target.info.require) {
				neededResourse = pr_sid;
			}
			
			super(settings);
		}
		
		override public function drawBackground():void 
		{
		
			if(mode == FURRY || mode == COLLECTOR || mode == COWBOW || mode == FURRY_FREE || mode == FURRY_GARDENER)
			{
				background = backing(settings.width, settings.height + 45, 20, "goldBacking");
				separator = Window.backingShort(160, 'dividerLight', false);
				separator2 = Window.backingShort(160, 'dividerLight', false);
				
				separator.alpha = separator2.alpha =  0.7;
				separator.x = 70;
				separator.y = separator2.y = 180;
				separator2.x = 315;
				separator2.scaleX = -1;
				
				
				/*bodyContainer.addChild(separator);
				bodyContainer.addChild(separator2);	*/
				
				
				
			}
			
			//	bodyContainer.addChild(separator);
			//	bodyContainer.addChild(separator2);
			/*if(mode == FURRY)
			{
				background = backing(settings.width, settings.height + 45, 20, "bankBacking");
				separator = Window.backingShort(160, 'dividerLight', false);
				separator2 = Window.backingShort(160, 'dividerLight', false);
				
				separator.alpha = separator2.alpha =  0.7;
				separator.x = 40;
				separator.y = separator2.y = 260;
				separator2.x = 325;
				separator2.scaleX = -1;
				bodyContainer.addChild(separator);
				bodyContainer.addChild(separator2);
				
				
			}*/
			
			if(mode == RESOURCE)
			{
				background = backing(settings.width, settings.height, 20, "bankBacking");
				background.x += 50;
			layer.addChildAt(background, 0);
			layer.addChildAt(separator, 1);
			layer.addChildAt(separator2, 2);
			
			}
			
			if(mode == FURRY || FURRY_GARDENER)
			{
				layer.addChildAt(background, 0);
			}
			
		}
		
		override public function drawTitle():void{			
		}
			
		private function drawTitleLabel():void 
		{
			var titleContainer:Sprite = new Sprite();
			var textFilter:GlowFilter = new GlowFilter(0x885827, 1, 4,4, 8, 1);
			
			var title:TextField = Window.drawText(settings.info.title, {
					color		:0xfeffff,
					borderColor	:0xb88556,
					fontSize	:38,
					multiline	:true,
					wrap		:true,
					textAlign	:"center",
					textLeading : -12
					
				});
				
				if(mode == FURRY || mode == COLLECTOR || mode == COWBOW || mode == FURRY_FREE || mode == FURRY_GARDENER)
				{
					title.y = -35;
					title.width = 250;
					title.x = (settings.width - title.width) / 2 - 2;
				}
				
				if(mode == RESOURCE)
				{
					title.y = -40;
					title.x += 50;
					title.width = 200;
					title.x = (settings.width - title.width) / 2 + 50;
				}
				
			titleContainer.addChild(title);
			titleContainer.filters = [textFilter ];
			bodyContainer.addChild(titleContainer);
		}
		
		override public function drawBody():void 
		{
			if(mode == FURRY || mode == FURRY_GARDENER)
			{
				background2 = Window.backing(205, 188, 20, "itemBacking");
				
					
				background2.x = (settings.width/2 - background2.width / 2);
				background2.y = (settings.height/2 - background2.height / 2) +15 ;
				layer.addChild(background2);  // было закомментировано
				//drawMirrowObjs('diamonds', 24, settings.width - 24, 58, false, false, false,1,-1 );
				//drawMirrowObjs('storageWoodenDec', 0, settings.width  , 48, false, false, false,1,-1);
				//drawMirrowObjs('storageWoodenDec', 0, settings.width , settings.height - 65);
				drawButtons();
				//shopBusyFurry();
				drawItems();
				if(mode == FURRY){
					showTimer();
				}
				drawTitleLabel();
				return;
			}
			
			
			
			
			if(mode == RESOURCE)
			{	
				
				
				var countContainer:Sprite = new Sprite();
				var capacityContainer:Sprite = new Sprite();
					background2 = Window.backing2(146, 134, 30, "bankInnerBackingTop", "bankInnerBackingBot", 0);
				
				background2.x = (settings.width/2 - background2.width / 2) + 50;
				background2.y = (settings.height/2 - background2.height / 2) - 65;
				layer.addChild(background2);
				
				var bIconData:BitmapData = settings.target.bmp.bitmapData;
				var bIcon:Bitmap = new Bitmap;
					bIcon.bitmapData = bIconData;
				if (bIcon.height > background2.height){
				bIcon.height = background2.height +15;
				bIcon.scaleX = bIcon.scaleY;	
			}
			if (bIcon.width > background2.width-30){
				bIcon.width = background2.width - 20;
				bIcon.scaleY = bIcon.scaleX;	
			}
			
			
				bIcon.x = background2.x +(background2.width - bIcon.width) / 2;
				if (background2.height != bIcon.height+15) 
				{
					bIcon.y = (background2.y - bIcon.height) +  (background2.height+bIcon.height)/2 -10;
				}
				else 
				{
					bIcon.y = background2.y - bIcon.height +120 ;
				}
				
			
				
				layer.addChild(bIcon);
				
				var iconSmallBack:Bitmap = new Bitmap(Window.textures.smallHutBack);
				iconSmallBack.x = (settings.width - iconSmallBack.width) / 2 + 50;
				iconSmallBack.y = (settings.width - iconSmallBack.width) / 2 + 30;
			//	iconSmallBack.alpha =  0.5;
				layer.addChild(iconSmallBack);
				
				drawItems();	
				
				
				
			
				var bg:Shape = new Shape();
				bg.graphics.beginFill(0xbc8e41);
				bg.graphics.drawCircle(0, 0, 18);
				
				var bg2:Shape = new Shape();
				bg2.graphics.beginFill(0xefd099);
				bg2.graphics.drawCircle(0, 0, 15);
				
				var bg3:Shape = new Shape();
				bg3.graphics.beginFill(0xbc8e41);
				bg3.graphics.drawCircle(0, 0, 19);
				
				var bg4:Shape = new Shape();
				bg4.graphics.beginFill(0xefd099);
				bg4.graphics.drawCircle(0, 0, 16);
					
			//	countContainer.addChild(bg);
			//	countContainer.addChild(bg2);
				
			//	capacityContainer.addChild(bg3);
			//	capacityContainer.addChild(bg4);
				
				
				itemCount = settings.capacity;
				
				
				itemCapacityTf = Window.drawText(String(itemCount - capacity) , {
					color		:0xfeffff,
					borderColor	:0x572c26,
					fontSize	:22,
					textAlign	:"center"
				});
				itemCapacityTf.x = iconSmallBack.x;
				itemCapacityTf.y = iconSmallBack.y ;
				
				
					
				minusBttn10 = new ImageButton(UserInterface.textures.coinsMinusBttn10);
				minusBttn10.scaleX = 0.9; 
				minusBttn10.x = -200; 
				minusBttn10.y = -5;
				
				minusBttn = new ImageButton(UserInterface.textures.coinsMinusBttn);
				minusBttn.x = minusBttn10.x + minusBttn10.width +5;
				minusBttn.y = minusBttn10.y
				bg.x = minusBttn.x + minusBttn.width + 5;
				bg.y = 10;
				bg2.x = bg.x;
				bg2.y = bg.y;
				
				
				
				plusBttn = new ImageButton(UserInterface.textures.coinsPlusBttn2);
				plusBttn.x = minusBttn.x + 130;
				plusBttn.y = minusBttn10.y;
				
				plusBttn10 = new ImageButton(UserInterface.textures.coinsPlusBttn10);
				plusBttn10.scaleX = 0.9; 
				plusBttn10.x = plusBttn.x + plusBttn.width +5;
				plusBttn10.y = plusBttn.y;
				
				
				capacity = 1;
				countCalc = Window.drawText(String(capacity) +"/"+String(itemCount) , {
					color		:0xfeffff,
					borderColor	:0x572c26,
					fontSize	:24,
					textAlign	:"center"
				});
				countCalc.x = minusBttn.x +minusBttn.width ;
				countCalc.y = minusBttn.y - 2;
				
				
				
				var iconBack:Bitmap = new Bitmap(Window.textures.hutBack);
				iconBack.x = (settings.width - iconBack.width) / 2 + 50;
				iconBack.y = (settings.width - iconBack.width) / 2 + 235;
			
				layer.addChild(iconBack);
				
				var mineCounterBacking:Bitmap = backingShort(80,"mineCounterBacking");
				mineCounterBacking.y = minusBttn.y -5;
				mineCounterBacking.x = minusBttn.x + minusBttn.width + 10;
				
				
				var title:TextField = Window.drawText(Locale.__e("flash:1412864010955"), {
					color		:0xfeffff,
					borderColor	:0x7a4b1f,
					fontSize	:26,
					multiline	:true,
					wrap		:true,
					textAlign	:"center"
					
					
				});
				
				title.x = countCalc.x;
				title.y = countCalc.y - 30;
				countContainer.addChild(title);
				
				var titleNeed:TextField = Window.drawText(Locale.__e("flash:1412864086819"), {
					color		:0xfeffff,
					borderColor	:0x7a4b1f,
					fontSize	:26,
					multiline	:false,
					wrap		:true,
					textAlign	:"center"
					
					
				});
				titleNeed.width = 110;
				titleNeed.x = countCalc.x;
				titleNeed.y = countCalc.y + 30;
				titleNeed.height = 30;
				countContainer.addChild(titleNeed);
				
				var iconSlave:Bitmap = new Bitmap(UserInterface.textures.robotIcon);
				iconSlave.scaleX = iconSlave.scaleY = 0.8;
				iconSlave.smoothing = true;
				iconSlave.x = iconBack.x + 5;
				iconSlave.y = iconBack.y + (iconBack.height-iconSlave.height)/2;
				
				layer.addChild(iconSlave);
				
				priceCalcSlave = Window.drawText("1", {
					color		:0xffdb65,
					borderColor	:0x775002,
					fontSize	:34,
					textAlign	:"left"
				});
				priceCalcSlave.x = iconSlave.x + iconSlave.width +3;
				priceCalcSlave.y = iconSlave.y+3;
				layer.addChild(priceCalcSlave);
				var icon:Bitmap = new Bitmap(UserInterface.textures.cookie);
				icon.scaleX = icon.scaleY = 0.8;
				icon.smoothing = true;
				icon.x = iconBack.x + 120;
				icon.y = iconBack.y + (iconBack.height-icon.height)/2;
				layer.addChild(icon);
				
				priceCount = capacity * settings.target.info.require[Stock.COOKIE];
				priceCalc = Window.drawText(String(priceCount) , {
					color		:0xffdb65,
					borderColor	:0x775002,
					fontSize	:34,
					textAlign	:"center"
				});
				priceCalc.x = icon.x + icon.width -priceCalc.width/2 +18 ;
				priceCalc.y = icon.y + 3;
				
				var iconBackPlus:Bitmap = new Bitmap(UserInterface.textures.mainBttnBacking);
				iconBackPlus.scaleX = iconBackPlus.scaleY = 0.9;
				iconBackPlus.smoothing = true;
				iconBackPlus.x = iconBack.x + iconBack.width - iconBackPlus.width -5;
				iconBackPlus.y = iconBack.y + (iconBack.height-iconBackPlus.height)/2;
				layer.addChild(iconBackPlus);
				
				
				
				cookiePlusBttn 	= new ImageButton(UserInterface.textures.energyPlusBttn);
				cookiePlusBttn.scaleX = cookiePlusBttn.scaleY = 0.9;
				
				layer.addChild(cookiePlusBttn)
				cookiePlusBttn.x = iconBackPlus.x + 6;
				cookiePlusBttn.y =  iconBack.y + (iconBack.height-cookiePlusBttn.height)/2;
				
				var iconBackPlus2:Bitmap = new Bitmap(UserInterface.textures.mainBttnBacking);
				iconBackPlus2.scaleX = iconBackPlus2.scaleY = 0.9;
				iconBackPlus2.smoothing = true;
				iconBackPlus2.x = priceCalcSlave.x + priceCalcSlave.textWidth +10;
				iconBackPlus2.y = iconBack.y + (iconBack.height-iconBackPlus2.height)/2;
				layer.addChild(iconBackPlus2);
				
				robotPlusBttn 	= new ImageButton(UserInterface.textures.energyPlusBttn);
				robotPlusBttn.scaleX = robotPlusBttn.scaleY = 0.9;
				layer.addChild(robotPlusBttn)
				robotPlusBttn.x = iconBackPlus2.x + 6;
				robotPlusBttn.y = iconBack.y + (iconBack.height-robotPlusBttn.height)/2;
				
				minusBttn.state = Button.DISABLED;
				minusBttn10.state = Button.DISABLED;
				plusBttn.addEventListener(MouseEvent.CLICK, onPlusEvent);
				plusBttn10.addEventListener(MouseEvent.CLICK, onPlus10Event);
				minusBttn.addEventListener(MouseEvent.CLICK, onMinusEvent);
				minusBttn10.addEventListener(MouseEvent.CLICK, onMinus10Event);
				cookiePlusBttn.addEventListener(MouseEvent.CLICK, onBuyEvent);
				robotPlusBttn.addEventListener(MouseEvent.CLICK, onBuyEvent);
				countContainer.addChild(mineCounterBacking);
				countContainer.addChild(plusBttn);
				countContainer.addChild(minusBttn);
				countContainer.addChild(plusBttn10);
				countContainer.addChild(minusBttn10);
				countContainer.addChild(countCalc);
				layer.addChild(priceCalc);
				capacityContainer.addChild(itemCapacityTf);
				
				layer.addChild(countContainer);
				layer.addChild(capacityContainer);
				
				countContainer.x = (background2.width + countContainer.width) / 2 - 10 + 90;
				countContainer.y = background2.y + (background2.height + countContainer.height) / 2 + 40;
				
				capacityContainer.x = layer.x ;
				capacityContainer.y = layer.y ;
				
			
				
				
				
				
				drawButtons();
				drawTitleLabel();
				return;
			}
		}
		
		private function showTimer():void 
		{
			textSettings = {
				color:0xFFFFFF,
				borderColor:0x4b2e1a,
				fontSize:32,
				textAlign:"center",
				multiline:true,
				width: 200
			};
		
			timeLeft = Window.drawText(Locale.__e("flash:1382952379794",TimeConverter.timeToStr(settings.finished - App.time)), textSettings);
			

			layer.addChild(timeLeft);
				
			timeLeft.x = settings.width/2 - timeLeft.textWidth/2;
			timeLeft.y = background2.y+ background2.height+ 10;
			
			App.self.setOnTimer(showTimeLeft)
			
		}
		
		private function showTimeLeft():void 
		{
			timeLeft.text = Locale.__e("flash:1382952379794", TimeConverter.timeToStr(settings.finished - App.time));
			if (settings.finished - App.time <= 0) 
			{
				//close();
			}
		}
		
		override public function close(e:MouseEvent = null):void {
			
			if (settings.hasAnimations == true) {
				startCloseAnimation();
			}else 
			if (settings.hasOwnProperty('finished')) {
				App.self.setOffTimer(showTimeLeft)
			}else{
				dispatchEvent(new WindowEvent("onBeforeClose"));
				dispose();
			}
		}
		
		private function onBuyEvent(e:MouseEvent = null):void 
		{
		if (App.user.quests.tutorial)
				return;
			
			this.close();
			//new JamWindow( { view:'cookie' } ).show();
		}
		
		private function onMinus10Event(e:MouseEvent):void 
		{
			if (e.currentTarget.mode == Button.DISABLED) return;
			
			if (capacity - 10 <= 0)
			{
				capacity = 1;
			}else
				capacity -= 10;
			
			plusBttn.state = Button.NORMAL;
			plusBttn10.state = Button.NORMAL;
				
			priceCount = int(capacity * settings.target.info.require[Stock.COOKIE]);
			priceCalc.text = String(priceCount);
			countCalc.text = String(capacity)+"/"+String(itemCount);
			itemCapacityTf.text = String(itemCount - capacity);
			timeNeed = capacity * settings.target.info.time;  
			collectBttn.count = TimeConverter.timeToCuts(timeNeed, true, true);
			collectBttn.topLayer.x = (collectBttn.bottomLayer.width - collectBttn.topLayer.width) / 2 - 30;
			
			if (capacity < 2) {
				minusBttn10.state = Button.DISABLED;
				minusBttn.state = Button.DISABLED;
			}
		}
		
		private function onPlus10Event(e:MouseEvent):void 
		{
			if (e.currentTarget.mode == Button.DISABLED) return;
			
			if (capacity + 10 >= itemCount)
			{
				capacity = itemCount;
			}else
				capacity += 10;
			
			minusBttn.state = Button.NORMAL;
			minusBttn10.state = Button.NORMAL;
			
			priceCount = int(capacity * settings.target.info.require[Stock.COOKIE]);
			priceCalc.text = String(priceCount);
			countCalc.text = String(capacity)+"/"+String(itemCount);
			itemCapacityTf.text = String(itemCount - capacity);
			timeNeed = capacity * settings.target.info.time;  
			collectBttn.count = TimeConverter.timeToCuts(timeNeed, true, true);
			collectBttn.topLayer.x = (collectBttn.bottomLayer.width - collectBttn.topLayer.width) / 2 - 30;
			
			if (capacity == itemCount) {
				plusBttn.state = Button.DISABLED;
				plusBttn10.state = Button.DISABLED;
			}
		}
		
		
		public var capacity:int = 0;
		private function onMinusEvent(e:MouseEvent):void 
		{
			if (e.currentTarget.mode == Button.DISABLED) return;
			
			capacity --;
			
			priceCount = int(capacity * settings.target.info.require[Stock.COOKIE]);
			priceCalc.text = String(priceCount);
			countCalc.text = String(capacity)+"/"+String(itemCount);
			itemCapacityTf.text = String(itemCount - capacity);
			timeNeed = capacity * settings.target.info.time;  
			collectBttn.count = TimeConverter.timeToCuts(timeNeed, true, true);
			collectBttn.topLayer.x = (collectBttn.bottomLayer.width - collectBttn.topLayer.width) / 2 - 30;
			
			if (capacity <= 1) {
				minusBttn.state = Button.DISABLED;
				minusBttn10.state = Button.DISABLED;
			}
				
			plusBttn.state = Button.NORMAL
			plusBttn10.state = Button.NORMAL;
		}
		
		private function onPlusEvent(e:MouseEvent):void 
		{
			if (e.currentTarget.mode == Button.DISABLED) return;
		if (priceCount==App.user.stock.count(150)) 
		{
			priceCalc.textColor = 0xee7462;
		}
			/*if (priceCount>App.user.stock.count(150)) 
			{
				priceCalc = Window.drawText(String(priceCount) , {
					color		:0xee7462,
					borderColor	:0x775002,
					fontSize	:34,
					textAlign	:"center"
				});
			}*/
			capacity ++
			
			priceCount = int(capacity * settings.target.info.require[Stock.COOKIE]);
			
			priceCalc.text = String(priceCount);
			countCalc.text = String(capacity)+"/"+String(itemCount);
			itemCapacityTf.text = String(itemCount - capacity);
			timeNeed = capacity * settings.target.info.time;  
			collectBttn.count = TimeConverter.timeToCuts(timeNeed, true, true);
			collectBttn.topLayer.x = (collectBttn.bottomLayer.width - collectBttn.topLayer.width) / 2 - 30;
			
			if (capacity == itemCount) {
				plusBttn.state = Button.DISABLED;
				plusBttn10.state = Button.DISABLED;
			}
			
			minusBttn.state = Button.NORMAL;
			minusBttn10.state = Button.NORMAL;
		}
		
		public function drawItems():void
		{	
			bitmap = new Bitmap();
			if (mode == FURRY || mode == COLLECTOR || mode == FURRY_FREE || mode == FURRY_GARDENER)
			{	
				bitmap.bitmapData = settings.target.bitmap.bitmapData;
				bitmap.smoothing = true;
				
				switch (settings.info.sID) {
					case 577:
						bitmap.scaleX = bitmap.scaleY = 1;
					//case App.data.storage[App.user.worldID].techno[0]:
						//bitmap.scaleX = bitmap.scaleY = 1;
						//break;
					default:
						bitmap.scaleX = bitmap.scaleY = 0.7;
				}
				
				bitmap.x = (settings.width - bitmap.width) / 2;
				bitmap.y = 130 - bitmap.height / 2;
				bodyContainer.addChild(bitmap);
			}
			if (mode == RESOURCE)
			{
				bitmap.bitmapData = settings.target.icon.bitmapData;
				bitmap.smoothing = true;
				
				if (bitmap.height > 50)
					bitmap.scaleX = bitmap.scaleY = 0.3;
				
				bitmap.x = background2.x + (background2.width - bitmap.width) / 2 - 15;
				bitmap.y = background2.y + (background2.height - bitmap.height) / 2 + 40;
				
				layer.addChild(bitmap);
			}
		}
		
		private function drawButtons():void 
		{
			if (collectBttn != null)
			{
				bodyContainer.removeChild(collectBttn);
			}
			var timer:Bitmap = new Bitmap(Window.textures.timer, "auto", true);
			collectBttnObj = {
				title			:Locale.__e("flash:1403870467181"),
				width			:160,
				height			:53,	
				fontSize		:26,
				radius			:20,
				countText		:TimeConverter.timeToCuts(timeNeed, true, true),
				multiline		:true,
				hasDotes		:false,
				hasText2		:true,
				fontCountSize	:26,
				fontCountColor	:0xffffff,
				fontCountBorder :0x814f31,
				textAlign		: "left",	
				bgColor			:[0xf5d058, 0xeeb331],
				bevelColor		:[0xfeee7b, 0xbf7e1a],
				fontBorderColor :0x814f31,
				iconScale		:0.8,
				iconFilter		:0x814f31
			};
			
			var bttnX:int;
			var bttnY:int;
			
			collectBttn = new MixedButton2(timer, collectBttnObj);
			collectBttn.textLabel.x = (collectBttn.settings.width - collectBttn.textLabel.width) / 2;
			collectBttn.textLabel.y += 4;
				
			collectBttn.addEventListener(MouseEvent.CLICK, onCollect);
			collectBttn.x = bttnX;
			collectBttn.y = bttnY;
			
			if (mode == FURRY_GARDENER) {
				collectBttnObj['title'] = settings.bttnText;
				bttnX = 63;
				bttnY = 260;
				
				bodyContainer.addChild(collectBttn);
			
			}
			
			if (mode == RESOURCE)
			{	
				collectBttnObj.title = "";// Locale.__e('flash:1403882956073');
				timeNeed = capacity * settings.target.info.time;  
				collectBttnObj.countText = TimeConverter.timeToCuts(timeNeed, true, true);
				bttnX = 113;
				bttnY = 293;
			}
			
			
			
			if (mode == RESOURCE) {
				if (collectBttn.countLabel.textWidth <= 50) {
					collectBttn.textLabel.x = 35;
				} else
					collectBttn.textLabel.x = 10;
				
				collectBttn.textLabel.x = 25;
				collectBttn.coinsIcon.x = collectBttn.textLabel.x + collectBttn.textLabel.textWidth + 10;
				collectBttn.countLabel.x = collectBttn.coinsIcon.x + collectBttn.coinsIcon.width + 3;
				collectBttn.countLabel.y = collectBttn.textLabel.y + 1;
				collectBttn.countLabel.textWidth;
			}
			
			
			
			//if (mode == FURRY_GARDENER)
			//{
				//collectBttnObj['title'] = settings.bttnText;
				//bttnX = 63;
				//bttnY = 260;
				//
				//collectBttn.addEventListener(MouseEvent.CLICK, onCollect);
				//collectBttn.x = bttnX;
				//collectBttn.y = bttnY;
				//collectBttn.topLayer.y ;
				//collectBttn.topLayer.x = (collectBttn.bottomLayer.width - collectBttn.topLayer.width) / 2 +15;
				//bodyContainer.addChild(collectBttn);
			//}
		}
		
		
		
		private function showAnyTargets(possibleSIDs:Array = null):void {
			if (!possibleSIDs) possibleSIDs = [];
			
			possibleTargets = Map.findUnits(possibleSIDs);
			for each(var res:* in possibleTargets)
			{
				if (res.hasProduct || res.started) continue;
				res.state = res.HIGHLIGHTED;
				res.canAddWorker = true;
			}
		}
		
		/*private function showMoneyTargets():void
		{
			var possibleSIDs:Array = [];
			for (var id:* in App.data.storage) {
				if (App.data.storage[id].type == "Moneyhouse") {
					possibleSIDs.push(id);
				}
			}
			var hutTargets:Object = { };
			for each(var sID:* in hutTargets)	possibleSIDs.push(sID);
			
			possibleTargets = Map.findUnits(possibleSIDs);
			for each(var res:Moneyhouse in possibleTargets)
			{
				if (res.busy == 1 || res.hasProduct || res.colector) continue;
				res.state = res.HIGHLIGHTED;
				res.canCollector = true;
				//Moneyhouse.waitForTarget = true;
			}
		}*/
		
		/*private function showAnimalTargets():void 
		{
			var possibleSIDs:Array = [];
			for (var id:* in App.data.storage) {
				if (App.data.storage[id].type == "Animal") {
					possibleSIDs.push(id);
				}
			}
			var hutTargets:Object = { };
			for each(var sID:* in hutTargets)	possibleSIDs.push(sID);
			
			possibleTargets = Map.findUnits(possibleSIDs);
			for each(var res:Animal in possibleTargets)
			{
				if (res.cowboy) continue;
				res.state = res.HIGHLIGHTED;
				res.canAddCowboy = true;
			}
		}*/
		
		/*private function showResTargets(techno:Techno = null):void
		{
			var possibleSIDs:Array = [];
			if (techno != null) 
			{
				for (var itm:* in techno.info.targets) {
					
					possibleSIDs[itm] = techno.info.targets[itm];
				}
			}else{
				for (var id:* in App.data.storage) {
					if (App.data.storage[id].type == "Resource") {
						possibleSIDs.push(id);
					}
				}
				var hutTargets:Object = { };
				for each(var sID:* in hutTargets)	possibleSIDs.push(sID);
			}
			possibleTargets = Map.findUnits(possibleSIDs);
			for each(var res:Resource in possibleTargets)
			{
				if (res.busy == 1 || res.isTarget) continue;
				res.state = res.HIGHLIGHTED;
				Resource.isFurryTarget = true;
			}
			setTimeout(function():void {
				App.self.addEventListener(MouseEvent.CLICK, unselectPossibleTargets);
			}, 100);
		}*/
		
		private function unselectPossibleTargets(e:MouseEvent):void
		{
			if (App.self.moveCounter > 3)
				return;
			
			App.self.removeEventListener(MouseEvent.CLICK, unselectPossibleTargets);
			
			if (mode == COLLECTOR) {
			//	Moneyhouse.waitForTarget = false;
			}else if (mode == COWBOW) { 
			//	Animal.waitForTarget = false;
			}else if (mode == FURRY) {
				Factory.waitForTarget = false;
			}
			
			if (mode != FURRY_GARDENER) {
				App.ui.upPanel.hideHelp();
			}
			
			for each(var res:* in possibleTargets)
			{
				res.state = res.DEFAULT;
				if (res.hasOwnProperty('canAddCowboy')) {
					res.canAddCowboy = false;
				}
				if(res.hasOwnProperty('canCollector'))	{
					res.canCollector = false;
				}
				if (res.hasOwnProperty('canAddWorker')) {
					res.canAddWorker = false;
				}
			}
		}
		
		private function onCollect(e:MouseEvent):void 
		{
			close();
			trace(Techno.freeTechno());
		//	var workers:Array = Techno.freeTechno(); Bear.isFreeBears();
			
		var workers:Array =  Techno.freeTechno();
		
			if (mode != COWBOW &&mode != FURRY_FREE && ((workers == null || workers.length == 0) && mode != FURRY_GARDENER)){
				//App.ui.upPanel.onRobotEvent();
				return;
			}
			
			if (mode != COLLECTOR && mode != COWBOW && mode != FURRY && mode != GOLDEN_FURRY && mode != FURRY_FREE && mode != FURRY_GARDENER) 
			{
				if (!App.user.stock.take(neededResourse, priceCount))
				return;
			}
			
			if (workers == null || workers.length == 0) {
				
				new PurchaseWindow( {
				width:560,
				height:320,
				itemsOnPage:3,
				useText:true,
				//shortWindow:true,
				cookWindow:true,
				columnsNum:3,
				scaleVal:1,
				noDesc:true,
				closeAfterBuy:false,
				autoClose:false,
				description:Locale.__e('flash:1422628646880'),
				content:PurchaseWindow.createContent("Energy", {view:['slave']}),
				title:Locale.__e('flash:1422628903758'), // 
				//description:Locale.__e("flash:1382952379757"),
				popup: true
			//	find:Stock.TECHNO
				
					
			}).show();
				return;
			}
			
			if (!App.user.stock.take(Stock.COOKIE, priceCount))
				return;
				
			if (mode == FURRY) {
				//showResTargets();
				showTargets();
			}else if (mode == FURRY_GARDENER) {
				if (settings.target.workStatus == 1) // BUSY
				{
					settings.target.unbindAction();
				}else{
					showAnyTargets(settings.possibleTargets);
					showTargets();
				}
			}else{	
				var worker:Techno = workers[0];
				worker.autoEvent(settings.target, capacity);
			}
		}
		
		
		
		private var possibleTargets:Array = [];
		private var itemCount:int;
		private var countCalc:TextField;
		private var priceCalc:TextField;
		private var priceCalcSlave:TextField;
		private var priceCount:int;
		private var timeNeed:int;
		private var collectBttnObj:Object;
		private var itemCapacityTf:TextField;
		private var cookiePlusBttn:ImageButton;
		private var robotPlusBttn:ImageButton;
		
		private function showTargets():void
		{
			var txt:String;
			var widthBg:int = 250;
			
			if (mode == COLLECTOR) {
				//Moneyhouse.waitForTarget = true;
			//	Moneyhouse.collector = settings.target;
				txt = Locale.__e('flash:1409127749657');
				widthBg = 350;
			}else if (mode == COWBOW) {
				//Animal.waitForTarget = true;
				//Cowboy.cowboy = settings.target;
				//Moneyhouse.collector = settings.target;
				txt = Locale.__e('flash:1409568558009');
			}else if (mode == FURRY || mode == FURRY_FREE) {
			//	Factory.waitForTarget = true;
				txt = Locale.__e("flash:1403870467181");
			}
			App.ui.upPanel.showHelp(Locale.__e(txt), widthBg);
			
			setTimeout(function():void {
				App.self.addEventListener(MouseEvent.CLICK, unselectPossibleTargets);
			}, 100);
		}
		
		private function shopBusyFurry():void
		{
			textSettings = {
				color:0xFFFFFF,
				borderColor:0x4b2e1a,
				fontSize:32,
				textAlign:"center"
			};
			robotIcon = new Bitmap(UserInterface.textures.robotIcon);
			robotCounter = Window.drawText("-/-", textSettings);
			robotCounter.text 	=  Techno.getBusyTechno() + "/" + App.user.techno.length;
			
			layer.addChild(robotIcon);
			layer.addChild(robotCounter);
			
			
			robotIcon.x = settings.width/2 - 50;
			robotIcon.y = settings.height/2 + 85;
			
			robotCounter.x = robotIcon.x + robotIcon.width - 20;
			robotCounter.y = robotIcon.y + 7;
		}
		
		override public function drawExit():void 
		{
			super.drawExit();
			
			exit.x = settings.width - exit.width+10;
			exit.y = -5;

			if (mode == RESOURCE)
			{	
				exit.x += 50;
			}
		}
		
		//public function clearWindow():void
		//{
			//collectBttn.removeEventListener(MouseEvent.CLICK, onCollect);
			//layer.removeChild(background2);
			//layer.removeChild(robotIcon);
			//layer.removeChild(robotCounter);
			//bodyContainer.removeChild(separator);
			//bodyContainer.removeChild(separator2);
			//bodyContainer.removeChild(bitmap);
			//bodyContainer.removeChild(collectBttn);
		//}
		
		override public function dispose():void
		{
			super.dispose();
		}
	}

}