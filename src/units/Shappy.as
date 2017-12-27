package units 
{
	import core.Numbers;
	import core.Post;
	import wins.ShappyWindow;
	public class Shappy extends Building 
	{
		public static var rate:int = 0;
		public static var position:int = 0;
		public static var rates:Object = { };
		
		public var topID:int;
		public var expire:int = 0;
		
		public function Shappy(object:Object) 
		{
			super(object);
			
			for (var topID:* in App.data.top) {
				if (App.data.top[topID].unit == this.sid) {
					this.topID = topID;
					break;
				}
			}
			if (this.topID != 0)
				expire = App.data.top[this.topID].expire.e;
			
			// Удаляется после 2 недель после завершения ивента
			if (expire + 86400 > App.time)
				removable = false;
			
		}
		
		override public function click():Boolean 
		{
			if (App.user.mode == User.GUEST) {
				guestClick();
				return true;
			}
			
			checkPosition(openProductionWindow);
			return true;
		}
		
		override public function openProductionWindow(settings:Object = null):void {
			new ShappyWindow( {
				target:this
			}).show();
		}
		
		public static var rateChecked:int = 0;
		public static var rateSended:Object = {};
		private var onUpdateRate:Function;
		public function getRate(callback:Function = null):void {			
			onUpdateRate = callback;
			
			Post.send( {
				ctr:		'top',
				act:		'users',
				uID:		App.user.id,
				tID:		topID
			}, function(error:int, data:Object, params:Object):void {
				if (error) return;
				
				rateChecked = App.time;
				
				if (data.hasOwnProperty('users')) {
					Shappy.rates = data['users'] || { };
					
					for (var id:* in Shappy.rates) {
						if (App.user.id == id) {
							Shappy.rate = Shappy.rates[id]['points'];
							//isInTop = true;
						}
						
						Shappy.rates[id]['uID'] = id;
					}
				}
				
				if (App.user.top.hasOwnProperty(topID)) {
					Shappy.rate = (Shappy.rate > App.user.top[topID].count) ? Shappy.rate : App.user.top[topID].count;
				}
				
				
				if (Numbers.countProps(Shappy.rates) > 100) {
					var array:Array = [];
					for (var s:* in Shappy.rates) {
						array.push(Shappy.rates[s]);
					}
					array.sortOn('points', Array.NUMERIC | Array.DESCENDING);
					array = array.splice(0, 100);
					for (s in Shappy.rates) {
						if (array.indexOf(Shappy.rates[s]) < 0)
							delete Shappy.rates[s];
					}
				}
				
				if (onUpdateRate != null) {
					onUpdateRate();
					onUpdateRate = null;
				}
				
			});
		}
		
		public function checkPosition(callback:Function = null):void {
			Post.send( {
				ctr:		'top',
				act:		'position',
				uID:		App.user.id,
				tID:		topID
			}, function(error:int, data:Object, params:Object):void {
				if (error) return;
				
				if (data.hasOwnProperty('position')) {
					position = data.position;
				}
				
				if (callback != null) {
					callback();
				}
			});
		}
		
		override public function checkOnAnimationInit():void {			
			if (textures && textures['animation']) {
				initAnimation();
				//beginAnimation();
				startAnimation();
			}
		}
		
	}

}