package units 
{
	import core.TimeConverter;
	import flash.geom.Point;
	import ui.UnitIcon;
	public class Booker extends Walkgolden 
	{
		public var played:uint = 0;
		public var playAllow:Boolean;
		
		public function Booker(object:Object) 
		{
			played = object.played || 0;
			super(object);	
			
			started = object.started;
			
			stockable = false;
			removable = false;
			
			init();
		}
		
		public function init():void {
			if(formed){
				if (played < App.midnight) {// Значит играли вчера
					tribute = true;
				}else{
					tribute = false;
					App.self.setOnTimer(work);
				}	
			}
			
			tip = function():Object {
				if (tribute)
				{
					return {
						title:info.title,
						text:Locale.__e("flash:1382952379966") + '\n' + info.description + ' ' + TimeConverter.timeToStr(started + info.time - App.time)
					};
				}else{
					return {
						title:info.title,
						text:info.description +' ' + TimeConverter.timeToStr(started + info.time - App.time),
						timer:true
					};
				}
			}
		}
		
		override public function click():Boolean 
		{			
			if (wasClick) return false;
			
			if (App.user.mode == User.GUEST) {
				return true;
			}
			
			if (tribute) {
				storageEvent();
				return true;
			}
			
			return true;
		}
		
		override public function work():void
		{
			if (App.time > App.nextMidnight)
			{
				App.self.setOffTimer(work);
				tribute = true;
			}
		}
		
		override public function set tribute(value:Boolean):void {
			if (value)
			{
				playAllow = value;
			}
			else
			{
				playAllow = false;
			}
			showIcon();
		}
		
		public function get tribute():Boolean {
			return playAllow;
		}
		
		override protected function onStockAction(error:int, data:Object, params:Object):void {
			if (error) {
				Errors.show(error, data);
				return;
			}
			
			this.id = data.id;
			started = App.time;
			
			this.cell = coords.x; 
			this.row = coords.z;
			
			movePoint.x = coords.x;
			movePoint.y = coords.z;
					
			moveable = true;
			
			played = App.midnight - 10;
			tribute = true;
			
			open = true;
			
			showIcon();
			
			goHome();
		}
		
		public override function onStorageEvent(error:int, data:Object, params:Object):void {
			
			if (error)
			{
				Errors.show(error, data);
				return;
			}
			ordered = false;
			
			if(data.hasOwnProperty('played')){
				this.played = data.played;
			}
			
			Treasures.bonus(data.bonus, new Point(this.x, this.y));
			
			if (started + info.time + 86400 < App.time) {
				uninstall();
			}
		}
		
		override public function showIcon():void {
			if (!formed || !open) return;
			
			if (App.user.mode == User.GUEST && touchableInGuest) {
				{
					drawIcon(UnitIcon.REWARD, 2, 1, {
						glow:		false
					});
				} 
			}
			
			if (App.user.mode == User.OWNER) {
				if (tribute) {
					drawIcon(UnitIcon.REWARD, Stock.FANT, 1, {
						glow:		true
					});
				}else {
					clearIcon();
				}
			}
		}
		
	}

}