package units 
{
	import api.ExternalApi;
	import com.greensock.TweenLite;
	import core.IsoConvert;
	import core.IsoTile;
	import core.Load;
	import core.Post;
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import ui.Hints;
	import ui.UserInterface;
	import wins.PurchaseWindow;
	public class Lantern extends AUnit
	{
		
		public static const LANTERN:uint = 585;
		public static const LANTERN_BLUE:uint = 586;
		public static const LANTERN_RED:uint = 587;
		public static const WBALOON:uint = 637;
		
		
		public static var lanterns:Array = [];
		public static var delay:uint = 50;
		public static var initTime:uint = 0;
		
		public var shadow:Bitmap;
		private var dX:Number = 0;
		private var dY:Number = 0;
		private var amplitude:Number = 40;
		private var altitude:uint = 400;
		
		private var viewportX:int;
		private var viewportY:int;
		
		private var start:Object;
		private var finish:Object;
		private var vittes:Number;
		private var t:Number = 0;
		private var live:Boolean = false;
		
		
		public static function dispose():void
		{
			App.self.setOffTimer(timer);
			for each(var lantern:Lantern in Lantern.lanterns) {
				lantern.uninstall();
			}
			Lantern.lanterns = [];
		}
		
		public static function init():void
		{
			//return;
			if (App.user.quests.tutorial) {
				App.self.addEventListener(AppEvent.ON_FINISH_TUTORIAL, start);
				return;
			}
				
			start();
		}
		
		private static function start(e:* = null):void {
			initTime = App.time;
			App.self.setOnTimer(timer);
			addLantern();
		}
		
		public static function timer():void
		{
			if (initTime + delay <= App.time)
			{
				initTime = App.time;
				addLantern();
				delay = int(Math.random() * 30) + 60;
			}
		}
		
		private static function addLantern():void
		{
			if (App.user.worldID == 555 || App.user.worldID == 1198) return;
			var sid:uint;
			var worldID:uint = App.user.worldID;
			if (App.user.mode == User.GUEST)
				worldID = App.owner.worldID
				
			//sid = App.data.storage[worldID].lantern;
			//sid = 344//test
			sid = 274;
			
			if(App.user.worldID == 1907)
				sid = 1897;
				
			if (App.user.worldID == Travel.SAN_MANSANO)
				sid = 2425;
				
			if (Nature.mode == Nature.HALLOWEEN)
				sid = 762; 
				
			new Lantern({sid:sid});
		}
		
		public var position:Object = null
		public function Lantern(object:Object) 
		{
			this.position = object.position;
			this.id = object.id || 0;
			Lantern.lanterns.push(this);
			
			layer = Map.LAYER_TREASURE;
			
			if (sid == 1897) {
				layer = Map.LAYER_SORT;
			}
			
			super(object);
			
			touchable	= true;
			clickable	= true;
			transable 	= false;
			moveable 	= false;
			removable 	= false;
			rotateable  = false;
			
			if (sid == 1897) {
				altitude = 40;
			}
			
			Load.loading(Config.getSwf(info.type, info.view), onLoad);
			
			tip = function():Object { 
				return {
					title:App.data.storage[sid].title,
					text:Locale.__e("flash:1382952379937")
				};
			};
		}
			
		override public function get bmp():Bitmap {
			return animationBitmap;
		}
		
		override public function onLoad(data:*):void {
			
			super.onLoad(data);
			
			textures = data;
			this.alpha = 0;
			
			viewportX = Map.mapWidth - (Map.mapWidth + App.map.x);
			viewportY = Map.mapHeight - (Map.mapHeight + App.map.y);
			
			if(position == null) {
				x = viewportX + Math.random() * App.self.stage.stageWidth;
				y = viewportY + Math.random() * App.self.stage.stageHeight;
			} else {
				x = position.x;
				y = position.y;
			}
			
			//startAnimation();
			TweenLite.to(this, 1, { alpha:1} );	
			
			initAnimation();
			startAnimation();
			startFly();
		}
		
		private function startFly():void
		{
			live = true;
			ay -= altitude;
			
			shadow = new Bitmap(UserInterface.textures.shadow);
			addChildAt(shadow, 0);
			shadow.x = - shadow.width / 2;
			shadow.y = - 4;
			shadow.alpha = 0.5;
			
			amplitude 	+= int(Math.random() * 40 - 20);
			
			if(position == null) {
				
				start = IsoConvert.isoToScreen(int((Math.random() * (Map.rows - 10) + 5)), -10, true);
				finish = IsoConvert.isoToScreen(int((Math.random() * (Map.rows - 10) + 5)), Map.cells + 10, true);
			
				_altitude = altitude;
			}else {
				start = position;
				finish = IsoConvert.isoToScreen(int((Math.random() * (Map.rows - 10) + 5)), Map.cells + 10, true);
				_altitude = 0;
			}

			
			//start 	= { x: -10 * IsoTile.spacing, 				y:IsoTile.spacing * (Math.random() * (Map.rows - 10) + 5) };
			//finish 	= { x: IsoTile.spacing * (Map.cells + 10), 	y:IsoTile.spacing * (Math.random() * (Map.rows - 10) + 5) };
			
			vittes = 0.0005;
			
			App.self.setOnEnterFrame(flying);
			
			//var scale:Number = Math.random() * 0.2 + 0.8;
			//animationBitmap.scaleX = animationBitmap.scaleY = scale;
			//animationBitmap.smoothing = true;
		}
		
		private var _altitude:int = 0;
		private var dAlt:uint = 2;
		private function flying(e:Event = null):void
		{
			t += vittes * (32 / App.self.fps);

			if (t >= 1 && live)
			{
				live = false;
				TweenLite.to(this, 0.5, { alpha:0, onComplete:uninstall } );
			}
			
			var nextX:Number = int(start.x + (finish.x - start.x) * t);
			var nextY:Number = int(start.y + (finish.y - start.y) * t);
			
			//var place:Object = IsoConvert.isoToScreen(nextX, nextY, false);
				
			x = nextX;// place.x;
			y = nextY;// place.y;
			
			if (_altitude < altitude)
				_altitude += dAlt;
			
			//ay = (amplitude * Math.sin(0.01 * x)) - _altitude;
		}
		
		override public function remove(callback:Function = null):void {
			
		}
		
		public override function click():Boolean {
			if (!clickable) return false;
			if (! App.user.stock.check(Stock.FANTASY, 1)) 
			{
				new PurchaseWindow( {
					width:595,
					itemsOnPage:3,
					content:PurchaseWindow.createContent("Energy", {view:'energy'}),
					title:Locale.__e("flash:1382952379756"),
					fontBorderColor:0xd49848,
					shadowColor:0x553c2f,
					shadowSize:4,
					description:Locale.__e("flash:1382952379757"),
					popup: true,
					callback:function(sID:int):void {
						var object:* = App.data.storage[sID];
						App.user.stock.add(sID, object);
					}
				}).show();
				return false;
			}
			
			//haloEffect(null, this.parent);
			
			Post.send( {
				ctr:'Gift',
				act:'light',
				uID:App.user.id,
				sID:sid
				}, onLightAction);
			
			clickable = false;
			touchable = false;
			ordered = true;
			
			return true;
		}
		
		private function removeFromStock():void {
			if (sid != LANTERN)
			{
				if(App.user.stock.count(sid) > 0)
					App.user.stock.sell(sid, 1);
			}
		}
		
		private function onLightAction(error:int, data:Object, params:Object = null):void
		{
			if (error)
			{
				if (error == 23 || error == 19)
				{
					uninstall();
					return;
				}
				
				Errors.show(error, data);
				return;
			}
			
			//if (App.social == 'FB') {
				//ExternalApi._6epush([ "_event", { "event":"gain", "item":"lantern_bonus" } ]);
			//}
			
			Hints.minus(Stock.FANTASY, 1, new Point(this.x*App.map.scaleX + App.map.x, this.y*App.map.scaleY + App.map.y + ay*App.map.scaleY), true);
			
			if (data.hasOwnProperty("bonus")) {
				Treasures.bonus(data.bonus, new Point(this.x, this.y + ay));
				SoundsManager.instance.playSFX('bonus');
			}
			uninstall();
			
			if (data.hasOwnProperty(Stock.FANTASY)) {
				App.user.stock.setFantasy(data[Stock.FANTASY]);
			}
		}
		
		public override function uninstall():void
		{
			var index:int = lanterns.indexOf(this);
			lanterns.splice(index, 1);
			
			App.self.setOffEnterFrame(flying);
			App.map.removeUnit(this);
		}
		
		override public function addAnimation():void
		{
			ax = textures.animation.ax;
			ay = textures.animation.ay;
			
			clearAnimation();
			
			var arrSorted:Array = [];
			for each(var nm:String in framesTypes) {
				arrSorted.push(nm); 
			}
			arrSorted.sort();
			
			for (var i:int = 0; i < arrSorted.length; i++ ) {
				var name:String = arrSorted[i];
				multipleAnime[name] = { bitmap:new Bitmap(), cadr: -1 };
				//animationContainer.addChild(multipleAnime[name].bitmap);
				bitmapContainer.addChild(multipleAnime[name].bitmap);
				
				if (textures.animation.animations[name]['unvisible'] != undefined && textures.animation.animations[name]['unvisible'] == true) {
					multipleAnime[name].bitmap.visible = false;
				}
				multipleAnime[name]['length'] = textures.animation.animations[name].chain.length;
				multipleAnime[name]['frame'] = 0;
			}
			for each(var multipleObject:Object in multipleAnime) {
				animationBitmap = multipleObject.bitmap;
				return;
			}
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