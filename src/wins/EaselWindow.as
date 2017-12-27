package wins 
{
	import buttons.Button;
	import com.greensock.TweenMax;
	import core.Load;
	import core.Numbers;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.text.TextField;
	
	public class EaselWindow extends Window 
	{
		public var sid:int = 0;
		public var info:Object = { };		
		public var picture:Bitmap;
		
		private var progressBar:ProgressBar;
		private var progressBacking:Bitmap;
		private var progressTitle:TextField;
		private var subTitle:TextField;
		
		public var counter:int = 0;
		
		private var posArr:Array = [ {x:75, y:37}, {x:129, y:37}, {x:443, y:37}, {x:75, y:273}, {x:292, y:150}, {x:518, y:133}  ]
		
		public function EaselWindow(settings:Object=null) 
		{
			if (!settings) settings = { };
			
			settings['width'] = settings['width'] || 800;
			settings['height'] = settings['height'] || 685;
			settings['title'] = settings.target.info.title;
			settings['hasPaginator'] = false;
			settings['background'] = 'alertBacking';
			
			sid = settings.target.sid;
			info = App.data.storage[sid];
			
			settings['content'] = [];
			for (var sID:* in info.kicks) {
				var obj:Object = { sID:sID, count:info.kicks[sID].c };
				if (info.kicks[sID].hasOwnProperty('t')) {
					obj['t'] = info.kicks[sID].t;
				}
				if (info.kicks[sID].hasOwnProperty('o')) {
					obj['o'] = info.kicks[sID].o;
				}
				if (info.kicks[sID].hasOwnProperty('k')) {
					obj['k'] = info.kicks[sID].k;
				}
				settings['content'].push(obj);
			}
				
			settings['content'].sortOn('o', Array.NUMERIC);
			
			super(settings);
			
			App.self.setOnTimer(checkParts);
			App.self.addEventListener(AppEvent.ON_CHANGE_STOCK, onStockChange);
		}
		
		private function checkParts():void {
			if (counter == 6) {
				App.self.setOffTimer(checkParts);
				
				picture.visible = true;
			}
		}
		
		override public function drawBody():void {
			titleLabel.y += 15;
			
			drawPicture();
			drawPuzzles();
			
			var separator:Bitmap = Window.backingShort(settings.width - 150, 'dividerLine', false);
			separator.scaleY = -1;
			separator.x = (settings.width - separator.width) / 2;
			separator.y = 430;
			separator.alpha = 0.5;			
			
			var separator2:Bitmap = Window.backingShort(settings.width - 150, 'dividerLine', false);
			separator2.scaleY = -1;
			separator2.x = (settings.width - separator2.width) / 2;
			separator2.y = 470;
			separator2.alpha = 0.5;
			
			var bg:Bitmap = Window.backing(settings.width - 150, 40, 50, 'fadeOutWhite');
			bg.x =(settings.width - bg.width) / 2;
			bg.y = 430;
			bg.alpha = 0.3;
			bodyContainer.addChild(bg);
			
			bodyContainer.addChild(separator);
			bodyContainer.addChild(separator2);
			
			var desc:TextField = drawText(Locale.__e('flash:1444639525016'), {
				color:		0x642a05,
				fontSize:	22,
				border:		false,
				textAlign:	'center',
				autoSize:	"left"
			});
			desc.x = (settings.width - desc.textWidth) / 2;
			desc.y = 435;
			bodyContainer.addChild(desc);
			
			drawKicks();
			
			progressBacking = Window.backingShort(290, "progBarBacking");
			progressBacking.x = itemsContainer.x + itemsContainer.width + 10;
			progressBacking.y = 565;
			bodyContainer.addChild(progressBacking);
			
			progressBar = new ProgressBar({win:this, width:306, isTimer:false});
			progressBar.x = progressBacking.x - 8;
			progressBar.y = progressBacking.y - 4;
			bodyContainer.addChild(progressBar);
			progressBar.progress = settings.target.kicks / settings.target.kicksNeed;
			progressBar.start();
			
			progressTitle = drawText(progressData, {
				fontSize:32,
				autoSize:"left",
				textAlign:"center",
				color:0xffffff,
				borderColor:0x6b340c,
				shadowColor:0x6b340c,
				shadowSize:1
			});
			progressTitle.x = progressBacking.x + progressBacking.width / 2 - progressTitle.width / 2;
			progressTitle.y = progressBacking.y - 2;
			progressTitle.width = 80;
			bodyContainer.addChild(progressTitle);
			
			var fillText:TextField = drawText(Locale.__e('flash:1444643530642'), {
				color:		0x763a15,
				fontSize:	22,
				borderColor:0xffffff,
				textAlign:	'center',
				autoSize:	"left"
			});
			fillText.x = progressBacking.x + (progressBacking.width - fillText.textWidth) / 2;
			fillText.y = progressBacking.y - 30;
			bodyContainer.addChild(fillText);
			
			subTitle = Window.drawText(String(settings.target.upgrade) + "/" + settings.target.totalTowerLevels, {
				fontSize:32,
				color:0xfbdb24,
				autoSize:"left",
				borderColor:0x75420b
			});
			subTitle.x = progressBacking.x + (progressBacking.width - subTitle.textWidth) / 2;
			subTitle.y = fillText.y - 35;
			bodyContainer.addChild(subTitle);
			
			var partsText:TextField = drawText(Locale.__e('flash:1444644115882'), {
				color:		0x763a15,
				fontSize:	22,
				borderColor:0xffffff,
				textAlign:	'center',
				autoSize:	"left"
			});
			partsText.x = progressBacking.x + (progressBacking.width - partsText.textWidth) / 2;
			partsText.y = subTitle.y - 25;
			bodyContainer.addChild(partsText);
			
			if (settings.target.kicks >= settings.target.kicksMax)
				blockItems(true);
			
			if (settings.target.totalTowerLevels > settings.target.upgrade && settings.target.kicks >= settings.target.kicksNeed)
				settings.target.growAction(onUpgradeComplete);
		}
		
		public function get progressData():String {
			return String(settings.target.kicks) + ' / ' + String(settings.target.kicksNeed);
		}
		
		private function progress():void {
			if (progressBar && info.tower.hasOwnProperty(settings.target.upgrade + 1)) {
				progressBar.progress = settings.target.kicks / settings.target.kicksNeed;
				if (settings.target.kicks > settings.target.kicksNeed) {
					settings.target.kicks = settings.target.kicksNeed;
				}
				progressTitle.text = String(settings.target.kicks) + ' / ' + String(settings.target.kicksNeed);
			}
		}
		
		private function drawPicture():void {
			picture = new Bitmap();
			bodyContainer.addChild(picture);
			picture.visible = false;
			
			Load.loading(Config.getImage('paintings', info.image, 'jpg'), function (data:*):void {
				picture.bitmapData = data.bitmapData;
				
				picture.x = (settings.width - picture.width) / 2;
				picture.y = 35;
			});
		}
		
		private var backItems:Array;
		private function drawPuzzles():void {
			for each (var itm:PuzzleItem in backItems)
			{
				if (itm.parent)
					itm.parent.removeChild(itm);
				itm.dispose();
				itm = null;
			}
			backItems = [];
			
			for (var i:int = 0; i < 6; i++)
			{
				var item:PuzzleItem = new PuzzleItem({id: i, pos: posArr[i]}, this)
				backItems.push(item);
				bodyContainer.addChild(item);
				
				if (i < settings.target.upgrade)
					item.visible = false;
			}
		}
		
		private var items:Vector.<KickItem> = new Vector.<KickItem>;
		public var itemsContainer:Sprite = new Sprite();
		public function drawKicks():void {
			clearKicks();
			var rewards:Array = [];
			for (var s:String in info.kicks) {
				var object:Object = info.kicks[s];
				object['id'] = s;
				rewards.push(object);
			}
			
			rewards.sortOn('o', Array.NUMERIC);
			
			bodyContainer.addChild(itemsContainer);
			itemsContainer.y = 455;
			var X:int = 0;
			var Xs:int = X;
			for (var i:int = 0; i < rewards.length; i++) {
				var item:KickItem = new KickItem(rewards[i], this);
				item.x = Xs;
				itemsContainer.addChild(item);
				items.push(item);
				
				Xs += item.bg.width + 15;
			}
			
			itemsContainer.x = 75;
		}
		
		private function clearKicks():void {
			while (items.length > 0) {
				var item:KickItem = items.shift();
				itemsContainer.removeChild(item);
				item.dispose();
			}
		}
		
		private function onStockChange(e:AppEvent):void 
		{
			drawKicks();
		}
		
		public function blockItems(value:Boolean = true):void {
			for (var i:int = 0; i < items.length; i++) {
				if (value) {
					items[i].bttn.state = Button.DISABLED;
				}else {
					items[i].checkButtonsStatus();
				}
			}
		}
		
		public function onUpgradeComplete(bonus:Object = null):void {
			if (bonus && Numbers.countProps(bonus) > 0) {
				App.user.stock.addAll(bonus);
			}
			
			kick();
			TweenMax.to(backItems[settings.target.upgrade - 1], 3, { alpha:0} );
			blockItems(false);
		}
		
		public function kick():void {
			progress();
			App.ui.upPanel.update();
			
			subTitle.text = String(settings.target.upgrade) + "/" + settings.target.totalTowerLevels;
			
			if (settings.target.canUpgrade) {
				blockItems(true);
			}else {
				blockItems(false);
			}
		}
		
		override public function dispose():void {
			clearKicks();
			App.self.setOffTimer(checkParts);
			super.dispose();
		}
		
	}

}
import buttons.Button;
import buttons.MoneyButton;
import com.greensock.TweenMax;
import core.Load;
import core.Numbers;
import core.Size;
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.text.TextField;
import ui.Hints;
import wins.actions.BanksWindow;
import wins.ShopWindow;
import wins.Window;
internal class KickItem extends LayerX{
	
