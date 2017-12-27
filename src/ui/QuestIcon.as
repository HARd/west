package ui
{
	import core.Load;
	import core.Post;
	import core.Size;
	import core.TimeConverter;
	import effects.Effect;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	import ui.QuestPanel;
	import wins.ThanksgivingEventWindow;
	import wins.Window;

	public class QuestIcon extends LayerX
	{
		
		public static const HEIGHT:int = 75;
		public static const ONE_WEEK:int = 604800;
		
		public var needClose:Boolean = true;
		
		private var item:Object;
		public var questData:Object;
		public var qID:int;
		
		public var bg:Bitmap;
		public var icon:Bitmap;
		private var preloader:Preloader;
		public var timerLabel:TextField;
		public var newIcon:Bitmap;
		static public var visibleQuest:Object = { };
		
		public var otherItems:Array;
		
		public function QuestIcon(item:Object) {
			
			this.item = item;
			this.qID = item.id;
			questData = App.data.quests[qID];
			
			drawIcon();
			
			tip = function():Object {
				var text:String = questData.description;
				
				if (questData.missions) {
					text = '';
					var count:int = 1;
					for (var mid:* in questData.missions) {
						if (text.length > 0) text += '\n';
						
						var have:int = (App.user.quests.data.hasOwnProperty(qID)) ? App.user.quests.data[qID][mid] : 0;
						var txt:String;
						if (questData.missions[mid].func != 'sum') {
							if (have == questData.missions[mid].need) {
								txt = '1/1';
							}else {
								txt = '0/1';
							}
							text += ' - ' + questData.missions[mid].title + ' ' + txt;
						} else {
							text += ' - ' + questData.missions[mid].title + ' ' + String(App.user.quests.data[qID][mid] || 0) + '/' + String(questData.missions[mid].need);
						}
						count++;
					}
					
					if (Config.admin) {
						text += '\n' + String(qID);
					}
				}
				
				return {
					title:		questData.title,
					text:		text
				}
			};
			
			initAddon();
		}
		
		public function drawIcon():void {
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
			
			bg = new Bitmap();
			addChild(bg);
			
			var character:String = (App.data.personages.hasOwnProperty(questData.character)) ? App.data.personages[questData.character].preview : "huntsman";
			Load.loading(Config.getImageIcon('quests/icons', character), function(data:Bitmap):void {
				removeChild(preloader);
				preloader = null;
				
				bg.bitmapData = data.bitmapData;
				bg.smoothing = true;
				resize();
				
				if (txtTime) {
					txtTime.x = (bg.width - txtTime.width) / 2;
					txtTime.y = bg.height - txtTime.height + 10;
				}
				
				if (timerLabel) {
					timerLabel.x = (bg.width - timerLabel.width) / 2;
					timerLabel.y = bg.height - timerLabel.height + 7;
				}
			});
			
			
			icon = new Bitmap();
			addChild(icon);
			
			var mid:*
			for (var ind:* in questData.missions) {
				if (!mid) for each(mid in questData.missions[ind].target) break;
				if (!mid) for each(mid in questData.missions[ind].map) break;
			}
			
			if (qID == 28) mid = 6;
			if (qID == 341) mid = 852;
			if (questData.hasOwnProperty('backview') && questData.backview != '' && questData.backview != null && questData.backview != 'null') {
				Load.loading(Config.getImage('questIcons', questData.backview), function(data:Bitmap):void {
					icon.bitmapData = data.bitmapData;
					icon.smoothing = true;
					
					Size.size(icon, 30, 30);
					icon.filters = [new GlowFilter(0xfeec71, 1, 3, 3, 4)];
					
					resize();
				});
			} else {
				if (App.data.storage.hasOwnProperty(mid) && App.data.storage[mid].preview != '') {
					Load.loading(Config.getIcon(App.data.storage[mid].type, App.data.storage[mid].preview), function(data:Bitmap):void {
						icon.bitmapData = data.bitmapData;
						icon.smoothing = true;
						
						Size.size(icon, 30, 30);
						icon.filters = [new GlowFilter(0xfeec71, 1, 3, 3, 4)];
						
						resize();
					});
				}
			}
			
			addEventListener(MouseEvent.CLICK, onQuestOpen);
			addEventListener(MouseEvent.ROLL_OVER, onOver);
			addEventListener(MouseEvent.ROLL_OUT, onOut);
			
			newIcon = new Bitmap(UserInterface.textures.richRedNewLabel);
			newIcon.x = -10;
			newIcon.y = bg.height - newIcon.height / 1.5;
			newIcon.visible = false;
			addChild(newIcon);
			
			if (!visibleQuest.hasOwnProperty(questData.ID)) {
				visibleQuest[questData.ID] = {visible:true};
			}
			
			var update:String = questData.update;
			if (App.data.updatelist.hasOwnProperty(App.social)) {
				if (App.data.updatelist[App.social][update] + ONE_WEEK >= App.time && visibleQuest[questData.ID].visible) { 
					if (App.user.quests.data.hasOwnProperty(questData.ID) && App.user.quests.data[questData.ID].hasOwnProperty('viewed') && App.user.quests.data[questData.ID].viewed < App.time) {
						newIcon.visible = false;
					} else {
						newIcon.visible = true;
					}
				}
			}
			
			if (questData.duration > 0) {
				drawTime();
			}
			
			if (!App.user.quests.tutorial && item.fresh && isNewItem()) {
				glowIcon('');
			}
				
			if (questData.hasOwnProperty('glow') && questData.glow == 1) {
				showGlowing();
			}
		}
		
		protected function isNewItem():Boolean
		{
			for each (var item:* in QuestPanel.newQuests)
			{
				if (item.id == qID && (App.time - item.time) < 10) return true;
			}
			return false;
		}
		
		public function resize():void {
			if (bg && bg.bitmapData)
				Size.size(bg, HEIGHT, HEIGHT);
			
			if (icon && icon.bitmapData) {
				if (bg && bg.bitmapData) {
					icon.x = bg.x + bg.width - icon.width + 6;
					icon.y = bg.y + bg.height - icon.height;
					
					if (newIcon) {
						newIcon.x = -10;
						newIcon.y = bg.height - newIcon.height / 1.5;
					}
				}else {
					icon.x = (HEIGHT - icon.width) / 2;
					icon.y = (HEIGHT - icon.height) / 2;
				}
			}
		}
		
		protected var txtTime:TextField;
		private function drawTime():void 
		{
			if (!App.user.quests.data.hasOwnProperty(qID)) return;
			var textSettings:Object = {
				text:Locale.__e("flash:1382952379793"),
				color:0xffffff,
				fontSize:19,
				borderColor:0x073839,
				scale:0.5,
				textAlign:'center'
			}
			
			var time:int;
			if (App.user.quests.data[qID].hasOwnProperty('created') && App.user.quests.data[qID].created != 0) {
				time = App.user.quests.data[qID].created + questData.duration * 3600 - App.time; 
			}else {
				App.user.quests.data[qID].created = App.time;
				time = App.user.quests.data[qID].created + questData.duration * 3600 - App.time;
			}
			if (App.data.quests[qID].update == addon.update && App.user.quests.data[qID].created + questData.duration * 3600 > Events.timeOfComplete && Events.timeOfComplete != 0) {
				time = Events.timeOfComplete - App.time;
			}
			txtTime = Window.drawText(TimeConverter.timeToStr(time), textSettings);
			updateDuration();
			addChild(txtTime);			
			
			txtTime.width = 95;
			txtTime.x = (bg.width - txtTime.width) / 2;
			txtTime.y = 55;// bg.height - txtTime.height + 10;
			
			App.self.setOnTimer(updateDuration);
		}
		
		private var timeID:uint;
		private var materialIcon:Bitmap;
		//public function glowIcon(text:String, timout:uint = 15000, isTimeOut:Boolean = true, type:uint = QuestPanel.NEW):void {
		public function glowIcon(text:String, timout:uint = 10000, isTimeOut:Boolean = true, type:uint = 2):void {
			if (App.data.quests[qID]) {
				
			}
			clearTimeout(timeID);
			
			var text:String = Locale.__e('flash:1382952379743');
			if (type == QuestPanel.PROGRESS)
				text = Locale.__e('flash:1382952379797');
				
			showGlowing();
			showPointing('right', -x, -y, this, text, {
				fontSize:		26,
				color:			0xffd84c,
				borderColor:	0x743d29,
				shadowSize:		2
			});
			
			if(isTimeOut)
				timeID = setTimeout(clear, timout);
			
			//SoundsManager.instance.playSFX('sound_5');
		}
		
		public function clear():void {
			App.self.setOffTimer(updateDuration);
			clearTimeout(timeID);
			hideGlowing();
			hidePointing();
		}
		
		public function onQuestOpen(e:MouseEvent = null):void {
			if (App.user.quests.tutorial && !Tutorial.tutorialBttn(this)) return;
			
			App.ui.bottomPanel.changeCursorPanelState(true);
			hideGlowing();
			hidePointing();
			
			if (newIcon && newIcon.visible == true) {
				newIcon.visible = false;
				visibleQuest[questData.ID].visible = false;
				
				//sendQuestClick(questData.ID);
			}
			
			if (needClose) Window.closeAll();
			else needClose = true;
			
			if (App.data.quests[qID].bonus)
				App.user.quests.openWindow(qID);
		}
		public function onOver(e:MouseEvent):void {
			Effect.light(this, 0.15);
		}
		public function onOut(e:MouseEvent):void {
			Effect.light(this, 0);
		}
		
		public static function sendQuestClick(qID:int):void {
			Post.send( {
				ctr:'quest',
				act:'view',
				qID:qID,
				uID:App.user.id
			}, function(error:int, data:Object, params:Object):void {
				
			});
		}
		
		protected function updateDuration():void {
			if (!App.user.quests.data[qID].hasOwnProperty('created')) {
				App.self.setOffTimer(updateDuration);
				return;
			}
			var time:int = App.user.quests.data[qID].created + questData.duration * 3600 - App.time;
			if (App.data.quests[qID].update == addon.update && App.user.quests.data[qID].created + questData.duration * 3600 > addonFinish && addonFinish != 0 && addonFinish > App.time) {
				time = addonFinish - App.time;
			}
			var daysToEnd:int = ((Math.floor((time / (60 * 60 * 24))))>1)?(Math.floor((time / (60 * 60 * 24)))):0;
			
			var timeValue:String = (daysToEnd)?Locale.__e("flash:1411744598574",daysToEnd):TimeConverter.timeToStr(time);
			
			txtTime.text = timeValue;
			
			if (time <= 0) {
				App.self.setOffTimer(updateDuration);
				App.ui.leftPanel.questsPanel.change();
			}
		}
		
		// Addon (Дополнение со временем)
		private var addonFinish:int = 0;
		private var addon:Object = {
			update:	'u566af0ca81b69',
			sid:	1302
		}
		/*private var addon2:Object = {
			update:	'562de476e0f54',
			sid:	1004
		}*/
		private function initAddon():void {
			var active:Boolean = false;
			for (var update:String in App.data.updatelist[App.social]) {
				if (addon.update == update && questData.update == addon.update && App.data.updates[addon.update].social.hasOwnProperty(App.social)) {
					active = true;
					break;
				}
			}
			
			/*for (var update2:String in App.data.updatelist[App.social]) {
				if (addon2.update == update2 && questData.update == addon2.update && App.data.updates[addon2.update].social.hasOwnProperty(App.social)) {
					active = true;
					break;
				}
			}*/
			
			if (active == false) return;
			
			var info:Object;
			if (addon.sid == 0) {
				if (App.data.top.hasOwnProperty(App.user.topID)) {
					info = App.data.top[App.user.topID];
					if (info.expire.hasOwnProperty('expire'))
						addonFinish = info.expire.e;
				} else return;
			}else {
				info = App.data.storage[addon.sid];
				if (info.type == 'Fatman') {
					addonFinish = Events.timeOfComplete;
				}
				else {
					if (info.expire[App.social]) {
						addonFinish = info.expire[App.social];
					}
				}
			}
			
			if (addonFinish > App.time && questData.duration <= 0) {
				drawTimer();
				updateAddon();
				App.self.setOnTimer(updateAddon);
			}
		}
		
		private function updateAddon():void {
			var time:int = addonFinish - App.time;
			timerLabel.text = TimeConverter.timeToStr(time);
			
			if (time <= 0) {
				App.self.setOffTimer(updateAddon);
				//App.ui.leftPanel.questsPanel.change(0,0);
			}
		}
		
		
		private function drawTimer():void {
			if (timerLabel) return;
			
			timerLabel = Window.drawText('', {
				color:			0xfeffbb,
				borderColor:	0x6f3203,
				fontSize:		17,
				width:			80,
				textAlign:		'center'
			});
			timerLabel.x = -9;
			timerLabel.y = 57;
			addChild(timerLabel);
			
			if (newIcon) newIcon.y -= 5;
		}
		public function dispose():void {
			removeEventListener(MouseEvent.CLICK, onQuestOpen);
			removeEventListener(MouseEvent.ROLL_OVER, onOver);
			removeEventListener(MouseEvent.ROLL_OUT, onOut);
			clear();
			if (parent) parent.removeChild(this);
		}
	}
}	