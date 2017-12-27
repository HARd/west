package units 
{
	import core.Load;
	import core.Post;
	import wins.ConstructWindow;
	/**
	 * ...
	 * @author ...
	 */
	public class Single extends Building
	{
		public static  var isSingle:Boolean = false;
		public function Single(object:Object) 
		{
			super(object);
			//id = 1;
			//App.user.mode = true;
			//totalLevels = 1;
			isSingle = true;
			moveable = true;
			removable = false;
			stockable = false;
			rotateable = false;
		}
		
		override public function load():void 
		{
			/*var curLevel:int = level;
			if (curLevel <= 0) curLevel = 1;
			
			if (info.devel.req[curLevel] == null) {
				curLevel --;
			}*/
			Load.loading(Config.getSwf(type, info.view), onLoad);
		}
		
		override public function updateLevel(checkRotate:Boolean = false, mode:int = -1):void 
		{
			if (textures == null) 
				return;
				
			if(level == 0)	{
				initAnimation();
				startAnimation();
			}else {
				clearAnimation();
				touchable = false;
			}
				
			var levelData:Object = textures.sprites[this.level];
			if (!textures.sprites.hasOwnProperty(this.level)) {
				levelData = textures.sprites[0];
			}
				
			draw(levelData.bmp, levelData.dx, levelData.dy);
		}
		
		public var reqLevel:int;
		override public function openConstructWindow():Boolean 
		{
			if (level == 1)
				return true;
			if (App.user.mode != User.OWNER)
				return false;
				
			for (var _level:* in info.devel.req) {
				var obj:Object = info.devel.req[_level];
				if(	App.user.level >= obj.lfrom &&
					App.user.level <= obj.lto )
				{
					reqLevel = _level;
					new ConstructWindow( {
						title:			info.title,
						upgTime:		info.devel.req[_level].t,
						request:		info.devel.obj[_level],
						target:			this,
						win:			this,
						onUpgrade:		upgradeEvent,
						hasDescription:	true
					}).show();
					
					break;
				}
			}
			return true;
		}
		
		override public function upgradeEvent(params:Object, fast:int = 0):void 
		{
			var price:Object = { };
			for (var sID:* in params) {
				price[sID] = params[sID];
			}
			
			if (fast == 0)
			{
				if (!App.user.stock.takeAll(price)) return;
			}else {
				if (!App.user.stock.take(Stock.FANT,fast)) return;
			}
		
			gloweble = true;
			
			Post.send({
				ctr:this.type,
				act:'upgrade',
				uID:App.user.id,
				id:this.id,
				wID:App.user.worldID,
				sID:this.sid,
				fast:fast,
				level:reqLevel
			},onUpgradeEvent, params);
		}
	}
}