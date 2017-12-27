package 
{
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public class Animation 
	{
		public var animations:Object = { };
		
		public var ax:int = 1;
		public var ay:int = -25;

		
		[Embed(source="sprites/sprite.png", mimeType="image/png")]
		private var Sprite:Class;
		
		public function Animation(){
		
			var frames:Array;
			var atlas:BitmapData = new Sprite().bitmapData;
			
			
			frames = [{ox:-39, oy:-56.5, x:0, y:0, w:77, h:87},{ox:-39, oy:-56.5, x:77, y:0, w:77, h:87},{ox:-39, oy:-56.5, x:154, y:0, w:77, h:87},{ox:-39, oy:-56.5, x:231, y:0, w:77, h:87},{ox:-39, oy:-56.5, x:308, y:0, w:77, h:87},{ox:-39, oy:-56.5, x:385, y:0, w:77, h:87},{ox:-39, oy:-56.5, x:462, y:0, w:77, h:87},{ox:-39, oy:-56.5, x:539, y:0, w:77, h:87},{ox:-39, oy:-56.5, x:616, y:0, w:77, h:87},{ox:-39, oy:-56.5, x:693, y:0, w:77, h:87}];
			animations['anim'] = {frames:getFrames(frames, atlas), chain:[0,0,0,1,1,1,2,2,2,3,3,3,4,4,4,5,5,5,6,6,6,7,7,7,8,8,8,9,9,9]};

			
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
