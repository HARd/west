package wins 
{
	import api.ExternalApi;
	import buttons.Button;
	import buttons.MenuButton;
	import core.Load;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;

	public class BankWindow extends Window
	{
		
		public static const MONEY:int = 2;
		public static const SETS:int = 4;
		
		public static var history:Object = {section:MONEY,page:0};
		
		public var items:Array = new Array();
		public var sets:Array = new Array();
		public var dataList:Array = new Array();
		public var icons:Array = new Array();
		public var moneyLayer:Sprite = new Sprite();
		public var setsLayer:Sprite = new Sprite();
		
		public function BankWindow(settings:Object = null) 
		{
			if (settings == null) {
				settings = new Object();
			}
			
			settings['width'] = 680;
			settings['title'] = Locale.__e("flash:1382952379979")
			settings['section'] = settings.section || MONEY;
			settings['hasPaginator'] = true;
			settings['hasButtons'] = false;
			settings['itemsOnPage'] = 6;
			settings['popup'] = true;
			settings['hasMenu'] = true;
			
			//settings["background"] = "questsSmallBackingTopPiece";//"questsMainBacking";
			
			settings.content = initContent();
			
			var setslength:int = 0;
			if (App.data['sets'] != undefined) {
				for each(var sets:Object in App.data.sets) {
					setslength++;
				}
			}
			
			if (setslength > 0 && App.social != 'YB') {
				settings['height'] = 518;
				settings['hasMenu'] = true;
			}
			else
			{
				settings['height'] = 490;
				settings['hasMenu'] = false;
				//Ys = 50;
			}
			
			if (App.social == 'FB') 
			{
				settings['height'] = 640;//570 + 25;
				//settings['hasMenu'] = false;
				//Ys = 50;
			}
			
			super(settings);
			//SoundsManager.instance.playSFX("window")
		}
		
		override public function drawBackground():void {
				
			var background:Bitmap = backing2(settings.width, settings.height, 40, "questsSmallBackingTopPiece", "questsSmallBackingBottomPiece");
			layer.addChild(background);
		}
		
		private function initContent():Array{
			var item:*
			var result:Array = [];
			for (var id:* in App.data.sets){
				item = App.data.sets[id];
				if (item.price[App.social] == undefined)
					continue;
				item['id'] = id;
				result.push(item);
			}
			result.sortOn('id');
			return result;
		}
		
		override public function drawBody():void {
			dataList = createData();
			bodyContainer.addChild(moneyLayer);
			bodyContainer.addChild(setsLayer);
			drawItems();
			if(settings['hasMenu']) drawMenu();
			setContentSection(settings.section);
			
			if (App.data.money.date_to > App.time && App.data.money.enabled) {
				drawTimer();
				App.self.setOnTimer(updateDuration);
			}
			
			if (App.social == 'FB') 
			{
				var lable1:Bitmap = new Bitmap();
				Load.loading(Config.getImage('money', 'secure_logos'), function(data:Bitmap):void {
					lable1.bitmapData = data.bitmapData;
					lable1.x = 65;
					lable1.y = settings.height - 100 - lable1.height/2;
				});
				
				var lable2:Bitmap = new Bitmap();
				Load.loading(Config.getImage('money', 'secure_lock'), function(data:Bitmap):void {
					lable2.bitmapData = data.bitmapData;
					lable2.x = settings.width - 65 - lable2.width;
					lable2.y = settings.height - 100 - lable2.height/2;
				});
				
				bodyContainer.addChild(lable1);
				bodyContainer.addChild(lable2);
				
				var giftcardBttn:Button = new Button( {
					borderColor:[0xf8f2bd, 0x836a07],
					bgColor:[0xA9DC3C, 0x96C52E],
					fontColor:0x4E6E16,
					fontBorderColor:0xDCFA9B,
					width:		140,
					height:		36,
					fontSize:	24,
					caption:	Locale.__e("flash:1384446450818")
				});				
				bodyContainer.addChild(giftcardBttn);
				giftcardBttn.x = 60;
				giftcardBttn.y = 36;
				giftcardBttn.addEventListener(MouseEvent.CLICK, ExternalApi.onReedem);
			}
			
			drawMirrowObjs('diamondsTop', settings.width / 2 - settings.titleWidth / 2 - 5, settings.width / 2 + settings.titleWidth / 2 + 5, -45, true, true);
			drawMirrowObjs('diamonds', -30, settings.width + 30, settings.height - 115);
			
		}
		
		
		
		private function updateDuration():void {
			var time:int = App.data.money.date_to - App.time;
			timerText.text = TimeConverter.timeToStr(time);
			
			if (time <= 0) {
				timerText.visible = false;
				close();
			}
		}
			
		private var timerText:TextField;
		public function drawTimer():void {
		
			var glowing:Bitmap = new Bitmap(Window.textures.actionGlow);
			bodyContainer.addChild(glowing);
			glowing.smoothing = true;
			glowing.alpha = .85;
			glowing.scaleX = glowing.scaleY = 0.6;
			glowing.rotation = -30;
			glowing.x = -35;
			glowing.y = 5;
			
			var title:Sprite = titleText({
				title:Locale.__e('flash:1382952379793'),
				color:0xffffff,
				fontSize:53,
				borderColor:0x7a4004,
				borderSize:8
			});
			
			bodyContainer.addChild(title);
			title.x = 5;
			title.y = 15;
			title.rotation = -30;
			
			var time:int = App.data.money.date_to - App.time;
			
			timerText = Window.drawText(TimeConverter.timeToStr(time), {
				color:0xf6f1df,
				letterSpacing:0,
				textAlign:"center",
				fontSize:26,
				borderColor:0x817043,
				borderSize:6
			});
			
			timerText.width = 230;
			timerText.y = 84;
			timerText.x = -20;
			timerText.rotation = -30
			bodyContainer.addChild(timerText);
		}
		
		public function drawMenu():void {
			
			var menuSettings:Object = {
				2: 	{ order:1,	title:Locale.__e("flash:1382952379980") },
				4: 	{ order:2,	title:Locale.__e("flash:1382952379981") }
			}
			
			for (var item:* in menuSettings) {
				var settings:Object = menuSettings[item];
				settings['type'] = item;
				settings['onMouseDown'] = onMenuBttnSelect;					
				settings['width'] = 120;					
				settings['fontSize'] = 26;					
				icons.push(new MenuButton(settings));
			}
			icons.sortOn("order");
	
			var sprite:Sprite = new Sprite();
			
			var offset:int = 0;
			for (var i:int = 0; i < icons.length; i++)
			{
				icons[i].x = offset;
				//icons[i].y = 30;
				offset += icons[i].settings.width + 10;
				sprite.addChild(icons[i]);
			}
			bodyContainer.addChild(sprite);
			sprite.x = (this.settings.width - sprite.width) / 2 + 8;
			sprite.y = 34;
		}
		
		private function onMenuBttnSelect(e:MouseEvent):void
		{
			e.currentTarget.selected = true;
			setContentSection(e.currentTarget.type, history.page);
		}	
		
		public function setContentSection(section:*, page:Number = 0):Boolean
		{
			for each(var icon:MenuButton in icons) {
				icon.selected = false;
				if (icon.type == section) {
					icon.selected = true;
				}
			}
			
			
			settings.section = section;
			if (settings.section == MONEY) {
				moneyLayer.visible = true;
				setsLayer.visible = false;				
				
				paginator.itemsCount = 1;
				paginator.onPageCount = 1;
				paginator.update();
								
			}else {
				moneyLayer.visible = false;
				setsLayer.visible = true;
				
				paginator.itemsCount = settings.content.length;
				paginator.onPageCount = settings.itemsOnPage;
				paginator.page = page;
				paginator.update();
				contentChange();
			}
			history.section = section;
			history.page = page;
			return true;
		}
		
		override public function drawArrows():void {
			super.drawArrows();
			paginator.arrowLeft.y -= 25;
			paginator.arrowRight.y -= 25;
		}
		
		public function createData():Array
		{
			var spisok:Array = []
			
			return spisok;
		}
		
		
		
		private var Xs:int = 41;
		private var Ys:int = 0;
		override public function contentChange():void {
		
			for each(var _item:SetItem in sets)
			{
				setsLayer.removeChild(_item);
				_item.dispose();
				_item = null;
			}
			
			sets = [];
			
			//var Xs:int = 50;
			//var Ys:int = 85;
			
			var itemNum:int = 0;
			for (var i:int = paginator.startCount; i < paginator.finishCount; i++){
				var item:SetItem = new SetItem(settings.content[i], this, i);
				
				setsLayer.addChild(item);
				item.x = Xs;
				item.y = Ys;
								
				sets.push(item);
				Xs += item.background.width + 10;
				itemNum++;
				
				if (itemNum == 2 || itemNum == 4) {
					Ys += item.height;
					Xs = 50;
				}
			}
		}
		
		public function drawItems():void{
			var Y:int = Ys;
			var X:int = Xs;
			
			for (var i:int = 0; i < 12; i++){
				var type:String;
				var obj:Object;
				var id:int;
				
				if (i < 6){
					type = "coins";
					obj = App.data.money.coins[i];
					id = i;
				}else{
					type = "reals";
					obj = App.data.money.reals[i - 6];
					id = i - 6;
				}
				
				var item:BankItem = new BankItem(type, obj, id);
				item.x = X;
				item.y = Y;
					
				moneyLayer.addChild(item);
					
				items.push(item);
				Y += item.background.height;
				
				if (i == 5){
					Y = Ys;
					X += 301 ;
				}
			}
		}
		
		public override function dispose():void
		{
			for (var i:int = 0; i < 12; i++)
			{
				items[i].dispose()
			}
			App.self.setOffTimer(updateDuration);
			super.dispose()
		}
		
	}
}


