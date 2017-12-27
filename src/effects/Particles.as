package effects 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	
	/**
	 * ...
	 * @author
	 */
	public class Particles 
	{
		
		private var particlesArr:Array;
		
		public function Particles() 
		{
			
		}
		
		public function init(cont:Sprite, coords:Point):void 
		{
			particlesArr = [];
			
			particlesArr.push( new ParticlesStars(coords.x, coords.y) );
			cont.addChildAt( particlesArr[particlesArr.length - 1], 0 );
			
			App.self.setOnEnterFrame(update);
		}
		public function update(e:Event):void {
			for (var i:int = 0; i < particlesArr.length; i++) 
			{
				particlesArr[i].update();
				if (particlesArr[i].deleted) particlesArr.splice(i,1);
			}
			
			if (particlesArr.length == 0)
				App.self.setOffEnterFrame(update);
		}
	}

}