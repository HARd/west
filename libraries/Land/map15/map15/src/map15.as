package 
{
	import flash.display.Sprite;
	import flash.system.Security;
	import flash.display.BitmapData;
	
	public class map15 extends Sprite 
	{
		Security.allowDomain("*");
		Security.allowInsecureDomain("*");
		
		
		[Embed(source="sprites/map15.jpg", mimeType="image/jpeg")]
		private var Tile:Class;
		public var tile:BitmapData = new Tile().bitmapData
		
		
		public var assetZones:Object = {
			1:113,
			2:2130,
			3:2095,
			4:2096,
			5:2097,
			6:2098
		};
		
		
		
		
		
		public var id:uint = 0;
		public var gridDelta:int = 5800;
		public var isoCells:uint = 260;
		public var isoRows:uint = 290;
		public var mapWidth:uint = 11408;
		public var mapHeight:uint = 5409;
		
		public var tileDX:int = 2363;
		public var tileDY:int = 755;
		public var type:String = 'image';
		public var bgColor:uint = 0xb6ddff;
		
		public var heroPosition:Object = { x:50, z:175 };
		
		public var zoneResources:Object = {
			//id:zoneID
			  19:2
		};
		public var zoneZoners:Object = {
			//id:zoneID
			  1:3,
			  2:4,
			  3:5,
			  4:6
		};
		
		public var zones:Object = {
			2130: {
				points: [
					{ x: 130, z: 158 },
					{ x: 154, z: 168 },
					{ x: 185, z: 138 },
					{ x: 194, z: 90 },
					{ x: 143, z: 57 },
					{ x: 115, z: 77 },
					{ x: 113, z: 135 }
				],
				clouds: []
			},
			2095: {
				points: [
					{ x: 214, z: 226 },
					{ x: 241, z: 212 },
					{ x: 240, z: 169 },
					{ x: 206, z: 147 },
					{ x: 176, z: 166 },
					{ x: 185, z: 201 }
				],
				clouds: []
			},
			2096: {
				points: [
					{ x: 100, z: 240 },
					{ x: 134, z: 247 },
					{ x: 170, z: 197 },
					{ x: 161, z: 181 },
					{ x: 113, z: 157 },
					{ x: 80, z: 187 },
					{ x: 84, z: 231 }
				],
				clouds: []
			},
			2097: {
				points: [
					{ x: 149, z: 278 },
					{ x: 177, z: 293 },
					{ x: 212, z: 279 },
					{ x: 222, z: 259 },
					{ x: 214, z: 237 },
					{ x: 176, z: 229 },
					{ x: 148, z: 242 }
				],
				clouds: []
			}
		};

		
		public function map15():void
		{
		
		}
	}
}