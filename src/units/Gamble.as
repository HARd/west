package units
{
	import core.Post;
	import core.TimeConverter;
	import flash.events.Event;
	import flash.geom.Point;
	import ui.Cloud;
	import ui.UnitIcon;
	import wins.GambleWindow;
	
	public class Gamble extends Golden
	{
		public var played:uint = 0;
		public var playAllow:Boolean;
		
		public function Gamble(object:Object)
		{
			played = object.played || 0;
			super(object);
			
			stockable = false;
			touchableInGuest = true;
			removable = false;
			
			tip = function():Object {
				if (tribute)
				{
					return {
						title:info.title,
						text:Locale.__e("flash:1382952379911")
					};
				}else{
					return {
						title:info.title,
						text:Locale.__e("flash:1382952379912", [TimeConverter.timeToStr(App.nextMidnight - App.time)]),
						timer:true
					};
				}
			}
		}
		
		public override function init():void {
			if(formed){
				if (played < App.midnight) {// Значит играли вчера
					tribute = true;
				}else{
					tribute = false;
					App.self.setOnTimer(work);
				}	
			}	
		}
		
		override public function work():void
		{
			if (App.time > App.nextMidnight)
			{
				App.self.setOffTimer(work);
				tribute = true;
			}
		}
		
		public function set tribute(value:Boolean):void {
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
		
		override public function get tribute():Boolean {
			return playAllow;
		}
		
		override protected function onBuyAction(error:int, data:Object, params:Object):void 
		{
			if (error) {
				Errors.show(error, data);
				return;
			}
			
			this.id = data.id;
			beginAnimation();
			tribute = true;
			
			// Регистрация покупки объекта с полем gcount
			if (Storage.isShopLimited(sid)) {
				Storage.shopLimitBuy(sid);
				App.user.updateActions();
				App.ui.salesPanel.updateSales();
				App.user.storageStore('shopLimit', Storage.shopLimitList, true);
			}
		}
		
		override public function onAfterBuy(e:AppEvent):void
		{
			//super.onAfterBuy(e);
			
			played = App.midnight - 10;
			tribute = true;
			
			//var frame:Object = textures.animation.animations[framesType].frames[0]
		}
		
		override public function onLoad(data:*):void {
			
			super.onLoad(data);
			startAnimation();
			//var frame:Object = textures.animation.animations[framesType].frames[0]
			//findCloudPosition();
		}
		
		override public function click():Boolean {
			if (!clickable || (App.user.mode == User.GUEST && touchableInGuest == false)) return false;
			App.tips.hide();
				
			if (App.user.mode == User.OWNER) {
				
				new GambleWindow( {
					target:this,
					onPlay:playEvent
				}).show();
			} else {
				if (guestDone) return false;
				
				if(App.user.addTarget({
					target:this,
					near:true,
					callback:onGuestClick,
					event:Personage.HARVEST,
					jobPosition:getContactPosition(),
					shortcut:true
				})) {
					ordered = true;
					clearIcon();
				}else {
					ordered = false;
				}
			}
			
			return true;
		}
		
		private var paid:uint = 0;
		private var onPlayed:Function;
		public function playEvent(paid:int, onPlayed:Function):void {
			
			this.onPlayed = onPlayed;
			this.paid = paid;
			
			if (paid == 1) {
				if (!App.user.stock.take(Stock.FANT, info.skip))
					return;
			}
			
			storageEvent();
		}
		
		override public function storageEvent(value:int = 0):void
		{
			if (App.user.mode == User.OWNER) {
				
				Post.send({
					ctr:this.type,
					act:'storage',
					uID:App.user.id,
					id:this.id,
					wID:App.user.worldID,
					sID:this.sid,
					paid:paid
				}, onStorageEvent);
				
				tribute = false;
			}
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
			
			if (onPlayed != null) onPlayed(data.bonus);
			Treasures.bonus(data.bonus, new Point(this.x, this.y));
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
					drawIcon(UnitIcon.REWARD, 2, 1, {
						glow:		true
					});
				}else {
					clearIcon();
				}
			}
		}
		
		
	}
}