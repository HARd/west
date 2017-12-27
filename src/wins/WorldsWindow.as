package wins 
{
	import adobe.utils.CustomActions;
	import buttons.Button;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import wins.elements.WorldItem;
	/**
	 * ...
	 * @author ...
	 */
	public class WorldsWindow extends Window
	{
		
		public var okBttn:Button;
		
		public var only:Array;
		public var parentWindow:*;
		
		public var worldList:Array = [];
		
		public function WorldsWindow(settings:Object = null) 
		{
			if (!settings) settings = { };
			
			settings['width'] = settings['width'] || 350;
			settings['height'] = settings['height'] || 280;
			settings['title'] = settings['title'] || Locale.__e('');
			
			settings['popup'] = settings['popup'] || true;
			settings['hasPaginator'] = settings['hasPaginator'] || true;
			settings['hasButtons'] = settings['hasButtons'] || false;
			settings['itemsOnPage'] = settings['itemsOnPage'] || 3;
			
			if (settings['only'] && (settings['only'] is Array))
				only = settings['only'];
			
			if (settings['window'])
				parentWindow = settings['window'];
			
			init();
			
			super(settings);
		}
		
		private function init():void {
			worldList = only;
		}
		
		override public function drawBackground():void {
			var back:Bitmap = backing2(settings.width, settings.height, 45, "questsSmallBackingTopPiece", 'questsSmallBackingBottomPiece');
			back.x = (settings.width - back.width) / 2;
			back.y = (settings.height - back.height) / 2 - 22;
			bodyContainer.addChildAt(back, 0);
		}
		
		public var container:Sprite;
		override public function drawBody():void {
			
			titleLabel.y += 25;
			
			container = new Sprite();
			container.y = 45;
			bodyContainer.addChild(container);
			
			okBttn = new Button( {
				width:200,
				height:46,
				caption:Locale.__e('flash:1413820223844')
			});
			okBttn.x = (settings.width - okBttn.width) / 2;
			okBttn.y = settings.height - okBttn.height - 5;
			//bodyContainer.addChild(okBttn);
			okBttn.addEventListener(MouseEvent.CLICK, onOk);
			
			paginator.itemsCount = worldList.length;
			paginator.update();
			
			if (worldList.length <= paginator.onPageCount) {
				paginator.visible = false;
			}else {
				paginator.visible = true;
			}
			
			contentChange();
		}
		
		public function onOk(e:MouseEvent):void {
			TravelWindow.show();
			closeAll();
		}
		
		override public function drawArrows():void {
			super.drawArrows();
			
			paginator.arrowLeft.x -= 30;
			paginator.arrowLeft.y += 10;
			paginator.arrowRight.x += 30;
			paginator.arrowRight.y += 10;
		}
		
		private var items:Vector.<WorldItem> = new Vector.<WorldItem>;
		override public function contentChange():void {
			clear();
			
			for (var i:int = 0; i < paginator.onPageCount; i++) {
				if (worldList.length <= i + paginator.page * paginator.onPageCount) continue;
				
				var item:WorldItem = new WorldItem( {
					sID:	worldList[i + paginator.page * paginator.onPageCount],
					window:	this
				});
				item.x = i * 170;
				container.addChild(item);
			}
			
			container.x = (settings.width - container.width) / 2;
		}
		
		public function clear():void {
			while (items.length > 0) {
				var item:WorldItem = items.shift();
				item.dispose();
			}
		}
		
		public function closeAll():void {
			if (parentWindow && parentWindow is Window)
				parentWindow.close();
			
			close();
		}
		
		override public function dispose():void {
			super.dispose();
			
			okBttn.removeEventListener(MouseEvent.CLICK, onOk);
			okBttn.dispose();
		}
		
	}

}