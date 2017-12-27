package wins 
{
	import buttons.Button;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.text.TextField;
	public class ChooseBoxWindow extends Window 
	{
		public var bonus:Object;
		public var bonusID:int = 0;
		public function ChooseBoxWindow(settings:Object=null) 
		{
			if (settings == null) {
				settings = new Object();
			}
			
			settings['width'] 			= 580;
			settings['height'] 			= 340;
			settings['title'] 			= Locale.__e('flash:1440499603885');
			settings['hasPaginator'] 	= false;
			settings['hasButtons']		= false;
			settings['background'] 		= 'goldBacking';
			
			bonus = settings['bonus'];
			bonusID = settings['id'];
			
			super(settings);
		}
		
		override public function drawBody():void {
			var separator:Bitmap = Window.backingShort(settings.width - 200, 'dividerLine', false);
			separator.x = (settings.width - separator.width) / 2;;
			separator.y = 20;
			separator.alpha = 0.5;
			bodyContainer.addChild(separator);
			
			var separator2:Bitmap = Window.backingShort(settings.width - 200, 'dividerLine', false);
			separator2.scaleY = -1;
			separator2.x = (settings.width - separator2.width) / 2;;
			separator2.y = 70;
			separator2.alpha = 0.5;
			bodyContainer.addChild(separator2);
			
			var description:TextField = drawText(Locale.__e('flash:1469629037914'), {
				color:0x5b340d,
				border:false,
				textAlign:'center',
				fontSize:26,
				width:settings.width - 100
			});
			description.x = (settings.width - description.width) / 2;
			description.y = 30;
			bodyContainer.addChild(description);
			
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
			var Xs:int = 75;
			var Ys:int = 80;
			itemsContainer.y = Ys;
			//if (settings.content.length < 1) return;
			for (var i:int = 0; i < 3; i++)
			{
				var item:BoxItem = new BoxItem(this, { id:i, treasure:bonus.treasure[i] } );
				item.x = Xs;
				items.push(item);
				itemsContainer.addChild(item);
				
				Xs += 150;
			}
			
			if (App.user.uData.hasOwnProperty('b' + String(bonusID)) && App.user.uData['b' + String(bonusID)].midnight == App.midnight) {
				blockButtons();
			}
		}
		
		public function blockButtons(chooseIndex:int = -1):void {
			for each (var item:BoxItem in items) {
				if (item.index != chooseIndex) {
					item.bttnTake.state = Button.DISABLED;
				}
			}
		}
		
		public override function dispose():void {
			if (items) {
				for each(var _item:* in items) {
					itemsContainer.removeChild(_item);
					_item.dispose();
				}
			}
			items = [];
			
			super.dispose();
		}
		
	}

}

import buttons.Button;
import core.Load;
import core.Post;
import core.Size;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.text.TextField;
import wins.Window;

internal class BoxItem extends Sprite
{
	public static var previews:Array = ['CloseChest1','CloseChest2','CloseChest3'];
	public static var previewsOpen:Array = ['CloseChest1Open','CloseChest2Open','CloseChest2Open'];
	public var window:*;
	public var index:int;
	public var bg:Bitmap;
	public var bttnTake:Button;
	private var bitmap:Bitmap;
	private var treasure:String;
	
	public function BoxItem(window:*, data:Object)
	{	
		this.treasure = data.treasure;
		this.index = data.id;
		this.window = window;
		
		bg = new Bitmap(new BitmapData(65 * 2, 65 * 2, true, 0xffffff));
		bg.x = 0;
		bg.y = 0;
		addChild(bg);
		
		var shape:Shape = new Shape();
		shape.graphics.beginFill(0xc8cabc, 1);
		shape.graphics.drawCircle(65, 65, 65);
		shape.graphics.endFill();
		bg.bitmapData.draw(shape);
		
		Load.loading(Config.getImage('content', previews[data.id]), onLoad);
		
		drawButton();
	}
	
	private function onClick(e:MouseEvent):void 
	{
		new ShowBonusWindow( {
			popup:true,
			bonus:treasure
		}).show();
	}
	
	private var sprite:Sprite = new Sprite();
	private function onLoad(data:Bitmap):void {
		addChildAt(sprite, 1);
		
		bitmap = new Bitmap(data.bitmapData);
		Size.size(bitmap, 120, 120);
		sprite.addChild(bitmap);
		bitmap.x = (bg.width - bitmap.width) / 2;
		bitmap.y = (bg.height - bitmap.height) / 2;
		bitmap.smoothing = true;
		
		sprite.addEventListener(MouseEvent.CLICK, onClick);
	}
	
	private function drawButton():void {
		bttnTake = new Button( {
			caption:Locale.__e('flash:1382952379890'),
			width:120
		});
		bttnTake.x = (bg.width - bttnTake.width) / 2;
		bttnTake.y = 140;
		bttnTake.addEventListener(MouseEvent.CLICK, onTakeBonus);
		addChild(bttnTake);
	}
	
