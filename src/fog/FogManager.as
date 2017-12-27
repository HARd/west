package fog 
{
	import adobe.utils.CustomActions;
	import core.Load;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.filters.GlowFilter;
	import flash.utils.clearInterval;
	import flash.utils.setInterval;
	//import units.Explode;
	import units.Unit;
	/**
	 * ...
	 * @author ...
	 */
	public class FogManager 
	{
		[Embed(source = "../../libraries/Windows/src/Textures/Fog/f1.png")]
		public var Fog1:Class;
		public var fog1:BitmapData = new Fog1().bitmapData;
		
		[Embed(source="../../libraries/Windows/src/Textures/Fog/f2.png")]
		public var Fog2:Class;
		public var fog2:BitmapData = new Fog2().bitmapData;
		
		[Embed(source="../../libraries/Windows/src/Textures/Fog/f3.png")]
		public var Fog3:Class;
		public var fog3:BitmapData = new Fog3().bitmapData;
		
		[Embed(source="../../libraries/Windows/src/Textures/Fog/f4.png")]
		public var Fog4:Class;
		public var fog4:BitmapData = new Fog4().bitmapData;
		
		[Embed(source="../../libraries/Windows/src/Textures/Fog/f5.png")]
		public var Fog5:Class;
		public var fog5:BitmapData = new Fog5().bitmapData;
		
		public var fogsImages:Array = [fog1, fog2, fog3, fog4, fog5];
		public var fogsImagesCoef:Array = [.8,.8, .8, .8, 0.8];
		
		// все необходимые файлы находятся в папке fog
		private var fogLayer:FogLayer;
		public var data:Object;
		public function FogManager() 
		{
		}
		// init в  Map onLoadTile 
		public function init(data:Object = null):void
		{
			if (!checkOnInit())
				return;
			if (data)
				this.data = data;
			loadExplode();
			if (!fogLayer)
				fogLayer = new FogLayer();
			if (User.inExpedition/* || App.user.worldID == Travel.SAN_MANSANO*/)
			{
				fogLayer.hideInFogs();
			}
		}
		// в Unit addMask, так же генерацию Bitmapdata я вынес в отдельный геттер 
		public function addToFog(target:Unit):void 
		{
			fogLayer.addUnit(target);
		}
		private function checkOnInit():Boolean
		{
			//if (!App.map.zoneResources)
				//return true;
			var re:Boolean = false;
			for each(var zone:String in App.map.assetZones)
			{
				if (!World.zoneIsOpen(uint (zone)))
				{
					re = true;
				}
			}
			return re;
		}
		public function get hidenZones():Array {
			var re:Array = [];
			for each(var zone:String in App.map.assetZones)
			{
				if (!World.zoneIsOpen(uint (zone)))
				{
					re.push(uint(zone))
				}
			}
			return re;
		}
		public function openZone():void
		{
			if (fogLayer) fogLayer.hideInFogs();
		}
		public function claer():void
		{
			if (fogLayer) fogLayer.clear();
		}
		// вызывается в Map dispose()
		public function dispose():void
		{
			if (fogLayer)
				fogLayer.dispose();
		}
		////////////////// Explode block
		private function loadExplode():void 
		{
			Load.loading(Config.getSwf('Firework', 'explode'), onLoadExplode);
			Load.loading(Config.getSwf('Effects', 'harvest'), onHarvestLoad);
		}
		private var explodeTextures:Object = null;
		private function onLoadExplode(data:*):void 
		{
			explodeTextures = data;
		}
		public var harvestTextures:Object;
		private function onHarvestLoad(data:*):void
		{
			harvestTextures = data;
		}
		// onOpenExpeditionZone в классе World
		// так же будьте внимательны, потому что координаты центра зоны и ассоциативный номер зоны до этого берутся из каласса Fog
		public function doExplode(target:Object, onFinish:Function):void 
		{
			if (explodeTextures == null) {
				onFinish();
				return;
			}
				
			var counter:int = 5;
			//var timer:int = setInterval(function():void {
				//addExplode(getRandomPos());
				//counter --;
				//if (counter == 0) {
					//clearInterval(timer);
					onFinish();
				//}
			//}, 400);
			
			var delay:int = 400;
			function getRandomPos():Object {
				var _x:int = target.x - delay/2 + int(Math.random()*delay);
				var _y:int = target.y - 100 - delay / 2 + int(Math.random() * delay);
				return {
					x:_x,
					y:_y
				}
			}
		}
		//private function addExplode(position:Object):void 
		//{
			//var explode:Explode = new Explode(explodeTextures);
			//explode.filters = [new GlowFilter(0xffFF00, 1, 15, 15, 4, 3)];
			//explode.x = position.x;
			//explode.y = position.y;
		//}
		//////////////////////////////////////////////////////////////////////////
		
		
		///////////////////////////////
		
		// вызывается сразу после инициалищации FogManager в Map onLoadTile 
		public function checkResources(_units:Object):void {
			
			// Отключить для тестирования
			//return;
			if (!App.map.zoneResources )
				return;
			for each(var item:Object in _units) {
				if (App.data.storage[item.sid].type == 'Resource')
					checkResource(item.id);
			}
		}
		public function checkResource(id:int):void
		{
			if (App.map.zoneResources && App.map.zoneResources.hasOwnProperty(id)) {
				var zoneID:int = App.map.assetZones[App.map.zoneResources[id]];
				App.map.closedZones.push(zoneID);
			}
		}
		public function zoneCenter(zoneID:int):Object
		{
			return fogLayer.zoneCenter(zoneID);
		}
		public function checkZonesToOpen():void
		{
			// Отключить для тестирования
			return;	
			if (!User.inExpedition)
				return;
			for each(var _sid:* in App.map.assetZones) {
				if (App.map.closedZones.indexOf(_sid) == -1) {
					if (App.user.world.zones.indexOf(_sid) == -1) {
						if (App.data.storage[_sid].open) 
							continue;
							var flag:Boolean = false;
						if (App.map.zoneZoners)
						{
							for ( var ins:String in App.map.zoneZoners )
							{
								if ( App.map.assetZones[App.map.zoneZoners[ins]] == _sid)
								{	
									flag = true;
								}
							}
						}
						if(!flag)
							App.user.world.emergOpenZone(_sid);
					}
				}
			}
		}
		////////////////////////////////////////////////////////////////////////
		//public function kickEffect(target:*):void {
			//var effect:KickEffect = new KickEffect(target);
		//}
	}	
}
//import units.Anime;
//import flash.display.Sprite;
//internal class KickEffect extends Anime {
	//
	//private var target:*;
	//public function KickEffect(target:*) 
	//{
		//this.target = target;
		//if (App.map.fogManager.harvestTextures != null){	
			//super(App.map.fogManager.harvestTextures, 'harvest', 0,0,1.3);
			//
			//if (target) {
				//target.addChild(this);
				//startAnimation();
			//}
		//}
		//
	//}
	//
	//override public function onLoop():void {
		//if(target)
			//target.removeChild(this);
			//
		//stopAnimation();	
		//target = null;	
	//}
//}