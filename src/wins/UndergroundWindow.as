package wins 
{
	import buttons.Button;
	import buttons.ImageButton;
	import buttons.ImagesButton;
	import com.greensock.TweenLite;
	import com.greensock.easing.Bounce;
	import com.pathfinder.Coordinate;
	import core.Load;
	import core.Numbers;
	import core.TimeConverter;
	import effects.Effect;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.BlurFilter;
	import flash.filters.GlowFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.system.Capabilities;
	import flash.text.TextField;
	import flash.utils.clearTimeout;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;
	import ui.Hints;
	import ui.UserInterface;
	import units.Anime;
	import units.Anime2;
	import units.Anime3;
	import units.Underground;
	
	public class UndergroundWindow extends Window 
	{
		public static const MODE_DEFAULT:uint = 1;
		public static const MODE_CHOOSE_ZONE:uint = 2;
		public static const MODE_ZONE_WAIT:uint = 3;
		
		public static const DEFAULT:uint = 0;		// Рабочий режим
		public static const MOVING:uint = 1;		// Режим ожидания хода (проигрывание анимации до конца)
		public static const BUYING:uint = 2;		// Режим докупки
		public static const TREASURING:uint = 3;	// Режим забирания клада
		public static const EXPIRE:uint = 4;		// Режим забирания клада
		public static const CAPTURED:uint = 5;		// Зона заблокирована захватчиком
		public static const CAPTURED_PRICE:uint = 6;// 
		
		
		public const NODE_INDENT:uint = 50;		// отступ по краям
		public const NODE_INDENT_TOP:uint = 60;	// отступ сверху
		public const NODE_INDENT_LEFT:uint = 300;	// отступ сверху
		public const NODE_WIDTH:uint = 91;			// Отступ по ширине
		public const NODE_HEIGHT:uint = 91;		// Отступ по высоте
		public const VISION_RANGE:uint = 3;		// Дальность видимости
		public const CAPTURE_RANGE:uint = 2;		// Дальность блокирования
		
		
		public static var find:*;
		
		
		private const fillColor:uint = 0xff000000;
		
		private var originalPicture:BitmapData;
		public var picture:Bitmap;
		private var mapContainer:Sprite;
		private var map:Sprite;
		private var wall:Sprite;
		private var road:Sprite;
		private var gridFader:Sprite;
		private var underLayer:Sprite;
		private var maskBitmapData:BitmapData;
		private var mapBitmapData:BitmapData;
		private var ownerItem:GridIcon;
		private var currencyCounter:CurrencyPanel;
		
		private var resizeBttn:ImagesButton;
		private var helpBttn:ImageButton;
		private var helpOpenButton:Button;
		private var shopButton:Button;
		
		public var target:Underground;
		
		public var indent:int = 0;
		public var moveCounter:uint = 0;
		private var needUpdateFader:Boolean = true;
		public var capturePoint:Point;
		
		public var treasures:Array;
		public var rewards:Object;
		
		public var openPoints:Vector.<Point>;
		public var closePoints:Vector.<Point>;
		public var treasurePoints:Vector.<Point>;
		public var grounds:Array = ['ground1','ground2','ground3','ground4','ground5','ground6','ground7'];
		
		public function UndergroundWindow(settings:Object=null) {
			
			if (!settings) settings = { };
			
			target = settings.target;
			
			settings['faderClickable'] = settings['faderClickable'] || false;
			settings['escExit'] = settings['escExit'] || false;
			settings['faderAlpha'] = settings['faderAlpha'] || 0;
			settings['faderColor'] = settings['faderColor'] || 0x111111;
			settings['hasAnimations'] = settings['hasAnimations'] || false;
			settings['hasPaginator'] = settings['hasPaginator'] || false;
			settings['hasButtons'] = settings['hasButtons'] || false;
			settings['hasTitle'] = settings['hasTitle'] || false;
			settings['width'] = settings['width'] || App.self.stage.stageWidth;
			settings['height'] = settings['height'] || App.self.stage.stageHeight;
			settings['title'] = settings['title'] || target.info.title;
			
			// Текстуры
			settings['bttn'] = Window.textures.bttn;
			settings['coinsBar'] = UserInterface.textures.panelMoney;
			settings['coinsPlusBttn'] = UserInterface.textures.addBttnYellow;
			settings['systemFullscreen'] = UserInterface.textures.optionsFullscreenIco;
			
			// Переменные
			openPoints = new Vector.<Point>;
			closePoints = new Vector.<Point>;
			treasurePoints = new Vector.<Point>;
			
			Load.loading(Config.getSwf('Firework', 'explode'), onLoadExplode);
			
			super(settings);
			
			App.self.addEventListener(AppEvent.ON_CHANGE_STOCK, onStockChange);
		}
		
		
		/**
		 * Ссылка на картинку
		 */
		private function get pictureURL():String {
			if (target.sid == 2824)
				return Config.getImage('mine', 'underground_2824', 'jpg');
			
			return Config.getImage('mine', 'WesternMineMap', 'jpg');
		}
		
		
		private var explodeTextures:Object;
		private function onLoadExplode(data:*):void {
			explodeTextures = data;
		}
		
		override public function drawBackground():void {}
		
		public function onStockChange(e:AppEvent):void {
			if (!currencyCounter) return;
			
			currencyCounter.update();
			
			if (treasuresItems) {
				for each (var tr:TreasureItem in treasuresItems) {
					tr.update();
				}
			}
		}
		
		override protected function onRefreshPosition(e:Event = null):void {
			///setTimeout(close, 10);
			
			settings.width = App.self.stage.stageWidth;
			settings.height =  App.self.stage.stageHeight;
			
			layer.x = 0;
			layer.y = 0;
			
			fader.width = settings.width;
			fader.height = settings.height;
			
			exit.x = settings.width - exit.width - 8;
			exit.y = 8;
			
			helpBttn.x = exit.x - exit.width - 5;
			helpBttn.y = exit.y;
			
			resizeBttn.x = helpBttn.x - helpBttn.width - 5;
			resizeBttn.y = exit.y;
			
			shopButton.x = settings.width - shopButton.width - 25;
			shopButton.y = shopButton.height + 25;
			
			helpOpenButton.x = settings.width - helpOpenButton.width - 25;
			helpOpenButton.y = helpOpenButton.height + 25 + shopButton.height + 10;
			
			upPanel.x = (App.self.stage.stageWidth - upPanel.width) / 2;
			upPanel.y = -120;
			
			treasurePanel.x = upPanel.x + (upPanel.width - treasurePanel.width) / 2 + 10;
			treasurePanel.y = upPanel.y + upPanel.height + 5;
			
			//hiddenRewardList.dispose();
			//hiddenRewardList = new HiddenRewardList(330, App.self.stage.stageHeight - 60, this, rewards, Underground.save.panelState);
			//hiddenRewardList.x = App.self.stage.stageWidth - hiddenRewardList.currWidth + 25;
			//hiddenRewardList.y = 60;
			//bodyContainer.addChild(hiddenRewardList);
			
			createMap();
			focusOnOwner(0);
		}
			
		public function get gridWidth():int {
			return NODE_WIDTH * target.gridCells + NODE_INDENT + NODE_INDENT + NODE_INDENT_LEFT;
		}
		public function get gridHeight():int {
			return NODE_HEIGHT * target.gridRows + NODE_INDENT + NODE_INDENT + NODE_INDENT_TOP;
		}
		
		override public function drawFader():void {
			super.drawFader();
			
			bodyContainer.y = 0;
			
			//layer.swapChildren(bodyContainer, headerContainer);
		}
		
		private var __mode:uint = MODE_DEFAULT;
		public function set mode(value:uint):void {
			if (mode == value) return;
			__mode = value;
			
			switch(__mode) {
				case MODE_DEFAULT:
					clearZoneMarker();
					break;
				case MODE_CHOOSE_ZONE:
					addZoneMarker();
					break;
			}
		}
		public function get mode():uint {
			return __mode;
		}
		
		private var timeID:uint = 0;
		override public function drawBody():void {
			exit.x = settings.width - exit.width - 8;
			exit.y = 8;
			
			treasures = target.getTreasures();
			rewards = target.getRewards();
			
			var back:Shape = new Shape();
			back.graphics.beginFill(0x666666);
			back.graphics.drawRect(0, 0, 100, 100);
			back.graphics.endFill();
			back.width = settings.width;
			back.height = settings.height;
			bodyContainer.addChild(back);
			
			mapContainer = new Sprite();
			map = new Sprite();
			wall = new Sprite();
			gridFader = new Sprite();
			road = new Sprite();
			underLayer = new Sprite();
			
			mapContainer.addChild(map);
			mapContainer.addChild(wall);
			mapContainer.addChild(road);
			mapContainer.addChild(underLayer);
			bodyContainer.addChild(mapContainer);
			
			createMap();
			
			// Картинка сзади
			picture = new Bitmap();
			mapContainer.addChildAt(picture, 0);
			
			//underLayer.addEventListener(MouseEvent.CLICK, onMapBlock);
			
			mouseChildren = false;
			mouseEnabled = false;
			
			Load.loading(pictureURL, function(bitmap:Bitmap):void {
				
				//if (!originalPicture)
					//return;
				
				if (bitmap.scaleX != 1) {
					bitmap.scaleX = 1;
					bitmap.scaleY = 1;
				}
				
				if (bitmap.width / bitmap.height > gridWidth / gridHeight) {
					bitmap.height = gridHeight;
					bitmap.scaleX = bitmap.scaleY;
					map.x = NODE_INDENT_LEFT + bitmap.width * 0.5 - target.gridCells * NODE_WIDTH * 0.5;
					map.y = NODE_INDENT_TOP + NODE_INDENT;
				}else {
					bitmap.width = gridWidth;
					bitmap.scaleY = bitmap.scaleX;
					map.x = NODE_INDENT_LEFT + NODE_INDENT;
					map.y = NODE_INDENT_TOP + bitmap.height * 0.5 - target.gridRows * NODE_HEIGHT * 0.5;
				}
				
				wall.x = map.x;
				wall.y = map.y;
				road.x = map.x;
				road.y = map.y;
				underLayer.x = map.x;
				underLayer.y = map.y;
				
				mapContainer.x -= map.x;
				mapContainer.y -= map.y;
				
				originalPicture = new BitmapData(bitmap.width, bitmap.height, false, 0xff666666);
				originalPicture.draw(bitmap, new Matrix(bitmap.scaleX, 0, 0, bitmap.scaleY));
				
				drawWarfogPole();
				setSelect(point.x, point.y);
				focusOnOwner(0);
				
				mouseChildren = true;
				mouseEnabled = true;
				
				mapContainer.addEventListener(MouseEvent.CLICK, onMapClick);
				mapContainer.addEventListener(MouseEvent.MOUSE_DOWN, onMapDown);
				mapContainer.addEventListener(MouseEvent.MOUSE_MOVE, onMapMove);
				
				bitmap = null;
			} );
			if (!picture.bitmapData) {
				mapContainer.x = NODE_INDENT_LEFT + settings.width * 0.5 - NODE_INDENT - NODE_WIDTH * target.gridCells * 0.5;
				mapContainer.y = NODE_INDENT_TOP + NODE_INDENT;
			}
			
			
			// Помощь
			helpBttn = drawHelp();
			helpBttn.x = exit.x - exit.width - 5;
			helpBttn.y = exit.y;
			exit.parent.addChild(helpBttn);
			helpBttn.addEventListener(MouseEvent.CLICK, onHelpEvent);
			if (settings.showHelp == true) {
				helpBttn.showGlowing();
			}
			
			// Ресайз
			resizeBttn = new ImagesButton(settings.bttn, settings.systemFullscreen);
			resizeBttn.x = helpBttn.x - helpBttn.width - 5;
			resizeBttn.y = exit.y;
			bodyContainer.addChild(resizeBttn);
			resizeBttn.addEventListener(MouseEvent.CLICK, App.ui.systemPanel.onFullscreenEvent);
			
			shopButton = new Button( {
				width:		140,
				height:		50,
				caption:	Locale.__e('flash:1382952379765')
			});
			shopButton.addEventListener(MouseEvent.CLICK, onShop);
			shopButton.x = settings.width - shopButton.width - 25;
			shopButton.y = shopButton.height + 25;
			bodyContainer.addChild(shopButton);
			
			helpOpenButton = new Button( {	// target.info.text2
				width:		140,
				height:		50,
				caption:	Locale.__e('flash:1472217949342')
			});
			helpOpenButton.addEventListener(MouseEvent.CLICK, onHelp);
			helpOpenButton.x = settings.width - helpOpenButton.width - 25;
			helpOpenButton.y = helpOpenButton.height + 25 + shopButton.height + 10;
			bodyContainer.addChild(helpOpenButton);
			
			drawUpPanel();
			drawTreasuresPanel();
			
			currencyCounter = new CurrencyPanel(this);
			currencyCounter.x = 35;
			currencyCounter.y = 20;
			bodyContainer.addChild(currencyCounter);
			
			if (settings.showHelp == true) {
				//onHelpEvent();
				tutorial_1();
			}
			
			if (UndergroundWindow.find) {
				var tres:Boolean = false;
				if (UndergroundWindow.find is Array) {
					for each (var item:* in UndergroundWindow.find) {
						if (target.items.indexOf(item) != -1) {
							tres = true;
							break;
						}
					}
				}
				
				if (!tres) {
					onShop();
				}else {
					treasurePanel.showGlowing();
					timeID = setTimeout(function():void {
						clearTimeout(timeID);
						treasurePanel.hideGlowing();
					}, 3000);
					UndergroundWindow.find = null;
				}
			}
		}
		
		// Последовательность 1
		private function tutorial_1():void {
			var window:MinigameTutorialWindow = new MinigameTutorialWindow( {
				popup:			true,
				description:	Locale.__e('flash:1477479585473'),//Locale.__e('flash:1472653866409'),
				height:			270,
				character:		'Miner',
				callback:		function():void {
					window.close();
					tutorial_2();
				}
			});
			window.show();
		}
		private function tutorial_2():void {
			var window:MinigameTutorialWindow = new MinigameTutorialWindow( {
				popup:			true,
				description:	Locale.__e('flash:1477479504912'),//Locale.__e('flash:1472654012526'),
				height:			300,
				character:		'Miner',
				callback:		function():void {
					window.close();
					onHelpEvent();
				}
			});
			window.show();
		}
		
		private function drawWarfogPole():void {
			if (!originalPicture) return;
			if (picture.bitmapData && (!closePoints || closePoints.length == 0)) return;
			
			if (picture.bitmapData) {
				picture.bitmapData.dispose();
				picture.bitmapData = null;
			}
			
			picture.bitmapData = originalPicture.clone();
			picture.smoothing = false;
			
			
			var matrix:Matrix = new Matrix();
			var colorTransform:ColorTransform = new ColorTransform();
			var point:Point;
			
			for (var i:int = 0; i < closePoints.length; i++) {
				point = toCoords(closePoints[i]);
				matrix.tx = point.x + map.x;
				matrix.ty = point.y + map.y;
				colorTransform.redOffset = -10 - 1 * int(closePoints[i].y);
				colorTransform.blueOffset = colorTransform.redOffset;
				colorTransform.greenOffset = colorTransform.redOffset;
				picture.bitmapData.draw(Window.texture('caveLand')/*UserInterface.textures.ground6*/, matrix, colorTransform);
			}
		}
		
		private function onHelp(e:MouseEvent):void {
			
			mode = MODE_DEFAULT;
			
			new MinigameHelpWindow({
				title:Locale.__e('flash:1472217949342'),
				background:'goldBacking',
				popup:true,
				itemsOnPage:2,
				description:Locale.__e('flash:1472221169266'),
				content:[
					{
						target:{
							sid:target.helpCurrency(2),
							count:target.helpPrice(2),
							title:Locale.__e('flash:1477554908089'),
							description:Locale.__e('flash:1464765572943')
						},
						link:Config.getImage('mine', 'WesternPicAdvice1','png'),
						func:(treasurePoints.length) ? openRandomPoint : null
					},
					{
						target:{
							sid:target.helpCurrency(3),
							count:target.helpPrice(3),
							title:'',
							description:Locale.__e('flash:1464765647660')
						},
						link:Config.getImage('mine', 'WesternPicAdvice2','jpg'),
						func:open9Points
					}
				]
			}).show();
		}
		
		private function onShop(e:MouseEvent = null):void {
			new UndergroundShopWindow( {
				target:target,
				popup:true
			}).show();
		}
		
		
		private var timerBacking:Bitmap;
		private var timer:TextField;
		private var timerText:TextField;
		private var clockContainer:Sprite;
		private var timerContainer:Sprite;
		private var upPanel:Sprite;
		private function drawUpPanel():void {
			upPanel = new Sprite();
			bodyContainer.addChild(upPanel);
			
			var backing:Bitmap = Window.backing(245, 180, 50, 'itemBacking');
			upPanel.addChild(backing);
			backing.alpha = 0.5;
			
			var titleLabel:TextField = Window.drawText(settings.title,{
				fontSize	:36,
				textAlign	:'left',
				color		:0xffffff,
				borderColor	:0x643a00
			});
			titleLabel.width = titleLabel.textWidth + 5;
			upPanel.addChild(titleLabel);
			titleLabel.x = backing.x + (backing.width - titleLabel.textWidth) / 2;
			titleLabel.y = backing.y + (backing.height - titleLabel.textHeight) * 0.9;
			
			timerContainer = new Sprite();
			upPanel.addChild(timerContainer);
			
			timerBacking = Window.backing(245, 180, 10, 'itemBacking');
			timerContainer.addChild(timerBacking);
			timerBacking.alpha = 0.5;
			
			timerContainer.x = backing.x + backing.width + 5;
			timerContainer.y = backing.y;
			
			clockContainer = new Sprite(); 
			var clockBitmap:Bitmap = new Bitmap(Window.texture('timer'), "auto", true);
			clockContainer.addChild(clockBitmap);
			clockContainer.x = timerBacking.x + 10;
			clockContainer.y = timerBacking.y + (timerBacking.height - clockContainer.height) * 0.9;
			timerContainer.addChild(clockContainer);
			timerText = Window.drawText(Locale.__e('flash:1382952379794',''),{
				fontSize	:26,
				textAlign	:'left',
				color		:0xffffff,
				borderColor	:0x643a00
			});
			timerText.x = clockContainer.x + clockContainer.width + 10;
			timerText.y = clockContainer.y + (clockContainer.height - timerText.textHeight) * 0.5 + 5;
			timerContainer.addChild(timerText);
			
			timer = Window.drawText('00:00:00', {
				fontSize	:28,
				textAlign	:'center',
				color		:0xf8dd46,
				borderColor	:0x643a00
			});
			timer.x = timerText.x + timerText.textWidth;
			timer.y = clockContainer.y + (clockContainer.height - timer.textHeight) * 0.5 + 5;
			timerContainer.addChild(timer);
			
			upPanel.x = (App.self.stage.stageWidth - upPanel.width) / 2;
			upPanel.y = -120;
			
			updateTimer();
			App.self.setOnTimer(updateTimer);
		}
		
		private var treasurePanel:LayerX;
		private var treasureSids:Array;
		private var treasuresItems:Array;
		private function drawTreasuresPanel():void {
			
			if (target.sid == 2824) {
				treasureSids = [2905, 2906, 2907, 2908];
			}else {
				treasureSids = [2572, 2573, 2574, 2575];
			}
			
			
			treasurePanel = new LayerX();
			bodyContainer.addChild(treasurePanel);
			treasuresItems = [];
			var backing:Bitmap = Window.backing(490, 60, 50, 'itemBacking');
			treasurePanel.addChild(backing);
			var treasureText:TextField = Window.drawText(Locale.__e('flash:1382952379794',''),{
				fontSize	:24,
				textAlign	:'left',
				color		:0xffffff,
				borderColor	:0x643a00
			});
			treasureText.x = backing.x + (backing.width - treasureText.textWidth) / 2;
			treasureText.y = -12;
			treasurePanel.addChild(treasureText);
			backing.alpha = 0.5;
			
			for (var i:* in treasureSids){
				var obj:Object = {
					sid:treasureSids[i],
					have:getTreasuresCount(treasureSids[i]),
					need:getTreasuresNeed(treasureSids[i])
				};
				
				var treasure:TreasureItem = new TreasureItem(this,obj);
				treasure.x = 30 + (treasurePanel.width / treasureSids.length - 10) * i;
				treasure.y = backing.y + (backing.height - treasure.height) / 2;
				treasurePanel.addChild(treasure);
				
				treasuresItems.push(treasure);
			}
			
			treasurePanel.x = upPanel.x + (upPanel.width - treasurePanel.width) / 2 + 10;
			treasurePanel.y = upPanel.y + upPanel.height + 10;
		}
		
		public function getTreasuresNeed(sid:int):int {
			var count:int;
			for (var x:* in this.target.items){
				if(this.target.items[x] == sid)
					count++;
			}
			return count;
		}
		
		public function getTreasuresCount(sid:int):int {
			var count:int = 0;
			for (var x:* in grid){
				for (var y:* in grid[x]){
					if(grid[x][y])
						if (this.target.items[grid[x][y].id] == sid)
							count++;
				}
			}
			return count;
		};
		
		public function onHelpEvent(e:MouseEvent = null):void {
			new InfoWindow({qID:'lost_cave'}).show();
		}
		
		private function updateTimer():void{
			timer.text = TimeConverter.timeToDays(target.expire - App.time);
			
			if (App.time > target.expire) {
				block = EXPIRE;
				timer.text = "00:00:00";
			}
		}
		
		/**
		 * Блокировка
		 */
		public var block:uint = 0;
		private var blockTime:uint = 0;
		
		
		/**
		 * Причина блокировки
		 */
		public function blockReason(__block:uint = 0):void {
			var title:String = target.info.title;
			var text:String;
			
			if (block != 0 && block != EXPIRE && blockTime > 0 && blockTime < App.time + 5) {
				blockTime = 0;
				block = 0;
			}
			
			if (__block == 0 && block != 0) {
				blockTime = App.time;
				__block = block;
			}
			
			switch(__block) {
				case MOVING: text = Locale.__e('flash:1464335366978'); break;
				case CAPTURED: text = Locale.__e('flash:1477563102001'); break;
				case CAPTURED_PRICE: text = Locale.__e('flash:1471341862782'); break;
				default: return;
			}
			
			new SimpleWindow( {
				popup:		true,
				title:		title,
				text:		text,
				confirm:	function():void {
					switch(__block) {
						case CAPTURED:
							//if (!capturePoint) return;
							//focusOn(capturePoint.x, capturePoint.y);
							//var cell:GridIcon = getCell(capturePoint);
							//cell.glowing(3);
							
							var capturePoint:Point = pointToNearestBlocker(selectPoint.x, selectPoint.y);
							if (!capturePoint) return;
							focusOn(capturePoint.x, capturePoint.y);
							var cell:GridIcon = getCell(capturePoint);
							cell.onClick();// glowing(3);
							
							break;
						case CAPTURED_PRICE:
							//trace(require);
							break;
					}
				}
			}).show();
		}
		
		
		// Сетка
		public function get grid():Array {
			return target.grid;
		}
		
		
		/**
		 * Очистка сетки
		 */
		private function clearMap():void {
			// Очистка карты от точек
			while (map.numChildren) {
				var item:* = map.getChildAt(0);
				
				if (item.hasOwnProperty('dispose') && item.dispose is Function && item.dispose != null)
					item.dispose();
				else
					map.removeChild(item);
				
				item = null;
			}
			
			road.removeChildren();
		}
		
		/**
		 * Создание сетки
		 */
		private function createMap():void {
			indent = int((Capabilities.screenResolutionX - NODE_WIDTH * target.gridCells) * 0.5);
			if (indent < NODE_INDENT)
				indent = NODE_INDENT;
			
			clearMap();
			
			openPoints.length = 0;
			closePoints.length = 0;
			treasurePoints.length = 0;
			
			var roundRect:Shape = new Shape();
			roundRect.graphics.beginFill(0, 1);
			roundRect.graphics.drawRoundRect(0, 0, NODE_WIDTH * 1.4, NODE_HEIGHT * 1.4, NODE_WIDTH * 0.4, NODE_HEIGHT * 0.4);
			roundRect.graphics.endFill();
			roundRect.filters = [new BlurFilter(NODE_WIDTH * 0.2, NODE_HEIGHT * 0.2)];
			
			capturePoint = null;
			
			for (var i:int = 0; i < grid.length; i++) {
				for (var j:int = 0; j < grid[i].length; j++) {
					var object:Object = grid[i][j];
					var id:int = -1;
					var open:int = 0;
					var require:Object = null;
					var inVision:Boolean = false;
					var cpoint:Point = new Point(i, j);
					var place:Point = toCoords(new Point(i, j));
					
					if (i == 0 && j == 9)
						trace();
					
					// Открыта ли ячейка
					if (object != 0) {
						//place = toCoords(new Point(i, j));
						
						if (object.hasOwnProperty('id'))
							id = object.id;
						
						open = object.o;
						require = object.r;
						
						if (open == 1)
							inVision = true;
					}
					
					// Или распространяется на нее видимость
					if (!inVision)
						inVision = isInVision(i, j, VISION_RANGE);
					
					if (!inVision && open == 0) {
						if (id >= 0 && (!require || (require && !isCapturerRequire(require))))
							treasurePoints.push(cpoint);
						
						closePoints.push(cpoint);
						continue;
					}
					
					// Стенки
					/*if (object != 0 && object.w) {
						if (object.w.indexOf('r') > -1) {
							var bitmap:Bitmap = new Bitmap(Window.texture('caveWall'));
							bitmap.x = place.x + NODE_WIDTH - 14;
							bitmap.y = place.y - 14;
							wall.addChild(bitmap);
						}
						if (object.w.indexOf('b') > -1) {
							bitmap = new Bitmap(Window.texture('caveWall'));
							bitmap.rotation = 90;
							bitmap.x = place.x + NODE_WIDTH + 14;
							bitmap.y = place.y + NODE_HEIGHT - 14;
							wall.addChild(bitmap);
						}
					}*/
					
					if ((inVision || open) && isCapturerRequire(require)) {
						capturePoint = new Point(i, j);
					}
					
					//place = toCoords(new Point(i, j));
					var item:GridIcon = new GridIcon( {
						cell:	i,
						row:	j,
						id:		id,
						open:	open,
						require:require,
						window:	this
					});
					item.x = place.x;
					item.y = place.y;
					
					map.addChild(item);
					openPoints.push(cpoint);
				}
			}
		}
		
		
		/**
		 * Сортировать иконку выше всех
		 */
		private function sortUp(item:GridIcon):void {
			if (!item || !map.contains(item) || map.numChildren + 1 == map.getChildIndex(item)) return;
			map.swapChildren(item, map.getChildAt(map.numChildren - 1));
		}
		
		
		/**
		 * Видимость клетки
		 */
		private function isInVision(cell:int, row:int, range:uint = 1):Boolean {
			for (var c:int = cell - range; c <= cell + range; c++) {
				if (c < 0 || c >= grid.length) continue;
				for (var r:int = row - range; r <= row + range; r++) {
					if (r < 0 || r >= grid[c].length) continue;
					if (grid[c][r] != 0 && grid[c][r].o == 1)
						return true;
				}
			}
			
			return false;
		}
		
		
		/**
		 * Дополнительные требования относятся к захватчику?
		 */
		public function isCapturerRequire(require:Object = null):Boolean {
			if (require && !require[2913])
				return true;
			
			return false;
		}
		
		
		/**
		 * Плавная замена затемнителя
		 */
		private var faderTween:TweenLite;
		private var faders:Vector.<Bitmap> = new Vector.<Bitmap>;
		private var faderBMDs:Vector.<BitmapData> = new Vector.<BitmapData>;
		private function swapFaders():void {
			if (faderBMDs.length < 1) return;
			
			var bitmap:Bitmap = new Bitmap(faderBMDs[faderBMDs.length - 1]);
			faders.push(bitmap);
			gridFader.addChild(bitmap);
			
			if (faders.length > 1) {
				bitmap.alpha = 0;
				faderTween = TweenLite.to(bitmap, 2, { alpha:1, onUpdate:function():void {
					faders[0].alpha = 1 - faders[1].alpha;
				}, onComplete:function():void {
					var bmd:BitmapData = faderBMDs.shift();
					bmd.dispose();
					bmd = null;
					
					bitmap = faders.shift();
					gridFader.removeChild(bitmap);
				}} );
			}
		}
		
		private function checkFaderForUpdate():void {
			needUpdateFader = false;
			for (var i:int = 0; i < moveCells.length; i++) {
				if (grid[moveCells[i].x][moveCells[i].y] == 0 || grid[moveCells[i].x][moveCells[i].y].o != 1)
					needUpdateFader = true;
			}
		}
		
		
		
		private function onMapBlock(e:MouseEvent):void { }
		private function onMapClick(e:MouseEvent):void {
			
			if (moveCounter < 2 && mode == MODE_CHOOSE_ZONE)
				open9PointsConfirm();
		}
		private function onMapMove(e:MouseEvent):void {
			moveCounter ++;
			
			var under:Array = bodyContainer.getObjectsUnderPoint(new Point(bodyContainer.mouseX, bodyContainer.mouseY));
			for (var i:int = 0; i < under.length; i++) {
				if (under[i].parent && under[i].parent is BonusItem)
					BonusItem(under[i].parent).cash();
			}
		}
		private function onMapDown(e:MouseEvent):void {
			moveCounter = 0;
			
			var dragRectangle:Rectangle = new Rectangle(0, 0, settings.width - picture.width, settings.height - picture.height);
			if (dragRectangle.width > 0) dragRectangle.width = 0;
			if (dragRectangle.height > 0) dragRectangle.height = 0;
			mapContainer.startDrag(false, dragRectangle);
			
			App.self.addEventListener(MouseEvent.MOUSE_UP, onMapUp);
		}
		private function onMapUp(e:MouseEvent):void {
			App.self.removeEventListener(MouseEvent.MOUSE_UP, onMapUp);
			
			mapContainer.stopDrag();
		}
		
		
		/**
		 * Показывает дорожку до клетки
		 */
		public var way:Vector.<Coordinate>;
		private var wayViews:Vector.<Bitmap> = new Vector.<Bitmap>;
		public function showRoad(cell:int, row:int):void {
			
			if (mode != MODE_DEFAULT) return;
			
			road.graphics.clear();
			
			way = target.getRoadTo(cell, row);
			if (!way || way.length == 0) return;
			
			clearRoad();
			
			var colorTransform:ColorTransform = new ColorTransform(0, 1, 0);
			var filters:Array = [new GlowFilter(0x00ff00, 0.5, 6, 6)];
			var place:Point;
			
			for (var i:int = 1; i < way.length; i++) {
				var bitmap:Bitmap = new Bitmap(settings.roadBlue);
				bitmap.transform.colorTransform = colorTransform;
				bitmap.filters = filters;
				road.addChild(bitmap);
				wayViews.push(bitmap);
				
				place = toCoords(way[i]);
				
				if (way[i - 1].x < way[i].x) {
					bitmap.rotation = 270;
					bitmap.x = place.x - bitmap.height - 62;
					bitmap.y = place.y + 2;
				}else if (way[i - 1].x > way[i].x) {
					bitmap.rotation = 270;
					bitmap.x = place.x + 32;
					bitmap.y = place.y + 2;
				}else if (way[i - 1].y < way[i].y) {
					bitmap.x = place.x - 2;
					bitmap.y = place.y - bitmap.height - 32;
				}else if (way[i - 1].y > way[i].y) {
					bitmap.x = place.x - 2;
					bitmap.y = place.y + 32;
				}
			}
		}
		public function clearRoad():void {
			while (wayViews.length) {
				var bitmap:Bitmap = wayViews.shift();
				if (bitmap.parent == road) road.removeChild(bitmap);
				bitmap = null;
			}
		}
		
		
		// Сбор бонуса
		private function getBonusFromPoint(bonus:Object, type:String = 'center'):void {
			var point:Point = new Point(select.x, select.y);
			
			if (type == 'center') {
				point.x += NODE_WIDTH * 0.5;
				point.y += NODE_HEIGHT * 0.5;
			}
			Treasures.bonus(bonus, point, null, false, null, null, underLayer);
		}
		
		
		// Движение по клеткам
		private var moveCells:Vector.<Coordinate>;
		public function open(cell:int, row:int, confirm:Boolean = true):void {
			
			if (mode != MODE_DEFAULT) return;
			
			if (isWallTo(cell, row)) {
				new SimpleWindow( {
					popup:		true,
					title:		settings.title,
					text:		Locale.__e('flash:1477491109996')
				}).show();
				return;
			}
			
			if (confirm)
				showConfirm(cell, row, openAction);
			else
				openAction(cell, row);
			
		}
		
		
		private function openAction(cell:int, row:int):void {
			var icon:GridIcon = getCell(new Point(cell, row));
			
			if (block) {
				blockReason();
				return;
			}
			
			moveCells = new Vector.<Coordinate>;
			moveCells.push(new Coordinate(cell, row));
			
			checkFaderForUpdate();
			
			block = MOVING;
			
			target.goAction(moveCells, onMove);
		}
		private function onMove(bonus:Object = null):void {
			
			block = DEFAULT;
			
			createMap();
			drawWarfogPole();
			
			// Обновить доступные клады (их могло стать меньше)
			treasures = target.getTreasures();
			// Обновить боковую панель
			currencyCounter.update();
			
			getBonusFromPoint(bonus);
		}
		
		
		public function showTreasure(item:GridIcon):void {
			var reward:Object;
			var chances:Object;
			var info:*;
			
			if (isWallTo(item.cell, item.row)) {
				new SimpleWindow( {
					popup:		true,
					title:		settings.title,
					text:		Locale.__e('flash:1477491109996')
				}).show();
				return;
			}
			
			for (var i:int = 0; i < treasures.length; i++) {
				if (treasures[i].x == item.cell && treasures[i].y == item.row) {
					if (!App.data.storage[treasures[i].sid]) continue;
					reward = Treasures.getTreasureItems(App.data.storage[treasures[i].sid].treasure);
					chances = App.data.treasures[App.data.storage[treasures[i].sid].treasure][App.data.storage[treasures[i].sid].treasure].probability;
					info = App.data.storage[treasures[i].sid];
					break;
				}
			}
			
			if (!reward) return;
			
			var open:Function = function():void {
				
				var price:Object = target.cellPrice(item.cell, item.row);
				
				if (!App.user.stock.checkAll(price, true)) {
					if (item.require && !isCapturerRequire(item.require)) {
						
						var text:String = Locale.__e('flash:1472723461950');
						if (target.sid == 2824) text = Locale.__e('flash:1477996128798');
						
						new SimpleWindow( {
							popup:		true,
							title:		target.info.title,
							text:		text,
							confirm:	function():void {
								getCurrency( { sid:2913 } );
							}
						}).show();
					}else{
						for (var sid:* in price) break;
						getCurrency( { sid:sid } );
					}
					return;
				}
				
				openAction(item.cell, item.row);
			}
			
			new UndergroundTreasureWindow( {
				width:		520,
				height:		245,
				title:		info.title,
				info:		info,
				onLook:		function():void {
					new UndergroundPresentWindow( {
						popup:		true,
						reward:		reward,
						chances:	chances,
						require:	item.require,
						description:App.data.storage[treasures[i].sid].title
					}).show();
				},
				onTake:		(target.nearIsOpen(item.cell, item.row)) ? open : null
			} ).show();
		}
		
		
		public function showCapturer(item:GridIcon):void {
			
			var explode:Anime;
			
			new InvaderWindow( {
				title:		App.data.storage[item.sid].title,
				target:		this.target,
				item:		item,
				onKill:		function():void {
					openAction(item.cell, item.row);
				},
				onBurst:	function():void {
					target.openAction(Underground.OPENTYPE_POINT, item.cell, item.row, function(bonus:Object):void {
						if (bonus == Underground.NO_PRICE) {
							getCurrency( { sid:target.burst } );
							return;
						}
						
						getBonusFromPoint(bonus);
						
						sortUp(item);
						
						explode = new Anime(explodeTextures, { onLoop:onBurstComplete } );
						explode.x = -45;
						explode.y = -60;
						item.addChild(explode);
						
						TweenLite.to(item.capturer, 0.3, { alpha:0 } );
						
					});
				}
			}).show();
			
			function onBurstComplete():void {
				
				if (explode && explode.parent) {
					explode.onLoop = null;
					explode.parent.removeChild(explode);
					explode = null;
				}
				
				needUpdateFader = true;
				createMap();
				treasures = target.getTreasures();
				currencyCounter.update();
			}
		}
		
		
		/**
		 * Текущая позиция
		 */
		public function get point():Point {
			return target.point;
		}
		
		/**
		 * Позиция на карте в x, y
		 * @param	place
		 * @return
		 */
		public function toCoords(place:Object):Point {
			return new Point(NODE_WIDTH * place.x, NODE_HEIGHT * place.y);
		}
		
		
		/**
		 * Преобразовать точку карты в позицию сетки
		 */
		private function toPlace(place:Object):Point {
			return new Point(int(place.x / NODE_WIDTH), int(place.y / NODE_HEIGHT));
		}
		
		
		/**
		 * Найти ячейку
		 */
		private function getCell(place:Object):GridIcon {
			for (var i:int = 0; i < map.numChildren; i++) {
				var cell:GridIcon = map.getChildAt(i) as GridIcon;
				if (!cell) continue;
				if (cell.cell == place.x && cell.row == place.y)
					return cell;
			}
			
			return null;
		}
		
		
		/**
		 * Выделить ячейку
		 */
		private var selectPoint:Point;
		public function setSelect(cell:int, row:int):void {
			selectPoint = new Point(cell, row);
			var point:Point = toCoords( selectPoint );
			select.x = point.x;
			select.y = point.y;
		}
		private var __select:Sprite;
		private function get select():Sprite {
			if (!__select) {
				const size:uint = 12;
				var beginX:int = NODE_WIDTH * 0.5;
				var beginY:int = NODE_HEIGHT * 0.5;
				
				__select = new Sprite();
				__select.graphics.lineStyle(3, 0x00ff00, 0.85);
				__select.graphics.moveTo(0, size);
				__select.graphics.lineTo(0, 0);
				__select.graphics.lineTo(size, 0);
				__select.graphics.moveTo(beginX * 2 - size, 0);
				__select.graphics.lineTo(beginX * 2, 0);
				__select.graphics.lineTo(beginX * 2, size);
				__select.graphics.moveTo(beginX * 2, beginY * 2 - size);
				__select.graphics.lineTo(beginX * 2, beginY * 2);
				__select.graphics.lineTo(beginX * 2 - size, beginY * 2);
				__select.graphics.moveTo(size, beginY * 2);
				__select.graphics.lineTo(0, beginY * 2);
				__select.graphics.lineTo(0, beginY * 2 - size);
				underLayer.addChild(__select);
			}
			
			return __select;
		}
		
		
		// Фокус на клекту где находится пользователь
		private function focusOnOwner(time:Number = 0.3, callback:Function = null):void {
			focusOn(point.x, point.y, time, callback);
		}
		// Фокус на клекту
		private function focusOn(cell:int, row:int, time:Number = 0.3, callback:Function = null):void {
			var targetX:int = settings.width * 0.5 - map.x - NODE_WIDTH * cell - NODE_WIDTH * 0.5;
			var targetY:int = settings.height * 0.5 - map.y - NODE_HEIGHT * row - NODE_HEIGHT * 0.5;
			
			if (targetX < App.self.stage.stageWidth - picture.width) targetX = App.self.stage.stageWidth - picture.width;
			if (targetY < App.self.stage.stageHeight - picture.height) targetY = App.self.stage.stageHeight - picture.height;
			if (targetX > 0) targetX = 0;
			if (targetY > 0) targetY = 0;
			
			TweenLite.to(mapContainer, time, {
				x: targetX,
				y: targetY,
				onComplete:function():void {
					if (callback != null) callback();
				}
			});
		}
		
		
		/**
		 * Содержит ли ячейка материал для главного клада
		 */
		public function isCellHaveMainTreasure(cell:int, row:int):int {
			var node:Object = grid[cell][row];
			if (node && node.hasOwnProperty('id')) {
				var mainID:int = getMainTreasureID(node.id);
				for each (var formula:* in rewards) {
					if (formula.items.hasOwnProperty(mainID))
						return formula.out;
				}
			}
			
			return 0;
		}
		
		
		public function getMainTreasureID(cellID:int):int {
			var info:Object = App.data.storage[target.items[cellID]];
			
			if (info && info.treasure) {
				var treasure:Object = Treasures.getTreasureItems(info.treasure, info.treasure);
				for (var tid:* in treasure) {
					if (tid == Stock.EXP || tid == Stock.COINS) continue;
					return tid;
				}
			}
			
			return 0;
		}
		
		
		/**
		 * Открытие ячейки по SID материала если будет найдена на поле
		 * @param	materialID
		 * @param	callback
		 */
		public function openLastCell(materialID:int, callback:Function = null):void {
			var items:Array = target.getTreasures();
			var treasure:Object;
			
			for (var i:int = 0; i < treasures.length; i++) {
				var sid:int = getMainTreasureID(treasures[i].id);
				if (materialID == sid) treasure = treasures[i];
			}
			
			if (!treasure) {
				if (callback != null) callback();
				return;
			}
			
			if (!App.user.stock.check(target.currency, target.helpPrice(4))) {
				getCurrency();
				return;
			}
			
			target.openAction(Underground.OPENTYPE_LAST, treasure.x, treasure.y, function(bonus:Object = null):void {
				needUpdateFader = true;
				
				createMap();
				treasures = target.getTreasures();
				//hiddenRewardList.update();
				currencyCounter.update();
				
				focusOn(treasure.x, treasure.y, 0.3, function():void {
					if (!bonus) return;
					getBonusFromPoint(bonus)
				} );
			});
			
		}
		
		
		/**
		 * Забрать подарок за собранные части (скрафтить мгновенный крафт)
		 */
		private var rewardCallback:Function;
		private var rewardID:int;
		public function takeReward(formulaID:int, callback:Function = null):void {
			rewardCallback = callback;
			rewardID = App.data.crafting[formulaID].out;
			
			target.onCraftAction(formulaID);
		}
		public function onCraftComplete():void {
			if (App.data.storage[rewardID]) {
				if (!Underground.save[rewardID])
					Underground.save[rewardID] = 0;
				
				Underground.save[rewardID] ++;
				target.goSave(true);
			}
			
			Effect.wowEffect(rewardID);
			
			currencyCounter.update();
			
			if (rewardCallback != null) rewardCallback();
			rewardCallback = null;
		}
		public function isTakeBefore(sid:*):Boolean {
			return (Underground.save[sid] > 0);
		}
		
		
		
		// Цена
		
		public function getPrice(cell:int, row:int):int {
			return target.defaultCellPrice;
		}
		
		
		
		// Подтверждение 
		public var confirmBttn:ConfirmButton;
		private var confirmCallback:Function;
		private var confirmPoint:Point;
		public function showConfirm(cell:int, row:int, callback:Function):void {
			var price:int = getPrice(cell, row);
			if (price <= 0) return;
			
			confirmCallback = callback;
			confirmPoint = new Point(cell, row);
			
			var description:String = Locale.__e('flash:1477488977901');
			
			if (!App.user.stock.check(target.currency, price)) {
				new SimpleWindow( {
					popup:		true,
					title:		target.info.title,
					text:		Locale.__e(description, [price - App.user.stock.count(target.currency)]),
					confirm:	getCurrency
				}).show();
				
				return;
			}
			
			// Проверить или ячейка содержит элемент для главных наград
			var out:int = isCellHaveMainTreasure(cell, row);
			if (out) {
				
				var info:Object = App.data.storage[out];
				
				new MinigameRewardWindow( {
					link:		Config.getIcon(info.type, info.preview),
					price:		price,
					title:		target.info.title,
					target:		target,
					rewardTitle:App.data.storage[out].title,
					description:Locale.__e('flash:1464358764947'),
					callback:	function():void {
						callback(cell, row);
					}
				}).show();
				
				return;
			}
			
			
			var place:Point = toCoords( { x:cell, y:row } );
			
			hideConfirm();
			confirmBttn = new ConfirmButton( {
				price:		price.toString(),
				sid:		target.currency.toString()
			});
			confirmBttn.x = place.x + NODE_WIDTH * 0.5;
			confirmBttn.y = place.y;
			confirmBttn.alpha = 0;
			confirmBttn.addEventListener(MouseEvent.CLICK, onConfirm);
			underLayer.addChild(confirmBttn);
			
			TweenLite.to(confirmBttn, 0.3, { alpha:1, y:place.y - 25, ease:Bounce.easeOut } );
			
			if (target.tutorial) {
				for (var i:int = 0; i < map.numChildren; i++) {
					var item:* = map.getChildAt(i);
					if (item is GridIcon) {
						item.hideGlowing();
						item.hidePointing();
					}
				}
				
				confirmBttn.showGlowing();
				confirmBttn.showPointing('top', -15, -30, confirmBttn.parent);
			}
		}
		public function hideConfirm():void {
			if (!confirmBttn) return;
			
			if (confirmBttn.parent)
				confirmBttn.parent.removeChild(confirmBttn);
			
			confirmBttn.hideGlowing();
			confirmBttn.hidePointing();
			
			confirmBttn.removeEventListener(MouseEvent.CLICK, onConfirm);
			confirmBttn.dispose();
			confirmBttn = null;
		}
		private function onConfirm(e:MouseEvent):void {
			hideConfirm();
			confirmCallback(confirmPoint.x, confirmPoint.y);
		}
		
		
		
		// Открытие точек зоны
		/**
		 * Произвольная закрытая точка
		 */
		private function openRandomPoint(e:MouseEvent = null):void {
			
			if (treasurePoints.length == 0) {
				new SimpleWindow( {
					popup:		true,
					title:		target.info.title,
					text:		Locale.__e('flash:1464171515197')
				}).show();
				
				return;
			}
			
			//var index:int = int(closePoints.length * Math.random());
			//var openPoint:Point = closePoints[index];
			
			var index:int = int(treasurePoints.length * Math.random());
			var openPoint:Point = treasurePoints[index];
			
			if (!App.user.stock.check(target.helpCurrency(2), target.helpPrice(2))) {
				getCurrency( { sid:target.helpCurrency(2) } );
				return;
			}
			
			target.openAction(Underground.OPENTYPE_RANDOMPOINT, openPoint.x, openPoint.y, function(bonus:Object):void {
				//closePoints.splice(index, 1);
				treasurePoints.splice(index, 1);
				needUpdateFader = true;
				currencyCounter.update();
				createMap();
				focusOn(openPoint.x, openPoint.y);
			});
		}
		
		/**
		 * Произвольная точка с кладом
		 */
		private function openTreasurePoint(e:MouseEvent = null):void {
			
			// Shuffle
			for (var i:int = 0; i < treasures.length * 2; i++) {
				var node:Object = treasures.splice(int(treasures.length * Math.random()), 1);
				treasures.push(node[0]);
			}
			
			var openPoint:Point;
			var index:int = 0;
			
			for (i = 0; i < treasures.length; i++) {
				var cell:Object = treasures[i];
				if (grid[cell.x][cell.y] && grid[cell.x][cell.y].o >= 1) continue;
				
				for (var j:int = 0; j < closePoints.length; j++) {
					if (closePoints[j].x == cell.x && closePoints[j].y == cell.y) {
						openPoint = closePoints[j];
						index = j;
						break;
					}
				}
				
				if (openPoint) break;
			}
			
			if (!openPoint) {
				new SimpleWindow( {
					popup:		true,
					title:		target.info.title,
					text:		Locale.__e('flash:1464172361515')
				}).show();
				
				return;
			}
			
			if (!App.user.stock.check(target.currency, target.helpPrice(1))) {
				getCurrency();
				return;
			}
			
			target.openAction(Underground.OPENTYPE_POINT, openPoint.x, openPoint.y, function(bonus:Object):void {
				closePoints.splice(index, 1);
				needUpdateFader = true;
				currencyCounter.update();
				createMap();
				focusOn(openPoint.x, openPoint.y, 0.3, function():void {
					if (!bonus) return;
					getBonusFromPoint(bonus, 'none');
				});
			});
		}
		
		/**
		 * Зона 3х3
		 */
		private function open9Points(e:MouseEvent = null):void {
			mode = MODE_CHOOSE_ZONE;
		}
		private function open9PointsConfirm():void {
			
			if (!lastMarkerPoint)
				return;
			
			mode = MODE_DEFAULT;
			
			// Проверить или содержит закрытые клетки
			var haveClose:Boolean = false;
			for (var i:int = lastMarkerPoint.x - 1; i < lastMarkerPoint.x + 2; i++) {
				for (var j:int = lastMarkerPoint.y - 1; j < lastMarkerPoint.y + 2; j++) {
					if (!grid[i][j]) haveClose = true;
				}
			}
			if (!haveClose) {
				new SimpleWindow( {
					popup:		true,
					title:		target.info.title,
					text:		Locale.__e('flash:1464340725016')
				}).show();
				return;
			}
			
			if (!App.user.stock.check(target.helpCurrency(3), target.helpPrice(3))) {
				new SimpleWindow( {
					popup:true,
					text:Locale.__e('flash:1472570820695'),
					title:target.info.title,
					confirm:function():void {
						getCurrency( { sid:target.helpCurrency(3) } );
					}
				}).show();
				return;
			}
			
			Hints.minus(target.helpCurrency(3), target.helpPrice(3), new Point(mouseX, mouseY), false, this);
			mode = MODE_ZONE_WAIT;
			
			target.openAction(Underground.OPENTYPE_3X3ZONE, lastMarkerPoint.x, lastMarkerPoint.y, function():void {
				mode = MODE_DEFAULT;
				
				needUpdateFader = true;
				currencyCounter.update();
				createMap();
				focusOn(lastMarkerPoint.x, lastMarkerPoint.y);
				lastMarkerPoint = null;
			});
		}
		
		/**
		 * Маркер открываемой зоны
		 * @param	cells
		 * @param	rows
		 */
		private var marker:Shape;
		private var lastMarkerPoint:Point;
		private function addZoneMarker(cells:int = 3, rows:int = 3):void {
			if (marker)
				clearZoneMarker();
			
			marker = new Shape();
			marker.graphics.lineStyle(2, 0xffcc00, 0.7, true);
			marker.graphics.beginFill(0xffcc00, 0.15);
			marker.graphics.drawRect(-NODE_WIDTH, -NODE_HEIGHT, NODE_WIDTH * cells, NODE_HEIGHT * rows);
			marker.graphics.endFill();
			map.addChild(marker);
			
			marker.addEventListener(Event.ENTER_FRAME, onMarkerMove);
		}
		private function clearZoneMarker():void {
			if (!marker) return;
			if (marker.parent) marker.parent.removeChild(marker);
			marker.removeEventListener(Event.ENTER_FRAME, onMarkerMove);
			marker = null;
		}
		private function onMarkerMove(e:Event):void {
			var point:Point = toPlace( { x:map.mouseX, y:map.mouseY } );
			
			if (point.x < 1) point.x = 1;
			if (point.x > target.gridCells - 2) point.x = target.gridCells - 2;
			if (point.y < 1) point.y = 1;
			if (point.y > target.gridRows - 2) point.y = target.gridRows - 2;
			
			// Если та же самая точка - выйти в окно
			if (lastMarkerPoint && lastMarkerPoint.x == point.x && lastMarkerPoint.y == point.y) return;
			lastMarkerPoint = point;
			
			var placeOnMap:Point = toCoords(point);
			
			marker.x = placeOnMap.x;
			marker.y = placeOnMap.y;
		}
		
		
		
		public function getCurrency(... args):void {
			
			var sid:* = target.currency;
			if (args[0] && args[0].hasOwnProperty('sid'))
				sid = args[0].sid;
				
			var content:Array = PurchaseWindow.createContent('Energy', { view:App.data.storage[sid].view } );
			if (content.length == 0) {
				onHelpEvent();
				return;
			}
			
			new PurchaseWindow( {
				popup:		true,
				width:		716,
				itemsOnPage:content.length,
				content:	content,
				title:		App.data.storage[sid].title,
				description:Locale.__e("flash:1464346398152"),
				callback:	function(sID:int):void { }
			}).show();
		}
		
		
		
		public function tutorialShowNearTreasureChest():void {
			for (var i:int = 0; i < map.numChildren; i++) {
				var item:* = map.getChildAt(i);
				if (item is GridIcon && item.cell == target.info.startX + 1 && item.row == target.info.startY) {
					item.showGlowing();
					item.showPointing('top', -45, -40, item.parent);
				}
			}
		}
		public function tutorialShowBackCell():void {
			for (var i:int = 0; i < map.numChildren; i++) {
				var item:* = map.getChildAt(i);
				if (item is GridIcon) {
					if (item.open == 1 && item.cell == target.info.startX && item.row == target.info.startY) {
						item.showGlowing();
						item.showPointing('top', -45, -40, item.parent);
					}else {
						item.hideGlowing();
						item.hidePointing();
					}
				}
			}
		}
		
		
		
		
		/**
		 * Проверка на заблокированность ячейки блокером
		 */
		public function blockByBlocker(cell:int, row:int):Boolean {
			if (capturePoint) {
				for (var c:int = cell - CAPTURE_RANGE; c <= cell + CAPTURE_RANGE; c++) {
					if (c < 0 || c >= grid.length) continue;
					for (var r:int = row - CAPTURE_RANGE; r <= row + CAPTURE_RANGE; r++) {
						if (r < 0 || r >= grid[c].length) continue;
						if (grid[c][r] != 0 && grid[c][r].hasOwnProperty('r') && Numbers.countProps(grid[c][r]['r']) > 0 && isCapturerRequire(grid[c][r]['r']))
							return true;
					}
				}
			}
			
			return false;
		}
		
		
		
		
		/**
		 * Проверка на заблокированность ячейки блокером; возвращает точку
		 */
		public function pointToNearestBlocker(cell:int, row:int):Point {
			for (var c:int = cell - CAPTURE_RANGE; c <= cell + CAPTURE_RANGE; c++) {
				if (c < 0 || c >= grid.length) continue;
				for (var r:int = row - CAPTURE_RANGE; r <= row + CAPTURE_RANGE; r++) {
					if (r < 0 || r >= grid[c].length) continue;
					if (grid[c][r] != 0 && grid[c][r].hasOwnProperty('r') && Numbers.countProps(grid[c][r]['r']) > 0 && isCapturerRequire(grid[c][r]['r']))
						return new Point(c, r);
				}
			}
			
			return null;
		}
		
		
		
		
		
		/**
		 * Проверка на возможность пройти; мешают ли стены
		 */
		public function isWallTo(cell:int, row:int):Boolean {
			/*var array:Array = target.nearIsOpenCells(cell, row);
			var current:Object = grid[cell][row];
			
			for (var i:int = 0; array && i < array.length; i ++) {
				var nodeInfo:Object = array[i];
				var node:Object = grid[nodeInfo.x][nodeInfo.y];
				
				if (nodeInfo.x < cell && node.w && node.w.indexOf('r') > -1) {}
				else if (nodeInfo.x > cell && current && current.w && current.w.indexOf('r') > -1) {}
				else if (nodeInfo.y < row && node.w && node.w.indexOf('b') > -1) {}
				else if (nodeInfo.y > row && current && current.w && current.w.indexOf('b') > -1) { }
				else {
					return false;
				}
			}
			
			return true;*/
			
			return false;
			
		}
		
		
		
		override public function close(e:MouseEvent = null):void {
			super.close(e);
			
			mapContainer.removeEventListener(MouseEvent.CLICK, onMapClick);
			mapContainer.removeEventListener(MouseEvent.MOUSE_DOWN, onMapDown);
			mapContainer.removeEventListener(MouseEvent.MOUSE_MOVE, onMapMove);
			mapContainer.stopDrag();
			
			App.self.removeEventListener(MouseEvent.MOUSE_UP, onMapUp);
			
			clearMap();
			clearZoneMarker();
			
			helpOpenButton.removeEventListener(MouseEvent.CLICK, onHelp);
			shopButton.removeEventListener(MouseEvent.CLICK, onShop);
			
			if (originalPicture) {
				originalPicture.dispose();
				originalPicture = null;
			}
		}
		
	}

}

