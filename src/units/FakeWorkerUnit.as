package units 
{
	import com.greensock.TweenLite;
	import core.Load;
	import flash.utils.setTimeout;
	/**
	 * ...
	 * @author ...
	 */
	public class FakeWorkerUnit extends WorkerUnit
	{
		public static const CONCIERGE:int = 439;
		
		private var target:*;
		
		public function FakeWorkerUnit(object:Object) 
		{
			super(object);
			
			target = object.target;
			
			info['area'] = {w:1, h:1};
			cells = rows = 1;
			velocities = [0.1];
			
			removable = false;
			
			homeRadius = 3;
			shortcutDistance = 50;
		}
		
		override public function load():void
		{
			if (preloader) addChild(preloader);
			Load.loading(Config.getSwf("Personage", info.view), onLoad);
		}
		
		override public function onLoad(data:*):void 
		{
			textures = data;
			getRestAnimations();
			addAnimation();
			createShadow();
			
			if (preloader) {
				TweenLite.to(preloader, 0.5, { alpha:0, onComplete:removePreloader } );
			}
			
			goHome();
		}
		
		override public function click():Boolean
		{
			return true;
		}
		
		override public function goHome(_movePoint:Object = null):void
		{
			if (move) {
				var time:uint = Math.random() * 5000 + 5000;
				timer = setTimeout(goHome, time);
				return;
			}
			
			if (workStatus == BUSY)
				return;
			
			var place:Object;
			if (target != null) { 
				place = findPlaceNearTarget({info:target.info, coords:target.coords}, homeRadius);
			}else {
				place = findPlaceNearTarget({info:{area:{w:1,h:1}},coords:{x:this.movePoint.x, z:this.movePoint.y}}, homeRadius);
			}
			
			framesType = Personage.WALK;
			initMove(
				place.x,
				place.z,
				onGoHomeComplete
			);
		}
		
	}

}