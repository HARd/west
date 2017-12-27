package wins 
{
	import buttons.Button;
	import buttons.IconButton;
	import buttons.ImageButton;
	import buttons.MixedButton;
	import buttons.MixedButton2;
	import buttons.MoneyButton;
	import buttons.UpgradeButton;
	import com.greensock.easing.Back;
	import com.greensock.easing.Cubic;
	import com.greensock.TweenLite;
	import com.greensock.TweenMax;
	import com.greensock.plugins.*;
	import flash.display.GradientType;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;
	import flash.utils.clearInterval;
	import flash.utils.setInterval;
	import flash.utils.setTimeout;
	TweenPlugin.activate([TransformAroundPointPlugin]);
	import core.Load;
	import flash.geom.Point;
	import ui.Hints;
	import ui.UserInterface;
	import wins.elements.ProductionFieldItem;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;

	public class ProductionFieldWindow extends BuildingWindow
	{
		protected var topBg:Bitmap = null;
		protected var bottomBg:Bitmap = null;
		protected var subTitle:TextField = null;
		public var items:Array = new Array();
		protected var partList:Array = new Array();
		protected var outItem:MaterialItem = null;
		protected var currentItem:ProductionFieldItem = null;
		
		protected var cookBttn:Button = null;
		protected var cookingTitle:TextField = null;
		protected var cookingBar:ProgressBar;
		protected var productIcon:Sprite;
		public var itemContainer:Sprite = new Sprite();
		public var crafted:uint;
		public var totalTime:uint;
		public var progressBacking:Bitmap;
		public var craftData:Array = [];
		public var busy:Boolean = false;
		public var dY:int = 30;
		
		protected var accelerateBttn:MoneyButton = null;
		protected var upgradeBttn:UpgradeButton = null;
		protected var boostBttn:MoneyButton = null;
		protected var neddLvlBttn:UpgradeButton = null;
		
		public static var history:int = 0;
		private var _arrCraft:Array = [];
		
		private var priceSpeed:int = 0;
		private var priceBttn:int = 0;
		private var isStart:Boolean = true;
		
		private var endLevelCont:Sprite = new Sprite();
		private var bttn:ImageButton;
		
		public var rotationRightAngle:Number = 28;
		public var rotationLeftAngle:Number = -28;
		public var rotationAngle:Number = -28;
		
		private var canUpgrade:Boolean = false;
		
		private var level:int;
		
		public function ProductionFieldWindow(settings:Object = null)
		{
			settings['width'] = settings.width || 620;
			settings['height'] = settings.height || 616;
			settings['hasArrows'] = true;
			settings['itemsOnPage'] = 6;
			settings['faderAlpha'] = 0.6;
			settings['page'] = history;
			settings['hasButtons'] = false;
			settings['hasAnimations'] = false;
			settings['hasTitle'] = false;
			
			settings['find'] = settings.find || 0;
			
			canUpgrade = settings.canUpgrade || false;

			settings.crafting = [];
			
			if (!settings.find && App.user.quests.opened) {
				for each(var quest:* in App.user.quests.opened) {
					if (quest.id == 2) {
						settings.find = App.data.quests[2].missions[1].target[0];
						break;
					}
				}
			}
			
			initContent(settings);
			
			super(settings);
			
		}
		
		private function findTarget():void {
			if (!settings.find) return;
			
			for (var i:int = 0; i < settings.crafting.length; i++ ) {
				if (settings.crafting[i] == settings.find) {
					if (i >= settings.itemsOnPage) {
						var countScroll:int = i;
						if (countScroll % 2 != 0) {
							countScroll -= 1;
						}
						for (var k:int = 0; k < (countScroll - settings.itemsOnPage); k++ ) {
							makeScrolling(1);
						}
						arrowLeftBttn.mouseEnabled = true;
						arrowLeftBttn.alpha = 1;
						
						settings.find = 0;
					}
					break;
				}else {
					var isFind:Boolean = false;
					for (var key:* in App.data.storage[settings.crafting[i]].outs ) {
						if (key == settings.find) {
							if (i >= settings.itemsOnPage) {
								countScroll = i;
								if (countScroll % 2 != 0) {
									countScroll -= 1;
								}
								for (k = 0; k < (countScroll - settings.itemsOnPage); k++ ) {
									makeScrolling(1);
								}
								arrowLeftBttn.mouseEnabled = true;
								arrowLeftBttn.alpha = 1;
								
								settings.find = 0;
								
								isFind = true;
							}
							break;
						}
					}
					if (isFind)
						break;
				}
				//if (App.data.storage[settings.crafting[i]].out == settings.find) {
					//break;
				//}
			}
		}
		
		private var updtItems:Array = [];
		public function initContent(settings:Object):void {
			var lvlRec:int = 0;
			var craftLevels:int = 0;
			
			updtItems = Stock.notAvailableItems();
			
			if (settings.target.info.hasOwnProperty('devel') ) {
				for each(var obj:* in settings.target.info.devel.open) {
					lvlRec += 1;
					craftLevels++;
					for (var fID:* in obj) {
						if (updtItems.indexOf(fID) != -1) {
							continue;
						}
						_arrCraft.push( { fid:fID, lvl:lvlRec } );
						settings.crafting.push(fID);
					}
				}
			}
			craftData = _arrCraft;
			
			level = settings.target.level - (settings.target.totalLevels - craftLevels);
		}
		
		
		override public function drawBackground():void {
			
		}
		override public function drawExit():void {
				super.drawExit();
			}
		override public function drawBody():void {
			
			topBg = Window.backing(570, 440, 40, "shopBackingSmall");
			topBg.x = (settings.width - topBg.width) / 2;
			topBg.y = 40;
			
			var iconCont:LayerX = new LayerX();
			var iconBuilding:Bitmap = new Bitmap(settings.target.bitmap.bitmapData);
			iconBuilding.smoothing = true;
			
			if (settings.target.scaleX == -1) {
				iconBuilding.scaleX = -1;
				iconBuilding.x += iconBuilding.width;
			}
			
			shine = new Bitmap(Window.textures.productionReadyBacking);
			shine.scaleX = shine.scaleY = 3;
			bodyContainer.addChild(shine);
			shine.x = (settings.width - shine.width) / 2;
			shine.y = (settings.height - shine.height) / 2;
			iconCont.addChild(iconBuilding);
			bodyContainer.addChild(iconCont);
			
			//iconCont.x = (settings.width - iconCont.width) / 2;
			//iconCont.y = (settings.height - iconCont.height) / 2;
			
			iconCont.x = shine.x + (shine.width - iconCont.width)/2;
			iconCont.y = shine.y + (shine.height - iconCont.height)/2;;
			
			iconCont.pluck(10, iconCont.x + iconCont.width/2, iconCont.y + iconCont.height/* / 2 + 300*/);
			
			
			var levelTxt:TextField = Window.drawText(Locale.__e("flash:1400855093548", [settings.target.level]), {
				fontSize:30,
				color:0xffffff,
				textAlign:"center",
				borderColor:0x603508
			});
			levelTxt.width = 120;
			bodyContainer.addChild(levelTxt);
			levelTxt.x = (settings.width - levelTxt.width) / 2 + 3;
			levelTxt.y = 440;
				
			var mymask:Sprite = new Sprite();
			var matrix:Matrix = new Matrix();
			matrix.createGradientBox(1075,400);
			mymask.graphics.lineStyle();
			mymask.graphics.beginGradientFill(GradientType.RADIAL,[0xFFFFFF,0xFFFFFF],[1,0],[235,255],matrix);
			mymask.graphics.drawEllipse(0,0,1075,400);
			mymask.graphics.endFill();
			bodyContainer.addChild(mymask);
			
			mymask.x = (settings.width - mymask.width) / 2;
			mymask.y = (settings.height - mymask.height) / 2 - 150;
			
			bodyContainer.addChild(itemContainer);
			itemContainer.mask = mymask;
			
			itemContainer.cacheAsBitmap = true;
			mymask.cacheAsBitmap = true;
			
			//createItems();
			
			setTimeout(createItems, 400);
			
			paginator.itemsCount = 0;
			
			
			//_arrCraft.sortOn("lvl", Array.NUMERIC);
			craftData = _arrCraft;
			
			paginator.itemsCount = _arrCraft.length; 
			
			paginator.page = settings.page;
			paginator.update();
			
			paginator.y -= 82;
			
			
			//contentChange();
			var isBttn:Boolean = false;
			for each(var _sid:* in settings.target.info.devel.open[settings.target.level + 1]) {
				if (updtItems.indexOf(_sid) == -1) {
					isBttn = true;
					break;
				}
			}
			
			if (isBttn && settings.target.info.devel.req[settings.target.level + 1].l <= App.user.level) {
				drawButton();
			}else if (isBttn)
			
				//if (canUpgrade)
					drawButton();
				//else
					//drawNeddLvlBttn();
				
			if (settings.target.level >= settings.target.totalLevels || !isBttn) {
				drawForMaxLevel();
			}
			
			//if (settings.target.level >= settings.target.totalLevels) {
				//drawForMaxLevel();
			//}
			//else if (settings.target.info.devel.req[settings.target.level + 1].l <= App.user.level) {
				//drawButton();
			//}else
				//drawNeddLvlBttn();
			
			showProgressBar();
		}
		
		private function drawForMaxLevel():void
		{			
			var doingNothing:TextField = Window.drawText(Locale.__e("flash:1393581854554"), {
				fontSize:30,
				color:0xffffff,
				textAlign:"center",
				borderColor:0x2b3b64
			});
			//endLevelCont.addChild(doingNothing);
			
			doingNothing.width = 330;
			doingNothing.height = doingNothing.textHeight;
			doingNothing.x = (settings.width - doingNothing.width) / 2;
			doingNothing.y = settings.height - doingNothing.textHeight - 86;
			
			bodyContainer.addChild(endLevelCont);
		}
		
		private function drawButton():void 
		{
			upgradeBttn = new UpgradeButton(UpgradeButton.TYPE_ON,{
				caption: Locale.__e("flash:1396963489306"),
				width:236,
				height:55,
				icon:Window.textures.upgradeArrow,
				fontBorderColor:0x002932,
				countText:"",
				fontSize:28,
				iconScale:0.95,
				radius:30,
				textAlign:'left',
				autoSize:'left',
				widthButton:230
			});
			//upgradeBttn.textLabel.x += 18;
			//upgradeBttn.coinsIcon.x += 18;
			
			
			bodyContainer.addChild(upgradeBttn);
			
			upgradeBttn.x = (settings.width - upgradeBttn.width)/2 + 4;
			upgradeBttn.y = topBg.y + topBg.height - 10;
			
			upgradeBttn.addEventListener(MouseEvent.CLICK, onUpgradeEvent);
			
			if (settings.target.helpTarget == settings.target.sid)
				upgradeBttn.showGlowing();
		}
		
		private function drawNeddLvlBttn():void 
		{
			neddLvlBttn = new UpgradeButton(UpgradeButton.TYPE_OFF,{
				caption: Locale.__e("flash:1393579961766"),
				width:236,
				height:55,
				icon:Window.textures.star,
				countText:String(settings.target.info.devel.req[settings.target.level + 1].l),
				fontSize:24,
				iconScale:0.95,
				radius:20,
				bgColor:[0xe4e4e4, 0x9f9f9f],
				bevelColor:[0xfdfdfd, 0x777777],
				fontColor:0xffffff,
				fontBorderColor:0x575757,
				fontCountColor:0xffffff,
				fontCountBorder:0x575757,
				fontCountSize:24,
				fontBorderCountSize:4
			})
			
			bodyContainer.addChild(neddLvlBttn);
			neddLvlBttn.x = (settings.width - neddLvlBttn.width)/2;
			neddLvlBttn.y = settings.height - neddLvlBttn.height - 64;
		}
		
		private function onUpgradeEvent(e:MouseEvent):void 
		{
			new ConstructWindow( {
				title:settings.target.info.title,
				upgTime:settings.upgTime,
				request:settings.target.info.devel.obj[settings.target.level + 1],
				target:settings.target,
				win:this,
				onUpgrade:onUpgradeAction,
				hasDescription:true
			}).show();
		}
		
		private function onUpgradeAction(obj:Object = null, count:int = 0):void
		{
			settings.target.upgradeEvent(settings.target.info.devel.obj[settings.target.level + 1],count);
			close();
		}
		
		private function progressVisible(value:Boolean):void
		{
			progressBacking.visible = value;
			cookingTitle.visible = value;
			cookingBar.visible = value;
		}
		
		public var bitmapIcon:Bitmap = null;
		public var sprTip:LayerX = new LayerX();
		private var preloader:Preloader = new Preloader();
		public function showProgressBar():void
		{
			progressBacking = Window.backingShort(340, "prograssBarBacking3");
			progressBacking.x = (settings.width - progressBacking.width) / 2 - 5;
			progressBacking.y = topBg.y + topBg.height + 5+15;
			bodyContainer.addChild(progressBacking);
			
			//Создаем пустой прогресс бар
			cookingTitle = Window.drawText(Locale.__e("flash:1382952380238"), {
				fontSize:24,
				color:0xfbf4e4,
				textAlign:"center",
				borderColor:0x855729
			});
			//bodyContainer.addChild(cookingTitle);
			
			cookingTitle.width = 330;
			cookingTitle.height = cookingTitle.textHeight;
			cookingTitle.x = (settings.width - 330) / 2 - 10;
			cookingTitle.y = topBg.y + topBg.height + dY - 35;
			
			var barWidth:int = 330;
			cookingBar = new ProgressBar({win:this, width:barWidth});
			bodyContainer.addChild(cookingBar);
			cookingBar.x = (settings.width - barWidth)/2 - 2 - 10;
			cookingBar.y = progressBacking.y + (progressBacking.height - cookingBar.height) / 2 - 10;
			
			if (settings.target.crafted > App.time) {
				startProgress(settings.target.fID);
			}
			else {
				progressVisible(false);
			}
			
		}
		override public function drawFader():void {
			if (fader==null && settings.hasFader) {
				fader = new Sprite();
					
				fader.graphics.beginFill(settings.faderColor);
				fader.graphics.drawRect(0, 0, App.self.stage.stageWidth, App.self.stage.stageHeight);
				fader.graphics.endFill();
				
				addChildAt(fader, 0);
					
				fader.alpha = 0;
				
				var finishX:Number = (App.self.stage.stageWidth - settings.width) / 2;
				var finishY:Number = (App.self.stage.stageHeight - settings.height) / 2;
					
				TweenLite.to(fader, settings.faderTime, { alpha:settings.faderAlpha } );
			}
		}
		override public function show():void
		{
			super.show();
			//App.map.focusedOn(settings.target, false, function():void 
			//{
				//settings.target.pluck(10, settings.target.x, settings.target.y - settings.target.bitmap.x);
			//}, true, 1, true, 0.5);
		}
		public function onPreviewComplete(obj:Object):void
		{
			if(bodyContainer.contains(preloader)){
				bodyContainer.removeChild(preloader);
			}
			bitmapIcon.bitmapData = obj.bitmapData;
			bitmapIcon.smoothing = true;
			if(bitmapIcon.height > 50)
				bitmapIcon.scaleX = bitmapIcon.scaleY = 0.8;
			sprTip.x = 40;
			sprTip.y = topBg.y + topBg.height + 4;
		}
		
		
		public function updateNumItems():void
		{
			numItems.text = 'x' + String(settings.target.craftRow.length);
		}
		
		private var numItems:TextField;
		public function startProgress(fID:uint):void
		{
			totalTime = 100;// App.data.crafting[fID].time;
			if (isStart) crafted = settings.target.crafted;
			else crafted = App.time + totalTime;
			
			endLevelCont.visible = false;
			if(upgradeBttn)upgradeBttn.visible = false;
			
			boostBttn = new MoneyButton({
					caption		:Locale.__e('flash:1382952380104'),
					width		:102,
					height		:63,	
					fontSize	:24,
					countText	:15,
					multiline	:true,
					radius:20,
					iconScale:0.67,
					fontBorderColor:0x4d7d0e,
					fontCountBorder:0x4d7d0e,
					notChangePos:true
			});
			boostBttn.x = settings.width - boostBttn.width - 30;
			boostBttn.y = topBg.y + topBg.height + 10;
			
			boostBttn.textLabel.y -= 12;
			boostBttn.textLabel.x = 0;
			
			boostBttn.coinsIcon.y += 12;
			boostBttn.coinsIcon.x = 2;
			
			boostBttn.countLabel.y += 12;
			boostBttn.countLabel.x = boostBttn.coinsIcon.x + boostBttn.coinsIcon.width + 6;
			
			var txtWidth:int = boostBttn.textLabel.width;
			if ((boostBttn.coinsIcon.width + 6 + boostBttn.countLabel.width) > txtWidth) {
				txtWidth = boostBttn.coinsIcon.width + 6 + boostBttn.countLabel.width;
				boostBttn.textLabel.x = (txtWidth - boostBttn.textLabel.width) / 2;
			}
			
			boostBttn.topLayer.x = (boostBttn.settings.width - txtWidth)/2;
			
			priceSpeed = Math.ceil((crafted - App.time) / App.data.options['SpeedUpPrice']);
			boostBttn.count = String(priceSpeed);
			
			boostBttn.addEventListener(MouseEvent.CLICK, onAccelerateEvent);
			
			cookingTitle.text = Locale.__e("flash:1382952380105");
				
			bodyContainer.addChild(boostBttn);
			
			productIcon = new Sprite();
			var bitmap:Bitmap = new Bitmap();
			productIcon.addChild(bitmap);
			bodyContainer.addChild(productIcon);
			productIcon.x = 74;
			productIcon.y = 470+30;
			
			if(fID != 0){
				Load.loading(
					Config.getIcon(App.data.storage[fID].type, App.data.storage[fID].preview),
					function(data:Bitmap):void{
						bitmap.bitmapData = data.bitmapData;
						bitmap.scaleX = bitmap.scaleY = 0.7;
						bitmap.smoothing = true;
						bitmap.x = -bitmap.width / 2 + 10;
						bitmap.y = -16;
					}
				);
			}
			
			progress();
			cookingBar.start();
			
			
			
			App.self.setOnTimer(progress);
			busy = true;
			
			
			if(neddLvlBttn) neddLvlBttn.visible = false;
		}
		
		public function onAccelerateEvent(e:MouseEvent):void {
			settings.target.onBoostEvent(priceBttn);
			
			Hints.minus(Stock.FANT, priceBttn, Window.localToGlobal(boostBttn), false, this);
			
			close();
		}
		
		
		private var itemWidth:int = 170;
		private var itemHeight:int = 206;
		
		private var closeInfoBack:Bitmap;
		
		public function drawClosedWindow():void
		{
			var winSettings:Object = {
						text				:Locale.__e('flash:1405581567143'),
						buttonText			:Locale.__e('flash:1382952380298'),
						image				:Window.textures.errorStorage,
						imageX				: -78,
						imageY				: -76,
						textPaddingY        : -18,
						textPaddingX        : -10,
						hasExit             :true,
						faderAsClose        :true,
						faderClickable      :true,
						closeAfterOk        :true,
						isPopup             :true,
						bttnPaddingY        :25
					};
			
			new ErrorWindow(winSettings).show();
		}
		
		
		
		private var indItem:int = 0;
			
		public function createItems():void 
		{
			var angle:int;
			var time:Number = 0.4;
			
			for (var i:int = 0; i < settings.itemsOnPage;  i++)
			{
				var item:ProductionFieldItem = new ProductionFieldItem(this, { height:itemHeight, width:itemWidth, crafting:_arrCraft[i], craftData:_arrCraft, level:level } );
				
				indItem++;
				
				var inner:Sprite = new Sprite();
				var cont:Sprite = new Sprite();
				
				inner.addChild(item);
				item.x = - item.width / 2;
				item.y = - item.height / 2;
				
				inner.rotation = -setPosScrollItems(i + 1);
				
				inner.x = 230;
				cont.addChild(inner);
				
				cont.rotation = 180;
				
				itemContainer.addChild(cont);
				items.push(item);
				
				//isScrolling = true;
				
				if (i == settings.itemsOnPage-1)
					setTimeout(function():void{isScrolling = false}, time);
				
				var indRot:int = i;
				TweenLite.to(cont, time, { rotation:setPosScrollItems(i + 1), alpha:1, ease:Back.easeOut } );
				
				time += 0.05;
				
				angle = 90 - settings.crafting.length * 15;
				if (settings.crafting.length <= 5) 
					inner.rotation -= angle;
			}
			
			itemContainer.x = settings.width / 2;
			itemContainer.y = settings.height / 2;
			
			angle = 90 - settings.crafting.length * 15;
			if (settings.crafting.length <= 5) 
				TweenLite.to(itemContainer, time, { rotation:angle, alpha:1, ease:Back.easeOut } );			
			
			if (indItem >= _arrCraft.length)
			{
				arrowRigthBttn.mouseEnabled = false;
				arrowRigthBttn.alpha = 0.5;
			}
			
			contentChange();
			
			findTarget();
		}
		
		private var arrowLeftBttn:ImageButton;
		private var arrowRigthBttn:ImageButton;
		override public function drawArrows():void {
			
			
			arrowLeftBttn = new ImageButton(Window.textures.menuArrow, {scaleX:-1,scaleY:1});
			arrowRigthBttn = new ImageButton(Window.textures.menuArrow, {scaleX:-1,scaleY:1});
			bodyContainer.addChild(arrowLeftBttn);
			bodyContainer.addChild(arrowRigthBttn);
			
			arrowLeftBttn.x =  60;
			arrowLeftBttn.y = 280;
			arrowLeftBttn.rotation = 50;
			
			arrowRigthBttn.x = 530;
			arrowRigthBttn.y = 305 - 10;
			arrowRigthBttn.rotation = 10;
			
			arrowLeftBttn.addEventListener(MouseEvent.CLICK, onLeftArrowClick);
			arrowRigthBttn.addEventListener(MouseEvent.CLICK, onRightArrowClick);
			
			arrowLeftBttn.mouseEnabled = false;
			arrowLeftBttn.alpha = 0.5;
			
			if (_arrCraft.length <= 6) 
			{
				arrowRigthBttn.mouseEnabled = false;
				arrowRigthBttn.alpha = 0.5;
			}
			else 
			{
				arrowRigthBttn.mouseEnabled = true;
				arrowRigthBttn.alpha = 1;
			}
		}
		
		private var isScrolling:Boolean = false;
		private var countScrollItems:int = 2;
		private var scrollingTime:Number = 0.2;
		private var scrollingAngle:int = 30;
		
		private var arrRemove:Array = [];
		
		private function addScrollItems(type:int):int
		{
			var countItems:int = 0;
			var removeInd:int = 0;
			var newInd:int;
			
			if (indItem < 0)
				indItem = 0;
			else if (indItem >= _arrCraft.length)
				indItem = _arrCraft.length;
			
			switch(type) {
				case 1:
					newInd = indItem;
					removeInd = 0;
				break;
				case 2:
					newInd = indItem - settings.itemsOnPage - 1;
					removeInd = items.length - 1;
				break;
			}
			
			var stopAdd:Boolean = false;
			
			arrRemove = [];
			
			for (var i:int = 0; i < countScrollItems; i++ ) {
				
				if (stopAdd)
					break;
				
				countItems++;
					
				var inner:Sprite = new Sprite();
				var cont:Sprite = new Sprite();
				
				var item:ProductionFieldItem = new ProductionFieldItem(this, { height:itemHeight, width:itemWidth, crafting:_arrCraft[newInd], craftData:_arrCraft, level:level } );
				
				item.canRotate = false;
				inner.addChild(item);
				item.x = - item.width / 2;
				item.y = - item.height / 2;
				
				var koef:int = -1;
				if (type == 1)
					koef = 1;
				inner.rotation = -setPosScrollItems(newInd + 1) - itemContainer.rotation + scrollingAngle * countScrollItems * koef;
				
				inner.x = 230;
				cont.addChild(inner);
				
			
				itemContainer.addChild(cont);
				
				cont.rotation = setPosScrollItems(newInd + 1);
				
				var isHelp:Boolean = false;
				if (settings.find == _arrCraft[newInd].fid) {
					isHelp = true;
				}else{
					for (var key:* in App.data.storage[_arrCraft[newInd].fid].outs) {
						if (key == settings.find) {
							isHelp = true;
							break;
						}
					}
				}
				
				//var isHelp:Boolean = false;
				//if (settings.find == _arrCraft[newInd].fid)
					//isHelp = true;
				
				item.change(_arrCraft[newInd].fid, _arrCraft[newInd].lvl, isHelp);
				item.visible = true;
				
				arrRemove.push(items[removeInd]);
				items.splice(removeInd,1);
				
				switch(type) {
					case 1:
						indItem ++;
						if (indItem >= _arrCraft.length) {
							stopAdd = true;
							
							arrowRigthBttn.mouseEnabled = false;
							arrowRigthBttn.alpha = 0.5;
							inner.rotation = -setPosScrollItems(newInd + 1) - itemContainer.rotation + scrollingAngle * countItems * koef;
						}
						newInd++;
						items.push(item);
					break;
					case 2:
						indItem --;
						if (indItem - settings.itemsOnPage - 1 < 0) {
							stopAdd = true;
							
							arrowLeftBttn.mouseEnabled = false;
							arrowLeftBttn.alpha = 0.5;
							inner.rotation = -setPosScrollItems(newInd + 1) - itemContainer.rotation + scrollingAngle * countItems * koef;
						}
						newInd--;
						items.unshift(item);
					break;
				}
			}
			return countItems;
		}
		
		private function setPosScrollItems(ind:int):Number
		{
			var countItems:int = int(settings.itemsOnPage) * 2;
			var angle:Number = ind * 360 / countItems + 165;//152//165;
			
			if (angle > 360)
				angle = angle - 360;
			
			return angle;
		}
		
		private function onRightArrowClick(e:MouseEvent):void 
		{		
			if (isScrolling || indItem >= _arrCraft.length || arrowRigthBttn.mode == Button.DISABLED)
				return;
				
			arrowLeftBttn.mouseEnabled = true;
			arrowLeftBttn.alpha = 1;
			makeScrolling(1);
		}
		
		private function onLeftArrowClick(e:MouseEvent):void 
		{
			if (isScrolling || (indItem - settings.itemsOnPage - 1) < 0 || arrowLeftBttn.mode == Button.DISABLED)
				return;
				
			arrowRigthBttn.mouseEnabled = true;
			arrowRigthBttn.alpha = 1;
			makeScrolling(2);
		}
		
		private function makeScrolling(type:int):void
		{
			if (tween) {
				onTweenComplete();
				itemContainer.rotation = targetRotation;
			}
			
			var koef:int = 1;
			if (type == 1)
				koef = -1;
			
			//isScrolling = true;
			
			var itemsToScroll:int = addScrollItems(type);
			
			var angle:int = scrollingAngle * itemsToScroll * koef;
			rotationAngle = itemContainer.rotation + angle;
			
			var item:ProductionFieldItem = null;
			
			for (var i:int = 0; i < items.length; i++ ) {
				
				item = items[i];
				
				if (item.canRotate) {
					//item.setAngle(convertAngle(item.parent.rotation - angle), scrollingTime * itemsToScroll);
					var _angle:int = convertAngle(item.parent.rotation - angle);
					item.rotateAngle = _angle;
					item.rotateTween = TweenLite.to(item.parent, scrollingTime * itemsToScroll, { rotation:_angle } );
				}else {
					item.canRotate = true;
				}
			}
			item = null;
			
			for (i = 0; i < arrRemove.length; i++ ) {
				
				item = arrRemove[i];
				
				item.parent.rotation = convertAngle(item.parent.rotation - angle);
			}
			
			targetRotation = rotationAngle;
			tween = TweenLite.to(itemContainer, scrollingTime * itemsToScroll, { rotation:rotationAngle, onComplete:onTweenComplete } );
		}
		
		private function onTweenComplete():void {
			tween.kill();
			tween = null;
				
			isScrolling = false;
			for (var i:int = 0; i < arrRemove.length; i++ ) {
				arrRemove[i].parent.removeChild(arrRemove[i]);
				arrRemove[i].dispose();
			}
			
			for (i = 0; i < items.length; i++) {
				items[i].removeAngleTween();
			}
			arrRemove = [];
		}
		
		private var tween:TweenLite; 
		private var targetRotation:Number;
		private var upArrow:Bitmap;
		private var shine:Bitmap;
		
		private function convertAngle(value:int):int
		{
			var angle:int = value;
			
			if (angle > 360)
				angle = angle - 360;
			else if (angle < 0)
				angle = angle + 360;
				
			return angle;
		}
		
		override public function contentChange():void {
			
			for (var i:int = 0; i < items.length; i++)
			{
				items[i].visible = false;
			}
			
			var itemNum:int = 0
			
			for (i = paginator.startCount; i < paginator.finishCount; i++)
			{
				var isHelp:Boolean = false;
				if (settings.find == _arrCraft[i].fid) {
					isHelp = true;
				}else{
					for (var key:* in App.data.storage[_arrCraft[i].fid].outs) {
						if (key == settings.find) {
							isHelp = true;
							break;
						}
					}
				}
				//if (settings.find == _arrCraft[i].fid)
					//isHelp = true;
				items[itemNum].change(_arrCraft[i].fid, _arrCraft[i].lvl, isHelp);
				items[itemNum].visible = true;
				itemNum++;
			}
			
			//settings.find = 0;
			settings.page = paginator.page;
			history = settings.page;
		}
		
		public function onCookEvent(fID:uint):void {
			
			isStart = false;
			
			if (!settings.target.crafting) {
				settings.onCraftAction(fID);
				startProgress(fID);
				contentChange();
				App.ui.flashGlowing(progressBacking, 0xFFFF00, null, false);
				SoundsManager.instance.playSFX('production');	
				progressVisible(true);
				if (upgradeBttn) upgradeBttn.visible = false;
			}else {
				settings.onCraftAction(fID);
				updateNumItems();
			}
		}
		
		protected function progress():void
		{
			var leftTime:int = crafted - App.time;
			if (leftTime <= 0) 
			{
				cookingBar.time = 0;
				cookingBar.progress = 1;
				App.self.setOffTimer(progress);
				close();
				return;
			}	
			cookingBar.progress = (totalTime - leftTime) / totalTime;
			cookingBar.time		= leftTime;
			
			priceSpeed = Math.ceil((crafted - App.time) / App.data.options['SpeedUpPrice']);
			if (boostBttn && priceBttn != priceSpeed && priceSpeed != 0) {
				priceBttn = priceSpeed;
				boostBttn.count = String(priceSpeed);
			}
			
			dispatchEvent(new WindowEvent("onProgress"));
		}
		
		
		override public function dispose():void {
			
			settings.target.visible = true;
			
			if (_arrCraft) {
				_arrCraft.splice(0, _arrCraft.length);
			}
			_arrCraft = null;
			bodyContainer.removeChild(shine);
			for (var i:int = 0; i < items.length; i++ ) {
				items[i].dispose();
			}
			
			if(arrowLeftBttn){
				arrowLeftBttn.removeEventListener(MouseEvent.CLICK, onLeftArrowClick);
				arrowLeftBttn.dispose();
				arrowLeftBttn = null;
			}
			if(arrowRigthBttn){
				arrowRigthBttn.removeEventListener(MouseEvent.CLICK, onRightArrowClick);
				arrowRigthBttn.dispose();
				arrowRigthBttn = null;
			}
			
			App.self.setOffTimer(progress);
			super.dispose();
		}
		
		public function glowQuest():void {
			var qID:* = App.user.quests.currentQID;
			var mID:* = App.user.quests.currentMID;
			var targets:* = App.data.quests[qID].missions[mID].target;
			
			for each(var sID:* in targets) {
				for each(var item:ProductionFieldItem in items) {
					if (item.sID == sID) {
						item.select();
					}
				}
			}
		}
		
		public override function close(e:MouseEvent = null):void {
			super.close();
			if (App.tutorial)
				App.tutorial.hide();
			
		}
	}
}