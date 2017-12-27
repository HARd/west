package ui
{
	import buttons.ContextBttn;
	import com.greensock.easing.Cubic;
	import com.greensock.TweenLite;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import units.Unit;
	
	public class ContextMenu extends Sprite 
	{
		
		public static var comtextMenu:ContextMenu;
		
		public var menuMargin:int = 0;
		public var content:Array = [];
		public var target:Unit;
		public var items:Vector.<ContextBttn> = new Vector.<ContextBttn>;
		
		public function ContextMenu(target:Unit, content:Array):void
		{
			this.content = content;
			this.target = target;
			
			create();
			
			App.self.addEventListener(AppEvent.ON_MAP_CLICK, onMapClick);
		}
		
		public function create():void
		{
			var X:int = 0;
			var Y:int = menuMargin;
			
			for each(var obj:Object in content) {
				var contextBttn:ContextBttn = new ContextBttn(obj);
				contextBttn.addEventListener(MouseEvent.MOUSE_UP, onClick, false, 10);
				contextBttn.x = -contextBttn.width / 2;
				contextBttn.y = Y - contextBttn.height;
				
				addChild(contextBttn);
				items.push(contextBttn);
				
				Y = contextBttn.y - 2;
				obj['contextBttn'] = contextBttn;
			}
		}
		
		private function onClick(e:MouseEvent):void {
			for (var i:int = 0; i < content.length; i++) {
				var contextBttn:ContextBttn = e.currentTarget as ContextBttn;
				if (content[i].sid == contextBttn.sid && content[i].hasOwnProperty('callback') && (content[i].callback is Function) && content[i].callback != null) {
					if (content[i]['callbackParams']) {
						content[i].callback(content[i].callbackParams);
					}else {
						content[i].callback();
					}
				}
			}
			
			onMapClick();
			
			e.stopImmediatePropagation();
		}
		
		public function onMapClick(e:AppEvent = null):void {
			if (comtextMenu) {
				comtextMenu.hide();
				comtextMenu = null;
			}
		}
		
		public function show():void {
			onMapClick();
			
			if (!target.bounds) target.countBounds();
			this.x = target.x + target.bounds.x + target.bounds.w / 2;
			this.y = target.y + target.bounds.y;
			this.alpha = 0;
			
			App.map.mTreasure.addChild(this);
			comtextMenu = this;
			
			TweenLite.to(this, 0.3, {alpha:1, y:target.y + target.bounds.y - 20, ease:Cubic.easeOut} );
		}
		
		public function dispose():void {
			App.self.removeEventListener(AppEvent.ON_MAP_CLICK, onMapClick);
			App.map.mTreasure.removeChild(this);
			content = [];
			
			while (items.length) {
				var item:ContextBttn = items.shift();
				item.removeEventListener(MouseEvent.CLICK, onClick);
				item.dispose();
			}
		}
		
		public function hide():void {
			var posY:int = this.y + 10;
			TweenLite.to(this, 0.15, { y:posY, alpha:0, ease:Cubic.easeOut, onComplete:function():void {
				dispose();
			}});
		}
		
	}
}