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
	import units.Garden;
	import wins.elements.TimeIcon;
	public class GardenWindow extends Window 
	{
		private var progressTitle:TextField;
		private var foodInStock:TextField;
		private var hireLabel:TextField;
		private var circle:Shape;
		private var addFoodToStockBttn:ImageButton;	//
		public var progressBar:ProgressBar;
		public var progressBacking:Bitmap;
		private var addFeedButton:Button;			//
		private var addMaxFeedButton:Button;			//
		private var countAddedFeed:int;
		public var foodIcon:Bitmap;
		public var foodIcon3:Bitmap;
		private var upgradeButton:Button;
		public var buildPaginator:Paginator;
		
		public var garden:Garden;
		public var stockFood:int = 0;
		public var takenFood:int = 0;
		public var needFood:int = 0;
		
		public static var FOOD:uint;
		
		private var amountAddedFeed:Object = {
			1:5,
			2:5,
			3:5,
			4:5
		}
		
		public function GardenWindow(settings:Object=null) 
		{
			if (settings == null) {
				settings = new Object();
			}
			
			garden = settings['target'];
			settings['width'] 			= 600;
			settings['height'] 			= 550;
			settings['sID'] 			= settings.sID || 0;
			settings['title'] 			= garden.info.title;
			settings['glowButton'] 		= settings.glowButton || false;
			settings['hasPaginator'] 	= true;
			settings["hasArrows"] 		= true;
			settings["returnCursor"] 	= false;
			settings['hasButtons']		= false;
			settings['itemsOnPage'] 	= 3;
			settings['shadowColor'] 	= 0x513f35;
			settings['shadowSize'] 		= 4;
			settings['content']			= [];
			
			settings['content'] = [];
			for each (var tree:Object in garden.trees) {
				settings.content.push(tree);
			}
			
			if (settings.content.length == 0) {
				settings.content.push({sID:184, count:0});
			}
			
			super(settings);
			
			FOOD = garden.info['in'];
			
			stockFood = App.user.stock.count(GardenWindow.FOOD);
			takenFood = garden.currFoodCount || 0;
			if (garden.info.devel.req.hasOwnProperty(garden.level))
				needFood = garden.info.devel.req[garden.level].c;
			else needFood = 0;
			
			App.self.addEventListener(AppEvent.ON_AFTER_PACK, updateEvent);
			
			settings.target.sameBuildings = Map.findUnits([settings.target.sid]);
		}
		
		override public function drawBody():void 
		{
			var searchBttn:ImageButton = new ImageButton(UserInterface.textures.lens);
			bodyContainer.addChild(searchBttn);
			searchBttn.x = 65;
			searchBttn.y = 25;
			searchBttn.addEventListener(MouseEvent.CLICK, showHelp);
			
			drawDescription();
			describeContainer.y = 40;
			updateState();			
			
			createBuildingsPaginator();
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
		
		private function showHelp(e:MouseEvent):void
		{
			new InfoWindow( {
				popup:true,
				qID:'100700'
			}).show();
		}
		
		public var describeContainer:Sprite;
		public function drawDescription():void {
			
			describeContainer = new Sprite();
			bodyContainer.addChild(describeContainer);
			
			var selfLabel:TextField = drawText(Locale.__e("flash:1445518579104", String(settings.target.info.devel.req[settings.target.level].limit)), {
				fontSize:24,
				autoSize:"left",
				textAlign:"center",
				multiline:true,
				color:0x773c18,
				borderColor:0xfaf9ec
			});
			selfLabel.x = settings.width / 2 - 220;
			selfLabel.y = 5;
			selfLabel.wordWrap = true;
			selfLabel.width = 290;
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
			inStock.y = -7;
			inStock.width = 100;
			describeContainer.addChild(inStock);
			//food icon
			foodIcon = new Bitmap();
			describeContainer.addChild(foodIcon);
			foodIcon.x = inStock.x - 10;
			foodIcon.y = 28;
			Load.loading(Config.getIcon(App.data.storage[garden.info['in']].type, App.data.storage[garden.info['in']].view), function(data:*):void {
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
			addFoodToStockBttn.y = foodInStock.y - 5;
			describeContainer.addChild(addFoodToStockBttn);
			addFoodToStockBttn.addEventListener(MouseEvent.CLICK, onAddFoodToStockEvent);
			
			//надо еды
			hireLabel = drawText(Locale.__e("flash:1445519712375"), {
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
			
			countAddedFeed = amountAddedFeed[garden.level];
			
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
				width:78,
				height:52
			};
			addFeedButton = new Button(addFeedParams);
			addFeedButton.textLabel.x -= 15;
			addFeedButton.textLabel.y += 2;
			
			foodIcon3 = new Bitmap();
			addFeedButton.addChild(foodIcon3);
			Load.loading(Config.getIcon(App.data.storage[garden.info['in']].type, App.data.storage[garden.info['in']].view), function(data:*):void {
				foodIcon3.bitmapData = data.bitmapData;
				foodIcon3.scaleX = foodIcon3.scaleY = 0.30;
				foodIcon3.smoothing = true;
				foodIcon3.x = addFeedButton.width / 2;
				foodIcon3.y = addFeedButton.height / 2 - foodIcon3.height / 2;
			});
			
			addFeedButton.x = progressBacking.x + progressBacking.width + 5;
			addFeedButton.y = 110;
			describeContainer.addChild(addFeedButton);
			addFeedButton.addEventListener(MouseEvent.CLICK, onAddFeedButtonEvent);
			addFeedButton.name = 'HutHireWindow_addFeedButton';
			
			var count:int = needFood - takenFood;
			var addMaxFeedParams:Object = {
				caption:'+' + count,
				bgColor:[0xffca4e, 0xff9c23],
				bevelColor:[0xffe88d, 0xce650d],
				borderColor:[0xc4b29b, 0xc5b39c],
				fontSize:24,
				fontColor:0xf4ffb7,
				fontBorderColor:0x542e17,
				shadowColor:0x542e17,
				shadowSize:4,
				width:78,
				height:52
			};
			addMaxFeedButton = new Button(addMaxFeedParams);
			addMaxFeedButton.textLabel.x -= 15;
			addMaxFeedButton.textLabel.y += 2;
			
			var foodIcon4:Bitmap = new Bitmap();
			addMaxFeedButton.addChild(foodIcon4);
			Load.loading(Config.getIcon(App.data.storage[garden.info['in']].type, App.data.storage[garden.info['in']].view), function(data:*):void {
				foodIcon4.bitmapData = data.bitmapData;
				foodIcon4.scaleX = foodIcon4.scaleY = 0.30;
				foodIcon4.smoothing = true;
				foodIcon4.x = addMaxFeedButton.width / 2 + 5;
				foodIcon4.y = addMaxFeedButton.height / 2 - foodIcon4.height / 2;
			});
			
			addMaxFeedButton.x = addFeedButton.x + addFeedButton.width + 5;
			addMaxFeedButton.y = 110;
			describeContainer.addChild(addMaxFeedButton);
			addMaxFeedButton.addEventListener(MouseEvent.CLICK, onAddMaxFeedButtonEvent);
			addMaxFeedButton.name = 'HutHireWindow_addMaxFeedButton';
			
			var animalsSprite:Sprite = new Sprite();
			var animalsBack:Bitmap = Window.backing2(settings.width - 20, settings.height / 2 + 50, 50, 'shopBackingTop', 'shopBackingBot');
			animalsBack.x += 10;
			animalsBack.y = settings.height / 2 - 50;
			animalsSprite.addChild(animalsBack);
			bodyContainer.addChild(animalsSprite);
			
			var titleText:TextField = drawText(Locale.__e('flash:1410167506188'), {
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
			
			if (garden.level == garden.totalLevels)
				return;
			
			drawMirrowObjs('upgradeDec', upgradeButton.x + 24, upgradeButton.x + upgradeButton.width - 24, upgradeButton.y, true, true, false);
			
			bodyContainer.addChild(upgradeButton);
			upgradeButton.addEventListener(MouseEvent.CLICK, onUpgradeButtonEvent);
			
			if (settings.glowButton) glowing();
		}
		
		private function glowing():void {
			if (addFeedButton) {
				if (!App.user.quests.tutorial) {
					addFeedButton.showGlowing();
				}
			}
		}
		
		private function onAddFeedButtonEvent(e:MouseEvent):void {
			
			if (e.currentTarget.mode == Button.DISABLED) return;
			
			if (stockFood - countAddedFeed >= 0) {
				if (takenFood + countAddedFeed > needFood) {
					countAddedFeed = needFood - takenFood;
				}
				takenFood += countAddedFeed;
				stockFood -= countAddedFeed;
				App.user.stock.take(GardenWindow.FOOD, countAddedFeed);
				
				addFeedButton.state = Button.DISABLED;
				Post.send( {
					ctr:'Garden',
					act:'fill',
					uID:App.user.id,
					wID:App.user.worldID,
					sID:garden.sid,
					id:garden.id,
					count:countAddedFeed
				}, function(error:int, data:Object, params:Object):void {					
					GardenWindow.moveFood(foodIcon.x, foodIcon.y, progressBacking.x + progressBacking.width / 2, foodIcon3.y + foodIcon3.parent.y, 0.8, 1, function():void{},garden.info['in'],bodyContainer);
					
					garden.currFoodCount = data.count;
					if (data.hasOwnProperty('slots')) {
						garden.createTrees(data.slots);
					}
					
					updateState();
				});
				//анимация
			} else {
				onAddFoodToStockEvent();
			}
		}
		
		private function onAddMaxFeedButtonEvent(e:MouseEvent):void {
			
			if (e.currentTarget.mode == Button.DISABLED) return;
			
			var countFood:int = needFood - takenFood;
			if (stockFood - countFood >= 0) {
				if (takenFood + countFood > needFood) {
					countFood = needFood - takenFood;
				}
				takenFood += countFood;
				stockFood -= countFood;
				App.user.stock.take(GardenWindow.FOOD, countFood);
				
				addMaxFeedButton.state = Button.DISABLED;
				Post.send( {
					ctr:'Garden',
					act:'fill',
					uID:App.user.id,
					wID:App.user.worldID,
					sID:garden.sid,
					id:garden.id,
					count:countFood
				}, function(error:int, data:Object, params:Object):void {					
					GardenWindow.moveFood(foodIcon.x, foodIcon.y, progressBacking.x + progressBacking.width / 2, foodIcon3.y + foodIcon3.parent.y, 0.8, 1, function():void{},garden.info['in'],bodyContainer);
					
					garden.currFoodCount = data.count;
					if (data.hasOwnProperty('slots')) {
						garden.createTrees(data.slots);
					}
					
					updateState();
				});
				//анимация
			} else {
				onAddFoodToStockEvent();
			}
		}
		
		public static function moveFood(startX:int, startY:int, endX:int, endY:int, scale1:Number,scale2:Number,callback:Function = null, icoSID:String = null, container:Sprite = null):void {	
			if (icoSID == null || container == null) return;
			var energyIcon:Bitmap = new Bitmap();
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
			garden.openUpgradeWindow();
			close();
		}
		
		public function get progressData():String {
			return String(takenFood) + '/' + String(needFood);
		}
		
		public function updateEvent(e:AppEvent):void {
			stockFood = App.user.stock.count(GardenWindow.FOOD) - takenFood;
			updateState();
		}
		
		private function onAddFoodToStockEvent(e:MouseEvent = null):void {
			new PurchaseWindow( {
				itemsOnPage:2,
				content:PurchaseWindow.createContent('Energy', { view:App.data.storage[GardenWindow.FOOD].view } ),
				title:App.data.storage[GardenWindow.FOOD].title,
				description:Locale.__e("flash:1382952379757"),
				fontBorderColor:0xd49848,
				shadowColor:0x553c2f,
				shadowSize:4,
				popup:true,
				callback:function(sID:int):void {
					updateState();
				}
			}).show();
			
			//докупить еды на склад
		}
		
		public function updateState():void {
			stockFood = App.user.stock.count(GardenWindow.FOOD);
			
			if (stockFood - countAddedFeed < 0) {
				addFeedButton.state = Button.DISABLED;
				addMaxFeedButton.state = Button.DISABLED;
				addFoodToStockBttn.visible = true;
			} else {
				addFeedButton.state = Button.NORMAL;
				addMaxFeedButton.state = Button.NORMAL;
				addFoodToStockBttn.visible = false;
			}
			
			takenFood = garden.currFoodCount;
			progressBar.progress = takenFood / needFood;
			progressTitle.text = progressData;
			
			foodInStock.text = String(stockFood);
			
			if (takenFood >= needFood) {
				addFeedButton.state = Button.DISABLED;
				addMaxFeedButton.state = Button.DISABLED;
			} else {
				addFeedButton.state = Button.NORMAL;				
				addMaxFeedButton.state = Button.NORMAL;				
			}
			
			addMaxFeedButton.caption = "+" + String(needFood - takenFood);
			addMaxFeedButton.textLabel.x = 0;
			addMaxFeedButton.textLabel.y += 2;
			
			settings['content'] = [];
			for each (var tree:Object in garden.trees) {
				settings.content.push(tree);
			}
			
			if (settings.content.length != 0) {
				paginator.itemsCount = settings.content.length;
				paginator.update();
				paginator.onPageCount = 3;
			}
			
			contentChange();
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
			if (settings.content.length != 0) {
				var X:int = 0;
				var Xs:int = X;
				var Ys:int = 290;
				sprite.x = 70;
				sprite.y = Ys;
				bodyContainer.addChild(sprite);
				
				for (var i:int = paginator.startCount; i < paginator.finishCount; i++) {
					if (settings.content[i].hasOwnProperty('count') && settings.content[i].count == 0) continue;
					var item:TreeItem = new TreeItem(this, { sID:settings.content[i].sid, count:settings.content[i].end, index:settings.content[i].inx } );
					item.x = Xs;
					items.push(item);
					sprite.addChild(item);
					
					Xs += item.bg.width + 20;
				}	
			}
			
		}
	}
}

import buttons.Button;
import buttons.EnergyButton;
import buttons.MoneyButton;
import core.Load;
import core.Size;
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

internal class TreeItem extends Sprite
{
	private var window:*;
	public var bg:Bitmap;
	public var item:Object;
	public var count:int;
	public var index:int;
	
	private var title:TextField;
	private var countText:TextField;
	private var sprite:LayerX = new LayerX();
	private var icon:Bitmap = new Bitmap();
	private var selectBttn:Button;
	public var _animal:uint = 0;
	
	public var _width:uint = 140;
	public var _height:uint = 180;
	
	public var bttn:MoneyButton;
	
	public function TreeItem(window:*, data:Object, self:Boolean = false)
	{
		this.window = window;
		
		if (data.sID) {
			item = App.data.storage[data.sID];
		} else {
			return;
		}
		
		count = data.count;
		index = data.index;
		
		bg = Window.backing(_width, _height, 10, 'itemBacking');
		addChildAt(bg, 0);
			
		addChild(sprite);
		sprite.addChild(icon);
		
		title = Window.drawText(String(item.title), {
			color:0x814f31,
			borderColor:0xfaf9ec,
			textAlign:"center",
			autoSize:"center",
			fontSize:22,
			textLeading:-6,
			multiline:true,
			wrap:true,
			width:bg.width - 20
		});
		title.y =  5;
		title.x = (bg.width - title.width)/2;
		sprite.addChild(title);
		
		countText = Window.drawText(TimeConverter.timeToStr(count - App.time), {
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
		countText.x = (bg.width - countText.textWidth) / 2;
		sprite.addChild(countText);	
		
		Load.loading(Config.getIcon(item.type, item.preview), function(data:*):void {
			if (!icon) icon = new Bitmap();
			icon.bitmapData = data.bitmapData;
			Size.size(icon, 100, 100);
			icon.x = (_width - icon.width) / 2;
			icon.y = (_height - icon.height) / 2 - 15;
			//sprite.addChild(icon);
		});
		sprite.addEventListener(MouseEvent.CLICK, onClick);
		
		var bttnSettings:Object = {
			caption:Locale.__e("flash:1382952380104"),
			width:110,
			height:40,
			fontSize:18
		};
		
		bttnSettings['bgColor'] = [0xa8f749, 0x74bc17];
		bttnSettings['borderColor'] = [0x5b7385, 0x5b7385];
		bttnSettings['bevelColor'] = [0xcefc97, 0x5f9c11];
		bttnSettings['fontColor'] = 0xffffff;			
		bttnSettings['fontBorderColor'] = 0x4d7d0e;
		bttnSettings['fontCountColor'] = 0xc7f78e;
		bttnSettings['fontCountBorder'] = 0x40680b;		
		bttnSettings['countText']	= window.garden.info.devel.skip[window.garden.level];
		
		bttn = new MoneyButton(bttnSettings);
		bttn.x = (bg.width - bttn.width) / 2;
		bttn.y = bg.y + bg.height - 20;
		bttn.addEventListener(MouseEvent.CLICK, onSpeed);
		addChild(bttn);
		
		if (data.count > App.time) {
			App.self.setOnTimer(drawTime);
			countText.y = bg.height - 55;
			bttn.visible = true;
		} else {
			countText.text = Locale.__e('flash:1445959408602');
			bttn.visible = false;
			countText.y = bg.height - 40;
		}
	}
	
	private function onClick(e:MouseEvent):void {
		Window.closeAll();
		App.ui.flashGlowing(window.garden.findTree(index));
	}
	
	private function onSpeed(e:MouseEvent):void {
		window.garden.boostAction(index, window.updateState);
	}
	
	public function drawTime():void {
		if (count - App.time <= 0) {
			countText.y = bg.height - 40;
			countText.text = Locale.__e('flash:1445959408602');
			App.self.setOffTimer(drawTime);
			bttn.visible = false;
		} else {
			countText.text = TimeConverter.timeToStr(count - App.time);
		}
	}
	
	public function dispose():void {
		icon = null;
		bg = null;
		App.self.setOffTimer(drawTime);
		sprite.removeEventListener(MouseEvent.CLICK, onClick);
		bttn.removeEventListener(MouseEvent.CLICK, onSpeed);
	}

}