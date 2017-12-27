package wins
{
	import buttons.Button;
	import buttons.ImageButton;
	import core.Load;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.StageDisplayState;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import ui.BottomPanel;
	import ui.UserInterface;
	import units.Hero;
	import units.Personage;
	import units.Techno;

		public class HeroWindow extends Window
	{
		public static var history:Object = {section:BODY, page:0, ind:0};
		
		public static const HEAD:String = 'head';
		public static const BODY:String = 'body';
		
		public var saveBttn:Button;
		public var hero:Hero;
		
		public var heroBg:Bitmap;
		public var saveSttings:Object = { };
		
		public var preloader:Preloader = new Preloader();
		public var clothing:Object = null;
		
		private var items:Array = [];
		private var backing:Bitmap;
		
		public var heroSid:int;		
		public var itemSid:int = 0;		
		public var focusItem:ClothItem;
		
		private var LayerOffset:Sprite = new Sprite;		
		private var aliens:Array = new Array();
		
		
		public function checkOnDressed(sID:uint):Boolean
		{
			if (!hero)
				return false;
			
			for each(var sid:* in hero.cloth)
			{
				if (sid == sID) 
					return true;
			}
			
			return false;
		}
		
		public function HeroWindow(settings:Object = null) 
		{
			if (settings == null) {
				settings = new Object();
			}
			
			for each (var item:Object in App.user.aliens)
				aliens.push(item);
			
			if (history.ind == aliens.length)
				heroSid = Techno.TECHNO;
			else
				heroSid = aliens[history.ind].sid;
			settings['sID'] = settings.sID || 0;
			settings["width"] = 750;
			settings["height"] = 520;
			settings["fontSize"] = 40;
			settings["hasPaginator"] = true;
			settings['shadowColor'] = 0x513f35;
			settings['shadowSize'] = 4;
			
			settings["title"] = Locale.__e("flash:1393580944680");
			
			settings["section"] = settings.section || history.section; 
			settings["page"] = settings.page || history.page;
			
			initContent();
			
			saveSttings['heroSid'] = heroSid;
			saveSttings['body'] = heroSid;
			
			super(settings);
		}
		
		public function initContent():void {
			
			if (clothing != null) clothing = {};
			
			clothing = {
				'120':[],    //man
				'121':[]  //woman
			};
			
			for (var id:String in App.data.storage)
			{
				if (App.data.storage[id].market == 8)
				{
					var item:Object = App.data.storage[id];	
					if (item.visible == 0) continue;
					if (!User.inUpdate(id)) continue;
					
					item['sid'] = id;
					item['onStock'] = false;
					if (App.user.stock.count(int(id)) > 0 || App.user.body == int(id))
						item['onStock'] = true;
						
					clothing[item.out].push(item);
				}
			}
			
			clothing[120].sortOn('default', Array.DESCENDING);
			clothing[121].sortOn('default', Array.DESCENDING);
		}
		
		override public function drawBackground():void {
			var background:Bitmap = Window.backing2(settings.width+20, settings.height+20, 45, "shopBackingTop", "shopBackingBot");
			layer.addChild(background);
		}
		
		private var paginatorUp:Paginator;
		private var paginatorDown:Paginator;
		public function createPaginators():void
		{
			paginator = new Paginator(6, 6, 9, {
				hasArrow:true,
				hasButtons:true
			});
			
			paginator.addEventListener(WindowEvent.ON_PAGE_CHANGE, onPageChange);
			
			paginator.drawArrow(bottomContainer, Paginator.LEFT,  214,  132, { scaleX:-0.7, scaleY:0.7 } );
			paginator.drawArrow(bottomContainer, Paginator.RIGHT, 554, 132, { scaleX:0.7, scaleY:0.7 } );
			
			bottomContainer.addChild(paginator);
		}
		
		override public function drawBody():void {
			exit.x = settings.width - exit.width + 12;
			
			heroBg = Window.backing(190, 235, 15, "itemBacking");
			LayerOffset.addChild(heroBg);
			heroBg.x = -55;
			heroBg.y = 130;
			
			var preview:String;			
			for (var j:int = 0; j < aliens.length; j++ ) {
				if (heroSid == aliens[j].sid) {
					preview = aliens[j].type;
					break;
				}
			}
			
			bodyContainer.addChild(LayerOffset);
			drawPersArrows();
			leftArrow.state = Button.DISABLED;
			rightArrow.state = Button.DISABLED;
			
			LayerOffset.addChild(preloader);
			preloader.x = heroBg.x + heroBg.width/2;
			preloader.y = heroBg.y + heroBg.height / 2;
			
			Load.loading(Config.getSwf('Clothes', preview), 
				function(data:*):void {
					if(preloader && preloader.parent)
						preloader.parent.removeChild(preloader);
						
					updateArrows();
						
					hero = new Hero(App.user, { id:Personage.HERO, sid:heroSid, x:10, z:10, alien:preview } );
					hero.uninstall();
					hero.touchable = false;
					hero.clickable = false;
					LayerOffset.addChild(hero);
					hero.framesType = 'walk';
					hero.scaleX = hero.scaleY = 1.2;
					
					hero.startAnimation();
					hero.x = heroBg.x + 100;
					hero.y = heroBg.y + 150;
				}
			);
			
			saveBttn = new Button( {
				width:190,
				height:45,
				fontSize:26,
				textAlign:"center",
				caption:Locale.__e("flash:1382952379786")
			});
			
			saveBttn.x = heroBg.x + (heroBg.width - saveBttn.width) / 2;
			saveBttn.y = heroBg.y + heroBg.height + 15;
			
			//LayerOffset.addChild(saveBttn);
			saveBttn.addEventListener(MouseEvent.CLICK, onSaveEvent);
			
			
			if(settings.hasOwnProperty('find')){
				var target:Object = App.data.storage[settings.find];
				if (target.part == 1)
					history.section = HEAD;
				else	
					history.section = BODY;
			}
			
			settings.mode = history.section;
				
			titleLabel.y = -14;
			
			LayerOffset.x = 115;
			LayerOffset.y -= 30;
			
			contentChange();
			updateBttn();			
		}
		
		override public function drawArrows():void {			
			paginator.x = (settings.width - paginator.width) / 2 - 30;
			paginator.y = settings.height - 10;
		}
		
		private var leftArrow:ImageButton;
		private var rightArrow:ImageButton;
		private function drawPersArrows():void {
			var PosY:int = heroBg.y + heroBg.height / 2 - 10;
			leftArrow = new ImageButton(Window.textures.arrow, {'scaleX': -0.7, 'scaleY': 0.7});
			LayerOffset.addChild(leftArrow);
			leftArrow.x = heroBg.x - 13;
			leftArrow.y = PosY;
			
			rightArrow = new ImageButton(Window.textures.arrow, {'scaleX': 0.7, 'scaleY': 0.7});
			LayerOffset.addChild(rightArrow);
			rightArrow.x = heroBg.x + heroBg.width - rightArrow.width / 2;
			rightArrow.y = PosY;
			
			updateArrows();
			
			leftArrow.addEventListener(MouseEvent.CLICK, switchPersLeft);
			rightArrow.addEventListener(MouseEvent.CLICK, switchPersRight);
		}
		
		private function updateArrows():void {
			leftArrow.state = Button.NORMAL;
			rightArrow.state = Button.NORMAL;
			
			if (history.ind >= aliens.length-1) {
				rightArrow.state = Button.DISABLED;
			}
			if (history.ind <= 0) {
				leftArrow.state = Button.DISABLED;
			}
		}
		
		private function switchPersRight(e:MouseEvent = null):void 
		{
			if (rightArrow.mode == Button.DISABLED)
				return;
			
			leftArrow.state = Button.NORMAL;
			
			history.ind ++;
			
			if (history.ind >= aliens.length) {
				history.ind = aliens.length;
				rightArrow.state = Button.DISABLED;
			}
			
			if (history.ind != aliens.length) {
			heroSid = aliens[history.ind].sid;
			}
				
			saveSttings['heroSid'] = heroSid;
			saveSttings['body'] = heroSid;
			
			contentChange();
			updateArrows();
			changeHero();
		}
		
		private function switchPersLeft(e:MouseEvent = null):void 
		{
			if (leftArrow.mode == Button.DISABLED)
				return;
			
			rightArrow.state = Button.NORMAL;
			history.ind --;
			if (history.ind <= 0) {
				leftArrow.state = Button.DISABLED;
				history.ind = 0;
			}
			if (history.ind != aliens.length)
				heroSid = aliens[history.ind].sid;
				
			saveSttings['heroSid'] = heroSid;
			saveSttings['body'] = heroSid;
			
			contentChange();
			updateArrows();
			changeHero();
		}
		
		private function drawItems():void
		{
			backing = Window.backing(370, 314, 30, 'shopBackingSmall');
			
			LayerOffset.addChild(backing);
			backing.x = 220;
			backing.y = 15;
			paginator.x = backing.x + (backing.width - paginator.width) / 2 -30;
			paginator.y = backing.y + backing.height + 70;
		}
		
		override public function contentChange():void
		{	
			for (var m:int = 0; m < items.length; m++)
			{
				items[m].dispose();
				LayerOffset.removeChild(items[m]);
			}
			
			paginator.itemsCount = clothing[heroSid].length;
			paginator.update();
			
			items = [];
			var X:int = 180;
			var Y:int = 50;
			
			for (var i:int = paginator.startCount; i < paginator.finishCount; i++)
			{
				var item:ClothItem = new ClothItem(clothing[heroSid][i], this);
				LayerOffset.addChild(item);
				item.x = X;
				item.y = Y;
				
				items.push(item);
				X += item.background.width + 5;
				
				if (i % 3 == 2 && i > 0)
				{
					X = 180;
					Y += item.background.height + 18;
				}
			}
			
			if (items.length < 6) {
				for (var j:int = i; j < 6; j++ ) {
					item = new ClothItem( { empty:true, sid:heroSid }, this);
					if (item.background == null) 
					{
						continue
					}
					LayerOffset.addChild(item);
					item.x = X;
					item.y = Y;
					
					items.push(item);
					X += item.background.width + 5;
					
					if (j % 3 == 2 && j>0)
					{
						X = backing.x + 14;
						Y += item.background.height + 6;
					}
				}
			}
			
			updateBttn();
		}
		
		public function updateItems():void
		{
			for (var i:int = 0; i < items.length; i++ ) {
				items[i].drawBg();
			}
			
			updateBttn();
		}
		
		private function updateBttn():void 
		{
			saveBttn.state = Button.NORMAL;
			if (!focusItem)
				return;
			
			if (focusItem.currentClose) {
				saveBttn.state = Button.DISABLED;
			}
			/*if (focusItem.item.onStock || focusItem.item.default == 1) {
				saveBttn.caption = Locale.__e('flash:1382952380163');
			}else {
				saveBttn.caption = Locale.__e('flash:1382952379751');
			}*/
		}
		
		public function changeHero():void
		{
			LayerOffset.addChild(preloader);
			preloader.x = heroBg.x + heroBg.width/2;
			preloader.y = heroBg.y + heroBg.height/2;
			
			 hero.change(saveSttings, onClothLoad);
		}
		
		private function onClothLoad():void
		{
			if(preloader && preloader.parent)
				preloader.parent.removeChild(preloader);
		}
		
		private function onSaveEvent(e:MouseEvent):void {
			
			if (saveBttn.mode == Button.DISABLED)
				return;
				
			/*if (focusItem && !focusItem.item.onStock && !App.user.stock.checkAll(focusItem.item.price))
				return;
				
			if(focusItem && !focusItem.item.onStock && !focusItem.item.default)
				App.user.stock.buy(focusItem.item.sid, 1, function():void {});
				
			saveBttn.state = Button.DISABLED;*/
			
			if (heroSid == User.PRINCE)	
				App.user.sex = 'm';
			else
				App.user.sex = 'f';
			
			var last:Object = App.user.hero.coords;
			App.user.onProfileUpdate(saveSttings);
			App.user.hero.placing(last.x, last.y, last.z);
			App.user.hero.cell = last.x;
			App.user.hero.row = last.z;
			
			//for (var i:int = 0; i < App.user.aliens.length; i++ ) {
				//if (App.user.aliens[i].sid == heroSid) {
					//App.user.aliens[i].type = App.data.storage[saveSttings.body].preview;
					//break;
				//}
			//}
			//
			//App.user.onProfileUpdate(saveSttings);
			//
			//for (var j:int = 0; j < App.user.personages.length; j++) 
			//{
				//if (App.user.personages[j].sid == heroSid) {
					//App.user.personages[j].change(saveSttings);
					//break;
				//}
			//}
			
			close();
			
			Nature.tryChangeMode();
		}
		
		override public function dispose():void {
			
			for (var i:int = 0; i < items.length; i++ ) {
				items[i].dispose();
			}
			items = null;
			
			focusItem = null;
			
			if(hero)
				hero.stopAnimation();
			hero = null;
			
			super.dispose();
			
			saveBttn.removeEventListener(MouseEvent.CLICK, onSaveEvent);
		}
		
		public function addCloth(sID:uint):void
		{
			for (var type:String in clothing[heroSid])
			{
				var L:uint = clothing[heroSid].length;
				for (var i:int = 0; i < L; i++)
				{
					if (clothing[heroSid][i].sid == sID)
					{
						clothing[heroSid][i].onStock = true;
						return;
					}
				}
			}
		}
		
		public function clothOff(sID:uint):void
		{
			saveSttings.body = App.data.storage[heroSid].preview;
				
			changeHero();	
		}
		
		public function clothOn(sID:uint):void
		{
			saveSttings.body = sID;				
			changeHero();	
		}
	}
}

