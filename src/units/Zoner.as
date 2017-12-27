package units 
{
	import api.ExternalApi;
	import astar.AStarNodeVO;
	import com.greensock.TweenLite;
	import core.Post;
	import core.TimeConverter;
	import core.WallPost;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	import ui.UnitIcon;
	import wins.OpenZoneWindow;
	import wins.SimpleWindow;
	import wins.SpeedWindow;
	import wins.Window;
	
	public class Zoner extends Personage 
	{
		
		public static const DEF:String = 'default';
		public static const PREPARE:String = 'prepare';
		public static const HOME_ZONE:int = 113;
		
		public var walkable:Boolean = false;
		public var gloweble:Boolean = true;
		
		public var upgrade:int		= 0;
		public var finished:int		= 0;
		public var level:int		= 0;
		public var totalLevels:int	= 0;
		public var zoneID:int		= 0;
		public var zoneAsset:*;
		private var relocateTimeout:int = 0;
		private var zonerType:String;
		
		public function Zoner(object:Object, view:String='') 
		{
			if ([280,773,1572,2114,2115,2116,2117].indexOf(int(object.sid)) != -1) {
				zonerType = 'bridge';
				if (object.sid != 773 && object.sid != 1572) object.z -= 1;
				object['layer'] = Map.LAYER_FIELD;
			}
			
			info = App.data.storage[object.sid];
			if (info) {
				for each(var rew:* in info.devel.rew) {
					for (var _sid:* in rew) {
						if (App.data.storage[_sid].type == 'Zones')
							zoneID = int(_sid);
					}
				}
			}
			
			if ([430].indexOf(int(object.sid)) != -1) zoneID = HOME_ZONE;
			
			if (info.devel) {
				for each(var obj:* in info.devel.req) {
					totalLevels++;
				}
			}
			
			super(object, view);
			
			if (object['level']) level = object.level;
			if (object['upgrade']) upgrade = object.upgrade;
			if (object['crafted']) finished = object.crafted;
			
			if (Config.admin)
				moveable = true;
			
			clickable = true;
			touchable = true;
			removable = false;
			stockable = false;
			
			if (zonerType != 'bridge')
				takeable = false;
			
			velocity = 0.04;
			
			tip = function():Object {
				
				var time:int;
				if (App.user.mode == User.GUEST || sid == 280) {
					return {
						title:	info.title,
						text:	info.description
					}
				}
				
				if (upgrade > App.time) {
					time = upgrade - App.time;
					if (time < 0) time = 0;
					
					return {
						title:	info.title,
						text:	Locale.__e('flash:1402905682294') + ':' + TimeConverter.timeToStr(time),
						timer:	true
					}
				}else if (upgrade > 0 && upgrade <= App.time && level == totalLevels) {
					
					return {
						title:	info.title,
						text:	Locale.__e('flash:1403170965448')
					}
				}else if (finished > 0 && finished > App.time && level == totalLevels) {
					time = finished - App.time;
					if (time < 0) time = 0;
					
					return {
						title:	info.title,
						text:	Locale.__e('flash:1382952379839', [TimeConverter.timeToStr(time)]),
						timer:	true
					}
				}else if (finished > 0 && finished <= App.time) {
					return {
						title:	info.title,
						text:	Locale.__e('flash:1393579618588')
					}
				}
				
				return {
					title:	info.title,
					text:	info.description
				}
			}
			
			if (textures)
			{
				if (textures.hasOwnProperty('animation')) {
					if (textures.animation.animations.hasOwnProperty('walk')) {
						walkable = true;
					}
					
					getRestAnimations();
					addAnimation();
					initAnimation();
				}
			}
			updateLevel();
			showIcon();
			//drawPreview();
			
			if (finished > 0) {
				App.self.setOnTimer(work);
			}
			
			if (level >= totalLevels && App.user.mode == User.OWNER) {
				refreshZone();
			}
		}
		
		private function refreshZone():void {
			var zones:Array = [];
			for each (var zone:* in App.user.world.zones) {
				zones.push(zone);
			}
			
			if (zones.indexOf(zoneID) == -1 && zoneID != 0) {
				Post.send( {
					ctr:this.type,
					act:'refresh',
					uID:App.user.id,
					id:this.id,
					wID:App.user.worldID,
					sID:this.sid
				}, function(error:int, data:Object, params:Object):void {
					if (error) {
						Errors.show(error, data);
						return;
					}
					
					for each (var zn:* in data.zones) {
						if (zones.indexOf(zn) == -1) {
							App.user.world.changeNodes(zn);
						}
					}
					//App.user.world.zones.splice(0,App.user.world.zones.length);
					for each(var zone:* in data.zones) {
						App.user.world.zones.push(zone);
					}
					App.map.fogManager.openZone();
				});
			}
		}
		
		override public function createShadow():void {}
		
		override public function onLoad(data:*):void {
			textures = data;
			
			if (textures.hasOwnProperty('animation')) {
				if (textures.animation.animations.hasOwnProperty('walk')) {
					walkable = true;
				}
				
				getRestAnimations();
				addAnimation();
				initAnimation();
			}
			
			updateLevel();
			showIcon();
			if (!open && User.inExpedition)
				visible = false;
			if (preloader) {
				TweenLite.to(preloader, 0.5, { alpha:0, onComplete:removePreloader } );
			}
			
			if (sid == 638) {
				if (App.user.hero) this.rotateTo({x:App.user.hero.x - 1});
			}
			if ((sid == 1095 || sid == 1125) && level >= totalLevels) {
				this.visible = false;
			}
		}
		
		public function initAnimation():void {
			if (!textures.hasOwnProperty('animation')) return;
			
			if (level < totalLevels) {
				if (textures.animation.animations.hasOwnProperty('level' + level)) {
					framesType = 'level' + level;
				}else {
					framesType = STOP;
				}
			}else {
				if (sid == 539) {
					if (textures.animation.animations.hasOwnProperty('level' + level)) {
						framesType = 'level' + level;
					}
				} else {
					startRest();
				}
			}
			
			if (multipleAnime) {
				startRest();
			}
		}
		
		override public function click():Boolean {
			var freezerID:int = 0;
			var freezerSID:int = 0;
			switch(sid) {
				case 2114:
					freezerID = 848;
					freezerSID = 2152;
					break;
				case 2115:
					freezerID = 819;
					freezerSID = 2153;
					break;
				case 2116:
					freezerID = 461;
					freezerSID = 2152;
					break;
				case 2117:
					freezerID = 233;
					freezerSID = 2154;
					break;
			}
			if (freezerID != 0) {
				var freezer:Freezer = Map.findUnit(freezerSID, freezerID);
				if (freezer) {
					App.map.focusedOn(freezer, true);
					return false;
				}
			}
			//var node:AStarNodeVO;
			//for (var i:uint = 0; i < cells; i++) {
				//for (var j:uint = 0; j < rows; j++) {
					//node = App.map._aStarNodes[coords.x + i][coords.z + j];
					//if (node.freezers.length != 0) {
						//return false;
					//}
				//}
			//}
			
			if (!open && !allParentZonesOpened) return false;
			
			if (wasClicked) return false;
			
			if (App.user.mode == User.GUEST) {
				return true;
			}
			
			if (sid == 2521) {
				new SimpleWindow( {
					label:SimpleWindow.ATTENTION,
					title:Locale.__e("flash:1429185188688"),
					text:Locale.__e('flash:1429185230673'),
					height:300
				}).show();
				return false;
			}
			
			if (onPrepare()) return true;
			
			if (onBonus()) return true;
			
			if (isUpgrade()) return true;
			
			if (onRewardCrafted()) return true;
			
			if (onRewardComplete()) return true;
			
			return false;
		}
		
		private function work():void 
		{
			if (App.user.mode == User.GUEST) return;
			if (finished < App.time) {
				App.self.setOffTimer(work);
				showIcon();
			}
		}
		
		private function get allParentZonesOpened():Boolean {
			var info:Object = App.data.storage[zoneID];
			if (info.hasOwnProperty('require')) {
				for (var zone:* in info.require) {
					if (App.data.storage[zone].type == 'Zones' && App.user.world.zones.indexOf(int(zone)) < 0)
						return false;
				}
			}
			
			if (sid == 2117) {
				zone == 2130;
				if (App.data.storage[zone].type == 'Zones' && App.user.world.zones.indexOf(int(zone)) < 0)
					return false;
			}
			
			return true;
		}
		
		public function updateLevel(checkRotate:Boolean = false):void 
		{
			if (level >= totalLevels && info.time == 0) {
				clickable = false;
				touchable = false;
			}
			
			if (textures == null) return;
			
			var levelData:Object = textures.sprites[this.level];
			
			if (levelData == null) {
				if (level > 0) {
					var lowLevel:int = level;
					while (lowLevel > 0) {
						if (textures.sprites[lowLevel]) {
							levelData = textures.sprites[lowLevel];
							break;
						}
						lowLevel--;
					}
				}
			}
			
			if (levelData == null) {
				if (textures.sprites[0]) {
					levelData = textures.sprites[0];
				}else {
					return;
				}
			}
			
			if (checkRotate && rotate == true) {
				flip();
			}
			
			if (this.level != 0 && gloweble) {
				var backBitmap:Bitmap = new Bitmap(bitmap.bitmapData);
				backBitmap.x = bitmap.x;
				backBitmap.y = bitmap.y;
				addChildAt(backBitmap, 0);
				bitmap.alpha = 0;
				
				TweenLite.to(bitmap, 0.4, { alpha:1, onComplete:function():void {
					removeChild(backBitmap);
					backBitmap = null;
				}});
				
				gloweble = false;
			}
			
			draw(levelData.bmp, levelData.dx, levelData.dy);
			
			if (zonerType == 'bridge') {
				if (level >= totalLevels) {
					tip = null;
					touchable = false;
					gloweble = false;
					clickable = false;
					free();
					if (sid == 773) {
						var settings:Object = { sid:777 };
						var unit:Unit = Unit.add(settings);
						//unit.stockAction({coords:{x:65, z:140}});
						unit.placing(this.coords.x + 28, 0, this.coords.z + 10);
					}
					if (sid == 1572) {
						var settingsUP:Object = { sid:1573 };
						var unitUp:Unit = Unit.add(settingsUP);
						unitUp.placing(this.coords.x + 2, 0, this.coords.z + 5);
						
						var settingsFence:Object = { sid:1578 };
						var unitFence:Unit = Unit.add(settingsFence);
						unitFence.placing(this.coords.x + 6, 0, this.coords.z + 17);
					}
				}
			}
		}
		
		
		// Storage 
		private var wasClicked:Boolean = false;
		public function storageEvent():void {
			wasClicked = true;
			var params:Object = {
				ctr:this.type,
				act:'storage',
				uID:App.user.id,
				wID:App.user.worldID,
				sID:this.sid,
				id:this.id
			}
			
			if (App.user.mode == User.OWNER) {
				if (finished > 0 && finished <= App.time)
					Post.send(params, onStorageEvent);
			}else {
				if (App.user.friends.takeGuestEnergy(App.owner.id)) {
					params['act'] = 'gueststorage';
					params['guest'] = App.user.id;
					params['uID'] = App.owner.id;
					
					Post.send(params, onStorageEvent, {guest:true});
				}
			}
		}
		public function onStorageEvent(error:int, data:Object, params:Object):void {
			wasClicked = false;
			if (error) {
				Errors.show(error, data);
				if(params && params.hasOwnProperty('guest')){
					App.user.friends.addGuestEnergy(App.owner.id);
				}
				return;
			}
			
			Treasures.bonus(data.bonus, new Point(this.x, this.y));
			SoundsManager.instance.playSFX('bonus');
			
			if (params != null) {
				if (params['guest'] != undefined) {
					App.user.friends.giveGuestBonus(App.owner.id);
				}
			}
			
			if (data.hasOwnProperty('started')) finished = data.started;
			
			showIcon();
			App.self.setOnTimer(work);
		}
		
		override public function stockAction(params:Object = null):void
		{
			if (!App.user.stock.check(sid))
			{
				//TODO показываем окно с ообщением, что на складе уже нет ничего
				return;
			}
			else if (!World.canBuilding(sid))
			{
				uninstall();
				return;
			}
			
			if (params && params.coords) {
				coords.x = params.coords.x;
				coords.z = params.coords.z;
			}
			
			App.user.stock.take(sid, 1);
			
			Post.send({ctr: this.type, act: 'stock', uID: App.user.id, wID: App.user.worldID, sID: this.sid, x: coords.x, z: coords.z, level:this.level}, onStockAction);
		}
		
		// Upgrade
		private var upgradeWindow:Window;
		protected function isUpgrade():Boolean {
			if (level < totalLevels) {
				upgradeWindow = new OpenZoneWindow( {
					zoneID:		zoneID,
					requires:	info.devel.obj[level + 1],
					title:		info.title,
					description:(info.hasOwnProperty('devel') && info.devel.hasOwnProperty('info')) ? info.devel.info[level + 1] : '',
					onUpgrade:	onUpgradeZoneGuide,
					onBoost:	onBoost,
					skipPrice:	(info.devel.skip) ? info.devel.skip[level + 1] : null,
					level:		level + 1,
					totalLevels:totalLevels
				});
				upgradeWindow.show();
				return true;
			}
			
			return false;
		}
		private function onUpgradeZoneGuide():void {
			if (!App.user.stock.takeAll(info.devel.obj[level + 1])) return;
			
			Post.send( {
				ctr:this.type,
				act:'upgrade',
				uID:App.user.id,
				id:this.id,
				wID:App.user.worldID,
				sID:this.sid,
				level:this.level
			}, onUpgradeEvent);
		}
		private function onUpgradeEvent(error:int, data:Object, params:Object):void {
			if (error) {
				Errors.show(error, data);
				return;
			}
			
			upgrade = App.time - 1;
			if (upgradeWindow) {
				upgradeWindow.close();
			}
			onBonus();
			
			//if (data.hasOwnProperty('upgrade')) {
				//upgrade = data.upgrade;
				//if (upgradeWindow) {
					//upgradeWindow.close();
				//}
				//
				//if ((level + 1) == totalLevels) {
					//finished = App.time + info.time;
				//}
				//
			//}
			
			//showIcon();
		}
		
		
		// Boost
		protected function onPrepare():Boolean {
			if (upgrade > 0 && upgrade > App.time && level == totalLevels) {
				new SpeedWindow( {
					title:			info.title,
					target:			this,
					totalTime:		info.devel.req[level + 1].t,
					finishTime:		upgrade,
					doBoost:		onBoost,
					priceSpeed:		info.devel.skip[level + 1]
				}).show();
				return true;
			}
			
			return false;
		}
		protected function onRewardCrafted():Boolean {
			if (info.time > 0 && finished > 0 && finished > App.time) {
				new SpeedWindow( {
					title:			info.title,
					target:			this,
					totalTime:		info.time,
					finishTime:		finished,
					doBoost:		onBoost,
					priceSpeed:		info.skip,
					zoneID:         zoneID
					//width:          600,
					//height:         320
				}).show();
				return true;
			}
			
			return false;
		}
		protected function onRewardComplete():Boolean {
			if (info.time > 0 && finished > 0 && finished <= App.time) {
				storageEvent();
				return true;
			}
			return false;
		}
		
		// Bonus
		public function onBonus():Boolean {
			if (upgrade > 0 && upgrade <= App.time) {
				Post.send({
					ctr:this.type,
					act:'reward',
					uID:App.user.id,
					id:this.id,
					wID:App.user.worldID,
					sID:this.sid
				}, onBonusEvent);
				
				if(level == totalLevels)
					WallPost.makePost(WallPost.NEW_ZONE, { sid:zoneID } );
				
				return true;
			}
			
			return false;
		}
		private function onBonusEvent(error:int, data:Object, params:Object):void {
			if (error) {
				Errors.show(error, data);
				return;
			}
			
			upgrade = 0;
			level++;
			
			if (level >= totalLevels)
				finished = App.time + info.time;
			
			showIcon();
			updateLevel();
			initAnimation();
			if (level >= totalLevels) openZone(info.devel.rew[level]);
			
			var reward:Object = { };
			for (var s:* in info.devel.rew[level]) {
				if (App.data.storage[s].type == 'Zones') continue;
				reward[s] = info.devel.rew[level][s];
			}
			Treasures.bonus(Treasures.convert(reward), new Point(this.x, this.y));
			
			if ((sid == 1095 || sid == 1125) && level >= totalLevels) {
				visible = false;
			}
		}
		
		
		
		private function onBoost(price:Object = null):void {
			var action:String = 'boost';
			if (!price) {
				if (level < totalLevels) {
					price = { };
					price[Stock.FANT] = info.devel.skip[level + 1];
					action = 'speedup';
				}else if (level >= totalLevels && finished > App.time) {
					price = { };
					price[Stock.FANT] = info.skip;
					action = 'boost';
				}
			}
			
			if (price && App.user.stock.take(Stock.FANT, uint(price))) {
				Post.send( {
					ctr:	type,
					act:	action,
					sID:	sid,
					id:		id,
					uID:	App.user.id,
					wID:	App.user.worldID
				}, function(error:int, data:Object, params:Object):void {
					if (error) {
						Errors.show(error, data);
						return;
					}
					
					if (data.hasOwnProperty('crafted')) finished = data.crafted;
					if (data.hasOwnProperty('reward')) 
						Treasures.bonus(data.reward, new Point(this.x, this.y));
					
					if (action == 'speedup') {
						onUpgradeEvent(error, { upgrade:App.time - info.devel.req[level + 1].t }, null);
					}
					
					showIcon();
				} );
			}
		}
		
		
		private function openZone(reward:Object = null):void {
			if (reward && zoneID > 0 && App.data.storage[zoneID].type == 'Zones') {
				if (World.zoneIsOpen(zoneID)) return;
				if (!App.user.world.hasOwnProperty('zones')) App.user.world.zones = [];
				App.user.world.zones.push(zoneID);
				for (var s:* in reward) {
					if (int(s) == zoneID)
						App.user.world.changeNodes(zoneID);
				}
				
				//Делаем push в _6e
				if (App.social == 'FB') {
					ExternalApi.og('investigate','area');
				}
			}
			
			if (User.inExpedition)
				App.map.fogManager.openZone();
		}
		
		
		// Timer
		private function timer():void {
			relocate();
		}
		
		
		// Relocate
		private function relocate():void {
 			if (!formed || !walkable) return;
			if (_framesType == WALK) return;
			
			goOnRandomPlace(onGoOnRandomPlace);
		}
		private function startRelocate(timeout:int = 5000, random:int = 2000):void {
			if (relocateTimeout > 0) stopRelocate();
			relocateTimeout = setTimeout(relocate, timeout + Math.random() * random);
		}
		private function stopRelocate():void {
			clearTimeout(relocateTimeout);
			relocateTimeout = 0;
		}
		
		
		// Zoner rest
		private function startRest():void {
			if (walkable) {
				
				// Определить привязан ли объект к зоне
				var find:Boolean = false;
				for (var asses:* in App.map.assetZones) {
					if (zoneID > 0 && App.map.assetZones[asses] == zoneID) {
						find = true;
						zoneAsset = asses;
					}
				}
				
				if (find)
					setRest();
			}else {
				if (textures.hasOwnProperty('animation') && textures.animation.hasOwnProperty('animations')) {
					setRest();
				}
			}
		}
		
		override public function setRest():void {
			if (App.user.quests.tutorial) {
				framesType = STOP;
				return;
			}
			
			var randomID:int = int(Math.random() * rests.length);
			var randomRest:String = rests[randomID];
			restCount = generateRestCount();
			
			var phaseType:String = 'phase_' + level;
			if (textures.animation.animations.hasOwnProperty(phaseType)) randomRest = phaseType;
			framesType = randomRest;
			startSound(randomRest);
		}
		
		public function goOnRandomPlace(callback:Function):void 
		{
			var place:Object = getRandomPlace();
			if (place) {
				framesType = WALK;
				initMove(
					place.x,
					place.z,
					callback
				);
			}
		}
		public function getRandomPlace():Object 
		{
			var i:int = 100;
			while (i > 0) {
				i--;
				var place:Object = nextPlace();
				if (App.map._aStarNodes[place.x][place.z].z != zoneID || App.map._aStarNodes[place.x][place.z].isWall) 
					continue;
				
				break;
			}
			
			if (i <= 0) return null;
			
			return {
				x:place.x,
				z:place.z
			}
			
			function nextPlace():Object {
				var randomX:int = int(Math.random() * Map.cells);
				var randomZ:int = int(Math.random() * Map.rows);
				return {
					x:randomX,
					z:randomZ
				}
			}
		}
		public function onGoOnRandomPlace():void {
			setRest();
		}
		
		
		override public function onLoop():void {
			if (_framesType.indexOf('rest') >= 0) {
				goOnRandomPlace(onGoOnRandomPlace);
			}
		}
		
		override public function addAnimation():void
		{
			super.addAnimation();
			
			var arrSorted:Array = [];
			var framesTypes:Array = [];
			if (textures && textures.hasOwnProperty('animation')) {
				for (var frameType:String in textures.animation.animations) {
					framesTypes.push(frameType);
				}
			}
			for each(var nm:String in framesTypes) {
				arrSorted.push(nm); 
			}
			arrSorted.sort();
			
			multipleAnime = [];
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
		
		override public function update(e:Event = null):void {
			
			if (_walk) {
				//_framesType = 'walk';
				
				if (start.y < finish.y){ 
					if (framesDirection != FACE) frame = 0;
					framesDirection = FACE; 
				}else {
					if (framesDirection != BACK) frame = 0;
					framesDirection = BACK;
				}
				
				if (start.x < finish.x) { 
					if (sid == 1770) {
						framesType = 'walk2';
						if (framesDirection == FACE){
							if(bitmap.scaleX>0){
								bitmap.scaleX = -1;
								sign = -1;
							}
						}
						framesFlip = RIGHT;
					}else {
						if (framesFlip != RIGHT){
							frame = 0;
							if(bitmap.scaleX>0){
								bitmap.scaleX = -1;
								sign = -1;
							}
						}
						framesFlip = RIGHT;
					}
				}else {
					if (framesFlip != LEFT){
						frame = 0;
						if(bitmap.scaleX<0){
							bitmap.scaleX = 1;
							sign = 1;
						}
					}
					framesFlip = LEFT;
				}	
				
			}else {
				if (!_position)	framesDirection = FACE;
			}
			
			var anim:Object = textures.animation.animations;
		
			if (!anim.hasOwnProperty(_framesType)) return;
			var cadr:uint 			= anim[_framesType].chain[frame];
			
			if (anim[_framesType].frames[framesDirection] == undefined) {
				framesDirection = 0;
			}
			var lt:int = anim[_framesType].frames[framesDirection].length;
			cadr = cadr >= lt?lt - 1:cadr;
			var frameObject:Object 	= anim[_framesType].frames[framesDirection][cadr];
			if (hasMultipleAnimation) multipleAnimation(cadr);
			
			if (!frameObject) {
				if (multipleAnime.hasOwnProperty('phase_' + (level - 1))) {
					multipleAnime['phase_' + (level - 1)].bitmap.visible = false;
					multipleAnime[_framesType].bitmap.visible = true;
				}
				frame 			= multipleAnime[_framesType].frame;
				cadr			= textures.animation.animations[_framesType].chain[frame];
				if (multipleAnime[_framesType].cadr != cadr) {
					multipleAnime[_framesType].cadr = cadr;
					frameObject 	= textures.animation.animations[_framesType].frames[cadr];
					
					multipleAnime[_framesType].bitmap.bitmapData = frameObject.bmd;
					multipleAnime[_framesType].bitmap.smoothing = true;
					multipleAnime[_framesType].bitmap.x = frameObject.ox+ax;
					multipleAnime[_framesType].bitmap.y = frameObject.oy+ay;
				}
				multipleAnime[_framesType].frame++;
				if (multipleAnime[_framesType].frame >= multipleAnime[_framesType].length){
					multipleAnime[_framesType].frame = 0;
				}
			}else {
				if (frameObject.bmd) bitmap.bitmapData = frameObject.bmd;
				bitmap.smoothing = true;
				bitmap.x = (frameObject.ox + ax) * sign;
				bitmap.y = (frameObject.oy + ay);
				
				frame++;
				if (frame >= anim[_framesType].chain.length) {
					this.dispatchEvent(new Event(Event.COMPLETE));
					frame = 0;
					onLoop();
				}
			}
			
			if (icon) iconSetPosition();
		}
		
		
		private function showIcon():void {
			if (!formed) return;
			
			if (App.user.mode == User.OWNER) {
				if (upgrade > 0 && upgrade <= App.time && level == totalLevels) {
					drawIcon(UnitIcon.REWARD, 2, 1, {
						glow:		true
					});
				}else if (level >= totalLevels && info.time > 0 && finished > 0 && finished <= App.time) {
					drawIcon(UnitIcon.REWARD, 2, 1, {
						glow:		true
					});
				}else {
					clearIcon();
				}
			}
		}
		
		override public function calcState(node:AStarNodeVO):int {
			return EMPTY;
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
		
		override public function uninstall():void {
			stopRelocate();
			super.uninstall();
		}
		
		override public function take():void {
			if (!takeable) return; 
			
			var node:AStarNodeVO;
			var part:AStarNodeVO;
			
			for (var i:uint = 0; i < cells; i++) {
				for (var j:uint = 0; j < rows; j++) {
					node = App.map._aStarNodes[coords.x + i][coords.z + j];
					node.isWall = (level >= totalLevels) ? false : true;
					node.b = 1;
					node.object = this;
					
					part = App.map._aStarParts[coords.x + i][coords.z + j];
					part.isWall = (level >= totalLevels) ? false : true;
					part.b = 1;
					part.object = this;
				}
			}
		}
		
		override public function free():void {
			if (!takeable) return;
			
			var node:AStarNodeVO;
			var part:AStarNodeVO;
			
			for (var i:uint = 0; i < cells; i++) {
				for (var j:uint = 0; j < rows; j++) {
					node = App.map._aStarNodes[coords.x + i][coords.z + j];
					node.isWall = false;
					node.b = (zonerType == 'bridge') ? 1 : 0;
					node.object = (zonerType == 'bridge') ? this : null;
					
					part = App.map._aStarParts[coords.x + i][coords.z + j];
					part.isWall = false;
					part.b = (zonerType == 'bridge') ? 1 : 0;
					part.object = (zonerType == 'bridge') ? this : null;
				}
			}
		}
	}

}