package wins 
{
	import buttons.Button;
	import buttons.ImageButton;
	import core.Load;
	import core.Numbers;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import ui.QuestIcon;
	import ui.QuestPlusIcon;
	import wins.elements.TimerUnit;

	public class QuestWindow extends Window
	{
		public var missions:Array = [];
		public var okBttn:Button;
		public var quest:Object = { };
		public var isDuration:Boolean = false;
		public var pointedMission:Mission;
		
		private var titleQuest:TextField;
		private var titleShadow:TextField;
		private var descLabel:TextField;
		private var timerText:TextField;
		private var arrowLeft:ImageButton;
		private var arrowRight:ImageButton;
		private var prev:int = 0;
		private var next:int = 0;
		private var _startMissionPosY:int = 100;
		private var _winContainer:Sprite;
		
		public function QuestWindow(settings:Object = null)
		{
			settings['width'] = 520;
			settings['height'] = 620;
			settings['hasTitle'] = false;
			settings['hasButtons'] = true;
			settings["background"] = 'alertBacking';
			settings['hasFader'] = true;
			settings['hasPaginator'] = false;
			settings['hasArrows'] = true;
			settings['qID'] = settings.qID || 2;
			settings['shadowColor'] = 0x513f35;
			settings['shadowSize'] = 4;
			settings['otherQuests'] = settings.otherQuests || null;
			
			if (App.user.quests.tutorial) {
				settings['escExit'] = false;
			}
			
			quest = App.data.quests[settings.qID];
			
			if (quest.dream is Array) {
				if (quest.dream.indexOf(Travel.SAN_MANSANO) != -1 || quest.chapter == 74 || quest.chapter == 75) {
					settings['background'] = 'goldBacking';
				}
			} else if (quest.dream is Object) {
				if (quest.dream.hasOwnProperty(Travel.SAN_MANSANO) || quest.chapter == 74 || quest.chapter == 75) {
					settings['background'] = 'goldBacking';
				}
			}
			
			super(settings);
			
			if (settings.otherQuests) settings.content = settings.otherQuests;
			 else settings.content = App.ui.leftPanel.questsPanel.homeQuests;
			
			for each(var item:* in settings.content) {
				if (settings.qID == item.id) {
					break;
				}
				prev = item.id;
			}
			
			for each(item in settings.content) {
				if (next == -1) {
					next = item.id;
					break;
				}
				if (settings.qID == item.id) {
					next = -1;
				}
			}
			
			if(quest.duration > 0)
				isDuration = true;
				
			App.ui.leftPanel.questsPanel.change();
			
			var questData:Object = App.data.quests[settings.qID];
			var update:String = questData.update;
			if (App.data.updatelist.hasOwnProperty(App.social)) {
				if (App.data.updatelist[App.social][update] + QuestIcon.ONE_WEEK >= App.time) { 
					if (App.user.quests.data.hasOwnProperty(questData.ID) && App.user.quests.data[questData.ID].hasOwnProperty('viewed') && App.user.quests.data[questData.ID].viewed < App.time) {
						
					} else {
						App.user.quests.data[questData.ID]['viewed'] = App.time;
						QuestIcon.sendQuestClick(settings.qID);
					}
				}
			}
		}
		
		private function onStockChange(e:AppEvent):void {
			contentChange();
		}
		
		override public function drawBackground():void 
		{
			if (missions.length == 3)
			{
				bodyContainer.y += 40;
				exit.y += 40;
			}
		}
		
		private var preloader:Preloader = new Preloader();
		override public function drawBody():void 
		{	
			drawMessage();
			
			okBttn = new Button( {
				width:150,
				height:47,
				fontSize:28,
				hasDotes:false,
				caption:Locale.__e("flash:1382952380242")
			});
			
			
			bodyContainer.addChild(okBttn);
			
			okBttn.addEventListener(MouseEvent.CLICK, close);
			
			var character:Bitmap = new Bitmap();
			
			bodyContainer.addChild(preloader);
			preloader.x = -138;
			preloader.y = 184;
			
			var preview:String = (App.data.personages[quest.character]) ? App.data.personages[quest.character].preview : '';
			if (quest.character == 3 || quest.character == 4) preview = App.data.personages[1].preview
			
			Load.loading(Config.getImageIcon('quests/preview', preview), function(data:*):void { 
				if (bodyContainer.contains(preloader))
					bodyContainer.removeChild(preloader);
				
				character.bitmapData = data.bitmapData;
				
				character.y = ((_startMissionPosY + 116 * Numbers.countProps(quest.missions) + 60) - character.height) / 2;
				switch(App.data.personages[quest.character].preview) {
					case 'huntsman':
					case 'bear':
					case 'bridge':
						character.x = -180;
						character.y = -30;
					break;
					case 'lady':
						character.x = -180;
						character.y = -20;
					break;
					case 'Tom':
						character.x = -310;
						character.y = 20;
					break;
					case 'vlad':
						character.x = -310;
						character.y = 20;
					break;
					case 'guide':
						character.x = -240;
						character.y = -20;
					break;
					case 'frank':
						character.x = -240;
						character.y = -20;
					break;
					case 'tree':
						character.x = -240;
						character.y = -20;
					break;
					case 'isabella':
						character.x = -240;
						character.y = -20;
					break;
					case 'charbandit':
						character.x = -240;
						character.y = -20;
					break;
					case 'good_girl':
						character.x = -240;
						character.y = -20;
					break;
					case 'ted':
						character.x = -240;
						character.y = -20;
					break;
					case 'miner':
						character.x = -290;
						character.y = 20;
					break;
					default:
						character.x = -180;
						character.y = -20;
				}
				
				bodyContainer.addChildAt(character,0);
			});
			contentChange();
			okBttn.x = (settings.width - okBttn.width) / 2;
			okBttn.y = background.height - okBttn.height - 10;
			
			arrowLeft = new ImageButton(Window.textures.arrow, {scaleX:-1,scaleY:1});
			arrowRight = new ImageButton(Window.textures.arrow, {scaleX:1,scaleY:1});
			
			arrowLeft.addEventListener(MouseEvent.MOUSE_DOWN, onPrevQuest);
			arrowRight.addEventListener(MouseEvent.MOUSE_DOWN, onNextQuest);
			
			if(next > 0){
				bodyContainer.addChild(arrowRight);
				arrowRight.x = okBttn.x + okBttn.width + 105;
				arrowRight.y = okBttn.y - 15;
			}
			
			if(prev > 0){
				bodyContainer.addChild(arrowLeft);
				arrowLeft.x = okBttn.x - arrowLeft.width - 105;
				arrowLeft.y = okBttn.y - 15;
			}
			
			if (App.user.quests.tutorial || [32].indexOf(settings.qID) >= 0) {
				arrowLeft.visible = false;
				arrowRight.visible = false;
			}
			
			if (settings.otherQuests) {
				okBttn.visible = false;
				arrowLeft.visible = false;
				arrowRight.visible = false;
			}
			App.self.addEventListener(AppEvent.ON_CHANGE_STOCK, onStockChange);
			
			if (App.data.quests[settings.qID].duration > 0) {
				drawTime();
			}
		}
		
		public function drawTime():void  {
			var timer:TimerUnit = new TimerUnit( {backGround:'glow',width:140,height:60,time: { started:App.user.quests.data[settings.qID].created, duration:App.data.quests[settings.qID].duration }} );
			timer.start();
			timer.y += 25;
			bodyContainer.addChild(timer);
		}
		
		override public function drawFader():void {
			super.drawFader();
			
			this.x += 120;
			fader.x -= 120;
		}
		
		private function onPrevQuest(e:MouseEvent):void {
			close();
			App.user.quests.openWindow(prev);
		}
		
		private function onNextQuest(e:MouseEvent):void {
			close();
			App.user.quests.openWindow(next);
		}
		
		private var titleQuestContainer:Sprite;
		private function drawMessage():void 
		{
			var titlePadding:int = 20;
			var descPadding:int = 50;
			var descMarginX:int = 10;
			
			_winContainer = new Sprite();
			titleQuestContainer = new Sprite();
			titleQuest = Window.drawText(quest.title, {
				color:0xFFFFFF,
				textLeading: -10,
				borderColor:0xa9784b,
				fontSize:48,
				multiline:true,
				textAlign:"center",
				wrap:true,
				width:300,
				shadowColor:0x513f35,
				shadowSize:4
			});
			titleQuest.wordWrap = true;
			
			var descSize:int = 26;
			
			do{
				descLabel = Window.drawText(quest.description, {
					color:0x532b07,
					border:true,
					borderColor:0xfde1c9,
					fontSize:descSize,
					multiline:true,
					autoSize: 'center',
					textAlign:"center"
				});
				
				descLabel.wordWrap = true;
				descLabel.width = 330;
				descSize -= 1;	
			}
			while (descLabel.height > 100) 
		
			var curHeight:int;
			if (titleQuest.height < 60) {
				curHeight = titleQuest.height + descLabel.height + titlePadding;
			} else {
				curHeight = titleQuest.height + descLabel.height + titlePadding - 25;
			}
			
			var marginSpriteY:int = 65;
			
			titleQuest.height = titleQuest.textHeight + 10; 
			
			titleQuest.x = 40;
			titleQuest.y = 40;
			
			if (titleQuest.height < 70) {
				titleQuest.y = 55;
				drawMirrowObjs('titleDecRose', titleQuest.x - 50, titleQuest.x + titleQuest.width + 50, titleQuest.y + titleQuest.height / 2 - 15, false, false, false, 1, 1, titleQuestContainer);
				descLabel.y = titleQuest.y + titleQuest.height + 10;
			} else {
				drawMirrowObjs('titleDecRose', titleQuest.x - 60, titleQuest.x + titleQuest.width + 60, titleQuest.y + titleQuest.height / 2 - 15, false, false, false, 1, 1, titleQuestContainer);
				descLabel.y = titleQuest.y + titleQuest.height - 5;
			}
			
			descLabel.x = descMarginX;
			
			titleQuestContainer.addChild(titleQuest);
			
			_winContainer.addChild(titleQuestContainer);
			_winContainer.addChild(descLabel);
			
			bodyContainer.addChild(_winContainer);
			
			_winContainer.x = 90;
			_winContainer.y = - marginSpriteY;
		}
		
		public function progress(mID:int):void {
			contentChange();
			for each(var item:Mission in missions) {
				if (item.mID == mID) {
					item.progress();
				}
			}
		}
		
		private var bonusList:Sprite;
		private var newHeight:int;
		override public function contentChange():void {
			var item:Mission;
			for each(item in missions) {
				bodyContainer.removeChild(item);
				item.dispose();
				item = null;
			}
			
			if (!_winContainer) return;
			
			missions = [];
			pointedMission = null;
			
			bonusList = new BonusList(quest.bonus.materials, true, {background:'fadeOutYellow', bgAlpha:0.5, titleColor:0xffdd70, titleBorderColor:0x5c371a, shadowColor:0x5c371a, shadowSize:1, bonusBorderColor:0x543211});
			bonusList.x = (settings.width - bonusList.width) / 2;
			bonusList.y = _winContainer.y + _winContainer.height + 60;
			bodyContainer.addChild(bonusList);
			
			var separator:Bitmap = Window.backingShort(bonusList.width - 5, 'dividerLine', false);
			separator.x = bonusList.x + 5;
			separator.y = bonusList.y;
			separator.alpha = 0.5;
			bodyContainer.addChild(separator);
			
			var separator2:Bitmap = Window.backingShort(bonusList.width - 5, 'dividerLine', false);
			separator2.x = bonusList.x + 5;
			separator2.y = bonusList.y + bonusList.height - 4;
			separator2.alpha = 0.5;
			bodyContainer.addChild(separator2);
			///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
			
			var margin:int = 0;
			_startMissionPosY = bonusList.y + bonusList.height + 20;
			
			var itemNum:int = 0;
			for (var mID:* in quest.missions) {
				item = new Mission(settings.qID, mID, this);
				item.x = (settings.width - item.background.width) / 2;
				item.y = _startMissionPosY + 100 * itemNum + margin;
				bodyContainer.addChild(item);
				
				missions.push(item);
				if (id == mID) {
					item.progress();
				}
				
				itemNum++;
			}
			
			if (pointedMission && bodyContainer.getChildIndex(pointedMission) < bodyContainer.numChildren - 1)
				bodyContainer.swapChildren(pointedMission, bodyContainer.getChildAt(bodyContainer.numChildren - 1));
			
			if (background)
				layer.removeChild(background);
			
			newHeight = _startMissionPosY + 100 * (itemNum + 1) + margin - 20;
			background = backing(settings.width, newHeight, 120, settings.background);
			layer.addChildAt(background, 0);
			
			if (settings.otherQuests) {
				drawPanel();
			}
		}
		
		private var questPanel:Sprite;
		private const QUESTS:int = 4;
		private var questBegin:int = 0;
		private var promoPaginator:Paginator;
		private var icons:Vector.<QuestIcon> = new Vector.<QuestIcon>;
		private function drawPanel():void {
			questPanelClear();
			
			if (!questPanel) {				
				questPanel = new Sprite();
				bodyContainer.addChildAt(questPanel,bodyContainer.numChildren - 1);
			}
			
			var X:int = 0;
			for (var i:int = 0; i < settings.otherQuests.length; i++) {
				if (i >= QUESTS || settings.otherQuests.length <= i + questBegin) continue;
				
				var icon:QuestPlusIcon = new QuestPlusIcon(settings.otherQuests[i + questBegin], settings.otherQuests, true);
				icon.x = i * 75 + X;
				icons.push(icon);
				questPanel.addChild(icon);
				
				X += 20;
				if (settings['qID'] == settings.otherQuests[i + questBegin].id) {
					icon.startGlowing();
				}
			}
			
			questPanel.x = (settings.width - questPanel.width) / 2;
			questPanel.y = newHeight - 60;
			
			if (settings.otherQuests.length - QUESTS > 0 && !promoPaginator) {
				promoPaginator = new Paginator(settings.otherQuests.length - QUESTS + 1, 1, 0, {
					hasButtons:		false
				});
				promoPaginator.drawArrow(bodyContainer, Paginator.LEFT, questPanel.x - 84, questPanel.y + 10, { scaleX: -1, scaleY:1} );
				promoPaginator.drawArrow(bodyContainer, Paginator.RIGHT, questPanel.x + questPanel.width, questPanel.y + 10, { scaleX:1, scaleY:1 } );
				promoPaginator.addEventListener(WindowEvent.ON_PAGE_CHANGE, onPaginatorPageChange);
			}
		}
		
		private function onPaginatorPageChange(e:WindowEvent = null):void {
			questBegin = promoPaginator.page;
			drawPanel();
		}
		
		private function questPanelClear():void {
			if (questPanel) {
				for each (var icon:QuestIcon in icons) {
					icon.dispose();
				}
				icons = new Vector.<QuestIcon>;
			}
		}
		
		override public function dispose():void {
			if (okBttn)
				okBttn.removeEventListener(MouseEvent.CLICK, close);
			
			App.self.removeEventListener(AppEvent.ON_CHANGE_STOCK, onStockChange);
			
			if (_winContainer && _winContainer.parent)_winContainer.parent.removeChild(_winContainer);
			_winContainer = null;
			
			questPanelClear();
			super.dispose();
		}
		
	}

}
import buttons.Button;
import buttons.MenuButton;
import buttons.MoneyButton;
import buttons.MoneySmallButton;
import core.Load;
import core.Size;
import flash.display.Bitmap;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.filters.GlowFilter;
import flash.geom.Point;
import flash.text.TextField;
import ui.Hints;
import ui.UserInterface;
import wins.Window;
import wins.RouletteWindow;
import wins.SimpleWindow;
import wins.TravelWindow;


