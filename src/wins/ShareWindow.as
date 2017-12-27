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

	public class ShareWindow extends Window
	{
		private var items:Array = new Array();
		private var info:Object;
		public var back:Bitmap;
		public var buyAllBttn:MoneyButton;
		public var kickBttn:Button;
		
		public function ShareWindow(settings:Object = null)
		{
			if (settings == null) {
				settings = new Object();
			}
			
			info = settings.target.info;
			
			settings['fontColor'] = 0xffcc00;
			settings['fontSize'] = 36;
			settings['fontBorderColor'] = 0x705535;
			settings['shadowBorderColor'] = 0x342411;
			settings['fontBorderSize'] = 8;
			
			
			settings['width'] = 550;
			settings['height'] = 440;
			settings['title'] = info.title;
			settings['hasPaginator'] = true;
			settings['hasButtons'] = false;
			settings['hasArrow'] = true;
			settings['itemsOnPage'] = 10;
			
			settings['content'] = []
			
			for (var _uid:* in settings.target.guests) {
				if (!App.user.friends.data.hasOwnProperty(_uid)) continue;
				settings['content'].push({uid:_uid, time:settings.target.guests[_uid]})
			}
			
			super(settings);
		}
		
		private function drawStageInfo():void{
			
			var textSettings:Object = 
			{
				title		:getTextFormInfo('text3') + Locale.__e("flash:1382952380278", [settings.target.kicks, info.count]),
				fontSize	:36,
				color		:0x564c45,
				borderColor	:0xf9f2dd,
				textAlign	:"center"
			}
			
			var titleText:Sprite = titleText(textSettings);
				titleText.x = (settings.width - titleText.width) / 2;
				titleText.y = 300;
				bodyContainer.addChild(titleText);
		}
		
		override public function drawBody():void {

			drawLabel(settings.target.textures.sprites[3].bmp);
			titleLabel.y += 20;
			titleLabelImage.y += 20;
			
			drawVisitors();
			drawStageInfo();
			
			if (settings.content.length == 0)
			{
				var descriptionLabel:TextField = drawText(getTextFormInfo('text4'), {
					fontSize:22,
					//autoSize:"left",
					textAlign:"center",
					//color:0x502f06,
					//border:false,
					color:0x5d450f,
					borderColor:0xefe5c3,
					textLeading: -3,
					multiline:true
				});
				
				descriptionLabel.wordWrap = true;
				descriptionLabel.y = 120;
				descriptionLabel.width = settings.width - 140;
				descriptionLabel.x = (settings.width - descriptionLabel.width) / 2;
				
				bodyContainer.addChild(descriptionLabel);
			}
			
			drawBttns();
		}
		
		private function drawBttns():void {
			
			skipPrice = (info.count - settings.target.kicks) * info.skip;
			
			kickBttn = new Button({
				caption		:Locale.__e(settings.target.info.text5),
				width		:190,
				height		:38,	
				fontSize	:26
			});
			
			buyAllBttn = new MoneyButton({
				caption		:getTextFormInfo('text5') + " " + Locale.__e("flash:1382952379984"),
				width		:190,
				height		:42,	
				fontSize	:26,
				countText	:skipPrice
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
		
		public var skipPrice:int;
		
		private function buyAllEvent(e:MouseEvent):void {
			if (e.currentTarget.mode == Button.DISABLED) return;
			e.currentTarget.state = Button.DISABLED;
			
			settings.storageEvent(skipPrice, onStorageEventComplete);
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
		
		private function drawVisitors():void {
			
			back = Window.backing(settings.width - 100, 210,20, 'bonusBacking');
			back.x = 50;
			back.y = 80;

			var text:String = Locale.__e(settings.target.info.text2);
			var label:TextField = drawText(text, {
				fontSize:26,
				autoSize:"center",
				textAlign:"center",
				//color:0x502f06,
				color:0xf0e6c1,
				borderColor:0x502f06,
				border:true
			});
			
			label.width = settings.width - 50;
			label.height = label.textHeight;
			label.x = (settings.width - label.width) / 2;
			label.y = back.y - 10;
			
			bodyContainer.addChild(back);
			bodyContainer.addChild(label);	
			
			if (settings['content'].length > 0){
				contentChange();
				drawNotif();
			}else{
				drawNotif();
			}	
		}
		
		public var notifBttn:Button = null;
		
		private function drawNotif():void {
			
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
				notifBttn.y = back.y + back.height - 28;
			}
			else
			{
				notifBttn.y = back.y + (back.height - notifBttn.height) / 2 + 35;
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
		
		override public function drawArrows():void {
				
			paginator.drawArrow(bodyContainer, Paginator.LEFT,  0, 0, { scaleX: -1, scaleY:1 } );
			paginator.drawArrow(bodyContainer, Paginator.RIGHT, 0, 0, { scaleX:1, scaleY:1 } );
			
			var y:Number = back.y + back.height / 2 - paginator.arrowLeft.height / 2;
			paginator.arrowLeft.x = -paginator.arrowLeft.width/2 + 26;
			paginator.arrowLeft.y = y;
			
			paginator.arrowRight.x = settings.width-paginator.arrowRight.width/2 - 26;
			paginator.arrowRight.y = y;
		}
		
		public override function contentChange():void {
			
			for each(var _item:* in items)
			{
				_item.dispose();
				bodyContainer.removeChild(_item);
			}
			
			items = [];
			
			var X:int = 70;
			var Xs:int = X;
			var Y:int = back.y + 15;
			var itemNum:int = 0;
			
			for (var i:int = paginator.startCount; i < paginator.finishCount; i++)
			{
				if (i >= settings.content.length) break;
				var item:ShareItem = new ShareItem(settings.content[i], this);
				items.push(item);
				bodyContainer.addChild(item);
				item.x = X;
				item.y = Y;
				
				X += item.bg.width + 3;
				
				if (itemNum == 4){
					Y += item.bg.height + 3;
					X = Xs;
				}
				
				itemNum++;
			}
		}
		
		override public function dispose():void {
			
			kickBttn.removeEventListener(MouseEvent.CLICK, kickEvent);
			buyAllBttn.removeEventListener(MouseEvent.CLICK, buyAllEvent);
			if (notifBttn != null) notifBttn.addEventListener(MouseEvent.CLICK, onNotifClick);
			
			super.dispose();
		}
		
		public function getTextFormInfo(value:String):String {
			var text:String = settings.target.info[value];
			text = text.replace(/\r/, "");
			return Locale.__e(text);
		}
	}
}


import core.AvaLoad;
import core.Load;
import flash.display.Bitmap;
import flash.display.Shape;
import flash.display.Sprite;
import wins.Window;

internal class ShareItem extends LayerX {
	
	public var window:*;
	public var uid:*;
	public var time:uint;
	public var bg:Bitmap;
	private var bitmap:Bitmap;
	private var maska:Shape;
	
	public function ShareItem(obj:Object, window:*) {
		
		this.uid = obj.uid;
		this.time = obj.time;
		this.window = window;
		
		bg = Window.backing(80, 80, 20, 'textSmallBacking');
		addChild(bg);
		
		maska = new Shape();
		maska.graphics.beginFill(0xFFFFFF, 1);
		maska.graphics.drawRoundRect(0,0,50,50,15,15);
		maska.graphics.endFill();
		
		addChild(maska);
		
		//Load.loading(App.user.friends.data[uid].photo, onLoad);
		new AvaLoad(App.user.friends.data[uid].photo, onLoad);
		
		
		var count:int = int(Math.random() * 10) + 1;
		
		tip = function():Object {
			return {
				title	:App.user.friends.data[uid].first_name + " " +App.user.friends.data[uid].last_name
				//text	:Locale.__e("Этот друг ударил [%d раз|%d раflash:1382952379984|%d раз]", [count])
			}
		}
	}
	
	private function onLoad(data:Bitmap):void {
		bitmap = new Bitmap(data.bitmapData);
		addChild(bitmap);
		bitmap.x = (bg.width - bitmap.width) / 2;
		bitmap.y = (bg.height - bitmap.height) / 2;
		
		maska.x = bitmap.x;
		maska.y = bitmap.y;
		bitmap.mask = maska;
	}
	
	public function dispose():void {
		
	}
	
	
}

