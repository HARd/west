package wins 
{
	import buttons.Button;
	import buttons.MenuButton;
	import buttons.MoneyButton;
	import by.blooddy.crypto.image.JPEGTableHelper;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import units.Hut;

	public class JamWindow extends Window
	{
		public static const FEED:int = 1;
		public static const BUY:int = 2;
		
		public var mode:uint = BUY;
		
		public var items:Array = new Array();
		public var icons:Array = new Array();
		
		public var buyJamBttn:Button;
		
		public function JamWindow(settings:Object = null) 
		{
			if (settings == null) {
				settings = new Object();
			}
			if (!settings.hasOwnProperty('view'))
				settings['view'] = 'jam';
				
			if(settings.view == 'jam'){
				settings['description1'] 	=  Locale.__e("flash:1382952380199");
				settings['description2'] 	=  Locale.__e("flash:1382952380200");
				settings['title'] 			=  Locale.__e('flash:1382952380201');
				settings['buyBttnCaption']	=  Locale.__e("flash:1382952380202");
			}else if (settings.view == 'fish') {
				settings['description1'] 	=  Locale.__e("flash:1382952380203");
				settings['description2'] 	=  Locale.__e("flash:1382952380204");
				settings['title'] 			=  Locale.__e('flash:1382952380205');
				settings['buyBttnCaption']	=  Locale.__e("flash:1382952380206");
			}
			
			settings['width'] = 612;
			settings['height'] = 420;
						
			settings['hasPaginator'] = true;
			settings['hasButtons'] = false;
			settings['onPageCount'] = 3;
			
			settings["find"] = settings.find || null;
			
			if (settings.hasOwnProperty('onFeedAction'))
				mode = JamWindow.FEED;
				
			settings.content = initContent(settings.view);
			super(settings);
		}
		
		private function initContent(view:String):Array
		{
			var item:*
			var result:Array = [];
			for (var sID:* in App.data.storage)
			{
				if (App.data.storage[sID].type == "Jam" && App.data.storage[sID].view.indexOf(view) != -1)
				{
					item = App.data.storage[sID];
					item['sID'] = sID;
					result.push(item);
				}
			}
			return result;
		}
		
		override public function drawBody():void {
			paginator.itemsCount = settings.content.length;
			paginator.update();
			
			var text:String = settings.description1;
			
			if (mode == JamWindow.FEED)	
				text = settings.description2;
			
			var descriptionLabel:TextField = drawText(text, {
				fontSize:22,
				autoSize:"left",
				textAlign:"center",
				color:0x604729,
				borderColor:0xfaf1df
			});
			
			descriptionLabel.x = (settings.width - descriptionLabel.width) / 2;
			descriptionLabel.y = 30;
			descriptionLabel.width = settings.width - 80;
			
			bodyContainer.addChild(descriptionLabel);
			
			drawMenu();
			drawBacking();
			contentChange();
		}
		
		public override function contentChange():void 
		{
			for each(var _item:JamItem in items)
			{
				bodyContainer.removeChild(_item);
				_item.dispose();
				_item = null;
			}
			
			items = [];
			
			var Xs:int = 70;
			var Ys:int = 70;
			var X:int = 70;
			
			var itemNum:int = 0;
			for (var i:int = paginator.startCount; i < paginator.finishCount; i++)
			{
				var item:JamItem = new JamItem(settings.content[i], this, i);
				
				bodyContainer.addChild(item);
				item.x = Xs;
				item.y = Ys;
								
				items.push(item);
				Xs += item.background.width + 10;
				
				/*if (itemNum == int(settings.itemsOnPage / 2) - 1)	{
					Xs = X;
					Ys += item.background.height + 10;
				}*/
				itemNum++;
			}
		}	
		
		public function drawBacking():void 
		{
			var dY:int = 60;
			var backing:Bitmap = Window.backing(settings.width-120, 220, 50);
			bodyContainer.addChild(backing);
			backing.x = settings.width/2 - backing.width/2;
			backing.y = dY;
		}
		
		public function drawMenu():void {
			
			buyJamBttn = new Button( {
				caption:settings.buyBttnCaption,
				width:180,
				fontSize:22,
				height:35,
				borderColor:			[0xf3a9b3,0x550f16],
				fontColor:				0xe6dace,
				fontBorderColor:		0x550f16,
				bgColor:				[0xbf3245,0x761925]
			});
			
			bodyContainer.addChild(buyJamBttn);
			buyJamBttn.x = (settings.width - buyJamBttn.width) / 2;
			buyJamBttn.y = 290;
			
			buyJamBttn.addEventListener(MouseEvent.CLICK, openPurchaseWindow);
			
			
			/*var menuSettings:Object = {
				1: {order:0,	title:Locale.__e("flash:1382952379751"), onMouseDown:openShopWindow, width:120},
				2: {order:1,	title:Locale.__e("flash:1382952380207"), onMouseDown:null, width:120}
			}
			
			for (var item:* in menuSettings) {
				icons.push(new MenuButton(menuSettings[item]));
			}
			icons.sortOn("order");
	
			var offset:int = 174;
			for (var i:int = 0; i < icons.length; i++)
			{
				icons[i].x = offset;
				icons[i].y = 290;
				offset += icons[i].width + 6;
				bodyContainer.addChild(icons[i]);
			}*/
		}
		
		public function openPurchaseWindow(e:MouseEvent = null):void
		{
			return;
			/*var settings:Object = {
				content:PurchaseWindow.createContent("Jam",{view:'jam'}),
				title:Locale.__e("flash:1382952380202"),
				description:Locale.__e("flash:1382952380208"),
				popup:true,
				closeAfterBuy:false,
				callback:function(sID:int):void {
					contentChange();
				}
			}
			
			if (this.settings.view == 'fish') {
				settings['content'] = PurchaseWindow.createContent("Jam",{ view:'fish' } );
				settings['title'] = Locale.__e("flash:1382952380206");
				settings['description'] = Locale.__e("flash:1382952380209");
				settings['callback'] = function(sID:int):void {
					contentChange();
				}
			}
			
			new PurchaseWindow(settings).show();*/
		}		
		
		private function openShopWindow(e:MouseEvent):void
		{
			new ShopWindow( { section:7, page:0 } ).show();
			close();
		}
		
		public override function dispose():void
		{
			for each(var _icon:MenuButton in icons)
			{
				_icon.dispose();
				_icon = null;
			}
			
			for each(var _item:JamItem in items)
			{
				_item.dispose();
				_item = null;
			}
			
			buyJamBttn.removeEventListener(MouseEvent.CLICK, openPurchaseWindow);
			
			super.dispose();
		}
	}
}	