import buttons.Button;
import buttons.ImageButton;
import com.greensock.TweenLite;
import com.greensock.easing.Back;
import core.AvaLoad;
import core.Load;
import core.Numbers;
import core.TimeConverter;
import effects.Effect;
import flash.display.Bitmap;
import flash.display.PixelSnapping;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.filters.BevelFilter;
import flash.geom.ColorTransform;
import flash.geom.Point;
import flash.text.TextField;
import ui.BitmapLoader;
import ui.Hints;
import ui.UserInterface;
import units.Anime;
import units.Hero;
import units.Underground;
import units.Personage;
import wins.UndergroundWindow;
import wins.Paginator;
import wins.Window;
import wins.WindowEvent;
import wins.SimpleWindow;
import wins.InvaderWindow;
import wins.actions.BanksWindow;
import wins.PurchaseWindow;

internal class GridIcon extends LayerX {
	
	public const EMPTY:uint = 0;
	public const OPEN:uint = 1;
	public const OWNER:uint = 2;
	public const TREASURE:uint = 3;
	public const CAPTURER:uint = 4;
	public const UNKNOWN:uint = 5;
	public const NEAR:uint = 6;
	public const KNOWN:uint = 7;
	public const CHEST:uint = 8;
	
	public static var choose:GridIcon;
	
