package wins {
	
	import api.ExternalApi;
	import buttons.Button;
	import core.Load;
	import core.Post;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.utils.setTimeout;

	public class DayliBonusWindow extends Window {
		
		public var items:Array = new Array();
		private var back:Bitmap;
		private var okBttn:Button;
		public var currentDayItem:DayliItem
		
		public function DayliBonusWindow(settings:Object = null) {
			if (settings == null) {
				settings = new Object();
			}
			
			settings['width'] 				= 810;
			settings['height'] 				= 340;
			settings['title'] 				= Locale.__e("flash:1382952380042");
			settings['hasPaginator'] 		= false;
			settings['content'] 			= [];
			settings['fontSize'] 			= 48;
			settings['shadowBorderColor']   = 0x342411;
			settings['fontBorderSize'] 		= 4;
			settings['hasExit'] 			= false;
			settings['faderClickable'] 		= false;
			
			for each(var item:Object in App.data.daylibonus) {
				settings.content.push(item);
			}
			
			super(settings);
		}
		
		override public function drawTitle():void {
			titleLabel = titleText( {
				title				: settings.title,
				color				: 0xffffff,
				multiline			: settings.multiline,			
				fontSize			: 46,
				textLeading	 		: settings.textLeading,	
				border				: true,
				borderColor 		: 0xc4964e,			
				borderSize 			: 4,	
				shadowColor			: 0x503f33,
				shadowSize			: 4,
				width				: settings.width - 140,
				textAlign			: 'center',
				sharpness 			: 50,
				thickness			: 50
			});
			titleLabel.x = (settings.width - titleLabel.width) / 2;
			titleLabel.y = - titleLabel.height / 2;
			titleLabel.mouseChildren = titleLabel.mouseEnabled = false;
			headerContainer.addChild(titleLabel);
			
			var descLabel:TextField = Window.drawText(Locale.__e("flash:1397115227646"), {
				fontSize	:32,
				color		:0xffffde,
				borderColor	:0x864e0f,
				textAlign	:"center",
				shadowColor	: 0x503f33,
				shadowSize	: 1
			});
			descLabel.width = descLabel.textWidth + 10;
			descLabel.x = (settings.width - descLabel.width) / 2;
			descLabel.y = 32;
			headerContainer.addChild(descLabel);
			
			headerContainer.y = -32;
			headerContainer.mouseEnabled = false;
		}
		
		override public function drawBackground():void {
			back = Window.backing(settings.width, settings.height, 20, 'alertBacking');
			back.x = (settings.width - back.width) / 2;
			back.y = 0;
			layer.addChild(back);
			
			var backRibbon:Bitmap = backingShort(settings.width + 80, 'ribbonYellow');
			backRibbon.x = back.x + (back.width - backRibbon.width) / 2;
			backRibbon.y = back.y - 35;
			layer.addChild(backRibbon);
		}
		
		override public function drawBody():void {
			Load.loading(Config.getImage('promo/images', 'crystals'), function(data:Bitmap):void {
				var image:Bitmap = new Bitmap(data.bitmapData);
				headerContainer.addChildAt(image, 0);
				image.x = settings.width / 2 - image.width / 2;
				image.y = -80;
			});
			
			var bgW1:Bitmap = Window.backing(150, 40, 50, 'fadeOutYellow');
			bgW1.alpha = 0;		//0.4
			bgW1.x = (settings.width - bgW1.width) / 2; //будет менятся в зависимости от положения дня "сегодня"   или нет :)
			bgW1.y = 15;
			bodyContainer.addChild(bgW1);
			
			var up_devider:Bitmap = new Bitmap(Window.textures.dividerLine);
			up_devider.x = 75;
			up_devider.y = bgW1.y + bgW1.height;
			up_devider.width = settings.width - 150;
			up_devider.alpha = 0.6;
			
			var bgW2:Bitmap = Window.backing(up_devider.width, 174, 50, 'fadeOutWhite');
			bgW2.alpha = 0.4;
			bgW2.x = (settings.width - bgW2.width) / 2;
			bgW2.y = up_devider.y;
			bodyContainer.addChild(bgW2);
			
			bodyContainer.addChild(up_devider);
			
			var down_devider:Bitmap = new Bitmap(Window.textures.dividerLine);
			down_devider.x = up_devider.x;
			down_devider.width = up_devider.width;
			down_devider.y = up_devider.y + 170;
			down_devider.alpha = 0.6;
			bodyContainer.addChild(down_devider);
			
			drawItems();
			
			okBttn = new Button( {
				caption:Locale.__e('flash:1382952379737'),
				fontSize:28,
				width:200,
				height:50
			});
			okBttn.name = 'DayliBonusWindow_okBttn';
			okBttn.x = (settings.width - okBttn.width) / 2;
			okBttn.y = settings.height - okBttn.height / 2 - 80;
			bodyContainer.addChild(okBttn);
			okBttn.addEventListener(MouseEvent.CLICK, onOkBttn);
		}
		
		private function onOkBttn(e:MouseEvent):void {
			if (e.currentTarget.mode == Button.DISABLED) return;
			
			e.currentTarget.state = Button.DISABLED
			take();
		}
		
		private var container:Sprite;
		public static var icons:Vector.<Object> = new Vector.<Object>;
		private function drawItems():void {
			container = new Sprite();
			var X:int = 0;
			var Y:int = 10;
			for (var i:int = 0; i < settings.content.length; i++) {				
				var item:DayliItem = new DayliItem(icons[i].sid, settings.content[i], this, new Bitmap(icons[i].bmd));
				
				if (item.itemDay == App.user.day) {
					container.addChild(item);
				} else
					container.addChildAt(item,0);
				item.x = X;
				item.y = Y;
				
				X += item.width - 25;
			}
			container.x = (settings.width - container.width) / 2;
			container.y = 35;
			bodyContainer.addChild(container);
		}
		
		public function take():void {
			Post.send( {
				ctr:'user',
				act:'day',
				uID:App.user.id
			}, function(error:int, data:Object, params:Object):void {
				if (error) {
					Errors.show(error, data);
					return;
				}
				
				if (App.social == 'FB') {
					ExternalApi.og('claim', 'daily_bonus');
				}
				
				App.user.stock.addAll(data.bonus);
				
				for (var _sid:* in data.bonus) {
					var item:BonusItem = new BonusItem(_sid, data.bonus[_sid]);
					var point:Point = Window.localToGlobal(currentDayItem);
					point.y += 80;
					item.cashMove(point, App.self.windowContainer);
				}
				
				setTimeout(close, 300);
			});
		}
		
		override public function dispose():void {
			if (container) {
				while (container.numChildren > 0) {
					var _item:* = container.getChildAt(0);
					if (_item is DayliItem) _item.dispose();
					container.removeChild(_item);
				}
			}
			if (okBttn) okBttn.removeEventListener(MouseEvent.CLICK, onOkBttn);
			
			super.dispose();
		}
	}
}	


