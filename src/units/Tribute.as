package units 
{
	import astar.AStarNodeVO;
	import core.Load;
	import core.Numbers;
	import core.Post;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.geom.Point;
	import ui.Cursor;
	import ui.Hints;
	import ui.SystemPanel;
	import ui.UnitIcon;
	import wins.BuildingConstructWindow;
	import wins.ConstructWindow;
	import wins.InformWindow;
	import wins.SimpleWindow;
	import wins.StockWindow;
	import wins.TributeWindow;
	import wins.SpeedWindow;
	import wins.Window;
	
	public class Tribute extends Building
	{
		public var started:int = 0;
		public var icount:int = 0;
		
		public function Tribute(object:Object) {
			started = object.crafted || 0;
			icount = object.icount || 1;
			
			super(object);
			
			if (sid == 1580 || sid == 1624 || sid == 1571 || sid == 2418) {
				removable = false;
				moveable = false;
				rotateable = false;
			}
			
			touchableInGuest = false;
			
			if (level >= totalLevels && !componentable && [1580,1624,1094,1761].indexOf(int(sid)) == -1) {
				stockable = true;
			}
			
			if (object.fromStock && [1580,1624,1094].indexOf(int(sid)) == -1)
				moveable = true;
				
			if ([1961, 1952, 2418].indexOf(int(sid)) != -1) {
				stockable = false;
			}
			
			if ([1353,1354,1355,1356,1357,815,817,816].indexOf(int(sid)) != -1) {
				removable = false;
			}
			
			init();
		}
		
		protected var _lock:Boolean = false;
		public function set lock (item:Boolean):void {
			_lock = item;
			if (item)
				removable = false;
			else
				removable = true;
		}
		public function get lock():Boolean {
			return _lock;
		}
		
		override public function onRemoveFromStage(e:Event):void {
			//App.self.setOffTimer(left);
			App.self.setOffTimer(work);
			super.onRemoveFromStage(e);
		}
		
		private var logo:Bitmap;
		public function init():void {
			
			if (level == totalLevels){
				touchableInGuest = true;
			}
			
			Load.loading(Config.getIcon('Material', App.data.storage[Stock.COINS].view), onOutLoad);
			//Если мы дома
			if (App.user.mode == User.OWNER) {
				if (started != 0) {
					App.self.setOnTimer(work);
				}
			}
			
			tip = function():Object {
				
				if (tribute){
					return {
						title:info.title,
						text:Locale.__e("flash:1382952379966")
					};
				}
				
				if (level == totalLevels)
				{
					return {
						title:info.title,
						text:Locale.__e("flash:1382952379839",[TimeConverter.timeToStr(started /*+ info.time*/ - App.time)]),
						timer:true
					};
				}
				
				return {
					title:info.title,
					text:Locale.__e("flash:1382952379967")
				};
			}
			
			if (sid == 402)
			{
				logo = new Bitmap(Window.texture('bankLogo'));
				logo.x = -64;
				logo.y = -125;
				addChild(logo);
				
				if (level < totalLevels) {
					logo.visible = false;
				}
			}
			
			showIcon();
		}
		
		override public function click():Boolean {
			var node:AStarNodeVO;
			for (var i:uint = 0; i < cells; i++) {
				for (var j:uint = 0; j < rows; j++) {
					node = App.map._aStarNodes[coords.x + i][coords.z + j];
					if (node.freezers.length != 0) {
						//if (sid == 2106) {
							new SimpleWindow( {
								popup:true,
								title:Locale.__e('flash:1382952380254'),
								text:Locale.__e('flash:1466608899476')
							}).show();
						//}
						return false;
					}
				}
			}
			if (cantClick)
				return false;
				
			if (sid == 1571) {
				if(App.user.mode == User.OWNER)
					swap();
				else guestClick();
				return true;
			}
			
			if ((sid == 1580 || sid == 1624) && level < totalLevels) {
				var station:Array = Map.findUnits([1596]);
				if (station.length != 0) {
					station[0].click();
				}
				return true;
			}
			
			if (sid == 2418) {
				var build:Array = [];
				//build.push(Map.findUnit(2420, 1));
				//build.push(Map.findUnit(2421, 2));
				build.push(Map.findUnit(2419, 3));
				//build.push(Map.findUnit(2415, 4));
				for each (var b:* in build) {
					if (b.level < b.totalLevels) {
						new SimpleWindow( {
							popup:true,
							title:Locale.__e('flash:1382952380254'),
							text:Locale.__e('flash:1470229113126'),
							confirm:function():void {
								var building:* = Map.findUnit(b.sid, b.id);
								if (building) {
									App.map.focusedOn(building, true);
								}
							}
						}).show();
						return false;
					}
				}
			}
			
			if (!clickable || id == 0 || (App.user.mode == User.GUEST && touchableInGuest == false)) return false;
			
			Cursor.accelerator = false;
			if (StockWindow.accelMaterial != 0 && started > 0 && started > App.time) {
				onBoostMaterialEvent(0, StockWindow.accelMaterial);
				if (StockWindow.accelUnits) {
					for each (var unit:* in StockWindow.accelUnits) {
						unit.hideGlowing();
					}
					StockWindow.accelUnits = [];
					StockWindow.accelMaterial = 0;
				}
				return true;
			}
			
			App.tips.hide();
			
			if (level < totalLevels) {
				
				if (App.user.mode == User.OWNER)
				{
					// Открываем окно постройки
					/*new BuildingConstructWindow({
						title:info.title,
						level:Number(level),
						totalLevels:Number(totalLevels),
						devels:info.devel[level+1],
						bonus:info.bonus,
						target:this,
						upgradeCallback:upgradeEvent
					}).show();*/
					if (!componentBuildable)
						return true;
							
					new ConstructWindow( {
						title			:info.title,
						upgTime			:info.devel.req[level + 1].t,
						request			:info.devel.obj[level + 1],
						target			:this,
						onUpgrade		:upgradeEvent,
						reward          :info.devel.rew[level + 1],
						hasDescription	:true
					}).show();
				}
			}
			else
			{
				if (tribute)
				{
					var price:Object = getPrice();
					
					if (!App.user.stock.checkAll(price))	return true;  // было false
					
					// Отправляем персонажа на сбор
					storageEvent();						
					ordered = false;
				}
				else if(App.user.mode == User.OWNER)
				{
					//Открываем окно ускорения работы
					/*new TributeWindow( {
						title:info.title,
						target:this,
						started:started,
						time:info.time,
						info:info
					}).show();*/
					if (!isReadyToWork()) return true;
				}
			}
			
			return true;
		}
		
		private function swap():void {
			var rotate:Boolean = this._rotate;
			uninstall();
			Post.send({
				'ctr':'tribute',
				'act':'swap',
				'uID':App.user.id,
				'wID':App.user.worldID,
				'sID':1571,
				'id':this.id,
				'tID':1596
			}, function(error:*, response:*, params:*):void {
				if (!error) {
					var newBuild:Building = new Building( { id:response.id, sid:1596, level:0, x:coords.x, z:coords.z, rotate:rotate } );
				}
			});
			return;	
		}
		
		//ускорялка для зданий за материалы
		override public function onBoostMaterialEvent(count:int = 0, material:int = 0):void {
			var that:* = this;
			if (!App.user.stock.take(Stock.FANT, count)) return;
				
				//App.self.setOffTimer(production);
				App.user.stock.take(material, 1);
				//crafted = App.time;
				//onProductionComplete();
				
				cantClick = true;
				
				Post.send({
					ctr:this.type,
					act:'boost',
					uID:App.user.id,
					id:this.id,
					wID:App.user.worldID,
					sID:this.sid,
					m:material
				}, function(error:*, data:*, params:*):void {
					
					if (error) {
						Errors.show(error, data);
						return;
					}
					
					started = data.crafted;
					
					if (started <= App.time) {
						App.self.setOffTimer(work);
						onProductionComplete();
					}
					
					cantClick = false;
					
					SoundsManager.instance.playSFX('bonusBoost');
				});
		}
		
		override public function isProduct(value:int = 0):Boolean
		{
			if (hasProduct)
			{
				
				var price:Object = getPrice();
						
				if (!App.user.stock.checkAll(price))	return true;  // было false
				
				// Отправляем персонажа на сбор
				storageEvent();
				
				/*App.user.addTarget( {
					target:this,
					near:true,
					callback:storageEvent,
					event:Personage.HARVEST,
					jobPosition: findJobPosition(),
					shortcut:true
				});*/
				
				ordered = false;
				
				return true; 
			}
			return false;
		}
		
		override public function isReadyToWork():Boolean
		{
			if (!tribute) {
				if (sid == 1624) return false;
				
				new SpeedWindow( {
					title:info.title,
					priceSpeed:info.speedup,
					target:this,
					info:info,
					finishTime:started/* + info.time*/,
					totalTime:App.data.storage[sid].time,
					doBoost:onBoostEvent,
					btmdIconType:App.data.storage[sid].type,
					btmdIcon:App.data.storage[sid].preview
				}).show();
				return false;	
				
			}	
			return true;
		}
		
		private function getPosition():Object {
			var Y:int = -1;
			if (coords.z + Y <= 0)
				Y = 0;
			
			return { x:int(info.area.w / 2), y: Y };
		}
		
		public function get tribute():Boolean {
			if (level >= totalLevels && started > 0 && started <= App.time)
				return true;
			
			return false;
		}
		
		override public function beginCraft(fID:uint, crafted:uint):void
		{
			this.fID = fID;
			this.crafted = crafted;
			hasProduct = false;
			crafting = true;
			
			forceClear = true;
			checkAndDrawFirstFrame();
				
			App.self.setOnTimer(work);
		}
		
		public function work():void
		{
			if (tribute) {
				App.self.setOffTimer(work);
				showIcon();
			}
		}
		
		override public function onBoostEvent(count:int = 0):void {
			
			if (App.user.stock.take(Stock.FANT, info.speedup)) {
				
				started = App.time - info.time;
				showIcon();
				
				var that:Tribute = this;
				
				Post.send({
					ctr:this.type,
					act:'boost',
					uID:App.user.id,
					id:this.id,
					wID:App.user.worldID,
					sID:this.sid
				}, function(error:*, data:*, params:*):void {
					
					if (!error && data) {
						started = data.crafted/* - info.time*/;
						App.ui.flashGlowing(that);
						
						open = true;
						showIcon();
					}
					
				});	
			}
		}
		
		public var guestDone:Boolean = false;
		public override function storageEvent(value:int = 0):void
		{
			if (App.user.mode == User.OWNER) {
				
				var price:Object = { }
				price[Stock.FANTASY] = 0;
					
				if (!App.user.stock.takeAll(price))	return;
				//Hints.minus(Stock.FANTASY, 1, new Point(this.x*App.map.scaleX + App.map.x, this.y*App.map.scaleY + App.map.y), true);
				
				Post.send({
					ctr:this.type,
					act:'storage',
					uID:App.user.id,
					id:this.id,
					wID:App.user.worldID,
					sID:this.sid
				}, onStorageEvent);
			}else {
				if (guestDone) return;
			
				if(App.user.addTarget({
					target:this,
					near:true,
					callback:onGuestClick,
					event:Personage.HARVEST,
					jobPosition:getContactPosition(),
					shortcut:true
				})) {
					ordered = true;
					clearIcon();
				}else {
					ordered = false;
				}
			}
		}
		
		override public function onGuestClick():void {
			if (App.user.friends.takeGuestEnergy(App.owner.id)) {
				guestDone = true;
				var that:* = this;
				Post.send( {
					ctr:'user',
					act:'guestkick',
					uID:App.user.id,
					sID:this.sid,
					fID:App.owner.id
				}, function(error:int, data:Object, params:Object):void {
					if (error) {
						Errors.show(error, data);
						return;
					}	
					if (data.hasOwnProperty("bonus")){
						spit(function():void{
							clearIcon();
							Treasures.bonus(data.bonus, new Point(that.x, that.y));
						}, bitmapContainer);
					}
					ordered = false;
					
					if (data.hasOwnProperty('energy')) {												//
						if(App.user.friends.data[App.owner.id].energy != data.energy){					//
							App.user.friends.data[App.owner.id].energy = data.energy;					//
							App.ui.leftPanel.update();													//test
						}																				//
					}																					//
					App.user.friends.giveGuestBonus(App.owner.id);										//
				});
			}else {
				showIcon();
				ordered = false;
				////Hints.text(Locale.__e('flash:1382952379907'), Hints.TEXT_RED,  new Point(App.map.scaleX*(x + width / 2) + App.map.x, y*App.map.scaleY + App.map.y));
				App.user.onStopEvent();
				return;					
			}
		}
		
		public function onHelperStorage(_started:uint):void {
			started = _started;
			App.self.setOnTimer(work);
		}
		
		public override function onStorageEvent(error:int, data:Object, params:Object):void {
			if (error)
			{
				Errors.show(error, data);
				if(params && params.hasOwnProperty('guest')){
					App.user.friends.addGuestEnergy(App.owner.id);
				}
				return;
			}
			
			started = data.crafted;
			App.self.setOnTimer(work);
			
			ordered = false;
			showIcon();
			
			Treasures.bonus(data.treasure, new Point(this.x, this.y));
			SoundsManager.instance.playSFX('bonus');
			
			if (params != null) {
				if (params['guest'] != undefined) {
					App.user.friends.giveGuestBonus(App.owner.id);
				}
			}
			
		}
		
		override public function upgradeEvent(params:Object, fast:int = 0):void {
			cantClick = true;
			super.upgradeEvent(params, fast);
		}
		
		override public function onUpgradeEvent(error:int, data:Object, params:Object):void {
			if (error){
				//Возвращаем как было
				for (var id:* in params) {
					App.user.stock.data[id] = params[id];
				}
				
				this.level--;
				updateLevel();
				return;
			}
			
			hasUpgraded = false;
			fromStock = false;
			upgradedTime = data.upgrade;
			
			App.self.setOnTimer(upgraded);
			
		}
		
		override protected function onStockAction(error:int, data:Object, params:Object):void {
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
			
			hasUpgraded = true;
			hasBuilded = true;
			fromStock = true;
			
			started = App.time + info.time;
		}
		
		override public function finishUpgrade():void
		{
			cantClick = false;
			
			super.finishUpgrade();
			if (level >= totalLevels) {
				started = App.time + info.time;
				
				if (sid == 1561) {
					new InformWindow( {
						text:Locale.__e('flash:1455114110086'),
						check:false
					}).show();
				}
			}
		}
		
		override public function set material(toogle:Boolean):void {
			if (countLabel == null) return;
			
			if (toogle) {
				countLabel.text = TimeConverter.timeToStr((started + info.time) - App.time);
				countLabel.x = (icon.width - countLabel.width) / 2;
			}
			//popupBalance.visible = toogle;
		}
		
		/*public function left():void {
			
			if((started + info.time) - App.time == 0){
				App.self.setOffTimer(left);
				material = false;
			}else {
				material = true;
			}
		}*/
		
		override public function remove(_callback:Function = null):void {
			if ([815, 816, 817, 835,1845,1868].indexOf(int(sid)) != -1) {
				var data:int = int(App.user.storageRead('building_' + sid, 0));
				data -= 1;
				App.user.storageStore('building_' + sid, data, true);
			}
			App.self.setOffTimer(work);
			super.remove(_callback);
		}
		
		override public function checkOnAnimationInit():void {			
			if (textures && textures['animation'] && level >= totalLevels - craftLevels) {
				
				initAnimation();
				
				//if (crafted > 0 || alwaysAnimated.indexOf(sid) != -1) {
				if (framesTypes.length > 0)	
					beginAnimation();
				//}else{
					//finishAnimation();
				//}
				
			}
		}
		
		override public function beginAnimation():void {
			if (textures && textures.animation && textures.animation.animations && Numbers.countProps(textures.animation.animations) > 0 && !animated)
			{
				startAnimation();
				forceClear = true;
				checkAndDrawFirstFrame();
			}
		}
		
		override public function flip():void {
			super.flip();
			
			if (sid == 402)
			{
				if (scaleX < 0)
					logo.visible = true;
				else
					logo.visible = false;
			}
			showIcon();
		}
		
		override public function draw(bitmapData:BitmapData, dx:int, dy:int):void {
			super.draw(bitmapData, dx, dy);
			
			if (sid == 402 && logo)
			{
				if (level < totalLevels) {
					logo.visible = false;
				} else {
					if (scaleX < 0) {
						logo.visible = true;
						return;
					}
					else {
						logo.visible = false;
						return;
					}
				}
			}
		}
		
		public var _name:String;
		override public function animate(e:Event = null, forceAnimate:Boolean = false):void 
		{
			if (!SystemPanel.animate && !(this is Lantern) && !forceAnimate) return;
			
			if(_name == null) _name = framesTypes[0];
			var name:String = _name;
			//for each(var name:String in framesTypes) {
				var frame:* 			= multipleAnime[name].frame;
				var cadr:uint 			= textures.animation.animations[name].chain[frame];
				if (multipleAnime[name].cadr != cadr) {
					multipleAnime[name].cadr = cadr;
					var frameObject:Object 	= textures.animation.animations[name].frames[cadr];
					
					multipleAnime[name].bitmap.bitmapData = frameObject.bmd;
					multipleAnime[name].bitmap.smoothing = true;
					multipleAnime[name].bitmap.x = frameObject.ox+ax;
					multipleAnime[name].bitmap.y = frameObject.oy + ay;
					multipleAnime[_name].bitmap.visible = true;
				}
				
				multipleAnime[name].frame++;
				if (multipleAnime[name].frame >= multipleAnime[name].length)
				{
					onLoop();
				}
			//}
		}
		
		public function onLoop():void {
			multipleAnime[_name].frame = 0;
			if (framesTypes.length > 1) setRest();
		}
		
		public function setRest():void {			
			var randomID:int = int(Math.random() * framesTypes.length);
			var randomRest:String = framesTypes[randomID];
			if (randomRest.indexOf('rest') == -1 && randomRest != 'stop_pause' && randomRest != 'anim') {
				setRest();
				return;
			}
			if (!_name) return;
			multipleAnime[_name].bitmap.visible = false;
			_name = randomRest;
			multipleAnime[_name].bitmap.visible = true;
		}
		
		override public function showIcon():void {
			if (!formed || !open) return;
			
			if (App.user.mode == User.GUEST) {
				clearIcon();
				return;
			}
			
			if (App.user.mode == User.OWNER) {
				if (level >= totalLevels && tribute) {
					if (sid == 402) {
						drawIcon(UnitIcon.REWARD, 3, 1, {
							glow:		true
						});
					} else if ( sid == 815 || sid == 816 || sid == 817) {
						drawIcon(UnitIcon.REWARD, Stock.ACTION, 1, {
							glow:		true
						});
					}else {
						drawIcon(UnitIcon.REWARD, 2, 1, {
							glow:		true
						});
					}
				}else if ((craftLevels == 0 && level < totalLevels) || (craftLevels > 0 && level < totalLevels - craftLevels + 1)) {
					drawIcon(UnitIcon.BUILD, null);
				}else {
					clearIcon();
				}
			}
		}
	}	
}