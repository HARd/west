package wins 
{
	import buttons.Button;
	import buttons.ImageButton;
	import buttons.MenuButton;
	import buttons.MoneyButton;
	import com.greensock.TweenLite;
	import core.Load;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.utils.setTimeout;
	import ui.UserInterface;
	import units.Storehouse;
	import wins.elements.SearchMaterialPanel;

	public class DaylicsShopWindow extends Window
	{
		public static var showUpgBttn:Boolean = true;
		public static const MINISTOCK:int = 4;
		public static const ARCHIVE:int = 1;
		public static const DESERT_WAREHOUSE:int = 2;
		public static const PAGODA:int = 3;
		public static const DEFAULT:int = 0;
		
		public static var mode:int = DEFAULT;
		public var sections:Object = new Object();
		public var icons:Array = new Array();
		public var items:Vector.<DaylicsShopItem> = new Vector.<DaylicsShopItem>();
		
		public static var history:Object = { section:"all", page:0 };
		
		public var bonusList:BonusList;
		public var plusBttn:ImageButton;
		
		public var makeBiggerBttn:Button;
		
		//public var capasitySprite:LayerX = new LayerX();
		//private var capasitySlider:Sprite = new Sprite();
		//private var capasityCounter:TextField;
		//public var capasityBar:Bitmap;
		
		public function DaylicsShopWindow(settings:Object = null):void
		{
			if (settings == null) {
				settings = new Object();
			}
			
			settings["section"] = settings.section || "all"; 
			settings["page"] = settings.page || 0; 
			
			settings["find"] = settings.find || null;
			
			settings["title"] = /*(User.inExpedition?App.data.storage[Stock.TENT].title:*/Locale.__e("flash:1382952379765");
			settings["width"] = 720;
			settings["height"] = 540;
			
			settings["hasPaginator"] = true;
			settings["hasArrows"] = true;
			settings["itemsOnPage"] = 8;
			settings["buttonsCount"] = 7;
			settings["background"] = 'storageBackingTop';
			mode = settings.mode || DEFAULT;
			//settings["hasPaginator"] = false;
			//settings["footerImage"] = 'stock';
			
			
			var stocks:Array = [];
			switch(mode) {
				default:
						stocks = Map.findUnits([Storehouse.SILO]);
					break;
				/*case ARCHIVE:
						stocks = Map.findUnits([Storehouse.ARCHIVE]);
					break;	
				case DESERT_WAREHOUSE:
						stocks = Map.findUnits([Storehouse.DESERT_WAREHOUSE]);
					break;	
				case PAGODA:
						stocks = Map.findUnits([Storehouse.PAGODA]);
					break;	*/	
			}
			
			if (App.self.getLength(App.user.daylicShopData)==0) {
				for (var id:String in App.data.storage) {
					var item:Object = App.data.storage[id];
					if (item.hasOwnProperty('currency') && App.self.getLength(item.currency)) {
						App.user.daylicShopData[id] = (item);
					}
			}
			}
			
			settings["target"] = stocks[0];
			
			createContent();
			
			findTargetPage(settings);
			
			super(settings);
			
			App.self.addEventListener(AppEvent.ON_CHANGE_STOCK, refresh);
		}
		
		override public function dispose():void {
			super.dispose();
			
			if(boostBttn)boostBttn.removeEventListener(MouseEvent.CLICK, onBoostEvent);
			boostBttn = null;
			
			App.self.removeEventListener(AppEvent.ON_CHANGE_STOCK, refresh);
			
			//if (capasitySprite.parent) capasitySprite.parent.removeChild(capasitySprite);
			//if (capasitySlider.parent) capasitySlider.parent.removeChild(capasitySlider);
			//capasitySprite = null;
			//capasitySlider = null;
			//capasityCounter = null;
			//capasityBar = null;
			
			for each(var item:* in items) {
				item.dispose();
				item = null;
			}
			
			for each(var icon:* in icons) {
				icon.dispose();
				icon = null;
			}
		}
		
		override public function drawBackground():void
		{
			
			//подгрузка тотема
			var totem:Bitmap = new Bitmap();
			Load.loading(Config.getQuestIcon('preview', App.data.personages[9].preview), function(data:*):void {
				
				totem.bitmapData = data.bitmapData;
				
				if (App.data.personages[9].preview == 'totem') {
					totem.x = (stage.x / 2) + 180;
					totem.y = -110;	
				}
			});
		
			//основная подложка
			var background:Bitmap = backing(settings.width, settings.height, 30, 'buildingBacking');
			layer.addChild(totem);
			layer.addChild(background);
			background.x = -10;
			background.y = 40;
			
			//сепараторы
			separator = Window.backingShort(630, 'divider');
			separator.alpha = 0.6;
			layer.addChild(separator);
			separator.x = 45;
			separator.y = 88;

		}
		
		override public function drawTitle():void 
		{
			titleLabel = titleText( {
				title				: settings.title,
				color				: settings.fontColor,
				multiline			: settings.multiline,
				fontSize			: settings.fontSize,				
				textLeading	 		: settings.textLeading,				
				borderColor 		: settings.fontBorderColor,			
				borderSize 			: settings.fontBorderSize,	
					
				shadowBorderColor	: settings.shadowBorderColor || settings.fontColor,
				width				: settings.width - 140,
				textAlign			: 'center',
				sharpness 			: 50,
				thickness			: 50,
				border				: true
			})
				
			titleLabel.x = (settings.width - titleLabel.width) * .5;
			titleLabel.y = -16;
			titleLabel.mouseChildren = titleLabel.mouseEnabled = false;
			headerContainer.addChild(titleLabel);
			headerContainer.y = 37;
			headerContainer.mouseEnabled = false;
		}
		
		override public function drawExit():void {
				var exit:ImageButton = new ImageButton(textures.closeBttn);
				headerContainer.addChild(exit);
				exit.x = settings.width - 60;
				exit.y = -5;
				exit.addEventListener(MouseEvent.CLICK, close);
			}
		
		private function findTargetPage(settings:Object):void {
			
			
			
			for (var section:* in sections) {
				if (App.user.quests.currentQID == 158) 
				section = 'others';
				for (var i:* in sections[section].items) {
					
					var sid:int = sections[section].items[i].sid;
					if (settings.find != null && settings.find.indexOf(sid) != -1) {
						
						history.section = section;
						history.page = int(int(i) / settings.itemsOnPage);
						
						settings.section = history.section;
						settings.page = history.page;
						return;
					}
				}
			}
			//close();
			
			if (settings.hasOwnProperty('find')&&settings.find !=null) 
			{
			//	setTimeout(function():void {
				new SimpleWindow( {
				label:SimpleWindow.ATTENTION,
				text:Locale.__e('flash:1425555522565', [App.data.storage[settings.find[0]].title]),
				title:Locale.__e('flash:1382952379725'),
				popup:true,
				confirm:findRes,
				buttonText:Locale.__e('flash:1407231372860')
				//forcedClosing:true
				}).show();
			//	}, 500)
			}
			
		}
		
		private function findRes():void 
		{
			
			ShopWindow.findMaterialSource(settings.find[0]);
		}
		
		public function createContent():void {
			
			if (sections["all"] != null) return;
			
			sections = {
				
				"others":{items:new Array(),page:0},
				"all":{items:new Array(),page:0},
				"harvest":{items:new Array(),page:0},
				"jam": { items:new Array(), page:0 },
				"materials":{items:new Array(),page:0},
			//	"collections":{items:new Array(),page:0},
				"workers":{items:new Array(),page:0}
			};
			
			var section:String = "all";
			
			//var parsedObj:Object = JSON.parse(App.data.options.daylicItem);
			
			for(var ID:* in App.user.daylicShopData) {
				var item:Object= App.user.daylicShopData[ID];
				//= App.data.storage[ID];
				if(item == null)	continue;
				//if (count < 1) 		continue;
				
				
				if (notShow(ID)) continue;
				//Пропускаем деньги
				//if ('gct'.indexOf(item.type) != -1) continue;
				switch(item.type){
					case 'Material':
				
						if (item.mtype == 0) {
							section = "materials";
						}else if (item.mtype == 1) {
							section = "harvest";
						}else if (item.mtype == 3) {
							if( mode != StockWindow.MINISTOCK) {
								continue
							 }else {
								 //Пропускаем системные
								continue; 
							 }
						}else if (item.mtype == 4 && mode != StockWindow.MINISTOCK) {
							//Пропускаем коллекции
							section = 'collections';
							continue;
						}else{
							section = "others";
						}
						break;
					case 'Jam':
					case 'Clothing':
					case 'Lamp':
					case 'Guide':
					case 'Vip':
							continue;
						break;
					default:
						section = "others";
						break;	
				}
				
				item["sid"] = ID;
				sections[section].items.push(item);
				sections["all"].items.push(item);
			}
			
			if (mode != DEFAULT) {
				if (mode != MINISTOCK) {
					sections["all"].items = artifacts[mode];
				}else {
					sections["all"].items = sections["all"].items.concat(artifacts[PAGODA]);
					sections["all"].items = sections["all"].items.concat(artifacts[DESERT_WAREHOUSE]);
					sections["all"].items = sections["all"].items.concat(artifacts[ARCHIVE]);
				}
			}
			//for each(var _section:* in sections) {
				//_section.items.sortOn("order", Array.NUMERIC);
			//}
		}
		
		private var artifacts:Object = { 1:[], 2:[], 3:[] };
		
		private var separator:Bitmap;
		private var separator2:Bitmap;
		private var seachPanel:SearchMaterialPanel;
		override public function drawBody():void {
			
			//бонуслист
			bonusList = new BonusList({1159:App.user.stock.count(Stock.SEA_STONE)}, true, {
				hasTitle: false,
				extraWidth: true,
				bonusTextColor: 0xa9f9ff,
				bonusBorderColor:0x44382a				
			});
			bodyContainer.addChild(bonusList);
			bonusList.x = (settings.widtn - bonusList.width)/2;
			bonusList.y += 35;
			
			//купить осколки моря
			plusBttn = new ImageButton(UserInterface.textures.energyPlusBttn);
			plusBttn.tip =  function():Object { return { title:Locale.__e("flash:1382952379817") }; }
			plusBttn.addEventListener(MouseEvent.CLICK, onEnergyEvent);
		//	bodyContainer.addChild(plusBttn);
			plusBttn.x = 400;
			plusBttn.y = 48;

			
			drawBacking();
			
			drawMirrowObjs('diamondsTop', settings.width / 2 - settings.titleWidth / 2 - 5, settings.width / 2 + settings.titleWidth / 2 + 5, 2, true, true);
		if (mode == MINISTOCK) {
				drawMirrowObjs('tentDecor', -10, settings.width - 10, 0);
				drawMirrowObjs('tentDecor', -10, settings.width - 10, settings.height , false, false, false, 1, -1);
			}else {
				drawMirrowObjs('storageWoodenDec', -10, settings.width - 10, settings.height - 70);
				drawMirrowObjs('storageWoodenDec', -10, settings.width - 10, 80, false, false, false, 1, -1);
			}
			
			
			drawMenu();
			
			setContentSection(settings.section,settings.page);
			contentChange();
			
			seachPanel = new SearchMaterialPanel( {
				win:this, 
				callback:showFinded,
				stop:onStopFinding,
				hasIcon:false,
				caption:Locale.__e('flash:1382952380300')
			});
			//bodyContainer.addChild(seachPanel);
			seachPanel.y = paginator.y + 28;
			seachPanel.x = 18;
			
			this.y -= 30;
			
			fader.y += 30;
			
			
			/*separator = Window.backingShort(160, 'separator3');
			separator.alpha = 0.5;
			separator.x = settings.backX;
			separator.y = 84;*/
			
			/*separator2 = Window.backingShort(160, 'separator3');
			separator2.alpha = 0.5;
			separator2.x = settings.backX + settings.backWidth - separator2.width;
			separator2.y = 84;*/
			
			/*bodyContainer.addChild(separator);
			bodyContainer.addChild(separator2);*/
			
			if(settings.target){
				if(settings.target.level < settings.target.totalLevels && showUpgBttn && !settings.target.hasPresent && settings.target.hasBuilded && settings.target.hasUpgraded){
					drawBttns();
				}
				//if(settings.target.level <= settings.target.totalLevels && showUpgBttn && !settings.target.hasPresent && settings.target.hasBuilded && settings.target.hasUpgraded){
					//addSlider();
				//}
				else if(settings.target.upgradedTime > 0 && !settings.target.hasUpgraded){
					drawUpgradeInfo();
				}else {
					drawBigSaparator();
				}
			}else {
				drawBigSaparator();
			}
			
			//drawMinistockBttn();
			//addSlider();
		}
		
		private function drawMinistockBttn():void 
		{
			if (!App.isSocial('DM','VK','ML','OK','FS','FB','NK')) 
			{
				return
			}
			var stockBttn:ImageButton = new ImageButton(UserInterface.textures.stockIcon);
			
			stockBttn.addEventListener(MouseEvent.CLICK, onStockBttn);
			var bg:Bitmap = new Bitmap(UserInterface.textures.mainBttnBacking);
			bodyContainer.addChild(bg);
			bodyContainer.addChild(stockBttn);
			stockBttn.x = stockBttn.height/2 -25;
			stockBttn.y = stockBttn.width / 2 -25;
			bg.x = stockBttn.x-(bg.width-stockBttn.width)/2;
			bg.y = stockBttn.y-(bg.height-stockBttn.height)/2;
		}
		
		private function onStockBttn(e:MouseEvent):void 
		{
			close();
			new ShipWindow( {
				target:	(settings.hasOwnProperty('stockTarget'))?settings.stockTarget:null,
				mode:mode
			}).show();
		}
		
		public function onEnergyEvent(e:MouseEvent = null):void {
			
			if (App.user.quests.tutorial)
				return;
			
			new PurchaseWindow( {
				width:558,
				itemsOnPage:3,
				content:PurchaseWindow.createContent("Energy", {inguest:0, view:'Energy'}),
				title:Locale.__e("flash:1382952379756"),
				description:Locale.__e("flash:1382952379757"),
				popup: true,
			
				callback:function(sID:int):void {
					var object:* = App.data.storage[sID];
					App.user.stock.add(sID, object);
				}
			}).show();
			
		}
		
		public function onStockShipTransferWindowBttn(e:MouseEvent):void 
		{
			//close();
			//var win:* = new VoicelessShipWindow( {
				//e:e,
				//target:	(settings.hasOwnProperty('stockTarget'))?settings.stockTarget:null,
				//popup:true,
				//mode:mode
			//});
			//win.show();
		}
		
		private var priceSpeed:int = 0;
		//private var priceBttn:int = 0;
		private var totalTime:int = 0;
		private var finishTime:int = 0;
		private var boostBttn:MoneyButton;
		private var upgTxt:TextField;
		private function drawUpgradeInfo():void 
		{
			if(separator)
				bodyContainer.removeChild(separator);
			if(separator2)
				bodyContainer.removeChild(separator2);
			separator = null;
			separator2 = null;
			
			var time:int = 0;
			if (settings.target.created > 0 && !settings.target.hasBuilded) {
				time = settings.target.created - App.time;
				
				var curLevel:int = settings.target.level + 1;
				if (curLevel >= settings.target.totalLevels) curLevel = settings.target.totalLevels;
				finishTime = settings.target.created;
				totalTime = App.data.storage[settings.target.sid].devel.req[1].t;
			}else if (settings.target.upgradedTime > 0 && !settings.target.hasUpgraded) {
				time = settings.target.upgradedTime - App.time;
				
				finishTime = settings.target.upgradedTime;
				totalTime = App.data.storage[settings.target.sid].devel.req[settings.target.level+1].t;
			}
			
			var textSettings:Object = {
				color:0xffffff,
				borderColor:0x644b2b,
				fontSize:32,
				
				textAlign:"left"
			};
			
			upgTxt = Window.drawText(Locale.__e('flash:1402905682294') + " " + TimeConverter.timeToStr(time), textSettings); 
			upgTxt.width = upgTxt.textWidth + 10;
			upgTxt.height = upgTxt.textHeight;
			
			bodyContainer.addChild(upgTxt);
			upgTxt.x = 70;
			upgTxt.y = 44;
			
			
			priceSpeed = Math.ceil((finishTime - App.time) / App.data.options['SpeedUpPrice']);
			
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
			boostBttn.x = upgTxt.x + upgTxt.width + 10;
			boostBttn.y = 32;
			bodyContainer.addChild(boostBttn);
			
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
			
			boostBttn.addEventListener(MouseEvent.CLICK, onBoostEvent);
			
			updateTime();
			App.self.setOnTimer(updateTime);
		}
		
		private function onBoostEvent(e:MouseEvent = null):void
		{
			//if (settings.doBoost)
				//settings.doBoost(priceBttn);
			//else
				//settings.target.acselereatEvent(priceBttn);
			//close();
		}
		
		private function updateTime():void
		{
			var time:int = 0;
			if (settings.target.created > 0 && !settings.target.hasBuilded) {
				time = settings.target.created - App.time;
			}else if (settings.target.upgradedTime > 0 && !settings.target.hasUpgraded) {
				time = settings.target.upgradedTime - App.time;
			}
			
			if (time < 0) {
				App.self.setOffTimer(updateTime);
				close();
				return;
			}
			
			upgTxt.text = Locale.__e('flash:1402905682294') + " " + TimeConverter.timeToStr(time);
			
			
			priceSpeed = Math.ceil((finishTime - App.time) / App.data.options['SpeedUpPrice']);
			
			//if (boostBttn && priceBttn != priceSpeed && priceSpeed != 0) {
				//priceBttn = priceSpeed;
				//boostBttn.count = String(priceSpeed);
			//}
			
		}
		
		private function drawBigSaparator():void
		{
			/*bodyContainer.removeChild(separator);
			bodyContainer.removeChild(separator2);
			separator = null;
			separator2 = null;*/
			
			/*separator = Window.backingShort(580, 'separator3');
			separator.alpha = 0.5;
			bodyContainer.addChild(separator);
			separator.x = settings.backX;
			separator.y = 84;*/
		}
		
		/*private function addSlider():void
		{
			capasityBar = new Bitmap(Window.textures.prograssBarBacking);			
			capasityBar.x;
			capasityBar.y = 22;
			Window.slider(capasitySlider, 60, 60, "progressBar");
			
			bodyContainer.addChild(capasitySprite);
			
			
			var textSettings:Object = {
				color:0xffffff,
				borderColor:0x644b2b,
				fontSize:32,
				
				textAlign:"center"
			};
			
			capasityCounter = Window.drawText(Stock.value +'/'+ Stock.limit, textSettings); 
			capasityCounter.width = 120;
			capasityCounter.height = capasityCounter.textHeight;
			
			capasitySprite.mouseChildren = false;
			capasitySprite.addChild(capasityBar);
			capasitySprite.addChild(capasitySlider);
			capasitySprite.addChild(capasityCounter);
			
			capasitySlider.x = capasityBar.x + 10; 
			capasitySlider.y = capasityBar.y + 6;
			
			
			if (settings.target.level < settings.target.totalLevels)
			{
				capasitySprite.x = settings.width / 2 - capasityBar.width / 2 - 85; 
				capasitySprite.y = 17;
			}else
			{
				capasitySprite.x = settings.width / 2 - capasityBar.width / 2; 
				capasitySprite.y = 17;
			};
			
			
			capasityCounter.x = capasityBar.width / 2 - capasityCounter.width / 2; 
			capasityCounter.y = capasityBar.y - capasityBar.height/2 + capasityCounter.textHeight / 2 + 8;
			
			updateCapasity(Stock.value, Stock.limit);
		}
		
		public function updateCapasity(currValue:int, maxValue:int):void
		{
			if (capasitySlider) {
				
				if (currValue < 0)
					currValue = 0;
				
				Window.slider(capasitySlider, currValue, maxValue, "progressBar");
				
				if(capasityCounter){
					capasityCounter.text = currValue +'/' + maxValue;
					capasityCounter.x = capasityBar.width / 2 - capasityCounter.width / 2;
				}
			}
		}*/
		
		private function drawBttns():void 
		{
			var bttnSettings:Object = {
				caption:Locale.__e("flash:1393580216438", [settings.target.info.devel.req[settings.target.level + 1].c]), //flash:1396609462757
				fontSize:24,
				width:140,
				height:37,
				radius:15,	
				textAlign:"center",
				hasDotes:false
			};
			
			makeBiggerBttn = new Button(bttnSettings);
			bodyContainer.addChild(makeBiggerBttn);
			makeBiggerBttn.tip = function():Object { 
				return {
					title:"",
					text:Locale.__e("flash:1393580216438", [settings.target.info.devel.req[settings.target.level + 1].c]) //flash:1396609462757
				};
			};
		
			makeBiggerBttn.x = settings.width * 0.5 - makeBiggerBttn.width * 0.5 + 210;
			makeBiggerBttn.y = 43;
			
			makeBiggerBttn.addEventListener(MouseEvent.CLICK, onMakeBiggerEvent);
		}
		
		private function onMakeBiggerEvent(e:MouseEvent):void 
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
			settings.target.upgradeEvent(settings.target.info.devel.obj[settings.target.level + 1], count);
			showUpgBttn = false;
			//App.ui.bottomPanel.bttnMainStock.buttonMode = false;
			//TweenLite.to(App.ui.bottomPanel.bttnMainStock, 1, {alpha:0});
			close();
		}
		
		private function showFinded(content:Array):void
		{
			settings.content = content;
			paginator.itemsCount = content.length;
			paginator.update();
			
			contentChange();
		}
		
		private function onStopFinding():void
		{
			setContentSection(history.section,history.page);
		}
		
		public function drawBacking():void {
			
			/*var backing:Bitmap = Window.backing(580, 390, 40, 'storageInnerBacking');
			bodyContainer.addChild(backing);
			backing.x = (settings.width/2 - backing.width/2) - 10;
			backing.y = 98;
			
			settings['backX'] = backing.x;
			settings['backWidth'] = backing.width;*/
		}
		
		public function drawMenu():void {
			if (mode == StockWindow.MINISTOCK) 
			{
			return	
			}
			var menuSettings:Object = {
				"all":		{order:1, 	title:" "+Locale.__e("flash:1382952380301")},
				//"harvest":	{order:2, 	title:" "+Locale.__e("flash:1382952380302")},
				"materials":{order:4, 	title:Locale.__e("flash:1382952380303")},
				"others":	{order:6, 	title:Locale.__e("flash:1382952380304")}
			}
			
			for (var item:* in sections) {
				if (menuSettings[item] == undefined) continue;
				var settings:Object = menuSettings[item];
				settings['type'] = item;
				settings['onMouseDown'] = onMenuBttnSelect;
				
				if (settings.order == 1) {
							settings["bgColor"] = [0xade7f1, 0x91c8d5];
							settings["bevelColor"] = [0xdbf3f3, 0x739dac];
							settings["fontBorderColor"] = 0x53828f;
							settings['active'] = {
								bgColor:				[0x73a9b6,0x82cad6],
								bevelColor:				[0x739dac, 0xdbf3f3],	
								fontBorderColor:		0x53828f				//Цвет обводки шрифта		
							}
						}
						
				icons.push(new MenuButton(settings));
			}
			icons.sortOn("order");
						
			var sprite:Sprite = new Sprite();
			
			var offset:int = 0;
			for (var i:int = 0; i < icons.length; i++)
			{
				icons[i].x = offset;
				//icons[i].y = 30;
				offset += icons[i].settings.width + 6;
				sprite.addChild(icons[i]);
			}
			//bodyContainer.addChild(sprite);
			sprite.x = (this.settings.width - sprite.width) / 2;
			sprite.y = 45;
			
		}
		
		private function onMenuBttnSelect(e:MouseEvent):void
		{
			if (App.user.quests.tutorial) 
			{
				return
			}
			e.currentTarget.selected = true;
			setContentSection(e.currentTarget.type);
		}
		
		public function setContentSection(section:*,page:int = -1):Boolean {
			for each(var icon:MenuButton in icons) {
				icon.selected = false;
				if (icon.type == section) {
					icon.selected = true;
				}
			}
			if (sections.hasOwnProperty(section)) {
				settings.section = section;
				settings.content = [];
				
				for (var i:int = 0; i < sections[section].items.length; i++)
				{
					var sID:uint = sections[section].items[i].sid;
					//if (App.user.stock.count(sID) > 0)
						settings.content.push(sections[section].items[i]);
				}
				
				paginator.page = page == -1 ? sections[section].page : page;
				paginator.itemsCount = settings.content.length;
				paginator.update();
				
			}else {
				return false;
			}
			
			contentChange();	
			//if(seachPanel) seachPanel.text = "";
			return true
		}
		
		
		
		public function refresh(e:AppEvent = null):void
		{
			//setContentSection(settings.section,settings.page);
			
			/*for (var i:int = 0; i < settings.content.length; i++)
			{
				if (App.user.stock.count(settings.content[i].sid) == 0)
				{
					settings.content.splice(i, 1);
				}
			}*/
			sections = { };
			createContent();
			findTargetPage(settings);
			setContentSection(settings.section,settings.page);
			
			paginator.itemsCount = settings.content.length;
			paginator.update();
			contentChange();
			
			//updateCapasity(Stock.value, Stock.limit);
		}
		
		override public function contentChange():void {
			
			for each(var _item:DaylicsShopItem in items) {
				bodyContainer.removeChild(_item);
				_item.dispose();
				_item = null;
			}
			if (bonusList) {
			bodyContainer.removeChild(bonusList);
			bonusList = null;
			}
			bonusList = new BonusList({1159:App.user.stock.count(Stock.SEA_STONE)}, true, {
				hasTitle: false,
				extraWidth: true,
				bonusTextColor: 0xa9f9ff,
				bonusBorderColor:0x44382a				
			});
			bodyContainer.addChild(bonusList);
			bonusList.x = (settings.width - bonusList.width)/2;
			bonusList.y += 35;
			
			items = new Vector.<DaylicsShopItem>();
			//var X:int = 74;
			var X:int = 58;
			var Xs:int = X;
			var Ys:int = 118;
			
			var itemNum:int = 0;
			for (var i:int = paginator.startCount; i < paginator.finishCount; i++)
			{
				var item:DaylicsShopItem = new DaylicsShopItem(settings.content[i], this);
				
				bodyContainer.addChild(item);
				item.x = Xs;
				item.y = Ys;
					
				items.push(item);
				Xs += item.bg.width+5;
				if (itemNum == int(settings.itemsOnPage / 2) - 1)	{
					Xs = X;
					Ys += item.bg.height+15;
				}
				
				itemNum++;
			}
			
			sections[settings.section].page = paginator.page;
			settings.page = paginator.page;
			
		}
		
		override public function drawArrows():void 
		{
			
			paginator.drawArrow(bottomContainer, Paginator.LEFT,  0, 0, { scaleX: -1, scaleY:1 } );
			paginator.drawArrow(bottomContainer, Paginator.RIGHT, 0, 0, { scaleX:1, scaleY:1 } );
			
			var y:int = (settings.height - paginator.arrowLeft.height) / 2 + 46;
			paginator.arrowLeft.x = 15;
			paginator.arrowLeft.y = y + 5;
			
			paginator.arrowRight.x = settings.width - paginator.arrowRight.width + 40;
			paginator.arrowRight.y = y + 5;
			
			//paginator.y += 87;
			paginator.x = int((settings.width - paginator.width)/2 - 40);
			paginator.y = int(settings.height - paginator.height + 52);
		}
		
		private function notShow(sID:int):Boolean 
		{
			return false
			switch(sID) {
				case 100000:
				
						return true;
					break;
			}
			
			return false;
		}
	}
}

