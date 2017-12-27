package 
{
	import flash.display.Sprite;
	import flash.system.Security;
	import flash.display.BitmapData;
	
	public class hut2 extends Sprite 
	{
		Security.allowDomain("*");
		Security.allowInsecureDomain("*");

		
		[Embed(source="sprites/hut-working-in-western_B_2.png", mimeType="image/png")]
		private var Stage0:Class;

		[Embed(source="sprites/hut-working-in-western_B_1.png", mimeType="image/png")]
		private var Stage1:Class;

		[Embed(source="sprites/hut-working-in-western_B_3.png", mimeType="image/png")]
		private var Stage2:Class;

		
		public var sprites:Array = [
			{
				bmp:new Stage1().bitmapData,
				dx:-155,
				dy:-84
			},
			{
				bmp:new Stage2().bitmapData,
				dx:-151,
				dy:-96
			},
			{
				bmp:new Stage0().bitmapData,
				dx:-154,
				dy:-96
			}
		];
 
		
		
		
		public function hut2()
		{
			
		}
		
		public var shadow:Array = [];	// {bmd,x,y,width,height,alpha}
		
		public function getLevel(level:int = 0):Object
		{
			return sprites[level];
		}
	}
}
