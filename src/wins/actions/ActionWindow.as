package wins.actions 
{
	import buttons.Button;
	import core.Load;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;

	public class ActionWindow extends Window
	{
		private var items:Array = new Array();
		public var action:Object;
		private var container:Sprite;
		private var priceBttn:Button;
		
		public function ActionWindow(settings:Object = null)
		{
			if (settings == null) {
				settings = new Object();
			}
			
			action = App.data.promo['516d5ea7993f8'];
			action.id = '516d5ea7993f8';
			
			settings['width'] = 670 + 60;
			settings['height'] = 540;
						
			settings['title'] = action.title;
			settings['hasPaginator'] = false;
			settings['hasButtons'] = false;
			settings['fontColor'] = 0xffcc00;
			settings['fontSize'] = 60;
			settings['fontBorderColor'] = 0x705535;
			settings['shadowBorderColor'] = 0x342411;
			settings['fontBorderSize'] = 8;
			
			settings.content = initContent(action.items);
			settings.bonus = initContent(action.bonus);
			
			super(settings);
		}
		
		private function initContent(data:Object):Array
		{
			var result:Array = [];
			for (var item:* in data)
			{
				result.push({sID:item, count:data[item]});
			}
			
			return result;
		}
		
		override public function drawBody():void {
			
			titleLabel.y -= 10;
			var text:String = Locale.__e(action.description);
			
			
			var descriptionLabel:TextField = drawText(text, {
				fontSize:26,
				autoSize:"left",
				textAlign:"center",
				color:0xf0e6c1,
				borderColor:0x502f06
			});
			descriptionLabel.x = (settings.width - descriptionLabel.width) / 2;
			descriptionLabel.y = 20;
			descriptionLabel.width = settings.width - 80;
			
			bodyContainer.addChild(descriptionLabel);
			
			container = new Sprite();
			bodyContainer.addChild(container);
			container.x = 50;
			container.y = 50;
			
			contentChange();
			drawPrice();
			drawTime();
			
			drawImage();
		}
		
		private function drawImage():void {
			Load.loading(Config.getImage('promo/images', action.image), function(data:Bitmap):void {
				
				var image:Bitmap = new Bitmap(data.bitmapData);
				bodyContainer.addChildAt(image, 0);
				image.x = 20;
				image.y = 185;
				
			});
			
			var glowing:Bitmap = new Bitmap(Window.textures.actionGlow);
			bodyContainer.addChildAt(glowing, 0);
			
			glowing.x = 350;
			glowing.y = 265;
		}
		
		public override function contentChange():void 
		{
			for each(var _item:ActionItem in items)
			{
				container.removeChild(_item);
				_item = null;
			}
			
			items = [];
			
			var Xs:int = 0;
			var Ys:int = 0;
			var X:int = 0;
			
			var itemNum:int = 0;
			//for (var i:int = paginator.startCount; i < paginator.finishCount; i++)
			for (var i:int = 0; i < settings.content.length; i++)
			{
				var item:ActionItem = new ActionItem(settings.content[i], this);
				
				container.addChild(item);
				item.x = Xs;
				item.y = Ys;
								
				items.push(item);
				Xs += item.background.width;
			}
			
			for (i = 0; i < settings.bonus.length; i++)
			{
				item = new ActionItem(settings.bonus[i], this, true);
				
				container.addChild(item);
				item.x = Xs;
				item.y = Ys;
								
				items.push(item);
				Xs += item.background.width;
			}
			
			container.x = (settings.width - container.width)/2
		}
		
		override public function drawBackground():void {
			var background:Bitmap = backing(settings.width, settings.height, 50, "windowActionBacking");
			layer.addChild(background);
		}
		
		public function drawTime():void {
			
			var background:Bitmap = Window.backing(230, 130, 10, "itemBacking");
			bodyContainer.addChild(background);
			background.x = 380;
			background.y = 240 - 10;
			
			var descriptionLabel:TextField = drawText(Locale.__e('flash:1382952379969'), {
				fontSize:30,
				textAlign:"center",
				color:0xf0e6c1,
				borderColor:0x502f06
			});
			descriptionLabel.width = 230;
			descriptionLabel.x = background.x;
			descriptionLabel.y = background.y + 25;
			bodyContainer.addChild(descriptionLabel);
			
			var text:TextField = Window.drawText(TimeConverter.timeToCuts(action.duration*60*60, false, true), {
				color:0xf8d74c,
				textAlign:"center",
				fontSize:30,
				borderColor:0x502f06
			});
			text.width = 230;
			text.y = 305 - 10;
			text.x = background.x;
			bodyContainer.addChild(text);
		}
		
		public function drawPrice():void {
			
			var bttnSettings:Object = {
				caption:Locale.__e("flash:1382952379970"),
				fontSize:26,
				width:166,
				height:45,
				borderColor:[0xaff1f9, 0x005387],
				bgColor:[0x70c6fe, 0x765ad7],
				fontColor:0x453b5f,
				fontBorderColor:0xe3eff1
			};
			
			priceBttn = new Button(bttnSettings);
			bodyContainer.addChild(priceBttn);
			
			priceBttn.x = 380 + 230/2 - priceBttn.width/2;
			priceBttn.y = settings.height - 135;
			
			priceBttn.addEventListener(MouseEvent.CLICK, onBuyEvent);
			
			var cont:Sprite = new Sprite();
			
			var text1:TextField = drawText(Locale.__e('flash:1382952379971'), {
				fontSize:24,
				textAlign:"left",
				color:0xf0e6c1,
				borderColor:0x502f06
			});
			text1.width = text1.textWidth + 5;
			text1.x = 0;
			cont.addChild(text1);
			
			var text2:TextField = Window.drawText(Locale.__e('flash:1382952379972',[action.price['VK']]), {
				color:0xf8d74c,
				textAlign:"left",
				fontSize:24,
				borderColor:0x502f06
			});
			text2.width = text2.textWidth + 5;
			text2.x = text1.x + text1.width;
			cont.addChild(text2);
			
			bodyContainer.addChild(cont);
			cont.x = priceBttn.x + priceBttn.width / 2 - cont.width / 2;
			cont.y = priceBttn.y - 30;
			
			text1.height = text1.textHeight;
			text2.height = text2.textHeight;
		}
		
		private function onBuyEvent(e:MouseEvent):void
		{
			
		}
		
		public override function dispose():void
		{
			for each(var _item:ActionItem in items)
			{
				_item = null;
			}
			
			super.dispose();
		}
	}
}

