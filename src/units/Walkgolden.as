package units 
{
	import com.greensock.TweenLite;
	import core.IsoConvert;
	import core.Load;
	import core.Numbers;
	import core.Post;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	import ui.Cursor;
	import ui.Hints;
	import ui.UnitIcon;
	import ui.UserInterface;
	import wins.BuyTwoItemsWindow;
	import wins.PurchaseWindow;
	import wins.SpeedWindow;
	import wins.StockWindow;
	/**
	 * ...
	 * @author ...
	 */
	public class Walkgolden extends WorkerUnit
	{
		public var icount:int = 0;
		public var level:uint = 0;
		public var crafted:uint = 0;
		public var started:int = 0;
		public var crafting:Boolean = false;
		public var hasProduct:Boolean = false;
		
		public var fID:int = 0;
		
		private var _tribute:Boolean = false;
		public var capacity:int = 0;
		
		public static var delay:uint = 50;
		public static var initTime:uint = 0;
		
		private var dX:Number = 0;
		private var dY:Number = 0;
		private var amplitude:Number = 40;
		private var altitude:uint = 400;
		
		private var viewportX:int;
		private var viewportY:int;
		
		private var vittes:Number;
		private var live:Boolean = false;
		
		private var canboost:Boolean = true;
		protected var homeCoords:Object;
		
		private var hasMainParent:Tribute;
		private var hasMainChild:Tribute;
		
		public var isThief:Boolean = false;
		public var shouldBeRemoved:Boolean = false;
		public var creationTime:int = 0;
		
		public function Walkgolden(object:Object) 
		{
			if (sid == 3174)
				trace();
			crafted = object.crafted || 0;
			icount = object.icount || 1;
			creationTime = object.created;
			delete object.created;
			hasMainParent = object.hasMainParent;
			crafting = true;
			
			if (object.capacity)
				capacity = object.capacity;
			
			if (object.hasOwnProperty('level'))
				level = object.level;
			//else
				//addEventListener(AppEvent.AFTER_BUY, onAfterBuy);
			
				
			super(object);
			
			isThief = ThiefGoldenManager.isThief(sid);
			
			moveable = true;
			stockable = true;
			multiple = true;
			
			if (sid == 629 || sid == 1447 || sid == 1251 || sid == 1091 || sid == 1796) {
				moveable = false;
				removable = true;
				stockable = false;
			}
			
			if (sid == 909 || sid == 360 || sid == 2344 || sid == 2288 || sid == 2372) {
				stockable = false;
				removable = false;
			}
			
			tip = function():Object {
				
				var subText:String = Locale.__e('flash:1414400030281', [info.capacity - capacity]);
				if (!info.capacity || info.capacity == 0)
					subText = '';
				
				var normalMaterials:Array = [];
				if (_tribute) {
					normalMaterials = [];
					for (var rid:* in info.require) {
						if (App.data.storage.hasOwnProperty(rid) && App.data.storage[rid].mtype != 3) {
							normalMaterials.push(rid);
						}
					}
					
					if (App.user.mode == User.GUEST) {
						rid = 6;
						normalMaterials = [rid];
					}
					
					if (normalMaterials.length > 0) {
						var bitmaps:Array = [];
						var counts:Array = [];
						for (var i:int = 0; i < normalMaterials.length; i++) {
							counts.push(info.require[normalMaterials[i]]);
							var bitmap:Bitmap = new Bitmap(new BitmapData(50,50,true,0));
							Load.loading(Config.getIcon(App.data.storage[normalMaterials[i]].type, App.data.storage[normalMaterials[i]].preview), function(data:Bitmap):void {
								bitmap.bitmapData.draw(data, new Matrix(0.5, 0, 0, 0.5));
								bitmaps.push(bitmap);
							});
						}
						
						if (bitmaps.length > 0) {
							return {
								title:info.title,
								text:info.description,//Locale.__e("flash:1382952379966") + '\n' + subText,
								desc:Locale.__e('flash:1383042563368'),
								icons:bitmaps,
								iconScale:0.5,
								counts:(App.user.mode == User.GUEST) ? [1] : counts
							};
						} else {
							return null;
						}
					}
					
					return {
						title:info.title,
						text:Locale.__e("flash:1382952379966") + '\n' + subText
					};
				}
				
				if (info.hasOwnProperty('require')) {
					normalMaterials = [];
					for (var reqid:* in info.require) {
						if (App.data.storage.hasOwnProperty(reqid) && App.data.storage[reqid].mtype != 3) {
							normalMaterials.push(reqid);
						}
					}
					
					if (App.user.mode == User.GUEST) {
						reqid = 6;
						normalMaterials = [reqid];
					}
					
					if (normalMaterials.length > 0) {
						var bmp:Bitmap = new Bitmap(new BitmapData(50,50,true,0));
						Load.loading(Config.getIcon(App.data.storage[reqid].type, App.data.storage[reqid].preview), function(data:Bitmap):void {
							bmp.bitmapData.draw(data, new Matrix(0.5, 0, 0, 0.5));
						});
						
						return {
							title:info.title,
							text:sid == 360 ? Locale.__e("flash:1430991777391")  + '\n' + TimeConverter.timeToStr(crafted - App.time) + subText : Locale.__e("flash:1382952379839", [TimeConverter.timeToStr(crafted - App.time)]) + '\n' + subText,
							desc:Locale.__e('flash:1383042563368'),
							icon:bmp,
							iconScale:0.6,
							count:(App.user.mode == User.GUEST) ? 1 : info.require[reqid],
							timer:true
						};
					}
				}
				
				return {
					title:info.title,
					text: sid == 360 ? Locale.__e("flash:1430991777391")  + '\n' + TimeConverter.timeToStr(crafted - App.time) + subText : Locale.__e("flash:1382952379839", [TimeConverter.timeToStr(crafted - App.time)]) + '\n' + subText,
					timer:true
				};
			}	
			
			App.self.addEventListener(AppEvent.ON_MOUSE_UP, onUp);
			shortcutDistance = 50;
			homeRadius = 4;
			//if (sid == 821) homeRadius = 20;
			
			if (object.buy || object.fromStock) {
				//showBorders();
			}
			
			if (info.hasOwnProperty('canboost') && info.canboost == 0) {
				canboost = false;
			}
			
			beginCraft(0, crafted);
			
			if (formed && Map.ready)
				goHome();
			else
				App.self.addEventListener(AppEvent.ON_MAP_COMPLETE, onMapComplete);
			
		}
		
		override public function onLoad(data:*):void {
			/*if (App.user.mode == User.OWNER && App.user.quests.data.hasOwnProperty(516) && App.user.quests.data[516].finished != 0 && sid == 1447) {
				removable = true;
				onApplyRemove();
			} else {*/
				super.onLoad(data);
			//}
		}
		
		override public function onDown():void 
		{
			/*if (App.user.mode == User.OWNER) {
				if (isMove) {
					clearTimeout(intervalMove);
					isMove = false;
					isMoveThis = false;
				}else{
					var that:Walkgolden = this;
					intervalMove = setTimeout(function():void {
						isMove = true;
						isMoveThis = true
						that.move = true;
						App.map.moved = that;
					}, 200);
				}
			}*/
		}
		
		/*override public function take():void {
			
		}*/
		
		private var isMoveThis:Boolean = false;
		public static var isMove:Boolean = false;
		private var intervalMove:int;
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
		
		private function onMapComplete(e:AppEvent):void {
			App.self.removeEventListener(AppEvent.ON_MAP_COMPLETE, onMapComplete);
			if (formed)
				goHome();
		}
		
		override public function goHome(_movePoint:Object = null):void {
			if (info.moveable == 1) {
				if (sid == 1447 && homeCoords == null) {
					var home:Array = Map.findUnits([1448]);
					if (home.length > 0 ) homeCoords = home[0];
				}
				clearTimeout(timer);
				if (!walkable) return;
				
				if (_framesType != Personage.STOP) {
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
				}else if (homeCoords != null) { 
					place = findPlaceNearTarget({info:homeCoords.info, coords:homeCoords.coords}, homeRadius);
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
		}
		
		override protected function onBuyAction(error:int, data:Object, params:Object):void {
			if (error) {
				Errors.show(error, data);
				return;
			}
			
			if (contLight) {
				removeChild(contLight);
				contLight = null;
			}
			
			this.cell = coords.x 
			this.row = coords.z;
			
			movePoint.x = coords.x;
			movePoint.y = coords.z;
			
			this.id = data.id;
			
			started = App.time;
			
			creationTime = App.time;
			created = App.time + App.data.storage[sid].time;
			crafted = App.time + App.data.storage[sid].time;
			
			beginCraft(0, created);
			
			tribute = false;
			hasProduct = false;
			
			if (started > 0)
				goHome();
				
			// Регистрация покупки объекта с полем gcount
			if (Storage.isShopLimited(sid)) {
				Storage.shopLimitBuy(sid);
				App.user.updateActions();
				App.ui.salesPanel.updateSales();
				App.user.storageStore('shopLimit', Storage.shopLimitList, true);
			}
			if (isThief)
			{
				makeOpen();
				
				if (shouldBeRemoved)
				{
					this.isThief = false;
					this.visible = false;
					this.open = false;
					this.clickable = false;
					this.touchable = false;
					this.clearIcon();
					this.remove();
					shouldBeRemoved = false;
				}
			}
		}
		
		override public function stockAction(params:Object = null):void {
			
			if (!App.user.stock.check(sid)) {
				//TODO показываем окно с ообщением, что на складе уже нет ничего
				return;
			}else if (!World.canBuilding(sid)) {
				uninstall();
				return;
			}
			
			App.user.stock.take(sid, 1);
			
			if (params && params.coords) {
				coords.x = params.coords.x;
				coords.z = params.coords.z;
			}
			
			Post.send( {
				ctr:this.type,
				act:'stock',
				uID:App.user.id,
				wID:App.user.worldID,
				sID:this.sid,
				x:coords.x,
				z:coords.z
			}, onStockAction);
		}
		
		override protected function onStockAction(error:int, data:Object, params:Object):void {
			if (error) {
				Errors.show(error, data);
				return;
			}
			
			if (contLight) {
				removeChild(contLight);
				contLight = null;
			}
			
			this.id = data.id;
			started = App.time;
			
			this.cell = coords.x; 
			this.row = coords.z;
			
			movePoint.x = coords.x;
			movePoint.y = coords.z;
			
			created = App.time + App.data.storage[sid].time;
			crafted = 0;// App.time + App.data.storage[sid].time;
			
			beginCraft(0, created);
			
			moveable = true;
			
			tribute = false;
			
			hasProduct = false;
			open = true;
			
			showIcon();
			
			goHome();
		}
		
		override public function onMoveAction(error:int, data:Object, params:Object):void {
			
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
			
			if (started > 0)
				goHome();
				
			clearTimeout(intervalMove);
			isMove = false;
			isMoveThis = false
		}
		
		override public function makeOpen():void
		{
			open = true;
			clickable = true;
			touchable = true;
			visible = true;
			
			showIcon();
		}
		
		protected var wasClick:Boolean = false;
		override public function click():Boolean 
		{
			clearTimeout(intervalMove);
			
			if(isMoveThis){
				this.move = false;
				App.map.moved = null;
				isMove = false;
				isMoveThis = false
				return true;
			}
			
			Cursor.accelerator = false;
			if (StockWindow.accelMaterial != 0 && crafted > 0 && crafted > App.time && sid != 360 && sid != 909) {
				onBoostMaterialEvent(0, StockWindow.accelMaterial);
				if (StockWindow.accelUnits) {
					for each (var unit:* in StockWindow.accelUnits) {
						unit.hideGlowing();
					}
					StockWindow.accelUnits = [];
					StockWindow.accelMaterial = 0;
				}
				return true;
			}
			
			if (Mhelper.waitForTarget && (!info.hasOwnProperty('capacity') || info.capacity == 0) && !lock/* && canboost*/) {
				Mhelper.addTarget(this);
				state = TOCHED;
				lock = true;
				return true;
			}
			
			if (wasClick) return false;
			
			if (App.user.mode == User.GUEST) {
				return true;
			}
			
			if (sid != 360 && sid != 909) if (!isReadyToWork()) return true;
			if (isProduct()) return true;
			
			return true;
		}
		
		//ускорялка для зданий за материалы
		public function onBoostMaterialEvent(count:int = 0, material:int = 0):void {
			var that:* = this;
			if (!App.user.stock.take(Stock.FANT, count)) return;
				
				//App.self.setOffTimer(production);
				App.user.stock.take(material, 1);
				//crafted = App.time;
				//onProductionComplete();
				
				//cantClick = true;
				
				Post.send({
					ctr:this.type,
					act:'boost',
					uID:App.user.id,
					id:this.id,
					wID:App.user.worldID,
					sID:this.sid,
					m:material
				}, function(error:*, data:*, params:*):void {
					
					if (error) {
						Errors.show(error, data);
						return;
					}
					
					crafted = data.crafted;
					
					if (crafted <= App.time) {
						App.self.setOffTimer(work);
						tribute = true;
						onProductionComplete();
					}
					
					SoundsManager.instance.playSFX('bonusBoost');
				});
		}
		
		public function isReadyToWork():Boolean
		{
			if (!canboost) return true;
			if (crafted > App.time) { 
				new SpeedWindow( {
					title:info.title,
					target:this,
					priceSpeed:info.skip,
					info:info,
					finishTime:crafted,
					totalTime:App.data.storage[sid].time,
					doBoost:onBoostEvent,
					btmdIconType:App.data.storage[sid].type,
					btmdIcon:App.data.storage[sid].preview,
					count:icount
				}).show();
				return false;
				
			}
			return true;
		}
		
		public function onBoostEvent(count:int = 0):void {
			
			if (App.user.stock.take(Stock.FANT, count)){
				
				started = App.time - info.time;
				crafted = App.time - info.time;
				
				var that:Walkgolden = this;
				
				open = true;
				onProductionComplete();
				
				Post.send({
					ctr:this.type,
					act:'boost',
					uID:App.user.id,
					id:this.id,
					wID:App.user.worldID,
					sID:this.sid
				}, function(error:*, data:*, params:*):void {
					
					if (!error && data) {
						started = data.started;
						App.ui.flashGlowing(that);
					}
					
				});
			}
		}
		
		public function beginCraft(fID:uint, crafted:uint):void
		{
			this.fID = fID;
			this.crafted = crafted;
			hasProduct = false;
			crafting = true;
			
			App.self.setOffTimer(work);
			App.self.setOnTimer(work);
		}
		
		public function setStarted(started:uint):void {
			tribute = false;
			this.started = started;
			App.self.setOnTimer(work);
		}
		
		//public function onAfterBuy(e:AppEvent):void
		//{
			//if(textures != null){
				//var levelData:Object = textures.sprites[this.level];
				//removeEventListener(AppEvent.AFTER_BUY, onAfterBuy);
				//App.ui.flashGlowing(this, 0xFFF000);
			//}
			//
			//SoundsManager.instance.playSFX('building_1');
			//
			//started = App.time;
			//App.self.setOnTimer(work);
			//crafting = true;
			//goHome();
		//}
		
		public function work():void
		{
			if (App.time >= crafted)
			{
				App.self.setOffTimer(work);
				tribute = true;
				onProductionComplete();
			}
		}
		
		public function onProductionComplete():void
		{
			hasProduct = true;
			crafting = false;
			crafted = 0;
			showIcon();
		}
		
		public function showIcon():void
		{
			if (!formed || !open) return;
			
			if (sid == 1447 || sid == 1796) return;
			
			if (App.user.mode == User.OWNER) {
				if (hasProduct) {
					var icPic:int  = 2;
					if (sid == 909) icPic = Stock.FANT;
					if (sid == 1092) icPic = 1109;
					drawIcon(UnitIcon.REWARD, icPic, 1, {
						glow:		true,
						clickable:	(App.data.storage[App.user.worldID].size == World.MINI)?false:true
					});
				}else {
					clearIcon();
				}
			}
		}
		
		public function getPrice():Object
		{
			var price:Object = { }
			price[Stock.FANTASY] = 0;
			return price;
		}
		
		public function isProduct(value:int = 0):Boolean
		{
			if (hasProduct)
			{
				//var price:Object = getPrice();
						
				//if (!App.user.stock.checkAll(price))	return true;
				
				storageEvent();
				
				ordered = false;
				
				return true; 
			}
			return false;
		}
		
		public function storageEvent(value:int = 0):void
		{
			if (App.user.mode == User.OWNER) {
				
				if (info.hasOwnProperty('require')) {
					var cnt:int = 0;
					for (var sID:* in info.require) {
						cnt = info.require[sID];
						break;
					}
					if (!sID || sID == 0) return;
					var price:Object = info.require;
					var s:*;
					for (s in price) {
						break;
					}
					
					if (!App.user.stock.takeAll(price, true))	{
						if (sid == 1796) {
							new BuyTwoItemsWindow( {
								popup:true,
								price:price,
								callback:storageEvent
							}).show();
							return;
						}
						var content:Array = PurchaseWindow.createContent("Energy", { view:App.data.storage[s].view } );
						if (Numbers.countProps(price) > 1) {
							content = [];
							var i:int = 0;
							for (s in price) {
								for (var eid:* in App.data.storage) {
									var object:Object = App.data.storage[eid];
									if (object.type != 'Energy') continue;
									
									if (object.view == App.data.storage[s].view ) {
										content.push( { sID:eid, order:object.order } );
										i++;
									}
								}
							}
						}
						new PurchaseWindow( {
							width:595,
							itemsOnPage:content.length,
							content:content,
							title:Locale.__e("flash:1382952379751"),
							fontBorderColor:0xd49848,
							shadowColor:0x553c2f,
							shadowSize:4,
							description:Locale.__e("flash:1382952379757"),
							popup: true,
							callback:function(sID:int):void {
								var object:* = App.data.storage[sID];
								App.user.stock.add(sID, object);
							}
						}).show();
						return;
					}
					
					for (var sD:* in info.require) {
						//cnt = info.require[sID];
						Hints.minus(sD, info.require[sD], new Point(this.x * App.map.scaleX + App.map.x, this.y * App.map.scaleY + App.map.y), true);
					}
				}
				wasClick = true;
				Post.send({
					ctr:this.type,
					act:'storage',
					uID:App.user.id,
					id:this.id,
					wID:App.user.worldID,
					sID:this.sid
				}, onStorageEvent);
			}
				
			tribute = false;
		}
		
		public function onStorageEvent(error:int, data:Object, params:Object):void {
			wasClick = false;
			if (error)
			{
				Errors.show(error, data);
				return;
			}
			
			ordered = false;
			crafted = App.time + App.data.storage[sid].time;
			
			if(data.hasOwnProperty('started')){
				App.self.setOnTimer(work);
				//beginAnimation();
			}
			
			Treasures.bonus(data.bonus, new Point(this.x, this.y));
			SoundsManager.instance.playSFX('bonus');
			
			tribute = false;
			hasProduct = false;
			
			clearIcon();
			
			capacity++;
			
			if (info.hasOwnProperty('capacity') && info.capacity > 0 && info.capacity <= capacity) {
				if (isThief)
				{
					ThiefGoldenManager.onTakeBonuse(this);
				} else
				{
					uninstall();
				}
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
			sp.graphics.drawRoundRect(0, 0,400,400,400,400);
			sp.rotation = 45;
			sp.alpha = 0.5;
			
			cont.addChild(sp);
			cont.height = 400 * 0.7;
			
			contLight.addChild(cont);
			
			contLight.y = -contLight.height / 2;
			
			addChildAt(contLight, 0);
		}
		
		override public function previousPlace():void {
			super.previousPlace();
			
			if (contLight) {
				removeChild(contLight);
				contLight = null;
			}
		}
		
		protected var _lock:Boolean = false;
		public function set lock (item:Boolean):void {
			_lock = item;
			if (item)
				removable = false;
			else
				removable = true;
				
		}
		public function get lock():Boolean {
			return _lock;
		}
		
		override public function free():void {
			//showBorders();
			super.free();
		}
		
		override public function uninstall():void 
		{
			App.self.removeEventListener(AppEvent.ON_MOUSE_UP, onUp);
			
			super.uninstall();
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
		
		override public function set touch(touch:Boolean):void
		{
			if (App.user.mode == User.GUEST)
				return;
			
			super.touch = touch;
		}
		
		public function set tribute(value:Boolean):void {
			_tribute = value;
		}
		
		
		override public function update(e:Event = null):void 
		{
			super.update(e);
			
			if(isThief)
				ThiefGoldenManager.checkExpire(this);
		}
		
		override public function onRemoveAction(error:int, data:Object, params:Object):void 
		{
			super.onRemoveAction(error, data, params);
			
			ThiefGoldenManager.checkAndSpawnDelayed();
		}
		
		//private var fposition:Object = null;
		//private function startFly():void
		//{
			////App.map.mTreasure.addChild(this);
			//live = true;
			//ay -= 0;
			////ay -= altitude;
			//
			//shadow = new Bitmap(UserInterface.textures.shadow);
			//addChildAt(shadow, 0);
			//shadow.x = - shadow.width / 2;
			//shadow.y = - 4;
			//shadow.alpha = 0.5;
			//
			//amplitude 	+= int(Math.random() * 40 - 20);
			//
			//start = IsoConvert.isoToScreen(coords.x, coords.z, true);
			//fposition = getRandomPlace();
			//finish = IsoConvert.isoToScreen(fposition.x, fposition.z, true);
			//
			//_altitude = altitude;
			//vittes = 0.0030;
			//
			//App.self.setOnEnterFrame(flying);
		//}
		//
		//private var _altitude:int = 0;
		//private var dAlt:uint = 2;
		//private function flying(e:Event = null):void
		//{
			//t += vittes * (32 / App.self.fps);
			//
			///*framesType = 'fly';
			//if (start.y < finish.y){ 
				//if (framesDirection != FACE) frame = 0;
				//framesDirection = FACE; 
			//}else {
				//if (framesDirection != BACK) frame = 0;
				//framesDirection = BACK;
			//}
			//
			//if (start.x < finish.x){ 
				//if (framesFlip != RIGHT){
					//frame = 0;
					//if(bitmap.scaleX > 0){
						//bitmap.scaleX = -1;
						//sign = -1;
					//}
				//}
				//framesFlip = RIGHT;
			//}else {
				//if (framesFlip != LEFT){
					//frame = 0;
					//if(bitmap.scaleX<0){
						//bitmap.scaleX = 1;
						//sign = 1;
					//}
				//}
				//framesFlip = LEFT;
			//}*/
//
			//if (t >= 1 && live)
			//{
				////App.map.mTreasure.removeChild(this);
				//App.self.setOffEnterFrame(flying);
				//framesType = 'take_off';
				//this.movePoint.x = fposition.x;
				//this.movePoint.y = fposition.z;
				//
				//this.cell = fposition.x;
				//this.row = fposition.z;
				//goHome();
				////live = false;
				////TweenLite.to(this, 0.5, { alpha:0, onComplete:uninstall } );
			//}
			//
			//var nextX:Number = int(start.x + (finish.x - start.x) * t);
			//var nextY:Number = int(start.y + (finish.y - start.y) * t);
			//
			//x = nextX;
			//y = nextY;
			//
			//if (_altitude < altitude)
				//_altitude += dAlt;
		//}
		//
		//override public function initMove(cell:int, row:int, _onPathComplete:Function = null):void {
			//if (sid != 821) {
				//super.initMove(cell, row, _onPathComplete);
				//return;
			//}
			//if (this.cell != cell || this.row != row) {
				//if (Math.random() < 0.3) {
					//framesType = 'take_on';
				//}
				//else {
					//framesType = 'walk';
					//super.initMove(cell, row, _onPathComplete);
				//}
			//}
		//}
		//
		//override public function getRandomPlace():Object 
		//{
			//var i:Boolean = true;
			//while (i) {
				////i--;
				//var place:Object = nextPlace();
				//if (App.map._aStarNodes[place.x][place.z].isWall || App.map._aStarNodes[place.x][place.z].object != null) 
					//continue;
				//if (App.map._aStarNodes[place.x][place.z].open == false)
					//continue;
				//i = false;
			//}
			//
			//return {
				//x:place.x,
				//z:place.z
			//}
			//
			//function nextPlace():Object {
				//var randomX:int = int(Math.random() * Map.cells);
				//var randomZ:int = int(Math.random() * Map.rows);
				//return {
					//x:randomX,
					//z:randomZ
				//}
			//}
		//}
		//
		//override public function update(e:Event = null):void {
			//
			//if (_walk) {
				//
				//if (start.y < finish.y){ 
					//if (framesDirection != FACE) frame = 0;
					//framesDirection = FACE; 
				//}else {
					//if (framesDirection != BACK) frame = 0;
					//framesDirection = BACK;
				//}
				//
				//if (start.x < finish.x){ 
					//if (framesFlip != RIGHT){
						//frame = 0;
						//if(bitmap.scaleX>0){
							//bitmap.scaleX = -1;
							//sign = -1;
						//}
					//}
					//framesFlip = RIGHT;
				//}else {
					//if (framesFlip != LEFT){
						//frame = 0;
						//if(bitmap.scaleX<0){
							//bitmap.scaleX = 1;
							//sign = 1;
						//}
					//}
					//framesFlip = LEFT;
				//}	
				//
			//}else {
				//if (!_position)	{
					//framesDirection = FACE;
				//}
			//}
			//var anim:Object = textures.animation.animations;
		//
			//var cadr:uint 			= anim[_framesType].chain[frame];
			//
			//if (anim[_framesType].frames[framesDirection] == undefined) {
				//framesDirection = 0;
			//}
			//var lt:int = anim[_framesType].frames[framesDirection].length;
			//cadr = cadr >= lt?lt - 1:cadr;
			//var frameObject:Object 	= anim[_framesType].frames[framesDirection][cadr];
			//if (hasMultipleAnimation) multipleAnimation(cadr);
			//
			//if (frameObject.bmd) bitmap.bitmapData = frameObject.bmd;
			//bitmap.smoothing = true;
			//bitmap.x = (frameObject.ox + ax) * sign;
			//bitmap.y = (frameObject.oy + ay);
			//
			//frame++;
			//if (frame >= anim[_framesType].chain.length) {
				//this.dispatchEvent(new Event(Event.COMPLETE));
				//frame = 0;
				//onLoop();
			//}
			//
			//if (icon) iconSetPosition();
		//}
		//
		//override public function onLoop():void 
		//{
			//if (sid != 821) {
				//super.onLoop();
				//return;
			//}
			//
			//if (_framesType == 'take_on') {
				//framesType = 'fly_breath';
				//startFly();
			//}
			//if (_framesType == 'take_off') {
				//framesType = 'walk';
			//}
		//}
		
	}

}