	public var window:*;
	public var item:Object;
	public var bg:Sprite;
	private var bitmap:Bitmap;
	private var sID:uint;
	public var bttn:Button;
	private var count:uint;
	private var nodeID:String;
	private var type:uint;
	private var k:uint;
	
	public function KickItem(obj:Object, window:*) {
		
		this.sID = obj.id;
		this.count = obj.c;
		this.nodeID = obj.id;
		this.k = obj.k;
		this.item = App.data.storage[sID];
		this.window = window;
		type = obj.t;
		
		bg = new Sprite();
		bg.graphics.beginFill(0xcbd4cf);
		bg.graphics.drawCircle(55, 100, 55);
		bg.graphics.endFill();
		addChild(bg);
		
		bitmap = new Bitmap();
		addChild(bitmap);
		
		drawTitle();
		drawBttn();
		drawLabel();
		
		Load.loading(Config.getIcon(item.type, item.preview), onLoad);
		
		tip = function():Object {
			return {
				title: item.title,
				text: item.description
			}
		}
	}
	private var icon:Bitmap;
	private function drawBttn():void {
		var bttnSettings:Object = {
			caption:Locale.__e("flash:1382952379978"),
			width:115,
			height:40,
			fontSize:22
		}
		
		if(item.real == 0 || type == 1){
			bttnSettings['borderColor'] = [0xaff1f9, 0x005387];
			bttnSettings['bgColor'] = [0x70c6fe, 0x765ad7];
			bttnSettings['fontColor'] = 0x453b5f;
			bttnSettings['fontBorderColor'] = 0xe3eff1;
			
			bttn = new Button(bttnSettings);
		}
		
		if (item.real || type == 2) {
			
			bttnSettings['bgColor'] = [0xa8f749, 0x74bc17];
			bttnSettings['borderColor'] = [0x5b7385, 0x5b7385];
			bttnSettings['bevelColor'] = [0xcefc97, 0x5f9c11];
			bttnSettings['fontColor'] = 0xffffff;			
			bttnSettings['fontBorderColor'] = 0x4d7d0e;
			bttnSettings['fontCountColor'] = 0xc7f78e;
			bttnSettings['fontCountBorder'] = 0x40680b;		
			bttnSettings['countText']	= item.price[Stock.FANT];
			
			bttn = new MoneyButton(bttnSettings);
		}
		
		if (type == 3) {
			bttn = new Button(bttnSettings);
		}
		
		addChild(bttn);
		bttn.x = (bg.width - bttn.width) / 2;
		bttn.y = bg.height + 30;
		bttn.addEventListener(MouseEvent.CLICK, onClick);
		
		checkButtonsStatus();
	}
	