import adobe.utils.CustomActions;
import buttons.Button;
import buttons.ImageButton;
import com.greensock.TweenMax;
import core.Load;
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.text.TextField;
import ui.Hints;
import ui.UserInterface;
import units.Field;
import units.Unit;
import wins.elements.PriceLabel;
import wins.Window;
import wins.JamWindow;
import wins.PurchaseWindow;

internal class JamItem extends Sprite {
	
	public var item:*;
	public var background:Bitmap;
	public var bitmap:Bitmap;
	public var title:TextField;
	public var jamCounter:TextField;
	public var id:uint;
	public var placeBttn:Button;
	public var buyBttn:Button;
	public var window:*;
	public var wishBttn:ImageButton;
	
	public var moneyType:String = "coins";
	private var preloader:Preloader = new Preloader();
	
	private var jamTick:LayerX;
	private var jamTickBitmap:Bitmap;


	public function JamItem(item:*, window:*, id:*) {
		
		this.id = id
		this.item = item;
		this.window = window;
		
		background = Window.backing(150, 180, 10, "itemBacking");
		addChild(background);
		
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
		preloader.y = (background.height) / 2 - 10;
		
		jamTick = new LayerX();
		jamTickBitmap = new Bitmap(UserInterface.textures.tick);
		jamTick.addChild(jamTickBitmap);
		addChild(jamTick)
		jamTick.x = background.width - jamTick.width + 10;
		jamTick.y = 0;
		jamTick.visible = false;
		jamTick.tip = function():Object { 
			return {
				title:"",
				text:Locale.__e("flash:1382952379767 варенья переполнен.")
			};
		};
		
		Load.loading(Config.getIcon(item.type, item.preview), onPreviewComplete);
		drawFeedBttn();
		drawCapacity();
		drawInfo();
		
		if (App.user.stock.count(item.sID) <= 0)
		{
			bitmap.alpha = 0.5;
			placeBttn.visible = false;
			buyBttn.visible = true;
		}
		
		if (window.settings.find != null && window.settings.find.indexOf(int(item.sID)) != -1) {
			glowing();
		}
	}
	
