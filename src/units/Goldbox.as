package units 
{
	import wins.SimpleWindow;
	/**
	 * ...
	 * @author 
	 */
	public class Goldbox extends Resource
	{
		
		public function Goldbox(object:Object) 
		{
			super(object);
			
			moveable = true;
			
			tip = function():Object {
				return {
					title:info.title,
					text:info.description
				};
			};
		}
		
		override public function click():Boolean 
		{	
			if (App.user.mode == User.GUEST)
				return true;
			
			if (capacity <= 0)
				return true;
				
			if (!canTake()) return true;
			
			onTakeResourceEvent();
			
			return true;
		}
		
		public function canTake():Boolean
		{	
			if (info.level > App.user.level) {
				new SimpleWindow( {
					title:Locale.__e('flash:1396606807965', [info.level]),
					text:Locale.__e('flash:1396606823071'),
					label:SimpleWindow.ERROR
				}).show();
				
				return false;
			}
			return true;
		}
		
	}

}
