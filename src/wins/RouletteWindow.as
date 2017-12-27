package wins 
{
	import buttons.Button;
	import buttons.ImageButton;
	import com.greensock.TweenLite;
	import core.Load;
	import core.Numbers;
	import core.Post;
	import core.Size;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.utils.setTimeout;
	import ui.UserInterface;
	public class RouletteWindow extends Window 
	{
		public static const CURRENCY:int = 1453;
		//public static const skins:Array = ['giftBoxPicRoulette3', 'giftBoxPicRoulette2', 'giftBoxPicRoulette1', 'giftBoxPicRoulette1', 'giftBoxPicRoulette3', 'giftBoxPicRoulette2', 'giftBoxPicRoulette3', 'giftBoxPicRoulette2', 'giftBoxPicRoulette1'];
		//public static const backSkins:Array = ['openBoxPicRoulette3', 'openBoxPicRoulette2', 'openBoxPicRoulette1', 'openBoxPicRoulette1', 'openBoxPicRoulette3', 'openBoxPicRoulette2', 'openBoxPicRoulette3', 'openBoxPicRoulette2', 'openBoxPicRoulette1'];
		
		public static var expire:int = 0;
		public static var slots:Object = {};
		public static var rTry:Object = {};
		public static var rPositions:Object = {};
		public static var trying:int = 1;
		public static var canChoose:Boolean = true;
		
		private var buyBttn:Button;
		private var infoBttn:ImageButton;
		private var playBttn:ImageButton;
		private var giftImageBttn:ImageButton;
		private var items:Array;
		private var positions:Array;
		private var itemsContainer:Sprite;
		private var playBttnText:TextField;
		private var currenceCount:TextField;
		private var lastWin:TextField;
		private var jackpot:TextField;
		private var newSlots:Array = [];
		private var attempt:int = 0;
		private var playText:TextField;
		private var fantsIco:Bitmap;
		public function RouletteWindow(settings:Object=null) 
		{
			if (!settings) settings = { };
			
			settings['width'] = settings['width'] || 470;
			settings['height'] = settings['height'] || 600;
			settings['title'] = Locale.__e('flash:1452871270891');
			settings['hasPaginator'] = false;
			settings['background'] = 'rouletteBackingTop';
			
			expire = App.data.roulette[1].time + App.data.roulette[1].jackpot[4] * 24 * 3600;
			
			super(settings);
			
			if (Numbers.countProps(rTry) != 0 && Numbers.countProps(rTry) != Numbers.countProps(slots)) {
				trying = Numbers.countProps(slots) - Numbers.countProps(rTry) + 1;
			}
			
			App.self.setOnTimer(drawJackpot);
			checkSlots();
		}
		
		private function init():void {
			checkCurrency();
			Post.send( {
				ctr:'Roulette',
				act:'init',
				sID:1,
				id:1,
				wID:App.user.worldID,
				uID:App.user.id
			}, function(error:int, data:Object, params:Object):void {
				if (error) return;
				
				if (data.hasOwnProperty('slots')) {
					RouletteWindow.slots = data.slots;
					RouletteWindow.rTry = data.slots;
				}
				
				RouletteWindow.rPositions = { };
				
				trying = 1;
				
				checkSlots();
				drawItems();
			});
		}
		
		private function checkSlots():void {	
			newSlots = [];
			for (var slotID:* in slots) {
				var obj:Object = { };
				obj[slotID] = slots[slotID];
				newSlots.push(obj);
			}			
			schuffle();
			for (var pos:* in rPositions) {
				for (var i:int = 0; i < newSlots.length; i++) {
					var sid:*;
					for (var idSlot:* in newSlots[i]) {
						for (sid in newSlots[i][idSlot]) break;
					}
					if (sid == rPositions[pos]) {
						swap(i, pos);
					}
				}
			}
			
			function schuffle():void {
				var length:uint = newSlots.length;
				
				while (length--) {
					var n:int = Math.random() * (length + 1);
					var temp:Object = newSlots[length];
					newSlots[length] = newSlots[n];
					newSlots[n] = temp;
				}
			}
			
			function swap(x:uint, y:uint):void {
				var temp:* = newSlots[x];
				newSlots[x] = newSlots[y];
				newSlots[y] = temp;
			}
		}
		
		override public function drawBody():void {
			exit.scaleX = exit.scaleY = 0.85;
			exit.x += 15;
			
			drawTop();
			
			var centerContainer:Sprite = new Sprite();
			bodyContainer.addChild(centerContainer);
			
			var upBack:Bitmap = new Bitmap();
			upBack = Window.backing2(settings.width, settings.height - 100, 50, 'rouletteCenterBacking', 'rouletteBackingBot');
			centerContainer.addChild(upBack);
			
			drawMirrowObjs('rouletteTreeDecBase', bodyContainer.x + 15, settings.width - 15, settings.height - 55, false, false, false, 1, 1, bodyContainer);
			drawMirrowObjs('rouletteTreeDecUp', bodyContainer.x + 15, settings.width - 15, 110, false, false, false, 1, 1, bodyContainer);
			
			var round:Bitmap = new Bitmap(Window.texture('rouletteGoldDecCentre'));
			round.x = (settings.width - round.width) / 2;
			round.y = 107;
			bodyContainer.addChild(round);
			
			drawMirrowObjs('rouletteTreeDecCentre', round.x - 37, round.x + round.width + 37, 106, false, false, false, 1, 1, bodyContainer);
			
			centerContainer.y = background.height - centerContainer.height;
			
			itemsContainer = new Sprite();
			itemsContainer.x = 60;
			itemsContainer.y = 55;
			centerContainer.addChild(itemsContainer);
			
			drawItems();
			drawBot();
			drawCroupier();
			drawCurrencyCount();			
		}
		
		override public function drawTitle():void {
			var titleText:TextField = drawText(settings.title, {
				color				: 0xffffff,
				multiline			: settings.multiline,			
				fontSize			: 46,
				textLeading	 		: settings.textLeading,	
				border				: true,
				borderColor 		: 0xc4964e,			
				borderSize 			: 4,	
				shadowColor			: 0x503f33,
				shadowSize			: 4,
				width				: settings.width,
				textAlign			: 'center',
				sharpness 			: 50,
				thickness			: 50
			});
			titleText.y = -35;
			bodyContainer.addChild(titleText);
		}
		
		private function drawTop():void {
			var substrate:Bitmap = Window.backing(settings.width - 70, 75, 50, 'fadeOutWhite');
			substrate.x = 33;
			substrate.y = 25;
			substrate.alpha = 0.3;
			bodyContainer.addChild(substrate);
			
			infoBttn = new ImageButton(Window.texture('interHelpBttn'));
			infoBttn.x = exit.x + 5;
			infoBttn.y = 40;
			bodyContainer.addChild(infoBttn);
			infoBttn.addEventListener(MouseEvent.CLICK, onInfo);
			
			var giftContainer:Bitmap = new Bitmap(Window.texture('rouletteGiftButton'));
			giftContainer.x = 40;
			giftContainer.y = 25;
			bodyContainer.addChild(giftContainer);
			
			giftImageBttn = new ImageButton(Window.texture('rouletteGiftIco'));
			giftImageBttn.x = giftContainer.x + (giftContainer.width - giftImageBttn.width) / 2;
			giftImageBttn.y = giftContainer.y + (giftContainer.height - giftImageBttn.height) / 2;
			bodyContainer.addChild(giftImageBttn);
			giftImageBttn.addEventListener(MouseEvent.CLICK, onGiftShow);
			
			jackpot = drawText(Locale.__e('flash:1452617385941', String(1000000)), {
				width:		background.width + 40,
				color:		0xfff5cd,
				borderColor:0x162329,
				fontSize:	31,
				textAlign:	'center'
			});
			jackpot.y = giftContainer.y + 5;
			bodyContainer.addChild(jackpot);
			
			var roulette:Object = App.data.roulette[1].jackpot;
			var textWin:String = String(Math.ceil(roulette[1] + roulette[2] * (roulette[4] * 24 * 3600 / roulette[3])));
			lastWin = drawText(Locale.__e('flash:1452617518477', textWin), {
				width:		background.width + 40,
				color:		0xfff5cd,
				borderColor:0x162329,
				fontSize:	28,
				textAlign:	'center'
			});
			lastWin.y = jackpot.y + lastWin.textHeight + 5;
			bodyContainer.addChild(lastWin);
		}
		
		private function drawBot():void {
			playBttn = new ImageButton(Window.texture('homeBttn'));
			playBttn.x = (settings.width - playBttn.width) / 2;
			playBttn.y = settings.height - playBttn.height + 10;
			bodyContainer.addChild(playBttn);
			playBttn.addEventListener(MouseEvent.CLICK, onPlay);
			
			playBttnText = Window.drawText(Locale.__e('flash:1437729611472'), {
				textAlign:		'center',
				fontSize:		32,
				color:			0xFFFFFF,
				borderColor:	0x631d0b,
				shadowSize:		1
			});
			playBttnText.x = 20;
			playBttnText.y = (playBttn.height - playBttnText.height) / 2;
			playBttn.addChild(playBttnText);
			
			var bg:Bitmap = Window.backing(settings.width - 130, 35, 50, 'fadeOutWhite');
			bg.x = 63;
			bg.y = playBttn.y - 40;
			bg.alpha = 0.2;
			bodyContainer.addChild(bg);
			
			playText = drawText(Locale.__e('flash:1452699034116'), {
				color:			0xfffaee,
				borderColor:	0x493222,
				fontSize:		22,
				textAlign:		'center',
				width:			settings.width
			});
			playText.y = playBttn.y - 35;
			bodyContainer.addChild(playText);
		}
		
		private function drawCroupier():void {
			var croupier:Bitmap = new Bitmap();
			bodyContainer.addChild(croupier);
			Load.loading(Config.getImage('content', 'CroupierPic'), function(data:*):void {
				croupier.bitmapData = data.bitmapData;
				croupier.x = -croupier.width + 50;
			});
		}
		
		private function drawCurrencyCount():void {
			var hanger:Bitmap = new Bitmap();
			hanger.bitmapData = Window.texture('rouletteDecGold');
			hanger.x = background.width - 15;
			hanger.y = 150;
			bodyContainer.addChild(hanger);
			
			var plate:Bitmap = backing(180, 185, 50, 'woodPaperBackingDark');
			plate.x = background.width - 50;
			plate.y = 250;
			bodyContainer.addChild(plate);
			
			var youHaveText:TextField = Window.drawText(Locale.__e('flash:1425978184363'), {
				color:			0xf5eccd,
				borderColor:	0x793916,
				fontSize:		24
			});
			youHaveText.x = plate.x + (plate.width - youHaveText.textWidth) / 2;
			youHaveText.y = plate.y + 35;
			bodyContainer.addChild(youHaveText);
			
			buyBttn = new Button( {
				caption:		Locale.__e('flash:1452683208269'),
				width:			100,
				height:			45,
				fontSize:		24
			});
			buyBttn.x = plate.x + (plate.width - buyBttn.width) / 2;
			buyBttn.y = plate.y + plate.height - buyBttn.height - 35;
			bodyContainer.addChild(buyBttn);
			buyBttn.addEventListener(MouseEvent.CLICK, onBuy);
			
			var ico:Bitmap = new Bitmap(Window.texture('rouletteIco'));
			ico.smoothing = true;
			ico.x = buyBttn.x;
			ico.y = buyBttn.y - 43;
			bodyContainer.addChild(ico);
			
			currenceCount = Window.drawText(String(App.user.stock.count(CURRENCY)), {
				color:			0x793916,
				borderColor:	0xf5eccd,
				fontSize:		30
			});
			currenceCount.x = ico.x + ico.width + 5;
			currenceCount.y = ico.y;
			bodyContainer.addChild(currenceCount);
		}
		
		public function onGiftShow(e:MouseEvent):void {
			var items:Object = { };
			var i:int = 0;
			for each (var cat:* in App.data.roulette[1].categories) {
				var catItems:Object = App.data.category[cat].items;
				for (var itm:* in catItems) {
					items[i] = { };
					items[i][itm] = catItems[itm];
					i++;
				}
			}
			new RouletteItemsWindow({
				popup:true,
				items:items
			}).show();
		}
		
		public function onBuy(e:MouseEvent = null):void {
			var content:Object = PurchaseWindow.createContent("Energy", { view:App.data.storage[CURRENCY].view } );
			new PurchaseWindow( {
				width:595,
				itemsOnPage:Numbers.countProps(content), 
				content:content,
				title:Locale.__e("flash:1382952379751"),
				fontBorderColor:0xd49848,
				shadowColor:0x553c2f,
				shadowSize:4,
				description:Locale.__e('flash:1453215785462'),
				popup: true,
				hasDescription:true,
				background:'woodPaperBackingDark',
				callback:function(sID:int):void {
					currenceCount.text = String(App.user.stock.count(CURRENCY));
				}
			}).show();
		}
		
		private function onInfo(e:MouseEvent):void {
			new InfoWindow({qID:'777'}).show();
		}
		
		private function onPlay(e:MouseEvent):void {
			if (e.currentTarget.mode == Button.DISABLED) return;			
			e.currentTarget.state = Button.DISABLED;
			
			if (!App.user.stock.take(CURRENCY, 1)) {
				playBttn.state = Button.NORMAL;
				playBttn.addChild(playBttnText);
				onBuy();
				return;
			}
			
			RouletteWindow.canChoose = false;
			closeItems();
		}
		
		public function onChooseItem(card:RouletteItem):void {	
			var pos:int = 0;
			for (var i:int; i < positions.length; i++) {
				if (positions[i].x == card.x && positions[i].y == card.y) {
					pos = i;
					break;
				}
			}
			
			playBttn.state = Button.NORMAL;
			playBttn.addChild(playBttnText);
			checkCurrency();
			
			Post.send( {
				ctr:'Roulette',
				act:'play',
				sID:1,
				id:1,
				wID:App.user.worldID,
				uID:App.user.id,
				p:pos,
				'try':trying
			}, function(error:int, data:Object, params:Object):void {
				if (error) return;
				
				trying++;
				
				if (data.hasOwnProperty('bonus')){
					card.openCard(data.bonus);
				}
				
				new RouletteRewardWindow( { 
					prize:data.bonus,
					popup:true
				} ).show();
				
				rPositions[pos] = card.sID;
				RouletteWindow.rTry = data['try'];
				RouletteWindow.canChoose = true;
			});
		}
		
		public function checkCurrency():void {
			currenceCount.text = String(App.user.stock.count(CURRENCY));
		}
		
		private function drawItems():void {			
			clearItems();
			items = [];
			positions = [];
			var i:int = 0;
			var item:RouletteItem;
			for each (var slotItem:* in newSlots) {
				for (var slotID:* in slotItem) {
					var slot:Object = slotItem[slotID];
					var open:Boolean = false;
					if (!rTry.hasOwnProperty(slotID)) {
						open = true;
					}
					for (var sid:* in slot) {
						var count:int = slot[sid];
					}
					item = new RouletteItem(this, { sid:int(sid), count:count, open:open} );
					item.x = (i % 3) * 118;
					item.y = Math.floor(i / 3) * 118;
					itemsContainer.addChild(item);
					
					items.push(item);
					positions.push( { x:item.x, y:item.y } );
					i++;
					if (i == 9) break;
				}
			}
			
			if (items.length != 0 && Numbers.countProps(rTry) == Numbers.countProps(slots)) {
				RouletteWindow.canChoose = false;
				for each (var itemr:RouletteItem in items) {
					itemr.removeOnOutListener();
				}
				setTimeout(openItems, 1000);
			}
			
			if (items.length == 0) {
				for (i = 0; i < 9; i++) {
					item = new RouletteItem(this, { sid:0, count:0, open:open} );
					item.x = (i % 3) * 118;
					item.y = Math.floor(i / 3) * 118;
					itemsContainer.addChild(item);
					
					items.push(item);
				}
				
				infoBttn.showGlowing();
			}
		}
		
		private function clearItems():void {
			for each (var item:RouletteItem in items) {
				if (item.parent != null)
					item.parent.removeChild(item);
				item.dispose();
			}
		}
		
		private function closeItems():void {
			playBttn.state = Button.DISABLED;
			for each (var item:RouletteItem in items) {
				if (item.sID != 0) {
					setTimeout(item.closeCard, Math.random() * 1000);
				}
			}
			
			setTimeout(init, 1000);
		}
		
		private function openItems():void {
			playBttn.state = Button.DISABLED;
			for each (var item:RouletteItem in items) {
				setTimeout(item.openCard, Math.random() * 1000);
			}
			
			setTimeout(revertItems, 5000);
		}
		
		private function revertItems():void {
			for each (var item:RouletteItem in items) {
				item.removeOnOutListener();
				setTimeout(item.closeCard, Math.random() * 1000);
			}
			
			setTimeout(shuffleItems, 2000);
		}
		
		private function shuffleItems():void {
			RouletteWindow.canChoose = false;
			
			var _array:Array = items.slice();
			var length:uint = _array.length;
			
			while (length--) {
				var n:int = Math.random() * (length + 1);
				swap(length, n);
			}
			items = _array;
			
			var i:int = 0;
			for (i = 0; i < items.length; i++) {
				TweenLite.to(items[i], 0.3, {x:positions[i].x, y:positions[i].y} );
			}
			
			attempt++;
			if (attempt < 5) {
				setTimeout(shuffleItems, 300);
			} else {				
				for (i = 0; i < items.length; i++) {
					items[i].addOnOutListener();
				}
				
				RouletteWindow.canChoose = true;
				attempt = 0;
			}
			
			function swap(x:uint, y:uint):void{
				var temp:* = _array[x];
				_array[x] = _array[y];
				_array[y] = temp;
			}
		}
		
		private function drawJackpot():void {
			if (expire >= App.time) {
				var roulette:Object = App.data.roulette[1].jackpot;
				var count:String = String(Math.ceil(roulette[1] + roulette[2] * ((App.time - (expire - roulette[4] * 3600 * 24)) / roulette[3])));
				if (jackpot) jackpot.text = Locale.__e('flash:1452617385941', count);
			}else {
				
			}
		}
		
		override public function dispose():void {
			buyBttn.removeEventListener(MouseEvent.CLICK, onBuy);
			infoBttn.removeEventListener(MouseEvent.CLICK, onInfo);
			giftImageBttn.removeEventListener(MouseEvent.CLICK, onGiftShow);
			App.self.setOffTimer(drawJackpot);
			super.dispose();
		}
		
	}

}
import com.greensock.TweenLite;
import core.Load;
import core.Size;
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.text.TextField;
import ui.UserInterface;
import wins.RouletteWindow;
import wins.SimpleWindow;
import wins.Window;

