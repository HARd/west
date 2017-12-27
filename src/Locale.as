package  
{
	import core.Lang;
	/**
	 * ...
	 * @author 
	 */
	public class Locale 
	{
		
		public static var data:Object;
		
		public function Locale() 
		{
			
		}
		
		
		public static function __e(text:String, params:* = null):String
		{
			
			//var obj = LanguageManager.DICTIONARY;
				if (params != null) 
				{
					if (Lang.DICTIONARY[text] != null)
					{
						text = Lang.DICTIONARY[text]
					}
					
					if (!(params is Array)) {
						params = new Array(params, null);
					}
				
					var chunks:Array = text.split(/(\[.*\])/);
					
					for (var i:String in chunks) {
						var chunk:* = chunks[i];
						if(chunk.indexOf('[') == 0){
							//Обреflash:1382952379984ем квадратные скобки
							chunk = chunk.slice(1, chunk.length - 1);
							//Делим строку по символу |
							var variants:* = chunk.split(/\|/);
							
							//Получаем очередной праметр
							var param:*;
							if (params.length == 1) {
								param = params[0];
							}else{
								param = params.shift();
							}
							
							//Проверяем число для правильного склонения
							if (param is Number) {
								switch(param % 10) {
									case 1:  	if (param<11 || param>19){
													chunks[i] = variants[0].replace(/\%d/, param); break;
												}	
									case 2: 
									case 3:
									case 4: 	chunks[i] = variants[1].replace(/\%d/, param); break;
									default: 	chunks[i] = variants[2].replace(/\%d/, param); break;
								}
							}
						}else{
							while(params.length) {
								if(chunks[i].indexOf('%s') != -1 || chunks[i].indexOf('%d') != -1){
									var p:* = params.shift();
									if (!(p is Number) && chunks[i].indexOf('%s') != -1) { 
										chunks[i] = chunks[i].replace(/\%s/, p);
										//params.shift();
									}
									if (p is Number && chunks[i].indexOf('%d') != -1) {
										chunks[i] = chunks[i].replace(/\%d/, p);
										//params.splice(j,1);
									}
								}else {
									break;
								}
							}
						}
					}
					
					var outText:String = '';
					for each(var _chunk:* in chunks) {
						outText += _chunk;
					}
					
					if (params.length > 0) {
						for each(var _param:* in params) {
							outText = outText.replace(/\%d/, _param);
							outText = outText.replace(/\%s/, _param);
						}
					}
					if (App.social == 'FB') {
						outText = outText.replace(/Dreamfields/g, 'Fantasy Garden');
						outText = outText.replace(/Legends of Dreams/g, 'Fantasy Garden');
					}
					
					return outText;
				}
				else 
				{
					if (Lang.DICTIONARY[text] != null)
					{
						return Lang.DICTIONARY[text];
					}
					return text;
				}
		}
	}

}