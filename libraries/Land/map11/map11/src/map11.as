package 
{
	import flash.display.Sprite;
	import flash.system.Security;
	import flash.display.BitmapData;
	
	public class map11 extends Sprite 
	{
		Security.allowDomain("*");
		Security.allowInsecureDomain("*");
		
		
		[Embed(source="sprites/tile.jpg", mimeType="image/jpeg")]
		private var Tile:Class;
		public var tile:BitmapData = new Tile().bitmapData
		
		
		public var assetZones:Object = {
			1:	113,
			2:	1388
		};
		
		
		
		public var elements:Array = [
					];
		
		public var id:uint = 0;
		public var gridDelta:int = 4329;
		public var isoCells:uint = 190;
		public var isoRows:uint = 220;
		public var mapWidth:uint = 8067;
		public var mapHeight:uint = 4033;
		
		public var tileDX:int = 750;
		public var tileDY:int = 0;
		public var type:String = 'image';
		public var bgColor:uint = 0x000000;		
		public var heroPosition:Object = { x:18, z:167 }
		public var zones:Object = {
			
		}
		
		public function map11():void
		{
		
		}
	}
}