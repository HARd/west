package units {
	
	import core.Post;
	import flash.display.Bitmap;
	import wins.Window;
	import wins.WindowMegaField;
	public class Mfield extends Building {
		
		public static const STATUS_EMPTY:String = "Mfield.empty";
		public static const STATUS_GROWING:String = "Mfield.growing";
		public static const STATUS_READY:String = "Mfield.ready";
		
		private var _currentStatus:String;
		private var _pID:int;
		private var _count:int;
		private var _title:String;
		
		private var positions:Object = {
			'0':{x:30, y:60},
			'1':{x:-50, y:25}
		};
		
		public var plants:Vector.<Object> = new Vector.<Object>;
		
		public function Mfield(object:Object) {
			super(object);
			_title = App.data.storage[sid].title;
			
			for (var i:int = 0; i < info.devel.req[level].c; i++) {
				plants.push({plant:null, count:0});
			}
			
			if (object.hasOwnProperty('items')) {
				for (var slot:* in object.items) {
					if (plants.length - 1 < slot) break;
					var pID:int = object.items[slot].pID;
					
					plants[slot].plant = createPlant(pID, object.items[slot].planted, slot);
					plants[slot].count = object.items[slot].count;
				}
			}
			
			App.self.setOnTimer(work);
		}
		
		override public function onLoad(data:*):void {
			super.onLoad(data);
			
			initAnimation();
		}
		
		public function work():void {
			if (!textures) return;
			if (!textures.hasOwnProperty('animation')) {
				App.self.setOffTimer(work);
				return;
			}
			for each (var plant:* in plants) {
				if (plant.plant == null) continue;
				var obj:Object = App.data.storage[plant.plant.sid];
				var growTime:int = obj.levelTime * obj.levels;
				var progressTime:int = App.time - plant.plant.planted;
				var leftTime:int = growTime - progressTime;
				
				if (leftTime <= 0) {
					stopAnimation();
				} else {
					startAnimation();
				}
			}
		}
		
		override public function click():Boolean {
			if (App.user.mode == User.OWNER) {
				new WindowMegaField({title:_title}, this).show();
			}
			
			if (App.user.mode == User.GUEST) {
				guestClick();
				return true;
			}
			
			return true;
		}
		
		override public function isPresent():Boolean
		{
			return false;
			
		}
		
		override public function finishUpgrade():void
		{
			super.finishUpgrade();
			
			for (var i:int = 0; i < info.devel.req[level].c; i++) {
				if (plants.hasOwnProperty(i) && plants[i].plant != null) continue;
				plants.push({plant:null, count:0});
			}
		}
		
		private function createPlant(pID:int, planted:int, slot:int):MfieldPlant {
			var plant:MfieldPlant = new MfieldPlant({
				sid:pID,
				planted:planted,
				slot:slot,
				point:positions[slot],
				mfield:this
			});
			
			addChild(plant);
			addGlass();
			
			return plant;
		}
		
		override public function updateLevel(checkRotate:Boolean = false, mode:int = -1):void 
		{
			super.updateLevel(checkRotate, mode);
			addGlass();
		}
		
		public var glass:Bitmap;
		public function addGlass():void {
			if (!textures) return;
			if (textures.hasOwnProperty('ground')) 
			{
				if (!glass) {
					glass = new Bitmap(textures.ground[0].bmp);
					glass.x = textures.ground[0].dx;
					glass.y = textures.ground[0].dy;
				}
				addChild(glass);
			}
		}
		
		private function removePlant(slot:int = 0):void {
			if (plants[slot].plant && plants[slot].plant.parent == this) {
				removeChild(plants[slot].plant);
				
				plants[slot].plant = null;
			}
		}
		
		private var _plantSuccessCallback:Function;
		public function plant(pID:int, count:int, iID:int = 0, callback:Function = null):void {
			Post.send({
				ctr:"Mfield",
				act:"plant",
				uID:App.user.id,
				wID:App.user.worldID,
				sID:this.sid,
				id:id,
				pID:pID,
				iID:iID,
				count:count
				}, plantCallback);
				
			_pID = pID;
			_count = count;
			
			_plantSuccessCallback = callback;
		}
		
		private function plantCallback(error:int, data:Object, params:Object):void {
			if (error) {
				Errors.show(error, data);
				
				return;
			}
			
			if (plants[data.slot].plant != null) {
				plants[data.slot].plant.sid = _pID;
				plants[data.slot].count = count;
			}else {
				plants[data.slot].plant = createPlant(_pID, data.planted, data.slot);
				plants[data.slot].count = count;
			}
			
			_pID = 0;
			_count = 0;
			
			if (_plantSuccessCallback != null) {
				_plantSuccessCallback();
			}
		}
		
		private var _harvestSuccessCallback:Function;
		public function harvest(iID:int, callback:Function = null):void {
			Post.send({
				ctr:"Mfield",
				act:"harvest",
				uID:App.user.id,
				wID:App.user.worldID,
				sID:this.sid,
				id:id,
				iID:iID
			}, harvestCallback);
			
			_harvestSuccessCallback = callback;
		}
		
		private function harvestCallback(error:int, data:Object, params:Object):void {
			if (error) {
				Errors.show(error, data);
				return;
			}
			for (var out:* in App.data.storage[plants[data.slot].plant.sid].outs) {
				if (int(out) != Stock.EXP && int(out) != Stock.COINS && int(out) != Stock.FANTASY) {
					var materialID:int = int(out);
					break;
				}
			}
			
			if (_harvestSuccessCallback != null) {
				_harvestSuccessCallback(data.slot, data.bonus);
			}
			
			removePlant(data.slot);
		}
		
		private var _boostSuccessCallback:Function;
		public function boost(iID:int = 0, callback:Function = null):void {
			Post.send({
				ctr:"Mfield",
				act:"boost",
				uID:App.user.id,
				wID:App.user.worldID,
				sID:this.sid,
				id:id,
				iID:iID,
				bID:Stock.FERTILIZER
			}, boostCallback);
			
			plants[iID].plant.planted = 0;
			
			_boostSuccessCallback = callback;
		}
		
		private function boostCallback(error:int, data:Object, params:Object):void {
			if (error) {
				Errors.show(error, data);
				return;
			}
			if (plants.hasOwnProperty(data.slot)) {
				plants[data.slot].plant.planted = 0;
				plants[data.slot].plant.level = plants[data.slot].plant.info.levels;
			}
			
			if (_boostSuccessCallback != null) {
				_boostSuccessCallback();
			}
		}
		
		public function get pID():int {
			return _pID;
		}
		
		public function get count():int {
			return _count;
		}
		
		public function get currentStatus():String {
			return _currentStatus;
		}
	}
}