import api.ExternalApi;
import buttons.Button;
import com.greensock.easing.Elastic;
import com.greensock.TweenLite;
import core.Load;
import core.Numbers;
import core.Post;
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.filters.GlowFilter;
import flash.geom.Point;
import flash.text.TextField;
import flash.utils.setTimeout;
import ui.UserInterface;
import wins.Window;
import wins.SimpleWindow;

internal class BankItem extends Sprite{
	
	public var background:Bitmap;
	public var icon:Bitmap;
	public var buyBttn:Button;
	public var text1:TextField;
	public var text2:TextField;
	public var text3:TextField;
	
	public var cont:Sprite;
	
	
	public var buyObject:Object;
	
	public function BankItem(type:String, obj:Object, id:int)
	{
		buyObject = {
			type: type,
			count:	0, 
			votes:	obj.cost,
			extra:  obj.extra,
			id:		id,
			extra:	0
		};
		//background = Window.backing2(300, 70, 10, "questsSmallBackingTopPiece", "questsSmallBackingBottomPiece");
		background = Window.backing2(300, 70, 10, "cursorsPanelBg", "cursorsPanelBg2");
		
		addChild(background);
		
		cont = new Sprite();
		
		
		function roundTo(value:Number): Number{
			return int(value*100)/100;
		}
		if (App.social == 'FB') {
			obj.text = Locale.__e('flash:1382952379984') + ' ' + roundTo(App.network.currency.usd_exchange_inverse * obj.cost) + ' ' + App.network.currency.user_currency;
		}
			
		if (type == "coins")
		{
			buyObject.count = obj.count
			icon = new Bitmap(UserInterface.textures.coinsIcon)
			
			buyBttn = new Button( {
				width:					70,
				height:					36,
				fontSize:				24,
				caption:				Locale.__e("flash:1382952379751")
			})
			
			text1 = Window.drawText(Numbers.moneyFormat(obj.count), {
				fontSize	:24,
				color		:0xffdc39,
				borderColor	:0x6d4b15,
				autoSize	:"left"
			});
			
			text2 = Window.drawText(obj.text, {
				fontSize:22,
				color:0x4a401f,
				border:false,
				autoSize:"left"
			});
			
			if(obj.extra > 0 && App.data.money.enabled && (App.data.money.date_to - App.time > 0)){
				text3 = Window.drawText('+'+Numbers.moneyFormat(obj.extra), {
					fontSize	:19,
					//color		:0xffdc39,
					//borderColor	:0x6d4b15,
					color		:0xd4f1f9,
					borderColor	:0x0f776a,
					autoSize	:"left"
				});
			}



		}
		else
		{
			buyObject.count = obj.count;
			icon = new Bitmap(UserInterface.textures.fantsIcon);
			
			buyBttn = new Button( {
				width:					70,
				height:					36,
				caption:				Locale.__e("flash:1382952379751"),
				bgColor: [0xa9f84a, 0x73bb16],//[0xf5cf56, 0xf1b733];	  [0x8dd529, 0x6e9e2d];
				borderColor: [0xffffff, 0xffffff],//[0x9d6249, 0x9d6249];    [0x94F58B, 0x13820B];
				bevelColor:[0xc5fe78, 0x405c1a],//[0xfff270, 0xca7d00];	
				fontColor: 0xffffff,				
				fontBorderColor: 0x354321,
				fontSize:22,
				radius:12
			})
							
			text1 = Window.drawText(Numbers.moneyFormat(obj.count), {
				fontSize	:24,
				color		:0xa1d435,
				borderColor	:0x38510d,
				autoSize	:"left"
			});
							
		//	var parts:Array = obj.text.split(" ");					
		//	var golosText:String = Locale.__e("flash:1382952379985", [Number(parts[1])]);					
								
			text2 = Window.drawText(obj.text,{
				fontSize:22,
				color:0x4a401f,
				border:false,
				autoSize:"left"
			});
			
			if(obj.extra > 0 && App.data.money.enabled && (App.data.money.date_to - App.time > 0)){
				text3 = Window.drawText('+'+Numbers.moneyFormat(obj.extra), {
					fontSize	:19,
					//color		:0xa1d435,
					//borderColor	:0x38510d,
					color		:0xd4f1f9,
					borderColor	:0x0f776a,
					autoSize	:"left"
				});
			}
		}
			
		icon.x = 10;
		icon.y = (background.height - icon.height) / 2;
		
		addChild(icon);
		addChild(buyBttn);
		cont.addChild(text1);
		cont.addChild(text2);
		
		addChild(cont);
		
		cont.x = icon.x + icon.width + 5;
		cont.y = (background.height - cont.height) / 2 - 7;
		text2.y = text1.textHeight - 2;
		
		if (App.social == 'YB' && type == 'coins') {
			var fantsIcon:Bitmap = new Bitmap(UserInterface.textures.fantsIcon);
			fantsIcon.scaleX = fantsIcon.scaleY = 0.6;
			fantsIcon.smoothing = true;
			cont.addChild(fantsIcon);
			fantsIcon.x = text2.x + text2.width ;
			fantsIcon.y = text2.y;
		}
		
		
		buyBttn.x = background.width - buyBttn.width - 14;
		buyBttn.y = (background.height - buyBttn.height) / 2 + 1;
		buyBttn.addEventListener(MouseEvent.CLICK, buyEvent);
		
		if (obj.best == 1) {
			var moneyLabel:Bitmap = new Bitmap(Window.textures.moneyLabel);
			moneyLabel.smoothing = true;
			addChild(moneyLabel);
			moneyLabel.x = 276;
			moneyLabel.y = 9;
		}
		
		if (text3 != null) {
			bonusCont = new Sprite();
			bonusCont.addChild(text3);
			bonusCont.x = buyBttn.x - bonusCont.width - 4;
			bonusCont.y = 6;
			bonusCont.filters = [new GlowFilter(0xd4f1f9, 1, 16, 16)];
			addChild(bonusCont);
		}
		
		if (type != "coins")//App.social == 'FB' && 
		{
			if (id == 0) {
				var _label1:MoneyLabel = new MoneyLabel(BEST_DEAL);
				addChild(_label1);
				_label1.x = 276+5;
				_label1.y = 9 + 7;
				setTimeout(function():void {
					TweenLite.to(_label1, 2, {rotation: -40, ease:Elastic.easeOut } );
				}, 200);
			}
			
			if (id == 2) {
				var _label2:MoneyLabel = new MoneyLabel(USER_CHOICE);
				addChild(_label2);
				_label2.x = 276+5;
				_label2.y = 9 + 7;
				setTimeout(function():void {
					TweenLite.to(_label2, 2, {rotation: -40, ease:Elastic.easeOut } );
				}, 200);
			}
		}
	}
	
