package wins 
{
	import flash.display.Sprite;
	/**
	 * ...
	 * @author 
	 */
	public class PortBuyWindow extends Window
	{
		private var blockCont:Sprite = new Sprite();
		
		public var blocks:Vector.<Block> = new Vector.<Block>;
		
		public function PortBuyWindow(settings:Object = null) 
		{
			if (settings == null) {
				settings = new Object();
			}	
			
			settings['width']			= 770; 
			settings['height']			= 640;
			
			settings['content']			= [];//settings.target.dataUsers || [];//[{},{},{},{},{}];
			
			settings["hasPaginator"]    = true;
			settings["hasArrows"]       = true;
			settings['itemsOnPage']     = 4;
			
			settings['background']      = 'tradingPostBackingMain';
			
			settings['title']			= Locale.__e('flash:1382952379751');
			
			super(settings);
		}
		
		public function setContent():void {
			
			var count:int = 0;
			
			for (var _id:* in settings.target.dataUsers) {
				settings.target.dataUsers[_id]['sid'] = _id; 
				settings.target.dataUsers[_id]['idUser'] = _id;
				settings.content.push(settings.target.dataUsers[_id]);
				count++;
			}
			
			paginator.page = 0;
			paginator.itemsCount = count;
			paginator.update();
				
			contentChange();	
		}
		
		override public function drawBody():void 
		{
			titleLabel.y += 6;
			exit.y -= 20;
			
			paginator.y += 28;
			paginator.x -= 30;
			
			bodyContainer.addChild(blockCont);
			blockCont.x = 48;
			blockCont.y = 16;
			
			
			//drawMirrowObjs('drapery1', -20, settings.width + 20, -62);
			//drawMirrowObjs('diamondsTop', settings.width / 2 - settings.titleWidth / 2 - 5, settings.width / 2 + settings.titleWidth / 2 + 5, -34, true, true);
			
			setContent();
		}
		
		override public function drawArrows():void {
			super.drawArrows();
			
			paginator.arrowLeft.y -= 39;
			paginator.arrowRight.y -= 39;
			paginator.arrowLeft.x -= 10;
			paginator.arrowRight.x += 10;
		}
		
		override public function contentChange():void 
		{
			for each(var _block:Block in blocks) {
				blockCont.removeChild(_block);
				_block.dispose();
				_block = null;
			}
			
			blocks = new Vector.<Block>();
			
			var posX:int = 0;
			var posY:int = 0;
			
			var count:int = 0;
			for (var i:int = paginator.startCount; i < paginator.finishCount; i++ ) {
				
				if (settings.content[i] == null)
					continue;
				
				var block:Block = new Block(this, settings.content[i]);
				
				block.x = posX;
				block.y = posY;
				
				blocks.push(block);
				
				posX += block.width + 8;
				
				if (count == settings.itemsOnPage/2 - 1) {
					posX = 0;
					posY += block.height + 8;
				}
				
				count++;
				blockCont.addChild(block);
			}
		}
		
	}

}
import buttons.Button;
import core.AvaLoad;
import core.Load;
import core.Post;
import flash.display.Bitmap;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.text.TextField;
import ui.UserInterface;
import wins.PortBuyWindow;
import wins.Window;


internal class Block extends Sprite {
	
	public var window:PortBuyWindow;
	public var settings:Object;
	
	private var bg:Bitmap;
	
	private var numItems:int = 3;
	
	public var items:Vector.<Material> = new Vector.<Material>;
	
	private var sprite:Sprite = new Sprite();
	private var avatar:Bitmap = new Bitmap();
	
	private var preloader:Preloader = new Preloader();
	
	public function Block(window:PortBuyWindow, settings:Object):void {
		this.settings = settings;
		this.window = window;
		
		bg = Window.backing(334, 254, 40, 'itemBacking');
		addChild(bg);
		
		drawAva();
		
		preloader.x = bg.width / 4 + 3;
		preloader.y = bg.height / 4 + 3;
		addChild(preloader);
	
		createItems();
		
		new AvaLoad(settings.photo, onLoad, onErrLoad);
	}
	
