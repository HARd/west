package api
{
	import api.com.odnoklassniki.core.*;
	import api.com.odnoklassniki.events.*;
	import api.com.odnoklassniki.Odnoklassniki;
	import api.com.odnoklassniki.net.*;
	import api.com.odnoklassniki.sdk.users.Users;
	import api.com.odnoklassniki.sdk.friends.Friends;
	import api.com.odnoklassniki.sdk.photos.Photos;
	import core.Load;
	import core.Log;
	import core.Post;
	import flash.system.Security;
	import flash.utils.setTimeout;
	import flash.events.Event;
	
	
		
	public class OKApi
	{
			
		public var flashVars:Object;
		public var profile:Object = { };
		public var appFriends:Array = [];
		public var allFriends:Array = [];
		public var friends:Object = { };
		public var otherFriends:Object = null;
		public var wallServer:String;
		public var albums:Object;
		public var mainAlbum:Object;
		
		private var queue:Vector.<Array> = new Vector.<Array>;
		private var executing:Boolean = false;
		
		public var friendsData:Array = new Array();

		public var usersUids:Array = new Array();
		
		private var album:String = null;
		
		private var apiObject:Object;
		private var callback:Function = null;
		private var wallPostObject:Object = null;
		
		public var callsLeft:int = 0;
		
		public var dictionary:Object = {
			0: function(sID:uint):Object {
					return{
						title:'',//App.data.storage[sID].title,
						url:Config.getIcon(App.data.storage[sID].type, App.data.storage[sID].preview)
					}
			},
			1: function(e:* = null):Object {
					return{
						title:Locale.__e("flash:1382952379697"),
						url:Config.getImage('mail', 'zone')
					}
			},
			2: function(sID:uint):Object {
					return{				
						title:Locale.__e("flash:1382952379698"),
						//url:Config.getIcon(App.data.storage[sID].type, App.data.storage[sID].preview)
						url:Config.getImage('mail', 'promo', 'jpg')
					}
			},
			3: function(sID:uint):Object {
					return{								
						title:Locale.__e("flash:1382952379699"),
						//url:Config.getIcon(App.data.storage[sID].type, App.data.storage[sID].preview)
						url:Config.getImage('mail', 'promo', 'jpg')
					}
			},
			4: function(sID:uint):Object {
					return{								
						title:Locale.__e("flash:1382952379700"),
						//url:Config.getIcon(App.data.storage[sID].type, App.data.storage[sID].preview)
						url:Config.getImage('mail', 'promo', 'jpg')
					}
			},
			5: function(sID:uint):Object {
					return{								
						title:Locale.__e("flash:1382952379701"),
						//url:Config.getIcon(App.data.storage[sID].type, App.data.storage[sID].preview)
						url:Config.getImage('mail', 'promo', 'jpg')
					}
			},
			6: function(sID:uint):Object {
					return{								
						title:Locale.__e("flash:1382952379702"),
						url:Config.getImage('mail', 'promo', 'jpg')
					}
			},
			7: function(qID:uint):Object {
					return{				
						title:Locale.__e(App.data.quests[qID].description),
						//url:Config.getQuestIcon('icons', App.data.personages[App.data.quests[qID].character].preview)
						url:Config.getImage('mail', 'promo', 'jpg')
					}	
			},
			8: function(sID:uint):Object {
					return{				
						title:Locale.__e("flash:1382952379703"),
						url:Config.getImage('mail', 'level', 'png')
					}
			},
			9: function(sID:uint):Object {
					return{				
						title:Locale.__e("flash:1398776058888", [App.data.storage[sID].title]),
						//url:Config.getIcon(App.data.storage[sID].type, App.data.storage[sID].preview)
						url:Config.getImage('mail', 'promo', 'jpg')
					}
			}
		}
	
		/**
		 * Конструктор
		 * @param	flashVars	переменные Одноклассники
		 */
		public function OKApi(flashVars:Object)
		{
			this.flashVars = flashVars;
			Log.alert('OKApi');
			Console.addLoadProgress('OK: Connect to OKApi');
			Odnoklassniki.initialize(App.self.stage, Config.OK.secret_key);
			Odnoklassniki.addEventListener(ApiServerEvent.CONNECTED, onConnect);
			Odnoklassniki.addEventListener(ApiServerEvent.CONNECTION_ERROR, onErrorConnection);
			Odnoklassniki.addEventListener(ApiServerEvent.PROXY_NOT_RESPONDING, onErrorConnection);
			Odnoklassniki.addEventListener(ApiServerEvent.NOT_YET_CONNECTED, onErrorConnection);
			Odnoklassniki.addEventListener(ApiCallbackEvent.CALL_BACK, onApiCallback);
			
			Odnoklassniki.setWindowSize(0, 850);
			//execute();
		}
		
		public function addQueue(callback:Function, params:Object=null):void {
			queue.push([callback,params]);
			
			execute();
		}
		
		public function execute():void {
			if (queue.length > 0 && !executing) {
				executing = true;
				var queueItem:Object = queue.shift();
				
				var callback:Function = queueItem[0];
				var params:Object = queueItem[1];
						
				setTimeout(function():void{callback(params)}, 200);
			}
			else if (queue.length == 0 && !executing) 
			{
				Log.alert('execute');
				App.self.onNetworkComplete(this);
			}
		}
		
		private function onConnect(e:ApiServerEvent):void {
			trace('Connect successfull');
			Console.addLoadProgress('OK: Connect successfull');
			Log.alert('Connect successfull');
			
			addQueue(getCurrentUser);
			addQueue(getAppUsers);
			addQueue(getAllFriends);
			addQueue(getAlbums);
			//setTimeout(getCallsLeft, 2000);
		}
		
		private function onErrorConnection(e:ApiServerEvent):void {
			trace('Cannot connect');
			Console.addLoadProgress('ERROR: Cannot connect');
			Console.addLoadProgress('type '+ e.type);
			Log.alert('Cannot connect');
		}
		
		private function onApiCallback(e:ApiCallbackEvent):void {
			
			if (callback != null)
				callback(e);
				
			callback = null;	
			Log.alert('onApiCallback!!:');
			Log.alert(e.method);
			Log.alert(e.data);
			Log.alert(e.result);
			Log.alert('----');
			
			switch(e.method) {
				case 'showInvite':
					if (showInviteCallback != null)
						showInviteCallback(e.data);
					
					break;
			}
			
			if (e.data.indexOf('amount') != -1) {
				setTimeout(refreshMoney, 2000);
			}
		}
		
		public static var showInviteCallback:Function = null;
		
		public function refreshMoney():void {
			Post.send( {
				'ctr':'stock',
				'act':'balance',
				'uID':App.user.id
			}, function(error:*, result:*, params:*):void {
				if(!error && result){
					for (var sID:* in result){
						App.user.stock.put(sID, result[sID]);
					}
				}
			});	
		}
		
		public function getCurrentUser(params:Object=null):void {
			Log.alert('getCurrentUser');
			Console.addLoadProgress("OK: users.getInfo");
			Odnoklassniki.callRestApi('users.getInfo', function(userdata:Array):void {
				Log.alert('onGetCurrentUser');
				Console.addLoadProgress('OK: users.getInfo complete');
				Log.alert(userdata);
				for each(var user:* in userdata){
					profile['first_name'] 	= user.first_name;
					profile['last_name'] 	= user.last_name;
					profile['sex'] 			= user.gender == 'male'?'m':'f';
					profile['photo'] 		= user.pic_1;
					
					if(user.location != undefined){
						profile['country'] 		= user.location.country || '';
						profile['city'] 		= user.location.city || '';
					}
					
					var year:* = 0;
					if(user.birthday != undefined){
						var bdata:Array = user.birthday.split('-');
						if (bdata[0] != undefined && String(bdata[0]).length == 4) {
							year = bdata[0];
						}
					}
					
					profile['year']			= year;
					break;
				}
				executing = false;
				execute();
			}, { uids:flashVars['viewer_id'], fields:'first_name,last_name,name,gender,pic_1,birthday,location' }, "JSON", "POST");
		}
		
		public function getAppUsers(params:Object=null):void {
			
			Log.alert('OKApi.getAppUsers');
			Console.addLoadProgress("OK: friends.getAppUsers");
			Odnoklassniki.callRestApi('friends.getAppUsers', function onGetAppUsers(uids:Object):void {
				
				//uids['uids'] = [332284649118,332487735718,455787150390,499482157747,513928183787,530843401503,551750837885,554967343970,561449794734]
				Console.addLoadProgress('OK: friends.getAppUsers complete');
				
				Console.addLoadProgress('OK: appFriends.length = '+appFriends.length);
				Log.alert('onGetAppUsers');
				Log.alert(appFriends);
				
				
				var friends:Array = uids.uids;
				if (friends.length > 0)
				{	
					while (friends.length > 100) {
						addQueue(getProfiles, { uids:friends.splice(0, 100), callback: onGetProfiles } );
					}
					addQueue(getProfiles, { uids:friends.splice(0, 100), callback: onGetProfiles  } );
				}
				
				executing = false;
				execute();
			}, {}, "JSON", "POST");
		}
		
		public function getProfiles(params:Object):void {
			var callback:Function = params.callback;
			
			Console.addLoadProgress('OK: getProfiles   uids:'+params.uids.length);
			if (params.hasOwnProperty('callback')) {
				callback = params.callback;
			}
			Odnoklassniki.callRestApi('users.getInfo', callback, { uids:params.uids.join(','), fields:'first_name,last_name,name,gender,pic_1' }, "JSON", "POST");
		}
		
		private function onGetProfiles(userdata:Array):void {
			var fID:String;
			
			Console.addLoadProgress('OK: onGetProfiles   userdata:' + userdata.length);
			for (var item:* in userdata) {
				if (item != 'method') {
					
					if (userdata[item].pic_1 == null || userdata[item].first_name == null)
						continue;
					
					fID = String(userdata[item].uid);
					appFriends.push(fID);
					friends[fID] = userdata[item];
					friends[fID]['first_name'] 	= userdata[item].first_name;
					friends[fID]['last_name'] 	= userdata[item].last_name;
					friends[fID]['sex'] 		= userdata[item].gender == 'male'?'m':'f';
					friends[fID]['photo'] 		= userdata[item].pic_1;
				}
			}
			
			executing = false;
			execute();
			
			if (queue.length == 0 && App.network == null){
				Log.alert(friends);
				App.self.onNetworkComplete(this);
			}
		}
		
		private function onGetOtherProfiles(userdata:Array):void {
			
			var fID:String;
			otherFriends = { };
			Console.addLoadProgress('OK: onGetProfiles   userdata:' + userdata.length);
			for (var item:* in userdata) {
				if (item != 'method') {
					
					if (userdata[item].pic_1 == null || userdata[item].first_name == null || friends[item])
						continue;
					
					fID = String(userdata[item].uid);
					otherFriends[fID] = userdata[item];
					otherFriends[fID]['first_name'] 	= userdata[item].first_name;
					otherFriends[fID]['last_name'] 	= userdata[item].last_name;
					otherFriends[fID]['sex'] 		= userdata[item].gender == 'male'?'m':'f';
					otherFriends[fID]['photo'] 		= userdata[item].pic_1;
				}
			}
			
			executing = false;
			execute();
			
			if (queue.length == 0 && App.network == null){
				Log.alert(friends);
				App.self.onNetworkComplete(this);
			}
		}
			
		public function getAllFriends(params:Object=null):void
		{
			Odnoklassniki.callRestApi('friends.get', function(userdata:*):void {
				Log.alert(userdata);
				
				allFriends = userdata;
				
				if (allFriends.length > 0)
				{	
					while (allFriends.length > 100) {
						addQueue(getProfiles, { uids:allFriends.splice(0, 100), callback: onGetOtherProfiles  } );
					}
					addQueue(getProfiles, { uids:allFriends.splice(0, 100), callback: onGetOtherProfiles  } );
				}
				
				
				executing = false;
				execute();
			}, { uid:flashVars['viewer_id'] }, "JSON", "POST");
		}
		
	
		public function makeScreenshot():void {
			setPermissionsOn('PHOTO CONTENT', continueMakeScreenshot);
		}
		
		public function continueMakeScreenshot(e:* = null):void 
		{
			Log.alert('continueMakeScreenshot');
			Log.alert('album '+album);
			if (album == null) {
				createAlbums();
			}else {
				Odnoklassniki.callRestApi('photosV2.getUploadUrl', onGetUploadUrl, {aid:album}, "JSON", "POST");
			}
		}
		
		public function setPermissionsOn(perm:String, _callback:Function):void {
			Odnoklassniki.callRestApi('users.hasAppPermission', onCheckPermissions, { uid:App.user.id, ext_perm:perm }, 'JSON', "POST");
			function onCheckPermissions(response:*):void {
				
				if (response == false)
				{
					callback = _callback
					Odnoklassniki.showPermissions(perm);
				}
				else
				{
					callback = null
					_callback();
				}
			}
		}
		
		public function getAlbums(params:Object=null):void {
			Odnoklassniki.callRestApi('photos.getAlbums', function(data:*):void {
				Log.alert('photos.getAlbums');
				Log.alert(data);
				for each(var item:* in data.albums) {
					if (item.title == Locale.__e("flash:1382952379705")) {
						album = item.aid;
						break;
					}
				}
				executing = false;
				execute();
			}, { uid:flashVars['viewer_id'], fid:flashVars['viewer_id'], count:100 }, "JSON", "POST");
		}
			
		public function createAlbums(params:Object=null):void {
			Odnoklassniki.callRestApi('photos.createAlbum', function(aid:*):void {
				Log.alert('photos.createAlbum');
				Log.alert(aid);
				album = aid;
				Odnoklassniki.callRestApi('photosV2.getUploadUrl', onGetUploadUrl, {aid:album, count: 1}, "JSON", "POST");
			}, { title:Locale.__e("flash:1382952379705"), type:"public" }, "JSON", "POST");
		}
		
		
		
		public function onGetUploadUrl(response:Object):void {
			Log.alert('onGetUploadUrl');
			Log.alert(response);

			if (wallPostObject != null) {
				Security.loadPolicyFile("http://up.odnoklassniki.ru/crossdomain.xml");
				Photos.upload([wallPostObject.file], function(response:Object):void { 
					for (var photo:* in response.photos) {
						Log.alert(photo);
						Odnoklassniki.callRestApi('photosV2.commit', function(response:*):void {
							Log.alert(response);
							wallPostObject = null;
						}, { photo_id:photo, token:response.photos[photo].token, comment:wallPostObject.msg }, "JSON", "POST");
					}
					Log.alert('Photos.upload complete');
				}, response.upload_url , App.user.id, album);
							
			} else {
				ExternalApi.saveScreenshot(response);
			}
			
		}
		
		private function onUploadComplete(e:Event):void {
			
		}
		
		private function onWallpostUploadResponse(e:Event):void {
			var response:Object = JSON.parse(e.currentTarget.loader.data);		
			response['caption'] = wallPostObject.msg;
			saveToAlbum(response);
			wallPostObject = null;
		}
		
		public function saveToAlbum(response:Object):void
		{
			Log.alert('saveToAlbum: '+response.photos);
			for (var photo:* in response.photos) {
				Log.alert(photo);
				Odnoklassniki.callRestApi('photosV2.commit', function(response:*):void {
						Log.alert(response);	
					}, { photo_id:photo, token:response.photos[photo].token, comment:response['caption'] }, "JSON", "POST");
				break;
			}
		}

		public function showInviteBox():void
		{
			Odnoklassniki.showInvite(Locale.__e('flash:1382952379702'));
		}
		
		
		public function getCallsLeft():void {
			return;
			Log.alert('getCallsLeft');
			//setPermissionsOn('PUBLISH TO STREAM', function():void { } );
				
			Odnoklassniki.callRestApi('users.getCallsLeft', function(response:*):void { 
				Log.alert(response);
				return;
				/*if (response[0].available == false) 
					callsLeft = 0;
				else
					callsLeft = response[0].callsLeft;
					
				Log.alert('callsLeft: '+callsLeft);	*/
					
			}, { uid:App.user.id, methods:'stream.publish'}, "JSON", "POST");
		}
		
		public function showNotification(params:Object):void {
			if (params.type == ExternalApi.ASK ||
				params.type == ExternalApi.GIFT)
				return;
				
			var obj:Object = dictionary[params.type](params.sID);
		
			Odnoklassniki.showNotification(obj.title);
		}
		
		public function wallPost(params:Object):void {
			
			Log.alert(params);
			
			//if (params.type == ExternalApi.ASK || params.type == ExternalApi.GIFT)
				//return;
			//switch(params.type) {
				//case ExternalApi.ASK:
				//case ExternalApi.GIFT:
				//case ExternalApi.FRIEND_BRAG:
				//	return;
				//break;
			//}
				
			var obj:Object = dictionary[params.type](params.sID);
			var url:String = obj.url.replace(Config.secure +  Config._resIP, "");
			
			Log.alert('wallPOST');
			Log.alert(Config.secure);
			Log.alert(Config._resIP);
			
			//Log.alert(url);
			//Log.alert(params.type);
			
			//var attach:Object = {
				//"caption":Locale.__e('flash:1408696652412'),//params.msg,
				//"media":[{"href":params.url,"src":url,"type":"image"}]
			//};
			
			wallPostObject = { 
				file: params.bytes,
				msg : params.msg + " " + params.url				
			};
			
			var callback:Function = function(response:Object):void {
				
				Log.alert('onGetUploadUrl ' + response);

				if (wallPostObject != null) {
					Security.loadPolicyFile("http://up.odnoklassniki.ru/crossdomain.xml");
					Photos.upload([wallPostObject.file], function(response:Object):void { 
						for (var photo:* in response.photos) {
							Log.alert(photo);
							Odnoklassniki.callRestApi('photosV2.commit', function(response:*):void {
								Log.alert(response);
								wallPostObject = null;
							}, { photo_id:photo, token:response.photos[photo].token, comment:wallPostObject.msg }, "JSON", "POST");
						}
						Log.alert('Photos.upload complete');
					}, response.upload_url , App.user.id, album);
								
				} else {
					ExternalApi.saveScreenshot(response);
				}
				
				if (params.callback != null && !response.error_code) 
					params.callback(response);
			}
			
			
			setPermissionsOn('PHOTO CONTENT', function() : void {
				if (album == null) {
					createAlbums();
				}else {
					Odnoklassniki.callRestApi('photosV2.getUploadUrl', callback/*onGetUploadUrl*/, {aid:album}, "JSON", "POST");
				}
			});
			
			return;
			/*
			var request : Object = {method : "stream.publish", uid : params['owner_id'], message : params.msg, attachment:JSON.stringify(attach)};
			//var request : Object = {method : "stream.publish", uid : params['owner_id'], message : obj.title, attachment:JSON.stringify(attach)};
			request = Odnoklassniki.getSignature(request, false);
			
			callback = function(e:* = null):void {
				
				//Log.alert(e.data);
				//Log.alert(e.method);
				//Log.alert('__onWallPostPublished');	
				
				request['resig'] = e.data;
				if (params.callback != null) 
						params.callback(e.data);
				
				Odnoklassniki.callRestApi('stream.publish', function(response:*):void { 
					Log.alert(response);
					
				}, request, "JSON", "POST");
			}
			
			ExternalApi.apiNormalScreenEvent();
			Odnoklassniki.showConfirmation('stream.publish', params.msg, request['sig']);*/
		}
		
		public function showNotificationNew(txt:String, uid:String = ""):void
		{
			Odnoklassniki.showNotification(txt, uid);
		}
		
		public function checkGroupMember(callback:Function):void {
			Odnoklassniki.callRestApi('group.getUserGroupsV2', function(response:*):void { 
				Log.alert(response);
				if (response.groups != null)
				{
					for each(var obj:* in response.groups) {
						if (obj.groupId == '52619439636668') 
						{
							callback(1);
							return;
						}
					}
				}
				callback(0);
					
			}, {uid:App.user.id}); 
		}
		
		
		public function showConfirmationCallback(e:*):void {
			Log.alert('showConfirmationCallback:')
		}
		
		public function onWallPostPublished(response:*):void {
			Log.alert('onWallPostPublished');
			Log.alert(response);
		}	
		
		public function purchase(object:Object):void
		{
			callback = object.callback;
			Log.alert(object);
			if(object.money == "Coins"){
				Odnoklassniki.showPayment(
					Locale.__e('flash:1382952379707',[object.count]), 
					Locale.__e('flash:1382952379708'), 
					object.item, 
					int(object.votes), 
					null, 
					null, 
					'ok', 
					'true'
				);
			}else if (object.money == "Reals") {
				Odnoklassniki.showPayment(
					Locale.__e('flash:1382952379709',[object.count]), 
					Locale.__e('flash:1382952379708'), 
					object.item, 
					int(object.votes), 
					null,
					null, 
					'ok', 
					'true'
				);
			}else if (object.money == "promo") {
				Odnoklassniki.showPayment(
					object.title,
					'',
					object.item,
					int(object.votes),
					null, 
					null, 
					'ok', 
					'true'
				);
			}else if (object.money == "sets") {
				Odnoklassniki.showPayment(
					Locale.__e(object.title),
					'',
					object.item,
					int(object.votes),
					null, 
					null, 
					'ok', 
					'true'
				);
			}else if (object.money == "bigsale") {
				Odnoklassniki.showPayment(
					object.title,
					object.description || '',
					object.item,
					int(object.votes),
					null, 
					null, 
					'ok', 
					'true'
				);
			}else if (object.money == "Sets") {
				object.item = 'S' + object.item;
				Odnoklassniki.showPayment(
					object.title,
					object.description || '',
					object.item,
					int(object.votes),
					null, 
					null, 
					'ok', 
					'true'
				);
			}else if (object.money == "energy") {
				Odnoklassniki.showPayment(
					object.title,
					object.description || '',
					object.item,
					int(object.votes),
					null, 
					null, 
					'ok', 
					'true'
				);
			}
			
		}
	}
}
//package api
//{
	//import api.com.odnoklassniki.core.*;
	//import api.com.odnoklassniki.events.*;
	//import api.com.odnoklassniki.Odnoklassniki;
	//import api.com.odnoklassniki.net.*;
	//import api.com.odnoklassniki.sdk.users.Users;
	//import api.com.odnoklassniki.sdk.friends.Friends;
	//import api.com.odnoklassniki.sdk.photos.Photos;
	//import core.Load;
	//import core.Log;
	//import core.Post;
	//import flash.external.ExternalInterface;
	//import flash.system.Security;
	//import flash.utils.setTimeout;
	//import flash.events.Event;
	//
	//
		//
	//public class OKApi
	//{
			//
		//public var flashVars:Object;
		//public var profile:Object = { };
		//public var appFriends:Array = [];
		//public var allFriends:Array = [];
		//public var friends:Object = { };
		//public var otherFriends:Object = null;
		//public var wallServer:String;
		//public var albums:Object;
		//public var mainAlbum:Object;
		//
		//private var queue:Vector.<Array> = new Vector.<Array>;
		//private var executing:Boolean = false;
		//
		//public var friendsData:Array = new Array();
