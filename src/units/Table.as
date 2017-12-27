package units 
{
	import core.Post;
	import flash.geom.Point;
	import ui.Cloud;
	import ui.Hints;
	import wins.BuildingConstructWindow;
	import wins.TableWindow;
	public class Table extends Building
	{
		public var guests:Object = {};
		public var _hasProfit:Boolean = false;
		
		public function Table(object:Object) 
		{
			this.guests = object.guests || {};
			
			super(object);
			
			if (guestsCount >= info.count) {
				hasProfit = true;
			}
			
			touchableInGuest = false;
		}
		
		override protected function onBuyAction(error:int, data:Object, params:Object):void {
			if (error) {
				Errors.show(error, data);
				return;
			}
			
			this.id = data.id;
		}
		
		override public function onLoad(data:*):void {
			
			super.onLoad(data);
			setCloudPosition(0, -50);
		}	
		
		public function addGuest(uid:String):void {
			guests[guestsCount] = uid;
		}
		
		public function set hasProfit(value:Boolean):void {
			_hasProfit = value;
			//if(value)
				//flag = Cloud.TRIBUTE;
			//else
				//flag = false;
		}
		
		public function get hasProfit():Boolean {
			return _hasProfit;
		}
		
		public function get guestsCount():uint {
			
			var count:int = 0;
			for (var i:* in guests) {
				count ++;
			}
			if (count > info.count)
				count = info.count;
				
			return count;
		}
		
		override public function click():Boolean {
			
			if (!clickable || id == 0) return false;
				
			if (App.user.mode == User.OWNER) {
				
				if (level < totalLevels) {
				
					// Открываем окно постройки
					new BuildingConstructWindow({
						title:info.title,
						level:Number(level),
						totalLevels:Number(totalLevels),
						devels:info.devel[level+1],
						bonus:info.bonus,
						target:this,
						upgradeCallback:upgradeEvent
					}).show();
				}
				else
				{
					new TableWindow({
						target:this,
						onStorage:onStorageClick
					}).show();
				}
			}
			return true;
		}
		
		public function onStorageClick():void {
			
			var price:Object = { };
			price[Stock.FANTASY] = 1;
					
			if (!App.user.stock.checkAll(price))	return;
					
			ordered = true;
			App.user.hero.addTarget( {
				target:this,
				callback:storageEvent,
				event:Personage.HARVEST,
				jobPosition:findJobPosition()
			});
		}
		
		public override function storageEvent(value:int = 0):void
		{
			var price:Object = { };
			price[Stock.FANTASY] = 1;
				
			if (!App.user.stock.takeAll(price))	return;
			Hints.minus(Stock.FANTASY, 1, new Point(this.x * App.map.scaleX + App.map.x, this.y * App.map.scaleY + App.map.y), true);
			
			Post.send({
				ctr:this.type,
				act:'storage',
				uID:App.user.id,
				id:this.id,
				wID:App.user.worldID,
				sID:this.sid,
				fID:fID
			}, onStorageEvent);
			
			hasProfit = false;
		}
		
		public override function onStorageEvent(error:int, data:Object, params:Object):void {
			
			if (error)
			{
				Errors.show(error, data);
				return;
			}
			
			Treasures.packageBonus(data.bonus, new Point(this.x, this.y));
			uninstall();
		}
	}
}
