package wins 
{
	import core.Numbers;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.text.TextField;
	public class CbuildingWindow extends Window 
	{
		public var target:*;
		
		public function CbuildingWindow(settings:Object=null) 
		{
			if (!settings) settings = { };
			
			target = settings.target;
			
			settings['width'] = settings['width'] || 610;
			settings['height'] = settings['height'] || 510;
			settings['title'] = target.info.title || '';
			settings['content'] = [];
			//settings.hasPaginator = false;
			
			super(settings);
			
		}
		
		override public function drawBackground():void {
			background = backing2(settings.width, settings.height, 190, 'shopBackingTop', 'shopBackingBot');
			layer.addChild(background);
		}
		
		public function createContent():void {
			if (!content) {
				content = [];
			}else {
				content.length = 0;
			}
			/*for (var id:* in target.slots) {
				var object:Object = target.slots[id];
				object['id'] = id;
				content.push(object);
			}
			
			while (content.length < target.slotsCount) {
				content.push( { sid:0 } );
			}*/
			
			
			
			for (var id:* in target.slots) {
				var object:Object = target.slots[id];
				object['targetID'] = id;
				object['info'] = App.data.storage[object.sid];
				
				// Проверка на улучшения
				if (object.info.hasOwnProperty('level') && object.info.level > 0 && object.level >= object.info.level && Numbers.countProps(object.info.devel) > object.info.level) {
					object['upgrade'] = object.level - object.info.level;
				}
				
				// Подготовка (форматирование) объекта fID
				if (!object.hasOwnProperty('fID')) object.fID = { };
				if (!object.hasOwnProperty('queue')) object.queue = [];
				
				// Формирование очереди
				object = target.queueParse(object); //object.queue = countQueue(object);
				
				content.push(object);
			}
			
			while (content.length < target.slotsCount) {
				content.push( {} );
			}
		}
		
		override public function drawBody():void {
			var bg:Bitmap = Window.backing(settings.width - 100, 135, 50, 'fadeOutWhite');
			bg.x = 50;
			bg.y = 20;
			bg.alpha = 0.2;
			bodyContainer.addChild(bg);
			
			var desc:TextField = drawText(target.info.description, {
				width: settings.width - 150,
				textAlign:'center',
				multiline:true,
				wrap:true,
				fontSize:26,
				color:0xffffff,
				borderColor:0x604300
			});
			desc.x = 75;
			desc.y = 30;
			bodyContainer.addChild(desc);
			
			//if (App.user.id == '120635122') {
				createContent();
				
				paginator.itemsCount = content.length;
				paginator.onPageCount = 3;
				paginator.update();
				
				contentChange();
			//}else {
				
				// Ожидайте в ближайших обновлениях
				/*var infoLabel:TextField = Window.drawText(Locale.__e('flash:1429185230673'), {
					width: settings.width - 140,
					textAlign:'center',
					multiline:true,
					wrap:true,
					fontSize:26,
					color:0xffffff,
					borderColor:0x604300
				});
				infoLabel.x = 70;
				infoLabel.y = desc.y + desc.height + 120;
				bodyContainer.addChild(infoLabel);*/
				
				//paginator.visible = false;
				//paginator.arrowLeft.visible = false;
				//paginator.arrowRight.visible = false;
			//}
		}
		
		private var items:Array;
		private var itemsContainer:Sprite = new Sprite();
		override public function contentChange():void {
			if (items) {
				for each(var _item:* in items) {
					itemsContainer.removeChild(_item);
					_item.dispose();
				}
			}
			items = [];
			
			bodyContainer.addChild(itemsContainer);
			var X:int = 0;
			var Xs:int = X;
			var Ys:int = 190;
			itemsContainer.x = 85;
			itemsContainer.y = Ys;
			if (content.length < 1) return;
			for (var i:int = paginator.startCount; i < paginator.finishCount; i++)
			{
				var object:Object = content[i];
				object['id'] = i + 1;
				
				var item:UnitItem = new UnitItem(object, this);
				item.x = Xs;
				items.push(item);
				itemsContainer.addChild(item);
				
				Xs += 175;
				
				if (findingIt(object.sid)) {
					item.showGlowing();
				}
			}
			
			if (content.length < 4) itemsContainer.x = (settings.width - itemsContainer.width) / 2;
		}
		
		public function attach():void {
			var list:Array = [];
			for each(var id:* in target.info.list) {
				list.push(App.data.storage[id]);
			}
			
			new ShopFilterWindow( {
				title:			settings.title,
				popup:			true,
				content:		list,
				onBuyAction:	target.buyItem
			} ).show();
			
		}
		
		override public function drawArrows():void {
			super.drawArrows();
			
			paginator.x = int((settings.width - paginator.width)/2 - 40);
			paginator.y = int(settings.height - paginator.height + 3);
		}
		
		/**
		 * Поиск в крафте объекта [sid]
		 */
		private function findingIt(sid:*):Boolean {
			var info:Object = App.data.storage[sid];
			
			if (info && info.devel && info.devel.craft) {
				for each(var craft:Object in info.devel.craft) {
					for each(var craftID:* in craft) {
						var formula:Object = App.data.crafting[craftID];
						if (formula.out == ProductionWindow.find)
							return true;
					}
				}
			}
			
			return false;
		}
		
	}

}

