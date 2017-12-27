package wins 
{
	import buttons.Button;
	import core.Load;
	import core.Size;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import silin.filters.ColorAdjust;
	/**
	 * ...
	 * @author ...
	 */
	public class TripleSaleWindow extends Window
	{
		private static var _data:Object;
		private static var choose:int = 0;
		private static var buyed:Array = [];
		private static var free:Array = [];
		private var aID:int;
		private var action:Object;
		private var items:Vector.<TripleActionItem> = new Vector.<TripleActionItem>;
		private var itemsCont:Sprite = new Sprite();
		private var desLabel:TextField;
		private var textTitleLabel:TextField;
		private var textLabel:TextField;
		private var promoImage:Bitmap;
		private var promoBacking:Shape = new Shape();
		private var separator1:Bitmap;
		private var separator2:Bitmap;
		private var promoCont:Sprite = new Sprite();
		private var timerLabel:TextField;
		private var timerTitleLabel:TextField;
		private var bottomLabel:TextField;
		private var timerBack:Bitmap;
		private var buyBttn:Button;
		private var colorAdjust:ColorAdjust;
		private var defaultSetts:Object = {
			background:		"xmasBacking",
			titleDecoration:'xmasDec',
			title:			Locale.__e('flash:1382952379793'),
			description:	Locale.__e('flash:1482232694117'),
			textTitle:		Locale.__e('flash:1482232835130'),
			text:			Locale.__e('flash:1482232753466'),
			timerLabel:		Locale.__e('flash:1393581955601'),
			bottomText:		Locale.__e('flash:1482232796289'),
			hasPaginator:	false,
			width:			690,
			height:			590,
			promoW:			350,
			promoBW:		655,
			promoH:			160
		};
		public function TripleSaleWindow(settings:Object )
		{
			aID = settings['pID'];
			action = App.data.actions[aID];
			action.id = aID;
			for (var property:* in defaultSetts) {
				settings[property] = defaultSetts[property];
			}
			super(settings);
		}
		//////// -->>>>
		//////// Управление акциими и их отображением
		////////
		private static function get data():Object
		{
			if (!_data)
			{
				try{
					_data = JSON.parse(App.data.options.PromoLink);
				}catch (e:*)
				{
					return {};
				}
			}
			return _data;
		}
		/** Храним купленые акции 
		*/
		public static function updateBuyed(pIDs:Object):void
		{
			for (var key:String in data)
			{
				if ( data[key].window == 'TripleSaleWindow' && data[key].params
						&& data[key].params.pIDs && data[key].params.pIDs.indexOf(int(key)) != -1)
				{
					if (pIDs.hasOwnProperty(key) && pIDs[key].buy)
						buyed.push(int(key));
					else
						free.push(int(key));
				}
			}
		}
		/** Пропускаем все открытые в данный момент акции из подгруппы кроме одной 
		 * обновить инфу о купденых необходимо до выполнения этой функции
		*/
		public static function continueAction(pID:int, pIDs:Object):Boolean
		{
			if (data.hasOwnProperty(String(pID)) && data[pID].window == 'TripleSaleWindow' && data[pID].params
						&& data[pID].params.pIDs && data[pID].params.pIDs.indexOf(int(pID)) != -1)
			{
				if (!choose)
				{
					choose = free[int (Math.random() * free.length)];
				}
				if (choose != pID)
					return true;
				return false;
			}
			return false;
		}
		public static function showSale(pID:int):Boolean
		{
			if ( data.hasOwnProperty(String(pID)) && data[pID].window == 'TripleSaleWindow')
			{
				new TripleSaleWindow({pID:pID}).show();
				return true;
			}
			return false;
		}
		/** Возвращаем адресс картинки которую нужно подгрузить в иконки акций
		*/
		public static function saleIconPath(pID:int):String
		{
			if (data.hasOwnProperty(String(pID)) && data[pID].window == 'TripleSaleWindow' && data[pID].params
				&& data[pID].params.icon)
					return Config.getImage('sales/image',data[pID].params.icon);
			return null;
		}
		//////// --<<<<<
		//////
		
		override public function drawBody():void 
		{
			super.drawBody();
			drawDescription();
			drawItems();
			drawPromo();
			drawTimer();
			drawButton();
			bottomLabel = Window.drawText(settings.bottomText,{
				fontSize		:31,
				color			:0xffffff,
				borderColor		:0x095960,
				textAlign		:"center",
				width			:settings.width - 140
			});
			bottomLabel.x = (settings.width - bottomLabel.width) * 0.5;
			bottomLabel.y = settings.height - bottomLabel.height - 95;
			bodyContainer.addChild(bottomLabel);
			exit.x += 5;
			exit.y -= 20;
		}
		/** Получаем элемент который мы получим за покупку этой акции
		*/
		private function actionGolden(pID:int):int
		{
			var actionInfo:Object = App.data.actions[pID];
			for (var re:String in actionInfo.items)
			{
				return int(re);
			}
			return 0;
		}
		private function drawDescription():void
		{
			desLabel = Window.drawText(settings.description,{
				fontSize		:27,
				color			:0xffffff,
				borderColor		:0x095960,
				textAlign		:"center",
				width			:settings.width - 140
			});
			desLabel.x = (settings.width - desLabel.width) * 0.5;
			desLabel.y = 35;
			bodyContainer.addChild(desLabel);
		}
		private function drawItems():void
		{
			if (!colorAdjust)
				colorAdjust = new ColorAdjust();
			colorAdjust.saturation(0);
			clearItems();
			var border:int = -16;
			var dX:int = 0;
			for each(var ins:String in data[aID].params.pIDs)
			{
				// отбращамся к сиду обьекта который в акции из списка смежных акций, так же подставляем соответсвтующие изображения
				var item:TripleActionItem = new TripleActionItem(actionGolden(int(ins)), data[ins].params.image);
				if (buyed.indexOf(ins) != -1)
					item.filters = [colorAdjust.filter];
				itemsCont.addChild(item);
				item.x = dX;
				dX += TripleActionItem.W + border;
				items.push(item);
			}
			itemsCont.x = (settings.width - (TripleActionItem.W + border)* items.length) * 0.5;
			itemsCont.y = 50;
			if (!itemsCont.parent)
				bodyContainer.addChild(itemsCont);
		}
		private function clearItems():void
		{
			for each (var ins:TripleActionItem in items)
			{
				ins.dispose ();
				if (ins.parent)
					ins.parent.removeChild(ins);
			}
			items.length = 0;
		}
		private function drawPromo():void
		{
			const margin:int = 35;
			if (!promoCont.parent)
				bodyContainer.addChild(promoCont);
			
			promoBacking.graphics.beginFill(0x71d9ff, 0.3);
			promoBacking.graphics.drawRect(0, 0, settings.promoBW - margin, settings.promoH);
			promoBacking.graphics.endFill();
			promoBacking.alpha = 0.8;
			promoCont.addChild (promoBacking);
			separator1 = backingShort( promoBacking.width, 'dividerLineBlue');
			separator2 = backingShort( promoBacking.width, 'dividerLineBlue');
			promoCont.addChild(separator1);
			promoCont.addChild(separator2);
			textTitleLabel = Window.drawText(settings.textTitle,{
				fontSize		:31,
				color			:0xffdd00,
				borderColor		:0x70492c,
				textAlign		:"center",
				width			:settings.promoW
			});
			textTitleLabel.width = textTitleLabel.textWidth + 5;
			textTitleLabel.x = settings.width - settings.promoW - margin - 20 + (settings.promoW - textTitleLabel.width) * 0.5;
			promoCont.addChild(textTitleLabel);
			textLabel = Window.drawText(settings.text,{
				fontSize		:21,
				color			:0x2a787f,
				borderColor		:0xffffff,
				textAlign		:"center",
				width			:settings.promoW,
				multiline		:true,
				wrap			:true
			});
			promoBacking.x = margin;//settings.width - promoBacking.width - margin;
			promoBacking.y = textTitleLabel.y + textTitleLabel.height - 10;
			separator1.x = promoBacking.x;
			separator1.y = promoBacking.y - separator1.height;
			separator2.x = promoBacking.x;
			separator2.y = promoBacking.y + promoBacking.height;
			textLabel.height = textLabel.textHeight + 5; // загадочно работающий autoSize меня смутил
			textLabel.x = settings.width - settings.promoW - margin - 20;
			textLabel.y = promoBacking.y + (settings.promoH - textLabel.height) * 0.5 + 8;
			promoCont.addChild(textLabel);
			promoImage = new Bitmap();
			promoCont.addChild(promoImage);
			Load.loading(saleIconPath(aID), onPromoIconLoad);
			promoCont.y = itemsCont.y + TripleActionItem.H + 10;
			drawMirrowObjs('xmasDec', promoCont.x + textTitleLabel.x - 95, promoCont.x + textTitleLabel.x + textTitleLabel.width + 95, promoCont.y + textTitleLabel.y - 5);
		}
		private function onPromoIconLoad(loadData:*):void
		{
			if (promoImage)
			{
				promoImage.bitmapData = loadData.bitmapData;
				promoImage.x = 40;
				promoImage.y = promoBacking.y + ( promoBacking.height - promoImage.height) * 0.5 - 15;
			}
		}
		private function get actionTime():int // Очень внимательно. Выходит что в каждой акции нужно указать одинаковое время 
		{
			return (action.time + action.duration * 3600) - App.time;
		}
		private function drawTimer():void // Не исспользуем TimerUnit ибо он очень спецефичен и для переноса не годится
		{
			timerBack = new Bitmap(Window.texture('actionGlow'));
			timerBack.x = 40;
			timerBack.y = 10;
			Size.size(timerBack, 120, 90);
			timerBack.smoothing = true;
			bodyContainer.addChild(timerBack);
			timerTitleLabel = Window.drawText(settings.timerLabel,{
				fontSize		:26,
				color			:0xfff7d2,
				borderColor		:0x712b15,
				textAlign		:"center",
				width			:130
			});;
			timerTitleLabel.x = timerBack.x - 10;
			timerTitleLabel.y = timerBack.y + 14;
			timerLabel = Window.drawText(TimeConverter.timeToStr(actionTime),{
				fontSize		:28,
				color			:0xffe979,
				borderColor		:0x841300,
				textAlign		:"center",
				width			:130
			});
			bodyContainer.addChild(timerTitleLabel);
			bodyContainer.addChild(timerLabel);
			timerLabel.x = timerTitleLabel.x;
			timerLabel.y = timerTitleLabel.y + timerTitleLabel.height -7;
			App.self.setOnTimer(timerUpdate);
			timerUpdate();
		}
		private function timerUpdate():void
		{
			if (actionTime < 0)
				close();
			timerLabel.text = TimeConverter.timeToStr(actionTime);
		}
		private function drawButton():void
		{
			buyBttn = new Button( {
				width:				175,
				height:				50,
				caption:			Payments.price(action.price[App.social]),
				fontColor:			0xfffeff,
				fontBorderColor:	0x814e33,
				shadow:				true
			});
			buyBttn.x = (settings.width - buyBttn.width) * 0.5;
			buyBttn.y = settings.height - buyBttn.height * 0.5 - 60;
			bodyContainer.addChild(buyBttn);
			buyBttn.addEventListener(MouseEvent.CLICK, buyEvent);
		}
		private function buyEvent(e:MouseEvent):void
		{
			
			if (buyBttn.mode == Button.DISABLED) return;
			buyBttn.state = Button.DISABLED;
			
			var description:String = Locale.__e('flash:1382952380239');
			if (App.social == 'YB') {
				description = '';
				var _sid:String;
				for (_sid in action.items) {
					description += String(action.items[_sid]) + App.data.storage[_sid].title+'\n';
				}
				for (_sid in action.bonus) {
					description += String(action.bonus[_sid]) + App.data.storage[_sid].title+'\n';
				}
			}
			
			Payments.buy( {
				type:			'promo',
				id:				action.id,
				price:			int(action.price[App.social]),
				count:			1,
				title: 			Locale.__e('flash:1382952379793'),
				description: 	description,
				callback:		onBuyComplete,
				error:			function():void {
					close();
				},
				icon:			Config.getImage('sales/image',settings.promoIcon)
			});
		}
		private function onBuyComplete(e:* = null):void {
			choose = 0;
			buyed.length = 0;
			free.length = 0;
			buyBttn.state = Button.NORMAL;
			
			if (action.hasOwnProperty("items") && action.items)
				App.user.stock.addAll(action.items);
			if (action.hasOwnProperty("bonus") && action.bonus)
				App.user.stock.addAll(action.bonus);
			action.buy = 1;
			App.user.buyPromo(action.id);
			App.user.updateActions();
			App.ui.salesPanel.createPromoPanel();
			
			
			close();
			
			new SimpleWindow( {
				label:SimpleWindow.ATTENTION,
				title:Locale.__e("flash:1382952379735"),
				text:Locale.__e("flash:1382952379990")
			}).show();
		}
		override public function dispose():void 
		{
			super.dispose();
			clearItems();
			App.self.setOffTimer(timerUpdate);
			if (buyBttn)
				buyBttn.removeEventListener(MouseEvent.CLICK, buyEvent);
		}
	}
}
import core.Load;
import core.Size;
import flash.display.Bitmap;
import wins.Window;
internal class TripleActionItem extends LayerX
{
	private var sid:int = 0;
	private var icon:Bitmap;
	public static const W:int = 195;
	public static const H:int = 195;
	public function TripleActionItem (sid:int, iconPath:String)
	{
		this.sid = sid;
		tip = function():Object { 
			return {
				title:App.data.storage[sid].title,
				text:App.data.storage[sid].description
			};
		};
		icon = new Bitmap();
		addChild(icon);
		Load.loading(Config.getImage('sales/image',iconPath),onLoad);
	}
	private function onLoad(data:*):void
	{
		if ( icon )
		{
			icon.bitmapData = data.bitmapData;
			//Size.size(icon, W, H); 
			icon.scaleX = icon.scaleY = 0.8;
			icon.smoothing = true;
			//icon.x = (W - icon.width) * 0.5;
			icon.y = H - icon.height;
		}
	}
	public function dispose():void
	{
		icon = null;
		removeChildren();
	}
}