import core.Load;
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.filters.GlowFilter;
import flash.text.TextField;
import wins.Window;

internal class ActionItem extends Sprite {
		
		public var count:uint;
		public var sID:uint;
		public var background:Bitmap;
		public var bitmap:Bitmap;
		public var title:TextField;
		public var window:*;
		
		private var preloader:Preloader = new Preloader();
		
		public function ActionItem(item:Object, window:*, bonus:Boolean = false) {
			
			sID = item.sID;
			count = item.count;
			
			this.window = window;
			
			background = Window.backing(130, 160, 10, "itemBacking");
			addChild(background);
			
			var sprite:LayerX = new LayerX();
			addChild(sprite);
			
			bitmap = new Bitmap();
			sprite.addChild(bitmap);
			
			if (bonus)
				addBonusLabel();
			
			drawTitle();
			drawCount();
			
			addChild(preloader);
			preloader.x = (background.width)/ 2;
			preloader.y = (background.height)/ 2 - 15;
			
			Load.loading(Config.getIcon(App.data.storage[sID].type, App.data.storage[sID].preview), onPreviewComplete);
			
			
		}
		
		private function addBonusLabel():void {
			background.filters = [new GlowFilter(0xb63718, 0.6, 25, 25, 4, 1, true)];
			
			var bonusLabel:Sprite = Window.titleText( {
					title				: Locale.__e('flash:1382952379973'),
					color				: 0xb63718,
					fontSize			: 30,				
					borderColor 		: 0xf5edd0,			
					borderSize 			: 8,	
					shadowBorderColor	: 0x4b0c21
				});
				
			bonusLabel.y = -20;
			bonusLabel.x = background.width - 40;
			bonusLabel.rotation = 35;
			addChild(bonusLabel);
		}
		
		public function onPreviewComplete(data:Bitmap):void
		{
			removeChild(preloader);
			
			bitmap.bitmapData = data.bitmapData;
			bitmap.scaleX = bitmap.scaleY = 0.8;
			bitmap.smoothing = true;
			bitmap.x = (background.width - bitmap.width)/ 2;
			bitmap.y = (background.height - bitmap.height)/ 2 - 15;
		}
		
		public function drawTitle():void {
			title = Window.drawText(String(App.data.storage[sID].title), {
				color:0x6d4b15,
				borderColor:0xfcf6e4,
				textAlign:"center",
				autoSize:"center",
				fontSize:20,
				textLeading:-6,
				multiline:true
			});
			title.wordWrap = true;
			title.width = background.width - 20;
			title.y = 10;
			title.x = 10;
			addChild(title);
		}
		
		public function drawCount():void {
			var countText:TextField = Window.drawText(String(count) + Locale.__e("flash:1382952379974"), {
				//color:0x6d4b15,
				//borderColor:0xfcf6e4,
				color:0xf8d74c,
				borderColor:0x502f06,
				textAlign:"center",
				autoSize:"center",
				fontSize:26,
				textLeading:-6,
				multiline:true
			});
			countText.wordWrap = true;
			countText.width = background.width - 10;
			countText.y = background.height -40;
			countText.x = 5;
			addChild(countText);
		}
}
