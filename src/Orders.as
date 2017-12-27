package
{
	import astar.AStarNodeVO;
	import units.Order;
	/**
	 * ...
	 * @author 
	 */
	public class Orders
	{
		public var sIDs:Array = [93];
		public static var levels:Object = {}
		public var ordersLimit:int = 3;
		public function Orders()
		{
			App.self.addEventListener(AppEvent.ON_GAME_COMPLETE, init);
		}
		
		private function init(e:AppEvent):void 
		{
			return;
			var orders:Array = Map.findUnits(sIDs);
			var neededOrders:int = ordersLimit - orders.length;
			if (neededOrders > 0){
				for (var i:int = 0; i < neededOrders; i++) {
					var orderID:String = takeOrderID();
					addNewOrder(orderID);
				}
			}
		}
		/*
		_id - идентификатор
		in - входящие материалы
		out - награда
		pers - перс
		skip
		lfrom
		lto
		*/
		
		public function takeOrderID():String 
		{
			var results:Array = [];
			for (var ID:* in App.data.orders) 
			{
				var order:Object = App.data.orders[ID];
				order['ID'] = ID;
				if (App.user.level >= order.lfrom && App.user.level <= order.lto)
				{
					results.push(ID);
				}
			}
			
			var id:int = Math.random() * results.length;
			return results[id];
		}
		
		public function addNewOrder(oID:String):void {
			var tries:int = 100;
			//Делаем не больше 100 попыток найти свободное место
			while(tries>0){
				var randX:int = 50 + Math.random() * 10;
				var randZ:int = 50 + Math.random() * 10;
				var node:AStarNodeVO = App.map._aStarNodes[randX][randZ];
				
				if (node.b == 0 && node.p == 0) {
					new Order({oID:oID, sid:App.data.orders[oID].pers, x:randX, z:randZ});
					return;
				}
				tries--;
			}
		}
	}
}