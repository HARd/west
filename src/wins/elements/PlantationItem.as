package wins.elements 
{
	import buttons.Button;
	import com.greensock.TweenMax;
	import core.Load;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import wins.Window;
	/**
	 * ...
	 * @author ...
	 */
	public class PlantationItem extends Sprite
	{
		public var background:Bitmap = null;
		public var bg1:Bitmap = null;
		public var bg2:Bitmap = null;
		public var bitmap:Bitmap = null;
		public var sID:String;
		public var fID:int;
		public var recipe:Object;
		public var count:uint;
		
		public var title:TextField = null;
		public var timeText:TextField = null;
		public var requestText:TextField = null;
		public var growBttn:Button;
		public var progressBar:Sprite;
		public var icon:Bitmap;
		protected var win:*
		
		private var tween:TweenMax;
		
		public var sprTip:LayerX = new LayerX();
		
		private var item:*;
		
		
		private var settings:Object = {
			width:170,
			height:206,
			recipeBttnMarginY:-28,
			recipeBttnHasDotes:true,
			
			titleColor:0x7c3136,
			
			timeColor:0xffffff,
			timeBorderColor:0x764a3e, 
			
			timeMarginY:-24,
			timeMarginX: -3
			
		};
		
		private var testFlag:Boolean = true;
		
		public function PlantationItem(win:*, _settings:Object = null)
		{
			for (var item:* in _settings) {
				settings[item] = _settings[item];
			}
			
			this.win = win;
			
			background = Window.backing(settings.width, settings.height, 10, "itemBacking");
			addChild(background);
			
			
			bg1 = Window.backing(115, 74, 20, "recipte_line");
			bg1.x = settings.width - bg1.width - 20;
			bg1.y = 46;
			addChild(bg1);
			
			bg2 = Window.backing(115, 46, 20, "recipte_line");
			bg2.x = bg1.x;
			bg2.y = bg1.y + bg1.height + 18;
			addChild(bg2);
			
			growBttn = new Button( {
				caption:Locale.__e("flash:1396612366738"),
				width:150,
				height:40,
				fontSize:26,
				hasDotes:settings.recipeBttnHasDotes
			});
			addChild(growBttn);
			growBttn.x = (background.width - growBttn.width) / 2;
			growBttn.y = background.height - growBttn.height / 2 + 24 + settings.recipeBttnMarginY;
			
			growBttn.addEventListener(MouseEvent.CLICK, onGrowClick);
			
			
			if (contains(sprTip)) {
				removeChild(sprTip);
				sprTip = new LayerX();
			}
			bitmap = new Bitmap();
			sprTip.addChild(bitmap);
			addChild(sprTip);
			
			title = Window.drawText("", {
				fontSize:28,
				color:settings.titleColor,
				borderColor:0xfff6f4,
				multiline:true,
				textAlign:"center",
				autoSize:"center"
			});
			
			sprTip.tip = function():Object {
				return {
					title:App.data.storage[sID].title,
					text:App.data.storage[sID].text
				}
			}
			
			addChild(title);
			title.wordWrap = true;
			
			title.width = background.width - 30;
			title.y = 5;
			
			addTime();
		}
		
		private var timeCont:Sprite = new Sprite();
		private function addTime():void 
		{
			addChild(timeCont);
			icon = new Bitmap(Window.textures.timerBrown);
			timeCont.addChild(icon);
			
			timeText = Window.drawText("", {
				fontSize:20,
				color:settings.timeColor,
				borderColor:settings.timeBorderColor
			});
			timeCont.addChild(timeText);
			
			icon.x = 20 + settings.timeMarginX;
			icon.y = background.height - 38 + settings.timeMarginY;
			
			timeText.x = icon.x + icon.width + 3;
			timeText.y = icon.y + 6;
		
		}
		
		protected function onGrowClick(e:MouseEvent):void
		{
			win.onCookEvent(sID);
		}
		
		private var preloader:Preloader = new Preloader();
		
		public function change(fID:*, lvlNeed:int = 0):void
		{
			dispose();
			
			item = App.data.storage[fID];
			
			var formula:Object = App.data.storage[fID];
			
			this.sID 		= fID;//formula.out;
			this.fID 		= int(fID);
			
			title.text = App.data.storage[sID].title;
			title.x = (background.width - title.width) / 2;
			
			bitmap.bitmapData = null;
			
			addChild(preloader);
			preloader.x = 80;
			preloader.y = (background.height)/ 2 - 12;
			Load.loading(Config.getIcon(App.data.storage[sID].type, App.data.storage[sID].preview), onPreviewComplete);
			
			timeText.text = TimeConverter.timeToCuts(formula.duration, true, true);
			timeText.height = timeText.textHeight + 6;
			
			var info:Object = App.data.storage[sID];
			sprTip.tip = function():Object {
				return {
					title: info.title,
					text: info.description
				};
			}
			
			if (Quests.help) {
				var qID:int = App.user.quests.currentQID;
				var mID:int = App.user.quests.currentMID;
				var targets:Object = App.data.quests[qID].missions[mID].target;
				for each(var sid:* in targets){
					if(this.sID == sid){
						stopGlowing = false;
						glowing();
						
						if (App.user.quests.tutorial) {
							growBttn.showPointing('bottom', growBttn.x - 20, 105, parent);
							App.user.quests.currentTarget = growBttn;
							App.user.quests.lock = false;
							Quests.lockButtons = false;
						}
					}
				}
			}
			
			if (lvlNeed > win.settings.target.level) {
				timeCont.visible = false;
				removeChild(background);
				background = null;
				background = Window.backing(settings.width, settings.height, 10, "buildingsDarckBacking");
				addChildAt(background, 0);
				growBttn.visible = false;
				
				bg1.alpha = 0.4;
				bg2.alpha = 0.4;
				
				var needLvl:TextField = Window.drawText("Нужен " + lvlNeed + " уровень здания", {
					fontSize:22,
					color:0xebe9cf,
					borderColor:0x41332b,
					multiline:true,
					textAlign:"center",
					autoSize:"left"
				});
				needLvl.wordWrap = true;
				needLvl.width = 150;
				addChild(needLvl);
				needLvl.x = 3;
				needLvl.y = settings.height - needLvl.textHeight - 10;
			}
			
			drawDesc();
		}
		
		private var icon1:Sprite = new Sprite();
		private var icon2:Sprite = new Sprite();
		private function drawDesc():void 
		{
			item
			
			var needRes:TextField = Window.drawText("Затраты:", {
				fontSize:24,
				color:0x243358,
				borderColor:0xfaf9ec,
				multiline:true,
				textAlign:"center",
				autoSize:"center"
			});
			addChild(needRes);
			needRes.x = bg1.x + (bg1.width - needRes.textWidth) / 2;
			needRes.y = bg1.y - needRes.textHeight / 2 - 2;
			
			var priceContainer:Sprite = new Sprite();
			
			var padding:int = 7;
			var arrPrices:Array = [];
			for (var sidP:* in item.price) {
				arrPrices.push(sidP);
			}
			arrPrices.sort(Array.NUMERIC);
			
			for (var i:int = 0; i < arrPrices.length; i++ ) {
				var objCol:Object = getColor(arrPrices[i]);
				var priceText:TextField = Window.drawText(String(item.price[arrPrices[i]]), {
					fontSize:24,
					color:objCol.color,
					borderColor:objCol.colorBorder,
					multiline:true,
					textAlign:"left",
					autoSize:"left"
				});
				
				if (i == 0) Load.loading(Config.getIcon(App.data.storage[arrPrices[i]].type, App.data.storage[arrPrices[i]].preview), onIcon1Complete);
				else Load.loading(Config.getIcon(App.data.storage[arrPrices[i]].type, App.data.storage[arrPrices[i]].preview), onIcon2Complete);
				
				if (sidP != Stock.COINS) priceContainer.addChildAt(priceText, 0);
				else priceContainer.addChild(priceText);
				priceText.y = (priceText.textHeight + padding) * i;
			}
				
			addChild(priceContainer);
			priceContainer.x = bg1.x + 40;
			priceContainer.y = bg1.y + 12;
			
			addChild(icon1);
			icon1.x = bg1.x + 6;
			icon1.y = bg1.y + 12;
			addChild(icon2);
			icon2.x = bg1.x + 6;
			icon2.y = bg1.y + 42;
			
			var outRes:TextField = Window.drawText("Дает:", {
				fontSize:24,
				color:0x243358,
				borderColor:0xfaf9ec,
				multiline:true,
				textAlign:"center",
				autoSize:"center"
			});
			addChild(outRes);
			outRes.x = bg2.x + (bg1.width - outRes.textWidth) / 2;
			outRes.y = bg2.y - outRes.textHeight / 2 - 2;
			
			for (var sidOut:* in item.outs) {
				break;
			}
			var outCol:Object = getColor(sidOut);
			var outText:TextField = Window.drawText(String(item.outs[sidOut]), {
				fontSize:24,
				color:outCol.color,
				borderColor:outCol.colorBorder,
				multiline:true,
				textAlign:"left",
				autoSize:"left"
			});
			
			Load.loading(Config.getIcon(App.data.storage[sidOut].type, App.data.storage[sidOut].preview), onIconComplete);
			
			addChild(outText);
			outText.x = bg2.x + 40;
			outText.y = bg2.y + 11;
			
		}
		
		private function onIconComplete(data:Object):void 
		{
			addIcon(data.bitmapData, bg2.x + 6, bg2.y + 12);
		}
		
		private function onIcon1Complete(data:Object):void 
		{
			addIcon(data.bitmapData, 0, 0, icon1);
		}
		
		private function onIcon2Complete(data:Object):void 
		{
			addIcon(data.bitmapData, 0, 0, icon2);
		}
		
		private function addIcon(bmData:BitmapData, posX:int = 0, posY:int = 0, container:Sprite = null):void
		{
			var iconBmp:Bitmap = new Bitmap(bmData, "auto", true);
			if (container) container.addChild(iconBmp);
			else addChild(iconBmp);
			iconBmp.scaleX = iconBmp.scaleY = 0.25;
			iconBmp.smoothing = true;
			iconBmp.x = posX;
			iconBmp.y = posY;
		}
		
		private function getColor(sid:int):Object
		{
			var obj:Object = [];
			switch(sid)
			{
				case Stock.FANTASY:
					obj.color = 0xffdb65;
					obj.colorBorder = 0x775002; 
					break;
				case Stock.COINS:
					obj.color = 0xfdd21e;
					obj.colorBorder = 0x774702; 
					break;
				case Stock.FANT:
					obj.color = 0xffaec7;
					obj.colorBorder = 0x931d4e; 
					break;
				default:
					obj.color = 0xfff1cf;
					obj.colorBorder = 0x482e16; 
					break
			}
			return obj;
		}
		
		public function dispose():void
		{
			stopGlowing = true;
			
			background.filters = null;
			growBttn.filters = null;
		}
		
		public function onPreviewComplete(obj:Object):void
		{
			if(contains(preloader)){
				removeChild(preloader);
			}
			bitmap.bitmapData = obj.bitmapData;
			bitmap.smoothing = true;
			if (bitmap.height > 140) {
				bitmap.height = 140;
				bitmap.scaleX = bitmap.scaleY;
			}
			sprTip.x = 80 - bitmap.width/2;// (background.width - bitmap.width) / 2;
			sprTip.y = (background.height - bitmap.height) / 2 - 15;
		}
		
		public function glow():void
		{
			var myGlow:GlowFilter = new GlowFilter();
			myGlow.inner = false;
			myGlow.color = 0xfbd432;
			myGlow.blurX = 6;
			myGlow.blurY = 6;
			myGlow.strength = 8
			this.filters = [myGlow];
		}
		
		//Используется в квестах
		public function select():void {
			growBttn.showGlowing();
			growBttn.showPointing("top", (growBttn.width - 30) / 2, 0, growBttn.parent);
			App.user.quests.currentTarget = growBttn;
		}
		
		
		private function glowing():void {
			customGlowing(background, glowing);
			if (growBttn) {
				customGlowing(growBttn);
			}
		}
		
		private var stopGlowing:Boolean = false;
		private function customGlowing(target:*, callback:Function = null):void {
			TweenMax.to(target, 1, { glowFilter: { color:0xFFFF00, alpha:0.8, strength: 7, blurX:12, blurY:12 }, onComplete:function():void {
				if (stopGlowing) {
					target.filters = null;
					return;
				}
				TweenMax.to(target, 0.8, { glowFilter: { color:0xFFFF00, alpha:0.6, strength: 7, blurX:6, blurY:6 }, onComplete:function():void {
					if (!stopGlowing && callback != null) {
						callback();
					}
					if (stopGlowing) {
						target.filters = null;
					}
				}});	
			}});
		}		
		
	}
}