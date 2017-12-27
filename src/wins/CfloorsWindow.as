package wins 
{
	import api.ExternalApi;
	import buttons.Button;
	import buttons.MenuButton;
	import buttons.MoneyButton;
	import core.Load;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import ui.Hints;
	import ui.UserInterface;
	import units.Hut;
	import core.Numbers;
	import flash.events.MouseEvent;
	import core.Post;
	
	public class CfloorsWindow extends Window
	{
		private var items:Array = new Array();
		private var info:Object;
		public var back:Bitmap;
		public var buyAllBttn:MoneyButton;
		public var kickBttn:Button;
		public var notifBttn:Button = null;
		public var target:*;
		private var chests:*;
		
		public function CfloorsWindow(settings:Object = null)
		{
			if (settings == null) {
				settings = new Object();
			}
			
			info = settings.target.info;
			target = settings.target;

			settings['fontColor'] = 0xffcc00;
			settings['fontSize'] = 36;
			settings['fontBorderColor'] = 0x705535;
			settings['shadowBorderColor'] = 0x342411;
			settings['fontBorderSize'] = 8;
			
			settings['width'] = 550;
			settings['height'] = 540;
			settings['title'] = info.title;
			settings['hasPaginator'] = true;
			settings['hasButtons'] = false;
			settings['hasArrow'] = true;
			settings['itemsOnPage'] = 10;
			
			settings['content'] = [];
			content = [];
			
			super(settings);
			
			bodyContainer.addChild(itemsContainer);
			generateContent();
		}
		
		override public function drawBody():void {
			//drawPanel();
			//drawKeysLabel();
			//drawBttns();
			//drawNotif();
			
		}
		
		override public function drawArrows():void {
			super.drawArrows();
			
			paginator.x = (settings.width - paginator.width)/2;
			paginator.y = settings.height - paginator.height;
			paginator.x = 0;
			paginator.y = 0;
			
			paginator.arrowLeft.x = paginator.x  - 60;// paginator.x -paginator.arrowLeft.width / 2 + 26;
			paginator.arrowLeft.y = (settings.height - paginator.arrowLeft.height) / 2;
			
			paginator.arrowRight.x = paginator.x + itemsContainer.width + 40;// paginator.x + settings.width - paginator.arrowRight.width / 2 - 26;
			paginator.arrowRight.y = (settings.height - paginator.arrowRight.height) / 2;
		}
		
		override public function drawBackground():void {
			background = backing2(settings.width, settings.height, 190, 'shopBackingTop', 'shopBackingBot');
			layer.addChild(background);
			
			generateContent();
		}
		
		private var itemsContainer:Sprite = new Sprite();
		override public function contentChange():void {
			if (paginator == null)
				return;
			
			if (items) {
				for each(var _item:* in items) {
					if (_item == null)
						continue;
						
					itemsContainer.removeChild(_item);
					_item.dispose();
				}
			}
			items = [];
			
			var X:int = 0;
			var Xs:int = X;
			var Ys:int = 190;
			itemsContainer.x = 30;
			itemsContainer.y = Ys;
			
			if (content.length < 1) return;
			for (var i:int = paginator.startCount; i < paginator.finishCount; i++)
			{
				var object:Object = content[i];
				object['id'] = i + 1;
				
				var item:TextWithIcon= new TextWithIcon(object, this, generateContent);
				item.x = Xs + item.width / 2;
				item.y = 0;
				items.push(item);
				itemsContainer.addChild(item);
				
				Xs += 175;
			}
		}
		
		private function generateContent():void
		{
			content = [];
				
			//chests = App.user.stock.tempChests;
			for (var id:* in chests) {
				for (var index:* in chests[id])
				{
					var object:Object = {
						index:index,
						sID:id,
						expire:chests[id][index].end,
						keys:chests[id][index].keys
					}
					
					content.push(object);
				}		
			}
			
			if(paginator != null)
			{
				paginator.itemsCount = content.length;
				paginator.onPageCount = 3;
				paginator.update();
			}
			contentChange();
		}
		
		private function drawKeysLabel():void{
			
			var descriptionLabel:TextField = drawText(getTextFormInfo('descriptionText'), {
					fontSize:36,
					textAlign:"center",
					color:0x5d450f,
					borderColor:0xefe5c3,
					textLeading: -3,
					multiline:true
				});
				
			descriptionLabel.wordWrap = true;
			descriptionLabel.y = back.y - descriptionLabel.height / 2;
			descriptionLabel.width = settings.width - 140;
			descriptionLabel.x = (settings.width - descriptionLabel.width) / 2;
			
			bodyContainer.addChild(descriptionLabel);
		}
		
		private function drawBttns():void {
			
			keysPrice = 10;
			
			kickBttn = new Button({
				caption		:Locale.__e(settings.target.info.title),
				width		:250,
				height		:38,	
				fontSize	:26
			});
			
			buyAllBttn = new MoneyButton({
				caption		:getTextFormInfo('buyKeysText') + " " + Locale.__e("flash:1382952379984"),
				width		:250,
				height		:42,	
				fontSize	:26,
				countText	:keysPrice
			});
			buyAllBttn.x = (settings.width - buyAllBttn.width) / 2;
			buyAllBttn.y = 350;
			
			kickBttn.x = (settings.width - kickBttn.width) / 2;
			kickBttn.y = 350;
			
			bodyContainer.addChild(kickBttn);
			bodyContainer.addChild(buyAllBttn);
			
			kickBttn.addEventListener(MouseEvent.CLICK, kickEvent);
			buyAllBttn.addEventListener(MouseEvent.CLICK, buyAllEvent);
			
			kickBttn.visible = false;
			buyAllBttn.visible = false;
			
			if (settings.target.kicks >= info.count)
				kickBttn.visible = true;
			else
				buyAllBttn.visible = true;
		}
		
		public var keysPrice:int;
		
		private function buyAllEvent(e:MouseEvent):void {
			if (e.currentTarget.mode == Button.DISABLED) return;
			e.currentTarget.state = Button.DISABLED;
			
			settings.storageEvent(keysPrice, onStorageEventComplete);
		}
		
		private function kickEvent(e:MouseEvent):void {
			if (e.currentTarget.mode == Button.DISABLED) return;
			e.currentTarget.state = Button.DISABLED;
			settings.storageEvent(0, onStorageEventComplete);
		}
		
		public function onStorageEventComplete(sID:uint, price:uint):void {
			
			if (price == 0 ) {
				close();
				return;
			}
			var X:Number = App.self.mouseX - kickBttn.mouseX + kickBttn.width / 2;
			var Y:Number = App.self.mouseY - kickBttn.mouseY;
			Hints.minus(sID, price, new Point(X, Y), false, App.self.tipsContainer);
			close();
		}
		
		private function drawPanel():void {
			
			back = Window.backing(settings.width - 100, 210,20, 'bonusBacking');
			back.x = 50;
			back.y = 80;
			
			bodyContainer.addChild(back);
			
			var itemsIcon:TextWithIcon = new TextWithIcon( { sID:25, count:5 }, this);
			itemsIcon.x = back.x + (back.width) /2;
			itemsIcon.y = back.y + (back.height) /2;

			bodyContainer.addChild(itemsIcon);
		}
		
		private function drawNotif():void {
			//invite friends
			var bttnSettings:Object = {
				caption		:Locale.__e("flash:1382952380289"),
				width		:190,
				height		:38,	
				fontSize	:26
			}
			
			if (settings['content'].length > 0) {
				bttnSettings['width'] = 160;
				bttnSettings['height'] = 30;
				bttnSettings['fontSize'] = 22;
				bttnSettings['caption'] = Locale.__e("flash:1382952379977");
			}
			
			notifBttn = new Button(bttnSettings);
			
			notifBttn.x = back.x + (back.width - notifBttn.width) / 2;
			
			if (settings['content'].length > 0) {
				notifBttn.y = back.y + back.height - bttnSettings.height/ 2;
			}
			else
			{
				notifBttn.y = back.y + back.height - bttnSettings.height/ 2;
			}
			
			bodyContainer.addChild(notifBttn);
			notifBttn.addEventListener(MouseEvent.CLICK, onNotifClick);
		}
		
		private function onNotifClick(e:MouseEvent):void {
			
			switch(App.self.flashVars.social) {
				case 'VK':
				case 'DM':
						new NotifWindow( { target:settings.target } ).show();
					break;
				case 'OK':
				case 'ML':	
				case 'PL':	
				case 'FB':	
						ExternalApi.apiInviteEvent();
					break;
			}
		}
		
		override public function dispose():void {
			
			//kickBttn.removeEventListener(MouseEvent.CLICK, kickEvent);
			//buyAllBttn.removeEventListener(MouseEvent.CLICK, buyAllEvent);
			//if (notifBttn != null) notifBttn.addEventListener(MouseEvent.CLICK, onNotifClick);
			
			super.dispose();
		}
		
		public function getTextFormInfo(value:String):String {
			var text:String = settings.target.info[value];
			text = text.replace(/\r/, "");
			return Locale.__e(text);
		}
	}
}
import buttons.Button;
import buttons.ImageButton;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Shape;
import flash.display.Sprite;
import flash.text.TextField;
import core.Load;
import core.Size;
import units.Techno;
import wins.elements.TimerUnit;
import wins.Window;
import flash.events.MouseEvent;
import core.Post;

