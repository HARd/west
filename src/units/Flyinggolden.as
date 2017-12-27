package units
{
	import com.greensock.easing.Linear;
	import com.greensock.TweenLite;
	import com.greensock.TweenMax;
	import core.IsoConvert;
	import core.Post;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	import ui.UnitIcon;
	import wins.SpeedWindow;
	
	public class Flyinggolden extends Tribute
	{		
		public static const FACE:int = 0;
		public static const BACK:int = 1;
		public static const LEFT:int = 0;
		public static const RIGHT:int = 1;
		
		public var numPositions:int = 8;
		public var numAwayPositions:int = 5;
		
		public var framesDirection:int = FACE;
		public var framesFlip:int = LEFT;
		
		private var _tribute:Boolean = false;
		public var capacity:int = 0;
		
		private var _flying:Boolean = false;
		private var flyHome:Boolean = false;
		private var _flyReturn:Boolean = false;
		private var _flyAway:Boolean = false;
		private var _flyHome:Boolean = false;
		private var startPos:Object = {x:0, y:0};
		private var awayPos:Object = {x:1000, y:1000};
		private var dX:Number = 0,
					dY:Number = 0,
					amplitude:Number = 40,
					altitude:uint = 400,
					viewportX:int,
					viewportY:int,
					start:Object,
					finish:Object,
					vittes:Number,
					t:Number = 0,
					position:Object = null;
		private var possSeagal:Object = {
			1: {
				x:0,
				y:200
			},
			2: {
				x:1836,
				y:726
			},
			3: {
				x:1795,
				y:676
			},
			4: {
				x:1526,
				y:1465
			},
			5: {
				x:1587,
				y:2128
			},
			6: {
				x:2059,
				y:2818
			},
			7: {
				x:2810,
				y:3159
			},
			8: {
				x:3681,
				y:3210
			},
			9: {
				x:4649,
				y:2771
			},
			10: {
				x:4955,
				y:2128
			},
			11: {
				x:5053,
				y:1575
			},
			12: {
				x:4779,
				y:855
			},
			13: {
				x:3765,
				y:675
			},
			14: {
				x:3034,
				y:516
			}
		}
		private var poss:Object = {
			1: {
				x:0,
				y:200
			},
			2: {
				x:1836,
				y:726
			},
			3: {
				x:1210,
				y:1734
			},
			4: {
				x:2663,
				y:2520
			},
			5: {
				x:4679,
				y:2447
			},
			6: {
				x:5130,
				y:1518
			},
			7: {
				x:4169,
				y:538
			},
			8: {
				x:3281,
				y:552
			}
		}
		
		private var possAway:Object = {
			1: {
				x:0,
				y:200
			},
			2: {
				x:2461,
				y:1255
			},
			3: {
				x:2663,
				y:2520
			},
			4: {
				x:4491,
				y:2530
			},
			5: {
				x:5283,
				y:2822
			},
			6: {
				x:7000,
				y:3000
			}
		}
		
		private var possReturn:Object = {
			1: {
				x:0,
				y:0
			},
			2: {
				x:1836,
				y:726
			}
		}
		
		private var possHome:Object = {
			1: {
				x:0,
				y:0
			},
			2: {
				x:1836,
				y:726
			}
		}
		
		public function Flyinggolden(object:Object)
		{
			crafted = object.crafted || 0;
			
			crafting = true;
			
			if (object.capacity)
				capacity = object.capacity;
			
			if (object.hasOwnProperty('level'))
				level = object.level;
			
			super(object);
			
			moveable = true;
			stockable = false;
			
			if (sid == 902) {
				numPositions = 14;
				poss = possSeagal;
			}
			
			tip = function():Object
			{
				if (App.user.mode == User.GUEST) {
					return {
						title:info.title,
						text:Locale.__e('flash:1382952379966')
					};
				}
				var subText:String = Locale.__e('flash:1414400030281', [info.capacity - capacity]);
				if (!info.capacity || info.capacity == 0)
					subText = '';
				
				if (_tribute)
				{
					return {title: info.title, text: Locale.__e("flash:1382952379966") + '\n' + subText};
				}
				
				return {title: info.title, text: sid == 360 ? Locale.__e("flash:1430991777391") + '\n' + TimeConverter.timeToStr(crafted - App.time) + subText : Locale.__e("flash:1382952379839", [TimeConverter.timeToStr(crafted - App.time)]) + '\n' + subText, timer: true};
			}
			
			
			beginCraft(0, crafted);
			setMoveParams();
		}
		
		override public function onLoad(data:*):void 
		{
			super.onLoad(data);
			
			startPos.x = animationContainer.x;
			startPos.y = animationContainer.y;
			
			if (App.time < crafted) {
				flyHome = false;
			} else {
				flyHome = true;
			}
			
			setMoveParams();
			_flyReturn = true;
			startFly();
			//flyReturn();
		}
		
		override public function beginCraft(fID:uint, crafted:uint):void
		{
			this.fID = fID;
			this.crafted = crafted;
			hasProduct = false;
			crafting = true;
			
			App.self.setOffTimer(work);
			App.self.setOnTimer(work);
		}
		
		public function set tribute(value:Boolean):void
		{
			_tribute = value;
		}
		
		private var wasClick:Boolean = false;
		
		override public function click():Boolean
		{
			if (wasClick) return false;
			
			   if (App.user.mode == User.GUEST) {
			   return true;
			   }
			
			   if (!isReadyToWork()) return true;
			 if (isProduct()) return true;
			
			return true;
		}
		
		override public function isReadyToWork():Boolean
		{
			if (crafted > App.time)
			{
				new SpeedWindow({title: info.title, target: this, priceSpeed: info.skip, info: info, finishTime: crafted, totalTime: App.data.storage[sid].time, doBoost: onBoostEvent, btmdIconType: App.data.storage[sid].type, btmdIcon: App.data.storage[sid].preview}).show();
				return false;
				
			}
			return true;
		}
		
		override protected function onStockAction(error:int, data:Object, params:Object):void {
			/*super.onStockAction(error, data, params);
			
			open = true;*/
			
			if (error) {
				Errors.show(error, data);
				return;
			}
			
			/*if (contLight) {
				removeChild(contLight);
				contLight = null;
			}*/
			
			this.id = data.id;
			started = App.time;
			
			//this.cell = coords.x; 
			//this.row = coords.z;
			
			//movePoint.x = coords.x;
			//movePoint.y = coords.z;
			
			created = App.time + App.data.storage[sid].time;
			crafted = 0;// App.time + App.data.storage[sid].time;
			
			beginCraft(0, created);
			
			moveable = true;
			
			tribute = false;
			
			hasProduct = false;
			open = true;
			
			showIcon();
		}
		
		override protected function onBuyAction(error:int, data:Object, params:Object):void 
		{
			if (error) {
				Errors.show(error, data);
				return;
			}
			this.id = data.id;
			open = true;
			
			crafted = App.time + info.time;
			started = App.time;
			
			tribute = false;
			
			setMoveParams();
			//beginCraft(0, crafted);
			//beginAnimation();
		}
		
		override public function onBoostEvent(count:int = 0):void
		{
			
			if (App.user.stock.take(Stock.FANT, count))
			{
				
				started = App.time - info.time;
				crafted = App.time - info.time;
				
				var that:Flyinggolden = this;
				
				onProductionComplete();
				
				Post.send({ctr: this.type, act: 'boost', uID: App.user.id, id: this.id, wID: App.user.worldID, sID: this.sid}, function(error:*, data:*, params:*):void
					{
						
						if (!error && data)
						{
							started = data.started;
							App.ui.flashGlowing(that);
						}
						
						flyHome = true;
						//if (!_flying) flyReturn();
						if (!_flying) {
							count = 1;
							path_L = 1;
							currentPath = possReturn;
							TweenLite.to(that.animationContainer, 0.5, { alpha:1 } );
							_flyReturn = true;
							startFly();
						}
					
					});
			}
		}
		
		override public function storageEvent(value:int = 0):void
		{
			if (App.user.mode == User.OWNER)
			{
				wasClick = true;
				Post.send({ctr: this.type, act: 'storage', uID: App.user.id, id: this.id, wID: App.user.worldID, sID: this.sid}, onStorageEvent);
			}
			
			tribute = false;
		}
		
		override public function onStorageEvent(error:int, data:Object, params:Object):void
		{
			wasClick = false;
			if (error)
			{
				Errors.show(error, data);
				return;
			}
			
			ordered = false;
			crafted = App.time + App.data.storage[sid].time;
			
			if (data.hasOwnProperty('started'))
			{
				App.self.setOnTimer(work);
			}
			
			Treasures.bonus(data.bonus, new Point(this.x, this.y));
			SoundsManager.instance.playSFX('bonus');
			
			tribute = false;
			hasProduct = false;
			
			clearIcon();
			flyHome = false;
			if (!_flying) {
				tweenBirdUp();
				/*_flyReturn = false;
				
				path_L = 8;
				count = 1;
				currentPath = poss;
				startFly();*/
			}
			//if (!_flying) takeOn();
		}
		
		override public function work():void
		{
			if (App.time >= crafted)
			{
				App.self.setOffTimer(work);
				tribute = true;
				onProductionComplete();
			}
		}
		
		override public function onProductionComplete():void
		{
			hasProduct = true;
			crafting = false;
			crafted = 0;
			showIcon();
		}
		
		override public function onLoop():void {
			multipleAnime[_name].frame = 0;
			if (_name == 'take_on') {
				startFly();
			} else {
				super.onLoop();
			}
		}
		
		private function tweenBirdUp():void {
			TweenMax.to(animationContainer, 1, { y: -220, onUpdate:function():void {
				/*if (ay > textures.animation.ay) ay--;
				if (ay < textures.animation.ay) ay++;*/
				
				multipleAnime[_name].bitmap.visible = false;
				_name = 'take_off';
				multipleAnime[_name].bitmap.visible = true;
				
				},onComplete:function():void {
					animationContainer.y = 0;
					
					_flyReturn = false;
					
					path_L = numPositions;
					count = 1;
					currentPath = poss;
					startFly();
				}
			} );
		}
		
		private function tweenBirdDown():void {
			animationContainer.y = -60;
			var time:Number = Math.ceil(Math.abs(Math.abs(ay) - Math.abs(textures.animation.ay)) / 30);
			TweenMax.to(animationContainer, time, { y:0, onUpdate:function():void {
				if (ay > textures.animation.ay) ay--;
				if (ay < textures.animation.ay) ay++;
				
				multipleAnime[_name].bitmap.visible = false;
				_name = 'fly';
				multipleAnime[_name].bitmap.visible = true;
				
				},onComplete:function():void {
					animationContainer.y = 0; 
					ay = textures.animation.ay;
					multipleAnime[_name].bitmap.visible = false;
					_name = 'take_off';
					multipleAnime[_name].bitmap.visible = true;
					
					_flying = false;
				}
			} );
		}
		
		private var indent:int = 0;
		public function setMoveParams():void {	
			var begin:Object = IsoConvert.isoToScreen(this.coords.x, this.coords.z, true);
			poss[1].x = begin.x;
			poss[1].y = begin.y;
			
			possHome[2].x = begin.x;
			possHome[2].y = begin.y;
			
			path_L = 1;
			currentPath = possReturn;
			
			//startPos.x = this.x;
			//startPos.y = this.y;
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
				animationContainer.addChild(multipleAnime[name].bitmap);
				//bitmapContainer.addChild(multipleAnime[name].bitmap);
				
				if (textures.animation.animations[name]['unvisible'] != undefined && textures.animation.animations[name]['unvisible'] == true) {
					multipleAnime[name].bitmap.visible = false;
				}
				multipleAnime[name]['length'] = textures.animation.animations[name].chain.length;
				multipleAnime[name]['frame'] = 0;
			}
			for each(var multipleObject:Object in multipleAnime) {
				//animationBitmap = multipleObject.bitmap;
				return;
			}
		}
		
		private function takeOn():void {
			animationContainer.x = 0;
			animationContainer.y = 0;
			animationContainer.visible = true;
			
			multipleAnime[_name].frame = 0;
			multipleAnime[_name].bitmap.visible = false;
			_name = 'take_on';
			multipleAnime['take_on'].bitmap.visible = true;
			count = 1;
			setTimeout(tweenBirdUp, 1000);
		}
		
		private var currentPath:Object;
		private function startFly(pos:int = 1):void {
			App.map.mTreasure.addChild(animationContainer);
			_flying = true;
			animationContainer.y = 0;
			animationContainer.visible = true;
			
			ay -= altitude;
			
			amplitude += int(Math.random() * 40 - 20);
			
			start = currentPath[pos];
			if (pos == path_L && !_flyAway) {
				finish = currentPath[2];
			}else {
				finish = currentPath[pos+1];
			}
			_altitude = altitude;
			var time:Number = Math.random() / 100;
			if (time < 0.001) time = 0.001;
			if (time > 0.006) time = 0.006;
			//trace(time);
			vittes = time;
			
			App.self.setOnEnterFrame(flying);
		}
		
		private var path_L:int = 8;
		
		private var _altitude:int = 0;
		private var dAlt:uint = 2;
		private var counter:int;
		private var count:int = 1;
		private var _fps:uint = 31;
		private var flyRound:int = 0;
		private function flying(e:Event = null):void
		{		
			var name:String = 'fly';
			if (start.y < finish.y)
			{
				framesDirection = FACE;
			}
			else
			{
				framesDirection = BACK;
				name = 'fly_back';
			}
			
			if (start.x < finish.x)
			{
				if (framesFlip != RIGHT)
				{
					frame = 0;
					if (animationContainer.scaleX > 0)
					{
						animationContainer.scaleX = -1;
					}
				}
				framesFlip = RIGHT;
			}
			else
			{
				if (framesFlip != LEFT)
				{
					frame = 0;
					if (animationContainer.scaleX < 0)
					{
						animationContainer.scaleX = 1;
					}
				}
				framesFlip = LEFT;
			}
			if (_name)
				multipleAnime[_name].bitmap.visible = false;
			_name = name;
			multipleAnime[_name].bitmap.visible = true;
			
			t += vittes * (32 / (_fps));
			
			if (t >= 1)
			{
				_fps = (App.self.fps)?App.self.fps:31;
				t = 0;
				count++;
				if (count > path_L) {
					if (_flyReturn) {
						_flyReturn = false;
						_altitude = 0;
						amplitude = 0;
						
						path_L = numPositions;
						currentPath = poss;
						count = 2;
						startFly(count);
						return;
					}
					
					if (_flyAway) {
						_flyAway = false;
						App.self.setOffEnterFrame(flying);
						TweenLite.to(this.animationContainer, 0.5, { alpha:0 } );
						_flying = false;
						return;
					}
					
					if (_flyHome) {
						count = 1;
						_altitude = 0;
						amplitude = 0;
						_flyHome = false;
						
						path_L = numPositions;
						currentPath = poss;
						
						App.self.setOffEnterFrame(flying);
						
						this.addChild(animationContainer);
						
						animationContainer.x = 0;
						animationContainer.y = 0;
						
						tweenBirdDown();
						
						multipleAnime[_name].bitmap.visible = false;
						_name = 'take_off';
						multipleAnime[_name].bitmap.visible = true;
						
						_flying = false;
						return;
					}
					flyRound++;
					count = 2;
				}
				App.self.setOffEnterFrame(flying);
				if (flyRound >= 1) {
					flyRound = 0;
					//count = 0;
					
					//_altitude = 0;
					//amplitude = 0;
					//this.addChild(animationContainer);
					if (flyHome) {		
						possHome[1] = poss[2];
						currentPath = possHome;
						path_L = 1;
						count = 1;
						
						_flyHome = true;
						startFly(count);
						//flyToHome();
					}
					else {
						possAway[1] = poss[2];						
						currentPath = possAway;
						path_L = numAwayPositions;
						count = 1;
						
						_flyAway = true;
						startFly(count);
						//flyAway();
					}
					return;
				} else {
					startFly(count);
				}
				
			}
			
			var nextX:Number = int(start.x + (finish.x - start.x) * t);
			var nextY:Number = int(start.y + (finish.y - start.y) * t);
				
			animationContainer.x = nextX;
			animationContainer.y = nextY;
			
			if (_altitude < altitude)
				_altitude += dAlt;
			
			ay = (amplitude * Math.sin(0.01 * x)) - _altitude;
		}
		
		override public function startAnimation(random:Boolean = false):void
		{
			if (animated) return;
			
			for each(var name:String in framesTypes) {
				
				multipleAnime[name]['length'] = textures.animation.animations[name].chain.length;
				multipleAnime[name].bitmap.visible = true;
				multipleAnime[name]['frame'] = 0;
				if (random) {
					multipleAnime[name]['frame'] = int(Math.random() * multipleAnime[name].length);
				}
			}
			
			setRest();
			
			App.self.setOnEnterFrame(animate);
			animated = true;
		}
		
		override public function showIcon():void
		{
			if (!formed || !open)
				return;
			
			if (App.user.mode == User.OWNER)
			{
				if (hasProduct)
				{
					drawIcon(UnitIcon.REWARD, 2, 1, {glow: true});
				}
				else
				{
					clearIcon();
				}
			}
		}
		
		override public function uninstall():void {
			this.addChild(animationContainer);
			App.self.setOffEnterFrame(flying);
			super.uninstall();
		}
	
	}

}