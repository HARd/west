package 
{
	import flash.utils.getDefinitionByName;
	import flash.utils.setTimeout;
	import units.Building;
	import units.Unit;
	import wins.ShopWindow;
	import wins.TravelWindow;
	/**
	 * ...
	 * @author 
	 */
	public class Find 
	{
		
		public static function find(sid:*):Boolean {
			
			var finded:Boolean;
			var info:Object = App.data.storage[sid];
			var maps:Array = [];
			var mapID:int;
			var unitsOnMap:Array;
			
			if (!info)
				return finded;
			
			// Поиск как территории
			if (isTerritory(info.type)) {
				finded = true;
				TravelWindow.show( { find:[sid] } );
			}
			
			/*if (isEnergy(info.type)) {
				if (App.data.storage[info.out].
			}*/
			
			// Поиск как материала
			if (isMaterial(info.type))
				finded = ShopWindow.findMaterialSource(sid);
			
			// Поиск как Unit
			if (isUnit(info.type)) {
				unitsOnMap = Map.findUnits([sid]);
				if (unitsOnMap.length > 0) {
					App.map.focusedOn(unitsOnMap[0], true);
				}else if (Storage.instanceMaps(sid).length > 0 && Storage.instanceMaps(sid).indexOf(App.user.worldID) == -1) {
					mapID = Storage.instanceMaps(sid)[0];
					
					TravelWindow.show( { find:mapID } );
					
					stepRequire = {
						sid:		sid,
						mapID:		mapID
					}
				}else if (ShopWindow.search(sid, true)) {
					ShopWindow.find(sid);
				}else{
					maps = availableOnMaps(sid);
					if (maps.length > 0) {
						TravelWindow.show( { find:maps[0] } );
						
						stepRequire = {
							sid:		sid,
							mapID:		maps[0]
						}
					}
				}
				
				finded = true;
			}
			
			return finded;
			
		}
		
		
		/**
		 * Определить, является тип территория
		 * @param	type
		 * @return
		 */
		private static function isTerritory(type:String):Boolean {
			if ([Storage.LANDS].indexOf(type) > -1)
				return true;
			
			return false;
		}
		
		
		/**
		 * Определить, является тип материалом
		 * @param	type
		 * @return
		 */
		private static function isMaterial(type:String):Boolean {
			if ([Storage.MATERIAL, Storage.ENERGY].indexOf(type) > -1)
				return true;
			
			return false;
		}
		
		
		/**
		 * Определить, является тип Unit (их можно ставить на карту)
		 * @param	type
		 * @return
		 */
		private static function isUnit(type:String):Boolean {
			try {
				var classType:Class = getDefinitionByName('units.' + type) as Class;
				return true;
			}catch (e:Error) { }
			
			return false;
		}
		
		
		/**
		 * Доступен на катре
		 */
		public static function availableOnMaps(sid:*):Array {
			
			function landSort(land1:int, land2:int):int {
				
				// Сортировка по наличию на ругих картах
				if (App.user.instance[land1] && App.user.instance[land2]) {
					if (App.user.instance[land1][sid] > App.user.instance[land2][sid])
						return 1;
					
					if (App.user.instance[land1][sid] < App.user.instance[land2][sid])
						return -1;
				}
				
				// Сортировка по открытости карт
				if (App.user.worlds[land1] && !App.user.worlds[land2])
					return 1;
				
				if (!App.user.worlds[land1] && App.user.worlds[land2])
					return -1;
				
				return 0;
			}
			
			var info:Object = App.data.storage[sid];
			var lands:Array = [];
			var world:Object;
			var bSID:String;
			var land:int;
			
			for (var i:int = 0; i < App.user.lands.length; i++) {
				land = App.user.lands[i];
				world = App.data.storage[land];
				
				if (world.hasOwnProperty('objects')) {
					for (bSID in world.objects) {
						if (sid == world.objects[bSID] && info.visible) {
							trace('Find.Objects land:', land);
							lands.push(land);
						}
					}
				}
				if (world.hasOwnProperty('stacks') && lands.indexOf(land) == -1) {
					for (bSID in world.stacks) {
						if (sid == world.stacks[bSID]) {
							trace('Find.Stacks land:', land);
							lands.push(land);
						}
					}
				}
			}
			
			
			// Если не нашло на карте и в магазине карты, то
			for (i = 0; i < App.user.lands.length; i++) {
				land = App.user.lands[i];
				world = App.data.storage[land];
				
				if (world.shop && lands.length == 0 && lands.indexOf(land) == -1) {
					for (var market:* in world.shop) {
						if (world.shop[market][sid] == 1 && info.visible) {
							trace('Find.Shop land:', land);
							lands.push(land);
						}
					}
				}
			}
			
			lands.sort(landSort);
			
			return lands;
		}
		
		
		/**
		 * Проверка на последовательный поиск
		 */
		public static var stepRequire:Object;
		private static var stepTimeout:int;
		public static function nextStep():void {
			
			//if (App.user.id != '120635122')
				//return;
			
			if (!stepRequire)
				return;
			
			if (stepTimeout)
				return;
			
			stepTimeout = setTimeout(nextStepAction, 500);
		}
		private static function nextStepAction():void {
			if (stepRequire.mapID > 0) {
				if (stepRequire.mapID == App.user.worldID)
					find(stepRequire.sid);
			}else if (false) {
				
			}
			
			stepTimeout = 0;
			stepRequire = null;
		}
		
	}

}