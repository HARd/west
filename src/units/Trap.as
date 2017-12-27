package units 
{
	import com.greensock.TweenLite;
	import core.Post;
	import core.TimeConverter;
	import flash.geom.Point;
	import ui.UnitIcon;
	import wins.ConstructWindow;
	import wins.TrapWindow;
	public class Trap extends Building 
	{
		public var capacity:int = 0;
		public var started:int = 0;
		public function Trap(object:Object) 
		{
			
			if (object.count)
				capacity = object.count;
			
			if (object.hasOwnProperty('level'))
				level = object.level;
				
			super(object);
			
			started = object.started || 0;
			if (started > 0)
				started -= info.time;
			
			tip = function():Object {
				
				var subText:String = Locale.__e('flash:1414400030281', [info.count - capacity]);
				if (!info.count || info.count == 0) {
					subText = '';
					
					return {
						title:info.title,
						text:Locale.__e("flash:1382952379966") + '\n' + subText
					};
				}
				
				if (started == 0) {
					return {
						title:info.title,
						text:info.description + '\n' + subText
					};
				}
				
				if (started > 0 && started + info.time <= App.time) {
					return {
						title:info.title,
						text:Locale.__e('flash:1382952379966')
					};
				}
				
				return {
					title:info.title,
					text: Locale.__e("flash:1382952379839", [TimeConverter.timeToStr(started + info.time - App.time)]) + '\n' + subText,
					timer:true
				};
			}
			
			if (started > 0 && App.time < started + info.time) 
				App.self.setOnTimer(work);
		}
		
		override public function onLoad(data:*):void {
			super.onLoad(data);
			
			if (started > 0 && App.time < started + info.time)  {
				initAnimation();
				startAnimation();
			}
		}
		
		override public function click():Boolean 
		{			
			if (App.user.mode == User.GUEST) {
				guestClick();
				return true;
			}
			
			if (this.id == 0) return false;
			
			if (capacity >= info.count) return false;
			
			if (isPresent()) return true;
			
			if (openConstructWindow()) return true;	
			
			return true;
		}
		
		override public function openConstructWindow():Boolean 
		{
			if (capacity < info.count)
			{
				if (App.user.mode == User.OWNER)
				{
					//if (hasUpgraded)
					{
						new TrapWindow( {
							title:			info.title,
							request:		info['in'],
							reward:			info['outs'],
							target:			this,
							onUpgrade:		kickEvent,
							hasDescription:	true
						}).show();
						
						return true;
					}
				}
			}
			return false;
		}
		
		public function kickEvent(params:Object = null, fast:int = 0):void {			
			// Забираем материалы со склада
			if (fast == 0) {
				if (!App.user.stock.takeAll(info['in'])) return;
			}
			
			gloweble = true;
			
			Post.send( {
				ctr:this.type,
				act:'kick',
				uID:App.user.id,
				id:this.id,
				wID:App.user.worldID,
				sID:this.sid,
				fast:fast
			},onKickEvent, params);
		}
		
		public function onKickEvent(error:int, data:Object, params:Object):void 
		{
			if (error){
				Errors.show(error, data);
				return; 
			}else {
				App.self.setOnTimer(work);
				this.started = data.started - info.time;
				
				initAnimation();
				startAnimation();
				
				showIcon();
			}
		}
		
		private function work():void {
			if (started > 0 && started + info.time <= App.time) {
				App.self.setOffTimer(work);
				showIcon();
				finishAnimation();
			}
		}
		
		override public function isPresent():Boolean
		{
			if (started > 0 && started + info.time <= App.time) {				
				Post.send({
					ctr:this.type,
					act:'storage',
					uID:App.user.id,
					id:this.id,
					wID:App.user.worldID,
					sID:this.sid
				}, onBonusEvent);
				
				return true;
			}
			return false;			
		}
		
		override public function onBonusEvent(error:int, data:Object, params:Object):void 
		{
			if (error) {
				Errors.show(error, data);
				return;
			}
			
			removeEffect();
			showIcon();
			
			if(data.hasOwnProperty('out')) {
				Treasures.bonus(Treasures.convert(data.out), new Point(this.x, this.y));
			}
			started = 0;
			capacity++;
			
			if (capacity >= info.count) {
				TweenLite.to(this, 1, { alpha:0, onComplete:function():void 
				{
					removable = true;
					uninstall();
				}});
			}
			
			showIcon();
		}
		
		override protected function onStockAction(error:int, data:Object, params:Object):void {
			if (error) {
				Errors.show(error, data);
				return;
			}
			this.id = data.id;
			started = 0;
		}
		
		override public function showIcon():void {
			if (!formed || !open) return;
			
			if (started > 0 && started + info.time <= App.time) {
				drawIcon(UnitIcon.REWARD, 2, 1, {
					glow:		false
				});
			}else {
				clearIcon();
			}
			
		}
		
		public function boostAction():void {
			if (!App.user.stock.take(Stock.FANT, info.skip)) return;
			
			Post.send({
				ctr:this.type,
				act:'boost',
				uID:App.user.id,
				id:this.id,
				wID:App.user.worldID,
				sID:this.sid
			}, onBoostAction);
		}
		
		public function onBoostAction(error:int, data:Object, params:Object):void {
			if (error) {
				Errors.show(error, data);
				return;
			}
			
			if (data.hasOwnProperty('started')) started = data.started;
		}
		
	}

}