import buttons.Button;
import buttons.ImageButton;
import buttons.MoneyButton;
import com.adobe.images.BitString;
import com.greensock.easing.Back;
import com.greensock.TweenLite;
import core.Load;
import core.Numbers;
import core.Size;
import core.TimeConverter;
import effects.Effect;
import flash.display.Bitmap;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.text.TextField;
import ui.Cursor;
import ui.Hints;
import units.Animal;
import units.Anime;
import units.Lantern;
import units.Unit;
import wins.Window;
import wins.ProductionWindow;
import wins.StockWindow;
import wins.ProgressBar;
import wins.SimpleWindow;

internal class UnitItem extends LayerX {
	
	public static const FREE:uint = 0;
	public static const BUILDING_IDLE:uint = 1;
	public static const BUILDING_CRAFTING:uint = 2;
	public static const BUILDING_COMPLETE:uint = 3;
	public static const BUILDING_STORAGE:uint = 4;
	public static const BUILDING_START_CRAFTING:uint = 5;
	
	private var __state:uint = FREE;
	
	private var container:LayerX;
	private var controlCont:Sprite;
	
	public var background:Bitmap;
	private var addImage:Bitmap;
	private var anime:Anime;
	private var preloader:Preloader;
	private var miniPreloader:Preloader;
	private var titleLabel:TextField;
	private var addBttn:Button;
	private var craftBttn:Button;
	private var closeBttn:ImageButton;
	
	private var window:*;
	private var info:Object;
	private var sid:int = 0;
	private var target:Object;
	
	public function UnitItem(object:Object, window:*) {
		
		this.window = window || null;
		
		if (object && object.sid) {
			sid = object.sid || 0;
			info = App.data.storage[sid];
			target = object;
			target['boostEvent'] = boostEvent;
			target['storageEvent'] = storageAction;
		}
		
		draw();
		
		/*var object:Object = getBounds(this);
		graphics.beginFill(0xff0000, 0.3);
		graphics.drawRect(0, 0, object.width, object.height);
		graphics.endFill();*/
		
	}
	
	// Состояние ячейки (свободная, занятая-простой, занятая-крафтб занятая-крафт завершен)
	public function get state():uint {
		return __state;
	}
	public function set state(value:uint):void {
		//if (__state == value) return;
		
		if (__state == BUILDING_STORAGE || __state == BUILDING_START_CRAFTING)
			Effect.light(this, 0, 1);
		
		__state = value;
		
		craftBttn.visible = false;
		closeBttn.visible = false;
		addBttn.visible = false;
		hideMiniPreloader();
		
		switch(__state) {
			case FREE:
				freeView();
				break;
			case BUILDING_IDLE:
				if (anime)
					anime.stopAnimation();
				
				idleView();
				break;
			case BUILDING_CRAFTING:
				if (Cursor.accelerator && container)
					for (var i:int = 0; i < StockWindow.accelUnits.length; i++) {
						if(window.info.type == StockWindow.accelUnits[i].type) {
							container.showGlowing(); //0x17b431
						}
					}
				
				if (anime)
					anime.startAnimation();
				
				progressView();
				break;
			case BUILDING_COMPLETE:
				if (anime)
					anime.stopAnimation();
				
				storageView();
				break
			case BUILDING_STORAGE:
			case BUILDING_START_CRAFTING:
				showMiniPreloader();
				Effect.light(this, 0, 0.25);
				break;
		}
	}
	
