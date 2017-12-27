package wins 
{
	import buttons.Button;
	import buttons.ImageButton;
	import core.Load;
	import core.Numbers;
	import core.Post;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	public class ThanksgivingEventWindow extends Window 
	{
		public static var info:Object = null;
		public static var MONEY:int = 0;
		public static var expireTop:int = 0;
		
		public static var rate:int = 0;
		public static var rates:Object = { };
		public static var isInTop:Boolean = false;
		
		public var topBttn:Button;
		private var timerLabel:TextField;
		private var infoBttn:Button;
		
		public var topx:int = 100;
		public var expire:int = 0;
		
		private var progressBar:ProgressBar;
		public var progressBacking:Bitmap;
		private var textTitle:TextField;
		
		private var topitems:Array = [];
		public static var topID:int = 1;
		
		public function ThanksgivingEventWindow(settings:Object=null) 
		{
			if (settings == null) {
				settings = new Object();
			}
			
			topID = App.user.topID;
			info = App.data.top[topID];
			MONEY = info.target;
			//if (info.expire.hasOwnProperty(App.social))
				expire = info.expire.e;
			
			expireTop = expire;	
				
			settings['width'] = 800;
			settings['height'] = 680;
			settings['shadowSize'] = 3;
			settings['shadowBorderColor'] = 0x554234;
			settings['shadowColor'] = 0x554234;
			settings['background'] = 'indianBacking';
			
			settings['title'] = Locale.__e('flash:1447404360344');
			settings['hasPaginator'] = false;
			settings['hasButtons'] = false;
			super(settings);
			
			getRate();
		}
		
		override public function drawBody():void {
			titleLabel.y += 15;
			
			var description:TextField = drawText(Locale.__e('flash:1447405163327'), {
				color:			0xffffff,
				borderColor:	0x612908,
				fontSize:		20,
				textAlign:		'center',
				autoSize:		'center',
				multiline:		true
			});
			description.wordWrap = true;
			description.width = 300;
			description.x = (settings.width - description.width) / 2;
			description.y = 50;
			bodyContainer.addChild(description);
			
			drawTimer();
			
			infoBttn = new Button({
				width:		100,
				height:		38,
				fontSize:	20,
				caption:	Locale.__e('flash:1440499603885')
			});
			infoBttn.x = description.x + description.width + 70;
			infoBttn.y = description.y + description.height * 0.5 - infoBttn.height * 0.5;
			bodyContainer.addChild(infoBttn);
			infoBttn.addEventListener(MouseEvent.CLICK, onInfo);
			
			var separator:Bitmap = Window.backingShort(settings.width - 110, 'dividerLine', false);
			separator.x = 60;
			separator.y = 120;
			separator.alpha = 0.5;
			bodyContainer.addChild(separator);
			
			var separator2:Bitmap = Window.backingShort(settings.width - 110, 'dividerLine', false);
			separator2.scaleY = -1;
			separator2.x = 60;
			separator2.y = 390;
			separator2.alpha = 0.5;
			bodyContainer.addChild(separator2);
			
			topBttn = new Button( {
				width:		170,
				height:		44,
				caption:	Locale.__e('flash:1447408179976'),
				radius:		12,
				fontSize:	24
			});
			topBttn.x = (settings.width - topBttn.width) / 2;
			topBttn.showGlowing();			
			topBttn.addEventListener(MouseEvent.CLICK, openTop);
			
			drawTopItems();
			drawBonusItems();
		}
		
		private var timerBacking:Bitmap;
		private var timerDescLabel:TextField;
		private function drawTimer():void {
			timerBacking = new Bitmap(Window.textures.iconGlow, 'auto', true);
			timerBacking.scaleX = 0.6;
			timerBacking.scaleY = 1;
			timerBacking.x = 90;
			timerBacking.y = 15;
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
				var time:int = expire - App.time;
				if (time < 0) {
					App.self.setOffTimer(timer);
					timerLabel.visible = false;
					timerBacking.visible = false;
					timerDescLabel.visible = false;
					time = 0;
				}
				timerLabel.text = TimeConverter.timeToStr(time);
			}
		}
		
		public var items:Vector.<TopItem> = new Vector.<TopItem>;
		private var txt:TextField;
		public function drawTopItems():void {
			if (!isInTop) {
				if (!txt) {
					txt = drawText(Locale.__e('flash:1447670366224'), {
						color:		0x7a3815,
						borderColor:0xfcfaed,
						multiline:	true,
						fontSize:	26,
						textAlign:	'center',
						autoSize:	'center'
					});
					txt.wordWrap = true;
					txt.width = 350;
					txt.x = (settings.width - txt.width) / 2;
					txt.y = 180;
					bodyContainer.addChild(txt);
				}
				
				topBttn.y = txt.y + txt.textHeight + 30;
				bodyContainer.addChild(topBttn);
				return;
			}
			
			if (txt) {
				bodyContainer.removeChild(txt);
				txt = null;
			}
			topitems.sortOn('points', Array.NUMERIC | Array.DESCENDING);
			var Ys:int = 120;
			for (var i:int = 0; i < topitems.length; i++) {
				var params:Object = topitems[i];
				
				params['width'] = 640;
				params['height'] = 90;
				params['num'] = params.position + 1;
				
				var item:TopItem = new TopItem(params, this);
				item.x = 80;
				item.y = Ys;
				Ys += 90;
				bodyContainer.addChild(item);
				items.push(item);
			}
			topBttn.y = 380;
			bodyContainer.addChild(topBttn);
		}
		
		public var points:Array;
		private var prizesItems:Array = [];
		public function drawBonusItems():void {
			var rateItem:RateItem = new RateItem(this);
			rateItem.x = 55;
			rateItem.y = 415;
			bodyContainer.addChild(rateItem);
			
			progressBacking = Window.backingShort(settings.width - 270 - 16, "progBarBacking");
			progressBacking.x = 220;
			progressBacking.y = 530;
			bodyContainer.addChild(progressBacking);
			
			points = [];
			for (var itm:String in info.abonus.p) {
				points.push(info.abonus.p[itm]);
			}
			
			progressBar = new ProgressBar( {
				win:		this,
				width:		settings.width - 270,
				isTimer:    false
			});
			progressBar.x = progressBacking.x - 8;
			progressBar.y = progressBacking.y - 4;
			bodyContainer.addChild(progressBar);
			setProgress();
			progressBar.start();
			
			var numberOfParts:int = points.length;
			for (var i:int = 1; i < numberOfParts + 1; i++) {
				var divider:Shape = new Shape();
				divider.graphics.beginFill(0xffffff, 1);
				divider.graphics.lineStyle(2, 0x754209, 1, false);
				divider.graphics.drawRoundRect(0, 0, 6, 36, 6, 6);
				divider.graphics.endFill();
				divider.x = progressBar.x + (progressBar.width - 60) * i / numberOfParts;
				divider.y = progressBar.y;
				bodyContainer.addChild(divider);
				
				/*var price:Object = getReward(i - 1);
				var count:int = price.cnt;
				var material:int = price.sid;
				var check:Boolean = false;
				var drawButton:Boolean = false;
				
				var curPrize:int = -1;
				if (App.user.top.hasOwnProperty(topID) && App.user.top[topID].hasOwnProperty('abonus')) {
					curPrize = App.user.top[topID].abonus;
				}
				if (App.user.top.hasOwnProperty(topID) && i - 1 > curPrize && App.user.top[topID].count > info.abonus.p[i - 1]) drawButton = true;
				var prize:PrizeItem = new PrizeItem(this, { sID:material, count:count, check:check , button:drawButton} );
				prize.x = divider.x - 25;
				prize.y = progressBar.y - 70;
				bodyContainer.addChild(prize);
				prizesItems.push(prize);*/
				
				var textLabel:TextField = drawText(points[i - 1], {
					fontSize:			28,
					autoSize:			'center',
					textAlign:			'center',
					color:				0xfbe458,
					borderColor:		0x744309
				});
				textLabel.x = divider.x + divider.width * 0.5 - textLabel.width * 0.5;
				if (i == numberOfParts)
					textLabel.x -= 10;
				textLabel.y = divider.y + divider.height + 3;
				bodyContainer.addChild(textLabel);
			}
		}
		
		public function setProgress():void {
			redrawPrizeItems();
			
			if (progressBar)
				progressBar.progress = progress();
			
			function progress():Number {
				var value:Number = 0;
				var count:int = 0;
				if (App.user.top.hasOwnProperty(topID) && App.user.top[topID].hasOwnProperty('count')) count = App.user.top[topID].count;
				var prev:int = 0;
				var maxPercent:Number = (progressBar.width - 65) / progressBar.width;
				
				for (var i:int = 0; i < points.length; i++) {
					if (points[i] > count) {
						value = maxPercent * (i / points.length) + (1 / points.length) * maxPercent * ((count - prev) / (points[i]/*.count*/ - prev));
						break;
					}
					
					prev = points[i];
				}
				
				if (value == 0 && i >= points.length - 1) {
					value = maxPercent * (i / points.length) + maxPercent * (1 / points.length) * ((count - prev) / prev);
				}
				
				if (value > 1) value = 1;
				if (!value) value = 0;
				
				return value;
			}
		}
		
		private function getReward(lvl:int = 0):Object {			
			var items:Object;
			var counts:Object;
			var s:*;
			var count:*;
			if (info.abonus.t.hasOwnProperty(lvl)) {
				items = App.data.treasures[info.abonus.t[lvl]][info.abonus.t[lvl]].item;
				counts = App.data.treasures[info.abonus.t[lvl]][info.abonus.t[lvl]].count;
				for each(s in items) {
					break;
				}
				for each(count in counts) {
					break;
				}
			}else {
				return {};
			}
			
			return {cnt:count, sid:s};
		}
		
		private function redrawPrizeItems():void {
			if (prizesItems.length > 0) {
				for each (var prz:PrizeItem in prizesItems) {
					prz.dispose();
				}
			}
			prizesItems = [];
			var numberOfParts:int = points.length;
			for (var i:int = 1; i < numberOfParts + 1; i++) {
				var price:Object = getReward(i - 1);
				var count:int = price.cnt;
				var material:int = price.sid;
				var check:Boolean = false;
				var drawButton:Boolean = false;
				
				var curPrize:int = -1;
				if (App.user.top.hasOwnProperty(topID) && App.user.top[topID].hasOwnProperty('abonus')) {
					curPrize = App.user.top[topID].abonus;
				}
				if (App.user.top.hasOwnProperty(topID) && i - 1 > curPrize && App.user.top[topID].count >= info.abonus.p[i - 1]) drawButton = true;
				var prize:PrizeItem = new PrizeItem(this, { sID:material, count:count, check:check , button:drawButton} );
				prize.x =  progressBar.x + (progressBar.width - 60) * i / numberOfParts - 25;
				prize.y = progressBar.y - 70;
				bodyContainer.addChild(prize);
				prizesItems.push(prize);
			}
		}
		
		public function onInfo(e:MouseEvent):void {
			if (infoBttn.mode == Button.DISABLED)
				return;
				
			new InfoWindow( {
				popup:true,
				qID:'100800'
			}).show();
		}
		
		protected function openTop(e:MouseEvent):void {
			if (rateChecked == 0) return;
			
			new TopWindow( {
				title:			settings.title,
				description:	Locale.__e('flash:1440518562248'),
				points:			ThanksgivingEventWindow.rate,
				max:			topx,
				target:			this,
				content:		ThanksgivingEventWindow.rates,
				material:		MONEY,
				popup:			true,
				onInfo:			function():void {
					new InfoWindow( {
						popup:true,
						qID:'100800'
					}).show();
				}
			}).show();
		}
		
		// Rate
		public static var rateChecked:int = 0;
		public static var rateSended:Object = {};
		private var onUpdateRate:Function;
		private function getRate(callback:Function = null):void {
			onUpdateRate = callback;
			
			Post.send( {
				ctr:		'top',
				act:		'users',
				uID:		App.user.id,
				tID:		topID
			}, function(error:int, data:Object, params:Object):void {
				if (error) return;
				
				rateChecked = App.time;
				
				if (data.hasOwnProperty('users')) {
					ThanksgivingEventWindow.rates = data['users'] || { };
					
					for (var id:* in ThanksgivingEventWindow.rates) {
						if (App.user.id == id) {
							ThanksgivingEventWindow.rate = ThanksgivingEventWindow.rates[id]['points'];
							isInTop = true;
						}
						
						ThanksgivingEventWindow.rates[id]['uID'] = id;
					}
				}
				
				if (App.user.top.hasOwnProperty(topID)) {
					ThanksgivingEventWindow.rate = App.user.top[topID].count;
				}
				
				//if (ThanksgivingEventWindow.rate > 50) 
					//isInTop = true;
				
				if (Numbers.countProps(ThanksgivingEventWindow.rates) > topx) {
					var array:Array = [];
					for (var s:* in ThanksgivingEventWindow.rates) {
						array.push(ThanksgivingEventWindow.rates[s]);
					}
					array.sortOn('points', Array.NUMERIC | Array.DESCENDING);
					array = array.splice(0, topx);
					for (s in ThanksgivingEventWindow.rates) {
						if (array.indexOf(ThanksgivingEventWindow.rates[s]) < 0)
							delete ThanksgivingEventWindow.rates[s];
					}
				}
				
				if (onUpdateRate != null) {
					onUpdateRate();
					onUpdateRate = null;
				}
				
				if (isInTop) {
					var list:Array = [];
					var top:Array = [];
					var ind:int = 0;
					for each (var rate:* in ThanksgivingEventWindow.rates) {
						top.push(rate);
					}
					top.sortOn('points', Array.NUMERIC | Array.DESCENDING);
					for (var i:int = 0; i < top.length; i ++) {
						if (top[i].uID == App.user.id) {
							ind = i;
							break;
						}
					}
					if (ind == 0) {
						topitems = getItems(ind, ind + 1, ind + 2, top);
					}else if (ind == top.length - 1) {
						if (ind == 1) topitems = getItems(ind - 1, ind, -1, top);
						else topitems = getItems(ind - 2, ind - 1, ind, top);
					}else {
						topitems = getItems(ind - 1, ind, ind + 1, top);
					}
				}
				
				drawTopItems();
			});
		}
		
		private function getItems(p1:int, p2:int, p3:int, list:Array):Array {
			var buf:Array = [];
			if (p1 < list.length) {
				var itm1:Object = list[p1];
				itm1['position'] = p1;
				buf.push(itm1);
			}
			if (p2 < list.length) {
				var itm2:Object = list[p2];
				itm2['position'] = p2;
				buf.push(itm2);
			}
			if (p3 < list.length && p3 != -1) {
				var itm3:Object = list[p3];
				itm3['position'] = p3;
				buf.push(itm3);
			}
			return buf;
		}
		
	}

}

