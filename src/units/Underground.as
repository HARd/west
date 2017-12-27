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
	import wins.UndergroundWindow;
	import wins.Window;
	import ui.SystemPanel;
	
	public class Underground extends Building 
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
		public var money:uint = 0;
		public var burst:uint = 0;
		
		public var defaultCellPrice:uint = 0;
		public var defaultOpenPrice:uint = 0;
		//public var wallCountTries:int = 0;
		
		public var pathfinder:com.pathfinder.Pathfinder;
		
		public var expire:int;
		public var restore:int;
		private var validete:Boolean;		// нормальная таблица
		
		public var wID:int;
		
		public function Underground(object:Object) {
			
			restore = object.restore || 0;
			
			parseMap(object.map);
			
			super(object);
			
			
			// Валюта объекта
			if (sid == 2824)
				money = 2930;
			else
				money = 2617;
			
				
			// Взрыв
			if (info.burst && Numbers.countProps(info.burst) > 0)
				burst = Numbers.firstProp(info.burst).key;
			
			
			// Преобразование items
			var array:Array = [];
			for (var blockID:* in info.items) {
				for (var SID:* in info.items[blockID]) {
					for (var i:int = info.items[blockID][SID]; i > 0; i--) {
						__items.push(SID);
					}
				}
			}
			
			
			// Позиция на сетке
			if (object.pos) {
				point = new Point(info.startX, info.startY);
			}
			
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
			helpPriceMultiply = object.steps || { };
			
			//if (Config.admin) {
				wID = App.map.id;
			//}else{
				//if (App.isSocial('VK', 'OK', 'FS', 'ML')) {
					//if (App.user.worldID != Travel.SAN_MANSANO) {
						//this.visible = false;
					//}
					//wID = Travel.SAN_MANSANO;
				//}else {
					//wID = User.HOME_WORLD;
					//this.visible = false;
				//}
			//}
			
			checkGrid();	// Проверка сетки
			
			if (sid == 2570) {
				//if (App.user.worldID != Travel.SAN_MANSANO)
					this.visible = false;
			}
			
			/*if (sid == 2824) {
				wID = User.HOME_WORLD;
			}*/
			
			moveable = true;
			
			if (App.user.mode == User.OWNER)
				App.self.setOnTimer(energyUpgrade);
		}
		
		// Попыкти создать стенки на клетке
		public function get wallCountTries():int {
			try {
				var value:int = App.data.options.wallCountTries;
				if (value < 0) return 200;
				return value;
			}catch (e:Error) {}
			
			return 200;
		}
		
		public function goSave(immediately:Boolean = false):void {
			App.user.storageStore(sid.toString(), Underground.save, immediately);
		}
		
		override public function onLoad(data:*):void {
			super.onLoad(data);
			
			if (this.level >= totalLevels) {
				initAnimation();
				startAnimation();
				checkAndDrawFirstFrame();
			}
			
			//if (App.user.mode == User.OWNER)
				//App.self.setOnTimer(energyUpgrade);
		}
		
		private var send:Boolean;
		private function energyUpgrade():void {
			if (!send && (App.time - restore) / info.time >= 1) {
				if (App.user.stock.count(currency) >= info.limit) {
					restore = App.time;
					return;
				}
				
				send = true;
				Post.send( {
					ctr:	type,
					act:	'restore',
					uID:	App.user.id,
					wID:	wID,//App.map.id,
					sID:	sid,
					id:		id
				}, function(error:int, data:Object, params:Object):void {
					if (error) return;
					send = false;
					
					if (data.restore) {
						restore = data.restore;
					}else {
						restore = App.time;
					}
					
					if (data.hasOwnProperty('add'))
						App.user.stock.add(currency, data.add);
					
					if (data.hasOwnProperty('count'))
						App.user.stock.data[currency] = data.count;
					
				});
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
			
			var obj:Object = App.user.storageRead('under' + String(sid), null);
			if (!obj) {
				App.user.storageStore('under' + String(sid), 1, true);
			}
			
			if (!validete)
				return;
			
			new UndergroundWindow( {
				target:		this,
				showHelp:	(obj) ? false: true
			}).show();
		}
		
		/*override protected function onCraftEvent(error:int, data:Object, params:Object):void {
			
			// Получаем и забираем награду
			super.onCraftEvent(error, data, params);
			
			if (error) return;
			
			storageEvent();
			
			var window:MinigameWindow = Window.isClass(MinigameWindow);
			if (window && window.opened) {
				window.onCraftComplete();
			}
		}*/
		
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
			
			// Добавление sid сундука который открываем
			var objects:Object = { };
			for (var i:int = 0; i < cells.length; i++) {
				objects[i] = { x:cells[i].x, y:cells[i].y };
				
				var cell:Object = grid[cells[i].x][cells[i].y];
				if (cell !== 0 && cell.hasOwnProperty('id'))
					objects[i].b = items[cell.id];
			}
			
			Post.send( {
				ctr:	type,
				act:	'go',
				sID:	sid,
				id:		id,
				uID:	App.user.id,
				wID:	wID,//App.map.id,
				cells:	JSON.stringify(objects) //JSON.stringify(cells)
			}, onGoAction, { cells:cells, callback:callback });
		}
		protected function onGoAction(error:int, data:Object, params:Object):void {
			if (error) return;
			
			// Обнулить время отсчета возобновления энергии
			if (restore < info.time)
				restore = App.time;
				
			if (data.restore) {
				restore = data.restore;
			}
			
			openCells(params.cells);
			
			if (data.bonus)
				App.user.stock.addAll(Treasures.treasureToObject(data.bonus));
			
			/*for (var i:int = 0; i < params.cells.length; i++) {
				App.user.stock.takeAll(cellPrice(params.cells[i].x, params.cells[i].y));
			}*/
			
			if (data.price)
				App.user.stock.takeAll(data.price);
			
			if (params.callback != null)
				params.callback(data.bonus);
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
					price[helpCurrency(openType)] = helpPrice(openType);
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
				wID:	wID,//App.map.id,
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
				
				var coord:Coordinate = cells[i];
				
				if (grid[coord.x][coord.y] == 0)
					grid[coord.x][coord.y] = { o:1 };
				else if (grid[coord.x][coord.y].r && typeof(grid[coord.x][coord.y].r) == 'object')
					grid[coord.x][coord.y] = 0;
				else {
					grid[coord.x][coord.y]['o'] = 1;
					
					if (grid[coord.x][coord.y].id >= 0)
						delete grid[coord.x][coord.y].id;
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
		public function cellPrice(x:int, y:int):Object {
			var price:Object = { };
			
			if (grid[x][y] && grid[x][y].r) {
				price = grid[x][y].r;
			}else if (grid[x][y] && grid[x][y].o == 1) {
				price[currency] = defaultOpenPrice;
			}else{
				price[currency] = defaultCellPrice;
				
				for (var i:int = x - PRICE_RANGE; i <= x + PRICE_RANGE; i++) {
					if (i < 0 || grid.length <= i) continue;
					for (var j:int = y - PRICE_RANGE; j <= y + PRICE_RANGE; j++) {
						if (j < 0 || grid[i].length <= j || grid[i][j] == 0 || !grid[i][j].hasOwnProperty('id')) continue;
						
						var multiIndex:uint = Math.abs(x - i) + Math.abs(y - j);
						if (multiIndex >= cellMultiPoles.length) continue;
						
						var item:Object = App.data.storage[items[grid[i][j].id]];
						
						price[currency] += item[cellMultiPoles[multiIndex]];
					}
				}
			}
			
			return price;
		}
		
		
		/**
		 * Валюта помощи
		 */
		public function helpCurrency(type:int):int {
			var sid:*;
			if (type == OPENTYPE_POINT) {
				for (sid in info.burst) break; 
			}else {
				for (sid in info.open) break;
			}
			return sid;
		}
		
		
		/**
		 * Цена помощи
		 */
		public function helpPrice(type:int):int {
			if (type == 1) {
				for (var sid:* in info.burst) break;
				return info.burst[sid];
			}
			
			var value:int = info['text' + type.toString()]/* + int(helpPriceMultiply[type]);*/
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
			
			
			if (App.user.settings.hasOwnProperty('underground_' + sid))
				delete App.user.settings['underground_' + sid];
			
			if (App.user.settings.hasOwnProperty('underground_' + sid + '_' + id))
				delete App.user.settings['underground_' + sid + '_' + id];
			
			/*var countWalls:int = 0;
			if (grid) {
				
				for (var i:int = 0; i < grid.length; i++) {
					for (var j:int = 0; j < grid[i].length; j++) {
						if (grid[i][j] !== 0 && grid[i][j].w is String)
							countWalls += grid[i][j].w.length;
					}
				}
				if (wallCountTries > 0 && countWalls > wallCountTries + 2) {
					if (App.user.settings.hasOwnProperty('underground_' + sid))
						delete App.user.settings['underground_' + sid];
					
					var walls:Object = App.user.storageRead('underground_' + sid + '_' + id, null );
					if (!walls) {
						while (countWalls > wallCountTries) {
							while (true) {
								var cell:int = Math.random() * gridCells;
								var row:int = Math.random() * gridRows;
								var item:Object = grid[cell][row];
								
								if (item == 0 || !item.w || item.w.length == 0) continue;
								
								item.w = item.w.substring(1, item.w.length);
								break;
							}
							countWalls--;
						}
						App.user.storageStore('underground_' + sid + '_' + id, grid );
					}else {
						for (i = 0; i < grid.length; i++) {
							for (j = 0; j < grid[i].length; j++) {
								if (grid[i][j] != 0 && grid[i][j].w && walls[i][j] != 0 && grid[i][j].w != walls[i][j].w)
								grid[i][j].w = walls[i][j].w;
							}
						}
					}
				}
			}*/
			
			
			createUndergroundGrid();
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
		
		
		private function createUndergroundGrid(again:Boolean = false):void {
			validateGrid();
			
			if (grid && !again) return;
			
			var pregrid:Array = generateUndergroundGrid();
			
			//App.user.storageStore('underground_' + sid, { } );
			
			Post.send( {
				ctr:		type,
				act:		'save',
				sID:		sid,
				id:			id,
				uID:		App.user.id,
				wID:		wID,//App.map.id,
				map:		JSON.stringify(pregrid)
			}, function(error:int, data:Object, params:Object):void {
				if (error) return;
				
				if (!data.map) return;
				
				validete = true;
				parseMap(data.map);
			});
		}
		private function validateGrid():void {
			if (!grid) return;
			
			var targets:Array = [172,173,1886];
			var invalid:Boolean;
			for (var i:int = 0; i < grid.length; i++) {
				for (var j:int = 0; j < grid[i].length; j++) {
					if (grid[i][j] != 0 && grid[i][j].hasOwnProperty('id') && grid[i][j].hasOwnProperty('r')) {
						var item:Object = App.data.storage[items[grid[i][j].id]];
						var find:Boolean = false;
						for (var s:* in grid[i][j].r) {
							if (targets.indexOf(s) > -1 && item.items) {
								for each(var object:Object in item.items) {
									if (object.hasOwnProperty(s)) find = true;
								}
								if (!find) {
									invalid = true;
								}
							}
						}
					
					}
				}
			}
			
			if (!invalid) {
				validete = true;
				return;
			}
			
			Post.send( {
				ctr:		type,
				act:		'generate',
				uID:		App.user.id,
				wID:		wID,
				sID:		sid,
				id:			id
			}, function(error:int, data:Object, params:Object = null):void {
				if (error) return;
				
				if (data.map)
					parseMap(data.map);
				
				validete = true;
			});
		}
		
		private function generateUndergroundGrid():Array {
			
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
				
				var cellInfo:Object = App.data.storage[items[id]];
				var numOfRequire:int = Numbers.countProps(cellInfo.items);
				var require:Object = { };
				
				if (numOfRequire >= 2) {
					var ids:Array = [];
					
					for (var s:* in cellInfo.items) {
						ids.push(s);
					}
					while (Numbers.countProps(require) < 2) {
						var index:int = int(ids.length * Math.random());
						var object:Object = cellInfo.items[ids[index]];
						for (var key:* in object) break;
						require[key] = object[key];
					}
					
					array[x][y] = { id:id, o:0, r:require };
				}else if (numOfRequire == 1) {
					require = cellInfo.items[0];
					array[x][y] = { id:id, o:0, r:require };
				} else{
					array[x][y] = { id:id, o:0 };
				}
				
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
			if (array.length > info.startX && array[point.x].length > info.startY) {
				array[point.x][point.y] = { o:1 };
				array[point.x + 1][point.y] = { o:1 };
			}else if (array.length > 0 && array[0].length > 0) {
				array[int(array.length * 0.5)][int(array.length * 0.5)] = { o:1 };
			}
			
			// Добавляем один клад рядом с позицией (нулевой)
			/*var cell_id:int;
			if (point.y == 0) {
				cell_id = 16;
				array[point.x + 2][point.y + 2] = { id:cell_id, o:0 };
				array[point.x - 1][point.y + 1] = { id:0, o:0 };
			}else {
				cell_id = 16;
				array[point.x + 2][point.y + 2] = { id:cell_id, o:0 };
				array[point.x + 1][point.y - 1] = { id:0, o:0 };
			}*/
			
			// Добавление клеток c кладами
			for (var cid:* in items) {
				//if (cid == 0) continue;	// Пропускаем потому что насильно добавили
				
				for (j = 0; j < 1000; j++) {
					var cell:int = int(Math.random() * gridCells);
					var row:int = int(Math.random() * gridRows);
					
					// Специфическое расположение определенных ячеек (монстры с определенных слоях)
					if (sid == 2570) {
						if (items[cid] == 2571) row = int(Math.random() * gridRows / 3);
						if (items[cid] == 2576) row = 20 + int(Math.random() * gridRows / 3);
						if (items[cid] == 2577) row = 40 + int(Math.random() * gridRows / 3);
						
						if (cell > info.startX - 4 && cell < info.startX + 4 && row >= 0 && row < 6)
							continue;
					}
					
					// Занять клетку
					if (take(cell, row, cid))
						break;
				}
			}
			
			
			// Создать стены для клеток
			// Добавить стенки
			/*if (sid == 2824) {
				var totalSteps:int = wallCountTries;
				while (totalSteps > 0) {
					cell = int(Math.random() * gridCells);
					row = int(Math.random() * gridRows);
					
					// Если близко к точке респауна
					if (cell > info.startX - 3 && cell < info.startX + 3 && row > info.startY - 3 && row < info.startY + 3) continue;
					if (array[cell][row] === 0) array[cell][row] = { };
					if (array[cell][row].hasOwnProperty('w')) continue;
					
					var wall:String = '';
					if (Math.random() < 0.33) {
						wall = 'r';
					}else if (Math.random() < 0.66) {
						wall = 'b';
					}else {
						wall = 'rb';
					}
					
					// Если клетка получается замкнутой, то не рисовать стенки
					if (wall == 'rb') {
						try {
							if (array[cell - 1][row].w.indexOf('r') > -1 || array[cell][row - 1].w.indexOf('b') > -1)
								continue;
						}catch(e:*) {
							continue;
						}
						
						//if ((!array[cell - 1] && !array[cell][row - 1].hasOwnProperty('w')) ||
							//(!array[cell][row - 1] && !array[cell - 1][row].hasOwnProperty('w')) ||
							//(array[cell - 1][row] != 0 && array[cell - 1][row].hasOwnProperty('w') && array[cell - 1][row].w.indexOf('r') == -1) ||
							//(array[cell][row - 1] != 0 && array[cell][row - 1].hasOwnProperty('w') && array[cell][row - 1].w.indexOf('b') == -1)) {
								//trace('Underground: Bad wall combine!!!', cell, row);
							//}else {
								//continue;
							//}
						
						//if ((!array[cell - 1] || (array[cell - 1][row] != 0 && array[cell - 1][row].hasOwnProperty('w') && array[cell - 1][row].w.indexOf('r') > -1)) &&
							//(!array[cell][row - 1] || (array[cell][row - 1] != 0 && array[cell][row - 1].hasOwnProperty('w') && array[cell][row - 1].w.indexOf('b') > -1))) continue;
					}
					
					array[cell][row]['w'] = wall;
					totalSteps --;
				}
			}*/
			
			/*var s:int = 1;
			var sides:Array = ['bottom', 'right'];
			while (s * 5 <= gridCells) {
				for (var k:int = 0; k < 5; k++) {
					var side:String;
					var w:int;
					var q:int;
					var finded:Boolean = false;
					while (!finded) {
						create();
						
						if (array[w][q].hasOwnProperty(side) && array[w][q][side] == 1) {
							create();
						}else {
							finded = true;
						}
					}
					array[w][q][side] = 1;
					
					function create():void {
						side = sides[Math.random() * sides.length];
						w = Math.random() * 5 * s;
						q = Math.random() * 5 * s;
					}
				}
				s++;
			}*/
			
			
			// Создать все клетки с кладами
			//for (var k:int = 0; k < gridCells; k++) {
				//for (var l:int = 0; l < gridRows; l++) {
					//if (array[k][l] != 0 && array[k][l]['o'] == 1) continue;
					//array[k][l] = { id:33, o:0, r:App.data.storage[2575].items[0] };
				//}
			//}
			
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
		private var __items:Array = [];
		public function get items():Object {
			return __items;
		}
		
		
		/**
		 * Возвращает список кладов доступных на сетке с удаленностями от точки персонажа
		 */
		public function getTreasures():Array {
			var list:Array = [];
			
			for (var i:int = 0; i < grid.length; i++) {
				for (var j:int = 0; j < grid[i].length; j++) {
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
		
		
		override public function uninstall():void {
			//App.self.setOffTimer(energyUpgrade);
			
			super.uninstall();
		}
		
		
		// Tutorial
		public function get tutorial():Boolean {
			return false;
		}
		
	}

}