package 
{
	import flash.display.Sprite;
	import flash.system.Security;
	import flash.display.BitmapData;
	
	public class kitchen extends Sprite 
	{
		Security.allowDomain("*");
		Security.allowInsecureDomain("*");

		
		[Embed(source="sprites/stage-1.png", mimeType="image/png")]
		private var Stage0:Class;

		[Embed(source="sprites/stage-2.png", mimeType="image/png")]
		private var Stage1:Class;

		[Embed(source="sprites/stage-3.png", mimeType="image/png")]
		private var Stage2:Class;

		[Embed(source="sprites/kitchen1.png", mimeType="image/png")]
		private var Stage3:Class;

		
		public var sprites:Array = [
			{
				bmp:new Stage0().bitmapData,
				dx:-134,
				dy:-27
			},
			{
				bmp:new Stage1().bitmapData,
				dx:-114,
				dy:-68
			},
			{
				bmp:new Stage2().bitmapData,
				dx:-114,
				dy:-68
			},
			{
				bmp:new Stage3().bitmapData,
				dx:-126,
				dy:-83
			}
		];
 
		
		public var animation:Animation = new Animation();
		
		public function kitchen()
		{
			
		}
		
		public var shadow:Array = [];	// {bmd,x,y,width,height,alpha}
		
		public function getLevel(level:int = 0):Object
		{
			return sprites[level];
		}
	}
}
