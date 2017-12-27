package 
{
	import flash.display.Sprite;
	import flash.system.Security;
	import flash.display.BitmapData;
	
	public class map14 extends Sprite 
	{
		Security.allowDomain("*");
		Security.allowInsecureDomain("*");
		
		
		[Embed(source="sprites/map_town.jpg", mimeType="image/jpeg")]
		private var Tile:Class;
		public var tile:BitmapData = new Tile().bitmapData
		
		
		public var assetZones:Object = {
			1:113,
			2:1915,
			3:1916
		};
		
		
		
		
		
		public var id:uint = 0;
		public var gridDelta:int = 5600;
		public var isoCells:uint = 280;
		public var isoRows:uint = 280;
		public var mapWidth:uint = 11014;
		public var mapHeight:uint = 5508;
		
		public var tileDX:int = 2633;
		public var tileDY:int = 380;
		public var type:String = 'image';
		public var bgColor:uint = 0xaed2f5;
		
		public var heroPosition:Object = {x:163, z:258};
		
		public var zones:Object = {
		};

		
		public function map14():void
		{
		
		}
	}
}