import buttons.Button;
import buttons.ImageButton;
import com.greensock.easing.Cubic;
import com.greensock.TweenLite;
import core.AvaLoad;
import core.Load;
import core.Post;
import core.Size;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.text.TextField;
import flash.utils.setTimeout;
import ui.UserInterface;
import wins.PurchaseWindow;
import wins.ThanksgivingEventWindow;
import wins.Window;

internal class TopItem extends LayerX {
	
	private var backing:Shape;
	private var imageBack:Sprite;
	public var image:Sprite;
	private var photoBack:Shape;
	private var numLabel:TextField;
	private var nameLabel:TextField;
	private var rateLabel:TextField;
	private var preloader:Preloader;
	private var travelBttn:Button;
	
	private var bgColor:uint = 0xFFFFFF;
	private var bgAlpha:Number = 0;
	
	public var uID:*;
	public var window:*;
	
	public function TopItem(params:Object, window:*) {
		
		uID = params['uID'];
		this.window = window;
		
		if (uID == App.user.id) {
			bgColor = 0x33cc00;
			bgAlpha = 0.2;
		}
		
		backing = new Shape();
		backing.x = 5;
		backing.graphics.beginFill(bgColor, 1);
		backing.graphics.drawRoundRect(0, 0, params.width - 10, params.height, 20, 20); //drawRect(0, 0, params.width, params.height);
		backing.graphics.endFill();
		addChild(backing);
		backing.alpha = bgAlpha;
		
		numLabel = Window.drawText(params.num, {
			color:			0x7a4004,
			borderColor:	0xffffff,
			fontSize:		40,
			textAlign:		'center',
			width:			140
		});
		numLabel.x = -20;
		numLabel.y = (backing.height - numLabel.height) / 2 + 4;
		addChild(numLabel);
		
		var name:String = '';
		if (params['aka']) {
			name = params.aka;
			name = name.replace(' ', '\n');
		}else {
			name = params.first_name + '\n' + params.last_name;
		}
		
		nameLabel = Window.drawText(name, {
			color:			0x723d1b,
			borderColor:	0xfff8f3,
			fontSize:		26,
			textAlign:		'left',
			autoSize:		'left',
			multiline:		true,
			wrap:			true
		});
		nameLabel.x = 180;
		nameLabel.y = (backing.height - nameLabel.height) / 2 - 2;
		addChild(nameLabel);
		
		var rateIcon:Bitmap;
		if (ThanksgivingEventWindow.MONEY) {
			rateIcon = new Bitmap();
			rateIcon.x = nameLabel.x + 150;
			addChild(rateIcon);
			Load.loading(Config.getIcon(App.data.storage[ThanksgivingEventWindow.MONEY].type, App.data.storage[ThanksgivingEventWindow.MONEY].preview), function(data:Bitmap):void {
				rateIcon.bitmapData = data.bitmapData;
				rateIcon.smoothing = true;
				Size.size(rateIcon, 50, 50);
				rateIcon.y = (backing.height - rateIcon.height) / 2;
			});
		}
		
		rateLabel = Window.drawText(params.points, {
			color:			0xf0ff69,
			borderColor:	0x434629,
			borderSize:		2,
			fontSize:		40,
			textAlign:		'left',
			autoSize:		'center',
			width:			240,
			shadowSize:		2
		});
		rateLabel.x = (rateIcon) ? (rateIcon.x + 60) : (nameLabel.x + 160);
		rateLabel.y = (backing.height - rateLabel.height) / 2 + 4;
		addChild(rateLabel);
		
		travelBttn = new Button( {
			width:		130,
			height:		47,
			caption:	Locale.__e('flash:1419440810299'),
			fontSize:	21,
			radius:		12
		});
		travelBttn.x = backing.width - travelBttn.width - 25;
		travelBttn.y = (backing.height - travelBttn.height) / 2;
		travelBttn.addEventListener(MouseEvent.CLICK, travel);
		addChild(travelBttn);
		
		if (params['take'] == 1) {
			var checkMark:Bitmap = new Bitmap(Window.textures.checkMark);
			checkMark.x = backing.width - checkMark.width - 50;
			checkMark.y = backing.y + (backing.height - checkMark.height) / 2;
			addChild(checkMark);
			
			travelBttn.visible = false;
			
		}else if (App.user.id == String(uID) || !App.user.friends.data.hasOwnProperty(uID)) {
			travelBttn.state = Button.DISABLED;
			travelBttn.y = (backing.height - travelBttn.height) / 2 - 8;
			
			var infoLabel:TextField = Window.drawText((uID == App.user.id) ? Locale.__e('flash:1419500839285') : Locale.__e('flash:1419500809271'), {
				color:			0x7a4004,
				borderColor:	0xffffff,
				fontSize:		20,
				textAlign:		'center',
				autoSize:		'center'
			});
			infoLabel.x = travelBttn.x + (travelBttn.width - infoLabel.width) / 2;
			infoLabel.y = travelBttn.y + travelBttn.height + 2;
			addChild(infoLabel);
		}
		
		imageBack = new Sprite();
		imageBack.graphics.beginFill(0xba944d, 1);
		imageBack.graphics.drawRoundRect(0, 0, 68, 68, 20, 20);
		imageBack.graphics.endFill();
		imageBack.x = 95;
		imageBack.y = (backing.height - imageBack.height) / 2;
		addChild(imageBack);
		
		image = new Sprite();
		addChild(image);
		
		preloader = new Preloader();
		preloader.scaleX = preloader.scaleY = 0.6;
		preloader.x = imageBack.x + imageBack.width / 2;
		preloader.y = imageBack.y + imageBack.height / 2;
		addChild(preloader);
		
		new AvaLoad(params.photo, onLoad);
		
		var star:Bitmap = new Bitmap(UserInterface.textures.expIcon);
		star.smoothing = true;
		star.scaleX = star.scaleY = 0.8;
		star.x = imageBack.x + imageBack.width - star.width + 6;
		star.y = imageBack.y + imageBack.height - star.height + 4;
		addChild(star);
		
		var level:TextField = Window.drawText(String(params.level || 0), {
			fontSize:		20,
			color:			0x643113,
			borderSize:		0,
			autoSize:		'left',
			multiline:		true,
			wrap:			true
		});
		level.x = star.x + star.width / 2 - level.width / 2 - 1;
		level.y = star.y + 4;
		addChild(level);
		
		addEventListener(MouseEvent.MOUSE_OVER, onOver);
		addEventListener(MouseEvent.MOUSE_OUT, onOut);
	}
	