	private function onTakeBonus(e:MouseEvent):void {
		if (e.currentTarget.mode == Button.DISABLED) return;
		
		window.blockButtons(index);
		
		Post.send({
			ctr:'bonus',
			act:'day',
			uID:App.user.id,
			sID:window.bonusID,
			tr:treasure
		}, onBonusEvent);
	}
	
	private function onBonusEvent(error:int, data:Object, params:Object):void {
		if (error) {
			Errors.show(error, data);
			return;
		}
		
		Window.closeAll();
	}
	
	public function dispose():void {
		
	}
}
import wins.Paginator;
internal class ShowBonusWindow extends Window {
	
	private var bttn:Button;
	public function ShowBonusWindow(settings:Object = null):void {
		if (settings == null) {
			settings = new Object();
		}
		
		settings['width'] 			= 400;
		settings['height'] 			= 160;
		settings['title'] 			= Locale.__e('flash:1457014786062');
		settings['hasPaginator'] 	= true;
		settings['hasButtons']		= false;
		settings['itemsOnPage']		= 5;
		settings['background'] 		= 'dialogueBacking';
		settings['bonus'] 			= settings.bonus;
		settings['content']			= [];
			
		super(settings);
		
		initContent();
	}
	
	private function initContent():void {
		var treasure:Object = App.data.treasures[settings.bonus][settings.bonus];
		if (!treasure) return;
		var items:Array = treasure.item;
		var counts:Array = treasure.count;
		
		for (var i:int = 0; i < items.length; i++) {
			settings.content.push({sid:items[i], count:counts[i]});
			//settings.content.push({sid:items[i], count:counts[i]});
			//settings.content.push({sid:items[i], count:counts[i]});
			//settings.content.push({sid:items[i], count:counts[i]});
		}
	}
	
	override public function drawBody():void {
		exit.visible = false;
		
		bttn = new Button( {
			caption:Locale.__e('flash:1382952380298')
		});
		bttn.x = (settings.width - bttn.width) / 2;
		bttn.y = settings.height - bttn.height - bttn.height / 2;
		bttn.addEventListener(MouseEvent.CLICK, close);
		bodyContainer.addChild(bttn);
		
		var separator:Bitmap = Window.backingShort(settings.width - 50, 'dividerLine', false);
		separator.x = (settings.width - separator.width) / 2;;
		separator.y = 10;
		separator.alpha = 0.5;
		bodyContainer.addChild(separator);
		
		var separator2:Bitmap = Window.backingShort(settings.width - 50, 'dividerLine', false);
		separator2.scaleY = -1;
		separator2.x = (settings.width - separator2.width) / 2;;
		separator2.y = 85;
		separator2.alpha = 0.5;
		bodyContainer.addChild(separator2);
		
		contentChange();
	}
	
	private var items:Array;
	private var itemsContainer:Sprite = new Sprite();
	override public function contentChange():void {
		if (items) {
			for each(var _item:* in items) {
				itemsContainer.removeChild(_item);
			}
		}
		items = [];
		
		bodyContainer.addChild(itemsContainer);
		var target:*;
		var Xs:int = 0;
		var Ys:int = 20;
		itemsContainer.y = Ys;
		if (settings.content.length < 1) return;
		for (var i:int = paginator.startCount; i < paginator.finishCount; i++)
		{
			var item:BonusItem = new BonusItem(this, settings.content[i]);
			item.x = Xs;
			items.push(item);
			itemsContainer.addChild(item);
			
			Xs += item.bg.width + 10;
		}
		
		itemsContainer.x = (settings.width - itemsContainer.width) / 2 + 40;
	}
	
	override public function drawArrows():void 
	{			
		paginator.drawArrow(bottomContainer, Paginator.LEFT,  0, 0, { scaleX: -0.7, scaleY:0.7 } );
		paginator.drawArrow(bottomContainer, Paginator.RIGHT, 0, 0, { scaleX:0.7, scaleY:0.7 } );
		
		var y:int = (settings.height - paginator.arrowLeft.height) / 2 + 45;
		paginator.arrowLeft.x = -5;
		paginator.arrowLeft.y = y + 5;
		
		paginator.arrowRight.x = settings.width - paginator.arrowRight.width + 15;
		paginator.arrowRight.y = y + 5;
	}
}

internal class BonusItem extends Sprite {
	
	private var bmp:Bitmap;
	private var window:*;
	public var bg:Bitmap;
	public function BonusItem(window:*, data:Object):void {
		this.window = window;
		
		bg = new Bitmap(new BitmapData(55, 55, true, 0xffffff));
		addChild(bg);
		
		Load.loading(Config.getIcon(App.data.storage[data.sid].type, App.data.storage[data.sid].preview), onLoad);
		
		drawCount(data.count);
	}
	
	private function onLoad(data:*):void {
		bmp = new Bitmap(data.bitmapData);
		Size.size(bmp, 55, 55);
		bmp.smoothing = true;
		addChildAt(bmp, 0);
	}
	
	private function drawCount(count:int):void {
		var text:TextField = Window.drawText('x' + String(count), {
			fontSize:26,
			color:0xffffff,
			borderColor:0x60462b
		})
		text.x = 43;
		text.y = 33;
		addChild(text);
	}
}

