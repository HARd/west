package units 
{
	import com.greensock.easing.Cubic;
	import com.greensock.TweenLite;
	import core.Load;
	import wins.ShipWindow;
	import wins.StockWindow;
	
	public class Tent extends AUnit 
	{		
		public var level:int = 0;
		public function Tent(object:Object) 
		{
			layer = Map.LAYER_SORT;
			
			super(object);
			
			if (!Config.admin && formed) 
			{
				stockable = false;
				removable = false;
			}
			
			Load.loading(Config.getSwf(type, info.view), onLoad)
		}
		
		override public function onLoad(data:*):void 
		{
			super.onLoad(data);
			textures = data;
			
			var levelData:Object = textures.sprites[0];
			draw(levelData.bmp, levelData.dx, levelData.dy);
			
			framesType = info.view;
			if (textures && textures.hasOwnProperty('animation')) 
				initAnimation();
			
			//addShip();
		}
		
		override public function click():Boolean 
		{
			//new StockWindow( {
				//mode:		StockWindow.MINISTOCK,
				//stockTarget:this
			//}).show();
			
			new ShipWindow( {
				target:		this
			}).show();
			
			return true;
		}
		
		// Ship
		public function onShipClick():void 
		{
			new ShipWindow( {
				target:		this
			}).show();
		}
		
		//private var shipPos:Object = { x:30, y: -150 };
		//
		//public function addShip():void 
		//{
			//if (ship) return;
			//
			//ship = new Ship( {
				//type:		'Ship',
				//view:		'ship',
				//info:		info,
				//target:		this,
				//onClick:	onShipClick
			//});
			//ship.x = shipPos.x;
			//ship.y = shipPos.y;
			//
			//switch(App.user.worldID)
			//{
				//case 790:
					//ship.scaleX = -1
					//ship.y += 180 - 40;
					//ship.x += 160 + 40;	
					//break;
				//case 925:
					//ship.y = 50;
					//ship.x = 100;	
					//break;	
			//}
		//}
		
		//private var shipAnimate:Boolean = false;
		//
		//private function initShipAnimation():void
		//{
			//if (shipAnimate) return;
			//
			//shipAnimate = true;
			//TweenLite.to(ship, 3, { y:shipPos.y + 15, ease:Cubic.easeInOut, onComplete:function():void {
				//TweenLite.to(ship, 3, { y:shipPos.y, ease:Cubic.easeInOut, onComplete:function():void {
					//if (!parent) return;
					//shipAnimate = false;
					//initShipAnimation();
				//}});
			//}});
		//}
		
		override public function uninstall():void 
		{
			super.uninstall();
		}		
	}
}