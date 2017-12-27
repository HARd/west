package wins 
{
	import buttons.Button;
	import buttons.ImageButton;
	import com.greensock.TweenLite;
	import core.Load;
	import core.Post;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import ui.Hints;
	import ui.UserInterface;
	import units.Animal;
	import units.Building;
	import units.Stall;
	import wins.elements.TimeIcon;
	public class StallWindow extends Window 
	{
		private var progressTitle:TextField;
		private var foodInStock:TextField;
		private var hireLabel:TextField;
		private var circle:Shape;
		private var addFoodToStockBttn:ImageButton;	//
		public var progressBar:ProgressBar;
		public var progressBacking:Bitmap;
		private var addFeedButton:Button;			//
		private var countAddedFeed:int;
		public var foodIcon:Bitmap;
		public var foodIcon3:Bitmap;
		private var upgradeButton:Button;
		public var buildPaginator:Paginator;
		
		public var stall:Stall;
		public var stockFood:int = 0;
		public var takenFood:int = 0;
		public var needFood:int = 0;
		
		public static var FOOD:uint;
		
		private var amountAddedFeed:Object = {
			1:5,
			2:10,
			3:20,
			4:30
		}
		
		private var animalsDesc:Array = [
			{sID:184, count:0},
			{sID:196, count:0},
			{sID:490, count:0},
			{sID:159, count:0},
			{sID:823, count:0},
			{sID:824, count:0},
			{sID:1476, count:0},
			{sID:1477, count:0},
			{sID:182, count:0},
			{sID:183, count:0},
			{sID:397, count:0},
			{sID:408, count:0},
			{sID:656, count:0},
			{sID:661, count:0},
			{sID:1144, count:0},
			{sID:1516, count:0},
			{sID:1637, count:0},
			{sID:1638, count:0},
			{sID:1639, count:0},
			{sID:1640, count:0},
			{sID:1641, count:0}
		]
		
		public function StallWindow(settings:Object=null) 
		{
			if (settings == null) {
				settings = new Object();
			}
			
			stall = settings['target'];
			settings['width'] 			= 600;
			settings['height'] 			= 550;
			settings['sID'] 			= settings.sID || 0;
			settings['title'] 			= stall.info.title;
			settings['glowButton'] 		= settings.glowButton || false;
			settings['hasPaginator'] 	= true;
			settings["hasArrows"] 		= true;
			settings["returnCursor"] 	= false;
			settings['hasButtons']		= false;
			settings['itemsOnPage'] 	= 3;
			settings['shadowColor'] 	= 0x513f35;
			settings['shadowSize'] 		= 4;
			settings['content']			= [];
			
			if (stall.animals){
				for each(var anim:* in stall.animals) {
					for each(var item:Object in animalsDesc) {
						if (anim && anim.sid == item.sID) item.count++;
					}
				}
			}
			
			settings['content'] = [];
			for each (var animal:Object in animalsDesc) {
				if (animal.count != 0)
					settings.content.push(animal);
			}
			
			if (settings.content.length == 0) {
				settings.content.push({sID:184, count:0});
			}
			
			super(settings);
			
			FOOD = stall.info['in'];
			
			stockFood = App.user.stock.count(StallWindow.FOOD);
			takenFood = stall.currFoodCount || 0;
			if (stall.info.devel.req.hasOwnProperty(stall.level))
				needFood = stall.info.devel.req[stall.level].c;
			else needFood = 0;
			
			App.self.addEventListener(AppEvent.ON_AFTER_PACK, updateEvent);
			
			settings.target.sameBuildings = Map.findUnits([settings.target.sid]);
		}
		
		override public function drawBody():void 
		{
			drawDescription();
			describeContainer.y = 40;
			
			if (settings.content.length != 0) {
				paginator.itemsCount = settings.content.length;
				paginator.update();
				paginator.onPageCount = 3;
			}
			
			contentChange();
			updateState();
		}
		
		public var describeContainer:Sprite;
		public function drawDescription():void {
			
			describeContainer = new Sprite();
			bodyContainer.addChild(describeContainer);
			
			var txt1:String = Locale.__e("flash:1433758873793");
			if (settings.target.sid == 1665) txt1 = Locale.__e('flash:1457086829546');
			var selfLabel:TextField = drawText(txt1, {
				fontSize:24,
				autoSize:"left",
				textAlign:"center",
				multiline:true,
				color:0x773c18,
				borderColor:0xfaf9ec
			});
			selfLabel.x = settings.width / 2 - 220;
			selfLabel.y = 15;
			selfLabel.wordWrap = true;
			selfLabel.width = 270;
			describeContainer.addChild(selfLabel);
			
			//круг
			circle = new Shape();
			circle.graphics.beginFill(0xc8cabc, 1);
			circle.graphics.drawCircle(selfLabel.x + selfLabel.width + 100, selfLabel.y + 25, 55);
			circle.graphics.endFill();
			describeContainer.addChild(circle);
			//на складе
			var inStock:TextField = drawText(Locale.__e("flash:1409236136005"), {
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
			inStock.x = selfLabel.x + selfLabel.width + 50;
			inStock.y = 0;
			inStock.width = 100;
			describeContainer.addChild(inStock);
			//food icon
			foodIcon = new Bitmap();
			describeContainer.addChild(foodIcon);
			foodIcon.x = inStock.x - 10;
			foodIcon.y = 36;
			Load.loading(Config.getIcon(App.data.storage[stall.info['in']].type, App.data.storage[stall.info['in']].view), function(data:*):void {
				foodIcon.bitmapData = data.bitmapData;
				foodIcon.scaleX = foodIcon.scaleY = 0.5;
				foodIcon.smoothing = true;
			});
			
			//food count
			foodInStock = drawText(String(stockFood), {
				fontSize:32,
				autoSize:"center",
				textAlign:"center",
				color:0xf4ffb7,
				borderColor:0x542e17
			});
			foodInStock.x = inStock.x + 52;
			foodInStock.y = 38;
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
			var txt2:String = Locale.__e("flash:1433760265640");
			if (settings.target.sid == 1665) txt2 = Locale.__e('flash:1445519712375');
			hireLabel = drawText(txt2, {
				fontSize:28,
				autoSize:"center",
				textAlign:"center",
				multiline:true,
				color:0xffffff,
				borderColor:0x6c3311,
				shadowColor:0x6c3311,
				shadowSize:1
			});
			hireLabel.x = 70 + (365 - hireLabel.textWidth) / 2;
			hireLabel.y = 80;
			hireLabel.width = 110;
			describeContainer.addChild(hireLabel);
			
			progressBacking = Window.backingShort(280, "progBarBacking");
			progressBacking.x = 100;
			progressBacking.y = 120;
			describeContainer.addChild(progressBacking);
			
			progressBar = new ProgressBar({win:this, width:296, isTimer:false});
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
			
			countAddedFeed = amountAddedFeed[stall.level];
			
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
				height:52
			};
			addFeedButton = new Button(addFeedParams);
			addFeedButton.textLabel.x -= 15;
			addFeedButton.textLabel.y += 2;
			
			foodIcon3 = new Bitmap();
			addFeedButton.addChild(foodIcon3);
			Load.loading(Config.getIcon(App.data.storage[stall.info['in']].type, App.data.storage[stall.info['in']].view), function(data:*):void {
				foodIcon3.bitmapData = data.bitmapData;
				foodIcon3.scaleX = foodIcon3.scaleY = 0.35;
				foodIcon3.smoothing = true;
				foodIcon3.x = addFeedButton.width / 2;
				foodIcon3.y = addFeedButton.height / 2 - foodIcon3.height / 2;
			});
			
			addFeedButton.x = progressBacking.x + progressBacking.width + 15;
			addFeedButton.y = 110;
			describeContainer.addChild(addFeedButton);
			addFeedButton.addEventListener(MouseEvent.CLICK, onAddFeedButtonEvent);
			addFeedButton.name = 'HutHireWindow_addFeedButton';
			
			progressBacking.visible = true;
			progressBar.visible = true;
			progressTitle.visible = true;
			addFeedButton.visible = true;
			
			//feedButton.visible = false;
			
			var animalsSprite:Sprite = new Sprite();
			var animalsBack:Bitmap = Window.backing2(settings.width - 20, settings.height / 2 + 50, 50, 'shopBackingTop', 'shopBackingBot');
			animalsBack.x += 10;
			animalsBack.y = settings.height / 2 - 50;
			animalsSprite.addChild(animalsBack);
			bodyContainer.addChild(animalsSprite);
			
			var txt:String = Locale.__e('flash:1402910864995');
			if (settings.target.sid == 1665) txt = Locale.__e('flash:1410167506188');
			var titleText:TextField = drawText(txt, {
				color:     0xffffff,
				borderColor: 0x4f2b13,
				fontSize:  34,
				autoSize:  'center'
			});
			titleText.x = (settings.width - titleText.textWidth) / 2;
			titleText.y = animalsBack.y + 12;
			animalsSprite.addChild(titleText);
			
			
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
			upgradeButton.x = (settings.width - upgradeButton.width )/ 2;
			upgradeButton.y = settings.height - upgradeButton.height;
			
			createBuildingsPaginator();
			
			if (stall.level == stall.totalLevels)
				return;
			
			drawMirrowObjs('upgradeDec', upgradeButton.x + 24, upgradeButton.x + upgradeButton.width - 24, upgradeButton.y, true, true, false);
			
			bodyContainer.addChild(upgradeButton);
			upgradeButton.addEventListener(MouseEvent.CLICK, onUpgradeButtonEvent);
			
			if (settings.glowButton) glowing();
		}
		
		private function createBuildingsPaginator():void {
			if (settings.target.sameBuildings.length == 0) return;
			buildPaginator = new Paginator(settings.target.sameBuildings.length, 1, 9,{hasButtons:false});
			buildPaginator.addEventListener(WindowEvent.ON_PAGE_CHANGE, onBuildingPageChange);
			bodyContainer.addChild(buildPaginator);
			drawBuildingArrows();
			buildPaginator.update();
		}
		
		private function onBuildingPageChange(e:WindowEvent = null):void {
				var unit:Building = settings.target.sameBuildings[int(Math.random() * settings.target.sameBuildings.length)];
				if (unit.id == settings.target.id || unit.level == 0) {
					onBuildingPageChange();
					return;
				}
				var page:int = paginator.page;
				close();
				unit.openProductionWindow({historyPage:page});
		}
		
		public function drawBuildingArrows():void {
			buildPaginator.drawArrow(bodyContainer, Paginator.LEFT,  0, 0, { scaleX: -1, scaleY:1 } );
			buildPaginator.drawArrow(bodyContainer, Paginator.RIGHT, 0, 0, { scaleX:1, scaleY:1 } );
			
			buildPaginator.arrowLeft.x = -buildPaginator.arrowLeft.width / 2;
			buildPaginator.arrowLeft.y = 100;
			
			buildPaginator.arrowRight.x = settings.width - buildPaginator.arrowRight.width / 2 - 20;
			buildPaginator.arrowRight.y = 100;
			
			buildPaginator.x = int((settings.width - buildPaginator.width)/2 - 40);
			buildPaginator.y = int(settings.height - buildPaginator.height - 15);
		}
		
		private function glowing():void {
			if (addFeedButton) {
				if (!App.user.quests.tutorial) {
					addFeedButton.showGlowing();
					/*priceBttn.showPointing("bottom", 0, priceBttn.height + 30, priceBttn.parent);
					priceBttn.name = 'bttn_shop_item_find';
				}else {
					customGlowing(priceBttn);*/
				}
			}
		}
		
		private function onAddFeedButtonEvent(e:MouseEvent):void {
			
			if (e.currentTarget.mode == Button.DISABLED) return;
			
			if (addFeedButton.mode == Button.DISABLED) {
				Hints.text(Locale.__e('flash:1426239741751'), Hints.TEXT_RED,  new Point(addFeedButton.x + addFeedButton.width/2, addFeedButton.y + 15), false, bodyContainer);
				return;
			}
			
			if (stockFood - countAddedFeed >= 0) {
				if (takenFood + countAddedFeed > needFood) {
					countAddedFeed = needFood - takenFood;
				}
				takenFood += countAddedFeed;
				stockFood -= countAddedFeed;
				App.user.stock.take(StallWindow.FOOD, countAddedFeed);
				Post.send( {
					ctr:'Stall',
					act:'fill',
					uID:App.user.id,
					wID:App.user.worldID,
					sID:stall.sid,
					id:stall.id,
					count:countAddedFeed
				}, function(error:int, data:Object, params:Object):void {
					/*var icon:Bitmap = HutHireWindow.moveFood(foodIcon.x, foodIcon.y, progressBacking.x + progressBacking.width / 2, foodIcon3.y + foodIcon3.parent.y, 0.8, 1, function():void{bodyContainer.removeChild(icon);},'forageIco');
					bodyContainer.addChild(icon);*/
					
					StallWindow.moveFood(foodIcon.x, foodIcon.y, progressBacking.x + progressBacking.width / 2, foodIcon3.y + foodIcon3.parent.y, 0.8, 1, function():void{/*bodyContainer.removeChild(icon);*/},stall.info['in'],bodyContainer);
					
					stall.currFoodCount = data.count;
					stall.checkAnimals();
					
					updateState();
				});
				//анимация
			} else {
				onAddFoodToStockEvent();
			}
		}
		
		public static function moveFood(startX:int, startY:int, endX:int, endY:int, scale1:Number,scale2:Number,callback:Function = null, icoSID:String = null, container:Sprite = null):void {	
			if (icoSID == null || container == null) return;
			var energyIcon:Bitmap = new Bitmap(/*Window.texture(ico)*/);
			container.addChild(energyIcon);
			Load.loading(Config.getIcon(App.data.storage[icoSID].type, App.data.storage[icoSID].view), function(data:*):void {
				var p:Point = new Point(startX, startY);
				energyIcon.scaleX = energyIcon.scaleY = scale1;
				energyIcon.x = p.x;
				energyIcon.y = p.y;
				
				TweenLite.to(energyIcon, 0.8, { x:endX, y:endY, scaleX:scale2, scaleY:scale2, onComplete:function():void {
					container.removeChild(energyIcon);
					energyIcon = null;
					callback();
				}});
			});
			
		}
		
		private function onUpgradeButtonEvent(e:MouseEvent):void {
			stall.openUpgradeWindow();
			close();
		}
		
		public function get progressData():String {
			return String(takenFood) + '/' + String(needFood);
		}
		
		public function updateEvent(e:AppEvent):void {
			stockFood = App.user.stock.count(StallWindow.FOOD) - takenFood;
			updateState();
		}
		
		private function onAddFoodToStockEvent(e:MouseEvent = null):void {
			new PurchaseWindow( {
				itemsOnPage:2,
				content:PurchaseWindow.createContent('Energy', { view:App.data.storage[StallWindow.FOOD].view } ),
				title:Locale.__e("flash:1396606700679"),
				description:Locale.__e("flash:1382952379757"),
				fontBorderColor:0xd49848,
				shadowColor:0x553c2f,
				shadowSize:4,
				popup:true,
				closeAfterBuy:false,
				callback:function(sID:int):void {
					updateState();
				}
			}).show();
			
			//докупить еды на склад
		}
		
		public function updateState():void {
			stockFood = App.user.stock.count(StallWindow.FOOD);
			
			if (stockFood - countAddedFeed < 0) {
				addFeedButton.state = Button.DISABLED;
				addFoodToStockBttn.visible = true;
			} else {
				addFeedButton.state = Button.NORMAL;
				addFoodToStockBttn.visible = false;
			}
			
			progressBar.progress = takenFood / needFood;
			progressTitle.text = progressData;
			
			foodInStock.text = String(stockFood);
			
			if (progressBar.progress >= 1) {
				//feedButton.visible = true;
				addFeedButton.state = Button.DISABLED;
			} else {
				addFeedButton.state = Button.NORMAL;				
				//feedButton.visible = false;
			}
		}
		
		override public function drawArrows():void {
			paginator.drawArrow(bodyContainer, Paginator.LEFT,  0, 0, { scaleX: -1, scaleY:1 } );
			paginator.drawArrow(bodyContainer, Paginator.RIGHT, 0, 0, { scaleX:1, scaleY:1 } );
			
			var y:Number = (settings.height - paginator.arrowLeft.height) / 2 + settings.height / 4;
			paginator.arrowLeft.x = 50 - paginator.arrowLeft.width;
			paginator.arrowLeft.y = y - 27;
			
			paginator.arrowRight.x = settings.width - 50;
			paginator.arrowRight.y = y - 27;
			
			paginator.x = (settings.width - paginator.width) / 2 - 30;
			paginator.y = settings.height - 30;
		}
	
		private var items:Array;
		private var sprite:Sprite = new Sprite();
		override public function contentChange():void {
			if (items) {
				for each(var _item:* in items) {
					sprite.removeChild(_item);
					_item.dispose();
				}
			}
			items = [];
			
			var X:int = 0;
			var Xs:int = X;
			var Ys:int = 290;
			var i:int = 0;
			var item:AnimalItem;
			sprite.y = Ys;
			if (settings.target.limit != 0) {
				bodyContainer.addChild(sprite);
				
				for (i = 0; i < settings.target.limit; i++) {
					var s:int = (i < settings.target.animals.length) ? settings.target.animals[i].sid : 0;
					item = new AnimalItem(this, { sID:s, count:1, help:true } );
					item.x = Xs;
					items.push(item);
					sprite.addChild(item);
					
					Xs += item.bg.width + 20;
				}
				
				sprite.x = (settings.width - sprite.width) / 2;
			}else {
				if (settings.content.length != 0) {
					sprite.x = 70;
					bodyContainer.addChild(sprite);
					
					for (i = paginator.startCount; i < paginator.finishCount; i++) {
						if (settings.content[i].count == 0) continue;
						item = new AnimalItem(this, { sID:settings.content[i].sID, count:settings.content[i].count } );
						item.x = Xs;
						items.push(item);
						sprite.addChild(item);
						
						Xs += item.bg.width + 20;
					}	
				}
			}
			
		}
	}
}

import buttons.Button;
import buttons.EnergyButton;
import buttons.ImageButton;
import core.Load;
import core.Size;
import flash.display.Bitmap;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.filters.GlowFilter;
import flash.geom.Point;
import flash.text.TextField;
import ui.UserInterface;
import units.Animal;
import wins.HutHireWindow;
import wins.InfoWindow;
import wins.SimpleWindow;
import wins.ShopWindow;
import wins.StallWindow;
import wins.Window;

internal class AnimalItem extends Sprite
{
	private var window:StallWindow;
	public var bg:Bitmap;
	public var item:Object;
	
	private var title:TextField;
	private var countText:TextField;
	private var sprite:LayerX = new LayerX();
	private var icon:Bitmap = new Bitmap();
	private var selectBttn:Button;
	private var searchBttn:Button;
	private var helpBttn:ImageButton;
	public var _animal:uint = 0;
	
	public var _width:uint = 140;
	public var _height:uint = 180;
	
	public var help:Boolean = false;
	
	public function AnimalItem(window:StallWindow, data:Object, self:Boolean = false)
	{
		this.window = window;
		
		if (data.hasOwnProperty('help')) {
			this.help = data.help;
		}
		
		bg = Window.backing(_width, _height, 10, 'itemBacking');
		addChildAt(bg, 0);
			
		addChild(sprite);
		
		if (help) {
			drawHelp();
		}
		
		if (data.sID) {
			item = App.data.storage[data.sID];
		} else {
			if (help) drawSearch();
			return;
		}
		
		title = Window.drawText(String(item.title), {
			color:0x814f31,
			borderColor:0xfaf9ec,
			textAlign:"center",
			autoSize:"center",
			fontSize:24,
			textLeading:-6,
			multiline:true,
			wrap:true,
			width:bg.width - 20
		});
		title.y = 10;
		title.x = (bg.width - title.width)/2;
		sprite.addChild(title);
		
		countText = Window.drawText('x' + String(data.count), {
			color:0xffffff,
			borderColor:0x8c502e,
			textAlign:"center",
			autoSize:"center",
			fontSize:24,
			textLeading:-6,
			multiline:true,
			wrap:true,
			width:bg.width - 20
		});
		countText.y = bg.height - 40;
		countText.x = bg.width - 35;
		sprite.addChild(countText);
		
		Load.loading(Config.getIcon(item.type, item.preview), function(data:*):void {
			icon.bitmapData = data.bitmapData;
			icon.x = (_width - icon.width) / 2;
			icon.y = (_height - icon.height) / 2;
			sprite.addChild(icon);
		});
	}
	
	public function drawHelp():void {
		helpBttn = new ImageButton(UserInterface.textures.lens);
		Size.size(helpBttn, 30, 30);
		addChild(helpBttn);
		helpBttn.x = 100;
		helpBttn.y = 10;
		helpBttn.addEventListener(MouseEvent.CLICK, showHelp);
	}
	
	private function showHelp(e:MouseEvent):void {
		new InfoWindow( {
			popup:true,
			qID:'100400'
		}).show();
	}
	
	private function drawSearch():void {
		searchBttn = new Button( {
			caption:Locale.__e('flash:1405687705056'),
			width:120,
			height:38
		});
		searchBttn.x = (bg.width - searchBttn.width) / 2;
		searchBttn.y = bg.height - searchBttn.height - 5;
		addChild(searchBttn);
		searchBttn.addEventListener(MouseEvent.CLICK, findAnimal);
	}
	
	private function findAnimal(e:MouseEvent):void {
		window.close();
		var unitsSIDs:Array = [1476, 1477];
		if (window.settings.target.animals.length != 0) {
			unitsSIDs = [window.settings.target.animals[0].sid];
		}
		var anim:Array = findUnits(unitsSIDs);
		if (anim.length > 0) {
			App.map.focusedOn(anim[0], true);
		}else {
			ShopWindow.findMaterialSource(unitsSIDs[0])
		}
	}
	
	public function findUnits(sIDs:Array):Array{
		if (!App.map) return new Array();
		var result:Array = [];
		var i:int = App.map.mSort.numChildren;
		while (--i >= 0)
		{
			var unit:* = App.map.mSort.getChildAt(i);
			var index:int = sIDs.indexOf(unit.sid);
			if (index != -1 && !(unit as Animal).inStall)
			{
				result.push(unit);
			}
		}
		
		return result;
	}
	
	public function dispose():void {
		if (helpBttn) helpBttn.removeEventListener(MouseEvent.CLICK, showHelp);
		if (searchBttn) searchBttn.removeEventListener(MouseEvent.CLICK, findAnimal);
		icon = null;
		bg = null;
	}

}