	private var bonusCont:Sprite;
	public function dispose():void
	{
		buyBttn.removeEventListener(MouseEvent.CLICK, buyEvent);
	}
	
	public static const BEST_DEAL:String = 'bd';
	public static const USER_CHOICE:String = 'uc';
	
	private function buyEvent(e:MouseEvent):void
	{
		var object:Object;
		if (App.social == 'YB' || App.social == 'GN') {
			
			if (buyObject.type == 'coins') {
				if(App.user.stock.take(Stock.FANT, buyObject.votes)){
					
					var point:Point = Window.localToGlobal(buyBttn);
					
					Post.send({
						'ctr':'stock',
						'act':'coins',
						'uID':App.user.id,
						'cID':buyObject.id
					}, function(error:*, result:*, params:*):void {
						if (error) {
							Errors.show(error, result);
							return;
						}
						var count:int = buyObject.count + ((App.data.money.enabled && App.data.money.date_to > App.time)?buyObject.extra:0);
						
						var item:BonusItem = new BonusItem(Stock.COINS, count);
						item.cashMove(point, App.self.windowContainer);
						
						
						App.user.stock.put(Stock.COINS, result[Stock.COINS] || App.user.stock.count(Stock.COINS));
					});
				}
				return;
			}
			
			object = {
				id:		 	buyObject.type+'_'+buyObject.id,
				price:		buyObject.votes,
				type:		buyObject.type,
				count: 		buyObject.count + ((App.data.money.enabled && App.data.money.date_to > App.time)?buyObject.extra:0)
			};
		}else if (App.social == 'FB') {
			object = {
				id:		 	buyObject.id,
				type:		buyObject.type
			};
		}else{
			object = {
				money: buyObject.type,
				type:	'item',
				item:	buyObject.type+'_'+buyObject.id,
				votes:	buyObject.votes,
				count: 	buyObject.count + ((App.data.money.enabled && App.data.money.date_to > App.time)?buyObject.extra:0)
			}
		}
		ExternalApi.apiBalanceEvent(object);
	}
}

