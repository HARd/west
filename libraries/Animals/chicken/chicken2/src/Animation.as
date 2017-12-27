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
			alpha:0.5,
			scaleX:0.85,
			scaleY:0.85
		};
		
		public var ax:int = 0;
		public var ay:int = 0;

		
		
		[Embed(source="sprites/walk_back.png", mimeType="image/png")]
		private var Sprite0:Class;

		[Embed(source="sprites/stop_pause.png", mimeType="image/png")]
		private var Sprite1:Class;

		[Embed(source="sprites/walk.png", mimeType="image/png")]
		private var Sprite2:Class;

		[Embed(source="sprites/rest.png", mimeType="image/png")]
		private var Sprite3:Class;

		[Embed(source="sprites/rest1.png", mimeType="image/png")]
		private var Sprite4:Class;

		
		public function Animation(){
		
			var frames:Array;
			//var atlas:BitmapData = new Sprite().bitmapData;
			
			
			var atlas_walk_back:BitmapData = new Sprite0().bitmapData;
			var atlas_stop_pause:BitmapData = new Sprite1().bitmapData;
			var atlas_walk:BitmapData = new Sprite2().bitmapData;
			var atlas_rest:BitmapData = new Sprite3().bitmapData;
			var atlas_rest1:BitmapData = new Sprite4().bitmapData;
			
			
			frames = [{ox:-19, oy:-45, x:0, y:0, w:37, h:62},{ox:-18, oy:-45, x:37, y:0, w:37, h:63},{ox:-17, oy:-46, x:74, y:0, w:36, h:63},{ox:-17, oy:-47, x:110, y:0, w:36, h:63},{ox:-17, oy:-48, x:146, y:0, w:35, h:62},{ox:-16, oy:-48, x:181, y:0, w:33, h:60},{ox:-16, oy:-46, x:214, y:0, w:33, h:59},{ox:-16, oy:-45, x:247, y:0, w:32, h:60},{ox:-17, oy:-46, x:279, y:0, w:33, h:60},{ox:-18, oy:-47, x:312, y:0, w:35, h:61},{ox:-19, oy:-47, x:347, y:0, w:36, h:62},{ox:-19, oy:-46, x:383, y:0, w:37, h:61}];
			animations['walk_back'] = {frames:getFrames(frames, atlas_walk_back), chain:[0,0,1,1,2,2,3,3,4,4,5,5,6,6,7,7,8,8,9,9,10,10,11,11]};
			
			frames = [{ox:-17, oy:-34, x:0, y:0, w:37, h:50},{ox:-17, oy:-34, x:37, y:0, w:37, h:50},{ox:-17, oy:-33, x:74, y:0, w:37, h:49},{ox:-17, oy:-33, x:111, y:0, w:37, h:49},{ox:-17, oy:-33, x:148, y:0, w:37, h:49},{ox:-17, oy:-32, x:185, y:0, w:37, h:48}];
			animations['stop_pause'] = {frames:getFrames(frames, atlas_stop_pause), chain:[0,0,0,1,1,1,2,2,2,3,3,3,4,4,4,5,5,5,4,4,4,3,3,3,2,2,2,1,1,1]};
			
			frames = [{ox:-16, oy:-36, x:0, y:0, w:33, h:51},{ox:-16, oy:-37, x:33, y:0, w:33, h:53},{ox:-17, oy:-37, x:66, y:0, w:34, h:52},{ox:-21, oy:-35, x:100, y:0, w:38, h:48},{ox:-24, oy:-33, x:138, y:0, w:42, h:46},{ox:-22, oy:-35, x:180, y:0, w:41, h:49},{ox:-18, oy:-37, x:221, y:0, w:37, h:54},{ox:-17, oy:-38, x:258, y:0, w:36, h:56},{ox:-17, oy:-37, x:294, y:0, w:36, h:54},{ox:-19, oy:-34, x:330, y:0, w:37, h:50},{ox:-21, oy:-33, x:367, y:0, w:39, h:48},{ox:-19, oy:-34, x:406, y:0, w:36, h:48}];
			animations['walk'] = {frames:getFrames(frames, atlas_walk), chain:[0,0,1,1,2,2,3,3,4,4,5,5,6,6,7,7,8,8,9,9,10,10,11,11]};
			
			frames = [{ox:-17, oy:-34, x:0, y:0, w:37, h:50},{ox:-16, oy:-33, x:37, y:0, w:34, h:49},{ox:-16, oy:-33, x:71, y:0, w:34, h:49},{ox:-16, oy:-33, x:105, y:0, w:33, h:49},{ox:-15, oy:-33, x:138, y:0, w:30, h:49},{ox:-15, oy:-33, x:168, y:0, w:29, h:49},{ox:-14, oy:-34, x:197, y:0, w:28, h:50},{ox:-14, oy:-34, x:225, y:0, w:28, h:50},{ox:-14, oy:-35, x:253, y:0, w:28, h:51},{ox:-14, oy:-35, x:281, y:0, w:28, h:51},{ox:-14, oy:-34, x:309, y:0, w:28, h:50},{ox:-15, oy:-33, x:337, y:0, w:29, h:49},{ox:-15, oy:-33, x:366, y:0, w:30, h:49},{ox:-16, oy:-34, x:396, y:0, w:34, h:50},{ox:-16, oy:-35, x:430, y:0, w:36, h:51},{ox:-16, oy:-36, x:466, y:0, w:37, h:52}];
			animations['rest'] = {frames:getFrames(frames, atlas_rest), chain:[0,0,1,1,2,2,3,3,4,4,5,5,6,6,7,7,8,8,9,9,10,10,11,11,12,12,13,13,14,14,15,15,14,14,13,13,12,12,11,11,10,10,9,9,8,8,7,7,6,6,5,5,4,4,3,3,2,2,1,1]};
			
			frames = [{ox:-17, oy:-34, x:0, y:0, w:37, h:50},{ox:-17, oy:-34, x:37, y:0, w:37, h:50},{ox:-17, oy:-34, x:74, y:0, w:37, h:50},{ox:-17, oy:-34, x:111, y:0, w:37, h:50},{ox:-17, oy:-34, x:148, y:0, w:37, h:50},{ox:-17, oy:-34, x:185, y:0, w:37, h:50},{ox:-17, oy:-33, x:222, y:0, w:37, h:49},{ox:-18, oy:-32, x:259, y:0, w:37, h:48},{ox:-20, oy:-31, x:296, y:0, w:40, h:47},{ox:-20, oy:-31, x:336, y:0, w:44, h:47},{ox:-18, oy:-30, x:380, y:0, w:46, h:46},{ox:-17, oy:-30, x:426, y:0, w:45, h:54},{ox:-18, oy:-30, x:471, y:0, w:45, h:48},{ox:-18, oy:-31, x:516, y:0, w:42, h:47},{ox:-18, oy:-31, x:558, y:0, w:40, h:47},{ox:-17, oy:-30, x:598, y:0, w:43, h:46},{ox:-16, oy:-30, x:641, y:0, w:49, h:46},{ox:-16, oy:-29, x:690, y:0, w:50, h:48},{ox:-16, oy:-29, x:740, y:0, w:50, h:45},{ox:-17, oy:-29, x:790, y:0, w:51, h:45},{ox:-18, oy:-30, x:841, y:0, w:49, h:46},{ox:-17, oy:-31, x:890, y:0, w:46, h:47},{ox:-17, oy:-32, x:936, y:0, w:42, h:48},{ox:-17, oy:-33, x:978, y:0, w:38, h:49}];
			animations['rest1'] = {frames:getFrames(frames, atlas_rest1), chain:[0,0,1,1,2,2,3,3,4,4,5,5,6,6,7,7,8,8,9,9,10,10,11,11,12,12,13,13,14,14,15,15,16,16,17,17,18,18,19,19,20,20,21,21,22,22,23,23,22,22,21,21,20,20,19,19,18,18,17,17,16,16,15,15,14,14,13,13,12,12,11,11,10,10,9,9,8,8,7,7,6,6,5,5,4,4,3,3,2,2,1,1]};
			
			
			animations = constructAnimation(animations);
			
			
			atlas_walk_back.dispose();
			atlas_walk_back = null;
			atlas_stop_pause.dispose();
			atlas_stop_pause = null;
			atlas_walk.dispose();
			atlas_walk = null;
			atlas_rest.dispose();
			atlas_rest = null;
			atlas_rest1.dispose();
			atlas_rest1 = null;
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