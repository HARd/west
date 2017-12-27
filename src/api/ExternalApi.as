package api 
{
	import by.blooddy.crypto.image.JPEGEncoder;
	import com.junkbyte.console.Cc;
	import core.Load;
	import core.Log;
	import core.MultipartURLLoader;
	import core.Post;
	import core.WallPost;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display.StageDisplayState;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.utils.ByteArray;
	import com.adobe.images.PNGEncoder;	
	import flash.utils.setTimeout;
	import strings.Strings;
	import ui.UserInterface;
	import wins.AskWindow;
	import wins.ErrorWindow;
	import wins.SimpleWindow;
	import flash.display.StageDisplayState;
	import wins.LevelUpWindow;
	import wins.StockWindow;
	import wins.Window;
	
	public class ExternalApi 
	{
		
		public static const DM:String = 'DM';
		
		public static const OTHER:uint = 0;
		public static const NEW_ZONE:uint = 1;
		public static const GIFT:uint = 2;
		public static const ASK:uint = 3;
		public static const ANIMAL:uint = 4;
		public static const BUILDING:uint = 5;
		public static const PROMO:uint = 6;
		public static const QUEST:uint = 7;
		public static const LEVEL:uint = 8;
		public static const FRIEND_BRAG:uint = 9;
		public static const DAYLICS:uint = 10;
		
		
		public static var postCallback:Function = null;
		public static var onCloseApiWindow:Function = null;
		
		
		public function ExternalApi() 
		{
			
		}
		
		public static function apiScreenshotEvent():void {
			
			switch(App.self.flashVars.social) {
				case 'VK':
				case 'DM':	
					if (ExternalInterface.available){
						ExternalInterface.addCallback("saveScreenshot", saveScreenshot);
						ExternalInterface.call("makeScreenshot");
					}
					break;
				case 'OK':
					App.network.makeScreenshot();
					break;
					
				case 'ML':	
					if (ExternalInterface.available){
						ExternalInterface.addCallback("saveScreenshot", App.network.saveScreenshot);
						ExternalInterface.call("makeScreenshot");
					}
					break
			}
		}
		
		public static function setCloseApiWindowCallback():void {
			if (ExternalInterface.available){
				ExternalInterface.addCallback("onCloseApiWindow", function():void{
					if (onCloseApiWindow != null)
					onCloseApiWindow();
				});
			}	
		}
		
		public static function reset():void{
			
			if (ExternalInterface.available)
			{
				ExternalInterface.call("reset");
			}
		}
		
		
		public static function addSettingsCallback(callback:Function):void {
			if (ExternalInterface.available)
				ExternalInterface.addCallback("onSettingsChanged", callback);
		}
		public static function showSettingsBox():void{
			if (ExternalInterface.available)
				ExternalInterface.call("showSettingsBox");
		}
		public static function getAppPermission():void{
			if (ExternalInterface.available)
				ExternalInterface.call("getAppPermissions");
		}
		
		public static function checkGroupMember(callback:Function):void {
			if (!ExternalInterface.available) {
				//callback(0);
				return;
			}
			
			Log.alert('checkGroupMember');
			switch(App.self.flashVars.social) {
				case "OK":
					if (App.network is OKApi)
						App.network.checkGroupMember(callback);
					else 
						callback(0);
					break;
				case "FB":
					break;
				default:
					ExternalInterface.addCallback("checkGroupMember", callback);
					ExternalInterface.call("isGroupMember");
			}
		}
		
		
		public static function sendmail(data:*):void {
			
			if (ExternalInterface.available)
			{
				ExternalInterface.call("sendmail", data);
			}
		}
		
		public static function saveScreenshot(response:Object):void{
			
			Post.addToArchive('saveScreenshot');
			Log.alert(response);
			
			var screenshot:BitmapData = new BitmapData(App.self.stage.stageWidth, App.self.stage.stageHeight);			
			screenshot.draw(App.self);		
			
		
			switch(App.self.flashVars.social) {
				case 'VK':
				case 'DM':	
					break;
				case 'OK':
					if (screenshot.height > 700) {
						
						var tempBitmap:Bitmap = new Bitmap(screenshot);
						tempBitmap.scaleX = tempBitmap.scaleY = 0.5;
						tempBitmap.smoothing = true;
						
						var cont:Sprite = new Sprite();
						cont.addChild(tempBitmap);
						
						screenshot = new BitmapData(tempBitmap.width, tempBitmap.height);
						screenshot.draw(cont);
						
						cont = null;
						tempBitmap = null;
					}
					
					if (response.hasOwnProperty('error_code')) {
						//var text:String = Locale.__e("flash:1382952379662");
						
						var winSettings:Object = {
							title				:Locale.__e('flash:1382952379692'),
							text				:Locale.__e('flash:1382952379662'),
							buttonText			:Locale.__e('flash:1393576915356'),
							//image				:UserInterface.textures.alert_error,
							image				:Window.textures.errorOops,
							imageX				:-78,
							imageY				: -76,
							textPaddingY        : -18,
							textPaddingX        : -10,
							hasExit             :true,
							faderAsClose        :true,
							faderClickable      :true,
							forcedClosing       :true,
							closeAfterOk        :true,
							bttnPaddingY        :25,
							ok					:function():void {
								//new StockWindow().show();
							}
						};
						new ErrorWindow(winSettings).show();
						
						return;
						//switch(response.error_code) {
							//case 10:
								//text = Locale.__e('flash:1382952379691');
								//break
						//}
						//
						//new SimpleWindow( {
							//text:text,
							//title:Locale.__e('flash:1382952379692'),
							//label:SimpleWindow.ERROR,
							//height:320
						//}).show();
						//
						//return;
					}
					
					break;
			}
			
			var pngStream:ByteArray = PNGEncoder.encode(screenshot);
			
			new SimpleWindow( {
				text:Locale.__e('flash:1382952379693'),
				title:Locale.__e('flash:1382952379694'),
				height:320,
				dialog:true,
				confirm: function():void {
					sendFile(response.upload_url, pngStream, onScreenshotUploadResponse);
					//Load.sendFile(response.upload_url, pngStream, "image.png", "file1", 'image/jpeg', onScreenshotUploadResponse);
				}
			}).show();
		}
		
		private static function sendFile(url:String, pngStream:ByteArray, callback:Function):void {
			
			var ldr:MultipartURLLoader = new MultipartURLLoader(); 
			ldr.addEventListener(Event.COMPLETE, function(e:Event):void {
				Post.addToArchive('-- SendFile --')
				callback(e);
			});
			ldr.addVariable('url', url);// App.network.wallServer.upload_url);
			ldr.addFile(pngStream, "image.png", "file", 'image/png');
			ldr.load('http://aliens.islandsville.com/iframe/upload.php');
		}
		
		private static function onScreenshotUploadResponse(e:Event):void {
			Post.addToArchive('onScreenshotUploadResponse');
			var response:Object = JSON.parse(e.currentTarget.loader.data);
			Log.alert('onScreenshotUploadResponse: '+e.currentTarget.loader.data);
			
			
			switch(App.self.flashVars.social) {
				case 'VK':
				case 'DM':	
					response['caption'] = Locale.__e('flash:1382952379695', [Config.appUrl]);
					if (ExternalInterface.available)
						ExternalInterface.call("saveToAlbum", response);
					break;
				case 'OK':
					response['caption'] = Locale.__e("flash:1382952379696");
					App.network.saveToAlbum(response);
					break;
			}
		}
		
		public static function apiInviteEvent(params:Object = null):void {
			Log.alert('invite');
			
			if (!ExternalInterface.available) return;
			Log.alert(App.social);
			
			ExternalApi.apiNormalScreenEvent();
			ExternalInterface.addCallback("onInviteComplete", onInviteComplete);
			
			if (!params) params = { };
			if (!params.hasOwnProperty('msg'))
				params['msg'] = Strings.__e('FreebieWindow_sendPost', [Config.appUrl]);
				
			switch(App.social) {
				case 'VK':
				case 'DM':
					//ExternalInterface.call("showInviteBox");
					new AskWindow(AskWindow.MODE_NOTIFY_2,  { 
						title:Locale.__e('flash:1407159672690'), 
						inviteTxt:Locale.__e("flash:1407159700409"), 
						desc:Locale.__e("flash:1407155423881"),
						descY:30,
						height:530,
						itemsMode:5
					}, function(uid:*):void {
						ExternalApi.notifyFriend( {
							uid:	String(uid),
							text:	Locale.__e('flash:1408696336510'),
							type:	'gift'
						});
						
						onInviteComplete(uid);
					} ).show();
					
					break;
				case 'NK':
					ExternalInterface.call("showInviteBox", {inviter:App.user.id, msg:Locale.__e('flash:1408696336510')});
					break;
				case 'OK':
					OKApi.showInviteCallback = onInviteComplete;
					App.network.showInviteBox();
					break;
				case 'YN':
					ExternalApi.apiNormalScreenEvent();
					App.network.invite();
					break;
				case 'SP':
					Log.alert('Internal showInviteBox');
					ExternalInterface.call("showInviteBox");
					if(params && params.hasOwnProperty('callback'))
						ExternalInterface.addCallback("onInviteComplete", params.callback);
					break;
				case 'GN':
					ExternalApi.apiNormalScreenEvent();
					Log.alert('call');
					ExternalInterface.call("showInviteBox");
					break;
				default:
					ExternalInterface.call("showInviteBox", params['msg']);
			}
			
			function onInviteComplete(data:*):void {
				Log.alert('ON_INVITE_COMPLETE');
				Log.alert(data);
				
				Friends.registerFriend(data);
				
				if (params && params.hasOwnProperty('callback'))
					params.callback(data);
			}
		}
		
		public static var tries:int = 0;
		public static function updateBalance(recursive:Boolean = false):void {
			
			Post.send( {
				'ctr':'stock',
				'act':'balance',
				'uID':App.user.id
			}, function(error:*, result:*, params:*):void {
				if (!error && result) {
					var same:Boolean = true;
					tries++;
					for (var sID:* in result){
						if(App.user.stock.count(sID) != result[sID]){
							App.user.stock.put(sID, result[sID]);
							if (sID == Stock.COINS) App.ui.glowing(App.ui.upPanel.coinsPanel, 0xFFFF00);
							else if (sID == Stock.FANT) App.ui.glowing(App.ui.upPanel.fantsPanel, 0xFFFF00);
							same = false;
						}
					}
					if (recursive && same && tries <= 10) {
						setTimeout(function():void {
							updateBalance(true);
						}, 3000);
					}
				}
			});	
			
		}
		
		public static function apiBalanceEvent(params:Object):void {
			if (!ExternalInterface.available) return;
			
			ExternalApi.apiNormalScreenEvent();
			
			switch(App.self.flashVars.social) {
				
				case 'PL':
					ExternalInterface.call("purchase", params);
					
					break;
				case 'YB':
					ExternalApi.apiNormalScreenEvent();
					YBApi.purchase(params);
					//ExternalInterface.addCallback("updateBalance", function():void {
						//updateBalance();
						//tries = 0; //Обнуляем кол-во попыток
						//setTimeout(function():void {
							//updateBalance(true);
						//}, 3000);
					//});
					//ExternalInterface.call("purchase", params);
					//
					break;
				
				case 'HV':
					HVApi.purchase(params);
					break;
				case 'FB':
				case 'NK':
				case 'VK':
				case 'DM':
					ExternalInterface.addCallback("updateBalance", function(callback:Boolean = true):void {
						tries = 0;
						updateBalance(true);
						if (callback && params['callback'] != null) {
							params.callback();
						}
					});
					ExternalInterface.call("purchase", params);
					
					break;
				case 'FS':
					FSApi.purchase(params);
					break;
				case 'MX':
					MXApi.purchase(params);
					break;
				case 'GN':
					ExternalApi.apiNormalScreenEvent();
					GNApi.purchase(params);
					break;
				case 'SP':
					ExternalApi.apiNormalScreenEvent();
					SPApi.purchase(params);
					break;
				case 'AI':
					ExternalApi.apiNormalScreenEvent();
					AIApi.purchase(params);
					break;
				default:
					App.network.purchase(params);
			}
		}
		
		private static var promoCallback:Function;
		public static function apiPromoEvent(params:Object):void {
			Log.alert('API PROMO EVENT');
			if (!ExternalInterface.available) return;
			Log.alert('External interface');
			promoCallback = params.callback;
			ExternalApi.apiNormalScreenEvent();
			
			switch(App.self.flashVars.social) {
				case 'NK':
				case 'VK':
				case 'DM':	
				case 'FB':	
					
					ExternalInterface.addCallback("updateBalance", function(data:* = null):void {
						if (promoCallback != null) promoCallback();
						promoCallback = null;
						askOpenFullscreen();
					});
					ExternalInterface.call("purchase", params);
					break;
				case 'HV':
					HVApi.purchase(params);
					break;
				case 'FS':
					FSApi.purchase(params);
					break;
				case 'YB':
					YBApi.purchase(params);
					break;
				case 'MX':
					MXApi.purchase(params);
					break;
				case 'GN':
					ExternalApi.apiNormalScreenEvent();
					GNApi.purchase(params);
					break;
				case 'SP':
					Log.alert('SPPromo Passed');
					SPApi.purchase(params);
					break;
				case 'AI':
					ExternalApi.apiNormalScreenEvent();
					AIApi.purchase(params);
					break;
				default:
					App.network.purchase(params);
			}
		}
		
		public static function apiSetsEvent(params:Object):void {
			switch(App.social) {
				case 'VK':
				case 'DM':	
					if (ExternalInterface.available)
					{
						ExternalInterface.addCallback("updateBalance", params.callback);
						ExternalInterface.call("purchase", params);
					}	
					break;
				case 'GN':
					ExternalApi.apiNormalScreenEvent();
					YBApi.purchase(params);
					break
				case 'FB':
				case 'NK':
					ExternalApi.apiNormalScreenEvent();
					if (ExternalInterface.available)
					{
						ExternalInterface.addCallback("updateBalance", params.callback);
						ExternalInterface.call("purchase", params);
					}
					break;
				default:
					ExternalApi.apiNormalScreenEvent();
					App.network.purchase(params);
			}
		}
		
		public static function onImagePostComplete(data:*, object:Object, callback:Function):void {
			var hasCallback:Boolean = false;
			var response:Object = JSON.parse(data);
			if (callback != null) {
				hasCallback = true;
				addPostCallback(callback);
				object['hasCallback'] = hasCallback;
			}
			ExternalInterface.call("wallPost", object, response);	
		}
		
		public static function notifyFriend(params:Object):void
		{
			if (!ExternalInterface.available) return;
			
			Log.alert('NOTIFY:');
			Log.alert(params.uid);
			Log.alert(params.text);
			
			ExternalApi.apiNormalScreenEvent();
			
			switch(App.social) {
				case 'HV':
				case 'VK':
				case 'DM':
					ExternalInterface.addCallback("updateNotify", function(callback:Boolean = true):void {
						if (params.callback)
							params.callback();
					});
					ExternalInterface.call("notify", params.uid, App.user.id, params.text);
					break;
				case 'OK':
				//case "ML":
					break;
				default:
					ExternalInterface.addCallback("updateNotify", function(callback:Boolean = true):void {
						if (params.callback)
							params.callback();
					});
					ExternalInterface.call("notify", params.uid, params.text, params.type);
			}
		}
		
		public static function notifyIngameFriends(params:Object = null):void {
			if (!params) params = { };
			
			ExternalApi.notifyFriend( {
				uid:	App.user.friends.ingameFriendList,
				text:	params.message || ''
			});
		}
		
		
		public static function apiWallPostEvent(type:uint, bitmap:Bitmap, owner_id:String, message:String, sID:uint = 0, callback:Function = null, settings:Object = null):void {
			
			if (!ExternalInterface.available) return;
			
			var pngStream:ByteArray = PNGEncoder.encode(bitmap.bitmapData);
			var hasCallback:Boolean = false;
			
			if (App.self.stage.displayState != StageDisplayState.NORMAL) {
				needBackAtFullScreen = true;
			}
			
			ExternalApi.apiNormalScreenEvent();
			
			switch(App.self.flashVars.social) {
				case 'VK':
				case 'DM':
					
					var ldr:MultipartURLLoader = new MultipartURLLoader();
					ldr.addEventListener(Event.COMPLETE, function(e:Event):void 
					{
						var response:Object = JSON.parse(e.currentTarget.loader.data);
						if (callback != null) 
						{
							hasCallback = true;
							addPostCallback(callback);
						}
						ExternalInterface.call("wallPost", {owner_id:owner_id, message:message, hasCallback:hasCallback}, response);
					});
					ldr.addVariable('url', App.network.wallServer.upload_url);
					ldr.addFile(pngStream, "image.png", "file", 'image/png');
					ldr.load('http://western.islandsville.com/iframe/upload.php');
					
					break;
					
				case 'PL':
					if (callback != null) {
						hasCallback = true;
						addPostCallback(callback);
					}
					PLApi.wallPost({type:type,owner_id:owner_id,msg:message,hasCallback:hasCallback,sID:sID});
					
					break;
				
				case 'YB':
					if (callback != null) {
						hasCallback = true;
						addPostCallback(callback);
					}
					YBApi.wallPost({type:type,owner_id:owner_id,msg:message,hasCallback:hasCallback,sID:sID});
					break;
					
				case 'ML':
					if (callback != null) {
						Log.alert('hasCallback ML');
						hasCallback = true;
						addPostCallback(callback);
					}
					App.network.wallPost( {
						type:type,
						owner_id:owner_id,
						bytes:pngStream,
						msg:message,
						hasCallback:hasCallback,
						sID:sID
					});
					break;
				case 'MX':
					if (callback != null) {
						Log.alert('hasCallback MX');
						hasCallback = true;
						addPostCallback(callback);
					}
					MXApi.wallPost({type:type,owner_id:owner_id,msg:message,hasCallback:hasCallback,sID:sID});
					break;
					
				case 'NK':
					if (callback != null) {
						hasCallback = true;
						addPostCallback(callback);
					}
					NKApi.wallPost({type:type,owner_id:owner_id,msg:message,hasCallback:hasCallback,sID:sID});
					
					break;
					break;
				case 'OK':
					
					if (callback != null)
					{
						addPostCallback(callback);
					}
					
					App.network.wallPost( {
						type:type,
						owner_id:owner_id,
						bytes:pngStream,
						msg:message,
						sID:sID,
						callback:callback,
						url:settings.url
					});
					break;
				case 'HV':
					HVApi.wallPost( {
						type:type,
						owner_id:owner_id,
						title:Locale.__e('flash:1382952379704'),
						msg:message,
						sID:sID
					});
					if (callback != null) {
						hasCallback = true;
						addPostCallback(callback);
					}
					break;
				case 'GN':
					ExternalApi.apiNormalScreenEvent();					
					var userArray:Array = [];
					var title:String = ""
					userArray.push(owner_id);
					if (ExternalInterface.available)
					{
						ExternalInterface.call("shareApp", userArray, title, message);
					}
					break;
				case 'FB':
					if (callback != null) {
						hasCallback = true;
						addPostCallback(callback);
					}
					App.network.wallPost( {
						type:type,
						owner_id:owner_id,
						bytes:pngStream,
						msg:message,
						hasCallback:hasCallback,
						sID:sID
					});
					break;
				case 'FS':
					if (callback != null){
						hasCallback = true;
						addPostCallback(callback);
					}
					FSApi.wallPost({type:type,owner_id:owner_id,msg:message,hasCallback:hasCallback,sID:sID});
					
					break;
					
				default:
					if (callback != null) {
						hasCallback = true;
						addPostCallback(callback);
					}
					App.network.wallPost( {
						type:type,
						owner_id:owner_id,
						bytes:pngStream,
						msg:message,
						hasCallback:hasCallback,
						sID:sID
					});
			}
		}
		
		
		public static function apiAppRequest(to:Array, message:String, callback:Function = null):void 
		{
			var gnReqTitle:String = "OK";	
			switch(App.self.flashVars.social) {
				case 'FB':
					ExternalApi.apiNormalScreenEvent();
					if (ExternalInterface.available){
						ExternalInterface.call("appRequest", to.splice(0,25).join(","), message, callback);
					}
					break;
				case 'GN':
					ExternalApi.apiNormalScreenEvent();
					if (ExternalInterface.available)
					{
						ExternalInterface.call("shareApp", to, gnReqTitle, message);
					}
					break;
			}
		}
		
		public static function addPostCallback(callback:Function):void {
			postCallback = function(response:*):void {
				Log.alert(response);
				callback(response);
				postCallback = null;
				if (!LevelUpWindow.needBonusWindow) askOpenFullscreen();
			}
			ExternalInterface.addCallback("onWallPostComplete", postCallback);
		}
		
		public static function onWallPostComplete(response:*):void {
			Cc.log('\n onWallPostComplete: ' + JSON.stringify(response));
		}
		
		public static var needBackAtFullScreen:Boolean = false;
		public static function apiNormalScreenEvent(auto:Boolean = true):void {
			if (ExternalInterface.available) {
				if (auto && App.self.stage.displayState != StageDisplayState.NORMAL) {
					needBackAtFullScreen = true;
				}
				
				switch(App.self.flashVars.social) {
					case 'VK':
					case 'DM':	
						if (ExternalInterface.available)
						{
							ExternalInterface.addCallback("gotoNormalScreen", function():void {
								App.self.stage.displayState = StageDisplayState.NORMAL;
								//App.map.center();
							});
						}
						break;
					case 'PL':
					case 'FB':
					case 'NK':
					case 'SP':
						ExternalInterface.call("gotoNormalScreen");
					default:
						App.self.stage.displayState = StageDisplayState.NORMAL;
				}
			}
		}
		
		public static function gotoScreen():void {
			if (ExternalInterface.available){
				
				switch(App.social) {
					case 'VK':
					case 'DM':	
					case 'PL':
					case 'FB':
					case 'SP':
						if(App.self.stage.displayState != StageDisplayState.NORMAL){
							ExternalInterface.call("gotoFullScreen");
						}else {
							ExternalInterface.call("gotoNormalScreen");
						}
					case 'OK':
					case 'ML':
					case 'NK':	
						break;
				}
			}
		}
		
		public static function askOpenFullscreen():void {
			if (!needBackAtFullScreen || App.self.stage.displayState == StageDisplayState.FULL_SCREEN) return;
			needBackAtFullScreen = false;
			
			new SimpleWindow( {
				title:		Locale.__e('flash:1416219745731'),
				text:		Locale.__e('flash:1416219764268'),
				dialog:		true,
				confirm:	function():void {
					App.self.stage.displayState = StageDisplayState.FULL_SCREEN;
				},
				cancel:		function():void {
					//
				}
			}).show();
		}
		
		public static function og(act:String, obj:String):void {
			if (ExternalInterface.available){
				ExternalInterface.call("og", act, obj);
			}
		}
		
		public static function _6epush(params:Array):void {
			return;
			if (ExternalInterface.available){
				ExternalInterface.call("_6epush", params);
			}
		}
		
		public static function _6push(params:Array):void {
			return;
			if (ExternalInterface.available){
				ExternalInterface.call("_6push", params);
			}
		}
		
		public static function getLeads():void {
			if (ExternalInterface.available){
				ExternalInterface.call("getLeads");
				ExternalInterface.addCallback("onGetLeads", function(show:*):void {
					
				});
			}
		}
		
		public static function openLeads():void {
			if (ExternalInterface.available){
				ExternalInterface.call("openLeads");
			}
		}
		
		public static function getUsersProfile(IDs:Array, callback:Function):void {
			if (ExternalInterface.available){
				var response:Object = { };
				
				ExternalInterface.addCallback("onGetProfile", function(profile:*):void {
					
					if (profile is String) {
						delete response[profile];
						return;
					}
					
					response[profile.uid] = profile;
					var full:Boolean = true;
					
					for each(var item:* in response) {
						if (item == 0) {
							full = false;
							break;
						}
					}
					if (full == true) {
						callback(response);
					}
				});
				
				for each(var id:String in IDs){
					response[id] = 0;
					ExternalInterface.call("getPerson", id);
				}
			}else {
				response = { };
				response['132771'] = {
					first_name:"fantasy1",
					last_name:"",
					photo:"http://dreams.islandsville.com/resources/icons/avatars/ava_bear50.jpg",
					uid:"132771"
				};
				response['132772'] = {
					first_name:"fantasy2",
					last_name:"",
					photo:"http://dreams.islandsville.com/resources/icons/avatars/ava_bear50.jpg",
					uid:"132772"
				};
				response['134471'] = {
					first_name:"rooms3",
					last_name:"",
					photo:"http://dreams.islandsville.com/resources/icons/avatars/ava_bear50.jpg",
					uid:"134471"
				};
				response['134472'] = {
					first_name:"jjjj",
					last_name:"",
					photo:"http://dreams.islandsville.com/resources/icons/avatars/ava_bear50.jpg",
					uid:"134472"
				};
				callback(response);
			}
		}
	
		public static function onReedem(e:MouseEvent):void {
			if (ExternalInterface.available) {
				Log.alert('onReedem');
				ExternalInterface.call("renderGC");
				ExternalInterface.addCallback("onRedeem", function(count:int):void {
					Post.send( {
						'ctr':'stock',
						'act':'giftcard',
						'uID':App.user.id,
						'count':count
					}, function(error:*, result:*, params:*):void {
						if (!error) {
							App.user.stock.add(Stock.FANT, count);
						}
					});
				});
			}			
		}
		
		
		public static var visibleTrialpay:Boolean = false;
		public static function showTrialpay():void {
			if (ExternalInterface.available){
				Post.send( {
					'ctr':'trialpay',
					'act':'visible',
					'uID':App.user.id
				}, function(error:*, result:*, params:*):void {
					if (!error) {
						if (result['visible'] != undefined && result['visible'] == 1) {
							visibleTrialpay = true;
							if(App.ui != null && App.ui['rightPanel'] != undefined){
								//App.ui.rightPanel.addFreebie();
							}
							ExternalInterface.call("showTrialpay");
						}
					}
				});
			}		
		}
		
		public static function onCardInfo(e:MouseEvent = null):void {
			//return;
			if (ExternalInterface.available){
				ExternalInterface.call("payerPromotion");
				ExternalInterface.addCallback("onPayerPromotion", function():void {
					Post.send( {
						'ctr':'stock',
						'act':'fbpromotion',
						'uID':App.user.id
					}, function(error:*, result:*, params:*):void {
						if (!error) {
							updateBalance();
						}
					});
				});
			}
			//App.ui.rightPanel.freebieBttn.visible = false;
			App.network.profile['is_eligible_promo'] = 0;
		}
		
		public static function checkID(_callback:Function):void {
			if (ExternalInterface.available) {
				Log.alert('CHECK ID');
				ExternalInterface.addCallback("getIDCallback", _callback);
				ExternalInterface.call("getID");
			}
		}
		
	}
	
	
}
