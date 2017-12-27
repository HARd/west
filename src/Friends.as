package  
{
	import api.ExternalApi;
	import api.VKApi;
	import astar.AStarNodeVO;
	import core.Log;
	import core.Post;
	import flash.external.ExternalInterface;
	import flash.geom.Point;
	import units.Field;
	import units.Guest;
	import units.Hero;
	import units.Personage;
	import units.Treasure;
	import units.Unit;
	import wins.RewardWindow;
	import wins.SimpleWindow;
	import wins.WindowEvent;
	public class Friends
	{
		public var bragFriends:Array = [];
		
		public var data:Object;
		public var keys:Array = [];
		
		public function Friends(friends:Object, emptyIDs:Array = null) {
			
			
			
			data = friends;
			var bear:Object = { };
			for each(var item:Object in data) {
				if (item.uid != "1") {
					keys.push( { uid:item.uid, level:item.level } );
				}else {
					item.first_name = Locale.__e('flash:1382952379733');//'Хранитель'
					item.photo = Config.getImageIcon('characters','Merry');
					bear = { uid:item.uid, level:item.level };
				}
				if (App.time <= item.gift) Gifts.takedFreeGift.push(item.uid);
			}
			keys.sortOn("level", Array.NUMERIC | Array.DESCENDING);
			
			
			if (App.isSocial('YB','MX','GN')) 
			{
				var emptyIDs:Array = [];
				for(var fID:String in data) {
					if (App.network.appFriends.indexOf(fID) == -1) {
						if (fID == '1') continue;
						emptyIDs.push(fID);
					}
				}
				
				ExternalApi.getUsersProfile(emptyIDs, function(response:Object):void {				
					for (var fID:String in response) {
						if (data[fID] != undefined) {
							for (var p:String in response[fID]) {
								data[fID][p] = response[fID][p];
							}
						}
					}
					if (App.ui != null && App.ui.bottomPanel != null) {
						App.ui.bottomPanel.friendsPanel.searchFriends();
					}
				});
			}
		}
		
		public function showHelpedFriends():void {
			var helpersCount:int =  App.data.options['MaxHelpers'] || 10;
			
			for each(var item:Object in data)
			{
				if (helpersCount > 0 && item['helped'] != undefined && item.helped > 0) {
					helpersCount--;
					installHelpedFriend(item);
				}
			}
		}
		
		public function checkOnLoad():Boolean {
			if (data[keys[keys.length - 1].uid].hasOwnProperty('first_name'))
				return true;
			return false;
		}
		
		public function installHelpedFriend(friend:Object):void {
			return;
			var tries:int = 100;
			//Делаем не больше 100 попыток найти свободное место
			while(tries>0){
				var randX:int = 10 + Math.random() * 30;
				var randZ:int = 10 + Math.random() * 30;
				var node:AStarNodeVO = App.map._aStarNodes[randX][randZ];
				
				if (node.b == 0 && node.p == 0) {
					new Guest(friend, {sid:Personage.HERO,x:randX,z:randZ});
					return;
				}
				tries--;
			}
		}
		
		public function get count():uint {
			var i:int = 0;
			for (var item:* in data) {
				i++;
			}
			return i;
		}
		
		public function uid(uid:String):Object {
			return data[uid];
		}
		
		public var showAttention:Boolean = true;
		public var paidEnergy:Boolean = false;
		public function takeGuestEnergy(uid:String):Boolean {
			paidEnergy = false;
			
			if ((App.user.friends.data[uid].lastvisit + App.data.options['LastVisitDays']) < App.time && App.isSocial('VK','DM','OK','FS','ML','NK','FB') && uid != '1') {
				if ((App.user.friends.data[uid].alert + App.data.options['alerttime']) > App.time) {
					new SimpleWindow( {
						title: Locale.__e('flash:1382952379893'),
						text: Locale.__e('flash:1449654596563'),
						textSize: 32
					}).show();
				} else {
					new SimpleWindow( {
						title: Locale.__e('flash:1382952379893'),
						text: Locale.__e('flash:1435130693238'),
						buttonText: Locale.__e('flash:1406634917036'),
						showBonus:true,
						textSize: 32,
						confirm: function():void {
							App.self.sendPostWake();
						}
					}).show();
				}
				return false;
			} 
			
			if (energyLimit <= 0) {
				if(App.user.stock.count(Stock.GUESTFANTASY)<=0 && showAttention){
					new SimpleWindow( {
						label:SimpleWindow.ATTENTION,
						title:Locale.__e("flash:1382952379725"),
						text:Locale.__e("flash:1382952379734")
					}).show();
					
					showAttention = false;
				}
				
				if(App.user.stock.take(Stock.GUESTFANTASY, 1)){
					paidEnergy = true;
					return true;
				}
				
				return false;
			}
			
			if (data[uid]['energy'] > 0 && data[uid]['energy'] < 6) {
				data[uid]['energy']--;
				App.user.stock.add(Stock.COUNTER_GUESTFANTASY, 1);
				if (data[uid]['fill'] == undefined || data[uid]['fill'] == 0) {
					data[uid]['fill'] = App.midnight + 24 * 3600;
				}
				App.ui.leftPanel.showGuestEnergy();
				App.ui.leftPanel.updateGuestReward();
				return true;
			}else {
				if(App.user.stock.take(Stock.GUESTFANTASY, 1)){
					paidEnergy = true;
					return true;
				}
				
			}
			
			return false;
		}
		
		public function giveGuestBonus(uid:String):void {
			if (data[uid]['energy'] == 0 && !paidEnergy) {
				
				App.user.onStopEvent();
				
				Post.send( {
					ctr:'user',
					act:'guest',
					uID:App.user.id,
					fID:uid
				}, onGuestBonusEvent, { uid:uid } );
				
				App.ui.bottomPanel.bttnMainHome.showGlowing();
			}
		}
		
		private function onGuestBonusEvent(error:*, result:*, params:Object):void {
			
			if (error) {
				Errors.show(error, data);
				return;
			}
			
			if (!error && result) {
				
				if (!result.hasOwnProperty('guestBonus')) 
					return;
				
				var bonus:Object = {};
				for (var sID:* in result.guestBonus) {
					var item:Object = result.guestBonus[sID];
					for(var count:* in item)
					bonus[sID] = count * item[count];
				}
				
				App.user.stock.addAll(bonus);
				
				new RewardWindow( { bonus:bonus} ).show();
			}
			else
			{
				Errors.show(error, data);
			}
			
		}
		
		private function onAddTargetEvent(e:WindowEvent):void {
			e.target.removeEventListener(WindowEvent.ON_AFTER_CLOSE, onAddTargetEvent);
			var result:Object = e.target.params;
			
			Treasures.bonus(result.guestBonus, new Point(result.unit.x, result.unit.y));
		}
		
		public function addGuestEnergy(uid:String):void {
			if (data[uid]['energy'] > 0 && data[uid]['energy'] < 6) {
				data[uid]['energy']++;
				App.ui.leftPanel.showGuestEnergy();
			}else {
				data[uid]['energy'] = 1;
				App.ui.leftPanel.showGuestEnergy();
			}
		}
		
		public function updateOne(uid:String, field:String, value:*):void {
			if (data[uid]) {
				data[uid][field] = value;
			}
		}
		
		public function get energyLimit():int {
			var limit:int = App.data.options['VisitLimit'] || 100;
			
			for each(var item:Object in data) {
				limit -= 5 - (item.energy > 0?item.energy:0);
			}
			
			if (limit <= 0) {
				for each(item in data) {
					item.energy = 0;
				}
			}
			return limit;
		}
		
		public function hasFriends(id:*):Boolean {
			if (data.hasOwnProperty(id)) return true;
			
			return false;
		}
		
		public function removeFriend(id:*, update:Boolean = true):void {
			if (data.hasOwnProperty(id)) {
				delete data[id];
			}
			if (update) {
				App.ui.bottomPanel.friendsPanel.searchFriends();
				App.ui.bottomPanel.friendsPanel.resize();
			}
		}
		
		public function addFriend(id:*, info:Object, update:Boolean = true):void {
			if (data.hasOwnProperty(id)) return;
			data[id] = info;
			
			if (update) {
				App.ui.bottomPanel.friendsPanel.searchFriends();
				App.ui.bottomPanel.friendsPanel.resize();
			}
		}
		
		public function get ingameFriendList():Array {
			var list:Array = [];
			for (var uid:String in data) {
				if (uid == '1') continue;
				list.push(uid);
			}
			return list;
		}
		
		public static function registerFriend(uid:*):void {
			
			Log.alert('INVITED FRIENDS');
			Log.alert(typeof(uid));
			
			if (App.isSocial('FB')) {
				for each (var id:* in uid.to) {
					send(id.toString());
				}
				return;
			}
			
			if (uid is Object) {
				send(uid.toString());
			}else if ((uid is String) || !isNaN(int(uid))) {
				send(uid);
			}else if ((uid is Array)) {
				send(uid.toString());
			}
			
			/*if (App.isSocial('DM','VK'))
				ExternalApi.apiWallPostEvent(1, new Bitmap(Window.textures.theGame), String(uid), Locale.__e('flash:1382952380111', [Config.appUrl]));*/
			
			function send(uid:*):void {
				Log.alert('SEND FRIEND ID' + uid);
				if (App.user.socInvitesFrs.hasOwnProperty(uid)) {
					Log.alert('Уже такой есть!');
					return;
				}
				
				Post.send( {
					ctr:'user',
					act:'setinvite',
					uID:App.user.id,
					fID:uid
				},function(error:*, data:*, params:*):void {
					if (error) {
						Errors.show(error, data);
						return;
					}
				});
			}
		}	
	}

}