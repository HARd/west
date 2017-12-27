package buttons 
{
	import flash.display.Bitmap;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import silin.filters.ColorAdjust;	
	
	public class MenuButton extends Button
	{
		public var _selected:Boolean = false;
		public var type:* = "";
		public var additionalBitmap:Bitmap
		/**
		 * Конструктор
		 * @param	settings	пользовательские настройки кнопки
		 */
		public function MenuButton(settings:Object = null)
		{
			settings['widthPlus']			= settings.widthPlus || 40;
			settings['width']				= settings.width || String(settings.title).length * 8 + settings.widthPlus//26;
			settings['height']				= settings.height || 42;
			settings['caption']				= settings.title;
			
			settings["bgColor"]				= settings.bgColor || [0xa0c8e1, 0x73a1b1];
			settings["borderColor"]			= settings.borderColor || [0x000000, 0x000000];
			settings["bevelColor"]			= settings.bevelColor ||[0xb9e0f1, 0x528296];	
			settings["fontColor"]			= settings.fontColor || 0xe5f0f2;
			settings["fontBorderColor"]		= settings.fontBorderColor || 0x4b818d;
			
			settings['active'] = settings.active || {
				bgColor:				[0x375e6f, 0x67a7cb],
				borderColor:			[0x000000, 0x000000],	//Цвета градиента
				bevelColor:				[0x30637e, 0x88c4e0],	
				fontColor:				0xfbffff,				//Цвет шрифта
				fontBorderColor:		0x23626b				//Цвет обводки шрифта
			}
			
			this.order = settings.order;
			this.type = settings.type;
			super(settings);
		}
		
		public function set selected(value:Boolean):void {		
			_selected = value;
			if (_selected)
				state = Button.ACTIVE;
			else
				state = Button.NORMAL;
		}
		
		public function glow():void{
			var myGlow:GlowFilter = new GlowFilter();
			myGlow.inner = false;
			myGlow.color = 0xFFFFFF;
			myGlow.blurX = 10;
			myGlow.blurY = 10;
			myGlow.strength = 10;
			myGlow.alpha = 0.5;
			this.filters = [myGlow];
		}
	}
}
