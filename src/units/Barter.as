package units 
{
	import core.Numbers;
	import core.Post;
	import flash.display.Bitmap;
	import flash.events.Event;
	import ui.SystemPanel;
	import wins.BarterWindow;
	import wins.ExchangeWindow;
	import wins.SimpleWindow;
	import wins.TravelRequireWindow;
	
	public class Barter extends Building
	{
		public function Barter(object:Object)
		{	
			super(object);
			if (sid == 3164)
				trace();
				info
			if (sid == 772) {
				removable = false;
				rotateable = false;
				stockable = false;
				moveable = false;
			}
			updateLevel();
		}
		
		override public function openProductionWindow(settings:Object = null):void 
		{
			if (sid == 303) {
				new SimpleWindow( {
					title: Locale.__e('flash:1429514173348'),
					text: Locale.__e('flash:1429514577638'),
					textSize: 24
				}).show();
			} else if (sid == 797) {
				new ExchangeWindow({onExchange:onExchange, target:this, find:helpTarget}).show();
			} else new BarterWindow({onExchange:onExchange, target:this, find:helpTarget}).show();
		}
		
		public function onExchange(bID:int, callback:Function = null):void {
			
			var barter:Object = App.data.barter[bID];
			
			var sID:String = Numbers.getProp(barter.out, 0).key;
			var count:int = barter.out[sID];
			App.user.stock.take(int(sID), count);
			
			if (Numbers.countProps(barter.out) == 2) {
				var sID2:String = Numbers.getProp(barter.out, 1).key;
				var count2:int = barter.out[sID2];
				App.user.stock.take(int(sID2), count2);
			}
			
			Post.send({
				ctr:'barter',
				act:'exchange',
				uID:App.user.id,
				sID:this.sid,
				id:id,
				bID:bID,
				wID:App.map.id
			}, function(error:int, data:Object, params:Object):void {
				if (error) {
					Errors.show(error, data);
					return;
				}	
				
				App.user.stock.addAll(barter.items);
				
				if (callback != null) callback();
			});
		}
		
		override public function onAfterStock():void {
			showIcon();
			hasUpgraded = true;
		}
		
		override public function updateLevel(checkRotate:Boolean = false, mode:int = -1):void 
		{
			super.updateLevel();
			if (!textures) return;
			if (this.level == this.totalLevels && this.sid == 303)
			{
				var levelData:Object = textures.sprites[totalLevels - 1];
				draw(levelData.bmp, levelData.dx, levelData.dy);
			}
			
			if (textures && textures['animation'] && level >= totalLevels) {
				initAnimation();		
				_name = 'anim';
				startAnimation();
				checkAndDrawFirstFrame();
			}
		}
		
		private var _name:String;
		override public function animate(e:Event = null, forceAnimate:Boolean = false):void 
		{
			if (!SystemPanel.animate && !(this is Lantern) && !forceAnimate) return;
			if (_name == null) _name = 'anim';//framesTypes[0];
			var name:String = _name;
			//for each(var name:String in framesTypes) {
				var frame:* 			= multipleAnime[name].frame;
				var cadr:uint 			= textures.animation.animations[name].chain[frame];
				if (multipleAnime[name].cadr != cadr) {
					multipleAnime[name].cadr = cadr;
					var frameObject:Object 	= textures.animation.animations[name].frames[cadr];
					
					multipleAnime[name].bitmap.bitmapData = frameObject.bmd;
					multipleAnime[name].bitmap.smoothing = true;
					multipleAnime[name].bitmap.x = frameObject.ox+ax;
					multipleAnime[name].bitmap.y = frameObject.oy+ay;
				}
				multipleAnime[name].frame++;
				if (multipleAnime[name].frame >= multipleAnime[name].length)
				{
					multipleAnime[name].frame = 0;
					if (framesTypes.length > 1) {
						multipleAnime[_name].bitmap.visible = false;
						_name = 'anim';//setRest();
						multipleAnime[_name].bitmap.visible = true;
					}
				}
			//}
		}
		
		public function setRest():void {			
			var randomID:int = int(Math.random() * framesTypes.length);
			var randomRest:String = framesTypes[randomID];
			multipleAnime[_name].bitmap.visible = false;
			_name = randomRest;
			multipleAnime[_name].bitmap.visible = true;
		}
		
		public function playShoot():void {
			multipleAnime[_name].bitmap.visible = false;
			_name = 'shoot';
			multipleAnime[_name].bitmap.visible = true;
		}
	}
}

