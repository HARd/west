package ui 
{
	
	import core.Load;
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
    import flash.ui.Mouse;
    import flash.ui.MouseCursorData;
    import flash.geom.Point;
    import flash.display.BitmapData;
	import units.Resource;
	import wins.Window;
	
	/**
	 * ...
	 * @author 
	 */
	public class Cursor 
	{
		private static var _type:String = "default";
		
		private static var cursorBitmapData:BitmapData;
		private static var cursorData:MouseCursorData;
		private static var cursorVector:Vector.<BitmapData> = new Vector.<BitmapData>();
		
		private static var types:Array = [ ];
		private static var icon:Bitmap = new Bitmap();
		private static var iconLabel:TextField;
		
		public static var prevType:String = "default";
		public static var toStock:Boolean = false;
		public static var accelerator:Boolean = false;
		
		public static function init():void
		{
			_type = prevType;
			
			types = [ 
				{type:"default", 		bmd:UserInterface.textures.cursorDefault},
				{type:"mhelper", 		bmd:UserInterface.textures.cursorDefault},
				{type:"default_small", 	bmd:UserInterface.textures.cursorDefaultSmall},
				{type:"reset", 			bmd:UserInterface.textures.cursorDefault},
				{type:"move", 			bmd:UserInterface.textures.cursorMove},
				{type:"remove", 		bmd:UserInterface.textures.cursorRemove},
				{type:"locked", 		bmd:UserInterface.textures.cursorLocked},
				{type:"stock", 			bmd:UserInterface.textures.cursorStock },
				{type:"rotate", 		bmd:UserInterface.textures.cursorRotate},
				{type:"woodCollect", 	bmd:UserInterface.textures.cursorWoodCollect},
				{type:"buildingIn", 	bmd:UserInterface.textures.cursorBuildingIn},
				{type:"stoneCollect", 	bmd:UserInterface.textures.cursorStoneCollect},
				{type:"take", 			bmd:UserInterface.textures.cursorTake},
				{type:"water", 			bmd:UserInterface.textures.cursorWaterDrop },
				{type:"animal_storage", bmd:UserInterface.textures.cursorDefaultSmall },
				{type:"field_storage", bmd:UserInterface.textures.cursorDefaultSmall },
				{type:"animal_reward",	bmd:UserInterface.textures.cursorDefaultSmall },
				{type:"mhelper",	bmd:UserInterface.textures.cursorStock }
				
			];
			
			for (var i:String in types)
			{
				cursorVector[0] = types[i].bmd;
				
				cursorData = new MouseCursorData();
				cursorData.hotSpot = new Point(1, 1);
				cursorData.data = cursorVector;
             
				Mouse.registerCursor(types[i].type, cursorData);
			}
			
			Mouse.cursor = _type;
		}
		
		
		public static function set plant(value:*):void
		{
			if (icon.bitmapData) {
					App.self.setOffEnterFrame(move);
					App.self.contextContainer.removeChild(icon);
					icon.bitmapData = null;
			}
			
			if (value)
			{
				//icon = new Bitmap();
				Load.loading(Config.getIcon("Material", App.data.storage[value].preview),
					
					function(data:Bitmap):void
					{
						icon.bitmapData = data.bitmapData;
						icon.scaleX = icon.scaleY = 0.5;
						icon.smoothing = true;
					}
				);
					
				App.self.contextContainer.addChild(icon);
				App.self.setOnEnterFrame(move);
			}
		}
		
		public static function get plant():* {
			return icon.bitmapData == null ? null : icon;
		}
		public static function get type():String
		{
			return _type
		}
		
		public static function set type(type:String):void
		{
			try {
				if(type == "locked" && _type != "locked")
					prevType = _type;
				else if(prevType == "locked")
					prevType = "default";
				
				if (type != "locked")
					prevType = type;
					
				
				_type = type;
				
				Mouse.cursor = _type;
			}catch (e:Error) {
				
			}
		}
		
		public static function set material(value:*):void
		{
			if (icon.bitmapData) {
				App.self.setOffEnterFrame(move);
				App.self.contextContainer.removeChild(icon);
				icon.bitmapData = null;
				icon.filters = null;
			}
			
			if (value) 	{
				moveMouseMargin = new Point();
				
				Load.loading(Config.getIcon("Material", App.data.storage[value].preview),
					function(data:Bitmap):void {
						icon.bitmapData = data.bitmapData;
						icon.scaleX = icon.scaleY = 0.5;
						icon.smoothing = true;
						
						if (_type == 'animal_storage' || _type == 'animal_reward')
							icon.filters = [new GlowFilter(0xffffff, 1, 4, 4, 24)];
					}
				);
				
				App.self.contextContainer.addChild(icon);
				App.self.setOnEnterFrame(move);
				
				if (iconLabel && App.self.contextContainer.contains(iconLabel))
					App.self.contextContainer.removeChild(iconLabel);
				
				iconLabel = Window.drawText('', {
					fontSize:		20,
					autoSize:		'left',
					color:			0xfefefe,
					borderColor:	0x754122
				});
				App.self.contextContainer.addChild(iconLabel);
			}
		}
		
		public static function get material():* {
			return icon.bitmapData == null ? null : icon;
		}
		
		
		public static var AXE:String = 'axe';
		public static var PICK:String = 'pick';
		public static var GOLDEN_PICK:String = 'goldenPick';
		public static var SHEARS:String = 'secateurs';
		public static var SICKLE:String = 'sickle';
		public static var BACKET:String = 'backet';
		public static var DYNANITE:String = 'dynamite';
		public static var BRUSH:String = 'brush';
		public static var HAMMER:String = 'hammer';
		public static var MINER:String = 'miner';
		public static var LOUPE:String = 'loupe';
		public static var BOCHKA:String = 'bochka';
		
		public static function set image(value:*):void
		{
			if (icon.bitmapData) {
				App.self.setOffEnterFrame(move);
				App.self.contextContainer.removeChild(icon);
				icon.bitmapData = null;
				icon.filters = null;
			}
						
			if (value) {
				if (value == Cursor.AXE || value == Cursor.PICK || value == Cursor.BACKET) {
					moveMouseMargin = new Point(10, 10);
				}else{
					moveMouseMargin = new Point();
				}
				
				icon.bitmapData = UserInterface.textures[value];
				icon.x = App.self.mouseX + moveMouseMargin.x;
				icon.y = App.self.mouseY + moveMouseMargin.y;
				icon.scaleX = icon.scaleY = 1;
				icon.smoothing = true;
				
				App.self.contextContainer.addChild(icon);
				App.self.setOnEnterFrame(move);
			}
		}
		
		public static function get image():* {
			return icon.bitmapData == null ? null : icon;
		}
		
		public static function set text(value:*):void {
			if (value != null && iconLabel)
				iconLabel.text = value.toString();
		}
		
		
		private static var _loading:Boolean = false;
		private static var preloader:Preloader = new Preloader();
		public static function set loading(loading:Boolean):void {
			if (_loading == loading) return;
			
			if (loading) {
				preloader.scaleX = preloader.scaleY = 0.7;
				App.self.contextContainer.addChild(preloader);
				App.self.setOnEnterFrame(moveLoader);
			}else{
				App.self.setOffEnterFrame(moveLoader);
				App.self.contextContainer.removeChild(preloader);
			}
			_loading = loading;
		}
		
		public static function get loading():Boolean {
			return _loading;
		}
		
		private static function moveLoader(e:Event = null):void {
			preloader.x = App.self.mouseX;
			preloader.y = App.self.mouseY;
		}
		
		public static var moveMouseMargin:Point = new Point();
		private static function move(e:Event = null):void
		{
			icon.x = App.self.mouseX + moveMouseMargin.x;
			icon.y = App.self.mouseY + moveMouseMargin.y;
			
			if (iconLabel) {
				iconLabel.x = icon.x + icon.width * 0.5 - iconLabel.width * 0.5;
				iconLabel.y = icon.y + icon.height - iconLabel.height + 6;
			}
		}
		
		public static function deleteText():void
		{
			if (iconLabel && App.self.contextContainer.contains(iconLabel))
				App.self.contextContainer.removeChild(iconLabel);
		}
	}
}