class TextWithIcon  extends LayerX {
	public var window:*;
	private var preloader:Preloader;
	private var sprite:LayerX;
	public var bitmap:Bitmap;
	private var background:Shape;
	private var button:Button;
	private var timer:TimerUnit;
	private var onDipose:Function;
	private var circleRadius:int = 53;
	private var item:Object;
	
	function TextWithIcon (item:Object, window:*, onDipose:Function = null) {
		init(item, window, onDipose);
		drawBG();
		addContainers();
		drawTimer();
		drawButton();
		addPreloader();
		loadIcon();
		
		var dot:Shape = new Shape();
			dot.graphics.beginFill(0xFF0000);
			dot.graphics.drawCircle(0, 0, 10);
			dot.graphics.endFill();
			addChild(dot);
	}
	private function init(item:Object, window:*, onDipose:Function = null):void
	{
		this.item = item;
		this.window = window;
		this.onDipose = onDipose;
	}
	
	private function drawBG():void
	{
		background = new Shape();
		background.graphics.beginFill(0xfbe2c8, 1);
		background.graphics.drawCircle(0, 0, circleRadius);
		background.graphics.endFill();
		background.y += circleRadius;
		addChild(background);
	}
	
	private function addContainers():void
	{
		sprite = new LayerX();
		addChild(sprite);
		
		bitmap = new Bitmap();
		sprite.addChild(bitmap);
	}
	
