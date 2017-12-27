package wins 
{
	import buttons.Button;
	import buttons.ImageButton;
	import buttons.ImagesButton;
	import com.greensock.TweenLite;
	import com.greensock.easing.Bounce;
	import com.pathfinder.Coordinate;
	import core.Load;
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
	import flash.utils.setTimeout;
	import ui.Hints;
	import ui.UserInterface;
	import units.Minigame;
	
	public class MinigameWindow extends Window 
	{
		public static const MODE_DEFAULT:uint = 1;
		public static const MODE_CHOOSE_ZONE:uint = 2;
		public static const MODE_ZONE_WAIT:uint = 3;
		
		public static const DEFAULT:uint = 0;		// Рабочий режим
		public static const MOVING:uint = 1;		// Режим ожидания хода (проигрывание анимации до конца)
		public static const BUYING:uint = 2;		// Режим докупки
		public static const TREASURING:uint = 3;	// Режим забирания клада
		public static const EXPIRE:uint = 4;	// Режим забирания клада
		
		
		private const NODE_INDENT:uint = 100;
		private const NODE_WIDTH:uint = 100;			// Отступ по ширине
		private const NODE_HEIGHT:uint = 100;		// Отступ по высоте
		private const VISION_RANGE:uint = 1;		// Дальность видимости
		
		
		private const fillColor:uint = 0x99000000;
		
		private var picture:Bitmap;
		private var mapContainer:Sprite;
		private var map:Sprite;
		private var road:Sprite;
		private var gridFader:Sprite;
		private var underLayer:Sprite;
		private var maskBitmapData:BitmapData;
		private var mapBitmapData:BitmapData;
		private var ownerItem:GridIcon;
		private var hiddenRewardList:HiddenRewardList;
		private var currencyCounter:CurrencyCounter;
		
		private var resizeBttn:ImagesButton;
		private var helpBttn:ImageButton;
		private var helpOpenButton:Button;
		
		public var target:Minigame;
		
		private var pictureURL:String;
		public var indent:int = 0;
		public var moveCounter:uint = 0;
		private var needUpdateFader:Boolean = true;
		
		public var treasures:Array;
		public var rewards:Object;
		
		public var openPoints:Vector.<Point>;
		public var closePoints:Vector.<Point>;
		
		public function MinigameWindow(settings:Object=null) {
			
			if (!settings) settings = { };
			
			target = settings.target;
			
			settings['faderClickable'] = settings['faderClickable'] || false;
			//settings['autoClose'] = settings['autoClose'] || false;
			//settings['strong'] = settings['strong'] || true;
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
			settings['selectIcon'] = UserInterface.textures.freebyBttn;
			settings['selectIconPuzzle'] = UserInterface.textures.selectIconPuzzle;
			settings['puzzleIcon'] = UserInterface.textures.puzzleIcon;
			settings['puzzleBrownIcon'] = UserInterface.textures.puzzleBrownIcon;
			settings['pointEmpty'] = UserInterface.textures.pointEmpty;
			settings['pointTarget'] = UserInterface.textures.pointTarget;
			settings['pointSelect'] = UserInterface.textures.pointSelect;
			settings['iconExpansion'] = UserInterface.textures.iconExpansion;
			settings['roadYellow'] = UserInterface.textures.roadYellow;
			settings['roadBlue'] = UserInterface.textures.roadBlue;
			settings['priceView'] = UserInterface.textures.priceView;
			settings['smallBacking'] = Window.textures.itemBacking;
			settings['friendsBacking'] = UserInterface.textures.defaultNeiborAvatar;
			settings['bttn'] = Window.textures.bttn;
			settings['systemFullscreen'] = UserInterface.textures.optionsFullscreenIco;
			settings['checknarkBig'] = Window.textures.checkMark;
			settings['coinsBar'] = UserInterface.textures.panelMoney;
			settings['coinsPlusBttn'] = UserInterface.textures.addBttnYellow;
			
			// Переменные
			pictureURL = Config.getImage('content', 'minigame', 'jpg');
			openPoints = new Vector.<Point>;
			closePoints = new Vector.<Point>;
			
			super(settings);
			
			addEventListener(WindowEvent.ON_AFTER_OPEN, onAfterOpen);
			
		}
		
		override public function drawBackground():void {}
		
		private function onAfterOpen(e:WindowEvent):void {
			removeEventListener(WindowEvent.ON_AFTER_OPEN, onAfterOpen);
			target.initTutorial();
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
			
			helpOpenButton.x = 10;
			helpOpenButton.y = settings.height - helpOpenButton.height - 5;
			
			hiddenRewardList.dispose();
			hiddenRewardList = new HiddenRewardList(330, App.self.stage.stageHeight - 60, this, rewards, Minigame.save.panelState);
			hiddenRewardList.x = App.self.stage.stageWidth - hiddenRewardList.currWidth + 25;
			hiddenRewardList.y = 60;
			bodyContainer.addChild(hiddenRewardList);
			
			createMap();
			focusOnOwner(0);
			
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
		
		override public function drawBody():void {
			exit.x = settings.width - exit.width - 8;
			exit.y = 8;
			
			treasures = target.getTreasures();
			rewards = target.getRewards();
			
			//maskBitmapData = new BitmapData(INDENT_WIDTH * 2 + NODE_WIDTH * target.gridCells, INDENT_HEIGHT * 2 + NODE_HEIGHT * target.gridRows, true, fillColor);
			//maskBitmapData = new BitmapData(200,200,true,fillColor);
			
			var back:Shape = new Shape();
			back.graphics.beginFill(0x666666);
			back.graphics.drawRect(0, 0, 100, 100);
			back.graphics.endFill();
			back.width = settings.width;
			back.height = settings.height;
			bodyContainer.addChild(back);
			
			mapContainer = new Sprite();
			map = new Sprite();
			gridFader = new Sprite();
			road = new Sprite();
			underLayer = new Sprite();
			
			//underLayer.mouseChildren = false;
			//underLayer.mouseEnabled = false;
			
			mapContainer.addChild(gridFader);
			mapContainer.addChild(road);
			mapContainer.addChild(map);
			mapContainer.addChild(underLayer);
			bodyContainer.addChild(mapContainer);
			
			mapContainer.addEventListener(MouseEvent.CLICK, onMapClick);
			mapContainer.addEventListener(MouseEvent.MOUSE_DOWN, onMapDown);
			mapContainer.addEventListener(MouseEvent.MOUSE_MOVE, onMapMove);
			
			createMap();
			focusOnOwner(0);
			
			hiddenRewardList = new HiddenRewardList(330, App.self.stage.stageHeight - 60, this, rewards, Minigame.save.panelState);
			hiddenRewardList.x = App.self.stage.stageWidth - hiddenRewardList.currWidth + 25;
			hiddenRewardList.y = 60;
			bodyContainer.addChild(hiddenRewardList);
			
			// Картинка сзади
			picture = new Bitmap();
			mapContainer.addChildAt(picture, 0);
			
			Load.loading(pictureURL, function(data:Bitmap):void {
				picture.bitmapData = data.bitmapData;
				picture.smoothing = true;
				
				if (picture.width / picture.height > gridFader.width / gridFader.height) {
					picture.height = gridFader.height;
					picture.scaleX = picture.scaleY;
					picture.x = gridFader.width * 0.5 - picture.width * 0.5;
				}else {
					picture.width = gridFader.width;
					picture.scaleY = picture.scaleX;
					picture.y = gridFader.height * 0.5 - picture.height * 0.5;
				}
			} );
			
			// Помощь
			helpBttn = drawHelp();
			helpBttn.x = exit.x - exit.width - 5;
			helpBttn.y = exit.y;
			exit.parent.addChild(helpBttn);
			helpBttn.addEventListener(MouseEvent.CLICK, onHelpEvent);
			
			// Ресайз
			resizeBttn = new ImagesButton(settings.bttn, settings.systemFullscreen);
			resizeBttn.x = helpBttn.x - helpBttn.width - 5;
			resizeBttn.y = exit.y;
			bodyContainer.addChild(resizeBttn);
			resizeBttn.addEventListener(MouseEvent.CLICK, App.ui.systemPanel.onFullscreenEvent);
			
			helpOpenButton = new Button( {	// target.info.text2
				width:		120,
				height:		50,
				caption:	Locale.__e('flash:1382952380254')
			});
			helpOpenButton.addEventListener(MouseEvent.CLICK, onHelp);
			helpOpenButton.x = 10;
			helpOpenButton.y = settings.height - helpOpenButton.height - 5;
			bodyContainer.addChild(helpOpenButton);
			
			drawUpPanel();
			
			currencyCounter = new CurrencyCounter(this);
			currencyCounter.x = 30;
			currencyCounter.y = 20;
			bodyContainer.addChild(currencyCounter);
		}
		
		private function onHelp(e:MouseEvent):void {
			
			if (!target.checkVerify('help')) return;
			
			mode = MODE_DEFAULT;
			
			new MinigameHelpWindow({
				title:Locale.__e('flash:1382952380254'),
				content:[
					{
						target:{
							sid:target.currency,
							count:target.helpPrice(2),
							title:Locale.__e('flash:1464352533413'),
							description:Locale.__e('flash:1464765572943')
						},
						link:Config.getImage('content', 'MiniGameHelpPic2'),
						func:openRandomPoint
					},
					{
						target:{
							sid:target.currency,
							count:target.helpPrice(1),
							title:Locale.__e('flash:1464352491797'),
							description:Locale.__e('flash:1464765647660')
						},
						link:Config.getImage('content', 'MiniGameHelpPic3'),
						func:openTreasurePoint
					},
					{
						target:{
							sid:target.currency,
							count:target.helpPrice(3),
							title:Locale.__e('flash:1464352320601'),
							description:Locale.__e('flash:1464765684451')
						},
						link:Config.getImage('content', 'MiniGameHelpPic4'),
						func:open9Points
					}
				]
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
			
			var backing:Bitmap = Window.backing(480, 220, 50, 'alertBacking');
			upPanel.addChild(backing);
			
			var titleLabel:TextField = Window.drawText(settings.title,{
				fontSize	:36,
				textAlign	:'left',
				color		:0xffffff,
				borderColor	:0x643a00
			});
			titleLabel.width = titleLabel.textWidth + 5;
			upPanel.addChild(titleLabel);
			titleLabel.x = backing.x + (backing.width - titleLabel.textWidth) / 2;
			titleLabel.y = backing.y + (backing.height - titleLabel.textHeight) * 0.7;
			
			timerContainer = new Sprite();
			upPanel.addChild(timerContainer);
			
			timerBacking = Window.backing(250, 60, 10, 'itemBacking');
			timerContainer.addChild(timerBacking);
			
			timerContainer.x = (App.self.stage.stageWidth - timerContainer.width) / 2;
			timerContainer.y = backing.y + backing.height - 50;
			
			clockContainer = new Sprite(); 
			var clockBitmap:Bitmap = new Bitmap(Window.texture('clock'), "auto", true);
			clockBitmap.transform.colorTransform = new ColorTransform(0,0,0,1,111,85,28);
			clockContainer.addChild(clockBitmap);
			clockContainer.filters = [new GlowFilter(0xffffff)];
			clockContainer.scaleX = clockContainer.scaleY = 0.5;
			clockContainer.x = timerBacking.x + 20;
			clockContainer.y = timerBacking.y + (timerBacking.height - clockContainer.height) * 0.5;
			timerContainer.addChild(clockContainer);
			timerText = Window.drawText(Locale.__e('flash:1382952379794',''),{
				fontSize	:22,
				textAlign	:'left',
				color		:0xffffff,
				borderColor	:0x643a00
			});
			timerText.x = clockContainer.x + clockContainer.width + 10;
			timerText.y = clockContainer.y + (clockContainer.height - timerText.textHeight) * 0.5;
			timerContainer.addChild(timerText);
			
			timer = Window.drawText('00:00:00', {
				fontSize	:28,
				textAlign	:'center',
				color		:0xf8dd46,
				borderColor	:0x643a00
			});
			timer.x = timerText.x + timerText.textWidth;
			timer.y = clockContainer.y + (clockContainer.height - timer.textHeight) * 0.5;
			timerContainer.addChild(timer);
			
			upPanel.x = (App.self.stage.stageWidth - upPanel.width) / 2;
			upPanel.y = -120;
			
			updateTimer();
			App.self.setOnTimer(updateTimer);
		}
		
		private function onHelpEvent(e:MouseEvent):void {
			/*new HelpWindow( {
				title:		settings.title,
				background:	'windowMain',
				width:		560,
				indent:		60,
				heightAdd:	50,
				content:	[
					{sid:4487, text:Locale.__e('flash:1464611904259') },
					{link:Config.getImage('content', 'Minigame_Help1'), text:Locale.__e('flash:1464611950208') },
					{link:Config.getImage('content', 'golden_chest'), text:Locale.__e('flash:1464612019951') },
					{link:Config.getImage('content', 'Minigame_Help4'), text:Locale.__e('flash:1464611975680') }
				]
			}).show();*/
			new InfoWindow({qID:'minigame'}).show();
		}
		
		private function updateTimer():void{
			timer.text = TimeConverter.timeToDays(target.expire - App.time);
			
			if (App.time > target.expire) {
				block = EXPIRE;
				timer.text = "00:00:00";
				//this.close();
			}
			upPanel.x = (App.self.stage.stageWidth - upPanel.width) / 2;
			timerBacking.width = clockContainer.width + timerText.width + timer.width + 5;
			timerContainer.x = (upPanel.width - timerContainer.width) / 2;
		}
		
		/**
		 * Блокировка
		 */
		public var block:uint = 0;
		
		
		/**
		 * Причина блокировки
		 */
		private function blockReason():void {
			var title:String = target.info.title;
			var text:String;
			
			switch(block) {
				case MOVING: text = Locale.__e('flash:1464335366978'); break;
				default: return;
			}
			
			new SimpleWindow( {
				popup:		true,
				title:		title,
				text:		text
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
			
			var bmd:BitmapData = new BitmapData(indent * 2 + NODE_WIDTH * target.gridCells, indent * 2 + NODE_HEIGHT * target.gridRows, true, fillColor);
			faderBMDs.push(bmd);
			
			var roundRect:Shape = new Shape();
			roundRect.graphics.beginFill(0, 1);
			roundRect.graphics.drawRoundRect(0, 0, NODE_WIDTH * 1.4, NODE_HEIGHT * 1.4, NODE_WIDTH * 0.4, NODE_HEIGHT * 0.4);
			roundRect.graphics.endFill();
			roundRect.filters = [new BlurFilter(NODE_WIDTH * 0.2, NODE_HEIGHT * 0.2)];
			
			//map.graphics.beginFill(0xff0000, 0.5);
			//map.graphics.drawRect(0, 0, INDENT_WIDTH * 2 + NODE_WIDTH * target.gridCells,INDENT_HEIGHT * 2 + NODE_HEIGHT * target.gridRows);
			//map.graphics.endFill();
			
			for (var i:int = 0; i < grid.length; i++) {
				for (var j:int = 0; j < grid[i].length; j++) {
					var object:Object = grid[i][j];
					var id:int = -1;
					var open:int = 0;
					var inVision:Boolean = false;
					var cpoint:Point = new Point(i, j);
					
					// Открыта ли ячейка
					if (object != 0) {
						if (object.hasOwnProperty('id'))
							id = object.id;
						
						open = object.o;
						
						if (open == 1)
							inVision = true;
						
					}
					
					// Или распространяется на нее видимость
					if (!inVision)
						inVision = isInVision(i, j, VISION_RANGE);
					
					if (!inVision && open == 0) {
						closePoints.push(cpoint);
						continue;
					}
					
					
					var place:Point = toCoords(new Point(i, j));
					var item:GridIcon = new GridIcon( {
						cell:	i,
						row:	j,
						id:		id,
						open:	open,
						window:	this
					});
					item.x = place.x;
					item.y = place.y;
					
					map.addChild(item);
					openPoints.push(cpoint);
					
					if (point.x == i && point.y == j)
						ownerItem = item;
					
					bmd.draw(roundRect, new Matrix(1, 0, 0, 1, int(item.x - NODE_WIDTH * 0.7), int(item.y - NODE_HEIGHT * 0.7)), null, BlendMode.ERASE);
					
					
					// Дорожки
					if (open == 1 && grid.length > i + 1 && grid[i + 1][j] && grid[i + 1][j].o == 1) {
						var bmp1:Bitmap = new Bitmap(settings.roadBlue);
						bmp1.rotation = 270;
						bmp1.x = place.x + 32;
						bmp1.y = place.y + 2;
						road.addChild(bmp1);
					}
					if (open == 1 && grid[i].length > j + 1 && grid[i][j + 1] && grid[i][j + 1].o == 1) {
						var bmp2:Bitmap = new Bitmap(settings.roadBlue);
						bmp2.x = place.x - 2;
						bmp2.y = place.y + 32;
						road.addChild(bmp2);
					}
				}
			}
			
			// Иконку пользователя поместить выше всех
			if (map.getChildAt(map.numChildren - 1) != ownerItem)
				map.swapChildren(ownerItem, map.getChildAt(map.numChildren - 1));
			
			if (needUpdateFader) {
				needUpdateFader = false;
				swapFaders();
			}
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
		 * Плавная замена затемнителя
		 */
		private var faderTween:TweenLite;
		private var faders:Vector.<Bitmap> = new Vector.<Bitmap>;
		private var faderBMDs:Vector.<BitmapData> = new Vector.<BitmapData>;
		private function swapFaders():void {
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
			
			var dragRectangle:Rectangle = new Rectangle(0, 0, settings.width - gridFader.width, settings.height - gridFader.height);
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
			
			/*var place:Point = toCoords(way[0]);
			road.graphics.lineStyle(4, 0x22cc66, 0.8);
			road.graphics.moveTo(place.x, place.y);
			
			for (var i:int = 1; i < way.length; i++) {
				place = toCoords(way[i]);
				road.graphics.lineTo(place.x, place.y);
			}*/
			
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
		
		
		// Движение по клеткам
		private var moveCells:Vector.<Coordinate>;
		private var movePrices:Vector.<int>;
		public function move(cell:int, row:int, confirm:Boolean = true):void {
			
			// Блокировка туториалом
			if (!target.checkVerify('move', cell, row)) return;
			
			if (mode != MODE_DEFAULT || moveCounter > 2) return;
			if (moveCells && moveCells.length > 0) return;
			
			if (confirm)
				showConfirm(cell, row, moveAction);
			else
				moveAction(cell, row);
		}
		private function moveAction(cell:int, row:int):void {
			if (block) {
				blockReason();
				return;
			}
			
			moveCells = target.getRoadTo(cell, row);
			moveCells.shift();
			movePrices = new Vector.<int>(moveCells.length, 0);
			
			// добавить цены за клетки
			for (var i:int = 0; i < moveCells.length; i++) {
				movePrices[i] = target.cellPrice(moveCells[i].x, moveCells[i].y);
			}
			
			checkFaderForUpdate();
			
			block = MOVING;
			
			target.goAction(moveCells, onMove);
		}
		private function onMove(bonus:Object = null):void {
			
			// Cоздать точку под OwnerItem
			var item:GridIcon = new GridIcon( {
				cell:	ownerItem.cell,
				row:	ownerItem.row,
				id:		-1,
				open:	true,
				window:	this
			});
			item.x = ownerItem.x;
			item.y = ownerItem.y;
			map.addChildAt(item, map.getChildIndex(ownerItem));
			
			animateMove(function(place:Point):void {
				block = DEFAULT;
				
				createMap();
				
				// Обновить доступные клады (их могло стать меньше)
				treasures = target.getTreasures();
				// Обновить боковую панель
				hiddenRewardList.update();
				currencyCounter.update();
				
				Treasures.bonus(bonus, toCoords(point), null, false, null, null, underLayer);
			});
		}
		private function animateMove(callback:Function = null, point:Object = null):void {
			if (!moveCells || moveCells.length == 0) {
				if (callback != null)
					callback(point);
			}else {
				
				var pos:Object = moveCells.shift();
				var price:int = movePrices.shift();
				var place:Point = toCoords(pos);
				
				TweenLite.to(ownerItem, 0.16, { x:place.x, y:place.y, onComplete:function():void {
					//Treasures.bonus( { 1:2 }, place, null, false, underLayer);
					Hints.minus(target.currency, price, place, false, underLayer);
					setTimeout(animateMove, 100, callback, place);
				}});
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
			return new Point(indent + NODE_WIDTH * 0.5 + NODE_WIDTH * place.x, indent + NODE_HEIGHT * 0.5 + NODE_HEIGHT * place.y);
		}
		
		
		/**
		 * Преобразовать точку карты в позицию сетки
		 */
		private function toPlace(place:Object):Point {
			return new Point(int((place.x - indent) / NODE_WIDTH), int((place.y - indent) / NODE_HEIGHT));
		}
		
		
		// Фокус на клекту где находится пользователь
		private function focusOnOwner(time:Number = 0.3, callback:Function = null):void {
			focusOn(point.x, point.y, time, callback);
		}
		// Фокус на клекту
		private function focusOn(cell:int, row:int, time:Number = 0.3, callback:Function = null):void {
			var targetX:int = settings.width * 0.5 - indent - NODE_WIDTH * cell;
			var targetY:int = settings.height * 0.5 - indent - NODE_HEIGHT * row;
			
			if (targetX < App.self.stage.stageWidth - indent * 2 - NODE_WIDTH * target.gridCells) targetX = App.self.stage.stageWidth - indent * 2 - NODE_WIDTH * target.gridCells;
			if (targetY < App.self.stage.stageHeight - indent * 2 - NODE_HEIGHT * target.gridRows) targetY = App.self.stage.stageHeight - indent * 2 - NODE_HEIGHT * target.gridRows;
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
			
			target.openAction(Minigame.OPENTYPE_LAST, treasure.x, treasure.y, function(bonus:Object = null):void {
				needUpdateFader = true;
				
				createMap();
				treasures = target.getTreasures();
				hiddenRewardList.update();
				currencyCounter.update();
				
				focusOn(treasure.x, treasure.y, 0.3, function():void {
					if (!bonus) return;
					Treasures.bonus(bonus, toCoords(new Point(treasure.x, treasure.y)), null, false);
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
				if (!Minigame.save[rewardID])
					Minigame.save[rewardID] = 0;
				
				Minigame.save[rewardID] ++;
				target.goSave(true);
			}
			
			Effect.wowEffect(rewardID);
			
			currencyCounter.update();
			
			if (rewardCallback != null) rewardCallback();
			rewardCallback = null;
		}
		public function isTakeBefore(sid:*):Boolean {
			return (Minigame.save[sid] > 0);
		}
		
		
		
		// Цена
		
		public var prices:Array;
		public function getPrice(cell:int, row:int):int {
			way = target.getRoadTo(cell, row);
			if (!way || way.length <= 1) return 0;
			
			prices = [];
			
			var price:int = 0;
			for (var i:int = 1; i < way.length; i++) {
				prices.push(target.cellPrice(way[i].x, way[i].y));
				price += prices[prices.length - 1];
			}
			
			return price;
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
			
			if (!App.user.stock.check(target.currency, price)) {
				new SimpleWindow( {
					popup:		true,
					title:		target.info.title,
					text:		Locale.__e('flash:1464622025139', [price - App.user.stock.count(target.currency)]),
					confirm:			getCurrency
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
			confirmBttn.x = place.x;
			confirmBttn.y = place.y - 40;
			confirmBttn.alpha = 0;
			confirmBttn.addEventListener(MouseEvent.CLICK, onConfirm);
			map.addChild(confirmBttn);
			
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
			if (!target.checkVerify('confirm')) return;
			
			hideConfirm();
			confirmCallback(confirmPoint.x, confirmPoint.y);
		}
		
		
		
		// Открытие точек зоны
		/**
		 * Произвольная закрытая точка
		 */
		private function openRandomPoint(e:MouseEvent = null):void {
			if (closePoints.length == 0) {
				new SimpleWindow( {
					popup:		true,
					title:		target.info.title,
					text:		Locale.__e('flash:1464171515197')
				}).show();
				
				return;
			}
			
			var index:int = int(closePoints.length * Math.random())
			var openPoint:Point = closePoints[index];
			
			if (!App.user.stock.check(target.currency, target.helpPrice(2))) {
				getCurrency();
				return;
			}
			
			target.openAction(Minigame.OPENTYPE_RANDOMPOINT, openPoint.x, openPoint.y, function(bonus:Object):void {
				closePoints.splice(index, 1);
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
			
			target.openAction(Minigame.OPENTYPE_POINT, openPoint.x, openPoint.y, function(bonus:Object):void {
				closePoints.splice(index, 1);
				needUpdateFader = true;
				currencyCounter.update();
				createMap();
				focusOn(openPoint.x, openPoint.y, 0.3, function():void {
					if (!bonus) return;
					Treasures.bonus(Treasures.treasureToObject(bonus), toCoords(new Point(openPoint.x, openPoint.y)), null, false);
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
			
			if (!App.user.stock.check(target.currency, target.helpPrice(3))) {
				getCurrency();
				return;
			}
			
			Hints.minus(target.currency, target.helpPrice(3), new Point(mouseX, mouseY), false, this);
			mode = MODE_ZONE_WAIT;
			
			target.openAction(Minigame.OPENTYPE_3X3ZONE, lastMarkerPoint.x, lastMarkerPoint.y, function():void {
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
			marker.graphics.lineStyle(2, 0x00ff00, 0.7, true);
			marker.graphics.beginFill(0x00ff00, 0.15);
			marker.graphics.drawRoundRect(NODE_WIDTH * cells * -0.55, NODE_HEIGHT * rows * -0.55, NODE_WIDTH * cells * 1.1, NODE_HEIGHT * rows * 1.1, NODE_WIDTH * 0.9, NODE_HEIGHT * 0.9);
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
			var content:Array = PurchaseWindow.createContent('Energy', { view:App.data.storage[target.currency].view } );
			new PurchaseWindow( {
				popup:		true,
				width:		716,
				itemsOnPage:content.length,
				content:	content,
				title:		App.data.storage[target.currency].title,
				description:Locale.__e("flash:1464346398152"),
				callback:	function(sID:int):void {
					/*var object:Object = App.data.storage[sID];
					App.user.stock.add(object.out, object.count);*/
					
					//currencyCounter.update();
				}
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
		public function tutorialShowRewards():void {
			hiddenRewardList.rewardBttn.showGlowing();
			hiddenRewardList.rewardBttn.showPointing('top', 0, -5, hiddenRewardList.rewardBttn.parent);
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
		}
		
	}

}

import buttons.Button;
import buttons.ImageButton;
import com.greensock.TweenLite;
import com.greensock.easing.Back;
import core.AvaLoad;
import core.Load;
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
import units.Minigame;
import units.Personage;
import wins.MinigameWindow;
import wins.Paginator;
import wins.Window;
import wins.WindowEvent;

internal class GridIcon extends LayerX {
	
	public const EMPTY:uint = 0;
	public const OPEN:uint = 1;
	public const OWNER:uint = 2;
	public const TREASURE:uint = 3;
	public const TREASURE_UNKNOWN:uint = 4;
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
	public var mainSID:int;
	public var mainReward:int;
	public var window:MinigameWindow;
	
	private var iconBack:Bitmap;
	private var icon:Bitmap;
	private var image:Sprite;
	
	public function GridIcon(data:Object) {
		cell = data.cell;
		row = data.row;
		open = data.open;
		id = data.id;
		window = data.window;
		
		if (id >= 0) {
			mainSID = window.getMainTreasureID(id);
			for each(var formula:* in window.rewards) {
				if (formula.items.hasOwnProperty(mainSID)) {
					mainReward = formula.out;
				}
			}
		}
		
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
		
		icon = new Bitmap();
		addChild(icon);
		
		switch (state) {
			case UNKNOWN:
			case EMPTY:
				drawUnknown();
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
			case OWNER:
				drawOwner();
				break;
			case CHEST:
				drawChest();
				break;
			case TREASURE:
				drawTreasure();
				break;
			case TREASURE_UNKNOWN:
				drawTreasureUnknown();
				break;
		}
		
	}
	
	public function get sid():int {
		return window.target.items[id];
	}
	
	public function get state():uint {
		if (window.point.x == cell && window.point.y == row)
			return OWNER;
		
		if (open == 1)
			return OPEN;
		
		if (id >= 0) {
			if (!mainReward)
				return CHEST;
			
			return TREASURE;
			if (window.target.nearIsOpen(cell, row))
				return TREASURE;
			else
				return TREASURE_UNKNOWN;
		}
		
		if (open == 2)
			return KNOWN;
		
		// Рядом с позицией
		if ((window.point.x == cell - 1 && window.point.y == row) ||
			(window.point.x == cell + 1 && window.point.y == row) ||
			(window.point.x == cell && window.point.y == row - 1) ||
			(window.point.x == cell && window.point.y == row + 1))
			return NEAR;
		
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
		icon.bitmapData = window.settings.pointTarget;
		icon.x = -icon.width * 0.5;
		icon.y = -icon.height * 0.5;
	}
	private function drawUnknown():void {
		icon.bitmapData = window.settings.pointEmpty;
		icon.x = -icon.width * 0.5;
		icon.y = -icon.height * 0.5;
	}
	private function drawKnown():void {
		icon.bitmapData = window.settings.pointSelect;
		icon.x = -icon.width * 0.5;
		icon.y = -icon.height * 0.5;
	}
	
	/**
	 * Позиция игрока
	 */
	private function drawOwner():void {
		
		icon.bitmapData = Window.backing(78, 82, 12, 'cursorsPanelBg2').bitmapData;
		icon.x = -icon.width * 0.5;
		icon.y = -icon.height * 0.5;
		
		iconBack = new Bitmap(window.settings.friendsBacking, 'auto', true);
		iconBack.x = -iconBack.width * 0.5;
		iconBack.y = -iconBack.height * 0.5;
		addChild(iconBack);
		
		image = new Sprite();
		addChild(image);
		
		new AvaLoad(App.user.photo, onLoad);
		
		function onLoad(bitmap:Bitmap):void {
			
			var bitmap:Bitmap = new Bitmap(bitmap.bitmapData, 'auto', true);
			bitmap.width = bitmap.height = 52;
			image.addChild(bitmap);
			
			var maska:Shape = new Shape();
			maska.graphics.beginFill(0xba944d, 1);
			maska.graphics.drawRoundRect(0, 0, 52, 52, 15, 15);
			maska.graphics.endFill();
			image.addChild(maska);
			
			bitmap.mask = maska;
			
			image.x = iconBack.x + (iconBack.width - image.width) / 2;
			image.y = iconBack.y + (iconBack.height - image.height) / 2;
		}
	}
	
	/**
	 * Ячейка с кладом
	 */
	private function drawTreasure():void {
		
		priceHolded = true;
		
		var price:int = window.getPrice(cell, row);
		
		priceView = new Sprite();
		priceView.mouseChildren = false;
		priceView.mouseEnabled = false;
		addChild(priceView);
		
		var back:Bitmap = new Bitmap(window.settings.selectIcon, PixelSnapping.AUTO, true);
		back.x = -back.width * 0.5;
		back.y = -back.height * 0.5;
		priceView.addChild(back);
		
		var treasure:BitmapLoader = new BitmapLoader((mainReward) ? mainReward : Config.getIcon(App.data.storage[sid].type, App.data.storage[sid].preview), 40, 40);
		treasure.transform.colorTransform = new ColorTransform(0, 0, 0, 1, 110, 68, 30);
		treasure.x = -treasure.width * 0.5;
		treasure.y = -treasure.height * 0.5;
		priceView.addChild(treasure);
		
		if (mainReward) {
			var puzzle:Bitmap = new Bitmap(window.settings.selectIconPuzzle, PixelSnapping.AUTO, true);
			puzzle.x = -55;
			puzzle.y = -50;
			priceView.addChild(puzzle);
		}
		
		if (price <= 0) return;
		var priceLabel:TextField = Window.drawText(price.toString(), {
			width:			40,
			textSize:		19,
			color:			0xfffbef,
			borderColor:	0x6d4927,
			textAlign:		'center',
			multiline:		true
		});
		priceLabel.x = -priceLabel.width * 0.5;
		priceLabel.y = 6;
		priceView.addChild(priceLabel);
		
	}
	
	private function drawTreasureUnknown():void {
		
		priceHolded = true;
		
		priceView = new Sprite();
		priceView.mouseChildren = false;
		priceView.mouseEnabled = false;
		addChild(priceView);
		
		var link:* = Config.getIcon(App.data.storage[sid].type, App.data.storage[sid].preview);
		if (!link)
			link = window.getMainTreasureID(id);
		
		var treasure:BitmapLoader = new BitmapLoader(link, 60, 60);
		treasure.x = -treasure.width * 0.5;
		treasure.y = -treasure.height * 0.5;
		priceView.addChild(treasure);
		
		Effect.light(treasure, 0, 0);
	}
	
	private function drawChest():void {
		
		//priceHolded = true;
		
		/*priceView = new Sprite();
		priceView.mouseChildren = false;
		priceView.mouseEnabled = false;
		addChild(priceView);*/
		
		var link:* = Config.getIcon(App.data.storage[sid].type, App.data.storage[sid].preview);
		if (!link)
			link = window.getMainTreasureID(id);
		
		var treasure:BitmapLoader = new BitmapLoader(link, 60, 60);
		treasure.x = -treasure.width * 0.5;
		treasure.y = -treasure.height * 0.5;
		addChild(treasure);
		
		if (!window.target.nearIsOpen(cell, row))
			Effect.light(treasure, 0, 0);
	}
	
	private function drawNear():void {
		showPrice(true);
	}
	
	
	private var priceHolded:Boolean;
	private var priceView:Sprite;
	private var priceTween:TweenLite;
	/**
	 * Показать цену за эту ячейку
	 */
	public function showPrice(hold:Boolean = false):void {
		
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
	
	
	private function onClick(e:MouseEvent):void {
		
		window.move(cell, row);
		
		if (GridIcon.choose != this) {
			var lastChoose:GridIcon = GridIcon.choose;
			GridIcon.choose = this;
			
			if (lastChoose)
				lastChoose.hidePrice();
		}
	}
	private function onOver(e:MouseEvent):void {
		if (window.mode != MinigameWindow.MODE_DEFAULT)
			return;
		
		window.showRoad(cell, row);
		showPrice();
	}
	private function onOut(e:MouseEvent):void {
		window.clearRoad();
		hidePrice();
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
	
	private var window:MinigameWindow;
	public var currWidth:int = 0;
	public var currHeight:int = 0;
	private var list:Array = [];
	
	public function HiddenRewardList(width:int, height:int, window:MinigameWindow, list:Object = null, state:uint = 2) {
		
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
		
		if (!window.target.checkVerify('rewards')) return;
		
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
	
	private var window:MinigameWindow;
	public var formula:Object;
	public var info:Object;
	public var sid:uint;
	public var near:int;	// Дистанция до ближайшей части
	private var having:Array;	// Список элементов в наличии
	private var needing:Array;	// Список отсутствующих элементов
	
	
	public function RewardItem(formula:Object, window:MinigameWindow, width:int, height:int) {
		
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
			
			if (!App.user.stock.check(window.target.currency, window.target.helpPrice(Minigame.OPENTYPE_LAST))) {
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
	
	private var window:MinigameWindow;
	
	public function CurrencyCounter(window:MinigameWindow) {
		
		this.window = window;
		
		back = new Bitmap(window.settings.coinsBar);
		addChild(back);
		
		plusBttn = new ImageButton(window.settings.coinsPlusBttn, {});
		plusBttn.x = back.width - plusBttn.width * 0.5;
		plusBttn.y = -1;
		plusBttn.addEventListener(MouseEvent.CLICK, onPlus);
		addChild(plusBttn);
		
		countLabel = Window.drawText(App.user.stock.count(window.target.currency).toString(), {
			width:		back.width,
			color:		0x682c00,
			borderColor:0xffe1ab,
			textAlign:	'center',
			fontSize:	22
		});
		countLabel.y = 5;
		addChild(countLabel);
		
		icon = new BitmapLoader(window.target.currency, 50, 50);
		icon.x = -30;
		icon.y = back.height * 0.5 - icon.height * 0.5;
		addChild(icon);
		
		App.self.addEventListener(AppEvent.ON_CHANGE_STOCK, update);
	}
	
	private function onPlus(e:MouseEvent):void {
		window.getCurrency();
	}
	
	public function update(e:AppEvent = null):void {
		countLabel.text = App.user.stock.count(window.target.currency).toString();
		//plusBttn.removeEventListener(MouseEvent.CLICK, onPlus);
	}
	
}