package units 
{
	import astar.AStarNodeVO;
	import com.greensock.easing.Linear;
	import com.greensock.TweenLite;
	import core.IsoTile;
	import core.Load;
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.filters.GlowFilter;
	import ui.UnitIcon;
	import ui.UserInterface;
	
	public class Personage extends WUnit
	{
		public static const E:int = 0;
		
		public var _flag:* = false;
		public var prevFlag:* = false;
		public var shadow:Bitmap;
		public var preloader:* = null;
		
		
		public static const BEAR:uint 			= 49;
		public static const BEAVER:uint 		= 622;
		public static const PANDA:uint 			= 390;
		public static const BOOSTER:uint 		= 431;
		public static const HERO:uint			= 8;
		public static const CONDUCTOR:uint		= 457;
		public static const TRAIN:uint			= 785;
		
		public static const REST:String 	= "rest";
		public static const WALK:String 	= "walk";
		public static const HARVEST:String 	= "harvest";
		public static const STOP:String 	= "stop_pause";
		public static const WORK:String 	= "work";
		public static const BUILD:String 	= "build";
		public static const PLANT:String 	= "work_plant";
		public static const GATHER:String 	= "work_gather";
		public static const MINE:String		= "work_mine";
		public static const CUT:String		= "work_cut";
		
		public var station:* = null;
		
		
		
		
		
		
		
		
		
		
		
		
		public function Personage(object:Object, view:String = '')
		{
			if (object.layer)
				layer = object.layer;
			else
				layer = Map.LAYER_SORT
			
			super(object);
			
			rotateable = false;
			transable = false;
			moveable = false;
			flyeble = true;
			removable = false;
			
			if (view !== '') {
				info.view = view;
			}
			
			if(UserInterface.textures.hasOwnProperty(info.view) && loaderCoords.hasOwnProperty(info.view)){
				preloader = new Bitmap(UserInterface.textures[info.view])
				preloader.x = loaderCoords[info.view].x;
				preloader.y = loaderCoords[info.view].y;
			}else {
				preloader = new Preloader();
			}
			
			load();
		}
		
		public function load():void
		{
			if (preloader) {
				addChild(preloader);
			}
			
			Load.loading(Config.getSwf(info.type, info.view), onLoad);
		}
		
		private var loaderCoords:Object = {
			'man':	{x:-15,y:-100},
			'woman': { x: -18, y: -100 }
		}
		
		public function onLoad(data:*):void 
		{
			textures = data;
			getRestAnimations();
			addAnimation();
			createShadow();
			
			if (preloader) {
				TweenLite.to(preloader, 0.5, { alpha:0, onComplete:removePreloader } );
			}
			if (!open && User.inExpedition)
				visible = false;
			if (sid == TRAIN) {
				//sort(App.map.mSort.numChildren - 2);
				framesSmoke = 'idle_smoke';
				startSmoke();
			}
			if (App.self.constructMode) visible = true;
		}
		
		public var framesSmoke:String;
		public var smoke_animated:Boolean = false;
		public var smokeAnimations:Array = [];
		public function startSmoke():void {
			smoke_animated = true;
			if (smokeAnimations.length > 0) {
				for each(var anime:Anime3 in smokeAnimations) {
					anime.startAnimation();
					anime.alpha = 1;
					addChild(anime);
				}
			}else{
				if (textures.hasOwnProperty('smokePoints')) {
					
					Load.loading(Config.getSwf('Smoke', 'smoke2'), function(data:*):void {
						var animation:Object = data;
						
						
						for each(var point:Object in textures.smokePoints) {
							anime = new Anime3(animation, 'smoke2', point.dx, point.dy, point.scale || 1);
							anime.framesType = framesSmoke;
							anime.startAnimation();
							anime.alpha = 1;
							addChild(anime);
							smokeAnimations.push(anime);
						}
						
						if (smoke_animated == false)
							stopSmoke();
					});
					
				}
			}
		}
		
		public function stopSmoke():void {
			smoke_animated = false;	
			if (smokeAnimations.length == 0) return;
			
			for each(var anime:Anime2 in smokeAnimations) {
				anime.stopAnimation();
				if(this.contains(anime)) removeChild(anime);
			}
		}
		
		private var treturn:Boolean = false;
		public function trainToGo(e:* = null):void {
			accel = 20;
			treturn = false;
			for each(var anime:Anime3 in smokeAnimations) {
				anime.framesType = 'move_smoke';
				anime.startAnimation();
				anime.alpha = 1;
				addChild(anime);
			}
			framesType = Personage.WALK;
			accel = 20;
			initMove(5, 84);
			
			App.self.setOnEnterFrame(hideTrain);
		}
		
		private function hideTrain(e:* = null):void {
			if (!path || treturn) {
				App.self.setOffEnterFrame(hideTrain);
			} else if (path.length - pathCounter == 12) {
				App.self.setOffEnterFrame(hideTrain);
				TweenLite.to(this, 2, { alpha:0} );
			}
		}
		
		public function trainReturn():void {
			accel = 32;
			treturn = true;
			for each(var anime:Anime3 in smokeAnimations) {
				anime.framesType = 'move_smoke';
				anime.startAnimation();
				anime.alpha = 1;
				addChild(anime);
			}
			framesType = Personage.WALK;
			placing(159, 0, 84);
			cell = 159;
			row = 84;
			TweenLite.to(this, 2, { alpha:1 } );
			initMove(142, 84, onTrainStop);
		}
		
		private function onTrainStop():void {
			for each(var anime:Anime3 in smokeAnimations) {
				anime.framesType = 'idle_smoke';
				anime.startAnimation();
				anime.alpha = 1;
				addChild(anime);
			}
			if (this.alpha < 1) {
				TweenLite.to(this, 1, { alpha:1 } );
			}
			framesType = Personage.STOP;
		}
		
		private var accel:Number = 20;
		override public function walk(e:Event = null):* {
			if (sid != Personage.TRAIN) {
				super.walk(e);
				return;
			}
			var k:Number = 0;
			
			if (start.x == finish.x) {
				k = IsoTile.spacing / Math.abs(start.y - finish.y);
			}else if (start.y == finish.y) {
				k = IsoTile.spacing / Math.abs(start.x - finish.x);
			}else {
				var d:Number = Math.sqrt(Math.pow((start.x - finish.x), 2) + Math.pow((start.y - finish.y), 2));
				k = IsoTile.spacing / d;
			}
			
			t += velocity * k * (accel / (App.self.fps || 32));
			if (!treturn && accel < 60) accel += 0.3;
			if (t >= 1)
			{
				var node:AStarNodeVO = path[pathCounter];
				this.cell = node.position.x;
				this.row = node.position.y;
				
				//trace('cell', cell);
				//trace('row', row);
				
				coords = { x:node.position.x, y:0, z:node.position.y };
				
				calcDepth();
				
				App.map.sorted.push(this);
					
				t = 0;
				x = finish.x;
				y = finish.y;
					
				pathCounter++;
				walking();
			}
			else
			{
				x = int((start.x + (finish.x - start.x) * t));
				y = int((start.y + (finish.y - start.y) * t));
			}
			return false;
		}
		
		public function removePreloader():void
		{
			if (preloader && preloader.parent)
				removeChild(preloader);
			
			preloader = null;
		}
		
		public function onPathToTargetComplete():void {}
		
		public function onStop():void {}
		
		public var defaultStopCount:uint = 5;
		private var stopCount:uint = defaultStopCount;
		public var restCount:uint = 0;
		override public function onLoop():void
		{	
			if (_framesType == STOP){
				stopCount--;
				if (stopCount <= 0){
					setRest();
				}
			}else if (rests.indexOf(_framesType) != -1) {
				restCount --;
				if (restCount <= 0){
					stopCount = generateStopCount();
					framesType = STOP;
				}
			}else {
				stopCount = defaultStopCount;
			}
		}
		
		public function setRest():void {
			if (App.user.quests.tutorial) {
				framesType = STOP;
				return;
			}
			
			var randomID:int = int(Math.random() * rests.length);
			var randomRest:String = rests[randomID];
			restCount = generateRestCount();
			framesType = randomRest;
			startSound(randomRest);
		}
		
		public function startSound(type:String):void {
			
		}
		
		public function generateStopCount():uint {
			return int(Math.random() * defaultStopCount) + defaultStopCount;
		}
		public function generateRestCount():uint {
			return 1;// int(Math.random() * )
		}
		
		public function createShadow():void {
			if (shadow) {
				removeChild(shadow);
				shadow = null;
			}
			
			if (textures && textures.animation.hasOwnProperty('shadow')) {
				shadow = new Bitmap(UserInterface.textures.shadow);
				addChildAt(shadow, 0);
				shadow.smoothing = true;
				shadow.alpha = textures.animation.shadow.alpha;
				shadow.scaleX = textures.animation.shadow.scaleX;
				shadow.scaleY = textures.animation.shadow.scaleY;
				shadow.x = textures.animation.shadow.x - (shadow.width / 2);
				shadow.y = textures.animation.shadow.y - (shadow.height / 2);
			}
		}
		
		override public function get bmp():Bitmap {
			if (bitmap.bitmapData && bitmap.bitmapData.getPixel(bitmap.mouseX, bitmap.mouseY) != 0)
				return bitmap;
			if (multiBitmap && multiBitmap.bitmapData && multiBitmap.bitmapData.getPixel(multiBitmap.mouseX, multiBitmap.mouseY) != 0)
				return multiBitmap;
				
			return bitmap;
		}
		
		override public function set state(state:uint):void {
			if (_state == state) return;
			
			switch(state) {
				case OCCUPIED: bitmap.filters = [new GlowFilter(0xFF0000,1, 6,6,7)]; break;
				case EMPTY: bitmap.filters = [new GlowFilter(0x00FF00,1, 6,6,7)]; break;
				case TOCHED: bitmap.filters = [new GlowFilter(0xFFFF00,1, 6,6,7)]; break;
				case HIGHLIGHTED: bitmap.filters = [new GlowFilter(0x88ffed,0.6, 6,6,7)]; break;
				case IDENTIFIED: bitmap.filters = [new GlowFilter(0x88ffed,1, 8,8,10)]; break;
				case DEFAULT: bitmap.filters = []; break;
			}
			_state = state;
		}
		
		override public function uninstall():void {
			if (tm != null) {
				tm.dispose();
			}
			
			stopWalking();
			super.uninstall();
		}
		
		public var rests:Array = [];
		public function getRestAnimations():void {
			for (var animType:String in textures.animation.animations)
				if (animType.indexOf('rest') != -1)
					rests.push(animType);
		}
		
		public function beginLive():void {
			
		}
		public function stopLive():void {
			
		}
		
		public function testHireAniamtion(worker:Personage, animationType:String = 'stop_pause'):String {
			if (worker.textures && worker.textures.animation.animations.hasOwnProperty(animationType)) {
				return animationType;
			}else {
				return Personage.STOP;
			}
		}
		
		public function rotateTo(target:*):void 
		{
			var side:int = WUnit.LEFT;
			if (this.x < target.x)
				side = WUnit.RIGHT;
			
			if (side == WUnit.RIGHT) {
				framesFlip = side;
				sign = -1;
				bitmap.scaleX = -1;
			}else{
				framesFlip = side;
				sign = 1;
				bitmap.scaleX = 1;
			}
			
			if (textures) update();
			//bitmap.x = (frameObject.ox + ax) * sign;
		}
		
		override public function click():Boolean {
			if (station /*&& station.crafted > 0 && station.crafted <= App.time*/) station.click();
			return true;
		}
		
		public function showTrainIcon():void {
			if (App.user.mode == User.OWNER) {
				if (station.level > 0 && station.info.type == 'Hut') {
					clearIcon();
					return;
				}
			}
			if (!station.formed || !station.open) return;
			for each (var pid:* in station.slots) {
				for (var slot:* in pid) {
					var formula:Object = App.data.crafting[slot];
						if (App.user.mode == User.OWNER) {				
							if (pid[slot] > 0 && pid[slot] <= App.time && station.hasProduct && formula) {
								drawIcon(UnitIcon.REWARD, formula.out, 1, {
									glow:		true
								});
							}
						}
					}
				}
		}
		
		override public function iconIndentCount():void {
			if (sid == 785) {
				if (!bounds) return;
				iconPosition.x = bounds.x + bounds.w / 2;
				iconPosition.y = bounds.y + bounds.h * 0.25;
			}else {
				super.iconIndentCount();
			}
		}
	}
}
