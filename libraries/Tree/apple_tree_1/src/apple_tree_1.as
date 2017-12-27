package 
{
	import flash.display.Sprite;
	import flash.system.Security;
	import flash.display.BitmapData;
	
	public class apple_tree_1 extends Sprite 
	{
		Security.allowDomain("*");
		Security.allowInsecureDomain("*");

		
		[Embed(source="sprites/Untitled-3.png", mimeType="image/png")]
		private var Stage0:Class;

		
		public var sprites:Array = [
			{
				bmp:new Stage0().bitmapData,
				dx:-62,
				dy:-153
			},
			{
				bmp:new Stage0().bitmapData,
				dx:-62,
				dy:-153
			},
			{
				bmp:new Stage0().bitmapData,
				dx:-62,
				dy:-153
			}
		];
 
		
		
		
		public function apple_tree_1()
		{
			
		}
		
		public var shadow:Array = [];	// {bmd,x,y,width,height,alpha}
		
		public function getLevel(level:int = 0):Object
		{
			return sprites[level];
		}
	}
}