	private function drawCapacity():void
	{
		var container:Sprite = new Sprite();
		var spoonIcon:Bitmap = new Bitmap();
		
		var _text:String;
		var textSettings:Object;
		textSettings = {
				color				: 0x614605,
				fontSize			: 16,
				borderColor 		: 0xf5efd9
			}
			
		if (item.view.indexOf('jam') != -1) {
			spoonIcon = new Bitmap(UserInterface.textures.spoonIcon);
			spoonIcon.scaleX = spoonIcon.scaleY = 0.25;
			switch(id)
			{
				case 0: _text = Locale.__e("flash:1382952380067"); break;
				case 1: _text = Locale.__e("flash:1382952380068"); break;
				case 2: _text = Locale.__e("flash:1382952380069"); break;
			}
		}else {
			spoonIcon = new Bitmap(UserInterface.textures.spoonIconFish);
			spoonIcon.scaleX = spoonIcon.scaleY = 0.35;
			switch(id)
			{
				case 0: _text = Locale.__e("flash:1382952380070"); break;
				case 1: _text = Locale.__e("flash:1382952380071"); break;
				case 2: _text = Locale.__e("flash:1382952380072"); break;
			}
		}
		
		spoonIcon.smoothing = true;
		
		var text:TextField = Window.drawText(_text + ":", textSettings);
		
		text.width 	= text.textWidth + 4;
		text.height = text.textHeight;
		
		var countText:TextField = Window.drawText(String(App.data.storage[item.sID].capacity), textSettings);
		
		countText.height = countText.textHeight;
		countText.width = countText.textWidth + 4;
		countText.border = false;
		
		countText.x = text.width + 4;
		
		spoonIcon.x = countText.x + countText.width + 4;
		spoonIcon.y = countText.y + (countText.textHeight - spoonIcon.height) / 2;
		
		container.addChild(text);
		container.addChild(countText);
		container.addChild(spoonIcon);
		
		addChild(container);
		container.x = (background.width - container.width) / 2;
		container.y = background.height - container.height - 16;//12;
	}
	
	public function drawInfo():void {
		
		var cont:Sprite = new Sprite();

		var textSettings:Object = {
				color:0x4f0e14,
				borderColor:0xf0e9db,
				fontSize:23
			};
		var text:String = String(App.user.stock.count(item.sID));
		
		/*if (item.sID == Stock.JAM)
		{
			text += " / " + (App.data.levels[App.user.level].jam || 0);
			if (App.user.stock.count(Stock.JAM) >= App.data.levels[App.user.level].jam)
				jamTick.visible = true;
			else
				jamTick.visible = false;
		}*/
		
		if(item.view == 'fish')
			textSettings['color'] = 0x323a05;
		
		jamCounter = Window.drawText(text, textSettings);
		jamCounter.width = jamCounter.textWidth+4;
		jamCounter.height = jamCounter.textHeight;
		jamCounter.x = 0;
		jamCounter.y = 0;
		cont.addChild(jamCounter);
		
		addChild(cont);
		cont.x = (background.width - cont.width)/2;
		cont.y = 120;
	}
	
	public function onPreviewComplete(data:Bitmap):void
	{
		removeChild(preloader);
		bitmap.bitmapData = data.bitmapData;
		//bitmap.scaleX = bitmap.scaleY = 0.8;
		bitmap.smoothing = true;
		bitmap.x = (background.width - bitmap.width)/ 2;
		bitmap.y = (background.height - bitmap.height)/ 2 - 10;
	}
	
