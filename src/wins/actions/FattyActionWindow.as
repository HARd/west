package wins.actions 
{
	import api.ExternalApi;
	import api.SPApi;
	import buttons.Button;
	import buttons.ImageButton;
	import buttons.MenuButton;
	import buttons.MoneyButton;
	import com.adobe.images.BitString;
	import core.Load;
	import core.Numbers;
	import core.Post;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import ui.UserInterface;
	import units.Factory;
	import units.Hut;
	import units.Techno;
	import units.Unit;
	import units.WorkerUnit;
	import wins.elements.RibbonItem;
	import wins.elements.TimerUnit;
	import wins.AddWindow;
	import wins.Window;
	import wins.SimpleWindow;
	
	public class FattyActionWindow extends AddWindow
	{
		
		public static const MODE_WITH_TIME:int = 1;
		public static const MODE_WITHOUT_TIME:int = 2;
		public static const TEST_MODE:Boolean = false;
		
		private var items:Array = new Array();
		private var container:Sprite;
		private var timerText:TextField;
		private var descriptionLabel:TextField;
		private var priceLabel:TextField;
		private var mode:int = MODE_WITH_TIME;
		
		public function FattyActionWindow(settings:Object = null)
		{
			if (settings == null) {
				settings = new Object();
			}
			
			if (TEST_MODE)
			{
				settings['pID'] = 3588;
				mode = MODE_WITH_TIME;
			}
			
			settings['width'] = 477;
			settings['height'] = 552;
			settings['shadowSize'] = 3;
			settings['shadowBorderColor'] = 0x554234;
			settings['shadowColor'] = 0x554234;
			
			settings['title'] = Locale.__e("flash:1382952379793");
			settings['hasPaginator'] = false;
			settings['hasButtons'] = false;
			settings['promoPanel'] = true;
			
			super(settings);
		}
		
		override public function drawExit():void {
		
		}
		
		override public function drawBackground():void 
		{
			
		}
		
		public function drawPriceLabel():void {
			priceLabel = Window.drawText(Locale.__e("flash:1463146430236"), {
				color:0xfff7d2,
				borderColor:0x712b15,
				textAlign:"center",
				autoSize:"center",
				fontSize:30,
				textLeading:-6,
				multiline:true
			});
			priceLabel.wordWrap = true;
			priceLabel.width = 217,
			priceLabel.height = 55;
			priceLabel.x = (itemsPanel.width - priceLabel.width) /2 - 50;
			priceLabel.y = itemsPanel.height + priceLabel.height + 110;
			itemsPanel.addChild(priceLabel);
		}
		
		public static function formatPrice(price:*):String {
			var text:String = '';
			
			switch(App.social) {
				case "VK":
				case "DM":
						text = Locale.__e('flash:1382952379972', [price]);
					break;
				case "OK":
						text = Locale.__e('flash:1395753315895', [price]);
					break;	
				case "ML":
						text = Locale.__e('flash:1395753234403', [price]);
					break;
				case "NK":
						text = Payments.price(price);
					break;
				case "PL":
				case "YB":
				case "NN":
						text = String(price);
					break;
				case "FB":
						var pr:Number = price;
						pr = pr * App.network.currency.usd_exchange_inverse;
						pr = Math.ceil(pr * 100) / 100;
						text = String(pr) + ' ' + App.network.currency.user_currency;
					break;
				default:
					text = String(price);
					break;
			}
			
			return text;
		}
		
		private var itemsPanel:Sprite;
		
		public function changePromo(pID:String):void {
			
			App.self.setOffTimer(updateDuration);
			
			action = App.data.actions[pID];
			action.id = pID;
			
			if (action.duration <= 0) {
				settings['height'] = 325;
				mode = MODE_WITHOUT_TIME;
			}
			
			if (action.id == 119 || action.id == 120 || action.id == 125) {
				mode = MODE_WITHOUT_TIME;
			}
			
			settings.content = initContent(action.items);
			settings.bonus = initContent(action.bonus);
			
			var background:Bitmap = backing(settings.width, settings.height, 45, 'woodPaperBackingDark');
			layer.addChild(background);
			
			exit = new ImageButton(textures.closeBttn);
			headerContainer.addChild(exit);
			exit.x = settings.width - 50;
			
			exit.addEventListener(MouseEvent.CLICK, close);
			
			var backing:Bitmap = Window.backing(settings.width - 60, 230, 43, 'shopBackingSmall1');
			
			backing.x = (settings.width - backing.width) / 2;
			backing.y = -10;
			
			var text:String = Locale.__e("flash:1393581986914");
			_descriptionLabel = drawText(text, {
				fontSize:26,
				autoSize:"left",
				textAlign:"center",
				color:0xffffff,
				borderColor:0x6d289a
			});
			
			_descriptionLabel.y = 20;
			
			container = new Sprite();
			bodyContainer.addChild(container);
			container.x = 50;
			container.y = 60;
			
			
			settings['L'] = settings.content.length + settings.bonus.length;
			if (settings['L'] < 2) settings['L'] = 2;
				drawImage();
			
			var btnSettings:Object = {
				fontSize:36,
				width:217,
				height:55,
				x:axeX - 217 / 2,
				y:settings.height - 80,
				caption:formatPrice(action.price[App.social]),
				callback:buyEvent,
				addBtnContainer:true,
				addLogo:false
			}
			drawPanel();
			drawBonusBacking();
			contentChange();
			drawButton(btnSettings);
			drawPriceLabel();
			drawStickers();
			drawProfit();
			
			if(fader != null)
				onRefreshPosition();
				
			titleLabel.x = (settings.width - titleLabel.width) / 2;	
			titleLabel.y = 0;
			_descriptionLabel.x = settings.width/2 - _descriptionLabel.width/2;
			exit.y -= 10;
			
			var X:int = 10;
			for each(var bttn:PromoIcon in bttns) {
				
				if (bttn.pID == pID) 
				{
					bttn.clickable = false;
					bttn.scaleX = bttn.scaleY = 1.2;
					bttn.filters = [];
					bttn.bttn.startRotate(0, 10000, 1);
					bttn.x = X;
					bttn.y = -6;
					X += 84;
				}
				else
				{
					bttn.clickable = true;
					UserInterface.effect(bttn, 0, 0.6);
					bttn.scaleX = bttn.scaleY = 1;
					bttn.y = 0;
					bttn.bttn.stopRotate();
					bttn.x = X;
					X += 70;
				}
			}
			
			if (menuSprite != null){
				menuSprite.x = settings.width / 2 - (promoCount * 70) / 2 - 20;
			}
		}
		
		private function drawProfit():void
		{
			var profitBG:Bitmap = Window.backing(153, 100, 0, 'itemBackingYellow');
			profitBG.x = 175;
			profitBG.y = 35;
			
			bodyContainer.addChild(profitBG);
			
			var profitTitle:TextField = Window.drawText(Locale.__e("flash:1419254677876"), {
				color:0xfff7d2,
				borderColor:0x712b15,
				textAlign:"center",
				autoSize:"center",
				fontSize:36,
				textLeading:-6,
				multiline:true
			});
			
			bodyContainer.addChild(profitTitle);
			
			profitTitle.wordWrap = true;
			profitTitle.width = 217,
			profitTitle.height = 55;
			profitTitle.x = profitBG.x + (profitBG.width - profitTitle.width) / 2 ;
			profitTitle.y = profitBG.y - profitTitle.height / 2;
			
			if (!action.hasOwnProperty('profit'))
				return;
			var profitValue:TextField = Window.drawText(action.profit + '%', {
				color:0xffde00,
				borderColor:0x8d1a00,
				textAlign:"center",
				autoSize:"center",
				borderSize:4,
				shadowSize:5,
				fontBorderGlow:3,
				fontSize:60,
				textLeading:-6,
				multiline:true
			});
			
			bodyContainer.addChild(profitValue);
			
			profitValue.wordWrap = true;
			profitValue.width = 217,
			profitValue.height = 55;
			profitValue.x = profitBG.x + (profitBG.width - profitValue.width) / 2 ;
			profitValue.y = profitBG.y + (profitBG.height - profitTitle.height) / 2 - 5;
		}
		
		private function drawStickers():void
		{
			drawSticker(30, 75, 335, 19, 17, 'flash:1477911338539');
			drawSticker(350, 20, 25, -2, 17, 'flash:1478165946723');
		}
		
		private function drawSticker(pX:int, pY:int, pRotation:int, labelOffsetX:int, labelOffsetY:int, title:String):void
		{
			var sticker:Bitmap = new Bitmap(Window.texture('saleLabelBank'));
			sticker.x = pX;
			sticker.y = pY;
			sticker.width = 135;
			sticker.height = 86;
			sticker.rotation = pRotation;
			bodyContainer.addChild(sticker);
			
			var stickerText:TextField = Window.drawText(Locale.__e(title), {
				color:0xffffff,
				borderColor:0x6e4413,
				textAlign:"center",
				autoSize:"center",
				fontSize:22,
				textLeading:-6,
				multiline:true
			});
			stickerText.wordWrap = true;
			stickerText.height = 86;
			stickerText.width = 115;
			
			bodyContainer.addChild(stickerText);
			
			stickerText.x = pX + labelOffsetX;
			stickerText.y = pY + labelOffsetY;
			stickerText.rotation = pRotation;
		}
		
		private function drawPanel():void
		{
			itemsPanel = new Sprite();
			bodyContainer.addChild(itemsPanel);
			
			var separator:Bitmap = Window.backingShort(settings.width - 40, 'dividerLine', false);
			separator.x = 25;
			separator.y = 201;
			separator.alpha = 0.7;
			itemsPanel.addChild(separator);
			
			var separator2:Bitmap = Window.backingShort(settings.width - 40, 'dividerLine', false);
			separator2.x = 25;
			separator2.y = 234+201;
			separator2.alpha = 0.7;
			itemsPanel.addChild(separator2);
			
			var rectangle:Shape = new Shape();
			rectangle.graphics.beginFill(0x4b3500, 0.1);
			rectangle.graphics.drawRect(0,0,434,234);
			rectangle.x = 25;
			rectangle.y = 201;
			itemsPanel.addChild(rectangle);
		}
		
		private function initContent(data:Object):Array
		{
			var result:Array = [];
			for (var sID:* in data) {
				result.push( { sID:sID, count:data[sID], order:action.iorder[sID]} );
			}
			
			result.sortOn('order');
			return result;
		}
		
		private var axeX:int
		private var _descriptionLabel:TextField;
		
		override public function drawBody():void 
		{
			changePromo(settings['pID']);
			if(settings['L'] <= 3){
				axeX = settings.width - 170;
			}else{
				axeX = settings.width - 190;
			}
			
			RibbonItem.descriptionParams.fontSize = 25;
			RibbonItem.descriptionParams.shadowSize = 0;
			RibbonItem.titleParams.shadowSize = 0;
			RibbonItem.titleParams.color = 0xfdfbc7;
			RibbonItem.titleParams.borderColor = 0x92541d;
			
			RibbonItem.titleParams.fontSize = 25;
			
			_descriptionLabel.x = settings.width / 2 - _descriptionLabel.width / 2;
			
			if (mode != MODE_WITHOUT_TIME)
			{
				drawTimerBG();
				drawTime();
			}
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
		
		private function drawMenu():void {
			
			menuSprite = new Sprite();
			var X:int = 10;
						
			if (App.data.promo == null) return;
			
			for (var pID:* in App.user.promo) {
				
				var promo:Object = App.data.promo[pID];	
				
				if (App.user.promo[pID].status)	continue;
				if (App.time > App.user.promo[pID].started + promo.duration * 3600)	continue
					
				promoCount++;
				var bttn:PromoIcon = new PromoIcon(pID, this);
				menuSprite.addChild(bttn);
				bttns.push(bttn);
				bttn.y = 0;
				bttn.x = X;
				
				if (App.user.promo[pID].hasOwnProperty('new')) 
				{
					if(App.time < App.user.promo[pID]['new'] + 2*3600)
						bttn._new = true;
					
					if(App.time < App.user.promo[pID]['new'] + 5*60)
						bttn.showGlowing();
				}
				X += 70;
			}
			
			bodyContainer.addChild(menuSprite);
			menuSprite.y = settings.height - 70;
			var bg:Bitmap = Window.backing((promoCount * 70) + 40, 70, 10, 'smallBacking');
			menuSprite.addChildAt(bg, 0);
			
			menuSprite.x = (settings.width - menuSprite.width) / 2 - 10;
		}
		
		private var glowing:Bitmap;
		private var stars:Bitmap;
		private function drawImage():void {
			if(action.image != null && action.image != " " && action.image != ""){
				Load.loading(Config.getImage('promo/images', action.image), function(data:Bitmap):void {
					
					var image:Bitmap = new Bitmap(data.bitmapData);
					bodyContainer.addChildAt(image, 0);
					image.x = 20;
					image.y = 185;
					if (action.image == 'bigPanda') {
						image.x = -200;
						image.y = -20;
					}
				});
			}else{
				axeX = settings.width / 2;
			}
		}
		
		public override function contentChange():void 
		{
			for each(var _item:RoundActionItem in items)
			{
				container.removeChild(_item);
				_item = null;
			}
			
			items = [];
			
			var Xs:int = 55;
			var Ys:int = 210;
			var X:int = 0;
			
			var itemNum:int = 0;
			
			var i:int = 0;
			var item: RoundActionItem;
			var gap:int = 25;
			for (i = 0; i < settings.content.length; i++)
			{	
				item = new RoundActionItem(settings.content[i], this);
				itemsPanel.addChild(item);
				
				item.x = (i >= 3)?Xs + item.width * (i-3) + item.width / 2:Xs + item.width * i;
				item.y = (i >= 3)?Ys + item.height - 10:Ys;
				if (i % 3 > 0)
				{
					item.x += (i % 3) * gap;
				}
				items.push(item);
				//Xs += item.background.width;
			}
			
			if (settings.bonus.length > 0 )
			{
				item = new RoundActionItem(settings.bonus[0], this, true);
				
				itemsPanel.addChild(item);
				item.x = 460;
				item.y = 265;
					
				items.push(item);
			}
			
			container.y -= 4;
			container.x = (settings.width - item.background.width * 3 - gap * 2) /2; //(settings.width - 150 * (settings.content.length + settings.bonus.length)) / 2 - 10;
		}
		
		private function drawBonusBacking():void
		{
			var bonusDecor:Bitmap = new Bitmap();
			bonusDecor.bitmapData = Window.texture('rouletteDecGold');
			itemsPanel.addChild(bonusDecor);
			
			bonusDecor.x = 455;
			bonusDecor.y = 140;
			
			var bonusBG:Bitmap = backing(170, 170, 45, 'woodPaperBackingDark');
			
			itemsPanel.addChild(bonusBG);
			
			bonusBG.x = 430;
			bonusBG.y = 235;
			
			var bonusRibbon:Bitmap = new Bitmap();
			bonusRibbon.bitmapData = Window.texture('bonusRedRibbon');
			itemsPanel.addChild(bonusRibbon);
			
			bonusRibbon.x = 430 + bonusRibbon.width / 2 + 1;
			bonusRibbon.y = 235 + bonusRibbon.height/ 2 + 1;
		}
		
		public function drawTime():void 
		{
			var timer:TimerUnit = new TimerUnit( {
				backGround:'none',
				width:140,
				height:60,
				time: { 
					started:action.begin_time, 
					duration:action.duration }, 
				label:'flash:1447864774806', 
				pX:0, 
				pY:12,
				color:0xffeb7d,
				borderColor:0x712b15,
				fontSize:36,
				titleColor:0xfff7d2,
				titleBorderColor:0x712b15,
				titleFontSize:24});
			timer.start();
			timer.y = 110;
			timer.x = 45;
			container.addChild(timer);
		}
		
		private var timerBacking:Bitmap;
		private function drawTimerBG():void
		{
			timerBacking = Window.backing(320, 43, 0, "timerBacking");
			timerBacking.x = 25;
			timerBacking.y = 87;
			
			container.addChild(timerBacking);
		}
		
		private function onTechnoComplete(sID:uint, rez:Object = null):void 
		{
			if (Techno.TECHNO == sID) {
				addChildrens(sID, rez.ids);
			}
		}
		
		private function addChildrens(_sid:uint, ids:Object):void 
		{
			var rel:Object = { };
			rel[Factory.TECHNO_FACTORY] = _sid;
			var position:Object = App.map.heroPosition;
			for (var i:* in ids){
				var unit:Unit = Unit.add( { sid:_sid, id:ids[i], x:position.x, z:position.z, rel:rel } );
					(unit as WorkerUnit).born({capacity:1});
			}
		}
		
		private function updateDuration():void {
			if (mode != MODE_WITH_TIME)
				return;
			
			var time:int = action.begin_time + action.duration * 3600 - App.time;
			timerText.text = TimeConverter.timeToStr(time);
			
			if (time <= 0) {
				descriptionLabel.visible = false;
				timerText.visible = false;
			}
		}
		
		public override function dispose():void
		{
			for each(var _item:RoundActionItem in items)
			{
				_item = null;
			}
			
			App.self.setOffTimer(updateDuration);
			super.dispose();
		}
		
		override public function getIconUrl(promo:Object):String {
			if (promo.hasOwnProperty('iorder')) {
				var _items:Array = [];
				for (var sID:* in promo.items) {
					_items.push( { sID:sID, order:promo.iorder[sID] } );
				}
				_items.sortOn('order');
				sID = _items[0].sID;
			}else {
				sID = promo.items[0].sID;
			}
			
			return Config.getIcon(App.data.storage[sID].type, App.data.storage[sID].preview);
		}
	}
}

import buttons.ImagesButton;
import core.Load;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.MouseEvent;
import units.Anime;
import units.AUnit;
import units.Techno;

internal class PromoIcon extends LayerX
{
	private var data:Object;
	public var pID:String;
	public var bttn:ImagesButton;
	private var win:*;
	public var clickable:Boolean = true;
	
	public function PromoIcon(pID:String, win:*)
	{
		this.pID = pID;
		this.win = win;
		
		data = App.data.promo[pID];
		for (var sID:* in data.items) break;
		var url:String = Config.getIcon(App.data.storage[sID].type, App.data.storage[sID].preview);
		
		bttn = new ImagesButton(new BitmapData(100,100,true,0));
		addChild(bttn);
		
		Load.loading(Config.getImage('promo/icons', data.preview), function(data:*):void {
			bttn.bitmapData = data.bitmapData;
		});
		
		Load.loading(url, function(data:Bitmap):void 
		{
			bttn.icon = data.bitmapData;
			bttn.iconBmp.scaleX = bttn.iconBmp.scaleY = 0.5;
			bttn.iconBmp.smoothing = true;
			bttn.iconBmp.x = 40 - bttn.iconBmp.width / 2;
			bttn.iconBmp.y = (bttn.bitmap.height - bttn.iconBmp.height) / 2;
		});
		
		bttn.addEventListener(MouseEvent.CLICK, onClick);
	}
	
	private var title:TextField;
	public function set _new(value:Boolean):void 
	{
		var textSettings:Object = {
			text:Locale.__e("flash:1382952379743"),
			color:0xf0e6c1,
			fontSize:19,
			borderColor:0x773c18,
			scale:0.5,
			textAlign:'center',
			multiline:true
		}
		
		var title:TextField = Window.drawText(textSettings.text, textSettings);
		title.wordWrap = true;
		title.width = 60;
		title.height = title.textHeight + 4;
		
		if (value == true){
			bttn.addChild(title);
			title.x = (bttn.bitmap.width - title.width)/2 - 2;
			title.y = (bttn.bitmap.height - title.height) / 2 + 14;
		}else{
			
		}
	}
	
	public function dispose():void {
		bttn.removeEventListener(MouseEvent.CLICK, onClick);
	}
	
	private function onClick(e:MouseEvent):void {
		if (clickable == false) return;
		win.changePromo(pID);
	}
}

import buttons.Button;
import core.Load;
import core.Size;
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.filters.GlowFilter;
import flash.text.TextField;
import ui.UserInterface;
import wins.Window;

class RoundActionItem extends Sprite {
		
		public var count:uint;
		public var sID:uint;
		public var background:Shape;
		public var bitmap:Bitmap;
		public var title:TextField;
		public var window:*;
		
		private var preloader:Preloader = new Preloader();
		
		private var bonus:Boolean = false;
		
		private var sprite:LayerX;
		
		public var differList:Object = {
				3: 	{
						1:{ min :1,  max :3000, val :223 },
						2:{ min :3001,  max :7999, val :224 },
						3:{ min :7500,  max :14999, val :225 },
						4:{ min :15000,  max :49999, val :226 },
						5:{ min :50000,  max :99999, val :227 },
						6:{ min :100000,  max :-1, val :228 }
					},
				164: {
						1:{ min :1,  max :1, val :220 },
						2:{ min :2,  max :2, val :221 },
						3:{ min :3,  max :3, val :222 }
					},
				5: 	{
						1:{ min :1,  max :19, val :270 },
						2:{ min :20,  max :40, val :271 },
						3:{ min :41,  max :99, val :271 },
						4:{ min :100,  max :199, val :271 },
						5:{ min :200,  max :499, val :344 },
						6:{ min :500,  max :-1, val :272 }
					},
				2:	{
						1:{ min :1,  max :30, val :2 },
						2:{ min :31,  max :300, val :170 },
						3:{ min :301,  max :499, val :171 },
						4:{ min :500,  max :-1, val :172 }
					}
				}
		
		public function getDifferVal(sId:uint,vl:uint):uint {
			var valueList:Object = differList[sId];
			for (var itm:* in valueList) {
				if ((vl >= valueList[itm].min) && ((vl <= valueList[itm].max) || (valueList[itm].max == -1)))
					return valueList[itm].val;
			}
			return sId;
		}
		
		public function RoundActionItem(item:Object, window:*, bonus:Boolean = false) {
			
			sID = item.sID;
			count = item.count;
			
			this.window = window;
			this.bonus = bonus;
			
			var backType:String = 'itemBacking';
			
			background = new Shape();
			background.graphics.beginFill(0xfbe2c8, (this.bonus)?0:1);
			background.graphics.drawCircle(53, 53, 53);
			background.graphics.endFill();
			addChild(background);
			
			sprite = new LayerX();
			addChild(sprite);
			
			bitmap = new Bitmap();
			sprite.addChild(bitmap);
			
			if (count > 1) {
				drawCount();
			}
			
			addChild(preloader);
			preloader.x = (background.width)/ 2;
			preloader.y = (background.height) / 2 - 15;
			
			var vId:uint = sID;
			
			if (differList.hasOwnProperty(sID))	{
				vId = getDifferVal(sID,count);
			}
			
			Load.loading(Config.getIcon(App.data.storage[vId].type, App.data.storage[vId].preview), onPreviewComplete);
			
			if (bonus) {
				var glow:Bitmap = new Bitmap();
				glow.bitmapData = Window.texture('glow');
				
				addChild(glow);
				glow.width = 140;
				glow.height = 140;
				glow.x = (background.width - glow.width) / 2;
				glow.y = (background.height - glow.height) / 2;
				setChildIndex(glow, 0);
			}
		}
		
		
		public function onPreviewComplete(data:Bitmap):void
		{
			removeChild(preloader);
			
			bitmap.bitmapData = data.bitmapData;
			Size.size(bitmap, background.width, background.height);
			bitmap.smoothing = true;
			bitmap.x = (background.width - bitmap.width)/ 2;
			bitmap.y = (background.height - bitmap.height) / 2;
			
			addTip();
		}
		private function onLoadAnimate(swf:*):void {
			removeChild(preloader);
			
			addTip();
			
			var anime:Anime = new Anime(swf, {w:background.width - 20, h:background.height - 20, animal:((App.data.storage[sID].type == 'Animal') ? true : false)});
			anime.x = (background.width - anime.width) / 2;
			anime.y = (background.height - anime.height) / 2 - 10;
			sprite.addChild(anime);
		}
		
		private function addTip():void {
			var description:String = App.data.storage[sID].description;
			if (sID == Techno.TECHNO) {
				description = Locale.__e('flash:1396445082768');
			}
			
			sprite.tip = function():Object {
				return {
					title:App.data.storage[sID].title,
					text:description
				};
			}
		}
		
		private function getPreview(sid:int, type:String = "Reals"):String
		{
			var preview:String;
			
			var arr:Array = [];
			arr = getIconsItems(type);
			arr.sortOn("order", Array.NUMERIC);
			
			if (arr.length == 0) return preview;
			preview = arr[arr.length-1].preview;
			for (var j:int = arr.length-1; j >= 0; j-- ) {
				if (count >= arr[j].price[sid]) {
					preview = arr[j].preview;
				}
				if (type == "Reals" && arr[j]) {
					
				}
				if (type == "Reals") {
					preview = "crystal_03";
				}else if (type == "Coins") {
					preview = "gold_02";
				}
			}
			return preview;
		}
		
		private function getIconsItems(type:String):Array
		{
			var arr:Array = [];
			
			for (var sID:* in App.data.storage) {
				var object:Object = App.data.storage[sID];
				object['sid'] = sID;
				
				if (object.type == type)
				{
					arr.push(object); 
				}
			}
			
			return arr;
		}
		
		//private function addBonusLabel():void {
			//removeChild(background);
			//background = null;
			//background = Window.backing2(150, 190, 25, 'shopSpecialBacking1','shopSpecialBacking2');
			//addChild(background);
			//
			//var bonusIcon:Bitmap = new Bitmap(Window.textures.redBow);
			//bonusIcon.y = -20;
			//bonusIcon.x = -20;
			//addChild(bonusIcon);
			//
		//}
		
		private var spCount:Sprite = new Sprite();
		private var countText:TextField;
		public function drawCount():void {
			countText = Window.drawText(String(count), {
				color:0xffffff,
				borderColor:0x5f4629,
				textAlign:"center",
				autoSize:"center",
				fontSize:32,
				textLeading:-6,
				multiline:true
			});
			countText.wordWrap = true;
			countText.height = countText.textHeight;
			countText.width = countText.textWidth + 10;
			spCount.addChild(countText);
			spCount.x = (background.width - spCount.width) / 2;
			spCount.y = background.height -22;			
			addChild(spCount);
		}
		
		private function onLoadOut(data:*):void
		{
			var iconEfir:Bitmap = new Bitmap(data.bitmapData);
			iconEfir.x = countText.x + countText.width;
			Size.size(iconEfir, 35, 35);
			iconEfir.smoothing = true;
			spCount.addChild(iconEfir);
			
			spCount.x = (background.width - spCount.width) / 2;
			spCount.y = background.height -40;			
			addChild(spCount);
		}
}
