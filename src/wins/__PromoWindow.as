package wins 
{
	import api.ExternalApi;
	import buttons.Button;
	import buttons.MenuButton;
	import buttons.MoneyButton;
	import core.Load;
	import core.Post;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import units.Hut;
	import wins.actions.PromoWindow;

	public class PromoWindow extends Window
	{
		private var items:Array = new Array();
		public var action:Object;
		private var container:Sprite;
		private var priceBttn:Button;
		private var timerText:TextField;
		private var descriptionLabel:TextField;
		
		public function PromoWindow(settings:Object = null)
		{
			if (settings == null) {
				settings = new Object();
			}
			
			action = App.data.promo[settings['pID']];
			action.id = settings['pID'];
			
			settings['width'] = 670 + 60;
			settings['height'] = 540;
						
			settings['title'] = Locale.__e("Акция");
			settings['hasPaginator'] = false;
			settings['hasButtons'] = false;
			settings['fontColor'] = 0xffcc00;
			settings['fontSize'] = 58;
			settings['fontBorderColor'] = 0x705535;
			settings['shadowBorderColor'] = 0x342411;
			settings['fontBorderSize'] = 8;
			
			settings.content = initContent(action.items);
			settings.bonus = initContent(action.bonus);
			
			settings['L'] = settings.content.length + settings.bonus.length;
			if (settings['L'] < 2) settings['L'] = 2;
			
			settings.width = 130 * settings['L'] + 130;
			super(settings);
		}
		
		private function initContent(data:Object):Array
		{
			var result:Array = [];
			for (var sID:* in data)
				result.push({sID:sID, count:data[sID], order:action.iorder[sID]});
			
			result.sortOn('order');
			return result;
		}
		
		private var axeX:int
		override public function drawBody():void {
			
			titleLabel.y -= 10;
			var text:String = Locale.__e("Уникальное предложение");
			
			var descriptionLabel:TextField = drawText(text, {
				fontSize:26,
				autoSize:"left",
				textAlign:"center",
				color:0xf0e6c1,
				borderColor:0x502f06
			});
			
			descriptionLabel.x = (settings.width - descriptionLabel.width) / 2;
			descriptionLabel.y = 25;
			descriptionLabel.width = settings.width - 80;
			
			bodyContainer.addChild(descriptionLabel);
			
			container = new Sprite();
			bodyContainer.addChild(container);
			container.x = 50;
			container.y = 60;
			
			
			if(settings['L'] <= 3)
				axeX = settings.width - 170;
			else
				axeX = settings.width - 190;
				
			drawImage();	
			
			contentChange();
			drawPrice();
			drawTime();
			
			
			
			App.self.setOnTimer(updateDuration);
		}
		
		private function drawImage():void {
			if(action.image != null && action.image != " " && action.image != ""){
				Load.loading(Config.getImage('promo/images', action.image), function(data:Bitmap):void {
					
					var image:Bitmap = new Bitmap(data.bitmapData);
					bodyContainer.addChildAt(image, 0);
					image.x = 20;
					image.y = 185;
					if (action.image == 'bigPanda') {
						image.x = -200;
						image.y = -20;
						//this.x += 100;
					}
				});
			}else{
				axeX = settings.width / 2;
			}
			
			var glowing:Bitmap = new Bitmap(Window.textures.actionGlow);
			bodyContainer.addChildAt(glowing, 0);
			
			glowing.alpha = 0.85;
			glowing.x = axeX - glowing.width/2;
			glowing.y = 265;
			glowing.smoothing = true;
			
			if (action.image == 'bigPanda') {
			
			}
			
			glowing.width = (settings.width - 100);
			glowing.x = 50;
			axeX = settings.width / 2;
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
			
			
			container.x = (settings.width - 130 * (settings.content.length + settings.bonus.length)) / 2;
		}
		
		override public function drawBackground():void {
			var background:Bitmap = backing(settings.width, settings.height, 50, "windowActionBacking");
			layer.addChild(background);
		}
		
		public function drawTime():void {
			
			var background:Bitmap = Window.backing(230, 130, 10, "itemBacking");
			bodyContainer.addChild(background);
			background.x = axeX - background.width/2;
			background.y = 240 - 10;
			
			descriptionLabel = drawText(Locale.__e('До конца акции:'), {
				fontSize:30,
				textAlign:"center",
				color:0xf0e6c1,
				borderColor:0x502f06
			});
			descriptionLabel.width = 230;
			descriptionLabel.x = axeX - background.width/2;
			descriptionLabel.y = background.y + 25;
			bodyContainer.addChild(descriptionLabel);
			
			var time:int = action.duration * 60 * 60 - (App.time - App.user.promo[action.id].started);
			//timerText = Window.drawText(TimeConverter.timeToCuts(time, true, true), {
			timerText = Window.drawText(TimeConverter.timeToStr(time), {
				color:0xf8d74c,
				letterSpacing:3,
				textAlign:"center",
				fontSize:34,//30,
				borderColor:0x502f06
			});
			timerText.width = 230;
			timerText.y = 305 - 10;
			timerText.x = background.x;
			bodyContainer.addChild(timerText);
		}
		
		public function drawPrice():void {
			
			var bttnSettings:Object = {
				caption:Locale.__e("Купить сейчас!"),
				fontSize:26,
				width:166,
				height:45,
				borderColor:[0xaff1f9, 0x005387],
				bgColor:[0x70c6fe, 0x765ad7],
				fontColor:0x453b5f,
				fontBorderColor:0xe3eff1
			};
			
			var text:String;
			switch(App.self.flashVars.social) {
				
				case "VK":
				case "DM":
						text = '[%d голос|%d голоса|%d голосов]';
					break;
				case "OK":
						text = '%d ОК';
						bttnSettings['borderColor'] = [0xffca8a, 0xc4690b];
						bttnSettings['fontColor'] = 0x3f2a1a;
						bttnSettings['bgColor'] = [0xfcbf1b, 0xe77402];//[0xff8c19, 0xe77402];
					break;	
				case "ML":
						text = '[%d мэйлик|%d мэйлика|%d мэйликов]';
						bttnSettings['borderColor'] = [0xffca8a, 0xc4690b];
						bttnSettings['fontColor'] = 0x3f2a1a;
						bttnSettings['bgColor'] = [0xfcbf1b, 0xe77402];//[0xff8c19, 0xe77402];
					break;
				case "PL":
						text = '%d';	
						bttnSettings['borderColor'] = [0xffca8a, 0xc4690b];
						bttnSettings['fontColor'] = 0x3f2a1a;
						bttnSettings['bgColor'] = [0xfcbf1b, 0xe77402];//[0xff8c19, 0xe77402];
					break;
				case "FB":
						var price:Number = action.price[App.self.flashVars.social];
						price = price * App.network.currency.usd_exchange_inverse;
						price = int(price * 100) / 100;
						text = price + ' ' + App.network.currency.user_currency;	
						
						bttnSettings['borderColor'] = [0xffca8a, 0xc4690b];
						bttnSettings['fontColor'] = 0x3f2a1a;
						bttnSettings['bgColor'] = [0xfcbf1b, 0xe77402];//[0xff8c19, 0xe77402];
					break;
			}
			
			priceBttn = new Button(bttnSettings);
			bodyContainer.addChild(priceBttn);
			
			priceBttn.x = axeX - priceBttn.width/2;
			priceBttn.y = settings.height - 135;
			
			priceBttn.addEventListener(MouseEvent.CLICK, buyEvent);
			
			var cont:Sprite = new Sprite();
			
			var text1:TextField = drawText(Locale.__e('Всего за'), {
				fontSize:24,
				textAlign:"left",
				color:0xf0e6c1,
				borderColor:0x502f06
			});
			text1.width = text1.textWidth + 5;
			text1.x = 0;
			cont.addChild(text1);
			text1.height = text1.textHeight;
			
				
			var text2:TextField = Window.drawText(Locale.__e(text,[int(action.price[App.self.flashVars.social])]), {
				color:0xf8d74c,
				textAlign:"left",
				fontSize:24,
				borderColor:0x502f06
			});
			text2.width = text2.textWidth + 5;
			text2.x = text1.x + text1.width + 4;
			cont.addChild(text2);
			text2.height = text2.textHeight;
	
			switch(App.self.flashVars.social) {
				case "PL":
					var crystals:Bitmap = new Bitmap(new BitmapData(32, 32, true, 0));
					var obj:Object = App.data.storage[Stock.FANT];
					cont.addChild(crystals);
					crystals.x = text2.x + text2.width + 4;
					Load.loading(Config.getIcon(obj.type, obj.view), function(data:*):void {
						crystals = data;
						cont.addChild(crystals);
						crystals.scaleX = crystals.scaleY = 0.5;
						crystals.smoothing = true;
						crystals.x = text2.x + text2.width + 4;
						crystals.y = (cont.height - crystals.height) / 2 - 8;
					});
					break;
				default: 
					break;
			}
			
			bodyContainer.addChild(cont);
			cont.x = priceBttn.x + priceBttn.width / 2 - cont.width / 2;
			cont.y = priceBttn.y - 30;
		}
		
		private function buyEvent(e:MouseEvent):void
		{
			if (e.currentTarget.mode == Button.DISABLED) return;
			
			//descriptionLabel.visible = false;
			//timerText.visible = false;
			switch(App.social) {
				case 'PL':
					if(App.user.stock.take(Stock.FANT, action.price[App.social])){
						Post.send({
							ctr:'Promo',
							act:'buy',
							uID:App.user.id,
							pID:action.id,
							ext:App.social
						},function(error:*, data:*, params:*):void {
							onBuyComplete();
						});
					}
					break;
				default:
					var object:Object;
					if (App.social == 'FB') {
						object = {
							id:		 		action.id,
							type:			'promo',
							title: 			action.title,
							description: 	action.description,
							callback:		onBuyComplete
						};
					}else{
						object = {
							count:			1,
							money:			'promo',
							type:			'item',
							item:			'promo_'+action.id,
							votes:			int(action.price[App.self.flashVars.social]),
							title: 			action.title,
							description: 	action.description,
							callback: 		onBuyComplete
						}
					}
					ExternalApi.apiPromoEvent(object);
					break;
			}
		}
		
		private function onBuyComplete(e:* = null):void 
		{
			priceBttn.state = Button.DISABLED;
			 App.user.stock.addAll(action.items);
			 App.user.stock.addAll(action.bonus);
			
			for each(var item:ActionItem in items) {
				var bonus:BonusItem = new BonusItem(item.sID, item.count);
				var point:Point = Window.localToGlobal(item);
					bonus.cashMove(point, App.self.windowContainer);
			}
			
			App.user.promo[action.id].status = 1;
			App.ui.leftPanel.createPromoPanel();
			
			close();
			
			new SimpleWindow( {
				label:SimpleWindow.ATTENTION,
				title:Locale.__e("Поздравляем!"),
				text:Locale.__e("Все купленные товары теперь на складе.")
			}).show();
		}
		
		private function updateDuration():void {
			var time:int = action.duration * 60 * 60 - (App.time - App.user.promo[action.id].started);
				timerText.text = TimeConverter.timeToStr(time);
			
			if (time <= 0) {
				descriptionLabel.visible = false;
				timerText.visible = false;
			}
		}
		
		public override function dispose():void
		{
			for each(var _item:ActionItem in items)
			{
				_item = null;
			}
			
			App.self.setOffTimer(updateDuration);
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
import ui.UserInterface;
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
			
			var backType:String = 'itemBacking';
			//if (!bonus)
			//	backType = 'bonusBacking'
			
			background = Window.backing(130, 160, 10, backType);
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
			//background.filters = [new GlowFilter(0xFFFF00, 0.6, 25, 25, 4, 1, true)];
			
			var bonusLabel:Sprite = Window.titleText( {
					title				: Locale.__e('Бонус!'),
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
			
			//UserInterface.colorize(background, 0xb63718, 0.3);
			UserInterface.effect(background, 0, 2);
		}
		
		public function onPreviewComplete(data:Bitmap):void
		{
			removeChild(preloader);
			
			bitmap.bitmapData = data.bitmapData;
			bitmap.scaleX = bitmap.scaleY = 0.8;
			bitmap.smoothing = true;
			bitmap.x = (background.width - bitmap.width)/ 2;
			bitmap.y = (background.height - bitmap.height)/ 2 - 10;
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
			var countText:TextField = Window.drawText(String(count)+Locale.__e(" шт."), {
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
