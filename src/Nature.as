package 
{
	import api.ExternalApi;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import ui.UserInterface;
	import units.Butterfly;
	import units.Pet;
	import units.Whispa;
	import wins.NatureWindow;
	
	/**
	 * ...
	 * @author 
	 */
	public class Nature 
	{
		
		public static const HALLOWEEN:String = 'halloween';
		public static const DEFAULT:String = 'default';
		
		public static var mode:String = DEFAULT;
		
		
		public static var _settings:Object = {
			'default': {
				bgColor:0x6b97b9//0x8de8b6
			},
			'halloween': {
				bgColor:0x768992
			}
		}
		
		public function Nature() {
			
		}
		
		private static function isDevelsComplete(type:String):Boolean {
			var result:Boolean = false;
			
			switch(type) {
				case HALLOWEEN: {
					if ((App.user.head == 742 && App.user.body == 741) ||
						(App.user.head == 740 && App.user.body == 739))
						result = true;
				}
			}
			
			return result;
		}
		
		public static function setMode(mapData:* = null):void {
			//return;
			var newMode:String = DEFAULT;
			// Если природа есть в карте
			if (mapData != null && mapData.hasOwnProperty('nature')) {
				newMode = mapData.nature;
			}
			else
			{// Проверяем какую включать
				if (App.map.id == User.HOME_WORLD)
				{
					if (isDevelsComplete(HALLOWEEN)) 
						newMode = HALLOWEEN;
				}
			}
			
			mode = newMode;
		}
		
		public static function tryChangeMode():void {
		//	return;
			var newMode:String;
			if (mode == DEFAULT) {
				if (isDevelsComplete(HALLOWEEN))
				{ 
					new NatureWindow( {
						title:Locale.__e('flash:1383040644311'),
						text:Locale.__e(''),
						onOk:function():void {
							ExternalApi.reset();
						},
						onClose:function():void{
							ExternalApi.reset();
						}
					}).show();
				}			
			}
			else if(mode == HALLOWEEN)
			{
				if (!isDevelsComplete(HALLOWEEN)) {
					new NatureWindow( {
						title:Locale.__e('flash:1383040745717'),
						text:Locale.__e(''),
						onOk:function():void {
							ExternalApi.reset();
						},
						onClose:function():void{
							ExternalApi.reset();
						}
					}).show();
				}
			}
		}
		
		public static function get settings():Object {
			return _settings[mode];
		}
		
		public static function getColorize(type:String):Object {
			
			var settings:Object = {
				color	:0x79498f,
				amount	:0.55
			}
			
			switch(type) {
				case 'tile':
					settings.amount = 0.5;
					break
			}
			
			return settings;
		}
		
		public static function colorize(bitmapData:BitmapData, type:String = 'image'):BitmapData
		{
			if (mode == DEFAULT) 
				return bitmapData;
			
			var _cont:Sprite = new Sprite();
			var _bitmap:Bitmap = new Bitmap(bitmapData);
			
			_cont.addChild(_bitmap);
			
			var settings:Object = getColorize(type);
			UserInterface.colorize(_bitmap, settings.color, settings.amount);
			
			var _bmd:BitmapData = new BitmapData(_cont.width, _cont.height, true, 0);
			_bmd.draw(_cont);
			_cont = null;
			_bitmap = null;
			
			return _bmd;
		}
		
		public static function change(target:*):void 
		{
			if (Nature.mode == Nature.HALLOWEEN){
				if (target is Whispa) {
					UserInterface.colorize(target, 0xFF0000, 0.8);
				}
			}
		}
		
		public static function init():void
		{
			return;
			Pet.addPets(Pet.MOLE, 2);
			Pet.addPets(Pet.BUNNY, 3);
			for (var i:int = 0; i < 6; i++) {
				addButterfly();
			}
		}
		
		private static var butterflies:Array = [];
		public static function addButterfly():void {
			butterflies.push(new Butterfly( {} ));
		}
		
		public static function removeButterfly():void {
			var fly:Butterfly = butterflies.pop();
			if(fly){
				fly.dispose();
				fly = null;
			}
			
			butterflies = [];
		}
		
		public static function dispose():void {
			removeButterfly();
		}

	}
}