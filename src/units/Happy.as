package units 
{
	import core.Numbers;
	import core.Post;
	import core.TimeConverter;
	import flash.events.Event;
	import flash.geom.Point;
	import ui.SystemPanel;
	import ui.UnitIcon;
	import wins.EaselWindow;
	import wins.HappyWindow;
	import wins.InfoWindow;
	import wins.TopLeaguesWindow;
	import wins.TopRewardWindow;
	import wins.TopWindow;
	import wins.Window;
	//import wins.elements.HappyToy;
	//import wins.HappyGuestWindow;

	
	public class Happy extends Building 
	{
		public static var take:int = 0;
		public var topID:int = 0;
		public var kicks:int = 0;
		public var guests:Object = { };
		public var upgrade:int = 0;
		public var toys:Object = { };
		public var expire:int = 0;
		
		public static var users:Object = {};
		public var usersLength:int = 0;
		public var totalTowerLevels:int = 0;
		
		public function Happy(object:Object) 
		{
			
			if (object['kicks']) kicks = object.kicks;
			if (object['guests']) guests = object.guests;
			if (object['materials']) toys = object.materials;
			
			
			super(object);
			
			//if (sid == 981)
				//trace();
			
			if (object.hasOwnProperty('take'))
				Happy.take = object.take;sid
			
			if (info.hasOwnProperty('expire') && info.expire.hasOwnProperty(App.social) >= 0) {
				var _expire:int = info.expire[App.social];
				if (_expire > 0) {
					expire = _expire;
				}else {
					expire = info.time;
				}
			}else {
				expire = info.time;
			}
			
			//if (App.user.id == '120635122') {
				//expire = App.time + 1000;
			//}
			
			if (info.hasOwnProperty('devel')) {
				totalLevels = Numbers.countProps(info.devel.req);
			}
			
			if (info.hasOwnProperty('tower')) {
				totalTowerLevels = Numbers.countProps(info.tower);
			}
			
			checkLevel();
			
			if(App.user.mode == User.GUEST){
				touchableInGuest =  false;
			} else {
				touchableInGuest =  true;
			}
			
			if(App.time < expire){
				removable = false;
			} else {
				removable = true;
			}
			
			if (info.htype == 1) {
				removable = false;
			}
			
			for (var topID:* in App.data.top) {
				if (App.data.top[topID].target == this.sid) {
					this.topID = topID;
					break;
				}
			}
			
			if (this.topID != 0) expire = App.data.top[this.topID].expire.e;
			
			if (sid == 2687) {
				moveable = false;
			}
			//removable = true;
		}
		
		override public function openConstructWindow():Boolean 
		{
			//if (level <= totalLevels - craftLevels || level == 0)
		
			/*if (level <= totalLevels - craftLevels || level == 0)
			{
				if (App.user.mode == User.OWNER)
				{
					//if (hasUpgraded)
					//{
						new ConstructWindow( {
							title:			info.title,
							upgTime:		info.devel.req[level + 1].t,
							request:		info.devel.obj[level + 1],
							target:			this,
							win:			this,
							onUpgrade:		upgradeEvent,
							hasDescription:	true,
							find:helpTarget
						}).show();
						helpTarget = 0;
						return true;
					//}
				}
			}*/
			return false;
		}
		
		override public function click():Boolean {
			var that:* = this;
			if (sid == 1302 && App.user.worldID != User.HOME_WORLD) {
				Post.send( {
					ctr:	type,
					act:	'restore',
					uID:	App.user.id,
					wID:	App.user.worldID,
					id:		id,
					sID:	sid
				}, function(error:int, data:Object, params:Object):void {
					if (error) return;
					
					if (data.hasOwnProperty("bonus")){
						Treasures.bonus(Treasures.convert(data.bonus), new Point(that.x, that.y));
					}
					
					uninstall();
				});
				return false;
			}
			if (expire < App.time && info.htype != 1) {
				if (this.topID == 0) return true;
				for (var l:* in App.data.top[this.topID].league.lfrom) {
					if (App.data.top[this.topID].league.lfrom[l] < App.user.level && App.data.top[this.topID].league.lto[l] > App.user.level) {
						break;
					}
				}
					Post.send( {
						ctr:		'top',
						act:		'users',
						uID:		App.user.id,
						tID:		this.topID,
						league:		App.data.top[this.topID].league.lfrom[l] + 1
					}, function(error:int, data:Object, params:Object):void {
						if (error) return;
						
						if (data.hasOwnProperty('users')) {
							var rate:int = 0;
							HappyWindow.rates = data['users'] || { };
							
							for (var id:* in HappyWindow.rates) {
								if (App.user.id == id) {
									rate = HappyWindow.rates[id]['points'];
								}
								
								HappyWindow.rates[id]['uID'] = id;
							}
						}
						
						if (App.user.top.hasOwnProperty(this.action.tID)) {
							rate = (HappyWindow.rate > App.user.top[this.action.tID].count) ? rate : App.user.top[this.action.tID].count;
						}
						
						if (Numbers.countProps(HappyWindow.rates) > 100) {
							var array:Array = [];
							for (var s:* in HappyWindow.rates) {
								array.push(HappyWindow.rates[s]);
							}
							array.sortOn('points', Array.NUMERIC | Array.DESCENDING);
							array = array.splice(0, 100);
							for (s in HappyWindow.rates) {
								if (array.indexOf(HappyWindow.rates[s]) < 0)
									delete HappyWindow.rates[s];
							}
						}
						
						var top100DescText:String = Locale.__e('flash:1450277133471');
						if (sid == 1518) top100DescText = Locale.__e('flash:1454424636459');
						if (that.topID >= 8 && that.topID != 9) {
							new TopLeaguesWindow( {
								title:			info.title,
								description:	top100DescText,
								points:			rate,
								max:			100,
								target:			that,
								content:		HappyWindow.rates,
								material:		null,
								popup:			true,
								topID:			that.topID,
								onInfo:			function():void {
									
								}
							}).show();
						} else {
							new TopWindow( {
								title:			info.title,
								description:	top100DescText,
								points:			rate,
								max:			100,
								target:			that,
								content:		HappyWindow.rates,
								material:		null,
								popup:			true,
								onInfo:			function():void {
									if (sid != 1518 && sid != 935) {
										new TopRewardWindow().show();
									}else if (sid == 935) {
										new InfoWindow( {
											popup:true,
											qID:'100600'
										}).show();
									}else {
										new InfoWindow( {
											popup:true,
											qID:'100300'
										}).show();
									}
								}
							}).show();
						}
					});
				return false;
			}
			if (!isReadyToWork()) return true;
			
			if(App.user.mode == User.OWNER){
				if (isPresent()) return true;
				
				if (level < totalLevels) {
					openConstructWindow();
					return true;
				}
				
				openProductionWindow();
			} else {
					/*new HappyGuestWindow( {
					target:		this,
					mode:		HappyGuestWindow.GUEST
					}).show();*/
			}
			
			
			
			return true;
		}
		
		override public function openProductionWindow(settings:Object = null):void {
			if (info.htype == 1) {
				new EaselWindow( {
					target:		this,
					kickEvent:  kickAction
				}).show();
				return;
			}topID
			new HappyWindow( {
				target:		this,
				kickEvent:  kickAction
			}).show();
		}
		
		override public function checkOnAnimationInit():void {			
			if (textures && textures['animation']) {
				initAnimation();
				beginAnimation();
			}
		}
		
		override public function beginAnimation():void {
			startAnimation();			
		}
		
		private var lastPhase:String;
		override public function animate(e:Event = null, forceAnimate:Boolean = false):void 
		{
			if (!SystemPanel.animate && !(this is Lantern) && !forceAnimate) return;
			if (!textures || !textures.hasOwnProperty('animation')) return;
			
			var phase:String = '';
			var i:int = 0;
			while (level - i >= 0 && phase == '') {
				if (framesTypes.indexOf('phase_' + (level - i)) != -1 ) 
					phase = 'phase_' + (level - i);
					i++;
			}
			
			if (!lastPhase)
				lastPhase = phase;
			
			if ((sid == 1518 || sid == 1711 || sid == 1969 || sid == 2284) && phase == '') return;
			if (phase == '') return;
			var frame:*;
			var cadr:uint;
			var frameObject:Object;
			if (phase != '') {
				if (lastPhase && lastPhase != phase) {
					multipleAnime[lastPhase].bitmap.visible = false;
					lastPhase = phase;
					multipleAnime[phase].bitmap.visible = true;
				}
				frame 			= multipleAnime[phase].frame;
				cadr			= textures.animation.animations[phase].chain[frame];
				if (multipleAnime[phase].cadr != cadr) {
					multipleAnime[phase].cadr = cadr;
					frameObject 	= textures.animation.animations[phase].frames[cadr];
					
					multipleAnime[phase].bitmap.bitmapData = frameObject.bmd;
					multipleAnime[phase].bitmap.smoothing = true;
					multipleAnime[phase].bitmap.x = frameObject.ox+ax;
					multipleAnime[phase].bitmap.y = frameObject.oy+ay;
				}
				multipleAnime[phase].frame++;
				if (multipleAnime[phase].frame >= multipleAnime[phase].length){
					multipleAnime[phase].frame = 0;
				}
			}else {
				for each(var name:String in framesTypes) {
					frame			= multipleAnime[name].frame;
					cadr 			= textures.animation.animations[name].chain[frame];
					if (multipleAnime[name].cadr != cadr) {
						multipleAnime[name].cadr = cadr;
						frameObject 	= textures.animation.animations[name].frames[cadr];
						
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
		}
		
		public function get view():String {
			var view:String;
			for (var s:* in info.tower) {
				if (upgrade > int(s) && info.tower[s]['v']) view = info.tower[s]['v'];
				if (upgrade == int(s))
					return info.tower[s]['v'];
			}
			
			return view;
		}
		
		public function get canUpgrade():Boolean {
			if (kicksNeed > 0 && kicks >= kicksNeed) return true;
			
			return false;
		}
		
		public function get kicksNeed():int {
			var _kicks:int = 0;
			if (info.tower.hasOwnProperty(upgrade + 1)) {
				_kicks = info.tower[upgrade + 1].c;
			}
			return _kicks;
		}
		
		public function get kicksMax():int {
			var max:int = 0;
			for (var s:* in info.tower) {
				if (info.tower[s].c > max)
					max = info.tower[s].c;
			}
			return max;
		}
		
		private function checkLevel():void {
			if (level > totalLevels) {
				upgrade = level - totalLevels;
			}
		}
		
		public function canDecorate():Boolean {
			if (guests.hasOwnProperty(App.user.id) && guests[App.user.id] > App.midnight) {
				return false;
			}
			
			return true;
		}
		public function addGuest(uID:*):void {
			guests[uID] = App.time;
		}
		
		// Actions
		
		/*
		 * kick - добавление материала для роста елки (сам у себя дома)
		- params: uID, sID, wID, id, mID - сид материала со стуков
		- out: bonus, kicks
		*/
		
		private var kickCallback:Function;
		public function kickAction(mID:*, callback:Function = null):void {
			kickCallback = callback;
			
			Post.send( {
				ctr:	type,
				act:	'kick',
				uID:	App.user.id,
				wID:	App.user.worldID,
				id:		id,
				sID:	sid,
				mID:	mID
			}, function(error:int, data:Object, params:Object):void {
				if (error) return;
				
				if (data.hasOwnProperty('kicks')) kicks = data.kicks;
				
				if (kickCallback != null) {
					/*var bonus:Object;
					if (data.hasOwnProperty('bonus')) {
						bonus = Treasures.convert(data.bonus);
					}*/
					kickCallback(/*Treasures.treasureToBigObject(*/data.bonus/*)*/);
					kickCallback = null;
				}
			});
		}
		
		/*
		 * grow - получение награды и переход на след. уровень.
		- params: uID, sID, wID, id
		- out: level, bonus
		*/
		
		private var growCallback:Function;
		public function growAction(callback:Function = null):void {
			growCallback = callback;
			
			var that:Happy = this;
			
			Post.send( {
				ctr:	type,
				act:	'grow',
				uID:	App.user.id,
				wID:	App.user.worldID,
				id:		id,
				sID:	sid
			}, function(error:int, data:Object, params:Object):void {
				if (error) return;
				
				if (data.hasOwnProperty('level')) level = data.level;
				
				checkLevel();
				updateLevel();
				
				if (data.hasOwnProperty('id')) {
					Treasures.bonus(/*Treasures.treasureToObject(*/data.bonus/*)*/, new Point(that.x, that.y));
					
					Window.closeAll();
					uninstall();
					var newGold:Golden = new Golden( { id:data.id, sid:info.out, x:coords.x, z:coords.z, crafted:App.time + App.data.storage[info.out].time } );
					
				}else {
				
					if (growCallback != null) {
						growCallback(Treasures.treasureToObject(data.bonus));
						growCallback = null;
					}
				}
			});
		}
		
		public function onTakeBonus():void {
			var that:* = this;
			
			Post.send( {
				ctr:'Happy',
				act:'bonus',
				uID:App.user.id,
				sID:this.sid,
				id:id,
				wID:App.map.id
			},function(error:int, data:Object, params:Object):void {
				if (error) {
					Errors.show(error, data);
					return;
				}	
					
				Window.closeAll();
				
				Happy.take = 1;
				
				if (data.hasOwnProperty("bonus")){
					Treasures.bonus(data.bonus, new Point(that.x, that.y));
				}
			});
		}
		
		
		/*
		2) decorate - добавление украшеня в гостях
		- params: uID, sID, wID, id, mID - сид материала из info['outs'], x,y - координаты на елке
		- out: bonus
		*/
		
		/*private var saveToyCallback:Function;
		public function saveToyAction(toy:HappyToy, callback:Function = null):void {
			saveToyCallback = callback;
			
			Post.send( {
				ctr:	type,
				act:	'decorate',
				uID:	App.owner.id,
				guest:	App.user.id,
				wID:	App.owner.worldID,
				id:		id,
				sID:	sid,
				mID:	toy.sID,
				x:		toy.x,
				y:		toy.y
			}, function(error:int, data:Object, params:Object):void {
				if (error) return;
				
				toys[nextToyID] = {
					mID:	toy.sID,
					x:		toy.x,
					y:		toy.y,
					uID:	App.user.id
				}
				
				if (saveToyCallback != null) {
					saveToyCallback(toy, Treasures.treasureToObject(data.bonus));
					saveToyCallback = null;
				}
			});
		}
		private function get nextToyID():int {
			var last:int = 0;
			for (var s:* in toys) {
				if (!isNaN(int(s)) && int(s) >= last) {
					last++;
				}
			}
			return last;
		}*/
		
		
		/*
		clear - удаление украшения со своей елки
		- params: uID, sID, wID, id, mID - сид материала из info['outs'], x,y - координаты на елке
		- out: пусто
		*/
		
		/*override public function setFlag(value:*, callBack:Function = null, settings:Object = null):void {
			//super.setFlag(value, callBack, settings);
		}
		
		private var clearToyCallback:Function;
		public function clearToyAction(toy:HappyToy = null, callback:Function = null, all:Boolean = false):void {
			clearToyCallback = callback;
			
			var values:Object = {
				ctr:	type,
				act:	'clear',
				uID:	App.user.id,
				wID:	App.user.worldID,
				id:		id,
				sID:	sid
			};
			
			if (all) {
				values['all'] = 1;
			}else {
				values['mID'] = toy.sID;
				values['x'] = toy.x;
				values['y'] = toy.y;
			}
			
			Post.send(values, function(error:int, data:Object, params:Object):void {
				if (error) return;
				
				if (all) {
					toys = { };
				}else if( toys.hasOwnProperty(toy.id)) {
					delete toys[toy.id];
				}
				
				if (clearToyCallback != null) {
					clearToyCallback(toy);
					clearToyCallback = null;
				}
			});
		}*/
		
		override public function remove(_callback:Function = null):void {
			if ([935,980,981,982,1302,1969].indexOf(int(sid)) != -1) {
				var data:int = int(App.user.storageRead('building_' + sid, 0));
				if (data > 0) data -= 1;
				App.user.storageStore('building_' + sid, data, true);
			}
			
			super.remove(_callback);
		}
		
		override public function showIcon():void {
			if (App.user.mode == User.OWNER) {
				if (level > 0 && info.type == 'Hut') {
					clearIcon();
					return;
				}
			}
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
				clearIcon();
			}
		}
		
	}

}