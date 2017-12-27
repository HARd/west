package wins.elements 
{

	import buttons.Button;
	import com.greensock.*; 
	import com.greensock.easing.*;
	import com.greensock.TweenLite;
	import com.greensock.TweenMax;
	import core.Load;
	import core.Size;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import ui.UserInterface;
	import units.Tribute;
	import units.Unit;
	import wins.ProductionWindow;
	import wins.RecipeAnimalWindow;
	import wins.ShopWindow;
	import wins.SimpleWindow;
	import wins.Window;
	import wins.RecipeWindow;
	import wins.WindowEvent;

	//Вспомогательный класс
	public class ProductionItem extends LayerX {
		
		public var background:Bitmap = null;
		public var bitmap:Bitmap = null;
		public var sID:String;
		public var fID:int;
		public var recipe:Object;
		public var count:uint;
		
		public var craftBttn:Button;
		private var preloader:Preloader = new Preloader();
		public var title:TextField = null;
		public var timeText:TextField = null;
		public var requestText:TextField = null;
		public var recipeBttn:Button;
		public var progressBar:Sprite;
		public var icon:Bitmap;
		protected var win:*
		private var productTitle:TextField;
		private var tween:TweenMax;
		public var sprTip:LayerX;
		
		private var find:int = 0;
		private var canShow:Boolean = true;
		
		private var settings:Object = {
			width:170,
			height:206,
			recipeBttnMarginY:-28,
			
			titleColor:0x753e15,
			
			timeColor:0xffffff,
			timeBorderColor:0x764a3e, 
			
			timeMarginY:-24,
			timeMarginX: -3
		};
		
		private var testFlag:Boolean = true;
		
		public function ProductionItem(win:*, _settings:Object = null)
		{
			for (var item:* in _settings) {
				settings[item] = _settings[item];
			}
			
			if (settings.hasOwnProperty('canShow')) {
				canShow = settings.canShow;
			}
			
			this.win = win;
			recipe = settings.crafting;
			fID = recipe.ID;
			sID = recipe.out;
			
			background = Window.backing(settings.width, settings.height, 40, 'itemBacking');
			addChild(background);
			
			sprTip = new LayerX();
			addChild(sprTip);
			sprTip.tip = function():Object {
				return {
					title:App.data.storage[sID].title,
					text:App.data.storage[sID].text
				}
			}
			
			bitmap = new Bitmap();
			addChild(bitmap);
			
			preloader = new Preloader();
			preloader.x = (background.width)/ 2;
			preloader.y = (background.height)/ 2 - 5;
			addChild(preloader);
			Load.loading(Config.getIcon(App.data.storage[sID].type, App.data.storage[sID].preview), onPreviewComplete);
			
			title = Window.drawText(App.data.storage[sID].title, {
				width:		background.width - 20,
				fontSize:	23,
				color:		settings.titleColor,
				borderColor:0xfcf6e4,
				multiline:	true,
				textAlign:	"center",
				autoSize:	"center",
				wrap:		true
			});
			title.x = (background.width - title.width) / 2;
			title.y = 8;
			addChild(title);
			
			// time and count craft
			addTimeIconAndCountCraft();
			
			if (!canShow) {
				craftBttn = new Button( {
					caption:		Locale.__e('flash:1382952380065'),
					width:			background.width - 25,
					height:			42,
					fontSize:		25,
					fontColor:		0xffa883
				});
			} else {
				craftBttn = new Button( {
					caption:		Locale.__e('flash:1382952380065'),
					width:			background.width - 25,
					height:			42,
					fontSize:		25
				});
			}
			craftBttn.x = (background.width - craftBttn.width) / 2;
			craftBttn.y = background.height - craftBttn.height / 2;
			craftBttn.name = 'pw_craft';
			addChild(craftBttn);
			if (win.settings.find == sID) craftBttn.showGlowing();
			//if (!canShow) craftBttn.state = Button.DISABLED;
			craftBttn.addEventListener(MouseEvent.CLICK, onRecipeBttnClick);
			
			if (App.data.crafting[fID].hasOwnProperty('expire') && App.data.crafting[fID].expire.hasOwnProperty(App.social) && App.data.crafting[fID].expire[App.social] > App.time)
				drawTimer();
		}
		
		private var timerText:TextField;
		private function drawTimer():void {
			timerText = Window.drawText(TimeConverter.timeToStr(App.data.crafting[fID].expire[App.social] - App.time), {
				color: 0xfff200,
				borderColor: 0x680000,
				fontSize: 26,
				textAlign: 'center',
				width: background.width
			});
			timerText.y = title.y + title.textHeight + 5;
			addChild(timerText);
			App.self.setOnTimer(updateTimer);
		}
		
		private function updateTimer():void {
			if (timerText) {
				var text:String = TimeConverter.timeToStr(App.data.crafting[fID].expire[App.social] - App.time);
				timerText.text = text;
				
				if (App.data.crafting[fID].expire[App.social] - App.time <= 0) {
					timerText.visible = false;					
					App.self.setOffTimer(updateTimer);
					
					recipeBttn.state = Button.DISABLED;
				}
			}
		}
		
		private var timeIcon:TimeIcon;
		private function addTimeIconAndCountCraft():void 
		{
			timeIcon = new TimeIcon(recipe.time, 70);
			if(recipe.time > 0)
				addChild(timeIcon);
			
			var craftCount:TextField = Window.drawText("x" + App.data.crafting[fID].count, {
				color:0xffffff,
				borderColor:0x6a3314,
				fontSize:26,
				borderSize:4,
				letterSpacing:1,
				shadowSize:1.5,
				autoSize:"left"
			});
			addChild(craftCount);
			
			timeIcon.x = 5;//(background.width - (timeIcon.width + craftCount.width + 30)) / 2;
			timeIcon.y = background.height - 55;
			
			craftCount.x = background.width - craftCount.width - 10;//timeIcon.x + timeIcon.width + 30;
			craftCount.y = background.height - 55;
			
			if (App.data.crafting[fID].count < 2) {
				craftCount.visible = false;
			}
			
			if (win.target.sid == 282) { //колодец
				craftCount.visible = true;
			}
			
			//если кухня, отображ иконку того, что получишь и колличество, например, еда +10
			if (win.target.sid == 281) { //кухня
				//
			}
			
			var sidCraftIcon:int;
			var countCraft:String;
			if (App.data.storage[recipe.out].type == 'Pack') {
				for (var b:String in App.data.storage[recipe.out].bonus) {
					sidCraftIcon = int(b);
					countCraft = App.data.storage[recipe.out].bonus[int(b)];
					
					craftCount.visible = true;
					craftCount.text = countCraft;
					
					var tf:TextFormat = craftCount.getTextFormat();
					tf.size = 18;
					craftCount.setTextFormat(tf);
					//timeIcon.x -= 5;
					craftCount.x -= 20;
					craftCount.y += 5;
					
					var icon:Bitmap = new Bitmap();
					addChild(icon);
					Load.loading(Config.getIcon(App.data.storage[sidCraftIcon].type, App.data.storage[sidCraftIcon].preview), function(data:Bitmap):void {
						icon.bitmapData = data.bitmapData;
						icon.scaleX = icon.scaleY = 0.3;
						icon.smoothing = true;
						craftCount.x = background.width - craftCount.width - icon.width;
						icon.x = craftCount.x + craftCount.width;
						icon.y = background.height - 55;
					});
					
					break;
				}
			}
			if (!craftCount.visible) timeIcon.x += 30;
			
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
			if (e.currentTarget.mode == Button.DISABLED) return;
			var loko:Array;
			var vagon:Array;
			switch (fID) {
				case 398:
					loko = Map.findUnits([1580]);
					
					if (loko.length != 0) {
						showOneLokoWindow();
						return;
					} 
					if (!canShow) {
						showTechnoWindow();
						return;
					}
					break;
				case 399:
					loko = Map.findUnits([1580]);
					
					if (loko.length != 0 && loko[0].level > 0) {
						showOneLokoWindow();
						return;
					} else if (loko.length != 0 && loko[0].level == 0 && canShow) {
						craftBttn.hideGlowing();
						craftBttn.hidePointing();
						
						hideGlowing();
						openRecipeWindow();
						return;
					}else if (canShow) {
						showPrevWindow();
						return;
					}
					if (!canShow) {
						showTechnoWindow();
						return;
					}
					break;
				case 403:
					loko = Map.findUnits([1580]);
					
					if (loko.length != 0 && loko[0].level > 1) {
						showOneLokoWindow();
						return;
					} else if (loko.length != 0 && loko[0].level == 1 && canShow) { 
						craftBttn.hideGlowing();
						craftBttn.hidePointing();
						
						hideGlowing();
						openRecipeWindow();
						return;
					}else if (canShow) {
						showPrevWindow();
						return;
					}
					if (!canShow) {
						showTechnoWindow();
						return;
					}
					break;
				case 410:
					vagon = Map.findUnits([1624]);
					
					if (vagon.length == 2) {
						showOneLokoWindow('flash:1456220149763');
						return;
					}
					if (!canShow) {
						showTechnoWindow();
						return;
					}
					break;
				case 411:
					vagon = Map.findUnits([1624]);
					
					var craft:Boolean = true;
					if (vagon.length == 2 && vagon[0].level > 0 && vagon[1].level > 0) {
						showOneLokoWindow('flash:1456220149763');
						return;
					} else if (vagon.length != 0 && canShow) {
						for each (var vag:Tribute in vagon) {
							if (vag.level == 0) {
								craftBttn.hideGlowing();
								craftBttn.hidePointing();
								
								hideGlowing();
								openRecipeWindow();
								return;
							}
						}
						if (canShow) {
							showPrevWindow();
							return;
						}
					}else if (canShow) {
						showPrevWindow();
						return;
					}
					if (!canShow) {
						showTechnoWindow();
						return;
					}
					break;
				case 412:
					vagon = Map.findUnits([1624]);
					
					if (vagon.length == 2 && vagon[0].level > 1 && vagon[1].level > 1) {
						showOneLokoWindow('flash:1456220149763');
						return;
					} else if (vagon.length != 0 && canShow) { 
						for each (var vag1:Tribute in vagon) {
							if (vag1.level == 1) {
								craftBttn.hideGlowing();
								craftBttn.hidePointing();
								
								hideGlowing();
								openRecipeWindow();
								return;
							}
						}
						if (canShow) {
							showPrevWindow();
							return;
						}
					}else if (canShow) {
						showPrevWindow();
						return;
					}
					if (!canShow) {
						showTechnoWindow();
						return;
					}
					break;
			}
			
			if (!canShow) {
				ShopWindow.findMaterialSource(App.data.crafting[fID].assoc);
				win.close();
				return;
			}
			
			craftBttn.hideGlowing();
			craftBttn.hidePointing();
			
			hideGlowing();
			openRecipeWindow();			
		}
		
		private function showOneLokoWindow(text:String = 'flash:1455703948759'):void {
			new SimpleWindow( {
				popup:true,
				title:Locale.__e('flash:1382952380254'),
				text:Locale.__e(text)
			}).show();
		}
		private function showTechnoWindow(text:String = 'flash:1455703938473'):void {
			new SimpleWindow( {
				popup:true,
				title:Locale.__e('flash:1382952380254'),
				text:Locale.__e(text),
				confirm:function():void {
					if (recipe.hasOwnProperty('assoc') && recipe.assoc != 0 && recipe.assoc != '') {
						Window.closeAll();
						ShopWindow.findMaterialSource(recipe.assoc);
					}
				}
			}).show();
		}
		private function showPrevWindow():void {
			new SimpleWindow( {
				popup:true,
				title:Locale.__e('flash:1382952380254'),
				text:Locale.__e('flash:1455719044917')
			}).show();
		}
		private function openRecipeWindow():void
		{
			recWin = new RecipeWindow( {
				title:Locale.__e("flash:1382952380065")+':',
				fID:fID,
				onCook:win.onCook,
				busy:win.busy,
				win:win,
				hasDescription:true,
				craftData:settings.craftData,
				dontCheckTechno:false,
				prodItem:this,
				find:find
			});
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
				dontCheckTechno:false,
				prodItem:this
			});
			recAnimalWin.show();
		}
		
		public function change(fID:*, lvlNeed:int = 0, isHelp:Boolean = false):void
		{
			dispose();
			var formula:Object = App.data.crafting[fID];
			
			this.sID 		= formula.out;
			this.fID 		= int(fID);
			this.count 		= formula.count;
			this.recipe 	= formula.items;
			
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
			Load.loading(Config.getIcon(App.data.storage[sID].type, App.data.storage[sID].preview), onPreviewComplete);
			
			if (!testFlag) {
				drawCloseItem(lvlNeed);
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
			
			drawCount();
		}
		
		public function dispose():void
		{
			find = 0;
			craftBttn.hideGlowing();
			craftBttn.removeEventListener(MouseEvent.CLICK, onRecipeBttnClick);
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
			
		public function onPreviewComplete(data:Object):void
		{
			if(contains(preloader))
				removeChild(preloader);
			
			bitmap.bitmapData = data.bitmapData;
			bitmap.smoothing = true;
			Size.size(bitmap, background.width - 30, background.width - 30);
			bitmap.x = (background.width - bitmap.width) / 2;
			bitmap.y = (background.height - bitmap.height) / 2;
		}
		
		private function onClosedBttnClick(e:MouseEvent):void 
		{
			win.close();
		}
		
		public function glow(find:int = 0):void {
			this.find = find;
			
			craftBttn.showGlowing();
			
			if (App.user.level < 3)
				craftBttn.showPointing('bottom', 0, craftBttn.height + 30, this);
		}
		
		
		private function glowing():void {

			if (App.user.quests.tutorial) {
				customGlowing(recipeBttn);
				App.user.quests.currentTarget = recipeBttn;
				App.user.quests.lock = false;
				Quests.lockButtons = false;
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