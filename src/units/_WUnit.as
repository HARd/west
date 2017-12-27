package units
{
	import astar.AStarNodeVO;
	import core.IsoTile;
	import flash.display.Bitmap;
	import flash.events.Event;
	
	
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
		public var velocities:Array = [0.11]
		public var velocity:Number = velocities[0];
		
		private var frame:uint = 0;
		private var frameLength:uint = 0;
		private var chain:Object;
		private var ax:int = 0;
		private var ay:int = 0;
		
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
		private var onPathComplete:Function = null
		
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
		 * Вызывается по окончанию загрузки анимации
		 */
		public function addAnimation():void
		{
			
			//if (hasMultipleAnimation) 
			//{
				multiBitmap = new Bitmap();
				addChild(multiBitmap);
			//}
			
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
			
			//Не пересчитываем маршрут, если идем в ту же клетку
			onPathComplete = _onPathComplete;
			
			if (_walk) {
				if (path[path.length - 1].position.x == cell && path[path.length - 1].position.y == row) {
					return;
				}
			}
			
			if (!(cell in App.map._aStarNodes)) {
				return;
			}
			if (!(row in App.map._aStarNodes[cell])) {
				return;
			}
			
			if (sid == Personage.BEAVER) {
				if (App.map._aStarWaterNodes[cell][row].isWall ){
					walking();
					return;
				}
			}
			else
			{
				if (App.map._aStarParts[cell][row].isWall ){
					walking();
					return;
				}
			}
			
			// Ищем путь
			path = findPath(this.cell, this.row, cell, row);
			
			if (path == null) {
				this._walk = false;
				pathCounter = 1;
				t = 0;
				App.self.setOffEnterFrame(walk);
				trace('Не могу туда пройти!');
				Bridge.showMessage();
				framesType = 'stop_pause';
				return;
			}
			
			pathCounter = 1;
			t = 0;
			walking();
		}
		
		public function findPath(start_cell:int, start_row:int, finish_cell:int, finish_row:int):Vector.<AStarNodeVO>
		{
			var path:Vector.<AStarNodeVO>;
			path = App.map._astar.search(App.map._aStarNodes[start_cell][start_row], App.map._aStarNodes[finish_cell][finish_row]);
			
			if (path == null) {
				trace('Не могу туда пройти по-нормальному!');
				//App.map._astarReserve.reload();
				path = App.map._astarReserve.search(App.map._aStarParts[this.cell][this.row], App.map._aStarParts[cell][row]);
			}
			
			return path;
			/*for each(var node:* in path) {
				var _tile:Bitmap = new Bitmap(IsoTile._tile);
				_tile.x = node.tile.x - IsoTile.width*.5;
				_tile.y = node.tile.y;
				App.map.mLand.addChild(_tile);
			}*/
		}
		
		/**
		 * Задаем путь из клетки в клетку
		 */
		private function walking():void
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
				var node:AStarNodeVO = path[pathCounter];
				this.cell = node.position.x;
				this.row = node.position.y;
				
				coords = { x:node.position.x, y:0, z:node.position.y };
				
				calcDepth();
				
				//try{
					//App.map.depths[index] = depth;
					App.map.sorted.push(this);
				//}catch (e:Error) {
				//	
				//}
				
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
			_framesType = value;
			frame = 0;
			position = null;
		}
		
		public function set position(value:*):void {
			_position = value;
			if (_position)
			{
				framesFlip = _position.flip;
				framesDirection = _position.direction;
				
				if (framesFlip != RIGHT){
						frame = 0;
						bitmap.scaleX = 1;
						sign = 1;
					}
					
				if (framesFlip != LEFT){
						frame = 0;
						bitmap.scaleX = -1;
						sign = -1;
					}
				if(textures){	
					var cadr:uint 			= textures.animation.animations[_framesType].chain[frame];	
					if (textures.animation.animations[_framesType].frames[framesDirection] == undefined) {
						framesDirection = 0;
					}
					var frameObject:Object 	= textures.animation.animations[_framesType].frames[framesDirection][cadr];
					bitmap.x = frameObject.ox * sign;	
				}
			}
		}
		
		/**
		 * Обновляет изображение юнита
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
				
				if (start.x < finish.x){ 
					if (framesFlip != RIGHT){
						frame = 0;
						if(bitmap.scaleX>0){
							bitmap.scaleX = -1;
							sign = -1;
						}
					}
					framesFlip = RIGHT; 
				}else {
					if (framesFlip != LEFT){
						frame = 0;
						if(bitmap.scaleX<0){
							bitmap.scaleX = 1;
							sign = 1;
						}
					}
					framesFlip = LEFT;
				}	
				
			}else {
				if (!_position)	framesDirection = FACE;
			}
			
			var anim:Object = textures.animation.animations;
			
			var cadr:uint 			= anim[_framesType].chain[frame];
			
			
			
			//if(oldCadr != cadr || oldDirection != framesDirection){
				//oldCadr = cadr;
				//oldDirection = framesDirection;
				if (anim[_framesType].frames[framesDirection] == undefined) {
					framesDirection = 0;
				}
				
				var frameObject:Object 	= anim[_framesType].frames[framesDirection][cadr];
				if (hasMultipleAnimation) multipleAnimation(cadr);
				
				bitmap.bitmapData = frameObject.bmd;
				bitmap.x = frameObject.ox * sign;
				bitmap.y = frameObject.oy - 30 + ay;
				
			//}
			
			frame++; 
			if (frame >= anim[_framesType].chain.length) {
				this.dispatchEvent(new Event(Event.COMPLETE));
				frame = 0;
			}
		}
		
		//private var oldMultipleCadr:int = -1;
		//private var oldMultipleDirection:int = -1;
		private function multipleAnimation(cadr:int):void
		{
			if (multipleAnime == null)
			{
				multiBitmap.bitmapData = null;
				return;
			}
			
			//if (oldMultipleCadr != cadr || oldMultipleDirection != framesDirection) {
				//oldMultipleCadr = cadr;
				//oldMultipleDirection = framesDirection;
				
				var frameObject:Object 	= multipleAnime[_framesType].frames[framesDirection][cadr];
				//var frameObject:Object 	= multipleAnime.frames[framesDirection][cadr];
				if (frameObject == null) return;
				multiBitmap.scaleX = bitmap.scaleX;
				multiBitmap.bitmapData = frameObject.bmd;
				multiBitmap.x = frameObject.ox * sign;
				multiBitmap.y = frameObject.oy - 30 + ay;
			//}
		}
		
		public function stopWalking():void
		{
			_walk = false;
			framesDirection = 0;
			frame = 0;
			path = null;
			App.self.setOffEnterFrame(walk);
		}
	}
}