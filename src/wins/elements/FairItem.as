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
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import flash.utils.setTimeout;
	import ui.UserInterface;
	import wins.FairRecipeWindow;
	import wins.RecipeAnimalWindow;
	import wins.Window;
	import wins.RecipeWindow;
	import wins.WindowEvent;

	//Вспомогательный класс
	public class FairItem extends LayerX{
		
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
		private var productTitle:TextField;
		private var tween:TweenMax;
		private var productionWindow:*;
		public var sprTip:LayerX = new LayerX();
		
		
		public var settings:Object = {
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
		
		public function FairItem(win:*, _settings:Object = null)
		{
			for (var item:* in _settings) {
				settings[item] = _settings[item];
			}
			addEventListener(MouseEvent.MOUSE_OVER, onMouseOverHandler);
			addEventListener(MouseEvent.MOUSE_OUT, onMouseOutHandler);
			this.win = win;
			productionWindow = win;
			
			background = new Bitmap(Window.textures.buildingsActiveBacking);
			background.smoothing = true;
			addChild(background);
			
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
			
		}
		
		private function onMouseOverHandler(e:MouseEvent):void 
		{
			removeStaff();
			
			addStaff();
		}
		
		private function onMouseOutHandler(e:MouseEvent):void 
		{
			removeStaff();
		}
		
		private function addStaff():void 
		{
			productTitle = Window.drawText(settings.crafting.n, {
				fontSize:26,
				textLeading: -12,
				textAlign:"center",
				wrap:true,
				multiline:true,
				width:130,
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
			//if (fieldArrow && fieldArrow.parent) 
			//{
				//fieldArrow.parent.removeChild(fieldArrow);
				//fieldArrow = null;
				//fieldArrow = null;
			//}
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
				borderColor:0x5e3402,
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
		
		public var recWin:RecipeWindow;
		public var recAnimalWin:RecipeAnimalWindow;
		protected function onRecipeBttnClick(e:MouseEvent):void
		{
			hideGlowing();
			openRecipeWindow();
		}
		
		private function openRecipeWindow():void
		{
			new FairRecipeWindow( {
				title:Locale.__e("flash:1382952380065") + ':',
				sID:settings.crafting.id,
				requires:win.settings.forms.obj[settings.crafting.id],
				openAction:win.settings.openAction,
				win:win,
				hasDescription:true,
				prodItem:this
			}).show();
		}
		
		private var preloader:Preloader = new Preloader();
		
		public function change(obj:*):void
		{
			dispose();
			this.fID 		= int(obj.id);
			
			//title.text = App.data.storage[sID].title;
			//title.x = (background.width - title.width) / 2;
			
			//if (lvlNeed > settings.level) {   // переделать
				//testFlag = false;  // just for test
			//}
			//else testFlag = true;
			
			bitmap.bitmapData = null;
			
			addChild(preloader);
			preloader.x = (background.width)/ 2;
			preloader.y = (background.height)/ 2 - 5;
			Load.loading(Config.getIcon('Fair', obj.v), onPreviewComplete);
			
			//timeText.text = TimeConverter.timeToCuts(formula.time, true, true);
			//timeText.height = timeText.textHeight + 6;
			
			//if (!testFlag) {
				//
				//drawCloseItem(lvlNeed);
				////requestText.visible = true;
			//}else {
				//
				//removeReqTekst();
				//
			//}
			
			//var info:Object = App.data.storage[sID];
			//sprTip.tip = function():Object {
				//return {
					//title: info.title,
					//text: info.description
				//};
			//}
			//
			//if (Quests.help) {
				//var qID:int = App.user.quests.currentQID;
				//var mID:int = App.user.quests.currentMID;
				//var targets:Object = App.data.quests[qID].missions[mID].target;
				//for each(var sid:* in targets){
					//if(this.sID == sid){
						//stopGlowing = false;
						//glowing();
					//}
				//}
			//}
			//
			//drawCount();
			
			//if (isHelp) {
				//showGlowing();
			//}
		}
		
		public function dispose():void
		{
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
			if (counterSprite != null)
			{
				removeChild(counterSprite);
				counterSprite = null
			}
			
			if (App.data.crafting[fID].count <= 1)
				return;
			
			counterSprite = new LayerX();
			counterSprite.tip = function():Object { 
				return {
					title:"",
					text:Locale.__e("flash:1382952380064")
				};
			};
			
			var countOnStock:TextField = Window.drawText("x "+App.data.crafting[fID].count, {
				color:0xffffff,
				borderColor:0x41332b,  
				fontSize:28,
				autoSize:"left"
			});
			
			var width:int = countOnStock.width + 24 > 30?countOnStock.width + 24:30;
			//var bg:Bitmap = Window.backing(width, 40, 10, "smallBacking");
			//
			//
			//counterSprite.addChild(bg);
			addChild(counterSprite);
			counterSprite.x = background.width - counterSprite.width - 36;
			counterSprite.y = 26;
			
			addChild(countOnStock);
			countOnStock.x = counterSprite.x + (counterSprite.width - countOnStock.width) / 2;
			countOnStock.y = counterSprite.y + 10;
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
			bitmap.bitmapData = obj.bitmapData;
			bitmap.smoothing = true;
			itemIcon = new ImageButton(bitmap.bitmapData);
			//itemIcon.tip = function():Object {
				//return {
					//title:App.data.storage[sID].title,
					//text:App.data.storage[sID].description
				//}
			//}
			//itemIcon.tip = function():Object {
					//var text:String;
					//text = Locale.__e('flash:1403775192866', TimeConverter.timeToStr(App.data.crafting[fID].time));
					//return {
						//title:App.data.storage[sID].description,
						//text:text
					//}
				//}
			if(testFlag)
				itemIcon.addEventListener(MouseEvent.CLICK, onRecipeBttnClick);
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
			productionWindow.drawClosedWindow();
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
				customGlowing(recipeBttn);
				App.user.quests.currentTarget = recipeBttn;
				App.user.quests.lock = false;
				Quests.lockButtons = false;
				setTimeout(function():void {
					//Tutorial.watchOn(recipeBttn, 'bottom', false, { dx:0, dy: -80, arrow_dy:130, scaleX:1.2, scaleY:1.4 } );
					Tutorial.watchOn(this, 'top', false);// , { dx:0, dy: -80, arrow_dy:130, scaleX:1.2, scaleY:1.4 } );
				}, 500);
				return;
			}
			
			customGlowing(background, glowing);
			if (recipeBttn) {
				customGlowing(recipeBttn);
			}
		}
		
		private var stopGlowing:Boolean = false;
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