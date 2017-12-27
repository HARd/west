package fog 
{
	import astar.AStarNodeVO;
	import com.flashdynamix.motion.layers.VectorLayer;
	import core.IsoConvert;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.BlurFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import units.Unit;
	import wins.Window;
	/**
	 * ...
	 * @author ...
	 */
	public class FogLayer
	{
		private const districtSize:int = 30;
		private var _transparent:Boolean = false;
		private var reserv:BitmapData;
		private var fogManager:FogManager;
		private var lineContainer:Sprite;
		public function FogLayer(transparent:Boolean = true)
		{
			this.transparent = transparent;
			fogManager = App.map.fogManager;
			reserv = App.map.bitmap.bitmapData.clone();
			unitsList = new Vector.<Unit>;
			unitsListDisplayd = new Vector.<Unit>;
		}
		public function set transparent(value:Boolean):void
		{
			_transparent = value;
		}
		public function get transparent():Boolean
		{
			return _transparent;
		}
		private var _allClouds: Vector.<FogCloud>;
		private function get allClouds():Vector.<FogCloud>
		{
			if (!_allClouds)
				_allClouds = greedy();
			return _allClouds;
		}
		private var _clouds: Vector.<FogCloud>;
		private function get clouds():Vector.<FogCloud>
		{
			if (!_clouds)
			{
				_clouds = new Vector.<FogCloud>;
				for each(var cloud:FogCloud in allClouds)
				{
					if (cloud.inZone(0))
					{
						_clouds.push(cloud);
					}
				}
			}
			return _clouds;
		}
		public function zoneCenter(zoneID:int):Object
		{
			var pos:Object = zonePosition(zoneID);
			var re:Object = {	x:int((pos.topLeftIso.x + pos.botRightIso.x) / 2), z:int((pos.topLeftIso.z + pos.botRightIso.z) / 2) };
			return re;
		}
		private function zonePosition(zoneID:int = 0):Object
		{
			var nodeArray:Object = App.map._aStarNodes;
			var _topLeftIso:Object = { x:0, z:0 };
			var _topLeft:Object = { x:0, y:0 };
			var _botRightIso:Object = { x:0, z:0 };
			var _botRight:Object = { x:0, y:0 };
			var minX:uint = Map.cells;
			var minZ:uint = Map.rows;
			var maxX:uint = 0;
			var maxZ:uint = 0;
			var _x:uint = 0;
			var _z:uint = 0;
			
			_topLeft.x = App.map.bitmap.x;
			_topLeft.y = App.map.bitmap.y ;

			while ( _x < Map.cells)
			{
				while ( _z < Map.rows) 
				{
					if ( (!zoneID && fogManager.hidenZones.indexOf (nodeArray[_x][_z].z) !=-1) || nodeArray[_x][_z].z == zoneID)
					{
						if (_z < minZ)
							minZ = _z;
						if (_x < minX)
							minX = _x;
						if (_z > maxZ)
							maxZ = _z;
						if (_x > maxX)
							maxX = _x;
					}
					_z++;
				}
				_z = 0;
				_x++;
			}
			if (minX != Map.cells || minZ != Map.rows)
			{
				var obj1:Object = IsoConvert.isoToScreen(minX, minZ);
				var obj2:Object = IsoConvert.isoToScreen(maxX, maxZ);
				
				_topLeft.x += obj1.x;
				_topLeft.y += obj1.y;
				_botRight.x = obj2.x;
				_botRight.y = obj2.y;
				
				_topLeftIso.x = minX;
				_topLeftIso.z = minZ;
				_botRightIso.x = maxX;
				_botRightIso.z = maxZ;
			}
			return {
				topLeft:_topLeft,
				botRight:_botRight,
				topLeftIso:_topLeftIso,
				botRightIso:_botRightIso
			}
		}
		private function collision(fogCloud:FogCloud,list:Vector.<FogCloud> ):Boolean
		{
			if (list.length == 0)
				return false;
			for each (var cloud:FogCloud in list)
			{
				if (fogCloud.collision(cloud))
					return true;
			}
			return false;
		}
		private function greedy():Vector.<FogCloud> // пробуем засунуть попбольше облаков жадным алгоритмом
		{
			var result:Vector.<FogCloud> = new Vector.<FogCloud>;
			var area:Object = zonePosition();
			area.topLeftIso.x = (area.topLeftIso.x > 10)? area.topLeftIso.x - 10: 0;
			area.topLeftIso.z = (area.topLeftIso.z > 10)? area.topLeftIso.z - 10: 0;
			var nodeArray:Object = App.map._aStarNodes;
			var zID:uint  = 0;
			var cloudC:Object = { };
			function cicle(___zone:Boolean):void
			{
				for (var _scale:Number =  4.5; _scale > 0.5 ; _scale-= 1)
				{
					var __zone:int = 0;
					for (var _x:uint = area.topLeftIso.x; _x < area.botRightIso.x; _x += 4)
					{
						for (var _z:uint = area.topLeftIso.z; _z < area.botRightIso.z; _z += 4)
						{
							
							var fogCloud:FogCloud = new FogCloud(Math.floor(Math.random()*fogManager.fogsImages.length), _scale);
							//var fogCloud:FogCloud = new FogCloud(0, _scale);
							fogCloud.positionIso = { x:_x, z:_z };
							zID = fogCloud.zID;
							fogCloud.zoneID = zID;
							if ( zID != 0 && fogManager.hidenZones.indexOf (zID) != -1)
							{								
								__zone = (___zone)? zID : 0;	
								if (!collision(fogCloud, result) && fogCloud.inZone(__zone) && fogCloud.inMapPos)
								{
									result.push(fogCloud);		
								}
							}
						}
					}
				}
			}
			cicle(true);
			cicle(false);
			var re:Vector.<FogCloud> =  new Vector.<FogCloud>;
			for (var _index:String in result)
			{
				if ( !collision(result[_index], result) )
				{
					re.push(result[_index]);
				}
			}
			return result;
		}
		private var unitsList:Vector.<Unit>;
		private var unitsListDisplayd:Vector.<Unit>;
		private var wait:int = 1;
		private var startTimer:Boolean = false;
		public function addUnit(target:Unit):void
		{
			unitsList.push(target);
			addUnits();
			if (!startTimer)
			{
				startTimer = true;
				App.self.setOnTimer(timer);
				wait = 1;
			}
		}
		private function timer():void
		{
			wait--;
			if (wait < 0)
			{
				App.self.setOffTimer(timer);
				startTimer = false;
				addUnits();
			}
		}
		// расскоментировать, если необходимо добавлять верхушки юнитов не по одному а пачками сокращая количество вызовов addUnits
		private function addUnits():void
		{
			if (!reserv)
				return;
			for each(var unit:Unit in unitsList)
			{
				if (!unit.open && unit.maskBMD)
				{
					var mtr:Matrix = new Matrix();
					mtr.tx = unit.x + unit.bitmap.x - App.map.bitmap.x;
					mtr.ty = unit.y + unit.bitmap.y - App.map.bitmap.y;
					App.map.bitmap.bitmapData.draw(unit.maskBMD, mtr, null, null, null, true);
					unitsListDisplayd.push(unit);
					unitsList.splice(unitsList.indexOf(unit), 1);
				}
			}
		}
		public function clear():void
		{
			App.map.bitmap.bitmapData = reserv.clone();
		}
		public function hideInFogs():void
		{
			if (!reserv)
				return;
			lineContainer = new Sprite();
			trace('-------->Start	' + new Date().time / 1000);
			clear();
			var mtr:Matrix = new Matrix();
			mtr.tx = -App.map.bitmap.x ;
			mtr.ty = -App.map.bitmap.y;
			App.map.bitmap.bitmapData.lock();
			for (var xD:int = 0; xD < Map.cells; xD += districtSize )
				for (var zD:int = 0; zD < Map.rows; zD += districtSize )
					sectionDraw( { x:xD, z:zD } );
			App.map.bitmap.bitmapData.unlock();
			for each(var unit:Unit in unitsListDisplayd)
			{
				unitsList.push(unit);
			}
			unitsListDisplayd.splice(0,unitsListDisplayd.length);
			addUnits();
			App.map.mLand.addChild(lineContainer);
			if (_clouds)
				_clouds.slice(0, _clouds.length);
			_clouds = null;
			trace('-------->Finish	' + new Date().time / 1000);
		}
		public function dispose():void
		{
			clear();
			reserv.dispose();
			fogManager = null;
			if (unitsList)
			{
				unitsList.splice(0,unitsList.length);
				unitsListDisplayd.splice(0, unitsListDisplayd.length);
			}
			//App.self.setOffTimer(timer);
		}
		private function sectionDraw(point:Object):void
		{
			var mtr:Matrix = new Matrix();
			mtr.tx = -App.map.bitmap.x ;
			mtr.ty = -App.map.bitmap.y;
			var tempSprite:Sprite = new Sprite();
			for each(var cloud:FogCloud in clouds)
			{
				if (cloud.xIso >= point.x && cloud.xIso < point.x + districtSize &&
						cloud.zIso >= point.z && cloud.zIso < point.z + districtSize)
				{
					cloud.filters = [new BlurFilter(4, 4, BitmapFilterQuality.LOW)];
					tempSprite.addChild(cloud);
					////lineContainer.graphics.lineStyle(4, 0x00061f, 1);
					////lineContainer.graphics.drawCircle(cloud.x, cloud.y, 2);
					////
					////lineContainer.graphics.lineStyle(2, 0xf4061f, 1);
					////lineContainer.graphics.drawCircle(cloud.centerC.x, cloud.centerC.y, cloud.radiusC);
					////var coords:* = IsoConvert.isoToScreen(cloud.xIso, cloud.zIso,true);
					////lineContainer.graphics.drawCircle(coords.x, coords.y, cloud.radiusC);
				}
			}
			App.map.bitmap.bitmapData.draw(tempSprite, mtr);
			tempSprite.removeChildren();
			tempSprite = null;
		}
	}
}