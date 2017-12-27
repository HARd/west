package  
{
	import astar.AStar;
	import astar.AStarNodeVO;
	import com.greensock.TweenLite;
	import com.greensock.TweenMax;
	import core.Debug;
	import core.IsoConvert;
	import core.IsoTile;
	import core.Load;
	import core.Log;
	import core.Post;
	import effects.Waves;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.BlurFilter;
	import flash.geom.Point;
	import flash.utils.clearTimeout;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;
	import fog.FogManager;
	import ui.Cursor;
	import ui.SystemPanel;
	import ui.UnitIcon;
	import wins.elements.BigSaleItem;
	import wins.elements.DecorItem;
	import wins.elements.FriendItem;
	import wins.elements.PackItem;
	import wins.elements.TopItem;
	import wins.InfoWindow;
	import wins.ShopWindow;
	import units.*;
	import wins.StockWindow;
	import helpers.ExceptionsDefinitions;
	import managers.InvadersManager;
	
	public class Map extends LayerX
	{
		public static var deltaX:int 	= 1000;
		public static var deltaY:int 	= 1000;
		public static var mapWidth:int 	= 3000;
		public static var mapHeight:int	= 3000;
		
		public static const LAYER_LAND:String 		= 'mLand';
		public static const LAYER_FIELD:String 		= 'mField';
		public static const LAYER_SORT:String 		= 'mSort';
		public static const LAYER_TREASURE:String 	= 'mTreasure';
		
		public static const DEBUG:Boolean 	= false;
		
		public static var X:int = 0;
		public static var Z:int = 0;
		
		public static var cells:int = 0;
		public static var rows:int = 0;
		
		public var mTreasure:Sprite 	= new Sprite();
		public var mLayer:Sprite 		= new Sprite();
		public var mUnits:Sprite 		= new Sprite();
		public var mIso:Sprite	 		= new Sprite();
		public var mLand:Sprite		 	= new Sprite();
		public var mField:Sprite	 	= new Sprite();
		public var mSort:Sprite		 	= new Sprite();
		public var mIcon:Sprite 		= new Sprite();
		
		public var _aStarNodes:Vector.<Vector.<AStarNodeVO>>;
		public var _aStarWaterNodes:Vector.<Vector.<AStarNodeVO>>;
		public var _aStarParts:Vector.<Vector.<AStarNodeVO>>;
		public var _astar:AStar;
		public var _astarReserve:AStar;
		public var _astarWater:AStar;
		
		public var touched:Vector.<*> = new Vector.<*>();
		
		public var lastTouched:Vector.<Unit> = new Vector.<Unit>();
		
		public var transed:Vector.<Unit> = new Vector.<Unit>();
		public var sorted:Array = [];
		public var depths:Array = [];
		
		public var moved:Unit;
		public var _grid:Bitmap;
		public var _plane:Sprite;
		
		private var _units:Object;
		
		public var butterflies:Vector.<Butterfly> = new Vector.<Butterfly>();
		public var whispas:Vector.<Whispa> = new Vector.<Whispa>();
		
		public var id:uint;
		public var info:Object = { };
		
		public static var focused:Boolean = false;
		
		public var bgColor:* = 0x278395;
		
		private var building:Building;
		private var personage:Personage;
		private var resource:Resource;
		private var exresource:Exresource;
		private var decor:Decor;
		private var field:Field;
		private var hut:Hut;
		private var animal:Animal;
		private var tribute:Tribute;
		private var treasure:Treasure;
		private var golden:Golden;
		private var bgolden:Bgolden;
		private var share:Share;
		private var tree:Tree;
		private var gamble:Gamble;
		private var guide:Guide;
		private var tower:Tower;
		private var floors:Floors;
		private var fake:Fake;
		private var box:Box;
		private var firework:Firework;
		private var chest:Chest;
		private var techno:Techno;
		private var ttechno:Ttechno;
		private var character:Character;
		private var walkGolden:Walkgolden;
		private var buffer:Buffer;
		private var zoner:Zoner;
		private var barter:Barter;
		private var decorItem:DecorItem;
		private var packItem:PackItem;
		private var bigSaleItem:BigSaleItem;
		private var friendItem:FriendItem;
		private var topItem:TopItem;
		private var food:Feed;
		private var thimbles:Thimbles; 
		private var fatman:Fatman; 
		private var tstation:Tstation;
		private var exchange:Exchange;
		private var technological:Technological;
		private var flyinggolden:Flyinggolden;
		private var happy:Happy;
		private var garden:Garden;
		private var mfield:Mfield;
		private var rbuilding:Rbuilding;
		private var efloors:Efloors;
		private var freezer:Freezer;
		private var booker:Booker;
		private var mhelper:Mhelper;
		private var mfloors:Mfloors;
		private var compressor:Compressor;
		private var tent:Tent;
		private var buildgolden:Buildgolden;
		private var minigame:Minigame;
		private var thappy:Thappy;
		private var trap:Trap;
		private var wigwam:Wigwam;
		private var underground:Underground;
		private var resourcehouse:Resourcehouse;
		private var shappy:Shappy;
		private var invader:Invader;
		private var cfloors:Cfloors;

		public var workmen:Object = {0:Personage.BEAR};
		public var heroPosition:Object = { x:36, z:65};
		public static var ready:Boolean = false;
		
		public static var generateResources:Boolean = false;
		public static var freezers:Array = [];
			
		public var fogCount:int;
		
		public function Map(id:int, units:Object = null, load:Boolean=true)
		{
			Map.ready = false;
			this._units = units;
			this.id = id;
			
			//Добавляем себя на сцену
			App.self.addChildAt(this, 0);
			
			fogCount = 100;
			
			if(load)
				Load.loading(Config.getDream(takeDreamName()), onLoadTile);
			
			mouseEnabled = false;
		}
		
		private function takeDreamName():String
		{
			//if (App.user.id == '1')
				//return 'map0';
			
			return App.data.storage[id].view;
		}
		
		public function load():void {
			Load.loading(Config.getDream(takeDreamName()), onLoadTile);
		}
		
		public function dispose():void {
				
			sorted = [];
			depths = [];
			
			var unit:*;
			
			App.self.setOffEnterFrame(sorting);
			
			var childs:int = mSort.numChildren;
			
			while (childs--) {
				try
				{
					unit = mSort.getChildAt(childs);
					
					if (unit is Resource) {
						unit.dispose();
					}else{
						if(!(unit is Plant)){
							unit.uninstall();
						}
					}
				
				}catch (e:Error) {
					
				}
			}
			
			childs = mLand.numChildren;
			while (childs--) {
				try
				{
					unit = mLand.getChildAt(childs);
					
					if (unit is Unit) {
						unit.uninstall();
					}
				}catch (e:Error) {
					
				}	
			}
			
			childs = mField.numChildren;
			while (childs--) {
				try
				{
					unit = mField.getChildAt(childs);
					
					if (unit is Unit) {
						unit.uninstall();
					}
				}catch (e:Error) {
					
				}	
			}
			
			Resource.countWhispa = 0;
			
			if (butterflies.length > 0) {
				for each(unit in butterflies) {
					unit.dispose();
					unit = null;
				}
				butterflies = new Vector.<Butterfly>();
			}
			
			if (whispas.length > 0) {
				for each(unit in whispas) {
					unit.dispose();
					unit = null;
				}
				whispas = new Vector.<Whispa>();
			}
					
			_aStarNodes = null;
			_aStarParts = null;
			_aStarWaterNodes = null;
			_astar = null;
			_astarReserve = null;
			_astarWater = null;
			
			App.user.removePersonages();
			App.self.removeChild(this);
			
			//Lantern.dispose();
			//Boss.dispose();
			//Hut.dispose();
			SoundsManager.instance.dispose();
			Pigeon.dispose();
			Nature.dispose();
			Waves.dispose();
			Resource.goldenOnMap = [];
			//Fog.dispose();
			
			disposeIcon();
			if (fogManager)
			{
				fogManager.dispose();
				fogManager = null;
			}
		}
		
		public function inGrid(point:Object):Boolean
		{
			if (point.x >= 0 && point.x < Map.cells)
			{
				if (point.z >= 0 && point.z < Map.rows) return true;
			}
			return false
		}
		
		/**
		 * Событие окончания загрузки SWF карты
		 * @param	data
		 */
		public var bitmap:Bitmap;
		public var assetZones:Object;
		public var zoneResources:Object;
		public var zoneZoners:Object;
		public var closedZones:Array = [];
		public var resources:Object;
		private function onLoadTile(data:Object):void 
		{			
			closedZones = [];
			var t1:uint;
			var t2:uint;
			
			deltaX 	= 0;//data.gridDelta;
			deltaY 	= 0;
			
			x = -deltaX;
			y = -deltaY;
			
			assetZones = data.assetZones;
			
			if (data.hasOwnProperty('zoneResources'))
			{
				zoneResources = data.zoneResources;
			}
			if (data.hasOwnProperty('zoneZoners'))
			{
				zoneZoners = data.zoneZoners;
			}
			
			t1 = getTimer();
			//Назначаем параметры карты
			Map.mapWidth 	= data.mapWidth;
			Map.mapHeight 	= data.mapHeight;
			Map.cells		= data.isoCells;
			Map.rows 		= data.isoRows;
			
			var widthTile:int 	= data.tile.width;
			var heightTile:int 	= data.tile.height;
			
			var mapCells:int 	= Math.ceil(data.mapWidth / widthTile); 
			var mapRows:int 	= Math.ceil(data.mapHeight / heightTile); 
			
			var tileDX:int = 0;
			var tileDY:int = 0;
			
			if (data.hasOwnProperty('tileDX')){
				tileDX = data.tileDX;
				tileDY = data.tileDY;
			}
			
			var _bgColor:*;
			if (data.hasOwnProperty('bgColor')) {
				if (data.bgColor != 0) {
					bgColor = data.bgColor;
					_bgColor = data.bgColor;
				}else {
					var wID:int;
					if (App.owner) wID = App.owner.worldID;
					else wID = App.user.worldID;
					
					switch(wID) {
						case 555: data.bgColor = 0x00060c;break;
						case 641: data.bgColor = 0x6189CD;break;
						case 767: data.bgColor = 0x6C96BB;break;
						case 903: data.bgColor = 0x4FAAD9;break;
						case 932: data.bgColor = 0x70B7E6;break;
						case 1122: data.bgColor = 0x2598BD;break;
						case 1198: data.bgColor = 0x1C426E;break;
						case 1371: data.bgColor = 0x2F8CB0;break;
						case 1569: data.bgColor = 0xA4C168;break;
						case 1801: data.bgColor = 0x6C96BB;break;
						case 1907: data.bgColor = 0xAED2F5;break;
						default: data.bgColor = 0x278395;
					}
					
					bgColor = data.bgColor;
					_bgColor = data.bgColor;
				}
			}else {
				_bgColor = 0x278395;
				bgColor = _bgColor;
			}
			App.self.bgColor = bgColor;
						
			if (data.hasOwnProperty('type') && data.type == 'image') {
				addTile(0,0);
			}else{
				//Дублируем тайлы карты по всему миру
				for (var j:int = 0; j < mapRows; j++ ) {
					for (var i:int = 0; i < mapCells; i++ ) {
						addTile(i, j);
					}
				}
			}
			
			if (data.hasOwnProperty('additionalTiles'))
			{
				for each(var coords:Object in data.additionalTiles)
				{
					addTile(coords.i, coords.j);
				}
			}
			
			if(data.hasOwnProperty('zoneResources')){
				zoneResources = data.zoneResources;
			}
			
			var count:int = 0;
			function addTile(i:int, j:int):void
			{
				bitmap = new Bitmap(data.tile);
				
				addChild(bitmap);
				bitmap.x = (i * widthTile) + tileDX;
				bitmap.y = (j * heightTile) + tileDY;
				bitmap.smoothing = true;
			}
			
			//drawLandscape(data.elements);
			//Добавляем слой с нарисованой из тайликов сеткой
			addChild(mIso);
			
			//Создаем сетку 
			initGridNodes(data.gridData);
			fogManager = new FogManager();
			if (data.hasOwnProperty('fog'))
				fogManager.init(data.fog);
			else
				fogManager.init();
			fogManager.checkResources(_units);
			fogManager.checkZonesToOpen();
			if (data.hasOwnProperty('info')) {
				info = data.info;
				if (info.hasOwnProperty('bridges'))
					Bridge.init(info.bridges);
			}
			
			addChild(mUnits);

			mUnits.addChild(mLand);
			mUnits.addChild(mField);
			mUnits.addChild(mSort);
			
			var land_decor:Array = [];
			resources = { };
			//раставляем полученные юниты
			for each(var item:Object in _units) {
				if (checkSkipUnit(item.sid)) continue;
				if ([1214,1215,1216].indexOf(int(item.sid)) != -1 && App.user.worldID == 1198) continue;
				//if (Math.random() < 0.5) continue;
				if (item.type == 'Decor' && App.data.storage[item.sid].dtype == 1) {
					land_decor.push(item);
					continue;
				}
				
				if (App.data.storage[item.sid].type == 'Resource') {
					if (!resources.hasOwnProperty(item.sid))
						resources[item.sid] = 0;
						
					resources[item.sid] += 1;
				}
				
				var unit:Unit = Unit.add(item);
				World.tagUnit(unit);
			}
			
			spawnResources();
			checkUnitsSpawn();
			//InvadersManager.Start();
			Invader.start();
			ThiefGoldenManager.Start();
			NewYearManager.Start();
			
			App.user.world.addMine(2504);
			
			if (App.data.storage.hasOwnProperty(1580) && App.user.stock.count(1580) != 0 && App.user.worldID == 1569) {
				var settings:Object = { sid:1580, fromStock:true };
				var unt:Unit = Unit.add(settings);
				unt.stockAction({coords:{x:81, z:139}});
				unt.placing(81, 0, 139);
			}
		
			if (data.hasOwnProperty('heroPosition')) {
				heroPosition = data.heroPosition;
			}
			
			land_decor.sortOn('id');
			var land_decor_lenght:int = land_decor.length;
			for (i = 0; i < land_decor_lenght; i++) {
				Unit.add(land_decor[i]);
			}
			
			land_decor = null;
			//grid = true;
			
			//createLine();
				
			allSorting();
			Fog.lightFirstZoneResource();
			
			/*showWhispas();
			
			for (i = 0; i < 2; i++) {
				var count:int = 2 + Math.random() * 2;
				var whispa:Whispa = new Whispa( { cells:count, rows:count } );
				whispa.show();
				whispas.push(whispa);
			}*/
			
			// Не получилось включить, потомучто ускорение грядок не радотает
			//mTreasure.mouseChildren = false;
			//mTreasure.mouseEnabled = false;
			
			addChild(mIcon);
			addChild(mTreasure);
			
			Map.ready = true;
			
			if (App.user.mode == User.GUEST)
				Resource.createGuestGolden();
			
			App.self.dispatchEvent(new AppEvent(AppEvent.ON_MAP_COMPLETE));
			App.self.setOnEnterFrame(sorting);
			
			if (data.hasOwnProperty('zones'))
			{
				if (App.user.mode == User.OWNER)
					App.user.world.drawZones(data.zones);
				else	
					App.owner.world.drawZones(data.zones);
			}
			
			
			Nature.init();
			Capturer.start();
			CrossPlatformUnit.start();
			Find.nextStep();
			
			if (data.hasOwnProperty('waves'))
				Waves.add(id, data.waves);		
				
			Techno.addWorkers();
			
			checkMine();
		}
		
		//получение данных по шахте для иностранных сетей, с целью получения доступа к юниту на любой локации
		private function checkMine():void {
			if (App.isSocial('VK', 'ML', 'OK', 'FS')) return;
			if (User.mine) return;
			
			var mines:Array = findUnits([2570]);
			
			if (mines.length > 0) {
				User.mine = mines[0];
			} else {
				if (App.user.worldID != User.HOME_WORLD) {
					var postObject:Object = {
						'ctr':'world',
						'act':'mini',
						'uID': App.user.id,
						'wID': User.HOME_WORLD,
						"fields":"[\"world\",\"units\"]"
					}
					
					Post.send(postObject, function(error:*, data:*, params:*):void {
						if (error) return;
						
						for each (var unit:Object in data.units) {
							if (App.data.storage[unit.sid] && ['Underground'].indexOf(App.data.storage[unit.sid].type) != -1) {
								User.mine = new Underground(unit);
								break;
							}
						}
					});
				}
			}
		}
		
		private function checkSkipUnit(sid:int):Boolean {
			if (sid == 1447 || sid == 1452) {
				if (App.user.quests.data.hasOwnProperty(516) && App.user.quests.data[516].finished != 0) return true;
				else return false;
			}
			return false;
		}
		
		private function findPosition(points:Object):Object {
			var start:Object = points[0];
			var end:Object = points[1];
			var startx:int = (start.x > end.x) ? end.x : start.x;
			var endx:int = (start.x > end.x) ? start.x : end.x;
			var starty:int = (start.y > end.y) ? end.y : start.y;
			var endy:int = (start.y > end.y) ? start.y : end.y;
			
			var i:Boolean = true;
			var cnt:int = 0;
			while (i) {
				cnt++;
				var place:Object = nextPlace();
				var node:AStarNodeVO = _aStarNodes[place.x][place.z];
				if (cnt == 30) {
					return null;
				}
				if (node.z != 1196) continue;
				if (node.isWall || node.open == false || node.p == 1) 
					continue;
				i = false;
			}
			
			return {
				x:place.x,
				y:place.z
			}
			
			function nextPlace():Object {
				var randomX:int = startx + int(Math.random() * (endx - startx));
				var randomZ:int = starty + int(Math.random() * (endy - starty));
				return {
					x:randomX,
					z:randomZ
				}
			}
			return {x:0,y:0};
		}
		
		private function drawZone(zoneID:int = 1196):void {
			var _plane:Sprite = new Sprite();
			addChild(_plane);
			
			for (var x:int = 0; x < _aStarNodes.length; x++) {
				for (var z:int = 0; z < _aStarNodes[x].length; z++) {
					if (_aStarNodes[x][z].z == zoneID) {
						_plane.graphics.beginFill(0x1C426E, 0.4);
					}else {
						continue;
					}
					
					var point:Object = IsoConvert.isoToScreen(x, z, true);
					_plane.graphics.moveTo(point.x, point.y);
					_plane.graphics.lineTo(point.x - 20, point.y + 10);
					_plane.graphics.lineTo(point.x, point.y + 20);
					_plane.graphics.lineTo(point.x + 20, point.y + 10);
					_plane.graphics.endFill();
				}
			}
		}
		
		private var spawnObject:Object = {
			1: {
				world:1371,
				sids:[1366, 1367],
				count:999999,
				spawnCount:2,
				available:true,
				needToWrite:false,
				onetime:false
			},
			2: {
				world:1907,
				sids:[1953],
				count:10,
				spawnCount:10,
				available:true,
				needToWrite:true,
				onetime:false
			},
			3: {
				world:1907,
				sids:[1928],
				count:10,
				spawnCount:10,
				available:true,
				needToWrite:true,
				onetime:false
			},
			4: {
				world:User.HOME_WORLD,
				sids:[2259],
				count:5,
				spawnCount:5,
				available:true,
				needToWrite:true,
				onetime:true,
				networks:{'DM':0,'VK':0,'FS':0,'ML':0,'OK':0,'YB':0,'NK':0,'FB':0,'SP':0,'MX':0,'AI':0,'GN':0}
			},
			5: {
				world:1907,
				sids:[2260],
				count:5,
				spawnCount:5,
				available:true,
				needToWrite:true,
				onetime:true,
				networks:{'DM':0,'VK':0,'FS':0,'ML':0,'OK':0,'YB':0,'NK':0,'FB':0,'SP':0,'MX':0,'AI':0,'GN':0}
			},
			6: {
				world:1907,
				sids:[2261],
				count:5,
				spawnCount:5,
				available:true,
				needToWrite:true,
				onetime:true,
				networks:{'DM':0,'VK':0,'FS':0,'ML':0,'OK':0,'YB':0,'NK':0,'FB':0,'SP':0,'MX':0,'AI':0,'GN':0}
			},
			7: {
				world:418,
				sids:[2110],
				count:20,
				spawnCount:20,
				available:true,
				needToWrite:true,
				onetime:true,
				networks:{'DM':0,'VK':0,'FS':0,'ML':0,'OK':0,'NK':0,'FB':0,'SP':0}
			},
			8: {
				world:1907,
				sids:[2110],
				count:20,
				spawnCount:20,
				available:true,
				needToWrite:true,
				onetime:true,
				networks:{'DM':0,'VK':0,'FS':0,'ML':0,'OK':0,'NK':0,'FB':0,'SP':0}
			}
		}
		public function spawnResources():void {
			if (App.user.mode != User.OWNER) return;
			
			var resourcesIDS:Array = [];
			var res:Array = [];
			var spawnCount:int = 0;
			var i:int = 0;
			var j:int = 0;
			var sID:int;
			var place:Object = { };
			var item:Object = { };
			var unit:Unit;
			var data:int;
			var spawnable:Boolean;
			
			for (var spawnID:* in spawnObject) {
				var spawn:Object = spawnObject[spawnID];
				if (!spawn.available) continue;
				if (App.user.worldID != spawn.world) continue;
				if (spawn.hasOwnProperty('networks') && !spawn.networks.hasOwnProperty(App.social)) continue;
				
				resourcesIDS = spawn.sids;
				res = findUnits(resourcesIDS);
				
				if (spawn.needToWrite) {
					var spawnRead:String = 'respawn' + spawn.sids[0];
					if (spawn.sids[0] == 1953) spawnRead = 'respawn_1953';
					if (spawn.sids[0] == 1928) spawnRead = 'respawn_oak';
					if (spawnID > 6 ) spawnRead = 'respawn' + spawn.sids[0] + spawnID;
					data = App.user.storageRead(spawnRead, 0);
					if (data < 0 && res.length == 0) data = 0;
					spawnable = (data >= 0 && data < spawn.count);
					
					if (!spawn.onetime) {
						while (data > spawn.count && res.length > 0) {
							unit = res.pop();
							unit.removable = true;
							unit.onApplyRemove();
							spawnable = false;
						}
					}
					
					if (spawnable) {
						spawnCount = spawn.spawnCount;
						var spawnSave:String = 'respawn' + spawn.sids[0];
						if (spawn.sids[0] == 1953) spawnSave = 'respawn_1953';
						if (spawn.sids[0] == 1928) spawnSave = 'respawn_oak';
						if (spawnID > 6 ) spawnSave = 'respawn' + spawn.sids[0] + spawnID;
						App.user.storageStore(spawnSave, data + spawnCount);
						
						for (j = 0; j < resourcesIDS.length; j++) {
							for (i = 0; i < spawnCount; i++) {
								sID = resourcesIDS[j];
								place = findSpawnPosition();
								item = {sid:resourcesIDS[j], x:place.x, z:place.y};
								unit = Unit.add(item);
								World.tagUnit(unit);
								(unit as Resource).spawnResource(place);
							}
						}
					}
				} else {
					if (res.length > 0) continue;
					
					spawnCount = spawn.spawnCount;
					for (j = 0; j < resourcesIDS.length; j++) {
						for (i = 0; i < spawnCount; i++) {
							sID = resourcesIDS[j];
							place = findSpawnPosition();
							item = {sid:resourcesIDS[j], x:place.x, z:place.y};
							unit = Unit.add(item);
							World.tagUnit(unit);
							(unit as Resource).spawnResource(place);
						}
					}
				}
			}
		}
		
		//проверяем что нужно заспавнить из списка всех спавнов в опциях игры
		public function checkUnitsSpawn():void {
			if (App.user.mode != User.OWNER || !_aStarNodes) return;
			var data:Object;
			for each (var spawn:Object in App.user.spawnUnits) {
				var quest:int = spawn.qID;
				var count:int = spawn.count;
				
				if (spawn.hasOwnProperty('social')) {
					if (spawn.social.indexOf(App.social) == -1) continue;
				}
				
				var needWrite:Boolean = (spawn.hasOwnProperty('onetime') && spawn.onetime == 1) ? true : false;				
				var writeCount:int = (spawn.hasOwnProperty('maxCount')) ? count: 1;
				
				if (spawn.hasOwnProperty('maxCount') && spawn.maxCount > count) needWrite = true;
				
				var place:Object = (spawn.hasOwnProperty('place')) ? spawn.place : null;
				
				if (App.user.quests.data.hasOwnProperty(quest) && App.user.quests.data[quest].finished != 0) {
					if (spawn.hasOwnProperty('finishqID') && App.user.quests.data.hasOwnProperty(spawn.finishqID) && App.user.quests.data[spawn.finishqID].finished != 0) continue;
					var exit:Boolean = false;
					if (needWrite) {
						data = App.user.storageRead('respawnUnits' + quest, 0);
						if (data != 0 && spawn.hasOwnProperty('maxCount')) {
							var spawned:Array = Map.findUnits(spawn.sIDs);
							var spawnedCount:int = 0;
							for (var wID:String in data) {
								spawnedCount += data[wID];
							}
							if (spawned.length > 0 || spawn.maxCount <= spawnedCount)
								continue;
						} else if (data != 0 && data.hasOwnProperty(App.user.worldID)) continue;
					}
					for each (var sid:* in spawn.sIDs) {
						if (!User.inUpdate(sid)) exit = true;
					}
					if (exit) continue;
					if (spawn.lands.indexOf(App.user.worldID) != -1) {
						spawnUnits(spawn.sIDs, quest, count, needWrite, writeCount, place);
					}
				}
			}
		}
		
		//спав любых юнитов, заданный в опциях в админке
		public function spawnUnits(sIDs:Array, qID:int, spawnCount:int, write:Boolean = false, writeCount:int = 1, spawnPlace:Object = null):void {	
			if ((qID == 954 && sIDs.indexOf(2541) != -1)) return;
			var res:Array = findUnits(sIDs);
			if (res.length > 0) return;
			
			var sunits:Array = [];
			for (var j:int = 0; j < sIDs.length; j++) {
				for (var i:int = 0; i < spawnCount; i++) {
					var sID:int = sIDs[j];
					var place:Object = (spawnPlace != null) ? spawnPlace : findSpawnPosition();
					var item:Object = { sid:sIDs[j], x:place.x, z:place.y, started:App.time };
					if (['Walkgolden', 'Golden'].indexOf(App.data.storage[sIDs[j]].type) != -1) {
						item['crafted'] = App.time;
					}
					if (['Trap'].indexOf(App.data.storage[sIDs[j]].type) != -1) {
						item['started'] = 0;
					}
					sunits.push(item);
				}
			}
			
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
					
					if (int(item.sid) == 2570) unit.visible = false;
				}
				
				if (params.write) {
					var obj:Object = App.user.storageRead('respawnUnits' + params.quest, 0);
					var oldCount:int = 0;
					if (obj == 0) obj = { };
					else oldCount = obj[App.user.worldID];
					obj[App.user.worldID] = oldCount + params.count;
					App.user.storageStore('respawnUnits' + params.quest, obj);
				}
				
				App.ui.checkShowResourceHelp();
				
				checkMine();
			}, {quest:qID, write:write, count:writeCount});
		}
		
		public function findSpawnPosition():Object {
			var i:Boolean = true;
			var cnt:int = 0;
			while (i) {
				cnt++;
				var place:Object = nextPlace();
				var node:AStarNodeVO = _aStarNodes[place.x][place.z];
				if (cnt == 30) {
					return {x:0,y:0};
				}
				if (node.isWall || node.open == false || node.b == 1 || node.object != null) 
					continue;
					
				i = false;
			}
			
			return {
				x:place.x,
				y:place.z
			}
			
			function nextPlace():Object {
				var randomX:int = int(Math.random() * Map.cells);
				var randomZ:int = int(Math.random() * Map.rows);
				return {
					x:randomX,
					z:randomZ
				}
			}
			return {x:0,y:0};
		}
		
		//нарисовать линию на карте
		public function createLine():void {
			var _plane:Sprite = new Sprite();
			addChild(_plane);
			
			var x:int = 84;
			for (var z:int = 0; z < _aStarNodes[x].length; z++) {
				if (_aStarNodes[x][z].p == 0) {
					_plane.graphics.beginFill(0x339900, 0.4);
				}else {
					_plane.graphics.beginFill(0xCC0000, 0.4);
				}
				
				var point:Object = IsoConvert.isoToScreen(z, x, true);
				_plane.graphics.moveTo(point.x, point.y);
				_plane.graphics.lineTo(point.x - 20, point.y + 10);
				_plane.graphics.lineTo(point.x, point.y + 20);
				_plane.graphics.lineTo(point.x + 20, point.y + 10);
				_plane.graphics.endFill();
			}
		}
		
		/**
		 * Добавляем элементы ландшафта
		 */
		private function drawLandscape(elements:Array):void
		{
			var elementsList:Array = [];
			for each(var element:Object in elements)
			{
				elementsList.push(element);
			}
			elementsList.sortOn("depth", Array.NUMERIC);
			
			var tileDX:int = 147;
			var tileDY:int = 120;
			
			if (id == 229)
			{
				tileDX = 0;
				tileDY = 0;
			}
			
			for (var e:int = 0; e < elementsList.length; e++)
			{
				var elementBitmap:LandscapeElement = new LandscapeElement(elementsList[e].name);
			
				element = elementsList[e];
				if (element.iso != null)
				{
					var coords:Object = IsoConvert.isoToScreen(elementsList[e].x, elementsList[e].y);
					elementBitmap.x = coords.x;
					elementBitmap.y = coords.y;
				}
				else
				{
					elementBitmap.x = elementsList[e].x - IsoTile.width + tileDX;
					elementBitmap.y = elementsList[e].y
				}
				
				if (elementsList[e].scaleX != null)
				{
					elementBitmap.scaleX = elementsList[e].scaleX;
				}
				
				addChild(elementBitmap);
			}
		}
		
		/**
		 * Создание сетки
		 * @param	markersData сетка поверхности
		 * @param	zonesData сетка зон
		 */
		private function initGridNodes(gridData:Array) : void {
			
			if(id == 81) 
				gridData[65][3].z = 4;
				
			var hasWater:Boolean = false;
			_aStarNodes = new Vector.<Vector.<AStarNodeVO>>();
			_aStarParts = new Vector.<Vector.<AStarNodeVO>>();
			_aStarWaterNodes = new Vector.<Vector.<AStarNodeVO>>();
			var x : uint = 0;
			var z : uint = 0;
			
			while ( x < Map.cells) {
				_aStarNodes[x] = new Vector.<AStarNodeVO>();
				_aStarParts[x] = new Vector.<AStarNodeVO>();
				_aStarWaterNodes[x] = new Vector.<AStarNodeVO>();
				
				while ( z < Map.rows){
					var node :AStarNodeVO  = new AStarNodeVO();
					var part :AStarNodeVO  = new AStarNodeVO();
					var water :AStarNodeVO  = new AStarNodeVO();
					
					node.h = 0;
					part.h = 0;
					
					node.f = 0;
					part.f = 0;
					
					node.g = 0;
					part.g = 0;
					
					node.visited = false;
					part.visited = false;
					water.visited = false;
					
					node.parent = null;
					part.parent = null;
					water.parent = null;
					
					node.closed = false;
					part.closed = false;
					water.closed = false;
					
					node.freezers = new Vector.<Freezer>;
					part.freezers = new Vector.<Freezer>;
					water.freezers = new Vector.<Freezer>;
					
					node.position = new Point(x, z);
					part.position = new Point(x, z);
					water.position = new Point(x, z);
					
					node.isWall = gridData[x][z].p;
					part.isWall = gridData[x][z].p;
					water.isWall = !gridData[x][z].w;
					if (gridData[x][z].w != null)	hasWater = true;
					
					var _z:int = assetZones[gridData[x][z].z];
					node.z = _z;
					
					if (World.zoneIsOpen(_z))	node.open = true;
					
					node.b = gridData[x][z].b;
					node.p = gridData[x][z].p;
					node.w = gridData[x][z].w;
					
					var point:Object = IsoConvert.isoToScreen(x, z, true);
					var cell:IsoTile = new IsoTile(point.x, point.y);
					
					node.tile = cell;
					part.tile = cell;
					water.tile = cell;
					
					_aStarNodes[x][z]  = node;
					_aStarParts[x][z]  = part;
					_aStarWaterNodes[x][z]  = water;
					
					z++;
				}
				z=0;
				x++;
			}
			
			_astar 			= new AStar(_aStarNodes);
			_astarReserve 	= new AStar(_aStarParts);
			
			if(hasWater)
				_astarWater		= new AStar(_aStarWaterNodes);
			else
				_aStarWaterNodes = null;
		}
		
		/**
		 * Управление сеткой
		 */
		public function set grid(value:Boolean):void
		{
			if (_plane) {
				if (this.contains(_plane)) {
					_plane.graphics.clear();
					this.removeChild(_plane);
					_plane = null;
				}
			} else {
				createGrid();
			}
			//if (value) createGrid();
			//else {	if (this.contains(_plane)) {
					//_plane.graphics.clear();
					//this.removeChild(_plane);
					//_plane = null;
				//}}
		}
		public function get grid():Boolean
		{
			return Boolean(_plane);
		}
		
		public function createGrid():void
		{
			_plane = new Sprite();
			addChild(_plane);
			
			var zones:Object = { };
			
			for (var x:int = 0; x < _aStarNodes.length; x++) {
				for (var z:int = 0; z < _aStarNodes[x].length; z++) {
					if (_aStarNodes[x][z].freezers.length == 0 && _aStarNodes[x][z].isWall == false) {
						_plane.graphics.beginFill(0x339900, 0.4);
					}else {
						_plane.graphics.beginFill(0xCC0000, 0.4);
					}
					
					/*if (_aStarNodes[x][z].object == null) {
						_plane.graphics.beginFill(0x339900, 0.4);
					}else {
						_plane.graphics.beginFill(0xCC0000, 0.4);
					}*/
					
					// Зоны
					//if (_aStarNodes[x][z].z == 0) {
						//_plane.graphics.beginFill(0x000000, 0.4);
					//}else {
						//if (!zones[_aStarNodes[x][z].z])
							//zones[_aStarNodes[x][z].z] = int(Math.random() * 0xffffff);
						//
						//_plane.graphics.beginFill(zones[_aStarNodes[x][z].z], 0.6);
					//}
					
					var point:Object = IsoConvert.isoToScreen(x, z, true);
					_plane.graphics.moveTo(point.x, point.y);
					_plane.graphics.lineTo(point.x - 20, point.y + 10);
					_plane.graphics.lineTo(point.x, point.y + 20);
					_plane.graphics.lineTo(point.x + 20, point.y + 10);
					_plane.graphics.endFill();
				}
			}
			
			/*var bmd:BitmapData = new BitmapData(_plane.width, _plane.height, true, 0);
				bmd.draw(_plane);
				
				removeChild(_plane);
				_plane = null;
				
			_grid = new Bitmap(bmd);
			addChild(_grid);*/
		}
		
		private var mapPadding:int = 350;
		/**
		 * Перерисовка карты при ее перемещении
		 * @param	dx	смещение по X оси
		 * @param	dy	смещение по Y оси
		 */
		
		private var replacingDist:int = 0;
		public function redraw(dx:int, dy:int):void {
			Map.focused = false;	
			if (focusTween) {
				focusTween.kill()
				focusTween = null;
			}
			if (focusCenTween) {
				focusCenTween.kill()
				focusCenTween = null;
			}
			
			if (!(x + dx - mapPadding < 0 && x + dx > stage.stageWidth - mapWidth*scaleX - mapPadding*2)) {
				dx = 0;
			}
			
			if (!(y + dy - mapPadding< 0 && y + dy > stage.stageHeight - mapHeight*scaleY - mapPadding)) {
				dy = 0;
			}
			
			if (dx || dy) {
				x += dx;
				y += dy;
			}
			
			replacingDist ++;
			if (replacingDist > 20) {
				replacingDist = 0;
				SoundsManager._instance.soundReplace();
			}
		}
		
		public function set scale(value:Number):void {
			App.map.scaleX = value;
			App.map.scaleY = value;
			App.map.center();
		}
		
		public function center():void {
			
			if (App.user.personages.length > 0)
				focusedOn(App.user.hero, false, null, false);
			else {
				var position:Object = IsoConvert.isoToScreen(App.map.heroPosition.x, App.map.heroPosition.z, true);
				App.map.focusedOn(position, false, null, false);
			}
		}
		
		public function addUnit(unit:*):void {
			if ([2566,2567,2568,2569, 1002].indexOf(int(unit.sid)) != -1) {
				trace();
			}
			switch(unit.layer) {
				case LAYER_FIELD: 		mField.addChild(unit); break;
				case LAYER_LAND:  		mLand.addChild(unit); break;
				case LAYER_TREASURE:  	mTreasure.addChild(unit); break;
				case LAYER_SORT:  
					depths.push(unit);
					sorted.push(unit);
					//depths.sort(Array.NUMERIC);
					//unit.index = depths.indexOf(unit.depth);
					//mSort.addChildAt(unit, unit.index); 
					mSort.addChild(unit); 
				break;
			}
		}
		
		
		public function removeUnit(unit:*):void {
			switch(unit.layer) {
				case LAYER_FIELD: 		if(mField.contains(unit)) 		mField.removeChild(unit); break;
				case LAYER_LAND:  		if(mLand.contains(unit))		mLand.removeChild(unit); break;
				case LAYER_SORT:  		
					
					var index:int = depths.indexOf(unit);
					if(index>0)	depths.splice(index, 1);
					
					index = sorted.indexOf(unit);
					if (index > 0) sorted.splice(index, 1);
					
					if (unit.parent) 		
						unit.parent.removeChild(unit); 
					
					break;
				case LAYER_TREASURE:  	if(mTreasure.contains(unit)) 	mTreasure.removeChild(unit); break;
			}
		}
		
		private var globalSorting:int = 0;
		
		public function sorting(e:Event = null):void {
			globalSorting++;
			if (globalSorting % 2 == 0) return;
			
			if (sorted.length > 0) {
				
				depths.sortOn('depth', Array.NUMERIC);
				
				for each(var unit:* in sorted) {
					var index:int = depths.indexOf(unit);
					unit.index = index;
					
					if(mSort.contains(unit)){
						try {
							//unit.setTint();
							unit.sort(index);
							//mSort.setChildIndex(unit, index);
						}catch (e:Error) {
							
						}
					}
				}	
				sorted = [];
						
				if (globalSorting >= 60) {
					var err:Boolean = false;
					for (var i:* in depths) {
						try{
							mSort.setChildIndex(depths[i], int(i));
						}catch (e:Error) {
							err = true;
						}
					}
					if (err) {
						globalSorting = 59;
					}else{
						globalSorting = 0;
					}
				}
			}
			if (globalSorting >= 60) {
				globalSorting = 0;
			}
		}
		
		public function allSorting():void {
			try {
				depths.sortOn('depth', Array.NUMERIC);
				for (var i:* in depths) {
					if(mSort.contains(depths[i])){
						mSort.setChildIndex(depths[i], int(i));
					}
				}
				
				var index:int = 0;
				while (index < mField.numChildren - 1) {
					if (mField.getChildAt(index).y > mField.getChildAt(index + 1).y) {
						mField.swapChildrenAt(index, index + 1);
						index = 0;
					}
					
					index++;
				}
			} catch (e:Error) {
				Log.alert(e.message + ' ' + index + ' ' + mField.numChildren);
			}
		}
		
		public function untouches():void {
			for each(var touch:* in touched) {
				touch.touch = false;
			}
			touched = new Vector.<*>();
			//if (User.inExpedition && Fog.fogs) {
				//Fog.untouches();
			//}
			Zone.untouches();
		}
		
		private var _unitIconOver:Boolean = false;
		public function set unitIconOver(value:Boolean):void {
			_unitIconOver = value;
			if (_unitIconOver) {
				untouches();
			}else {
				
			}
		}
		
		public var under:Array = [];
		public function touches(e:MouseEvent):void {
			//return;
			//if (_unitIconOver) 
				//return;
			
			var bmp:Bitmap;
			under = [];
			under = getObjectsUnderPoint(new Point(e.stageX, e.stageY));
			//if (User.inExpedition && Fog.fogs) {
				//Fog.touches();
			//}
			Zone.touches();
			
			var length:uint = under.length;
			if (length > 0) {
				
				for each(var touch:* in touched) {
					//bmp = touch.bmp;
					//if (bmp.bitmapData && bmp.bitmapData.getPixel(bmp.mouseX, bmp.mouseY) == 0 || !touch.touchable) {
						touch.touch = false;
						//touched.splice(touched.indexOf(touch), 1);
					//}
				}
				touched = new Vector.<*>();
				
				for (var i:int = length - 1; i >= 0; i--) {
					if (under[i].parent is BonusItem) {
						BonusItem(under[i].parent).cash();
					}
					if (under[i].parent is AnimationItem) {
						under[i].parent.touch = true;
						touched.push(under[i].parent);
						break;
					}
					
					if (under[i].parent.name == 'icon') {
						var unitIcon:* = under[i].parent.parent as UnitIcon;
						if (unitIcon.isTouch()) 
							break;
						
					}else if (UnitIcon.unitIcon) {
						UnitIcon.unitIcon.focusOff();
					}
					
					var unit:Unit = null;
					if (under[i].parent is Unit) {
						unit = under[i].parent;
					}
					else if (under[i].parent.parent is Unit)
					{
						unit = under[i].parent.parent;
					}
					else if (under[i].parent.parent && under[i].parent.parent.parent && under[i].parent.parent.parent is Unit)
					{
						unit = under[i].parent.parent.parent;
					}
					
					if (unit != null){
						
						if (!unit.clickable || !unit.visible) {
						//if (!unit.touchable || !unit.visible) {
							continue;
						}
						
						if (
							(unit.bmp && unit.bmp.bitmapData && unit.bmp.bitmapData.getPixel(unit.bmp.mouseX, unit.bmp.mouseY) != 0) || 
							(unit.animationBitmap && unit.animationBitmap.bitmapData && unit.animationBitmap.bitmapData.getPixel(unit.animationBitmap.mouseX, unit.animationBitmap.mouseY) != 0)
							//(unit.bmp && unit.bmp.bitmapData && unit.bmp.bitmapData.getPixel(unit.bmp.mouseX, unit.bmp.mouseY) != 0)
						) {
							
							var toTouch:Boolean = true;
							if ((unit.cells + unit.rows) * .5 < 4) {
								toTouch = (Map.X+5 >= unit.coords.x && Map.Z+5 >= unit.coords.z || !unit.transable);
							}else {
								toTouch = (Map.X+2 >= unit.coords.x && Map.Z+2 >= unit.coords.z || !unit.transable);
							}
							//Убираем прозрачность
							if (toTouch) {
								
								if (unit.transparent) {
									unit.transparent = false;
								}
								
								// Если объект как бы и выделен но не в списке выделения, снять выделение
								//if (unit.touch && touched.indexOf(unit) != -1)
								//	unit.touch = false;
								
								//Выделяем объект
								if (moved == null && !unit.touch && touched.length == 0) {
									
									if (unit.layer == Map.LAYER_LAND)
									{
										if (Cursor.type == 'default') break;
									}
									touched.push(unit);
									unit.touch = true;
									//Выделили самый верхний не прозрачный и выходим
									break;
								}
								
							}else {
								if (!unit.transparent) {
									unit.transparent = true;
									transed.push(unit);
									
									if(unit.touch){
										unit.touch = false;
										touched.splice(touched.indexOf(unit), 1);
									}
								}
							}
						}
						
					}
				}
				
				for each(var trans:Unit in transed) {
					bmp = trans.bmp;
					
					if (bmp && bmp.bitmapData && trans.animationBitmap && trans.animationBitmap.bitmapData){
						if (
							(bmp.bitmapData && bmp.bitmapData.getPixel(bmp.mouseX, bmp.mouseY) == 0) &&
							(trans.animationBitmap && trans.animationBitmap.bitmapData && trans.animationBitmap.bitmapData.getPixel(trans.animationBitmap.mouseX, trans.animationBitmap.mouseY) == 0)
						) {
							trans.transparent = false;
							transed.splice(transed.indexOf(trans), 1);
						}
					}else {
						if (bmp && (bmp.bitmapData && bmp.bitmapData.getPixel(bmp.mouseX, bmp.mouseY) == 0)) {
							trans.transparent = false;
							transed.splice(transed.indexOf(trans), 1);
						}
					}
				}
			}
		}

		
		public function click():void
		{
			if (isNodeFreezed()) {
				new InfoWindow( {
					popup:true,
					qID:String(App.user.worldID),
					caption:Locale.__e('flash:1382952380254'),
					callback: function():void {
						var ids:Array = [];
						for (var sid:* in App.data.storage) {
							if (App.data.storage[sid].type == 'Freezer')
								ids.push(sid);
						}
						App.user.onStopEvent();
						WUnit.findUnits(ids, 'Freezer');
					}
				}).show();
				return;
			}
			Field.clearBoost();
			
			if ( Mhelper.waitForTarget )
			{
				Mhelper.waitForTarget = false;
				Mhelper.waitWorker.unselectPossibleTargets();
			}
			
			if ((Cursor.type != "default" || Cursor.material || Cursor.type == "instance") && Cursor.type != "locked") {
				Cursor.type = 'default';
				
				if (StockWindow.accelUnits) {
					for each (var unit:* in StockWindow.accelUnits) {
						unit.hideGlowing();
					}
					StockWindow.accelUnits = [];
					StockWindow.accelMaterial = 0;
				}
				Cursor.accelerator = false;
				return;
			}
			
			if (StockWindow.accelUnits) {
				for each (var unt:* in StockWindow.accelUnits) {
					unt.hideGlowing();
				}
				StockWindow.accelUnits = [];
				StockWindow.accelMaterial = 0;
			}
			Cursor.accelerator = false;
			Field.clearBoost();
			App.self.dispatchEvent(new AppEvent(AppEvent.ON_MAP_CLICK));
			
			var world:World;
			if (App.user.mode == User.OWNER){
				if (!App.user.world.checkZone(null, true)) return;
			}else{
				if (!App.owner.world.checkZone(null, true)) return;
			}
			
			if (App.user.hero && App.user.hero.tm.status != TargetManager.FREE) return;
			var point:Object = IsoConvert.screenToIso(this.mouseX, this.mouseY, true);
			
			if(App.user.personages.length > 0)
				App.user.initPersonagesMove(point.x, point.z);
			
			var effect:AnimationItem = new AnimationItem( { type:'Effects', view:'clickEffect', params: { scale:0.4 }, onLoop:function():void {
				/*App.map.mLand.removeChild(effect);*/ effect.parent.removeChild(effect);
			}});
			SoundsManager.instance.playSFX('map_sound_1v3');
			mLand.addChild(effect);
			effect.x = this.mouseX;
			effect.y = this.mouseY;
			
			//App.tutorial.setCirclePosition( { x:App.self.mouseX, y:App.self.mouseY } );
		}
		
		public function touch():void
		{
			if (Cursor.type == "instance") {
				Cursor.type = 'default';
				//touched.splice(0, 1);
				return;
			}
			
			//if (isNodeFreezed()) return;
			
			if (touched.length == 0 || !(touched[0] is Unit)) return;
			
			var unit:Unit = touched[0];
			
			if (isNodeFreezed() && !(unit is Freezer)) return;
			
			if(!(unit is Hero))App.self.dispatchEvent(new AppEvent(AppEvent.ON_MAP_TOUCH));
			
			var world:World;
			if (App.user.mode == User.OWNER)
				world = App.user.world;
			else	
				world = App.owner.world;
			
			switch(Cursor.type)
			{
				case "move":
					if (!world.checkZone(null, true)) return;
					if (unit.can()) {
						break;
					}
					unit.fromStock = false;
					unit.move = true;
					if (unit.move) {
						moved = unit;
					}
					break;
					
				case "remove":
					if (unit is Golden) {
						if (!(unit as Golden).isBaloon)
							if (!world.checkZone(null, true)) return;
					}
					if (unit.can()) {
						break;
					}
					touched.splice(0, 1);
					unit.touch = false;
					unit.remove();
					
					break;
					
				case "rotate":
					if (!world.checkZone(null, true)) return;
					if (unit.can()) {
						break;
					}
					unit.rotate = !unit.rotate;
					break;
				
				case "stock":
					if(Cursor.toStock){
						if (!world.checkZone(null, true)) return;
						if (unit.can()) {
							break;
						}
						unit.putAction();
						break;	
					}
				case "mhelper":
					if ( Mhelper.waitForTarget  && !(unit.info.type == 'Walkgolden' || unit.info.type == 'Golden') || Mhelper.waitWorker.isExclude(unit.sid))
					{
						Mhelper.waitForTarget = false;
						Mhelper.waitWorker.unselectPossibleTargets();
					}
					
				default:
					var exludesMhelper:Array = [];// JSON.parse(App.data.options.MhelperExludes) as Array;
					if (!(unit is Field) && (Mhelper.waitForTarget  && !(unit.info.type == 'Walkgolden' || unit.info.type == 'Golden') || exludesMhelper.indexOf(unit.sid) > -1)) {
							Field.clearBoost();
							Cursor.material = 0;
							ShopWindow.currentBuyObject.type = null;
					}
					
					if (StockWindow.accelMaterial != 0 && StockWindow.accelUnits) {
						var find:Boolean = false;
						for each (var unt:* in StockWindow.accelUnits) {
							if (unt.sid == unit.sid) {
								find = true;
							}
						}
						if (!find) {
							for each (var ut:* in StockWindow.accelUnits) {
								ut.hideGlowing();
							}
							StockWindow.accelUnits = [];
							StockWindow.accelMaterial = 0;
							Cursor.accelerator = false;
							Cursor.material = 0;
						}
					}
					
					if (unit is Decor) {
						if ((unit as Decor).info.dtype == 2 || (unit as Decor).sid == 784 || (unit is Firework)) {
							unit.click();
						}
						else {
							click();
						}
					}else{
						unit.click();
						if(!(unit is Animal))
							App.self.dispatchEvent(new AppEvent(AppEvent.ON_STOP_MOVE));
					}
				break;
			}
		}
		
		//проверяем заблокирована ли текущая клетка фризером
		public function isNodeFreezed():Boolean {
			var coords:Object = IsoConvert.screenToIso(this.mouseX, this.mouseY, true);
			if (App.map._aStarNodes.length <= coords.x || coords.x < 0) return false;
			if (App.map._aStarNodes[coords.x].length <= coords.z || coords.z < 0) return false;
			var node:AStarNodeVO = App.map._aStarNodes[coords.x][coords.z];
			if (node.freezers.length > 0 )
				return true;
				
			return false;
		}
		
		//поиск юнита по сиду и айди
		public static function findUnit(sID:uint, id:uint):*
		{
			
			var i:int = App.map.mSort.numChildren;
			while (--i >= 0)
			{
				var unit:* = App.map.mSort.getChildAt(i);
				if (unit is Unit && unit.sid == sID  && unit.id == id)
				{
					return unit;
				}
			}
			
			return null;
		}
		
		//поиск всех юнитов по сиду
		public static function findUnits(sIDs:Array):Array
		{
			if (!App.map) return new Array();
			var result:Array = [];
			var i:int = App.map.mSort.numChildren;
			var unit:*;
			var index:int;
			
			while (--i >= 0)
			{
				unit = App.map.mSort.getChildAt(i);
				index = sIDs.indexOf(unit.sid);
				if (index != -1)
				{
					result.push(unit);
				}
			}
			
			i = App.map.mField.numChildren;
			while (--i >= 0)
			{
				unit = App.map.mField.getChildAt(i);
				index = sIDs.indexOf(unit.sid);
				if (index != -1)
				{
					result.push(unit);
				}
			}
			
			i = App.map.mTreasure.numChildren;
			while (--i >= 0)
			{
				unit = App.map.mTreasure.getChildAt(i);
				if (unit.hasOwnProperty('sid'))
				{
					index = sIDs.indexOf(unit.sid);
					if (index != -1)
					{
						result.push(unit);
					}
				}
				
			}
			return result;
		}
		
		//поиск юнитов по типу
		public static function findUnitsByType(types:Array):Array
		{
			var result:Array = [];
			var i:int = App.map.mSort.numChildren;
			while (--i >= 0)
			{
				var unit:* = App.map.mSort.getChildAt(i);
				if (!unit.hasOwnProperty('type')) continue;
				var index:int = types.indexOf(unit.type);
				if (index != -1)
				{
					result.push(unit);
				}
			}
			
			i = App.map.mField.numChildren;
			while (--i >= 0)
			{
				var unitF:* = App.map.mField.getChildAt(i);
				if (!unitF.hasOwnProperty('type')) continue;
				var indexF:int = types.indexOf(unitF.type);
				if (indexF != -1)
				{
					result.push(unitF);
				}
			}
			
			return result;
		}
		
		//поиск юнитов по типу на слое mLand
		public static function findUnitsByTypeinLand(types:Array):Array
		{
			var result:Array = [];
			var i:int = App.map.mLand.numChildren;
			while (--i >= 0)
			{
				var unit:* = App.map.mLand.getChildAt(i);
				var index:int = types.indexOf(unit.type);
				if (index != -1)
				{
					result.push(unit);
				}
			}
			
			return result;
		}
		
		//подвести камеру к выбранному юниту и подсветить его
		private var focusTween:TweenLite;
		public function focusedOn(unit:*, glowing:Boolean = false, callback:Function = null, tween:Boolean = true, scale:* = null, considerBoder:Boolean = true, tweenTime:Number = 1, focusOnCenter:Boolean = false):void
		{
			if (scale == null)
				scale = this.scaleX;
			var targetX:int = 0;
			var targetY:int = 0;
			//if (unit is Boss) {
				//targetX = -unit.x * scale + App.self.stage.stageWidth / 2;
				//targetY = -unit.y * scale + App.self.stage.stageHeight ;
			//}else{
				targetX = -unit.x * scale + App.self.stage.stageWidth / 2;
				targetY = -unit.y * scale + App.self.stage.stageHeight / 2;
			//}
			
			if(considerBoder){
				if (targetX > 0) targetX = 0;
				else if (targetX < stage.stageWidth - mapWidth * scale) 	targetX = stage.stageWidth - mapWidth * scale;
				
				if (targetY > 0) 
					targetY = 0;
				else if  (targetY < stage.stageHeight - mapHeight * scale) 
					targetY = stage.stageHeight - mapHeight * scale;
			}
			
			if (tween == false || (x == targetX && y == targetY)) {
				x = targetX;
				y = targetY;
				
				setTimeout(onComplete, 10);
				
				return;
			}
			
			SystemPanel.scaleValue = scale;
			SystemPanel.updateScaleMode();
			App.ui.systemPanel.updateScaleBttns();
			
			if(scale == this.scaleX)
				focusTween = TweenLite.to(this, tweenTime, { x:targetX, y:targetY, onComplete:onComplete } );
			else
				focusTween = TweenLite.to(this, tweenTime, { x:targetX, y:targetY, scaleX:scale, scaleY:scale, onComplete:onComplete } );
			
			function onComplete():void {
				if (glowing) App.ui.flashGlowing(unit);
				if(callback != null){
					callback();
				}
				focusTween = null;
			}
		}
		
		private var watchUnit:Unit;
		private var watchSlow:Number = 2;
		public function watchOn(unit:Unit, slow:Number = 2):void {
			if (!watchUnit)
				App.self.setOnEnterFrame(onWatchOn);
			
			watchSlow = slow;		// Коефициент довода камеры ( 1 - жестко привязяна к объекту, 2< - увеличение торможения )
			watchUnit = unit;
		}
		private function onWatchOn(e:Event):void {
			if (!watchUnit) {
				watchOff();
				return;
			}
			
			var targetX:Number = -watchUnit.x * this.scaleX + App.self.stage.stageWidth / 2;
			var targetY:Number = -watchUnit.y * this.scaleX + App.self.stage.stageHeight / 2;
			x = x + (targetX - x) / watchSlow;
			y = y + (targetY - y) / watchSlow;
		}
		public function watchOff():void {
			if (watchUnit) {
				App.self.setOffEnterFrame(onWatchOn);
				watchUnit = null;
			}
		}
		
		private var focusCenTween:TweenLite;
		public function focusedOnCenter(unit:*, glowing:Boolean = false, callback:Function = null, tween:Boolean = true, scale:* = null, considerBoder:Boolean = true, tweenTime:Number = 1, focusOnCenter:Boolean = false):void
		{
			if (App.user.quests.tutorial)
				tweenTime = 0.5;
			
			if (scale == null)
				scale = this.scaleX;
				
			var posX:int;
			var posY:int;
			
			if (unit.scaleX == 1) {
				posX = unit.x + unit.bitmap.x + unit.bitmap.width / 2;
				posY = unit.y + unit.bitmap.y + unit.bitmap.height / 2;
			}else {
				posX = unit.x + unit.bitmap.width / 2 - (unit.bitmap.width + unit.bitmap.x);
				posY = unit.y + unit.bitmap.y + unit.bitmap.height / 2;
			}
			
			var targetX:int = -posX * scale + App.self.stage.stageWidth / 2;
			var targetY:int = -posY * scale + App.self.stage.stageHeight / 2;
			
			if(considerBoder){
				if (targetX > 0) targetX = 0;
				else if (targetX < stage.stageWidth - mapWidth * scale) 	targetX = stage.stageWidth - mapWidth * scale;
				
				if (targetY > 0) 
					targetY = 0;
				else if  (targetY < stage.stageHeight - mapHeight * scale) 
					targetY = stage.stageHeight - mapHeight * scale;
			}
			
			if (tween == false || (x == targetX && y == targetY)) {
				x = targetX;
				y = targetY;
				if (callback != null) callback();
				return;
			}
			
			SystemPanel.scaleValue = scale;
			SystemPanel.updateScaleMode();
			App.ui.systemPanel.updateScaleBttns();
			
			if(scale == this.scaleX)
				focusCenTween = TweenLite.to(this, tweenTime, { x:targetX, y:targetY, onComplete:onComplete } );
			else
				focusCenTween = TweenLite.to(this, tweenTime, { x:targetX, y:targetY, scaleX:scale, scaleY:scale, onComplete:onComplete } );
			
			function onComplete():void {
				if (glowing) App.ui.flashGlowing(unit);
				if(callback != null){
					callback();
				}
				focusCenTween = null;
			}
		}
		
		public function showWhispas():void {
			if(lastTouched.length > 0){
				var unit:Resource = lastTouched.pop();
				
				unit.showWhispa();
				lastTouched = new Vector.<Unit>();
			}
			
			setTimeout(showWhispas, 10000 + Math.random() * 5000);
		}
		
		public static function glow(width:int, height:int, blur:int = 100):Bitmap 
		{
			var glow:Shape = new Shape();
			glow.graphics.beginFill(0x8de8b6, 1);
			glow.graphics.drawEllipse(0, 0, width, height);
			glow.graphics.endFill();
			
			glow.filters = [new BlurFilter(blur, blur, 3)];
			
			var padding:int = 80;
			var cont:Sprite = new Sprite();
			cont.addChild(glow);
			glow.x = padding;
			glow.y = padding;
			
			var bmd:BitmapData = new BitmapData(glow.width + 2 * padding, glow.height + 2 * padding, true, 0);
			bmd.draw(cont);
			bmd = Nature.colorize(bmd);
			
			cont = null;
			glow = null;
			
			return new Bitmap(bmd);
		}
		
		private static var contLight:LayerX;
		public static function createLight(coords:Object, /*cells:int, rows:int,*/ view:String, focused:Boolean = true, color:int = 0x2bed6f, alpha:Number = 0.3):void
		{
			var _coords:Object = IsoConvert.isoToScreen(coords.x, coords.z, true);
			removeLight();
			
			contLight = new LayerX();
			
			var sqSize:int = 30;
			
			var cont:Sprite = new Sprite();
			var sp:Sprite = new Sprite();
			sp.graphics.beginFill(color);
			sp.graphics.drawRoundRect(0, 0, sqSize * coords.x, sqSize * coords.z, sqSize * coords.x, sqSize * coords.z);
			sp.rotation = 45;
			sp.alpha = alpha;
			cont.addChild(sp);
			cont.height = sqSize * coords.z * 0.7;
			
			contLight.addChild(cont);
			contLight.x = _coords.x ;
			contLight.y = _coords.y;
			
			contLight.showPointing("top", - cont.width/2 , cont.height/2);
			
			
			doLightEff();
			
			App.map.mLand.addChild(contLight);
		}
		public var fogManager:FogManager;
		
		public static function removeLight():void
		{
			removeLightEff();
			
			if (contLight) {
				contLight.hidePointing();
				if(contLight.parent)contLight.parent.removeChild(contLight);
			}
			contLight = null;
		}
		
		// Icon service
		private var iconSortTimeout:int = 0;
		public function iconSortSetHighest(icon:UnitIcon):void {
			if (!icon || icon.parent != mIcon) return;
			var depth:int = mIcon.getChildIndex(icon);
			if (depth < mIcon.numChildren - 1)
				mIcon.swapChildrenAt(depth, App.map.mIcon.numChildren - 1);
		}
		public function iconSortResort(now:Boolean = false):void {
			if (iconSortTimeout > 0) clearTimeout(iconSortTimeout);
			if (!now) {
				iconSortTimeout = setTimeout(iconSortResort, 10, true);
				return;
			}else {
				iconSortTimeout = 0;
			}
			
			var index:int = 0;
			while (index < mIcon.numChildren - 1) {
				if (mIcon.getChildAt(index).y > mIcon.getChildAt(index + 1).y) {
					mIcon.swapChildrenAt(index, index + 1);
					index = 0;
				}else{
					index ++;
				}
			}
		}
		public function disposeIcon():void {
			while (mIcon.numChildren) {
				var icon:* = mIcon.getChildAt(0);
				icon.dispose();
				icon = null;
			}
		}
		
		private static var lightTween:TweenMax;
		private static var lightTween2:TweenMax;
		static private function doLightEff():void 
		{
			lightTween = TweenMax.to(contLight, 1, { glowFilter: { color:0x2bed6f, alpha:0.8, strength: 7, blurX:32, blurY:32 }, onComplete:function():void {
				lightTween2 = TweenMax.to(contLight, 0.8, { glowFilter: { color:0x2bed6f, alpha:0.6, strength: 7, blurX:6, blurY:6 }, onComplete:doLightEff});	
			}});
		}
		
		static private function removeLightEff():void 
		{
			if(lightTween)lightTween.kill();
			if(lightTween2)lightTween2.kill();
			lightTween = null;
		}
		
		public static function traceAllResource(_units:*):void
		{
			var res:Object = { };
			var totalCount:uint = 0;
			
			for each(var item:Object in _units) {
				if ( App.data.storage[item.sid].type == "Resource")
				{
					var resource:Object =App.data.storage[item.sid];
					if (!res.hasOwnProperty(resource.title))
					{
						res[resource.title] = {count:0, capacity:0};
					}
					
					res[resource.title].count ++;
					res[resource.title].capacity += item.capacity;
					totalCount ++;
				}
			}
			
			for ( var type:String in res)
			{
				trace(type + " - количество: " + res[type].count + " общая емкость: " + res[type].capacity);
			}
			trace("totalCount: " + totalCount);
		}
		
		//найти ближайшую свободную позицию возле переданного объекта
		public static function findNearestFreePosition(object:Object):Object {
			var x:int = object.x;
			var y:int = object.y;
			var fX:int = x;
			var fY:int = y;
			var radius:int = 0;
			var sideType:int = 3;
			var emergencyCounter:int = 0;
			var _astarNodes:Vector.<Vector.<AStarNodeVO>>  = App.map._aStarNodes;
			
			while (true) {
				if (emergencyCounter > 1000) break;
				emergencyCounter++;
				
				if (fX >= 0 && fY >= 0 && fX < _astarNodes.length && fY < _astarNodes[fX].length && _astarNodes[fX][fY].open == 1 && _astarNodes[fX][fY].isWall == 0) {
					object.x = fX;
					object.y = fY;
					return object;
				}
				
				if (sideType == 0) {
					fY++;
					if (fY >= y + radius) sideType = 1;
				}else if (sideType == 1) {
					fX--;
					if (fX <= x - radius) sideType = 2;
				}else if (sideType == 2) {
					fY--;
					if (fY <= y - radius) sideType = 3;
				}else if (sideType == 3) {
					fX ++;
					if (fX > x + radius) {
						radius++;
						sideType = 0;
					}
				}
			}
			
			return object;
		}
		
		//подсчет количества итемов на карте для ShopItemNew
		public static function countOnMap(item:Object):int
		{
			var count:int = 0;
			if (item.sid == 1333)
			{
				trace();
			}
			
			if (item.limit > 0 || item.attachTo) {
				count = World.getBuildingCount(item.sid);
			}
			else if (item.hasOwnProperty('instance')) 
			{
				count= Storage.instanceGet(item.sid);
			}
			else 
			{
				count = World.getBuildingCount(item.sid);
			}
			
			if (item.hasOwnProperty('instance') && App.user.stock.data && App.user.stock.data.hasOwnProperty(item.sid)) 
			{
				count += App.user.stock.count(item.sid);
			}
			
			var countUnits:Array = [];
			var data:Object;
			
			if (ExceptionsDefinitions.ITEMS[0].indexOf(int(item.sid)) != -1) {
				countUnits = Map.findUnits([int(item.sid)]);
				count = countUnits.length;
			}
			
			if (ExceptionsDefinitions.ITEMS[3].indexOf(int(item.sid)) != -1) {
				data = App.user.storageRead('building_' + item.sid, 0);
				if (int(data) > countUnits.length)
					count = int(data);
				else 
					count = countUnits.length;
			}
			
			/*if (item.type == 'Fatman') {
				data = App.user.storageRead('building_' + item.sid, 0);
				if (int(data) > countUnits.length)
					count = int(data);
				else 
					count = countUnits.length;
			}*/
			
			if (App.user.quests.data.hasOwnProperty(516) && App.user.quests.data[516].finished != 0 && int(item.sid) == 1444) {
				count = 1;
			}
			
			return count;
		}
	}
}

import flash.display.Bitmap;
import core.Load;
import core.Debug;

internal class LandscapeElement extends Bitmap
{
	private var _name:String
	public function LandscapeElement(name:String)
	{
		_name = name;
		Load.loading(Config.getDream(name), onLoad)
	}
	
	private function onLoad(data:*):void
	{
		if (data.hasOwnProperty('bmd')) 
		{
			/*if (data.hasOwnProperty('colorize') && data.colorize){}else{
				data['colorize'] = true;
				data.bmd = Nature.colorize(data.bmd);
			}*/
			this.bitmapData = data.bmd;
		}
		else {
			Debug.log(_name);
		}
	}
}