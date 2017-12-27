package 
{
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public class Animation 
	{
		public var animations:Object = { };
		
		public var shadow:Object = {
			x:0,
			y:10,
			alpha:0.59,
			scaleX:1,
			scaleY:1
		};
		
		public var ax:int = 0;
		public var ay:int = 30;

		
		
		[Embed(source="sprites/rest1.png", mimeType="image/png")]
		private var Sprite0:Class;

		[Embed(source="sprites/walk.png", mimeType="image/png")]
		private var Sprite1:Class;

		[Embed(source="sprites/stop_pause.png", mimeType="image/png")]
		private var Sprite2:Class;

		[Embed(source="sprites/rest.png", mimeType="image/png")]
		private var Sprite3:Class;

		[Embed(source="sprites/walk_back.png", mimeType="image/png")]
		private var Sprite4:Class;

		
		public function Animation(){
		
			var frames:Array;
			//var atlas:BitmapData = new Sprite().bitmapData;
			
			
			var atlas_rest1:BitmapData = new Sprite0().bitmapData;
			var atlas_walk:BitmapData = new Sprite1().bitmapData;
			var atlas_stop_pause:BitmapData = new Sprite2().bitmapData;
			var atlas_rest:BitmapData = new Sprite3().bitmapData;
			var atlas_walk_back:BitmapData = new Sprite4().bitmapData;
			
			
			frames = [{ox:-49, oy:-53, x:0, y:0, w:80, h:75},{ox:-49, oy:-53, x:80, y:0, w:80, h:75},{ox:-49, oy:-53, x:160, y:0, w:80, h:73},{ox:-49, oy:-53, x:240, y:0, w:79, h:73},{ox:-51, oy:-53, x:319, y:0, w:81, h:75},{ox:-53, oy:-53, x:400, y:0, w:83, h:78},{ox:-53, oy:-52, x:483, y:0, w:83, h:78},{ox:-53, oy:-52, x:566, y:0, w:83, h:78},{ox:-51, oy:-52, x:649, y:0, w:81, h:78},{ox:-51, oy:-51, x:730, y:0, w:81, h:77},{ox:-51, oy:-51, x:811, y:0, w:80, h:79},{ox:-50, oy:-50, x:891, y:0, w:79, h:79},{ox:-50, oy:-51, x:970, y:0, w:79, h:79},{ox:-52, oy:-51, x:1049, y:0, w:82, h:78},{ox:-51, oy:-51, x:1131, y:0, w:80, h:81},{ox:-50, oy:-51, x:1211, y:0, w:79, h:84}];
			animations['rest1'] = {frames:getFrames(frames, atlas_rest1), chain:[0,0,1,1,2,2,3,3,4,4,5,5,6,6,7,7,8,8,9,9,10,10,11,11,12,12,13,13,14,14,15,15,14,14,13,13,12,12,11,11,10,10,9,9,8,8,7,7,6,6,5,5,4,4,3,3,2,2,1,1]};
			
			frames = [{ox:-43, oy:-61, x:0, y:0, w:75, h:86},{ox:-43, oy:-60, x:75, y:0, w:76, h:85},{ox:-44, oy:-60, x:151, y:0, w:75, h:84},{ox:-44, oy:-59, x:226, y:0, w:74, h:81},{ox:-45, oy:-58, x:300, y:0, w:73, h:79},{ox:-45, oy:-58, x:373, y:0, w:72, h:78},{ox:-45, oy:-58, x:445, y:0, w:72, h:77},{ox:-45, oy:-59, x:517, y:0, w:71, h:78},{ox:-44, oy:-59, x:588, y:0, w:70, h:80},{ox:-43, oy:-60, x:658, y:0, w:70, h:83},{ox:-43, oy:-60, x:728, y:0, w:71, h:83},{ox:-43, oy:-60, x:799, y:0, w:71, h:83},{ox:-43, oy:-59, x:870, y:0, w:72, h:81},{ox:-44, oy:-59, x:942, y:0, w:73, h:80},{ox:-44, oy:-58, x:1015, y:0, w:73, h:78},{ox:-44, oy:-58, x:1088, y:0, w:73, h:76},{ox:-44, oy:-58, x:1161, y:0, w:73, h:77},{ox:-43, oy:-59, x:1234, y:0, w:72, h:80},{ox:-43, oy:-60, x:1306, y:0, w:73, h:83},{ox:-43, oy:-60, x:1379, y:0, w:74, h:84},{ox:-43, oy:-61, x:1453, y:0, w:75, h:86}];
			animations['walk'] = {frames:getFrames(frames, atlas_walk), chain:[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20]};
			
			frames = [{ox:-49, oy:-53, x:0, y:0, w:80, h:75},{ox:-49, oy:-53, x:80, y:0, w:80, h:75},{ox:-49, oy:-53, x:160, y:0, w:80, h:75},{ox:-49, oy:-52, x:240, y:0, w:80, h:74},{ox:-49, oy:-52, x:320, y:0, w:80, h:74},{ox:-50, oy:-52, x:400, y:0, w:81, h:74}];
			animations['stop_pause'] = {frames:getFrames(frames, atlas_stop_pause), chain:[0,0,0,1,1,1,2,2,2,3,3,3,4,4,4,5,5,5,4,4,4,3,3,3,2,2,2,1,1,1]};
			
			frames = [{ox:-49, oy:-53, x:0, y:0, w:80, h:75},{ox:-48, oy:-53, x:80, y:0, w:79, h:75},{ox:-50, oy:-53, x:159, y:0, w:81, h:75},{ox:-50, oy:-53, x:240, y:0, w:81, h:75},{ox:-50, oy:-53, x:321, y:0, w:81, h:75},{ox:-50, oy:-53, x:402, y:0, w:81, h:75},{ox:-51, oy:-53, x:483, y:0, w:82, h:75},{ox:-51, oy:-53, x:565, y:0, w:82, h:75},{ox:-51, oy:-53, x:647, y:0, w:82, h:75},{ox:-53, oy:-53, x:729, y:0, w:84, h:75},{ox:-54, oy:-53, x:813, y:0, w:85, h:75},{ox:-55, oy:-53, x:898, y:0, w:86, h:75},{ox:-55, oy:-53, x:984, y:0, w:86, h:75},{ox:-55, oy:-53, x:1070, y:0, w:86, h:75},{ox:-55, oy:-53, x:1156, y:0, w:86, h:75},{ox:-55, oy:-53, x:1242, y:0, w:86, h:75}];
			animations['rest'] = {frames:getFrames(frames, atlas_rest), chain:[0,0,1,1,2,2,3,3,4,4,5,5,6,6,7,7,8,8,9,9,10,10,11,11,12,12,13,13,14,14,15,15,14,14,13,13,12,12,11,11,10,10,9,9,8,8,7,7,6,6,5,5,4,4,3,3,2,2,1,1]};
			
			frames = [{ox:-39, oy:-81, x:0, y:0, w:70, h:106},{ox:-39, oy:-81, x:70, y:0, w:71, h:106},{ox:-39, oy:-81, x:141, y:0, w:71, h:104},{ox:-40, oy:-81, x:212, y:0, w:72, h:103},{ox:-40, oy:-80, x:284, y:0, w:73, h:101},{ox:-40, oy:-80, x:357, y:0, w:73, h:99},{ox:-40, oy:-80, x:430, y:0, w:72, h:99},{ox:-40, oy:-80, x:502, y:0, w:72, h:100},{ox:-39, oy:-80, x:574, y:0, w:72, h:100},{ox:-39, oy:-81, x:646, y:0, w:73, h:101},{ox:-39, oy:-81, x:719, y:0, w:74, h:101},{ox:-39, oy:-80, x:793, y:0, w:75, h:100},{ox:-40, oy:-80, x:868, y:0, w:74, h:100},{ox:-41, oy:-80, x:942, y:0, w:74, h:101},{ox:-41, oy:-80, x:1016, y:0, w:72, h:101},{ox:-42, oy:-80, x:1088, y:0, w:72, h:102},{ox:-41, oy:-80, x:1160, y:0, w:71, h:103},{ox:-41, oy:-80, x:1231, y:0, w:70, h:104},{ox:-40, oy:-81, x:1301, y:0, w:70, h:105},{ox:-40, oy:-81, x:1371, y:0, w:70, h:105},{ox:-39, oy:-81, x:1441, y:0, w:70, h:106}];
			animations['walk_back'] = {frames:getFrames(frames, atlas_walk_back), chain:[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20]};
			
			
			animations = constructAnimation(animations);
			
			
			atlas_rest1.dispose();
			atlas_rest1 = null;
			atlas_walk.dispose();
			atlas_walk = null;
			atlas_stop_pause.dispose();
			atlas_stop_pause = null;
			atlas_rest.dispose();
			atlas_rest = null;
			atlas_walk_back.dispose();
			atlas_walk_back = null;
		}
		
		public function getFrames(animations:Array, atlas:BitmapData):Array
		{
			const pt:Point = new Point(0, 0);
			var frame:Object;
			var bmd:BitmapData;
			var data:Array = [];
			for (var index:* in animations)
			{
				frame = animations[index];
				bmd = new BitmapData(frame.w, frame.h);
				
				bmd.copyPixels(atlas, new Rectangle(frame.x, frame.y, frame.w, frame.h), pt);
				data.push( { bmd:bmd, ox:frame.ox, oy:frame.oy} );
			}
			return data;
		}
		
		private function constructAnimation(animations:Object):Object
		{
			var result:Object = { };
			
			for (var i:String in animations) {
				if (i.indexOf('_back') >= 0) {
					if (result.hasOwnProperty(i.substring(0,i.length-5))) {
						result[i.substring(0,i.length-5)].frames[1] = animations[i].frames;
					}else{
						result[i.substring(0,i.length-5)] = {
							chain: animations[i].chain,
							frames: {
								1:animations[i].frames
							}
						}
					}
				}else {
					if (result.hasOwnProperty(i)) {
						result[i].frames[0] = animations[i].frames;
					}else{
						result[i] = {
							chain: animations[i].chain,
							frames: {
								0:animations[i].frames
							}
						}
					}
				}
			}
			
			return result;
		}
		
	}
}