//
		//public var usersUids:Array = new Array();
		//
		//private var album:String = null;
		//
		//private var apiObject:Object;
		//private var callback:Function = null;
		//private var wallPostObject:Object = null;
		//
		//public var callsLeft:int = 0;
		//
		//public var dictionary:Object = {
			//0: function(sID:uint):Object {
					//return{
						//title:'',//App.data.storage[sID].title,
						//url:Config.getUnversionedIcon(App.data.storage[sID].type, App.data.storage[sID].preview)
					//}
			//},
			//1: function(e:* = null):Object {
					//return{
						//title:Locale.__e("flash:1382952379697"),
						//url:Config.getUnversionedImage('mail', 'PostsPic_level_OK')
					//}
			//},
			//2: function(sID:uint):Object {
					//return{				
						//title:Locale.__e("flash:1382952379698"),
						//url:Config.getIcon(App.data.storage[sID].type, App.data.storage[sID].preview)
						////url:Config.getUnversionedImage('mail', 'promo')
					//}
			//},
			//3: function(sID:uint):Object {
					//return{								
						//title:Locale.__e("flash:1382952379699"),
						//url:Config.getUnversionedIcon(App.data.storage[sID].type, App.data.storage[sID].preview)
						////url:Config.getUnversionedImage('mail', 'promo')
					//}
			//},
			//4: function(sID:uint):Object {
					//return{								
						//title:Locale.__e("flash:1382952379700"),
						////url:Config.getIcon(App.data.storage[sID].type, App.data.storage[sID].preview)
						//url:Config.getUnversionedImage('mail', 'promo')
					//}
			//},
			//5: function(sID:uint):Object {
					//return{								
						//title:Locale.__e("flash:1382952379701"),
						////url:Config.getIcon(App.data.storage[sID].type, App.data.storage[sID].preview)
						//url:Config.getUnversionedImage('mail', 'promo')
					//}
			//},
			//6: function(sID:uint):Object {
					//return{								
						//title:Locale.__e("flash:1382952379702"),
						//url:Config.getUnversionedImage('mail', 'promo')
					//}
			//},
			//7: function(qID:uint):Object {
					//return{				
						//title:Locale.__e(App.data.quests[qID].description),
						////url:Config.getQuestIcon('icons', App.data.personages[App.data.quests[qID].character].preview)
						//url:Config.getUnversionedImage('mail', 'promo')
					//}	
			//},
			//8: function(sID:uint):Object {
					//return{				
						//title:Locale.__e("flash:1382952379703"),
						//url:Config.getUnversionedImage('mail', 'level')
					//}
			//},
			//9: function(sID:uint):Object {
					//return{				
						//title:Locale.__e("flash:1398776058888", [App.data.storage[sID].title]),
						////url:Config.getIcon(App.data.storage[sID].type, App.data.storage[sID].preview)
						//url:Config.getUnversionedImage('mail', 'promo', 'jpg')
					//}
			//}
		//}
	//
		///**
		 //* Конструктор
		 //* @param	flashVars	переменные Одноклассники
		 //*/
		//public function OKApi(flashVars:Object)
		//{
			//this.flashVars = flashVars;
			//Log.alert('OKApi');
			//ExternalInterface.addCallback("setNetwork", setNetwork);
			//ExternalInterface.call('getNetwork');
		//}
		//
		//public function setNetwork(params:Object):void
		//{
			//Log.alert('setNetwork');
			//Log.alert(params);
			//
			//appFriends 	= params['appuids'];
			//friends 	= params['friends'];
			//profile 	= params['profile'];
			//allFriends 	= params['alluids'];
			//
			//Log.alert('complete');
			//App.self.onNetworkComplete(this);
		//}
		//public static var showInviteCallback:Function = null;
		//
		//public function refreshMoney():void {
			//Post.send( {
				//'ctr':'stock',
				//'act':'balance',
				//'uID':App.user.id
			//}, function(error:*, result:*, params:*):void {
				//if(!error && result){
					//for (var sID:* in result){
						//App.user.stock.put(sID, result[sID]);
					//}
				//}
			//});	
		//}
	//
		//public function makeScreenshot():void {
			//setPermissionsOn('PHOTO CONTENT', continueMakeScreenshot);
		//}
		//
		//public function continueMakeScreenshot(e:* = null):void 
		//{
			//Log.alert('continueMakeScreenshot');
			//Log.alert('album '+album);
			//if (album == null) {
				//createAlbums();
			//}else {
				//Odnoklassniki.callRestApi('photosV2.getUploadUrl', onGetUploadUrl, {aid:album}, "JSON", "POST");
			//}
		//}
		//
		//public function setPermissionsOn(perm:String, _callback:Function):void {
			//Odnoklassniki.callRestApi('users.hasAppPermission', onCheckPermissions, { uid:App.user.id, ext_perm:perm }, 'JSON', "POST");
			//function onCheckPermissions(response:*):void {
				//
				//if (response == false)
				//{
					//callback = _callback
					//Odnoklassniki.showPermissions(perm);
				//}
				//else
				//{
					//callback = null
					//_callback();
				//}
			//}
		//}
		//
		//public function createAlbums(params:Object=null):void {
			//Odnoklassniki.callRestApi('photos.createAlbum', function(aid:*):void {
				//Log.alert('photos.createAlbum');
				//Log.alert(aid);
				//album = aid;
				//Odnoklassniki.callRestApi('photosV2.getUploadUrl', onGetUploadUrl, {aid:album, count: 1}, "JSON", "POST");
			//}, { title:Locale.__e("flash:1382952379705"), type:"public" }, "JSON", "POST");
		//}
		//
		//
		//
		//public function onGetUploadUrl(response:Object):void {
			//Log.alert('onGetUploadUrl');
			//Log.alert(response);
