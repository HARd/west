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
	
	import com.adobe.images.PNGEncoder;
	import com.adobe.images.JPGEncoder;
	
	import api.com.adobe.crypto.MD5;
		
	public class HVApi
	{
		
		public static var dictionary:Object = {
			0: function(sID:uint):Object {
					return{
						title:'',//App.data.storage[sID].title,
						//url:Config.getIcon(App.data.storage[sID].type, App.data.storage[sID].preview)
						url:App.lang == 'ru' ? Config.getImage('mail', 'PostsPic_game') : Config.getImage('post/small', 'postPicGame_Small_en','jpg')
					}
			},
			// Новая территория
			1: function(e:* = null):Object {
					return{
						title:Locale.__e("flash:1382952379697"),
						url:App.lang == 'ru' ? Config.getImage('mail', 'PostsPic_territory') : Config.getImage('post/small', 'Investigate_an_Area_Small_en','jpg')
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
						url:App.lang == 'ru' ? Config.getImage('mail', 'PostsPic_game') : Config.getImage('post/small', 'Complete_a_Quest_Small_en','jpg')
					}
			},
			// Уровень
			5: function(sID:uint):Object {
				return{
					title:Locale.__e("flash:1382952379703"),
					url:App.lang == 'ru' ? Config.getImage('mail', 'PostsPic_level') : Config.getImage('post/small', 'Reach_a_Level_Small_en','jpg')
				}
			},
			6: function(sID:uint):Object {
					return{
						title:Locale.__e("flash:1382952379702"),
						url:App.lang == 'ru' ? Config.getImage('mail', 'PostsPic_game') : Config.getImage('post/small', 'postPicGame_Small_en','jpg')
					}
			},
			7: function(qID:uint):Object {
					return{
						title:Locale.__e(App.data.quests[qID].title),
						url:App.lang == 'ru' ? Config.getImage('mail', 'PostsPic_game') : Config.getImage('post/small', 'postPicGame_Small_en','jpg')
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
		
		public function HVApi()
		{
		
		}
		
		
		public static function purchase(params:Object):void
		{
			
			if (ExternalInterface.available){
				ExternalInterface.addCallback("spendMoney", function():void {
					
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
					case "Sets":
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
				if(money == '5'){
					params.sid = money + '' + result[2] + '' + result[1];
				}else {
					params.sid = money + result[1];
				}
				ExternalInterface.call("purchase", params);
			}
		}
		
		public static function wallPost(params:Object):void {
			
			Log.alert('Final wallpost');
			Log.alert(params);
			
			var obj:Object = dictionary[params.type](params.sID);
			var url:String = obj.url;
			
			if (ExternalInterface.available)
				ExternalInterface.call("wallPost", params.msg, url);
		}
		
	}		
		
}