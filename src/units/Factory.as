package units 
{
	import core.Post;
	import flash.geom.Point;
	import flash.utils.setTimeout;
	import wins.AnimalProgressWindow;
	import wins.FurryWindow;
	import wins.ProductionWindow;
	
	public class Factory extends Building {
		private var _isBoost:Boolean;
		
		public static const TECHNO_FACTORY:uint = 165;
		public static const TECHNO_FACTORY_2:uint = 166;
		public static const TECHNO_FACTORY_3:uint = 167;
		public static const ANIMAL_FACTORY:uint = 134;
		public static const TECHNO_FACTORY_4:uint = 684;
		
		
		public static var waitForTarget:Boolean = false;
		
		public function Factory(object:Object)
		{
			super(object);
			
			if (sid == TECHNO_FACTORY || sid == TECHNO_FACTORY_2 || sid == TECHNO_FACTORY_3 || sid == TECHNO_FACTORY_4) {
				removable = false;
			}else {
				info.ask = 1;
			}
		}
		
		override public function click():Boolean 
		{
			if (App.user.mode == User.GUEST) {
				guestClick();
				return true;
			}
			
			if (sid && checkCrafting()) return true;
			
			if (!isReadyToWork()) return true;
			
			if (isPresent()) return true;
			
			if (isProduct()) return true;
			
			var that:Factory = this;
			if (sid == TECHNO_FACTORY || sid == TECHNO_FACTORY_2 || sid == TECHNO_FACTORY_3 || sid == TECHNO_FACTORY_4) 
			{
				/*if (!isPhase())
				{	
						isPresent();
						new FurryWindow({
							title:info.title,
							info:info,
							mode:FurryWindow.FURRY,
							target:that
						}).show();
					
					return true;
				}*/
			}
			
			/*if (isPhase())
			{
				if (App.user.mode == User.OWNER)
				{
					if (hasUpgraded)
					{
						openConstructWindow();
						
						return true;
					}
				}
			}			*/

			//if (sid && checkCrafting()) return true;
			
			//super.click();
			
			return true;
		}
		
		override public function isProduct(value:int = 0):Boolean
		{
			if (hasProduct)
			{	
				storageEvent();
				return true; 
			}
			return false;
		}
		
		override public function storageEvent(value:int = 0):void
		{
			Post.send({
				ctr:this.type,
				act:'storage',
				uID:App.user.id,
				id:this.id,
				wID:App.user.worldID,
				sID:this.sid,
				fID:fID
			}, onStorageEvent);			
		}
		
		public static var spirit:Techno = null;
		public function addSpirit():void {
			if (App.user.quests.tutorial && this.id == 1) {
				spirit = new Techno({
					id:1,
					sid:164,
					x:28,
					z:76,
					spirit:1
				});
			}
		}
		
		private function checkCrafting():Boolean 
		{
			if (crafting) {
				new AnimalProgressWindow({
					title:info.title,
					target:this,
					info:info,
					endTime:crafted,
					pid:fID,
					sid:fID
				}).show();
				return true;
			}
			return false;
		}
		
		override protected function onBuyAction(error:int, data:Object, params:Object):void 
		{
			if (error) {
				Errors.show(error, data);
				return;
			}
			
			this.id = data.id;
			//checkTechnoNeed();
			
			//setTimeout(function():void { hidePointing(); }, 3000);
			//showPointing("top", dx, dy);
			if(type != "Trade" &&level <= totalLevels - craftLevels)
			{
				//setFlag("constructing", isPresent, { target:this, roundBg:false, addGlow:false } );
			}
			openConstructWindow();
			
			//this.id = data.id;
			//instance = 1;
			//created = App.time + info.devel.req[1].t;
			//App.self.setOnTimer(build);
			//if (sid == ANIMAL_FACTORY) addProgressBar();
			//addEffect(Building.BUILD);
			//checkTechnoNeed();
		}
		
		override public function onBonusEvent(error:int, data:Object, params:Object):void 
		{
			if (error)
			{
				Errors.show(error, data);
				return;
			}
			
			//flag = false;
			
			var hasTechno:Boolean = false;
			var techno:Array = [];
			var reward:Object = info.devel.rew[level];
			var _reward:Object = { };
			var worker_sid:int = Techno.TECHNO;
			
			for (var _sid:* in reward) {
				if (App.data.storage[_sid].type == 'Techno') {
					hasTechno = true;
					worker_sid = _sid;
				}else{
					_reward[_sid] = reward[_sid];
				}
			}
			
			Treasures.bonus(Treasures.convert(_reward), new Point(this.x, this.y));
			
			removeEffect();
			
			if (hasTechno)
				addChildrens(worker_sid, data.units);
				
		}
		
		override public function onStorageEvent(error:int, data:Object, params:Object):void {
			
			if (error)
			{
				Errors.show(error, data);
				return;
			}
			
			ordered = false;
			
			hasProduct = false;
			crafting = false;
			
			fID = 0;
			crafted = 0;
			
			var that:* = this;
			spit(function():void{
				Treasures.bonus(data.bonus, new Point(that.x, that.y));
			}, bitmapContainer);
			
			var info:Object = App.data.storage[formula.out];
			if (info.type != 'Animal') return;
			
			addChildrens(formula.out, data.units);
		}
		
/*		public function checkBoost():Boolean
		{
			if (_boostStarted > App.time) {
				_isBoost = true;
				return true;
			}
			return false;
		}*/
		
		
		private function addChildrens(_sid:uint, ids:Object):void 
		{
			var rel:Object = { };
			rel[sid] = id;
			var position:Object = getBornPosition();
			
			var unit:Unit;
			if (App.user.quests.tutorial && this.id == 1 && spirit != null) {
				unit = Unit.add( { sid:Techno.TECHNO, id:1, x:spirit.coords.x, z:spirit.coords.z, rel:rel } );
				(unit as WorkerUnit).born();
				//spirit.uninstall();
				return;
			}
			for (var i:* in ids){
				unit = Unit.add( { sid:_sid, id:ids[i], x:position.x, z:position.z + 4, rel:rel } );
				(unit as WorkerUnit).born();
				unit.moveAction();
			}
		}
		
		
		private function getBornPosition():Object{
			return {
				x:coords.x + info.area.w,
				z:coords.z + info.area.h / 2 - 1
			}
		}
		
		override public function onApplyRemove(callback:Function = null):void
		{
			if (!removable) return;
			
			var bots:Array = findChildsTechno();
			for each(var bot:Techno in bots)
				bot.remove();
			
			super.onApplyRemove(callback);
		}
		
		public function findChildsTechno():Array 
		{
			var childs:Array = [];
			for each(var bot:* in App.user.techno) {
				if (bot.rel != null) {
					if (bot.rel[sid] != null && bot.rel[sid] == id)
						childs.push(bot);
				}
			}
			return childs;
		}
		
		override public function openProductionWindow(settings:Object = null):void {
			
			if (level == totalLevels || sid == TECHNO_FACTORY || sid == TECHNO_FACTORY_2 || sid == TECHNO_FACTORY_3 || sid == TECHNO_FACTORY_4)
				return;
				
			/*new ProductionWindow( {
				title:			info.title,
				crafting:		info.devel.craft,
				target:			this,
				onCraftAction:	onCraftAction,
				hasPaginator:	true,
				hasButtons:		true
			}).focusAndShow();*/
		}
		
		
		override public function upgraded():void {
			
			if (isUpgrade()){
				App.self.setOffTimer(upgraded);
				
				if(level >= totalLevels - craftLevels){
					addSpirit();
				}else {
					if (App.user.mode != User.GUEST) {
						hasPresent = true;
					}
				}
				
				hasPresent = true;
				this.level++;
				updateLevel();
				fireTechno();
				stopAnimation();
				//removeProgress();
			}
		}
		
		override public function build():void {
			
			if (isBuilded()){
				App.self.setOffTimer(build);
				
				fireTechno();
				hasPresent = true;
				updateLevel();
			}
		}
		
		override public function onUpgradeEvent(error:int, data:Object, params:Object):void 
		{
			if (error){
				Errors.show(error, data);
				return;
			}
			hasUpgraded = false;
			upgradedTime = data.upgrade;
			App.self.setOnTimer(upgraded);
		
			if(level >= totalLevels - craftLevels){
				startAnimation();
			}else {
				//addProgressBar();
			}
		}
		
		override public function setCraftLevels():void
		{
			for each(var obj:* in info.devel.rew) {
				for (var _sid:* in obj) {
					if(_sid == Techno.TECHNO){
						craftLevels++;
						break;
					}
				}
			}
		}
	}
}