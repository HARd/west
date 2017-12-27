package managers 
{
	import units.Building;
	import units.NewInvader;
	/**
	 * ...
	 * @author ...
	 */
	public class InvadersManager 
	{
		private static var invaders:Array = [];
		
		public static function Start ():void {
			return;
			if (App.data.hasOwnProperty('invaders')) {
				for (var index:* in App.data.invaders)
				{
					if (App.data.invaders[index].hasOwnProperty('settings') && App.data.invaders[index].settings)
					{
						invaders.push(App.data.invaders[index]);
						
						tryToPlace(App.data.invaders[index]);
					}
				}
			}
		}
		
		public static function tryToPlace(object:Object):void {
			if (!checkAllOptions(object)) return;
			
			var onMap:Array = Map.findUnits([object.SIDs]);
			var _sid:int = 0;
			var find:Boolean = false;
						
			for ( var i:int = onMap.length; i < object.count; i++) {
				
				onMap = Map.findUnits(object.SIDs);
				
				// Выбор сундука которого еще нет на карте или последнего из списка
				if (object.hasOwnProperty("uniq") && object.uniq) {
					var sidsOutOfMap:Object = { };
					var allSidsToUse:Array = [];
					for each(var sd:* in object.SIDs) {
						allSidsToUse.push(int(sd));
					}
					for (var j:int = 0; j < object.SIDs.length; j++) {
						find = false;
						for (var k:int = 0; k < onMap.length; k++) {
							if (!sidsOutOfMap.hasOwnProperty(onMap[k].sid)) {
								sidsOutOfMap[onMap[k].sid] = 0;
							}
							sidsOutOfMap[onMap[k].sid]++;
							if (sidsOutOfMap[onMap[k].sid] >= object.uniq) {
								if(allSidsToUse.indexOf(onMap[k].sid) != -1)
									allSidsToUse.splice(allSidsToUse.indexOf(onMap[k].sid),1);
							}
						}
					}
					_sid = allSidsToUse[int(Math.random()*(allSidsToUse.length-0.1))]
				}else {
					_sid = object.SIDs[int(Math.random() * object.SIDs.length) ];
				}
				
				//TODO: реализовать подмену инвейдера
				//_sid = podmenaInvaders(_sid);
				
				var invader: NewInvader = new NewInvader({
					sid:			_sid,
					x:				(object.coords[object.mIDs.indexOf(App.map.id)])?object.coords[object.mIDs.indexOf(App.map.id)].x : 0,
					z:				(object.coords[object.mIDs.indexOf(App.map.id)])?object.coords[object.mIDs.indexOf(App.map.id)].z : 0,
					spawnable:		object.spawnable,
					radius:			object.radius,
					onAllMap: 		object.onAllMap,
					hasEvent:		object.hasEvent,
					id:				Map.findUnits(object.SIDs).length + 1,
					purchaseable:	object.buy,
					hasWalk:		object.moveable,
					velocity:		object.velocity,
					settingsOn:		true,
					SIDs:			object.SIDs,
					shake:			object.shake,
					rweapon:		object.rweapon,
					flying:			object.flying
				});
				
				App.map.sorted.push(invader);
				
				if (object.buy)
					invader.buyAction();
			}
			
			App.map.allSorting();	
		}
		
		public static function checkAllOptions(object:Object):Boolean {
			
			if (!checkLands(object.settings))
				return false;
			if (!checkSpawnQuest(object.settings))
				return false;
			if (!checkRemoveQuest(object.settings))
				return false;
			//if (!checkSoc(object.settings))
				//return false;
			if (!checkHome(object.settings))
				return false;
			if (!checkLevel(object))
				return false;
				
			return true;
		}
		
		private static function checkHome(options:Object):Boolean
		{
			if (options.hasOwnProperty ("home") && options.home) { 
				var onMap:Array = Map.findUnits([options.home]);
				
				for (var index:* in onMap)
				{
					if ((onMap[index] is Building) && (onMap[index] as Building).hasBuilded)
						return true;
				}
			}
			
			return false;
		}
		
		private static function checkSoc(options:Object):Boolean
		{
			if (options.hasOwnProperty ("networks") && options.networks && options.networks.length > 0 ) { 
				
				for each ( var soc:* in options.networks)
					if (App.isSocial (soc))
						return true;
			}
			
			return false;
		}
		
		private static function checkLevel(object:Object):Boolean
		{
			if (object.hasOwnProperty ("devel") && object.devel) { 
				
				for each ( var req:* in object.devel.req)
				{
					if (req.lfrom <= App.user.level && req.lto >= App.user.level)
						return true;
				}
			}
			
			return false;
		}
		
		private static function checkSpawnQuest(options:Object):Boolean
		{
			if (options.hasOwnProperty('sQIDs') && options.sQIDs.length > 0 )
				return chekQuest(options.sQIDs, true);
			
			return false;
		}
		private static function checkRemoveQuest(options:Object):Boolean
		{
			if (options.hasOwnProperty('rQIDs') && options.rQIDs && options.rQIDs.length > 0)
			{					
				for (var index:* in options.rQIDs)
				{
					if (App.user.quests.data.hasOwnProperty(options.rQIDs[index]))
						if (App.user.quests.data[options.rQIDs[index]].finished != 0)
							return false;
				}
			}
			
			return true;
		}
		private static function checkLands(options:Object):Boolean
		{
			if (options.hasOwnProperty('lands') && options.lands && options.lands.length > 0 )
			{
				for each( var wID:Object in options.lands )
					if (App.map.id == wID)
						return true;
			}
			
			return false;
		}
		
		public static function chekQuest(_qIDs:Array, hasFinish:Boolean = false):Boolean {
			var _start:Boolean = false;
			for each (var _qID:Object in _qIDs){
				if (App.user.quests.data.hasOwnProperty(_qID)) {
					if (!hasFinish && App.user.quests.data[_qID].finished != 0)
						continue;
					var quest:Object = App.data.quests[_qID];
					if (quest.dream && quest.dream != ''){
						for each(var dream:* in quest.dream) {
							if (dream == App.user.worldID) {
									_start = true;
								break;
							}	
						}	
					}
				}
			}
			return _start;
		}
		
		public static function checkSpawnOptions(option:InvaderOption = null):void
		{
			switch(option)
			{
				case InvaderOption.ALL: break;
				case InvaderOption.QUEST: break;
				default:break;
			}
		}
	}
}


class InvaderOption
{
	// Ссылка на единственный экземпляр класса.
	public static const ALL : InvaderOption = new InvaderOption("all");
	public static const QUEST: InvaderOption = new InvaderOption("quest");

	private static var _enumCreated:Boolean = false;
	{
		_enumCreated = true;
	}

	private var _optionName : String;
	
	public function InvaderOption(optionName : String)
	{
		if (_enumCreated)
			throw new Error("The enum is already created.");
		_optionName = optionName;
	}
}