package units 
{
	import com.greensock.TweenLite;
	import core.Post;
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.geom.Point;
	import ui.SystemPanel;
	import ui.UnitIcon;
	import wins.OpenZoneWindow;
	import wins.Window;
	public class Rbuilding extends Building 
	{
		private var req:Object = { };
		
		public var isNewYearBuilding:Boolean = false;
		
		public function Rbuilding(object:Object) 
		{
			this.req = object.req;
			
			isNewYearBuilding = NewYearManager.isNewYearBuilding(object.sid);
			if (isNewYearBuilding)
				object['layer'] = Map.LAYER_TREASURE;
			super(object);
			
			if (sid == 1798 || sid == 1800) {
				moveable = false;
				removable = false;
				rotateable = false;
				stockable = false;
			}
			
			totalLevels = 0;
			if (info.targets) {
				for each(var obj:* in info.targets.pool) {
					totalLevels++;
				}
			}
			
			if (isNewYearBuilding)
			{
				if (formed && textures) {		
					if (needAnimation) {
						visibleAnimation = false;
						initAnimation();
						beginAnimation();
						checkAndDrawFirstFrame();
					}
				}
				
				if (level >= totalLevels && App.user.mode == User.GUEST) {
					startGlowing();
				}
			}
			
			showIcon();
		}
		
		override public function updateLevel(checkRotate:Boolean = false, mode:int = -1):void 
		{
			super.updateLevel(checkRotate, mode);
			
			if (needAnimation) {
				visibleAnimation = false;
				initAnimation();
				beginAnimation();
				//checkAndDrawFirstFrame();
			}
		}
		
		private function get needAnimation():Boolean {
			if (((level) >= (totalLevels + 1) && animationBitmap == null && level!= 0))
				return true;
			
			// Поиск в имени анимации уровня на котором она проигрывается
			if (textures && textures.animation) {
				for (var animation:String in textures.animation.animations) {
					if (animation.search(/[0-9]/) == 5 && int(animation.charAt(5)) == level)
						return true;
				}
			}
			
			return false;
		}
		
		override protected function onBuyAction(error:int, data:Object, params:Object):void 
		{
			if (error) {
				Errors.show(error, data);
				return;
			}
			
			this.id = data.id;
			this.req = data.req;
			
			showIcon();
			
			open = true;
			
			if (data.req) {
				if(!isNewYearBuilding)
					openConstructWindow();
			}
		}
		
		override public function onBonusEvent(error:int, data:Object, params:Object):void 
		{
			if (error) {
				Errors.show(error, data);
				return;
			}
			
			removeEffect();
			showIcon();
			
			if (data.hasOwnProperty('req'))
				this.req = data.req;
			
			checkOnAnimationInit();
			
			if(info.hasOwnProperty('targets') && info.targets.hasOwnProperty('reward')) {
				Treasures.bonus(Treasures.convert(info.targets.reward[level]), new Point(this.x, this.y));
			}
		}
		
		override public function checkOnAnimationInit():void {			
			if (textures && textures['animation'] && level >= totalLevels) {
				initAnimation();
				startAnimation();
			}
			
			if (sid == 1800) {
				initAnimation();
				startAnimation();
			}
		}
		
		override public function openConstructWindow():Boolean 
		{
			if (level < totalLevels) {
				new OpenZoneWindow( {
					target:this,
					requires:	req,
					title:		info.title,
					description:(info.hasOwnProperty('devel') && info.devel.hasOwnProperty('info')) ? info.devel.info[level + 1] : '',
					onUpgrade:	upgradeRbuildingEvent,
					level:		level + 1,
					totalLevels:totalLevels
				}).show();
				return true;
			}
			
			return false;
		}
		
		public function upgradeRbuildingEvent():void {
			
			if (level  > totalLevels) {
				return;
			}
			
			var price:Object = getPriceForUpgrade();
			if (!App.user.stock.takeAll(price)) return;
			
			Window.closeAll();
			gloweble = true;

			Post.send( {
				ctr:this.type,
				act:'upgrade',
				uID:App.user.id,
				id:this.id,
				wID:App.user.worldID,
				sID:this.sid,
				fast:0
			},onUpgradeEvent);
		}
		
		private function getPriceForUpgrade():Object {
			var obj:Object = { };
			for each (var item:* in req) {
				for (var sID:* in item) {
					obj[sID] = item[sID];
				}
			}
			return obj;
		}
		
		private var clicked:Boolean = false;
		override public function openProductionWindow(settings:Object = null):void {
			if (clicked) return;
			clicked = true;
			var that:* = this;
			Post.send( {
				ctr:this.type,
				act: 'bonus',
				uID:App.user.id,
				id:this.id,
				wID:App.user.worldID,
				sID:this.sid
			}, function(error:int, data:Object, params:Object):void {
				if (error) {
					Errors.show(error, data);
					return;
				}
				
				if(data.hasOwnProperty('bonus')) {
					Treasures.bonus(data.bonus, new Point(that.x, that.y));
				}
				
				if (isNewYearBuilding)
				{
					NewYearManager.onTakeBonuse(that);
				}
				else
					TweenLite.to(that, 2, { alpha:0, onComplete:uninstall } );
			});
		}
		
		override public function uninstall():void {
			clicked = false;			
			super.uninstall();
		}
		
		override public function addAnimation():void {
			if (!textures.hasOwnProperty('animation')) return;
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
		
		private var moveDelay:int = 60;
		private var currentDelay:int = 0;
		public var _name:String;
		override public function animate(e:Event = null, forceAnimate:Boolean = false):void 
		{
			var frame:*;
			var cadr:uint;
			var frameObject:Object;
			
			if (isNewYearBuilding) {
				if (!SystemPanel.animate && !forceAnimate) return;
				
				var useAllPreviewAnimation:Boolean = true;
				var animSource:String = 'animations';
				
				for each(var name:String in framesTypes) {
					
					frame = multipleAnime[name].frame;
					cadr = textures.animation[animSource][name].chain[frame];
					
					if (multipleAnime[name].frame >= multipleAnime[name].length){
						multipleAnime[name].frame = 0;
					}
					if (multipleAnime[name].cadr != cadr) {
						multipleAnime[name].cadr = cadr;
						frameObject = textures.animation[animSource][name].frames[cadr];
						
						var bitmap:Bitmap = multipleAnime[name].bitmap;
						
						bitmap.bitmapData = frameObject.bmd;
						bitmap.smoothing = true;
						bitmap.x = frameObject.ox+ax;
						bitmap.y = frameObject.oy + ay;
						
						// Проверить уровень анимации
						if (!useAllPreviewAnimation && int(name.substring(5, 6)) == level && name.length <= 6) {
							if (level == totalLevels + 1)
							{
								if (int(name.substring(5, 6)) != level)
									bitmap.visible = false;
								else
									bitmap.visible = true;
							}
							else
							if (bitmap.visible == false)
								bitmap.visible = true;
						}else if (useAllPreviewAnimation && int(name.substring(5, 6)) <= level && name.length <= 6) {
							if (level == totalLevels + 1)
							{
								if (int(name.substring(5, 6)) != level)
									bitmap.visible = false;
								else
									bitmap.visible = true;
							}
							else
							if (bitmap.visible == false)
								bitmap.visible = true;
						}else {
							if (bitmap.visible == true)
								bitmap.visible = false;
						}
					}
					multipleAnime[name].frame++;
				}	
				
				if (level == totalLevels+1)
				{
					if (currentDelay >= moveDelay)
					{
						this.x -= 3;
						this.y += 2;
					}
					else
					{
						currentDelay++;
					}
				}
			}else {
				if (!SystemPanel.animate && !(this is Lantern) && !forceAnimate) return; sid
				if(_name == null) _name = framesTypes[0];
				//var name:String = _name;
				frame = multipleAnime[_name].frame;
				cadr = textures.animation.animations[_name].chain[frame];
				if (multipleAnime[_name].cadr != cadr) {
					multipleAnime[_name].cadr = cadr;
					frameObject = textures.animation.animations[_name].frames[cadr];
					
					multipleAnime[_name].bitmap.bitmapData = frameObject.bmd;
					multipleAnime[_name].bitmap.smoothing = true;
					multipleAnime[_name].bitmap.x = frameObject.ox+ax;
					multipleAnime[_name].bitmap.y = frameObject.oy + ay;
					multipleAnime[_name].bitmap.visible = true;
				}
				multipleAnime[_name].frame++;
				if (multipleAnime[_name].frame >= multipleAnime[_name].length)
				{
					onLoop();
				}
			}
		}
		
		public function onLoop():void {
			multipleAnime[_name].frame = 0;
			if (framesTypes.length > 1) setRest();
		}
		
		public function setRest():void {	
			if (isNewYearBuilding)
				return;
			var randomID:int = int(Math.random() * framesTypes.length);
			var randomRest:String = framesTypes[randomID];
			if (randomRest.indexOf('rest') == -1 && randomRest != 'stop_pause' && randomRest != 'anim') {
				setRest();
				return;
			}
			
			if (!_name) return;
			multipleAnime[_name].bitmap.visible = false;
			_name = randomRest;
			multipleAnime[_name].bitmap.visible = true;
		}
		
		override public function showIcon():void {
			if (!formed || !open) return;
			
			if (App.user.mode == User.GUEST && touchableInGuest) {
				drawIcon(UnitIcon.REWARD, 2, 1, {
					glow:		false
				}); 
			}
			
			if (App.user.mode == User.OWNER) {
				if (level >= totalLevels) {
					drawIcon(UnitIcon.REWARD, 2, 1, {
						glow:		true
					});
				}else {
					clearIcon();
				}
			}
		}
		
		override public function beginAnimation():void
		{
			startAnimation(false);
			
			if (info.view == 'cauldron') {
				if (level >= totalLevels)
				{					
					startSmoke();
				}
			}	
		}
		
		override public function startAnimation(random:Boolean = false):void 
		{
			if (animated) return;
			
			for each(var name:String in framesTypes) {
				
				multipleAnime[name]['length'] = textures.animation.animations[name].chain.length;
				multipleAnime[name].bitmap.visible = true;
				if (int(name.substring(5, 6)) == level && name.length <= 6) {
					multipleAnime[name].bitmap.visible = true;
				}else {
					multipleAnime[name].bitmap.visible = false;
				}
				multipleAnime[name]['frame'] = 0;
				if (random) {
					multipleAnime[name]['frame'] = int(Math.random() * multipleAnime[name].length);
				}
			}
			//visibleAnimation = false;
			App.self.setOnEnterFrame(animate);
			animated = true;
		}
		
	}

}