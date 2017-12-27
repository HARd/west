package core 
{
	import flash.utils.ByteArray;
	public class Numbers 
	{
		
		public function Numbers() 
		{
			
		}	
	
		public static function moneyFormat(count:int):String {
			var r:RegExp = /\d\d\d$/g;
			var s:String = count.toString();
			var a:Array = new Array();
			var res:String ='';

			while (s.length > 3){
				a.push(' '+s.match(r));
				s = s.replace(r,'');
			}

			for (var i:int = a.length; i > 0; i--) {
				res = res+a[i-1];
			}

			res = s + res;
			return res;
		}
		
		public static function countProps(object:Object = null):int {
			var nums:int = 0;
			
			if (object)
				for (var s:String in object) nums++;
			
			return nums;
		}
		
		public static function firstProp(object:Object = null):* {
			for (var o:* in object) {
				return { key:o, val:object[o] };
			}
		}
		
		public static function getProp(object:Object, num:int = 0):Object {
			var i:int = 0;
			for (var itm:* in object) {
				if (i == num) {
					return {key:itm, val:object[itm]}
				}
				i++;
			}
			return { };
		}
		
		public static function speedUpPrice(time:int):int {
			if (App.data.options['SpeedUpPrice'] is Number) {
				return Math.ceil(time / App.data.options['SpeedUpPrice']);
			}else if (App.data.options['SpeedUpPrice'] is String) {
				try {
					var object:Object = JSON.parse(App.data.options['SpeedUpPrice']);
					var lowest:int = int(object[0]);
					var lowestTime:int = 0;
					for (var s:* in object) {
						if (int(s) > 0) {
							if (int(s) > time && (lowestTime > int(s) || lowestTime == 0)) {
								lowestTime = int(s);
								lowest = int(object[s]);
							}
						}
					}
					
					return lowest;
				}catch(e:*) {}
			}
			
			return Math.ceil(time / 3600);
		}
		
		public static function copyObject(inObj:*):* {
			var copier:ByteArray = new ByteArray();
			copier.writeObject(inObj);
			copier.position = 0;
			var outObj:* = copier.readObject();
			return outObj;
		}
		
	}

}