	private function addPreloader():void
	{	
		preloader = new Preloader()
		addChild(preloader);
		preloader.x = 0;
		preloader.y = circleRadius;
	}
	
	private function loadIcon():void
	{
		//Load.loading(Config.getIcon(App.data.storage[sID].type, App.data.storage[sID].preview), onPreviewComplete);
		Load.loading(Config.getIcon("Box", App.data.storage[item.sID].preview), onPreviewComplete);
	}
	
	private function drawButton():void
	{
		button = new Button({
				caption: item.keys,
				width:140,
				height:30,
				fontSize:24,
				radius:20,
				hasDotes:false,
				bgColor:			[0xf28102,0xca6e04],
				bevelColor:			[0xf89626,0xb05e00]
			});
		
		addChild(button);
		button.x = bitmap.x + (bitmap.width - button.width) / 2;
		button.y = circleRadius + bitmap.y + bitmap.height + timer.height + button.height * 1.5;
		
		var obj:* = App.data.storage[item.sID];
		
		for (var sid:* in obj.require)
		{
			Load.loading(Config.getIcon(App.data.storage[sid].type, App.data.storage[sid].preview), onButtonPreviewComplete);
		}
		
		button.addEventListener(MouseEvent.CLICK, onClick);
	}
	
	public function onButtonPreviewComplete(data:Bitmap):void
	{
		var btmp:Bitmap = new Bitmap
		btmp.bitmapData = data.bitmapData;
		Size.size(btmp, 19, 22);
		btmp.smoothing = true;
		
		button.topLayer.addChild(btmp);
		
		btmp.x = 20;
		btmp.y = 5;
	}
	
	private function onClick(e:MouseEvent):void {
		var obj:* = App.data.storage[item.sID];
		
		for (var sid:* in obj.require)
		{
			//trace(App.user.stock.take(3, 1));
			var sendObject:Object = 
			{
				ctr:'stock',
				act:'take',
				uID:App.user.id,
				sID:sid,
				count:obj.require[sid]
			}
				
			Post.send(sendObject,
			function(error:int, data:Object, params:Object):void 
			{
				if (error) {
					Errors.show(error, data);
					return;
				}
			});
		}
		
		onDipose();
	}
	
	public function onPreviewComplete(data:Bitmap):void
	{
		removeChild(preloader);
		
		bitmap.bitmapData = data.bitmapData;
		Size.size(bitmap, 106, 106);
		bitmap.smoothing = true;
		bitmap.x = (background.width) / 2 * - 1;
		bitmap.y = circleRadius +  (background.height) / 2 * - 1 + 5;
		
		addTip();
	}
	
	private function addTip():void {
		var description:String = App.data.storage[item.sID].description;
		if (item.sID == Techno.TECHNO) {
			description = Locale.__e('flash:1396445082768');
		}
		
		sprite.tip = function():Object {
			return {
				title:App.data.storage[item.sID].title,
				text:description
			};
		}
	}
	
	public function drawTimer():void {
		timer = new TimerUnit( {
			backGround:'none',
			width:140,
			height:60,
			time: { 
				started:App.time, 
				duration:(item.expire - App.time) / 3600}, 
			label:'Исчезнет через', 
			color:0xffeb7d,
			borderColor:0x712b15,
			fontSize:36,
			titleColor:0xfff7d2,
			titleBorderColor:0x712b15,
			titleFontSize:24,
			callback:this.onTimeOut} );
		timer.start();
		timer.x = bitmap.x + (bitmap.width - timer.width) / 2;
		timer.y = circleRadius + bitmap.y + bitmap.height + timer.height;
		addChild(timer);
	}
	
	public function dispose():void
	{
		button.removeEventListener(MouseEvent.CLICK, onClick);
		
		if (parent) 
		{
			parent.removeChild(this);
		}
	}
	
	public function onTimeOut():void
	{
		//delete App.user.stock.tempChests[item.sID][item.index];
		
		this.visible = false;
		onDipose();
	}
}
