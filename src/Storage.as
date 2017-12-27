package {
	import core.Numbers;
	import flash.net.SharedObject;
	import flash.utils.ByteArray;
	import ui.LeftPanel;
	import units.Unit;
	

	public class Storage {
		
		
		public static const MATERIAL:String = 'Material';
		public static const BUILDING:String = 'Building';
		public static const ENERGY:String = 'Energy';
		public static const COLLECTION:String = 'Collection';
		public static const RESOURCE:String = 'Resource';
		public static const LANDS:String = 'Lands';
		
		
		
		// Инфо объекта
		public static function info(sid:*):Object {
			if (App.data.storage[sid])
				return App.data.storage[sid];
			
			return { };
		}
		
		
		/**
		 * Цена
		 * @param	sid
		 * @return
		 */
		public static function price(sid:*):Object {
			var object:Object = { };
			if (App.data.storage.hasOwnProperty(sid)) {
				var info:Object = App.data.storage[sid];
				if (info.hasOwnProperty('instance')) {
					var countOnMap:int = 0;
					if (info.hasOwnProperty('instance') && !info.attachTo) {
						countOnMap = Storage.instanceGet(info.sid);
					}else {
						countOnMap = World.getBuildingCount(info.sid);
					}
					
					countOnMap += App.user.stock.count(info.sid);
					
					object = info.instance.cost[countOnMap + 1];
					if (!object) {
						var max:int = 0;
						for (var lvl:* in info.instance.cost) {
							if (max < int(lvl))
								max = int(lvl);
						}
						object = info.instance.cost[max];
					}
				}else if (info.hasOwnProperty('price')) {
					if (info.price.hasOwnProperty('item') && info.price.hasOwnProperty('count')) {
						for (var s:* in info.price.item) {
							object[info.price.item[s]] = info.price.count[s];
						}
					}else{
						object = info.price;
					}
				}
			}
			return object;
		}
		
		
		/**
		 * Возвращает либо значение уровня объекта, либо максимальное значение
		 * @param	object
		 * @param	level
		 * @return
		 */
		public static function maxOfKey(object:Object, level:int = 1):* {
			
			if (!object || Numbers.countProps(object) == 0)
				return 0;
			
			var levels:Array = [];
			var last:int = 0;
			var limit:int = Numbers.countProps(object);
			
			// Выбрать все уровни инстанса
			for (var lvl:* in object) {
				levels.push(lvl);
			}
			levels.sort();
			last = levels[levels.length - 1];
			
			if (level < levels[0])
				level = levels[0];
			
			if (level > last)
				level = last;
			
			return object[level];
		}
		
		
		
		
		public static function canBuy(sid:*):Boolean {
			var object:Object = App.data.storage[sid];
			
			if (!object)
				return false;
			
			if (object['jems'] > 0 && object['jems'] <= App.user.stock.count(Stock.FANT))
				return true;
			
			if (object['coins'] > 0 && object['coins'] <= App.user.stock.count(Stock.COINS))
				return true;
			
			if (object['currency'] && Numbers.countProps(object.currency) > 0 && App.user.stock.checkAll(object.currency))
				return true;
			
			return false;
		}
		
		public static function needForBuy(sid:*):Object {
			var object:Object = App.data.storage[sid];
			
			if (object) {
				var result:Object = { };
				
				if (object['bucks'] > 0 && object['bucks'] > App.user.stock.count(Stock.FANT)) {
					if (!result[Stock.FANT]) result[Stock.FANT] = 0;
					result[Stock.FANT] += object.jems;
				}
				
				if (object['coins'] > 0 && object['coins'] > App.user.stock.count(Stock.COINS)) {
					if (!result[Stock.FANT]) result[Stock.COINS] = 0;
					result[Stock.COINS] += object.coins;
				}
				
				if (object['currency'] > 0 && Numbers.countProps(object.currency) > 0) {
					for (var s:* in object.currency) {
						if (!result[s]) result[s] = 0;
						result[s] += object.currency[s];
					}
				}
				
				return result;
			}
			
			return null;
		}
		
		public static function sharedStore(key:String, data:Object):void {
			if (!data) return;
			
			var bytes:ByteArray = new ByteArray();
			bytes.writeObject(data);
			bytes.compress();
			
			var shared:SharedObject = SharedObject.getLocal('df6bvz1', '/');
			shared.data[key] = bytes;
			shared.flush();
		}
		
		public static function sharedRead(key:String, _default:* = null):* {
			var shared:SharedObject = SharedObject.getLocal('df6bvz1', '/');
			var object:* = shared.data[key];
			
			if (object is ByteArray) {
				var bytes:ByteArray = object as ByteArray;
				bytes.uncompress();
				return bytes.readObject();
			}else {
				return _default;
			}
		}
		
		public static function japanFormat(string:String, numberOverNewLine:uint = 30):String {
			var ieroglyphs:Array = ['み','い','の','ね','も','う','フ','テ','ィ','バ','ル','の','は','わ','て','る','わ','こ','で','け','ね','、','し','い','サ','テ','ン','ど','う','や','っ','ケ','ア','す','る','え','あ','げ','る','わ'];
			var position:uint = 0;
			
			while (position + numberOverNewLine < string.length) {
				while (ieroglyphs.indexOf(string.charAt(position + numberOverNewLine)) != -1 && position + numberOverNewLine < string.length) {
					position ++;
				}
				string = string.substring(0, position + numberOverNewLine + 1) + '\n' + string.substring(position + numberOverNewLine + 1);
				position = position + numberOverNewLine + 1;
			}
			
			return string;
		}
		
		
		/**
		 * Cколько есть объектов на складе и карте
		 * @param	sid
		 * @return
		 */
		public static function globalCount(sid:int):int {
			var count:int = App.user.stock.count(sid) + ((Map.ready) ? Map.findUnits([sid]).length : 0);
			return count;
		}
		
		
		
		/**
		 * Ограничение на покупку в игре
		 * @param	sid
		 * @return
		 */
		public static var shopLimitList:Object;
		public static var shopLimitIDs:Array = [];
		public static function shopLimitCheck():void {
			//App.user.storageStore('shopLimit', { }, true );
			shopLimitList = App.user.storageRead('shopLimit', { } );
			
			for each(var sid:* in shopLimitIDs) {
				if (!shopLimitList.hasOwnProperty(sid))
					shopLimitList[sid] = 0;
				
				// Блокировка если есть
				var count:int = Storage.globalCount(sid);
				if (count > 0 && count > shopLimitList[sid])
					shopLimitList[sid] = count;
			}
		}
		
		// Добавление одного объекта в список лимита
		public static function shopLimitBuy(sid:*, count:int = 1):void {
			Storage.shopLimitList[sid] = int(Storage.shopLimitList[sid]) + count;
		}
		
		public static function isShopLimited(sid:*):Boolean {
			return (Storage.shopLimitIDs.indexOf(int(sid)) != -1);
		}
		
		// Вернуть - сколько уже куплено
		public static function shopLimit(sid:*):int {
			return (Storage.shopLimitList.hasOwnProperty(sid)) ? Storage.shopLimitList[sid] : 0;
		}
		
		// Можно купить или нет
		public static function shopLimitCanBuy(sid:*):Boolean {
			if (isShopLimited(sid) && App.data.storage[sid].gcount <= Storage.shopLimitList[sid])
				return false;
			
			return true;
		}
		
		
		
		
		
		// ИНСТАНСЫ
		
		private static var __instance:Object;
		
		/**
		 * Инстанс
		 */
		public static function get instance():Object {
			return __instance;
		}
		public static function set instance(value:Object):void {
			__instance = value;
		}
		
		/**
		 * Добавить значение инстанса объекта
		 * @param	sid
		 * @param	wid
		 * @return
		 */
		public static function instanceAdd(sid:*, wid:int = 0):int {
			if (!wid) wid = App.user.worldID;
			
			if (!App.data.storage[sid]) return 0;
			
			if (!__instance[wid]) __instance[wid] = { };
			if (!__instance[wid][sid]) __instance[wid][sid] = 0;
			
			__instance[wid][sid] ++;
			
			return __instance[wid][sid];
		}
		
		/**
		 * Удалить значение инстанса объекта
		 * @param	sid
		 * @param	wid
		 * @return
		 */
		public static function instanceRemove(sid:*, wid:int = 0):int {
			if (!wid) wid = App.user.worldID;
			
			if (!App.data.storage[sid]) return 0;
			
			if (!__instance[wid]) __instance[wid] = { };
			if (!__instance[wid][sid]) __instance[wid][sid] = 0;
			
			__instance[wid][sid] --;
			if (__instance[wid][sid] < 0)
				__instance[wid][sid] = 0;
			
			return __instance[wid][sid];
		}
		
		/**
		 * Вернуть значиние инстанса объекта
		 * @param	sid
		 * @return
		 */
		public static function instanceGet(sid:*):int {
			
			var count:int = 0;
			
			if (__instance) {
				for (var wid:* in __instance) {
					if (__instance[wid] is int) {
						if (wid == sid)
							count += __instance[wid];
					}else if (__instance[wid][sid]) {
						count += __instance[wid][sid];
					}
				}
			}
			
			return count;
		}
		
		/**
		 * Вернуть значиние инстанса объекта
		 * @param	sid
		 * @return
		 */
		public static function instanceMaps(sid:*):Array {
			
			var array:Array = [];
			
			if (__instance) {
				for (var wid:* in __instance) {
					if (__instance[wid] is int) continue;
					if (__instance[wid][sid])
						array.push(wid);
				}
			}
			
			return array;
		}
		
		
		
		
		
		
		
		// КОМПОНОВКА ЗДАНИЙ (component)
		
		/**
		 * Считывает список скомпонированных зданий на карте
		 * @param	mID		карта
		 * @param	sid		идентификатор
		 * @return
		 */
		public static function componentsGet(mID:*, sid:int = 0):Object {
			var data:Object = App.user.storageRead('component', { } );
			
			if (App.user.id != '120635122')
				return { };
			
			if (data[mID]) {
				if (sid == 0)
					return data[mID];
				
				if (data[mID][sid])
					return data[mID][sid];
			}
			
			return { };
		}
		
		/**
		 * Возвращает основной компонент
		 * @param	mID		карта
		 * @param	sid		идентификатор
		 * @return
		 */
		public static function componentGetMain(mID:*, sid:int = 0):Unit {
			var data:Object = App.user.storageRead('component', { } );
			
			if (data[mID] && data[mID][sid]) {
				for (var id:* in data[mID][sid]) {
					if (data[mID][sid][id] == 1)
						return Map.findUnit(sid, id);
				}
			}
			
			return null;
		}
		
		/**
		 * Помещает здание в список скомпонированных на карте
		 * @param	mID		карта
		 * @param	main	экземпляр юнита главный, который останется на карте
		 * @param	unit	экземпляр юнита
		 */
		public static function componentSet(mID:*, unit:Unit):Boolean {
			var data:Object = App.user.storageRead('component', { } );
			
			if (!data.hasOwnProperty(mID)) data[mID] = { };
			if (!data[mID].hasOwnProperty(unit.sid)) data[mID][unit.sid] = { };
			if (Numbers.countProps(data[mID][unit.sid]) == 0) {
				data[mID][unit.sid][unit.id] = 1;
			}else {
				data[mID][unit.sid][unit.id] = 0;
				
				var find:Boolean;
				for (var id:* in data[mID][unit.sid]) {
					if (data[mID][unit.sid][id] == 1) {
						find = true;
						break;
					}
				}
				
				var main:Unit = Map.findUnit(unit.sid, id);
				if (!main)
					return false;
				
				unit.placing(main.coords.x, 0, main.coords.z);
				unit.moveAction();
			}
			
			App.user.storageStore('component', data, true);
			
			return true;
		}
		
		
		/**
		 * Cколько таких объектов было куплено ВООБЩЕ
		 * @param	sid
		 * @return
		 */
		public static function globalBuyed(sid:int):int {
			var global:int = 0;
			if (App.data.storage[sid] && App.data.storage[sid].gcount > 0) {
				if (!shopLimitList) shopLimitList = App.user.storageRead('shopLimit', { } );
				global = int(shopLimitList[sid]);
			}
			
			return global;
		}
		
		
		/**
		 * Cколько таких объектов было куплено на карте
		 * @param	sid
		 * @return
		 */
		public static function buyedOnMap(sid:*, mapID:*):int {
			return ((App.user.instance && App.user.instance[mapID]) ? int(App.user.instance[mapID][sid]) : 0);
		}
		
		
		/**
		 * Cколько таких объектов было куплено
		 * @param	sid
		 * @return
		 */
		public static function buyed(sid:int):int {
			var count:int = 0;
			if (App.user.instance) {
				for (var mapID:* in App.user.instance) {
					if (typeof(App.user.instance[mapID]) != 'object') continue;
					count += int(App.user.instance[mapID][sid]);
				}
			}
			
			return count;
		}
		
		
		/**
		 * Удаляет здание из списка скомпонированных на карте
		 * @param	mID		карта
		 * @param	unit	экземпляр юнита
		 * @return
		 */
		public static function componentUnset(mID:*, unit:Unit):Boolean {
			var data:Object = App.user.storageRead('component', { } );
			
			if (!data.hasOwnProperty(mID)) return false;
			if (!data[mID].hasOwnProperty(unit.sid)) return false;
			if (!data[mID][unit.sid].hasOwnProperty(unit.id)) return false;
			
			if (data[mID][unit.sid][unit.id] == 1) {
				for (var id:* in data[mID][unit.sid]) {
					if (data[mID][unit.sid][id] == 0) {
						data[mID][unit.sid][id] = 1;
						break;
					}
				}
			}
			
			delete data[mID][unit.sid][unit.id];
			
			App.user.storageStore('component', data, true);
			
			return true;
		}
		
		/**
		 * Возвращает список возможных крафтов одной строкой
		 * @param	item		объект storage'a
		 * @return
		 */
		public static function getCrafts(item:Object):String
		{
			var totalLevels:int = (item.devel) ? Numbers.countProps(item.devel.req) : 0;
			var defText:String = '';
			var prevItm:String;
			var crafting:Object = App.data.crafting;
			var craft:Object = item.devel.craft[totalLevels];
			var storage:Object = App.data.storage;
			var out:Object;
			
			for (var itm:String in craft) {
				if (!crafting.hasOwnProperty(craft[itm])) 
					continue;
				
				out = crafting[craft[itm]].out;
				if (prevItm && prevItm == storage[out].title || !User.inUpdate(out)) 
					break;
				if (defText.length > 0) 
					defText += ', ';
				defText += storage[out].title;
				prevItm = storage[out].title;
			}
			
			return defText;
		}
		
	}
	
}