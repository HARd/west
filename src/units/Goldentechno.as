package units 
{
	import core.Post;
	import flash.geom.Point;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	import wins.FurryWindow;
	import wins.SimpleWindow;
	/**
	 * ...
	 * @author ...
	 */
	public class Goldentechno extends Techno
	{
		public static const GOLDEN_TECHNO_FORREST:uint = 589;
		public static const GOLDEN_TECHNO_ROCK:uint = 590;
		public static const GOLDEN_TECHNO_FURRY:uint = 591;
		
		public function Goldentechno(object:Object) 
		{
			
		object['spirit'] = '';	
		super(object);
		removable = false;
		
			if (!object.hasOwnProperty('die')) 
			{
				expired = App.time + this.info.time;
				App.user.goldenTechno.push(this);
			}else {				
				expired = object.die ;
				this.id = object.id;		
				App.user.goldenTechno.push(this);
			}
			
		}
		
		public function highlightTargets():void {
			
		}
		
		override public function goHome(_movePoint:Object = null):void
		{
			if (App.user.mode == User.OWNER && App.map.id == User.HOME_WORLD)		{
			clearTimeout(timer);
			
			if (isRemove)
				return;
			
			if (move) {
				var time:uint = Math.random() * 5000 + 5000;
				timer = setTimeout(goHome, time);
				return;
			}
			
			if (workStatus == BUSY)
				return;
			
			var place:Object;
			if (_movePoint != null) {
				place = _movePoint;
			}else if (homeCoords != null) { 
				place = findPlaceNearTarget({info:homeCoords.info, coords:homeCoords.coords}, homeRadius);
			}else {
				place = findPlaceNearTarget({info:{area:{w:4,h:4}},coords:{x:this.movePoint.x, z:this.movePoint.y}}, homeRadius);
			}
			
			framesType = Personage.WALK;
			initMove(
				place.x,
				place.z,
				onGoHomeComplete
			);
		}
		}
		
		override protected function onStockAction(error:int, data:Object, params:Object):void {
			if (error) {
				Errors.show(error, data);
				return;
			}
			
			this.id = data.id;
			if(!(multiple && App.user.stock.check(sid))){
				App.map.moved = null;
			}
			
			this.id = data.id;
		//	App.user.goldenTechno.push(this);
			
			//App.ui.upPanel.addTechIcon(this)
			
			
			if (this.info.time == 0) 
				{
					
				}else 
				{
					
			/*App.ui.upPanel.setTimeToTechnoIcons(expired - this.info.time, this.info.time, this.id);
				
					
			
				}*/
				}
		
			App.ui.glowing(this);
			World.addBuilding(this.sid);
		}
		
		override public function click():Boolean
		{
			
			if ((App.user.mode == User.GUEST) ) 
			{
				return false;
			}
			
			if (collecterBonus) {
				collecterBonus = false;
				collector.storageCollector(id);
				homeCoords = null;
				return true;
			}
			
			if (hasProduct) {
				storageEvent();
				return true;
			}
			highlightTargets();
			var that:Goldentechno = this;
			if (busy != BUSY)
			{
				App.map.focusedOn(this, false, function():void 
				{
					new FurryWindow({
						//title:info.title,
						info:info,
						target:that,
						mode:FurryWindow.FURRY_FREE
					}).show();
				}, true, 1, true, 0.5);
			}
			
			clearTimeout(intervalMove);
			
			if(isMoveThis){
				this.move = false;
				App.map.moved = null;
				isMove = false;
				isMoveThis = false
				return true;
			}
			return true;
		}
		
		override public function autoEvent(target:Resource, count:int = 1):void {
			countRes = count;
			Post.send( {
				ctr:this.type,
				act:'auto',
				uID:App.user.id,
				wID:App.user.worldID,
				sID:this.sid,
				id:id,
				rID:target.sid,
				mID:target.id,
				count:count
			}, function(error:int, data:Object, params:Object):void{
				if (error) {
					Errors.show(error, data);
					return;
				}
				finished = data.finished;
				busy = BUSY;
				target.busy = 1;
				App.self.setOnTimer(work);
				goToJob(target);
			});
		}
		
		override public function storageEvent(count:int = 1):void {
			
			if (collector) {
				collector.storageCollector(id);
				return;
			}
				
			
			var rew:Object = { };
			rew[target.sid] = countRes;
			
			if(target && target.hasOwnProperty('targetWorker'))
				target.targetWorker = null;
			
			var that:* = this;
			hasProduct = false;
			fire();
			Post.send( {
				ctr:this.type,
				act:'storage',
				uID:App.user.id,
				wID:App.user.worldID,
				sID:this.sid,
				id:id
			}, function(error:int, data:Object, params:Object):void{
				if (error) {
					Errors.show(error, data);
					return;
				}
				if (data.hasOwnProperty("bonus")){
					Treasures.bonus(data.bonus, new Point(that.x, that.y));
					fire(capacity);
				}
				if(target){
					target.busy = 0;
					target.setCapacity(data.cap);
					target = null;
				}
				finished = 0;
				busy = 0;
			});
		
			//timeExpired();
		}
		
		public static function freeTechno(sid:uint=0):Array {
			var result:Array = [];
			for each(var bot:Goldentechno in App.user.goldenTechno) {
				
				if (bot.isFree()){
				for each(var res:uint in bot.info.targets) {
				if (res == sid){
				result.push(bot);
				return result
				}
				}
			}	
			}
			
			return result;
		}
		
		 public function CheckResource(sid:int):Boolean {
			//var result:Array = [];
			for each(var res:uint in info.targets) {
				if (res == sid)
					return true
			}
			
			return false;
		}
		
		
		public function timeExpired():Boolean 
		{
			if (((expired - App.time)<=0)&&sid !=GOLDEN_TECHNO_FORREST && sid !=GOLDEN_TECHNO_ROCK && sid !=GOLDEN_TECHNO_FURRY &&this.info.time !=0)
			{
				
				var index:int = App.user.goldenTechno.indexOf(this)
				if (index != -1)
				{
					this.remove();
				}
				uninstall()
				
				return true
			}
			return false
		}
		
		
		
		override public function uninstall():void {
			var index:int = App.user.goldenTechno.indexOf(this)
			if (index != -1){
			App.user.goldenTechno.splice(index, 1);
			cell = 0;
			row = 0;
			//App.self.removeEventListener(AppEvent.ON_GAME_COMPLETE, onGameComplete);
			App.self.removeEventListener(AppEvent.ON_MAP_COMPLETE, onGameComplete);
			
			App.self.removeEventListener(AppEvent.ON_MOUSE_UP, onUp);
			this.visible = false;
			}
		//	super.uninstall();
			//App.ui.upPanel.update();
		}
		
		override public function remove(_callback:Function = null):void {
			
			var callback:Function = _callback;
			if (sid !=GOLDEN_TECHNO_FORREST && sid !=GOLDEN_TECHNO_ROCK && sid !=GOLDEN_TECHNO_FURRY &&this.info.time !=0) 
			{
			if (info && info.hasOwnProperty('ask') && info.ask == true)
			{
				//if (sid == 132)
					//return
				new SimpleWindow( {
					title:Locale.__e("flash:1382952379842"),
					text:Locale.__e("flash:1382952379968", [info.title]),
					label:SimpleWindow.ATTENTION,
					dialog:true,
					isImg:true,
					confirm:function():void {
						onApplyRemove(callback);
					}
				}).show();
			}
			else
			{
				onApplyRemove(callback)
			}
			}
		}
		
	}

}