import buttons.Button;
import buttons.ImageButton;
import com.greensock.TweenLite;
import com.greensock.TweenMax;
import core.Load;
import core.Numbers;
import core.Post;
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.filters.GlowFilter;
import flash.geom.Point;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.utils.setTimeout;
import ui.Cursor;
import ui.UserInterface;
import ui.WishList;
import units.Factory;
import units.Field;
import units.Techno;
import units.Unit;
import units.WorkerUnit;
import wins.StockWindow;
//import gifts.GiftManager;
//import picture.PictureFiller;
import wins.Window;
import wins.SellItemWindow;
import silin.filters.ColorAdjust;

internal class StockMenuItem extends Sprite {
	
	public var textLabel:TextField;
	public var icon:Bitmap;
	public var type:String;
	public var order:int = 0;
	public var title:String = "";
	public var selected:Boolean = false;
	public var window:*;
	
	public function StockMenuItem(type:String, window:*) {
		
		this.type = type;
		this.window = window;
		
		switch(type) {
			case "all"			: order = 1; title = Locale.__e("flash:1382952380301"); break;
			case "harvest"		: order = 2; title = Locale.__e("flash:1382952380302"); break;
			case "jam"			: order = 3; title = Locale.__e("flash:1382952380201"); break;
			case "materials"	: order = 4; title = Locale.__e("flash:1382952380303"); break;
			case "others"		: order = 6; title = Locale.__e("flash:1382952380304"); break;
		}

		icon.y = - icon.height + 6;
		
		addChild(icon);
				
		textLabel = Window.drawText(title,{
			fontSize:18,
			color:0xf2efe7,
			borderColor:0x464645,
			autoSize:"center"
		});


		addChild(textLabel);
		textLabel.x = (icon.width - textLabel.width) / 2 + 200;

		addEventListener(MouseEvent.CLICK, onClick);
		addEventListener(MouseEvent.MOUSE_OVER, onOver);
		addEventListener(MouseEvent.MOUSE_OUT, onOut);
	}
		
	
	private function onClick(e:MouseEvent):void {
		if (App.user.quests.tutorial)
		return
		this.active = true;
		window.setContentSection(type);
	}
	
