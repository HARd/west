package units 
{
	import astar.AStarNodeVO;
	import core.IsoTile;
	import core.Post;
	import flash.geom.Point;
	import ui.UnitIcon;
	import wins.ConstructWindow;
	import wins.StallWindow;
	public class Stall extends Hut 
	{
		public var animals:Vector.<*> = new Vector.<*>;
		public var bonuses:Vector.<Object> = new Vector.<Object>;
		public var capacity:uint;
		public var foodSID:uint;
		public var currFoodCount:int = 0;
		public var hasStorage:Boolean = false;
		public var limit:int = 0;
		
		//public var animals:Array = [];
		
		
		  /*
            перебираем животных
            $_animal['animal'] - уровень/стадия животного
            $_animal['started'] - время последнего кормления
            $_animal['feeds'] - кол-во кормлений на уровне
        */
			
		public function checkStallAnimals(animals:Object, sid:int):* {
			var stallInfo:Object = App.data.storage[sid];
			for each(var _animal:Object in animals) {
				_animal['next'] = false;
				var _info:Object = App.data.storage[_animal.sid];
				var _devel:Object = _info.devel;
				var _nextfeed:int = App.time;
				
				for (var foodID:* in _devel.obj[_animal.animal]) break;
				
				/*if (foodID != StallWindow.FOOD) {
					_animal['remove'] = true;
					continue;
				}*/
				
				/*если животное не голодно пытаемся собрать награду*/
				if (_animal.started > 0) {
					
					if (!_devel.req.hasOwnProperty(_animal.animal)) {
						_animal['remove'] = true;
						continue;
					}
					/*время сбора еще не настало*/
					if (App.time < _animal.started + _devel.req[_animal.animal].t) continue;              
					
					/*собираем клад*/
					hasStorage = true;
					
					//$treasure = $_devel['req'][$_animal['animal']]['tr'];
					//$this->data['storage'] = Treasure::merge($this->data['storage'], Treasure::generate($treasure, $treasure));
					/*собираем выходной материал*/
					//foreach($_devel['rew'][$_animal['animal']] as $_rsid => $_rcount)
					//$this->data['storage'] = Treasure::merge($this->data['storage'], array($_rsid => array(1 => $_rcount)));
					
					/*устанавливаем что животное голодно*/
					_nextfeed = _animal.started;
					_animal.started = 0;
					
					/*если достигнул лимит сбора переходи на следующую стадию*/
					if(_animal.feeds >= _devel.req[_animal.animal].c){
						_animal.animal++;
						
						/*если стадий больше нету удаляем животное*/
						if(!_devel.obj.hasOwnProperty(_animal.animal)) {
							_animal['remove'] = true;
							//$treasure = Treasure::generate($_info['treasure'], $_info['treasure']);
							//$this->data['storage'] = Treasure::merge($this->data['storage'], $treasure);
							continue;
						} else {
							_animal.feeds = 0; /*сбрасываем счетчик сбора*/
						}
					} 
					/*время следующего сбора*/
					_nextfeed += _devel.req[_animal.animal].t; 
				}
				
				if (currFoodCount <= 0) continue;
				
				if (!_devel.obj.hasOwnProperty(_animal.animal)) {
					_animal['remove'] = true;
					continue;
				}
				
				/*кормить нечем или неправильный корм*/
				if (currFoodCount - _devel.obj[_animal.animal][stallInfo['in']] < 0) continue;     
							
				/*кормим животное*/
				currFoodCount -= _devel.obj[_animal.animal][stallInfo['in']];// _devel.obj[_animal.animal][info['in']];
				_animal.started = _nextfeed;
				_animal.feeds++;
				
				/*можем ли мы продолжать кормить животное*/
				_animal['next'] = (_nextfeed < App.time)/* && ($this->data['count'] > 0)*/;
			}
			
			 /*
				если хоть одно животное 
				можно продолжать кормить 
				делаем рекурсию  
			*/
			
			for (var i:String in animals) {
				var animal:Object = animals[i];
				/*если животное было помеченно для удаления*/
				if (animal.hasOwnProperty('remove')) {
					delete animals[i];
					continue;
				} 
				 /*продолжаем кормить*/
				if(animal.next) {
					checkStallAnimals(animals, sid);
					break;
				}   
			}
		}	
		
		public function Stall(object:Object) 
		{
			currFoodCount = object['count'];
			
			if (object.hasOwnProperty('animals')) {
				checkStallAnimals(object.animals, object.sid);
				createAnimals(object.animals);
			}
			
			if (currFoodCount < 0) currFoodCount = 0;
			
			super(object);
			
			foodSID = info['in'];
			limit = info['limit'];
			
			if (animals.length > 0) {
				removable = false;
				moveable = false;
				rotateable = false;
			}
			
			capacity = stallCapacity;
			
			if (level >= 1) clearIcon();
			
			/*for each (var item:* in App.data.storage) {
				if (item.type == 'Animal')
					animals.push(item.sid);
			}*/
		}
		
		private function createAnimals(animals:Object):void {
			for (var anim:* in animals) {
				animals[anim]['index'] = anim;
				animals[anim].stallTarget = this;
				
				var animalInfo:Object = App.data.storage[animals[anim].sid];
				
				if (animals[anim].started > 0 && animals[anim].started < App.time) {
					animals[anim].started = animals[anim].started + animalInfo.devel.req[animals[anim].animal].t;
				}
				
				var unit:Unit = Unit.add(animals[anim]);
				World.tagUnit(unit);
				this.animals.push(unit);
			}
			
			App.map.allSorting();
		}
		
		override public function onLoad(data:*):void {
			super.onLoad(data);
			
			updateLevel();
			
			if (hasStorage) {
				showStorageIcon();
			}
		}
		
		public function showStorageIcon():void {
			drawIcon(UnitIcon.REWARD, 2, 1, {
				glow:		false
			});
		}
		
		override public function updateLevel(checkRotate:Boolean = false, mode:int = -1):void
		{
			if (level > totalLevels) {
				level = totalLevels;
			}
			
			if (textures == null)
				return;
			
			var levelData:Object;
			levelData = textures.sprites[level];
			
			if (levelData == null)
			{
				levelData = textures.sprites[0];
			}
			
			if (checkRotate && rotate == true) {
				flip();
			}
			
			draw(levelData.bmp, levelData.dx, levelData.dy);
			clearIcon();
		}
		
		override public function click():Boolean {
			
			if (cantClick)
				return false;
			
			if (App.user.mode == User.GUEST) {
				guestClick();
				return true;
			}
			
			if (!isReadyToWork()) return true;
			
			if (isPresent()) return true;
			
			if (isStorage()) return true;
			
			if (openConstructWindow()) return true;	
			
			openProductionWindow();
			
			return true;
		}
		
		override protected function onBuyAction(error:int, data:Object, params:Object):void
		{
			super.onBuyAction(error, data, params);
			
			//if (App.user.instance[sid]) 
			//{
				//App.user.instance[sid] ++;
			//}else 
			//{
				//App.user.instance[sid] = 1;
			//}
			
			Storage.instanceAdd(sid)
		}
		
		public function isStorage():Boolean
		{
			if (hasStorage) {
				hasStorage = false;
				clearIcon();
				
				var that:* = this;
				Post.send({
					ctr:this.type,
					act:'storage',
					uID:App.user.id,
					id:this.id,
					wID:App.user.worldID,
					sID:this.sid
				}, function(error:int, data:Object, params:Object):void {
					if (error) {
						return;
					}
					
					if (data.hasOwnProperty('bonus')) {
						Treasures.bonus(data.bonus, new Point(that.x, that.y));
					}
					checkAnimals();
					clearIcon();
				});
				
				return true;
			}
			return false;
			
		}
		
		override public function openConstructWindow():Boolean 
		{
			if(level == 0) {
				if (App.user.mode == User.OWNER)
				{
					if (hasUpgraded)
					{
						drawIcon(UnitIcon.BUILD, null);
						
						new ConstructWindow( {
							title:			info.title,
							upgTime:		info.devel.req[level + 1].t,
							request:		info.devel.obj[level + 1],
							reward:			{},//info.devel.rew[level + 1],
							target:			this,
							win:			this,
							onUpgrade:		upgradeEvent,
							hasDescription:	true
						}).show();
						
						return true;
					}
				}
			}
			return false;
		}
		
		override public function openUpgradeWindow(sidKettle:int = 0):void 
		{
			new ConstructWindow({
				mode:ConstructWindow.UPGRADE,
				title:			info.title,
				upgTime:		info.devel.req[level + 1].t,
				request:		info.devel.obj[level + 1],
				reward:			{},
				target:			this,
				win:			this,
				timeWorkLabel:  Locale.__e("flash:1433776819660"),
				onUpgrade:		upgradeEvent,
				hasDescription:	true,
				sidKettle:      StallWindow.FOOD
			}).show();
		}
		
		override public function openProductionWindow(settings:Object = null):void {	
			new StallWindow( {
				target:		this
			}).show();
		}
		
		public function checkAnimals():void {
			for each (var a:* in animals) {
				if (a.started == 0 && currFoodCount >= a.info.devel.obj[a.animal][info['in']]) {
					currFoodCount -= a.info.devel.obj[a.animal][info['in']];
					a.started = App.time + a.info.devel.req[a.animal].t;
					a.startWork();
					if (a is Animal) a.clearIcon();
					else {
						a.checkState();
						a.showIcon();
					}
				} 
			}
		}
		
		public function feedAnimals():void {
			for each (var animal:* in animals) {
				if (animal.started == 0) animal.feedEvent();
			}
		}
		
		public function takeBonuses():void {
			for each (var bonus:Object in bonuses) {
				Treasures.bonus(Treasures.convert(bonus), new Point(this.x, this.y));
			}
			bonuses = new Vector.<Object>;
		}
		
		public function removeAnimal(anim:*):void {
			for (var i:* in animals) {
				if (animals[i].id == anim.id && animals[i].started == anim.started) animals.splice(i, 1);
			}
			if (animals.length == 0) {
				removable = true;
				moveable = true;
			}
		}
		
		public function containsAnimal(anim:*):Boolean {
			for (var i:* in animals) {
				if (animals[i].id == anim.id && animals[i].started == anim.started) return true;
			}
			return false;
		}
		
		public function get stallCapacity():int {
			if (info.hasOwnProperty('devel') && info.devel.hasOwnProperty('req') && info.devel.req.hasOwnProperty(level)) {
				return info.devel.req[level].c;
			}
			
			return 0;
		}
		
		override public function take():void {
			if (!takeable) return;
			var node:AStarNodeVO;
			var part:AStarNodeVO;
			var water:AStarNodeVO;
			
			var nodes:Vector.<AStarNodeVO> = new Vector.<AStarNodeVO>();
			var waters:Vector.<AStarNodeVO> = new Vector.<AStarNodeVO>();
			var parts:Vector.<AStarNodeVO> = new Vector.<AStarNodeVO>();
			
			for (var i:uint = 0; i < cells; i++) {
				for (var j:uint = 0; j < rows; j++) {
					node = App.map._aStarNodes[coords.x + i][coords.z + j];
					
					nodes.push(node);
					
					node.isWall = false;
					node.b = 0;
					node.object = this;
					if (layer == Map.LAYER_FIELD || layer == Map.LAYER_LAND) node.isWall = false;
					
					
					if (i> 0 && i < cells - 1 && j>0 && j < rows -1) {
						part = App.map._aStarParts[coords.x + i][coords.z + j];
						parts.push(part);
						
						part.isWall = false;
						part.b = 0;
						part.object = this;
						if (layer == Map.LAYER_FIELD || layer == Map.LAYER_LAND) part.isWall = false;
						
						if (info.base != null && info.base == 1)
						{
							if (App.map._aStarWaterNodes != null)
							{
								water = App.map._aStarWaterNodes[coords.x + i][coords.z + j];
								waters.push(water);
								water.isWall = false;
								water.b = 0;
								water.object = this;
							}
						}
					}else {
						part = App.map._aStarParts[coords.x + i][coords.z + j];
						parts.push(part);
						
						part.isWall = false;
						part.b = 1;
						part.object = this;
						
						node.isWall = false;
						node.b = 1;
						
						if (info.base != null && info.base == 1)
						{
							if (App.map._aStarWaterNodes != null)
							{
								water = App.map._aStarWaterNodes[coords.x + i][coords.z + j];
								waters.push(water);
								water.isWall = false;
								water.b = 1;
								water.object = this;
							}
						}
					}
					
					var lm:int = 5;
					if (sid == 1478) lm = 2;
					if (i > 0 && i < lm && j > 0 && j < lm) {
						part.isWall = true;
						part.b = 1;
						part.object = this;
						
						node.isWall = true;
						node.b = 1;
					}
					
				}
			}
			
			if(layer == Map.LAYER_SORT){
				App.map._astar.take(nodes);
				App.map._astarReserve.take(parts);
			}
			
			if (info.base != null && info.base == 1) {
				if (App.map._astarWater != null)
					App.map._astarWater.take(waters);
			}
		}
		
		override public function calcDepth():void {
			var left:Object = { x:x - IsoTile.width * rows * .5, y:y + IsoTile.height * rows * .2 };
			var right:Object = { x:x + IsoTile.width * cells * .5, y:y + IsoTile.height * cells * .2 };
			depth = (left.x + right.x) + (left.y + right.y) * 100;
		}
		
		private var currentNode:AStarNodeVO;
		override public function calcState(node:AStarNodeVO):int
		{
			for (var foodID:* in food) break;
			for (var i:uint = 0; i < cells; i++) {
				for (var j:uint = 0; j < rows; j++) {
					node = App.map._aStarNodes[coords.x + i][coords.z + j];
					for each (var an:* in ans) {
						if (an.coords.x == coords.x  + i && an.coords.z == coords.z + j) {
							return OCCUPIED;
						}
					}
					if (node.b != 0 || node.open == false || (node.object != null && (node.object is Animal) && node.b != 0)) {
						return OCCUPIED;
					}
				}
			}
			return EMPTY;
		}
		
		private var ans:Array;
		override public function set move(move:Boolean):void {			
			if (move)
				ans = Map.findUnitsByType(['Animal', 'Tree']);
			else 
				ans = [];
				
			super.move = move;
		}
		
		override public function uninstall():void {
			for (var i:int = 0; i < animals.length; i++ ) {
				animals[i].uninstall();
			}
			animals = null;
			super.uninstall();
		}
		
	}

} 