package
{
	import api.AIApi;
	import api.ExternalApi;
	import api.flashVarsGenerator;
	import api.GNApi;
	import api.MailApi;
	import api.MXApi;
	import api.VKApi;
	import api.OKApi;
	import api.FBApi;
	import api.YNApi;
	import buttons.Button;
	import buttons.CheckboxButton;
	import com.jac.mouse.MouseWheelEnabler;
	import com.junkbyte.console.Cc;
	import core.Admin;
	import core.CookieManager;
	import core.Debug;
	import core.Lang;
	import core.Log;
	import core.Log;
	import core.Numbers;
	import core.Post;
	import core.WallPost;
	import effects.Snowfall;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.GradientType;
	import flash.display.InteractiveObject;
	import flash.display.InterpolationMethod;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.SpreadMethod;
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.Capabilities;
	import flash.system.LoaderContext;
	import flash.system.SecurityDomain;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.ui.Keyboard;
	import flash.utils.describeType;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;
	import flash.utils.Timer;
	import strings.Strings;
	import ui.BottomPanel;
	import ui.SystemPanel;
	import units.Animal;
	import units.Box;
	import units.Decor;
	import units.Field;
	import units.Lantern;
	import units.PetHouse;
	import units.Pigeon;
	import units.Resource;
	import units.Techno;
	import wins.InfoWindow;
	import wins.NewUnlockedItemsWindow;
	import wins.SelectRewardWindow;
	import wins.ShopWindow;
	import wins._6WBonusWindow;
	import wins.actions.AnySalesWindow;
	import wins.actions.BanksWindow;
	import wins.actions.BuffetActionWindow;
	import wins.actions.EnlargeStorageWindow;
	import wins.BigsaleWindow;
	import wins.BonusVisitingWindow;
	import wins.ConciergeHelpWindow;
	import wins.DayliBonusWindow;
	import wins.actions.FattyActionWindow;
	import wins.FiestaWindow;
	import wins.FreeGiftsWindow;
	import wins.GroupGiftWindow;
	import wins.GroupWindow;
	import wins.GuestRewardsWindow;
	import wins.GuestRewardWindow;
	import wins.HelpWindow;
	import wins.HistoryWindow;
	import wins.IndianEventWindow;
	import wins.InformerWindow;
	import wins.InformWindow;
	import wins.InformWindow2;
	import wins.ItemsWindow;
	import wins.LevelUpWindow;
	import wins.actions.NewSpecialActionWindow;
	import wins.OfferWindow;
	import wins.OnceOfferWindow;
	import wins.PresentWindow;
	import wins.QuestRewardWindow;
	import wins.RouletteRewardWindow;
	import wins.RouletteWindow;
	import wins.SaleBoosterWindow;
	import wins.actions.SalesWindow;
	import wins.SalePackWindow;
	import wins.SimpleWindow;
	import wins.actions.SpecialActionWindow;
	import wins.actions.SpecialBoosterWindow;
	import wins.actions.TemporaryActionWindow;
	import wins.ThanksgivingEventWindow;
	import wins.TopAwardWindow;
	import wins.TopLeaguesWindow;
	import wins.TopRewardWindow;
	import wins.actions.UniqueActionWindow;
	import wins.TripleSaleWindow;
	import wins.Window;
	import core.IsoConvert;
	import core.Load;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.system.Security;
	import ui.UserInterface;
	import ui.WishList;
	import ui.Cursor;
	import com.sociodox.theminer.TheMiner;
	import units.Unit;
	import ui.Tips;
	import ui.HelpPanel;
	import ui.ContextMenu;
	import flash.text.Font;
	import wins.YahooGamesWindow;
	import units.Invader;
	import ui.WorldPanel;

	[SWF ( width = "900", height = "700", allowsFullScreen = true, backgroundColor = '#6C4735') ]//278295 //82c1ca
	
	public class App extends Sprite 
	{
		public static const USE_NEW_FREEBIE:Boolean = true;
		
		public static var data:Object;
		
		public static var user:User;
		
		public static var owner:Owner;
		public static var map:Map;
		public static var ui:UserInterface;
		public static var wl:WishList = new WishList();
		public static var network:*;
		public static var invites:Invites;
		
		public static var _fontScale:Number = 1;
		
		public static var social:String;
		public static var ref:String = "";
		public static var ref_link:String = "";
		
		public static var blink:String = "";
		public static var oneoff:String = "";
		
		public static var tips:Tips;
		
		public static var time:int = new Date().time / 1000;
		public static var serverTime:int = time;
		public static var midnight:int = 0; 
		public static var nextMidnight:int = 0;
		
		public static var defaultFont:Font;
		public static var reserveFont:Font;
		
		public var windowContainer:Sprite;
		public var contextContainer:Sprite;
		public var tipsContainer:Sprite;
		public var faderContainer:Sprite = new Sprite();
		
		public var complete:Boolean = false;
		
		public var mapCompleted:Boolean = false;
		public var introCompleted:Boolean = false;
		
		public var deltaX:int 		= 0;
		public var deltaY:int 		= 0;
		public var moveCounter:int 	= 0;
		
		public var flashVars:Object;
		public var frameCallbacks:Vector.<Function> = new Vector.<Function>();
		public var timerCallbacks:Vector.<Function> = new Vector.<Function>();
		
		private var prevTime:Number;
		public var fps:Number;
		
		public var timer:Timer;
		private var _timer:Timer = new Timer(60);
		
		public var preloader:*;
		public var changeLoader:Function = null;
		public var hideLoader:Function = null;
		
		public var intro:* = null;
		
		public static var self:App;
		private var old_seconds:uint = 0;
		
		public var constructMode:Boolean = false; 
		
		public static var tutorial:Tutorial;
		
		public var snowfall:Snowfall;
		
		Security.allowDomain("*");
        Security.allowInsecureDomain("*");
		
		[Embed(source="fonts/BRUSH-N(08.04.2016).ttf", fontName = "font",  mimeType = "application/x-font-truetype", fontWeight="normal", fontStyle="normal", advancedAntiAliasing="true", embedAsCFF="false")]
		//[Embed(source="fonts/meiryob.ttc",  fontName = "font",  mimeType = "application/x-font-truetype", fontWeight="normal", fontStyle="normal", advancedAntiAliasing="true", embedAsCFF="false")]
		public static var font:Class;
		
		[Embed(source = "fonts/arial.ttf", fontName = "arial",  mimeType = "application/x-font-truetype", fontWeight = "normal", fontStyle = "normal", advancedAntiAliasing = "true", embedAsCFF = "false")]
		public static var arial:Class;
		
		/**
		 * VK	103716091 (Света)   354551111 (Саша)	392720809 (Дима)
		 * AI	120635122
		 * MX	120635122
		 * GN	2208263
		 * FS	81529015
		 */
		
		public static const ID:* 		= '10206667913805287';			// 6652132
		public static const SOCIAL:* 	= 'FB';					// DM, VK, OK, ML, FB, PL NK
		public static const SERVER:* 	= 'FB'; 				// DM, VK, OK, ML, FB, PL NK
		public static var lang:String 	= 'ru';					// ru en fr es pl nl jp de it pt
		
		public static var VERSION:String = '20.12.4';					// ru en fr es pl nl jp
		
		public function App():void
		{
			//Font.registerFont(font);
			
			if (self){
				throw new Error("Вы не можете создавать экземпляры класса при помощи конструктора. Для доступа к экземпляру используйте Singleton.instance.")
			}else{
				self = this;
			}
			
			Security.allowDomain("*");
            Security.allowInsecureDomain("*");
			
			Cc.startOnStage(this, 'mko');
			
			//defaultFont = new font();
			reserveFont = new arial();
			
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
			
			/*var _text:String = "999 €GB";
			if (_text.search(/[^\s0-9a-zA-Z€aąbcćdeęfghijкklłmnńoóprsśtuwyxzźżAĄBCĆDEĘFGHIJКKLŁMNOÓPRSŚTUWYXZŹŻ\…\.,_\/\-\|\{\}\[\]\+\)\(\*\&\?\>\<\:\;\%\$\#\@\!\"\']/).toString()) {
				trace(_text);
			}*/
		}
		
		/**
		 * Инициализация приложения
		 * @param	e	событие
		 */
		private function init(e:Event = null):void
		{
			
			MouseWheelEnabler.init(stage);
			
			//панель показателей производительности игры
			//addChild(new TheMiner());
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			tips = new Tips();
			
			stage.scaleMode 	= StageScaleMode.NO_SCALE;
			stage.align 		= StageAlign.TOP_LEFT;
			
			if (stage.loaderInfo.parameters.hasOwnProperty('viewer_id'))
				flashVars = stage.loaderInfo.parameters;
			else if (stage.loaderInfo.parameters.hasOwnProperty('logged_user_id')){
				flashVars = stage.loaderInfo.parameters;
				flashVars['viewer_id'] = flashVars['logged_user_id'];
			}else
				flashVars = flashVarsGenerator.take(App.ID.toString());//(9490649)///(159185922)//174971289//89675457//100004640803161//sb_mbga_jp:132771 // 120635122	//134475609	//22606358		//22606358712619  //22606358712619   //2329711 - andrew  22612   //-235815106			
				
			/*if (flashVars['viewer_id'] == '243667149') {
				flashVars['viewer_id'] = '1';
			}*/
				
			if (flashVars.hasOwnProperty('blink'))
				App.blink = flashVars['blink'];
				
			if (flashVars.hasOwnProperty('oneoff'))
				App.oneoff = flashVars['oneoff'];
				
			this.addEventListener(AppEvent.ON_GAME_COMPLETE, onGameComplete);
			this.addEventListener(AppEvent.ON_MAP_COMPLETE, onMapComplete);
			
			//Грузим окна в кеш
			Cc.log(flashVars);
			
			if (flashVars.hasOwnProperty('secure'))
				Config.setSecure(flashVars.secure+"//");
			
			if (flashVars.hasOwnProperty('ref'))
				App.ref = flashVars.ref;
			
			if (flashVars.hasOwnProperty('testMode')) {
				Config.testMode = flashVars.testMode;
				Config.resServer = flashVars['viewer_id'] % 2;
			}
			
			if (flashVars.hasOwnProperty('version_content'))
				Config.version = flashVars.version_content;
			
			if (flashVars.hasOwnProperty('version_window'))
				Config.versionWindow = flashVars.version_window;
			
			Config.setServersIP(stage.loaderInfo.parameters);
			
			Log.alert('Узнали IP');
			Log.alert(flashVars);
			//Асинхронно грузим данные об игре и информацию о пользователе
			//Загрузка данных игры
			
			windowContainer = new Sprite();
			contextContainer = new Sprite();
			tipsContainer = new Sprite();
			
			tipsContainer.mouseChildren = false;
			tipsContainer.mouseEnabled = false;
			
			addChild(contextContainer);
			addChild(windowContainer);
			addChild(tipsContainer);
			addChild(faderContainer);
			
			if (flashVars.hasOwnProperty('lang'))
				lang = flashVars.lang;
			
			//если загружаемся из-под флеш девелопа, берем шрифт из embed, если грузимся из-под браузера, загружаем шрифт извне
			if (Capabilities.playerType == 'StandAlone') {
				if (!font)  return;
				Font.registerFont(font);
				loadLang();
			}else {
				if (!flashVars['font'])
					flashVars['font'] = 'font';
				
				if (flashVars.hasOwnProperty('font')) {
					loadFont(Config.getSwf('Font',flashVars['font']));
				}
			}
			
			/*setTimeout(function():void {
				new SimpleWindow({title:'a',text:'b'}).show();
			}, 15000);*/
		}
		
		private function loadFont(url:String):void 
		{
			var context:LoaderContext;
			if (!ExternalInterface.available){
				context = new LoaderContext(true);
			}else{
				context = new LoaderContext( true, new ApplicationDomain( ApplicationDomain.currentDomain ), SecurityDomain.currentDomain );
			}
			
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onFontLoad);  
			loader.load(new URLRequest(url), context);
        }
		
        public function onFontLoad(event:Event):void {
			var FontLibrary:Class = event.target.applicationDomain.getDefinition('AppFont') as Class;
			
			font = FontLibrary['font'];
            Font.registerFont(font);
			defaultFont = new font();
			
			loadLang();
		}
		
		private function loadLang():void {
			Lang.loadLanguage(lang, function():void {
				Load.loadText(Config.getData(), onGameLoad, true);
			});
		}
		
		private function translateGameData(data:*):void {
			for (var id:* in data) {
				var val:* = data[id];
				if (typeof val == 'object') {
					translateGameData(val);
				}else if(typeof val == 'string'){
					if (val.indexOf(':') != -1) {
						data[id] = Locale.__e(val);
					}
				}
			}
		}
		
		/**
		 * Событие завершения загрузки данных об игре
		 * @param	data	данные игры
		 */
		public var allWorlds:Array = [];
		private function onGameLoad(_data:String):void {
			data = JSON.parse(_data);
			data['invaders'] = [];
			for (var s:* in data.storage) {
				if (data.storage[s].type == 'Tribute' && data.storage[s].limit > 0)
				{
					trace('Tribute', s, data.storage[s].limit);
					data.storage[s]["gcount"] = data.storage[s].limit;
					delete data.storage[s].limit;
				}
				if (data.storage[s].type == 'Invader')
				{
					data['invaders'].push(data.storage[s]);
				}
			}
			
			findAndFormatNumbres();
			
			translateGameData(data);
			
			//Формируем коллекции
			for(var sID:* in data.storage){
				var item:Object = data.storage[sID];
				if(item.type == 'Collection'){
					item['materials'] = [];	
					for(var mID:* in data.storage){
						var material:Object = data.storage[mID];
						if (material.collection == sID) {
							item.materials.push(mID);
						}
					}
				}
				if (item.type == 'Lands') {
					allWorlds.push(sID);
				}
				
				if (sID == Stock.COINS && lang == 'jp') {
					item.view = item.view + '_jp';
					item.preview = item.preview + '_jp';
				}
				
				if (item.view == 'money_boost' && lang == 'jp') {
					item.view = item.view + '_jp';
					item.preview = item.preview + '_jp';
				}
			}
			
			//Деньги берем конкретно для сети
			social = flashVars['social'];
			
			//уменьшаем шрифт в игре для японских иероглифов
			if (App.lang == 'jp') {
				_fontScale = 0.7;
				tips.init();
			}
			
			//Проверяем акции
			checkPromo();
			
			//Включаем таймер (таймер общий во всей игре)
			timer = new Timer(1000);
			timer.start();
			timer.addEventListener(TimerEvent.TIMER, onTimerEvent);
			
			//подключаемся к социальной сети
			if (flashVars['social']) {
				connectToNetwork(flashVars.social);
			}
			Events.init();
			checkUpdates();
		}
		
		public function getLength(o:Object):uint {
			var length:uint = 0;
			for (var s:* in o)
				length++;
			
			return length;
		}
		
		private function findAndFormatNumbres():void {			
			data = toNumber(data);
			
			function toNumber(object:Object):Object {
				for (var s:String in object) {
					if (typeof(object[s]) == 'object') {
						object[s] = toNumber(object[s]);
					}else {
						if (object[s]) {
							var num:Number = Number(object[s]);
							if (!isNaN(num))
								object[s] = num;
						}
					}
				}
				
				return object;
			}
		}
		
		private function connectToNetwork(type:String):void 
		{
			Log.alert('PREPARE NETWORK. Available: ' + ExternalInterface.available.toString());
			
			if (ExternalInterface.available) {
				ExternalInterface.addCallback("updateBalance", function():void {
					ExternalApi.tries = 0;
					ExternalApi.updateBalance(true);
				});
				ExternalInterface.addCallback("openBank", function():void {
					if (!App.user.quests.tutorial) 
						new BanksWindow().show();
				});
				ExternalInterface.addCallback("openGifts", function():void {
					if (!App.user.quests.tutorial) 
						new FreeGiftsWindow().show();
				});
				ExternalInterface.addCallback("showInviteBox", function():void {
					ExternalApi.apiInviteEvent();
				});
				
				Log.alert('TYPE ' + type);
				switch(type) {
					case 'AI':
						if (ExternalInterface.available){	
							Log.alert('AI available');
							ExternalInterface.addCallback('openPayments', Payments.getHistory);
							
							ExternalInterface.addCallback("openBank", function():void {
								if (!user.quests.tutorial) {
									new BanksWindow().show();
								}
							});
							ExternalInterface.addCallback("openGifts", function():void {
								if (!user.quests.tutorial) {
									new FreeGiftsWindow().show();
								}
							});
							network = new AIApi(flashVars);
							Log.alert('STARTING NETWOTK');
						}else {
							Log.alert('AI not available');
							onNetworkComplete({
								profile:flashVars.profile,
								appFriends:flashVars.appFriends,
								wallServer:flashVars.wallServer,
								otherFriends:flashVars.otherFriends
							});
						}
						break;
					case 'YB':
					case 'NN':
						if (ExternalInterface.available){	
							
							ExternalInterface.addCallback('openPayments', Payments.getHistory);
							
							ExternalInterface.addCallback("openBank", function():void {
								if (!App.user.quests.tutorial) 
								{
									new BanksWindow({forcedClosing:true,
									popup:true}).show();
								}
							});
							ExternalInterface.addCallback("openGifts", function():void {
								if (!App.user.quests.tutorial) 
								{
									new FreeGiftsWindow({forcedClosing:true,
									popup:true}).show();
								}
							});
							
							ExternalInterface.addCallback("initNetwork", onNetworkComplete);
							ExternalInterface.call("initNetwork");
						}else {
							onNetworkComplete({
								profile:flashVars.profile,
								appFriends:flashVars.appFriends,
								wallServer:flashVars.wallServer,
								otherFriends:flashVars.otherFriends
							});
						}
						break;
					case 'PL':
					case 'SP':
					case 'HV':
					case 'FS':
						Log.alert('ADD initNetwork');
						ExternalInterface.addCallback("initNetwork", onNetworkComplete);
						ExternalInterface.call("initNetwork");
						break;
					case 'NK':
						if (ExternalInterface.available){
							ExternalInterface.addCallback("initNetwork", onNetworkComplete);
							ExternalInterface.call("initNetwork");
						}else {
							onNetworkComplete({
								profile:flashVars.profile,
								appFriends:flashVars.appFriends,
								wallServer:flashVars.wallServer,
								otherFriends:flashVars.otherFriends
							});
						}
						break
					case 'VK':
					case 'DM':
						ExternalInterface.addCallback("initNetwork", function(data:Object):void {
							new VKApi(App.self.flashVars, data, onNetworkComplete);
						});
						
						ExternalInterface.call("initNetwork");
					break;
					case 'GN':
					if (ExternalInterface.available)
					{						
						ExternalInterface.addCallback('openPayments', Payments.getHistory);						
						ExternalInterface.addCallback("openBank", function():void {
							if (!App.user.quests.tutorial) 
							{
								new BanksWindow({forcedClosing:true, popup:true}).show();
							}
						});
						ExternalInterface.addCallback("openGifts", function():void {
							{
								new FreeGiftsWindow().show();
							}
						});
						network = new GNApi(flashVars);
						Log.alert('STARTING NETWOTK');
					}else {
						onNetworkComplete({
							profile:flashVars.profile,
							appFriends:flashVars.appFriends,
							wallServer:flashVars.wallServer,
							otherFriends:flashVars.otherFriends
						});
					}
					break;
					case 'OK': 
						Cc.log('OK: logged_user_id = ' + flashVars['logged_user_id']);
						
						if(flashVars['logged_user_id'] != undefined){
							network = new OKApi(flashVars);
							
							ExternalInterface.addCallback("showInviteBox", function():void {
								network.showInviteBox();
							});
						}
						
						break;
					case 'ML':
						network = new MailApi(flashVars);
						break;
					case 'FB':
						ExternalInterface.addCallback("openInbox", function():void {
							new FreeGiftsWindow( {
								mode:FreeGiftsWindow.TAKE
							}).show();
						});
						
						network = new FBApi(flashVars);
						
						if (!ExternalInterface.available){	
							App.network['currency'] = {
								'usd_exchange_inverse': 1,
								'user_currency': 'RUR'
							}
						}
						
						break;
					case 'YN':
						
						network = new YNApi(flashVars);
						
						ExternalInterface.addCallback("initNetwork", onNetworkComplete);
						ExternalInterface.call("initNetwork");
						
						break;
					case 'MX':
						network = new MXApi(flashVars);
						if (ExternalInterface.available){	
							
							ExternalInterface.addCallback('openPayments', Payments.getHistory);
							
							ExternalInterface.addCallback("openBank", function():void {
								if (!App.user.quests.tutorial) 
									new BanksWindow().show();
							});
							ExternalInterface.addCallback("openGifts", function():void {
								if (!App.user.quests.tutorial) 
									new FreeGiftsWindow().show();
							});
						}
						break;
				}
			}else {
				onNetworkComplete({
					profile:flashVars.profile,
					appFriends:flashVars.appFriends,
					wallServer:flashVars.wallServer,
					otherFriends:flashVars.otherFriends
				});
			}
		}
		
		public function onNetworkComplete(data:Object):void 
		{
			Log.alert("ON_NETWORK_COMPLETE");
			Log.alert(data);
			
			network = data;
			Cc.log('onNetworkComplete');
			removeEventListener(AppEvent.ON_NETWORK_COMPLETE, onNetworkComplete);
			
			if (App.data.banlist != null && App.data.banlist[flashVars['viewer']] != undefined && App.data.banlist[flashVars['viewer']].inban) {
				var ban:Object = App.data.banlist[flashVars['viewer']];
				Load.loading(Config.getInterface('windows'), function(data:*):void { 					
					if (App.lang == 'jp') {
						data.moneyIco = data.moneyIco_jp;
					}
					Window.textures = data;
					setTimeout(function():void{
						new SimpleWindow( {
							'label':SimpleWindow.ATTENTION,
							'text': Locale.__e('flash:1382952379712', [ban.message]),
							'textSize': 22,
							'width': 560,
							'height': 350
						}).show();
					}, 3000);
					
					if(hideLoader != null) hideLoader();
				});
				return;
			}
			
			//Загрузка пользователя
			//addEventListener(AppEvent.ON_USER_COMPLETE, onUserComplete);
			//user = new User(flashVars['viewer_id']);
			
			//проверка на подмену ID в flashvars в консоли браузера
			if (App.isSocial(/*'FB',*/ 'VK', 'OK', 'ML', 'FS') && ExternalInterface.available) {
				ExternalApi.checkID(createUser)
			} else {
				createUser({id:flashVars['viewer_id']})
			}
			addEventListener(AppEvent.ON_USER_COMPLETE, onUserComplete);
			//addEventListener(AppEvent.ON_START_TUTORIAL, loadIntro);
		}
		
		public function createUser(result:Object):void {
			Log.alert('CREATE USER');
			Log.alert(result);
			if(result.id == flashVars['viewer_id'])
				user = new User(flashVars['viewer_id']);
			else
				Log.alert('Nice try')
		}
		
		//окончание загрузки карты
		private function onMapComplete(e:AppEvent):void {
			this.removeEventListener(AppEvent.ON_MAP_COMPLETE, onMapComplete);
			//Вызываем событие окончания загрузки игры, можно раставлять теперь объекты на карте
			mapCompleted = true;
			
			checkGameStart();
				
			if (!App.user.quests.tutorial) {
				//показываемся окно акций, если не проходим туториал
				showOffers();
				
				InformerWindow.init();
			}else {
				App.self.addEventListener(AppEvent.ON_FINISH_TUTORIAL, showOffers);
			}
			
			//подарок от группы
			//App.blink = 'b5704b872169bb';
			//App.user.quests.tutorial = true;
			if (App.data.hasOwnProperty('blinks') && App.data.blinks.hasOwnProperty(App.blink)) {
				var bbonus:Object = App.data.blinks[App.blink];
				if (bbonus.start < App.time && bbonus.start + bbonus.duration * 3600 > App.time && !App.user.blinks.hasOwnProperty(App.blink)) {
					if (!App.user.quests.tutorial)
						new GroupGiftWindow( { bonus:App.data.blinks[App.blink].bonus, mode:'blink', id:App.blink } ).show();
					else {
						var obj:Object = {
							ctr:	'user',
							act:	'blink',
							uID:	App.user.id
						};
						obj['blink'] = App.blink;
						Post.send(obj, function(error:int, data:Object = null, params:Object = null):void {
							App.user.stock.addAll(App.data.blinks[App.blink].bonus);
						});
					}
				}
			}
			
			if (!App.user.quests.tutorial && App.oneoff.length > 0)
				user.takeBonus();
			
			for each(var item:* in App.user._6wbonus) {
				var bonus:Object = App.data.bonus[item['campaign']] || null;
				if (bonus) {
					new _6WBonusWindow( { bonus:bonus } ).show();
				}
			} 
			
			if(App.user.trialpay != null){
				for each(var trialpay:Object in App.user.trialpay){
					Load.loading(Config.getImage('promo/images', 'crystals'), function(data:*):void {
						new SimpleWindow( {
							'label':SimpleWindow.CRYSTALS,
							'title': Locale.__e('flash:1382952379735'),
							'text': Locale.__e('flash:1384418596313', [int(trialpay[3])])
						}).show();
					});
				}
			}
			
			//App.user.addCharacter({sid:206, x:20, z:20});
			
			//включение снегопада на экране
			snowfall = new Snowfall();
			snowfall.hide();
			App.ui.systemPanel.bttnSnow.alpha = 0.5;
			if (SystemPanel.getSystemCookie(SystemPanel.SNOW) == '1') {
				snowfall.show();
				App.ui.systemPanel.bttnSnow.alpha = 1;
			}
			addChild(snowfall);
			
			//проверка на открытие окон-информеров при загрузке игры
			checkDambaInformer();
			checkBoatInformer();
		}
		
		//показываем информер 3 раза в день 7 дней подряд
		private function checkBoatInformer():void {
			if (App.user.level < 10) return;
			if (App.isSocial('YB', 'MX', 'AI', 'GN')) return;
			if (App.user.worldID != User.HOME_WORLD) return;
			if (App.user.quests.tutorial)	
				return;
			var boat:Array = Map.findUnits([315]);
			if (boat.length == 0) return;
			if (boat[0].level >= boat[0].totalLevels) return;
			
			var save:Boolean = false;
			var obj:Object = App.user.storageRead('infBoat', null);
			if (obj) {
				var count:int = Numbers.countProps(obj);
				if (count >= 21) return;
				
				var i:int = 0;
				for each (var item:Object in obj) {
					if (item.time < App.nextMidnight) {
						i++;
					}
				}
				if (i < 3) save = true;
				else return;
			}else {
				save = true;
			}
			
			if (save) {
				var saveObj:Object = App.user.storageRead('infBoat', null);
				if (saveObj) {
					var saveCount:int = Numbers.countProps(saveObj);
					saveObj[saveCount + 1] = {'time':App.time};
					App.user.storageStore('infBoat', saveObj, true);
				}else {
					var sv:Object = { };
					sv['1'] = {'time':App.time};
					App.user.storageStore('infBoat', sv, true);
				}
				
				setTimeout(function():void {
					new InformWindow2({mode:InformWindow2.BOAT_MODE, text:Locale.__e('flash:1466668533596')}).show();
				}, 3000);
			}
		}
		
		//показываем информер один раз в день 5 дней подряд
		private function checkDambaInformer():void {
			if (App.isSocial('YB', 'MX', 'AI', 'GN', 'FB','SP','NK')) return;
			if (App.user.worldID == Travel.SAN_MANSANO) return;
			if (App.user.quests.tutorial)	
				return;

			var save:Boolean = false;
			var obj:Object = App.user.storageRead('infDamba', null);
			if (obj) {
				var count:int = Numbers.countProps(obj);
				if (count >= 5) return;
				
				for each (var item:Object in obj) {
					if (item.time < App.nextMidnight && item.time > App.midnight) {
						return;
					}
				}
			}else {
				save = true;
			}
			
			if (save) {
				var saveObj:Object = App.user.storageRead('infDamba', null);
				if (saveObj) {
					var saveCount:int = Numbers.countProps(saveObj);
					saveObj[saveCount + 1] = {'time':App.time};
					App.user.storageStore('infDamba', saveObj, true);
				}else {
					var sv:Object = { };
					sv['1'] = {'time':App.time};
					App.user.storageStore('infDamba', sv, true);
				}
				
				setTimeout(function():void {
					new InformWindow2({mode:InformWindow2.DAMBA_MODE, text:Locale.__e('flash:1470144594072')}).show();
				}, 3000);
			}
		}
		
		private function showOffers(e:AppEvent = null):void {	
			showOfferWindow();
			showBigSaleWindow();
		}
		
		private function showBigSaleWindow():void {
			var sales:Array = [];
			var sale:Object;
			for (var sID:* in App.data.bigsale) {
				sale = App.data.bigsale[sID];
				if(sale.social == App.social)
					sales.push({sID:sID, order:sale.order, sale:sale});
			}
			sales.sortOn('order');
			for each(sale in sales) {
				if (App.time > sale.sale.time && App.time < sale.sale.time + sale.sale.duration * 3600) {
					BigsaleWindow.startAction(sale.sID, sale.sale);
					break;
				}
			}
		}
		
		private function showOfferWindow():void 
		{
			App.self.removeEventListener(AppEvent.ON_FINISH_TUTORIAL, showOfferWindow);
			if (App.user.quests.tutorial)	
				return;
				
			if (App.data.money != null && App.data.money[App.social]) 
			{
				if ((App.data.money[App.social].enabled && App.data.money[App.social].date_to > App.time && App.data.money[App.social].date_from < App.time) || (App.user.money > App.time))
					App.ui.salesPanel.addBankSaleIcon();
			}
		}
		
		
		//инициализация карты
		private function initMap():void	{
			map.visible = true;
			
			user.addPersonag();
			map.center();
			
			dispatchEvent(new AppEvent(AppEvent.ON_GAME_COMPLETE));
			//инициализация фонарей
			Lantern.init();
			
			//загружаем звуки
			SoundsManager.instance.loadSounds();
			
			if (!App.user.quests.tutorial) {
				//подгружаем иконки для окна ежедневного бонуса
				if(App.user.bonus == 0 && App.user.level > 5) 
					loadIcons();
				
				//показываем окно обновления
				setTimeout(function():void {
					if(!App.user.quests.tutorial)
						Pigeon.checkNews();
				}, 5000);
			}
			
			App.user.quests.checkFreebie();
		}
		
		//подгружаем рекурсивно иконки и после этого показываем окно ежедневного бонуса
		private function loadIcons(i:int = 0):void
		{
			var count:int = i;
			if (count == App.data.daylibonus.length)
			{
				new DayliBonusWindow().show();
				return;
			}
			for (var _sID:* in App.data.daylibonus[count].bonus) break;
			Load.loading(Config.getIcon(App.data.storage[_sID].type, App.data.storage[_sID].preview), function(data:Bitmap):void {
				DayliBonusWindow.icons.push({bmd:data.bitmapData, sid:_sID});
				count++;
				loadIcons(count);
			});
		}
		
		private function checkGameStart():void
		{
			App.user.stock.checkSystem();
			App.self.setOnTimer(App.user.stock.checkEnergy);
			user.quests.initQuests();
			initMap();
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			
			if (hideLoader != null) {
				hideLoader();
				Log.alert('hideLoader')
			}
		}
		
		private function onGameComplete(e:AppEvent):void 
		{
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			stage.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			
			stage.addEventListener(Event.MOUSE_LEAVE, mouseLeave);
			stage.addEventListener(Event.FULLSCREEN, onFullscreen);
			stage.addEventListener(MouseEvent.MOUSE_OUT, onOutStage);
			
			stage.addEventListener(Event.RESIZE, onResize);
			stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			
			this.removeEventListener(AppEvent.ON_GAME_COMPLETE, onGameLoad);
			
			user.friends.showHelpedFriends();
			
			//показываем окно предупреждение о закрытии игры на яху
			if (!App.user.quests.tutorial && App.isSocial('YN')) YahooGamesWindow.ShowYahooGamesWindow();
			
			checkNews();
			App.user.checkBFF();
			
			App.user.checkDaysleft();
			
			//showBulks();
			
			ShopWindow.init();
			WorldPanel.init();
			Events.checkEvents();
			//Events.initEvents(); 
			
			checkGroup();
			
			addBonusBox();
			
			// Проверка глобального доступа в магазине
			Storage.shopLimitCheck();
		}
		
		private function checkGroup():void {
			if (App.isSocial('YN','MX','SP','AI','GN')) return;
			if (App.isSocial('FB')) {
					setTimeout(function():void {
						if (int(App.user.storageRead('gw')) == 0 && !App.user.quests.tutorial && App.user.worldID == User.HOME_WORLD) {
							App.ui.bottomPanel.addCommunityButton();
							BottomPanel.communityAdd = true;
							App.ui.resize();
							new GroupWindow().show();
						}
					}, 5000);
				return;
			}
			var member:Boolean = false;
			ExternalApi.checkGroupMember(function(response:*):void {
				Log.alert('\n check Group Member Callback: ' + JSON.stringify(response));
				member = true;
				
				if (response) {
					member = true;
				} else {
					member = false;
				}
			});
			
			setTimeout(function():void {
				trace(int(App.user.storageRead('gw')));
				if (!member && int(App.user.storageRead('gw')) == 0 && !App.user.quests.tutorial && !App.isSocial('NK','HV','YN','YB','MX','GN') && App.user.worldID == User.HOME_WORLD) {
					Log.alert('not group member');
					App.ui.bottomPanel.addCommunityButton();
					BottomPanel.communityAdd = true;
					App.ui.resize();
					new GroupWindow().show();
				}
			}, 5000);
		}
		
		private function showBulks():void {
			for (var bulkID:* in data.bulks) {
				var bulk:Object = data.bulks[bulkID];
				if (bulk.social.hasOwnProperty(App.social)) {
					new SalesWindow( {
						action:bulk,
						pID:bulkID,
						mode:SalesWindow.BULKS,
						width:670,
						title:Locale.__e('flash:1385132402486')
					}).show();
					return;
				}
			}
		}
		
		private function onSpeedHack(e:Event):void
		{
		   new SimpleWindow( {
					label:SimpleWindow.ERROR,
					text:Locale.__e("flash:1382952379713")
				}).show();
			App.user.onStopEvent();	
		}
		
		private function mouseLeave(e:Event):void
		{
			cursorOut = true;
			moveCounter = 0;
		}
		
		private function onMouseWheel(e:MouseEvent):void {
			if (App.ui && App.ui.systemPanel && !App.user.quests.tutorial)
				App.ui.systemPanel.onMouseWheel(e);
				
			App.self.dispatchEvent(new AppEvent(AppEvent.ON_WHEEL_MOVE, false, false, {delta:e.delta}));
		}
		
		private function onFullscreen(e:Event):void {
			setTimeout(function():void { mouseLeave(e) }, 10);
			ExternalApi.gotoScreen();
		}
		
		private function onOutStage(e:MouseEvent):void {
			if (!(e.stageX > 0 && e.stageX < stage.stageWidth && e.stageY > 0 && e.stageY < stage.stageHeight)) {
				mouseLeave(e);
			}
		}
		
		/**
		 * Событие завершения загрузки данных пользователя
		 * @param	e	объект события
		 */
		private function onUserComplete(e:AppEvent):void
		{
			Log.alert('USER complete');
			
			removeEventListener(AppEvent.ON_USER_COMPLETE, onUserComplete);
				
			/*if (user.quests.isTutorial) {
				User.checkBoxState = CheckboxButton.UNCHECKED;
				if(App.self.changeLoader != null) App.self.changeLoader("hasIntro", 0);	
			}*/
			
			Log.alert('UI create');
			this.addEventListener(AppEvent.ON_UI_LOAD, onUILoad);
			ui = new UserInterface();
			
			Log.alert('PANELS start');
			Load.loading(Config.getInterface('panels'), function(data:*):void {
				Log.alert('PANELS complete');
				if (App.lang == 'jp') {
					data.coinsIcon = data.coinsIcon_jp;
				}
				UserInterface.textures = data;
				
				onComplete();
			});
			
			Log.alert('WINDOWS start');
			Load.loading(Config.getInterface('windows'), function(data:*):void {
				Log.alert('WINDOWS complete');
				Window.textures = data;
				ExternalApi.setCloseApiWindowCallback();
				
				onComplete();
			},  0, false, 
			function(progress:Number):void{
				if(changeLoader != null) changeLoader('wins', progress);
			});
			
			function onComplete():void {
				if (Window.textures && UserInterface.textures) {
					
					// Window
					Log.alert('UI loaded');
					
					if (App.social == 'GN')
					{
						invites = new Invites();
						invites.init(null);
						Payments.getHistory(false);
					}
					
					if (Invites.externalPermission) {
						invites = new Invites();
						invites.init(function():void {});
					}
					addChildAt(ui, getChildIndex(windowContainer) - 1 );
					
					if (intro != null && contains(intro)){
						setChildIndex(intro, App.self.numChildren-1);
					}
					
					// UserInterface
					App.ui.onLoad();
				}
			}
		}
		
		/**
		 * Событие завершения загрузки интерфейса
		 * @param	e	объект события
		 */
		private function onUILoad(e:AppEvent):void
		{
			this.removeEventListener(AppEvent.ON_UI_LOAD, onUILoad);
			
			//Загрузка карты
			map = new Map(user.worldID, user.units);
			map.visible = false;
			drawBackground();
			
			Log.alert('MAP created');
		}
		
		/**
		 * Добавление функции обратного вызова на событие EnterFrame
		 * @param	callback	функция обратного вызова
		 */
		public var enterFrameHandlers:Vector.<Function> = new Vector.<Function>;
		public function setOnEnterFrame(callback:Function):void {
			if (enterFrameHandlers.indexOf(callback) != -1) return;
			enterFrameHandlers.push(callback);
			addEventListener(Event.ENTER_FRAME, callback);
		}
		
		/**
		 * Удаление функции обратного вызова с события EnterFrame
		 * @param	callback	функция обратного вызова
		 */
		public function setOffEnterFrame(callback:Function):void {
			if (enterFrameHandlers.indexOf(callback) >= 0)
				enterFrameHandlers.splice(enterFrameHandlers.indexOf(callback), 1);
			
			removeEventListener(Event.ENTER_FRAME, callback);
		}
		
		/**
		 * Событие EnterFrame
		 * @param	e	объект события
		 */
		private function onEnterFrame(e:Event):void {
			getFps(e);
		}
		
		public function setOnTimer(callback:Function):void {
			timerCallbacks.push(callback);
		}

		public function setOffTimer(callback:Function):void {
			var index:int = timerCallbacks.indexOf(callback);
			
			if(index != -1){
				timerCallbacks[index] = null;
			}
		}
		
		
		private var date:Date;
		private var date2:Date;
		private var diff:int = 0;
		private var last:int = getTimer();
		private function onTimerEvent(e:TimerEvent):void {
			time += 1;
			
			for (var i:int = 0; i < timerCallbacks.length; i++ ) {
				if(timerCallbacks[i] != null){
					timerCallbacks[i].call();
				}
			}
			for (i = 0; i < timerCallbacks.length; i++ ) {
				if(timerCallbacks[i] == null){
					delete timerCallbacks[i];
				}
			}
			
			// Компенсатор времени
			if (date) date2 = date;
			date = new Date();
			
			if (date && date2) {
				diff += date.getTime() - date2.getTime() - 1000;
				if (diff > 1000) {
					time += 1;
					diff -= 1000;
					//Cc.log('TIME OF SECOND LOST! ' + ((getTimer() - last) / 1000).toString() + 'сек');
					last = getTimer();
				}
			}
		}
		
		/**
		 * Событие перемещения мыши
		 * @param	e	объект события
		 */
		//public var isMapMove:Boolean = false;
		public var cursorOut:Boolean = false;
		public var overTarget:Unit;
		private function onMouseMove(e:MouseEvent):void 
		{
			if (ItemsWindow.isOpen)
				return;
			
			moveCounter++;
			
			if (e.buttonDown == true && moveCounter>2 && !Window.isOpen && !cursorOut && !Animal.isMove && !Techno.isMove) { //  && !Field.quickStorage && !Walkgolden.isMove
				
				var dx:int = e.stageX - deltaX;
				var dy:int = e.stageY - deltaY;
				
				deltaX = e.stageX;
				deltaY = e.stageY;
				
				map.redraw(dx, dy);
				tips.relocate();
				HelpPanel.hideAll();
				
				if (overTarget && overTarget is Resource) {
					(overTarget as Resource).storageSkipPack();
				}
			}else{
				var target:* = e.target;
				var _target:* = e.target;
				UserInterface.over = false; 
				//trace(target);
				if (!(target is Unit || target is Map)) 
				{
					while (target.parent != null) {
						if (target.parent is UserInterface || target is HelpPanel || target.parent is HelpPanel || target.parent is ContextMenu){
							UserInterface.over = true;
							map.untouches();
							break;
						}
						target = target.parent;
					}
				}
				
				var point:Object = IsoConvert.screenToIso(map.mouseX, map.mouseY, true);
				
				Map.X = point.x>0?point.x:0;
				Map.Z = point.z>0?point.z:0;
				Map.X = Map.X < Map.cells?Map.X:Map.cells - 1;
				Map.Z = Map.Z < Map.rows?Map.Z:Map.rows - 1;
							
				target = e.target;
				
				if(App.map._aStarNodes){
					if (App.map._aStarNodes[Map.X][Map.Z].z != 0 && App.map._aStarNodes[Map.X][Map.Z].open == false)
					{	
						if (Window.isOpen || UserInterface.over) {
							Cursor.init();
						}else {
							Cursor.type = 'locked';
						}
					}
					else if (Cursor.type == 'locked')
					{
						Cursor.init();
					}
				}
				
				if(!UserInterface.over && !Window.isOpen){
					map.touches(e);
					if (map.touched && map.touched.length > 0) {
						target = map.touched[0];
					}
					
					if (target && target is Unit)
						overTarget = target as Unit;
				}
				if (!map.moved) {
					if (UserInterface.over || Window.isOpen) {
						tips.show(_target as DisplayObject);
					}else if (target is Unit && target.touch ) {
						tips.show(target as DisplayObject);
					}else {
						tips.hide();
					}
				}else {
					tips.hide();
				}
			}
		}
		
		/**
		 * Событие нажатия кнопки мыши	
		 * @param	e	объект события
		 */
		private function onMouseDown(e:MouseEvent):void {
			moveCounter = 0;
			
			var elm:* = e.target;
			
			cursorOut = false;
			deltaX = e.stageX;
			deltaY = e.stageY;
			
			
			dispatchEvent(new AppEvent(AppEvent.ON_MOUSE_DOWN));
			
			for (var i:int = 0; i < map.touched.length; i++ ) {
				if (map.touched[i] is Unit/* || map.touched[i] is Techno*/) {
					map.touched[i].onDown();
					break;
				}
			}
			
			if (user.mode == User.OWNER && !UserInterface.over && !Window.isOpen && overTarget && overTarget is Resource)
				(overTarget as Resource).storageStartPack();
			
			//trace(IsoConvert.screenToIso(map.mouseX, map.mouseY, true).x, IsoConvert.screenToIso(map.mouseX, map.mouseY, true).z);
			//trace(map.mouseX, map.mouseY);
		}
		
		/**
		 * Событие отпускания кнопки мыши
		 * @param	e	объект события
		 */
		private function onMouseUp(e:MouseEvent):void {
			
			cursorOut = false;
			
			if (Window.isOpen || ItemsWindow.isOpen || UserInterface.over) return;
			
			if (moveCounter < 4) {
				if (map.moved != null) {
					if (!map.moved.canInstall()){
						return;
					}
					
					map.moved.move = false;
					
					if (map.moved && !map.moved.formed && map.moved.multiple == true && Unit.lastUnit != null) {
						if (App.data.storage[Unit.lastUnit.sid].type == 'Decor') 
						{
							Cursor.loading = true;
							setTimeout(function():void {
								Cursor.loading = false;
								Unit.addMore();
							}, 600)
						}
						else
						{
							Unit.addMore();
						}
					}else {
						map.moved = null;
					}
					
				}else if (map.touched.length > 0) {
					if (overTarget && overTarget is Resource)
						(overTarget as Resource).storageStopPack();
						
					map.touch();
				}else {
					map.click();
				}
				
				//dispatchEvent(new AppEvent(AppEvent.ON_MOUSE_UP));
			}
			else
			{
				SoundsManager.instance.soundReplace();
			}
			
			dispatchEvent(new AppEvent(AppEvent.ON_MOUSE_UP));
		}
		
		/**
		 * Событие нажатия кнопки клавиатуры
		 * @param	e	объект события
		 */
		private function onKeyDown(e:KeyboardEvent):void 
		{
			Log.alert('onKeyDown');
			
			if (e.keyCode == Keyboard.I && e.ctrlKey) {
				new SimpleWindow({
					title:			"System",
					text: 			App.VERSION
				}).show();
			}
			
			if (e.keyCode == Keyboard.U && e.ctrlKey) {
				YahooGamesWindow.ShowYahooGamesWindow();
			}
			
			var keyDescription:XML = describeType(Unit);
			var keyNames:XMLList = keyDescription..constant.@name;
			
			if (!Config.admin) return;
			
			if (e.keyCode == Keyboard.Y && e.ctrlKey)
				Admin.show();
			
			/*if (e.keyCode == Keyboard.M && e.ctrlKey) {
				var sids:Array = [];
				for (var s:* in data.storage) {
					sids.push(s);
				}
				var list:Array = [];
				while (list.length < 3) {
					list.push(sids[int(sids.length * Math.random())]);
				}
				
				ShopWindow.find(list);
				trace(list);
			}*/
			
			
			
			if (e.keyCode == Keyboard.Q)
				//new DayliBonusWindow().show();
			
			
			if (e.keyCode == Keyboard.F) {
				App.user.showBooster();
			}
			
			
			if (e.keyCode == Keyboard.N) {
				Pigeon.checkNews(80);
			}
			
			if (e.keyCode == Keyboard.W) {
				App.map.grid = true;
			}
			
			if (e.keyCode == Keyboard.P) {
				trace('map: {x:' + App.map.x +  ' ,y:' + App.map.y + '}, hero: {x:' + App.user.hero.coords.x +  ' ,y:' + App.user.hero.coords.z + '}');
			}
			
			/*if (e.keyCode == Keyboard.Y) {
				new InformWindow2({mode:InformWindow2.DAMBA_MODE, text:Locale.__e('flash:1470144594072')}).show();
			}*/
			
			if (e.keyCode == Keyboard.E) {
				if (App.user.id == "7584561")
				{
					new TripleSaleWindow({pID:4031}).show();
				}
			}
		}
		
		/**
		 * Событие изменения размеров приложения
		 * @param	e	объект события
		 */
		private function onResize(e:Event):void {
			App.ui.resize();
			background.width = stage.stageWidth;
			background.height = stage.stageHeight;
			
			dispatchEvent(new AppEvent(AppEvent.ON_RESIZE));
		}
		
		private function getFps(e:Event):void
        {
			fps = Math.round(1000 / (getTimer() - prevTime));
			fps = fps > 31?31:fps;
			
            prevTime = getTimer();
        }
		
		private function checkPromo():void {
			for (var promoID:* in App.data.promo) {
				var promo:Object = App.data.promo[promoID];
				// Удаляем всех не из этой сети
				if (!promo.hasOwnProperty('price') || !promo.price.hasOwnProperty(App.social)) {
					delete App.data.promo[promoID];
				}
			}
		}
		
		private function checkUpdates():void {
			/**1
			 * Переписывает из параметров социальной сети "currentSocial" данные в текущую социальную сеть (для подмены)
			 */
			flashVars.currentSocial = 'DM';
			if (flashVars.currentSocial && data.updatelist.hasOwnProperty(flashVars.currentSocial)) {
				
				data.updatelist[App.social] = data.updatelist[flashVars.currentSocial];
				
				for (updateID in App.data.updates) {
					update = App.data.updates[updateID];
					
					if (update.social.hasOwnProperty(flashVars.currentSocial))
						update.social[App.social] = App.social;
						
					if (update.ext.hasOwnProperty(flashVars.currentSocial))
						update.ext[App.social] = App.social;
					
				}
			}
			
			
			for (var updateID:* in App.data.updates) {
				var update:Object = App.data.updates[updateID];
				if (updateID == "u58207fa70c0a7" || updateID == "u5832acb95a4a3")
					trace();
				if (!update.hasOwnProperty('social') || !update.social.hasOwnProperty(App.social)) {
					for (var sID:* in update.items) {
						//if (sID == 2824)
							//trace();
						
						if (!update.ext.hasOwnProperty(App.social)) {
							if(App.data.storage[sID] != null) 
								App.data.storage[sID].visible = 0;
						} else {
							var exclude:Boolean = true;
							for (var id:* in update.stay) {
								if (sID == id) {
									exclude = false;
									break;
								}
							}
							if (exclude && App.data.storage[sID] != null) {
								App.data.storage[sID].visible = 0;
							}
						}
					}
				}		
			}
		}
		
		private function addBonusBox():void {
			if (App.user.mode != User.OWNER || App.map.id != User.HOME_WORLD) return;
			
			if (!App.data.options.hasOwnProperty('AddBox')) return;
			var info:Object = JSON.parse(App.data.options.AddBox);
			
			for each (var present:Object in info.boxes) {
				if (!present.hasOwnProperty('social') || present.social.indexOf(App.social) < 0) continue;
				var boxSID:int = present.box.sid;
				var time:int = present.box.time;
				
				if (time < App.time) continue;			
				
				var boxes:Object = App.user.storageRead('bonusBox', null);
				if (!boxes) boxes = { };
				if (boxes && boxes.hasOwnProperty(boxSID))
					continue;
				
				boxes [boxSID] = App.time;
				var position:Object = App.map.heroPosition;
				var box:Box = new Box({sid:boxSID, x:position.x - 2, z:position.z});
				box.buyAction();
				
				App.user.storageStore('bonusBox', boxes, true);
			}
	
		}
		
		public function userNameSettings(textSettings:Object):Object {
			if (App.self.flashVars['font']) {
				//if (!App.isSocial('YB','MX'))
					//textSettings['fontFamily'] = 'fontArial';
				textSettings['fontSize'] = 16;
			}
			return textSettings;
		}
		
		public var background:Shape;
		public function drawBackground(colors:Array = null):void {
			//return;
			if (background != null)
				App.self.removeChild(background);				
				
				background = new Shape();
				background.graphics.beginFill(map.bgColor, 1);
				background.graphics.drawRect(0, 0, 100, 100);
				background.graphics.endFill();
				App.self.addChildAt(background, 0);
				background.width = stage.stageWidth;
				background.height = stage.stageHeight;
		}
		
		public var _bgColor:*;
		public function get bgColor():* {
			return _bgColor;
		}
		public function set bgColor(color:*):void {
			_bgColor = color;
			drawBackground();
		}
		
		public function checkNews():void {
			
			if (App.user.quests.tutorial)
				return;
			setTimeout(function():void 
			{
				for (var newsID:* in data.news) {
					var news:Object = data.news[newsID];
					if (news.social != App.social) continue;
					if (App.time > news.time + news.duration * 3600) continue;
					
					if (ExternalInterface.available) {
						var cookieName:String = "news_" + newsID;
						var value:String = CookieManager.read(cookieName);
						if (value != "1") {
							
						}else{
							continue;
						}
					}
					
					App.ui.showNews(news, cookieName);
				}
			}, 5000);
			
		}
		
		public static function isSocial(... params):Boolean {
			for (var i:int = 0; i < params.length; i++) {
				if (params[i] == App.social)
					return true;
			}
			
			return false;
		}
		
		public function sendPostWake():void {
			var message:String = Strings.__e("WakeUp_sendPost", [Config.appUrl]);
			var bitmap:Bitmap = new Bitmap(UserInterface.textures.postGame, "auto", true);
		
			if (bitmap != null) {
				Log.alert('ExternalApi.apiWallPostEvent +');
				ExternalApi.apiWallPostEvent(ExternalApi.PROMO, bitmap, String(App.owner.id), message, 0, onPostComplete, {url:Config.appUrl});
			}
				
		}
	
		public function onPostComplete(result:*):void {
		Log.alert('Alert +' + result);
		if (App.social == "ML" && (/*result.status != "publishSuccess" ||*/ result.status != "opened"))
				return;		
		
		switch(App.self.flashVars.social) {
			case "VK":
			case "DM":
					if (result != null && result.hasOwnProperty('post_id')) {
					
					Post.send( {
						ctr:'friends',
						act:'alert',
						uID:App.user.id,
						fID:App.owner.id
					},function(error:*, data:*, params:*):void {
						if (error) {
							Errors.show(error, data);
							return;
						}
						App.ui.upPanel.hideWakeUpPanel();
						if (data != null && data.hasOwnProperty('bonus') && data.bonus!={}) 
						{
							//new BonusVisitingWindow( { bonus:Treasures.treasureToObject(data.bonus), wakeUpBonus:true } ).show();
							var rewData:Object = { };
							rewData['character'] = 1;
							rewData['title'] = Locale.__e('flash:1406554650287');
							rewData['description'] = Locale.__e('flash:1393518655260');
							rewData['bonus'] = { };
							rewData['bonus']['materials'] = Treasures.treasureToObject(data.bonus);
							new QuestRewardWindow( {
								data:rewData,
								levelRew:true,
								forcedClosing:true,
								strong:false
							}).show();
							App.user.stock.addAll(Treasures.treasureToObject(data.bonus));
							App.user.friends.data[App.owner.id].alert = App.time;
						}
					});
					}
				break;
			case "OK":
			case "ML":
			case "FB":
			case "NK":
					if (result != null && result != "null") {
						Post.send( {
							ctr:'friends',
							act:'alert',
							uID:App.user.id,
							fID:App.owner.id
						},function(error:*, data:*, params:*):void {
							if (error) {
								Errors.show(error, data);
								return;
							}
							App.ui.upPanel.hideWakeUpPanel();
							if (data !=null && data.hasOwnProperty('bonus') && data.bonus != {}) 
							{
								//new BonusVisitingWindow( { bonus:Treasures.treasureToObject(data.bonus), wakeUpBonus:true } ).show();	
								var rewData:Object = { };
								rewData['character'] = 1;
								rewData['title'] = Locale.__e('flash:1406554650287');
								rewData['description'] = Locale.__e('flash:1393518655260');
								rewData['bonus'] = { };
								rewData['bonus']['materials'] = Treasures.treasureToObject(data.bonus);
								new QuestRewardWindow( {
									data:rewData,
									levelRew:true,
									forcedClosing:true,
									strong:false
								}).show();
								App.user.stock.addAll(Treasures.treasureToObject(data.bonus));
								App.user.friends.data[App.owner.id].alert = App.time;
							}
						});
					}
				break;
			case "FS":
					if (result) {
						Post.send( {
							ctr:'friends',
							act:'alert',
							uID:App.user.id,
							fID:App.owner.id
						},function(error:*, data:*, params:*):void {
							if (error) {
								Errors.show(error, data);
								return;
							}
							App.ui.upPanel.hideWakeUpPanel();
							if (data !=null && data.hasOwnProperty('bonus') && data.bonus != {}) 
							{
								//new BonusVisitingWindow( { bonus:Treasures.treasureToObject(data.bonus), wakeUpBonus:true } ).show();	
								var rewData:Object = { };
								rewData['character'] = 1;
								rewData['title'] = Locale.__e('flash:1406554650287');
								rewData['description'] = Locale.__e('flash:1393518655260');
								rewData['bonus'] = { };
								rewData['bonus']['materials'] = Treasures.treasureToObject(data.bonus);
								new QuestRewardWindow( {
									data:rewData,
									levelRew:true,
									forcedClosing:true,
									strong:false
								}).show();
								
								App.user.stock.addAll(Treasures.treasureToObject(data.bonus));
								App.user.friends.data[App.owner.id].alert = App.time;
							}
						});
					}
				break;	
				
			
		}
	
		}
	}
}