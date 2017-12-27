package wins 
{
	import flash.events.MouseEvent;
	/**
	 * ...
	 * @author 
	 */
	public class BuildingWindow extends Window
	{
		
		public function BuildingWindow(settings:Object) 
		{
			super(settings);
			scale = App.map.scaleX;
			target = settings.target;
		}
		
		private var target:*
		private var scale:Number;
		public function focusAndShow():void 
		{
			App.map.focusedOnCenter(target, false, function():void{
				target.visible = false;
				show();
			}, true, 1, true, 0.5);
		}
		
		public override function close(e:MouseEvent = null):void {
			unfocus();
			super.close();
		}
		
		public function unfocus():void 
		{
			if(scale != 1)
				App.map.focusedOnCenter(target, false, null, true, scale, true, 0.3);
				
			target = null;
			scale = 1;
		}
	}
}