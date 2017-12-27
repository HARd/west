package wins 
{
	import flash.display.Sprite;
	public class LuckyBagWindow extends Window 
	{
		
		public function LuckyBagWindow(settings:Object=null) 
		{
			if (!settings) settings = { };
			
			settings['width'] = settings['width'] || 580;
			settings['height'] = settings['height'] || 500;
			settings['title'] = settings['title'] || Locale.__e('flash:1452848012209');
			settings['hasPaginator'] = true;
			settings['itemsOnPage'] = 12;
			settings['content'] = [];
			
			for each (var item:* in settings.items) {
				if (item.hasOwnProperty('sid')) {
					settings.content.push(item);
				}else {
					for (var sid:* in item) {
						settings.content.push({sid:sid, count:item[sid]});
					}
				}
			}
			
			super(settings);
			
		}
		
		override public function drawBackground():void {
			background = backing2(settings.width, settings.height, 190, 'shopBackingTop', 'shopBackingBot');
			layer.addChild(background);
		}
		
		override public function drawArrows():void {
			paginator.drawArrow(bodyContainer, Paginator.LEFT,  0, 0, { scaleX: -1, scaleY:1 } );
			paginator.drawArrow(bodyContainer, Paginator.RIGHT, 0, 0, { scaleX:1, scaleY:1 } );
			
			var y:Number = (settings.height - paginator.arrowLeft.height) / 2 - 10;
			paginator.arrowLeft.x = 50 - paginator.arrowLeft.width;
			paginator.arrowLeft.y = y - 18;
			
			paginator.arrowRight.x = settings.width - 50;
			paginator.arrowRight.y = y - 18;
			
			paginator.x = (settings.width - paginator.width) / 2 - 30;
			paginator.y = settings.height - 30;
		}
		
		override public function drawBody():void {
			paginator.onPageCount = settings.itemsOnPage;
			paginator.update();
			
			contentChange();
		}
		
		private var items:Array;
		private var itemsContainer:Sprite = new Sprite();
		override public function contentChange():void {
			if (items) {
				for each(var _item:* in items) {
					itemsContainer.removeChild(_item);
					_item.dispose();
				}
			}
			items = [];
			
			bodyContainer.addChild(itemsContainer);
			var target:*;
			var X:int = 0;
			var Xs:int = X;
			var Ys:int = 0;
			itemsContainer.x = 50;
			itemsContainer.y = 30;
			if (settings.content.length < 1) return;
			var cnt:int = 0;
			for (var i:int = paginator.startCount; i < paginator.finishCount; i++)
			{
				var item:LuckyItem = new LuckyItem(this, { item:settings.content[i] } );
				item.x = Xs;
				item.y = Ys;
				items.push(item);
				itemsContainer.addChild(item);
				
				Xs += item.bg.width + 7;
				cnt++;
				
				if (cnt == 4) {
					Xs = 0;
					Ys += item.bg.height + 7;
					cnt = 0;
				} 
			}
			
			if (settings.content.length < 4) itemsContainer.x = (settings.width - itemsContainer.width) / 2;
		}
		
		override public function dispose():void {
			if (items) {
				for each(var _item:* in items) {
					itemsContainer.removeChild(_item);
					_item.dispose();
				}
			}
			super.dispose();
		}
		
	}

}
import core.Load;
import core.Size;
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.text.TextField;
import wins.Window;

internal class LuckyItem extends LayerX
{
	public var bg:Bitmap;
	public var sID:int;
	public var count:int;
	private var icon:Bitmap = new Bitmap();
	public function LuckyItem(window:*, data:Object)
	{
		sID = data.item.sid;
		count = data.item.count;
		bg = Window.backing(115, 115, 50, 'itemBacking');
		addChild(bg);
		
		if (App.data.storage[sID].type == 'Energy') {
			Load.loading(Config.getIcon(App.data.storage[sID].type, App.data.storage[sID].preview), onLoad);
		}else {
			Load.loading(Config.getIcon(App.data.storage[sID].type, App.data.storage[sID].view), onLoad);
		}
		
		tip = function():Object {
			return {
				title:App.data.storage[sID].title,
				text:App.data.storage[sID].description
			};
		}
	}
	
	private function onLoad(data:*):void {
		icon.bitmapData = data.bitmapData;
		icon.smoothing = true;
		Size.size(icon, 75, 75);
		icon.x = (bg.width - icon.width) / 2;
		icon.y = (bg.height - icon.height) / 2 + 5;
		addChild(icon);
		
		drawTitle();
		drawCount();
	}
	
	private function drawTitle():void {
		var titletext:TextField = Window.drawText(App.data.storage[sID].title, {
			color		:0x773d18,
			borderColor	:0xf9fce7,
			width		:bg.width,
			textAlign	:'center',
			multiline	:true,
			wrap		:true
		});
		addChild(titletext);
	}
	
	private function drawCount():void {
		var counttext:TextField = Window.drawText('x' + String(count), {
			color		:0xfffdff,
			borderColor	:0x773d18,
			width		:bg.width,
			textAlign	:'right',
			multiline	:true,
			wrap		:true,
			fontSize	:24
		});
		counttext.x = -15;
		counttext.y = bg.height - counttext.textHeight - 10;
		addChild(counttext);
	}
	
	public function dispose():void {
		
	}
}