	public var size:uint = 60;
	
	public var cell:int;
	public var row:int;
	public var open:int;
	public var id:int;
	public var require:Object;
	public var center:Point;
	public var window:UndergroundWindow;
	
	private var iconBack:Bitmap;
	private var icon:Bitmap;
	private var bg:Bitmap;
	private var image:Sprite;
	
	public function GridIcon(data:Object) {
		cell = data.cell;
		row = data.row;
		open = data.open;
		id = data.id;
		require = data.require;
		window = data.window;
		
		//if (cell == 37 && row == 13)
			//trace();
		
		center = new Point(int(window.NODE_WIDTH * 0.5), int(window.NODE_HEIGHT * 0.5));
		
		draw();
		
		addEventListener(MouseEvent.CLICK, onClick);
		addEventListener(MouseEvent.MOUSE_OVER, onOver);
		addEventListener(MouseEvent.MOUSE_OUT, onOut);
		
		var info:Object = App.data.storage[sid];
		if (info) {
			tip = function():Object {
				return {
					title:	info.title,
					text:	info.description
				}
			}
		}
	}
	
	private function draw():void {
		
		bg = new Bitmap();
		addChild(bg);
		
		icon = new Bitmap();
		addChild(icon);
		
		switch (state) {
			case UNKNOWN:
				drawUnknown();
				break;
			case EMPTY:
				drawEmpty();
				break;
			case NEAR:
				drawNear();
				break;
			case KNOWN:
				drawKnown();
				break;
			case OPEN:
				drawOpen();
				break;
			case CHEST:
				drawChest();
				break;
			case TREASURE:
				drawTreasure();
				break;
			case CAPTURER:
				drawCapturer();
				break;
		}
		
	}
	
