package api
{
	import core.Log;
	import core.Post;
	import flash.external.ExternalInterface;
	import wins.SimpleWindow;
	
	public class AIApi
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
						title:Locale.__e('flash:1387366508257'),
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
		private var apiObject:Object;
		
		public function AIApi(flashVars:Object)
		{
			this.flashVars = flashVars;
			
			if (ExternalInterface.available) {
				ExternalInterface.addCallback("initNetwork", onNetworkComplete);
				ExternalInterface.call("initNetwork");
			}else {
				onNetworkComplete( { appFriends:[], profile:{}} );
			}
		}
		
		public function onNetworkComplete(data:Object):void {
			
			this.appFriends = data.appFriends
			this.profile = data.profile;
			this.friends = data.friends;
			
			Log.alert('AIApi: onNetworkComplete');
			Log.alert('appFriends: ' + appFriends);
			App.self.onNetworkComplete(this);
		}
				
		public static function wallPost(params:Object):void {
			
			var obj:Object = dictionary[params.type](params.sID);
			var url:String = obj.url;
				
			if (ExternalInterface.available) {
				Log.alert('AI wallPost');
				
				var data:Object = { uid:App.user.id, oid:params.owner_id, title:params.msg, msg:obj.title };
				
				if ([0, 3, 5, 7].indexOf(params.type) != -1) {
					data.title = obj.title;
					data.msg = params.msg;
				}
				ExternalInterface.call("wallPost", data);
			}	
		}
		
		
		static public function purchase(object:Object):void
		{
			Post.send( {
				'ctr':'aima',
				'act':'purchase',
				'uID':App.user.id,
				'sID':object.item,
				'name':object.title
			}, function(error:*, result:*, params:*):void {
				Log.alert('PAYMENT RESULT');
				Log.alert(error);
				Log.alert(result);
				if (!error && result) {
					
					if (result['balance'] != undefined) {
						new SimpleWindow( {
							title:Locale.__e('flash:1421400405118'),
							text:Locale.__e('flash:1421401415421'),
							label:SimpleWindow.ATTENTION,
							dialog:true,
							confirm:function():void {
								ExternalInterface.call("chargeWindow");
							},
							popup:true
						}).show();
					}else {
						Log.alert('paument ai');
						Log.alert(object);
						object.callback();
						ExternalApi.updateBalance();
					}
				}
			});
			
		}
		
	}		
		
}