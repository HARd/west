package units
{
	import astar.AStarNodeVO;
	import com.greensock.easing.Elastic;
	import com.greensock.TweenLite;
	import core.Load;
	import core.Post;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.utils.clearInterval;
	import flash.utils.setInterval;
	import flash.utils.setTimeout;
	import ui.Cursor;
	import ui.IconsMenu;
	import ui.UnitIcon;
	import ui.UserInterface;
	import wins.Window;
	
	public class Firework extends Decor{

		public static var _boom:Boolean = false;
		public function Firework(object:Object)
		{
			layer = Map.LAYER_SORT;
			if (App.data.storage[object.sid].dtype == 1)
				layer = Map.LAYER_LAND;
			
			super(object);
			
			touchableInGuest = false;
			multiple = false;
			stockable = true;
			moveable = true;
			rotateable = false;
			
			if (info.count == 0)
				multiple = true;
			
			Load.loading(Config.getSwf(info.type, 'explode'), onLoadExplode);
		}
		
		override public function onLoad(data:*):void {
			textures = data;
			var levelData:Object = textures.sprites[0];
			draw(levelData.bmp, levelData.dx, levelData.dy);
			
			framesType = info.view;
			if (textures && textures.hasOwnProperty('animation')) 
				initAnimation();
		}
		
		private var explodeTextures:Object = null;
		private function onLoadExplode(data:*):void {
			explodeTextures = data;
		}
		
		override public function set touch(touch:Boolean):void 
		{
			if (!touchable) 
				return;
			
			if (!touchable || (App.user.mode == User.GUEST && touchableInGuest == false)) return;
			
			_touch = touch;
			
			if (touch) {
				if(state == DEFAULT){
					state = TOCHED;
				}else if (state == HIGHLIGHTED) {
					state = IDENTIFIED;
				}
				
			}else {
				if(state == TOCHED){
					state = DEFAULT;
				}else if (state == IDENTIFIED) {
					state = HIGHLIGHTED;
				}
			}
			
			if (Cursor.type != 'default') {				
				clearIcon();
				readyToBoom = false;
				hideTargets();
				
			}
		}
		
		private var iconMenu:IconsMenu;
		private var readyToBoom:Boolean = false;
		override public function click():Boolean 
		{
			if (!super.click() || this.id == 0) return false;
			
			if (_boom == true) {
				return true;
			}
			
			if (readyToBoom) {
				clearIcon();
				initBoom();
				return true;
			}	
			
			var icons:Array = [];
			var dY:int = 0;
		
			//showIcon('require', initBoom, AnimalCloud.MODE_NEED);
			showIcon();
			showTargets();
			
			return true;
			/*if (!super.click() || this.id == 0) return false;
			
			if (_boom == true) {
				return true;
			}
			var icons:Array = [];
			var dY:int = 0;
			icons.push( { status:true,	image:UserInterface.textures.fireworkIcon, 	callback:initBoom, params:sid, description:Locale.__e("flash:1383658502987")} );
			
			iconMenu = new IconsMenu(icons, [this], hideTargets, dY);
			iconMenu.show();
			
			showTargets();
			return true;*/
		}
		
		public var damageTargets:Array = [];
		public var targets:Array = [];
		private function showTargets(params:Object = null):void 
		{
			hideTargets();
			var startX:int = coords.x - info.count;
			var startZ:int = coords.z - info.count;
			var finishX:int = coords.x + info.count;
			var finishZ:int = coords.z + info.count;
			
			if (startX < 0) startX = 0;
			if (startZ < 0) startZ = 0;
			
			if (finishX > Map.cells) finishX = Map.cells;
			if (finishZ > Map.rows) finishZ = Map.rows;
			
			var index:int = App.map.mSort.numChildren;
			var unit:*;
			var _x:int = 0;
			var _z:int = 0;
			var radius:int = 10;
			
			while (index > 0) {
				index--;
				unit = App.map.mSort.getChildAt(index);
				
				if (!(unit is Resource) || !unit.hasOwnProperty('coords')) continue;
				if (sid != 1556 && [1555, 1558].indexOf(int(unit.sid)) != -1) continue;
				if ((unit as Resource).open == false) continue;
				
				if ((unit as Resource).info.hasOwnProperty('require')) {
					var normalMaterials:Array = [];
					for (var rid:* in unit.info.require) {
						// Если не системный
						if (App.data.storage.hasOwnProperty(rid) && App.data.storage[rid].mtype != 3) {
							normalMaterials.push(rid);
						}
					}
					if (normalMaterials.length > 0) continue;
				}
				
				if (radius > Math.sqrt((unit.coords.x - coords.x) * (unit.coords.x - coords.x) + (unit.coords.z - coords.z) * (unit.coords.z - coords.z))) {
					targets.push(unit);
				}
			}
			
			for (var s:* in targets) {
				if (targets[s].busy == true) {
					targets.splice(int(s), 1);
					continue;
				}
				targets[s].state = HIGHLIGHTED;
			}
			
			if (targets.length > 0) readyToBoom = true;
		}
		
		private function hideTargets():void {
			for each(var target:Resource in targets) {
				target.state = DEFAULT;
			}
			targets = [];
		}
		
		private function generateDamage():void {
			if (lastObject) {
				damageTargets = [];
				damageTargets.push(lastObject);
			}
			
			var target:Resource;
			var damageLeft:int = info.capacity;
			
			var destroyed:Array = [];
			
			while (damageLeft > 0) {
				if (damageTargets.length <= destroyed.length) break;
				
				for (var i:int = 0; i < damageTargets.length; i++) {
					target = damageTargets[i];
					if (destroyed.indexOf(target) != -1) continue;
					if (target.capacity - target.damage > 0) {
						target.damage ++;
						damageLeft --;
						if (damageLeft <= 0) break;
					}
					else
					{
						destroyed.push(target);
					}
				}
			}
		}
		
		public function initBoom(params:Object = null):void {
			
			_boom = true;
			
			clickable = false;
			touchable = false;
			moveable = false;
			removable = false;
			rotateable = false;
			stockable = false;
			
			damageTargets = [];
			damageTargets = damageTargets.concat(targets);
			for each(var target:Resource in targets) {
				target.busy = 1;
				target.clickable = false;
			}
			startCountdown();
		}
		
		private function showExplodes():void {
			
			var counter:int = 0;
			var X:int = App.map.x;
			var Y:int = App.map.y;
			
			doExplode();
			var count:int = 0;
			var interval:int = setInterval(doExplode, 300);
			
			function doExplode():void 
			{
				if (counter >= damageTargets.length)
				{
					clearInterval(interval);
					hideTargets();
					_boom = false;
					return;
				}
				
				var target:Resource = damageTargets[counter];
				setTimeout(target.showDamage, 200);
				
				var explode:Explode = new Explode(explodeTextures);
				explode.filters = [new GlowFilter(0xffFF00, 1, 15, 15, 4, 3)];
				explode.x = target.x;
				explode.y = target.y - 100;
				counter ++;	
			}
			
			/*App.map.x += 200 - int(Math.random() * 400);
			App.map.y += 200 - int(Math.random() * 400);
			TweenLite.to(App.map, 1, { x:X, y:Y, ease:Elastic } );*/
		}
		
		private function boom(params:Object = null):void 
		{
			generateDamage();
			
			var _units:Array = [];
			var _freezers:Array = [];
			
			for (var i:int = 0; i < damageTargets.length; i++) 
			{
				var target:* = damageTargets[i];
				var array:Array = [target.sid, target.id, target.damage];
				if (target.damage >= target.capacity && target is Freezer) {
					_freezers = _freezers.concat(target.getOpened());
				}
				_units.push(array);
			}
			
			showExplodes();
			
			var that:*= this;
			
			Post.send({
				ctr:this.type,
				act:'boom',
				uID:App.user.id,
				id:this.id,
				wID:App.user.worldID,
				sID:this.sid,
				units:JSON.stringify(_units),
				ids:JSON.stringify(_freezers)
			}, function(error:*, data:*, params:*):void 
			{
				if (error) {
					Errors.show(error, data);
					return;
				}
				
				App.ui.flashGlowing(that.bitmap);
				TweenLite.to(that, 1, { alpha:0, onComplete:uninstall } );
				Treasures.bonus(data.bonus, new Point(that.x, that.y));
				
				readyToBoom = false;
			});	
		}
		
		private var countDown:TextField;
		private var counter:int = 4;
		private var cont:Sprite;
		private function startCountdown():void {
			cont = new Sprite();
			countDown = Window.drawText(String(counter), {
				color:0xffdc39,
				borderColor:0x6d4b15,
				textAlign:"center",
				fontSize:30,
				width:30
			});
			
			cont.addChild(countDown);
			countDown.x = -countDown.width / 2;
			countDown.y = -countDown.textHeight - 20;
			
			cont.x = 0;
			cont.y = -20;
			addChild(cont);
			
			doCountDown();
			interval = setInterval(doCountDown, 1000);
		}
		
		private var interval:int = 0;
		private function doCountDown():void {
			if (counter == 0) {
				clearInterval(interval);
				removeChild(cont);
				boom();
				return;
			}
			
			cont.scaleX = cont.scaleY = 1;
			TweenLite.to(cont, 1, { scaleX:2, scaleY:2 } );
			
			counter--;
			countDown.text = String(counter);
		}
		
		private var lastObject:*;
		override public function calcState(node:AStarNodeVO):int
		{
			if (lastObject) lastObject.touch = false;
			Cursor.accelerator = false;
			var i:int;
			var j:int;
			if (info.count == 0) {
				for (i = 0; i < cells; i++) {
					for (j = 0; j < rows; j++) {
						node = App.map._aStarNodes[coords.x + i][coords.z + j];
						if (App.user.worldID == 2099 || App.user.worldID == 2195) {
							if (node.p != 0 || node.open == false || node.closed == true)
							{							
								return OCCUPIED;
							}else {
								return EMPTY;
							}
						}
						if (node.object && (node.object is Resource)) {
							lastObject = node.object;
							if (sid == 1556) {
								if ([1555,1558].indexOf(int(node.object.sid)) != -1) {
									Cursor.accelerator = true;
									lastObject.touch = true;
									return EMPTY;
								}else {
									lastObject = null;
									return OCCUPIED;
								}
							}
							if ((lastObject as Resource).info.hasOwnProperty('require')) {
								var normalMaterials:Array = [];
								for (var rid:* in lastObject.info.require) {
									// Если не системный
									if (App.data.storage.hasOwnProperty(rid) && App.data.storage[rid].mtype != 3) {
										normalMaterials.push(rid);
									}
								}
								if (normalMaterials.length > 0) {
									lastObject = null;
									return OCCUPIED;
								}
							}
							Cursor.accelerator = true;
							lastObject.touch = true;
							return EMPTY;
						}
					}
				}
				
				return OCCUPIED;
			}else {
				for (i = 0; i < cells; i++) {
					for (j = 0; j < rows; j++) {
						node = App.map._aStarNodes[coords.x + i][coords.z + j];
						if (node.p != 0 || node.open == false || node.closed == true)
						{							
							return OCCUPIED;
						}
						if (node.object && (node.object is Resource))
								return OCCUPIED;
					}
				}
			}
				
				return EMPTY;
		}
		
		override protected function onBuyAction(error:int, data:Object, params:Object):void {
			super.onBuyAction(error, data, params);
			
			if (lastObject) {
				lastObject.touch = false;
				boom();
			}
		}
		
		override protected function onStockAction(error:int, data:Object, params:Object):void {
			super.onStockAction(error, data, params);
			
			if (lastObject) {
				lastObject.touch = false;
				boom();
			}
		}
		
		public function showIcon():void
		{			
			if (App.user.mode == User.OWNER)
			{
				drawIcon(UnitIcon.REWARD, 852, 1, {glow: true});
			}
		}
	}
}	


