package wins.elements 
{
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.text.TextField;
	import wins.Window;
	/**
	 * ...
	 * @author ...
	 */
	public class TimeIcon extends Sprite
	{
		
		public var timeLabel:TextField;
		
		public function TimeIcon(time:int, _width:int = 0) 
		{
			var clock:Bitmap = new Bitmap(Window.textures.timerSmall);
			addChild(clock);
			
			var textSize:int = 21;
			do {
				timeLabel = Window.drawText(TimeConverter.timeToCuts(time, true, true), {
					textAlign:		'center',
					autoSize:       "left",
					multiline:      true,
					color:			0xffffff,
					borderColor:	0x6a3314,
					fontSize:		textSize,
					shadowSize:		1.5
				});
				//if (_width == 0) {
					//_width = timeLabel.textWidth + 4;
				//}
				timeLabel.width = timeLabel.textWidth + 4;//_width;
				textSize--;
			} while (timeLabel.width > _width && _width != 0);
			
			//timeLabel.border = true;
			timeLabel.x = clock.width + 5;
			timeLabel.y = (clock.height - timeLabel.height) / 2 + 4;
			addChild(timeLabel);
			//timeLabel.border = true;
		}
	}
}