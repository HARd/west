package wins 
{
	import adobe.utils.ProductManager;
	import buttons.Button;
	import buttons.MoneyButton;
	import core.Load;
	import core.Numbers;
	import core.Size;
	import flash.display.DisplayObject;
	import flash.display.GradientType;
	import flash.display.Shape;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import ui.Hints;
	import units.Building;
	import units.Unit;
	import wins.elements.ProductionItem;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;

	public class ProductionWindow extends Window
	{
		
		public static var find:*;
		
		public static var container:Sprite;
		private var infoContainer:Sprite;
		private var infoLimitContainer:Sprite;
		private var itemContainer:Sprite;
		private var craftContainer:Sprite;
		protected var productionEmptyLabel:TextField;
		
		private var craftBacking:Shape;
		private var craftIcon:Bitmap;
		private var craftLabel:TextField;
		private var infoLabel:TextField;
		private var infoLimitLabel:TextField;
		private var craftProgressBar:ProgressBar;
		private var progressBarBacking:Bitmap;
		private var craftBoostBttn:MoneyButton;
		private var craftStorageBttn:Button;
		
		public var progressBar:ProgressBar;
		public var progressBacking:Bitmap;
		private var progressTitle:TextField;
		
		private var items:Vector.<ProductionItem> = new Vector.<ProductionItem>;
		public var crafts:Array = [];
		public var target:*;
		
		private var history:int = 0;
		
		public var buildPaginator:Paginator;
		
		public function ProductionWindow(settings:Object = null) 
		{
			target = settings['target'];
			
			settings['title'] = (target && target.hasOwnProperty('info')) ? target.info.title : Locale.__e('flash:1382952380292');
			settings['width'] = settings.width || 580;
			settings['height'] = settings.height || 650;
			settings['hasPaginator'] = true;
			settings['itemsOnPage'] = 6;
			settings['page'] = settings.historyPage || history;
			settings['shadowSize'] = 4;
			settings['shadowColor'] = 0x543b36;
			
			if (!find && settings.hasOwnProperty('find')) {
				if (settings.find is Array) {
					find = settings.find[0];
				}else if (settings.find is int) {
					find = settings.find;
				}
			}
			
			checkCraft();
			
			if (crafts.length <= settings.itemsOnPage / 2) {
				settings['height'] -= 190;
			}
			
			super(settings);
			
			target.sameBuildings = Map.findUnits([target.sid]);
			
			App.self.setOnTimer(timer);
		}
		
		public function checkCraft():void {
			if (target.info.hasOwnProperty('devel') && target.info.devel.hasOwnProperty('craft')) {
				for (var lvl:* in target.info.devel.craft) {
					for each(var pid:* in target.info.devel.craft[lvl]) {
						//if (pid == 670)
							//trace();
						
						if (!App.data.crafting.hasOwnProperty(pid)) continue;
						var craft:Object = App.data.crafting[pid];
						var skip:Boolean = false;
 						if (craft.hasOwnProperty('assoc') && craft.assoc != '') {
							if (int(craft.assoc) > 0) {
								//if (!App.user.stock.check(craft.assoc, 1))
									//skip = true;
							}	
						}
						for (var sid:* in craft.items) {
							//if (!User.inUpdate(sid))
								//skip = true;
						}
						//if (!User.inUpdate(craft.out))
							//skip = true;
						if (craft.hasOwnProperty('expire') && craft.expire.hasOwnProperty(App.social) && craft.expire[App.social] <= App.time)
							skip = true;
							
						if (craft.hasOwnProperty('exclude') && craft.exclude != 0 && craft.exclude.indexOf(App.social) != -1)
							skip = true;
						
						if (!skip) 
							crafts.push(craft);
					}
				}
			}
			
			crafts.sortOn('order', Array.NUMERIC);
		}
		
		override public function drawBackground():void {
			background = backing2(settings.width, settings.height, 180, 'shopBackingTop', 'backingBot');
			if (App.user.worldID == Travel.SAN_MANSANO) {
				background = backing2(settings.width, settings.height, 50, 'topBacking', 'bottomBacking3');
			}
			layer.addChild(background);
		}
		
		override public function titleText(settings:Object):Sprite
		{
			var titleCont:Sprite = new Sprite();
			var mirrorDec:String = 'titleDecRose';
			var indent:int = 0;
			if (App.user.worldID == Travel.SAN_MANSANO) {
				mirrorDec = 'goldTitleDec2';
				indent = -10;
			}
			
			if (settings.mirrorDecor) {
				mirrorDec = settings.mirrorDecor;
			}
			
			var textLabel:TextField = Window.drawText(settings.title, settings);
			if (this.settings.hasTitle == true && this.settings.titleDecorate == true) {
				drawMirrowObjs(mirrorDec, textLabel.x + (textLabel.width - textLabel.textWidth) / 2 - 75, textLabel.x + (textLabel.width - textLabel.textWidth) / 2 + textLabel.textWidth + 75, textLabel.y + (textLabel.height - 40) / 2 + indent, false, false, false, 1, 1, titleCont);
			}
			
			titleCont.mouseChildren = false;
			titleCont.mouseEnabled = false;
			titleCont.addChild(textLabel);
			
			return titleCont;
		}
		
		override public function drawBody():void {
			var backing:Bitmap;
			if (App.user.worldID == Travel.SAN_MANSANO) {
				backing = backingShort(settings.width - ((crafts.length <= settings.itemsOnPage / 2) ? 2 : 0), 'bottomBacking1');
				backing.y = settings.height - 290;
			}else {
				backing = backingShort(settings.width - ((crafts.length <= settings.itemsOnPage / 2) ? 2 : 0), 'shopBackingBot');
				backing.y = settings.height - 380;
			}
			backing.x = ((crafts.length <= settings.itemsOnPage / 2) ? 1 : 0);
			bodyContainer.addChild(backing);
			
			productionEmptyLabel = drawText(Locale.__e('flash:1423649490997'), {
				width:			400,
				fontSize:		26,
				color:			0xFFFFFF,
				borderColor:	0x5d411e,
				autoSize:		"center",
				textAlign:		"center",
				multiline:		true,
				wrap:			true,
				shadowSize:		2
			});
			productionEmptyLabel.x = (settings.width - productionEmptyLabel.width) / 2;
			productionEmptyLabel.y = 190;
			bodyContainer.addChild(productionEmptyLabel);
			
			container = new Sprite();
			container.x = 56;
			container.y = 20;
			bodyContainer.addChild(container);
			
			// Craft
			craftContainer = new Sprite();
			craftContainer.y = settings.height - 175;
			bodyContainer.addChild(craftContainer);
			
			itemContainer = new Sprite();
			itemContainer.y = settings.height - 175;
			bodyContainer.addChild(itemContainer);
			
			var matrix:Matrix = new Matrix();
			matrix.createGradientBox(90, 90);
			
			craftBacking = new Shape();
			craftBacking.graphics.beginGradientFill(GradientType.LINEAR, [0x648a95, 0x85abb8], [1, 1], [0, 255], matrix);
			craftBacking.graphics.drawCircle(45, 45, 45);
			craftBacking.graphics.endFill();
			craftBacking.x = 50;
			craftBacking.y = 0;
			itemContainer.addChild(craftBacking);
			
			craftIcon = new Bitmap();
			itemContainer.addChild(craftIcon);
			
			craftLabel = drawText(Locale.__e('flash:1404823388967', ['']), {
				width:		300,
				color:		0xf2fefe,
				borderColor:0x072d42,
				fontSize:	27,
				multiline:	true,
				textAlign:	'center',
				autoSize:	'center',
				wrap:		true,
				shadowSize:	2
			});
			craftLabel.x = 140;
			craftLabel.y = 9;
			craftContainer.addChild(craftLabel);
			
			progressBarBacking = Window.backingShort(280, 'progressBar');
			progressBarBacking.x = (settings.width - progressBarBacking.width) / 2;
			progressBarBacking.y = craftLabel.y + craftLabel.height + 6;
			craftContainer.addChild(progressBarBacking);
			
			craftProgressBar = new ProgressBar( { width:276, win:this } );
			craftProgressBar.x = progressBarBacking.x + 2;
			craftProgressBar.y = progressBarBacking.y + 3;
			craftContainer.addChild(craftProgressBar);
			craftProgressBar.start();
			
			craftBoostBttn = new MoneyButton( {
				width:		100,
				height:		64,
				caption:	Locale.__e('flash:1382952380104'),
				multiline:	true,
				fontSize:	24
			});
			craftBoostBttn.x = settings.width - craftBoostBttn.width - 35;
			craftBoostBttn.y = 15;
			craftBoostBttn.addEventListener(MouseEvent.CLICK, onCraftBoost);
			craftContainer.addChild(craftBoostBttn);
			
			craftStorageBttn = new Button( {
				width:			220,
				height:			52,
				caption:		Locale.__e('flash:1382952379737'),
				fontSize:		27
			});
			craftStorageBttn.x = (settings.width - craftStorageBttn.width) / 2 + 30;
			craftStorageBttn.y = settings.height - 149;
			craftStorageBttn.addEventListener(MouseEvent.CLICK, onCraftStorage);
			bodyContainer.addChild(craftStorageBttn);
			
			// Info
			infoContainer = new Sprite();
			infoContainer.y = settings.height - 175;
			bodyContainer.addChild(infoContainer);
			
			infoLabel = drawText(Locale.__e('flash:1382952379994'), {
				width:		settings.width - 40,
				color:		0xf2fefe,
				borderColor:0x072d42,
				fontSize:	28,
				textAlign:	'center',
				shadowSize:	2
			});
			infoLabel.x = 20;
			infoLabel.y = 25;
			infoContainer.addChild(infoLabel);
			
			// Info limit
			infoLimitContainer = new Sprite();
			infoLimitContainer.y = settings.height - 175;
			bodyContainer.addChild(infoLimitContainer);
			
			infoLimitLabel = drawText(Locale.__e('flash:1451407980421'), {
				width:		settings.width - 40,
				color:		0xf2fefe,
				borderColor:0x072d42,
				fontSize:	22,
				textAlign:	'center',
				shadowSize:	2
			});
			infoLimitLabel.x = 20;
			infoLimitLabel.y = 15;
			infoLimitContainer.addChild(infoLimitLabel);
			
			progressBacking = Window.backingShort(280, "progBarBacking");
			progressBacking.x = (settings.width - progressBacking.width) / 2;
			progressBacking.y = 55;
			infoLimitContainer.addChild(progressBacking);
			
			progressBar = new ProgressBar({win:this, width:296, isTimer:false});
			progressBar.x = progressBacking.x - 8;
			progressBar.y = progressBacking.y - 4;
			infoLimitContainer.addChild(progressBar);
			progressBar.progress = target.climit / target.totalLimit;
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
			infoLimitContainer.addChild(progressTitle);
			
			// Find
			paginator.x = 60;
			paginator.y = settings.height - 167;
			paginator.itemsCount = crafts.length;
			paginator.page = settings.page;
			if (crafts.length < paginator.onPageCount) paginator.visible = false;
			
			var i:int;
			if (!(find is Array) > 0) {
				for (i = 0; i < crafts.length; i++) {
					if (crafts[i].out == find) {
						paginator.page = Math.floor(i / paginator.onPageCount);
						break;
					}
				}
			}else if (find.length > 0) {
				for (i = 0; i < crafts.length; i++) {
					if (crafts[i].out == find[0]) {
						paginator.page = Math.floor(i / paginator.onPageCount);
					}
				}
			}
			if (target.helpTarget != 0 && find == 0) {
				for (i = 0; i < crafts.length; i++) {
					if (crafts[i].out == target.helpTarget) {
						paginator.page = Math.floor(i / paginator.onPageCount);
						break;
					}
				}
			}
			paginator.update();
			
			craftContainer.visible = false;
			itemContainer.visible = false;
			infoContainer.visible = false;
			infoLimitContainer.visible = false;
			craftStorageBttn.visible = false;
			
			updateState();
			
			contentChange();
			
			if (App.isSocial('VK', 'DM', 'FS', 'ML', 'OK')) createBuildingsPaginator();
			
			if (App.user.id == '120635122') createComponentItems();
		}
		
		public function get progressData():String {
			return String(target.climit) + '/' + String(target.totalLimit);
		}
		
		override public function drawArrows():void {
			super.drawArrows();
			
			if (crafts.length > settings.itemsOnPage / 2) {
				paginator.arrowLeft.y = 170;
				paginator.arrowRight.y = 170;
			}else {
				paginator.arrowLeft.y = 100;
				paginator.arrowRight.y = 100;
			}
		}
		
		override public function contentChange():void {
			clear();
			
			for (var i:int = 0; i < settings.itemsOnPage; i++) {
				if (crafts.length <= paginator.page * settings.itemsOnPage + i) continue;
				
				var craft:Object = crafts[paginator.page * settings.itemsOnPage + i];
				var show:Boolean = true;
				if (craft.hasOwnProperty('assoc') && craft.assoc != '') {
					if (int(craft.assoc) > 0) {
						if (!App.user.stock.check(craft.assoc, 1))
							show = false;
					}
				}
				var item:ProductionItem = new ProductionItem(this, {
					height:170,
					width:145,
					crafting:craft,
					craftData:crafts,
					canShow:show
				});
				item.x = (i % 3) * 160;
				item.y = Math.floor(i / 3) * 200;
				container.addChild(item);
				items.push(item);
				
				if (!(find is Array)) {
					if (craft.out == find) {
						//item.glow(find);
						item.name = 'findItem';
						find = 0;
					}
				}else {
					if (find.indexOf(int(craft.out)) != -1) {
						item.name = 'findItem';
					}
				}
			}
			
			if (items.length == 0) {
				productionEmptyLabel.visible = true;
			}else {
				productionEmptyLabel.visible = false;
			}
			
			find = 0;
			for each (var obj:ProductionItem in items) {
				if (obj.name && obj.name == 'findItem') {
					container.setChildIndex(obj, items.length - 1);
					obj.glow(find);
				}
			}
		}
		
		private function clear():void {
			while (items.length) {
				var item:ProductionItem = items.shift();
				item.dispose();
				if (container.contains(item)) container.removeChild(item);
				item = null;
			}
		}
		
		private function createBuildingsPaginator():void {
			if (target.sameBuildings.length == 0) return;
			buildPaginator = new Paginator(target.sameBuildings.length, 1, 9, {hasButtons:false});
			buildPaginator.addEventListener(WindowEvent.ON_PAGE_CHANGE, onBuildingPageChange);
			bodyContainer.addChild(buildPaginator);
			drawBuildingArrows();
			buildPaginator.update();
		}
		
		private function onBuildingPageChange(e:WindowEvent = null):void {
				var unit:Building = target.sameBuildings[int(Math.random() * target.sameBuildings.length)];
				var non_present:Boolean = containsBuildingByCondition('non_present');
				var non_crafting:Boolean = containsBuildingByCondition('non_crafting');
				if (unit.id == target.id || unit.level < unit.totalLevels) {
					onBuildingPageChange();
					return;
				}
				if (((unit.hasPresent && non_present) || (unit.crafted > 0 && unit.crafted >= App.time && unit.formula && non_crafting)) && !(non_present && non_crafting)) {
					onBuildingPageChange();
					return;
				}
				var page:int = paginator.page;
				close();
				unit.openProductionWindow({historyPage:page});
		}
		
		private function containsBuildingByCondition(condition:String):Boolean {
			var building:Building;
			switch(condition) {
				case 'non_present':
					for each (building in target.sameBuildings) {
						if (building.level < building.totalLevels) continue;
						if (!building.hasPresent)
							return true;
					}
					break;
				case 'non_crafting':
					for each (building in target.sameBuildings) {
						if (building.level < building.totalLevels) continue;
						if (building.crafted > 0 && building.crafted >= App.time && building.formula) continue;
						return true;
					}
					break;
			}
			return false;
		}
		
		public function drawBuildingArrows():void {
			buildPaginator.drawArrow(bodyContainer, Paginator.LEFT,  0, 0, { scaleX: -1, scaleY:1 } );
			buildPaginator.drawArrow(bodyContainer, Paginator.RIGHT, 0, 0, { scaleX:1, scaleY:1 } );
			
			buildPaginator.arrowLeft.x = -buildPaginator.arrowLeft.width / 2;
			buildPaginator.arrowLeft.y = 400;
			
			buildPaginator.arrowRight.x = settings.width - buildPaginator.arrowRight.width / 2;
			buildPaginator.arrowRight.y = 400;
			
			buildPaginator.x = int((settings.width - buildPaginator.width)/2 - 40);
			buildPaginator.y = int(settings.height - buildPaginator.height - 15);
		}
		
		private var _state:int = 0;
		protected function updateState():void {
			if (target && target.crafted > App.time && _state != 1) {
				craftBoostBttn.countLabelText = Numbers.speedUpPrice(target.crafted - App.time);
				
				var formulaID:int = (typeof(target.fID) == 'object' && Numbers.countProps(target.fID) > 0 && target.fID.hasOwnProperty('0')) ? target.fID[0] : target.fID;
				
				var title:String = '';
				var _out:int = App.data.crafting[formulaID].out
				title = App.data.storage[_out].title;
				craftLabel.text = Locale.__e('flash:1404823388967', [title]);
				
				if (App.data.crafting[formulaID].count > 1) {
					craftLabel.appendText(' x' + String(App.data.crafting[formulaID].count));
				}
				
				if (craftLabel.numLines > 1)
				{
					craftLabel.text = Locale.__e('flash:1404461744090') + "\n" + title;
					craftLabel.y -= 15;
				}
				
				craftContainer.visible = true;
				itemContainer.visible = true;
				infoContainer.visible = false;
				craftStorageBttn.visible = false;
				loadItem();
				_state = 1;
			}else if (target && target.crafted > 0 && target.crafted <= App.time && /*target.completed.length > 0 &&*/ _state != 2) {
				loadItem();
				craftContainer.visible = false;
				itemContainer.visible = true;
				infoContainer.visible = false;
				craftStorageBttn.visible = true;
				craftStorageBttn.state = Button.NORMAL;
				_state = 2;
			}else if (target && target.crafted == 0 && /*target.completed.length == 0 &&*/ _state != 3) {
				if (craftContainer) craftContainer.visible = false;
				if (itemContainer) itemContainer.visible = false;
				if (infoContainer) infoContainer.visible = true;
				if (craftStorageBttn) craftStorageBttn.visible = false;
				if (target.totalLimit > 0 && target.climit > -1) {
					if (infoLimitContainer) {
						infoLimitContainer.visible = true;
						progressTitle.text = progressData;
					}
					if (infoContainer) infoContainer.visible = false;
				}
			}
		}
		
		protected function timer():void {
			if (!craftProgressBar) return;
			if (target && target.crafted >= App.time) {
				craftProgressBar.progress = (App.time - (target.crafted - target.formula.time)) / target.formula.time;
				craftProgressBar.time = target.crafted - App.time;
				
			}
			
			updateState();
		}
		
		private function onCraftBoost(e:MouseEvent):void {
			if (craftStorageBttn.mode == Button.DISABLED) return;
			//craftStorageBttn.state = Button.DISABLED;
			
			if (target && target.crafted > App.time) {
				if (target.hasOwnProperty('boostEvent')) {
					target.boostEvent();
				}else{
					target.onBoostEvent(Numbers.speedUpPrice(target.crafted - App.time));
				}
			}
		}
		
		private function onCraftStorage(e:MouseEvent):void {
			if (craftStorageBttn.mode == Button.DISABLED) {
				Hints.text(Locale.__e('flash:1382952379927') + '!', 9, new Point(mouseX, mouseY));
				return;
			}
			craftStorageBttn.state = Button.DISABLED;
			
			//if (target && target.completed.length > 0)
			if (target && target.crafted > 0 && target.crafted <= App.time)
				target.storageEvent();
		}
		
		public function onCook(fID:*):void {
			settings.onCraftAction(fID);
		}
		
		public function get busy():Boolean {
			if (target && target.crafted > 0)
				return true;
			
			return false;
		}
		
		private function loadItem():void {
			if (target && target.formula && target.formula['out']) {
				Load.loading(Config.getIcon(App.data.storage[target.formula.out].type, App.data.storage[target.formula.out].preview), onLoad);
			}
		}
		
		private function onLoad(data:Bitmap):void {
			craftBacking;
			craftIcon.bitmapData = data.bitmapData;
			craftIcon.smoothing = true;
			Size.size(craftIcon, craftBacking.width, craftBacking.height);
			craftIcon.x = craftBacking.x + (craftBacking.width - craftIcon.width) / 2;
			craftIcon.y = craftBacking.y + (craftBacking.height - craftIcon.height) / 2;
		}
		
		
		private var components:Vector.<ComponentItem>;
		private var componentList:Object;
		private var componentContainer:Sprite;
		private var componentPaginator:Paginator;
		public function createComponentItems():void {
			if (!components) components = new Vector.<ComponentItem>;
			
			componentList = Storage.componentsGet(App.map.id, target.sid);
			for (var id:* in componentList) {
				components.push(new ComponentItem( { sid:target.sid, id:id, click:onComponent } ));
			}
			
			// Для добавления
			components.push(new ComponentItem( { id:0, click:onComponent } ));
			
			componentPaginator = new Paginator(components.length, 1, 0, {
				hasButtons:	false,
				hasPoints:	false
			});
			
			if (!componentContainer) {
				componentContainer = new Sprite();
				componentContainer.x = 40;
				componentContainer.y = 500;
				bodyContainer.addChild(componentContainer);
			}
			
			componentContentChange();
		}
		private function componentContentChange():void {
			
			componentContentClear();
			
			for (var i:int = componentPaginator.page; i < componentPaginator.itemsCount; i++) {
				if (i < 0 || components.length <= i) continue;
				
				var item:ComponentItem = components[i];
				item.x = componentContainer.numChildren * 110;
				componentContainer.addChild(item);
			}
		}
		private function componentContentClear():void {
			while (componentContainer && componentContainer.numChildren) {
				var child:* = componentContainer.getChildAt(0);
				if (child is ComponentItem) {
					child.dispose();
				}else{
					componentContainer.removeChild(child);
				}
			}
		}
		public function onComponent(item:ComponentItem):void {
			if (item.id == 0) {
				
				var list:Array = Map.findUnits([target.sid]);
				var unit:Unit;
				
				for each(var candidate:* in list) {
					if (!candidate || !(candidate is Unit) || candidate.sid != target.sid || candidate.level < candidate.totalLevels || componentList.hasOwnProperty(candidate.id)) continue;
					unit = candidate;
					break;
				}
				
				if (!unit) {
					new SimpleWindow( { popup:true, title:target.info.title, text:'Нельзя больше добавщшыа' } ).show();
					return;
				}
				
				if (!Storage.componentSet(App.map.id, unit)) return;
				
				var main:Unit = Storage.componentGetMain(App.map.id, target.sid);
				if (main && main != unit) {
					unit.visible = false;
					unit.coords.x = main.coords.x;
					unit.coords.z = main.coords.z;
					unit.moveAction();
				}
				
				componentList = Storage.componentsGet(App.map.id, target.sid);
				componentContentChange();
			}else {
				target = item.unit; 
			}
		}
		
		
		override public function dispose():void
		{
			componentContentClear();
			clear();
			if (craftBoostBttn)
				craftBoostBttn.removeEventListener(MouseEvent.CLICK, onCraftBoost);
				
			App.self.setOffTimer(timer);
			super.dispose();
		}
	}
}

