package wins.newFreebie 
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	/**
	 * ...
	 * @author ...
	 */
	public class NewFreebieModel extends EventDispatcher
	{	
		private static var _instance:NewFreebieModel;
		
		public static const NEW_FREEBIE_START_DATA:int = 1453939200;
		
		static public function get instance():NewFreebieModel 
		{
			if (!_instance)
			{
				_instance = new NewFreebieModel(new Initializer());
			}
			
			return _instance;
		}
		
		
		
		private var _invitedFriends:Object;
		private var _availableFreebies:Vector.<BountyForLevel>;
		
		public function NewFreebieModel(initializer:Initializer)
		{
			
		}
		
		
		public function get sentInvites():Array
		{
			var invitesData:Object = App.user.socInvitesFrs;
			var invitesArray:Array = [];
			
			for each (var inviteData:Object in invitesData) 
			{
				invitesArray.push(inviteData);
			}
			
			return invitesArray;
		}
		
		public function numInvitedFriendsOverLevel(level:int):int
		{
			var result:int = 0;
			
			for (var key:String in invitedFriends)
			{
				if (App.user.friends.data 
				&& App.user.friends.data.hasOwnProperty(key) 
				&& App.user.friends.data[key].level >= level
				&& invitedFriends[key] == 1
				&& App.user.friends.data[key].createtime >= NEW_FREEBIE_START_DATA)
					result++
			}
			
			return result;
		}
		
		
		public function get availableFreebies():Vector.<BountyForLevel>
		{
			if (!_availableFreebies)
			{
				_availableFreebies = new Vector.<BountyForLevel>();
				var freebies:Object = App.data.bounty;				
				
				var currentFreebieObj:Object;
				for (var key:String in freebies) 
				{
					currentFreebieObj = freebies[key];
					currentFreebieObj["sid"] = key;
					
					_availableFreebies.push(new BountyForLevel(currentFreebieObj));
				}
			}
			
			return _availableFreebies
		}
		
		public function get isNewFreebieAvailable():Boolean
		{
			var result:Boolean = false;
			var takenBounties:Object = App.user.bounty;
			var currentFreebieData:BountyForLevel;
			
			for (var i:int = 0; i < availableFreebies.length; i++) 
			{
				currentFreebieData = availableFreebies[i];
				for (var key:String in currentFreebieData.itemsForUsers)
				{					
					if (!isBountyTaken(currentFreebieData.level, int(key)))
					{
						result = true;
						break;
					}
				}
				
				if (result)
					break;
			}
			
			return result;
		}
		
		public function isBountyTaken(level:int, friendsCount:int):Boolean
		{
			var result:Boolean = false;
			var takenBounties:Object = App.user.bounty;
			
			if (takenBounties && takenBounties.hasOwnProperty(String(level)) && takenBounties[level].hasOwnProperty(String(friendsCount)) && takenBounties[level][friendsCount] == 1)
			{
				result = true;
			}
			
			return result;
		}
		
		public function setTakenBounty(level:int, friendsCount:int):void
		{			
			if (!App.user.bounty)
				App.user.bounty = { };
				
			if (!App.user.bounty[level])
				App.user.bounty[level] = { };
				
			App.user.bounty[level][friendsCount] = 1;
			
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		public function get invitedFriends():Object 
		{
			if (!_invitedFriends)
				_invitedFriends = App.user.socInvitesFrs;
				
			return _invitedFriends;
		}
	}
}

internal class Initializer
{
	public function Initializer()
	{}
	
}