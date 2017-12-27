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
			alpha:0.4,
			scaleX:0.7,
			scaleY:0.7
		};
		
		public var ax:int = 0;
		public var ay:int = 0;

		
		
		[Embed(source="sprites/stop_pause.png", mimeType="image/png")]
		private var Sprite0:Class;

		[Embed(source="sprites/walk_back.png", mimeType="image/png")]
		private var Sprite1:Class;

		[Embed(source="sprites/rest1.png", mimeType="image/png")]
		private var Sprite2:Class;

		[Embed(source="sprites/walk.png", mimeType="image/png")]
		private var Sprite3:Class;

		[Embed(source="sprites/rest.png", mimeType="image/png")]
		private var Sprite4:Class;

		
		public function Animation(){
		
			var frames:Array;
			//var atlas:BitmapData = new Sprite().bitmapData;
			
			
			var atlas_stop_pause:BitmapData = new Sprite0().bitmapData;
			var atlas_walk_back:BitmapData = new Sprite1().bitmapData;
			var atlas_rest1:BitmapData = new Sprite2().bitmapData;
			var atlas_walk:BitmapData = new Sprite3().bitmapData;
			var atlas_rest:BitmapData = new Sprite4().bitmapData;
			
			
			frames = [{ox:-11, oy:-17, x:0, y:0, w:28, h:32},{ox:-11, oy:-17, x:28, y:0, w:28, h:32},{ox:-11, oy:-17, x:56, y:0, w:28, h:32},{ox:-11, oy:-17, x:84, y:0, w:28, h:32},{ox:-11, oy:-17, x:112, y:0, w:28, h:32},{ox:-12, oy:-17, x:140, y:0, w:29, h:32},{ox:-12, oy:-17, x:169, y:0, w:28, h:32}];
			animations['stop_pause'] = {frames:getFrames(frames, atlas_stop_pause), chain:[0,0,1,1,2,2,3,3,4,4,5,5,6,6]};
			
			frames = [{ox:-11, oy:-25, x:0, y:0, w:27, h:41},{ox:-12, oy:-25, x:27, y:0, w:28, h:40},{ox:-12, oy:-25, x:55, y:0, w:28, h:38},{ox:-11, oy:-25, x:83, y:0, w:27, h:37},{ox:-11, oy:-25, x:110, y:0, w:27, h:37},{ox:-10, oy:-25, x:137, y:0, w:25, h:38},{ox:-9, oy:-25, x:162, y:0, w:25, h:39},{ox:-8, oy:-25, x:187, y:0, w:25, h:38},{ox:-8, oy:-25, x:212, y:0, w:26, h:38},{ox:-9, oy:-24, x:238, y:0, w:27, h:37},{ox:-9, oy:-25, x:265, y:0, w:27, h:39},{ox:-10, oy:-25, x:292, y:0, w:27, h:40}];
			animations['walk_back'] = {frames:getFrames(frames, atlas_walk_back), chain:[0,0,1,1,2,2,3,3,4,4,5,5,6,6,7,7,8,8,9,9,10,10,11,11]};
			
			frames = [{ox:-14, oy:-17, x:0, y:0, w:28, h:32},{ox:-14, oy:-17, x:28, y:0, w:29, h:32},{ox:-15, oy:-15, x:57, y:0, w:31, h:30},{ox:-14, oy:-15, x:88, y:0, w:31, h:30},{ox:-14, oy:-15, x:119, y:0, w:31, h:30},{ox:-14, oy:-15, x:150, y:0, w:29, h:30},{ox:-13, oy:-15, x:179, y:0, w:28, h:30},{ox:-15, oy:-12, x:207, y:0, w:30, h:27},{ox:-14, oy:-14, x:237, y:0, w:31, h:29},{ox:-14, oy:-12, x:268, y:0, w:29, h:27},{ox:-14, oy:-15, x:297, y:0, w:28, h:30},{ox:-15, oy:-15, x:325, y:0, w:30, h:30},{ox:-14, oy:-14, x:355, y:0, w:30, h:29},{ox:-14, oy:-16, x:385, y:0, w:28, h:31},{ox:-14, oy:-18, x:413, y:0, w:27, h:33},{ox:-15, oy:-18, x:440, y:0, w:28, h:33},{ox:-15, oy:-18, x:468, y:0, w:28, h:33},{ox:-14, oy:-17, x:496, y:0, w:28, h:32},{ox:-14, oy:-17, x:524, y:0, w:28, h:32}];
			animations['rest1'] = {frames:getFrames(frames, atlas_rest1), chain:[0,0,1,1,2,2,3,3,4,4,5,5,6,6,7,7,8,8,9,9,10,10,11,11,12,12,13,13,14,14,15,15,16,16,17,17,18,18]};
			
			frames = [{ox:-12, oy:-18, x:0, y:0, w:27, h:36},{ox:-13, oy:-18, x:27, y:0, w:28, h:35},{ox:-13, oy:-17, x:55, y:0, w:28, h:33},{ox:-12, oy:-17, x:83, y:0, w:27, h:32},{ox:-12, oy:-17, x:110, y:0, w:27, h:32},{ox:-11, oy:-18, x:137, y:0, w:26, h:33},{ox:-10, oy:-18, x:163, y:0, w:25, h:34},{ox:-9, oy:-18, x:188, y:0, w:25, h:33},{ox:-9, oy:-18, x:213, y:0, w:26, h:32},{ox:-10, oy:-17, x:239, y:0, w:27, h:31},{ox:-10, oy:-18, x:266, y:0, w:27, h:33},{ox:-11, oy:-18, x:293, y:0, w:27, h:35}];
			animations['walk'] = {frames:getFrames(frames, atlas_walk), chain:[0,0,1,1,2,2,3,3,4,4,5,5,6,6,7,7,8,8,9,9,10,10,11,11]};
			
			frames = [{ox:-11, oy:-17, x:0, y:0, w:28, h:32},{ox:-11, oy:-16, x:28, y:0, w:28, h:31},{ox:-11, oy:-14, x:56, y:0, w:28, h:29},{ox:-11, oy:-13, x:84, y:0, w:29, h:28},{ox:-11, oy:-12, x:113, y:0, w:29, h:27},{ox:-11, oy:-12, x:142, y:0, w:29, h:29},{ox:-11, oy:-12, x:171, y:0, w:29, h:29},{ox:-11, oy:-12, x:200, y:0, w:29, h:28},{ox:-11, oy:-12, x:229, y:0, w:27, h:27},{ox:-11, oy:-13, x:256, y:0, w:28, h:28},{ox:-11, oy:-13, x:284, y:0, w:32, h:31},{ox:-10, oy:-13, x:316, y:0, w:32, h:32},{ox:-11, oy:-13, x:348, y:0, w:31, h:28},{ox:-11, oy:-12, x:379, y:0, w:29, h:27},{ox:-11, oy:-12, x:408, y:0, w:30, h:27},{ox:-11, oy:-11, x:438, y:0, w:32, h:28},{ox:-11, oy:-11, x:470, y:0, w:33, h:31},{ox:-11, oy:-11, x:503, y:0, w:30, h:28},{ox:-11, oy:-13, x:533, y:0, w:31, h:28},{ox:-11, oy:-14, x:564, y:0, w:34, h:29},{ox:-11, oy:-15, x:598, y:0, w:35, h:30},{ox:-11, oy:-17, x:633, y:0, w:36, h:32},{ox:-11, oy:-18, x:669, y:0, w:35, h:33}];
			animations['rest'] = {frames:getFrames(frames, atlas_rest), chain:[0,0,1,1,2,2,3,3,4,4,5,5,6,6,7,7,8,8,9,9,10,10,11,11,12,12,13,13,14,14,15,15,16,16,17,17,18,18,19,19,20,20,21,21,22,22,21,21,20,20,19,19,18,18,17,17,16,16,15,15,14,14,13,13,12,12,11,11,10,10,9,9,8,8,7,7,6,6,5,5,4,4,3,3,2,2,1,1]};
			
			
			animations = constructAnimation(animations);
			
			
			atlas_stop_pause.dispose();
			atlas_stop_pause = null;
			atlas_walk_back.dispose();
			atlas_walk_back = null;
			atlas_rest1.dispose();
			atlas_rest1 = null;
			atlas_walk.dispose();
			atlas_walk = null;
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