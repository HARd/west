package 
{
	import buttons.ImageButton;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import ui.UserInterface;
	import wins.GiftWindow;
	import wins.Window;
	public class SearchPanel extends LayerX 
	{
		public static const DEFAULT:int = 1;
		public static const FRIENDS:int = 2;
		
		public var bttnSearch:ImageButton;
		public var bttnBreak:ImageButton;
		public var searchField:TextField;
		
		//настройки по умолчанию
		public var settings:Object = {
			width:		154,
			height:		25,
			maxChars:	250,
			restrict:	null,
			content:	null,
			callback:	null,
			stop:		null,
			caption:	null,
			hasIcon:	true,
			filter:		[],
			mode:		SearchPanel.DEFAULT
		}
		
		public function SearchPanel(settings:Object = null) 
		{
			for (var item:* in settings)
				this.settings[item] = settings[item];
				
			//если полученный контент является объектом, приводим его к массиву с помощью функции generateData
			if (settings.content != null && settings.content is Object) {
				this.settings.content = generateData(settings.content);
			}
			
			drawSearch();
			
			if(settings.caption)
				text = settings.caption;
		}
		
		public function set content(data:*):void {
			if (data is Object) {
				data = generateData(data);
			}
			settings.content = data;
		}
		
		public function get content():Array {
			return settings.content;
		}
		
		//визуальная отрисовка панели, добавление слушателей событий
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
			
			if (!settings.hasIcon) {
				bttnSearch.visible = false;
			}
			
			var searchBg:Shape = new Shape();
			searchBg.graphics.lineStyle(2, 0x263737, 1, true);
			searchBg.graphics.beginFill(0xf5edd0, 1);
			searchBg.graphics.drawRoundRect(0, 0, settings.width, settings.height, 15, 15);
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
			searchField.maxChars = settings.maxChars;
			searchField.restrict = settings.restrict;
			
			searchField.x = bttnSearch.width + 30;
			searchField.y = 11;
			searchField.width = bttnBreak.x - 2 - searchField.x;
			searchField.height = searchField.textHeight + 2;
			
			addChild(searchField);
			
			searchField.addEventListener(Event.CHANGE, onInputEvent);
			searchField.addEventListener(FocusEvent.FOCUS_IN, onFocusEvent);
			searchField.addEventListener(FocusEvent.FOCUS_OUT, onUnFocusEvent);
		}
		
		public function onBreakEvent(e:MouseEvent):void {
			searchField.text = "";
			
			if (settings.stop != null) {
				settings.stop();
			}
		}
		
		public function onFocusEvent(e:FocusEvent):void {
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
		
		public function set text(value:String):void {
			searchField.text = value;
		}
		public function get text():String {
			return searchField.text;
		}
		
		//если передали функцию обработчик, то вызываем ее. если нет, то используем
		//стандартный перебор и поиск данных
		public function search(query:String = ''):void {
			if (settings.searchCallback) {
				if (settings.callback != null && query != "") {
					settings.callback(settings.searchCallback(query));
					return;
				}
			}
			
			if (settings.mode == SearchPanel.FRIENDS) {
				searchFriends(query);
				return;
			}
			
			if (query == "" || settings.content == null) {
				if (settings.stop != null)
					settings.stop();
				return;	
			}
			
			query = query.toLowerCase();
			
			var result:Array = [];
			var items:Array = settings.content;
			
			for (var i:int = 0; i < items.length; i++)
			{
				var item:Object = items[i];
					
				if (settings.filter.length != 0) {
					for each (var prop:* in settings.filter) {
						if (item.hasOwnProperty(prop) && String(item[prop]).toLowerCase().indexOf(query) != -1) {
							result.push(App.data.storage[item.sid]);
						}
					}
				}else {
					if (item.title.toLowerCase().indexOf(query) == 0)
						result.push(App.data.storage[item.sid]);
				}
			}
			
			result.sortOn('order', Array.NUMERIC);
			
			if (settings.callback != null) settings.callback(result);
		}
		
		public function searchFriends(query:String = ""):void {
			
			var wlFilter:Boolean = false;
			if (settings.hasOwnProperty('wishListFilter')) wlFilter = settings.wishListFilter;
			
			var freeFilter:Boolean = false;
			if (settings.hasOwnProperty('iconMode') && settings.iconMode == GiftWindow.FREE_GIFTS) freeFilter = true;
			
			var friends:Array = [];
			var friend:Object;
			
			query = query.toLowerCase();
			var fid:String;
			
			// Пустая строка поиска
			if (query == "") {
				
				if (settings.hasOwnProperty('itemsMode') && settings.itemsMode == GiftWindow.ALLFRIENDS){
					for (fid in App.network.otherFriends) {
						friends.push(App.network.otherFriends[fid]);
					}
					friends.sortOn("uid");
				}else{
					for each(friend in App.user.friends.keys) {
						if (!friend.uid || friend.uid == "1") continue;
						
						if (friend.uid && !useFilters(friend.uid)) continue;
						friends.push(friend);
					}
					friends.sortOn(["level", "uid"]);
				}
			}else {
				
				if (settings.hasOwnProperty('itemsMode') && settings.itemsMode == GiftWindow.ALLFRIENDS){
					for (fid in App.network.otherFriends) {
						
						friend = App.network.otherFriends[fid];
						if (
							friend.first_name.toLowerCase().indexOf(query) == 0 ||
							friend.last_name.toLowerCase().indexOf(query) == 0 ||
							friend.uid.toString().toLowerCase().indexOf(query) == 0
						){
							friends.push(friend);
						}
					}
					friends.sortOn("uid");
				}else{
					for each(friend in App.user.friends.data) {
						
						if (!friend.uid || friend.uid == "1" || !useFilters(friend.uid)) continue;
						
						if (
							friend.aka.toLowerCase().indexOf(query) == 0 ||
							(friend.first_name && friend.first_name.toLowerCase().indexOf(query) == 0) ||
							(friend.last_name && friend.last_name.toLowerCase().indexOf(query) == 0) ||
							friend.uid.toString().toLowerCase().indexOf(query) == 0
						){
							friends.push(friend);
						}
					}
					friends.sortOn("level");
				}
			}
			
			// Проверяем подходит ли под условия фильтра
			function useFilters(_uid:String):Boolean
			{
				if (freeFilter && !Gifts.canTakeFreeGift(_uid)) return false;
				if (wlFilter)
				{
					var check:Boolean = false
					for each(var wItem:* in App.user.friends.data[_uid].wl) if (wItem == settings.win.icon.ID) check = true;
					if (!check) return false;
				}
				
				// фильтры пройдены
				return true;
			}
			
			if (settings.callback != null) settings.callback(friends);
		}
		
		public function dispose():void {
			bttnBreak.removeEventListener(MouseEvent.CLICK, onBreakEvent);
			
			searchField.removeEventListener(Event.CHANGE, onInputEvent);
			searchField.removeEventListener(FocusEvent.FOCUS_IN, onFocusEvent);
			searchField.removeEventListener(FocusEvent.FOCUS_OUT, onUnFocusEvent);
		}
		
		//приведения массива данных к виду [ { sid:1236, order:1, title:'Материал' } ]
		public static function generateData(data:*):Array {
			var arr:Array = [];
			var i:int;
			var itm:*;
			
			if (data is Array) {
				for (i = 0; i < data.length; i++) {
					if (data[i] is Array) {
						for (var j:int = 0; j < data[i].length; j++) {
							addElement(data[i][j]);
						}
					}else {
						if (data[i].hasOwnProperty('items')) {
							if (data[i].items is Array) {
								for (i = 0; i < data[i].items.length; i++) {
									addElement(data[i].items[i]);
								}
							} else {
								for each (itm in data[i].items) {
									addElement(itm);
								}
							}
						} else {
							addElement(data[i]);
						}
					}
				}
			} else if (data is Object) {
				for each (var item:* in data) {
					if (item is Array) {
						for (i = 0; i < item.length; i++) {
							if (item.hasOwnProperty('items')) {
								if (item.items is Array) {
									for (i = 0; i < item.items.length; i++) {
										addElement(item.items[i]);
									}
								} else {
									for each (itm in item.items) {
										addElement(itm);
									}
								}
							} else {
								addElement(item[i]);
							}
						}
					} else if (item is Object) {
						if (item.hasOwnProperty('items')) {
							if (item.items is Array) {
								for (i = 0; i < item.items.length; i++) {
									addElement(item.items[i]);
								}
							} else {
								for each (itm in item.items) {
									addElement(itm);
								}
							}
						} else {
							addElement(item);
						}
					}
				}
			}
			
			//удаление повторяющихся элементов в массиве
			for (i = 0; i < arr.length; i++) {
				itm = arr[i];
				for (var n:int = 0; n < arr.length; n++) {
					if (arr[n].sid == itm.sid && arr[n].order == itm.order && arr[n].title == itm.title && i != n)
						arr.splice(n, 1);
				}
			}
			
			function addElement(element:Object):void {
				if (element.hasOwnProperty('sid')) {
					arr.push({sid:element.sid, order:element.order, title:element.title});
				} else if (element.hasOwnProperty('sID')) {
					arr.push({sid:element.sID, order:element.order, title:element.title});
				}
			}
			
			return arr;
		}
		
	}

}