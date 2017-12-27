package wins.actions 
{
	import buttons.Button;
	import core.Load;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.text.TextField;
	import ui.UserInterface;
	import wins.elements.TimerUnit;
	import wins.AddWindow;
	import wins.Window;
	
	public class TemporaryActionWindow extends Window 
	{
		private var timerText:TextField;
		private var descriptionLabel:TextField;
		private var actionItems:Array = [];
		private var action:Object;
		
		public function TemporaryActionWindow(settings:Object=null) 
		{
			if (settings == null) {
				settings = new Object();
			}
			
			settings['width'] 			= 750;
			settings['height'] 			= 550;
			settings['title'] 			= Locale.__e('flash:1447926073325');
			settings['hasPaginator'] 	= false;
			settings['hasButtons']		= false;
			settings['background'] 		= 'stockBackingTop';
			
			action = App.data.actions[1030];
			
			super(settings);
		}
		
		override public function drawTitle():void {
			titleLabel = titleText( {
				title				: settings.title,
				color				: 0xffffff,
				multiline			: settings.multiline,			
				fontSize			: 46,
				textLeading	 		: settings.textLeading,	
				border				: true,
				borderColor 		: 0xc4964e,			
				borderSize 			: 4,	
				shadowColor			: 0x503f33,
				shadowSize			: 4,
				width				: settings.width - 140,
				textAlign			: 'center',
				sharpness 			: 50,
				thickness			: 50
			});
			titleLabel.x = (settings.width - titleLabel.width) * .5;
			titleLabel.y = -40;
			titleLabel.mouseChildren = titleLabel.mouseEnabled = false;
			headerContainer.addChild(titleLabel);
			headerContainer.mouseEnabled = false;
		}
		
		override public function drawBody():void {
			drawMirrowObjs('stockTitleBacking', 140, 140 + 236 * 2, -120);
			
			var titleText:TextField = drawText(Locale.__e('flash:1447927724992'), {
				color:			0xffd84f,
				borderColor:	0x5c300d,
				fontSize:		26
			});
			titleText.width = titleText.textWidth + 6;
			titleText.x = (settings.width - titleText.width) / 2;
			titleText.y = -30;
			bodyContainer.addChild(titleText);
			
			var bottomText:TextField = drawText(Locale.__e('flash:1447929334352'), {
				color:			0xffffff,
				borderColor:	0x56321a,
				fontSize:		26
			});
			bottomText.width = bottomText.textWidth + 6;
			bottomText.x = (settings.width - bottomText.width) / 2;
			bottomText.y = settings.height - 100;
			bodyContainer.addChild(bottomText);
			
			var bigShine:Bitmap = new Bitmap(Window.texture('glow'));
			bigShine.x = (settings.width - bigShine.width) / 2;
			bigShine.y = 15;
			bigShine.alpha = 0.5;
			bodyContainer.addChild(bigShine);
			
			var bigBanker:Bitmap = new Bitmap();
			bodyContainer.addChild(bigBanker);
			
			var preloader:Preloader = new Preloader();
			preloader.x = (settings.width - preloader.width) / 2;
			preloader.y = (settings.height - preloader.height) / 2;
			bodyContainer.addChild(preloader);
			Load.loading(Config.getImageIcon('sales/image/', 'GreedyBankier'), function (data:*):void {
				if (preloader) bodyContainer.removeChild(preloader);
				
				bigBanker.bitmapData = data.bitmapData;
				bigBanker.x = (settings.width - bigBanker.width) / 2;
				bigBanker.y = 15;
			});
			
			drawTimer();
			drawItems();
			//drawSale();
		}
		
		private function drawTimer():void {
			var timer:TimerUnit = new TimerUnit( {backGround:'glow',width:140,height:60,time: { started:action.begin_time, duration:action.duration}} );
			timer.start();
			timer.x = (settings.width - timer.width) / 2
			timer.y = settings.height - 180;
			bodyContainer.addChild(timer);
		}
		
		private function drawItems():void {
			var item:ActionItem = new ActionItem( {qID:1030, price1:40, price2:1, price3:10}, this);
			item.x = 80;
			item.y = 30;
			bodyContainer.addChild(item);
			actionItems.push(item);
			
			var item2:ActionItem = new ActionItem( {qID:1031, price1:200, price2:6, price3:20} , this);
			item2.x = 500;
			item2.y = 30;
			bodyContainer.addChild(item2);
			actionItems.push(item2);
		}
		
		private function drawSale():void {
			var sprite:Sprite = new Sprite();
			sprite.x = -30;
			sprite.y = -40;
			var label:Bitmap = new Bitmap(UserInterface.textures.saleLabelBank);
			label.smoothing = true;
			var textAction:TextField = Window.drawText(Locale.__e('flash:1447948813463'), {
				color: 0xffffff,
				borderColor: 0x765134,
				fontSize: 28
			});
			textAction.width = textAction.textWidth + 5;
			textAction.x = (label.width - textAction.textWidth) / 2;
			textAction.y = (label.height - textAction.textHeight) / 2;
			
			sprite.addChild(label);
			sprite.addChild(textAction);
			
			bodyContainer.addChild(sprite);
		}
		
		public function blockButtons(block:Boolean):void {
			var item:ActionItem;
			if (block) {
				for each (item in actionItems) {
					item.buyBttn.state = Button.DISABLED;
				}
			}else {
				for each (item in actionItems) {
					item.buyBttn.state = Button.NORMAL;
				}
			}
		}
		
		override public function dispose():void {
			super.dispose();
		}
		
	}

}