	// ID ячейки
	public function get targetID():int {
		return (target) ? target.targetID : -1;
	}
	
	
	public function checkState():void {
		if (!info) {
			state = FREE;
		}else if (target.crafted > App.time) {
			state = BUILDING_CRAFTING;
		}else if (target.crafted >  0 && target.crafted <= App.time) {
			state = BUILDING_COMPLETE;
		}else {
			state = BUILDING_IDLE;
		}
	}
	
	private function draw():void {
		
		// Общий вид
		container = new LayerX();
		container.addEventListener(MouseEvent.CLICK, onClick);
		container.addEventListener(MouseEvent.MOUSE_OVER, onOver);
		container.addEventListener(MouseEvent.MOUSE_OUT, onOut);
		
		container.tip = function():Object {
			if (target) {
				return {
					title:		info.title,
					text:		info.description
				}
			}
			
			return {
				title:		Locale.__e('flash:1407829337190')
			}
		}
		
		
		background = Window.backing(170, 215, 20, 'itemBacking');
		container.addChild(background);
		
		controlCont = new Sprite();
		controlCont.y = background.y + background.height + 5;
		
		titleLabel = Window.drawText(title, {
			width:		background.width,
			fontSize:	22,
			color:		0x58330d,
			borderColor:0xfaedca,
			textAlign:	'center',
			wrap:		true,
			multiline:	true
		});
		titleLabel.y = background.x - titleLabel.height - 5;
		
		
		closeBttn = new ImageButton(Window.textures.closeBttn, {
			scaleX: 0.8,
			scaleY:	0.8,
			tips:	{ title:Locale.__e('flash:1444634526228') }
		});
		closeBttn.addEventListener(MouseEvent.CLICK, onClose);
		closeBttn.scaleX = closeBttn.scaleY = 0.5;
		closeBttn.x = background.x + background.width - closeBttn.width - 9;
		closeBttn.y = background.y + 9;
		
		addBttn = new Button( {
			width:		background.width - 20,
			height:		46,
			caption:	Locale.__e('flash:1463135500963'),
			radius:		22,
			onClick:	onClick
		});
		addBttn.x = background.x + background.width * 0.5 - addBttn.width * 0.5;
		controlCont.addChild(addBttn);
		
		craftBttn = new Button( {
			width:		background.width - 20,
			height:		46,
			radius:		22,
			caption:	Locale.__e('flash:1444215754914'),
			onClick:	onClick
		});
		craftBttn.x = background.x + background.width * 0.5 - craftBttn.width * 0.5;
		controlCont.addChild(craftBttn);
		
		
		addImage = new Bitmap(Window.textures.plus);
		addImage.x = background.x + background.width * 0.5 - addImage.width * 0.5;
		addImage.y = background.y + background.height * 0.5 - addImage.height * 0.5;
		container.addChild(addImage);
		
		
		
		addChild(container);
		addChild(controlCont);
		addChild(titleLabel);
		addChild(closeBttn);
		
		load();
		
		showMiniPreloader();
		checkState();
	}
	private function load():void {
		
		if (!info) return;
		
		//image = new Bitmap();
		//container.addChild(image);
		
		preloader = new Preloader();
		preloader.x = background.x + background.width * 0.5;
		preloader.y = background.y + background.height * 0.5;
		container.addChild(preloader);
		
		Load.loading(Config.getSwf(info.type, info.view), onAnimeLoad);
	}
	private function onAnimeLoad(swf:*):void {
		if (!craftBttn) return;
		
		if (container && preloader && container.contains(preloader))
			container.removeChild(preloader);
		
		anime = new Anime(swf, {
			stage:		target.level
		});
		
		Size.size(anime, background.width * 0.9, background.height * 0.9);
		anime.x = background.width * 0.5 - anime.width * 0.5;
		anime.y = background.height * 0.5 - anime.height * 0.5;
		
		container.addChild(anime);
		
		checkState();
	}
	private function clear():void {
		
		if (progressBar) {
			progressBar.dispose();
			progressBar = null;
			boostBttn.dispose();
			boostBttn = null;
			progressCont.removeChildren();
			controlCont.removeChild(progressCont);
		}
		
		if (storageBttn) {
			
			controlCont.removeChild(storageBttn);
			storageBttn.dispose();
			storageBttn = null;
		}
		
		App.self.setOffTimer(progress);
	}
	