	public function get sid():int {
		return window.target.items[id];
	}
	
	public function get state():uint {
		//if (window.point.x == cell && window.point.y == row)
			//return OWNER;
		
		if (open == 1)
			return OPEN;
		
		if (id >= 0) {
			if (window.isCapturerRequire(require))
				return CAPTURER;
			
			return TREASURE;
		}
		
		if (window.target.nearIsOpen(cell, row))
			return NEAR;
		
		if (open == 2)
			return KNOWN;
		
		// Рядом с позицией
		/*if ((window.point.x == cell - 1 && window.point.y == row) ||
			(window.point.x == cell + 1 && window.point.y == row) ||
			(window.point.x == cell && window.point.y == row - 1) ||
			(window.point.x == cell && window.point.y == row + 1))
			return NEAR;*/
		
		return EMPTY;
	}
	
	/**
	 * Просто точка
	 */
	private function drawPoint(color:uint = 0xff0000, alpha:Number = 1):void {
		var shape:Shape = new Shape();
		shape.graphics.beginFill(color, alpha);
		shape.graphics.drawRoundRect( -10, -10, 20, 20, 10, 10);
		shape.graphics.endFill();
		shape.filters = [new BevelFilter(3, 90, 0xffffff, .2, 0x000000, .2, 3, 3)];
		
		addChild(shape);
	}
	
	
	private function drawOpen():void {
		var shape:Shape = new Shape();
		shape.graphics.beginFill(0x000000, 0.0);
		shape.graphics.drawRect(0, 0, 90, 90);
		shape.graphics.endFill();
		addChild(shape);
	}
	private function drawUnknown():void {
		bg.bitmapData = Window.texture('caveLand');// UserInterface.textures.ground6;
	}
	private function drawEmpty():void {
		bg.bitmapData = Window.texture('caveLand');// UserInterface.textures.ground6;
	}
	private function drawKnown():void {
		bg.bitmapData = UserInterface.textures['ground4'];
	}
	
