package units 
{
	import api.ExternalApi;
	import com.greensock.TweenLite;
	import core.Load;
	import core.Post;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.geom.Point;
	import ui.Cursor;
	import ui.Hints;
	import wins.PurchaseWindow;
	import wins.SimpleWindow;
	import wins.Window;
	/**
	 * ...
	 * @author 
	 */
	public class Fplant extends AUnit
	{
		public static var waitForTarget:Boolean = false;
		
		public var level:int = 0;
		public var canAddWorker:Boolean = false;
		
		public function Fplant(object:Object) 
		{
			
			started = object.started || 0;
			if (started > App.time) 
				producting = true;
			
			layer = Map.LAYER_SORT;
			if (App.data.storage[object.sid].dtype == 1)
				layer = Map.LAYER_LAND;
			
			object['hasLoader'] = false;
			super(object);
			
			touchableInGuest = false;
			//touchable = true;
			//multiple = true;
			//stockable = true;
			
			Load.loading(Config.getSwf(type, info.view), onLoad);
			
			if(!formed) addEventListener(AppEvent.AFTER_BUY, onAfterBuy);
			addEventListener(Event.REMOVED_FROM_STAGE, onRemoveFromStage);
			
			
			
			if (started > 0) {
				level = 1;
				App.self.setOnTimer(work);
			}
			
			tip = function():Object {
				if(started != 0){
					if (started > App.time) {
						return {
							title:info.title,
							text:Locale.__e('flash:1396606641768', [TimeConverter.timeToStr(started - App.time)]),
							timer:true
						}
					}else {
						return {
							title:info.title,
							text:Locale.__e('flash:1396606659545')
						}
					}
				}	
				
				return {
					title:info.title,
					text:info.description
				}
			}
			
			App.self.addEventListener(AppEvent.ON_CHANGE_STOCK, onChangeStock);
		}
		
		private function onChangeStock(e:AppEvent):void 
		{
			/*if (cloudAnimal && !hasProduct && !producting) {
				showIcon('require', feedEvent, AnimalCloud.MODE_NEED);
			}*/
		}
		
		override public function initAnimation():void {
			framesTypes = [];
			if (textures && textures.hasOwnProperty('animation')) {
				for (var frameType:String in textures.animation.animations) {
					framesTypes.push(frameType);
				}
				addAnimation();
				startAnimation(true);
			}
		}
		
		override public function take():void {
			/*if (info.dtype == 0) */super.take();
		}
		override public function free():void {
			/*if (info.dtype == 0)*/ super.free();
		}
		
		public function onAfterBuy(e:AppEvent):void
		{
			removeEventListener(AppEvent.AFTER_BUY, onAfterBuy);
			App.user.stock.add(Stock.EXP, info.experience);
			if(App.data.storage[sid].experience > 0)Hints.plus(Stock.EXP, App.data.storage[sid].experience, new Point(this.x * App.map.scaleX + App.map.x, this.y * App.map.scaleY + App.map.y), true);
		}
		
		override public function onLoad(data:*):void {
			textures = data;
			var levelData:Object = textures.sprites[0];
			draw(levelData.bmp, levelData.dx, levelData.dy);
			
			framesType = info.view;
			if (textures && textures.hasOwnProperty('animation')) 
				initAnimation();
				
			updateLevel();
		}
		
		public function updateLevel(checkRotate:Boolean = false):void 
		{
			if (textures == null) return;
			
			var levelData:Object;
			levelData = textures.sprites[this.level];
			
			
			if (levelData == null)
				levelData = textures.sprites[0];
			
			if (checkRotate && rotate == true) {
				flip();
			}
			
			//if (this.level != 0 && gloweble)
			//{
				var backBitmap:Bitmap = new Bitmap(bitmap.bitmapData);
				backBitmap.x = bitmap.x;
				backBitmap.y = bitmap.y;
				addChildAt(backBitmap, 0);
				
				bitmap.alpha = 0;
				
				//App.ui.flashGlowing(this, 0xFFF000)//0x6fefff);
				
				var time:Number = 0.1;
				
				if (level == 0)
					time = 0.1;
				
				TweenLite.to(bitmap, time, { alpha:1, onComplete:function():void {
					removeChild(backBitmap);
					backBitmap = null;
				}});
				//
				//gloweble = false;
			//}
			
			draw(levelData.bmp, levelData.dx, levelData.dy);
			
			//checkOnAnimationInit();
		}
		
		//override public function set touch(touch:Boolean):void {
			//if (Cursor.type == 'default') {
				//return;
			//}
			//super.touch = touch;
		//}
		
		public var lock:Boolean = false;
		public var hasProduct:Boolean = false;
		override public function click():Boolean {
			
			if (App.user.mode == User.GUEST) {
				return true;
			}
			
			if (lock) {
				// Не предусмотрена проверка причины блокировки. Возможно занят рабочим
				showMessage();
				return false;
			}
			
			if (producting) {
				return false;
			}
			
			if (hasProduct)
			{
				storageEvent();
				return true;
			}
			
			if (Gardener.waitForTarget && canAddWorker) {
				Gardener.addTarget(this);
				state = TOCHED;
				return true;
			}
			
			/*if (cloudAnimal)feedEvent();
			else showIcon('require', feedEvent, AnimalCloud.MODE_NEED);*/
			
			return true;
		}
		
		public var started:uint = 0;
		public var producting:Boolean = false;
		private function feedEvent(value:int = 0):void {
			
			if (!App.user.stock.takeAll(App.data.storage[sid].require)) {
				for (var req:* in App.data.storage[sid].require) {
					break;
				}
				var typeNeed:String = 'Water';
				
				for (var s:String in info.require) {
					typeNeed = App.data.storage[s].view;
					break;
				}
				
				new PurchaseWindow( {
					width:390,
					itemsOnPage:2,
					content:PurchaseWindow.createContent("Energy", { inguest:0, view:typeNeed} ),
					find:req,
					title:Locale.__e("flash:1406209151924"),
					description:Locale.__e("flash:1382952379757"),
					callback:function(sID:int):void {
						var object:* = App.data.storage[sID];
						App.user.stock.add(sID, object);
					}
				}).show();
				
				/*if (cloudAnimal) cloudAnimal.dispose();
				cloudAnimal = null;*/
				return;
			}
			for (var out:* in App.data.storage[sid].require) {
				break;
			}
			
			var point:Point = new Point(this.x*App.map.scaleX + App.map.x, this.y*App.map.scaleY + App.map.y);
			Hints.minus(out, App.data.storage[sid].require[out], point);
			
			//if (cloudAnimal) cloudAnimal.dispose();
			//cloudAnimal = null;
			
			//App.ui.flashGlowing(this, 0x83c42a);
			
			flyMaterial(out);
			
			producting = true;
			Post.send({
				ctr:this.type,
				act:'feed',
				uID:App.user.id,
				id:this.id,
				wID:App.user.worldID,
				sID:this.sid
			}, function(error:int, data:Object, params:Object):void {
				
				if (error) {
					Errors.show(error, data);
					return;
				}
				started = data.started;
				App.self.setOnTimer(work);
				
				//if (App.social == 'FB') {
					//ExternalApi._6epush([ "_event", { "event": "use", "item": "feed_" + App.data.storage[out].view} ]);
				//}
				
				level = 1;
				updateLevel();
			});		
		}
		
		public function work():void 
		{
			if (App.time >= started) {
				App.self.setOffTimer(work);
				hasProduct = true;
				//showIcon('outs', storageEvent, AnimalCloud.MODE_DONE);
				//if(cloudAnimal)cloudAnimal.doIconEff();
				producting = false;
				
				level = 2;
				updateLevel();
			}
		}
		
		private function storageEvent(value:int = 0):void {
			
			//if (cloudAnimal) cloudAnimal.dispose();
			//cloudAnimal = null;
			
			hasProduct = false;
			
			Post.send({
				ctr:this.type,
				act:'storage',
				uID:App.user.id,
				id:this.id,
				wID:App.user.worldID,
				sID:this.sid
			},onStorageEvent);
		}
		
		private function onStorageEvent(error:int, data:Object, params:Object):void 
		{
			if (error) {
				Errors.show(error, data);
				return;
			}
			
			started = 0;
			var outs:Object = Treasures.convert(info.outs)
			Treasures.bonus(outs, new Point(this.x, this.y));
			
			if (data.hasOwnProperty('bonus'))
				Treasures.bonus(data.bonus, new Point(this.x, this.y));
			
			if (App.social == 'FB') {
				var itmSid:int;
				for (var id:* in info.outs) {
					itmSid = id;
					break;
				}
				
				//ExternalApi._6epush([ "_event", { "event": "use", "item": "retrieve_" + App.data.storage[itmSid].view} ]);
			}
			
			level = 0;
			updateLevel();
		}
		
		public function onBoostEvent(count:int = 0):void {
			
			if (!App.user.stock.take(Stock.FANT, count)) return;
				
				var that:Fplant = this;
			
				producting = false;
				
				Post.send({
					ctr:this.type,
					act:'boost',
					uID:App.user.id,
					id:this.id,
					wID:App.user.worldID,
					sID:this.sid
				}, function(error:*, data:*, params:*):void {
					
					if (error) {
						Errors.show(error, data);
						return;
					}
					
					if (!error && data) {
						
						App.ui.flashGlowing(that);
						
						started = data.started;
						
						//if (cloudAnimal) cloudAnimal.dispose();
						//cloudAnimal = null;
						
					}
					SoundsManager.instance.playSFX('bonusBoost');
				});
		}
		
		/*private function showIcon(typeItem:String, callBack:Function, mode:int, btmDataName:String = 'productBacking2'):void 
		{
			if (App.user.mode == User.GUEST)
				return;
			
			if (cloudAnimal) {
				cloudAnimal.dispose();
				cloudAnimal = null;
			}
			
			cloudAnimal = new AnimalCloud(callBack, this, sid, mode, {scaleDone:0.8});
			cloudAnimal.create(btmDataName);
			cloudAnimal.show();
			
			
			switch(info.view) {
				case "mat_tree":
					cloudAnimal.x = - 24;
					cloudAnimal.y = - 220;
				break;
				default:
					cloudAnimal.x = - 30;
					cloudAnimal.y = - 140;
			}
			
			
			if (rotate) {
				cloudAnimal.scaleX = -cloudAnimal.scaleX;
				cloudAnimal.x += cloudAnimal.width;
			}
			
			//cloudAnimal.pluck(30);
		}*/
		
		private function flyMaterial(sid:int):void
		{
			var item:BonusItem = new BonusItem(sid, 0);
			
			var point:Point = Window.localToGlobal(App.ui.bottomPanel.bttnMainStock);
			var moveTo:Point = new Point(App.self.mouseX, App.self.mouseY);
			item.fromStock(point, moveTo, App.self.tipsContainer);
		}
		
		private function onContextClick():void
		{
			trace("onContextClick");
		}
		
		override public function uninstall():void {
			removeEventListener(AppEvent.AFTER_BUY, onAfterBuy);
			App.self.removeEventListener(AppEvent.ON_CHANGE_STOCK, onChangeStock);
			
			super.uninstall();
		}
		
		public function showMessage():void {
			new SimpleWindow( {
				title:	info.title,
				text:	Locale.__e('flash:1416474591946'),
				sID:	sid,
				label:	SimpleWindow.MATERIAL
			}).show();
		}
	}

}