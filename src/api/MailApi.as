package api
{
	import core.Log;
	import core.MultipartURLLoader;
	import core.Post;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.external.ExternalInterface;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	import flash.events.Event;
	
	import com.adobe.images.PNGEncoder;
	
	import api.com.adobe.crypto.MD5;
		
	public class MailApi
	{
		public var flashVars:Object;
		
		public var dictionary:Object = {
			
			0: function(sID:uint):Object {
					return{
						title:'',//App.data.storage[sID].title,
						url:Config.getIcon(App.data.storage[sID].type, App.data.storage[sID].preview)
					}
			},
			// Новая территория
			1: function(e:* = null):Object {
					return{
						title:Locale.__e("flash:1382952379697"),
						url:Config.getImage('mail', 'PostsPic_territory')
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
						title:Locale.__e("flash:1382952379702"),
						url:Config.getImage('mail', 'PostsPic_game')
					}
			},
			// Уровень
			5: function(sID:uint):Object {
				return{
					title:Locale.__e("flash:1382952379703"),
					url:Config.getImage('mail', 'PostsPic_level')
				}
			},
			6: function(sID:uint):Object {
					return{
						title:Locale.__e("flash:1382952379702"),
						url:Config.getImage('mail', 'PostsPic_game')
					}
			},
			7: function(qID:uint):Object {
					return{
						title:Locale.__e(App.data.quests[qID].title),
						url:Config.getImage('mail', 'PostsPic_game')
					}	
			},
			// Постройка
			8: function(sID:uint):Object {
					return{
						title:Locale.__e("flash:1428400868944"),
						url:Config.getIcon(App.data.storage[sID].type, App.data.storage[sID].preview)
					}
			},
			999: function(sID:uint):Object {
				return{
					title:App.data.storage[sID].title,
					url:Config.getIcon(App.data.storage[sID].type, App.data.storage[sID].preview)
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
		
		public function MailApi(flashVars:Object)
		{
			this.flashVars = flashVars;
			if(ExternalInterface.available){
				ExternalInterface.addCallback("initNetwork", onNetworkComplete);
				ExternalInterface.call("initNetwork");
			}else{
				onNetworkComplete( { appFriends:[], profile: { }} );
			}
		}
		
		public function onNetworkComplete(data:Object):void {
			
			appFriends = takeFriendsUids(data.appFriends)
			this.profile = data.profile;
			
			Log.alert('MailApi: onNetworkComplete');
			Log.alert('appFriends: ' + appFriends);
			App.self.onNetworkComplete(this);
		}
		
		private function takeFriendsUids(data:Array):Array {
			var result:Array = [];
			
			var L:int = data.length;
			for (var i:int = 0; i < L; i++) {
				result.push(String(data[i].uid));
				friends[data[i].uid] = data[i];
			}
			
			return result;
		}
		
		public function wallPost(params:Object):void {
			
			Log.alert('WALLPOST');
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
		/*
		public function wallPost(params:Object):void {
			var ldr:MultipartURLLoader = new MultipartURLLoader(); 
			ldr.addEventListener(Event.COMPLETE, function(e:Event):void {
				var response:Object = JSON.parse(e.currentTarget.loader.data);
				var url:String = response.url;
				
				params.msg = params.msg.replace(/http[^ ]+/, "");
				
				var attach:Object = {
				  'title':dictionary[params.type],
				  'text': params.msg,
				  'img_url': response.url,
				  'action_links': [
						{'text': Locale.__e('flash:1382952379704'), 'href': Config.appUrl}
				  ]
				}
				
				e.currentTarget.dispose();
				
				if (ExternalInterface.available){
					if (params.owner_id == App.user.id) {
						ExternalInterface.call("streamPost", {hasCallback:params.hasCallback}, attach);
					}else{
						attach['uid'] = params.owner_id;
						ExternalInterface.call("guestbookPost", {hasCallback:params.hasCallback}, attach);
					}
				}
			});
			
			ldr.addFile(params.bytes, "file", "image", "image/png");
			var pid:* = new Date().time;
			ldr.addVariable("crc",  MD5.hash('ytf$%$yuGFis*&udh' + pid));
			ldr.addVariable("pid",  pid);
			ldr.load("http://dreams.islandsville.com/ok/59b514174b/img.php");
		}*/
		
		public function purchase(params:Object):void
		{
			
			if (ExternalInterface.available){
				ExternalInterface.addCallback("updateBalance", function():void {
					
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
				});
				
				var service_name:String = "";
				var money:String = "";
				
				switch(params.money) {
					
					case "Coins":
							service_name = App.data.storage[Stock.COINS].title;
							money = "1";
						break;
					
					case "promo":	
							service_name = params.description;
							money = "3";
						break;
						
					case "sets":	
							service_name = params.title;
							money = "4";
						break;
					
					case "bigsale":	
							service_name = params.title;
							money = "5";
						break;
					case "Sets":	
							service_name = params.title;
							money = "6";
						break;
					case "energy":	
							service_name = params.title;
							money = "7";
						break;
						
					default:
							service_name = App.data.storage[Stock.FANT].title;
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
					
				var obj:Object = {
					service_id:		service_id,
					service_name:	service_name,
					mailiki_price:	params.votes
				}
				
				ExternalInterface.call("purchase", obj);
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
			
			//url: 'http://www.sports.ru/images/object_19.1218129668.jpg',
			//aid: '_myphoto',
			//set_as_cover: true
		}
	}
}