	/**
	 * Ячейка с кладом
	 */
	private function drawTreasure():void {
		
		priceHolded = true;
		
		var price:int = window.getPrice(cell, row);
		
		bg.bitmapData = UserInterface.textures['ground3'];
		
		priceView = new Sprite();
		priceView.mouseChildren = false;
		priceView.mouseEnabled = false;
		addChild(priceView);
		
		var treasure:BitmapLoader = new BitmapLoader(sid, 70, 70);
		treasure.x = center.x - 35;
		treasure.y = center.y - 35;
		priceView.addChild(treasure);
		
	}
	
	/**
	 * Ячейка с захватчиком
	 */
	public var capturer:LayerX;
	private function drawCapturer():void {
		
		priceHolded = true;
		
		//var price:int = window.getPrice(cell, row);
		
		bg.bitmapData = Window.texture('caveBlock');// UserInterface.textures['ground' + String(int(3 + Math.random() * 2))];
		
		capturer = new LayerX();
		capturer.mouseChildren = false;
		capturer.mouseEnabled = false;
		addChild(capturer);
		
		//var treasure:Bitmap = new Bitmap(UserInterface.textures.stoneBlocker);
		//treasure.x = center.x - treasure.width * 0.5;
		//treasure.y = center.y - treasure.height * 0.5;
		//capturer.addChild(treasure);
		
	}
	
