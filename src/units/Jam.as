package units 
{
	import api.ExternalApi;
	import astar.AStarNodeVO;
	import com.greensock.TweenLite;
	import core.Load;
	import core.Post;
	import ui.Hints;
	
	public class Jam extends Unit{

		public function Jam(object:Object)
		{
			layer = Map.LAYER_SORT;
			
			super(object);
			
			takeable			= false;
			clickable 			= false;
			touchableInGuest 	= false;
			
			Load.loading(Config.getSwf(type, info.preview), onLoad);
			
			tip = function():Object { 
				return {
					title:info.title,
					text:info.description
				};
			};
			
			if(formed)	addBear();
		}
		
		override public function take():void {
		
		}
		
		override public function free():void {
		
		}
		
		private function onLoad(data:*):void 
		{
			textures = data;
			var levelData:Object = textures.sprites[0];
			draw(levelData.bmp, levelData.dx, levelData.dy);
		}
		/*
		override public function buyAction():void {
			
			Hints.buy(this);
			
			Post.send( {
				ctr:this.type,
				act:'buy',
				uID:App.user.id,
				wID:App.user.worldID,
				sID:this.sid,
				x:coords.x,
				z:coords.z
			}, onBuyAction);
		}
		*/
		
		override protected function onBuyAction(error:int, data:Object, params:Object):void {
			if (error) {
				Errors.show(error, data);
				return;
			}
			
			this.id = data.id;
			addBear();
		}
		
		
		override protected function onStockAction(error:int, data:Object, params:Object):void {
			if (error) {
				Errors.show(error, data);
				return;
			}
			
			//Делаем push в _6e
			//if (App.social == 'FB') {
				//ExternalApi._6epush([ "_event", { "event": "use", "item": "jam" } ]);
			//}
			
			this.id = data.id;
			addBear();
		}
		
		private function addBear():void
		{
			var bear:Bear;
			/*var hungryBear:Object = Bear.findHungryBear();
			if (hungryBear.result == false)
			{
				bear = new Bear( { id:0, sid:Personage.BEAR, x:10, z:10 } ); 
				Unit.sorting(bear);
			}
			else
			{
				bear = hungryBear.bear;
				Unit.sorting(bear);
			}*/
			
			var _sID:uint = Personage.BEAR;
			if (App.data.storage[sid].view == 'fish')
				_sID = Personage.BEAVER;
			
			var place:Object = findBornNear(_sID);
			
				bear = new Bear( { id:0, sid:_sID, x:place.x, z:place.z } ); 
				bear.alpha = 0
				TweenLite.to(bear, 0.5, { alpha:1 } );
				Unit.sorting(bear);
				
				bear.action 		= Bear.ACTION_WALK;
				bear.framesType 	= Bear.ANIM_WALK;
				
				bear.addTarget({
					target:this,
					callback:bear.onBornEvent,
					event:Bear.ACTION_BORN,
					jobPosition:this.jobPosition
				});
				
		}
		
		private function get jobPosition():Object
		{
			var Y:int = -2;
			if (this.coords.z - 2 <= 0) Y = 0;
			
			var X:int = -1;
			if (this.coords.x - 1 <= 0) X = 0
			
			return { x: X, y: Y, direction:0,	flip:0 };
		}
		
		public function findBornNear(_sID:uint):Object
		{
			var radius:uint = 10;
			var places:Array = [];
			for (var pX:int = 0; pX < radius; pX++)
			{
				for (var pY:int = 0; pY < radius; pY++)
				{
					var placeX:int = coords.x - pX;
					var placeY:int = coords.z - pY;
					
					if (placeX <= 0 || placeY <= 0) continue;
					
					var place:Object;
					if(_sID == Personage.BEAR){
						place = App.map._aStarNodes[placeX][placeY];
						if (!place.isWall && place.p == 0)
							places.push( { x:placeX, z:placeY } );
						else
							continue;
					}else{
						place = App.map._aStarWaterNodes[placeX][placeY];
						if (!place.isWall)
							places.push( { x:placeX, z:placeY } );
						else
							continue;
					}
				}
			}
			
			if (places.length == 0)
			{
				places.push( { x:coords.x, z:coords.z } );
			}
			var random:uint = int(Math.random() * (places.length - 1));
			
			return places[random];
		}
		
		override public function calcState(node:AStarNodeVO):int
		{
			if (info.view == 'jam')
				return super.calcState(node);
				
			for (var i:uint = 0; i < cells; i++) {
				for (var j:uint = 0; j < rows; j++) {
					node = App.map._aStarNodes[coords.x + i][coords.z + j];
					if (node.w != 1 || node.open == false || node.object != null) {
						return OCCUPIED;
					}
				}
			}
			
			return EMPTY;
		}
	}
}