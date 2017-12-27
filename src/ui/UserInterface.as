package ui
{
	import com.greensock.TweenMax;
	import core.CookieManager;
	import core.Load;
	import core.Log;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.geom.Point;
	import flash.filters.GlowFilter;
	import flash.geom.Rectangle;
	import wins.CollectionWindow;
	import wins.HalloweenWindow;
	import wins.Window;
	/**
	 * ...
	 * @author 
	 */
	public class UserInterface extends Sprite
	{
		public static const NONE:int = 0;
		public static const OWNER:int = 1;
		public static const GUEST:int = 2;
		
		public static var textures:Object;
		public static var over:Boolean = false;
		
		private var serverDate:Date;
		public var dateOffset:int = 0;
		public var bottomPanel:BottomPanel;
		public var upPanel:UpPanel;
		public var systemPanel:SystemPanel;
		public var rightPanel:RightPanel;
		public var leftPanel:LeftPanel;
		public var salesPanel:SalesPanel;
		
		public function UserInterface()
		{
			/*Load.loading(Config.getInterface('panels'), onLoad, 0, false,
			function(progress:Number):void{
				if(App.self.changeLoader != null) App.self.changeLoader('ui', progress);
			});*/
		}
		
		public function hideAll():void 
		{
			bottomPanel.hide();
			salesPanel.hide();
			systemPanel.visible = false;
			leftPanel.visible = false;
			
			upPanel.hide();
			refresh();
		}
		
		private var _mode:uint = UserInterface.OWNER;
		public function set mode(value:int):void {
			if (mode == value) return;
			
			_mode = value;
			
			if (_mode == UserInterface.OWNER) {
				bottomPanel.show(UserInterface.OWNER);
				upPanel.show(UserInterface.OWNER);
				upPanel.hideWakeUpPanel();
				leftPanel.hideGuestEnergy();
			}else if (_mode == UserInterface.GUEST) {
				bottomPanel.show(UserInterface.GUEST);
				upPanel.show(UserInterface.OWNER);
				leftPanel.showGuestEnergy();
			}else {
				bottomPanel.hide();
				upPanel.hide();
			}
		}
		public function get mode():int {
			return _mode;
		}
		
		public function refresh():void {
			
		}
		
		public var eventIcon:EventIcon;
		public function onLoad():void 
		{
			Cursor.init();
			bottomPanel = new BottomPanel();
			upPanel = new UpPanel();
			systemPanel = new SystemPanel();
			rightPanel = new RightPanel();
			leftPanel = new LeftPanel();
			salesPanel = new SalesPanel();
			
			addChild(bottomPanel);
			addChild(upPanel);
			
			
			serverDate = new Date();
			
			serverDate.setTime((App.midnight + serverDate.timezoneOffset * 60 + 3600 * 12 + dateOffset * 86400) * 1000);
			var month:uint = serverDate.getMonth() + 1;
			var currMonth:uint = month;
			var day:int = serverDate.getDate();
			var year:uint = serverDate.getFullYear();
			var daysOnMonth:int = new Date(year, month, 0).getDate();
			if (App.data.calendar)	{		
				for (var i:int = 0; i < daysOnMonth; i++) {
				
				if (App.data.calendar[month] && App.data.calendar[month].hasOwnProperty('items') && App.data.calendar[month].items.hasOwnProperty(i + 1))
					for (var sid:* in App.data.calendar[month].items[i + 1]) break;
							getState(i + 1);
						}
				function getState(index:int):void
				{
					if (App.user.calendar[year].hasOwnProperty(month)) {
						
					
					if(App.user.calendar[year][month].indexOf(index) < 0 && App.user.calendar[year][month].indexOf(year) < 0)
					if (month == currMonth && index == day) {
							App.ui.upPanel.calendarBttn.startGlowing();
						}
					}
				}
			}
			addChild(systemPanel);
			addChild(rightPanel);
			addChild(leftPanel);
			addChild(salesPanel);
			
			addBankIcon();
			
			App.self.addEventListener(AppEvent.ON_CHANGE_STOCK, onChangeStock);
			App.self.dispatchEvent(new AppEvent(AppEvent.ON_UI_LOAD));
			
			addEventListener(MouseEvent.ROLL_OVER, function(e:MouseEvent):void {
				over = true;
			});
			addEventListener(MouseEvent.ROLL_OUT, function(e:MouseEvent):void {
				over = false;
			});
			
			//this.addEventListener(MouseEvent.MOUSE_DOWN, onDownEvent);
			
			resize();
			checkExpedition();
			
			checkShowResourceHelp();
		}
		
		public function checkShowResourceHelp():void {
			if (!Map.ready) {
				App.self.addEventListener(AppEvent.ON_MAP_COMPLETE, onMap);
			}else {
				onMap();
			}
			
			function onMap(e:AppEvent = null):void {
				if (App.user.worldID == 1907 && App.user.mode == User.OWNER) {
					App.ui.bottomPanel.showResourceHelp(true);
				}else {
					App.ui.bottomPanel.showResourceHelp(false);
				}
				
				if (App.user.worldID == Travel.SAN_MANSANO && App.user.mode == User.OWNER) {
					App.ui.bottomPanel.showResourceHelp(true,2395,'ShowMeBttn');
				}else {
					App.ui.bottomPanel.showResourceHelp(false);
				}
				
				if (App.user.worldID == 1122 && App.user.mode == User.OWNER) {
					App.ui.bottomPanel.showResourceHelp(true,2643,'ShowMeBttn');
				}else {
					App.ui.bottomPanel.showResourceHelp(false);
				}
			}
		}
		
		private var bankIcon:SalesIcon;
		private function addBankIcon(visible:Boolean = false):void {
			if (salesPanel.bankSaleIcons.length > 0)
				return;
			
			var info:Object = App.data.storage[Stock.FANT];
			var icon:Bitmap = Load.getCache(Config.getIcon(info.type, info.preview));
			if (!icon) {
				Load.loading(Config.getIcon(info.type, info.preview), function(data:Bitmap):void {
					if (icon) return;
					icon = new Bitmap(data.bitmapData);
					addBankIcon();
				});
				return;
			}
			
			bankIcon = new SalesIcon(null, null, {
				sale: 'bankSale',
				scale: 0.5,
				bitmap: icon
			});
			salesPanel.bankSaleIcons.push(bankIcon);
			
			bankIcon.x = App.self.stage.stageWidth - bankIcon.bg.width - 15;
			bankIcon.y = systemPanel.y + systemPanel.height + 15;
			
			addChild(bankIcon);		
			salesPanel.isBankAdd = true;
			if (App.data.money != null && App.data.money[App.social]) {
				if ((App.data.money[App.social].enabled && App.data.money[App.social].date_to > App.time && App.data.money[App.social].date_from < App.time) || (App.user.money > App.time))
					visible = true;
			}
			bankIcon.visible = visible;
		}
		
		public function showBankIcon():void {
			if (bankIcon) bankIcon.visible = true;
			else addBankIcon(true);
			App.ui.upPanel.showBankRibbon();
			resize();
			
		}
		
		public function hideBankIcon():void {
			if (bankIcon) bankIcon.visible = false;
			resize();
		}
		
		private var bookerIcon:SalesIcon;
		public function addBookerIcon(sale:Object, pID:*):void {
			return;
			if (bookerIcon) return;
			
			bookerIcon = new SalesIcon(sale, pID, {
				sale: 'vip',
				scale: 0.5
			});
			
			if (!bankIcon.visible) {
				bookerIcon.x = App.self.stage.stageWidth - bankIcon.bg.width - 15;
				bookerIcon.y = systemPanel.y + systemPanel.height + 15;
			} else {
				bookerIcon.x = App.self.stage.stageWidth - bankIcon.bg.width - 15;
				bookerIcon.y = systemPanel.y + systemPanel.height + bankIcon.height + 10;
			}
			
			addChild(bookerIcon);		
			bookerIcon.visible = true;
			
			resize();
		}
		
		public function checkExpedition():void {
			if (App.user.mode == User.OWNER) {
				if (User.inExpedition) {
					if (leftPanel.bttnDaylics) leftPanel.bttnDaylics.visible = false;
					bottomPanel.showExpeditionPanel(true);
				}else {
					if (leftPanel.bttnDaylics) leftPanel.bttnDaylics.visible = true;
					bottomPanel.showExpeditionPanel(false);
				}
			}
		}
		
		private function onChangeStock(e:AppEvent):void {
			bottomPanel.setCollectionCount(CollectionWindow.count);
		}
		
		public function eventIconRemove():void {
			if (eventIcon) {
				removeChild(eventIcon);
				eventIcon = null;
			}
		}
		
		public function eventIconCheck():void {
			if (App.user.level >= 4 && Events.timeOfComplete > App.time && App.user.mode == User.OWNER && !eventIcon) {
			/*	eventIcon = new EventIcon( {
					icon:			'EventHalloween',
					endTime:		App.time + 20,
					onClick:		function():void {
						new HalloweenWindow().show();
					}
				});
				eventIcon.x = 106;
				eventIcon.y = 104;
				addChild(eventIcon);*/
			}
		}
		
		//private function onDownEvent(e:MouseEvent):void {
			/*var list:Array = getObjectsUnderPoint();
			for (var i:int = 0; i < list.length; i++) {
				if (list[i] is Bitmap
			}*/
			
			//over = true;
	//	}
		
		public function resize():void 
		{
			bottomPanel.resize();
			rightPanel.resize();
			upPanel.resize();
			leftPanel.resize();
			systemPanel.resize();
			if (salesPanel && salesPanel.visible) {
				salesPanel.y = 100;
				if (App.data.money != null && App.data.money[App.social]) 
				{
					if ((App.data.money[App.social].enabled && App.data.money[App.social].date_to > App.time && App.data.money[App.social].date_from < App.time) || (App.user.money > App.time))
						salesPanel.y = 185;
				}
				if (bookerIcon) {
					if (salesPanel.y == 185) {
						salesPanel.y = bookerIcon.y + bookerIcon.height;
					} else {
						salesPanel.y = 185;
					}
				}
				var dy:int = 230;
				if (BottomPanel.communityAdd) dy = 310;
				salesPanel.resize(App.self.stage.stageHeight - salesPanel.y - dy);
			}
			
			if (bankIcon) {
				bankIcon.x = App.self.stage.stageWidth - bankIcon.bg.width - 15;
				bankIcon.y = systemPanel.y + systemPanel.height + 15;
			}
			
			if (bookerIcon) {
				if (bankIcon && bankIcon.visible) {
					bookerIcon.x = App.self.stage.stageWidth - bankIcon.bg.width - 15;
					bookerIcon.y = systemPanel.y + systemPanel.height + bankIcon.height + 10;
				} else {
					bookerIcon.x = App.self.stage.stageWidth - bookerIcon.bg.width - 15;
					bookerIcon.y = systemPanel.y + systemPanel.height + 15;
				}
			}
			
			if (App.user.quests.tutorial && App.tutorial)
				App.tutorial.resize();
		}
		
		public static function slider(result:Sprite, value:Number, max:Number, bmd:String = "energySlider"):void {
			while (result.numChildren) {
				result.removeChildAt(0);
			}
			var slider:Bitmap;
			
			if(Window.textures.hasOwnProperty(bmd)) slider = new Bitmap(Window.textures[bmd]);
			else slider = new Bitmap(UserInterface.textures[bmd]);
			
			var mask:Shape = new Shape();
			
			result.addChild(mask);			
			result.addChild(slider);
			
			slider.mask = mask;
			
			var percent:Number = value > max ? 1: value / max;
			if (isNaN(percent)) percent  = 0;
			var currentWidth:Number = slider.width * percent;
			
			mask.graphics.beginFill(0x000000, 1);
			mask.graphics.drawRect(0, 0, slider.width * percent, slider.height);
			mask.graphics.endFill();
		}
		
		private var tglGlow:Boolean = false;
		public function toggleGlow(target:*, color:uint = 0xFFFF00, callback:Function = null):void {
			TweenMax.to(target, 0.3, { glowFilter: { color:color, alpha:0.8, strength: 4, blurX:20, blurY:20 }} );
		}
		
		public function staticGlow(target:*, params:Object = null):void {
			var defPars:Object = { color:0xf7d64b, strength:5 };
			var pars:Object = (params)?params: defPars;
			var glowAnimPars:Object = { min:0.5, max:1, step:0.02, grow:true };
			
			var noNameFunc:Function = function():void
				{
					var filt:GlowFilter = new GlowFilter(pars.color,
										pars.alpha,
										pars.strength,
										pars.strength,
										3,
										2,
										false,
										false);
					if (!stage.contains(target))
						App.self.setOffEnterFrame(noNameFunc);
					target.filters = [filt];
					pars.alpha += (glowAnimPars.grow)? -glowAnimPars.step: +glowAnimPars.step;
					if (pars.alpha >= glowAnimPars.max || pars.alpha <= glowAnimPars.min) glowAnimPars.grow = !glowAnimPars.grow;
				};
			App.self.setOnEnterFrame(noNameFunc);
		}
		
		public function glowing(target:*, color:uint = 0xFFFF00, callback:Function = null):void {
			TweenMax.to(target, 0.3, { glowFilter: { color:color, alpha:0.8, strength: 4, blurX:12, blurY:12 }, onComplete:function():void {
				
				TweenMax.to(target, 0.2, { glowFilter: { color:color, alpha:0, strength: 4, blurX:12, blurY:12 }, onComplete:function():void {
					target.filters = [];
					if (callback != null) {
						callback();
					}
				}});
			}});
		}
		
		public function flashGlowing(target:*, color:uint = 0xFFFF00, callback:Function = null, hasSound:Boolean = true):void 
		{
			TweenMax.to(target, 0.6, { glowFilter: { color:color, alpha:0.8, strength: 7, blurX:30, blurY:30 }, onComplete:function():void {
				TweenMax.to(target, 1, { glowFilter: { color:color, alpha:0, strength: 4, blurX:6, blurY:6 }, onComplete:function():void {
					target.filters = [];
					if (callback != null) {
						callback();
					}
				}});	
			}});
			
			if(hasSound)
				SoundsManager.instance.playSFX('glow');	
		}
		
		import silin.filters.ColorAdjust;	
		
		public static function effect(target:*, brightness:Number = 1, saturation:Number = 1):void {
			var mtrx:ColorAdjust;
			mtrx = new ColorAdjust();
			mtrx.saturation(saturation);
			mtrx.brightness(brightness);
			target.filters = [mtrx.filter];
		}
		
		public static function colorize(target:*, rgb:*, amount:*):void {
			var mtrx:ColorAdjust;
			mtrx = new ColorAdjust();
			mtrx.colorize(rgb, amount);
			target.filters = [mtrx.filter];
		}
		
		public function showNews(data:Object, name:String):void 
		{
			var news:NewsItem = new NewsItem(data, name);
				news.show();
		}
		
		public var globalLoader:GlobalLoader;
		public function addGlobalLoader():void {
			if (globalLoader != null)
				globalLoader.dispose();
				
			globalLoader = new GlobalLoader();
			globalLoader.show();
		}
		public function removeGlobalLoader():void {
			if(globalLoader != null)
				globalLoader.dispose();
				
			globalLoader = null;	
		}
	}
}

