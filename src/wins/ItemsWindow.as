package wins 
{
	import com.greensock.easing.Back;
	import com.greensock.TweenLite;
	import core.IsoConvert;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.utils.setTimeout;
	import ui.SystemPanel;
	/**
	 * ...
	 * @author 
	 */
	public class ItemsWindow extends Sprite
	{
		public static var isOpen:Boolean = false;
		
		public var settings:Object;
		public var container:Sprite = new Sprite();
		
		private var items:Array = [];
		
		
		
		public function ItemsWindow(settings:Object) 
		{
			if (settings == null) {
				settings = new Object();
			}
			
			settings['totalItems'] = settings.totalItems || 6;
			settings['items'] = settings.items || 3;
			
			
			this.settings = settings;
			
			App.self.addEventListener(AppEvent.ON_MOUSE_DOWN, onClick, false, 500);
		}
		
		private function onClick(e:AppEvent):void 
		{
			e.stopImmediatePropagation();
			dispose();
		}
		
		private function createItems():void 
		{
			var posX:int = -250;
			var posY:int = -75;
			var time:Number = 0.4;
			
			for (var i:int = 0; i < settings.totalItems; i++ ) {
				var item:Item = new Item({});
				
				item.alpha = 0;
				container.addChild(item);
				
				TweenLite.to(item, time, {x:posX, y:posY, scaleX:1, scaleY:1, alpha:1, ease:Back.easeOut});
				
				switch(i) {
					case 0:
						item.x = posX + item.width;
						item.y = posY;
						
						posX += item.width - item.width/3;
						posY -= item.height;
					break;
					case 1:
						item.x = posX + item.width;
						item.y = posY + item.height*0.8;
					
						posX += item.width;
						posY -= item.height / 2;
					break;
					case 2:
						item.x = posX;
						item.y = posY + item.height*0.7;
					
						posX += item.width + 12;
						//posY += item.height / 2;
					break;
					case 3:
						item.x = posX - item.width;
						item.y = posY + item.height;
						
						posX += item.width/* / 2;*/
						posY += item.height / 2;
					break;
					case 4:
						item.x = posX - item.width;
						item.y = posY;
						
						posX += item.width / 2 + 14;
						posY += item.height;
					break;
					case 5:
						item.x = posX - item.width;
						item.y = posY;
					break;
				}
				
				item.scaleX = item.scaleY = 0.8;
				
				items.push(item);
			}
		}
		
		public function show():void
		{
			if(!App.self.windowContainer.contains(container)){
				App.self.windowContainer.addChild(container);
			}
			
			
			SystemPanel.scaleValue = 1;
			App.map.focusedOn(settings.target, false, function():void {
				
				createItems();
			
				settings.target.pluck(10, settings.target.x, settings.target.y - settings.target.bitmap.x);
				
				var centerX:int = settings.target.x + App.map.x + settings.target.bitmap.x + settings.target.bitmap.width / 2;
				var centerY:int = settings.target.y + App.map.y + settings.target.bitmap.y + settings.target.bitmap.height / 2;
			
				container.x = centerX;
				container.y = centerY;
				
				isOpen = true;
			}, true, 1, true, 0.5);
		}
		
		public function dispose():void
		{
			App.self.removeEventListener(AppEvent.ON_MOUSE_DOWN, onClick);
			
			for (var i:int = 0; i < items.length; i++ ) {
				var item:Item = items[i];
				item.dispose();
				item = null;
			}
			items = [];
			
			if(App.self.windowContainer.contains(container)){
				App.self.windowContainer.removeChild(container);
			}
			
			container = null;
			
			setTimeout(function():void { ItemsWindow.isOpen = false; }, 200);
		}
		
	}

}

import flash.display.Bitmap;
import flash.display.Sprite;
import flash.events.MouseEvent;
import wins.Window;

internal class Item extends Sprite {
	
	public var isActive:Boolean = false;
	
	public function Item(settings:Object) {
		
		drawBg();
		
		isActive = true;//для теста, сделать чтобы если есть контент, то активно, если нету, то нет
		
		addEventListener(MouseEvent.MOUSE_DOWN, onClick, false, 1000);
	}
	
	private function onClick(e:MouseEvent):void 
	{
		if(isActive)
			e.stopImmediatePropagation();
	}
	
	private function drawBg():void 
	{
		var bg:Bitmap = new Bitmap(Window.textures.buildingsSlot);
		addChild(bg);
	}
	
	public function dispose():void
	{
		removeEventListener(MouseEvent.MOUSE_DOWN, onClick);
		
		if (this.parent)
			this.parent.removeChild(this);
	}
}
