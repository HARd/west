package wins.actions 
{
	import buttons.Button;
	import buttons.MoneyButton;
	import core.Load;
	import core.Post;
	import core.Post;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import wins.elements.TimerUnit;
	import wins.AddWindow;
	import wins.SimpleWindow;
	import wins.Window;
	import wins.Paginator;
	
	public class BuffetActionWindow extends AddWindow 
	{
		private var preloader:Preloader = new Preloader();
		public var choosenElements:Array;
		
		public function BuffetActionWindow(settings:Object=null) 
		{
			if (settings == null) {
				settings = new Object();
			}
			
			settings['width'] = 700;
			settings['height'] = 640;
			settings['shadowSize'] = 3;
			settings['shadowBorderColor'] = 0x554234;
			settings['shadowColor'] = 0x554234;
			
			settings['title'] = Locale.__e("flash:1382952380262");
			settings['hasPaginator'] = true;
			settings['itemsOnPage'] = 4;
			settings['hasButtons'] = false;
			settings['promoPanel'] = false;
			
			action = App.data.actions[settings.pID];
			
			settings['content'] = [];
			for (var sID:String in App.data.actions[settings.pID].items) {
				settings.content.push({sID:sID, count:App.data.actions[settings.pID].items[sID]});
			}
			
			choosenElements = [];
			
			super(settings);
		}
		
		override public function drawBackground():void 
		{
			background = backing2(settings.width, settings.height, 190, 'shopBackingTop', 'shopBackingBot');
			layer.addChild(background);
			
			var back2:Bitmap = backing2(settings.width, settings.height / 2 + 60, 190, 'shopBackingTop', 'backingBot');
			layer.addChild(back2);
		}
		
		override public function drawBody():void {
			var preview:String = App.data.personages[1].preview;	
			var character:Bitmap = new Bitmap();			
			bodyContainer.addChild(preloader);
			
			Load.loading(Config.getImageIcon('quests/preview', preview), function(data:*):void { 
				if (bodyContainer.contains(preloader))
					bodyContainer.removeChild(preloader);
				
				character.bitmapData = data.bitmapData;	
				character.scaleX = character.scaleY = 0.9;
				character.x = -140;
				character.y = 25;
				bodyContainer.addChildAt(character,0);
			});
			
			drawTime();
			var priceBttn:Object = {
				caption			:Locale.__e("flash:1463146430236"),
				radius      	:10,
				fontColor:		0xffffff,
				fontBorderColor:0x508010,
				width			:210,
				height			:48,
				fontSize		:28,
				countText		:action.price[App.social],
				x:(settings.width - 210) / 2,
				y:297,
				callback:buyEvent,
				addBtnContainer:false,
				addLogo:false
			};
			drawButton(priceBttn);
			
			var bg1:Bitmap = Window.backing(500, 60, 50, 'fadeOutWhite');
			bg1.alpha = 0.4;
			bg1.x = (settings.width - bg1.width) / 2;
			bg1.y = 15;
			bodyContainer.addChild(bg1);
			
			var text1:TextField = drawText(Locale.__e('flash:1463144656150'), {
				textAlign:'center',
				fontSize:25,
				color:0xececec,
				borderColor:0x634604,
				multiline:true,
				autoSize: 'center'
			});
			text1.wordWrap = true;
			text1.width = 370;
			text1.x = (settings.width - text1.width) / 2;
			text1.y = 17;
			bodyContainer.addChild(text1);
			
			var bg2:Bitmap = Window.backing(200, 27, 50, 'fadeOutYellow');
			bg2.alpha = 0.6;
			bg2.x = (settings.width - bg2.width) / 2;
			bg2.y = 80;
			bodyContainer.addChild(bg2);
			
			var text2:TextField = drawText(Locale.__e('flash:1463145859882'), {
				width:settings.width,
				textAlign:'center',
				fontSize:28,
				color:0xfee759,
				borderColor:0x6a3900
			});
			text2.y = 76;
			bodyContainer.addChild(text2);
			
			var bg3:Bitmap = Window.backing(500, 27, 50, 'fadeOutWhite');
			bg3.alpha = 0.4;
			bg3.x = (settings.width - bg3.width) / 2;
			bg3.y = 345;
			bodyContainer.addChild(bg3);
			
			var text3:TextField = drawText(Locale.__e('flash:1463143167206'), {
				width:settings.width,
				textAlign:'center',
				fontSize:24,
				color:0xececec,
				borderColor:0x634604
			});
			text3.y = 343;
			bodyContainer.addChild(text3);			
			
			if (settings.content.length != 0) {
				paginator.itemsCount = settings.content.length;
				paginator.update();
				paginator.onPageCount = 4;
			}
			
			contentChange();			
			drawChoosenElements();
		}
		
		public function drawTime():void 
		{
			var timer:TimerUnit = new TimerUnit( {backGround:'glow',width:140,height:60,time: { started:action.begin_time, duration:action.duration }} );
			timer.start();
			timer.x += 15;
			timer.y -= 15;
			bodyContainer.addChild(timer);
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
			var X:int = 0;
			var Xs:int = X;
			var Ys:int = 375;
			itemsContainer.x = 55;
			itemsContainer.y = Ys;
			if (settings.content.length < 1) return;
			for (var i:int = paginator.startCount; i < paginator.finishCount; i++)
			{
				var item:MaterialItem = new MaterialItem(this, { sID:settings.content[i].sID, count:settings.content[i].count } );
				item.x = Xs;
				items.push(item);
				itemsContainer.addChild(item);
				
				Xs += item.bg.width + 10;
			}
		}
		
		override public function drawArrows():void {
			paginator.drawArrow(bodyContainer, Paginator.LEFT,  0, 0, { scaleX: -1, scaleY:1 } );
			paginator.drawArrow(bodyContainer, Paginator.RIGHT, 0, 0, { scaleX:1, scaleY:1 } );
			
			var y:Number = (settings.height - paginator.arrowLeft.height) / 2 + settings.height / 4;
			paginator.arrowLeft.x = 50 - paginator.arrowLeft.width;
			paginator.arrowLeft.y = y - 27;
			
			paginator.arrowRight.x = settings.width - 50;
			paginator.arrowRight.y = y - 27;
			
			paginator.x = (settings.width - paginator.width) / 2 - 30;
			paginator.y = settings.height - 30;
		}
		
		public function addElement(sid:int, count:int):void {
			if (choosenElements.length < 3) {
				choosenElements.push({sID:sid, count:count});
				
				drawChoosenElements();
			}
		}
		
		public function removeElement(sid:int, count:int):void {
			var bufArray:Array = [];
			for each (var element:Object in choosenElements) {
				if (element.sID == sid && element.count == count) continue;
				bufArray.push(element);
			}
			
			choosenElements = bufArray;
			
			drawChoosenElements();
			contentChange();
		}
		
		private var itemsChoose:Array;
		private var itemsChooseContainer:Sprite = new Sprite();
		public function drawChoosenElements():void {
			if (itemsChoose) {
				for each(var _item:* in itemsChoose) {
					itemsChooseContainer.removeChild(_item);
					_item.dispose();
				}
			}
			itemsChoose = [];
			
			bodyContainer.addChild(itemsChooseContainer);
			var X:int = 0;
			var Xs:int = X;
			var Ys:int = 110;
			for (var i:int = 0; i < 3; i++)
			{
				var item:MaterialItem;
				if (choosenElements[i]) item = new MaterialItem(this, { sID:choosenElements[i].sID, count:choosenElements[i].count, choose:true } );
				else item = new MaterialItem(this, { sID:null, count:0, choose:true } );
				item.x = Xs;
				itemsChoose.push(item);
				itemsChooseContainer.addChild(item);
				
				Xs += item.bg.width + 10;
			}
			
			itemsChooseContainer.x = (settings.width - itemsChooseContainer.width) / 2;
			itemsChooseContainer.y = Ys;
		}
		
		override protected function buyEvent(e:MouseEvent):void
		{
			if (e.currentTarget.mode == Button.DISABLED) return;
			
			if (!choosenElements || choosenElements.length < 3) {
				priceBttn.state = Button.NORMAL;
				
				new SimpleWindow( {
					label:SimpleWindow.ATTENTION,
					title:Locale.__e("flash:1382952379893"),
					text:Locale.__e("flash:1463384854268"),
					popup:true
				}).show();
				return;
			}
			
			if (!App.user.stock.take(Stock.FANT, action.price[App.social])) return;
			priceBttn.state = Button.DISABLED;
			
			var citems:Array = [];
			for each (var item:Object in choosenElements) {
				citems.push(item.sID);
			}
			
			Post.send( {
				ctr:'Stock',
				act:'offer',
				aID:action.pID,
				uID:App.user.id,
				items:JSON.stringify(citems)
			}, onBuyComplete);
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
import buttons.ImageButton;
import core.Load;
import core.Size;
import flash.display.Bitmap;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.text.TextField;
import ui.UserInterface;
import wins.Window;

internal class MaterialItem extends LayerX
{
	public var window:*;
	public var item:Object;
	public var count:int;
	public var bg:Bitmap;
	private var bitmap:Bitmap;
	public var sID:uint;
	public var bttn:Button;
	public var bttnDelete:ImageButton;
	public var itemForChoose:Boolean = false;
	
	public function MaterialItem(window:*, data:Object)
	{
		this.sID = data.sID;
		this.item = App.data.storage[sID];
		this.window = window;
		this.count = data.count;
		if (data.hasOwnProperty('choose')) this.itemForChoose = data.choose;
		
		if (itemForChoose) bg = Window.backing(150, 180, 50, 'itemBacking');
		else bg = Window.backing(140, 170, 50, 'itemBacking');
		addChild(bg);
		
		if (!sID) return;
		
		Load.loading(Config.getIcon(item.type, item.preview), onLoad);
		
		drawTitle();		
		if (itemForChoose) {
			drawCount();
			drawPrice();
			drawDelete();
		} else {
			drawBttn();
		}
		
		tip = function():Object {
			return {
				title:item.title,
				text:item.description
			}
		}
	}
	
	private function onClick(e:MouseEvent):void 
	{
		if (e.currentTarget.mode == Button.DISABLED) return;
		e.currentTarget.state = Button.DISABLED;
		window.addElement(sID, count);
	}
	private function onDelete(e:MouseEvent):void 
	{
		if (e.currentTarget.mode == Button.DISABLED) return;
		window.removeElement(sID, count);
	}
	
	private function onLoad(data:Bitmap):void {
		bitmap = new Bitmap(data.bitmapData);
		Size.size(bitmap, 120, 120);
		addChildAt(bitmap, 1);
		bitmap.x = (bg.width - bitmap.width) / 2;
		bitmap.y = (bg.height - bitmap.height) / 2;
		bitmap.smoothing = true;
		
		if (itemForChoose) {
			bitmap.y -= 10;
		}
	}
	
	private function drawTitle():void {
		var titleText:TextField = Window.drawText(App.data.storage[sID].title, {
			width:bg.width,
			textAlign:'center',
			fontSize:24,
			color:0x7b3e07,
			borderColor:0xffffff
		});
		titleText.y = 5;
		addChild(titleText);
	}
	
	private function drawBttn():void 
	{
		var bttnSettings:Object = {
			caption:Locale.__e("flash:1463135500963"),
			width:113,
			height:40,
			fontSize:26
		}
		
		bttn = new Button(bttnSettings);
		
		addChild(bttn);
		bttn.x = (bg.width - bttn.width) / 2;
		bttn.y = bg.height - 25;
		bttn.addEventListener(MouseEvent.CLICK, onClick);
		
		for each (var element:Object in window.choosenElements) {
			if (element.sID == sID) {
				bttn.state = Button.DISABLED;
			}
		}
	}
	
	public function drawCount():void {
		var sprite:Sprite = new Sprite();
		
		var textCount:TextField = Window.drawText('x' + String(count), {
			color:0x7b3e07,
			fontSize:30,
			borderColor:0xffffff
		});
		textCount.width = textCount.textWidth + 10;
		sprite.addChild(textCount);
		
		sprite.x = bg.width - sprite.width - 10;
		sprite.y = bg.y + bg.height - 65;
		addChild(sprite);
	}
	
	public function drawPrice():void {
		var textContainer:Sprite = new Sprite();
			var icon:Bitmap = new Bitmap(UserInterface.textures.fantsIcon);
			textContainer.addChild(icon);
			icon.scaleX = icon.scaleY = 0.8;
			icon.smoothing = true;			
			
			var oldPriceText:TextField = Window.drawText(String(App.data.storage[sID].price[Stock.FANT] * count),{
				fontSize	:24,
				color		:0xffffff,
				borderColor	:0x6d4200,
				autoSize	:"center"
			});
			textContainer.addChild(oldPriceText);
			oldPriceText.x = icon.x + icon.width + 4;
			oldPriceText.y = icon.y + (icon.height - oldPriceText.height) / 2 + 4;
			
			addChild(textContainer);
			
			var line:Shape = new Shape();
			line.graphics.lineStyle(4, 0xe31103, 0.75);
			line.graphics.beginFill(0x00FF00);
			line.graphics.moveTo(oldPriceText.x, oldPriceText.y + oldPriceText.height); 
			line.graphics.lineTo(oldPriceText.x + oldPriceText.width, oldPriceText.y);
			textContainer.addChild(line);
			
			textContainer.x = (bg.width - textContainer.width) / 2;
			textContainer.y = bg.y + bg.height - textContainer.height - 5;
	}
	
	private function drawDelete():void {
		bttnDelete = new ImageButton(UserInterface.textures.iconStop);
		bttnDelete.x = bg.width - bttnDelete.width;
		addChild(bttnDelete);
		
		bttnDelete.addEventListener(MouseEvent.CLICK, onDelete);
	}
	
	public function dispose():void {
		if (bttn) bttn.removeEventListener(MouseEvent.CLICK, onClick);
		if (bttnDelete) bttnDelete.removeEventListener(MouseEvent.CLICK, onDelete);
	}
}

