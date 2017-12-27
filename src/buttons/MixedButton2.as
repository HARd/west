package buttons 
{
	import flash.display.Bitmap;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	/**
	 * ...
	 * @author ...
	 */
	public class MixedButton2 extends Button
	{
		public var type:* = "";
		
		public var countText:String = '99';
		public var countLabel:TextField;
		
		public var fontCountSize:int = 20;
		public var fontCountColor:uint = 0xDCFA9B;
		public var fontCountBorder:uint = 0x38510D;
		public var coinsIcon:Bitmap;
		
		private var countStyle:TextFormat = new TextFormat(); 
		
		public var icon2:Bitmap;
		
		public function MixedButton2(icon:Bitmap, settings:Object = null, _icon2:Bitmap = null) 
		{
			coinsIcon = icon;
			icon2 = _icon2;
			
			settings["width"]       = settings.width || 200;
			settings["height"] = settings.height || 44;
			settings['caption'] = settings.title;
			
			settings["bgColor"] = settings.bgColor || [0x8dd529, 0x6e9e2d];//[0xf5cf56, 0xf1b733];	
			settings["borderColor"] = settings.borderColor || [0xffffff, 0xffffff];//[0x9d6249, 0x9d6249];    [0x94F58B, 0x13820B];
			settings["bevelColor"] = settings.bevelColor || [0xc5fe78, 0x405c1a]//[0xfff270, 0xca7d00];	
			settings["fontColor"] = settings.fontColor || 0xffffff;				
			settings["fontBorderColor"] = settings.fontBorderColor || 0x354321;
			
			settings["fontCountColor"]	= settings.fontCountColor || 0xffffff;				//Цвет шрифта	          0xDCFA9B
			settings["fontCountBorder"] = settings.fontCountBorder || 0x354321;				//Цвет обводки шрифта	
			
			settings['iconScale'] = settings.iconScale || 1;
			
			settings["countText"] 		= settings.countText || 0;	
			
			settings["fontSize"]  = settings.fontSize || 22;
			settings["fontCountSize"] = settings.fontCountSize || 23;
			settings["fontBorderCountSize"] = 5;
			settings["fontBorderCountSize"] = 5;
			settings["radius"] = settings.radius || 12;
			settings['isIconFilter'] = settings.isIconFilter || false;
			settings['iconFilter'] = settings.iconFilter || 0x814f31;
			
			settings['hasText2'] = settings.hasText2 || false;
			
			settings['notCheck'] = settings.notCheck || false
			//settings["text2"] 		= settings.text2 || "";	
			//settings["fontCountColor2"]	= 0xffffff;				//Цвет шрифта	          0xDCFA9B
			//settings["fontCountBorder2"] = 0x354321;	
			
			
			this.order = settings.order;
			this.type = settings.type;
			super(settings);
		}
		
		public function set countLabelText(count:String):void {
			countText = count;
			countLabel.text = countText + "";
			countLabel.setTextFormat(countStyle);
			
		//	countLabel.border = true;
		}
		
		public function get countLabelText():String {
			return countText;
		}
		
		public function set count(number:String):void {
			countLabel.text = number;
			countLabel.setTextFormat(countStyle);
			countLabel.width = countLabel.textWidth + 6;
		}
		
		override protected function drawTopLayer():void {
			
			textLabel = new TextField();
			textLabel.mouseEnabled = false;
			textLabel.mouseWheelEnabled = false;
			
			textLabel.multiline = true;
			textLabel.antiAliasType = AntiAliasType.ADVANCED;
			textLabel.embedFonts = true;
			textLabel.sharpness = 100;
			textLabel.thickness = 50;
			//textLabel.autoSize = TextFieldAutoSize.LEFT

			textLabel.text = settings.caption;

			var style:TextFormat = new TextFormat(); 
			style.color = settings.fontColor; 
			style.size = settings.fontSize;
			style.font = settings.fontFamily;
			style.align = TextFormatAlign.CENTER;
			style.leading = settings.textLeading;
			textLabel.setTextFormat(style);
			var filter:GlowFilter = new GlowFilter(settings.fontBorderColor,1,settings.fontBorderSize,settings.fontBorderSize,10,1);
			textLabel.filters = [filter];	
			
			textLabel.x = 10;
			textLabel.width = textLabel.textWidth + 6;
			textLabel.height = textLabel.textHeight + 6;
			
			var deltaWidth:int = settings.setWidth?40:0;
			
			
			if (textLabel.width > (settings.width - deltaWidth)) {
				if(textLabel.text.indexOf(' ') != -1){
					textLabel.wordWrap = true;
				}
				textLabel.width = settings.width - deltaWidth - 10;
				textLabel.height = textLabel.textHeight + 8;
				while (textLabel.textHeight > bottomLayer.height || textLabel.textWidth > settings.width - deltaWidth - 10) {
					settings.fontSize -= 1;
					if (settings.fontSize  < 18) {
						style.leading = -3;
					}
					style.size = settings.fontSize;
					textLabel.setTextFormat(style);
					textLabel.height = textLabel.textHeight+8;
				}
			}
			
			topLayer.addChild(textLabel);
			topLayer.x = 0;
			
			countLabel = new TextField();
			countLabel.mouseEnabled = false;
			countLabel.mouseWheelEnabled = false;
			countLabel.antiAliasType = AntiAliasType.ADVANCED;
			countLabel.embedFonts = true;
			countLabel.sharpness = 100;
			countLabel.thickness = 50;
			countLabel.text = settings.countText + "";

			countStyle.color = settings.fontCountColor; 
			countStyle.size = settings.fontCountSize*App._fontScale;
			countStyle.font = settings.fontFamily;
			countStyle.align = TextFormatAlign.RIGHT;
			
			countLabel.setTextFormat(countStyle);
			
			var countFilter:GlowFilter = new GlowFilter(settings.fontCountBorder,1,settings.fontBorderCountSize,settings.fontBorderCountSize,10,1);
			countLabel.filters = [countFilter];	
			
			textLabel.y = (settings.height - textLabel.textHeight) / 2;
			if (deltaWidth == 0) {
				//textLabel.x = (settings.width - textLabel.textWidth) / 2;
			}
			
			if (settings.iconScale)
			{
				coinsIcon.scaleX = settings.iconScale;
				coinsIcon.scaleY = settings.iconScale;
			}
			
			coinsIcon.x = 20//settings["width"] - coinsIcon.width;
			coinsIcon.y = (bottomLayer.height - coinsIcon.height) / 2 - 2;
			
			if (settings.isIconFilter) {
				var filterIcon:GlowFilter = new GlowFilter(settings.iconFilter, 1, 2, 2, 10, 1);
				var shadowFilter:DropShadowFilter = new DropShadowFilter(1,90,0xab8226,1,2,8,2,1);
				coinsIcon.filters = [filterIcon, shadowFilter];	
			}
			
			countLabel.y = (bottomLayer.height - settings.borderWidth)/2 - countLabel.textHeight/2;
			countLabel.height = countLabel.textHeight;
			countLabel.width = countLabel.textWidth + 6;//coinsIcon.x - countLabel.x;
			
			var minX:int = textLabel.textWidth + textLabel.x + 10;
			countLabel.x = coinsIcon.x - textLabel.textWidth / 2;
			
			
			countLabel.x -= 5;
			countLabel.y += 5;
			textLabel.y -= 6;
			coinsIcon.x -= 29;
			coinsIcon.y += 3;
			
			if (icon2) {
				//topLayer.addChild(icon2);
				icon2.x = settings.width  - 20;
				icon2.y = (bottomLayer.height - coinsIcon.height) / 2 +1;
			}
			
			topLayer.addChild(coinsIcon);
			//topLayer.addChild(textLabel);
			textLabel.x = (settings.width - textLabel.width) / 2;
			if(settings.countText)topLayer.addChild(countLabel);
			
			addChild(topLayer);
			
			if (settings.countText == 0 && !settings.notCheck) {
				coinsIcon.visible = false;
				countLabel.visible = false;
				textLabel.x = (settings.width - textLabel.width) / 2;
			}
		}
	}
}