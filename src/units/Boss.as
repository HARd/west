package units 
{
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
	import wins.CharactersWindow;
	import wins.PurchaseWindow;
	public class Boss extends AUnit
	{
		
		public static const FROZEN_BOSS:uint = 392,
							FIRE_BOSS:int = 398,
							EARTH_BOSS:int = 478,
							AIR_BOSS:int = 479;
		
		public static var bosses:Array = [],
					      delay:uint = 50,
						  initTime:uint = 0;
						  static private var require:int;
						  static private var bossHaloColor:int;
		
		public var shadow:Bitmap,
				   position:Object = null;
		
		
		private var dX:Number = 0,
					dY:Number = 0,
					amplitude:Number = 40,
					altitude:uint = 400,
					viewportX:int,
					viewportY:int,
					start:Object,
					finish:Object,
					firstPos:Object,
					secondPos:Object,
					thirdPos:Object,
					fourthPos:Object,
					vittes:Number,
					t:Number = 0,
					live:Boolean = false,
					mouseOverBoss:Boolean = false,
					clickCounter:int = 0;
					
		public function Boss(object:Object) 
		{
			this.position = object.position;
			this.id = object.id || 0;
			Boss.bosses.push(this);
			
			layer = Map.LAYER_TREASURE;
			
			super(object);
			
			touchable	= true;
			clickable	= true;
			transable 	= false;
			moveable 	= false;
			removable 	= false;
			rotateable  = false;
			
			Load.loading(Config.getSwf(info.type, info.preview), onLoad);
			setMoveParams();
			startFly();
			//Load.loading(Config.getSwf('Tools', 'Boss'), onLoad);
			//App.data.storage[sid].description;
			tip = function():Object { 
				return {
					title:App.data.storage[sid].title,
					text:App.data.storage[sid].description
				};
			};
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
		
		/*private function showIcon(typeItem:String, callBack:Function, mode:int, btmDataName:String = 'productBacking2', scaleIcon:Number = 0.6):void 
		{
			if (App.user.mode == User.GUEST)
				return;
			
			if (cloudAnimal) {
				cloudAnimal.dispose();
				cloudAnimal = null;
			}
			
			cloudAnimal = new AnimalCloud(callBack, this, sid, mode);
			cloudAnimal.create(btmDataName);
			cloudAnimal.show();
			cloudAnimal.x = - 30;
			cloudAnimal.y = - 500;
			cloudAnimal.pluck(30);
			
			App.self.setOnTimer(hideIcon);
			startTime = App.time;
		}*/
		
		
		private function hideIcon():void
		{
			var duration:int = 3;
			var time:int = duration - (App.time - startTime);
			if (time < 0) {
					App.self.setOffTimer(hideIcon);
					//if (cloudAnimal) {
					//cloudAnimal.dispose();
					//cloudAnimal = null;
				}
			
		}
		
		private static function start(e:* = null):void {
			initTime = App.time;
			//App.self.setOnTimer(timer);
			addBoss();
		}
		
		public static function timer():void
		{
			return;
			if (initTime + delay <= App.time)
			{
				initTime = App.time;
				addBoss();
				delay = int(Math.random() * 30) + 60;
			}
		}
		
		private static function addBoss():void
		{
			var sid:uint;
			var worldID:uint = App.user.worldID;
			if (App.user.mode == User.GUEST)
				worldID = App.owner.worldID
				
			var lottery:int = Math.round(Math.random() * 3);
			//lottery = 0;	
			var txt:String;
			if (lottery == 0) {
				txt = Locale.__e('flash:1409299164759');
				sid = FROZEN_BOSS;
			}
			if (lottery == 1) {
				txt = Locale.__e('flash:1409299395052');
				sid = FIRE_BOSS;
			}
			if (lottery == 2) {
				txt = Locale.__e('flash:1411568890341');
				sid = EARTH_BOSS;
			}
			if (lottery == 3) {
				txt = Locale.__e('flash:1411568985660');
				sid = AIR_BOSS;
			}
			
			bossHaloColor = 0x000000;
			if (sid == FROZEN_BOSS)
				bossHaloColor = 0x25b3ef;
			if (sid == FIRE_BOSS)
				bossHaloColor = 0xef5425;
			if (sid == AIR_BOSS)
				bossHaloColor = 0x000055;
			if (sid == EARTH_BOSS)
				bossHaloColor = 0xab1a00;
			
			for (var id:* in App.data.storage[sid].require) {
				require = id;
			}
				
			var boss:Boss = new Boss( { sid:sid } );
			
			//new CharactersWindow( {escExit:true, quest: { character:6, title:Locale.__e('flash:1409299679964'), description:txt }, callback:function():void {
				//App.map.focusedOnCenter(boss);
			//}} ).show();
			
		}
		
		override public function get bmp():Bitmap {
			return animationBitmap;
		}
		
		public function setMoveParams():void {
			viewportX = Map.mapWidth - (Map.mapWidth + App.map.x);
			viewportY = Map.mapHeight - (Map.mapHeight + App.map.y);
			
			if(position == null) {
				x = viewportX + Math.random() * App.self.stage.stageWidth;
				y = viewportY + Math.random() * App.self.stage.stageHeight;
			} else {
				x = position.x;
				y = position.y;
			}
		}
		
		override public function onLoad(data:*):void {
			
			super.onLoad(data);
			
			textures = data;
			this.alpha = 0;
			
			//setMoveParams();
			
			//startAnimation();
			TweenLite.to(this, 1, { alpha:1} );	
			
			initAnimation();
			startAnimation();
			
			//setFlyCoords();
			
			//startFly();
		}
		
		//private function setFlyCoords():void 
		//{
			//var cells:Object = { };
			//var rows:Object = { };
			//var pieceCells:int = (Map.cells - 6) / 5;
			//var pieceRows:int = (Map.rows - 4) / 3;
			//var currentPieceCell:int = 0;
			//var currentPieceRow:int = 0;
			//for (var i:int = 0; i < 5; i++) 
			//{
				//cells[i] = IsoConvert.isoToScreen(int(currentPieceCell*pieceCells), 5, true);
				//
				//currentPieceCell++;
			//}
			//
			//for (var j:int = i; j < i+3; j++) 
			//{
				//rows[j] = IsoConvert.isoToScreen(Map.cells - 3, int(currentPieceRow*pieceRows), true);
				//
				//currentPieceRow++;
			//}
			//trace();
		//}
		
		private var poss:Object = {
			1: {
				x:1000,
				y:300
			},
			2: {
				x:1100,
				y:1100
			},
			3: {
				x:900,
				y:2200
			},
			4: {
				x:1200,
				y:2900
			},
			5: {
				x:2000,
				y:3000
			},
			6: {
				x:2800,
				y:3100
			},
			7: {
				x:3600,
				y:2900
			},
			8: {
				x:4400,
				y:2700
			},
			9: {
				x:5200,
				y:2900
			},
			10: {
				x:5000,
				y:2200
			},
			11: {
				x:5100,
				y:1400
			},
			12: {
				x:5000,
				y:400
			},
			13: {
				x:4200,
				y:390
			},
			14: {
				x:3600,
				y:370
			},
			15: {
				x:2800,
				y:400
			},
			16: {
				x:2000,
				y:410
			},
			17: {
				x:1000,
				y:300
			}
		}
		
		private function startFly(pos:int = 1):void
		{
			live = true;
			ay -= altitude;
			
			amplitude += int(Math.random() * 40 - 20);
			
			//var p1:Object = IsoConvert.isoToScreen(int((Map.rows - 10) + 5), -10, true);
			//var p2:Object = IsoConvert.isoToScreen(int((Map.rows - 10) + 5), Map.cells + 10, true);
			//positions = [p1,p2,p1,p2];
			
			//if(position == null) {
				
				start = poss[pos];
				if (pos == 17) {
					finish = poss[1];
				}else {
					finish = poss[pos+1];
				}
				
				//start = IsoConvert.isoToScreen(int((Math.random() * (Map.rows - 10) + 5)), -10, true);
				//finish = IsoConvert.isoToScreen(int((Math.random() * (Map.rows - 10) + 5)), Map.cells + 10, true);
			
				_altitude = altitude;
			//}else {
				//start = position;
				//finish = poss[pos+1];
				//_altitude = altitude;
				////start = position;
				////finish = IsoConvert.isoToScreen(int((Math.random() * (Map.rows - 10) + 5)), Map.cells + 10, true);
				////_altitude = 0;
			//}

			
			//start 	= { x: -10 * IsoTile.spacing, 				y:IsoTile.spacing * (Math.random() * (Map.rows - 10) + 5) };
			//finish 	= { x: IsoTile.spacing * (Map.cells + 10), 	y:IsoTile.spacing * (Math.random() * (Map.rows - 10) + 5) };
			
			//vittes = 0.0005;
			vittes = 0.0030;
			
			App.self.setOnEnterFrame(flying);
		}
		
		private var _altitude:int = 0;
		private var dAlt:uint = 2;
		private var startTime:int;
		private var counter:int;
		private var positions:Array;
		private var count:int = 1;
		private var _fps:uint = 31;
		private function flying(e:Event = null):void
		{
			t += vittes * (32 / (_fps));
			
			if (t >= 1 && live)
			{
				_fps = (App.self.fps)?App.self.fps:31;
				t = 0;
				count++;
				if (count > 17) {
					count = 1;
				}
				App.self.setOffEnterFrame(flying);
				startFly(count);
				//live = false;
				//TweenLite.to(this, 0.5, { alpha:0, onComplete:uninstall } );
			}
			
			var nextX:Number = int(start.x + (finish.x - start.x) * t);
			var nextY:Number = int(start.y + (finish.y - start.y) * t);
			
			//var place:Object = IsoConvert.isoToScreen(nextX, nextY, false);
				
			x = nextX;// place.x;
			y = nextY;// place.y;
			
			if (_altitude < altitude)
				_altitude += dAlt;
			
			ay = (amplitude * Math.sin(0.01 * x)) - _altitude;
		}
		
		override public function remove(callback:Function = null):void {
			
		}
		
		private function onCloudClick(e:* = null):void {
			click();
		}
		
		public override function click():Boolean {
			if (!clickable) return false;
			clickCounter++;
			
			if (clickCounter == 1) {
				var clickTime:int = App.time;
				//showIcon('require', onCloudClick, AnimalCloud.MODE_NEED, 'productBacking2'/*, 0.7*/);
				clickCounter = 1;
				return true;
			}
			App.self.setOnTimer(crearClicks);
			function crearClicks():void {
				var duration:int = 1;
				var time:int = duration - (App.time - clickTime);
				if (time < 0) {
					App.self.setOffTimer(crearClicks);
					clickCounter = 0;
				}
			}
			
			if (!App.user.stock.check(require, 1) && clickCounter == 2) {
				clickCounter = 0;
				
				new PurchaseWindow( {
					width:395,
					itemsOnPage:2,
					content:PurchaseWindow.createContent("Energy", {view:'Magic'}),
					find:require,
					title:Locale.__e("flash:1396606700679"),
					description:Locale.__e("flash:1382952379757"),
					callback:function(sID:int):void {
						var object:* = App.data.storage[sID];
						App.user.stock.add(sID, object);
					}
				}).show()
			}
			
			if (clickCounter == 2 && App.user.stock.take(require, 1)) {
				haloEffect(bossHaloColor, this.parent);
				Post.send( {
					ctr:'boss',
					act:'kill',
					uID:App.user.id,
					sID:sid
				}, onLightAction);
			}
			return true;
		}
		
		public function storageEvent(count:int = 1):void {
			
		}
		
		private function removeFromStock():void {
			if (sid != FROZEN_BOSS)
			{
				if(App.user.stock.count(sid) > 0)
					App.user.stock.sell(sid, 1);
			}
		}
		
		private function onLightAction(error:int, data:Object, params:Object = null):void
		{
			if (error)
			{
				Errors.show(error, data);
				return;
			}
			//haloEffect(bossHaloColor, this.parent);
			Hints.minus(require, 1, new Point(this.x*App.map.scaleX + App.map.x, this.y*App.map.scaleY + App.map.y + ay*App.map.scaleY), true);
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
			var index:int = bosses.indexOf(this);
			bosses.splice(index, 1);
			
			App.self.setOffEnterFrame(flying);
			App.map.removeUnit(this);
		}
		
		override public function addAnimation():void
		{
			super.addAnimation();
			for each(var multipleObject:Object in multipleAnime) {
				animationBitmap = multipleObject.bitmap;
				return;
			}
		}
		
		override public function set state(state:uint):void {
			if (_state == state) return;
			
			switch(state) {
				case TOCHED: animationBitmap.filters = [new GlowFilter(0xFFFF00, 1, 6, 6, 7)];
					App.self.setOffEnterFrame(flying);
				break;
				case DEFAULT: animationBitmap.filters = []; 
				mouseOverBoss = false;
				App.self.setOnEnterFrame(flying);
				break;
			}
			_state = state;
		}	
		
		public static function dispose():void
		{
			App.self.setOffTimer(timer);
			for each(var boss:Boss in Boss.bosses) {
				boss.uninstall();
			}
			Boss.bosses = [];
		}
	}
}