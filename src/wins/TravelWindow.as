package wins
{
	import adobe.utils.CustomActions;
	import buttons.Button;
	import buttons.ImageButton;
	import buttons.MixedButton;
	import buttons.MoneyButton;
	import buttons.SimpleButton;
	import buttons.UpgradeButton;
	import com.greensock.TweenLite;
	import core.Load;
	import core.Numbers;
	import core.Post;
	import flash.display.BitmapData;
	import flash.display.GradientType;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.filters.DropShadowFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.ui.MouseCursor;
	import ui.Hints;
	import ui.UserInterface;
	import wins.elements.ProductionItem;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;

	public class TravelWindow extends Window
	{
		public var items:Vector.<TravelItem> = new Vector.<TravelItem>;
		public static var history:int = 0;
		
		public static var pages:Array;
		
		
		public var titleTextField:TextField;
		public var image:Bitmap;
		public var topBricks:Bitmap;
		public var bottomBricks:Bitmap;
		private var back:Shape;
		private var leftFader:Shape;
		private var rightFader:Shape;
		public var container:Sprite;
		public var homeBttn:Button;
		public var upgradeBttn:UpgradeButton;
		public var preloader:Preloader;
		public var mapBttn:ImageButton;
		
		private var imageContainer:Sprite = new Sprite();
		
		public function TravelWindow(settings:Object = null)
		{
			removeExcluded();
			
			if (settings == null) settings = { };
			
			settings['title'] = Locale.__e("flash:1382952380311");
			settings['width'] = App.self.stage.stageWidth;
			settings['height'] = App.self.stage.stageHeight;
			settings['hasArrows'] = true;
			settings['itemsOnPage'] = 1;
			settings['hasPaginator'] = true;
			settings['hasButtons'] = false;
			settings['hasTitle'] = false;
			
			settings['find'] = settings['find'] || 0;
			settings['findTargets'] = settings['findTargets'] || [];
			
			super(settings);
			
			pages = [];
			for (var i:* in App.user.maps) {
				pages[i] = App.user.maps[i].ilands;
			}
			
			App.self.addEventListener(AppEvent.ON_RESIZE, resize);
		}
		
		public static function show(settings:Object = null):TravelWindow {
			
			// Закрыть лишние
			while (true) {
				var window:TravelWindow = Window.isClass(TravelWindow);
				if (window) {
					window.close();
				}else {
					break;
				}
			}
			
			window = new TravelWindow(settings);
			window.show();
			
			return window;
		}
		
		override public function drawBackground():void {}
		
		public static var images:Object = {
			0: {link:Config.getImage('content', 'map_western3', 'jpg'), bgColor:0x310f27, title:Locale.__e('flash:1431946337807'), bmd:null},
			1: {link:Config.getImage('content', 'map2_jungle', 'jpg'), bgColor:0x310f27, title:Locale.__e('flash:1431946390467'), bmd:null},
			2: {link:Config.getImage('content', 'w_location0', 'jpg'), bgColor:0x310f27, title:Locale.__e('flash:1431946390467'), bmd:null}
			//1: {link:Config.getImage('content', 'map1_29_01', 'jpg'), bgColor:0x143386, title:Locale.__e('flash:1421313638082'), bmd:null}
		};
		
		public static var pagesYbExclude:Object = {
			0: {
				//790: true,
				//861: true,
				925: true
			},
			1: {
				//984: true,
				//992: true,
				//1002: true,
				//1011: true,
				//1048: true,
				//1094: true,
				//1341:true
			}
		}
		
		public static function removeExcluded():void {
			if(App.isSocial('YB','MX')){
				var itm:*;
				var itmm:*;
				for (itm in pages) {
					if (pagesYbExclude.hasOwnProperty(itm)) {
						for (itmm in pages[itm]) {
							if (pagesYbExclude[itm].hasOwnProperty(itmm)) {
								delete pages[itm][itmm];
							}
						}
						var isEmpty:Boolean = true;
						for (var a:* in pages[itm]) {
							isEmpty = false;
							break;
						}
						if (isEmpty)
							delete pages[itm];
					}
				}
			}
		}
		
		public static function getAllIncluded():Array {
			removeExcluded();
			var allMaps:Array = [];
			for (var pg:* in pages) {
				for (var mp:* in pages[pg]) {
					allMaps.push(/*pages[pg][mp]*/int(mp));
				}
			}
			return allMaps;
		}
		
		override public function drawBody():void {
			
			back = new Shape();
			bodyContainer.addChild(back);
			
			bodyContainer.addChild(imageContainer);
			
			image = new Bitmap();
			imageContainer.addChild(image);
			
			leftFader = new Shape();;
			bodyContainer.addChild(leftFader);
			rightFader = new Shape();
			bodyContainer.addChild(rightFader);
			redrawColors();
			
			/*container = new Sprite();
			bodyContainer.addChild(container);*/
			
			titleLabel = new Sprite();
			bodyContainer.addChild(titleLabel);
			titleTextField = Window.drawText(settings['title'], {
				fontSize:		46,
				color:			0xffffff,
				borderColor:	0xb48d62,
				shadowSize:     5,
				shadowColor:    0x461f34,
				autoSize:		'center'
			});
			titleTextField.x = -titleTextField.width / 2;
			titleTextField.y = 10;
			titleLabel.addChild(titleTextField);
			
			drawMirrowObjs('diamondsTop', titleTextField.x + 15, titleTextField.x + titleTextField.width - 15, 20, true, true, false, 1, 1, titleLabel);
			
			homeBttn = new Button( {
					width:		180,
					height:		52,
					caption:	Locale.__e("flash:1382952379764"),
					fontSize:	22,
					multiline:  true,
					bgColor:	[0x96c9da,0x77a1af],
					borderColor:[0xffeede,0xbcbaa6],
					fontBorderColor: 0x426e7b,
					bevelColor:	[0xbadff1,0x4f8198]
			});
			homeBttn.scaleX = homeBttn.scaleY = 0.9;
			homeBttn.addEventListener(MouseEvent.CLICK, onHome);
			bodyContainer.addChild(homeBttn);
			
			upgradeBttn = new UpgradeButton(UpgradeButton.TYPE_ON,{
				caption: Locale.__e("flash:1393580216438"),
				width:200,
				height:55,
				icon:null,//Window.textures.upgradeArrow,
				fontBorderColor:0x002932,
				countText:"",
				fontSize:28,
				iconScale:0.95,
				radius:30,
				textAlign:'left',
				autoSize:'left',
				widthButton:230
			});
			upgradeBttn.scaleX = upgradeBttn.scaleY = 0.9;
			upgradeBttn.addEventListener(MouseEvent.CLICK, onUpgrade);
			bodyContainer.addChild(upgradeBttn);
			
			mapBttn = new ImageButton(UserInterface.textures.puzzleIco);
			mapBttn.addEventListener(MouseEvent.CLICK, onMap);
			mapBttn.scaleX = mapBttn.scaleY = 1.2;
			if (!App.isSocial('YB','MX')) {
				drawGlow();
				bodyContainer.addChild(mapBttn);
			}
			
			// Если на основном острове, то
			if (App.map.id == User.HOME_WORLD) {
				homeBttn.visible = false;
				
				if (!settings.target) {
					var list:Array = Map.findUnits([789]);
					if (list.length > 0) {
						settings.target = list[0];
						if (settings.target.upgradedTime > 0)
							upgradeBttn.state = Button.DISABLED;
					}else{
						upgradeBttn.visible = false;
					}
				}else if (settings.target.maxLevelUpgrade == settings.target.level) {
					upgradeBttn.visible = false;
				}
			}else {
				upgradeBttn.visible = false;
			}
				
			// Paginator
			paginator.page = 0;
			if (settings.find && App.data.storage.hasOwnProperty(settings.find) && App.data.storage[settings.find].type == 'Lands' || 
			settings.navigateTo && App.data.storage.hasOwnProperty(settings.navigateTo) && App.data.storage[settings.navigateTo].type == 'Lands') {
				for (var page:* in pages) {
					if (pages[page].hasOwnProperty(settings.find) || pages[page].hasOwnProperty(settings.navigateTo)) {
						paginator.page = int(page);
					}
				}
			}
			
			paginator.onPageCount = 1;
			paginator.itemsCount = Numbers.countProps(pages);
			paginator.update();
			drawImage();
			resize();
			
			drawPageBttns();
			contentChange();
		}
		private function redrawColors():void {
			var matrix:Matrix = new Matrix();
			matrix.createGradientBox(50, 1);
			leftFader.graphics.clear();
			leftFader.graphics.beginGradientFill(GradientType.LINEAR, [images[paginator.page].bgColor, images[paginator.page].bgColor], [1, 0], [0, 255], matrix);
			leftFader.graphics.drawRect(0, 0, 50, 1);
			leftFader.graphics.endFill()
			
			rightFader.graphics.clear();
			rightFader.graphics.beginGradientFill(GradientType.LINEAR, [images[paginator.page].bgColor, images[paginator.page].bgColor], [0, 1], [0, 255], matrix);
			rightFader.graphics.drawRect(0, 0, 50, 1);
			rightFader.graphics.endFill();
			
			back.graphics.clear();
			back.graphics.beginFill(images[paginator.page].bgColor, 1);
			back.graphics.drawRect(0, 0, 100, 100);
			back.graphics.endFill();
		}
		
		// Glow
		private var glow:Sprite;
		public function drawGlow():void {
			glow = new Sprite();
			//glow.alpha = 0;
			bodyContainer.addChild(glow);
			
			glow.x = mapBttn.x;
			glow.y = mapBttn.y;
			
			var glowBitmap:Bitmap = new Bitmap(Window.textures.iconGlow);
			glowBitmap.scaleX = glowBitmap.scaleY = 0.8;
			glowBitmap.x = -glowBitmap.width / 2;
			glowBitmap.y = -glowBitmap.height / 2;
			glow.addChild(glowBitmap);
			
			App.self.setOnEnterFrame(glowRotate);
		}
		private function glowRotate(e:Event = null):void {
			glow.rotation += 0.6;
		}
		
		private function onMap(e:MouseEvent = null):void {
			close();
			new PuzzleMapWindow().show();
		}
		
		private function onHome(e:MouseEvent):void {
			if (homeBttn.mode == Button.DISABLED) return;
			
			if (App.user.worldID != User.HOME_WORLD) {
				Travel.goTo(User.HOME_WORLD);
			}
			
			close();
		}
		
		private function onUpgrade(e:MouseEvent):void {
			if (settings.target && settings.target.level < settings.target.totalLevels) {
				settings.target.openConstructWindow();
				close();
			}
		}
		
		public function resize(e:AppEvent = null):void {
			settings.width = App.self.stage.stageWidth;
			settings.height = App.self.stage.stageHeight;
			layer.x = 0;
			layer.y = 0;
			exit.x = settings.width - 70;
			exit.y = 20;
			
			titleLabel.x = settings.width / 2;
			titleLabel.y = 10;
			homeBttn.x = 12;
			homeBttn.y = settings.height - homeBttn.height - 25;
			upgradeBttn.x = homeBttn.x;
			upgradeBttn.y = homeBttn.y;
			mapBttn.x = (settings.width - mapBttn.width) / 2;
			mapBttn.y = settings.height - mapBttn.height - 20;
			if (glow) {
				glow.x = mapBttn.x + mapBttn.width / 2;
				glow.y = mapBttn.y + mapBttn.height / 2;
			}
			bttnContainer.x = (settings.width - bttnContainer.width) / 2;
			bttnContainer.y = settings.height - bttnContainer.height - 24;
			
			redrawColors();
			arrowsUpdate();
			drawImage();
			itemsResize();
		}
		
		public function drawImage():void {
			back.width = settings.width;
			back.height = settings.height;
			
			if (!images[paginator.page].bmd) {
				if (!preloader) {
					preloader = new Preloader();
					bodyContainer.addChild(preloader);
				}
				preloader.x = back.width / 2;
				preloader.y = back.height / 2;
				
				Load.loading(images[paginator.page].link, onLoad);
				return;
			}
			
			image.bitmapData = images[paginator.page].bmd;
			image.smoothing = true;
			if (paginator.page == 1 || paginator.page == 2) {
				image.height = settings.height;
				image.scaleX = image.scaleY;
			}else {
				image.height = images[paginator.page].bmd.height;
				image.scaleX = image.scaleY;
			}
			
			imageContainer.x = (settings.width - image.width) / 2 - 90;
			imageContainer.y = int((settings.height - image.height) / 2) - 100;
			
			var position:Object
			if (settings.hasOwnProperty("navigateTo"))
			{
				position = getPosition(settings.navigateTo);
				imageContainer.x = -position.x + App.self.stage.stageWidth / 2;
				imageContainer.y = -position.y + App.self.stage.stageHeight / 2;
				
				mMove(null);
			}
			
			if (paginator.page == 1 || paginator.page == 2) {
				imageContainer.x = (App.self.stage.stageWidth - image.width) / 2;
				imageContainer.y = int((App.self.stage.stageHeight - image.height) / 2);
			}
			
			if (settings.find != 0 && paginator.page == 0 && pages[paginator.page].hasOwnProperty(settings.find)) {
				position = getPosition(settings.find);
				imageContainer.x = -position.x + App.self.stage.stageWidth / 2;
				imageContainer.y = -position.y + App.self.stage.stageHeight / 2;
				
				mMove(null);
			}
			
			if (paginator.page == 0) {				
				imageContainer.addEventListener(MouseEvent.MOUSE_DOWN, mDown);
				imageContainer.addEventListener(MouseEvent.MOUSE_UP, mUp);
				imageContainer.addEventListener(MouseEvent.MOUSE_MOVE, mMove);
				App.self.stage.addEventListener(Event.MOUSE_LEAVE, mouseLeave);
			} else {
				if (imageContainer.hasEventListener(MouseEvent.MOUSE_DOWN)) imageContainer.removeEventListener(MouseEvent.MOUSE_DOWN, mDown);
				if (imageContainer.hasEventListener(MouseEvent.MOUSE_UP)) imageContainer.removeEventListener(MouseEvent.MOUSE_UP, mUp);
				if (imageContainer.hasEventListener(MouseEvent.MOUSE_MOVE)) imageContainer.removeEventListener(MouseEvent.MOUSE_MOVE, mMove);
				if (App.self.stage.hasEventListener(Event.MOUSE_LEAVE)) App.self.stage.removeEventListener(Event.MOUSE_LEAVE, mouseLeave);
			}
		}
		private function onLoad(data:Bitmap):void {
			if (preloader && bodyContainer.contains(preloader)) {
				bodyContainer.removeChild(preloader);
				preloader = null;
			}
			
			for (var i:int = 0; i < items.length; i++) {
				items[i].visible = true;
			}
			
			images[paginator.page].bmd = data.bitmapData;
			drawImage();
			itemsResize();
		}
		
		private function mDown(event:MouseEvent):void {
			var beginX:int = (App.self.stage.stageWidth > image.width) ? (App.self.stage.stageWidth - image.width) / 2 : 0;
			var beginY:int = (App.self.stage.stageHeight > image.height) ? (App.self.stage.stageHeight - image.height) / 2 : 0;
			imageContainer.startDrag(false, new Rectangle(beginX, beginY, (App.self.stage.stageWidth < image.width) ? App.self.stage.stageWidth - image.width : 0, (App.self.stage.stageHeight < image.height) ? App.self.stage.stageHeight - image.height : 0));
		}
		
		private function mUp(event:MouseEvent):void{
			imageContainer.stopDrag();
		}
		private function mouseLeave(event:Event):void{
			imageContainer.stopDrag();
		}
		
		private function mMove(event:MouseEvent):void{
			if (imageContainer.x > 0 - bodyContainer.x)
				imageContainer.x = 0 - bodyContainer.x;
				
			if (imageContainer.y > 0 - bodyContainer.y)
				imageContainer.y = 0 - bodyContainer.y;
				
			if (imageContainer.x < App.self.stage.stageWidth - imageContainer.width - bodyContainer.x)
				imageContainer.x = App.self.stage.stageWidth - imageContainer.width - bodyContainer.x;
				
			if (imageContainer.y < App.self.stage.stageHeight - imageContainer.height - bodyContainer.y)
				imageContainer.y = App.self.stage.stageHeight - imageContainer.height - bodyContainer.y;	
			
			if(event)
				event.updateAfterEvent();
		}
		
		private var positions:Object = {
			"112":{'x':1610,'y':500},
			"418":{'x':1620,'y':670},
			"535":{'x':1880,'y':600},
			"555":{'x':400,'y':400},
			"641":{'x':1200,'y':420},
			"767":{'x':1760,'y':360},
			"903":{'x':1170,'y':710},
			"932":{'x':1370,'y':850},
			"1122":{'x':1010,'y':460},
			"1198":{'x':1370,'y':410},
			"1371":{'x':780,'y':550},
			"1569":{'x':1100,'y':530},
			"1801":{'x':1370,'y':630},
			"1907":{'x':1860,'y':490},
			"2099":{'x':1300,'y':1400},
			"2195":{'x':2300,'y':1050},
			"2501":{'x':2000,'y':2250},
			"2673":{'x':2300,'y':1500},
			"3060":{'x':1700,'y':850},
			"2813":{'x':980,'y':320}
		};
		
		public function getPosition(wid:int):Object {
			var position:Object = { x:0, y:0 };
			
			if (positions[wid]) {
				position.x =  positions[wid].x;
				position.y =  positions[wid].y;
			}else {
				var map:Object = App.user.maps[paginator.page];
				if (map.ilands && map.ilands[wid] && (map.ilands[wid].pos is String) && map.ilands[wid].pos.indexOf(':') >= 0) {
					var array:Array = map.ilands[wid].pos.split(':');
					var posX:int = int(array[0]);
					var posY:int = int(array[1]);
					if (!isNaN(posX) &&  !isNaN(posY) && posX > 0 && posY > 0) {
						position.x = posX;
						position.y = posY;
					}
				}
			}
			
			return position;
		}
		
		override public function contentChange():void {
			clearItems();
			
			for (var s:* in pages[paginator.page]) {
				//if ((/*int(s) == 1801 || */int(s) == 2501) && App.isSocial('YB','MX','AI'))
					//continue;
				//if ((int(s) == 2813) && !App.isSocial('DM', 'VK', 'FS', 'ML', 'OK'))
					//continue;
					if (s == 3060)
						trace();
				if (!User.inUpdate(s))
					continue;
				
				var item:TravelItem = new TravelItem( {
					sID:		int(s),
					window:		this,
					scale:		1,
					link:		Config.getIcon('Lands', s),
					align:		'center',
					hasBacking:	false,
					hasTitle:	false
					
				});
				
				
				var position:Object = getPosition(s);
				item.x =  position.x;
				item.y =  position.y;
				
				/*if (positions[s]) {
					item.x =  positions[s].x;
					item.y =  positions[s].y;
				}else {
					var map:Object = App.user.maps[paginator.page];
					if (map.ilands && map.ilands[s] && (map.ilands[s].pos is String) && map.ilands[s].pos.indexOf(':') >= 0) {
						var array:Array = map.ilands[s].pos.split(':');
						var posX:int = int(array[0]);
						var posY:int = int(array[1]);
						if (!isNaN(posX) &&  !isNaN(posY) && posX > 0 && posY > 0) {
							item.x = posX;
							item.y = posY;
						}
					}
				}*/
				items.push(item);
				imageContainer.addChild(item);
				
				if (!images[paginator.page].bmd)
					item.visible = false;
				
				if (App.user.worldID == int(item.sID))
					item.setPlace();
				
				if(Config.admin){
					item.addEventListener(MouseEvent.MOUSE_DOWN, onDown);
					item.addEventListener(MouseEvent.MOUSE_UP, onUp);
				}
			}
			
			for (var i:int = 0; i < pageBttns.length; i++) {
				if (int(pageBttns[i].name) == paginator.page) {
					pageBttns[i].state = Button.ACTIVE;
				}else{
					pageBttns[i].state = Button.NORMAL;
				}
			}
			
			resize();
		}
		private function onDown(e:MouseEvent):void {
			e.currentTarget.startDrag(false);
		}
		private function onUp(e:MouseEvent):void {
			e.currentTarget.stopDrag();
			trace(int(e.currentTarget.x / image.scaleX), int(e.currentTarget.y / image.scaleX));
		}
		
		public function itemsResize():void {
			var scale:Number = image.scaleX;
			
			for each(var item:TravelItem in items) {
				if (pages[paginator.page].hasOwnProperty(item.sID)) {
					if (positions[item.sID] && paginator.page == 0) {
						item.x =  positions[item.sID].x;
						item.y =  positions[item.sID].y;
					} else if (positions[item.sID]) {
						item.x =  positions[item.sID].x * scale;
						item.y =  positions[item.sID].y * scale;
					}
				}
			}
		}
		private function clearItems():void {
			while (items.length > 0) {
				var item:TravelItem = items.shift();
				item.dispose();
			}
		}
		
		override public function drawArrows():void {
			super.drawArrows();
			arrowsUpdate();
		}
		public function arrowsUpdate():void {
			if (paginator && paginator.arrowLeft) {
				paginator.arrowLeft.x = 10;
				paginator.arrowLeft.y = (settings.height - paginator.arrowLeft.height) / 2;
				paginator.arrowRight.x = settings.width - paginator.arrowRight.width - 10;
				paginator.arrowRight.y = (settings.height - paginator.arrowRight.height) / 2;
			}
		}
		
		private var pageBttns:Vector.<Button> = new Vector.<Button>;
		private var bttnContainer:Sprite = new Sprite();
		private function drawPageBttns():void {
			if (pageBttns.length > 0) return;
			//return;
			
			bodyContainer.addChild(bttnContainer);
			return;
			for (var s:* in App.user.maps/*images*/) {
				var bttn:Button = new Button( {
					width:		180,
					height:		52,
					caption:	App.user.maps[s]['title'],
					fontSize:	18,
					multiline:  true,
					bgColor:	[0x96c9da,0x77a1af],
					borderColor:[0xffeede,0xbcbaa6],
					fontBorderColor: 0x426e7b,
					bevelColor:	[0xbadff1,0x4f8198]
				});
				bttn.name = s;
				bttn.x = pageBttns.length * (bttn.width + 5);
				bttn.addEventListener(MouseEvent.CLICK, onPage);
				bttnContainer.addChild(bttn);
				pageBttns.push(bttn);
			}
		}
		private function onPage(e:MouseEvent):void {
			var bttn:Button = e.currentTarget as Button;
			if (bttn.mode != Button.NORMAL) return;
			
			paginator.page = int(bttn.name);
			paginator.update();
			contentChange();
		}
		
		override public function dispose():void {
			for (var i:int = 0; i < pageBttns.length; i++) {
				pageBttns[i].removeEventListener(MouseEvent.CLICK, onPage);
				pageBttns[i].dispose();
			}
			
			App.self.removeEventListener(AppEvent.ON_RESIZE, resize);
			homeBttn.removeEventListener(MouseEvent.CLICK, onHome);
			upgradeBttn.removeEventListener(MouseEvent.CLICK, onUpgrade);
			
			super.dispose();
		}
		
		public function closeAll():void {
			close();
		}
		
	}
}


