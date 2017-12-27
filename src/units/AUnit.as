package units
{
	import astar.AStarNodeVO;
	import core.IsoConvert;
	import core.Load;
	import core.WallPost;
	import flash.display.Bitmap;
	import flash.events.Event;
	import ui.SystemPanel;
	import units.Unit;
	import core.Numbers;
	/**
	 * ...
	 * @author 
	 */
	public class AUnit extends Unit 
	{
		public var framesType:String = "work";
		
		public var framesTypes:Array = [];
		public var multipleAnime:Object = {};
		
		protected var frame:uint = 0;
		protected var frameLength:uint = 0;
		
		private var chain:Object;
		
		public var ax:int = 0;
		public var ay:int = 0;
		
		protected var _cloudY:Number = 0;
		protected var _cloudX:Number = 0;
		
		public var _flag:* = false;
		protected var needCadr:Boolean = false;
		protected var forceClear:Boolean = false;
		
		public function AUnit(object:Object)
		{
			super(object);
			
			if (object.hasOwnProperty('hasLoader'))
				hasLoader = object.hasLoader;
			
			if	(hasLoader) {
				loader = new UnitPreloader(click);
				addChild(loader);
			}
			
			addEventListener(Event.REMOVED_FROM_STAGE, onRemoveFromStage);
		}
		
		override public function calcState(node:AStarNodeVO):int
		{
			if (App.self.constructMode) return EMPTY;
			if (info.base != null && info.base == 1) 
			{
				for (var i:uint = 0; i < cells; i++) {
					for (var j:uint = 0; j < rows; j++) {
						node = App.map._aStarNodes[coords.x + i][coords.z + j];
						//if (node.b != 0 || node.open == false) {
						if (node.w != 1 || node.object != null || node.open == false) { // 
							return OCCUPIED;
						}
					}
				}
				return EMPTY;
			}
			else
			{
				return super.calcState(node);
			}
		}
		
		public function onRemoveFromStage(e:Event):void {
			if (animated) {
				stopAnimation();
			}
			removeEventListener(Event.REMOVED_FROM_STAGE, onRemoveFromStage);
		}
		
		public function onLoad(data:*):void {
			if (loader) removeChild(loader);
			loader = null;
			if (User.inExpedition && !open)
				visible = false;
			if (App.self.constructMode) visible = true;
			textures = data;
		}
		
		
		public function initAnimation():void {
			if (!SystemPanel.animate)
			{
				forceClear = true;
				checkAndDrawFirstFrame();
			}
			
			framesTypes = [];
			if (textures && textures.hasOwnProperty('animation')) {
				for (var frameType:String in textures.animation.animations) {
					framesTypes.push(frameType);
				}
				addAnimation();
				
				if (framesTypes.length > 0)
					animate();
			}
		}
		
		public function addAnimation():void
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
		}
		
		protected function checkAndDrawFirstFrame():void
		{
			if (!SystemPanel.animate && framesTypes.length > 0)
			{
				animate(null, true);
				forceClear = true;
			}
				
			//animationBitmap == null;
		}
		
		private var _visibleAnimation:Boolean = false;
			
		public function get visibleAnimation():Boolean 
		{
			return _visibleAnimation;
		}
		
		public function set visibleAnimation(value:Boolean):void 
		{	
			for (var name:String in multipleAnime) {
				multipleAnime[name].bitmap.visible = value;
			}
			
			_visibleAnimation = value;
		}
		
		
		public function startAnimation(random:Boolean = false):void
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
			
			App.self.setOnEnterFrame(animate);
			animated = true;
		}
		
		public function stopAnimation():void
		{
			App.self.setOffEnterFrame(animate);
			animated = false;
		}
		
		public function clearAnimation():void {
			stopAnimation();
			if (!SystemPanel.animate && !forceClear) return;
			forceClear = false;
			for (var _name:String in multipleAnime) {
				var btm:Bitmap = multipleAnime[_name].bitmap;
				if (btm && btm.parent)
					btm.parent.removeChild(btm);
			}
		}
		
		override public function animate(e:Event = null, forceAnimate:Boolean = false):void 
		{
			if (!SystemPanel.animate && !(this is Lantern) && !forceAnimate) return;
			
			for each(var name:String in framesTypes) {
				var frame:* 			= multipleAnime[name].frame;
				var cadr:uint 			= textures.animation.animations[name].chain[frame];
				if (multipleAnime[name].cadr != cadr) {
					multipleAnime[name].cadr = cadr;
					var frameObject:Object 	= textures.animation.animations[name].frames[cadr];
					
					multipleAnime[name].bitmap.bitmapData = frameObject.bmd;
					multipleAnime[name].bitmap.smoothing = true;
					multipleAnime[name].bitmap.x = frameObject.ox+ax;
					multipleAnime[name].bitmap.y = frameObject.oy+ay;
				}
				multipleAnime[name].frame++;
				if (multipleAnime[name].frame >= multipleAnime[name].length)
				{
					multipleAnime[name].frame = 0;
				}
			}
		}
		
		
		protected function drawFirstCadr():void
		{
			if (!SystemPanel.animate && !(this is Lantern) && needCadr && Numbers.countProps(textures.animation.animations) > 0)
			{	
				animate();
				needCadr = false;
			}
		}
		
		public function setCloudPosition(dX:Number, dY:Number):void
		{
			_cloudY = dY;
			_cloudX = dX;
		}
		
		public var smoke_animated:Boolean = false;
		public var smokeAnimations:Array = [];
		public function startSmoke():void {
			smoke_animated = true;
			if (smokeAnimations.length > 0) {
				for each(var anime:Anime2 in smokeAnimations) {
					anime.startAnimation();
					anime.alpha = 1;
					addChild(anime);
				}
			}else{
				if (textures.hasOwnProperty('smokePoints')) {
					
					Load.loading(Config.getSwf('Smoke', 'smoke'), function(data:*):void {
						var animation:Object = data;
						
						
						for each(var point:Object in textures.smokePoints) {
							var anime:Anime2 = new Anime2(animation, 'smoke', point.dx, point.dy, point.scale || 1);
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
		
		public function makePost(e:* = null):void
		{
			if (App.user.quests.tutorial)
				return;
			
			//WallPost.makePost(WallPost.LEVEL, { callBack:function(...args):void {} } );
		}
	}
	
}