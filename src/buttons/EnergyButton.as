package buttons 
{
	import flash.display.Bitmap;
	import flash.text.AntiAliasType;
	import flash.text.TextFormat;
	import ui.UserInterface;
	import wins.Window;
	
	
	public class EnergyButton extends Button
	{
				
		public var fontCountSize:int = 20;
		public var fontCountColor:uint = 0xDCFA9B;
		public var fontCountBorder:uint = 0x38510D;
		
		private var countStyle:TextFormat = new TextFormat(); 
		
		public function EnergyButton(settings:Object = null) 
		{
			var defaults:Object = new Object()
			defaults["type"]			= "green";	
			defaults["width"] 			= 120;	
			defaults["height"] 			= 38;	
			defaults["fontBorderSize"] 	= 4;					//Размер обводки шрифта
			defaults["fontBorderGlow"] 	= 2;					//Размер размытия шрифта
			
			defaults["caption"]			= "";//Locale.__e("+5");//Текст кнопки
			defaults["textAlign"]		= "center";	
			defaults["borderGlow"] 		= 0;	//Ширина смазывания бордюра
			defaults["borderWidth"] 	= 2.5;					//Ширина бордюра
			
			defaults["fontSize"]		= 24;					//Размер шрифта
			
			defaults["borderColor"]		= [0xaff1f9, 0x005387];	//Цвета градиента
			defaults["bgColor"] 		= [0x70c6fe, 0x765ad7];	//Начальный цвет градиента
			defaults["fontColor"]	 	= 0x453b5f;				//Цвет шрифта	
			defaults["fontBorderColor"] = 0xe3eff1;				//Цвет обводки шрифта			
			
			for (var property:* in settings) {
				defaults[property] = settings[property];
			}
			settings = defaults
			
			super(settings);
		}
		
		
		override protected function drawTopLayer():void {
			
			textLabel = Window.drawText(settings.caption, {
				color:settings.fontColor,
				borderColor:settings.fontBorderColor,
				fontSize:settings.fontSize,
				textAlign:settings.textAlign,
				width:70
			});
			textLabel.mouseEnabled = false;
			textLabel.mouseWheelEnabled = false;
			
			textLabel.x = 10;
			
			
			textLabel.width = textLabel.textWidth + 6;
			textLabel.height = textLabel.textHeight+6;;
			textLabel.y = (settings.height - textLabel.textHeight) / 2 - 1;
			
			topLayer.addChild(textLabel);
			
			var energy:Bitmap = new Bitmap(UserInterface.textures.energyIcon, "auto", true);
			
			energy.scaleX = 0.7;
			energy.scaleY = 0.7;
			
			energy.x = settings["width"] - energy.width - 3;
			energy.y = (bottomLayer.height - energy.height) / 2;
			
			topLayer.addChild(energy);
			topLayer.addChild(textLabel);
			
			
			addChild(topLayer);
		}
	}

}