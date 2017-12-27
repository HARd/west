package units 
{
	import core.Load;
	import core.Post;
	import flash.display.Bitmap;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import wins.CollectionWindow;
	
	
	public class Tradesman extends Building
	{
		private var _tribute:Boolean = false;
		private var started:int;
		
		
		public function Tradesman(object:Object) 
		{
			started = object.started;
			
			super(object);
			
			stockable = false;
			//gloweble = true;
			touchable = true;
			clickable = true;
			touchableInGuest = true;
			moveable = true;
			
			flag = false;
			if (App.user.mode == User.GUEST) {
				//App.self.setOffTimer(work);
				flag = false;
				touchable = true;
				clickable = true;
				rotateable = false;
				moveable = false;
			}
			
			if (formed && textures)
				beginAnimation();
			
			tip = function():Object {
				return {
					title:info.title,
					text:info.description
				};
			}	
			
			if (started < App.midnight)
				tribute = true;
		}
		
		override protected function onBuyAction(error:int, data:Object, params:Object):void 
		{
			if (error) {
				Errors.show(error, data);
				return;
			}
			this.id = data.id;
			
			beginAnimation();
			
			tribute = false;
			flag = false;
		}
		
		override public function click():Boolean {
			if (App.user.mode == User.GUEST) {
				guestClick();
				return true;
			}
			if (tribute) {
				storageEvent();
				return true;
			}
			if (!isReadyToWork()) return true;
			
			return true;
		}
		
		public function onBuy(mid:int):void
		{
			Post.send({
				ctr:type,
				act:'item',
				uID:App.user.id,
				id:id,
				wID:App.user.worldID,
				sID:sid,
				mID:mid
			}, onBuyDone);
		}
		
		private function onBuyDone(error:int, data:Object, params:Object):void 
		{
			if (error) {
				Errors.show(error, data);
				return;
			}
		}
		
		override public function isReadyToWork():Boolean
		{
			new CollectionWindow({target:this, mode:CollectionWindow.COLLECTION_SHOP}).show();
			return true;
		}
		
		override public function storageEvent(value:int = 0):void
		{			
			Post.send({
				ctr:this.type,
				act:'storage',
				uID:App.user.id,
				id:this.id,
				wID:App.user.worldID,
				sID:this.sid
			}, onStorageEvent);			
		}
		
		override public function onStorageEvent(error:int, data:Object, params:Object):void {
			if (error)
			{
				Errors.show(error, data);
				if(params && params.hasOwnProperty('guest')){
					App.user.friends.addGuestEnergy(App.owner.id);
				}
				return;
			}
			ordered = false;
			
			if(data.hasOwnProperty('started')){
				started = data.started;
			}else {
				started = App.time;
			}
			
			var bonus:Object = { };
			bonus[data.bonus] = 1;
			
			Treasures.bonus(Treasures.convert(bonus), new Point(this.x, this.y));
			SoundsManager.instance.playSFX('bonus');
			
			if (params != null) {
				if (params['guest'] != undefined) {
					App.user.friends.giveGuestBonus(App.owner.id);
				}
			}
			tribute = false;
			//flag = false;
		}
		
		public function set tribute(value:Boolean):void {
			_tribute = value;
		}
		
		override public function get bmp():Bitmap {
			if (bitmap.bitmapData && bitmap.bitmapData.getPixel(bitmap.mouseX, bitmap.mouseY) != 0)
				return bitmap;
			if (animationBitmap && animationBitmap.bitmapData && animationBitmap.bitmapData.getPixel(animationBitmap.mouseX, animationBitmap.mouseY) != 0)
				return animationBitmap;
				
			return bitmap;
		}
		
		override public function set state(state:uint):void {
			if (_state == state) return;
			
			switch(state) {
				case OCCUPIED: this.filters = [new GlowFilter(0xFF0000,1, 6,6,7)]; break;
				case EMPTY: this.filters = [new GlowFilter(0x00FF00,1, 6,6,7)]; break;
				case TOCHED: this.filters = [new GlowFilter(0xFFFF00,1, 6,6,7)]; break;
				case HIGHLIGHTED: this.filters = [new GlowFilter(0x88ffed,0.6, 6,6,7)]; break;
				case IDENTIFIED: this.filters = [new GlowFilter(0x88ffed,1, 8,8,10)]; break;
				case DEFAULT: this.filters = []; break;
			}
			_state = state;
		}
		
		public function get tribute():Boolean 
		{
			return _tribute;
		}
		
		override public function load():void 
		{
			Load.loading(Config.getSwf(type, info.view), onLoad);
		}
		
		override public function onLoad(data:*):void 
		{
			super.onLoad(data);
			
			textures = data;
			
			var levelData:Object;
			levelData = textures.sprites[0];
			
			if (rotate == true) {
				flip();
			}
			
			draw(levelData.bmp, levelData.dx, levelData.dy);
			
			initAnimation();
			startAnimation();
		}
	}
}