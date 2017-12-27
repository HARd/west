package units
{
	import astar.AStarNodeVO;
	import core.IsoTile;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.events.Event;
	import wins.InfoWindow;
	import wins.SimpleWindow;
	
	
	public class WUnit extends Unit 
	{
		public static const FACE:int = 0;
		public static const BACK:int = 1;
		public static const LEFT:int = 0;
		public static const RIGHT:int = 1;
		
		public var _walk:Boolean = false;
		public var start:Object = { x:0, y:0 };
		public var finish:Object = { x:0, y:0 };
		public var t:Number = 0;
		public var velocities:Array = [0.08]
		public var velocity:Number = velocities[0];
		
		public var frame:uint = 0;
		private var frameLength:uint = 0;
		private var chain:Object;
		protected var ax:int = 0;
		protected var ay:int = 0;
		
		public var _framesType:String = 'walk';
		public var framesDirection:int = FACE;
		public var framesFlip:int = LEFT;
		public var _position:Object = null;
		public var sign:int = 1;
		
		public var path:Vector.<AStarNodeVO>;
		public var pathCounter:int = 0;
		
		public var cell:int = 0;
		public var row:int = 0;
		
		public var tm:TargetManager;
		public var onPathComplete:Function = null;
		
		public var hasMultipleAnimation:Boolean = false;
		public var multiBitmap:Bitmap;
		public var multipleAnime:Object = null;
		
		public var flyeble:Boolean = false;
		
		public function WUnit(object:Object) 
		{
			cell 	= object.x;
			row 	= object.z;
			super(object);
			addEventListener(Event.REMOVED_FROM_STAGE, onRemoveFromStage);
			
		}
		
		public function onRemoveFromStage(e:Event):void {
			if (animated) {
				stopAnimation();
				stopWalking();
			}
			removeEventListener(Event.REMOVED_FROM_STAGE, onRemoveFromStage);
		}
		
		/**
		 * Вызывается по окончанию flash:1382952379984грузки анимации
		 */
		public function addAnimation():void
		{
			multiBitmap = new Bitmap();
			addChild(multiBitmap);
			
			// Red dot, красная точка
			//var shape:Shape = new Shape();
			//shape.graphics.beginFill(0xFF0000, 1);
			//shape.graphics.drawRect( -1, -1, 2, 2);
			//shape.graphics.endFill(); 
			//addChild(shape);
			
			ax = textures.animation.ax;
			ay = textures.animation.ay;
			
			if(!animated){
				startAnimation();
			}
		}
		
		/**
		 * вкл/выкл анимации
		 */
		public function startAnimation():void {
			animated = true;
			App.self.setOnEnterFrame(update);
		}
		public function stopAnimation():void {
			animated = false;
			App.self.setOffEnterFrame(update);
		}
			
		/**
		 * Вычисляем маршрут
		 * @param	cell
		 * @param	row
		 */
		public function initMove(cell:int, row:int, _onPathComplete:Function = null):void {
			
			/*if (_framesType == Hero.STOP) {
				onLoopParams = { cell:cell, row:row, _onPathComplete:_onPathComplete };
				return;
			}*/
			
			//Не пересчитываем маршрут, если идем в ту же клетку
			onPathComplete = _onPathComplete;
			
			if (_walk) {
				if (!path) {
					_walk = false;
					_framesType = 'stop_pause';
					return;
				}
				if (path[path.length - 1].position.x == cell && path[path.length - 1].position.y == row) {
					return;
				}
			}
			
			if (!App.map._aStarNodes || !(cell in App.map._aStarNodes)) {
				return;
			}
			if (!(row in App.map._aStarNodes[cell])) {
				return;
			}
			
			if (App.map._aStarParts[cell][row].isWall ) {
				/*var findNewPlace:Boolean = false;
				var count:int = 2;
				while(!findNewPlace){
					for (var _cell:int = cell - count; _cell < count; _cell++) {
						for (var _row:int = row - count; _row < count; _row++) {
							if (App.map._aStarParts[_cell][_row].isWall == false) {
									cell = _cell;
									row = _row;
									findNewPlace = true;
								break;
							}
						}
					}
					count ++;
				}*/
				
				//if(!findNewPlace){
					walking();
					return;
				//}
			}
			
			try {
				path = findPath(App.map._aStarNodes[this.cell][this.row], App.map._aStarNodes[cell][row], App.map._astar);
			}catch(e:Error) {
				return;
			}
			
			if (info.type == 'Animal' && path && path.length > 30)
				trace(path);
			
			if (path == null) {
				trace('Не могу туда пройти по-нормальному!');
				if ((App.user.worldID == 1198) && !(this is Walkgolden)) {
					if (!App.isSocial('HV','NK','SP')) {
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
								findUnits(ids, 'Freezer');
							}
						}).show();
					} else {
						new SimpleWindow( {
							title:Locale.__e('flash:1382952379893'),
							text: Locale.__e('flash:1449067282943'),
							popup:true,
							needCancelAfterClose:true,
							confirm: function():void {
								App.user.onStopEvent();
							},
							cancel: function():void {
								App.user.onStopEvent();
							}
						}).show();
					}
					return;
				}
				
				path = findPath(App.map._aStarParts[this.cell][this.row], App.map._aStarParts[cell][row], App.map._astarReserve);
				
				if(path == null){
					this._walk = false;
					pathCounter = 1;
					t = 0;
					App.self.setOffEnterFrame(walk);
					trace('Не могу туда пройти!');
					_framesType = 'stop_pause';
					Bridge.showMessage();
					if(_onPathComplete!= null)
						_onPathComplete();
					return;
				}
			}
			
			/*
			for each(var node:* in path) {
				var _tile:Bitmap = new Bitmap(IsoTile._tile);
				_tile.x = node.tile.x - IsoTile.width*.5;
				_tile.y = node.tile.y;
				App.map.mLand.addChild(_tile);
			}
			*/
			pathCounter = 1;
			t = 0;
			walking();
			//_framesType = Hero.WALK;
		}
		
		public static var currentTarget:*;
		public static var showed:Array = [];
		public static function findUnits(sIDs:Array, type:String = ''):void {
			var approved:Array = [];
			var personage:Hero;
			
			currentTarget = null;
			
			var index:int = 0;
			while (index < App.map.mSort.numChildren) {
				currentTarget = App.map.mSort.getChildAt(index);
				
				if (sIDs.indexOf(currentTarget.sid) != -1){
					if (type == 'Freezer') {
						if (!currentTarget.freez) {
							approved.push(currentTarget);
						}
					} else {
						approved.push(currentTarget);
					}
				}
				
				index++;
			}
			
			for (var i:int = 0; i < App.user.personages.length; i++) {
				if (!personage) personage = App.user.personages[i];
				if (App.user.personages[i].hasOwnProperty('main') && App.user.personages[i].main) personage = App.user.personages[i];
			}
			
			var distance:Number = 0;
			var targetID:int = 0;
			for (i = 0; i < approved.length; i++) {
				if (showed.indexOf(approved[i].id) != -1) continue;
				var predistance:Number = Math.sqrt((personage.x - approved[i].x) * (personage.x - approved[i].x) + (personage.y - approved[i].y) * (personage.y - approved[i].y));
				if (distance == 0 || predistance < distance) {
					distance = predistance;
					targetID = i;
				}
			}
			
			currentTarget = null;
			if (distance >= 0 && approved.length > 0) {
				
				currentTarget = approved[targetID];
				
				App.map.focusedOn(currentTarget, true, function():void {
					showed.push(currentTarget.id);
					if (showed.length == sIDs.length || distance > 200)
						showed = [];
					if (currentTarget is Building) {
						currentTarget.click();
					}
				});
			}
		}
		
		public function initMoveOnPath(_path:Vector.<AStarNodeVO>, _onPathComplete:Function = null, _type:String = 'walk'):void {
			path = _path;
			framesType = _type;
			onPathComplete = _onPathComplete;
			pathCounter = 1;
			t = 0;
			walking();
		}
		
		public function findPath(start:*, finish:*, _astar:*):Vector.<AStarNodeVO> {
			var path:Vector.<AStarNodeVO> = _astar.search(start, finish);
			return path;
		}
		
		/**
		 * Задаем путь flash:1382952379993 клетки в клетку
		 */
		public function walking():void
		{
			if (path && pathCounter < path.length) {
				
				start.x = this.x;
				start.y = this.y;
				
				var node:AStarNodeVO = path[pathCounter];
				
				finish = {x:node.tile.x, y:node.tile.y};
				if(this._walk == false){
					this._walk = true;
					App.self.setOnEnterFrame(walk);
				}
			}else {
				// Заканчиваем путь
				path = null;
				pathCounter = 1;
				this._walk = false;
				t = 0;
				App.self.setOffEnterFrame(walk);
				if(onPathComplete != null) onPathComplete();
			}
		}
		
		/**
		 * Обновляем координаты юнита
		 * @return возвращаем юнит если его нужно сортировать
		 */
		public function walk(e:Event = null):* {
			
			var k:Number = 0;
			
			if (start.x == finish.x) {
				k = IsoTile.spacing / Math.abs(start.y - finish.y);
			}else if (start.y == finish.y) {
				k = IsoTile.spacing / Math.abs(start.x - finish.x);
			}else {
				var d:Number = Math.sqrt(Math.pow((start.x - finish.x), 2) + Math.pow((start.y - finish.y), 2));
				k = IsoTile.spacing / d;
			}
			
			t += velocity * k * (32 / (App.self.fps || 32));
			
			if (t >= 1)
			{
				if (path == null) {
					_framesType = 'stop_pause';
					return false;
				}
				var node:AStarNodeVO = path[pathCounter];
				this.cell = node.position.x;
				this.row = node.position.y;
				
				//trace('cell', cell);
				//trace('row', row);
				
				coords = { x:node.position.x, y:0, z:node.position.y };
				
				calcDepth();
				
				App.map.sorted.push(this);
					
				t = 0;
				x = finish.x;
				y = finish.y;
					
				pathCounter++;
				walking();
			}
			else
			{
				x = int((start.x + (finish.x - start.x) * t));
				y = int((start.y + (finish.y - start.y) * t));
			}
			return false;
		}
		
		public function set framesType(value:String):void {
			if (textures && !textures.animation.animations.hasOwnProperty(value)) return;
			if (sid == 1770 && value == 'walk2') {
				_framesType = value;
				return;
			}
			if (_framesType != value) {
				frame = 0;
				_framesType = value;
			}
			position = null;
		}
		
		public function set position(value:*):void {
			_position = value;
			if (_position)
			{
				if(_position.hasOwnProperty('flip'))
					framesFlip = _position.flip;
				if(_position.hasOwnProperty('direction'))
					framesDirection = _position.direction;
				
				if (framesFlip != RIGHT){
						bitmap.scaleX = 1;
						sign = 1;
					}
					
				if (framesFlip != LEFT){
						bitmap.scaleX = -1;
						sign = -1;
					}
				if (textures) {
					//_framesType = (_framesType == 'work3')?'harvest':_framesType;
					var cadr:uint = textures.animation.animations[_framesType].chain[frame];	
					if (textures.animation.animations[_framesType].frames[framesDirection] == undefined) {
						framesDirection = 0;
					}
					var frameObject:Object 	= textures.animation.animations[_framesType].frames[framesDirection][cadr];
					bitmap.x = frameObject.ox * sign;	
				}
			}
		}
		
		/**
		 * Обновляет flash:1382952379993ображение юнита
		 */
		//private var oldCadr:int = -1;
		//private var oldDirection:int = -1;
		public function update(e:Event = null):void {
			
			if (_walk) {
				//_framesType = 'walk';
				
				if (start.y < finish.y){ 
					if (framesDirection != FACE) frame = 0;
					framesDirection = FACE; 
				}else {
					if (framesDirection != BACK) frame = 0;
					framesDirection = BACK;
				}
				
				if (start.x < finish.x) { 
					if (sid == 1770) {
						framesType = 'walk2';
						if (framesDirection == FACE){
							if(bitmap.scaleX>0){
								bitmap.scaleX = -1;
								sign = -1;
							}
						}
						framesFlip = RIGHT;
					}else {
						if (framesFlip != RIGHT){
							frame = 0;
							if(bitmap.scaleX>0){
								bitmap.scaleX = -1;
								sign = -1;
							}
						}
						framesFlip = RIGHT;
					}
				}else {
					/*if (sid == 1770) {
						framesType = 'walk2';
						framesDirection = LEFT;
					}else */{
						if (framesFlip != LEFT){
							frame = 0;
							if(bitmap.scaleX<0){
								bitmap.scaleX = 1;
								sign = 1;
							}
						}
						framesFlip = LEFT;
					}
				}	
				
			}else {
				if (!_position)	framesDirection = FACE;
			}
			//if (_framesType == 'walk2') framesDirection = RIGHT;
			var anim:Object = textures.animation.animations;
		
			var cadr:uint 			= anim[_framesType].chain[frame];
			
			if (anim[_framesType].frames[framesDirection] == undefined) {
				framesDirection = 0;
			}
			var lt:int = anim[_framesType].frames[framesDirection].length;
			cadr = cadr >= lt?lt - 1:cadr;
			if (cadr == lt - 1)
				cadr == 0;
			var frameObject:Object 	= anim[_framesType].frames[framesDirection][cadr];
			if (hasMultipleAnimation) multipleAnimation(cadr);
			
			if (frameObject.bmd) bitmap.bitmapData = frameObject.bmd;
			bitmap.smoothing = true;
			bitmap.x = (frameObject.ox + ax) * sign;
			bitmap.y = (frameObject.oy + ay);
			
			frame++;
			if (frame >= anim[_framesType].chain.length) {
				this.dispatchEvent(new Event(Event.COMPLETE));
				frame = 0;
				onLoop();
			}
			
			if (icon) iconSetPosition();
		}
		
		/*public function setFlip(flip:int):void
		{
			if (flip == RIGHT && framesFlip != RIGHT){
				frame = 0;
				if(bitmap.scaleX>0){
					bitmap.scaleX = -1;
					sign = -1;
				}
				framesFlip = RIGHT;
				
			}else if (flip == LEFT && framesFlip != LEFT){
				frame = 0;
				if(bitmap.scaleX<0){
					bitmap.scaleX = 1;
					sign = 1;
				}
				framesFlip = LEFT;
			}	
		}*/
		
		//private var oldMultipleCadr:int = -1;
		//private var oldMultipleDirection:int = -1;
		protected function multipleAnimation(cadr:int):void
		{
			if (multipleAnime == null)
			{
				multiBitmap.bitmapData = null;
				return;
			}
			
			var frameObject:Object 	= multipleAnime[_framesType].frames[framesDirection][cadr];
			//var frameObject:Object 	= multipleAnime.frames[framesDirection][cadr];
			if (frameObject == null) return;
			multiBitmap.scaleX = bitmap.scaleX;
			multiBitmap.bitmapData = frameObject.bmd;
			multiBitmap.x = frameObject.ox * sign;
			multiBitmap.y = frameObject.oy - 30 + ay;
		}
		
		public function stopWalking():void
		{
			_walk = false;
			framesDirection = 0;
			frame = 0;
			path = null;
			App.self.setOffEnterFrame(walk);
		}
		
		public var onLoopParams:Object;
		public function onLoop():void 
		{
			if (onLoopParams != null) {
				initMove(onLoopParams.cell, onLoopParams.row, onLoopParams.onPathComplete);
				onLoopParams = null;
			}
		}
	}
}