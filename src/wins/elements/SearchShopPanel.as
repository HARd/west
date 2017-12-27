package wins.elements 
{
	import flash.events.FocusEvent;
	
	/**
	 * ...
	 * @author 
	 */
	public class SearchShopPanel extends SearchMaterialPanel
	{
		public var isFocus:Boolean = false;
		
		public function SearchShopPanel(settings:Object) 
		{
			super(settings);
		}
		
		override public function onFocusEvent(e:FocusEvent):void {
			isFocus = true;
			
			super.onFocusEvent(e);
		}
		
		override public function onUnFocusEvent(e:FocusEvent):void {
			isFocus = false;
			
			super.onUnFocusEvent(e);
		}
		
		override public function search(query:String = "", isCallBack:Boolean = true):Array {
			
			if (query == "") {
				if (settings.stop != null)
					settings.stop();
				
				return null;	
			}
			
			//query = query.toLowerCase();
			
			
			//var result:Array = [];
			//for (var section:* in ShopWindow.shop){
				//for (var i:* in ShopWindow.shop[ShopWindow.history.section].data) {
					//
					//var sid:int = ShopWindow.shop[ShopWindow.history.section].data[i].sid;
					//var item:* = App.data.storage[sid];
					//
					//if (item.title.toLowerCase().indexOf(query) > -1 || String(sid).indexOf(query) > -1) {
						//result.push(item);
					//}
				//}
			//}
			
			//var result:Array = [];
			//var items:Array = settings.win.sections[settings.win.settings.section].items;
			//var L:uint = items.length;
			
			//for (var i:int = 0; i < L; i++)
			//{
				//var item:Object = items[i];
				//
				//if (item.title.toLowerCase().indexOf(query) == 0)
					//result.push(item);
			//}
			
			//result.sortOn('order', Array.NUMERIC);
			
			settings.callback(null);
			
			return null;
		}
		
	}

}