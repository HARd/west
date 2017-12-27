package buttons 
{
	import core.Load;
	import flash.display.Bitmap;
	import flash.filters.GlowFilter;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import ui.UserInterface;
	
	
	public class MoneyButton extends Button
	{
		public var type:* = "";
		public var countLabel:TextField;
		
		public var countText:int = 99;
		public var fontCountSize:int = 20;
		public var fontCountColor:uint = 0xDCFA9B;
		public var fontCountBorder:uint = 0x527b01;
		public var coinsIcon:Bitmap;
		
		private var countStyle:TextFormat = new TextFormat(); 
		
		public function MoneyButton(settings:Object = null) 
		{
			settings["width"]			= settings.width || 200;
			settings["height"]			= settings.height || 44;
			settings['caption']			= settings.caption || Locale.__e('flash:1382952379751');
			
			settings["bgColor"] 		= settings.bgColor || [0xa6f949, 0x74bb15];
			settings["borderColor"] 	= settings.borderColor || [0x000000, 0x000000];
			settings["bevelColor"] 		= settings.bevelColor || [0xbfeea8, 0x48882a];
			settings["fontColor"]		= settings.fontColor || 0xffffff;				
			settings["fontBorderColor"]	= settings.fontBorderColor || 0x527b01;
			
			settings["fontCountColor"]	= settings.fontCountColor || 0xfffdff;
			settings["fontCountBorder"] = settings.fontCountBorder || 0x527b01;
			
			settings['iconScale']		= settings.iconScale || 0.65;
			settings["countText"] 		= settings.countText || 50;
			
			settings["fontSize"]  = settings.fontSize || 22;
			settings["fontCountSize"] = settings.fontCountSize || 23;
			settings["fontBorderCountSize"] = 5;
			settings["radius"] = settings.radius || 16;
			
			this.order = settings.order;
			this.type = settings.type;
			this.countText = settings.countText;
			
			super(settings);
		}
		
		public function set countLabelText(count:int):void {
			countText = count;
			countLabel.text = String(countText);
			countLabel.setTextFormat(countStyle);
			
			resize();
		}
		
		public function set count(count:*):void {
			countLabel.text = String(count);
			countLabel.setTextFormat(countStyle);
			
			resize();
		}
		
		public function get countLabelText():int {
			return countText;
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
			//textLabel.border = true;
			
			textLabel.text = settings.caption;
			
			var style:TextFormat = new TextFormat(); 
			
			if (App.isSocial('NK') && App.lang == 'pl' && textLabel.text.search(/[^\s0-9a-zA-Z€aąbcćdeęfghijкklłmnńoóprsśtuwyxzźżAĄBCĆDEĘFGHIJКKLŁMNOÓPRSŚTUWYXZŹŻ\…\.,_\/\-\|\{\}\[\]\+\)\(\*\&\?\>\<\:\;\%\$\#\@\!\"\']/) != -1) {
				settings.fontFamily = App.reserveFont.fontName;
				settings.fontSize *= 0.75;
			}else if (App.lang == 'jp') {
				settings.fontSize *= 0.75;
			}
			
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
			
			if (deltaWidth == 0) {
				textLabel.x = (settings.width - textLabel.textWidth) / 2;
			}
			
			countLabel = new TextField();
			countLabel.mouseEnabled = false;
			countLabel.mouseWheelEnabled = false;
			countLabel.autoSize = TextFieldAutoSize.LEFT;
			
			countLabel.antiAliasType = AntiAliasType.ADVANCED;
			countLabel.embedFonts = true;
			countLabel.sharpness = 100;
			countLabel.thickness = 50;
			countLabel.text = countText.toString();
			
			countStyle.color = settings.fontCountColor; 
			countStyle.size = settings.fontCountSize*App._fontScale;
			countStyle.font = settings.fontFamily;
			countStyle.align = TextFormatAlign.RIGHT;
			
			countLabel.setTextFormat(countStyle);
			
			var countFilter:GlowFilter = new GlowFilter(settings.fontCountBorder,1,settings.fontBorderCountSize,settings.fontBorderCountSize,10,1);
			countLabel.filters = [countFilter];	
			
			
			if(settings.type == "gold"){
				coinsIcon = new Bitmap(UserInterface.textures.coinsIcon, "auto", true);
			}if (settings.type == "actions") {
				Load.loading(Config.getIcon(App.data.storage[Stock.ACTION].type , App.data.storage[Stock.ACTION].preview), onCurrencyLoad);
				return;
			}else {
				coinsIcon = new Bitmap(UserInterface.textures.fantsIcon, "auto", true);
			}
			
			if (settings.iconScale)
			{
				coinsIcon.scaleX = settings.iconScale;
				coinsIcon.scaleY = settings.iconScale;
			}
			
			textLabel.y = (bottomLayer.height - textLabel.height)/2 - 3;
			
			coinsIcon.y = (bottomLayer.height - coinsIcon.height) / 2;
			
			countLabel.y = (bottomLayer.height - countLabel.textHeight)/2;
			countLabel.height = countLabel.textHeight;
			countLabel.width = countLabel.textWidth + 6;
			
			var minX:int = textLabel.textWidth + textLabel.x + 10;
			
			textLabel.x = 0;
			coinsIcon.x = textLabel.x + textLabel.width + 4;
			countLabel.x = coinsIcon.x + coinsIcon.width + 4;
			
			topLayer.addChild(coinsIcon);
			topLayer.addChild(textLabel);
			topLayer.addChild(countLabel);
			
			addChild(topLayer);
			
			resize();
		}
		
		private function onCurrencyLoad(data:Bitmap):void {
			coinsIcon = new Bitmap(data.bitmapData);
			
			if (settings.iconScale)
			{
				coinsIcon.scaleX = settings.iconScale;
				coinsIcon.scaleY = settings.iconScale;
			}
			
			textLabel.y = (bottomLayer.height - textLabel.height)/2 - 3;
			
			coinsIcon.y = (bottomLayer.height - coinsIcon.height) / 2;
			
			countLabel.y = (bottomLayer.height - countLabel.textHeight)/2;
			countLabel.height = countLabel.textHeight;
			countLabel.width = countLabel.textWidth + 6;
			
			var minX:int = textLabel.textWidth + textLabel.x + 10;
			
			textLabel.x = 0;
			coinsIcon.x = textLabel.x + textLabel.width + 4;
			countLabel.x = coinsIcon.x + coinsIcon.width + 4;
			
			topLayer.addChild(coinsIcon);
			topLayer.addChild(textLabel);
			topLayer.addChild(countLabel);
			
			addChild(topLayer);
			
			resize();
		}
		
		public function resize():void {
			
			if (settings['multiline'] && textLabel.width + coinsIcon.width + countLabel.width > settings.width) {
				var lineMargin:Number = 2;
				
				textLabel.x = (settings.width - textLabel.width) / 2;
				textLabel.y = (settings.height - textLabel.height - lineMargin - countLabel.height) / 2;
				coinsIcon.x = (settings.width - coinsIcon.width - lineMargin - countLabel.width) / 2;
				coinsIcon.y = textLabel.y + textLabel.height + 4;
				countLabel.x = coinsIcon.x + coinsIcon.width + 5;
				countLabel.y = textLabel.y + textLabel.height + 1;
			}else {
				textLabel.x = (settings.width - textLabel.width - 2 - coinsIcon.width - 2 - countLabel.width) / 2;
				textLabel.y = (settings.height - textLabel.height) / 2;
				coinsIcon.x = textLabel.x + textLabel.width + 2;
				coinsIcon.y = bottomLayer.y + bottomLayer.height * 0.5 - coinsIcon.height * 0.5 + int(bottomLayer.height * 0.05); // + 5% от высоты
				countLabel.x = coinsIcon.x + coinsIcon.width + 2;
				countLabel.y = bottomLayer.y + bottomLayer.height * 0.5 - countLabel.height * 0.5 + int(bottomLayer.height * 0.05); // + 5% от высоты
			}
			
		}
		
	}

}