package units
{
	import astar.AStarNodeVO;
	import core.Load;
	import core.Post;
	import core.TimeConverter;
	import flash.geom.Point;
	import ui.Cloud;
	import wins.CreateAnimalWindow;
	import wins.FurryWindow;
	import wins.SimpleWindow;
	
	public class Wigwam extends Building
	{
		public var energy:uint = 0;
		public var slaveCount:uint = 0;
		public var animal:uint = 0;
		public var base:uint = 0;
		public var price:Object = 0;
		public var time:uint = 0;
		public var finished:uint = 0;
		public var params:Object = null;
		public var technoToDelete:Array = new Array;
		public var workers:Array = new Array;
		
		public function Wigwam(object:Object)
		{
			layer = Map.LAYER_SORT;
			//trace(App.data.storage[object.sid]);
			energy = App.data.storage[object.sid].energy || energy;
			animal = object.animal || animal;
			price = App.data.storage[object.sid].price;
			slaveCount = App.data.storage[object.sid].outs[Ttechno.TECHNO];
			time = App.data.storage[object.sid].time;
			
			super(object);
			totalLevels = 2;
			finished = object.finished;			
			touchableInGuest = false;
			
			if (object.hasOwnProperty('workers'))
			{
				for each (var worker:uint in object.workers)
				{
					workers.push(worker)
				}				
			}
			
			framesType = 'sphere';
			
			Load.loading(Config.getSwf(type, info.view) + '?1', onLoad);
			addTip();
			//flagable = false;
			//flag = false;
			//if (App.user.mode == User.GUEST) 
			//{
				//flagable	= true
			//}
			//
			if (App.map._aStarNodes[coords.x][coords.z].w == 1)
			{
				base = 1;
			}
			
			scaleX = scaleY = 1;
		}
		
		private function addTip():void
		{
			tip = function():Object
			{
				if (finished != 0)
				{
					if (finished > App.time)
					{
						return {title: info.title, text: Locale.__e('flash:1470064226123', [TimeConverter.timeToStr(finished - App.time)]), timer: true}
					}
					else
					{
						return {title: info.title, text: Locale.__e('flash:1396606659545')}
					}
				}else 
				if (level == totalLevels) 
				{
					return {title: Locale.__e('flash:1470058095169'), text: Locale.__e('flash:1470058116768')}
				}
				
				return {title: info.title, text: info.description}
			}
		}
		
		private function progressToDie():void
		{
			if (finished <= App.time && finished != 0)
			{		
				finished = 0;
				App.self.setOffTimer(progressToDie);
				level++;
				updateLevel();				
				App.self.setOnTimer(checkTechnoToRemove)
				checkTechnoToRemove();
			}		
		}
		
		private function checkTechnoToRemove():void
		{
			var count:uint = 0;
			if (technoToDelete.length == slaveCount) {
				return;
			}else {
				for (var j:int = 0; j < workers.length; j++)
				{
					for (var i:int = 0; i < App.user.techno.length; i++)
					{						
						if (App.user.techno[i].isFree() && workers[j] == App.user.techno[i].id && App.user.techno[i] is Ttechno)
						{
							if (technoToDelete.length < slaveCount)
							{
								technoToDelete.push(App.user.techno[i]);
								App.user.techno[i].wigwam(true);
							}else
							{
								App.self.setOffTimer(checkTechnoToRemove);
								return
							}							
						}
					}
				}
				
			}		
		}
		
		override public function onLoad(data:*):void
		{			
			super.onLoad(data);			
			textures = data;
			
			if (finished != 0)
			{
				level = 1;					
				App.self.setOnTimer(progressToDie);
				progressToDie()
			}
			
			if (App.user.mode == User.GUEST) 
			{					
			}
			
			updateLevel();
		}
		
		override public function onGuestClick():void 
		{
			super.onGuestClick();
			//cloud.dispose();
		}
		
		public function create(params:Object):void
		{			
			Post.send({ctr: 'wigwam', act: 'hire', uID: App.user.id, wID: App.user.worldID, sID: this.sid, id: id, energy: params.energy, ids: JSON.stringify(params.friends), buy: 0}, onBuyAction);
			
			App.self.setOnTimer(progressToDie);
			progressToDie()
			level++;
			updateLevel();
		}
		
		public function boost(params:Object):void
		{			
			Post.send({ctr: 'wigwam', act: 'hire', uID: App.user.id, wID: App.user.worldID, sID: this.sid, id: id, energy: params.energy, ids: JSON.stringify(params.friends), buy: 1}, onBuyAction);
			App.self.setOnTimer(progressToDie);
			progressToDie()
			level++;
			updateLevel();
		}
		
		override protected function onBuyAction(error:int, data:Object, params:Object):void
		{
			if (error)
			{
				Errors.show(error, data);
				return;
			}
			
			//flag = false;
			if (type != "Trade" && type != 'Tree' && level <= totalLevels - craftLevels)
			{
			}
			
			if (data.hasOwnProperty('finished'))
			{
				finished = data.finished;
			}
			
			if (data.hasOwnProperty('id'))
			{
				this.id = data.id;				
			}
			
			if (data.hasOwnProperty('units'))
			{
				for each (var worker:uint in data.units)
				{
					workers.push(worker)
				}
				removable = false;
			}
			
			addTip();
			var hasTechno:Boolean = false;
			var techno:Array = [];
			var reward:Object = info.outs;
			var _reward:Object = {};
			var worker_sid:int = Ttechno.TECHNO;//App.data.storage[App.user.worldID].techno[0];
			
			for (var _sid:*in reward)
			{
				if (App.data.storage[_sid].type == 'Ttechno')
				{
					hasTechno = true;
					worker_sid = _sid;
				}else
				{
					_reward[_sid] = reward[_sid];
				}
			}
			
			Treasures.bonus(Treasures.convert(_reward), new Point(this.x, this.y));
			
			removeEffect();
			
			//if (_cloud)
				//_cloud.dispose();
			//_cloud = null;
			
			if (hasTechno)
				addChildrens(worker_sid, data.units);
			
			openConstructWindow();
		}
		
		private function addChildrens(_sid:uint, ids:Object):void
		{
			var rel:Object = {};
			rel[sid] = id;			
			var unit:Unit;
			
			for (var i:*in ids)
			{
				var position:Object = getNearPosition();				
				unit = Unit.add({sid: _sid, id: ids[i], x: position.x, z: position.z, rel: rel});
				(unit as WorkerUnit).born();
			}
		}
		
		public function getNearPosition():Object
		{
			var object:Object = {x: info.area.w + 1, z: info.area.h - 1};
			var tries:int = 50;
			
			while (true)
			{
				var _object:Object = find();
				if (App.map._aStarNodes[_object.x] && App.map._aStarNodes[_object.x][_object.z] && !App.map._aStarNodes[_object.x][_object.z].object && App.map._aStarNodes[_object.x][_object.z].open == true)
				{
					return _object;
				}
				
				tries--;
				if (tries <= 0)
					break;
			}
			
			function find():Object
			{
				var _x:int = coords.x - 5 + int(Math.random() * (info.area.w + 10));
				var _y:int = coords.z - 5 + int(Math.random() * (info.area.h + 10));
				
				return {x: _x, z: _y}
			}
			
			return object;
		}
		
		override public function openConstructWindow():Boolean
		{
			return false;		
		}
		
		override public function openProductionWindow(settings:Object = null):void
		{
		}
		
		override public function storageEvent(value:int = 0):void
		{
			ordered = true;
			
			if (App.user.mode == User.GUEST)
				return;
			
			//checkTechnoToRemove()
			if ((technoToDelete.length == slaveCount && (App.user.mode != User.GUEST)))
			{				
				Post.send({ctr: 'wigwam', act: 'reward', uID: App.user.id, id: id, wID: App.user.worldID, sID: this.sid}, onStorageEvent);
			}else 
			{
				new SimpleWindow( {
					title:Locale.__e("flash:1382952379725"),
					label:SimpleWindow.ATTENTION,
					text:Locale.__e("flash:1470061202097")
				}).show();
			}
		}
		
		override public function onStorageEvent(error:int, data:Object, params:Object):void
		{
			if (error)
			{
				Errors.show(error, data);
				return;
			}
			
			this.visible = false;
			hasProduct = false;
			ordered = false;
			var outs:Object = Treasures.convert(info.outs)
			Treasures.bonus(data.bonus, new Point(this.x, this.y));
			uninstall();
		}
		
		override public function uninstall():void {
			//App.self.setOffTimer(checkTechnoToRemove);
			//removeWorkers();
			finishAnimation();
			super.uninstall();
		}
		
		override public function calcState(node:AStarNodeVO):int
		{
			var state:uint = EMPTY;
			base = 0;
			
			for (var i:uint = 0; i < cells; i++)
			{
				for (var j:uint = 0; j < rows; j++)
				{
					node = App.map._aStarNodes[coords.x + i][coords.z + j];
					
					if (node.b != 0 || node.open == false)
					{
						state = OCCUPIED;						
						break;
					}
				}
			}
			
			if (state == EMPTY)
				base = 0;
			
			if (state == OCCUPIED)
			{
				state = EMPTY;
				for (i = 0; i < cells; i++)
				{
					for (j = 0; j < rows; j++)
					{
						if (node.w != 1 || node.object != null || node.open == false)
						{
							state = OCCUPIED;
							break;
						}
					}
				}
				if (state == EMPTY)
					base = 1;
			}
			
			return state;		
		}
		
		public function addLevel():void
		{
			var levelData:Object = textures.sprites[1];
			draw(levelData.bmp, levelData.dx, levelData.dy);
			
			if (textures.hasOwnProperty('animation'))
			{
				addAnimation();
				startAnimation(true);
			}
		}
		
		public function addSlaves():void
		{
			var levelData:Object = textures.sprites[1];
			draw(levelData.bmp, levelData.dx, levelData.dy);
			
			if (textures.hasOwnProperty('animation'))
			{
				addAnimation();
				startAnimation(true);
			}
		}
		
		override public function updateLevel(checkRotate:Boolean = false, mode:int = -1):void
		{
			if (level > totalLevels)
			{
				level = totalLevels;
			}
			
			if (textures == null)
				return;
			
			var levelData:Object = textures.sprites[level];
			
			if (levelData == null)
				levelData = textures.sprites[0];
			
			if (checkRotate && rotate == true)
			{
				flip();
			}
			
			draw(levelData.bmp, levelData.dx, levelData.dy);
			
			checkOnAnimationInit();
		}
		
		override public function checkOnAnimationInit():void
		{
			
			if (level == totalLevels - craftLevels)
			{
				initAnimation();
				beginAnimation();
			}
			
			if (crafted == 0)
			{
				finishAnimation();
			}
			
			//if (_cloud)
				//setCloudCoords();
		}
		
		override public function click():Boolean
		{
			if (App.user.mode == User.OWNER)
			{
				if (level < totalLevels - 1)
				{					
					if (animal == 0)
					{
						var that:Wigwam = this;;
						new CreateAnimalWindow({sID: Ttechno.TECHNO/*App.data.storage[App.user.worldID].techno[0]*/, sphere: that}).show();						
					}
					return true;					
				}else if (level == totalLevels - 1)
				{					
					new FurryWindow({title: info.title, target: this, info: info, mode: FurryWindow.FURRY, finished:finished, 
					worker: 'Techno'}).show();					
					return true;
				}else if (level == totalLevels)
				{					
					storageEvent()
					return true;					
				}				
			}
			return false;
		}
		
		override protected function onStockAction(error:int, data:Object, params:Object):void {
			if (error) {
				return;
			}
			//hasUpgraded = false;
			//hasBuilded = true;
			//upgradedTime = App.time - 1000;
			//App.self.setOnTimer(upgraded);
			
			this.id = data.id;
			
			App.ui.glowing(this);
			World.addBuilding(this.sid);
			onAfterStock();
		}
	}
}
