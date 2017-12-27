package ui 
{
	import core.Load;
	import effects.Effect;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.events.MouseEvent;
	import wins.Window;
	
	public class QuestPlusIcon extends QuestIcon 
	{
		public static const HEIGHT:int = 75;
		
		private var item:Object;
		private var normalIcon:Boolean;
		private var worldID:int;
		
		//private var bg:Bitmap;
		//private var icon:Bitmap;
		private var preloader:Preloader;
		
		public function QuestPlusIcon(item:Object, other:Array, normalIcon:Boolean = false, worldID:int = 0) 
		{
			this.item = item;
			this.qID = item.id;
			this.otherItems = other;
			this.normalIcon = normalIcon;
			this.worldID = worldID;
			super(item);
			
			addEventListener(MouseEvent.CLICK, onQuestOpen);
			addEventListener(MouseEvent.ROLL_OVER, onOver);
			addEventListener(MouseEvent.ROLL_OUT, onOut);
			
			tip = function():Object {
				var text:String = '';
				if (worldID != 0) text = App.data.storage[worldID].title;
				else text = App.data.quests[qID].title;
				return {
					title:		'',
					text:		text
				}
			};
		}
		
		override public function drawIcon():void {
			if (normalIcon) {
				super.drawIcon();
				return;
			}
			var shape:Shape = new Shape();
			shape.graphics.beginFill(0xFF0000, 0.0);
			shape.graphics.drawRect(0, 0, HEIGHT, HEIGHT);
			shape.graphics.endFill();
			addChild(shape);
			
			preloader = new Preloader();
			preloader.scaleX = preloader.scaleY = 0.75;
			preloader.x = 35;
			preloader.y = 35;
			addChild(preloader);
			
			bg = new Bitmap(/*Window.texture('interSaleBackingYellow')*/);
			addChild(bg);
			
			if (worldID) {
				Load.loading(Config.getImage('questIcons', String(worldID)), function (data:*):void {
					removeChild(preloader);
					bg.bitmapData = data.bitmapData;
				});
			}
			
			for each (var q:* in otherItems) {
				if (!App.user.quests.tutorial && q.fresh && isNew(q.id)) 
					glowIcon('');
			}
		}
		
		override public function onQuestOpen(e:MouseEvent = null):void {
			if (App.user.quests.tutorial && !Tutorial.tutorialBttn(this)) return;
			
			App.ui.bottomPanel.changeCursorPanelState(true);
			hideGlowing();
			hidePointing();
			
			Window.closeAll();
			
			if (App.data.quests[qID].bonus)
				App.user.quests.openPlusWindow(qID, otherItems);
		}
		
		private function isNew(qI:int):Boolean
		{
			for each (var item:* in QuestPanel.newQuests)
			{
				if (item.id == qI && (App.time - item.time) < 10) return true;
			}
			return false;
		}
		
	}

}