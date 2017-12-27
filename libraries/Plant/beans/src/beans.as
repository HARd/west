package 
{
	import flash.display.Sprite;
	import flash.system.Security;
	import flash.display.BitmapData;
	
	public class beans extends Sprite 
	{
		Security.allowDomain("*");
		Security.allowInsecureDomain("*");

		
		[Embed(source="sprites/Untitled-3.png", mimeType="image/png")]
		private var Stage0:Class;

		[Embed(source="sprites/Untitled-3 (2).png", mimeType="image/png")]
		private var Stage1:Class;

		[Embed(source="sprites/Untitled-3 (3).png", mimeType="image/png")]
		private var Stage2:Class;

		
		public var sprites:Array = [
			{
				bmp:new Stage0().bitmapData,
				dx:-26,
				dy:-95
			},
			{
				bmp:new Stage1().bitmapData,
				dx:-30,
				dy:-92
			},
			{
				bmp:new Stage2().bitmapData,
				dx:-30,
				dy:-87
			}
		];
 
		
		
		
		public function beans()
		{
			
		}
		
		public var shadow:Array = [];	// {bmd,x,y,width,height,alpha}
		
		public function getLevel(level:int = 0):Object
		{
			return sprites[level];
		}
	}
}
