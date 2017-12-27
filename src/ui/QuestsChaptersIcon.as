package ui
{	
	import buttons.ImageButton;
	import buttons.ImagesButton;
	import core.Load;
	import effects.Effect;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import ui.QuestIcon;
	import wins.Window;
	
	public class QuestsChaptersIcon extends QuestIcon
	{	
		public var checkMark:Bitmap;
		public var item:Object;
		
		public function QuestsChaptersIcon(item:Object, time:uint, questType:String = 'opened', glow:Boolean = false) {
			super(item);
			
			this.item = item;
			
			if (glow) {
				this.showGlowing();
			}else {
				this.hideGlowing();
			}
			
			if (item.questType == 'closed') 
			{	
				//removeEventListener(MouseEvent.CLICK, onQuestOpen);
				Effect.light(this, 0, .1);
				//Effect.light(icon, 0, .1);
				this.tip = function():Object {
					return {
						title:Locale.__e(App.data.quests[item.ID].title)
					};
				};
			}
			
			if (item.questType == 'finished') 
			{	
				//addEventListener(MouseEvent.CLICK, onQuestOpen);
				if (txtTime) txtTime.visible = false;
				App.self.setOffTimer(updateDuration);
				App.ui.leftPanel.questsPanel.change();
				newIcon.visible = false;
				//Effect.light(this, 0, .1);
				//Effect.light(icon, 0, .1);
				addCheckMark();
			}
		}
		
		public function addCheckMark():void {
			var check:Bitmap = new Bitmap(Window.texture('checkmarkSlim'));
			check.x = (bg.width - check.width) / 2;
			check.y = 32;
			addChild(check);
		}
		
		override public function onQuestOpen(e:MouseEvent = null):void {
			if (item.questType == 'closed' || item.questType == 'finished') return;
			needClose = false;
			super.onQuestOpen(e);
		}
		
		override public function onOver(e:MouseEvent):void {
			if (item.questType == 'closed' || item.questType == 'finished') return;
			Effect.light(this, 0.15);
		}
		override public function onOut(e:MouseEvent):void {
			if (item.questType == 'closed' || item.questType == 'finished') return;
			Effect.light(this, 0);
		}
	}
}
