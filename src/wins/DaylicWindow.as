package wins 
{
	import buttons.Button;
	import buttons.ImageButton;
	import core.Load;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import ui.UserInterface;

	public class DaylicWindow extends Window
	{		
		
		public var separator:Bitmap;
		public var missions:Array = [];
		
		public var okBttn:Button;
		public var daylicShopBttn:Button;
		
		public var quest:Object = { };
		private var headBG:Sprite;
		private var titleQuest:TextField;
		private var titleShadow:TextField;
		private var descLabel:TextField;
		private var presLabel:TextField;
		private var timerLabel:TextField;
		
		private var arrowLeft:ImageButton;
		private var arrowRight:ImageButton;
		private var presentBacking:Bitmap;
		private var topBacking:Bitmap;
		private var helpBttn:Button;
		
		private var progressView:Sprite = new Sprite();
		private var presentView:Sprite;
		
		private var prev:int = 0;
		private var next:int = 0;
		
		public function DaylicWindow(settings:Object = null)
		{
			if (settings == null) {
				settings = { };
			}
			
			settings['width'] = 500; // 444;
			settings['height'] = 780;
			
			settings['hasTitle'] = false;
			settings['hasButtons'] = false;
			settings['hasPaginator'] = false;
			settings['background'] = "dailyBacking";	
			
			//if (Quests.currentDID != 0 && App.data.daylics.hasOwnProperty(Quests.currentDID))
			
			settings['qID'] =  Quests.currentDID;
			quest = Quests.daylics[Quests.currentDID];
			super(settings);
			
			if (App.isSocial('YB', 'AI')) {
				pretime = 'のこり: ';
			}
		}
		
		private var pretime:String = '';
		public function timerControll():void {
			timerLabel.text = pretime + TimeConverter.timeToStr(App.nextMidnight - App.time);
		}
		
		override public function drawBackground():void {
			
		}
		
		override public function create():void {
			super.create();
			//layer.swapChildren(bodyContainer, headerContainer);
		}
		
		private var preloader:Preloader = new Preloader();
				
		override public function drawBody():void {
			exit.x -= 115;
			exit.y -= 18;
			
			//helpBttn = drawHelp();
			//helpBttn.x = exit.x - 40;
			//helpBttn.y = exit.y;
			//helpBttn.addEventListener(MouseEvent.CLICK, onHelp);
			//headerContainer.addChild(helpBttn);
			
			
			
			presentBacking = backing(316 + 88, 60,50, "questRewardBacking1");
			presentBacking.x = 			(settings.width - presentBacking.width) / 2;
			presentBacking.y = 654 -  presentBacking.height - 120;
			
			var separator:Bitmap = Window.backingShort(410, 'dividerLine', false);
			separator.x = (settings.width - separator.width) / 2;;
			separator.y = 654 -  presentBacking.height -110;
			separator.alpha = 0.5;
			bodyContainer.addChild(separator);
			
			var separator2:Bitmap = Window.backingShort(410, 'dividerLine', false);
			separator2.scaleY = -1;
			separator2.x = (settings.width - separator2.width) / 2;;
			separator2.y = 654 -  presentBacking.height - 40 -20;
			separator2.alpha = 0.5;
			bodyContainer.addChild(separator2);
			
			//bodyContainer.addChild(presentBacking);
			
			drawMessage();
			okBttn = new Button( {
				width:157,
				height:47,
				fontSize:28,
				caption:Locale.__e("flash:1382952380298")
			});
			bodyContainer.addChild(okBttn);
			
			okBttn.addEventListener(MouseEvent.CLICK, close);
			
			//daylicShopBttn = new Button( {
				//width:138,
				//height:38,
				//fontSize:28,
				//caption:Locale.__e("flash:1382952379765")
			//});
			//
			//daylicShopBttn.addEventListener(MouseEvent.CLICK, openDaylicShop);
			
			//var character:Bitmap = new Bitmap();
			//
			//bodyContainer.addChild(preloader);
			//preloader.x = 38;
			//preloader.y = 84;
			
			//Load.loading(Config.getQuestIcon('preview', App.data.personages[quest.character].preview), function(data:*):void { 
				//bodyContainer.removeChild(preloader);
				//
				//character.bitmapData = data.bitmapData;
				//character.x = (-(character.width / 4) * 3) - 40;
				//character.y = 30;
				//
				//bodyContainer.addChild(character);
				//bodyContainer.addChild(daylicShopBttn);
			//});
			
			infoUpdate(true);
			
			okBttn.x = (settings.width - okBttn.width) / 2;
			okBttn.y = 624 - okBttn.height/2 - 5;
			
			arrowLeft = new ImageButton(Window.textures.arrow, {scaleX:-0.7,scaleY:0.7});
			arrowRight = new ImageButton(Window.textures.arrow, {scaleX:0.7,scaleY:0.7});
			
			arrowLeft.addEventListener(MouseEvent.MOUSE_DOWN, onPrevQuest);
			arrowRight.addEventListener(MouseEvent.MOUSE_DOWN, onNextQuest);
			
			if(prev > 0){
				bodyContainer.addChild(arrowLeft);
				arrowLeft.x = okBttn.x - arrowLeft.width - 40;
				arrowLeft.y = okBttn.y + 2;
			}
			
			if(next > 0){
				bodyContainer.addChild(arrowRight);
				arrowRight.x = okBttn.x + okBttn.width + 54;
				arrowRight.y = okBttn.y + 2;
			}
			
			settings.height = 624; //okBttn.y + okBttn.height - 14;
			var background:Bitmap = backing(settings.width, settings.height, 50, "dailyBacking");//фон
			bodyContainer.addChildAt(background, 0);
			
			bodyContainer.x = -bodyContainer.width/4 - 20;
			App.self.setOnTimer(timerControll);
			
			drawAddonDaylic();
		}
		
		private function openDaylicShop(e:Event = null):void {
			close();
			var daylicWindow:DaylicsShopWindow = new DaylicsShopWindow( {
					popup: true
				}
			);
			daylicWindow.y += 40;
			daylicWindow.show();
			daylicWindow.fader.y -= 40;
		}
		
		private function onPrevQuest(e:MouseEvent):void {
			close();
			App.user.quests.openWindow(prev);
		}
		
		private function onNextQuest(e:MouseEvent):void {
			close();
			App.user.quests.openWindow(next);
		}
		
		private function drawMessage():void {
			if (titleQuest) {
				bodyContainer.removeChild(titleQuest);
				bodyContainer.removeChild(descLabel);
				bodyContainer.removeChild(timerLabel);
				bodyContainer.removeChild(presLabel);
				bodyContainer.removeChild(headBG);
			}
			
			headBG = new Sprite();
			
			titleQuest = Window.drawText(Locale.__e('flash:1442502071077'), {
				color:0xFFFFFF,
				borderColor:0xc39c51,
				fontSize:41,
				multiline:true,
				textAlign:"center",
				wrap:true,
				width:320,
				filters: [new DropShadowFilter(2, 90, 0x604729, 1, 0, 0, 1, 1)]
			});
			titleQuest.wordWrap = true;
			titleQuest.width = 320;
			titleQuest.height = titleQuest.textHeight + 10;
			
			
			titleQuest2 = Window.drawText(Locale.__e('flash:1442502071077'), {
				color:0x513d36,
				borderColor:0x513d36,
				fontSize:41,
				multiline:true,
				textAlign:"center",
				wrap:true,
				width:320,
				filters: [new DropShadowFilter(2, 90, 0x604729, 1, 0, 0, 1, 1)]
			});
			titleQuest2.wordWrap = true;
			titleQuest2.width = 320;
			titleQuest2.height = titleQuest.textHeight + 10;
			
			drawMirrowObjs('titleDecRose', titleQuest.x + 30 , titleQuest.x + titleQuest.width + 140, titleQuest.y + /*titleQuest.height / 2 */- 15, false, false, false, 1, 1, bodyContainer);
			
			var text:String = '';
			if (Quests.daylics[2] && Quests.daylics[2].hasOwnProperty('description')) {
				text = Quests.daylics[2].description.replace(/\r/g, "");
			}
			descLabel = Window.drawText(text, {
				color:0x532e02,
				border:true,
				fontSize:24,
				multiline:true,
				borderColor:0xfce8cd,
				borderSize: 1,	
				textAlign:"center"
			});
			descLabel.wordWrap = true;
			descLabel.width = 380;
			descLabel.height = descLabel.textHeight + 10;
			
			timerLabel = Window.drawText('', {
				color:0xfae28c,
				borderColor:0x763b13,
				fontSize:34,
				textAlign:"center",
				width:320,
				filters: [new DropShadowFilter(2, 90, 0x604729, 1, 0, 0, 1, 1)]
			});
			timerControll();
			timerLabel.width = 280;
			timerLabel.height = timerLabel.textHeight + 10;
			timerLabel.cacheAsBitmap = true;
			
			presLabel = Window.drawText(Locale.__e("flash:1442501972301"), {
				color:0xffdb70,
				borderColor:0x5f3618,
				fontSize:26,
				borderSize: 4,	
				textAlign:"center",
				textLeading:1
			});
			presLabel.width = presLabel.textWidth + 10;
			presLabel.height = presLabel.textHeight + 4;
			presLabel.x = (settings.width - presLabel.width) / 2;
			presLabel.y =  654 - presentBacking.height - 50 - presLabel.height -50; //130 + missions.length * 102;
			bodyContainer.addChild(presLabel);
			
			bodyContainer.addChild(titleQuest2);
			bodyContainer.addChild(titleQuest);
			titleQuest.y = -22;
			titleQuest.x = (settings.width - titleQuest.width) / 2;
			titleQuest2.y = -19;
			titleQuest2.x = (settings.width - titleQuest.width) / 2 - 2;
			
			bodyContainer.addChild(descLabel);
			descLabel.x = (settings.width - descLabel.width) / 2;
			descLabel.y = titleQuest.y + titleQuest.height - 5;
			
			bodyContainer.addChild(timerLabel);
			timerLabel.x = (settings.width - timerLabel.width) / 2;
			timerLabel.y = descLabel.y + descLabel.height - 10;
			
			headBG.x = (settings.width - headBG.width) / 2;
			headBG.y = 86 - headBG.height;
			
			bodyContainer.addChild(headBG);
		}
		
		public function infoUpdate(allUpdate:Boolean = false):void {
			if (Quests.currentDID == 0) return;
			
			for (var i:int = 0; i < missions.length; i++) {
				var child:Mission = missions[i] as Mission;
				if (Quests.currentDID == child.qID) {
					child.update();
				}else {
					allUpdate = true;
					settings['qID'] = Quests.currentDID;
					quest = Quests.daylics[Quests.currentDID];
				}
			}
			
			if (allUpdate) {
				titleQuest.text = Quests.daylics[Quests.currentDID].title;
				descLabel.text = quest.description.replace(/\r/g, "");
				
				contentChange();
				drawMessage();
				drawStage();
				drawBonus();
			}
		}
		
		public var stageList:Array = [];
		public function drawStage():void {
			clearStageList();
			
			const indent:int = 2;
			var complete:Boolean = false;
			var arrow:Bitmap;
			
			var point1:Bitmap;
			var point2:Bitmap;
			var point3:Bitmap;
			var point4:Bitmap;
			
			var separator:Bitmap = Window.backingShort(55, 'dividerLine', false);
			separator.scaleY = -1;
			separator.x = 45;
			separator.y = -30;
			separator.alpha = 0.5;
			
			var separator2:Bitmap = Window.backingShort(55, 'dividerLine', false);
			separator2.scaleY = -1;
			separator2.x = 145;
			separator2.y = -30;
			separator2.alpha = 0.5;
				
			var pos:int = 0;
			for (var i:int = 0; i < 3/*Quests.daylicsList.length*/; i++) {
				if (Quests.daylicsList[i].finished == 0 && !arrow) {
					arrow = new Bitmap(Window.textures.arrowNewYellowWWhite, 'auto', true);
					arrow.rotation = -90;
					arrow.smoothing = true;
					arrow.scaleX = arrow.scaleY = 0.5;
					arrow.x = pos + 7;
					arrow.y = 70 - 116;
				}
				
				var currStage:LayerX = new LayerX();
				var stageLabel:Bitmap;
				var countLabel:TextField;
				var stageText:TextField;
				if (Quests.daylicsList[i].finished > 0) {
					stageLabel = new Bitmap(Window.textures.stagesCompleteSlot, 'auto', true);
					stageLabel.y = - 41;
				}else {
					stageLabel = new Bitmap(Window.textures.stagesEmptySlot, 'auto', true);
					countLabel = Window.drawText(String(i+1), {
						color:0xffffff,
						borderColor:0x493627,
						fontSize:22,
						textAlign:"center"
					});
					countLabel.width = countLabel.textWidth + 4;
					countLabel.height = countLabel.textHeight + 4;
					countLabel.x = Math.floor((stageLabel.width - countLabel.width)/2);
					countLabel.y = -45;
					stageLabel.y = -41;
					
					stageText = Window.drawText(Locale.__e('flash:1442499086598'), {    //этап
						fontSize:		16,
						color:0xffffff,
						borderColor:0x493627,
						autoSize:		'center'
					});
					stageText.x = Math.floor((stageLabel.width - stageText.width)/2);
					stageText.y = - 25;
					stageLabel.y = - 48;
				}
				currStage.x = pos + indent;
				currStage.y = -currStage.height;
				currStage.addChild(stageLabel);
				pos += currStage.width + indent + 66;
				
				if (countLabel) {
					currStage.addChild(countLabel);
					currStage.addChild(stageText);
				}
				progressView.addChild(currStage);
				progressView.addChild(separator);
				progressView.addChild(separator2);
				
				if(arrow != null)
					progressView.addChild(arrow);
				
				stageList.push(currStage);
			}
			
			progressView.x = Math.floor((settings.width - progressView.width) / 2);
			progressView.y = 165;
			
			bodyContainer.addChild(progressView);
		}
		public function clearStageList():void {
			while (progressView.numChildren > 0) {
				progressView.removeChildAt(0);
			}
			stageList = [];
		}
		
		public function drawBonus():void {			
			var bg:Bitmap = Window.backing(400, 42, 50, 'fadeOutYellow');
			bg.alpha = 0.4;
			bodyContainer.addChild(bg);
			
			bonusList = new BonusList(Quests.daylics[Quests.currentDID].bonus, false, { 
					hasTitle:false,
					background:'questRewardBacking',
					width: 200,
					height: 60,
					size:30,
					bgWidth:60,
					bgX: -3,
					bgY:5,
					titleColor:0x571b00,
					titleBorderColor:0xfffed7,
					bonusTextColor:0x3a1e08,
					bonusBorderColor:0xffffd9
					
				} );
			bodyContainer.addChild(bonusList);
			bonusList.x = (settings.width - bonusList.width) / 2 - 10;
			bonusList.y = presentBacking.y;
			
			bg.x = 45;
			bg.y = presentBacking.y + 13;
		}
		
		private function drawAddonDaylic():void {
			
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
		private var titleQuest2:TextField;
		override public function contentChange():void {
			for each(var item:Mission in missions) {
				bodyContainer.removeChild(item);
				item.dispose();
				item = null;
			}
			missions = [];
			
			var itemNum:int = 0;
			for(var mID:* in quest.missions) {
				
				item = new Mission(settings.qID, mID, this);
				
				bodyContainer.addChild(item);
				item.x = (settings.width - item.background.width) / 2;
				item.y = (150 + 75 + 104 * itemNum) - 70;
				
				missions.push(item);
				
				if (id == mID) {
					item.progress();
				}
				
				itemNum++;
			}
			
			/*var quest2:Object = Quests.daylics[4];
			for(var mID2:* in quest2.missions) {
				
				item = new Mission(4, mID2, this);
				
				bodyContainer.addChild(item);
				item.x = (settings.width - item.background.width) / 2;
				item.y = 570;
				
				missions.push(item);
				
				if (id == mID2) {
					item.progress();
				}
				
				itemNum++;
			}*/
		}
		
		public function showTake(dID:uint):void {
			for(var i:String in App.data.daylics[dID].bonus) {
				var item:BonusItem = new BonusItem(uint(i), App.data.daylics[dID].bonus[i]);
				item.cashMove(new Point(presentBacking.x + presentBacking.width / 2, presentBacking.y + presentBacking.height / 2), App.self.windowContainer);
			}
		}
		
		override public function dispose():void {
			okBttn.removeEventListener(MouseEvent.CLICK, close);
			App.self.setOffTimer(timerControll);
			
			super.dispose();
		}
		
		override public function drawFader():void {
			super.drawFader();
			
			this.x += 150;
			fader.x -= 150;
		}
		
	}

}
import buttons.Button;
import buttons.MoneyButton;
import core.Load;
import flash.display.Bitmap;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.text.TextField;
import flash.utils.setTimeout;
import ui.UserInterface;
import wins.Window;
import wins.SimpleWindow;
import units.Field;


internal class Mission extends Sprite {
	
	public var qID:int;
	public var mID:int;
	
	public var background:Bitmap;
	public var bitmap:Bitmap = new Bitmap();
	
	public var mission:Object = { };
	public var quest:Object = { };
	public var have:int = 0;
	public var text:String = '';
	
	public var counterLabel:TextField;
	public var titleLabel:TextField;
	public var presLabel:TextField;
	
	public var helpBttn:Button;
	public var rewards:Sprite;
	
	private var preloader:Preloader = new Preloader();
	
	private var window:*;
	private var sID:*;
	public function Mission(qID:int, mID:int, window:*) {
		
		this.qID = qID;
		this.mID = mID;
		
		this.window = window;
		
		background = Window.backing2(440, 106, 44, 'questTaskBackingTop', 'questTaskBackingBot')//фоны самих квестов
		//addChild(background);
		
		var bg:Bitmap = Window.backing(300, 70, 50, 'fadeOutWhite');
		bg.x = 60;
		bg.y = 15;
		bg.alpha = 0.2;
		addChild(bg);
		
		var separator:Bitmap = Window.backingShort(300, 'dividerLine', false);
		separator.x = 60;
		separator.y = 15;
		separator.alpha = 0.5;
		addChild(separator);
		
		var separator2:Bitmap = Window.backingShort(300, 'dividerLine', false);
		separator2.scaleY = -1;
		separator2.x = 60;
		separator2.y = 90 - 1;
		separator2.alpha = 0.5;
		addChild(separator2);
		
		var rad:int = 45;
		circle = new Shape();
		circle.graphics.beginFill(0xc8cabc, 1);
		circle.graphics.drawCircle(0, 0, rad);
		circle.graphics.endFill();
		circle.x = 70;
		circle.y = rad + 10;
		addChild(circle);
		
		addChild(bitmap);
		
		quest = Quests.daylics[qID];
		mission = Quests.daylics[qID].missions[mID];
		
		
		if(mission.target is Object){
			for each(sID in mission.target) {
				break;
			}
		}else if (mission.map is Object) {
			for each(sID in mission.map) {
				break;
			}
		}
		
		if(sID!= null && App.data.storage[sID] != undefined){
			
			var url:String;
			if (sID == 0 || sID == 1) {
				url = Config.getQuestIcon('missions', mission.preview);
			}else {
				var icon:Object = App.data.storage[sID];
				url = Config.getIcon(icon.type, icon.preview);
			}
			
			
			addChild(preloader);
			preloader.x = 40;
			preloader.y = 40;
			
			Load.loading(url, function(data:*):void {
				
				removeChild(preloader);
				
				bitmap.bitmapData = data.bitmapData;
				if (bitmap.height > 70) {
					bitmap.scaleX = bitmap.scaleY = 70 / bitmap.height;
				}
				if (bitmap.width > 70) {
					bitmap.scaleX = bitmap.scaleY = 70 / bitmap.width;
				}
				
				bitmap.smoothing = true;
				bitmap.x = ((90 - bitmap.width) / 2) + 25;
				bitmap.y = (106 - bitmap.height)/2;
				
			});
		}
		
		update();
		
		counterLabel = Window.drawText(text, {
			fontSize:32,
			color:0xffffff,
			borderColor:0x2D2D2D,
			autoSize:"left"
		});
		
		counterLabel.x = ((90 - counterLabel.width) / 2) + 25;
		counterLabel.y = 70;
		addChild(counterLabel);
		
		titleLabel = Window.drawText(mission.title, {
			fontSize:24,
			color:0xfefaf1,
			borderColor:0x423620,
			multiline:true,
			borderSize:5,
			textAlign:"center",
			textLeading:-3
		});
		titleLabel.wordWrap = true;
		titleLabel.width = 186;
		titleLabel.height = titleLabel.textHeight+10;
		
		titleLabel.x = 130;
		titleLabel.y = (background.height - titleLabel.height) / 2;
		addChild(titleLabel);
		
		if (mission.func == "subtract") 
		{
			if (have >= mission.need) {// засчитано
				drawFinished();
			}else {
				if(App.user.stock.count(sID) >= mission.need)// можно снять
					drawSubstructButtons();
				else
					drawButtons();// не хватает для снятия
			}
		}else {
			if (have >= mission.need) {
				drawFinished();
			}else{
				drawButtons();
			}
		}
		
		if(mission.hasOwnProperty('bonus') && mission.need > have) {
			var nums:int = 0;
			rewards = new Sprite(); App.data.daylics;
			for (var s:String in mission.bonus) {
				var item:PresentItem = new PresentItem(s, String(mission.bonus[s]), {bitmapSize:20});
				item.x = (50 * nums) - 60;
				item.y += 15;
				rewards.addChild(item);
				nums++;
			}
			rewards.x = background.width - 50 * nums - 20;
			rewards.y = 16;
			addChild(rewards);
		}
	}
	
	public function update():void {
		have = quest.progress[mID];
		if (have > mission.need) have = mission.need;
		
			
		
		if(mission.func == 'sum'){
			text = have + '/' + mission.need;
		}else if (mission.func == "subtract") {
			if (have >= mission.need) {
				text = have + '/' + mission.need;
			}else{
				text = App.user.stock.count(sID) + '/' + mission.need;
			}
		}else {
			if (have == mission.need) {
				text = '1/1';
			}else {
				text = '0/1';
			}
		}
		if(counterLabel)
			counterLabel.text = text;
		
		if (have >= mission.need && rewards) {
			take(App.data.daylics[qID].missions[mID].bonus);
			removeChild(rewards);
			rewards = null;
			presLabel.visible = false;
			helpBttn.visible = false;
			drawFinished();
		}
	}
	private function take(items:Object):void {
		for(var i:String in items) {
			var item:BonusItem = new BonusItem(uint(i), items[i]);
			var point:Point = Window.localToGlobal(rewards);
			item.cashMove(point, App.self.windowContainer);
		}
	}
	
		private var substructBttn:Button;
		private var circle:Shape;
	
	private function drawSubstructButtons():void {
		substructBttn = new Button( { 
			caption:Locale.__e('flash:1433939122335'),
			width:115,
			height:38,
			fontSize:22,
			radius:12
		});
		substructBttn.x = background.width - substructBttn.width - 30;
		substructBttn.y = 62;
		substructBttn.textLabel.x -= 15;
		
		var takenedIconBttn:Bitmap = new Bitmap(Window.textures.takenedItemsIco);
		takenedIconBttn.scaleX = takenedIconBttn.scaleY = 0.75;
		takenedIconBttn.smoothing = true;
		takenedIconBttn.x = substructBttn.textLabel.x + substructBttn.textLabel.width - 25;
		takenedIconBttn.y = -3;
		substructBttn.addChild(takenedIconBttn);
		
		addChild(substructBttn);
		substructBttn.showGlowing();
		substructBttn.addEventListener(MouseEvent.CLICK, onSubstructEvent);
		
		//if (window.isDuration)
		//	substructBttn.y = (background.height - substructBttn.height) / 2 + 6;
	}
	
	private function onSubstructEvent(e:MouseEvent):void {
		App.user.quests.subtractEvent(qID, mID, window.progress,'daylics');
	}
	
	
	
	private function drawFinished():void {
		
		//var bg:Bitmap = new Bitmap(Window.textures.stageEmpty);
		//var mark:Bitmap = new Bitmap(Window.textures.stageComplete);
	 //
		//bg.x = 375;
		//mark.x = 385;
		//bg.y += 23;
		//mark.y += 23;
		//
		//addChild(bg);
		//addChild(mark);
		
		var finishedBg:Bitmap = new Bitmap(Window.textures.checkmarkSlot, "auto", true);
		finishedBg.x = background.width - finishedBg.width - 30;
		finishedBg.y = (background.height - finishedBg.height) / 2/* + 15*/;
		addChild(finishedBg);
		
		var finished:Bitmap = new Bitmap(Window.textures.checkMark, "auto", true);
		finished.x = background.width - finished.width - 30;
		finished.y = (background.height - finished.height) / 2/* + 10*/;
		addChild(finished);
	}
	
	private function drawButtons():void {
		presLabel = Window.drawText(Locale.__e("flash:1382952380000"), {
			fontSize:24,
			color:0xffda6f,
			borderSize: 2,	
			borderColor:0x6b3922,
			multiline:false,
			textLeading:-2
		});
		presLabel.width = 156;
		presLabel.height = presLabel.textHeight+4;
		presLabel.x = background.width - 130;
		presLabel.y = -1;
		addChild(presLabel);
		
		helpBttn = new Button( { 
			caption:Locale.__e('flash:1382952380254'),
			width:107,
			height:38,
			bgColor:[0x81caf7,0x5aaddf],
			borderColor:[0xbdd3e0, 0x3282b3],
			fontColor:0xFFFFFF,
			fontBorderColor:0x3f4b61,
			bevelColor:[0xd8e7ae,0x4f9500],
			fontSize:22,
			radius:12
		});
		
		addChild(helpBttn);
		helpBttn.x = background.width - helpBttn.width - 30;
		helpBttn.y = 60;
		helpBttn.settings['find'] = mission.find;
		
		helpBttn.addEventListener(MouseEvent.CLICK, onHelpEvent);
		
	}
	
	private function onHelpEvent(e:MouseEvent):void
	{
		//if (qID == 36)	
			//App.user.quests.startTrack();
	
		
		if (e.currentTarget.settings.find > 0) {
			App.user.quests.helpEvent(qID, mID, 1);
			window.close();
			//App.user.quests.stopTrack()
		}else {
			if (qID == 126 && mID == 1) {
				App.ui.bottomPanel.friendsPanel.bttnPrevAll.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
				setTimeout(function():void{
					App.ui.bottomPanel.friendsPanel.friendsItems[0].showPointing("top", -50, 0, App.ui.bottomPanel.friendsPanel.friendsItems[0], "", null, false);
					App.ui.bottomPanel.friendsPanel.friendsItems[0].startGlowing();
					//App.ui.bottomPanel.bttns[3].showPointing("top",-325,0,App.ui.bottomPanel.bttns[3], "", null, false);
					setTimeout(function():void {
					App.ui.bottomPanel.friendsPanel.friendsItems[0].hidePointing();
					App.ui.bottomPanel.friendsPanel.friendsItems[0].hideGlowing();
					
					}, 3500)
					
				}, 500)
				
				window.close();
				return
			}
			
			new SimpleWindow( {
				popup:true,
				height:320,
				width:480,
				title:Locale.__e('flash:1382952380254'),
				text:App.data.daylics[qID].missions[mID].description
			}).show();
		}
	}
	
	public function progress():void {
		App.ui.flashGlowing(bitmap, 0xFFFF00, null, false);
	}
	
	public function dispose():void {
		if(helpBttn)
			helpBttn.removeEventListener(MouseEvent.CLICK, onHelpEvent);
	}
}

internal class PresentItem extends LayerX {
	
	public var count:TextField;
	
	function PresentItem(sid:String, text:String, sett:Object) {
		var preload:Preloader = new Preloader();
		preload.x = sett.bitmapSize / 2;
		preload.y = sett.bitmapSize / 2;
		preload.width = sett.bitmapSize;
		preload.height = sett.bitmapSize;
		addChild(preload);
		
		tip = function():Object {
			return {
				title:		App.data.storage[sid].title,
				text:		App.data.storage[sid].description
			}
		}
		
		Load.loading(Config.getIcon(App.data.storage[sid].type, App.data.storage[sid].preview), function(data:*):void {
			removeChild(preload);
			var bitmap:Bitmap = new Bitmap(data.bitmapData, 'auto', true);
			bitmap.x = 2;
			bitmap.y = -1;
			bitmap.width = sett.bitmapSize;
			//bitmap.scaleY = bitmap.scaleX;
			bitmap.scaleY = 0.30;
			bitmap.scaleX = 0.30;
			addChild(bitmap);
		});
		
		count = Window.drawText(/*'  x'*/ " " + text, {
			fontSize:		sett.fontSize || 25,
			color: 			sett.color || 0xfffff8,
			borderColor:	sett.borderColor || 0x4c341a,
			borderSize:		sett.borderSize || 4,
			multiline:		false,
			textLeading:	-2
		});
		count.x = sett.textX || 32;
		count.y = sett.textY || 2;
		count.width = count.textWidth + 4;
		count.height = count.textHeight + 2;
		addChild(count);
	}
}