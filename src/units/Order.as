package units 
{
	import com.greensock.TweenLite;
	import core.Post;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import ui.HelpPanel;
	
	public class Order extends Hero
	{
		
		public var friend:Object;
		
		public var help:HelpPanel;
		public var showedHelp:Boolean = false;
		public var order:Object;
		
		public function Order(object:Object)
		{
			order = App.data.orders[object.oID];
			friend = App.data.storage[object.sid];
			friend['first_name'] = friend.title;
			
			super(friend, object);
			
			touchable = true;
			clickable = true;
			
			//createAva(friend);
			//ava.addEventListener(MouseEvent.MOUSE_OVER, onOfferHelp);
			
			if (!object.id)
				buyAction();
			
			//help = new HelpPanel(onTakeHelp, reject);
			//help.x = x + 28;
			//help.y = y - 168;
		}
		
		/*override public function set touch(touch:Boolean):void {
			
			if (!touchable || (App.user.mode == User.GUEST && touchableInGuest == false)) return;
			
			_touch = touch;
		}*/
		
		override public function buyAction():void {
			
			Post.send( {
				ctr:this.type,
				act:'buy',
				uID:App.user.id,
				wID:App.user.worldID,
				sID:this.sid,
				oID:order.ID,
				x:coords.x,
				z:coords.z
			}, function(error:int, data:Object, params:Object):void {
				if (error) {
					Errors.show(error, data);
					return;
				}
				
				this.id = data.id;
			});
							
			dispatchEvent(new AppEvent(AppEvent.AFTER_BUY));
		}
		
		override public function walk(e:Event = null):* {
			super.walk();
			//ava.x = x - 38;
			//ava.y = y - 168;
		}
	
		public function rejectAction():void {
			
			Post.send( {
				ctr:this.type,
				act:'reject',
				uID:App.user.id,
				wID:App.user.worldID,
				sID:this.sid,
				id:this.id
			}, function(error:*, data:Object, params:Object = null):void 
			{
				if (error){
					Errors.show(error, data);
					return;
				}
				goAway();
			});
		}
		
		public function exchangeAction():void {
			
			Post.send( {
				ctr:this.type,
				act:'exchange',
				uID:App.user.id,
				wID:App.user.worldID,
				sID:this.sid,
				id:this.id
			}, function(error:*, data:Object, params:Object = null):void 
			{
				if (error){
					Errors.show(error, data);
					return;
				}
				goAway();
			});
		}
		
		public function skipAction():void {
			
			Post.send( {
				ctr:this.type,
				act:'skip',
				uID:App.user.id,
				wID:App.user.worldID,
				sID:this.sid,
				id:this.id
			}, function(error:*, data:Object, params:Object = null):void
			{
				if (error){
					Errors.show(error, data);
					return;
				}
				goAway();
			});
		}
		
		public function goAway():void 
		{
			uninstall();
		}
		
		override public function uninstall():void 
		{
			//if(App.map.mTreasure.contains(ava)){
			//	App.map.mTreasure.removeChild(ava);
			//}
			//help.dispose();
			TweenLite.to(this, 0.4, { alpha:0, onComplete: super.uninstall});
		}
		
		override public function click():Boolean {
			//exchangeAction();
			skipAction();
			return true;
		}
	}
}