	private function onOver(e:MouseEvent):void {
		backing.alpha += 0.1;
	}
	private function onOut(e:MouseEvent):void {
		backing.alpha = bgAlpha;
	}
	
	private function travel(e:MouseEvent):void {
		if (travelBttn.mode == Button.DISABLED) return;
		
		Travel.friend = App.user.friends.data[uID];
		Travel.onVisitEvent(User.HOME_WORLD); 
		window.close();
	}
	
	private function onLoad(data:*):void {
		removeChild(preloader);
		preloader = null;
		
		var bitmap:Bitmap = new Bitmap(data.bitmapData, 'auto', true);
		bitmap.width = bitmap.height = 64;
		image.addChild(bitmap);
		
		var maska:Shape = new Shape();
		maska.graphics.beginFill(0xba944d, 1);
		maska.graphics.drawRoundRect(0, 0, 64, 64, 18, 18);
		maska.graphics.endFill();
		image.addChild(maska);
		
		bitmap.mask = maska;
		
		image.x = imageBack.x + (imageBack.width - image.width) / 2;
		image.y = imageBack.y + (imageBack.height - image.height) / 2;
	}
	
	public function dispose():void {
		removeEventListener(MouseEvent.MOUSE_OVER, onOver);
		removeEventListener(MouseEvent.MOUSE_OUT, onOut);
		
		if (parent) parent.removeChild(this);
	}
}

