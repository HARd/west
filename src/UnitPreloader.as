package 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	public class UnitPreloader extends Sprite 
	{
		[Embed(source="Question_desk.png")]
		private var Question_desk:Class;
		public var desk:BitmapData = new Question_desk().bitmapData;
		
		public var callback:Function = null;
		
		public function UnitPreloader(callback:Function = null) 
		{
			var preloaderPic:Bitmap = new Bitmap(desk);
			preloaderPic.x -= 100;
			preloaderPic.y -= 100;
			addChild(preloaderPic);
			
			if (callback != null) this.callback = callback;
			
			this.addEventListener(MouseEvent.CLICK, onClick);
			this.addEventListener(Event.REMOVED_FROM_STAGE, dispose);
		}
		
		private function onClick(e:MouseEvent):void {
			if (callback != null) callback();
		}
		
		private function dispose(e:Event):void {
			this.removeEventListener(MouseEvent.CLICK, onClick);
			this.removeEventListener(Event.REMOVED_FROM_STAGE, dispose);
		}
		
	}

}