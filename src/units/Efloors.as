package units 
{
	import core.Post;
	import ui.UnitIcon;
	import wins.ConstructWindow;
	import wins.EfloorsWindow;
	import wins.OpenZoneWindow;
	import wins.ShareGuestWindow;
	import wins.SimpleWindow;
	public class Efloors extends Share 
	{
		public var kicksLimit:int = 0;
		public var floor:int = 0;
		public var totalFloors:int = 0;
		public var timer:int = 0;
		
		public function Efloors(settings:Object) 
		{
			super(settings);
			
			kicksLimit = info.limit;
			
			if (floor <= totalFloors && level >= totalLevels && App.user.mode == User.GUEST) {
				startGlowing();
			}
		}
		
		override public function click():Boolean {
			if (App.user.mode == User.GUEST && level < totalLevels) {
				new SimpleWindow( {
					title:info.title,
					label:SimpleWindow.ATTENTION,
					text:Locale.__e('flash:1409298573436')
				}).show();
				return true;
			}
			
			if (!clickable || id == 0) return false;
			
			/*if (!isReadyToWork()) return true;
			
			if(App.user.mode == User.OWNER){
				if (isPresent()) return true;
			}*/
			
			if (level < totalLevels) {
				if(App.user.mode == User.OWNER){
					new OpenZoneWindow( {
						title			:info.title,
						requires		:info.devel.obj[level + 1],
						upgTime			:info.devel.req[level + 1].t,
						request			:info.devel.obj[level + 1],
						target			:this,
						level			:level + 1,
						totalLevels		:totalLevels,
						onBuild			:upgradeEvent,
						reward          :info.devel.rew[level + 1],
						description		:'',
						hasDescription	:false
					}).show();
				}
			} else {
				if (App.user.mode == User.OWNER) {
					new EfloorsWindow( {
						target:this,
						storageEvent:storageAction,
						buyKicks:buyKicks
					}).show();
				}
				else {
					if (hasPresent) {
						new SimpleWindow( {
							title:title,
							label:SimpleWindow.ATTENTION,
							text:Locale.__e('flash:1409297890960')
						}).show();
						return true;
					}
					
					if (kicks >= kicksLimit) {
						var text:String = Locale.__e('flash:1382952379909',[info.title]);
						var title:String = Locale.__e('flash:1382952379908');
						// Больше стучать нельзя
						new SimpleWindow( {
							title:title,
							label:SimpleWindow.ATTENTION,
							text:text
						}).show();
						return true;
					}else {
						new ShareGuestWindow({
							target:this,
							kickEvent:kickEvent
						}).show();
					}
				}
			}
			
			return true;	
		}
		
		public function buyKicks(params:Object):void {
			
			var callback:Function = params.callback;
			var that:Efloors = this;
			
			Post.send( {
				ctr:this.type,
				act:'boost',
				uID:App.user.id,
				id:this.id,
				wID:App.user.worldID,
				sID:this.sid
			},function(error:int, data:Object, params:Object):void {
				if (error) {
					Errors.show(error, data);
					return;
				}
				
				if (data.hasOwnProperty(Stock.FANT))
					App.user.stock.put(Stock.FANT, data[Stock.FANT]);
				
				kicks = data.kicks;
				callback();
			});
		}
		
		override public function storageAction(boost:uint, callback:Function):void {
			
			var self:Share = this;
			var sendObject:Object = {
				ctr:this.type,
				act:'storage',
				uID:App.user.id,
				wID:App.user.worldID,
				sID:this.sid,
				id:this.id
			}
				
			Post.send(sendObject,
			function(error:int, data:Object, params:Object):void {
				
				if (error) {
					Errors.show(error, data);
					return;
				}
				
				var bonus:Object = { };
				
				if (data.hasOwnProperty('bonus'))
					bonus = data.bonus;
					
				callback(Stock.FANT, boost, bonus);
				
				if (data.hasOwnProperty(Stock.FANT))
					App.user.stock.data[Stock.FANT] = data[Stock.FANT];
				
				
				if (info.burst == 1)
				{
					level = 0;
					kicks = 0;
					guests = { };
					updateLevel();
				}else{
					uninstall();
				}
				
				self = null;
			});
		}
		
		override public function showIcon():void {
			if (!formed || !open) return;
			
			if (App.user.mode == User.OWNER) {				
				if (crafted > 0 && crafted <= App.time && hasProduct && formula) {
					drawIcon(UnitIcon.REWARD, formula.out, 1, {
						glow:		true
					});
				}else if (crafted > 0 && crafted >= App.time && formula) {
					drawIcon(UnitIcon.PRODUCTION, formula.out, 1, {
						progressBegin:	crafted - formula.time,
						progressEnd:	crafted
					});
				}else if (hasPresent) {
					drawIcon(UnitIcon.REWARD, 2, 1, {
						glow:		true
					});
				}else if (hasBuilded && upgradedTime > 0 && upgradedTime > App.time && level < totalLevels) {
					drawIcon(UnitIcon.BUILDING, null, 0, {
						clickable:		false,
						boostPrice:		info.devel.skip[level + 1],
						progressBegin:	upgradedTime - info.devel.req[level + 1].t,
						progressEnd:	upgradedTime,
						onBoost:		function():void {
							acselereatEvent(info.devel.skip[level + 1]);
						}
					});
				}else if ((craftLevels == 0 && level < totalLevels) || (craftLevels > 0 && level < totalLevels - craftLevels + 1)) {
					drawIcon(UnitIcon.BUILD, null);
				}else {
					clearIcon();
				}
			}else if (App.user.mode == User.GUEST) {
				if (level >= totalLevels) {
					drawIcon(UnitIcon.HAND_STATE, UnitIcon.HAND, 1, {
						glow:		false
					});
				} else {
					clearIcon();
				}
			}
		}
	}

}