package units
{
	import com.greensock.TweenLite;
	import core.Post;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import ui.Cloud;
	import wins.GambleWindow;
	import wins.ThimbleWindow;
	
	public class Thimbles extends Golden
	{
		public var played:uint = 0;
		public var playAllow:Boolean;
		
		public function Thimbles(object:Object)
		{
			played = object.played || 0;
			super(object);
			stockable = false;
			
			if(formed){
				if (played < App.midnight) {// Значит играли вчера
					tribute = true;
				}else{
					tribute = false;
					App.self.setOnTimer(work);
				}
			}
			
			tip = function():Object {
				if (tribute)
				{
					return {
						title:info.title,
						text:Locale.__e("flash:1382952379911")
					};
				}else{
					return {
						title:info.title,
						text:Locale.__e("flash:1382952379912", [TimeConverter.timeToStr(App.nextMidnight - App.time)]),
						timer:true
					};
				}
			}
		}
		
		
		
		public override function init():void {
			
			
		}
		
		override public function work():void
		{
			if (App.time > App.nextMidnight)
			{
				App.self.setOffTimer(work);
				tribute = true;
			}
		}
		
		public function set tribute(value:Boolean):void {
			if (value)
			{
				playAllow = value;
			}
			else
			{
				playAllow = false;
			}
			showIcon();
		}
		
		override public function get tribute():Boolean {
			return playAllow;
		}
		
		override public function onAfterBuy(e:AppEvent):void
		{
			super.onAfterBuy(e);
			tribute = true;
		}
		
		override public function onLoad(data:*):void {
			if (data.hasOwnProperty('animation'))
			{
				for (var type:* in data.animation.animations)
				{
					if (data.animation.animations[type].hasOwnProperty('pause')) 
					{
						var length:int = int(data.animation.animations[type].pause * Math.random());
						var chain:Array = data.animation.animations[type].chain;
						//var lastFrame:int = chain.pop();
						for (var i:int = 0; i < length; i++) 
						{
							chain.push(0);
						}
					}
				}
			}
			super.onLoad(data);
		}
		
		override public function click():Boolean {
			if (!clickable || (App.user.mode == User.GUEST && touchableInGuest == false)) return false;
			
			App.tips.hide();
				
			if (App.user.mode == User.OWNER) {
				
				new ThimbleWindow( {
					target:this,
					onPlay:playEvent
				}).show();
			}
			
			return true;
		}
		
		private var paid:uint = 0;
		private var onPlayed:Function;
		public function playEvent(paid:int, onPlayed:Function):void {
			
			this.onPlayed = onPlayed;
			this.paid = paid;
			
			if (paid == 1) {
				App.user.stock.take(Stock.FANT, info.skip);
			}
		}
		
		public var treasure:Object;
		override public function storageEvent(value:int = 0):void
		{
			if (App.user.mode == User.OWNER) {
				
				Post.send({
					ctr:this.type,
					act:'storage',
					uID:App.user.id,
					id:this.id,
					wID:App.user.worldID,
					sID:this.sid,
					paid:paid,
					tID:treasure.tID,
					iID:treasure.iID
				}, onStorageEvent);
				
				tribute = false;
			}
		}
		
		public override function onStorageEvent(error:int, data:Object, params:Object):void {
			
			if (error)
			{
				Errors.show(error, data);
				return;
			}
			ordered = false;
			
			if(data.hasOwnProperty('played')){
				this.played = data.played;
			}
			
			if (onPlayed != null) onPlayed(data.bonus);
			App.user.stock.addAll(data.bonus);
		}
		
		private var usedStage:int = 0;
		override public function updateLevel(checkRotate:Boolean = false, mode:int = -1):void 
		{
			if (textures == null) return;
			
			var levelData:Object;
			if (this.level && info.thimbles && info.thimbles.req.hasOwnProperty(this.level) && info.thimbles.req[this.level].hasOwnProperty("s") && textures.sprites[info.thimbles.req[this.level].s]) {
				usedStage = info.thimbles.req[this.level].s;
			}else if (textures.sprites[this.level]) {
				usedStage = this.level;
			}
			
			levelData = textures.sprites[usedStage];
			
			if (checkRotate && rotate == true) {
				flip();
			}
			
			if (this.level != 0 && gloweble)
			{
				var backBitmap:Bitmap = new Bitmap(bitmap.bitmapData);
				backBitmap.x = bitmap.x;
				backBitmap.y = bitmap.y;
				addChildAt(backBitmap, 0);
				
				bitmap.alpha = 0;
				
				App.ui.flashGlowing(this, 0xFFF000);
				
				TweenLite.to(bitmap, 0.4, { alpha:1, onComplete:function():void {
					removeChild(backBitmap);
					backBitmap = null;
				}});
				
				gloweble = false;
			}
			
			draw(levelData.bmp, levelData.dx, levelData.dy);
			
			checkOnAnimationInit();
		}
		
	}
}