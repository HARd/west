package wins.elements 
{
	import flash.utils.getDefinitionByName;
	import flash.display.Sprite;
	/**
	 * ...
	 * @author 
	 */
	public class ContentManager extends Sprite
	{
		public var itemType:String = '';
		public var content:Array = [];
		private var settings:Object = {
			from:0,
			to:2,
			cols:2,
			margin:10,
			padding:10
		};
		
		public function ContentManager(settings:Object) {
			for (var prop:* in settings) {
				this.settings[prop] = settings[prop];
			}
			itemType = settings.itemType;
			content = settings.content;
		}
		
		public function update(_from:int,_to:int):void {
			var i:int = 0;
			for (i = numChildren-1; i >= 0; i-- ) {
				removeChild(getChildAt(i));
			}
			var clName:String = 'wins.elements.' + itemType;
			var itemClass:Class = getDefinitionByName(clName) as Class;
			for (i = _from; i < _to; i++ ) {
				content[i]['pagePos'] = i - _from;
				var item:* = new itemClass(content[i]);
				item.x = settings.padding + ((i - _from) % settings.cols) * (item.width+settings.margin);
				item.y = settings.padding + int((i - _from) / settings.cols) * (item.getHeight()+settings.margin);
				
				addChild(item);
			}
		}
	}
}