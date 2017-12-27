package wins 
{
	import buttons.Button;
	import buttons.ImageButton;
	import buttons.MenuButton;
	import buttons.MoneyButton;
	import com.greensock.TweenLite;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import ui.UserInterface;
	import units.Storehouse;
	import wins.elements.SearchMaterialPanel;

	public class StockWindow extends Window
	{
		public static const DEFAULT:int = 0;
		public static const ARTIFACTS:int = 1;
		public static const MINISTOCK:int = 4;
		
		public static var mode:int = DEFAULT;
		
		public static var needToOpen:int = 0;
		public static var accelUnits:Array;
		public static var accelMaterial:int;
		
		public var sections:Object = new Object();
		public var icons:Array = new Array();
		public var items:Vector.<StockItem> = new Vector.<StockItem>();
		
		public static var history:Object = { section:"all", page:0 };
		
		public var makeBiggerBttn:Button;
		
		public var capasitySprite:LayerX = new LayerX();
		private var capasitySlider:Sprite = new Sprite();
		private var capasityCounter:TextField;
		public var capasityBar:Bitmap;
		
		public function StockWindow(settings:Object = null):void
		{
			if (settings == null) {
				settings = new Object();
			}
			
			settings["section"] = settings.section || "all"; 
			settings["page"] = settings.page || 0; 
			settings["find"] = settings.find || null;
			settings["title"] = settings.title || Locale.__e("flash:1382952379767");
			settings["width"] = 680;
			settings["height"] = 590;
			settings["hasPaginator"] = true;
			settings["hasArrows"] = true;
			settings["itemsOnPage"] = 6;
			settings["background"] = 'storageBackingMain';
			settings['shadowColor'] = 0x513f35;
			settings['shadowSize'] = 4;

			mode = settings.mode || DEFAULT;
			
			if (mode == MINISTOCK) {
				settings["width"] = 680;
				settings["height"] = 550;
			}
			
			//var stocks:Array = Map.findUnits([Storehouse.SILO]);
			//settings["target"] = stocks[0];
			
			createContent();
			
			if (needToOpen != 0 ) {
				settings['find'] = [needToOpen];
				needToOpen = 0;
			}
			
			findTargetPage(settings);
			
			super(settings);
			
			App.self.addEventListener(AppEvent.ON_CHANGE_STOCK, refresh);
		}
		
		override public function dispose():void {
			super.dispose();
			
			if(boostBttn)boostBttn.removeEventListener(MouseEvent.CLICK, onBoostEvent);
			boostBttn = null;
			
			App.self.removeEventListener(AppEvent.ON_CHANGE_STOCK, refresh);
			
			if (capasitySprite.parent) capasitySprite.parent.removeChild(capasitySprite);
			if (capasitySlider.parent) capasitySlider.parent.removeChild(capasitySlider);
			capasitySprite = null;
			capasitySlider = null;
			capasityCounter = null;
			capasityBar = null;
			
			for each(var item:* in items) {
				item.dispose();
				item = null;
			}
			
			for each(var icon:* in icons) {
				icon.dispose();
				icon = null;
			}
		}
		
		private var titleBacking:Bitmap;
		override public function drawBackground():void {
			if (mode == MINISTOCK) {
				background = backing2(settings.width, settings.height, 100, 'expBackingTop', 'expBackingBot');
				layer.addChild(background);
			} else {
				background = backing2(settings.width, settings.height, 100, 'stockBackingTop', 'stockBackingBot');
				layer.addChild(background);
				titleBacking = backingShort(235, 'stockTitleBacking', true);
				drawMirrowObjs('stockTitleBacking', 110, 580, -35, false, false, false, 1, 1, layer);
			}
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
				shadowColor			: settings.shadowColor,
				width				: settings.width - 140,
				textAlign			: 'center',
				sharpness 			: 50,
				thickness			: 50,
				border				: true,
				shadowSize			:4
			})
				
			titleLabel.x = (settings.width - titleLabel.width) * .5;
			titleLabel.y = -40;
			titleLabel.mouseChildren = titleLabel.mouseEnabled = false;
			headerContainer.addChild(titleLabel);
			headerContainer.y = 37;
			headerContainer.mouseEnabled = false;
		}
		
		override public function drawExit():void {
			var exit:ImageButton = new ImageButton(textures.closeBttn);
			headerContainer.addChild(exit);
			exit.x = settings.width - 54;
			exit.y = 2;
			exit.addEventListener(MouseEvent.CLICK, close);
			
			if (mode == MINISTOCK) {
				exit.y -= 30;
			}
		}
	
		private function findTargetPage(settings:Object):void {
			for (var section:* in sections){
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
		}
		
		public function createContent():void {
			
			if (sections["all"] != null) return;
			artifacts = [];
			
			sections = {
				"all":{items:new Array(),page:0},
				"harvest":{items:new Array(),page:0},
				"jam":{items:new Array(),page:0},
				"materials":{items:new Array(),page:0},
				"workers":{items:new Array(),page:0},
				"buildings":{items:new Array(),page:0},
				"others":{items:new Array(),page:0}
			};
			
			var section:String = "all";
			
			var harvest:Object = { };
			for (var s:* in App.data.storage) {
				if ((App.data.storage[s].hasOwnProperty('outs') && App.data.storage[s].type == 'Plant') && ID != 3) {
					var outs:Object = App.data.storage[s].outs;
					for (var out:* in outs) {
						if (out != Stock.EXP && out != Stock.COINS && out != Stock.FANT && out != Stock.FANTASY && out != Stock.ENERGY) {
							harvest[out] = s;
						}
					}
				} else if (App.data.storage[s].hasOwnProperty('devel') && App.data.storage[s].type == 'Tree' && ID != 2)
				{
					var devel:Object = App.data.storage[s].devel.rew;
					for (var i:* in devel) {
						for (out in devel[i]) {
							if (out != Stock.EXP && out != Stock.COINS && out != Stock.FANT && out != Stock.FANTASY && out != Stock.ENERGY) {
								harvest[out] = s;
							}
						}
					}
				}
			}
			
			for (var ID:* in App.user.stock.data) {
				var count:int = 0;
				
				if (App.data.storage[ID].type == 'Zones') continue;
				if (App.data.storage[ID].type == 'Collection') continue;
				if (ID == 752 || App.data.storage[ID].type == 'Building' || App.data.storage[ID].type == 'Tribute') {
					if (!(App.user.stock.data[ID] is int)) {
						for (var level:String in App.user.stock.data[ID]) {
							count += App.user.stock.data[ID][level]; 
							//if (count > 0) break;
						}
					}
					if (!count) count = App.user.stock.data[ID];
				}else {
					count = App.user.stock.data[ID];
				}
				var item:Object = App.data.storage[ID];
				if(item == null)	continue;
				if (count < 1) 		continue;
				if (ID == 686 || ID == 1127) continue;
				
				// Урожай
				if (harvest.hasOwnProperty(ID))
					item.mtype = 1;
				
				//Пропускаем деньги
				switch(item.type){
					case 'Material':
				
						if (item.mtype == 0) {
							section = "materials";
						}else if (item.mtype == 1) {
							section = "harvest";
						}else if (item.mtype == 3) {
							if (item.sid == Stock.GOLD_COINS /*Золотые монетки*/) {
								section = "materials";
								break;
							}
							
							continue;
						}else if (item.mtype == 4 && mode != StockWindow.MINISTOCK) {
							//Пропускаем коллекции
							section = 'collections';
							continue;
						}else{
							section = "others";
						}
						break;
					case 'Building':
					case 'Tribute':
					case 'Hut':
					case 'Floors':
					case 'Happy':
					case 'Wigwam':
					case 'Resourcehouse':
						section = "buildings";
						break;
					case 'Jam':
					case 'Clothing':
					case 'Lamp':
					//case 'Guide':
					case 'Vip':
							continue;
						break;
					default:
						section = "others";
						break;	
				}
				item["sid"] = ID;
				
				if (item.artifact) {
					artifacts.push(item);
					continue;
				}
				
				if (item.sid == 629) {
					continue;
				}
				
				sections[section].items.push(item);
				sections["all"].items.push(item);
			}
			
			if (mode == ARTIFACTS) {
				sections["all"].items = artifacts;
			}
		}
		
		private var artifacts:Array = [];
		
		private var separator:Bitmap;
		private var separator2:Bitmap;
		private var seachPanel:SearchPanel;
		//private var seachPanel:SearchMaterialPanel;
		override public function drawBody():void {
			drawBacking();
			setContentSection(settings.section,settings.page);
			contentChange();
			
			seachPanel = new SearchPanel({
				content:sections,
				searchCallback:search,
				callback:showFinded,
				stop:onStopFinding,
				hasIcon:false,
				//filter:['sid'],
				caption:Locale.__e('flash:1405687705056')
			});
			bodyContainer.addChild(seachPanel);
			
			//seachPanel = new SearchMaterialPanel( {
				//win:this, 
				//callback:showFinded,
				//stop:onStopFinding,
				//hasIcon:false,
				//caption:Locale.__e('flash:1405687705056')
			//});
			//bodyContainer.addChild(seachPanel);
			seachPanel.y = paginator.y;
			seachPanel.x = 10;
			
			if(settings.target){
				if(settings.target.level < settings.target.totalLevels && !settings.target.hasPresent && settings.target.hasBuilded && settings.target.hasUpgraded){
					drawBttns();
				}
				if(settings.target.level <= settings.target.totalLevels && !settings.target.hasPresent && settings.target.hasBuilded && settings.target.hasUpgraded){
					addSlider();
				}
				else if(settings.target.upgradedTime > 0 && !settings.target.hasUpgraded){
					drawUpgradeInfo();
				}else {
					drawBigSaparator();
				}
			}else {
				drawBigSaparator();
			}
			
			if (mode == MINISTOCK) drawMinistockBttn();
			
			drawMenu();
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
			if (settings.doBoost)
				settings.doBoost(priceBttn);
			else
				settings.target.acselereatEvent(priceBttn);
			close();
		}
		
		private function drawMinistockBttn():void 
		{
			var stockBttn:ImageButton = new ImageButton(UserInterface.textures.expShipPic);			
			stockBttn.addEventListener(MouseEvent.CLICK, onStockBttn);
			bodyContainer.addChild(stockBttn);
			stockBttn.x = 60;
			stockBttn.y = -25;
		}
		
		private function onStockBttn(e:MouseEvent):void 
		{
			close();
			
			new ShipWindow( {
				target:	(settings.hasOwnProperty('stockTarget'))?settings.stockTarget:null,
				mode:mode
			}).show();
		}
		
		private var priceBttn:int;
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
			
			if (boostBttn && priceBttn != priceSpeed && priceSpeed != 0) {
				priceBttn = priceSpeed;
				boostBttn.count = String(priceSpeed);
			}
			
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
			
			if (!settings.target || !settings.target.hasPresent) return;
			
			var textFiled:TextField = drawText(Locale.__e('flash:1413557015995'), {
				textAlign:		'center',
				color:			0xFFFFFF,
				borderColor:	0x644b2b,
				fontSize:		24,
				width:			420,
				multiline:		true,
				wrap:			true
			});
			textFiled.x = 40;
			textFiled.y = 50;
			bodyContainer.addChild(textFiled);
			
			var bttnBonus:Button = new Button( {
				caption:		Locale.__e('flash:1382952379737'),
				width:			130,
				height:			46,
				fontSize:		26
			});
			bttnBonus.x = textFiled.x + textFiled.width + 10;
			bttnBonus.y = 40;
			bodyContainer.addChild(bttnBonus);
			bttnBonus.addEventListener(MouseEvent.CLICK, onBonusTake);
		}
		private function onBonusTake(e:MouseEvent):void {
			e.currentTarget.removeEventListener(MouseEvent.CLICK, onBonusTake);
			settings.target.click();
			close();
		}
		
		private function addSlider():void
		{
			capasityBar = new Bitmap(Window.textures.prograssBarBacking);			
			if (mode == StockWindow.ARTIFACTS)
				capasityBar.x = 0;
			
			capasityBar.y = 22;
			Window.slider(capasitySlider, 60, 60, "progressBar");
			
			bodyContainer.addChild(capasitySprite);
			
			
			var textSettings:Object = {
				color:0xffffff,
				borderColor:0x644b2b,
				fontSize:32,
				
				textAlign:"center"
			};
			
			//textSettings.fontSize = 24;
			capasityCounter = Window.drawText('0', textSettings);
			capasityCounter.width = 120;
			capasityCounter.height = capasityCounter.textHeight;
			
			capasitySprite.mouseChildren = false;
			capasitySprite.addChild(capasityBar);
			capasitySprite.addChild(capasitySlider);
			capasitySprite.addChild(capasityCounter);
			
			//capasitySlider.x = (capasityBar.width - capasitySlider.width)/2; capasitySlider.y = (capasityBar.height - capasitySlider.height)/2;
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
			
			
			capasityCounter.x = capasityBar.x + (capasityBar.width / 2 - capasityCounter.width / 2); 
			capasityCounter.y = capasityBar.y - capasityBar.height / 2 + capasityCounter.textHeight / 2 + 8;
			
			//updateCapasity(Stock.value, Stock.limit);
		}
		
		public function updateCapasity(currValue:int, maxValue:int):void
		{
			/*if (mode == ARTIFACTS) {
				currValue = Stock._value_mag;
				maxValue = Stock.limit_mag;
			}else {
				currValue = Stock.value;
				maxValue = Stock.limit;
			}*/
			
			if (capasitySlider) 
			{
				if (currValue < 0)
					currValue = 0;
				
				Window.slider(capasitySlider, currValue, maxValue, "progressBar");
				
				if(capasityCounter){
					capasityCounter.text = currValue +'/' + maxValue;
					capasityCounter.x = capasityBar.x + (capasityBar.width / 2 - capasityCounter.width / 2);
				}
			}
		}
		
		private function drawBttns():void 
		{
			var bttnSettings:Object = {
				caption:Locale.__e("flash:1393580216438", [settings.target.info.devel.req[settings.target.level + 1].c]), //flash:1396609462757
				fontSize:24,
				width:140,
				height:37,
				radius:15,	
				textAlign:"left",
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
			
			if (settings.isStock) {
				makeBiggerBttn.startGlowing();
			}
				
			makeBiggerBttn.addEventListener(MouseEvent.CLICK, onMakeBiggerEvent);
			
			if (mode == StockWindow.ARTIFACTS)
				makeBiggerBttn.visible = false;
				
			if (settings.target.helpTarget == settings.target.sid)
				makeBiggerBttn.showGlowing();
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
			
			close();
		}
		
		public function search(query:String = ""):Array {
			if (query == "") {
				onStopFinding();
				return null;	
			}
			
			query = query.toLowerCase();
			
			var result:Array = [];
			var items:Array = sections[settings.section].items;
			var L:uint = items.length;
			
			for (var i:int = 0; i < L; i++)
			{
				var item:Object = items[i];
				
				if (item.sid == 752 && App.user.stock.data[item.sid] == 0)
					continue;
					
				var txt:String = String(item.title);
				txt = txt.toLocaleLowerCase();
				
				if (txt.indexOf(query) == 0)
					result.push(item);
			}
			
			result.sortOn('order', Array.NUMERIC);
			
			return result;
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
		
		public function drawBacking():void {}
		
		public function drawMenu():void {
			if (mode == StockWindow.MINISTOCK) return;
			
			var menuSettings:Object = {
				"all":		{order:1, 	title:" "+Locale.__e("flash:1382952380301")+"  "},
				"harvest":	{order:2, 	title:" "+Locale.__e("flash:1382952380302")+"  "},
				"materials":{order:4, 	title:Locale.__e("flash:1382952380303")},
				"buildings":{order:5, 	title:Locale.__e("flash:1460465048576")},
				"others":	{order:6, 	title:Locale.__e("flash:1382952380304")}
			}
			
			for (var item:* in sections) {
				if (menuSettings[item] == undefined) continue;
				var settings:Object = menuSettings[item];
				settings['type'] = item;
				settings['onMouseDown'] = onMenuBttnSelect;
				settings['fontSize'] = 24;
					
				icons.push(new MenuButton(settings));
			}
			icons.sortOn("order");
	
						
			var sprite:Sprite = new Sprite();
			
			var offset:int = 0;
			for (var i:int = 0; i < icons.length; i++)
			{
				icons[i].x = offset;
				//icons[i].y = 30;
				offset += icons[i].settings.width + 10;
				sprite.addChild(icons[i]);
			}
			bodyContainer.addChild(sprite);
			sprite.x = (this.settings.width - sprite.width) / 2;
			sprite.y = 30;
			
		}
		
		private function onMenuBttnSelect(e:MouseEvent):void
		{
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
					if (App.user.stock.count(sID) > 0)
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
			
			for (var i:int = 0; i < settings.content.length; i++)
			{
				if (App.user.stock.count(settings.content[i].sid) == 0)
				{
					settings.content.splice(i, 1);
				}
			}
			sections = { };
			createContent();
			findTargetPage(settings);
			setContentSection(settings.section,settings.page);
			
			paginator.itemsCount = settings.content.length;
			paginator.update();
			contentChange();
		}
		
		override public function contentChange():void {
			
			for each(var _item:StockItem in items) {
				bodyContainer.removeChild(_item);
				_item.dispose();
				_item = null;
			}
			
			items = new Vector.<StockItem>();
			//var X:int = 74;
			var X:int = 70;
			var Xs:int = X;
			var Ys:int = 80;
			
			if (mode == MINISTOCK) Ys = 40;
			
			var itemNum:int = 0;
			for (var i:int = paginator.startCount; i < paginator.finishCount; i++)
			{
				var item:StockItem = new StockItem(settings.content[i], this);
				
				bodyContainer.addChild(item);
				item.x = Xs;
				item.y = Ys;
					
				items.push(item);
				Xs += item.background.width+10;
				if (itemNum == int(settings.itemsOnPage / 2) - 1)	{
					Xs = X;
					Ys += item.background.height+15;
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
			
			var y:int = (settings.height - paginator.arrowLeft.height) / 2 + 36;
			paginator.arrowLeft.x = -40;
			paginator.arrowLeft.y = y + 5;
			
			paginator.arrowRight.x = settings.width - paginator.arrowLeft.width + 20;
			paginator.arrowRight.y = y + 5;
			
			if (paginator.pages <= 7) {
				paginator.x = (settings.width - paginator.width) / 2 - 30;
			}else {
				paginator.x = (settings.width - paginator.width) / 2;
			}
			paginator.y = int(settings.height - paginator.height) - 15;
			seachPanel.y = paginator.y - 75;
			
			if (mode == MINISTOCK) {
				paginator.y = int(settings.height - paginator.height);
				seachPanel.y = paginator.y - 60;
			}
		}
	}
}

import buttons.Button;
import buttons.ImageButton;
import buttons.SimpleButton;
import com.greensock.TweenLite;
import com.greensock.TweenMax;
import core.Load;
import core.Numbers;
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.filters.GlowFilter;
import flash.geom.Point;
import flash.text.TextField;
import flash.text.TextFormat;
import silin.utils.Hint;
import ui.Cursor;
import ui.Hints;
import ui.UserInterface;
import ui.WishList;
import units.Factory;
import units.Field;
import units.Unit;
import units.WorkerUnit;
import wins.StockWindow;;
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
			case "buildings"	: order = 5; title = Locale.__e("flash:1460465048576"); break;
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



import wins.GiftWindow;
import wins.RewardWindow;
import wins.SimpleWindow;
import wins.StockDeleteWindow;
import wins.TechnoManagerWindow;
import wins.TravelWindow;

internal class StockItem extends Sprite {
	
	public var item:*;
	public var background:Bitmap;
	public var bitmap:Bitmap;
	public var title:TextField;
	public var placeBttn:Button;
	public var applyBttn:Button;
	public var closeBttn:ImageButton;
	public var wishlistBttn:ImageButton;
	public var giftBttn:ImageButton;
	public var window:*;
	public var sellPrice:TextField;
	public var price:int;
	
	public var plusBttn:Button;
	public var minusBttn:Button;
	
	public var plus10Bttn:Button;
	public var minus10Bttn:Button;
	
	public var countCalc:TextField;
	private var preloader:Preloader = new Preloader();
	
	private var reason:String = '';
	
	public function StockItem(item:*, window:*):void {
		
		this.item = item;
		this.window = window;
		
		background = Window.backing(170, 170, 10, "itemBacking");
		addChild(background);
		
		var sprite:LayerX = new LayerX();
		addChild(sprite);
		
		bitmap = new Bitmap();
		sprite.addChild(bitmap);
		
		sprite.tip = function():Object { 
			return {
				title:item.title,
				text:item.description
			};
		};
		
		//drawTitle();
		
		addChild(preloader);
		preloader.x = background.width / 2;
		preloader.y = background.height / 2;
		
		drawBttns();
		
		
		Load.loading(Config.getIcon(item.type, item.preview), onPreviewComplete);
		
		price = item.cost;
		
		placeBttn.visible = false;
		applyBttn.visible = false;
		wishlistBttn.visible = true;
		giftBttn.visible = true;
		
		if (price == 0 && Numbers.countProps(item.sale) == 0) {
			closeBttn.visible = false;
		}
		
		if (StockWindow.mode == StockWindow.MINISTOCK) {
			giftBttn.visible = false;
			closeBttn.visible = false;
			wishlistBttn.x += 40;
		}
		
		if (item.type == "Jam"){
			giftBttn.visible = false;
			wishlistBttn.visible = false;
			placeBttn.visible = true;
		}
		
		if (['Building','Tribute','Decor','Golden','Animal','Tree','Resource','Bridge','Firework','Techno','Moneyhouse','Field','Floors','Walkgolden','Mining','Buffer','Tradesman','Goldbox','Character','Goldentechno','Gamble','Changeable','Zoner','Box','Barter','Hut','Stall','Thimbles','Fake','Tstation','Exchange','Technological','Guide','Happy','Garden','Bgolden','Fatman','Mfield','Rbuilding','Efloors','Booker','Mhelper','Mfloors','Compressor','Minigame','Buildgolden','Thappy','Trap','Wigwam','Ttechno','Resourcehouse','Underground','Tent','Shappy','Cbuilding','Exresource','Cfloors'].indexOf(item.type) != -1) {
			giftBttn.visible = false;
			wishlistBttn.visible = false;
			placeBttn.visible = true;
			sellSprite.visible = false;
			
			if (!World.canBuilding(item.sid)) {
				placeBttn.state = Button.DISABLED;
				reason = Locale.__e('flash:1413192105251');
			}
		}
		
		if (['Energy','Luckybag'].indexOf(item.type) >= 0) {
			giftBttn.visible = false;
			wishlistBttn.visible = false;
			applyBttn.visible = true;
		}
		
		if (item.type == 'Sets') {
			giftBttn.visible = false;
			wishlistBttn.visible = false;
			sellSprite.visible = false;
			applyBttn.visible = true;
			
			giftBttn.x = applyBttn.x + applyBttn.width - giftBttn.width + 5;
		}
		
		if (item.type == 'Accelerator') {
			giftBttn.visible = false;
			wishlistBttn.visible = false;
			placeBttn.visible = false;
			sellSprite.visible = false;
			applyBttn.visible = true;
		}
		
		if (item.mtype == 3 || item.mtype == 5) {
			giftBttn.visible = false;
			wishlistBttn.visible = false;
			placeBttn.visible = false;
			sellSprite.visible = false;
		}
		
		if (item.sid == 798) {
			giftBttn.visible = false;
			wishlistBttn.visible = false;
			placeBttn.visible = false;
			sellSprite.visible = false;
		}
		
		drawCount();
		
		if (window.settings.find != null && window.settings.find.indexOf(int(item.sid)) != -1) {
			glowing();
		}
		drawTitle();
	}
	
	public function dispose():void {
		closeBttn.removeEventListener(MouseEvent.CLICK, onSellEvent);
		wishlistBttn.removeEventListener(MouseEvent.CLICK, onWishlistEvent);
		giftBttn.removeEventListener(MouseEvent.CLICK, onGiftBttnEvent);
		placeBttn.removeEventListener(MouseEvent.CLICK, onPlaceEvent);
		applyBttn.removeEventListener(MouseEvent.CLICK, onApplyEvent);
	}
	
	public function drawTitle():void {
		var text:String = "";
		
		title = Window.drawText(item.title, {
			color:0x6d4b15,
			borderColor:0xfcf6e4,
			textAlign:"center",
			autoSize:"center",
			fontSize:22,
			multiline:true
		});
		title.wordWrap = true;
		title.width = background.width - 50;
		title.y = 10;
		title.x = 25;
		addChild(title)
	}
	
	
	public function drawCount():void {
		var count:int;
		if (item.sid == 752 || item.type == 'Building' || item.type == 'Tribute') {
			if (!(App.user.stock.data[item.sid] is int)) {
				for (var level:String in App.user.stock.data[item.sid]) {
					count += App.user.stock.data[item.sid][level]; 
					//if (count > 0) break;
				}
			}
			if (!count) count = App.user.stock.data[item.sid];
		}else {
			count = App.user.stock.data[item.sid];
		}
		var countOnStock:TextField = Window.drawText('x' + count || "", {
			color:0xefcfad9,
			borderColor:0x764a3e,  
			fontSize:28,
			autoSize:"left"
		});
		
		var width:int = countOnStock.width + 24 > 30?countOnStock.width + 24:30;
		
		addChild(countOnStock);
		countOnStock.x = background.width - countOnStock.width - 14;
		countOnStock.y = background.height - countOnStock.height - 23;
	}
	
	
	public var sellSprite:Sprite = new Sprite();
	public function drawSellPrice():void {
		
		if (item.type == 'Energy')
			return;
		
		var icon:Bitmap = new Bitmap(UserInterface.textures.coinsIcon, "auto", true);
		icon.scaleX = icon.scaleY = 0.7;
		icon.x = label.width;
		icon.y = -2;

		sellSprite.addChild(icon);
		
		var label:TextField = Window.drawText(Locale.__e("flash:1382952380306"), {
			color:0x4A401F,
			borderSize:0,
			fontSize:18,
			autoSize:"left"
		});
		sellSprite.addChild(label);
		
		sellPrice = Window.drawText(String(price), {
			fontSize:20, 
			autoSize:"left",
			color:0xffdc39,
			borderColor:0x6d4b15
		});
		sellSprite.addChild(sellPrice);
		sellPrice.x = icon.x + icon.width;
		sellPrice.y = 0;
		
		addChild(sellSprite);
		
		sellSprite.x = (background.width - sellSprite.width) / 2;
		sellSprite.y = 136;
	}
	
	public function drawBttns():void {
		placeBttn = new Button( {
			caption:Locale.__e('flash:1382952380210'),
			width:109,
			hasDotes:false,
			height:37,
			fontSize:22
		});
		addChild(placeBttn);
		
		placeBttn.x = (background.width - placeBttn.width)/2;
		placeBttn.y = background.height - placeBttn.height/2 - 5;
		
		placeBttn.addEventListener(MouseEvent.CLICK, onPlaceEvent);
		
		
		applyBttn = new Button( {
			caption:Locale.__e('flash:1412930855334'),
			width:109,
			hasDotes:true,
			height:37,
			fontSize:22
		});
		addChild(applyBttn);
		
		applyBttn.x = (background.width - applyBttn.width)/2;
		applyBttn.y = background.height - applyBttn.height/2 - 5;
		
		applyBttn.addEventListener(MouseEvent.CLICK, onApplyEvent);
		
		wishlistBttn = new ImageButton(UserInterface.textures.addBttnBlue);
		wishlistBttn.tip = function():Object { 
			return {
				title:"",
				text:Locale.__e("flash:1382952380013")
			};
		};
		wishlistBttn.y -= 4;
		wishlistBttn.addEventListener(MouseEvent.CLICK, onWishlistEvent);
		
		var btnnCont:Sprite = new Sprite();
		btnnCont.addChild(wishlistBttn);
		
		
		giftBttn = new ImageButton(Window.textures.giftBttn, { scaleX:1, scaleY:1 } );
		giftBttn.tip = function():Object { 
			return {
				title:"",
				text:Locale.__e("flash:1382952380012")
			};
		};
		giftBttn.y -= 6;
		giftBttn.addEventListener(MouseEvent.CLICK, onGiftBttnEvent);
		btnnCont.addChild(giftBttn);
		
		closeBttn = new ImageButton(UserInterface.textures.sellBttn);
		btnnCont.addChild(closeBttn);
		closeBttn.tip = function():Object { 
			return {
				title:"",
				text:Locale.__e("flash:1382952380277")
			};
		};
		closeBttn.y = -2;
		closeBttn.addEventListener(MouseEvent.CLICK, onSellEvent);
		
		wishlistBttn.x = 0;
		giftBttn.x = wishlistBttn.x + wishlistBttn.width + 5;
		if (item.type == 'Decor') closeBttn.x = giftBttn.x + giftBttn.width + 25;
		else closeBttn.x = giftBttn.x + giftBttn.width + 5;
		addChild(btnnCont);
		btnnCont.x = (background.width - btnnCont.width) / 2;
		btnnCont.y = background.height - btnnCont.height / 2;
	}
	
	private function onGiftBttnEvent(e:MouseEvent):void 
	{
		new GiftWindow( {
			iconMode:GiftWindow.MATERIALS,
			itemsMode:GiftWindow.FRIENDS,
			sID:item.sid
		}).show();
		window.close();
	}
	
	private function onWishlistEvent(e:MouseEvent):void {
		App.wl.show(item.sid, e);
	}
	
	private var worlds:Array = [];
	private function onPlaceEvent(e:MouseEvent):void 
	{
		if (placeBttn.mode == Button.DISABLED) {
			if (reason.length > 0) {
				Hints.text(reason, 4, Window.localToGlobal(placeBttn));
			}
			return;
		}
		
		if (User.inExpedition && item.sid != 2105) {
			new SimpleWindow ( {
				text: Locale.__e('flash:1397124712139', [App.data.storage[item.sid].title]),
				title: Locale.__e('flash:1382952380254'),
				popup: true
			}).show();
			return;
		}
		
		if ([2371].indexOf(item.sid) != -1 && [112,1907,1569].indexOf(App.user.worldID) == -1) {
			new SimpleWindow ( {
				text: Locale.__e('flash:1397124712139', [App.data.storage[item.sid].title]),
				title: Locale.__e('flash:1382952380254'),
				popup: true,
				confirm:function():void {
					Window.closeAll();
					TravelWindow.show( { find:[1907] } );
				}
			}).show();
			return;
		}
		
		if ([1950,1961,1952].indexOf(item.sid) != -1 && App.user.worldID != 1907) {
			new SimpleWindow ( {
				text: Locale.__e('flash:1397124712139', [App.data.storage[item.sid].title]),
				title: Locale.__e('flash:1382952380254'),
				popup: true,
				confirm:function():void {
					Window.closeAll();
					TravelWindow.show( { find:[1907] } );
				}
			}).show();
			return;
		}
			
		for (var land:* in App.data.storage) {
			var itm:Object = App.data.storage[land];
			if (itm.type == 'Lands') {
				worlds.push(land);
			}
		}
		for (var id:int = 0; id < worlds.length; id++)
		{	
			var world:Object = App.data.storage[worlds[id]];
			if (!world.hasOwnProperty('stacks')) continue;
			for (var bSID:String in world.stacks) {
				if (App.user.worldID == Travel.SAN_MANSANO && worlds[id] == Travel.SAN_MANSANO && world.stacks[item.sid]) {
					if (['Golden', 'Walkgolden','Decor','Booker'].indexOf(String(App.data.storage[item.sid].type)) != -1) continue;
					new SimpleWindow( {
						label:SimpleWindow.ATTENTION,
						text:Locale.__e('flash:1397124712139', [App.data.storage[item.sid].title]),
						title:"",
						popup:true
					}).show();
					return;
				}
				if (item.sid == world.stacks[bSID] && worlds[id] != App.user.worldID && [752,2678,2679,2680,2681,2682].indexOf(int(item.sid)) == -1) {
					item['territory'] = worlds[id];
					var text:String = Locale.__e('flash:1397124712139', [App.data.storage[item.sid].title]);
					if (item.sid == 1359) text = Locale.__e('flash:1455278217820');
					new SimpleWindow( {
						label:SimpleWindow.ATTENTION,
						text:text,
						title:"",
						popup:true,
						confirm: function():void {
							Window.closeAll();
							TravelWindow.show({findTargets:[item['territory']]});
						}
					}).show();
					return;
				}
			}
		}
		
		if (App.user.worldID != 1198 && item.sid == 1255) {
			new SimpleWindow( {
				label:SimpleWindow.ATTENTION,
				text:Locale.__e('flash:1397124712139', [App.data.storage[item.sid].title]),
				title:"",
				popup:true
			}).show();
			return;
		}
		
		//if (App.user.worldID != 1198 && App.user.worldID != 2099 && App.user.worldID != 2195 && item.type == 'Firework' && item.hasOwnProperty('count') && item.count == 0 && item.sid != 1556) {
			//new SimpleWindow( {
				//label:SimpleWindow.ATTENTION,
				//text:Locale.__e('flash:1397124712139', [App.data.storage[item.sid].title]),
				//title:"",
				//popup:true
			//}).show();
			//return;
		//}
		
		if (App.user.worldID != 1569 && App.user.worldID != 1907 && App.user.worldID != 1801 && item.sid == 1556) {
			new SimpleWindow( {
				label:SimpleWindow.ATTENTION,
				text:Locale.__e('flash:1397124712139', [App.data.storage[item.sid].title]),
				title:"",
				popup:true
			}).show();
			return;
		}
		
		//if (App.user.worldID != 1198 && item.type == 'Firework' && item.hasOwnProperty('count') && item.count == 0 && item.sid == 1255) {
			//new SimpleWindow( {
				//label:SimpleWindow.ATTENTION,
				//text:Locale.__e('flash:1397124712139', [App.data.storage[item.sid].title]),
				//title:"",
				//popup:true
			//}).show();
			//return;
		//}
		
		if (!User.inExpedition && item.sid == 2105) {
			new SimpleWindow( {
				label:SimpleWindow.ATTENTION,
				text:Locale.__e('flash:1397124712139', [App.data.storage[item.sid].title]),
				title:"",
				popup:true
			}).show();
			return;
		}
		
		if (App.user.worldID != User.HOME_WORLD && item.type == 'Happy') {
			new SimpleWindow( {
				label:SimpleWindow.ATTENTION,
				text:Locale.__e('flash:1397124712139', [App.data.storage[item.sid].title]),
				title:"",
				popup:true
			}).show();
			return;
		}
		
		if (App.user.worldID != 903 && App.user.worldID != 1122 && App.user.worldID != 1371 && App.user.worldID != 767 && App.user.worldID != 1569 && App.user.worldID != 418 && App.user.worldID != 1907 && App.user.worldID != 2501 && App.user.worldID != 3060) {
			if (!canPlace(item.type) && App.user.worldID != User.HOME_WORLD) {
				new SimpleWindow( {
					label:SimpleWindow.ATTENTION,
					text:Locale.__e('flash:1397124712139', [App.data.storage[item.sid].title]),
					title:"",
					popup:true
				}).show();
				return;
			}
		}
		
		if ((item.type != 'Decor' || (item.type == 'Decor' && item.dtype != 2)) && App.user.worldID == 555) {
			if (item.sid != 553 && item.sid != 554 && item.sid != 694) {
				new SimpleWindow( {
					label:SimpleWindow.ATTENTION,
					text:Locale.__e('flash:1435246218020'),
					title:"",
					popup:true
				}).show();
				return;
			}
		}
		
		if (((item.type == 'Decor' && item.dtype == 2) || (item.sid == 553 || item.sid == 554 || item.sid == 694)) && App.user.worldID != 555) {
			new SimpleWindow( {
				label:SimpleWindow.ATTENTION,
				text:Locale.__e('flash:1435227617379', [App.data.storage[item.sid].title]),
				title:"",
				popup:true,
				confirm: goToKlide
			}).show();
			return;
		}
		
		if (['Tribute'].indexOf(item.type) != -1 && item.hasOwnProperty('count') && item.count > 0 && [815,816,817].indexOf(int(item.sid)) == -1) {
			var unts:Array = Map.findUnits([item.sid]);
			if (unts.length >= item.count) {
				new SimpleWindow( {
					label:SimpleWindow.ATTENTION,
					text:Locale.__e('flash:1449581752374'),
					title:item.title,
					popup:true
				}).show();
				return;
			}
		}
		
		var settings:Object = { sid:item.sid, fromStock:true };
		
		if (setBuildingLevel(item.type) > 0) {
			settings['level'] = setBuildingLevel(item.type);
		}
		
		var unit:Unit = Unit.add(settings);
		unit.move = true;
		App.map.moved = unit;
		window.close();
	}
	
	private function goToKlide():void {
		if (!App.user.quests.data.hasOwnProperty(216)) {
			new SimpleWindow( {
				title: Locale.__e('storage:278:title'),
				text: Locale.__e('flash:1435130693238'),
				textSize: 32,
				popup:true
			}).show();
			return;
		}
		Travel.goTo(555);
		StockWindow.needToOpen = item.sid;
		window.close();
	}
	
	private function setBuildingLevel(type:String):int {
		//switch(type){
			//case 'Hut':
					//return 1;
				//break;
		//}
		return 0;
	}
	
	private function canPlace(type:String):Boolean
	{
		var isCan:Boolean = true;
		switch(type) {
			case 'Animal':
			case 'Techno':
			case 'Building':
			case 'Mining':
			case 'Storehouse':
			case 'Factory':	
			case 'Moneyhouse':	
			case 'Trade':	
			case 'Field':
			case 'Tradesman':
			case 'Walkgolden':
				var placeAnyway:Boolean = ['365','178','312','694','1092'].indexOf(String(item.sid)) != -1;
				isCan = placeAnyway || true;
			break;
		}
		return isCan;
	}
	
	
	private function onApplyEvent(e:MouseEvent):void {
		if (item.type == 'Energy'|| item.type == 'Vip') {
			
			App.user.stock.charge(item.sid);
			if (item.type == 'Vip') {
				applyBttn.state = Button.DISABLED;
			}else if (item.out == 1529) {
				window.close();
				new SimpleWindow( {
					title: Locale.__e('flash:1382952379828'),
					text: Locale.__e('flash:1456311507472'),
					popup: true
				}).show();
			}else {
				flyMaterial(Stock.FANTASY);
				window.refresh();
			}
				
			return;
		}
		
		if (item.type == 'Sets') {
			App.user.stock.unpack(item.sid, function(data:Object):void {
				App.user.stock.take(item.sid, 1);
				
				var targetPoint:Point = Window.localToGlobal(applyBttn);
				targetPoint.y += applyBttn.height / 2;
				for (var _sID:Object in data)
				{
					var sID:uint = Number(_sID);
					var item:*;
					
					item = new BonusItem(sID, data[_sID]);
					App.user.stock.add(sID, data[_sID]);	
					item.cashMove(targetPoint, App.self.windowContainer)		
				}
				SoundsManager.instance.playSFX('reward_1');
			});
		}
		
		if (item.type == 'Accelerator') {
			window.close();
			var sIDs:Array = [];
			for (var it:* in item.targets) {
				for (var id:* in App.data.storage) {
					if (item.hasOwnProperty('delete')) {
						if (App.data.storage[id].type == item.targets[it] && item['delete'].indexOf(id) == -1){
							sIDs.push(id);
						}
					}else {
						if (App.data.storage[id].type == item.targets[it]){
							sIDs.push(id);
						}
					}
				}
			}
			StockWindow.accelUnits = Map.findUnits(sIDs);
			for each (var target:* in StockWindow.accelUnits) {
				if (target.info.type == 'Tribute') {
					if (target.started > 0 && target.started > App.time)
						target.showGlowing();
				} else {
					if (target.crafted > 0 && target.crafted > App.time)
						target.showGlowing();
				}
			}
			Cursor.material = item.sid;	
			Cursor.accelerator = true;
			StockWindow.accelMaterial = item.sid;
			return;
		}
		
		if (item.type == 'Luckybag') {		
			window.close();
			App.user.stock.unpackLuckyBag(item.sid, onLuckybag, function():void {
				//window.blokItems(true);
			});
			return;
		}
		
		if (item.type == 'Food') {
			var items:Array = Map.findUnits([160, 461]);
			var huts:Array = [];
			
			var countHungry:int = 0;
			var countFull:int = 0;
			
			for each (var itm:* in items) {
				var time:int = itm.workers[0].worker.finished - App.time;
				var premTime:int = 0;
				if (itm.food != 0)  premTime = itm.food - App.time;
				if (time > 0 && premTime <= 0) {
					huts.push( {time:time, hut:itm } );
				} else {
					if (time <= 0) countHungry++;
					if (premTime > 0) countFull++;
				}
			}
			
			huts.sortOn(['time'], [Array.DESCENDING]);
			var hut:*;
			if (huts.length == 0) {
				if (countHungry == items.length) {
					new SimpleWindow( {
						title: Locale.__e('flash:1382952379828'),
						text: Locale.__e('flash:1436954543116'),
						popup: true,
						confirm: function():void {
							Window.closeAll();
							new TechnoManagerWindow().show();
						}
					}).show();
				} else if (countFull == items.length) {
					new SimpleWindow( {
						title: Locale.__e('flash:1382952379828'),
						text: Locale.__e('flash:1436954683396'),
						popup: true
					}).show();
				}
				return;
			}else {
				hut = huts[0].hut;
			}
			
			Window.closeAll();		
			
			var sidKettle:uint = 672;
			
			switch (item.sid) {
				case 658:
					sidKettle = 672;
					break;
				case 659:
					sidKettle = 673;
					break;
				case 660:
					sidKettle = 674;
					break;
				default: 
					sidKettle = 672;
					break;
			}
			
			var energyObject:Object = {
				foodID: item.sid
			}
			
			var food:Unit = Unit.add( { sid:sidKettle, buy:false,  energyObject:energyObject, callback:hut.goOnPremiumFeed } );
			food.move = true;
			App.map.moved = food;			
		}
	
	}
	
	private function onLuckybag(bonusArray:Object = null):void {				
		var targetPoint:Point = new Point(0, 0);
		BonusItem.takeRewards(bonusArray, targetPoint, 0);		
	}
	
	private function onSellEvent(e:MouseEvent):void {
		new SellItemWindow( { 
			sID:item.sid, 
			callback:function():void {
				window.refresh();
			}
		}).show();
	}
	
	public function onPreviewComplete(data:Bitmap):void
	{
		removeChild(preloader);
		bitmap.bitmapData = data.bitmapData;
		bitmap.smoothing = true;
		
		if (bitmap.width > background.width - 40) {
			bitmap.width = background.width - 40;
			bitmap.scaleY = bitmap.scaleX;
			if (bitmap.height > background.height - 60) {
				bitmap.height = background.height - 60;
				bitmap.scaleX = bitmap.scaleY;
			}
		}
		
		bitmap.x = (background.width - bitmap.width) / 2;
		bitmap.y = (background.height - bitmap.height) / 2;
		
	}
	private function glowing():void {
		if (window.settings.hasOwnProperty('findEvent'))
		{
			switch(window.settings.findEvent) {
				case 'gift':
						customGlowing(giftBttn,null);	
					break;
				case 'sell':
						customGlowing(closeBttn,null);	
					break;
			}
		}
		
		customGlowing(background, glowing);
	}
	
	private function customGlowing(target:*, callback:Function = null):void {
		TweenMax.to(target, 1, { glowFilter: { color:0xFFFF00, alpha:0.8, strength: 7, blurX:12, blurY:12 }, onComplete:function():void {
			TweenMax.to(target, 0.8, { glowFilter: { color:0xFFFF00, alpha:0.6, strength: 7, blurX:6, blurY:6 }, onComplete:function():void {
				if (callback != null) {
					callback();
				}
			}});	
		}});
	}	
	
	private function flyMaterial(sID:uint):void
	{
		var item:BonusItem = new BonusItem(sID, 0);
		
		var point:Point = Window.localToGlobal(bitmap);
		item.cashMove(point, App.self.windowContainer);
	}
	
}