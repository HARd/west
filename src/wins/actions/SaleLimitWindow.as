package wins.actions 
{
	import api.ExternalApi;
	import buttons.Button;
	import buttons.MenuButton;
	import buttons.MoneyButton;
	import core.Load;
	import core.Post;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.text.TextField;
	import ui.UserInterface;
	import units.Hut;
	import wins.elements.TimerUnit;
	import wins.AddWindow;
	import wins.Window;
	import wins.SimpleWindow;
	
	public class SaleLimitWindow extends AddWindow
	{
		public var items:Array = new Array();
		public var container:Sprite;
		public var timerText:TextField;
		public var descriptionLabel:TextField;
		public var desc:TextField;
		public var desc2:TextField;
		
		public static const MODE_TIME:int = 1;
		public static const MODE_COUNT:int = 2;
		private var mode:int;
		
		public var title:TextField = new TextField();
		
		public function SaleLimitWindow(settings:Object = null)
		{
			if (settings == null) {
				settings = new Object();
			}
			
			settings['width'] = settings.width || 510;
			settings['height'] = settings.height || 500;
			settings['hasTitle'] = false;
			//settings['title'] = settings.title || Locale.__e("flash:1382952379793");
			settings['hasPaginator'] = false;
			settings['hasButtons'] = false;
			settings['promoPanel'] = true;

			super(settings);
			
			background = backing(settings.width, settings.height, 45, 'alertBacking');
			
			if (App.data.actions[settings.pID].rate != "") 
				mode = MODE_COUNT;
			else
				mode = MODE_TIME;
		}
		
		override public function drawBackground():void 
		{
			layer.addChild(background);
		}		
		
		public function changePromo(pID:String):void {
			action = App.data.actions[pID];
			action['remain'] = Math.ceil(action.duration * action.rate - (App.time - action.time) * action.rate / 3600);
			if (action['remain'] <= 0) action['remain'] = 1;
			action.id = pID;
			settings.content = initContent(action.items);
			
			settings['L'] = settings.content.length;
			if (settings['L'] < 2) settings['L'] = 2;
			
			//drawImage();
			//contentChange();
			//drawTime();
			drawPrice2();
			
			if(fader != null)
				onRefreshPosition();
			
			if (menuSprite != null){
				menuSprite.x = settings.width / 2 - (promoCount * 70) / 2 - 20;
			}
		}
		
		public function updateTimerLabel(nums:int):void {
			if (!desc2) return;
			
			desc2.text = Locale.__e('flash:1441977171781', [nums.toString(), (action.duration * action.rate - nums).toString()]);
		}
		
		private function initContent(data:Object):Array
		{
			var result:Array = [];
			for (var sID:* in data)
				result.push({sID:sID, count:data[sID], order:action.iorder[sID]});
			
			result.sortOn('order');
			return result;
		}
		
		private var axeX:int
		private var _descriptionLabel:TextField;
		override public function drawBody():void 
		{			
			ribbon = backingShort(625, 'ribbonYellow');
			ribbon.x = (settings.width - ribbon.width) / 2;
			ribbon.y = 275;
			bodyContainer.addChild(ribbon);
			
			container = new Sprite();
			bodyContainer.addChild(container);
			container.x = 50;
			container.y = 60;
			if (settings.pID == "126") {
				container.y = 90;
			}
			
			changePromo(settings['pID']);

			if(settings['L'] <= 3)
				axeX = settings.width - 170;
			else
				axeX = settings.width - 190;
			//drawMenu();
			drawTitleText();
			drawImage();
			bodyContainer.swapChildren(ribbon, bitmap);
			
			if (action.hasOwnProperty('picture')) {
				var pic:Bitmap = new Bitmap();
				bodyContainer.addChild(pic);
				bodyContainer.swapChildren(ribbon, pic);
				var path:String = Config.getImage('sales/bg', action.picture, 'png');
				Load.loading(action.picture, function(data:*):void {
					pic.bitmapData = data.bitmapData;	
					pic.x = -(pic.width - 100);
					pic.y = (settings.height - pic.height) / 2;
				});
			}else {
				if (action.sid == 951) {
					var pic0:Bitmap = new Bitmap();
					bodyContainer.addChild(pic0);
					bodyContainer.swapChildren(ribbon, pic0);
					var path0:String = Config.getImage('sales/bg', 'HorseBS', 'png');
					Load.loading(path0, function(data:*):void {
						pic0.bitmapData = data.bitmapData;	
						pic0.x = -180;
						pic0.y = -30;
					});
				}
				
				if (action.sid == 977) {
					var pic1:Bitmap = new Bitmap();
					bodyContainer.addChild(pic1);
					bodyContainer.swapChildren(ribbon, pic1);
					var path1:String = Config.getImage('sales/bg', 'Diligence', 'png');
					Load.loading(path1, function(data:*):void {
						pic1.bitmapData = data.bitmapData;	
						pic1.x = -220;
						pic1.y = 30;
					});
				}
				
				if (action.sid == 978) {
					var pic2:Bitmap = new Bitmap();
					bodyContainer.addChild(pic2);
					bodyContainer.swapChildren(ribbon, pic2);
					var path2:String = Config.getImage('sales/bg', 'PinePic', 'png');
					Load.loading(path2, function(data:*):void {
						pic2.bitmapData = data.bitmapData;	
						pic2.x = -210;
						pic2.y = -23;
					});
				}
			}
			
			drawDescription();
			drawDescription2();
		}
		
		public function drawBttm(py:int = 0, ph:int = 0 ):void {
			
			//settings.height += desc.height;
			
			//background.height += desc.height;
			//priceBttn.y = settings.height - 115;
		}
		
		public function drawTitleText():void {
			//return;
			var titleCont:Sprite = new Sprite();
			title = Window.drawText(String(App.data.storage[action.sid].title), {
				fontSize:46,
				textAlign:"center",
				autoSize:"center",
				color:0xffffff,
				borderColor:0xc09a53,
				shadowColor:0x553c2f,
				shadowSize:4
			});
			title.width = title.textWidth + 20;
			title.x = ribbon.x + (ribbon.width - title.width)/2;
			title.y = -5;
			titleCont.addChild(title);
			//titleCont.filters = [new GlowFilter(0x553c2f, 1, 4, 4, 2, 1)];
			
			drawMirrowObjs('titleDecRose', title.x - 65, title.x + title.width + 65, title.y + 8);
			
			bodyContainer.addChild(titleCont);
		}
		
		public function drawDescription():void 
		{
			var fontSize:int = 26;
			desc = Window.drawText(App.data.storage[action.sid].description , {
				color:0xffffff,
				borderColor:0x76481a,
				textAlign:"center",
				autoSize:"center",
				fontSize:fontSize,
				textLeading: -6,
				wrap:true,
				multiline:true
			});
			desc.wordWrap = true;
			desc.width = settings.width - 60;
			desc.x = (settings.width - desc.width) / 2;
			desc.y = ribbon.y + 40;
			
			if (desc.height > 30) {
				desc.y = ribbon.y + 20;
			}
			
			bodyContainer.addChild(desc);
		}
		
		public function drawDescription2():void 
		{
			var fontSize:int = 22;
			desc2 = Window.drawText('Скорее! Осталось всего 365 предложений. Уже продано 3.' , {
				color:0xffffff,
				borderColor:0x5a3019,
				textAlign:"center",
				autoSize:"center",
				fontSize:fontSize,
				textLeading: 2,
				wrap:true,
				multiline:true
			});
			desc2.wordWrap = true;
			desc2.width = 310;
			desc2.x = (settings.width - desc.width) / 2 + 70;
			desc2.y = ribbon.y + ribbon.height - 25;
			updateTimerLabel(action.remain);
			bodyContainer.addChild(desc2);
		}
		
		override protected function onRefreshPosition(e:Event = null):void
		{ 		
			var stageWidth:int = App.self.stage.stageWidth;
			var stageHeight:int = App.self.stage.stageHeight;
			
			layer.x = (stageWidth - settings.width) / 2;
			layer.y = (stageHeight - settings.height) / 2;
			
			fader.width = stageWidth;
			fader.height = stageHeight;
		}
		
		private var promoCount:int = 0;
		private var menuSprite:Sprite
		private var bttns:Array = [];
		public function drawMenu():void {
			
			menuSprite = new Sprite();
			var X:int = 10;
						
			if (App.data.promo == null) return;
			
			for (var pID:* in App.user.promo) {
				
				var promo:Object = App.data.promo[pID];	
				
				if (App.user.promo[pID].status)	continue;
				if (App.time > App.user.promo[pID].started + promo.duration * 3600)	continue
					
				promoCount++;
				var bttn:ActionItem = new ActionItem(pID, this);
				menuSprite.addChild(bttn);
				bttns.push(bttn);
				bttn.y = 0;
				bttn.x = X;
				
				X += 70;
			}
			
			bodyContainer.addChild(menuSprite);
			
			var bg:Bitmap = Window.backing((promoCount * 70) + 40, 70, 10, 'collectionRewardBacking');
			menuSprite.addChildAt(bg, 0);
			menuSprite.y = settings.height - 70;
			menuSprite.x = (settings.width - menuSprite.width) / 2 - 10;
		}
		
		public var bitmap:Bitmap = new Bitmap();
		public function drawImage():void {
			bodyContainer.addChild(bitmap);
			var path:String = Config.getImage('actions', App.data.storage[settings.content[0].sID].view, 'jpg');
			Load.loading( path,onPicLoad);
		}
		
		public function onPicLoad(data:Bitmap):void
		{
			bitmap.bitmapData = data.bitmapData;
			bitmap.x = (background.width - bitmap.width) / 2;
			bitmap.y = title.y + title.height + 15;
		}
		
		public override function contentChange():void 
		{
			for each(var _item:ActionItem in items)
			{
				container.removeChild(_item);
				_item = null;
			}
			
			items = [];
			
			var Xs:int = 0;
			var Ys:int = 0;
			var X:int = 0;
			
			var itemNum:int = 0;
			for (var i:int = 0; i < settings.content.length; i++)
			{
				var item:ActionItem = new ActionItem(settings.content[i], this);
				
				container.addChild(item);
				item.x = Xs;
				item.y = Ys;
								
				items.push(item);
				Xs += item.background.width;
			}
			
			container.y += 10;
			container.x = (settings.width - item.background.width * settings.content.length) / 2;
			
		}
		
		public var timerOne:TimerUnit;
		public function drawTime():void {
			timerOne = new TimerUnit( { time: { duration:action.duration, started:action.time } } );
			timerOne.start();
			timerOne.x = (settings.width - timerOne.width) / 2;
			timerOne.y = settings.height - timerOne.height * 1.2;
			bodyContainer.addChild(timerOne);
		}
		
		private var cont:Sprite;
		public var ribbon:Bitmap;
		public function drawPrice2():void {
			
			var bttnSettings:Object = {
				fontSize:36,
				width:186,
				height:52,
				hasDotes:false
			};
			
			if (priceBttn != null)
				bodyContainer.removeChild(priceBttn);
			
			bttnSettings['caption'] = Payments.price(action.price[App.social]);
			priceBttn = new Button(bttnSettings);
			bodyContainer.addChild(priceBttn);
			priceBttn.x = settings.width / 2 - priceBttn.width / 2;
			priceBttn.y = settings.height - priceBttn.height - 5;
			
			if (App.isSocial('MX')) {
				var mxLogo:Bitmap = new Bitmap(UserInterface.textures.mixieLogo);
				mxLogo.scaleX = mxLogo.scaleY = 0.8;
				priceBttn.addChild(mxLogo);
				mxLogo.y = priceBttn.textLabel.y - (mxLogo.height - priceBttn.textLabel.height)/2;
				mxLogo.x = priceBttn.textLabel.x-10;
				priceBttn.textLabel.x = mxLogo.x + mxLogo.width + 5;
			}
			if (App.isSocial('SP')) {
				var spLogo:Bitmap = new Bitmap(UserInterface.textures.fantsIcon);
				priceBttn.addChild(spLogo);
				spLogo.y = priceBttn.textLabel.y - (spLogo.height - priceBttn.textLabel.height)/2;
				spLogo.x = priceBttn.textLabel.x-10;
				priceBttn.textLabel.x = spLogo.x + spLogo.width + 5;
			}
			
			priceBttn.addEventListener(MouseEvent.CLICK, buyEvent);
			
			if (cont != null)
				bodyContainer.removeChild(cont);
				
			cont = new Sprite();
			
			//bodyContainer.addChild(cont);
			cont.x = priceBttn.x + priceBttn.width / 2 - cont.width / 2;
			cont.y = priceBttn.y - 30;
		}
		
		public override function dispose():void
		{
			for each(var _item:ActionItem in items)
			{
				_item = null;
			}
			
			super.dispose();
		}
	}
}

