package 
{
	import flash.display.Sprite;
	import flash.system.Security;
	import flash.display.BitmapData;
	
	public class grass5 extends Sprite 
	{
		Security.allowDomain("*");
		Security.allowInsecureDomain("*");

		
		[Embed(source="sprites/grass5.png", mimeType="image/png")]
		private var Stage0:Class;

		
		public var sprites:Array = [
			{
				bmp:new Stage0().bitmapData,
				dx:-31,
				dy:-50
			}
		];
 
		
		
		
		public function grass5()
		{
			
		}
		
		public var shadow:Array = [];	// {bmd,x,y,width,height,alpha}
		
		public function getLevel(level:int = 0):Object
		{
			return sprites[level];
		}
	}
}
