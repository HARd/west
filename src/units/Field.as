package units 
{
	import astar.AStarNodeVO;
	import core.Load;
	import core.Post;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	import ui.AnimalIcon;
	import ui.Cursor;
	import ui.Hints;
	import ui.PlantMenu;
	import wins.PlantWindow;
	import wins.PurchaseWindow;
	import wins.ShopWindow;
	import com.greensock.TweenLite;
	import wins.Window;
	import wins.WindowEvent;
	
	public class Field extends Unit {
		
		public static var exists:Boolean = false;
		public static var planting:Vector.<Field> = new Vector.<Field>;
		
		private static var DEFAULT_MULTI_BOOST:int = 3;
		public static var boost:int = 0;
		public static var boosts:Array = [];
		public static var multiSelect:int = DEFAULT_MULTI_BOOST;
		public static var fieldForBoost:Vector.<Field> = new Vector.<Field>;
		public static var fieldsOnMap:Array = [];
		public static var touched:Field;
		public static var quickStorage:int = 0;
		
		public var plant:Plant = null;
		
		public var pID:uint = 0;				// sid растения, нужен для запоминания. что купили в последний раз
		public var sowing:Boolean = false;		// Сеется
		
		public function Field(object:Object)
		{
			layer = Map.LAYER_FIELD;
			
			super(object);
			
			multiple = true;
			rotateable = false;
			
			if (App.user.mode == User.GUEST) {
				clickable = false;
			}
			
			if (object.pID && object.pID > 0) {
				createPlant(object.pID, object.planted);
			}else {
				touchableInGuest = false;
			}
			
			if (!formed && ShopWindow.currentBuyObject.sid && App.data.storage[ShopWindow.currentBuyObject.sid].type == 'Plant') {
				createPlant(ShopWindow.currentBuyObject.sid, 0, true);
			}
			
			tip = function():Object {
				if(plant != null){
					var growthTime:int = plant.planted + plant.info.levels * plant.info.levelTime;
					
					if (plant.planted == 0) {
						return {
							title:plant.info.title,
							text:info.description,
							timer:true
						};
					}else if (plant.planted > 0 && growthTime > App.time) {
						return {
							title:plant.info.title,
							text:Locale.__e("flash:1382952379899") + '\n' + TimeConverter.timeToStr(growthTime - App.time),
							timer:true
						};
					}else {
						return {
							title:plant.info.title,
							text:Locale.__e("flash:1382952379900"),
							timer:false
						};	
					}
				}else{
					return {
						title:		info.title,
						text:		info.description
					}
				}
			};
			
			Load.loading(Config.getSwf(App.data.storage[sid].type, App.data.storage[sid].view), onLoad);
			
		}
		
		override public function canInstall():Boolean
		{
			if (visible)
				return (_state != OCCUPIED);
			
			if (fieldTouch && fieldTouch.plant && fieldTouch.plant.planted == 0)
				fieldTouch.click();
			
			if (!visible && App.map.moved == this && plant && plant.planted == 0) {
				App.map.touch();
				return false;
			}
			
			previousPlace();
			Cursor.material = ShopWindow.currentBuyObject.sid;
			App.map.touch();
			return false;
		}
		
		public static var fieldTouch:Field;
		override public function calcState(node:AStarNodeVO):int {
			for (var i:uint = 0; i < cells; i++) {
				for (var j:uint = 0; j < rows; j++) {
					node = App.map._aStarNodes[coords.x + i][coords.z + j];
					
					if (!formed) {
						if (node.object != null && node.object is Field &&  node.object.ordered == false /*&& Field(node.object).plant == null*/) {
							this.visible = false;
							if (plant) plant.visible = false;
							
							if (fieldTouch != node.object) {
								if (fieldTouch) fieldTouch.touch = false;
								fieldTouch = node.object as Field;
							}
							
							//App.map.touched.push(node.object);
							node.object.touch = true;
							return OCCUPIED;
						}else {
							if (fieldTouch) {
								fieldTouch.touch = false;
								fieldTouch = null;
							}
							
							this.visible = true;
							if (plant) plant.visible = true;
						}
					}
					
					if (node.b != 0 || node.open == false || node.object != null) {
						return OCCUPIED;
					}
				}
			}
			
			return EMPTY;
		}
		
		
		
		override public function buyAction():void {
			
			pID = ShopWindow.currentBuyObject.sid;
			
			if (!pID) {
				setTimeout(uninstall, 100);
				return;
			}
			
			var price:Object = { };
			price[Stock.FANTASY] = 1;
			var plantInfo:Object = App.data.storage[pID];
			
			if(plantInfo.coins && plantInfo.coins > 0){
				price[Stock.COINS] = plantInfo.coins;
			}else if (plantInfo.hasOwnProperty('price')) {
				for (var s:* in plantInfo.price) {
					price[s] = plantInfo.price[s];
				}
			}
			
			if (!App.user.stock.checkAll(price)) {
				setTimeout(uninstall, 100);
				
				Hints.text(Locale.__e('flash:1479394440483'), Hints.TEXT_RED, new Point(App.self.stage.mouseX, App.self.stage.mouseY));
				
				return;
			}
			
			App.user.hero.addTarget( {
				target:this,
				callback:onCreateEvent,
				event:Personage.PLANT,
				jobPosition:{x:0,y:0}
			});
			
			ordered = true;
		}
		
		override public function set transparent(transparent:Boolean):void {
			if (!transable || _trans == transparent)
				return;
			
			if (transparent == true) {
				_trans = true;
				transTimeID = setTimeout(function():void{
					if(plant) tween = TweenLite.to(plant, 0.2, { alpha:0.3 } );
				},200);
				
			}else {
				_trans = false;
				clearTimeout(transTimeID);
				
				if (tween) {
					tween.complete(true);
					tween.kill();
					tween = null;
				}
				//this.bmp.alpha = 1;
				if(plant) plant.alpha = 1;
			}
		}
		
		override public function get bmp():Bitmap {
			if (bitmap.bitmapData && bitmap.bitmapData.getPixel(bitmap.mouseX, bitmap.mouseY) != 0) 			
				return bitmap;
			if (plant && plant.bitmapData && plant.bitmapData.getPixel(plant.mouseX, plant.mouseY) != 0) 	
				return plant;
			return bitmap;
		}
		
		override public function set state(state:uint):void {
			if (_state == state) return;
			
			switch(state) {
				case OCCUPIED: 
						bitmap.filters = [new GlowFilter(0xFF0000, 1, 4, 4, 5)];
						if(plant && !plant.glowed) plant.filters = [new GlowFilter(0xFF0000, 1, 4, 4, 5)];
						break;
				case EMPTY:
						bitmap.filters = [new GlowFilter(0x00FF00, 1, 4, 4, 5)];
						if(plant && !plant.glowed) plant.filters = [new GlowFilter(0x00FF00, 1, 4, 4, 5)];
						break;
				case TOCHED:
						if ((Cursor.type == 'default' || Cursor.type == 'default_small') && plant && plant.ready && !ShopWindow.currentBuyObject.sid) {
							Cursor.type = 'default_small';
							Cursor.image = 'sickle';
							Cursor.moveMouseMargin = new Point(10, 10);
						}
						bitmap.filters = [new GlowFilter(0xFFFF00, 1, 8, 8, 5)]; 
						if(plant && !plant.glowed) plant.filters = [new GlowFilter(0xFFFF00, 1, 8, 8, 5)];
						break;
				case DEFAULT:
						if (Cursor.type == 'default_small') {
							Cursor.type = 'default';
							Cursor.image = null;
						}
						bitmap.filters = []; 
						if(plant && !plant.glowed) plant.filters = []; 
						break;
			}
			_state = state;
		}
		
		override protected function moving(e:Event = null):void {
			if (coords.x != Map.X || coords.z != Map.Z) {
				placing(Map.X, 0, Map.Z);
				if (plant) {
					App.map.sorted.push(plant);
					
					if (plant.levelData) {
						plant.x = plant.levelData.dx + x;
						plant.y = plant.levelData.dy + y;
					}
				}
			}
		}
		
		override public function previousPlace():void {
			super.previousPlace();
			
			if(formed && plant){
				App.map.sorted.push(plant);
				
				plant.x = plant.levelData.dx + x;
				plant.y = plant.levelData.dy + y;
			}
		}
		
		override public function set ordered(ordered:Boolean):void {
			super.ordered = ordered;
			
			if (plant) plant.alpha = alpha;
			if (!ordered && plant && plant.planted == 0 && !sowing) {
				removePlant();
			}
		}
		
		override public function set touch(touch:Boolean):void {
			if (!touchable || (App.user.mode == User.GUEST && (touchableInGuest == false || (plant != null && !plant.ready)))) return;
			
			if (Cursor.type == "rotate") {
				return;
			}
			
			if (Cursor.accelerator) {
				/*if(state == DEFAULT){
					state = TOCHED;
				}*/
				return;
			}
			
			if (Cursor.type == "stock" && Cursor.toStock == true) {
				return;
			}
			
			_touch = touch;
			var unit:Field;
			if (touch) {
				touched = this;
				
				if (!plant && App.map.moved && (App.map.moved is Field) && ShopWindow.currentBuyObject.type == 'Plant') {
					createPlant(ShopWindow.currentBuyObject.sid, 0, true);
				}
				
				if (boost > 0) {
					if (!hasEventListener(AppEvent.ON_WHEEL_MOVE))
						App.self.addEventListener(MouseEvent.MOUSE_WHEEL, onWheel);
					
					chooseForBoost();
				}
				
				if(state == DEFAULT){
					state = TOCHED;
				}
				
				if (AnimalIcon.multiClickState == 'field_storage' && AnimalIcon.multiClickTargetID == sid && plant && plant.ready)
					click();
			}else {
				touched = null;
				
				if (forView)
					removePlant();
				
				if (boost > 0) {
					App.self.removeEventListener(MouseEvent.MOUSE_WHEEL, onWheel);
					clearForBoost();
				}
				
				if (state == TOCHED) {
					state = DEFAULT;
				}
			}
		}
		
		/**
		 * Создаем растение вместе с грядкой
		 */
		private function onCreateEvent():void
		{
			var self:Field = this;
			ordered = false;
			
			var price:Object = { };
			price[Stock.FANTASY] = 1;
			for (var s:* in App.data.storage[pID].price) {
				price[s] = App.data.storage[pID].price[s];
			}
			
			if (!App.user.stock.checkAll(App.data.storage[pID].require)) {
				openEnergyWindow();
				uninstall();
				App.user.onStopEvent();
				return;
			} else if (!App.user.stock.takeAll(price)) {
				if (!App.user.stock.check(Stock.FANTASY, 1)) {
					openEnergyWindow();
				}
				uninstall();
				App.user.onStopEvent();
				return;
			}
			
			createPlant(pID, App.time);
			
			clickable = false;
			touchable = false;
			
			Post.send( {
				ctr:this.type,
				act:'plant',
				uID:App.user.id,
				wID:App.user.worldID,
				sID:this.sid,
				pID:pID,
				x:coords.x,
				z:coords.z
				}, function(error:int, data:Object, params:Object):void {
					
					if (error) {
						Errors.show(error, data);
						//App.map.removeUnit(plant);
						plant = null;
						ordered = false;
						return;
					}
				
					self.id = data.id;
					if (plant) plant.planted = data.planted;
					clickable = true;
					touchable = true;
					
					for (var s:* in App.data.storage[pID].price) {
						var count:int = App.data.storage[pID].price[s];
					}
					Hints.minus(Stock.FANTASY, price[Stock.FANTASY], new Point(self.x*App.map.scaleX + App.map.x, self.y*App.map.scaleY + App.map.y), true);
					Hints.minus(s, count, new Point(self.x * App.map.scaleX + App.map.x, self.y * App.map.scaleY + App.map.y));
				});
		}
		
		private function hidePoint():void
		{
			if (__hasPointing) hidePointing();
		}
		
		private function onLoad(data:*):void {
			if(data.hasOwnProperty('sprites')){
				textures = data;
				updateField();
			}
		}
		
		/**
		 * Рисуем поле
		 */
		private function updateField():void
		{
			var texture:Object = textures.sprites[0];
			draw(texture.bmp, texture.dx, texture.dy);
		}
		
		private function openBoostWindow():void {
			new PurchaseWindow( {
				width:395,
				itemsOnPage:2,
				content:/*PurchaseWindow.createContent("Energy", { inguest:0, view:'Water'} ),*/PurchaseWindow.createContent("Boost"),
				title:Locale.__e("flash:1382952379903"),
				returnCursor:false,
				noDesc:false,
				description:Locale.__e("flash:1382952379904"),
				callback:function(sID:int):void {
					touch = false;
					boost = sID;
					Cursor.type = 'water';
					
					this.window.close();
				}
			}).show();
		}
		
		private function stopPlanting():void {
			pID = 0;
			Cursor.type = 'default';
			Cursor.material = 0;
			ShopWindow.currentBuyObject.type = '';
			ShopWindow.currentBuyObject.sid = 0;
			App.user.onStopEvent();
			
			if (App.map.moved is Field) {
				var field:Field = App.map.moved as Field;
				field = null;
			}
			
			if (forView)
				removePlant();
			
			touch = false;
		}
		
		private function openEnergyWindow():void {
			new PurchaseWindow( {
				width:595,
				itemsOnPage:3,
				content:PurchaseWindow.createContent("Energy", {view:'energy'}),
				title:Locale.__e("flash:1382952379756"),
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
		}
		
		
		override public function click():Boolean {
			if (!touchable || (App.user.mode == User.GUEST && (touchableInGuest == false || (plant != null && !plant.ready)))) return false;
			
			if (!super.click() || sowing) return false;
			
			var self:Field = this;
			multiSelect = DEFAULT_MULTI_BOOST;
			
			var allFields:Array = Field.findFields();
			for (var i:int = 0; i <  allFields.length; i++) {
				 allFields[i].hidePoint();
			}
			
			if (plant && !forView)
			{
				if (plant.ready) {
					if (quickStorage) {
						onHarvestEvent();
					}else {
						startMultiStorage();
						
						if (App.user.addTarget({
							target:this,
							near:true,
							callback:onHarvestEvent,
							event:Personage.GATHER,
							jobPosition:{x:0,y:1,direction:0, flip:1},
							shortcutCheck:true,
							onStart:function(_target:* = null):void {
								//ordered = false;
								//harvest = true;
							}
						})) {
							if  (App.tutorial && App.user.quests.data.hasOwnProperty(5) && App.user.quests.data[5].finished == 0)
								App.tutorial.quest5_0(this);
							
						}
						
						ordered = true;
						state = DEFAULT;
					}
					
					return true;
				}else{
					var showContext:Boolean = false;
					var percent:int = 0;
					var boosts:Object = { };
					var ID:*;
					for (ID in App.data.storage) {
						if (App.data.storage[ID].type == 'Boost'){
							if(App.data.storage[ID].out == boost) {
								percent = App.data.storage[ID].percent;
							}
							var out:int = App.data.storage[ID].out;
							boosts[out] = App.user.stock.count(out);
							showContext = true;
						}
					}
					
					if (showContext && boost == 0) {
						var items:Array = [];
						
						for (ID in boosts) {
							items.push( { caption:Locale.__e('flash:1424688304987'), sid:ID, callbackParams:ID, callback:onStartBoost});
						}
						
						new PlantMenu(this, items).show();
						
						return true;
					}else if (boost != 0 && Field.fieldForBoost.length > 0) {
						
						Cursor.material = Field.boost;
						Cursor.type = 'boost';
						Cursor.text = App.user.stock.count(boost);
						
						if (App.user.stock.take(boost, Field.fieldForBoost.length)) {
							var ids:Array = [];
							for each(var field:Field in Field.fieldForBoost) {
								ids.push(field.id);
								field.plant.planted -= (field.plant.info['levels'] * field.plant.info['levelTime']) * percent;
								field.plant.glowing();
							}
							if(ids.length > 0){
								Post.send( {
									ctr:this.type,
									act:'boost',
									uID:App.user.id,
									wID:App.user.worldID,
									sID:this.sid,
									IDs:JSON.stringify(ids),
									bID:boost
								}, function(error:*, result:*, params:*):void {
									
									if (!error) { }
									Cursor.text = App.user.stock.count(boost);
									
									if (App.user.stock.count(boost) == 0) {
									Cursor.type = 'default';
									Cursor.material = null;
									boost = 0;
								}
									
								});
							}else {
							
								if (App.user.stock.count(boost) == 0) {
									Cursor.type = 'default';
									Cursor.material = null;
									boost = 0;
								}
							}
						}else {
							
							var content:Array = [{
								sid:		boost,
								need:		Field.fieldForBoost.length
							}];
							
							var fields:Array = [];
							for each (var fld:Field in Field.fieldForBoost)
								fields.push(fld);
							
							new PlantWindow( {
								description:	Locale.__e('flash:1424792011658'),
								content:		content,
								title:			info.title,
								callback:		function():void {
									for each (var fld:Field in fields)
										Field.fieldForBoost.push(fld);
									
									click();
								}
							}).show();
							
						}
						
					}
					
					return true;
				}
			}
			else if(App.user.mode == User.OWNER)
			{ 
				if (ShopWindow.currentBuyObject && ShopWindow.currentBuyObject.type == "Plant")
				{
					// Добавляем растение
					pID = ShopWindow.currentBuyObject.sid;
					
					var item:Object = App.data.storage[pID];
					
					if (!App.user.stock.checkAll(item.require)) {
						openEnergyWindow();
						stopPlanting();
						return false;
					}else if(!App.user.stock.checkAll(item.price)) {
						stopPlanting();
						return false;
					}
					
					if (App.user.addTarget({
						target:this,
						near:true,
						callback:onSowEvent,
						event:Personage.PLANT,
						jobPosition:{x:0,y:1,direction:0,flip:1},
						shortcutCheck:true,
						onStart:function(_target:* = null):void {
							planting.push(self);
							sowing = true;
							ordered = false;
						}
					})) {
						createPlant(pID);
						ordered = true;
						
						if  (App.tutorial && App.user.quests.data.hasOwnProperty(5) && App.user.quests.data[5].finished == 0)
							App.tutorial.quest5_1(this);
					}
					
				}
				else
				{
					exists = true;
					
					ShopWindow.show( { section:2 } );
					ShopWindow.instance.addEventListener(WindowEvent.ON_AFTER_CLOSE, onAfterClose);
					
					//var shop:ShopWindow = new ShopWindow( { section:2} );
					//shop.addEventListener(WindowEvent.ON_AFTER_CLOSE, onAfterClose);
					//shop.show();
					
				}
			}
			
			return true;
		}
		
		private function onMouseUpQuickStorage(e:AppEvent):void {
			App.self.removeEventListener(AppEvent.ON_MOUSE_UP, onMouseUpQuickStorage);
			quickStorage = 0;
		}
		
		private function onAfterClose(e:WindowEvent):void {
			e.currentTarget.removeEventListener(WindowEvent.ON_AFTER_CLOSE, onAfterClose);
			if(ShopWindow.currentBuyObject.type == "Plant"){
				click();
			}
		}
		
		override public function free():void {
			//if (ShopWindow.currentBuyObject.type == 'Plant') return;
			//if (formed)
				super.free(); 
		}
		
		
		/**
		 * По окончанию сбора урожая
		 */
		public function onHarvestEvent(guest:Guest = null):void
		{
			if(guest != null){
				
				Post.send( {
					ctr:this.type,
					act:'helpharvest',
					uID:App.user.id,
					wID:App.user.worldID,
					sID:this.sid,
					id:id,
					helper:guest.friend.uid
				}, onHarvestAction, { friend:guest } );
			}else if (App.user.mode == User.OWNER) {
				Post.send( {
					ctr:this.type,
					act:'harvest',
					uID:App.user.id,
					wID:App.user.worldID,
					sID:this.sid,
					id:id
				}, onHarvestAction);
			} else {
				if(App.user.friends.takeGuestEnergy(App.owner.id)){
				
					Post.send( {
						ctr:this.type,
						act:'guestharvest',
						uID:App.owner.id,
						wID:App.owner.worldID,
						sID:this.sid,
						id:id,
						guest:App.user.id
					}, onHarvestAction, { pID:plant.sid, guest:true } );
				}else {
					Hints.text(Locale.__e('flash:1382952379907'), Hints.TEXT_RED,  new Point(App.map.scaleX*(x + width / 2) + App.map.x, y*App.map.scaleY + App.map.y));
					App.user.onStopEvent();
					return;
				}
				
			}
			
			// Уничтожаем растение
			removePlant();
			
			ordered = false;
			
			
		}
		
		private function onHarvestAction(error:int, data:Object, params:Object):void
		{
			
			if (error) {
				Errors.show(error, data);
				if(params && params.hasOwnProperty('guest')){
					App.user.friends.addGuestEnergy(App.owner.id);
				}
				return;
			}
			
			if (data.hasOwnProperty("out")) Treasures.bonus(Treasures.convert(data.out), new Point(this.x, this.y));
			
			if (state == TOCHED) touch = false;
			
			if (params != null) {
				if(params['friend'] != undefined) {
					var guest:Guest = params.friend;
					if (guest.friend['helped'] != undefined && guest.friend.helped > 0) {
						guest.friend.helped--;
					}
					if (guest.friend['helped'] == undefined || guest.friend.helped == 0) {
						guest.uninstall();
						guest = null;
					}
				}
				
				if (params['guest'] != undefined) {
					if (data.hasOwnProperty('energy')) {
						if(App.user.friends.data[App.owner.id].energy != data.energy){
							App.user.friends.data[App.owner.id].energy = data.energy;
							App.ui.leftPanel.update();
						}
					}
					App.user.friends.giveGuestBonus(App.owner.id);
				}
			}
		}
		
		/**
		 * Добавляем растение
		 */
		private var forView:Boolean = false;
		private function createPlant(pID:uint, planted:int = 0, forView:Boolean = false):void {
			if (plant) {
				removePlant();
			}
			
			plant = new Plant({
				id:0,
				sid:pID,
				planted:planted,
				x:coords.x,
				z:coords.z,
				field:this
			});
			App.map.addUnit(plant);
			
			if (forView) {
				this.forView = true;
				plant.alpha = 0.5;
			}else {
				this.forView = false;
				plant.alpha = 1;
			}
		}
		public function removePlant():void {
			sowing = false;
			if (plant) {
				App.map.removeUnit(plant);
				plant = null;
			}
		}
		
		/**
		 * По окончанию посадки семян
		 */
		private function onSowEvent():void
		{
			var self:Field = this;
			sowing = true;
			ordered = false;
			
			var item:Object = App.data.storage[pID];
			
			if (!App.user.stock.checkAll(item.require)) {
				openEnergyWindow();
				stopPlanting();
				return;
			}else if(!App.user.stock.checkAll(item.price)) {
				stopPlanting();
				return;
			}
			
			//createPlant(pID, App.time);
			if (plant && plant.planted == 0) {
				plant.planted = App.time;
			}
			
			clickable = false;
			touchable = false;
			
			Post.send( {
				ctr:this.type,
				act:'plant',
				uID:App.user.id,
				wID:App.user.worldID,
				sID:this.sid,
				id:id,
				pID:pID
			}, function(error:int, data:Object, params:Object):void {
				
				sowing = false;
				if (Field.planting.indexOf(self) >= 0)
					Field.planting.splice(Field.planting.indexOf(self), 1);
				
				if (error) {
					Errors.show(error, data);
					//App.map.removeUnit(plant);
					plant = null;
					ordered = false;
					return;
				}
				var currency:int = Stock.COINS;
				for (var itm:String in App.data.storage[data.pID].price) {
					currency = int(itm);
					var count:uint = parseInt(App.data.storage[data.pID].price[itm]);
					break;
				}
				
				App.user.stock.take(currency, count);
				//App.user.stock.setFantasy(data[Stock.FANTASY]);
				App.user.stock.data[Stock.FANTASY] = data[Stock.FANTASY];
				
				plant.planted = data.planted;
				clickable = true;
				touchable = true;
				
				Hints.minus(Stock.FANTASY, 1, new Point(self.x*App.map.scaleX + App.map.x, self.y*App.map.scaleY + App.map.y), true);
				Hints.minus(currency, count, new Point(self.x * App.map.scaleX + App.map.x, self.y * App.map.scaleY + App.map.y));
				App.map.allSorting();
			});
		}
		
		public override function uninstall():void {
			removePlant();
			super.uninstall();
		}
		
		override public function set filters(value:Array):void {
			super.filters = value;
			
			if (plant) plant.filters = value;
		}
		
		//private function onWheel(e:AppEvent):void {
		private function onWheel(e:MouseEvent):void {
			if (boost == 0) return;
			
			if (e.delta < 0) {
				if (multiSelect > 0)
					multiSelect--;
			}else {
				if (multiSelect < 49)
					multiSelect++;
			}
			
			clearForBoost();
			var numOfBoostedFields:int = chooseForBoost();
			if (multiSelect > numOfBoostedFields)
				multiSelect = numOfBoostedFields;
			
			e.stopImmediatePropagation();
			e.stopPropagation();
		}
		private function onMouseUp(e:AppEvent):void {
			if (!_touch) {
				Cursor.type = 'default';
				Cursor.material = 0;
				Cursor.text = App.user.stock.count(boost);
				clearBoost();
			}
		}
		
		private function onStartBoost(params:*):void {
			
			Field.boost = params;
			Cursor.type = 'boost';
			Cursor.material = Field.boost;
			Cursor.text = App.user.stock.count(boost);
			
			// Заполняем массив грядок и чистим их от лишних (без растений)
			var index:int = 0;
			var child:*;
			Field.fieldsOnMap = [];
			while (App.map.mField.numChildren > index) {
				child = App.map.mField.getChildAt(index);
				if (child && child.sid == this.sid)
					Field.fieldsOnMap.push(child);
				
				index++;
			}
		}
		
		public function chooseForBoost():int {
			if (!plant || plant.ready) return 0;
			if (fieldForBoost.length > 0 && fieldForBoost[0] == this) return 0;
			
			while (fieldForBoost.length) {
				var field:Field = fieldForBoost.shift();
				field.state = 4;
			}
			
			var nearestField:Field;
			var distance:Number;
			var predistance:Number;
			for (var i:int = 0; i < multiSelect; i++) {
				nearestField = null;
				distance = Math.sqrt(Map.cells * Map.cells + Map.rows * Map.rows);
				for (var j:int = 0; j < fieldsOnMap.length; j++) {
					if (fieldsOnMap[j].plant && !fieldsOnMap[j].plant.ready && fieldsOnMap[j].plant.sid == plant.sid && !fieldsOnMap[j].ordered && !fieldsOnMap[j].sowing) {
						predistance = Math.sqrt((fieldsOnMap[j].coords.x - this.coords.x) * (fieldsOnMap[j].coords.x - this.coords.x) + (fieldsOnMap[j].coords.z - this.coords.z) * (fieldsOnMap[j].coords.z - this.coords.z));
						if (fieldsOnMap[j] != this && fieldForBoost.indexOf(fieldsOnMap[j]) < 0 && distance > predistance) {
							nearestField = fieldsOnMap[j];
							distance = predistance;
						}
					}
				}
				
				if (nearestField)
					fieldForBoost.push(nearestField);
			}
			
			fieldForBoost.unshift(this);
			
			for (i = 0; i < fieldForBoost.length; i++)
				fieldForBoost[i].state = TOCHED;
			
			return fieldForBoost.length;
		}
		
		private static function clearForBoost():void {
			while (fieldForBoost.length) {
				var field:Field = fieldForBoost.shift();
				field.state = 4;
			}
		}
		public static function clearBoost():void {
			Cursor.material = 0;
			Cursor.type = 'default';
			Cursor.deleteText();
			Field.boost = 0;
			clearForBoost();
		}
		
		public static function clearPlant():void {
			Cursor.type = 'default';
			Cursor.material = 0;
			
			Field.clearBoost();
			ShopWindow.currentBuyObject.type = null;
			ShopWindow.currentBuyObject.sid = 0;
			
			if (App.map.moved is Field) {
				var field:Field = App.map.moved as Field;
				field = null;
				App.map.moved = null;
			}
		}
		
		public static function findUnit(sID:uint, id:uint):*
		{
			var i:int = App.map.mField.numChildren;
			while (--i >= 0)
			{
				var unit:* = App.map.mField.getChildAt(i);
				if (unit is Unit && unit.sid == sID  && unit.id == id)
				{
					return unit;
				}
			}
			
			return null;
		}
		
		public static function findFields():Array
		{
			var index:int = 0;
			var child:*;
			var list:Array = [];
			
			while (App.map.numChildren > index) {
				child = App.map.getChildAt(index);
				
				if (child is Field)
					list.push(child);
				
				index++;
			}
			
			return list;
		}
		
		public function startMultiStorage():void {
			
			if (Cursor.type != 'field_storage') {
				Cursor.type = 'field_storage';
				Cursor.image = Cursor.SICKLE;
				AnimalIcon.multiClickState = 'field_storage';
				AnimalIcon.multiClickTargetID = sid;
				App.self.stage.addEventListener(MouseEvent.MOUSE_UP, onMultiStorageMouseUp, false, 10);
			}
		}
		private function onMultiStorageMouseUp(e:MouseEvent = null):void {
			if (App.self.moveCounter > 2 && AnimalIcon.multiClickState == 'field_storage') return;
			
			App.self.stage.removeEventListener(MouseEvent.MOUSE_UP, onMultiStorageMouseUp);
			
			setTimeout(AnimalIcon.resetMultiClick, 50);
		}
	}
}
