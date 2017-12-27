package wins 
{
	import api.ExternalApi;
	import buttons.Button;
	import buttons.CheckboxButton;
	import buttons.ImageButton;
	import com.flashdynamix.motion.extras.BitmapTiler;
	import core.Load;
	import core.WallPost;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import strings.Strings;
	import ui.TipsPanel;

	public class QuestRewardWindow extends Window
	{
		public static const QUESTS:String = "quests";
		public static const DAYLICS:String = "daylics";
		public var questType:String = QUESTS;
		
		public var okBttn:Button;
		public var quest:Object = { };
		private var titleQuest:TextField;
		private var descLabel:TextField;
		private var bonusList:RewardList;
		
		private var _startMissionPosY:int = 174;
		private var _winContainer:Sprite;
		private var checkBox:CheckboxButton;
		
		private var characterForWallPost:BitmapData;
		
		public function QuestRewardWindow(settings:Object = null) 
		{
			settings['width'] = 480;
			settings['height'] = 450;
			settings['hasTitle'] = true;
			settings['titleDecorate'] = false;
			settings["title"] = Locale.__e('flash:1433335396688');
			settings['hasButtons'] = false;
			settings['hasPaginator'] = false;
			settings['callback'] = settings.callback || null;
			settings['faderAsClose'] = false;
			settings['faderClickable'] = false;
			settings['popup'] = true;
			settings['qID'] = settings.qID || 2;
			settings['shadowColor'] = 0x513f35;
			settings['shadowSize'] = 4;
			questType = settings.type || QUESTS;
			
			if(questType == DAYLICS) {
				quest = App.data.daylics[settings.qID];
				/*materials = quest.bonus;
				if (settings.qID == 1 || settings.qID == 2) {
					title = Locale.__e('flash:1382952380250', [String(settings.qID)]); // 'Задание 1/2 успешно пройдено!';
				}else{
					title = Locale.__e("flash:1393253093524");
				}*/
			}else {
				if (settings.levelRew)
					quest = settings.data;
				else
					quest = App.data.quests[settings.qID];
			}
			
			super(settings);
			
			SoundsManager.instance.playSFX('quest_Done');
			TipsPanel.hide();
			
			if (!characterForWallPost && questType == QUESTS && App.data.personages[quest.character]) {
				var preview:String = App.data.personages[quest.character].preview;
				if (quest.character == 3 || quest.character == 4) preview = App.data.personages[1].preview
				
				Load.loading(Config.getImageIcon('quests/preview', preview), function(data:*):void { 
					characterForWallPost = data.bitmapData;
				});
			}
		}
		
		override public function drawTitle():void 
		{
			titleLabel = titleText( {
				title				: settings.title,
				color				: 0xfcfbc3,
				multiline			: settings.multiline,			
				fontSize			: settings.fontSize,				
				textLeading	 		: settings.textLeading,				
				borderColor 		: 0xae751b,			
				borderSize 			: settings.fontBorderSize,	
				shadowColor			: settings.shadowColor,
				width				: settings.width - 140,
				textAlign			: 'center',
				sharpness 			: 50,
				thickness			: 50,
				border				: true,
				shadowSize			:4
			})
				
			titleLabel.x = (settings.width - titleLabel.width) * .5;
			titleLabel.y = - 13;
			titleLabel.mouseChildren = titleLabel.mouseEnabled = false;
			headerContainer.addChild(titleLabel);
			headerContainer.y = 37;
			headerContainer.mouseEnabled = false;
		}
		
		private var upperPart:Bitmap;	
		override public function drawBody():void 
		{	
			upperPart = backingShort(settings.width + 120, 'ribbonYellow', true);
			upperPart.x = -60;
			upperPart.y = -40;
			bodyContainer.addChild(upperPart);
			
			addIcon();
			
			exit.visible = false;
			
			//////////////////////////////////////////////////TEXT/////////////////////////////////////////
			var titlePadding:int = -10;
			var descMarginX:int = 10;
			
			var descSize:int = 32;
			
			do{
				descLabel = Window.drawText(quest.title, {
					color:0x502d07, 
					border:false,
					fontSize:descSize,
					multiline:true,
					textAlign:"center"
				});
					
				descLabel.wordWrap = true;
				descLabel.width = 368;
				descLabel.height = descLabel.textHeight + 10;
					
				descSize -= 1;	
			}
			while (descLabel.height > 104.8) 
				
			var curHeight:int = /*titleQuest.height + */descLabel.height + titlePadding*2;
			if (curHeight > 240) curHeight = 240;
			if (curHeight < 200) curHeight = 200;
			
			var marginSpriteY:int = 65;
			
			//titleQuest.x = upperPart.x + (upperPart.width - titleQuest.width)/2;
			//titleQuest.y = upperPart.y + (upperPart.height - titleQuest.height)/2  + 60;
			
			descLabel.y = /*titleQuest.y + titleQuest.height + */25;
			if (descLabel.height >= 100)
			{
				descSize -= 1;
				descLabel.y = /*titleQuest.y + titleQuest.height*/ - 25;
			}
			
			//drawMirrowObjs('titleDecRose', titleQuest.x - 10, titleQuest.x + titleQuest.width + 10, titleQuest.y + 15, false, false, false, 1, 0.7, bodyContainer);
			
			descLabel.x = (settings.width - descLabel.width) / 2;
			descLabel.y = 80;
			
			//bodyContainer.addChild(titleQuest);
			bodyContainer.addChild(descLabel);
			
			contentChange();
			
			okBttn = new Button( {
				borderColor:			[0xfeee7b,0xb27a1a],
				fontColor:				0xffffff,
				fontBorderColor:		0x814f31,
				bgColor:				[0xf5d159, 0xedb130],
				width:162,
				height:50,
				fontSize:32,
				hasDotes:false,
				caption:Locale.__e("flash:1393582068437")
			});
			okBttn.x = (settings.width - okBttn.width) / 2;
			okBttn.y = settings.height - okBttn.height - 50;
			bodyContainer.addChild(okBttn);
			okBttn.addEventListener(MouseEvent.CLICK, onTakeEvent);
			okBttn.name = 'QuestRewardWindow_okBttn';
			
			if (Quests.helpInQuest(App.user.quests.currentQID)) {
				okBttn.showGlowing();
				if (App.user.level < 4)
					okBttn.showPointing('bottom', 0, okBttn.height + 30, bodyContainer);
			}
			
			if(!settings.levelRew && !App.isSocial('HV','YN','YB','MX','SP','AI','GN')){
				checkBox = new CheckboxButton();
				bodyContainer.addChild(checkBox);
				checkBox.x = okBttn.x + 24;
				checkBox.y = okBttn.y - checkBox.height  - 3;
			}
			
			if (questType == DAYLICS) {
				//tellBttn.visible = false;
				okBttn.x = 70 + okBttn.width + 10 - okBttn.width / 2;
			}
		}
		
		private function onTakeEvent(e:MouseEvent):void {
			if (checkBox && checkBox.checked == CheckboxButton.CHECKED && characterForWallPost) onTellEvent(e);
			bonusList.take();
			close();
			if (settings.callback) settings.callback();
		}
		
		private function onTellEvent(e:MouseEvent):void
		{
			WallPost.makePost(WallPost.QUEST, {
				bitmapData:		characterForWallPost,
				questTitle:		quest.title
			});
			bonusList.take();
			close();
		}
		
		private function addIcon():void
		{
			var preview:String = (quest.hasOwnProperty('character')) ? App.data.personages[quest.character].preview : App.data.personages[1].preview;
			if (quest.character == 3 || quest.character == 4 || quest.character == 11) preview = App.data.personages[1].preview;
			
			var persIcon:Bitmap = new Bitmap();
			Load.loading(Config.getImageIcon('quests/reward', preview), function(data:*):void {
				persIcon.bitmapData = data.bitmapData;
				persIcon.smoothing = true;
				
				switch (quest.character) 
				{
					case 1:
						persIcon.x = (settings.width - persIcon.width) / 2;
						persIcon.y = -126;
					break;
					case 2:
						persIcon.x = (settings.width - persIcon.width) / 2 - 5;
						persIcon.y = -118;
					break;
					/*case 7:
						persIcon.x = (settings.width - persIcon.width) / 2 - 155;
						persIcon.y = -118;
					break;*/
					/*case 3:
						persIcon.x = (settings.width - persIcon.width) / 2 - 48;
						persIcon.y = -125;
					break;*/
					default:
						persIcon.x = (settings.width - persIcon.width) / 2;
						persIcon.y = -126;
				}
			});
			
			
			var iconBacking:Bitmap = new Bitmap(Window.textures.questCompleTitleDec);
			bodyContainer.addChild(iconBacking);
			iconBacking.x = (settings.width - iconBacking.width)/ 2;
			iconBacking.y = -110;
			
			bodyContainer.addChild(persIcon);
			
			
			//drawMirrowObjs('decorStar', persIcon.x - 50, persIcon.x + persIcon.width + 55, -75, false, false, false, 1, 1, bodyContainer);
		}
		
		override public function contentChange():void
		{	
			if (!quest.bonus) return;
			var bonus:Object = quest.bonus.materials;
			if (questType == DAYLICS) bonus = quest.bonus;
			
			bonusList = new RewardList(bonus, false, settings.width - 50, Locale.__e("flash:1382952380000"), 1, 44, 0, 40, '', 1);
			bonusList.x = 10;
			bonusList.y = descLabel.y + descLabel.textHeight + 4;
			
			var separator:Bitmap = Window.backingShort(350, 'dividerLine', false);
			separator.x = 70;
			separator.y = bonusList.y + 50;
			separator.alpha = 0.5;
			bodyContainer.addChild(separator);
			
			var separator2:Bitmap = Window.backingShort(350, 'dividerLine', false);
			separator2.x = 70;
			separator2.y = bonusList.y + 160;
			separator2.alpha = 0.5;
			bodyContainer.addChild(separator2);
			
			bodyContainer.addChild(bonusList);
		}
		
		override public function close(e:MouseEvent = null):void {
			super.close();
			
			if (Tutorial.mainTutorialComplete && Quests.helpInQuest(settings.qID)) {
				
				// Определить или открыто окно QuestWindow
				var noQuestWindow:Boolean = true;
				if (App.self.windowContainer.numChildren > 0) {
					for (var i:int = 0; i < App.self.windowContainer.numChildren; i++) {
						var window:* = App.self.windowContainer.getChildAt(i);
						if ((window is QuestWindow) || (window is LevelUpWindow) || (window is GoalWindow))
							noQuestWindow = false;
					}
				}
				
				if (noQuestWindow) {
					var questID:int = 0;
					if (settings.finished) {
						questID = Quests.hasHelpInQuest;
						if (Tutorial.showedQuests.indexOf(questID) >= 0) {
							questID = 0;
						}else {
							Tutorial.showedQuests.push(questID);
						}
					}else if(settings.missionComplete){
						questID = settings.qID;
					}
					
					if (questID) App.user.quests.openWindow(questID);
				}
			}
		}
		
		override public function dispose():void
		{
			okBttn.removeEventListener(MouseEvent.CLICK, close);
			super.dispose();
			
			/*if(InfoWindow.info.hasOwnProperty(settings.qID)) {
				new InfoWindow( {qID:settings.qID} ).show();
			}*/
		}
	}
}