import buttons.IconButton;
import buttons.ImageButton;
import core.Load;
import core.Numbers;
import effects.Effect;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.text.TextField;
import flash.utils.clearInterval;
import flash.utils.setInterval;
import wins.elements.WorldItem;
import wins.ClipperRequireWindow;
import wins.TravelWindow;
import wins.Window;
import wins.OpenWorldWindow;
import wins.ShopWindow;
import wins.SimpleWindow;
import wins.TravelRequireWindow;
import wins.TravelPayWindow;

internal class TravelItem extends WorldItem {
	
	public static var currentWorld:TravelItem;
	
	private var lockCont:Sprite;
	private var arrow:Bitmap;
	private var lock:Bitmap;
	private var lockText:TextField;
	private var titleText:TextField;
	private var place:Bitmap;
	private var teleport:TeleportItem;
	private var reqSID:*;
	private var reqLevel:*;
	public function teleportDraw():void 
	{
		if (sID != 1341 ) return;
		//if (!World.isAvailable(1341)) {
			teleport = new TeleportItem(1353,1341,window);
			addChild(teleport);
		//}
	}
	
	public function TravelItem(params:Object) {
		super(params);
	}
	override public function draw():void {
		super.draw();
		teleportDraw();
		lockCont = new Sprite();
		addChild(lockCont);
		lockCont.visible = false;
		
		lock = new Bitmap(Window.textures.timer, 'auto', true);
		lock.scaleX = lock.scaleY = 0.75;
		lock.x = -lock.width / 2;
		lock.y = 10;
		lockCont.addChild(lock);
		
		arrow = new Bitmap(Window.textures.upgradeArrow, 'auto', true);
		arrow.scaleX = arrow.scaleY = 0.5;
		lockCont.addChild(arrow);
		
		lockText = Window.drawText('0', {
			fontSize:17,
			color:0xfcf6e4,
			borderColor:0x5e3402,
			textAlign:"left",
			borderSize:2,
			width:30
		});
		lockCont.addChild(lockText);
		
		arrow.x = lock.x + (lock.width - arrow.width - 2 - lockText.textWidth-4) / 2;
		arrow.y = 25;
		lockText.x = arrow.x + arrow.width + 2;
		lockText.y = 23;
		
		place = new Bitmap(Window.textures.checkMark, 'auto', true);
		place.scaleX = place.scaleY = 0.5;
		place.x = -place.width / 2;
		place.y = 10;
		place.visible = false;
		addChild(place);
		
		if (window.settings.find == sID) {
			this.startGlowing();
		}
		
		if (window.settings.findTargets.indexOf(sID) != -1) {
			this.startGlowing(0xf6ff00);
		}
		
		titleText = Window.drawText(App.data.storage[sID].title, {
			fontSize:30,
			color:0xfcf6e4,
			borderColor:0x5e3402,
			multiline:true,
			textAlign:"center",
			width:bg.width,
			shadowSize:2
		});
		titleText.x = - titleText.width / 2;
		titleText.y = 20;
		addChild(titleText);
		
		checkLock();
		
		if (App.user.quests.data.hasOwnProperty(508) && App.user.quests.data[508].finished > 0 && [112, 903, 932, 1122, 1371].indexOf(int(sID)) != -1) {
			if (!App.user.quests.data.hasOwnProperty(516) || (App.user.quests.data.hasOwnProperty(516) && App.user.quests.data[516].finished == 0)) {
				drawSheriffStar();
			}
		}
	}
	
