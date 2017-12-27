package wins 
{
	import adobe.utils.CustomActions;
	import buttons.Button;
	import buttons.MoneyButton;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import units.Compressor;
	
	public class CompressorWindow extends Window 
	{
		
		private var container:Sprite;
		private var bottomCont:Sprite;
		private var bottomCompleteCont:Sprite;
		private var skipBttn:MoneyButton;
		private var timerLabel:TextField;
		private var timerDescLabel:TextField;
		
		public var list:Array;
		public var target:Compressor;
		
		public function CompressorWindow(settings:Object=null) 
		{
			if (!settings) settings = { };
			
			target = settings.target;
			list = settings.units;
			
			settings['width'] = 770;
			settings['height'] = 680;
			settings['title'] = target.info.title;
			settings['itemsOnPage'] = 8;
			
			settings['content'] = initContent();
			
			super(settings);
			
			App.self.setOnTimer(timer);
		}
		
		private function initContent():Array {
			
			var preunits:Object = { };
			var array:Array = [];
			
			for (var i:int = 0; i < list.length; i++) {
				if (!preunits.hasOwnProperty(list[i].sid))
					preunits[list[i].sid] = 0;
				
				preunits[list[i].sid] ++;
			}
			
			for (var s:* in preunits) {
				if (int(s) == 1447) continue;
				array.push( {
					sid:		s,
					count:		preunits[s],
					order:		s
				});
			}
			array.sortOn('order', Array.NUMERIC | Array.DESCENDING);
			return array;
		}
		
		override public function drawBody():void {
			var back:Bitmap = backing(settings.width - 132, settings.height - 240, 50, 'windowDarkBacking');
			back.x = settings.width * 0.5 - back.width * 0.5;
			back.y = 50;
			//bodyContainer.addChild(back);
			
			paginator.itemsCount = settings.content.length;
			paginator.onPageCount = settings.itemsOnPage;
			paginator.update();
			
			
			// Не готов
			bottomCont = new Sprite();
			bodyContainer.addChild(bottomCont);
			
			timerDescLabel = drawText(Locale.__e('flash:1463991668210'), {
				autoSize:	'left',
				textAlign:	'left',
				color:		0xf5eccc,
				borderColor:0x4f2e07,
				fontSize:	32
			});
			timerDescLabel.y = 5;
			bottomCont.addChild(timerDescLabel);
			
			timerLabel = drawText('', {
				width:		160,
				textAlign:	'center',
				color:		0xf8ce26,
				borderColor:0x4f2e07,
				fontSize:	40
			});
			timerLabel.x = timerDescLabel.x + timerDescLabel.width;
			bottomCont.addChild(timerLabel);
			
			skipBttn = new MoneyButton( {
				width:		150,
				height:		44,
				caption:	Locale.__e('flash:1382952380104'),
				countText:	target.info.skip,
				onClick:	onSkipEvent
			});
			skipBttn.x = timerLabel.x + timerLabel.width + 10;
			skipBttn.y = timerLabel.height * 0.5 - skipBttn.height * 0.5 - 2;
			//if (App.debug || App.user.id == '308057051' || App.user.id == '9044558') bottomCont.addChild(skipBttn);
			
			bottomCont.x = settings.width * 0.5 - bottomCont.width * 0.5;
			bottomCont.y = back.y + back.height + 15;
			
			
			//Готов
			bottomCompleteCont = new Sprite();
			bottomCompleteCont.visible = false;
			bodyContainer.addChild(bottomCompleteCont);
			
			var compLabel:TextField = drawText(Locale.__e('flash:1463991451416') + '!', {
				width:		400,
				textAlign:	'center',
				color:		0xf8ce26,
				borderColor:0x4f2e07,
				fontSize:	40
			});
			bottomCompleteCont.addChild(compLabel);
			
			bottomCompleteCont.x = settings.width * 0.5 - bottomCompleteCont.width * 0.5;
			bottomCompleteCont.y = back.y + back.height + 15;
			
			
			// Container
			container = new Sprite();
			container.x = 80;
			container.y = 58;
			bodyContainer.addChild(container);
			
			
			timer();
			contentChange();
			
		}
		
		private function onSkipEvent(e:MouseEvent):void {
			if (skipBttn.mode == Button.DISABLED) return;
			skipBttn.state = Button.DISABLED;
			
			target.onBoostAction(function():void {
				skipBttn.state = Button.NORMAL;
				timer();
				contentChange();
			});
		}
		
		override public function drawArrows():void {
			super.drawArrows();
			
			paginator.arrowLeft.y -= 80;
			paginator.arrowRight.y -= 80;
		}
		
		override public function contentChange():void {
			clear();
			
			for (var i:int = 0; i < settings.itemsOnPage; i++) {
				if (settings.content.length <= paginator.page * paginator.onPageCount + i) continue;
				
				var item:UnitItem = new UnitItem(settings.content[paginator.page * paginator.onPageCount + i], this);
				item.x = 155 * (container.numChildren % 4);
				item.y = 210 * int(container.numChildren / 4);
				container.addChild(item);
			}
		}
		
		private function clear():void {
			while (container.numChildren) {
				var item:UnitItem = container.getChildAt(0) as UnitItem;
				item.dispose();
			}
		}
		
		public function get ready():Boolean {
			return (target.started + target.info.time <= App.time);
		}
		
		protected function timer():void {
			if (ready) {
				if (bottomCompleteCont.visible == false) {
					bottomCompleteCont.visible = true;
					bottomCont.visible = false;
				}
			}else {
				if (bottomCompleteCont.visible == true) {
					bottomCompleteCont.visible = false;
					bottomCont.visible = true;
				}
				
				timerLabel.text = TimeConverter.timeToStr(target.started + target.info.time - App.time);
			}
		}
		
		public function upLayer(item:UnitItem):void {
			if (item && container && container.contains(item) && container.getChildIndex(item) < container.numChildren - 1) {
				container.swapChildrenAt(container.getChildIndex(item), container.numChildren - 1);
			}
		}
		
		override public function close(e:MouseEvent = null):void {
			super.close(e);
			
			skipBttn.dispose();
			skipBttn = null;
			
			App.self.setOffTimer(timer);
		}
		
	}

}

