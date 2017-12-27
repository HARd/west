package wins 
{
	import buttons.Button;
	import buttons.MoneyButton;
	import core.Numbers;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import ui.BitmapLoader;
	
	public class UndergroundPresentWindow extends Window 
	{
		
		public const NUM_ON_LINE:uint = 8;
		
		public var okBttn:Button;
		public var container:Sprite;
		private var buyBttn:Button;
		private var countLabel:TextField;
		
		public function UndergroundPresentWindow(settings:Object=null) 
		{
			
			if (!settings) settings = { };
			
			settings.reward = settings.reward || { };
			settings.require = settings.require || { };
			settings.width = Math.max(400, 100 + Math.min(NUM_ON_LINE, Numbers.countProps(settings.reward)) * 70);
			settings.height = 240 + 80 * int(Numbers.countProps(settings.reward) / NUM_ON_LINE);// (Numbers.countProps(settings.require)) ? 380 : 240;
			settings.background = 'goldBacking';
			settings.title = settings.title || Locale.__e('flash:1472628617873');
			settings.hasPaginator = false;
			settings.hasPages = false;
			settings.mirrorDecor = 'goldTitleDec';
			settings.noCount = settings.noCount || false;
			
			super(settings);
			
		}
		
		override public function drawBody():void {
			
			exit.x += 10;
			exit.y -= 10;
			
			if (!container) {
				container = new Sprite();
				bodyContainer.addChild(container);
			}else{
				container.removeChildren();
			}
			
			var list:Array = [];
			for (var s:* in settings.reward) {
				list.push({ sid:s, count:settings.reward[s], order:s });
			}
			list.sortOn('order', Array.NUMERIC);
			
			var chances:Array = [];
			for (var c:* in settings.chances) {
				chances.push({ chance:settings.chances[c], order:c });
			}
			chances.sortOn('order', Array.NUMERIC);
			
			for (var i:int = 0; i < list.length; i++) {
				var item:UPItem = new UPItem(list[i], settings.noCount, chances[i].chance);
				item.x = 70 * (container.numChildren % NUM_ON_LINE);
				item.y = 80 * int(container.numChildren / NUM_ON_LINE);
				container.addChild(item);
			}
			
			container.x = settings.width * 0.5 - container.width * 0.5;
			container.y = 80;
			
			// Description
			var textLabel:TextField = Window.drawText(Locale.__e('flash:1472715936723')/*settings.description || ''*/, {
				fontSize:			28,
				textAlign:			'center',
				width:				settings.width - 80,
				color:				0x803b1a,
				borderColor:		0xfff7f1,
				multiline:			true,
				wrap:				true
			});
			textLabel.x = settings.width * 0.5 - textLabel.width * 0.5;
			textLabel.y = 14;
			bodyContainer.addChild(textLabel);
			
			// OK
			okBttn = new Button( {
				width:		140,
				height:		46,
				caption:	(settings.onClick != null) ? Locale.__e('flash:1382952379737')	/* Забрать */ : Locale.__e('flash:1382952380298')
			});
			okBttn.x = settings.width * 0.5 - okBttn.width * 0.5;
			okBttn.y = settings.height - 60;
			bodyContainer.addChild(okBttn);
			okBttn.addEventListener(MouseEvent.CLICK, onClick);
			
			//if (Numbers.countProps(settings.require) > 0)
				//drawRequire();
		}
		
		private var requireSprite:LayerX = new LayerX();
		private function drawRequire():void {			
			var firstObject:Object = Numbers.firstProp(settings.require);
			if (App.user.stock.count(firstObject.key) < firstObject.val)
				okBttn.state = Button.DISABLED;
			
			var separator:Bitmap = Window.backingShort(settings.width - 100, 'dividerLine', false);
			separator.x = (settings.width - separator.width) / 2;;
			separator.y = 140;
			separator.alpha = 0.5;
			bodyContainer.addChild(separator);
			
			// Не открыть сундук без ключа
			var requireLabel:TextField = Window.drawText(Locale.__e('flash:1472542311970'), {
				fontSize:			24,
				textAlign:			'center',
				width:				settings.width - 40,
				color:				0x803b1a,
				borderColor:		0xfff7f1,
				multiline:			true,
				wrap:				true
			});
			requireLabel.x = settings.width * 0.5 - requireLabel.width * 0.5;
			requireLabel.y = 150;
			bodyContainer.addChild(requireLabel);
			
			var circle:Shape = new Shape();
			circle.graphics.beginFill(0xc7c9b9, 1);
			circle.graphics.drawCircle(0, 0, 50);
			circle.graphics.endFill();
			circle.x = settings.width * 0.5;
			circle.y = requireLabel.y + requireLabel.height + 56;
			bodyContainer.addChild(circle);
			
			var requireBitmap:BitmapLoader = new BitmapLoader(firstObject.key, 80, 80);
			requireBitmap.x = circle.x - requireBitmap.width * 0.5;
			requireBitmap.y = circle.y - requireBitmap.height * 0.5;
			bodyContainer.addChild(requireSprite);
			requireSprite.addChild(requireBitmap);
			
			requireSprite.tip = function():Object {
				return {
					titleBar:App.data.storage[firstObject.key].title,
					text:App.data.storage[firstObject.key].description
				}
			}
			
			countLabel = Window.drawText(Locale.__e('flash:1382952380278', [App.user.stock.count(firstObject.key), firstObject.val]), {
				fontSize:			28,
				textAlign:			'center',
				width:				80,
				color:				(okBttn.mode == Button.DISABLED) ? 0xcc9999 : 0xffffff,
				borderColor:		0x7f3f00
			});
			countLabel.x = circle.x - countLabel.width * 0.5;
			countLabel.y = circle.y + 15;
			bodyContainer.addChild(countLabel);
			
			buyBttn = new Button( {
				caption			:Locale.__e("flash:1382952379751"),
				radius      	:10,
				width			:110,
				height			:35,
				fontSize		:18
			});
			buyBttn.x = circle.x - buyBttn.width / 2;
			buyBttn.y = countLabel.y + 30;
			buyBttn.addEventListener(MouseEvent.CLICK, onBuy);
			
			if (App.user.stock.count(firstObject.key) < firstObject.val) {
				bodyContainer.addChild(buyBttn);
			}
		}
		
		private function onBuy(e:MouseEvent):void {
			var firstObject:Object = Numbers.firstProp(settings.require);
			var content:Array = PurchaseWindow.createContent('Energy', { view:App.data.storage[firstObject.key].view } );
			new PurchaseWindow( {
				popup:		true,
				width:		716,
				itemsOnPage:content.length,
				content:	content,
				title:		App.data.storage[firstObject.key].title,
				description:Locale.__e("flash:1464346398152"),
				callback:	function(sID:int):void {
					countLabel.text = Locale.__e('flash:1382952380278', [App.user.stock.count(firstObject.key), firstObject.val]);
					if (App.user.stock.count(firstObject.key) < firstObject.val)
						okBttn.state = Button.DISABLED;
					else 
						okBttn.state = Button.NORMAL;
				}
			}).show();
		}
		
		private function onClick(e:MouseEvent):void {
			if (okBttn.mode == Button.DISABLED) return;
			okBttn.state = Button.DISABLED;
			
			if (settings.onClick != null)
				settings.onClick();
			
			close();
		}
		
		override public function dispose():void {
			super.dispose();
			
			okBttn.removeEventListener(MouseEvent.CLICK, onClick);
		}
		
	}

}

import flash.text.TextField;
import ui.BitmapLoader;
import wins.Window;

internal class UPItem extends LayerX {
	
	public var sid:int;
	public var count:int;
	public var chance:int;
	public var bitmap:BitmapLoader;
	
	public function UPItem(object:Object, noCount:Boolean, chance:int) {
		
		sid = object.sid;
		count = object.count;
		
		bitmap = new BitmapLoader(sid, 60, 70);
		addChild(bitmap);
		
		tip = function():Object {
			return {
				title:App.data.storage[sid].title,
				text:App.data.storage[sid].description
			}
		}
		
		//if (noCount) return;
		//
		
		if (!App.isSocial('AI', 'YB', 'MX', 'GN')) return;
		
		var textLabel:TextField = Window.drawText(chance.toString() + '%', {
			fontSize:			24,
			textAlign:			'right',
			width:				bitmap.width - 10,
			color:				0xffffff,
			borderColor:		0x6f5637
		});
		textLabel.x = 5;
		textLabel.y = 60 - textLabel.height + 10;
		addChild(textLabel);
	}
	
}