import wins.Window;
internal class RateItem extends LayerX {
	private var background:Bitmap;
	private var rateLabel:TextField;
	private var window:*;
	private var sprite:LayerX = new LayerX();
	public function RateItem(window:*) {
		this.window = window;
		addChild(sprite);
		background = Window.backing(135, 165, 50, 'itemBacking');
		sprite.addChild(background);
		
		var moneyIcon:Bitmap = new Bitmap();
		sprite.addChild(moneyIcon);
			
		var points:String = '0';
		if (App.user.top.hasOwnProperty(ThanksgivingEventWindow.topID) && App.user.top[ThanksgivingEventWindow.topID].hasOwnProperty('count')) points = String(App.user.top[ThanksgivingEventWindow.topID].count);
		rateLabel = Window.drawText('x' + points, {
			color:			0xeffb67,
			borderColor:	0x45471f,
			borderSize:		2,
			fontSize:		36,
			textAlign:		'left',
			autoSize:		'center',
			width:			240,
			shadowSize:		2
		});
		sprite.addChild(rateLabel);
		
		Load.loading(Config.getIcon(App.data.storage[ThanksgivingEventWindow.MONEY].type, App.data.storage[ThanksgivingEventWindow.MONEY].preview), function(data:*):void {
			moneyIcon.bitmapData = data.bitmapData;
			moneyIcon.x = (background.width - moneyIcon.width) / 2;
			moneyIcon.y = 15;
			moneyIcon.smoothing = true;
			
			
			rateLabel.x = moneyIcon.x + moneyIcon.width - rateLabel.textWidth + 5;
			rateLabel.y = moneyIcon.y + moneyIcon.height - 25;
		});
		
		var addBttn:ImageButton = new ImageButton(Window.texture('interAddBttnGreen'));
		addBttn.x = (background.width - addBttn.width) / 2;
		addBttn.y = background.height - addBttn.height / 1.5;
		addChild(addBttn);
		
		addBttn.addEventListener(MouseEvent.CLICK, onAddMoney);
		
		App.self.addEventListener(AppEvent.ON_CHANGE_STOCK, onStockChange);
		
		sprite.tip = function():Object {
			return {
				title:App.data.storage[ThanksgivingEventWindow.MONEY].title,
				text:App.data.storage[ThanksgivingEventWindow.MONEY].description
			}
		}
	}
	
