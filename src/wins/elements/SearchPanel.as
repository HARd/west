package wins.elements 
{
	
	import buttons.ImageButton;
	import flash.display.Shape;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import wins.AskWindow;
	import wins.GiftWindow;
	import ui.UserInterface;
	import flash.display.Sprite;
	import flash.display.Bitmap;
	import flash.display.StageDisplayState;
	import wins.Window;

	public class SearchPanel extends Sprite
	{
		public var bttnSearch:ImageButton;
		public var bttnBreak:ImageButton;
		public var searchField:TextField;
		private var win:*
		private var update:Function
		
		public var settings:Object = {
			win:		null,
			callback:	null,
			stop:		null,
			caption:	null,
			hasIcon:	true
		}
		
		public function SearchPanel(settings:Object)
		{
			for (var item:* in settings)
				this.settings[item] = settings[item];
			
			
			if (settings.win is GiftWindow)
			{
				if (settings.win.settings.itemsMode == GiftWindow.FRIENDS)	
					drawSearch();
					
			}else {
				drawSearch();
			}
			
			if(settings.caption)
				text = settings.caption;
		}
			
		private function drawSearch():void {
			
			bttnSearch = new ImageButton(UserInterface.textures.lens);
			bttnSearch.y = 4;
			bttnSearch.tip = function():Object {
				return {
					title:Locale.__e('flash:1382952380073'),
					text:Locale.__e('flash:1382952380074')
				}
			}
			addChild(bttnSearch);
				//bttnSearch.addEventListener(MouseEvent.CLICK, onSearchEvent);
			if (!settings.hasIcon)
			{
				bttnSearch.visible = false
			}
			
			var searchBg:Shape = new Shape();
			searchBg.graphics.lineStyle(2, 0x263737, 1, true);
			searchBg.graphics.beginFill(0xf5edd0, 1);
			searchBg.graphics.drawRoundRect(0, 0, 154, 25, 15, 15);
			searchBg.graphics.endFill();
			
			addChild(searchBg);
			searchBg.x = 45;
			searchBg.y = 10;
			
			bttnBreak = new ImageButton(Window.textures.searchDeleteBttn, { scaleX:1, scaleY:1, shadow:false } );
			addChild(bttnBreak);
			bttnBreak.x = searchBg.x + searchBg.width - bttnBreak.width - 4;
			bttnBreak.y = searchBg.y + 4;
			bttnBreak.addEventListener(MouseEvent.CLICK, onBreakEvent);
			
			searchField = Window.drawText("",{ 
				color:0x502f06,
				borderColor:0xf8f2e0,
				fontSize:18,
				input:true
			});
			
			searchField.x = bttnSearch.width + 30;
			searchField.y = 11;
			searchField.width = bttnBreak.x - 2 - searchField.x;
			searchField.height = searchField.textHeight + 2;
			
			addChild(searchField);
			
			searchField.addEventListener(Event.CHANGE, onInputEvent);
			searchField.addEventListener(FocusEvent.FOCUS_IN, onFocusEvent);
			searchField.addEventListener(FocusEvent.FOCUS_OUT, onUnFocusEvent);
		}
		
		
		public function onFocusEvent(e:FocusEvent):void {
			//if (App.self.stage.displayState != StageDisplayState.NORMAL) {
				//App.self.stage.displayState = StageDisplayState.NORMAL;
			//}
			
			if (text == settings.caption)
				text = "";
		}
		
		public function onUnFocusEvent(e:FocusEvent):void {
			if(settings.caption && text == "")
				text = settings.caption;
		}
		
		private function onInputEvent(e:Event):void {
			
			search(e.target.text);
		}
		
		private function onSearchEvent(e:MouseEvent):void {
			//if (!searchPanel.visible) {
			//	searchField.text = "";
			//}
			//searchPanel.visible = !searchPanel.visible;
		}
		
		public function onBreakEvent(e:MouseEvent):void {
			searchField.text = "";
			search();
			//searchPanel.visible = false;
		}
		
		public function set text(value:String):void {
			searchField.text = value;
		}
		public function get text():String {
			return searchField.text;
		}
		
		public function search(query:String = "", isCallBack:Boolean = true):Array {
			return null;
		}
	}
}	