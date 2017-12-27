package 
{
	import com.greensock.plugins.TweenPlugin;
	import com.greensock.TweenMax;
	import effects.Effect;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import core.BezieDrop;
	import core.Load;
	import flash.display.Bitmap;
	import flash.display.Stage;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.filters.BlurFilter;
	import flash.geom.Point;
	import flash.utils.clearTimeout;
	import flash.utils.setInterval;
	import flash.utils.setTimeout;
	import flash.utils.Timer;
	import ui.Hints;
	import com.greensock.TweenLite;
	import ui.UserInterface;
	import wins.Window;
	
	/**
	 * ...
	 * @author 
	 */
	
	public class BonusItem extends Sprite 
	{
		public var bitmap:Bitmap;
		private var sID:uint;
		private var nominal:uint;
		private var count:uint;
		private var bezieDrop:BezieDrop;
		private var layer:*;
		private var scaling:Boolean = true;
		private var destObject:* = null;
		private var dropArea:Object = null;
		
		private static const PATH_TIME:Number = 1;// 0.8;
		private var preloader:Preloader = new Preloader();
		
		[Embed(source="blick_bitmap.png", mimeType="image/png")]
		private var Blick_Bitmap:Class;
		private var blickBMD:BitmapData = new Blick_Bitmap().bitmapData;
		
		public function BonusItem(sID:uint, nominal:uint, scaling:Boolean = true, destObject:* = null, dropArea:Object = null)
		{
			this.sID = sID;
			this.nominal = nominal;
			this.count = count;
			this.scaling = scaling;
			this.destObject = destObject;
			this.dropArea = dropArea;
			//trace("sID="+this.sID + );
			bitmap = new Bitmap();
			addChild(bitmap);
			if (sID == Stock.FANTASY) 
			{
				bitmap.bitmapData = UserInterface.textures.energyIcon;
				onImageComplete(bitmap);
			}
			else if (sID == Stock.COINS)
			{
				if (nominal == Treasures.NOMINAL_1)				bitmap.bitmapData = UserInterface.textures.coinsIcon;
				else if (nominal == Treasures.NOMINAL_2)		bitmap.bitmapData = UserInterface.textures.coinsIcon;
				else if (nominal == Treasures.NOMINAL_3)		bitmap.bitmapData = UserInterface.textures.coinsIcon;
				else 											bitmap.bitmapData = UserInterface.textures.coinsIcon;
					
				onImageComplete(bitmap);
			}
			else if (sID == Stock.EXP)
			{
				if (nominal == Treasures.NOMINAL_1)			bitmap.bitmapData = UserInterface.textures.expIcon;
				else if (nominal == Treasures.NOMINAL_2)		bitmap.bitmapData = UserInterface.textures.expIcon;
				else if (nominal == Treasures.NOMINAL_3)		bitmap.bitmapData = UserInterface.textures.expIcon;
				else                                            bitmap.bitmapData = UserInterface.textures.expIcon;
				
				onImageComplete(bitmap);
			}
			else if (sID == Stock.FRANKS)
			{
				if (nominal == Treasures.NOMINAL_1)			bitmap.bitmapData = UserInterface.textures.francsIco;
				else if (nominal == Treasures.NOMINAL_2)		bitmap.bitmapData = UserInterface.textures.francsIco;
				else if (nominal == Treasures.NOMINAL_3)		bitmap.bitmapData = UserInterface.textures.francsIco;
				else                                            bitmap.bitmapData = UserInterface.textures.francsIco;
				
				onImageComplete(bitmap);
			}
			else if (sID == Stock.HELLOWEEN_ICON)
			{
				if (nominal == Treasures.NOMINAL_1)			bitmap.bitmapData = UserInterface.textures.helloweenMoneyIco;
				else if (nominal == Treasures.NOMINAL_2)		bitmap.bitmapData = UserInterface.textures.helloweenMoneyIco;
				else if (nominal == Treasures.NOMINAL_3)		bitmap.bitmapData = UserInterface.textures.helloweenMoneyIco;
				else                                            bitmap.bitmapData = UserInterface.textures.helloweenMoneyIco;
				
				onImageComplete(bitmap);
			}
			else if (sID == Stock.PATRICK_ICON)
			{
				if (nominal == Treasures.NOMINAL_1)			bitmap.bitmapData = Window.textures.patricCoinIco;
				else if (nominal == Treasures.NOMINAL_2)		bitmap.bitmapData = Window.textures.patricCoinIco;
				else if (nominal == Treasures.NOMINAL_3)		bitmap.bitmapData = Window.textures.patricCoinIco;
				else                                            bitmap.bitmapData = Window.textures.patricCoinIco;
				
				onImageComplete(bitmap);
			}
			else
			{
				addChild(preloader);
				preloader.scaleX = preloader.scaleY = 0.6;
				
				Load.loading(Config.getIcon(App.data.storage[sID].type, App.data.storage[sID].preview), onImageComplete);
			}
			
			if ([962, 963, 964, 965, 966, 4, 1201, 1202, 1203, 1204].indexOf(int(sID)) == -1) {
				setTimeout(cash, 4000 + Math.random()*3000);
			} else {
				this.startGlowing();
			}
		}
		
		public var glowingColor:* = 0xFFFF00;
		private var __tween:TweenMax;
		public function startGlowing(color:* = null):void
		{
			if (color != null) glowingColor = color;
			__tween = TweenMax.to(this, 0.8, { glowFilter: { color:glowingColor, alpha:1, strength: 2, blurX:15, blurY:15}, onComplete:restartGlowing} );
		}
		
		public function restartGlowing():void
		{
			if (!this.parent) return;
			__tween = TweenMax.to(this, 0.8, { glowFilter: { color:glowingColor, alpha:0.7, strength: 4, blurX:6, blurY:6 }, onComplete:startGlowing } );	
		}
		
		private function onMouseOver(e:MouseEvent):void {
			cash();
		}
		
		private var maska:Bitmap;
		public function onImageComplete(data:Bitmap):void
		{
			if(contains(preloader)){
				removeChild(preloader);
			}
			bitmap.bitmapData = data.bitmapData;
			bitmap.smoothing = true;
			if (scaling && App.data.storage[sID].mtype != 3 && (bitmap.width >= 70 || App.data.storage[sID].mtype == 4 || bitmap.height >= 70))
				bitmap.scaleX = bitmap.scaleY = 0.6;
				
			if (sID == Stock.FANT)
				bitmap.scaleX = bitmap.scaleY = 0.5;
				
			bitmap.x = -(bitmap.width)/ 2;
			bitmap.y = -(bitmap.height) / 2;
			
			maska = new Bitmap(data.bitmapData);
			addChild(maska);
			maska.x = bitmap.x;
			maska.y = bitmap.y;
			maska.scaleX = bitmap.scaleX;
			maska.scaleY = bitmap.scaleY;
			
			addBlick();
		}
		
		private var blick:Bitmap = new Bitmap();
		private function addBlick():void {
			
			if (maska == null)
				return;
			
			blick.bitmapData = blickBMD;
			addChild(blick);
			blick.x = bitmap.x;
			blick.y = bitmap.y;
			blick.blendMode = BlendMode.OVERLAY;
			blick.width = maska.width + 10;
			blick.rotation =  - 25 + Math.random() * -10;
			//blick.filters = [new BlurFilter(5,5,2)];
			
			/*blik.graphics.beginFill(0xFFFFFF);
			blik.graphics.drawRect(0, 0, maska.width, 5);
			blik.graphics.endFill();
			blik.x = bitmap.x;
			blik.y = bitmap.y;
			blik.blendMode = BlendMode.OVERLAY;
			blik.rotation = Math.random() * 15;
			//blik.filters = [new BlurFilter(0,10,3)];*/
			
			blick.cacheAsBitmap = true;
			maska.cacheAsBitmap = true;
			blick.mask = maska;
			
			randomTime = 1000 + int(1000 * Math.random());
			setTimeout(startBlick, 1000);
		}
		
		private var timer:uint = 0;
		private var randomTime:int;
		private function startBlick():void {
			if (maska == null)
				return;
			
			blick.y = maska.y -5;
			TweenLite.to(blick, 3, {y:maska.height, onComplete:pauseBlick, ease:Strong.easeOut})
		}
		
		private function pauseBlick():void {
			timer = setTimeout(startBlick, randomTime);
		}
		
		private function stopBlick():void {
			if (timer > 0) {
				clearTimeout(timer);
				timer = 0;
			}
		}
		
		public function move(time:int):void {
			setTimeout(doMove, time);
			//doMove();
			this.visible = false;
		}
		
		public var onStartDrop:Function = null;
		public var onCash:Function = null;
		private function doMove():void
		{
			if (onStartDrop != null) onStartDrop();
			this.visible = true;
			var Xf:uint;
			var Yf:uint;
			
			if (dropArea) {
				Xf = this.x + int(Math.random() * dropArea.width) - dropArea.width/2;
				Yf = this.y + int(Math.random() * dropArea.height);
			} else {
				Xf = this.x + int(Math.random() * Treasures.bonusDropArea.w) - Treasures.bonusDropArea.w/2;
				Yf = this.y + int(Math.random() * Treasures.bonusDropArea.h);
			}
			
			var that:* = this;
			//if ([2, 3, 5, 6, 305, 337].indexOf(sID) == -1 && notCollectionItem()) {
				//var bonusDropArea:Object = { w:250, h:50 };
				//this.scaleX = this.scaleY = 1.2;
				//Yf = this.y + int(Math.random() * bonusDropArea.h);
				//bezieDrop = new BezieDrop(this.x, this.y - 150, Xf, Yf, this, function():void {
					//addBlick();
					////addPluck();
					///*var effect:Effect = new Effect('Sparks', that);
					//effect.x = bitmap.x + bitmap.width / 2;
					//effect.y = bitmap.y + bitmap.height / 2;*/
				//});
			//} else {
				bezieDrop = new BezieDrop(this.x, this.y, Xf, Yf, this, function():void {
					addBlick();
					/*var effect:Effect = new Effect('Sparks', that);
					effect.x = bitmap.x + bitmap.width / 2;
					effect.y = bitmap.y + bitmap.height / 2;*/
				});
			}
		//}
		
		public function addPluck():void {
			this.pluck(20, this.x, this.y);
		}
		
		public var isPluck:Boolean = false;
		private var pluckY:Number;
		private var pluckX:Number;
		public function pluck(delay:uint = 0, xPos:int = 0, yPos:int = 0):void 
		{
			pluckY = yPos;
			pluckX = xPos;
			if (delay > 0)
				setTimeout(pluckIn, delay);
			else
				pluckIn();
		}
		 
		private var plackTween:TweenLite;
		private var tweenPlugin:TweenPlugin;
		private var sclKoef:int = 1;
		private function pluckIn():void {
			if (isPluck) return;
			
			isPluck = true;
			sclKoef = this.scaleX;
			
			var cslX:Number = sclKoef * 1.5;
			
			plackTween = TweenLite.to(this, 0.3, { transformAroundPoint: { point:new Point(pluckX, pluckY), scaleX:cslX, scaleY:0.8 }, ease:Strong.easeOut} );//1.2 0.8
			setTimeout(function():void {
				pluckOut();
			}, 200);
		}
		
		
		private var plackOutTween:TweenLite;
		private function pluckOut():void {
			var cslX:Number = sclKoef * 1.2;
			plackOutTween = TweenLite.to(this, 1, { transformAroundPoint: { point:new Point(pluckX, pluckY), scaleX:cslX, scaleY:1 }, ease:Elastic.easeOut, onComplete:function():void { isPluck = false; } }  );
		}
		
		public function pluckDispose():void
		{
			//TweenPlugin.activate(
			//tweenPlugin.onComplete
			
			if (plackTween && plackTween.active) {
				
				plackTween.kill();
			}
			if (plackOutTween && plackOutTween.active) {
				plackOutTween.kill();
			}
			
			tweenPlugin = null;
			plackTween = null;
			plackOutTween = null;
		}
		
		private function notCollectionItem():Boolean {
			if (App.data.storage[sID].hasOwnProperty('collection')) {
				if (App.data.storage[sID].collection != '')
					return false;
			}
			return true;
		}
		
		import com.greensock.easing.*;
		private var cashing:Boolean;
		public function cash():void
		{
			if (cashing) return;
			cashing = true;
			
			if(bezieDrop != null) bezieDrop.stop();
			bezieDrop = null;
			
			var place:Point;
			
			if(App.map.mTreasure.contains(this)) {
				App.map.mTreasure.removeChild(this);
				
				layer = App.ui;
				
				place = new Point(x + App.map.x/App.map.scaleX, y + App.map.y/App.map.scaleY);
				place.x *= App.map.scaleX;
				place.y *= App.map.scaleY;
			}else if (this.parent) {
				layer = this.parent;
				Hints.plus(sID, nominal, new Point(x, y), false, layer); 
				TweenLite.to(this, PATH_TIME * 0.25, { scaleX:0, scaleY:0, ease:Back.easeIn, onComplete:function():void {
					remove();
				} } );
				return;
			}else {
				return;
			}
			
			var totalCount:uint = nominal;
			Hints.plus(sID, totalCount, new Point(place.x, place.y), false, layer);
			
			cashMove(place, layer);
			
			if (onCash != null)
				onCash();
			
			/*stopBlick();
			var that:* = this;
			
			if(bezieDrop != null) bezieDrop.stop();
			bezieDrop = null;
			
			if(App.map.mTreasure.contains(that)){
				App.map.mTreasure.removeChild(that);
			}else{
				return;
			}
			
			var totalCount:uint = nominal;
			//if(!App.user.quests.tutorial)
				Hints.plus(sID, totalCount, new Point((that.x*App.map.scaleX + that.width / 2)+App.map.x, that.y*App.map.scaleY+App.map.y));
			
			var place:Point = new Point(x + App.map.x/App.map.scaleX, y + App.map.y/App.map.scaleY);
			place.x *= App.map.scaleX;
			place.y *= App.map.scaleY;
			
			this.layer = App.ui;
			x = place.x;
			y = place.y;
			layer.addChild(this);
			place.y -= 120;
			
			//this.scaleX = this.scaleY =  0.2;
			//App.ui.flashGlowing(this);
			startBlick();
			TweenLite.to(this, 0.3, { scaleY:1, scaleX:1, ease:Back.easeOut});
			TweenLite.to(this, 0.3, { y:place.y, ease:Strong.easeOut, onComplete:function():void {
				cashMove(place, App.ui);
			}});
			
			if (onCash != null)
				onCash();*/
		}
		
		public function cashMove(place:Point, layer:*):void
		{
			this.layer = layer;
			x = place.x;
			y = place.y;
			layer.addChild(this);
			
			if (destObject != null && destObject.sIDs.indexOf(sID) != -1) {
				toDestinationObject();
				return;
			}
			
			switch(sID) {
				case Stock.COINS:	toCoinsBar(); App.ui.upPanel.update(); break;
				case Stock.EXP: 	toExpBar(); App.ui.upPanel.update(); break;
				case Stock.FANT: 	toFantBar(); App.ui.upPanel.update(); break;
				case Stock.FANTASY:
					toEnergyBar(); 
					App.ui.upPanel.update();
					break;
				case Stock.GUESTFANTASY:
					if (App.user.mode == User.OWNER) {
						toStock();
					}else{
						toGuestEnergyBar();
					}
					break;
			default :
					if (App.data.storage[sID].mtype == 4)
						toCollections();
					else
						toStock();
					break;
			}
		}
		
		public function fromStock(place:Point, moveTo:Point, layer:*):void 
		{
			this.layer = layer;
			x = place.x;
			y = place.y;
			layer.addChild(this);
			
			SoundsManager.instance.playSFX('map_sound_2');
			
			var p:Object = { x:moveTo.x, y:moveTo.y };
			tween(this, p, remove);
		}
		
		private function toDestinationObject():void {
			var p:Object = { x:destObject.target.x + App.map.x, y:destObject.target.y + App.map.y};
			TweenLite.to(this, PATH_TIME, { x:p.x, y:p.y, onComplete:remove});
		}
		
		public function tween(target:*, point:Object, onComplete:Function = null, onCompleteParams:Array = null):void{
			var bezierPoints:Array = [];
			
			var bezierPoint:Object = point;
			bezierPoints.push(bezierPoint);
			
			var borders:Object = {a:point, b:{x:target.x, y:target.y}};
			var randomCount:int = 1;
			for (var i:int = 0; i < randomCount; i++) {
				bezierPoint = new Object();
				
				bezierPoint['x'] = int((target.x - point.x - 100) * Math.random()) + point.x + 50;
				bezierPoint['y'] = int((target.y - point.y - 100) * Math.random()) + point.y + 50;
				
				//bezierPoint['x'] = 100 +((App.self.stage.stageWidth - 200) * Math.random());
				//bezierPoint['y'] = 100 +((App.self.stage.stageHeight - 200) * Math.random());
				bezierPoints.unshift(bezierPoint);
			}
			var randomTime:Number = PATH_TIME + PATH_TIME * Math.random();
			
			if (onCompleteParams == null)
				onCompleteParams = [];
			
			TweenMax.to(target, PATH_TIME, {bezierThrough:bezierPoints, orientToBezier:false, onComplete:onComplete, onCompleteParams:onCompleteParams});
		}
		
		private function toCoinsBar():void {
			SoundsManager.instance.playSFX('map_sound_3');
			var bttn:* = App.ui.upPanel.coinsPanel;
			var p:Object = { x:bttn.x + 20, y:bttn.y + 20 };
			tween(this, p, remove, [App.ui.upPanel.coinsPanel, 0xFFFF00]);
		}
		
		private function toExpBar():void {
			SoundsManager.instance.playSFX('map_sound_4');
			var bttn:* = App.ui.upPanel.expPanel;
			var p:Object = { x:bttn.x + 20, y:bttn.y + 20 };
			tween(this, p, remove, [App.ui.upPanel.expPanel, 0xFFFF00]);
		}
		
		private function toFantBar():void {
			SoundsManager.instance.playSFX('map_sound_2');
			var bttn:* = App.ui.upPanel.fantsPanel;
			var p:Object = { x:bttn.x + 20, y:bttn.y + 20 };
			tween(this, p, remove, [App.ui.upPanel.fantsPanel, 0xFFFF00]);
		}
		
		private function toEnergyBar():void {
			SoundsManager.instance.playSFX('map_sound_2');
			var bttn:* = App.ui.upPanel.energyPanel;
			var p:Object = { x:bttn.x + 17, y:bttn.y + 20};
			tween(this, p, remove, [App.ui.upPanel.energyPanel, 0x86e3f2]);
		}
		
		private function toGuestEnergyBar():void {
			SoundsManager.instance.playSFX('map_sound_2');
			var bttn:* = App.ui.leftPanel.guestEnergy.getChildAt(0);
			var p:Object = { x:bttn.x + 20, y:bttn.y + 20 };
			tween(this, p, remove, [App.ui.upPanel.fantsPanel, 0xFFFF00]);
		}
		
		private function toStock():void {
			var bttn:*;
			var p:Object;
			SoundsManager.instance.playSFX('map_sound_2');
			if (App.user.mode == User.GUEST) {
				bttn = App.ui.bottomPanel.bttnMainHome;
				p = { x:App.ui.bottomPanel.x + bttn.parent.x + bttn.x + bttn.width / 2, y:App.ui.bottomPanel.y + bttn.parent.y + bttn.y + bttn.height / 2};
			}else {
				bttn = App.ui.bottomPanel.bttnMainStock;
				p = { x:App.ui.bottomPanel.x + bttn.parent.x + bttn.x + bttn.width / 2, y:App.ui.bottomPanel.y + bttn.parent.y + bttn.y + bttn.height / 2};
			}
			
			tween(this, p, remove, [bttn, 0xFFFF00]);
		}
		
		private function toCollections():void 
		{
			SoundsManager.instance.playSFX('map_sound_2');
			var bttn:*;
			var p:Object;
			if (App.user.mode == User.GUEST) {
				bttn = App.ui.bottomPanel.bttnMainHome;
				p = { x:App.ui.bottomPanel.x + bttn.parent.x + bttn.x + bttn.width / 2, y:App.ui.bottomPanel.y + bttn.parent.y + bttn.y + bttn.height / 2};
			}else {y
				bttn = App.ui.bottomPanel.bttnCollection;
				p = { x:App.ui.bottomPanel.x + bttn.parent.x + bttn.x + bttn.width / 2, y:App.ui.bottomPanel.y + bttn.parent.y + bttn.y + bttn.height / 2};
			}
			tween(this, p, remove, [bttn, 0xFFFF00]);
		}
		
		public function remove(target:* = null, color:uint = 0xFFFF00):void 
		{
			if (target) App.ui.glowing(target, color);
			if (this.parent == null) return;
			this.parent.removeChild(this);
			layer = null;
		}
		
		public static function takeRewards(items:Object, target:*, delay:int = 0):void {
			
			var timer:Timer;
			var index:int = 0;
			var bitems:Vector.<BonusItem> = new Vector.<BonusItem>;
			for (var i:String in items) {
				var bitem:BonusItem = new BonusItem(int(i), items[i]);
				bitem.visible = false;
				bitems.push(bitem);
			}
			
			if (bitems.length > 0) {
				if (delay > 0 && bitems.length > 1) {
					timer = new Timer(delay, bitems.length);
					timer.addEventListener(TimerEvent.TIMER, onTimer);
					timer.addEventListener(TimerEvent.TIMER_COMPLETE, onTimerComplete);
					timer.start();
				}else {
					for (var j:int = 0; j < bitems.length; j++) showElement(j);
				}
			}
			
			function onTimer(e:TimerEvent):void {
				showElement(timer.currentCount - 1);
			}
			function onTimerComplete(e:TimerEvent):void {
				timer.removeEventListener(TimerEvent.TIMER, onTimer);
				timer.removeEventListener(TimerEvent.TIMER_COMPLETE, onTimerComplete);
			}
			function showElement(id:int):void {
				var point:Point;
				if (target is DisplayObject) {
					point = BonusItem.localToGlobal(target, 'center');
				}else if(target is Point) {
					point = target;
				}else {
					return;
				}
				point.x -= bitems[id].width / 2;
				point.y -= bitems[id].height / 2;
				bitems[id].visible = true;
				bitems[id].cashMove(point, App.self.windowContainer);
			}
		}
		
		public static function localToGlobal(target:DisplayObject, type:String = 'center'):Point {
			var point:Point = new Point(target.x, target.y);
			
			if (type == 'center') {
				point.x += target.width / 2;
				point.y += target.height / 2;
			}
			
			while (true) {
				if (target is Stage || target.parent == null) {
					break;
				}else if (target.parent != null) {
					target = target.parent;
					point.x += target.x;
					point.y += target.y;
				}
			}
			
			return point;
		}
	}
}