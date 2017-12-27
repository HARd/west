package units 
{
	import adobe.utils.CustomActions;
	import com.adobe.air.net.events.ResourceCacheEvent;
	import core.Post;
	import wins.ConstructWindow;
	import wins.GardenWindow;

	public class Garden extends Stall 
	{
		public var trees:Vector.<Resource> = new Vector.<Resource>;
		public var positions:Array = [];
		public function Garden(data:Object) 
		{
			super(data);
			
			if (data.hasOwnProperty('slots')) {
				createTrees(data.slots);
			}
			
			if (formed && level > 0 && App.user.mode == User.OWNER) checkState();
		}
		
		private function initPositions():void {
			if (positions.length > 0) {
				positions = [];
			}
			
			switch (this.level) {
				case 1:
					positions.push({x:coords.x + 3, z:coords.z + 7});
					positions.push({x:coords.x + 3, z:coords.z + 11});
					positions.push({x:coords.x + 10, z:coords.z + 3});
					positions.push({x:coords.x + 10, z:coords.z + 7});
					positions.push({x:coords.x + 10, z:coords.z + 11});
					break;
				case 2:
					positions.push({x:coords.x + 3, z:coords.z + 7});
					positions.push({x:coords.x + 3, z:coords.z + 11});
					positions.push({x:coords.x + 7, z:coords.z + 2});
					positions.push({x:coords.x + 7, z:coords.z + 5});
					positions.push({x:coords.x + 7, z:coords.z + 8});
					positions.push({x:coords.x + 7, z:coords.z + 11});
					positions.push({x:coords.x + 10, z:coords.z + 2});
					positions.push({x:coords.x + 10, z:coords.z + 5});
					positions.push({x:coords.x + 10, z:coords.z + 8});
					positions.push({x:coords.x + 10, z:coords.z + 11});
					break;
				case 3:
					positions.push({x:coords.x + 1, z:coords.z + 7});
					positions.push({x:coords.x + 1, z:coords.z + 11});
					positions.push({x:coords.x + 5, z:coords.z + 7});
					positions.push({x:coords.x + 5, z:coords.z + 11});
					positions.push({x:coords.x + 3, z:coords.z + 9});
					positions.push({x:coords.x + 8, z:coords.z + 3});
					positions.push({x:coords.x + 8, z:coords.z + 5});
					positions.push({x:coords.x + 8, z:coords.z + 7});
					positions.push({x:coords.x + 8, z:coords.z + 9});
					positions.push({x:coords.x + 8, z:coords.z + 11});
					positions.push({x:coords.x + 10, z:coords.z + 3});
					positions.push({x:coords.x + 10, z:coords.z + 5});
					positions.push({x:coords.x + 10, z:coords.z + 7});
					positions.push({x:coords.x + 10, z:coords.z + 9});
					positions.push({x:coords.x + 10, z:coords.z + 11});
					break;
			}
		}
		
		public function createTrees(trees:Object):void {
			if (this.trees) {
				for each (var tr:Resource in this.trees) {
					tr.uninstall();
				}
			}
			this.trees = new Vector.<Resource>;
			initPositions();
			for (var tree:* in trees) {
				trees[tree]['index'] = tree;
				trees[tree]['multiple'] = false;
				
				var treeInfo:Object = App.data.storage[trees[tree].sid];
				
				if (trees[tree].end > 0 && trees[tree].end < App.time) {
					trees[tree].end = trees[tree].end;
				}
				
				var coord:Object = positions[tree];
				
				var unit:Unit = Unit.add(trees[tree]);
				(unit as Resource).garden = this;
				unit.placing(coord.x, 0, coord.z);
				unit.removable = false;
				unit.rotateable = false;
				unit.moveable = true;
				this.trees.push(unit as Resource);
				
				World.tagUnit(unit);
			}
			
			if (this.trees.length > 0) {
				removable = false;
				moveable = false;
				rotateable = false;
			} else {
				removable = true;
				moveable = true;
				rotateable = true;
			}
			
			App.map.allSorting();
		}
		
		public function findTree(index:int):Resource {
			for each (var tree:Resource in trees) {
				if (tree.inx == index)
					return tree;
			}
			
			return null;
		}
		
		public function removeTree(tree:Resource):void {
			for (var i:* in trees) {
				if (trees[i].inx == tree.inx && trees[i].end == tree.end) trees.splice(i, 1);
			}
			if (trees.length == 0) removable = true;
		}
		
		override public function openProductionWindow(settings:Object = null):void {	
			new GardenWindow( {
				target:		this
			}).show();
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
				sidKettle:      GardenWindow.FOOD
			}).show();
		}
		
		public function boostAction(treeID:int, callback:Function = null):void {
			if (!App.user.stock.take(Stock.FANT, info.devel.skip[level])) return;
			
			Post.send( {
				ctr:'Garden',
				act:'boost',
				uID:App.user.id,
				wID:App.user.worldID,
				sID:this.sid,
				iID:treeID,
				id:this.id
			}, function(error:int, data:Object, params:Object):void {	
				trees[treeID].end = App.time;
				
				if (data.hasOwnProperty('count'))
					currFoodCount = data.count;
					
				if (data.hasOwnProperty('slots')) {
					createTrees(data.slots);
				}
				
				if (callback != null)
					callback();
			});
		}
		
		public function checkState():void {		
			if (App.user.mode != User.OWNER) return;
			Post.send( {
				ctr:'Garden',
				act:'fill',
				uID:App.user.id,
				wID:App.user.worldID,
				sID:this.sid,
				id:this.id,
				count:0
			}, function(error:int, data:Object, params:Object):void {
				if (error) {
					//Errors.show(error, data);
					return;
				}
				if (data.hasOwnProperty('count'))
					currFoodCount = data.count;
					
				if (data.hasOwnProperty('slots')) {
					createTrees(data.slots);
				}
			});
		}
		
	}

}