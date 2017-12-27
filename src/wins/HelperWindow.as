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
	import flash.events.ProgressEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import ui.Hints;
	import ui.UserInterface;
	import units.Hut;

	public class HelperWindow extends Window
	{
		private var items:Array = new Array();
		private var info:Object;
		public var back:Bitmap;
		public var takeBttn:Button;
		public var kickBttn:Button;
		
		public var started:uint;
		public var totalTime:uint;
		
		public function HelperWindow(settings:Object = null)
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
			
			settings['width'] = 670;
			settings['height'] = 420;
			settings['title'] = info.title;
			settings['hasPaginator'] = true;
			settings['hasButtons'] = false;
			settings['hasArrow'] = true;
			settings['itemsOnPage'] = 10;
			
			settings['content'] = initContent(settings.target.stacks);
			super(settings);
		}
		
		private function initContent(stacks:Object):Array
		{
			var content:Array = [];
			for (var i:* in stacks)
			{
				for(var sID:* in stacks[i]) {
					content.push(sID);
				}
			}
			
			return content;
		}
		
		public var progressBar:ProgressBar;
		private function drawStageInfo():void {
			
			if (settings.target.started == 0) return;
			
			var text:String = Locale.__e('flash:1382952380145');
			var label:TextField = drawText(text, {
				fontSize:26,
				color:0xf0e6c1,
				borderColor:0x502f06,
				border:true
			});
			
			leftTimeLabel = drawText("", {
				fontSize:26,
				color:0xf0e6c1,
				borderColor:0x502f06,
				border:true
			});
			
			label.width = label.textWidth + 5;
			label.height = label.textHeight;
			leftTimeLabel.height = label.height;
			label.x = (settings.width - label.width) / 2 - 40;
			label.y = 300;
			
			bodyContainer.addChild(label);
			bodyContainer.addChild(leftTimeLabel);
			leftTimeLabel.x = label.x + label.width + 10;
			leftTimeLabel.y = label.y;
			
			progress();
			App.self.setOnTimer(progress);
		}
		
		private var leftTime:uint;
		private var leftTimeLabel:TextField;
		private function progress():void
		{
			leftTime = settings.target.info.time - (App.time - settings.target.started);
			leftTimeLabel.text = TimeConverter.timeToStr(leftTime);
			
			if (leftTime <= 0) {
				App.self.setOffTimer(progress);
				close();
			}
		}
		
		override public function drawBody():void {
			
			drawLabel(settings.target.textures.sprites[0].bmp, 0.6);
			titleLabelImage.y += 20;
			drawVisitors();
			drawStageInfo();
			
			drawBttns();
		}
		
		private function drawBttns():void {
			
			skipPrice = info.skip;
			
			takeBttn = new Button({
				caption		:Locale.__e("flash:1382952380146"),
				width		:190,
				height		:42,	
				fontSize	:26
			});
			takeBttn.x = (settings.width - takeBttn.width) / 2;
			takeBttn.y = 250;
			
			bodyContainer.addChild(takeBttn);
			
			takeBttn.addEventListener(MouseEvent.CLICK, takeAllEvent);
			takeBttn.visible = true;
			
			if (settings.target.stacksIsEmpty()) {
				takeBttn.state = Button.DISABLED;
			}
		}
		
		public var skipPrice:int;
		
		private function takeAllEvent(e:MouseEvent):void {
			if (e.currentTarget.mode == Button.DISABLED) return;
			e.currentTarget.state = Button.DISABLED;
			
			settings.onTakeEvent();
			close();
		}
		
		private function drawVisitors():void {
			
			back = Window.backing(settings.width - 100, 160, 20, 'bonusBacking');
			back.x = 50;
			back.y = 80;
			
			var text:String = Locale.__e('flash:1382952380147');
			var label:TextField = drawText(text, {
				fontSize:26,
				autoSize:"center",
				textAlign:"center",
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
			
			
			contentChange();
			
		}
		
		public override function contentChange():void {
			
			for each(var _item:* in items)
			{
				_item.dispose();
				bodyContainer.removeChild(_item);
			}
			
			items = [];
			
			var cont:Sprite = new Sprite();
			
			var X:int = 0;
			var Xs:int = X;
			var Y:int = 0;
			var itemNum:int = 0;
			
			for (var i:int = 0; i < 5; i++)
			{
				var item:HelperItem;
				
				item = new HelperItem(this);
				item.alpha = 0.5;
				items.push(item);
				cont.addChild(item)
				
				item.x = X;
				item.y = Y;
				
				X += item.bg.width;// + 3;
				
				itemNum++;
			}
			
			if (settings['content'].length > 0) {
				var L:int = settings.content.length;
				
				if (L > settings.target.info.stacks) 
					L = settings.target.info.stacks;
					
				for (i = 0; i < L; i++) {
					items[i].change(settings.content[i]);
				}
			}
			
			bodyContainer.addChild(cont);
			cont.x = (settings.width - cont.width) / 2;
			cont.y = back.y + 24;
		}
		
		override public function dispose():void {
			super.dispose();
		}
	}
}


import core.AvaLoad;
import core.Load;
import flash.display.Bitmap;
import flash.display.Shape;
import flash.display.Sprite;
import wins.Window;

internal class HelperItem extends LayerX {
	
	public var window:*;
	public var sID:uint;
	public var time:uint;
	public var bg:Bitmap;
	private var bitmap:Bitmap;
	private var maska:Shape;
	
	public var ava_width:int = 90;
	
	public function HelperItem(window:*) {
		
		this.window = window;
		
		bg = Window.backing(110, 110, 20, 'textSmallBacking');
		addChild(bg);
		
		maska = new Shape();
		maska.graphics.beginFill(0xFFFFFF, 1);
		maska.graphics.drawRoundRect(0,0,ava_width,ava_width,15,15);
		maska.graphics.endFill();
		
		addChild(maska);
		maska.visible = false;
	}
	
	public function change(sID:uint):void {
		
		this.alpha = 1;
		this.sID = sID;
		
		tip = function():Object {
			return {
				title:App.data.storage[sID].title
			}
		}
		
		Load.loading(Config.getIcon(App.data.storage[sID].type, App.data.storage[sID].preview), onLoad);
	}
	
	private function onLoad(data:Bitmap):void 
	{
		bitmap = new Bitmap(data.bitmapData);
		addChild(bitmap);
		
		bitmap.scaleX = bitmap.scaleY = 0.8;
		bitmap.smoothing = true;
		
		bitmap.x = (bg.width - bitmap.width) / 2;
		bitmap.y = (bg.height - bitmap.height) / 2;
		
		maska.x = (bg.width - maska.width)/2;
		maska.y = (bg.height - maska.height)/2;
		bitmap.mask = maska;
		
		maska.visible = true;
	}
	
	public function dispose():void {
		
	}
}

