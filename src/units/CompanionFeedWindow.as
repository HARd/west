package units
{
	import adobe.utils.CustomActions;
	import buttons.Button;
	import buttons.ImageButton;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import ui.BitmapLoader;
	import com.greensock.TweenMax;
	import units.BuyPetsFoodWindow;
	import units.Companion;
	import units.Pet;
	import wins.elements.TimeIcon;
	import wins.InfoWindow;
	import wins.MaterialItem;
	import wins.PurchaseWindow;
	import wins.ShopWindow;
	import wins.Window;
	import core.Load;
	import ui.UserInterface;
	import wins.ProgressBar;
	import wins.ProgressBar;
	import units.Unit;
	import core.Post;
	/**
	 * ...
	 * @author ...
	 */
	public class CompanionFeedWindow extends Window
	{
		public static const MAX_ITEMS_ON_PAGE:int = 4;
		
		private var _targetPet:Companion;
		
		private var stockFood:int = 0;
		private var foodToTake:int = 0;
		private var takenFood:int = 0;
		private var needFood:int = 0;
		private var sidKettle:int = 0;
		private var circle:Shape;
		public var items:Array = new Array();
		
		private var foodInStock:TextField;
		private var hireLabel:TextField;
		private var progressTitle:TextField;
		
		private var addFeedButton:Button;
		private var addAllFeedButton:Button;
		private var feedButton:Button;
		private var inviteButton:Button;
		private var upgradeButton:Button;
		
		public var foodIcon:Bitmap;
		public var foodIcon2:Bitmap;
		public var foodIcon3:Bitmap;
		public var progressBacking:Bitmap;
		
		public var progressBar:ProgressBar;
		
		private var countAddedFeed:int;
		
		private var addFoodToStockBttn:ImageButton;	
		
		private var feedCalback:Function;
		
		private var amountAddedFeed:Object = {
			1:5,
			2:10,
			3:20,
			4:30
		}
		
		public function CompanionFeedWindow(targetPet:Companion, settings:Object=null) 
		{
			_targetPet = targetPet;
			
			if (settings == null)
			{
				settings = {};
			}
			settings['width'] 			= 700;
			settings['height'] 			= 665;
			settings['sID'] 			= settings.sID || 0;
			settings['title'] 			= Locale.__e('Покорми животное');
			settings['hasButtons']		= false;
			settings['shadowColor'] 	= 0x513f35;
			settings['shadowSize'] 		= 4;
			
			feedCalback = settings.feedCalback;
			super(settings);
			
			takenFood = _targetPet.energy;
			stockFood = App.user.stock.count(Stock.FOOD);
			needFood = _targetPet.info.foods[Stock.FOOD];
			
			foodToTake = 0;
			
			//App.self.addEventListener(AppEvent.ON_AFTER_PACK, updateEvent);
			
		}
		
		public function updateEvent(e:AppEvent):void {
			stockFood = App.user.stock.count(Stock.FOOD) - takenFood;
			updateState();
		}
		
		override public function drawBody():void 
		{
			//drawDescription();
			//describeContainer.y = 40;
			//contentChange();
			//updateState();
			//
			//// Туторил
			//if (App.user.quests.data[32] && App.user.quests.data[32].finished == 0) {
				//if (describeContainer.getChildIndex(addFeedButton) < describeContainer.numChildren - 1)
					//describeContainer.swapChildren(addFeedButton, describeContainer.getChildAt(describeContainer.numChildren - 1));
				//
				//addFeedButton.showGlowing();
				//addFeedButton.showPointing('bottom', 0, addFeedButton.height + 30, describeContainer);
			//}
			
			new BuyPetsFoodWindow( {
				itemsOnPage:4,
				content:BuyPetsFoodWindow.createContent('Energy', { out:2992 } ),
				title:Locale.__e("flash:1478593486615"),
				fontBorderColor:0xd49848,
				shadowColor:0x553c2f,
				shadowSize:4,
				popup:true,
				hasDescription: true,
				description:Locale.__e('flash:1478593891481')
			}).show();
		}
		
		public var describeContainer:Sprite;
		public function drawDescription():void {
			
			describeContainer = new Sprite();
			bodyContainer.addChild(describeContainer);
			
			//switch(hut.level) {
				//case 1:
					//sidKettle = 311;
				//break;
				//case 2:
					//sidKettle = 316;
				//break;
				//case 3:
					//sidKettle = 317;
				//break;
				//case 4:
					//sidKettle = 317;
				//break;
				//default:
					//sidKettle = 311;
			//}
			
			sidKettle = 311;
			
			var icon:Bitmap = new Bitmap();
			describeContainer.addChild(icon);
			Load.loading(Config.getIcon('Feed', App.data.storage[sidKettle].preview), function(data:Bitmap):void
			{
				icon.bitmapData = data.bitmapData;
				icon.scaleX = icon.scaleY = 1;
				icon.smoothing = true;
				icon.x = 130 - icon.width / 2;
				icon.y = 100 - icon.height / 2;
			});
			
			var timeIcon:TimeIcon = new TimeIcon(_targetPet.info.foods[Stock.FOOD]);
			timeIcon.x = 130 - timeIcon.width / 2;
			timeIcon.y = 175;
			describeContainer.addChild(timeIcon);
			
			var selfLabel:TextField = drawText(Locale.__e("Воспользуйся запасами еды что бы накормить животное"), {
				fontSize:24,
				autoSize:"left",
				textAlign:"center",
				multiline:true,
				color:0x773c18,
				borderColor:0xfaf9ec
			});
			selfLabel.x = settings.width / 2 - 150;
			selfLabel.y = 30;
			selfLabel.wordWrap = true;
			selfLabel.width = 270;
			describeContainer.addChild(selfLabel);
			
			//круг
			circle = new Shape();
			circle.graphics.beginFill(0xc8cabc, 1);
			circle.graphics.drawCircle(selfLabel.x + selfLabel.width + 80, selfLabel.y + 55, 55);
			circle.graphics.endFill();
			describeContainer.addChild(circle);
			//на складе
			var inStock:TextField = drawText(Locale.__e("flash:1425563334631"), {
				fontSize:23,
				autoSize:"center",
				textAlign:"center",
				color:0xffffff,
				borderColor:0x1a292b,
				shadowColor:0x1a292b,
				shadowSize:1,
				textLeading:-6,
				multiline:true
			});
			inStock.wordWrap = true;
			inStock.x = selfLabel.x + selfLabel.width + 30;
			inStock.y = 21;
			inStock.width = 100;
			describeContainer.addChild(inStock);
			//food icon
			foodIcon = new Bitmap(Window.textures.foodIco);
			foodIcon.x = inStock.x - 5;
			foodIcon.y = 76;
			foodIcon.scaleX = foodIcon.scaleY = 0.8;
			foodIcon.smoothing = true;
			describeContainer.addChild(foodIcon);
			//food count
			foodInStock = drawText(String(stockFood), {
				fontSize:32,
				autoSize:"center",
				textAlign:"center",
				color:0xf4ffb7,
				borderColor:0x542e17
			});
			foodInStock.x = foodIcon.x + foodIcon.width + 5;
			foodInStock.y = foodIcon.y + 2;
			foodInStock.width = foodInStock.textWidth;
			describeContainer.addChild(foodInStock);
			
			//кнопка купить еды на склад
			addFoodToStockBttn = new ImageButton(UserInterface.textures.addBttnGreen);
			addFoodToStockBttn.tip = function():Object { 
				return {
					title:"",
					text:Locale.__e("flash:1382952380013")
				};
			};
			addFoodToStockBttn.x = foodInStock.x + foodInStock.width + 10;
			addFoodToStockBttn.y = foodInStock.y;
			describeContainer.addChild(addFoodToStockBttn);
			//addFoodToStockBttn.addEventListener(MouseEvent.CLICK, onAddFoodToStockEvent);
			
			//надо еды
			hireLabel = drawText(Locale.__e("flash:1425563563894"), {
				fontSize:28,
				textAlign:"center",
				multiline:true,
				color:0xffffff,
				borderColor:0x6c3311,
				shadowColor:0x6c3311,
				shadowSize:1
			});
			hireLabel.x = 195 + (365 - hireLabel.textWidth) / 2 - 25;
			hireLabel.y = 120;
			hireLabel.width = 110;
			describeContainer.addChild(hireLabel);
			
			//еда, прогрессбар, кнопка
			foodIcon2 = new Bitmap(Window.texture('foodIco'));
			foodIcon2.x = 200;
			foodIcon2.y = 150;
			describeContainer.addChild(foodIcon2);
			
			progressBacking = Window.backingShort(230, "progBarBacking");
			progressBacking.x = foodIcon2.x + foodIcon2.width;
			progressBacking.y = foodIcon2.y + 12;
			describeContainer.addChild(progressBacking);
			
			progressBar = new ProgressBar({win:this, width:246, isTimer:false});
			progressBar.x = progressBacking.x - 8;
			progressBar.y = progressBacking.y - 4;
			describeContainer.addChild(progressBar);
			progressBar.progress = takenFood / needFood;
			progressBar.start();
			
			progressTitle = drawText(progressData, {
				fontSize:32,
				autoSize:"left",
				textAlign:"center",
				color:0xffffff,
				borderColor:0x6b340c,
				shadowColor:0x6b340c,
				shadowSize:1
			});
			progressTitle.x = progressBacking.x + progressBacking.width / 2 - progressTitle.width / 2;
			progressTitle.y = progressBacking.y - 2;
			progressTitle.width = 80;
			describeContainer.addChild(progressTitle);
			
			////кнопка покормить
			var feedParams:Object = {
				caption:Locale.__e('flash:1424939984069'),
				bgColor:[0xfed444, 0xf4aa27],
				bevelColor:[0xfde96c, 0xc67d0c],
				borderColor:[0xd4c4ab, 0xc4b29c],
				fontSize:26,
				fontBorderColor:0x7f4c2f,
				shadowColor:0x7f4c2f,
				shadowSize:4,
				width:220,
				height:52
			};
			feedButton = new Button(feedParams);
			feedButton.x = (settings.width - feedButton.width) / 2;//foodIcon2.x + foodIcon2.width / 2;
			feedButton.y = settings.height - 140;//foodIcon2.y;
			describeContainer.addChild(feedButton);
			feedButton.addEventListener(MouseEvent.CLICK, onFeedButtonEvent);
			feedButton.name = 'HutHireWindow_feedButton';
			
			//добавить еды со склада в прогресс бар
			//кнопка +1 (n) еды
			//countAddedFeed = 1;
			countAddedFeed = amountAddedFeed[_targetPet.level];
			
			var addFeedParams:Object = {
				caption:'+' + countAddedFeed,
				bgColor:[0xffca4e, 0xff9c23],
				bevelColor:[0xffe88d, 0xce650d],
				borderColor:[0xc4b29b, 0xc5b39c],
				fontSize:24,
				fontColor:0xf4ffb7,
				fontBorderColor:0x542e17,
				shadowColor:0x542e17,
				shadowSize:4,
				width:110,
				height:48
			};
			addFeedButton = new Button(addFeedParams);
			addFeedButton.textLabel.x -= 15;
			addFeedButton.textLabel.y += 2;
			
			foodIcon3 = new Bitmap(Window.textures.foodIco);
			foodIcon3.scaleX = foodIcon3.scaleY = 0.55;
			foodIcon3.smoothing = true;
			foodIcon3.x = addFeedButton.width / 2;
			foodIcon3.y = addFeedButton.height / 2 - foodIcon3.height / 2;
			addFeedButton.addChild(foodIcon3);
			
			addFeedButton.x = progressBacking.x + progressBacking.width + 15;
			addFeedButton.y = foodIcon2.y - 5;
			describeContainer.addChild(addFeedButton);
			addFeedButton.addEventListener(MouseEvent.CLICK, onAddFeedButtonEvent);
			addFeedButton.name = 'HutHireWindow_addFeedButton';
			
			addFeedParams['caption'] = Locale.__e('flash:1460468264293');
			addFeedParams['width'] = 160;
			addFeedParams['height'] = 42;
			addAllFeedButton = new Button(addFeedParams);
			addAllFeedButton.x = addFeedButton.x + (addFeedButton.width - addAllFeedButton.width) / 2;
			addAllFeedButton.y = addFeedButton.y + addFeedButton.height + 5;
			if (App.isSocial('FB', 'NK', 'SP', 'AI', 'MX', 'YB')) addAllFeedButton.visible = false;
			describeContainer.addChild(addAllFeedButton);
			addAllFeedButton.addEventListener(MouseEvent.CLICK, onAddAllFeedButtonEvent);
			
			if (App.user.quests.tutorial && App.user.quests.data[32] && App.user.quests.data[32].finished == 0) {
				addAllFeedButton.state = Button.DISABLED;
			}
			
			foodIcon2.visible = true;
			progressBacking.visible = true;
			progressBar.visible = true;
			progressTitle.visible = true;
			addFeedButton.visible = true;
			
			feedButton.visible = false;
			
			var devider:Bitmap = new Bitmap(Window.textures.dividerLine);
			devider.x = 70;
			devider.y = 245;
			devider.width = settings.width - 140;
			devider.scaleY = -1;
			devider.alpha = 0.7;
			
			var devider2:Bitmap = new Bitmap(Window.textures.dividerLine);
			devider2.x = 70;
			devider2.y = 40;// settings.height - 105;
			devider2.width = settings.width - 140;
			devider2.scaleY = -1;
			devider2.alpha = 0.7;
			bodyContainer.addChild(devider2);
			
			var upgradeParams:Object = {
				caption:Locale.__e('flash:1425574338255'),
				bgColor:[0x7bc9f9, 0x60aedf],
				bevelColor:[0xa5ddfb, 0x266fad],
				borderColor:[0xd5c2a9, 0xbca486],
				fontSize:26,
				fontBorderColor:0x40505f,
				shadowColor:0x40505f,
				shadowSize:4,
				width:210,
				height:52
			};
			upgradeButton = new Button(upgradeParams);
			upgradeButton.x = devider2.x + devider2.width / 2 - upgradeButton.width / 2;
			upgradeButton.y = 14;// devider2.y - upgradeButton.height / 2 - 2;
			
			if (_targetPet.level == _targetPet.totalLevels)
				return;
			
			drawMirrowObjs('upgradeDec', upgradeButton.x + 24, upgradeButton.x + upgradeButton.width - 24, upgradeButton.y, true, true, false);
			
			bodyContainer.addChild(upgradeButton);
			//upgradeButton.addEventListener(MouseEvent.CLICK, onUpgradeButtonEvent);
			
			if ((settings.target == App.user.quests.currentTarget) && App.user.quests.data.hasOwnProperty(72) && App.user.quests.data[72].finished == 0) {
				App.user.quests.currentTarget = null;
				glowing();
			}
			
			if (settings.glowUpgrade) {
				glowing();
			}
		}
		
		private function glowing():void {			
			if (upgradeButton) {
				if (!App.user.quests.tutorial) {
					customGlowing(upgradeButton, glowing);
				}
			}
		}
		
		private function customGlowing(target:*, callback:Function = null):void {
			TweenMax.to(target, 1, { glowFilter: { color:0xFFFF00, alpha:0.8, strength: 7, blurX:12, blurY:12 }, onComplete:function():void {
				TweenMax.to(target, 0.8, { glowFilter: { color:0xFFFF00, alpha:0.6, strength: 7, blurX:6, blurY:6 }, onComplete:function():void {
					if (callback != null) {
						callback();
					}
				}});	
			}});
		}
		
		private function onHelpClick(e:MouseEvent):void 
		{
			//new InfoWindow(3,{popup:true}).show();
		}
		
		private function glowFeedItems():void
		{
			//for each (var ins:PetFoodItem in _items)
			//{
				//if (ins.status ==  MaterialItem.READY)
					//ins.showGlowing();
			//}
		}
		override public function drawTitle():void 
		{
			super.drawTitle();
		}
		private function onFeedButtonEvent(e:MouseEvent):void {
			Window.closeAll();
			
			feedCalback(foodToTake);
			//App.user.stock.take(Stock.FOOD, 25);
			
		}
		
		private function onAddFeedButtonEvent(e:MouseEvent):void {
			
			if (e.currentTarget.mode == Button.DISABLED) return;
			
			if (addFeedButton.mode == Button.DISABLED) {
				//Hints.text(Locale.__e('flash:1426239741751'), Hints.TEXT_RED,  new Point(addFeedButton.x + addFeedButton.width/2, addFeedButton.y + 15), false, bodyContainer);
				return;
			}
			
			if (stockFood - countAddedFeed >= 0) {
				takenFood += countAddedFeed;
				stockFood -= countAddedFeed;
				//App.user.stock.take(Stock.FOOD, countAddedFeed);
				//stockFood = App.user.stock.count(Stock.FOOD);
				//анимация
				//var icon:Bitmap = HutHireWindow.moveFood(foodIcon.x, foodIcon.y, foodIcon2.x, foodIcon2.y + foodIcon2.parent.y, 0.8, 1, function():void{bodyContainer.removeChild(icon);});
				//bodyContainer.addChild(icon);
				updateState();
			} else {
				onAddFoodToStockEvent();
			}
		}
		
		public function get progressData():String {
			return String(takenFood) + '/' + String(needFood);
		}
		
		public function get progressComplete():Boolean {
			return (takenFood >= needFood);
		}
		
		private function onAddAllFeedButtonEvent(e:MouseEvent):void {
			if (e.currentTarget.mode == Button.DISABLED) return;
			
			if (stockFood == 0) {
				onAddFoodToStockEvent();
				return;
			}
			if (takenFood >= needFood) return;
			var takeF:int = needFood - takenFood;
			if (stockFood < needFood) takeF = stockFood;
			takenFood += takeF;
			stockFood -= takeF;
			foodToTake += takeF;
			//анимация
			//var icon:Bitmap = HutHireWindow.moveFood(foodIcon.x, foodIcon.y, foodIcon2.x, foodIcon2.y + foodIcon2.parent.y, 0.8, 1, function():void{bodyContainer.removeChild(icon);});
			//bodyContainer.addChild(icon);
			updateState();
		}
		
		private function onAddFoodToStockEvent(e:MouseEvent = null):void {
			new PurchaseWindow( {
				itemsOnPage:3,
				//content:PurchaseWindow.createContent('Food', { view:'food' } ),
				content:PurchaseWindow.createContent('Energy', { view:'food' } ),
				title:Locale.__e("flash:1426072877425"),
				fontBorderColor:0xd49848,
				shadowColor:0x553c2f,
				shadowSize:4,
				popup:true
			}).show();
			
			//докупить еды на склад (ещё не сделали покупку еды)
		}
		
		public function updateState():void {
			//stockFood = App.user.stock.count(Stock.FOOD);
			
			if (stockFood - countAddedFeed < 0) {
				addFeedButton.state = Button.DISABLED;
				addAllFeedButton.state = Button.DISABLED;
				addFoodToStockBttn.visible = true;
			} else {
				addFeedButton.state = Button.NORMAL;
				addAllFeedButton.state = Button.NORMAL;
				addFoodToStockBttn.visible = false;
			}
			
			progressBar.progress = takenFood / needFood;
			progressTitle.text = progressData;
			
			foodInStock.text = String(stockFood);
			
			if (progressBar.progress >= 1) {
				feedButton.visible = true;
				
				if (inviteButton) 
					inviteButton.visible = false;

				addFeedButton.state = Button.DISABLED;
				addAllFeedButton.state = Button.DISABLED;
			} else {
				addFeedButton.state = Button.NORMAL;
				addAllFeedButton.state = Button.NORMAL;
				
				feedButton.visible = false;
			}
			
			if (progressBar.progress >= 1) {
				if (App.user.quests.data[32] && App.user.quests.data[32].finished == 0) {
					for each (var item:* in items)
						item.unglow();
					
					addFeedButton.hideGlowing();
					addFeedButton.hidePointing();
					
					feedButton.showGlowing();
					feedButton.showPointing('bottom', 0, feedButton.height + 30, describeContainer);
				}
			}
		}
	}

}