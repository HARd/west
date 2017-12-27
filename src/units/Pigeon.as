package units
{
	import core.IsoConvert;
	import core.Load;
	import core.Post;
	import flash.display.Bitmap;
	import flash.filters.GlowFilter;
	import wins.FiestaWindow;
	import wins.NewsWindow;
	
	public class Pigeon extends AUnit
	{
		public static var pigeon:Pigeon = null;
		
		public static function dispose():void {
			pigeon = null;
		}
		
		public static function checkNews(limit:int = 4):void
		{
			//return;
			//if (App.social == 'NK' || App.social == 'FB') return;
			
			if (pigeon != null) return;
			if (App.user.quests.tutorial) return;
			if (User.inExpedition) return;
			
			var news:Array = [];
			var updatelist:Array = [];
			var first:Boolean = false;
			var update:Object;
			
			//if (!App.data.hasOwnProperty(updatelist)) return;
			if(App.data.updatelist.hasOwnProperty(App.social)) {
				for (var s:String in App.data.updatelist[App.social]) {
					if (!App.data.updates.hasOwnProperty(s)) continue;
					if (!App.data.updates[s].social.hasOwnProperty(App.social)) continue;
					updatelist.push( {
						nid: s,
						update: App.data.updates[s],
						order: App.data.updatelist[App.social][s]
					});
				}
				updatelist.sortOn('order', Array.NUMERIC);
				updatelist.reverse();
			}
			if (updatelist[0])
			{
				update = updatelist[0].update;
				update['nid'] = updatelist[0].nid;
			}
			
			if (update == null) return;
				
			var count:int = 1;
			var _cookie:String = App.user.storageRead('upd', '');
			var cookie:Array = _cookie.split("_");
			
			if (cookie.length == 0 || cookie[0] != update.nid) {
				cookie[0] = update.nid;
				cookie[1] = count;
				if (cookie[2]) cookie[2] = 0;
			}else {
				cookie[1] = int(cookie[1]) + 1;
				count = cookie[1];
			}
			
			if (count < limit) {
				App.user.storageStore('upd', cookie.join('_'));
				
				Load.loading(Config.getImageIcon('updates/images', update.preview), function(data:Bitmap):void {
					//new FiestaWindow( { news:update } ).show();
					new NewsWindow({news:update}).show();
				});
			}
		}
		
		private var news:Object;
		
		public function Pigeon(object:Object) 
		{
			layer = Map.LAYER_TREASURE;
			this.news = object.news;
			
			super(object);
			
			removable = false;
			
			touchable	= true;
			clickable	= true;
			transable 	= false;
			moveable 	= false;
			removable 	= false;
			rotateable  = false;
			
			type = "News";
			framesType = "pigeon";
			
			Load.loading(Config.getSwf(type, 'pigeon'), onLoad);
			
			tip = function():Object { 
				return {
					title:Locale.__e("flash:1382952379938"),
					text:Locale.__e("flash:1382952379939")
				};
			};
			
			var coord:Object = IsoConvert.isoToScreen(App.map.heroPosition.x, App.map.heroPosition.z, true);
			this.x = coord.x + 250; //- 70;
			this.y = coord.y - 180;//  + 400//- 100;
		}
		
		override public function get bmp():Bitmap {
			return animationBitmap;
		}
		
		override public function onLoad(data:*):void {
			
			super.onLoad(data);
			
			textures = data;
			initAnimation();
			startAnimation();
		}
		
		override public function addAnimation():void
		{
			super.addAnimation();
			for each(var multipleObject:Object in multipleAnime) {
				animationBitmap = multipleObject.bitmap;
				return;
			}
		}
		
		public override function click():Boolean {
			if (!clickable) return false;
			if (App.user.quests.tutorial) return false;
			
			//new NewsWindow({news:news}).show();
			new FiestaWindow( { news:news } ).show();
			
			//uninstall()
			return true;
		}
		
		public override function uninstall():void
		{
			App.map.removeUnit(this);
		}
		
		override public function set state(state:uint):void {
			if (_state == state) return;
			
			switch(state) {
				case TOCHED: animationBitmap.filters = [new GlowFilter(0xFFFF00,1, 6,6,7)]; break;
				case DEFAULT: animationBitmap.filters = []; break;
			}
			_state = state;
		}
	}
}