package wins.elements 
{
	import core.Numbers;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.text.TextField;
	import wins.ProductionWindow;
	
	/**
	 * ...
	 * @author ...
	 */
	public class ProductionQueue extends Sprite 
	{
		private var itemsContainer:Sprite;
		private var items:Object;
		private var queueItem:QueueItem;
		public var queueItemArr:Array = [];
		private var sid:int;
		private var id:int;
		private var type:String;
		private var settings:Object;
		public var openedSlots:int;
		private var craftingTime:Array = [];
		private var infoText:TextField;
		private var window:ProductionWindow;
		

		public function ProductionQueue(_items:Object,_settings:Object, _window:ProductionWindow) 
		{
			super();
			settings = _settings;
			window = _window;
			sid = settings.target.sid;
			id = settings.target.id;
			type = settings.target.type;
			items = _items;
			openedSlots = settings.target.openedSlots;
			
			for each (var item:* in items){
				craftingTime.push(App.data.crafting[item.fID].time);
			}
			
			drawItemQueue();
		}
		
		/**Функция обновляет графику*/
		public function update():void
		{
			if (itemsContainer != null) {
				for (var i:int = 0; i < queueItemArr.length; i++) 
				{
					queueItemArr[i].dispose();
					queueItemArr[i] = null;
				}
				queueItemArr = [];
				
				removeChild(itemsContainer);
				itemsContainer = null;
			}
			drawItemQueue();
		}
		
		public function addInfoBlock():void {
			window.addInfoBlock();
		}
		private var fid:int;
		/**Функция перебирает и добавляет элементы*/
		private function drawItemQueue():void 
		{
			itemsContainer = new Sprite();
			
			var itemX:int = 0;
			var itemY:int = 0;
			var itemDX:int = 110;
			for (var i:int = 0; i < Numbers.countProps(App.data.storage[sid].slots); i++) 
			{
				if (i < openedSlots) {
					queueItem = new QueueItem(items[i+1], true, i, sid, id, type, openedSlots, settings.target, craftingTime, this);
				}else {
					queueItem = new QueueItem(items[i+1], false, i, sid, id, type, openedSlots, settings.target, craftingTime, this);
					//prevItemCraftingTime = items[i].crafted;
				}
				
				itemsContainer.addChild(queueItem);
				queueItemArr.push(queueItem);
				
				queueItem.x = itemX;
				queueItem.y = itemY;
				itemX += itemDX;
			}
			addChild(itemsContainer);
		}
	}

}

import buttons.Button;
import buttons.MoneyButton;
import core.Load;
import core.Post;
import core.TimeConverter;
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.text.TextField;
import ui.Hints;
import wins.elements.ProductionQueue;
import wins.Window;
	

internal class QueueItem extends Sprite 
{
	public  var  itemCont:  Sprite = new Sprite();
	private	 var back:		Bitmap;
	private	 var itemIcon:	Bitmap;
	public	 var bitmap:	Bitmap = new Bitmap;
	private	 var items:		Object;
	public	 var buyBttn:	MoneyButton;
	private  var mode:   	Boolean;
	private var numberInQueue:int;
	private var sid:int;
	private var id:int;
	private var backCont:Sprite;
	private var type:String;
	private var text:TextField;
	private var lock:Bitmap;
	private var openPrice:int;
	private var settings:Object;
	private var openedSlots:int;
	private var target:Object;
	public var sprTip:LayerX = new LayerX();
	private var craftingTimeArr:Array;
	private var craftingTime:int;
	private var productionQueue:ProductionQueue;
	
	public function QueueItem(_items:Object, _mode:Boolean, _numberInQueue:int, _sid:int, _id:int, _type:String, _openedSlots:int, _target:Object, _craftingTime:Array, _productionQueue:ProductionQueue) 
	{
		productionQueue = _productionQueue;
		target = _target;
		openedSlots = _openedSlots;
		craftingTimeArr = _craftingTime;
		mode = _mode;   // определяем состоянеие элемента, открыт/закрыт
		numberInQueue = _numberInQueue;
		sid = _sid;
		id = _id;
		type = _type;
		items = _items;
		
		if (contains(sprTip)) {
				removeChild(sprTip);
				sprTip = new LayerX();
			}
		calculateCraftingTime();	
		sprTip.tip = function():Object {
				return {
					title:App.data.storage[App.data.crafting[items.fID].out].title,
					text:Locale.__e(Locale.__e('flash:1405081234584') +  '\n' + TimeConverter.timeToStr(target.crafted-App.time + craftingTime)),
					timer:true
				}
			}
		for (var item:* in App.data.storage[sid].slots[numberInQueue +1].req)
		{
			openPrice = App.data.storage[sid].slots[numberInQueue +1].req[item];
		}
		
		addChild(itemCont);
		drawBody();
		itemCont.addChild(sprTip);
		drawElement();
	}
	
	private function calculateCraftingTime():void 
	{
		for (var i:int = 0; i <  numberInQueue; i++) 
		{
			craftingTime += craftingTimeArr[i+1];
		}
	}
	