	private function showMiniPreloader():void {
		miniPreloader = new Preloader();
		miniPreloader.scaleX = miniPreloader.scaleY = 0.75;
		miniPreloader.x = background.x + background.width * 0.5;
		miniPreloader.y = background.y + background.height + 30;
		addChild(miniPreloader);
	}
	private function hideMiniPreloader():void {
		if (miniPreloader && contains(miniPreloader)) {
			removeChild(miniPreloader);
			miniPreloader = null;
		}
	}
	
	// Materials
	private var materialCont:Sprite;
	public function createMaterials():void {
		if (state == BUILDING_IDLE || state == FREE) return;
		
		if (!materialCont) {
			materialCont = new Sprite();
			addChild(materialCont);
		}else {
			materialCont.visible = true;
			clearMaterials();
		}
		
		for (var i:int = 0; i < target.queue.length; i++) {
			var formula:Object = window.target.getFormula(target.queue[i].fID);
			if (!formula) continue;
			
			var item:MaterialItem = new MaterialItem(formula.out, decorateReplace);
			item.x = 70 * (target.queue.length - i - 1);
			item.y = -10;
			materialCont.addChild(item);
			
			if (target.queue[i].crafted <= App.time)
				item.startRotate();
		}
		
		materialCont.x = background.width * 0.5 - materialCont.width * 0.5;
		materialCont.y = background.y + background.height - 80;
	}
	private function hideMaterials():void {
		if (materialCont) {
			materialCont.visible = false;
			clearMaterials();
		}
	}
	private function clearMaterials():void {
		while (materialCont && materialCont.numChildren) {
			var materialItem:MaterialItem = materialCont.removeChildAt(0) as MaterialItem;
			materialItem.dispose();
		}
	}
	
	// IDLE View
	public function idleView():void {
		clear();
		
		craftBttn.visible = true;
		closeBttn.visible = true;
		
		hideMaterials();
		decorateReplace();
	}
	
	// Free view
	public function freeView():void {
		clear();
		
		addImage.visible = true;
		addBttn.visible = true;
		
		hideMaterials();
		decorateReplace();
	}
	
