package wins 
{
	import api.ExternalApi;
	import buttons.Button;
	import buttons.EnergyButton;
	import buttons.ImageButton;
	import buttons.ImagesButton;
	import com.greensock.TweenLite;
	import com.greensock.TweenMax;
	import core.Load;
	import core.Post;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import ui.Hints;
	import ui.UserInterface;
	import units.Animal;
	import units.Feed;
	import units.Hut;
	import units.Unit;
	import wins.elements.Bar;
	import wins.elements.TimeIcon;

	public class HutHireWindow extends Window
	{
		public static var isHelpEvent:Boolean = false;
		public var items:Array = new Array();
		public var friends:Object = { };
		public var energyBttn:EnergyButton;
		public var createBttn:Button;
		public var createBttnBuy:Button;
		public var anotherBttn:Button;
		public var animalEnergy:Bar;
		public var userEnergy:Bar;
		public var energyBefore:int;
		public var textLabel:TextField;
		
		private var progressTitle:TextField;
		private var foodInStock:TextField;
		private var hireLabel:TextField;
		private var circle:Shape;
		private var addFoodToStockBttn:ImageButton;	//
		public var progressBar:ProgressBar;
		public var progressBacking:Bitmap;
		private var feedButton:Button;				//
		private var inviteButton:Button;				//
		private var addFeedButton:Button;			//
		private var addAllFeedButton:Button;			//
		private var countAddedFeed:int;
		public var foodIcon:Bitmap;
		public var foodIcon2:Bitmap;
		public var foodIcon3:Bitmap;
		private var upgradeButton:Button;
		
		public var stockFood:int = 0;
		public var hut:Hut;
		public var takenFood:int = 0;
		public var needFood:int = 0;
		
		private var sidKettle:int;
		
		private var amountAddedFeed:Object = {
			1:5,
			2:10,
			3:20,
			4:30
		}
		
		public function HutHireWindow(settings:Object = null) 
		{
			if (settings == null) {
				settings = new Object();
			}
			
			hut = settings['target'];
			settings['width'] 			= 700;
			settings['height'] 			= 665;
			settings['sID'] 			= settings.sID || 0;
			settings['title'] 			= Locale.__e('flash:1425561797309');
			settings['hasPaginator'] 	= true;
			settings['hasButtons']		= false;
			settings['itemsOnPage'] 	= 10;
			settings['shadowColor'] 	= 0x513f35;
			settings['shadowSize'] 		= 4;
			settings['content']			= [];
			
			//settings.content.unshift( { uid:'1', level:App.user.friends.data[1].level } );
			for (var i:int = 0; i < App.user.friends.keys.length; i++) {
				var friend:Object = App.user.friends.data[App.user.friends.keys[i].uid];
				var friendData:Object = App.user.friends.keys[i];
				if (friend.hasOwnProperty('wigwam')) {
					friendData['wigwam'] = friend.wigwam;
				} else {
					friendData['wigwam'] = 0;
				}
				
				settings.content.push(friendData);
			}
			
			settings.content.sortOn('wigwam');
			settings.content.unshift( { uid:'1', level:App.user.friends.data[1].level } );
			
			super(settings);
			
			stockFood = App.user.stock.count(Stock.FOOD);
			takenFood = settings.target.energy;
			needFood = hut.info.devel.req[settings.target.level].energy;
			
			App.self.addEventListener(AppEvent.ON_AFTER_PACK, updateEvent);
			App.self.addEventListener(AppEvent.FEED_COMPLETE, updateFriends);
		}
		
		override public function dispose():void {
			App.self.removeEventListener(AppEvent.ON_AFTER_PACK, updateEvent);
			
			for (var i:int = 0; i < items.length; i++)
			{
				if (items[i] != null)
				{
				items[i].dispose();
				items[i] = null;
				}
			}
			super.dispose();
		}
		
		public var describeContainer:Sprite;
		public function drawDescription():void {
			
			describeContainer = new Sprite();
			bodyContainer.addChild(describeContainer);
			
			
			
			switch(hut.level) {
				case 1:
					sidKettle = 311;
				break;
				case 2:
					sidKettle = 316;
				break;
				case 3:
					sidKettle = 317;
				break;
				case 4:
					sidKettle = 317;
				break;
				default:
					sidKettle = 311;
			}
			
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
			
			var timeIcon:TimeIcon = new TimeIcon(hut.info.devel.req[hut.level].time);
			timeIcon.x = 130 - timeIcon.width / 2;
			timeIcon.y = 175;
			describeContainer.addChild(timeIcon);
			
			//var timeLabel:TextField = drawText(TimeConverter.timeToCuts(hut.info.devel.req[1].time, false, true), {
				//fontSize:20,
				//autoSize:"left",
				//textAlign:"center",
				//multiline:true,
				//color:0xffffff,
				//borderColor:0x6a351c,
				//shadowColor:0x6a351c,
				//shadowSize:1
			//});
			//timeLabel.x = timeIcon.x + timeIcon.width - 5;
			//timeLabel.y = timeIcon.y + 5;
			//timeLabel.width = timeLabel.textWidth + 5;
			//bodyContainer.addChild(timeLabel);
			
			var selfLabel:TextField = drawText(Locale.__e("flash:1425563160765"), {
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
			addFoodToStockBttn.addEventListener(MouseEvent.CLICK, onAddFoodToStockEvent);
			
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
			
			//кнопка покормить
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
			countAddedFeed = amountAddedFeed[hut.level];
			
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
			friendsContainer.addChild(devider);
			
			var friendsLabel:TextField = drawText(Locale.__e("flash:1425565423700"), {
				fontSize:32,
				autoSize:"left",
				textAlign:"center",
				multiline:true,
				color:0xffffff,
				borderColor:0x6c3311,
				shadowColor:0x6c3311,
				shadowSize:1
			});
			friendsLabel.x =70 + (560 - friendsLabel.textWidth)/2;
			friendsLabel.y = 210;
			friendsContainer.addChild(friendsLabel);
			
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
			
			if (hut.level == hut.totalLevels)
				return;
			
			drawMirrowObjs('upgradeDec', upgradeButton.x + 24, upgradeButton.x + upgradeButton.width - 24, upgradeButton.y, true, true, false);
			
			bodyContainer.addChild(upgradeButton);
			upgradeButton.addEventListener(MouseEvent.CLICK, onUpgradeButtonEvent);
			
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
		
		private function onUpgradeButtonEvent(e:MouseEvent):void {
			var sidNextKettle:int;
			switch(hut.level + 1) {
				case 2:
					sidNextKettle = 316;
				break;
				case 3:
					sidNextKettle = 317;
				break;
				default:
					sidNextKettle = 316;
			}
			
			hut.openUpgradeWindow(sidNextKettle);
			close();
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
		
		public var ids:Array;
		private function onFeedButtonEvent(e:MouseEvent):void {
			Window.closeAll();
			
			ids = [];
			for (var ID:* in friends) {
				if(friends[ID].used)
					ids.push(ID);
			}
			
			var friendEnergy:int = ids.length * App.data.options['FriendEnergy'];
			
			//if (App.user.stock.take(Stock.FOOD, takenFood - friendEnergy)) {
				//for each(ID in ids) {
					//App.user.friends.updateOne(ID, 'wigwam', friends[ID].time);
				//}
			//} else {
				//close();
			//}
			
			var energyObject:Object = {
				energy:takenFood - friendEnergy,
				friends:ids,
				buy:false
			}
			
			var food:Unit = Unit.add( { sid:sidKettle, buy:false, energyObject:energyObject, callback:hut.goOnFeed } );
			food.move = true;
			App.map.moved = food;
			
			//var array:Array = Map.findUnits([84,281]);	// Кухня
			//if (array.length > 0) {
				//App.map.focusedOn(array[0], true);
			//}else {
				//new SimpleWindow( {
					//title:		hut.info.title,
					//text:		Locale.__e('flash:1425038496884')
				//}).show();
			//}
		}
		
		public function updateFriends(e:*):void
		{
			for each(var ID:* in ids) {
				App.user.friends.updateOne(ID, 'wigwam', friends[ID].time);
			}
		}
		
		//со склада в прогресс бар
		private var tutorialAddFeedCounter:int = 0;
		private function onAddFeedButtonEvent(e:MouseEvent):void {
			
			if (e.currentTarget.mode == Button.DISABLED) return;
			
			if (App.user.quests.tutorial && App.user.quests.data[32] && App.user.quests.data[32].finished == 0) {
				
				if (tutorialAddFeedCounter >= 2 && hut.level < 2) 
					return;
				
				switch(hut.level) {
					case 2:
						if (tutorialAddFeedCounter >= 2 && takenFood < 30) return;
						break;
					case 3:
						if (tutorialAddFeedCounter >= 2 && takenFood < 50) return;
						break;
					case 4:
						if (tutorialAddFeedCounter >= 2 && takenFood < 70) return;
						break;
				}
					
				tutorialAddFeedCounter ++;
				
				if (tutorialAddFeedCounter < 2){
					addFeedButton.showGlowing();
					addFeedButton.showPointing('bottom', 0, addFeedButton.height + 30, describeContainer);
				}else if (tutorialAddFeedCounter >= 2) {
					addFeedButton.hideGlowing();
					addFeedButton.hidePointing();
					
					for each (var item:* in items) {
						if (item.friend.uid == '1')
							item.glow();
					}
				}
			}
			
			if (addFeedButton.mode == Button.DISABLED) {
				Hints.text(Locale.__e('flash:1426239741751'), Hints.TEXT_RED,  new Point(addFeedButton.x + addFeedButton.width/2, addFeedButton.y + 15), false, bodyContainer);
				return;
			}
			
			if (stockFood - countAddedFeed >= 0) {
				takenFood += countAddedFeed;
				stockFood -= countAddedFeed;
				//App.user.stock.take(Stock.FOOD, countAddedFeed);
				//stockFood = App.user.stock.count(Stock.FOOD);
				//анимация
				var icon:Bitmap = HutHireWindow.moveFood(foodIcon.x, foodIcon.y, foodIcon2.x, foodIcon2.y + foodIcon2.parent.y, 0.8, 1, function():void{bodyContainer.removeChild(icon);});
				bodyContainer.addChild(icon);
				updateState();
			} else {
				onAddFoodToStockEvent();
			}
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
			//анимация
			var icon:Bitmap = HutHireWindow.moveFood(foodIcon.x, foodIcon.y, foodIcon2.x, foodIcon2.y + foodIcon2.parent.y, 0.8, 1, function():void{bodyContainer.removeChild(icon);});
			bodyContainer.addChild(icon);
			updateState();
		}
		
		public function get progressData():String {
			return String(takenFood) + '/' + String(needFood);
		}
		
		public function get progressComplete():Boolean {
			return (takenFood >= needFood);
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
			
			var ids:Array = [];
			for (var ID:* in friends) {
				if (friends[ID].used)
					ids.push(ID);
			}
			
			progressBar.progress = takenFood / needFood;
			progressTitle.text = progressData;
			
			foodInStock.text = String(stockFood);
			
			if (progressBar.progress >= 1) {
				feedButton.visible = true;
				friendsContainer.alpha = 0.5;
				friendsContainer.mouseEnabled = false;		
				friendsContainer.mouseChildren = false;
				
				if (inviteButton) inviteButton.visible = false;

				//hireLabel.visible = false;
				//progressBar.visible = false;
				//progressBacking.visible = false;
				//progressTitle.visible = false;
				//foodIcon2.visible = false;
				//addFeedButton.visible = false;
				addFeedButton.state = Button.DISABLED;
				addAllFeedButton.state = Button.DISABLED;
			} else {
				addFeedButton.state = Button.NORMAL;
				addAllFeedButton.state = Button.NORMAL;
				//hireLabel.visible = true;
				//progressBar.visible = true;
				//progressBacking.visible = true;
				//progressTitle.visible = true;
				//foodIcon2.visible = true;
				//addFeedButton.visible = true;
				
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
		
		override public function drawBody():void 
		{
			friendsContainer = new Sprite();
			bodyContainer.addChild(friendsContainer);
			drawDescription();
			describeContainer.y = 40;
			friendsContainer.y = 40;
			contentChange();
			updateState();
			
			// Туторил
			if (App.user.quests.data[32] && App.user.quests.data[32].finished == 0) {
				if (describeContainer.getChildIndex(addFeedButton) < describeContainer.numChildren - 1)
					describeContainer.swapChildren(addFeedButton, describeContainer.getChildAt(describeContainer.numChildren - 1));
				
				addFeedButton.showGlowing();
				addFeedButton.showPointing('bottom', 0, addFeedButton.height + 30, describeContainer);
			}
		}
		
		public function updateEvent(e:AppEvent):void {
			stockFood = App.user.stock.count(Stock.FOOD) - takenFood;
			updateState();
		}
		
		private function onCreateBuyEvent(e:MouseEvent):void 
		{
			var canTakeEnergy:int = energyBefore - userEnergy.have;
			
			var needToBuy:int = Math.ceil((animalEnergy.all - animalEnergy.have)/ App.data.options['SpeedUpEnergy'])
			var ids:Array = [];
			for (var ID:* in friends) {
				if(friends[ID].used){
					ids.push(ID);
				}
			}
			
			if (App.user.stock.check(Stock.FOOD, canTakeEnergy)) {
				for each(ID in ids) {
					canTakeEnergy += App.data.options['FriendEnergy'];
				}
				var needEnergy:int = App.data.storage[settings.sID].energy;
				if (canTakeEnergy >= needEnergy) {
					if (!App.user.stock.take(Stock.FANT, needToBuy)) 
					{
						return;
					}
					App.user.stock.take(Stock.FOOD, energyBefore - userEnergy.have);
					for each(ID in ids) {
						App.user.friends.updateOne(ID, 'wigwam', friends[ID].time);
					}
					
				} else {
					//TODO показываем окно об ошибке
					close();
				}
				
			}
			
			createBttn.visible = false;
			createBttnBuy.visible = true;
			close();
			
			hut.hire(energyBefore - userEnergy.have, ids, true, settings['onHire']);
		}
		
		//private function onInviteEvent(e:MouseEvent):void {
			////if (inviteButton.mode == Button.DISABLED) return;
			//
			////Пытаемся отнять у пользователя энергию
			//var ids:Array = [];
			//for (var ID:* in friends) {
				//if(friends[ID].used)
					//ids.push(ID);
			//}
			//
			//var friendEnergy:int = ids.length * App.data.options['FriendEnergy'];
			//
			//if (App.user.stock.take(Stock.FOOD, takenFood - friendEnergy)) {
				//for each(ID in ids) {
					//App.user.friends.updateOne(ID, 'wigwam', friends[ID].time);
				//}
			//} else {
				//close();
			//}
			//
			//hut.hire(takenFood - friendEnergy, ids, false, function():void {
				//close();
				//settings['onHire'];
			//});
			//
			////inviteButton.state = Button.DISABLED;
		//}
		
		private function onAnotherEvent(e:MouseEvent):void {
			close();
			hut.animal = 0;
			hut.click();
		}
		
		override public function drawArrows():void {
			super.drawArrows();
			paginator.arrowLeft.x = - paginator.arrowLeft.width / 2 + 35;
			paginator.arrowRight.x = settings.width - paginator.arrowLeft.width / 2 - 35;
			
			paginator.arrowLeft.y = 350 + 30;
			paginator.arrowRight.y = 350 + 30;
			
			if (settings.content.length == 0) {
				paginator.arrowLeft.visible = false;
				paginator.arrowRight.visible = false;
			}
		}
		
		public var friendsContainer:Sprite
		override public function contentChange():void {
			for each(var _item:* in items) {
				//friendsContainer.removeChild(_item);
				_item.dispose();
			}
			items = [];
			
			var Xs:int = 85;
			var Ys:int = 260;
			var cols:int = 5;
			
			var itemNum:int = 0;
			
			if (settings.content.length > 0){
				for (var i:int = paginator.startCount; i < paginator.finishCount; i++){
					
					var item:FriendItem = new FriendItem(this, settings.content[i]);
					
					friendsContainer.addChild(item);
					item.x = Xs + ((i-paginator.startCount) % cols) * 110;
					item.y = Ys + int((i-paginator.startCount) / cols)*(item.height);
					items.push(item);
					itemNum++;
					
					//
					//	item.alpha = 0.5;
					//	item.mouseEnabled = false;
					//}
				}
				//settings.page = paginator.page;
			} 
			
			if (App.user.friends.count <= 5)
			{
				var inviteParams:Object = {
					caption:Locale.__e('flash:1382952379977'),
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
				inviteButton = new Button(inviteParams);
				inviteButton.x = 70 + (560 - inviteButton.width)/2;
				inviteButton.y = item.y + item.height + (friendsContainer.height - inviteButton.height) / 2 - 20;
				friendsContainer.addChild(inviteButton);
				inviteButton.addEventListener(MouseEvent.CLICK, onInviteEvent);
			}
			//settings.sections[settings.section].page = paginator.page;
		}
		
		private function onInviteEvent(e:MouseEvent):void
		{
			ExternalApi.apiInviteEvent();
		}
		
		public static function moveFood(startX:int, startY:int, endX:int, endY:int, scale1:Number,scale2:Number,callback:Function = null, ico:String = 'foodIco'):Bitmap {	
			var energyIcon:Bitmap = new Bitmap(Window.texture(ico));
			energyIcon.scaleX = energyIcon.scaleY = scale1;
			
			var p:Point = new Point(startX, startY);
			energyIcon.x = p.x;
			energyIcon.y = p.y;
			
			TweenLite.to(energyIcon, 0.8, { x:endX, y:endY,scaleX:scale2,scaleY:scale2, onComplete:function():void {
				energyIcon = null;
				callback();
			}});
			
			return energyIcon;
		}
	}
}

import buttons.Button;
import buttons.EnergyButton;
import com.greensock.TweenLite;
import com.greensock.TweenMax;
import core.AvaLoad;
import core.Load;
import core.Log;
import core.TimeConverter;
import flash.display.Bitmap;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.filters.GlowFilter;
import flash.geom.Point;
import flash.text.TextField;
import ui.UserInterface;
import wins.HutHireWindow;
import wins.Window;

internal class FriendItem extends Sprite
{
	private var window:HutHireWindow;
	public var bg:Bitmap;
	public var friend:Object;
	
	private var title:TextField
	private var infoText:TextField
	private var sprite:LayerX = new LayerX();
	private var avatar:Bitmap = new Bitmap();
	//public var selectBttn:EnergyButton;
	private var selectBttn:Button;
	public var _animal:uint = 0;
	
	public var friendEnergy:int = App.data.options['FriendEnergy'] || 5;
	public var restoreTime:int = App.data.options['TimeEnergy'] || 7200;
	
	public var used:Boolean = false;
	
	public function FriendItem(window:HutHireWindow, data:Object, self:Boolean = false)
	{
		this.window = window;
		
		if (self) {
			this.friend = App.user;
			bg = new Bitmap(Window.textures.friendSlot);
		} else {
			this.friend = App.user.friends.data[data.uid];
			bg = new Bitmap(Window.textures.friendSlot);
		}
		addChild(bg);
		addChild(sprite);
		sprite.addChild(avatar);
		
		//sprite.tip = function():Object
		//{
			//var text:String;
			//
			//if (_animal)
				//text = Locale.__e("flash:1382952380039")
			//else
				//text= Locale.__e("flash:1382952380040")
			//
			//return {
				//text:text
			//}
		//}
		
		var first_Name:String = '';
		if (friend.first_name && friend.first_name.length > 0)
			first_Name = friend.first_name;
		else if (friend.aka && friend.aka.length > 0) {
			first_Name = friend.aka;
		}
		
		if (first_Name.indexOf(' ') > 0) first_Name = first_Name.substring(0, first_Name.indexOf(' '));
		
		title = Window.drawText(!self ? first_Name : Locale.__e("flash:1382952380041") , {
			fontSize:23,
			color:0xffffff,
			borderColor:0x4b2e1a,
			textAlign:"center",
			fontBorderSize:1,
			shadowColor:0x4b2e1a,
			shadowSize:1
		});
		addChild(title);		
		title.width = bg.width;
		title.height = title.textHeight;
		title.x = 0;
		title.y = -6;
		
		//Load.loading(friend.photo, onLoad);
		new AvaLoad(friend.photo, onLoad);
		
		var fontSize:int = 22;
		if (App.lang == 'jp') fontSize = 14;
		selectBttn = new Button({
			caption:Locale.__e("+ "+friendEnergy),
			width:85,
			height:36,
			fontSize:fontSize,
			fontColor:0xf4ffb6,
			fontBorderColor:0x542e17,
			fontBorderSize:2,
			shadowColor:0x542e17,
			shadowSize:4,
			bgColor:[0xf5cf57, 0xeeb431],
			bevelColor:	[0xfff17f, 0xbf7e1a],
			borderColor:[0xcccccc, 0xc4b29b]
		});
		selectBttn.textLabel.x = 10;
		selectBttn.textLabel.y = 5;
		
		var foodIcon:Bitmap = new Bitmap(Window.texture('foodIco'));
		foodIcon.x = 50;
		foodIcon.y = 5;
		foodIcon.scaleX = foodIcon.scaleY = 0.5;
		foodIcon.smoothing = true;
		selectBttn.addChild(foodIcon);
		
		selectBttn.addEventListener(MouseEvent.CLICK, onSelectClick);
		
		if (friend.uid == '1')
			selectBttn.name = "HutHireWindow_user1";
		
		if(!self){
			addChild(selectBttn);		
		}
		selectBttn.x = (bg.width - selectBttn.width) / 2 + 2;
		selectBttn.y = bg.height - selectBttn.height + 27;
		
		infoText = Window.drawText("",{
			fontSize:20,
			color:0x898989,
			borderColor:0xf8f2e0
		});	
		infoText.x = (bg.width - infoText.textWidth) / 2
		infoText.y = bg.height - infoText.textHeight - 5;
		addChild(infoText);	
		
		if(!self){
			if (window.friends[friend.uid] == undefined) {
						
				if (!friend.hasOwnProperty("wigwam")){
					animal = 0;
				}else{
					animal = friend.wigwam + restoreTime < App.time ? 0 : friend.wigwam;
				}
			}else {
				animal = window.friends[friend.uid].time;
			}
		}
	}
	
	private function onSelectClick(e:MouseEvent):void
	{
		if (window.takenFood >= window.needFood) {
			return;
		}
		
		animal = App.time;
		window.friends[friend.uid] = { time:_animal, used:true };
		
		var icon:Bitmap = HutHireWindow.moveFood(window.bodyContainer.mouseX, window.bodyContainer.mouseY, window.foodIcon2.x, window.foodIcon2.y, 0.7, 1, function():void{window.bodyContainer.removeChild(icon);});
		window.bodyContainer.addChild(icon);
		
		window.takenFood += friendEnergy;
		window.updateState();
		
		unglow();
	}
	
	public function set animal(value:uint):void
	{
		_animal = value;
		if (window.friends[friend.uid] != undefined && window.friends[friend.uid]['used'] != undefined) {
			
		}else{
			window.friends[friend.uid] = { time:_animal, used:false };
		}
		
		if (_animal != 0){
			selectBttn.visible = false;
			infoText.visible = true;
			onTimerEvent();
			App.self.setOnTimer(onTimerEvent);
		}
		else
		{
			selectBttn.visible = true;
			infoText.visible = false;
		}
	}
	
	private function onTimerEvent():void {
		infoText.text = TimeConverter.timeToStr(_animal + restoreTime - App.time);
		infoText.x = 20
		infoText.y = bg.height - infoText.textHeight - 5;
	}
	
	private function onLoad(data:*):void {
		avatar.bitmapData = data.bitmapData;
		avatar.smoothing = true;
		
		var shape:Shape = new Shape();
		shape.graphics.beginFill(0x000000, 1);
		shape.graphics.drawRoundRect(0, 0, 50, 50, 12, 12);
		shape.graphics.endFill();
		sprite.mask = shape;
		sprite.addChild(shape);
		
		var scale:Number = 1.5;
		
		sprite.width *= scale;
		sprite.height *= scale;
		
		sprite.x = (bg.width - sprite.width) / 2;
		sprite.y = (bg.height - sprite.height) / 2;
	}
	
	public function glow():void {
		if (!selectBttn.visible) return;
		
		selectBttn.showGlowing();
		selectBttn.showPointing('bottom', 0, selectBttn.height + 30, this);
		
		var prnt:* = this.parent;
		if (prnt && prnt.getChildIndex(this) < prnt.numChildren - 1)
			prnt.swapChildren(this, prnt.getChildAt(prnt.numChildren - 1));
	}
	public function unglow():void {
		selectBttn.hideGlowing();
		selectBttn.hidePointing();
	}
	
	public function dispose():void
	{
		if (parent)
			parent.removeChild(this);
		
		selectBttn.removeEventListener(MouseEvent.CLICK, onSelectClick);
		App.self.setOffTimer(onTimerEvent);
		selectBttn.dispose();
	}
}