	private function onAddMoney(e:MouseEvent):void {
		new PurchaseWindow( {
			width:595,
			itemsOnPage:2,
			content:PurchaseWindow.createContent("Energy", {view:'postcard'}),
			title:Locale.__e("top:1:title"),
			fontBorderColor:0xd49848,
			shadowColor:0x553c2f,
			shadowSize:4,
			description:Locale.__e("flash:1382952379757"),
			popup: true,
			closeAfterBuy: false,
			callback:function(sID:int):void {
			}
		}).show();
	}
	
	private function onStockChange(e:AppEvent):void 
	{
		var points:String = '0';
		if (App.user.top.hasOwnProperty(ThanksgivingEventWindow.topID) && App.user.top[ThanksgivingEventWindow.topID].hasOwnProperty('count')) points = String(App.user.top[ThanksgivingEventWindow.topID].count);
		rateLabel.text = 'x' + points;
		
		window.setProgress();
	}
}

import buttons.Button;
import buttons.MoneyButton;
import core.Load;
import core.Size;
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.text.TextField;
import ui.Hints;
import ui.UserInterface;
import wins.SemiEventWindow;
import wins.SimpleWindow;
import wins.ShopWindow;
import wins.TechnologicalWindow;
import wins.Window;

internal class PrizeItem extends Sprite
{
	public var window:*;
	public var item:Object;
	private var bitmap:Bitmap;
	private var background:Bitmap = new Bitmap();
	private var sID:uint;
	private var count:uint;
	private var info:Object;
	private var check:Boolean = false;
	
