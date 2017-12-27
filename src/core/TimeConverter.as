package core{
		
	
	public class  TimeConverter
	{
		public static const H_M_S:uint 	= 1;
		public static const M_S:uint 	= 2;
		
		public function TimeConverter()
		{
			
		}
		
		/**
		 * Приводит время flash:1382952379984данное кол-вом секунд к формату ЧЧ:ММ:СС
		 * @param	time
		 */
		public static function timeToStr(time:int):String
		{
			var hours:int = Math.floor(time / 3600);
			var minutes:int = Math.floor((time - hours * 3600) / 60);
			var seconds:int = Math.floor(time - hours * 3600 - minutes * 60);
			
			if (hours > 100)
			{
				return " " + String(int(hours / 24) + " " + Locale.__e("flash:1382952379727"));
			}
			return toFormat(hours)+ ':' + toFormat(minutes) + ':' + toFormat(seconds);
		}
		
		
		public static function timeToDays(time:int):String
		{
			var hours:int = Math.floor(time / 3600);
			var minutes:int = Math.floor((time - hours * 3600) / 60);
			var seconds:int = Math.floor(time - hours * 3600 - minutes * 60);
			
			if (hours > 25)
			{
				return String(int(hours / 24) + " " + Locale.__e("flash:1382952379727"));
			}
			
			return toFormat(hours)+ ':' + toFormat(minutes) + ':' + toFormat(seconds);
		}
		
		/**
		 * Приводит время flash:1382952379984данное кол-вом секунд к формату ММ:СС
		 * @param	time
		 */
		public static function minutesToStr(time:int):String
		{
			var hours:int = Math.floor(time / 3600);
			var minutes:int = Math.floor((time - hours * 3600) / 60);
			var seconds:int = Math.floor(time - hours * 3600 - minutes * 60);
			
			return toFormat(minutes) + ':' + toFormat(seconds);
		}
		
		/**
		 * Преобразовывает единицу времени (часы, минуты или секунды) в формат XX
		 * @param	time
		 */
		public static function toFormat(time:int):String
		{
			var str:String = String(time);
			if (str.length == 1)
			{
				return '0' + str;
			}
			return str;
		}
		
		/**
		 * Приводит время flash:1382952379984данное кол-вом секунд к формату flash:1382952379728flash:1382952379729flash:1382952379730
		 * @param	time
		 * @param	addSeconds
		 */
		public static function timeToCuts(time:int, addSeconds:Boolean = false, addMinutes:Boolean = false):String
		{
			var result:String = "";
			var hours:int = Math.floor(time / 3600);
			var minutes:int = Math.floor((time - hours * 3600) / 60);
			var seconds:int = Math.floor(time - hours * 3600 - minutes * 60);
				
			if (hours > 0)
				result += String(hours + ' '+Locale.__e('flash:1382952379728')+' ');
				
			if(minutes > 0 && addMinutes)
				result += String(minutes + ' '+Locale.__e('flash:1382952379729')+' ');
				
			if (seconds > 0 && addSeconds) result += seconds + ' ' + Locale.__e('flash:1382952379730') + ' ';
			
			return result;
		}
		
		public static function getDatetime(format:String, time:int):String {
			var currDate:Date = new Date(time*1000);
    			
			var D:Number = currDate.getDate();
			var M:Number = currDate.getMonth()+ 1;
			var Y:Number = currDate.getFullYear();
			
			var h:Number = currDate.getHours();
			var m:Number = currDate.getMinutes();
			var s:Number = currDate.getSeconds();
			
			format = format
				.replace(/%d/,toFormat(D))
				.replace(/%m/,toFormat(M))
				.replace(/%Y/,Y)
				.replace(/%H/,toFormat(h))
				.replace(/%i/,toFormat(m))
				.replace(/%s/,toFormat(s));
			
			return format;
		}
		
		public static function strToTime(dateLine:String):int {
			try {
				var date:Date = new Date(dateLine.substr(0, 4), int(dateLine.substr(5, 2)) - 1, dateLine.substr(8, 2), dateLine.substr(11, 2), dateLine.substr(14, 2), dateLine.substr(17, 2));
				return date.time / 1000;
			}catch (e:*) { }
			
			return 0;
		}
	}
}