import flash.display.Sprite;
import wins.ShopWindow;
internal class GlobalLoader extends Sprite
{
	private var preloader:Preloader = new Preloader();
		
		public function GlobalLoader() 
		{
			drawBody();
		}
		
		private function drawBody():void 
		{
			addChild(preloader);
			preloader.scaleX = preloader.scaleY = 0.8;
			preloader.x = 50;
			preloader.y = 80;
			
			var txt:TextField = Window.drawText(Locale.__e("flash:1405331495038"), {
				color:0xffffff,
				borderColor:0x1d3b3d,
				fontSize:22,
				textAlign:"left"
			});
			addChild(txt);
			txt.width = txt.textWidth + 10;
			txt.x = preloader.x + preloader.width/2 + 10;
			txt.y = preloader.y - txt.textHeight/2;
			
		}
		
		public function dispose():void
		{
			if (preloader && preloader.parent)
				preloader.parent.removeChild(preloader);
				
			App.self.removeChild(this);	
		}
		
		public function show():void {
			App.self.addChild(this);
			this.x = (App.self.stage.stageWidth - this.width) / 2 - 20;
			this.y = (App.self.stage.stageHeight - this.height) / 2 - 40;
		}
}

import buttons.Button;
import buttons.ImageButton;
import com.greensock.TweenLite;
import core.CookieManager;
import core.Load;
import core.TimeConverter;
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.external.ExternalInterface;
import flash.text.TextField;
import wins.ShopWindow;
import wins.Window;

