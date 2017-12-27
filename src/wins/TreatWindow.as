package wins 
{
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.text.TextField;

	public class TreatWindow extends Window 
	{
		
		public function TreatWindow(settings:Object=null) 
		{
			if (settings == null) {
				settings = new Object();
			}
			
			settings['width'] 			= 600;
			settings['height'] 			= 400;
			settings['title'] 			= Locale.__e('flash:1382952379828');
			settings['hasPaginator'] 	= true;
			settings['hasButtons']		= false;
			settings['itemsOnPage'] 	= 4;
			settings['target'] 			= settings.target || null;
			settings['helpSID'] 		= settings.helpSID || 0;
			var items:Array = [];
			for (var item:String in App.data.storage) {
				if ( App.data.storage[item].type == 'Food') {
					var obj:Object = { sid:item, treat:App.data.storage[item]};
					items.push(obj);
				}
			}
			
			settings['content']         = items;
			
			super(settings);
		}
		
		override public function drawBody():void {
			var description:TextField = drawText(Locale.__e('flash:1436965915848'), {
				color:0x532b07,
				border:true,
				borderColor:0xfde1c9,
				fontSize:26,
				multiline:true,
				autoSize: 'center',
				textAlign:"center"
			});
			description.wordWrap = true;
			description.width = 550;
			description.x = (settings.width - description.width) / 2;
			description.y = 20;
			bodyContainer.addChild(description);
			
			var separator:Bitmap = Window.backingShort(description.width - 60, 'dividerLine', false);
			separator.x = description.x + 35;
			separator.y = description.y + description.textHeight + 5;
			separator.alpha = 0.5;
			bodyContainer.addChild(separator);
			
			if (settings.content.length != 0) {
				paginator.itemsCount = settings.content.length;
				paginator.update();
				paginator.onPageCount = 4;
			}
			
			contentChange();
		}
		
		private var items:Array;
		private var itemsContainer:Sprite = new Sprite();
		override public function contentChange():void {
			if (items) {
				for each(var _item:* in items) {
					itemsContainer.removeChild(_item);
					_item.dispose();
				}
			}
			items = [];
			
			bodyContainer.addChild(itemsContainer);
			var target:*;
			var X:int = 0;
			var Xs:int = X;
			var Ys:int = 70;
			itemsContainer.x = 85;
			itemsContainer.y = Ys;
			for (var i:int = paginator.startCount; i < paginator.finishCount; i++)
			{
					var item:TreatItem = new TreatItem(this, { sID:settings.content[i].sid, hut:settings.content[i] } );
					item.x = Xs;
					items.push(item);
					itemsContainer.addChild(item);
					
					Xs += item.bg.width + 20;
			}
			
			if (settings.content.length < 4) itemsContainer.x = (settings.width - itemsContainer.width) / 2;
		}
		
		public override function dispose():void {
			if (items) {
				for each(var _item:* in items) {
					itemsContainer.removeChild(_item);
					_item.dispose();
				}
			}
			items = [];
			
			super.dispose();
		}
		
	}

}

import buttons.Button;
import buttons.MoneyButton;
import core.Load;
import core.Size;
import core.TimeConverter;
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.text.TextField;
import ui.Hints;
import ui.UserInterface;
import units.Unit;
import wins.ShopWindow;
import wins.TreatWindow;
import wins.Window;

internal class TreatItem extends Sprite
{
	public var window:*;
	public var item:Object;
	public var bg:Sprite;
	private var bitmap:Bitmap;
	private var sID:uint;
	public var bttn:Button;
	
	private var need:int = 1;
	private var count:int = 0;
	
	public function TreatItem(window:TreatWindow, data:Object)
	{
		this.sID = data.sID;
		this.item = App.data.storage[sID];
		this.window = window;
		
		count = App.user.stock.count(sID);
		
		bg = new Sprite();
		bg.graphics.beginFill(0xcbd4cf);
		bg.graphics.drawCircle(65, 100, 65);
		bg.graphics.endFill();
		addChild(bg);
		
		Load.loading(Config.getIcon(item.type, item.preview), onLoad);
		
		drawCount();
		drawTime();
		drawBttn();
	}
	
	private function onClick(e:MouseEvent):void 
	{
		if (e.currentTarget.mode == Button.DISABLED) return;
		Window.closeAll();
		
		var sidKettle:uint = 672;
			
		switch (sID) {
			case 658:
				sidKettle = 672;
				break;
			case 659:
				sidKettle = 673;
				break;
			case 660:
				sidKettle = 674;
				break;
			default: 
				sidKettle = 672;
				break;
		}
		
		var energyObject:Object = {
			foodID: sID,
			duration: item.duration
		}
		
		var food:Unit = Unit.add( { sid:sidKettle, buy:false,  energyObject:energyObject, callback:window.settings.target.goOnPremiumFeed } );
		food.move = true;
		App.map.moved = food;	
	}
	
