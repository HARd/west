package units
{
	import astar.AStarNodeVO;
	import com.greensock.TweenLite;
	import core.Load;
	import flash.events.Event;
	import flash.utils.setTimeout;
	
	
	public class Feed extends Unit{

		public var onBuyCallback:Function;
		public var energyObject:Object;
		
		public var workerCount:int = 2;
		public function Feed(object:Object)
		{
			layer = Map.LAYER_SORT;
			onBuyCallback = object.callback;
			energyObject  = object.energyObject;
			
			super(object);
			
			removable = false;
			stockable = false;
			
			Load.loading(Config.getSwf(type, info.view), onLoad);
			
			if (!formed) addEventListener(AppEvent.AFTER_BUY, onAfterBuy);
			
			tip = function():Object {
				return {
					title:info.title,
					text:info.description
				};
			};
		}
		
		//override public function take():void {}
		//override public function free():void {}
		
		override public function buyAction():void {
			onBuyCallback(this);
			moveable = false;
			touchable = false;
		}
		
		public function onAfterBuy(e:AppEvent):void
		{
			removeEventListener(AppEvent.AFTER_BUY, onAfterBuy);
		}
		
		public function onLoad(data:*):void {
			textures = data;
			var levelData:Object = textures.sprites[0];
			draw(levelData.bmp, levelData.dx, levelData.dy);
		}
		
		override public function click():Boolean {
			return true;
		}
		
		private var orders:Array = [];
		private var order:int = 0;
		public function getTechnoPosition():Object 
		{
			orders = [
				{x:coords.x - 1, z:coords.z + 1 },
				{x:coords.x + 1, z:coords.z - 1 }
				//{x:coords.x-1, z:coords.z-1},
				//{x:coords.x+1, z:coords.z+1},
				//{x:coords.x-3, z:coords.z-1},
				//{x:coords.x+3, z:coords.z+1}
			];
			
			if (orders.length <= order) order = orders.length - 1;
			
			var position:Object = orders[order];
			order ++;
			
			return position;
		}
		
		private var completeCounter:int = 0;
		public function completeFeedBuyWorker(worker:Techno):void {
			completeCounter ++;
			if (completeCounter >= workerCount) {
				setTimeout(hide, 500);
			}
		}
		
		private function hide():void {
			TweenLite.to(this, 1, {alpha:0, onComplete:uninstall})
		}
		
		/*override public function calcState(node:AStarNodeVO):int
		{
			for (var i:uint = 0; i < cells; i++) {
				for (var j:uint = 0; j < rows; j++) {
					node = App.map._aStarNodes[coords.x + i][coords.z + j];
					if (node.b != 0 || node.open == false || node.object != null)
					{
						return OCCUPIED;
					}
				}
			}
			
			return EMPTY;
		}*/
	}
}