internal class NewsItem extends Sprite
{
	private var bg:Bitmap;
	public var exit:ImageButton
	private var data:Object;
	private var cookieName:String;
	
	public function NewsItem(data:Object, cookieName:String) {
		this.data = data;
		this.cookieName = cookieName;
		
		bg = Window.backing(300, 150, 50, 'windowBacking');
		addChild(bg);
		
		App.ui.addChild(this);
		this.x = App.self.stage.stageWidth - bg.width - 30;
		this.y = -200;
		
		exit = new ImageButton(Window.textures.closeBttn);
		exit.scaleX = exit.scaleY = 0.7;
		addChild(exit);
		exit.x = bg.width - 25;
		exit.y = 0;
		exit.addEventListener(MouseEvent.CLICK, onClose);
		
		drawIcon();
		drawTexts();
		drawBttn();
		
		App.self.setOnTimer(timer);
	}
	
	public function onClose(e:MouseEvent):void {
		if(ExternalInterface.available){
			CookieManager.store(this.cookieName, '1');
		}
		dispose();
	}
	
	public function show():void {
		TweenLite.to(this, 0.5, {y:60})
	}
	
	private var bttn:Button;
	private function drawBttn():void {
		bttn = new Button( {
			caption:Locale.__e('flash:1382952379751'),
			fontSize:22,
			width:94,
			height:30
		})
		addChild(bttn);
		bttn.x = 200 - bttn.width / 2;
		bttn.y = bg.height - bttn.height / 2 - 10;
		bttn.addEventListener(MouseEvent.CLICK, onClick);
	}
	
