package effects
{
	import flash.display.BitmapData;

	/**
	 * ...
	 * @author 
	 */
	public class Waves
	{
		
		[Embed(source="water.png")]
		private static var waterBMP_1:Class;
		
		public static var waves:Array = [];
		public function Waves():void 
		{
			
		}
		
		public static function add(wid:int, id:int):void {
			
			var wavesSettings:Object = takeWavesSettings(wid, id);
			if (wavesSettings == null)
				return;
			
			waves.push(new Wave(wavesSettings));
		}
		
		public static function dispose():void {
			for each(var wave:* in waves)
				wave.dispose();
			waves = [];	
		}
		
		private static function takeWavesSettings(wid:int, id:int):Object {
			if (wavesSettings[wid] != null) {
				if (wavesSettings[wid][id] != null) {
					return wavesSettings[wid][id];
				}
			}
			return null;
		}
		
		public static var wavesSettings:Object = {
			196:{//START_WORLD
				1: {
					bmd:new waterBMP_1().bitmapData,
					x:550-12+250,
					y:650+70-250
				}
			}	
		}
	}	
}

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.events.Event;
import flash.filters.DisplacementMapFilter;
import flash.filters.DisplacementMapFilterMode;
import flash.geom.Point;

internal class Wave 
{
	private var bmd:BitmapData;
	private var disp:DisplacementMapFilter;
	private var offsets:Array;
	private var target:Bitmap;
	
	public function Wave(settings:Object):void {
			
		target = new Bitmap(settings.bmd);
		bmd = new BitmapData(target.width, target.height);  
			//var disp:DisplacementMapFilter = new DisplacementMapFilter(bmd,new Point(0,0),1,2,20,25, DisplacementMapFilterMode.CLAMP);  
		disp = new DisplacementMapFilter(bmd,new Point(0,0),10,2,10,15, DisplacementMapFilterMode.CLAMP);
		offsets = [new Point(0, 0), new Point(0, 0)];  
		
		App.map.mLand.addChild(target);
		target.x = settings.x;
		target.y = settings.y;	
		
		App.self.setOnEnterFrame(doUpdate);  
	}
	
	public function dispose():void {
		App.self.setOffEnterFrame(doUpdate);  
		App.map.mLand.removeChild(target);
	}
	
	private function doUpdate(evt:Event):void
	{
	  offsets[0].x -=0.2;
	  offsets[1].y -= 0.5//1;//0.5;  
	  //bmd.perlinNoise(45, 20, 2 ,50, true, false, 7, true, offsets);  
	  bmd.perlinNoise(45, 10, 2 ,50, true, false, 7, true, offsets);
	  target.filters=[disp];
	}
}
