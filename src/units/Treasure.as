package units 
{
	import core.Load;
	
	public class Treasure extends Unit{

		public function Treasure(object:Object)
		{
			layer = Map.LAYER_SORT;
			
			this.id = object.id || 0;
			
			super(object);
			layer = Map.LAYER_SORT;
			
			cells = 2;
			rows = 2;
			
			type = "Tools";
			
			clickable 			= false;
			touchableInGuest 	= false;
			
			Load.loading(Config.getSwf(type, 'box'), onLoad);
			
			/*
			tip = function():Object { 
				return {
					title:info.title,
					text:info.description
				};
			};
			*/
		}
		
		private function onLoad(data:*):void {
				
			textures = data;
			var levelData:Object = textures.sprites[0];			
			draw(levelData.bmp, levelData.dx, levelData.dy);
		}
		
		
	}
}