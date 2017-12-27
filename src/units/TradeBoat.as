package units 
{
	import core.Load;
	import flash.display.Bitmap;
	/**
	 * ...
	 * @author ...
	 */
	public class TradeBoat extends AUnit
	{
		public static const DEFAULT:int = 0;
		public static const STRAIGHT:int = 1;
		public static const BACK:int = 2;
		
		private var _typeMove:int;
		
		
		public function TradeBoat(settings:Object) 
		{
			super(settings);
			id = settings.id;
			
			Load.loading(Config.getSwf("Ships", "trade_boat_" + settings.id), onLoad);
		}
		
		public function start():void
		{
			startAnimation();
		}
		
		public function stop():void
		{
			stopAnimation();
		}
		
		override public function onLoad(data:*):void 
		{
			super.onLoad(data);
			textures = data;
			var icon:Bitmap = new Bitmap(data.sprites[0].bmp);
			icon.x = data.sprites[0].dx;
			icon.y = data.sprites[0].dy;
			addChild(icon);
			initAnimation();
		}
		
		public function get typeMove():int 
		{
			return _typeMove;
		}
		
		public function set typeMove(value:int):void 
		{
			_typeMove = value;
		}
		
	}

}