	private function drawSheriffStar():void {
		var sprite:LayerX = new LayerX();
		addChild(sprite);
		
		var icon:Bitmap = new Bitmap();
		sprite.addChild(icon);
		
		Load.loading(Config.getImage('content', 'sheriffs_star'), function(data:*):void {
			icon.bitmapData = data.bitmapData;
			icon.smoothing = true;
			icon.x = 30;
			icon.y = -50;
		});
		
		sprite.tip = function():Object {
			return {
				text:		Locale.__e('flash:1453284228105')
			}
		}
		
	}
	
	private var block:Boolean = false;
	override public function onClick(e:MouseEvent = null):void {
		if (!params.clickable) minilockAlert();
		
		if (!params.clickable || block) return;
		
		if (params.jump) jump();
		
		if (!App.user.worlds.hasOwnProperty(sID)) {
			if (App.data.storage[sID].hasOwnProperty('require') && Numbers.countProps(App.data.storage[sID].require) > 0) {
				for (var sid:String in info.require) break;
				if ((int(sid) == 933 || int(sid) == 1205 || int(sid) == 2164) && reqSID) {
					Load.loading(Config.getIcon(App.data.storage[reqSID].type, App.data.storage[reqSID].view), function(data:*):void {
						new ClipperRequireWindow( {
							popup:true,
							title:Locale.__e('flash:1394010224398'),
							buttonText:Locale.__e('flash:1418816484831'),
							text:Locale.__e('flash:1442912221010'),
							bitmap:new Bitmap(data.bitmapData),
							sID:sid,
							search:false,
							onGo:function():void { 
								/*if (App.isSocial('FB','HV','NK')) {
									new SimpleWindow( {
										popup:true,
										label:SimpleWindow.ATTENTION,
										title:Locale.__e("flash:1429185188688"),
										text:Locale.__e('flash:1429185230673'),
										height:300
									}).show()
								} else*/ {
									block = true;
									App.user.world.openWorld(sID, false, function():void {
										block = false;
										if (sID == 1198) Map.generateResources = true;
										onClick(e);
									},false); 
								}
							}
						}).show();
					});
				} else {
					new TravelRequireWindow ( {
						sIDmap: sID,
						description: Locale.__e('flash:1432032135047'),
						callback: function():void {
							block = true;
							App.user.world.openWorld(sID, false, function():void {
								block = false;
								onClick(e);
							});
						}
					}).show();
				}
			}else {
				block = true;
				App.user.world.openWorld(sID, false, function():void {
					block = false;
					onClick(e);
				});
			}
			return;
		}
		
		if (sID != App.map.id) {
			if (App.data.storage[sID].hasOwnProperty('charge')) {
				if (Numbers.countProps(App.data.storage[sID]['charge']) > 0) {
					new TravelRequireWindow ( {
						sIDmap: sID,
						description: Locale.__e('flash:1432032135047'),
						callback: function():void {
							Travel.goTo(sID);
							window.close();
						}
					}).show();
					//new TravelPayWindow( {
						//worldID:	sID,
						//window:		window,
						//content:	App.data.storage[sID].charge
					//}).show();
				}
			} else {
				for (var id:String in App.data.storage[sID].require) break;
				if (int(id) == 933 || int(id) == 1205) {
					Load.loading(Config.getIcon(App.data.storage[reqSID].type, App.data.storage[reqSID].view), function(data:*):void {
						new ClipperRequireWindow( {
							popup:true,
							title:Locale.__e('flash:1394010224398'),
							buttonText:Locale.__e('flash:1418816484831'),
							text:Locale.__e('flash:1442912221010'),
							bitmap:new Bitmap(data.bitmapData),
							sID:id,
							search:false,
							onGo:function():void { 
								Travel.goTo(sID);
								window.close(); 
							}
						}).show();
					});
				} else {
					Travel.goTo(sID);
					window.close();
				}
			}
		}
	}
	
