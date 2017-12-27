//////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 2007 RIAFactory. http://www.riafactory.ru
//  Author(s): Alexey "Vooparker" Anickutin
//  Version: 1.0
//
//////////////////////////////////////////////////////////////////////

package core 
{
	import flash.external.ExternalInterface;
	
	
	/**
	 *	CookieManager provides methods for manage cookies
	 *	with Javascript through ExternalInterface.
	 */
	public class CookieManager 
	{
		// -------------------------------------------------------------------------------------------------------
		// Getters & Setters
		// -------------------------------------------------------------------------------------------------------
		
		public static var _domain:String;
		
		/**
		 *	Indicates if cookies enabled
		 */
		public static function get cookiesEnabled ():Boolean
		{
			if(ExternalInterface.available)
				return ExternalInterface.call("function(){return navigator.cookieEnabled;}") as Boolean;
			return false;
		}
		
		/**
		 *	Cookies object contains all available and not null cookies
		 *	
		 *	@throws	Error	An error is thrown if cookies is disabled in browser
		 */
		public static function get cookies ():Object
		{
			if(!cookiesEnabled)
				throw new Error("Cookies is disabled. Check if ExternalInterface is available and cookies is enabled.");
			var cookies:Object = {};
			var cookiesString:String = (ExternalInterface.call("function(){return document.cookie;}") as String) + ";";
			var cookiePattern:RegExp = /\s?(?P<name>.*?)=(?P<value>.*?);/g;
			var matches:Object;
			while((matches = cookiePattern.exec(cookiesString)) != null)
				if(unescape((matches.value as String)) != "null")
					cookies[(matches.name as String)] = unescape((matches.value as String));
			return cookies;
		}

		// -------------------------------------------------------------------------------------------------------
		// Constructor
		// -------------------------------------------------------------------------------------------------------
		
		/**
		 *	Constructor. 
		 *	You can't create instance of CookiesManager. 
		 *	All its methods and properties are static.
		 */
		public function CookieManager() 
		{
			throw new Error ("You can't create instance of CookiesManager. All its methods and properties are static");
		}
		
		// -------------------------------------------------------------------------------------------------------
		// Public methods
		// -------------------------------------------------------------------------------------------------------
		
		/**
		 *	Store cookie
		 *	
		 *	@param	name		Cookie name
		 *	@param	value		Cookie value
		 *	@param	expires		Expiry date after which cookie will be trashed
		 *	@param	path		The path specifys a directory where the cookie is active
		 *	@param	domain		The domain tells the browser to which domain the cookie should be sent
		 *	@param	secure		The secure cookie indicates if cookie will accessed only via HTTPS
		 *	
		 *	@throws	Error 		An error is thrown if cookies is disabled in browser
		 */
		public static function store (name:String, value:String, expires:Date = null, 
									  path:String = null, domain:String = null, secure:Boolean = false):void
		{
			var date:Date = new Date(2015, 1, 1)
			var _expires:String = date.toUTCString();
			//Post.addToArchive('expires: ' + _expires);
			if(!cookiesEnabled)
				throw new Error("Cookies is disabled. Check if Exte	nalInterface is available and cookies is enabled.");
				
			var cookieString:String = name + "=" + escape(value);
			cookieString += "; expires=" + _expires;
			if(path != null) 	cookieString += "; path=" + path;
			if(domain != null) 	cookieString += "; domain=" + domain;
			if(secure) 			cookieString += "; secure";
			ExternalInterface.call("function(){document.cookie=\"" + cookieString + "\"}");
		}

		/**
		 *	Read value of cookie by its name
		 *	
		 *	@param	name		Cookie name
		 *	
		 *	@return		Cookie value or null if there is no cookie with specified name
		 */
		public static function read (name:String):String
		{
			if(cookies[name] == undefined)
				return null;
			return cookies[name] as String;
		}
		
		/**
		 *	Remove cookie by setting null value and expiry date to 01 Jan 1970
		 *	
		 *	@param	name		Cookie name
		 *	@param	path		The path specifys a directory where the cookie is active
		 *	@param	domain		The domain tells the browser to which domain the cookie should be sent
		 *	@param	secure		The secure cookie indicates if cookie will accessed only via HTTPS
		 */
		public static function remove (name:String, path:String = null, 
									   domain:String = null, secure:Boolean = false):void
		{
			store(name, "null", new Date(0), path, domain, secure);
		}
	}
}
