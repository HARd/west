package 
{
	import flash.display.Sprite;
	import flash.system.Security;
	import flash.display.BitmapData;
	
	public class hut extends Sprite 
	{
		Security.allowDomain("*");
		Security.allowInsecureDomain("*");

		
		[Embed(source="sprites/hut-working-in-western_1.png", mimeType="image/png")]
		private var Stage0:Class;

		[Embed(source="sprites/hut-working-in-western_3.png", mimeType="image/png")]
		private var Stage1:Class;

		[Embed(source="sprites/hut-working-in-western_2.png", mimeType="image/png")]
		private var Stage2:Class;

		
		public var sprites:Array = [
			{
				bmp:new Stage0().bitmapData,
				dx:-151,
				dy:-110
			},
			{
				bmp:new Stage1().bitmapData,
				dx:-155,
				dy:-110
			},
			{
				bmp:new Stage2().bitmapData,
				dx:-156,
				dy:-110
			}
		];
 
		
		
		
		public function hut()
		{
			
		}
		
		public var shadow:Array = [];	// {bmd,x,y,width,height,alpha}
		
		public function getLevel(level:int = 0):Object
		{
			return sprites[level];
		}
	}
}
