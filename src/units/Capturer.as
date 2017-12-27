package units 
{
	import com.greensock.easing.Circ;
	import com.greensock.TweenLite;
	import core.IsoTile;
	import core.Load;
	import core.Post;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filters.BlurFilter;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.utils.setTimeout;
	import wins.PurchaseWindow;
	
	public class Capturer extends WUnit
	{
		
		public static const BLOCK:String = 'block';
		public static const WORK:String = 'work';
		
		public static const ANIM_STOP:String = 'stop_pause';
		
		public static var bossesList:Array = [];
		
		public static const FROZEN_BOSS:uint = 392,
							FIRE_BOSS:int = 398,
							EARTH_BOSS:int = 478,
							AIR_BOSS:int = 479;
		
		public static var	bosses:Array = [],
							spells:Array = [],
							delay:uint = 50,
							initTime:uint = 0;
		
		private static var bossHaloColor:int;
		private static var first:Boolean = true;
		
		public var shadow:Bitmap;
		public var spawnPoint:Object;
		public var infected:Array = [];
		public var capturerID:int;
		public var require:Object = { };
		public var level:String = '';
		
		private var dX:Number = 0,
					dY:Number = 0,
					clickCounter:int = 0,
					_bossState:String = BLOCK,
					_radius:int = 30;
		
		private const MIN_INFECT_RADIUS:int = 10;
		private const MAX_INFECT_RADIUS:int = 36;
		
		public function Capturer(object:Object) 
		{
			spawnPoint = object.position;
			capturerID = object.cID;
			this.id = object.id || 0;
			Capturer.bosses.push(this);
			
			layer = Map.LAYER_SORT;
			
			radius = 15;
			
			super(object);
			
			touchable	= true;
			clickable	= true;
			transable 	= false;
			moveable 	= false;
			removable 	= false;
			rotateable  = false;
			
			for (var s:String in info.devel.obj) {
				if (App.user.level >= info.devel.req[s].lfrom && App.user.level <= info.devel.req[s].lto) {
					require = info.devel.obj[s];
					level = s;
				}
			}
			info['require'] = require;
			
			framesType = ANIM_STOP;
			Load.loading(Config.getSwf(info.type, info.preview), onLoad);
			
			tip = function():Object { 
				return {
					title:App.data.storage[sid].title,
					text:App.data.storage[sid].description
				};
			};
			
			App.self.addEventListener(AppEvent.ON_UNIT_CHANGE_POSITION, onUnitChangePosition);
			
			/*var s:Shape = new Shape();
			s.graphics.beginFill(0xFF0000, 1);
			s.graphics.drawRect(0, 0, 2, 2);
			s.graphics.endFill();
			addChild(s);*/
			
			remove();
		}
		
		public static function start():void {
			if (App.user.mode != User.OWNER || App.map.id != User.HOME_WORLD) return;
			
			var params:* = App.user.storageRead('boss', null);
			
			if (params) {
				try {
					
					bossesList = [];
					bossesList = params as Array;
					
					bossHaloColor = 0x443333;
					
					for (var i:int = 0; i < bossesList.length; i++) {
						var boss:Capturer = new Capturer( { sid:bossesList[i].sid, position:bossesList[i].position, cID:bossesList[i].cID } );
					}
					
				}catch (e:*) {}
			}
		}
		
		public static function testForCreate(position:Object):void {
			if (App.user.mode == User.OWNER && App.map.id == User.HOME_WORLD) {
				if (Capturer.bosses.length < 3) {
					var list:Array = getBosses();
					
					for (var i:int = 0; i < list.length; i++) {
						if (App.data.storage.hasOwnProperty(list[i])) {
							var info:Object = App.data.storage[list[i]];
							
							var create:Boolean = false;
							for (var lvl:String in info.devel.req) {
								if (App.user.level >= info.devel.req[lvl].lfrom && App.user.level <= info.devel.req[lvl].lto) {
									if (info.devel.req[lvl].chance > Math.random() * 100) {
										create = true;
									}
								}
							}
							
							if (create) {
								var sid:int = list[i];
								
								var bossInfo:Object = {
									sid:		sid,
									position:	getRandomPosition(6, position),
									cID:		getCapturerID()
								};
								var capturer:Capturer = new Capturer(bossInfo);
								
								bossesList.push(bossInfo);
								App.user.storageStore('boss', bossesList, true);
								
								setTimeout(function():void {
									App.map.focusedOn(capturer, true);
								}, 3000);
								
								break;
							}
						}
					}
				}
			}
			
			function getCapturerID():int {
				var value:int = 0;
				
				for (var i:int = 0; i < bossesList.length; i++) {
					if (bossesList[i].cID == value) {
						i = 0;
						value++;
					}
				}
				
				return value;
			}
		}
		
		public static function showBoss(capturer:int):void {
			for (var i:int = 0; i < Capturer.bosses.length; i++) {
				if (Capturer.bosses[i].capturerID == capturer) {
					App.map.focusedOn(Capturer.bosses[i], true);
				}
			}
		}
		
		public static function getBosses():Array {
			return [624];
		}
		
		public function set bossState(value:String):void {
			_bossState = value;
		}
		public function get bossState():String {
			return _bossState;
		}
		
		public function onLoad(data:*):void {
			textures = data;
			this.alpha = 0;
			
			addAnimation();
			startAnimation();
			placing(spawnPoint.x, spawnPoint.y, spawnPoint.z);
			
			App.map.sorted.push(this);
			
			// Заблокировать объекты
			infect();
			// обновить картинку юнита
			update();
		}
		
		private function onUnitChangePosition(e:AppEvent):void {
			if (e.params.hasOwnProperty('unit')) {
				var unit:Unit = e.params.unit;
				if (unit.hasOwnProperty('coords') && inRadius(unit.coords)) {
					infected.push(unit);
					unit.visible = false;
				}
			}
		}
		
		public function get radius():int {
			return _radius;
		}
		public function set radius(value:int):void {
			_radius = value;
		}
		
		private function inRadius(coords:Object):Boolean {
			if (radius > Math.sqrt((coords.x - spawnPoint.x) * (coords.x - spawnPoint.x) + (coords.z - spawnPoint.z) * (coords.z - spawnPoint.z)))
				return true;
			
			return false;
		}
		public function infect():void {
			if (infected.length > 0)
				infected = [];
			
			var index:int = App.map.mSort.numChildren;
			var unit:*;
			var _x:int = 0;
			var _z:int = 0;
			
			while (index > 0) {
				index--;
				unit = App.map.mSort.getChildAt(index);
				
				if (!(unit is Resource) || !unit.hasOwnProperty('coords')) continue;
				
				if (radius > Math.sqrt((unit.coords.x - spawnPoint.x) * (unit.coords.x - spawnPoint.x) + (unit.coords.z - spawnPoint.z) * (unit.coords.z - spawnPoint.z))) {
					infected.push(unit);
					unit.captured = true;
					unit.capturer = capturerID;
				}
			}
			
			show();
		}
		public function show():void {
			//drawFog();
			var that:* = this;
			TweenLite.to(this, 1, { alpha:1, onComplete:onShow, onUpdate:function():void {} } );
		}
		private function onShow():void {
			bossState = WORK;
		}
		public function hide():void {
			bossState = BLOCK;
			
			var that:* = this;
			TweenLite.to(this, 0.5, {alpha:0, onComplete:onHide, onUpdate:function():void {}} );
		}
		private function onHide():void {
			for (var i:int = 0; i < infected.length; i++) {
				infected[i].captured = false;
				infected[i].capturer = -1;
			}
			infected = null;
			uninstall();
		}
		
		private var fog:Bitmap;
		private function drawFog():void {
			var fogCont:Sprite = new Sprite();
			var shape:Shape = new Shape();
			shape.graphics.beginFill(0xCCCCCC, 0.4);
			shape.graphics.drawEllipse( -IsoTile.width * radius * 0.6, -IsoTile.height * radius * 0.6, IsoTile.width * radius * 1.2, IsoTile.height * radius * 1.2);
			shape.graphics.endFill();
			shape.x = 60 + shape.width / 2;
			shape.y = 30 + shape.height / 2;
			fogCont.addChild(shape);
			
			for (var i:int = 0; i < radius * 2; i++) {
				var s:Shape = new Shape();
				s.graphics.beginFill(0xCCCCCC, 0.4);
				s.graphics.drawEllipse(0,0,80,40);
				s.graphics.endFill();
				s.x = Math.random() * (shape.width - s.width);
				s.y = Math.random() * (shape.height - s.height);
				fogCont.addChild(s);
			}
			fogCont.filters = [new BlurFilter(60, 30, 1)];
			
			fog = new Bitmap(new BitmapData(shape.width + 120, shape.height + 60, true, 0));
			fog.bitmapData.draw(fogCont);
			fog.x = -shape.x + this.x;
			fog.y = -shape.y + this.y;
			App.map.mField.addChild(fog);
		}
		
		public static function getRandomPosition(radius:int = 0, position:Object = null):Object {
			var find:Boolean = false;
			while (!find) {
				var _x:int = int(Math.random() * App.map._aStarNodes.length);
				var _z:int = int(Math.random() * App.map._aStarNodes[_x].length);
				
				if (radius > 0 && position != null && radius < Math.sqrt((_x - position.x) * (_x - position.x) + (_z - position.z) * (_z - position.z))) {
					continue;
				}
				
				// Если не вода и там ничего не стоит
				if (App.map._aStarNodes[_x][_z].w == 0 && App.map._aStarNodes[_x][_z].object == null && App.map._aStarNodes[_x][_z].open == 1 && App.map._aStarNodes[_x][_z].isWall == false) {
					find = true;
				}
			}
			
			return { x:_x, y:0, z:_z};
		}
		
		/*override public function set state(state:uint):void {
			super.state = state;
			
			switch(state) {
				case TOCHED: bitmap.filters = [new GlowFilter(bossHaloColor,1,6,6,7)]; break;
			}
			
			_state = state;
		}*/
		
		override public function onLoop():void {
			if (_framesType == ANIM_STOP && Math.random() < 0.1) {
				framesType = getRest();
			}else {
				framesType = ANIM_STOP;
			}
		}
		public function getRest(except:Array = null):String {
			var rests:Array = [];
			if (textures) {
				for (var s:String in textures.animation.animations) {
					if (s.indexOf('rest') >= 0 && (!except || except.indexOf(s) < 0)) {
						rests.push(s);
					}
				}
			}
			
			if (rests.length > 0) {
				return rests[Math.floor(Math.random() * rests.length)];
			}else {
				return 'stop_pause';
			}
		}
		
		public override function click():Boolean {
			if (!clickable) return false;
			
			if (bossState == BLOCK) return true;
			
			if (!canKill) {
				clickCounter = 0;
				
				new PurchaseWindow( {
					find:[weapoon],
					width:560,
					itemsOnPage:[], //Boss.spells.length,
					content:[], //Boss.spells,
					title:Locale.__e("flash:1413981522829"),
					description:Locale.__e("flash:1413981562797"),
					callback:function(sID:int):void {
						var object:* = App.data.storage[sID];
						App.user.stock.add(sID, object);
					}
				}).show();
			}else {
				kick();
				
				if (App.user.stock.takeAll(require)) {
					Post.send( {
						ctr:'invader',
						act:'kill',
						uID:App.user.id,
						sID:sid,
						mID:weapoon,
						level:level
					}, onKillEvent);
				}
			}
			return true;
		}
		
		private function get canKill():Boolean {
			return true;
		}
		
		public function get weapoon():int {
			for (var s:String in require)
				return int(s);
			
			return 0;
		}
		
		public function get need():int {
			for (var s:String in require)
				return require[s];
			
			return 0;
		}
		
		private var kicked:Boolean = false;
		public function kick():void {
			TweenLite.to(multiBitmap, 0.1, {ease:Circ.easeInOut, scaleX:0.95, scaleY:0.95, onComplete:function():void {
				TweenLite.to(multiBitmap, 0.1, {ease:Circ.easeInOut, scaleX:1, scaleY:1, onComplete:function():void {
					
				}});
			}});
			
			if (_framesType == ANIM_STOP) {
				framesType = 'rest1';
			}
		}
		
		private function onKillEvent(error:int, data:Object, params:Object = null):void
		{
			if (error) {
				Errors.show(error, data);
				return;
			}
			
			if (data.hasOwnProperty("bonus")) {
				Treasures.bonus(data.bonus, new Point(this.x, this.y + 30));
				SoundsManager.instance.playSFX('bonus');
				
				App.user.storageStore('boss', null, true);
			}
			
			hide();
		}
		
		public override function uninstall():void
		{
			var index:int = bosses.indexOf(this);
			bosses.splice(index, 1);
			
			if (fog && fog.parent) {
				fog.parent.removeChild(fog);
				fog = null;
			}
			
			App.self.removeEventListener(AppEvent.ON_UNIT_CHANGE_POSITION, onUnitChangePosition);
			App.map.removeUnit(this);
		}
		
		public static function dispose():void
		{
			for each(var boss:Capturer in Capturer.bosses) {
				boss.uninstall();
			}
			Capturer.bosses = [];
		}
	}
}