import com.greensock.*;
internal class MoneyLabel extends Sprite {
	
	private var bitmap:Bitmap;
	public function MoneyLabel(type:String) {
		
		switch(App.lang){
			case 'ru':
			case 'jp':
				type += '_'+App.lang;
				break;
			default:
				type += '_en';
				break;
		}
		
		bitmap = new Bitmap();
		Load.loading(Config.getImage('sales/image', type), onLoad);
		addChild(bitmap);
		this.rotation = -100;
	}
	
	private function onLoad(data:Bitmap):void 
	{
		bitmap.bitmapData = data.bitmapData;
		bitmap.x = -bitmap.width / 2;
		bitmap.y = -3;
		bitmap.smoothing = true;
	}
}

internal class SetItem extends Sprite{
	
	public var background:Bitmap;
	public var icon:Bitmap;
	public var item:Object;
	public var window:*;
	public var id:int;
	public var buyBttn:Button;
	public var bitmap:Bitmap;
	public var cont:Sprite;	
	private var priceBttn:Button;
	
	public function SetItem(item:Object, window:*, i:int) {
		
		this.id = id
		this.item = item;
		this.window = window;
		
		background = Window.backing(296, 130, 10, "itemBacking");
		addChild(background);
		
		bitmap = new Bitmap();
		addChild(bitmap);
		
		Load.loading(Config.getImage('sets', item.image), function(data:*):void {
			bitmap.bitmapData = data.bitmapData;
			//bitmap.scaleX = bitmap.scaleY = 0.4;
			bitmap.smoothing = true;
			bitmap.x = -5;
			bitmap.y = (background.height - bitmap.height) / 2;
		});
		
		drawTitle();
		
		var i:int = 0;
		var items:Array = [];
		for (var sID:* in item.items) {
			items.push( { order:item.iorder[sID], sID:sID, count:item.items[sID] } );
		}
		items.sortOn('order');
		
		var n:int = 1;
		for each(var row:* in items) {
			if (n < 3) {
				getItem(row);
			}else {
				getBonus(row);
			}
			n++;
		}
		drawPrice();
	}
	
