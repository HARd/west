package buttons 
{
	import flash.text.AntiAliasType;
	
	
	public class PageButton extends Button
	{
		public static const WIDTH:int = 32;
		public static const HEIGHT:int = 32;
		
		public var page:int = 0;
		
		public function PageButton(settings:Object = null) 
		{
			if (settings == null)
				settings = new Object();
			
			settings["width"] 					= settings.width || PageButton.WIDTH;	
			settings["height"] 					= settings.height || PageButton.HEIGHT;	
			settings["radius"] 					= 15;					//Радиус скругления
			settings["fontSize"]				= 18;					//Размер шрифта
			settings["bevelColor"] 				= settings.bevelColor || [0xbaa48f, 0xb9a491];
			settings["bgColor"] 				= settings.bgColor || [0x9dc8db, 0x799fb2];
			settings["borderColor"] 			= settings.borderColor || [0x000000, 0x000000];
			settings["fontColor"]	 			= 0xfffcff;
			settings["fontBorderColor"] 		= settings.fontBorderColor || 0x3e6c69;
			
			settings['active'] = settings.active || {
				bgColor:				[0x588ca2,0x6d9aad],
				borderColor:			[0x000000,0x000000],	//Цвета градиента
				bevelColor:				[0x5a8ca7,0x90bbcb],	
				fontColor:				0xfffcff,				//Цвет шрифта
				fontBorderColor:		0x437166				//Цвет обводки шрифта		
			}
			
			settings["textAlign"]				= "center";	
			settings["caption"]					= settings.caption || "1";
			settings["shadow"]					= true;
			
			super(settings);
		}
	}
}