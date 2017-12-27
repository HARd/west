package units 
{
	import com.pathfinder.Coordinate;
	import com.pathfinder.EHeuristic;
	import com.pathfinder.MapData;
	import com.pathfinder.Pathfinder;
	import core.Numbers;
	import core.Post;
	import effects.Effect;
	import flash.geom.Point;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;
	import wins.MinigameTutorialWindow;
	import wins.SimpleWindow;
	import wins.MinigameWindow;
	import wins.Window;
	
	public class Minigame extends Building 
	{
		
		public static const OPENTYPE_POINT:uint = 1;
		public static const OPENTYPE_RANDOMPOINT:uint = 2;
		public static const OPENTYPE_3X3ZONE:uint = 3;
		public static const OPENTYPE_LAST:uint = 4;
		
		public static const NO_PRICE:String = 'noPrice';
		
		public static var save:Object;
		
		public const PRICE_RANGE:uint = 4;
		
		private var helpPriceMultiply:Object;
		
		public var currency:uint = 0;
		public var defaultCellPrice:uint = 0;
		public var defaultOpenPrice:uint = 0;
		
		public var pathfinder:com.pathfinder.Pathfinder;
		
		public var expire:int;
		
		public function Minigame(object:Object) {
			
			// Позиция на сетке
			if (object.pos) {
				point = new Point(object.pos.x, object.pos.y);
			}
			
			parseMap(object.map);
			
			super(object);
			
			expire = info.expire[App.social] || 0;
			
			if (expire > App.time)
				removable = false;
			
			// Цена страндартная на закрытую клетку
			for (var s:* in info.cost) {
				currency = uint(s);
				defaultCellPrice = info.cost[s];
			}
			
			// Цена страндартная на открытую клетку
			defaultOpenPrice = info.text5;
			
			// Цена страндартная на открытую клетку
			helpPriceMultiply = object.steps || {};
			
			Minigame.save = App.user.storageRead(sid.toString(), {
				panelState:		2,
				tutorial:		3
			});
		}
		
		public function goSave(immediately:Boolean = false):void {
			App.user.storageStore(sid.toString(), Minigame.save, immediately);
		}
		
		override public function onLoad(data:*):void {
			super.onLoad(data);
			checkGrid();
			
			if (this.level >= totalLevels){
				startAnimation();
			}
		}
		
		override public function openProductionWindow(settings:Object = null):void {
			
			if (expire < App.time) {
				new SimpleWindow( {
					title:		info.title,
					text:		Locale.__e('flash:1466147553176')
				}).show();
				return;
			}
			
			if (!grid) return;
			
			new MinigameWindow( {
				target:		this
			}).show();
		}
		
		override protected function onCraftEvent(error:int, data:Object, params:Object):void {
			
			// Получаем и забираем награду
			super.onCraftEvent(error, data, params);
			
			if (error) return;
			
			storageEvent();
			
			var window:MinigameWindow = Window.isClass(MinigameWindow);
			if (window && window.opened) {
				window.onCraftComplete();
			}
		}
		
		override public function onStorageEvent(error:int, data:Object, params:Object):void {
			if (error)
			{
				Errors.show(error, data);
				return;
			}
			
			//formula
			if (data.hasOwnProperty('bonus')) {
				var that:* = this;
				var exit:Boolean = false;
				for (var sID:* in data.bonus) {
					Effect.wowEffect(sID);
					var count:int = 0;
					for (var bs:* in data.bonus[sID]) {
						count += data.bonus[sID][bs] * bs;
					}
					App.user.stock.add(sID, count);
				}
			} 
			
			clearIcon();
			
			ordered = false;
			hasProduct = false;
			queue = [];
			crafted = 0;
			
			cantClick = false;
		}
		
		/**
		 * 
		 */
		public function goAction(cells:Vector.<Coordinate>, callback:Function = null):void {
			if (cells.length == 0) return;
			if (expire < App.time) return;
			
			Post.send( {
				ctr:	type,
				act:	'go',
				sID:	sid,
				id:		id,
				uID:	App.user.id,
				wID:	App.map.id,
				cells:	JSON.stringify(cells)
			}, onGoAction, { cells:cells, callback:callback });
		}
		protected function onGoAction(error:int, data:Object, params:Object):void {
			if (error) return;
			
			openCells(params.cells);
			
			//if (data.bonus)
				//App.user.stock.addAll(Treasures.treasureToObject(data.bonus));
			
			if (data.price)
				App.user.stock.takeAll(data.price);
			
			if (params.callback != null)
				params.callback(data.bonus);
			
			initTutorial();
		}
		
		
		
		/**
		 * 
		 */
		public function openAction(openType:uint, x:int, y:int, callback:Function = null):void {
			
			if (expire < App.time) return;
			
			var price:Object = { };
			
			switch(openType) {
				case OPENTYPE_POINT:
				case OPENTYPE_RANDOMPOINT:
				case OPENTYPE_3X3ZONE:
					price[currency] = helpPrice(openType);
					break;
				case OPENTYPE_LAST:
					price[currency] = helpPrice(OPENTYPE_LAST);
					break;
			}
			
			if (!App.user.stock.takeAll(price)) {
				callback(NO_PRICE);
				return;
			}
			
			Post.send( {
				ctr:	type,
				act:	'open',
				sID:	sid,
				id:		id,
				uID:	App.user.id,
				wID:	App.map.id,
				type:	openType,
				x:		x,
				y:		y
			}, onOpenAction, { openType:openType, callback:callback });
		}
		protected function onOpenAction(error:int, data:Object, params:Object):void {
			if (error) return;
			
			if (data.map)
				parseMap(data.map);
			
			if (data.bonus) {
				App.user.stock.addAll(Treasures.treasureToObject(data.bonus));
			}
			
			if (params.callback != null)
				params.callback(data.bonus);
			
			if (!helpPriceMultiply[params.openType])
				helpPriceMultiply[params.openType] = 0;
			helpPriceMultiply[params.openType] ++;
		}
		
		
		
		/**
		 * Сетка
		 */
		public var grid:Array;
		
		private function parseMap(map:Object = null):void {
			if (!map) return;
			
			grid = [];
			
			pathfinder = null;
			
			var cells:int = Numbers.countProps(map);
			var rows:int = Numbers.countProps(map[0]);
			var __mapData:Vector.<Boolean> = new Vector.<Boolean>();
			while (__mapData.length < cells * rows)
				__mapData.push(false);
			
			for (var i:* in map) {
				
				if (!grid[i]) grid[i] = [];
				
				for (var j:* in map[i]) {
					grid[i][j] = map[i][j];
					
					if (map[i][j] && map[i][j].o == 1) __mapData[j * cells + i] = true;
				}
			}
			
			pathfinder = new Pathfinder(new MapData(cells, rows, __mapData));
			
		}
		
		
		/**
		 * Открыть порядок ячеек
		 */
		public function openCells(cells:Vector.<Coordinate>):void {
			for (var i:int = 0; i < cells.length; i++) {
				point.x = cells[i].x;
				point.y = cells[i].y;
				
				if (grid[point.x][point.y] == 0)
					grid[point.x][point.y] = { o:1 };
				else {
					grid[point.x][point.y]['o'] = 1;
					
					if (grid[point.x][point.y].id >= 0)
						delete grid[point.x][point.y].id;
				}
				
			}
			
			parseMap(grid);
		}
		
		
		
		/**
		 * Проверить или открыта ячейка
		 */
		public function cellIsOpen(cell:int, row:int):Boolean {
			return (grid[cell][row] && grid[cell][row]['o'] == 1);
		}
		
		
		
		/**
		 * Цена списка ячеек
		 */
		public function takePrice(cells:Array):Object {
			var price:Object = { };
			price[currency] = 0;
			
			for (var i:int = 0; i < cells.length; i++) {
				price[currency] += cellPrice(cells[i].x, cells[i].y);
			}
			
			App.user.stock.takeAll(price);
			
			return price;
		}
		
		
		/**
		 * Или открыта ячейка рядом
		 */
		public function nearIsOpen(x:int, y:int):Boolean {
			return Boolean(nearIsOpenCells(x, y));
		}
		
		
		/**
		 * Или открыта ячейка рядом
		 */
		public function nearIsOpenCells(x:int, y:int):Array {
			var array:Array = [];
			
			if (grid[x - 1] && grid[x - 1][y] && grid[x - 1][y].o == 1) array.push({ x:x - 1, y:y });
			if (grid[x + 1] && grid[x + 1][y] && grid[x + 1][y].o == 1) array.push({ x:x + 1, y:y });
			if (grid[x][y - 1] && grid[x][y - 1].o == 1) array.push({ x:x, y:y - 1 });
			if (grid[x][y + 1] && grid[x][y + 1].o == 1) array.push( { x:x, y:y + 1 } );
			
			return (array.length) ? array : null;
		}
		
		
		/**
		 * Или открыта ячейка рядом
		 */
		public function nearIsPoint(x:int, y:int, nearx:int, neary:int):Boolean {
			if (neary == y && (nearx == x + 1 || nearx == x - 1))
				return true;
			
			if (nearx == x && (neary == y + 1 || neary == y - 1))
				return true;
			
			return false;
		}
		
		
		/**
		 * Цена ячейки
		 */
		private var cellMultiPoles:Array = ['text1','text2','text3','text4','text5'];
		public function cellPrice(x:int, y:int):uint {
			var price:uint = 0;
			
			if (grid[x][y] && grid[x][y].o == 1) {
				price = defaultOpenPrice;
			}else{
				price = defaultCellPrice;
				
				for (var i:int = x - PRICE_RANGE; i <= x + PRICE_RANGE; i++) {
					if (i < 0 || grid.length <= i) continue;
					for (var j:int = y - PRICE_RANGE; j <= y + PRICE_RANGE; j++) {
						if (j < 0 || grid[i].length <= j || grid[i][j] == 0 || !grid[i][j].hasOwnProperty('id')) continue;
						
						var multiIndex:uint = Math.abs(x - i) + Math.abs(y - j);
						if (multiIndex >= cellMultiPoles.length) continue;
						
						var item:Object = App.data.storage[items[grid[i][j].id]];
						
						price += item[cellMultiPoles[multiIndex]];
					}
				}
			}
			
			return price;
		}
		
		
		
		public function helpPrice(type:int):int {
			if (type == 4) type = 6;
			var value:int = info['text' + type.toString()] + info['text' + type.toString()] * int(helpPriceMultiply[type]) * info.text4 * 0.01;
			return value;
		}
		
		
		/**
		 * Поиск путь от последнего к первому
		 * @param	cell
		 * @param	row
		 * @return
		 */
		public function getRoadTo(cell:int, row:int):Vector.<Coordinate> {
			
			var start:Coordinate = new Coordinate(point.x, point.y);
			var finish:Coordinate;
			var road:Vector.<Coordinate> = new Vector.<Coordinate>;
			
			// Если рядом
			if (nearIsPoint(cell, row, point.x, point.y)) {
				road.push(new Coordinate(point.x, point.y), new Coordinate(cell, row));
			}else if (!grid[cell][row] || grid[cell][row].o != 1) {
				var nearCells:Array = nearIsOpenCells(cell, row);
				if (!nearCells) return null;
				
				var roads:Array = [];
				for (var i:int = 0; i < nearCells.length; i++) {
					var __finish:Coordinate = new Coordinate(nearCells[i].x, nearCells[i].y);
					var __road:Vector.<Coordinate> = pathfinder.createPath(start, __finish, EHeuristic.MANHATTAN, false);
					
					if (!__road || __road.length == 0) continue;
					
					roads.push(__road);
				}
				roads.sortOn('length', Array.NUMERIC);
				
				if (roads.length == 0) return null;
				
				roads[0].push(new Coordinate(cell, row));
				road = roads[0];
				
			}else {
				finish = new Coordinate(cell, row);
				road = pathfinder.createPath(start, finish, EHeuristic.MANHATTAN, false);
			}
			
			return road;
			
		}
		
		
		/**
		* Точка присутствия игрока на сетке
		*/
		private var __point:Point;
		public function get point():Point {
			if (!__point) {
				__point = new Point(info.startX || 0, info.startY || 0);
			}
			
			return __point;
		}
		public function set point(value:Point):void {
			__point = value;
		}
		
		
		/**
		 * Проверка наличия сетки и создание ее если она еще нужна
		 */
		private function checkGrid():void {
			if (!formed) return;
			if (expire < App.time) return;
			if (level < totalLevels) return;
			
			createMinigameGrid();
		}
		
		
		
		/**
		 * Создание сетки после постройки
		 */
		override protected function onBuyAction(error:int, data:Object, params:Object):void {
			super.onBuyAction(error, data, params);
			
			if (error) return;
			
			checkGrid();
		}
		override protected function onStockAction(error:int, data:Object, params:Object):void {
			super.onStockAction(error, data, params);
			
			if (error) return;
			
			checkGrid();
		}
		override public function onUpgradeEvent(error:int, data:Object, params:Object):void {
			super.onUpgradeEvent(error, data, params);
			
			if (error) return;
			
			checkGrid();
		}
		
		
		private function createMinigameGrid(again:Boolean = false):void {
			if (grid && !again) return;
			
			var pregrid:Array = generateMinigameGrid();
			
			Post.send( {
				ctr:		type,
				act:		'save',
				sID:		sid,
				id:			id,
				uID:		App.user.id,
				wID:		App.map.id,
				map:		JSON.stringify(pregrid)
			}, function(error:int, data:Object, params:Object):void {
				if (error) return;
				
				if (!data.map) return;
				
				parseMap(data.map);
			});
		}
		
		private function generateMinigameGrid():Array {
			
			const cellIndent:uint = 1;	// Отступ активных клеток друг от друга
			
			// Занять клетку если можно
			function take(x:int, y:int, id:int):Boolean {
				for (var i:int = x - cellIndent; i < x + cellIndent + 1; i++) {
					if (i < 0 || i >= array.length) continue;
					for (var j:int = y - cellIndent; j < y + cellIndent + 1; j++) {
						if (j < 0 || j >= array[i].length) continue;
						if (array[i][j]) return false;
					}
				}
				
				array[x][y] = { id:id, o:0 };
				
				return true;
			}
			
			var array:Array = [];
			
			// Создание пустой сетки
			for (var i:int = 0; i < gridCells; i++) {
				if (array.length <= i)
					array[i] = [];
				
				for (var j:int = 0; j < gridRows; j++) {
					array[i].push(0);
				}
			}
			
			// Добавление позиции отсчета (начало хода)
			if (array.length > info.startX && array[point.x].length > info.startY)
				array[point.x][point.y] = { o:1 };
			else if (array.length > 0 && array[0].length > 0)
				array[int(array.length * 0.5)][int(array.length * 0.5)] = { o:1 };
			
			// Добавляем один клад рядом с позицией (нулевой)
			array[point.x + 1][point.y] = { id:0, o:0 };
			
			// Добавление клеток c кладами
			for (var cid:* in items) {
				if (cid == 0) continue;	// Пропускаем потому что насильно добавили
				
				for (j = 0; j < 1000; j++) {
					var cell:int = int(Math.random() * gridCells);
					var row:int = int(Math.random() * gridRows);
					
					// Занять клетку
					if (take(cell, row, cid))
						break;
				}
			}
			
			// Создать все клетки с кладами
			/*for (var k:int = 0; k < gridCells; k++) {
				for (var l:int = 0; l < gridRows; l++) {
					if (array[k][l] != 0 && array[k][l]['o'] == 1) continue;
					array[k][l] = { id:int(Math.random() * items.length), o:0 };
				}
			}*/
			
 			return array;
		}
		
		/**
		 * Ширина и высота сетки
		 */
		public function get gridCells():int {
			return info.width;
		}
		public function get gridRows():int {
			return info.height;
		}
		
		/**
		* Список кладов
		*/
		private var __items:Array;
		public function get items():Object {
			return info.items;
		}
		
		
		/**
		 * Возвращает список кладов доступных на сетке с удаленностями от точки персонажа
		 */
		public function getTreasures():Array {
			var list:Array = [];
			
			for (var i:int = 0; i < grid.length; i++) {
				for (var j:int = 0; j < grid.length; j++) {
					if (grid[i][j] != 0 && grid[i][j].hasOwnProperty('id')) {
						list.push( {
							x:			i,
							y:			j,
							id:			grid[i][j].id,
							sid:		items[grid[i][j].id],
							distance:	Math.abs(point.x - i) + Math.abs(point.y - j)
						});
					}
				}
			}
			
			return list;
		}
		
		/**
		 * Возвращает доступные награды (берет из крафта и компонует по наградам)
		 */
		public function getRewards():Object {
			var object:Object = { };
			
			for each(var fid:* in info.crafting) {
				var formula:Object = App.data.crafting[fid];
				if (!formula) continue;
				/*for (var itemID:* in formula.items) {
					if (!User.inUpdate(itemID)) {
						formula = null;
						break;
					}
				}
				if (!formula) continue;*/
				object[fid] = formula;
			}
			
			return object;
		}
		
		
		
		// Tutorial
		public function get tutorial():Boolean {
			return Boolean(tutorialStep);
		}
		
		public function get tutorialStep():int {
			return Minigame.save.tutorial;
		}
		
		public function initTutorial():void {
			
			//Minigame.save.tutorial = 0;
			
			if (!tutorial) return;
			
			var window:MinigameWindow = Window.isClass(MinigameWindow);
			if (!window) return;
			
			
			tutorialNextStep();
			
		}
		
		public function tutorialNextStep():void {
			
			// Если нет денег, то и туториала нет
			if (cellPrice(info.startX, info.startY) + cellPrice(info.startX + 1, info.startY) > App.user.stock.count(currency))
				Minigame.save.tutorial = 0;
			
			if (tutorialStep == 3) {
				// Если игрок уже не на исходной позиции
				if (point.x != info.startX || point.y != info.startY)
					Minigame.save.tutorial = 2;
			}
			
			if (tutorialStep == 2) {
				// Если игрок уже не на исходной позиции
				if (point.x != info.startX + 1 && point.y != info.startY)
					Minigame.save.tutorial = 1;
			}
			
			if (Minigame.save.tutorial != 3 && cellIsOpen(info.startX + 1, info.startY) == false)
				Minigame.save.tutorial = 3;
			
			
			switch(tutorialStep) {
				case 3:
					setTimeout(tutorial_1, 1000);
					break;
				case 2:
					tutorial_4();
					break;
				case 1:
					tutorial_6();
					break;
			}
		}
		
		// Последовательность 1
		private function tutorial_1():void {
			var window:MinigameTutorialWindow = new MinigameTutorialWindow( {
				popup:			true,
				description:	Locale.__e('flash:1465829749336'),
				callback:		function():void {
					window.close();
					tutorial_2();
				}
			});
			window.show();
		}
		private function tutorial_2():void {
			var window:MinigameTutorialWindow = new MinigameTutorialWindow( {
				popup:			true,
				description:	Locale.__e('flash:1465829983298'),
				callback:		function():void {
					window.close();
					tutorial_3();
				}
			});
			window.show();
		}
		private function tutorial_3():void {
			var window:MinigameWindow = Window.isClass(MinigameWindow);
			if (!window) return;
			
			window.tutorialShowNearTreasureChest();
		}
		private function tutorial_4():void {
			var window:MinigameTutorialWindow = new MinigameTutorialWindow( {
				popup:			true,
				description:	Locale.__e('flash:1465830909141'),
				callback:		function():void {
					window.close();
					tutorial_5();
				}
			});
			window.show();
		}
		private function tutorial_5():void {
			var window:MinigameWindow = Window.isClass(MinigameWindow);
			if (!window) return;
			window.tutorialShowBackCell();
		}
		private function tutorial_6():void {
			var window:MinigameTutorialWindow = new MinigameTutorialWindow( {
				popup:			true,
				description:	Locale.__e('flash:1465830971493'),
				callback:		function():void {
					tutorial_7();
				}
			});
			window.show();
		}
		private function tutorial_7():void {
			var window:MinigameWindow = Window.isClass(MinigameWindow);
			if (!window) return;
			window.tutorialShowRewards();
		}
		
		public function checkVerify(type:String, ... args):Boolean {
			
			if (!tutorial) 
				return true;
			
			switch(type) {
				case 'rewards':
					if (tutorialStep == 1) {
						Minigame.save.tutorial = 0;
						goSave(true);
						return true;
					}
					break;
				case 'confirm':
					if (tutorialStep == 3) {
						Minigame.save.tutorial = 2;
						goSave();
						return true;
					}else if (tutorialStep == 2) {
						Minigame.save.tutorial = 1;
						goSave();
						
						return true;
					}
					break;
				case 'move':
					if (tutorialStep == 3) {
						if (args.length > 0 && args[0] == info.startX + 1 && args[1] == info.startY) {
							return true;
						}
					}else if (tutorialStep == 2) {
						if (args.length > 0 && args[0] == info.startX && args[1] == info.startY) {
							return true;
						}
					}
					break;
			}
			
			return false;
		}
		
	}

}