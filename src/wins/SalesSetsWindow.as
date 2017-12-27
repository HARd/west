package wins 
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
	import flash.geom.Point;
	import flash.text.TextField;
	import ui.UserInterface;
	import units.Hut;

	public class SalesSetsWindow extends Window
	{
		private var items:Array = new Array();
		public var action:Object;
		private var container:Sprite;
		//private var priceBttn:Button;
		private var timerText:TextField;
		private var descriptionLabel:TextField;
		
		public function SalesSetsWindow(settings:Object = null)
		{
			if (settings == null) {
				settings = new Object();
			}
			
			settings['width'] = 750;
			settings['height'] = 540;
						
			settings['title'] = Locale.__e("flash:1382952379793");
			settings["itemsOnPage"] = 4;
			settings['hasPaginator'] = false;
			settings['hasButtons'] = false;
			

			super(settings);
		}
		
		override public function drawArrows():void {
				
			paginator.drawArrow(bodyContainer, Paginator.LEFT,  0, 0, { scaleX: -1, scaleY:1 } );
			paginator.drawArrow(bodyContainer, Paginator.RIGHT, 0, 0, { scaleX:1, scaleY:1 } );
			
			var y:Number = (settings.height - paginator.arrowLeft.height) / 2 - 30;
			paginator.arrowLeft.x = -paginator.arrowLeft.width/2 + 22;
			paginator.arrowLeft.y = y;
			
			paginator.arrowRight.x = settings.width-paginator.arrowRight.width/2 - 22;
			paginator.arrowRight.y = y;
			
		}
		
		override public function drawBackground():void 
		{
			var background:Bitmap = backing2(settings.width, settings.height, 45, 'questsSmallBackingTopPiece', 'questsSmallBackingBottomPiece');
			layer.addChild(background);
		}
		
		private var background:Bitmap
		public function changePromo(pID:String):void {
			
			App.self.setOffTimer(updateDuration);
			
			action = App.data.promo[pID];
			action.id = pID;
			
			action.items[110] = 1;
			action.items[111] = 1;
			
			settings.content = initContent(action.items);
			settings.bonus = initContent(action.bonus);
			
			settings['L'] = settings.content.length + settings.bonus.length;
			if (settings['L'] < 2) settings['L'] = 2;
			
			paginator.page = 0;
			paginator.itemsCount = settings.content.length;
			paginator.update();
			
			drawImage();	
			contentChange();
			//drawPrice();
			drawTime();
			
			App.self.setOnTimer(updateDuration);
			
			if(fader != null)
				onRefreshPosition();
				
			titleLabel.x = (settings.width - titleLabel.width) / 2;	
			_descriptionLabel.x = settings.width/2 - _descriptionLabel.width/2;
			exit.y -= 10;
			
			if (menuSprite != null){
				menuSprite.x = settings.width / 2 - (promoCount * 70) / 2 - 20;
			}
		}
		
		private function initContent(data:Object):Array
		{
			var result:Array = [];
			for (var sID:* in data) {
				result.push({sID:sID, count:data[sID], order:action.iorder[sID]});
			}
			
			result.sortOn('order');
			return result;
		}
		
		private var axeX:int
		private var _descriptionLabel:TextField;
		override public function drawBody():void 
		{	
			
			titleLabel.y -= 10;
			paginator.y += 34;
			
			drawMirrowObjs('diamondsTop', settings.width / 2 - settings.titleWidth / 2 - 5, settings.width / 2 + settings.titleWidth / 2 + 5, -50, true, true);
			drawMirrowObjs('diamonds', -30, settings.width + 30, settings.height - 115);
			drawMirrowObjs('diamonds', -26, settings.width + 26, 50, false, false, false, 1, -1);
			
			var backing:Bitmap = Window.backing(710, 420, 43, 'shopBackingSmall');
			bodyContainer.addChild(backing);
			backing.x = (settings.width - backing.width) / 2;
			backing.y = 30;
			backing.alpha = 0.5;
			
			
			var ribbon:Bitmap = backingShort(660, 'blueRibbon2');
			ribbon.y = -10;
			ribbon.x = (settings.width - ribbon.width) / 2;
			bodyContainer.addChild(ribbon);
			
			var text:String = Locale.__e("flash:1393582651596");
			_descriptionLabel = drawText(text, {
				fontSize:26,
				autoSize:"left",
				textAlign:"center",
				color:0xffffff,
				borderColor:0x175d8e
			});
			
			//_descriptionLabel.border = true;
			_descriptionLabel.y = 3;
			
			bodyContainer.addChild(_descriptionLabel);
			
			container = new Sprite();
			bodyContainer.addChild(container);
			container.x = 50;
			container.y = 60;
			
			//drawMenu();
			changePromo(settings['pID']);
			
			if(settings['L'] <= 3)
				axeX = settings.width - 170;
			else
				axeX = settings.width - 190;
				
			_descriptionLabel.x = settings.width / 2 - _descriptionLabel.width / 2;
			
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
			for (var i:int = paginator.startCount; i < paginator.finishCount; i++)
			//for (var i:int = 0; i < settings.content.length; i++)
			{
				var item:ActionItem = new ActionItem(settings.content, action, this);
				
				container.addChild(item);
				item.x = Xs;
				item.y = Ys;
								
				items.push(item);
				Xs += item.background.width + 4;
				
				if (itemNum == 1) {
					Xs = 0;
					Ys += item.background.height + 18;
				}
				itemNum++;
			}
			
			container.y = 56;
			container.x = 44;
		}
		
		private var timerContainer:Sprite;
		public function drawTime():void {
			
			if (timerContainer != null)
				bodyContainer.removeChild(timerContainer);
				
			timerContainer = new Sprite()
			
			var background:Bitmap = Window.backingShort(160, "timeBg");
			timerContainer.addChild(background);
			background.x =  - background.width/2;
			background.y = 0//settings.height - background.height - 80;
			
			descriptionLabel = drawText(Locale.__e('flash:1393581955601'), {
				fontSize:30,
				textAlign:"left",
				color:0xffffff,
				borderColor:0x2b3b64
			});
			descriptionLabel.x =  background.x + (background.width - descriptionLabel.textWidth) / 2;
			descriptionLabel.y = background.y - descriptionLabel.textHeight / 2;
			timerContainer.addChild(descriptionLabel);
			
			var time:int = action.duration * 60 * 60 - (App.time - App.user.promo[action.id].started);
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
			timerText.x = background.x - 20;
			
			timerContainer.addChild(timerText);
			
			bodyContainer.addChild(timerContainer);
			timerContainer.x = 12 + timerContainer.width/2;
			timerContainer.y = -10;
		}
		
		private var cont:Sprite;
		private function updateDuration():void {
			var time:int = action.duration * 60 * 60 - (App.time - App.user.promo[action.id].started);
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
import buttons.Button;
import core.Load;
import core.Post;
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.filters.GlowFilter;
import flash.geom.Point;
import flash.text.TextField;
import ui.UserInterface;
import wins.Window;
import wins.SimpleWindow;

internal class ActionItem extends Sprite {
		
		public var background:Bitmap;
		public var window:*;
		
		private var priceBttn:Button;
		
		private var bonus:Boolean = false;
		
		private var preloader:Preloader = new Preloader();
		
		private var items:Object;
		private var action:Object;
		
		public function ActionItem(items:Object, action:Object, window:*) {
			
			this.items = items;
			this.action = action;
			
			this.window = window;
			
			
			var backType:String = 'itemBacking';
			
		
			background = Window.backing(330, 176, 10, backType);
			addChild(background);
			
			addChild(preloader);
			preloader.x = (background.width - preloader.width) / 2;
			preloader.y = (background.height - preloader.height) / 2;
			
			drawPrice();
			
			createIcons();
		}
		
		private var arrIcons:Array = [];
		private function createIcons():void 
		{
			for (var itm:* in items) {
				var icon:SetIcon = new SetIcon(items[itm], this);
				arrIcons.push(icon);
			}
		}
		
		private var iconsCont:Sprite = new Sprite();
		private var countIcons:int = 0;
		public function setPositions():void
		{
			countIcons += 1;
			
			if (countIcons >= arrIcons.length) {
				var posX:int = 0;
				for (var i:int = 0; i < arrIcons.length; i++ ) {
					var icon:SetIcon = arrIcons[i];
					icon.x = posX;
					iconsCont.addChild(icon);
					
					posX += icon.width + 8;
				}
				
				if(contains(preloader))removeChild(preloader);
				
				addChild(iconsCont);
				iconsCont.x = (background.width - iconsCont.width) / 2;
				iconsCont.y = 12;
			}
		}
		
	private var cont:Sprite;
	public function drawPrice():void {
		
		var bttnSettings:Object = {
			fontSize:26,
			width:158,
			height:42,
			hasDotes:false
		};
		
		if (priceBttn != null)
			removeChild(priceBttn);
		
		bttnSettings['caption'] = Payments.price(action.price[App.social]);
		priceBttn = new Button(bttnSettings);
		addChild(priceBttn);
		
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
		
		priceBttn.x = (background.width - priceBttn.width) / 2;
		priceBttn.y = background.height - priceBttn.height / 2 - 4;
		
		priceBttn.addEventListener(MouseEvent.CLICK, buyEvent);
		
		if (cont != null)
			removeChild(cont);
			
		cont = new Sprite();
		
		addChild(cont);
		cont.x = priceBttn.x + priceBttn.width / 2 - cont.width / 2;
		cont.y = priceBttn.y - 30;
	}
	
	private function buyEvent(e:MouseEvent):void
	{
		if (e.currentTarget.mode == Button.DISABLED) return;
		
		//descriptionLabel.visible = false;
		//timerText.visible = false;
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
						pID:action.id,
						ext:App.social
					},function(error:*, data:*, params:*):void {
						onBuyComplete();
					});
				}else {
					window.close();
				}
				break;
			default:
				var object:Object;
				if (App.social == 'FB') {
					ExternalApi.apiNormalScreenEvent();
					object = {
						id:		 		action.id,
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
						item:			'promo_'+action.id,
						votes:			int(action.price[App.self.flashVars.social]),
						title: 			Locale.__e('flash:1382952379793'),
						description: 	Locale.__e('flash:1382952380239'),
						callback: 		onBuyComplete
					}
				}
				ExternalApi.apiPromoEvent(object);
				break;
		}
	}
	
	private function onBuyComplete(e:* = null):void 
	{
		priceBttn.state = Button.DISABLED;
		 App.user.stock.addAll(items);
		// App.user.stock.addAll(action.bonus);
		
		for each(var item:SetIcon in arrIcons) {
			var bonus:BonusItem = new BonusItem(item.item.sID, item.item.count);
			var point:Point = Window.localToGlobal(item);
				bonus.cashMove(point, App.self.windowContainer);
		}
		
		App.user.promo[action.id].buy = 1;
		App.user.buyPromo(action.id);
		App.ui.salesPanel.createPromoPanel();
		
		window.close();
		
		new SimpleWindow( {
			label:SimpleWindow.ATTENTION,
			title:Locale.__e("flash:1382952379735"),
			text:Locale.__e("flash:1382952379990")
		}).show();
	}
		
}

