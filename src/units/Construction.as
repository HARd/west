package units 
{
	import core.Load;

	public class Construction extends Unit
	{
		
		public var level:uint = 0;
		public var totalLevels:uint = 0;
		
		public function Construction(object:Object) 
		{
			layer = Map.LAYER_SORT;
			
			super(object);
			
			for each(var devel:String in info.devel) totalLevels++;
			
			Load.loading(Config.getSwf(type, info.view), onLoad);
		}
		
		private function onLoad(data:*):void {
			textures = data;
			updateLevel();
		}
		
		public function updateLevel(checkRotate:Boolean = false):void {
			var levelData:Object = textures.sprites[this.level];			
			
			if (checkRotate && rotate == true) {
				flip();
			}
			
			draw(levelData.bmp, levelData.dx, levelData.dy);
			
			if (textures.hasOwnProperty('animation')){
				addAnimation();
				if (level == totalLevels){
					setTimeout(
						function():void {
							startAnimation();
						}, Math.random() * 1000
					);
				}	
			}
		}
		
		public function upgradeEvent(params:Object):void {
			
			// Забираем материалы со склада
			for (var sID:* in params.m){
				App.user.stock.take(sID, params.m[sID]);
			}
			
			this.level++;
			
			updateLevel(true);
			var fast:uint = params[Stock.FANT] || 0;
			
			corePost.send( {
				ctr:this.type,
				act:'upgrade',
				uID:App.user.id,
				id:this.id,
				wID:App.user.worldID,
				sID:this.sid,
				fast:fast
			},onUpgradeEvent, params);
		}
		
		public function onUpgradeEvent(error:int, data:Object, params:Object):void {
			
			if (error) {
				Errors.show(error, data);
				//Возвращаем как было
				for (var id:* in params) {
					App.user.stock.data[id] = params[id];
				}
				
				this.level--;
				updateLevel();
			}
		}
		
	}

}