	public function getBonus(row:Object):void {
		var obj:Object = App.data.storage[row.sID];
		
		var sprite:Sprite = new Sprite();
		var bonusstar:Bitmap = new Bitmap(Window.textures.bonusstar, "auto", true);
		bonusstar.scaleX = bonusstar.scaleY = 0.95;
		sprite.addChild(bonusstar);
		
		var icon:Bitmap = new Bitmap();
		Load.loading(Config.getIcon(obj.type, obj.preview), function(data:*):void {
			icon.bitmapData = data.bitmapData;
			icon.scaleX = icon.scaleY = 0.40;
			icon.smoothing = true;		
			icon.x = (bonusstar.width - icon.width)/2;
			icon.y = (bonusstar.height - icon.height)/2 - 10;
				
			sprite.addChild(icon);
			
			var settings:Object = {
				fontSize	:22,
				color		:0x0f776a,
				borderColor	:0xe0f5fb,
				autoSize	:"left",
				letterSpacing: -1
			};
			
			var textLabel:TextField  = Window.drawText('+ '+Numbers.moneyFormat(row.count), settings);
			textLabel.x = (bonusstar.width - textLabel.width) / 2 - 4;
			textLabel.y = icon.y + icon.height - 8;
				
			sprite.addChild(textLabel);
		});
		
		addChild(sprite);
		addChild(sprite);
		sprite.x = background.width - bonusstar.width + 5;
		sprite.y = 5;
		sprite.rotation = -10;
	}
	
