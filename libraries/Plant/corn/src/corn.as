package 
{
	import flash.display.Sprite;
	import flash.system.Security;
	import flash.display.BitmapData;
	
	public class corn extends Sprite 
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
				dx:-38,
				dy:-25
			},
			{
				bmp:new Stage1().bitmapData,
				dx:-50,
				dy:-68
			},
			{
				bmp:new Stage2().bitmapData,
				dx:-56,
				dy:-80
			}
		];
 
		
		
		
		public function corn()
		{
			
		}
		
		public var shadow:Array = [];	// {bmd,x,y,width,height,alpha}
		
		public function getLevel(level:int = 0):Object
		{
			return sprites[level];
		}
	}
}