import core.Load;
import flash.display.Bitmap;
import flash.display.Shape;
import flash.filters.GlowFilter;
import flash.text.TextField;
import flash.utils.clearInterval;
import flash.utils.setInterval;
import ui.UserInterface;
import wins.DayliBonusWindow;
import wins.Window;
	
internal class DayliItem extends LayerX {
	
	private var item:Object;
	private var icon:Bitmap;
	private var circle:Shape;
	public var win:DayliBonusWindow;
	private var title:TextField;
	private var sID:uint;
	private var count:uint;
	private var status:int = 0;
	public var itemDay:int;
	private var check:Bitmap = new Bitmap(Window.textures.checkMark);
	private var layer:LayerX;
	private var intervalPluck:int;
	private var glowing:GlowFilter = new GlowFilter(0xffffb6, 1, 24, 24, 3, 1, false, false);
	
	public function DayliItem(sid:uint, item:Object, win:DayliBonusWindow, bitmap:Bitmap) {
		this.win = win;
		this.item = item;
		this.icon = bitmap;
		this.sID = sid;
		itemDay = item.day;
		
		if (item.day == App.user.day) {
			status = 1;							//сегодня
			win.currentDayItem = this;
		} else if (item.day > App.user.day + 1)
			status = 0;							//
		else if (item.day == App.user.day + 1)
			status = 2;							//
		else if (item.day < App.user.day)
			status = -1;						//
		
		circle = new Shape();
		
		if (status == 1) {
			circle.graphics.beginFill(0xb1c0b9, 1);
			circle.graphics.drawCircle(80, 100, 70);
			circle.graphics.endFill();
		} else {
			circle.graphics.beginFill(0xb1c0b9, 1);
			circle.graphics.drawCircle(80, 100, 55);
			circle.graphics.endFill();
		}
		
		addChild(circle);
		
		if (item == null) return;
		
		count = item.bonus[sID];
		
		drawDay();
		
		/*if (status == 1) {
			var glow:Bitmap = new Bitmap(Window.textures.glow, 'auto', true);
			glow.alpha = 0.75;
			glow.width = pwidth;
			glow.height = pheight;
			addChild(glow);
		}*/
		
		layer = new LayerX();
		addChild(layer);
		
		layer.addChild(icon);			
		if(sID == Stock.EXP)
			icon.scaleX = icon.scaleY = 0.8;
		else
			icon.scaleX = icon.scaleY = 0.9;
			
		icon.smoothing = true;
		icon.x = (164 - icon.width) / 2;
		icon.y = 100 - icon.height / 2;
		
		if (status == -1) {
			icon.alpha = 0.5;
		}
		
		if (status == 1) {
			icon.scaleX = icon.scaleY = 1.2;
			icon.x -= 20;
			icon.y -= 20;
			startPluck();
			//layer.showGlowing();
			icon.filters = [glowing];
		}
		//if (sID == Stock.FANT) return;
		if (status == 0 || status == 2) {
			UserInterface.effect(bitmap, 0, 0.6);
		}
		
		drawTitle();
		drawMark();
		drawCount();
		
		if (status == 0 || status == 2) {
			circle.graphics.beginFill(0x878a82, 1);
			circle.graphics.drawCircle(80, 100, 55);
			circle.graphics.endFill();
		}
		
		if (status == 1) {
			//this.showGlowing();
		}
	}
	
