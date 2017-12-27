package buttons 
{
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.filters.GlowFilter;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import ui.UserInterface;
	
	
	public class MoneySmallButton extends Button
	{
		public var countLabel:TextField;
		
		public var countText:int = 99;
		public var fontCountSize:int = 20;
		public var fontCountColor:uint = 0xDCFA9B;
		public var fontCountBorder:uint = 0x38510D;
		public var coinsIcon:Bitmap;
		
		private var countStyle:TextFormat = new TextFormat(); 
		
		public function MoneySmallButton(settings:Object = null) 
		{
			var defaults:Object = new Object()
			defaults["type"]			= "real";	
			defaults["width"] 			= 120;	
			defaults["height"] 			= 38;	
			defaults["fontBorderSize"] 	= 4;
			defaults["fontBorderGlow"] 	= 2;
			defaults["caption"]			= "";//Locale.__e("");
			defaults["textAlign"]		= "center";	
			defaults["borderGlow"] 		= 0;
			defaults["borderWidth"] 	= 2.5;
			
			defaults["fontSize"]		= 20;
			defaults["sound"]		= 'green_button';
			
			if (settings == null) settings = defaults;
			
			if (settings.type == "coins")
			{
				defaults["borderColor"]		= [0xfbe109,0xd2aa09];	//Цвета градиента
				defaults["bgColor"] 		= [0xfbe109, 0xd2aa09];//[0xA9DC3C, 0x96C52E];	//Начальный цвет градиента
				defaults["fontColor"]	 	= 0x614605;				//Цвет шрифта	
				defaults["fontBorderColor"] = 0xf0e6c1;				//Цвет обводки шрифта	
				defaults["fontCountColor"]	= 0xfedb38;//0x614605;				//Цвет шрифта	
				defaults["fontCountBorder"] = 0x80470b;//0xf0e6c1;				//Цвет обводки шрифта	
			}
			else
			{
				defaults["borderColor"]		= [0xf8f2bd, 0x836a07];	//Цвета градиента
				defaults["bgColor"] 		= [0xA9DC3C, 0x96C52E];	//Начальный цвет градиента
				defaults["fontColor"]	 	= 0x4E6E16;				//Цвет шрифта	
				defaults["fontBorderColor"] = 0xDCFA9B;				//Цвет обводки шрифта	
				defaults["fontCountColor"]	= 0xDCFA9B;				//Цвет шрифта	
				defaults["fontCountBorder"] = 0x38510D;				//Цвет обводки шрифта	
			}
			
			defaults["countText"] 		= 50;	
			defaults["fontCountSize"]	= 28;					//Размер шрифта
			
			for (var property:* in settings) {
				defaults[property] = settings[property];
			}
			settings = defaults
			
			super(settings);
		}
		
		override protected function drawTopLayer():void {
			
			countLabel = new TextField();
			countLabel.mouseEnabled = false;
			countLabel.mouseWheelEnabled = false;
			
			countLabel.antiAliasType = AntiAliasType.ADVANCED;
			countLabel.embedFonts = true;
			countLabel.sharpness = 100;
			countLabel.thickness = 50;

			countLabel.text = settings.countText + "";
			//countLabel.border = true;

			countStyle.color = settings.fontCountColor; 
			countStyle.size = settings.fontSize;
			countStyle.font = settings.fontFamily;
			countStyle.align = TextFormatAlign.RIGHT;
			
			countLabel.setTextFormat(countStyle);
			
			var countFilter:GlowFilter = new GlowFilter(settings.fontCountBorder,1,settings.fontBorderSize,settings.fontBorderSize,10,1);
			countLabel.filters = [countFilter];	
			
			if(settings.type == "coins"){
				coinsIcon = new Bitmap(UserInterface.textures.coinsIcon, "auto", true);
			}else {
				coinsIcon = new Bitmap(UserInterface.textures.fantsIcon, "auto", true);
			}
			
			coinsIcon.scaleX = coinsIcon.scaleY = settings.scale;
			
			if (settings.iconScale)
			{
				coinsIcon.scaleX = settings.iconScale;
				coinsIcon.scaleY = settings.iconScale;
			}
			
			countLabel.height = countLabel.textHeight;
			countLabel.width = countLabel.textWidth + 6;
			
			coinsIcon.y = (settings.height - coinsIcon.height) / 2 + 2;
			countLabel.y = (bottomLayer.height - settings.borderWidth) / 2 - countLabel.textHeight / 2;
			
			var cont:Sprite = new Sprite();
			topLayer.addChild(cont);
			
			coinsIcon.x = 0;
			countLabel.x = coinsIcon.width + 2;
			
			cont.addChild(coinsIcon);
			cont.addChild(countLabel);
			cont.x = (settings.width - cont.width) / 2;
			
			addChild(topLayer);
		}
	}
}