import flash.display.Bitmap;
import flash.display.Sprite;
import flash.events.Event;

internal class Explode extends Sprite
{
	private var textures:Object = null;
	private var _parent:*;
	
	public function Explode(textures:Object) 
	{
		this.textures = textures;
		frame = 0;
		addAnimation();
		startAnimation();
		App.map.mTreasure.addChild(this);
	}
	
	private var frameLength:int = 0;
	private var framesType:String = 'explode';
	private var bitmap:Bitmap;
	
	public function addAnimation():void
	{
		frameLength = textures.animation.animations[framesType].chain.length;
		bitmap = new Bitmap();
		addChild(bitmap);
	}
	
	public function startAnimation(random:Boolean = false):void
	{
		frameLength = textures.animation.animations[framesType].chain.length;
		
		if (random) {
			frame = int(Math.random() * frameLength);
		}
		
		App.self.setOnEnterFrame(animate);
		animated = true;
	}
	
	public var animated:Boolean = false;
	
	public function stopAnimation():void
	{
		animated = false;
		App.self.setOffEnterFrame(animate);
	}
	
	public var frame:int = 0;
	public function animate(e:Event = null):void
	{
		var cadr:uint 			= textures.animation.animations[framesType].chain[frame];
		var frameObject:Object 	= textures.animation.animations[framesType].frames[cadr];
				
		bitmap.bitmapData = frameObject.bmd;
		bitmap.x = frameObject.ox;
		bitmap.y = frameObject.oy;
		bitmap.smoothing = true;
		
		frame ++;
		if (frame >= frameLength)
			dispose();
	}
	
	public function dispose():void {
		stopAnimation();
		App.map.mTreasure.removeChild(this);
	}
}