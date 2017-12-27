package ui 
{
	import com.greensock.easing.Linear;
	import flash.events.Event;
	import units.Field;
	import units.Unit;
	
	public class PlantMenu extends ContextMenu 
	{
		
		public var progressBar:ProgressBar;
		public var field:Field;
		
		public function PlantMenu(target:Unit, content:Array):void
		{
			
			field = target as Field;
			
			if (field.plant != null && field.plant.planted + field.plant.info.levels * field.plant.info.levelTime > App.time) { 
				progressBar = new ProgressBar(field.plant.info.levels * field.plant.info.levelTime, 0, {
					auto:		false,
					textUpdate:	true,
					ease:		Linear.easeNone
				});
				progressBar.x = -progressBar.width / 2 + 17;
				progressBar.y = -progressBar.height;
				progressBar.start((App.time - field.plant.planted) / (field.plant.planted + field.plant.info.levels * field.plant.info.levelTime - field.plant.planted));
				progressBar.addEventListener(Event.COMPLETE, onProgressComplete);
				
				addChild(progressBar);
				
				menuMargin = -22;
			}
			
			super(target, content);
			
		}
		
		private function onProgressComplete(e:Event):void {
			hide();
		}
		
		override public function dispose():void {
			if (progressBar) {
				progressBar.removeEventListener(Event.COMPLETE, onProgressComplete);
				progressBar.dispose();
			}
			
			super.dispose();
		}
	}

}