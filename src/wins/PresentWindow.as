package wins 
{
	import buttons.Button;
	import buttons.MenuButton;
	import buttons.MoneyButton;
	import core.Load;
	import core.Post;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import units.Hut;

	public class PresentWindow extends Window
	{
		private var items:Array = new Array();
		public var action:Object;
		private var container:Sprite;
		private var priceBttn:Button;
		
		public function PresentWindow(settings:Object = null)
		{
			if (settings == null) {
				settings = new Object();
			}
					
			settings['height'] = 450;
					
			settings['title'] = Locale.__e('flash:1382952380235');
			settings['hasPaginator'] = false;
			settings['hasButtons'] = false;
		
			settings['fontSize'] = 44;
			
			var items:Object = App.data.gifts[settings.gift].items;
			var _width:int = 0;
			for (var sid:* in items) {
				_width += 140;
			}
			settings['width'] = Math.max(_width + 100, 400);
			
			settings.content = initContent(items);
			
			super(settings);
		}
		
		override public function drawBackground():void {
			var background:Bitmap = backing(settings.width, settings.height, 50, "windowActionBacking");
			layer.addChild(background);
			
			var bitmap:Bitmap = new Bitmap();
			bitmap.bitmapData = Load.getCache(Config.getImage('promo/images', 'present')).bitmapData;
			bitmap.scaleX = bitmap.scaleY = 0.74;
			bitmap.smoothing = true;
			layer.addChildAt(bitmap,1);
			bitmap.x = (settings.width - bitmap.width) / 2;
			bitmap.y = -bitmap.y / 2 - 90; 
		}
		
		private function initContent(data:Object):Array
		{
			var result:Array = [];
			for (var item:* in data){
				result.push({sID:item, count:data[item]});
			}
			return result;
		}
		
		override public function drawBody():void {
			
			titleLabel.y = 116;
			
			container = new Sprite();
			bodyContainer.addChild(container);
			container.x = 50;
			container.y = 107;
			
			contentChange();
			
			var glowing:Bitmap = new Bitmap(Window.textures.actionGlow);
			bodyContainer.addChildAt(glowing, 0);
			glowing.width = settings.width - 90;
			glowing.x = (settings.width - glowing.width)/2;
			glowing.y = settings.height - glowing.height - 60;
			
			var bttnSettings:Object = {
				caption:Locale.__e("flash:1382952380236"),
				fontSize:26,
				width:166,
				height:45
				//borderColor:[0xaff1f9, 0x005387],
				//bgColor:[0x70c6fe, 0x765ad7],
				//fontColor:0x453b5f,
				//fontBorderColor:0xe3eff1
			};
			
			priceBttn = new Button(bttnSettings);
			bodyContainer.addChild(priceBttn);
			
			priceBttn.x = (settings.width - priceBttn.width)/2;
			priceBttn.y = settings.height - 166;
			
			priceBttn.addEventListener(MouseEvent.CLICK, onTakeEvent);
		}
		
		
		public override function contentChange():void 
		{
			for each(var _item:PresentItem in items)
			{
				container.removeChild(_item);
				_item = null;
			}
			
			items = [];
			
			var Xs:int = 0;
			var Ys:int = 0;
			var X:int = 0;
			
			var itemNum:int = 0;
			for (var i:int = 0; i < settings.content.length; i++)
			{
				var item:PresentItem = new PresentItem(settings.content[i], this);	
				container.addChild(item);
				item.x = Xs;
				item.y = Ys;
								
				items.push(item);
				Xs += item.background.width;
			}
			container.x = (settings.width - container.width)/2
		}
		

			
		private function onTakeEvent(e:MouseEvent):void
		{
			Post.send({
				ctr:'present',
				act:'take',
				uID:App.user.id,
				pID:settings.gift
			},function(error:*, data:*, params:*):void {
				onTakeComplete();
			});
		}
		
		private function onTakeComplete(e:* = null):void 
		{
			priceBttn.state = Button.DISABLED;
			App.user.stock.addAll(App.data.gifts[settings.gift].items);
			
			for each(var item:PresentItem in items) {
				var bonus:BonusItem = new BonusItem(item.sID, item.count);
				var point:Point = Window.localToGlobal(item);
				bonus.cashMove(point, App.self.windowContainer);
			}
			
			App.user.presents[settings.gift] = { status:App.time };
			close();
			
			new SimpleWindow( {
				label:SimpleWindow.ATTENTION,
				title:Locale.__e("flash:1382952379735"),
				text:Locale.__e("flash:1382952380237")
			}).show();
		}
		
		public override function dispose():void
		{
			for each(var _item:PresentItem in items)
			{
				_item = null;
			}
			
			super.dispose();
		}
	}
}

import buttons.Button;
import core.Load;
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.filters.GlowFilter;
import flash.text.TextField;
import wins.Window;

internal class PresentItem extends Sprite {
		
		public var count:uint;
		public var sID:uint;
		public var background:Bitmap;
		public var bitmap:Bitmap;
		public var title:TextField;
		public var window:*;
		
		private var preloader:Preloader = new Preloader();
		
		public function PresentItem(item:Object, window:*, bonus:Boolean = false) {
			
			sID = item.sID;
			count = item.count;
			
			this.window = window;
			
			background = Window.backing(130, 160, 10, "itemBacking");
			addChild(background);
						
			var sprite:LayerX = new LayerX();
			addChild(sprite);
			
			bitmap = new Bitmap();
			sprite.addChild(bitmap);
					
			drawTitle();
			drawCount();
			
			addChild(preloader);
			preloader.x = (background.width)/ 2;
			preloader.y = (background.height)/ 2 - 15;
			
			Load.loading(Config.getIcon(App.data.storage[sID].type, App.data.storage[sID].preview), onPreviewComplete);
			
		}
		/*
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
		*/
		
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
