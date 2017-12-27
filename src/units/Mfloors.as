package units
{
	import com.greensock.TweenLite;
	import core.Numbers;
	import core.Post;
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import ui.SystemPanel;
	import ui.UnitIcon;
	import ui.Cursor;
	import wins.ConstructWindow;
	import wins.ShareGuestWindow;
	import wins.SimpleWindow;
	import wins.TowerWindow;
	import wins.TowerWindowTwo;

	public class Mfloors extends Share
	{
		public var kicksLimit:int = 0;
		public var floor:int = 0;
		public var totalFloors:int = 0;
		
		public static const ONE_SIDE_KICK:int = 0;
		public static const TWO_SIDE_KICK:int = 1;		
		public static const BURST_ALWAYS:int = 0;
		public static const BURST_ONLY_ON_COMPLETE:int = 1;
		public static const BURST_NEVER:int = 2;
		
		public static const HORN_SMALL:int = 1650;
		public static const HORN_BIG:int = 1651;
		public static const LOVE_TREE:int = 2095;
		public static const LOVE_TREE_BIG:int = 2094;
		 
		public function Mfloors(settings:Object)
		{
			gloweble = false;
			floor = settings.floor || 0;		
			
			if (settings.hasOwnProperty('level') && settings['level'] == 0) 
			{
				settings['level'] = App.data.storage[settings.sid].start;	
			}
			
			super(settings);
			level = settings.level;
			
			totalFloors = Numbers.countProps(info.tower);
						
			craftLevels = totalLevels;
			
			kicksLimit = info.tower[totalFloors].c;
			
			if (floor == -1) {
				changeOnDecor();
				removable = true;
				return;
			}else {
				removable = false;
			}
			
			if (formed && textures) {		
				if (needAnimation) {
					visibleAnimation = false;
					initAnimation();
					beginAnimation();
					checkAndDrawFirstFrame();
				}
			}
			
			//clickable = true;
			showIcon();
			
			if (floor > totalFloors && App.user.mode == User.GUEST) {
				clearIcon();
			}
			
			if (floor <= totalFloors && level >= totalLevels && App.user.mode == User.GUEST) {
				startGlowing();
			}
		}
		
		override public function click():Boolean 
		{
			if (App.user.mode == User.GUEST && level < totalLevels) 
			{
				new SimpleWindow( {
					title:title,
					label:SimpleWindow.ATTENTION,
					text:Locale.__e('flash:1409298573436')
				}).show();
				return true;
			}
			
			if (!clickable || id == 0) return false;
			if (floor > totalFloors) return true;			
			if (!isReadyToWork()) return true;
			
			if (App.user.mode == User.OWNER)
			{
				if (isPresent()) return true;
			}
			
			if (level < totalLevels) 
			{
				if (App.user.mode == User.OWNER)
				{					
					new ConstructWindow( {
						title			:info.title,
						upgTime			:info.devel.req[level + 1].t,
						request			:info.devel.obj[level + 1],
						target			:this,
						onUpgrade		:upgradeEvent,
						hasDescription	:true
					}).show();
				}
			}
			else
			{
				if (App.user.mode == User.OWNER)
				{
					//if (info.sID == HORN_SMALL || info.sID == LOVE_TREE) {
						new TowerWindowTwo({
							target:this,
							storageEvent:storageAction,
							upgradeEvent:growEvent,
							buyKicks:buyKicks,
							mKickEvent:mKickEvent,
							fontOffset:6
						}).show();
					//}
					/*if (info.sID == HORN_BIG || info.sID == LOVE_TREE_BIG) {
						new TowerWindowTwo({
							target:this,
							storageEvent:storageAction,
							upgradeEvent:growEvent,
							buyKicks:buyKicks,
							mKickEvent:mKickEvent,
							itemsNum:4
						}).show();
					}*/					
				}
				else
				{
					if (hasPresent)
					{
						new SimpleWindow( {
							title:title,
							label:SimpleWindow.ATTENTION,
							text:Locale.__e('flash:1409297890960')
						}).show();
						return true;
					}
					
					if (info.tower[floor + 1] == undefined) 
					{
						var text:String = Locale.__e('flash:1382952379909',[info.title]);
						var title:String = Locale.__e('flash:1382952379908');
						if (info.burst == BURST_NEVER) 
						{
							text = Locale.__e('flash:1384786087977', [info.title]);
							title = Locale.__e('flash:1384786294369');
						}
						// Больше стучать нельзя
						new SimpleWindow( {
							title:title,
							label:SimpleWindow.ATTENTION,
							text:text
						}).show();
						return true;
					}
					
					if (kicks >= info.tower[floor+1].c)
					{
						// Больше стучать нельзя
						new SimpleWindow( {
							label:SimpleWindow.ATTENTION,
							title:Locale.__e('flash:1382952379908'),
							text:Locale.__e('flash:1382952379910',[info.title])
						}).show();
					}
					else
					{
						new ShareGuestWindow({
							target:this,
							kickEvent:kickEvent,
							itemsNum:2
						}).show();
					}
				}
			}
			
			return true;
		}
		
		public function growEvent(params:Object):void 
		{
			gloweble = true;
			var self:Mfloors = this;
			//flag = false;
			
			Post.send( {
				ctr:this.type,
				act:'grow',
				uID:App.user.id,
				id:this.id,
				wID:App.user.worldID,
				sID:this.sid
			},function(error:int, data:Object, params:Object):void {
				if (error) 
				{
					Errors.show(error, data);
					return;
				}
				guests = { };
				floor = data.floor;
				updateLevel(true);
				
				if (data.hasOwnProperty('bonus'))
				{
					Treasures.bonus(data.bonus, new Point(self.x, self.y));
				}
			});
		}
		
		override public function updateLevel(checkRotate:Boolean = false, mode:int = -1):void 
		{/*			
			if (!textures) return;
			var levelData:Object
			if(this.floor == 0)
				levelData = textures.sprites[this.level];
			else
				levelData = textures.sprites[this.floor + this.level];*/				
			
			if (!textures) return;
			
			visibleAnimation = false;
			var levelData:Object;
			var smaller:int = 0;
			if (floor < 0) {
				totalFloors = Numbers.countProps(info.tower);
				floor = totalFloors + 1;
			}
			while (!textures.sprites[level + floor + smaller]) smaller--;
			levelData = textures.sprites[level + floor + smaller];
			
			if (checkRotate && rotate == true) 
			{
				flip();
			}
			
			if (this.level != 0 && gloweble)
			{
				var backBitmap:Bitmap = new Bitmap(bitmap.bitmapData);
				backBitmap.x = bitmap.x;
				backBitmap.y = bitmap.y;
				addChildAt(backBitmap, 0);				
				bitmap.alpha = 0;
				
				App.ui.flashGlowing(this);
				
				TweenLite.to(bitmap, 0.4, { alpha:1, onComplete:function():void 
				{
					removeChild(backBitmap);
					backBitmap = null;
				}});
				
				gloweble = false;
			}
			
			draw(levelData.bmp, levelData.dx, levelData.dy);
			
			if (needAnimation) {
				visibleAnimation = false;
				initAnimation();
				beginAnimation();
				checkAndDrawFirstFrame();
			}
		}
		
		private function get needAnimation():Boolean {
			if (floor == -1 || ((level + floor) >= (totalLevels + totalFloors) && animationBitmap == null && totalFloors != 0))
				return true;
			
			// Поиск в имени анимации уровня на котором она проигрывается
			if (textures && textures.animation) {
				for (var animation:String in textures.animation.animations) {
					if (animation.search(/[0-9]/) == 5 && int(animation.charAt(5)) == floor + level - 1)
						return true;
				}
			}
			
			return false;
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
		
		override public function get bmp():Bitmap {
			if (animationContainer) {
				for (var i:int = 0; i < animationContainer.numChildren; i++) {
					var child:* = animationContainer.getChildAt(i);
					if (child is Bitmap && child.bitmapData && child.bitmapData.getPixel(child.mouseX, child.mouseY) != 0)
						return child as Bitmap;
				}
			}
			
			if (bitmap.bitmapData && bitmap.bitmapData.getPixel(bitmap.mouseX, bitmap.mouseY) != 0)
				return bitmap;
			
			return null;
		}
		
		override public function set state(state:uint):void {
			if (_state == state) return;
				
			switch(state) {
				case OCCUPIED: this.filters = [new GlowFilter(0xFF0000,1, 6,6,7)]; break;
				case EMPTY: this.filters = [new GlowFilter(0x00FF00,1, 6,6,7)]; break;
				case TOCHED: this.filters = [new GlowFilter(0xFFFF00,1, 6,6,7)]; break;
				case HIGHLIGHTED: this.filters = [new GlowFilter(0x88ffed,0.6, 6,6,7)]; break;
				case IDENTIFIED: this.filters = [new GlowFilter(0x88ffed,1, 8,8,10)]; break;
				case DEFAULT: this.filters = []; break;
			}
			_state = state;
		}
		
		public function buyKicks(params:Object):void {
			
			var callback:Function = params.callback;
			
			Post.send( {
				ctr:this.type,
				act:'boost',
				uID:App.user.id,
				id:this.id,
				wID:App.user.worldID,
				sID:this.sid
			},function(error:int, data:Object, params:Object):void {
				if (error) 
				{
					Errors.show(error, data);
					return;
				}
				
				if (data.hasOwnProperty(Stock.FANT))
				{					
					App.user.stock.put(Stock.FANT, data[Stock.FANT]);
				}
				
				kicks = data.kicks;
				//flag = Cloud.TRIBUTE;
				callback();
			});
		}
		
		override public function onLoad(data:*):void
		{
			if (data.hasOwnProperty('animation'))
			{
				for (var type:* in data.animation.animations)
				{
					if (data.animation.animations[type].hasOwnProperty('pause')) 
					{
						var length:int = int(data.animation.animations[type].pause * Math.random());
						var chain:Array = data.animation.animations[type].chain;
						//var lastFrame:int = chain.pop();
						for (var i:int = 0; i < length; i++) 
						{
							chain.push(0);
						}
					}
				}
			}	
			
			super.onLoad(data);
			touchableInGuest = true;
			
			if (App.user.mode == User.GUEST) {
				touchableInGuest = true;
				//flag = false;
				if(level == totalLevels){
					if (info.tower[floor + 1] != undefined) {
						//flag = Cloud.HAND;
						if (kicks < info.tower[floor + 1].c){
							//flag = Cloud.PICK;
						}
					}	
				}
			}
			else
			{
				//flag = Cloud.TRIBUTE;
				if (floor > totalFloors || floor < 0)
				{					
					//flag = false;
				}
				
				if (info.tower[floor + 1] != undefined)
				{
					if (kicks < info.tower[floor + 1].c)
					{
						//flag = false;
					}
				}
				else {
					if (level == totalLevels)
					{
						if (info.tower[floor + 1] != undefined) 
						{
							//flag = false;
							if (kicks < info.tower[floor + 1].c)
							{
								//flag = Cloud.TRIBUTE;
							}
						}	
					}
				}
				
				if (hasPresent) 
				{
					//setFlag("hand", isPresent, { target:this, roundBg:false, addGlow:false } );
				}
			}
		}		
		
		override public function storageAction(boost:uint, callback:Function):void {
			
			var self:Share = this;
			var sendObject:Object = {
				ctr:this.type,
				act:'storage',
				uID:App.user.id,
				wID:App.user.worldID,
				sID:this.sid,
				id:this.id
			}
			
			Post.send(sendObject,
			function(error:int, data:Object, params:Object):void 
			{				
				if (error) 
				{
					Errors.show(error, data);
					return;
				}
				
				callback(Stock.FANT, boost);
				
				if (data.hasOwnProperty(Stock.FANT))
					App.user.stock.data[Stock.FANT] = data[Stock.FANT];
				
				if (data.hasOwnProperty('bonus'))
				{					
					Treasures.packageBonus(data.bonus, new Point(self.x, self.y));
				}
				
				if (info.burst == BURST_ONLY_ON_COMPLETE)
				{
					if (floor == totalFloors)
						removable = true;
						
					free();
					changeOnDecor();
					take();
					
				}else{
					uninstall();
				}
				
				self = null;
			});
		}
		
		private function changeOnDecor():void 
		{
			visibleAnimation = false;
			floor = totalFloors + 1;
			if (textures) {
				var smaller:int = 0;
				while (!textures.sprites[level + floor + smaller]) smaller--;
				var levelData:Object = textures.sprites[level + floor + smaller];
				draw(levelData.bmp, levelData.dx, levelData.dy);
			}
			
			initAnimation();
			beginAnimation();
			
			showIcon();
		}
		
		override public function initAnimation():void 
		{
			//visibleAnimation = false;
			super.initAnimation();
		}
		
		override public function startAnimation(random:Boolean = false):void 
		{
			if (animated) return;
			
			for each(var name:String in framesTypes) {
				
				multipleAnime[name]['length'] = textures.animation.animations[name].chain.length;
				multipleAnime[name].bitmap.visible = true;
				if (int(name.substring(5, 6)) == floor + level - 1 && name.length <= 6) {
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
		
		public var multianimUnits:Array = [3006];
		override public function animate(e:Event = null, forceAnimate:Boolean = false):void 
		{
			if (multianimUnits.indexOf(sid) != -1) {
				if (!SystemPanel.animate && !forceAnimate) return;
				
				var frameObject:Object;
				var useAllPreviewAnimation:Boolean = Boolean(sid == 3006);
				var animSource:String = 'animations';
				
				for each(var name:String in framesTypes) {
					
					var frame:int = multipleAnime[name].frame;
					var cadr:int = textures.animation[animSource][name].chain[frame];
					
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
						if (!useAllPreviewAnimation && int(name.substring(5, 6)) == floor + level - 1 && name.length <= 6) {
							if (bitmap.visible == false)
								bitmap.visible = true;
						}else if (useAllPreviewAnimation && int(name.substring(5, 6)) <= floor + level - 1 && name.length <= 6) {
							if (bitmap.visible == false)
								bitmap.visible = true;
						}else {
							if (bitmap.visible == true)
								bitmap.visible = false;
						}
					}
					multipleAnime[name].frame++;
				}	
			}else {
				super.animate();
			}
		}
		
		override public function refresh():void 
		{
			//touchableInGuest = false;
		}
		
		override public function setCraftLevels():void
		{
			craftLevels = totalLevels;
			//craftLevels = totalFloors;
		}
		
		override public function set touch(touch:Boolean):void 
		{
			if (floor > totalFloors)
			{
				if (Cursor.type == 'default') {
					return;
				}
			}
			super.touch = touch;
		}
		
		override public function remove(_callback:Function = null):void {
			if ([1658,2201,2641,2642].indexOf(int(sid)) != -1) {
				var data:int = int(App.user.storageRead('building_' + sid, 0));
				data -= 1;
				App.user.storageStore('building_' + sid, data, true);
			}
			super.remove(_callback);
		}
		
		override public function showIcon():void {
			if (!formed || !open) return;
			
			if (sid == 533) {
				clearIcon();
				return;
			}
			
			if (App.user.mode == User.OWNER) {				
				if (crafted > 0 && crafted <= App.time && hasProduct && formula) {
					drawIcon(UnitIcon.REWARD, formula.out, 1, {
						glow:		true
					});
				}else if (crafted > 0 && crafted >= App.time && formula) {
					drawIcon(UnitIcon.PRODUCTION, formula.out, 1, {
						progressBegin:	crafted - formula.time,
						progressEnd:	crafted
					});
				}else if (hasPresent) {
					drawIcon(UnitIcon.REWARD, 2, 1, {
						glow:		true
					});
				}else if (hasBuilded && upgradedTime > 0 && upgradedTime > App.time && level < totalLevels) {
					drawIcon(UnitIcon.BUILDING, null, 0, {
						clickable:		false,
						boostPrice:		info.devel.skip[level + 1],
						progressBegin:	upgradedTime - info.devel.req[level + 1].t,
						progressEnd:	upgradedTime,
						onBoost:		function():void {
							acselereatEvent(info.devel.skip[level + 1]);
						}
					});
				}else if ((craftLevels == 0 && level < totalLevels) || (craftLevels > 0 && level < totalLevels - craftLevels + 1)) {
					drawIcon(UnitIcon.BUILD, null);
				}else {
					clearIcon();
				}
			}else if (App.user.mode == User.GUEST) {
				if (info.type == 'Mfloors')
				{
					if (level >= totalLevels && (floor < totalFloors && floor != -1)) {
						drawIcon(UnitIcon.HAND_STATE, UnitIcon.HAND, 1, {
							glow:		false
						});
					} else {
						clearIcon();
					}
				} else
				{
					drawIcon(UnitIcon.REWARD, 2, 1, {
						glow:		false
					});
				}
			}
		}
		
		/*override public function putAction():void 
		{
			if (level < totalLevels || floor <= totalFloors) return;
			super.putAction();
		}

		override public function set touch(touch:Boolean):void 
		{
			if (floor <= totalFloors && Cursor.type == 'stock') {
				return;
			}
			if (floor > totalFloors && Cursor.type == 'default') {
				return;
			}   
			super.touch = touch;
		}*/
	}
}