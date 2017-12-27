package wins 
{
	import buttons.Button;
	import buttons.MoneyButton;
	import core.Load;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import units.Castle;

	public class CastleGuestWindow extends Window
	{
		private var items:Array = new Array();
		public var info:Object;
		public var back:Bitmap;
		public var target:Castle;
		
		public function CastleGuestWindow(settings:Object = null)
		{
			if (settings == null) {
				settings = new Object();
			}
			
			settings['width'] = 640;
			settings['height'] = 370;
			settings['title'] = settings.target.info.title;
			settings['description'] = Locale.__e('flash:1417087399779');// settings.target.info.description;
			settings['hasPaginator'] = true;
			settings['hasButtons'] = false;
			settings['hasArrow'] = true;
			settings['itemsOnPage'] = 10;
			
			settings["fontSize"] = 46;
			settings["fontBorderSize"] = 1;
			settings["fontBorderGlow"] = 1;
			
			target = settings.target;
			info = settings.target.info;
			
			settings['content'] = [];
			if (info.form && info.form.view && info.form.view.hasOwnProperty(target.view)) {
				for (var s:* in info.form.view[target.view]) {
					var node:Object = info.form.view[target.view][s];
					settings['content'].push( { sID:node.sid, count:node.cnt, nID:s } );
				}
			}
			
			settings['content'].sortOn('count', Array.NUMERIC);
			
			settings.width = 80 + 150 * settings.content.length + 5 * (settings.content.length - 1);
			
			super(settings);
		}
		
		override public function drawBackground():void {
			var background:Bitmap = backing(settings.width, settings.height, 10, "windowBacking");
			layer.addChild(background);
			background.y = 30;
		}
		
		override public function drawBody():void {

			drawLabel(settings.target.textures.sprites[5].bmp, 0.6);
			titleLabel.y += 20;
			titleLabelImage.y += 20;
			
			exit.x += 5;
			exit.y += 5;
			
			var back:Bitmap = Window.backing(settings.content.length * 150 + (settings.content.length - 1) * 5 + 54, 256, 20, 'dialogueBacking');
			back.x = (settings.width - back.width)/2;
			back.y = 100;
			bodyContainer.addChild(back);
			
			drawItems();
			
			var descriptionLabel:TextField = drawText(Locale.__e(settings.description), {
				fontSize:24,
				autoSize:"left",
				textAlign:"center",
				color:0x5d450f,
				borderColor:0xefe5c3,
				textLeading:-9
			});
			
			descriptionLabel.x = (settings.width - descriptionLabel.width) / 2;
			descriptionLabel.y = 60;
			descriptionLabel.width = settings.width - 80;
			
			bodyContainer.addChild(descriptionLabel);
			
			drawMirrowObjs('diamondsTop', settings.width / 2 - settings.titleWidth / 2 - 5, settings.width / 2 + settings.titleWidth / 2 + 5, -14, true, true);
			drawMirrowObjs('storageWoodenDec', -4, settings.width + 4, 72, false, false, false, 1, -1);
			drawMirrowObjs('storageWoodenDec', -4, settings.width + 4, settings.height - 38, false, false, true, 1, 1);
		}
		
		private function drawItems():void {
			
			var container:Sprite = new Sprite();
			
			var X:int = 0;
			var Y:int = 0;
			
			for (var i:int = 0; i < settings.content.length; i++)
			{
				var _item:ShareGuestItem = new ShareGuestItem(settings.content[i], this);
				container.addChild(_item);
				_item.x = X;
				_item.y = Y;
				items.push(_item);
				
				X += _item.bg.width + 5;
			}
			
			bodyContainer.addChild(container);
			container.x = (settings.width - container.width) / 2;
			container.y = 125;
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
import flash.display.Bitmap;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.text.TextField;
import ui.Hints;
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
	//private var kicks:uint;
	//private var type:int = 0;
	private var count:uint;
	private var nodeID:String;
	
	public function ShareGuestItem(obj:Object, window:*) {
		
		this.sID = obj.sID;
		this.count = obj.count;
		this.nodeID = obj.nID;
		this.item = App.data.storage[sID];
		this.window = window;
		
		bg = Window.backing(150, 190, 20, 'itemBacking');
		addChild(bg);
		
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
			width:110,
			height:36,
			fontSize:26
		}
		
		bttn = new Button(bttnSettings);
		bttn.x = (bg.width - bttn.width) / 2;
		bttn.y = bg.height - bttn.height + 20;
		bttn.addEventListener(MouseEvent.CLICK, onClick);
		addChild(bttn);
		
		checkButtonsStatus();
	}
	
	private function checkButtonsStatus():void {
		if (item.real == 0 && App.user.friends.data[App.owner.id]['energy'] <= 0)
			bttn.state = Button.DISABLED;
		
		if (window.settings.target.alwaysGive(App.user.id))
			bttn.state = Button.DISABLED;
	}
	
	private function onClick(e:MouseEvent):void {
		
		if (e.currentTarget.mode == Button.DISABLED) return;
		
		var boost:int = 0;
		if(item.real > 0)
			boost = 1;
		
		window.blockItems(true);
		window.settings.target.tributeAction(onKickEventComplete, nodeID);
		
	}
	
	private function onKickEventComplete():void {
		App.user.stock.take(sID, count);
		
		var X:Number = App.self.mouseX - bttn.mouseX + bttn.width / 2;
		var Y:Number = App.self.mouseY - bttn.mouseY;
		Hints.minus(sID, count, new Point(X, Y), false, App.self.tipsContainer);
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
			fontSize:20,
			textLeading:-6,
			multiline:true
		});
		title.wordWrap = true;
		title.width = bg.width - 10;
		title.height = title.textHeight;
		title.y = 10;
		title.x = 5;
		addChild(title);
	}
	
	public function drawLabel():void {
		//var price:PriceLabel;
		var text:TextField = Window.drawText(count.toString(), {
			color:0x6d4b15,
			borderColor:0xfcf6e4,
			textAlign:"center",
			autoSize:"center",
			fontSize:30,
			textLeading:-6,
			multiline:true
		});
		text.x = (bg.width - text.width) / 2;
		text.y = 136;
		addChild(text);
	}
}