	// Progress view
	private var formula:Object = null;
	private var fID:int = 0;
	private var progressCont:Sprite;
	private var progressBarBack:Shape;
	private var progressBar:ProgressBar;
	private var boostBttn:MoneyButton;
	public function progressView():void {
		clear();
		
		fID = target.fID[0];
		formula = window.target.getFormula(fID);
		
		progressCont = new Sprite();
		controlCont.addChild(progressCont);
		
		progressBarBack = new Shape();
		progressBarBack.graphics.beginFill(0x888888, 0.75);
		progressBarBack.graphics.drawRoundRect(0, 0, 128, 20, 20, 20);
		progressBarBack.graphics.endFill();
		progressCont.addChild(progressBarBack);
		
		progressBar = new ProgressBar( {
			win:		window,
			width:		background.width * 1.05
		});
		progressBar.scaleX = progressBar.scaleY = 0.8;
		progressCont.addChild(progressBar);
		progressBar.start();
		progress();
		
		boostBttn = new MoneyButton( {
			width:			124,
			height:			46,
			countText:		Numbers.speedUpPrice(target.crafted - App.time),//(info.devel.hasOwnProperty('skip')) ? info.devel.skip[level + 1] : null, //target.info.skip,
			fontSize:		22,
			fontCountSize:	32,
			radius:			22,
			caption:		Locale.__e('flash:1382952380104'),
			onClick:		boostEvent
		});
		progressCont.addChild(boostBttn);
		
		progressBarBack.x = 22;
		progressBarBack.y = 6;
		progressBar.x = 14;
		//progressBar.y = -progressBar.height - 3;
		boostBttn.x = background.x + background.width * 0.5 - boostBttn.width * 0.5 + 2;
		boostBttn.y = progressBar.y + progressBar.height + 4;
		
		App.self.setOnTimer(progress);
		decorateReplace();
		
		//createMaterials();
	}
	private function progress():void {
		if (progressBar) {
			//progressBar.progress = 1;
			var leftTime:int = target.crafted - App.time;
			if (leftTime < 0) {
				leftTime = 0;
				App.self.setOffTimer(progress);
				checkState();
			}else {
				progressBar.progress = 1 - (leftTime / formula.time);
				progressBar.time = leftTime;
			}
		}
		
		if (state == BUILDING_COMPLETE) {
			
			// меняем значение времени для иконок материалов
			for (var i:int = 1; i < materialCont.numChildren; i++) {
				var item:MaterialItem = materialCont.getChildAt(i) as MaterialItem;
				item.showTime(target.queue[i].crafted - App.time);
			}
			
			if (target.queue.length == 0) {
				App.self.setOffTimer(progress);
			}else if (target.queue[materialCont.numChildren - 1].crafted - App.time == 0) {
				createMaterials();
				
				// отключаем таймер если время равно 0 на последнем крафте
				if (i >= target.queue.length - 1)
					App.self.setOffTimer(progress);
			}
		}
	}
	
	// Storage view
	private var storageBttn:Button;
	public function storageView():void {
		clear();
		
		storageBttn = new Button( {
			width:		124,
			height:		42,
			fontSize:	22,
			caption:	Locale.__e('flash:1382952380146'),
			radius:		22,
			onClick:	storageAction
		});
		storageBttn.x = background.x + background.width * 0.5 - storageBttn.width * 0.5 + 2;
		controlCont.addChild(storageBttn);
		
		createMaterials();
		
		App.self.setOnTimer(progress);
	}
	
	// Production
	public function productionView(e:MouseEvent = null):void {
		new ProductionWindow( {
			popup:			true,
			title:			info.title,
			crafting:		info.crafting,
			target:			target,
			onCraftAction:	craftAction,
			height:			650,
			hasPaginator:	true,
			hasButtons:		true
		}).show();
	}
	
	private function get title():String {
		if (info)
			return info.title;
		
		return Locale.__e('flash:1407829337190');
	}
	
	private function decorateReplace():void {
		var targetY:int = background.y + background.height - 55;
		
		if (state == BUILDING_STORAGE || state == BUILDING_COMPLETE) {
			targetY = background.y + background.height - 25;
		}else if (state == BUILDING_CRAFTING || state == BUILDING_START_CRAFTING) {
			targetY = background.y + background.height - 60;
		}
		
		if (controlCont.y != targetY)
			TweenLite.to(controlCont, 0.3, { y:targetY, ease:Back.easeOut } );
	}
	
	private function onClick(e:MouseEvent = null):void {
		if (state == BUILDING_STORAGE || state == BUILDING_START_CRAFTING) return;
		
		/*if (state == BUILDING_CRAFTING && Cursor.accelerator && StockWindow.accelMaterial) {
			for (var i:int = 0; i < StockWindow.accelUnits.length; i++) {
				if(window.info.type == StockWindow.accelUnits[i].type) {
					accelerateEvent(StockWindow.accelMaterial);
					return;
				}
			}
		}*/
		
		window.target.activeUnitID = targetID;
		
		if (state == FREE) {
			Window.closeAll();
			window.attach();
		}else if (state == BUILDING_IDLE || state == BUILDING_CRAFTING){
			productionView();
		}
	}
	private function onOver(e:MouseEvent):void {
		Effect.light(container, 0.1);
	}
	private function onOut(e:MouseEvent):void {
		Effect.light(container);
	}
	
