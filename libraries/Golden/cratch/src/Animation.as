package 
{
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public class Animation 
	{
		public var animations:Object = { };
		
		public var ax:int = 33;
		public var ay:int = -7;

		
		[Embed(source="sprites/sprite.png", mimeType="image/png")]
		private var Sprite:Class;
		
		public function Animation(){
		
			var frames:Array;
			var atlas:BitmapData = new Sprite().bitmapData;
			
			
			frames = [{ox:1, oy:3.5, x:0, y:0, w:43, h:56},{ox:1, oy:3.5, x:43, y:0, w:43, h:56},{ox:1, oy:3.5, x:86, y:0, w:43, h:56},{ox:1, oy:3.5, x:129, y:0, w:43, h:56},{ox:1, oy:3.5, x:172, y:0, w:43, h:56},{ox:1, oy:3.5, x:215, y:0, w:43, h:56},{ox:1, oy:3.5, x:258, y:0, w:43, h:56},{ox:1, oy:3.5, x:301, y:0, w:43, h:56},{ox:1, oy:3.5, x:344, y:0, w:43, h:56},{ox:1, oy:3.5, x:387, y:0, w:43, h:56},{ox:1, oy:3.5, x:430, y:0, w:43, h:56},{ox:1, oy:3.5, x:473, y:0, w:43, h:56}];
			animations['anim'] = {frames:getFrames(frames, atlas), chain:[0,0,0,1,1,1,2,2,2,3,3,3,4,4,4,5,5,5,6,6,6,7,7,7,8,8,8,9,9,9,10,10,10,11,11,11]};

			
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
