	package  
	{
		import astar.AStarNodeVO;
		import com.adobe.images.BitString;
		import com.greensock.TweenLite;
		import core.IsoConvert;
		import core.IsoTile;
		import core.Load;
		import flash.display.Bitmap;
		import flash.display.BitmapData;
		import flash.display.Shape;
		import flash.display.Sprite;
		import flash.events.Event;
		import flash.filters.BlurFilter;
		import flash.filters.GlowFilter;
		import flash.geom.Matrix;
		import flash.geom.Point;
		import flash.geom.Rectangle;
		import flash.utils.setInterval;
		import ui.Cursor;
		import ui.UserInterface;
		import units.FogCloud;
		import units.Resource;
		import units.Unit;
		import wins.Window;
		
		public class Fog extends Sprite
		{			
			public static var fog1:Bitmap = new Bitmap(Window.textures.f1, "auto", true);
			public static var fog2:Bitmap = new Bitmap(Window.textures.f2, "auto", true);
			public static var fog3:Bitmap = new Bitmap(Window.textures.f3, "auto", true);
			public static var fog4:Bitmap = new Bitmap(Window.textures.f4, "auto", true);			
			
			public static const SUN_SHINE:int = 829;
			
			public static var fogsImages:Array = [fog1, fog2, fog3, fog4];			
			public static var data:Object;
			public static var assetZones:Object;			
			public static var shape:Shape;
			
			public static var zonesIds:Object = {				
			}
			
			public static function checkResources(_units:Object):void
			{
				for each(var item:Object in _units)
				{
					if (App.data.storage[item.sid].type == 'Resource')
						checkResource(item.id);
				}
			}
			
			public static function checkResource(id:int):void
			{
				if (App.map.zoneResources && App.map.zoneResources.hasOwnProperty(id)) 
				{
					var zoneID:int = App.map.assetZones[App.map.zoneResources[id]];
					App.map.closedZones.push(zoneID);
				}
			}
			
			public static function checkZonesToOpen():void
			{					
				for each(var _sid:* in App.map.assetZones)
				{
					if (App.map.closedZones.indexOf(_sid) == -1) 
					{
						if (App.user.world.zones.indexOf(_sid) == -1)
						{
							App.user.world.emergOpenZone(_sid);
						}
					}
				}
			}
			
			public static var zoneData:Object = { };
			
			public static function generateZoneCorners():void
			{
				for (var x:int = 0; x < Map.cells; x++) 
				{
					for (var z:int = 0; z < Map.rows; z++) 
					{
						var zID:* = App.map._aStarNodes[x][z].z;
						if(!zoneData.hasOwnProperty(zID))
							zoneData[zID] = { minX:1000, minZ:1000, maxX:0, maxZ:0, objects:[] };
							
						zoneData[zID].minX = Math.min(zoneData[zID].minX, x);
						zoneData[zID].minZ = Math.min(zoneData[zID].minZ, z);
						zoneData[zID].maxX = Math.max(zoneData[zID].maxX, x);
						zoneData[zID].maxZ = Math.max(zoneData[zID].maxZ, z);
					}
				}
				
				var delta:int = 1;
				for (zID in zoneData) 
				{
					zoneData[zID]['corners'] = [];
					zoneData[zID].corners[0] = { x:zoneData[zID].minX-delta, z:zoneData[zID].minZ-delta };
					zoneData[zID].corners[1] = { x:zoneData[zID].maxX+delta, z:zoneData[zID].minZ-delta };
					zoneData[zID].corners[2] = { x:zoneData[zID].maxX+delta, z:zoneData[zID].maxZ+delta };
					zoneData[zID].corners[3] = { x:zoneData[zID].minX - delta, z:zoneData[zID].maxZ + delta };					
					zoneData[zID]['cells'] = zoneData[zID].maxX - zoneData[zID].minX;
					zoneData[zID]['rows'] = zoneData[zID].maxZ - zoneData[zID].minZ;
				}
			}
			
			
			public static function addClouds():void 
			{				
				for (var counter:int = 0; counter < App.map.fogCount; counter++) {
					var _x:int = Math.random() * Map.cells;
					var _z:int = Math.random() * Map.rows;
					var node:AStarNodeVO = App.map._aStarNodes[_x][_z];
					
					var fogObject:Object = {
						id:int(counter),
						bmd:fogsImages[1],
						x:_x,
						z:_z,
						scale:1
					}
					
					var unit:FogCloud = new FogCloud(fogObject);
					unit.zone = node.z;
					Fog.addToZone(unit);					
				}
				
				App.map.sorting();
				
				for each(var fog:Fog in fogs)
				{
					fog.addUnits();
				}
			}
			
			public static function addUnitsInFogs(e:AppEvent = null):void
			{
				App.self.removeEventListener(AppEvent.ON_MAP_COMPLETE, addUnitsInFogs);
				addClouds();
				
			}
			
			public static var bg:Sprite;
			
			public static function init(assetZones:Object):void 
			{				
				fogs = [];
				bg = new Sprite();
				
				for (var zid:* in zoneData) 
				{
					if (zid == 0) continue;					
					if (App.user.world.zones.indexOf(zid) != -1) continue;
					var fog:Fog = new Fog(zid);
					fogs.push(fog);
					App.map.depths.push(fog);
					App.map.sorted.push(fog);
				}
				
				if (Map.ready)
				{
					addClouds();
					
				}else {
					App.self.addEventListener(AppEvent.ON_MAP_COMPLETE, addUnitsInFogs);
				}
				
				checkZonesToOpen();
			}
			
			
			static public function lightFirstZoneResource():void
			{
				if (App.map.zoneResources && App.map.assetZones)
				{	
					for (var _id:*in App.map.zoneResources)
					{
						trace(App.map.zoneResources[_id]);
						trace(currExp());
						if (App.map.zoneResources[_id] == currExp()) {
							var resArr:Array = Map.findUnitsByType(['Resource']);
							for (var j:int = 0; j < resArr.length; j++)
							{
								if (_id == resArr[j].id)
								{
									App.map.focusedOn(resArr[j], true);
									//resArr[j].show
									resArr[j].showPointing();
									resArr[j].showGlowing();
								}
							}
						}
					}
				}
			}
			
			static private function currExp():uint 
			{
				((App.user.worldID == 2099)?2:2)
				
				switch (App.user.worldID) 
				{
					case 2099:
					return 2;	
					break;
					
					default:
					return 2
				}
			}			
			
			public static function hideAll():void
			{
				for each(var fog:Fog in fogs)
					fog.visible = false;
			}			
			
			public static function showFogsAfterTutorial():void
			{
				for each(var fog:Fog in fogs)
				{
					fog.visible = true;
				}
			}
			
			public static function drawFader():void 
			{
				return;
				var shape:Sprite = new Sprite();
				for each(var fog:Fog in fogs) {
					if (App.user.world.zones.indexOf(fog.sid) != -1) continue;
					
					shape.graphics.beginFill(0x000000, 1);
					var point:Object = fog.points[0];
					shape.graphics.moveTo(point.x, point.y);
					
					for (var i:int = 1; i < fog.points.length; i++) 
					{
						point = fog.points[i];
						shape.graphics.lineTo(point.x, point.y);
					}
					
					point = fog.points[0];
					shape.graphics.lineTo(point.x, point.y);
				}
				shape.graphics.endFill();
				
				var bounds:Object = snapClip(shape);
				var bitmap:Bitmap = new Bitmap(bounds.bmd);				
				var bgCont:Sprite = new Sprite();
				
				bgCont.addChild(bitmap);
				bitmap.alpha = 0.5;
				bitmap.filters = [new BlurFilter(10, 10)];
				bounds = snapClip(bgCont);
				bitmap.bitmapData.dispose();
				
				var mapBitmap:Bitmap = new Bitmap(bounds.bmd);
				
				App.map.bitmap.bitmapData.copyPixels(bounds.bmd, new Rectangle(0,0,bounds.bmd.width,bounds.bmd.height), new Point(bounds.rect.x -App.map.bitmap.x + 100,bounds.rect.y - App.map.bitmap.y - 100));
			}
			
			public static var additionalClouds:Object = {
				2099:[
					{x:42, z:59 },
					{x:62, z:89 },
					{x:44, z:27 },
					{x:100, z:42 },
					{x:72, z:9 }
				]
			};
			
			public static var bitmap:Bitmap 
			public static var clouds:Array = [];
			
			public static function drawClouds(_clouds:Array):void 
			{
				bitmap = new Bitmap();
				var cont:Sprite = new Sprite();
				
				for (var i:int = 0; i < _clouds.length; i++) 
				{
					var fog:FogElement = new FogElement(fogsImages[2]);
					cont.addChild(fog);
					
					var coors:Object = IsoConvert.isoToScreen(_clouds[i].x, _clouds[i].z, true);
					fog.x = coors.x - fog.width/1 - App.map.bitmap.x + 500;
					fog.y = coors.y - fog.height / 1;
				}
				var mtr:Matrix = new Matrix();
				var delta:int = 100;
				mtr.ty = delta;
				var bmd:BitmapData = new BitmapData(shape.width + 100, cont.height+ 50, true, 0);
				bmd.draw(cont,mtr);
				
				bitmap.bitmapData = bmd;
				bitmap.x = App.map.bitmap.x - 200;
				bitmap.y = -delta;
				App.map.mLand.addChild(bitmap);
				
				shape.cacheAsBitmap = true;
				bitmap.cacheAsBitmap = true;
				bitmap.mask = shape;
			}
			
			public static function removeFogs():void 
			{
				for each(var cloud:FogCloud in clouds) {
					cloud.uninstall();
				}
			}
			
			public static function dispose():void
			{
				fogs = null;
				App.map.closedZones = [];
				Fog.data = null;
				Fog.assetZones = null;
				Fog.zoneData = { }
			}
			
			public static function on():void 
			{
				return;
			}
			
			public static function addToFog(bmd:BitmapData, target:*):void 
			{
				bitmap.bitmapData.copyPixels(bmd, new Rectangle(0, 0, bmd.width, bmd.height), 
				new Point(target.x + target.bitmap.x - bitmap.x, target.y + target.bitmap.y - bitmap.y), null, null, true );
			}
			
			public static function openZone(sID:int):void
			{				
				for each(var fog:Fog in fogs)
				{
					if (fog.sid == sID)
						fog.visible = false;
						checkBoosterLight();
				}				
			}
			
			static private function checkBoosterLight():void 
			{
				if (App.user.stock.data.hasOwnProperty(Stock.LIGHT_RESOURCE)&&App.user.stock.data[Stock.LIGHT_RESOURCE]>App.time) 
				{
					if (App.map.zoneResources && App.map.assetZones)
					{						
						for (var _id:*in App.map.zoneResources)
						{
							if (App.map.zoneResources[_id]) 
							{
								var resArr:Array = Map.findUnitsByType(['Resource']);
								for (var j:int = 0; j < resArr.length; j++)
								{
									if (_id == resArr[j].id&&resArr[j].open)
									{
										App.map.focusedOn(resArr[j]);
										resArr[j].showGlowing();
									}
								}							
							}							
						}						
					}
				}	
			}
			
			public static var zones:Object = {				
			}
			
			public static var fogs:Array = [];
			
			public static function sortFogs():void 
			{
				fogs.sortOn('depth', Array.NUMERIC);
				for (var i:* in fogs)
				{
					if (App.map.mSort.contains(fogs[i])) 
					{
						if(int(i) <App.map.mSort.numChildren)
						App.map.mSort.setChildIndex(fogs[i], int(i));
					}
				}
			}
			
			public var sid:int;
			public var _units:Array = [];
			public var queue:Array = [];
			public var index:int;
			public var container:Sprite = new Sprite();
			
			private var data:Object;
			private var _width:int;
			private var _height:int;
			private var points:Array;			
			
			public function Fog(sid:int)
			{
				this.sid = sid;
				data = zoneData[sid];
				Fog.zones[sid] = this;
				
				points = [];
				for (var i:int = 0; i < data.corners.length; i++) 
				{
					var coors:Object = IsoConvert.isoToScreen(data.corners[i].x, data.corners[i].z, true);
					points.push(coors);
				}
				
				_width = points[1].x - points[3].x;
				_height = points[2].y - points[0].y;
				
				drawZone();
				calcDepth();
			}
			
			public static function addToZone(unit:*):void
			{
				var zid:int = unit.zone;
				if (!zoneData.hasOwnProperty(zid)) 
					return;
				
				if(!zoneData[zid].hasOwnProperty('_units'))
					zoneData[zid]['_units'] = [];
				
				zoneData[zid]['_units'].push(unit);
			}
			
			public var depth:int = 0;
			
			public function calcDepth():void 
			{
				var left:Object = points[3];
				var right:Object = points[1];
				depth = (left.x + right.x) + (left.y + right.y) * 50;
			}
			
			public static function untouches():void 
			{
				for (var i:int = 0; i < fogs.length; i++)
				{
					fogs[i].touch = false;
				}
			}
			
			public static var tochedZone:int = 0;
			
			public static function touches():Boolean
			{
				var node:* = World.nodeDefinion(App.map.mouseX, App.map.mouseY);
				if (node == null) return false;
				
				var world:World = App.user.world;
				var zoneID:uint = node.z;
				
				for (var i:int = 0; i < fogs.length; i++)
				{
					var fog:Fog = fogs[i];
					fog.touch = false;
					
					if (fog.sid == zoneID)
					{
						fog.touch = true;
					}
				}
				
				return false;
			}
			
			public function set touch(value:Boolean):void 
			{
				if (App.user.mode == User.GUEST) return;
				
				if (_touch == value) return;
				_touch = value;
				
				if (_touch) 
					UserInterface.effect(this, 0.1, 1); 
				else
					this.filters = []; 
			}
			
			private var _touch:Boolean = false;
			
			public function get touch():Boolean 
			{
				return _touch;
			}
			
			public function addUnits(e:AppEvent = null):void 
			{
				if (!zoneData[sid].hasOwnProperty('_units')) return;
				zoneData[sid]._units.sortOn('index', Array.NUMERIC | Array.DESCENDING);
				zoneData[sid]._units.reverse();
				
				for (var i:int = 0; i < zoneData[sid]._units.length; i++) 
				{
					var fogUnit:FogUnit = new FogUnit(zoneData[sid]._units[i], this);
					container.addChild(fogUnit);
				}
			}
			
			public var unitCounter:int = 0;
			
			public function onUnitComplete():void
			{
				unitCounter++;
				if (unitCounter >= zoneData[sid]._units.length) 
				{
					var bounds:Object = snapClip(this);
					var bitmap:Bitmap = new Bitmap(bounds.bmd);
					addChild(bitmap);
					removeChild(container);
					this.x = bounds.rect.x + 151 - 300+((App.user.worldID == 1001)?120:1);
					this.y = bounds.rect.y - 50+((App.user.worldID == 1001)?680:1);
				}
			}
			
			public static function snapClip(clip:*, delta:int = 100):Object
			{
				var bounds:Rectangle = clip.getBounds(clip);
				var bmd:BitmapData = new BitmapData (int (bounds.width+delta), int (bounds.height + delta), true, 0);
				bmd.draw (clip, new Matrix (1, 0, 0, 1, -bounds.x + delta/2, -bounds.y + delta/2));
				return {
					bmd:bmd,
					rect:bounds
				}
			}
		
			private function drawZone():void 
			{
				addChild(container);
				container.x = App.map.bitmap.x;
				App.map.mSort.addChild(this);
			}
			
			public function drawInMap():void 
			{
				bg.graphics.beginFill(0x000000, 1);
				bg.graphics.lineStyle();
				var point:Object = points[0];
				bg.graphics.moveTo(point.x, point.y);
				for (var i:int = 1; i < points.length; i++) 
				{
					point = points[i];
					bg.graphics.lineTo(point.x, point.y);
				}
				point = points[0];
				bg.graphics.lineTo(point.x, point.y);
				bg.graphics.endFill();
			}
		}	
	}

	import core.Load;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import ui.UserInterface;
	import units.FogCloud;
	import units.Unit;

	internal class FogUnit extends Bitmap {
		
		private var fog:Fog;
		private var index:int = 0;
		private var color:* = 0x102b37;
		
		public function FogUnit(unit:*, fog:Fog) 
		{
			this.index = unit.index;
			this.fog = fog;
			var that:*= this;
			
			if (unit is FogCloud) 
			{
				switch (App.user.worldID) 
				{
					case 1001:
					color = 0x44f1b6;
					break;
				}
				
				draw(unit);
			}else{
				Load.loading(Config.getSwf(unit.info.type, unit.info.view), function(data:*):void {
					draw(unit);
				});
			};
		}
		
		public function draw(unit:*):void
		{
			this.bitmapData = unit.bitmap.bitmapData;
			this.x = unit.bitmap.x + unit.x - App.map.bitmap.x;
			this.y = unit.bitmap.y + unit.y - App.map.bitmap.y - 400 - 79;
			this.smoothing = true;
			UserInterface.colorize(this, color, 0.7);
			fog.onUnitComplete();
		}
		
		public function sort():void
		{
			fog.setChildIndex(this, index);
		}
	}


	import flash.display.Bitmap;
	import flash.display.BitmapData;

	internal class FogElement extends Bitmap 
	{		
		public function FogElement(bmd:BitmapData)
		{
			this.bitmapData = bmd;
			this.scaleX = this.scaleY = 3;
			this.smoothing = true;
		}
	}