internal class Mission extends Sprite {
	
	public var qID:int;
	public var mID:int;
	public var background:Bitmap;
	public var bitmap:Bitmap = new Bitmap();
	public var mission:Object = { };
	public var quest:Object = { };
	public var counterLabel:TextField;
	public var titleLabel:TextField;
	public var skipBttn:MoneyButton;
	public var helpBttn:MenuButton;
	public var circle:Shape;
	
	private var preloader:Preloader = new Preloader();
	private var window:*;
	private var titleDecor:Bitmap;
	private var sprite:LayerX = new LayerX();
	
	public function Mission(qID:int, mID:int, window:*) {
		
		this.qID = qID;
		this.mID = mID;
		this.window = window;
		
		background = Window.backing(250, 70, 50, 'fadeOutWhite');
		background.alpha = 0.2;
		background.x = 20;
		background.y = 15;
		addChild(background);
		
		var separator:Bitmap = Window.backingShort(background.width, 'dividerLine', false);
		separator.x = background.x;
		separator.y = background.y;
		separator.alpha = 0.5;
		addChild(separator);
		
		var separator2:Bitmap = Window.backingShort(background.width, 'dividerLine', false);
		separator2.x = background.x;
		separator2.y = background.y + background.height - 4;
		separator2.alpha = 0.5;
		addChild(separator2);
		
		var rad:int = 45;
		circle = new Shape();
		circle.graphics.beginFill(0xc8cabc, 1);
		circle.graphics.drawCircle(0, 0, rad);
		circle.graphics.endFill();
		circle.x = -20;
		circle.y = rad;
		addChild(circle);
		
		addChild(sprite);
		sprite.addChild(bitmap);
		
		quest = App.data.quests[qID];
		mission = App.data.quests[qID].missions[mID];
		
		var sID:*;
		if(mission.target is Object){
			for each(sID in mission.target) {
				break;
			}
		} else if (mission.map is Object) {
			for each(sID in mission.map) {
				break;
			}
		}
		// На гостевые действия показывать лопаты
		if ((sID == undefined) && (mission.event == 'guestkick' || mission.event == 'state')) 
			sID = Stock.GUESTFANTASY;
		//на рулетку показывать текущую валюту рулетки
		if (sID == undefined && mission.controller == 'roulette') 
			sID = RouletteWindow.CURRENCY;
			
		if (mission.event == 'zone') sID = 27; // золотой самородок
		if (sID == 913) sID = 852; 
		
		if(sID > 0 && App.data.storage[sID] != undefined){
			
			var url:String;
			if (sID == 0 || sID == 1) {
				url = Config.getQuestIcon('missions', mission.preview);
			} else {
				var icon:Object
				if (mission.preview != "" && mission.preview != "1") {
					icon = App.data.storage[mission.preview];
				} else{
					icon = App.data.storage[sID];
				}
				url = Config.getIcon(icon.type, icon.preview);
			}	
			loadIcon(url);
		} else if (qID == 30) {
			loadIcon(Config.getQuestIcon("icons", "druid"));
		}
		
		function loadIcon(url:String):void 
		{
			Load.loading(url, function(data:*):void {				
				bitmap.bitmapData = data.bitmapData;
				Size.size(bitmap, 86, 86);
				
				bitmap.x = circle.x - bitmap.width / 2;
				bitmap.y = circle.y - bitmap.height / 2;
				bitmap.smoothing = true;
				
				sprite.tip = function():Object {
					return {
						title: icon.title,
						text: icon.description
					};
				}
			});
		}
		
		var have:int = (App.user.quests.data.hasOwnProperty(qID)) ? App.user.quests.data[qID][mID] : 0;
		
		var text:String;
		if (mission.func == 'sum') {
			if (have > mission.need)
				have = mission.need;
			
			text = have + '/' + mission.need;
		}else {
			if (have == mission.need) {
				text = '1/1';
			}else {
				text = '0/1';
			}
		}
		
		counterLabel = Window.drawText(text, {
			fontSize:32,
			color:0xfdfef8,
			borderColor:0x45302f,
			shadowSize:1,
			shadowColor:0x45302f,
			autoSize:"left"
		});
		counterLabel.x = circle.x + (circle.width - counterLabel.textWidth) / 2 - 43;
		counterLabel.y = 55;
		addChild(counterLabel);
		
		var descSize:int = 22;
		do {
			titleLabel = Window.drawText(mission.title,{
				fontSize:descSize,
				color:0xfdfbef,
				borderColor:0x4c3a24,
				multiline:true,
				borderSize:4,
				textAlign:"left",
				textLeading: -3,
				wrap:true,
				width:160
			});
			descSize -= 1;	
		}
		while (titleLabel.height > 65)
		titleLabel.height = titleLabel.textHeight + 10;
		titleLabel.x = 40;
		titleLabel.y = (background.height) / 2;
		if (titleLabel.height > 40) {
			titleLabel.y = background.y + (background.height - titleLabel.textHeight) / 2;
		}
		addChild(titleLabel);

		if (have >= mission.need) {
			drawFinished();
		}else{
			drawButtons();
		}
	}
	
