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
			alpha:0.47,
			scaleX:0.9,
			scaleY:0.9
		};
		
		public var ax:int = 0;
		public var ay:int = 0;

		
		
		[Embed(source="sprites/walk_back.png", mimeType="image/png")]
		private var Sprite0:Class;

		[Embed(source="sprites/walk.png", mimeType="image/png")]
		private var Sprite1:Class;

		[Embed(source="sprites/stop_pause.png", mimeType="image/png")]
		private var Sprite2:Class;

		[Embed(source="sprites/rest1.png", mimeType="image/png")]
		private var Sprite3:Class;

		[Embed(source="sprites/rest.png", mimeType="image/png")]
		private var Sprite4:Class;

		
		public function Animation(){
		
			var frames:Array;
			//var atlas:BitmapData = new Sprite().bitmapData;
			
			
			var atlas_walk_back:BitmapData = new Sprite0().bitmapData;
			var atlas_walk:BitmapData = new Sprite1().bitmapData;
			var atlas_stop_pause:BitmapData = new Sprite2().bitmapData;
			var atlas_rest1:BitmapData = new Sprite3().bitmapData;
			var atlas_rest:BitmapData = new Sprite4().bitmapData;
			
			
			frames = [{ox:-29, oy:-66, x:0, y:0, w:55, h:88},{ox:-29, oy:-66, x:55, y:0, w:55, h:88},{ox:-29, oy:-66, x:110, y:0, w:56, h:87},{ox:-30, oy:-66, x:166, y:0, w:57, h:86},{ox:-30, oy:-66, x:223, y:0, w:57, h:85},{ox:-30, oy:-66, x:280, y:0, w:57, h:83},{ox:-30, oy:-66, x:337, y:0, w:57, h:84},{ox:-30, oy:-66, x:394, y:0, w:57, h:84},{ox:-29, oy:-66, x:451, y:0, w:57, h:85},{ox:-29, oy:-66, x:508, y:0, w:58, h:85},{ox:-29, oy:-66, x:566, y:0, w:59, h:85},{ox:-29, oy:-66, x:625, y:0, w:60, h:84},{ox:-30, oy:-66, x:685, y:0, w:60, h:84},{ox:-31, oy:-66, x:745, y:0, w:59, h:85},{ox:-31, oy:-66, x:804, y:0, w:57, h:86},{ox:-31, oy:-65, x:861, y:0, w:57, h:85},{ox:-31, oy:-65, x:918, y:0, w:57, h:86},{ox:-31, oy:-66, x:975, y:0, w:57, h:88},{ox:-30, oy:-66, x:1032, y:0, w:56, h:88},{ox:-30, oy:-66, x:1088, y:0, w:56, h:88}];
			animations['walk_back'] = {frames:getFrames(frames, atlas_walk_back), chain:[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19]};
			
			frames = [{ox:-32, oy:-47, x:0, y:0, w:59, h:72},{ox:-32, oy:-47, x:59, y:0, w:60, h:71},{ox:-33, oy:-47, x:119, y:0, w:60, h:70},{ox:-33, oy:-46, x:179, y:0, w:58, h:69},{ox:-34, oy:-46, x:237, y:0, w:57, h:68},{ox:-34, oy:-46, x:294, y:0, w:57, h:67},{ox:-34, oy:-46, x:351, y:0, w:57, h:66},{ox:-34, oy:-46, x:408, y:0, w:57, h:65},{ox:-33, oy:-47, x:465, y:0, w:56, h:67},{ox:-33, oy:-47, x:521, y:0, w:56, h:69},{ox:-32, oy:-47, x:577, y:0, w:55, h:70},{ox:-32, oy:-47, x:632, y:0, w:55, h:69},{ox:-33, oy:-46, x:687, y:0, w:57, h:67},{ox:-33, oy:-45, x:744, y:0, w:57, h:65},{ox:-33, oy:-44, x:801, y:0, w:57, h:63},{ox:-33, oy:-44, x:858, y:0, w:57, h:63},{ox:-33, oy:-45, x:915, y:0, w:57, h:65},{ox:-33, oy:-45, x:972, y:0, w:57, h:66},{ox:-32, oy:-46, x:1029, y:0, w:57, h:69},{ox:-32, oy:-46, x:1086, y:0, w:58, h:70}];
			animations['walk'] = {frames:getFrames(frames, atlas_walk), chain:[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19]};
			
			frames = [{ox:-36, oy:-40, x:0, y:0, w:62, h:62},{ox:-36, oy:-40, x:62, y:0, w:62, h:62},{ox:-36, oy:-39, x:124, y:0, w:62, h:61},{ox:-37, oy:-39, x:186, y:0, w:63, h:61},{ox:-37, oy:-39, x:249, y:0, w:63, h:61},{ox:-37, oy:-39, x:312, y:0, w:63, h:61}];
			animations['stop_pause'] = {frames:getFrames(frames, atlas_stop_pause), chain:[0,0,0,1,1,1,2,2,2,3,3,3,4,4,4,5,5,5,4,4,4,3,3,3,2,2,2,1,1,1]};
			
			frames = [{ox:-36, oy:-40, x:0, y:0, w:62, h:62},{ox:-36, oy:-40, x:62, y:0, w:62, h:62},{ox:-36, oy:-40, x:124, y:0, w:62, h:61},{ox:-36, oy:-40, x:186, y:0, w:62, h:61},{ox:-38, oy:-40, x:248, y:0, w:64, h:63},{ox:-40, oy:-40, x:312, y:0, w:66, h:65},{ox:-40, oy:-40, x:378, y:0, w:66, h:66},{ox:-40, oy:-39, x:444, y:0, w:66, h:65},{ox:-39, oy:-39, x:510, y:0, w:65, h:65},{ox:-40, oy:-39, x:575, y:0, w:65, h:65},{ox:-40, oy:-38, x:640, y:0, w:65, h:64},{ox:-40, oy:-38, x:705, y:0, w:65, h:64},{ox:-39, oy:-38, x:770, y:0, w:64, h:64},{ox:-39, oy:-39, x:834, y:0, w:64, h:65},{ox:-38, oy:-39, x:898, y:0, w:63, h:65},{ox:-37, oy:-38, x:961, y:0, w:62, h:66}];
			animations['rest1'] = {frames:getFrames(frames, atlas_rest1), chain:[0,0,1,1,2,2,3,3,4,4,5,5,6,6,7,7,8,8,9,9,10,10,11,11,12,12,13,13,14,14,15,15,14,14,13,13,12,12,11,11,10,10,9,9,8,8,7,7,6,6,5,5,4,4,3,3,2,2,1,1]};
			
			frames = [{ox:-36, oy:-40, x:0, y:0, w:62, h:62},{ox:-36, oy:-40, x:62, y:0, w:62, h:62},{ox:-37, oy:-40, x:124, y:0, w:63, h:62},{ox:-37, oy:-40, x:187, y:0, w:63, h:62},{ox:-37, oy:-40, x:250, y:0, w:63, h:62},{ox:-38, oy:-40, x:313, y:0, w:64, h:62},{ox:-38, oy:-40, x:377, y:0, w:64, h:62},{ox:-38, oy:-40, x:441, y:0, w:64, h:62},{ox:-38, oy:-40, x:505, y:0, w:64, h:62},{ox:-39, oy:-40, x:569, y:0, w:65, h:62},{ox:-41, oy:-40, x:634, y:0, w:67, h:62},{ox:-41, oy:-40, x:701, y:0, w:67, h:62},{ox:-41, oy:-40, x:768, y:0, w:67, h:62},{ox:-41, oy:-40, x:835, y:0, w:67, h:62},{ox:-41, oy:-40, x:902, y:0, w:67, h:62},{ox:-41, oy:-40, x:969, y:0, w:67, h:62}];
			animations['rest'] = {frames:getFrames(frames, atlas_rest), chain:[0,0,1,1,2,2,3,3,4,4,5,5,6,6,7,7,8,8,9,9,10,10,11,11,12,12,13,13,14,14,15,15,14,14,13,13,12,12,11,11,10,10,9,9,8,8,7,7,6,6,5,5,4,4,3,3,2,2,1,1]};
			
			
			animations = constructAnimation(animations);
			
			
			atlas_walk_back.dispose();
			atlas_walk_back = null;
			atlas_walk.dispose();
			atlas_walk = null;
			atlas_stop_pause.dispose();
			atlas_stop_pause = null;
			atlas_rest1.dispose();
			atlas_rest1 = null;
			atlas_rest.dispose();
			atlas_rest = null;
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