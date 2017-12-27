package api
{
	import api.com.adobe.json.JSONDecoder;
	import core.Load;
	import core.Log;
	import core.MultipartURLLoader;
	import core.Post;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.external.ExternalInterface;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.system.Capabilities;
	import flash.utils.ByteArray;
	import flash.utils.setTimeout;
	import flash.events.Event;
	import playerio.Client;
	import playerio.PlayerIO;
	import playerio.YahooProfile;
	
	import com.adobe.images.PNGEncoder;
	import com.adobe.images.JPGEncoder;
	
	import api.com.adobe.crypto.MD5;
		
	public class YNApi
	{
		public var flashVars:Object;
		
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
						url:Config.getIcon(App.data.storage[sID].type, App.data.storage[sID].preview)
					}
			},
			3: function(sID:uint):Object {
					return{								
						title:Locale.__e("flash:1382952379699"),
						url:Config.getIcon(App.data.storage[sID].type, App.data.storage[sID].preview)
					}
			},
			4: function(sID:uint):Object {
					return{								
						title:Locale.__e("flash:1382952379700"),
						url:Config.getIcon(App.data.storage[sID].type, App.data.storage[sID].preview)
					}
			},
			5: function(sID:uint):Object {
					return{								
						title:Locale.__e("flash:1382952379701"),
						url:Config.getIcon(App.data.storage[sID].type, App.data.storage[sID].preview)
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
						url:Config.getQuestIcon('icons', App.data.personages[App.data.quests[qID].character].preview)
					}	
			},
			8: function(sID:uint):Object {
					return{				
						title:Locale.__e("flash:1382952379703"),
						url:Config.getImage('mail', 'promo', 'jpg')
					}
			}
		}
		
		
		public var appFriends:Array = [];
		public var profile:Object = { };
		public var friends:Object = { };
		public var otherFriends:Object = null;
		
		private var apiObject:Object;
		
		//data.friends["18090249874169842929"] = { };
		//App.network['friends'] = { "18090249874169842929": { "aka":"", "level":"50", "sex":"f", "energy":5, "fill":0, "uid":"18090249874169842929", "first_name":"Анна", "last_name":"Чистилина", "photo":"http://avt.appsmail.ru/mail/umkapost4/_avatar50" }};
		
		private var client:Client;
		private var inviteFunction:Function;
		
		public function YNApi(flashVars:Object)
		{
			var that:YNApi = this;
			this.flashVars = flashVars;
			
			if (!ExternalInterface.available) return;
			
			/*PlayerIO.authenticate(App.self.stage, "lumeria-test-ntnupvjokahokr3vakgq", "public", { userId:flashVars.uid}, null, function(client:Client){
				   trace('connected'); // connection established
				   
			});*/	
			Log.alert( [flashVars.gameId, "public"]);
			Log.alert({ 
				userId:flashVars.viewer_id,
				userToken:flashVars.usertoken
			});
			
			PlayerIO.useSecureApiRequests = true;
			PlayerIO.authenticate(App.self.stage, flashVars.gameId, "public", { 
				userId:flashVars.viewer_id,
				userToken:flashVars.usertoken
			}, null, function(client:Client):void{
				that.client = client;
				//Refresh Yahoo data
				friends = { };
				client.yahoo.refresh(
					function():void{
						inviteFunction = client.gameRequests.showSendDialog;
						
						var user:Object = client.yahoo.profiles.myProfile
						profile = {
							uid 		: user.userId,
							first_name	: user.displayName,
							last_name	:'',
							sex			:'m',
							photo		: user.avatarUrl
						};
						
						Log.alert('YAHOO INFO');
						Log.alert(client.yahoo.relations.friends);
						
						for each(var friend:YahooProfile in client.yahoo.relations.friends) {
							//Check if other user is blocked
							if (client.yahoo.relations.isBlocked(friend.userId)) {
								continue;
							}
							friends[friend.userId] = {
								uid:friend.userId,
								first_name:friend.displayName,
								last_name:'',
								sex:'m',
								photo:friend.avatarUrl
							};
							appFriends.push(friend.userId);
						}
						
						App.self.onNetworkComplete(that);
					}, function():void {
						
					}
				);
				
				Log.alert('YN network connected!');
			});			
		}
		
		public function invite():void {
			inviteFunction('invite',{},function():void{});
		}
		
		
		public function wallPost(params:Object):void {
			Log.alert(params);
			params.msg = params.msg.replace(/http[^ ]+/, "");
			
			params['hash'] = Config.appUrl;
			
			var hashIndex:int = params.msg.indexOf('#oneoff');
			if (hashIndex >= 0) {
				params.hash = 'oneoff=' + params.msg.substr(hashIndex + 7, 13);
			}
			
			var obj:Object = dictionary[params.type](params.sID);
			var url:String = obj.url;//.replace('http://' + Config._resIP, "");
			
			var attach:Object = {
				  'title':obj.title,
				  'text': params.msg,
				  'img_url':url,
				  'action_links': [
						{'text': Locale.__e('flash:1382952379704'), 'href': /*Config.appUrl*/params.hash}
				  ]
				}
				
			if (ExternalInterface.available){
				if (params.owner_id == App.user.id) {
					ExternalInterface.call("streamPost", {hasCallback:params.hasCallback}, attach);
				}else{
					attach['uid'] = params.owner_id;
					ExternalInterface.call("guestbookPost", {hasCallback:params.hasCallback}, attach);
				}
			}	
		  }
		
		public function purchase(params:Object):void
		{
			Log.alert('YN API');
			if (ExternalInterface.available){
				ExternalInterface.addCallback("updateBalance", function(data:Object = null):void {
					if (data) {
						if (params.callback != null)
							params.callback();
							
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
					
					ExternalApi.askOpenFullscreen();
				});
				
				var money:String = "";
				
				switch(params.money) {
					case "Coins":
						money = "1";
						break;
					
					case "promo":
						money = "3";
						break;
						
					case "sets":
						money = "4";
						break;
					
					case "bigsale":	
						money = "5";
						break;
						
					default:
						money = "2";
						break;	
				}
				
				var result:Array = params.item.split("_");
				var service_id:String;
				if(money == '5'){
					service_id = money + '' + result[2] + '' + result[1];
				}else {
					service_id = money + result[1];
				}
				
				ExternalInterface.call("purchase", params);
			}
		}
		
		public function checkGroupMember(callback:Function):void {
			callback(1);
		}
		
		public function saveScreenshot(e:* = null):void {
			
			var scale:Number = 1;
			var W:int = 900;
			var H:int = 700;
			
			var screenBmd:BitmapData = new BitmapData(App.self.stage.stageWidth, App.self.stage.stageHeight);
			screenBmd.draw(App.self);
			
			var screenshot:BitmapData;
			
			if (App.self.stage.stageHeight > 700){
				scale = 0.5;
				screenshot = new BitmapData(App.self.stage.stageWidth * scale, App.self.stage.stageHeight * scale, true, 0);
				var matrix:Matrix = new Matrix();
				matrix.scale(scale, scale);
				
				screenshot.draw(App.self, matrix);
			}else{
				screenshot = new BitmapData(W, H, true, 0);
				screenshot.copyPixels(screenBmd, new Rectangle((App.self.stage.stageWidth - W )/2, 0, W, H), new Point());
			}
			
			var pngStream:ByteArray = PNGEncoder.encode(screenshot);
			
			var ldr:MultipartURLLoader = new MultipartURLLoader(); 
			ldr.addEventListener(Event.COMPLETE, function(e:Event):void {
				var response:Object = JSON.parse(e.currentTarget.loader.data);
				var url:String = response.url;
				
				var attach:Object = {
				  'url': response.url
				}
				
				e.currentTarget.dispose();
				
				if (ExternalInterface.available){
						ExternalInterface.call("saveToAlbum", attach);
				}
			});
			
			ldr.addFile(pngStream, "file", "image", "image/png");
			var pid:* = new Date().time;
			ldr.addVariable("crc",  MD5.hash('ytf$%$yuGFis*&udh' + pid));
			ldr.addVariable("pid",  pid);
			ldr.load(Config.secure + "dreams.islandsville.com/ok/59b514174b/img.php");
		}
	}
}