package wins.elements 
{
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.filters.DropShadowFilter;
	import flash.text.TextField;
	import wins.Window;
	/**
	 * ...
	 * @author ...
	 */
	public class StockCounter extends Sprite
	{
		public var counter:TextField;
		public function StockCounter() 
		{
			counter = Window.drawText('0', {
				color:0xffffff,
				borderColor:0x324540,
				fontSize:26,
				textAlign:"center"
			});
			
			var circleSprite:Sprite = new Sprite();
			var bg:Shape = new Shape();
			bg.graphics.beginFill(0xffecd4);
			bg.graphics.drawCircle(0, 0, 26);
			
			var bg2:Shape = new Shape();
			bg.graphics.beginFill(0x9ab3b0);
			bg.graphics.drawCircle(0, 0, 22);
				
			circleSprite.addChild(bg);
			circleSprite.addChild(bg2);
			
			counter.width = bg.width
			
			circleSprite.filters = [new DropShadowFilter(3, 90, 0, 0.5, 6, 6)];
			addChild(circleSprite);
			
			addChild(counter);
			
			counter.x = -bg.width / 2;
			counter.y = -counter.textHeight / 2;
			count = 0;
		}
		
		public var _count:int = 0;
		public function set count(value:int):void {
			if (value == _count)
				return;
				
			_count = value;
			counter.text = String(_count);
			
		}
		
		public function get count():int {
			return int(_count);
		}
	}
}