import buttons.Button;
import core.Load;
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.filters.DropShadowFilter;
import flash.filters.GlowFilter;
import flash.text.TextField;
import ui.UserInterface;
import units.AnimationItem;
import units.Anime;
import units.Personage;
import wins.Window;

internal class ActionItem extends Sprite {
		
		public var count:uint;
		public var sID:uint;
		public var background:Bitmap;
		public var bitmap:Bitmap;
		public var aItem:AnimationItem;
		public var countText:TextField;
		public var window:*;
		
		private var preloader:Preloader = new Preloader();
		
		private var bonus:Boolean = false;
		private var sprite:LayerX;
		
		public function ActionItem(item:Object, window:*, bonus:Boolean = false) {
			
			sID = item.sID;
			count = item.count;
			
			this.window = window;
			this.bonus = bonus;
			
			background = new Bitmap(Window.textures.alertBacking);
			addChild(background);
			
			sprite = new LayerX();
			addChild(sprite);
			bitmap = new Bitmap();
			sprite.addChild(bitmap);
			
			addChild(preloader);
			preloader.x = (background.width)/ 2;
			preloader.y = (background.height)/ 2 - 15;
			
			if (['Golden','Gamble','Animal','Character'].indexOf(App.data.storage[sID].type) >= 0) {
				Load.loading(Config.getSwf(App.data.storage[sID].type, App.data.storage[sID].view), onLoadAnimate);
			}else{
				Load.loading(Config.getIcon(App.data.storage[sID].type, App.data.storage[sID].preview), onPreviewComplete);
			}
		}
		
