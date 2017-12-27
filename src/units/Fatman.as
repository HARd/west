package units 
{
	import core.Post;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.setTimeout;
	import ui.UnitIcon;
	import wins.SingleBarterWindow;
	import wins.Window;
	
	public class Fatman extends Building 
	{
		
		public const EATING_TIME:uint = 15;
		
		public var inited:Boolean = false;
		private var lastLevel:int = 0;
		public var timeTo:int = 0;
		public var timeCurr:int = 0;
		public var totalTime:int = 0;
		public var eatingTime:int = 0;
		public var _mode:String;
		
		public var food:Object;
		public var serverTime:int = 0;
		
		public function Fatman(object:Object)
		{
			super(object);
			
			if (!Config.admin) removable = false;
			
			lastLevel = level;
			totalTime = info.time * 3600;
			food = object['food'] || null;
			serverTime = object.time;
			
			crafting = true;
			removable = false;
			
			if(formed)
				checkState();
				
			if (Events.timeOfComplete <= App.time) {
				removable = true;
			}
			
			var time:int = Events.timeOfComplete;
			if (info.hasOwnProperty('expire') && info.expire.hasOwnProperty(App.social)) time = info.expire[App.social];
			if (time > 0 && time <= App.time) {
				removable = true;
			} else {
				removable = false;
			}
			
			tip = function():Object 
			{
				return {
					title:info.title,
					text:info.description
				};
			}
			
			if (food && food.hasOwnProperty('sID')) {
				if (!App.data.storage.hasOwnProperty(food.sID)) {
					updateData();
					return;
				}
				for (var m:* in App.data.storage[food.sID].require) {
					break;
				}
				if (!User.inUpdate(m)) {
					updateData();
					return;
				}
			}
		}
		
		public function checkState():void {
			if (level >= totalLevels) {
				if(!food || !food.time || !food.need) {
					updateData();
				}else {
					init();
				}
			}
		}
		
		override protected function onBuyAction(error:int, data:Object, params:Object):void {
			super.onBuyAction(error, data, params);
			checkState();
		}
		
		public function updateData(openWindow:Boolean = false):void {
			var time:int = Events.timeOfComplete;
			if (info.hasOwnProperty('expire') && info.expire.hasOwnProperty(App.social)) time = info.expire[App.social];
			if (time > 0 && time <= App.time) {
				return;
			}
			Post.send( {
				id:		id,
				uID:	App.user.id,
				sID:	sid,
				wID:	App.user.worldID,
				act:	'start',
				ctr:	'Fatman'
			}, function(error:int, data:Object, params:Object):void {
				if (error) return;
				
				if (data.food)
					parseData(data);
				
			}, {});
		}
		public function parseData(data:Object = null):void {
			if (!data) data = {food:food};
			
			food = data.food;
			for (var m:* in App.data.storage[food.sID].require) {
				break;
			}
			if (!User.inUpdate(m)) {
				updateData();
				return;
			}
			init(null,false);
		}
		
		override public function click():Boolean {
			if (App.user.mode == User.GUEST) return true;
			var infoQuest:Object = JSON.parse(App.data.quests[516].missions[1].target[1]);
			if (App.user.quests.data.hasOwnProperty(516) && App.user.quests.data[516].finished != 0 && infoQuest.sid1 == sid) {
				uninstall();
				Post.send({
					'ctr':'Fatman',
					'act':'swap',
					'uID':App.user.id,
					'wID':App.user.worldID,
					'sID':infoQuest.sid1,
					'id':this.id,
					'tID':infoQuest.sid2
				}, function(error:*, response:*, params:*):void {
					if (!error) {
						var newBuild:Walkgolden = new Walkgolden( { id:response.id, sid:infoQuest.sid2, x:coords.x, z:coords.z } );
					}
				});
				return false;
			}
			var time:int = Events.timeOfComplete;
			if (info.hasOwnProperty('expire') && info.expire.hasOwnProperty(App.social)) time = info.expire[App.social];
			if (time > 0 && time <= App.time) {
				return true;
			}
			
			if (mode && mode != SingleBarterWindow.EAT && level >= totalLevels) {
				
				new SingleBarterWindow( {
					target:			this,
					totalTime:		info.time * 3600,
					state:			mode,
					food:			(mode == SingleBarterWindow.WAIT) ? food : null
				}).show();
			}else if (level < totalLevels) {
				super.click();
			}
			
			return true;
		}
		
		public function timer():void {
			if (eatingTime > 0) {
				eatingTime--;
				if (eatingTime <= 0) init();
			}
			
			timeCurr = timeTo - App.time;
			if (timeCurr < 0) {
				timeCurr = 0;
				init();
			}
			
			if (App.data.quests.hasOwnProperty(516) && App.data.quests[516].missions[1].target.hasOwnProperty(1)) {
				var infoQuest:Object = JSON.parse(App.data.quests[516].missions[1].target[1]);
				if (App.user.quests.data.hasOwnProperty(516) && App.user.quests.data[516].finished != 0 && infoQuest.sid1 == sid) {
					showIcon();
				}
			}
		}
		
		override public function updateLevel(checkRotate:Boolean = false, mode:int = -1):void {
			super.updateLevel(checkRotate);
			if (level >= totalLevels) {
				initAnimation();
				beginAnimation();
			}
		}
		
		override public function onUpgradeEvent(error:int, data:Object, params:Object):void  {
			super.onUpgradeEvent(error, data, params);
			
			if (level >= totalLevels) {
				serverTime = App.time;
				setTimeout(updateData, 500);
			}
		}
		
		public function init(setMode:String = null, openWindow:Boolean = false):void {
			if (/*!yeti && */!inited) {
				App.self.setOnTimer(timer);
				//createYeti();
			}
			
			if (setMode == SingleBarterWindow.EAT) {
				mode = SingleBarterWindow.EAT;
				eatingTime = EATING_TIME;
				return;
			}
			
			if (totalTime <= 0) {
				mode = SingleBarterWindow.WAIT;
				inited = true;
				if (openWindow) {
					click();
				}
				return;
			}
			
			var window:* = Window.isClass(SingleBarterWindow);
			if (window && window.target.id == id) window.close();
			
			var attitude:Number = (App.time - serverTime) / totalTime;
			if (attitude == Infinity) attitude = 0;
			
			if (attitude >= 2) {
				attitude = attitude % 2;
				serverTime += (App.time - serverTime) - (App.time - serverTime) % (totalTime * 2);
				if (App.user.mode == User.GUEST) {
					trace(food);
				}else if (attitude < 1 && (!food.time || (food.time && food.time < App.time - totalTime * 2))) updateData();
			}
			if (attitude < 1) {
				mode = SingleBarterWindow.WAIT;
			}else if (attitude < 2) {
				mode = SingleBarterWindow.GONE;
			}
			
			if (serverTime == 0) serverTime = App.time;
			timeTo = App.time + totalTime - (App.time - serverTime) % totalTime;
			
			inited = true;
			
			if (openWindow) {
				click();
			}
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
				//animationContainer.addChild(multipleAnime[name].bitmap);
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
		
		public var _name:String;
		override public function animate(e:Event = null, forceAnimate:Boolean = false):void 
		{
			if(_name == null) _name = framesTypes[0];
			var name:String = _name;
			//for each(var name:String in framesTypes) {
				var frame:* 			= multipleAnime[name].frame;
				var cadr:uint 			= textures.animation.animations[name].chain[frame];
				if (multipleAnime[name].cadr != cadr) {
					multipleAnime[name].cadr = cadr;
					var frameObject:Object 	= textures.animation.animations[name].frames[cadr];
					
					multipleAnime[name].bitmap.bitmapData = frameObject.bmd;
					multipleAnime[name].bitmap.smoothing = true;
					multipleAnime[name].bitmap.x = frameObject.ox+ax;
					multipleAnime[name].bitmap.y = frameObject.oy + ay;
					multipleAnime[_name].bitmap.visible = true;
				}
				multipleAnime[name].frame++;
				if (multipleAnime[name].frame >= multipleAnime[name].length)
				{
					onLoop();
				}
			//}
		}
		
		public function onLoop():void {
			multipleAnime[_name].frame = 0;
			if (framesTypes.length > 1) setRest();
		}
		
		public function setRest():void {			
			var randomID:int = int(Math.random() * framesTypes.length);
			var randomRest:String = framesTypes[randomID];
			if (randomRest.indexOf('rest') == -1 && randomRest != 'stop_pause') {
				setRest();
				return;
			}
			if (!_name) return;
			multipleAnime[_name].bitmap.visible = false;
			_name = randomRest;
			multipleAnime[_name].bitmap.visible = true;
		}
		
		private function createYeti():void {
			/*if (sid != 1340) return;
			
			yeti = new Yeti( {
				id:			this.id,
				sid:		Yeti.YETI,
				target:		this,
				animation:	Yeti.ANIM_WAIT
			});
			addChild(yeti);*/
		}
		public function set mode(value:String):void {
			_mode = value;
			setYetiAnimation();
		}
		public function get mode():String {
			return _mode;
		}
		public function setYetiAnimation():void {
			/*if (!yeti) return;
			
			if(mode == YetiWindow.EAT) {
				yeti.x = 14;
				yeti.y = 90;
				yeti.framesType = Yeti.ANIM_EAT;
			}else if (mode == YetiWindow.GONE) {
				yeti.x = 9;
				yeti.y = 86;
				yeti.framesType = Yeti.ANIM_MAKE;
			}else {
				yeti.x = 14;
				yeti.y = 90;
				yeti.framesType = Yeti.ANIM_WAIT;
			}
			
			if (textures) {
				var levelData:Object = textures.sprites[this.level];
				if (mode == YetiWindow.GONE) {
					stopAnimation();
				}else {
					startAnimation();
				}
				draw(levelData.bmp, levelData.dx, levelData.dy);
			}*/
		}
		
		override public function uninstall():void {
			App.self.setOffTimer(timer);			
			super.uninstall();
		}
		
		override public function showIcon():void {
			if (App.user.mode != User.OWNER) return;
			
			if (App.data.quests.hasOwnProperty(516) && App.data.quests[516].missions[1].target.hasOwnProperty(1)) {
				var infoQuest:Object = JSON.parse(App.data.quests[516].missions[1].target[1]);
				if (App.user.quests.data.hasOwnProperty(516) && App.user.quests.data[516].finished != 0 && infoQuest.sid1 == sid) {
					drawIcon(UnitIcon.REWARD, 2, 1, {
						glow:		true
					});
				}
			}
		}
	}

}