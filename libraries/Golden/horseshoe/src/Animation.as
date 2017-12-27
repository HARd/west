package 
{
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public class Animation 
	{
		public var animations:Object = { };
		
		public var ax:int = -5;
		public var ay:int = -37;

		
		[Embed(source="sprites/sprite.png", mimeType="image/png")]
		private var Sprite:Class;
		
		public function Animation(){
		
			var frames:Array;
			var atlas:BitmapData = new Sprite().bitmapData;
			
			
			frames = [{ox:-18, oy:-67, x:0, y:0, w:42, h:68},{ox:-18, oy:-67, x:42, y:0, w:42, h:68},{ox:-19, oy:-67, x:84, y:0, w:44, h:68},{ox:-19, oy:-67, x:128, y:0, w:44, h:68},{ox:-20, oy:-67, x:172, y:0, w:46, h:68},{ox:-20, oy:-67, x:218, y:0, w:46, h:68},{ox:-21, oy:-67, x:264, y:0, w:48, h:68},{ox:-21, oy:-67, x:312, y:0, w:48, h:68},{ox:-22, oy:-67, x:360, y:0, w:49, h:68},{ox:-22, oy:-67, x:409, y:0, w:50, h:68},{ox:-22, oy:-67, x:459, y:0, w:50, h:68},{ox:-23, oy:-67, x:509, y:0, w:51, h:68},{ox:-23, oy:-67, x:560, y:0, w:52, h:68},{ox:-23, oy:-67, x:612, y:0, w:52, h:68},{ox:-24, oy:-67, x:664, y:0, w:53, h:68}];
			animations['anim'] = {frames:getFrames(frames, atlas), chain:[0,0,0,1,1,1,2,2,2,3,3,3,4,4,4,5,5,5,6,6,6,7,7,7,8,8,8,9,9,9,10,10,10,11,11,11,12,12,12,13,13,13,14,14,14,14,14,14,13,13,13,12,12,12,11,11,11,10,10,10,9,9,9,8,8,8,7,7,7,6,6,6,5,5,5,4,4,4,3,3,3,2,2,2,1,1,1,0,0,0]};

			
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
