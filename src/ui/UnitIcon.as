package ui 
{
	import buttons.MoneyButton;
	import com.greensock.easing.Elastic;
	import com.greensock.easing.Strong;
	import com.greensock.TweenLite;
	import core.Load;
	import core.Size;
	import effects.Effect;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.utils.clearInterval;
	import flash.utils.clearTimeout;
	import flash.utils.setInterval;
	import flash.utils.setTimeout;
	import units.Animal;
	import wins.Window;
	
	public class UnitIcon extends LayerX {
		
		public static const DEFAULT:String = 'default';
		public static const PROGRESS:String = 'progress';
		public static const PRODUCTION:String = 'production';
		public static const REWARD:String = 'reward';
		public static const BUILD:String = 'build';
		public static const BUILDING:String = 'building';
		public static const DIALOG:String = 'dialog';
		public static const DREAM:String = 'dream';
		public static const MATERIAL:String = 'material';
		public static const SMILE_POSITIVE:String = 'smilePositive';
		public static const SMILE_NEGATIVE:String = 'smileNegative';
		public static const HUNGRY:String = 'hungry';
		public static const HAND_STATE:String = 'hand';
		
		public static const HAND:int = 1080;
		
		public static var unitIcon:UnitIcon;
		
		private var textLabel:TextField;
		private var glow:Sprite;
		private var container:Sprite;
		private var progressBack:Bitmap;
		private var progressBar:Sprite;
		private var boostBttn:MoneyButton;
		public var backing:Bitmap;
		public var icon:Bitmap;
		private var preloader:Preloader;
		
		public var info:Object;
		public var block:Boolean = false;
		
		private var _state:String = DEFAULT;
		public var target:*;
		public var sid:*;
		public var need:int = 0;
		public var require:Object = { };
		
		public var params:Object = {
			maxWidth:		140,
			maxHeight:		140,
			horizontalAlign:true,
			verticalAlign:	false,
			backing:		'none',
			hasBacking:		true,
			
			stocklisten:	false,		// Подписаться на события склада и обновлять счетчик, если известны sid'ы
			hidden:			false,		// Прятаться
			hiddenTimeout:	3000,		// Прятаться по истечении времени
			fadein:			false,
			fadeinTimeout:	500,
			
			clickable:		true,
			onClick:		null,
			multiclick:		false,		// Активирует возможность "кликнуть" на подобные иконти, кликом на одну и наведение мыши на остальные
			
			iconScale:		1,
			iconDX:			0,
			iconDY:			0,
			
			glow:			false,
			glowRotate:		false,
			glowRotateSpeed:0.6,
			
			progressWidth:	100,
			progressHeight:	3,
			progressBegin:	0,
			progressEnd:	0,
			boostPrice:		100,
			progressBacking:'progressBarProduction',
			progressBar:	'progressBarYellow',
			bttnCaption:	Locale.__e('flash:1382952379751'),
			
			//disableText:	false,
			textSettings:	{
				fontSize:	18,
				color:		0xfefefe,
				//borderColor:0x1d2740,
				borderColor:0x754122,
				autoSize:	'left'
			}
			
		}
		
		public function UnitIcon(type:String, sid:* = null, need:int = 0, target:* = null, params:Object = null) {
			if (params) {
				for (var prop:* in params) {
					this.params[prop] = params[prop];
					
					if (this.hasOwnProperty(prop) && !(params[prop] is Function) && typeof(this[prop]) == typeof(params[prop]) )
						this[prop] = params[prop];
				}
			}
			
			state = type;
			this.target = target;
			
			// Если получили объект, то взять первый элемент как материал
			if (sid && typeof(sid) == 'object') {
				for (var first:* in sid) break;
				require = sid;
				this.need = sid[first];
				this.sid = first;
			} else if (sid is int) {
				require[sid] = need;
				this.sid = sid;
				this.need = need;
			}
			
			if (App.data.storage.hasOwnProperty(this.sid))
				info = App.data.storage[this.sid];
			
			draw();
			initFadeIn();
			initHidden();
			
			addEventListener(Event.REMOVED_FROM_STAGE, onRemove);
			//addEventListener(MouseEvent.ROLL_OVER, onOver);
			//addEventListener(MouseEvent.ROLL_OUT, onOut);
			
			if (this.params.stocklisten)
				App.self.addEventListener(AppEvent.ON_CHANGE_STOCK, onChangeStock);
			
			var s:Shape = new Shape();
			s.graphics.beginFill(0xFF0000, 1);
			s.graphics.drawCircle(0, 0, 2);
			s.graphics.endFill();
			//addChild(s);
		}
		
		public function draw():void {
			
			container = new Sprite();
			container.name = 'icon';
			addChild(container);
			if (params.clickable) {
				container.addEventListener(MouseEvent.MOUSE_DOWN, onDown);
				container.addEventListener(MouseEvent.MOUSE_UP, onClick, false, 1);
			}
			
			/*var s:Shape = new Shape();
			s.graphics.beginFill(0xFF0000, 0.3);
			s.graphics.drawRect(0, 0, params.maxWidth, params.maxHeight);
			s.graphics.endFill();
			container.addChild(s);*/
			
			if (state == PRODUCTION) {
				progressBack = new Bitmap(Window.textures[params.progressBacking]);
				progressBack.x = -progressBack.width / 2;
				progressBack.y = -progressBack.height;
				container.addChild(progressBack);
				
				progress();
				
				App.self.setOnTimer(progress);
				
				
				// Backing
				backing = new Bitmap(Window.textures.iconProduction);
				backing.width = 70;
				backing.scaleY = backing.scaleX;
				backing.smoothing = true;
				//backing.alpha = 0.0;
				backing.x = -backing.width / 2;
				backing.y = -backing.height - progressBack.height - 4;
				container.addChild(backing);
				
				// Icon
				loadIcon();
				//jump();
				
			} else if (state == PROGRESS || state == BUILDING) {
				progressBack = new Bitmap(Window.textures[params.progressBacking]);
				progressBack.x = -progressBack.width / 2;
				progressBack.y = -progressBack.height;
				container.addChild(progressBack);
				
				progress();
				
				if (Config.admin || (target is Animal && target.isCollectionFinder)) {
					boostBttn = new MoneyButton( {
						width:		progressBack.width + 30,
						height:		44,
						caption:	params.bttnCaption,
						countText:	params.boostPrice,
						onClick:	onClick
					});
					boostBttn.x = progressBack.x + (progressBack.width - boostBttn.width) / 2;
					boostBttn.y = progressBack.y - boostBttn.height - 4;
					container.addChild(boostBttn);
				}
				
				App.self.setOnTimer(progress);
				
				removeOnMapClick();
				//jump(100, 1);
				
			} else if (state == REWARD) {
				
				backing = new Bitmap(new BitmapData(80, 80, false, 0x000000));
				backing.alpha = 0.0;
				backing.x = -backing.width / 2;
				backing.y = -backing.height;
				container.addChild(backing);
				
				if (params.glow)
					drawGlow();
				
				// Icon
				loadIcon();
				jump();
				
			} else if (state == BUILD) {
				
				backing = new Bitmap(Window.textures.iconBack2);
				backing.width = 60;
				backing.scaleY = backing.scaleX;
				backing.smoothing = true;
				backing.x = -backing.width / 2;
				backing.y = -backing.height;
				container.addChild(backing);
				
				icon = new Bitmap(Window.texture('buildIcon'));
				icon.smoothing = true;
				Size.size(icon, 44, 44);
				icon.x = backing.x + (backing.width - icon.width) / 2;
				icon.y = backing.y + (backing.width - icon.height) / 2;
				container.addChild(icon);
				icon.x = -icon.width/2;
				icon.y = -icon.height - 16;
				
			} else if (state == DIALOG) {
				
				var text:TextField = Window.drawText(params['text'], params.textSettings);
				
				if (text.width > 260) {
					text.wordWrap = true;
					text.multiline = true;
					text.width = 260;
				}
				
				text.x = -text.width / 2;
				text.y = -text.height - 32;
				
				var back:BitmapData = Window.backing(text.width + 20, text.height + 15, 14, 'dialogBacking').bitmapData;
				var tail:BitmapData = Window.texture('dialogTail');
				var cloud:BitmapData = new BitmapData(back.width, back.height + 19, true, 0);
				cloud.draw(back);
				cloud.draw(tail, new Matrix(1, 0, 0, 1, int((back.width - tail.width) / 2), back.height - 6));
				
				backing = new Bitmap();
				backing.bitmapData = cloud;
				backing.alpha = 0.5;
				backing.smoothing = true;
				backing.x = text.x - 10;
				backing.y = text.y - 8;
				
				container.addChild(backing);
				container.addChild(text);
				
				up();
				
			} else if (state == DREAM) {
				
				backing = new Bitmap(Window.texture('bubble'));
				backing.x = -backing.width / 2;
				backing.y = -backing.height;
				container.addChild(backing);
				
				params.iconScale = 0.55;
				
				loadIcon();
			
			} else if (state == MATERIAL) {
				
				backing = new Bitmap(Window.texture('iconBack'), 'auto', true);
				backing.x = -backing.width / 2;
				backing.y = -backing.height;
				container.addChild(backing);
				
				loadIcon();
				
				if (need > 0) {
					stockHaveRequire = true;
					drawText(String(need));
					onChangeStock();
				}
				
			} else if (state == HUNGRY) {
				backing = new Bitmap(Window.texture('iconBack2'), 'auto', true);
				backing.x = -backing.width / 2;
				backing.y = -backing.height;
				container.addChild(backing);
				
				params.iconScale = 0.7;
				loadIcon();
				
				if (need > 0) {
					drawText(String(need));
				}
			} else if (state == HAND_STATE) {
				backing = new Bitmap(Window.texture('iconBack'), 'auto', true);
				backing.x = -backing.width / 2;
				backing.y = -backing.height * 2;
				container.addChild(backing);
				
				params.iconScale = 0.7;
				loadIcon();
			} else {
				backing = new Bitmap(Window.texture('iconBack'), 'auto', true);
				backing.x = -backing.width / 2;
				backing.y = -backing.height;
				container.addChild(backing);
				
				icon = new Bitmap(Window.texture(state), 'auto', true);
				icon.filters = [new GlowFilter(0xFFFFFF, 1, 5, 5, 1)];
				container.addChild(icon);
				
				icon.x = backing.x + (backing.width - icon.width) / 2 + params.iconDX;
				icon.y = backing.y + (backing.height - icon.height) / 2 + params.iconDY - 5;
				
				jump(100, 1, false);
			}
		}
		
		private function onLoad(data:Bitmap):void {
			//if (preloader && container.contains(preloader))
				//container.removeChild(preloader);
			
			icon.bitmapData = data.bitmapData;
			icon.smoothing = true;
			Size.size(icon, backing.width * params.iconScale, backing.height * params.iconScale);
			icon.x = backing.x + (backing.width - icon.width) / 2 + params.iconDX;
			icon.y = backing.y + (backing.height - icon.height) / 2 + params.iconDY - 5;
			
			if (glow) {
				glow.alpha = 1;
				glow.x = icon.x + icon.width / 2;
				glow.y = icon.y + icon.height / 2;
			}
		}
		
		// Boost
		public function progress():void {
			var progressValue:Number = (App.time - params.progressBegin) / (params.progressEnd - params.progressBegin);
			if (progressValue > 1) progressValue = 1;
			if (progressValue < 0) progressValue = 0;
			
			if (!progressBar) progressBar = new Sprite();
			if (!container.contains(progressBar)) container.addChild(progressBar);
			progressBar.x = progressBack.x + 3;
			progressBar.y = progressBack.y + 3;
			UserInterface.slider(progressBar, progressValue, 1, params.progressBar);
		}
		
		// Glow
		public function drawGlow():void {
			glow = new Sprite();
			glow.alpha = 0;
			container.addChild(glow);
			
			if (backing) {
				glow.x = backing.x + backing.width / 2 + params.iconDX;
				glow.y = backing.y + backing.height / 2 + params.iconDY;
			}
			
			var glowBitmap:Bitmap = new Bitmap(Window.textures.iconGlow);
			glowBitmap.scaleX = glowBitmap.scaleY = params.iconScale;
			glowBitmap.x = -glowBitmap.width / 2;
			glowBitmap.y = -glowBitmap.height / 2;
			glow.addChild(glowBitmap);
			
			App.self.setOnEnterFrame(glowRotate);
		}
		private function glowRotate(e:Event = null):void {
			glow.rotation += params.glowRotateSpeed;
		}
		
		// Text
		public function drawText(text:String = '', additionalSettings:Object = null):void {
			//if (params.disableText) return;
			
			if (textLabel && container.contains(textLabel)) {
				container.removeChild(textLabel);
			}
			
			var textSettings:Object = { };
			for (var s:* in params.textSettings)
				textSettings[s] = params.textSettings[s];
			
			if (additionalSettings) {
				for (s in additionalSettings)
					textSettings[s] = additionalSettings[s];
			}
			
			textLabel = Window.drawText('x' + text, textSettings);
			textLabel.x = -textLabel.width / 2 + 13;
			textLabel.y = -textLabel.height - 13;
			container.addChild(textLabel);
		}
		
		// Icon
		public function loadIcon():void {
			if (!info) return;
			
			//preloader = new Preloader();
			//preloader.y = -params.maxHeight / 2;
			//container.addChild(preloader);
			icon = new Bitmap();
			container.addChild(icon);
			Load.loading(Config.getIcon(info.type, info.preview), onLoad);
		}
		
		// State
		public function set state(value:String):void {
			if (_state == value) return;
			
			_state = value;
		}
		
		public function get state():String {
			return _state;
		}
		
		public function onClick(e:MouseEvent = null):void {
			if (App.user.quests.tutorial && !Tutorial.tutorialBttn(this)) return;
			if (App.map.moved || block) return;
			
			App.ui.bottomPanel.changeCursorPanelState(true);
			
			if (__hasGlowing) hideGlowing();
			
			if (params.onClick != null) {
				params.onClick();
			}else if (target && target.hasOwnProperty('click') && (target['click'] is Function)) {
				target['click']();
			}
			
			if (App.user.quests.tutorial) return;
			if (e) e.stopImmediatePropagation();
		}
		
		public function onDown(e:MouseEvent):void {}
		
		// Moves and animations
		private var jumpTimeout:int = 0;
		private var jumpTimes:int = 0;
		private var jumping:int = 0;
		private var jumpInProgress:Boolean = false;
		private function jump(timeout:int = 5000, times:int = 0, randomStart:Boolean = true):void {
			jumpStop();
			
			jumpTimeout = timeout;
			jumpTimes = times;
			jumping = setInterval(goJump, ((randomStart) ? Math.floor(jumpTimeout * Math.random()) : jumpTimeout), randomStart);
		}
		
		private function jumpStop():void {
			if (jumping) clearInterval(jumping);
		}
		
		private function goJump(randomStart:Boolean = false):void {
			if (randomStart) {
				jump(jumpTimeout, jumpTimes, false);
				return;
			}
			
			if (jumpInProgress) return;
			jumpInProgress = true;
			
			TweenLite.to(container, 0.3, { scaleX:1.2, scaleY:0.8, ease:Strong.easeOut, onComplete:function():void {
				TweenLite.to(container, 0.8, { 
					scaleX:1, scaleY:1, ease:Elastic.easeOut, onComplete:function():void {
						if (jumpTimes > 1) {
							jumpTimes--;
						}else if (jumpTimes == 1) {
							jumpStop();
							return;
						}
						
						jumpInProgress = false;
					}
				} );
			}} );
		}
		
		private function up():void {
			container.alpha = 0;
			container.y = 6;
			TweenLite.to(container, 0.25, { y:0, alpha:1 } );
		}
		
		
		private function removeOnMapClick():void {
			App.self.addEventListener(AppEvent.ON_MAP_CLICK, onMapClickEvent);
		}
		private function onMapClickEvent(e:AppEvent = null):void {
			hideBegin();
		}
		
		
		// Fade in
		// Hidden
		private var hiddenTimeout:int = 0;
		private var tweenFadein:TweenLite;
		private function initHidden():void {
			if (params.hidden && hiddenTimeout == 0) {
				hiddenTimeout = setTimeout(hideBegin, params.hiddenTimeout);
			}
		}
		
		private function hideBegin():void {
			//block = true;
			TweenLite.to(this, 0.5, { alpha:0, onComplete:function():void {
				dispose();
			}} );
		}
		
		private function initFadeIn():void {
			if (params.fadein && params.fadeinTimeout > 0) {
				alpha = 0;
				tweenFadein = TweenLite.to(this, params.fadeinTimeout / 1000, { alpha:1 } );
			}
		}
		
		// Stock
		private var stockHaveRequire:Boolean = false;
		private function onChangeStock(e:AppEvent = null):void {
			if (need > 0) {
				var lastState:Boolean = stockHaveRequire;
				stockHaveRequire = App.user.stock.checkAll(require, true);
				
				if (lastState != stockHaveRequire) {
					var additionalSettings:Object = null;
					
					// Если на складе не достаточно материала
					if (!stockHaveRequire) {
						
						backing.bitmapData = Window.texture('iconBack2');
						
						additionalSettings = {
							color:			0xff632c,
							borderColor:	0x591f0b
						}
						
						drawText(String(need), additionalSettings);
					} else if(stockHaveRequire) {
						backing.bitmapData = Window.texture('iconBack');
					}
					
					drawText(String(need), additionalSettings);
				}
			}
		}
		
		protected function onOver():void {}
		
		protected function onOut():void {}
		
		public function isTouch():Boolean {
			var point:Point = new Point(this.mouseX, this.mouseY);
			var bmd:Bitmap;
			var index:int = container.numChildren;
			
			while (--index >= 0) {
				if (container.getChildAt(index) is Bitmap) {
					bmd = container.getChildAt(index) as Bitmap;
					
					if (bmd && bmd.bitmapData) {
						if (bmd.bitmapData.getPixel((point.x - bmd.x) / bmd.scaleX, (point.y - bmd.y) / bmd.scaleY) > 0) {
							focusOn();						
							return true;
						}
						//bmd.bitmapData.setPixel((point.x - bmd.x) / bmd.scaleX, (point.y - bmd.y) / bmd.scaleY, 0xff0000);
					}
				}
			}
			
			//App.map.unitIconOver = false;
			if (unitIcon)
				unitIcon.focusOff();
			
			return false;
		}
		private function focusOn():void {
			if (unitIcon != this) {
				if (unitIcon)
					unitIcon.focusOff();
				
				Effect.light(this, 0.15);
				onOver();
				unitIcon = this;
			}
		}
		public function focusOff():void {
			Effect.light(this);
			onOut();
			
			if (unitIcon == this)
				unitIcon = null;
		}
		
		private function onRemove(e:Event = null):void {
			dispose();
		}
		
		public function dispose():void {
			App.map.unitIconOver = false;
			
			removeEventListener(Event.REMOVED_FROM_STAGE, onRemove);
			//removeEventListener(MouseEvent.ROLL_OVER, onOver);
			//removeEventListener(MouseEvent.ROLL_OUT, onOut);
			App.self.removeEventListener(AppEvent.ON_CHANGE_STOCK, onChangeStock);
			App.self.removeEventListener(AppEvent.ON_MAP_CLICK, onMapClickEvent);
			container.removeEventListener(MouseEvent.MOUSE_DOWN, onDown);
			container.removeEventListener(MouseEvent.MOUSE_UP, onClick);
			
			jumpStop();
			App.self.setOffTimer(progress);
			
			if (boostBttn)
				boostBttn.dispose();
			
			if (parent)
				parent.removeChild(this);
			
			if (hiddenTimeout > 0)
				clearTimeout(hiddenTimeout);
			
			if (tweenFadein)
				tweenFadein.kill();
		}
	}
}

