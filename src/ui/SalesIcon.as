package ui 
{
	import core.Load;
	import core.Size;
	import com.greensock.easing.*;
	import com.greensock.TweenLite;
	import core.TimeConverter;
	import effects.Effect;
	import flash.events.MouseEvent;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.utils.clearInterval;
	import flash.utils.clearTimeout;
	import flash.utils.setInterval;
	import flash.utils.setTimeout;
	import wins.Window;
	import wins.TripleSaleWindow;
	
	public class SalesIcon extends LayerX 
	{
		public static const HEIGHT:int = 71;
		
		public var item:Object;
		public var pID:String = '';
		
		public var bg:Bitmap;
		private var icon:Bitmap;
		private var preloader:Preloader;
		private var title:TextField;
		
		public var settings:Object = {
			scale          :  1
		}
		
		public function SalesIcon(item:Object, pID:*, settings:Object = null) 
		{
			this.item = item;
			this.pID = pID;
			
			if (settings == null) {
				settings = new Object();
			} else {
				for (var property:* in settings) {
					this.settings[property] = settings[property];
				};
			}
			
			if (settings.sale == 'promo') {
				for (var key:* in item.items)
					break;
				
				settings['out'] = key;
			}
			
			var shape:Shape = new Shape();
			shape.graphics.beginFill(0xFF0000, 0.0);
			shape.graphics.drawRect(0, 0, HEIGHT, HEIGHT);
			shape.graphics.endFill();
			addChild(shape);
			
			preloader = new Preloader();
			preloader.scaleX = preloader.scaleY = 0.75;
			preloader.x = 35;
			preloader.y = 35;
			addChild(preloader);
			
			bg = new Bitmap();
			addChild(bg);
			
			var textSettings:Object = {
				text:Locale.__e("flash:1382952379793"),
				color:0xf0e6c1,
				fontSize:19,
				borderColor:0x634807,
				scale:0.5,
				textAlign:'center'
			}
			
			if (!item) {
				if (settings.sale == 'bankSale' && settings.bitmap) 
					createBankIcon();
				return;
			}
			
			if (settings.sale == 'vip') {
				createBookerIcon();
				return;
			}
			
			switch(item.preview) {
				case "interSaleBackingBlue":
					textSettings['color'] = 0xffffff;
					textSettings['borderColor'] = 0x06324b;
					textSettings['shadowColor'] = 0x06324b;
					textSettings['shadowSize'] = 1;
				break;
				case "interSaleBackingGreen":
					textSettings['color'] = 0xffffff;
					textSettings['borderColor'] = 0x3c4b06;
					textSettings['shadowColor'] = 0x3c4b06;
					textSettings['shadowSize'] = 1;
				break;
				case "interSaleBackingYellow":
					textSettings['color'] = 0xffffff;
					textSettings['borderColor'] = 0x654a00;
					textSettings['shadowColor'] = 0x654a00;
					textSettings['shadowSize'] = 1;
					break;
				default:
				//case "interSaleBackingOrange":
					textSettings['color'] = 0xffffff;
					textSettings['borderColor'] = 0x593429;
					textSettings['shadowColor'] = 0x06324b;
					textSettings['shadowSize'] = 1;
				//break;
			}
			
			/*if (item.hasOwnProperty('preview')) {
				bg.bitmapData = Window.textures[item.preview];
			} else */if (item.hasOwnProperty('backview')){
				bg.bitmapData = Window.textures[item.backview];
			} else {
				bg.bitmapData = Window.textures['interSaleBackingOrange'];
			}
			bg.smoothing = true;
			
			var flag:int = 0;
			if (item.hasOwnProperty('ishow'))
			{
				flag = int(item.ishow);
			}
			var _sid:*;
			var sidArr:Array = [];
			if (settings.sale == 'bigSale') {
				for (_sid in item.items) {
					sidArr.push(item.items[_sid].sID);
				}
				if (flag) _sid = sidArr[0];
				else _sid = sidArr[Math.round(Math.random() * (sidArr.length - 1))];
			} else if (settings.sale == 'bulk') {
				for (_sid in App.data.bulkset[1].items) {
					break;
				}
			} else {
				for (_sid in item.items) {
					sidArr.push(_sid);
				}
				if (flag) _sid = sidArr[0];
				else _sid = sidArr[Math.round(Math.random() * (sidArr.length - 1))];
			}
			
			icon = new Bitmap();
			addChild(icon);
			
			var url:String = Config.getIcon(App.data.storage[_sid].type, App.data.storage[_sid].preview);
			if (TripleSaleWindow.saleIconPath(int(pID)))
				url = TripleSaleWindow.saleIconPath(int(pID));
			if (_sid == 933) url = Config.getIcon(App.data.storage[_sid].type, 'clipper2');
			var text:String = textSettings.text;
			if (settings.sale == 'premium') {
				var action:Object = App.data.actions[pID];
				action['remain'] = Math.ceil(action.duration * action.rate - (App.time - action.time) * action.rate / 3600);
				text = Locale.__e('flash:1444122277404', String(action['remain']));
				
				App.self.setOnTimer(updateCounter);
			}
			if (settings.sale == 'bigSale' || settings.sale == 'sales' || settings.sale == 'bulk' || settings.sale == 'buffet'  || TripleSaleWindow.saleIconPath (int(pID))) {
				text = TimeConverter.timeToStr(item.duration * 3600 - (App.time - item.time));
				
				App.self.setOnTimer(updateBigsale);
				this.startGlowing();
			}
			title = Window.drawText(text, textSettings);
			title.wordWrap = true;
			title.width = 70;
			title.height = title.textHeight + 4;
			
			var scale:* = settings.scale;
			Load.loading(url, function(data:Bitmap):void {
				removeChild(preloader);
				preloader = null;
				
				icon.bitmapData = data.bitmapData;
				icon.smoothing = true;
				if (settings.scale) {
					if (settings.out == 920) 
						icon.scaleX = icon.scaleY = 0.2;
					else 
						icon.scaleX = icon.scaleY = settings.scale;
					
					while (icon.height > bg.height + 5 && settings.out != 920) {
						scale -= 0.1;
						icon.scaleX = icon.scaleY = scale;
					}
				}
				
				addChild(title);
				title.x = (bg.width - title.width)/2 - 3;
				title.y = (bg.height - title.height) / 2 + 20;
				
				if (settings.hasOwnProperty('text') && !settings.text) title.visible = false;
				
				resize();
				
				startRotate(Math.random() * 10 * 420);
			});
			
			addEventListener(MouseEvent.CLICK, onSaleOpen);
			addEventListener(MouseEvent.ROLL_OVER, onOver);
			addEventListener(MouseEvent.ROLL_OUT, onOut);
			
			tip = function():Object {
				var text:String;
				var time:int = 0;
				if (item.hasOwnProperty('begin_time')) 
					time = item.begin_time + item.duration * 3600 - App.time;
				else 
					time = item.duration * 3600 - (App.time - item.time);
				if (time < 60)
					text = Locale.__e('flash:1382952379794',[TimeConverter.timeToStr(time)]);
				else
					text = Locale.__e('flash:1382952379794', [TimeConverter.timeToStr(time)]);
					
				if (item.duration == 999 || time <= 0) {
					return {
						text:Locale.__e('flash:1396521604876'),
						timer:false
					}
				}
				
				return {
					text:text,
					timer:true
				}
			};
		}
		
		private var titleBankIcon:TextField;
		private function createBankIcon():void {
			var textSettings:Object = {
				text:Locale.__e("flash:1396521604876"),
				fontSize:19,
				color:0xffffff,
				borderColor:0x23534a,
				scale:0.5,
				textAlign:'center',
				width:90
			}
			
			bg.bitmapData = Window.textures.interSaleBackingBlue;
			bg.smoothing = true;
			
			removeChild(preloader);
			icon = settings.bitmap;
			addChild(icon);
			
			titleBankIcon = Window.drawText(textSettings.text, textSettings);
			addChild(titleBankIcon);
			
			if (settings.scale) icon.scaleX = icon.scaleY = settings.scale;
				
			titleBankIcon.x = (bg.width - titleBankIcon.width)/2 - 3;
			titleBankIcon.y = (bg.height - titleBankIcon.height)/2 + 20;
			resize();
			
			startRotate(Math.random() * 10 * 420);
			
			var timeToEnd:int = 0;
			if(App.data.money && App.data.money[App.social] && App.time >= App.data.money[App.social].date_from && App.time < App.data.money[App.social].date_to && App.data.money[App.social].enabled == 1)
				timeToEnd = App.data.money[App.social].date_to;
			else if (App.user.money > App.time)
				timeToEnd = App.user.money;
				
			addEventListener(MouseEvent.CLICK, onSaleOpen);
			addEventListener(MouseEvent.ROLL_OVER, onOver);
			addEventListener(MouseEvent.ROLL_OUT, onOut);
			
			App.self.setOnTimer(updateTimers);
			
			tip = function():Object {
				var text:String;
				var timeToEnd:int = 0;
				if(App.data.money && App.data.money[App.social] && App.time >= App.data.money[App.social].date_from && App.time < App.data.money[App.social].date_to && App.data.money[App.social].enabled == 1)
					timeToEnd = App.data.money[App.social].date_to;
				else if (App.user.money > App.time)
					timeToEnd = App.user.money;
				var time:int = timeToEnd - App.time;
				if (time < 86400)
					text = Locale.__e('flash:1382952379794',[TimeConverter.timeToStr(time)]);
				else
					text = Locale.__e('flash:1382952379794',[TimeConverter.timeToDays(time)]);
				
				return {
					title:Locale.__e("flash:1396606263756"),
					text:text,
					timer:true
				}
			};
		}
		
		private var titleBookerIcon:TextField;
		private function createBookerIcon():void {
			var textSettings:Object = {
				text:Locale.__e("flash:1396521604876"),
				fontSize:19,
				color:0xffffff,
				borderColor:0x23534a,
				scale:0.5,
				textAlign:'center',
				width:90
			}
			
			bg.bitmapData = Window.textures.interSaleBackingBlue;
			bg.smoothing = true;
			
			icon = new Bitmap();
			addChild(icon);
			
			var _sid:*;
			var sidArr:Array = [];
			for (_sid in item.items) {
				sidArr.push(_sid);
			}
			_sid = sidArr[0];
				
			var url:String = Config.getIcon(App.data.storage[_sid].type, App.data.storage[_sid].view);
			Load.loading(url, function(data:Bitmap):void {
				removeChild(preloader);
				preloader = null;
				
				icon.bitmapData = data.bitmapData;
				icon.smoothing = true;
				if (settings.scale) {	
					var scale:* = settings.scale;
					while (icon.height > bg.height + 5) {
						scale -= 0.1;
						icon.scaleX = icon.scaleY = scale;
					}
				}				
				resize();
				
				startRotate(Math.random() * 10 * 420);
			});
			
			titleBookerIcon = Window.drawText(textSettings.text, textSettings);
			addChild(titleBookerIcon);
			
			if (settings.scale) icon.scaleX = icon.scaleY = settings.scale;
				
			titleBookerIcon.x = (bg.width - titleBookerIcon.width)/2 - 3;
			titleBookerIcon.y = (bg.height - titleBookerIcon.height)/2 + 20;
				
			addEventListener(MouseEvent.CLICK, onSaleOpen);
			addEventListener(MouseEvent.ROLL_OVER, onOver);
			addEventListener(MouseEvent.ROLL_OUT, onOut);
			
			App.self.setOnTimer(updateCounterBooker);
			
			tip = function():Object {
				var text:String;
				var time:int = 0;
				time = item.begin_time + item.duration * 3600 - App.time;;
				//time = item.duration * 3600 - (App.time - item.time);
				text = Locale.__e('flash:1382952379794', [TimeConverter.timeToStr(time)]);
					
				if (item.duration == 999) {
					return {
						text:Locale.__e('flash:1396521604876'),
						timer:false
					}
				}
				
				return {
					text:text,
					timer:true
				}
			};
		}
		
		private function updateTimers():void {
			var timeToEnd:int = 0;
			if(App.data.money && App.data.money[App.social] && App.time >= App.data.money[App.social].date_from && App.time < App.data.money[App.social].date_to && App.data.money[App.social].enabled == 1)
				timeToEnd = App.data.money[App.social].date_to;
			else if (App.user.money > App.time)
				timeToEnd = App.user.money;
			var time:int = timeToEnd - App.time;
			
			titleBankIcon.text = TimeConverter.timeToStr(time);
			
			if (time <= 0) {
				titleBankIcon.visible = false;
				App.self.setOffTimer(updateTimers);
				
				App.ui.salesPanel.updateSales();
			}
		}
		
		private function updateCounterBooker():void {
			if (titleBookerIcon) {
				var action:Object = App.data.actions[pID];
				var time:int = action.begin_time + action.duration * 3600 - App.time;
				//var time:int = action.duration * 3600 - (App.time - action.time);
				
				titleBookerIcon.text = TimeConverter.timeToStr(time);
				
				if (time <= 0) {
					titleBookerIcon.visible = false;
					App.self.setOffTimer(updateCounterBooker);
					
					//App.ui.salesPanel.updateSales();
				}
			}
		}
		
		private function updateCounter():void {
			if (title) {
				var action:Object = App.data.actions[pID];
				action['remain'] = Math.ceil(action.duration * action.rate - (App.time - action.time) * action.rate / 3600);
				if (action['remain'] <= 0) {
					action['remain'] = 1;
				}
				var text:String = Locale.__e('flash:1444122277404', String(action['remain']));
				
				title.text = text;
			}
		}
		
		private function updateBigsale():void {
			if (title) {
				var text:String = TimeConverter.timeToStr(item.duration * 3600 - (App.time - item.time));
				title.text = text;
				
				if (item.duration * 3600 - (App.time - item.time) <= 0) {
					title.visible = false;					
					App.self.setOffTimer(updateBigsale);
					
					//App.ui.salesPanel.updateSales();
				}
			}
		}
		
		public function resize():void {
			if (bg && bg.bitmapData)
				Size.size(bg, HEIGHT, HEIGHT);
			
			if (icon && icon.bitmapData) {
				if (bg && bg.bitmapData) {
					icon.x = (bg.width - icon.width) / 2;
					if (icon.height > bg.height)
						icon.y = bg.y + bg.height - icon.height;
					else
						icon.y = (bg.height - icon.height) / 2;
				}else {
					icon.x = (HEIGHT - icon.width) / 2;
					icon.y = (HEIGHT - icon.height) / 2;
				}
			}
		}
		
		public function onSaleOpen(e:MouseEvent):void {
			if (settings.callback) {
				settings.callback();
			}
			else {
				if (settings.sale == 'bulk') App.ui.salesPanel.onBulksOpen(e);
				else App.ui.salesPanel.onPromoOpen(e);
			}
		}
		
		public function onOver(e:MouseEvent):void {
			Effect.light(this, 0.15);
		}
		
		public function onOut(e:MouseEvent):void {
			Effect.light(this, 0);
		}
		
		public function clear():void {
			if (settings.sale == 'bigSale') {
				hidePointing();
				return;
			}
			hideGlowing();
			hidePointing();
		}
		
		private var cont:Sprite = new Sprite();
		private var timeOut:uint = 0;
		private var time:Number = 0.5;
		public function startRotate(delay:uint, timeOut:int = 10000, time:Number = 0.5):void 
		{
			this.time = time;
			if(this.timeOut == 0){
				this.timeOut = timeOut;
				cont.addChild(bg);
				addChildAt(cont, 0);
				cont.x += bg.width / 2;
				cont.y += bg.height / 2;
				bg.x = - bg.width / 2;
				bg.y = - bg.height / 2;
			}
			
			timeout = setTimeout(rotate, delay+10);
		}
		
		public function stopRotate():void {
			if (timeout > 0)
				clearTimeout(timeout);
				
			if (tween != null)
				tween.kill();
				
			cont.rotation = 0;	
			timeout = 0;
		}
		
		private var timeout:int = 0;
		private var tween:TweenLite = null
		private function rotate():void {
			tween = TweenLite.to(cont, time, { rotation:cont.rotation + 360 / 5, onComplete:function():void {
				timeout = setTimeout(rotate, timeOut);
			}});
		}
		
		public function dispose():void {
			removeEventListener(MouseEvent.CLICK, onSaleOpen);
			removeEventListener(MouseEvent.ROLL_OVER, onOver);
			removeEventListener(MouseEvent.ROLL_OUT, onOut);
			App.self.setOffTimer(updateTimers);
			App.self.setOffTimer(updateBigsale);
			App.self.setOffTimer(updateCounter);
			App.self.setOffTimer(updateCounterBooker);
			clear();
			if (parent) parent.removeChild(this);
		}
		
	}

}