import buttons.Button;
import com.greensock.easing.Cubic;
import com.greensock.TweenLite;
import core.Load;
import core.Size;
import effects.Effect;
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.text.TextField;
import wins.Window;

internal class UnitItem extends LayerX {
	
	public var background:Bitmap;
	private var image:Bitmap;
	private var preloader:Preloader;
	private var titleLabel:TextField;
	private var countLabel:TextField;
	private var compressBttn:Button;
	
	public var count:int;
	public var sid:int;
	public var info:Object;
	public var window:*;
	
	public function UnitItem(data:Object, window:*):void {
		sid = data.sid;
		count = data.count;
		info = Storage.info(sid);
		
		this.window = window;
		
		background = Window.backing(150, 200, 50, 'itemBacking');
		addChild(background);
		
		preloader = new Preloader();
		preloader.x = background.x + background.width * 0.5;
		preloader.y = background.y + background.height * 0.5;
		addChild(preloader);
		
		image = new Bitmap();
		addChild(image);
		
		titleLabel = Window.drawText(info.title, {
			width:		background.width - 20,
			textAlign:	'center',
			color:		0x763b18,
			borderColor:0xfbf5e4,
			fontSize:	20,
			textLeading:-6,
			multiline:	true,
			wrap:		true
		});
		titleLabel.x = background.x + background.width * 0.5 - titleLabel.width * 0.5;
		titleLabel.y = background.y + 15;
		addChild(titleLabel);
		
		countLabel = Window.drawText('x' + count.toString(), {
			width:		background.width - 40,
			textAlign:	'right',
			color:		0xfbf5e4,
			borderColor:0x4f2e07,
			fontSize:	30
		});
		countLabel.x = background.x + background.width * 0.5 - countLabel.width * 0.5;
		countLabel.y = background.y + background.height - 65;
		addChild(countLabel);
		
		compressBttn = new Button( {
			width:		background.width - 32,
			height:		38,
			caption:	Locale.__e('flash:1463991418226'),
			onClick:	onClick,
			fontSize:	24
		});
		compressBttn.x = background.x + background.width * 0.5 - compressBttn.width * 0.5;
		compressBttn.y = background.y + background.height - 30;
		if (count > 1) addChild(compressBttn);
		
		if (!window.ready) compressBttn.state = Button.DISABLED;
		
		Load.loading(Config.getIcon(info.type, info.preview), function(data:Bitmap):void {
			if (preloader && contains(preloader))
				removeChild(preloader);
			
			image.bitmapData = data.bitmapData;
			image.smoothing = true;
			Size.size(image, background.width, background.height * 0.8);
			image.x = background.x + background.width * 0.5 - image.width * 0.5;
			image.y = background.y + background.height * 0.5 - image.height * 0.5;
			
		});
		
		tip = function():Object {
			return {
				title:  info.title,
				text:	info.description
			}
		}
		
		addEventListener(MouseEvent.ROLL_OVER, onOver);
		addEventListener(MouseEvent.ROLL_OUT, onOut);
		
	}
	
	private function onOver(e:MouseEvent):void {
		Effect.light(this, 0.05);
		
		window.upLayer(this);
		
		var list:Array = Map.findUnits([sid]);
		//list.sortOn('icount', Array.DESCENDING | Array.NUMERIC);
		
		UnitsList.createList(list, this);
	}
	
