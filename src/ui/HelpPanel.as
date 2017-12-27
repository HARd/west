package ui 
{

	import buttons.Button;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	import wins.Window;

	public class HelpPanel extends Sprite
	{
		public static var opened:Boolean = false;
		
		public var takeBttn:Button;
		public var cancelBttn:Button;
		
		public var take:Function;
		public var cancel:Function;
		
		public var closed:Boolean = false;
		
		public var showed:Boolean = false;
		
		public static function hideAll():void {
			var num:int = App.ui.numChildren;
			while (num--) {
				var item:* = App.ui.getChildAt(num);
				if (item is HelpPanel) {
					item.hide();
				}
			}
		}
		
		public function HelpPanel(take:Function, cancel:Function) 
		{
			this.take = take;
			this.cancel = cancel;
			
			var bg:Bitmap = Window.backing(170, 74, 10, "textSmallBacking");
			addChild(bg);
			
			var label:TextField = Window.drawText(Locale.__e("flash:1382952379784"), {
				fontSize:18,
				textAlign:"center"
			});
			addChild(label);
			label.width = 170;
			label.height = label.textHeight;
			
			takeBttn = new Button({ 
				caption:Locale.__e("flash:1382952379786"),
				fontSize:18,
				width:70,
				height:28
			});
			takeBttn.addEventListener(MouseEvent.CLICK, onTake);
			
			addChild(takeBttn);
			
			cancelBttn = new Button({ 
				caption:Locale.__e("flash:1383041104026"),
				fontSize:18,
				width:40,
				height:28,
				borderColor:			[0x9f9171,0x9f9171],
				fontColor:				0x4c4404,
				fontBorderColor:		0xefe7d4,
				bgColor:				[0xe3d5b5,0xc0b292]
			});
			cancelBttn.addEventListener(MouseEvent.CLICK, onCancel);
			
			addChild(cancelBttn);
			
			takeBttn.x = 20;
			takeBttn.y = 30;
			
			cancelBttn.x = takeBttn.width + 30;
			cancelBttn.y = 30;
			
			label.x = (bg.width - label.width) / 2;
			label.y = 7;
		}
		
		private var timeID:uint;
		public function show():void {
			var num:int = App.map.mTreasure.numChildren;
			while (num--) {
				var item:* = App.map.mTreasure.getChildAt(num);
				if (item is HelpPanel && item != this) {
					item.hide();
				}
			}
			
			showed = true;
			opened = true;
			
			if(!App.map.mTreasure.contains(this)){
				App.map.mTreasure.addChild(this);
			}
						
			App.self.addEventListener(MouseEvent.CLICK, onMouseDown);
			App.self.addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
			
			timeID = setTimeout(check, 700);
		}
		
		public function update():void {
			timeID = setTimeout(check, 700);
		}
		
		private function check():void {
			
			for (var i:int = App.map.under.length-1; i >= 0; i--) {
				var target:* = App.map.under[i];
				while (target.parent != null) {
					if (target.parent is HelpPanel || target.parent.name == 'ava') {
						timeID = setTimeout(check, 700);
						return; 
					}
					target = target.parent;
				}
			}
			hide();
		}
		
		private function onMouseDown(e:MouseEvent):void
		{
			hide();
		}
		
		private function onMouseOver(e:MouseEvent):void {
			UserInterface.over = true;
		}
		
		private function onCancel(e:MouseEvent):void {
			cancel();
			closed = true;
		}
		
		private function onTake(e:MouseEvent):void {
			take();
			closed = true;
		}
		
		public function hide():void
		{
			
			clearTimeout(timeID);
			
			App.self.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			App.self.removeEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
			
			if(App.map.mTreasure.contains(this)){
				App.map.mTreasure.removeChild(this);
			}
			
			showed = false;
			opened = false;
		}
		
		public function dispose():void {
			takeBttn.removeEventListener(MouseEvent.CLICK, onTake);
			cancelBttn.removeEventListener(MouseEvent.CLICK, onCancel);
		}
	}

}