	/**
	 * Выставление объекта на карту
	 * @param	e
	 */
	private function onClose(e:MouseEvent):void {
		/*var object:Object = App.data.storage[sid];
		
		if (!object || closeBttn.mode == Button.DISABLED) return;
		
		var unit:Unit = Unit.add( {
			sid:				sid,
			level:				target.level,
			fromStock:			true,
			parentStock:		true,
			parentStockAction:	window.target.childStockAction
		} );
		unit.move = true;
		App.map.moved = unit;
		
		window.target.targetForRemove = target.targetID;
		window.close();*/
		
		new SimpleWindow( {
			title:		window.target.info.title,
			text:		Locale.__e('flash:1477298764247'),
			popup:		true,
			dialog:		true,
			confirm:	function():void {
				window.target.dettachAction(targetID);
			}
		}).show();
	}
	
	// Начало производства
	public function craftAction(fID:*):void {
		formula = window.target.getFormula(fID);
		target.formula = formula;
		
		if (!target.formula) return;
		
		if (!target.fID) target.fID = { };
		target.fID[Numbers.countProps(target.fID)] = formula.ID;
		
		if (target.crafted == 0) {
			target.crafted = App.time + target.formula.time;
		}
		
		for (var sID:* in target.formula.items){
			App.user.stock.take(sID, target.formula.items[sID]);
		}
		
		/*var animals:Object = { };
		if (Animal.animals.length) {
			for each(var animal:Animal in Animal.animals) {
				if(target.formula.items[animal.sid] != undefined && animal.level != Animal.USED) {
					animals[animal.sid] = animal.id;
				}
			}
		}*/
		
		target.queue.push( {
			order:		target.queue.length,
			fID:		fID,
			crafted:	(target.queue.length == 0) ? target.crafted : (target.queue[target.queue.length - 1].crafted + target.formula.time)
		});
		
		state = BUILDING_START_CRAFTING;
		window.target.craftingAction(targetID, fID, onCraftAction);
	}
	private function onCraftAction(data:Object):void {
		if (data) {
			target.crafted = data.crafted;
		}else {
			window.target.queueRemoveLast(target);
		}
		
		checkState();
	}
	
	
	// Сбор storageEvent
	public function storageAction(e:MouseEvent = null):void {
		if (!App.user.stock.check(Stock.FANTASY, 1)) return;
		
		var point:Point = BonusItem.localToGlobal(storageBttn);
		Hints.minus(Stock.FANTASY, 1, point, false, window);
		
		state = BUILDING_STORAGE;
		window.target.storageAction(targetID, onStorageAction);
	}
	private function onStorageAction(data:Object):void {
		var bonus:Object = window.target.queueStorage(target, data);
		bonus = Treasures.treasureToObject(bonus);
		
		BonusItem.takeRewards(bonus, this);
		App.user.stock.addAll(bonus);
		App.ui.upPanel.update();
		
		checkState();
		
		// Для фонарей
		for (var sID:* in bonus) {
			if	(App.data.storage[sID].type == 'Lamp') {
				for (var i:int = 0; i < bonus[sID]; i++) {
					var item:Lantern = new Lantern( { sid:sID, 
						position: {
							x:window.target.x,
							y:window.target.y
						}
					});
				}
				window.close();
			}
		}
	}
	
	// Ускорение
	private var boostPrice:int;
	public function boostEvent(e:MouseEvent = null):void {
		if (!App.user.stock.check(Stock.FANT, target.info.skip)) return;
		
		boostPrice = Numbers.speedUpPrice(target.crafted - App.time);
		
		if (state == BUILDING_CRAFTING) {
			window.target.boostAction(targetID, onBoostAction);
		}
	}
	private function onBoostAction(data:Object):void {
		if (data) {
			if (data.hasOwnProperty('crafted')) {
				
				var point:Point = BonusItem.localToGlobal((boostBttn) ? boostBttn : storageBttn);
				Hints.minus(Stock.FANT, boostPrice, point, false, window);
				App.user.stock.take(Stock.FANT, boostPrice);
				App.ui.upPanel.update();
				
				target.crafted = data.crafted;
				target = window.target.queueParse(target);
			}
		}
		
		checkState();
	}
	
