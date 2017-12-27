package wins 
{
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.text.TextField;
	import units.Hut;

	public class TechnoManagerWindow extends Window 
	{
		
		public function TechnoManagerWindow(settings:Object=null) 
		{
			if (settings == null) {
				settings = new Object();
			}
			
			settings['width'] 			= 750;
			settings['height'] 			= 400;
			settings['title'] 			= Locale.__e('flash:1382952379828');
			settings['hasPaginator'] 	= true;
			settings['hasButtons']		= false;
			settings['itemsOnPage'] 	= 4;
			var items:Array = Map.findUnits([160, 461, 278, 752]);
			
			for (var i:int = 0; i < items.length; i++ ) {
				if (!items[i].workers[0] && items[i].sid != Hut.KLIDE_HOUSE) {
					items.splice(i, 1);
					i--;
				}
			}
			
			settings['content']         = items;
			
			super(settings);
			
		}
		
		override public function drawBody():void {
			var description:TextField = drawText(Locale.__e('flash:1434545092187') + ' ' + Locale.__e('flash:1434547251181'), {
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
			
			var separator:Bitmap = Window.backingShort(description.width - 5, 'dividerLine', false);
			separator.x = description.x + 5;
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
			var Ys:int = 110;
			itemsContainer.x = 85;
			itemsContainer.y = Ys;
			if (settings.content.length < 1) return;
			for (var i:int = paginator.startCount; i < paginator.finishCount; i++)
			{
				var item:HutItem = new HutItem(this, { sID:settings.content[i].sid, hut:settings.content[i] } );
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
import core.Load;
import core.Size;
import core.TimeConverter;
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.text.TextField;
import ui.UserInterface;
import units.Hut;
import units.Techno;
import units.WorkerUnit;
import wins.TechnoManagerWindow;
import wins.Window;

internal class HutItem extends Sprite
{
	public var window:*;
	public var item:Object;
	public var hut:Hut;
	public var bg:Sprite;
	private var bitmap:Bitmap;
	private var sID:uint;
	public var bttn:Button;
	
	public function HutItem(window:TechnoManagerWindow, data:Object)
	{
		this.sID = data.sID;
		this.item = App.data.storage[sID];
		this.window = window;
		this.hut = data.hut;
		
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
		window.close();
		App.map.focusedOn(hut, true, function():void {
			hut.click();
		});
	}
	
	private function onLoad(data:Bitmap):void {
		bitmap = new Bitmap(data.bitmapData);
		Size.size(bitmap, 120, 120);
		addChildAt(bitmap, 1);
		bitmap.x = (bg.width - bitmap.width) / 2;
		bitmap.y = (bg.height - bitmap.height) / 2 + 35;
		bitmap.smoothing = true;
	}
	
	private function drawBttn():void 
	{
		var bttnSettings:Object = {
			caption:Locale.__e("flash:1394010224398"),
			width:110,
			height:36,
			fontSize:26
		}
		
		bttn = new Button(bttnSettings);
		
		addChild(bttn);
		bttn.x = (bg.width - bttn.width) / 2;
		bttn.y = bg.height + 25;
		bttn.addEventListener(MouseEvent.CLICK, onClick);
		
		if (hut.sid == Hut.KLIDE_HOUSE) bttn.visible = false;
	}
	
	public function drawCount():void {
		var sprite:Sprite = new Sprite();
		var ico:Bitmap = new Bitmap(UserInterface.textures.iconWorker);
		ico.smoothing = true;
		Size.size(ico, 35, 35);
		sprite.addChild(ico);
		
		var textCount:TextField = Window.drawText(getFree() + '/' + getWorkersCount(), {
			color:0xffffff,
			fontSize:30,
			borderColor:0x7b3e07
		});
		textCount.width = textCount.textWidth + 10;
		textCount.x = ico.x + ico.width + 5;
		sprite.addChild(textCount);
		
		sprite.x = (bg.width - sprite.width) / 2;
		sprite.y -= 15;
		addChild(sprite);
	}
	
	private function getFree():int {
		var count:int = 0;
		for each(var worker:* in hut.workers) {
			if (worker.worker.workStatus != WorkerUnit.BUSY) count++;
		}
		if (hut.sid == 278 && count > 1) return 1;
		return count;
	}
	
	private function getWorkersCount():int {
		var count:int = 0;
		if (hut.sid == 278) return 1;
		for each(var techno:* in hut.workers) {
			count++;
		}
		return count;
	}
	
	private var textTime:TextField;
	public function drawTime():void {
		var time:String = '';
		var color:uint = 0x4e2c09;
		var borderColor:uint = 0xf7e6cc;
		if (hut.sid == Hut.KLIDE_HOUSE) {
			time = Locale.__e('flash:1426259573142');
			color = 0xffffff;
			borderColor = 0x7b3e07;
		} else {
			var tm:int = 0;
			if ( hut.workers[0]) tm = hut.workers[0].finished - App.time;
			if (tm <= 0) {
				time = Locale.__e('flash:1434634638268');
				color = 0xd41600;
			}
			else time = TimeConverter.timeToStr(tm);
		}
		textTime = Window.drawText(time, {
			color:color,
			fontSize:26,
			borderColor:borderColor
		});
		textTime.width = textTime.textWidth + 10;
		textTime.x = (bg.width - textTime.width) / 2;
		textTime.y += 20;
		addChild(textTime);
		
		if (hut.sid != Hut.KLIDE_HOUSE) App.self.setOnTimer(updateTime);
	}
	
	public function updateTime():void {
		if (hut && hut.workers[0]) {
			var time:int = hut.workers[0].finished - App.time;
			if (time <= 0) textTime.text =  Locale.__e('flash:1434634638268');
			else textTime.text = TimeConverter.timeToStr(time);
		}
	}
	
	public function dispose():void {
		App.self.setOffTimer(updateTime);
		bttn.removeEventListener(MouseEvent.CLICK, onClick);
	}
}

