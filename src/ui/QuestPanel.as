package ui
{
	import buttons.ImageButton;
	import com.greensock.easing.Cubic;
	import com.greensock.TweenLite;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.StageDisplayState;
	import flash.events.MouseEvent;
	import wins.Paginator;
	import wins.Window;
	import wins.WindowEvent;
	
	
	public class QuestPanel extends Sprite
	{
		public static const PROGRESS:uint = 1;
		public static const NEW:uint = 2;
		
		public var icons:Vector.<QuestIcon> = new Vector.<QuestIcon>;
		public var panelHeight:int = 0;
		public var iconsCount:int = 0;
		
		public var paginator:Paginator;
		public var showNewMode:Boolean = false
		public static var newQuests:Vector.<Object> = new Vector.<Object>;
		public static var progressQuest:uint = 0;
		
		private var container:Sprite = new Sprite();
		private var maska:Shape = new Shape();
		
		public function QuestPanel() {
			addChild(container);
			
			maska = new Shape();
			maska.graphics.beginFill(0xff0000, 0.3);
			maska.graphics.drawRect(0, 0, 500, 300);
			maska.graphics.endFill();
			addChild(maska);
			container.mask = maska;
			
			paginator = new Paginator(0, 1, 0, {
				hasPoints:		false,
				hasButtons:		false
			});
			paginator.drawArrow(this, Paginator.LEFT, 0, 0, {
				texture:		Window.textures.smallArrow
			});
			paginator.drawArrow(this, Paginator.RIGHT, 0, 0, {
				texture:		Window.textures.smallArrow,
				scaleX:			1,
				scaleY:			-1
			});
			paginator.addEventListener(WindowEvent.ON_PAGE_CHANGE, onPageChange);
			
			addEventListener(MouseEvent.MOUSE_WHEEL, onWheel);
			
			//paginator.arrowLeft = new ImageButton(Window.textures.smallArrow);
			//paginator.arrowRight = new ImageButton(Window.textures.smallArrow);
			
			/*paginator = new QuestPaginator(App.user.quests.opened, 4, this);
			paginator.drawArrows();
			resize();*/
			
		}
		
		public function clearIconsGlow():void {
			for (var i:int = 0; i < icons.length; i++){
				icons[i].hideGlowing();
				icons[i].hidePointing();
			}	
		}
		
		public function refresh():void {
			change();
		}
		
		public function focusedOnQuest(qID:uint, type:uint = 0):void {
			for (var i:int = 0; i < icons.length; i++) {
				if (icons[i].qID == qID) {
					icons[i].glowIcon(icons[i].questData.title, 10000, true, type);
					if (i < paginator.page || i > paginator.page + iconsCount) {
						paginator.page = (i > icons.length - iconsCount) ? (icons.length - iconsCount) : i;
						paginator.update();
						onPageChange();
					}
					break;
				}
			}
		}
		
		public function availableInWorld(openedItem:Object):Boolean {
			var item:Object = App.data.quests[openedItem.id];
			
			//if (item.ID == 1130)
				//trace();
			
			if (item.type == 1) return false;// сообщение
			if (item.duration > 0 && item.created + item.duration * 3600 <= App.time) 
				return false;
			for each(var dream:* in item.dream) {
				if (item.dream == '' || dream == App.user.worldID) {
					return true;
				}
			}
			if (item.dream == '') {
				return true;
			}
			return false;
		}
		
		public var homeQuests:Array;
		public var otherQuests:Array;
		public function sortQuests():void {
			homeQuests = [];
			otherQuests = [];
			
			var i:int;
			var item:Object;
			for (i = 0; i < App.user.quests.opened.length; i++) {
				item = App.user.quests.opened[i];
				if (!item) continue;
				if (App.data.quests[item.id].type == 1) continue;	// сообщение
				if (App.data.quests[item.id].duration > 0 && App.user.quests.data[item.id].created + App.data.quests[item.id].duration * 3600 <= App.time) continue;
				
				if (availableInWorld(item)) {
					homeQuests.push(item);
				} else {
					otherQuests.push(item);
				}
			}
			
			if (otherQuests.length > 0) {
				var quests:Array = [];
				var others:Array = [];
				
				for each (var id:String in App.self.allWorlds) {
					for (i = 0; i < otherQuests.length; i++) {
						item = App.data.quests[otherQuests[i].id];
						for each(var dream:* in item.dream) {
							if (item.dream == '' || dream == id) {
								others.push(otherQuests[i]);
							}
						}
					}
					
					if (others.length > 0 ) {
						quests.push( { worldID:id, others:others } );
						others = [];
					}
				}
				
				if (quests.length > 0) {
					otherQuests = [];
					otherQuests = quests;
				}
			}
			
			homeQuests.sortOn('order', Array.NUMERIC | Array.DESCENDING);
		}
		
		public function resize(height:int = 0):void {
			if (height == 0) {
				if (panelHeight == 0) {
					panelHeight = App.self.stage.stageHeight;
				}else {
					panelHeight = height;
				}
			}else {
				panelHeight = height;
			}
			
			change();
		}
		
		private var QUEST_ICON_MARGIN:int = 5;
		private var countDoChange:int = 0;
		public function change():void {
			removeIcons();
			
			sortQuests();
			
			App.user.quests.opened.sortOn('order', Array.NUMERIC | Array.DESCENDING);
			
			//for (var i:int = 0; i < 15; i++) {
				//var item:Object = App.user.quests.opened[0];
			/*for (var i:int = 0; i < App.user.quests.opened.length; i++) {
				var item:Object = App.user.quests.opened[i];
				if (!item) continue;
				if (App.data.quests[item.id].type == 1) continue;	// сообщение
				if (App.data.quests[item.id].duration > 0 && App.user.quests.data[item.id].created + App.data.quests[item.id].duration * 3600 <= App.time) continue;
				
				if (!questIsAlreadyOpened(item.id)) newQuests.push({id:item.id, time:App.time});
				var icon:QuestIcon = new QuestIcon(item);
				icon.x = 10;
				icon.y = i * (QuestIcon.HEIGHT + QUEST_ICON_MARGIN);
				
				container.addChild(icon);
				icons.push(icon);
			}*/
			
			for (var i:int = 0; i < homeQuests.length; i++) {
				var item:Object = homeQuests[i];
				
				/*if (App.user.quests.data[item.id].hasOwnProperty('created') && App.data.quests[item.id].hasOwnProperty('duration')) {
					var time:int = App.user.quests.data[item.id].created + App.data.quests[item.id].duration * 3600 - App.time;
					if (time <= 0)
						continue;
				}*/
				
				if (!questIsAlreadyOpened(item.id)) newQuests.push({id:item.id, time:App.time});
				var icon:QuestIcon = new QuestIcon(item);
				icon.x = 10;
				icon.y = i * (QuestIcon.HEIGHT + QUEST_ICON_MARGIN);
				
				container.addChild(icon);
				icons.push(icon);
			}
			
			for (var j:int = 0; j < otherQuests.length; j++) {
				if (!otherQuests[j].hasOwnProperty('others')) continue;
				var itemPlus:Object = otherQuests[j].others[0];
				for each (var other:* in otherQuests[j].others) {
					if (!questIsAlreadyOpened(other.id)) newQuests.push( { id:other.id, time:App.time } );
				}
				var iconPlus:QuestPlusIcon = new QuestPlusIcon(itemPlus, otherQuests[j].others, false, otherQuests[j].worldID);
				iconPlus.x = 10;
				iconPlus.y = i * (QuestPlusIcon.HEIGHT + QUEST_ICON_MARGIN);
				i++;
				
				container.addChild(iconPlus);
				icons.push(iconPlus);
			}
			
			
			paginatorUpdate();
		}
		
		private function questIsAlreadyOpened(id:int):Boolean
		{
			for each (var item:* in newQuests)
			{
				if (item.id == id) return true;
			}
			return false;
		}
		
		private function removeIcons():void {
			while(icons.length) {
				var icon:QuestIcon = icons.shift();
				icon.dispose();
				icon = null;
			}
		}
		
		private function paginatorUpdate():void {
			iconsCount = Math.floor(panelHeight / (QuestIcon.HEIGHT + QUEST_ICON_MARGIN));
			if (container.height >= panelHeight) {
				iconsCount = Math.floor((panelHeight - paginator.arrowLeft.height - paginator.arrowRight.height) / (QuestIcon.HEIGHT + QUEST_ICON_MARGIN));
			}
			
			paginator.itemsCount = (icons.length - iconsCount > 0) ? (icons.length - iconsCount + 1) : 0;
			paginator.update();
			
			if (icons.length <= 0 || container.height <= panelHeight) {
				maska.y = 0;
				maska.height = panelHeight;
				paginator.visible = false;
				container.y = (panelHeight - container.height) / 2;
			}else {
				maska.y = paginator.arrowLeft.height + (panelHeight - paginator.arrowLeft.height - paginator.arrowRight.height - (QuestIcon.HEIGHT + QUEST_ICON_MARGIN) * iconsCount) / 2 - 7;
				maska.height = (QuestIcon.HEIGHT + QUEST_ICON_MARGIN) * iconsCount + 7;
				paginator.visible = true;
				container.y = maska.y + 7 - (QuestIcon.HEIGHT + QUEST_ICON_MARGIN) * paginator.page;
			}
			
			paginator.arrowLeft.x = (QuestIcon.HEIGHT - paginator.arrowLeft.height) / 2;
			paginator.arrowRight.x = (QuestIcon.HEIGHT - paginator.arrowRight.height) / 2;
			paginator.arrowLeft.y = maska.y - paginator.arrowLeft.height;
			paginator.arrowRight.y = maska.y + maska.height;
		}
		
		private var moveTween:TweenLite;
		private function onPageChange(e:WindowEvent = null):void {
			if (moveTween) moveTween.kill();
			
			moveTween = TweenLite.to(container, 0.2, { ease:Cubic.easeOut, y: maska.y + 7 - (QuestIcon.HEIGHT + QUEST_ICON_MARGIN) * paginator.page, onComplete:function():void {
				moveTween = null;
			}} );
		}
		private function onWheel(e:MouseEvent):void {
			if (App.self.stage.displayState != StageDisplayState.NORMAL) return;
			if (e.delta > 0 && paginator.page > 0) {
				paginator.page --;
				paginator.update();
				onPageChange();
			}else if (e.delta < 0 && paginator.page + iconsCount < icons.length) {
				paginator.page ++;
				paginator.update();
				onPageChange();
			}
		}
		
		public function dispose():void {
			removeIcons();
		}
	}
}
