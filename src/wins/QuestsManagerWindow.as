package wins 
{
	import buttons.ImageButton;
	import buttons.UpgradeButton;
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import silin.gadgets.Preloader;
	import ui.QuestIcon;
	import ui.QuestsChaptersIcon;
	
	public class QuestsManagerWindow extends Window
	{
		//public var background:Bitmap;
		public var bttnBackToChapters:ImageButton;
		public var chapterCharacter:Bitmap;
		public var chapterDescTextLabel:TextField;
		public var bonusList:BonusList;
		public var currentQuests:Array = [];
		public var sections:Object = new Object();
		public var items:Vector.<QuestIcon> = new Vector.<QuestIcon>();
		public var questType:String;
		public var rewardTextLabel:TextField;
		
		public function QuestsManagerWindow(settings:Object = null):void
		{
			if (settings == null) {
				settings = new Object();
			}
			
			App.data;
			App.user;
			
			settings['width'] = 510;
			settings['height'] = 310;			
			settings['hasTitle'] = true;
			settings['hasButtons'] = true;
			settings['hasPaginator'] = true;
			settings['callback'] = settings.callback || null;			
			settings['faderAsClose'] = false;
			settings['faderClickable'] = false;			
			settings['popup'] = true;
			settings['questID'] = settings.questID;
			settings['pesonage'] = settings.personage;
			settings['questTitle'] = settings.questTitle;
			settings['questDescription'] = settings.questDescription;
			settings['questBonus'] = settings.questBonus;
			settings["itemsOnPage"] = 4;
			settings["openedQuests"] = settings.openedQuests;
			settings["closedQuests"] = settings.closedQuests;
			settings["hasButtons"] = false;
			
			super(settings);
			
			createContent();
		}
		
		override public function close(e:MouseEvent = null):void {
			super.close();
		}		
		
		override public function drawBackground():void {
			background = backing(settings.width + 50, settings.height + 50, 30, 'alertBacking');
			background.x = 90;
			background.y = 10;
			layer.addChild(background);			
		}
		
		override public function drawTitle():void 
		{
			titleLabel = titleText( {
				title				: settings.questTitle,
				color				: settings.fontColor,
				multiline			: settings.multiline,
				fontSize			: settings.fontSize,				
				textLeading	 		: settings.textLeading,				
				borderColor 		: settings.fontBorderColor,			
				borderSize 			: settings.fontBorderSize,						
				shadowBorderColor	: settings.shadowBorderColor || settings.fontColor,
				width				: settings.width - 140,
				textAlign			: 'center',
				sharpness 			: 50,
				thickness			: 50,
				border				: true
			})
			
			titleLabel.x = ((settings.width - titleLabel.width) * .5) + 120;
			titleLabel.y = 0;
			titleLabel.mouseChildren = titleLabel.mouseEnabled = false;
			headerContainer.addChild(titleLabel);
			headerContainer.y = -10;
			headerContainer.mouseEnabled = false;
		}
		
		override public function drawExit():void {
			var exit:ImageButton = new ImageButton(textures.closeBttn);
			headerContainer.addChild(exit);
			exit.x = settings.width + 75;
			exit.y = 10;
			exit.addEventListener(MouseEvent.CLICK, close);
			exit.visible = true;
		}
		
		override public function drawBody():void 
		{
			//drawMirrowObjs('diamondsTop', settings.width / 2 - settings.titleWidth / 2 + 120, settings.width / 2 + settings.titleWidth / 2 + 120, -40, true, true);
			drawBackground();
			drawBttns();
			
			bttnBackToChapters.addEventListener(MouseEvent.CLICK, close);
			
			switch (settings.personage) 
			{
				case 1:
					chapterCharacter = new Bitmap(Window.textures.goalsChatsHuntsman, "auto", true);
				break;
				case 2:
					chapterCharacter = new Bitmap(Window.textures.goalsChatsLady, "auto", true);
				break;
				case 5:
					chapterCharacter = new Bitmap(Window.textures.goalsChatsWoodcutter, "auto", true);
				break;
				case 6:
					chapterCharacter = new Bitmap(Window.textures.goalsChatsSailor, "auto", true);
				case 7:
					chapterCharacter = new Bitmap(Window.textures.goalsChatsTommy, "auto", true);
				break;
				case 9:
					chapterCharacter = new Bitmap(Window.textures.goalsChatsGuide, "auto", true);
				break;
				case 10:
					chapterCharacter = new Bitmap(Window.textures.goalsChatsMiner, "auto", true);
				break;
				case 11:
					chapterCharacter = new Bitmap(Window.textures.goalsChatsBigMarie, "auto", true);
				break;
				case 12:
					chapterCharacter = new Bitmap(Window.textures.goalsChatsSheriff, "auto", true);
				break;
				case 13:
					chapterCharacter = new Bitmap(Window.textures.goalsChatsShepherd, "auto", true);
				break;
				case 15:
					chapterCharacter = new Bitmap(Window.textures.goalsChatsBandit, "auto", true);
				break;
				case 16:
					chapterCharacter = new Bitmap(Window.textures.goalsChatsLadyPink, "auto", true);
				break;
				case 17:
					chapterCharacter = new Bitmap(Window.textures.goalsChatsNewBoy, "auto", true);
				break;
				default:
					chapterCharacter = new Bitmap(Window.textures.goalsChatsHuntsman, "auto", true);
				break;
			}
			
			chapterCharacter.x = background.x - chapterCharacter.width + 90;
			chapterCharacter.y = (background.y - (chapterCharacter.height / 2)) + 170;
			layer.addChild(chapterCharacter);			
			
			/*bonusList = new BonusList(settings.questBonus, true, { hasTitle: false});
			layer.addChild(bonusList);
			bonusList.x = background.x + (background.width / 2) - (bonusList.width / 2);
			bonusList.y = (background.y + (background.height / 2) - (bonusList.height / 2)) + 5;
			
			rewardTextLabel = Window.drawText(Locale.__e('flash:1382952380000'), {
				width		:280,
				fontSize	:25,
				textAlign	:"left",
				color:0xffffff,
				borderColor:0x643a00,
				multiline	:true,
				wrap		:true
			});
			
			layer.addChild(rewardTextLabel);
			rewardTextLabel.x = bonusList.x + bonusList.width - (rewardTextLabel.width / 2);
			rewardTextLabel.y = bonusList.y - 20;*/
			
			chapterDescTextLabel = Window.drawText(Locale.__e('flash:1447338055710'), {
				width		:420,
				fontSize	:24,
				textAlign	:"center",
				color		:0x743f17,
				borderColor	:0xffffff,
				multiline	:true,
				wrap		:true
			});
			
			layer.addChild(chapterDescTextLabel);
			chapterDescTextLabel.x = background.x + (background.width - chapterDescTextLabel.width) / 2;
			chapterDescTextLabel.y = (titleLabel.y + titleLabel.height + 150) / 2 /*- chapterDescTextLabel.height / 2 - 5*/;
			chapterDescTextLabel.visible = true;
			
			for (var i:int = 0; i < settings.content.length; i++)
			{				
				if (settings.content[i].ID == settings.find) {
					paginator.page = int(i / 4);
					sections["all"].page = paginator.page;
					settings.page = paginator.page;
				}
			}
			
			contentChange();
		}
		
		private function drawBttns():void {
			bttnBackToChapters = new ImageButton(Window.texture('homeBttn'));
			layer.addChild(bttnBackToChapters);
			
			bttnBackToChapters.x = background.x + (background.width - bttnBackToChapters.width) / 2;
			bttnBackToChapters.y = (background.y + background.height - (bttnBackToChapters.height / 2)) - 25;
			
			var backText:TextField = Window.drawText(Locale.__e('flash:1447335300608'), {
				textAlign:		'center',
				fontSize:		32,
				color:			0xFFFFFF,
				borderColor:	0x631d0b,
				shadowSize:		1
			});
			backText.x = 20;
			backText.y = (bttnBackToChapters.height - backText.height) / 2;
			bttnBackToChapters.addChild(backText);
		}
		
		private function onBackToChapters (e:Event = null):void 
		{
			close();
		}	
		
		public function createContent():void {
			
			if (sections["all"] != null) return;
			
			sections = {				
				"all"		:{items:new Array(),page:0}
			};
			
			for (var fID:* in settings.finishedQuests) {
				settings.finishedQuests[fID].id = settings.finishedQuests[fID].ID;
				settings.finishedQuests[fID].questType = 'finished';
				if (settings.finishedQuests[fID].type == 0) 
				{
					settings.content.push(settings.finishedQuests[fID]);
					sections["all"].items.push(settings.finishedQuests[fID]);
				}			
			}
			
			for (var ID:* in settings.openedQuests) {
				settings.openedQuests[ID].id = settings.openedQuests[ID].ID;
				settings.openedQuests[ID].questType = 'opened';
				if (settings.openedQuests[ID].type == 0) 
				{
					settings.content.push(settings.openedQuests[ID]);
					sections["all"].items.push(settings.openedQuests[ID]);
				}				
			}
			
			for (var cID:* in settings.closedQuests) {
				settings.closedQuests[cID].id = settings.closedQuests[cID].ID;
				settings.closedQuests[cID].questType = 'closed';
				if (settings.closedQuests[cID].type == 0) 
				{
					settings.content.push(settings.closedQuests[cID]);
					sections["all"].items.push(settings.closedQuests[cID]);
				}			
			}	
		}
		
		override public function contentChange():void {
			
			for each(var _item:QuestIcon in items) {
				layer.removeChild(_item);
				_item = null;
			}
			
			items = new Vector.<QuestIcon>();
			var Xs:int = 225;
		
			for (var i:int = paginator.startCount; i < paginator.finishCount; i++)
			{				
				var item:QuestsChaptersIcon = new QuestsChaptersIcon(settings.content[i], 0, settings.content[i].questType, (settings.content[i].ID == settings.find) ? true : false);				
				layer.addChild(item);
				items.push(item);
				
				item.y = 210;
				item.x = Xs;
				Xs += 80;
			}
			
			sections["all"].page = paginator.page;
			settings.page = paginator.page;
		}
		
		override public function drawArrows():void 
		{			
			paginator.drawArrow(bottomContainer, Paginator.LEFT,  0, 0, { scaleX: -1, scaleY:1 } );
			paginator.drawArrow(bottomContainer, Paginator.RIGHT, 0, 0, { scaleX:1, scaleY:1 } );
			
			var y:int = (settings.height - paginator.arrowLeft.height) / 2 + 46;
			paginator.arrowLeft.x = 150;
			paginator.arrowLeft.y = y + 60;
			
			paginator.arrowRight.x = settings.width - paginator.arrowRight.width + 110;
			paginator.arrowRight.y = y + 60;
			
			paginator.arrowRight.scaleX = paginator.arrowRight.scaleY = 0.8;
			paginator.arrowLeft.scaleX = paginator.arrowLeft.scaleY = 0.8;
			
			paginator.x = int((settings.width - paginator.width)/2 - 20);
			paginator.y = int(settings.height - paginator.height + 40);
		}
	}
}