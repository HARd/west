package units 
{
	import adobe.utils.CustomActions;
	import astar.AStar;
	import astar.AStarNodeVO;
	import core.IsoConvert;
	import core.Numbers;
	import core.Post;
	import flash.display.Shape;
	import flash.geom.Point;
	import ui.Hints;
	import wins.InfoWindow;
	import wins.PurchaseWindow;
	import wins.SimpleWindow;
	public class Freezer extends Resource 
	{
		private var radiusFreez:int = 0;
		private var radiusRelief:int = 0;
		
		public var freez:Boolean = false;
		
		public function Freezer(object:Object) 
		{
			super(object);
			
			radiusFreez = info.radius1;
			radiusRelief = info.radius2;
			
			freez = object.freez;
			
			//drawPreview();
			
			if (Config.admin) {
				//freez = false;
			}
			
			
			if (freez) {
				markFreezedZone();
				drawPreview();
			}
		}
		
		override public function onLoad(data:*):void 
		{
			colorize(data);
			
			textures = data;
			var levelData:Object = textures.sprites[0];
			draw(levelData.bmp, levelData.dx, levelData.dy);
			if (!open && User.inExpedition && formed) {
				if (bitmap.height > 100) 
					addMask();
					//uninstall();
			}
			if (!open && User.inExpedition)
				visible = false;
			if (App.self.constructMode) visible = true;
		}
		
		override public function click():Boolean {
			//trace('id ', this.id);
			//trace('sid ', this.sid);
			//return true;
			if (App.user.mode == User.GUEST) return false;
			
			if (freez) {
				trace('id ', this.id);
				Hints.text(Locale.__e('flash:1429185188688'), Hints.TEXT_RED, new Point(App.self.mouseX, App.self.mouseY));
				var ids:Array = [];
				for (var sid:* in App.data.storage) {
					if (App.data.storage[sid].type == 'Freezer')
						ids.push(sid);
				}
				
				if (App.user.worldID == 2099) {
					if (App.user.settings.hasOwnProperty('noticeFreezer')) {
						var obj:Object = App.user.settings.noticeFreezer;
						var count:int = Numbers.countProps(obj);
						if (count >= 3) {
							App.user.onStopEvent();
							WUnit.findUnits(ids, 'Freezer');
							return true;
						}
						
						showNoticeWindow();
					}else {
						showNoticeWindow();
					}
				} else {
					App.user.onStopEvent();
					WUnit.findUnits(ids, 'Freezer');
				}
				
				return false;
			}
			super.click();
			
			return true;
		}
		
		private function showNoticeWindow():void {
			if (App.user.settings.hasOwnProperty('noticeFreezer')) {
				var saveObj:Object = App.user.settings.noticeFreezer;
				var saveCount:int = Numbers.countProps(saveObj);
				saveObj[saveCount + 1] = 1;
				App.user.storageStore('noticeFreezer', saveObj, true);
			}else {
				var sv:Object = { };
				sv['1'] = 1;
				App.user.storageStore('noticeFreezer', sv, true);
			}
			new InfoWindow( {
				popup:true,
				qID:String(App.user.worldID),
				caption:Locale.__e('flash:1382952380254'),
				callback: function():void {
					var ids:Array = [];
					for (var sid:* in App.data.storage) {
						if (App.data.storage[sid].type == 'Freezer')
							ids.push(sid);
					}
					App.user.onStopEvent();
					WUnit.findUnits(ids, 'Freezer');
				}
			}).show();
		}
		
		public function markFreezedZone():void {
			//if (!formed) return;
			var node:AStarNodeVO;
			
			for (var i:int = -radiusFreez; i < cells + radiusFreez; i++) {
				for (var j:int = -radiusFreez; j < rows + radiusFreez; j++) {
					if (coords.x + i < 0 || coords.z + j < 0) continue;
					if (coords.x + i >= App.map._aStarNodes.length || coords.z + j >= App.map._aStarNodes[coords.x + i].length) continue;
					node = App.map._aStarNodes[coords.x + i][coords.z + j];
					node.freezers.push(this);
					node.closed = true;
					node.b = 1;
				}
			}
		}
		
		public function freeZone(openOthers:Boolean = false):void {
			var node:AStarNodeVO;	
			var i:int = 0;
			var j:int = 0;
			for (i = -radiusFreez; i < cells + radiusFreez; i++) {
				for (j = -radiusFreez; j < rows + radiusFreez; j++) {
					node = App.map._aStarNodes[coords.x + i][coords.z + j];
					unfreeze(node);
				}
			}
			
			var shape:Shape = App.map.getChildByName('preview') as Shape;
			if (shape) App.map.removeChild(shape);
			
			freez = false;
			
			if (!openOthers) return;
			
			i = j = 0;
			var ids:Array = [];
			for (i = -radiusFreez; i < cells + radiusRelief; i++) {
				for (j = -radiusFreez; j < rows + radiusRelief; j++) {	
					if (App.map._aStarNodes.length <= coords.x + i || coords.x + i < 0) continue;
					if (App.map._aStarNodes[coords.x].length <= coords.z + j || coords.z + j < 0) continue;
					var nd:AStarNodeVO = App.map._aStarNodes[coords.x + i][coords.z + j];
					for each (var fr:Freezer in nd.freezers) {
						fr.freeZone();
						if (ids.indexOf(fr.id) == -1) ids.push(fr.id);
					}
				}
			}
			
			var forRemove:int = 0;
			forRemove = lastReserved;
			if (forRemove == 0)
				return;
			
			var postObject:Object = {
				ctr:this.type,
				act:'kick',
				uID:App.user.id,
				wID:App.user.worldID,
				sID:this.sid,
				id:id,
				count:forRemove,
				ids:JSON.stringify(ids)
			}
			
			Post.send(postObject, onKickEvent, {
				reserved:	forRemove
			});
			if (storageList)
				storageList = [];
			takeResource(forRemove);
		}
		
		override public function takeResource(count:uint = 1):void
		{
			if (capacity - count >= 0)	
				capacity -= count;
			if (capacity == 0) {
				this.hidePointing();
				uninstall();
			}
		}
		
		public function getOpened():Array {
			var ids:Array = [];
			for (var i:int = -radiusFreez; i < cells + radiusRelief; i++) {
				for (var j:int = -radiusFreez; j < rows + radiusRelief; j++) {					
					var nd:AStarNodeVO = App.map._aStarNodes[coords.x + i][coords.z + j];
					for each (var fr:Freezer in nd.freezers) {
						fr.freeZone();
						if (ids.indexOf(fr.id) == -1) ids.push(fr.id);
					}
				}
			}
			return ids;
		}
		
		public function unfreeze(cell:AStarNodeVO):void {
			if (cell.freezers.length == 0) return;
			for (var i:int = 0; i < cell.freezers.length; i++) {
				if (cell.freezers[i].sid == this.sid && cell.freezers[i].id == this.id) {
					cell.freezers.splice(i, 1);
					cell.closed = false;
					cell.b = 0;
				}
			}
		}
		
		public function checkFreez():void {
			var node:AStarNodeVO;	
			var i:int = 0;
			var j:int = 0;
			for (i = -radiusFreez; i < cells + radiusFreez; i++) {
				for (j = -radiusFreez; j < rows + radiusFreez; j++) {
					node = App.map._aStarNodes[coords.x + i][coords.z + j];
					if (node.z != 1196) {
						
					}
				}
			}
			
			freez = false;
		}
		
		override public function placing(x:uint, y:uint, z:uint):void
		{
			super.placing(x, y, z);
			if (freez) markFreezedZone();
			
			//if (freez) drawPreview();
		}
		
		override public function onTakeResourceEvent(guest:Guest = null):void
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
					
					if (capacity - lastReserved == 0) {
						freeZone(true);
						return;
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
		
		override protected function onKickEvent(error:int, data:Object, params:Object):void
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
		}
		
		override public function set touch(touch:Boolean):void {
			super.touch = touch;
			
			
		}
		
		override protected function onBuyAction(error:int, data:Object, params:Object):void {
			super.onBuyAction(error, data, params);
			
			markFreezedZone();
			//drawPreview();
		}
		
		override public function uninstall():void {
			super.uninstall();
			
			//freeZone(true);
			
			var shape:Shape = App.map.getChildByName('preview') as Shape;
			if (shape) App.map.removeChild(shape);
		}
		
		override public function drawPreview():void {
			var scale:int = 1;
			if (_rotate)
				scale = -1;
			
			var radius:Number = radiusRelief; 
			var shape:Shape = new Shape();
			var point1:Object = IsoConvert.isoToScreen(coords.x - radius, coords.z - radius, true);
			var point2:Object = IsoConvert.isoToScreen(coords.x - radius, coords.z + rows + radius, true);
			var point3:Object = IsoConvert.isoToScreen(coords.x + cells + radius, coords.z + rows + radius, true);
			var point4:Object = IsoConvert.isoToScreen(coords.x + cells + radius, coords.z - radius, true);
			shape.name = 'preview';
			shape.graphics.beginFill(0x00FF00, 0.1);
			shape.graphics.lineStyle(1, 0x00FF00, 0.5);
			shape.graphics.moveTo(point1.x, point1.y);
			shape.graphics.lineTo(point2.x, point2.y);
			shape.graphics.lineTo(point3.x, point3.y);
			shape.graphics.lineTo(point4.x, point4.y);
			shape.graphics.lineTo(point1.x, point1.y);
			shape.graphics.endFill();
			App.map.addChild(shape);
			
			
			radius = radiusFreez; 
			var shape2:Shape = new Shape();
			var point12:Object = IsoConvert.isoToScreen(coords.x - radius, coords.z - radius, true);
			var point22:Object = IsoConvert.isoToScreen(coords.x - radius, coords.z + rows + radius, true);
			var point32:Object = IsoConvert.isoToScreen(coords.x + cells + radius, coords.z + rows + radius, true);
			var point42:Object = IsoConvert.isoToScreen(coords.x + cells + radius, coords.z - radius, true);
			shape2.name = 'preview';
			shape2.graphics.beginFill(0xFF0000, 0.1);
			shape2.graphics.lineStyle(1, 0xFF0000, 0.5);
			shape2.graphics.moveTo(point12.x, point12.y);
			shape2.graphics.lineTo(point22.x, point22.y);
			shape2.graphics.lineTo(point32.x, point32.y);
			shape2.graphics.lineTo(point42.x, point42.y);
			shape2.graphics.lineTo(point12.x, point12.y);
			shape2.graphics.endFill();
			App.map.addChild(shape2);
		}
		
	}

}