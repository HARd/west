package core 
{
	import api.ExternalApi;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.text.TextField;
	import wins.Window;
	/**
	 * ...
	 * @author 
	 */
	public class WallPost 
	{
		public static const OTHER:uint = 0;
		public static const NEW_ZONE:uint = 1;
		public static const GIFT:uint = 2;
		public static const ASK:uint = 3;
		public static const QUEST:uint = 4;
		public static const LEVEL:uint = 5;
		public static const INVITE:uint = 6;
		
		
		public function WallPost() 
		{
			
		}
		
		private static var randomKey:String;
		public static function onPostComplete(result:*):void {
			if (!result || result == 'null') return;
			
			/*if (App.social == "ML" && result.status != "publishSuccess")
				return;
			
			Post.statisticPost(Post.STATISTIC_WALLPOST);
		
			Post.send( {
				ctr:	'oneoff',
				act:	'set',
				uID:	App.user.id,
				id:		randomKey
			}, function(error:int, data:Object, params:Object):void {});*/
		}
		
		public static function makePost(type:int, settings:Object = null):void
		{
			if (App.isSocial('SP')) return;
			Log.alert('MakePost');
			
			if (App.user.quests.tutorial) return;
			
			var message:String = settings['message'] || '';
			var material:Object = (settings.sid) ? App.data.storage[settings.sid] : {};
			var mainBitmapData:BitmapData;
			
			mainBitmapData = getBitmap(type);
			if (!mainBitmapData) {
				if (settings.bitmapData) {
					mainBitmapData = settings.bitmapData;
				}else{
					makeWithLogo(/* BitmapData */);
				}
			}
			
			/*randomKey = Config.randomKey;
			var linkType:String = '?ref=';
			if (App.isSocial('DM','VK','ML')) linkType = '#';*/
			var url:String = Config.appUrl;// + linkType + 'oneoff' + randomKey + 'z';
			
			Log.alert('MakePost 2');
			
			switch(type) {
				
				case OTHER:
					ExternalApi.apiWallPostEvent(WallPost.OTHER, new Bitmap(redrawWhite(mainBitmapData)), App.user.id, message, 0, onPostComplete, {url:url});
					break;
				case NEW_ZONE:
						if (App.isSocial('OK')) {
							message = Locale.__e('flash:1408615269508', [material.title]);
							message = message.replace('%s', '');
						}else {
							message = Locale.__e('flash:1408615269508', [material.title, url]);
						}
						
						ExternalApi.apiWallPostEvent(WallPost.NEW_ZONE, new Bitmap(redrawWhite(mainBitmapData)), App.user.id, message, 0, onPostComplete, {url:url});
					break;
				case ASK:
						if (!App.isSocial('OK','FS')) {
							message = settings.message + " " + url;
						}
						
						if (App.isSocial('FS')) {
							ExternalApi.notifyIngameFriends( {
								message:	message
							});
							return;
						}
						
						if (settings.bitmapData) {
							var sprite:Sprite = new Sprite();
							var logoBitmap:Bitmap = new Bitmap(getBitmap(type));
							sprite.addChild(logoBitmap);
							
							var image:Bitmap = new Bitmap(settings.bitmapData);
							image.x = (sprite.width - image.width) / 2;
							image.y = 115 - image.height/2;
							sprite.addChild(image);
							
							var bmd:BitmapData = new BitmapData(sprite.width, sprite.height, false, 0xffffff);
							bmd.draw(sprite);
							
							ExternalApi.apiWallPostEvent(WallPost.ASK, new Bitmap(bmd), App.user.id, message, settings.sid, onPostComplete, {url:Config.appUrl});
						}
						else 
						{
							ExternalApi.apiWallPostEvent(WallPost.ASK, new Bitmap(mainBitmapData), App.user.id, message, settings.sid, onPostComplete, {url:Config.appUrl});
						}
						
					break;
				case QUEST:
						if (App.isSocial('OK','FS')) {
							message = Locale.__e('flash:1406799219011', [settings.questTitle]);
							message = message.replace('%s', '');
						}else{
							message = Locale.__e('flash:1406799219011', [settings.questTitle, url]);
						}
						
						var questBitmapData:BitmapData = new BitmapData(Math.max(settings.bitmapData.width, mainBitmapData.width), 400, false, 0xffffff);
						questBitmapData.draw(settings.bitmapData, new Matrix(1,0,0,1,questBitmapData.width / 2 - settings.bitmapData.width / 2, 10));
						questBitmapData.draw(mainBitmapData, new Matrix(1,0,0,1,questBitmapData.width / 2 - mainBitmapData.width / 2, 400 - 10 - mainBitmapData.height));
						
						ExternalApi.apiWallPostEvent(WallPost.QUEST, new Bitmap(questBitmapData), App.user.id, message, 0, onPostComplete, {url:url});
					break;
				case LEVEL:
						if (App.isSocial('OK','FS')) {
							message = Locale.__e('flash:1406799202850', [App.user.level]);
							message = message.replace('%s', '');
						}else{
							message = Locale.__e('flash:1406799202850', [App.user.level, url]);
						}
						
						var callback:Function = null;
						if (settings.callback != null)
							callback = settings.callback;
						
						var levelBitmapData:BitmapData = redrawWhite(mainBitmapData);
						var levelTF:TextField = Window.drawText(App.user.level.toString(), {
							color:			0xfff29a,
							borderColor:	0x9e5413,
							borderSize:		8,
							fontSize:		86,
							autoSize:		'left',
							shadowSize:		2
						});
						levelBitmapData.draw(levelTF, new Matrix(1, 0, 0, 1, (mainBitmapData.width - levelTF.width) / 2, 40));
						
						ExternalApi.apiWallPostEvent(WallPost.LEVEL, new Bitmap(levelBitmapData), App.user.id, message, 0, callback, {url:url});
					break;
				case INVITE:
					ExternalApi.apiWallPostEvent(WallPost.INVITE, new Bitmap(redrawWhite(mainBitmapData)), App.user.id, message, 0, callback, {url:url});
					break;
			}
			
			function redrawWhite(bmd:BitmapData):BitmapData {
				var _bmd:BitmapData = new BitmapData(bmd.width, bmd.height, false, 0xffffff);
				_bmd.draw(bmd);
				return _bmd;
			}
		}
		
		
		
		private static function makeWithLogo(bitmapData:BitmapData = null):BitmapData {
			var sprite:Sprite = new Sprite();
			var logoBitmap:Bitmap = new Bitmap(Window.texture('goldenLogo'));
			if (bitmapData && bitmapData.width * 2 < logoBitmap.width) {
				logoBitmap.width = bitmapData.width * 2;
				logoBitmap.scaleY = logoBitmap.scaleX;
				logoBitmap.smoothing = true;
			}
			
			sprite.addChild(logoBitmap);
			var bitmap:Bitmap = new Bitmap(bitmapData);
			bitmap.x = (sprite.width - bitmap.width) / 2;
			bitmap.y = sprite.height + 16;
			sprite.addChild(bitmap);
			
			var bmd:BitmapData = new BitmapData(sprite.width, sprite.height, true, 0);
			bmd.draw(sprite);
			
			return bmd;
		}
		
		private static function getBitmap(type:int):BitmapData {
			switch(type) {
				case NEW_ZONE:	return Window.texture('postTerritory');
				case ASK:		return Window.texture('postSearch');
				case QUEST:		return Window.texture('goldenLogo');
				case LEVEL:		return Window.texture('postLevel');
			}
			
			return null;
		}
		
	}

}