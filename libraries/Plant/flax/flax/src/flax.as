package 
{
	import flash.display.Sprite;
	import flash.system.Security;
	import flash.display.BitmapData;
	
	public class flax extends Sprite 
	{
		Security.allowDomain("*");
		Security.allowInsecureDomain("*");

		
		[Embed(source="sprites/stg_1.png", mimeType="image/png")]
		private var Stage0:Class;

		[Embed(source="sprites/stg_2.png", mimeType="image/png")]
		private var Stage1:Class;

		[Embed(source="sprites/stg_3.png", mimeType="image/png")]
		private var Stage2:Class;

		
		public var sprites:Array = [
			{
				bmp:new Stage0().bitmapData,
				dx:-36,
				dy:-1
			},
			{
				bmp:new Stage1().bitmapData,
				dx:-40,
				dy:-23
			},
			{
				bmp:new Stage2().bitmapData,
				dx:-41,
				dy:-39
			}
		];
 
		
		
		
		public function flax()
		{
			
		}
		
		public var shadow:Array = [];	// {bmd,x,y,width,height,alpha}
		
		public function getLevel(level:int = 0):Object
		{
			return sprites[level];
		}
	}
}
