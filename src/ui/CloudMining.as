package ui 
{
	import flash.events.MouseEvent;
	import units.Mining;
	
	/**
	 * ...
	 * @author ...
	 */
	public class CloudMining extends Cloud
	{
		private var _parentClass:Mining;
		
		public function CloudMining(parentClass:Mining, type:String, params:Object = null)
		{
			super(type, params);
			_parentClass = parentClass;
			//addEventListener(MouseEvent.CLICK, onCloud);
		}
		
		private function onCloud(e:MouseEvent):void 
		{
			_parentClass.cloudMining(false);
		}
		
		
	}	
}