package wins 
{
	import adobe.utils.CustomActions;
	import buttons.Button;
	import core.Load;
	import core.Size;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.text.TextField;
	import units.Exchange;
	import units.Shappy;
	import units.Unit;
	import wins.elements.TopItem;
	public class TopWindow extends Window 
	{
		
		private var descLabel:TextField;
		private var back:Bitmap;
		private var container:Sprite;
		private var showMeBttn:Button;
		private var infoBttn:Button;
		public var material:Object;
		private var timerLabel:TextField;
		
		public var sections:int = 0;
		public var max:int = 100;
		
		public function TopWindow(settings:Object=null) 
		{
			if (!settings) settings = { };
			
			settings['width'] = settings['width'] || 790;
			settings['height'] = settings['height'] || 660;
			settings['title'] = settings['title'] || '';
			settings['true'] = false;
			settings['description'] = settings['description'] || '';
			settings['spliceOver'] = settings['spliceOver'] || 0;		// Обрезать все что меньше
			settings['points'] = settings['points'] || 0;
			settings['material'] = settings['material'] || 0;
			settings['background'] = settings['background'] || 'winterBacking';
			settings['mirrorDecor'] = settings['mirrorDecor'] || 'titleDecRose';
			if (((settings.target is Unit) && settings.target.sid != 1302) || (settings.target is Window)) settings['background'] = settings['background'] || 'alertBacking';
			
			max = settings['max'] || 100;
			sections = settings['sections'] || 5;
			
			if (App.data.storage[settings.material])
				material = App.data.storage[settings.material];
			
			var ownerHere:Boolean = false;
			var list:Array = [];
			for each(var object:Object in settings.content) {
				list.push(object);
			}
			settings.content = list;
			for (var i:int = 0; i < settings.content.length; i++) {
				if (settings.content[i].uID == App.user.id) {
					ownerHere = true;
					settings.content[i].points = settings.points;
				}
				if (settings.content[i].points < settings.spliceOver) {
					settings.content.splice(i, 1);
					i--;
				}
			}
			settings.content.sortOn('points', Array.NUMERIC | Array.DESCENDING);
			
			
			if (settings.content.length > max)
				settings.content.splice(max, settings.content.length - max);
			
			for (i = 0; i < settings.content.length; i++) {
				settings.content[i]['num'] = String(i + 1);
			}
			
			/*if (!ownerHere) {
				settings.content.push( {
					num:		'?',
					uID:		App.user.id,
					first_name:	App.user.first_name,
					last_name:	App.user.last_name,
					attraction:	settings.target.kicks
				});
			}*/
			
			super(settings);
			
		}
		
		public const MARGIN:int = 5;
		override public function drawBody():void 
		{
			titleLabel.y += 10;
			
			back = new Bitmap(new BitmapData(settings.width - 106, 450, true, 0xffff00));
			back.x = settings.width/2 - back.width/2;
			back.y = 85;
			bodyContainer.addChild(back);
			
			descLabel = drawText(settings.description, {
				textAlign:		'center',
				fontSize:		21,
				color:			0xe8e8e6,
				borderColor:	0x542f14,
				multiline:		true,
				wrap:			true,
				width:			480
			});
			descLabel.x = (settings.width - descLabel.width) / 2;
			descLabel.y = 15;
			bodyContainer.addChild(descLabel);
			
			var separator:Bitmap = Window.backingShort(back.width - 10, 'dividerLine', false);
			separator.x = back.x + 10;
			separator.y = back.y;
			separator.alpha = 0.5;
			bodyContainer.addChild(separator);
			
			var separator2:Bitmap = Window.backingShort(back.width - 10, 'dividerLine', false);
			separator2.x = back.x + 10;
			separator2.y = back.y + back.height;
			separator2.alpha = 0.5;
			bodyContainer.addChild(separator2);
			
			var skip:Boolean = true;
			var posY:int = 0;
			for (var i:int = 0; i < sections; i++) {
				var height:int = Math.floor((back.height - MARGIN * 2) / sections);
				if (i == 0 || i == sections - 1) height += MARGIN;
				var bmd:BitmapData = new BitmapData(back.width, height, true, 0x66FFFFFF);
				
				if (!skip) {
					back.bitmapData.draw(bmd, new Matrix(1, 0, 0, 1, 0, posY));
					skip = true;
				}else {
					skip = false;
				}
				posY += bmd.height;
			}
			
			container = new Sprite();
			container.x = back.x;
			container.y = back.y;
			bodyContainer.addChild(container);
			
			/*showMeBttn = new Button( {
				width:		100,
				height:		36,
				caption:	Locale.__e('flash:1419439510724'),
				radius:		12,
				fontSize:	20
			});
			showMeBttn.x = 60;
			showMeBttn.y = settings.height - showMeBttn.height - 60;
			showMeBttn.addEventListener(MouseEvent.CLICK, showMe);
			bodyContainer.addChild(showMeBttn);*/
			
			infoBttn = new Button({
				width:		130,
				height:		45,
				fontSize:	20,
				caption:	Locale.__e('flash:1440499603885')
			});
			infoBttn.x = descLabel.x + descLabel.width;
			infoBttn.y = descLabel.y + descLabel.height * 0.5 - infoBttn.height * 0.5;
			bodyContainer.addChild(infoBttn);
			infoBttn.addEventListener(MouseEvent.CLICK, onInfo);
			
			if (settings.target is Shappy && settings.target.topID && settings.target.topID >= 15) infoBttn.visible = false;
			
			var cont:Sprite = new Sprite();
			bodyContainer.addChild(cont);
			
			var rateDescLabel:TextField = drawText(Locale.__e('flash:1440494930989') + ':', {
				autoSize:		'center',
				textAlign:		'center',
				color:			0xf0feff,
				borderColor:	0x562d19,
				fontSize:		21
			});
			rateDescLabel.x = 0;
			rateDescLabel.y = 4;
			cont.addChild(rateDescLabel);
			
			var rateIcon:Bitmap;
			if (material) {
				rateIcon = new Bitmap();
				cont.addChild(rateIcon);
				Load.loading(Config.getIcon(material.type, material.preview), function(data:Bitmap):void {
					rateIcon.bitmapData = data.bitmapData;
					rateIcon.smoothing = true;
					Size.size(rateIcon, 30, 30);
					rateIcon.x = rateDescLabel.x + rateDescLabel.width + 6;
					rateIcon.y = rateDescLabel.y + rateDescLabel.height * 0.5 - rateIcon.height * 0.5;
				});
			}
			
			var rateLabel:TextField = drawText(String(settings.points), {
				width:			200,
				textAlign:		'left',
				color:			0x77feff,
				borderColor:	0x043b74,
				fontSize:		28
			});
			rateLabel.x = (rateIcon) ? rateDescLabel.x + rateDescLabel.width + 40 : rateDescLabel.x + rateDescLabel.width + 10;
			cont.addChild(rateLabel);
			cont.x = 90;
			cont.y = settings.height - cont.height - 80;
			
			
			paginator.onPageCount = sections;
			paginator.itemsCount = settings.content.length;
			paginator.update();
			paginator.x -= 40;
			paginator.y += 12;
			
			drawTimer();
			
			contentChange();
			
			if (ExchangeWindow.depthShow > 0 || HappyWindow.depthShow > 0) {
				ExchangeWindow.depthShow = 0;
				HappyWindow.depthShow = 0;
				onInfo();
			}
		}
		
		public function onInfo(e:MouseEvent = null):void {
			if (infoBttn.mode == Button.DISABLED)
				return;
				
			if (settings.onInfo != null)
				settings.onInfo();
		}
		
		public function showMe(e:MouseEvent):void {
			for (var i:int = 0; i < settings.content.length; i++) {
				if (String(settings.content[i].uID) == App.user.id) {
					break;
				}
			}
			
			if (paginator.page != Math.floor(i / sections)) {
				paginator.page = Math.floor(i / sections);
				paginator.update();
				contentChange();
			}
		}
		
		public var items:Vector.<TopItem> = new Vector.<TopItem>;
		override public function contentChange():void {
			clear();
			
			var item:TopItem;
			for (var i:int = 0; i < sections; i++) {
				if (paginator.page * sections + i >= settings.content.length) continue;
				var params:Object = settings.content[paginator.page * sections + i];
				
				params['width'] = back.width;
				params['height'] = Math.floor((back.height - MARGIN * 2) / sections);
				
				item = new TopItem(params, this);
				item.x = 0;
				item.y = MARGIN + i * Math.floor((back.height - MARGIN * 2) / sections);
				container.addChild(item);
				items.push(item);
			}
			
			if (items.length < sections) {
				for each (var usr:* in settings.content) {
					if (usr.uID == App.user.id) {
						item = new TopItem(usr, this);
						item.x = 0;
						item.y = MARGIN + i * Math.floor((back.height - MARGIN * 2) / sections);
						container.addChild(item);
						items.push(item);
					}
				}
			}
		}
		private function clear():void {
			while (items.length > 0) {
				var item:TopItem = items.shift();
				item.dispose();
			}
		}
		
		private var timerBacking:Bitmap;
		private var timerDescLabel:TextField;
		private function drawTimer():void {
			timerBacking = new Bitmap(Window.textures.iconGlow, 'auto', true);
			timerBacking.scaleX = 0.6;
			timerBacking.scaleY = 1;
			timerBacking.x = 80;
			timerBacking.y = -20;
			timerBacking.alpha = 0.7;
			bodyContainer.addChild(timerBacking);
			
			var text:String = Locale.__e('flash:1382952379794').replace('%s', '');
			timerDescLabel = drawText(text, {
				width:			timerBacking.width,
				textAlign:		'center',
				fontSize:		25,
				color:			0xfdfde5,
				borderColor:	0x7c523a,
				shadowSize:		1
			});
			timerDescLabel.x = timerBacking.x + (timerBacking.width - timerDescLabel.width) / 2;
			timerDescLabel.y = timerBacking.y + 20;
			bodyContainer.addChild(timerDescLabel);
			
			timerLabel = drawText('', {
				width:			200,
				textAlign:		'center',
				fontSize:		38,
				color:			0xfde676,
				borderColor:	0x743e1a,
				shadowSize:		2
			});
			timerLabel.x = timerDescLabel.x + timerDescLabel.width * 0.5 - timerLabel.width * 0.5;
			timerLabel.y = timerDescLabel.y + timerDescLabel.height - 5;
			bodyContainer.addChild(timerLabel);
			
			App.self.setOnTimer(timer);
		}
		private function timer():void {
			if (timerLabel) {
				var time:int = settings.target.expire - App.time;
				if (time < 0) {
					App.self.setOffTimer(timer);
					timerLabel.visible = false;
					timerBacking.visible = false;
					timerDescLabel.visible = false;
					time = 0;
					
					if (Exchange.take == 0)
						infoBttn.showGlowing();
				}
				timerLabel.text = TimeConverter.timeToStr(time);
				
				if (time <= 0) {
					App.self.setOffTimer(timer);
					timerLabel.visible = false;
					timerDescLabel.visible = false;
					timerBacking.visible = false;
				}
			}
		}
		
		override public function dispose():void {
			clear();
			if (infoBttn) infoBttn.removeEventListener(MouseEvent.CLICK, onInfo);
			App.self.setOffTimer(timer);
			
			super.dispose();
		}
	}

}