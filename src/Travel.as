package 
{
	import api.ExternalApi;
	import core.Load;
	import flash.events.MouseEvent;
	import flash.utils.setTimeout;
	import ui.Cursor;
	import ui.SystemPanel;
	import ui.UserInterface;
	import units.Mhelper;
	import units.Personage;
	import units.Techno;
	import units.Unit;
	import wins.InformWindow;
	import wins.ShopWindow;
	import wins.StockWindow;
	import wins.VisitWindow;
	import wins.Window;
	import wins.WindowEvent;
	
	/**
	 * ...
	 * @author 
	 */
	public class Travel 
	{
		//territories
		public static const LAKE:int 					= 418;
		public static const ROCK:int 					= 535;
		public static const KLIDE_HOUSE:int 			= 555;
		public static const MOUNTAINS:int 				= 641;
		public static const RIVER:int 					= 767;
		public static const COAST:int 					= 903;
		public static const ARCHEOLOGICAL_ISLAND:int 	= 932;
		public static const MOUNTAIN_PASS:int 			= 1122;
		public static const CAVE:int 					= 1198;
		public static const VALLEY:int 					= 1371;
		public static const TOWN:int 					= 1569;
		public static const BANDITS_CANYON:int 			= 1801;
		public static const JOHNTOWN:int 				= 1907;
		public static const LOST_ISLANDS:int 			= 2099;
		public static const LOST_PYRAMIDS:int 			= 2195;
		public static const SAN_MANSANO:int 			= 2501;
		public static const DEEP_JOUNGLE:int 			= 2673;
		public static const GOLD_PROSPECTOR_TOWN:int 	= 2813;
		public static const WHITE_HILLS:int 			= 2897;
		public static const MOUNTAINS_NEW:int 			= 3060;
		private static var visitWindow:VisitWindow;
		
		public static var openShop:Object;
		public static var findMaterialSource:int = 0;
		
		public static function goHome(visitWorld:int = 0):void {
			
			ownerWorldID = visitWorld || User.HOME_WORLD;
			
			App.user.onStopEvent();
			App.ui.mode = UserInterface.NONE;
			App.ui.upPanel.worldPanel.hide();
			visitWindow = new VisitWindow({title:Locale.__e("flash:1382952379776")});
			visitWindow.addEventListener(WindowEvent.ON_AFTER_OPEN, loadHome);
			visitWindow.show();
		}
		private static function clearWorlds():void {
			if (App.owner) {
				App.owner.world.dispose();
				App.owner = null;
			}
			if (App.map) {
				App.map.dispose();
				App.map = null;
			}
			
		}
		private static function loadHome(e:WindowEvent):void {
			visitWindow.removeEventListener(WindowEvent.ON_AFTER_OPEN, loadHome);
			App.self.addEventListener(AppEvent.ON_USER_COMPLETE, onHomeComplete);
			App.user.goHome(ownerWorldID);
			App.ui.mode = UserInterface.OWNER;
		}
		private static function onHomeComplete(e:AppEvent):void {
			App.self.removeEventListener(AppEvent.ON_USER_COMPLETE, onHomeComplete);
			clearWorlds();
			
			App.self.addEventListener(AppEvent.ON_MAP_COMPLETE, onMapComplete);
			App.user.mode = User.OWNER;
			
			App.ui.eventIconCheck();
			if (App.ui.bottomPanel.friendsPanel.inviteBttn)
				App.ui.bottomPanel.friendsPanel.inviteBttn.visible = true;
			
			App.map = new Map(App.user.worldID, App.user.units, false);
			App.map.load();
			
			App.ui.leftPanel.questsPanel.change();
		}
		
		private static function onMapComplete(e:AppEvent):void {
			App.self.removeEventListener(AppEvent.ON_MAP_COMPLETE, onMapComplete);
			App.ui.checkExpedition();
			App.user.addPersonag();
			
			App.map.scaleX = App.map.scaleY = SystemPanel.scaleValue;
			App.map.center();
			
			if (visitWindow != null) {
				visitWindow.close();
				visitWindow = null;
			}
			
			if (App.user.mode == User.OWNER) {
				setTimeout(App.user.quests.scoreOpened, 1000);
			}
		}
		
		public static var friend:Object;
		private static var visitAsMyWorld:Boolean;
		public static function onVisitEvent(visitWorld:int, visitAsMyWorld:Boolean = false):void {
			Cursor.type = 'default';
			if (Quests.lockButtons) {
				Quests.lockButtons = false;
				return;
			}
			
			if (App.owner != null && friend.uid == App.owner.id && App.owner.worldID == visitWorld) return;
			
			Travel.visitAsMyWorld = visitAsMyWorld;
			ownerWorldID = visitWorld;
			App.user.onStopEvent();
			
			currentFriend = friend;
			friend['visited'] = App.time;
			App.ui.mode = UserInterface.NONE;
			
			if (visitWindow) {
				loadOwner(new WindowEvent(WindowEvent.ON_AFTER_OPEN));
			}else{
				visitWindow = new VisitWindow();
				visitWindow.addEventListener(WindowEvent.ON_AFTER_OPEN, loadOwner);
				visitWindow.show();
			}
			
			//Делаем push в _6e
			if (App.social == 'FB') {
				ExternalApi.og('visit','friend');
			}
			
		}
		
		private static var startTime:uint;
		private static var finishTime:uint;
		public static var ownerWorldID:int;
		public static var currentFriend:Object = null;
		private static function loadOwner(e:WindowEvent):void 
		{
			visitWindow.removeEventListener(WindowEvent.ON_AFTER_OPEN, loadOwner);
			
			if (!App.owner || !App.owner.worlds.hasOwnProperty(ownerWorldID)) {
				ownerWorldID = User.HOME_WORLD;
			}
			
			App.self.addEventListener(AppEvent.ON_OWNER_COMPLETE, onOwnerComplete);
			App.owner = new Owner(friend, ownerWorldID);
			App.ui.mode = UserInterface.GUEST;
			friend = null;
		}
		
		private static function onOwnerComplete(e:AppEvent):void 
		{ 
			App.self.removeEventListener(AppEvent.ON_OWNER_COMPLETE, onOwnerComplete);
			
			if (Travel.visitAsMyWorld && App.owner.worldID != App.user.worldID && App.owner.worlds.hasOwnProperty(App.user.worldID)) {
				Travel.visitAsMyWorld = false;
				Travel.friend = Travel.currentFriend;
				Travel.onVisitEvent(App.user.worldID);
				return;
			}
			
			App.map.dispose();
			App.user.world.dispose();
			App.map = null;
			
			App.self.addEventListener(AppEvent.ON_MAP_COMPLETE, onMapComplete);
			
			App.user.mode = User.GUEST;
			App.ui.eventIconRemove();
			if (App.ui.bottomPanel.friendsPanel.inviteBttn)
				App.ui.bottomPanel.friendsPanel.inviteBttn.visible = false;
			App.map = new Map(App.owner.worldID, App.owner.units, false);
			App.map.load();
		}
		
		public function Travel() {
			
		}
		
		public static var ableWorlds:Object = { };
		public static function addAbleWorld(sID:*):void {
			if (App.data.storage.hasOwnProperty(sID) && !ableWorlds.hasOwnProperty(sID)) {
				ableWorlds[sID] = sID;
			}
		}
		
		private static var worldID:int;
		public static function goTo(_worldID:uint):void {
			if (Mhelper.waitForTarget) {
				Mhelper.waitForTarget = false;
				Mhelper.waitWorker.unselectPossibleTargets();
			}
			
			if (worldID == Travel.MOUNTAIN_PASS) {
				if (App.user.personages.length > 1) {
					App.user.personages.pop();
				}
			}
			
			worldID = _worldID;
			App.user.onStopEvent();
			Load.clearLoad();
			
			if (_worldID == Travel.KLIDE_HOUSE || App.user.worldID == Travel.KLIDE_HOUSE) visitWindow = new VisitWindow( {
				title:Locale.__e('flash:1382952380050',[App.data.storage[worldID].title]),
				background:'travelPicDoor'
				});
			else visitWindow = new VisitWindow({title:Locale.__e('flash:1382952380050',[App.data.storage[worldID].title])});
			visitWindow.addEventListener(WindowEvent.ON_AFTER_OPEN, _onLoadUser);
			visitWindow.show();	
			
			if (App.user.worldID == Travel.KLIDE_HOUSE) App.ui.bottomPanel.showHomeButton(false);
			if (_worldID == Travel.KLIDE_HOUSE) setTimeout(App.ui.bottomPanel.showHomeButton, 1000);
		}
		
		private static function _onLoadUser(e:WindowEvent):void {
			visitWindow.removeEventListener(WindowEvent.ON_AFTER_OPEN, _onLoadUser);
			
			App.self.addEventListener(AppEvent.ON_USER_COMPLETE, _onUserComplete);
			App.user.world.dispose();
			App.user.dreamEvent(worldID);
			
			if (App.user.worldID != User.HOME_WORLD && StockWindow.needToOpen != 0) {
				new StockWindow().show();
			}
		}
		
		private static function _onUserComplete(e:AppEvent):void {
			App.self.removeEventListener(AppEvent.ON_USER_COMPLETE, _onUserComplete);
			App.map.dispose();
			App.map = null;
			App.self.addEventListener(AppEvent.ON_MAP_COMPLETE, _onMapComplete);
			
			App.user.mode = User.OWNER;
			App.ui.eventIconCheck();
			App.map = new Map(App.user.worldID, App.user.units, false);
			App.map.load();
		}
		
		private static function _onMapComplete(e:AppEvent):void {
			App.self.removeEventListener(AppEvent.ON_MAP_COMPLETE, _onMapComplete);
			
			if(visitWindow != null){
				visitWindow.close();
				visitWindow = null;
			}
			
			
			App.ui.checkExpedition();
			App.user.addPersonag();
			App.map.scaleX = App.map.scaleY = SystemPanel.scaleValue;
			if (App.user.worldID == Travel.KLIDE_HOUSE) App.map.scaleX = App.map.scaleY = 1;
			App.map.center();
			
			InformWindow.checkTownInform();
			
			App.user.quests.scoreOpened();
			App.ui.leftPanel.questsPanel.change();
			App.self.dispatchEvent(new AppEvent(AppEvent.ON_GAME_COMPLETE));
			
		}
	}
}