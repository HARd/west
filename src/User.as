package  
{
	import astar.AStarNodeVO;
	import core.Load;
	import core.Log;
	import core.Numbers;
	import core.Post;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.utils.setTimeout;
	import ui.Cursor;
	import units.Character;
	import units.Field;
	import units.Guide;
	import units.Resource;
	import units.Techno;
	import units.Underground;
	import units.Unit;
	import units.Hero;
	import units.Personage;
	import units.WorkerUnit;
	import wins.actions.BanksWindow;
	import wins.actions.BanksWindow;
	import wins.BonusVisitingWindow;
	import wins.CalendarWindow;
	import wins.ConstructWindow;
	import wins.DayleftWindow;
	import wins.DaylicWindow;
	import wins.InviteBestFriendWindow;
	import wins.OnceOfferWindow;
	//import wins.OnceOfferWindow;
	import wins.actions.PromoWindow;
	import wins.ReferalRewardWindow;
	import wins.RouletteWindow;
	import wins.SaleBoosterWindow;
	import wins.ShopWindow;
	import wins.TopAwardWindow;
	import wins.Window;
	import units.Companion;
	import units.PetHouse;
	import wins.TripleSaleWindow;
	
	public class User extends EventDispatcher
	{
		
		public static const GUEST:Boolean = true;
		public static const OWNER:Boolean = false;
		
		public static const VIEW:Boolean = true;
		
		public static const BOY_BODY:uint 	= 0;
		public static const BOY_HEAD:uint 	= 0;
		
		public static const GIRL_BODY:uint 	= 0;
		public static const GIRL_HEAD:uint 	= 0;
		
		public static const START_WORLD:uint = 112; // 288 (Merry location)
		public static const HOME_WORLD:uint = 112;
		public static const EVENT_WORLD:uint = 0;
		public static const MERRY_WORLD:uint = 288;
		
		public static const  PRINCE:int = 120;
		public static const  PRINCESS:int = 121;
		
		public static const  HECK:int = 1;
		public static const  TRICK:int = 1;
		public static const  LEA:int = 1;
		public static const  SPARK:int = 1;
		
		public static var checkBoxState:int = 1;
		public static var openExpJson:Object;
		
		public static var mine:Underground;
		
		public var id:String = '0'; 
		public var worldID:int = 1; 
		public var aka:String = ""; 
		public var sex:String = "f"; 
		public var first_name:String; 
		public var last_name:String; 
		public var photo:String; 
		public var year:int; 
		public var city:String;
		public var country:String;
		public var email:String;
		public var level:uint = 1; 
		public var exp:int = 1; 
		public var world:World;
		public var worlds:Object = {};
		public var maps:Array = [];
		public var friends:Friends;
		public var quests:Quests;
		public var orders:Orders;
		public var stock:Stock = null;
		public var units:Object;
		public var shop:Object = { };
		public var lastvisit:uint = 0;
		public var createtime:uint = 0;
		public var energy:uint = 0;
		public var freebie:Object = null;
		public var presents:Object = {};
		public var restore:int;
		public var promos:Array = [];
		public var promo:Object = { };
		public var oncePromos:Array = [];
		public var onceOfferShow:uint = 0;
		public var premiumPromos:Array = [];
		public var daylics:Object = {};
		public var boostPromos:Array = [];
		public var boostCompleteTime:int = 0;
		public var boostBlock:Boolean = false;
		public var boostList:Array = [];
		public var money:int = 0; 
		public var pay:int = 0;
		public var bestFriends:Object;
		public var bestFriendsInvites:Object;
		public var blinks:Object = { };
		public var profile:Object = { };
		
		public var currentGuestReward:Object;
		public var currentGuestLimit:uint = 0;
		
		public var wishlist:Array = [];
		public var gifts:Array = [];
		public var requests:Array = [];
		public var head:uint = 0;
		public var body:uint = 0;
		public var day:uint = 0;
		public var bonus:uint = 0;
		public var _6wbonus:Object = {};
		public var trialpay:Object = {};
		
		public var personages:Array = [];
		public var characters:Array = [];
		public var techno:Array = [];
		public var goldenTechno:Array = [];
		public var animals:Array = [];
		public var mode:Boolean = OWNER;
		public var view:Boolean = false;
		public var trades:Object;
		public var tradeshop:Object;
		private var _settings:String = '';
		public var settings:Object = {ui:"111", f:"0"};
		public var diffvisit:int = 0;
		public var hidden:int = 0;
		public var top:Object = {};
		public var topID:int = 8;
		public var spawnUnits:Object = { };
		public var lands:Array = [];
		public var instance:Object = {};
		public var instanceWorlds:Object = {};
		public var uData:Object = {};
		
		public var ach:Object = { };
		public var socInvitesFrs:Object = { };
		
		public var rooms:Object = {};
		//public var restoredUnits:Object; 
		public var wl:Object;
		
		public var giftsLimit:int;
		
		public var cowboys:Array = [];
		
		public var boosterTimer:int = 180 + Math.floor(120 * Math.random());
		//public var boosterTimer:int = 5;
		public var boosterTimeouts:int = 900;
		public var boosterLimit:int = 4;
		
		public var charactersData:Array = [];
		
		public var pet:Companion;
		
		private var _bounty:Object;
		public function get bounty():Object 
		{
			return _bounty;
		}
		public function set bounty(value:Object):void 
		{
			_bounty = value;
		}
		
		public var ref:String = ""; 
		public var keepers:Object = {
			79:0,
			80:0,
			81:0
		}
		
		public var daylicShopData:Object = { };
		
		public function User(id:String){
			Log.alert('uID: '+id);
			this.id = id;
			
			first_name 	= App.network.profile.first_name || "Name";
			last_name 	= App.network.profile.last_name || "";
			sex 		= App.network.profile.sex || "f";
			photo		= App.network.profile.photo;
			year		= App.network.profile.year || 0;
			city		= App.network.profile.city || '';
			country		= App.network.profile.country || '';
			email		= App.network.profile.email || '';
			
			for (var sID:* in App.data.storage) {
				var item:Object = App.data.storage[sID];
				if (item.type == 'Lands' && item.started) {
					worldID = sID;
				}
				
				// Ускорения для растений
				if (item.type == 'Boost') {
					Field.boosts.push(int(sID));
				}
				
				// Территории
				if (item.type == 'Lands')
					lands.push(sID);
				
				// Cbuilding
				if (item.type == 'Cbuilding' && item.hasOwnProperty('list') && item.list is Array) {
					for each(var attachSID:* in item.list) {
						if (App.data.storage[attachSID]) {
							if (!App.data.storage[attachSID]['attachTo']) App.data.storage[attachSID]['attachTo'] = [];
							App.data.storage[attachSID].attachTo.push(sID);
						}
					}
				}
				
				if (item.gcount > 0)
					Storage.shopLimitIDs.push(sID);
				
				
				item['sid'] = sID;
				
			}
			
			Log.alert('App.network.appFriends');
			Log.alert(App.network.appFriends);
			
			var social:String = App.social;
			if (social == 'DM')
				social = 'VK';
				
			Console.addLoadProgress('App.network.appFriends.length: ' + App.network.appFriends.length);
			
			var postObject:Object = {
				'ctr':'user',
				'act':'state',
				'uID':id,
				'year':year,
				'sex':sex,
				'friends':JSON.stringify(App.network.appFriends),
				'social':social,
				'city':city,
				'country':country,
				'photo':photo,
				'aka':first_name + ' ' + last_name,
				'email':email
			}
			
			if (App.blink != "") {
				postObject['blink'] = App.blink;
			}
			
			//postObject['wID'] = (id == '1') ? MERRY_WORLD : HOME_WORLD;
			//if (App.isSocial('FB', 'NK', 'SP', 'YB', 'AI', 'MX')) {
				//postObject['wID'] = (id == '1') ? MERRY_WORLD : HOME_WORLD;
			//}
			
			Post.send(postObject, onLoad);
			App.self.addEventListener(AppEvent.ON_UI_LOAD, onUILoad);
			
			/*if (App.isSocial('MX', 'YB')) {
				topID = 7;
			}*/
			for (var tID:* in App.data.top) {
				var topStorage:Object = App.data.top[tID];
				if (App.data.top[tID].hasOwnProperty('expire') && App.data.top[tID].expire.s < App.time && App.data.top[tID].expire.e > App.time) {
					topID = tID;
				}
			}
		}
		
		public static var inupdate:Object;
		public static var instay:Object;
		public static function inUpdate(sid:*):Boolean {
			return ((inupdate && inupdate.hasOwnProperty(sid)) || (instay && instay.hasOwnProperty(sid)));
		}
		
		public var arrHeroesInRoom:Array = [];
		public var calendar:Object = { };
		
		public function onLoad(error:int, data:Object, params:Object):void {
			
			Console.addLoadProgress("User: onLoad");
			if (error) {
				Errors.show(error, data);
				//Обрабатываем ошибку
				return;
			}
			
			ach = data.ach || {};
			if (!ach) ach = { };
			for (var ac:* in App.data.ach) {
				if (!ach[ac]) {
					ach[ac] = { };
				}
			}
			//lastvisit = 1444314037 [0x56167bb5]
			if (data.user && data.user.invite)
				socInvitesFrs = data.user.invite;
			
			App.ref = data.user['ref'] || "";
			App.ref_link = data.ref_link || "";
			for (var properties:* in data.user)
			{
				if (['worlds','friends'].indexOf(properties) >= 0) continue;
				
				if (properties == 'wID') {
					worldID = data.user[properties];
					continue;
				}
				
				if (properties == 'blinks') {
					if (data.user[properties] == null) {
						blinks = { };
						continue;
					}
				}
				
				if (properties == 'settings') {
					try{
						_settings = data.user[properties];
						settings = JSON.parse(_settings);
					}catch (e:*) {}
					if (!settings['ui']) settings['ui'] = '111';
					if (!settings['f']) settings['f'] = '0';
					continue;
				}
				
				if (this.hasOwnProperty(properties)){
					this[properties] = data.user[properties];
				}
			}
			
			//if (Config.admin) App.self.constructMode = true;
			
			checkInstances();
			
			if (settings.body) {
				App.user.body = settings.body;
			}else {
				if (sex == 'f') App.user.body = User.PRINCESS;
				else 			App.user.body = User.PRINCE;
			}
			//if (data.user.profile) {
				//for (var val:* in data.user.profile) {
					//for (var k:int = 0; k < aliens.length; k++ ) {
						//if (val == aliens[k].sid)
							//aliens[k].type = getClothView(data.user.profile[val]);
						//
					//}
				//}
			//}
			
			if (data.user.hasOwnProperty('rSlots')) {
				RouletteWindow.slots = data.user.rSlots;
			}
			if (data.user.hasOwnProperty('rTry')) {
				RouletteWindow.rTry = data.user.rTry;
			}
			if (data.user.hasOwnProperty('rPosition')) {
				RouletteWindow.rPositions = data.user.rPosition;
			}
			
			if (data.hasOwnProperty('ships'))
				tradeshop = data.ships;
				
			for each(var wID:* in data.user.worlds) {
				worlds[wID] = wID;
			}
			
			for each(var _sid:* in wl) wishlist.push(_sid);
			
			Console.addLoadProgress("User: 1");
			units = data.units;
			//stock = new Stock(data.stock);
			
			// На МИНИ локации другой склад. Переносим в него системные материалы и создаем из ресурсов мира
			if (App.data.storage[worldID].size == World.MINI) {
				if (!data.world.hasOwnProperty('stock')) data.world['stock'] = { };
				for (properties in data.stock) {
					if (App.data.storage.hasOwnProperty(properties) && (App.data.storage[properties].mtype == 3 || App.data.storage[properties].type == 'Vip'))
						data.world.stock[properties] = data.stock[properties];
				}
				stock = new Stock(data.world.stock);
			}else{
				stock = new Stock(data.stock);
			}
			
			if (App.network['friends'] != undefined) {
				for (var _i:* in App.network.friends) {
					var fID:String = App.network.friends[_i].uid;
					if (data.friends[fID] != undefined) {
						for (var key:* in App.network.friends[_i]) {
							data.friends[fID][key] = App.network.friends[_i][key];
						}
					}
				}
			}
			
			for each(var room:* in rooms) 
			{
				if (!room.hasOwnProperty('times')) room['times'] = 0;
				if (!room.hasOwnProperty('drop')) room['drop'] = 0;
				
				for (var hr:* in room.pers) {
					arrHeroesInRoom.push(room.pers[hr]);
				}
			}
			
			if (!ExternalInterface.available) {
				var networkDefoult:Object = { };
				networkDefoult['1'] = {
					//"uid"           : 151695597,//friend["uid"],
					"uid"           : 9490649,//friend["uid"],
					"first_name"    : 'User',//friend["first_name"],
					"last_name"     : 'Real_user',
					"photo"	        : '',
					"url"  			: "http://vk.com/id" + 159185922,
					"sex"           : 'm',//friend["sex"] == 2 ? "m" : "f",
					"exp"           : 1600
				}
				for (var _j:* in data.friends) {
					var fID2:int = data.friends[_j].uid;
					if (data.friends[fID2] != undefined) {
						for (var key2:* in networkDefoult[1]) {
							if (!data.friends[fID2].hasOwnProperty(key2)) {
								if (key2 == 'photo')
									data.friends[fID2][key2] = Config.getImage('avatars', 'av_' + int(Math.random() * 2 + 1));
								else
									data.friends[fID2][key2] = networkDefoult[1][key2];
							}
						}
					}
				}
			}
			
			friends = new Friends(data.friends);
			
			promo 		= data.promo;
			freebie     = data.freebie;
			presents	= data.presents;
			trades		= data.trades;
			
			for (var item:* in App.data.storage) {
				if (App.data.storage[item].type == 'Maps')
					maps.push(App.data.storage[item]);
			}
			
			if(data.hasOwnProperty('keepers'))
				keepers		= data.keepers;
				
			if (data.user.hasOwnProperty('bestfriends')) {
				if (data.user.bestfriends.hasOwnProperty('friends')) 
				{
					bestFriends	= data.user.bestfriends.friends;
				}
				if (data.user.bestfriends.hasOwnProperty('invites'))
				{
					bestFriendsInvites	= data.user.bestfriends.invites;
				}
			}
			
			Console.addLoadProgress("User: 2");
			for (var gID:String in data.gifts) {
				if (gID == 'limit') {
					giftsLimit = Math.max(App.data.options.GiftsLimit ,data.gifts['limit']);
					continue;
				}
				if (!App.data.storage.hasOwnProperty(data.gifts[gID].sID))
					continue;
				
				if(App.data.storage[data.gifts[gID].sID].type == 'Goldentechno')
					continue;
				
				Gifts.addGift(gID, data.gifts[gID]);
			}
			
			gifts.sortOn("time");
			gifts.reverse();
			
			world = new World(data.world);
			quests = new Quests(data.quests);
			orders = new Orders();
			
			//TODO инициализируем зависимые объекты
			App.self.dispatchEvent(new AppEvent(AppEvent.ON_USER_COMPLETE));
			App.self.setOnTimer(totalTimer);
			
			for each(var fr:* in data.friends) {
				if (fr.uid != "1" && fr.exp && fr.exp >= stock.count(Stock.EXP) ) {
					friends.bragFriends.push(fr);
				}
			}
			initTutorial();
			
			/*if (id == '241769205') {
				for (var s:* in friends.data) {
					if (String(s) != '1')
						delete friends.data[s];
				}
			}*/
			
			CalendarWindow.format();
			
			if (App.data.options.hasOwnProperty('SpawnUnits')) {
				spawnUnits = JSON.parse(App.data.options['SpawnUnits']);
			}
			
			if ((!data.user.freegift || App.time - data.user.freegift > 24 * 3600) && App.time - data.user.createtime > 120 /*&& App.isSocial('DM','VK')*/) {
				postForFreeGift();
			}
			
			if (data.user.hasOwnProperty('top'))
				checkTop();
			
			// Проверка глобального доступа в магазине
			Storage.shopLimitCheck();
			
		}
		
		public function postForFreeGift():void
		{
			var freeGifts:Array = [];
			var freeWishes:Array = [];
			
			var currentItem:Object;
			for (var key:String in App.data.storage)
			{
				currentItem = App.data.storage[key];
				if (currentItem.type == "Material" && currentItem.hasOwnProperty("free") && currentItem.free == 1)
				{
					freeGifts.push(int(key));
				}
			}
			
			if (wishlist && wishlist.length > 0)
			{
				for (var i:int = 0; i < wishlist.length; i++) 
				{
					if (freeGifts.indexOf(wishlist[i]) >= 0)
					{
						freeWishes.push(wishlist[i]);
					}
				}
			}
			else
			{
				freeWishes = freeGifts;
			}
			
			var randomGiftID:int = freeWishes[int(Math.random() * (freeWishes.length - 1))];
			if (randomGiftID == 0) randomGiftID = freeGifts[int(Math.random() * (freeGifts.length - 1))];;
			var postObject:Object = {
				ctr:"user",
				act:"freegift",
				sID:randomGiftID,
				uID:App.user.id
			};
			
			Post.send(postObject, onPostForFreeGift);
		}
		
		private function onPostForFreeGift(error:int, data:Object, params:Object):void
		{
			if (error)
			{
				Post.addToArchive("GIFT FROM BOT ERROR. ErrorID :" + error.toString());
			}
		}
		
		private function checkInstances():void {
			
			Storage.instance = instance;
			
			/*var newInstans:Object = { };
				var count:int = 0;
				if (instance.hasOwnProperty('units'))
					trace();
				
				var source:Object = (instance.hasOwnProperty('units')) ? instance.units : instance;
				for each (var worldItem:Object in source) {
					for (var item:* in worldItem) {
						if (worldItem[item] is int) {
							if (!newInstans[item])
								newInstans[item] = 0;
							
							newInstans[item] += worldItem[item];
						}
					}
				}
			
			instance = newInstans;*/
		}
		
		private function onUILoad(e:AppEvent):void {
			App.self.removeEventListener(AppEvent.ON_UI_LOAD, onUILoad);
			
			// Boosts
			activeBooster();
		}
		private function getClothView(sID:uint):String
		{
			return App.data.storage[sID].preview;
		}
		
		public function checkTop():void {
			for (var topID:* in top) {
				if (topID == 1 || topID == 8) continue;
				if (App.data.hasOwnProperty('top') && App.data.top.hasOwnProperty(topID) && !top['bonus']) {
					var topStorage:Object = App.data.top[topID];
					if (topStorage.hasOwnProperty('expire') && topStorage.expire.s < App.time && topStorage.expire.e < App.time) {
						
						if (App.user.top.hasOwnProperty(topID) && !App.user.top[topID].hasOwnProperty('tbonus')) {
							var tID:int = topID;
							Post.send( {
								ctr:		'top',
								act:		'position',
								uID:		App.user.id,
								tID:		topID
							}, function(error:int, data:Object, params:Object):void {
								if (error) return;
								
								if (data.hasOwnProperty('position') && data.position <= App.data.top[params.topID].limit && data.position != 0) {
									setTimeout(function():void {
										new TopAwardWindow( {
											place:		data.position,
											topID:		params.topID
										}).show();
									}, 5000);
								} else {
									if (params.storage.hasOwnProperty('lbonus') && params.storage.lbonus != "") {
										var count:int = Numbers.countProps(params.storage.lbonus.t);
										for (var i:int = 0; i < count; i++) {
											if (top[params.topID].count >= params.storage.lbonus.s[i] && top[params.topID].count <= params.storage.lbonus.e[i]) {
												var lbonus:int = i;
												setTimeout(function():void {
													new TopAwardWindow( {
														lbonus:		lbonus,
														topID:		params.topID
													}).show();
												}, 5000);
											}
										}
									}
								}
							}, {
								topID:		tID,
								storage:	topStorage
							});
						}
					}
				}
			}
			
		}
		
		//акции
		public var promoFirstParse:Boolean = true;
		public function updateActions():void 
		{
			//return;
			var actionsArch:Object = storageRead('actions', { } );
			//actionsArch = { }; //storageStore('actions', actionsArch);
			if (!App.data.hasOwnProperty('actions')) return;
			
			if (actionsArch is Array) {
				var object:Object = { };
				for (var ind:int = 0; ind < actionsArch.length; ind++) {
					if (actionsArch[ind] != null) object[ind] = actionsArch[ind];
				}
				actionsArch = null;
				actionsArch = object;
			}
			
			// Удалить куки несуществующих акций или акций которые уже не появятся. ОДИН РАЗ ПРИ ЗАПУСКЕ!
			var arch:Object;
			var pID:String;
			
			if(promoFirstParse) {
				for (pID in actionsArch) {
					if (pID == '831') continue;
					if (!App.data.actions.hasOwnProperty(pID)) {
						delete actionsArch[pID];
					}else{
						arch = App.data.actions[pID];
						if (arch.type == 0 && (arch.unlock.level && arch.unlock.level < level) && (arch.unlock.quest && quests.data.hasOwnProperty(arch.unlock.quest) && quests.data[arch.unlock.quest].finished > 0)) {
							delete actionsArch[pID];
						}else if (arch.type == 7 && actionsArch[pID].time + arch.duration * 3600 < App.time) {
							delete actionsArch[pID];
						}else if (arch.type != 0 && arch.type != 7 && arch.time + arch.duration * 3600 < App.time) {
							delete actionsArch[pID];
						}else if (arch.type == 4) {
							delete actionsArch[pID];
						}
					}
				}
			}
			
			// Удаление не подходящих по условиям акций
			for (pID in actionsArch) {
				arch = App.data.actions[pID];
				if (arch.unlock.lto > 0 && arch.unlock.lto <= level) {
					delete actionsArch[pID];
				}
			}
			
			promo = {};
			promos = [];
			premiumPromos = [];
			oncePromos = [];
			boostPromos = [];

			var promoNormal:Array = [];
			var promoUnique:Array  = [];
			
			for (var arId:* in actionsArch) {
				if (actionsArch[arId] == null)
					actionsArch[arId] = { };
					//delete actionsArch[arId];
			}
			
			TripleSaleWindow.updateBuyed(actionsArch);
			
			for (var aID:String in App.data.actions) {
				if (['1031','1187','1484','1486','1488','1490','1492','1494','1496','1498','1500','1502','1504','2674'].indexOf(aID) != -1) {
					continue;
				}
				if (aID == '3605') {
					trace();
				}
				var action:Object = App.data.actions[aID];
				var open:Boolean = false;
				
				// Пропустить если купили
				if (actionsArch.hasOwnProperty(aID) && actionsArch[aID] != null && actionsArch[aID].buy) {
					delete actionsArch[aID].time;
					delete actionsArch[aID].prime;
					continue;
				}
				// Нет в социальной сети
				if (!action.price || !action.price.hasOwnProperty(App.social)) continue;
				
				// Не наступила
				if (App.time < action.time) continue;
				// Платящие акцию не увидят
				if (pay > 0 && action.hasOwnProperty('pay') && action.pay == 1) continue;
				
				//if (action.hasOwnProperty('pay') && action.pay != pay) continue;
				
				if (aID == '831' && App.user.stock.data.hasOwnProperty('1038')) continue;
				
				// Акция с клипером, если клипер есть на складе, пропускаем
				var exit:Boolean = false;
				for (var id:String in action.items) {
					if (int(id) == 933 && App.user.stock.count(int(id)) > 0) {
						exit = true;
					}
				}
				if (exit) continue;
				
				action['pID'] = aID;
				action['buy'] = 0;
				if (!action.hasOwnProperty('prime')) action['prime'] = 0;
				
				// Пропустить акцию если купленного больше чем нужно
				var brokenAction:Boolean = false;
				for (var stid:* in action.items) {
					if (!App.data.storage[stid]) {
						brokenAction = true;
					}else if (!Storage.shopLimitCanBuy(stid)) {
						brokenAction = true;
					}
				}
				for (stid in action.bonus) {
					if (!App.data.storage[stid]) {
						brokenAction = true;
					}else if (!Storage.shopLimitCanBuy(stid)) {
						brokenAction = true;
					}
				}
				
				if (brokenAction)
					continue;
				
				// Проверка если есть зона и она открыта
				var alreadyOpened:Boolean = false;
				for (var _sid:* in action.items) {
					if (App.data.storage[_sid].type == 'Zones') {
						if (World.zoneIsOpen(_sid))
							alreadyOpened = true;
					}
				}
				
				
				if (alreadyOpened)
					continue;
				if (TripleSaleWindow.continueAction(int(aID), actionsArch))
					continue;
					
				if (action.type == 0 || action.type == 9) { // Обычные
					
					//if (((action.unlock.level && level >= action.unlock.level) || (action.unlock.quest && quests.data.hasOwnProperty(action.unlock.quest) && quests.data[action.unlock.quest].finished == 0)) || (actionsArch.hasOwnProperty(aID) && actionsArch[aID] != null && actionsArch[aID].time + action.duration * 3600 > App.time)) {
					if ((actionsArch.hasOwnProperty(aID) && actionsArch[aID] != null && actionsArch[aID].time + action.duration * 3600 > App.time) ||
						(action.unlock.level && !action.unlock.quest && level >= action.unlock.level && (!action.unlock.lto || action.unlock.lto > level)) ||
						(action.unlock.quest && !action.unlock.level && quests.data.hasOwnProperty(action.unlock.quest) && quests.data[action.unlock.quest].finished == 0) ||
						(action.unlock.level && level >= action.unlock.level && (!action.unlock.lto || action.unlock.lto > level) && action.unlock.quest && quests.data.hasOwnProperty(action.unlock.quest) && quests.data[action.unlock.quest].finished == 0)) {
						
						open = true;
						if (!actionsArch.hasOwnProperty(aID)) {
							action.prime = 1;
							actionsArch[aID] = {
								prime:	1,
								buy:	0,
								time:	App.time
							};
						}else {
							if (actionsArch[aID].prime) actionsArch[aID].prime = 0;
							if (actionsArch[aID].time + action.duration * 3600 < App.time) {
								open = false;
							}
						}
						if(open) {
							action['begin_time'] = actionsArch[aID].time;
							promoNormal.push(action);
						}
					}else {
						if (actionsArch.hasOwnProperty(aID)) delete actionsArch[aID];
					}
				}else if (action.type == 1 || action.type == 10) { // Уникальные и специальные
					if (App.time >= action.time && App.time < action.time + action.duration * 3600 && (action.unlock.level && level >= action.unlock.level && (!action.unlock.lto || action.unlock.lto > level))) {
						open = true;
						if (!actionsArch.hasOwnProperty(aID)) {
							action.prime = 1;
							actionsArch[aID] = {
								prime:	1,
								buy:	0,
								time:	App.time
							};
						}else {
							if (actionsArch[aID].prime) actionsArch[aID].prime = 0;
						}
						action['begin_time'] = action.time;
						promoUnique.push(action);
					}else {
						if (actionsArch.hasOwnProperty(aID))
							delete actionsArch[aID];
					}
				}else if (action.type == 2) {
					if (App.time >= action.time && App.time < action.time + action.duration * 3600) {
						premiumPromos.push(action);
						if (!actionsArch.hasOwnProperty(aID)) {
							action['first'] = true;
							actionsArch[aID] = {
								shows:	0,
								buy:	0
							};
						}else {
							if (promoFirstParse) actionsArch[aID].shows ++;
						}
						action['shows'] = actionsArch[aID].shows;
						for (var sid:String in action.items) break;
						action['sid'] = sid;
					}
				}else if (action.type == 3) {
					oncePromos.push(action);
				}else if (action.type == 4) {
					boostPromos.push(action);
				}else if (action.type == 7) {
					if (action.unlock.level && level >= action.unlock.level && (!action.unlock.lto || action.unlock.lto > level)) {
						if (!actionsArch.hasOwnProperty(aID)) {
							if (action.object == ConstructWindow.actionTarget) {
								open = true;
								action.prime = 1;
								actionsArch[aID] = {
									prime:	1,
									buy:	0,
									time:	App.time
								};
								action['begin_time'] = App.time;
								showPromoWindow(aID);
							}
						}else if (actionsArch.hasOwnProperty(aID)) {
							if (actionsArch[aID].prime) actionsArch[aID].prime = 0;
							
							action['begin_time'] = actionsArch[aID].time;
							
							if (actionsArch[aID].time + action.time > App.time)
								open = true;
						}
						
						if (open)
							promoNormal.push(action);
					}else {
						if (actionsArch.hasOwnProperty(aID))
							delete actionsArch[aID];
					}
				}
				
				if (open) {
					promo[aID] = action;
				}
			}
			
			promoNormal.sortOn('order', Array.DESCENDING);
			promoNormal.sortOn('prime', Array.DESCENDING);
			promoUnique.sortOn('order', Array.DESCENDING);
			promoUnique.sortOn('prime', Array.DESCENDING);
			
			if (promoUnique.length > 0) promos.unshift(promoUnique.shift());
			if (promoNormal.length > 0) promos.push(promoNormal.shift());
			promos = promos.concat(promoUnique);
			promos = promos.concat(promoNormal);
			
			if (promoFirstParse) {
				if (premiumPromos.length > 0) {
					action = premiumPromos[0];
					//App.ui.rightPanel.createPremiumPromo(Boolean(action.first));
					action.first = false;
					if (action.shows < 3) {
						/*setTimeout(function():void {
							new PremiumWindow( {pID:action.pID} ).show();
						}, 3000);*/
					}
				}
				
				if (oncePromos.length > 0) {
					App.self.addEventListener(AppEvent.ON_STOCK_ACTION, onStockAction);
				}
			}
			
			promoFirstParse = false;
			
			storageStore('actions', actionsArch);
			
		}
		
		private var oncePromosIndx:Array = [];
		private function onStockAction(e:AppEvent = null):void {
			//if (onceOfferShow > 0) return;
			var onceWaitPromos:Array = [];
			for (var i:int = 0; i < oncePromos.length; i++) {
				if (!oncePromos[i].price || !oncePromos[i].price.hasOwnProperty(App.social)) continue;
				if (oncePromos[i].rel is Number && e.params.sids.indexOf(oncePromos[i].rel) >= 0 && stock.count(oncePromos[i].rel) == 0 && oncePromosIndx.indexOf(int(oncePromos[i].pID)) == -1) {
					onceWaitPromos.push(oncePromos[i]);
				}
			}
			
			if (onceWaitPromos.length > 0) {
				var pid:int = onceWaitPromos[Math.floor(onceWaitPromos.length * Math.random())].pID;
				new OnceOfferWindow( { pID:pid } ).show();
				oncePromosIndx.push(pid);
				//onceOfferShow = 300;
			}
		}
		
		private function showPromoWindow(aID:*):void {
			setTimeout(function():void {
				new PromoWindow( { pID:aID } ).show();
			}, 2000);
		}
		
		public function buyPromo(pID:String):void {
			if (App.data.actions[pID]['more'] == 1) return;
			
			var actionsArch:Object = storageRead('actions', { } );
			if (!actionsArch.hasOwnProperty(pID)) actionsArch[pID] = {};
			actionsArch[pID]['buy'] = 1;
			
			if (promo[pID]) {
				promo[pID]['buy'] = 1;
				promos.splice(promos.indexOf(promo[pID]), 1);
			}else {
				for (var i:int = 0; i < premiumPromos.length; i++) {
					if (premiumPromos[i].pID == pID) {
						premiumPromos[i]['buy'] = 1;
					}
				}
			}
			
			storageStore('actions', actionsArch, true);
		}
		public function unprimeAction(pID:String):void {
			var actionsArch:Object = storageRead('actions', {});
			if (actionsArch.hasOwnProperty(pID)) 
				actionsArch[pID]['prime'] = 0;
			promo[pID]['prime'] = 0;
			
			storageStore('actions', actionsArch);
		}
		
		public var aliens:Object = {
			m:{type: Hero.PRINCE, aka:App.data.storage[User.PRINCE].title, sid:User.PRINCE},
			f:{type: Hero.PRINCESS, aka:App.data.storage[User.PRINCESS].title, sid:User.PRINCESS}
		};
		
		public function addPersonag():void 
		{
			
			var position:Object = App.map.heroPosition;
			var positions:Array = findNewPositions(position.x, position.z, aliens.length);
			for (var i:int = 0; i < 1/*aliens.length*/; i++) {
				personages.push(new Hero(this, { id:Personage.HERO, sid:App.user.body, x:positions[i].x, z:positions[i].z, alien:'', aka:'' } ));
			}
			
			if(personages.length>0)
				personages[personages.length - 1].beginLive();
			
			if (Map.ready && App.map.id == MERRY_WORLD) {
				var merry:Personage = new Personage( { id:10, sid:Hero.MERRY, x:61, z:67, alien:Hero.MERRY, aka:'' }, 'merry');
				merry.framesType = Personage.STOP;
				merry.rotateTo( { x:merry.x + 1 } );
			}
			
			if (Map.ready && App.user.quests.data.hasOwnProperty(411) && App.user.quests.data[411].finished > 0 && App.map.id == 1122) {
				if (App.user.quests.data.hasOwnProperty(423) && App.user.quests.data[423].finished > 0) {
					var joes:Array = Map.findUnits([1091]);
					if (App.user.stock.count(1091) > 0 && joes.length == 0) {
						var settings:Object = { sid:1091, fromStock:true };
						var unit:Unit = Unit.add(settings);
						unit.stockAction({coords:{x:23, z:97}});
						unit.placing(23, 0, 97);
					}
				} else {
					var joe:WorkerUnit = new WorkerUnit( { id:10, sid:1127, x:153, z:168, alien:1127, aka:'' }, 'joe');
					joe.shortcutDistance = 20;
					joe.homeRadius = 5;
					joe.goHome();
					personages.push(joe);
				}
			}
			
			for each(var _hero:* in personages) {
				Unit.sorting(_hero);
			}
			
			App.ui.upPanel.update();
		}
		
		private var multiply:Object = { 227:2 };
		private var whimsyTerms:Object = { 59:{skip:1}, 72:{skip:1}, 73:{skip:1}, 95:{skip:1}}; //Нектар Опыт Монеты
		private var numOfShow:int = 3;
		public function showBooster(type:* = null):void {
			
			if (App.isSocial(/*'YB',*/'MX')) return;
			if (App.user.quests.tutorial) return;
			
			if (Config.admin) {
				whimsyTerms = { 59:{skip:1000} , 72:{skip:1000}, 73:{skip:1000}, 95:{skip:1000}};
			}
			
			var boostCanSell:Array = [];
			var skipBoost:Boolean;
			
			var delay:int = 0;
			for each(var s_:* in whimsyTerms) {
				if (int(s_.skip)>0) {
					delay = 1;	
				}
			}
			if (!delay) {
				boosterTimer = boosterTimeouts*10;	
			}
			
			/*if (level > 4 && numOfShow > 0 && boostCanSell.indexOf(int(type)) >= 0 && !Window.hasType(SaleBoosterWindow)) {
				new SaleBoosterWindow( { popup:true, pID:String(type)} ).show();
				numOfShow --;
			}*/
			
			for (var i:int = 0; i < boostPromos.length; i++) {
				skipBoost = false;
				for (var s:String in boostPromos[i].items) {
					if (stock.data.hasOwnProperty(s) && stock.data[s] > App.time) {
						skipBoost = true;
						if (Config.admin) skipBoost = false;
					}
					if (!skipBoost) {
						if (multiply.hasOwnProperty(boostPromos[i].pID)) {
							for (var j:int = 1; j < multiply[boostPromos[i].pID]; j++) {
								if (whimsyTerms[int(boostPromos[i].pID)].skip>0) {
									boostCanSell.push(int(boostPromos[i].pID));
								}
							}
						}
						if (whimsyTerms[int(boostPromos[i].pID)] && whimsyTerms[int(boostPromos[i].pID)].skip>0) {
								boostCanSell.push(int(boostPromos[i].pID));
						}
					}
				}
			}
			
			var index:int = 0;
			/*for (var s:String in whimsyTerms) {
				if (App.user.stock.count(int(s)) < App.time)
					boostCanSell.push(int(s));
			}*/
			if (boostCanSell.length > 0)
				index = boostCanSell[Math.floor(Math.random() * boostCanSell.length)];
				
			if (App.data.actions.hasOwnProperty(index)) {
				var sID:int = 0;
				for (var item:String in App.data.actions[index].items) {
					sID = int(item);
					break;
				}
				if (level > 4 && boostCanSell.indexOf(index) >= 0 && !Window.hasType(SaleBoosterWindow)) {
					if (stock.data.hasOwnProperty(sID) && stock.data.sID > App.time) return;
					new SaleBoosterWindow( { popup:true, pID:String(index) } ).show();
					whimsyTerms[index].skip--;
					boosterTimer = boosterTimeouts;
					boosterLimit --;
				}
			}
		}
		
		
		public function activeBooster():void {
			boostCompleteTime = 0;
			for (var id:String in stock.data) {
				if (App.data.storage[id].type == 'Vip' && stock.data[id] > App.time) {
					var percent:Number = 0;
					var boosted:int = 0;
					for (var s:String in App.data.storage[id].outs) {
						boosted = int(s);
						boosted = int(s);
						percent = App.data.storage[id].outs[s];
						break;
					}
					switch(boosted) {
						case Stock.EXP: App.ui.upPanel.expBoost.show(percent);
						/*setTimeout(function () : void
						{
							unactiveBooster()
						}, (stock.data[id]+1-App.time)*1000);*/
						break;
						case Stock.COINS: App.ui.upPanel.coinsBoost.show(percent); 
						/*setTimeout(function () : void
						{
							unactiveBooster()
						}, (stock.data[id]+1-App.time)*1000);*/
						break;
						case Stock.FANTASY: 
							App.ui.upPanel.energyBoost.show(Locale.__e('flash:1427979479987'),false); 
							Stock.energyRestoreTime = App.data.options['EnergyRestoreTime'] - App.data.options['EnergyRestoreTime'] * App.data.storage[id].outs[Stock.FANTASY] / 100;
							if (Stock.energyRestoreTime < 5) Stock.energyRestoreTime = 5;
							stock.diffTime = Stock.energyRestoreTime;
							/*setTimeout(function () : void
						{
							unactiveBooster()
						}, (stock.data[id]+1-App.time)*1000);*/
						break;
					}
					if (boostCompleteTime == 0 || boostCompleteTime > stock.data[id])
						boostCompleteTime = stock.data[id];
				}
			}
		}
		
		public function unactiveBooster():void {
			for (var id:String in stock.data) {
				if (App.data.storage[id].type == 'Vip' && stock.data[id] <= App.time) {
					for (var s:String in App.data.storage[id].outs) break;
					switch(int(s)) {
						case Stock.EXP: App.ui.upPanel.expBoost.hide(); break;
						case Stock.COINS: App.ui.upPanel.coinsBoost.hide(); break;
						case Stock.FANTASY: App.ui.upPanel.energyBoost.hide(); 
						Stock.energyRestoreTime = App.data.options['EnergyRestoreTime'];
						break;
					}
				}
			}
		}
		
		
		public function initTutorial():void {
			if (id == '1')
				storageStore('tutorial', { c:1, s:0 } );
			
			var tutorial:Object = storageRead('tutorial', { c:0, s:1 } );
			
			if (typeof(tutorial) == 'number') {
				tutorial = { c:0, s:1 };
				storageStore('tutorial', tutorial);
			}
			
			if (!tutorial.c && !quests.data.hasOwnProperty(5)) {
				App.tutorial = new Tutorial();
				App.tutorial.show(tutorial.s);
			}else {
				Tutorial.mainTutorialComplete = true;
			}
		}
		
		public static function get inExpedition():Boolean {
			
			/*openExpJson = JSON.parse(App.data.options.expeditionChange);
			if (App.SERVER == 'DM' && openExpJson) {
				return false;
			}*/			
			if (App.data.storage[App.user.worldID].size == World.MINI) return true;
			return false;
		}
		
		
		public function get hero():Hero {
			for each(var hero:* in App.user.personages) {
				if (hero.hasOwnProperty('main') && hero.main)
					return hero;
			}
			return App.user.personages[0];
		}
		
		public function returnHero(sid:uint, position:Object):void {
			if (App.data.storage[sid].type == "Character") {
				for (var i:int = 0; i < charactersData.length; i++) {
					if (sid == charactersData[i].sid) {
						var _character:Character = new Character({id:1, sid:charactersData[i].sid, x:position.x, z:position.z, type:charactersData[i].type});
						_character.cell = position.x;
						_character.row = position.z;
						_character.calcDepth();
						
						var index:int = arrHeroesInRoom.indexOf(sid);
						if (index != -1) arrHeroesInRoom.splice(index, 1);
						break;
					}
				}	
			}else {
				for (i = 0; i < aliens.length; i++) {
					if (sid == aliens[i].sid) {
						var _hero:Hero = new Hero(this, { id:Personage.HERO, sid:aliens[i].sid, x:position.x, z:position.z, alien:aliens[i].type, aka:aliens[i].aka } ); 
						personages.push(_hero);
						_hero.cell = position.x;
						_hero.row = position.z;
						_hero.calcDepth();
						
						index = arrHeroesInRoom.indexOf(sid);
						if (index != -1) arrHeroesInRoom.splice(index, 1);
						break;
					}
				}
			}
			
			App.ui.upPanel.update();
		}
		
		public function removePersonages():void 
		{
			for each(var _hero:* in personages) {
				_hero.uninstall();
				_hero = null;
			}
			personages = [];
			App.ui.upPanel.update();
		}
		
		public function removePersonage(sid:uint):void 
		{
			for (var i:int = 0; i < personages.length; i++ ) {
				var _hero:* = personages[i];
				if (_hero.sid == sid) {
					arrHeroesInRoom.push(sid);
					_hero.stopAnimation();
					_hero.uninstall();
					_hero = null;
					personages.splice(i, 1);
					i--;
				}
			}
			for ( i = 0; i < characters.length; i++ ) {
				var _character:Character = characters[i];
				if (_character.sid == sid) {
					if(arrHeroesInRoom.indexOf(sid) == -1)
						arrHeroesInRoom.push(sid);
						
					_character.stopAnimation();
					_character.uninstall();
					_character = null;
					characters.splice(i, 1);
					i--;
				}
			}
			App.ui.upPanel.update();
		}
		
		public function onStopEvent(e:MouseEvent = null):void {
			if (hero == null) return;
			
			for (var i:int = 0; i < personages.length; i++ ) {
				var pers:* = personages[i];
				if(pers._walk){
					pers.stopWalking();
				}
				pers.tm.dispose();
				pers.finishJob();
				if (pers.path) {
					pers.path.splice(0, pers.path.length);
				}
			}
			
			Field.clearBoost();
			for (i = Field.planting.length - 1; i > -1; i--) {
				Field.planting[i].removePlant();
				Field.planting.splice(i, 1);
			}
			var fields:Array = Field.findFields();
			for (i = 0; i < fields.length; i++) {
				if (!fields[i].formed) {
					fields[i].uninstall();
				}
			}
			
			for each(var target:* in App.user.queue) {
				if (target.target.ordered) {
					target.target.ordered = false;
					target.target.state = 4;		// DEFAULT
					target.target.worker = null;
					if (!target.target.formed) {
						target.target.uninstall();
					}
				}
				if (target.target.hasOwnProperty('reserved') && target.target.reserved > 0) {
					target.target.reserved = 0;
				}
			}
			
			App.user.queue = [];
			
			Cursor.material = false;
			if (ShopWindow.currentBuyObject.type) {
				ShopWindow.currentBuyObject.type = null;
			}
			
			Unit.clearGrid();
		}
		
		public function goHome(worldID:int):void {
			dreamEvent(worldID);
		}
		
		public function onProfileUpdate(data:Object):void {
			App.user.body = data.body;
			storageStore('body', App.user.body, true);
			removePersonages();
			addPersonag();
		}
		
		public function dreamEvent(wID:int):void {
			worldID = wID;
			Post.send( {
				'ctr':'user',
				'act':'state',
				'uID':id,
				'wID':wID,
				'fields':JSON.stringify(['world','stock'])
			},  function onLoad(error:int, data:Object, params:Object):void {
				if (error) {
					Errors.show(error, data);
					//Обрабатываем ошибку
					return;
				}
				
				App.self.setOffTimer(App.user.stock.checkEnergy);
				
				if (App.data.storage[worldID].size == World.MINI) {
					if (!data.world.hasOwnProperty('stock')) data.world['stock'] = { };
					for (properties in data.stock) {
						if (App.data.storage.hasOwnProperty(properties) && (App.data.storage[properties].mtype == 3 || App.data.storage[properties].type == 'Vip'))
							data.world.stock[properties] = data.stock[properties];
					}
					stock = new Stock(data.world.stock);
				}else {
					stock = new Stock(data.stock);
				}
				
				App.self.setOnTimer(App.user.stock.checkEnergy);
				
				units = data.units;
				world = new World(data.world);
				for (var properties:* in data.user)
				{
					this[properties] = data.user[properties];
				}
				
				var worlds:Object = {};
				for each(var wID:* in this.worlds) {
					worlds[wID] = wID;
				}
				this.worlds = worlds;
				
				checkInstances();
				
				App.self.dispatchEvent(new AppEvent(AppEvent.ON_USER_COMPLETE));
			});
		}
		
		public function initPersonagesMove(X:int, Z:int):void 
		{
			/*var _hero:Hero = hero;
			if (_hero.tm.status != TargetManager.FREE)
				return;
				
			var positions:Array = findNewPositions(X, Z, 1);
			_hero.initMove(positions[0].x, positions[0].z, _hero.onStop);*/
			
			var positions:Array = findNewPositions(X, Z, personages.length);
			
			var counter:int = 0;
			for each(var _hero:* in personages) {
				if (_hero.sid == 1127) {
					_hero.initMove(positions[counter].x, positions[counter].z, _hero.onStop);
				}else if(_hero.tm.status == TargetManager.FREE)
					_hero.initMove(positions[counter].x, positions[counter].z, _hero.onStop);
					
				counter++;
			}
			
			if (personages.length > 0)
				personages[int(Math.random() * personages.length)].makeVoice();
		}
		
		public var queue:Array = [];
		
		private function nearlestFreeHero(target:*):Hero {
			var resultHero:Hero;
			var dist:int = 0;
			for each(var _hero:* in personages) {
				if (_hero.sid == 1127) continue;
				if (_hero.tm.status != TargetManager.FREE)	continue;
				
				var _dist:int = Math.abs(_hero.coords.x - target.coords.x) + Math.abs(_hero.coords.z - target.coords.z);
				if (dist == 0 || dist > _dist) {
					dist = _dist;
					resultHero = _hero;
				}
			}
			return resultHero;
		}
		
		private function freeHero():Hero 
		{
			
			for each(var _hero:* in personages) {
				if (_hero.sid == 1127) continue;
				if (_hero.tm.status == TargetManager.FREE)
					return _hero;
			}
			return null;
		}
		
		/*public function getPersonag(sid:int):* 
		{
			var neededPers:Hero;
			for each(var pers:Hero in personages) {
				if(pers.targets.indexOf(sid) != -1)
					return pers;
			}
			
			return null;
		}*/
		
		public function addTarget(targetObject:Object):Boolean
		{
			var target:* = targetObject.target;
			var near:Boolean = targetObject.near || false;
			
			// если уже обрабатывается кем-то, то отдаем ему же в очередь
			if (target.worker) { 
				targetObject['event'] = target.worker.getJobFramesType(target.sid);
				target.worker.addTarget(targetObject); 
				return true; 
			}
			
			// ищем свободного, если нет отдаем первому
			var _hero:Hero;
			//var capacity:* = target.
			if (target is Resource) {
				_hero = nearlestFreeHero(target);
				if(_hero)
					targetObject['event'] = _hero.getJobFramesType(target.sid);
				
			}else{
				if (near)
					_hero = nearlestFreeHero(target);
				else	
					_hero = freeHero();
					
				if(_hero)
					targetObject['event'] = targetObject.event;
			}	
			
			if (_hero == null && targetObject.isPriority) {
				for each(_hero in personages) {
					_hero.addTarget(targetObject);
					return true;
				}
			}
			
			if (_hero == null) {
				if (targetObject.isPriority)
					queue.unshift(targetObject);
				else
					queue.push(targetObject);
			}else{
				//target.worker = _hero;
				_hero.addTarget(targetObject);
			}	
			return true;
		}
		
		private var radius:int = 5;
		private function findNewPositions(x:int, z:int, length:int = 2):Array {
			
			var positions:Array = [];
			var sX:int = x - radius;
			var sZ:int = z - radius;
			
			var fX:int = x + radius;
			var fZ:int = z + radius;
			
			for (var i:int = sX; i < fX; i++) {
				for (var j:int = sZ; j < fZ; j++) {
					if (App.map.inGrid( { x:i, z:j } )) {
						var node:AStarNodeVO = App.map._aStarNodes[i][j];
						if (!node.isWall) {
							positions.push( { x:i, z:j } );
						}
					}
				}
			}
			
			var result:Array = [
				{x:x, z:z}
			];
			
			for (var n:int = 0; n < length; n++) {
				result.push(takePosition(Math.random() * positions.length));
			}
			
			function takePosition(id:int):Object 
			{
				var position:Object = positions[id];
				positions.splice(id, 1);
				if (position == null) {
					position = {x:x, z:z };
				}
				return position;
			}
			
			//if(result[])
			
			return result;
		}
		
		public function takeTaskForTarget(_target:*):Array
		{
			var result:Array = [];
			for (var i:int = 0; i < queue.length; i++)	{
				if (queue[i].target == _target){ 
					result.push(queue[i]);
					queue.splice(i, 1);
					i--;
				}
			}
			
			return result;
		}
		
		public function addCharacter(object:Object):void {
			new Guide({ id:1, sid:object.sid, x:object.x, z:object.z});
		}
		public static function countCharacters(sID:int):uint {
			var count:uint = 0;
			for (var i:int = 0; i < App.user.characters.length; i++) {
				if (App.user.characters[i].sid == sID) {
					count ++;
				}
			}
			return count;
		}
		
		public function storageRead(name:String, defaultReturn:* = ''):* {
			if (!settings.hasOwnProperty(name)) return defaultReturn;
			
			try {
				var _value:Object = settings[name];
				return _value;
			}catch (e:*) {
				var _string:* = settings[name];
				return _string;
			}
		}
		public function storageStore(name:String, value:*, immediately:Boolean = false, added:Object = null):void {
			settings[name] = value;
			if (immediately) {
				settingsWait = settingsSaveEvery;
				settingsSave(added);
			}else {
				settingsWait = 0;
			}
		}
		public function settingsSave(added:Object = null):void {
			var presettings:String = JSON.stringify(settings);
			var compress:Boolean = true;
			
			if (_settings == presettings) return;
			_settings = presettings;
			
			var params:Object = {
				'uID':		id,
				'ctr':		'user',
				'act':		'settings',
				'settings':	presettings
			}
			if(added) {
				for (var s:String in added)
					params[s] = added[s];
			}
			
			Post.send(params, function(error:uint, data:Object, sett:Object):void {
				//
			}, {});
		}
		
		private var skipTimes:int = 3;
		private const settingsSaveEvery:uint = 3;
		private var settingsWait:uint = 0;
		public var ministock:Object = { items:{}, level:1 };
		public function totalTimer():void {
			// Daylics
			if (skipTimes > 0) {
				skipTimes--;
				return;
			}
			
				// Booster
			if (boostCompleteTime > 0 && boostCompleteTime < App.time) unactiveBooster();
			if (boosterTimer < 1) {
				if (boosterLimit > 0)
					showBooster();
			}
			boosterTimer--;
			
			if (App.time > App.nextMidnight) {
				App.nextMidnight += 86400;
				App.midnight += 86400;
				
				//try { Window.isClass(CalendarWindow).close() }catch(e:*){};
				try { Window.isClass(DaylicWindow).close() }catch(e:*){};
				App.user.quests.dayliInit = false;
				delete App.user.daylics.quests;
				App.user.quests.getDaylics(true);
			}
			
			// settings
			if (settingsWait == settingsSaveEvery) {
				settingsSave();
			}
			settingsWait++;
			
			// Stock actioner
			if (stock.actionTimer > 0 && stock.actionTimer + 1 < App.time) {
				stock.actionTimer = 0;
				stock.dispatchAction();
			}
		}
		
		public function takeBonus():void {
			if (quests.tutorial) return;
			
			Post.send( {
				ctr:	'Oneoff',
				act:	'get',
				id:		App.oneoff,
				uID:	App.user.id
			},function(error:int, data:Object, params:Object):void {
				if (error) return;
				
				if (data.hasOwnProperty('bonus')) {
					if (data.bonus is Boolean) {
						
					}else {
						new ReferalRewardWindow({bonus:Treasures.treasureToObject(data.bonus)}).show();
					}
				}
			});
		}
		
		
		public var arrBFFInvites:Array = [];
		public function checkBFF():void 
		{
			if (App.user.level <= 4) return;
			
			for (var friendInvite:* in bestFriendsInvites) {
				if(App.user.friends.data[friendInvite])
					arrBFFInvites.push(friendInvite);
			}
			if (arrBFFInvites.length > 0) 
			{
				new InviteBestFriendWindow(arrBFFInvites[0], null).show();
			}
		}
		
		public var checkDaysleft_Complete:Boolean = false;
		// Пероид отсутствия в игре
		public function checkDaysleft():void {
			if (!App.isSocial('DM', 'VK', 'OK', 'ML', 'FS', 'FB', 'NK')) return;
			
			if (checkDaysleft_Complete) return;
				checkDaysleft_Complete = true;
				
			if (!App.data.options.hasOwnProperty('LackBonus') || App.user.quests.tutorial) return;
			var luckBonus:Object = JSON.parse(App.data.options.LackBonus);
			//diffvisit = App.time - 86400 * 15;
			var daysLeft:int = 0;
			
			if (diffvisit <= 0) return;
			var maxDay:int = 0;
			for (var s:String in luckBonus) {
				var dayleftBonus:Object = luckBonus[s];
				if (diffvisit <= App.time - int(s) * 86400) {// && daysLeft * 86400 < App.time - diffvisit) {
					if (maxDay < int(s)) {
						maxDay = int(s)
						daysLeft = int(s);
					}
				}
			}
			
			if (daysLeft > 0 && luckBonus.hasOwnProperty(daysLeft)) {
				
				var visitLimit:Object = storageRead('visitLimit', { 3:3, 7:2, 14:2, 20:2 } );
				if (--visitLimit[daysLeft] < 0)
					return;
				
				storageStore('visitLimit', visitLimit, true);
				
				new BonusVisitingWindow( {
					type:'lack',
					bonus:luckBonus[daysLeft],
					onTake:function():void {
						if (App.isSocial('SP')) return;
						
						if (daysLeft >= 14) {
							Post.send( {
								ctr:		'user',
								act:		'money',
								uID:		App.user.id,
								enable:		1
							}, function(error:int, data:Object, params:Object):void {
								if (error) {
									Errors.show(error, data);
									return;
								}
								
								App.user.money = App.time + (App.data.money[App.social].duration || 24) * 3600;
								
								if (!App.isSocial('YN')) {
									if (!App.user.quests.tutorial)
										new BanksWindow().show();
								}
								
								App.ui.salesPanel.addBankSaleIcon();
							});	
						}
					}
				}).show();
			}
		}
		
	
	
	}
}