import buttons.Button;
import buttons.ImageButton;
import core.Load;
import core.TimeConverter;
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.text.TextField;
import ui.UserInterface;
import wins.SimpleWindow;
import wins.Window;

internal class ActionItem extends LayerX {
	private var window:*;
	private var data:Object;
	public var buyBttn:ImageButton;
	public var action:Object;
	
	public function ActionItem(data:Object, window:*) {
		this.data = data;
		this.window = window;
		this.action = App.data.actions[data.qID];
		action['id'] = data.qID;
		
		drawFirstBlock();
		drawSecondBlock();
		drawThirdBlock();
		drawButton();
		/*var _sid:*;
		var sidArr:Array = [];
		for (_sid in action.items) {
			sidArr.push(_sid);
		}
		_sid = sidArr[0];
		var item:Object = App.data.storage[_sid];
		tip = function():Object {			
			return {
				title:item.title,
				text:item.description + ' ' + TimeConverter.timeToStr(action.duration * 3600 - (App.time - action.time)),
				timer:true
			}
		};*/
	}
	
	private function drawFirstBlock():void {
		var sprite:Sprite = new Sprite();
		sprite.x = 10;
		addChild(sprite);
		
		var bg:Bitmap = Window.backing(170, 35, 50, 'fadeOutWhite');
		bg.x -= 10;
		bg.alpha = 0.6;
		sprite.addChild(bg);
		
		var text:TextField = Window.drawText(Locale.__e('flash:1447942905068'), {
			color:			0x74fff1,
			borderColor:	0x1d2f09,
			fontSize:		23
		});
		text.x = 10;
		text.y = 3;
		sprite.addChild(text);
		
		var number:TextField = Window.drawText(data.price1, {
			color:			0xcafe78,
			borderColor:	0x1a2f04,
			fontSize:		23
		});
		number.x = text.x + text.textWidth + 5;
		number.y = text.y;
		sprite.addChild(number);
		
		var bucks:Bitmap = new Bitmap(UserInterface.textures.fantsIcon);
		bucks.x = number.x + number.textWidth + 5;
		bucks.y = number.y - 5;
		sprite.addChild(bucks);
	}
	
	private function drawSecondBlock():void {
		var sprite:Sprite = new Sprite();
		sprite.y = 50;
		addChild(sprite);
		
		var bg:Bitmap = Window.backing(210, 130, 50, 'fadeOutWhite');
		bg.x -= 15;
		bg.alpha = 0.6;
		sprite.addChild(bg);
		
		var icoBanker:Bitmap = new Bitmap();
		sprite.addChild(icoBanker);
		
		var arrow:Bitmap = new Bitmap(Window.texture('barterArrowYellow'));
		arrow.scaleX = arrow.scaleY = 0.5;
		sprite.addChild(arrow);
		
		var bucks:Bitmap = new Bitmap(UserInterface.textures.fantsIcon);
		sprite.addChild(bucks);
		
		var number:TextField = Window.drawText(data.price2, {
			color:			0xcafe78,
			borderColor:	0x1a2f04,
			fontSize:		23
		});
		sprite.addChild(number);
		
		Load.loading(Config.getImageIcon('sales/image/', 'GreedyBankierIco'), function (data:*):void {
			icoBanker.bitmapData = data.bitmapData;
			icoBanker.x = 15;
			icoBanker.y = 3;
			
			arrow.x = icoBanker.x + icoBanker.width + 5;
			arrow.y = 25;
			
			bucks.x = arrow.x + arrow.width + 5;
			bucks.y = arrow.y - 10;
			
			number.x = bucks.x + bucks.width;
			number.y = arrow.y;
		});
		
		var desc:TextField = Window.drawText(action.text1, {
			color:			0xffd845,
			borderColor:	0x5c2b1a,
			fontSize:		21,
			multiline:		true,
			textAlign:		'center',
			textLeading:	-1
		});
		desc.wordWrap = true;
		desc.width = 210;
		desc.x -= 10;
		desc.y = 70;
		sprite.addChild(desc);
	}
	