import flash.display.Bitmap;
import flash.events.MouseEvent;
import ui.BitmapLoader;
import ui.UserInterface;
import units.Anime;
import units.Unit;
import wins.Window;

internal class ComponentItem extends LayerX {
	
	protected var background:Bitmap;
	protected var params:Object = {};
	
	public function ComponentItem(params:Object = null) {
		
		if (params) {
			for (var s:* in params)
				this.params[s] = params[s];
		}
		
		background = Window.backing(120, 120, 50, 'itemBacking');
		addChild(background);
		
		if (id == 0) {
			var plus:Bitmap = new Bitmap(Window.texture('plus'));
			plus.x = background.width * 0.5 - plus.width * 0.5;
			plus.y = background.height * 0.5 - plus.height * 0.5;
			addChild(plus);
		}else if (info) {
			var image:BitmapLoader = new BitmapLoader(Config.getIcon(info.type, info.preview), background.width * 0.85, background.height * 0.85 );
			image.x = 10;
			image.y = 10;
			addChild(image);
		}
		
		addEventListener(MouseEvent.CLICK, onClick);
	}
	
	private var __unit:Unit;
	public function get unit():Unit {
		if (!__unit) __unit = Map.findUnit(sid, id);
		return __unit;
	}
	public function get id():int {
		return params.id;
	}
	public function get sid():int {
		return params.sid;
	}
	public function get info():Object {
		return App.data.storage[sid];
	}
	
	private function onClick(e:MouseEvent):void {
		if (params.click != null)
			params.click(id);
	}
	
	public function dispose():void {
		removeEventListener(MouseEvent.CLICK, onClick);
		if (parent) parent.removeChild(this);
	}
	
}
