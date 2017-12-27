package units 
{
	import com.greensock.TweenLite;
	import core.Post;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.geom.Point;
	import wins.ConstructWindow;
	import wins.SpeedWindow;
	
	public class Changeable extends Tribute 
	{
		
		public var view:int;
		public var views:Array = [];
		public var noTribute:Boolean = false;
		
		public function Changeable(object:Object) 
		{
			view = object.view || 1;
			addViews(object.views);
			if (views.indexOf(1) == -1) views.push(1);
			
			super(object);
			
			crafted = object.crafted || 0;
			tribute = false;
			
			touchableInGuest = false;
			stockable = false;
			
			if (rewardTime == 0) {
				_flag = null;
				crafted = 0;
				noTribute = true;
			}
			
			if (level >= totalLevels && !noTribute) {
				_flag = null;
				if(App.user.mode == User.OWNER){
					if (crafted > 0 && crafted > App.time) {
						App.self.setOnTimer(work);
					}else {
						tribute = true;
					}
				}
			}
			
			tip = function():Object {
				if (tribute){
					return {
						title:info.title,
						text:Locale.__e("flash:1382952379966")
					};
				}
				
				if (level >= totalLevels && !noTribute)
				{
					return {
						title:info.title,
						text:Locale.__e("flash:1382952379839", [TimeConverter.timeToStr(crafted - App.time)]),
						timer:true
					};
				}else if (!hasPresent && !hasUpgraded && App.time < upgradedTime) {
					return {
						title:info.title,
						text:Locale.__e('flash:1395412562823') +  '\n' + TimeConverter.timeToStr(upgradedTime - App.time),
						timer:true
					}
				}
				
				return {
					title:info.title,
					text:info.description
				};
			}
		}
		
		override public function init():void {
			if (App.user.mode == User.GUEST) {
				tribute = false;
			}
		}
		
		override public function onLoad(data:*):void {
			
			super.onLoad(data);
		}
		
		override public function work():void
		{
			flag = false;
			
			if (App.time >= crafted) {
				App.self.setOffTimer(work);
				tribute = true;
				onProductionComplete();
			}
		}
		
		public function set tribute(value:Boolean):void {
			//
		}
		
		
		override public function stockAction(params:Object = null):void {
			hasProduct = false;
			hasUpgraded = true;
			super.stockAction(params);
		}
		
		override public function click():Boolean {
			
			if (App.user.mode == User.GUEST) {
				guestClick();
				return true;
			}
			
			if (isPresent()) return true;
			
			if (isProduct()) return true;
			
			if (!isReadyToWork()) return true;
			
			openConstructWindow();
			
			return false;
		}
		
		override public function isReadyToWork():Boolean
		{
			var finishTime:int = -1;
			var totalTime:int = -1;
			if (created > 0 && !hasBuilded){ // еще строится
				var curLevel:int = level + 1;
				if (curLevel >= totalLevels) curLevel = totalLevels;
				finishTime = created;
				totalTime = App.data.storage[sid].devel.req[1].t;
			}else if (upgradedTime >0 && !hasUpgraded) { // еще апграйдится
				finishTime = upgradedTime;
				totalTime = App.data.storage[sid].devel.req[level+1].t;
			}
			if(finishTime >0){
				new SpeedWindow( {
					title:info.title,
					target:this,
					info:info,
					finishTime:finishTime,
					totalTime:totalTime
				}).show();
				return false;
			}
			
			if (level >= totalLevels && !hasPresent && (crafted > App.time || noTribute)) { 
				new SpeedWindow( {
					title:info.title,
					target:this,
					info:info,
					finishTime:crafted,
					totalTime:rewardTime,
					doBoost:onBoostEvent,
					btmdIconType:info.type,
					btmdIcon:info.preview,
					noTimer:noTribute
				}).show();
				return false;
			}
			
			return true;
		}
		
		override public function isProduct(value:int = 0):Boolean
		{
			if (tribute && !noTribute) {
				storageEvent();
				return true; 
			}
			
			return false;
		}
		
		override public function updateLevel(checkRotate:Boolean = false):void 
		{
			if (textures == null) return;
			
			var levelData:Object;
			if (this.level && info.devel && info.devel.req.hasOwnProperty(this.level + view - 1) && info.devel.req[this.level].hasOwnProperty("s")) {
				levelData = textures.sprites[info.devel.req[this.level].s];
			}else{
				levelData = textures.sprites[this.level + view - 1];
			}
			
			if (levelData == null)
				levelData = textures.sprites[0];
			
			if (checkRotate && rotate == true) {
				flip();
			}
			
			if (this.level != 0 && gloweble)
			{
				var backBitmap:Bitmap = new Bitmap(bitmap.bitmapData);
				backBitmap.x = bitmap.x;
				backBitmap.y = bitmap.y;
				addChildAt(backBitmap, 0);
				
				bitmap.alpha = 0;
				
				//App.ui.flashGlowing(this, 0xFFF000)//0x6fefff);
				
				TweenLite.to(bitmap, 0.4, { alpha:1, onComplete:function():void {
					removeChild(backBitmap);
					backBitmap = null;
				}});
				
				gloweble = false;
			}
			
			draw(levelData.bmp, levelData.dx, levelData.dy);
			
			checkOnAnimationInit();
			
			if (level >= totalLevels && crafted == 0) {
				crafted = App.time + info.form.req[view].t;
				App.self.setOnTimer(work);
			}
		}
		
		override public function onBoostEvent(count:int = 0):void {
			
			if (App.user.stock.take(Stock.FANT, count)){// || App.user.stock.take(Stock.FANT, count)) {
				
				started = App.time - rewardTime;
				
				var that:Tribute = this;
				
				onProductionComplete();
				
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
						
						if (data.hasOwnProperty(Stock.FANT))
							App.user.stock.data[Stock.FANT] = data[Stock.FANT];
					}
					
					stopAnimation();
				});	
			}
		}
		
		override public function storageEvent(value:int = 0):void
		{
			if (App.user.mode == User.OWNER && !noTribute) {
				
				tribute = false;
				
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
		
		override public function onStorageEvent(error:int, data:Object, params:Object):void {
			if (error)
			{
				Errors.show(error, data);
				if(params && params.hasOwnProperty('guest')){
					App.user.friends.addGuestEnergy(App.owner.id);
				}
				return;
			}
			
			App.self.setOnTimer(work);
			crafted = App.time + rewardTime;
			
			if (data.hasOwnProperty('bonus')) {
				Treasures.bonus(data.bonus, new Point(this.x, this.y));
				SoundsManager.instance.playSFX('bonus');
			}
		}
		
		public function get rewardTime():int {
			return info.form.req[view].t;
		}
		
		
		// Открыть вид
		private var openCallback:Function = null;
		private var viewForOpen:*;
		public function openAction(callback:Function, view:*):void {
			openCallback = callback;
			viewForOpen = view;
			
			if (!info.form.req.hasOwnProperty(view)) {
				trace('НЕИЗВЕСТНЫЙ VIEW !!');
				return;
			}
			
			Post.send( {
				ctr:this.type,
				act:'open',
				uID:App.user.id,
				id:this.id,
				wID:App.user.worldID,
				sID:this.sid,
				view:view
			}, onOpenAction);
		}
		private function onOpenAction(error:int, data:Object, params:Object):void {
			if (error) return;
			
			if (views.indexOf(int(viewForOpen)) == -1)
				views.push(int(viewForOpen));
			
			if (openCallback != null) openCallback();
			openCallback = null;
			
			tribute = false;
			crafted = App.time + rewardTime;
		}
		
		// Cvtybnm dbl
		private var viewCallback:Function = null;
		public function viewAction(callback:Function = null):void {
			viewCallback = callback;
			
			Post.send( {
				ctr:this.type,
				act:'view',
				uID:App.user.id,
				id:this.id,
				wID:App.user.worldID,
				sID:this.sid,
				view:view
			}, onOpenAction);
		}
		private function onViewAction(error:int, data:Object, params:Object):void {
			if (error) return;
			
			if (viewCallback != null) viewCallback();
			viewCallback = null;
			
			tribute = false;
			crafted = App.time + rewardTime;
		}
		
		
		
		public function addViews(object:* = null):void {
			if (object == null) return;
			
			for (var s:* in object) {
				if (views.indexOf(int(s)) == -1)
					views.push(int(s));
			}
		}
		private var setViewCallback:Function;
		public function setView(id:*, callback:Function = null):void {
			setViewCallback = callback;
			
			if (views.indexOf(int(id)) == -1) {
				openView(id);
				return;
			}
			
			if (view == int(id)) return;
			view = int(id);
			updateLevel();
			setViewCallback();
			viewAction();
		}
		
		private function openView(id:*):void {
			var target:Object = { sid:sid, level:level, viewID:id, totalLevels:totalLevels, type:type, views:views, info: { devel: { obj:info.form.obj, req: {}, skip: { 6:0 }}, form: info.form }};
			target.info.devel.req[level + 1] = { t:0, l:0 };
			target.info.devel.skip[level + 1] = 0;
			
			new ConstructWindow( {
				title:			info.title,
				upgTime:		0,
				request:		info.form.obj[id],
				target:			target,
				win:			null,
				onUpgrade:		function():void {
					openAction(function():void {
						view = int(id);
						updateLevel();
						setViewCallback();
					}, id);
				},
				hasDescription:	true,
				bttnTxt:		'flash:1382952379890',
				noSkip:			true
			}).show();
		}
		
	}

}