	private function drawChest():void {
		
		var link:* = Config.getIcon(App.data.storage[sid].type, App.data.storage[sid].preview);
		if (!link)
			link = window.getMainTreasureID(id);
		
		var treasure:BitmapLoader = new BitmapLoader(link, 60, 60);
		treasure.x = center.x - 30;
		treasure.y = center.y - 30;
		addChild(treasure);
		
		if (!window.target.nearIsOpen(cell, row))
			Effect.light(treasure, 0, 0);
	}
	
	private function drawNear():void {
		var ground:String = 'ground2'
		if (row >= 20) ground = 'ground3';
		if (row >= 40) ground = 'ground5';
		
		bg.bitmapData = UserInterface.textures[ground];
		
		icon.bitmapData = window.settings.pointYellow;
		icon.x = center.x - icon.width * 0.5;
		icon.y = center.y - icon.height * 0.5;
		
		var image:BitmapLoader = new BitmapLoader(window.target.currency, 50, 50);
		image.x = center.x - 25;
		image.y = center.y - 25;
		addChild(image);
		image.transform.colorTransform = new ColorTransform(1, 1, 1, 1, 32, 32, 32);
	}
	
	
	private var priceHolded:Boolean;
	private var priceView:Sprite;
	private var priceTween:TweenLite;
	/**
	 * Показать цену за эту ячейку
	 */
	public function showPrice(hold:Boolean = false):void {
		
		if (state != NEAR) return;
		if (priceView) return;
		
		if (priceHolded || choose == this) return;
		priceHolded = hold;
		
		clearPrice();
		
		var price:int = window.getPrice(cell, row);
		if (price <= 0) return;
		
		priceView = new Sprite();
		priceView.mouseChildren = false;
		priceView.mouseEnabled = false;
		addChild(priceView);
		
		var back:Bitmap = new Bitmap(window.settings.selectIcon, PixelSnapping.AUTO, true);
		back.x = -back.width * 0.5;
		back.y = -back.height * 0.5;
		priceView.addChild(back);
		
		var point:Bitmap = new Bitmap(window.settings.pointSelect, PixelSnapping.AUTO, true);
		point.x = -point.width * 0.5;
		point.y = -point.height * 0.5 - 1;
		priceView.addChild(point);
		
		var priceLabel:TextField = Window.drawText(price + '\n' + Locale.__e('flash:1464185112847'), {
			width:			40,
			textSize:		19,
			color:			0xfffbef,
			borderColor:	0x6d4927,
			textAlign:		'center',
			multiline:		true
		});
		priceLabel.x = -priceLabel.width * 0.5;
		priceLabel.y = -12;
		priceView.addChild(priceLabel);
		
		if (!hold) {
			priceView.scaleX = priceView.scaleY = 0;
			priceView.alpha = 0;
			priceTween = TweenLite.to(priceView, 0.25, { alpha:2, scaleX:1, scaleY:1, ease:Back.easeOut } );
		}
	}
	private function clearPrice():void {
		if (!priceView)
			return;
		
		if (contains(priceView))
			removeChild(priceView);
		
		priceView.removeChildren();
		priceView = null;
	}
	public function hidePrice():void {
		if (priceTween)
			priceTween.kill();
		
		if (!priceView)
			return;
		
		if (priceHolded || choose == this)
			return;
		
		priceTween = TweenLite.to(priceView, 0.15, { alpha:0, scaleX:0, scaleY:0, onComplete:clearPrice } );
	}
	
	
	public function onClick(e:MouseEvent = null):void {
		
		if (!window.picture.bitmapData || window.moveCounter > 2)
			return;
		
		if (window.mode != UndergroundWindow.MODE_DEFAULT)
			return;
		
		window.hideConfirm();
		select();
		
		if (state == CAPTURER) {
			window.showCapturer(this);
			return;
		}
		
		if (window.blockByBlocker(cell, row)) {
		//if (window.capturePoint) {
			window.blockReason(UndergroundWindow.CAPTURED);
			return;
		}
		
		if (state == NEAR)
			window.open(cell, row);
		
		if (state == TREASURE)
			window.showTreasure(this);
		
	}
	private function onOver(e:MouseEvent):void {
		if (window.mode != UndergroundWindow.MODE_DEFAULT)
			return;
		
		//window.showRoad(cell, row);
		//showPrice();
	}
	private function onOut(e:MouseEvent):void {
		window.clearRoad();
		hidePrice();
	}
	
	
	public function unselect():void {
		hidePrice();
	}
	public function select():void {
		if (GridIcon.choose == this) return;
		
		if (GridIcon.choose)
			GridIcon.choose.unselect();
		
		GridIcon.choose = this;
		window.setSelect(cell, row);
	}
	
	
	public function glowing(times:int = 0):void {
		if (!capturer) return;
		
		capturer.showGlowing(times);
	}
	
	
	public function dispose():void {
		removeEventListener(MouseEvent.CLICK, onClick);
		removeEventListener(MouseEvent.MOUSE_OVER, onOver);
		removeEventListener(MouseEvent.MOUSE_OUT, onOut);
		
		if (parent)
			parent.removeChild(this);
		
		if (GridIcon.choose == this)
			GridIcon.choose = null;
	}
	
}

