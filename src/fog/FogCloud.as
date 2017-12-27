package fog 
{
	import com.google.analytics.utils.Variables;
	import core.IsoConvert;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.geom.Point;
	/**
	 * ...
	 * @author ...
	 */
	public class FogCloud extends Bitmap
	{
		
		
		private var coefCollision:Number;
		private var subCoefCollision:Number = 0.42;
		public var zoneID:uint;
		public var xIso:uint = 0;
		public var zIso:uint = 0;
		
		public function FogCloud(index:int = 2,scale:Number = 1)
		{
			this.coefCollision = App.map.fogManager.fogsImagesCoef[index];
			this.bitmapData = App.map.fogManager.fogsImages[index];
			
			//bitmapData = new BitmapData (fogsImages[index].width, fogsImages[index].height, false);
			//bitmapData.draw(fogsImages[index]);
			
			scaleY = scaleX = scale;
			//height = width;
			zoneID = zID;
			smoothing = true;
		}
		public function get radiusC():uint
		{
			var re:Number = 0.0;
			re = width * 0.5 * coefCollision;
			if (re > height * 0.5 * coefCollision)
				re = height * 0.5 * coefCollision;
			return uint (re);
		}
		public function get zID():int
		{
			var isoCenter:Object = IsoConvert.screenToIso(centerC.x, centerC.y, true);
			if (isoCenter.x >= 0 && isoCenter.x < Map.cells
				&& isoCenter.z >= 0 && isoCenter.z < Map.rows)
				return App.map._aStarNodes[isoCenter.x][isoCenter.z].z;
			return 0;
		}
		public function get centerC():Point
		{
			var re:Point = new Point();
			re.x = width * 0.5 + x;
			re.y = height * 0.4 + y;
			return re;
		}
		public function get inMapPos():Boolean
		{
			return ((x >= App.map.bitmap.x) && (x + width <= App.map.bitmap.x + App.map.bitmap.width)
				&& (y >= App.map.bitmap.y) && (y + height <= App.map.bitmap.y + App.map.bitmap.height));
		}
		public function collision(_fog:FogCloud):Boolean
		{
			if (_fog.zoneID != zoneID)
				return false;
				
			var defX:int = centerC.x - _fog.centerC.x;
			var defY:int = centerC.y - _fog.centerC.y;
			var sumR:int = (_fog.radiusC + radiusC) * subCoefCollision ;
			var re:Boolean = Math.abs(defX * defX + defY * defY) <= sumR * sumR;
			// Collision Circle
			
			//var re:Boolean = bitmapData.hitTest(new Point(x, y), 135, _fog.bitmapData, new Point (_fog.x, _fog.y), 129);
			return re;
		}
		public function set positionIso(point:Object):void
		{
			xIso = point.x;
			zIso = point.z;
			var _point:Object = IsoConvert.isoToScreen(point.x, point.z,true);
			x = _point.x - width * 0.5 /** coefCollision*/;
			y = _point.y - height * 0.6 /** coefCollision*/;
		}
		public function inZone(zID:int):Boolean
		{
			var result:Boolean = false;
			var top:Object = IsoConvert.screenToIso(centerC.x, centerC.y - radiusC, true);
			var left:Object = IsoConvert.screenToIso(centerC.x - radiusC, centerC.y, true);
			var right:Object = IsoConvert.screenToIso(centerC.x + radiusC, centerC.y, true);
			var bot:Object = IsoConvert.screenToIso(centerC.x, centerC.y + radiusC, true);
			var nodes:Object = App.map._aStarNodes;
			if (zID != 0)
				result = ( top.x >= 0 && top.z >= 0 && top.x < Map.cells && top.z < Map.rows && nodes[top.x][top.z].z == zID
					&& left.x >= 0 && left.z >= 0 && left.x < Map.cells && left.z < Map.rows && nodes[left.x][left.z].z == zID
					&& right.x >= 0 && right.z >= 0 && right.x < Map.cells && right.z < Map.rows && nodes[right.x][right.z].z == zID
					&& bot.x >= 0 && bot.z >= 0 && bot.x < Map.cells && bot.z < Map.rows && nodes[bot.x][bot.z].z == zID);
			else
				result = ( top.x >= 0 && top.z >= 0 && top.x < Map.cells && top.z < Map.rows && App.map.fogManager.hidenZones.indexOf (nodes[top.x][top.z].z) != -1
					&& left.x >= 0 && left.z >= 0 && left.x < Map.cells && left.z < Map.rows && App.map.fogManager.hidenZones.indexOf (nodes[left.x][left.z].z) != -1
					&& right.x >= 0 && right.z >= 0 && right.x < Map.cells && right.z < Map.rows && App.map.fogManager.hidenZones.indexOf (nodes[right.x][right.z].z) != -1
					&& bot.x >= 0 && bot.z >= 0 && bot.x < Map.cells && bot.z <  Map.rows && App.map.fogManager.hidenZones.indexOf (nodes[bot.x][bot.z].z) != -1);
			
			return result;
		}
	}
	
}