		private function addBonusLabel():void {
			removeChild(background);
			background = null;
			background = Window.backing(150, 190, 55, 'collectionRewardBacking');
			addChild(background);
			
			var bonusIcon:Bitmap = new Bitmap(Window.textures.redBow);
			bonusIcon.y = -20;
			bonusIcon.x = -20;
			addChild(bonusIcon);
			
		}
		
		private function onLoadAnimate(swf:*):void {
			removeChild(preloader);
			
			var anime:Anime = new Anime(swf, {w:200, h:250, animal:((['Animal','Character'].indexOf(App.data.storage[sID].type) >= 0) ? true : null) });
			anime.x = (background.width - anime.width) / 2;
			anime.y = (background.height - anime.height) / 2 - 10;
			sprite.addChild(anime);
			
			drawCount();
		}
		public function onPreviewComplete(data:Bitmap):void
		{
			removeChild(preloader);
			bitmap.bitmapData = data.bitmapData;
			bitmap.scaleX = bitmap.scaleY = 0.8;
			bitmap.smoothing = true;
			bitmap.x = (background.width - bitmap.width)/ 2;
			bitmap.y = (background.height - bitmap.height) / 2;
			
			if (bonus)
				bitmap.filters = [new GlowFilter(0xffffff, 1, 40, 40)];
			
			drawCount();
		}
		
		public function drawCount():void {
			if (count == 1) return;
			countText = Window.drawText("x" + String(count), {
				color:0xffffff,
				borderColor:0x41332b,
				textAlign:"center",
				autoSize:"center",
				fontSize:42,
				textLeading:-6,
				multiline:true
			});
			countText.wordWrap = true;
			countText.width = background.width - 20;
			countText.y = 55;
			countText.x = 80;
			addChild(countText);
		}
		
}