	private function onOver(e:MouseEvent):void{
		if(!selected){
			effect(0.1);
		}
	}
	
	private function onOut(e:MouseEvent):void {
		if(!selected){
			icon.filters = [];
		}
	}
	
	public function dispose():void {
		removeEventListener(MouseEvent.CLICK, onClick);
		removeEventListener(MouseEvent.MOUSE_OVER, onOver);
		removeEventListener(MouseEvent.MOUSE_OUT, onOut);
	}
	
	public function set active(selected:Boolean):void {
		var format:TextFormat = new TextFormat();
		
		this.selected = selected;
		if (selected) {
			glow();
			format.size = 18;
			textLabel.setTextFormat(format);
		}else {
			icon.filters = [];
			textLabel.setTextFormat(textLabel.defaultTextFormat);
		}
	}
	
	public function glow():void{
		
		var myGlow:GlowFilter = new GlowFilter();
		myGlow.inner = false;
		//myGlow.color = 0xebdb81;
		myGlow.color = 0xf1d75d;
		myGlow.blurX = 10;
		myGlow.blurY = 10;
		myGlow.strength = 10
		icon.filters = [myGlow];
	}
	
	private function effect(count:int):void {
		var mtrx:ColorAdjust;
		mtrx = new ColorAdjust();
		mtrx.brightness(count);
		icon.filters = [mtrx.filter];
	}
}



	import buttons.Button;
	import buttons.MoneySmallButton;
	import core.Load;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import ui.Cursor;
	import ui.Hints;
	import units.Anime;
	import units.Field;
	import units.Unit;
	import ui.Cursor;
	import ui.Hints;
	import wins.Window;
	import wins.ShopWindow;
	import wins.SimpleWindow;
	import units.Anime2;
	
	internal class DaylicsShopItem extends Sprite {
		
		public var item:Object;
		public var bg:Bitmap;
		private var bitmap:Bitmap;
		private var buyBttn:MoneySmallButton;
		private var buyBttnNow:MoneySmallButton;
		private var _parent:*;
		private var sprite:LayerX;
		private var preloader:Preloader = new Preloader();
		
		public function DaylicsShopItem (item:Object, parent:*) {
			
			this._parent = parent;
			this.item = item;
			
			
			
			bg = Window.backing(160, 190, 15, 'itemBacking');
			addChild(bg);
			
			bg.x -= 35;
			bg.y -= 23;
			
			var sprite:LayerX = new LayerX();
			addChild(sprite);
				
			bitmap = new Bitmap();
			sprite.addChild(bitmap);
			
			sprite.tip = function():Object { 
				
				if (item.type == "Plant") {
					return {
						title:item.title,
						text:Locale.__e("flash:1382952380297", [TimeConverter.timeToCuts(item.levelTime * item.levels), item.experience, App.data.storage[item.out].cost])
					};
				}
				else if (item.type == "Decor") {
					return {
						title:item.title,
						text:Locale.__e("flash:1382952380076", String(item.experience))
					}	
				} else {
					return {
						title:item.title,
						text:item.description
					};
				}
			};
			
			drawTitle();
			drawBttn();
			
			addChild(preloader);
			preloader.x = (bg.width)/ 2;
			preloader.y = (bg.height) / 2;
			preloader.scaleX = preloader.scaleY = 0.67;
			
			if ((item.type == 'Decor' || item.type == 'Golden' || item.type == 'Walkgolden')) {
				Load.loading(Config.getSwf(item.type, item.preview), onLoadAnimate);	
			} else {		
				Load.loading(Config.getIcon(item.type, item.preview), onLoad);
			}
		}
		
		private function onLoad(data:Bitmap):void {
			if (preloader){
				removeChild(preloader);
				preloader = null;
			}
			
			bitmap.bitmapData = data.bitmapData;
			
			if (bitmap.width > bg.width - 20) {
				bitmap.scaleX = bitmap.scaleY = (bg.width - 20)/(bitmap.width);
			}
			if (bitmap.height > bg.height - 50 ) {
				bitmap.height =  bg.height - 50;
				bitmap.scaleX = bitmap.scaleY;
			}
			
			bitmap.smoothing = true;
			
			bitmap.x = ((bg.width - bitmap.width)/2) - 35;
			bitmap.y = ((bg.height - bitmap.height)/2) - 23;
			
		}
	 
		private function onLoadAnimate(swf:*):void {
			if (preloader){
				removeChild(preloader);
				preloader = null;
			}
			
			if (!sprite) { 
				sprite = new LayerX();
			}
			if (!contains(sprite)) addChild(sprite);
			
			var bitmap:Bitmap = new Bitmap(swf.sprites[swf.sprites.length - 1].bmp, 'auto', true);
			bitmap.x = swf.sprites[swf.sprites.length - 1].dx;
			bitmap.y = swf.sprites[swf.sprites.length - 1].dy;
			sprite.addChild(bitmap);
			
			if(swf.animation){
				var framesType:String;
				for (framesType in swf.animation.animations) break;
				var anime:Anime = new Anime(swf);//, framesType, swf.animation.ax, swf.animation.ay);
				sprite.addChild(anime);
				//anime.startAnimation();
			}
			
			if (sprite.width > bg.width - 20) {
				sprite.scaleX = sprite.scaleY = (bg.width - 20)/(sprite.width);
			}
			if (sprite.height > bg.height - 40 ) {
				sprite.height =  bg.height - 40;
				sprite.scaleX = sprite.scaleY;// = (background.height - 70) / (bitmap.height);
			}
			sprite.x = bg.x + bg.width / 2;
			sprite.y = bg.y + bg.height / 2 + 15/* + ((sprite.height > 100) ? ((sprite.height - 100) / 2) : 0)*/;
			
		}
		
		public function drawTitle():void {
			var title:TextField = Window.drawText(String(item.title), {
				color:0x814f31,
				borderColor:0xfcf6e4,
				textAlign:"center",
				fontSize:22,
				textLeading:-8,
				multiline:false,
				wrap:true,
				width:bg.width
			});
			
			title.y = -15;
			title.x = ((bg.width - title.width)/2) - 35;
			addChild(title);
		}
		
		public function drawBttn():void {
			
			var isBuyNow:Boolean = false;
			
			var bttnSettings:Object = {
				caption     :Locale.__e("flash:1382952379751"),
				width		:100,
				height		:38,	
				fontSize	:24,
				scale		:0.8,
				hasDotes    :false
			}
			App.data.storage
			
			/*if (item.cost) {
				bttnSettings['type'] = 'real';
				bttnSettings['countText'] = item.cost;
				bttnSettings["bgColor"] = [0xfffef6, 0x80552a];
				bttnSettings["borderColor"] = [0xffffff, 0xffffff];
				bttnSettings["bevelColor"] = [0xc5fe78, 0x405c1a];
				bttnSettings["fontColor"] = 0xffffff;				
				bttnSettings["fontBorderColor"] = 0x354321;
				bttnSettings['greenDotes'] = false;
				isBuyNow = true;
			}else if (item.price && item.price[Stock.COINS]) {
				bttnSettings['type'] = 'coins';
				bttnSettings['countText'] = item.price[Stock.COINS];
			isBuyNow = true;
			}else if(item.price && item.price[Stock.FANT]){
				bttnSettings['type'] = 'real';
				bttnSettings['countText'] = item.price[Stock.FANT];
				bttnSettings["bgColor"] = [0xa9f84a, 0x73bb16];
				bttnSettings["borderColor"] = [0xffffff, 0xffffff];
				bttnSettings["bevelColor"] = [0xc5fe78, 0x405c1a];
				bttnSettings["fontColor"] = 0xffffff;				
				bttnSettings["fontBorderColor"] = 0x354321;
				bttnSettings['greenDotes'] = false;
				isBuyNow = true;
			}else if (item.instance) {
				var count:int = World.getBuildingCount(item.sID);
				if (count == 0)
					count = 1;
				if (item.instance.cost && item.instance.cost[count][Stock.FANT]) {
					bttnSettings['type'] = 'real';
					bttnSettings["bgColor"] = [0xa9f84a, 0x73bb16];
					bttnSettings["borderColor"] = [0xffffff, 0xffffff];
					bttnSettings["bevelColor"] = [0xc5fe78, 0x405c1a];
					bttnSettings["fontColor"] = 0xffffff;				
					bttnSettings["fontBorderColor"] = 0x354321;
					bttnSettings['greenDotes'] = false;
					bttnSettings["countText"] = item.instance.cost[count][Stock.FANT];
					isBuyNow = true;
				}
			}*/
			
			if(item.currency && item.currency[Stock.SEA_STONE]){
				bttnSettings['type'] = 'seaStone';
				bttnSettings['countText'] = item.currency[Stock.SEA_STONE];
			/*	bttnSettings["bgColor"] = [0xa9f84a, 0x73bb16];
				bttnSettings["borderColor"] = [0xffffff, 0xffffff];
				bttnSettings["bevelColor"] = [0xc5fe78, 0x405c1a];
				bttnSettings["fontColor"] = 0xffffff;				
				bttnSettings["fontBorderColor"] = 0x354321;
				bttnSettings['greenDotes'] = false;*/
				//isBuyNow = true;
			}
			
			if(!isBuyNow){
				buyBttn = new MoneySmallButton(bttnSettings);
				addChild(buyBttn);
				buyBttn.x = (bg.width - buyBttn.width) / 2;
				buyBttn.y = bg.height - 24;
				buyBttn.addEventListener(MouseEvent.CLICK, onBuy);
			}else {
				buyBttnNow = new MoneySmallButton(bttnSettings);
				addChild(buyBttnNow);
				buyBttnNow.x = (bg.width - buyBttnNow.width) / 2;
				buyBttnNow.y = bg.height - 24;
				buyBttnNow.addEventListener(MouseEvent.CLICK, onBuyNow);
				buyBttnNow.coinsIcon.y -= 4;
		}			
		if (item.currency[Stock.SEA_STONE]>App.user.stock.count(Stock.SEA_STONE)) {
			buyBttn.state = Button.DISABLED;
		}
			buyBttn.x -= 35;
			buyBttn.y -= 23;			
		}
		
		private function onBuyNow(e:MouseEvent):void {
			return
			if (e.currentTarget.mode == Button.DISABLED) return;
			e.currentTarget.state = Button.DISABLED;
			
			ShopWindow.currentBuyObject = { type:item.type, sid:item.sid, currency:item.currency };
			
			var unit:Unit;
			switch(item.type) {
				
				case "Material":
					App.user.stock.buy(item.sid, 1, onBuyComplete);
					break;
				case "Boost":
				case "Energy":
					App.user.stock.pack(item.sid, onBuyComplete);
					break;
				case "Plant":
					if(Field.exists == false){
						unit = Unit.add( { sid:13 } );
						unit.move = true;
						App.map.moved = unit;
						Cursor.plant = item.sid;
					}
					Field.exists = false;
					break;
				default:
					if (item.sid == 54 && App.user.quests.data["16"] == undefined) {
						new SimpleWindow( {
							text:Locale.__e('flash:1383043022250', [App.data.quests[16].title]),
							label:SimpleWindow.ATTENTION
						}).show();
						break;
					}
					unit = Unit.add( { sid:item.sid, buy:true } );
					
					unit.move = true;
					App.map.moved = unit;
					
					
				break;
			}
			
			if(item.type != "Material"){
					_parent.win.close();
				}
		}
		
		
		
		public function onBuyComplete(type:*, price:uint = 0):void {
			
			var point:Point = new Point(App.self.mouseX - buyBttn.mouseX, App.self.mouseY - buyBttn.mouseY);
			point.x += buyBttn.width / 2;
			Hints.minus(Stock.FANT, item.real, point, false, App.self.tipsContainer);
			buyBttn.state = Button.NORMAL;
			
			flyMaterial();
		}		
		
		private function onBuy(e:MouseEvent):void {
			if (buyBttn.mode == Button.DISABLED) {
				Hints.text(Locale.__e('flash:1441034974700'), Hints.TEXT_RED, new Point(App.self.mouseX, App.self.mouseY));
				return
			}
		//	_parent.close();
		//	if (!isEnoughTechno()) return;
			
			//if (!isEnoughMoney()) return;
		
		//	ShopWindow.currentBuyObject = { type:item.type, sid:item.sid,currency:item.currency };
			var unit:Unit;
			if (App.map.moved && App.map.moved.info.type == 'Field' ) {
				Cursor.plant = false;
				App.map.moved.previousPlace();
				App.map.moved.move = false;
				App.map.moved.visible = false;
				App.map.moved.uninstall();
			}
			
			if (Cursor.plant) {
				Cursor.plant = false;
			}
			
			App.map.moved = null;
			if (item.type != 'Field' || item.type != 'Plant') {
				Cursor.plant == false;
			}
			
			App.user.stock.buy(item.sid, 1, null/*, { 'ac':1 } */);
			flyMaterial(/*item.sid*/);
			return
			
			switch(item.type)
			{
				case "Material":
				case 'Vip':
				case 'Firework':
				case "Energy":
					if (item.view !='slave') 
					{
					App.user.stock.buy(item.sid, 1,null,{'ac':1});
					flyMaterial(/*item.sid*/);
					break;
					}
					//App.user.stock.buy(item.sid, 1);
					//break;
				case "Boost":
				case "Energy":
					var sett:Object = null;
					if (App.data.storage[item.sid].out == App.data.storage[App.user.worldID].techno[0]) {
						sett = { 
							ctr:'techno',
							wID:App.user.worldID,
							x:App.map.heroPosition.x,
							z:App.map.heroPosition.z,
							ac:1,
							capacity:App.time + App.data.options['SlaveBoughtTime']
						};
						App.user.stock.pack(item.sid, onBuyComplete, function():void {
						}, sett);
					}else {
						App.user.stock.pack(item.sid,null,null,{'ac':1});
					}
					break;
				/*case "Plant":
					unit = Unit.add( { sid:User.fieldSkin(), pID:item.sid, planted:0 } );
					unit.move = true;
					App.map.moved = unit;
					Cursor.plant = item.sid;
					
					Field.exists = false;
					
					if (App.user.quests.currentQID == 10) {
						App.user.quests.currentTarget = null;
						QuestsRules.getQuestRule(App.user.quests.currentQID, App.user.quests.currentMID);
					}
					
					break;*/
				/*case 'Clothing':
					new HeroWindow({find:item.sid}).show();
					break;*/
				/*case 'Animal':
					unit = Unit.add( { sid:item.sid, buy:true } );
					
					unit.move = true;
					App.map.moved = unit;
					break;*/
				default:
					unit = Unit.add( { sid:item.sid, buy:true } );
					//if ( unit.hasOwnProperty('_cloud') ) unit['_cloud'].dispose();
					unit.move = true;
					unit.isBuyNow = true;
					App.map.moved = unit;
				break;
			}
			
			//	window.contentChange(); 
			
			/*if(item.type != "Material"){
				window.close();
			}else{
				var point:Point = localToGlobal(new Point(e.currentTarget.x, e.currentTarget.y));
				point.x += e.currentTarget.width / 2;
				Hints.minus(Stock.COINS, item.coins, point);
			}*/
			
			/*if(App.user.quests.tutorial){
				QuestsRules.getQuestRule(App.user.quests.currentQID, App.user.quests.currentMID);
			}*/
		}		
		
		public function dispose():void {
			if(buyBttn)buyBttn.removeEventListener(MouseEvent.CLICK, onBuy);
			if(buyBttnNow)buyBttn.removeEventListener(MouseEvent.CLICK, onBuyNow);
		}
		
		private function flyMaterial():void
		{
			var item:BonusItem = new BonusItem(item.sid, 0);
			
			var point:Point = Window.localToGlobal(this);
			//point.y += bitmap.height / 2;
			item.cashMove(point, App.self.windowContainer);
		}
	}
