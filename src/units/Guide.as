package units 
{
	import astar.AStarNodeVO;
	import com.greensock.TweenLite;
	import core.Load;
	import flash.display.Bitmap;
	import wins.ShipWindow;
	import wins.SimpleWindow;
	import wins.TravelWindow;
	
	public class Guide extends Building//Personage
	{
		
		public var walkable:Boolean = false;
		//public var gloweble:Boolean = true;
		
		//public var level:int		= 0;
		//public var totalLevels:int	= 0;
		
		public function Guide(object:Object)
		{
			
			//info = App.data.storage[object.sid];
			
			super(object);
			
			moveable = false;
			clickable = true;
			touchable = true;
			removable = false;
			stockable = false;
			rotateable = false;
			
			info['area'] = { w:1, h:1 };
			//velocities = [0.05];
		}
		
		
		override public function click():Boolean {
			if (App.user.mode != User.OWNER) {
				return false;
			}
			if (App.user.quests.tutorial) {
				Tutorial.boxInterface();			
			} else {
			// Если не туторил
			var text:String = Locale.__e('flash:1429185230673');
			if (sid == 905) {
				if (App.isSocial('AI')) {
					text = Locale.__e('flash:1442504324546');
					if (!App.user.quests.tutorial) {
						new SimpleWindow( {
							label:SimpleWindow.ATTENTION,
							title:Locale.__e("flash:1429185188688"),
							text:text,
							height:300
						}).show();
					}
				} else {				
					if (openConstructWindow()) return true;
					
					var lands:Array = [];
					for (var each:String in info.lands) {
						lands.push(info.lands[each]);
					}
					TravelWindow.show( { findTargets:lands } );
				}
			} else {
				if (!App.user.quests.tutorial) {
					//if (App.isSocial('FB','NK','SP','MX','AI')) {
						//new SimpleWindow( {
							//label:SimpleWindow.ATTENTION,
							//title:Locale.__e("flash:1429185188688"),
							//text:text,
							//height:300
						//}).show();
						//return false;
					//}
					if (level < totalLevels) {
						openConstructWindow();
						return true;
					}
					
					new ShipWindow( {
						target:this
					}).show();
				}
			}
			
			}
			return true;
		}
		
		override public function onLoad(data:*):void {
			textures = data;
			
			if (textures.hasOwnProperty('animation')) {
				if (textures.animation.animations.hasOwnProperty('walk')) {
					walkable = true;
				}
				
				addAnimation();
				initAnimation();
			}
			
			updateLevel();
			
			if (loader) {
				removeChild(loader);
				loader = null;
			}
		}
		
		override public function updateLevel(checkRotate:Boolean = false, mode:int = -1):void 
		{
			var levelData:Object;
			if (textures == null) return;
			
			if (sid == 315) {
				levelData = textures.sprites[level + App.user.ministock.level - 1];
			} else {
				if (level >= totalLevels && info.time == 0) {
					clickable = false;
					touchable = false;
				}
				
				levelData = textures.sprites[this.level];
			}
			
			if (levelData == null) {
				if (level > 0) {
					var lowLevel:int = level;
					while (lowLevel > 0) {
						if (textures.sprites[lowLevel]) {
							levelData = textures.sprites[lowLevel];
							break;
						}
						lowLevel--;
					}
				}
			}
			
			if (levelData == null) {
				if (textures.sprites[0]) {
					levelData = textures.sprites[0];
				}else {
					return;
				}
			}
			
			if (checkRotate && rotate == true) {
				flip();
			}
			
			if (this.level != 0 && gloweble) {
				var backBitmap:Bitmap = new Bitmap(bitmap.bitmapData);
				backBitmap.x = bitmap.x;
				backBitmap.y = bitmap.y;
				addChildAt(backBitmap, 0);
				bitmap.alpha = 0;
				
				TweenLite.to(bitmap, 0.4, { alpha:1, onComplete:function():void {
					removeChild(backBitmap);
					backBitmap = null;
				}});
				
				gloweble = false;
			}
			
			draw(levelData.bmp, levelData.dx, levelData.dy);
		}
		
		override public function showIcon():void {
			super.showIcon();
			
			if (App.user.mode == User.GUEST) {
				clearIcon();
			}
		}
		
		
		private function startRest():void { }
		
		override public function calcState(node:AStarNodeVO):int {
			return EMPTY;
		}
	}
}