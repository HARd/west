package units 
{
	import core.Numbers;
	import core.Post;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import ui.Cursor;
	import ui.Hints;
	import wins.MhelperWindow;
	import wins.SimpleWindow;
	import wins.Window;
	
	public class Mhelper extends Golden
	{
		public static const READY:int = 1;
		public static const UNREADY:int = 2;
		public static const UNBOOST:int = 3;
		public static const BOOST:int = 4;
		public var stacks:uint = 0;
		public var permittedTargets:Object = null;
		public function Mhelper(object:Object) 
		{
			super(object);
			object.slots = object.slots || 0;
			stacks = object.slots /*+ info.start*/;
			this.info['moveable'] = 1;
			
			stockable = false;
			
			if (info.hasOwnProperty('targets')) {
				permittedTargets = info.targets;
			}
			if ( object.units )
			{
				for (var index:String  in object.units)
				{
					var item:Object = object.units[index];
					item['info'] = App.data.storage[item.sid];
					targets[index] = item;
				}
			}
			/*if (formed && Map.ready) {
				goHome();
			}*/
			else
				App.self.addEventListener(AppEvent.ON_MAP_COMPLETE, onMapComplete);
			if (App.user.mode == User.GUEST)
				clearIcon();
			tip = function():Object {
				return {
					title:		info.title,
					text: info.description
				};
			}
		}
		
		public function get targetsLength():int
		{
			var re:int = 0;
			for (var i:String in targets)
				re++;
			return re;
		}
		private function onMapComplete(e:AppEvent):void {
			App.self.removeEventListener(AppEvent.ON_MAP_COMPLETE, onMapComplete);
			/*if (formed) {
				//find();
				goHome();
				
			}*/
		}
		public var targets:Array = [];
		public function get posibleTargets ():Array {
			var arr: Array = Map.findUnitsByType(["Walkgolden", "Golden"]);
			var result:Array = [];
			for each (var key:Object in arr)
				if (/*!( App.data.storage[key.sid].hasOwnProperty ("block") && App.data.storage[key.sid].block ) &&*/ /*!key.lock &&*/ key.hasOwnProperty('lock') && (!App.data.storage[key.sid].hasOwnProperty('capacity') || App.data.storage[key.sid].capacity == 0) )
					result.push (key.sid);
			return result;
		}
		public function getTime (item:Object):int
		{
			return item.crafted - App.time;
		}
		public function cheackState(object:Object):Object 
		{
			var re:Object = {};
			if ( getTime(object) < 10 )
			{
				re['isReady'] = READY;
			}
			else
			{
				re['isReady'] = UNREADY;
			}
			if (object.info.block || object.info.type == "Changeable" || object.info.canboost == 0)
			{
				re['isBoost'] = UNBOOST;
			}
			else
			{
				re['isBoost'] = BOOST;
			}
			return re;
		}

		public function getPriceItems (object:Object = null):int
		{
			if ( object )
			{
				return App.data.storage[object.sid].skip;
			}
			var re:int = 0;
			for each(var item:Object in targets)
			{
				var check:Object = cheackState(item);
				if (check.isBoost == BOOST && check.isReady == UNREADY)
					re += App.data.storage[item.sid].skip;
			}
			return re;
		}
		override public function click():Boolean 
		{
			if (App.user.mode == User.GUEST)
				return false;
			new MhelperWindow( { target:this } ).show();
			return true;
		}
		public function findBoost():Object
		{
			var re:Object = {};
			//find();
			for each (var item:Object in targets)
			{
				var check:Object = cheackState(item);
				if (check.isBoost == BOOST && check.isReady == UNREADY)
					re [targets.indexOf (item)] =  item.sid;
					
					//re.push( { (targets.indexOf (item)): item.sid } );
			}
			return re;
		}
		public function findCollect():Object
		{
			var re:Object = { };
			//find();
			for each (var item:Object in targets)
			{
				var check:Object = cheackState(item);
				if (check.isReady == READY)
					re [targets.indexOf (item)] =  item.sid;
					//re.push( { sID:item.sid, ID:targets.indexOf (item) } );
			}
			return re;
		}
		public static var chooseTargets:Array = [];
		public static var clickCounter:int = 0;
		public function startAttch():void
		{
			chooseTargets = [];
		}
		public function onCancel():void {
			App.ui.upPanel.hideHelp();
			App.ui.upPanel.hideCancel();
			Cursor.type = 'default';
			unselectTargets();
			waitForTarget = false;
			waitWorker = null
		}
		public function unselectTargets():void {
			var _posibleTargets:Array = Map.findUnits(posibleTargets);
			for each(var res:* in _posibleTargets)
			{
				if (res.state == res.HIGHLIGHTED) {
					res.state = res.DEFAULT;
					
				}
				res.lock = false;
			}
			lockTargets();
		}
		public function unselectPossibleTargets(e:MouseEvent = null):void
		{
			
			if (App.self.moveCounter > 3)
				return;
			if (waitForTarget )
				return;
			App.self.removeEventListener(MouseEvent.CLICK, unselectPossibleTargets);
			App.ui.upPanel.hideHelp();
			App.ui.upPanel.hideCancel();
			Cursor.type = 'default';
			unselectTargets();
			lockExludes(false);
			waitForTarget = false;
			waitWorker = null;
		}
		private function lockTargets():void
		{
			/*var arr: Array = Map.findUnitsByType(["Helper"]);
			for each (var helper:Helper in arr)
			{
				helper.lockTargets();
			}*/
		}
		public function lockExludes(flag:Boolean = true):void
		{
			var exludes:Array = JSON.parse(App.data.options.MhelperExludes) as Array;
			var exludesUnits:Array = Map.findUnits(exludes);
			for each(var unit:* in exludesUnits)
			{
				var skip:Boolean = false;
				if (permittedTargets != null) {
					for each (var targ:* in permittedTargets) {
						if (unit.sid == targ) {
							skip = true;
							break;
						}
					}
				}
				
				if ( unit.hasOwnProperty ('lock') && !skip)
					unit.lock = flag;
			}
		}
		
		public function isExclude(sID:int):Boolean {
			var exludes:Array = JSON.parse(App.data.options.MhelperExludes) as Array;
			
			if (permittedTargets != null) {
				for each (var targ:* in permittedTargets) {
					if (sID == targ) {
						return false;
					}
				}
				
				return true;
			}
			
			if (exludes.indexOf(sID) == -1) return false;
			return true;
		}
		
		public function onConfirm():void {
			attachAction();
			App.ui.upPanel.hideHelp();
			App.ui.upPanel.hideCancel();
			Cursor.type = 'default';
			unselectTargets();
			waitForTarget = false;
			waitWorker = null
		}
		public static var waitWorker:Mhelper;
		public static function addTarget(target:*):void {
			//if (waitWorker.posibleTargets.indexOf(target.sid) == -1) return;
			
			if (waitForTarget &&  chooseTargets.length + waitWorker.targetsLength < waitWorker.stacks && chooseTargets.indexOf(target) == -1) {
				chooseTargets.push(target);
			}
			
			if (chooseTargets.length + waitWorker.targetsLength >= waitWorker.stacks) {
				App.ui.upPanel.hideCancel();
				Cursor.type = 'default';
				waitForTarget = false;
				if (waitWorker) {
					var targets:Object = [];
					for each (var unit:* in chooseTargets) {
						var object:Object = { };
						object[unit.sid] = unit.id;
						targets.push(object);
						
					}
					
					waitWorker.attachAction();
				}
			}else {
				App.ui.upPanel.showHelp(Locale.__e('flash:1455616106139') + ' ' + (chooseTargets.length + waitWorker.targetsLength) + "/" +  waitWorker.stacks, 0);
			}
		}
		//public function collectinAction(item:Object,win:MhelperWindow):void
		//{
			//
			//var that:Mhelper = this;
			//Post.send({
				//ctr:this.type,
				//act:'collectin',
				//uID:App.user.id,
				//id:this.id,
				//wID:App.user.worldID,
				//sID:this.sid,
				//iID:targets.indexOf(item)
			//}, function(error:*, data:*, params:*):void {
				//if ( error )
				//{
					//return;
				//}
				//Treasures.bonus(data.bonus, new Point(that.x, that.y));
				//SoundsManager.instance.playSFX('bonus');
				//win.contentChange();
			//});
		//}
		public function attachAction():void 
		{
			if (!chooseTargets || chooseTargets.length < 1)
				return;
			var _target:Array = [];
			for each ( var item:Object in  chooseTargets)
			{
				_target.push( { sID:item.sid, ID:item.id } );
			}
			
			var that:Mhelper = this;
			Post.send({
				ctr:this.type,
				act:'attach',
				uID:App.user.id,
				id:this.id,
				wID:App.user.worldID,
				sID:this.sid,
				units:JSON.stringify(_target)
			}, function(error:*, data:*, params:*):void {
				for each (var item:Object in chooseTargets) {
					that.targets[that.targets.length] = { sid:item.sid, id:item.id, info: App.data.storage[item.sid], crafted: item.crafted , started: item.started }; // извращуга
					item.uninstall();
				}
				chooseTargets = [];
			});
		}
		public function startDetach(item:Object, win:MhelperWindow = null):void
		{
			waitWorker = this;
			detachIID = targets.indexOf(item);
			item['id'] = 0;
			item['fromMhelper'] = true;
			item.info['moveable'] = false;
			var unit:Unit = add(item);
			unit.move = true;
			App.map.moved = unit;
			
		}
		public function stopDetach():void
		{
			waitWorker = null;
			detachIID = -1;
		}
		public var detachIID:int = -1;
		override protected function onStockAction(error:int, data:Object, params:Object):void 
		{
			super.onStockAction(error, data, params);
			stacks = info.start;
		}
		
		override protected function onBuyAction(error:int, data:Object, params:Object):void 
		{
			super.onBuyAction(error, data, params);
			stacks = info.start;
		}
		public static function detachAction(item:Object):void
		{
			if (waitWorker.detachIID < 0) return;
			item.fromMhelper = false;
			//var that:Mhelper = this;
			Post.send({
				ctr:waitWorker.type,
				act:'detach',
				uID:App.user.id,
				id:waitWorker.id,
				wID:App.user.worldID,
				sID:waitWorker.sid,
				iID:waitWorker.detachIID,
				x:item.coords.x,
				z:item.coords.z
				}, function(error:*, data:*, params:*):void {
				
				if (!error && data) 
				{
					//waitWorker.targets.removeAt (waitWorker.detachIID);
					var tempArr:Array = new Array();
					for (var index:String in waitWorker.targets)
					{
						if ( int (index) != waitWorker.detachIID )
							tempArr[index] = waitWorker.targets[index];
					}
					waitWorker.targets.length = 0;
					waitWorker.targets = tempArr;
					item.beginCraft(0, item.crafted);
					waitWorker.detachIID = -1;
					item.moveable = true;
					waitWorker = null;
					if ( item.info.type == 'Walkgolden') {
						item.goHome();
						//item.removeChild(item.contLight);
						//item.contLight = null;
						//item.info['moveable'] = App.data.storage[item.sid]['moveable'];
					}
					if ( item.info.type == 'Golden')
					{
						item.initAnimation();
						item.beginAnimation();
						//item.clearGrid();
					}
					item.open = true;
					if (data.hasOwnProperty('id'))
						item.id = data.id;
				}
				
			});
		}
		public function speedAction(win:MhelperWindow, item:Object = null):void 
		{
			var queryString:String = '';
			if (!item)
				queryString = JSON.stringify(findBoost());
			else
				queryString = JSON.stringify({(targets.indexOf (item)):  item.sid});
			//var that:Object = this;
			if ( App.user.stock.take(Stock.FANT,getPriceItems(item)) )
			{
				Post.send({
					ctr:this.type,
					act:'speedin',
					uID:App.user.id,
					id:this.id,
					wID:App.user.worldID,
					sID:this.sid,
					units:queryString
				}, function(error:*, data:*, params:*):void {
					var point:Point = new Point (App.self.stage.mouseX, App.self.stage.mouseY);
					Hints.minus(Stock.FANT,getPriceItems(item), point,true,win);
					if (!error && data) 
					{
						for (var index:String in data.crafted)
						{
							if (targets[index].info.type == 'Golden')
								targets[index].started = App.time - targets[index].info.time;
							else
								targets[index].started = targets[index].crafted;
							targets[index].crafted = data.crafted[index];
						}
					}
					win.contentChange();
					win.blockAll(false);
				});
			}
		}
		
		public static var waitForTarget:Boolean = false;
		public function collectAction(win:MhelperWindow, item:Object = null):void 
		{
			var queryString:String = '';
			var fin:Object = findCollect();
			if (!item)
				queryString = JSON.stringify(fin);
			else
				queryString = JSON.stringify({(targets.indexOf (item)):  item.sid});
			var that:Object = this;
			//if (App.user.stock.take(Stock.FANTASY, ((item)?1:Numbers.countProps(fin))))
			{
				Post.send({
					ctr:this.type,
					act:'collectin',
					uID:App.user.id,
					id:this.id,
					wID:App.user.worldID,
					sID:this.sid,
					units:queryString//JSON.stringify(findCollect())
				}, function(error:*, data:*, params:*):void {
					
					if (!error && data) 
					{
						//var point:Point = Window.localToGlobal(win.bodyContainer);
						var point:Point = new Point (App.self.stage.mouseX, App.self.stage.mouseY);
						//point.x = win.bodyContainer
						//App.ui.upPanel.update(['coins']);
						//App.ui.upPanel.update(['exp']); 
						//App.ui.upPanel.update(['fants']); 
						var tempBonus:Object = { };
						for (var _sid:String in data.bonus)
						{
							for (var _instance:String in data.bonus[_sid])
							{
								tempBonus[_sid] = int( data.bonus[_sid][_instance]) * int (_instance);
							}
						}
						Hints.plusAll(tempBonus, point, win);

						for each (var index:String in data.units)
						{
							that.targets[index].started = App.time; 
							that.targets[index].crafted = App.time + App.data.storage[that.targets[index].sid].time;
						}
						
						Treasures.bonus(data.bonus, new Point(that.x, that.y));
						SoundsManager.instance.playSFX('bonus');
					
					}
					win.contentChange();
					win.blockAll(false);
					win.close();
				});
			}
		}
		public function extendAction (win:MhelperWindow):void 
		{
			for (var ins:Object in info.extra)
				break;
			if ( targetsLength < info.stacks && App.user.stock.take (int(ins), info.extra[ins]))
			{
				var that:Mhelper = this;
				var point:Point = new Point (App.self.stage.mouseX, App.self.stage.mouseY);
				Hints.minus(int(ins), int(info.extra[ins]), point, true, win);
				Post.send({
					ctr:this.type,
					act:'extend',
					uID:App.user.id,
					id:this.id,
					wID:App.user.worldID,
					sID:this.sid
				}, function(error:*, data:*, params:*):void {
					
					if (!error && data) 
					{
						that.stacks++;
					}
					win.contentChange();
					win.blockAll(false);
				});
			}
		}
		override public function remove(_callback:Function = null):void 
		{
			//super.remove(_callback);
			var callback:Function = _callback;
			
			if (!removable) return;
			
			if (targetsLength > 0 )
			{
				var text:String = Locale.__e("flash:1455635497240");
				if (sid == 1648) text = Locale.__e('flash:1456760949360');
				//if (sid == 132)
					//return
				new SimpleWindow( {
					title:info.title,
					text:text,
					label:SimpleWindow.ATTENTION,
					dialog:true,
					isImg:true,
					confirm:function():void {
						click();
					}
				}).show();
				return;
			}	
			if (info && info.hasOwnProperty('ask') && info.ask == true)
			{
				new SimpleWindow( {
					title:Locale.__e("flash:1382952379842"),
					text:Locale.__e("flash:1382952379968", [info.title]),
					label:SimpleWindow.ATTENTION,
					dialog:true,
					isImg:true,
					confirm:function():void {
						onApplyRemove(callback);
					}
				}).show();
			}
			else
			{
				onApplyRemove(callback)
			}
		}
		override public function putAction():void 
		{
			if (targets.length > 0)
			{
				new SimpleWindow( {
					title:info.title,
					text:Locale.__e("flash:1455635497240"),
					label:SimpleWindow.ATTENTION,
					dialog:true,
					isImg:true,
					confirm:function():void {
						click();
					}
				}).show();
				return;
			}
			super.putAction();
		}
	}
	
}