	public function checkLock():void {
		var item:*;
		for (var i:* in App.user.maps[window.paginator.page].ilands) { 
			if (i == sID) {
				item = App.user.maps[window.paginator.page].ilands[i];
				break;
			}
		}
		var island:Object = App.data.storage[sID];
		reqLevel = int(island.level);
		if (reqLevel > App.user.level) {
			params.clickable = false;
			available = false;
			Effect.light(this, 0, 0);
			return;
		}
		
		if (item.hasOwnProperty('req')) {
			for (var j:* in item.req) { 
				reqSID = j;
				if (App.user.stock.check(j) < item.req[j])
				{
					//lockCont.visible = true;
					params.clickable = false;
					available = false;
					Effect.light(this, 0, 0);
					return;
				}
			}
		}
		
		//lockCont.visible = false;
		params.clickable = true;
		available = true;
		Effect.light(this, 0, 1);
		/*if (!World.isAvailable(sID)) {
			lockCont.visible = true;
			params.clickable = false;
		}else {
			lockCont.visible = false;
			params.clickable = true;
		}*/
	}
	
	public function setPlace(value:Boolean = true):void {
		if (TravelItem.currentWorld) {
			TravelItem.currentWorld.place.visible = false;
			TravelItem.currentWorld.params.clickable = true;
			TravelItem.currentWorld = null;
		}
		if (value) {
			TravelItem.currentWorld = this;
			//this.startGlowing();
			//addGlow(Window.textures.iconEff, 0, 1.2);
			place.visible = true;
			params.clickable = false;
		}
	}
	
