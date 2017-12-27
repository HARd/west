package  
{
	import flash.events.EventDispatcher;
	import api.ExternalApi;
	import core.Post;
	import flash.events.Event;
	public class Invites extends EventDispatcher
	{		
		public var data:Object;
		public var random:Array = [];
		public var invited:Object = {}; //меня пригласили
		public var requested:Object = {}; //я пригласил
		public var searched:Object = {}; //я пригласил
		/*public var randomProfiles:Object = {};
		public var invitedProfiles:Object = {};
		public var requestedProfiles:Object = {};*/
		public var inited:Boolean = false;
		
		public function Invites() 
		{
			
		}
		
		public function init(callback:Function):void {
			if (App.isSocial('FB')) return;
			if (inited) {
				callback();
				return;
			}
			
			Post.send({
				'ctr':'invites',
				'act':'get',
				'uID':App.user.id
			}, function(error:*, response:*, params:*):void {
				if (!error) {
					var _random:Object = response['random'];
					var fid:*;
					if(response['random']){
						for each(fid in response['random']) {
							random.push(fid);
						}
					}
					invited = response['invited'] || { };
					requested = response['requested'] || { };
					inited = true;
					
					dispatchEvent(new Event(Event.CHANGE));
					
					/*ExternalApi.getUsersProfile(random, function(profiles:Object):void {
						inited = true;
						for each(var friend:Object in profiles) {
							if (invited[friend.uid] != undefined) {
								invitedProfiles[friend.uid] = friend;
							}else if (requested[friend.uid] != undefined) {
								requestedProfiles[friend.uid] = friend;
							}else {
								randomProfiles[friend.uid] = friend;
							}	
						}
						if(callback != null){
							callback();
						}
					});*/
				}
			});
		}
		
		public function invite(fID:String, callback:Function):void {
			
			Post.send({
				'ctr':'invites',
				'act':'invite',
				'uID':App.user.id,
				'fID':fID
			}, function(error:*, response:*, params:*):void {
				if (!error) {
					for (var i:int = 0; i < random.length; i++) {
						if (random[i]['_id'] == fID) {
							invited[fID] = random[i];
							invited[fID]['time'] = App.time;
							break;
						}
					}
					if (searched.hasOwnProperty(fID)) {
						invited[fID] = searched[fID];
						invited[fID]['time'] = App.time;
					}
					callback();
					
					dispatchEvent(new Event(Event.CHANGE));
				}
			});
			
		}
		
		public function accept(fID:String, callback:Function):void {
			
			Post.send({
				'ctr':'invites',
				'act':'accept',
				'uID':App.user.id,
				'fID':fID
			}, function(error:*, response:*, params:*):void {
				if (!error) {
					App.user.friends.addFriend(fID, response.friend);
					delete requested[fID];
					callback();
					
					dispatchEvent(new Event(Event.CHANGE));
				}
			});
			
		}
		
		public function reject(fID:String, callback:Function):void {
			
			Post.send({
				'ctr':'invites',
				'act':'reject',
				'uID':App.user.id,
				'fID':fID
			}, function(error:*, response:*, params:*):void {
				if (!error) {
					
					if (requested.hasOwnProperty(fID)) {
						delete requested[fID];
					}
					if (invited.hasOwnProperty(fID)) {
						if (invited[fID].time == 0 && App.user.friends.data.hasOwnProperty(fID)) {
							delete App.user.friends.data[fID];
						}
						delete invited[fID];
					}
					if (App.user.friends.hasFriends(fID)) {
						App.user.friends.removeFriend(fID);
					}
					callback();
					
					dispatchEvent(new Event(Event.CHANGE));
				}
			});
			
		}
		
		public function search(fID:String, callback:Function):void {
			if (searched.hasOwnProperty(fID)) {
				callback(searched[fID]);
				return;
			}
			
			Post.send( {
				ctr:	'invites',
				act:	'search',
				uID:	App.user.id,
				fID:	fID
			}, function(error:*, response:*, params:*):void {
				if (!error) {
					if (response.friend) {
						searched[fID] = response.friend;
					}
					callback(response.friend);
				}
			});
		}
		
		public function canInvite(fID:String):Boolean {
			if (fID == App.user.id || invited.hasOwnProperty(fID) || requested.hasOwnProperty(fID) || App.user.friends.hasFriends(fID))
				return false;
			
			return true;
		}
		
		public static function get externalPermission():Boolean {
			
			if (App.user.id == '' || App.isSocial('YB','FB','YN','MX','YN','AI','GN'))
				return true;
			
			return false;
		}
		
		public static function postAboutInvite(fID:String):void
		{
			Post.send( {
					ctr:'user',
					act:'setinvite',
					uID:App.user.id,
					fID:fID
				},function(error:*, data:*, params:*):void {
					if (error) {
						Errors.show(error, data);
						return;
					}
				});
		}
	}

}