package core
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.SecurityErrorEvent;
	import flash.utils.clearInterval;
	import flash.utils.getTimer;
	import flash.utils.setInterval;

	/**
	* @author Björn Acker | www.bjoernacker.de
	*/
	public class SpeedWatchDog extends EventDispatcher
	{
		protected var _tolerance:Number;
		protected var _prevDate:Number;
		protected var _prevTimer:int;
		protected var _interval:uint;
		
		[Event(name="securityError",type="flash.events.SecurityErrorEvent")]
		
		public function init(interval:int = 1000, tolerance:Number = 0.35):void
		{
			_tolerance = tolerance;
			_prevTimer = getTimer();
			_prevDate = new Date().time;
			this.interval = interval;
		}
		
		public function stop():void
		{
			clearInterval(_interval);
		}
		
		public function get tolerance():Number
		{
			return _tolerance;
		}
		
		public function set tolerance(value:Number):void
		{
			_tolerance = value;
		}
		
		public function get interval():uint
		{
			return _interval;
		}
		
		public function set interval(value:uint):void
		{
			clearInterval(_interval);
			_interval = setInterval(check, value);
		}
		
		protected function check():void
		{
			var date:Number = new Date().time - _prevDate;
			var timer:Number = getTimer() - _prevTimer;
			var t:Number = date * _tolerance;
			
			if (timer > date + t || timer < date - t)
			{
				dispatchEvent(new SecurityErrorEvent(SecurityErrorEvent.SECURITY_ERROR));
			}
			
			_prevTimer = getTimer();
			_prevDate = new Date().time;
		}
	}
}