//
			//if (wallPostObject != null) {
				//Security.loadPolicyFile("http://up.odnoklassniki.ru/crossdomain.xml");
				//Photos.upload([wallPostObject.file], function(response:Object):void { 
					//for (var photo:* in response.photos) {
						//Log.alert(photo);
						//Odnoklassniki.callRestApi('photosV2.commit', function(response:*):void {
							//Log.alert(response);
							//wallPostObject = null;
						//}, { photo_id:photo, token:response.photos[photo].token, comment:wallPostObject.msg }, "JSON", "POST");
					//}
					//Log.alert('Photos.upload complete');
				//}, response.upload_url , App.user.id, album);
							//
			//} else {
				//ExternalApi.saveScreenshot(response);
			//}
			//
		//}
		//
		//private function onUploadComplete(e:Event):void {
			//
		//}
		//
		//private function onWallpostUploadResponse(e:Event):void {
			//var response:Object = JSON.parse(e.currentTarget.loader.data);		
			//response['caption'] = wallPostObject.msg;
			//saveToAlbum(response);
			//wallPostObject = null;
		//}
		//
		//public function saveToAlbum(response:Object):void
		//{
			//Log.alert('saveToAlbum: '+response.photos);
			//for (var photo:* in response.photos) {
				//Log.alert(photo);
				//Odnoklassniki.callRestApi('photosV2.commit', function(response:*):void {
						//Log.alert(response);	
					//}, { photo_id:photo, token:response.photos[photo].token, comment:response['caption'] }, "JSON", "POST");
				//break;
			//}
		//}
