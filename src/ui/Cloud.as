package ui
{
	import buttons.SimpleButton;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.clearInterval;
	import flash.utils.setInterval;
	import wins.Window;
	
	
	public class Cloud extends SimpleButton
	{
		public static const HAND:String 			= "hand";
		public static const PICK:String 			= "pick";
		public static const TRIBUTE:String 			= "coin";
		public static const EFIR:String 			= "efir";
		public static const NO_JAM:String 			= "noJam";
		public static const NO_PLACE:String 		= "noPlace";
		public static const NO_TARGET:String 		= "noTarget";
		public static const NEED_REPAIR:String 		= "needRepair";
		public static const AVATAR:String 			= "avatar";
		public static const WATER:String 			= "water";
		public static const CRISTAL:String 			= "cristal";
		public static const CONSTRUCTING:String 	= "constructing";
		
		public var bg:Bitmap;
		public var bitmap:Bitmap;
		
		public var callBack:Function = null;
		private var params:Object = { };
		
		public function Cloud(type:String, params:Object = null, isRotate:Boolean = false, callBack:Function = null)
		{
			this.callBack = callBack;
			
			if(params) 
				this.params = params;
			
			if (params && params.roundBg) 
				//bg = new Bitmap(Window.textures.productBacking2);// UserInterface.textures.cloudsLabel);
				bg = new Bitmap(Window.textures.iconProduction);// UserInterface.textures.cloudsLabel);
			else
				//bg = new Bitmap(Window.textures.productBacking);// UserInterface.textures.cloudsLabel);
				bg = new Bitmap(Window.textures.iconBack2);// UserInterface.textures.cloudsLabel);
			
			
			bitmap = new Bitmap(Cloud.takeIcon(type, params));
			
			bitmap.x = (bg.width - bitmap.width) / 2;
			bitmap.y = 5;
			bitmap.smoothing = true;
			
			if (type == CONSTRUCTING)
			{
				bitmap.scaleX = bitmap.scaleY = 0.9;
				bitmap.x += 4;
				bitmap.y -= 4;
			}
			
			if (type == HAND) {
				//bitmap.x += 1;
				bitmap.x += 8; 
				bitmap.y -= 12;
				
				if (params && params.addGlow) 
					addGlow(Window.textures.iconEff, 1, 1);
			}
			
			if (isRotate) {
				bitmap.scaleX = -1;
				bitmap.x += bitmap.width;
				if (type == HAND) {
					bitmap.x -= 16;
				}
			}
			
			addChildAt(bg, 0);
			addChild(bitmap);
			
			addEventListener(MouseEvent.CLICK, onClick);
		}
		
		private function onClick(e:MouseEvent):void 
		{
			if (callBack != null)
				callBack();
		}
		
		private var container:Sprite;
		public function addGlow(bmd:BitmapData, layer:int, scale:Number = 1):void
		{
			var btm:Bitmap = new Bitmap(bmd);
			container = new Sprite();
			container.addChild(btm);
			btm.scaleX = btm.scaleY = scale;
			btm.smoothing = true;
			btm.x = -btm.width / 2;
			btm.y = -btm.height / 2;
			
			addChild(container);
			
			container.mouseChildren = false;
			container.mouseEnabled = false;
			
			container.x = bg.x +bg.width / 2;
			container.y = bg.y +bg.height / 2;
			
			App.self.setOnEnterFrame(rotateBtm);
			this.startGlowing();
			
			var that:* = this;
			startInterval = setInterval(function():void {
				clearInterval(startInterval);
				interval = setInterval(function():void {
					that.pluck();
				}, 10000);
			}, int(Math.random() * 3000));
		}
		
		private var interval:int = 0;
		private var startInterval:int = 0;
		private function rotateBtm(e:Event):void 
		{
			container.rotation += 1;
		}
		
		public static function takeIcon(type:String, params:Object = null):BitmapData
		{
			switch(type)
			{
				case HAND:
					return Window.textures.checkMarkBig;
				case PICK:
					return UserInterface.textures.gestureIco;
				case TRIBUTE:
					return UserInterface.textures.coinsIcon;
				case NO_JAM:
					if (params && params.hasOwnProperty('view') && params.view == 'fish') {
						return UserInterface.textures.noJamFish;
					}
					return UserInterface.textures.noJam;
				case NO_PLACE:
					return UserInterface.textures.noPlace;
				case "noFish":
					return UserInterface.textures.noJamFish;
				case NO_TARGET:
					return UserInterface.textures.noTarget;
				case NEED_REPAIR:
					return UserInterface.textures.repairUnitIcon;	
				case WATER:
					return UserInterface.textures.checkMarkBig;	
				case CRISTAL:
					return UserInterface.textures.fantsIcon;	
				case EFIR:
					return UserInterface.textures.energyIcon;	
				case CONSTRUCTING:
					//return Window.textures.buildIco;	
					return UserInterface.textures.buildIcon;	
				case AVATAR:
					return null;
				default :
					return Window.textures.checkMarkBig;
			}
		}
		
		override public function dispose():void
		{
			super.dispose();
			removeEventListener(MouseEvent.CLICK, onClick);
			App.self.setOffEnterFrame(rotateBtm);
			this.hideGlowing();
		}
	}	
}