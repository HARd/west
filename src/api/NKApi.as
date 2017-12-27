package api
{
	import core.Log;
	import core.Post;
	import flash.external.ExternalInterface;
	
	import com.adobe.images.JPGEncoder;
	
		
	public class NKApi
	{
		
		/*public static var dictionary:Object = {
			
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
		}*/
		public static var dictionary:Object = {
			
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
		
		
		public function NKApi()
		{
		
		}
		
		
		/*public static function wallPost(params:Object):void {
			
			var obj:Object = dictionary[params.type](params.sID);
			var url:String = obj.url;
				
			if (ExternalInterface.available) {
				Log.alert('wallPost');
				ExternalInterface.call("wallPost", {uid:App.user.id, oid:params.owner_id, title:params.msg, msg:obj.title, url:url});
			}	
		}*/
		
		
		public static function wallPost(params:Object):void {
			Log.alert('WALLPOST NK');
			Log.alert(params);
			
			if (!FBApi.dictionary[params.type]) params.type = 999;
			var obj:Object = FBApi.dictionary[params.type](params.sID);
			//obj.title = params.msg;
			
			Log.alert(obj.url);
			
			if (ExternalInterface.available)
				//ExternalInterface.call("wallPost", App.user.id, params.owner_id, obj.title, params.msg, obj.url, null);
				ExternalInterface.call("wallPost", {uid:App.user.id, oid:params.owner_id, title:params.msg, msg:obj.title, url:obj.url});
		}
		
	}		
		
}