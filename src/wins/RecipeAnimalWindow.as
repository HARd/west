package wins 
{
	import buttons.Button;
	import buttons.ImageButton;
	import buttons.ImagesButton;
	import buttons.MoneyButton;
	import com.flashdynamix.motion.extras.BitmapTiler;
	import core.Load;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.text.TextField;
	import ui.Hints;
	import ui.UserInterface;
	import units.Techno;
	import wins.elements.OutItem;
	
	public class RecipeAnimalWindow extends Window
	{
		public var item:Object;
		
		public var bitmap:Bitmap;
		public var title:TextField;
		
		private var buyBttn:MoneyButton;
		
		private var sID:uint;
		private var formula:Object;
		public var container:Sprite = new Sprite();
		
		private var partList:Array = [];
		private var padding:int = 24;
		public var outItem:OutItem;
		
		private var arrowLeft:ImageButton;
		private var arrowRight:ImageButton;
		
		private var prev:int = 0;
		private var next:int = 0;
		private var bg1:Shape;
		private var bg2:Shape;
		private var _background:Bitmap;
		private var _equality:Bitmap;
		
		public function RecipeAnimalWindow(settings:Object = null):void
		{
			if (settings == null) {
				settings = new Object();
			}
			
			settings['sID'] = settings.sID/* || 0*/;
			
			settings["width"] = 475;
			settings["height"] = 500;
			settings["popup"] = true;
			settings["fontBorderSize"] = 1,
			settings["fontBorderColor"] = [0xb98659],
			settings["fontColor"] = [0xfffef6];
			//settings["filters"] = null;
			settings["fontSize"] = 50;
			settings["callback"] = settings["callback"] || null;
			settings["dontCheckTechno"] = settings["dontCheckTechno"] || false;
			settings["hasPaginator"] = false;
			settings['recipeBttnName'] = settings.recipeBttnName || Locale.__e("flash:1382952380036");
			
			formula = App.data.crafting[settings.fID];
			
			
			sID = formula.out;
			settings["title"] =/*+= " " +*/App.data.storage[sID].title;
			
			
			if (settings.win != undefined) {
				var crafting:Object = {};
				for (var itm:* in settings.win.craftData) {
					if (settings.win.craftData[itm].lvl <= settings.win.settings.target.level) {
						crafting[itm] = settings.win.craftData[itm].fid;
					}
				}
				for each(var item:* in crafting) {
					if (settings.fID == item) {
						break;
					}
					prev = item;
				}
				
				for each(item in crafting) {
					if (next == -1) {
						next = item;
						break;
					}
					if (settings.fID == item) {
						next = -1;
					}
				}
			}
			
			var requiresCount:int = 0;
			var requires:Object = { };
			var materialsCount:int = 0;
			var materials:Object = { };
			for (var sID:* in formula.items) {
				switch(sID) {
					//case Stock.COINS:
					/*case Stock.FANTASY:*/
					//case Stock.FANT:
					//case Stock.GUESTFANTASY:
					case Techno.TECHNO:
							requiresCount ++;
							requires[sID] = formula.items[sID];
						break;
					default:
							materialsCount ++;
							materials[sID] = formula.items[sID];
						break;	
				}
			}
			
			settings['requires'] = requires;
			settings['materials'] = materials;
			if (materialsCount == 0){
				settings['materials'][Stock.FANTASY] = requires[Stock.FANTASY];
				delete settings['requires'][Stock.FANTASY];
			}	
			
			super(settings);	
			
			App.self.addEventListener(AppEvent.ON_CHANGE_STOCK, onStockChange);
			App.self.addEventListener(AppEvent.ON_AFTER_PACK, onStockChange);
			App.self.addEventListener(AppEvent.ON_TECHNO_CHANGE, onStockChange);
		}
		
		private function onStockChange(e:AppEvent):void 
		{
			if (requiresList && requiresList.parent) {
				requiresList.parent.removeChild(requiresList);
				requiresList.dispose();
				requiresList = null;
			}
			
			for (var i:int = 0; i < partList.length; i++ ) {
				var itm:MaterialItem = partList[i];
				if (itm.parent) itm.parent.removeChild(itm);
				itm.removeEventListener(WindowEvent.ON_CONTENT_UPDATE, onUpdateOutMaterial);
				itm.dispose();
				itm = null;
			}
			partList.splice(0, partList.length);
			
			if (_equality && _equality.parent) {
				_equality.parent.removeChild(_equality);
				_equality = null;
			}
			
			if (outItem && outItem.parent) {
				outItem.parent.removeChild(outItem);
				outItem = null;
			}
			
			for (i = 0; i < container.numChildren; i++ ) {
				container.removeChildAt(0);
				i--;
			}
			
			if (container && container.parent) {
				container.parent.removeChild(container);
			}
			createItems(settings['materials']);
			
			container.x = padding + (backgroundWidth - container.width) / 2;
		}
		
		override public function drawBackground():void {

		}
		
		override public function drawExit():void {
			super.drawExit();
			
			exit.x = settings.width - exit.width + 63;
			exit.y = -8;
		}
		
		override public function drawTitle():void 
		{	
			titleLabel = titleText( {
				title				: settings.title,
				color				: 0xffffff,
				multiline			: settings.multiline,			
				fontSize			: settings.fontSize,				
				textLeading	 		: settings.textLeading,				
				borderColor 		: settings.fontBorderColor,		
				borderSize 			: settings.fontBorderSize,	
				filters				: null,
				shadowBorderColor	: settings.shadowBorderColor || settings.fontColor,
				//width				: settings.width - 340,
				textAlign			: 'center',
				sharpness 			: 50,
				thickness			: 50,
				border				: true
			})
			titleLabel.x = (settings.width - titleLabel.width) * .5;
			titleLabel.y = -55;					
			
			var recipeText:String;
				recipeText = Locale.__e("flash:1393854850716") + ":";
				
			var recipeLabel:TextField = drawText(recipeText, {
				fontSize:34,
				color:0xffffff,
				borderColor:0x814f31
			});
			bodyContainer.addChild(recipeLabel);
			recipeLabel.width = recipeLabel.textWidth;
			recipeLabel.x = 220;
			recipeLabel.y = 160;
			
			drawMirrowObjs('diamondsTop', titleLabel.width - 75, titleLabel.width + 55, titleLabel.y + 20, true, true);
			
			bottomContainer.addChild(titleLabel);
			
		}
		
		private var backgroundWidth:int;
		private var _minWidth:int = 360;
		private var _backLine:Shape;
		override public function drawBody():void {
			
			if (settings.hasDescription) settings.height += 40;
			titleLabel.y = -25;
			
			createItems(settings['materials']);
			settings;
			//
			container.x = padding;
			container.y = 6;
			
			backgroundWidth = partList.length * (partList[0].background.width + 5) - 5;
			
			if (backgroundWidth < _minWidth) backgroundWidth = _minWidth;
			
			container.x = padding + (backgroundWidth - container.width) / 2;
		
			_background = Window.backing(460, 294, 10, "dialogueBacking"); // бэкбэкграунд рецептов
			_background.alpha = 0.8;
			bodyContainer.addChildAt(_background, 0);
			_background.x = padding - 16 + 55;
			_background.y = 214 - 40;
			drawMirrowObjs('storageWoodenDec', _background.x + 65, _background.width - 5, _background.height + 105, true, true);
			settings.width = padding + backgroundWidth + 5 + partList[0].background.width + 20 + padding;
			
			var background:Bitmap = backing(475, 497, 30, "questBacking"); //основной бэкграунд
			background.x = 55;
			layer.addChild(background);
			

			var background2:Bitmap = Window.backing2(280, 155, 40, "questTaskBackingTop","questTaskBackingBot");
			layer.addChild(background2);
			background2.x = 170 + 55;
			background2.y = 40;
			
			bg1 = new Shape();
			bg1.graphics.beginFill(0xbca168);
			bg1.graphics.drawCircle(0, 0, 55);
			
			bg2 = new Shape();
			bg2.graphics.beginFill(0xbca168);
			bg2.graphics.drawCircle(0, 0, 55);
			
			bg1.x = background2.x + bg1.width/2 + 25;
			bg1.y = background2.y + bg1.height/2 + 30;
			bg2.x = bg1.x + bg1.width + 10;
			bg2.y = bg1.y;
			
			layer.addChild(bg1);
			layer.addChild(bg2);
			
			
			var _item:* = App.data.storage[formula.out];
			for (var sidOut:* in _item.outs) {
				break;
			}
			Load.loading(Config.getIcon(App.data.storage[sidOut].type, App.data.storage[sidOut].preview),onIconOutComplete);
			
			for (var sidReq:* in _item.require) {
				break;
			}
			Load.loading(Config.getIcon(App.data.storage[sidReq].type, App.data.storage[sidReq].preview), onIconReqComplete);
			
			titleLabel.x = settings.width / 2 - titleLabel.width / 2;			
			
			var separator:Bitmap = Window.backingShort(190, 'divider', false);
			separator.alpha = 0.8;
			separator.x = _background.x  + 55;
			separator.y = _background.y + _background.height - 52;
			bodyContainer.addChildAt(separator, 1);
			
			var separator2:Bitmap = Window.backingShort(190, 'divider', false);
			separator2.alpha = 0.8;
			separator2.x = _background.x + 410;
			separator2.y = _background.y + _background.height - 52;
			separator2.scaleX = -1;
			bodyContainer.addChildAt(separator2, 1);
			container.y = 42;			
			
			arrowLeft = new ImageButton(Window.textures.arrow, {scaleX:-0.7,scaleY:0.7});
			arrowRight = new ImageButton(Window.textures.arrow, {scaleX:0.7,scaleY:0.7});
			
			arrowLeft.addEventListener(MouseEvent.MOUSE_DOWN, onPrev);
			arrowRight.addEventListener(MouseEvent.MOUSE_DOWN, onNext);
			
			if(prev > 0){
				bodyContainer.addChild(arrowLeft);
				arrowLeft.x = settings.width * 0.2;
				arrowLeft.x = settings.width / 2 - 200;
				arrowLeft.y = -24;
			}
			
			if(next > 0){
				bodyContainer.addChild(arrowRight);
				arrowRight.x = settings.width * 0.8 - 10;
				arrowRight.x = settings.width/2 + 200 - 20;
				arrowRight.y = -24;
			}
			
			onUpdateOutMaterial();
		}
		
		private var iconReqCont:LayerX = new LayerX();
		private function onIconReqComplete(data:Object):void 
		{
			addChild(iconReqCont);
			var iconBmp:Bitmap = new Bitmap(data.bitmapData, "auto", true);
			iconBmp.x = bg1.x - iconBmp.width/2;
			iconBmp.y = bg1.y - iconBmp.height/2;
			layer.addChild(iconBmp);
			
			var text:TextField = drawText(Locale.__e('flash:1401871231747'), {
				fontSize:28,
				textAlign:"center",
				color:0x562a10,
				borderColor:0xffffff
			});
			text.x = iconBmp.x;
			text.y = iconBmp.y - 35;
			layer.addChild(text);
			
		}
		
		private var iconOutCont:LayerX = new LayerX();
		private function onIconOutComplete(data:Object):void 
		{
			addChild(iconOutCont);
			var iconBmp:Bitmap = new Bitmap(data.bitmapData, "auto", true);
			iconBmp.x = bg2.x - iconBmp.width/2;
			iconBmp.y = bg2.y - iconBmp.height/2;
			layer.addChild(iconBmp);
			
			var text:TextField = drawText(Locale.__e('flash:1382952380034'), {
				fontSize:28,
				textAlign:"center",
				color:0x562a10,
				borderColor:0xffffff
			});
			text.x = iconBmp.x;
			text.y = iconBmp.y - 35;
			layer.addChild(text);
		}
		
		
		private function onPrev(e:MouseEvent):void {
			close();
			settings.prodItem.recWin = new RecipeWindow( {
				title:""/*Locale.__e("flash:1382952380065")+':'*/,
				fID:prev,
				onCook:settings.win.onCookEvent,
				busy:settings.win.busy,
				win:settings.win,
				hasDescription:true,
				prodItem:settings.prodItem
			});// .show();
			settings.prodItem.recWin.show();
		}
		
		private function onNext(e:MouseEvent):void {
			close();
			settings.prodItem.recWin = new RecipeWindow( {
				title:""/*Locale.__e("flash:1382952380065")+':'*/,
				fID:next,
				onCook:settings.win.onCookEvent,
				busy:settings.win.busy,
				win:settings.win,
				hasDescription:true,
				prodItem:settings.prodItem
			});// .show();
			settings.prodItem.recWin.show();
		}
		
		public var requiresList:RequiresList;
		//private function drawRequirements(requirements:Object):void 
		//{
			//requiresList = new RequiresList(requirements, false, {dontCheckTechno:settings.dontCheckTechno});
			//bodyContainer.addChild(requiresList);
			//requiresList.x = _backLine.x + (_backLine.width- requiresList.width)/2;
			//requiresList.y = 30;
		//}
		
		private function createItems(materials:Object):void
		{
			var count2:int = 0;
			var offsetX:int = 0;
			var offsetY:int = 160;
			for(var _sID:* in materials) 
			{
				count2++;
			}
			if (count2 == 1)
			{
				offsetX = 100;
			}else if (count2 == 2)
			{
				offsetX = 32;
			}else offsetX = -15;
			
			
			var dX:int = 0;
			
			var pluses:Array = [];
			
			var count:int = 0;
			for(_sID in materials) 
			{
				var circle:Shape = new Shape();
				circle.graphics.beginFill(0xc7d3ce);
				circle.graphics.drawCircle(0, 0, 55);
				
				container.addChild(circle);
				
				var inItem:MaterialItem = new MaterialItem({   //итем рецепта
					sID:_sID,
					need:materials[_sID],
					window:this, 
					type:MaterialItem.IN,
					bitmapDY:-10
				});
				
				inItem.checkStatus();
				inItem.addEventListener(WindowEvent.ON_CONTENT_UPDATE, onUpdateOutMaterial)
				inItem.scaleX = inItem.scaleY = 1;
				partList.push(inItem);
				
				container.addChild(inItem);
				inItem.x = offsetX + 55;
				inItem.y = offsetY;
				count++;
				circle.x = inItem.x + circle.width - 35;
				circle.y = inItem.y + circle.height - 25;
				
				
				
				inItem.background.visible = false;
				
				var plus:Bitmap = new Bitmap(Window.textures.plus);
				container.addChild(plus);
				pluses.push(plus)
				//plus.x = inItem.x - plus.width / 2;
				plus.y = offsetY + inItem.background.height / 2 - plus.height / 2 - 10;
				
				//offsetX += inItem.background.width + dX;
				if (count2 == 2)
				{
					offsetX += 190;
					plus.x = inItem.x - plus.width / 2 -20 ;
				}
				else
				{
					offsetX += 150;
					plus.x = inItem.x - plus.width / 2;
				}
			}
			
			var firstPlus:Bitmap = pluses.shift();
			container.removeChild(firstPlus);
			outItem = new OutItem(onCook, {formula:formula, recipeBttnName:settings.recipeBttnName, target:settings.win.settings.target});
			//outItem.change(formula);
			outItem.background.visible = false;
			outItem.title.visible = false;
			outItem.timeText.x = 50 + 165;
			outItem.timeText.y = 182 + 210;
			outItem.icon.x = outItem.timeText.x - outItem.icon.width - 5;
			outItem.icon.y = outItem.timeText.y - 2
			outItem.bitmap.scaleX = outItem.bitmap.scaleY = 1;
			outItem.y = 18;
			outItem.x = 18 + 55;
			bodyContainer.addChild(outItem);
			
			outItem.recipeBttn.caption = Locale.__e("flash:1382952380097");
			outItem.recipeBttn.width = 160;
			outItem.recipeBttn.height = 50;
			outItem.recipeBttn.x = 475/2 - outItem.recipeBttn.width/2 - 16;
			outItem.recipeBttn.y = 450 - outItem.recipeBttn.height/2;
			outItem.bitmap.x = -20;
			outItem.bitmap.y = -75;
			bodyContainer.addChild(container);
			
			onUpdateOutMaterial();
		}
		
		public function onUpdateOutMaterial(e:WindowEvent = null):void {
			var outState:int = MaterialItem.READY;
			for each(var item:* in partList) {
				if(item.status != MaterialItem.READY){
					outState = item.status;
				}
			}
			
			if (requiresList && !requiresList.checkOnComplete())
				outState = MaterialItem.UNREADY;
			
			if (outState == MaterialItem.UNREADY) 
				outItem.recipeBttn.state = Button.DISABLED;
			else
				outItem.recipeBttn.state = Button.NORMAL;
			
			if (settings.busy && settings.fID != settings.win.settings.target.fID)
				outItem.recipeBttn.state = Button.DISABLED;
						
			/*if (formula.out == Stock.JAM && App.user.stock.count(Stock.JAM) >= App.data.levels[App.user.level].jam)
				outItem.recipeBttn.state = Button.DISABLED;*/
				
			/*if (formula.out == Stock.JAM){
				if (App.user.stock.count(Stock.JAM) >= App.data.levels[App.user.level].jam)
					outItem.jamTick.visible = true;
				else
					outItem.jamTick.visible = false;
			}	
			*/
		}
		
		
		private function onCook(e:MouseEvent):void
		{
			// TODO Обьяснять причину 
			if (settings.busy && (settings.fID != settings.win.settings.target.fID)){
				App.ui.flashGlowing(settings.win.progressBacking, 0xFFFF00);
				Hints.text(Locale.__e("flash:1382952380255"), Hints.TEXT_RED, new Point(mouseX, mouseY), false, App.self.tipsContainer);
			}
			
			/*if (formula.out == Stock.JAM && App.user.stock.count(Stock.JAM) >= App.data.levels[App.user.level].jam)
				Hints.text(Locale.__e("flash:1382952380256"), Hints.TEXT_RED, new Point(mouseX, mouseY), false, App.self.tipsContainer);*/
			
			if (e.currentTarget.mode == Button.DISABLED) {
				for (var i:int = 0; i < partList.length; i++ ) {
					partList[i].doPluck();
				}
				requiresList.doPluck();
				return;
			}
			e.currentTarget.state = Button.DISABLED;
			
			settings.onCook(settings.fID);
			
			
			close();
		}
		
		override public function dispose():void
		{
			App.self.removeEventListener(AppEvent.ON_CHANGE_STOCK, onStockChange);
			App.self.removeEventListener(AppEvent.ON_AFTER_PACK, onStockChange);
			App.self.removeEventListener(AppEvent.ON_TECHNO_CHANGE, onStockChange);
			
			for (var i:int = 0; i < partList.length; i++ ) {
				var itm:MaterialItem = partList[i];
				if (itm.parent) itm.parent.removeChild(itm);
				itm.removeEventListener(WindowEvent.ON_CONTENT_UPDATE, onUpdateOutMaterial);
				itm.dispose();
				itm = null;
			}
			partList.splice(0, partList.length);
			
			super.dispose();
		}
		
		
	}		
}
