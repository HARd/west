package units
{
	import adobe.utils.CustomActions;
	import flash.display.Bitmap;
	import flash.geom.Point;
	import units.Building;
	import units.BuyPetsFoodWindow;
	import units.Companion;
	import wins.CbuildingWindow;
	import wins.CfloorsGuestWindow;
	import wins.CfloorsWindow;
	import wins.ConstructWindow;
	import wins.InfoWindow;
	import wins.ProductionWindow;
	import wins.ShareGuestWindow;
	import wins.ShareWindow;
	import wins.SimpleWindow;
	import core.Post;
	import flash.events.Event;
	import ui.SystemPanel;
	import flash.filters.GlowFilter;
	import core.Load;
	import ui.Hints;
	
	public class PetHouse extends Building 
	{	
		static private var _instance:PetHouse;
		private var feed:int = 0;
		public var posX:int = 0;
		public var posZ:int = 0;
		
		public static function get Instance():PetHouse
		{
			return _instance;
		}
		
		public function PetHouse(settings:Object) 
		{	
			posX = settings.x;
			posZ = settings.z;
			_instance = this;
			super(settings);
			
			touchableInGuest = false;
			transable = true;
			//removable = false;
			
			
			feed = settings.feed;
			this.type = 'Pethouse';
			
			if (level == 3)
			{
				spawnPet();
			}
		}
		
		override public function updateLevel(checkRotate:Boolean = false, mode:int = -1):void 
		{
			super.updateLevel(checkRotate, mode);
		}
		
		private function get needAnimation():Boolean {
			if (level >= 0 && ((level) > (totalLevels) && animationBitmap == null))
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
			
			App.self.setOnEnterFrame(animate);
			animated = true;
		}
		public var multianimUnits:Array = [3025];
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
						if (!useAllPreviewAnimation && name.length > 5 && int(name.substring(5, 6)) == level) {
							if (bitmap.visible == false)
								bitmap.visible = true;
						}else if (useAllPreviewAnimation && name.length > 5 && int(name.substring(5, 6)) <= level) {
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
		
		override public function load():void 
		{
			// Прервать загрузку если является не основным компонентом
			var components:Object = Storage.componentsGet(App.map.id, sid);
			if (components.hasOwnProperty(id) && components[id] == 0) return;
			
			
			if (textures) {
				stopAnimation();
				textures = null;
			}
			
			var view:String = info.view;
			if (info.hasOwnProperty('start') && level == 0) {
				level = info.start;
			}
			
			if (info.hasOwnProperty('devel') && info.devel.hasOwnProperty('req')) {
				var viewLevel:int = level;
				while (true) {
					if (info.devel.req.hasOwnProperty(viewLevel) && info.devel.req[viewLevel].hasOwnProperty('v') && String(info.devel.req[viewLevel].v).length > 0) {
						if (info.devel.req[viewLevel].v == '0') {
							if (viewLevel > 0) {
								viewLevel --;
							}else {
								break;
							}
						} else {
							view = info.devel.req[viewLevel].v;
							break;
						}
					}else if (viewLevel > 0) {
						viewLevel --;
					}else {
						break;
					}
				}
			}
			Load.loading(Config.getSwf("PetHouse", view), onLoad);
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
			
			visibleAnimation = false;
			if (needAnimation) {
				initAnimation();
				beginAnimation();
			}
		}
		
		override public function initAnimation():void 
		{
			if (textures && textures.hasOwnProperty('animation')) {
				for (var frameType:String in textures.animation.animations) {
					framesTypes.push(frameType);
				}
				addAnimation();
				animate();
			}
		}
		
		override public function onRemoveAction(error:int, data:Object, params:Object):void 
		{	
			if (App.user.pet)
				App.user.pet.uninstall();
			
			super.onRemoveAction(error, data, params);
		}
		
		override public function click():Boolean 
		{
			if (App.user.mode == User.GUEST)
				return false;
				
			if (level < totalLevels)
			{
				this.openConstructWindow();
				return false;
			}
			else
			{
				this.openProductionWindow();
				return true;
			}
		}

		public function goHome():void
		{
			App.user.pet.initMove(posX, posZ);
		}
		
		public function spawnPet():void
		{
			if (level != 3 || App.user.pet || App.user.worldID != 2897 || App.user.mode == User.GUEST)
			{
				return;
			}
			App.user.pet = new Companion( { sid:3017, x:posX + 2, z:posZ} );
			App.user.pet.level = level;
			App.user.pet.totalLevels = totalLevels;
			App.user.pet.energy = feed;
			
			if (posX == 0 && posZ == 0)
			{
				posX = this.coords.x;
				posZ = this.coords.z;
			}
			
			
			App.user.pet.cell = posX + 2;
			App.user.pet.row = posZ + 2;
			
			App.user.pet.assignPetToUser();
			
			if (posX != 0 && posZ != 0)
			{
				visibleAnimation = true;
				animationContainer.visible = false;
			}
			
			for (var invader:String in _instance.info.invaders)
			{
				if (App.user.pet.minEnergy > int(_instance.info.invaders[invader]))
				{
					App.user.pet.minEnergy = int(_instance.info.invaders[invader]);
				}
			}
			
			if ((App.user.hero) && App.user.pet.minEnergy <= App.user.pet.energy )
				App.user.pet.placing(App.user.hero.cell, 0, App.user.hero.row);
				
			App.user.pet.energy = feed;
		}
		
		override public function openProductionWindow(settings:Object = null):void 
		{
			showFeedWindow();
		}
		
		override public function upgradeEvent(params:Object, fast:int = 0):void 
		{
			if (level  > totalLevels) {
				return;
			}
			
			var price:Object = { };
			for (var sID:* in params) {
				if (sID == Techno.TECHNO) {
					//needTechno = params[sID];
					//delete params[sID];
					continue;
				}
				price[sID] = params[sID];
			}
			
			// Забираем материалы со склада
			if (fast == 0) {
				if (!App.user.stock.takeAll(price)) return;
			}/*else {
				if (!App.user.stock.take(Stock.FANT,fast)) return;
			}*/
			
			gloweble = true;
			
			Post.send( {
				ctr:this.type,
				act:'upgrade',
				uID:App.user.id,
				id:this.id,
				wID:App.user.worldID,
				sID:this.sid,
				fast:fast
			},onUpgradeEvent, params);
		}
		
		override public function onUpgradeEvent(error:int, data:Object, params:Object):void 
		{
			super.onUpgradeEvent(error, data, params);
		}
		
		override public function upgraded():void 
		{
			super.upgraded();
			
			if (App.user.pet)
			{
				App.user.pet.level = level;
			}
			else
			{
				if (level == 3 )
					spawnPet();
			}
		}
		
		public function invaderClick(sid:int, callback:Function):Boolean
		{
			if (App.user.pet && (App.user.pet.energy < App.user.pet.minEnergy || App.user.pet.energy < invadersCost(sid)))
			{
				new InfoWindow({qID:'fox_invader', callback:showFeedWindow}).show();
				//showFeedWindow();
				return false;
			}
			
			if (App.user.pet && App.user.pet.level == 3)
			{
				
				if (ableToKillWithPet(sid))
				{
					takeEnergy(sid, callback);
					return true;
				}
			}
			
			if (level != 3)
			{
				openConstructWindow();
				return false;
			}
			
			return false;
		}
		
		public function ableToKillWithPet(sid:*):Boolean
		{
			if (!App.user.pet || !App.user.hero)
				return false;
			//var pos:int = App.user.hero.cell - this.cell;
			//var pos2:int = App.user.hero.row - this.row;
					//
			//var len:int = Math.floor(Math.sqrt(pos * pos + pos2 * pos2));
			//pos = App.user.pet.cell - this.cell;
			//pos2 = App.user.pet.row - this.row;
			//var len2:int = Math.floor(Math.sqrt(pos * pos + pos2 * pos2));
			//var val:Boolean = (len <= killRadius && len2 <= killRadius && App.user.pet.energy <= PetHouse.invadersCost(sid));
			return App.user.pet.energy >= PetHouse.invadersCost(sid);
		}
		
		override public function openConstructWindow():Boolean 
		{
			if ((level < totalLevels) || (craftLevels > 0 && level < totalLevels))
			{
				if (App.user.mode == User.OWNER)
				{
					if (hasUpgraded)
					{
						if (!componentBuildable)
							return true;
						
						new ConstructWindow( {
							title:			info.title,
							upgTime:		info.devel.req[level + 1].t,
							request:		info.devel.obj[level + 1],
							reward:			null,
							target:			this,
							win:			this,
							onUpgrade:		upgradeEvent,
							hasDescription:	true
						}).show();
						
						return true;
					}
				}
			}
			return false;
		}
		
		public static function invadersCost(invadersSID:int):int
		{
			return int(_instance.info.invaders[invadersSID]);
		}
		
		public static function showFeedWindow():void
		{
			new BuyPetsFoodWindow( {
				itemsOnPage:4,
				content:BuyPetsFoodWindow.createContent('Energy', {out:2992} ),
				title:Locale.__e("flash:1478593486615"),
				fontBorderColor:0xd49848,
				shadowColor:0x553c2f,
				shadowSize:4,
				popup:true,
				hasDescription: true,
				description:Locale.__e('flash:1478593891481')
			}).show();
			
			//var onMap:Array = Map.findUnits(_instance.info.invaders);
		}
		
		public static function takeEnergy(invadersSID:int, callback:Function):void
		{
			if(!App.user.pet)
				return;
					
			var sendObject:Object = { };
			if (App.user) {
				sendObject = {
					id:_instance.id,
					ctr:Instance.type,
					act:'kill',
					invID:invadersSID,
					uID:App.user.id,
					sID:_instance.info.sid,
					wID:App.user.worldID,
					count:_instance.info.invaders[invadersSID]
				}
			}
			
			Post.send(sendObject,
			function(error:int, data:Object, params:Object):void 
			{
				if (error) {
					Errors.show(error, data);
					return;
				}
				
				App.user.pet.energy -= _instance.info.invaders[invadersSID];
				Hints.text("-"+ String(_instance.info.invaders[invadersSID]), Hints.ENERGY, new Point(App.self.mouseX, App.self.mouseY));
				
				//if (App.user.pet.energy < App.user.pet.minEnergy)
					//Instance.goHome();
				callback(error, data, params);
			});
		}
		
		public static function feedPet(sid:int, amount:int, callback:Function):void
		{
			if(!App.user.pet)
				return;
				
			var sendObject:Object = { };
			if (App.user) {
				sendObject = {
					act:"feed",
					ctr:_instance.type,
					sID:_instance.info.sid,
					mID:sid,
					id:_instance.id,
					uID:App.user.id,
					wID:App.user.worldID,
					energy:amount
				}
			}
			
			Post.send(sendObject,
			function(error:int, data:Object, params:Object):void 
			{
				if (error) {
					Errors.show(error, data);
					return;
				}
				
				App.user.stock.take(sid, amount);
				App.user.pet.energy += amount;
				
				callback();
				
				if (_instance.posX == 0 && _instance.posZ == 0)
				{
					_instance.visibleAnimation = true;
					_instance.animationContainer.visible = false;
				}
			});
		}
	}
}