internal class SetIcon extends LayerX
{
	public var item:Object;
	public var bitmap:Bitmap;
	
	private var preloader:Preloader = new Preloader();
	
	private var target:ActionItem;
	
	public function SetIcon(item:Object, cont:ActionItem)
	{
		this.item = item;
		target = cont;
		
		addChild(preloader);
		
		
		var sprite:LayerX = new LayerX();
		addChild(sprite);
		
		bitmap = new Bitmap();
		sprite.addChild(bitmap);
		
		drawTitle();
		drawCount();
		
		Load.loading(Config.getIcon(App.data.storage[item.sID].type, App.data.storage[item.sID].preview), onPreviewComplete);
	}
	
	private var bitmapHeight:int = 84;
	public function onPreviewComplete(data:Bitmap):void
	{
		removeChild(preloader);
		
		bitmap.bitmapData = data.bitmapData;
		bitmap.height = bitmapHeight;
		bitmap.scaleX = bitmap.scaleY;
		bitmap.smoothing = true;
		bitmap.y = 26;
		
		countText.width = bitmap.width - 10;
		title.width = bitmap.width - 10;
		title.x = (bitmap.width - title.width) / 2;
		countText.x = (bitmap.width - countText.width) / 2;
		
		target.setPositions();
	}
	
	private var title:TextField;
	public function drawTitle():void 
	{
		title = Window.drawText(String(App.data.storage[item.sID].title), {
			color:0x814f31,
			borderColor:0xfcf6e4,
			textAlign:"center",
			autoSize:"center",
			fontSize:20,
			textLeading:-6,
			multiline:true
		});
		title.wordWrap = true;
		title.width = bitmap.width - 10;
		title.y = 0;
		title.x = 10;
		addChild(title);
	}
	
	private var countText:TextField;
	public function drawCount():void {
		countText = Window.drawText('x' + String(item.count), {
			color:0xffffff,
			borderColor:0x41332b,
			textAlign:"center",
			autoSize:"center",
			fontSize:24,
			textLeading:-6,
			multiline:true
		});
		countText.wordWrap = true;
		countText.width = bitmap.width - 10;
		countText.y = bitmapHeight + 24;
		countText.x = 20;
		addChild(countText);
	}
	
	
}
