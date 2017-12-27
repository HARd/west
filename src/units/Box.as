package units 
{
	import com.greensock.TweenLite;
	import core.Load;
	import core.Numbers;
	import core.Post;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.utils.setTimeout;
	import ui.Hints;
	import ui.SystemPanel;
	import wins.EventWindow;
	import wins.ShopWindow;
	import wins.Window;
	
	public class Box extends AUnit {
		
		public var callback:Function = null;
	
		public function Box(object:Object)
		{
			layer = Map.LAYER_SORT;
				
			if (object.hasOwnProperty('gift'))
				gift = object.gift;
				
			super(object);
			//layer = Map.LAYER_SORT;
			
			clickable 			= true;
			touchableInGuest 	= false;
			removable = false;
			multiple = true;
			
			Load.loading(Config.getSwf(info.type, info.view), onLoad);
			
			tip = function():Object { 
				return {
					title:info.title,
					text:info.description
				};
			};
			
		}
		
		override public function buyAction():void 
		{
			SoundsManager.instance.playSFX('build');
			//TODO снимаем деньги за покупку
			var money:uint = Stock.COINS;
			var count:int = info.coins;
			if (info.real > 0) {
				money = Stock.FANT;
				count = info.real;
			}
			
			var obj:Object = Storage.price(sid);
			
			if (!App.user.stock.takeAll(obj)) {
				ShopWindow.currentBuyObject.type = null;
				uninstall();
				return;
			}
			
			var postObject:Object = {
				ctr:this.type,
				act:'buy',
				uID:App.user.id,
				wID:App.user.worldID,
				sID:this.sid,
				x:coords.x,
				z:coords.z
			}
			
			if (gift) {
				postObject['gift'] = 1;
			}
			
			if (App.user.stock.take(money, count))
			{
				Hints.buy(this);
				Post.send(postObject, onBuyAction);
				dispatchEvent(new AppEvent(AppEvent.AFTER_BUY));
			}else{
				ShopWindow.currentBuyObject.type = null;
				uninstall();
			}
		}
		
		override protected function onBuyAction(error:int, data:Object, params:Object):void {
			if (error) {
				Errors.show(error, data);
				return;
			}
			//App.ui.upPanel.update(["coins"]);
			
			this.id = data.id;
			
			if (callback != null) {
				callback();
				callback = null;
			}
		}
		
		override public function onLoad(data:*):void {
			textures = data;
			var levelData:Object = textures.sprites[0];
			draw(levelData.bmp, levelData.dx, levelData.dy);
			
			super.onLoad(data);
			
			/*if (textures.sprites.length == 1)
				textures.sprites[1] = textures.sprites[0];*/
		}
		
		override public function click():Boolean 
		{
			if (!super.click()) return false;
			if (!clickable || id == 0) return false;
			App.tips.hide();
			
			if (App.user.mode == User.OWNER)
			{
				var price:Object = { };
				price[Stock.FANTASY] = 1;
				
				if (!App.user.stock.checkAll(price))	return false;
				
				showKeyWindow();
			}
			
			return true;
		}
		
		private function showKeyWindow():void {
			if (info['in'] == '' || info.count == 0){
				onOpen();
				return;
			}
			
			new EventWindow({
				target:this,
				sID:info['in'],
				need:info.count,
				description:Locale.__e('flash:1382952379888'),
				bttnCaption:Locale.__e('flash:1382952379890'),
				onWater:onOpen
			}).show();
		}
		
		private var gift:Boolean = false;
		private function onOpen():void {
			
			if (info['in'] != '') {
				if (!App.user.stock.take(info['in'], info.count)) {
					App.user.onStopEvent();
					showKeyWindow();
					return;	
				}
			}else {
				gift = true;
			}
			
			
			if (gift) {
				ordered = true;
				storageEvent();
			}else {
				if (App.user.quests.tutorial) {
					storageEvent();
				}else if(App.user.addTarget({
					target:this,
					callback:storageEvent,
					event:Personage.HARVEST,
					jobPosition:getContactPosition(),
					onStart:function(_target:* = null):void {
						ordered = false;
					}
				})) {
					ordered = true;
				}else {
					ordered = false;
				}
			}
		}
		
		override public function set ordered(ordered:Boolean):void {
			super.ordered = ordered;
			//alpha = 1;
			/*var levelData:Object;
			if (ordered){
				levelData = textures.sprites[1];
				App.ui.flashGlowing(this);
			}else {
				levelData = textures.sprites[0];
			}
			
			draw(levelData.bmp, levelData.dx, levelData.dy);*/
		}
		
		public function storageEvent():void
		{
			ordered = true;
			
			if (textures.hasOwnProperty('animation')) {
				var levelData:Object;
				levelData = textures.sprites[1];			
				draw(levelData.bmp, levelData.dx, levelData.dy);
				
				initAnimation();
				startAnimation();
				alpha = 1;
			}
			
			if (App.user.mode == User.OWNER) 
			{
				var price:Object = { };
				price[Stock.FANTASY] = 1;
				
				if (!info.hasOwnProperty('treasure') || info.treasure == "") {
					rewardEvent();
					return;
				}
				
				//if (!App.user.stock.takeAll(price))	return;
				//Hints.minus(Stock.FANTASY, 1, new Point(this.x*App.map.scaleX + App.map.x, this.y*App.map.scaleY + App.map.y), true);
				
				var postObject:Object = {
					ctr:this.type,
					act:'storage',
					uID:App.user.id,
					id:this.id,
					wID:App.user.worldID,
					sID:this.sid
				}
				
				Post.send(postObject, onStorageEvent);
			}
		}
		
		public function rewardEvent():void
		{
			var postObject:Object = {
				ctr:this.type,
				act:'reward',
				uID:App.user.id,
				id:this.id,
				wID:App.user.worldID,
				sID:this.sid
			}
			
			Post.send(postObject, onRewardEvent);
		}
		
		public function onRewardEvent(error:int, data:Object, params:Object):void {
			if (error)
			{
				Errors.show(error, data);
				return;
			}
			
			if (data.decor != null) {
				//App.user.stock.add(uint(data.decor), 1)
				flyMaterial(data.decor);
			}
					
			setTimeout(onUninstall, 2000);	
		}
		
		private function flyMaterial(sid:int):void
		{
			var bonus:Object = { };
			bonus[sid] = { };
			bonus[sid][1] = 1;
			Treasures.bonus(bonus, new Point(this.x, this.y));
		}
		
		public function onStorageEvent(error:int, data:Object, params:Object):void {
			if (error)
			{
				Errors.show(error, data);
				return;
			}
			
			if (data.bonus != null)
				Treasures.bonus(data.bonus, new Point(this.x, this.y));
					
			setTimeout(onUninstall, 2000);	
		}
		
		private function onUninstall():void {
			TweenLite.to(this, 1, { alpha:0, onComplete:function():void 
			{
				//removable = true;
				uninstall();
			}});
		}
		
		public function getContactPosition():Object
		{
			var y:int = -1;
			if (this.coords.z + y < 0)
				y = 0;
				
			return {
				x: Math.ceil(info.area.w / 2),
				y: y,
				direction:0,
				flip:0
			}
		}
		
		override protected function onStockAction(error:int, data:Object, params:Object):void {
			super.onStockAction(error, data, params);
			
			if (callback != null) {
				callback();
				callback = null;
			}
		}
		
		override public function animate(e:Event = null, forceAnimate:Boolean = false):void 
		{
			if (!SystemPanel.animate && !(this is Lantern) && !forceAnimate) return;
			
			for each(var name:String in framesTypes) {
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
					stopAnimation();
				}
			}
		}
	}
}