	private function drawAva():void 
	{
		var shape:Shape = new Shape();
		shape.graphics.beginFill(0xc78b1e, 1);
		shape.graphics.drawRoundRect(0, 0, 80, 80, 12, 12);
		shape.graphics.endFill();
		addChild(shape);
		
		shape.x = bg.width/4 - 38;
		shape.y = bg.height/3 - 48;
		
		addChild(sprite);
		
		sprite.addChild(avatar);
		
		var nameTxt:TextField =  Window.drawText(settings.aka, {
				color:0xffffff,
				fontSize:20,
				borderColor:0x814f31,
				autoSize:"center",
				textAlign:"center"
			}
		);
		nameTxt.wordWrap = true;
		nameTxt.width = 90;
		nameTxt.x = shape.x + shape.width/2 - nameTxt.width/2;
		nameTxt.y = shape.y - 14;
		addChild(nameTxt);
		
		var star:Bitmap = new Bitmap(Window.textures.star);
		star.scaleX = star.scaleY = 0.8;
		star.smoothing = true;
		star.x = shape.x + shape.width - star.width / 2 - 7;
		star.y = shape.y + shape.height - star.height / 2 - 5;
		addChild(star);
		
		
		var lvlTxt:TextField =  Window.drawText(settings.level, {
				color:0xffffff,
				fontSize:16,
				borderColor:0x814f31,
				autoSize:"center",
				textAlign:"center"
			}
		);
		lvlTxt.width = 90;
		lvlTxt.x = star.x +(star.width - lvlTxt.width) / 2;
		lvlTxt.y = star.y +(star.height - lvlTxt.textHeight) / 2;
		addChild(lvlTxt);
	}
	
	private function onErrLoad():void {
		removeChild(preloader);
		var noImageBcng:Bitmap = new Bitmap(UserInterface.textures.friendsBacking);
		drawPic(noImageBcng,true);
	}
	
	private function onLoad(data:*):void {
		removeChild(preloader);
		
		drawPic(data);
	}
	
	public function drawPic(data:*,noImage:* = null):void {
		avatar.bitmapData = data.bitmapData;
		avatar.smoothing = true;
		
		//var bgAva:
		
		var shape:Shape = new Shape();
		shape.graphics.beginFill(0x000000, 1);
		var wd:uint = 50;
		var ht:uint = 50;
		if (noImage) {
			wd = 65;
			ht = 65;
		}
		shape.graphics.drawRoundRect(0, 0, wd, ht, 12, 12);
		shape.graphics.endFill();
		sprite.mask = shape;
		sprite.addChild(shape);
		
		var scale:Number = 1.5;
		
		sprite.width *= scale;
		sprite.height *= scale;
		
		sprite.x = bg.width / 4 - sprite.width / 2 + 2;		
		sprite.y = bg.height / 3 - sprite.height / 2 - 8;
		if (noImage) {
			sprite.x += 2;
			sprite.y += 2;
		}
		
	}
	
	public function createItems():void 
	{
		for (var j:int = 0; j < items.length; j++ ) {
			removeChild(items[j]);
			items[j].dispose();
			items[j] = null;
		}
		items = new Vector.<Material>;
		
		var posX:int = 171;
		var posY:int = 14;
		
		for (var i:int = 0; i < numItems; i++ ) {
			
			var item:Material = new Material(this, settings.items[i] );//slots
			
			items.push(item);
			
			item.x = posX;
			item.y = posY;
			
			posX += item.bg.width + 8;
			
			if (i == 0) {
				posX = 18;
				posY += item.height;
			}
			
			addChild(item);
		}
	}
	
	public function dispose():void
	{
		
	}
}

import wins.ErrorWindow;

internal class Material extends Sprite {
	
	public var window:Block;
	public var settings:Object;
	
	public var bg:Bitmap;
	
	private var bttnBuy:Button;
	
	private var preloader:Preloader = new Preloader();
	
	private var icon:Bitmap;
	
	private var container:LayerX = new LayerX();
	
	public function Material(window:Block, settings:Object):void {
		this.settings = settings;
		this.window = window;
		
		bg = Window.backing(146, 112, 10, 'shopBackingSmall2');
		addChild(bg);
		//bg.graphics.beginFill(0xd7cda2);
		//bg.graphics.drawRoundRect(0,0,146,108, 28, 28);
		//bg.graphics.endFill();
		
		if (settings == null) {
			drawEmpty();
			return;
		}else if (settings.sold) {
			drawBought();
		}else {
			drawBttn();
		}
		
		var item:Object = App.data.storage[settings.sid];
		
		addChild(container);
		container.tip = function():Object { 
				
				return {
					title:item.title,
					text:item.description
				};
			};
		
		icon = new Bitmap();
		container.addChild(icon);
		
		addChild(preloader);
		preloader.x = bg.width / 4;
		preloader.y = bg.height / 2 - 6;
		
		drawInfo();
			
		Load.loading(Config.getIcon(item.type, item.preview), onLoad);
	}
	
	private function onLoad(data:*):void 
	{
		if(contains(preloader)){
			removeChild(preloader);
		}
		
		icon.bitmapData = data.bitmapData;
		icon.scaleX = icon.scaleY = 0.6;
		icon.smoothing = true;
		container.x = bg.width/4 - container.width / 2 + 3;								
		container.y = (bg.height - container.height) / 2 - 16;
	}
	
