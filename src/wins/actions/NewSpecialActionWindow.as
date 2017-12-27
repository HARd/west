package wins.actions 
{
	import buttons.Button;
	import core.Load;
	import flash.display.Bitmap;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import ui.UserInterface;
	import wins.elements.TimerUnit;
	import wins.AddWindow;
	import wins.Window;
	import wins.SimpleWindow;
	
	public class NewSpecialActionWindow extends AddWindow 
	{
		public var desc:TextField;
		public var ribbon:Bitmap;
		private var timer:TimerUnit;
		public function NewSpecialActionWindow(settings:Object=null) 
		{
			if (settings == null) {
				settings = new Object();
			}
			
			settings['width'] = 570;
			settings['height'] = 450;
						
			settings['title'] = Locale.__e('flash:1396521604876');
			settings['hasPaginator'] = false;
			settings['hasButtons'] = false;
			settings['fontSize'] = 48;
			settings['fontBorderSize'] = 8;
			settings['promoPanel'] = true;
			settings['content'] = [];
			
			super(settings);
			
			changePromo(settings['pID']);
		}
		
		override public function drawBody():void {
			titleLabel.x += 75;
			
			ribbon = backingShort(625, 'ribbonYellow');
			ribbon.x = (settings.width - ribbon.width) / 2;
			ribbon.y = 250;
			
			drawImage();
			
			bodyContainer.addChild(ribbon);
			
			var bttnSettings:Object = {
				fontSize:30,
				width:194,
				height:53,
				caption:Payments.price(action.price[App.social]),
				x:(settings.width - 194) / 2,
				y:settings.height - 53 - 35,
				callback:onBuyEvent,
				addBtnContainer:false,
				addLogo:true
			};
			drawButton(bttnSettings);
			drawTimer();
			
			var text:TextField = Window.drawText(Locale.__e('flash:1456154780412'), {
				color:0xffffff,
				borderColor:0x76481a,
				textAlign:"center",
				autoSize:"center",
				fontSize:32,
				wrap:true,
				multiline:true,
				width:ribbon.width
			});
			text.wordWrap = true;
			text.x = ribbon.x + (ribbon.width - text.width) / 2;
			text.y = ribbon.y + 40;
			
			bodyContainer.addChild(text);
		}
		
		public var bitmap:Bitmap = new Bitmap();
		public function drawImage():void {
			bodyContainer.addChild(bitmap);
			var path:String = Config.getImage('actions', App.data.storage[settings.content[0].sID].view, 'png');
			Load.loading( path,onPicLoad);
		}
		
		public function onPicLoad(data:Bitmap):void
		{
			bitmap.bitmapData = data.bitmapData;
			bitmap.x = -50;// (background.width - bitmap.width) / 2;
			bitmap.y = (settings.height - bitmap.height) / 2;
			
			drawDescription();
		}
		
		public function changePromo(pID:String):void {
			action = App.data.actions[pID];
			action.id = pID;
			
			settings.content = initContent(action.items);
		}
		
		private function initContent(data:Object):Array
		{
			var result:Array = [];
			for (var sID:* in data)
				result.push({sID:sID, count:data[sID], order:action.iorder[sID]});
			
			result.sortOn('order');
			return result;
		}
		
		public function drawDescription():void 
		{			
			var separator:Bitmap = Window.backingShort(settings.width / 2 - 50, 'dividerLine', false);
			separator.x = settings.width / 2 - 15;
			separator.y = 50;
			separator.alpha = 0.5;
			bodyContainer.addChild(separator);
			
			var title:TextField = Window.drawText(App.data.storage[settings.content[0].sID].title, {
				color:0xffffff,
				borderColor:0x76481a,
				textAlign:"center",
				autoSize:"center",
				fontSize:28,
				wrap:true,
				multiline:true,
				width:ribbon.width
			});
			title.wordWrap = true;
			title.x = separator.x + (separator.width - title.width) / 2;
			title.y = 20;
			
			bodyContainer.addChild(title);
			
			var fontSize:int = 24;
			desc = Window.drawText(App.data.storage[settings.content[0].sID].description, {
				color:0x76481a,
				borderColor:0xffffff,
				textAlign:"center",
				autoSize:"center",
				fontSize:fontSize,
				wrap:true,
				multiline:true
			});
			desc.wordWrap = true;
			desc.width = 270;
			desc.x = settings.width / 2 - 50;
			desc.y = 60;
			
			bodyContainer.addChild(desc);
			
			var separator2:Bitmap = Window.backingShort(settings.width / 2 - 50, 'dividerLine', false);
			separator2.x = separator.x;
			separator2.y = desc.y + desc.textHeight + 10;
			separator2.alpha = 0.5;
			bodyContainer.addChild(separator2);
		}
		
		private function drawTimer():void {
			timer = new TimerUnit( {width:140,height:60,backGround:'glow', time:{started:action.time, duration:action.duration} } );
			bodyContainer.addChild(timer);
			timer.x = settings.width / 2 + (settings.width / 2 - timer.width) / 2 - 40;
			timer.y = 200;
			timer.start();
		}
		
		private function onBuyEvent(e:MouseEvent):void {
			if (e.currentTarget.mode == Button.DISABLED) return;
			
			priceBttn.state = Button.DISABLED;
			
			Payments.buy( {
				type:			'promo',
				id:				action.id,
				price:			int(action.price[App.social]),
				count:			1,
				title: 			Locale.__e('flash:1382952379793'),
				description: 	Locale.__e('flash:1382952380239'),
				callback:		onBuyComplete,
				error:			function():void {
					close();
				},
				icon:			getIconUrl(action)
			});
		}
		
		override public function getIconUrl(promo:Object):String {
			if (promo.hasOwnProperty('iorder')) {
				var _items:Array = [];
				for (var sID:* in promo.items) {
					_items.push( { sID:sID, order:promo.iorder[sID] } );
				}
				_items.sortOn('order');
				sID = _items[0].sID;
			}else {
				sID = promo.items[0].sID;
			}
			
			return Config.getIcon(App.data.storage[sID].type, App.data.storage[sID].preview);
		}
		
	}

}