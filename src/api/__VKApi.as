package api 
{
	import core.Log;
	import core.Post;
	import vk.APIConnection;
	import vk.events.*;
	import com.adobe.images.PNGEncoder;
	//import wins.SimpleWindow;
	//import ru.inspirit.encoders.png.PNGEncoder;
	import flash.utils.ByteArray;
	
	import flash.net.URLRequest
	import flash.net.URLLoader
	
	import flash.net.URLRequestMethod
	import flash.events.Event
	import flash.net.URLVariables	
	
	import flash.utils.setTimeout;
	import flash.display.Sprite;
	
	
	/**
	 * ...
	 * @author ...
	 */
	public class VKApi 
	{
		private const test_mode:uint = 0;
		
		private var userID:*;
		private var flashVars:Object;
		private var VK:APIConnection
		private var requestVars:URLVariables
		private var requestObject:URLRequest
		private var ldr:URLLoader
		private var pngStream:ByteArray
		private var apiObject:Object;
		private var fader:Sprite = null;
		private var api_result:Object = null;
		private var onWallSavedCallback:Function = null;
		
		public var profile:Object = new Object
		public var server:Object;
		public var albumUrl:String;
		
		public var allFriendsUIDs:Array = [];
		public var friendsUids:Array = [];
		public var appFriends:Array = [];
		public var allFriends:Array = [];
		
		/**
		 * Конструктор
		 * @param flashVars переменные ВКонтакте
		 */
		
		public function VKApi(flashVars:Object)
		{
			this.flashVars = flashVars;
			
			userID = flashVars['viewer_id'];
			
			VK = new APIConnection(flashVars);
			
			VK.addEventListener('onBalanceChanged', onBalanceChanged); 
			VK.addEventListener('onWindowBlur', onWindowBlur); 
			VK.addEventListener('onWindowFocus', onWindowFocus);
			VK.addEventListener('onOrderSuccess', onOrderSuccess);
			VK.addEventListener('onOrderFail', onOrderFail);
			//VK.addEventListener('onOrderCancel', onOrderCancel);
		//	VK.addEventListener('onSettingsChanged', onSettingsChanged);
		
			init();
		}

		/**
		 * Наложение серой пленки на сцену при появлении модального окна Вконтакте
		 * @param	e	событие
		 */
		public function onWindowBlur(e: CustomEvent):void {
			//ScreenMode.goToNormal();
			fader = new Sprite;
			fader.graphics.beginFill(0xF4F4F4, 1);
			fader.graphics.drawRect(0, 0, App.self.stage.stageWidth, App.self.stage.stageHeight);
			fader.graphics.endFill();
			App.self.addChild(fader);
		}
		
		/**
		 * Снятие пленки со сцены при закрытии модального окна
		 * @param	e	событие
		 */
		public function onWindowFocus(e: CustomEvent):void {
			if (fader != null)
			{
				if(App.self.contains(fader)){
					App.self.removeChild(fader);
					fader = null;
					if (apiObject != null && apiObject.hasOwnProperty('callback')) {
						apiObject.callback();
					}
				}
			}
		}
		
		public function showSettingsBox(callback:Function):void {
			VK.callMethod('showSettingsBox', 256);
			apiObject = new Object();
			apiObject.callback = getUserSettings;
			apiObject.callbacksettings = callback;
		}
		
		public function getUserSettings():void {
			VK.api('getUserSettings',{ test_mode:test_mode }, apiObject.callbacksettings, onApiRequestFail);
		}
		
		/**
		 * Событие ошибки от ВК
		 * @param	data
		 */
		private  function onApiRequestFail(data:Object): void 
		{
			//data = "Connection error occured"
			trace("Error: " + data.error_msg)
		}

		
		/**
		 * Возвращает true в случае, когда сцена закрыта пленкой
		 * @return
		 */
		public function isBlur():Boolean {
			return fader != null;
		}
		
		/**
		 * Начальная инициализация апи
		 */
		public function init():void 
		{
			//ISLANDS.sendToLoader("execute отправлен на vkAPI");
			
			if (flashVars.api_result != null)
			{ 
				trace("берем из первого запроса");
				api_result = JSON.parse(flashVars.api_result);
				//fetchUser(api_result.response);
				
				VK.api('execute',
					{code:
					'var appFriends = API.getAppFriends(); ' +
					'var wallServer = API.photos.getWallUploadServer(); '+
					'var friendsUids = API.friends.get(); '+ 
					'var profile = API.getProfiles({"uids":'+userID+',"fields":"uid,first_name,last_name,photo,sex", test_mode:'+test_mode+'}); '+
					'return { appFriends:appFriends, friendsUids:friendsUids, wallServer:wallServer, profile:profile};' },
				fetchUser,
				onApiRequestFail);	
			}
			else 
			{
				VK.api('execute',
					{code:
					'var appFriends = API.getAppFriends(); ' +
					'var wallServer = API.photos.getWallUploadServer(); '+
					'var friendsUids = API.friends.get(); '+ 
					'var profile = API.getProfiles({"uids":'+userID+',"fields":"uid,first_name,last_name,photo,sex,country,bdate,city", test_mode:'+test_mode+'}); '+
					'return { appFriends:appFriends, friendsUids:friendsUids, wallServer:wallServer, profile:profile};' },
				fetchUser,
				onApiRequestFail);	
			}
		}
		
		private  function fetchUser(userdata:Object): void
		{
			friendsUids	= userdata.friendsUids;
			trace("получен friendsUids: " + friendsUids.length);
			
			appFriends = userdata.appFriends;
			trace("получен friendsList: " + appFriends.length);
			
			profile = userdata.profile[0];
			trace("получен profile");
			profile.sex = profile.sex == 2?'m':'f';
			
			server = userdata.wallServer;
			trace("получен wallServer");

			var count:int = appFriends.length;
			for (var i:int = 0; i < count; i++ )
			{
				var uid:* = appFriends[i];
				var index:int = friendsUids.indexOf(uid);
				if (index != -1) {
					friendsUids.splice(index, 1);
				}
			}
			
			var otherUsersUids:Array = friendsUids.splice(0, 50);
			
			trace("запрашиваем друзей вне приложения "+otherUsersUids.length)
			
			if (otherUsersUids.length == 0){
				otherUsersUids = appFriends.slice(0, 50);
			}
			
			VK.api(
				'execute', 
				{code: 'return {"otherUsers":API.users.get({uids:"' + otherUsersUids + '", fields:"uid,first_name,last_name,photo", test_mode:' + test_mode +'})};' },
				finishTakeInfo,
				onApiRequestFail
			);
			
		}
		
		private function finishTakeInfo(userdata:Object):void
		{
			trace("получили все данные");
			
			var otherUsers:Array = [];
			if (userdata.otherUsers != false)
			{
				otherUsers = userdata.otherUsers;
			}
			
			var i:int = otherUsers.length-1;
			while (i >= 0){
				allFriendsUIDs.push(otherUsers[i].uid);
				i--;
			}
			allFriends = otherUsers;
			App.self.dispatchEvent(new AppEvent(AppEvent.ON_NETWORK_COMPLETE));
		}
		
		
		public function showInviteBox():void
		{
			VK.callMethod('showInviteBox',{test_mode:test_mode});
		}
		
		
		/**********************************************
		** ОПОВЕЩЕНИЯ *********************************
		**********************************************/
		
		public function showRequestBox(object:Object):void {
			
			if (!object.hasOwnProperty('requestKey')) {
				object['requestKey'] = '';
			}
			
			VK.callMethod('showRequestBox', { test_mode:test_mode, uid:object.uid, message:object.message, requestKey:object.requestKey } );
			
		}
		
		
		/**********************************************
		** СОХРАНЕНИЕ ФОТОГРАФИЙ В АЛЬБОМ *************
		**********************************************/
		
		/**
		 * Запрос на получение альбома игры для сохранения скриншота
		 */
		public function getAlbum():void {
			VK.api('photos.getAlbums', {test_mode:test_mode}, onGetAllAlbums, onApiRequestFail);
		}
		
		/**
		 * Callback для получения всех альбомов пользователя
		 * @param	responce - все альбомы пользователя
		 */
		public function onGetAllAlbums(responce:Object):void 
		{
			var album:Object = null;
			for each(var item:* in responce) {
				if (item.title == "Загадочный остров") {
					album = item;
					break;
				}
			}
			if (album != null) {
				var timeOut:Number = setTimeout(
					function():void { onGetAlbum(album) },
					1000
				)
			}
		}
		
		/**
		 * Callback для получения альбома текущего пользователя
		 * @param	album - альбом игры
		 */
		public function onGetAlbum(album:Object):void 
		{		
			VK.api('photos.getUploadServer', { test_mode:test_mode, aid:album.aid}, onGetServer, onApiRequestFail);
		}
		
		private function onGetServer(responce:Object):void 
		{
			albumUrl = responce.upload_url
			
			/*
			if (createNewAlbum == true) {
				setTimeout(function():void {
					
					new SimpleWindow( {
						text:"Опубликовать фото в альбоме игры?",
						dialog:true,
						confirm:function() {
							Connection.MAIN_CONTAINER.API.postImageData();	
						},
						label:SimpleWindow.ATTENTION
					}).show();
				
				
				}
				, 500);
			}
			*/
		}

		
		public function onAlbumUploadResponse(e:Event):void 
		{
			e.currentTarget.removeEventListener(Event.COMPLETE, onAlbumUploadResponse);
			var responce:Object = JSON.parse(e.currentTarget.loader.data);
			responce['test_mode'] = test_mode;
			
			VK.api('photos.save', responce, onPhotoUploaded, onApiRequestFail);
		}
		
		/**
		 * Сохранение фотографии в альбоме пользователя
		 * @param	object
		 */
		public function savePhoto(object:Object):void
		{
			this.apiObject = object;
			
			//var pngStream:ByteArray = PNGEncoder.encode(object.image);
			
			if (albumUrl != null) {
				setTimeout(function():void {
					/*
					new SimpleWindow( {
						text:"Опубликовать фото в альбоме игры?",
						dialog:true,
						confirm:function() {
							Connection.MAIN_CONTAINER.API.postImageData();	
						},
						label:SimpleWindow.ATTENTION
					}).show();
					*/
				}, 500);
			}else {
				//createNewAlbum = true;
				VK.api('photos.createAlbum', { test_mode:test_mode, title:"Загадочный остров"}, onGetAlbum, onApiRequestFail);
			}
		}
		
		public function postImageData():void {
			var pngStream:ByteArray = PNGEncoder.encode(apiObject.image);
			
			//ISLANDS.instance.getWrapper().sendData(albumUrl, onAlbumUploadResponse, pngStream, "image.png", "file1", 'image/jpeg');
		}
		
		
		
		public function onPhotoUploaded(responce:Object):void 
		{
			
		}
		
		/**********************************************
		** СОХРАНЕНИЕ ФОТОГРАФИЙ НА СТЕНУ *************
		**********************************************/
		
		/**
		 * Загрузка фотографий на стену пользователя
		 * @param	object.image 	bitmap изображения
		 * 			object.message 	текст сообщения
		 * 			object.uid 		дентификатор пользователя ВКонтакте
		 */
		public function saveWallPost(object:Object):void
		{
			Log.alert('saveWallPost');
			Post.addToArchive('saveWallPost');
			//Временное решение для постинга фотографий
			this.apiObject = object;
			
			var encoder:Object = new Object();
			encoder.encode = PNGEncoder.encode;
			var imageBytes:ByteArray = encoder.encode(apiObject.image);
			
			//if(ISLANDS.instance.getWrapper().hasOwnProperty('sendData')){
				//ISLANDS.instance.getWrapper().sendData(server.upload_url, onWallUploadResponse, imageBytes, "image.png", "photo", 'image/png');
			//}
		}
				
		public function onGetWallUploadServer(responce:Object):void
		{
			Log.alert('onGetWallUploadServer');
			Post.addToArchive('onGetWallUploadServer');
			this.server = responce;
		}
		
		public function onWallUploadResponse(e:Event):void 
		{
			Log.alert('onWallUploadResponse');
			Post.addToArchive('onWallUploadResponse');
			e.currentTarget.removeEventListener(Event.COMPLETE, onWallUploadResponse);
			
			var responce:Object = JSON.parse(e.currentTarget.loader.data);
				
			responce['test_mode'] = test_mode;
			
			if (apiObject.uid != userID) {
				responce['uid'] = apiObject.uid;
			}
			VK.api('photos.saveWallPhoto', responce, onWallUploaded, onApiRequestFail);
		}
		
		public function onWallUploaded(responce:Object):void 
		{
			Log.alert('onWallUploaded');
			Post.addToArchive('onWallUploaded');
			var req:Object = {
				owner_id:responce[0].owner_id,
				message:apiObject.message,
				attachments:responce[0].id,
				test_mode:test_mode
			}
			if (apiObject.uid != userID) {
				req['owner_id'] = apiObject.uid;
			}
			
			VK.api('wall.post', req, onWallSaved, onApiRequestFail);
			
		}
		
		public function onWallSaved(responce:Object):void 
		{
			Log.alert('onWallSaved');
			Post.addToArchive('onWallSaved');
			if (onWallSavedCallback == null) return;
			
			if (responce.hasOwnProperty("post_id"))
			{
				onWallSavedCallback(true)
			}else{
				onWallSavedCallback(false)
			}
		}
		
		/**********************************************
		** ПЛАТЕЖИ ************************************
		**********************************************/
		public function purchase(object:Object):void 
		{
			this.apiObject = object;
			
			var params:Object = {
				type: 'item',
				item: object.type+'_'+object.id,
				test_mode:test_mode
			};
			
			VK.callMethod('showOrderBox', params);
		}
		
		public function onBalanceChanged(e: CustomEvent):void 
		{
		}
		public function onOrderSuccess(e:*):void 
		{
			//Post.prepare({
				//'action':'balance'
			//});
		}
		public function onOrderFail(e: CustomEvent):void 
		{
			/*
			new SimpleWindow( {
				label:SimpleWindow.ERROR,
				text: 'Оплата не удалась. Вы можете перегрузить игру и повторить попытку.'				
			}).show();
			*/
		}
		
			
		public function groupsIsMember(callback:Function):void
		{
			VK.api('groups.isMember', {gid:'island_farm', uid:userID, test_mode:test_mode}, callback, onApiRequestFail);
		}

	}

}