package 
{
	import flash.display.Sprite;
	import flash.system.Security;
	import flash.display.BitmapData;
	
	public class ctree9 extends Sprite 
	{
		Security.allowDomain("*");
		Security.allowInsecureDomain("*");

		
		[Embed(source="sprites/medium-green.png", mimeType="image/png")]
		private var Stage0:Class;

		
		public var sprites:Array = [
			{
				bmp:new Stage0().bitmapData,
				dx:-74,
				dy:-202
			}
		];
 
		
		
		
		public function ctree9()
		{
			
		}
		
		public var shadow:Array = [];	// {bmd,x,y,width,height,alpha}
		
		public function getLevel(level:int = 0):Object
		{
			return sprites[level];
		}
	}
}
