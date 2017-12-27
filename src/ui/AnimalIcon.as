package ui 
{
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.utils.setTimeout;
	
	public class AnimalIcon extends UnitIcon 
	{
		
		public static var multiClickState:String;
		public static var multiClickTargetID:int = 0;
		
		public var rewardStorageTimeout:int = 0;
		
		public function AnimalIcon(type:String, sid:*=null, need:int=0, target:*=null, params:Object=null) 
		{
			super(type, sid, need, target, params);
		}
		
		override public function onClick(e:MouseEvent = null):void {
			super.onClick(e);
			
			var targets:Array = [];
			var i:int;
			
			if (params.multiclick && state == MATERIAL && (Cursor.type != 'animal_storage' || multiClickTargetID != sid)) {
				if (!App.user.stock.checkAll(require)) return;
				
				// Попытка не включать кормление если больше кормить некого
				targets = Map.findUnits([target.sid]);
				for (i = 0; i < targets.length; i++) {
					if (!targets[i].icon || targets[i].icon.state != MATERIAL) {
						targets.splice(i, 1);
						i--;
					}
				}
				if (targets.length <= 0) {
					resetMultiClick();
					return;
				}
				
				Cursor.type = 'animal_storage';
				Cursor.material = sid;
				Cursor.text = App.user.stock.count(sid);
				Cursor.moveMouseMargin = new Point(10,10);
				multiClickState = state;
				multiClickTargetID = sid;
				App.self.stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp, false, 10);
			}
			
			if (params.multiclick && state == REWARD && Cursor.type != 'animal_reward') {
				
				// Попытка не включать сбор если больше не с чего собирать
				targets = Map.findUnitsByType([target.type]);
				for (i = 0; i < targets.length; i++) {
					if (!targets[i].icon || targets[i].icon.state != REWARD) {
						targets.splice(i, 1);
						i--;
					}
				}
				if (targets.length <= 0) {
					resetMultiClick();
					return;
				}
				
				Cursor.type = 'animal_reward';
				Cursor.image = Cursor.BACKET;
				
				multiClickState = state;
				App.self.stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp, false, 10);
			}
		}
		override protected function onOver():void {
			if (Cursor.type == 'animal_reward' && state == REWARD) {
				onClick();
			}
			
			if (Cursor.type == 'animal_storage' && state == MATERIAL && !target.ordered) { // target.sid == multiClickTargetID
				if (sid == multiClickTargetID) {
					onClick();
					
					var onStock:int = App.user.stock.count(sid);
					if (need <= App.user.stock.count(sid) && Cursor.material) {
						Cursor.text = onStock;
					}else {
						onMouseUp();
					}
				}
			}
		}
		
		private function onMouseUp(e:MouseEvent = null):void {
			if (App.self.moveCounter > 2 && (multiClickState == MATERIAL || multiClickState == REWARD)) return;
			
			App.self.stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			
			setTimeout(AnimalIcon.resetMultiClick, 50);
			//AnimalIcon.resetMultiClick();
		}
		
		public static function resetMultiClick():void {
			
			App.map.unitIconOver = false;
			multiClickState = null;
			multiClickTargetID = 0;
			
			Cursor.type = 'default';
			Cursor.material = 0;
			Cursor.image = null;
			Cursor.text = '';
		}
	}

}