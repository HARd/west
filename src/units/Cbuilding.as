package units 
{
	import core.Numbers;
	import core.Post;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.utils.setTimeout;
	import ui.UnitIcon;
	import wins.CbuildingWindow;
	import wins.ShopWindow;
	import wins.SimpleWindow;
	import wins.Window;
	
	public class Cbuilding extends Building 
	{
		
		public static var attach:Cbuilding;
		public var activeUnitID:*;
		
		public var slots:Object;
		
		public function Cbuilding(object:Object) 
		{
			slots = object.slots;
			
			super(object);
			
			// Добавить в поставленные юниты
			for each(var slot:Object in slots) {
				World.addBuilding(slot.sid);
			}
		}
		
		override public function onLoad(data:*):void {
			super.onLoad(data);
			
			updateUnits();
		}
		
		override public function initProduction(object:Object):void {
			var targetID:int = targetInCraft;
			if (targetID == -1) {
				crafting = false;
				crafted = 0;
				showIcon();
				return;
			}
			
			crafted = slots[targetID].crafted;
			
			if (crafted >= App.time && !crafting) {
				crafting = true;
				App.self.setOnTimer(production);
			}else if (crafted < App.time) {
				crafting = false;
				App.self.setOffTimer(production);
				showIcon();
			}
		}
		override protected function production():void {
			if (crafted < App.time)
				initProduction(slots);
		}
		
		override public function showIcon():void {
			if (App.user.mode == User.GUEST) return;
			
			if (crafted > 0 && crafted < App.time) {
				var formula:Object = completeCraftFormula;
				if (formula) {
					drawIcon(UnitIcon.REWARD, formula.out, 1, {
						glow:		true
					});
				}else {
					formula = completeCraftFormula;
				}
			}else {
				clearIcon();
			}
		}
		
		override public function openProductionWindow(settings:Object = null):void {
			new CbuildingWindow( {
				target:this
			}).show();
		}
		
		override public function stockAction(params:Object = null):void {
			
			if (!App.user.stock.check(sid)) {
				//TODO показываем окно с ообщением, что на складе уже нет ничего
				return;
			}else if (!World.canBuilding(sid)) {
				uninstall();
				return;
			}
			
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
				z:coords.z,
				level:0
			}, onStockAction);
		}
		
		
		
		/**
		 * Количество доступных слотов на уровне
		 */
		public function get slotsCount():int {
			if (info.devel && info.devel.req && info.devel.req[level])
				return info.devel.req[level].slots;
			
			return 0;
		}
		
		/**
		 * Количество занятых слотов на уровне
		 */
		public function get slotsBusy():int {
			return Numbers.countProps(slots);
		}
		
		/**
		 * Ближайший незанятый слот
		 */
		public function get freeSlotID():int {
			var slotID:int = 1;
			while (slots.hasOwnProperty(slotID)) {
				slotID++;
			}
			return slotID;
		}
		
		
		/**
		 * Покупка элемента
		 * @param	sid
		 */
		public function buyItem(sid:*):void {
			var price:Object = Storage.price(sid);
			if (!App.user.stock.checkAll(price))
				return;
			
			attachAction(sid, freeSlotID);
		}
		
		
		
		/**
		 * Покупка в слот
		 * @param	targetSID
		 * @param	slotID
		 */
		public function attachAction(targetSID:*, slotID:*):void {
			Post.send( {
				ctr:		type,
				act:		'attach',
				sID:		sid,
				id:			id,
				uID:		App.user.id,
				wID:		App.map.id,
				tsID:		targetSID,
				slotID:		slotID
			}, onAttachAction, { targetSID:targetSID, slotID:slotID });
		}
		protected function onAttachAction(error:int, data:Object, params:Object):void {
			if (error) {
				Errors.show(error, data);
				return;
			}
			
			slots = data.slots;
			World.addBuilding(params.targetSID);
			updateUnits();
			
			App.map.focusedOn(this, true);
			click();
		}
		
		
		
		/**
		 * Покупка в слот
		 * @param	targetSID
		 * @param	slotID
		 */
		public function dettachAction(slotID:*):void {
			Post.send( {
				ctr:		type,
				act:		'dettach',
				sID:		sid,
				id:			id,
				uID:		App.user.id,
				wID:		App.map.id,
				slotID:		slotID
			}, onDettachAction, { targetSID:slots[slotID].sid, slotID:slotID } );
		}
		protected function onDettachAction(error:int, data:Object, params:Object):void {
			if (error) {
				Errors.show(error, data);
				return;
			}
			
			if (slots.hasOwnProperty(params.slotID))
				delete slots[params.slotID];
			
			updateUnits();
			
			var cbuildingWindow:CbuildingWindow = Window.isClass(CbuildingWindow);
			if (cbuildingWindow.target == this) {
				cbuildingWindow.createContent();
				cbuildingWindow.contentChange();
			}
		}
		
		
		/**
		 * Вернуть targetID производимым крафтом
		 */
		public function get targetInCraft():int {
			for (var id:* in slots) {
				if (slots[id].crafted > 0)
					return id;
			}
			
			return -1;
		}
		
		
		/**
		 * Вернуть targetID с готовым крафтом
		 */
		public function get completeCraft():int {
			for (var id:* in slots) {
				if (slots[id].crafted > 0 && slots[id].crafted < App.time)
					return id;
			}
			
			return -1;
		}
		
		
		/**
		 * Вернуть формулу targetID с готовым крафтом
		 */
		public function get completeCraftFormula():Object {
			for (var id:* in slots) {
				if (slots[id].crafted > 0 && slots[id].crafted < App.time && slots[id].fID) {
					if (!(slots[id].fID is int)) {
						for each(var fid:* in App.time && slots[id].fID)
							return App.data.crafting[fid];
					}
					
					return App.data.crafting[slots[id].fID];
				}
			}
			
			return null;
		}
		
		
		/**
		 * Запустить крафт для определенного здания
		 */
		public function craftingAction(targetID:*, formulaID:*, callback:Function = null):void {
			Post.send( {
				ctr:	info.type,
				act:	'crafting',
				uID:	App.user.id,
				wID:	App.map.id,
				sID:	sid,
				id:		id,
				slotID:	targetID,
				fID:	formulaID
			}, function(error:int, data:Object, params:Object):void {
				if (callback != null)
					callback(data);
				
				if (error) return;
				if (!data) return;
				
				getBonus(data.bonus);
				updateUnits();
			});
			
		}
		
		
		/**
		 * Собрать крафт для определенного здания
		 */
		public function storageAction(targetID:*, callback:Function = null):void {
			Post.send( {
				ctr:	type,
				act:	'storage',
				uID:	App.user.id,
				wID:	App.map.id,
				sID:	sid,
				id:		id,
				slotID:	targetID
			}, function(error:int, data:Object, params:Object):void {
				if (error) return;
				
				updateUnits();
				
				if (callback != null)
					callback(data);
				
				initProduction(null);
			});
		}
		
		private var storageAllBonus:Object = { };
		public function storageAllAction():void {
			ordered = true;
			
			var that:* = this;
			var targetID:int = completeCraft;
			
			if (targetID >= 0) {
				storageAction(targetID, function(data:Object):void {
					var __bonus:Object = queueStorage(that.data[targetID], data);
					
					for (var s:* in __bonus) {
						if (!storageAllBonus[s]) storageAllBonus[s] = 0;
						storageAllBonus[s] += __bonus[s];
					}
					
					storageAllAction();
				});
				return;
			}
			
			ordered = false;
			
			getBonus(storageAllBonus);
			storageAllBonus = { };
		}
		
		
		/**
		 * Ускорение крафта
		 */
		public function boostAction(targetID:*, callback:Function = null, mID:int = 0):void {
			var params:Object = {
				ctr:	info.type,
				act:	'boost',
				uID:	App.user.id,
				wID:	App.map.id,
				sID:	sid,
				id:		id,
				slotID:	targetID
			}
			
			if (App.data.storage[mID] && App.data.storage[mID].type == 'Accelerator') {
				params['m'] = mID;
			}
			
			Post.send(params, function(error:int, data:Object, params:Object):void {
				if (error) return;
				
				if (callback != null)
					callback(data);
				
				initProduction(null);
				
			});
		}
		
		
		
		private var items:Object;
		private function updateUnits():void {
			if (!items) items = {};
			
			var unit:Unit;
			var slotID:*;
			
			// Удалить установленные юниты если их нет в списке
			for (slotID in items) {
				if (slots.hasOwnProperty(slotID)) continue;
				
				unit = items[slotID];
				if (!unit) continue;
				
				unit.uninstall();
				if (this == unit.parent)
					removeChild(unit);
				
				delete items[slotID];
			}
			for (slotID in slots) {
				if (items.hasOwnProperty(slotID)) continue;
				
				var position:Point = getPosition(slotID);
				unit = Unit.add( { sid:slots[slotID].sid, id:slotID, x:position.x, y:position.y, nonInstall:true } );
				unit.x = position.x;
				unit.y = position.y;
				unit.touchable = false;
				unit.clickable = false;
				addChild(unit);
				
				items[slotID] = unit;
			}
			for (slotID in items) {
				unit = items[slotID];
				if (!unit) continue;
				
				if (slots[slotID].crafted > App.time) {
					setAnimate(unit);
				}else {
					setNotAnimate(unit);
				}
			}
			
			function getPosition(slotID:int):Point {
				var point:Point = new Point();
				
				if (info.coords is String) {
					var array:Array = info.coords.split(';');
					if (array[slotID - 1]) {
						array = array[slotID - 1].split(':');
						if (array.length >= 2) {
							point.x = int(array[0]);
							point.y = int(array[1]);
						}
					}
				}
				
				return point;
			}
			function setAnimate(unit:Unit):void {
				if (!unit.textures) {
					setTimeout(setAnimate, 200, unit);
					return;
				}
				
				(unit as Building).crafting = true;
				(unit as Building).initAnimation();
				(unit as Building).beginAnimation();
			}
			function setNotAnimate(unit:Unit):void {
				if (!unit.textures) {
					setTimeout(setNotAnimate, 200, unit);
					return;
				}
				
				(unit as Building).crafting = false;
				(unit as Building).finishAnimation();
			}
		}
		private function removeUnits():void {
			for (var slotID:* in items) {
				var unit:Unit = items[slotID];
				if (!unit) continue;
				
				unit.uninstall();
				
				if (contains(unit))
					removeChild(unit);
			}
		}
		
		
		
		override public function uninstall():void {
			App.self.setOffTimer(production);
			
			removeUnits();
			
			super.uninstall();
		}
		
		
		
		
	}

}