package units
{
	import core.IsoConvert;
	import core.IsoTile;
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.utils.ByteArray;
	import ui.UserInterface;
	public class FogCloud extends Sprite {
		
		public var layer:String;
		public var rows:int = 5;
		public var cells:int = 5;
		
		public var sid:int;
		public var id:int;
		
		public var dX:int = 0;
		public var dY:int = 0;
		
		public var index:uint = 0;
		public var bitmap:Bitmap;
		public var zone:int;
		
		public function FogCloud(object:Object)
		{
			layer = Map.LAYER_SORT;
			install();
			
			bitmap = object.bmd;
			bitmap.smoothing = true;
			addChild(bitmap);
			
			var dX:int = -bitmap.width / 2 ;
			var dY:int = -bitmap.height / 2;
			bitmap.x = dX; 
			bitmap.y = dY;
			
			var settings:Object = {
				color	:0x99ffff,
				amount	:0.8
			}
				
			UserInterface.colorize(bitmap, settings.color, settings.amount)
			
			sortPos = IsoConvert.isoToScreen(object.x, object.z, true);
			this.x = sortPos.x;
			this.y = sortPos.y;
			
			calcDepth();
		}
		
		public var sortPos:Object;
		
		public function install():void {
			visible = false;
			App.map.addUnit(this);
		}
		
		public function uninstall():void {
			App.map.removeUnit(this);
		}
		
		public function sort(index:*):void {
			App.map.mSort.setChildIndex(this, index);
		}
		
		public var depth:int;
		public function calcDepth():void {
			var left:Object = { x:sortPos.x  - IsoTile.width * rows * .5, y:sortPos.y + IsoTile.height * rows * .5 };
			var right:Object = { x:sortPos.x + IsoTile.width * cells * .5, y:sortPos.y + IsoTile.height * cells * .5 };
			depth = (left.x + right.x) + (left.y + right.y) * 100;
		}
	}
}