	private var title:TextField;
	private var description:TextField;
	private var timeText:TextField;
	private function drawTexts():void {
		title = Window.drawText(item.title, {
			color:0xFFFFFF,
			borderColor:0x502f06,
			borderSize:4,
			fontSize:26,
			textAlign:"center",
			multiline:true
		});
		title.width = 140;
		title.height = title.textHeight;
		addChild(title);
		
		description = Window.drawText(data.description, {
			color:0xFFFFFF,
			borderColor:0x502f06,
			borderSize:4,
			fontSize:22,
			textAlign:"center",
			multiline:true,
			wrap:true
		});
		description.width = 140;
		description.x = 130;
		description.height = 130;
		addChild(description);
		
		var time:int = (data.time + data.duration * 3600) - App.time;
		timeText = Window.drawText(TimeConverter.timeToStr(time), {
			color:0xf7d64b,
			borderColor:0x502f06,
			borderSize:4,
			fontSize:36,
			textAlign:"center",
			multiline:true,
			wrap:true
		});
		
		timeText.width = 140;
		timeText.x = description.x;
		timeText.y = 70;
		timeText.height = 130;
		addChild(timeText);
	}
	
	private var item:Object;
	private var bitmap:Bitmap;
	private var sID:*;
	private function drawIcon():void {
		bitmap = new Bitmap();
		addChild(bitmap);
		for (sID in data.items) break;
			item = App.data.storage[sID];
			Load.loading(Config.getIcon(item.type, item.preview), onLoad);
	}
	
	private function onLoad(data:Bitmap):void
	{
		bitmap.bitmapData = data.bitmapData;
		bitmap.x = 70 - bitmap.width / 2;
		bitmap.y = (bg.height - bitmap.height) / 2;
	}
	
	public function onClick(e:MouseEvent = null):void {
		dispose();
		ShopWindow.show( { find:[sID] } );
	}
	
	public function dispose(e:MouseEvent = null):void {
		bttn.removeEventListener(MouseEvent.CLICK, onClick);
		exit.removeEventListener(MouseEvent.CLICK, dispose);
		App.self.setOffTimer(timer);
		App.ui.removeChild(this);
	}
	
	public function timer(e:MouseEvent = null):void {
		var time:int = (data.time + data.duration * 3600) - App.time;
		if (time < 0) {
			dispose();
		}
		timeText.text = TimeConverter.timeToStr(time);
	}
}
