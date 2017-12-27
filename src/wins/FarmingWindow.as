package wins 
{
	import buttons.Button;
	import buttons.ImageButton;
	import buttons.MoneyButton;
	import core.Load;
	import core.Post;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import ui.Hints;
	import ui.UserInterface;
	import wins.elements.OutItem;
	public class FarmingWindow extends Window
	{
		
		public var item:Object;
		
		public var bitmap:Bitmap;
		public var title:TextField;
		public var applyBttn:Button;
		public var addJamBttn:Button;
		
		private var progressBar:ProgressBar;
		private var buyBttn:MoneyButton;
		
		private var leftTime:int;
		private var started:int;
		private var totalTime:int;
		
		private var sID:uint;
		private var formula:Object;
		private var container:Sprite;
		
		private var partList:Array = [];
		private var padding:int = 10;
		private var outItem:OutItem;
		
		private var recipeBttn:Button;
		private var openBttn:Button;
		
		private var arrowLeft:ImageButton;
		private var arrowRight:ImageButton;
		
		private var prev:int = 0;
		private var next:int = 0;
	
		public function FarmingWindow(settings:Object = null):void
		{
			if (settings == null) {
				settings = new Object();
			}
			
			settings['sID'] = settings.sID || 0;
			
			settings["width"] = 637;
			settings["height"] = 244;
			settings["popup"] = true;
			settings["fontSize"] = 30;
			settings["callback"] = settings["callback"] || null;
			settings["hasPaginator"] = false;
			
			formula = App.data.farming[settings.fID];
			sID = formula.out;
			
			settings["title"] = App.data.storage[sID].title;
			
			super(settings);
			
			if(settings.win){
				settings.win.addEventListener(WindowEvent.ON_AFTER_CLOSE, onFarmWindowClose)
				
				var crafting:Object = settings.win.settings.crafting;
				for each(var item:* in crafting) {
					if (settings.fID == item) {
						break;
					}
					prev = item;
				}
				
				for each(item in crafting) {
					if (next == -1) {
						next = item;
						break;
					}
					if (settings.fID == item) {
						next = -1;
					}
				}
			}
		}
		
		override public function drawBackground():void {
			
		}
		
		private function onFarmWindowClose(e:WindowEvent):void
		{
			close();
		}
		
		override public function drawExit():void {
			super.drawExit();
			
			exit.x = settings.width - exit.width + 12;
			exit.y = -12;
		}
		
		override public function drawBody():void {
			
			if (settings.hasDescription) settings.height += 40;
			titleLabel.y = 2;
			
			createItems();
			
			
			var backgroundWidth:int = 305;
			/*
			background = Window.backing(backgroundWidth, 190, 10, "itemBacking");
			//bodyContainer.addChildAt(background, 0);
			background.x = padding;
			background.y = 6;
			*/
			
			settings.width = padding + backgroundWidth + 155 + padding;
			
			
			var background:Bitmap = backing(settings.width, settings.height, 30, "windowBacking");
			layer.addChild(background);
			
			exit.x = settings.width - exit.width + 12;
			titleLabel.x = (settings.width - titleLabel.width) * .5;
			
			container.x = padding;
			container.y = 6;
			
			if (settings.hasDescription)
			{
				container.y = 42;
				drawDescription();
			}
			
			arrowLeft = new ImageButton(Window.textures.arrowMain, {scaleX:-0.7,scaleY:0.7});
			arrowRight = new ImageButton(Window.textures.arrowMain, {scaleX:0.7,scaleY:0.7});
			
			arrowLeft.addEventListener(MouseEvent.MOUSE_DOWN, onPrev);
			arrowRight.addEventListener(MouseEvent.MOUSE_DOWN, onNext);
			
			if(prev > 0){
				bodyContainer.addChild(arrowLeft);
				//arrowLeft.x = settings.width * 0.2;
				arrowLeft.x = settings.width / 2 - 210;
				arrowLeft.y = -6;
			}
			
			if(next > 0){
				bodyContainer.addChild(arrowRight);
				//arrowRight.x = settings.width * 0.8 - 10;
				arrowRight.x = settings.width/2 + 210 - 20;
				arrowRight.y = -6;
			}
		}
		
		private function onPrev(e:MouseEvent):void {
			close();
			new FarmingWindow( {
				fID:prev,
				win:settings.win,
				onCook:settings.win.onCookEvent,
				busy:settings.win.busy,
				capacity:settings.win.settings.target.capacity,
				hasDescription:true
			}).show();
		}
		
		private function onNext(e:MouseEvent):void {
			close();
			new FarmingWindow( {
				fID:next,
				win:settings.win,
				onCook:settings.win.onCookEvent,
				busy:settings.win.busy,
				capacity:settings.win.settings.target.capacity,
				hasDescription:true
			}).show();
		}
		
		private function drawDescription():void {
			
			var info:Object = App.data.storage[sID];
			var sprite:Sprite = new Sprite();
			
			var text1:TextField = drawText(Locale.__e("flash:1382952380091")+":", {
				fontSize:20,
				color:0x5a524c,//0x604729,//0x5a524c,
				borderColor:0xfaf1df
			});
			
			text1.width = text1.textWidth + 5;
			text1.height = text1.textHeight;
			text1.y = 4;
			
			sprite.addChild(text1);
			
			var coinIcon:Bitmap = new Bitmap(UserInterface.textures.coinsIcon);
			sprite.addChild(coinIcon);
			coinIcon.smoothing = true;
			coinIcon.x = text1.width + 2;
			coinIcon.scaleX = coinIcon.scaleY = .8;
			
			var coinsText:TextField = drawText(info.cost, {
				fontSize:22,
				color:0x604729,//0x5a524c,
				borderColor:0xfaf1df
			});
			
			coinsText.x = coinIcon.x + coinIcon.width + 2;
			coinsText.y = 2;
			coinsText.width = coinsText.textWidth + 5;
			coinsText.height = coinsText.textHeight;
			
			sprite.addChild(coinsText);
			
			if (info.hasOwnProperty('experience') && info.experience != 0)
			{
				var text2:TextField = drawText(Locale.__e("flash:1382952380092")+":", {
					fontSize:20,
					color:0x5a524c,//0x604729,//0x5a524c,
					borderColor:0xfaf1df
				});
				
				text2.width = text2.textWidth + 5;
				text2.height = text2.textHeight;
				text2.x = sprite.width + 20;
				text2.y = 4;
				
				sprite.addChild(text2);
				
				var expIcon:Bitmap = new Bitmap(UserInterface.textures.expIcon);
				sprite.addChild(expIcon);
				expIcon.smoothing = true;
				expIcon.x = text2.x + text2.width + 2;
				expIcon.scaleX = expIcon.scaleY = .7;
				
				var expText:TextField = drawText(info.experience, {
					fontSize:22,
					color:0x604729,//0x5a524c,
					borderColor:0xfaf1df
				});
				
				expText.x = expIcon.x + expIcon.width + 2;
				expText.y = 2;
				expText.width = expText.textWidth + 5;
				expText.height = expText.textHeight;
				
				sprite.addChild(expText);
			}	
			
			bodyContainer.addChild(sprite);
			
			sprite.x = (settings.width- sprite.width)/2;
			sprite.y = 10;
		}
		
		private function getTitle(title:String):TextField{
			var label:TextField = Window.drawText(title, {
				color:0x6d4b15,
				borderColor:0xfcf6e4,
				textAlign:"center",
				autoSize:"center",
				fontSize:22,
				multiline:true
			});
			label.wordWrap = true;
			return label;
		}
		
		public function drawOpenBttn(sprite:Sprite):void {
			
			var item:Object = App.data.storage[formula.plant];
			
			var icon:Bitmap;
			var settings:Object = { 
				fontSize:22, 
				autoSize:"left",
				color:0xA3D637,
				borderColor:0x38510D
			};
			
			var bttnSettings:Object = {
				caption:Locale.__e("flash:1382952379890"),
				fontSize:22,
				bgColor: [0xA9DC3C, 0x96C52E],
				borderColor : [0xf8f2bd, 0x836a07],
				fontColor : 0x4E6E16,
				fontBorderColor : 0xDCFA9B,
				width:94,
				height:30,
				shadow:true
			};
			
			var open:TextField = Window.drawText(Locale.__e("flash:1382952380083"), {
				color:0x4A401F,
				borderSize:0,
				fontSize:18,
				autoSize:"left"
			});
			sprite.addChild(open);
			open.x = 15;
			open.y = 20;
			
			icon = new Bitmap(UserInterface.textures.fantsIcon,"auto",true);
			icon.scaleX = icon.scaleY = 0.7;
				
			icon.x = open.x + open.width + 2;
			icon.y = 18;

			sprite.addChild(icon);
			
			var count:TextField = Window.drawText(String(item.unlock.price),settings);
			sprite.addChild(count);
			count.x = icon.x + icon.width + 2;
			count.y = 20;
			
			var needed:TextField = Window.drawText(Locale.__e("flash:1382952380085",[item.unlock.level]), {
				color:0xbf1a22,
				fontSize:16,
				borderColor:0xfcf5e5,
				textAlign:"center",
				borderSize:6
			});
			
			needed.width = 150;
			needed.height = needed.textHeight;
			sprite.addChild(needed);
			needed.x = 0;
			needed.y = 0;
			
			openBttn = new Button(bttnSettings);
			sprite.addChild(openBttn);
			openBttn.x = 26;
			openBttn.y = 46;
						
			openBttn.addEventListener(MouseEvent.CLICK, onOpenEvent);
		}
		
		private function onOpenEvent(e:MouseEvent):void {
			var item:Object = App.data.storage[formula.plant];
			
			if(App.user.stock.take(Stock.FANT, item.unlock.price)){
				Post.send( {
					ctr:'user',
					act:'open',
					uID:App.user.id,
					sID:formula.plant
				}, function(error:*, data:*, params:*):void {
					if (!error) {
						
						App.user.shop[formula.plant] = 1;
						
						priceSprite.visible = true;
						openSprite.visible = false;
								
						settings.capacity = settings.win.settings.target.capacity;
				
						if (formula.spoons <= settings.capacity) {
							if (!settings.win.busy) {
								recipeBttn.state = Button.NORMAL;
							}
						}					
					}
				});
			}
			
		}
		
		public function drawCount(sprite:Sprite):void
		{
			var textColor:uint = 0xffdc39;
			settings['have'] = true;
			if(formula.spoons > settings.capacity){
				textColor = 0xee9177;
				settings.have = false;
			}
			
			var count_txt:TextField = Window.drawText(String(settings.capacity),{
				fontSize		:24,
				color			:textColor,
				borderColor		:0x6d4b15,
				autoSize:"left"
			});
										
			var vs_txt:TextField = Window.drawText(" "+Locale.__e("flash:1382952379993")+" ",{
				fontSize		:18,
				color			:textColor,
				borderColor		:0x6d4b15,
				autoSize:"left"
			});
										
			var need_txt:TextField = Window.drawText(String(formula.spoons),{
				fontSize		:24,
				color			:textColor,
				borderColor		:0x6d4b15,
				autoSize:"left"
			});						
						
			sprite.addChild(count_txt)							
			sprite.addChild(vs_txt)							
			sprite.addChild(need_txt)							
			
			count_txt.x = 0;
			count_txt.y = 0;
			vs_txt.x = count_txt.x + count_txt.textWidth;
			vs_txt.y = count_txt.y + 3;
			need_txt.x = vs_txt.x + vs_txt.textWidth;
			need_txt.y = count_txt.y;
			
			if (formula.spoons > settings.capacity) {
				
			
				addJamBttn = new Button( {
					caption:Locale.__e("flash:1382952380093"),
					width:110,
					fontSize:22,
					height:28,
					borderColor:			[0xf3a9b3,0x550f16],
					fontColor:				0xe6dace,
					fontBorderColor:		0x550f16,
					bgColor:				[0xbf3245,0x761925]
				});
				
				sprite.addChild(addJamBttn);
				
				addJamBttn.x = -38;
				addJamBttn.y = need_txt.y + 28;
				
				addJamBttn.addEventListener(MouseEvent.CLICK, settings.win.onAddJamEvent);
				
			}
			
		}
		
		private var priceSprite:Sprite;
		private var openSprite:Sprite;
		private var countSprite:Sprite = new Sprite();
		private var bg2:Bitmap;
		private function createItems():void
		{
			container = new Sprite();
			
			var offsetX:int = 0;
			var offsetY:int = 0;
			var dX:int = 5;
			
			var pluses:Array = [];
			
			var count:int = 0;
					
			var bg:Bitmap = Window.backing(150, 190, 10, "itemBacking");
			container.addChild(bg);
			
			var plantLayer:LayerX = new LayerX();
			var plantBitmap:Bitmap = new Bitmap();
			plantLayer.addChild(plantBitmap);
			container.addChild(plantLayer);
			
			plantLayer.tip = function():Object {
				return {
					title:App.data.storage[sID].title,
					text:App.data.storage[sID].text
				}
			}
			
			bg.x = offsetX;
			bg.y = offsetY;
			
			var plant:Object = App.data.storage[formula.plant];
			
			var title:TextField = getTitle(plant.title);
			title.x = bg.x + (bg.width - title.width) / 2;
			title.y = 10;
			container.addChild(title);
			
			priceSprite = new Sprite();
			container.addChild(priceSprite);
			
			var countLabel:TextField = Window.drawText("3",{
				fontSize		:24,
				color			:0xffdc39,
				borderColor		:0x6d4b15,
				autoSize:"left"
			});
			priceSprite.addChild(countLabel);
			
			var labelX:TextField = Window.drawText(" X ",{
				fontSize		:16,
				color			:0xffdc39,
				borderColor		:0x6d4b15,
				autoSize:"left"
			});
			labelX.x = countLabel.x + 12;
			labelX.y = countLabel.y + 4;
			priceSprite.addChild(labelX);
			
			var coins:Bitmap = new Bitmap(UserInterface.textures.coinsIcon, "auto", true);
			priceSprite.addChild(coins);
			coins.x = labelX.x + 25;
			coins.y = labelX.y - 4;
			coins.scaleX = coins.scaleY = 0.7;
			
			var priceLabel:TextField = Window.drawText(String(plant.coins*3),{
				fontSize		:24,
				color			:0xffdc39,
				borderColor		:0x6d4b15,
				autoSize:"left"
			});
			priceLabel.x = coins.x + 30;
			priceLabel.y = countLabel.y;
			priceSprite.addChild(priceLabel);
			
			priceSprite.x = bg.x + (bg.width - priceSprite.width) / 2;
			priceSprite.y = bg.y + bg.height - 40;
			
			openSprite = new Sprite();
			
			drawOpenBttn(openSprite);
			container.addChild(openSprite);
			openSprite.x = bg.x + (bg.width - openSprite.width) / 2;
			openSprite.y = bg.y + bg.height - 60;
					
			
			Load.loading(Config.getIcon(plant.type, plant.preview), function(data:*):void {
				plantBitmap.bitmapData = data.bitmapData;
				plantBitmap.x = bg.x + (bg.width - plantBitmap.width) / 2;
				plantBitmap.y = bg.y + (bg.height - plantBitmap.height) / 2;
			});
			
			
			//////2-st///////
			offsetX += bg.width + dX;
			
			bg2 = Window.backing(150, 190, 10, "itemBacking");
			container.addChild(bg2);
			
			var spoonLayer:LayerX = new LayerX();
			var spoonBitmap:Bitmap = new Bitmap();
			spoonLayer.addChild(spoonBitmap);
			container.addChild(spoonLayer);
			spoonLayer.tip = function():Object {
				return {
					//title:App.data.storage[sID].title,
					text:Locale.__e("flash:1382952380094")
				}
			}
			
			bg2.x = offsetX;
			bg2.y = offsetY;
			
			//var plant:Object = App.data.storage[formula.plant];
			
			title = getTitle(Locale.__e("flash:1383041504207"));
			title.x = bg2.x + (bg2.width - title.width) / 2;
			title.y = 10;
			container.addChild(title);
			
			
			drawCount(countSprite);
			settings.win.addEventListener(WindowEvent.ON_CONTENT_UPDATE, onContentUpdate);
			
			
			if (formula.spoons > settings.capacity) {
				countSprite.y = bg2.y + bg2.height - 50;
			}else {
				countSprite.y = bg2.y + bg2.height - 40;
			}
			countSprite.x = bg2.x + (bg2.width) / 2 - 19;
			container.addChild(countSprite);
			
			Load.loading(Config.getIcon('Material', 'spoon'), function(data:*):void {
				spoonBitmap.bitmapData = data.bitmapData;
				spoonBitmap.x = bg2.x + (bg.width - spoonBitmap.width) / 2;
				spoonBitmap.y = bg2.y + (bg.height - spoonBitmap.height) / 2;
			});
			
			
			var plus:Bitmap = new Bitmap(Window.textures.plus);
			container.addChild(plus);
			plus.x = offsetX - plus.width / 2 - 3;
			plus.y = bg.height / 2 - plus.height/2;
				
			
			offsetX += bg2.width + dX;
			
		
			////////Out/////////
			var bgOut:Bitmap = Window.backing(150, 190, 10, "itemBacking");
			container.addChild(bgOut);
			
			var outBitmap:Bitmap = new Bitmap();
			container.addChild(outBitmap);
			
			bgOut.x = offsetX;
			bgOut.y = offsetY;
			
			var out:Object = App.data.storage[formula.out];
			
			title = getTitle(out.title);
			title.x = bgOut.x + (bgOut.width - title.width) / 2;
			title.y = 10;
			container.addChild(title);
					
			Load.loading(Config.getIcon(out.type, out.preview), function(data:*):void {
				outBitmap.bitmapData = data.bitmapData;
				outBitmap.x = bgOut.x + (bgOut.width - outBitmap.width) / 2;
				outBitmap.y = bgOut.y + (bgOut.height - outBitmap.height) / 2;
			});			
			
			var icon:Bitmap = new Bitmap(Window.textures.iconTime);
			container.addChild(icon);
			
			icon.x = bgOut.x + 50;
			icon.y = bgOut.height - 50;
			
			var time:int = plant.levels * plant.levelTime;
			
			var timeText:TextField = Window.drawText(TimeConverter.timeToCuts(time), {
				fontSize:18,
				color:0x4d3921,
				borderColor:0xfcf6e4
			});
			timeText.x = icon.x + icon.width + 3;
			timeText.y = icon.y + 2;
			container.addChild(timeText);
			
			recipeBttn = new Button( {
				caption:Locale.__e("flash:1382952380097"),
				width:110,
				fontSize:26,
				height:36
			});
			
			container.addChild(recipeBttn);
			recipeBttn.x = bgOut.x + (bgOut.width - recipeBttn.width) / 2;
			recipeBttn.y = bgOut.height - recipeBttn.height / 2 - 4;
			
			recipeBttn.addEventListener(MouseEvent.CLICK, onCook)
			
			if(plant.unlock.level > App.user.level && App.user.shop[formula.plant] == undefined){
				priceSprite.visible = false;
				openSprite.visible = true;
				recipeBttn.state = Button.DISABLED;
			}else {
				priceSprite.visible = true;
				openSprite.visible = false;
			}
			
			
			
			if (settings.win.busy || !settings.have) {
				recipeBttn.state = Button.DISABLED;
			}
		
			var equality:Bitmap = new Bitmap(Window.textures.equality);
			container.addChild(equality);
			equality.x = bgOut.x - equality.width / 2 - 2;
			equality.y = bgOut.height / 2 - equality.height/2;
			
			bodyContainer.addChild(container);
			container.x = 10;
			container.y = 10;
			
		}
		
		private function onContentUpdate(e:WindowEvent):void{
			var plant:Object = App.data.storage[formula.plant];
			
			if (container.contains(countSprite)){
				container.removeChild(countSprite);
			}
			
			settings.capacity = settings.win.settings.target.capacity;
			
			countSprite = new Sprite();
			drawCount(countSprite);
			if (formula.spoons > settings.capacity) {
				countSprite.y = bg2.y + bg2.height - 50;
			}else {
				countSprite.y = bg2.y + bg2.height - 40;
				if (!settings.win.busy) {
					recipeBttn.state = Button.NORMAL;
				}else{
					recipeBttn.state = Button.DISABLED;
				}
			}
			
			if(plant.unlock.level <= App.user.level || App.user.shop[formula.plant] != undefined){
				if (recipeBttn.mode == Button.DISABLED && !settings.win.busy) {
					recipeBttn.state = Button.NORMAL;
				}
			}else {
				recipeBttn.state = Button.DISABLED;
			}
			
			countSprite.x = bg2.x + (bg2.width) / 2 - 19;
			container.addChild(countSprite);
		}
		
		private function onCook(e:MouseEvent):void
		{
			// TODO Обьяснять причину 
			if (openSprite.visible) {
				App.ui.flashGlowing(openBttn, 0xFFFF00);
				Hints.text(Locale.__e("flash:1382952380098"), Hints.TEXT_RED, new Point(mouseX, mouseY), false, App.self.tipsContainer);
				return;
			}
			
			if (settings.busy) {
				App.ui.flashGlowing(settings.win.progressBacking, 0xFFFF00);
				Hints.text(Locale.__e("flash:1382952380099"), Hints.TEXT_RED, new Point(mouseX, mouseY), false, App.self.tipsContainer);
			}
			if(!settings.busy && !settings.have) Hints.text(Locale.__e("flash:1382952380100"), Hints.TEXT_RED, new Point(mouseX, mouseY), false, App.self.tipsContainer);
			if (e.currentTarget.mode == Button.DISABLED) return;
			settings.onCook(settings.fID);
			close();
		}
		
		override public function dispose():void
		{
			if(settings.win)
				settings.win.removeEventListener(WindowEvent.ON_AFTER_CLOSE, onFarmWindowClose);
			super.dispose();
		}
	
	}		

}