internal class RouletteItem extends Sprite
{
	public static const BG_WIDTH:int = 115;
	
	public var bg:Bitmap;
	public var bgOpen:Bitmap;
	public var sID:int;
	public var count:int;
	public var open:Boolean = true;
	private var window:*;
	private var icon:Bitmap = new Bitmap();
	private var center:int;
	private var contentSprite:LayerX = new LayerX();
	private var textSprite:Sprite = new Sprite();
	private var counttext:TextField;
	private var titletext:TextField;
	private var needOpen:Boolean = false;
	private var textOpen:TextField;
	private var currencyCount:TextField;
	public function RouletteItem(window:*, data:Object)
	{
		this.sID = data.sid;
		this.count = data.count;
		this.window = window;
		this.open = data.open;
		
		bg = new Bitmap(Window.texture('giftBoxPicRoulette3'));
		addChild(bg);
		
		bgOpen = new Bitmap(Window.texture('openBoxPicRoulette3'));
		addChild(bgOpen);
		
		addChild(contentSprite);
		addChild(textSprite);
		
		if (sID == 0) {
			bgOpen.visible = false;
			return;
		}
		
		drawText();
		setState(0);
		
		Load.loading(Config.getIcon(App.data.storage[sID].type, App.data.storage[sID].view), onLoad);
		
		addEventListener(MouseEvent.CLICK, onClick);
		addOnOutListener();
	}
	
