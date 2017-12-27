package units 
{
	import core.Load;
	import core.Post;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.BlendMode;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filters.BlurFilter;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.text.TextField;
	import ui.Hints;
	import wins.SimpleWindow;
	import wins.Window;
	
	public class Chest extends Unit
	{
		public var timer:TextField
		public var _time:int = 0;
		public function Chest(object:Object)
		{
			layer = Map.LAYER_SORT;
			created = object.created || App.time;
			super(object);
			_time = object.time || info.time;
			layer = Map.LAYER_SORT;
			
			clickable 			= true;
			touchableInGuest 	= false;
			removable 			= false;
			
			Load.loading(Config.getSwf(info.type, info.view), onLoad);
			
			tip = function():Object { 
				return {
					title:info.title,
					text:info.description
				};
			};
		}
		
		private function onLoad(data:*):void {
			textures = data;
			var levelData:Object = textures.sprites[0];			
			draw(levelData.bmp, levelData.dx, levelData.dy);
			
			addTimer();
		}
		
		private var glow:Sprite;
		private var _glow1:Sprite;
		private var _glow2:Sprite;
		private function addGlow():void 
		{
			glow = new Sprite();
			addChild(glow);
			_glow1 = new Sprite();
			_glow2 = new Sprite();
			var bitmap1:Bitmap = new Bitmap(textures.sprites[2].bmp);
			var bitmap2:Bitmap = new Bitmap(textures.sprites[2].bmp);
			_glow1.addChild(bitmap1);
			bitmap1.smoothing = true;
			bitmap2.smoothing = true;
			_glow2.addChild(bitmap2);
			bitmap1.x = bitmap2.x = -bitmap1.width / 2;
			bitmap1.y = bitmap2.y = -bitmap1.height / 2;
			App.self.setOnEnterFrame(onFrame);
			
			glow.addChild(_glow1);
			glow.addChild(_glow2);
			glow.scaleX = glow.scaleY = 0.5;
			
			glow.x = - 10;
			glow.y = -12;
			glow.alpha = 0.9
			glow.blendMode = BlendMode.MULTIPLY;
			//glow.filters = [new BlurFilter(7,7)];
			this.filters = [new GlowFilter(0xFFFF00, 1, 2, 2, 1, 3)];
			
			addEventListener(Event.REMOVED_FROM_STAGE, onRemoveFromStage);
		}
		
		private function hideGlow():void {
			removeChild(glow);
			App.self.setOffEnterFrame(onFrame);
			
			var levelData:Object = textures.sprites[0];			
			draw(levelData.bmp, levelData.dx, levelData.dy);
			
			addTimer();
		}
		
		private function onFrame(e:Event = null):void {
			_glow1.rotation += 3;
			_glow2.rotation -= 3;
		}
		
		private var cont:Sprite;
		private function addTimer():void 
		{
			cont = new Sprite();
			timer = Window.drawText('', {
				color:0xf8d74c,
				textAlign:"center",
				fontSize:24,
				borderColor:0x502f06
			});
			timer.width = 90;
			
			addChild(cont);
			cont.addChild(timer);
			
			timer.x = bitmap.x + (bitmap.width - timer.width) / 2 + 15 - 15;
			timer.y = bitmap.y + 35 + 18 - 45;
			App.self.setOnTimer(update);
		}
		
		private function update():void 
		{
			var time:int = (created + _time) - App.time;
			timer.text = TimeConverter.timeToStr(time);
			if (time <= 0) {
				removeChild(cont);
				//startGlowing();
				addGlow();
				var levelData:Object = textures.sprites[1];			
				draw(levelData.bmp, levelData.dx, levelData.dy);
				App.self.setOffTimer(update);
			}
		}
		
		
		public function onRemoveFromStage(e:Event):void {
			removeEventListener(Event.REMOVED_FROM_STAGE, onRemoveFromStage);
			App.self.setOffEnterFrame(onFrame);
		}
		
		override public function click():Boolean 
		{
			if (!super.click() || this.id == 0) return false;
			hideGlowing();
			
			if (created + _time > App.time) {
				new SimpleWindow({
					label:SimpleWindow.TREASURE,
					title:info.title,
					timer:(created + _time) - App.time,
					text:Locale.__e('flash:1384255810488')
				}).show();
				return true
			}
			
			App.user.hero.addTarget( {
				target:this,
				callback:storageEvent,
				event:Personage.HARVEST,
				jobPosition: getPosition()
			});
			
			return true;
		}
		
		public function storageEvent():void
		{
			var price:Object = { }
			price[Stock.FANTASY] = 1;
				
			if (!App.user.stock.takeAll(price))	return;
			Hints.minus(Stock.FANTASY, 1, new Point(this.x * App.map.scaleX + App.map.x, this.y * App.map.scaleY + App.map.y), true);
					
			Post.send({
				ctr:this.type,
				act:'storage',
				uID:App.user.id,
				id:this.id,
				wID:App.user.worldID,
				sID:this.sid
			}, onStorageEvent);
		}
		
		public function onStorageEvent(error:int, data:Object, params:Object):void {
			
			if (error)
			{
				Errors.show(error, data);
				return;
			}
			hideGlow();
			
			created = App.time;
			ordered = false;
			
			if(data.hasOwnProperty('bonus'))
				Treasures.bonus(data.bonus, new Point(this.x, this.y));	
			
			if (!data.hasOwnProperty('time')){
				uninstall();
			}
			else
			{
				_time = data.time;
			}	
			
		}
		
		private function getPosition():Object
		{
			var Y:int = -1;
			if (coords.z + Y <= 0)
				Y = 0;
			
			return { x:1, y: Y };
		}
	}
}