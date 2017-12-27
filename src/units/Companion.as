package units {
	
	import astar.AStarNodeVO;
	import buttons.Button;
	import com.greensock.TweenLite;
	import core.Post;
	import core.TimeConverter;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.setTimeout;
	import ui.UnitIcon;
	import units.WorkerUnit;
	//import wins.JamWindow;
	import wins.QuestsChaptersWindow;
	import wins.SimpleWindow;
	
	public class Companion extends WorkerUnit 
	{
		private static const WAIT:String = 'stop_pause';
		
		private static const ANIMATION_HAPPY:String = "happy";
		private static const ANIMATION_SAD:String = "sad";
		private static const ANIMATION_EAT:String = "eat";
		
		private static var _petFoods:Array;
		public var level:int = 0;
		public var totalLevels:int = 0;
		private var _energy:int = 0;
		private var _minEnergy:int = 99999999;
		public static function get petFoods():Array 
		{
			return _petFoods;
		}
		
		private var _finished:int;
		public function get finished():int 
		{
			return _finished;
		}
		public function set finished(value:int):void 
		{
			_finished = value;
		}
		
		private var _bountiesLeft:uint;
		private var _settings:Object;
		
		private var _lastFood:Object;
		private var _animateFeeding:Boolean;
		private var _onFeedComplete:Function;
		private var _foodID:int;
		private var _foodsForPet:Array;
		
		private var _bonusCount:int = 0;
		private var _materialID:int = 0;
		private var _resourceID:int = 0;
		
		public function Companion(object:Object = null) 
		{
			super(object);
			_settings = object;
			stockable = false;
			_bonusCount = int(_settings.count);
			_materialID = int(_settings.mID);
			_resourceID = int(_settings.rID);
			//placing(object.x, 0, object.z);
			//init();
			tips();
			info
		}
		
		override public function get formed():Boolean 
		{
			return true;
		}
		private function init():void
		{
			cells = 0;
			rows = 0;
			App.map._aStarNodes[coords.x][coords.z].object = null;
			
			velocities = [0.15, 0.75];
			velocity = 0.15;
			_bountiesLeft = _settings.feed;
			flyeble = true;
				
			if (App.user.mode != User.OWNER)
				visible = false;
			
			moveable = (_settings.fromShop || _settings.fromStock);
			removable = false;
			
			touchableInGuest = false;
			framesType = WAIT;
			
			if (!_settings.fromStock && !_settings.fromShop)
			{
				initWithHero();
			}
			initPetfoods();
		}
		
		override protected function onStockAction(error:int, data:Object, params:Object):void 
		{
			super.onStockAction(error, data, params);
			initWithHero();
		}
		
		override protected function onBuyAction(error:int, data:Object, params:Object):void 
		{
			super.onBuyAction(error, data, params);
			initWithHero();
		} 
		
		private function initWithHero():void
		{
			if (App.user.hero == null)
			{
				App.self.addEventListener(AppEvent.ON_GAME_COMPLETE, onGameComplete);
				return;
			}
			
			//if (!App.user.quests.tutorial && App.user.hero && App.user.mode == User.OWNER) 
			//{
			//	assignPetToUser();
			//}
		}
		
		private function initPetfoods():void
		{
			_petFoods = [];
			var currentItem:Object;
			for (var key:String in App.data.storage)
			{
				currentItem = App.data.storage[key];
				if (currentItem.type == "Petfood")
				{
					if (currentItem.pets.indexOf(sid) >= 0)
					{
						_petFoods.push(int(key));
					}
				}
			}
			
			for (var key1:int = 0; key1 < _petFoods.length; key1++ )
			{
				for (var key2:int = 0; key2 < _petFoods.length; key2++ )
				{
					if ( App.data.storage[_petFoods[key1]].order < App.data.storage[_petFoods[key2]].order)
					{
						var templ:int = _petFoods[key1];
						_petFoods[key1] = _petFoods[key2];
						_petFoods[key2] = templ;
					}
				}
			}
		}
		
		private function onPetReleased(e:AppEvent):void 
		{
			
		}
		
		public function assignPetToUser():void
		{
			this.visible = true;
			App.user.pet = this;
			if(App.user.hero)
				initMove(App.user.hero.cell, App.user.hero.row);
			//updateStatusIcon();
			
			//App.self.addEventListener(AppEvent.USER_FINISHED_JOB, onUserFinishedJob);
			//App.self.addEventListener(AppEvent.USER_FINISED_HARVEST, onUserFinisedHarvest);
		}
		
		override public function initMove(cell:int, row:int, _onPathComplete:Function = null):void 
		{
			updateStatusIcon();
			if (_energy < _minEnergy)
			{
				//super.initMove(PetHouse.Instance.posX, PetHouse.Instance.posZ);
				//alpha = 1;
				//TweenLite.to(this, 1, { alpha:0 } );
				//setTimeout(placeAtHome, 1000);
				return;
			}
			if (finished > App.time)
				return;
			
			super.initMove(cell, row, _onPathComplete);
		}
		
		private function placeAtHome():void
		{
			placing(PetHouse.Instance.posX, 0, PetHouse.Instance.posZ);
			cell = PetHouse.Instance.posX;
			row = PetHouse.Instance.posZ;
			alpha = 1;
		}
		
		private function onUserFinisedHarvest(e:AppEvent):void 
		{
			storageFromField();
		}
		
		private function onUserFinishedJob(e:AppEvent):void 
		{
			storageFromPetEvent(e.params.count);
		}
		
		protected function onGameComplete(e:AppEvent):void 
		{
			//super.onGameComplete(e);
			
			App.self.removeEventListener(AppEvent.ON_GAME_COMPLETE, onGameComplete);
			initWithHero();
		}
		
		override public function get name():String {
			return "Pet";
		}
		
		override public function set name(value:String):void {
			super.name = value;
		}
		
		override public function take():void {}
		override public function free():void {}
		
		public function inViewport():Boolean 
		{
			var globalX:int = this.x * App.map.scaleX + App.map.x;
			var globalY:int = this.y * App.map.scaleY + App.map.y;
			
			if (globalX < -10 || globalX > App.self.stage.stageWidth + 10) 	return false;
			if (globalY < -10 || globalY > App.self.stage.stageHeight + 10) return false;
			
			return true;
		}
		
		
		override public function findPath(start:*, finish:*, _astar:*):Vector.<AStarNodeVO>
		{
			//var needSplice:Boolean = checkOnSplice(start, finish);
			var needSplice:Boolean = false;
			
			if (App.user.quests.tutorial && tm.currentTarget != null)
				tm.currentTarget.shortcutCheck = true;
			
			if (!needSplice)
			{
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
				}	
			}
			else
			{
				placing(finish.position.x, 0, finish.position.y);
				cell = finish.position.x;
				row = finish.position.y;
				alpha = 0;
				TweenLite.to(this, 1, {alpha: 1});
				return null;
			}
			
			return path;
		}
		public function findCollection():void
		{
			//if (_bountiesLeft <= 0)
				//return;
			//framesType = 'dig';
			//framesDirection = WUnit.BACK;
			//_position = true;
			setTimeout(SoundsManager.instance.playSFX, 0, 'bark');
			setTimeout(SoundsManager.instance.playSFX, 600, 'bark');
			//setTimeout(SoundsManager.instance.playSFX, 4100, 'bark');
			//setTimeout(SoundsManager.instance.playSFX, 4700, 'bark');
			//setTimeout(function():void {
				//framesType = Personage.STOP;
			//},5000);
		}
		override public function stockAction(params:Object = null):void 
		{
			super.stockAction(params);
			moveable = false;
			
			if (App.user.pet)
				App.user.pet.putAction();
			
			App.user.pet = this;
		}
		
		override public function buyAction():void 
		{
			super.buyAction();
			moveable = false;
			
			if (App.user.pet)
				App.user.pet.putAction();
			
			App.user.pet = this;
		}
		
		override public function walking():void 
		{
			if (path && pathCounter < path.length) 
			{
				if (_framesType != "walk")
				{
					framesType = "walk";
				}
			}
			else 
			{
				framesType = "stop_pause";
			}
			
			super.walking();	
			
			//updateStatusIcon();
		}
		
		override public function walk(e:Event = null):* 
		{
			if (path.length > 10 && pathCounter > 2 && pathCounter < path.length - 5)
			{
				velocity = velocities[1];
			} 
			else 
			{
				velocity = velocities[0];
			}
			
			return super.walk(e);
		}
		
		override public function onLoop():void 
		{
			super.onLoop();
			
			if (_framesType == ANIMATION_EAT || _framesType == ANIMATION_HAPPY || _framesType == ANIMATION_SAD)
			{
				framesType = WAIT;
			}
		}
		
		override public function goHome(_movePoint:Object = null):void 
		{
			//super.goHome(_movePoint);
		}
		
		override public function set framesType(value:String):void 
		{
			if (value != 'dig')
				trace();
			
			super.framesType = value;
		}
		
		override public function click():Boolean 
		{		
			if (App.user.mode == User.GUEST)
				return false;
				
			if (ordered)
				return false;
				
			if (!touchableInGuest && App.user.mode == User.GUEST)
				return false;
				
			if (info.energy <= 0)
				new CompanionFeedWindow(this).show();
			//if (_bonusCount > 0)
			//{
				//storageEvent(_bonusCount);
				//return true;
			//}
			
			if (bountiesLeft == 0)
			{
				var foods:Array = foodsForPet();
				
				for (var i:int = 0; i < foods.length; i++) 
				{
					if (App.user.stock.count(foods[i].sID) > 0)
					{						
						feed(foods[i].sID);
						ordered = true;
						return true;
					}
				}
				
				openFeedWindow();
			}
			else
			{
				openFeedWindow();
			}
				
			return true;
		}
		
		private function onIconClick(e:MouseEvent):void 
		{		
			if (ordered)
				return;
			
			icon.removeEventListener(MouseEvent.CLICK, onIconClick);
			//click();
		}
		
		private function onMapClick(e:AppEvent):void 
		{
			App.self.removeEventListener(AppEvent.ON_MAP_CLICK, onMapClick);
			hideHungryIcon();
		}
		
		public function openFeedWindow(flag:Boolean = false):void
		{
			//// В туториале нельзя вызывать окно поле обычного кормления
			//if (App.user.quests.tutorial || (!App.user.quests.isFinish(40) && !App.user.quests.isOpen(40)))
			//{
				//new SimpleWindow( {
					//title:		Locale.__e(info.title),
					//text:		Locale.__e('flash:1473244831443'),
					//confirm:	function():void
					//{
						//new QuestsChaptersWindow({find:[40],showFind:true}).show();
					//}
				//}).show();
				//return;
			//}
			//
			//var windowSettings:Object = { 
				//onFeedAction	:feed,
				//petID			:this.sid,
				//buyBttnCaption	:"Buy",
				//glowFeedItems	:flag
			//};
			//
			//if (App.user.pet)
			//{
				//new CompanionFeedWindow(this, windowSettings).show();
				////new JamWindow(windowSettings).show();
			//}
			
			PetHouse.showFeedWindow();
		}
		
		public function foodsForPet():Array
		{
			if (!_foodsForPet)
			{
				_foodsForPet = [];
			
				for each (var foodItem:Object in App.data.storage) 
				{
					if (foodItem.pets && foodItem.pets.indexOf(sid) >= 0)
					{
						_foodsForPet.push(foodItem);
					}
				}
				_foodsForPet.sortOn("count", Array.NUMERIC);
			}
			
			return _foodsForPet;
		}
		
		override public function uninstall():void 
		{
			super.uninstall();
			App.user.pet = null;
		}
		
		
		public function feed(foodID:int, animate:Boolean = true, onComplete:Function = null):void
		{
			if (!App.user.stock.take(foodID,1))
				return;
			var foodItem:Object = App.data.storage[foodID];
			_lastFood = foodItem;
			
			_animateFeeding = animate;
			_onFeedComplete = onComplete;
						
			var objectToSend:Object = {
				ctr:this.type,
				act:"feed",
				uID:App.user.id,
				sID:sid,
				id:id,
				wID:App.user.worldID,
				fID:foodID
			};
			Post.send(objectToSend, feedCallback);
			
			ordered = true;
		}
		
		private function feedCallback(error:int, data:Object, params:Object):void
		{
			if (error)
			{
				Errors.show(error, data);
				return;
			}
			
			if (_lastFood.count)
				_bountiesLeft += _lastFood.count;
			
			App.user.stock.take(_lastFood.ID, 1);
			framesType = ANIMATION_EAT;
			
			updateStatusIcon();
			
			if (_animateFeeding)
				showFeedReaction();
			
			ordered = false;
			
			if (_onFeedComplete != null && _onFeedComplete is Function)
			{
				_onFeedComplete.call();
			}
		}
		
		public function storageFromField(fieldSID:int = 0):void
		{
			if (_bountiesLeft > 0)
			{
				var objectToSend:Object = {
					ctr:this.type,
					act:"storage", 
					uID:App.user.id,
					sID:sid,
					id:id,
					wID:App.user.worldID
				};
				
				if (fieldSID)
					objectToSend.tID = fieldSID;
				else
					return;
				
				Post.send(objectToSend, onStoragefromFieldEvent);
			}
			else
			{
				framesType = ANIMATION_SAD;
				updateStatusIcon();
			}
		}
		
		//private var countRes:int = 0;
		//public function autoEvent(target:Resource, count:int = 1):void 
		//{
			//countRes = count;
			//Post.send( {
				//ctr:this.type,
				//act:'auto',
				//uID:App.user.id,
				//wID:App.user.worldID,
				//sID:this.sid,
				//id:id,
				//rID:target.sid,
				//mID:target.id,
				//count:count
			//}, onAutoEventComplete, { target:target } );
			//
			//_materialID = target.id;
			//_resourceID = target.sid;
		//}
		
		//private function onAutoEventComplete(error:int, data:Object, params:Object):void
		//{
			//if (error) 
			//{
				//Errors.show(error, data);
				//return;
			//}
			//
			//if (params.target)
			//{
				//target = params.target;
				//Resource(target).setCapacity(Resource(target).capacity - countRes);
			//}
			//
			//App.self.setOnTimer(work);
			//goToJob(target);
			//finished = data.finished;
			//_bountiesLeft -= countRes;
		//}
		
		//protected function work():void 
		//{
			//if (App.time > finished) 
			//{
				//App.self.setOffTimer(work);
				//_bonusCount = countRes;
				//countRes = 0;
				//updateStatusIcon();
				//framesType = WAIT;
			//}
			//else
			//{
				//framesType = ANIMATION_WORK;
			//}
		//}
		
		//public function storageEvent(count:int = 1):void 
		//{
			////super.storageEvent(count);
			//Post.send( {
				//ctr:this.type,
				//act:'give',
				//uID:App.user.id,
				//wID:App.user.worldID,
				//sID:this.sid,
				//id:id
			//},storageEventComleteHanlder);
		//}
		
		//private function storageEventComleteHanlder(error:int, data:Object, params:Object):void
		//{
			//if (error) 
			//{
				//Errors.show(error, data);
				//return;
			//}
			//
			//if (data.hasOwnProperty("bonus"))
			//{
				//Treasures.packageBonus(data.bonus, new Point(this.x, this.y));
			//}
			//
			//finished = 0;
			//busy = 0;
			//_bonusCount = 0;
			//_materialID = 0;
			//_resourceID = 0;
			//
			//updateStatusIcon();
		//}
		
		private function onStoragefromFieldEvent(error:int, data:Object, params:Object):void
		{
			if (error)
			{
				Errors.show(error, data);
				return;
			}
			
			if (data.bonus)
			{				
				dropBonus(data.bonus);
			}
			
			updateStatusIcon();
		}
		
		public function storageFromPetEvent(count:int):void 
		{
			if (App.user.mode == User.GUEST || !App.user.stock.check(Stock.ENERGY,count,true))
				return;
			if (_bountiesLeft < count)
				count = _bountiesLeft; 
			if (_bountiesLeft >= 1)
			{
				var objectToSend:Object = {
					ctr:this.type,
					act:"storage", 
					uID:App.user.id,
					sID:sid,
					id:id,
					count:count,
					wID:App.user.worldID
				};
				_bountiesLeft -= count;
				if (_bountiesLeft < 0)
					_bountiesLeft = 0;
				Post.send(objectToSend, onStorageEvent);
			}
			else
			{
				framesType = ANIMATION_SAD;
				updateStatusIcon();
			}
		}
		
		public function onStorageEvent(error:int, data:Object, params:Object):void 
		{			
			if (data.bonus)
			{
				
				for (var ins:String in data.bonus)
				{
					if (App.data.storage[ins].type == 'Material' && App.data.storage[ins].collection)
					{
						findCollection();
						break;
					}
				}
				if (App.user.quests.tutorial) 
				{
					setTimeout(function():void {
						dropBonus(data.bonus);
					}, 1500);
				}
				else
				{
					dropBonus(data.bonus);
				}
			}
			
			updateStatusIcon();
		}
		
		private function dropBonus(bonusObj:Object):void
		{
			Treasures.bonus(bonusObj, new Point(this.x, this.y));
		}
		
		
		private function showFeedReaction():void
		{
			var foodItem:BonusItem = new BonusItem(getFoodID(), 1, true, { target:{x:this.x - App.map.x, y:this.y - App.map.y} , sIDs:[getFoodID()] } );
			
			var stockButton:Button = App.ui.bottomPanel.bttnMainStock;
			var rect:Rectangle = stockButton.getBounds(App.map.mIcon);
			
			var startPoint:Point = new Point();
			
			startPoint.x = rect.x + (rect.width * 0.5);
			startPoint.y = rect.y + (rect.height * 0.5);
			
			foodItem.cashMove(startPoint, App.map.mIcon);
		}
		private function showHappyIcon():void
		{
			//if (!icon)
				//return;
			
			//TweenLite.to(icon, 0.3, { alpha:1 } );
			
			drawIcon(UnitIcon.SMILE_POSITIVE, 2992, _energy);
				
		}
		private function showEnergyIcon(autohide:Boolean = true):void
		{
			//if (!icon)
				//return;
				
			//TweenLite.to(icon, 0.3, { alpha:1 } );
				
			drawIcon('petEnergyIcon', 2992, _energy);
			icon.drawText(String(_energy));
				
			//icon.mouseEnabled = true;
			//icon.mouseChildren = true;
		}
		
		private function hideHungryIcon():void
		{
			if (!icon)
				return;
				
			//TweenLite.to(icon, 0.3, { alpha:0, onComplete:onIconHidden } );
		}
		
		private function onIconHidden():void
		{
			if (!icon)
				return;
				
			icon.mouseEnabled = false;
			icon.mouseChildren = false;
		}
		
		private function updateStatusIcon():void
		{
			if (energy < minEnergy)
			{
				clearIcon();
				showEnergyIcon();
			}
			else
			{
				clearIcon();
				showHappyIcon();
			}
			return;
		}
		
		
		private function getFoodID():int
		{
			if (!_foodID)
			{
				var item:Object;
				for (var key:String in App.data.storage) 
				{
					item = App.data.storage[key];
					if (item.type == "Petfood")
					{
						if (item.pets.indexOf(sid) >= 0)
						{
							_foodID = int(key);
							return _foodID;
						}
					}
				}
			}
			return _foodID;
		}
		
		public function get bountiesLeft():uint 
		{
			return _bountiesLeft;
		}
		
		public function tips():void 
		{
			tip = function():Object 
			{
				var result:Object;
				if (finished > App.time)
				{
					result = {
						title: info.title,
						text: (Locale.__e("flash:1393581955601") + " " + TimeConverter.timeToStr(finished - App.time)),
						timer:true
					}
				}
				else
				{
					result = {
						title: info.title,
						text: info.description
					}
				}
				return result;
			};
		}
		
		override public function get visible():Boolean 
		{
			return super.visible;
		}
		
		override public function set visible(value:Boolean):void 
		{
			super.visible = value;
			if (icon)
				icon.visible = value;
		}
		
		override public function set state(value:uint):void 
		{
			if (state == value)
				return;
			
			super.state = value;
			
			if (bountiesLeft > 0)
				return;
			
			updateStatusIcon();
			
			if (state == TOCHED && icon)
			{
				showEnergyIcon(false);
				icon.mouseEnabled = true;
				icon.mouseChildren = true;
				icon.addEventListener(MouseEvent.CLICK, onIconClick);
				App.self.addEventListener(AppEvent.ON_MAP_CLICK, onMapClick);
			}
		}
		
		private function placeAtUser():void
		{
			placing(App.user.hero.cell + 2, 0, App.user.hero.row + 2);
			cell = App.user.hero.cell + 2;
			row = App.user.hero.row + 2;
		}
		
		public function get energy():int 
		{
			return _energy;
		}
		
		public function set energy(value:int):void 
		{
			clearIcon();
			if (value >= _minEnergy && _energy < _minEnergy)
			{
				if (App.user.hero)
				{
					alpha = 0;
					TweenLite.to(this, 1, {alpha:1});
					setTimeout(placeAtUser, 500);
					_energy = value;
					updateStatusIcon();
					return;
				}
			}
			_energy = value;
			if (_energy < 0)
				_energy = 0;
			
			if (_energy < _minEnergy)
			{
				showEnergyIcon();
				alpha = 1;
				
				TweenLite.to(this, 1, { alpha:0 } );
				setTimeout(placeAtHome, 1000);
			}
			else
			{
				showHappyIcon();
			}
		}
		
		public function get minEnergy():int 
		{
			return _minEnergy;
		}
		
		public function set minEnergy(value:int):void 
		{
			_minEnergy = value;
		}
		
		override public function putAction():void 
		{
			if (_bountiesLeft > 0)
			{
				var msgWindow:SimpleWindow = new SimpleWindow({text:Locale.__e("flash:1447167158326")});
				msgWindow.show();
				return;
			}
			
			var bonusItem:BonusItem = new BonusItem(sid, 1, false);
			bonusItem.x = this.x;
			bonusItem.y = this.y;
			App.map.mTreasure.addChild(bonusItem);
			bonusItem.cash();
			
			super.putAction();
		}
		public static const _radiusPosition:int = 4;
		public static function getPositionForPet(initX:int, initZ:int):Point {
			var resultPoint:Point;
			var initNode:AStarNodeVO = App.map._aStarNodes[initX][initZ];
			var node:AStarNodeVO;
			
			var openPositions:Vector.<Point> = new Vector.<Point>();
			
			for (var posX:int = initX - _radiusPosition; posX <= initX + _radiusPosition; posX += 1) {
				for (var posZ:int = initZ - _radiusPosition; posZ <= initZ + _radiusPosition; posZ += 1) {
					if (posX == initX && posZ == initZ) {
						continue;
					}
					
					var newX:int = posX;
					var newZ:int = posZ;
					
					if (newX < 0) newX = 0;
					if (newZ < 0) newZ = 0;
					if (newX > Map.cells - 1) newX = Map.cells - 1;
					if (newZ > Map.rows - 1) newZ = Map.rows - 1;
					
					node = App.map._aStarNodes[newX][newZ];
					if (initNode.open && !initNode.isWall && node.open && !node.isWall) {
						openPositions.push(new Point(newX, newZ));
					}
				}
			}
			
			if (openPositions.length > 0) {
				resultPoint = openPositions[int(Math.random() * openPositions.length)];
			}
			
			if (!resultPoint) {
				resultPoint = new Point(App.user.pet.coords.x, App.user.pet.coords.z);
			}
			return resultPoint;
		}
	}
}