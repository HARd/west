package api 
{
	import core.Log;
	import flash.utils.setTimeout;
	import vk.APIConnection;
	import vk.events.*;
	
	
	/**
	 * ...
	 * @author ...
	 */
	public class VKApi 
	{
		private var flashVars:Object;
		private var VK:APIConnection;
		private var userID:*;
		private var onNetworkComplete:Function = null;
		private var data:Object;
		
		public function VKApi(flashVars:Object, data:Object, onNetworkComplete:Function = null)
		{
			this.onNetworkComplete = onNetworkComplete;
			this.flashVars = flashVars;
			this.data = data;
			userID = flashVars['viewer_id'];
			VK = new APIConnection(flashVars);
			init();
		}
		
		private  function onApiRequestFail(data:Object): void 
		{
			trace("Error: " + data.error_msg);
		}
		
		public function init():void 
		{
			getFriendsData();
		}
		
		private function chunk(array:Array, chunkSize:int):Array {
			var R:Array = [];
			for (var i:int=0; i<array.length; i+=chunkSize)
				R.push(array.slice(i,i+chunkSize));
			return R;
		}
		
		private function takeFriends():void
		{
			var uids:Array = paths[pathID];
			pathID ++;
			counter ++;
			VK.api('execute',{
				code:'return {"profile" : API.getProfiles({"uids":['+uids.join(',')+'],"fields":"uid,first_name,last_name,photo,sex"})};', test_mode:Config.testMode
			}, friendsReady, onError);	
		}
		
		private var pathID:int = 0;
		private var counter:int = 0;
		private var paths:Array = [];
		private function getFriendsData():void
		{
			if(data.appFriends.length > 0){
				paths = chunk(data.appFriends, 400);
				Log.alert(paths);
				takeFriends();
			}else {
				getOtherFriends();
			}
		}
		
		private function onError(json:Object):void {
			Log.alert('--onError '+json);
		}

		private var friends:Object = [ ];
		private function friendsReady(json:Object):void {
			Log.alert('friendsReady');
			//Log.alert(json.profile);
			//addFriends(json.profile);
			friends = friends.concat(json.profile);
			Log.alert(friends.length +" / "+ data.appFriends.length);
			//if (App.ui.bottomPanel) App.ui.bottomPanel.changeFriendsLoadProgress(friends.length / data.appFriends.length);
			
			Log.alert('pathID '+pathID+'  counter '+counter);
			if (paths[pathID] != null) {
				Log.alert(counter % 3);
				if (counter % 3 == 0) {
						Log.alert('--TIMEOUT--');
						setTimeout(takeFriends, 1000);
				}else {
					Log.alert('takeFriends');
					takeFriends();
				}
			}
			else
			{
				//allFriendsLoad();
				getOtherFriends();
			}
		}
		
		private function addFriends(friends:Array):void {
			var _length:int = friends.length;
			
			for (var i:int = 0; i < _length; i++) {
				var fID:String = friends[i].uid;
				
				if (App.user.friends.data[fID] != undefined) {
					for (var key:* in friends[i]) {
						App.user.friends.data[fID][key] = friends[i][key];
					}
				}
			}
		}
		
		private function allFriendsLoad():void {
			//if (App.ui.bottomPanel) App.ui.bottomPanel.friendsComplete();
		}
		
		private function getOtherFriends():void {
			
			onComplete();
			//Log.alert('otherFriends');
				//if (data.otherFriends.length == 0) {
					//onComplete();
				//}
				//else
				//{
					//VK.api('execute',{
						//code:'return {"profile" : API.getProfiles({"uids":['+data.otherFriends.join(',')+'],"fields":"uid,first_name,last_name,photo,sex"})};', test_mode:Config.testMode
					//}, profilesReady, onError);	
				//}
			
		}
		
		private var otherFriends:Object = { };
		private function profilesReady(json:Object):void
		{
			otherFriends = new Object();
			Log.alert("Api  profilesReady   " + json);
			if (!(json.profile && json.profile is Array))
				return;
			
			for(var id:* in json.profile){
				var friend:Object = json.profile[id];
			
				otherFriends[friend["uid"]] = {
					"uid"           : friend["uid"],
					"first_name"    : friend["first_name"],
					"last_name"     : friend["last_name"],
					"photo"	        : friend["photo"],
					"url"  			: "http://vk.com/id" + friend["uid"],
					"sex"           : friend["sex"] == 2 ? "m" : "f"
				};
			}
			
			onComplete()
		}
		
		private function onComplete():void {
			
			//data['otherFriends'] = otherFriends;
			data['friends'] = friends;
			
			if(onNetworkComplete != null)
				onNetworkComplete(data);
		}
	}	
}