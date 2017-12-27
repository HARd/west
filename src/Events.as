package  
{
	import core.Post;
	import flash.utils.setTimeout;
	import wins.FiestaWindow;
	/**
	 * ...
	 * @author ...
	 */
	public class Events 
	{
		public static var timeOfComplete:int = 1480118400;
		public function Events()
		{
			
		}
		
		public static function init():void {
			try {
				var object:Object = JSON.parse(App.data.options['EventTimes']);
				if (object.hasOwnProperty(App.social)) {
					timeOfComplete = object[App.social];
				}else if (object.hasOwnProperty('ALL')) {
					timeOfComplete = object.ALL;
				}
			}catch(e:*) {}
		}
		
		public static function initEvents():void {
		 var eventManager:Object = JSON.parse(App.data.options['EventManager']);
			if (eventManager.timeFinish > App.time && App.user.quests.data[425]) {
				setTimeout(function():void {
					new FiestaWindow().show();
				}, 6000);
			}
		}
		
		public static function checkEvents():void {
			return;//
			var events:Object = App.data.gameevents;
			for (var eventID:* in events) {
				startEvent(eventID);
				return;
			}
		}
		
		public static var currentEvent:Object;
		private static function startEvent(eventID:int):void {
			currentEvent = App.data.gameevents[eventID];
			//openMap(currentEvent.world);
			//openMap(767);
		}
		
		public static function openMap(worldID:int, callback:Function = null):void {
			
			if (App.user.worlds.hasOwnProperty(worldID)) return;
			
			Post.send({
				ctr:'world',
				act:'open',
				uID:App.user.id,
				wID:worldID,
				buy:0
			},
			function(error:*, data:*, params:*):void {
				
				if (error) {
					Errors.show(error, data);
					return;
				}
				
				App.user.worlds[worldID] = worldID;
				if (callback != null) callback();
			});	
		}
	}
}