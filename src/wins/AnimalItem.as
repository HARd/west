package wins 
{
	import buttons.Button;
	import com.greensock.TweenMax;
	import core.Load;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import wins.Window;
	import wins.RecipeWindow;
	/**
	 * ...
	 * @author ...
	 */
	public class AnimalItem extends Sprite
	{
		
		public var background:Bitmap = null;
		public var bg1:Shape = null;
		public var bg2:Shape = null;
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
			recipeBttnHasDotes:false,
			
			titleColor:0x7c3136,
			
			timeColor:0xffffff,
			timeBorderColor:0x764a3e, 
			
			timeMarginY:-24,
			timeMarginX: -3
			
		};
		
		private var testFlag:Boolean = true;
		
		public function AnimalItem(win:*, _settings:Object = null)
		{
			for (var item:* in _settings) {
				settings[item] = _settings[item];
			}
			
			this.win = win;
			
			drawBody();
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
			
			icon.x = 30 + settings.timeMarginX;
			icon.y = background.height - 38 + settings.timeMarginY;
			
			timeText.x = icon.x + icon.width + 3;
			timeText.y = icon.y + 6;
		}
		
		public var recWin:RecipeWindow;
		protected function onGrowClick(e:MouseEvent):void
		{
			recWin = new RecipeWindow( {
				title:Locale.__e("flash:1382952380065")+':',
				fID:fID,
				onCook:win.onCookEvent,
				busy:win.busy,
				win:win,
				hasDescription:true,
				craftData:settings.craftData, 
				recipeBttnName:Locale.__e("flash:1382952380097"),
				prodItem:this
			});
			recWin.show();
		}
		
		private var preloader:Preloader = new Preloader();
		private var needLvl:TextField;
		public function change(fID:*, lvlNeed:int = 0):void
		{
			dispose();
			
			if(!background){
				background = Window.backing(settings.width, settings.height, 10, "itemBacking");
				addChildAt(background, 0);
			}
			
			var formula:Object = App.data.crafting[fID];
			
			this.sID 		= formula.out;
			this.fID 		= int(fID);
			this.count 		= formula.count;
			this.recipe 	= formula.items;
			
			item = App.data.storage[sID];
			
			title.text = App.data.storage[sID].title;
			title.x = (background.width - title.width) / 2;
			
			bitmap.bitmapData = null;
			
			addChild(preloader);
			preloader.x = 80;
			preloader.y = (background.height)/ 2 - 12;
			Load.loading(Config.getIcon(App.data.storage[sID].type, App.data.storage[sID].preview), onPreviewComplete);
			
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
					}
				}
			}
			
			if (lvlNeed > win.settings.target.level) {
				
				if(background && background.parent)
					removeChild(background);
				
				background = null;
				background = Window.backing(settings.width, settings.height, 10, "buildingsDarckBacking");
				addChildAt(background, 0);
				growBttn.visible = false;
				
				bg1.alpha = 0.4;
				bg2.alpha = 0.4;
				
				needLvl = Window.drawText(Locale.__e("flash:1397210661699", [lvlNeed]), {
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
				needLvl.x = 12;
				needLvl.y = settings.height - needLvl.textHeight - 15;
			}else  {
				
				if (background == null){
					background = Window.backing(settings.width, settings.height, 10, "itemBacking");
					addChild(background);
				}
				
				addTime();
				
				timeText.text = TimeConverter.timeToCuts(formula.time, true, true);
				timeText.height = timeText.textHeight + 6;
				
				growBttn.visible = true;
			}
			
			drawDesc();
		}
		
		private function drawBody():void 
		{
			background = Window.backing(settings.width, settings.height, 10, "itemBacking");
			addChild(background);
			
			
			bg1 = new Shape();
			bg1.graphics.beginFill(0xbca168);
			bg1.graphics.drawCircle(0, 0, 55);
			
			bg2 = new Shape();
			bg2.graphics.beginFill(0xbca168);
			bg2.graphics.drawCircle(0, 0, 55);
			
			bg1.x = 80;
			bg1.y = 75;
			bg2.x = bg1.x + bg1.width + 10;
			bg2.y = bg1.y;
			
			addChild(bg1);
			addChild(bg2);
			
			
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
			
			growBttn = new Button( {
				caption:Locale.__e("flash:1382952380097"),
				width:150,
				height:40,
				fontSize:26,
				hasDotes:settings.recipeBttnHasDotes
			});
			addChild(growBttn);
			growBttn.x = (background.width - growBttn.width) / 2;
			growBttn.y = background.height - growBttn.height / 2 + 24 + settings.recipeBttnMarginY;
			
			growBttn.addEventListener(MouseEvent.CLICK, onGrowClick);
			
			addChild(title);
			title.wordWrap = true;
			
			title.width = background.width - 30;
			title.y = 5;
		}
		
		
		private var icon1:Sprite = new Sprite();
		private var icon2:Sprite = new Sprite();
		
		private var needRes:TextField;
		private var outRes:TextField;
		private function drawDesc():void 
		{
			needRes = Window.drawText(Locale.__e("flash:1382952380034"), {
				fontSize:24,
				color:0x67372a,
				borderColor:0xfaf9ec,
				multiline:true,
				textAlign:"center",
				autoSize:"center"
			});
			addChild(needRes);
			needRes.x = bg1.x + (bg1.width - needRes.textWidth) / 2;
			needRes.y = bg1.y - needRes.textHeight / 2 - 2;
			
			var padding:int = 7;
			
				
			addChild(icon1);
			icon1.x = bg1.x + 6;
			icon1.y = bg1.y + 12;
			addChild(icon2);
			icon2.x = bg1.x + 6;
			icon2.y = bg1.y + 42;
			
			outRes = Window.drawText(Locale.__e("flash:1399285692352"), {
				fontSize:20,
				color:0x67372a,
				borderColor:0xfaf9ec,
				multiline:true,
				textAlign:"center",
				autoSize:"center"
			});
			addChild(outRes);
			outRes.x = bg2.x + 10;
			outRes.y = bg2.y + 4;
			
			for (var sidOut:* in item.outs) {
				break;
			}
			
			Load.loading(Config.getIcon(App.data.storage[sidOut].type, App.data.storage[sidOut].preview), onIconOutComplete);			
			
			for (var sidReq:* in item.require) {
				break;
			}
			Load.loading(Config.getIcon(App.data.storage[sidReq].type, App.data.storage[sID].preview), onIconReqComplete);
		}
		
		private var iconReqCont:LayerX = new LayerX();
		private function onIconReqComplete(data:Object):void 
		{
			addChild(iconReqCont);
			var iconBmp:Bitmap = new Bitmap(data.bitmapData, "auto", true);
			addChild(iconBmp);
			
			iconBmp.scaleX = iconBmp.scaleY = 0.3;
			iconBmp.smoothing = true;
			iconReqCont.x = bg2.x + 46;
			iconReqCont.y = bg2.y;
			iconReqCont.addChild(iconBmp);
			
			for (var sidReq:* in App.data.storage[sID].require) {
				var count:int = App.data.storage[sID].require[sidReq];
				break;
			}
			var text:String = Locale.__e('flash:1382952380034') + " " + count;
			iconReqCont.tip = function():Object { 
				return {
					title:App.data.storage[sidReq].title,
					text:text
				};
			};
		}
		
		private var iconOutCont:LayerX = new LayerX();
		private function onIconOutComplete(data:Object):void 
		{
			addChild(iconOutCont);
			var iconBmp:Bitmap = new Bitmap(data.bitmapData, "auto", true);
			addChild(iconBmp);
			if (iconBmp.height > 76)
				iconBmp.height = 76;
			iconBmp.scaleX = iconBmp.scaleY;// = 0.7;
			iconBmp.smoothing = true;
			iconOutCont.x = bg1.x + 16;
			iconOutCont.y = bg1.y + 12;
			iconOutCont.addChild(iconBmp);
			
			for (var sidOut:* in App.data.storage[sID].outs) {
				var count:int = App.data.storage[sID].outs[sidOut];
				break;
			}
			var text:String = Locale.__e('flash:1382952380034') + " " + count;
			iconOutCont.tip = function():Object { 
				return {
					title:App.data.storage[sidOut].title,
					text:text
				};
			};
		}
		
		private function addIcon(bmData:BitmapData, posX:int = 0, posY:int = 0, container:Sprite = null):void
		{
			var iconBmp:Bitmap = new Bitmap(bmData, "auto", true);
			addChild(iconBmp);
			iconBmp.scaleX = iconBmp.scaleY = 0.7;
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
			if (growBttn) growBttn.filters = null;
			
			if (icon1 && icon1.parent)
				icon1.parent.removeChild(icon1);
				
			if (icon2 && icon2.parent)
				icon2.parent.removeChild(icon2);
				
			if (iconReqCont && iconReqCont.parent) {
				while (iconReqCont.numChildren > 0) {
					iconReqCont.removeChildAt(0);
				}
				iconReqCont.parent.removeChild(iconReqCont);
			}
				
			if (iconOutCont && iconOutCont.parent) {
				while (iconOutCont.numChildren > 0) {
					iconOutCont.removeChildAt(0);
				}
				iconOutCont.parent.removeChild(iconOutCont);
			}
				
			if (needRes && needRes.parent) {
				needRes.parent.removeChild(needRes);
			}
				
			if (outRes && outRes.parent)
				outRes.parent.removeChild(outRes);
				
			if (needLvl && needLvl.parent)
				needLvl.parent.removeChild(needLvl);	
				
			if (background && background.parent) {
				background.parent.removeChild(background);
				background = null;
			}
			
			if (timeCont && timeCont.parent) {
				while (timeCont.numChildren > 0) {
					timeCont.removeChildAt(0);
				}
				timeCont.parent.removeChild(timeCont);
			}
				
		}
		
		public function onPreviewComplete(obj:Object):void
		{
			if(contains(preloader)){
				removeChild(preloader);
			}
			bitmap.bitmapData = obj.bitmapData;
			bitmap.smoothing = true;
			if (bitmap.height > 110) {
				bitmap.height = 110;
				bitmap.scaleX = bitmap.scaleY;
			}
			sprTip.x = 20;
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