	public function dispose():void {
		if(placeBttn != null){
			placeBttn.removeEventListener(MouseEvent.CLICK, onPlaceClick);
		}
		
		if (Quests.targetSettings != null) {
			Quests.targetSettings = null;
			if (App.user.quests.currentTarget == null) {
				QuestsRules.getQuestRule(App.user.quests.currentQID, App.user.quests.currentMID);
			}
		}
		
		//wishBttn.removeEventListener(MouseEvent.CLICK, onWishEvent);
	}
	
	public function drawTitle():void {
		title = Window.drawText(String(item.title), {
			color:0x6d4b15,
			borderColor:0xfcf6e4,
			textAlign:"center",
			autoSize:"center",
			fontSize:20,
			multiline:true
		});
		title.wordWrap = true;
		title.width = background.width - 10;
		title.y = 10;
		title.x = (background.width - title.width)/2;
		addChild(title)
	}
	
	public function drawFeedBttn():void {
		
		var caption:String = Locale.__e("flash:1382952379978"); 
		
		if (window.mode == JamWindow.BUY)	
			caption = Locale.__e("flash:1382952380210"); 
			
		var icon:Bitmap;
		var settings:Object = { fontSize:16, autoSize:"left" };
		var bttnSettings:Object = {
			caption:caption,
			fontSize:22,
			width:94,
			height:30
		};
		
		placeBttn = new Button(bttnSettings);
		addChild(placeBttn);
		placeBttn.x = background.width/2 - placeBttn.width/2;
		placeBttn.y = height - 18;
		
		placeBttn.addEventListener(MouseEvent.CLICK, onPlaceClick);
		
		bttnSettings = {
			caption:Locale.__e("flash:1382952379751"),
			fontSize:22,
			width:94,
			height:30,
			borderColor:			[0xf3a9b3,0x550f16],
			fontColor:				0xe6dace,
			fontBorderColor:		0x550f16,
			bgColor:				[0xbf3245,0x761925]
		};
		
		buyBttn = new Button(bttnSettings);
		addChild(buyBttn);
		buyBttn.x = placeBttn.x;
		buyBttn.y = placeBttn.y;
		
		buyBttn.addEventListener(MouseEvent.CLICK, onBuyClick);
		
		buyBttn.visible = false;
	}
	
	private function onBuyClick(e:MouseEvent):void
	{
		if (e.currentTarget.mode == Button.DISABLED) return;
		
		window.openPurchaseWindow();
		/*new PurchaseWindow( {
				content:PurchaseWindow.createContent("Jam", {view:'fish'}),
				title:Locale.__e("flash:1382952380202"),
				description:Locale.__e("flash:1382952380208"),
				popup:true,
				closeAfterBuy:false,
				callback:function(sID:int):void {
					App.ui.glowing(App.ui.upPanel.jamBttn, 0x7b1012);
					window.contentChange();
				}
			}).show();*/
	}
	
	private function onPlaceClick(e:MouseEvent):void
	{
		if (e.currentTarget.mode == Button.DISABLED) return;
		
		if (window.mode == JamWindow.FEED){	
			window.settings.onFeedAction(item.sID);
		} else {
			var unit:Unit = Unit.add( { sid:item.sID, fromStock:true} );
			unit.move = true;
			App.map.moved = unit;
		};
		window.close();
	}
	
	private function onWishEvent(e:MouseEvent):void
	{
		App.wl.show(item.sID, e);
	}
	
	private function glowing():void {
		if (!App.user.quests.tutorial) {
			customGlowing(background, glowing);
		}
		
		if (placeBttn) {
			if (App.user.quests.tutorial) {
				App.user.quests.currentTarget = placeBttn;
				placeBttn.showGlowing();
				placeBttn.showPointing("top", placeBttn.width/2 - 15, 0, placeBttn.parent);
			}else {
				customGlowing(placeBttn);
			}
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

