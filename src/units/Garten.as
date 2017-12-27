package units 
{
	import wins.GartenWindow;
	public class Garten extends Stall 
	{
		
		public function Garten(object:Object) 
		{
			super(object);
			
		}
		
		override public function openProductionWindow():void {	
			new GartenWindow( {
				target:		this
			}).show();
		}
		
	}

}