	private var sprite:LayerX;
	private function onLoad(data:Bitmap):void {
		sprite = new LayerX();
		sprite.tip = function():Object {
			return {
				title: item.title,
				text: item.description
			};
		}
		sprite.addEventListener(MouseEvent.CLICK, searchEvent);
		bitmap = new Bitmap(data.bitmapData);
		Size.size(bitmap, 120, 120);
		addChildAt(sprite, 1);
		sprite.addChild(bitmap);
		bitmap.x = (bg.width - bitmap.width) / 2;
		bitmap.y = (bg.height - bitmap.height) / 2 + 35;
		bitmap.smoothing = true;
	}
	
	private var searchBttn:Button;
	public var buyBttn:MoneyButton;
	private function drawBttn():void 
	{
		var bttnSettings:Object = {
			caption:Locale.__e("flash:1436962960359"),
			width:110,
			height:36,
			fontSize:26
		}
		
		bttn = new Button(bttnSettings);
		
		addChild(bttn);
		bttn.x = (bg.width - bttn.width) / 2;
		bttn.y = bg.height + 75;
		bttn.addEventListener(MouseEvent.CLICK, onClick);
		
		searchBttn = new Button({
			caption			:Locale.__e("flash:1405687705056"),
			fontSize		:15,
			radius      	:10,
			fontColor:		0xffffff,
			fontBorderColor:0x475465,
			borderColor:	[0xfff17f, 0xbf8122],
			bgColor:		[0x75c5f6,0x62b0e1],
			bevelColor:		[0xc6edfe,0x2470ac],
			width			:94,
			height			:30,
			fontSize		:15
		});
		searchBttn.x = (bg.width - searchBttn.width) / 2;
		searchBttn.y = bg.height + 40;
		addChild(searchBttn);
		searchBttn.addEventListener(MouseEvent.CLICK, searchEvent);
		
		var price:int = item.price[Stock.FANT];
		buyBttn = new MoneyButton({
			caption		:Locale.__e('flash:1382952379751'),
			width		:110,
			height		:36,
			fontSize	:22,
			radius		:16,
			countText	:price,
			multiline	:true
		});
		buyBttn.x = (bg.width - buyBttn.width) / 2;
		buyBttn.y = bg.height + 75;
		addChild(buyBttn);
		buyBttn.addEventListener(MouseEvent.CLICK, buyEvent);
		
		updateState();
	}
	
	public function updateState():void {
		//textCount.text = String(count) + ' / ' + String(need);
		drawCount();
		
		if (App.user.stock.check(sID, need, true)) {
			buyBttn.visible = false;
			searchBttn.visible = false;
			bttn.visible = true;
			
			if (window.settings.helpSID == sID) {
				bttn.showGlowing();
			}
			
			spriteCount.y = bg.height + 35;
		} else {
			buyBttn.visible = true;
			searchBttn.visible = true;
			bttn.visible = false;
			
			spriteCount.y = bg.height + 5;
		}
	}
	
	private var spriteCount:Sprite = new Sprite();
	private var textCount:TextField;
	public function drawCount():void {		
		var color:uint = 0xef7563;
		var borderColor:uint = 0x623126;
		if (count >= need) {
			color = 0xfedc34;
			borderColor = 0x694c14;
		}
		
		if (contains(spriteCount)) {
			spriteCount.removeChild(textCount);
			removeChild(spriteCount);
		}
		
		textCount = Window.drawText(String(count) + ' / ' + String(need), {
			color:color,
			fontSize:30,
			borderColor:borderColor
		});
		textCount.width = textCount.textWidth + 10;
		spriteCount.addChild(textCount);
		
		spriteCount.x = (bg.width - spriteCount.width) / 2;
		spriteCount.y = bg.height + 5;
		addChild(spriteCount);
	}
	private var textTime:TextField;
	public function drawTime():void {
		var time:int = item.duration;
		var color:uint = 0x4e2c09;
		var borderColor:uint = 0xf7e6cc;
		textTime = Window.drawText(TimeConverter.timeToCuts(time, false, true), {
			color:color,
			fontSize:26,
			borderColor:borderColor
		});
		textTime.width = textTime.textWidth + 5;
		textTime.x = (bg.width - textTime.width) / 2;
		//textTime.y += 15;
		addChild(textTime);
	}
	
	private function searchEvent(e:MouseEvent):void {
		ShopWindow.findMaterialSource(sID);
	}
	
	private var pnt:Point;
	private function buyEvent(e:MouseEvent):void {
		if (e.currentTarget.mode == Button.DISABLED) return;
			
		var _x:int = App.self.tipsContainer.mouseX - buyBttn.mouseX;
		var _y:int = App.self.tipsContainer.mouseY - buyBttn.mouseY;
		
		pnt = new Point(_x, _y);
		pnt.x += buyBttn.width / 2;
		pnt.y += -20;
		
		var def:int = need -  App.user.stock.count(sID);
		e.currentTarget.state = Button.DISABLED;
		App.user.stock.buy(sID, def, onBuyEvent);
	}
	
	private function onBuyEvent(price:Object):void
	{
		for (var sid:* in price) {
			Hints.minus(sid, price[sid], pnt, false);
			break;
		}
		
		count = App.user.stock.count(sID);
		
		updateState();
	}
	
	public function dispose():void {
		bttn.removeEventListener(MouseEvent.CLICK, onClick);
		searchBttn.removeEventListener(MouseEvent.CLICK, searchEvent);
	}
}