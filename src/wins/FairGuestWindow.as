package wins 
{
	import buttons.Button;
	import buttons.UpgradeButton;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	public class FairGuestWindow extends Window 
	{
		
		private var descLabel:TextField;
		private var beginBttn:UpgradeButton;
		public var info:Object;
		public var target:*;
		
		public function FairGuestWindow(settings:Object=null) 
		{
			
			settings['background'] = settings['background'] || 'questBacking';
			
			super(settings);
			
			target = settings.target;
			info = settings.target.info;
			
			content = [];
			if (info.form && info.form.kicks && info.form.kicks.hasOwnProperty(target.view)) {
				for (var s:* in info.form.kicks[target.view]) {
					var node:Object = info.form.kicks[target.view][s];
					content.push( { sID:s, count:node.c, type:node.t } );
				}
			}
		}
		
		override public function drawBody():void {
			
			exit.x += 4;
			exit.y -= 20;
			
			titleLabel.y -= 10;
			
			drawMirrowObjs('diamondsTop', settings.width / 2 - settings.titleWidth / 2 - 5, settings.width / 2 + settings.titleWidth / 2 + 5, -50, true, true);
			
			var back:Bitmap = backing2(settings.width - 40, 200, 40, "questsSmallBackingTopPiece", "questsSmallBackingBottomPiece");
			bodyContainer.addChild(back);
			back.x = (settings.width - back.width) / 2;
			back.y = 50;
			
			drawMirrowObjs('drapery1', -37, settings.width + 42, -60);
			
			// info
			descLabel = drawText(Locale.__e('flash:1416990203971'), {
				autoSize:		'center',
				textAlign:		'center',
				color:			0xf3fff9,
				borderColor:	0x79561c,
				fontSize:		23,
				multiline:		true
			});
			descLabel.wordWrap = true;
			descLabel.width = settings.width - 200;
			descLabel.x = (settings.width - descLabel.width) / 2;
			descLabel.y = 0;
			bodyContainer.addChild(descLabel);
			
			drawItems();
		}
		
		public var items:Array = [];
		private function drawItems():void {
			
			var container:Sprite = new Sprite();
			
			var X:int = 0;
			var Y:int = 0;
			
			for (var i:int = 0; i < content.length; i++)
			{
				var _item:ShareGuestItem = new ShareGuestItem(content[i], this);
				container.addChild(_item);
				_item.x = X;
				_item.y = Y;
				items.push(_item);
				
				X += _item.bg.width;
			}
			
			bodyContainer.addChild(container);
			container.x = (settings.width - container.width) / 2;
			container.y = 60;
		}
		
		public function blockItems(value:Boolean):void {
			for each(var _item:ShareGuestItem in items) {
				if(value)
					_item.bttn.state = Button.DISABLED;
				else
					_item.bttn.state = Button.NORMAL;
			}
		}
		
		private function drawBttns():void {
			
		}
	}
	
}


import buttons.Button;
import buttons.MoneyButton;
import core.Load;
import core.Post;
import flash.display.Bitmap;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.text.TextField;
import ui.Hints;
import ui.UserInterface;
import wins.elements.PriceLabel;
import wins.Window;

internal class ShareGuestItem extends LayerX{
	
	public var window:*;
	public var item:Object;
	public var bg:Bitmap;
	private var bitmap:Bitmap;
	private var sID:uint;
	public var bttn:Button;
	//private var buyBttn:MoneyButton;
	private var count:uint;
	private var type:uint;
	
	public function ShareGuestItem(obj:Object, window:*) {
		
		this.sID = obj.sID;
		this.count = obj.count;
		this.type = obj.type;
		this.item = App.data.storage[sID];
		this.window = window;
		
		if (type == 2) {
			count = App.data.storage[sID].price[Stock.FANT];
		}
		
		bg = Window.backing(140, 190, 20, 'itemBacking');
		addChild(bg);
		bg.visible = false;
		
		var circle:Shape = new Shape();
		circle.graphics.beginFill(0xc8d4d0, 1);
		circle.graphics.drawCircle(75, 95, 50);
		circle.graphics.endFill();
		addChild(circle);
		
		drawTitle();
		drawBttn();
		drawLabel();
		
		Load.loading(Config.getIcon(item.type, item.preview), onLoad);
		
		tip = function():Object {
			return {
				title: Locale.__e(item.title),
				text: Locale.__e(item.description)
			}
		}
	}
	
