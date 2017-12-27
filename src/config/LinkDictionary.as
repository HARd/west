package config 
{
	/**
	 * ...
	 * @author 
	 */
	public class LinkDictionary 
	{
		public static var LINK:Object = { };
		public static var serverID:int = 0;
		
		public static function takeUrl(type, name):String
		{
			return LINK[serverID][type][name];
		}
		
		public static function init(_serverID):void
		{
			serverID = _serverID;
			LINK["0"] = 
			{
				dreams: {
							dream1:"link",
							dream2:"link"
						}
			};
		}	