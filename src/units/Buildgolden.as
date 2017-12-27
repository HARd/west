package units 
{
	import core.Post;
	import core.TimeConverter;
	import flash.events.Event;
	import flash.geom.Point;
	import ui.SystemPanel;
	import ui.UnitIcon;
	import wins.ConstructWindow;
	import wins.SimpleWindow;
	import wins.SpeedWindow;
	/**
	 * ...
	 * @author ...
	 */
	public class Buildgolden extends Building
	{
		public var capacity:int = 0;
		public function Buildgolden(object:Object):void
		{			
			super(object);
			
			if(object.crafted)
				crafted = object.crafted;
			
			capacity = object.capacity?object.capacity:0;
			
			craftLevels = -1;
			if (info.devel && info.devel.req) {
				for each (var value:* in info.devel.req) {
					if (value.tr && App.data.treasures.hasOwnProperty(value.tr))
						craftLevels++;
				}
			}
			if (craftLevels < 0)
				craftLevels = 0;
			
			if (level > totalLevels) {
				level = totalLevels;
			}
			if (level >= totalLevels - craftLevels) {
				if (App.time > crafted - time) {
					if (!isWorking) {
						App.self.setOnTimer(work);
						isWorking = true;
					}
				}
			}
			
			//if (!(App.map._moved == this) && formed) {
				//this.open = App.user.world.checkUnitZone(this, 81);
			//}
			
			if (componentable) {
				removable = false;
				stockable = false;
				rotateable = false;
				moveable = false;
			}
			
			touchableInGuest = false;
			//removable = false;
			tip = function():Object {
				var capacityText:String = capacity < info.capacity?'\n' + Locale.__e('flash:1382952379794', String(info.capacity - capacity)):'';
				if (App.user.mode == User.GUEST) {
					return {
						title:info.title,
						text:info.description
					};
				}
				
				if (level == totalLevels)
				{
					if (App.time >= crafted) {
						return {
							title:info.title,
							text:Locale.__e("flash:1382952379966") + capacityText
						};
					}else{
						return {
							title:info.title,
							text:Locale.__e("flash:1382952379839", [TimeConverter.timeToStr(crafted - App.time)]) + capacityText,
							timer:true
						};
					}
				}
				
				return {
					title:info.title,
					text:Locale.__e("flash:1382952379967")
				};
			}
			
			if (buildFinished && !isWorking) {
				showIcon();
			}
			
			if (formed) {
				//if (!App.user.instance.hasOwnProperty(sid))
					//App.user.instance[sid] = 0;
				//App.user.instance[sid]++;
				Storage.instanceAdd(sid);
			}
			
		}
		
		private var showComponent:Boolean = false;
		override public function click():Boolean {
			
			if (App.user.mode == User.OWNER) {
				
				if (buildFinished) {
					if (App.time < crafted) {
						new SpeedWindow( {
							title:info.title,
							priceSpeed:info.skip,
							target:this,
							info:info,
							noBoostBttn:(info.hasOwnProperty('capacity') && info.capacity != 0),
							finishTime:crafted,
							totalTime:time,
							doBoost:onBoostEvent,
							btmdIconType:App.data.storage[sid].type,
							btmdIcon:App.data.storage[sid].preview,
							upgrade:(level < totalLevels) ? openConstructWindow : null
						}).show();
					}else {
						storageEvent();
						startMultistorage();
					}
				} else {
					showComponent = true;
					openConstructWindow();
				}
			}
			
			return false;
		}
		
		public function get buildFinished():Boolean {
			return (level >= totalLevels - craftLevels);
		}
		
		override public function onBoostEvent(count:int = 0):void {
			if (App.user.stock.take(Stock.FANT, count)){
				ordered = true
				var that:Buildgolden = this;
				Post.send({
					ctr:this.type,
					act:'boost',
					uID:App.user.id,
					id:this.id,
					wID:App.user.worldID,
					sID:this.sid
				}, function(error:*, data:*, params:*):void {
					if (!error && data) {
						crafted = data.crafted;
					}
					onProductionComplete();
					ordered = false;
				});	
			}
		}
		
		override public function openConstructWindow():Boolean 
		{
			if (!componentBuildable)
				return false;
			if (level <= totalLevels || level == 0)
			{
				if (App.user.mode == User.OWNER)
				{
					if (hasUpgraded)
					{
						if (info.devel.req.hasOwnProperty(level + 1)/* && (info.devel.req[level + 1].fr)*/) {
							new ConstructWindow( {
								title:			info.title,
								upgTime:		info.devel.req[level + 1].t,
								request:		info.devel.obj[level + 1],
								target:			this,
								win:			this,
								onUpgrade:		upgradeEvent,
								hasDescription:	true
							}).show();
						} else {
							//
						}
						
						return true;
					}
				}
			}
			return false;
		}
		
		public var isWorking:Boolean = false;
		override public function onUpgradeEvent(error:int, data:Object, params:Object):void {
			super.onUpgradeEvent(error, data, params);
			if (buildFinished) {
				crafted = App.time;
				showIcon();
				if(!isWorking){
					App.self.setOnTimer(work);
					isWorking = true;
				}
			};
		}
		
		
		public function work():void {
			if (App.user.mode == User.GUEST)
				return;
			
			if (App.time > crafted) {
				App.self.setOffTimer(work);
				showIcon()
				isWorking = false;
			}else {
				clearIcon();
			}
		}
		
		override public function storageEvent(value:int = 0):void
		{
			if (!App.user.stock.takeAll({2:1}))
				return;
			ordered = true;
			Post.send({
				ctr:this.type,
				act:'storage',
				uID:App.user.id,
				id:this.id,
				wID:App.user.worldID,
				sID:this.sid
			}, onStorageEvent);
		}
		
		override public function onStorageEvent(error:int, data:Object, params:Object):void {
			if (error){
				Errors.show(error, data);
				return;
			}
			
			if(data.hasOwnProperty('bonus')){
				var trgPoint:Point = new Point(this.x, this.y);
				Treasures.bonus(data.bonus, trgPoint);
			}
			capacity++;
			if (info.capacity && capacity >= info.capacity) {
				uninstall();
				return;
			}
			
			ordered = false;
			crafted = App.time + time;
			
			showIcon()
			if (!isWorking) {
				clearIcon();
				App.self.setOnTimer(work);
				isWorking = true;
			}
			
			if (buildFinished && level >= totalLevels) {
				checkOnAnimationInit();
				initAnimation();
				startAnimation();
			}
		}
		
		public function get time():int {
			if (info.devel && info.devel.req && info.devel.req[level])
				return info.devel.req[level].time;
			
			return info.time;
		}
		
		override public function updateLevel(checkRotate:Boolean = false, mode:int = 1):void {
			super.updateLevel(checkRotate, mode);
			
			if (buildFinished && level >= totalLevels) {
				checkOnAnimationInit();
				initAnimation();
				startAnimation();
				checkAndDrawFirstFrame();
			}
		}
		
		override public function checkOnAnimationInit():void {	
			if (level < totalLevels && sid != 2806) return;
			super.checkOnAnimationInit();
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
			
			if (phase == '' && sid == 2806) return;
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
		
		override public function showIcon():void {
			if (App.user.mode == User.GUEST) {
				clearIcon();
				return;
			}
			
			iconIndentCount();
			if (crafted > 0 && App.time >= crafted && buildFinished) {
				drawIcon(UnitIcon.REWARD, 2, 1, {
					glow:		false
				});
			}
		}
		
		override public function iconIndentCount():void {
			if (sid == 2090) {
				if (!bounds) return;
				countBounds('', level, false);
				iconPosition.x = bounds.x + bounds.w / 2;
				iconPosition.y = bounds.y + bounds.h * 0.1;
			}else {
				super.iconIndentCount();
			}
		}

	}
}