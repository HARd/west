package wins
{
	
	import core.Numbers;
	import flash.display.Sprite;
	import wins.elements.ShopItem;
	import wins.elements.ShopItemNew;
	
	public class ShopFilterWindow extends Window 
	{
		
		private var container:Sprite;
		
		private var count:int;
		private var items:Vector.<ShopItemNew>;
		
		public function ShopFilterWindow(settings:Object=null) 
		{
			if (!settings) settings = { };
			
			count = Numbers.countProps(settings.content)
			
			settings.height = 360;
			settings.width = 240 + count * 180;
			settings.hasPaginator = false;
			settings.hasButtons = false;
			
			items = new Vector.<ShopItemNew>;
			
			super(settings);
			
		}
		
		override public function drawBody():void {
			
			container = new Sprite();
			bodyContainer.addChild(container);
			
			contentChange();
			
		}
		
		override public function contentChange():void {
			
			clear();
			
			if (!settings.content || !(settings.content is Array))
				settings.content = [];
			
			for (var i:int = 0; i < settings.content.length; i++) {
				var item:ShopItemNew = new ShopItemNew(settings.content[i], this);
				
				item.x = 180 * container.numChildren;
				item.onBuyAction = onBuyAction;
				container.addChild(item);
				
				items.push(item);
			}
			
			container.x = settings.width * 0.5 - container.width * 0.5;
			container.y = 40;
		}
		
		private function clear():void {
			var item:*;
			
			while (items && items.length) {
				item = items.shift();
				item.dispose();
				
				if (item.parent.contains(item))
					item.parent.removeChild(item);
			
			}
		}
		
		public function onBuyAction(sid:*):void {
			settings.onBuyAction(sid);
		}
		
		override public function dispose():void {
			super.dispose();
			clear();
		}
		
	}

}