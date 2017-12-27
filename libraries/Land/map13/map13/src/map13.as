package 
{
	import flash.display.Sprite;
	import flash.system.Security;
	import flash.display.BitmapData;
	
	public class map13 extends Sprite 
	{
		Security.allowDomain("*");
		Security.allowInsecureDomain("*");
		
		
		[Embed(source="sprites/W_map_road0.jpg", mimeType="image/jpeg")]
		private var Tile:Class;
		public var tile:BitmapData = new Tile().bitmapData
		
		
		public var assetZones:Object = {
			6:1816,
			4:1814,
			5:1815,
			1:113,
			3:1813,
			2:1812
		};
		
		
		
		
		
		public var id:uint = 0;
		public var gridDelta:int = 5600;
		public var isoCells:uint = 220;
		public var isoRows:uint = 280;
		public var mapWidth:uint = 11014;
		public var mapHeight:uint = 4918;
		
		public var tileDX:int = 2177;
		public var tileDY:int = 235;
		public var type:String = 'image';
		public var bgColor:uint = 0x6c96bb;
		
		public var heroPosition:Object = {x:153, z:272};
		
		public var zones:Object = {
		};

		
		public function map13():void
		{
		
		}
	}
}