package wins.actions 
{
	import api.ExternalApi;
	import buttons.Button;
	import buttons.ImageButton;
	import buttons.MenuButton;
	import buttons.MoneyButton;
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
	
	public class PromoWindow extends AddWindow
	{
		public static const MODE_WITH_TIME:int = 1;
		public static const MODE_WITHOUT_TIME:int = 2;
		
		private var items:Array = new Array();
		private var container:Sprite;
		private var timerText:TextField;
		private var descriptionLabel:TextField;
		
		private var mode:int = MODE_WITHOUT_TIME;
		
		public function PromoWindow(settings:Object = null)
		{
			if (settings == null) {
				settings = new Object();
			}
			
			settings['width'] = 728;
			settings['height'] = 450;
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
			}
			
			return text;
		}
		
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
			
			var numItems:int = settings.content.length + (settings.bonus.length - 1);
			
			if (numItems < 4) {
				
				settings.width = numItems * 200 + 200;
				if (settings.content.length == 3) settings.width = 700;
				if (settings.content.length == 1) settings.width = 360;
			}
			if (numItems == 4) settings.width = 850;
			if (numItems == 1) settings.width = 420;
			
			var background:Bitmap = backing(settings.width, settings.height, 45, 'stockBackingTopWithoutSlate');
			layer.addChild(background);
			
			exit = new ImageButton(textures.closeBttn);
			headerContainer.addChild(exit);
			exit.x = settings.width - 50;
			//exit.y = -20;
			exit.addEventListener(MouseEvent.CLICK, close);
			
			var backing:Bitmap = Window.backing(settings.width - 60, 230, 43, 'shopBackingSmall1');
			//bodyContainer.addChild(backing);
			backing.x = (settings.width - backing.width) / 2;
			backing.y = -10;
			//backing.alpha = 0.5;
			
			
			var text:String = Locale.__e("flash:1393581986914");
			_descriptionLabel = drawText(text, {
				fontSize:26,
				autoSize:"left",
				textAlign:"center",
				color:0xffffff,
				borderColor:0x6d289a
			});
			
			//_descriptionLabel.y = 3;
			_descriptionLabel.y = /*ribbon.y + (ribbon.height - _descriptionLabel.height)/2 - 15*/20;
			
			//bodyContainer.addChild(_descriptionLabel);
			
			container = new Sprite();
			bodyContainer.addChild(container);
			container.x = 50;
			container.y = 60;
			
			
			settings['L'] = settings.content.length + settings.bonus.length;
			if (settings['L'] < 2) settings['L'] = 2;
			
			//settings.width = 130 * settings['L'] + 130;
			
			//if(background != null)
				//layer.removeChild(background);
				//
			//background = backing(settings.width, settings.height, 50, "windowActionBacking");
			//layer.addChildAt(background,0);
			
			drawImage();	
			contentChange();
			drawPrice2();
			//drawTime();
			
			/*if(mode == MODE_WITH_TIME){
				updateDuration();
				App.self.setOnTimer(updateDuration);
			}*/
			
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
			
			var ribbon:RibbonItem;
			ribbon = new RibbonItem( { title:Locale.__e("flash:1393581986914"), width:settings.width , height:settings.height, decorated:false } );
				
			ribbon.y -= 15;
			bodyContainer.addChild(ribbon);
			
			_descriptionLabel.x = settings.width / 2 - _descriptionLabel.width / 2;
			
			if (mode != MODE_WITHOUT_TIME) drawTime();
			//drawMirrowObjs('diamondsTop', settings.width / 2 - settings.titleWidth / 2 - 15, settings.width / 2 + settings.titleWidth / 2 + 15, -82, true, true);
			//drawMirrowObjs('storageWoodenDec', 12, settings.width - 12, settings.height - 127);
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
						//this.x += 100;
					}
				});
			}else{
				axeX = settings.width / 2;
			}
			
			//if (glowing == null)
			//{
				//glowing = Window.backingShort(0, 'saleGlowPiece');
				//bodyContainer.addChildAt(glowing, 0);
			//}
			
			//if (stars == null) {
				//stars = Window.backingShort(0, 'decorStars');
				//bodyContainer.addChildAt(stars, 1);
			//}
			
			//stars.smoothing = true;
			//if (stars.width > settings.width - 40) stars.width = settings.width - 40;
			
			//stars.x = 20;
			//stars.y = settings.height - stars.height - 38;
			
			//glowing.alpha = 0.85;
			//glowing.x = axeX - glowing.width/2;
			//glowing.y = settings.height - glowing.height - 38;
			//glowing.smoothing = true;
			
			if (action.image == 'bigPanda') {
			
			}
			
			//glowing.width = (settings.width - 100);
			//glowing.x = 50;
			//axeX = settings.width / 2;
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
			var Ys:int = 50;
			var X:int = 0;
			
			var itemNum:int = 0;
			//for (var i:int = paginator.startCount; i < paginator.finishCount; i++)
			for (var i:int = 0; i < settings.content.length; i++)
			{
				var item:ActionItem = new ActionItem(settings.content[i], this);
				
				container.addChild(item);
				item.x = Xs;
				item.y = Ys;
								
				items.push(item);
				Xs += item.background.width;
			}
			
			var plus:Bitmap = new Bitmap(Window.textures.plus);
			plus.x = Xs - 16;
			plus.y = Ys+35;
			Xs += 20;
			
			for (i = 0; i < settings.bonus.length; i++)
			{
				item = new ActionItem(settings.bonus[i], this, true);
				
				container.addChild(item);
				item.x = Xs;
				item.y = Ys;
								
				items.push(item);
				Xs += item.background.width;
			}
			if (settings.bonus.length > 0) {
				container.addChild(plus);
			}
			container.y -= 4;
			container.x = (settings.width - 150 * (settings.content.length + settings.bonus.length)) / 2 - 10;
		}
		
		//private var timerContainer:Sprite;
		public function drawTime():void 
		{
			var timer:TimerUnit = new TimerUnit( {backGround:'glow',width:140,height:60,time: { started:action.begin_time, duration:action.duration }} );
			timer.start();
			timer.y += 15;
			bodyContainer.addChild(timer);
		}
		
		private var cont:Sprite;
		public function drawPrice2():void {
			var fontSize:int = 36;
			if (App.lang == 'jp') fontSize = 24;
			var bttnSettings:Object = {
				fontSize:fontSize,
				width:200,
				height:65
				//hasDotes:true
			};
			
			if (priceBttn != null)
				bodyContainer.removeChild(priceBttn);
				
			bttnSettings['caption'] = Payments.price(action.price[App.social]);
			priceBttn = new Button(bttnSettings);
			bodyContainer.addChild(priceBttn);
			
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
			
			priceBttn.x = axeX - priceBttn.width / 2;
			priceBttn.y = settings.height - priceBttn.height / 2 - 90;//135;
			
			priceBttn.addEventListener(MouseEvent.CLICK, buyEvent);
			
			if (cont != null)
				bodyContainer.removeChild(cont);
				
			cont = new Sprite();
			
			bodyContainer.addChild(cont);
			cont.x = priceBttn.x + priceBttn.width / 2 - cont.width / 2;
			cont.y = priceBttn.y - 30;
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
			for each(var _item:ActionItem in items)
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
		//var backBitmap:Bitmap = Window.backing(120, 70, 8, 'textSmallBacking');
		
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
			//bttn.iconBmp.filters = iconSettings.filter;
			bttn.iconBmp.x = 40 - bttn.iconBmp.width / 2;//(bttn.bitmap.width - bttn.iconBmp.width)/2;
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

internal class ActionItem extends Sprite {
		
		public var count:uint;
		public var sID:uint;
		public var background:Bitmap;
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
		
		public function ActionItem(item:Object, window:*, bonus:Boolean = false) {
			
			sID = item.sID;
			count = item.count;
			
			this.window = window;
			this.bonus = bonus;
			
			var backType:String = 'itemBacking';
			//if (!bonus)
			//	backType = 'bonusBacking'
			if (['Golden','Walkgolden'].indexOf(App.data.storage[sID].type) != -1)
				backType = "itemBackingGreen";
		
			background = Window.backing(150, 190, 10, backType);
			addChild(background);
			
			/*if (bonus)
				addBonusLabel();*/
			
			sprite = new LayerX();
			addChild(sprite);
			
			bitmap = new Bitmap();
			sprite.addChild(bitmap);
			
			
			drawTitle();
			if (count > 1) {
				drawCount();
			}
			
			addChild(preloader);
			preloader.x = (background.width)/ 2;
			preloader.y = (background.height) / 2 - 15;
			
			var type:String = App.data.storage[sID].type;
			var preview:String = App.data.storage[sID].preview;
			
			switch(sID) {
				case Stock.COINS:
					type = "Coins";
					preview = getPreview(Stock.COINS, type);
				break;
				case Stock.FANT:
					type = "Reals";
					preview = getPreview(Stock.FANT);
				break;
			}
			
			var vId:uint = sID;
			
			if (differList.hasOwnProperty(sID))	{
				vId = getDifferVal(sID,count);
			}
			
			if (['Golden','Gamble'].indexOf(App.data.storage[sID].type) >= 0) {
				Load.loading(Config.getSwf(App.data.storage[sID].type, App.data.storage[sID].view), onLoadAnimate);
			}else {
				Load.loading(Config.getIcon(App.data.storage[vId].type, App.data.storage[vId].preview), onPreviewComplete);
			}
			
			/*if (bonus) {
				var corner:Bitmap = new Bitmap(Window.textures.bonusLabelBlue);
				corner.x = background.x + background.width - corner.width / 1.5;
				corner.y = background.y + background.height - corner.height / 1.5;
				addChild(corner);
			}*/
			
			if (['Golden','Walkgolden'].indexOf(App.data.storage[sID].type) != -1) {
				var newStripe:Bitmap = new Bitmap(Window.textures.goldRibbon);
				newStripe.x = 2;
				newStripe.y = 3;
				
				addChild(newStripe);
			}
		}
		
		
		public function onPreviewComplete(data:Bitmap):void
		{
			removeChild(preloader);
			
			bitmap.bitmapData = data.bitmapData;
			Size.size(bitmap, background.width, background.height);
			//if (App.data.storage[sID].type == 'Building') bitmap.scaleX = bitmap.scaleY = 0.5;
			bitmap.smoothing = true;
			bitmap.x = (background.width - bitmap.width)/ 2;
			bitmap.y = (background.height - bitmap.height) / 2;
			//setChildIndex(bitmap, 1000000);
			
			addTip();
			
			if (bonus)
				bitmap.filters = [new GlowFilter(0xffffff, 1, 40, 40)];
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
			var preview:String;// = App.data.storage[sID].preview;
			
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
		
		private function addBonusLabel():void {
			//background.filters = [new GlowFilter(0xFFFF00, 0.6, 25, 25, 4, 1, true)];
			
			
			removeChild(background);
			background = null;
			background = Window.backing2(150, 190, 25, 'shopSpecialBacking1','shopSpecialBacking2');
			addChild(background);
			
			var bonusIcon:Bitmap = new Bitmap(Window.textures.redBow);
			bonusIcon.y = -20;
			bonusIcon.x = -20;
			addChild(bonusIcon);
			
		}
		
		public function drawTitle():void {
			title = Window.drawText(String(App.data.storage[sID].title), {
				color:0x773c18,
				borderColor:0xfcf6e4,
				textAlign:"center",
				autoSize:"center",
				fontSize:24,
				textLeading:-6,
				multiline:true
			});
			title.wordWrap = true;
			title.width = background.width - 10;
			title.y = 10;
			title.x = 5;
			addChild(title);
		}
		
		private var spCount:Sprite = new Sprite();
		private var countText:TextField;
		public function drawCount():void {
			countText = Window.drawText('x' + String(count), {
				color:0xffffff,
				borderColor:0x41332b,
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
			if (App.data.storage[sID].view == "Energy")
			{
				Load.loading(Config.getIcon(App.data.storage[sID].type, App.data.storage[sID].view), onLoadOut);
			}
			else
			{
				spCount.x = (background.width - spCount.width) / 2;
				spCount.y = background.height -40;			
				addChild(spCount);
			}
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
