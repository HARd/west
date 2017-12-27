package units 
{
	import core.Post;
	import flash.geom.Point;
	import flash.utils.setTimeout;
	import ui.UnitIcon;
	import wins.ConstructWindow;
	import wins.HutHireWindow;
	import wins.HutWindow;
	import wins.PurchaseWindow;
	import wins.ResourcehouseWindow;
	import wins.SimpleWindow;
	import wins.TechnoManagerWindow;
	import wins.Window;
	public class Resourcehouse extends Hut 
	{
		public var slots:Object = { };
		public function Resourcehouse(object:Object) 
		{
			if (object.hasOwnProperty('start')) {
				slots = object.start;
			}
			
			super(object);
			
			removable = false;
			
			setTimeout(hireWorkers, 2000);
		}
		
		private function hireWorkers():void {
			for each (var slot:* in slots) {
				if (slot + worktime > App.time) {
					findWorkerForSlot();
				}
			}
		}
		
		public function get worktime():int {
			if (info.devel.req.hasOwnProperty([this.level])) {
				return info.time + info.devel.req[this.level].bt;
			}
			
			return info.time;
		}
		
		public function get currPrice():Object {
			if (info.devel.foods.hasOwnProperty([this.level])) {
				return info.devel.foods[this.level];
			}
			
			return {};
		}
		
		override public function click():Boolean
		{
			if (App.user.mode == User.GUEST) {
				guestClick();
				return true;
			}
			
			if (level == 0 || (info.hasOwnProperty('devel') && info.devel.req.hasOwnProperty([this.level]) && info.devel.req[this.level].sl == 0)) {
				openConstructWindow();
				return true;
			}
			
			openProductionWindow();
			
			return true;
		}
		
		override public function openConstructWindow():Boolean 
		{
			for each (var slot:* in slots) {
				if (slot + worktime > App.time) {
					new SimpleWindow( {
						label:SimpleWindow.ATTENTION,
						text:Locale.__e('flash:1470818409192'),
						title:Locale.__e('flash:1382952379893'),
						popup:true
					}).show();
					return true;
				} else if (slot > 0 && slot + worktime <= App.time) {
					openProductionWindow();
					return true;
				}
			}
			drawIcon(UnitIcon.BUILD, null);
			
			new ConstructWindow( {
				title:			info.title,
				upgTime:		info.devel.req[level + 1].t,
				request:		info.devel.obj[level + 1],
				reward:			{},//info.devel.rew[level + 1],
				target:			this,
				win:			this,
				onUpgrade:		upgradeEvent,
				hasDescription:	true
			}).show();
			
			return true;
		}
		
		override public function openProductionWindow(settings:Object = null):void { 
			new ResourcehouseWindow( {
				target:this,
				slots:this.slots
			}).show();
		}
		
		override protected function onStockAction(error:int, data:Object, params:Object):void {
			if (error) {
				return;
			}			
			this.id = data.id;
			
			App.ui.glowing(this);
			World.addBuilding(this.sid);
			onAfterStock();
		}
		
		public function startSlot(slot:int, callback:Function = null):void {
			if (!findWorkerForSlot()) return;
			if (!App.user.stock.takeAll(currPrice)) {
				freeTechno();
				return;
			}
			
			Post.send( {
				ctr:this.type,
				act:'start',
				uID:App.user.id,
				wID:App.user.worldID,
				sID:this.sid,
				id:this.id,
				slot:slot
			}, onStartAction, {callback:callback, slot:slot});
		}
		
		public function onStartAction(error:int, data:Object, params:Object):void {
			if (error) {
				return;
			}	
			
			slots[params.slot] = data.start[params.slot];
			
			if (params.callback)
				params.callback(data.start[params.slot]);
		}
		
		public function storageAction(slot:int, callback:Function = null):void {
			Post.send( {
				ctr:this.type,
				act:'storage',
				uID:App.user.id,
				wID:App.user.worldID,
				sID:this.sid,
				id:this.id,
				slot:slot
			}, onStorage, {callback:callback, slot:slot});
		}
		
		public function onStorage(error:int, data:Object, params:Object):void {
			if (error) {
				return;
			}	
			
			if (data.hasOwnProperty('bonus')) {
				Window.closeAll();
				Treasures.bonus(Treasures.convert(data.bonus), new Point(this.x, this.y)) 
			}
			
			freeTechno();
			
			if (slots.hasOwnProperty(params.slot)) {
				slots[params.slot] = 0;
			}
		}
		
		public function boostAction(slot:int, callback:Function = null):void {
			if (!App.user.stock.take(Stock.FANT, info.devel.req[level].skip)) return;
			
			Post.send( {
				ctr:this.type,
				act:'boost',
				uID:App.user.id,
				wID:App.user.worldID,
				sID:this.sid,
				id:this.id,
				slot:slot
			}, onBoostAction, {callback:callback, slot:slot});
		}
		
		public function onBoostAction(error:int, data:Object, params:Object):void {
			if (error) {
				return;
			}	
			
			slots[params.slot] = data.start[params.slot];
			
			freeTechno();
			
			if (params.callback)
				params.callback(data.start[params.slot]);
		}
		
		private function findWorkerForSlot():Boolean {
			var worker:* = Techno.findTechnosForWork(worktime, 1);
			if (worker is String) {
				var notText:String = Locale.__e('flash:1427716990553');
				if (App.user.worldID == Travel.SAN_MANSANO) notText = Locale.__e('flash:1470212158544');
				if (worker == 'not_much') {
					new SimpleWindow( {
						title:		info.title,
						text:		notText,
						popup:		true,
						confirm:	function():void {
							App.ui.upPanel.onWorkersEvent()
						}
					}).show();
				}else if (worker == 'busy') {
					new SimpleWindow( {
						title:		info.title,
						text:		Locale.__e('flash:1427716915911'),
						popup:		true,
						confirm:    onBuyTechno
					}).show();
				}else if (worker == 'busy_time') {
					Window.closeAll();
					var items:Array = Map.findUnits([160, 461, 278, 752]);
					if (items.length > 0) {
						new TechnoManagerWindow( {
							
						}).show();
					}else {
						new SimpleWindow( {
							title:		info.title,
							text:		notText,
							popup:		true,
							confirm:	function():void {
								App.ui.upPanel.onWorkersEvent()
							}
						}).show();
					}
				}else if (worker == 'not_enough_time') {
					new SimpleWindow( {
						title:		info.title,
						text:		Locale.__e('flash:1438847074566'),
						popup:		true,
						confirm:    onHutUpdateOpen
					}).show();
				}
				return false;
			} else if (worker is Array && worker.length == 0) {
				new SimpleWindow( {
					title:		info.title,
					text:		notText,
					popup:		true,
					confirm:	function():void {
						App.ui.upPanel.onWorkersEvent()
					}
				}).show();
				return false;
			}
			worker[0].workStatus = WorkerUnit.BUSY;
			worker[0].workEnded = App.time + worktime;
			worker[0].target = this;
			worker[0].visible = false;
			
			return true;
		}
		
		private function onBuyTechno():void {
			var technoName:String = 'workers';
			if (App.user.worldID == Travel.SAN_MANSANO) technoName = 'worker_staratel';
			var content:Array = PurchaseWindow.createContent('Energy', { view:technoName } );
			new PurchaseWindow( {
				width:595,
				itemsOnPage:App.user.worldID == Travel.SAN_MANSANO ? content.length : 3,
				content:content,
				title:App.user.worldID == Travel.SAN_MANSANO ? Locale.__e('flash:1470210237983') : Locale.__e("flash:1382952379828"),
				fontBorderColor:0xd49848,
				shadowColor:0x553c2f,
				shadowSize:4,
				hasDescription:App.user.worldID == Travel.SAN_MANSANO ? false : true,
				description:Locale.__e("flash:1427363516041"),
				popup: true,
				callback:function(sID:int):void {
					var object:* = App.data.storage[sID];
					App.user.stock.add(sID, object);
				}
			}).show();
		}
		
		private function freeTechno():void {
			for each (var techno:* in App.user.techno) {
				if (techno.target == null) continue;
				if (techno.workStatus == WorkerUnit.BUSY && techno.target.sid == this.sid && techno.target.id == this.id) {
					techno.workStatus = WorkerUnit.FREE;
					techno.workEnded = 0;
					techno.targetObject = null;
					techno.target = null;
					techno.visible = true;
					return;
				}
			}
		}
		
		private function onHutUpdateOpen():void
		{
			var items:Array = Map.findUnits([Techno.TECHNO]);
			var target:*;
			var full:Boolean = false;
			var hungry:Boolean = false;
			for each (var unit:* in items) {
				for each (var s:* in unit.workers) {
					if (s.finished > 0 && s.finished < App.time + worktime) {
						target = unit;
						if (s.finished > App.time) {
							full = true;
						} else {
							hungry = true;
						}
						break;
					}
				}
			}
			if (target)
			{
				if (full) {
					new HutWindow( {
						target:		target,
						sID:		Techno.TECHNO,
						popup:      true,
						glowUpgrade:  true
					}).show();
					return;
				}
				
				new HutHireWindow( {
						target:		target,
						sID:		Techno.TECHNO,
						popup:      true,
						glowUpgrade:  true
					}).show();
			}
		}
		
	}

}