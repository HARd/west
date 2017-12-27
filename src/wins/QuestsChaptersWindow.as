package wins 
{
	import buttons.Button;
	import buttons.ImageButton;
	import buttons.MenuButton;
	import buttons.MoneyButton;
	import com.greensock.TweenLite;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import ui.UserInterface;
	import units.Storehouse;

	public class QuestsChaptersWindow extends Window
	{
		public static const MINISTOCK:int = 4;
		public static const ARCHIVE:int = 1;
		public static const DESERT_WAREHOUSE:int = 2;
		public static const PAGODA:int = 3;
		public static const DEFAULT:int = 0;
		
		//public static var find:*;
		
		public static var mode:int = DEFAULT;
		public var sections:Object = new Object();
		public var icons:Array = new Array();
		public var openedQuestsId:Array = [];
		public var finishedQuestsId:Array = [];
		public var items:Vector.<ChapterItem> = new Vector.<ChapterItem>();
		public var otherQuests:Array = [];
		
		public static var history:Object = { section:"all", page:0 };
		
		public function QuestsChaptersWindow(settings:Object = null):void
		{
			if (settings == null) {
				settings = new Object();
			}
			
			settings["section"] = settings.section || "all"; 
			settings["page"] = settings.page || 0; 
			settings["find"] = settings.find || null;
			settings["title"] = Locale.__e('flash:1447327984507');
			settings["width"] = 755;
			settings["height"] = 655;
			settings["hasPaginator"] = true;
			settings["hasArrows"] = true;
			settings["itemsOnPage"] = 4;
			settings["buttonsCount"] = 8;
			settings["background"] = 'dailyBacking';
			
			createContent();
			
			findTargetPage(settings);
			
			super(settings);
			App.self.addEventListener(AppEvent.ON_CHANGE_STOCK, refresh);
		}
		
		override public function dispose():void {
			super.dispose();
			
			App.self.removeEventListener(AppEvent.ON_CHANGE_STOCK, refresh);
			
			for each(var item:* in items) {
				item.dispose();
				item = null;
			}
			
			for each(var icon:* in icons) {
				icon.dispose();
				icon = null;
			}
			
			ChapterItem.find = -1;
		}
		
		override public function drawBackground():void
		{			
			var background:Bitmap = backing(settings.width, settings.height, 50, settings.background);
			layer.addChild(background);
			background.x = -10;
			background.y = 40;
		}
		
		override public function drawTitle():void 
		{
			titleLabel = titleText( {
				title				: settings.title,
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
			
			titleLabel.x = (settings.width - titleLabel.width) * .5;
			titleLabel.y = -16;
			titleLabel.mouseChildren = titleLabel.mouseEnabled = false;
			headerContainer.addChild(titleLabel);
			headerContainer.y = 37;
			headerContainer.mouseEnabled = false;
		}
		
		override public function drawExit():void {
			var exit:ImageButton = new ImageButton(textures.closeBttn);
			headerContainer.addChild(exit);
			exit.x = settings.width - 60;
			exit.y = -5;
			exit.addEventListener(MouseEvent.CLICK, close);
		}
		
		public static function inShop(sid:uint = 0):Boolean 
		{
		var shop:Object = App.data.storage[App.user.worldID]['shop'];
			if (shop) {
				for (var type:* in shop) {
					if (shop[type].hasOwnProperty(sid)) {
						if (shop[type][sid] == 1)
							return true
					}
				}
			}
			return false
		}
	
		private function findTargetPage(settings:Object):void {			
			
			for (var section:* in sections) {
				if (App.user.quests.currentQID == 158) 
				section = 'done';
				for (var i:* in sections[section].items) {
					
					var sid:int = sections[section].items[i].sid;
					if (settings.find != null && settings.find.indexOf(sid) != -1) {
						
						history.section = section;
						history.page = int(int(i) / settings.itemsOnPage);
						
						settings.section = history.section;
						settings.page = history.page;
						return;
					}
					for (var j:* in sections[section].items[i].allQuests) {
						if (settings.find != null && settings.find.indexOf(sections[section].items[i].allQuests[j].ID) != -1) {
							
							history.section = section;
							history.page = int(int(i) / settings.itemsOnPage);
							
							settings.section = history.section;
							settings.page = history.page;
							return;
						}
					}
				}
			}			
		}

		public function createContent():void {
			
			if (sections["all"] != null) return;
			
			sections = {
				"done"		:{items:new Array(),page:0},
				"all"		:{items:new Array(),page:0},
				"active"	:{items:new Array(),page:0},
				"locked"	:{items:new Array(),page:0}
			};
			
			var section:String = "all";			
			
			for (var index:* in App.user.quests.opened) {
				openedQuestsId.push(App.user.quests.opened[index].id);
			}
			
			for (var indexF:* in App.user.quests.data) {
				if (App.user.quests.data[indexF].finished != 0) {
					finishedQuestsId.push(indexF);
				}
			}
			
			for (var IDq:* in App.data.quests) {
				var itemQI:Object = App.data.quests[IDq];
				if (itemQI.update == '') {
					itemQI.update = 'u54787b5b242c5';
				}
			}
			
			for (var ID:* in App.data.updates) {
				var item:Object = App.data.updates[ID];
				item.excludeSocial = [];
				item.openedQuests = [];
				item.closedQuests = [];
				item.finishedQuests = [];	
				item.allQuests = [];	
				
				for (var social:* in item.exclude) {
					item.excludeSocial.push(item.exclude[social]);
				}
				
				if (item.excludeSocial.indexOf(App.SOCIAL) != -1) {
					continue;
				}
				
				if (ID.indexOf('ea5ea') >= 0) {
					trace();
				}
				
				for(var IDquest:* in App.data.quests) {
					var itemQ:Object = App.data.quests[IDquest];
					if (IDquest == '820') {
						trace();
					}
					if ((App.data.quests[IDquest].update == ID) && (App.data.quests[IDquest].missions !== null))
					{
						if (openedQuestsId.indexOf(IDquest) >= 0) {
							item.openedQuests.push(itemQ);
						} else if (finishedQuestsId.indexOf(IDquest) >= 0) {
							item.finishedQuests.push(itemQ);
						} else {
							item.closedQuests.push(itemQ);
						}
						
						item.allQuests.push(itemQ);
					}
				}
				
				if (item.openedQuests.length == 0 && item.closedQuests.length == 0 && item.finishedQuests.length == 0) {
					continue;
				}
				
				if (!App.data.updates[ID].social || !App.data.updates[ID].social.hasOwnProperty(App.social)) {
						if (item.finishedQuests.length != item.finishedQuests.length + item.openedQuests.length + item.closedQuests.length)
							continue;
				}
				
				if (item.openedQuests.length == 0 && item.closedQuests.length > 0 && item.finishedQuests.length == 0) {
					item.type = 'locked'; //не октрыто
					//sections["all"].items.push(item);
					if (item.description != 'Тестовая') 
					{
						//if (item.exclude == "") 
						//{
							sections["locked"].items.push(item);
						//}
						
					}					
				}
				
				if (item.openedQuests.length > 0) {
					item.type = 'active';//активна
					//sections["all"].items.push(item);
					if (item.description != 'Тестовая' ) 
					{
						//if (item.exclude == "") 
						//{
							sections["active"].items.push(item);
						//}
						
					}					
				}
				
				if (item.openedQuests.length == 0 && item.closedQuests.length == 0 && item.finishedQuests.length > 0) {
					item.type = 'done';//выполено
					//sections["all"].items.push(item);
					if (item.description != 'Тестовая')
					{
						//if (item.exclude == "") 
						//{
							sections["done"].items.push(item);
						//}
						
					}
					
				}
				
				item["sid"] = ID;
				//sections[section].items.push(item);
				if (item.description != 'Тестовая') 
				{
					//if (item.exclude == "") 
					//{
						sections["all"].items.push(item);
					//}
					
				}	
				
				sections["all"].items.sortOn('order', Array.NUMERIC | Array.DESCENDING);
				sections["done"].items.sortOn('order', Array.NUMERIC | Array.DESCENDING);
				sections["active"].items.sortOn('order', Array.NUMERIC | Array.DESCENDING);
				sections["locked"].items.sortOn('order', Array.NUMERIC | Array.DESCENDING);
			}
		}
		
		private var artifacts:Object = { 1:[], 2:[], 3:[] };		
		override public function drawBody():void {			
			drawMenu();
			
			setContentSection(settings.section,settings.page);
			contentChange();
			
			this.y -= 30;			
			fader.y += 30;
		}
		
		public function drawMenu():void {
			
			var menuSettings:Object = {
				"all":			{order:1, 	title:Locale.__e("flash:1382952380301")},
				"active":		{order:4, 	title:Locale.__e("flash:1447328127894")},
				"done":			{order:6, 	title:Locale.__e("flash:1447328513010")},
				"locked":		{order:7, 	title:Locale.__e("flash:1447328533340")}
			}
			
			for (var item:* in sections) {
				if (menuSettings[item] == undefined) continue;
				var settings:Object = menuSettings[item];
				settings['type'] = item;
				settings['onMouseDown'] = onMenuBttnSelect;
				settings['fontSize'] = 24;
				
				if (settings.order == 1) {
							settings["bgColor"] = [0xade7f1, 0x91c8d5];
							settings["bevelColor"] = [0xdbf3f3, 0x739dac];
							settings["fontBorderColor"] = 0x53828f;
							settings['active'] = {
								bgColor:				[0x73a9b6,0x82cad6],
								bevelColor:				[0x739dac, 0xdbf3f3],	
								fontBorderColor:		0x53828f//Цвет обводки шрифта		
							}
						}
						
				icons.push(new MenuButton(settings));
			}
			icons.sortOn("order");
			
			var sprite:Sprite = new Sprite();
			
			var offset:int = 0;
			for (var i:int = 0; i < icons.length; i++)
			{
				icons[i].x = offset;
				offset += icons[i].settings.width + 6;
				sprite.addChild(icons[i]);
			}
			bodyContainer.addChild(sprite);
			sprite.x = (this.settings.width - sprite.width) / 2;
			sprite.y = 45;
			
		}
		
		private function onMenuBttnSelect(e:MouseEvent):void
		{
			if (App.user.quests.tutorial) 
			{
				return
			}
			e.currentTarget.selected = true;
			setContentSection(e.currentTarget.type);
		}
		
		public function setContentSection(section:*,page:int = -1):Boolean {
			for each(var icon:MenuButton in icons) {
				icon.selected = false;
				if (icon.type == section) {
					icon.selected = true;
				}
			}
			if (sections.hasOwnProperty(section)) {
				settings.section = section;
				settings.content = [];
				
				for (var i:int = 0; i < sections[section].items.length; i++)
				{
					var sID:uint = sections[section].items[i].sid;
					settings.content.push(sections[section].items[i]);
				}
				
				paginator.page = page == -1 ? sections[section].page : page;
				paginator.itemsCount = settings.content.length;
				paginator.update();
				
			}else {
				return false;
			}
			
			contentChange();	
			return true
		}		
		
		public function refresh(e:AppEvent = null):void
		{
			for (var i:int = 0; i < settings.content.length; i++){
				if (App.user.stock.count(settings.content[i].sid) == 0){
					settings.content.splice(i, 1);
				}
			}
			sections = { };
			createContent();
			findTargetPage(settings);
			setContentSection(settings.section,settings.page);
			
			paginator.itemsCount = settings.content.length;
			paginator.update();
			contentChange();
		}
		
		override public function contentChange():void {
			
			for each(var _item:ChapterItem in items) {
				bodyContainer.removeChild(_item);
				_item.dispose();
				_item = null;
			}
			
			items = new Vector.<ChapterItem>();
			var Ys:int = 100;
		
			for (var i:int = paginator.startCount; i < paginator.finishCount; i++)
			{
				var item:ChapterItem = new ChapterItem(settings.content[i], this);
				
				bodyContainer.addChild(item);
				items.push(item);
				item.x = (settings.width - item.background.width) / 2  ;
				item.y = Ys - 5;
				Ys += 125 ;
			}
			
			sections[settings.section].page = paginator.page;
			settings.page = paginator.page;
		}
		
		override public function drawArrows():void 
		{			
			paginator.drawArrow(bottomContainer, Paginator.LEFT,  0, 0, { scaleX: -1, scaleY:1 } );
			paginator.drawArrow(bottomContainer, Paginator.RIGHT, 0, 0, { scaleX:1, scaleY:1 } );
			
			var y:int = (settings.height - paginator.arrowLeft.height) / 2 + 45;
			paginator.arrowLeft.x = -40;
			paginator.arrowLeft.y = y + 5;
			
			paginator.arrowRight.x = settings.width - paginator.arrowRight.width + 15;
			paginator.arrowRight.y = y + 5;
			
			paginator.x = int((settings.width - paginator.width)/2 - 40);
			paginator.y = int(settings.height - paginator.height + 25);
		}		
	}
}

import buttons.Button;
import buttons.ImageButton;
import com.greensock.TweenLite;
import com.greensock.TweenMax;
import core.Load;
import core.Numbers;
import core.Post;
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.filters.GlowFilter;
import flash.geom.Point;
import flash.text.TextField;
import flash.text.TextFormat;
import ui.Cursor;
import ui.QuestIcon;
import ui.UserInterface;
import ui.WishList;
import units.Factory;
import units.Field;
import units.Golden;
import units.Techno;
import units.Unit;
import units.WorkerUnit;
import wins.QuestsChaptersWindow;
import wins.Window;
import wins.SellItemWindow;
import silin.filters.ColorAdjust;

internal class StockMenuItem extends Sprite {
	
	public var textLabel:TextField;
	public var icon:Bitmap;
	public var type:String;
	public var order:int = 0;
	public var title:String = "";
	public var selected:Boolean = false;
	public var window:*;
	
	public function StockMenuItem(type:String, window:*) {
		
		this.type = type;
		this.window = window;
		
		switch(type) {
			case "all"			: order = 1; title = Locale.__e("flash:1382952380301"); break;//Все
			case "active"		: order = 2; title = Locale.__e("flash:1446313327612"); break;//Активные materials
			case "done"			: order = 3; title = Locale.__e("flash:1446313393958"); break;//Выполненные others
			case "locked"		: order = 3; title = Locale.__e("flash:1446313433698"); break;//Недоступные
		}

		icon.y = - icon.height + 6;
		
		addChild(icon);
		
		textLabel = Window.drawText(title,{
			fontSize:18,
			color:0xf2efe7,
			borderColor:0x464645,
			autoSize:"center"
		});
		
		addChild(textLabel);
		textLabel.x = (icon.width - textLabel.width) / 2 + 200;
		addEventListener(MouseEvent.CLICK, onClick);
		addEventListener(MouseEvent.MOUSE_OVER, onOver);
		addEventListener(MouseEvent.MOUSE_OUT, onOut);
	}
	
	private function onClick(e:MouseEvent):void {
		if (App.user.quests.tutorial) return;
		this.active = true;
		window.setContentSection(type);
	}
	
	private function onOver(e:MouseEvent):void{
		if(!selected){
			effect(0.1);
		}
	}
	
	private function onOut(e:MouseEvent):void {
		if(!selected){
			icon.filters = [];
		}
	}
	
	public function dispose():void {
		removeEventListener(MouseEvent.CLICK, onClick);
		removeEventListener(MouseEvent.MOUSE_OVER, onOver);
		removeEventListener(MouseEvent.MOUSE_OUT, onOut);
	}
	
	public function set active(selected:Boolean):void {
		var format:TextFormat = new TextFormat();
		
		this.selected = selected;
		if (selected) {
			glow();
			format.size = 18;
			textLabel.setTextFormat(format);
		}else {
			icon.filters = [];
			textLabel.setTextFormat(textLabel.defaultTextFormat);
		}
	}
	
	public function glow():void{
		
		var myGlow:GlowFilter = new GlowFilter();
		myGlow.inner = false;
		myGlow.color = 0xf1d75d;
		myGlow.blurX = 10;
		myGlow.blurY = 10;
		myGlow.strength = 10
		icon.filters = [myGlow];
	}
	
	private function effect(count:int):void {
		var mtrx:ColorAdjust;
		mtrx = new ColorAdjust();
		mtrx.brightness(count);
		icon.filters = [mtrx.filter];
	}
}

import wins.GiftWindow;
import wins.RewardWindow
import wins.SimpleWindow;
import wins.StockDeleteWindow;
import wins.ShipTransferWindow;
import wins.WorldsWindow;
import wins.TravelWindow;
import wins.BonusList;
import wins.QuestsManagerWindow;
import wins.Window;
import LayerX;
import flash.filters.GlowFilter;

internal class ChapterItem extends LayerX {
	
	public var item:*;
	public var background:Bitmap;
	public var bitmap:Bitmap;
	public var window:*;
	public var chapterTextLabel:TextField;
	public var questsCounterTextLabel:TextField;
	public var chapterCharacter:Bitmap;
	public var bonusList:BonusList;
	public var goToQuestsBttn:Button;
	public var findQuestsBttn:Button;
	public var goalBitmap:Bitmap;
	public var checkMark:Bitmap;
	public var notOpenedTextLabel:TextField;
	public var notOpenedLevelTextLabel:TextField;
	public var doneTextLabel:TextField;
	private var preloader:Preloader = new Preloader();
	public var rewards:Sprite;
	public var rewardTextLabel:TextField;
	public static var find:int = -1;

	public function ChapterItem(item:*, window:*):void {
		
		this.item = item;
		this.window = window;
		
		background = Window.backing(650, 125, 10, 'paperBacking');
		background.visible = false;
		addChild(background);
		
		var bg:Bitmap = Window.backing(650, 115, 10, 'fadeOutWhite');
		bg.x = 0;
		bg.y = 0;
		bg.alpha = 0.3;
		addChild(bg);
		
		var sprite:LayerX = new LayerX();
		addChild(sprite);
		
		var separator:Bitmap = Window.backingShort(650, 'dividerLine', false);
		separator.scaleY = -1;
		separator.x = 0;
		separator.y = 0;
		separator.alpha = 0.5;
		
		
		var separator2:Bitmap = Window.backingShort(650, 'dividerLine', false);
		separator2.scaleY = -1;
		separator2.x = 0;
		separator2.y = 115;
		separator2.alpha = 0.5;
		sprite.addChild(separator);
		sprite.addChild(separator2);
		
		bitmap = new Bitmap();
		sprite.addChild(bitmap);
		
		drawBttns();
		
		chapterTextLabel = Window.drawText(item.title, {
			width		:280,
			fontSize	:28,
			textAlign	:"center",
			color		:0xfff268,
			borderColor	:0x5b3c06,
			multiline	:true,
			wrap		:true
		});
		
		addChild(chapterTextLabel);
		chapterTextLabel.x = (background.x + (background.width / 2)) - 140;
		chapterTextLabel.y = 5;
		
		var totalQuests:Number = 0;
		totalQuests = item.finishedQuests.length + item.openedQuests.length + item.closedQuests.length;
		if (totalQuests == 0) totalQuests = item.allQuests.length;
		
		questsCounterTextLabel = Window.drawText(Locale.__e('flash:1447328732450') + " " + item.finishedQuests.length + "/" + totalQuests, {
			width		:280,
			fontSize	:22,
			textAlign	:"center",
			color:0x571b00,
			borderColor:0xfffed7,
			multiline	:true,
			wrap		:true
		});
		
		addChild(questsCounterTextLabel);
		questsCounterTextLabel.x = (background.x + (background.width / 2)) - 140;
		questsCounterTextLabel.y = 60;
		
		chapterCharacter = new Bitmap();
		addChild(chapterCharacter);
		
		addChild(preloader);
		preloader.x = chapterCharacter.x + 90;;
		preloader.y =  chapterCharacter.y + 90;
		preloader.scaleX = preloader.scaleY = 0.5;
		
		var mask:Sprite = new Sprite();
		mask.graphics.beginFill(0xcbd4cf);
		mask.graphics.drawCircle(55, 100, 60);
		mask.graphics.endFill();
		mask.x = 15;
		mask.y = -45;
		mask.visible = false;
		addChild(mask);
		
		var frame:Bitmap = Window.backing(100, 120, 50, 'questManagerBacking');
		
		Load.loading(
			Config.getImageIcon('updates/icons', App.data.updates[item.sid].preview, 'jpg'),
			function(data:Bitmap):void {
				if (preloader) removeChild(preloader);
				chapterCharacter.bitmapData = data.bitmapData;
				chapterCharacter.scaleX = chapterCharacter.scaleY = 0.5;
				chapterCharacter.x = background.x + 20;
				chapterCharacter.y = background.y;
				addChild(chapterCharacter);	
				
				chapterCharacter.mask = mask;
				frame.x += 20;
				frame.y -= 5;
				addChild(frame);
			}
		);	
		
		goalBitmap = new Bitmap();
		addChild(goalBitmap);
		
		notOpenedTextLabel = Window.drawText(Locale.__e('flash:1447328801124'), {//Ещё не открыто
			width		:280,
			fontSize	:25,
			textAlign	:"left",
			color		:0xffffff,
			borderColor	:0x824c2f,
			multiline	:true,
			wrap		:true
		});
		
		addChild(notOpenedTextLabel);
		notOpenedTextLabel.x = background.x + background.width - notOpenedTextLabel.width + 110;
		notOpenedTextLabel.y = background.y + (background.height / 2) - (notOpenedTextLabel.height / 2) + 15;

		notOpenedLevelTextLabel = Window.drawText(Locale.__e('flash:1396606807965', App.data.chapters[item.allQuests[0].chapter].level), {//Ещё не открыто
			width		:280,
			fontSize	:25,
			textAlign	:"left",
			color		:0xffffff,
			borderColor	:0x824c2f,
			multiline	:true,
			wrap		:true
		});
		addChild(notOpenedLevelTextLabel);
		
		notOpenedLevelTextLabel.x = background.x + background.width - notOpenedLevelTextLabel.width + 110;
		notOpenedLevelTextLabel.y = notOpenedTextLabel.y + notOpenedTextLabel.height + 5;
		
		if (item.openedQuests.length == 0 && item.closedQuests.length > 0 && item.finishedQuests.length == 0) {
			if (App.data.chapters[item.allQuests[0].chapter].level && App.data.chapters[item.allQuests[0].chapter].level > App.user.level) {
				notOpenedLevelTextLabel.visible = true;
				notOpenedTextLabel.y -= 20;
				notOpenedLevelTextLabel.y = notOpenedTextLabel.y + notOpenedTextLabel.height + 5;
			}else {
				notOpenedLevelTextLabel.visible = false;
			}
			notOpenedTextLabel.visible = true;
		} else {
			notOpenedTextLabel.visible = false;
			notOpenedLevelTextLabel.visible = false;
		}	
		
		var doneContainer:Sprite = new Sprite();
		addChild(doneContainer);
		doneContainer.x = background.x + background.width - 125;
		doneContainer.y = background.y + background.height - 115;
		
		if (item.openedQuests.length == 0 && item.closedQuests.length == 0 && item.finishedQuests.length > 0) {
			doneContainer.visible = true;
		} else {
			doneContainer.visible = false;
		}
		
		checkMark = new Bitmap(Window.textures.checkMark);
		checkMark.x = 0;
		checkMark.y = 0;
		doneContainer.addChild(checkMark);
		
		doneTextLabel = Window.drawText(Locale.__e('flash:1447346366368'), {//Выполнено
			width		:280,
			fontSize	:25,
			textAlign	:"left",
			color		:0xa6ff80,
			borderColor	:0x1a4a0e,
			multiline	:true,
			wrap		:true
		});
		
		doneContainer.addChild(doneTextLabel);
		doneTextLabel.x = checkMark.x - 20;
		doneTextLabel.y = checkMark.y + checkMark.height - 3;
		
		if (goToQuestsBttn.visible == false && doneContainer.visible == false && notOpenedTextLabel.visible == false) {
			if (App.data.chapters[item.allQuests[0].chapter].level && App.data.chapters[item.allQuests[0].chapter].level < App.user.level) {
				findQuestsBttn = new Button( {
						width:140,
						height:45,
						fontSize:25,
						fontColor:		0xffffff,
						fontBorderColor:0x475465,
						borderColor:	[0xfff17f, 0xbf8122],
						bgColor:		[0x75c5f6,0x62b0e1],
						bevelColor:		[0xc6edfe,0x2470ac],
						caption:Locale.__e("flash:1382952380254")
				});
				
				addChild(findQuestsBttn);
				findQuestsBttn.x = background.x + background.width - findQuestsBttn.width - 40;
				findQuestsBttn.y = background.y + (background.height / 2) - (findQuestsBttn.height / 2);
				findQuestsBttn.addEventListener(MouseEvent.CLICK, onFindQuests);
			}
		}else if (notOpenedTextLabel.visible) {
			findQuestsBttn = new Button( {
					width:140,
					height:40,
					fontSize:23,
					fontColor:		0xffffff,
					fontBorderColor:0x475465,
					borderColor:	[0xfff17f, 0xbf8122],
					bgColor:		[0x75c5f6,0x62b0e1],
					bevelColor:		[0xc6edfe,0x2470ac],
					caption:Locale.__e("flash:1382952380254")
			});
			
			addChild(findQuestsBttn);
			findQuestsBttn.x = background.x + background.width - findQuestsBttn.width - 40;
			findQuestsBttn.y = background.y + (background.height / 2) - (findQuestsBttn.height / 2) - 35;
			findQuestsBttn.addEventListener(MouseEvent.CLICK, onFindQuests);
		}
		
		if (ChapterItem.find == -1) {
			for (var i:* in item.allQuests) {
				if (window.settings.find != null && window.settings.find.indexOf(item.allQuests[i].ID) != -1) {
					ChapterItem.find = window.settings.find;
					if (findQuestsBttn && findQuestsBttn.visible) findQuestsBttn.showGlowing();
					if (goToQuestsBttn && goToQuestsBttn.visible) {
						goToQuestsBttn.showGlowing();
						onGoToQuests();
					}
				}
			}
		}
	}
	
	public function dispose():void {
		
	}
	
	public function drawBttns():void {
		
		var btnnCont:Sprite = new Sprite();
		addChild(btnnCont);
		btnnCont.x = (background.width - btnnCont.width) / 2 ;
		btnnCont.y = background.height - btnnCont.height / 2;
		
		goToQuestsBttn = new Button( {
				width:140,
				height:45,
				fontSize:25,
				caption:Locale.__e("flash:1394010224398")
		});
		
		addChild(goToQuestsBttn);
		goToQuestsBttn.x = background.x + background.width - goToQuestsBttn.width - 40;
		goToQuestsBttn.y = background.y + (background.height / 2) - (goToQuestsBttn.height / 2);
		goToQuestsBttn.addEventListener(MouseEvent.CLICK, onGoToQuests);
		
		if (item.openedQuests.length > 0) {
			goToQuestsBttn.visible = true;
		} else {
			goToQuestsBttn.visible = false;
		}	
	}	
	
	private function onGoToQuests (e:Event = null):void 
	{
		var questsManagerWindow:QuestsManagerWindow = new QuestsManagerWindow( {
			popup: true,
			questID: item.ID,
			personage: item.personage,
			questTitle: item.title,
			questDescription: item.description,
			questBonus: item.bonus,
			openedQuests: item.openedQuests,
			closedQuests: item.closedQuests,
			finishedQuests: item.finishedQuests,
			find:ChapterItem.find
		}
		);
		questsManagerWindow.show();
	}
	
	private function onFindQuests(e:Event = null):void 
	{
		qIDs = [];
		new SimpleWindow( {
			text:Locale.__e('flash:1455269552420'),
			title:Locale.__e('flash:1382952380254'),
			popup:true,
			confirm:checkQuests
		}).show();
	}
	
	private var qIDs:Array = [];
	private function checkQuests():void {
		window.close();
		var quest:Object; App.data.updates
		for each (quest in item.allQuests) {
			if ((!App.user.quests.data.hasOwnProperty(quest.ID) || (App.user.quests.data.hasOwnProperty(quest.ID) && App.user.quests.data[quest.ID].finished == 0)) && qIDs.indexOf(quest.ID) == -1) {
				qIDs.push(quest.ID);
				check(quest.ID);
				break;
			}
		}
		function check(qID:int):void {
			if (App.user.quests.data.hasOwnProperty(qID) && App.user.quests.data[qID].finished == 0) {
				for each (var icon:QuestIcon in App.ui.leftPanel.questsPanel.icons) {
					if (icon.qID == qID) {
						//icon.onQuestOpen();
						App.user.quests.openWindow(qID);
						return;
					}else if (icon.otherItems) {
						for each (var other:* in icon.otherItems) {
							if (other.id == qID) {
								App.user.quests.openWindow(other.id);
								return;
							}
						}
					}
				}
				
				new SimpleWindow( {
					text:Locale.__e('flash:1396606807965', App.data.chapters[item.allQuests[0].chapter].level),
					title:Locale.__e('flash:1382952380254'),
					popup:true
				}).show();
			} else if (App.data.quests[qID].hasOwnProperty('parent') && App.data.quests[qID].parent != 0) {
				check(App.data.quests[qID].parent)
			}
		}
	}
}