	private function onLoadIcon(data:Bitmap):void {
		icon.bitmapData = data.bitmapData;		
		icon.scaleX = icon.scaleY = 0.35;
		icon.x = 20;
		icon.y = 4;
		icon.smoothing = true;
	}
	
	
	public function checkButtonsStatus():void {
		if (type == 2) {
			bttn.state = Button.NORMAL;
		}else if (type == 3) {
			if (App.user.stock.count(sID) < price) {
				bttn.state = Button.DISABLED;
			}else {
				bttn.state = Button.NORMAL;
			}
		}
	}
	
	private function onClick(e:MouseEvent):void {
		if (e.currentTarget.mode == Button.DISABLED) return;
		if (currency == Stock.FANT && App.user.stock.count(Stock.FANT) < price) {
			window.close();
			BanksWindow.history = {section:'Reals',page:0};
			new BanksWindow().show();
			return;
		}
		if (type == 3 && App.user.stock.count(sID) < 1 && ShopWindow.findMaterialSource(sID))  {
			window.close();
			return;
		}
		
		window.blockItems();
		window.settings.target.kickAction(sID, onKickEventComplete);
	}
	
	private function onKickEventComplete(bonus:Object = null):void {
		App.user.stock.take(currency, price);
		
		var X:Number = App.self.mouseX - bttn.mouseX + bttn.width / 2;
		var Y:Number = App.self.mouseY - bttn.mouseY;
		Hints.minus(currency, price, new Point(X, Y), false, App.self.tipsContainer);
		
		/*if (Numbers.countProps(bonus) > 0) {
			BonusItem.takeRewards(bonus, bttn, 20);
			App.user.stock.addAll(bonus);
		}*/
		
		if (bonus){
			flyBonus(bonus);
		}
		
		if (stockCount) stockCount.text = 'x' + App.user.stock.count(sID);
		window.kick();
		
		if (window.settings.target.kicks >= window.settings.target.kicksNeed) {
			window.settings.target.growAction(onUpgradeEvent);
		}
	}	
	
