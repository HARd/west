package units 
{
	import com.greensock.TweenLite;
	import core.Post;
	import core.TimeConverter;
	import wins.ConstructWindow;
	import wins.SpeedWindow;
	
	public class Bgolden extends Golden 
	{		
		public function Bgolden(object:Object, view:String='') 
		{
			crafted = object.crafted || 0;
			started = crafted - App.data.storage[object.sid].time;
			
			super(object);	
			
			if (totalLevels == 0) {
				if (info.devel) {
					for each(var obj:* in info.devel.req) {
						totalLevels++;
					}
				}
			}
			
			tip = function():Object {
				if (App.user.mode == User.OWNER) {
					if (level < totalLevels) {
						return {
							title:info.title,
							text:Locale.__e('flash:1382952379966')
						};
					}
					if (/*tribute ||*/ hasProduct){
						return {
							title:info.title,
							text:Locale.__e("flash:1382952379966")
						};
					}
					
					if (level == totalLevels)
					{
						return {
							title:info.title,
							text:Locale.__e("flash:1382952379839", [TimeConverter.timeToStr(crafted - App.time)]),
							timer:true
						};
					}
					
					return {
						title:info.title,
						text:Locale.__e("flash:1382952379967")
					};
				}
				
				return {
					title:info.title,
					text:Locale.__e('flash:1382952379966')
				};
			}	
		}
		
		override public function onLoad(data:*):void 
		{
			super.onLoad(data);
			
			if (level == totalLevels) {
				initAnimation(); 
				beginAnimation();
			}
		}
		
		override public function click():Boolean {
			if (App.user.mode == User.GUEST) {
				guestClick();
				return true;
			}
			
			if (!isReadyToWork()) return true;
			if (isProduct()) return true;
			
			if (openConstructWindow()) return true;
			return true;
		}
		
		override public function openConstructWindow():Boolean 
		{
			
			if ((craftLevels == 0 && level < totalLevels) || (craftLevels > 0 && level < totalLevels - craftLevels + 1))
			{
				if (App.user.mode == User.OWNER)
				{
						new ConstructWindow( {
							title:			info.title,
							upgTime:		info.devel.req[level + 1].t,
							request:		info.devel.obj[level + 1],
							reward:			info.devel.rew[level + 1],
							target:			this,
							win:			this,
							onUpgrade:		upgradeEvent,
							hasDescription:	true
						}).show();
						
						return true;
				}
			}
			return false;
		}
		
		override public function isReadyToWork():Boolean
		{
			if (crafted > App.time && level == totalLevels) {
				new SpeedWindow( {
					title:info.title,
					priceSpeed:info.skip,
					target:this,
					info:info,
					finishTime:crafted,
					totalTime:App.data.storage[sid].time,
					doBoost:onBoostEvent,
					btmdIconType:App.data.storage[sid].type,
					btmdIcon:App.data.storage[sid].preview
				}).show();
				return false;					
			}	
			return true;
		}
		
		override protected function onStockAction(error:int, data:Object, params:Object):void {
			if (error) {
				Errors.show(error, data);
				return;
			}
			this.id = data.id;
			
			hasProduct = false;
			open = true;
		}
		
		
	}

}