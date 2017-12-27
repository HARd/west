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
		
	public class FBApi
	{
		public var flashVars:Object;
		
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
		public var allFriends:Array = [];
		public var otherFriends:Object = {};
		public var profile:Object = { };
		public var friends:Object = { };
		public var albums:Object = { };
		public var currency:Object = { };
		

		public function FBApi(flashVars:Object)
		{
			Log.alert('Init FB API');
			this.flashVars = flashVars;
			if (ExternalInterface.available){
				ExternalInterface.addCallback("initNetwork", onNetworkComplete);
				ExternalInterface.call("initNetwork");
			}else {
				App.self.onNetworkComplete( {
					profile:flashVars.profile,
					appFriends:flashVars.appFriends
				});
			}
		}
		
		
		private function onNetworkComplete(data:*):void {
			for (var prop:String in data) {
				if(this[prop] != null)
					this[prop] = data[prop];
			}
			Log.alert(this);
			App.self.onNetworkComplete(this);
		}
		
		public function wallPost(params:Object):void {
			Log.alert('WALLPOST FB');
			Log.alert(params);
			
			if (!FBApi.dictionary[params.type]) params.type = 999;
			var obj:Object = FBApi.dictionary[params.type](params.sID);
			obj.title = params.msg;
			
			Log.alert(params.type);
			
			if (ExternalInterface.available) {
				ExternalInterface.call("wallPost", App.user.id, params.owner_id, obj.title, params.msg, obj.url, null);
			}
		}
	}
}