	private function drawInfo():void 
	{
		var countTxt:TextField =  Window.drawText("x" + String(settings.count), {
				color:0xfcfad9,
				fontSize:24,
				borderColor:0x764a3e,
				autoSize:"right",
				textAlign:"right"
			}
		);
		countTxt.width = 200;
		countTxt.x = bg.width - countTxt.width - 18;
		countTxt.y = 14;
		addChild(countTxt);
		
		var coin:Bitmap = new Bitmap(UserInterface.textures.coinsIcon);
		coin.scaleX = coin.scaleY = 0.7;
		coin.smoothing = true;
		addChild(coin);
		
		var priceTxt:TextField =  Window.drawText(String(settings.price), {
				color:0xfedb38,
				fontSize:30,
				borderColor:0x6d4b15,
				autoSize:"right",
				textAlign:"right"
			}
		);
		priceTxt.width = 200;
		priceTxt.x = bg.width - priceTxt.width - 14;
		priceTxt.y = countTxt.y + countTxt.height + 1;
		addChild(priceTxt);
		
		coin.x = priceTxt.x - coin.width + 4;
		coin.y = priceTxt.y + (priceTxt.textHeight - coin.height) / 2;
	}
	
	private function drawEmpty():void 
	{
		var descTxt:TextField =  Window.drawText(Locale.__e("flash:1407829337190"), {
				color:0xfff0d5,
				fontSize:30,
				borderColor:0x2b3b64,
				borderSize:0,
				autoSize:"center",
				textAlign:"center"
			}
		);
		descTxt.wordWrap = true;
		descTxt.width = bg.width - 16;
		descTxt.x = (bg.width - descTxt.width) / 2;
		descTxt.y = (bg.height - descTxt.height) / 2;
		addChild(descTxt);
	}
	
	private function drawBought():void 
	{
		var descTxt:TextField =  Window.drawText(Locale.__e("flash:1396612413334"), {
				color:0x41332b,
				fontSize:26,
				borderColor:0xffffff,
				autoSize:"center",
				textAlign:"center"
			}
		);
		descTxt.wordWrap = true;
		descTxt.width = bg.width - 16;
		descTxt.x = (bg.width - descTxt.width) / 2;
		descTxt.y = bg.height - descTxt.height - 1;
		addChild(descTxt);
	}
	
	private function drawBttn():void 
	{
		bttnBuy = new Button( {
			caption:	Locale.__e("flash:1382952379751"),
			width:		100,
			height:		38,
			fontSize:	26
		});
		
		bttnBuy.x = (bg.width - bttnBuy.width) / 2;
		bttnBuy.y = bg.height - bttnBuy.height + 4;
		
		addChild(bttnBuy);
		
		bttnBuy.addEventListener(MouseEvent.CLICK, onBuy);
	}
	
	private function onBuy(e:MouseEvent):void 
	{
		if (bttnBuy.mode == Button.DISABLED)
			return;
			
		if(!App.user.stock.check(settings.pid, settings.price))return
		
		bttnBuy.state = Button.DISABLED;
		
		Post.send({
			ctr:window.window.settings.target.type,
			act:'pbuy',
			uID:App.user.id,
			wID:App.user.worldID,
			sID:window.window.settings.target.sid,
			iID:settings.idslot,
			tID:window.settings.idUser
		}, onBuyEvent);			
	}
	
	private function onBuyEvent(error:int, data:Object, params:Object):void 
	{
		if (error)
		{
			Errors.show(error, data);
			return;
		}
		
		if (data.error) {
			window.window.settings.target.canUpdate = true;
			
			//окно, типa материал уже купили, извините
			var winSettings:Object = {
				title				:Locale.__e('flash:1401784528880'),
				text				:Locale.__e('flash:1401784585729'),
				buttonText			:Locale.__e('flash:1382952380298'),
				image				:UserInterface.textures.alert_storage,
				imageX				:-78,
				imageY				: -76,
				textPaddingY        : -18,
				textPaddingX        : -10,
				hasExit             :true,
				faderAsClose        :true,
				faderClickable      :true,
				closeAfterOk        :true,
				bttnPaddingY        :25
			};
			new ErrorWindow(winSettings).show();
			
			updateWindow();
			return;
		}
		
		updateWindow();
		
		App.user.stock.take(settings.pid, settings.price);
		
		var bonusData:Object = { };
		bonusData[data.slot.sid] = data.slot.count;
		
		Treasures.bonus(Treasures.convert(bonusData), new Point(window.window.settings.target.x, window.window.settings.target.y));
	}
	
	private function updateWindow():void
	{
		window.settings.items[settings.idslot]['sold'] = 1;
		window.createItems();
	}
	
	public function dispose():void
	{
		if (container && container.parent) {
			container.parent.removeChild(container);
			container = null;
		}
		icon = null;
		bg = null;
		
		if (bttnBuy) {
			bttnBuy.removeEventListener(MouseEvent.CLICK, onBuy);
			bttnBuy.dispose();
			bttnBuy = null;
		}
	}
}