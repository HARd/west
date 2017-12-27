package units 
{
	import wins.MapWindow;
	/**
	 * ...
	 * @author 
	 */
	public class Conductor extends Bear
	{
		
		public function Conductor(object:Object)
		{
			super(object);
			_framesType = 'wait';
			touchable = true;
			clickable = true;
			moveable = false;
			removable = false;
			rotateable = false;
		}
		
		override public function onLoad(data:*):void {
			super.onLoad(data);
			action = Bear.ACTION_WAIT;
		}
		
		override public function click():Boolean {
			//if (!super.click()) return false;
			
			new MapWindow({ 
					sID:441
				}).show();
			
			return true;
		}
	}
}