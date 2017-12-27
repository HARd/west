package units
{
	import astar.AStarNodeVO;
	import com.greensock.TweenLite;
	import com.greensock.TweenMax;
	import core.Load;
	import core.Post;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.utils.clearTimeout;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;
	import ui.Cursor;
	import ui.Hints;
	import ui.SystemPanel;
	import wins.BuyItemWindow;
	import wins.PurchaseWindow;
	import wins.SimpleWindow;
	import wins.StockWindow;
	import wins.Window;
	import wins.WindowEvent;
	
	public class Resource extends Unit{
		
		public var capacity:uint;
	//	public var canUseCapacity:uint;
		//public var reserved:int = 0;
		public var visited:uint = 0;
		
		public var countLabel:TextField;
		public var title:TextField;
		public var resourceIcon:Bitmap = new Bitmap(null, "auto", true);
		public var popupBalance:Sprite;
		public var glowed:Boolean = false;
		public var damage:int = 0;
		
		private var glowInterval:int;
		public var targetWorker:*;
		
		public var garden:Garden;
		public var isOnGarden:Boolean = false;
		public var inx:int;
		
		// Захватчик
		public var captured:int = 0;
		public var capturer:int = 0;
		
		// Для золотого песка
		public static var golden_hidden:Array = [66, 67, 68, 69, 70, 71, 72, 65];
		public static var golden:Array = [349, 350, 351, 352, 353, 354, 355, 356];
		public static var goldenOnMap:Array = [];
		public static var numOfRes:Array = [];
		
		public var end:int = 0;
		
		public function Resource(object:Object)
		{
			layer = Map.LAYER_SORT;
			
			if (object.hasOwnProperty('index')) {
				inx = object.index;
			}
			super(object);
			
			if(info.outs){
				for (var _sid:* in info.outs) {
					info['out'] = _sid;
					if (App.data.storage[_sid].mtype != 3) break;
				}
			}else {
				info['out'] = Stock.COINS;
			}
			
			if (object.hasOwnProperty('capacity')) 
			{
				capacity = object.capacity;
				if (capacity <= 0 && App.user.mode == User.OWNER && info.type != 'Exresource')
				{
					info['ask'] = false;
					remove();
					return;
				}
			}
			else
			{
				capacity = info.capacity;
			}	
			
			if (App.user.mode == User.GUEST) {				
				if (golden_hidden.indexOf(sid) != -1) {
					if (!Map.ready && App.map._aStarNodes[coords.x][coords.z].open)
						visible = false;
				}
				
				if (golden.indexOf(sid) == -1) 
				{
					touchable = false;
					clickable = false;
				}
				
				capacity = 1;
				
				if (golden_hidden.indexOf(sid) == -1 && golden.indexOf(sid) == -1) {
					touchable = false;
					touchableInGuest = false;
				}
			}
			
			moveable = false;	
			multiple = true;
			rotateable = true;
			removable = true;
			
			if(!formed)
				moveable = true;
				
			if (Config.admin) {
				removable = true;
				moveable = true;
				
				multiple = true;
			}
			
			if (object.hasOwnProperty('moveable'))
				moveable = object.moveable;
				
			if (object.hasOwnProperty('multiple'))
				multiple = object.multiple;
				
			if (object.hasOwnProperty('end')){
				end = object.end;
				
				if (end > App.time)
					App.self.setOnTimer(checkGarden);
			}
			
			tip = function():Object {
				if (end != 0) {
					if (end > App.time) {
						return {
							title:info.title,
							text:Locale.__e('flash:1444636170940', TimeConverter.timeToStr(end - App.time)),
							timer:true
						}
					}else {
						return {
							title:info.title,
							text:Locale.__e('flash:1445959408602')
						}
					}
				}
				
				if (info.hasOwnProperty('require')) {
					var normalMaterials:Array = [];
					for (var rid:* in info.require) {
						// Если не системный
						if (App.data.storage.hasOwnProperty(rid) && App.data.storage[rid].mtype != 3) {
							normalMaterials.push(rid);
						}
						if (sid == 1928 || sid == 1953 || sid == 2643 || App.user.worldID == Travel.SAN_MANSANO) {
							normalMaterials.push(rid);
						}
					}
					
					if (App.user.mode == User.GUEST) {
						rid = 6;
						normalMaterials = [rid];
					}
					
					if (normalMaterials.length > 0) {
						var bitmap:Bitmap = new Bitmap(new BitmapData(50,50,true,0));
						Load.loading(Config.getIcon(App.data.storage[rid].type, App.data.storage[rid].preview), function(data:Bitmap):void {
							bitmap.bitmapData.draw(data, new Matrix(0.5, 0, 0, 0.5));
						});
						
						return {
							title:info.title,
							text:info.description,
							desc:Locale.__e('flash:1383042563368'),
							icon:bitmap,
							iconScale:0.6,
							count:(App.user.mode == User.GUEST) ? 1 : info.require[rid]
						};
					}
				}
				
				return {
					title:info.title,
					text:info.description
				};
			};
			
			Load.loading(Config.getSwf(type, info.view), onLoad);
			if ([967, 968, 969, 1245, 1246, 1247].indexOf(int(sid)) != -1 ) {
				Load.loading(Config.getImage('content', 'icon_treasure'), onOutLoad);
			}else if ([1738].indexOf(int(sid)) != -1 ) {
				Load.loading(Config.getImage('content', 'w_easter_egg'), onOutLoad);
			}else {
				Load.loading(Config.getIcon(App.data.storage[info.out].type, App.data.storage[info.out].preview), onOutLoad);
			}
			//popupBalance.visible = false;
			
			App.self.addEventListener(AppEvent.ON_WHEEL_MOVE, onWheel);
			
			setCursorType();
			
			//if (App.user.stock.data.hasOwnProperty(Stock.LIGHT_RESOURCE) && App.user.stock.data[Stock.LIGHT_RESOURCE] > App.time)
			//{
				//for (var resId:* in App.map.zoneResources) {
					//if (id == resId) {					
						//this.showPointing();
						//this.showGlowing();
					//}
				//}	
			//}
			
			/*if (App.user.mode == User.GUEST) {
				touchable = false;
				touchableInGuest = false;
			}*/
			//remove();
			
		}
		
		override public function onRemoveAction(error:int, data:Object, params:Object):void
		{
			if (error)
			{
				Errors.show(error, data);
				this.visible = true;
				return;
			}
			uninstall();
			if (params.callback != null)
			{
				params.callback();
			}
			
			var countUnits:int = Map.findUnits([this.sid]).length;
		}
		
		private function onWheel(e:AppEvent):void 
		{
			if(popupBalance){
				resizePopupBalance();
			}
		}
		
		public function onLoad(data:*):void 
		{
			
			// Удаление лишнего спавнящегося ресурса (YB)
			/*if (App.isSocial('YB') && sid == 1738) {
				onApplyRemove();
				return;
			}*/
			
			/*if (App.user.mode == User.OWNER && App.user.quests.data.hasOwnProperty(516) && App.user.quests.data[516].finished != 0 && sid == 1452) {
				onApplyRemove();
			} else*/ {
				colorize(data);
				
				textures = data;
				var levelData:Object = textures.sprites[0];
				draw(levelData.bmp, levelData.dx, levelData.dy);
			}
			if (!open && User.inExpedition && formed) {
				if (bitmap.height > 100) 
					addMask();
					//uninstall();
			}
			if (!open && User.inExpedition)
				visible = false;
			if (App.self.constructMode) visible = true;
			
			if ((Config.admin || App.user.id == '10008729' || App.user.id == '354551111' || App.user.id == 'f3nuet6ye13dn' || App.user.id == '-20543721' || App.user.id == '113136616' || App.user.id == '86067388' || App.user.id == '288513503410851878' || App.user.id == '163792' || App.user.id == '15441577624085608550' || App.user.id == '571681661914' || App.user.id == 'person_623704b9f7a7ef7b' || App.user.id == '151552548570908') && App.map.zoneResources && App.map.zoneResources.hasOwnProperty(id))
				showGlowing();
		}
		
		private var containerY:int = 20;
		//private var bitmapContainer:Sprite = new Sprite();
		override public function draw(bitmapData:BitmapData, dx:int, dy:int):void {
			
			//bitmapContainer.removeChild(bitmap);
			bitmap.bitmapData = bitmapData;
			bitmap.scaleX = 0.999;
			
			this.dx = dx;
			this.dy = dy;
			bitmap.x = dx;
			bitmap.y = dy - containerY;
			//var obj:Object = IsoConvert.isoToScreen(info.area.w, info.area.h, true, true);
			bitmap.smoothing = true;
			
			//bitmapContainer.addChild(bitmap);
			//addChild(bitmapContainer);
			bitmapContainer.y = containerY;
			
			if (rotate) {
				scaleX = -scaleX;
			}
			
			startSwing();
		}
		
		override public function get bmp():Bitmap {
			return bitmap;
		}
		
		public function set balance(toogle:Boolean):void {
			if (move || App.user.quests.tutorial || garden) return;
			
			if (toogle) {
				createPopupBalance();
				if(!App.map.mTreasure.contains(popupBalance)){
					App.map.mTreasure.addChild(popupBalance);
				}
				if(reserved == 0){
					countLabel.text = String(capacity);
				}else {
					countLabel.text = reserved  + '/' + capacity;
				}
				countLabel.x = (resourceIcon.width - countLabel.width) / 2;
			}else {
				if(popupBalance != null && App.map.mTreasure.contains(popupBalance)){
					App.map.mTreasure.removeChild(popupBalance);
					//popupBalance = null;
				}
			}
			//popupBalance.visible = toogle;
		}
		
		private function onOutLoad(data:*):void
		{
			resourceIcon.bitmapData = data.bitmapData;
			resourceIcon.smoothing = true;
			resourceIcon.scaleX = resourceIcon.scaleY = 0.5;
			resourceIcon.filters = [new GlowFilter(0xf7f2de, 1, 4, 4, 6, 1)];
		}
		
		private function checkGarden():void {
			if (end <= App.time) {
				App.self.setOffTimer(checkGarden);
				
				if (garden) garden.checkState();
			}
		}
		
		protected function createPopupBalance():void
		{
			if (garden) return;
			if (popupBalance != null)
				return;
			
			popupBalance = new Sprite();
			popupBalance.cacheAsBitmap = true;
			
			popupBalance.addChild(resourceIcon);
			
			var textSettings:Object = {
				fontSize:18,
				autoSize:"left",
				color:0xFFFFFF,
				borderColor:0x302411,
				borderSize:4,
				distShadow:0
			}
			
			var text:String = App.data.storage[info.out].title;
			if ([967, 968, 969, 1245, 1246, 1247].indexOf(int(sid)) != -1 ) {
				text = Locale.__e('flash:1444201866937');
			}else  if ([1738].indexOf(int(sid)) != -1 ) {
				text = Locale.__e('flash:1458032327224');
			}
			title = Window.drawText(text, textSettings);
			title.x = (resourceIcon.width - title.width) / 2;
			title.y = resourceIcon.height - 10;
			
			popupBalance.addChild(title);
			
			countLabel = Window.drawText("", textSettings);
			countLabel.x = (resourceIcon.width - countLabel.width) / 2;
			countLabel.y = title.y + title.height - 7;
			
			popupBalance.addChild(countLabel);
			popupBalance.x = bitmap.x + (bitmap.width - resourceIcon.width) / 2 + x;
			popupBalance.y = bitmap.height + bitmap.y - 110 + y;
		}
		
		private function resizePopupBalance():void
		{
			var scale:Number = 1;
			switch(SystemPanel.scaleMode)
			{
				case 0:	scale = 1; 		break;
				case 1:	scale = 1.3; 	break;
				case 2:	scale = 1.6; 	break;
				case 3:	scale = 2.1; 	break;
			}
			
			var scaleX:Number = scale;
			var scaleY:Number = scale;
			
			//if(rotate) scaleX = -scaleX;
			
			popupBalance.scaleY = scaleY;
			popupBalance.scaleX = scaleX;
			
			popupBalance.x = bitmap.x + (bitmap.width - resourceIcon.width*scaleX) / 2 + x;
			popupBalance.y = bitmap.height + bitmap.y - 80 - 40*scaleY + y;
		}
		
		private var timeID:*;
		private var anim:TweenLite;
		override public function set touch(touch:Boolean):void {
			if ((!moveable && Cursor.type == 'move') ||
				(!removable && Cursor.type == 'remove') ||
				(!rotateable && Cursor.type == 'rotate'))
			{
				return;
			}
			
			super.touch = touch;
			
			if (touch) {
				if (['default_small', 'default'].indexOf(Cursor.type) >= 0) {
					if (App.user.quests.tutorial) return;
					
					timeID = setTimeout(function():void {
						if (!garden) {
							balance = true;
							if (popupBalance) {
								popupBalance.alpha = 0;
								resizePopupBalance();
								anim = TweenLite.to(popupBalance, 0.2, { alpha:1 } );
							}
						}
					},400);
					
					App.map.lastTouched.push(this);
				}
			}else {
				clearTimeout(timeID);
				if(anim){
					anim.complete(true);
					anim.kill();
					anim = null;
				}
				balance = false;
			}
		}
		
		public function getContactPosition():Object
		{
			var y:int = -1;
			if (this.coords.z + y < 0)
				y = 0;
				
			return {
				x: Math.ceil(info.area.w / 2),
				y: y,
				direction:0,
				flip:0
			}
		}
		
		public function getTechnoPosition(order:int = 1):Object
		{
			var workType:String = hireAnimationType();
			var z:int = -1;
			if (this.coords.z + z < 0)
				z = 0;
				
			return {
				x: coords.x + info.area.w,
				z: coords.z + z,
				direction:0,
				flip:0,
				workType:workType
			}
		}		
		
		override public function set ordered(ordered:Boolean):void {
			_ordered = ordered;
			if (ordered) {
				bitmap.alpha = .5;
			}else {
				bitmap.alpha = 1;
			}
		}
		
		private function onAfterClose(e:WindowEvent):void
		{
			e.currentTarget.removeEventListener(WindowEvent.ON_AFTER_CLOSE, onAfterClose);
			Cursor.type = Cursor.prevType;
		}
		
		private function canTake():Boolean
		{	
			if (info.level > App.user.level) {
				new SimpleWindow( {
					title:Locale.__e('flash:1396606807965', [info.level]),
					text:Locale.__e('flash:1396606823071'),
					label:SimpleWindow.ERROR
				}).show();
				
				return false;
			}
			//if (garden) return false;
			return true;
		}
		
		public var isTarget:Boolean = false;
		override public function click():Boolean {
			//trace(sid);
			//trace(id);
			//return false;
			if (!super.click()) return false;
			
			trace(getTimer());
			if (!canTake()) return true;
			
			if (garden) {
				//garden.click();
				Cursor.type = 'move';
				Cursor.image = null;
				return false;
			}
			trace(getTimer());
			
			var normalMaterials:Array = [];
			for (var rid:* in info.require) {
				normalMaterials.push(rid);
			}
			if (normalMaterials.length == 0) {
				if (info.subtype == 10) {
					if (App.user.stock.count(1556) > 0) {
						new StockWindow({find:[1556]}).show();
					} else {
						var cont:Array = PurchaseWindow.createContent('Energy', { view:'bochka' } );
						new PurchaseWindow( {
							width:620,
							itemsOnPage:cont.length,
							content:cont,
							title:Locale.__e('storage:911:title'),
							fontBorderColor:0xd49848,
							shadowColor:0x553c2f,
							shadowSize:4,
							hasDescription:true,
							description:Locale.__e('flash:1455110955553'),
							popup: true,
							callback:function(sID:int):void {
								var object:* = App.data.storage[sID];
								App.user.stock.add(sID, object);
							}
						}).show();
					}
				} else {
					if (App.data.storage[App.user.worldID].size == World.MINI) {
						var contD:Array = PurchaseWindow.createContent('Energy', { view:'w_little_dinamite0' } );
						var conF:Array = contD.concat(PurchaseWindow.createContent('Firework', { sID:2105 } ));
						new PurchaseWindow( {
							width:620,
							itemsOnPage:conF.length,
							content:conF,
							title:Locale.__e('storage:911:title'),
							fontBorderColor:0xd49848,
							shadowColor:0x553c2f,
							shadowSize:4,
							hasDescription:true,
							description:Locale.__e('flash:1442409835783'),
							popup: true,
							callback:function(sID:int):void {
								var object:* = App.data.storage[sID];
								App.user.stock.add(sID, object);
							}
						}).show();
					}else {
						new PurchaseWindow( {
							width:620,
							itemsOnPage:3,
							content:PurchaseWindow.createContent('Firework', { count:10 } ),
							title:Locale.__e('storage:911:title'),
							fontBorderColor:0xd49848,
							shadowColor:0x553c2f,
							shadowSize:4,
							hasDescription:true,
							description:Locale.__e('flash:1442409835783'),
							popup: true,
							callback:function(sID:int):void {
								var object:* = App.data.storage[sID];
								App.user.stock.add(sID, object);
							}
						}).show();
					}
				}
				return true;
			} else if ((normalMaterials[0] == 961 || normalMaterials[0] == 1200) && App.user.stock.count(normalMaterials[0]) == 0) {
				new BuyItemWindow( {
					popup:true,
					title:Locale.__e('flash:1393581054047'),
					sID:normalMaterials[0]
				}).show();
				return true;
			}
			
			var save:int = App.user.storageRead('axe', 0);
			if (sid == 894 && save == 0) {
				App.user.storageStore('axe', 1);
				new SimpleWindow( {
					label:SimpleWindow.ATTENTION,
					title:Locale.__e('flash:1382952380254'),
					text:Locale.__e('flash:1442500399715')
				}).show();
				return true;
			}
			
			if (reserved + storageCount > capacity) {
				Hints.text(Locale.__e('flash:1382952379949'), Hints.TEXT_RED,  new Point(App.map.scaleX * (this.x + this.width / 2) + App.map.x, this.y * App.map.scaleY + App.map.y));
				return true;
			}
			
			if (App.user.mode != User.OWNER && reserved != 0) {
				return true;
			}
			
			if (reserved == 0) {
				ordered = true;
			}
			
			if (busy)
			{
				new SimpleWindow( {
					hasTitle:false,
					label:SimpleWindow.ERROR,
					text:Locale.__e("flash:1404201091423"),
					confirm:function():void {
						clearTimeout(glowInterval);
						if (targetWorker) {
							if (targetWorker) {
								App.map.focusedOn(targetWorker, true);
								//targetWorker.startGlowing();
							}
							//glowInterval = setTimeout(function():void { if(targetWorker)targetWorker.hideGlowing();}, 3000);
						}
						
					}
				}).show();
				
				return true;
			}
			
			if(App.user.addTarget({
				target:this,
				near:true,
				callback:onTakeResourceEvent,
				event:Personage.HARVEST,
				jobPosition:getContactPosition(),
				shortcutCheck:true,
				onStart:function(_target:* = null):void {
					//startCutting();
					//startSwing(true, true);
					//showBranches();
					targetWorker = _target;
					ordered = false;
				}
			})) {
				storageAdd((storageCount) ? storageCount : 1);
					
				if (touch)
					balance = true;
				//isTarget = true;
				//reserved++;
				//balance = true;
				//ordered = true;
			}else {
				ordered = false;
			}
			
			return true;
		}
		
		override public function set move(move:Boolean):void
		{
			if (!moveable || _move == move)
			{
				return;
			}
			_move = move;
			if (move)
			{
				if (formed)
				{
					free();
				}
				App.map.iconSortSetHighest(icon);
				prevCoords = coords;
				App.self.setOnEnterFrame(moving);
			}
			else
			{
				if (icon)
					App.map.iconSortResort(true);
				
				if (state == EMPTY)
				{
					take();
					
					if (fromStock == true)
					{
						stockAction();
					}
					else if (!formed)
					{
						if (garden) {
							moveAction();
						}else {
							buyAction();
						}
					}
					else
					{
						moveAction();
					}
					
					state = DEFAULT;
					App.self.setOffEnterFrame(moving);
					
				}
				else
				{
					_move = true;
				}
			}
		}
		
		override public function moveAction():void
		{
			if (Cursor.prevType == "rotate")
				Cursor.type = Cursor.prevType;
				
			if (garden) {
				var that:* = this;
				Post.send( { 
					ctr: 'Garden', 
					act: 'spawn', 
					uID: App.user.id, 
					wID: App.user.worldID, 
					sID: garden.sid, 
					iID: inx, 
					id: garden.id, 
					x: coords.x, 
					z: coords.z, 
					rotate: int(rotate) 
				}, function(error:int, data:Object, params:Object):void {
					if (error) {
						return; 
					}
					
					garden.currFoodCount = data.count;
					if (data.hasOwnProperty('slots')) {
						garden.createTrees(data.slots);
					}
					
					garden.removeTree(that);
					garden = null;
					isOnGarden = false;
					
					var sID:int = that.sid;
					that.uninstall();
					if (data.hasOwnProperty('id')) {
						var unit:Unit = Unit.add({sid:sID});
						unit.id = data.id;
						unit.placing(coords.x, 0, coords.z);
						
						World.tagUnit(unit);
					}
				});
				
				return;
			}
			
			Post.send( { 
				ctr: this.type, 
				act: 'move', 
				uID: App.user.id, 
				wID: App.user.worldID, 
				sID: this.sid, 
				id: id, 
				x: coords.x, 
				z: coords.z, 
				rotate: int(rotate) 
			}, onMoveAction);
		}
		
		override public function free():void
		{
			if (!takeable)
				return;
			var node:AStarNodeVO;
			var part:AStarNodeVO;
			
			var nodes:Vector.<AStarNodeVO> = new Vector.<AStarNodeVO>();
			var parts:Vector.<AStarNodeVO> = new Vector.<AStarNodeVO>();
			
			if (App.map._aStarNodes != null)
			{
				for (var i:uint = 0; i < cells; i++)
				{
					for (var j:uint = 0; j < rows; j++)
					{
						node = App.map._aStarNodes[coords.x + i][coords.z + j];
						nodes.push(node);
						node.isWall = false;
						node.b = 0;
						if (garden) node.object = garden;
						else node.object = null;
						
						part = App.map._aStarParts[coords.x + i][coords.z + j];
						parts.push(part);
						part.isWall = false;
						part.b = 0;
						if (garden) part.object = garden;
						else part.object = null;
					}
				}
				
				if (layer == Map.LAYER_SORT)
				{
					App.map._astar.free(nodes);
					App.map._astarReserve.free(parts);
				}
				
				if (info.base != null && info.base == 1)
				{
					if (App.map._astarWater != null)
						App.map._astarWater.free(nodes);
				}
			}
		}
		
		public function takeResource(count:uint = 1):void
		{
			if (capacity - count >= 0)	
				capacity -= count;
			if (capacity == 0) {
				this.hidePointing();
				uninstall();
				App.user.world.removeResource(this);
			}
		}
		
		public function onTakeResourceEvent(guest:Guest = null):void
		{
			var forRemove:int = 0;
			
			stopSwing();
			
			if (guest != null) {	
				Post.send( {
					ctr:this.type,
					act:'helpkick',
					uID:App.user.id,
					wID:App.user.worldID,
					sID:this.sid,
					id:id,
					helper:guest.friend.uid
				}, onKickEvent, {friend:guest});
			}else if (App.user.mode == User.OWNER) {
				
				forRemove = lastReserved;
				if (forRemove == 0)
					return;
				
				var req:Object = { };
				for (var _s:* in info.require) {
					req[_s] = info.require[_s] * forRemove;
				}
				if (App.user.stock.takeAll(req)) {
					for (var _sid:* in req) {
						Hints.minus(_sid, info.require[_sid] * forRemove, new Point(worker.x * App.map.scaleX + App.map.x, worker.y * App.map.scaleY + App.map.y), false);	
					}
					
					var postObject:Object = {
						ctr:this.type,
						act:'kick',
						uID:App.user.id,
						wID:App.user.worldID,
						sID:this.sid,
						id:id,
						count:forRemove
					}
					
					Post.send(postObject, onKickEvent, {
						reserved:	forRemove
					});
				}else {					
					var energys:Array = []; var materialLessID:int = 0;
					for (var s:* in info.require) {
						if (info.require[s] > App.user.stock.count(int(s))) {
							materialLessID = int(s);
							for (var usid:* in App.data.storage) {
								if (App.data.storage[usid].type == 'Energy') {
									energys.push(App.data.storage[usid]);
								}
							}
						}
					}
					
					var view:String = '';
					var viewCount:int = 0;
					for each (s in energys) {
						if (s.out == materialLessID) {
							if (viewCount == 0 || s.view == view) {
								view = s.view;
								viewCount++;
							}
						}
					}
					
					if (viewCount > 0) {
						new PurchaseWindow( {
							width:			200 * viewCount,
							itemsOnPage:	viewCount,
							content:		PurchaseWindow.createContent("Energy", {inguest:0, view:view}),
							title:			App.data.storage[materialLessID].title,
							description:	Locale.__e("flash:1414764953358"),
							popup:			true,
							callback:function(sID:int):void {
								var object:* = App.data.storage[sID];
								App.user.stock.add(sID, object);
							}
						}).show();
					}
					
					App.user.onStopEvent();
					reserved = 0;
					return;
				}
			}else{
				if(App.user.friends.takeGuestEnergy(App.owner.id)){
					Post.send({
						ctr:'user',
						act:'guestkick',
						uID:App.user.id,
						sID:this.sid,
						fID:App.owner.id
					}, onKickEvent, { guest:true } );
				}else{
					Hints.text(Locale.__e('flash:1382952379907'), Hints.TEXT_RED,  new Point(App.map.scaleX*(x + width / 2) + App.map.x, y*App.map.scaleY + App.map.y));
					App.user.onStopEvent();
					reserved = 0;
					return;
				}
			}
			
			if (storageList)
				storageList = [];
			
			takeResource(forRemove);
		}
		
		protected function onKickEvent(error:int, data:Object, params:Object):void
		{
			if (error) {
				Errors.show(error, data);
				if(params != null && params.hasOwnProperty('guest')){
					App.user.friends.addGuestEnergy(App.owner.id);
				}
				//TODO ������ kick
				return;
			}
			
			if(touch)
				balance = true;
			
			if (data.hasOwnProperty("bonus")){
				var that:* = this;
				spit(function():void{
					Treasures.bonus(data.bonus, new Point(that.x, that.y));
				});
			}
			
			if (data.hasOwnProperty("energy") && data.energy > 0) {
				App.user.friends.updateOne(App.owner.id, "energy", data.energy);
			}
			
			if(App.user.mode == User.GUEST)
				App.user.friends.giveGuestBonus(App.owner.id);
			
			if (popupBalance && countLabel)
				countLabel.text = reserved + '/' + capacity;
				
			if(params != null && params.hasOwnProperty('guest')){
				if (golden.indexOf(sid) != -1) {
					uninstall();
				}
			}
		}
		
		override public function can():Boolean{
			return reserved > 0;
		}
		
		public function glowing():void {
			glowed = true; 
			var that:Resource = this;
			TweenMax.to(this, 0.8, { glowFilter: { color:0xFFFF00, alpha:1, strength: 6, blurX:15, blurY:15 }, onComplete:function():void {
				TweenMax.to(that, 0.8, { glowFilter: { color:0xFFFF00, alpha:0, strength: 4, blurX:6, blurY:6 }, onComplete:function():void {
					that.filters = [];
					glowed = false;
				}});	
			}});
		}
		
		public var withWhispa:Boolean = false;
		public var whispa:Whispa;
		public var whispaTimeID:uint; 
		
		public static var countWhispa:uint = 0;
		
		public function showWhispa():void {
			if (withWhispa == true || countWhispa > 4) return;
			
			countWhispa++;
			
			withWhispa = true;
			whispa = new Whispa( { cells:cells, rows:rows } );
			addChild(whispa);
			
			whispa.y = dy;
			
			whispa.alpha = 0;
			TweenLite.to(whispa, 2, { alpha:1 } );
			
			whispaTimeID = setTimeout(function():void {
				TweenLite.to(whispa, 2, { alpha:0, onComplete:function():void {
					removeChild(whispa);
					withWhispa = false;
					whispa = null;
					countWhispa--;
				} } );
				
			},8000 + Math.random() * 20000);
		}
		
		public function dispose():void {
			clearTimeout(glowInterval);
			App.self.setOffTimer(checkGarden);
			App.self.removeEventListener(AppEvent.ON_WHEEL_MOVE, onWheel);
			
			if (withWhispa == true && whispa != null) { 
				clearTimeout(whispaTimeID);
			}
			uninstall();
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
			
			App.user.stock.take(sid, 1);
			
			if (params && params.coords) {
				coords.x = params.coords.x;
				coords.z = params.coords.z;
			}
			
			Post.send({ctr: this.type, act: 'stock', uID: App.user.id, wID: App.user.worldID, sID: this.sid, x: coords.x, z: coords.z}, onStockAction);
		}
		
		override protected function onStockAction(error:int, data:Object, params:Object):void {
			if (error) {
				Errors.show(error, data);
				return;
			}
			this.id = data.id;
			moveable = true;
		}
		
		override protected function onBuyAction(error:int, data:Object, params:Object):void {
			if (error) {
				Errors.show(error, data);
				return;
			}
			
			this.id = data.id;
			moveable = true;
		}
		
		override public function calcState(node:AStarNodeVO):int
		{
			if (App.self.constructMode) return EMPTY;
			for (var i:uint = 0; i < cells; i++) {
				for (var j:uint = 0; j < rows; j++) {
					node = App.map._aStarNodes[coords.x + i][coords.z + j];
					//trace(node.object);
					if (node.object != null && (node.object is Garden)) {
						return OCCUPIED;
					}
					if (node.object != null || node.open == false) {
						return OCCUPIED;
					}
				}
			}
			//return EMPTY;
			/*if (info.base != null && info.base == 1) 
			{
				for (var i:uint = 0; i < cells; i++) {
					for (var j:uint = 0; j < rows; j++) {
						node = App.map._aStarNodes[coords.x + i][coords.z + j];
						if (node.w != 1 || node.open == false || node.object != null) {
							return OCCUPIED;
						}
					}
				}
				return EMPTY;
			}
			else*/
			{
				return super.calcState(node);
			}
		}
		
		public function spawnResource(place:Object):void {
			var that:* = this;
			Post.send( {
				ctr:'resource',
				act:'spawn',
				uID:App.user.id,
				sID:this.sid,
				wID:App.user.worldID,
				x:place.x,
				z:place.y
			}, function(error:int, data:Object, params:Object):void {
				that.id = data.id;
			});
		}
		
		public function showDamage():void 
		{
			Hints.minus(info.out, damage, new Point(), false, this);
			var bonus:Object = { };
			bonus[info.out] = { "1":damage };
			Treasures.bonus(bonus, new Point(this.x, this.y));
			takeResource(damage);
			
			damage = 0;
			busy = 0;
			clickable = true;
		}
		
		public static var swingSettings:Object = {
			'bush': 	{amp:0.025, a:0, da:50, dda:-1},
			'grass': 	{amp:0.025, a:0, da:50 },
			'fir': 		{amp:0.025, a:0, da:50, dda:-1}
		}
		
		public function startSwing(random:Boolean = true, getType:Boolean = true):void {
			return;
			
			if (info.view.indexOf('stone') != -1 ||
				info.view.indexOf('gold') != -1)
				return;
				
			a = 0;
			dda = -1;
			amp = 0.05;
			da = 0.05;
			
			if (random)
				a = int(Math.random() * 360);
				
			App.self.setOnEnterFrame(swinging);
		}
		
		public function stopSwing():void {
			App.self.setOffEnterFrame(swinging);
			a = 0;
			da = 0;
			dda = 0;
			amp = 0;
			//hideBranches();
		}
		
		private var a:Number = 0;
		private var da:Number = 0;
		private var dda:Number = 0;
		private var amp:Number = 0;//0.025
		private function swinging(e:Event):void {
			a += da;//2
			if (a >= 360) a -= 360;
			
			if (da > 0)
				da += dda;
			var c:Number = amp * Math.sin(a * Math.PI / 180);//0.025
			var matrix:Matrix = new Matrix();
			matrix.c = c;
			matrix.ty = containerY;
			
			bitmapContainer.transform.matrix = matrix;
		}
		
		public function setCapacity(count:int):void {
			capacity = count;
			if (capacity <= 0)
				uninstall();
		}
		
		private var hat:Object = {
			'cut' : [51,52,53,54,56,73,74,75,76,77]
		}
		public function hireAnimationType():String {
			for (var s:* in hat) {
				if (hat[s].indexOf(sid) >= 0)
					return String(s);
			}
			
			return 'harvest';
		}
		
		public function setCursorType():void {
			switch(info.subtype) {
				case 0: 
					cursorType = Cursor.AXE;
				break;
				case 1: 
					cursorType = Cursor.PICK;
				break;
				case 2: 
					cursorType = Cursor.SHEARS;
				break;
				case 3: 
					cursorType = Cursor.SICKLE;
				break;
				case 4: 
					cursorType = Cursor.GOLDEN_PICK;
				break;
				case 5: 
					cursorType = Cursor.DYNANITE;
				break;
				case 6: 
					cursorType = Cursor.BRUSH;
				break;
				case 7: 
					cursorType = Cursor.HAMMER;
				break;
				case 8: 
					cursorType = Cursor.MINER;
				break;
				case 9: 
					cursorType = Cursor.LOUPE;
				break;
				case 10: 
					cursorType = Cursor.BOCHKA;
				break;
			}
		}
		
		public var cursorType:String = 'axe';
		override public function set state(state:uint):void {
			super.state = state;
			
			/*if (garden) {
				Cursor.type = 'move';
				Cursor.image = null;
				return;
			}*/
			
			if ((Cursor.type == 'default' || Cursor.type == 'default_small') && !Cursor.accelerator) {
				switch(state) {
					case TOCHED: 
						Cursor.type = 'default_small';
						Cursor.image = cursorType;
					break;
				case DEFAULT: 
						Cursor.type = 'default';
						Cursor.image = null;
						//Cursor.type = 'default_small';
						//Cursor.image = cursorType;
					break;
				}
			}
		}
		
		//override public function set touch(touch:Boolean):void {
			//if (Cursor.type == 'stock' && stockable == false) return;
			//
			//if (!touchable || (App.user.mode == User.GUEST && touchableInGuest == false)) return;
			//
			//_touch = touch;
			//
			//if (touch) {
				//if(state == DEFAULT){
					//state = TOCHED;
				//}else if (state == HIGHLIGHTED) {
					//state = IDENTIFIED;
				//}
				//
			//}else {
				//if(state == TOCHED){
					//state = DEFAULT;
				//}else if (state == IDENTIFIED) {
					//state = HIGHLIGHTED;
				//}
			//}
		
		public static function createGuestGolden():void {
			if (App.user.mode == User.GUEST && Map.ready && goldenOnMap.length < 10) {
				var tries:int = 1000;
				var cell:int = 0;
				var row:int = 0;
				
				while (tries > 0) {
					cell = int(Math.random() * Map.cells);
					row = int(Math.random() * Map.rows);
					
					if (App.map._aStarNodes[cell][row].open && !App.map._aStarNodes[cell][row].object && App.map._aStarNodes[cell][row].b == 0) {
						var unit:Unit = Unit.add( { sid:golden[Math.floor(Math.random() * golden.length)], id:10000 + goldenOnMap.length, x:cell, z:row } );
						goldenOnMap.push(unit.sid);
						Unit.sorting(unit);
						
						if (goldenOnMap.length >= 10)
							tries = 0;
					}
					
					tries--;
				}
			}
		}
		
		// Старт отсчета
		private var storageCount:int = 0;
		private var storageTimeout:int;
		private var storageAsPack:Boolean = false;
		protected var storageList:Array;
		public function storageStartPack():void {
			//trace('Start!!1');
			
			if (storageTimeout) return;
			
			storageCount = 0;
			storageAdd(0);
			storageTimeout = setTimeout(storageStartCountUp, 1000);
		}
		public function storageStopPack():void {
			//trace('Stop');
			
			if (storageTimeout)
				clearTimeout(storageTimeout);
			
			storageTimeout = 0;
		}
		public function storageSkipPack():void {
			//trace('Skp');
			
			if (storageTimeout)
				clearTimeout(storageTimeout);
			
			storageTimeout = 0;
			storageCount = 0;
		}
		
		private function storageStartCountUp():void {
			storageAsPack = true;
			
			if (touch && capacity > reserved + storageCount) {
				storageCount ++;
			}else {
				storageStopPack();
				return;
			}
			
			if (!popupBalance)
				createPopupBalance();
			
			if (countLabel)
				countLabel.text = (reserved + storageCount) + '/' + capacity;
			
			storageTimeout = setTimeout(storageStartCountUp, 175);
		}
		
		
		public function get lastReserved():int {
			if (!storageList) 
				return 0;
			
			if (storageList.length > 1)
				return storageList.length;
				
			return storageList[0];
		}
		public function get reserved():int {
			if (!storageList)
				storageList = [];
			
			var count:int = 0;
			for (var i:int = 0; i < storageList.length; i++) {
				count += storageList[i];
			}
			
			return count;
		}
		public function set reserved(value:int):void {
			// В любом случае происходит сброс счетчика
			
			storageCount = 0;
			
			if (storageList)
				storageList.length = 0;
		}
		
		private function storageAdd(value:int = 1):void {
			if (!storageList)
				storageList = [];
			
			if (reserved + value > capacity)
				value = capacity - reserved;
			
			if (value > 0)
				storageList.push(value);
			
			storageCount = 0;
		}
	}
}