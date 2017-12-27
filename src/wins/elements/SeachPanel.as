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

	public class SeachPanel extends Sprite
	{
		public var bttnSearch:Bitmap;
		public var bttnBreak:ImageButton;
		public var searchField:TextField;
		private var win:*
		private var update:Function
		
		public function SeachPanel(window:*, update:Function)
		{
			this.update = update
			this.win = window;
			if(win is GiftWindow)
				if (win.settings.itemsMode == GiftWindow.FRIENDS)	
					drawSearch();
					
			if (win is AskWindow)
				drawSearch();
		}
			
		private function drawSearch():void {
			
			bttnSearch = new Bitmap(UserInterface.textures.searchBttn);
			bttnSearch.y = 4;
			addChild(bttnSearch);
			//bttnSearch.addEventListener(MouseEvent.CLICK, onSearchEvent);
			
			var searchBg:Shape = new Shape();
			searchBg.graphics.lineStyle(2, 0x5d5321, 1, true);
			searchBg.graphics.beginFill(0xddd7ae,1);
			searchBg.graphics.drawRoundRect(0, 0, 135, 25, 15, 15);
			searchBg.graphics.endFill();
			
			addChild(searchBg);
			searchBg.x = 40;
			searchBg.y = 5;
			
			bttnBreak = new ImageButton(UserInterface.textures.stopIcon, { scaleX:0.7, scaleY:0.7, shadow:true } );
			addChild(bttnBreak);
			bttnBreak.x = searchBg.x + searchBg.width - bttnBreak.width - 4;
			bttnBreak.y = searchBg.y + 3;
			bttnBreak.addEventListener(MouseEvent.CLICK, onBreakEvent);
			
			searchField = Window.drawText("",{ 
				color:0x502f06,
				borderColor:0xf8f2e0,
				fontSize:18,
				input:true
			});
			
			searchField.x = bttnSearch.width + 6;
			searchField.y = 6;
			searchField.width = bttnBreak.x - 2 - searchField.x;
			searchField.height = searchField.textHeight + 2;
			
			addChild(searchField);
			
			searchField.addEventListener(Event.CHANGE, onInputEvent);
			searchField.addEventListener(FocusEvent.FOCUS_IN, onFocusEvent);
		}
		
		
		private function onFocusEvent(e:FocusEvent):void {
			if (App.self.stage.displayState != StageDisplayState.NORMAL) {
				App.self.stage.displayState = StageDisplayState.NORMAL;
			}
		}
		
		private function onInputEvent(e:Event):void {
			
			searchFriends(e.target.text);
		}
		
		private function onSearchEvent(e:MouseEvent):void {
			//if (!searchPanel.visible) {
			//	searchField.text = "";
			//}
			//searchPanel.visible = !searchPanel.visible;
		}
		
		private function onBreakEvent(e:MouseEvent):void {
			searchField.text = "";
			searchFriends();
			//searchPanel.visible = false;
		}
		
		public function searchFriends(query:String = ""):void {
			
			var wlFilter:Boolean = false;
			if (win.hasOwnProperty('wishListFilter')) wlFilter = win.wishListFilter;
			
			var freeFilter:Boolean = false;
			if (win.settings.iconMode == GiftWindow.FREE_GIFTS) freeFilter = true;
			
			var friends:Array = [];
			var friend:Object;
			
			query = query.toLowerCase();
			
			// Пустая строка поиска
			if (query == "") {
				
				for each(friend in App.user.friends.keys) {
					if (friend.uid == "1") continue;
					
					if (!useFilters(friend.uid)) continue;
					friends.push(friend);
				}
				friends.sortOn("level");
				
			}else {
				for each(friend in App.user.friends.data) {
					
					if (!useFilters(friend.uid)) continue;
					
					if (
						friend.aka.toLowerCase().indexOf(query) == 0 ||
						friend.first_name.toLowerCase().indexOf(query) == 0 ||
						friend.last_name.toLowerCase().indexOf(query) == 0 ||
						friend.uid.toString().toLowerCase().indexOf(query) == 0
					){
						friends.push(friend);
					}
				}
				friends.sortOn("level");
			}
			// Передаем новый список друзей
			update(friends)
			
			// Проверяем подходит ли под условия фильтра
			function useFilters(_uid:String):Boolean
			{
				if (freeFilter && !Gifts.canTakeFreeGift(_uid)) return false;
				if (wlFilter)
				{
					var check:Boolean = false
					for each(var wItem:* in App.user.friends.data[_uid].wl) if (wItem == win.icon.ID) check = true;
					if (!check) return false;
				}
				
				// фильтры пройдены
				return true;
			}
		}
	}
}	