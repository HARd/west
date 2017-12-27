package core 
{
	import com.junkbyte.console.Cc;
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.geom.ColorTransform;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;
	import wins.AchivementsWindow;
	import wins.SimpleWindow;
	//import com.adobe.serialization.json.JSON;

	public class Post 
	{
		private static const BUSY:uint = 1;
		private static const FREE:uint = 0;
		
		private static const SINGLE:uint = 1;
		private static const MULTI:uint = 2;
		
		private static var queue:Vector.<Object> = new Vector.<Object>();
		private static var sends:Vector.<Object> = new Vector.<Object>();
		
		private static var status:uint = FREE;
		private static var type:uint = SINGLE;
		
		private static var loader:URLLoader;
		public static var archive:Array = [];
		public static var time1:uint = 0;
		public static var time2:uint = 0;
		
		private static var h:String = '';
		
		public function Post() 
		{
			
		}
		
		public static function send(action:Object, callback:Function, params:Object = null):void {
			action['ref'] = App.ref || "";
			queue.push( { action:action, callback:callback, params:params } );
			
			if (App.ui && App.ui.bottomPanel)
				App.ui.bottomPanel.addPostPreloader();
			
			//if (App.isSocial('ML','YB') && type != MULTI)
				//type = MULTI;
			
			if (status == FREE) {
				request();
			}
		}
		
		private static function request():void {
			
			status = BUSY;
			
			//var item:Object = queue;// queue[0];
			var items:Array = [];
			var result:String = '';
			
			
			for each (var object:* in queue) {
				if (App.user && App.user.pay)
					object.action['p'] = 1;
				
				for each(var action:* in object.action) {
					if (action == null)
						action = '';
					
					result += action + '';
				}
				
				items.push(object.action);
				
				if (type == SINGLE)
					break;
			}
			
			var pid:Number = new Date().time;
			var crc:String = MD5.encrypt('ytf$%$yuGFis*&udh' + result + pid + '');
			
			var data:String;
			if (type == SINGLE)
				data = JSON.stringify(items[0]);
			else
				data = JSON.stringify(items);
			
			time1 = getTimer();
			trace("POST: " + data);
			addToArchive('\n'+data+'  '+time1);
			
			var requestVars:URLVariables = new URLVariables();
			requestVars.data = data;
			requestVars.crc = crc;
			requestVars.pid = pid;
			if (h.length > 0) 
				requestVars.h = h;
			
			var req:URLRequest = new URLRequest(Config.getUrl());
			req.method = URLRequestMethod.POST;
			req.data = requestVars;
			
			loader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, onComplete);
			loader.addEventListener(IOErrorEvent.IO_ERROR, OnIOError);
			//loader.addEventListener(HTTPStatusEvent.HTTP_STATUS, OnHttpStatus);
			loader.load(req);
			//setTimeout(loader.load, 10000, req);
		}
		
		private static function onComplete(e:Event):void {
			
			/*if (App.user && App.user.quests && App.user.quests.tutorial)
				App.user.quests.unlockFuckAll();
			*/	
			URLLoader(e.target).removeEventListener(Event.COMPLETE, onComplete);
			URLLoader(e.target).removeEventListener(IOErrorEvent.IO_ERROR, OnIOError);
			URLLoader(e.target).removeEventListener(HTTPStatusEvent.HTTP_STATUS, OnHttpStatus);
			
			//var item:Object = queue.shift();
			
			time2 = getTimer();
			
			var response:String = e.currentTarget.data.replace(/\n/, '');
			
			trace(response);
			//response = response.replace('\rArray\n(\n)\n', '');
			if (response.search(/\"error\":0/) >= 0) {
				Cc.log(response + ' d:' + (time2 - time1) + '  ' + time2);
			}else{
				Cc.error(response);
				damageShow();
			}
			
			try{
				var object:Object = JSON.parse(response);
			}catch (e:Error) {
				status = FREE;
				return;
			}
			
			//if (object.error && object.error == 666 && type == SINGLE) {
				//type = MULTI;
				//status = FREE;
				//request();
				//return;
			//}
			
			var count:* = 0;
			var items:Vector.<Object>;
			if (object.hasOwnProperty('res')) {
				items = queue.splice(0, Numbers.countProps(object.res));
			}else {
				items = new Vector.<Object>;
				items.push(queue.shift());
			}
			
			//var count:* = (object.hasOwnProperty('res')) ? Numbers.countProps(object.res) : 1;
			//var items:Vector.<Object> = queue.splice(0, count);
			
			if (type == MULTI) {
				for (count in object.res) {
					handleResponce(object.res[count], items[count]);
				}
			}else {
				handleResponce(object, items[count]);
			}
			
			status = FREE;
			if (queue.length > 0) {
				request();
			}
			
			function handleResponce(response:Object, item:Object):void {
				
				var progress:*;
				var dayliProgress:*;
				
				if (response.data != null) {
					if(response.data.hasOwnProperty('h')) {
						h = String(response.data['h']);
						delete response.data['h'];	
					} /*else h_arr.push(item);*/
					
					if(response.data.hasOwnProperty('__time')) {
						App.time = response.data['__time'];
						delete response.data['__time'];
					}
					
					if(response.data.hasOwnProperty('__took')) {
						delete response.data['__took'];	
					}
					
					if(response.data.hasOwnProperty('__updates')) {
						delete response.data['__updates'];	
					}
					
					if (response.data.hasOwnProperty('__take')) 
					{
						delete response.data['__take'];	
					}
					
					if (response.data.hasOwnProperty('__queststate')) {
						progress = new Object();
						
						for (var qID:* in response.data['__queststate']) {
							if (App.data.quests.hasOwnProperty(qID)) {
								progress[qID] = response.data['__queststate'][qID];
							}
						}
						delete response.data['__queststate'];	
					}
					
					if (response.data.hasOwnProperty('__daylics')) {
						dayliProgress = { };
						for (var dID:* in response.data['__daylics']) {
							if (App.data.daylics.hasOwnProperty(dID)) {
								dayliProgress[dID] = response.data['__daylics'][dID];
							}
						}
						delete response.data['__daylics'];
					}
					
					if (response.data.hasOwnProperty(Stock.COUNTER_GUESTFANTASY)) {
						App.user.stock.data[Stock.COUNTER_GUESTFANTASY] = response.data[Stock.COUNTER_GUESTFANTASY];
						App.ui.leftPanel.showGuestEnergy();
						App.ui.leftPanel.updateGuestReward();
					}
					
					//achivements
					if (response.data.hasOwnProperty('__achstate')) {
						//progress = new Object();
						
						for (var ach:* in response.data.__achstate) {
							if (!App.user.ach[ach]) {
								App.user.ach[ach] = response.data.__achstate[ach];
								continue;
							}
							for (var mis:* in response.data.__achstate[ach]) {
								App.user.ach[ach][mis] = response.data.__achstate[ach][mis];
							}
							
							AchivementsWindow.checkAchProgress(ach);
						}
						
						/*for (var qID:* in response.data['__achstate']) {
							if (App.data.quests.hasOwnProperty(qID)) {
								progress[qID] = response.data['__achstate'][qID];
							}
						}*/
						delete response.data['__achstate'];	
					}
					
					//Устанавливаем время полночи
					if(response.data.hasOwnProperty('midnight')) {
						if (response.data['midnight'] != undefined) {
							App.midnight = response.data.midnight;
							App.nextMidnight = App.midnight + 24*3600;
							delete response.data['midnight'];	
						}
					}
					
					
					
					// Дополнительный бонус
					if (response.data.hasOwnProperty('annex') && response.data.annex) {
						if (!response.data.hasOwnProperty('bonus'))
							response.data['bonus'] = { };
						
						
						var annex:Object = { };
						for (var s:* in response.data.annex) {
							for (var anns:* in response.data.annex[s])
								annex[s] = response.data.annex[s][anns] * anns;
						}
						
						// Если объект - сид:количество
						for (s in response.data.bonus) {
							if (response.data.bonus[s] is int) {
								response.data.bonus[s] += int(annex[s]);
							}else {
								var count:int = 0;
								for (var bs:* in response.data.bonus[s]) {
									trace(response.data.bonus[s]);
									trace(response.data.bonus[s][bs]);
									count += response.data.bonus[s][bs] * bs;
								}
								response.data.bonus[s] = { 1:count + int(annex[s])};
							}
						}
						
						for (s in annex) {
							if (!response.data.bonus.hasOwnProperty(s)) {
								response.data.bonus[s] = { 1:int(annex[s])};
							}
						}
					}
					//
					//if (response.data.hasOwnProperty('__obj')) {
						//var chests:* = [];
						//for (var sid:* in response.data['__obj'])
						//{
							//chests[sid] = response.data['__obj'][sid];
						//}
						//if (App.user.stock)
						//{
							//App.user.stock.addTempChests(chests);
						//}
						//delete response.data['__obj'];
						//delete response.data['bonus'];
					//}
				}
				
				item.callback(response.error, response.data, item.params);
				
				
				if (App.ui && App.ui.bottomPanel)
					App.ui.bottomPanel.removePostPreloader();
				
				if (progress)
					App.user.quests.progress(progress);
				
				if (dayliProgress)
					App.user.quests.dayliProgress(dayliProgress);
			}
		}
		
		public static function clear():void
		{
			queue = new Vector.<Object>;
		}
		
		private static function OnIOError(event:IOErrorEvent):void 
		{
			URLLoader(event.target).removeEventListener(Event.COMPLETE, onComplete);
			URLLoader(event.target).removeEventListener(IOErrorEvent.IO_ERROR, OnIOError);
			
			Cc.error(event.currentTarget.data);
			trace(event.currentTarget.data);
			
			//Показываем ошибку, только если у нас уже не осталось flash:1382952379984пасных IP адресов
			if (Config._mainIP.length == 0) {
				new SimpleWindow( {
					title:Locale.__e('flash:1382952379725'),
					text:Locale.__e('flash:1382952379726'),
					label:SimpleWindow.ERROR
				});
			}
		}
		
		private static function OnHttpStatus(event:HTTPStatusEvent):void {
			
			
			
			switch(event.status) {
				case 301:
				case 302:
				case 303:
				case 304:
				case 305:
				case 307:
				case 200: break;
				default: 
				
				
					URLLoader(event.target).removeEventListener(Event.COMPLETE, onComplete);
					//loader.removeEventListener(IOErrorEvent.IO_ERROR, OnIOError);
					URLLoader(event.target).removeEventListener(HTTPStatusEvent.HTTP_STATUS, OnHttpStatus);
					
					//URLLoader(event.target).close();
					
					if (Config.changeIP()) {
						//trace('Change IP to ' + Config._curIP);
						status = FREE;
						if (queue.length > 0) {
							request();
						}
						return;
					}
					
					var item:Object = queue.shift();
					item.callback(1000, null, item.params);
				
					/*status = FREE;
					if (queue.length > 0) {
						request();
					}*/
					
					Errors.show(1000, {code:event.status } );
					break;
			}
		}
		
		public static const STATISTIC_INVITE:String = 'invite';
		public static const STATISTIC_WALLPOST:String = 'wallpost';
		public static function statisticPost(type:String):void 
		{
			Post.send({
				ctr:'User',
				act:'stat',
				uID:App.user.id,
				type:type
			}, function(error:int, data:Object, params:Object):void {
				if (error) {
					Errors.show(error, data);
					return;
				}	
			});
		}
		
		
		public static function addToArchive(data:String, checkOnLength:Boolean = true):void {
			Cc.log(data);
		}
		
		
		/**
		 * Показывает ошибки
		 */
		private static var damageValue:int = 0;
		public static function damageShow():void {
			
			if (!Config.admin)
				return;
			
			if (damageValue == 0)
				App.self.setOnEnterFrame(damageHandler);
			
			damageValue = 200;
			
		}
		private static function damageHandler(e:Event):void {
			if (damageValue < 0) {
				App.self.setOffEnterFrame(damageHandler);
				damageValue = 0;
				return;
			}
			
			damageValue -= 5;
			
			if (!App.map || !App.ui) return;
			App.ui.transform.colorTransform = new ColorTransform(1, 1, 1, 1, damageValue);
			App.map.transform.colorTransform = new ColorTransform(1, 1, 1, 1, damageValue);
			
		}
	}
}