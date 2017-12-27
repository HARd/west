package wins 
{
	import buttons.Button;
	import buttons.ImageButton;
	import buttons.MixedButton;
	import core.Load;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.utils.setTimeout;
	import ui.SystemPanel;
	import ui.UserInterface;
	import units.Bridge;
	import units.Lantern;
	import units.Whispa;
	import wins.elements.MapIcon;
	
	
	public class MapWindow extends Window
	{
		
		public var info:Object
		public function MapWindow(settings:Object)
		{
			settings['width'] = 700;
			settings['height'] = 500;
			settings['faderAlpha'] = 1;
			settings['hasArrows'] = false;
			settings['hasPaginator'] = false;
			
			info = App.data.storage[settings.sID];
			mapWindow = this;
			super(settings);
		}
		
		public static var mapWindow:MapWindow = null;
		private var _title:Sprite = new Sprite();
		override public function drawTitle():void {
		
		}
		
		public function _drawTitle():void {
			
			_title  = titleText( {
				title				: info.title,
				color				: settings.fontColor,
				multiline			: true,			
				fontSize			: settings.fontSize,				
				textLeading	 		: settings.textLeading,				
				borderColor 		: settings.fontBorderColor,			
				borderSize 			: settings.fontBorderSize,	
				
				shadowBorderColor	: settings.shadowBorderColor || settings.fontColor,
				
				autoSize			: 'left',
				textAlign			: 'left',
				sharpness 			: 50,
				thickness			: 50,
				border				: true
			});
			
			bodyContainer.addChild(_title);
			_title.x = settings.width / 2 - _title.width / 2;
			_title.y = -30;
		}
		
		override public function drawBackground():void {
			
		}
		
		override public function drawBody():void {
			bodyContainer.addChild(exit);
			exit.y -= 60;
			Load.loading(Config.getSwf(info.type, info.image), onLoad);
			_drawTitle();
		}
		
		import wins.elements.WhispaSpirit;
		public var whispa:WhispaSpirit;
		public function addWhispa(icon:MapIcon):void 
		{
			whispa = new WhispaSpirit();
			whispa.x = icon.x;
			whispa.y = icon.y;
			bodyContainer.addChild(whispa);
		}
		
		private var homeBttn:MixedButton;
		private function drawHomeBttn():void 
		{
			/*homeBttn = new MixedButton(Window.textures.bubble,{caption:Locale.__e("flash:1382952379764"),fontSize:24});
			/*homeBttn = new ImageButton( {
				caption:Locale.__e('flash:1382952379764'),
				width:130,
				height:40
			})
			
			var bttnMainHome = 
			homeBttn.textLabel.x -= 5;
			bodyContainer.addChild(homeBttn);
			homeBttn.x = settings.width - homeBttn.width - 40;
			homeBttn.y = settings.height - 50 - 10;
			homeBttn.addEventListener(MouseEvent.CLICK, onHomeClick);
						
			iconCoords['171'] = {x:homeBttn.x+homeBttn.width/2, y:homeBttn.y+homeBttn.height/2 - 5};
			*/
		}
		private function onHomeClick(e:MouseEvent):void {
			if (App.user.worldID == User.HOME_WORLD){
				close();
			}else{	
				onDreamEvent(User.HOME_WORLD);
			}
		}
		
		public override function dispose():void {
			if (whispa)	whispa.dispose();
			whispa = null
			super.dispose();
			//homeBttn.removeEventListener(MouseEvent.CLICK, onHomeClick);
		}
		
		public var mapImage:Bitmap
		public var iconsCoords:Object
		private function onLoad(data:*):void {
			mapImage = new Bitmap(data.mapImage);
			bodyContainer.addChildAt(mapImage,0);
			mapImage.x = (settings.width - mapImage.width) / 2;
			mapImage.y = (settings.height - mapImage.height) / 2;
			
			iconsCoords = data.getIconsCoords();
			createIcons();
			drawHomeBttn();
		}
		
		public var icons:Array = [];
		public function createIcons():void 
		{
			line = new Shape();
			bodyContainer.addChild(line);
			
			var icon:MapIcon;
				icon = new MapIcon(User.HOME_WORLD, this);
				icons.push(icon);
				icon.x = settings.width - 70 + 6 - 15;
				icon.y = settings.height - 10 + 40 - 10;
				bodyContainer.addChild(icon);
			
			for (var i:* in info.dreams) {
				icon = new MapIcon(info.dreams[i], this);
				icons.push(icon);
				icon.x = mapImage.x + iconsCoords[i].x;
				icon.y = mapImage.y + iconsCoords[i].y;
				bodyContainer.addChild(icon);
			}
			
			var currentWorldID:int = 171;
			if (App.user.mode == User.OWNER) {
				currentWorldID = App.user.worldID;
			}else {
				currentWorldID = App.owner.worldID;
			}
			
			for each(icon in icons) {
				iconCoords[icon.worldID] = icon;
				icon.addEventListener(MouseEvent.CLICK, onIconClick);
				icon.addEventListener(MouseEvent.MOUSE_OVER, onOver);
				icon.addEventListener(MouseEvent.MOUSE_OUT, onOut);
				
				
				if (icon.worldID == currentWorldID) {
					addWhispa(icon);
					icon.bitmap.filters = [new GlowFilter(0xFFFF00, 1, 10, 10, 3)];
				}
			}
		}
		
		public var linkages:Object = {
			171: {
				696:[],
				442:[696],
				668:[696, 442],
				834:[696, 442, 668]
			},
			696: {
				171:[],
				442:[],
				668:[442],
				834:[442,668]
			},
			442: {
				171:[696],
				696:[],
				668:[],
				834:[668]
			},
			668:{
				171:[442,696],
				696:[442],
				442:[],
				834:[]
			},
			834:{
				171:[668,442,696],
				696:[668,442],
				442:[668],
				668:[]
			}
		}
		public var iconCoords:Object = {
			
		};
		
		private var line:Shape;
		private function onOver(e:MouseEvent):void 
		{
			if (e.currentTarget.unready == true) return;
			e.currentTarget.bitmap.filters = [new GlowFilter(0xFFFF00, 1, 10, 10, 3)];
			
			var start_WID:int = App.user.worldID;
			var finish_WID:int = e.currentTarget.worldID;
			if (start_WID == finish_WID || !linkages.hasOwnProperty(finish_WID)) return;
			
			var _array:Array = linkages[start_WID][finish_WID];
			var targets:Array = [start_WID];
			for (var i:int = 0; i < _array.length; i++) 
			{
				targets.push(_array[i]);
			}
			targets.push(finish_WID);
			
			drawLinks(targets);

			return;
			/*
			line.graphics.clear();
						
			line.graphics.lineStyle(3, 0xFFFF00, 1, true);
			
			var target:Object = iconCoords[targets[0]];
			
			line.graphics.moveTo(target.x, target.y);
			for (i = 1; i < targets.length; i++) {
				target = iconCoords[targets[i]]
				line.graphics.lineTo(target.x, target.y);
			}
			
			line.filters = [new GlowFilter(0xFFFF00, 1, 10, 10, 3)];
			line.alpha = 0.8;*/
		}
		
		private function drawLinks(targets:Array):void {
			
			for (var i:int = 0; i < targets.length; i++) 
			{
				var icon:MapIcon = iconCoords[targets[i]];
				
				if (targets[i - 1] != null) {
					icon.drawArrowTo(iconCoords[targets[i - 1]]);
				}
				
				if (targets[i + 1] != null) {
					icon.drawArrowTo(iconCoords[targets[i + 1]]);
				}
			}
		}
		
		private function onOut(e:MouseEvent):void {
			//line.graphics.clear();
			if(e.currentTarget.worldID != App.user.worldID)
				e.currentTarget.bitmap.filters = [];
				
			for each(var icon:MapIcon in icons) {
				icon.removeArrows();
			}
		}
		
		private function onIconClick(e:MouseEvent):void {
			
			var world:Object = App.data.storage[e.currentTarget.worldID];
			var worldID:uint = e.currentTarget.worldID;
			
			if (e.currentTarget.unready) return;
			
			if(whispa)
				whispa.flyTo(e.currentTarget);
				
			if(!e.currentTarget.open)
			{
				new OpenWorldWindow({
					sID:e.currentTarget.worldID,
					require:world.require,
					unlock:world.unlock,
					bitmapData:e.currentTarget.bitmap._bitmapData,
					openZone:function(sID:uint, buy:Boolean = false):void {
						App.user.world.openWorld(sID, buy, onOpenWorldComplete);
					},
					popup:true
				}).show();
			}
			else
			{
				for each(var _icon:MapIcon in icons) {
					_icon.filters = [];
				}
				
				App.ui.flashGlowing(e.currentTarget);
				setTimeout(function():void {
					
					if(App.user.mode == User.OWNER)
						onDreamEvent(worldID);
					/*else{
						App.ui.bottomPanel.visitOwnerWorld(worldID);
						close();
					}*/	
						
				}, 1000);
				
				/*new SimpleWindow( {
					title:Locale.__e('flash:1382952380215'),
					label:SimpleWindow.ATTENTION,
					text:Locale.__e("flash:1382952380218",[App.data.storage[worldID].title]),
					sID:worldID,
					popup:true,
					buttonText:Locale.__e("flash:1382952380219"),
					ok:function():void {
						onDreamEvent(worldID);
					}
				}).show();*/
			}
		}
		
		private function onOpenWorldComplete(worldID:uint):void
		{
			for each(var icon:MapIcon in icons) {
				if (icon.worldID == worldID) {
					icon.open = true;
				}
			}
			new SimpleWindow( {
				title:App.data.storage[worldID].title,
				label:SimpleWindow.BUILDING,
				text:Locale.__e("flash:1382952380220"),
				sID:worldID,
				popup:true,
				buttonText:Locale.__e("flash:1382952380219"),
				ok:function():void {
					onDreamEvent(worldID);

					if(worldID == 668 || worldID == 834){
						setTimeout(function():void {
							welcomeWorldMessage(worldID);
						},2000);
					}
				}
			}).show();
		}
		
		private function welcomeWorldMessage(worldID:*):void {
			
			var text:String
			switch(worldID) {
				case 668:
					text = Locale.__e("flash:1383313800169");
					break;
				case 834:
					text = Locale.__e("flash:1388748701580");
					break;	
			}
			
			new SimpleWindow( {
				title:App.data.storage[worldID].title,
				label:SimpleWindow.BUILDING,
				text:text,
				sID:worldID,
				popup:true,
				height:400,
				buttonText:Locale.__e("flash:1382952380298")
			}).show();
		}
		
		public static var visitWindow:VisitWindow;
		public static var worldID:uint;
		public static function onDreamEvent(worldID:uint):void {
			
			if (worldID == App.user.worldID) {
				mapWindow.close();
				return;
			}
			
			MapWindow.worldID = worldID;
			mapWindow.close();
			App.user.onStopEvent();
			visitWindow = new VisitWindow({title:Locale.__e('flash:1382952380050',[App.data.storage[worldID].title])});
			visitWindow.addEventListener(WindowEvent.ON_AFTER_OPEN, onLoadUser);
			visitWindow.show();	
		}
		
		private static function onLoadUser(e:WindowEvent):void {
			visitWindow.removeEventListener(WindowEvent.ON_AFTER_OPEN, onLoadUser);
			ShopWindow.shop = null;
			//ShopWindow.history.section = 2;
			App.self.addEventListener(AppEvent.ON_USER_COMPLETE, onUserComplete);
			App.user.world.dispose();
			App.user.dreamEvent(worldID);
		}
		
		private static function onUserComplete(e:AppEvent):void {
			App.self.removeEventListener(AppEvent.ON_USER_COMPLETE, onUserComplete);
			
			App.map.dispose();
			App.map = null;
			App.self.addEventListener(AppEvent.ON_MAP_COMPLETE, onMapComplete);
			
			App.user.mode = User.OWNER;
			App.map = new Map(App.user.worldID, App.user.units, false);
			App.map.load();
		}
		
		private static function onMapComplete(e:AppEvent):void 
		{
			App.self.removeEventListener(AppEvent.ON_MAP_COMPLETE, onMapComplete);
			//Вызываем событие окончания flash:1382952379984грузки игры, можно раставлять теперь объекты на карте
			//mapWindow.dispatchEvent(new AppEvent(AppEvent.ON_GAME_COMPLETE));
			
			if(visitWindow != null){
				visitWindow.close();
				visitWindow = null;
			}
			
			App.user.addPersonag();
			App.map.scaleX = App.map.scaleY = SystemPanel.scaleValue;
			App.map.center();
			
			Lantern.init();
		}
	}
}