	// Ускорение через сокращение времени крафта
	public function accelerateEvent(mID:int):void {
		if (!App.data.storage[mID] || App.data.storage[mID].type != 'Accelerator' || !App.user.stock.check(mID, 1)) return;
		
		if (state == BUILDING_CRAFTING) {
			window.target.boostAction(targetID, onAccelerateAction, mID);
		}
	}
	private function onAccelerateAction(data:Object):void {
		if (data) {
			if (data.hasOwnProperty('crafted')) {
				
				var point:Point = BonusItem.localToGlobal((boostBttn) ? boostBttn : storageBttn);
				
				Hints.text("-" + TimeConverter.timeToCuts(target.crafted - data.crafted), 8, point, false, window);
				Hints.minus(StockWindow.accelMaterial, 1, point, true, window);
				
				App.user.stock.take(StockWindow.accelMaterial, 1);
				App.ui.upPanel.update();
				
				target.crafted = data.crafted;
				target = window.target.queueParse(target);
			}
		}
		
		checkState();
	}
	
	
	public function dispose():void {
		if (parent) parent.removeChild(this);
		
		hideMaterials();
		clear();
		
		addBttn.dispose();
		addBttn = null;
		
		craftBttn.dispose();
		craftBttn = null;
		
		closeBttn.removeEventListener(MouseEvent.CLICK, onClose);
		container.removeEventListener(MouseEvent.CLICK, onClick);
		container.removeEventListener(MouseEvent.MOUSE_OVER, onOver);
		container.removeEventListener(MouseEvent.MOUSE_OUT, onOut);
	}
	
}

internal class MaterialItem extends LayerX {
	
	private var backCont:Sprite;
	private var back:Bitmap;
	private var image:Bitmap;
	private var timeLabel:TextField;
	private var preloader:Preloader;
	
	public function MaterialItem(sid:int, onLoad:Function = null) {
		
		var info:Object = Storage.info(sid);
		
		backCont = new Sprite();
		addChild(backCont);
		
		back = new Bitmap(Window.textures.glow);
		back.alpha = 0.9;
		back.scaleX = back.scaleY = 0.2;
		back.x = -back.width * 0.5;
		back.y = -back.height * 0.5;
		backCont.x = -back.x;
		backCont.y = -back.y;
		backCont.addChild(back);
		
		image = new Bitmap();
		addChild(image);
		
		preloader = new Preloader();
		preloader.x = back.width * 0.5;
		preloader.y = back.height * 0.5;
		addChild(preloader);
		
		timeLabel = Window.drawText('0:00:00', {
			width:			back.width,
			fontSize:		18,
			color:			0xffe400,
			borderColor:	0x5d2e00,
			textAlign:		'center'
		});
		timeLabel.x = 0;
		timeLabel.y = back.height - timeLabel.height;
		addChild(timeLabel);
		timeLabel.visible = false;
		
		Load.loading(Config.getIcon(info.type, info.preview), function(data:Bitmap):void {
			if (!contains(preloader)) return;
			
			removeChild(preloader);
			
			image.bitmapData = data.bitmapData;
			image.smoothing = true;
			Size.size(image, back.width * 0.8, back.height * 0.8);
			image.x = backCont.x - image.width * 0.5;
			image.y = backCont.y - image.height * 0.5;
			
			if (onLoad != null) onLoad();
		});
		
		tip = function():Object {
			return {
				title:		info.title,
				text:		info.description
			}
		}
	}
	
	private var rotating:Boolean = false;
	public function startRotate():void {
		if (rotating) return;
		rotating = false;
		
		App.self.setOnEnterFrame(rotate);
	}
	private function rotate(e:Event):void {
		backCont.rotation += 0.5;
	}
	private function stopRotate():void {
		App.self.setOffEnterFrame(rotate);
		rotating = false;
	}
	
	public function showTime(time:int):void {
		if (time <= 0) {
			hideTime();
			return;
		}
		
		if (timeLabel.visible == false)
			timeLabel.visible = true;
		
		if (rotating)
			stopRotate();
		
		timeLabel.text = TimeConverter.timeToStr(time);
	}
	public function hideTime():void {
		timeLabel.visible = false;
	}
	
	public function dispose():void {
		removeChildren();
		
		stopRotate();
		
		if (parent) parent.removeChild(this);
	}
	
}