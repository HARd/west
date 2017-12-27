package api
{
	
	import com.adobe.crypto.HMAC;
	import com.adobe.crypto.SHA1;
	import core.Log;
	import core.Post;
	import flash.external.ExternalInterface;

	
	public class MXApi
	{
	
		public var flashVars:Object;
		private static var keys:Array = [
			'8d77e17fb3a94ad80467d183481a591325213f44',
			'384ddfb326b361b9a23105c2f1eac86d682f8492'
		];
		
		public static var dictionary:Object = {
			
			0: function(sID:uint):Object {
					return{
						title:'',//App.data.storage[sID].title,
						//url:Config.getIcon(App.data.storage[sID].type, App.data.storage[sID].preview)
						url:App.lang == 'ru' ? Config.getImage('mail', 'PostsPic_game') : Config.getImage('post', 'postPicGame_en','jpg')
					}
			},
			// Новая территория
			1: function(e:* = null):Object {
					return{
						title:Locale.__e("flash:1382952379697"),
						url:App.lang == 'ru' ? Config.getImage('mail', 'PostsPic_territory') : Config.getImage('post', 'postPicTerritory_en','jpg')
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
			//Quest
			4: function(sID:uint):Object {
					return{
						title:Locale.__e("flash:1382952379702"),
						url:App.lang == 'ru' ? Config.getImage('mail', 'PostsPic_game') : Config.getImage('post', 'postPicQuest_en','jpg')
					}
			},
			// Уровень
			5: function(sID:uint):Object {
				return{
					title:Locale.__e("flash:1382952379703"),
					url:App.lang == 'ru' ? Config.getImage('mail', 'PostsPic_level') : Config.getImage('post', 'postPicLevel_en','jpg')
				}
			},
			6: function(sID:uint):Object {
					return{
						title:Locale.__e("flash:1382952379702"),
						url:App.lang == 'ru' ? Config.getImage('mail', 'PostsPic_game') : Config.getImage('post', 'postPicGame_en','jpg')
					}
			},
			7: function(qID:uint):Object {
					return{
						title:Locale.__e(App.data.quests[qID].title),
						url:App.lang == 'ru' ? Config.getImage('mail', 'PostsPic_game') : Config.getImage('post', 'postPicGame_en','jpg')
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
		
		public function MXApi(flashVars:Object)
		{
			this.flashVars = flashVars;
			if(ExternalInterface.available){
				ExternalInterface.addCallback("initNetwork", onNetworkComplete);
				ExternalInterface.call("initNetwork");
			}else{
				onNetworkComplete( {
					appFriends:flashVars.appFriends,
					profile: { }
				});
			}
		}
		
		public function onNetworkComplete(data:Object):void {
			
			appFriends = takeFriendsUids(data.appFriends)
			this.profile = data.profile;
			
			Log.alert('MXApi: onNetworkComplete');
			Log.alert({appFriends:appFriends});
			Log.alert({allData:data});
			//App.self.onNetworkComplete(this);
			App.self.onNetworkComplete(data);
		}
		
		
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
			Log.alert('MX start purchase');
			if (ExternalInterface.available) {
				Log.alert('MX external interface');
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
					case "energy":
						money = "7";
						break;
						
					default:
						money = "2";
						break;	
				}
				
				var result:Array = params.item.split("_");
				var SKU_ID:String;
				if(money == '5'){
					SKU_ID = money + '' + result[2] + '' + result[1];
				}else {
					SKU_ID = money + result[1];
				}
				
				//////////////////////////// chamele0n
				if (!('handler' in App.self.flashVars)) {
					App.self.flashVars.handler = 'http://w-mx.islandsville.com/app/api/MX/MXPayment.php';					
				}				
				if (!('testMode' in App.self.flashVars)) {
					App.self.flashVars.testMode = 1;
				}
				
				var sig:Array = [
					'callback_url=' + encodeURIComponent(App.self.flashVars.handler),
					'inventory_code=' + SKU_ID,
					'is_test=' + (int(App.self.flashVars.testMode) == 1 ? 'true' : 'false'),
					'item_id=' + SKU_ID,
					'item_price=' + params.votes
				];
				
				var _string:String = encodeURIComponent(sig.join('&'));
				var _key:String = keys[int(App.self.flashVars.testMode)] + '&';
				//var SIGNATURE:String = HMAC.hash2(_key, _string, SHA1);
				//////////////////////////////
				
				
				var obj:Object = {
					info: {
						type: params.money,
						count: params.count,
						string: _string
					},
					pay: {
						amount: params.votes,
						signature: HMAC.hash2(_key, _string, SHA1),
						item_id: SKU_ID,
						is_test: (int(App.self.flashVars.testMode) == 1 ? 'true' : 'false'),
						code: params.item,
						url: App.self.flashVars.handler
					}
				}
				
				Log.alert('MX_PURCHASE');
				ExternalInterface.call("purchase", obj);
			}
		}
		
		
		public static function wallPost(params:Object):void {
			
			var obj:Object = dictionary[params.type](params.sID);
			var url:String = obj.url;
				
			if (ExternalInterface.available) {
				Log.alert('wallPost');
				ExternalInterface.call("wallPost", {uid:App.user.id, oid:params.owner_id, title:params.msg, msg:obj.title,hasCallback:params.hasCallback});
			}	
		}
		
	}		
		
}