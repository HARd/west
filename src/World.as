package 
{
	import api.ExternalApi;
	import astar.AStarNodeVO;
	import core.Debug;
	import core.IsoConvert;
	import core.IsoTile;
	import core.Load;
	import core.Numbers;
	import core.Post;
	import core.WallPost;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.EventDispatcher;
	import flash.filters.BlurFilter;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import strings.Strings;
	import ui.Hints;
	import units.Cbuilding;
	import units.Conductor;
	import units.Personage;
	import units.Resource;
	import units.Storehouse;
	import units.Unit;
	import wins.OpenZoneWindow;
	import wins.PurchaseWindow;
	import wins.SimpleWindow;
	import wins.Window;
	
	/**
	 * ...
	 * @author 
	 */
	public class World 
	{
		public static const zoneIcon:String = Config.getIcon("Material", 'land');
		public var data:Object;
		public var zones:Array = [];
		public var faders:Object = { };
		public var zoneUnits:Object = { };
		
		private var bonusCoords:Point;
		
		public static const MINI:uint = 1;
		
		public static var buildingStorage:Object = new Object();
		
		public function World(data:Object)
		{
			faders = new Object();
			zones = new Array();
			
			this.data = data;
			for each(var zone:* in data.zones) {
				zones.push(zone);
			}
			
			buildingStorage = null;
			buildingStorage = new Object();
		}
		
		public static function isOpen(worldID:uint):Boolean {
			
			if (App.user.worlds.hasOwnProperty(worldID))
				return true;
			
			return false;
		}
		
		public function addUnitToZone(unit:Object, zID:uint):void
		{
			if (zoneUnits[zID] != null) 
				zoneUnits[zID].push(unit);
			else {
				zoneUnits[zID] = new Array();
				zoneUnits[zID].push(unit);
			}
		}
		
		public function drawZones(mapZones:Object):void
		{return;
			for (var sID:* in mapZones)
			{
				if (zones.indexOf(sID) != -1) continue;
				var fader:Zone = new Zone(sID, mapZones[sID]);
				faders[sID] = fader;
			}
			
			/*Load.loading(Config.resources +'dreams/'+'openZoneLabel.png', function(data:Bitmap):void {
				Zone.openZoneImage = data.bitmapData;
			});*/
		}
		
		public function showOpenZoneWindow(zoneID:uint):void
		{
			if (App.user.quests.tutorial) return;
			
			var data:Object = App.data.storage[zoneID];
			
			if (data.level > App.user.level) {
				new SimpleWindow( {
					title:Locale.__e('flash:1396606807965', [data.level]),
					text:Locale.__e('flash:1405002933543'),
					label:SimpleWindow.ERROR
				}).show();
				
				return;
			}
			
			// Если в рецепете есть зона и она закрыта
			var previewClose:Boolean = false;
			if (data.hasOwnProperty('require')) {
				for (var mid:* in data.require) {
					if (App.data.storage[mid].type == 'Zones' && !World.zoneIsOpen(mid)) {
						if (App.isSocial('FB', 'NK', 'SP', 'AI', 'YB', 'MX', 'GN') && [2503/*,2504,2505,2506*/].indexOf(int(mid)) != -1) {
								new SimpleWindow( {
								label:SimpleWindow.ATTENTION,
								title:Locale.__e("flash:1429185188688"),
								text:Locale.__e('flash:1429185230673'),
								height:300
							}).show();
							break;
						}
						previewClose = true;
						new SimpleWindow( {
							title:		App.data.storage[mid].title,
							text:		Locale.__e('flash:1425045818067')
						}).show();
						break;
					}
				}
			}
			
			// Попытаться открыть 
			if (!previewClose) {
				var array:Array = Map.findUnitsByType(['Zoner']);
				var find:Boolean = false;
				for (var i:int = 0; i < array.length; i++) {
					if (array[i].zoneID == zoneID) {
						find = true;
						App.map.focusedOn(array[i], true, function():void {
							array[i].click();
						});
						break;
					}
				}
				
				//показываем окно о покупке зоны в том случае, если нет зонера и зона должна открываться только за покупку
				if (!find) {
					Post.addToArchive('Не найден объект открывающий зону!');
					if ([774,907,1388,2503,2504,2505,2506].indexOf(zoneID) != -1) {
						if (App.isSocial('FB', 'NK', 'SP', 'AI', 'YB', 'MX', 'GN') && [/*2504,*/2503/*,2505,2506*/].indexOf(zoneID) != -1) {
								new SimpleWindow( {
								label:SimpleWindow.ATTENTION,
								title:Locale.__e("flash:1429185188688"),
								text:Locale.__e('flash:1429185230673'),
								height:300
							}).show();
							//new OpenZoneWindow({
								//title:App.data.storage[zoneID].title,
								//sID:zoneID,
								//requires:data.require,
								//unlock:data.unlock,
								//openZone:openZone,
								////additionalPrice:App.data.storage[zoneID].price,
								//description:Locale.__e('flash:1439538711720')
							//}).show();
						} else {
							new OpenZoneWindow({
								title:App.data.storage[zoneID].title,
								sID:zoneID,
								requires:data.require,
								unlock:data.unlock,
								openZone:openZone,
								additionalPrice:App.data.storage[zoneID].price,
								description:Locale.__e('flash:1439538711720')
							}).show();
						}
					}
					if ([1915,1916/*,2503,2504,2505,2506*/,2507].indexOf(int(zoneID)) != -1) {
						new SimpleWindow( {
							label:SimpleWindow.ATTENTION,
							title:Locale.__e("flash:1429185188688"),
							text:Locale.__e('flash:1429185230673'),
							height:300
						}).show();
					}
					/*if (Config.admin) {
						new SimpleWindow( {
							title:data.title,
							text:'Не найден объект открывающий зону!',
							label:SimpleWindow.ERROR
						}).show();
					}*/
				}
			}
		}
		
		public static function nodeDefinion(X:Number, Y:Number):AStarNodeVO
		{
			var place:Object = IsoConvert.screenToIso(X, Y, true);
			
			if (place.x<0 || place.x>Map.X) return null;
			if (place.z<0 || place.z>Map.Z) return null;
			
			//var obj:Object = App.map._aStarNodes[place.x][place.z];
			//Debug.log([obj.position.x, obj.position.y,"    ",obj.z], 0xFFFFFF);
			
			return App.map._aStarNodes[place.x][place.z];
		}
		
		public static function checkUnitZone(target:Object):Object
		{
			var node:AStarNodeVO = App.map._aStarNodes[target.x][target.z];
			if (!node.open)
			{
				return{
					result:false,
					zone:node.z
				};
			}else{
				return{
					result:true
				};
			}
		}
		
		public static const ALWAYS_OPENED_ZONE:int = 4;
		public function checkZone(target:Unit = null, openWindow:Boolean = false):Boolean
		{
			var node:AStarNodeVO;
			if (target == null)
				node = World.nodeDefinion(App.map.mouseX, App.map.mouseY);
			else
				node = App.map._aStarNodes[target.coords.x][target.coords.z];
				
			if (node == null || node.z == 0)	return false;
			if (!node.open && node.z != ALWAYS_OPENED_ZONE)
			{
				if (openWindow && App.user.mode == User.OWNER){
					showOpenZoneWindow(node.z);
				}else{
					Hints.text(Locale.__e('flash:1382952380333'), Hints.TEXT_RED,  new Point(App.self.mouseX, App.self.mouseY));
				}
				return false;
			}
			return true;
		}
		
		//открытие зоны
		public function openZone(sID:uint, buy:Boolean = false):void
		{
			var require:Object;
			if (buy)
			{
				var price:Object = App.data.storage[sID].price;
				if (!App.user.stock.takeAll(price)) return;
			}
			else
			{
				require = App.data.storage[sID].require;
				
				var zone:Object = App.data.storage[sID];
				if (zone.devel) {
					for (var _level:* in zone.devel.req) {
					var obj:Object = zone.devel.req[_level];
					if(	App.user.level >= obj.lfrom &&
						App.user.level <= obj.lto )
						{
							require = zone.devel.obj[_level];
							break
						}
					}	
				}
				
				for (var sid:* in require)
				{
					if (App.data.storage[sid].type != "Material") {
						delete require[sid];
					}
				}
				if (!App.user.stock.takeAll(require))	return;
			}
			
			Post.send({
				ctr:'world',
				act:'zone',
				uID:App.user.id,
				wID:App.user.worldID,
				zID:sID,
				buy:int(buy)
			}, onOpenZone, {sID:sID, require:require});
		}
		
		public function onOpenExpeditionZone(error:*, data:*, params:*):void 
		{
			if (error) 
			{
				Errors.show(error, data);
				return;
			}
					
			var zoneID:int = 0;
			var _center:Object = {};			
			for (var assetID:String in App.map.assetZones)
			{
					if ( App.map.assetZones[assetID] == params.sID )
						zoneID = int (assetID);
				//_center = App.map.fogManager.data[zoneID].center;
				_center = App.map.fogManager.zoneCenter(params.sID);
			}
			var zoneCenter:Object  =  {}
			
			zoneCenter['target'] = IsoConvert.isoToScreen(_center.x, _center.z, true);
			zoneCenter['callback'] = function():void {
				onOpenComplete(params.sID);	
			}
			
			changeNodes(params.sID);
			zones.push(params.sID);
			//Fog.openZone(params.sID);
			App.map.fogManager.openZone();
			var bonus:Object = { };
			bonus = Treasures.convert(bonus);
			Treasures.bonus(bonus, new Point(params.target.x, params.target.y), zoneCenter);
		}
		
		public function onOpenZone(error:*, data:*, params:*):void {
			var sID:int = params.sID;
			var require:Object = params.require;
			
			if (error) {
				Errors.show(error, data);
				for (var _sID:* in require)
				{
					App.user.stock.add(_sID, require[_sID]);
				}
				return;
			}
			
			var fader:Zone = faders[sID];
			bonusCoords = new Point(App.map.mouseX, App.map.mouseY);
			if (data.hasOwnProperty("bonus")) Treasures.bonus(data.bonus, bonusCoords);
			if (data.hasOwnProperty("reward")) Treasures.bonus(data.reward, bonusCoords);
			
			onOpenComplete(sID);
			bonusCoords = null;
			fader = null;
			openUnits(sID);
			
			removeFakes(sID);
			
			//Делаем push в _6e
			if (App.social == 'FB') {
				ExternalApi.og('investigate','area');
			}
			if (User.inExpedition) App.map.fogManager.openZone();
			
			//добавление шахт для территории сан-монсано
			if (sID == 2504 || sID == 2503) {
				addMine(sID);
			}
		}
		
		public function addMine(sID:int):void {
			if (App.user.worldID != Travel.SAN_MANSANO) return;
			
			var item:Object;
			var qID:int;
			switch (sID) {
				case 2504:
					if (!zoneIsOpen(2504)) 
						return;
					item = { sid:2541, x:110, z:98, level:0 };
					qID = 954
					break;
				case 2503:
					if (App.isSocial('FB', 'NK', 'SP', 'YB', 'MX', 'AI', 'GN')) 
						return;
					item = { sid:2570, x:176, z:70};
					qID = 1003;
					break;
			}
			var mine:Array = Map.findUnits([item.sid]);
			
			
			//TODO:remove this part of code in a month from 25.11.2016
			if (mine.length > 1)
			{
				mine.sortOn("level", Array.DESCENDING);
				while (mine.length > 1)
				{	
					Post.send( { ctr: mine[mine.length - 1].type, act: 'remove', uID: App.user.id, wID: App.user.worldID, sID: mine[mine.length - 1].sid, id: mine[mine.length - 1].id }, mine[mine.length - 1].onRemoveAction, { callback: null } );
					mine.splice(mine.length - 1, 1);
				}
			}
			
			if (mine.length > 0) 
				return;
				
			var sunits:Array = [];
			sunits.push(item);
			
			Post.send( {
				ctr:'world',
				act:'rise',
				uID:App.user.id,
				wID:App.user.worldID,
				qID:qID,
				units:JSON.stringify(sunits)
			}, function(error:int, data:Object, params:Object):void {
				if (error) {
					return;
				}
				for each (var item:* in data) {
					var unit:Unit = Unit.add(item);
					World.tagUnit(unit);
				}
				
				var obj:Object = App.user.storageRead('respawnUnits' + qID, 0);
				var oldCount:int = 0;
				if (obj == 0) obj = { };
				else oldCount = obj[App.user.worldID];
				obj[App.user.worldID] = oldCount + 1;
				App.user.storageStore('respawnUnits' + qID, obj);
			});
		}
		
		//когда рубим ресурс в экспедиции, который должен открывать зону
		public function removeResource(res:Resource):void
		{
			if (App.map.zoneResources == null)
				return;
			
			if (!App.map.zoneResources.hasOwnProperty(res.id))
				return;
			
			var zoneID:int = App.map.zoneResources[res.id];
			var zone_SID:int = App.map.assetZones[zoneID];
			
			if (App.user.world.zones.indexOf(zone_SID) != -1)
				return;
			
			
			Post.send({
				ctr:'world',
				act:'zone',
				uID:App.user.id,
				wID:App.user.worldID,
				zID:zone_SID,
				buy:0
			}, onOpenExpeditionZone, {sID:zone_SID, target:res});
		}
		
		private var fakes:Object = {
			180: {//Полуостров
				sid:297,
				id:7
			}
		}
		
		private function removeFakes(sID:int):void 
		{
			var fakeObject:Object = fakes[sID];
			if (fakeObject == null)
				return;
			var fake:* = Map.findUnit(fakeObject.sid, fakeObject.id);
			if (fake != null)
				fake.onApplyRemove();
		}
		
		private function openUnits(zone_sid:uint):void {
			
			/*var i:int = App.map.mSort.numChildren;
			while (--i >= 0)
			{
				var unit:* = App.map.mSort.getChildAt(i);
				var node:AStarNodeVO = App.map._aStarNodes[unit.coords.x][unit.coords.z];
				if (node.z == zone_sid)
					unit.makeOpen();
			}*/
		}
		
		private function onOpenComplete(sID:uint):void
		{
		
			changeNodes(sID);
			//faders[sID].dispose();
			//delete faders[sID];
			zones.push(sID);
			
			new SimpleWindow( {
				title:App.data.storage[sID].title,
				label:SimpleWindow.BUILDING,
				text:Locale.__e("flash:1382952380334"),
				sID:sID,
				confirm:function():void {
					openZonePost(sID);
				}
			}).show();
		}
		
		public function dispose():void
		{
			for each(var zone:Zone in faders)
			{
				zone.dispose();
			}
			zoneUnits = { };
			faders = null;
			zones = [];
			data = null;
		}
		
		//проверить открыта ли определенная зона
		public static function zoneIsOpen(sID:uint):Boolean
		{
			//зоны, открытые всегда по умолчанию
			if (sID == 113 || sID == 1196) return true;
			
			var world:World;
			if (App.user.mode == User.OWNER)
				world = App.user.world;
			else	
				world = App.owner.world;
				
			if (world.zones.indexOf(sID) == -1) 
				return false;
				
			return true;
		}
		
		//записываем в сетку открытую зону
		public function changeNodes(sID:uint):void
		{
			var x : uint = 0;
			var z : uint = 0;
			
			while ( x < Map.cells) {
				z = 0;
				while ( z < Map.rows){
					if (App.map._aStarNodes[x][z].z == sID)
					{
						App.map._aStarNodes[x][z].open = true;
						if (App.map._aStarNodes[x][z].object != null) {
							trace(App.map._aStarNodes[x][z].object);
							App.map._aStarNodes[x][z].object.makeOpen();
						}
					}	
					z++;	
				}
				x++;
			}
		}
		
		public static function canBuyOnThisMap(sid:*, exceptionSections:Array = null):Boolean {
			return true;
		}
		
		public static function canBuyOnMap(sid:*, exceptionSections:Array = null):Array {
			var worlds:Array;
			
			if (!exceptionSections) exceptionSections = [];
			if (exceptionSections.indexOf(0) == -1)
				exceptionSections.push(0);
			
			for each(var worldID:* in App.user.worlds) {
				var info:Object = App.user.worlds[worldID];
				if (info) {
					for (var section:* in info.shop) {
						if (exceptionSections.indexOf(section) >= 0) continue;
						if (info.shop[section][sid] == 1) {
							if (!worlds) worlds = [];
							worlds.push(worldID);
						}
					}
				}
			}
			
			return worlds;
			return [0];
		}
		
		public function openZonePost(sID:uint):void
		{
			//Пост на стену
			//var message:String = Locale.__e('flash:1382952380041 открыл новую территорию \"%s\" в игре \"flash:1382952379705\". %s',[App.data.storage[sID].title, Config.appUrl]);
			
			
			//var message:String = Strings.__e('World_openZonePost',[App.data.storage[sID].title, Config.appUrl]);
			//
			//var back:Sprite = new Sprite();
			//var front:Sprite = new Sprite();
			//
			//var bitmap:Bitmap = new Bitmap(Zone.openZoneImage);
			//back.addChild(bitmap);
			//bitmap.smoothing = true;
			//var gameTitle:Bitmap = new Bitmap(Window.textures.logo, "auto", true);
			//back.addChild(gameTitle);
			//gameTitle.x = 0;
			//gameTitle.y = bitmap.height - 34;
			//bitmap.x = (gameTitle.width - bitmap.width) / 2 - 5;
			//var bmd:BitmapData = new BitmapData(Math.max(bitmap.width, gameTitle.width), back.height);//, true, 0);
			//bmd.draw(back);
			//
			//ExternalApi.apiWallPostEvent(ExternalApi.NEW_ZONE, new Bitmap(bmd), App.user.id, message);
			
			//WallPost.makePost(WallPost.NEW_ZONE, {sid:sID});
			
			//End Пост на стену
		}
		
		/*public var conductor:Conductor
		public function addConductor():void {
			if (App.user.worldID == User.HOME_WORLD) return;
			conductor = new Conductor({ id:0, sid:Personage.CONDUCTOR, x:App.map.heroPosition.x - 5, z:App.map.heroPosition.z + 2} );
			Unit.sorting(conductor);
		}*/
		
		//открыть территорию
		public function openWorld(wID:uint, buy:Boolean = false, callback:Function = null, take:Boolean = true):void
		{
			var worldID:uint = wID;
			var require:Object;
			if (buy)
			{
				var price:int = App.data.storage[wID].unlock.price;
				if (!App.user.stock.take(Stock.FANT, price)) return;
			}
			else
			{
				require = App.data.storage[wID].require;
				if (take) {
					for (var sid:* in require)
					{
						if (App.data.storage[sid].type != "Material") {
							delete require[sid];
						}
					}
					if (!App.user.stock.takeAll(require))	return;
				}
			}
			
			Post.send({
				ctr:'world',
				act:'open',
				uID:App.user.id,
				wID:worldID,
				buy:int(buy)
			},
			function(error:*, data:*, params:*):void {
				
				if (error) {
					Errors.show(error, data);
					for (var _sID:* in require)
						App.user.stock.add(_sID, require[_sID]);
					return;
				}
				
				App.user.worlds[worldID] = worldID;
				
				App.user.quests.checkQuestsForTerritoty();
				
				if (callback != null) callback(worldID);
			});	
		}
		
		public static function tagUnit(unit:Unit):void {
			if (!App.data.storage.hasOwnProperty(unit.sid)) return;

			addBuilding(unit.sid);
		}
		
		public static function addBuilding(sid:int):void
		{
			//if (sid == 2872)
				//trace();
			
			if (buildingStorage[sid]) {
				buildingStorage[sid] += 1;
				return;
			}
			
			buildingStorage[sid] = 1;
		}
		
		public static function removeBuilding(unit:Unit):void
		{
			buildingStorage[unit.sid] -= 1;
		}
		
		public static function getBuildingCount(sid:int):int 
		{
			if (buildingStorage[sid]) {
				return buildingStorage[sid];
			}
			return 0;
		}
		
		public static function canBuilding(sid:int):Boolean {
			var placeAnyway:Boolean = false;// (['0'].indexOf(String(sid)) != -1);
			var builded:int = getBuildingCount(sid);
			var canBuild:int = 0;
			
			if (!App.data.storage[sid].hasOwnProperty('instance') || sid == 1478)
				placeAnyway = true;
			
			try {
				canBuild = Numbers.countProps(App.data.storage[sid].instance.cost);
				
				// Если просто здание можно строить всегда
				if (['Tribute','Building','Rbuilding','Buildgolden'].indexOf(App.data.storage[sid].type) != -1) canBuild = builded + 1;
			}catch (e:*) {}
			
			return (placeAnyway || (canBuild > 0 && builded < canBuild)) ? true : false;
		}
		
		public function emergOpenZone(zone_SID:int):void
		{
			Post.send({
				ctr:'world',
				act:'zone',
				uID:App.user.id,
				wID:App.user.worldID,
				zID:zone_SID,
				buy:0
			}, function(error:*, data:*, params:*):void {
				changeNodes(zone_SID);
				zones.push(zone_SID);
				
				if (User.inExpedition)
					App.map.fogManager.openZone();
					//Fog.openZone(zone_SID);
			});
		}
	}
}