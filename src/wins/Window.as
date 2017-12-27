	package wins 
	{
		import buttons.Button;
		import buttons.ImageButton;
		import core.Log;
		import core.Post;
		import flash.display.Bitmap;
		import flash.display.BitmapData;
		import flash.display.DisplayObject;
		import flash.display.GradientType;
		import flash.display.Shape;
		import flash.display.Sprite;
		import flash.events.Event;
		import flash.events.KeyboardEvent;
		import flash.events.MouseEvent;
		import com.greensock.*
		import com.greensock.easing.*
		import flash.filters.BevelFilter;
		import flash.filters.BitmapFilterQuality;
		import flash.filters.DropShadowFilter;
		import flash.geom.Matrix;
		import flash.geom.Point;
		import flash.geom.Rectangle;
		import flash.text.Font;
		import flash.text.TextField;
		import flash.text.TextFieldAutoSize;
		import flash.text.TextFieldType;
		import flash.text.TextFormat;
		import flash.text.AntiAliasType;
		import flash.text.TextFormatAlign;
		import flash.filters.GlowFilter;
		import flash.utils.getQualifiedClassName;
		import flash.utils.setTimeout;
		import core.Load;
		import ui.BottomPanel;
		import ui.Cursor;
		import ui.SalesPanel;
		import ui.UserInterface;
		import units.Field;
		import units.Techno;
		import units.Unit;
		
		import com.demonsters.debugger.MonsterDebugger;
		
		
		public class Window extends Sprite
		{
			public static const DISABLED:int = 0;
			public static const ENABLED:int = 1;
			
			public static var fontScale:Number = 1;
			
			public static var textures:Object;
			static private var titleGlow:Boolean = true;
			private var showAfterLoad:Boolean = false; 
			private var textFilter:GlowFilter;
			
			//Вflash:1382952379993уальные свойства
			public var id:String						= '';					//Идентификатор окна
			public var opened:Boolean 					= false;
			public var settings:Object					= {
				content				: new Array(),
				type				: 'normal',				//Тип окна
				title				: Locale.__e('flash:1382952380330'),			//Заголовок окна
				titleScaleX			: 1,
				titleScaleY			: 1,
				multiline			: false,				//Многострочный текст
				fontSize			: 48,					//Размер шрифта
				fontColor	 		: 0xfefdff,				//Цвет шрифта	
				textLeading	 		: -3,					//Вертикальное расстояние между словами	
				fontBorderColor 	: 0xc09a53,				//Цвет обводки шрифта	
				fontBorderSize 		: 5,					//Размер обводки шрифта
				fontBorderGlow 		: 2,					//Размер размытия шрифта
				fontFamily			: 'font',		//Шрифт
				titleDecorate		: true,
				shadowColor			: 0x4c3f36,
				shadowSize			: 0,
				
				background			: 'alertBacking',	
				hasPaper			: false,
				hasTitle			: true,
				titleGlow			: true,
				autoClose			: false,				//Авто flash:1382952379984крытие окна при открытие другого
				forcedClosing		: false,				//Принудительное flash:1382952379984крытие окна 
				strong				: false,				//Принудительно не может быть flash:1382952379984крыто
				popup				: false,				//Всплывающее окно
				escExit				: true,					//Закрытие окна по Esc
				
				hasPaginator		: true,					//Окно с пагинацией
				hasButtons			: true,					//Окно со стрелками влево, вправо
				paginatorSettings 	: {},					//Настройки пагинатора
				
				hasArrows			: true,					//Окно со стрелками влево, вправо
				itemsOnPage			: 6,					//Кол-во итемов на странице
				buttonsCount		: 9,					//Кол-во кнопок в пейжинаторе
				hasFader			: true,					//Окно с подкладкой			
				faderClickable		: true,					//Окно с подкладкой			
				faderAlpha			: 0.3,					//Прозрачность фейдера
				hasAnimations		: true,					//Окно с анимацией при открытии и flash:1382952379984крытии
				hasExit				: true,					//Показывать кнопку flash:1382952379984крытия окна
			
				animationShowSpeed	: 0.3,					//Скорость анимации появления окна
				animationHideSpeed	: 0.1,					//Скорость анимации flash:1382952379984крытия окна
			
				faderAsClose		: true,					//Клик по подкладке flash:1382952379984крывает окно
				autoClose			: false,				//При открытии другого окна это flash:1382952379984крывается автоматически
				delay				: 200,					//Задержка при открытии окна в милисекундах
			
				currentPage			: 1,					//Текущая страница
			
				width				: 500,					//Ширина контейнера с окном
				height				: 500,					//Длина контейнера с окном	
				
				paperHeight			: 0,
				paperWidth			: 0,
							
				debug				: false,					//В Debug режиме отображаются рамки контейнера
				
				returnCursor		: true,
				hasDescription		: false,
				faderColor			: 0x000000,
				faderTime			: 0.3,
				exitScale			: 1, 
				smallExit			:false,
				
				openSound 			:'sound_3',
				closeSound 			:'sound_4'
				//exitType			: Window.EXIT_DEFAULT
			};
			
			//Части окна
			public var exit:ImageButton					= null;
			public var titleContainer:Sprite			= new Sprite();
			public var backgroundContainer:Sprite		= new Sprite();
			public var headerContainer:Sprite			= new Sprite();
			public var bodyContainer:Sprite				= new Sprite();
			public var bottomContainer:Sprite			= new Sprite();
			
			public var paginator:Paginator				= null;					//Объект Пагинатор
			public var layer:Sprite 					= new Sprite();			//Объект Фейдер
			public var fader:Sprite 					= null;			 		//Объект Фейдер
			
			public var content:*;													//Контент окна 
			
			protected var titleBar:Bitmap;
			protected var titleLabel:Sprite;
			protected var style:TextFormat;
			public var _bitmap:Bitmap = null;
			
			public var params:Object;
			
			public function Window(settings:Object = null) 
			{
				//Load.loading(Config.getInterface('windows'), onLoad);
				//MonsterDebugger.trace(this,this);
				
				Log.alert('Window: ' + getQualifiedClassName(this));
				//trace('Window: ' + getQualifiedClassName(this));
				
				//Переназначаем дефолтные настройки на пользовательские
				for (var property:* in settings) {
					this.settings[property] = settings[property];
				}
				//trace('window');
			}
			
			private function onLoad(data:*):void {
				textures = data;
				
				if (showAfterLoad) {
					showAfterLoad = false;
					show();
				}
			}
			
			public static function get isOpen():Boolean {
				var windowOpened:Boolean = false;
				for (var i:int = 0; i < App.self.windowContainer.numChildren; i++) {
					var window:* = App.self.windowContainer.getChildAt(i)
					if (window is Window && window.opened == true) {
						windowOpened = true;
					}
				}
				return windowOpened;
			}
			public static function hasType(type:Class):Boolean {
				for (var i:int = 0; i < App.self.windowContainer.numChildren; i++) {
					var window:* = App.self.windowContainer.getChildAt(i);
					if (window is type)
						return true;
				}
				
				return false;
			}
			
			public static function centerOn(sub:*,on:*):void {
				sub.x = on.x + (on.width - sub.width) / 2;
				sub.y = on.y + (on.height - sub.height) / 2;
			}
			public function drawHelp():ImageButton {
			var bttn:ImageButton = new ImageButton(Window.textures.bttn);
				var questionMark:TextField = Window.drawText('?', {
					fontSize:		36,
					border:			false,
					//borderColor:	0x776741,
					color:			0xFFFFFF,
					autoSize:		'center',
					filters:		[new DropShadowFilter(1,90,0x776741,1,0,0,1,1)]
				});
				
				questionMark.x = (bttn.width - questionMark.width) / 2 - 1;
				questionMark.y = (bttn.height - questionMark.height) / 2 + 3;
				bttn.addChild(questionMark);
				
				return bttn;
			}
			public static function localToGlobal(object:*):Point
			{
				var X:int = App.self.mouseX - object.mouseX + object.width/2;
				var Y:int = App.self.mouseY - object.mouseY;
				return new Point(X, Y);
			}
			
			public static function createdWindowType(type:*, content:*):Boolean {
				
				for (var i:int = 0; i < App.self.windowContainer.numChildren; i++) {
					var window:* = App.self.windowContainer.getChildAt(i)
					if (window is Window) {
						if (window.settings[type] != null && window.settings[type] == content)
							return true;
					}
				}
				return false;
			}
			
			public static function closeAll():void {
				for (var i:int = App.self.windowContainer.numChildren - 1; i > -1; i--) {
					var window:* = App.self.windowContainer.getChildAt(i);
					if (window is Window) window.close();
				}
			}
			
			public static function texture(texture:String):BitmapData {
				if (Window.textures.hasOwnProperty(texture)) {
					return Window.textures[texture];
				}else if (UserInterface.textures.hasOwnProperty(texture)) {
					return UserInterface.textures[texture];
				}
				
				return new BitmapData(1, 1, true, 0);
			}
			
			public function show():void {
				
				if(App.map != null){
					for each(var trans:Unit in App.map.transed) {
						var bmp:Bitmap = trans.bmp;
						
						trans.transparent = false;
						App.map.transed.splice(App.map.transed.indexOf(trans), 1);
					}
				}
				
				if(App.map != null){
					App.map.untouches();
					
					if (App.map.moved != null) {
						var unit:Unit = App.map.moved;
						
						if (unit is Field)
							Field.clearPlant();
						
						if (unit.formed) {
							unit.previousPlace();
						}else {
							unit.uninstall();
						}
						
						App.map.moved = null;
					}
				}
				
				App.tips.hide();
				
				Cursor.type = "default";
				Cursor.material = null;
				
				if (textures == null) {
					showAfterLoad = true;
					return;
				}
				
				
				var hasQueue:Boolean = false;
				for (var i:int = 0; i < App.self.windowContainer.numChildren; i++) {
					var backWindow:* = App.self.windowContainer.getChildAt(i);
					
					if (backWindow is Window && (settings.forcedClosing == true || backWindow.settings.autoClose == true)) {
						if (backWindow is LevelUpWindow) {
							hasQueue = true;
							return;
						}else if (backWindow.settings.strong) {
							hasQueue = true;
							//return;
						}else if((backWindow is AchivementMsgWindow)){
							backWindow.close();
							//hasQueue = true;
						}else if (settings.popup) { 
							backWindow.close();
						}else {
							//backWindow.close();
							hasQueue = true;
						}
					}else if(backWindow is Window && !(backWindow is MinigameWindow) && !(backWindow is AchivementMsgWindow)  &&  settings.popup == false) {
						hasQueue = true;
					}
				}
				
				App.self.windowContainer.addChild(this);
				if (SalesPanel.isSaleWindow) {
					App.self.windowContainer.setChildIndex(this, 0);
					SalesPanel.isSaleWindow = false;
				}
				layer.visible = false;
				addChild(layer);
				
				if (hasQueue == true) {
					return;
				}
				
				create();
				
				SoundsManager.instance.playSFX(settings.openSound);
				
			}
			
			/**
			 * Добавляем окно на сцену
			 * @param	e	Event
			 */
			private function onAddedToStage(e:Event):void {
				removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
				this.visible = false;
				create();
			}
		
			public function drawFader():void 
			{
				if (fader==null && settings.hasFader) {
					fader = new Sprite();
						
					fader.graphics.beginFill(settings.faderColor);
					fader.graphics.drawRect(0, 0, App.self.stage.stageWidth, App.self.stage.stageHeight);
					fader.graphics.endFill();

					addChildAt(fader, 0);

					fader.alpha = settings.faderAlpha;
					
					var finishX:Number = (App.self.stage.stageWidth - settings.width) / 2;
					var finishY:Number = (App.self.stage.stageHeight - settings.height) / 2;
					
					//TweenLite.to(fader, settings.faderTime, { alpha:settings.faderAlpha } );
				}
			}
			
			protected function onFaderClick(e:MouseEvent):void 
			{
				if (App.user.quests.tutorial) return;
				
				if(fader.hasEventListener(MouseEvent.CLICK)){
					fader.removeEventListener(MouseEvent.CLICK, onFaderClick);
				}
				
				if(settings.faderClickable == true){
					close();
				}
			}
			
			/**
			 * Отрисовываем окно, при необходимости flash:1382952379984пускаем анимацию появления окна
			 */
			protected var clearQuestsTargets:Boolean = false;
			public function create():void {
				
				opened = true;
					
				if (Quests.help) {
					clearQuestsTargets = true;
				}
			
				dispatchEvent(new WindowEvent( "onBeforeOpen"));
				
				dispatchEvent(new WindowEvent( "onContentRequest"));
				
				drawFader();
				drawHeader();
				drawBottom();
				drawBackground();
				//drawHeader();
				drawBody();
				if(settings.hasPaginator && settings.hasArrows){
					drawArrows();
				}
				
			
				
				
				layer.addChild(bodyContainer);
				layer.addChild(bottomContainer);
				layer.addChild(headerContainer);
				layer.addChild(titleContainer);
				if(settings.hasTitle){
					bodyContainer.y = headerContainer.height / 2;
				}
				
				
				if (settings.debug) {
					debug(headerContainer, 0x00FF00);
					debug(bottomContainer, 0xCCCCCC);
					debug(bodyContainer, 0xFF0000);
				}

				//drawFader();
				
				this.stage.addEventListener(Event.RESIZE, onRefreshPosition);
				
				if (settings.hasAnimations == true) {
					if (settings.delay){
						setTimeout(startOpenAnimation, settings.delay);
					}else {
						startOpenAnimation();
					}
				}else {
					this.visible = true;
					layer.x = App.self.stage.stageWidth / 2 - settings.width / 2
					layer.y = App.self.stage.stageHeight / 2 - settings.height / 2
					layer.visible = true;
					
					fader.addEventListener(MouseEvent.CLICK, onFaderClick);
						
					dispatchEvent(new WindowEvent("onAfterOpen"));
				}
				
				if (settings.debug) {
					debug(this,0x0000FF);
				}
				
				this.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			}
			
			protected function onKeyDown(e:KeyboardEvent):void {
				if (Number(e.keyCode.toString()) == 27 && settings.escExit == true) {
					close();
				}
			}
			
			public function dispose():void {
				
				//SoundsManager.instance.playSFX(settings.closeSound);
				
				//MouseCursor.switchVisibleCursor(Connection.lastCursorType);
				
				if (fader != null && fader.hasEventListener(MouseEvent.CLICK)) {
					fader.removeEventListener(MouseEvent.CLICK, onFaderClick);
					fader = null;
				}
				
				if (this.stage != null)
				{
					this.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
					this.stage.removeEventListener(Event.RESIZE, onRefreshPosition);
				}
				
				if(settings.hasExit && exit){
					exit.removeEventListener(MouseEvent.CLICK, close);
				}
				
				if (settings.hasPaginator && paginator != null) {
					paginator.dispose();
				}
				
				if (this.parent != null) {
					this.parent.removeChild(this);
				}else {
					if(App.self.windowContainer.contains(this)){
						App.self.windowContainer.removeChild(this);
					}
				}
				
				//uiBuffer.bigWinOpen = false;

				for (var i:int = 0; i < App.self.windowContainer.numChildren; i++) {
					var backWindow:* = App.self.windowContainer.getChildAt(i);

					if (backWindow is Window && !(backWindow is InstanceWindow) && !(backWindow is AchivementMsgWindow) && backWindow.opened == false) {
						//try{
							backWindow.create();
						//}catch (e:Error) {
							//trace(e.message);
						//}
						break;
					}else if(backWindow is Window)
					{
						break;
					}
				}
				
				if(settings.returnCursor && Cursor.type != "stock" && Cursor.type != "water"){
					Cursor.type = Cursor.prevType;
				}
				
				dispatchEvent(new WindowEvent("onAfterClose"));		
				if (clearQuestsTargets) {
					Quests.help = false;
				}
			}
			
			public function close(e:MouseEvent = null):void {
				
				if (settings.target && settings.target.hasOwnProperty('helpTarget'))
					settings.target.helpTarget = 0;
				
				opened = false;
				
				if (settings.hasAnimations == true) {
					startCloseAnimation();
				}else {
					dispatchEvent(new WindowEvent("onBeforeClose"));
					dispose();
				}
			}
			
			public function contentChange():void {}
			
			public var background:Bitmap;
			public function drawBackground():void {
				if (!background) {
					background = new Bitmap();
					layer.addChild(background);
				}
				background.bitmapData = backing(settings.width, settings.height, 50, settings.background).bitmapData;
			}
			
			
			public function drawTitle():void {
				
				titleLabel = titleText( {
					title				: settings.title,
					color				: settings.fontColor,
					multiline			: settings.multiline,
					fontSize			: settings.fontSize,
					textLeading	 		: settings.textLeading,
					borderColor 		: settings.fontBorderColor,
					borderSize 			: settings.fontBorderSize,
					shadowSize			: settings.shadowSize,
					shadowColor			: settings.shadowColor,
					
					shadowBorderColor	: settings.shadowBorderColor || settings.fontColor,
					width				: settings.width - 140,
					textAlign			: 'center',
					sharpness 			: 50,
					thickness			: 50,
					border				: true,
					mirrorDecor			: settings.mirrorDecor
				});
				
				titleLabel.x = (settings.width - titleLabel.width) * .5;
				titleLabel.y = -16;
				titleContainer.addChild(titleLabel);
				titleContainer.mouseEnabled = false;
				titleContainer.mouseChildren = false;
			}
			
			public function drawExit():void {
				exit = new ImageButton(textures.closeBttn);
				headerContainer.addChild(exit);
				
				if (settings.smallExit) {
					exit.scaleX = exit.scaleY = 0.85;
					exit.x = settings.width - 60;
					exit.y =  10;
				}else {
					exit.x = settings.width - exit.width;
					exit.y = 0;
				}
				
				
				exit.addEventListener(MouseEvent.CLICK, close);
			}
			
			public function drawHeader():void {
				if(settings.hasTitle){
					drawTitle();		
				}
				if (settings.hasExit == true) {
					drawExit();
				}
			}
			
			public function drawBody():void {
				
				
			}
			
			public static function slider(result:Sprite, value:Number, max:Number, bmd:String = "energySlider", useBacking:Boolean = false, backingWidth:int = 0, bgWidth:int = 0):void {
				while (result.numChildren) {
					result.removeChildAt(0);
				}
				var slider:Bitmap;
				if (!useBacking) {
					slider = new Bitmap(textures[bmd]);
					if (bgWidth > 0)
						slider.width = bgWidth;
				}else {
					slider = Window.backingShort(backingWidth, bmd);
				}
				
				var mask:Shape = new Shape();
				mask.graphics.beginFill(0x000000, 1);
				mask.graphics.drawRect(0, 0, slider.width, slider.height);
				mask.graphics.endFill();
				
				result.addChild(mask);			
				result.addChild(slider);
				
				slider.mask = mask;
				
				var percent:Number = value > max ? 1: value / max;
				var currentWidth:Number = slider.width * percent;
				
				
				mask.x = currentWidth - slider.width;
				mask.x = slider.x <= 0?mask.x:0;
			}
			
			public function drawMirrowObjs(_texture:String, xPos:int, xPos2:int, yPos:int, selfPaddingLeft:Boolean = false, selfPaddingRight:Boolean = false, selfPaddingTop:Boolean = false, _alpha:Number = 1, scaleY:Number = 1, container:Sprite = null):void
			{
					var btmLeft:Bitmap;
					var btmRight:Bitmap;
				if (Window.textures.hasOwnProperty(_texture)) {
					btmLeft = new Bitmap(Window.textures[_texture]);
					btmRight =  new Bitmap(Window.textures[_texture]);
				}else if(UserInterface.textures.hasOwnProperty(_texture)) {
					btmLeft =  new Bitmap(UserInterface.textures[_texture]);
					btmRight =  new Bitmap(UserInterface.textures[_texture]);
				}else {
					btmLeft =  new Bitmap(Window.textures['titleDecRose']);
					btmRight =  new Bitmap(Window.textures['titleDecRose']);
				}
				
		//		var btmLeft:Bitmap = new Bitmap(textures[texture]);
				btmLeft.scaleY = scaleY;
				if (selfPaddingLeft) {
					btmLeft.x = xPos - btmLeft.width; 
				}else {
					btmLeft.x = xPos; 
				}
				if (selfPaddingTop) {
					btmLeft.y = yPos - btmLeft.height/2;
				}else {
					btmLeft.y = yPos;
				}
				
			//	var btmRight:Bitmap = new Bitmap(textures[texture]);
				btmRight.scaleX = -1;
				btmRight.scaleY = scaleY;
				
				if (selfPaddingRight) {
					btmRight.x = xPos2 + btmRight.width;
				}else{
					btmRight.x = xPos2;
				}
				if (selfPaddingTop) {
					btmRight.y = yPos - btmRight.height/2;
				}else {
					btmRight.y = yPos;
				}
				btmLeft.alpha = _alpha;
				btmRight.alpha = _alpha;
				if (container != null) {
					container.addChild(btmLeft);
					container.addChild(btmRight);
				}else {
					bodyContainer.addChild(btmLeft);
					bodyContainer.addChild(btmRight);
				}
				
			}
			
			public function drawBottom():void {
				
				if(settings.hasPaginator == true){
					createPaginator();
				}
			}
			
			public function createPaginator():void {
				
				settings.paginatorSettings["hasArrow"] = settings.paginatorSettings.hasArrow || settings.hasArrow;
				settings.paginatorSettings["hasButtons"] = settings.paginatorSettings.hasButtons || settings.hasButtons;
				
				paginator = new Paginator(settings.content.length || 10, settings.itemsOnPage, settings.buttonsCount, settings.paginatorSettings);
				paginator.x = int((settings.width - paginator.width) / 2);
				paginator.y = int(settings.height - paginator.height - 46);
				
				paginator.addEventListener(WindowEvent.ON_PAGE_CHANGE, onPageChange);
				
				bottomContainer.addChild(paginator);
			}
			
			public function drawArrows():void {
				
				paginator.drawArrow(bodyContainer, Paginator.LEFT,  0, 0, { scaleX: -1, scaleY:1 } );
				paginator.drawArrow(bodyContainer, Paginator.RIGHT, 0, 0, { scaleX:1, scaleY:1 } );
				
				var y:Number = (settings.height - paginator.arrowLeft.height) / 2;
				paginator.arrowLeft.x = -paginator.arrowLeft.width / 2 + 26;
				paginator.arrowLeft.y = y;
				
				paginator.arrowRight.x = settings.width-paginator.arrowRight.width/2 - 26;
				paginator.arrowRight.y = y;
				
			}
			
			public function onPageChange(e:WindowEvent):void {
				
				contentChange();
			}
			
			public function startOpenAnimation():void {
				
				var finishX:int = (App.self.stage.stageWidth - settings.width) / 2;
				var finishY:int = (App.self.stage.stageHeight - settings.height) / 2;
				
				layer.x = /*finishX;// */(App.self.stage.stageWidth - settings.width * .3) / 2;
				layer.y = /*finishY;// */(App.self.stage.stageHeight - settings.height * .3) / 2;
				
				layer.visible = true;
							
				layer.scaleX = layer.scaleY = 0.3;
				layer.cacheAsBitmap = true;
				TweenLite.to(layer, settings.animationShowSpeed, { x:finishX, y:finishY, scaleX:1, scaleY:1, ease:Strong.easeOut, onComplete:finishOpenAnimation } );
				//finishOpenAnimation()
			}
			
			public function finishOpenAnimation():void {
				if(fader)fader.addEventListener(MouseEvent.CLICK, onFaderClick);
				dispatchEvent(new WindowEvent("onAfterOpen"));
			}
			
			public function startCloseAnimation():void {
				if(fader != null){
					fader.visible = false;
				}
				TweenLite.to(layer, settings.animationHideSpeed, { alpha:0, onComplete:finishCloseAnimation } );
			}
			
			public function finishCloseAnimation():void {
				dispose();
			}		
			
			public function debug(container:*, color:uint = 0x000000):void {
				container.graphics.lineStyle(2, color, 1, true);
				container.graphics.drawRoundRect(2, 2, container.width, container.height, 10);
				container.graphics.endFill();
			}
			
			protected function onRefreshPosition(e:Event = null):void
			{ 		
				var stageWidth:int = App.self.stage.stageWidth;
				var stageHeight:int = App.self.stage.stageHeight;
				
				layer.x = (stageWidth - settings.width) / 2;
				layer.y = (stageHeight - settings.height) / 2;
				
				if(settings.hasTitle){
					layer.y += headerContainer.height / 4;
				}
				
				if(fader){
					fader.width = stageWidth;
					fader.height = stageHeight;
				}
			}
			
			public static function drawText(text:String, defaults:Object = null):TextField {
				
				var settings:Object = {
					color				: 0xdfdbcf,
					multiline			: false,				//Многострочный текст
					fontSize			: 19,					//Размер шрифта
					textLeading	 		: -3,					//Вертикальное расстояние между словами	
					borderColor 		: 0x5d5d5d,				//Цвет обводки шрифта	
					borderSize 			: 4,					//Размер обводки шрифта
					fontBorderGlow 		: 2,					//Размер размытия шрифта
					//fontFamily			: 'BrushType-SemiBold',		//Шрифт					
					fontFamily			: 'font',		//Шрифт					
					autoSize			: 'none',
					textAlign			: 'left',
					filters				: defaults.filters || [],
					sharpness 			: 100,
					thickness			: 50,
					border				: true,
					letterSpacing		: 0,
					input				: false,
					width				: 0,
					wrap				: false,
					background			: false,
					backgroundColor		: 0xffffff,
					shadowSize			: 0
				}
				
				if (defaults != null) {
					for (var property:* in defaults) {
						settings[property] = defaults[property];
					}
				}
				
				var textLabel:TextField = new TextField();
				var filters:Array = [];
				
				if(settings.input){
					textLabel.type = TextFieldType.INPUT;
					//textLabel.selectable = false;
					//textLabel.tabEnabled = true;
				}else{
					textLabel.mouseEnabled = false;
					textLabel.mouseWheelEnabled = false;
				}
				textLabel.antiAliasType = AntiAliasType.ADVANCED;
				textLabel.multiline = settings.multiline;
				
				switch(settings.autoSize){
					case "left": textLabel.autoSize = TextFieldAutoSize.LEFT; break;
					case "center": textLabel.autoSize = TextFieldAutoSize.CENTER; break;
					case "right": textLabel.autoSize = TextFieldAutoSize.RIGHT; break;
				}
				
				textLabel.embedFonts = true;
				textLabel.sharpness = settings.sharpness;
				textLabel.thickness = settings.thickness;
				//textLabel.border = true;
				
				textLabel.background = settings.background;
				textLabel.backgroundColor = settings.backgroundColor;
				
				var style:TextFormat = new TextFormat();
				style.color = settings.color; 
				style.letterSpacing = settings.letterSpacing;
				if(settings.multiline){
					style.leading = settings.textLeading; 
				}
				
				if (text && /*App.isSocial('VK','NK','HV') && */text.search( /[€]/ ) != -1) {
					settings.fontFamily = App.reserveFont.fontName;
					settings.fontSize *= 0.75;
				}
				
				style.size = settings.fontSize*fontScale*App._fontScale;
				style.font = settings.fontFamily;
				style.bold = settings.bold || false;
				switch(settings.textAlign) {
					case 'left': style.align = TextFormatAlign.LEFT; break;
					case 'center': style.align = TextFormatAlign.CENTER; break;
					case 'right': style.align = TextFormatAlign.RIGHT; break;
					case 'justify': style.align = TextFormatAlign.JUSTIFY; break;
				}
				
				textLabel.defaultTextFormat = style;
				if (text == null) text = "";
				textLabel.text = text;
				
				
				if (textLabel.text.indexOf(' ') == -1) {
					textLabel.wordWrap = false;
				}else {
					textLabel.wordWrap = settings.wrap;
				}
				
				var metrics:*;
				if (settings.width > 0) { 
					textLabel.width = settings.width;
					metrics = textLabel.getLineMetrics(0);
					if(text.length > 3 && textLabel.textWidth+metrics.descent > settings.width) {
						while (textLabel.textWidth + metrics.descent > settings.width) {
							settings.fontSize -= 1;
							style.size = settings.fontSize;
							textLabel.setTextFormat(style);
							metrics = textLabel.getLineMetrics(0);
							//textLabel.defaultTextFormat = style;
						}
					}
				}
				textLabel.defaultTextFormat = style;
				
				if (settings.shadowSize > 0) {
					var dsfilter:DropShadowFilter = new DropShadowFilter(settings.shadowSize, 90, (settings.hasOwnProperty('shadowColor')) ? settings.shadowColor : settings.borderColor, 1, 0, 0);
					settings.filters.unshift(dsfilter);
				}
				if(settings.borderSize>0 && settings.border){
					var filter:GlowFilter = new GlowFilter(settings.borderColor,1,settings.borderSize,settings.borderSize,10,1);
					settings.filters.unshift(filter);
				}
				textLabel.filters = settings.filters;
				
				textLabel.cacheAsBitmap = true;
				
				if (settings.autoSize == 'none') {
					metrics = textLabel.getLineMetrics(0);
					textLabel.height = (textLabel.textHeight || metrics.height) + 4;
				}
				return textLabel;
			}
			
			public static function backing(width:int, height:int, padding:int = 50, _texture:String = "collectionRewardBacking"):Bitmap 
			{
				var sprite:Sprite = new Sprite();
				var cWidth:int = 0;
				var cHeight:int = 0;
				
				
				var texture:String = _texture;
				var bitmap:BitmapData;
				if (Window.textures.hasOwnProperty(_texture)) {
					bitmap = Window.textures[_texture];
				}else if(UserInterface.textures.hasOwnProperty(_texture)) {
					bitmap = UserInterface.textures[_texture];
				}else {
					bitmap = Window.textures['collectionRewardBacking'];
				}
				
				if (bitmap.width * 2 > width) {
					cWidth = Math.floor(width / 2) - 1;
				}else {
					cWidth = bitmap.width;
				}
				if (bitmap.height * 2 > height) {
					cHeight = Math.floor(height / 2) - 1;
				}else {
					cHeight = bitmap.height;
				}
				
				var backingBMD:BitmapData = new BitmapData(cWidth, cHeight, true, 0x00000000);
				backingBMD.copyPixels(bitmap, new Rectangle(0, 0, cWidth, cHeight), new Point());
				
				var topLeft:Bitmap = new Bitmap(backingBMD, "auto", true);
				
				var topRight:Bitmap = new Bitmap(backingBMD, "auto", true);
				topRight.scaleX = -1;
				
				var bottomLeft:Bitmap = new Bitmap(backingBMD, "auto", true);
				bottomLeft.scaleY = -1;
				
				var bottomRight:Bitmap = new Bitmap(backingBMD, "auto", true);
				bottomRight.scaleX = bottomRight.scaleY = -1;
				
				if (topLeft.height * 2 > height) {
					cHeight = Math.floor(height / 2);
				}else {
					cHeight = topLeft.height;
				}
				
				var horizontal:BitmapData = new BitmapData(1, cHeight, true, 0);
				horizontal.copyPixels(topLeft.bitmapData,new Rectangle(cWidth-1, 0, cWidth, cHeight), new Point());
				
				var vertical:BitmapData = new BitmapData(topLeft.width, 1, true, 0);
				vertical.copyPixels(topLeft.bitmapData,new Rectangle(0, cHeight-1, cWidth, cHeight), new Point());
				
				var fillColor:uint = topLeft.bitmapData.getPixel(cWidth - 1, cHeight - 1);
				
				topRight.x = width;
				topRight.y = 0;
				
				bottomLeft.x = 0;
				bottomLeft.y = height;
				
				bottomRight.y = height;
				bottomRight.x = width;
				
				var shp:Shape;
				shp = new Shape();
				shp.graphics.beginBitmapFill(horizontal);
				shp.graphics.drawRect(0, 0, width - topLeft.width * 2, cHeight);
				shp.graphics.endFill();
				
				var hBmd:BitmapData = new BitmapData(Math.abs(width - topLeft.width * 2)+1, cHeight, true, 0);
				hBmd.draw(shp);
				
				var hTopBmp:Bitmap = new Bitmap(hBmd, "auto", true);
				var hBottomBmp:Bitmap = new Bitmap(hBmd, "auto", true);
				hBottomBmp.scaleY = -1;
				
				hTopBmp.x = topLeft.width;
				hTopBmp.y = 0;
				hBottomBmp.x = topLeft.width;
				hBottomBmp.y = height;
				
				shp = new Shape();
				shp.graphics.beginBitmapFill(vertical);
				shp.graphics.drawRect(0, 0, topLeft.width, height - cHeight * 2);
				shp.graphics.endFill();

				var vBmd:BitmapData = new BitmapData(topLeft.width, (height - cHeight * 2 == 0) ? 1 : (height - cHeight * 2), true, 0);
				vBmd.draw(shp);
				
				var vLeftBmp:Bitmap = new Bitmap(vBmd, "auto", true);
				var vRightBmp:Bitmap = new Bitmap(vBmd, "auto", true);
				vRightBmp.scaleX = -1;
				
				vLeftBmp.x = 0;
				vLeftBmp.y = cHeight;
				
				vRightBmp.x = width;
				vRightBmp.y = cHeight;
				
				var solid:Sprite = new Sprite();
				solid.graphics.beginFill(fillColor);
				solid.graphics.drawRect(topLeft.width, topLeft.height, width - topLeft.width*2, height-topLeft.height*2);
				solid.graphics.endFill();
				
				sprite.addChildAt(solid,0);
				
				sprite.addChild(topLeft);
				sprite.addChild(topRight);
				sprite.addChild(bottomLeft);
				sprite.addChild(bottomRight);
				sprite.addChild(hTopBmp);
				sprite.addChild(hBottomBmp);
				sprite.addChild(vLeftBmp);
				sprite.addChild(vRightBmp);
				
				solid = null;
				
				var bg:BitmapData = new BitmapData(sprite.width, sprite.height,true,0x00000000);
				bg.draw(sprite);
							
				for (var i:int = 0; i < sprite.numChildren; i++) {
					sprite.removeChildAt(i);
				}
				sprite = null;
				
				return new Bitmap(bg, "auto", true);
			}
			
			public static function backingShort(width:int, _texture:String = "alertBacking", mirrow:Boolean = true):Bitmap {
				var sprite:Sprite = new Sprite();
				
					var left:Bitmap;
					var right:Bitmap;
				if (Window.textures.hasOwnProperty(_texture)) {
					left = new Bitmap(Window.textures[_texture]);
					right =  new Bitmap(Window.textures[_texture]);
				}else if(UserInterface.textures.hasOwnProperty(_texture)) {
					left =  new Bitmap(UserInterface.textures[_texture]);
					right =  new Bitmap(UserInterface.textures[_texture]);
				}else {
					left =  new Bitmap(Window.textures['titleDecRose']);
					right =  new Bitmap(Window.textures['titleDecRose']);
				}
				
					right.scaleX = -1;
				
				var horizontal:BitmapData = new BitmapData(1, left.height, true, 0);
				horizontal.copyPixels(left.bitmapData,new Rectangle(left.width-1, 0, left.width, left.height), new Point());
				
				var fillColor:uint = left.bitmapData.getPixel(left.width - 1, left.height - 1);
				
				right.x = width;
				right.y = 0;
				
				var shp:Shape;
				shp = new Shape();
				shp.graphics.beginBitmapFill(horizontal);
				shp.graphics.drawRect(0, 0, width - left.width * 2, left.height);
				shp.graphics.endFill();
				
				if (width > 0) {
					var hBmd:BitmapData = new BitmapData(Math.abs(width - left.width * 2), left.height, true, 0);
					hBmd.draw(shp);
					var hTopBmp:Bitmap = new Bitmap(hBmd, "auto", true);
					hTopBmp.x = left.width;
					hTopBmp.y = 0;
					sprite.addChild(hTopBmp);
				}else {
					right.x = left.width*2;
				}
					
				
				
				sprite.addChild(left);
				if (mirrow)sprite.addChild(right);
				
				
				var bg:BitmapData = new BitmapData(sprite.width, sprite.height,true,0x00000000);
				bg.draw(sprite);
							
				for (var i:int = 0; i < sprite.numChildren; i++) {
					sprite.removeChildAt(i);
				}
				sprite = null;
				
				return new Bitmap(bg, "auto", true);
			}
			
			public static function backingShort2(width:int, height:int, texture:String = "windowBacking", isBottonPiece:Boolean = false):Bitmap {
				
				var textureBitmapData:BitmapData;
				if (textures.hasOwnProperty(texture)) {
					textureBitmapData = textures[texture];
				}else if(UserInterface.textures.hasOwnProperty(texture)) {
					textureBitmapData = UserInterface.textures[texture];
				}else {
					textureBitmapData = textures[defaultBacking];
				}
				
				/*var backing:BitmapData = new BitmapData(width, height, true, 0);
				backing.draw(textureBitmapData);
				backing.draw(textureBitmapData, new Matrix( -1, 0, 0, 1, width, 0));
				backing.draw(textureBitmapData, new Matrix( 1, 0, 0, -1, 0, height));
				backing.draw(textureBitmapData, new Matrix( -1, 0, 0, -1, width, height));
				
				var verticalLine:BitmapData = new BitmapData(1, textureBitmapData.height, true, 0);
				var horizontalLine:BitmapData = new BitmapData(textureBitmapData.width, 1, true, 0);
				verticalLine.copyPixels(textureBitmapData, new Rectangle(textureBitmapData.width - 1, 0, 1, textureBitmapData.height), new Point());
				horizontalLine.copyPixels(textureBitmapData, new Rectangle(0, textureBitmapData.height - 1, textureBitmapData.width, 1), new Point());
				
				backing.draw(verticalLine, new Matrix( width - textureBitmapData.width * 2, 0, 0, 1, textureBitmapData.width, 0));
				backing.draw(verticalLine, new Matrix( width - textureBitmapData.width * 2, 0, 0, -1, textureBitmapData.width, height));
				backing.draw(horizontalLine, new Matrix( 1, 0, 0, height - textureBitmapData.height * 2, 0, textureBitmapData.height));
				backing.draw(horizontalLine, new Matrix( -1, 0, 0, height - textureBitmapData.height * 2, width, textureBitmapData.height));
				
				backing.floodFill(textureBitmapData.width + 1, textureBitmapData.height + 1, textureBitmapData.getPixel32(textureBitmapData.width - 1, textureBitmapData.height - 1));
				
				return new Bitmap(backing);*/
				
				var sprite:Sprite = new Sprite();
				var left:Bitmap = new Bitmap(textureBitmapData, "auto", true);
				var right:Bitmap = new Bitmap(textureBitmapData, "auto", true);
				
				right.scaleX = -1;
				
				
				var piece:BitmapData = new BitmapData(1, left.height, true, 0);
				piece.copyPixels(left.bitmapData,new Rectangle(1, 0, left.width, left.height), new Point());
				
				var shp:Shape;
				shp = new Shape();
				shp.graphics.beginBitmapFill(piece);
				shp.graphics.drawRect(0, 0,(width - left.width * 2)/2, left.height);
				shp.graphics.endFill();
				
				var pieceBmd:BitmapData = new BitmapData((width - left.width * 2)/2, left.height, true, 0);
				pieceBmd.draw(shp);
				
				var leftBmp:Bitmap = new Bitmap(pieceBmd, "auto", true);
				var rightBmp:Bitmap = new Bitmap(pieceBmd, "auto", true);
				
				if (isBottonPiece) {
					var bottomPiece:BitmapData = new BitmapData(1, 1, true, 0);
					bottomPiece.copyPixels(left.bitmapData, new Rectangle(1, left.height-1, width, height -left.height), new Point());
					
					var shp2:Shape;
					shp2 = new Shape();
					shp2.graphics.beginBitmapFill(bottomPiece);
					shp2.graphics.drawRect(0, 0,width, height -left.height);
					shp2.graphics.endFill();
					
					var bottomPieceBmd:BitmapData = new BitmapData(width, height - left.height, true, 0);
					bottomPieceBmd.draw(shp2);
					
					var bottomBmp:Bitmap = new Bitmap(bottomPieceBmd, "auto", true);
					sprite.addChild(bottomBmp);
					bottomBmp.y = leftBmp.y + leftBmp.height;
				}
				
				
				leftBmp.x = 0;
				leftBmp.y = 0;
				
				left.x = leftBmp.width;
				left.y = 0;
				
				right.x = left.x + left.width*2;
				right.y = 0;
				
				rightBmp.x = right.x;
				rightBmp.y = 0;
				
				sprite.addChild(left);
				sprite.addChild(right);
				sprite.addChild(leftBmp);
				sprite.addChild(rightBmp);
				
				var bg:BitmapData = new BitmapData(sprite.width, sprite.height,true,0x00000000);
				bg.draw(sprite);
							
				for (var i:int = 0; i < sprite.numChildren; i++) {
					sprite.removeChildAt(i);
				}
				sprite = null;
				
				return new Bitmap(bg, "auto", true);
			}
			
			private static var defaultBacking:String = 'collectionRewardBacking';
			public static function backing2(width:int, height:int, padding:int = 50, texture:String = "collectionRewardBacking", texture2:String = "collectionRewardBacking", koefBetweenTextures:int = 0):Bitmap {
				var sprite:Sprite = new Sprite();
				
				var isHeightSmoller:Boolean = false;
				if (!textures.hasOwnProperty(texture)){
					texture = defaultBacking;
				}
				if (!textures.hasOwnProperty(texture2)){
					texture2 = defaultBacking;
				}
				var topLeft:Bitmap = new Bitmap(textures[texture], "auto", true);
				var topRight:Bitmap = new Bitmap(textures[texture], "auto", true);
				var bottomLeft:Bitmap = new Bitmap(textures[texture2], "auto", true);
				var bottomRight:Bitmap = new Bitmap(textures[texture2], "auto", true);
				
				var sameHeigth:Boolean = false;
				var sameWidth:Boolean = false;
				
				if (height <= topLeft.height + bottomLeft.height) {
					sameHeigth = true;
				}
				else if (width <= topLeft.width + bottomLeft.width) {
					sameWidth = true;
				}
				
				if(!sameWidth){
					var horizontal:BitmapData = new BitmapData(1, bottomLeft.height, true, 0);
					horizontal.copyPixels(topLeft.bitmapData, new Rectangle(topLeft.width - 1, 0, topLeft.width, topLeft.height), new Point());
					
					var horizontal2:BitmapData = new BitmapData(1, bottomLeft.height, true, 0);
					horizontal2.copyPixels(bottomLeft.bitmapData,new Rectangle(bottomLeft.width-1, 0, bottomLeft.width, bottomLeft.height), new Point());
				
					var shp:Shape;
					shp = new Shape();
					shp.graphics.beginBitmapFill(horizontal);
					shp.graphics.drawRect(0, 0, width - topLeft.width * 2, topLeft.height);
					shp.graphics.endFill();
					
					var shp2:Shape;
					shp2 = new Shape();
					shp2.graphics.beginBitmapFill(horizontal2);
					shp2.graphics.drawRect(0, 0, width - bottomLeft.width * 2 + koefBetweenTextures*4, bottomLeft.height);
					shp2.graphics.endFill();
					
					if (width - topLeft.width * 2 <= 0)
						width = topLeft.width * 2 + 1;
							
					var hBmd:BitmapData = new BitmapData(width - topLeft.width * 2, topLeft.height, true, 0);
					hBmd.draw(shp);
					
					if (width - bottomLeft.width * 2 <= 0)
						width = bottomLeft.width * 2 + 1;
					
					var hBmd2:BitmapData = new BitmapData(width - bottomLeft.width * 2  + koefBetweenTextures*4, bottomLeft.height, true, 0);
					hBmd2.draw(shp2);
					
					var hTopBmp:Bitmap = new Bitmap(hBmd, "auto", true);
					var hBottomBmp:Bitmap = new Bitmap(hBmd2, "auto", true);
				}
					
				if (height < topLeft.height + bottomLeft.height) {
					isHeightSmoller = true;
					var heightDiff:Number = (topLeft.height + bottomLeft.height) - height + 6;
					
					topLeft.height = topLeft.height - heightDiff / 2;
					topRight.height = topRight.height - heightDiff / 2;
					bottomLeft.height = bottomLeft.height - heightDiff / 2;
					bottomRight.height = bottomRight.height - heightDiff / 2;
					
					hTopBmp.height = hTopBmp.height - heightDiff / 2;
					hBottomBmp.height = hBottomBmp.height - heightDiff / 2;
				}
				
				if(!sameWidth){
					hTopBmp.x = topLeft.width;
					hTopBmp.y = 0;
					hBottomBmp.x = bottomLeft.width - koefBetweenTextures*2;
					hBottomBmp.y = height - hBottomBmp.height;
				}
				
				topRight.scaleX = -1;
				bottomRight.scaleX = -1;
				
				if(!sameHeigth){
					var vertical:BitmapData = new BitmapData(topLeft.width, 1, true, 0);
					vertical.copyPixels(topLeft.bitmapData,new Rectangle(0, topLeft.height-1, topLeft.width, topLeft.height), new Point());
				
					var fillColor:uint = topLeft.bitmapData.getPixel(topLeft.width - 1, topLeft.height - 1);
				}
				
				topLeft.x = 0;
				topLeft.y = 0;
				
				topRight.x = width;
				topRight.y = 0;
				
				bottomLeft.x = - koefBetweenTextures;
				if (isHeightSmoller) {
					bottomLeft.y = topLeft.height;
					if(!sameWidth)hBottomBmp.y = bottomLeft.y + bottomLeft.height - hBottomBmp.height;
				}else {bottomLeft.y = height - bottomLeft.height;}
				
				if (isHeightSmoller) 
					bottomRight.y = topRight.height;
				else 
					bottomRight.y = height - bottomRight.height;
				
				bottomRight.x = width + koefBetweenTextures;
				
				if(!sameHeigth){
					shp = new Shape();
					shp.graphics.beginBitmapFill(vertical);
					shp.graphics.drawRect(0, 0, topLeft.width, height - topLeft.height * 2);
					shp.graphics.endFill();

					var vBmd:BitmapData = new BitmapData(topLeft.width, height - topLeft.height * 2, true, 0);
					vBmd.draw(shp);
					
					var vLeftBmp:Bitmap = new Bitmap(vBmd, "auto", true);
					var vRightBmp:Bitmap = new Bitmap(vBmd, "auto", true);
					vRightBmp.scaleX = -1;
					
					vLeftBmp.x = 0;
					vLeftBmp.y = topLeft.height;
					
					vRightBmp.x = width;
					vRightBmp.y = topLeft.height;
				}
				
				if(!sameHeigth && !sameWidth){
					var solid:Sprite = new Sprite();
					solid.graphics.beginFill(fillColor);
					solid.graphics.drawRect(padding, padding, width-padding*2, height-padding*2);
					solid.graphics.endFill();
				}
				
				sprite.addChild(topLeft);
				sprite.addChild(topRight);
				sprite.addChild(bottomLeft);
				sprite.addChild(bottomRight);
				
				if (!sameHeigth && !sameWidth) sprite.addChildAt(solid, 0);
				if(!sameWidth){
					sprite.addChild(hTopBmp);
					sprite.addChild(hBottomBmp);
				}
				if(!sameHeigth){
					sprite.addChild(vLeftBmp);
					sprite.addChild(vRightBmp);
				}
				
				solid = null;
				
				var bg:BitmapData = new BitmapData(sprite.width, sprite.height,true,0x00000000);
				bg.draw(sprite);
							
				for (var i:int = 0; i < sprite.numChildren; i++) {
					sprite.removeChildAt(i);
				}
				sprite = null;
				
				return new Bitmap(bg, "auto", true);
			}

			public static function separator(width:int, xPos:int = 0, yPos:int = 0, alphaVal:Number = 1, texture:String = "separatorPiece", texture2:String = "separatorPiece2"):Bitmap
			{
				var sprite:Sprite = new Sprite();
				
				var left:Bitmap = new Bitmap(textures[texture], "auto", true);
				
				var right:Bitmap = new Bitmap(textures[texture], "auto", true);
				right.scaleX = -1;
				right.x = width;
				
				var piece2Width:Number = width - left.width - right.width;
				
				var centerPiece:Shape = new Shape();
				centerPiece.graphics.beginBitmapFill(Window.textures.separatorPiece2);
				centerPiece.graphics.drawRect(0, 0, piece2Width, Window.textures.separatorPiece2.height);
				centerPiece.graphics.endFill();
				centerPiece.x = left.width;
				
				sprite.addChild(left);
				sprite.addChild(right);
				sprite.addChild(centerPiece);
				
				var bg:BitmapData = new BitmapData(sprite.width, sprite.height,true,0x00000000);
				bg.draw(sprite);
				
							
				for (var i:int = 0; i < sprite.numChildren; i++) {
					sprite.removeChildAt(i);
				}
				sprite = null;
				
				var sep:Bitmap = new Bitmap(bg, "auto", true);
				sep.alpha = alphaVal;
				sep.x = xPos; sep.y = yPos;
				
				return sep;
			}
			
			
			public static function shadowBacking(width:int, height:int, radius:int=7):Sprite {
				
				var sprite:Sprite = new Sprite();
				
				var shadow:Shape = new Shape();
				shadow.graphics.beginFill(0x5A31B0, .2);
				shadow.graphics.drawRoundRect(2, 4, width, height, radius, radius);
				shadow.graphics.endFill();
				
				var middle:Shape = new Shape();
				middle.graphics.beginFill(0x442585, 1);
				middle.graphics.drawRoundRect(0, 0, width, height, radius, radius);
				middle.graphics.endFill();
				
				var face:Shape = new Shape();
				face.graphics.beginFill(0x4A40CE, 1); 
				face.graphics.drawRoundRect(2, 2, width-4, height-4, radius, radius);
				face.graphics.endFill();
				
				sprite.addChild(shadow);
				sprite.addChild(middle);
				sprite.addChild(face);
				
				return sprite;
			}
			
			public static function getBacking(width:int = 100, height:int = 100, x:int = 0, y:int = 0, radius:int = 33, settings:Object = null):Sprite {
				
				var defaultsColors:Object = {
					bgColor				:0x98988e,
					bevelColorHight		:0x939689,
					bevelColorDown		:0xc4caab,
					glowColor			:0x2c312a,
					borderWidth			:2,
					bevel				:true
				}
				
				if (settings == null) {
					settings = defaultsColors;
				}else {
					for (var property:* in settings) {
						defaultsColors[property] = settings[property];
					}
					settings = defaultsColors;
				}
				
				var backing:Sprite = new Sprite();
				
				var backing1:Sprite= new Sprite();
				
				if(settings.bevel == true){
					backing1.graphics.beginFill(settings.bgColor);
					backing1.graphics.drawRoundRect(0, 0, width, height, radius,radius);
					backing1.graphics.endFill();
					var filter1:BevelFilter = new BevelFilter(1, 90, settings.bevelColorHight, 1, settings.bevelColorDown, 1, 1.6, 1.6, 15, 15, "outter", false);
					backing1.filters = [filter1];
				}
				
				var backing2:Sprite= new Sprite();
				
				backing2.graphics.beginFill(settings.bgColor);
				backing2.graphics.drawRoundRect(0, 0, width, height, radius, radius);
				backing2.graphics.endFill();
				
				var filter2:GlowFilter = new GlowFilter(settings.glowColor, 1, settings.borderWidth, settings.borderWidth, 10, BitmapFilterQuality.HIGH, false);
				
				backing2.filters = [filter2];
							
				backing.addChild(backing1);
				backing.addChild(backing2);
				
				backing.x = x;
				backing.y = y;
				
				backing.cacheAsBitmap = true;
				
				return backing;
			}
			
			public function titleText(settings:Object):Sprite
			{
				var titleCont:Sprite = new Sprite();
				var mirrorDec:String = 'titleDecRose';
				var indent:int = 0;
				if (App.user.worldID == Travel.SAN_MANSANO) {
					mirrorDec = 'goldTitleDec';
					indent = -3;
				}
				
				if (settings.mirrorDecor) {
					mirrorDec = settings.mirrorDecor;
				}
				
				var textLabel:TextField = Window.drawText(settings.title, settings);
				if (this.settings.hasTitle == true && this.settings.titleDecorate == true) {
					if (mirrorDec == 'goldTitleDec') {
						drawMirrowObjs(mirrorDec, textLabel.x + (textLabel.width - textLabel.textWidth) / 2 - 45, textLabel.x + (textLabel.width - textLabel.textWidth) / 2 + textLabel.textWidth + 50, textLabel.y + (textLabel.height - 40) / 2 + indent, false, false, false, 1, 1, titleCont);
					}else {
						drawMirrowObjs(mirrorDec, textLabel.x + (textLabel.width - textLabel.textWidth) / 2 - 75, textLabel.x + (textLabel.width - textLabel.textWidth) / 2 + textLabel.textWidth + 75, textLabel.y + (textLabel.height - 40) / 2 + indent, false, false, false, 1, 1, titleCont);
					}
				}
				
				titleCont.mouseChildren = false;
				titleCont.mouseEnabled = false;
				titleCont.addChild(textLabel);
				
				return titleCont;
			}
			
			public var titleLabelImage:Bitmap;
			public function drawLabel(bmd:BitmapData, scale:Number = 1):void
			{
				titleLabelImage = new Bitmap(bmd);
				layer.addChild(titleLabelImage);
				if (titleLabelImage.height > 260 && scale == 1) 
					scale = 260 / titleLabelImage.height;
				
				titleLabelImage.scaleX = titleLabelImage.scaleY = scale;
				titleLabelImage.smoothing = true;
				
				titleLabelImage.x = (settings.width - titleLabelImage.width)/2;
				titleLabelImage.y = -titleLabelImage.height / 2;
			}
			
			public static function getTextColor(sid:int):Object
			{
				var data:Object = [];
				data['color'] = 0xffffff;
				data['borderColor'] = 0x000000;
				
				switch(sid) {
					case Stock.FANTASY:
					case Stock.GUESTFANTASY:
						data['color'] = 0xffdb65;
						data['borderColor'] = 0x775002;
					break;
					case Stock.COINS:
						data['color'] = 0xffdb65;
						data['borderColor'] = 0x775002;
					break;
					case Stock.FANT:
						data['color'] = 0xffdb65;
						data['borderColor'] = 0x775002;
					break;
					case Techno.TECHNO:
						data['color'] = 0xfff1cf;
						data['borderColor'] = 0x482e16;
					break;
				}
				return data;
			}
			
			
			public static function addMirrowObjs(layer:Sprite, texture:String, xPos:int, xPos2:int, yPos:int, selfPaddingLeft:Boolean = false, selfPaddingRight:Boolean = false, selfPaddingTop:Boolean = false, _alpha:Number = 1, scaleY:Number = 1 ):void
			{
				var btmLeft:Bitmap = new Bitmap(textures[texture]);
				btmLeft.scaleY = scaleY;
				btmLeft.smoothing = true;
				
				if (selfPaddingLeft) {
					btmLeft.x = xPos - btmLeft.width; 
				}else {
					btmLeft.x = xPos; 
				}
				if (selfPaddingTop) {
					btmLeft.y = yPos - btmLeft.height/2;
				}else {
					btmLeft.y = yPos;
				}
				
				var btmRight:Bitmap = new Bitmap(textures[texture]);
				btmRight.smoothing = true;
				btmRight.scaleX = -1;
				btmRight.scaleY = scaleY;
				
				if (selfPaddingRight) {
					btmRight.x = xPos2 + btmRight.width;
				}else{
					btmRight.x = xPos2;
				}
				if (selfPaddingTop) {
					btmRight.y = yPos - btmRight.height/2;
				}else {
					btmRight.y = yPos;
				}
				btmLeft.alpha = _alpha;
				btmRight.alpha = _alpha;
				layer.addChild(btmLeft);
				layer.addChild(btmRight);
			}
			
			public function maker():void {
				addEventListener(MouseEvent.MOUSE_DOWN, onDown);
				addEventListener(MouseEvent.MOUSE_UP, onUp);
				addEventListener(MouseEvent.MOUSE_MOVE, onMove);
				
				var moveObject:*;
				var window:* = this;
				var beginX:int;
				var beginY:int;
				
				function onDown(e:MouseEvent):void {
					var list:Array = window.getObjectsUnderPoint(new Point(window.mouseX, window.mouseY));
					if (list.length > 0) {
						var object:* = list[list.length - 1];
						while(true) {
							if (!object.parent) {
								break;
							}else if (object.parent == bodyContainer) {
								moveObject = object;
								beginX = window.mouseX;
								beginX = window.mouseY;
								break;
							}else {
								object = object.parent;
							}
						}
					}
				}
				function onMove(e:MouseEvent):void {
					if (moveObject) {
						if (window.mouseX - beginX < 20 && window.mouseY - beginY < 20) {
							moveObject.x += window.mouseX - beginX;
							moveObject.y += window.mouseY - beginY;
						}
						beginX = window.mouseX;
						beginY = window.mouseY;
					}
				}
				function onUp(e:MouseEvent):void {
					if (moveObject) {
						trace('x: ', moveObject.x, '  y: ', moveObject.y);
						moveObject = null;
					}
				}
			}
			public static function isClass(clss:Class):* {
				var window:* = null;
				for (var i:int = 0; i < App.self.windowContainer.numChildren; i++) {
					window = App.self.windowContainer.getChildAt(i);
					if (window is clss && window.opened == true) {
						return window as clss;
					}
				}
				return null;
			}
		}
	}