//
		//public function showInviteBox():void
		//{
			////Odnoklassniki.showInvite(Locale.__e('flash:1382952379702'));
			//ExternalInterface.call("showInvite", Locale.__e('flash:1382952379702'))
		//}
		//
		//
		//public function getCallsLeft():void {
			//return;
			//Log.alert('getCallsLeft');
			////setPermissionsOn('PUBLISH TO STREAM', function():void { } );
				//
			//Odnoklassniki.callRestApi('users.getCallsLeft', function(response:*):void { 
				//Log.alert(response);
				//return;
				///*if (response[0].available == false) 
					//callsLeft = 0;
				//else
					//callsLeft = response[0].callsLeft;
					//
				//Log.alert('callsLeft: '+callsLeft);	*/
					//
			//}, { uid:App.user.id, methods:'stream.publish'}, "JSON", "POST");
		//}
		//
		//public function showNotification(params:Object):void {
			//if (params.type == ExternalApi.ASK ||
				//params.type == ExternalApi.GIFT)
				//return;
				//
			//var obj:Object = dictionary[params.type](params.sID);
		//
			//Odnoklassniki.showNotification(obj.title);
		//}
		//
		////public function wallPostOld(params:Object):void {
			////
			////Log.alert(params);
			////
			//////if (params.type == ExternalApi.ASK || params.type == ExternalApi.GIFT)
				//////return;
			//////switch(params.type) {
				//////case ExternalApi.ASK:
				//////case ExternalApi.GIFT:
				//////case ExternalApi.FRIEND_BRAG:
				//////	return;
				//////break;
			//////}
				////
			////var obj:Object = dictionary[params.type](params.sID);
			////var url:String = obj.url.replace(Config.secure +  Config._resIP, "");
			////
			////Log.alert('wallPOST');
			////Log.alert(Config.secure);
			////Log.alert(Config._resIP);
			////
			//////Log.alert(url);
			//////Log.alert(params.type);
			////
			//////var attach:Object = {
				//////"caption":Locale.__e('flash:1408696652412'),//params.msg,
				//////"media":[{"href":params.url,"src":url,"type":"image"}]
			//////};
			////
			////wallPostObject = { 
				////file: params.bytes,
				////msg : params.msg + " " + params.url				
			////};
			////
			////var callback:Function = function(response:Object):void {
				////
				////Log.alert('onGetUploadUrl ' + response);
