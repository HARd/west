package wins 
{
	import buttons.Button;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	public class BuyTwoItemsWindow extends Window 
	{
		private var price:Object = { };
		private var bttn:Button;
		public function BuyTwoItemsWindow(settings:Object=null) 
		{
			if (!settings) settings = { };
			
			settings['height'] = 380;
			settings['hasPaginator'] = false;
			settings['title'] = Locale.__e('flash:1382952379970');
			
			price = settings['price'];
			
			super(settings);
		}
		
		override public function drawBody():void {
			contentChange();
			
			bttn = new Button( {  width:194, height:53, caption:Locale.__e('flash:1412930855334') } );
			bodyContainer.addChild(bttn);
			bttn.x = (settings.width - bttn.width) / 2;
			bttn.y = settings.height - bttn.height - 35;
			bttn.addEventListener(MouseEvent.CLICK, onClick);
			bttn.state = Button.DISABLED;
		}
		
		public function onClick(e:MouseEvent):void {
			if (settings.callback) settings.callback();
			close();
		}
		
		private var items:Array;
		private var itemsContainer:Sprite = new Sprite();
		override public function contentChange():void {
			if (items) {
				for each(var _item:* in items) {
					itemsContainer.removeChild(_item);
					_item.dispose();
				}
			}
			items = [];
			
			bodyContainer.addChild(itemsContainer);
			var target:*;
			var X:int = 0;
			var Xs:int = X;
			var Ys:int = 50;
			itemsContainer.x = 92;
			itemsContainer.y = Ys;
			
			for (var sID:* in price)
			{
				var item:MaterialItem = new MaterialItem( {
					sID:sID,
					need:price[sID],
					window:this, 
					type:MaterialItem.IN,
					bitmapDY: -10
				});
				item.x = Xs;
				items.push(item);
				itemsContainer.addChild(item);
				item.addEventListener(WindowEvent.ON_CONTENT_UPDATE, onUpdateOutMaterial);
				
				Xs += item.width + 20;
			}
			
		}
		
		public function onUpdateOutMaterial(e:WindowEvent = null):void {
			var outState:int = MaterialItem.READY;
			for each(var item:* in items) {
				if(item.status != MaterialItem.READY){
					outState = item.status;
				}
			}		
			
			if (outState == MaterialItem.UNREADY) 
				bttn.state = Button.DISABLED;
			else if (outState != MaterialItem.UNREADY)
				bttn.state = Button.NORMAL;
			
		}
		
		public override function dispose():void {
			if (items) {
				for each(var _item:* in items) {
					itemsContainer.removeChild(_item);
					_item.dispose();
				}
			}
			items = [];
			
			super.dispose();
		}
		
	}

}