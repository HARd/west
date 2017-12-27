package 
{
	import flash.display.Sprite;
	import flash.system.Security;
	import flash.display.BitmapData;
	
	public class map16 extends Sprite 
	{
		Security.allowDomain("*");
		Security.allowInsecureDomain("*");
		
		
		[Embed(source="sprites/map16.jpg", mimeType="image/jpeg")]
		private var Tile:Class;
		public var tile:BitmapData = new Tile().bitmapData
		
		
		public var assetZones:Object = {
			1:113,
			10:2232,
			11:2233,
			12:2234,
			9:2231,
			8:2230,
			16:2238,
			6:2228,
			7:2229,
			15:2237,
			4:2226,
			13:2235,
			5:2227,
			2:2224,
			14:2236,
			3:2225
		};
		
		
		
		
		
		public var id:uint = 0;
		public var gridDelta:int = 4600;
		public var isoCells:uint = 230;
		public var isoRows:uint = 230;
		public var mapWidth:uint = 9048;
		public var mapHeight:uint = 4524;
		
		public var tileDX:int = 1401;
		public var tileDY:int = 791;
		public var type:String = 'image';
		public var bgColor:uint = 0x99cbff;
		
		public var heroPosition:Object = { x:142, z:198 };
		
		public var zoneResources:Object = {
			//id:zoneID
			  725:2,
			  724:3,
			  68:4,
			  713:5,
			  163:6,
			  376:7,
			  160:8,
			  217:9,
			  265:10,
			  368:11,
			  244:12,
			  266:13,
			  119:14,
			  128:15,
			  738:16
		};
		
		public var zones:Object = {
			2224: {
				points: [
					{ x: 105, z: 156 },
					{ x: 115, z: 165 },
					{ x: 125, z: 168 },
					{ x: 131, z: 161 },
					{ x: 131, z: 143 },
					{ x: 121, z: 134 },
					{ x: 113, z: 131 },
					{ x: 106, z: 132 },
					{ x: 102, z: 144 },
					{ x: 102, z: 153 }
				],
				clouds: []
			},
			2225: {
				points: [
					{ x: 131, z: 163 },
					{ x: 134, z: 170 },
					{ x: 141, z: 174 },
					{ x: 150, z: 179 },
					{ x: 160, z: 179 },
					{ x: 167, z: 172 },
					{ x: 168, z: 160 },
					{ x: 160, z: 146 },
					{ x: 150, z: 139 },
					{ x: 141, z: 138 },
					{ x: 131, z: 144 }
				],
				clouds: []
			},
			2226: {
				points: [
					{ x: 122, z: 135 },
					{ x: 131, z: 143 },
					{ x: 141, z: 138 },
					{ x: 150, z: 139 },
					{ x: 149, z: 127 },
					{ x: 140, z: 114 },
					{ x: 123, z: 101 },
					{ x: 117, z: 96 },
					{ x: 106, z: 96 },
					{ x: 101, z: 102 },
					{ x: 97, z: 109 },
					{ x: 99, z: 120 },
					{ x: 104, z: 128 },
					{ x: 106, z: 131 },
					{ x: 117, z: 131 }
				],
				clouds: []
			},
			2227: {
				points: [
					{ x: 169, z: 162 },
					{ x: 176, z: 166 },
					{ x: 193, z: 167 },
					{ x: 205, z: 160 },
					{ x: 202, z: 138 },
					{ x: 192, z: 127 },
					{ x: 178, z: 119 },
					{ x: 161, z: 119 },
					{ x: 155, z: 123 },
					{ x: 155, z: 128 },
					{ x: 150, z: 128 },
					{ x: 150, z: 139 },
					{ x: 160, z: 146 }
				],
				clouds: []
			},
			2228: {
				points: [
					{ x: 165, z: 118 },
					{ x: 165, z: 110 },
					{ x: 163, z: 100 },
					{ x: 152, z: 85 },
					{ x: 133, z: 71 },
					{ x: 123, z: 72 },
					{ x: 119, z: 80 },
					{ x: 119, z: 89 },
					{ x: 119, z: 96 },
					{ x: 123, z: 101 },
					{ x: 139, z: 113 },
					{ x: 149, z: 127 },
					{ x: 154, z: 127 },
					{ x: 154, z: 123 }
				],
				clouds: []
			},
			2229: {
				points: [
					{ x: 193, z: 128 },
					{ x: 200, z: 131 },
					{ x: 219, z: 129 },
					{ x: 220, z: 118 },
					{ x: 211, z: 110 },
					{ x: 183, z: 87 },
					{ x: 170, z: 93 },
					{ x: 165, z: 101 },
					{ x: 167, z: 118 },
					{ x: 178, z: 118 }
				],
				clouds: []
			},
			2230: {
				points: [
					{ x: 180, z: 87 },
					{ x: 179, z: 77 },
					{ x: 166, z: 64 },
					{ x: 151, z: 54 },
					{ x: 137, z: 53 },
					{ x: 130, z: 57 },
					{ x: 134, z: 71 },
					{ x: 151, z: 83 },
					{ x: 164, z: 101 },
					{ x: 170, z: 93 }
				],
				clouds: []
			},
			2231: {
				points: [
					{ x: 132, z: 70 },
					{ x: 130, z: 57 },
					{ x: 114, z: 52 },
					{ x: 103, z: 52 },
					{ x: 91, z: 59 },
					{ x: 90, z: 69 },
					{ x: 95, z: 80 },
					{ x: 108, z: 94 },
					{ x: 116, z: 95 },
					{ x: 118, z: 79 },
					{ x: 123, z: 72 }
				],
				clouds: []
			},
			2232: {
				points: [
					{ x: 151, z: 54 },
					{ x: 154, z: 44 },
					{ x: 138, z: 23 },
					{ x: 123, z: 13 },
					{ x: 112, z: 9 },
					{ x: 104, z: 9 },
					{ x: 94, z: 15 },
					{ x: 97, z: 31 },
					{ x: 106, z: 45 },
					{ x: 109, z: 51 },
					{ x: 128, z: 55 },
					{ x: 137, z: 52 }
				],
				clouds: []
			},
			2233: {
				points: [
					{ x: 92, z: 13 },
					{ x: 86, z: 15 },
					{ x: 84, z: 22 },
					{ x: 56, z: 44 },
					{ x: 58, z: 52 },
					{ x: 90, z: 68 },
					{ x: 90, z: 59 },
					{ x: 104, z: 52 },
					{ x: 109, z: 52 },
					{ x: 96, z: 30 }
				],
				clouds: []
			},
			2234: {
				points: [
					{ x: 88, z: 68 },
					{ x: 56, z: 50 },
					{ x: 50, z: 50 },
					{ x: 50, z: 62 },
					{ x: 57, z: 78 },
					{ x: 71, z: 94 },
					{ x: 75, z: 102 },
					{ x: 87, z: 110 },
					{ x: 92, z: 109 },
					{ x: 96, z: 108 },
					{ x: 107, z: 94 },
					{ x: 94, z: 80 }
				],
				clouds: []
			},
			2235: {
				points: [
					{ x: 75, z: 101 },
					{ x: 65, z: 107 },
					{ x: 62, z: 116 },
					{ x: 62, z: 126 },
					{ x: 65, z: 140 },
					{ x: 85, z: 166 },
					{ x: 99, z: 162 },
					{ x: 103, z: 155 },
					{ x: 101, z: 141 },
					{ x: 105, z: 130 },
					{ x: 98, z: 118 },
					{ x: 96, z: 108 },
					{ x: 86, z: 111 }
				],
				clouds: []
			},
			2236: {
				points: [
					{ x: 65, z: 141 },
					{ x: 27, z: 139 },
					{ x: 17, z: 145 },
					{ x: 15, z: 160 },
					{ x: 23, z: 175 },
					{ x: 42, z: 190 },
					{ x: 60, z: 197 },
					{ x: 71, z: 194 },
					{ x: 80, z: 189 },
					{ x: 85, z: 176 },
					{ x: 84, z: 165 }
				],
				clouds: []
			},
			2237: {
				points: [
					{ x: 63, z: 139 },
					{ x: 60, z: 121 },
					{ x: 52, z: 115 },
					{ x: 46, z: 107 },
					{ x: 24, z: 92 },
					{ x: 6, z: 96 },
					{ x: 6, z: 112 },
					{ x: 13, z: 127 },
					{ x: 24, z: 139 }
				],
				clouds: []
			},
			2238: {
				points: [
					{ x: 47, z: 56 },
					{ x: 39, z: 56 },
					{ x: 17, z: 78 },
					{ x: 20, z: 91 },
					{ x: 23, z: 92 },
					{ x: 46, z: 106 },
					{ x: 52, z: 114 },
					{ x: 60, z: 121 },
					{ x: 63, z: 106 },
					{ x: 74, z: 100 },
					{ x: 70, z: 92 },
					{ x: 56, z: 78 }
				],
				clouds: []
			}
		};

		
		public function map16():void
		{
		
		}
	}
}