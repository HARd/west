package units 
{
	import astar.AStarNodeVO;
	import com.greensock.TweenLite;
	import core.Load;
	import core.Numbers;
	import core.Post;
	import core.TimeConverter;
	import flash.display.GradientType;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.utils.clearInterval;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	import flash.utils.Timer;
	import ui.Cursor;
	import ui.Hints;
	import ui.UnitIcon;
	import wins.HaskyFeedingWindow;
	import wins.PurchaseWindow;
	import wins.ShopWindow;
	import wins.SimpleWindow;
	import wins.StallWindow;
	import wins.Window;
	
	public class Animal extends WorkerUnit
	{
		public static var waitForTarget:Boolean = false;
		public static var animals:Vector.<Animal> = new Vector.<Animal>;
		
		public var feeds:int = 0;
		public var animal:int = 0;
		public var started:uint = 0;
		
		public var canAddCowboy:Boolean = false;
		public var cowboy:Cowboy;
		
		public var isCollectionFinder:Boolean = false;
		public var inStall:Boolean = false;
		public var stallTarget:Stall;
		public var aIndex:int;
		
		public function Animal(object:Object)
		{
			started = object.started || 0;
			feeds = object.feeds || 0;
			animal = object.animal || 1;
			object['area'] = { w:1, h:1 }; 
			
			super(object);
			
			//info['area'] = { w:1, h:1 };
			cells = rows = 1;
			velocities = [0.05];
			
			takeable = false;
			moveable = true;
			removable = true;
			multiple = true;
			
			if (object.hasOwnProperty('stallTarget')) {
				inStall = true;
				stallTarget = object.stallTarget;
				aIndex = object.index;
				walkable = false;
				removable = false;
			}
			
			if (Config.admin) {
				removable = true;
			}
			
			if (App.data.options.hasOwnProperty('CollectionFinder')) {
				var finders:Object = JSON.parse(App.data.options.CollectionFinder);
				if (finders.hasOwnProperty(sid))	isCollectionFinder = true;
			}
			
			if (started > 0) {
				if (started > App.time) {
					App.self.setOnTimer(work);
				}else {
					hasProduct = true;
					walkable = false;
				}
			}
			
			if (started == 0 || started <= App.time)
				showIcon();
			
			tip = function():Object {
				if (isCollectionFinder)
				{
					if(started != 0){
						if (started > App.time) {
							return {
								title:info.title,
								text:Locale.__e('flash:1396606641768', [TimeConverter.timeToStr(started - App.time)]),
								timer:true
							}
						}else {
							return {
								title:info.title,
								text:Locale.__e('flash:1396606659545')
							}
						}
					}	
					
					return {
						title:info.title,
						text:info.description// + "\n" + Locale.__e("flash:1403797940774", [String(leftFeedsOnStage)])
					}
				}
				
				var stage:int = 0; 
				for (var st:* in info.devel.req) {
					stage++;
				}
				if(started != 0){
					if (started > App.time) {
						return {
							title:info.title,
							text:Locale.__e('flash:1456733722668', [String(animal), String(stage)]) + "\n" + Locale.__e('flash:1396606641768', [TimeConverter.timeToStr(started - App.time)] + "\n" + Locale.__e("flash:1403797940774", [String(leftFeedsOnStage)])),
							timer:true
						}
					}else {
						return {
							title:info.title,
							text:Locale.__e('flash:1396606659545')
						}
					}
				}	
				
				for (var out_sID:* in info.devel.rew[animal]) break;
				
				return {
					title:info.title,
					//text:info.description + "\n" + Locale.__e("flash:1403797940774", [String(leftFeedsOnStage)])
					text:Locale.__e('flash:1456733722668', [String(animal), String(stage)]) + "\n" + Locale.__e('flash:1382952380034') +' '+App.data.storage[out_sID].title + "\n" + Locale.__e("flash:1403797940774", [String(leftFeedsOnStage)])
				}
			}
			
			movePoint.x = coords.x;
			movePoint.y = coords.z;
			
			if (Map.ready && started > 0)
				goHome();
			else
				App.self.addEventListener(AppEvent.ON_MAP_COMPLETE, onMapComplete);
			
			/*if (object.buy) {
				showBorders();
			}*/
			
			App.self.addEventListener(AppEvent.ON_MOUSE_UP, onUp);
			shortcutDistance = 50;
			homeRadius = (isCollectionFinder) ? 10 : 2;
			
			//курочки
			if (sid == 159) homeRadius = 1;
			
			if (formed)
				animals.push(this);
				
			if (isOnStall()) {
				attachStall();
				walkable = false;
			} /*else {
				detachStall();
				walkable = true;
			}*/
			//App.self.addEventListener(AppEvent.ON_CHANGE_STOCK, onChangeStock);
		}
		
		public function get maxState():uint {
			var st:uint = 1;
			while (App.data.storage[sid].devel.rew.hasOwnProperty(st))
				st++;
			return st-1;
		}
		
		override public function load():void
		{
			var view:String = info.view;
			try {
				view = info.devel.req[animal].v;
			}catch(e:*) {}
			
			if (preloader) addChild(preloader);
			if (textures && animated) {
				stopAnimation(); 
				textures = null;
			}
			Load.loading(Config.getSwf(info.type, view), onLoad);
		}
		override public function onLoad(data:*):void {
			super.onLoad(data);
			
			bounds = null;
			if (isCollectionFinder && started < App.time) stopRest();
			iconSetPosition();
		}
		
		private function onChangeStock(e:AppEvent):void {
			showIcon();
		}
		
		private function onUp(e:AppEvent):void 
		{
			if (isMoveThis) {
				this.move = false;
				App.map.moved = null;
				isMove = false;
				isMoveThis = false
			}
			clearTimeout(intervalMove);
			isMove = false;
			isMoveThis = false;
		}
		
		override public function set move(move:Boolean):void {
			super.move = move;
			
			if (move){
				stopWalking();
				framesType = STOP;
			}	
			
			if (!move && isMoveThis)
				previousPlace();			
		}
		
		private var stall:Boolean = true;
		override public function previousPlace():void {
			super.previousPlace();
			
			if (contLight) {
				removeChild(contLight);
				contLight = null;
			}
		}
		
		private var contLight:LayerX;
		private function showBorders():void 
		{
			contLight = new LayerX();
			
			var sqSize:int = 30;
			
			var cont:Sprite = new Sprite();
			var sp:Sprite = new Sprite();
			sp.graphics.beginFill(0x89d93c);
			sp.graphics.drawEllipse(-130, -65 + 10, 260, 130);
			sp.alpha = 0.5;
			
			cont.addChild(sp);
			contLight.addChild(cont);
			addChildAt(contLight, 0);
		}
		
		override public function spit(callback:Function = null, target:* = null):void 
		{
			
		}
		
		override protected function onBuyAction(error:int, data:Object, params:Object):void 
		{
			if (error) {
				Errors.show(error, data);
				return;
			}
			
			if (contLight) {
				removeChild(contLight);
				contLight = null;
			}
			
			this.cell = coords.x;
			this.row = coords.z;
			this.id = data.id;
			
			movePoint.x = coords.x;
			movePoint.y = coords.z;
			
			showIcon();
		}
		
		override public function free():void {
			//showBorders();
			//super.free();
			
			if (inStall) {
				var node:AStarNodeVO;
				var part:AStarNodeVO;
				
				if (App.map._aStarNodes != null)
				{
					for (var i:uint = 0; i < cells; i++)
					{
						for (var j:uint = 0; j < rows; j++)
						{
							node = App.map._aStarNodes[coords.x + i][coords.z + j];
							node.isWall = false;
							node.b = 0;
							node.object = stallTarget;
							
							part = App.map._aStarParts[coords.x + i][coords.z + j];
							part.isWall = false;
							part.b = 0;
							part.object = stallTarget;
						}
					}
				}
			}else {
				super.free();
			}
		}
		
		override public function moveAction():void {
			
			if (Cursor.prevType == "rotate") Cursor.type = Cursor.prevType;
			
			if (stallTarget) {
				this.cell = coords.x;
				this.row = coords.z;
				
				movePoint.x = coords.x;
				movePoint.y = coords.z;
				
				if (started > 0)
					goHome();
					
				clearTimeout(intervalMove);
				isMove = false;
				isMoveThis = false;
				
				if (isOnStall()) {
					attachStall();
					walkable = false;
				} else {
					detachStall();
					walkable = true;
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
			if (contLight) {
				removeChild(contLight);
				contLight = null;
			}
			
			if (error) {
				Errors.show(error, data);
				
				free();
				_move = false;
				placing(prevCoords.x, prevCoords.y, prevCoords.z);
				take();
				state = DEFAULT;
				
				//TODO меняем координаты на старые
				return;
			}	
			this.cell = coords.x;
			this.row = coords.z;
			
			movePoint.x = coords.x;
			movePoint.y = coords.z;
				
			clearTimeout(intervalMove);
			isMove = false;
			isMoveThis = false;
			
			if (isOnStall()) {
				attachStall();
				//inStall = true;
				walkable = false;
				//moveable = false;
			} else {
				detachStall();
				walkable = true;
			}
			
			if (started > 0)
				goHome();
		}
		override public function take():void {
			
		}
		
		override protected function onStockAction(error:int, data:Object, params:Object):void {
			if (error) {
				Errors.show(error, data);
				return;
			}
			
			this.id = data.id;
			if(!(multiple && App.user.stock.check(sid))){
				//App.map.moved = null;
			}
			
			//App.ui.glowing(this);
			//World.addBuilding(this.sid);
			showIcon();
			onAfterStock();
			fromStock = false;
		}
		
		private function onMapComplete(e:AppEvent):void {
			App.self.removeEventListener(AppEvent.ON_MAP_COMPLETE, onMapComplete);
			
			if (animal == maxState && !isCollectionFinder) {
				//if (feeds >= App.data.storage[sid].devel.req[animal].c) {
				if (feeds >= info.devel.req[animal].c + 1) {
					removable = true;
					uninstall();
					removable = false;
				}
			}
			if (started > 0)
				goHome();
				
			if (isOnStall()) {
				walkable = false;
				attachStall();
			} /*else {
				detachStall();
				walkable = true;
			}*/
		}
		
		override public function set touch(touch:Boolean):void
		{
			if (App.user.mode == User.GUEST)
				return;
			
			//stopWalking();
			//onGoHomeComplete();
			
			super.touch = touch;
		}
		
		override public function onGoHomeComplete():void {
			stopRest();
			if(started > 0){
				var time:uint = Math.random() * 5000 + 5000;
				timer = setTimeout(goHome, time);
			}
		}
		
		override public function stopRest():void {
			if (isCollectionFinder) {
				if (started > 0 && started > App.time) {
					framesType = 'work';
				} else if (hasProduct)
				{
					stopWalking();
					framesType = 'lie';
				} else {
					framesType = 'sit';
				}
			}else {
				framesType = Personage.STOP;
			}
			
			if (timer > 0)
				clearTimeout(timer);
		}
		
		private var hungryCloseTween:TweenLite;
		private function closeHungryCloud():void 
		{
			//clearInterval(intervalHungry);
			//if(cloudAnimal)hungryCloseTween = TweenLite.to(cloudAnimal, 1, { alpha:0, scaleX:0.3, scaleY:0.3, x:(cloudAnimal.x + 20), y:(cloudAnimal.y + 60), onComplete:realHungCloudClose});
		}
		
		private function realHungCloudClose():void
		{
			//clearInterval(intervalHungry);
			if (hungryCloseTween) {
				hungryCloseTween.kill();
				hungryCloseTween = null;
			}
		}
		
		override public function uninstall():void {
			removeAnyway = true;
			App.self.setOffTimer(work);
			
			if (animals.indexOf(this) != -1)
				animals.splice(index, 1);
				
			//if (stallTarget) stallTarget.removeAnimal(this);
			
			App.self.removeEventListener(AppEvent.ON_CHANGE_STOCK, onChangeStock);
			App.self.removeEventListener(AppEvent.ON_MOUSE_UP, onUp);
			
			super.uninstall();
			removeAnyway = false;
		}
		
		private var isMoveThis:Boolean = false;
		public static var isMove:Boolean = false;
		private var intervalMove:int;
		override public function onDown():void 
		{
			if (App.user.mode == User.OWNER) {
				if (isMove) {
					clearTimeout(intervalMove);
					isMove = false;
					isMoveThis = false;
				}else if(!cowboy){
					var that:Animal = this;
					intervalMove = setTimeout(function():void {
						isMove = true;
						isMoveThis = true;
						that.move = true;
						App.map.moved = that;
					}, 200);
				}
			}
		}
		
		private var lock:Boolean = false;
		public var hasProduct:Boolean = false;
		override public function click():Boolean
		{
			clearTimeout(intervalMove);
			if (stallTarget) {
				return false;
			}
			
			/*if (canAddCowboy && Animal.waitForTarget) {
				Cowboy.cowboy.tie(this);
				cowboy = Cowboy.cowboy;
				if (started <= 0) {
					started = App.time + info.duration;
					App.self.setOnTimer(work);
					work();
				}
				
				
				if (cloudAnimal)
					cloudAnimal.dispose();
				cloudAnimal = null;
				
				if (hasProduct) 
				{
					cowboy.storage();
					started = App.time + info.duration;
					App.self.setOnTimer(work);
					work();
				}
				return true;
			}
			
			if (cowboy) {
				cowboy.showSpeedWindow();
				return true;
			}*/
			
			if(isMoveThis && moveable){
				this.move = false;
				App.map.moved = null;
				isMove = false;
				isMoveThis = false;
				return true;
			}
			
			if (App.user.mode == User.GUEST) {
				return true;
			}
			
			if (lock) return false;
			
			if (hasProduct) {
				storageEvent();
				return true;
			}
			
			showIcon();
			
			if (started == 0)
				feedEvent();
			
			return true;
		}
		
		public function startWork():void {
			clearIcon();
			App.self.setOnTimer(work);
		}
		
		private var requestBlock:Boolean = false;
		private var isCollectionFinderApply:Boolean = false;
		public function feedEvent(value:int = 0):void {
			if (requestBlock) return;
			if (!formed) return;
			if (stallTarget) {
				new StallWindow( {
					target:		stallTarget,
					glowButton: true
				}).show();
				return;
			}
			
			for (var foodID:* in food) break;
			if (isCollectionFinder && !isCollectionFinderApply)
			{
				var desc:String = Locale.__e("flash:1432045845746");
				if (sid == 1475) desc = Locale.__e('flash:1453816536182');
				new HaskyFeedingWindow( {
					sid:sid,
					width:395,
					reqSID:foodID,
					require:food,
					description:desc,
					callback:function():void {
						isCollectionFinderApply = true;
						feedEvent();
					}
				}).show();
			} else {
				
				isCollectionFinderApply = false;
				
				if (!App.user.stock.takeAll(food, false, true)) {
					
					//new PurchaseWindow( {
						//width:395,
						//itemsOnPage:2,
						//content:PurchaseWindow.createContent("Energy", { inguest:0, view:App.data.storage[foodID].view} ),
						//find:foodID,
						//title:Locale.__e("flash:1396606700679"),
						//description:Locale.__e("flash:1382952379757"),
						//callback:function(sID:int):void {
							//var object:* = App.data.storage[sID];
							//App.user.stock.add(sID, object);
						//}
					//}).show();
				}else{
					
					requestBlock = true;
					
					var point:Point = new Point(this.x*App.map.scaleX + App.map.x, this.y*App.map.scaleY + App.map.y);
					Hints.minus(foodID, food[foodID], point);
					
					App.ui.flashGlowing(this, 0x83c42a);
					flyMaterial(foodID);
					clearIcon();
					
					Post.send({
						ctr:this.type,
						act:'feed',
						uID:App.user.id,
						id:this.id,
						wID:App.user.worldID,
						sID:this.sid
					}, function(error:int, data:Object, params:Object):void {
						
						requestBlock = false;
						
						if (error) {
							Errors.show(error, data);
							return;
						}
						
						started = data.started;
						feeds = data.feed;
						walkable = true;
						if (stallTarget) walkable = false;
						
						App.self.setOnTimer(work);
						
						setRest();
						setTimeout(goHome, 5000);
					});
				}
			}
			
		}
		
		override public function setRest():void {
			if (isCollectionFinder) {
				stopRest();
			}else {
				if (App.user.quests.tutorial) {
					framesType = STOP;
					return;
				}
				
				var randomID:int = int(Math.random() * rests.length);
				var randomRest:String = rests[randomID];
				restCount = generateRestCount();
				framesType = randomRest;
				startSound(randomRest);
			}
		}
		
		override public function goHome(_movePoint:Object = null):void
		{
			clearTimeout(timer);
			if (!walkable) return;
			
			if (_framesType != Personage.STOP && _framesType != 'work') {
				var newtime:uint = Math.random() * 5000 + 5000;
				timer = setTimeout(goHome, newtime);
				return;
			}
			
			if (isRemove)
				return;
			
			if (move) {
				var time:uint = Math.random() * 5000 + 5000;
				timer = setTimeout(goHome, time);
				return;
			}
			
			if (workStatus == BUSY)
				return;
			
			var place:Object;
			if (_movePoint != null) {
				place = _movePoint;
			}else {
				place = findPlaceNearTarget({info:{area:{w:1,h:1}},coords:{x:this.movePoint.x, z:this.movePoint.y}}, homeRadius);
			}
			
			if (sid == 1127) return;
			framesType = Personage.WALK;
			initMove(
				place.x,
				place.z,
				onGoHomeComplete
			);
		}
		
		private function flyMaterial(sid:int):void
		{
			var item:BonusItem = new BonusItem(sid, 0);
			var point:Point = Window.localToGlobal(App.ui.bottomPanel.bttnMainStock);
			var moveTo:Point = new Point(App.self.mouseX, App.self.mouseY);
			if (isCollectionFinder) moveTo = Window.localToGlobal(this);
			item.fromStock(point, moveTo, App.self.tipsContainer);
		}
		
		private function work():void 
		{
			if (App.user.mode == User.GUEST) return;
			if (App.time > started ) {
			
					App.self.setOffTimer(work);
					hasProduct = true;
					walkable = false;
					if (isCollectionFinder) stopRest();
					if (stallTarget) {
						nextFeedLevel = feeds + 1;
						
						if (App.time > started && started > 0){
							stallTarget.hasStorage = true;
							stallTarget.showStorageIcon();
						}
						hasProduct = false;
						if (feeds >= info.devel.req[animal].c) {
							animal++;
							if (!info.devel.obj.hasOwnProperty(animal))
							{
								var that:* = this;
								TweenLite.to(this, 1, { alpha:0, onComplete:function():void 
									{
										removable = true;
										uninstall();
									}});
								stallTarget.removeAnimal(that);
								return;
							} else {
								feeds = 0;
								load();
							}
						}
						if (stallTarget.currFoodCount >= info.devel.obj[animal][stallTarget.info['in']]) {						
							started = App.time + info.devel.req[animal].t;
							feeds++;
							
							stallTarget.currFoodCount -= info.devel.obj[animal][stallTarget.info['in']];
							
							walkable = false;							
							App.self.setOnTimer(work);
						} else {
							started = 0;
							showIcon();
						}
						clearTimeout(timer);
						return;
					}
					
					showIcon();
				//}
			}
		}
		
		public function onBoostEvent(count:int = 0):void {
			
			if (!App.user.stock.take(Stock.FANT, count)) return;//заменить
				
				var that:Animal = this;
				clearIcon();
				
				Post.send({
					ctr:this.type,
					act:'boost',
					uID:App.user.id,
					id:this.id,
					wID:App.user.worldID,
					sID:this.sid
				}, function(error:*, data:*, params:*):void {
					
					if (error) {
						Errors.show(error, data);
						return;
					}
					
					if (!error && data) {
						App.ui.flashGlowing(that);
						started = data.started;
						hasProduct = true;
					}
					
					if (isCollectionFinder) {
						if (_framesType == 'work') {
							onGoHomeComplete();
						}
					}
					
					SoundsManager.instance.playSFX('bonusBoost');
				});
		}
		
		private var nextFeedLevel:int;
		private function storageEvent(value:int = 0):void {
			
			if (App.user.mode != User.OWNER) return;
			clearIcon();
			
			nextFeedLevel = feeds + 1;
			
			Post.send({
				ctr:this.type,
				act:'storage',
				uID:App.user.id,
				id:this.id,
				wID:App.user.worldID,
				sID:this.sid
			}, onStorageEvent, {result:result});
		}
		
		private function onStorageEvent(error:int, data:Object, params:Object):void 
		{
			if (error) {
				Errors.show(error, data);
				return;
			}
			
			hasProduct = false;
			started = 0;
			
			if (data['level']) {
				var nextLevel:Boolean = false;
				if (data.level > animal) {
					nextLevel = true;
					feeds = 0;
				}else {
					feeds = data.feed;
				}
				animal = data.level;
				if (nextLevel) load();
			}
			
			stopWalking();
			onGoHomeComplete();
			clearTimeout(timer);
			
			if (animal >= Numbers.countProps(info.devel.req) && feeds >= info.devel.req[animal].c && nextFeedLevel > feeds && !isCollectionFinder) {
				var that:* = this;
				TweenLite.to(this, 1, { alpha:0, onComplete:function():void 
				{
					removable = true;
					uninstall();
					//new SimpleWindow({
						//title:App.data.storage[that.sid].title,
						//text:Locale.__e('flash:1396606732168')
					//}).show();
				}});	
			} else {
				showIcon();
			}
			if (!inStall) {
				if (data['bonus']) {
					Treasures.bonus(data.bonus, new Point(this.x, this.y));
				}
				
				Treasures.bonus(Treasures.convert(params.result), new Point(this.x, this.y));
			}
		}
		
		public function addCowboy(cowboy:Cowboy):void
		{
			this.cowboy = cowboy;
			if (hasProduct)
			{
				cowboy.animalDone();
			}
			removable = false;
		}
		
		override public function onRemoveFromStage(e:Event):void 
		{
			clearTimeout(timer);
			App.self.removeEventListener(AppEvent.ON_MAP_COMPLETE, onMapComplete);
			realHungCloudClose();
			
			super.onRemoveFromStage(e);
		}
		
		override public function checkOnSplice(start:*, finish:*):Boolean {
			return false;
		}
		
		override public function set state(state:uint):void {
			if (_state == state) return;
			
			switch(state) {
				case OCCUPIED: this.filters = [new GlowFilter(0xFF0000,1, 6,6,7)]; break;
				case EMPTY: this.filters = [new GlowFilter(0x00FF00,1, 6,6,7)]; break;
				case TOCHED: 
					this.filters = [new GlowFilter(0xFFFF00, 1, 6, 6, 7)];
					
					if (Cursor.type == 'default' && hasProduct) {
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
		
		private var currentNode:AStarNodeVO;
		override public function calcState(node:AStarNodeVO):int
		{
			for (var foodID:* in food) break;
			for (var i:uint = 0; i < cells; i++) {
				for (var j:uint = 0; j < rows; j++) {
					node = App.map._aStarNodes[coords.x + i][coords.z + j];
					//trace('b = ', node.b, ' open = ' , node.open, ' object = ', node.object);
					if (node.b != 0 || node.open == false || (node.object != null && !(node.object is Stall) && node.b != 0)) {
						return OCCUPIED;
					}
					if ((node.object is Stall) && foodID != (node.object as Stall).foodSID) {
						showHelp(Locale.__e('flash:1456321901275'));
						return OCCUPIED;
					}
					if ((node.object is Stall) && (node.object as Stall).limit != 0 && ((node.object as Stall).limit < (node.object as Stall).animals.length + 1 || ((node.object as Stall).animals.length != 0 && (node.object as Stall).animals[(node.object as Stall).animals.length - 1].sid != sid))) {
						showHelp(Locale.__e('flash:1456321951422'));
						return OCCUPIED;
					}
					/*if ((node.object is Stall) && started > 0 && started > App.time) {
						return OCCUPIED;
					}*/
					if ((node.object is Stall) && (node.object as Stall).level < 1) {
						return OCCUPIED;
					}
				}
			}
			hideHelp();
			return EMPTY;
		}
		
		private static const sizes:Object = { "90":1, '180':3, '240':5, '320':6 };
		private static const padding:uint = 3;
		private static const fontSize:uint = 17;
		private static var textLabel:TextField;
		private var prompt:Sprite = new Sprite();
		private function showHelp(text:String):void {
			var iconScale:Number;
			
			var text:String = text;
			var sprite:Sprite;
			
			for (var w:String in sizes) {
				var textWidth:int = int(w);
				var lineCount:int = Math.round((text.length * fontSize) / textWidth);
			}
			textLabel = Window.drawText("", {
				color:0x413116,
				multiline:true,
				border:false,
				fontSize:fontSize,
				textLeading:-5
			});
			
			textLabel.wordWrap = true;
			textLabel.text = text;
			textLabel.autoSize = TextFieldAutoSize.LEFT;
			textLabel.width = textWidth;
			

			var maxWidth:int = Math.max(textLabel.textWidth) + padding * 2;
			textLabel.width = maxWidth + 5;
			
			var maxHeight:int = textLabel.height + 10;
			
			var matrix:Matrix = new Matrix();
			matrix.createGradientBox(maxWidth + padding * 2, maxHeight + padding, (Math.PI / 180) * 90, 0, 0);
			
			var shape:Shape = new Shape();
			shape.graphics.beginGradientFill(GradientType.LINEAR, [0xeed4a6, 0xeed4a6], [1, 1], [0, 255], matrix);  //[0xe9e0ce, 0xd5c09f]
			shape.graphics.drawRoundRect(0, 0, maxWidth + padding * 2, maxHeight + padding, 15);
			shape.graphics.endFill();
			shape.filters = [new GlowFilter(0x4c4725, 1, 4, 4, 3, 1)];
			shape.alpha = 0.8;
			prompt.addChild(shape);
			
			textLabel.x = padding;
			//textLabel.y = titleLabel.height;
			
			if (sprite) {
				prompt.addChild(sprite);
			}
			
			textLabel.y = padding;
			
			prompt.addChild(textLabel);
			
			this.x -= 20;
			
			this.addChild(prompt);
		}
		
		private function hideHelp():void {
			if (prompt && prompt.parent) 
				prompt.parent.removeChild(prompt);
		}
		
		private function isOnStall():Boolean {
			var node:AStarNodeVO = App.map._aStarNodes[coords.x][coords.z]; this.maxState
			for (var foodID:* in food) break;
			if (node.object != null && node.object is Stall && foodID == (node.object as Stall).foodSID) {
				if (animal == maxState && feeds < info.devel.req[animal].c){
					stallTarget = (node.object as Stall);
					return true;
				} else if (animal < maxState) {
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
						this.feeds = data.feeds;
						this.walkable = false;
						//moveable = false;
						clearIcon();
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
					stallTarget = null;
					inStall = false;
					removeAnyway = true;
					App.self.setOffTimer(work);
					
					if (animals.indexOf(that) != -1)
						animals.splice(index, 1);
					
					App.self.removeEventListener(AppEvent.ON_CHANGE_STOCK, onChangeStock);
					App.self.removeEventListener(AppEvent.ON_MOUSE_UP, onUp);
					isRemove = true;
					clearTimeout(timer);
					stopWalking();
					App.map.removeUnit(that);
					if (formed)
					{
						World.removeBuilding(that);
					}
					clearIcon();
					removeAnyway = false;
					//that.uninstall();
					
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
		
		/**
		 * Общее количестов кормлений животного
		 */
		public function get totalFeeds():int {
			var value:int = 0;
			if (info.hasOwnProperty('devel') && info.devel.hasOwnProperty('req')) {
				for (var s:* in info.devel.req) {
					value += info.devel.req[s].c;
				}
			}
			
			return value;
		}
		
		/**
		 * Осталось кормлений
		 */
		public function get leftFeeds():int {
			var value:int = 0;
			if (info.hasOwnProperty('devel') && info.devel.hasOwnProperty('req')) {
				for (var s:* in info.devel.req) {
					if (animal == int(s)) {
						value += info.devel.req[s].c - feeds;
					}else if (animal < int(s)) {
						value += info.devel.req[s].c;
					}
				}
			}
			
			return value;
		}
		
		/**
		 * Осталось кормлений на стадии
		 */
		public function get leftFeedsOnStage():int {
			if (info.hasOwnProperty('devel') && info.devel.hasOwnProperty('req') && info.devel.req.hasOwnProperty(animal)) {
				return info.devel.req[animal].c - feeds/* - ((started > 0) ? 1 : 0)*/;
			}
			
			return 0;
		}
		
		/**
		 * Еда
		 */
		public function get food():Object {
			return info.devel.obj[animal];
		}
		
		public function get producting():Boolean {
			if (started > App.time) return true;
			return false;
		}
		public function get result():Object {
			return info.devel.rew[animal];
		}
		public function get boostPrice():int {
			return info.devel.req[animal].f;
		}
		public function get duration():int {
			return info.devel.req[animal].t;
		}
		
		
		public function showIcon():void {
			if (App.user.mode == User.OWNER) {
				if (stallTarget) {
					if (started < App.time && !hasProduct) {
						drawIcon(UnitIcon.MATERIAL, food, 0, {
							clickable:      true,
							onClick:		function():void {
								new StallWindow( {
									target:		stallTarget,
									glowButton: true
								}).show();
							},
							iconScale:		0.7,
							stocklisten:	true,
							disableText:	true,
							multiclick:		true
							//
						});
					} else {
						clearIcon();
					}
					return;
				}
				if (started > 0 && started > App.time) {
					if (App.user.quests.tutorial) {
						icon.hideGlowing();
						clearIcon();
						return;
					}
					
					drawIcon(UnitIcon.PROGRESS, null, 0, {
						clickable:		false,
						boostPrice:		boostPrice,
						onClick:		onBoostEvent,
						progressBegin:	started - duration,
						progressEnd:	started,
						hidden:			true,
						bttnCaption:	Locale.__e('flash:1382952380104')
					});
				} else if (started < App.time && hasProduct) {
					drawIcon(UnitIcon.REWARD, result, 0, {
						iconScale:  	0.7,
						multiclick:		true
					});
				} else {
					drawIcon(UnitIcon.MATERIAL, food, 0, {
						onClick:		feedEvent,
						iconScale:		0.7,
						stocklisten:	true,
						disableText:	true,
						multiclick:		true
						//
					});
				}
			}
		}
		
		override public function iconIndentCount():void {
			super.iconIndentCount();
			iconPosition.y -= 15;
			
			// Овца
			if (sid == 196) {
				iconPosition.y += 20;
			}
		}
		
		override public function set alpha(value:Number):void {
			if (icon) icon.alpha = value;
			super.alpha = value;
		}
	}
}