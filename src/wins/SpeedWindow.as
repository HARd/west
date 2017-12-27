package wins 
{
	import buttons.Button;
	import buttons.MoneyButton;
	import core.Load;
	import core.Numbers;
	import core.Size;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.text.TextField;
	import units.Changeable;
	/**
	 * ...
	 * @author ...
	 */
	public class SpeedWindow extends Window
	{
		public var boostBttn:MoneyButton;
		public var updateBttn:Button;
		
		private var progressBar:ProgressBar;
		private var finishTime:int;
		private var leftTime:int;
		private var isBoost:Boolean;
		private var timer:TextField;
		private var totalTime:int;
		private var priceSpeed:int = 0;
		private var priceBttn:int = 0;
		private var priceKoef:int;
		protected var count:int;
		
		public function SpeedWindow(settings:Object = null) 
		{
			settings["width"] = settings.width || 540;
			settings["height"] = settings.height || 330;
			settings["fontSize"] = 48,
			settings["hasPaginator"] = false;
			settings['background'] = 'alertBacking';
			settings['shadowColor'] = 0x513f35;
			settings['shadowSize'] = 4;
			
			if (App.lang == 'jp')
				settings.height = 380;
			
			if (App.user.worldID == Travel.SAN_MANSANO) {
				settings['background'] = 'goldBacking';
			}
			
			if (settings.hasOwnProperty('picture')) {
				settings["width"] = 800;
				settings["height"] = 685;
				
				settings['picture'] = settings.picture;
			}
			
			count = settings.hasOwnProperty('count') ? settings.count : 1;
			finishTime = settings.finishTime;
			totalTime = settings.totalTime;
			
			super(settings);
			
			priceSpeed = settings['priceSpeed'];
		}
		
		private function progress():void
		{
			leftTime = finishTime - App.time;
			
			if (leftTime <= 0) {
				if (settings['noTimer']) return;
				leftTime = 0;
				App.self.setOffTimer(progress);
				close();
			}
		
			timer.text = TimeConverter.timeToStr(leftTime);
			if (progressBar.timer) progressBar.time = leftTime;
			var percent:Number = (totalTime - leftTime) / totalTime;
			progressBar.progress = percent;
		}
		
		private var iconTarget:Bitmap = new Bitmap();
		override public function drawBody():void 
		{
			titleLabel.y = 0;
			if (App.user.worldID == Travel.SAN_MANSANO) {
				exit.x += 15;
				exit.y -= 15;
			}
				
			var itm:Object = App.data.storage[settings.target.sid];
			Load.loading(Config.getIcon(itm.type, itm.preview), onPreviewComplete);
			
			bodyContainer.addChildAt(iconTarget, 0);
			
			var multiLabel:TextField = Window.drawText('', {
				fontSize:32,
				color:0xfecb00,
				borderColor:0x7f622f,
				textAlign:"right",
				width:background.width 
			});
			multiLabel.x = background.x + background.width - multiLabel.width - 40;
			multiLabel.y = background.y + background.height - multiLabel.height - 30;
			bodyContainer.addChild(multiLabel);
			
			if (settings.hasOwnProperty('count') && count > 1) {
				multiLabel.text = 'x' + String(count);
				multiLabel.visible = true;
			}else{
				multiLabel.visible = false;
			}
			
			if (settings.zoneID) {
				var icon:Bitmap = new Bitmap();
				bodyContainer.addChild(icon);
				if (settings.zoneID) {
					Load.loading(Config.getIcon(App.data.storage[settings.zoneID].type, App.data.storage[settings.zoneID].preview), function(data:Bitmap):void
					{
						icon.bitmapData = data.bitmapData;
						icon.x = -30;
						icon.y = -50;
					});
				}
				
				var zoneItem:Object = App.data.storage[settings.target.sid];	
				var treasure:Object = App.data.treasures[zoneItem.shake][zoneItem.shake];
				var i:int;
				var desc:String = Locale.__e('flash:1382952380034') + ' ';
				for (i = 0; i < treasure.item.length; i++ ) {
					desc += App.data.storage[treasure.item[i]].title;
					if (i < treasure.item.length - 1) desc += ', ';
				}
				
				if (treasure.hasOwnProperty('randomMaterial')) {
					desc += ', ';
					i = 0;
					for (var s:* in treasure.randomMaterial) {
						i++;
						desc += App.data.storage[s].title;
						if (i < Numbers.countProps(treasure.randomMaterial)) desc += ' ' + Locale.__e('flash:1475664696458') + ' ';
					}
				}
				
				var text:TextField = Window.drawText(desc, {
					fontSize:      28,
					color:         0xffffff,
					borderColor:   0x6d460f,
					textLeading:   -2,
					width:         320,
					textAlign:     "center",
					wrap:          true,
					multiline:     true
				});
				text.x = (settings.width - text.width ) / 2;
				text.y = titleLabel.y + 30;
				bodyContainer.addChild(text);
			}
			
			timer = Window.drawText(TimeConverter.timeToStr(127), {
				color:			0xffffff,
				borderColor:	0x6d460f,
				fontSize:		34
			});
			timer.x = settings.width / 2 - 50;
			if (settings.zoneID) timer.y = text.y + text.height + 5;
			else if (settings.target.sid == 2416)
				timer.y = titleLabel.y + 50;
			else timer.y = titleLabel.y + 25;
			timer.width = timer.textWidth + 10;
			timer.height = timer.textHeight;
			//bodyContainer.addChild(timer);
			
			var progressBacking:Bitmap = Window.backingShort(380, "progBarBacking");
			progressBacking.x = (settings.width - progressBacking.width) / 2;
			progressBacking.y = timer.y + timer.height - 3;
			bodyContainer.addChild(progressBacking);
			
			//if (settings.target.info.type == 'Tribute') {
				progressBar = new ProgressBar({win:this, width:383, isTimer:true});
			//} else {
				//progressBar = new ProgressBar( { win:this, width:383, isTimer:false } );
			//}
			progressBar.x = (settings.width - 380) / 2 - 8;
			progressBar.y = progressBacking.y - 4;
			bodyContainer.addChild(progressBar);
			progressBar.visible = true;
			
			var separator:Bitmap = Window.backingShort(settings.width - 130, 'dividerLine', false);
			separator.x = (settings.width - separator.width) / 2;
			separator.y = progressBacking.y - 25;
			separator.alpha = 0.5;
			bodyContainer.addChild(separator);
			
			var separator2:Bitmap = Window.backingShort(settings.width - 130, 'dividerLine', false);
			//separator2.scaleY = -1;
			separator2.x = (settings.width - separator2.width) / 2;;
			separator2.y = progressBacking.y + progressBacking.height - 4 + 25;
			separator2.alpha = 0.5;
			bodyContainer.addChild(separator2);
			
			bodyContainer.addChild(timer);
			
			progress();
			App.self.setOnTimer(progress);
			
			progressBar.start();
			
			if (App.user.quests.tutorial) {
				priceSpeed = 0;
			}
			
			var bttnWidth:int = 192;
			
			var bttnContainer:Sprite = new Sprite();
			bodyContainer.addChild(bttnContainer);
			
			//if (settings.target.info.type == 'Tribute') {
				progressBacking.y += 60;
				progressBar.y += 60;
				separator2.y -= 25;
				timer.visible = false;				
				
				var bg:Bitmap = Window.backing(settings.width - 130, separator2.y - separator.y - separator.height, 50, 'fadeOutWhite');
				bg.x = separator.x;
				bg.y = separator.y + separator.height;
				bg.alpha = 0.4;
				bodyContainer.addChild(bg);
				
				var txt:TextField = drawText(Locale.__e('flash:1474293101330'), {
					color:0x79381a,
					borderColor:0xffffff,
					fontSize:27,
					width:settings.width - 200,
					textAlign:'center'
				});
				txt.x = 100;
				txt.y = bg.y + (bg.height - txt.textHeight) / 2;
				bodyContainer.addChild(txt);
			//}
			
			if (settings.target.hasOwnProperty('componentable') && settings.target.componentable)
				return;
				
			if (settings.target.sid == 2416)
				return;
				
			if (settings.upgrade && (settings.upgrade is Function)) {
				updateBttn = new Button( {
					caption:		Locale.__e('flash:1393580216438'),
					width:			bttnWidth,
					height:			56
				});
				updateBttn.addEventListener(MouseEvent.CLICK, onUpgradeEvent);
				bttnContainer.addChild(updateBttn);
				App.ui.staticGlow(updateBttn, { alpha:1, color:0xf7e61b, strength:50, power:3 } );
			}
				
			boostBttn = new MoneyButton( {
				caption: (settings['count'] && count > 1) ? Locale.__e('flash:1463992396751') : Locale.__e("flash:1382952380104"),
				countText:String(priceSpeed * count),
				width:bttnWidth,
				height:56,
				fontSize:30,
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
			});
			//boostBttn.x = (settings.width - boostBttn.width)/2;
			//boostBttn.y = settings.height - boostBttn.height - 40;
			//boostBttn.countLabel.width = boostBttn.countLabel.textWidth + 5;
			//bodyContainer.addChild(boostBttn);
			
			boostBttn.x = bttnContainer.numChildren * (bttnWidth + 10);
			boostBttn.countLabel.width = boostBttn.countLabel.textWidth + 5;
			bttnContainer.addChild(boostBttn);
			boostBttn.addEventListener(MouseEvent.CLICK, onBoostEvent);
			
			bttnContainer.x = settings.width * 0.5 - bttnContainer.width * 0.5;
			bttnContainer.y = settings.height - bttnContainer.height - 27;
			
			if (settings.hasOwnProperty('picture') && settings.picture) {
				var image:Bitmap = new Bitmap();
				bodyContainer.addChild(image);
				
				Load.loading(settings.picture, function(data:*):void {
					image.bitmapData = data.bitmapData;
					
					image.x = (settings.width - image.width) / 2;
					image.y = 35;
					
					timer.y = image.y + image.height + 20;
					progressBacking.y = timer.y + timer.height + 3;
					progressBar.y = progressBacking.y - 4;
					separator.y = progressBacking.y - 25;
					separator2.y = progressBacking.y + progressBacking.height - 4 + 25;
					
					boostBttn.y -= 40;
				});
			}
			
			if (settings.target.info.type == 'Golden' && settings.target.info.hasOwnProperty('capacity') && settings.target.info.capacity != 0 && settings.target.info.capacity != '') {
				var capacityTxt:TextField = drawText(String(settings.target.info.capacity - settings.target.capacity) + ' ' + Locale.__e('flash:1475676799016') + ' ' + settings.target.info.capacity, {
					color:0x79381a,
					borderColor:0xffffff,
					fontSize:27,
					width:settings.width - 200,
					textAlign:'center'
				});
				capacityTxt.x = 230;
				capacityTxt.y = progressBacking.y + (progressBacking.height - capacityTxt.textHeight) / 2;
				bodyContainer.addChild(capacityTxt);
			}
		}
		
		private function onPreviewComplete(data:Bitmap):void 
		{
			iconTarget.bitmapData = data.bitmapData;
			Size.size(iconTarget, 120, 120); 
			iconTarget.x = settings.width / 2 - iconTarget.width / 4 - 15;
			iconTarget.y = - iconTarget.height / 2 - 45;
			//iconTarget.scaleX = iconTarget.scaleY = 0.5;
			iconTarget.smoothing = true;
		}
		
		private function onBoostEvent(e:MouseEvent = null):void
		{
			if (priceBttn == 0) priceBttn = priceSpeed * count;
			
			if (settings.doBoost)
				settings.doBoost(priceBttn);
			else
				//settings.target.acselereatEvent(priceBttn);
				settings.target.onBoostEvent();
			close();
		}
		
		private function onUpgradeEvent(e:MouseEvent):void {
			close();
			settings.upgrade();
		}
		
		override public function dispose():void
		{
			if(progressBar)progressBar.dispose();
			progressBar = null;
			if(boostBttn)boostBttn.removeEventListener(MouseEvent.CLICK, onBoostEvent);
			boostBttn = null;
			App.self.setOffTimer(progress);
			super.dispose();
		}
	}
}