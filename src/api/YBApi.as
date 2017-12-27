package api
{
	import api.com.adobe.json.JSONDecoder;
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
	import flash.utils.ByteArray;
	import flash.utils.setTimeout;
	import flash.events.Event;
	import wins.SimpleWindow;
	
	import com.adobe.images.PNGEncoder;
	import com.adobe.images.JPGEncoder;
	
	import api.com.adobe.crypto.MD5;
		
	public class YBApi
	{
	
		public var flashVars:Object;
		
		public static var dictionary:Object = {
			
			0: function(sID:uint):Object {
					return{
						title:App.data.storage[sID].title,
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
					return {
						callbackName:'levelUpPost',
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
		
		public function YBApi(flashVars:Object = null)
		{
			/*this.flashVars = flashVars;
			if(ExternalInterface.available){
				ExternalInterface.addCallback("initNetwork", onNetworkComplete);
				ExternalInterface.call("initNetwork");
			}else{
				onNetworkComplete( {
					appFriends:flashVars.appFriends,
					profile: { }
				});
			}*/
		}
		
		/*public function onNetworkComplete(data:Object):void {
			
			appFriends = takeFriendsUids(data.appFriends)
			this.profile = data.profile; 
			//setTimeout(function():void{if(App.user.id == '163792'){Post.addToArchive("GAME_DATA_ADDED_TO_ARCHIVE \n"+JSON.stringify(data));}},5000);
			Log.alert('YBApi: onNetworkComplete');
			Log.alert('appFriends: ' + appFriends);
			App.self.onNetworkComplete(this);
		}*/
		
		
		private function takeFriendsUids(data:Array):Array {
			var result:Array = [];
			
			var L:int = data.length;
			for (var i:int = 0; i < L; i++) {
				if((data[i] is Array || data[i] is Object) && data[i].hasOwnProperty('uid')){
					result.push(String(data[i].uid));
					friends[data[i].uid] = data[i];
				}else{
					result.push(String(data[i]));
					friends[data[i]] = data[i];
				}
			}
			
			return result;
		}
		
		
		public static function purchase(params:Object):void
		{
			Log.alert('YBAPI PURCHASE');
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
				
				var name:String = "";
				var money:String = "";
				
				switch(params.money) {
					
					case "Coins":
							name = App.data.storage[Stock.COINS].title;
							money = "1";
						break;
					
					case "promo":	
							name = params.description;
							money = "3";
						break;
						
					case "sets":	
							name = params.title;
							money = "4";
						break;
					
					case "bigsale":	
							name = params.title;
							money = "5";
						break;
						
					case "Sets":	
							name = params.title;
							money = "6";
						break;	
					case "energy":
							name = params.title;
							money = "7";
						break;
					
					default:
							name = App.data.storage[Stock.FANT].title;
							money = "2";
						break;	
				}
				Log.alert('PAYMENT PARAMS:');
				Log.alert(params);
				
				var result:Array = params.item.split("_");
				var SKU_ID:String;
				if(money == '5'){
					SKU_ID = money + '' + result[2] + '' + result[1];
				}else {
					SKU_ID = money + result[1];
				}
					
				var obj:Object = {
					type:		params.money,
					SKU_ID:		SKU_ID,
					name:		name,
					price:		params.votes,
					count:		params.count
				}
				
				ExternalInterface.call("purchase", obj);
			}
		}
		
		
		public static function wallPost(params:Object):void {
			
			var obj:Object = dictionary[params.type](params.sID);
			obj.title =  String(obj.title).substr(0, 20);
			var url:String = obj.url;
			Log.alert('ybApi wallPost reached ');
			
			if (ExternalInterface.available) {
				Log.alert('wallPost');
				ExternalInterface.call("wallPost", {uid:App.user.id, oid:params.owner_id, title:obj.title, msg:params.msg, hasCallback:params.hasCallback});
			}	
		}
		
	}		
		
}