	private function drawFinished():void {
		var finishedBg:Bitmap = new Bitmap(Window.textures.checkmarkSlot, "auto", true);
		finishedBg.x = background.width - finishedBg.width + 70;
		finishedBg.y = (background.height - finishedBg.height) / 2 + 15;
		addChild(finishedBg);
		
		var finished:Bitmap = new Bitmap(Window.textures.checkMark, "auto", true);
		finished.x = background.width - finished.width + 70;
		finished.y = (background.height - finished.height) / 2 + 10;
		addChild(finished);
	}
	
	private function drawButtons():void {
		
		if (!window.isDuration && mission.skip > 0) {
			var fontSize:int = (App.lang == 'jp') ? 16 : 22;
			skipBttn = new MoneyButton( {
				caption: Locale.__e("flash:1382952380253"),
				countText:String(mission.skip),
				width:115,
				height:48,
				borderColor:[0xcefc97, 0x5f9c11],
				fontColor:0xFFFFFF,
				fontBorderColor:0x4d7d0e,
				bevelColor:[0xcefc97, 0x5f9c11],
				fontSize:fontSize
			})
			skipBttn.x = background.width - skipBttn.width + 70;
			addChild(skipBttn);
			skipBttn.countLabel.width = skipBttn.countLabel.textWidth + 5;
			skipBttn.addEventListener(MouseEvent.CLICK, onSkipEvent);
		}
		
		helpBttn = new MenuButton( { 
			title:Locale.__e('flash:1382952380254'),
			width:115,
			height:38,
			bgColor:[0x82c9f6,0x5dacde],
			borderColor:[0xa0d5f6, 0x3384b2],
			fontColor:0xFFFFFF,
			fontBorderColor:0x435060,
			bevelColor:[0xc2e2f4,0x3384b2],
			fontSize:22,
			radius:12
		});
		helpBttn.x = background.width - helpBttn.width + 70;
		helpBttn.y = (!skipBttn) ? 30 : 52;
		addChild(helpBttn);
		helpBttn.settings['find'] = mission.find;
		helpBttn.name = 'QuestWindow_helpBttn';
		helpBttn.addEventListener(MouseEvent.CLICK, onHelpEvent);
		
		if (Quests.helpInQuest(qID) && !window.pointedMission) {
			helpBttn.showGlowing();
			if (qID == 12 && mID == 1) {
				
			} else {
				helpBttn.showPointing('bottom', 0, helpBttn.height + 30, this);
			}
			window.pointedMission = this;
		}
		
		if (window.isDuration)
			helpBttn.y = (background.height - helpBttn.height) / 2 + 6;
	}
	