	private function drawThirdBlock():void {
		var sprite:Sprite = new Sprite();
		sprite.y = 200;
		addChild(sprite);
		
		var bg:Bitmap = Window.backing(210, 120, 50, 'fadeOutWhite');
		bg.x -= 15;
		bg.alpha = 0.6;
		sprite.addChild(bg);
		
		var calendar:Bitmap = new Bitmap();
		sprite.addChild(calendar);
		
		var arrow:Bitmap = new Bitmap(Window.texture('barterArrowYellow'));
		arrow.scaleX = arrow.scaleY = 0.5;
		sprite.addChild(arrow);
		
		var bucks:Bitmap = new Bitmap(UserInterface.textures.fantsIcon);
		sprite.addChild(bucks);
		
		var number:TextField = Window.drawText(data.price3, {
			color:			0xcafe78,
			borderColor:	0x1a2f04,
			fontSize:		23
		});
		sprite.addChild(number);
		
		Load.loading(Config.getImageIcon('sales/image/', 'Calendar30'), function (data:*):void {
			calendar.bitmapData = data.bitmapData;
			calendar.x = 15;
			calendar.y = 10;
			
			arrow.x = calendar.x + calendar.width + 5;
			arrow.y = 25;
			
			bucks.x = arrow.x + arrow.width + 5;
			bucks.y = arrow.y - 10;
			
			number.x = bucks.x + bucks.width;
			number.y = arrow.y;
		});
		
		var desc:TextField = Window.drawText(action.text2, {
			color:			0xffd845,
			borderColor:	0x5c2b1a,
			fontSize:		21,
			multiline:		true,
			textAlign:		'center',
			textLeading:	-1
		});
		desc.wordWrap = true;
		desc.width = 210;
		desc.x -= 10;
		desc.y = 60;
		sprite.addChild(desc);
	}
	
	private function drawButton():void {
		buyBttn = new ImageButton(Window.texture('greenBttn'));
		buyBttn.x = 20;
		buyBttn.y = 345;
		addChild(buyBttn);
		
		var buyBttnText:TextField = Window.drawText(Payments.price(action.price[App.social]), {
			textAlign:		'center',
			autoSize:		'center',
			fontSize:		28,
			color:			0xfffa99,
			borderColor:	0x054f14,
			shadowSize:		1
		});
		buyBttn.width = 150;
		buyBttnText.x = (buyBttn.width - buyBttnText.width) / 2 + 5;
		buyBttnText.y = (buyBttn.height - buyBttnText.height) / 2;
		buyBttn.addChild(buyBttnText);
		
		if (App.isSocial('MX')) {
			var mxLogo:Bitmap = new Bitmap(UserInterface.textures.mixieLogo);
			mxLogo.scaleX = mxLogo.scaleY = 0.8;
			buyBttn.addChild(mxLogo);
			mxLogo.y = buyBttn.textLabel.y - (mxLogo.height - buyBttn.textLabel.height)/2;
			mxLogo.x = buyBttn.textLabel.x-10;
			buyBttn.textLabel.x = mxLogo.x + mxLogo.width + 5;
		}
		if (App.isSocial('SP')) {
				var spLogo:Bitmap = new Bitmap(UserInterface.textures.fantsIcon);
				buyBttn.addChild(spLogo);
				spLogo.y = buyBttn.textLabel.y - (spLogo.height - buyBttn.textLabel.height)/2;
				spLogo.x = buyBttn.textLabel.x-10;
				buyBttn.textLabel.x = spLogo.x + spLogo.width + 5;
			}
		
		buyBttn.addEventListener(MouseEvent.CLICK, onBuy);
	}
	
	private function onBuy(e:MouseEvent):void {
		if (e.currentTarget.mode == Button.DISABLED) return;
		//onBuyComplete();
		//return;
		
		window.blockButtons(true);
		
		Payments.buy( {
			type:			'promo',
			id:				action.id,
			price:			int(action.price[App.social]),
			count:			1,
			title: 			Locale.__e('flash:1382952379793'),
			description: 	Locale.__e('flash:1382952380239'),
			callback:		onBuyComplete,
			error:			function():void {
				window.close();
			},
			icon:			getIconUrl(action)
		});
	}
	
	private function onBuyComplete(e:* = null):void {
		window.blockButtons(false);
		
		// Открыть зону и убрать ее из списка зачисления на склад
		for (var s:String in action.items) {
			if (App.data.storage[s].type == 'Zones') {
				if (App.user.world.zones.indexOf(int(s)) < 0) {
					App.user.world.onOpenZone(0, { }, { sID:int(s), require:{} } );
				}
				delete action.items[s];
			}
		}
		
		App.user.stock.addAll(action.items);
		App.user.stock.addAll(action.bonus);
		
		for(var item:* in action.items) {
			var bonus:BonusItem = new BonusItem(item, action.items[item]);
			var point:Point = Window.localToGlobal(buyBttn);
				bonus.cashMove(point, App.self.windowContainer);
		}
		
		App.user.buyPromo(action.id);
		App.ui.salesPanel.createPromoPanel();
		
		window.close();
		
		new SimpleWindow( {
			label:SimpleWindow.ATTENTION,
			title:Locale.__e("flash:1382952379735"),
			text:Locale.__e("flash:1382952379990")
		}).show();
	}
	
	public function getIconUrl(promo:Object):String {
		if (promo.hasOwnProperty('iorder')) {
			var _items:Array = [];
			for (var sID:* in promo.items) {
				_items.push( { sID:sID, order:promo.iorder[sID] } );
			}
			_items.sortOn('order');
			sID = _items[0].sID;
		}else {
			sID = promo.items[0].sID;
		}
		
		return Config.getIcon(App.data.storage[sID].type, App.data.storage[sID].preview);
	}
}