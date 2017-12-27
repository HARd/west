package units 
{
	import core.Load;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	import ui.Cursor;
	import wins.ShopWindow;
	/**
	 * ...
	 * @author 
	 */
	public class Character extends WorkerUnit
	{
		public static const MORION:String = 'morion';
		
		public function Character(object:Object) 
		{
			
			super(object);
			
			velocities = [0.05];
			info['area'] = { w:1, h:1 };
			cells = rows = 1;
			
			//if(formed)
				//moveable = false;
			//else	
				moveable = true;
			takeable = false;
			removable = true;
			
			App.user.characters.push(this);
			
			var isAddIcon:Boolean = true;
			for (var i:int = 0; i < App.user.charactersData.length; i++ ) {
				if (sid == App.user.charactersData[i].sid)
					isAddIcon = false;
			}
			
			if (isAddIcon) {
				App.user.charactersData.push({sid:sid, type:info.type});
			}
			
			/*if(!App.ui.upPanel.consistPersIcon(sid))
				App.ui.upPanel.addPersIcon({aka:App.data.storage[sid].title, sid:sid, type:info.type});*/
			
			if(Map.ready)
				goHome();
			else
				App.self.addEventListener(AppEvent.ON_MAP_COMPLETE, onMapComplete);
				
			
			if(ShopWindow.shop && ShopWindow.shop[100])
				ShopWindow.shop[100].data;
			
			tip = function():Object {
				
				return {
					title:info.title,
					text:info.description
				}
			}
			
			App.ui.salesPanel.createPromoPanel();	
			shortcutDistance = 50;
		}
		
		private function onMapComplete(e:AppEvent):void {
			App.self.removeEventListener(AppEvent.ON_MAP_COMPLETE, onMapComplete);
			goHome();
		}
		
		override public function onStop():void
		{
			framesType = Personage.STOP;
		}
		
		override protected function onBuyAction(error:int, data:Object, params:Object):void 
		{
			if (error) {
				Errors.show(error, data);
				return;
			}
			//moveable = false;
			//for (var ind:* in ShopWindow.shop[100].data) {
				//
				//for (var ind2:* in ShopWindow.shop[100].data[ind].data) {
					//if (ShopWindow.shop[100].data[ind].data[ind2].sID == sid) {
						//trace();
						//delete ShopWindow.shop[100].data[ind].data[ind2]//ShopWindow.shop[100].data[ind].data
					//}
				//}
				//
				//ShopWindow.shop[100].data[].data[].sID == sid
			//}
			
			this.cell = coords.x;
			this.row = coords.z;
			this.id = data.id;
			App.ui.salesPanel.createPromoPanel();
			
			setTimeout(goHome, 2000);
		}
		
		//override public function goHome():void 
		//{
			//clearTimeout(timer);
			//
			//if (move) {
				//var time:uint = Math.random() * 4000 + 4000;
				//timer = setTimeout(goHome, time);
				//return;
			//}
			//
			//if (workStatus == BUSY) 
				//return;
				//
			//for (var home_sID:* in rel)
				//break;
				//
			//var place:Object;	
			//
			//place = findPlaceNearTarget({info:{area:{w:1,h:1}},coords:App.map.heroPosition}, 5);
				//
			//
			//framesType = Personage.WALK;
			//initMove(
				//place.x, 
				//place.z,
				//onGoHomeComplete
			//);
		//}
		
		override public function click():Boolean
		{
			/*framesType = 'fly';
			goOnRandomPlace();
			*/
			
			return true;
		}
		
		override public function load():void
		{
			if (preloader) addChild(preloader);
			Load.loading(Config.getSwf(info.type, info.view), onLoad);
		}
		
		override public function onLoad(data:*):void {
			super.onLoad(data);
			goHome();
		}
		
		override public function goOnRandomPlace():void 
		{
			var place:Object = findPlaceNearTarget(this, 5);
			initMove(
				place.x, 
				place.z,
				onGoOnRandomPlace
			);
		}
		
		override public function uninstall():void 
		{
			if (App.user.characters.indexOf(this) != -1)	
				App.user.characters.splice(App.user.characters.indexOf(this), 1);
				
			super.uninstall();
		}
		
		override public function onGoHomeComplete():void {
			stopRest();
			//if(started > 0){
				var time:uint = Math.random() * 5000 + 5000;
				timer = setTimeout(goHome, time);
			//}
		}
		
		override public function onMoveAction(error:int, data:Object, params:Object):void {
			
			if (error) {
				Errors.show(error, data);
				
				free();
				_move = false;
				placing(prevCoords.x, prevCoords.y, prevCoords.z);
				take();
				state = DEFAULT;
				
				//TODO меняем координаты на старые
				return;
			}	
			this.cell = coords.x;
			this.row = coords.z;
			
			movePoint.x = coords.x;
			movePoint.y = coords.z;
			
			goHome();
		}
		
		override public function set touch(touch:Boolean):void {
			if ((!moveable && Cursor.type == 'move') ||
				(!removable && Cursor.type == 'remove') ||
				(!rotateable && Cursor.type == 'rotate'))
			{
				return;
			}
			
			stopWalking();
			onGoHomeComplete();
			
			super.touch = touch;
		}
		
	}

}