	private function onLoad(data:*):void {
		if (icon.parent) {
			contentSprite.removeChild(icon);
			icon = new Bitmap();
		}
		icon.bitmapData = data.bitmapData;
		icon.smoothing = true;
		Size.size(icon, 75, 75);
		icon.x = (BG_WIDTH - icon.width) / 2;
		icon.y = (BG_WIDTH - icon.height) / 2 + 5;
		contentSprite.addChild(icon);
		
		contentSprite.tip = function():Object {
			return {
				title:App.data.storage[sID].title,
				text:App.data.storage[sID].description
			}
		}
		
		drawTitle();
		drawCount();
		
		if (open) {
			setState(1);
		} else {
			setState();
		}
		
		if (needOpen) {
			needOpen = false;
			openCard();
		}
	}
	
	public function onClick(e:MouseEvent):void {
		if (!RouletteWindow.canChoose) return;
		if (contentSprite.visible == false) {
			RouletteWindow.canChoose = false;
			if (RouletteWindow.trying == 1) {
				removeOnOutListener();
				window.onChooseItem(this);
				return;
			}
			var that:* = this;
			new SimpleWindow( {
				popup:true,
				showCoin:true,
				title:Locale.__e('flash:1382952379893'),
				text:Locale.__e('flash:1456479559427', String(App.data.roulette[1].cost[RouletteWindow.trying])),
				dialog:true,
				needCancelAfterClose:true,
				confirm:function():void {
					if (RouletteWindow.trying != 1 && !App.user.stock.take(RouletteWindow.CURRENCY, App.data.roulette[1].cost[RouletteWindow.trying])) {
						RouletteWindow.canChoose = true;
						window.onBuy();
						return;
					}
					removeOnOutListener();
					window.onChooseItem(that);
				},
				cancel:function():void {RouletteWindow.canChoose = true;}
			}).show();
		}
	}
	
