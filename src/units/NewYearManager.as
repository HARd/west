package units 
{
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import flash.geom.ColorTransform;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	/**
	 * ...
	 * @author ...
	 */
	public class NewYearManager
	{
		static private var timerID:uint;
		static private var newYearEventsList:Array;
		
		public static function Start ():void {
			if (App.data.options.hasOwnProperty('NewYearEvent')) {
				try {
					newYearEventsList = JSON.parse(App.data.options.NewYearEvent) as Array;
					//qIDs = [];
					for each (var newYearEvent:Object in newYearEventsList  ) {
						//for each(var qid:int in thief.QIDs)
							//qIDs.push(qid);
						
						init (newYearEvent); 
					}
				}catch(e:*) {}
			}
		}
		
		public static function init(object:Object):void {
			var onMap:Array = Map.findUnits(object.SIDs);
			var _sid:int = 0;
			var find:Boolean = false;
			var j:int = 0;
			var flag:Boolean = false;
			
			if (object.soc.length == 0){
				flag = false;
			}else {
				flag = false;
				for each ( var soc:String in object.soc)
					if (App.isSocial (soc))
						flag = true;
			}
			
			if (onMap.length > 0 && ((object.mIDs.indexOf(App.user.worldID) == -1) || !flag))
			{
				for (j = 0; j < onMap.length; j++)
				{
					(onMap[j] as Rbuilding).removeAnyway = true;
					(onMap[j] as Rbuilding).visible = false;
					(onMap[j] as Rbuilding).removable = true;
					(onMap[j] as Rbuilding).remove();
					(onMap[j] as Rbuilding).isNewYearBuilding = true;
				}
				
				return;
			}
			
			
			if (!checkAllSets(object)) return;
			onMap = Map.findUnits(object.SIDs);
			onMap.sortOn("level");
			//while ( > object.count)
			//{
				//
			//}
			for (j = 0; j < onMap.length - object.count; j++)
			{
				
				(onMap[j] as Rbuilding).removeAnyway = true;
				(onMap[j] as Rbuilding).visible = false;
				(onMap[j] as Rbuilding).isNewYearBuilding = true;
				(onMap[j] as Rbuilding).removable = true;
				(onMap[j] as Rbuilding).remove();
				(onMap[j] as Rbuilding).removable = false;
			}
			for (j = 0; j < onMap.length; j++)
			{
				//(onMap[j] as Rbuilding).visible = false;
				(onMap[j] as Rbuilding).isNewYearBuilding = true;
				//if (App.self.flashVars.currentSocial != 'DM')
				//{
					//(onMap[j] as Rbuilding).visible = false;
					//(onMap[j] as Rbuilding).removable = true;
					//(onMap[j] as Rbuilding).remove();
					//(onMap[j] as Rbuilding).isNewYearBuilding = true;
				//}
			}
			
			if (onMap.length >= object.count || Map.findUnits([object.bID]).length >= object.count)
				return;
				
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
					rX = int( Math.random() * Map.cells);
					rZ = int( Math.random() * Map.rows);
					
					if (Invader.checkFreeNode(rX, rZ, {sid:_sid})){
						findFreePos = true;
					}
					
				}
				while (!findFreePos)
				
				createNewYearBuilding( {
					sid:			_sid,
					x:				rX,//(object.coords[object.mIDs.indexOf(App.map.id)])?object.coords[object.mIDs.indexOf(App.map.id)].x : 0,
					z:				rZ,//(object.coords[object.mIDs.indexOf(App.map.id)])?object.coords[object.mIDs.indexOf(App.map.id)].z : 0,
					id:				0,
					req:			[],
					level:			0
				});
			}
			
			App.map.allSorting();
		}
		
		public static function createNewYearBuilding(settings:Object):Rbuilding
		{
			var eventBuilding: Rbuilding= new Rbuilding(settings);
			
			eventBuilding.isNewYearBuilding = true;
			App.map.sorted.push(eventBuilding);
			
			eventBuilding.buyAction();
			
			return eventBuilding;
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
			
			if ( object.mIDs && object.mIDs.length > 0 )
			{
				check = false;
				for each( var _mID:Object in object.mIDs )
					if (App.map.id == _mID)
						flag =  true;
					else
						flag = false;
				//flag = (check)?flag:false;
			}
			
			return flag;
		}
		
		private static function checkQuest(_qIDs:Array, hasFinish:Boolean = false):Boolean {
			return Invader.chekQuest(_qIDs, hasFinish);
		}
		
		public static function isNewYearBuilding(sid:*):Boolean
		{
			if (App.data.options.hasOwnProperty('NewYearEvent') && !newYearEventsList) {
				try {
					newYearEventsList = JSON.parse(App.data.options.NewYearEvent) as Array;
					//qIDs = [];
					for each (var newYearEvent:Object in newYearEventsList  ) {
						for each (var newYearBuildings:* in newYearEvent.SIDs) {
							if (sid == newYearBuildings)
								return true;
						}
					}
				}catch(e:*) {}
			}
			else
			{
				for each (var event:Object in newYearEventsList) {
					for each (var newYearBuildings2:* in event.SIDs) {
						if (sid == newYearBuildings2)
							return true;
					}
				}
			}
			return false;
		}
		
		public static function getNewYearBuildingData(sid:*):Object
		{
			for each (var event:Object in newYearEventsList) {
				for each (var buildingSid:* in event.SIDs) {
					if (sid == buildingSid)
					{
						return event;
					}
				}
			}
			
			return null;
		}
		
		private static var _instance:Rbuilding;
		
		public static function onTakeBonuse(instance:Rbuilding):void
		{
			_instance = instance;
			instance.level++;
			//instance.isNewYearBuilding = false;
			instance.updateLevel();
			damageShow();
			
			//instance.removable = true;
			//instance.remove();
			//instance.removable = false;
		}
		
		public static function spawnGolden(mainBuild:Rbuilding):void
		{
			var data:Object = getNewYearBuildingData(mainBuild.sid);
			
			var onMap:Array = Map.findUnits([data.bID]);
			var _sid:int = 0;
				
			//if (onMap.length > 0)
				//return;
				
			var golden: Buildgolden= new Buildgolden({
				id:0,
				sid:data.bID,
				level:0,
				x:mainBuild.coords.x,
				z:mainBuild.coords.z,
				crafted:App.time
			});
			golden.hasUpgraded = true;	
			golden.moveable = true;
			App.map.sorted.push(golden);
			
			golden.buyAction();
			
			App.map.allSorting();
		}
		
		/**
		 * Показывает затемнение
		 */
		private static var damageStep:int = 4;
		private static var damageValue:int = 0;
		private static var mvc:MovieClip = new MovieClip();
		public static function damageShow():void {
			timerID = setTimeout(startWhiteScreen, 5000);
			//mouse
			App.self.addEventListener(MouseEvent.CLICK, clickBlocker, false, 2147483647);
			App.self.addEventListener(MouseEvent.MOUSE_DOWN, clickBlocker, false, 2147483647);
			App.self.addEventListener(MouseEvent.MOUSE_UP, clickBlocker, false, 2147483647);
			App.self.addEventListener(MouseEvent.ROLL_OVER, clickBlocker, false, 2147483647);
			App.self.addEventListener(MouseEvent.ROLL_OUT, clickBlocker, false, 2147483647);
			App.self.addEventListener(MouseEvent.MOUSE_OVER, clickBlocker, false, 2147483647);
			App.self.addEventListener(MouseEvent.MOUSE_OUT, clickBlocker, false, 2147483647);
			App.self.addEventListener(MouseEvent.DOUBLE_CLICK, clickBlocker, false, 2147483647);
			App.self.addEventListener(MouseEvent.MOUSE_MOVE, clickBlocker, false, 2147483647);
		}
		
		private static function startWhiteScreen():void
		{
			clearTimeout(timerID);
			
			if (damageValue == 0)
				App.self.setOnEnterFrame(damageHandler);
			damageValue = 0;
			
			var shape:Shape = new Shape();
			shape.graphics.beginFill(0xFF0000, 0);
			shape.graphics.drawRect(0, 0, 1000, 1000);
			shape.graphics.endFill();
			
			var spr:Sprite = new Sprite();
			spr.graphics.copyFrom(shape.graphics);
			
			mvc.addChild(spr);
			mvc.width = 1000;
			mvc.height = 1000;
			App.self.addChild(mvc);
		}
		
		private static function clickBlocker(e:MouseEvent):void
		{
			e.cancelable;
			e.stopImmediatePropagation();
			e.stopPropagation();
		}
		
		private static function damageHandler(e:Event):void {
			if (damageValue < 0) {
				App.self.setOffEnterFrame(damageHandler);
				damageValue = 0;
				App.self.removeChild(mvc);
				App.self.removeEventListener(MouseEvent.CLICK, clickBlocker);
				App.self.removeEventListener(MouseEvent.MOUSE_DOWN, clickBlocker);
				App.self.removeEventListener(MouseEvent.MOUSE_UP, clickBlocker);
				App.self.removeEventListener(MouseEvent.ROLL_OVER, clickBlocker);
				App.self.removeEventListener(MouseEvent.ROLL_OUT, clickBlocker);
				App.self.removeEventListener(MouseEvent.MOUSE_OVER, clickBlocker);
				App.self.removeEventListener(MouseEvent.MOUSE_OUT, clickBlocker);
				App.self.removeEventListener(MouseEvent.DOUBLE_CLICK, clickBlocker);
				App.self.removeEventListener(MouseEvent.MOUSE_MOVE, clickBlocker);
				return;
			}
			else
			{
				if (damageValue >= 255)
				{
					damageValue = 255;
					damageStep = -2;
					spawnGolden(_instance);
					_instance.uninstall();
				}
			}
			damageValue += damageStep;
			
			if (!App.map || !App.ui) return;
			App.ui.transform.colorTransform = new ColorTransform(1, 1, 1, 1, damageValue,damageValue,damageValue);
			App.map.transform.colorTransform = new ColorTransform(1, 1, 1, 1, damageValue, damageValue, damageValue);
		}
	}

}