	public function PrizeItem(window:*, data:Object)
	{
		this.sID = data.sID;
		this.count = data.count;
		this.check = data.check;
		this.item = App.data.storage[data.sID];
		this.window = window;
		
		sprite = new LayerX();
		bitmap = new Bitmap();
		
		background = new Bitmap(new BitmapData(70, 70, true, 0xffffff));
		background.x = -10;
		background.y = -10;
		sprite.addChild(background);
			
		var shape:Shape = new Shape();
		shape.graphics.beginFill(0xc6c7b9, 1);
		shape.graphics.drawCircle(35, 35, 35);
		shape.graphics.endFill();
		background.bitmapData.draw(shape);
		
		sprite.tip = function():Object {
			return {
				title: item.title,
				text: item.description
			};
		}
		sprite.addChild(bitmap);
		addChild(sprite);
		
		Load.loading(Config.getIcon(item.type, item.preview), onLoad);
		
		drawCount();
		if (data.button == true) drawButton();
	}
	
	private var sprite:LayerX;
	private function onLoad(data:Bitmap):void {		
		bitmap.bitmapData = data.bitmapData;
		Size.size(bitmap, 50, 50);
		bitmap.smoothing = true;
	}
	
	private var takeBttn:Button;
	private function drawButton():void {
		takeBttn = new Button( {
			width:		75,
			height:		27,
			caption:	Locale.__e('flash:1382952379737'),
			radius:		12,
			fontSize:	20
		});
		takeBttn.x = background.x + (background.width - takeBttn.width) / 2;
		takeBttn.y = 45;
		sprite.addChild(takeBttn);
		takeBttn.addEventListener(MouseEvent.CLICK, onTake);
	}
	
