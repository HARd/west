package units
{
	import astar.AStarNodeVO;
	import com.greensock.easing.Elastic;
	import com.greensock.easing.Strong;
	import com.greensock.plugins.TransformAroundPointPlugin;
	import com.greensock.plugins.TweenPlugin;
	import com.greensock.TweenLite;
	import com.greensock.TweenMax;
	import core.IsoConvert;
	import core.IsoTile;
	import core.Numbers;
	import core.Post;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.BlurFilter;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.utils.clearTimeout;
	import flash.utils.getDefinitionByName;
	import flash.utils.setTimeout;
	import ui.AnimalIcon;
	import ui.Cursor;
	import ui.Hints;
	import ui.SystemPanel;
	import ui.UnitIcon;
	import ui.UserInterface;
	import units.*;
	import units.PetHouse;
	import wins.ExchangeWindow;
	import wins.ShopWindow;
	import wins.SimpleWindow;
	import wins.Window;
	
	public class Unit extends LayerX
	{
		public const OCCUPIED:uint = 1;
		public const EMPTY:uint = 2;
		public const TOCHED:uint = 3;
		public const DEFAULT:uint = 4;
		public const IDENTIFIED:uint = 5;
		public const HIGHLIGHTED:uint = 6;
		
		public var touchable:Boolean = true;
		public var moveable:Boolean = true;
		public var transable:Boolean = true;
		public var removable:Boolean = true;
		public var clickable:Boolean = true;
		public var animated:Boolean = false;
		public var rotateable:Boolean = true;
		public var multiple:Boolean = false;
		public var takeable:Boolean = true;
		public var stockable:Boolean = false;
		public var removeAnyway:Boolean = false;
		
		public var touchableInGuest:Boolean = true;
		
		protected var _touch:Boolean = false;
		protected var _move:Boolean = false;
		protected var _trans:Boolean = false;
		protected var _install:Boolean = false;
		protected var _ordered:Boolean = false;
		protected var _state:uint = DEFAULT;
		protected var _rotate:Boolean = false;
		
		protected var previosRotate:Boolean = false;
		
		public var helped:Boolean = false;
		
		public var bitmap:Bitmap = new Bitmap(null, "auto", true);
		public var animationBitmap:Bitmap;
		public var layer:String;
		public var icon:UnitIcon;
		
		public var coords:Object = {x: 0, y: 0, z: 0};
		public var prevCoords:Object = {x: 0, y: 0, z: 0};
		
		public var id:uint = 0;
		public var sid:uint = 0;
		public var type:String;
		public var depth:uint = 0;
		public var info:Object;
		public var textures:Object;
		
		public var dx:int;
		public var dy:int;
		
		public var cells:uint = 0;
		public var rows:uint = 0;
		
		public var busy:uint = 0;
		
		public var index:uint = 0;
		
		public var fromStock:Boolean = false;
		
		public static var lastUnit:Object;
		public static var lastRemove:int;
		public var created:int;
		public var open:Boolean = false;
		
		private var _limitedCount:int = 0;
		protected var expired:uint = 0;
		
		public var loader:UnitPreloader;
		//public var loader:Preloader;
		public var hasLoader:Boolean = true;
		
		public function Unit(data:Object)
		{
			
			this.id = data.id || 0;
			this.sid = data.sid || 0;
			
			this.fromStock = data.fromStock || false;
			
			if (this.sid != 0)
			{
				info = App.data.storage[this.sid];
				type = info.type;
				
				_rotate = data['rotate'] || false;
				
				if (data.area)
				{
					info.area = data.area;
				}
				else
				{
					if (!info.area)
						info.area = {w: 1, h: 1};
					if (sid == 785)
						info.area = {w: 5, h: 10};
					
					if (!_rotate)
					{
						cells = info.area.w || 0;
						rows = info.area.h || 0;
					}
					else
					{
						cells = info.area.h || 0;
						rows = info.area.w || 0;
					}
				}
			}
			
			generateCenter();
			
			//drawPreview();
			//bitmap.alpha = 0.2
			
			bitmapContainer.addChild(bitmap);
			bitmapContainer.addChild(animationContainer);
			addChild(bitmapContainer);
			
			/*var b:Bitmap = new Bitmap(IsoTile._tile);
			   b.x = -IsoTile.width * .5;
			 addChild(b);*/
			
			/*var marker:Shape = new Shape()
			   marker.graphics.beginFill(0xFF0000, 1);
			   marker.graphics.drawRect( 0, 0, 2,2);
			   marker.graphics.endFill();
			 addChild(marker);*/
			
			placing(data.x || 0, data.y || 0, data.z || 0);
			
			if (!data.nonInstall)
				install();
			
			//bitmap.scaleX = 0.999;
			//bitmap.scaleY = 0.999;
			
			mouseEnabled = false;
			//cacheAsBitmap = true;
			//this.mouseEnabled = false
			
			if (data.fromMhelper)
				fromMhelper = data.fromMhelper;
			if (formed)
			{
				open = App.map._aStarNodes[coords.x][coords.z].open;
				if (!open)
				{
					clickable = false;
					touchable = false;
				}
			}
			
		}
		
		public function makeOpen():void
		{
			open = true;
			clickable = true;
			touchable = true;
			visible = true;
		}
		
		public var center:Object = {x: 0, y: 0};
		
		public function generateCenter():void
		{
			if (info && info.hasOwnProperty('area'))
				center = IsoConvert.isoToScreen(Math.floor(info.area.w / 2), Math.floor(info.area.h / 2), true, true);
		}
		
		public static var classes:Object = {};
		
		public static function add(object:Object):Unit
		{
			lastUnit = object;
			if (!App.data.storage.hasOwnProperty(object.sid))
				return null;
			var type:String = 'units.' + App.data.storage[object.sid].type;
			
			if (object.sid == 821) {
				type = 'units.Flyinggolden';
				App.data.storage[object.sid].view = 'eagle2';
			}
			if (object.sid == 902) {
				type = 'units.Flyinggolden';
			}
			
			var classType:Class;
			if (classes[type] == undefined)
			{
				if (type == 'units.Pfloors') {
					classType = getDefinitionByName('units.Floors') as Class;
				}else{
					classType = getDefinitionByName(type) as Class;
				}
				classes[type] = classType;
			}
			else
			{
				classType = classes[type];
			}
			
			var unit:Unit = new classType(object);
			if (unit.formed)
			{
				unit.take();
			}
			
			return unit;
		}
		
		public static function addMore():void
		{
			if (lastUnit != null)
			{
				if (lastUnit.hasOwnProperty('fromStock') && lastUnit.fromStock == true)
				{
					if (!App.user.stock.check(lastUnit.sid))
					{
						Cursor.type = "default";
						return;
					}
				}
				
				// Если садится грядка, но магазин уже перестал продавать грядки (например нет цены)
				if (lastUnit.pID && ShopWindow.currentBuyObject.sid != lastUnit.pID)
					return;
				
				var unit:Unit = add(lastUnit);
				unit.move = true;
				App.map.moved = unit;
			}
		}
		
		public static function sorting(unit:Unit):void
		{
			App.map.sorted.push(unit);
		}
		
		public function get formed():Boolean
		{
			return (this.id > 0);
		}
		
		public function can():Boolean
		{
			return ordered;
		}
		
		public function get bmp():Bitmap
		{
			return bitmap;
		}
		
		public function take():void
		{
			
			if (!takeable)
				return;
			var node:AStarNodeVO;
			var part:AStarNodeVO;
			var water:AStarNodeVO;
			
			var nodes:Vector.<AStarNodeVO> = new Vector.<AStarNodeVO>();
			var waters:Vector.<AStarNodeVO> = new Vector.<AStarNodeVO>();
			var parts:Vector.<AStarNodeVO> = new Vector.<AStarNodeVO>();
			
			/*if (rotate) {
			   cells = info.area.h;
			   rows = info.area.w;
			 }*/
			for (var i:uint = 0; i < cells; i++)
			{
				for (var j:uint = 0; j < rows; j++)
				{
					node = App.map._aStarNodes[coords.x + i][coords.z + j];
					
					nodes.push(node);
					
					node.isWall = true;
					node.b = 1;
					node.object = this;
					if (layer == Map.LAYER_FIELD || layer == Map.LAYER_LAND)
						node.isWall = false;
					
					if (i > 0 && i < cells - 1 && j > 0 && j < rows - 1)
					{
						part = App.map._aStarParts[coords.x + i][coords.z + j];
						parts.push(part);
						
						part.isWall = true;
						part.b = 1;
						part.object = this;
						if (layer == Map.LAYER_FIELD || layer == Map.LAYER_LAND)
							part.isWall = false;
						
						if (info.base != null && info.base == 1)
						{
							if (App.map._aStarWaterNodes != null)
							{
								water = App.map._aStarWaterNodes[coords.x + i][coords.z + j];
								waters.push(water);
								water.isWall = true;
								water.b = 1;
								water.object = this;
							}
						}
						
					}
					else
					{
						//trace('Оставляем пустое пространство');
					}
					
					/*
					   var _tile:Bitmap = new Bitmap(IsoTile._tile);
					   _tile.x = node.tile.x - IsoTile.width*.5;
					   _tile.y = node.tile.y;
					   App.map.mLand.addChild(_tile);
					 */
					
				}
			}
			
			if (layer == Map.LAYER_SORT)
			{
				App.map._astar.take(nodes);
				App.map._astarReserve.take(parts);
			}
			
			if (info.base != null && info.base == 1)
			{
				if (App.map._astarWater != null)
					App.map._astarWater.take(waters);
			}
		}
		
		public function free():void
		{
			if (!takeable)
				return;
			var node:AStarNodeVO;
			var part:AStarNodeVO;
			
			var nodes:Vector.<AStarNodeVO> = new Vector.<AStarNodeVO>();
			var parts:Vector.<AStarNodeVO> = new Vector.<AStarNodeVO>();
			
			if (App.map._aStarNodes != null)
			{
				for (var i:uint = 0; i < cells; i++)
				{
					for (var j:uint = 0; j < rows; j++)
					{
						node = App.map._aStarNodes[coords.x + i][coords.z + j];
						nodes.push(node);
						node.isWall = false;
						node.b = 0;
						node.object = null;
						
						part = App.map._aStarParts[coords.x + i][coords.z + j];
						parts.push(part);
						part.isWall = false;
						part.b = 0;
						part.object = null;
					}
				}
				
				if (layer == Map.LAYER_SORT)
				{
					App.map._astar.free(nodes);
					App.map._astarReserve.free(parts);
				}
				
				if (info.base != null && info.base == 1)
				{
					if (App.map._astarWater != null)
						App.map._astarWater.free(nodes);
				}
			}
		}
		
		public function set ordered(ordered:Boolean):void
		{
			_ordered = ordered;
			if (ordered)
			{
				clickable = false;
				alpha = .5;
				
				if (touch)
				{
					touch = false;
					var idx:int = App.map.touched.indexOf(this);
					if (idx >= 0)
					{
						App.map.touched.splice(idx, 1);
					}
				}
			}
			else
			{
				clickable = true;
				alpha = 1;
			}
		}
		
		public function get ordered():Boolean
		{
			return _ordered;
		}
		
		public function set state(state:uint):void
		{
			if (_state == state)
				return;
			
			switch (state)
			{
				case OCCUPIED: 
					bitmap.filters = [new GlowFilter(0xFF0000, 1, 6, 6, 7)];
					break;
				case EMPTY: 
					bitmap.filters = [new GlowFilter(0x00FF00, 1, 6, 6, 7)];
					break;
				case TOCHED: 
					//TweenMax.to(bitmap, 0.2, { colorTransform: { brightness:1.2 }} );
					//TweenMax.to(bitmap, 0.2, {colorTransform:{tint:0xffff00, tintAmount:0.2, brightness:1.1}});
					bitmap.filters = [new GlowFilter(0xFFFF00, 1, 6, 6, 7)];
					break;
				case HIGHLIGHTED: 
					bitmap.filters = [new GlowFilter(0x88ffed, 0.6, 6, 6, 7)];
					break;
				case IDENTIFIED: 
					bitmap.filters = [new GlowFilter(0x88ffed, 1, 8, 8, 10)];
					break;
				case DEFAULT: 
					bitmap.filters = [];
					//TweenMax.to(bitmap, 0.2, { colorTransform: { brightness:1 }} );	
					//TweenMax.to(bitmap, 0.2, {colorTransform:{tint:0xffff00, tintAmount:0, brightness:1}});
					break;
			}
			_state = state;
		}
		
		public function get state():uint
		{
			return _state;
		}
		
		public function canInstall():Boolean
		{
			return (_state != OCCUPIED);
		}
		
		public function placing(x:uint, y:uint, z:uint):void
		{
			
			var node:AStarNodeVO;
			
			if (x + cells > Map.cells || z + rows > Map.rows)
			{
				takeable = false;
				return;
			}
			else
			{
				takeable = true;
			}
			
			if (!App.map._aStarNodes) return;
			
			node = App.map._aStarNodes[x][z];
			
			coords = {x: x, y: y, z: z};
			this.x = node.tile.x;
			this.y = node.tile.y;
			
			iconSetPosition(0, 0, ((move) ? true : false));
			calcDepth();
			
			if (move)
				state = calcState(node);
		}
		
		public function calcState(node:AStarNodeVO):int
		{ 
			if (App.self.constructMode) return EMPTY;
			for (var i:uint = 0; i < cells; i++)
			{
				for (var j:uint = 0; j < rows; j++)
				{
					node = App.map._aStarNodes[coords.x + i][coords.z + j];
					trace('b = ', node.b, ' open = ' , node.open, ' object = ', node.object);
					if (node.b != 0 || node.open == false || node.object != null || (node.object != null && (node.object is Stall) && node.b != 0))
					{
						return OCCUPIED;
					}
				}
			}
			return EMPTY;
		}
		
		public function install():void
		{
			App.map.addUnit(this);
		}
		
		public function uninstall():void
		{
			free();
			App.map.removeUnit(this);
			if (formed)
			{
				World.removeBuilding(this);
			}
			clearIcon();
		}
		
		public function sort(index:*):void
		{
			try {
				App.map.mSort.setChildIndex(this, index);
			} catch (e:Error) {
				
			}
		}
		
		public function calcDepth():void
		{
			var left:Object = {x: x - IsoTile.width * rows * .5, y: y + IsoTile.height * rows * .5};
			var right:Object = {x: x + IsoTile.width * cells * .5, y: y + IsoTile.height * cells * .5};
			depth = (left.x + right.x) + (left.y + right.y) * 100;
		}
		
		public var bitmapContainer:Sprite = new Sprite();
		public var animationContainer:Sprite = new Sprite();
		
		public function draw(bitmapData:BitmapData, dx:int, dy:int):void
		{
			
			bitmap.bitmapData = bitmapData;
			//bitmap.smoothing = true;
			//bitmap.scaleX = 1;
			
			this.dx = dx;
			this.dy = dy;
			bitmap.x = dx;
			bitmap.y = dy;
			
			if (rotate && scaleX > 0)
			{
				scaleX = -scaleX;
			}
		}
		
		protected var tween:TweenLite;
		public var transTimeID:uint;
		
		public function set transparent(transparent:Boolean):void
		{
			if (!transable || _trans == transparent || (App.user.quests.tutorial && transparent == true))
				return;
			var that:* = bitmapContainer;
			if (transparent == true)
			{
				_trans = true;
				
				transTimeID = setTimeout(function():void
					{
						if (SystemPanel.animate)
							tween = TweenLite.to(that, 0.2, {alpha: 0.3});
						else
							that.alpha = 0.3;
					}, 150);
				
			}
			else
			{
				clearTimeout(transTimeID);
				_trans = false;
				if (tween)
				{
					tween.complete(true);
					tween.kill();
					tween = null;
				}
				that.alpha = 1;
			}
		}
		
		public function get transparent():Boolean
		{
			return _trans;
		}
		
		public function previousPlace():void
		{
			if (_move != true) return;
			
			if (formed) {
				_move = false;
				
				if (_rotate != previosRotate)
				{
					_rotate = !_rotate;
					previosRotate = _rotate;
					var temp:uint = cells;
					cells = rows;
					rows = temp;
					scaleX = -scaleX;
					x -= width * scaleX;
				}
				
				placing(prevCoords.x, prevCoords.y, prevCoords.z);
				take();
				state = DEFAULT;
				App.self.setOffEnterFrame(moving);
			}else if ((App.map.moved is Resource) && (App.map.moved as Resource).garden != null) {
				_move = false;
				
				if (_rotate != previosRotate)
				{
					_rotate = !_rotate;
					previosRotate = _rotate;
					var tempo:uint = cells;
					cells = rows;
					rows = tempo;
					scaleX = -scaleX;
					x -= width * scaleX;
				}
				
				placing(prevCoords.x, prevCoords.y, prevCoords.z);
				take();
				state = DEFAULT;
				App.self.setOffEnterFrame(moving);
			}else{
				_move = false;
				App.self.setOffEnterFrame(moving);
				uninstall();
			}
			if (App.map.moved == this)
			{
				App.map.moved = null;
			}
			
			clearGrid();
			alpha = 1;
		}
		
		public var fromMhelper:Boolean = false;
		public function set move(move:Boolean):void
		{
			if (!moveable || _move == move)
			{
				return;
			}
			_move = move;
			if (move)
			{
				if (formed)
				{
					free();
				}
				App.map.iconSortSetHighest(icon);
				prevCoords = coords;
				App.self.setOnEnterFrame(moving);
				
				if (Config.admin)
					createGrid();
			}
			else
			{
				if (icon)
					App.map.iconSortResort(true);
				
				if (state == EMPTY)
				{
					take();
					
					if (fromStock == true)
					{
						stockAction();
					}else if (fromMhelper == true) {
						Mhelper.detachAction(this);
					}else if (!formed)
					{
						buyAction();
					}
					else
					{
						moveAction();
					}
					
					state = DEFAULT;
					App.self.setOffEnterFrame(moving);
					
				}
				else
				{
					_move = true;
				}
			}
		}
		
		public function get move():Boolean
		{
			return _move;
		}
		
		protected function moving(e:Event = null):void
		{
			if (coords.x != Map.X || coords.z != Map.Z)
			{
				placing(Map.X, 0, Map.Z);
				if (layer == Map.LAYER_SORT)
				{
					//App.map.depths[index] = depth;
					App.map.sorted.push(this);
				}
				
			}
			
			if(Config.admin)
				createGrid();
		}
		
		public function flip():void
		{
			var temp:uint = cells;
			cells = rows;
			rows = temp;
			
			scaleX = -scaleX;
			x -= width * scaleX;
			//bitmap.scaleX = -bitmap.scaleX;
			//bitmap.x = bitmap.width + (-bitmap.width - bitmap.x);
			
			placing(coords.x, coords.y, coords.z);
		}
		
		public function set rotate(rotate:Boolean):void
		{
			if (!rotateable || _rotate == rotate)
				return;
			previosRotate = _rotate;
			_rotate = rotate;
			
			free();
			
			Cursor.type = "move";
			Cursor.prevType = "rotate";
			App.map.moved = this;
			move = true;
			
			flip();
			/*var node:AStarNodeVO;
			   for (var i:uint = 0; i < cells; i++) {
			   for (var j:uint = 0; j < rows; j++) {
			   node = App.map._aStarNodes[coords.x + i][coords.z + j];
			   if (node.b != 0) {
			   state = OCCUPIED;
			   }
			   }
			 }*/
			
			return;
		}
		
		public function get rotate():Boolean
		{
			return _rotate;
		}
		
		public function set touch(touch:Boolean):void
		{
			if (Cursor.type == 'stock' && stockable == false)
				return;
			
			if (Cursor.type == 'remove' && removable == false)
				return;
			
			if (Cursor.type == 'rotate' && rotateable == false)
				return;
			
			if (!touchable || (App.user.mode == User.GUEST && touchableInGuest == false))
				return;
			
			_touch = touch;
			
			if (touch)
			{
				if (state == DEFAULT)
				{
					state = TOCHED;
				}
				else if (state == HIGHLIGHTED)
				{
					state = IDENTIFIED;
				}
				
			}
			else
			{
				if (state == TOCHED)
				{
					state = DEFAULT;
				}
				else if (state == IDENTIFIED)
				{
					state = HIGHLIGHTED;
				}
			}
		}
		
		public function get touch():Boolean
		{
			return _touch;
		}
		
		public function remove(_callback:Function = null):void
		{
			
			var callback:Function = _callback;
			
			if (!removable)
				return;
			
			if (info && info.hasOwnProperty('ask') && info.ask && !removeAnyway)
			{
				new SimpleWindow({width: 540, title: Locale.__e("flash:1382952379842"), fontBorderColor: 0xbc9a50, text: Locale.__e("flash:1382952379968", [info.title]), label: SimpleWindow.ERROR, dialog: true, isImg: false, bitmap: bitmap, sid: this.sid, confirm: function():void
					{
						onApplyRemove(callback);
					}}).show();
			}
			else
			{
				onApplyRemove(callback)
			}
		}
		
		public function onApplyRemove(callback:Function = null):void
		{
			if (!removable)
				return;
			
			Post.send({ctr: this.type, act: 'remove', uID: App.user.id, wID: App.user.worldID, sID: this.sid, id: this.id}, onRemoveAction, {callback: callback});
			
			this.visible = false;
		}
		
		public function onRemoveAction(error:int, data:Object, params:Object):void
		{
			if (error)
			{
				Errors.show(error, data);
				this.visible = true;
				return;
			}
			uninstall();
			if (params.callback != null)
			{
				params.callback();
			}
			
			if ([738,749,797,815,816,817,835,935,980,981,982,1302,1845,1868,1658,2201,2371,2732].indexOf(int(sid)) != -1) {
				var dt:int = App.user.storageRead('building_' + sid, 0);
				dt -= 1;
				App.user.storageStore('building_' + sid, dt, true);
			}
		}
		
		public function click():Boolean
		{
			
			if (!clickable || (App.user.mode == User.GUEST && touchableInGuest == false))
				return false;
			
			App.tips.hide();
			
			return true;
		}
		
		public function animate(e:Event = null, forceAnimate:Boolean = false):void
		{
		
		}
		
		/********************* ПОЛЬЗОВАТЕЛЬСКИЕ СОБЫТИflash:1382952380041 **************************/
		
		public function putAction():void
		{
			if (!stockable)
			{
				return;
			}
			
			uninstall();
			App.user.stock.add(sid, 1);
			
			Post.send({ctr: this.type, act: 'put', uID: App.user.id, wID: App.user.worldID, sID: this.sid, id: this.id}, function(error:int, data:Object, params:Object):void
				{
				
				});
		}
		
		public function stockAction(params:Object = null):void
		{
			
			if (!App.user.stock.check(sid))
			{
				//TODO показываем окно с ообщением, что на складе уже нет ничего
				return;
			}
			else if (!World.canBuilding(sid))
			{
				uninstall();
				return;
			}
			
			if (params && params.coords) {
				coords.x = params.coords.x;
				coords.z = params.coords.z;
			}
			
			App.user.stock.take(sid, 1);
			
			Post.send({ctr: this.type, act: 'stock', uID: App.user.id, wID: App.user.worldID, sID: this.sid, x: coords.x, z: coords.z}, onStockAction);
		}
		
		public function onAfterStock():void
		{
			moveable = true;
		}
		
		protected function onStockAction(error:int, data:Object, params:Object):void
		{
			if (error)
			{
				Errors.show(error, data);
				return;
			}
			
			this.id = data.id;
			if (!(multiple && App.user.stock.check(sid)))
			{
				App.map.moved = null;
			}
			
			App.ui.glowing(this);
			World.addBuilding(this.sid);
			onAfterStock();
			
			clearGrid();
		}
		
		public function buyAction():void
		{
			
			SoundsManager.instance.playSFX('build');
			
			if (Storage.isShopLimited(sid) && Storage.shopLimit(sid) >= info.gcount && ['Mfloors'].indexOf(App.data.storage[sid].type) == -1 && sid != 2732) {
				Hints.text(Locale.__e('flash:1401883824721'), Hints.TEXT_RED, new Point(App.self.mouseX, App.self.mouseY));
				Unit.lastUnit = null;
				uninstall();
				return;
			}
			
			if (!World.canBuilding(sid)) {
				Hints.text(Locale.__e('flash:1401883824721'), Hints.TEXT_RED, new Point(App.self.mouseX, App.self.mouseY));
				Unit.lastUnit = null;
				
				uninstall();
				return;
			}
			
			var obj:Object = Storage.price(sid);
			
			//если WalkGolden и вор то для него не ищем, иначе
			var serachEnabled:Boolean = (this is Walkgolden)? !(this as Walkgolden).isThief:true;
			
			if (App.user.stock.takeAll(obj, false, serachEnabled))
			{
				
				World.addBuilding(this.sid);
				Hints.buy(this);
				//spit();
				
				Post.send({ctr: this.type, act: 'buy', uID: App.user.id, wID: App.user.worldID, sID: this.sid, x: coords.x, z: coords.z}, onBuyAction);
				
				dispatchEvent(new AppEvent(AppEvent.AFTER_BUY));
			}
			else
			{
				ShopWindow.currentBuyObject.type = null;
				free();
				App.map.removeUnit(this);
				clearIcon();
				
				var id:String;
				for (var s:String in App.data.storage[this.sid].price)
				{
					id = s;
				}
				if (!s) {
					for (s in App.data.storage[this.sid].instance.cost[1])
					{
						id = s;
					}
				}
				if (uint(s) == Stock.FRANKS)
				{
					ShopWindow.show( { find: [717, 718, 719] } );
				}
				if (uint(s) == Stock.HELLOWEEN_ICON)
				{
					ShopWindow.show( { find: [1030, 1031, 1032] } );
				}
				
				Hints.text(Locale.__e('flash:1470823262859'), Hints.TEXT_RED, new Point(App.self.mouseX, App.self.mouseY));
			}
		}
		
		protected function onBuyAction(error:int, data:Object, params:Object):void
		{
			if (error) {
				uninstall();
				Errors.show(error, data);
				return;
			}
			
			this.id = data.id;
			
			clearGrid();
			
			// Регистрация покупки объекта с полем gcount
			if (Storage.isShopLimited(sid)/* && ['Floors','Walkgolden','Booker','Golden'].indexOf(App.data.storage[sid].type) != -1*/) {
				Storage.shopLimitBuy(sid);
				App.user.updateActions();
				App.ui.salesPanel.updateSales();
				App.user.storageStore('shopLimit', Storage.shopLimitList, true);
			}
		}
		
		public function moveAction():void
		{
			
			if (Cursor.prevType == "rotate")
				Cursor.type = Cursor.prevType;
			
			Post.send({ctr: this.type, act: 'move', uID: App.user.id, wID: App.user.worldID, sID: this.sid, id: id, x: coords.x, z: coords.z, rotate: int(rotate)}, onMoveAction);
		}
		
		public function onMoveAction(error:int, data:Object, params:Object):void
		{
			if (error)
			{
				Errors.show(error, data);
				
				free();
				_move = false;
				placing(prevCoords.x, prevCoords.y, prevCoords.z);
				take();
				state = DEFAULT;
				
				//TODO меняем координаты на старые
				return;
			}
			
			clearGrid();
		}
		
		public function rotateAction():void
		{
			
			Post.send({ctr: this.type, act: 'rotate', uID: App.user.id, wID: App.user.worldID, sID: this.sid, id: id, rotate: int(rotate)}, onRotateAction);
		}
		
		public function onDown():void
		{
		
		}
		
		private function onRotateAction(error:int, data:Object, params:Object):void
		{
			if (error)
			{
				Errors.show(error, data);
				//TODO меняем координаты на старые
				return;
			}
		}
		
		public static function explode(obj:Object):Object
		{
			for (var sID:*in obj)
				break;
			return {sID: sID, id: obj[sID]};
		}
		
		public function colorize(data:*):void
		{
			return;
			if (data.hasOwnProperty('colorize') && data.colorize)
				return;
			data['colorize'] = true;
			data.sprites[0].bmp = Nature.colorize(data.sprites[0].bmp, info.type);
		}
		
		public var _worker:Hero = null;
		
		public function get worker():Hero
		{
			return _worker;
		}
		
		public function set worker(value:*):void
		{
			_worker = value;
		}
		
		public var spitY:Number;
		public var spitX:Number;
		private var spitCallback:Function;
		
		public function spit(callback:Function = null, target:* = null):void
		{
			if (target == null)
				target = bitmap;
			
			if (target is Bitmap)
				target.smoothing = true;
			
			spitCallback = callback;
			var obj:Object = IsoConvert.isoToScreen(info.area.w, info.area.h, true, true);
			spitY = obj.y;
			spitX = obj.x;
			spitIn(target);
		}
		
		private function spitIn(target:*):void
		{
			TweenPlugin.activate([TransformAroundPointPlugin]);
			TweenLite.to(target, 0.3, {transformAroundPoint: {point: new Point(spitX, spitY), scaleX: 1.1, scaleY: 0.9}, ease: Strong.easeOut}); //1.2 0.8
			setTimeout(function():void
				{
					spitOut(target)
				}, 200);
		}
		
		private function spitOut(target:*):void
		{
			TweenLite.to(target, 1, {transformAroundPoint: {point: new Point(spitX, spitY), scaleX: 1, scaleY: 1}, ease: Elastic.easeOut, onComplete: function():void
				{
				}});
			if (spitCallback != null)
				spitCallback();
		}
		
		public function haloEffect(color:* = null, layer:* = null):void
		{
		
			//return;
		/*var that:* = this;
		
		   if(layer != null)
		   that = layer;
		
		   var effect:AnimationItem = new AnimationItem( { type:'Effects', view:'halo3', params: { scale:1 }, onLoop:function():void {
		   that.removeChild(effect);
		   }});
		   //effect.blendMode = BlendMode.ADD;
		   that.addChild(effect);
		   effect.x = that.mouseX;
		   effect.y = that.mouseY;
		
		   if (color != null) {
		   UserInterface.colorize(effect, color, 1);
		 }*/
		}
		
		// Icon
		public var iconPosition:Object = {x: 0, y: 0};
		public var bounds:Object;
		private var isStreaming:Boolean = false;
		private var lastIconX:Number = 0;
		private var lastIconY:Number = 0;
		private const STREAM_SLUCK:Number = 2;
		
		public function drawIcon(type:String, material:*, need:int = 0, params:Object = null):void
		{
			if (icon)
				clearIcon();
			if (!formed || !parent)
				return;
			
			if ((this is Animal) || (this is Tree) || (this is Invader) && need == 0)
			{
				icon = new AnimalIcon(type, material, need, this, params);
			}
			else
			{
				icon = new UnitIcon(type, material, need, this, params);
			}
			icon.x = this.x;
			icon.y = this.y;
			
			if (!App.map.mIcon.contains(icon))
				App.map.mIcon.addChild(icon);
			
			iconSetPosition();
			App.map.iconSortResort();
		}
		
		public function clearIcon():void
		{
			if (icon)
			{
				icon.dispose();
				icon = null;
			}
		}
		
		public function iconSetPosition(x:int = 0, y:int = 0, stream:Boolean = false):void
		{
			if (isStreaming)
				return;
			if (!icon)
				return;
			if (!bounds && textures)
				countBounds();
			if (bounds)
			{
				if (!stream)
				{
					iconIndentCount();
					icon.x = this.x + ((x == 0) ? iconPosition.x : x);
					icon.y = this.y + ((y == 0) ? iconPosition.y : y);
				}
				else
				{
					isStreaming = true;
					App.self.setOnEnterFrame(streaming);
				}
			}
		}
		
		private function streaming(e:Event = null):void
		{
			if (!icon)
				return;
			lastIconX = icon.x;
			lastIconY = icon.y;
			icon.x = icon.x + (this.x - icon.x + iconPosition.x) / STREAM_SLUCK;
			icon.y = icon.y + (this.y - icon.y + iconPosition.y) / STREAM_SLUCK;
			if (!move && lastIconX == icon.x && lastIconY == icon.y)
			{
				isStreaming = false;
				App.self.setOffEnterFrame(streaming);
			}
		}
		
		public function iconIndentCount():void
		{
			// Рассчитывает отступ иконки от 0,0
			if (!bounds)
				return;
			iconPosition.x = bounds.x + bounds.w / 2;
			iconPosition.y = bounds.y + 15;
		}
		
		public function countBounds(animation:String = '', stage:int = -1, checkAnimation:Boolean = true):void
		{
			bounds = Anime.bounds(textures, {stage: stage, animation: animation, checkAnimation: checkAnimation, walking: ((this is WUnit) ? true : false)});
		}
		
		// Preview
		public function drawPreview():void
		{
			var scale:int = 1;
			if (_rotate)
				scale = -1;
			
			var sizeX:Number = 9.8; //19.6;
			var sizeY:Number = 4.9; // 9.8;
			var shape:Shape = new Shape();
			shape.name = 'preview';
			shape.graphics.beginFill(0x00FF00, 0.3);
			shape.graphics.lineStyle(1, 0x00FF00, 0.6);
			shape.graphics.moveTo(0, 0);
			shape.graphics.lineTo(-sizeX * rows * scale, sizeY * rows);
			shape.graphics.lineTo((-sizeX * rows + sizeX * cells) * scale, sizeY * rows + sizeY * cells);
			shape.graphics.lineTo(sizeX * cells * scale, sizeY * cells);
			shape.graphics.lineTo(0, 0);
			shape.graphics.endFill();
			addChild(shape);
		}
		
		public function clearPreview():void
		{
			var shape:Shape = getChildByName('preview') as Shape;
			removeChild(shape);
		}
		
		
		
		
		//Grid
		private static var colorizedUnits:Vector.<Unit> = new Vector.<Unit>;
		public function createGrid():void{
			alpha = 1;
			
			clearGrid();
			
			var node:Object;
			var ___X:* = ((coords.x + cells ) < Map.cells)? coords.x + cells: Map.cells - 1;
			var ___Z:* = ((coords.z + rows ) < Map.rows)? coords.z + rows: Map.rows - 1;
			for (var _x:int = ((coords.x) >= 0)? coords.x : 0; _x < ___X; _x++) {
				for (var _z:int = ((coords.z ) >= 0)? coords.z: 0; _z < ___Z; _z++) {
					
					if (!App.map._aStarNodes) continue;
					
					node = App.map._aStarNodes[_x][_z];
					
					if (node.object && (node.object is Unit) && colorizedUnits.indexOf(node.object) == -1) {
						node.object.state = OCCUPIED;
						colorizedUnits.push(node.object);
						alpha = 0.4;
					}
				}
			}
		}
		private var lineContainer:Sprite;
		private var _plane:Sprite;
		private var maska:Shape;
		private var dY:int;
		private var delta:int;
		public function addMask(dY:int = 250, delta:int = 80):void 
		{
			this.dY = dY;
			this.delta = delta;
			maska = new Shape();
			maska.graphics.beginFill(0xFFFFFF, 1);
			maska.graphics.drawRect(0, 0, bitmap.width, 300);
			maska.graphics.endFill();
			addChild(maska);
			if (rotate && scaleX > 0) {
				scaleX = -scaleX;
			}
			maska.filters = [new BlurFilter(0, 30, 2)];
			maska.cacheAsBitmap = true;
			bitmap.cacheAsBitmap = true;
			bitmap.mask = maska;
			//maska.x = bitmap.x; 
			//maska.y = bitmap.y + bitmap.height  - dY + int(Math.random() * 80) - maska.height;
			
			var _dx:int = bitmap.x;
			var _dy:int = bitmap.y;
			
			bitmap.x = 0;
			bitmap.y = 0;
			maska.x = bitmap.x; 
			maska.y = bitmap.y + bitmap.height  - dY + int(Math.random() * delta) - maska.height;
			
			var bmd:BitmapData = new BitmapData(bitmap.width, bitmap.height, true, 0);
			bmd.draw(this);
			
			bitmap.x = _dx;
			bitmap.y = _dy;
			bitmap.mask = null;
			removeChild(maska);
			maska = null;
			if (App.map.fogManager)
				App.map.fogManager.addToFog(this);
			//Fog.addToFog(bmd, this);
		}
		public function get maskBMD():BitmapData
		{
			
			maska = new Shape();
			maska.graphics.beginFill(0xFFFFFF, 1);
			maska.graphics.drawRect(0, 0, bitmap.width, 350);
			maska.graphics.endFill();
			addChild(maska);
			maska.filters = [new BlurFilter(0, 128, BitmapFilterQuality.LOW)];
			maska.cacheAsBitmap = true;
			bitmap.cacheAsBitmap = true;
			bitmap.mask = maska;
			
			var _dx:int = bitmap.x;
			var _dy:int = bitmap.y;
			
			bitmap.x = 0;
			bitmap.y = 0;
			maska.x = bitmap.x; 
			maska.y = bitmap.y + bitmap.height  - dY + int(Math.random() * delta) - maska.height;
			//var cloud:Bitmap = new Bitmap(App.map.fogManager.fogsImages[0]);
			//cloud.rotation = 90;
			//cloud.height = bitmap.height * 1.2;
			//cloud.scaleX = cloud.scaleY;
			//cloud.y = -maska.y - 300;
			//cloud.x = +bitmap.width ;
			//addChildAt(cloud, 0);
			
			var bmd:BitmapData = new BitmapData(bitmap.width, bitmap.height, true, 0);
			bmd.draw(this);
			
			bitmap.x = _dx;
			bitmap.y = _dy;
			bitmap.mask = null;
			removeChild(maska);
			maska = null;
			//removeChild(cloud);
			function inMapPos():Boolean
			{
				return ((x + bitmap.x>= App.map.bitmap.x) && (x + bitmap.x + bmd.width <= App.map.bitmap.x + App.map.bitmap.width)
					&& (y + bitmap.y>= App.map.bitmap.y) && (y + bitmap.y + bmd.height <= App.map.bitmap.y + App.map.bitmap.height));
			}
			

			
			//var cloudBitmapData:BitmapData = new BitmapData(App.map.fogManager.fog2.width, App.map.fogManager.fog2.height, true);
			
			if (!inMapPos())
				return null;
			return bmd;
		}
		public static function clearGrid():void {
			while(colorizedUnits.length) {
				colorizedUnits.shift().state = 4; // Unit:DEFAULT
			}
		}
		
		public function findPlaceNearTarget(target:*, radius:int = 3):Object
		{
			var places:Array = [];
			
			var targetX:int = target.coords.x;
			var targetZ:int = target.coords.z;
			
			var startX:int = targetX/* - radius*/;
			var startZ:int = targetZ/* - radius*/;
			
			if (startX <= 0) startX = 1;
			if (startZ <= 0) startZ = 1;
			
			var area:Object = { h:2, w:2 };
			if (target.info.area) {
				area = target.info.area;
			}
			
			var finishX:int = targetX + radius * 2 + area.w;
			var finishZ:int = targetZ + radius * 2 + area.h;
			
			if (finishX >= Map.cells) finishX = Map.cells - 1;
			if (finishZ >= Map.rows) finishZ = Map.rows - 1;
			
			for (var pX:int = startX; pX < finishX; pX++)
			{
				for (var pZ:int = startZ; pZ < finishZ; pZ++)
				{
					if ((coords.x <= pX && pX <= targetX +area.w) &&
					(coords.z <= pZ && pZ <= targetZ + area.h)){
						continue;
					}
					
					if (App.map._aStarNodes && App.map._aStarNodes[pX][pZ].isWall) 
						continue;
						
					if (App.map._aStarNodes && App.map._aStarNodes[pX][pZ].open == false) 
						continue;	
					
					places.push( { x:pX, z:pZ} );
				}
			}
			
			if (places.length == 0) {
				places.push( { x:coords.x, z:coords.z } );
			}
			var random:uint = int(Math.random() * (places.length - 1));
			return places[random];
		}
	}
}