	public function onUpgradeEvent(bonus:Object = null):void {
		window.onUpgradeComplete();
		
		/*if (Numbers.countProps(bonus) > 0) {
			BonusItem.takeRewards(bonus, bttn, 20);
			App.user.stock.addAll(bonus);
		}*/
		
		if (bonus){
			flyBonus(bonus);
		}
	}
	
	private function flyBonus(data:Object):void {
		var targetPoint:Point = Window.localToGlobal(bttn);
			targetPoint.y += bttn.height / 2;
			for (var _sID:Object in data)
			{
				var sID:uint = Number(_sID);
				for (var _nominal:* in data[sID])
				{
					var nominal:uint = Number(_nominal);
					var count:uint = Number(data[sID][_nominal]);
				}
				
				var item:*;
				
				for (var i:int = 0; i < count; i++)
				{
					item = new BonusItem(sID, nominal);
					App.user.stock.add(sID, nominal);	
					
					item.cashMove(targetPoint, App.self.windowContainer)
				}			
			}
			SoundsManager.instance.playSFX('reward_1');
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
		
		bitmap = new Bitmap(data.bitmapData);
		Size.size(bitmap, 80, 80);
		sprite.x = (bg.width - bitmap.width) / 2;
		sprite.y = (bg.height - bitmap.height) / 2 + 35;
		sprite.addChild(bitmap);
		addChildAt(sprite, 1);
		bitmap.smoothing = true;
		
		sprite.addEventListener(MouseEvent.CLICK, searchEvent);
	}
	