	private function onTake(e:MouseEvent):void {
		takeBttn.visible = false;
		Post.send( {
			ctr:		'top',
			act:		'abonus',
			uID:		App.user.id,
			tID:		App.user.topID
		}, function(error:int, data:Object, params:Object):void {
			if (error) return;
			
			if (data.hasOwnProperty('bonus')) {
				//App.user.stock.addAll(data.bonus);
				take(data.bonus);
			}
				
			if (App.user.top[App.user.topID].hasOwnProperty('abonus')) {
				App.user.top[App.user.topID].abonus = App.user.top[App.user.topID].abonus + 1;
			} else {
				App.user.top[App.user.topID]['abonus'] = 0;
			}
		});
	}
	
	private function take(items:Object):void {
		for(var i:String in items) { 			
			Load.loading(Config.getIcon(App.data.storage[i].type, App.data.storage[i].preview), function(data:Bitmap):void {
				rewardW = new Bitmap;
				rewardW.bitmapData = data.bitmapData;
				App.user.stock.add(int(i), count);
				wauEffect();
			});
		}
	}
	
	public var rewardW:Bitmap;
	private function wauEffect(e:MouseEvent =  null):void {
		if (rewardW.bitmapData != null) {
			var rewardCont:Sprite = new Sprite();
			App.self.windowContainer.addChild(rewardCont);
			
			var glowCont:Sprite = new Sprite();
			glowCont.alpha = 0.6;
			glowCont.scaleX = glowCont.scaleY = 0.5;
			rewardCont.addChild(glowCont);
			
			var glow:Bitmap = new Bitmap(Window.textures.actionGlow);
			glow.x = -glow.width / 2;
			glow.y = -glow.height + 90;
			glowCont.addChild(glow);
			
			var glow2:Bitmap = new Bitmap(Window.textures.actionGlow);
			glow2.scaleY = -1;
			glow2.x = -glow2.width / 2;
			glow2.y = glow.height - 90;
			glowCont.addChild(glow2);
			
			var bitmap:Bitmap = new Bitmap(new BitmapData(rewardW.width, rewardW.height, true, 0));
			bitmap.bitmapData = rewardW.bitmapData;
			bitmap.smoothing = true;
			bitmap.x = -bitmap.width / 2;
			bitmap.y = -bitmap.height / 2;
			rewardCont.addChild(bitmap);
			
			var countText:TextField = Window.drawText('x' + String(count), {
				fontSize:		32,
				color:			0xffffff
			});
			countText.x = bitmap.x + bitmap.width - countText.textWidth;
			countText.y = bitmap.y + bitmap.height - 10;
			rewardCont.addChild(countText);
			
			if (e) {
				rewardCont.x = e.target.parent.x + e.target.parent.width / 2 ;
				rewardCont.y = e.target.parent.y + e.target.parent.height / 2 ;
			} else {
				rewardCont.x = rewardCont.y = 0;
			}
			
			function rotate():void {
				glowCont.rotation += 1.5;
			}
			
			App.self.setOnEnterFrame(rotate);
			
			count = 0;
			TweenLite.to(rewardCont, 0.5, { x:App.self.stage.stageWidth / 2, y:App.self.stage.stageHeight / 2, scaleX:1.25, scaleY:1.25, ease:Cubic.easeInOut, onComplete:function():void {
				setTimeout(function():void {
					App.self.setOffEnterFrame(rotate);
					glowCont.alpha = 0;
					var bttn:* = App.ui.bottomPanel.bttnMainStock;
					var _p:Object = { x:App.ui.bottomPanel.x + bttn.parent.x + bttn.x + bttn.width / 2, y:App.ui.bottomPanel.y + bttn.parent.y + bttn.y + bttn.height / 2};
					SoundsManager.instance.playSFX('takeResource');
					TweenLite.to(rewardCont, 0.3, { ease:Cubic.easeOut, scaleX:0.7, scaleY:0.7, x:_p.x, y:_p.y, onComplete:function():void {
						TweenLite.to(rewardCont, 0.1, { alpha:0, onComplete:function():void {App.self.windowContainer.removeChild(rewardCont);}} );
					}} );
				}, 3000)
			}} );
		}
	}
	
	private var textCount:TextField;
	private function drawCount():void {
		textCount = Window.drawText('x' + count, {
			color:0xffffff,
			fontSize:26,
			borderColor:0x7b3e07
		});
		textCount.width = textCount.textWidth + 10;
		textCount.x = 35;
		textCount.y = 20;
		sprite.addChild(textCount);
		
		if (check) {
			textCount.visible = false;
			var check:Bitmap = new Bitmap(Window.texture('checkMark'));
			check.scaleX = check.scaleY = 0.6;
			check.smoothing = true;
			check.x = 7;
			check.y = 25;
			sprite.addChild(check);
		}
	}
	
	public function dispose():void {
		parent.removeChild(this);
	}
}