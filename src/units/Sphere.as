package units
{
	import astar.AStarNodeVO;
	import core.Load;
	import core.Post;
	import wins.HutHireWindow;
	import wins.SelectAnimalWindow;

	public class Sphere  extends AUnit
	{
		public var energy:uint = 0;
		public var animal:uint = 0;
		public var base:uint = 0;
		
		public function Sphere(object:Object) 
		{
			layer = Map.LAYER_SORT;
			
			energy = object.energy || energy;
			animal = object.animal || animal;
			
			super(object);
			
			touchableInGuest = false;
			
			framesType = 'sphere';
			
			Load.loading(Config.getSwf(type, info.view)+'?1', onLoad);
			
			tip = function():Object {
				if (energy >= info.energy){
					return {
						title:info.title,
						text:Locale.__e("flash:1382952379956"),
						timer:false
					};
				}else if (energy == 0){
					return {
						title:info.title,
						text:Locale.__e("flash:1382952379957"),
						timer:false
					};
				}
				else
				{
					return {
						title:info.title,
						text:Locale.__e("flash:1382952379958", [info.energy - energy]),
						timer:false
					};
				}	
			};
			
			if (App.map._aStarNodes[coords.x][coords.z].w == 1) {
				base = 1;
			}
			
			scaleX = scaleY = 1;
		}
		
		override public function onLoad(data:*):void {
			
			super.onLoad(data);
			
			textures = data;
			
			var levelData:Object = textures.sprites[0];
			draw(levelData.bmp, levelData.dx, levelData.dy);
			
			if (textures.hasOwnProperty('animation')){
				addAnimation();
				startAnimation(true);
			}
		}
		
		override public function calcState(node:AStarNodeVO):int
		{
			var state:uint = EMPTY;
			base = 0;
			for (var i:uint = 0; i < cells; i++) {
				for (var j:uint = 0; j < rows; j++) {
					node = App.map._aStarNodes[coords.x + i][coords.z + j];
					if (node.b != 0 || node.open == false) {
						state = OCCUPIED;
						
						break;
					}
				}
			}
			if(state == EMPTY) base = 0;
			
			if (state == OCCUPIED) {
				state = EMPTY;
				for (i = 0; i < cells; i++) {
					for (j = 0; j < rows; j++) {
						if (node.w != 1 || node.object != null || node.open == false) {
							state = OCCUPIED;
							break;
						}
					}
				}
				if(state == EMPTY) base = 1;
			}
			
			return state;
		}
		
		override public function click():Boolean {
			if (!super.click()) return false;
			if (!formed) return false;
			
			if (animal == 0) {
				//trace('открытие окна ВЫБОРА животного');
				//TODO открытие окна ВЫБОРА животного
				var that:Sphere = this;
				new SelectAnimalWindow( { 
					sphere:this,
					callback:function(sID:uint):void {
						animal = sID;
						
						Post.send( {
							ctr:type,
							act:'set',
							uID:App.user.id,
							wID:App.user.worldID,
							sID:that.sid,
							id:that.id,
							asID:sID
						}, function(error:*, results:*, params:*):void {
							if (error) {
								Errors.show(error, results);
								animal = 0;
								return;
							}
							//TODO открытие окна СОЗДАНИflash:1382952380041 животного
							new HutHireWindow( { sID:animal, sphere:that} ).show();
							//trace('открытие окна СОЗДАНИflash:1382952380041 животного');
						});
					}
				}).show();
			}else {
				//trace('открытие окна СОЗДАНИflash:1382952380041 животного');
				new HutHireWindow( { sID:animal, sphere:this } ).show();
			}
			
			return true;
		}
	}
}