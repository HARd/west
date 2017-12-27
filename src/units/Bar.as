package units
{
	import core.TimeConverter;
	import flash.geom.Point;
	import wins.BuildingConstructWindow;
	import wins.ShareGuestWindow;
	import wins.SimpleWindow;
	import wins.Window;
	
	public class Bar extends Share
	{
		public var items:int = 0;
		public function Bar(object:Object)
		{
			this.items = object.items || 0;
			if (items < 0) items = 0;
			super(object);
			
			tip = function():Object {
				
				if(App.user.mode == User.OWNER){
					if (hasProduct){
						return {
							title:info.title,
							text:Locale.__e("flash:1382952379845", [App.data.storage[formula.out].title])
						};
					}
					
					if (fID != 0){
						return {
							title:info.title,
							text:Locale.__e("flash:1382952379846", [App.data.storage[formula.out].title, TimeConverter.timeToStr((crafted + formula.time) - App.time)]),
							timer:true
						};
					}
				}	
				
				return {
					title:info.title,
					text:info.description
				};
			}
		}
		
		override public function onLoad(data:*):void {
			super.onLoad(data);
			if (App.user.mode == User.GUEST){
				//if (!hasFreeTable() && !App.data.storage[sid].visible)
					//flag = false;
			}	
		}
		
		override public function click():Boolean {
			
			if (!clickable || id == 0) return false;
			
			if (App.user.mode == User.OWNER)
			{
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
					if (hasProduct)
					{
						var price:Object = { };
						price[Stock.FANTASY] = 1;
								
						if (!App.user.stock.checkAll(price))	return false;
						
						// Отправляем персонажа на сбор
						App.user.hero.addTarget( {
							target:this,
							callback:storageEvent,
							event:Personage.HARVEST,
							jobPosition:findJobPosition()
						});
						
						ordered = true;
						
						return true;
					}
					
					openProductionWindow();
				}
			}
			else
			{
				if (!hasFreeTable())
				{
					if (App.social != 'PL')
					{
						if (App.data.storage[sid].visible) 
						{
							new SimpleWindow( {
								label:SimpleWindow.BUILDING,
								sID:sid,
								title:Locale.__e('flash:1382952379847'),
								buttonText:Locale.__e('flash:1382952379850'),
								ok:function():void {
									sendInvite(App.owner.id);
								},
								text:Locale.__e('flash:1382952379852')
							}).show(); 
						}
					}
				}
				else
				{
					if (level >= totalLevels) {
						new ShareGuestWindow({
							target:this,
							kickEvent:kickEvent
						}).show();
					}
				}
			}
			
			return true;
		}
		
		override public function onStorageEvent(error:int, data:Object, params:Object):void {
			
			if (error)
			{
				Errors.show(error, data);
				return;
			}
			
			ordered = false;
			hasProduct = false;
			crafting = false;
			fID = 0;
			crafted = 0;
			
			var bonus:Object = { };
			bonus[formula.out] = { 1:formula.count };
			if (App.data.storage[formula.out].hasOwnProperty('experience') && App.data.storage[formula.out].experience > 0)
			{
				bonus[Stock.EXP] = { 1:App.data.storage[formula.out].experience};
			}
			
			var destObject:Object = {
				target:this,
				sIDs:[]
			}
			
			for(var _sID:* in info.kicks)
				destObject.sIDs.push(_sID);
			
			Treasures.bonus(bonus, new Point(this.x, this.y), destObject);
			//flag = false;
			
			
			var items_sID:uint = destObject.sIDs[0];
			for (var i:* in bonus[items_sID])
				items += bonus[items_sID][i];
		}
		
		public function tablesCount():int {
			var count:int = 0; 
				
			var tables:Array = Map.findUnitsByType(['Table']);
			for (var i:int = 0; i < tables.length; i++) {
				if(tables[i].level >= tables[i].totalLevels)
					count += tables[i].info.count;
			}
			
			return count;
		}
		
		public function guestsCount():int {
			var count:int = 0;
			var tables:Array = Map.findUnitsByType(['Table']);
			for each(var table:Table in tables)
			{
				if(table.level >= table.totalLevels)
					count += table.guestsCount;
			}
			
			return count;
		}
		
		private var selectedTable:Table = null;
		public function hasFreeTable():Boolean {
			selectedTable = null;
			var tables:Array = Map.findUnitsByType(['Table']);
			
			var maxGuests:int = 0;
			
			for (var i:int = 0; i < tables.length; i++) {
				if (tables[i].level < tables[i].totalLevels) 
					continue;
					
				var count:int = tables[i].guestsCount;
				
				if (count >= maxGuests && count < tables[i].info.count){
					maxGuests = count;
					selectedTable = tables[i];
				}	
			}
			
			if (selectedTable == null)
				return false;
			else
				return true;
		}
		
		//public override function kickEvent(mID:uint, callback:Function, boost:int = 0, _sendObject:Object = null):void {
			//
			//selectedTable.addGuest(App.user.id); 
			//
			//var sendObject:Object = {
				//tID:selectedTable.id,
				//tsID:selectedTable.sid
			//}
			//
			//super.kickEvent(mID, callback, boost, sendObject);
		//}
		
		override public function openProductionWindow(settings:Object = null):void {
			
			/*new BarWindow( {
				title:			info.title,
				crafting:		info.crafting,
				target:			this,
				onCraftAction:	onCraftAction,
				height:			650,
				hasPaginator:	true,
				hasButtons:		true
			}).show();*/
		}
		
		/*public override function set crafting(value:Boolean):void
		{
			_crafting = value;
			if (smokeAnimations.length == 0) return;
			
			if (_crafting) {
				for each(var anime:Anime in smokeAnimations) {
					anime.bitmap.visible = true;
				}	
			}
			else
			{
				for each(var _anime:Anime in smokeAnimations) {
					_anime.bitmap.visible = false;
				}	
			}
		}*/
		
		override public function beginAnimation():void 
		{
			startAnimation();
				
			//startSmoke();
			
			/*if (crafted == 0) {
				crafting = false;
			}*/
		}
	}
}