	public function onOver(e:MouseEvent):void {
		if (!RouletteWindow.canChoose || contentSprite.visible) return;
		setState(2);
	}
	
	public function onOut(e:MouseEvent):void {
		if (!RouletteWindow.canChoose || contentSprite.visible) return;
		setState(0);
	}
	
	private function drawTitle():void {
		if (titletext) {
			contentSprite.removeChild(titletext);
			titletext = null;
		}
		titletext = Window.drawText(App.data.storage[sID].title, {
			color		:0x773d18,
			borderColor	:0xf9fce7,
			width		:bg.width,
			textAlign	:'center',
			multiline	:true,
			wrap		:true
		});
		titletext.y = 5;
		contentSprite.addChild(titletext);
	}
	
	private function drawCount():void {
		if (counttext) {
			contentSprite.removeChild(counttext);
			counttext = null;
		}
		counttext = Window.drawText('x' + String(count), {
			color		:0xfffdff,
			borderColor	:0x773d18,
			width		:bg.width,
			textAlign	:'right',
			multiline	:true,
			wrap		:true,
			fontSize	:24
		});
		counttext.x = -15;
		counttext.y = BG_WIDTH - counttext.textHeight - 10;
		contentSprite.addChild(counttext);
	}
	
	private function drawText():void {
		if (textSprite.numChildren > 0) {
			while (textSprite.numChildren > 0)
				textSprite.removeChildAt(0);
		}
		textOpen = Window.drawText(Locale.__e('flash:1382952379890'), {
			color		:0x773d18,
			borderColor	:0xf9fce7,
			width		:bg.width,
			textAlign	:'center',
			multiline	:true,
			wrap		:true,
			fontSize	:26
		});
		textOpen.y = (BG_WIDTH - textOpen.textHeight) / 2 + 5;
		textSprite.addChild(textOpen);
	}
	
