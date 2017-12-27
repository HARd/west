package ui
{
	import buttons.ImageButton;
	import flash.display.BitmapData;
	import flash.events.MouseEvent;
	
	public class IconsMenu extends ContextMenu 
	{
		private var dY:int = 0;
		private var positions:Object = 
		{
			4:[
				{x: -85, y: -50 },
				{x: -30, y: -80 },
				{x: +25, y: -50 },
				{x: -20, y: 90 }
			],
			
			3:[
				{x: -60, y: -70 },
				{x: +0, y: -70 },
				{x: -20, y: 90 }
			],
			
			2:[
				{x: -30, y: -80 },
				{x: -20, y: 90 }
			],
			
			1:[
				{x: -30, y: -80 }
			]
		}
		
		public var icons:Array = []
		
		private var onClose:Function;
		
		public function IconsMenu(target:*, content:Array, onClose:Function = null, dY:int = 0):void
		{
			this.dY = dY;
			this.onClose = onClose;
			super(target, content);
		}
		
		private function createTip(bttn:ImageButton):void
		{
			bttn.tip = function():Object { 
				return {
					title:bttn.settings.description 
			}};
		}
		
		override public function create():void
		{
			var X:int = 0;
			var Y:int = 0;
			
			var length:uint = content.length
			
			for (var i:int = 0; i < content.length; i++)
			{
				var obj:Object = content[i];
				if (obj.icon == null) 
					obj.icon = new BitmapData(1, 1, true, 0x00000000);
				
				var iconBttn:ImageButton = new ImageButton( obj.image, { 
					callback		:obj.callback, 
					description		:obj.description,
					params			:obj.params || { }
				});
				
				iconBttn.name = 'iconMenu';
				
				createTip(iconBttn);
				
				if (i == content.length - 1) {
					dY = 0;
				}
				
				//iconBttn.addEventListener(MouseEvent.MOUSE_DOWN, onClick);
				iconBttn.x = positions[length][i].x;
				iconBttn.y = positions[length][i].y + dY;
				
				icons.push(iconBttn);
				
				obj.contextBttn = iconBttn;
					
				addChild(iconBttn);	
				X += iconBttn.width;
				
				if(obj.hasOwnProperty('scale'))
				{
					iconBttn.scaleX = obj.scale;
					iconBttn.scaleY = obj.scale;
				}
				
				if (!obj.status) iconBttn.alpha = 0.5;
			}
		}
		
		override public function show():void
		{
			this.x = App.map.mouseX - target.mouseX;
			this.y = App.map.mouseY - target.mouseY - 70;
			App.map.mTreasure.addChild(this);
		}
		
		override public function dispose():void
		{
			if (onClose != null) onClose();
			
			//App.self.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			for each(var obj:Object in content)
			{
				obj.contextBttn.removeEventListener(MouseEvent.MOUSE_DOWN, obj.callback);
				removeChild(obj.contextBttn);	
			}
			
			App.map.mTreasure.removeChild(this);
			content = [];
			//self = null;
		}
	}
}