internal class HiddenRewardList extends Sprite {
	
	public static const OPEN:uint = 1;
	public static const CLOSE:uint = 2;
	
	private const ITEM_WIDTH:uint = 210;
	private const ITEM_HEIGHT:uint = 230;
	private const ITEM_INDENT:uint = 10;
	
	private var background:Bitmap;
	private var paginator:Paginator;
	private var back:Bitmap;
	private var maska:Shape;
	public var rewardBttn:Button;
	
	private var mainContainer:Sprite;
	private var container:Sprite;
	
	private var window:UndergroundWindow;
	public var currWidth:int = 0;
	public var currHeight:int = 0;
	private var list:Array = [];
	
	public function HiddenRewardList(width:int, height:int, window:UndergroundWindow, list:Object = null, state:uint = 2) {
		
		this.window = window;
		this.state = state;
		
		currWidth = width;
		currHeight = height;
		
		App.self.addEventListener(AppEvent.ON_WHEEL_MOVE, onWheel);
		
		// Список 
		if (!list) list = { };
		for (var key:* in list) {
			this.list.push( {
				formula:list[key],
				order:key
			});
		}
		this.list.sortOn('order', Array.NUMERIC);
		
		
		mainContainer = new Sprite();
		addChild(mainContainer);
		
		// Backing
		background = Window.backing(currWidth, currHeight + 100, 50, 'alertBacking');
		mainContainer.addChild(background);
		
		back = Window.backing(currWidth - 100, currHeight, 50, 'windowBacking');
		back.x = 50;
		back.y = 60;
		//mainContainer.addChild(back);
		
		
		//
		container = new Sprite();
		container.x = back.x + 10;
		container.y = back.y + 10;
		mainContainer.addChild(container);
		
		maska = new Shape();
		maska.graphics.beginFill(0xff0000, 0.3);
		maska.graphics.drawRect(0, 0, ITEM_WIDTH, currHeight - 80);
		maska.graphics.endFill();
		maska.x = back.x + 10;
		maska.y = back.y + 10;
		mainContainer.addChild(maska);
		
		container.mask = maska;
		
		
		//
		rewardBttn = new Button( {
			width:		188,
			height:		52,
			caption:	Locale.__e('flash:1463411341026')
		});
		rewardBttn.addEventListener(MouseEvent.CLICK, onOpenToggle);
		rewardBttn.x = currWidth * 0.5 - rewardBttn.width * 0.5;
		mainContainer.addChild(rewardBttn);
		
		
		//
		paginator = new Paginator(1, 1, 0, {
			hasButtons:	false,
			hasPoints:	false
		});
		paginator.drawArrow(mainContainer, Paginator.LEFT, 0, 0, {});
		paginator.drawArrow(mainContainer, Paginator.RIGHT, 0, 0, {
			scaleX:			1,
			scaleY:			-1
		});
		paginator.addEventListener(WindowEvent.ON_PAGE_CHANGE, onPageChange);
		paginator.arrowLeft.x = -5;
		paginator.arrowLeft.y = 140;
		paginator.arrowLeft.rotation = 270;
		paginator.arrowRight.x = 50;
		paginator.arrowRight.y = 140;
		paginator.arrowRight.rotation = 90;
		paginator.arrowLeft.scaleX = paginator.arrowLeft.scaleY = 0.7;
		paginator.arrowRight.scaleX = paginator.arrowRight.scaleY = 0.7;
		
		//
		update();
		
		
		if (this.state == CLOSE) {
			mainContainer.y = currHeight;
			rewardBttn.y = -70;
		}
		
	}
	
	public function update():void {
		
		clear();
		
		for (var i:int = 0; i < list.length; i++) {
			var item:RewardItem = new RewardItem(list[i].formula, window, ITEM_WIDTH, ITEM_HEIGHT);
			item.x = 0;
			item.y = (ITEM_HEIGHT + ITEM_INDENT) * container.numChildren;
			container.addChild(item);
		}
		
		paginator.itemsCount = ((maska.height / (ITEM_HEIGHT + ITEM_INDENT)) < container.numChildren) ? container.numChildren - int(maska.height / (ITEM_HEIGHT + ITEM_INDENT)) + 1 : 0;
		paginator.update();
		
	}
	private function clear():void {
		while (container.numChildren) {
			var item:* = container.getChildAt(0);
			item.dispose();
		}
	}
	
	private var paginatorTween:TweenLite;
	private function onPageChange(e:WindowEvent = null):void {
		if (paginatorTween)
			paginatorTween.kill();
		
		var targetY:int = back.y + 10 - (ITEM_HEIGHT + ITEM_INDENT) * paginator.page;
		paginatorTween = TweenLite.to(container, 0.15, { y:targetY } );
	}
	
	public var state:uint = OPEN;
	private var moving:Boolean;
	public function onOpenToggle(e:MouseEvent = null):void {
		
		if (moving) return;
		moving = true;
		
		tutorialShowFirstGetted();
		
		if (state == OPEN) {
			TweenLite.to(mainContainer, 0.2, { y:currHeight } );
			TweenLite.to(rewardBttn, 0.2, { y:-70 , onComplete:function():void {
				moving = false;
				state = CLOSE;
			}} );
		}else {
			TweenLite.to(mainContainer, 0.2, { y:0 } );
			TweenLite.to(rewardBttn, 0.2, { y:0 , onComplete:function():void {
				moving = false;
				state = OPEN;
			}} );
		}
		
	}
	
	private function tutorialShowFirstGetted():void {
		
		for (var i:int = 0; i < container.numChildren; i++) {
			var item:RewardItem = container.getChildAt(i) as RewardItem;
			if (rewardBttn.__hasGlowing && item.have > 0)
				item.showGlowing();
			else
				item.hideGlowing();
		}
		
		rewardBttn.hideGlowing();
		rewardBttn.hidePointing();
	}
	
	private function onWheel(e:AppEvent = null):void {
		if (state != OPEN) return;
		
		if (e.params.delta > 0) {
			paginator.page --;
		}else {
			paginator.page ++;
		}
		paginator.update();
		
		onPageChange();
	}
	
	public function dispose():void {
		paginator.removeEventListener(WindowEvent.ON_PAGE_CHANGE, onPageChange);
		
		clear();
		
		App.self.removeEventListener(AppEvent.ON_WHEEL_MOVE, onWheel);
		
		rewardBttn.removeEventListener(MouseEvent.CLICK, onOpenToggle);
		
		if (parent)
			parent.removeChild(this);
		
	}
	
}

internal class RewardItem extends LayerX {
	
	private var preloader:Preloader;
	private var background:Bitmap;
	private var anime:Anime;
	private var titleLabel:TextField;
	private var haveLabel:TextField;
	private var nextLabel:TextField;
	private var buyBttn:Button;
	private var takeBttn:Button;
	private var icon:Bitmap;
	private var checkmark:Bitmap;
	private var interfaceContainer:Sprite;
	
	public var currWidth:int;
	public var currHeight:int;
	
	private var window:UndergroundWindow;
	public var formula:Object;
	public var info:Object;
	public var sid:uint;
	public var near:int;	// Дистанция до ближайшей части
	private var having:Array;	// Список элементов в наличии
	private var needing:Array;	// Список отсутствующих элементов
	
	
	public function RewardItem(formula:Object, window:UndergroundWindow, width:int, height:int) {
		
		this.window = window;
		this.formula = formula;
		
		currWidth = width;
		currHeight = height;
		sid = formula.out;
		info = Storage.info(sid);
		
		tip = function():Object {
			return {
				title:		info.title,
				text:		info.description
			}
		}
		
		having = [];
		needing = [];
		
		draw();
		update();
		
	}
	
	public function update():void {
		
		var total:uint = 0;
		
		having.length = 0;
		needing.length = 0;
		
		for (var key:* in formula.items) {
			total ++;
			if (App.user.stock.count(key) > 0) {
				having.push(key);
			}else {
				needing.push(key);
			}
		}
		
		if (window.treasures) {
			near = 9999;	// Сделать максимально удаленное
			
			for (var i:int = 0; i < window.treasures.length; i++) {
				var sid:int = window.getMainTreasureID(window.treasures[i].id);
				if (having.indexOf(sid) == -1 && formula.items.hasOwnProperty(sid) && window.treasures[i].distance > 0 && near > window.treasures[i].distance)
					near = window.treasures[i].distance;
			}
		}
		
		if (near == 9999) nextLabel.visible = false;
		else nextLabel.visible = true;
		
		nextLabel.text = Locale.__e('flash:1464268332480', [near]);
		haveLabel.text = having.length.toString() + '/' + total.toString();
		
		buyBttn.visible = false;
		takeBttn.visible = false;
		checkmark.visible = false;
		
		if (window.isTakeBefore(formula.out)) {
			checkmark.visible = true;
			haveLabel.visible = false;
			return;
		}
		
		if (having.length + 1 == total) {
			buyBttn.visible = true;
			
			if (!App.user.stock.check(window.target.currency, window.target.helpPrice(Underground.OPENTYPE_LAST))) {
				buyBttn.state = Button.DISABLED;
			}else {
				buyBttn.state = Button.NORMAL;
			}
		}else if (having.length >= total) {
			takeBttn.visible = true;
		}
	}
	
	public function get have():int {
		return having.length;
	}
	
