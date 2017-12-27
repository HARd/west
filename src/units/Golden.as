package units 
{
	import api.ExternalApi;
	import com.greensock.easing.Linear;
	import com.greensock.TweenLite;
	import core.Load;
	import core.Numbers;
	import core.Post;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import ui.Cursor;
	import ui.Hints;
	import wins.PurchaseWindow;
	import wins.SimpleWindow;
	import wins.SpeedWindow;
	import wins.StockWindow;
	public class Golden extends Tribute
	{
		public var shadow:Bitmap,
				   position:Object = null;
				   
		public var happy:int = 0;
		public var capacity:int;
		
		private var dX:Number = 0,
					dY:Number = 0,
					amplitude:Number = 40,
					altitude:uint = 400,
					viewportX:int,
					viewportY:int,
					start:Object,
					finish:Object,
					firstPos:Object,
					secondPos:Object,
					thirdPos:Object,
					fourthPos:Object,
					vittes:Number,
					t:Number = 0,
					live:Boolean = false,
					mouseOverBoss:Boolean = false,
					clickCounter:int = 0;
					
		private var base:Unit;
					
		private var poss:Object = {
			1: {
				x:1000,
				y:300
			},
			2: {
				x:1100,
				y:1100
			},
			3: {
				x:900,
				y:2200
			},
			4: {
				x:1200,
				y:2900
			},
			5: {
				x:2000,
				y:3200
			},
			6: {
				x:2800,
				y:3500
			},
			7: {
				x:4000,
				y:3500
			},
			8: {
				x:4800,
				y:3300
			},
			9: {
				x:6200,
				y:3000
			},
			10: {
				x:6500,
				y:2200
			},
			11: {
				x:6700,
				y:1400
			},
			12: {
				x:5000,
				y:400
			},
			13: {
				x:4200,
				y:390
			},
			14: {
				x:3600,
				y:370
			},
			15: {
				x:2800,
				y:400
			},
			16: {
				x:2000,
				y:410
			},
			17: {
				x:1000,
				y:300
			}
		}
					
		public function Golden(object:Object) 
		{
			crafted = object.crafted || 0;
			object['started'] = crafted - App.data.storage[object.sid].time;
			capacity = object.capacity || 0;
			
			super(object);
			
			crafting = true;
			totalLevels = level;
			stockable = true;
			transable 	= false;
			
			currentPath = poss;
			path_L = 17;
				
			if (formed && textures && crafted > App.time)
			{
				beginAnimation();
			}
			if (App.user.mode == User.GUEST) {
				App.self.setOffTimer(work);
				//flag = false;
				touchable = true;
				clickable = true;
			}
			
			if (info.hasOwnProperty('capacity') && info.capacity != 0 && info.capacity != '') {
				stockable = false;
			}
			
			tip = function():Object {
				if (App.user.mode == User.OWNER) {
					var subText:String = Locale.__e('flash:1414400030281', [info.capacity - capacity]);
					if (!info.capacity || info.capacity == 0)
						subText = '';
						
					var normalMaterials:Array = [];
					if (info.hasOwnProperty('capacity') && info.capacity != 0 && info.capacity != '' && capacity == info.capacity) {
						return {
							title:info.title,
							text:info.description + '\n' + subText
						};
					}
					if (tribute || hasProduct) {
						normalMaterials = [];
						for (var rid:* in info.require) {
							if (App.data.storage.hasOwnProperty(rid) && App.data.storage[rid].mtype != 3) {
								normalMaterials.push(rid);
							}
						}
						
						if (App.user.mode == User.GUEST) {
							rid = 6;
							normalMaterials = [rid];
						}
						
						if (normalMaterials.length > 0) {
							var bitmap:Bitmap = new Bitmap(new BitmapData(50,50,true,0));
							Load.loading(Config.getIcon(App.data.storage[rid].type, App.data.storage[rid].preview), function(data:Bitmap):void {
								bitmap.bitmapData.draw(data, new Matrix(0.5, 0, 0, 0.5));
							});
							
							return {
								title:info.title,
								text:Locale.__e("flash:1382952379966") + '\n',
								desc:Locale.__e('flash:1383042563368'),
								icon:bitmap,
								iconScale:0.6,
								count:(App.user.mode == User.GUEST) ? 1 : info.require[rid]
							};
						}
						
						return {
							title:info.title,
							text:Locale.__e("flash:1382952379966") + '\n' + subText
						};
					}
					
					if (info.hasOwnProperty('require')) {
						normalMaterials = [];
						for (var reqid:* in info.require) {
							if (App.data.storage.hasOwnProperty(reqid) && App.data.storage[reqid].mtype != 3) {
								normalMaterials.push(reqid);
							}
						}
						
						if (App.user.mode == User.GUEST) {
							reqid = 6;
							normalMaterials = [reqid];
						}
						
						if (normalMaterials.length > 0) {
							var bmp:Bitmap = new Bitmap(new BitmapData(50,50,true,0));
							Load.loading(Config.getIcon(App.data.storage[reqid].type, App.data.storage[reqid].preview), function(data:Bitmap):void {
								bmp.bitmapData.draw(data, new Matrix(0.5, 0, 0, 0.5));
							});
							
							return {
								title:info.title,
								text:sid == 360 ? Locale.__e("flash:1430991777391")  + '\n' + TimeConverter.timeToStr(crafted - App.time)  + '\n' + subText : Locale.__e("flash:1382952379839", [TimeConverter.timeToStr(crafted - App.time)]) + '\n' + subText,
								desc:Locale.__e('flash:1383042563368'),
								icon:bmp,
								iconScale:0.6,
								count:(App.user.mode == User.GUEST) ? 1 : info.require[reqid],
								timer:true
							};
						}
					}
					if (tribute || hasProduct){
						return {
							title:info.title,
							text:Locale.__e("flash:1382952379966")  + '\n' + subText
						};
					}
					
					if (level == totalLevels)
					{
						return {
							title:info.title,
							text:Locale.__e("flash:1382952379839", [TimeConverter.timeToStr(crafted - App.time)])  + '\n' + subText,
							timer:true
						};
					}
					
					return {
						title:info.title,
						text:Locale.__e("flash:1382952379967")  + '\n' + subText
					};
				}
				
				return {
					title:info.title,
					text:Locale.__e('flash:1382952379966')  + '\n' + subText
				};
			}	
			
			if (isBaloon) {
				var settings:Object = { sid:784, callback:click, getTip:getTip };
				base = Unit.add(settings);
				base.placing(this.coords.x, 0, this.coords.z);
				
				base.visible = false;
			}
			
			for (var sID:String in App.data.storage) {
				if (App.data.storage[sID].type == 'Happy' && App.data.storage[sID].htype == 1) {
					if (App.data.storage[sID].out == this.sid) {
						happy = int(sID);
						break;
					}
				}
			}
		}
		
		private function getTip():Object {
			if (tribute || hasProduct){
					return {
						title:info.title,
						text:Locale.__e("flash:1382952379966")
					};
				}
				
				if (level == totalLevels)
				{
					return {
						title:info.title,
						text:Locale.__e("flash:1382952379839", [TimeConverter.timeToStr(crafted - App.time)]),
						timer:true
					};
				}
				
				return {
						title:info.title,
						text:Locale.__e("flash:1382952379967")
					};
		}
		
		override protected function onBuyAction(error:int, data:Object, params:Object):void 
		{
			if (error) {
				Errors.show(error, data);
				return;
			}
			
			super.onBuyAction(error, data, params);
			
			open = true;
			
			crafted = App.time + info.time;
			started = App.time;
			
			beginCraft(0, crafted);
			beginAnimation();
			
			if (info.hasOwnProperty('capacity') && info.capacity != 0 && info.capacity != '') {
				capacity = 0;
			}
		}
		
		override public function beginCraft(fID:uint, crafted:uint):void
		{
			this.fID = fID;
			this.crafted = crafted;
			hasProduct = false;
			crafting = true;
			
			App.self.setOnTimer(work);
		}
		
		private var wasClick:Boolean = false;
		override public function click():Boolean {
			if (wasClick) return false;
			//trace(this.mouseX, this.mouseY);
			if (App.user.mode == User.GUEST) {
				guestClick();
				return true;
			}
			
			if (info.hasOwnProperty('capacity') && info.capacity != 0 && info.capacity != '') {
				if (capacity == info.capacity) {
					new SimpleWindow( {
						popup:true,
						dialog:true,
						confirmText:Locale.__e('flash:1475653985832'),
						title:info.title,
						text:Locale.__e('flash:1475653855173', [info.title, String(info.capacity)]),
						confirm:reloadAction,
						moneyButton:true,
						moneyCount:info.reloadPrice[Stock.FANT]
					}).show();
					return true;
				}
			}
			
			Cursor.accelerator = false;
			if (StockWindow.accelMaterial != 0 && crafted > 0 && crafted > App.time) {
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
			
			if (Mhelper.waitForTarget && !lock) {
				Mhelper.addTarget(this);
				state = TOCHED;
				lock = true;
				return true;
			}
			
			//if (!super.click() || this.id == 0) return false;
			
			if (sid != 2314 || sid != 2370 || sid != 2620 || sid != 2310) if (!isReadyToWork()) return true;
			if (isProduct()) return true;
			
			//openProductionWindow();
			return true;
		}
		
		//ускорялка для зданий за материалы
		override public function onBoostMaterialEvent(count:int = 0, material:int = 0):void {
			var that:* = this;
			if (!App.user.stock.take(Stock.FANT, count)) return;
				App.user.stock.take(material, 1);
				
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
					
					crafted = data.crafted;
					
					if (crafted <= App.time) {
						App.self.setOffTimer(work);
						onProductionComplete();
						
						if (isBaloon) {
							flyToHome();
						} else {
							stopAnimation();
						}
					}
					
					cantClick = false;
					
					SoundsManager.instance.playSFX('bonusBoost');
				});
		}
		
		override public function get tribute():Boolean {
			if (level >= totalLevels && hasProduct && (crafted == 0 || (crafted > 0 && crafted <= App.time)))
				return true;
			
			return false;
		}
		
		override public function onProductionComplete():void
		{
			hasProduct = true;
			crafting = false;
			crafted = 0;
			showIcon();
			
			if (!isBaloon) {
				finishAnimation();
			}
		}
		
		override public function isProduct(value:int = 0):Boolean
		{
			if (hasProduct)
			{
				if (info.hasOwnProperty('require')) {
					var cnt:int = 0;
					for (var sID:* in info.require) {
						cnt = info.require[sID];
						break;
					}
					if (!sID || sID == 0) return false;
					var priceRequire:Object = info.require;
					for (var s:* in priceRequire) {
						break;
					}
					
					if (!App.user.stock.takeAll(priceRequire))	{
						var content:Object = PurchaseWindow.createContent("Energy", { view:App.data.storage[s].view } );
						new PurchaseWindow( {
							width:595,
							itemsOnPage:Numbers.countProps(content),
							content:content,
							title:Locale.__e("flash:1382952379751"),
							fontBorderColor:0xd49848,
							shadowColor:0x553c2f,
							shadowSize:4,
							description:Locale.__e("flash:1382952379757"),
							popup: true,
							callback:function(sID:int):void {
								var object:* = App.data.storage[sID];
								App.user.stock.add(sID, object);
							}
						}).show();
						return false;
					}
					
					Hints.minus(sID, cnt, new Point(this.x * App.map.scaleX + App.map.x, this.y * App.map.scaleY + App.map.y), true);
				}
				
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
			if (info.skip == 0 || info.skip == '' || !info.hasOwnProperty('skip')) return true;
			if (crafted > App.time) {
				if (happy != 0 ) {
					new SpeedWindow( {
						title:info.title,
						priceSpeed:info.skip/*Math.ceil((crafted - App.time) / 3600)*/,
						target:this,
						info:info,
						finishTime:crafted,
						totalTime:App.data.storage[sid].time,
						doBoost:onBoostEvent,
						btmdIconType:App.data.storage[sid].type,
						btmdIcon:App.data.storage[sid].preview,
						picture:Config.getImage('paintings',App.data.storage[happy].image, 'jpg')
					}).show();
					return false;
				} else {
					new SpeedWindow( {
						title:info.title,
						priceSpeed:info.skip/*Math.ceil((crafted - App.time) / 3600)*/,
						target:this,
						info:info,
						finishTime:crafted,
						totalTime:App.data.storage[sid].time,
						doBoost:onBoostEvent,
						btmdIconType:App.data.storage[sid].type,
						btmdIcon:App.data.storage[sid].preview
					}).show();
					return false;	
				}
				
			}	
			return true;
		}
		
		public override function storageEvent(value:int = 0):void
		{
			if (App.user.mode == User.OWNER) {
				wasClick = true;
				Post.send({
					ctr:this.type,
					act:'storage',
					uID:App.user.id,
					id:this.id,
					wID:App.user.worldID,
					sID:this.sid
				}, onStorageEvent);
			}
		}
		
		public override function onStorageEvent(error:int, data:Object, params:Object):void {
			wasClick = false;
			if (error)
			{
				Errors.show(error, data);
				if(params && params.hasOwnProperty('guest')){
					App.user.friends.addGuestEnergy(App.owner.id);
				}
				return;
			}
			
			ordered = false;
			
			if(data.hasOwnProperty('started')){
				crafted = data.started;
				started = crafted - info.time;
				showIcon();
				App.self.setOnTimer(work);
				forceClear = true;
				addAnimation();
				beginAnimation();
				checkAndDrawFirstFrame();
			}
			
			Treasures.bonus(data.bonus, new Point(this.x, this.y));
			SoundsManager.instance.playSFX('bonus');
			
			if (params != null) {
				if (params['guest'] != undefined) {
					App.user.friends.giveGuestBonus(App.owner.id);
				}
			}
			
			hasProduct = false;
			
			if (info.hasOwnProperty('capacity') && info.capacity != 0 && info.capacity != '') {
				capacity++;
			}
			
			if (isBaloon) flyToStartPosition();
		}
		
		override public function work():void {
			if (isBaloon){
				if (App.time == crafted - 20 && isBaloon) {
					flyToHome();
				}
				if (App.time >= crafted) {
					App.self.setOffTimer(work);
					if (!boosted) onProductionComplete();
				}
				return;
			}
			if (App.time >= crafted) {
				App.self.setOffTimer(work);
				onProductionComplete();
			}
		}
		
		private var boosted:Boolean = false;
		override public function onBoostEvent(count:int = 0):void {
			boosted = true;
			if (App.user.stock.take(Stock.FANT, count)) {
				
				crafted = App.time;
				started = crafted - info.time;
				//showIcon();
				
				var that:Tribute = this;
				
				if (isBaloon) {
					hasProduct = true;
					crafting = false;
					crafted = 0;
				}else {
					onProductionComplete();
				}
				
				Post.send({
					ctr:this.type,
					act:'boost',
					uID:App.user.id,
					id:this.id,
					wID:App.user.worldID,
					sID:this.sid
				}, function(error:*, data:*, params:*):void {
					
					if (!error && data) {
						crafted = data.crafted;
					}
					
					if (isBaloon) {
						flyToHome();
					} else {
						stopAnimation();
					}
					
				});	
			}
		}
		
		override public function build():void {
			hasBuilded = true;
			App.self.setOffTimer(build);
		}
		
		override public function putAction():void {
			if (!stockable) {
				return;
			}
			
			uninstall();
			App.user.stock.add(sid, 1);
			
			Post.send( {
				ctr:this.type,
				act:'put',
				uID:App.user.id,
				wID:App.user.worldID,
				sID:this.sid,
				id:this.id
			}, function(error:int, data:Object, params:Object):void {
					
			});
		}
		
		override protected function onStockAction(error:int, data:Object, params:Object):void {
			if (error) {
				Errors.show(error, data);
				return;
			}
			this.id = data.id;
			started = App.time;
			crafted = App.time + info.time;
			
			//started = App.time - info.time;
			//crafted = App.time;
			
			hasProduct = false;
			open = true;
			
			beginCraft(0, crafted);
			
			initAnimation();
			beginAnimation();
			
			if (isBaloon) flyToStartPosition();
		}
		
		public function reloadAction():void {
			if (!App.user.stock.takeAll(info.reloadPrice)) return;
			
			Post.send( {
				ctr:this.type,
				act:'reload',
				uID:App.user.id,
				wID:App.user.worldID,
				sID:this.sid,
				id:this.id
			}, function(error:int, data:Object, params:Object):void {
				if (error) {
					Errors.show(error, data);
					return;
				}
				
				capacity = 0;
			});
		}
		
		override public function get bmp():Bitmap {
			if (bitmap.bitmapData && bitmap.bitmapData.getPixel(bitmap.mouseX, bitmap.mouseY) != 0)
				return bitmap;
			if (animationBitmap && animationBitmap.bitmapData && animationBitmap.bitmapData.getPixel(animationBitmap.mouseX, animationBitmap.mouseY) != 0)
				return animationBitmap;
				
			return bitmap;
		}
		
		override public function set state(state:uint):void {
			if (_state == state) return;
			var elm:* = this;
			
			if (App.user.mode != User.OWNER)
				elm = this.getChildAt(0);
				
			switch(state) {
				case OCCUPIED: elm.filters = [new GlowFilter(0xFF0000,1, 6,6,7)]; break;
				case EMPTY: elm.filters = [new GlowFilter(0x00FF00,1, 6,6,7)]; break;
				case TOCHED: elm.filters = [new GlowFilter(0xFFFF00,1, 6,6,7)]; break;
				case HIGHLIGHTED: elm.filters = [new GlowFilter(0x88ffed,0.6, 6,6,7)]; break;
				case IDENTIFIED: elm.filters = [new GlowFilter(0x88ffed,1, 8,8,10)]; break;
				case DEFAULT: elm.filters = []; break;
			}
			_state = state;
		}
		
		override public function load():void {
			var curLevel:int = 1;
			
			Load.loading(Config.getSwf(type, info.view), onLoad);
		}
		
		private var unit:Unit;
		public var decorCoords:Object;
		override public function onLoad(data:*):void 
		{
			super.onLoad(data);
			
			initAnimation();
			beginAnimation();
			if(framesTypes.length > 0 && Numbers.countProps(textures.animation.animations) > 0)
				checkAndDrawFirstFrame();
			
			startPos.x = this.x;
			startPos.y = this.y;
			
			if (App.data.options.hasOwnProperty('Aerostats')) {
				var baloons:Object = JSON.parse(App.data.options.Aerostats);
				if (baloons.hasOwnProperty(sid))	isBaloon = true;
			}
			if (isBaloon && App.time < crafted) {
				setMoveParams();
				startFly();
				if (base) base.visible = true;
				else {
					var settings:Object = { sid:784, callback:click, getTip:getTip };
					base = Unit.add(settings);
					base.placing(this.coords.x, 0, this.coords.z);
				}
			}
		}
		
		private var indent:int = 0;
		public function setMoveParams():void {
			viewportX = Map.mapWidth - (Map.mapWidth + App.map.x);
			viewportY = Map.mapHeight - (Map.mapHeight + App.map.y);
			
			if(position == null) {
				x = viewportX + Math.random() * App.self.stage.stageWidth;
				y = viewportY + Math.random() * App.self.stage.stageHeight;
			} else {
				x = position.x;
				y = position.y;
			}
			
			currentPath = poss;
			startPos.x = this.x;
			startPos.y = this.y;
		}
		
		private var startPos:Object = {x:0, y:0 };
		public function flyToStartPosition():void {
			var that:* = this;
			/*startPos.x = this.x;
			startPos.y = this.y;*/
			
			animationBitmap.visible = true;
			bitmap.visible = false;
			
			base.visible = true;
			
			ay = textures.animation.ay;
			TweenLite.to(this, 20, { alpha:0, x:poss[1].x, y:poss[1].y, ease: Linear.easeIn, onComplete:function():void { 
				TweenLite.to(that, 1, { alpha:1 } );
				startFly(); }} );
		}
		
		public function flyToHome():void {
			App.self.setOffEnterFrame(flying);
			TweenLite.to(this, 20, { alpha:1, x:startPos.x, y:startPos.y, ease: Linear.easeIn, onUpdate:function():void {
				if (ay > textures.animation.ay) ay--;
				if (ay < textures.animation.ay) ay++;
				
				sort(App.map.mSort.numChildren - 1);
				},onComplete:function():void { 
					stopAnimation();
					animationBitmap.visible = false;
					bitmap.visible = true;
					
					base.visible = false;
					
					boosted = false;
					showIcon();
			} });
		}
		
		private var currentPath:Object;
		private function startFly(pos:int = 1):void {
			animationBitmap.visible = true;
			bitmap.visible = false;
			
			live = true; 
			ay -= altitude;
			
			amplitude += int(Math.random() * 40 - 20);

			start = currentPath[pos];
			if (pos == path_L) {
				finish = currentPath[2];
			}else {
				finish = currentPath[pos+1];
			}
			_altitude = altitude;
			vittes = 0.0010;
			
			App.self.setOnEnterFrame(flying);
		}
		
		private var path_L:int = 17
		
		private var _altitude:int = 0;
		private var dAlt:uint = 2;
		private var startTime:int;
		private var counter:int;
		private var positions:Array;
		private var count:int = 1;
		private var _fps:uint = 31;
		private var die:Boolean = false;
		private function flying(e:Event = null):void
		{
			t += vittes * (32 / (_fps));
			
			if (t >= 1 && live)
			{
				_fps = (App.self.fps)?App.self.fps:31;
				t = 0;
				count++;
				if (count > path_L) {
					count = 1;
				}
				App.self.setOffEnterFrame(flying);
				startFly(count);
			}
			
			var nextX:Number = int(start.x + (finish.x - start.x) * t);
			var nextY:Number = int(start.y + (finish.y - start.y) * t);
				
			x = nextX;
			y = nextY;
			
			if (_altitude < altitude)
				_altitude += dAlt;
			
			if (die) {
				_altitude = 0;
				amplitude = 0;
			}
			ay = (amplitude * Math.sin(0.01 * x)) - _altitude;
		}
		
		override public function addAnimation():void {
			if (!textures || !textures.hasOwnProperty('animation')) return;
			ax = textures.animation.ax;
			ay = textures.animation.ay;
			
			clearAnimation();
			
			var arrSorted:Array = [];
			for each(var nm:String in framesTypes) {
				arrSorted.push(nm); 
			}
			arrSorted.sort();
			
			for (var i:int = 0; i < arrSorted.length; i++ ) {
				var name:String = arrSorted[i];
				multipleAnime[name] = { bitmap:new Bitmap(), cadr: -1 };
				//animationContainer.addChild(multipleAnime[name].bitmap);
				bitmapContainer.addChild(multipleAnime[name].bitmap);
				
				if (textures.animation.animations[name]['unvisible'] != undefined && textures.animation.animations[name]['unvisible'] == true) {
					multipleAnime[name].bitmap.visible = false;
				}
				multipleAnime[name]['length'] = textures.animation.animations[name].chain.length;
				multipleAnime[name]['frame'] = 0;
			}
			for each(var multipleObject:Object in multipleAnime) {
				animationBitmap = multipleObject.bitmap;
				return;
			}
		}
		
		public function deleteParent():void {
			this.removable = true;
			this.takeable = false;
			this.onApplyRemove();
			unit.placing(decorCoords.x, 0, decorCoords.z);
			App.map.sorted.push(unit);
			App.map.sorting();
		}
		
		override public function uninstall():void {
			if (isBaloon) App.self.setOffEnterFrame(flying);
			super.uninstall();
		}
		
	}
}