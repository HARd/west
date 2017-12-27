package 
{
	import flash.display.Sprite;
	import flash.system.Security;
	import flash.display.BitmapData;
	
	public class map17 extends Sprite 
	{
		Security.allowDomain("*");
		Security.allowInsecureDomain("*");
		
		
		[Embed(source="sprites/map17.jpg", mimeType="image/jpeg")]
		private var Tile:Class;
		public var tile:BitmapData = new Tile().bitmapData
		
		
		public var assetZones:Object = {
			4:2505,
			5:2506,
			2:2503,
			1:113,
			3:2504,
			6:2507
		};
		
		
		
		
		
		public var id:uint = 0;
		public var gridDelta:int = 5000;
		public var isoCells:uint = 250;
		public var isoRows:uint = 250;
		public var mapWidth:uint = 9834;
		public var mapHeight:uint = 4918;
		
		public var tileDX:int = 2427;
		public var tileDY:int = 144;
		public var type:String = 'image';
		public var bgColor:uint = 0x96bdfe;
		
		public var heroPosition:Object = {x:231, z:157};
		
		public var zones:Object = {

		};

		
		public function map17():void
		{
		
		}
	}
}