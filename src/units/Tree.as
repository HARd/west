package units 
{
	import api.ExternalApi;
	import astar.AStarNodeVO;
	import com.greensock.TweenLite;
	import core.Load;
	import core.Post;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import strings.Strings;
	import ui.Cursor;
	import ui.Hints;
	import ui.UnitIcon;
	import wins.EventWindow;
	import wins.SpeedWindow;
	import wins.TreeGuestWindow;
	import wins.TreeWindow;
	import wins.Window;
	
	public class Tree extends Tribute
	{
		public var _free:Object;
		public var _paid:Object;
		public var times:uint = 1;
		
		public var input:Object = {};
		public var output:Object = { };
		public var animal:int = 1;
		public var kick:int = 0;
		public var inStall:Boolean = false;
		public var stallTarget:Stall;
		public var aIndex:int;
		
		public function Tree(object:Object)
		{
			info = App.data.storage[object.sid];
			
			animal = object.animal || 1;
			kick = object.feeds || 0;
			object.crafted = object.started;
			
			info['area'] = { w:2, h:2 };
			
			super(object);
			
			
			
			clickable = true;
			multiple = true;
			
			if (object.hasOwnProperty('stallTarget')) {
				inStall = true;
				stallTarget = object.stallTarget;
				aIndex = object.index;
				removable = false;
			}
			
			if (Map.ready && started > 0)
				onMapComplete();
			else
				App.self.addEventListener(AppEvent.ON_MAP_COMPLETE, onMapComplete);
		}
		
		private function onMapComplete(e:AppEvent = null):void {
			App.self.removeEventListener(AppEvent.ON_MAP_COMPLETE, onMapComplete);
				
			if (isOnStall()) { sid
				attachStall();
			}
		}
		
		override public function load():void {
			var view:String = info.view;
			try {
				view = info.devel.req[animal].v;
			}catch(e:*) {}
			
			if (textures && animated) {
				stopAnimation(); 
				textures = null;
			}
			Load.loading(Config.getSwf(info.type, view), onLoad);
		}
		
		override public function get tribute():Boolean {
			if (started > 0 && started + time <= App.time)
				return true;
			
			return false;
		}
		
		public function startWork():void {
			clearIcon();
			App.self.setOnTimer(work);
		}
		
		override public function work():void {
			if (App.time >= started + time) {
				App.self.setOffTimer(work);
				checkState();
				
				if (stallTarget) {
					if (App.time >= started + time && started > 0){
						stallTarget.hasStorage = true;
						stallTarget.showStorageIcon();
					}
					hasProduct = false;
					if (kick >= kicks) {
						var that:* = this;
						TweenLite.to(this, 1, { alpha:0, onComplete:function():void 
							{
								removable = true;
								uninstall();
							}});
						stallTarget.removeAnimal(that);
						return;
					}
					if (stallTarget.currFoodCount >= info.devel.obj[animal][stallTarget.info['in']]) {	
						checkState();
						
						started = App.time;
						kick++;
						
						checkState();
						
						stallTarget.currFoodCount -= info.devel.obj[animal][stallTarget.info['in']];
											
						App.self.setOnTimer(work);
					} else {
						started = 0;
						showIcon();
					}
					return;
				}
			}
			
			
		}
		
		override public function init():void {
			// Потому что, видите ли, стартед это время окончания производства
			if (started > 0)
				started = started - time;
			
			if (info.hasOwnProperty('devel')) {
				if (info.devel.hasOwnProperty('obj'))
					input = info.devel.obj;
					
				if (info.devel.hasOwnProperty('rew'))
					output = info.devel.rew;
			}
			
			showIcon();
			
			if (App.user.mode == User.OWNER) {
				if (started > 0 && !tribute){
					App.self.setOnTimer(work);
				}
			}else {
				if (started > 0 && App.time > started + time) {
					touchableInGuest = false;
					return;
				}
				
				if (kicks > 0) {
					touchableInGuest = true;
					return;
				}
			}
			
			//flag = null;
			
			tip = function():Object {
				
				if (tribute)
				{
					return {
						title:info.title,
						text:Locale.__e("flash:1382952379959") + "\n" + Locale.__e('flash:1382952379960', [kick, kicks]) 
					};
				}
				
				if (started > 0)
				{
					return {
						title:info.title,
						text:Locale.__e("flash:1382952379961", [TimeConverter.timeToStr((started + time) - App.time)]) + "\n" + Locale.__e('flash:1382952379960', [kick, kicks]),
						timer:true
					};
				}
				
				var text:String = Locale.__e("flash:1382952379962")
				if (sid == 2945) text = Locale.__e('flash:1478093632629');
				
				return {
					title:info.title,
					text:text + "\n" + Locale.__e('flash:1382952379960', [kick, kicks])
				};
			}
		}
		
		override public function click():Boolean {
			if (!clickable) return false;
			
			if (stallTarget) {
				stallTarget.click();
				return false;
			}
			
			if (tribute) {
				if (App.user.mode == User.OWNER) {
					//var price:Object = { };
					//price[Stock.FANTASY] = 1;
					//
					//if (!App.user.stock.checkAll(price))	return false;
					
					if (App.user.addTarget({
						target:this,
						near:true,
						callback:storageEvent,
						event:Personage.HARVEST,
						jobPosition:getContactPosition(),
						shortcutCheck:true
					})) {
						ordered = true;
					}
				}
			} else {
				if (App.user.mode == User.OWNER) {
					
					if (!tribute && started == 0) {
						showEventWindow();
					} else {
						//new TreeWindow( {
							//target:this,
							//started:started,
							//time:time,
							//skip:boostPrice
						//}).show();
						
						new SpeedWindow( {
							title:info.title,
							target:this,
							info:info,
							finishTime:started + time,
							totalTime:time,
							priceSpeed:boostPrice
						}).show();
					}
				}
			}
			
			return true;
		}
		
		override public function onBoostEvent(count:int = 0):void {
			
			if (App.user.stock.take(Stock.FANT, boostPrice)) {
				
				var that:Tribute = this;
				
				Post.send({
					ctr:this.type,
					act:'boost',
					uID:App.user.id,
					id:this.id,
					wID:App.user.worldID,
					sID:this.sid
				}, function(error:*, data:*, params:*):void {
					
					if (!error && data) {
						started = data.started - time;
						App.ui.flashGlowing(that);
						checkState();
					}
					
				});	
			}
		}
		
		public override function storageEvent(value:int = 0):void
		{
			if (App.user.mode == User.OWNER) {
				
				Post.send({
					ctr:this.type,
					act:'storage',
					uID:App.user.id,
					id:this.id,
					wID:App.user.worldID,
					sID:this.sid
				}, onStorageEvent);
			} else {
				if(App.user.friends.takeGuestEnergy(App.owner.id)){
					Post.send({
						ctr:this.type,
						act:'gueststorage',
						uID:App.owner.id,
						id:this.id,
						wID:App.owner.worldID,
						sID:this.sid,
						guest:App.user.id
					}, onStorageEvent, {guest:true});
				} else {
					Hints.text(Locale.__e('flash:1382952379907'), Hints.TEXT_RED,  new Point(App.map.scaleX*(x + width / 2) + App.map.x, y*App.map.scaleY + App.map.y));
					App.user.onStopEvent();
					return;					
				}
			}
			
			started = 0;
			checkState();
			App.self.setOffTimer(work);
		}
		
		public override function onStorageEvent(error:int, data:Object, params:Object):void {
			if (error) {
				return;
			}
			ordered = false;
			
			super.onStorageEvent(error, data, params);
			
			started = 0;
			
			if (data['level']) {
				var nextLevel:Boolean = false;
				if (data.level > animal) {
					nextLevel = true;
					kick = 0;
				}else {
					kick++;
				}
				animal = data.level;
				if (nextLevel) load();
			}
			
			showIcon();
			
			if (data.bonus) {
				//if (App.isSocial('FB')) Treasures.bonus(Treasures.convert(data.bonus), new Point(this.x, this.y));
				/*else*/ Treasures.bonus(/*Treasures.convert(*/data.bonus/*)*/, new Point(this.x, this.y));
			}
			
			if (data['soul'] && data.soul['sid'] && App.data.storage.hasOwnProperty(data.soul.sid)) {
				App.self.setOffTimer(work);
				uninstall();
				
				var unit:Unit = Unit.add(data.soul);
				unit.install();
			}
		}
		
		override public function updateLevel(checkRotate:Boolean = false, mode:int = -1):void 
		{
			if (textures == null) return;
			
			var levelData:Object = textures.sprites[level];
			if (!levelData) {
				var _level:int = level;
				while (textures.sprites[_level] == null || _level <= 0) {
					_level--;
				}
				levelData = textures.sprites[_level];
			}
			
			if (checkRotate && rotate == true) {
				flip();
			}
			
			if (this.level != 0 && gloweble)
			{
				var backBitmap:Bitmap = new Bitmap(bitmap.bitmapData);
				backBitmap.x = bitmap.x;
				backBitmap.y = bitmap.y;
				addChildAt(backBitmap, 0);
				
				bitmap.alpha = 0;
				
				TweenLite.to(bitmap, 0.4, { alpha:1, onComplete:function():void {
					removeChild(backBitmap);
					backBitmap = null;
				}, onUpdate:function():void {
					backBitmap.alpha = 1 - bitmap.alpha;
				}});
				
				gloweble = false;
			}
			
			draw(levelData.bmp, levelData.dx, levelData.dy);
			
			checkOnAnimationInit();
		}
		
		override public function set state(state:uint):void {
			if (_state == state) return;
			
			switch(state) {
				case OCCUPIED: this.filters = [new GlowFilter(0xFF0000,1, 6,6,7)]; break;
				case EMPTY: this.filters = [new GlowFilter(0x00FF00,1, 6,6,7)]; break;
				case TOCHED: 
					this.filters = [new GlowFilter(0xFFFF00, 1, 6, 6, 7)];
					
					if (Cursor.type == 'default' && tribute) {
						Cursor.type = 'default_small';
						Cursor.image = Cursor.BACKET;
					}
					break;
				case HIGHLIGHTED: this.filters = [new GlowFilter(0x88ffed,0.6, 6,6,7)]; break;
				case IDENTIFIED: this.filters = [new GlowFilter(0x88ffed,1, 8,8,10)]; break;
				case DEFAULT:
					this.filters = [];
					
					if (Cursor.type == 'default_small') {
						Cursor.type = 'default';
						Cursor.image = null;
					}
					break;
			}
			_state = state;
		}
		
		/*override public function addAnimation():void
		{
			ax = textures.animation.ax;
			ay = textures.animation.ay;
			animationBitmap = new Bitmap();
			addChildAt(animationBitmap, 0);
			addChildAt(bitmap, 0);
		}*/
		
		private function getPosition():Object
		{
			var Y:int = -1;
			if (coords.z + Y <= 0)
				Y = 0;
			
			return { x:int(info.area.w / 2), y: Y };
		}
		
		
		private function showEventWindow():void {
			if (!formed) uninstall();
			
			if (App.user.stock.checkAll(input[animal])) {
				onWater();
			}else{
				new EventWindow( {
					target:this,
					sIDs:input[animal],
					description:Locale.__e('flash:1382952379963'),
					onWater:onWater
				} ).show();
			}
		}
		
		private function onWater():void 
		{
			waterEvent();
		}
		
		
		private var requestBlock:Boolean = false;
		public function waterEvent():void {
			
			var that:* = this;
			
			if (!App.user.stock.checkAll(input[animal], true)) {
				App.user.onStopEvent();
				showEventWindow();
				return;
			}
			
			if (App.user.stock.takeAll(input[animal])) {
				
				if (requestBlock) return;
				requestBlock = true;
				if (icon) icon.block = true;
				
				Post.send({
					ctr:this.type,
					act:'feed',
					uID:App.user.id,
					id:this.id,
					wID:App.user.worldID,
					sID:this.sid
				}, function(error:*, data:*, params:*):void {
					requestBlock = false;
					ordered = false;
					
					if (icon) icon.block = false;
					
					if (error) {
						Errors.show(error, data);
						return;
					}
					
					App.ui.flashGlowing(that, 0x00c0ff);
					started = data.started - time;
					App.self.setOnTimer(work);
					checkState();
				});
			}
		}
		
		public function alwaysKick(uid:*):Boolean {
			for (var s:String in _free) {
				if (String(uid) == _free[s])
					return true;
			}
			
			return false;
		}
		public function setKick(uid:*):void {
			_free[uid] = App.user.id;
		}
		
		public function checkState():void {
			if (started > 0 && started + time <= App.time) {
				if (level != 2) {
					level = 2;
					updateLevel();
				}
			}else if (started > 0 && started + time > App.time) {
				if (level != 1) {
					level = 1;
					updateLevel();
				}
			}else {
				if (level != 0) {
					level = 0;
					updateLevel();
				}
			}
			
			showIcon();
		}
		
		override public function showIcon():void {
			if (App.user.mode == User.GUEST) return;
			
			for (var msid:* in output[animal]) {
				if ([Stock.COINS, Stock.FANTASY, Stock.EXP].indexOf(int(msid)) != -1)
					continue;
				else
					break;
			}
			
			if (started > 0 && started + time > App.time) {
				drawIcon(UnitIcon.PRODUCTION, msid, 0, {
					progressBegin:	started,
					progressEnd:	started + time
				});
			}else if (started > 0 && started + time <= App.time) {
				drawIcon(UnitIcon.REWARD, msid, 0, {
					//glow:		true,
					iconScale:	0.8,
					multiclick:		true
				});
			}else {
				drawIcon(UnitIcon.MATERIAL, input[animal], 0, {
					stocklisten:	true,
					iconScale:		0.7,
					multiclick:		true
				});
			}
		}
		
		override public function calcState(node:AStarNodeVO):int
		{
			for (var foodID:* in info.devel.obj[animal]) break;
			for (var i:uint = 0; i < cells; i++) {
				for (var j:uint = 0; j < rows; j++) {
					node = App.map._aStarNodes[coords.x + i][coords.z + j];
					//trace('b = ', node.b, ' open = ' , node.open, ' object = ', node.object);
					if (node.b != 0 || node.open == false || (node.object != null && (!(node.object is Stall) || (node.object is Garden)) && node.b != 0)) {
						return OCCUPIED;
					}
					if (node.b != 0 || node.open == false || (node.object != null && node.object is Garden)) {
						return OCCUPIED;
					}
					if ((node.object is Stall) && foodID != (node.object as Stall).foodSID) {
						//showHelp(Locale.__e('flash:1456321901275'));
						return OCCUPIED;
					}
					if ((node.object is Stall) && (node.object as Stall).limit != 0 && ((node.object as Stall).limit < (node.object as Stall).animals.length + 1 || ((node.object as Stall).animals.length != 0 && (node.object as Stall).animals[(node.object as Stall).animals.length - 1].sid != sid))) {
						//showHelp(Locale.__e('flash:1456321951422'));
						return OCCUPIED;
					}
					if ((node.object is Stall) && (node.object as Stall).level < 1) {
						return OCCUPIED;
					}
				}
			}
			//hideHelp();
			return EMPTY;
		}
		
		private function isOnStall():Boolean {
			var node:AStarNodeVO = App.map._aStarNodes[coords.x][coords.z]; 
			for (var foodID:* in info.devel.obj[animal]) break;
			if (node.object != null && (node.object is Stall) && foodID == (node.object as Stall).foodSID) {
				if (kick <= kicks){
					stallTarget = (node.object as Stall);
					return true;
				}
			}
			return false;
		}
		
		private function attachStall():void {
			if (!inStall) {
				var that:* = this;
				if (hasProduct) storageEvent();
				Post.send( {
					ctr:'Stall',
					act:'attach',
					uID:App.user.id,
					wID:App.user.worldID,
					sID:stallTarget.sid,
					id:stallTarget.id,
					asID:this.sid,
					aID:this.id
				}, function(error:int, data:Object, params:Object):void {
					if (error) {
						return; 
					}
					stallTarget.animals.push(that); 
					stallTarget.moveable = false;
					aIndex = data.index;
					inStall = true;
					if (data && stallTarget.currFoodCount >= info.devel.obj[animal][stallTarget.info['in']]) {
						this.started = App.time + info.devel.req[animal].t;
						this.kick = data.feeds;
						showIcon();
						App.self.setOnTimer(work);
					}
				});
			}
		}
		
		private function detachStall():void {
			if (stallTarget) {
				var that:* = this;
				Post.send( {
					ctr:'Stall',
					act:'detach',
					uID:App.user.id,
					wID:App.user.worldID,
					sID:stallTarget.sid,
					id:stallTarget.id,
					asID:this.sid,
					aID:aIndex,
					x:coords.x,
					z:coords.z
				}, function(error:int, data:Object, params:Object):void {
					if (error) {
						return; 
					}
					stallTarget.removeAnimal(that);
					if (stallTarget.animals.length == 0) {
						stallTarget.moveable = true;
					}
					stallTarget = null;
					inStall = false;
					that.uninstall();
					
					if (data.hasOwnProperty('animal')) {
						if (data.animal.started > 0 && data.animal.started < App.time) {
							data.animal.started = data.animal.started + info.devel.req[data.animal.animal].t;
						}
						var unit:Unit = Unit.add(data.animal);
						World.tagUnit(unit);
						unit.id = data.animal.id;
					}
				});
			}
		}
		
		override public function moveAction():void {
			
			if (Cursor.prevType == "rotate") Cursor.type = Cursor.prevType;
			
			if (stallTarget) {
				//this.cell = coords.x;
				//this.row = coords.z;
				
				if (isOnStall()) {
					attachStall();
				} else {
					detachStall();
				}
				return;
			}
			
			Post.send( {
				ctr:this.type,
				act:'move',
				uID:App.user.id,
				wID:App.user.worldID,
				sID:this.sid,
				id:id,
				x:coords.x,
				z:coords.z,
				rotate:int(rotate)
			}, onMoveAction);
		}
		
		override public function onMoveAction(error:int, data:Object, params:Object):void
		{
			super.onMoveAction(error, data, params);
			
			if (isOnStall()) {
				attachStall();
			} else {
				detachStall();
			}
		}
		
		override public function take():void {
			
		}
		
		public function sendInvite(fID:String):void
		{
			//Пост на стену
			
			var message:String = Strings.__e('Tree_makePost', [Config.appUrl]);
			
			var scale:Number = 0.8;
			var bitmapData:BitmapData = textures.sprites[1].bmp;
			
			var bmp:Bitmap = new Bitmap(bitmapData);
			bmp.scaleX = bmp.scaleY = scale;
			var bmd:BitmapData = new BitmapData(bmp.width, bmp.height);
			var cont:Sprite = new Sprite();
			cont.addChild(bmp);
			bmp.smoothing = true;
			bmd.draw(cont);
			
			var _bitmap:Bitmap = new Bitmap(Gifts.generateGiftPost(new Bitmap(bmd), -30));
			
			if (_bitmap != null) {
				ExternalApi.apiWallPostEvent(ExternalApi.OTHER, _bitmap, String(fID), message, sid);
			}
			//End Пост на стену
		}
		
		public function sendKickPost(fID:String, bmp:Bitmap):void
		{
			//Пост на стену
			var message:String = Locale.__e("flash:1382952379965", [Config.appUrl]);
			var _bitmap:Bitmap = new Bitmap(Gifts.generateGiftPost(bmp));
			
			//App.self.addChild(_bitmap);
			
			if (_bitmap != null) {
				ExternalApi.apiWallPostEvent(ExternalApi.OTHER, _bitmap, String(fID), message, sid);
			}
			//End Пост на стену
		}
		
		public function get time():int {
			if (info.hasOwnProperty('devel') && info.devel.hasOwnProperty('req')) {
				return info.devel.req[animal].t;
			}
			
			return 3600;
		}
		
		public function get kicks():int {
			if (info.hasOwnProperty('devel') && info.devel.hasOwnProperty('req')) {
				return info.devel.req[animal].c;
			}
			
			return 1000;
		}
		
		public function get boostPrice():int {
			if (info.hasOwnProperty('devel') && info.devel.hasOwnProperty('req')) {
				return info.devel.req[animal].f;
			}
			
			return 1000;
		}
		
		override public function set alpha(value:Number):void {
			if (icon) icon.alpha = value;
			super.alpha = value;
		}
		
		override protected function onStockAction(error:int, data:Object, params:Object):void {
			super.onStockAction(error, data, params);
			hasPresent = false;
			started = 0;
			fromStock = false;
		}
		
		override public function isPresent():Boolean {
			return false;
		}
		
		override public function finishUpgrade():void {}
	}
}
