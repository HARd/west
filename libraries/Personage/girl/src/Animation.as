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
			alpha:0.53,
			scaleX:1,
			scaleY:1
		};
		
		public var ax:int = 0;
		public var ay:int = 0;

		
		
		[Embed(source="sprites/walk.png", mimeType="image/png")]
		private var Sprite0:Class;

		[Embed(source="sprites/work_mine.png", mimeType="image/png")]
		private var Sprite1:Class;

		[Embed(source="sprites/work_plant.png", mimeType="image/png")]
		private var Sprite2:Class;

		[Embed(source="sprites/work_cut.png", mimeType="image/png")]
		private var Sprite3:Class;

		[Embed(source="sprites/work_gather.png", mimeType="image/png")]
		private var Sprite4:Class;

		[Embed(source="sprites/stop_pause.png", mimeType="image/png")]
		private var Sprite5:Class;

		[Embed(source="sprites/work_water.png", mimeType="image/png")]
		private var Sprite6:Class;

		[Embed(source="sprites/walk_back.png", mimeType="image/png")]
		private var Sprite7:Class;

		[Embed(source="sprites/rest.png", mimeType="image/png")]
		private var Sprite8:Class;

		
		public function Animation(){
		
			var frames:Array;
			//var atlas:BitmapData = new Sprite().bitmapData;
			
			
			var atlas_walk:BitmapData = new Sprite0().bitmapData;
			var atlas_work_mine:BitmapData = new Sprite1().bitmapData;
			var atlas_work_plant:BitmapData = new Sprite2().bitmapData;
			var atlas_work_cut:BitmapData = new Sprite3().bitmapData;
			var atlas_work_gather:BitmapData = new Sprite4().bitmapData;
			var atlas_stop_pause:BitmapData = new Sprite5().bitmapData;
			var atlas_work_water:BitmapData = new Sprite6().bitmapData;
			var atlas_walk_back:BitmapData = new Sprite7().bitmapData;
			var atlas_rest:BitmapData = new Sprite8().bitmapData;
			
			
			frames = [{ox:-26, oy:-91, x:0, y:0, w:47, h:111},{ox:-24, oy:-92, x:47, y:0, w:47, h:110},{ox:-23, oy:-93, x:94, y:0, w:44, h:109},{ox:-24, oy:-94, x:138, y:0, w:41, h:108},{ox:-23, oy:-94, x:179, y:0, w:39, h:107},{ox:-22, oy:-94, x:218, y:0, w:37, h:105},{ox:-21, oy:-93, x:255, y:0, w:34, h:108},{ox:-20, oy:-92, x:289, y:0, w:34, h:111},{ox:-19, oy:-92, x:323, y:0, w:37, h:112},{ox:-18, oy:-92, x:360, y:0, w:37, h:110},{ox:-18, oy:-93, x:397, y:0, w:34, h:110},{ox:-19, oy:-94, x:431, y:0, w:39, h:110},{ox:-23, oy:-94, x:470, y:0, w:44, h:109},{ox:-24, oy:-94, x:514, y:0, w:46, h:108},{ox:-25, oy:-93, x:560, y:0, w:47, h:109},{ox:-27, oy:-92, x:607, y:0, w:48, h:112}];
			animations['walk'] = {frames:getFrames(frames, atlas_walk), chain:[0,0,1,1,2,2,3,3,4,4,5,5,6,6,7,7,8,8,9,9,10,10,11,11,12,12,13,13,14,14,15,15]};
			
			frames = [{ox:-11, oy:-127, x:0, y:0, w:81, h:146},{ox:-11, oy:-133, x:81, y:0, w:66, h:152},{ox:-12, oy:-121, x:147, y:0, w:54, h:140},{ox:-13, oy:-96, x:201, y:0, w:40, h:115},{ox:-17, oy:-73, x:241, y:0, w:42, h:92},{ox:-29, oy:-66, x:283, y:0, w:55, h:89},{ox:-47, oy:-63, x:338, y:0, w:73, h:87},{ox:-32, oy:-66, x:411, y:0, w:58, h:86},{ox:-23, oy:-73, x:469, y:0, w:48, h:92},{ox:-13, oy:-82, x:517, y:0, w:41, h:101},{ox:-12, oy:-90, x:558, y:0, w:71, h:109},{ox:-11, oy:-116, x:629, y:0, w:80, h:135}];
			animations['work_mine'] = {frames:getFrames(frames, atlas_work_mine), chain:[0,0,1,1,2,2,3,3,4,4,5,5,6,6,7,7,8,8,9,9,10,10,11,11]};
			
			frames = [{ox:-31, oy:-92, x:0, y:0, w:54, h:106},{ox:-31, oy:-93, x:54, y:0, w:54, h:107},{ox:-31, oy:-93, x:108, y:0, w:54, h:108},{ox:-31, oy:-94, x:162, y:0, w:54, h:109},{ox:-31, oy:-95, x:216, y:0, w:53, h:110},{ox:-30, oy:-95, x:269, y:0, w:52, h:110},{ox:-30, oy:-95, x:321, y:0, w:52, h:110},{ox:-29, oy:-95, x:373, y:0, w:51, h:110},{ox:-27, oy:-96, x:424, y:0, w:49, h:111},{ox:-26, oy:-96, x:473, y:0, w:49, h:111},{ox:-26, oy:-95, x:522, y:0, w:59, h:110},{ox:-27, oy:-95, x:581, y:0, w:64, h:110},{ox:-28, oy:-96, x:645, y:0, w:61, h:111},{ox:-29, oy:-95, x:706, y:0, w:61, h:115},{ox:-30, oy:-95, x:767, y:0, w:62, h:123},{ox:-30, oy:-95, x:829, y:0, w:62, h:124},{ox:-31, oy:-95, x:891, y:0, w:62, h:124},{ox:-31, oy:-94, x:953, y:0, w:62, h:123},{ox:-31, oy:-93, x:1015, y:0, w:54, h:108},{ox:-31, oy:-93, x:1069, y:0, w:54, h:107}];
			animations['work_plant'] = {frames:getFrames(frames, atlas_work_plant), chain:[0,0,1,1,2,2,3,3,4,4,5,5,6,6,7,7,8,8,9,9,10,10,11,11,12,12,13,13,14,14,15,15,16,16,17,17,18,18,19,19]};
			
			frames = [{ox:-12, oy:-98, x:0, y:0, w:68, h:117},{ox:-12, oy:-97, x:68, y:0, w:68, h:116},{ox:-11, oy:-97, x:136, y:0, w:66, h:116},{ox:-11, oy:-97, x:202, y:0, w:60, h:116},{ox:-11, oy:-97, x:262, y:0, w:55, h:116},{ox:-10, oy:-96, x:317, y:0, w:40, h:115},{ox:-22, oy:-96, x:357, y:0, w:51, h:115},{ox:-13, oy:-96, x:408, y:0, w:42, h:115},{ox:-10, oy:-96, x:450, y:0, w:42, h:115},{ox:-11, oy:-97, x:492, y:0, w:56, h:116},{ox:-11, oy:-97, x:548, y:0, w:61, h:116},{ox:-12, oy:-97, x:609, y:0, w:67, h:116},{ox:-12, oy:-98, x:676, y:0, w:68, h:117}];
			animations['work_cut'] = {frames:getFrames(frames, atlas_work_cut), chain:[0,0,1,1,2,2,3,3,4,4,5,5,6,6,7,7,8,8,9,9,10,10,11,11,12,12]};
			
			frames = [{ox:-26, oy:-61, x:0, y:0, w:65, h:81},{ox:-26, oy:-61, x:65, y:0, w:65, h:81},{ox:-26, oy:-62, x:130, y:0, w:65, h:82},{ox:-26, oy:-63, x:195, y:0, w:65, h:83},{ox:-26, oy:-64, x:260, y:0, w:66, h:84},{ox:-26, oy:-63, x:326, y:0, w:66, h:83},{ox:-26, oy:-62, x:392, y:0, w:66, h:82},{ox:-26, oy:-61, x:458, y:0, w:66, h:81},{ox:-26, oy:-59, x:524, y:0, w:66, h:79},{ox:-26, oy:-58, x:590, y:0, w:66, h:78},{ox:-26, oy:-58, x:656, y:0, w:66, h:78}];
			animations['work_gather'] = {frames:getFrames(frames, atlas_work_gather), chain:[0,0,1,1,2,2,3,3,4,4,5,5,6,6,7,7,8,8,9,9,10,10,9,9,8,8,7,7,6,6,5,5,4,4,3,3,2,2,1,1]};
			
			frames = [{ox:-17, oy:-95, x:0, y:0, w:36, h:113},{ox:-17, oy:-95, x:36, y:0, w:36, h:113},{ox:-17, oy:-95, x:72, y:0, w:36, h:113},{ox:-17, oy:-95, x:108, y:0, w:36, h:113},{ox:-17, oy:-95, x:144, y:0, w:36, h:113},{ox:-17, oy:-95, x:180, y:0, w:36, h:113}];
			animations['stop_pause'] = {frames:getFrames(frames, atlas_stop_pause), chain:[0,0,0,1,1,1,2,2,2,3,3,3,4,4,4,5,5,5,4,4,4,3,3,3,2,2,2,1,1,1]};
			
			frames = [{ox:-54, oy:-94, x:0, y:0, w:79, h:129},{ox:-56, oy:-94, x:79, y:0, w:81, h:128},{ox:-58, oy:-94, x:160, y:0, w:83, h:126},{ox:-59, oy:-94, x:243, y:0, w:83, h:127},{ox:-58, oy:-94, x:326, y:0, w:82, h:127},{ox:-57, oy:-94, x:408, y:0, w:81, h:127},{ox:-55, oy:-94, x:489, y:0, w:79, h:129},{ox:-52, oy:-94, x:568, y:0, w:76, h:130},{ox:-54, oy:-94, x:644, y:0, w:79, h:129},{ox:-53, oy:-94, x:723, y:0, w:78, h:131}];
			animations['work_water'] = {frames:getFrames(frames, atlas_work_water), chain:[0,0,1,1,2,2,3,3,4,4,5,5,6,6,7,7,8,8,9,9]};
			
			frames = [{ox:-21, oy:-94, x:0, y:0, w:40, h:115},{ox:-17, oy:-95, x:40, y:0, w:38, h:114},{ox:-17, oy:-96, x:78, y:0, w:36, h:111},{ox:-19, oy:-97, x:114, y:0, w:37, h:109},{ox:-21, oy:-97, x:151, y:0, w:40, h:110},{ox:-23, oy:-97, x:191, y:0, w:42, h:112},{ox:-24, oy:-96, x:233, y:0, w:44, h:113},{ox:-24, oy:-95, x:277, y:0, w:43, h:113},{ox:-22, oy:-95, x:320, y:0, w:44, h:113},{ox:-24, oy:-95, x:364, y:0, w:47, h:113},{ox:-24, oy:-96, x:411, y:0, w:42, h:111},{ox:-25, oy:-96, x:453, y:0, w:41, h:111},{ox:-26, oy:-97, x:494, y:0, w:43, h:113},{ox:-25, oy:-96, x:537, y:0, w:43, h:113},{ox:-24, oy:-95, x:580, y:0, w:42, h:114},{ox:-23, oy:-95, x:622, y:0, w:39, h:116}];
			animations['walk_back'] = {frames:getFrames(frames, atlas_walk_back), chain:[0,0,1,1,2,2,3,3,4,4,5,5,6,6,7,7,8,8,9,9,10,10,11,11,12,12,13,13,14,14,15,15]};
			
			frames = [{ox:-17, oy:-95, x:0, y:0, w:36, h:113},{ox:-17, oy:-95, x:36, y:0, w:36, h:113},{ox:-20, oy:-96, x:72, y:0, w:40, h:114},{ox:-23, oy:-96, x:112, y:0, w:44, h:114},{ox:-23, oy:-98, x:156, y:0, w:44, h:116},{ox:-22, oy:-102, x:200, y:0, w:43, h:120},{ox:-19, oy:-106, x:243, y:0, w:39, h:124},{ox:-15, oy:-107, x:282, y:0, w:35, h:125},{ox:-15, oy:-107, x:317, y:0, w:35, h:125},{ox:-19, oy:-104, x:352, y:0, w:38, h:122},{ox:-21, oy:-99, x:390, y:0, w:40, h:117},{ox:-24, oy:-98, x:430, y:0, w:43, h:116},{ox:-24, oy:-98, x:473, y:0, w:43, h:116},{ox:-22, oy:-99, x:516, y:0, w:41, h:117},{ox:-21, oy:-99, x:557, y:0, w:39, h:117},{ox:-19, oy:-103, x:596, y:0, w:38, h:121},{ox:-17, oy:-106, x:634, y:0, w:37, h:124},{ox:-15, oy:-107, x:671, y:0, w:35, h:125},{ox:-15, oy:-105, x:706, y:0, w:35, h:123},{ox:-15, oy:-98, x:741, y:0, w:34, h:116},{ox:-15, oy:-96, x:775, y:0, w:33, h:114},{ox:-16, oy:-96, x:808, y:0, w:34, h:114}];
			animations['rest'] = {frames:getFrames(frames, atlas_rest), chain:[0,0,1,1,2,2,3,3,4,4,5,5,6,6,7,7,8,8,9,9,10,10,11,11,12,12,13,13,14,14,15,15,16,16,15,15,14,14,13,13,12,12,11,11,10,10,9,9,8,8,9,9,10,10,11,11,12,12,13,13,14,14,15,15,16,16,15,15,14,14,13,13,12,12,11,11,10,10,9,9,8,8,9,9,10,10,11,11,12,12,13,13,14,14,15,15,16,16,17,17,18,18,19,19,20,20,21,21]};
			
			frames = [{ox:-11, oy:-127, x:0, y:0, w:81, h:146},{ox:-11, oy:-133, x:81, y:0, w:66, h:152},{ox:-12, oy:-121, x:147, y:0, w:54, h:140},{ox:-13, oy:-96, x:201, y:0, w:40, h:115},{ox:-17, oy:-73, x:241, y:0, w:42, h:92},{ox:-29, oy:-66, x:283, y:0, w:55, h:89},{ox:-47, oy:-63, x:338, y:0, w:73, h:87},{ox:-32, oy:-66, x:411, y:0, w:58, h:86},{ox:-23, oy:-73, x:469, y:0, w:48, h:92},{ox:-13, oy:-82, x:517, y:0, w:41, h:101},{ox:-12, oy:-90, x:558, y:0, w:71, h:109},{ox:-11, oy:-116, x:629, y:0, w:80, h:135}];
			animations['harvest'] = {frames:getFrames(frames, atlas_work_mine), chain:[0,0,1,1,2,2,3,3,4,4,5,5,6,6,7,7,8,8,9,9,10,10,11,11]};
			
			
			animations = constructAnimation(animations);
			
			
			atlas_walk.dispose();
			atlas_walk = null;
			atlas_work_mine.dispose();
			atlas_work_mine = null;
			atlas_work_plant.dispose();
			atlas_work_plant = null;
			atlas_work_cut.dispose();
			atlas_work_cut = null;
			atlas_work_gather.dispose();
			atlas_work_gather = null;
			atlas_stop_pause.dispose();
			atlas_stop_pause = null;
			atlas_work_water.dispose();
			atlas_work_water = null;
			atlas_walk_back.dispose();
			atlas_walk_back = null;
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