	private var container:Sprite;
		public function addGlow(bmd:BitmapData, layer:int, scale:Number = 1):void
		{
			var btm:Bitmap = new Bitmap(bmd);
			container = new Sprite();
			container.addChild(btm);
			btm.scaleX = btm.scaleY = scale;
			btm.smoothing = true;
			btm.x = -btm.width / 2;
			btm.y = -btm.height / 2;
			
			addChildAt(container,0);
			
			container.mouseChildren = false;
			container.mouseEnabled = false;
			
			container.x = bg.x +bg.width / 2;
			container.y = bg.y +bg.height / 2;
			
			App.self.setOnEnterFrame(rotateBtm);
			this.startGlowing();
		}
		
		private var interval:int = 0;
		private var startInterval:int = 0;
		private function rotateBtm(e:Event):void 
		{
			container.rotation += 1;
		}
	
	public function get isMiniOpen():Boolean {
		/*if (info.size == World.MINI) {
			var ports:Object = App.user.storageRead('port', { } );
			if (!ports.hasOwnProperty(789) || ports[789] < World.minimaps[sID]) {
				return false;
			}
		}*/
		
		return true;
	}
	
	private function minilockAlert():void {
		if (TravelItem.currentWorld && TravelItem.currentWorld.sID == this.sID) {
			params.window.close();
			return;
		}
		if (/*!reqSID && */reqLevel && reqLevel > App.user.level) {
			new SimpleWindow( {
				popup:true,
				width:550,
				title:Locale.__e('flash:1432020823895'),
				buttonText:Locale.__e('flash:1382952380298'),
				text:Locale.__e('flash:1396606807965', reqLevel)/*,
				bitmap:new Bitmap(data.bitmapData)*/
			}).show();
			return;
		}
		Load.loading(Config.getIcon(App.data.storage[reqSID].type, App.data.storage[reqSID].view), function(data:*):void {
			
				new ClipperRequireWindow( {
					popup:true,
					title:Locale.__e('flash:1394010224398'),
					buttonText:Locale.__e('flash:1418816484831'),
					text:Locale.__e('flash:1442912221010'),
					bitmap:new Bitmap(data.bitmapData),
					sID:reqSID,
					search:true,
					onFind:function():void {
							if (reqSID == 903) {
								window.settings.find = 903;
								window.contentChange();
								//window.close(); 
							} if (reqSID == 2164) {
								if (App.user.worldID == User.HOME_WORLD) {
									window.close();
									var boot:Array = Map.findUnits([315]);
									if (boot.length > 0 ) {
										App.map.focusedOn(boot[0], true, function():void {
											boot[0].click();
										});
									}
								}else {
									window.close(); 
									TravelWindow.show( { find:User.HOME_WORLD } );
								}
							} else {
								new SimpleWindow( {
									title:Locale.__e('flash:1382952379893'),
									text: Locale.__e('flash:1449050006330'),
									popup:true
								}).show();
							}
						},
					onBuy:function():void {
						checkLock();
						onClick();
					}
				}).show();
		});
	}
	
}
import wins.PurchaseWindow;
internal class TeleportItem  extends LayerX{
	private var teleportTxt:TextField;
	private var teleportImg:Bitmap;
	private var teleportBtn:ImageButton;
	private var teleportID:int;
	private var wID:int;
	private var window:Object;
	private var item:Object;
	public function TeleportItem(teleportId:int, wID:int, window:Object):void {
		super();
		teleportID = teleportId;
		item = App.data.storage[teleportID];
		this.wID = wID;
		this.window = window;
		draw();
	}
	
