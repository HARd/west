package units
{
	import com.greensock.TweenLite;
	import core.Post;
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.geom.Point;
	import ui.Cursor;
	import ui.SystemPanel;
	import ui.UnitIcon;
	import wins.BuildingConstructWindow;
	import wins.ConstructWindow;
	import wins.IndianEventWindow;
	import wins.PFloorsWindow2;
	import wins.SemiEventWindow;
	import wins.ShareGuestWindow;
	import wins.SimpleWindow;
	import wins.SpeedWindow;
	import wins.TowerWindow;
	import wins.PFloorsWindow2;
	/**
	 * ...
	 * @author 
	 */
	public class Floors extends Share
	{
		public static const ONE_SIDE_KICK:int = 0;
		public static const TWO_SIDE_KICK:int = 1;
		
		public var kicksLimit:int = 0;
		public var floor:int = 0;
		public var totalFloors:int = 0;
		public var timer:int = 0;
		public var typeOfKick:int = 0;
		public static const BURST_ALWAYS:int = 0;
		public static const BURST_ONLY_ON_COMPLETE:int = 1;
		public static const BURST_NEVER:int = 2;
		public static const BURST_ON_TIME:int = 3;
		 
		public function Floors(settings:Object)
		{
			gloweble = false;
			floor = settings.floor || 0;
			timer = settings.timer;
			//if (floor == -1)
				//settings['area'] = { w:4, h:4 };
			
			info = App.data.storage[settings.sid];
			
			for (var flr:* in info.tower) {
				if (info.tower[flr].hasOwnProperty('m') && info.tower[flr].m > 0)
					typeOfKick = TWO_SIDE_KICK;
				totalFloors++;
			}
			
			if (timer != 0) {
				totalFloors = 1;
			}
			
			super(settings);
			
			if (sid == 3029)
				trace(guests);
			
			craftLevels = totalFloors;
			
			kicksLimit = info.tower[totalFloors].c;
			
			if (sid == 2371 || sid == 2602) {
				removable = false;
			}
			
			if (floor == -1 || floor > totalFloors){
				changeOnDecor();
				return;
			}
			
			if (formed && textures)
				beginAnimation();
			
			clickable = true;
			
			if (sid == 637 || sid == 934) {
				removable = false;
				moveable = true;
				rotateable = false;
			}
			
			if (floor > totalFloors && App.user.mode == User.GUEST) {
				clearIcon();
			}
			
			if (floor <= totalFloors && level >= totalLevels && App.user.mode == User.GUEST) {
				startGlowing();
			}
		}
		
		override public function click():Boolean 
		{
			if (App.user.mode == User.GUEST && level < totalLevels) {
				new SimpleWindow( {
					title:info.title,
					label:SimpleWindow.ATTENTION,
					text:Locale.__e('flash:1409298573436')
				}).show();
				return true;
			}
			
			if (!clickable || id == 0) return false;
			if (floor > totalFloors) return true;
			
			if (!isReadyToWork()) return true;
			
			if(App.user.mode == User.OWNER){
				if (isPresent()) return true;
			}
			
			if (level < totalLevels) {
				if(App.user.mode == User.OWNER){
					new ConstructWindow( {
						title			:info.title,
						upgTime			:info.devel.req[level + 1].t,
						request			:info.devel.obj[level + 1],
						target			:this,
						onUpgrade		:upgradeEvent,
						reward          :info.devel.rew[level + 1],
						hasDescription	:true
					}).show();
				}
			}
			else
			{
				if (App.user.mode == User.OWNER)
				{
					if (sid == 637 || sid == 934 || sid == 2371 || sid == 2602) {
						new SemiEventWindow( {
							target:this,
							storageEvent:storageAction,
							upgradeEvent:growEvent,
							buyKicks:buyKicks,
							kickEvent:kickEvent
						}).show();
						return true;
					}
					if (info.type == 'Pfloors') {
						new PFloorsWindow2( {
							target:this,
							storageEvent:storageAction,
							upgradeEvent:growEvent,
							buyKicks:buyKicks,
							mKickEvent:mKickEvent
						}).show();
					}else{
						new TowerWindow({
							target:this,
							storageEvent:storageAction,
							upgradeEvent:growEvent,
							buyKicks:buyKicks
						}).show();
					}
				}
				else
				{
					if ((App.user.friends.data[App.owner.id].lastvisit + App.data.options['LastVisitDays']) < App.time && App.isSocial('VK','DM','OK','FS','ML')) {
						if ((App.user.friends.data[App.owner.id].alert + App.data.options['alerttime']) > App.time) {
							new SimpleWindow( {
								title: Locale.__e('flash:1382952379893'),
								text: Locale.__e('flash:1449654596563'),
								textSize: 32
							}).show();
						} else {
							new SimpleWindow( {
								title: Locale.__e('flash:1382952379893'),
								text: Locale.__e('flash:1435130693238'),
								buttonText: Locale.__e('flash:1406634917036'),
								showBonus:true,
								textSize: 32,
								confirm: function():void {
									App.self.sendPostWake();
								}
							}).show();
						}
						return false;
					} 
					if (hasPresent) {
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
						if (sid == 637 || sid == 934 || sid == 2371 || sid == 2602) {
							guestClick();
							return true;
						}
						new ShareGuestWindow( {
							t:3,
							target:this,
							kickEvent:kickEvent
						}).show();
					}
				}
			}
			
			return true;
		}
		
		public function growEvent(params:Object):void 
		{
			gloweble = true;
			var self:Floors = this;
			//flag = false;
			
			Post.send( {
				ctr:this.type,
				act:'grow',
				uID:App.user.id,
				id:this.id,
				wID:App.user.worldID,
				sID:this.sid
			},function(error:int, data:Object, params:Object):void {
				if (error) {
					Errors.show(error, data);
					return;
				}
				guests = { };
				floor = data.floor;
				updateLevel(true);
				
				if(data.hasOwnProperty('bonus'))
					Treasures.bonus(data.bonus, new Point(self.x, self.y));
			});
		}
		
		override public function updateLevel(checkRotate:Boolean = false, mode:int = -1):void {
			
			if (!textures) return;
			info
			var levelData:Object
			if(this.floor == 0)
				levelData = textures.sprites[this.level];
			else
			{
				if(textures.sprites[this.floor + this.level])
					levelData = textures.sprites[this.floor + this.level];
				else
					levelData = textures.sprites[this.floor + this.level -1];
			}
			
			if (type == "Pfloors")
			{
				if (this.floor > totalFloors)
					levelData = textures.sprites[totalFloors];
				else
					levelData = textures.sprites[this.floor];
			}
			if (checkRotate && rotate == true) {
				flip();
			}
			
			if (timer > 0) {
				levelData = textures.sprites[textures.sprites.length - 1];
			}
			
			if (this.level != 0 && gloweble)
			{
				var backBitmap:Bitmap = new Bitmap(bitmap.bitmapData);
				backBitmap.x = bitmap.x;
				backBitmap.y = bitmap.y;
				addChildAt(backBitmap, 0);
				
				bitmap.alpha = 0;
				
				App.ui.flashGlowing(this, 0xFFF000, function():void {
					if (level < totalLevels)
						drawIcon(UnitIcon.BUILD, null);
				});
					
				TweenLite.to(bitmap, 0.4, { alpha:1, onComplete:function():void {
					removeChild(backBitmap);
					backBitmap = null;
				}});
				
				gloweble = false;
			}
			
			if (levelData == null) {
				levelData = textures.sprites[0];
			}
			
			draw(levelData.bmp, levelData.dx, levelData.dy);
			
			if (level != 0 && animationBitmap == null && totalFloors != 0){
				initAnimation();
				beginAnimation();
				
				checkAndDrawFirstFrame();
			}
		}
		
		override public function startAnimation(random:Boolean = false):void 
		{
			if (type == "Pfloors")
			{
				if (animated)
					return;
				visibleAnimation = false;
				multiStartAnimations(false);
			}
			else
				super.startAnimation(random);
		}
		
		private function multiStartAnimations(random:Boolean = false):void
		{
			if (animated) return;
			
			for each(var name:String in framesTypes) {
				
				multipleAnime[name]['length'] = textures.animation.animations[name].chain.length;
				multipleAnime[name].bitmap.visible = true;
				if (int(name.substring(5, 6)) == floor) {
					multipleAnime[name].bitmap.visible = true;
				}else
				if (floor == totalFloors + 1 && int(name.substring(5, 6)) == totalFloors){
					multipleAnime[name].bitmap.visible = true;
				}else{
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
		
		override public function beginAnimation():void
		{
			if (type == "Pfloors")
			{
				if (animated)
					return;
				visibleAnimation = false;
				multiStartAnimations(false);
			}
			else
				startAnimation(true);
			
			if (info.view == 'cauldron') {
				if(level >= totalLevels)
					startSmoke();
			}	
		}
		
		private var lastPhase:String;
		override public function animate(e:Event = null, forceAnimate:Boolean = false):void 
		{
			if (!SystemPanel.animate && !(this is Lantern) && !forceAnimate) return;
			if (!textures || !textures.hasOwnProperty('animation')) return;
			
			if ((sid == 1823 || sid == 2371 || sid == 2602) && floor < totalFloors) return;
			
			var phase:String = '';
			var i:int = 0;
			while (floor + 1 - i > 0 && phase == '') {
				if (framesTypes.indexOf('phase_' + (floor + 1 - i)) != -1 ) 
					phase = 'phase_' + (floor  + 1 - i);
				
					i++;
			}
			
			if (!lastPhase)
				lastPhase = phase;
			
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
		
		override public function stopAnimation():void
		{
			App.self.setOffEnterFrame(animate);
			animated = false;
		}
		
		public function buyKicks(params:Object):void {
			
			var callback:Function = params.callback;
			var that:Floors = this;
			
			Post.send( {
				ctr:this.type,
				act:'boost',
				uID:App.user.id,
				id:this.id,
				wID:App.user.worldID,
				sID:this.sid
			},function(error:int, data:Object, params:Object):void {
				if (error) {
					Errors.show(error, data);
					return;
				}
				
				if (data.hasOwnProperty(Stock.FANT))
					App.user.stock.put(Stock.FANT, data[Stock.FANT]);
				
				if (typeOfKick == TWO_SIDE_KICK) {
					kicks = data.g_kicks;
					mykicks = data.h_kicks;
				}else{
					kicks = data.kicks;
				}
				//flag = Cloud.TRIBUTE;
				if (data.hasOwnProperty('timer')) {
					that.timer = data.timer;
				}
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
			//flag = false;
			
			showIcon();
			/*if (App.user.mode == User.GUEST) {
				touchableInGuest = true;
				flag = false;
				if(level == totalLevels){
					if (info.tower[floor + 1] != undefined) {
						flag = Cloud.HAND;
						if (kicks < info.tower[floor + 1].c){
							flag = Cloud.PICK;
						}
					}	
				}
			}
			else
			{
				flag = Cloud.TRIBUTE;
				if (floor > totalFloors || floor<0)
					flag = false;
					
				if (info.tower[floor + 1] != undefined){
					if (kicks < info.tower[floor + 1].c)
						flag = false;
				}
				else{
					if (info.burst == BURST_NEVER)
						flag = false;
				}
				
				if(hasPresent)
					setFlag("hand", isPresent, { target:this, roundBg:false, addGlow:false } );
			}*/
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
			if (this.type == "Pfloors")
			{
				sendObject = {
				ctr:this.type,
				act:'storage',
				uID:App.user.id,
				wID:App.user.worldID,
				sID:this.sid,
				id:this.id,
				iID:boost
			}
			
			if (this.type == "Pfloors")
					boost = 0;
			}
			Post.send(sendObject,
			function(error:int, data:Object, params:Object):void {
				
				if (error) {
					Errors.show(error, data);
					return;
				}
				
				var bonus:Object = { };
				
				if (data.hasOwnProperty('bonus'))
					bonus = data.bonus;
				
				if (data.hasOwnProperty('timer'))
					(self as Floors).timer = data.timer;
				else 
					(self as Floors).timer = App.time;
				
				callback(Stock.FANT, boost, bonus);
				
				if (data.hasOwnProperty(Stock.FANT))
					App.user.stock.data[Stock.FANT] = data[Stock.FANT];
				
				if (data.hasOwnProperty('bonus') && type == "Pfloors")
					Treasures.packageBonus(data.bonus, new Point(self.x, self.y));
					
				if (info.burst == BURST_ONLY_ON_COMPLETE)
				{
					if (type == "Pfloors")
					{
						//floor = -1;
						//updateLevel();
					}
					free();
					changeOnDecor();
					take();
				}else if (info.burst == BURST_ON_TIME) {
					floor = 0;
					kicks = 0;
					totalFloors = 1;
					kicksLimit = info.tower[totalFloors].c;
				}else{
					uninstall();
				}
				
				self = null;
			});
		}
		
		private function changeOnDecor():void 
		{
			floor = totalFloors + 1;
			if(textures){
				var levelData:Object;
				var i:int = 0;
				while (!levelData) {
					levelData = textures.sprites[level + floor - i];
					i++;
				}
				draw(levelData.bmp, levelData.dx, levelData.dy);
			}
			
			if (sid == 2371 || sid == 2602) {
				removable = true;
			}
			
			
			//info.area.w = App.data.storage[sid].area.w;
			//info.area.h = App.data.storage[sid].area.h;
			//cells = App.data.storage[sid].area.w;
			//rows = App.data.storage[sid].area.w;
			
			
			//flag = false;
			
			showIcon();
			
			initAnimation();
			beginAnimation();
		}
		
		override public function refresh():void {
			//touchableInGuest = false;
		}
		
		override public function setCraftLevels():void
		{
			craftLevels = totalFloors;
		}
		
		override public function set touch(touch:Boolean):void {
			if(floor >totalFloors){
				if (Cursor.type == 'default') {
					return;
				}
			}
			super.touch = touch;
		}
		
		override public function isReadyToWork():Boolean
		{
			var finishTime:int = -1;
			var totalTime:int = -1;
			if (created > 0 && !hasBuilded){ // еще строится
				var curLevel:int = level + 1;
				if (curLevel >= totalLevels) curLevel = totalLevels;
				finishTime = created;
				totalTime = App.data.storage[sid].devel.req[1].t;
			}else if (upgradedTime >0 && !hasUpgraded) { // еще апграйдится
				finishTime = upgradedTime;
				totalTime = App.data.storage[sid].devel.req[level+1].t;
			}	
			
			if(finishTime >0){
				new SpeedWindow( {
					title:info.title,
					target:this,
					info:info,
					finishTime:finishTime,
					totalTime:totalTime,
					priceSpeed: info.skip,
					doBoost:acselereatEvent
				}).show();
				return false;	
			}		
			
			return true;
		}
		
		override public function showIcon():void {
			if (!formed || !open) return;
			
			if (sid == 533) {
				clearIcon();
				return;
			}
			
			if (App.user.mode == User.OWNER) {				
				if (/*completed.length > 0*/crafted > 0 && crafted <= App.time && hasProduct && formula) {
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
				if ((info.type == 'Floors' || info.type == 'Pfloors') && sid != 2371 && sid != 2602)
				{
					if (level >= totalLevels && (floor < totalFloors && floor != -1)) {
						drawIcon(UnitIcon.HAND_STATE, UnitIcon.HAND, 1, {
							glow:		false/*,
							iconDY:     -50*/
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
	}
}