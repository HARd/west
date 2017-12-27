package 
{
	import flash.display.Sprite;
	import flash.system.Security;
	import flash.display.BitmapData;
	
	public class map10 extends Sprite 
	{
		Security.allowDomain("*");
		Security.allowInsecureDomain("*");
		
		
		[Embed(source="sprites/tile.jpg", mimeType="image/jpeg")]
		private var Tile:Class;
		public var tile:BitmapData = new Tile().bitmapData
		
		
		public var assetZones:Object = {
			1:	113,
			2:	1196
		};
		
		
		
		public var elements:Array = [
					];
		
		public var id:uint = 0;
		public var gridDelta:int = 4132;
		public var isoCells:uint = 210;
		public var isoRows:uint = 210;
		public var mapWidth:uint = 8264;
		public var mapHeight:uint = 4132;
		
		public var tileDX:int = 950;
		public var tileDY:int = -300;
		public var type:String = 'image';
		public var bgColor:uint = 0x000000;		
		public var heroPosition:Object = { x:165, z:194 }
		public var zones:Object = {
			
		}
		
		public function map10():void
		{
		
		}
	}
}