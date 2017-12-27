package 
{
	import api.ExternalApi;
	import core.Load;
	import core.Log;
	import core.Post;
	import core.WallPost;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.utils.setTimeout;
	import strings.Strings;
	import units.Unit;
	import units.WorkerUnit;
	import wins.ErrorWindow;
	import wins.FreeGiftsWindow;
	import wins.ReceivedGiftWindow;
	import wins.SimpleWindow;
	import wins.Window;
	
	/**
	 * ...
	 * @author 
	 */
	public class Gifts 
	{	
		public static const NORMAL:int 	= 0;
		public static const FREE:int	= 1;
		public static const SPECIAL:int	= 3491;
		
		public static var count:uint = 0;
		public static var sID:uint = 0;
		public static var receivers:Array = [];
		public static var type:int = NORMAL;
		public static var msg:String = "";
		
		public static var takedFreeGift:Vector.<String> = new Vector.<String>;
		public static var currentGift:uint = 0;
		
		public static const MAX_FREE_GIFTS:int = 5;
		public static var freeGifts:int = 5;
		
		public function Gifts()
		{
			
		}
		
		/*public static function checkGifts():void {
			
			
			var delta:int = 180;
			if (App.time % delta != 0) {
				return;
			}
			
			Post.send( {
				ctr:		'gift',
				act:		'check',
				uID:		App.user.id,
				time:		App.time - delta
			},function(error:*, data:*, params:*):void {
				if (data && !error) {
					var hasGift:Boolean = false;
					for (var gID:String in data.gifts) {
						addGift(gID, data.gifts[gID]);
						hasGift = true;
					}
					if (hasGift) {
						App.ui.glowing(App.ui.rightPanel.bttnMainGifts, 0xFFFF00);
					}
						
					App.user.gifts.sortOn("time", Array.DESCENDING);
					if (App.user.gifts.length > App.data.options['GiftsLimit']) {
						App.user.gifts.splice(45, App.user.gifts.length - 45);
						if(App.ui) App.ui.rightPanel.update();
					}
					//App.user.gifts.reverse();
				}
			});
		}*/
		
		public static function canTakeFreeGift(uid:String):Boolean
		{
			//Log.alert('canTakeFreeGift '+ uid + ' ' + App.user.friends.data[uid].gift + ' ' + App.time);
			var fr:Object = App.user.friends.data[uid];
			if (!fr) return false;
			if (App.user.friends.data[uid].gift)
			{
				if (App.time <= App.user.friends.data[uid].gift || App.user.friends.data[uid].gift == 1) 
					return false;
				else 											
					return true;
			}
			
			return true;
		}
		
		public static function clean():void
		{
			count = 0;
			sID = 0;
			receivers = [];
		}
		
		
		public static function addGift(gID:String, _gift:Object):void
		{
			var gift:Object = _gift;
			for each(var item:* in App.user.gifts) {
				if (gID == item.gID) {
					return;
				}
			}
			
			// если нет такого друга и подарок не от администрации
			//if (!App.user.friends.data.hasOwnProperty(gift.from) && gift.type != SPECIAL)
				//return;
				
			if (gift.type == SPECIAL) {
				if (App.data.storage[gift.sID].type != 'Sets')
					gift.from = "1";
			}
			
			gift["gID"] = gID;
			
			if (App.ui) App.ui.rightPanel.update();
			
			if (App.data.storage[gift.sID].type == 'Sets') {
				setTimeout(function():void {
					if (!App.user.quests.tutorial) {
						new ReceivedGiftWindow( {
							gift: gift
						}).show();
					}
				}, 5000);
			}else {
				App.user.gifts.push(gift);
			}
			
			if (gift.sID == 1782) {
				setTimeout(function():void {
					if (!App.user.quests.tutorial) {
						new SimpleWindow( {
							title:App.data.storage[gift.sID].title,
							text:App.data.storage[gift.sID].description,
							buttonText:'受け取る',
							confirm:function():void {
								new FreeGiftsWindow().show();
							}
						}).show();
					}
				}, 5000);
			}
			
			//App.self.addEventListener(AppEvent.ON_UI_LOAD, onUILoad);
		}
		
		public static function removeGift(gID:String):void
		{
			var length:int = App.user.gifts.length;
			for (var i:int = 0; i < length; i++)
			{
				if (App.user.gifts[i].gID == gID)
				{
					App.user.stock.add(App.user.gifts[i].sID, App.user.gifts[i].count);
					App.user.gifts.splice(i, 1);
					App.ui.bottomPanel.update();
					return;
				}
			}
			
		}
		
		public static function removeAllGifts():void
		{
			var length:int = App.user.gifts.length;
			for (var i:int = 0; i < length; i++) {
				App.user.stock.add(App.user.gifts[i].sID, App.user.gifts[i].count);
			}
			App.user.gifts = [];
			App.ui.bottomPanel.update();
		}
		
		public static function remove(gID:String, callback:Function):void
		{
			removeGift(gID);
			callback();
			
			var params:Object = { callback:callback };
			
			
			Post.send( {
					ctr:		'gift',
					act:		'reject',
					uID:		App.user.id,
					gID:		gID
				},function(error:int, data:Object, params:Object):void {
					if (error) {
						Errors.show(error, data);
						return; 
					}	
					
					params.callback();
				}, params);
		}
		
		public static function grabGifts():uint
		{
			var maxTime:uint = 0;
			var length:int = App.user.gifts.length;
			for (var i:int = 0; i < length; i++)
			{
				if (App.user.gifts[i].time > maxTime)
					maxTime = App.user.gifts[i].time;
					
				App.user.stock.add(App.user.gifts[i].sID, App.user.gifts[i].count);
			}
			App.user.gifts = [];
			App.ui.rightPanel.update();
			
			return maxTime;
		}
		
		public static function addReceiver(uid:String):void
		{
			if (receivers.indexOf(uid) == -1)	receivers.push(uid);
		}
		
		public static function removeReceiver(uid:String):void
		{
			var index:int = receivers.indexOf(uid);
			if (index != -1)
			{
				receivers.slice(index, index + 1);
			}
		}
		
		/**
		 * Отправляем подарок одному пользователю
		 */
		public static function send(sID:uint, fID:String, count:int, type:uint, callback:Function):void
		{
			if (App.data.storage[sID].type == 'Sets') type = Gifts.SPECIAL;
			if (type == NORMAL)
			{
				if (!App.user.stock.take(sID, count))
				{
					// не хватает материалов
					return;
				}
			}
			else
			{
				if(App.user.friends.data[fID] != undefined){
					App.user.friends.data[fID]["gift"] = App.midnight + 24 * 3600;
					takedFreeGift.push(fID);
				}
			}
						
			var params:Object = {
				callback:callback,
				fID:fID,
				sid:sID,
				count:count,
				type:type
			};
			
			if (msg == Locale.__e("flash:1382952379738")) msg = "";
			
			//if (App.social != 'OK') 
			//WallPost.makePost(WallPost.GIFT, {sid:sID, fid:fID});
			
			/*if (App.social == 'VK' || App.social == 'DM') {
				var material:Object = App.data.storage[sID];
				var msg:String = Strings.__e('Gifts_send', [material.title, Config.appUrl]);
				ExternalApi.notifyFriend( { uid:fID, text:msg, callback:null, type:'gift' } );
			}*/
			
			switch(App.social) {
				case 'DM':
				case 'VK':
				case 'FS':
				case 'FB':
				case 'NK':
					ExternalApi.notifyFriend( {
						uid:	params.fID,
						text:	Strings.__e('Gifts_send', [App.data.storage[sID].title, Config.appUrl]),
						type:	'gift'
					});
					break;
				case 'ML':
					ExternalApi.notifyFriend( {
						uid:	params.fID,
						text:	Strings.__e('Gifts_send', [App.data.storage[sID].title, Config.appUrl]),
						type:	Config.getIcon(App.data.storage[sID].type, App.data.storage[sID].preview)
					});
					break;
				case 'GN':
					ExternalApi.apiAppRequest([String(params.fID)], msg);
					break
			}
			
			Post.send( {
				ctr:		'gift',
				act:		'send',
				uID:		App.user.id,
				fID:		fID,
				sID:		sID,
				count:		count,
				msg:		msg,
				type:		type,
				name:       App.user.first_name + " " + App.user.last_name,
				title:      App.data.storage[sID].title
			},onSendEvent, params);
		}
		
		private static function onSendEvent(error:int, data:Object, params:Object):void {
			if (error) {
				Errors.show(error, data);
				//50 - уже дарил бесплатный подарок
				//38 - нет fID
				//13 - undefined sID
				//51 - не передано количество
				//12 - нет склада
				//23 - не хватает материалов
				//42 - не может найти друга
				//55 - ошибка типа
				return; 
			}	
			//if (data.gift && data.gift > 0)
			//{
				//App.user.friends.data[params.fID]["gift"] = data.gift;
			//}
			if (data.gift == 0 && params.type == NORMAL) {
				addErrorWindow();
				App.user.stock.add(params.sid, params.count);
			}else if (data.gift == 0 && params.type == FREE) {
				addErrorWindow();
			}else if(params.type == FREE && App.user.friends.data.hasOwnProperty(params.fID)){
				App.user.friends.data[params.fID]["gift"] = App.nextMidnight;
				//if (App.social != 'OK') 
					//WallPost.makePost(WallPost.GIFT, {sid:params.sid, fid:String(params.fID)});
			}else {
				//if (App.social != 'OK') 
					//WallPost.makePost(WallPost.GIFT, {sid:params.sid, fid:String(params.fID)});
			}
			
			if (params.callback != null) params.callback();
		}
		
		private static function addErrorWindow():void
		{
			new SimpleWindow( {
				title:		'',
				text:		Locale.__e('flash:1406275629192'),
				buttonText:	Locale.__e('flash:1382952380298'),
				isImg:		true,
				popup:		true
			}).show();
		}
		
		/**
		 * Отправляем один подарок списку пользователей
		 */
		public static function broadcast(sID:uint, receivers:Array, type:uint, callback:Function = null, isNotify:Boolean = true):void
		{
			if(msg == null || msg == Locale.__e("flash:1382952379738")) msg = "";
			Post.send( {
				ctr:		'gift',
				act:		'broadcast',
				uID:		App.user.id,
				friends:	JSON.stringify(receivers),
				sID:		sID,
				msg:		msg,
				type:		type // FREE, SPECIAL, NORMAL
			},onBroadcastEvent);
			
			var material:Object = App.data.storage[sID];
			var msg:String = Locale.__e('flash:1382952379740', [material.title]);
			
			if	(isNotify) {
				switch(App.social) {
					case 'FB':
					case 'NK':
					case 'FS':
					case 'FB':
						ExternalApi.notifyFriend( { uid:receivers, text:msg, callback:callback, type:'gift' } );
						break;
					case 'ML':
						ExternalApi.notifyFriend( { uid:receivers, text:msg, callback:callback, type:Config.getIcon(material.type, material.preview) } );
						break;
				}
			}
			
			//Делаем push в og
			if (App.social == 'FB') {
				ExternalApi.og("send", "gift");
			}
			
			clean();	
		}
		
		private static function onBroadcastEvent(error:int, data:Object, params:Object):void {
			if (error) {
				Errors.show(error, data);
				//13 - undefined sID
				//52 - неflash:1382952379993вестный тип
				//53 - неверный friends
				//54 - JSON error
				//55 - ошибка типа
				//50 - уже дарил бесплатный подарок
				return; 
			}
		}
		
		/**
		 * Берем подарок
		 */
		public static function take(gID:String, callback:Function):void
		{
			removeGift(gID);
			callback(true);
			
			var params:Object = { callback:callback };
			
			Post.send( {
					ctr:		'gift',
					act:		'take',
					uID:		App.user.id,
					gID:		gID
				},onTakeEvent, params);
		}
		
		/**
		 * Берем все подарки
		 */
		public static function takeAll(callback:Function):void
		{
			removeAllGifts();
			callback();
			
			//var params:Object = { callback:callback };
			
			Post.send( {
					ctr:		'gift',
					act:		'takeall',
					uID:		App.user.id
				},onTakeEvent);
		}
		
		private static function onTakeEvent(error:int, data:Object, params:Object):void {
			if (error) {
				Errors.show(error, data);
				//49 - undefined gID
				//56 - can not find gID
				return; 
			}	
			
			if (data.hasOwnProperty('bonus')) data = data.bonus;
			
			for (var sID:* in data) {
				if (sID == Stock.FANT || sID == Stock.COINS || sID == Stock.FANTASY) {
					App.user.stock.add(sID, data[sID]);					
					App.ui.upPanel.update();
				}/*else {
					App.user.stock.data[sID] = data[sID];
				}*/
				
				//App.user.stock.add(sID, data[sID]);
				
				//Делаем push в _6e
				if (App.social == 'FB') {
					ExternalApi.og('receive','gift');
				}
				
				if (App.data.storage[sID].type == 'Animal') {
					var rel:Object = { };
					rel[sID] = sID;
					var position:Object = App.map.heroPosition;
						var unit:Unit = Unit.add( { sid:sID, id:2, x:position.x, z:position.z, rel:rel } );
							(unit as WorkerUnit).born();
							
						unit.stockAction({sid:sID});
				}
			}
			if (params) params.callback(false, data);
			
			App.ui.upPanel.update();
		}
		
		/**
		 * Берем все подарки
		 */
		public static function grab(callback:Function):void
		{
			var time:uint = grabGifts();
			callback();
			Post.send( {
					ctr:		'gift',
					act:		'grab',
					uID:		App.user.id,
					time:		time
				},onGrabEvent);
		}
		
		private static function onGrabEvent(error:int, data:Object, params:Object):void {
			if (error) {
				Errors.show(error, data);
				// 16 - нет склада
				return; 
			}	
			
		}
		
		/**
		 * Отправляем подарок одному пользователю
		 */
		public static function ask(sID:uint, fID:String, callback:Function = null):void
		{
			currentGift = sID;				
			//Пост на стену
			/*var material:Object = App.data.storage[sID];
			//var message:String = Locale.__e("%s %s никак не может найти \"%s\". Отправьте подарок вашему другу! %s", [App.user.first_name, App.user.last_name, material.title, Config.appUrl]);
			var message:String = Strings.__e('Gifts_ask', [App.user.first_name, App.user.last_name, material.title, Config.appUrl]); 
			
			var bitmap:Bitmap = new Bitmap(Gifts.generateGiftPost(Load.getCache(Config.getIcon("Material", material.preview))));
			
			if (bitmap != null) {
				ExternalApi.apiWallPostEvent(ExternalApi.ASK, bitmap, String(fID), message, sID);
			}*/
			
			WallPost.makePost(WallPost.ASK, {sid:sID, fID:fID});
			
			
			//End Пост на стену

			if (callback != null) {
				callback();
			}
		}
		
		public static function generateGiftPost(material:Bitmap, dY:int = 0):BitmapData
		{
			if (!material)
				return null;
			
			var back:Sprite = new Sprite();
			
			var bitmap:Bitmap = new Bitmap(material.bitmapData);
			back.addChild(bitmap);
			bitmap.smoothing = true;
			var gameTitle:Bitmap = new Bitmap(Window.texture('logo'), "auto", true);
			back.addChild(gameTitle);
			gameTitle.scaleX = gameTitle.scaleY = 1;
			
			gameTitle.x = 0;
			gameTitle.y = bitmap.height + dY;
			
			bitmap.x = (gameTitle.width - bitmap.width) / 2 - 5;
			var bmd:BitmapData = new BitmapData(Math.max(bitmap.width, gameTitle.width), back.height, false);//, 0);
			bmd.draw(back);
			
			return bmd;
		}
	}
}