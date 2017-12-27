package units 
{
	import core.Post;
	import flash.geom.Point;
	import wins.ConstructWindow;
	import wins.SimpleWindow;
	import wins.TechnologicalWindow;
	public class Technological extends Share 
	{
		public var technologies:Object = {};
		public var prizes:Object = {};
		
		public function Technological(settings:Object) 
		{
			super(settings);
			
			removable = false;
			
			for (var i:String in info.devel.tech[1]) {
				if (settings.technology) technologies[info.devel.tech[1][i]] = settings.technology[info.devel.tech[1][i]];
				if (!technologies[info.devel.tech[1][i]]) technologies[info.devel.tech[1][i]] = 0;
				
				if (settings.tlevel) prizes[info.devel.tech[1][i]] = settings.tlevel[info.devel.tech[1][i]];
				if (prizes[info.devel.tech[1][i]] == undefined) prizes[info.devel.tech[1][i]] = -1;
			}
		}
		
		override public function onLoad(data:*):void
		{
			super.onLoad(data);
				
			if (level == totalLevels)
				touchableInGuest = true;
				
			updateLevel();
		}
		
		override public function checkOnAnimationInit():void {			
			if (textures && textures['animation'] && level >= totalLevels) {
				initAnimation();				
				beginAnimation();
			}
		}
		
		override public function beginAnimation():void 
		{
			if (textures.animation != null && level >= totalLevels)
			{
				startAnimation();
			}			
		}
		
		override public function click():Boolean 
		{
			/*if (App.user.mode == User.GUEST && level < totalLevels) {
				new SimpleWindow( {
					title:info.title,
					label:SimpleWindow.ATTENTION,
					text:Locale.__e('flash:1409298573436')
				}).show();
				return true;
			}*/
			
			if (!clickable || id == 0) return false;
			
			if (App.user.mode == User.GUEST) {
				guestClick();
				return true;
			}
			
			if (!isReadyToWork()) return true;
			
			if(App.user.mode == User.OWNER){
				if (isPresent()) return true;
			}
			
			if (level < totalLevels) {
				if(App.user.mode == User.OWNER){
					new ConstructWindow( {
						title			:info.title,
						upgTime			:info.devel.req[level + 1].t,
						request			:info.devel.obj[level + 1],
						target			:this,
						onUpgrade		:upgradeEvent,
						reward          :info.devel.rew[level + 1],
						hasDescription	:true
					}).show();
				}
			}
			else
			{
				if (App.user.mode == User.OWNER)
				{
					new TechnologicalWindow( {
						target:this,
						title:info.title,
						description:info.description,
						technologies:info.devel.tech[1],
						kickEvent:onKick
					}).show();
					return true;
				}
			}
			
			return true;
		}
		
		public function onKick(mID:uint, tID:uint, callback:Function, type:int = 1, _sendObject:Object = null, count:int = 1):void {
			var item:Object = App.data.storage[mID];
			switch(type) {
				case 1:
					if (!App.user.friends.takeGuestEnergy(App.owner.id)) 
						return;
					break;
				case 2:
					if (!App.user.stock.take(Stock.FANT, item.price[Stock.FANT])) 
						return;
					break;
				case 3:
					if (!App.user.stock.take(mID, count))
						return;
					break;
			}
			
			var self:Share = this;
			var sendObject:Object = { };
			if (App.owner) {
				sendObject = {
					ctr:info.type,
					act:'kick',
					uID:App.owner.id,
					wID:App.owner.worldID,
					sID:this.sid,
					id:this.id,
					guest:App.user.id,
					mID:mID,
					tID:tID
				}
			}
			
			if (_sendObject != null)
				for (var _item:* in _sendObject)
					sendObject[_item] = _sendObject[_item];
					
			sendObject['ctr'] = info.type;
			sendObject['sID'] = this.sid;
			sendObject['id'] = this.id;
			sendObject['mID'] = mID;
			sendObject['tID'] = tID;
		
			Post.send(sendObject,
			function(error:int, data:Object, params:Object):void 
			{
				if (error) {
					
					if (error == 31) {
						uninstall();
						new SimpleWindow( {
							label:SimpleWindow.ATTENTION,
							text:Locale.__e(info.title),
							forcedClosing:true
						}).show();
						if(type == 1){
							App.user.friends.addGuestEnergy(App.owner.id);
						}
						
						return;
					}
					
					Errors.show(error, data);
					return;
				}
				
				var bonus:Object = { };
				if (data.hasOwnProperty('bonus'))
					bonus = data.bonus;
					
				var treasure:Object = { };
				if (data.hasOwnProperty('treasure'))
					treasure = data.treasure;
								
				if (data.hasOwnProperty("energy") && data.energy > 0)
					App.user.friends.updateOne(App.owner.id, "energy", data.energy);
					
				/*if (data.hasOwnProperty('bonus'))
					Treasures.bonus(data.bonus, new Point(self.x, self.y));*/
					
				self = null;
				
				if (type == 1)
				{
					App.user.friends.giveGuestBonus(App.owner.id);
					guests[App.user.id] = App.time;	
				}
				
				technologies[tID] += App.data.storage[tID].kicks[mID].c;
				if (data.hasOwnProperty('kicks'))
					technologies[tID] = data.kicks;
				
				refresh();
				
				callback(bonus, treasure);
			});
		}
		
		override public function storageAction(tID:uint, callback:Function):void {
			
			var self:Share = this;
			var sendObject:Object = {
				ctr:this.type,
				act:'storage',
				uID:App.user.id,
				wID:App.user.worldID,
				sID:this.sid,
				id:this.id,
				tID:tID
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
				
				var treasure:Object = { };
				if (data.hasOwnProperty('treasure'))
					treasure = data.treasure;	
				
				if (data.hasOwnProperty('kicks'))
					technologies[tID] = data.kicks;
					
				var points:Array = [];
				var info:Object = App.data.storage[tID];
				for (var itm:String in info.devel.point) {
					points.push(info.devel.point[itm]);
				}
				/*if (technologies[tID] == points[points.length - 1]) {
					technologies[tID] = 0;
					prizes[tID] = -1;
				}*/
					
				callback(Stock.FANT, 0, bonus, treasure);
				
				if (data.hasOwnProperty(Stock.FANT))
					App.user.stock.data[Stock.FANT] = data[Stock.FANT];
				
				/*if (data.hasOwnProperty('bonus'))
					Treasures.packageBonus(data.bonus, new Point(self.x, self.y));*/

				
				/*if (info.burst == BURST_ONLY_ON_COMPLETE)
				{
					free();
					changeOnDecor();
					take();
				}else if (info.burst == BURST_ON_TIME) {
					floor = 0;
					kicks = 0;
					totalFloors = 1;
					kicksLimit = info.tower[totalFloors].c;
				}else{
					uninstall();
				}*/
				
				self = null;
			});
		}
		
		override public function remove(_callback:Function = null):void {
			if ([835].indexOf(int(sid)) != -1) {
				var data:int = int(App.user.storageRead('building_' + sid, 0));
				if (data > 0) data -= 1;
				App.user.storageStore('building_' + sid, data, true);
			}
			
			super.remove(_callback);
		}
		
	}

}