package wins.elements
{
	import flash.events.MouseEvent;
	import wins.elements.SearchPanel;

	/**
	 * ...
	 * @author ...
	 */
	public class SearchMaterialPanel extends SearchPanel 
	{
		public var content:Array = null
		
		public function SearchMaterialPanel(settings:Object) {
			
			super(settings);
			
		}
		
		override public function onBreakEvent(e:MouseEvent):void {
			searchField.text = "";
			if (settings.stop != null) 
				settings.stop();
		}
		
		override public function search(query:String = "", isCallBack:Boolean = true):Array {
			
			if (query == "") {
				if (settings.stop != null)
					settings.stop();
				return null;	
			}
			
			query = query.toLowerCase();
			
			var result:Array = [];
			var items:Array = settings.win.sections[settings.win.settings.section].items;
			var L:uint = items.length;
			
			for (var i:int = 0; i < L; i++)
			{
				var item:Object = items[i];
				
				if (item.sid == 752 && App.user.stock.data[item.sid] == 0)
					continue;
					
				if (item.title.toLowerCase().indexOf(query) == 0)
					result.push(item);
			}
			
			result.sortOn('order', Array.NUMERIC);
			
			settings.callback(result);
			
			return null;
		}
	}
	
}