	private function draw ():void {
		
		teleportImg = new Bitmap(Window.textures.referalRoundBacking);
		addChild (teleportImg);
		teleportImg.smoothing = true;
		teleportImg.x = 25;
		teleportImg.y = 25;
		teleportImg.scaleX = 0.4;
		teleportImg.scaleY = 0.4;
		textDraw(teleportID);
		Load.loading(Config.getIcon(item.type, item.preview), function(bitmap:Bitmap):void {
			teleportBtn = new ImageButton(bitmap.bitmapData);
			addChild(teleportBtn);
			teleportBtn.x = 28;
			teleportBtn.y = 28;
			teleportBtn.scaleX = 0.36;
			teleportBtn.scaleY = 0.36;
			teleportBtn.addEventListener(MouseEvent.CLICK, onClick);
			teleportBtn.tip = function():Object {
				return {
					title:item.title,
					text:item.description
				}
			}
		});
	}
	
	private function goTo():void {
		if (!App.user.worlds.hasOwnProperty(item.map)) 
		{
			App.user.stock.sell(item.sID, 1, function():void 
			{
				/*World.openMap(item.map, function():void {
					Travel.goTo(item.map);
				});*/
			});
		}else {
			App.user.stock.sell(item.sID, 1, function():void 
			{
				Travel.goTo(item.map);
			});
		}
		window.close();
	}
	