import buttons.MoneyButton;
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.filters.ColorMatrixFilter;
import flash.filters.DropShadowFilter;
import flash.filters.GlowFilter;
import units.Hero;
import units.Personage;
import units.Techno;
import wins.elements.PriceLabelShop;
import wins.Window;

	import buttons.Button;
	import com.greensock.TweenMax;
	import core.Load;
	import core.Post;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import ui.Cursor;
	import ui.Hints;
	import ui.UserInterface;
	import units.Field;
	import units.Unit;
	import wins.elements.PriceLabel;
	import wins.ShopWindow;
	import wins.SimpleWindow;
	import wins.Window;
	import wins.HeroWindow;

	internal class ClothItem extends Sprite {
		
		public var item:*;
		public var background:Bitmap;
		public var bitmap:Bitmap;
		public var title:TextField;
		public var window:HeroWindow;
		private var CY:uint = 70;
		private var saveSttings:Object = { };
		private var saveBttn:Button;
		
		public var moneyType:String = "coins";
		
		private var preloader:Preloader = new Preloader();
		
		public var mark:Bitmap;
		
		public var currentClose:Boolean = false;
		
		public function ClothItem(item:*, window:HeroWindow) {
			this.item = item;
			this.window = window;			
			
			if (item.empty) {
				drawCloseState();
				return;
			}
			drawBg();
			
			var sprite:LayerX = new LayerX();
			addChild(sprite);
			
			bitmap = new Bitmap();
			sprite.addChild(bitmap);
			
			
			sprite.tip = function():Object { 				
				return {
					title:item.title,
					text:item.description
				};
			};
			
			drawTitle();
			
			addChild(preloader);
			preloader.x = (background.width)/ 2;
			preloader.y = (background.height) / 2 - 15;
			
			var isPrice:Boolean = true;
			for (var j:int = 0; j < App.user.aliens.length; j++ ) {
				if (window.heroSid == App.user.aliens[j].sid && App.user.aliens[j].type == item.preview) {
					isPrice = false;
					window.focusItem = this;
					drawBg(true);
					currentClose = true;
					break;
				}
			}
			
			if(!item['onStock']){
				if (item.hasOwnProperty('unlock') && App.user.level < item.unlock.level && App.user.shop[item.sid] == undefined) {
				}else if (item.default == 0 && !item.onStock) {
					drawPrice();
				}else if (item.default == 1) {
					drawBuyedLabel();
				}
			}else{
				drawBuyedLabel();
			}
			
			if (window.settings.find != null && window.settings.find.indexOf(int(item.sid)) != -1) {
				glowing();
			}
			
			Load.loading(Config.getIcon(item.type, item.preview), onPreviewComplete);
			
			this.addEventListener(MouseEvent.CLICK, onClick);
			
			if(/*item.onStock || item.default == 1*/item.sid == App.user.body){
				mark = new Bitmap(Window.textures.checkmarkSlim);
				mark.x = background.width - mark.width - 10;
				mark.y = background.height - mark.height - 20;
				addChild(mark);
			}
		}
		
		private function drawCloseState():void 
		{
			return;
			var icon:Bitmap;
			switch(item.sid) {
				case 162:  icon = new Bitmap(Window.textures.princeInstanceIco); break;
				case 163:  icon = new Bitmap(Window.textures.princessInstanceIco); break;
				case 229:  icon = new Bitmap(Window.textures.shadowFat); break;
				case 97	:  icon = new Bitmap(Window.textures.shadowBoy); break;
				case 702:  icon = new Bitmap(UserInterface.textures.shadowHuman); break;
				case 705:  icon = new Bitmap(UserInterface.textures.shadowHumanGirl); break;
			}
			
			icon.x = (background.width - icon.width) / 2;
			icon.y = background.height - icon.height - 10;
			addChild(icon);
			
			var titleClose:TextField = Window.drawText(Locale.__e('flash:1406103820575'), {
				color:0x814f31,
				borderColor:0xffffff,
				textAlign:"center",
				autoSize:"center",
				fontSize:20,
				textLeading:-6,
				multiline:true
			});
			titleClose.wordWrap = true;
			titleClose.width = background.width - 6;
			titleClose.y = 6;
			titleClose.x = 3;
			addChild(titleClose)
			
			TweenMax.to(this, 0.04, {colorMatrixFilter:{colorize:0x000000, amount:0.3}});
		}
		
		public function drawBg(isSpecial:Boolean = false):void{
			if (background) {
				removeChild(background);
				background = null
			}
			
			if (isSpecial) {
				background = Window.backing(142, 200, 30, "itemBackingYellow");
				addChildAt(background, 0);
			}else {
				background = Window.backing(142, 200, 30, "itemBacking");
				addChildAt(background, 0);
			}
		}
		
		private function onClick(e:MouseEvent):void 
		{
			window.focusItem = this;
			window.itemSid = item.sID;
			
			window.saveSttings.body = item.sid;
			window.heroSid = window.saveSttings.heroSid;
			
			window.changeHero();
			
			window.updateItems();
			drawBg(true);
		}
		
		private function onSave(e:MouseEvent):void 
		{
			window.focusItem = this;
			window.itemSid = item.sID;
			
			saveSttings.body = item.sid;
			saveSttings.heroSid = window.saveSttings.heroSid;
			if (saveBttn.mode == Button.DISABLED)
				return;
				
			
			if (window.heroSid == User.PRINCE)	
				App.user.sex = 'm';
			else
				App.user.sex = 'f';
			
			var last:Object = App.user.hero.coords;
			App.user.onProfileUpdate(saveSttings);
			App.user.hero.placing(last.x, last.y, last.z);
			App.user.hero.cell = last.x;
			App.user.hero.row = last.z;
			
			for (var i:int = 0; i < App.user.aliens.length; i++ ) {
				if (App.user.aliens[i].sid == window.heroSid) {
					App.user.aliens[i].type = App.data.storage[saveSttings.body].preview;
					break;
				}
			}
			
			App.user.onProfileUpdate(saveSttings);
			
			for (var j:int = 0; j < App.user.personages.length; j++) 
			{
				if (App.user.personages[j].sid == window.heroSid) {
					App.user.personages[j].change(saveSttings);
					break;
				}
			}
			
			window.close();
			
			Nature.tryChangeMode();;
			
			//window.updateItems();
			//drawBg(true);
		}
		
		public function onPreviewComplete(data:Bitmap):void
		{
			removeChild(preloader);
			
			bitmap.bitmapData = data.bitmapData;
			bitmap.smoothing = true;
			bitmap.x = (background.width - bitmap.width)/ 2;
			bitmap.y = (background.height - bitmap.height)/ 2 - 10;
		}
		
		public function dispose():void {
			this.removeEventListener(MouseEvent.CLICK, onClick);
			if (saveBttn) saveBttn.removeEventListener(MouseEvent.CLICK, onSave);
			
			if (Quests.targetSettings != null) {
				Quests.targetSettings = null;
				if (App.user.quests.currentTarget == null) {
					QuestsRules.getQuestRule(App.user.quests.currentQID, App.user.quests.currentMID);
				}
			}
		}
		
		public function drawTitle():void {
			title = Window.drawText(String(item.title), {
				width:background.width,
				color:0x814f31,
				borderColor:0xffffff,
				textAlign:"center",
				fontSize:20,
				multiline:true
			});
			title.wordWrap = true;
			title.y = 6;
			addChild(title)
		}
		
		public function drawBuyedLabel():void {
			if (item.sid != App.user.body) {
				saveBttn = new Button( {
					width:105,
					height:38,
					fontSize:22,
					textAlign:"center",
					caption:Locale.__e("flash:1382952380163")
				});
				
				saveBttn.x = (background.width - saveBttn.width) / 2;
				saveBttn.y = background.height - saveBttn.height - 5;
				
				addChild(saveBttn);
				saveBttn.addEventListener(MouseEvent.CLICK, onSave);
			}
		}
		
		public function drawPrice():void {			
			var settings:Object = {
				width:105,
				height:38,
				fontSize:22,
				caption:Locale.__e('flash:1382952379751')
			};
			settings["bgColor"] 		= [0xa6f949, 0x74bb15];
			settings["borderColor"] 	= [0x000000, 0x000000];
			settings["bevelColor"] 		= [0xbfeea8, 0x48882a];
			settings["fontColor"]		= 0xffffff;				
			settings["fontBorderColor"]	= 0x527b01;
			
			settings["fontCountColor"]	= 0xfffdff;
			settings["fontCountBorder"] = 0x527b01;
			
			if (!item.price) return;
			
			var buyBttn:Button = new Button(settings);
			buyBttn.x = (background.width - buyBttn.width) / 2;
			buyBttn.y = background.height - buyBttn.height - 5;
			addChild(buyBttn);
			buyBttn.addEventListener(MouseEvent.CLICK, onBuy);
			
			var priceLabel:PriceLabelShop = new PriceLabelShop(item.price);
			priceLabel.x = background.width - priceLabel.width - 15;
			priceLabel.y = buyBttn.y - 10;
			addChild(priceLabel);
		}
		
		private function onBuy(e:MouseEvent):void {
			if (e.currentTarget.mode == Button.DISABLED)
				return;
			
			if (!item.onStock && !App.user.stock.checkAll(item.price))
				return;
			
			e.currentTarget.state = Button.DISABLED;
			
			if(!item.onStock && !item.default)
				App.user.stock.buy(item.sid, 1, function():void {
					window.initContent();
					window.contentChange();
				});
		}
		
		private function glowing():void {
			if (!App.user.quests.tutorial) {
				customGlowing(background, glowing);
			}
		}
		
		private function customGlowing(target:*, callback:Function = null):void {
			TweenMax.to(target, 1, { glowFilter: { color:0xFFFF00, alpha:0.8, strength: 7, blurX:12, blurY:12 }, onComplete:function():void {
				TweenMax.to(target, 0.8, { glowFilter: { color:0xFFFF00, alpha:0.6, strength: 7, blurX:6, blurY:6 }, onComplete:function():void {
					if (callback != null) {
						callback();
					}
				}});	
			}});
		}
	}