	private function onOut(e:MouseEvent):void {
		Effect.light(this);
		
		UnitsList.removeList();
	}
	
	public function onClick(e:MouseEvent = null):void {
		if (compressBttn.mode == Button.DISABLED) return;
		compressBttn.state = Button.DISABLED;
		
		window.target.onCompressAction(sid);
		window.close();
	}
	
	public function dispose():void {
		if (compressBttn) {
			compressBttn.dispose();
			compressBttn = null;
		}
		
		if (parent) 
			parent.removeChild(this);
	}
	
}

internal class UnitsList extends Sprite {
	
	public static var unitsList:UnitsList;
	
	private var tween:TweenLite;
	private var list:Array;
	private var items:Vector.<UnitInfoItem> = new Vector.<UnitInfoItem>;
	
	public static function createList(list:Array, listParent:*):void {
		UnitsList.removeList()
		
		var decompList:UnitsList = new UnitsList(list);
		
		
		decompList.x = listParent.background.width * 0.5 - decompList.width * 0.5;
		decompList.y = listParent.height + 18;
		decompList.alpha = 0;
		
		listParent.addChild(decompList);
		
		decompList.startTween();
		
		UnitsList.unitsList = decompList;
	}
	
	public static function removeList():void {
		if (UnitsList.unitsList) {
			UnitsList.unitsList.dispose();
			UnitsList.unitsList = null;
		}
	}
	
	public function UnitsList(list:Array):void {
		this.list = list;
		
		draw();
	}
	
	public function startTween():void {
		var destinationY:int = y - 20;
		
		tween = TweenLite.to(this, 0.25, {
			alpha:	1,
			y:		destinationY,
			ease:	Cubic.easeOut
		});
	}
	
	private function draw():void {
		for (var i:int = 0; i < list.length; i++) {
			if (i >= 4) {
				var text:TextField = Window.drawText('...', {
					autoSize:		'left',
					fontSize:		42,
					color:			0xfbf5e4,
					borderColor:	0x4f2e07
				});
				text.x = 60 * items.length;
				text.y = 14;
				addChild(text);
				break;
			}
			
			var item:UnitInfoItem = new UnitInfoItem(list[i].sid, list[i].icount);
			item.x = 60 * items.length;
			
			addChild(item);
			items.push(item);
			
			if (items.length > 1) {
				var plus:Bitmap = new Bitmap(Window.textures.plus, 'auto', true);
				plus.scaleX = plus.scaleY = 0.55;
				plus.x = item.x - 16;
				plus.y = 16;
				addChild(plus);
			}
		}
	}
	
	public function dispose():void {
		while (items.length) {
			var item:UnitInfoItem = items.shift();
			item.dispose();
		}
		
		items = null;
		
		if (tween) {
			tween.kill();
			tween = null;
		}
		
		if (parent)
			parent.removeChild(this);
	}
}

internal class UnitInfoItem extends LayerX {
	
	private var image:Bitmap;
	private var background:Bitmap;
	private var countLabel:TextField;
	private var info:Object;
	private var preloader:Preloader;
	
	public function UnitInfoItem(sid:int, count:int = 0):void {
		background = Window.backing(60, 60, 10, "itemBacking");
		background.x = -2;
		addChild(background);
		
		image = new Bitmap();
		addChild(image);
		
		preloader = new Preloader();
		preloader.scaleX = preloader.scaleY = 0.5;
		preloader.x = background.x + background.width * 0.5;
		preloader.y = background.y + background.height * 0.5;
		addChild(preloader);
		
		countLabel = Window.drawText('x' + count.toString(), {
			width:		60,
			fontSize:	18,
			textAlign:	'center',
			color:		0xfbf5e4,
			borderColor:0x4f2e07
		});
		countLabel.x = 0;
		countLabel.y = 34;
		addChild(countLabel);
		
		if (!App.data.storage[sid]) return;
		
		info = App.data.storage[sid];
		
		tip = function():Object {
			return {
				title:	info.title,
				text:	info.description
			}
		}
		
		Load.loading(Config.getIcon(info.type, info.preview), onLoad);
	}
	
	private function onLoad(data:Bitmap):void {
		if (preloader && contains(preloader))
			removeChild(preloader);
		
		if (!image) return;
		
		image.bitmapData = data.bitmapData;
		image.smoothing = true;
		
		if (image.height > background.height * 0.8) {
			image.height = int(background.height * 0.8);
			image.scaleX = image.scaleY;
			if (image.width > background.width * 0.9) {
				image.width = int(background.width * 0.9);
				image.scaleY = image.scaleX;
			}
		}
		
		image.x = (background.width - image.width) / 2;
		image.y = (background.height - image.height) / 2;
	}
	
	public function dispose():void {
		if (parent)
			parent.removeChild(this);
		
		preloader = null;
		background = null;
		image = null;
	}
	
}