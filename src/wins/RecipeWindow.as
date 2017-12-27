package wins 
{
	import buttons.Button;
	import buttons.ImageButton;
	import buttons.MoneyButton;
	import core.Load;
	import core.Numbers;
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import ui.Hints;
	import ui.UserInterface;
	import units.Techno;
	import units.Ttechno;
	import units.Unit;
	import wins.elements.OutItem;
	
	public class RecipeWindow extends Window
	{
		public var item:Object;
		
		public var bitmap:Bitmap;
		public var title:TextField;
		
		private var buyBttn:MoneyButton;
		
		private var fID:int;
		private var sID:uint;
		private var formula:Object;
		public var container:Sprite = new Sprite();
		
		public var outItem:OutItem;
		
		private var arrowLeft:ImageButton;
		private var arrowRight:ImageButton;
		
		private var prev:int = 0;
		private var next:int = 0;
		
		private var _backLine:Bitmap;
		private var _background:Bitmap;
		private var _equality:Bitmap;
		
		public var items:Vector.<MaterialItem> = new Vector.<MaterialItem>;
		public var requires:Object = {};
		public var materials:Object = {};
		public var crafts:Array = [];
		
		public function RecipeWindow(settings:Object = null):void
		{
			if (settings == null) {
				settings = new Object();
			}
			
			settings['sID'] = settings.sID || 0;
			settings["width"] = 670;
			settings["height"] = 360;
			settings["popup"] = true;
			settings["fontSize"] = 38;
			settings["shadowSize"] = 4;
			settings["callback"] = settings["callback"] || null;
			settings["dontCheckTechno"] = settings["dontCheckTechno"] || false;
			settings["hasPaginator"] = false;
			settings["titleDecorate"] = false;
			
			crafts = settings['craftData'];
			
			if (App.user.worldID == Travel.SAN_MANSANO) settings['background'] = 'goldBacking';
			
			initFormula(settings.fID);
			
			super(settings);
		}
		
		private const MATERIAL_MARGIN:int = 165;
		private const LEFT_MARGIN:int = 70;
		private var items_margin:int = 0;
		
		private var headContainer:Sprite;
		override public function drawBody():void {
			clear();
			clearBody();
			
			// Divider
			var devider:Bitmap = new Bitmap(Window.textures.dividerLine);
			devider.x = LEFT_MARGIN;
			bodyContainer.addChild(devider);
			
			drawHeaders();
			//headContainer.x = (settings.width - headContainer.width) / 2;
			headContainer.y = 30;
			headContainer.x = LEFT_MARGIN;
			
			devider.y = headContainer.y + headContainer.height;
			if (headContainer.width > Numbers.countProps(materials) * MATERIAL_MARGIN) {
				devider.width = headContainer.width;
				//items_margin = (headContainer.width - (Numbers.countProps(materials) * MATERIAL_MARGIN)) / 2;
				settings.width = LEFT_MARGIN + headContainer.width + 170 + LEFT_MARGIN;
			}else {
				headContainer.x = LEFT_MARGIN + ((Numbers.countProps(materials) * MATERIAL_MARGIN) - headContainer.width) / 2;
				devider.width = Numbers.countProps(materials) * MATERIAL_MARGIN;
				settings.width = LEFT_MARGIN + (Numbers.countProps(materials) * MATERIAL_MARGIN) + 170 + LEFT_MARGIN;
			}
			
			if (Numbers.countProps(materials) == 1) {
				devider.width += 100;
			}
			
			contentChange();
			drawBackground();
			redrawTitle();
			
			exit.x = settings.width - exit.width / 2 - 38;
			exit.y = -exit.height / 2 + 28;
			
			if (Numbers.countProps(materials) == 1) exit.x += 7;
			if (Numbers.countProps(materials) == 4) exit.x -= 13;
			
			layer.x = (App.self.stage.stageWidth - settings.width) / 2;
		}
		
		private function redrawTitle():void {
			if (!arrowLeft && !arrowRight) {
				arrowLeft = new ImageButton(Window.textures.arrow, {scaleX:-0.7,scaleY:0.7});
				arrowRight = new ImageButton(Window.textures.arrow, {scaleX:0.7,scaleY:0.7});
				arrowLeft.addEventListener(MouseEvent.MOUSE_DOWN, onPrev);
				arrowRight.addEventListener(MouseEvent.MOUSE_DOWN, onNext);
			}
			
			if (Numbers.countProps(materials) <= 1) {
				arrowLeft.x = settings.width / 2 - 200;
				arrowRight.x = settings.width / 2 + 170;
			}else{
				arrowLeft.x = settings.width / 2 - 200;
				arrowRight.x = settings.width / 2 + 170;
			}
			
			
			arrowLeft.y = -36;
			arrowRight.y = -36;
			
			var textField:* = null;
			for (var i:int = 0; i < titleLabel.numChildren; i++) {
				textField = titleLabel.getChildAt(i);
				if (textField is TextField) break;
			}
			
			if (textField) {
				textField.text = settings.title + ' ' + App.data.storage[sID].title;
				titleLabel.x = (settings.width - titleLabel.width) * .5;
				titleLabel.y = -2;
			}
			
			arrowLeft.visible = false;
			arrowRight.visible = false;
			var index:int = getFormulaIndex(fID);
			if (index > 0) arrowLeft.visible = true;
			if (index < crafts.length - 1) arrowRight.visible = true;
			
			bodyContainer.addChild(arrowLeft);
			bodyContainer.addChild(arrowRight);
		}
		
		override public function contentChange():void {
			
			var array:Array = [];
			for (var s:* in materials) array.push( {
				sid:	int(s),
				need:	materials[s],
				order:	App.data.storage[s].order
			});
			array.sortOn('order', Array.NUMERIC);
			
			for (var i:int = 0; i < array.length; i++) {
				// Сперва добавим знак
				var mark:Bitmap;
				if (array.length - 1 == i) {
					mark = new Bitmap(Window.textures.equals);
				}else {
					mark = new Bitmap(Window.textures.plus);
				}
				if (Numbers.countProps(materials) == 1) {
					mark.x = LEFT_MARGIN + items_margin + 132 + i * MATERIAL_MARGIN + 100;
				} else {
					mark.x = LEFT_MARGIN + items_margin + 132 + i * MATERIAL_MARGIN;
				}
				mark.y = 140;
				bodyContainer.addChild(mark);
				
				
				var item:MaterialItem = new MaterialItem( {
					sID:array[i].sid,
					need:array[i].need,
					window:this, 
					type:MaterialItem.IN
				});
				if (Numbers.countProps(materials) == 1) {
					item.x = LEFT_MARGIN + items_margin + i * MATERIAL_MARGIN + 50;
				} else {
					item.x = LEFT_MARGIN + items_margin + i * MATERIAL_MARGIN;
				}
				item.y = 90;
				item.addEventListener(WindowEvent.ON_CONTENT_UPDATE, onUpdateOutMaterial);
				
				items.push(item);
				bodyContainer.addChild(item);
			}
			
			// Выходной материал
			outItem = new OutItem(onCook, {formula:formula, recipeBttnName:"dd", target:settings.win.settings.target, find:settings.find});
			bodyContainer.addChild(outItem);
			if (Numbers.countProps(materials) == 1) {
				outItem.x = LEFT_MARGIN + requireWidth + 30 - 50;
			} else {
				outItem.x = LEFT_MARGIN + requireWidth + 30;
			}
			outItem.y = 30;
			
			//for (var i:int = 0; i < array.length; i++) {
				//if (App.user.stock.count(array[i].sid) < array[i].need)
				//{
					//outItem.recipeBttn.state = Button.DISABLED;
				//}
			//}
			
			settings.width = outItem.x + MATERIAL_MARGIN + 40;
/*			if (Numbers.countProps(materials) == 1) {
				settings.width = outItem.x + MATERIAL_MARGIN + 40 + 20;
			}*/
			onUpdateOutMaterial();
		}
		
		public function change():void
		{
			outItem.flyMaterial();
			clear();
			bodyContainer.removeChild(outItem);
			contentChange();
		}
		
		public function onUpdateOutMaterial(e:WindowEvent = null):void {
			var outState:int = MaterialItem.READY;
			for each(var item:* in items) {
				if(item.status != MaterialItem.READY){
					outState = item.status;
				}
			}
			
			if (requiresList && !requiresList.checkOnComplete())
				outState = MaterialItem.UNREADY;
			
			if (outState == MaterialItem.UNREADY) 
				outItem.recipeBttn.state = Button.DISABLED;
			else if (outState != MaterialItem.UNREADY)
				outItem.recipeBttn.state = Button.NORMAL;
			
			var openedSlots:int;
			openedSlots = settings.win.settings.target.openedSlots;
			if (settings.win.settings.target.queue.length >= openedSlots+1)
				outItem.recipeBttn.state = Button.DISABLED;
			
			if (settings.busy)
				outItem.recipeBttn.state = Button.DISABLED;
			
			//for (var sid:* in formula.items) {
				//if (sid == Stock.COOKIE && App.user.stock.count(sid) < formula.items[sid])
					//outItem.recipeBttn.state = Button.DISABLED;
			//}
			//if (settings.busy && settings.fID != settings.win.settings.target.fID)
				//outItem.recipeBttn.state = Button.DISABLED;
				
			//if (formula.out == Stock.JAM && App.user.stock.count(Stock.JAM) >= App.data.levels[App.user.level].jam)
				//outItem.recipeBttn.state = Button.DISABLED;
				
			//if (formula.out == Stock.JAM){
				//if (App.user.stock.count(Stock.JAM) >= App.data.levels[App.user.level].jam)
					//outItem.jamTick.visible = true;
				//else
					//outItem.jamTick.visible = false;
			//}	
			
		}
		
		public function get requireWidth():Number {
			var count:int = Numbers.countProps(materials);
			if (count == 1) count++;
			if (count * MATERIAL_MARGIN < headContainer.width)
				return headContainer.width;
			
			return count * MATERIAL_MARGIN;
		}
		
		private function onPrev(e:MouseEvent):void {
			var index:int = getFormulaIndex(fID);
			if (index > 0) {
				initFormula(crafts[index - 1].ID);
				drawBody();
			}
		}
		private function onNext(e:MouseEvent):void {
			var index:int = getFormulaIndex(fID);
			if (index < crafts.length - 1) {
				initFormula(crafts[index + 1].ID);
				drawBody();
			}
		}
		private function getFormulaIndex(fID:int):int {
			var index:int = -1;
			for (var i:int = 0; i < crafts.length; i++) {
				if (crafts[i].ID == fID)
					index = i;
			}
			return index;
		}
		
		public var requiresList:RequiresList;
		private function drawRequirements(requirements:Object):void 
		{
			requiresList = new RequiresList(requirements, false, {dontCheckTechno:settings.dontCheckTechno});
			bodyContainer.addChild(requiresList);
			requiresList.x = _backLine.x + (_backLine.width- requiresList.width)/2;
			requiresList.y = 30;
		}
		
		//public function onUpdateOutMaterial(e:WindowEvent = null):void {}
		
		public function onCook(e:MouseEvent):void {
			
			if (e.currentTarget.mode == Button.DISABLED) return;
			
			if (settings.win.busy) return;
			
			for (var sid:* in formula.items) {
				if (sid == Stock.COOKIE && App.user.stock.count(sid) < formula.items[sid]) {
					buyCookie();
					return;
				}
			}
			
			// Проверить или доступен рабочий для крафта если он нужен
			var target:* = settings.target;
			if (!target && settings.win)
				target = settings.win.settings.target;
			
			var technosForWork:* = Techno.findTechnosForCraft(fID, App.time, target);
			var notText:String = Locale.__e('flash:1427716990553');
			if (App.user.worldID == Travel.SAN_MANSANO) notText = Locale.__e('flash:1470212158544');
			if (technosForWork is String) {
				if (technosForWork == 'not_much') {
					new SimpleWindow( {
						title:		target.info.title,
						text:		notText,
						popup:		true,
						confirm:	function():void {
							App.ui.upPanel.onWorkersEvent()
						}
					}).show();
				}else if (technosForWork == 'busy') {
					new SimpleWindow( {
						title:		target.info.title,
						text:		Locale.__e('flash:1427716915911'),
						popup:		true,
						confirm:    onBuyTechno
					}).show();
				}else if (technosForWork == 'busy_time') {
					Window.closeAll();
					var items:Array = Map.findUnits([160, 461, 278, 752]);
					if (items.length > 0) {
						new TechnoManagerWindow( {
							
						}).show();
					}else {
						new SimpleWindow( {
							title:		target.info.title,
							text:		notText,
							popup:		true,
							confirm:	function():void {
								App.ui.upPanel.onWorkersEvent()
							}
						}).show();
					}
					/*new SimpleWindow( {
						title:		target.info.title,
						text:		Locale.__e('flash:1434545092187'),
						popup:		true,
						confirm:    onHutOpen
					}).show();*/
				}else if (technosForWork == 'not_enough_time') {
					new SimpleWindow( {
						title:		target.info.title,
						text:		Locale.__e('flash:1438847074566'),
						popup:		true,
						confirm:    onHutUpdateOpen
					}).show();
				}
				
				//Hints.text('Нет достаточно рабочих (Не локаль)', Hints.TEXT_RED, new Point(mouseX, mouseY), false, App.self.tipsContainer);
				return;
			}else {
				Techno.setBusy(technosForWork, target, App.time + formula.time);
			}
			
			e.currentTarget.state = Button.DISABLED;
			settings.onCook(fID);
			
			if (formula.time)
			{
				close();
			} else
			{
				change();
			}
		}
		
		private function onBuyTechno():void {
			var technoName:String = 'workers';
			if (App.user.worldID == Travel.SAN_MANSANO) technoName = 'worker_staratel';
			var content:Array = PurchaseWindow.createContent('Energy', { view:technoName } );
			new PurchaseWindow( {
				width:595,
				itemsOnPage:App.user.worldID == Travel.SAN_MANSANO ? content.length : 3,
				content:content,
				title:App.user.worldID == Travel.SAN_MANSANO ? Locale.__e('flash:1470210237983') : Locale.__e("flash:1382952379828"),
				fontBorderColor:0xd49848,
				shadowColor:0x553c2f,
				shadowSize:4,
				hasDescription:App.user.worldID == Travel.SAN_MANSANO ? false : true,
				description:Locale.__e("flash:1427363516041"),
				popup: true,
				callback:function(sID:int):void {
					var object:* = App.data.storage[sID];
					App.user.stock.add(sID, object);
				}
			}).show();
		}
		
		private function buyCookie():void {
			var content:Array = PurchaseWindow.createContent('Energy', { view:'w_coupon_payment0' } );
			new PurchaseWindow( {
				width:595,
				itemsOnPage:content.length,
				content:content,
				title:App.data.storage[Stock.COOKIE].title,
				fontBorderColor:0xd49848,
				shadowColor:0x553c2f,
				shadowSize:4,
				hasDescription:false,
				description:Locale.__e("flash:1427363516041"),
				popup: true,
				callback:function(sID:int):void {
					var object:* = App.data.storage[sID];
					App.user.stock.add(sID, object);
				}
			}).show();
		}
		
		private function onHutOpen():void
		{
			//if (!App.isSocial('FB')) {
				Window.closeAll();
				new TechnoManagerWindow( {
					
				}).show();
			/*} else {
				var items:Array = Map.findUnits([160]);
				var target:*;
				for each (var unit:* in items)
				{
					for each (var s:* in unit.workers)
					{
						if (s.finished > App.time) {
							break;
						}
						target = unit;
						break;
					}
				}
				if (target)
				{
					new HutHireWindow( {
						target:		target,
						sID:		Techno.TECHNO,
						popup:      true
					}).show();
					close();
				}
			}*/
		}
		
		private function onHutUpdateOpen():void
		{
			var items:Array = Map.findUnits([160]);
			var craft:Object = App.data.crafting[fID];
			var target:*;
			var full:Boolean = false;
			var hungry:Boolean = false;
			for each (var unit:* in items)
			{
				for each (var s:* in unit.workers)
				{
					if (s.finished > 0 && s.finished < App.time + craft.time) {
						target = unit;
						if (s.finished > App.time) {
							full = true;
						} else {
							hungry = true;
						}
						break;
					}
				}
			}
			if (target)
			{
				if (full) {
					new HutWindow( {
						target:		target,
						sID:		Techno.TECHNO,
						popup:      true,
						glowUpgrade:  true
					}).show();
					close();
					return;
				}
				
				new HutHireWindow( {
						target:		target,
						sID:		Techno.TECHNO,
						popup:      true,
						glowUpgrade:  true
					}).show();
					close();
			}
		}
		
		override public function dispose():void {
			clear();
			clearBody();
			
			super.dispose();
		}
		
		private function clear():void {
			while (items.length) {
				var item:MaterialItem = items.shift();
				item.dispose();
				if (item.parent) item.parent.removeChild(item);
			}
		}
		
		private function clearBody():void {
			while (bodyContainer.numChildren) {
				var child:DisplayObject = bodyContainer.getChildAt(0);
				bodyContainer.removeChild(child);
			}
		}
		
		private function initFormula(fID:*):void {
			if (!App.data.crafting[fID]) fID = settings.fID;
			this.fID = int(fID);
			
			formula = App.data.crafting[fID];
			sID = formula.out;
			materials = { };
			requires = { };
			
			for (var sid:* in formula.items) {
				switch(sid) {
					case Stock.COINS:
					case Stock.ENERGY:
					case Stock.FANT:
					case Stock.GUESTFANTASY:
					case Techno.TECHNO:
					case Ttechno.TECHNO:
					case Stock.COOKIE:
							requires[sid] = formula.items[sid];
						break;
					default:
							materials[sid] = formula.items[sid];
						break;	
				}
			}
		}
		
		private function drawHeaders():void {
			if (headContainer) headContainer = null;
			headContainer = new Sprite();
			bodyContainer.addChild(headContainer);
			
			var textLabel:TextField = drawText(Locale.__e('flash:1423742002798') + ':', {
				fontSize:		25,
				autoSize:		'left',
				color:			0x5d2e04,
				borderColor:	0xf5ead8
			});
			headContainer.addChild(textLabel);
			textLabel.x = w;
			if (Numbers.countProps(materials) == 1) textLabel.x += 50;
			
			var w:int = 0;
			for (var s:* in requires) {
				var icon:Bitmap = new Bitmap();
				switch(int(s)) {
					case Stock.TECHNO:
						icon.bitmapData = UserInterface.textures.iconWorker;
						icon.scaleX = icon.scaleY = 0.7;
						break;
					case Stock.COINS:
						icon.bitmapData = UserInterface.textures.coinsIcon;
						break;
					case Stock.FANT:
						icon.bitmapData = UserInterface.textures.fantsIcon;
						break;
					case Stock.COOKIE:
						icon.bitmapData = UserInterface.textures.couponIco;
						break;
					case Ttechno.TECHNO:
						icon.bitmapData = UserInterface.textures.workerIco;
						break;
				}
				icon.smoothing = true;
				icon.x = textLabel.x + textLabel.textWidth + 10 + w;
				icon.y = (25 - icon.height) / 2;
				headContainer.addChild(icon);
				
				var textColor:int = 0xef7563;
				var borderColor:int = 0x623126;
				switch(int(s)) {
					case Stock.TECHNO:
					case Ttechno.TECHNO:
						if (Techno.freeTechno().length >= requires[s]) { 
							textColor = 0xfffefb;
							borderColor = 0xfffefb;
						}
						break;
					default:
						if (App.user.stock.check(int(s), requires[s], true)) { 
							textColor = 0xfffefb;
							borderColor = 0xfffefb;
						}
				}
				
				var text:TextField = drawText(String(requires[s]), {
					fontSize:		29,
					autoSize:		'left',
					color:			textColor,
					borderColor:	0x69311a,
					shadowSize:		2
				});
				text.x = icon.x + icon.width + 5;
				text.y = -4;
				headContainer.addChild(text);
				
				if (int(s) == Ttechno.TECHNO || int(s) == Stock.COOKIE) {
					w = icon.width + text.textWidth + 25;
				}else {					
					var text2:TextField = drawText(App.data.storage[s].title, {
						fontSize:		25,
						autoSize:		'left',
						color:			0x5d2e04,
						borderColor:	0xf5ead8,
						shadowSize:		2
					});
					text2.x = text.x + text.width + 10;
					headContainer.addChild(text2);
					
					w = icon.width + text.textWidth + text2.textWidth + 25;
				}
			}
		}
	}		
}