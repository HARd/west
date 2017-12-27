package units 
{
	import astar.AStarNodeVO;
	import com.greensock.easing.Circ;
	import com.greensock.TweenLite;
	import core.Load;
	import core.Numbers;
	import core.Post;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	import ui.UnitIcon;
	//import ui.AnimalCloud;
	import ui.UserInterface;
	//import wins.BoxWindow;
	import wins.PurchaseWindow;
	//import wins.ComplexCapturerWindow;
	import wins.ShopWindow;
	import wins.SimpleWindow;
	public class Invader extends WUnit
	{
		public static const spatialMap:int	= 1760;
		protected var hasEvent:Boolean		= false;
		protected var QIDs:Array			= [];
		protected var sQIDs:Array			= [];
		protected var home:Array 			= [];
		public var level:String = '';
		public var shadow:Bitmap;
		//protected var ifectRadius:int 		= 0;
		protected var mIDs:Array			= [];
		public static var qIDs:Array		= [];
		protected var spawnable:Boolean 	= false;
		protected var onAllMap:Boolean		= false;
		protected var purchaseable:int		= 0;
		protected var hasWalk:Boolean		= false;
		protected var uniq:Boolean			= false; 
		protected var radius:int			= 0;
		public static const STOP:String 	= "stop_pause";
		public static const KILL:String		= "kill";
		private var fog:Bitmap;
		private var soc:Array;
		public var movePoint:Point = new Point();
		protected var rweapon:Boolean = false;
		protected var shake:Boolean = false;
		protected var SIDs:Array;
		
		
		//SIDs 				- набор сидов из которых будет созадвавться захватчик
		//uniq 				- если параметр 0 или отсутствует то sid из набора SIDs будет выбираться случайным образом
		//mIDs 				- указуются карты на которых будет находится захватчик
		//soc				- указуются социальные сети для которых доступен захватчик
		//coords			- координаты захватчика, 
		//radius			- радиус в котором выбираться случайная доступная точка для захватчика.
		//count				- количество на карте
		//QIDs				- пока открыт квест с этим айди 
		//sQIDs				- с которого открыт квест с этим айди 
		//rQIDs				- квесты после которых убирать инвейдеров
		//home				- пока здание с этим айди не будет построено до последнего уровня. "защищают здание)"
		//onAllMap			- генерируются координаты в случайной проходимой открытой точке карты
		//hasEvent			- подвязаны ли к ивенту
		//spawnable 		- спавнятся после события kill или нет
		//buy				- покупаются и ставятся на карту (для сохранения выбраных координат. лучше бы найти другой способ)
		//moveable			- могут ли двигаться
		//velocity			- скорость передвижения
		//mxlvlU			- хранит сид юнита который достиг необходимого уровня либо имеет необходимые элементы
		public function Invader(object:Object) 
		{
			var pos:Object		= setPosition (object);
			hasEvent			= object.hasEvent || false;
			qIDs				= object.qIDs || [];
			sQIDs				= object.sQIDs || [];
			home				= object.protectedBuilding || [];
			//ifectRadius		= object.ifectRadius || 0;
			mIDs				= object.mID || [];
			spawnable			= object.spawnable || false;
			onAllMap			= object.onAllMap || false;
			radius				= object.radius	|| 0;
			object.x			= pos.x;
			object.z			= pos.z;
			layer				= Map.LAYER_SORT;
			purchaseable		= object.purchaseable || 0;
			hasWalk				= object.hasWalk || false;
			uniq				= object.uniq || false;
			this.id 			= object.id || 0;
			settingsOn			= object.settingsOn || false;
			rweapon 			= object.rweapon || false;
			shake				= object.shake	|| false;
			SIDs				= object.SIDs;
			flying				= object.flying || false;
			movePoint.x = object.x;
			movePoint.y = object.z;
			super (object);
			velocity			= object.velocity || 0.08;
			touchable	= true;
			touchableInGuest	= false;
			clickable	= true;
			
			if (!Config.admin)
			{
				transable 	= false;
				moveable 	= false;
				removable 	= false;
				rotateable  = false;
				stockable 	= false;
			}
			if(info!=null){
				for (var s:String in info.devel.obj) {
					if (App.user.level >= info.devel.req[s].lfrom && App.user.level <= info.devel.req[s].lto) {
						require = info.devel.obj[s];
						level = s;
					}
				}
				info['require'] = require;
				framesType = STOP;
				if (Numbers.countProps(require) >= 1)
					Load.loading(Config.getSwf(info.type, info.view), onLoad);
			}
			
			tip = function():Object {
				
				var subText:String = '';				
				var normalMaterials:Array = [];				
				if (info.hasOwnProperty('require')) {
					normalMaterials = [];
					for (var reqid:* in info.require) {
						if (App.data.storage.hasOwnProperty(reqid) && App.data.storage[reqid].mtype != 3) {
							normalMaterials.push(reqid);
						}
					}
					
					if (App.user.mode == User.GUEST) {
						reqid = 6;
						normalMaterials = [reqid];
					}
					
					if (normalMaterials.length > 0) {
						var bmp:Bitmap = new Bitmap(new BitmapData(40,40,true,0));
						Load.loading(Config.getIcon(App.data.storage[reqid].type, App.data.storage[reqid].preview), function(data:Bitmap):void {
							bmp.bitmapData.draw(data, new Matrix(0.3, 0, 0, 0.3));
						});
						
						return {
							title:info.title,
							text:info.description,
							desc:Locale.__e('flash:1383042563368'),
							icon:bmp,
							iconScale:0.6,
							count:(App.user.mode == User.GUEST) ? 1 : info.require[reqid]
						};
					}
				}
				
				return {
					title:info.title,
					text:info.description
				};
			}
			
			testCreate();
			take();
			
			if (flying)
				homeRadius = 15;
			
			//graphics.beginFill(0xff0000);
			//graphics.drawRect(0, 0, 100, 100);
			//graphics.endFill();
		}
		protected function testCreate ():void { // проверяем не создано ли лишнего и удаляем лишних. проверка не работает на фисташковом острове. проверка сверяется с опциями игры
			if ( App.map.id == spatialMap  || App.map.id == 3135 || App.map.id == 3290 || App.map.id == 3423) return;
			//try {
					invaderList = JSON.parse(App.data.options.InvaderList) as Array;
					var invader:Object;
					for each (invader in invaderList) {
						
						// Костыль для искр.
						if (this.sid == 3656 && invader.SIDs.indexOf(3655) != -1) {
							break;
						}
						else
						{
							if (invader.SIDs.indexOf(this.sid)!=-1) break;
						}
					}
					spawnable	 = invader.spawnable|| false;
					soc			 = invader.soc || [];
					mIDs		 = invader.mIDs || [];
					QIDs		 = invader.QIDs || [];
					sQIDs		 = invader.sQIDs || [];
					home		 = invader.home || [];
					hasEvent 	 = invader.hasEvent || false;
					purchaseable = invader.buy;
					if ( !checkAllSets(this) || App.user.level < 4 || (this.coords.x == 0 && this.coords.z == 0)) {
						if (App.user.mode == User.OWNER ){
							if ( purchaseable != 0){
								removable = true;
								onApplyRemove();
							}
							uninstall();
						}
						else {
							this.visible = false;
						}
					}
				//}catch(e:*) {}
			
		}
		public static function init(object:Object):void {
			if (!checkAllSets(object)) return;
			
			var onMap:Array = Map.findUnits(object.SIDs);
			var _sid:int = 0;
			var find:Boolean = false;
						
			for ( var i:int = onMap.length; i < object.count; i++) {
				
				onMap = Map.findUnits(object.SIDs);
				
				// Выбор сундука которого еще нет на карте или последнего из списка
				if (object.hasOwnProperty("uniq") && object.uniq) {
					var sidsOutOfMap:Object = { };
					var allSidsToUse:Array = [];
					for each(var sd:* in object.SIDs) {
						allSidsToUse.push(int(sd));
					}
					for (var j:int = 0; j < object.SIDs.length; j++) {
						find = false;
						for (var k:int = 0; k < onMap.length; k++) {
							if (!sidsOutOfMap.hasOwnProperty(onMap[k].sid)) {
								sidsOutOfMap[onMap[k].sid] = 0;
							}
							sidsOutOfMap[onMap[k].sid]++;
							if (sidsOutOfMap[onMap[k].sid] >= object.uniq) {
								if(allSidsToUse.indexOf(onMap[k].sid) != -1)
									allSidsToUse.splice(allSidsToUse.indexOf(onMap[k].sid),1);
							}
						}
					}
					_sid = allSidsToUse[int(Math.random()*(allSidsToUse.length-0.1))]
				}else {
					_sid = object.SIDs[int(Math.random() * object.SIDs.length) ];
				}
				
				//TODO: реализовать подмену инвейдера
				//_sid = podmenaInvaders(_sid);
				
				var invader: Invader = new Invader({
					sid:			_sid,
					x:				(object.coords[object.mIDs.indexOf(App.map.id)])?object.coords[object.mIDs.indexOf(App.map.id)].x : 0,
					z:				(object.coords[object.mIDs.indexOf(App.map.id)])?object.coords[object.mIDs.indexOf(App.map.id)].z : 0,
					spawnable:		object.spawnable,
					radius:			object.radius,
					onAllMap: 		object.onAllMap,
					hasEvent:		object.hasEvent,
					id:				Map.findUnits(object.SIDs).length + 1,
					purchaseable:	object.buy,
					hasWalk:		object.moveable,
					velocity:		object.velocity,
					settingsOn:		true,
					SIDs:			object.SIDs,
					shake:			object.shake,
					rweapon:		object.rweapon,
					flying:			object.flying
				});
				
				App.map.sorted.push(invader);
				
				if (object.buy)
					invader.buyAction();
			}
			
			App.map.allSorting();
			
			
		}
		
		/**
		 * Подменить инвейдера на другого инвейдера
		 */
		//static private function podmenaInvaders(sid:int):int 
		//{
			//if (sid == "инвейдер" && App.map.id == "остров")
			//{
				//if ("условие")
				//{
					//return "сид";
				//}
			//}
			//
			//return sid;
		//}
		
		/**
		 * Создать инвейдера
		 */
		public static function createInvader(mID:int):void
		{			
			var findSID:int = -1;
			var crafting:*;
			var lvl:*;
			var treasure:*;
			var subtreasure:*;
			
			
			// Перебераем всех доступных нам инвейдеров.
			for (var s:* in App.data.storage) 
			{		
				if (findSID != -1) break;
				
				if ( App.data.storage[s].type == 'Invader' && App.data.storage[s].hasOwnProperty('devel') && App.data.storage[s].devel.hasOwnProperty('req') )
				{
					crafting = App.data.storage[s].devel.req;
					for (lvl in crafting) {
						if ( crafting[lvl].lfrom <= App.user.level && crafting[lvl].lto >= App.user.level )
							treasure = crafting[lvl].treasure;
					}
					
					
					// В кладах ищем sid инвейдера.
					if (treasure) 
					{
						if (App.data.treasures.hasOwnProperty(treasure)) 
						{
							if (App.data.treasures[treasure].hasOwnProperty(treasure)) {
								subtreasure = treasure;
							}else if (App.data.treasures[treasure].hasOwnProperty('kick')) {
								subtreasure = 'kick';
							}
							
							if (subtreasure) {
								for each(crafting in App.data.treasures[treasure][subtreasure].item) {
									if (int(crafting) == mID) {
										findSID = int(s);
										break;
									}
								}
							}
						}
						treasure = null;
						subtreasure = null;
					}
				}
			}
			
			
			var findUnit:Object = App.data.storage[findSID];
						
			var rX:int;
			var rZ:int;
			var findFreePos:Boolean = false;
			
			// Ищем свободную ячейку.
			do
			{
				rX = int( Math.random() * Map.cells );
				rZ = int( Math.random() * Map.rows );
				
				if (Invader.checkFreeNode(rX, rZ, findUnit)){
					findFreePos = true;
				}
				
			}
			while (!findFreePos)
					
			// Создаем инвейдера.
			new Invader({
				sid:findSID,
				x:	rX,
				z:	rZ
			});
		}
				
		static private var invaderList:Array;
		public static function start ():void {
			if (App.data.options.hasOwnProperty('InvaderList')) {
				try {
					invaderList = JSON.parse(App.data.options.InvaderList) as Array;
					qIDs = [];
					for each (var invader:Object in invaderList  ) {
						for each(var qid:int in invader.QIDs)
							qIDs.push(qid);
							
						invader = invaderCheck(invader);
						
						init (invader); 
					}
				}catch(e:*) {}
			}
		}
		
		/**
		 * Дополнительная проверка инвейдера.
		 */
		static private function invaderCheck(invader:Object):Object 
		{
			// Условие для инвейдера 3655
			if (invader.SIDs[0] == "3655" && App.user.mode != User.GUEST) {
				
				if ( App.map.id == 1341 && Map.findUnits([3649]).length > 0)
				{
					// подмениваем на другого инвейдера
					invader.SIDs[0] = "3656";
				}
				
			}
			
			return invader;
		}
		
		public static function checkAllSets(object:Object):Boolean { // выполняем проверку можем ли мы добавить нового захватчика // true - создаем	
			var flag:Boolean = true;
			var check:Boolean = false;
			if (object.SIDs[0] == 3262)
				trace();
			if (object.hasOwnProperty('QIDs') && object.QIDs.length > 0 )
				flag = chekQuest(object.QIDs);
			if ( object.home.length > 0 ) {
				var _units:Array = Map.findUnits(object.home);
					if ( !(_units.length > 0 && _units[0].level < _units[0].totalLevels) )
						flag = chekQuest(object.QIDs);
					else
						flag = true;
			}
			if ( object.hasOwnProperty('sQIDs') && object.sQIDs.length > 0 )
				flag = chekQuest(object.sQIDs,true);
			if (object.hasEvent) {
				if (Events.timeOfComplete < App.time)
					flag = false;
			}

			if ( object.mIDs && object.mIDs.length > 0 )
			{
				check = false;
				for each( var _mID:Object in object.mIDs )
					if (App.map.id == _mID)
						check =  true;
				flag = (check)?flag:false;
			}
			if (object.soc.indexOf ("ALL") == -1) { 
				if (object.soc.length == 0){
					flag = false;
				}else {
					check = false;
					for each ( var soc:String in object.soc)
						if (App.isSocial (soc))
							check = true;
					flag = (check)?flag:false;
				}
			}
			if (object.hasOwnProperty('mxlvlU')) // Достиг ли обьет необходимого уровня
			{
				var maxLvl:Object = App.user.storageRead('mxlvlU', null);
				if (!maxLvl || !maxLvl.hasOwnProperty(object.mxlvlU))
					flag = false;
			}
			
			if (object.hasOwnProperty('rQIDs') && object.rQIDs && object.rQIDs.length > 0)
			{					
				for (var index:* in object.rQIDs)
				{
					if (App.user.quests.data.hasOwnProperty(object.rQIDs[index]))
						if (App.user.quests.data[object.rQIDs[index]].finished != 0)
							flag = false;
				}
			}
			
			return flag;
		}
		public static function checkFreeNode(_x:int, _z:int,object:Object):Boolean
		{
			if (_x > Map.cells || _z > Map.rows)
				return false;
			var _info:Object = App.data.storage[object.sID || object.sid];
			var nodes:Object = App.map._aStarNodes;
			if ( !_info.hasOwnProperty ('area')||  _info.area.w == 0 || _info.area.h == 0 ){
				if (nodes[_x][_z].w == 0 && nodes[_x][_z].object == null && nodes[_x][_z].open == 1 && nodes[_x][_z].isWall == false && nodes[_x][_z].p == 0) 
					return true;
				else
					return false;
			}
			for (var i:uint = 0; i < _info.area.w; i++) {
				for (var j:uint = 0; j < _info.area.h; j++) {
					if (nodes[_x + i][_z + j].w == 1 || nodes[_x + i][_z + j].object != null || nodes[_x + i][_z + j].open == 0 
							|| nodes[_x + i][_z + j].isWall == true || nodes[_x + i][_z + j].p == 1)
						return false;
				}
			}
			return true;
		}
		public function setPosition ( object: Object):Object {
			if (object.x > Map.cells || object.z > Map.rows)
			{
				object.x = 0;
				object.z = 0;
			}
			var _x:int = object.x;
			var _z:int = object.z;
			var serchSet:int = 300;
			var widthArea:int = 0;
			var heightArea:int = 0;
			var subWidthArea:Number = 0;
			var subHeightArea:Number = 0;
			
			if ( object.hasOwnProperty("radius") && object.radius > 0 )
			{
				widthArea		= object.radius;
				heightArea		= object.radius;
				subWidthArea	= object.radius / 2;
				subHeightArea	= object.radius / 2;
			}
			if ( object.hasOwnProperty("onAllMap") && object.onAllMap )
			{
				widthArea	= Map.cells;
				heightArea	= Map.rows;
			}
			
			for (var count:int = 0; count < serchSet; ++count ) {
				_x = int(Math.random() * widthArea  + object.x - subWidthArea);
				_z = int(Math.random() * heightArea + object.z - subHeightArea);
				// check free node
				if (Invader.checkFreeNode(_x,_z,object))
					break;
			}
			if (count >= serchSet) {
				for ( count = 0; count < serchSet; ++count ) {
					_x = int(Math.random() * widthArea  + object.x - subWidthArea);
					_z = int(Math.random() * heightArea + object.z - subHeightArea);
					// check free node
					if (App.map._aStarNodes[_x][_z].w == 0 && App.map._aStarNodes[_x][_z].object == null  && App.map._aStarNodes[_x][_z].isWall == false && App.map._aStarNodes[_x][_z].p == 0) {
						break;
					}
				}
			}
			object.x = _x;
			object.z = _z;
			return object;
		}
		protected function get purchaseSettings():Object  {
			return {
			find:[weapoon],
			width:391,
			itemsOnPage:2,
			content:PurchaseWindow.createContent("Energy", { out:weapoon } ),
			title:'',
			description:'',
			callback:function(sID:int):void {
				var object:* = App.data.storage[sID];
				App.user.stock.add(sID, object);
			}};
		}
		public function get weapoon():int {
			if ( _rweapon != 0)
				return _rweapon;
			for (var s:String in require)
				return int(s);
			
			return 0;
		}
		public function inUpdate(sid:*):Boolean {
			var fsid:String = String(sid);
			
			for (var update:String in App.data.updatelist[App.social]) {
				if (App.data.updates.hasOwnProperty(update) && App.data.updates[update].social.hasOwnProperty(App.social) && App.data.updates[update].items && App.data.updates[update].items.hasOwnProperty(fsid)) {
					return true;
				}
			}
			
			return false;
		}
		private var _rweapoonSid:int;
		public function get _rweapon():int
		{
			if ( rweapon )
			{
				if ( !_rweapoonSid )
				{
					var _require:Object = { };
					for (var key:String in require)
					{
						if ( inUpdate(key ) )
						{
							_require[key] = require[key];
						}
						else
						{
							trace();
						}
					}
					require = _require;
					var rand:int = Math.floor ( Math.random() * Numbers.countProps(require));
					for (var item:String in require)
					{
						if ( rand == 0)
						{
							_rweapoonSid = int (item);
							var temp:Object = require[item]
							require = {};
							require[item] = temp;
						}
						rand--;
					}
				}
				return _rweapoonSid;
			}
			return 0;
		}
		
		private var killRadius:int = 24;
		/**
		 * Игрок кликнул по инвейдеру.
		 */
		public override function click():Boolean {
			if (!clickable) return false;
			if ( App.user.mode != User.OWNER ) return false;
			if (!App.map._aStarNodes[coords.x][coords.z].open) return false;
			
			if (sid == 3008 || sid == 3014 || sid == 3015)
			{	
				if (PetHouse.Instance && PetHouse.Instance.invaderClick(sid, onKillEvent))
				{
					stopWalking();
					stopRest();
					setRest(true);
					clickable = false;
				}
				else
					return false;
			}
			if (isComplex) {
				 //new ComplexCapturerWindow( {
					//sID:sid,
					//require:App.data.storage[sid].require,
					//invader: this
					//}).show();
				//return false;
			}
			//if (!cloudAnimal) {
				//showIcon('require', onIconClick, AnimalCloud.MODE_NEED);
			//}
			else {
				killCaprure();
			}
			return true;
		}
		
		private function showIcon():void {
			if (App.user.mode == User.GUEST)
				return;
			for (var reqid:* in info.require) {
				if (App.data.storage.hasOwnProperty(reqid) && App.data.storage[reqid].mtype != 3) {
					break;
				}
			}
			
			if (sid == 3008 || sid == 3014 || sid == 3015)
			{	
				if (PetHouse.Instance && PetHouse.Instance.ableToKillWithPet(sid))
				{
					drawIcon(UnitIcon.MATERIAL, reqid, 0, {
						//glow:		true,
						clickable:	true,
						stocklisten:	true
					});
				}
				else
				{
					drawIcon(UnitIcon.MATERIAL, reqid, info.require[reqid], {
						//glow:		true,
						clickable:	true,
						stocklisten:	true
					});
				}
			}
			else
				//if (App.user.stock.check(reqid, info.require[reqid]))
				//{
					drawIcon(UnitIcon.MATERIAL, reqid, info.require[reqid], {
						glow:		true,
						clickable:	true,
						stocklisten:	true
					});
				//}
				//else
				//{
					//drawIcon(UnitIcon.HUNGRY, reqid, info.require[reqid], {
						//glow:		true,
						//clickable:	true
					//});
				//}
		}
		public static function chekQuest(_qIDs:Array, hasFinish:Boolean = false):Boolean {
			var _start:Boolean = false;
			for each (var _qID:Object in _qIDs){
				if (App.user.quests.data.hasOwnProperty(_qID)) {
					if (!hasFinish && App.user.quests.data[_qID].finished != 0)
						continue;
					var quest:Object = App.data.quests[_qID];
					if (quest.dream && quest.dream != ''){
						for each(var dream:* in quest.dream) {
							if (dream == App.user.worldID) {
									_start = true;
								break;
							}	
						}	
					}
				}
			}
			return _start;
		}
		//override public function take():void 
		//{
			//if (sid == 1789)
				//trace();
			//super.take();
		//}
		public var defaultStopCount:uint = 4;
		private var stopCount:uint = defaultStopCount;
		private var restCount:uint = 0;
		
		
		override public function onLoop():void
		{	
			if (_framesType == STOP){
				stopCount--;
				if (stopCount <= 0){
					setRest();
				}
			}else if (rests.indexOf(_framesType) != -1 || _framesType == KILL) {
				restCount --;
				if (restCount <= 0){
					stopCount = generateStopCount();
					framesType = STOP;
					if (isDie) onKick();
				}
			}else {
				stopCount = defaultStopCount;
			}
		}
		public function setRest(die:Boolean = false):void {
			var randomID:int = int(Math.random() * rests.length);
			var randomRest:String = rests[randomID];
			if ( die )
			{
				if (textures.hasOwnProperty('sprites') && textures.sprites.length > 1) {
					var levelData:Object = textures.sprites[1];
					additionalBitmap.bitmapData = levelData.bmp;
					
					additionalBitmap.x = levelData.dx;
					additionalBitmap.y = levelData.dy;
					
				}
			}
			restCount = generateRestCount();
			if (randomRest)
				framesType = randomRest;
			if (textures.animation.animations.hasOwnProperty(KILL) && die) 
				framesType = KILL;
			//startSound(randomRest);
		}
		public function generateStopCount():uint {
			return int(Math.random() * 5) + 5;
		}
		public function generateRestCount():uint {
			return 1;// int(Math.random() * )
		}
		public var rests:Array = [];
		public function getRestAnimations():void {
			rests = [];
			for (var animType:String in textures.animation.animations){
				if (animType.indexOf('rest') != -1){
					rests.push(animType);
				}
			}
		}
		public function onKillEvent(error:int, data:Object, params:Object = null):void
		{
			if (error) {
				Errors.show(error, data);
				return;
			}
			isDie = true;
			clickable = false;
			touchable = false;
			if (  data.unit) {
				createDecor(data.unit);
			}
			if (data.hasOwnProperty("bonus")) {
				Treasures.bonus(data.bonus, new Point(this.x, this.y + 30));
				SoundsManager.instance.playSFX('bonus');
				
				App.user.storageStore('boss', null, true);
				zooOpen(data.bonus);
			}
			//hide();
			clearIcon();
			
		}
		private function zooOpen(bonus:Object):void
		{
			//var zoo:Array = Map.findUnitsByType(['Zoo']);
			//for each (var ins:Object in zoo)
			//{
				//if (zoo.length && ins is Zoo)
				//{
					//for each(var material:Object in (ins as Zoo).info.items.obj)
					//{
						//if (bonus.hasOwnProperty (material))
						//{
							//App.map.focusedOnCenter(ins, true, null, true, App.map.scaleX);
							//(ins as Zoo).click();
						//}
					//}
				//}
			//}
		}
		private var additionalBitmap:Bitmap;
		public function show():void {
			var that:* = this;
			TweenLite.to(this, 1, { alpha:1, onComplete:function():void {}, onUpdate:function():void {} } );
		}
		public function onLoad(data:*):void {
			
			if (sid == 3015)
				trace();
			
			textures = data;
			this.alpha = 0;
			addAnimation();
			startAnimation();
			if (textures.hasOwnProperty('sprites') && textures.sprites.length > 0) {
				var levelData:Object = textures.sprites[0];
				additionalBitmap = new Bitmap(levelData.bmp);
				levelData.smoothing = true;
				addChildAt(additionalBitmap, 0);
				
				additionalBitmap.x = levelData.dx;
				additionalBitmap.y = levelData.dy;
			}
			App.map.sorted.push(this);
			show();
			
			update();
			
			
			if (!isComplex)
				addIcon();
			getRestAnimations();
			createShadow();
			if (hasWalk && open)
				goHome();
		}
		/// has many require
		public function get isComplex():Boolean {
			if (Numbers.countProps(require) > 1 && !rweapon)
				return true;
				
			return false	
		}
		/// block for Fogs (gide invader on clouds)
		///
		override public function take():void 
		{
			super.take();
		}
		public function makeUnOpen():void 
		{
			clickable = false;
			touchable = false;
			if (User.inExpedition)
				visible = false;
		}
		override public function makeOpen():void {
			open = true;
			clickable = true;
			touchable = true;
			visible = true;
		}
		public var require:Object = { };
		
		public function killCaprure(buy:int = 0):void  {
			if ( buy == 0 && !App.user.stock.takeAll(require) ) {
				if (App.map.id != 3290)
				{
					if (PurchaseWindow.createContent("Energy", { out:weapoon } ).length < 1)
					{
						ShopWindow.findMaterialSource(weapoon);
					}
					else
					{
						new PurchaseWindow(purchaseSettings ).show();
					}
				}
				else
				{
					if (User.inExpedition)
					{
						new SimpleWindow( {
							title:Locale.__e('flash:1382952380254'),
							label:SimpleWindow.ATTENTION,
							text:Locale.__e("flash:1464787001000"),
							popup:true,
							buttonText:Locale.__e("flash:1382952379764"),
							confirm:function():void {
								Travel.findMaterialSource = weapoon;
								Travel.goHome();
							}
						}).show();
						return;
					}
				}
			}
			else {
				kick(buy);
				if (buy == 1) 
					if(  !App.user.stock.take ( Stock.FANT, info.devel.req[1].skip)) return;
				
			}
		}
		private var isDie:Boolean = false;
		private var settingsOn:Boolean = false;
		private var flying:Boolean;
		public function kick(buy:int):void {
			stopWalking();
			stopRest();
			setRest(true);
			clickable = false;
			//if (cloudAnimal) {
				//cloudAnimal.dispose();
				//cloudAnimal = null;
			//}
			var _id:int = id;
			if (purchaseable == 0 && settingsOn) {
				_id = 0;
			}
			Post.send( {
					ctr:'invader',
					act:'kill',
					uID:App.user.id,
					sID:sid,
					mID:_rweapon,
					wID:App.user.worldID,
					level:level,
					buy:buy,
					id:_id
				}, onKillEvent);
		}
		protected function onKick ():void {
			if (textures.animation.animations.hasOwnProperty(KILL))
			{
				onHide();
				return;
			}
			TweenLite.to(multiBitmap, 0.1, { ease:Circ.easeInOut, scaleX:0.95, scaleY:0.95, onComplete:function():void {
				
				TweenLite.to(multiBitmap, 0.1, { ease:Circ.easeInOut, scaleX:1, scaleY:1, onComplete:function():void {
					hide ();
				}});
			}});
		}
		protected function addIcon():void {
			if (!visible) return;
			showIcon();
		}
		private function onIconClick(... args):void {
			killCaprure();	
		}
		public function hide():void {
			TweenLite.to(this, 0.5, {alpha:0, onComplete:onHide, onUpdate:function():void {}} );
		}
	
		protected function createDecor(object:Object):void {
			var decor:Unit = Unit.add( object);
			//decor.buyAction();
		}
		public function onHide():void {
			
			//if ( purchaseable ){
				//removable = true;
				//onApplyRemove();
			//}
			if ( shake )
			{
				var invaders:Array = Map.findUnits(SIDs);
				for each (var inv:Invader in invaders)
				{
					if ( inv != this ) {
						TweenLite.to(inv, 1, { alpha:0, onCompleteParams:[inv], onComplete:function (... args):void {
							var invader:Invader = args[0] as Invader;
							
							var randPos:Object = setPosition( { x:0, y:0, radius: radius, onAllMap: invader.onAllMap , sid: invader.sid } );
							invader.placing(randPos.x, 0, randPos.z);
							
							TweenLite.to(invader, 1, { alpha:1 } );
						}, onUpdate:function():void {}} );
					}
				}
			}
			uninstall();
			
			if (spawnable) 
				Invader.start();
		}
		public override function uninstall():void
		{
			//if (cloudAnimal)
				//cloudAnimal.dispose();
			clearTimeout(timer);
		
			if (fog && fog.parent) {
				fog.parent.removeChild(fog);
				fog = null;
			}
			App.map.removeUnit(this);
		}
		public function createShadow():void {
			if (shadow) {
				removeChild(shadow);
				shadow = null;
			}
			if (textures && textures.animation.hasOwnProperty('shadow')) {
				shadow = new Bitmap(UserInterface.textures.shadow);
				addChildAt(shadow, 0);
				shadow.smoothing = true;
				shadow.x = textures.animation.shadow.x - (shadow.width / 2);
				shadow.y = textures.animation.shadow.y - (shadow.height / 2);
				shadow.alpha = textures.animation.shadow.alpha;
				shadow.scaleX = textures.animation.shadow.scaleX;
				shadow.scaleY = textures.animation.shadow.scaleY;
			}
		}
		
		override public function update(e:Event = null):void 
		{
			if (textures.animation == null)	// если в инвейдере нет аннимации
				return;
			
			if ( !textures.animation.animations.hasOwnProperty (STOP)  )
				return;
			super.update(e);
			
			
			//if (sid == 3008 || sid == 3014 || sid == 3015)
			//{
				//if (ableToKillWithPet())
				//{
					//if (!icon && !isDie)
						//addIcon();
				//}
				//else
				//{
					//clearIcon();
				//}
			//}
			//if (cloudAnimal) 
				//cloudAnimal.iconSetPosition();
		}
		public var timer:uint = 0;
		public var homeRadius:int = 5;
		public function goHome(_movePoint:Object = null):void // все функции для хотьбы и генерации рестов скопированы с workerunit_а  и personage_а 
		{
			clearTimeout(timer);
			//visible = true;
			if ( !visible || !hasWalk)
				return;
			if (move) {
				var time:uint = Math.random() * 5000 + 5000;
				timer = setTimeout(goHome, time);
				return;
			}
			
			
			var place:Object;
			if (_movePoint != null) {
				place = _movePoint;
			}else {
				place = findPlaceNearTarget({info:{area:{w:1,h:1}},coords:{x:this.movePoint.x, z:this.movePoint.y}}, homeRadius);
			}
			
			framesType = Personage.WALK;
			initMove(
				place.x,
				place.z,
				onGoHomeComplete
			);
		}
		//override public function initMove(cell:int, row:int, _onPathComplete:Function = null):void {
			////if (sid != 3063 || flying)
			////{
				////super.initMove(cell, row, _onPathComplete);
				////return;
			////}
			////Не пересчитываем маршрут, если идем в ту же клетку
			//onPathComplete = _onPathComplete;
			//if (_walk) {
				//if (path[path.length - 1].position.x == cell && path[path.length - 1].position.y == row) {
					//return;
				//}
			//}
			//
			//if (!App.map._aStarClearNodes)
				//return;
			//if (!(cell in App.map._aStarClearNodes)) {
				//return;
			//}
			//if (!(row in App.map._aStarClearNodes[cell])) {
				//return;
			//}
			//path = findPath(App.map._aStarClearNodes[this.cell][this.row], App.map._aStarClearNodes[cell][row], App.map._astar);
			//pathCounter = 1;
			//t = 0;
			//walking();
		//}
		public function onGoHomeComplete():void {
			//if (sid == 3063 || flying)
			//{
				//goHome();
				//return;
			//}
			stopRest();
			var time:uint = Math.random() * 5000 + 5000;
			timer = setTimeout(goHome, time);
		}
		public function stopRest():void {
			framesType = Personage.STOP;
			if (timer > 0)
				clearTimeout(timer);
		}
		override public function set state(state:uint):void {
			if (_state == state) return;
			
			switch(state) {
				case OCCUPIED: bitmap.filters = [new GlowFilter(0xFF0000, 1, 6, 6, 7)]; 
					if (additionalBitmap) additionalBitmap.filters = [new GlowFilter(0xFF0000, 1, 6, 6, 7)];break;
				case EMPTY: bitmap.filters = [new GlowFilter(0x00FF00, 1, 6, 6, 7)]; 
					if (additionalBitmap) additionalBitmap.filters = [new GlowFilter(0x00FF00, 1, 6, 6, 7)];break;
				case TOCHED:
					bitmap.filters = [new GlowFilter(0xFFFF00, 1, 6, 6, 7)];
					if (additionalBitmap) additionalBitmap.filters =  [new GlowFilter(0xFFFF00, 1, 6, 6, 7)];
				break;
				case HIGHLIGHTED: bitmap.filters = [new GlowFilter(0x88ffed, 0.6, 6, 6, 7)]; 
					if (additionalBitmap) additionalBitmap.filters = [new GlowFilter(0x88ffed, 0.6, 6, 6, 7)];break;
				case IDENTIFIED: bitmap.filters = [new GlowFilter(0x88ffed, 1, 8, 8, 10)];
					if (additionalBitmap) additionalBitmap.filters = [new GlowFilter(0x88ffed, 1, 8, 8, 10)];break;
				case DEFAULT: 
					bitmap.filters = [];
					if (additionalBitmap)
						additionalBitmap.filters = [];
				break;
			}
			_state = state;
		}
		override public function get bmp():Bitmap {
			if (bitmap.bitmapData && bitmap.bitmapData.getPixel(bitmap.mouseX, bitmap.mouseY) != 0)
				return bitmap;
			if (additionalBitmap && additionalBitmap.bitmapData && additionalBitmap.bitmapData.getPixel(additionalBitmap.mouseX, additionalBitmap.mouseY) != 0)
				return additionalBitmap;	
			
			for (var _name:* in multipleAnime) {
				var _bitmap:Bitmap = multipleAnime[_name].bitmap;
				if (_bitmap.bitmapData.getPixel(_bitmap.mouseX, _bitmap.mouseY) != 0)
					return _bitmap
			}
			if (additionalBitmap)
				return additionalBitmap;
				
			return bitmap;
		}
	}
}