	/** рисует бэкграунд*/
	private function drawBody():void 
	{
		backCont = new Sprite();
		back = new Bitmap(Window.textures.orderBacking);
		back.alpha = 0.7;
		backCont.addChild(back);
		itemCont.addChild(backCont);
		backCont.addEventListener(MouseEvent.CLICK, onBackClick);
	}
	
	private function onBackClick(e:MouseEvent):void 
	{
		if (items == null && mode == true) {
			//target.addInfoBlock()
			productionQueue.addInfoBlock()
		}
	}
	
	/** рисует титульный текст*/
	private function drawText():void
	{
		text = Window.drawText(Locale.__e('flash:1404463696917'), {
			color		:0xe1d09d,
			borderSize	:0,
			widht		:80,
			wrap		:true,
			textAlign	:"center",
			autoSize	:"center",
			fontSize	:24
		});
		text.x = back.x + (back.width - text.width) / 2;
		text.y = back.y + (back.height - text.height) / 2;
		text.mouseEnabled = false;
		itemCont.addChild(text);
	}
	
	/** добавляет замок на закрытый элемент*/
	private function drawLocked():void
	{
		lock = new Bitmap(Window.textures.lock2);
		lock.x = back.x + (back.width - lock.width) / 2;
		lock.y = back.y + (back.height - lock.height) / 2 - 5;
		itemCont.addChild(lock);
		
		buyBttn = new MoneyButton({
			caption		:Locale.__e('flash:1382952379751'),
			width		:100,
			height		:32,	
			fontSize	:18,
			radius		:15,
			countText	:openPrice,
			multiline	:true
		});
		buyBttn.x = back.x + (back.width - buyBttn.width) / 2;
		buyBttn.y = back.y + back.height - buyBttn.height / 2;
		buyBttn.coinsIcon.x= 48;
		buyBttn.countLabel.x = 69;
		
		itemCont.addChild(buyBttn);
		
		//if(App.user.stock.count(Stock.FANT) < openPrice)
		//{
			//buyBttn.state = Button.DISABLED;
		//}
		if (numberInQueue > openedSlots) {
			buyBttn.state = Button.DISABLED;
		}
		buyBttn.addEventListener(MouseEvent.CLICK, buyEvent);
	}
	
	/**По нажатию на кнопку покупки*/
	private function buyEvent(e:MouseEvent):void 
	{
		trace("покупка новой ячейки в очереди");
		if (e.currentTarget.mode == Button.DISABLED) return;
			e.currentTarget.state = Button.DISABLED;
			
		if (App.user.stock.take(Stock.FANT, openPrice)) 
		{
			Post.send({
			ctr:type,
			act:'slot',
			uID:App.user.id,
			pID:numberInQueue+1,
			id:id,
			wID:App.user.worldID,
			sID:sid
			}, onOpenEvent);
		}else {
			e.currentTarget.state = Button.NORMAL;
		}
	}
	
	public function onOpenEvent(error:int, data:Object, params:Object):void 
		{
			if (error) {
				Errors.show(error, data);
				return;
			}
			Hints.minus(Stock.FANT, openPrice, Window.localToGlobal(buyBttn), false);
			
			target.openedSlots++;
			productionQueue.openedSlots++;
			productionQueue.update();
			//onUpdate();
			
		}
		
		private function onUpdate():void 
		{
			if (itemCont != null && lock != null)
				itemCont.removeChild(lock);
			if(itemCont != null && buyBttn != null)
				itemCont.removeChild(buyBttn);
			
			mode = true;
			items = null;
			drawElement();
		}
	
	/**Проверяет какой элемент отрисовывать*/
	private function drawElement():void
	{			
		if (items != null && mode == true){
			drawItem();
		}else if (items == null && mode == true){
			drawText();
		}else drawLocked();
	}
	
	/**Загружает иконку элемента*/
	private function drawItem():void
	{
		Load.loading(Config.getIcon(App.data.storage[App.data.crafting[items.fID].out].type, App.data.storage[App.data.crafting[items.fID].out].preview), onPreviewComplete);
	}
	
	/**Отображает иконку элемента*/
	public function onPreviewComplete(obj:Object):void
	{
		bitmap.bitmapData = obj.bitmapData;
		
		itemIcon = new Bitmap(bitmap.bitmapData);
		itemIcon.scaleX = itemIcon.scaleY = 0.8; 
		itemIcon.smoothing = true;
		itemIcon.x = back.x + (back.width - itemIcon.width) / 2;
		itemIcon.y = back.y + (back.height - itemIcon.height)/2;
		
		sprTip.addChild(itemIcon);
		//itemCont.addChild(itemIcon);
	}
	
	/**Чистим содержимое*/
	public function dispose():void
	{
		if (itemIcon != null)	
			sprTip.removeChild(itemIcon);
		if (sprTip != null)
			itemCont.removeChild(sprTip);
		if (text != null)
			itemCont.removeChild(text);
		if (lock != null)
			itemCont.removeChild(lock);
		if (back != null)
			backCont.removeChild(back);
		if (buyBttn != null) {
			buyBttn.removeEventListener(MouseEvent.CLICK, buyEvent);
			itemCont.removeChild(buyBttn);
		}
		if (itemCont != null)
			removeChild(itemCont);
			
		if (this.parent != null)
			this.parent.removeChild(this);
	}
}