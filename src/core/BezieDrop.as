package core{
	
	import com.greensock.*
	import com.flashdynamix.motion.*
	import com.flashdynamix.motion.easing.*;
	import flash.events.Event;
	
	public class BezieDrop
	{
		private var _x:int = 0;
		private var _y:int = 0;
		
		private var Xs:int = 0;
		private var Ys:int = 0;
		
		private var Xf:int = 0;
		private var Yf:int = 0;
		
		private var obj:*;
		private var N:Number = 200;
		private var dY:Number = 0;
		private var addY:Number = 0;
		private var directionX:Number = 1;
		private var step:int = 0;
		private var k:Number = 0;
		private var _onComplete:Function
		
		public function BezieDrop(Xs:int, Ys:int, Xf:int, Yf:int, obj:*, onComplete:Function = null)
		{
			var Xb:int =  Xs + (Xf - Xs) / 2;
			var Yb:int =  Ys - (Yf - Ys) / 2;
			
			this.obj = obj;
			this.Xf = Xf;
			this.Yf = Yf;
			
			this.Xs = Xs;
			this.Ys = Ys;
			
			obj.x = Xs;
			obj.y = Ys;
			
			dY = Math.random() * 3
			
			directionX = (Math.random() * 3) - 1.5;
			if (onComplete != null)	_onComplete = onComplete;
			App.self.setOnEnterFrame(move);
		}
		
		private var dScale:Number = 0.05;
		private var _dY:Number = 1;
		private var cadr:int = 0;
		private var chain:Array = [0, 0, 0, 0, 0, -1, -1, -1, -1, 0, 1, 1, 1, 1, 0, 0, 0, -1, -1, -1, 0, 1, 1, 1, 0, 0, 0, 0, 0, -1, 0, 1];
		
		private function move(e:Event = null):void
		{
			_x += 3;
			_y = Math.abs(N * Math.sin(0.1 * _x));
			//trace(int(N)+"  "+int(_x)+"  "+int(_y)+" "+chain[cadr]);
			N += ( -N) / 10;
			addY += dY;
			
			/*if (_y <= N*0.15) 
			{
				step ++;
				if(step == 3)
				{
					App.self.setOffEnterFrame(move);
				}
			}*/
			
			if (_x >= 96)	{
				App.self.setOffEnterFrame(move);
				if (_onComplete != null) _onComplete();
				return;
			}
			
			obj.x = Xs + _x*directionX;
			obj.y = (Ys - _y) + addY;

			var value:int
			if (cadr >= chain.length)
			{
				//value = 0;
			}
			else
			{
				value = chain[cadr];
				cadr ++;
				obj.scaleY += dScale * value;
				obj.y += _dY * value;
			}
		}
		
		public function stop():void
		{
			App.self.setOffEnterFrame(move);
		}
	}
}