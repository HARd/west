package units 
{
	import api.ExternalApi;
	import core.Post;
	import core.TimeConverter;
	import flash.geom.Point;
	import ui.UnitIcon;
	import wins.ProductionWindow;
	import wins.SimpleWindow;
	import wins.StationProductionWindow;
	import wins.Window;
	
	public class Tstation extends Building 
	{
		public var train:*;
		public var slots:Object;
		public var started:int = 0;
		public function Tstation(object:Object) 
		{
			super(object); 
			
			slots = object.slots;
			
			initProduction(object);
			
			touchableInGuest = true;			
			removable = false;
			moveable = false;
			rotateable = false;
			
			started = object.started;
			
			if (started < App.midnight && level >= totalLevels && sid != 906) {
				refreshSlots();
			}
			
			if (level >= totalLevels && !train && sid == 794) {
				addTrain();
			}
			
			showIcon();
			
			tip = function():Object 
			{
				if (App.user.mode == User.GUEST)
				{
					return {
						title:info.title,
						text:info.description
					};
				}
				if (sid == 668) {
					return {
						title:info.title,
						text:info.description
					};
				}
				if (hasProduct) {
					var text:String = '';
					if (formula)
						text = App.data.storage[formula.out].title;
					
					return {
						title:info.title,
						text:Locale.__e("flash:1382952379845", [text]),
						timer:false
					};
				} else if (created > 0 && !hasBuilded) {
					return {
						title:info.title,
						text:Locale.__e('flash:1395412587100') +  '\n' + TimeConverter.timeToStr(created-App.time),
						timer:true
					}
				} else if (upgradedTime > 0 && !hasUpgraded) {
					return {
						title:info.title,
						text:Locale.__e('flash:1395412562823') +  '\n' + TimeConverter.timeToStr(upgradedTime-App.time),
						timer:true
					}
				} else if (crafting) {
						return {
						title:info.title,
						text:Locale.__e(Locale.__e('flash:1395853416367') +  '\n' + TimeConverter.timeToStr(crafted-App.time)),
						timer:true
					}
				}
				
				var defText:String = '';
				var prevItm:String;
				if (this.info.type == 'Tstation') {
					if (info.hasOwnProperty('devel') && info.devel.hasOwnProperty('craft')) {
						for (var itm:String in this.info.devel.craft[totalLevels]) {
							if (App.data.crafting[this.info.devel.craft[totalLevels][itm]])
							{
								if (prevItm && prevItm == App.data.storage[App.data.crafting[this.info.devel.craft[totalLevels][itm]].out].title) break;
								if (!User.inUpdate(App.data.crafting[this.info.devel.craft[totalLevels][itm]].out)) break;
								if (defText.length > 0) defText += ', ';
								defText += App.data.storage[App.data.crafting[this.info.devel.craft[totalLevels][itm]].out].title;
								prevItm = App.data.storage[App.data.crafting[this.info.devel.craft[totalLevels][itm]].out].title;
							}
						}
					}
				}
				
				if (defText.length > 0) {
					return {
						title:info.title,
						text:Locale.__e('flash:1404823388967', [defText]),
						timer:false
					};
				} else {
					return {
						title:info.title,
						text:info.description
					};
				}
				
			}
		}
		
		override public function click():Boolean 
		{
			if (sid == 906 && App.user.mode != User.GUEST) {
				if (App.isSocial(/*'MX', 'YB',*/ 'AI')) {
					new SimpleWindow( {
						label:SimpleWindow.ATTENTION,
						title:Locale.__e("flash:1429185188688"),
						text:Locale.__e('flash:1442504324546'),
						height:300
					}).show();
					return true;
				}
				swapPort();
				return true;
			}
			if (cantClick)
				return false;
			
			if (App.user.mode == User.GUEST) {
				guestClick();
				return true;
			}
			
			//if (!super.click() || this.id == 0) return false;
			
			if (!isReadyToWork()) return true;
			
			if (isPresent()) return true;
			
			if (isProduct()) return true;
			
			if (openConstructWindow()) return true;	
			
			openProductionWindow();
			
			return true;
		}
		
		private function swapPort():void {
			uninstall();
			Post.send({
				'ctr':'building',
				'act':'swap',
				'uID':App.user.id,
				'wID':App.user.worldID,
				'sID':906,
				'id':this.id,
				'tID':918,
				'level':0
			}, function(error:*, response:*, params:*):void {
				if (!error) {
					var newBuild:Building = new Tstation( { id:response.id, sid:918, level:0, x:coords.x, z:coords.z } );
				}
			});
			return;	
		}
		
		override public function openProductionWindow(settings:Object = null):void 
		{
			if (App.user.quests.tutorial && App.tutorial && App.tutorial.step == 31) return;
			
			new StationProductionWindow( {
				title:			info.title,
				crafting:		this.slots,
				target:			this,
				onCraftAction:	onCraftAction,
				hasPaginator:	true,
				hasButtons:		true,
				find:helpTarget
			}).show();
		}
		
		override public function updateLevel(checkRotate:Boolean = false, mode:int = -1):void 
		{
			super.updateLevel(checkRotate, mode);
			
			if (level >= totalLevels && !train && sid == 794) {
				addTrain();
			}
			
			/*for each (var pid:* in slots) {
				for (var slot:* in pid) {
					var formula:Object = App.data.crafting[slot];
					if (pid[slot] > 0 && pid[slot] >= App.time)
					{
						App.self.setOffTimer(production);
					}
				}
			}*/
		}
		
		override public function checkProduction():void {
			completed = [];
			crafting = false;
			
			for each (var pid:* in slots) {
				for (var slot:* in pid) {
					if (pid[slot] > 0) {
						var formula:Object = App.data.crafting[slot];
						if (pid[slot] <= App.time) {
							hasProduct = true;
							//formula = getFormula(slot);
							showIcon();
						}else {
							beginCraft(fID, pid[slot]);
						}
					}
				}
			}
			
			checkOnAnimationInit();
		}
		
		public function changeSlot(slot:int):void {
			
			if (!App.user.stock.take(Stock.FANT, 1)) return;
			Post.send({
					ctr:this.type,
					act:'change',
					uID:App.user.id,
					id:this.id,
					wID:App.user.worldID,
					sID:this.sid,
					slot:slot
				}, function(error:*, data:*, params:*):void {
					
					if (error) {
						Errors.show(error, data);
						return;
					}
					
					if (data.hasOwnProperty('slots')) {
						slots = data.slots;
					}
					
					openProductionWindow();
				});
		}
		
		public function addTrain():void 
		{
			train = Unit.add( {
				sid:	785,
				id:		1,
				x:		142,
				z:		84
			});
			train.cell = 142;
			train.row = 84;
			App.map.sorting();
			train.framesType = Personage.STOP;
			train.station = this;
			
			if (crafting) {
				train.alpha = 0;
			}
			
			var count:int = 0;
			var countCraft:int = 0;
			for each(var pid:* in slots) {
				for (var slot:* in pid) {
					if (pid[slot] > 0 && pid[slot] > App.time) {
						countCraft++;
					}
				}
				count++;
			}
			
			if (count != 0 && count == countCraft) {
				train.alpha = 0;
			}
		}
		
		public function onBoost(slot:int, count:int = 0):void 
		{
			var that:* = this;
			if (!App.user.stock.take(Stock.FANT, count)) return;
				
				App.self.setOffTimer(production);
				
				crafted = App.time;
				onProductionComplete();
				
				cantClick = true;
				currentSlot = slot;
				
				Post.send({
					ctr:this.type,
					act:'fboost',
					uID:App.user.id,
					id:this.id,
					wID:App.user.worldID,
					sID:this.sid,
					slot:slot
				}, function(error:*, data:*, params:*):void {
					
					if (error) {
						Errors.show(error, data);
						return;
					}
					
					cantClick = false;
					hasProduct = true;
					
					if (data.hasOwnProperty('crafted')) {
						if (currentSlot != -1) {
							for (var itm:* in slots[currentSlot]) {
								slots[currentSlot][itm] = data.crafted;
								break;
							}
						}
						currentSlot = -1;
					}
					
					if (train) {
						train.trainReturn();
					}
					showIcon();
					SoundsManager.instance.playSFX('bonusBoost');
				});
		}

		override public function onStorageEvent(error:int, data:Object, params:Object):void 
		{			
			if (error)
			{
				Errors.show(error, data);
				return;
			}
			
			if (App.user.quests.tutorial) {
				try {
					if (data.bonus.hasOwnProperty('228')) {
						App.user.stock.addAll(data.bonus);
						App.user.stock.add(234, 1);
						App.user.stock.data[234] = -1;
						data.bonus = { 234:1 };
					}
				}catch(e:*) {}
			}
			//formula
			if (data.hasOwnProperty('bonus')) {
				var that:* = this;
				if (train) that = train;
				Treasures.bonus(/*Treasures.convert(*/data.bonus/*)*/, new Point(that.x, that.y));
			} 
			
			if (data.hasOwnProperty('slots')) {
				slots = data.slots;
			}
			
			clearIcon();
			if (train) train.clearIcon();
			
			ordered = false;
			hasProduct = false;
			queue = [];
			crafted = 0;
		}
		
		override public function isProduct(value:int = 0):Boolean
		{
			if (hasProduct)
			{
				/*var price:Object = getPrice();
				
				var out:Object = { };
				out[formula.out] = formula.count;
				if (!App.user.stock.checkAll(price))	return true; */ // было false
				
				// Отправляем персонажа на сбор
				storageEvent();
				
				return true; 
			}
			return false;
		}
		
		override public function storageEvent(value:int = 0):void
		{
			hasProduct = false;
			
			var i:int = 0;
			for each (var pid:* in slots) {
				for (var slot:* in pid) {
					if (pid[slot] > 0 && pid[slot] <= App.time) {
						Post.send({
							ctr:this.type,
							act:'storage',
							uID:App.user.id,
							id:this.id,
							wID:App.user.worldID,
							sID:this.sid,
							slot:i
						}, onStorageEvent);
					}
					i++;
				}
			}	
		}
		
		override public function onBonusEvent(error:int, data:Object, params:Object):void 
		{
			if (error) {
				Errors.show(error, data);
				return;
			}
			
			removeEffect();
			showIcon();
			
			if (data.hasOwnProperty('slots')) {
				slots = data.slots;
			}
			
			if(info.devel.hasOwnProperty('rew')) {
				Treasures.bonus(Treasures.convert(info.devel.rew[level]), new Point(this.x, this.y));
			}
		}
		
		public var currentSlot:int = -1;
		public function onCraft(fID:uint, slot:int):void
		{
			var isBegin:Boolean = true;
				
			var formula:Object = App.data.crafting[fID];
			
			if(formula.time > 0){
				beginCraft(fID, App.time + formula.time);
				
				checkOnAnimationInit();				
				Window.closeAll();
			}
			
			for (var sID:* in formula.items){
				App.user.stock.take(sID, formula.items[sID]);
			}
			currentSlot = slot;
			
			Post.send({
				ctr:this.type,
				act:'crafting',
				uID:App.user.id,
				id:this.id,
				wID:App.user.worldID,
				sID:this.sid,
				fID:fID,
				slot:slot
			}, onCraftEvent);
		}
		
		override protected function onCraftEvent(error:int, data:Object, params:Object):void 
		{
			if (error) {
				Errors.show(error, data);
				cancelCraft();
				return;
			}
			
			if (data.hasOwnProperty('crafted')) {
				if (currentSlot != -1) {
					for (var itm:* in slots[currentSlot]) {
						slots[currentSlot][itm] = data.crafted;
						break;
					}
				}
				currentSlot = -1;
			}else {
				ordered = false;
				hasProduct = false;
				queue = [];
				crafted = 0;
				//onStorageEvent(error, data, params);
			}
			
			App.self.setOnTimer(production);
			showIcon();
			//Создание ресурса в OG
			if (App.social == 'FB') {
				ExternalApi.og('create','resource');
			}
		}
		
		override public function beginCraft(fID:uint, crafted:uint):void
		{
			/*formula = getFormula(fID);
			if (crafted == 0) crafted = App.time + formula.time;
			
			this.fID = fID;
			this.crafted = crafted;
			began = crafted - formula.time;
			crafting = true;
			open = true;*/
			showIcon();
			
			App.self.setOnTimer(production);
			if (train) train.trainToGo();
		}
		
		override public function onProductionComplete():void {
			if (train) train.trainReturn();
			hasProduct = true;
			showIcon();
			//super.onProductionComplete();
		}
		
		override public function get progress():Boolean {
			for each (var pid:* in slots) {
				for (var slot:* in pid) {
					var formula:Object = App.data.crafting[slot];
					if (pid[slot] > 0 && pid[slot] < App.time)
					{
						onProductionComplete();
						//if (queue.length - completed.length <= 0) return true;
						/*if (crafted <= App.time)*/ return true;
					}
				}
			}
			
			return false;
		}
		
		public function refreshSlots():void {
			if (App.user.mode == User.GUEST) return;
			Post.send({
					ctr:this.type,
					act:'refresh',
					uID:App.user.id,
					id:this.id,
					wID:App.user.worldID,
					sID:this.sid/*,
					slot:slot*/
				}, function(error:*, data:*, params:*):void {
					
					if (error) {
						Errors.show(error, data);
						return;
					}
					
					if (data.hasOwnProperty('slots')) {
						slots = data.slots;
					}
					
					started = data.started;
					
					//openProductionWindow();
				});
		}
		
		override public function showIcon():void {
			if (!formed || !open) return;
			clearIcon();
			
			for each (var pid:* in slots) {
				for (var slot:* in pid) {
					var formula:Object = App.data.crafting[slot];
					if (App.user.mode == User.OWNER) {	
						if (pid[slot] > 0 && pid[slot] <= App.time /*&& hasProduct*/ && formula) {
							if (train) {
								//clearIcon();
								train.showTrainIcon();
								return;
							} else {
								drawIcon(UnitIcon.REWARD, formula.out, 1, {
									glow:		true
								});
								return;
							}
						}
						if (pid[slot] > 0 && pid[slot] >= App.time && pid[slot]) {
							drawIcon(UnitIcon.PRODUCTION, formula.out, 1, {
								progressBegin:	pid[slot] - formula.time,
								progressEnd:	pid[slot]
							});
						}else if (hasPresent) {
							drawIcon(UnitIcon.REWARD, 2, 1, {
								glow:		true
							});
						}else if (hasBuilded && upgradedTime > 0 && upgradedTime > App.time && level < totalLevels) {
							drawIcon(UnitIcon.BUILDING, null, 0, {
								clickable:		false,
								boostPrice:		info.devel.skip[level + 1],
								progressBegin:	upgradedTime - info.devel.req[level + 1].t,
								progressEnd:	upgradedTime,
								onBoost:		function():void {
									acselereatEvent(info.devel.skip[level + 1]);
								}
							});
						}else if ((craftLevels == 0 && level < totalLevels) || (craftLevels > 0 && level < totalLevels - craftLevels + 1)) {
							drawIcon(UnitIcon.BUILD, null);
						}else {
							//clearIcon();
						}
					}else if (App.user.mode == User.GUEST) {
						drawIcon(UnitIcon.REWARD, 2, 1, {
							glow:		false
						});
					}
				}
			}
		}
		
	}

}