	private function onHelpEvent(e:MouseEvent):void
	{	
		if (qID == 49 && mID == 1) {
			Tutorial.startQuest49();
			return;
		}
		
		if (e.currentTarget.settings.find > 0) {
			Window.closeAll();
			App.user.quests.helpEvent(qID, mID);
		}else {
			new SimpleWindow( {
				popup:true,
				height:300,
				width:420,
				title:Locale.__e('flash:1382952380254'),
				text:App.data.quests[qID].missions[mID].description
			}).show();
		}
	}
	
	public function onSkipEvent(e:MouseEvent):void {
		if (App.user.quests.skipEvent(qID, mID, window.progress)) {
			var pnt:Point = Window.localToGlobal(skipBttn)
			Hints.minus(Stock.FANT, mission.skip, new Point(pnt.x - 130, pnt.y - 10), false, window);
			skipBttn.removeEventListener(MouseEvent.CLICK, onSkipEvent);
		};
	}
	
	public function progress():void {
		App.ui.flashGlowing(bitmap, 0xFFFF00, null, false);
	}
	
	public function dispose():void {
		if (skipBttn) skipBttn.removeEventListener(MouseEvent.CLICK, onSkipEvent);
		if (helpBttn) helpBttn.removeEventListener(MouseEvent.CLICK, onHelpEvent);
	}
}