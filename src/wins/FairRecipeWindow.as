package wins 
{
	import buttons.Button;
	import buttons.ImageButton;
	import buttons.MoneyButton;
	import buttons.UpgradeButton;
	import core.Load;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.text.TextField;
	import ui.Hints;
	import ui.UserInterface;
	import units.Techno;
	import wins.elements.OutItem;
	public class FairRecipeWindow extends Window
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
		
		private var _backLine:Bitmap;
		private var _background:Bitmap;
		private var _equality:Bitmap;
		public var icon:Bitmap;
		
		public function FairRecipeWindow(settings:Object = null):void
		{
			if (settings == null) {
				settings = new Object();
			}
			
			settings['sID'] = settings.sID || 0;
			
			
			settings["width"] = 670;
			settings["height"] = 390;
			settings["popup"] = true;
			settings["fontSize"] = 44;
			settings["callback"] = settings["callback"] || null;
			settings["dontCheckTechno"] = settings["dontCheckTechno"] || false;
			settings["description"] = Locale.__e('flash:1416993045091');
			settings["hasPaginator"] = false;
			//settings['recipeBttnName'] = settings.recipeBttnName || Locale.__e("flash:1382952380036");
			
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

			createItems(settings['requires']);
		}
		
		override public function drawBackground():void {
			//var background:Bitmap = backing(settings.width, settings.height, 30, "windowBacking");
			//layer.addChild(background);
		}
		
		override public function drawExit():void {
			super.drawExit();
			
			exit.x = settings.width - exit.width + 8;
			exit.y = -8;
		}
		
		override public function drawTitle():void {
							
				
			titleLabel = titleText( {
				title				: settings.title,
				color				: settings.fontColor,
				multiline			: settings.multiline,			
				fontSize			: settings.fontSize,				
				textLeading	 		: settings.textLeading,				
				borderColor 		: settings.fontBorderColor,			
				borderSize 			: settings.fontBorderSize,	
				
				shadowBorderColor	: settings.shadowBorderColor || settings.fontColor,
				width				: settings.width - 340,
				textAlign			: 'center',
				sharpness 			: 50,
				thickness			: 50,
				border				: true
			})
			
			titleLabel.x = (settings.width - titleLabel.width) * .5;
			titleLabel.y = -28;
			bottomContainer.addChild(titleLabel);
			
		}
		
		private var descText:TextField
		private function drawDescription():void {
			descText = drawText(settings.description, {
				multiline:		true,
				fontSize:		24,
				color:			0xFFFFFF,
				borderColor:	0x7e5619,
				textAlign:		'left'
			});
			descText.width = descText.textWidth + 5;
			descText.wordWrap = true;
			bodyContainer.addChild(descText);
			descText.x = (settings.width - descText.width) / 2;
			descText.y = 14;
		}
		
		private var backgroundWidth:int;
		private var _minWidth:int = 360;
		override public function drawBody():void {
			
			
			//icon = new Bitmap(getTargetBitmapData, 'auto', true);
			//icon.width = 160;
			//icon.scaleY = icon.scaleX;
			//icon.x = (settings.width - icon.width) / 2;
			//icon.y = -icon.height / 2 - 10;
			//bodyContainer.addChild(icon);
			
			createItems(settings['requires']);
			
			//
			container.x = padding;
			
			backgroundWidth = partList.length * (partList[0].background.width + 5) - 5;
			
			if (backgroundWidth < _minWidth)backgroundWidth = _minWidth;
			//outItem.x = padding + backgroundWidth + 6;
			//outItem.y = 26;
			//container.x = padding + (backgroundWidth - container.width) / 2;
			//_equality.x = padding + backgroundWidth - _equality.width / 2 + 2;
			//_equality.y += 39;
		
			_background = Window.backing(backgroundWidth, 250, 10, "dialogueBacking");
			bodyContainer.addChildAt(_background, 0);
			
			_background.x = padding;
			_background.y = 50;
			
			_backLine = Window.backing(_background.width - 36, 48, 10, "recipte_line");
			//bodyContainer.addChildAt(_backLine, 1);
			_backLine.x = _background.x + 18;
			_backLine.y = _background.y + 12;
			
			settings.width = padding + backgroundWidth + padding;
			
			var descrBg:Shape = new Shape();
			descrBg.graphics.beginFill(0xe2c395);
			descrBg.graphics.drawRoundRect(0, 0, settings.width - 200, 200, 30, 30);
			descrBg.graphics.endFill();
			
			bodyContainer.addChildAt(descrBg, 0);
			descrBg.x = (settings.width - descrBg.width) / 2;
			descrBg.y = 0;	
			
			var background:Bitmap =  Window.backing(settings.width, settings.height, 30, "questBacking");
			layer.addChild(background);
			
			exit.x = settings.width - exit.width + 12;
			//titleLabel.x = (settings.width - titleLabel.width) * .5;
			titleLabel.x = settings.width / 2 - titleLabel.width/2;
			//drawRequirements(settings['requires']);
			
			container.y = 55;
			
			
			//arrowLeft = new ImageButton(Window.textures.arrow, {scaleX:-0.7,scaleY:0.7});
			//arrowRight = new ImageButton(Window.textures.arrow, {scaleX:0.7,scaleY:0.7});
			
			//arrowLeft.addEventListener(MouseEvent.MOUSE_DOWN, onPrev);
			//arrowRight.addEventListener(MouseEvent.MOUSE_DOWN, onNext);
			
			if(prev > 0){
				bodyContainer.addChild(arrowLeft);
				//arrowLeft.x = settings.width * 0.2;
				//arrowLeft.x = settings.width / 2 - 200;
				//arrowLeft.y = -24;
			}
			
			if(next > 0){
				bodyContainer.addChild(arrowRight);
				//arrowRight.x = settings.width * 0.8 - 10;
				//arrowRight.x = settings.width/2 + 200 - 20;
				//arrowRight.y = -24;
			}
			
			
			drawMirrowObjs('diamondsTop', settings.width / 2 - settings.titleWidth / 2 - 5, settings.width / 2 + settings.titleWidth / 2 + 5, -46, true, true);
			drawMirrowObjs('storageWoodenDec', -5, settings.width + 5, 45, false, false, false, 1, -1);
			drawMirrowObjs('storageWoodenDec', -5, settings.width + 5, settings.height - 95);
			
			drawDescription();
			
			var separator:Bitmap = Window.backingShort(630, 'divider');
			separator.x = (settings.width - separator.width) / 2;
			separator.y = settings.height - 70;
			separator.alpha = 0.5;
			bodyContainer.addChild(separator);
			
			drawButton();
			onUpdateOutMaterial();
		}
		
		public function get getTargetBitmapData():BitmapData {
			var bmd:BitmapData;
			var bounds:Object = settings.target.getBounds(settings.target);
			bmd = new BitmapData(bounds.width, bounds.height, true, 0);
			bmd.draw(settings.target, new Matrix(1, 0, 0, 1, -bounds.top, -bounds.left));
			return bmd;
		}
		
		private var upgradeBttn:UpgradeButton
		private function drawButton():void 
		{
			upgradeBttn = new UpgradeButton(UpgradeButton.TYPE_ON,{
				caption: Locale.__e("flash:1416990243382"),
				width:236,
				height:55,
				fontBorderColor:0x002932,
				fontSize:28,
				radius:30,
				textAlign:'left',
				autoSize:'left',
				widthButton:230,
				countText:''
			});
			bodyContainer.addChild(upgradeBttn);
			
			upgradeBttn.x = (settings.width - upgradeBttn.width)/2 + 4;
			upgradeBttn.y = settings.height - 80;
			
			upgradeBttn.addEventListener(MouseEvent.CLICK, onUpgradeEvent);
		}
		
		private function onUpgradeEvent(e:MouseEvent):void {
			if (e.currentTarget.mode == Button.DISABLED) 
				return;
				
			e.currentTarget.state = Button.DISABLED;
			settings.openAction(settings.sID);
			close();
		}
		
		//private function onPrev(e:MouseEvent):void {
			//close();
			//settings.prodItem.recWin = new RecipeWindow( {
				//title:Locale.__e("flash:1382952380065")+':',
				//fID:prev,
				//onCook:settings.win.onCookEvent,
				//busy:settings.win.busy,
				//win:settings.win,
				//hasDescription:true,
				//prodItem:settings.prodItem
			//});// .show();
			//settings.prodItem.recWin.show();
		//}
		
		//private function onNext(e:MouseEvent):void {
			//close();
			//settings.prodItem.recWin = new RecipeWindow( {
				//title:Locale.__e("flash:1382952380065")+':',
				//fID:next,
				//onCook:settings.win.onCookEvent,
				//busy:settings.win.busy,
				//win:settings.win,
				//hasDescription:true,
				//prodItem:settings.prodItem
			//});// .show();
			//settings.prodItem.recWin.show();
		//}
		
		public var requiresList:RequiresList;
		private function drawRequirements(requirements:Object):void 
		{
			requiresList = new RequiresList(requirements, false, {dontCheckTechno:settings.dontCheckTechno});
			bodyContainer.addChild(requiresList);
			requiresList.x = _backLine.x + (_backLine.width- requiresList.width)/2;
			requiresList.y = 30;
		}
		
		private function createItems(materials:Object):void
		{
			var offsetX:int = 0;
			var offsetY:int = 0;
			var dX:int = 5;
			
			var pluses:Array = [];
			
			var count:int = 0;
			for(var _sID:* in materials) 
			{
				//var inItem:MaterialItem = new MaterialItem({
					//sID:_sID,
					//need:materials[_sID],
					//window:this, 
					//bitmapDY: -10,
					//disableAll:disableAll
				//});
				
				var inItem:MaterialItem = new MaterialItem({
					sID:_sID,
					need:materials[_sID],
					window:this, 
					type:MaterialItem.IN,
					color:0x5a291c,
					borderColor:0xfaf9ec,
					bitmapDY: -10,
					bgItemY:38,
					bgItemX:20
				});
				
				inItem.checkStatus();
				inItem.addEventListener(WindowEvent.ON_CONTENT_UPDATE, onUpdateOutMaterial)
				
				partList.push(inItem);
				
				container.addChild(inItem);
				inItem.x = offsetX;
				inItem.y = offsetY + 18;
				count++;
				
				offsetX += inItem.background.width + dX;
				inItem.background.visible = false;
				
				//var plus:Bitmap = new Bitmap(Window.textures.plus);
				//container.addChild(plus);
				//pluses.push(plus)
				//plus.x = inItem.x - plus.width / 2 - 2;
				//plus.y = inItem.background.height / 2 - plus.height/2 + 36;
			}
			
			//var firstPlus:Bitmap = pluses.shift();
			//container.removeChild(firstPlus);
			
			//outItem = new OutItem(onCook, {formula:formula, recipeBttnName:"dd", target:settings.win.settings.target});
			//outItem.change(formula);
			//bodyContainer.addChild(outItem);//container.addChild(outItem);
			//
			//outItem.x = offsetX;
			//outItem.y = offsetY - 16;
			//
			//_equality = new Bitmap(Window.textures.equals);
			//bodyContainer.addChild(_equality);//container.addChild(_equality);
			//_equality.x = outItem.x - _equality.width / 2 - 2;
			//_equality.y = outItem.background.height / 2 - _equality.height/2 + 6;
			
			bodyContainer.addChild(container);
			
			onUpdateOutMaterial();
		}
		
		private function disableAll(value:Boolean = true):void 
		{
			for (var i:int = 0; i < partList.length; i++ ) {
				partList[i].disableBtt(value);
			}
			//if (outItem) {
				//if(value)
					//outItem.recipeBttn.state = Button.DISABLED;
				//else
					//outItem.recipeBttn.state = Button.NORMAL;
			//}
		}
		public function onUpdateOutMaterial(e:WindowEvent = null):void {
			
			if (!upgradeBttn) return;
			
			var outState:int = MaterialItem.READY;
			for each(var item:* in partList) {
				if(item.status != MaterialItem.READY){
					outState = item.status;
				}
			}
			
			if (outState == MaterialItem.READY)
				upgradeBttn.state = Button.NORMAL;
			else
				upgradeBttn.state = Button.DISABLED;
			
			
			return;
			//var outState:int = MaterialItem.READY;
			//for each(var item:* in partList) {
				//if(item.status != MaterialItem.READY){
					//outState = item.status;
				//}
			//}
			//
			//if (requiresList && !requiresList.checkOnComplete())
				//outState = MaterialItem.UNREADY;
			//
			//if (outState == MaterialItem.UNREADY) 
				//outItem.recipeBttn.state = Button.DISABLED;
			//else if (outState != MaterialItem.UNREADY)
				//outItem.recipeBttn.state = Button.NORMAL;
			//
			//var openedSlots:int;
			//openedSlots = settings.win.settings.target.openedSlots;
			//if (settings.win.settings.target.queue.length >= openedSlots+1)
				//outItem.recipeBttn.state = Button.DISABLED;
			
			//if (settings.busy && settings.fID != settings.win.settings.target.fID)
				//outItem.recipeBttn.state = Button.DISABLED;
				
			//if (formula.out == Stock.JAM && App.user.stock.count(Stock.JAM) >= App.data.levels[App.user.level].jam)
				//outItem.recipeBttn.state = Button.DISABLED;
				
			//if (formula.out == Stock.JAM){
				//if (App.user.stock.count(Stock.JAM) >= App.data.levels[App.user.level].jam)
					//outItem.jamTick.visible = true;
				//else
					//outItem.jamTick.visible = false;
			//}	
			
		}
		
		private function onCook(e:MouseEvent):void
		{
			// TODO Обьяснять причину 
			//if (settings.busy /*&& (settings.fID != settings.win.settings.target.fID)*/){
				//App.ui.flashGlowing(settings.win.progressBacking, 0xFFFF00);
				//Hints.text(Locale.__e("flash:1382952380255"), Hints.TEXT_RED, new Point(mouseX, mouseY), false, App.self.tipsContainer);
				//return;
			//}
			
			if (e.currentTarget.mode == Button.DISABLED) {
				for (var i:int = 0; i < partList.length; i++ ) {
					partList[i].doPluck();
				}
				requiresList.doPluck();
				return;
			}
			e.currentTarget.state = Button.DISABLED;
			
			close();
			
			settings.onCook(settings.fID);
			
			
			//close();
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
