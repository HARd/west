package 
{
	import flash.display.Sprite;
	import flash.system.Security;
	import flash.display.BitmapData;
	
	public class oats extends Sprite 
	{
		Security.allowDomain("*");
		Security.allowInsecureDomain("*");

		
		[Embed(source="sprites/Oats1.png", mimeType="image/png")]
		private var Stage0:Class;

		[Embed(source="sprites/Oats2.png", mimeType="image/png")]
		private var Stage1:Class;

		[Embed(source="sprites/Oats3.png", mimeType="image/png")]
		private var Stage2:Class;

		
		public var sprites:Array = [
			{
				bmp:new Stage0().bitmapData,
				dx:-42,
				dy:1
			},
			{
				bmp:new Stage1().bitmapData,
				dx:-52,
				dy:-38
			},
			{
				bmp:new Stage2().bitmapData,
				dx:-57,
				dy:-50
			}
		];
 
		
		
		
		public function oats()
		{
			
		}
		
		public var shadow:Array = [];	// {bmd,x,y,width,height,alpha}
		
		public function getLevel(level:int = 0):Object
		{
			return sprites[level];
		}
	}
}
