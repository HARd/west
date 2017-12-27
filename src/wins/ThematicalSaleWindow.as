package wins 
{
	import api.ExternalApi;
	import buttons.Button;
	import buttons.ImageButton;
	import core.Load;
	import core.Post;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import ui.UserInterface;
	/**
	 * ...
	 * @author 
	 */
	public class ThematicalSaleWindow extends Window
	{
		
		private var items:Array = new Array();
		public var action:Object;
		private var container:Sprite;
		//private var priceBttn:Button;
		private var timerText:TextField;
		private var descriptionLabel:TextField;
		
		public function ThematicalSaleWindow(settings:Object = null)
		{
			if (settings == null) {
				settings = new Object();
			}
			
			settings['hasTitle'] = false;
			
			settings['width'] = 716;
			settings['height'] = 468;
						
			//settings['title'] = Locale.__e("flash:1382952379793");
			settings['hasPaginator'] = false;
			settings['hasButtons'] = false;
			

			super(settings);
		}
		
		override public function drawExit():void {
		
		}
		
		override public function drawBackground():void 
		{
			
		}
		
		private var backing:Bitmap;
		private var descBacking:Bitmap;
		private function drawBackings():void
		{
			var background:Bitmap = backing2(settings.width, settings.height, 45, 'questsSmallBackingTopPiece', 'questsSmallBackingBottomPiece');
			layer.addChild(background);
			
			exit = new ImageButton(textures.closeBttn);
			headerContainer.addChild(exit);
			exit.x = settings.width - 50;
			exit.y = 0;
			exit.addEventListener(MouseEvent.CLICK, close);
			
			backing = Window.backing(settings.width - 46, 267, 43, 'shopBackingSmall');
			bodyContainer.addChild(backing);
			backing.x = (settings.width - backing.width) / 2;
			backing.y = settings.height - backing.height - 20;
			backing.alpha = 0.5;
			
			descBacking = Window.backing2(300, 200, 43, 'questsSmallBackingTopPiece', 'questsSmallBackingBottomPiece');
			bodyContainer.addChild(descBacking);
			descBacking.x = settings.width - descBacking.width - 40;
			descBacking.y = 20;
			
			//var glowingD:Bitmap = Window.backingShort(0, 'saleGlowPiece');
			//glowingD.width = descBacking.width;
			//glowingD.height = 160;
			//glowingD.smoothing = true;
			//glowingD.x = descBacking.x;
			//glowingD.y = descBacking.y + descBacking.height - glowingD.height -10
			//bodyContainer.addChild(glowingD);
			
			//var decorStars:Bitmap = Window.backingShort(0, 'decorStars');
			//decorStars.width = descBacking.width;
			//decorStars.height = 100;
			//decorStars.smoothing = true;
			//decorStars.x = descBacking.x ;
			//decorStars.y = descBacking.y + descBacking.height - decorStars.height -50
			//bodyContainer.addChild(decorStars);
			
			var desc:TextField = Window.drawText(Locale.__e("Большая расспродажа арахиса"), {
				color:0xffffff,
				borderColor:0x3a4971,
				textAlign:"center",
				autoSize:"center",
				fontSize:34,
				textLeading:-6,
				multiline:true
			});
			desc.wordWrap = true;
			desc.width = descBacking.width - 50;
			desc.y = descBacking.y + 20;
			desc.x = descBacking.x + (descBacking.width - desc.width)/2;
			bodyContainer.addChild(desc);
			
			
			container = new Sprite();
			bodyContainer.addChild(container);
			container.x = 50;
			container.y = 60;
		}
		
		private var background:Bitmap
		public function changePromo(pID:String):void {
			
			App.self.setOffTimer(updateDuration);
			
			action = App.data.bigsale[pID];
			action.id = pID;
			
			settings.content = initContent(action.items);
			settings.bonus = initContent(action.bonus);
			
			settings.width = settings.content.length * 200 + 200;
			if (settings.content.length == 3) settings.width = 700;
			if (settings.content.length == 4) settings.width = 716;
			
			drawBackings();
			
			settings['L'] = settings.content.length + settings.bonus.length;
			if (settings['L'] < 2) settings['L'] = 2;
			
			
			drawImage();	
			contentChange();
			drawTime();
			updateDuration();
			App.self.setOnTimer(updateDuration);
			
			if(fader != null)
				onRefreshPosition();
				
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
			for (var sID:* in data)
				//result.push({sID:sID, count:data[sID], order:action.iorder[sID]});
				result.push({sID:data[sID].sID, count:data[sID].c, order:action.items[sID]});
			
			result.sortOn('order');
			return result;
		}
		
		private var axeX:int
		private var _descriptionLabel:TextField;
		
		override public function drawBody():void 
		{
			changePromo(settings['pID']);
			
			if(settings['L'] <= 3)
				axeX = settings.width - 170;
			else
				axeX = settings.width - 190;
				
			drawMirrowObjs('diamonds', -30, settings.width + 30, settings.height - 85);
			drawMirrowObjs('diamonds', -26, settings.width + 26, 85, false, false, false, 1, -1);
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
			
			if (glowing == null)
			{
				glowing = Window.backingShort(0, 'saleGlowPiece');
				bodyContainer.addChildAt(glowing, 0);
			}
			
			if (stars == null) {
				stars = Window.backingShort(0, 'decorStars');
				bodyContainer.addChildAt(stars, 1);
			}
			
			stars.smoothing = true;
			if (stars.width > settings.width - 40) stars.width = settings.width - 40;
			
			stars.x = 20;
			stars.y = settings.height - stars.height - 38;
			
			glowing.alpha = 0.85;
			glowing.x = axeX - glowing.width/2;
			glowing.y = settings.height - glowing.height - 38;
			glowing.smoothing = true;
			
			if (action.image == 'bigPanda') {
			
			}
			
			glowing.width = (settings.width - 100);
			glowing.x = 50;
			axeX = settings.width / 2;
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
			//for (var i:int = paginator.startCount; i < paginator.finishCount; i++)
			for (var i:int = 0; i < settings.content.length; i++)
			{
				var item:ActionItem = new ActionItem(settings.content[i], this);
				
				container.addChild(item);
				item.x = Xs;
				item.y = Ys;
								
				items.push(item);
				Xs += item.background.width + 12;
			}
			
			for (i = 0; i < settings.bonus.length; i++)
			{
				item = new ActionItem(settings.bonus[i], this, true);
				
				container.addChild(item);
				item.x = Xs;
				item.y = Ys;
								
				items.push(item);
				Xs += item.background.width;
			}
			
			container.y = backing.y + 30;
			container.x = (settings.width - 160 * (settings.content.length + settings.bonus.length)) / 2  - 12*(settings.content.length-1);
		}
		
		private var timerContainer:Sprite;
		public function drawTime():void {
			
			if (timerContainer != null)
				bodyContainer.removeChild(timerContainer);
				
			timerContainer = new Sprite()
			
			var background:Bitmap = Window.backingShort(200, "timeBg");
			timerContainer.addChild(background);
			background.x =  - background.width/2;
			background.y = 0;
			
			descriptionLabel = drawText(Locale.__e('flash:1393581955601'), {
				fontSize:30,
				textAlign:"left",
				color:0xffffff,
				borderColor:0x2b3b64
			});
			descriptionLabel.x =  background.x + (background.width - descriptionLabel.textWidth) / 2;
			descriptionLabel.y = background.y - descriptionLabel.textHeight / 2;
			timerContainer.addChild(descriptionLabel);
			
			//var time:int = action.duration * 60 * 60 - (App.time - App.user.promo[action.id].started);
			var time:int = action.duration * 60 * 60 - (App.time - action.time);
			//timerText = Window.drawText(TimeConverter.timeToCuts(time, true, true), {
			timerText = Window.drawText(TimeConverter.timeToStr(time), {
				color:0xf8d74c,
				letterSpacing:3,
				textAlign:"center",
				fontSize:34,//30,
				borderColor:0x502f06
			});
			timerText.width = 200;
			timerText.y = background.y + 14;
			timerText.x = background.x;
			
			timerContainer.addChild(timerText);
			
			bodyContainer.addChild(timerContainer);
			timerContainer.x = descBacking.x + (descBacking.width)/2;
			timerContainer.y = descBacking.y + descBacking.height - timerContainer.height;
		}
		
		private function updateDuration():void {
			var time:int = action.duration * 3600 - (App.time - App.data.actions[action.id].begin_time);
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
	}
}

import api.ExternalApi;
import buttons.ImagesButton;
import core.Load;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.geom.Point;

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
		//addChild(bttn);
		
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
			borderColor:0x634807,
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
		
		public function ActionItem(item:Object, window:*, bonus:Boolean = false) {
			
			sID = item.sID;
			count = item.count;
			
			this.window = window;
			this.bonus = bonus;
			
			var backType:String = 'itemBacking';
			//if (!bonus)
			//	backType = 'bonusBacking'
			
		
			background = Window.backing(160, 203, 10, backType);
			addChild(background);
			
			if (bonus)
				addBonusLabel();
			
			var sprite:LayerX = new LayerX();
			addChild(sprite);
			
			bitmap = new Bitmap();
			sprite.addChild(bitmap);
			
			
			//drawTitle();
			drawCount();
			drawBttn();
			
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
			Load.loading(Config.getIcon(type, preview), onPreviewComplete);
			//Load.loading(Config.getIcon(App.data.storage[sID].type, App.data.storage[sID].preview), onPreviewComplete);
		}
		
		private function getPreview(sid:int, type:String = "Reals"):String
		{
			var preview:String = App.data.storage[sID].preview;
			
			var arr:Array = [];
			arr = getIconsItems(type);
			arr.sortOn("order", Array.NUMERIC);
			
			if (arr.length == 0) return preview;
			preview = arr[arr.length-1].preview;
			for (var j:int = arr.length-1; j >= 0; j-- ) {
				if (count >= arr[j].price[sid]) {
					preview = arr[j].preview;
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
		
		public var priceBttn:Button
		public function drawBttn():void
		{
			priceBttn = new Button( {
				caption:Locale.__e("flash:1382952379751"),
				fontSize:24,
				width:124,
				hasDotes:false,
				height:40
			});
			addChild(priceBttn);
			priceBttn.x = (background.width - priceBttn.width) / 2;
			priceBttn.y = background.height - priceBttn.height / 2 - 8;
			
			priceBttn.addEventListener(MouseEvent.CLICK, buyEvent);
		}
		
		private function buyEvent(e:MouseEvent):void
		{
			/*if (e.currentTarget.mode == Button.DISABLED) return;
			
			switch(App.social) {
				case 'PL':
					//if(!App.user.stock.check(Stock.FANT, action.price[App.social])){
						//close();
						
						//break;
					//}
				case 'YB':
					if(App.user.stock.take(Stock.FANT, action.price[App.social])){
						Post.send({
							ctr:'Promo',
							act:'buy',
							uID:App.user.id,
							pID:sID,
							ext:App.social
						},function(error:*, data:*, params:*):void {
							onBuyComplete();
						});
					}else {
						close();
					}
					break;
				default:
					var object:Object;
					if (App.social == 'FB') {
						ExternalApi.apiNormalScreenEvent();
						object = {
							id:		 		sID,
							type:			'promo',
							title: 			Locale.__e('flash:1382952379793'),
							description: 	Locale.__e('flash:1382952380239'),
							callback:		onBuyComplete
						};
					}else{
						object = {
							count:			1,
							money:			'promo',
							type:			'item',
							item:			'promo_'+sID,
							votes:			action.price[App.self.flashVars.social],
							title: 			Locale.__e('flash:1382952379793'),
							description: 	Locale.__e('flash:1382952380239'),
							callback: 		onBuyComplete
						}
					}
					ExternalApi.apiPromoEvent(object);
					break;
			}*/
		}
		
		private function onBuyComplete(e:* = null):void 
		{
			/*priceBttn.state = Button.DISABLED;
			App.user.stock.addAll(action.items);
			App.user.stock.addAll(action.bonus);
			
			for each(var item:ActionItem in items) {
				var bonus:BonusItem = new BonusItem(item.sID, item.count);
				var point:Point = Window.localToGlobal(item);
					bonus.cashMove(point, App.self.windowContainer);
			}
			
			App.user.promo[action.id].status = 1;
			//App.ui.leftPanel.createPromoPanel();
			App.ui.salesPanel.createPromoPanel();
			
			close();
			
			new SimpleWindow( {
				label:SimpleWindow.ATTENTION,
				title:Locale.__e("flash:1382952379735"),
				text:Locale.__e("flash:1382952379990")
			}).show();*/
		}
		
		private function addBonusLabel():void {
			
			//removeChild(background);
			//background = null;
			//background = Window.backing(160, 200, 55, 'shopSpecialBacking');
			//addChild(background);
			//
			//var bonusIcon:Bitmap = new Bitmap(Window.textures.redBow);
			//bonusIcon.y = -20;
			//bonusIcon.x = -20;
			//addChild(bonusIcon);
			
		}
		
		public function onPreviewComplete(data:Bitmap):void
		{
			removeChild(preloader);
			
			bitmap.bitmapData = data.bitmapData;
			//bitmap.scaleX = bitmap.scaleY = 0.8;
			bitmap.smoothing = true;
			bitmap.x = (background.width - bitmap.width)/ 2;
			bitmap.y = (background.height - bitmap.height) / 2;// - 20;
			
			if (bonus)
				bitmap.filters = [new GlowFilter(0xffffff, 1, 40, 40)];
		}
		
		public function drawTitle():void {
			title = Window.drawText(String(App.data.storage[sID].title), {
				color:0x6d4b15,
				borderColor:0xfcf6e4,
				textAlign:"center",
				autoSize:"center",
				fontSize:24,
				textLeading:-6,
				multiline:true
			});
			title.wordWrap = true;
			title.width = background.width - 20;
			title.y = 10;
			title.x = 10;
			addChild(title);
		}
		
		public function drawCount():void {
			var countText:TextField = Window.drawText('x' + String(count), {
				color:0xffffff,
				borderColor:0x41332b,
				textAlign:"center",
				autoSize:"center",
				fontSize:32,
				textLeading:-6,
				multiline:true
			});
			countText.wordWrap = true;
			countText.width = background.width - 10;
			countText.y = 10;
			countText.x = 5;
			addChild(countText);
		}
}
