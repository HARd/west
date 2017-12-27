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

		
		
		[Embed(source="sprites/walk.png", mimeType="image/png")]
		private var Sprite0:Class;

		[Embed(source="sprites/rest1.png", mimeType="image/png")]
		private var Sprite1:Class;

		[Embed(source="sprites/walk_back.png", mimeType="image/png")]
		private var Sprite2:Class;

		[Embed(source="sprites/rest.png", mimeType="image/png")]
		private var Sprite3:Class;

		[Embed(source="sprites/stop_pause.png", mimeType="image/png")]
		private var Sprite4:Class;

		
		public function Animation(){
		
			var frames:Array;
			//var atlas:BitmapData = new Sprite().bitmapData;
			
			
			var atlas_walk:BitmapData = new Sprite0().bitmapData;
			var atlas_rest1:BitmapData = new Sprite1().bitmapData;
			var atlas_walk_back:BitmapData = new Sprite2().bitmapData;
			var atlas_rest:BitmapData = new Sprite3().bitmapData;
			var atlas_stop_pause:BitmapData = new Sprite4().bitmapData;
			
			
			frames = [{ox:-14, oy:-38, x:0, y:0, w:33, h:52},{ox:-13, oy:-38, x:33, y:0, w:32, h:53},{ox:-15, oy:-38, x:65, y:0, w:34, h:52},{ox:-19, oy:-36, x:99, y:0, w:38, h:48},{ox:-21, oy:-34, x:137, y:0, w:41, h:46},{ox:-19, oy:-36, x:178, y:0, w:40, h:49},{ox:-15, oy:-39, x:218, y:0, w:36, h:55},{ox:-13, oy:-39, x:254, y:0, w:34, h:57},{ox:-14, oy:-38, x:288, y:0, w:35, h:55},{ox:-17, oy:-36, x:323, y:0, w:38, h:51},{ox:-19, oy:-34, x:361, y:0, w:39, h:48},{ox:-17, oy:-35, x:400, y:0, w:36, h:48}];
			animations['walk'] = {frames:getFrames(frames, atlas_walk), chain:[0,0,1,1,2,2,3,3,4,4,5,5,6,6,7,7,8,8,9,9,10,10,11,11]};
			
			frames = [{ox:-17, oy:-34, x:0, y:0, w:37, h:49},{ox:-17, oy:-34, x:37, y:0, w:37, h:49},{ox:-17, oy:-34, x:74, y:0, w:37, h:49},{ox:-17, oy:-34, x:111, y:0, w:37, h:49},{ox:-17, oy:-34, x:148, y:0, w:37, h:49},{ox:-17, oy:-34, x:185, y:0, w:37, h:49},{ox:-17, oy:-34, x:222, y:0, w:36, h:49},{ox:-18, oy:-33, x:258, y:0, w:37, h:48},{ox:-20, oy:-32, x:295, y:0, w:40, h:47},{ox:-20, oy:-31, x:335, y:0, w:44, h:46},{ox:-18, oy:-31, x:379, y:0, w:46, h:46},{ox:-17, oy:-31, x:425, y:0, w:45, h:55},{ox:-18, oy:-31, x:470, y:0, w:45, h:48},{ox:-18, oy:-32, x:515, y:0, w:42, h:47},{ox:-18, oy:-32, x:557, y:0, w:40, h:47},{ox:-18, oy:-31, x:597, y:0, w:44, h:46},{ox:-16, oy:-31, x:641, y:0, w:49, h:46},{ox:-16, oy:-30, x:690, y:0, w:52, h:48},{ox:-16, oy:-30, x:742, y:0, w:52, h:45},{ox:-17, oy:-30, x:794, y:0, w:51, h:45},{ox:-18, oy:-31, x:845, y:0, w:49, h:46},{ox:-18, oy:-31, x:894, y:0, w:46, h:46},{ox:-17, oy:-33, x:940, y:0, w:41, h:48},{ox:-17, oy:-34, x:981, y:0, w:38, h:49}];
			animations['rest1'] = {frames:getFrames(frames, atlas_rest1), chain:[0,0,1,1,2,2,3,3,4,4,5,5,6,6,7,7,8,8,9,9,10,10,11,11,12,12,13,13,14,14,15,15,16,16,17,17,18,18,19,19,20,20,21,21,22,22,23,23,0,0,1,1,2,2,3,3,4,4,5,5,6,6,7,7,8,8,9,9,10,10,11,11,12,12,13,13,14,14,15,15,16,16,17,17,18,18,19,19,20,20,21,21,22,22,23,23]};
			
			frames = [{ox:-14, oy:-43, x:0, y:0, w:33, h:57},{ox:-14, oy:-42, x:33, y:0, w:33, h:58},{ox:-16, oy:-43, x:66, y:0, w:35, h:58},{ox:-19, oy:-43, x:101, y:0, w:38, h:58},{ox:-22, oy:-44, x:139, y:0, w:42, h:60},{ox:-20, oy:-44, x:181, y:0, w:41, h:61},{ox:-16, oy:-43, x:222, y:0, w:36, h:61},{ox:-14, oy:-42, x:258, y:0, w:35, h:61},{ox:-15, oy:-43, x:293, y:0, w:36, h:61},{ox:-18, oy:-44, x:329, y:0, w:38, h:60},{ox:-19, oy:-44, x:367, y:0, w:39, h:58},{ox:-17, oy:-44, x:406, y:0, w:36, h:58}];
			animations['walk_back'] = {frames:getFrames(frames, atlas_walk_back), chain:[0,0,1,1,2,2,3,3,4,4,5,5,6,6,7,7,8,8,9,9,10,10,11,11]};
			
			frames = [{ox:-17, oy:-34, x:0, y:0, w:37, h:49},{ox:-16, oy:-34, x:37, y:0, w:30, h:49},{ox:-15, oy:-34, x:67, y:0, w:28, h:49},{ox:-14, oy:-35, x:95, y:0, w:28, h:50},{ox:-14, oy:-36, x:123, y:0, w:28, h:51},{ox:-14, oy:-36, x:151, y:0, w:28, h:51},{ox:-15, oy:-34, x:179, y:0, w:28, h:49},{ox:-16, oy:-35, x:207, y:0, w:34, h:50},{ox:-17, oy:-37, x:241, y:0, w:38, h:52}];
			animations['rest'] = {frames:getFrames(frames, atlas_rest), chain:[0,0,1,1,2,2,3,3,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,5,5,6,6,7,7,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,7,7]};
			
			frames = [{ox:-17, oy:-34, x:0, y:0, w:37, h:49},{ox:-17, oy:-34, x:37, y:0, w:37, h:49},{ox:-17, oy:-34, x:74, y:0, w:37, h:49},{ox:-17, oy:-34, x:111, y:0, w:37, h:49},{ox:-17, oy:-33, x:148, y:0, w:37, h:48},{ox:-17, oy:-33, x:185, y:0, w:37, h:48}];
			animations['stop_pause'] = {frames:getFrames(frames, atlas_stop_pause), chain:[0,0,0,1,1,1,2,2,2,3,3,3,4,4,4,5,5,5,4,4,4,3,3,3,2,2,2,1,1,1]};
			
			
			animations = constructAnimation(animations);
			
			
			atlas_walk.dispose();
			atlas_walk = null;
			atlas_rest1.dispose();
			atlas_rest1 = null;
			atlas_walk_back.dispose();
			atlas_walk_back = null;
			atlas_rest.dispose();
			atlas_rest = null;
			atlas_stop_pause.dispose();
			atlas_stop_pause = null;
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