	private function drawMark():void {
		if (status == -1) {
			addChild(check);
		}
		check.x = 50;
		check.y = 70;
	}
	
	private function drawTitle():void {
		title = Window.drawText(App.data.storage[sID].title, {
			color:0x71431a,
			borderColor:0xf8e6d2,
			shadowColor:0xf8e6d2,
			shadowSize:1,
			textAlign:"center",
			autoSize:"center",
			fontSize:28,
			textLeading:-6,
			multiline:true
		});
		title.wordWrap = true;
		title.width = 155;
		title.x = 5;
		title.y = 15;
		addChild(title);
	}
	
	private function drawDay():void {
		var textSettings:Object = {
			color:0xfff5e3,
			borderColor:0x855729,
			shadowColor:0x855729,
			shadowSize:1,
			fontSize:32,
			textAlign:"center",
			autoSize:"center",
			textLeading:-6,
			multiline:true
		}
		
		var text:String = Locale.__e('flash:1382952380043', [item.day]);
		
		if(status == 1) {
			text = Locale.__e("flash:1382952380044");
			textSettings['color'] = 0xFFFFFF;
			textSettings['borderColor'] = 0x603306;
			textSettings['borderSize'] = 4;
			textSettings['fontSize'] = 32;
		}
		if(status == 2) {
			text = Locale.__e("flash:1383041362368");
			textSettings['color'] = 0xFFFFFF;
			textSettings['borderColor'] = 0x603306;
			textSettings['fontSize'] = 28;
		}	
		if(status == 0) {
			textSettings['color'] = 0xFFFFFF;
			textSettings['borderColor'] = 0x603306;
			textSettings['fontSize'] = 28;
		}
		
		var title:TextField = Window.drawText(text, textSettings);
		title.wordWrap = true;
		title.width = 164;
		title.y = -25;
		title.x = 0;
		//addChild(title);
		
		if (status == 1) {
			title.y -= 2;
			
			var bgW1:Bitmap = Window.backing(164, 40, 50, 'fadeOutYellow');
			bgW1.alpha = 1;
			bgW1.x = 0;
			bgW1.y = -30;
			addChild(bgW1);
		}
		
		addChild(title);
	}
	
	private function drawCount():void {
		var countText:TextField = Window.drawText("x" + String(count), {
			color:0xffffff,
			borderColor:0x754108,
			shadowColor:0x754108,
			shadowSize:1,
			textAlign:"left",
			autoSize:"left",
			fontSize:30,
			textLeading:-6,
			multiline:true
		});
		countText.wordWrap = true;
		countText.width = countText.textWidth + 5;
		countText.x = 98;
		countText.y = 118;
		addChild(countText);
		
		if (status == 1) {
			countText.scaleX = countText.scaleY = 1.2;
			countText.x += 5;
			countText.y += 5;
		}
	}
	
	public function startPluck():void {
		intervalPluck = setInterval(randomPluck, Math.random()* 5000 + 2000);
	}
	
	private function randomPluck():void {
		layer.pluck(30, layer.width / 2, layer.height / 2 + 50);
	}
	
	public function dispose():void {
		clearInterval(intervalPluck);
		layer.pluckDispose();
	}
}