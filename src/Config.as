package
{
	import core.CookieManager;
	import core.Log;
	import core.MD5;
	import flash.system.Capabilities;
	import flash.utils.getTimer;

	public class Config
	{
		public static var _mainIP:Array;
		public static var _resIP:*;
		
		public static var _curIP:String;
		
		public static var testMode:int = 1;
		public static var resServer:uint = 0;
		
		public static var version:int = 1153;// Math.random() * 999999999;
		public static var versionWindow:int = 1153;// Math.random() * 999999999;
		
		public static var secure:String = "http://";
		
		public static var OK:Object = {
			secret_key:'F14C5E5AB7A94D44E8D3D8D5'
		};
		
		public static function get appUrl():String
		{
			switch(App.self.flashVars.social) {
				case 'VK':
				case 'DM':
					return 'http://vk.com/app4878452';
				break;	
				case 'ML':
					return 'http://my.mail.ru/apps/705236';
				break;
				case 'OK':
					return 'http://ok.ru/game/1134327040';
				break;
				case 'FS':
					return 'http://fotostrana.ru/app/goldenfrontier';
				break;
				case 'NK':
					return 'http://nk.pl/#applications_test/51cc296248feeaf3';
				break;
				case 'FB':
					return 'https://apps.facebook.com/goldenfrontier';
				break;
				case 'AI':
					return 'http://wp.aima.woopie.jp/v2/g/500566/play';
				break;
				case 'YB':
					return 'http://yahoo-mbga.jp/game/12023559/play';
				break;
				case 'MX':
					return 'http://mixi.jp/run_appli.pl?id=41105';
				break;
				default:
					return '';
				break;
			}
		}
		
		public function Config()
		{
			
		}
		
		public static function setServersIP(parameters:Object):void
		{
			var mainIP:Array;
			var resIP:Array;
			
			if(parameters.hasOwnProperty('mainIP')){
				mainIP = JSON.parse(parameters.mainIP) as Array;
				resIP = JSON.parse(parameters.resIP) as Array;
			}	
			
			Log.alert("mainIP: " + mainIP);
			Log.alert("resIP: " + resIP);
			
			switch(App.SERVER) {
				case "DM":
					_mainIP	= mainIP != null ? mainIP : ['western.islandsville.com', 'western.islandsville.com'];
				break;
				case "VK":
					_mainIP	= mainIP != null ? mainIP : ['w-vk3.islandsville.com', 'w-vk3.islandsville.com'];
				break;
				case "OK":
					_mainIP	= mainIP != null ? mainIP : ['w-ok1.islandsville.com', 'w-ok1.islandsville.com'];
				break;
				case "FS":
					_mainIP	= mainIP != null ? mainIP : ['w-fs1.islandsville.com', 'w-fs1.islandsville.com'];
				break;
				case "ML":
					_mainIP	= mainIP != null ? mainIP : ['w-mm1.islandsville.com', 'w-mm1.islandsville.com'];
				break;
				case "FB":
					_mainIP	= mainIP != null ? mainIP : ['w-fb-d1.islandsville.com', 'w-fb-d2.islandsville.com'];
				break;
				case "NK":
					_mainIP	= mainIP != null ? mainIP : ['w-nk1.islandsville.com', 'w-nk1.islandsville.com'];
				break;
				case "HV":
					_mainIP	= mainIP != null ? mainIP : ['w-hv1.islandsville.com', 'w-hv1.islandsville.com'];
				break;
				case "YN":
					_mainIP	= mainIP != null ? mainIP : ['w-yn1.islandsville.com', 'w-yn1.islandsville.com'];
				break;
				case "MX":
					_mainIP	= mainIP != null ? mainIP : ['w-mx1.islandsville.com', 'w-mx1.islandsville.com'];
				break;
				case "YB":
					_mainIP	= mainIP != null ? mainIP : ['w-yb1.islandsville.com', 'w-yb1.islandsville.com'];
				break;
				case "YBD":
					_mainIP	= mainIP != null ? mainIP : ['w-yb.islandsville.com', 'w-yb.islandsville.com'];
				break;
				case "GN":
					_mainIP	= mainIP != null ? mainIP : ['w-gn1.islandsville.com', 'w-gn1.islandsville.com'];
				break;
				case "GND":
					_mainIP	= mainIP != null ? mainIP : ['w-gn.islandsville.com', 'w-gn.islandsville.com'];
				break;
				case "SP":
					_mainIP	= mainIP != null ? mainIP : ['w-sp1.islandsville.com', 'w-sp1.islandsville.com'];
				break;
				case "MX_TEST":
					_mainIP	= mainIP != null ? mainIP : ['w-mx.islandsville.com', 'w-mx.islandsville.com'];
				break;
				case "AI":
					_mainIP	= mainIP != null ? mainIP : ['w-ai1.islandsville.com', 'w-ai1.islandsville.com'];
				break;
				case "AID":
					_mainIP	= mainIP != null ? mainIP : ['w-ai.islandsville.com', 'w-ai.islandsville.com'];
				break;
				default:
					_mainIP	= mainIP != null ? mainIP : ['western.islandsville.com', 'western.islandsville.com'];
			}
			
			//_resIP 	= resIP  != null ? resIP  : ['w-vk3.islandsville.com'];
			_resIP 	= resIP  != null ? resIP  : ['western.islandsville.com', 'western.islandsville.com'];
			
			var resRand:int = int(Math.random() * _resIP.length);
			_resIP = _resIP[resRand];
			
			var rand:int = Math.floor(Math.random() * _mainIP.length);
			
			_curIP = _mainIP[rand];
			_mainIP.splice(_mainIP.indexOf(_curIP));
			
			Log.alert("_mainIP: " + _curIP);
			Log.alert('_resIP: ' + _resIP);
			
			CookieManager._domain = String(_mainIP);
		}
		
		public static function get randomKey():String {
			var pos:int = int(Math.random() * (31 - 13));
			
			return MD5.encrypt(String(getTimer()) + App.user.id).substring(pos, pos + 13);
		}
		
		public static function changeIP():Boolean {
			_curIP = _mainIP.shift();
			if (_curIP) {
				return true;
			}
			return false;
		}
		
		public static function getQuestIcon(type:String, icon:String):String {
			return secure + _resIP + '/resources/icons/quests/' + type + '/' + icon + '.png' + '?v='+version;
		}
		
		public static function getQuestAva(icon:String):String {
			return secure + _resIP + '/resources/icons/avatars/' + icon + '.png' + '?v='+version;
		}
		
		public static function getUrl():String {
			return secure + _curIP + '/';
		}
		
		public static function getData():String {
			return secure + _curIP + '/app/data/json/game.json?v=' + String(new Date().time);
		}
		
		public static function getLocale(lg:String):String
		{
			return secure + _resIP + '/resources/' + 'locales/' + lg + '.csv?v=' + String(new Date().time);
		}
			
		public static function get resources():String {
			return secure + _resIP + '/resources/';
		}	
		
		public static function getIcon(type:String, icon:String):String {
			return secure + _resIP + '/resources/icons/store/' + type + '/' + icon + '.png'+"?v="+version;
		}
		
		public static function getUnversionedImage(type:String, icon:String, _type:String = 'png'):String 
		{
			return secure + _resIP + '/resources/images/' + type + '/' + icon + '.' + _type;
		}
		
		public static function getUnversionedIcon(type:String, icon:String, _type:String = 'png'):String 
		{
			return secure + _resIP + '/resources/icons/store/' + type + '/' + icon + '.' + _type;
		}
		
		public static function getImageIcon(type:String, icon:String, _type:String = 'png'):String {
			return secure + _resIP + '/resources/icons/' + type + '/' + icon + '.'+_type+"?v="+version;
		}
		
		public static function getImage(type:String, icon:String, _type:String = 'png'):String
		{
			return secure + _resIP + '/resources/images/' + type + '/' + icon + '.' + _type +"?v="+version;
		}
		public static function getCross(url:String):String {
			return secure + url+ '?v='+version;
		}
		public static function getSwf(type:String, name:String):String {
			/*if (name == 'magician') {
				return 'D:/__WESTERN/Western/resources/interface/' + 'magician' + '.swf?v='+version;
			}else if (name == 'railway_station') {
				return 'D:/__WESTERN/Western/resources/swf/Building/' + 'railway_station' + '.swf?v='+version;
			}else*/{
				return Config.resources +'swf/' + type + '/' + name + '.swf?v=' + version;
			}
		}
		
		public static function getInterface(type:String):String {
			return Config.resources +'interface/__' + type + '.swf?v=' + versionWindow;// (Math.random() * 999999999);
		}
		
		public static function getDream(type:String):String
		{
			return Config.resources +'lands/' + type + '.swf?v='+version;
		}
		
		public static function setSecure(secureValue:String = "http://"):void {
			secure = secureValue;
		}
		
		public static function get admin():Boolean {
			//return false;
			if (Capabilities.playerType == 'StandAlone')
				return true;
			
			return (['120635122', '120635124', '7584561'].indexOf(App.user.id) >= 0) ? true : false;
		}
	}
}