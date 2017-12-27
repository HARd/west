package wins.newFreebie 
{
	import flash.utils.Dictionary;
	/**
	 * ...
	 * @author ...
	 */
	public class BountyForLevel 
	{
		private var _bountyName:String;
		private var _sid:String;
		private var _bountyID:String;
		private var _level:int;
		private var _itemsForUsers:Dictionary;
		private var _maxUsers:int = 0;
		private var _numSteps:int;
		
		public function BountyForLevel(data:Object) 
		{
			_bountyID = data.ID;
			_level = data.level;
			_bountyName = data.name;
			_sid = data.sid;
			
			_itemsForUsers = new Dictionary();
			for (var key:String in data.items)
			{
				_itemsForUsers[int(key)] = data.items[key];
				
				if (int(key) > _maxUsers)
					_maxUsers = int(key);
					
				_numSteps++;
			}
		}
		
		public function get bountyID():String 
		{
			return _bountyID;
		}
		
		public function get level():int 
		{
			return _level;
		}
		
		public function get itemsForUsers():Dictionary 
		{
			return _itemsForUsers;
		}
		
		public function get bountyName():String 
		{
			return _bountyName;
		}
		
		public function get maxUsers():int 
		{
			return _maxUsers;
		}
		
		public function get numSteps():int 
		{
			return _numSteps;
		}
		
		public function get sid():String 
		{
			return _sid;
		}
	}
}