	private function onClick(e:MouseEvent):void {
		if (App.user.stock.take(teleportID, 1)){			
			goTo();
			teleportBtn.removeEventListener(MouseEvent.CLICK, onClick);
		}else {
			window.close();
			ShopWindow.show( { find:[1358] } );
			//new PurchaseWindow( {
				//width:230,
				//itemsOnPage:1,
				//content:[App.data.storage[1358]],
				//title:'',
				//description:'',
				//closeAfterBuy:true,
				//callback:function(sID:int):void {
					//var object:* = App.data.storage[sID];
					//App.user.stock.add(sID, object);
					//teleportTxt.text = App.user.stock.count(teleportID).toString() + ' / 1' ;
				//}
			//}).show();
		}
	}
	private function textDraw (teleportID:int):void {
		var drawText:String =   App.user.stock.count(teleportID).toString() + ' / 1' ;
		if ( App.user.stock.count(teleportID) > 0 ) {
			teleportTxt = Window.drawText(drawText,{
				color:0xffffff,
				borderColor:0x1d2740,
				textAlign:"center",
				fontSize:17
			});
		}
		else {
			teleportTxt = Window.drawText(drawText ,{
				color:0xef7563,
				borderColor:0x623126,
				textAlign:"center",
				fontSize:17
			});
		}
		teleportTxt.x = 25;
		teleportTxt.y = 56;
		teleportTxt.width = teleportImg.width;
		addChild(teleportTxt);
	}

	
}
