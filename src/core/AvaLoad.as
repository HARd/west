package core 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.geom.Matrix;
	import flash.net.URLRequest;
	
	public class AvaLoad 
	{
		
		private var _loader:Loader = null;
		private var _loaderContent:DisplayObject = null;
		private var callback:Function;
		private var errCall:Function;
		private var url:String;
		
		public function AvaLoad(url:String, callback:Function, errCall:Function = null) 
		{
			//trace('--------------  ' + url);
			if (url == null)
				return;
			
			//var pattern:RegExp = /http:/
			//url = url.replace(pattern, 'https:');
			
			if (errCall != null)
				this.errCall = errCall;
			var data:* = Load.getCache(url);
			if (data != null) {
				callback(data);
			}else{
				this.url = url;
				this.callback = callback;
				try{
					_loadContent(url);
				}
				catch (err:Error) {
					if (errCall != null)
						errCall();
					}
			}
		}
		
		
		private function _loadContent(url:String):void
		{
			//trace("_loadContent() -> url: " + url);
 
			_loader = new Loader();
			_loader.addEventListener(IOErrorEvent.IO_ERROR, onError);
			_loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onError);
			_loader.addEventListener(Event.ADDED, _onAddedToLoader, true, int.MAX_VALUE);
			_loader.addEventListener(Event.ADDED, _onAddedToLoader, false, int.MAX_VALUE);
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, _onPicLoaded);
			_loader.load(new URLRequest(url));
		}
 
		private function _onAddedToLoader( e:Event ) : void
		{
			//trace("_onAddedToLoader() -> e: " + e);
			//trace("_onAddedToLoader() -> e.target: " + e.target);
 
			if (e.target)
			{
				_loaderContent = e.target as DisplayObject;
			}
		}
		
		private function onError(e:IOErrorEvent):void {
			if(errCall!=null)
			errCall();
			trace(e.text);
		}
 
		private function _onPicLoaded( e:Event ) : void
		{
			//trace("_onPicLoaded() -> e: " + e);
			//trace("_onPicLoaded() -> (_loaderContent as Bitmap): " + (_loaderContent as Bitmap));
 
			var bd:BitmapData = (_loaderContent as Bitmap).bitmapData;
 
			//trace("_onPicLoaded() -> bd: " + bd);
 
			var bdCopy:BitmapData = new BitmapData(bd.width, bd.height, true, 0x0);
			bdCopy.draw(bd);
			
			var scaleX:Number = 50 / bd.width;
			var scaleY:Number = 50 / bd.height;
			if(scaleX < 1){
				var matrix:Matrix = new Matrix();
				matrix.scale(scaleX, scaleY);
				var smallBMD:BitmapData = new BitmapData(50, 50, true, 0x000000);
				smallBMD.draw(bdCopy, matrix, null, null, null, true);
				bdCopy = smallBMD;
			}
			
			bd = null;
			var bmp:Bitmap = new Bitmap(bdCopy);
			
			//Load.addCache(url, bmp);
			
			callback(bmp);
			
			//trace("get original loader content: ");
			try {
				_loaderContent = _loader.content;
				//trace("no exception");
			} catch (exception:Error) {
				trace("exception: " + exception);
			}
			
		}
		
	}

}