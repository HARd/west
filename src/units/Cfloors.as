package units
{
	import adobe.utils.CustomActions;
	import units.Building;
	import wins.CbuildingWindow;
	import wins.CfloorsGuestWindow;
	import wins.CfloorsWindow;
	import wins.ProductionWindow;
	import wins.ShareGuestWindow;
	import wins.ShareWindow;
	import wins.SimpleWindow;
	import core.Post;
	
	public class Cfloors extends Building 
	{
		public var kicks:uint;
		public var slots:Array = [ { sID:25, count:1 }, { sID:25, count:2 }, { sID:25, count:3 }, { sID:25, count:4 }, { sID:25, count:5 }, { sID:25, count:6 }, { sID:25, count:7 }, { sID:25, count:8 } ];
		public var slotsCount:Array = [];
		public var chests:*;
		public function Cfloors(settings:Object) 
		{
			super(settings);
			
			info['buyKeysText'] = "Купить Экстра ключ";
			info['descriptionText'] = "Ваши ключи";
			info['kickInfo'] = "Помочь другу";
			info['help'] = "Помочь";
			info['kicksCount'] = settings.kicks;
			info['keys'] = 3;	
		}
		
		override public function click():Boolean 
		{
			if (!clickable) 
				return false;
			
			this.openProductionWindow();
			
			return true;
		}
		
		override public function openProductionWindow(settings:Object = null):void 
		{	
			if(App.user.mode == User.OWNER){
				new CfloorsWindow( {
					target:this,
					storageEvent:storageAction
				} ).show();
			}else {	
				if (kicks >= info.count)
				{
					// Больше стучать нельзя
				}
				else
				{
					new CfloorsGuestWindow({
						target:this,
						kickEvent:kickEvent
					}).show();
				}
			}
		}
		
		public function storageAction(boost:uint, callback:Function):void {
			
		}
		
		public function kickEvent(mID:uint, callback:Function, _sendObject:Object = null, count:int = 1):void {
			
			//if (info.devel.req.[info.level].key )
			
			var sendObject:Object = { };
			if (App.user) {
				sendObject = {
					ctr:info.type,
					act:'kick',
					uID:App.owner.id,
					wID:App.owner.worldID,
					sID:this.sid,
					id:this.id,
					guest:App.user.id,
					mID:mID
				}
			}
			
			Post.send(sendObject,
			function(error:int, data:Object, params:Object):void 
			{
				if (error) {
					Errors.show(error, data);
					return;
				}
				
				kicks += info.kicks[mID].c;
				if (data.hasOwnProperty('kicks'))
					kicks = data.kicks;
				
				if (kicks >= info.limit)
				{
					//TODO:ADDKey
				}
				callback(kicks);
			});
		}
	}

}