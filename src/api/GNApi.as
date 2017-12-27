package api
{
	import core.Log;
	import core.Post;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.external.ExternalInterface;
	import flash.geom.Point;
	import flash.utils.ByteArray;
	import flash.utils.setTimeout;
	import wins.SimpleWindow;
	import wins.Window;
	
	import com.adobe.images.JPGEncoder;
	
		
	public class GNApi
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
		
		public function GNApi(flashVars:Object = null)
		{
			this.flashVars = flashVars;
			if (ExternalInterface.available) 
			{
				ExternalInterface.addCallback("initNetwork", onNetworkComplete);
				ExternalInterface.call("initNetwork");
			}else {
				onNetworkComplete( {
					appFriends:flashVars.appFriends,
					profile: { }
				});
			}
		}
		
		public function onNetworkComplete(data:Object):void
		{			
			appFriends = takeFriendsUids(data.appFriends)
			friends = data.friends;
			this.profile = data.profile;
			Log.alert('appFriends: ' + appFriends);
			App.self.onNetworkComplete(this);
		}		
		
		private function takeFriendsUids(data:Array):Array 
		{
			var result:Array = [];			
			var L:int = data.length;
			
			for (var i:int = 0; i < L; i++)
			{
				if ((data[i] is Array || data[i] is Object) && data[i].hasOwnProperty('uid'))
				{
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
			Log.alert('GESOTEN purchase');
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
				
				ExternalInterface.addCallback("noMoney", function():void 
				{					
					Window.closeAll();
					
					new SimpleWindow( {
						text:Locale.__e("flash:1461674941437"),
						height:250,
						popup:true
					}).show();	
				});
				
				
				var money:String = "";
				
				switch(params.money) {					
					case "Coins":
							money = "1";
						break;					
					case "promo":	
							money = "3";
						break;						
					case "Sets":	
							money = "4";
						break;
					case "bigsale":	
							money = "5";
						break;	
					case "energy":
							money = "7";
						break;
					default:
							money = "2";
						break;	
				}
					
				Log.alert(money);
				var result:Array = params.item.split("_");
				if(money == '5'){
					params.sid = money + '' + result[2] + '' + result[1];
				}else {
					params.sid = money + result[1];
				}
				
				Log.alert('checkPayment');
				ExternalInterface.call("checkPayment", params);
			}
		}
		
		
		public static function wallPost(params:Object):void {
			
			var obj:Object = dictionary[params.type](params.sID);
			obj.title =  String(obj.title).substr(0, 20);
			var url:String = obj.url;
			
			if (ExternalInterface.available) {
				Log.alert('wallPost');
				ExternalInterface.call("wallPost", {uid:App.user.id, oid:params.owner_id, title:obj.title, msg:params.msg, hasCallback:params.hasCallback});
			}	
		}		
	}	
}