	public function getItem(row:Object):void {
		
		var obj:Object = App.data.storage[row.sID];
		var icon:Bitmap = new Bitmap();
		Load.loading(Config.getIcon(obj.type, obj.preview), function(data:*):void {
			icon.bitmapData = data.bitmapData;
			icon.scaleX = icon.scaleY = 0.40;
			icon.smoothing = true;		
			
		});
		icon.x = 130;
		icon.y = 20 + 38 * (row.order - 1);
		addChild(icon);
		
		var settings:Object = {
			fontSize	:22,
			color		:0xffdc39,
			borderColor	:0x6d4b15,
			autoSize	:"left"
		};
		
		if (row.sID == Stock.FANT) {
			settings.color = 0xa1d435;
			settings.borderColor = 0x38510d;	
		}
			
		var textLabel:TextField  = Window.drawText(Numbers.moneyFormat(row.count), settings);
		textLabel.x = 170;
		textLabel.y = 22 + 40 * (row.order - 1);
		addChild(textLabel);
	}
	
	public function drawTitle():void {
		var title:TextField = Window.drawText(String(item.title), {
			color:0x6d4b15,
			borderColor:0xfcf6e4,
			textAlign:"center",
			autoSize:"center",
			fontSize:24,
			textLeading:-6,
			multiline:true
		});
		title.wordWrap = true;
		title.width = background.width - 10;
		title.y = -8;
		title.x = 5;
		addChild(title);
	}
	
	public function drawPrice():void {
			
		var bttnSettings:Object = {
			caption:"",
			fontSize:22,
			width:126,
			height:34,
			borderColor:[0xaff1f9, 0x005387],
			bgColor:[0x70c6fe, 0x765ad7],
			fontColor:0x453b5f,
			fontBorderColor:0xe3eff1
		};
		
		bttnSettings.caption = Locale.__e("flash:1382952379984") + ' ' + Payments.price(item.price[App.social]);
		
		priceBttn = new Button(bttnSettings);
		addChild(priceBttn);
		
		priceBttn.x = 140;
		priceBttn.y = background.height - 32;
		
		priceBttn.addEventListener(MouseEvent.CLICK, buyEvent);
	}
	
	private function buyEvent(e:MouseEvent):void{
		
		if (e.currentTarget.mode == Button.DISABLED) return;
		
		var object:Object;
		if (App.social == 'FB') {
			object = {
				id:		 		item.id,
				type:			'sets',
				title: 			item.title,
				callback:		onBuyComplete
			};
		}else{
			object = {
				count:			1,
				money:			'sets',
				type:			'item',
				item:			'set_'+item.id,
				votes:			item.price[App.social],
				title: 			item.title,
				callback: 		onBuyComplete
			};
		}
		ExternalApi.apiSetsEvent(object);
	}
	
	private function onBuyComplete(e:* = null):void 
	{
		
		priceBttn.state = Button.DISABLED;
		App.user.stock.addAll(item.items);
		
		for (var sID:* in item.items) {
			var bonus:BonusItem = new BonusItem(int(sID), int(item.items[sID]));
			var point:Point = Window.localToGlobal(priceBttn);
			bonus.cashMove(point, App.self.windowContainer);
		}
		window.close();
		
		new SimpleWindow( {
			label:SimpleWindow.ATTENTION,
			title:Locale.__e("flash:1382952379735"),
			text:Locale.__e("flash:1382952379990")
		}).show();
	}
	
	public function dispose():void
	{
		//buyBttn.removeEventListener(MouseEvent.CLICK, buyEvent);
	}
	
	
}

