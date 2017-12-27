package wins 
{
	/**
	 * ...
	 * @author ...
	 */
	import buttons.Button;
	import buttons.MixedButton2;
	import buttons.MoneyButton;
	import buttons.SimpleButton;
	import core.Load;
	import core.Numbers;
	import core.Size;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	import flash.utils.setInterval;
	import ui.Hints;
	import ui.UserInterface;
	import units.Factory;
	import units.Garden;
	import units.Hut;
	import units.Mining;
	import units.Single;
	import units.Storehouse;
	import units.Techno;
	import wins.actions.BanksWindow;
	import wins.elements.BankMenu;
	
	public class ConstructWindow extends Window
	{
		public static const CONSTRUCT:int 	= 1;
		public static const UPGRADE:int 	= 2;
		
		public var item:Object;
		public var bitmap:Bitmap;
		public var title:TextField;
		public var bitmapBack:Bitmap = new Bitmap(null, "auto", true);
		public var dx:int;
		public var dy:int;
		public var bonusList:BonusList;
		public var materialForSearch:Boolean = false;
		public var forSearch:Boolean = false;
		
		private var upgBttn:MixedButton2;
		private var skipBttn:MoneyButton;
		private var buyAllBttn:MoneyButton;
		private var container:Sprite = new Sprite();
		private var backLine:Bitmap;
		private var backField:Bitmap;
		private var resources:Array = [];
		private var prices:Array = [];
		private var partList:Array = [];
		private var smallWindow:Boolean = false;
		private var bgHeight:int;
		private var isEnoughMoney:Boolean = false;
		private var buildingBackImage:Bitmap;
		private var skipPrices:Array = [];
		private var stageLabel:TextField;
		private var buyPrice:uint = 0;
		private var itemsForDebit:Object = {};
		
		public function ConstructWindow(settings:Object = null):void
		{
			if (settings == null) {
				settings = new Object();
			}
			settings['mode'] = settings.mode || ConstructWindow.CONSTRUCT;
			settings['sID'] = settings.sID || 0;
			settings["width"] = 670;
			settings["height"] = 465;
			settings["fontSize"] = 44;
			settings["callback"] = settings["callback"] || null;
			settings["hasPaginator"] = false;
			settings['popup'] = true;
			settings['background'] = "storageBackingMain";
			settings['onUpgrade'] = settings.onUpgrade;
			settings['upgTime'] = settings.upgTime || 0;
			settings['bttnTxt'] = settings.bttnTxt || Locale.__e('flash:1393580216438');
			settings['noSkip'] = settings['noSkip'] || false;
			settings['notChecks'] = settings.notChecks || false;
			settings['shadowColor'] = 0x513f35;
			settings['shadowSize'] = 4;
			settings['target'] = settings.target;
			
			if (settings.target is Storehouse || settings.target is Mining/* || settings.target is Storehouse || settings.target is Storehouse*/)
				settings['notChecks'] = true;
			
			if (settings.target.level == 0)
				settings['bttnTxt'] = Locale.__e('flash:1382952379806');
				
			for (var sID:* in settings.request) {
				switch(sID) {
					case Stock.FANTASY:
						prices.push({sid:sID, count:settings.request[sID]});
						break;
					case Stock.COINS:
						prices.push({sid:sID, count:settings.request[sID]});
						break;
					//case Stock.FANT:
						//prices.push({sid:sID, count:settings.request[sID]});
						//break;
					case Techno.TECHNO:
						prices.push({sid:sID, count:settings.request[sID]});
						break;
					default:
						resources.push(sID);
						break
				}
			}
			if (resources.length == 4) settings['width'] = 770;
			super(settings);
				
			//skipPrice = (settings.target.info.hasOwnProperty('devel')) ? settings.target.info.devel.skip[settings.target.level + 1] : 0;
			
			if (resources.length == 0) smallWindow = true;
			
			prices.sortOn('sid', Array.NUMERIC);
			
			App.self.addEventListener(AppEvent.ON_CHANGE_STOCK, onStockChange);
			App.self.addEventListener(AppEvent.ON_AFTER_PACK, onStockChange);
			App.self.addEventListener(AppEvent.ON_TECHNO_CHANGE, onStockChange);
			
			if (App.user.quests.tutorial || (App.user.stock.checkAll(settings.require, true) && Quests.helpInQuest(App.user.quests.currentQID))) {
				forSearch = true;
				App.user.quests.currentQID = 0;
			}
			
			checkActions();
			
			//if (App.user.id == "7584561")
			//{
				//settings.target.info.devel.req[settings.target.level + 1].l = 200;
			//}
		}
		
		public static var actionTarget:int;
		private function checkActions():void
		{
			if (World.getBuildingCount(settings.target.sid) > 1)
			{
				actionTarget = settings.target.sid;
				App.user.updateActions();
				if (App.ui) {
					setTimeout(function():void{
						App.ui.salesPanel.createPromoPanel();
						App.ui.salesPanel.resize();
					}, 1000);
				}
			}
		}
		
		private function onStockChange(e:AppEvent = null):void 
		{
			isEnoughMoney = true;
			
			if(!lvlSmaller)
				upgBttn.state = Button.NORMAL;
			
			for (var i:int = 0; i < arrBttns.length; i++ ) {
				var bttn:Button = arrBttns[i];
				if (bttn.order == 1) bttn.removeEventListener(MouseEvent.CLICK, showFantasy);
				else if (bttn.order == 2)bttn.removeEventListener(MouseEvent.CLICK, showBankCoins);
				else if (bttn.order == 3)bttn.removeEventListener(MouseEvent.CLICK, showBankReals);
				else if (bttn.order == 4)bttn.removeEventListener(MouseEvent.CLICK, showTechno);
				bttn.dispose();
				bttn = null;
			}
			arrBttns.splice(0, arrBttns.length);
			
			if (needTxt && bodyContainer.contains(needTxt) ) {
				bodyContainer.removeChild(needTxt);
			}
			if (descCont && bodyContainer.contains(descCont) ) {
				bodyContainer.removeChild(descCont);
			}
			descCont = null;
			descCont = new Sprite();
			
			/*for (i = 0; i < partList.length; i++ ) {
				var itm:MaterialItem = partList[i];
				if (itm.parent) itm.parent.removeChild(itm);
				itm.removeEventListener(WindowEvent.ON_CONTENT_UPDATE, onUpdateOutMaterial);
				itm.dispose();
				itm = null;
			}
			partList.splice(0, partList.length);*/
			
			if (prices.length > 0)
				drawDescription();
			
			/*if (!smallWindow) {
				createResources();
			}*/
			
			buyPrice = 0;
			for (var sID:* in settings.request)
			{
				if (int(sID) == Stock.FANT) {
					settings['noBuyAll'] = true;
				}
				
				if (!App.data.storage[sID].hasOwnProperty('price') || !App.data.storage[sID].price.hasOwnProperty(Stock.FANT)) {
					settings['noBuyAll'] = true;
					break;
				}
				
				var needBuyCount:int = 0;
				var count:int = settings.request[sID];
				
				var countOnStock:int = App.user.stock.count(sID);
				
				if (countOnStock > 0)
					itemsForDebit[sID] = (countOnStock < count) ? countOnStock : count;
				
				if (countOnStock < count)
				{
					needBuyCount = count - countOnStock;
					buyPrice += settings.request[Stock.FANT];
				}
			}
			
			buyAllBttn.count = String(buyPrice);
			
			if (settings.noBuyAll || buyPrice == 0)
				buyAllBttn.visible = false;
		}
		
		private var titleBacking:Bitmap;
		override public function drawBackground():void {
			background = backing2(settings.width, settings.height, 100, 'shopBackingTop', 'shopBackingBotWithRope');
			if (App.user.worldID == Travel.SAN_MANSANO) {
				background = backing2(settings.width, settings.height, 50, 'topBacking', 'bottomBacking3');
			}
			layer.addChild(background);
			
			var backingStr:String = 'shopTitleBacking';
			if (App.user.worldID == Travel.SAN_MANSANO) backingStr = 'goldBackingTop';
			titleBacking = backingShort(235, 'stockTitleBacking', true);
			drawMirrowObjs(backingStr, (settings.width - 518) / 2, (settings.width - 518) / 2 + 518, -70, false, false, false, 1, 1, layer);
		}
		
		override public function drawExit():void {
			super.drawExit();
			exit.x = settings.width - exit.width + 8;
			exit.y = -10;
		}
		
		override public function drawBody():void 
		{
			resizeBack();
			
			titleLabel.x = (settings.width - titleLabel.width) / 2;
			titleLabel.y = - 30;
			
			var bgW1:Bitmap = Window.backing(230, 30, 50, 'fadeOutYellow');
			bgW1.alpha = 0.4;
			bgW1.x = (settings.width - bgW1.width) / 2;
			bgW1.y = -10;
			bodyContainer.addChild(bgW1);
			
			stageLabel = Window.drawText(Locale.__e("flash:1382952380004", [int(settings.target["level"] + 1), settings.target["totalLevels"]]), {
				color				: 0xfffea5,
				fontSize			: 32,
				borderColor 		: 0x4e2811,
				borderSize 			: 4,
				textAlign			: 'center',
				border				: true,
				shadowColor			: 0x4e2811,
				shadowSize			: 1
			});
			stageLabel.width = stageLabel.textWidth + 5;
			stageLabel.x = (settings.width - stageLabel.width) / 2;
			stageLabel.y = -15;
			bodyContainer.addChild(stageLabel);
			
			if (settings.target is Hut) {
				if (settings.target.sid != 461)
					//stageLabel.text = Locale.__e("flash:1382952380004", [int(settings.target["level"]), settings.target["totalLevels"] - 1]);
				//else
					stageLabel.visible = false;
				if (settings.target.info.type == 'Resourcehouse') {
					var maxLevels:int = 0;
					for each (var lvl:Object in settings.target.info.devel.req) {
						maxLevels++;
					}
					stageLabel.visible = true;
					stageLabel.text = Locale.__e("flash:1382952380004", [int(settings.target["level"] + 1), maxLevels]);
				}
			}
			
			bonusList = new BonusList(settings.reward, true, { background:'collectionRewardBacking', titleBorderColor:0x191f37, bonusBorderColor:0x212747}, 530 );
			bonusList.x = (background.width - bonusList.width) / 2;
			bonusList.y = 15;
			
			if (settings.mode == ConstructWindow.CONSTRUCT) {
				for (var sID:* in settings.reward)
				{
					bodyContainer.addChild(bonusList);
					break;
				}
			}
			
			bgHeight = settings.height; 
			if (smallWindow) {
				bgHeight = 200;
			}
			
			drawBackgrounds();
			
			drawBttn();
			
			if (prices.length > 0)
				drawDescription();
			
			backField = new Bitmap();
			backField.width = settings.width - 80;
			backField.height = 240;
			if (!smallWindow) {
				backField.x = (settings.width - backField.width) / 2;
				if (prices.length > 0) {
					backField.y = backLine.y + backLine.height + 10;
					bttnContainer.y = background.height - 75;
				}else {
					//background.height = 400;
					backField.y = 80;
					bttnContainer.y = background.height - 75;
					if (settings.hasState)
						backField.y += 30;
				}
				recNeedTxt();
				createResources();
				//bodyContainer.addChildAt(container, numChildren - 1);
				bodyContainer.addChild(container);
				container.x = backField.x + (backField.width - container.width)/2;
				container.y = backField.y + 26;
			}
			
			windowUpdate();
		}
		
		private function windowUpdate():void 
		{
			if (upgBttn.mode == DISABLED)
			{
				backField.height = 256;
			} else if (backLine != null) {
				var hgNew:int = bgHeight - 26;
				background.height = hgNew;
				backField.height = 206;
				bttnContainer.y = hgNew - 80;
			} 
		}
		
		private function resizeBack():void 
		{
			if (resources.length == 6) 
			{
				settings.width = 940;
				exit.x = -exit.width + settings.width;
			}
			if (resources.length == 5) 
			{
				settings.width = 800;
				exit.x = -exit.width + settings.width;
			}
			if (resources.length == 4) 
			{
				settings.width = 770;
				exit.x = -exit.width + settings.width;
			}
			if (resources.length == 3 && buildingBackImage) 
			{
				buildingBackImage.x = settings.width/2 - buildingBackImage.width/2;
			}
		}
		
		private var lvlSmaller:Boolean = false;
		private function drawBttn():void
		{	
			bttnContainer = new Sprite();
			
			var timer:Bitmap = new Bitmap(Window.textures.timer, "auto", true);
			var timeUpg:int = settings.upgTime;
			if (timeUpg == 0)
				timeUpg = settings.target.info.devel.req[settings.target.level + 1].t;
			
			var count:String = Locale.__e(TimeConverter.timeToCuts(timeUpg, true, true));
			
			var bttnUpgSettings:Object = {
				title			:Locale.__e(settings.bttnTxt),
				width			:230,
				height			:63,	
				fontSize		:26,
				radius			:20,
				countText		:count,
				multiline		:true,
				hasDotes		:false,
				hasText2		:true,
				fontCountSize	:24,
				fontCountColor	:0xffffff,
				fontCountBorder :0x623126,
				textAlign		: "left",	
				bgColor			:[0xf5d058, 0xeeb331],
				bevelColor		:[0xfeee7b, 0xbf7e1a],
				fontBorderColor :0x814f31,
				iconScale		:1,
				iconFilter		:0x814f31,
				notCheck		:false
			}
			if (count == "" && settings.target.type != 'Castle' && settings.target.type != 'Changeable') {
				bttnUpgSettings["width"] = 220;
				bttnUpgSettings["title"] = Locale.__e("flash:1382952379806");
			}
			
			timeUpg = 0;
			
			if (settings.target.info.hasOwnProperty('devel') && Numbers.countProps(settings.target.info.devel.obj[settings.target.level + 1]) == 1) {
				for (var currency:* in settings.target.info.devel.obj[settings.target.level + 1]) {
					break;
				}
				if (currency == Stock.FANT)
					bttnUpgSettings["diamond"] = true;
					bttnUpgSettings["count"] = settings.target.info.devel.obj[settings.target.level + 1][currency];
			}
			
			if (settings.target.info.hasOwnProperty('devel') && App.user.level < settings.target.info.devel.req[settings.target.level + 1].l) {
				timer = new Bitmap(UserInterface.textures.expIcon);
				bttnUpgSettings["title"] = Locale.__e("flash:1404210887391");
				bttnUpgSettings["countText"] = settings.target.info.devel.req[settings.target.level + 1].l;
				lvlSmaller = true;
			} else if (timeUpg == 0) {
				bttnUpgSettings['width'] = 160;
			}
			
			if (settings.target is Single) 
			{
					bttnUpgSettings["title"] = Locale.__e("flash:1414668480389");
					bttnUpgSettings['countText'] = 0;
			}
			upgBttn = new MixedButton2(timer, bttnUpgSettings);
			upgBttn.coinsIcon.x = upgBttn.textLabel.x + upgBttn.textLabel.textWidth + 14;
			upgBttn.coinsIcon.y -= 2;
			upgBttn.countLabel.x = upgBttn.coinsIcon.x + upgBttn.coinsIcon.width + 5;
			upgBttn.countLabel.y += 9;
			upgBttn.name = 'cw_upgrade';
			
			if (timeUpg == 0) {
				upgBttn.textLabel.x = (upgBttn.settings.width - upgBttn.textLabel.width) / 2;
			}
			
			if (lvlSmaller) {
				//upgBttn.countLabel.x = upgBttn.coinsIcon.x + (upgBttn.coinsIcon.width - upgBttn.countLabel.width) / 2;
				upgBttn.countLabel.x = upgBttn.coinsIcon.x - upgBttn.countLabel.width - 5;
				upgBttn.countLabel.y += upgBttn.countLabel.height / 2 - 9;
				upgBttn.state = Button.DISABLED;
			}
			
			if (settings.target.info.hasOwnProperty('devel') && App.user.level < settings.target.info.devel.req[settings.target.level + 1].l) {
				upgBttn.textLabel.x = 8;
			}
			
			upgBttn.y = - upgBttn.height / 2 + 10;
			bttnContainer.addChild(upgBttn);
			upgBttn.addEventListener(MouseEvent.CLICK, onUpgrade);
			
			bttnContainer.x = (settings.width - bttnContainer.width) / 2;
			bodyContainer.addChild(bttnContainer);
			
			if (settings.mode == ConstructWindow.UPGRADE) {
				upgBttn.y += 15;
			}
			
			if (forSearch && App.user.stock.checkAll(settings.request, true)) {
				upgBttn.showGlowing();
				if (App.user.level <= 3) upgBttn.showPointing('bottom', 0, upgBttn.height + 30, bttnContainer);
			}
			
			buyAllBttn = new MoneyButton({
				caption		:Locale.__e("flash:1382952380002"),
				width		:170,
				height		:63,	
				fontSize	:26,
				countText	:90
			});
			buyAllBttn.x = upgBttn.x + upgBttn.width + 10;
			buyAllBttn.y = upgBttn.y;
			
			bttnContainer.addChild(buyAllBttn);
			buyAllBttn.addEventListener(MouseEvent.CLICK, buyAllEvent);
			onStockChange();
		}
		
		private function buyAllEvent(e:MouseEvent):void
		{
			new SimpleWindow( {
				popup:true,
				dialog:true,
				title:Locale.__e('flash:1382952379893'),
				text:Locale.__e('flash:1459929560178'),
				confirm:function():void {
					if (App.user.stock.take(Stock.FANT, buyPrice)) {
						buyAllBttn.state = Button.DISABLED;
						
						var params:Object = { };
						params[Stock.FANT] = buyPrice;
						
						App.user.stock.takeAll(itemsForDebit);
						itemsForDebit = { };
						
						if(settings.hasState || settings.target is Single)
							settings.onUpgrade(settings.request, 1);
						else {
							settings.onUpgrade(settings.target.info.devel.obj[settings.target.level + 1], 1);
						}
						
						if (upgBttn.__hasGlowing) upgBttn.hideGlowing();
						if (upgBttn.__hasPointing) upgBttn.hidePointing();
						
						if (bonusList) bonusList.take();
					}
					
					close();
				}
			}).show();
		}
		
		private var iconTarget:Bitmap = new Bitmap();
		private function drawBackgrounds():void
		{
			if (prices.length == 0)
				bgHeight -= 50;
		   
			var view:String = (settings.target.info.hasOwnProperty('devel')) ? settings.target.info.devel.req[settings.target.level + 1].v : settings.target.info.view;
			var type:String = settings.target.type;
			Load.loading(Config.getIcon(type, view), onPreviewComplete);
			
			bodyContainer.addChildAt(iconTarget, 0);
			
			if (prices.length > 0){
				backLine = new Bitmap(Window.textures.itemBacking);
				bodyContainer.addChild(backLine);
				backLine.x = (settings.width - backLine.width) / 2;
				backLine.y = 80;
			}
			
			if (settings.hasState)
				backLine.y += 30;
		}
		
		private function onPreviewComplete(data:Bitmap):void 
		{
			iconTarget.bitmapData = data.bitmapData;
			Size.size(iconTarget, 190, 140);
			iconTarget.smoothing = true;
			iconTarget.x = (settings.width - iconTarget.width) / 2;
			iconTarget.y = - iconTarget.height - 5;
		}
		
		private var needTxt:TextField;
		private var descCont:Sprite = new Sprite();
		private var arrBttns:Array = [];
		private var numResourses:int;
		private var skipPrice:int;
		private var bttnContainer:Sprite;
		
		private function drawDescription():void 
		{
			var posX:int = 0;
			
			bodyContainer.addChild(descCont);
			
			needTxt = drawText(Locale.__e("flash:1383042563368"), {
				fontSize:28,
				color:0xffffff,
				borderColor:0x5b4814
			});
			bodyContainer.addChild(needTxt);
			needTxt.width = needTxt.textWidth + 5;
			needTxt.height = needTxt.textHeight;
			needTxt.y = backLine.y - needTxt.height + 18;
			needTxt.x = backLine.x + (backLine.width - needTxt.width) / 2;
			
			var contIcon:LayerX = new LayerX();
			
			for (var i:int = 0; i < prices.length; i++ ) {
				var icon:Bitmap;
				var color:int;
				var boderColor:int;
				
				var bttn:Button;
				var bttnSettings:Object = { 
					fontSize:20,
					caption:Locale.__e("flash:1382952379751"),
					height:30,
					width:94,
					radius : 12
				};
				switch(prices[i].sid) {
					case Stock.FANTASY:
						icon = new Bitmap(UserInterface.textures.energyIcon);
						icon.y = 7;
						if (App.user.stock.count(prices[i].sid) < prices[i].count) {
							
							bttnSettings['bgColor'] = [0xa9f84a, 0x73bb16];
							bttnSettings['borderColor'] = [0xffffff, 0xffffff];
							bttnSettings['bevelColor'] = [0xc5fe78, 0x5f9c11];
							bttnSettings['fontColor'] = 0xffffff;				
							bttnSettings['fontBorderColor'] = 0x518410;
							
							bttn = new Button(bttnSettings);
							bttn.addEventListener(MouseEvent.CLICK, showFantasy);
							bttn.order = 1;
						}
						break;
					case Stock.COINS:
						icon = new Bitmap(UserInterface.textures.coinsIcon);
						icon.y = 7;
						if(App.user.stock.count(prices[i].sid) < prices[i].count){
							bttn = new Button( bttnSettings);
							bttn.addEventListener(MouseEvent.CLICK, showBankCoins);
							bttn.order = 2;
						}
						color = 0xfff1cf;
						boderColor = 0x482e16
						break;
					case Stock.FANT:
						icon = new Bitmap(UserInterface.textures.fantsIcon);
						icon.y = 7;
						if(App.user.stock.count(prices[i].sid) < prices[i].count){
							bttn = new Button(bttnSettings);
							bttn.addEventListener(MouseEvent.CLICK, showBankReals);
							bttn.order = 3;
						}
						color = 0xfff1cf;
						boderColor = 0x482e16
						break;
					case Techno.TECHNO:
						icon = new Bitmap(UserInterface.textures.iconWorker);
						icon.y = 7;
						if((App.user.techno.length - Techno.getBusyTechno()) < prices[i].count){
							bttn = new Button(bttnSettings);
							bttn.addEventListener(MouseEvent.CLICK, showTechno);
							bttn.order = 4;
						}
						color = 0xfff1cf;
						boderColor = 0x482e16;
						
						break;
				}
				if (prices[i].sid == Stock.TECHNO && (App.user.techno.length - Techno.getBusyTechno()) < prices[i].count) {
					color = 0xef7563;
					boderColor = 0x623126;
					isEnoughMoney = false;
					upgBttn.state = Button.DISABLED;
					//intervalPluck = setInterval(function():void { if(contIcon && !contIcon.isPluck)contIcon.pluck(30, 25, 25)}, Math.random()* 5000 + 4000);
				}else if (prices[i].sid != Stock.TECHNO  && App.user.stock.count(prices[i].sid) < prices[i].count) {
					color = 0xef7563;
					boderColor = 0x623126;

					isEnoughMoney = false;
					upgBttn.state = Button.DISABLED;
					//intervalPluck = setInterval(function():void { if(contIcon && !contIcon.isPluck)contIcon.pluck(30, 25, 25)}, Math.random()* 5000 + 4000);
				}else {
					color = Window.getTextColor(prices[i].sid).color;
					boderColor = Window.getTextColor(prices[i].sid).borderColor;
				}
				
				icon.smoothing = true;
				descCont.addChild(icon);
				icon.x = posX;
				
				var counTxt:TextField = drawText(String(prices[i].count), {
					fontSize:30,
					color:color,
					borderColor:boderColor
				});
			
				counTxt.width = counTxt.textWidth + 5;
				counTxt.height = counTxt.textHeight;
				counTxt.x = icon.x + icon.width + 5;
				counTxt.y = 12;
				
				descCont.addChild(counTxt);
				
				if (bttn) {
					bttn.x = icon.x + (icon.width + counTxt.textWidth + 5 - bttn.width) / 2;
					bttn.y = 52;
					descCont.addChild(bttn);
					arrBttns.push(bttn);
					bttn = null;
				}
				
				posX = counTxt.x + counTxt.width + 30;
			}
			bodyContainer.addChild(descCont);
			
			//sprite.x = backLine.x + (backLine.width- sprite.width)/2;
			//sprite.y = backLine.y + 10;
			
			descCont.x = backLine.x + (backLine.width- descCont.width)/2;
			descCont.y = backLine.y + 10;
			
		}
		
		private function showTechno(e:MouseEvent):void
		{
			var arrFactories:Array = Map.findUnits([Factory.TECHNO_FACTORY]);
			if (arrFactories.length > 0) {
				
				App.ui.upPanel.onWorkersEvent(e);
			}else {
				App.ui.upPanel.onWorkersEvent(e);
				
				//new ShopWindow( { find:[Factory.TECHNO_FACTORY], forcedClosing:true, popup: true } ).show();
			}
		}
		
		private function showBankReals(e:MouseEvent):void 
		{
			BankMenu._currBtn = BankMenu.REALS;
			BanksWindow.history = {section:'Reals',page:0};
			new BanksWindow( { popup:true } ).show();

		}
		
		private function showBankCoins(e:MouseEvent):void 
		{
			BankMenu._currBtn = BankMenu.COINS;
			BanksWindow.history = {section:'Coins',page:0};
			new BanksWindow( { popup:true } ).show();
		}
		
		private function showFantasy(e:MouseEvent):void 
		{
			new PurchaseWindow( {
				popup:true,
				width:716,
				itemsOnPage:4,
				content:PurchaseWindow.createContent("Energy", {inguest:0, view:'Energy'}),
				title:Locale.__e("flash:1382952379756"),
				description:Locale.__e("flash:1382952379757"),
				callback:function(sID:int):void {
					var object:* = App.data.storage[sID];
					App.user.stock.add(sID, object);
				}
			}).show();
		}
		
		////////////////////////////////////////////////////////////////////////////////
		private var bg:Bitmap;
		private function recNeedTxt():void
		{
			var needTxtParams:Object;
			
			var needTxtConstruct:Object = {
				fontSize:28,
				color:0xffffff,
				borderColor:0x73481e,
				shadowColor:0x73481e,
				shadowSize:1
			};
			
			var needTxtUpgrade:Object = {
				fontSize:32,
				color:0xffffff,
				borderColor:0x1a2729,
				shadowColor:0x1a2729,
				shadowSize:1
			};
			
			if (settings.mode == ConstructWindow.CONSTRUCT) {
				bg = Window.backing(500, 33, 50, 'fadeOutWhite');
				bg.x = (settings.width - bg.width) / 2;
				bg.y = backField.y - bg.height + 40;
				bg.alpha = 0.3;
				bodyContainer.addChild(bg);
				needTxtParams = needTxtConstruct;
			} else if (settings.mode == ConstructWindow.UPGRADE) {
				bg = Window.backing(540, 100, 50, 'fadeOutWhite');
				bg.x = (settings.width - bg.width) / 2;
				bg.y = backField.y - bg.height + 30;
				bg.alpha = 0.1;
				bodyContainer.addChild(bg);
				needTxtParams = needTxtUpgrade;
				/////////////////////////////////////////////////////////
				var fontTime:int = 24;
				if (settings.target is Garden) {
					fontTime = 28;
				}
				var timeWorkLabel:TextField = drawText(settings.timeWorkLabel, {
					fontSize:fontTime,
					autoSize:"left",
					textAlign:"left",
					color:0xffffff,
					borderColor:0x1a2729,
					shadowColor:0x1a2729,
					shadowSize:1
				});
				timeWorkLabel.x = bg.x + 55;
				timeWorkLabel.y = bg.y + 40;
				if (settings.target is Garden)
					timeWorkLabel.y = bg.y + 20;
				timeWorkLabel.width = timeWorkLabel.textWidth;
				bodyContainer.addChild(timeWorkLabel);
				
				var timeIcon:Bitmap = new Bitmap(Window.textures.timer);
				timeIcon.x = timeWorkLabel.x + timeWorkLabel.width + 10;
				timeIcon.y = timeWorkLabel.y - 13;
				bodyContainer.addChild(timeIcon);
				
				var font:int = 32;
				var color:uint = 0x31241d;
				if (settings.target is Garden) {
					font = 28;
					color = 0x1a2729;
				}
				var timeLabel:TextField = drawText(TimeConverter.timeToCuts(settings.target.info.devel.req[settings.target.level + 1].time, false, true), {
					fontSize:font,
					autoSize:"left",
					textAlign:"left",
					color:0xffffff,
					borderColor:color,
					shadowColor:color,
					shadowSize:1
				});
				timeLabel.x = timeIcon.x + timeIcon.width + 10;
				timeLabel.y = timeIcon.y + 5;
				timeLabel.width = timeLabel.textWidth;
				bodyContainer.addChild(timeLabel);
				
			}
			
			var txt:String;
			if (prices.length > 0) {
				txt = Locale.__e("flash:1393580288027") + ":";
			} else if(settings.mode == ConstructWindow.CONSTRUCT) {
				txt = Locale.__e("flash:1382952380003");
			} else {
				txt = Locale.__e("flash:1425656974038");
			}
			
			var needTxt:TextField = drawText(txt, needTxtParams);
			needTxt.width = needTxt.textWidth + 5;
			needTxt.height = needTxt.textHeight;
			needTxt.x = backField.x + (backField.width - needTxt.width)/2;
			needTxt.y = backField.y - needTxt.height + 40;
			if (settings.mode == ConstructWindow.UPGRADE) {
				needTxt.y += 23;
			}
			bodyContainer.addChild(needTxt);
		}
		
		private function createResources():void
		{
			var offsetX:int = 5;
			var offsetY:int = 0;
			var dX:int = 0;
			
			var count:int = 0;
			for each(var sID:* in resources) 
			{
				var pnt:Bitmap = Window.backing(160, 210, 50, 'itemBacking');
				pnt.x += offsetX;
				pnt.y = 30;
				container.addChild(pnt);
				
				var inItem:MaterialItem = new MaterialItem({
					sID:sID,
					need:settings.request[sID],
					window:this, 
					type:MaterialItem.IN,
					color:0x5a291c,
					borderColor:0xfaf9ec,
					bitmapDY: -10,
					bgItemY:38,
					bgItemX:20
				});
				
				if (forSearch && !materialForSearch && !App.user.stock.check(sID, settings.request[sID], true)) {
					inItem.askBttn.showGlowing();
					//inItem.askBttn.showPointing('bottom', 0, inItem.askBttn.height + 20, inItem);
					materialForSearch = true;
				}
				
				inItem.checkStatus();
				inItem.addEventListener(WindowEvent.ON_CONTENT_UPDATE, onUpdateOutMaterial);
				
				partList.push(inItem);
				
				container.addChild(inItem);
				inItem.x = offsetX;
				inItem.y = 50;
				
				count++;
				
				offsetX += inItem.background.width + 70;
				inItem.background.visible = false;
				
				if (settings.mode == ConstructWindow.UPGRADE) {
					pnt.y += 10;
					inItem.y += 10;
				}
			}
			
			container.x = (settings.width - container.width) / 2;
			//inItem.dispatchEvent(new WindowEvent(WindowEvent.ON_CONTENT_UPDATE));
			onUpdateOutMaterial();
		}
		
		public function onUpdateOutMaterial(e:WindowEvent = null):void {
			var outState:int = MaterialItem.READY;
			for each(var item:* in partList) {
				if(item.status != MaterialItem.READY){
					outState = item.status;
				}
			}
			
			if (outState == MaterialItem.UNREADY) {
				
				upgBttn.state = Button.DISABLED;
			}
			else if (isEnoughMoney && !lvlSmaller) {
				
				upgBttn.state = Button.NORMAL; 
				windowUpdate();
			}
		}
		
		private function onUpgrade(e:MouseEvent):void
		{
			if (e.currentTarget.mode == Button.DISABLED) {
				Hints.text(Locale.__e('flash:1382952379927') + '!', 9, new Point(mouseX, mouseY));
				return;
			}
			
			close();
			e.currentTarget.state = Button.DISABLED;
			
			if(settings.hasState || settings.target is Single)
				settings.onUpgrade(settings.request);
			else {
				settings.onUpgrade((settings.target.info.hasOwnProperty('devel')) ? settings.target.info.devel.obj[settings.target.level + 1] : null);
			}
			
			if (upgBttn.__hasGlowing) upgBttn.hideGlowing();
			if (upgBttn.__hasPointing) upgBttn.hidePointing();
		}
		
		override public function dispose():void
		{
			App.self.removeEventListener(AppEvent.ON_CHANGE_STOCK, onStockChange);
			App.self.removeEventListener(AppEvent.ON_AFTER_PACK, onStockChange);
			App.self.removeEventListener(AppEvent.ON_TECHNO_CHANGE, onStockChange);
			
			if (upgBttn) {
				upgBttn.removeEventListener(MouseEvent.CLICK, onUpgrade);
				upgBttn.dispose();
				upgBttn = null;
			}
			
			for (var i:int = 0; i < arrBttns.length; i++ ) {
				var bttn:Button = arrBttns[i];
				if (bttn.order == 1) bttn.removeEventListener(MouseEvent.CLICK, showFantasy);
				else if (bttn.order == 2)bttn.removeEventListener(MouseEvent.CLICK, showBankCoins);
				else if (bttn.order == 3)bttn.removeEventListener(MouseEvent.CLICK, showBankReals);
				else if (bttn.order == 4)bttn.removeEventListener(MouseEvent.CLICK, showTechno);
				bttn.dispose();
				bttn = null;
			}
			arrBttns.splice(0, arrBttns.length);
			
			if (needTxt && bodyContainer.contains(needTxt) ) {
				bodyContainer.removeChild(needTxt);
			}
			
			for (i = 0; i < partList.length; i++ ) {
				var itm:MaterialItem = partList[i];
				if (itm.parent) itm.parent.removeChild(itm);
				itm.removeEventListener(WindowEvent.ON_CONTENT_UPDATE, onUpdateOutMaterial)
				itm.dispose();
				itm = null;
			}
			partList.splice(0, partList.length);
			
			super.dispose();
		}
		
	}		
}