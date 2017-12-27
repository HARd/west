package wins.elements
{
	import core.Post;
	import wins.GiftWindow;
	import wins.elements.SearchPanel;

	/**
	 * ...
	 * @author ...
	 */
	public class SearchFriendsPanel extends SearchPanel 
	{
		
		public function SearchFriendsPanel(settings:Object) {
			
			super(settings);
			
		}
		
		override public function search(query:String = "", isCallBack:Boolean = true):Array {
			
			var wlFilter:Boolean = false;
			if (settings.win.hasOwnProperty('wishListFilter')) wlFilter = settings.win.wishListFilter;
			
			var freeFilter:Boolean = false;
			if (settings.win.settings.iconMode == GiftWindow.FREE_GIFTS) freeFilter = true;
			
			var friends:Array = [];
			var friend:Object;
			
			query = query.toLowerCase();
			var fid:String;
			
			// Пустая строка поиска
			if (query == "") {
				
				if (settings.win.settings.itemsMode == GiftWindow.ALLFRIENDS){
					for (fid in App.network.otherFriends) {
						friends.push(App.network.otherFriends[fid]);
					}
					friends.sortOn("uid");
				}else{
					for each(friend in App.user.friends.keys) {
						if (!friend.uid || friend.uid == "1") continue;
						
						if (friend.uid && !useFilters(friend.uid)) continue;
						friends.push(friend);
					}
					friends.sortOn(["level", "uid"]);
				}
			}else {
				
				if (settings.win.settings.itemsMode == GiftWindow.ALLFRIENDS){
					for (fid in App.network.otherFriends) {
						
						friend = App.network.otherFriends[fid];
						if (
							friend.first_name.toLowerCase().indexOf(query) == 0 ||
							friend.last_name.toLowerCase().indexOf(query) == 0 ||
							friend.uid.toString().toLowerCase().indexOf(query) == 0
						){
							friends.push(friend);
						}
					}
					friends.sortOn("uid");
				}else{
					for each(friend in App.user.friends.data) {
						
						if (!friend.uid || friend.uid == "1" || !useFilters(friend.uid)) continue;
						
						if (
							friend.aka.toLowerCase().indexOf(query) == 0 ||
							(friend.first_name && friend.first_name.toLowerCase().indexOf(query) == 0) ||
							(friend.last_name && friend.last_name.toLowerCase().indexOf(query) == 0) ||
							friend.uid.toString().toLowerCase().indexOf(query) == 0
						){
							friends.push(friend);
						}
					}
					friends.sortOn("level");
				}
			}
			// Передаем новый список друзей
			if(isCallBack)
				settings.callback(friends);
			
			// Проверяем подходит ли под условия фильтра
			function useFilters(_uid:String):Boolean
			{
				if (freeFilter && !Gifts.canTakeFreeGift(_uid)) return false;
				if (wlFilter)
				{
					var check:Boolean = false
					for each(var wItem:* in App.user.friends.data[_uid].wl) if (wItem == settings.win.icon.ID) check = true;
					if (!check) return false;
				}
				
				// фильтры пройдены
				return true;
			}
			return friends;
		}
	}
	
}