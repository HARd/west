package 
{
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public class Animation 
	{
		public var animations:Object = { };
		
		public var ax:int = -56;
		public var ay:int = -37;

		
		[Embed(source="sprites/sprite.png", mimeType="image/png")]
		private var Sprite:Class;
		
		public function Animation(){
		
			var frames:Array;
			var atlas:BitmapData = new Sprite().bitmapData;
			
			
			frames = [{ox:18, oy:67.5, x:0, y:0, w:42, h:57},{ox:18, oy:67.5, x:42, y:0, w:41, h:57},{ox:18, oy:68.5, x:83, y:0, w:41, h:56},{ox:18, oy:67.5, x:124, y:0, w:41, h:57},{ox:18, oy:67.5, x:165, y:0, w:42, h:57},{ox:18, oy:67.5, x:207, y:0, w:41, h:57},{ox:18, oy:67.5, x:248, y:0, w:41, h:57},{ox:18, oy:68.5, x:289, y:0, w:41, h:56},{ox:18, oy:67.5, x:330, y:0, w:42, h:57}];
			animations['anim'] = {frames:getFrames(frames, atlas), chain:[0,0,0,1,1,1,2,2,2,3,3,3,4,4,4,5,5,5,6,6,6,7,7,7,8,8,8]};

			
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
