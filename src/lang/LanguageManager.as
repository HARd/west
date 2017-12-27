package lang
{
	import com.shortybmc.data.parser.CSV;
	import flash.events.Event;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;
	
	public class LanguageManager 
	{
		public static var DICTIONARY:Dictionary = new Dictionary();
		
		public static function loadLanguage(lg:String, callback:Function):void
		{
			if (lg == "ru")
			{
				callback();
				return;
			}
			
			var csv : CSV = new CSV();
			csv.addEventListener ( Event.COMPLETE, completeHandler );
			csv.load ( new URLRequest('http://5.9.90.73/locale/'+lg+'.csv?v='+int(Math.random()*1000)) );
			function completeHandler (event:Event):void
			{
				trace('loadLanguage Complete');
				//csv.decode();
				for (var s:int = 0; s < csv.data.length; s++)
				{
					var obj:Object = csv.data[s];
					for (var j:int = 0; j < obj.length; j++)
					{
						var string:String = obj[j];
						
						for (var i:int = 0; i < string.length; i++)
						{
							var simbol:String = string.charAt(i);
							var spart:String
							var fpart:String
							
							if (string.charAt(i) == '"' &&
								(string.charAt(i + 1) != null && string.charAt(i + 1) != '"')
								)
								{
									spart = string.slice(0, i);
									fpart = string.slice(i+1, string.length);
									
									string = spart + fpart;
								}
								else if(string.charAt(i) == '"')
								{
									spart = string.slice(0, i);
									fpart = string.slice(i+1, string.length);
									
									string = spart + fpart;
								}
						}
						
						string = string.replace(/\\n/g, "\n");
						obj[j] = string;
						
					}
					
					DICTIONARY[csv.data[s][0]] = csv.data[s][1];
				}
				
				callback();
			}
		}
	}
}