	private function searchEvent(e:MouseEvent):void {
		ShopWindow.findMaterialSource(sID);
	}
	
	public function dispose():void {
		bttn.removeEventListener(MouseEvent.CLICK, onClick);
	}
	
	public function drawTitle():void {
		var title:TextField = Window.drawText(item.title + ' +' + k, {
			color:0x814f31,
			borderColor:0xffffff,
			textAlign:"center",
			autoSize:"center",
			fontSize:22,
			textLeading:-6,
			multiline:true,
			distShadow:0
		});
		title.wordWrap = true;
		title.width = bg.width - 5;
		title.height = title.textHeight;
		title.x = 5;
		title.y = 15;
		addChild(title);
	}
	
	private var stockCount:TextField;
	public function drawLabel():void 
	{
		var count:int = App.user.stock.count(sID);
		var countText:String = 'x' + String(count);
		if (count < 1) {
			countText = '';
		}
		if (stockCount) {
			removeChild(stockCount);
			stockCount = null;
		}
		stockCount = Window.drawText(countText, {
			color:0xffffff,
			fontSize:30,
			borderColor:0x7b3e07
		});
		stockCount.width = stockCount.textWidth + 10;
		stockCount.x = bg.x + bg.width - stockCount.width;
		stockCount.y = bg.y + bg.height - 10;
		
		if (type == 2)
			return;
		addChild(stockCount);
	}
	
	private function get price():int {
		if (type == 2) {
			for (var s:* in item.price) break;
			return item.price[s];
		}
		
		return 1;
	}
	private function get currency():int {
		if (type == 2) {
			for (var s:* in item.price) break;
			return int(s);
		}
		
		return sID;
	}

}

import buttons.Button;
import core.Load;
import flash.display.Bitmap;
import flash.display.Sprite;
import wins.Window;
import wins.ShopWindow;
import wins.SimpleWindow;

internal class PuzzleItem extends Sprite
{
	
	public var bg:Bitmap;
	public var item:Object;
	private var bitmap:Bitmap;
	private var buyBttn:Button;
	private var _parent:*;
	private var preloader:Preloader = new Preloader();
	
	public function PuzzleItem(item:Object, parent:*)
	{
		
		this._parent = parent;
		this.item = item;
		
		var sprite:LayerX = new LayerX();
		addChild(sprite);
		
		bitmap = new Bitmap();
		sprite.addChild(bitmap);
		
		addChild(preloader);
		preloader.x = item.pos.x;
		preloader.y = item.pos.y;
		preloader.scaleX = preloader.scaleY = 0.67;
		
		Load.loading(Config.getImage('paintings/parts', 'PaintPiece' + (item.id + 1)), function(data:*):void
		{
			if (preloader)
			{
				removeChild(preloader)
				preloader = null
			}
			
			bitmap.bitmapData = data.bitmapData;
			bitmap.smoothing = true;
			bitmap.x = item.pos.x;
			bitmap.y = item.pos.y;
			
			_parent.counter++;
		})	
	}
	
	public function dispose():void
	{
		if (bitmap && bitmap.parent)
			bitmap.parent.removeChild(bitmap);
		bitmap = null;
	
	}

}
