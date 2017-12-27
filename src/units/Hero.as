package units 
{
	import astar.AStar;
	import astar.AStarNodeVO;
	import com.greensock.easing.Strong;
	import com.greensock.TweenLite;
	import core.AvaLoad;
	import core.Load;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	import flash.utils.Timer;
	import ui.Cursor;
	import ui.ProgressBar;
	import wins.HeroWindow;
	import wins.SimpleWindow;
	import wins.Window;
	import units.Companion;
	/**
	 * ...
	 * @author 
	 */
	public class Hero extends WorkerUnit
	{
		private var progressBar:ProgressBar;
		
		public static const PRINCE:String = 'man';
		public static const PRINCESS:String = 'woman';
		
		public static const PRINCE_SID:int = 162;
		public static const PRINCESS_SID:int = 163;
		public static const MERRY:int = 323;
		public static const SEAMAN:int = 628;
		
		public var owner:*;
		public var fly:Boolean = false;
		public var wingsAnimation:Object = { };
		
		public var cloth:Object = {
			'head':0,
			'body':0,
			'sex':'m'
		};
		
		public var transport:Transport = null;
		public var alien:String = PRINCE;
		public var aka:String = '';
		
		public var isWorking:Boolean = false;
		
		public static function isMain(hero:Hero):Boolean 
		{
			if((hero.sid == 162 && App.user.sex == 'm') ||
			(hero.sid == 163 && App.user.sex == 'f'))
				return true;
				
			return false;	
		}
		
		public function Hero(owner:*, object:Object)
		{
			this.owner = owner;
			
			this.alien = object.alien;
			
			if (owner.head == null || owner.head == 0)
			{
				if (owner.sex == 'm')
					owner.head = User.BOY_HEAD;
				else
					owner.head = User.GIRL_HEAD;
			}
			
			if (owner.body == null || owner.body == 0)
			{
				if (owner.sex == 'm')
					owner.body = User.BOY_BODY;
				else
					owner.body = User.GIRL_BODY;
			}
			
			cloth.sex = owner.sex;
			cloth.head = owner.head;
			cloth.body = owner.body;
			
			if(App.map.id == User.HOME_WORLD){
				if(object.sid == 162){
					object.x = 41;
					object.z = 78;
				}
				if(object.sid == 163){
					object.x = 49;
					object.z = 87;
				}
			}
			
			super(object, alien);
			velocities = [0.1, 0.07];
						
			moveable = false;
			removable = false;
			transable = false;
			flyeble = true;
			rotateable = false;
			
			if (owner is Owner) {
				touchable = false;
				clickable = false;
				if(owner.id != 1){
					createAva(owner);
				}
			}
			
			//hasMultipleAnimation = true;
			
			tm = new TargetManager(this);
			framesType = STOP;
			
			aka = object.aka;
			
			tip = function():Object {
				return {
					title:info.title
				}
			}
			
			main = isMain(this);
			
			if (App.user.pet && App.user.pet.energy >= App.user.pet.minEnergy)
			{
				//App.user.pet.placing(cell, 0, row);
				setTimeout(placePetAtUse, 1100);
			}
		}
		
		private function placePetAtUse():void
		{
			App.user.pet.placing(cell + 4, 0, row + 2);
			App.user.pet.cell = cell + 4;
			App.user.pet.row = row + 2;
		}
		
		public var main:Boolean = false;
		private var liveTimer:uint = 0;
		override public function beginLive():void {
			if (main) return;
			return;
			
			var time:uint = 3000 + int(Math.random() * 3000);
			liveTimer = setTimeout(goHome, time);
		}
		
		override public function onGoHomeComplete():void {
			stopRest();
			var time:uint = Math.random() * 5000 + 5000;
			liveTimer = setTimeout(goHome, time);
		}
		
		override public function goHome(_movePoint:Object = null):void 
		{
			clearTimeout(liveTimer);
			liveTimer = 0;
			
			if (isRemove)
				return;
			
			if (move) {
				var time:uint = Math.random() * 5000 + 5000;
				liveTimer = setTimeout(goHome, time);
				return;
			}
			
			if (workStatus == BUSY) 
				return;
				
			var place:Object;	
				place = findPlaceNearTarget({info:{area:{w:1,h:1}},coords:{x:movePoint.x, z:movePoint.y}}, homeRadius);
			
			framesType = Personage.WALK;
			initMove(
				place.x, 
				place.z,
				onGoHomeComplete
			);
		}
		
		override public function stopLive():void {
			if (main) return;
			
			if (liveTimer > 0){
				clearTimeout(liveTimer);
				liveTimer = 0;
			}	
		}
		
		private function getClothView(sID:uint):String
		{
			return App.data.storage[sID].view;
		}
		
		public function change(clothSettings:Object , callback:Function = null):void
		{
			if (preloader) addChild(preloader);
			Load.loading(Config.getSwf('Clothes', getClothView(clothSettings.body)), 
				function(data:*):void {
					textures = data;
					if (callback != null) callback();
					if (preloader) {
						TweenLite.to(preloader, 0.5, { alpha:0, onComplete:removePreloader } );
					}
					App.data.storage[clothSettings.heroSid].view = App.data.storage[clothSettings.body].view;
				}
			);
		}
		override public function load():void
		{
			if (preloader) addChild(preloader);
			
			Load.loading(Config.getSwf('Clothes', info.view), onLoad);
		}
		
		private function onHeadLoad(data:*):void {
			hasMultipleAnimation = true;
			multipleAnime = data.animation.animations;
			
			if (textures != null)
				removePreloader();
		}
		
		public var ava:Sprite;
		
		private var avatarSprite:Sprite = new Sprite();
		private var avatar:Bitmap;
		private var friendID:*;
		
		public function createAva(friend:Object):void {
			//Аватар
						
			if (friend.hasOwnProperty('uid'))
				friendID = friend.uid;
			else
				friendID = friend.id;
				
				
			ava = new Sprite();
			ava.name = 'ava';
			var bg:Bitmap = Window.backing(74, 74, 10, "textSmallBacking");
			ava.addChild(bg);
			
			avatar = new Bitmap(null, "auto", true);
			avatarSprite.addChild(avatar);
			avatarSprite.x = 12;
			avatarSprite.y = 12;
			ava.addChild(avatarSprite);
			
			if (App.user.friends.data[friendID].first_name != null) {
				drawAvatar();
			}else {
				App.self.setOnTimer(checkOnLoad);
			}
			
			var arrow:Sprite = Window.shadowBacking(10, 10, 6);
			ava.addChild(arrow);
			arrow.x = ava.width / 2 - 5;
			arrow.y = bg.x + bg.height - 2;
			
			App.map.mTreasure.addChild(ava);
			ava.x = x - 38;
			ava.y = y - 168;
			
			ava.mouseChildren = false;
		}
		
		private function checkOnLoad():void {
			if (App.user.friends.data[friendID].first_name != null) 
			{
				App.self.setOffTimer(checkOnLoad);
				drawAvatar();
			}
		}
		
		override public function uninstall():void {
			super.uninstall();
			App.self.setOffTimer(checkOnLoad);
		}
		
		private function drawAvatar():void 
		{
			var friend:Object = App.user.friends.data[friendID];
			var name:TextField = Window.drawText(friend.aka || friend.first_name, {
				fontSize:18,
				color:0x502f06,
				borderColor:0xf8f2e0,
				autoSize:"left"
			});
			
			ava.addChild(name);
			name.x = (ava.width - name.width) / 2;
			name.y = -6;
			
			new AvaLoad(friend.photo, function(data:*):void {
				avatar.bitmapData = data.bitmapData;
				var shape:Shape = new Shape();
				shape.graphics.beginFill(0x000000, 1);
				shape.graphics.drawRoundRect(0, 0, 50, 50, 15, 15);
				shape.graphics.endFill();
				avatarSprite.mask = shape;
				avatarSprite.addChild(shape);
			});
		}
		
		override public function initMove(cell:int, row:int, _onPathComplete:Function = null):void {
			if (this.cell != cell || this.row != row) framesType = Personage.WALK;
			super.initMove(cell, row, _onPathComplete);
			
			if (App.user.pet)
			{	
				var petPos:Point = Companion.getPositionForPet(cell, row);
				App.user.pet.initMove(cell + 3, row + 3);
			}
		}
		
		override public function findPath(start:*, finish:*, _astar:*):Vector.<AStarNodeVO> {
			
			var needSplice:Boolean = checkOnSplice(start, finish);
			
			if (App.user.worldID == 1198 || App.user.worldID == 2099) needSplice = false;
			
			if (App.user.quests.tutorial && tm.currentTarget != null)
				tm.currentTarget.shortcutCheck = true;
				
			if (!needSplice) {
				var path:Vector.<AStarNodeVO> = _astar.search(start, finish);
				if (path == null) 
					return null;
					
				if (tm.currentTarget != null && tm.currentTarget.shortcutCheck) {
					if (path.length > shortcutDistance) {
						path = path.splice(path.length - shortcutDistance, shortcutDistance);
						placing(path[0].position.x, 0, path[0].position.y);
						alpha = 0;
						TweenLite.to(this, 1, { alpha:1 } );
						return path;
					}
				}
					
				if (!inViewport() || (tm.currentTarget != null && tm.currentTarget.shortcut)) {
					path = path.splice(path.length - 5, 5);
					placing(path[0].position.x, 0, path[0].position.y);
					alpha = 0;
					TweenLite.to(this, 1, { alpha:1 } );
					//if(App.user.pet)
						//App.user.pet.initMove(path[0].position.x+2, path[0].position.y+2);
				}		
			}else {
				placing(finish.position.x, 0, finish.position.y);
				cell = finish.position.x;
				row = finish.position.y;
				alpha = 0;
				TweenLite.to(this, 1, { alpha:1 } );
				return null;
			}
			
			return path;
		}
		
		
		

		/**
		 * Отправляем цель в TargetManager
		 * @param	targetObject имеет target, jobPosition, callback
		 */
		override public function addTarget(targetObject:Object):Boolean
		{
			if (transport != null && !(targetObject.target is Dock)) {
				new SimpleWindow( {
					title:Locale.__e('flash:1383572998112'),
					label:SimpleWindow.ATTENTION,
					text:Locale.__e('flash:1383573037900')
				}).show();
				Transport.showGlowDocks();
				return false;
			}
			
			makeVoice();
			
			tm.add(targetObject);
			stopLive();
			
			return true;
		}
		
		/**
		 * Выполняется когда персонаж останавливается без цели
		 */ 
		override public function onStop():void
		{
			framesType = Personage.STOP;
		}
		
		/**
		 * Выполняется когда персонаж доходит до цели
		 */ 
		override public function onPathToTargetComplete():void
		{
			startJob();
		}
		
		override public function set touch(touch:Boolean):void {
			if (Cursor.type == 'stock' && stockable == false) return;
			
			if (!touchable || (App.user.mode == User.GUEST && touchableInGuest == false)) return;
			
			
			_touch = touch;
			
			if (touch) {
				if(state == DEFAULT){
					state = TOCHED;
				}else if (state == HIGHLIGHTED) {
					state = IDENTIFIED;
				}
				
			}else {
				if(state == TOCHED){
					state = DEFAULT;
				}else if (state == IDENTIFIED) {
					state = HIGHLIGHTED;
				}
			}
		}
		
		/**
		 * Выполняем действие
		 */
		
		private function startJob():void
		{
			if (tm.currentTarget.target is Resource && (tm.currentTarget.target as Resource).lastReserved == 0 && !(tm.currentTarget.target as Resource).ordered) {
				finishJob();
				return;
			}
			var jobTime:int = tm.currentTarget.target.info.jobtime;
			if (jobTime <= 0) jobTime = 2;
			//if (Config.admin) jobTime = 1;
			//if (App.user.quests.tutorial) jobTime = 1.5;
			if (this.sid == 1774 || this.sid == 1775) jobTime = 1;
			
			isWorking = true;
			
			if (progressBar == null) {
				progressBar = new ProgressBar(jobTime);
			}
			
			if (tm.currentTarget == null) return;
			
			var target:* = tm.currentTarget.target;
			
			if (tm.currentTarget.target.hasOwnProperty('isTarget'))
				tm.currentTarget.target.isTarget = true;
			
			if (tm.currentTarget.onStart)
				tm.currentTarget.onStart();
			
			if (tm.currentTarget.event == 'harvest') {
				framesType = getJobFramesType(tm.currentTarget.target.sid);
			}else {
				framesType = tm.currentTarget.event;
			}
			
			position = tm.currentTarget.jobPosition;
			
			switch(tm.currentTarget.event) 
			{
				case "harvest":
					progressBar.label = Locale.__e('flash:1382952379925');
					break;
					
				default:
					progressBar.label = Locale.__e('flash:1382952379926'); 
					break;
			}
			
			progressBar.x = x - progressBar.width / 2; 
			progressBar.y = y - height - 10;
			progressBar.addEventListener(Event.COMPLETE, finishJob);
			
			if (App.user.quests.tutorial && App.tutorial && App.tutorial.step == 4) return;
			
			App.map.mTreasure.addChild(progressBar);
		}
		
		override public function onLoop():void
		{
			
			if (_framesType == Tutorial.INTRO_2)
				_framesType = Tutorial.INTRO_3;
				
			if (_framesType == Tutorial.INTRO_6)
				App.tutorial.setOriginalHeroTexture();
			
			super.onLoop();
		}
		
		override public function walk(e:Event = null):* 
		{
			switch(alien) {
				case PRINCE:
					velocity = velocities[0];
					break;
				case PRINCESS:
					velocity = velocities[1];
					break;	
			}
			
			super.walk();
		}	
		
		private function startFly():void
		{
			if (fly) return;
			fly = true;
			velocity = velocities[1];
			framesType = "_fly";
			TweenLite.to(shadow, 0.3, { alpha:0.4 } );
			addEventListener(Event.COMPLETE, onStartFly)
			SoundsManager.instance.playSFX("flyStart", this);
		}
		
		private function onStartFly(e:Event):void
		{
			removeEventListener(Event.COMPLETE, onStartFly)
			framesType = "fly";
		}
		
		private function onFinishFly(e:Event):void
		{
			removeEventListener(Event.COMPLETE, onFinishFly)
			framesType = "walk";
		}
		
		private function finishFly():void
		{
			if (!fly) return;
			fly = false;
			velocity = velocities[0];
			framesType = "fly_";
			TweenLite.to(shadow, 0.3, { alpha:1, ease:Strong.easeIn } );
			addEventListener(Event.COMPLETE, onFinishFly);
			SoundsManager.instance.playSFX("flyEnd", this);
		}
		
		/**
		 * Заканчиваем действие и flash:1382952379993меняем цель
		 * @param	e
		 */
		override public function finishJob(e:Event = null):void
		{
			isWorking = false;
			
			if(progressBar!= null){
				progressBar.removeEventListener(Event.COMPLETE, finishJob);
				
				if(App.map.mTreasure.contains(progressBar)){
					App.map.mTreasure.removeChild(progressBar);
				}
				progressBar = null;
			}
			
			if (hasEventListener(Event.COMPLETE))	
				removeEventListener(Event.COMPLETE, onFinishFly);
			
			if (hasEventListener(Event.COMPLETE))
				removeEventListener(Event.COMPLETE, onStartFly)
				
			if (tm.length == 0) framesType = Personage.STOP;
			
			if (tm.currentTarget != null) {
				
				if (tm.currentTarget.target.hasOwnProperty('isTarget'))
					tm.currentTarget.target.isTarget = false;
				
				tm.onTargetComplete();
			}
		}
		
		public function inViewport():Boolean 
		{
			var globalX:int = this.x * App.map.scaleX + App.map.x;
			var globalY:int = this.y * App.map.scaleY + App.map.y;
			
			if (globalX < -10 || globalX > App.self.stage.stageWidth + 10) 	return false;
			if (globalY < -10 || globalY > App.self.stage.stageHeight + 10) return false;
			
			return true;
		}
		
		
		override public function click():Boolean {
			
			if (App.user.quests.tutorial) return false;
			
			if (isWorking) return false;
			
			new HeroWindow( { sID:this.sid } ).show();
			
			return true;
		}
		
		
		public static function randomSound(sid:uint, type:String):String {
			if (sounds[sid][type] is Array)
				return sounds[sid][type][int(Math.random() * sounds[sid][type].length)];
			
			return sounds[sid][type];
		}
		
		public static var sounds:Object = {
			5: {//Трик
				gathering:'gathering_sound_3',
				voice:['speak_7','speak_8','speak_9']
			},
			230: {//Леа
				gathering:'gathering_sound_2',
				voice:['speak_4','speak_5','speak_6']
			},
			229: {//Хек
				gathering:'gathering_sound_1',
				voice:['speak_1','speak_2','speak_3']
			}
		}
		
		private var lastVoice:uint = 0;
		override public function makeVoice():void {
			if (!canVoice()) return;
			SoundsManager.instance.playSFX(randomSound(sid, 'voice'), null, 0, 3);
			lastVoice = App.time;
		}
		
		public function canVoice():Boolean {
			
			return false;
			
			if (lastVoice +10 < App.time)
				return true;
				
			return false;	
		}
		
		override public function iconIndentCount():void {
			if (!bounds) return;
			iconPosition.x = bounds.x + bounds.w / 2;
			iconPosition.y = bounds.y - 10;
		}
		
		public function getJobFramesType(sid:int):String {
			
			if (this.sid == User.PRINCE || App.data.storage[this.sid].out == User.PRINCE) {
				if (App.data.storage[sid].hasOwnProperty('subtype')) {
					if (App.data.storage[sid].subtype == 4) return 'work_mine';
					if (App.data.storage[sid].subtype == 2 || App.data.storage[sid].subtype == 9) return 'work_gather';
				}
				// Рубить
				if ([64, 78, 79, 80, 81, 122, 123, 124, 125, 126, 127, 132, 133, 134, 230, 231, 232, 233, 262, 263, 322,448,449,450,453,454,456,444,445,446,447,451,452,769,770,771,778,892,893,894,1106, 1107, 1108, 1363, 1364, 1365, 1368, 1369, 1370,1366, 1367,1559,1560,2109, 2110, 2107, 2108].indexOf(sid) >= 0) {
					return 'work_cut';
					
				// Добывать
				}else if ([56,57,58,59,60,65,66,67,68,69,70,71,72,128,129,130,135,136,137,138,162,164,165,313,432,433,434,435,436,1063,1208, 1209, 1210, 1231, 1232, 1233,1245, 1246, 1247,1211, 1212, 1213, 1234, 1235, 1236,1219, 1220, 1221, 1218, 1241, 1217, 1222, 1229, 1230, 1231, 1232, 1233, 1240, 1242,2118, 2119, 2152, 2153, 2154, 2163].indexOf(sid) >= 0) {
					return 'work_mine';
					
				// Собирать
				}else if ([51,52,53,54,61,62,63,73,74,75,76,77,82,83,158,431,437,438,439,440,441,442,443].indexOf(sid) >= 0) {
					return 'work_gather';
				}
			}else if (this.sid == User.PRINCESS || App.data.storage[this.sid].out == User.PRINCESS) 
			{
				if (App.data.storage[sid].hasOwnProperty('subtype')) {
					if (App.data.storage[sid].subtype == 4) return 'work_mine';
					if (App.data.storage[sid].subtype == 2 || App.data.storage[sid].subtype == 9) return 'work_gather';
				}
				// Рубить
				if ([64, 78, 79, 80, 81, 122, 123, 124, 125, 126, 127, 132, 133, 134, 230, 231, 232, 233, 262, 263, 322, 448,449,450,453,454,456,444,445,446,447,451,452,769,770,771,778,892,893,894,1106, 1107, 1108, 1363, 1364, 1365, 1368, 1369, 1370,1366, 1367,1559,1560,2109, 2110, 2107, 2108].indexOf(sid) >= 0) {
					return 'work_cut';
				// Добывать
				}else if ([56,57,58,59,60,65,66,67,68,69,70,71,72,128,129,130,135,136,137,138,162,164,165,313,432,433,434,435,436,1063,1208, 1209, 1210, 1231, 1232, 1233,1245, 1246, 1247,1211, 1212, 1213, 1234, 1235, 1236, 1219, 1220, 1221, 1218, 1241, 1217, 1222, 1229, 1230, 1231, 1232, 1233, 1240, 1242,2118, 2119, 2152, 2153, 2154, 2163].indexOf(sid) >= 0) {
					return 'work_mine';
				// Собирать
				}else if ([51,52,53,54,61,62,63,73,74,75,76,77,82,83,158,431,437,438,439,440,441,442,443].indexOf(sid) >= 0) {
					return 'work_gather';
				}
			}
			
			return 'work_gather';//Personage.HARVEST;
		}
		
	}
}