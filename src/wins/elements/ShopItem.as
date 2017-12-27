package wins.elements 
{
	import buttons.Button;
	import buttons.ImageButton;
	import buttons.MoneyButton;
	import buttons.SimpleButton;
	import com.greensock.TweenMax;
	import core.IsoConvert;
	import core.Load;
	import core.Log;
	import core.Numbers;
	import core.Post;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.utils.setTimeout;
	import ui.Cursor;
	import ui.Hints;
	import ui.UserInterface;
	import units.Anime;
	import units.Building;
	import units.Character;
	import units.Factory;
	import units.Field;
	import units.Plant;
	import units.Sphere;
	import units.Techno;
	import units.Unit;
	import units.WorkerUnit;
	import wins.elements.PriceLabel;
	import wins.ErrorWindow;
	import wins.HeroWindow;
	import wins.PurchaseWindow;
	import wins.ShopWindow;
	import wins.SimpleWindow;
	import wins.TravelWindow;
	import wins.UndergroundWindow;
	import wins.Window;
	import wins.WorldsWindow;

	public class ShopItem extends LayerX {
		
		public var item:*;
		public var background:Bitmap;
		public var bitmap:Bitmap;
		public var title:TextField;
		public var priceBttn:Button;
		private var infoBttn:Button;
		public var openBttn:MoneyButton;
		public var window:*;
		
		public var moneyType:String = "coins";
		public var previewScale:Number = 1;
		
		public var onBuyAction:Function;
		
		private var needTechno:int = 0;
		public var countOnMap:int = 0;
		
		private var preloader:Preloader = new Preloader();
		
		public function ShopItem(item:*, window:*) {
			
			this.item = item;
			this.window = window;
			
			if (item.sid == 160)
				trace();
			
			var backing:String = 'itemBacking';
			
			if (item.hasOwnProperty('backview') && item.backview != '')
				backing = item.backview;
			
			if (item.backview == 'G' || item.backview == 'Gold')
				backing = 'itemBacking';
			
			if (item.sid == 461) backing = 'itemBackingGreen';
			
			background = Window.backing(170, 210, 10, backing);
			
			addChildAt(background, 0);
			
			sprite = new LayerX();
			addChild(sprite);
			
			bitmap = new Bitmap();
			sprite.addChild(bitmap);
			sprite.mouseChildren = false;
			sprite.mouseEnabled = false;
			if(item.view=='spring'){
				trace(item.view);
			}
			
			var totalLevels:int = (item.devel) ? Numbers.countProps(item.devel.req) : 0;
			var defText:String = '';
			var prevItm:String;
			/*if (item.devel) {
				for each(var obj:* in item.devel.req) {
					totalLevels++;
				}
			}*/
			
			
			// Cbuilding потомки
			if (item.attachTo) {
				if (item.attachTo.length > 0) {
					var list:Array = Map.findUnits(item.attachTo);
					for (var i:int = 0; i < list.length; i++) {
						if (list[i].slotsCount > list[i].slotsBusy) {
							onBuyAction = list[0].buyItem;
							break;
						}
					}
				}
				
				// Если функция возврата не заполнена - ничего не рисовать
				if (onBuyAction == null) {
					load();
					return;
				}
			}
			
			
			if((item.type == 'Building' || item.type == 'Tstation') && item.devel.craft){
				for (var itm:String in item.devel.craft[totalLevels]) {
					if (!App.data.crafting.hasOwnProperty(item.devel.craft[totalLevels][itm])) continue;
					if (prevItm && prevItm == App.data.storage[App.data.crafting[item.devel.craft[totalLevels][itm]].out].title) break;
					if (!User.inUpdate(App.data.crafting[item.devel.craft[totalLevels][itm]].out)) break;
					if (defText.length > 0) defText += ', ';
					defText += App.data.storage[App.data.crafting[item.devel.craft[totalLevels][itm]].out].title;
					prevItm = App.data.storage[App.data.crafting[item.devel.craft[totalLevels][itm]].out].title;
				}
			}
			
			if (defText.length > 0) {
				tip = function():Object {
					if (item.sid == 668 || item.sid == 738 || item.sid == 749 || item.sid == 1010) {
						return {
							title:item.title,
							text:item.description
						};
					}
					return {
						title:item.title,
						text:Locale.__e('flash:1404823388967', [defText])
					};
				};
			} else {
				tip = function():Object 
				{
					/*if (item.type == "Decor")
					{
						return {
							title:item.title,
							text:Locale.__e("flash:1382952380076", [String(item.experience)])
						};
					}else*/{
						return {
							title:item.title,
							text:item.description
						};
					}
				};
			}
			
			drawTitle();
			
			load();
			
			var short:Boolean = false;
			if (item.type == "Material" && item.sid != 852 && item.sid != 2215)
				short = true;
			
			
			
			countOnMap = World.getBuildingCount(item.sid);
			if (item.hasOwnProperty('instance') && !item.attachTo) 
			{
				countOnMap = Storage.instanceGet(item.sid);
			}else 
			{
				countOnMap = World.getBuildingCount(item.sid);
			}
			
			if (item.hasOwnProperty('instance') && App.user.stock.data && App.user.stock.data.hasOwnProperty(item.sid) /*&& item.type == 'Building'*/) 
			{
				countOnMap += App.user.stock.count(item.sid);
			}
			
			//countOnMap = 0;
			
			var countUnits:Array;
			var data:Object;
			if ([738,749,797,815,816,817,935,980,981,982,1002,1012,1193,1302,1845,1868,1658,1969,2201,2371,2641,2642,2732].indexOf(int(item.sid)) != -1) {
				countUnits = [];
				countUnits = Map.findUnits([int(item.sid)]);
				countOnMap = countUnits.length;
			}
			
			if ([/*'Tribute',*/'Fatman'].indexOf(item.type) != -1) {
				countUnits = [];
				countUnits = Map.findUnits([int(item.sid)]);
				countOnMap = countUnits.length;
			}
			
			//App.user.storageStore('building_2284', 0, true);
			if ([797,815,816,817,935,980,981,982,1012,1193,1302,1845,1868,1658,1969,2013,2201,2371,2641,2642,2732].indexOf(int(item.sid)) != -1) {
				data = App.user.storageRead('building_' + item.sid, 0);
				if (int(data) > countUnits.length)
					countOnMap = int(data);
				else 
					countOnMap = countUnits.length;
			}
			
			if (['Fatman'].indexOf(item.type) != -1) {
				data = App.user.storageRead('building_' + item.sid, 0);
				if (int(data) > countUnits.length)
					countOnMap = int(data);
				else 
					countOnMap = countUnits.length;
			}
			
			if (App.user.quests.data.hasOwnProperty(516) && App.user.quests.data[516].finished != 0 && int(item.sid) == 1444) {
				countOnMap = 1;
			}
			
			if (short) {
				if (item.collection) {
					drawText(Locale.__e('flash:1405680422898'));
				}
			}else if ((([738,749,815,816,817,797,835,1002,1845,1868,1658,1969,2201].indexOf(int(item.sid)) != -1  || ['Fatman'].indexOf(item.type) != -1) && item.hasOwnProperty('instance') && (countOnMap + App.user.stock.count(item.sid)) >= getInstanceNum()) || ([935,980,981,982,1012,1193,1302,1658,2201,2371,2641,2642,2732].indexOf(int(item.sid)) != -1 && (countOnMap + App.user.stock.count(item.sid)) >= getInstanceNum())) {  
				drawTextBought();
				drawCountBuild();
			}else if (['Tribute'].indexOf(item.type) != -1 && item.hasOwnProperty('count') && item.count > 0 && item.count <= countOnMap) {
				drawTextBought();
				drawCountBuild();
			}else if (/*['Building'].indexOf(item.type) != -1 && App.user.worldID == Travel.SAN_MANSANO && item.hasOwnProperty('gcount') &&*/ item.gcount > 0 && !Storage.shopLimitCanBuy(item.sid)) {
				drawTextBought();
				drawCountBuild();
			}else if (item.type != 'Garden' && item.type != 'Building' && item.type != 'Rbuilding' && item.type != 'Tribute' && item.type != 'Technological' && item.sid != 797 /*&& item.sid != 1478*/ && item.hasOwnProperty('instance') && (countOnMap + App.user.stock.count(item.sid)) >= getInstanceNum() && forCurrentTerritory()) {  
				drawTextBought();
				drawCountBuild();
			}else if (item.hasOwnProperty('instance') && !isItemAvailableByLevel(item, countOnMap) && !App.user.shop.hasOwnProperty(item.sid)) {
				drawNeedTxt(item.instance.level[availableFromLvl], 10, 190);
				drawOpenBttn(availableFromLvl);
			} else if (item.type == 'Minigame' && App.user.level < item.level && !App.user.shop.hasOwnProperty(item.sid)) {
				drawNeedTxt(item.level, 10, 190);
				//drawOpenBttn(availableFromLvl);
			} else if (item.hasOwnProperty('instance') && App.user.level < item.instance.level[countOnMap + 1] && App.user.shop[item.sid] != countOnMap + 1) {
				if (App.user.shop.hasOwnProperty(item.sid) && App.user.shop[item.sid] >= countOnMap + 1) {
					drawPriceBttn();
				} else if (item.instance.p && item.instance.p[countOnMap + 1]) {
					if (item.instance.level[countOnMap + 1] != null)
					{
							drawNeedTxt(item.instance.level[countOnMap + 1], 10, 190);
							drawOpenBttn(countOnMap + 1);
					}
				}else 
				{
					drawNeedTxt(item.instance.level[countOnMap + 1], 10, 196);
					drawCountBuild();
				}	
				
			}else if (App.user.shop && !App.user.shop.hasOwnProperty(item.sid) && (item.type == 'Resource' || item.type == 'Decor' || item.type == "Golden" || item.type == 'Plant' || item.type == 'Tree' || item.type == 'Animal') && item.level > App.user.level) {
				drawNeedTxt(item.level, 7, 24, openSprite);
				drawOpenBttn(item.sid);
			}else if (item.type == 'Character'){
				var buyed:Boolean = false;
				if (App.user.characters.length > 0) {
					for each(var _char:Character in App.user.characters) {
						if (_char.sid == item.sid) {
							buyed = true;
						}
					}
				}
				if (App.user.arrHeroesInRoom.indexOf(item.sID) != -1 || App.user.stock.count(item.sID) > 0) {
					buyed = true;
				}
				
				if(buyed)
					drawTextBought();
				else
					drawPriceBttn();
					
			}else if (item.collection) {
				drawText(Locale.__e('flash:1405680422898'));
			}else if (item.type == 'Vip') {
				drawVipUI();
			}else {
				if(item.type!='Collection' && item.type != "Pack"){
					drawPriceBttn();
				}
			}
			
			
			if (ShopWindow.lockInThisWorld.indexOf(int(item.sid)) != -1) {
				closed = true;
				return;
			}
			
			if (item.type == 'Goldbox' && item.hasOwnProperty('outs')) {
				drawOuts();
			}
			
			if (window.settings.find != null && window.settings.find.indexOf(int(item.sid)) != -1) {
				glowing();
			}
			
			if (ShopWindow.shop && ShopWindow.shop[100] && ShopWindow.shop[100].data && ShopWindow.shop[100].data.indexOf(item.sid) != -1) {
				setNew();
			}
			
			if (item.type == 'Golden' || item.type == 'Gamble' || item.type == 'Walkgolden') {
				setGold();
			}
			if (item.type == 'Golden' || item.type == 'Walkgolden') {
				drawTimeField();
			}
			
			if (item.type == 'Gamble' && App.isSocial('YB','MX','AI')) {
				drawHelp();
			}
			
			if (item.hasOwnProperty('expire') && item.expire.hasOwnProperty(App.social) && item.type != 'Fatman') {
				if (item.expire[App.social] > App.time) {
					drawTimer();
				} else {
					if (priceBttn) priceBttn.state = Button.DISABLED;
				}
			}
		}
		
		private function load():void {
			addChild(preloader);
			preloader.x = (background.width)/ 2;
			preloader.y = (background.height)/ 2 - 15;
			
			if (item.type == "Golden" || item.type == 'Thimbles' || item.type == 'Gamble' || item.type == 'Fatman') {
				Load.loading(Config.getSwf(item.type, item.view), onAnimComplete);
			}else {
				if (item.type == 'Plant') {
					var out:Object = Plant.materialObject(item.sid);
					if (out) Load.loading(Config.getIcon(out.type, out.preview), onPreviewComplete);
				}else{
					Load.loading(Config.getIcon(item.type, item.preview), onPreviewComplete);
				}
			}
		}
		
		/*public function get countOnMap():int {
			var count:int = World.getBuildingCount(item.sid);
			if (item.hasOwnProperty('instance') && !item.attachTo) {
				count = App.user.instance[item.sid] || 0;
			}else {
				count = World.getBuildingCount(item.sid);
			}
			
			if (item.hasOwnProperty('instance') && App.user.stock.data && App.user.stock.data.hasOwnProperty(item.sid)) {
				count += App.user.stock.count(item.sid);
			}
			
			return count;
		}*/
		
		private function forCurrentTerritory():Boolean {
			var world:Object;
			var id:int;
			var bSID:String;
			for (id = 0; id < App.user.lands.length; id++) {
				world = App.data.storage[App.user.lands[id]];
				if (!world.hasOwnProperty('objects')) continue;
				for (bSID in world.objects) {
					if (int(item.sid) == int(world.objects[bSID])) {
						item['territory'] = App.user.lands[id];
						if (item.visible == 0) continue;
						
						if (App.user.worldID != App.user.lands[id]) {
							return false;
						}
					}
				}
			}
			var itemsWithFind:Array = JSON.parse(App.data.options.ItemsWithFindButton) as Array;
			if (itemsWithFind.indexOf(int(item.sid)) != -1) {
				return false;
			}
			return true;
		}
		
		private var timerText:TextField;
		private function drawTimer():void {
			if (item.type == 'Happy') {
				var tID:int = 0;
				for (var topID:* in App.data.top) {
					if (App.data.top[topID].target == item.sid) {
						tID = topID;
						break;
					}
				}
				if (tID == 0) return;
			}
			timerText = Window.drawText(TimeConverter.timeToStr(item.expire[App.social] - App.time), {
				color: 0xfff200,
				borderColor: 0x680000,
				fontSize: 26,
				textAlign: 'center',
				width: background.width
			});
			timerText.y = title.y + title.textHeight + 5;
			addChild(timerText);
			App.self.setOnTimer(updateTimer);
		}
		
		private function updateTimer():void {
			if (timerText) {
				var text:String = TimeConverter.timeToStr(item.expire[App.social] - App.time);
				timerText.text = text;
				
				if (item.expire[App.social] - App.time <= 0) {
					timerText.visible = false;					
					App.self.setOffTimer(updateTimer);
					
					priceBttn.state = Button.DISABLED;
				}
			}
		}
		
		private var availableFromLvl:int = 0;
		private function isItemAvailableByLevel(item:*, countOnMap:int = -1):Boolean
		{
			if (countOnMap != -1) {
				if (item.instance.level[countOnMap + 1] > App.user.level) {
					availableFromLvl = countOnMap + 1;
					return false;
				}
				return true;
			}
			for (var lvl:* in item.instance.level) {
				if (item.instance.level[lvl] > App.user.level) {
					availableFromLvl = lvl;
					return false;
				}
			}
			return true;
		}
		
		private function drawHelp():void {
			var searchBttn:ImageButton = new ImageButton(UserInterface.textures.lens);
			addChild(searchBttn);
			searchBttn.x = 130;
			searchBttn.y = 10;
			searchBttn.addEventListener(MouseEvent.CLICK, showHelp);
		}
		
		private function showHelp(e:MouseEvent):void {
			var text:String;
			if (item.sid == 483)
				text = Locale.__e('flash:1449649687794');
			else if (item.sid == 976) {
				text = Locale.__e('flash:1449649890043');
			}else if (item.sid == 2018) {
				text = Locale.__e('flash:1465828699513');
			}
			new SimpleWindow( {
				width:450,
				height:600,
				label:SimpleWindow.ATTENTION,
				text:text,
				title:item.title,
				popup:true
			}).show();
			return;
		}
		
		private function drawVipUI():void 
		{
			if (App.user.stock.data.hasOwnProperty(item.sid) && App.user.stock.data[item.sid] > App.time) {
				boughtText = Window.drawText('', {
					color:0xfff2dd,
					borderColor:0x7a602f,
					borderSize:4,
					fontSize:24,
					textAlign:'center',
					width:background.width - 20
				});
				boughtText.x = (background.width - boughtText.width) / 2;
				boughtText.y = background.height - boughtText.textHeight - 20;
				addChild(boughtText);
				App.self.setOnTimer(vipTimer);
				vipTimer();
				
				if (!hasEventListener(Event.REMOVED_FROM_STAGE))
					addEventListener(Event.REMOVED_FROM_STAGE, onRemoveFromStage);
				
			}else {
				if (boughtText) {
					removeChild(boughtText);
					boughtText = null;
				}
				drawPriceBttn();
				App.self.setOffTimer(vipTimer);
			}
		}
		private function vipTimer():void {
			var time:int = App.user.stock.data[item.sid] - App.time;
			if (time <= 0) {
				drawVipUI();
			}else{
				boughtText.text = TimeConverter.timeToStr(time);
			}
		}
		
		private function onRemoveFromStage(event:Event):void {
			if (item.type == 'Vip') {
				App.self.setOffTimer(vipTimer);
			}
		}
		
		private function drawOuts():void 
		{
			for (var key:* in item.outs) {
				break;
			}
			
			var cont:LayerX = new LayerX();
			var iconOut:Bitmap = new Bitmap();
			addChild(cont);
			cont.addChild(iconOut);
			
			cont.tip = function():Object { 
				return {
					title:App.data.storage[key].title,
					text:App.data.storage[key].description
				};
			}
			
			var txtCount:TextField = Window.drawText("x" + String(item.capacity), {
				color:0xffffff,
				borderColor:0x2b2929,
				textAlign:"center",
				autoSize:"center",
				fontSize:24
			});
			txtCount.width = txtCount.textWidth;
			
			priceLabel.y += 8;
			
			Load.loading(Config.getIcon(App.data.storage[key].type, App.data.storage[key].preview), function(data:*):void {
				iconOut.bitmapData = data.bitmapData;
				iconOut.scaleX = iconOut.scaleY = 0.36;
				iconOut.smoothing = true;
				
				iconOut.x = background.width - iconOut.width - 44;
				iconOut.y = background.height - iconOut.height/2 - 66;
				
				txtCount.x = iconOut.x + iconOut.width;
				txtCount.y = iconOut.y + (iconOut.height - txtCount.textHeight) / 2;
				addChild(txtCount);
			});
		}
		
		private function onAnimComplete(swf:*):void 
		{
			removeChild(preloader);
			
			var anime:Anime = new Anime(swf, { w:background.width - 20, h:background.height - 40 } );
			if (item.sid == 793 || item.sid == 869 || item.sid == 944 || item.sid == 945) anime.scaleX = anime.scaleY = 0.6;
			if (item.sid == 1005) anime.scaleX = anime.scaleY = 0.8;
			if (item.sid == 1004) anime.scaleX = anime.scaleY = 0.9;
			anime.x = (background.width - anime.width) / 2;
			anime.y = (background.height - anime.height) / 2;
			if (item.sid == 1004) {
				anime.x += 10;
				anime.y -= 15;
			}
			sprite.addChild(anime);
		}
		
		private function drawText(text:String):void 
		{
			var txt:TextField = Window.drawText(text, {
				color:0xc42f07,
				fontSize:22,
				borderColor:0xfcf5e5,
				textAlign:"center",
				borderSize:3,
				autoSize:'center'
			});
			
			txt.wordWrap = true;
			txt.width = 145;
			txt.height = txt.textHeight;
			addChild(txt);
			txt.x = (background.width - txt.width) / 2;
			txt.y = background.height - txt.textHeight - 28;
			
			if (txt.textHeight > 30) txt.y += 15;
		}
		
		public function setGold():void {
			var newStripe:Bitmap = new Bitmap(Window.textures.goldRibbon);
			newStripe.x = 2;
			newStripe.y = 3;
			
			addChildAt(newStripe,1);
		}
		
		public function setNew():void {
			var newStripe:Bitmap = new Bitmap(Window.textures.stripNew);
			newStripe.x = 2;
			newStripe.y = 3;
			addChild(newStripe);
		}
		
		private function drawTimeField():void {
			var container:Sprite = new Sprite();
			addChild(container);
			var icon:Bitmap = new Bitmap(Window.textures.timerSmall);
			container.addChild(icon);
			var time:TextField = Window.drawText(int(item.time/3600)+Locale.__e('flash:1382952379728'),{
				color:			0x6d4b15,
				borderColor:	0xfcf6e4,
				fontSize:		16,
				textAlign:		'left'
			});
			container.addChild(time);
			
			time.x = icon.width;
			time.y = (icon.height - time.textHeight) / 2;
			time.width = time.textWidth + 5;
			
			container.x = background.width - container.width - 15;
			container.y = title.y + title.height;
		}
		
		private function getInstanceNum():int
		{
			if (item.hasOwnProperty('count') && item.count != '' && item.count != 0) return item.count;
			if (item.hasOwnProperty('gcount') && item.gcount != '' && item.gcount != 0) return item.gcount;
			if ([738, 749].indexOf(int(item.sid)) != -1) return 3;
			if ([1353,1354,1355,1356,1357].indexOf(int(item.sid)) != -1) return 2;
			if ([815,816,817,1193].indexOf(int(item.sid)) != -1) return (item.hasOwnProperty('count') && item.count != '' && item.count != 0) ? item.count : 2;
			if ([825, 935, 980, 981, 982, 1002,1012,1302,1845,1868,1658,1969,2201,2371].indexOf(int(item.sid)) != -1) return 1;
			if (['Fatman','Technological'].indexOf(item.type) != -1) return 1;
			var count:int = 0;
			for each(var inst:* in item.instance['level']) {
				count++;
			}
			return count;
		}
		
		private function setLabel(type:String):void {
			
			var text:String = '';
			var textSettings:Object = {
				color:0x4A401F,
				borderColor:0xfcf6e4,
				borderSize:4,
				fontSize:20,
				textAlign:"center",
				multiline:true
			}
			switch(type) {
				case 'Collection':
					text = Locale.__e('flash:1382952380077');
					textSettings['fontSize'] = 22;
					textSettings['color'] = 0x4683a6;
					break;
				case 'Dreams':
					textSettings['fontSize'] = 22;
					textSettings['color'] = 0x5c9e5a;
					text = Locale.__e('flash:1382952380078');
					break;	
			}
			
			var label:TextField = Window.drawText(text, textSettings);
			addChild(label);
			label.wordWrap = true;
			label.width = background.width - 20
			label.x = 10;
			label.y = 140;
		}
		
		
		
		private var _closed:Boolean = false;
		private function set closed(value:Boolean):void {
			_closed = value;
			if (_closed)
			{
				bitmap.alpha = 0.5;
				if (openSprite) openSprite.visible = false;
				if (priceBttn) priceBttn.visible = false;
				if (openBttn) openBttn.visible = false;
				if (priceLabel) priceLabel.visible = false;
				if (needed) needed.visible = false;
				drawClosedLabel();
			}
		}
		
		private function drawClosedLabel():void 
		{
			/*var label:TextField = Window.drawText(Locale.__e("flash:1382952380079"), {
				color:0x4A401F,
				borderColor:0xfcf6e4,
				borderSize:4,
				fontSize:20,
				textAlign:"center",
				multiline:true
			});
			addChild(label);
			label.wordWrap = true;
			label.width = background.width - 20;
			label.height = label.textHeight + 5;
			label.x = 10;
			label.y = 125;*/
			
			infoBttn = new Button( {
				caption: Locale.__e("flash:1405687705056"),
				width:130,
				height:40,
				fontSize:24,
				radius:20,
				hasDotes:false,
				bgColor:			[0xf28102,0xca6e04],
				//borderColor:		[0xf89626,0xb05e00]
				bevelColor:			[0xf89626,0xb05e00]
			});
			addChild(infoBttn);
			infoBttn.x = (background.width - infoBttn.settings.width) / 2;
			infoBttn.y = background.height - infoBttn.height +15;
			infoBttn.addEventListener(MouseEvent.CLICK, onInfoClick);
		}
		private function onInfoClick(e:MouseEvent):void {
			var worldsWhereEnable:Array = [];
			for each (var s:* in App.self.allWorlds) {
				if (App.data.storage[s].hasOwnProperty('shop')) {
					for (var shopNode:String in App.data.storage[s].shop) {
						if (App.data.storage[s].shop[shopNode].hasOwnProperty(item.sID) && App.data.storage[s].shop[shopNode][item.sID] == 1)
							worldsWhereEnable.push(s);
					}
				}
			}
			
			new WorldsWindow( {
				title: Locale.__e('flash:1415791943192'),
				sID:	item.sID,
				only:	worldsWhereEnable,
				popup:	true,
				window:	window
			}).show();
		}
		
		private function get closed():Boolean {
			return _closed;
		}
		
		private var dY:int = -22;
		public function onPreviewComplete(data:Bitmap):void
		{
			removeChild(preloader);
			var centerY:int = 90;
			
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
			
			if (item.type == 'Golden')
				goldenCollectionIcon();
				
			if (item.type == 'Plant' || item.type == 'Animal') {
				bitmap.y -= 10;
			}
		}
		private function goldenCollectionIcon():void {
			var sid:int;
			var btm:Bitmap = new Bitmap(Window.textures.giftBttn);
			var bonus:Object = App.data.treasures[item.shake];
			var tips:Object = {
				title:"",
				text:Locale.__e("flash:1396002489532")
			}		
			for each (var item:* in bonus)
			{
				for (var innerItem:* in item.item)
				{
					sid = item.item[innerItem];
					if ((App.data.storage[sid].type != "Collection") &&
						(App.data.storage[sid].mtype != 3)) {
							btm.bitmapData = Window.textures.giftBttn;
							tips.text = Locale.__e("flash:1404910191257");
							break;
					}
				}
			}
			var contGolden:LayerX = new LayerX();
			contGolden.addChild(btm);
			var label:TextField ;
			/*if (this.item.sID == 558 || this.item.sID == 559 || this.item.sID == 560 || this.item.sID == 561)
			{
				var count:int = (App.data.treasures[this.item.treasure])[this.item.treasure].rcount;
				label = Window.drawText("x" + String(count), {
				color:0xffffff,
				borderColor:0x2b2929,
				textAlign:"center",
				autoSize:"center",
				fontSize:22
				});
				label.x = btm.x - label.width +12;
				label.y = btm.y + (btm.height - label.height) / 2 + 8;
				
				contGolden.addChild(label);
				btm.scaleX = btm.scaleY = 0.8;
			}*/
			addChild(contGolden);
			contGolden.x = background.width - contGolden.width + 5;
			contGolden.y = background.height - contGolden.height - 32;
			contGolden.tip = function():Object { 
				return {
					title:tips.title,
					text:tips.text
				};
			}
		}
		
		public function dispose():void {
			if(priceBttn != null){
				priceBttn.removeEventListener(MouseEvent.CLICK, onBuyEvent);
			}
			if(openBttn != null){
				openBttn.removeEventListener(MouseEvent.CLICK, onOpenEvent);
			}
			if (infoBttn != null) {
				infoBttn.removeEventListener(MouseEvent.CLICK, onInfoClick);
			}
			
			if (Quests.targetSettings != null) {
				Quests.targetSettings = null;
				if (App.user.quests.currentTarget == null) {
					QuestsRules.getQuestRule(App.user.quests.currentQID, App.user.quests.currentMID);
				}
			}
			
			if (hasEventListener(Event.REMOVED_FROM_STAGE))
				removeEventListener(Event.REMOVED_FROM_STAGE, onRemoveFromStage);
		}
		
		public function drawTitle():void {
			title = Window.drawText(String(item.title), {
				color:0x814f31,
				borderColor:0xfaf9ec,
				textAlign:"center",
				autoSize:"center",
				fontSize:23,
				textLeading:-6,
				multiline:true,
				wrap:true,
				width:background.width - 20
			});
			title.y = 10;
			title.x = (background.width - title.width)/2;
			addChild(title);
		}
		
		public function drawBuyedLabel():void {
			var label:TextField = Window.drawText(Locale.__e("flash:1382952380080"), {
				color:0x4A401F,
				borderSize:0,
				fontSize:14,
				autoSize:"center"
			});
			addChild(label);
			label.x = (background.width - label.width)/2;
			label.y = 152;
		}
		
		public var priceLabel:PriceLabelShop;
		private var worlds:Array = [];
		private var canShow:Boolean = true;
		public function drawPriceBttn():void 
		{
			var countInstance:int = 0;
			var count:int = 0;
			
			var icon:Bitmap;
			var price:int = 0;
			var settings:Object = { fontSize:16, autoSize:"center" };
			var bttnSettings:Object = {
				caption:Locale.__e("flash:1382952379751"),
				fontSize:27,
				width:136,
				height:42,
				hasDotes:false
			};
			var sidColor:int = 0;
			var countCurrency:int = 0;
			var bttnFind:Button;
			
			if (item.hasOwnProperty('target') && item.target != '' && item.type == 'Decor') {
				if (int(item.target) > 0) {
					if (!App.user.stock.check(item.target, 1)) {
						canShow = false;
						bttnFind = new Button({
							caption			:Locale.__e("flash:1405687705056"),
							fontSize		:18,
							radius      	:10,
							fontColor:		0xffffff,
							fontBorderColor:0x475465,
							borderColor:	[0xfff17f, 0xbf8122],
							bgColor:		[0x75c5f6,0x62b0e1],
							bevelColor:		[0xc6edfe,0x2470ac],
							width			:110,
							height			:35,
							fontSize		:15
						});
						bttnFind.x = background.x + background.width / 2 - bttnFind.width / 2;
						bttnFind.y = 185;
						bttnFind.addEventListener(MouseEvent.CLICK, onFind);
						addChild(bttnFind);
						return;
					}
				}
			}
			
			if (item.hasOwnProperty('unlock')) {
				priceLabel = new PriceLabelShop( { 3:item.unlock.price });
				count = 133;
				countCurrency = item.unlock.price[Stock.FANT];
			}else if (item.hasOwnProperty('price') && item.type != 'Food') {
				if (item.price.hasOwnProperty('count') && item.price.hasOwnProperty('item')) {
					var object:Object = { };
					for (var s:* in item.price.item) {
						object[item.price.item[s]] = item.price.count[s];
						if (count == 0) count = item.price.count[s];
						countCurrency = item.price.count[s];
					}
					
					priceLabel = new PriceLabelShop(object);
				}else{
					priceLabel = new PriceLabelShop(item.price);
					for each (count in item.price) break;
					for (var sd:* in item.price) {
						sidColor = sd;
						countCurrency = item.price[sd];
						break;
					}
				}
			}else if (item.hasOwnProperty('instance')) {
				/*var countOnMap:int = 0;
				if (item.hasOwnProperty('instance') && !item.attachTo) 
				{
					countOnMap = App.user.instance[item.sid] || 0;
				}else 
				{
					countOnMap = World.getBuildingCount(item.sid);
				}
				
				countOnMap += App.user.stock.count(item.sid);*/
				
				/*if (item.hasOwnProperty('gcount') && item.type == 'Building') {
					countOnMap = Storage.shopLimit(item.sid);
				}*/
				if (['Tribute'].indexOf(item.type) != -1) {
					var countUnits:Array = [];
					countUnits = Map.findUnits([int(item.sid)]);
					countOnMap = countUnits.length;
				}
				if (!item.instance.cost.hasOwnProperty(countOnMap + 1)) {
					while (!item.instance.cost.hasOwnProperty(countOnMap + 1) && countOnMap > 0) {
						countOnMap --;
					}
				}
				
				if (countOnMap < 0) countOnMap = 0;
				var priceObject:Object = Storage.price(item.sid);
				priceLabel = new PriceLabelShop(priceObject);
				for  (var sID:* in priceObject) {
					if (sID == Stock.FANT) {
						count = sID;
						sidColor = sID;
						countCurrency = item.instance.cost[countOnMap+1][sID];
						break;
					}
				}
			}
			
			if (item.hasOwnProperty('count') && item.count != 0 && item.type != 'Energy') {
				var mapItems:Array = Map.findUnits([int(item.sid)]);
				if (mapItems.length >= item.count) {
					drawTextBought();
					drawCountBuild();
					return;
				}
			}
			
			if (item.hasOwnProperty('socialprice') && item.socialprice.hasOwnProperty(App.social)) {
				
				priceBttn = new Button( {
					caption:	Payments.price(item.socialprice[App.social]),
					width:		136,
					height:		42,
					fontSize:	26,
					shadow:		true,
					type:		"green"
				});
				priceBttn.x = background.width/2 - priceBttn.width/2;
				priceBttn.y = background.height - 30;
				addChild(priceBttn);
				
				priceBttn.addEventListener(MouseEvent.CLICK, onSocialBuyClick);
				return;
			}
			
			// пара сладкоежек, юная ведьмочка, всадник без головы
			/*if ([2841, 2838, 2843].indexOf(int(item.sid)) != -1) {
				
			}*/
			
			if ([1961, 1952, 2836].indexOf(int(item.sid)) != -1) {
				var find:Boolean = true;
				
				if (App.user.worldID == 1907) {
					var build:Array = Map.findUnits([1950]);
					if (int(item.sid) == 1950 || (build.length > 0 && ShopWindow.containsMaxLevelBuilding(build)))
						find = false;
				}
				
				if (find) {
					bttnFind = new Button({
						caption			:Locale.__e("flash:1405687705056"),
						fontSize		:18,
						radius      	:10,
						fontColor:		0xffffff,
						fontBorderColor:0x475465,
						borderColor:	[0xfff17f, 0xbf8122],
						bgColor:		[0x75c5f6,0x62b0e1],
						bevelColor:		[0xc6edfe,0x2470ac],
						width			:110,
						height			:35,
						fontSize		:15
					});
					bttnFind.x = background.x + background.width / 2 - bttnFind.width / 2;
					bttnFind.y = 185;
					
					item['territory'] = 1907;
					
					if (App.map.id == 1907) {
						bttnFind.addEventListener(MouseEvent.CLICK, onSearchNeedBuilding);
					}else {
						bttnFind.addEventListener(MouseEvent.CLICK, onFind);
					}
					addChild(bttnFind);
					return;
				}
			}
			
			if (item.sid == 2168 && App.map.id != User.HOME_WORLD) {
				return;
			}
			
			var world:Object;
			var id:int;
			var bSID:String;
			var finded:Boolean = false;
			var findBttn:Button;
			var landsWhereCanBuy:Array = [];
			for (id = 0; id < App.user.lands.length; id++) {
				world = App.data.storage[App.user.lands[id]];
				if (world.hasOwnProperty('objects')) {
					for (bSID in world.objects) {
						if (item.sid == world.objects[bSID] && item.visible != 0)
							landsWhereCanBuy.push(App.user.lands[id]);
					}
				}
				if (world.hasOwnProperty('stacks')) {
					for (bSID in world.stacks) {
						if (item.sid == world.stacks[bSID] && item.visible != 0 && landsWhereCanBuy.indexOf(App.user.lands[id]) == -1)
							landsWhereCanBuy.push(App.user.lands[id]);
					}
				}
			}
			if (landsWhereCanBuy.length > 0) {
				if (landsWhereCanBuy.indexOf(App.user.worldID) == -1) {
					for (id = 0; id < landsWhereCanBuy.length; id++) {
						finded = true;
						item['territory'] = landsWhereCanBuy[id];
						findBttn = new Button({
							caption			:Locale.__e("flash:1405687705056"),
							fontSize		:18,
							radius      	:10,
							fontColor:		0xffffff,
							fontBorderColor:0x475465,
							borderColor:	[0xfff17f, 0xbf8122],
							bgColor:		[0x75c5f6,0x62b0e1],
							bevelColor:		[0xc6edfe,0x2470ac],
							width			:110,
							height			:35,
							fontSize		:15
						});
						findBttn.x = background.x + background.width / 2 - findBttn.width / 2;
						findBttn.y = 185;
						addChild(findBttn);
						findBttn.addEventListener(MouseEvent.CLICK, onFind);
						return;
					}
				}else {
					finded = true;
				}
			}
			
			if (!finded) {
				for (id = 0; id < App.user.lands.length; id++) {
					
					world = App.data.storage[App.user.lands[id]];
					if (!world.hasOwnProperty('stacks')) continue;
					for (bSID in world.stacks) {
						if (item.sid == world.stacks[bSID]) {
							item['territory'] = App.user.lands[id];
							if (item.visible == 0) continue;
							findBttn = new Button({
								caption			:Locale.__e("flash:1405687705056"),
								fontSize		:18,
								radius      	:10,
								fontColor:		0xffffff,
								fontBorderColor:0x475465,
								borderColor:	[0xfff17f, 0xbf8122],
								bgColor:		[0x75c5f6,0x62b0e1],
								bevelColor:		[0xc6edfe,0x2470ac],
								width			:110,
								height			:35,
								fontSize		:15
							});
							findBttn.x = background.x + background.width / 2 - findBttn.width / 2;
							findBttn.y = 185;
							if (App.user.worldID != Travel.SAN_MANSANO) {
								if ([1353, 1354, 1355, 1356, 1357].indexOf(int(item.sid)) != -1) {
									if (int(world.sid) != App.user.worldID) findBttn.addEventListener(MouseEvent.CLICK, onFind);
									else findBttn.addEventListener(MouseEvent.CLICK, onSearchTable);
								} else {
									findBttn.addEventListener(MouseEvent.CLICK, onFind);
								}
								if ([2641, 2642].indexOf(int(item.sid)) != -1) {
									if (int(world.sid) != App.user.worldID) {
										findBttn.addEventListener(MouseEvent.CLICK, onFind);
										addChild(findBttn);
										return;
									}
								}else {
									addChild(findBttn);
									return;
								}
							}
						}
					}
				}
			}
			
			
			var itemsWithFind:Array = JSON.parse(App.data.options.ItemsWithFindButton) as Array;
			if (itemsWithFind.indexOf(int(item.sid)) != -1) {
				
				var searchBttn:Button = new Button({
					caption			:Locale.__e("flash:1405687705056"),
					fontSize		:18,
					radius      	:10,
					fontColor:		0xffffff,
					fontBorderColor:0x475465,
					borderColor:	[0xfff17f, 0xbf8122],
					bgColor:		[0x75c5f6,0x62b0e1],
					bevelColor:		[0xc6edfe,0x2470ac],
					width			:110,
					height			:35,
					fontSize		:15
				});
				searchBttn.x = background.x + background.width / 2 - searchBttn.width / 2;
				searchBttn.y = 185;
				
				searchBttn.addEventListener(MouseEvent.CLICK, onSearchTable);
				addChild(searchBttn);
				return;
			}
			
			if (item.type == 'Lands') 
			{
				var descLabel:TextField = Window.drawText(Locale.__e('chapters:12:description'), {
					fontSize:20,
					autoSize:"left",
					textAlign:"center",
					multiline:true,
					color:0xffffff,
					borderColor:0x6a351c,
					shadowColor:0x6a351c,
					shadowSize:1
				});
				descLabel.width = descLabel.textWidth + 5;
				descLabel.x = background.width/2 - descLabel.width/2;;
				descLabel.y = background.height - descLabel.height - 30;
				addChild(descLabel);
				
				var srchBttn:Button = new Button({
					caption			:Locale.__e("flash:1405687705056"),
					fontSize		:18,
					radius      	:10,
					fontColor:		0xffffff,
					fontBorderColor:0x475465,
					borderColor:	[0xfff17f, 0xbf8122],
					bgColor:		[0x75c5f6,0x62b0e1],
					bevelColor:		[0xc6edfe,0x2470ac],
					width			:110,
					height			:35,
					fontSize		:15
				});
				srchBttn.x = background.x + background.width / 2 - srchBttn.width / 2;
				srchBttn.y = 185;
				
				srchBttn.addEventListener(MouseEvent.CLICK, onSearchTerritory);
				addChild(srchBttn);
				return;
			}
			
			if (!priceLabel) {
				if (item.hasOwnProperty('currency')) {
					for (var d:* in item.currency) {
						sidColor = d;
						countCurrency = item.currency[d];
						break;
					}
					priceLabel = new PriceLabelShop(item.currency);
				}
			}
			
			if (!priceLabel) return;
			
			if (sidColor == Stock.FANT || item.sid == 461){
				bttnSettings["bgColor"] = [0x9adc60, 0x5d9f3e];
				bttnSettings["borderColor"] = [0xbfeea8, 0x48882a];
				bttnSettings["bevelColor"] = [0xbfeea8, 0x48882a];
				bttnSettings["fontColor"] = 0xfbfaf6;
				bttnSettings["fontBorderColor"] = 0x3c7a24;
				bttnSettings["diamond"] = true;
				bttnSettings["countText"] = countCurrency;
			}
			
			priceLabel.x = 12;
			priceLabel.y = 168;
			priceLabel.scaleX = 1.2;
			priceLabel.scaleY = 1.1;
			
			addChild(priceLabel);
			
			if (item.hasOwnProperty('instance')) countInstance = getInstanceNum();
			//if (item.hasOwnProperty('gcount')) countInstance = item.gcount;
			
			if (item.type != 'Garden' && item.type != 'Building' && item.type != 'Tribute' && item.type != 'Rbuilding' && countInstance > 0/* && item.sid != 1478*/) {
				
				count = Storage.instanceGet(item.sid);
				count += App.user.stock.count(item.sid);
				//if (Storage.isShopLimited(item.sid))
					//count = Storage.shopLimit(item.sid);
				
				var txt:String = String(count) + "/" + countInstance;
				
				var counterLabel:TextField = Window.drawText(txt, {
					fontSize:23,
					color:0xffffff,
					borderColor:0x2D2D2D,
					autoSize:"left"
				});
				
				counterLabel.x = 108 - 20;
				if (priceLabel.getNum() == 1) counterLabel.y = -55;
				else counterLabel.y = -priceLabel.height/4 - 5;
				priceLabel.addChild(counterLabel);
			}
			
			priceBttn = new Button(bttnSettings);
			addChild(priceBttn);
			
			priceBttn.x = background.width/2 - priceBttn.width/2;
			priceBttn.y = background.height - priceBttn.height + 15;
			
			priceBttn.addEventListener(MouseEvent.CLICK, onBuyEvent);
			
			//время созревания растений
			if (item.market == 2) {
				var timeIcon:Bitmap = new Bitmap(Window.textures.timer);
				timeIcon.scaleX = timeIcon.scaleY = 0.7;
				timeIcon.smoothing = true;
				timeIcon.x = priceBttn.x + priceBttn.width / 2 + 10;
				timeIcon.y = priceBttn.y - timeIcon.height - 3;
				addChild(timeIcon);
				
				var maturationTime:int;
				
				if (item.hasOwnProperty('levelTime') && item.hasOwnProperty('levels')) {
					maturationTime = item.levelTime * item.levels;
				}
				
				if (item.hasOwnProperty('devel')) {
					if(item.devel.hasOwnProperty('req')) {
						maturationTime = item.devel.req[1].t;
					}
				}
				
				var textSize:int = 20;
				do {
					var timeLabel:TextField = Window.drawText(TimeConverter.timeToCuts(maturationTime, false, true), {
						fontSize:textSize,
						autoSize:"left",
						textAlign:"center",
						multiline:true,
						color:0xffffff,
						borderColor:0x6a351c,
						shadowColor:0x6a351c,
						shadowSize:1
					});
					if (textSize <= 14) {
						timeLabel.wordWrap = true;
						timeLabel.width = 41;
					} else {
						timeLabel.width = timeLabel.textWidth + 5;
					}
					timeLabel.x = timeIcon.x + timeIcon.width + 3;
					timeLabel.y = timeIcon.y + 8;
					//timeLabel.width = timeLabel.textWidth + 5;
					textSize -= 1;
				} while (timeLabel.textWidth >= 40);
				addChild(timeLabel);
			}
			
			
			/*if (App.data.options.hasOwnProperty('EventList')) {
				if (!item.hasOwnProperty('sid')) return;
				var eList:Object = JSON.parse(App.data.options.EventList);
				for each (var itm:Object in eList[0]) {
					if (int(itm.sID) == int(item.sid)) {
						if (Events.timeOfComplete > App.time) {
							priceBttn.visible = true;
						} else {
							priceBttn.visible = false;
						}
						break;
					}
				}
			}*/
			
			if ([935].indexOf(int(item.sid)) != -1 && !App.isSocial('MX','YB')) {
				priceBttn.visible = false;
				priceLabel.visible = false;
			}
			
			if (['Happy'].indexOf(item.type) != -1 && item.htype != 1 && App.user.worldID != User.HOME_WORLD) {
				priceBttn.visible = false;
				priceLabel.visible = false;
			}
		}
		
		private function onFind(e:MouseEvent):void {
			window.close();
			
			Find.find(item.sid);
			return;
			
			if (!canShow) {
				ShopWindow.findMaterialSource(item.target);
				Window.closeAll();
				return;
			}
			
			if (App.user.worldID != item.territory) {
				if (App.isSocial('FB', 'NK', 'SP', 'YB', 'MX', 'AI', 'GN') && ([2618, 2619, 2620].indexOf(int(item.sid)) != -1 || item.type == 'Underground')) {
					UndergroundWindow.find = item.sid;
					App.ui.upPanel.eventIcon.mouseClick();
					return;
				}
				new TravelWindow( {
					find:item.territory
				}).show();
			}else {
				ShopWindow.findMaterialSource(item.sid);
			}
		}
		
		private function onSearch(e:MouseEvent):void {
			window.close();
			new TravelWindow( {
				find:641
			}).show();
		}
		
		private function onSearchTerritory(e:MouseEvent):void {
			window.close();
			new TravelWindow( {
				find:item.sid
			}).show();
		}
		
		private function onSearchTable(e:MouseEvent):void {
			if (item.sid == 1447) {
				new SimpleWindow( {
					popup:true,
					height:300,
					width:420,
					title:Locale.__e('flash:1382952380254'),
					text:Locale.__e('flash:1453372438562')
				}).show();
				return;
			}
			window.close();
			
			Find.find(item.sid);
			//ShopWindow.findMaterialSource(item.sid);
		}
		
		private function onSearchNeedBuilding(e:MouseEvent):void {
			ShopWindow.findMaterialSource(1950);
		}
		
		private function drawNotAvailableTxt():void
		{
			var txt:TextField = Window.drawText(Locale.__e("flash:1394709941657"), {
				color:0xa62f14,
				borderColor:0xfcf5e5,
				textAlign:"center",
				autoSize:"center",
				fontSize:22,
				textLeading:-6,
				multiline:true,
				wrap:true,
				width:background.width - 20
			});
			addChild(txt)
			txt.x = (background.width - txt.width)/2;
			txt.y = (background.height - txt.textHeight) - 20;
		}
		
		private var openSprite:Sprite = new Sprite();
		private var needed:TextField;
		private function drawNeedTxt(lvl:int, posX:int, posY:int, container:Sprite = null):void
		{
			addChild(openSprite);
			openSprite.y = 170;
			
			needed = Window.drawText(Locale.__e("flash:1382952380085",[lvl]), {
				color:0xc42f07,
				fontSize:19,
				borderColor:0xfcf5e5,
				textAlign:"center",
				borderSize:3
			});
			
			needed.width = needed.textWidth + 4;
			//needed.height = needed.textHeight;
			if (container) container.addChild(needed);
			else addChild(needed);
			needed.x = (background.width - needed.width) / 2;//posX;
			needed.y =  posY - 32;
			
			//drawCountBuild();
		}
		
		private var boughtText:TextField;
		private function drawTextBought():void
		{
			boughtText = Window.drawText(Locale.__e("flash:1396612413334"), {
				color:0xfff2dd,
				borderColor:0x7a602f,
				borderSize:4,
				fontSize:24,
				autoSize:"center"
			});
			addChild(boughtText);
			boughtText.x = (background.width - boughtText.textWidth)/2;
			boughtText.y = background.height - boughtText.textHeight - 20;
			
			bitmap.alpha = 0.5;
			
		}
		
		private var openText:TextField;
		private var sprite:LayerX;
		public function drawOpenBttn(idItem:int, isDecor:Boolean = false):void {
			
			var settings:Object = { 
				fontSize:20, 
				autoSize:"left",
				color:0xc5f68f,
				borderColor:0x3f670f
			};
			
			var cont:Sprite = new Sprite();
			
			openBttn = new MoneyButton({
				caption: Locale.__e("flash:1382952379890"),
				width:136,
				height:42,
				fontSize:24,
				radius:20
			});
			
			if (item.hasOwnProperty('skip') && item.skip > 0){
				openBttn.count = item.skip;
			}else{
				openBttn.count = item.instance.p[idItem];
			}
			
			addChild(openBttn);
			openBttn.countLabel.x -= 4;
			openBttn.x = (background.width - openBttn.settings.width)/2;
			openBttn.y = background.height - openBttn.height/2 - 4;
			openBttn.addEventListener(MouseEvent.CLICK, onOpenEvent);
		}
		
		private function drawCountBuild():void
		{
			var count:int = World.getBuildingCount(item.sid);
			if (item.hasOwnProperty('instance')) 
			{
				count = Storage.instanceGet(item.sid);
			}else 
			{
				count = World.getBuildingCount(item.sid);
			}
			
			if (item.hasOwnProperty('instance') && App.user.stock.data && App.user.stock.data.hasOwnProperty(item.sid) /*&& item.type == 'Building'*/) 
			{
				count += App.user.stock.count(item.sid);
			}
			
			var countUnits:Array = [];
			if ([738,749,797,815,816,817,935,980,981,982,1002,1012,1193,1302,1845,1868,1658,1969,2201,2371,2641,2642,2732].indexOf(int(item.sid)) != -1) {
				countUnits = Map.findUnits([int(item.sid)]);
				count = countUnits.length;
			}
			if ([/*'Tribute',*/'Fatman'].indexOf(item.type) != -1) {
				countUnits = Map.findUnits([int(item.sid)]);
				count = countUnits.length;
			}
			
			if ([797,815,816,817,935,980,981,982,1004,1012,1193,1302,1444,1666,1845,1868,1658,1969,2013,2201,2371,2641,2642,2732].indexOf(int(item.sid)) != -1) {
				var data:Object = App.user.storageRead('building_' + item.sid, 0);
				/*if (data <= 0 && countUnits.length > data) {
					App.user.storageStore('building_' + item.sid, countUnits.length, true);
				}*/
				if (int(data) >= countUnits.length + App.user.stock.count(item.sid))
					count = int(data);
				else 
					count = countUnits.length + App.user.stock.count(item.sid);
			}
			
			if (item.gcount > 0)
				count = Storage.shopLimit(item.sid);
			
			var maxCount:int = getInstanceNum();
			if (count > maxCount) count = maxCount;
			var txt:String = String(count) + "/" + String(maxCount);
				
				var counterLabel:TextField = Window.drawText(txt, {
					fontSize:24,
					color:0xffffff,
					borderColor:0x2D2D2D,
					autoSize:"left"
				});
				
				counterLabel.x = 100;
				counterLabel.y = 120;
				addChild(counterLabel);
		}
		
		private function onOpenEvent(e:MouseEvent):void {

			if (e.currentTarget.mode == Button.DISABLED) return;
			e.currentTarget.state = Button.DISABLED;
			
			/*var countOnMap:int = World.getBuildingCount(item.sid);
			
			if (item.hasOwnProperty('instance')) 
			{
				countOnMap = App.user.instance[item.sID] || 0;
			}else 
			{
				countOnMap = World.getBuildingCount(item.sid);
			}
			
			if (item.hasOwnProperty('instance') && App.user.stock.data && App.user.stock.data.hasOwnProperty(item.sID)) 
			{
				countOnMap += App.user.stock.count(item.sID);
			}*/
			if (item.hasOwnProperty('skip') && item.skip > 0) {
				if (App.user.stock.take(Stock.FANT, item.skip)) {
					Hints.minus(Stock.FANT, item.skip, Window.localToGlobal(e.currentTarget), false, window);
					
					App.user.shop[item.sid] = countOnMap+1;
					window.contentChange();
					
					Post.send( {
						ctr:'user',
						act:'open',
						uID:App.user.id,
						sID:item.sid,
						wID:App.user.worldID,
						iID:1
					}, function(error:*, data:*, params:*):void {
						if (!error) {
							App.user.shop[item.sid] = 1;
							window.contentChange();
						}
					})
				}
			}
			else if (App.user.stock.take(Stock.FANT, item.instance.p[availableFromLvl])) {
				if (availableFromLvl != 0) {
					Hints.minus(Stock.FANT, item.instance.p[availableFromLvl], Window.localToGlobal(e.currentTarget), false, window);
					
					App.user.shop[item.sid] = countOnMap+1;
					window.contentChange();
					
					Post.send( {
						ctr:'user',
						act:'open',
						uID:App.user.id,
						sID:item.sid,
						wID:App.user.worldID,
						iID:(availableFromLvl == 0) ? 1 : availableFromLvl
					}, function(error:*, data:*, params:*):void {
						if (!error) {
							App.user.shop[item.sid] = countOnMap+1;
							window.contentChange();
						}
					})
				} else {
					Hints.minus(Stock.FANT, item.instance.p[countOnMap+1], Window.localToGlobal(e.currentTarget), false, window);
					
					App.user.shop[item.sid] = countOnMap+1;
					window.contentChange();
					
					Post.send( {
						ctr:'user',
						act:'open',
						uID:App.user.id,
						sID:item.sid,
						wID:App.user.worldID,
						iID:(countOnMap+1 == 0) ? 1 : countOnMap+1 == 0
					}, function(error:*, data:*, params:*):void {
						if (!error) {
							App.user.shop[item.sid] = countOnMap+1;
							window.contentChange();
						}
					})
				}
			} 
			else
			{
				e.currentTarget.state = Button.NORMAL;
			}
		}
		
		private function onSocialBuyClick(e:MouseEvent):void {
			if (e.currentTarget.mode == Button.DISABLED) return;
			
			Payments.buy( {
				type:			'energy',
				id:				item.sid,
				price:			int(item.socialprice[App.social]),
				count:			1,
				title: 			Locale.__e('flash:1396521604876'),
				description: 	Locale.__e('flash:1393581986914'),
				callback:		function():void {
					Log.alert('onBuyComplete ShopItem');
					App.user.stock.add(item.out, item.count);
					onBuyComplete(0,0);
				},
				error:			function():void {
					window.close();
				},
				icon:			Config.getIcon(item.type, item.preview)
			});
		}
		
		private function onBuyEvent(e:MouseEvent):void {
			if (e.currentTarget.mode == Button.DISABLED) return;
			if ([2371].indexOf(int(item.sid)) != -1 && [112,1907,1569].indexOf(int(App.user.worldID)) == -1) {
				new SimpleWindow ( {
					text: Locale.__e('flash:1397124712139', [App.data.storage[item.sid].title]),
					title: Locale.__e('flash:1382952380254'),
					popup: true,
					confirm:function():void {
						Window.closeAll();
						new TravelWindow( { findTargets:[112,1907,1569] } ).show();
					}
				}).show();
				return;
			}
			if ((/*((item.type == 'Floors' || item.type == 'Mfloors') && App.isSocial('FB','SP','NK','MX','YB','AI')) ||*/ item.sid == 1970 || item.sid == 2258 || item.sid == 2090) && App.user.worldID != User.HOME_WORLD) {
				new SimpleWindow ( {
					text: Locale.__e('flash:1455190874281'),
					title: Locale.__e('flash:1382952380254'),
					popup: true,
					confirm:function():void {
						Window.closeAll();
						new TravelWindow( { find:[112] } ).show();
					}
				}).show();
				return;
			}
			
			if ([1950,1961,1952].indexOf(int(item.sid)) != -1 && App.user.worldID != 1907) {
				new SimpleWindow ( {
					text: Locale.__e('flash:1394709941657'),
					title: Locale.__e('flash:1382952380254'),
					popup: true,
					confirm:function():void {
						Window.closeAll();
						new TravelWindow( { find:[1907] } ).show();
					}
				}).show();
				return;
			}
			
			ShopWindow.currentBuyObject = { type:item.type, sid:item.sid };
			
			// Локальный магазин
			if (onBuyAction != null) {
				onBuyAction(item.sid);
				window.close();
				return;
			}
			
			var unit:Unit;
			if (item.type == 'Golden' && item.hasOwnProperty('capacity') && item.capacity != 0 && item.capacity != '') {
				new SimpleWindow( {
					popup:true,
					height:340,
					title:item.title,
					text:Locale.__e('flash:1475653349983', [item.title, String(item.capacity)]),
					confirm:function():void {
						Window.closeAll();
						unit = Unit.add( { sid:item.sid, buy:true } );
						unit.move = true;
						App.map.moved = unit;
					}
				}).show();
				return;
			}
			
			
			switch(item.type)
			{
				case "Material":
				case 'Vip':
					App.user.stock.buy(item.sid, 1);
					break;
				case "Boost":
				case "Energy":
					var sett:Object = null;
					if (App.data.storage[item.sid].out == Techno.TECHNO) {
						sett = { 
							ctr:'techno',
							wID:App.user.worldID,
							x:App.map.heroPosition.x,
							z:App.map.heroPosition.z,
							capacity:1
						};
						App.user.stock.pack(item.sid, onBuyComplete, function():void {
						}, sett);
					}else {
						App.user.stock.pack(item.sid);
					}
					break;
				case "Plant":
					unit = Unit.add( { sid:181, pID:item.sID, planted:0 } );
					unit.move = true;
					App.map.moved = unit;
					Cursor.material = item.sid;
					
					Field.exists = false;					
					break;
				case 'Clothing':
					new HeroWindow({find:item.sid}).show();
					break;
				case 'Animal':
					unit = Unit.add( { sid:item.sid, buy:true } );
					unit.move = true;
					App.map.moved = unit;
					break;
				case 'Decor':
					if (item.dtype == 2) {
						App.user.stock.buy(item.sid, 1);
						flyMaterial(item.sid);
						new SimpleWindow( {
							title:item.title,
							text: Locale.__e('flash:1382952379990'),
							popup:true
						}).show();
					} else {
						unit = Unit.add( { sid:item.sid, buy:true } );
						unit.move = true;
						App.map.moved = unit;
					}
					break;
				case 'Golden':
					if ((item.sid == 553 || item.sid == 554) && App.user.worldID != 555) {
						App.user.stock.buy(item.sid, 1);
						flyMaterial(item.sid);
						new SimpleWindow( {
							title:item.title,
							text: Locale.__e('flash:1382952379990'),
							popup:true
						}).show();
					} else {
						unit = Unit.add( { sid:item.sid, buy:true } );
						unit.move = true;
						App.map.moved = unit;
					}
					break;
				case 'Floors':
					/*if (App.user.worldID != User.HOME_WORLD) {
						new SimpleWindow( {
							title:Locale.__e('flash:1382952379893'),
							text: Locale.__e('flash:1444039115523'),
							popup:true
						}).show();
					} else*/ {
						unit = Unit.add( { sid:item.sid, buy:true } );
						unit.move = true;
						App.map.moved = unit;
					}
					break;
				case 'Firework':
					if (item.sid == 1255 || item.sid == 1556) {
						App.user.stock.buy(item.sid, 1);
						flyMaterial(item.sid);
					} else {
						unit = Unit.add( { sid:item.sid, buy:true } );
						unit.move = true;
						App.map.moved = unit;
					}
					break;
				case 'Happy':
					if (item.sid == 1302 && App.user.worldID != User.HOME_WORLD) {
						new SimpleWindow( {
							title:item.title,
							text: Locale.__e('flash:1397124712139', item.title),
							popup:true
						}).show();
						return;
					} else {
						unit = Unit.add( { sid:item.sid, buy:true } );
						unit.move = true;
						App.map.moved = unit;
					}
					break;
				default:
					unit = Unit.add( { sid:item.sid, buy:true } );
					
					unit.move = true;
					App.map.moved = unit;
				break;
			}
			
			if ([2,23,55,5].indexOf(App.user.quests.currentQID) >= 0) {
				Tutorial.tutorialQuests();
			}
			
			var point:Point;
			if (item.type == "Energy") {
				point = localToGlobal(new Point(e.currentTarget.x, e.currentTarget.y));
				point.x += e.currentTarget.width / 2;
				Hints.minus(Stock.FANT, item.price[Stock.FANT], point);
				return;
			}
			
			if (item.type == 'Firework' && item.count == 0)
				return;
			
			if(item.type != "Material"){
				window.close();
			}else{
				point = localToGlobal(new Point(e.currentTarget.x, e.currentTarget.y));
				point.x += e.currentTarget.width / 2;
				Hints.minus(Stock.COINS, item.coins, point);
			}
		}
		
		public function flyMaterial(_sid:int):void
		{
			var item:BonusItem = new BonusItem(uint(_sid), 0);
			
			var point:Point = Window.localToGlobal(bitmap);
			point.y += bitmap.height / 2;
			
			item.cashMove(point, App.self.windowContainer);
		}
		
		private function onBuyComplete(sID:uint, rez:Object = null):void 
		{
			if (Techno.TECHNO == sID) {
				addChildrens(sID, rez.ids);
			}
		}
		
		private function addChildrens(_sid:uint, ids:Object):void 
		{
			var rel:Object = { };
			rel[Factory.TECHNO_FACTORY] = _sid;
			var position:Object = App.map.heroPosition;
			for (var i:* in ids){
				var unit:Unit = Unit.add( { sid:_sid, id:ids[i], x:position.x, z:position.z, rel:rel, finished:App.time + App.data.options.buyedTechnoTime } );
					(unit as WorkerUnit).born({capacity:1});
			}
		}
		
		private function glowing():void {
			if (!App.user.quests.tutorial) {
				customGlowing(background, glowing);
			}
			
			if (priceBttn) {
				if (App.user.quests.tutorial) {
					priceBttn.showGlowing();
					priceBttn.showPointing("bottom", 0, priceBttn.height + 30, priceBttn.parent);
					priceBttn.name = 'bttn_shop_item_find';
				}else {
					customGlowing(priceBttn);
				}
			}
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
	}
}	