	public function openCard(newCard:Object = null):void {
		center = bg.width / 2;
		if (newCard != null) {
			for (var s:* in newCard) {
				var count:int = newCard[s];
			}
			this.sID = s;
			this.count = count;
			
			App.user.stock.add(s, count);
			
			if (s == RouletteWindow.CURRENCY) window.checkCurrency();
			
			needOpen = true;
			Load.loading(Config.getIcon(App.data.storage[s].type, App.data.storage[s].view), onLoad);
			return;
		}
		TweenLite.to(this, 0.2, {scaleX:0, x:this.x + center, onComplete:showSide, onCompleteParams:[true]});
	}
	
	public function closeCard():void {
		if (!contentSprite.visible) return;
		center = bg.width / 2;
		TweenLite.to(this, 0.2, {scaleX:0, x:this.x + center, onComplete:showSide, onCompleteParams:[false]});
	}
	
	private function showSide(front:Boolean = true):void {
		setState(int(front));
		TweenLite.to(this, 0.2, { scaleX:1, x:this.x - center, onCompleteParams:[front], onComplete:function(front:Boolean):void{
			if (front) {
				addOnOutListener();
			}
		}});
	}
	
	/* Состояния карты:
		 0 - карта повернута рубашкой
		 1 - карта повернута лицевой стороной
		 2 - показываем текст на карте
	 * */
	private function setState(state:int = 0):void {
		switch(state) {
			case 0:
				bgOpen.visible = false;
				bg.visible = true;
				contentSprite.visible = false;
				textSprite.visible = false;
				break;
			case 1:
				bgOpen.visible = true;
				bg.visible = false;
				contentSprite.visible = true;
				textSprite.visible = false;
				break;
			case 2:
				contentSprite.visible = false;
				
				drawText();
				textSprite.visible = true;
				break;
		}
	}
	
	public function addOnOutListener():void {
		addEventListener(MouseEvent.MOUSE_OVER, onOver);
		addEventListener(MouseEvent.MOUSE_OUT, onOut);
	}
	
	public function removeOnOutListener():void {
		removeEventListener(MouseEvent.MOUSE_OVER, onOver);
		removeEventListener(MouseEvent.MOUSE_OUT, onOut);
	}
	
	public function dispose():void {
		removeOnOutListener();
		removeEventListener(MouseEvent.CLICK, onClick);
	}
}
