package wins.elements 
{

	import buttons.Button;
	import buttons.ImageButton;
	import com.greensock.*; 
	import com.greensock.easing.*;
	import com.greensock.TweenLite;
	import com.greensock.TweenMax;
	import core.Load;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import flash.utils.setTimeout;
	import ui.UserInterface;
	import wins.ProductionFieldWindow;
	import wins.RecipeAnimalWindow;
	import wins.Window;
	import wins.RecipeWindow;
	import wins.WindowEvent;
	
	//Вспомогательный класс
	public class ProductionFieldItem extends LayerX{
		
		public var background:Bitmap = null;
		public var bitmap:Bitmap = null;
		public var itemIcon:ImageButton;
		public var sID:String;
		public var fID:int;
		public var recipe:Object;
		public var count:uint;
		
		public var canRotate:Boolean = true;
		
		public var title:TextField = null;
		public var timeText:TextField = null;
		public var requestText:TextField = null;
		public var recipeBttn:Button;
		public var progressBar:Sprite;
		public var icon:Bitmap;
		protected var win:*
		private var productionFieldWindow:ProductionFieldWindow;
		
		private var tween:TweenMax;
		
		public var sprTip:LayerX = new LayerX();
		
		
		private var settings:Object = {
			width:170,
			height:206,
			recipeBttnMarginY:-28,
			//recipeBttnHasDotes:true,
			
			titleColor:0x814f31,
			
			timeColor:0xffffff,
			timeBorderColor:0x764a3e, 
			
			timeMarginY:-24,
			timeMarginX: -3
		};
		
		private var testFlag:Boolean = true;
		
		public function ProductionFieldItem(win:*, _settings:Object = null)
		{
			for (var item:* in _settings) {
				settings[item] = _settings[item];
			}
			addEventListener(MouseEvent.MOUSE_OVER, onMouseOverHandler);
			addEventListener(MouseEvent.MOUSE_OUT, onMouseOutHandler);
			this.win = win;
			productionFieldWindow = win;
			background = new Bitmap(Window.textures.buildingsActiveBacking);
			background.smoothing = true;
			addChild(background);
			
			//fieldArrow = new blueArrow();
			//fieldArrow.alpha = 0;
			
			//backgroundOff = Window.backing(settings.width, settings.height, 40, "itemBackingOff");
			//addChild(backgroundOff);
			//backgroundOff.visible = false;
			if (contains(sprTip)) {
				removeChild(sprTip);
				sprTip = new LayerX();
			}
			bitmap = new Bitmap();
			//sprTip.addChild(bitmap);
			bitmap.y = 10;
			addChild(sprTip);
			title = Window.drawText("", {
				fontSize:22,
				color:settings.titleColor,
				borderColor:0xfcf6e4,
				multiline:true,
				textAlign:"center",
				autoSize:"center"
			});
			settings;
			sprTip.tip = function():Object {
				return {
					title:App.data.storage[sID].title,
					text:App.data.storage[sID].text
				}
			}
			
			//addChild(title);
			title.wordWrap = true;
			
			title.width = background.width - 30;
			title.y = 8;
			
			addTime();
		}

		private function onMouseOverHandler(e:MouseEvent = null):void 
		{
			removeStaff();
			
			addStaff();
		}
		
		public function onMouseOutHandler(e:MouseEvent = null):void 
		{
			removeStaff();
		}
		
		private function addStaff():void 
		{
			fieldArrow = new blueArrow();
			fieldArrow.mouseEnabled = false;
			fieldArrow.alpha = 0;
			if (testFlag) 
			{	
				if (fieldArrow != null)
				{
					this.parent.parent.addChild(fieldArrow);
					TweenLite.to(fieldArrow, 0.5, { alpha:1, ease:Bounce.easeInOut } );
					fieldArrow.scaleY = -1;
					fieldArrow.x = 50;
					fieldArrow.y = 20;
				}
			}
			productTitle = Window.drawText(App.data.storage[sID].title, {
				fontSize:26,
				multiline:true,
				textLeading: -12,
				textAlign:"center",
				wrap:true,
				multiline:true,
				width:110,
				color:0xffffff,
				borderColor:0x774702
			});
				
			if (productTitle != null)
			{
				parent.addChild(productTitle);
				TweenLite.to(productTitle, 0.5, { alpha:1, ease:Bounce.easeInOut } );
				productTitle.x = -55;
				productTitle.y = -65;
			}
		}
		
		private function removeStaff():void 
		{
			if (fieldArrow && fieldArrow.parent) 
			{
				fieldArrow.parent.removeChild(fieldArrow);
				fieldArrow = null;
				fieldArrow = null;
			}
			if (productTitle) 
			{
				if(productTitle.parent)
					productTitle.parent.removeChild(productTitle);
				productTitle = null;
			}
		}
		private function drawCloseItem(lvlNeed:int):void 
		{
			background.bitmapData = Window.textures.buildingsLockedBacking;
			background.smoothing = true;
				
			var lock:Bitmap = new Bitmap(Window.textures.lock);
				lock.smoothing = true;
				lock.x = (background.width - lock.width) / 2;
				lock.y = background.height - lock.height / 2 - 6;
				addChild(lock);
			
			var upArrow:Bitmap = new Bitmap(Window.textures.upgradeArrow);
				upArrow.smoothing = true;
				upArrow.scaleX = upArrow.scaleY = .5;
				upArrow.x = (background.width - lock.width) / 2 + 8;
				upArrow.y = background.height - lock.height / 2 + 16;
				addChild(upArrow);
			
			requestText = Window.drawText(Locale.__e(/*"flash:1400851737141", [*/String(lvlNeed)/*]*/), {
				fontSize:22,
				color:0xfcf6e4,
				borderColor:0x4c3f36,
				multiline:true,
				textAlign:"center",
				wrap:true,
				width:background.width - 20
			});
			addChild(requestText);
			
			requestText.x = lock.x + (lock.width - requestText.width) / 2 + 8;
			requestText.y = lock.y + lock.height - requestText.textHeight - 10;
		}
		
		private function removeReqTekst():void
		{
			if (!requestText) return;
			
			if (requestText.parent) requestText.parent.removeChild(requestText);
			requestText = null;
		}
		
		private function addTime():void 
		{
			//icon = new Bitmap(Window.textures.timerBrown);
			//addChild(icon);
			
			
			//timeText = Window.drawText("", {
				//fontSize:20,
				//color:settings.timeColor,
				//borderColor:settings.timeBorderColor
			//});
			//addChild(timeText);
			
			//icon.x = 40 + settings.timeMarginX;
			//icon.y = background.height - 59 + settings.timeMarginY;
			
			//timeText.x = icon.x + icon.width + 3;
			//timeText.y = icon.y + 6;
			
			
			
			//recipeBttn = new Button( {
				//caption:Locale.__e("flash:1382952380065"),
				//width:110,
				//fontSize:26,
				//hasDotes:false,
				//height:36
			//});
			//
			//addChild(recipeBttn);
			//recipeBttn.x = (background.width - recipeBttn.width) / 2;
			//recipeBttn.y = background.height - recipeBttn.height / 2 - 4 + settings.recipeBttnMarginY;
			
			//recipeBttn.addEventListener(MouseEvent.CLICK, onRecipeBttnClick);
		}
		
		public var recWin:RecipeWindow;
		public var recAnimalWin:RecipeAnimalWindow;
		protected function onRecipeBttnClick(e:MouseEvent):void
		{
			if (App.data.storage[sID].type == "Animal") 
			{
				openRecipeAnimalWindow();
			}else
			{
				removeStaff();
				hideGlowing();
				
				win.onCookEvent(fID);
				
				win.close();
				
				
				//win.settings.onCraftAction(fID)
			}			
		}
		private function openRecipeWindow():void
		{
			recWin = new RecipeWindow( {
				title:Locale.__e("flash:1382952380065")+':',
				fID:fID,
				onCook:win.onCookEvent,
				busy:win.busy,
				win:win,
				hasDescription:true,
				craftData:settings.craftData,
				dontCheckTechno:win.settings.target.dontCheckTechno(),
				prodItem:this
				});// .show();
				recWin.show();
		}
		
		private function openRecipeAnimalWindow():void
		{
			recAnimalWin = new RecipeAnimalWindow( {
				title:Locale.__e("flash:1382952380065")+':',
				fID:fID,
				onCook:win.onCookEvent,
				busy:win.busy,
				win:win,
				hasDescription:true,
				craftData:settings.craftData,
				dontCheckTechno:win.settings.target.dontCheckTechno(),
				prodItem:this
				});// .show();
				recAnimalWin.show();
		}
		private var preloader:Preloader = new Preloader();
		
		public function change(fID:*, lvlNeed:int = 0, isHelp:Boolean = false):void
		{
			dispose();
			
			this.sID 		= fID;
			this.fID 		= int(fID);
			this.count 		= 1;
			//this.recipe 	= items;
			
			title.text = App.data.storage[sID].title;
			title.x = (background.width - title.width) / 2;
			
			if (lvlNeed > settings.level) {   // переделать
				testFlag = false;  // just for test
			}
			else testFlag = true;
			
			bitmap.bitmapData = null;
			
			addChild(preloader);
			preloader.x = (background.width)/ 2;
			preloader.y = (background.height)/ 2 - 5;
		
			var test:*;
			for (var test2:* in App.data.storage[sID].outs) 
			{
				break;
			}
			if (win.settings.target.sid == 159)
				test2 = sID;
			
			Load.loading(Config.getIcon(App.data.storage[test2].type, App.data.storage[test2].preview), onPreviewComplete);
			//timeText.text = TimeConverter.timeToCuts(formula.time, true, true);
			//timeText.height = timeText.textHeight + 6;
			
			if (!testFlag) {
				
				drawCloseItem(lvlNeed);
				//requestText.visible = true;
			}else {
				
				removeReqTekst();
				
			}
			
			var info:Object = App.data.storage[sID];
			
			sprTip.tip = function():Object {
				return {
					title: info.title,
					text: info.description
				};
			}
			
/*			if (Quests.help) {
				var qID:int = App.user.quests.currentQID;
				var mID:int = App.user.quests.currentMID;
				var targets:Object = App.data.quests[qID].missions[mID].target;
				for each(var sid:* in targets){
					if(this.sID == sid){
						stopGlowing = false;
						glowing();
					}
				}
			}*/
			if (App.user.quests.tutorial) {
				var qID:int = App.user.quests.currentQID;
				var mID:int = App.user.quests.currentMID;
				if (qID == 87 && mID == 1) {
					if (QuestsRules.quest87_1)
						return;
					QuestsRules.quest87_1 = true;
				var targets:Object = App.data.quests[qID].missions[mID].target;
					for each(var sid:* in targets){
						if(this.sID == sid){
							stopGlowing = false;
							glowing();
						}
					}
				}
			}
			
			drawCount();
			
			if (isHelp) {
				showGlowing();
				addStaff();
			}
		}
		
		public function dispose():void
		{
			onMouseOutHandler();
			
			if (itemIcon) {
				itemIcon.removeEventListener(MouseEvent.CLICK, onRecipeBttnClick);
				itemIcon.dispose();
				itemIcon = null;
			}
			
			if (requestText && requestText.parent) {
				requestText.parent.removeChild(requestText);
			}
			requestText = null;
			
			if (recWin) {
				recWin.close();
				recWin = null;
			}
			if (recAnimalWin) {
				recAnimalWin.close();
				recAnimalWin = null;
			}
			
			
			if (progressBar != null)
			{
				win.removeEventListener(WindowEvent.ON_PROGRESS, progress)
				removeChild(progressBar);
				removeChild(bg);
				bg = null;
				progressBar = null;
			}
			
			stopGlowing = true;
			
			background.filters = null;
			//recipeBttn.filters = null;
		}
		
		private var counterSprite:LayerX = null;
		public function drawCount():void {
			//if (counterSprite != null)
			//{
				//removeChild(counterSprite);
				//counterSprite = null
			//}
			//
			//
			//counterSprite = new LayerX();
			//counterSprite.tip = function():Object { 
				//return {
					//title:"",
					//text:Locale.__e("flash:1382952380064")
				//};
			//};
			//
			//var countOnStock:TextField = Window.drawText("x "+App.data.crafting[fID].count, {
				//color:0xffffff,
				//borderColor:0x41332b,  
				//fontSize:28,
				//autoSize:"left"
			//});
			//
			//var width:int = countOnStock.width + 24 > 30?countOnStock.width + 24:30;
		//
			//addChild(counterSprite);
			//counterSprite.x = background.width - counterSprite.width - 36;
			//counterSprite.y = 26;
			//
			//addChild(countOnStock);
			//countOnStock.x = counterSprite.x + (counterSprite.width - countOnStock.width) / 2;
			//countOnStock.y = counterSprite.y + 10;
		}
		
		private var bg:Bitmap
		private function drawProgressBar(crafted:uint, time:uint):void{
			if (progressBar != null)
			{
				removeChild(progressBar);
				progressBar = null;
			}
			
			progressBar = new Sprite();
			
			bg = new Bitmap(UserInterface.textures.craftSliderBg);
			addChild(bg);
			
			win.addEventListener(WindowEvent.ON_PROGRESS, progress)
			addChild(progressBar);
			
			//icon.visible = false;
			//timeText.visible = false;
			
			bg.x = (background.width - bg.width)/2;
			bg.y = background.height - 46;
			progressBar.x = bg.x + 2;
			progressBar.y = bg.y + 1;
		}
		
		private function progress(e:WindowEvent = null):void
		{
			var _progress:Number = ((App.time - win.crafted) / win.totalTime) *100;
			UserInterface.slider(progressBar, _progress, 100, "craftSlider");
		}
			
		public function onPreviewComplete(obj:Object):void
		{
			if(contains(preloader)){
				removeChild(preloader);
			}
			
			//drawCost();
			
			bitmap.bitmapData = obj.bitmapData;
			settings;
			settings.craftData[sID];
			bitmap.smoothing = true;
			itemIcon = new ImageButton(bitmap.bitmapData);
			
			if (win.settings.target.sid == 159) {
				itemIcon.tip = function():Object {
					var text:String;
					text = Locale.__e('flash:1403775192866', TimeConverter.timeToStr(App.data.storage[sID].duration));
					return {
						title:App.data.storage[sID].description,
						text:text,
						desc:Locale.__e('flash:1402650165308'),
						count:String(App.data.storage[sID].outs[Stock.FANTASY]),
						icon:new Bitmap(UserInterface.textures.energyIconSmall)
					};
				}
			}else{
				itemIcon.tip = function():Object {
					var text:String;
					text = Locale.__e('flash:1403775192866', TimeConverter.timeToStr(App.data.storage[sID].duration));
					return {
						title:App.data.storage[sID].description,
						text:text
					}
				}
			}
			if (testFlag) {
				
				itemIcon.addEventListener(MouseEvent.CLICK, onRecipeBttnClick);
				drawCost();
			}
			else
				itemIcon.addEventListener(MouseEvent.CLICK, onClosedBttnClick);
				//itemIcon.mouseEnabled = false;
			//itemIcon.y = 10;
			itemIcon.y = background.y - 3;
			itemIcon.x = background.x;
			sprTip.addChild(itemIcon);

			if (bitmap.height > 135) {
				
				bitmap.scaleX = bitmap.scaleY = 0.5;
				itemIcon.y = background.y - 30;
				itemIcon.x = background.x - 30;
			}
			sprTip.x = (background.width - bitmap.width) / 2;
			sprTip.y = (background.height - bitmap.height) / 2;
		}
		
		
		
		private function onClosedBttnClick(e:MouseEvent):void 
		{
			productionFieldWindow.drawClosedWindow();
		}
		
		private function drawCost():void 
		{
			var ellipse:Sprite = new Sprite();
				ellipse.graphics.beginFill(0xf6ecd2,0.7);
				ellipse.graphics.drawEllipse(50,50,75,30);
				ellipse.graphics.endFill();
				ellipse.x = -35;
				ellipse.y = 35;
				addChild(ellipse);
				
			var coinsIcoin:Bitmap = new Bitmap(UserInterface.textures.coinsIcon);
				coinsIcoin.x = 17; 
				coinsIcoin.y = 85; 
				coinsIcoin.scaleX = coinsIcoin.scaleY = 0.7;
				coinsIcoin.smoothing = true;
				addChild(coinsIcoin);			
				
			var price:int = App.data.storage[sID].price[3];
			var costText:TextField = Window.drawText(String(price), {
				fontSize:26,
				textAlign:"left",
				color:0xfdd21e,
				borderColor:0x774702
			});
				costText.x = coinsIcoin.x + 28;
				costText.y = coinsIcoin.y;
				addChild(costText);
		}
		
		public function glow():void
		{
			var myGlow:GlowFilter = new GlowFilter();
			myGlow.inner = false;
			myGlow.color = 0xfbd432;
			myGlow.blurX = 6;
			myGlow.blurY = 6;
			myGlow.strength = 8
			this.filters = [myGlow];
		}
		
		//Используется в квестах
		public function select():void {
			//recipeBttn.showGlowing();
			//recipeBttn.showPointing("top", (recipeBttn.width - 30) / 2, 0, recipeBttn.parent);
			//App.user.quests.currentTarget = recipeBttn;
		}
		
		
		private function glowing():void {

			if (App.user.quests.tutorial) {
				startGlowing();
				App.user.quests.currentTarget = itemIcon;
				App.user.quests.lock = false;
				Quests.lockButtons = false;
				
				var that:* = this;
				setTimeout(function():void {
					//Tutorial.watchOn(recipeBttn, 'bottom', false, { dx:0, dy: -80, arrow_dy:130, scaleX:1.2, scaleY:1.4 } );
					Tutorial.watchOn(that, 'top', false, { dx: -30 } );// , dy: -80, arrow_dy:130, scaleX:1.2, scaleY:1.4 } );
				}, 500);
				return;
			}
			
			/*customGlowing(background, glowing);
			if (recipeBttn) {
				customGlowing(recipeBttn);
			}*/
		}
		
		private var stopGlowing:Boolean = false;
		private var fieldArrow:MovieClip;
		private var productTitle:TextField;
		private var onOverItem:Boolean;
		private function customGlowing(target:*, callback:Function = null):void {
			TweenMax.to(target, 1, { glowFilter: { color:0xFFFF00, alpha:0.8, strength: 7, blurX:12, blurY:12 }, onComplete:function():void {
				if (stopGlowing) {
					target.filters = null;
					return;
				}
				TweenMax.to(target, 0.8, { glowFilter: { color:0xFFFF00, alpha:0.6, strength: 7, blurX:6, blurY:6 }, onComplete:function():void {
					if (!stopGlowing && callback != null) {
						callback();
					}
					if (stopGlowing) {
						target.filters = null;
					}
				}});	
			}});
		}	
		
		public var rotateTween:TweenLite;
		public var rotateAngle:int;
		public function removeAngleTween():void {
			if (rotateTween) {
				rotateTween.kill();
				rotateTween = null;
				this.parent.rotation = rotateAngle;
			}
		}
		
	}
}