////
				////if (wallPostObject != null) {
					////Security.loadPolicyFile("http://up.odnoklassniki.ru/crossdomain.xml");
					////Photos.upload([wallPostObject.file], function(response:Object):void { 
						////for (var photo:* in response.photos) {
							////Log.alert(photo);
							////Odnoklassniki.callRestApi('photosV2.commit', function(response:*):void {
								////Log.alert(response);
								////wallPostObject = null;
							////}, { photo_id:photo, token:response.photos[photo].token, comment:wallPostObject.msg }, "JSON", "POST");
						////}
						////Log.alert('Photos.upload complete');
					////}, response.upload_url , App.user.id, album);
								////
				////} else {
					////ExternalApi.saveScreenshot(response);
				////}
				////
				////if (params.callback != null && !response.error_code) 
					////params.callback(response);
			////}
			////
			////
			////setPermissionsOn('PHOTO CONTENT', function() : void {
				////if (album == null) {
					////createAlbums();
				////}else {
					////Odnoklassniki.callRestApi('photosV2.getUploadUrl', callback/*onGetUploadUrl*/, {aid:album}, "JSON", "POST");
				////}
			////});
			////
			////return;
			/////*
			////var request : Object = {method : "stream.publish", uid : params['owner_id'], message : params.msg, attachment:JSON.stringify(attach)};
			//////var request : Object = {method : "stream.publish", uid : params['owner_id'], message : obj.title, attachment:JSON.stringify(attach)};
			////request = Odnoklassniki.getSignature(request, false);
			////
			////callback = function(e:* = null):void {
				////
				//////Log.alert(e.data);
				//////Log.alert(e.method);
				//////Log.alert('__onWallPostPublished');	
				////
				////request['resig'] = e.data;
				////if (params.callback != null) 
						////params.callback(e.data);
				////
				////Odnoklassniki.callRestApi('stream.publish', function(response:*):void { 
					////Log.alert(response);
					////
				////}, request, "JSON", "POST");
			////}
			////
			////ExternalApi.apiNormalScreenEvent();
			////Odnoklassniki.showConfirmation('stream.publish', params.msg, request['sig']);*/
		////}
		//
		//public function wallPost(params:Object):void 
		//{
			//Log.alert('WALLPOST');
			//Log.alert(params);
			//
			//params.msg = params.msg.replace(/http[^ ]+/, "");
			//
			//params['hash'] = Config.appUrl;
			//
			//var hashIndex:int = params.msg.indexOf('#oneoff');
			//if (hashIndex >= 0) {
				//params.hash = 'oneoff=' + params.msg.substr(hashIndex + 7, 13);
			//}
			//
			//var obj:Object = dictionary[params.type](params.sID);
			//var url:String = obj.url;//.replace('http://' + Config._resIP, "");
			//if (String(obj.title).length > 64 ) // не дает посить с названием большим чем 64 символа
			//{
				//params.msg = obj.title + '\n' + params.msg;
				//obj.title = Log.alert('flash:1472726979622');
			//}
			//var attach:Object = {
				//'title':obj.title,
				//'text': params.msg,
				//'image':url,
				//'action': Config.appUrl,
				//'mark': Config.appUrl
			//}
			//Log.alert(attach);	
			//if (ExternalInterface.available)
			//{	
				//ExternalInterface.call("post", attach);
			//}	
		//}
		//
		//public function showNotificationNew(txt:String, uid:String = ""):void
		//{
			//Odnoklassniki.showNotification(txt, uid);
		//}
		//
		//public function checkGroupMember(callback:Function):void {
			////Odnoklassniki.callRestApi('group.getUserGroupsV2', function(response:*):void { 
				////Log.alert(response);
				////if (response.groups != null)
				////{
					////for each(var obj:* in response.groups) {
						////if (obj.groupId == '52619439636668') 
						////{
							////callback(1);
							////return;
						////}
					////}
				////}
				////callback(0);
					////
			////}, {uid:App.user.id}); 
			////callback(1);
			//if (ExternalInterface.available)
			//{
				//ExternalInterface.addCallback("onCheckGroupMember", callback);
				//ExternalInterface.call("checkGroupMember");
			//}
			//else
			//{
				//callback(0);
			//}
		//}
		//
		//
		//public function showConfirmationCallback(e:*):void {
			//Log.alert('showConfirmationCallback:')
		//}
		//
		//public function onWallPostPublished(response:*):void {
			//Log.alert('onWallPostPublished');
			//Log.alert(response);
		//}	
		//
		//public function purchase(object:Object):void
		//{
			//callback = object.callback;
			//
			//
			//var params:Object = {};
			//
			//if (object.money == "Coins")
			//{
				////Odnoklassniki.showPayment(
					////Locale.__e('flash:1382952379707',[object.count]), 
					////Locale.__e('flash:1382952379708'), 
					////object.item, 
					////int(object.votes), 
					////null, 
					////null, 
					////'ok', 
					////'true'
				////);
				//
				//params["name"] = Locale.__e('flash:1382952379707', [object.count]);
				//params["description"] = Locale.__e('flash:1382952379708');
				//params["code"] = object.item;
				//params["price"] = int(object.votes);
				//params["options"] = null;
				//params["attributes"] = null;
				//params["currency"] = "ok",
				//params["callback"] = "true";
			//}
			//else if (object.money == "Reals") 
			//{
				////Odnoklassniki.showPayment(
					////Locale.__e('flash:1382952379709',[object.count]), 
					////Locale.__e('flash:1382952379708'), 
					////object.item, 
					////int(object.votes), 
					////null,
					////null, 
					////'ok', 
					////'true'
				////);
				//
				//params["name"] = Locale.__e('flash:1382952379709',[object.count]);
				//params["description"] = Locale.__e('flash:1382952379708');
				//params["code"] = object.item;
				//params["price"] = int(object.votes);
				//params["options"] = null;
				//params["attributes"] = null;
				//params["currency"] = "ok",
				//params["callback"] = "true";
			//}
			//else if (object.money == "promo") 
			//{
				////Odnoklassniki.showPayment(
					////object.title,
					////'',
					////object.item,
					////int(object.votes),
					////null, 
					////null, 
					////'ok', 
					////'true'
				////);
				//
				//params["name"] = object.title;
				//params["description"] = "";
				//params["code"] = object.item;
				//params["price"] = int(object.votes);
				//params["options"] = null;
				//params["attributes"] = null;
				//params["currency"] = "ok",
				//params["callback"] = "true";
			//}
			//else if (object.money == "sets") 
			//{
				////Odnoklassniki.showPayment(
					////Locale.__e(object.title),
					////'',
					////object.item,
					////int(object.votes),
					////null, 
					////null, 
					////'ok', 
					////'true'
				////);
				//
				//params["name"] = object.title;
				//params["description"] = "";
				//params["code"] = object.item;
				//params["price"] = int(object.votes);
				//params["options"] = null;
				//params["attributes"] = null;
				//params["currency"] = "ok",
				//params["callback"] = "true";
			//}
			//else if (object.money == "bigsale") 
			//{
				////Odnoklassniki.showPayment(
					////object.title,
					////object.description || '',
					////object.item,
					////int(object.votes),
					////null, 
					////null, 
					////'ok', 
					////'true'
				////);
				//
				//params["name"] = object.title;
				//params["description"] = object.description || "";
				//params["code"] = object.item;
				//params["price"] = int(object.votes);
				//params["options"] = null;
				//params["attributes"] = null;
				//params["currency"] = "ok",
				//params["callback"] = "true";
			//}
			//if (object.money == "energy") 
			//{
				////Odnoklassniki.showPayment(
					////object.title,
					////object.description || '',
					////object.item,
					////int(object.votes),
					////null, 
					////null, 
					////'ok', 
					////'true'
				////);
				//
				//params["name"] = object.title;
				//params["description"] = object.description || "";
				//params["code"] = object.item;
				//params["price"] = int(object.votes);
				//params["options"] = null;
				//params["attributes"] = null;
				//params["currency"] = "ok",
				//params["callback"] = "true";
			//}
			//
			//if (ExternalInterface.available)
			//{
				//ExternalInterface.addCallback("updateBalance", function():void {
					//if (callback != null)
					//{
						//callback();
					//}
						//
					//Post.send( {
						//'ctr':'stock',
						//'act':'balance',
						//'uID':App.user.id
					//}, function(error:*, result:*, params:*):void {
						//if(!error && result){
							//for (var sID:* in result){
								//App.user.stock.put(sID, result[sID]);
							//}
						//}
					//});
				//});
				//ExternalInterface.call("showPayment", params);
			//}
		//}
	//}
//}