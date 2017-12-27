package 
{
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public class Animation 
	{
		public var animations:Object = { };
		
		public var ax:int = 9;
		public var ay:int = -28;

		
		[Embed(source="sprites/sprite.png", mimeType="image/png")]
		private var Sprite:Class;
		
		public function Animation(){
		
			var frames:Array;
			var atlas:BitmapData = new Sprite().bitmapData;
			
			
			frames = [{ox:-71, oy:46.5, x:0, y:0, w:27, h:13},{ox:-71, oy:46.5, x:27, y:0, w:27, h:13},{ox:-70, oy:46.5, x:54, y:0, w:26, h:27},{ox:-70, oy:46.5, x:80, y:0, w:26, h:27},{ox:-70, oy:37.5, x:106, y:0, w:26, h:30},{ox:-70, oy:30.5, x:132, y:0, w:26, h:37},{ox:-71, oy:23.5, x:158, y:0, w:28, h:36},{ox:-71, oy:19.5, x:186, y:0, w:28, h:40},{ox:-71, oy:17.5, x:214, y:0, w:28, h:42},{ox:-70, oy:17.5, x:242, y:0, w:27, h:42},{ox:-70, oy:16.5, x:269, y:0, w:27, h:43},{ox:-70, oy:18.5, x:296, y:0, w:27, h:41},{ox:-71, oy:22.5, x:323, y:0, w:28, h:37},{ox:-71, oy:26.5, x:351, y:0, w:28, h:33},{ox:-71, oy:32.5, x:379, y:0, w:27, h:27},{ox:-71, oy:39.5, x:406, y:0, w:28, h:38},{ox:-71, oy:41.5, x:434, y:0, w:27, h:32},{ox:-71, oy:46.5, x:461, y:0, w:27, h:13},{ox:-71, oy:46.5, x:488, y:0, w:27, h:13}];
			animations['anim'] = {frames:getFrames(frames, atlas), chain:[0,0,0,1,1,1,2,2,2,3,3,3,4,4,4,5,5,5,6,6,6,7,7,7,8,8,8,9,9,9,10,10,10,11,11,11,12,12,12,13,13,13,14,14,14,15,15,15,16,16,16,17,17,17,18,18,18]};

			
			atlas.dispose();
			atlas = null;
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
		
		
	}
}