	private function drawBttn():void {
		
		var bttnSettings:Object = {
			caption:Locale.__e('flash:1382952380118'),
			width:130,
			height:42,
			fontSize:24
		}
		
		if (type == 2) {
			bttnSettings['bgColor'] = [0xa8f84b, 0x71bc17];
			bttnSettings['borderColor'] = [0xa8f84b, 0x71bc17];
			bttnSettings['bevelColor'] = [0xcefd93, 0x5f9d0e];
			bttnSettings['fontColor'] = 0xfffbff;
			bttnSettings['fontBorderColor'] = 0x5c9510;
		}
		
		bttn = new Button(bttnSettings);
		bttn.x = (bg.width - bttn.width) / 2;
		bttn.y = bg.height - bttn.height + 20;
		bttn.addEventListener(MouseEvent.CLICK, onClick);
		addChild(bttn);
		
		checkButtonsStatus();
	}
	
	private function checkButtonsStatus():void {
		if (type == 3) {
			if (App.user.stock.count(sID) == 0 || window.target.alwaysGive(App.user.id)) {
				bttn.state = Button.DISABLED;
			}else {
				bttn.state = Button.NORMAL;
			}
		}else if (type == 2) {
			if (App.user.stock.count(Stock.FANT) == 0) { 
				bttn.state = Button.DISABLED;
			}else {
				bttn.state = Button.NORMAL;
			}
		}else if (type == 1) {
			if (App.user.friends.data[App.owner.id]['energy'] <= 0 || window.target.alwaysGive(App.user.id)) { 
				bttn.state = Button.DISABLED;
			}else {
				bttn.state = Button.NORMAL;
			}
		}
		
		
		/*if (item.real == 0 && App.user.friends.data[App.owner.id]['energy'] <= 0)
			*/
		
		/*if (window.settings.target.alwaysGive(App.user.id))
			bttn.state = Button.DISABLED;*/
	}
	
	private function onClick(e:MouseEvent):void {
		
		if (e.currentTarget.mode == Button.DISABLED) return;
		
		window.blockItems(true);
		window.settings.target.kickEvent(onKickEventComplete, sID);
		
	}
	
	private function onKickEventComplete():void {
		var targetSID:*;
		
		if (type == 3) {
			App.user.stock.take(sID, count);
			targetSID = sID;
		}else if (type == 2) {
			App.user.stock.take(Stock.FANT, count);
			targetSID = Stock.FANT;
		}else if (type == 1) {
			App.user.friends.data[App.owner.id]['energy'] --;
			targetSID = Stock.GUESTFANTASY;
			window.target.friends[App.user.id] = App.time;
		}
		
		var X:Number = App.self.mouseX - bttn.mouseX + bttn.width / 2;
		var Y:Number = App.self.mouseY - bttn.mouseY;
		Hints.minus(targetSID, count, new Point(X, Y), false, App.self.tipsContainer);
		window.close();
	}	
	
	private function onLoad(data:Bitmap):void {
		bitmap = new Bitmap(data.bitmapData);
		addChild(bitmap);
		bitmap.x = (bg.width - bitmap.width) / 2;
		bitmap.y = (bg.height - bitmap.height) / 2 - 10;
	}
	
	public function dispose():void {
		bttn.removeEventListener(MouseEvent.CLICK, onClick);
	}
	
	public function drawTitle():void {
		
		var title:TextField = Window.drawText(String(item.title), {
			color:0x6d4b15,
			borderColor:0xfcf6e4,
			textAlign:"center",
			autoSize:"center",
			fontSize:24,
			textLeading:-6,
			multiline:true
		});
		title.wordWrap = true;
		title.width = bg.width - 10;
		title.height = title.textHeight;
		title.y = 5;
		title.x = 5;
		addChild(title);
	}
	
	public function drawLabel():void {
		
		var text:TextField;
		if (type == 3) { // Склад
			text = Window.drawText(Locale.__e('flash:1409236136005') + ': ' + App.user.stock.count(sID), {
				color:0x6d4b15,
				borderColor:0xfcf6e4,
				textAlign:"center",
				autoSize:"center",
				fontSize:21,
				textLeading:-6,
				multiline:true
			});
			text.x = (bg.width - text.width) / 2;
			text.y = 138;
			addChild(text);
		}else if (type == 2) { // Деньги
			text = Window.drawText(count.toString(), {
				color:0xf9b2c4,
				borderColor:0x921e4b,
				textAlign:"center",
				autoSize:"center",
				fontSize:26,
				textLeading:-6,
				multiline:true
			});
			text.y = 136;
			addChild(text);
			
			var icon:Bitmap = new Bitmap(UserInterface.textures.fantsIcon, 'auto', true);
			icon.height = text.height;
			icon.scaleX = icon.scaleY;
			addChild(icon);
			
			icon.y = 136;
			icon.x = (bg.width - (icon.width + 8 + text.width)) / 2;
			text.x = icon.x + icon.width + 8;
		}
	}
}