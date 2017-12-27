package units 
{
	import com.greensock.TweenLite;
	import core.Post;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import ui.HelpPanel;
	
	public class Guest extends Hero
	{
		
		public var friend:Object;
		
		public var help:HelpPanel;
		public var showedHelp:Boolean = false;
		
		
		public function Guest(friend:Object, object:Object)
		{
			this.friend = friend;
			
			super(friend, object);
			
			touchable = true;
			clickable = true;
			
			createAva(friend);
			ava.addEventListener(MouseEvent.MOUSE_OVER, onOfferHelp);
			
			
			help = new HelpPanel(onTakeHelp, reject);
			help.x = x + 28;
			help.y = y - 168;
		}
		
		override public function set touch(touch:Boolean):void {
			
			if (!touchable || (App.user.mode == User.GUEST && touchableInGuest == false)) return;
			
			_touch = touch;
			
			if (touch) {
				if(state == DEFAULT){
					onOfferHelp();
				}
			}
		}
		
		private function onOfferHelp(e:MouseEvent = null):void {
			
			if(!help.showed && !help.closed){
				
				help.show();
				App.map.mTreasure.setChildIndex(ava, App.map.mTreasure.numChildren - 1);
				
				help.x = x + 28;
				help.y = y - 168;
			}else if (help.showed) {
				help.update();
			}
		}
		
		override public function walk(e:Event = null):* {
			super.walk();
			ava.x = x - 38;
			ava.y = y - 168;
		}
				
		public function selectTargets():Array {
			var unit:*;
			var num:int = App.map.mSort.numChildren;
			var childs:Array = [];
			while (num--) {
				unit = App.map.mSort.getChildAt(num);
				
				if (unit is Resource && !unit.helped && !unit.busy && !unit.ordered && unit.capacity > 0) {
					if (App.map._aStarNodes[unit.coords.x][unit.coords.z].open == false) {
						continue;
					}
					childs.push(unit);
				}/*else if (unit is Plant && !unit.field.helped && !unit.field.ordered && unit.field.plant.ready) {
					if (App.map._aStarNodes[unit.field.coords.x][unit.field.coords.z].open == false) {
						continue;
					}
					childs.push(unit.field);
				}*/
				
			}
			
			return childs;
		}
		
		public function getRandomTarget(targets:Array):Unit {
			var num:int = targets.length;
			var target:*;
			if (num == 0) {
				//reject();
			}
			if (num == 1) {
				target = targets[0];
				targets.splice(0,1);
				return target;
			}
			var i:int = int(Math.random() * num);
			target = targets[i];
			targets.splice(i, 1);
			
			return target;
		}
		
		private function onResourceTarget(target:*):Function {	
			var that:Guest = this;
			return function():void{
				target.onTakeResourceEvent(that);
				if (that.tm.length == 0){
					uninstall();
				}
			}
		}
		
		private function onHarvestTarget(target:*):Function {	
			var that:Guest = this;
			return function():void{
				target.onHarvestEvent(that);
				if (that.tm.length == 0) {
					uninstall();
				}
			}
		}
			
		
		private function onTakeHelp():void {
					
			if (friend['helped'] == undefined || friend.helped <= 0) {
				uninstall();
				return;
			}
			var targets:Array = selectTargets();
			
			var that:Guest = this;
			
			if (targets.length == 0) {
				reject();
				return;
			}
			
			var helped:int = friend.helped;
			while (helped > 0) {
				
				if (targets.length == 0) {
					helped = 0;
					return;
				}
				
				var target:* = getRandomTarget(targets);
				
				if (target == null) {
					if(friend.helped == 2){
						uninstall();
					}
					return;
				}
				
				if(target is Resource){
					var capacity:int = target.capacity; 
					
					while (helped > 0 && capacity > 0) {
						
						target.helped = true;
						addTarget( {
							target:target,
							callback:onResourceTarget(target),
							event:Personage.HARVEST,
							jobPosition: target.getContactPosition()
						});	
						helped--;
						capacity--;
					}
				}else if(target is Field && helped > 0){
					target.helped = true;
					addTarget( {
						target:target,
						callback:onHarvestTarget(target),
						event:Personage.HARVEST,
						jobPosition: { x:0, y:0 }
					});	
					
					helped--;
				}
			}
			
		}
		
		public function reject():void {
			
			Post.send( {
				ctr:'friends',
				act:'reject',
				uID:App.user.id,
				fID:friend.uid
			}, function(error:*, result:*, params:*):void {
				
			});
			
			uninstall();
		}
		
		override public function uninstall():void {
						
			if(App.map.mTreasure.contains(ava)){
				App.map.mTreasure.removeChild(ava);
			}
			help.dispose();
			TweenLite.to(this, 0.4, { alpha:0, onComplete: super.uninstall});
		}
		
		override public function click():Boolean {
			return false;
		}
		
	}

}