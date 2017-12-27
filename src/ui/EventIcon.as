package ui 
{
	import buttons.ImagesButton;
	import core.Load;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import wins.Window;
	
	public class EventIcon extends LayerX 
	{
		
		private var bg:Bitmap;
		private var bgBMD:BitmapData;
		private var iconBMD:BitmapData;
		public var imageBttn:ImagesButton;
		private var timerlabel:TextField;
		
		public var params:Object = {
			width:		100,
			height:		100
		}
		
		public var onClick:Function = null;
		public var endTime:int = 0;
		
		public function EventIcon(params:Object = null) 
		{
			if (!params) params = { };
			for (var s:String in params) this.params[s] = params[s];
			
			endTime = Events.timeOfComplete || 0;
			
			if (this.params.hasOwnProperty('endTime')) {
				endTime = this.params.endTime;
			}
			
			bg = new Bitmap(new BitmapData(this.params.width, this.params.height, true, 0));
			addChild(bg);
			
			if (this.params.hasOwnProperty('background')) {
				Load.loading(Config.getImage('content', this.params.background), function(data:Bitmap):void {
					bgBMD = data.bitmapData;
					draw();
				});
			}else {
				bgBMD = new BitmapData(this.params.width, this.params.height, true, 0);
			}
			
			if (this.params.hasOwnProperty('icon')) {
				Load.loading(Config.getImage('content', this.params.icon), function(data:Bitmap):void {
					iconBMD = data.bitmapData;
					draw();
				});
			}
			
			if (params.hasOwnProperty('onClick') && params.onClick != null) {
				onClick = params.onClick;
			}
			
			addEventListener(Event.REMOVED_FROM_STAGE, dispose);
			
		}
		
		private function draw():void {
			if (bgBMD) {
				if (!imageBttn) {
					imageBttn = new ImagesButton(bgBMD, (iconBMD) ? iconBMD : null);
					imageBttn.addEventListener(MouseEvent.CLICK, mouseClick);
					addChild(imageBttn);
					
					timerlabel = Window.drawText('', {
						fontSize:			22,
						width:				105,
						textAlign:			'center',
						color:				0xfffaf7,
						borderColor:		0x232b50
					});
					timerlabel.x = (bg.width - timerlabel.width) / 2;
					timerlabel.y = bg.height - timerlabel.height;
					addChild(timerlabel);
					
					App.self.setOnTimer(timer);
				}
				
				if (iconBMD) {
					imageBttn.icon = iconBMD;
				}
			}
		}
		
		private function timer():void {
			if (endTime - App.time >= 0 && timerlabel) {
				timerlabel.text = TimeConverter.timeToDays(endTime - App.time);
			} else {
				App.ui.upPanel.deleteEventButton();
				App.user.checkTop();
			}
		}
		
		public function mouseClick(e:MouseEvent = null):void {
			if (onClick != null) onClick();
		}
		
		public function dispose(e:Event = null):void {
			if (imageBttn && onClick != null) {
				imageBttn.removeEventListener(MouseEvent.CLICK, mouseClick);
			}
			
			App.self.setOffTimer(timer);
			removeEventListener(Event.REMOVED_FROM_STAGE, dispose);
		}
	}
}