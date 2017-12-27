package core
{
	import com.shortybmc.data.parser.CSV;
	import flash.events.Event;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;
	
	public class Lang
	{
		public static var DICTIONARY:Dictionary = new Dictionary();
		
		public static function loadLanguage(lg:String, callback:Function):void
		{
			if (lg == "ru_str")
			{
				callback();
				return;
			}
			
			var csv:CSV = new CSV();
			//csv.addEventListener (Event.COMPLETE, completeHandler);
			//csv.load(new URLRequest(Config.getLocale(lg)));
			
			var url_zip:String = Config.getLocale(lg);
			url_zip = url_zip.replace('.csv', '.zip');
			Load.loadZip(url_zip, function(data:*):void {
				if (data is String) {
					csv.data = data;
					csv.decode();
					completeHandler();
				}else {
					trace('LOADING: ', Config.getLocale(lg));
					csv.addEventListener(Event.COMPLETE, completeHandler);
					csv.addEventListener(SecurityErrorEvent.SECURITY_ERROR, function(e:*):void {
						Log.alert('SECURITY ERROR');
						Log.alert(e.toString());
					});
					csv.load(new URLRequest(Config.getLocale(lg)));
				}
			});
			
			//trace('LOADING: ', Config.getLocale(lg));
			
			function completeHandler(event:Event = null):void
			{
				for (var s:int = 0; s < csv.data.length; s++)
				{
					var obj:Object = csv.data[s];
					for (var j:int = 0; j < obj.length; j++)
					{
						var string:String = obj[j];
						
						for (var i:int = 0; i < string.length; i++)
						{
							var simbol:String = string.charAt(i);
							var spart:String;
							var fpart:String;
							
							if (string.charAt(i) == '"' && (string.charAt(i + 1) != null && string.charAt(i + 1) != '"'))
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