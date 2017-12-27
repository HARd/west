package units 
{
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	/**
	 * ...
	 * @author ...
	 */
	public class ThiefGoldenManager
	{
		static private var timerID:uint;
		static private var timerID2:uint;
		static private var thiefsList:Array;
		static private var thiefsToRemoveList:Array = [];
		static private var inited:Boolean = false;
		
		public static function Start ():void {
			clearTimeout(timerID);
			if (App.data.options.hasOwnProperty('ThiefGoldenList')) {
				try {
					thiefsList = JSON.parse(App.data.options.ThiefGoldenList) as Array;
					//qIDs = [];
					for each (var thiefs:Object in thiefsList  ) {
						//for each(var qid:int in thief.QIDs)
							//qIDs.push(qid);
						
						init (thiefs); 
					}
				}catch(e:*) {}
			}
		}
		
		public static function init(object:Object):void {
			/////////////
			//if (App.self.flashVars.currentSocial != 'DM')
				//return;
			//var onMap2:Array = Map.findUnits(object.SIDs);
			//
			//for (var s:int = 0; s < onMap2.length; s++)
			//{
				//(onMap2[s] as Walkgolden).removable = true;
				//(onMap2[s] as Walkgolden).remove();
				//(onMap2[s] as Walkgolden).removable = false;
				//(onMap2[s] as Walkgolden).isThief = false;
			//}
			//return;
			/////////////////////
			if (!checkAllSets(object)) return;
			
			var onMap:Array = Map.findUnits(object.SIDs);
			var _sid:int = 0;
			var find:Boolean = false;
			var instance:Walkgolden;	
			for (var j:int = 0; j < onMap.length; j++)
			{
				instance = (onMap[j] as Walkgolden);
				instance.isThief = true;
				if (instance.coords.x == 0 || instance.coords.z == 0)
				{
					instance.coords.x = 37;
					instance.coords.z = 117;
					
					instance.moveAction();
				}
			}
			
			if (onMap.length > 0)
			{
				instance = (onMap[onMap.length-1] as Walkgolden);
				instance.isThief = true;
				if (!inited)
				{
					//время без воров, отсчет со времени смерти последнего заспавненого вора
					var t:int = App.time - instance.creationTime - object.duration;
					
					//сколько воров должны были отработать за это время
					var c:int = Math.floor(t / object.duration);
					
					if (c > 0)
					{
						spawnAndRemoveThief(c, instance.sid);
					}
				}
				
			}
			
			inited = true;
			
			for ( var i:int = onMap.length; i < object.count; i++) {
				//TODO::check material count
				onMap = Map.findUnits(object.SIDs);
				
				_sid = object.SIDs[int(Math.random() * object.SIDs.length) ];
				
				var rX:int;
				var rZ:int;
				var findFreePos:Boolean = false;
				
				// Ищем свободную ячейку.
				do
				{
					rX = int( Math.random() * Map.cells );
					rZ = int( Math.random() * Map.rows );
					
					if (Invader.checkFreeNode(rX, rZ, {sid:_sid})){
						findFreePos = true;
					}
					
				}
				while (!findFreePos)
				
				createThief({
					crafted:App.time,
					sid:			_sid,
					x:				rX,//(object.coords[object.mIDs.indexOf(App.map.id)])?object.coords[object.mIDs.indexOf(App.map.id)].x : 0,
					z:				rZ,//(object.coords[object.mIDs.indexOf(App.map.id)])?object.coords[object.mIDs.indexOf(App.map.id)].z : 0,
					id:				0
				});
			}
			
			App.map.allSorting();
		}
		
		static private function spawnAndRemoveThief(c:int, sid:*):void 
		{
			var timeToWait:int = 2000;
			while (c > 0)
			{
				var obj:Object = Storage.price(sid);
				
				if (!App.user.stock.checkAll(obj, false, false))
					break;
				
				var thief:Walkgolden = createThief({
					crafted:App.time,
					sid:			sid,
					x:				0,//(object.coords[object.mIDs.indexOf(App.map.id)])?object.coords[object.mIDs.indexOf(App.map.id)].x : 0,
					z:				0,//(object.coords[object.mIDs.indexOf(App.map.id)])?object.coords[object.mIDs.indexOf(App.map.id)].z : 0,
					id:				0
				});
				thiefsToRemoveList.push(thief);
				
				thief.shouldBeRemoved = true;
				
				timeToWait += 2000;
				c--;
			}
			
			App.map.allSorting();
			
			//timerID2 = setTimeout(removeThiefs, timeToWait);
		}
		
		private static function removeThiefs():void
		{
			for (var index:* in thiefsToRemoveList)
			{
				var thief:Walkgolden = (thiefsToRemoveList[index] as Walkgolden);
				thief.removable = true;
				thief.remove();
				thief.removable = false;
				thief.isThief = false;
			}
			
			clearTimeout(timerID2);
		}
		
		public static function createThief(settings:Object):Walkgolden
		{
			var thief: Walkgolden = new Walkgolden(settings);
				
			App.map.sorted.push(thief);
			
			var obj:Object = Storage.price(thief.sid);
			
			//если WalkGolden и вор то для него не ищем, иначе
			var serachEnabled:Boolean = false;
			
			if (App.user.stock.checkAll(obj, false, serachEnabled))
			{
				for (var topID:* in App.user.top)
				{
					for (var sid:* in obj)
					{
						if (App.data.top.hasOwnProperty(topID) && App.data.top[topID].target == sid)
						{
							if(App.user.top[topID].count)
								App.user.top[topID].count = int(App.user.top[topID].count) - int(obj[sid]);
								
							App.user.top[topID].count = (int(App.user.top[topID].count) < 0)?0:int(App.user.top[topID].count);
						}
					}
				}
			}
			
			thief.buyAction();
			
			return thief;
		}
		
		private static function checkAllSets(object:Object):Boolean { // выполняем проверку можем ли мы добавить нового вора // true - создаем	
			var flag:Boolean = true;
			var check:Boolean = false;
			if (object.hasOwnProperty('QIDs') && object.QIDs.length > 0 )
				flag = checkQuest(object.QIDs);
			if (object.hasOwnProperty('home') && object.home.length > 0 ) {
				var _units:Array = Map.findUnits(object.home);
					if ( !(_units.length > 0 && _units[0].level < _units[0].totalLevels) )
						flag = checkQuest(object.QIDs);
					else
						flag = true;
			}
			if ( object.hasOwnProperty('sQIDs') && object.sQIDs.length > 0 )
				flag = checkQuest(object.sQIDs,true);
			if (object.hasEvent) {
				if (Events.timeOfComplete < App.time)
					flag = false;
			}

			if ( object.mIDs && object.mIDs.length > 0 )
			{
				check = false;
				for each( var _mID:Object in object.mIDs )
					if (App.map.id == _mID)
						check =  true;
				flag = (check)?flag:false;
			}
			if (object.soc.indexOf ("ALL") == -1) { 
				if (object.soc.length == 0){
					flag = false;
				}else {
					check = false;
					for each ( var soc:String in object.soc)
						if (App.isSocial (soc))
							check = true;
					flag = (check)?flag:false;
				}
			}
			if (object.hasOwnProperty('mxlvlU')) // Достиг ли обьет необходимого уровня
			{
				var maxLvl:Object = App.user.storageRead('mxlvlU', null);
				if (!maxLvl || !maxLvl.hasOwnProperty(object.mxlvlU))
					flag = false;
			}
			
			if (object.hasOwnProperty('rQIDs') && object.rQIDs && object.rQIDs.length > 0)
			{					
				for (var index:* in object.rQIDs)
				{
					if (App.user.quests.data.hasOwnProperty(object.rQIDs[index]))
						if (App.user.quests.data[object.rQIDs[index]].finished != 0)
							flag = false;
				}
			}
			
			return flag;
		}
		
		private static function checkQuest(_qIDs:Array, hasFinish:Boolean = false):Boolean {
			var _start:Boolean = true;
			
			return _start;
		}
		
		public static function isThief(sid:*):Boolean
		{
			for each (var thiefs:Object in thiefsList) {
				for each (var thiefSid:* in thiefs.SIDs) {
					if (sid == thiefSid)
						return true;
				}
			}
			
			return false;
		}
		
		public static function checkExpire(instance:Walkgolden):void
		{
			var thiefData:Object = getThiefData(instance.sid);
			
			if ((instance.creationTime + int(thiefData.duration) <= App.time || instance.capacity == App.data.storage[instance.sid].capacity) && instance.visible && instance.id != 0)
			{
				instance.visible = false;
				instance.open = false;
				instance.clickable = false;
				instance.touchable = false;
				instance.clearIcon();
			}
			
			if (instance.creationTime + int(thiefData.respawn) <= App.time && instance.id != 0)
			{
				instance.removable = true;
				instance.remove();
				instance.removable = false;
				instance.isThief = false;
			}
		}
		
		public static function getThiefData(sid:*):Object
		{
			for each (var thiefs:Object in thiefsList) {
				for each (var thiefSid:* in thiefs.SIDs) {
					if (sid == thiefSid)
					{
						return thiefs;
					}
				}
			}
			
			return null;
		}
		
		public static function checkAndSpawnDelayed():void
		{
			timerID = setTimeout(Start, 2000);
		}
		
		public static function onTakeBonuse(instance:Walkgolden):void
		{
			if (instance.visible && instance.id != 0)
			{
				instance.visible = false;
				instance.open = false;
				instance.clickable = false;
				instance.touchable = false;
			}
		}
	}

}