	private function draw():void {
		if (!sid) return;
		
		var totalItems:int = 0;
		var completeItems:int = 0;
		for (var cid:* in formula.items) {
			totalItems ++;
			if (App.user.stock.count(cid) >= formula.items[cid])
				completeItems ++;
		}
		
		background = Window.backing(currWidth, currHeight, 20, (totalItems <= completeItems) ? 'itemBackingYellow' : 'itemBacking');
		addChild(background);
		
		loadContent();
		
		interfaceContainer = new Sprite();
		addChild(interfaceContainer);
		
		titleLabel = Window.drawText(info.title, {
			width:			currWidth * 0.8,
			textAlign:		'left',
			fontSize:		22,
			color:			0xf0fdff,
			borderColor:	0x584330,
			multiline:		true,
			wrap:			true
		});
		titleLabel.x = 10;
		titleLabel.y = 15;
		addChild(titleLabel);
		
		nextLabel = Window.drawText(' ', {
			width:			currWidth * 0.7,
			textAlign:		'left',
			fontSize:		19,
			color:			0x584330,
			borderColor:	0xf0fdff,
			multiline:		true,
			wrap:			true
		});
		nextLabel.x = 12;
		nextLabel.y = titleLabel.y + titleLabel.height;
		addChild(nextLabel);
		
		icon = new Bitmap(window.settings.puzzleIcon);
		icon.x = background.x + background.width - icon.width - 10;
		icon.y = background.y + 15;
		addChild(icon);
		
		haveLabel = Window.drawText('9/9', {
			width:			currWidth * 0.25,
			textAlign:		'center',
			fontSize:		24,
			color:			0xf0fdff,
			borderColor:	0x584330,
			multiline:		true,
			wrap:			true
		});
		haveLabel.x = icon.x + icon.width * 0.5 - haveLabel.width * 0.5;
		haveLabel.y = icon.y + icon.height + 2;
		addChild(haveLabel);
		
		buyBttn = new Button( {
			caption:		window.target.helpPrice(4),	// Цена за открытие точки с частью подарка
			width:			120,
			height:			36
		});
		buyBttn.addEventListener(MouseEvent.CLICK, onBuy);
		buyBttn.x = background.width * 0.5 - buyBttn.width * 0.5;
		buyBttn.y = background.height - buyBttn.height * 0.8;
		addChild(buyBttn);
		buyBttn.textLabel.x += 15;
		buyBttn.textLabel.y += 2;
		
		var currencyIcon:BitmapLoader = new BitmapLoader(window.target.currency, 32, 32);
		currencyIcon.x = 20;
		currencyIcon.y = 4;
		buyBttn.addChild(currencyIcon);
		
		takeBttn = new Button( {
			onClick:	onTake,
			width:		120,
			height:		36,
			caption:	Locale.__e('flash:1382952379737')
		});
		takeBttn.x = background.width * 0.5 - takeBttn.width * 0.5;
		takeBttn.y = background.height - takeBttn.height * 0.8;
		addChild(takeBttn);
		
		checkmark = new Bitmap(window.settings.checknarkBig, PixelSnapping.AUTO, false);
		checkmark.x = background.width - checkmark.width * 1.25;
		checkmark.y = background.height - checkmark.height * 1.2;
		addChild(checkmark);
	}
	
	
	// Докупить последнюю часть
	private function onBuy(e:MouseEvent):void {
		if (buyBttn.mode == Button.DISABLED) return;
		buyBttn.state = Button.DISABLED;
		
		var point:Point = BonusItem.localToGlobal(buyBttn);
		Hints.minus(window.target.currency, window.target.helpPrice(4), point, false, window);
		
		if (needing.length == 1)
			window.openLastCell(needing[0]);
	}
	
	
	// Собрать подарок из частей
	private function onTake(e:MouseEvent = null):void {
		if (takeBttn.mode == Button.DISABLED) return;
		takeBttn.state = Button.DISABLED;
		
		window.takeReward(formula.ID, update);
	}
	
	
	private function loadContent():void {
		var link:String = Config.getSwf(info.type, info.view);
		Load.loading(link, onLoad);
		
		if (anime) return;
		
		preloader = new Preloader();
		preloader.x = background.width * 0.5;
		preloader.y = background.height * 0.5;
		addChild(preloader);
	}
	private function onLoad(swf:*):void {
		if (preloader && contains(preloader))
			removeChild(preloader);
		
		var walking:Boolean = false;
		for (var animation:* in swf.animation.animations) {
			if (swf.animation.animations[animation].frames[0] is Array)
				walking = true;
		}
		
		anime = new Anime(swf, { w:background.width * 0.7, h:background.height * 0.7, walking:walking } );
		anime.x = background.width * 0.5 - anime.width * 0.5;
		anime.y = background.height * 0.5 - anime.height * 0.5;
		addChildAt(anime, getChildIndex(background) + 1);
	}
	
	public function dispose():void {
		
		if (anime) {
			anime.stopAnimation();
			removeChild(anime);
		}
		
		if (parent)
			parent.removeChild(this);
		
		buyBttn.removeEventListener(MouseEvent.CLICK, onBuy);
		buyBttn.dispose();
		buyBttn = null;
		
		takeBttn.dispose();
		takeBttn = null;
	}
	
}

internal class ConfirmButton extends Button {
	
	private var dialog:Bitmap;
	
	public function ConfirmButton(settings:Object = null):void {
		
		if (!settings) settings = null;
		
		settings['width'] = 90;
		settings['height'] = 40;
		settings['radius'] = 15;
		
		super(settings);
		
	}
	
	override protected function MouseDown(e:MouseEvent):void {
		effect(0, 0.6);
	}
	override protected function MouseUp(e:MouseEvent):void {
		effect(0, 1);
	}
	
	override protected function drawBottomLayer():void {
		
		super.drawBottomLayer();
		
		dialog = new Bitmap(UserInterface.textures.priceView2, PixelSnapping.AUTO, true);
		dialog.x = -3;
		dialog.y = -5;
		bottomLayer.addChildAt(dialog, 0);
		
		bottomLayer.x = -46;
		bottomLayer.y = -dialog.height + 5;
		
	}
	
	override protected function drawTopLayer():void {
		
		// Добавить под кнопку (ее визуальную часть)
		
		var icon:BitmapLoader = new BitmapLoader(settings.sid, 30, 30);
		icon.x = -dialog.width * 0.5 + dialog.x + 16;
		icon.y = -dialog.height + dialog.y + 15;
		addChild(icon);
		
		var priceLabel:TextField = Window.drawText(settings.price, {
			color:		0x783200,
			borderColor:0xf3f3f1,
			fontSize:	30,
			width:		56,
			textAlign:	'center'
		});
		priceLabel.x = -dialog.width * 0.5 + dialog.x + dialog.width - priceLabel.width;
		priceLabel.y = -dialog.height + dialog.y + 14;
		addChild(priceLabel);
		
	}
	
}

internal class CurrencyCounter extends LayerX {
	
	private var back:Bitmap;
	private var plusBttn:ImageButton;
	private var icon:BitmapLoader;
	private var countLabel:TextField;
	
	private var window:UndergroundWindow;
	private var info:Object;
	private var currency:int;
	
	public function CurrencyCounter(window:UndergroundWindow, currency:int, params:Object = null) {
		this.window = window;
		this.currency = currency;
		info = App.data.storage[currency];
		
		back = new Bitmap(window.settings.coinsBar);
		addChild(back);
		
		plusBttn = new ImageButton(window.settings.coinsPlusBttn, {});
		plusBttn.x = back.width - plusBttn.width * 0.5;
		plusBttn.y = -1;
		plusBttn.addEventListener(MouseEvent.CLICK, onPlus);
		addChild(plusBttn);
		plusBttn.visible = !(params && params.buy === false);
		
		countLabel = Window.drawText(App.user.stock.count(currency).toString(), {
			width:		back.width,
			color:		0xfbdb38,
			borderColor:0x682c00,
			textAlign:	'center',
			fontSize:	22
		});
		countLabel.y = 6;
		addChild(countLabel);
		
		icon = new BitmapLoader(currency, 50, 50);
		icon.x = -30;
		icon.y = back.height * 0.5 - icon.height * 0.5;
		addChild(icon);
		
		App.self.addEventListener(AppEvent.ON_CHANGE_STOCK, update);
		
		tip = function():Object {
			var time:int = window.target.restore + window.target.info.time - App.time;
			if (time < 0) time = 0;
			
			if (currency == window.target.currency) {
				if (App.user.stock.count(currency) >= window.target.info.limit) {
					return {
						title:		info.title,
						text:		info.description
					}
				}else {
					return {
						title:		info.title,
						text:		TimeConverter.timeToStr(time),
						timer:		true
					}
				}
			}else {
				return {
					title:		info.title,
					text:		info.description
				}
			}
		}
	}
	
	private function onPlus(e:MouseEvent):void {
		//window.getCurrency();
		if (currency == Stock.FANT) {
			window.close();
			new BanksWindow( { section:BanksWindow.REALS } ).show();
			return;
		}
		
		if (currency == 2617) {
			new SimpleWindow( {
				popup:true,
				text:Locale.__e('flash:1472638724975'),
				title:Locale.__e('flash:1382952379893')
			}).show();
			return;
		}
		
		var content:Array = PurchaseWindow.createContent('Energy', { view:App.data.storage[currency].view } );
		new PurchaseWindow( {
			popup:		true,
			width:		716,
			itemsOnPage:content.length,
			content:	content,
			title:		App.data.storage[currency].title,
			hasDescription:(currency == 2624) ? true : false,
			description:Locale.__e('flash:1472652747853'),//App.data.storage[currency].description,
			callback:	function(sID:int):void {
				/*var object:Object = App.data.storage[sID];
				App.user.stock.add(object.out, object.count);*/
				
				//currencyCounter.update();
			}
		}).show();
	}
	
	public function update(e:AppEvent = null):void {
		countLabel.text = App.user.stock.count(currency).toString();
		//plusBttn.removeEventListener(MouseEvent.CLICK, onPlus);
	}
	
}

import wins.UndergroundPresentWindow;
internal class TreasureItem extends Sprite {
	private var bitmap:*;
	private var window:UndergroundWindow;
	private var preloader:Preloader = new Preloader();
	private var info:Object = { };
	public var have:int;
	public var need:int;
	public var sid:int;
	public function TreasureItem(window:UndergroundWindow, object:Object) {
		if (object.have)
			have = object.have;
		
		if (object.need)
			need = object.need;
		
		this.sid = object.sid;
		this.window = window;
		info = App.data.storage[object.sid];
		
		bitmap = new BitmapLoader(object.sid, 50, 50, 0.6);
		addChild(bitmap);
		
		drawCounters();
		
		addEventListener(MouseEvent.CLICK, onClick);
	}
	
	private function onClick(e:MouseEvent):void {
		var reward:Object = Treasures.getTreasureItems(App.data.storage[sid].treasure);
		
		//TODO:: create static method Treasures.getTreasureChances(treasure);
		var chances:Object;
		var treasureID:Object = App.data.storage[sid].treasure;
		var treasureInfo:Object = App.data.treasures[treasureID];
		var treasureChances:Object = App.data.treasures[treasureID][App.data.storage[sid].treasure]. probability;
		chances = App.data.treasures[treasureID][App.data.storage[sid].treasure].probability;
		//
		
		new UndergroundPresentWindow( {
			popup:		true,
			title:		Locale.__e('flash:1472570406246'),
			reward:		reward,
			description:App.data.storage[sid].title,
			noCount:	true,
			chances:	chances,
			onClick:	null
		}).show();
	}
	
	public var textField:TextField = Window.drawText('0/0', {
		fontSize	:26,
		textAlign	:'left',
		color		:0xffffff,
		borderColor	:0x643a00
	});
	public function drawCounters():void {
		textField.text = have+'/'+need;
		textField.x = bitmap.width;
		textField.y = (bitmap.height - textField.textHeight) / 2;
		if (!textField.parent) addChild(textField);
	}
	
	public function update():void {
		have = window.getTreasuresCount(sid);
		need = window.getTreasuresNeed(sid);
		
		drawCounters();
	}
}

internal class CurrencyPanel extends LayerX {
	private var gemsPanel:CurrencyCounter;
	private var shovelPanel:CurrencyCounter;
	private var dynamitPanel:CurrencyCounter;
	private var keyPanel:CurrencyCounter;
	private var bucksPanel:CurrencyCounter;
	
	private var window:UndergroundWindow;
	
	public function CurrencyPanel(window:UndergroundWindow):void {
		this.window = window;
		
		gemsPanel = new CurrencyCounter(window, window.target.money, { buy:false } );
		shovelPanel = new CurrencyCounter(window, window.target.currency);
		dynamitPanel = new CurrencyCounter(window, window.target.burst);
		keyPanel = new CurrencyCounter(window, 2913);
		bucksPanel = new CurrencyCounter(window, Stock.FANT);
		
		shovelPanel.y = gemsPanel.y + gemsPanel.height + 1;
		dynamitPanel.y = shovelPanel.y + shovelPanel.height + 1;
		keyPanel.y = dynamitPanel.y + dynamitPanel.height + 1;
		bucksPanel.y = keyPanel.y + keyPanel.height + 1;
		
		addChild(gemsPanel);
		addChild(shovelPanel);
		addChild(dynamitPanel);
		addChild(keyPanel);
		addChild(bucksPanel);
	}
	
	public function update():void {
		gemsPanel.update();
		shovelPanel.update();
		dynamitPanel.update();
		keyPanel.update();
		bucksPanel.update();
	}
}