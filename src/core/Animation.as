package core
{
	
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.display.BitmapData;
	
	public class Animation 
	{
		
		public function Animation() 
		{
			
		}
		
		public static function getFrames(atlas:*, animation:*):Object
		{
			var frames = new Object();
			
			for (var move:String in animation)
			{
				var data:Array = []	
				for (var frame in animation[move])
				{
					if (animation[move][frame] == "empty")
					{
						data.push( { bmd:null, xo:0, yo:0 } );
					}
					else
					{
						var frame:Object = animation[move][frame];
						var x:int = frame.x
						var y:int = frame.y
						var w:int = frame.w
						var h:int = frame.h
						
						var ox:int = frame.ox
						var oy:int = frame.oy
						
						var bmd = getBitmap(atlas, new Rectangle(x, y, w, h));
						data.push( { bmd:bmd, ox:ox, oy:oy, w:w, h:h } );
					}
				}
				
				var direction:int = 0;
				
				var part1:String = move.slice(0, 5);
				if (part1 == "back_")
				{
					move = move.slice(5, move.length);
					direction = 1;
				}
				
				if (frames[move] == null)
				{
					frames[move] = [null, null];
				}
				
				frames[move][direction] = data;
			}
			
			return frames;
		}
		
		private static function getBitmap(atlas:BitmapData, rect:Rectangle):BitmapData
		{
			var bmd:BitmapData = new BitmapData(rect.width, rect.height);
			bmd.copyPixels(atlas, rect, new Point(0, 0));
			return bmd;
		}
		
		public static function getSequence(animation:Object):Object
		{
			var sequence:Object = new Object
			for (var move in animation)
			{
				sequence[move] = [null, null];
				
				for (var direction in animation[move])
				{
					var data = [];
					if (animation[move][direction] != null)
					{
						for (var i:int = 0; i < animation[move][direction].length; i++)
						{
							data.push(i);
						}
						sequence[move][direction] = data;
					}
					else
					{
						sequence[move][direction] = null;
					}
				}
			}
			return sequence;
		}
		
	}

}