package wins 
{
	import api.ExternalApi;
	import buttons.Button;
	import buttons.MoneyButton;
	import core.Load;
	import core.Log;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import ui.Hints;
	import units.Floors;
	import wins.elements.ContentManager;
	import wins.Paginator;
	
	public class TowerWindowTwo extends Window
	{
		private var items:Array = new Array();
		private var accelerateBttn:MoneyButton
		public var info:Object;
		public var back:Bitmap;
		public var backSmall:Bitmap;
		public var hitBttn:Button;
		public var upgradeBttn:Button;
		public var contentManager:ContentManager;
		public var notifBttn:Button = null;
		public var whatToPlaceTextLabel:TextField;	
		public var progressBar:ProgressBar;
		public var itemsNum:int;
		public var rewardTextLabel:TextField;
		public var fontOffset:int = 0;
		
		public function TowerWindowTwo(settings:Object = null)
		{
			if (settings == null) {
				settings = new Object();
			}
			
			info = settings.target.info;
			
			settings['itemsNum'] = settings.itemsNum;
			settings['fontColor'] = 0xffffff;
			settings['fontSize'] = 36;
			settings['fontBorderColor'] = 0xb5855d;
			settings['shadowBorderColor'] = 0x86572b;
			settings['fontBorderSize'] = 4;			
			settings['background'] = "alertBacking";
			settings['width'] = (settings.itemsNum == 4) ? 675 : 550;
			settings['height'] = 635;
			settings['title'] = info.title;
			settings['hasPaginator'] = true;
			settings['hasButtons'] = false;
			settings['hasArrow'] = true;
			settings['itemsOnPage'] = 10;			
			settings['content'] = [];
			settings['kicks'] = [];	
			
			fontOffset = settings.fontOffset || 0;
			
			itemsNum = settings.itemsNum;
			
			if (settings.target.sid == 1929 || settings.target.sid == 2202 || settings.target.sid == 2642) {
				settings['width'] = 675;
				itemsNum = 4;
			}
			
			for (var _uid:* in settings.target.guests) {
				if (!App.user.friends.data.hasOwnProperty(_uid)) continue;
				settings['content'].push( { uid:_uid, time:settings.target.guests[_uid] } );
			}
			
			settings['kicks'] = [];
			for (var sID:* in info.mkicks) {
				var obj:Object = { sID:sID, count:info.mkicks[sID].c };
				if (info.mkicks[sID].hasOwnProperty('t')) {
					obj['t'] = info.mkicks[sID].t;
					obj['o'] = info.mkicks[sID].o;
				}
				settings['kicks'].push(obj);
			}
			
			settings['kicks'].sortOn(info.mkicks[sID].t, Array.NUMERIC);
			
			var colsCount:int = 4;
			if (itemsNum == 4) {
				colsCount = 6;
			}
			contentManager = new ContentManager( { from:0, to:settings['itemsOnPage'], cols:colsCount, content:settings['content'], itemType:'FriendItem', margin:10} );
			
			if (settings.target.hasOwnProperty('floor')) {
				floor = settings.target.floor;
			}else{
				floor = settings.target.level;
			}			
			
			super(settings);
		}
		
		public var floor:int = 0;
		public var titleTxt:Sprite;
		private var txtS:TextField;		
		public function drawProgress():void {			
			var progressBacking:Bitmap = Window.backingShort(400, "progBarBacking");
			progressBacking.x = (settings.width - progressBacking.width) / 2;
			progressBacking.y = 45;
			bodyContainer.addChild(progressBacking);
			
			var barSettings:Object = {
				width:416,
				win:this.parent,
				isTimer:false
			};
			
			progressBar = new ProgressBar(barSettings);
			progressBar.x = progressBacking.x - 8;
			progressBar.y = progressBacking.y - 4;
			bodyContainer.addChild(progressBar);
				
			progressBar.start();
			
			txtS = drawText('', {
				width:progressBar.width,
				fontSize:26 + fontOffset,
				color:0xFFFFFF,
				autoSize:"center",
				borderColor:0x704a26
			});
			txtS.x = (settings.width - txtS.width) / 2;
			txtS.y = progressBar.y + 4;
			bodyContainer.addChild(txtS);
			
			progress();
		}
		
		public function get kickTextPosY():int {
			return settings.height - 200 / 2 - 90;
		}
		
		public function get kickTextPosX():int {
			return (settings.width - 200) / 2;
		}
		
		override public function drawBody():void {
			exit.y -= 25;
			if (settings.target.floor < settings.target.totalFloors) {
				drawVisitors();
			}
			
			if (settings.content.length == 0) {
				var descText:String = 'text4';
				if (floor > 0) {
					if (info.tower[floor + 1] == undefined ) {
						descText = 'text9'
					}
				}
				
				var descriptionLabel:TextField = drawText(getTextFormInfo(descText), {
					fontSize:20 + fontOffset,
					textAlign:"center",
					color:0xffffff,
					borderColor:0x624512,
					textLeading: -3
				});
				
				descriptionLabel.wordWrap = true;
				descriptionLabel.width = 350;
				descriptionLabel.height = descriptionLabel.textHeight + 10;
				descriptionLabel.x = (settings.width - descriptionLabel.width) / 2;
				descriptionLabel.y = 290;
				
				bodyContainer.addChild(descriptionLabel);
			}
			drawBttns();
			
			var levelTextTabel:TextField = Window.drawText(Locale.__e("flash:1382952380004", [settings.target.floor, settings.target.totalFloors]), {
				fontSize:22 + fontOffset,
				color:0xFFFFFF,
				autoSize:"left",
				borderColor:0x704a26
			});
			
			bodyContainer.addChild(levelTextTabel);
			levelTextTabel.x = settings.width / 2 - levelTextTabel.width / 2;
			levelTextTabel.y = 10;
			titleLabel.y += 8;
			bodyContainer.addChild(contentManager);
			
			if (itemsNum == 4) {
				contentManager.x = 65;
			}else {
				contentManager.x = 75;
			}
			contentManager.y = 370;
			
			backSmall = Window.backing((settings.itemsNum == 4) ? 625 : 350, 230, 20, 'alertBacking');
			backSmall.x = (settings.width - backSmall.width) / 2;
			backSmall.y = 110;
			backSmall.alpha = 1;
			
			whatToPlaceTextLabel = drawText(Locale.__e('flash:1456762527705'), {
				fontSize:28 + fontOffset,
				autoSize:"center",
				textAlign:"center",
				color:0xffffff,
				borderColor:0x764413,
				border:true
			});
			whatToPlaceTextLabel.x = backSmall.x + (backSmall.width / 2) - (whatToPlaceTextLabel.width / 2);
			whatToPlaceTextLabel.y = backSmall.y - 35;			
			bodyContainer.addChild(whatToPlaceTextLabel);					
			
			var upgradeText:String = getTextFormInfo('text9');			
			var textSett:Object = {
				width		:settings.width - 100,
				height		:400,
				fontSize	:27 + fontOffset,
				textAlign	:"center",
				color		:0xffffff,
				borderColor	:0x784727,
				multiline	:true,
				wrap		:true
			}
			
			rewardTextLabel = Window.drawText(upgradeText, textSett);	
			bodyContainer.addChild(rewardTextLabel);
			rewardTextLabel.visible = false;
			
			if (upgradeBttn.visible) {
				bodyContainer.removeChild(whatToPlaceTextLabel);
				rewardTextLabel.visible = true;
				rewardTextLabel.x = 50;
				rewardTextLabel.y = upgradeBttn.y - 100;
			}
			
			drawProgress();
			drawItems();
		}
		
		public var container:Sprite = new Sprite();
		
		public function drawItems():void {
			for (var j:int = 0; j < items.length; j++) {
				
				container.removeChild(items[j]);
				items[j].dispose();
			}
			items = [];	
			
			var X:int = 0;
			var Y:int = 18;			
			settings.kicks.sortOn('o', Array.NUMERIC);		
			for (var i:int = 0; i < settings.kicks.length; i++)
			{
				var _item:UserShareItem = new UserShareItem(settings.kicks[i], this);
				container.addChild(_item);
				_item.x = X;
				_item.y = Y;
				items.push(_item);
				
				X += _item.bg.width + 10;
			}
			
			bodyContainer.addChild(container);
			container.x = (settings.width - container.width) / 2;
			container.y = 90;
			
			if (settings['content'].length > 0) {
				container.y = 110;
			}
			
			if (upgradeBttn.visible) {
				bodyContainer.removeChild(container);
			}
		}		
		
		public function progress():void {
			if (info.tower[floor + 1] && progressBar) {
				progressBar.progress = settings.target.kicks / info.tower[floor + 1].c;
				if (txtS) {
					txtS.text =  (info.tower.hasOwnProperty(floor + 1)) 
						? Locale.__e("flash:1382952380278", [settings.target.kicks, info.tower[floor + 1].c])
						: ''
				}
			}			
		}
		
		private function drawBttns():void {
			upgradeBttn = new Button({
				caption		:getTextFormInfo('text2'),
				width		:190,
				height		:52,	
				fontSize	:26 + fontOffset
			});
			
			hitBttn = new Button({
				caption		:getTextFormInfo('text5'),
				width		:190,
				height		:52,	
				fontSize	:36 + fontOffset
			});
			hitBttn.x = (settings.width - hitBttn.width) / 2;
			hitBttn.y = settings.height - upgradeBttn.height / 2-80;
			
			upgradeBttn.x = (settings.width - upgradeBttn.width) / 2;
			upgradeBttn.y = settings.height - upgradeBttn.height / 2 - 20;
			
			bodyContainer.addChild(upgradeBttn);
			upgradeBttn.showGlowing();
			bodyContainer.addChild(hitBttn);
			hitBttn.showGlowing();
			
			var skipPrice:int = 0
			if (info.tower[floor + 1] != null) {
				skipPrice = settings.target.info.kskip * (info.tower[floor + 1].c - settings.target.kicks);
			}
			
			accelerateBttn = new MoneyButton({
				caption			:Locale.__e('flash:1382952379751'),
				width			:192,
				height			:50,	
				fontSize		:26 + fontOffset,
				fontCountSize	:26,
				radius			:18,
				countText		:skipPrice,
				iconScale		:0.8,
				multiline		:true
			});
			
			upgradeBttn.addEventListener(MouseEvent.CLICK, kickEvent);
			hitBttn.addEventListener(MouseEvent.CLICK, buyAllEvent);
			accelerateBttn.addEventListener(MouseEvent.CLICK, buyKickEvent);
			
			//bodyContainer.addChild(accelerateBttn);
			accelerateBttn.x = ((settings.width - accelerateBttn.width) / 2) + 300;
			accelerateBttn.y = settings.height - accelerateBttn.height / 2 - 35;
			
			upgradeBttn.visible = false;
			hitBttn.visible = false;
			accelerateBttn.visible = false;
			
			if (floor > 0 || settings.target.kicks >= info.tower[floor+1].c) {
				if (info.tower[floor+1] != undefined && settings.target.kicks < info.tower[floor+1].c){
					hitBttn.visible = true;
					accelerateBttn.visible = true;
				}else if (info.tower[floor + 1] == undefined) {
					upgradeBttn.visible = false;
					hitBttn.visible = true;
				}else{
					upgradeBttn.visible = true;
					upgradeBttn.y -= 350;
				}
			}else{
				accelerateBttn.visible = true;
			}
			
			switch(info.burst) {
				case Floors.BURST_ONLY_ON_COMPLETE:
					if (info.tower[floor + 1] == null)
						hitBttn.visible = true;
					else
						hitBttn.visible = false;
				break;
				case Floors.BURST_NEVER:
					hitBttn.visible = false;
				break;	
			}
			if (hitBttn.visible) {
				
			}
		}
		
		public var skipPrice:int;
		private function buyAllEvent(e:MouseEvent):void {
			if (e.currentTarget.mode == Button.DISABLED) return;
			e.currentTarget.state = Button.DISABLED;
			
			settings.storageEvent(0, onStorageEventComplete);
		}
		
		private function kickEvent(e:MouseEvent):void {
			if (e.currentTarget.mode == Button.DISABLED) return;
			e.currentTarget.state = Button.DISABLED;
			settings.upgradeEvent( {} );
			settings.content = [];
			close();
		}
		
		private var price:int;
		private function buyKickEvent(e:MouseEvent):void {
			
			price = (info.tower[floor + 1].c - settings.target.kicks) * settings.target.info.kskip;
			
			if (!App.user.stock.check(Stock.FANT, price))
				return;
			
			if (e.currentTarget.mode == Button.DISABLED) return;
			e.currentTarget.state = Button.DISABLED;
			
			settings.buyKicks({
				callback:onBuyKicks
			});
		}
		
		private function onBuyKicks():void {
			if (titleTxt)
				bodyContainer.removeChild(titleTxt);
				
			//drawStageInfo();	
			//titleTxt.x = kickTextPosX;
			
			Hints.minus(Stock.FANT, price, Window.localToGlobal(accelerateBttn), false, this);
			App.user.stock.take(Stock.FANT, price);
			
			/*titleTxt.y = kickTextPosY;
			titleTxt.x = kickTextPosX;*/
			upgradeBttn.visible = true;
			accelerateBttn.visible = false;
			hitBttn.visible = false;
		}
		
		public function onStorageEventComplete(sID:uint, price:uint):void {
			
			if (price == 0 ) {
				close();
				return;
			}
			var X:Number = App.self.mouseX - upgradeBttn.mouseX + upgradeBttn.width / 2;
			var Y:Number = App.self.mouseY - upgradeBttn.mouseY;
			Hints.minus(sID, price, new Point(X, Y), false, App.self.tipsContainer);
			close();
		}
		
		private var separator:Bitmap;
		private var separator2:Bitmap;
		private function drawVisitors():void {			
			separator = Window.backingShort(settings.width - 150, 'dividerLine', false);
			separator.x = 75;
			separator.y = 360;
			separator.alpha = 0.5;
			bodyContainer.addChild(separator);
			
			separator2 = Window.backingShort(settings.width - 150, 'dividerLine', false);
			separator2.x = 75;
			separator2.y = 545;
			separator2.alpha = 0.5;
			bodyContainer.addChild(separator2);
			
			var text:String = Locale.__e(settings.target.info.text1);
			var label:TextField = drawText(text, {
				fontSize:28 + fontOffset,
				autoSize:"center",
				textAlign:"center",
				color:0xffffff,
				borderColor:0x764413,
				border:true
			});
			
			label.width = settings.width - 50;
			label.height = label.textHeight;
			label.x = (settings.width - label.width) / 2;
			label.y = 360 - 13;
			
			//bodyContainer.addChild(back);
			bodyContainer.addChild(label);
			
			if (settings['content'].length > 0){
				contentChange();
				drawNotif();
			}else{
				drawNotif();
			}	
		}
		
		private function drawNotif():void 
		{
			if (info.tower[floor + 1] == undefined)
				return;
			
			var bttnSettings:Object = {
				caption		:Locale.__e("flash:1407159672690"),//Пpигласить
				width		:230,
				height		:48,	
				fontSize	:25 + fontOffset
			}
			
			if (settings['content'].length > 0) {
				bttnSettings['width'] = 180;
				bttnSettings['height'] = 44;
				bttnSettings['fontSize'] = 26 + fontOffset;
				bttnSettings['caption'] = Locale.__e("flash:1382952379977");//Пригласить ещё
			}
			
			notifBttn = new Button(bttnSettings);			
			notifBttn.x = (settings.width - notifBttn.width) / 2;			
			if (settings['content'].length > 0) {
				notifBttn.y = separator2.y - notifBttn.height / 2 + 30;
			}else {
				notifBttn.y = separator2.y - notifBttn.height / 2;
			}
			
			bodyContainer.addChild(notifBttn);
			notifBttn.addEventListener(MouseEvent.CLICK, onNotifClick);
		}
		
		private function onNotifClick(e:MouseEvent):void 
		{
			switch(App.self.flashVars.social) {
				case 'VK':
				case 'DM':
				case 'FS':
					new AskWindow(AskWindow.MODE_INVITE_INGAME, {
						target:settings.target,
						title:Locale.__e('flash:1382952380197'), 
						friendException:settings.friendsData, 
						inviteTxt:Locale.__e("flash:1395846352679"),
						desc:getTextFormInfo('text4')
					},
					function(uid:*):void {
						ExternalApi.notifyFriend( {
							uid:	String(uid),
							text:	info.text8,
							type:	'gift'
						})
					}).show();
					break;
				default:
					ExternalApi.apiInviteEvent();
			}
		}
		
		override public function drawArrows():void 
		{
			paginator.drawArrow(bodyContainer, Paginator.LEFT,  0, 0, { scaleX: -1, scaleY:1 } );
			paginator.drawArrow(bodyContainer, Paginator.RIGHT, 0, 0, { scaleX:1, scaleY:1 } );
			
			var y:Number = 545 / 2 - paginator.arrowLeft.height / 2;
			paginator.arrowLeft.x = -paginator.arrowLeft.width / 2 + 95;
			paginator.arrowLeft.y = y;
			
			paginator.arrowRight.x = settings.width - paginator.arrowRight.width / 2 - 15;
			paginator.arrowRight.y = y;
			
			
		}
		
		public function updateItems():void {
			if (floor > 0 || settings.target.kicks >= info.tower[floor+1].c) {
				if (info.tower[floor+1] != undefined && settings.target.kicks < info.tower[floor+1].c){
					hitBttn.visible = true;
					accelerateBttn.visible = true;
				}else if (info.tower[floor + 1] == undefined) {
					upgradeBttn.visible = false;
					hitBttn.visible = true;
				}else{
					upgradeBttn.visible = true;
					upgradeBttn.y -= 350;
				}
			}else{
				accelerateBttn.visible = true;
			}
			
			switch(info.burst) {
				case Floors.BURST_ONLY_ON_COMPLETE:
					if (info.tower[floor + 1] == null)
						hitBttn.visible = true;
					else
						hitBttn.visible = false;
				break;
				case Floors.BURST_NEVER:
					hitBttn.visible = false;
				break;	
			}
			
			if (upgradeBttn.visible && bodyContainer.contains(backSmall)) {
				bodyContainer.removeChild(backSmall);
			}
			if (upgradeBttn.visible && bodyContainer.contains(whatToPlaceTextLabel)) {
				bodyContainer.removeChild(whatToPlaceTextLabel);
				rewardTextLabel.visible = true;
				rewardTextLabel.x = 50;// upgradeBttn.x - 70;
				rewardTextLabel.y = upgradeBttn.y - 100;
			}
			
			drawItems();
			progress();		
		}
		
		public override function contentChange():void {			
			contentManager.update(paginator.startCount, paginator.finishCount);				
		}
	
		override public function dispose():void {
			upgradeBttn.removeEventListener(MouseEvent.CLICK, kickEvent);
			hitBttn.removeEventListener(MouseEvent.CLICK, buyAllEvent);
			if (notifBttn != null) notifBttn.addEventListener(MouseEvent.CLICK, onNotifClick);
			super.dispose();
		}
		
		public function disposeProgress():void {
			bodyContainer.removeChild(progressBar);
		}
		
		public function getTextFormInfo(value:String):String {
			var text:String = settings.target.info[value];
			text = text.replace(/\r/, "");
			return Locale.__e(text);
		}
	}		
}

import core.Size;
import buttons.Button;
import core.Load;
import core.Post;
import flash.display.Bitmap;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.text.TextField;
import ui.Hints;
import units.Bar;
import wins.elements.PriceLabel;
import wins.ShopWindow;
import wins.SimpleWindow;
import wins.TravelWindow;
import wins.Window;

internal class UserShareItem extends LayerX{
	
	public var window:*;
	public var item:Object;
	public var bg:Bitmap;
	private var bitmap:Bitmap;
	private var sID:uint;
	public var bttn:Button;
	public var findBttn:Button;
	private var kicks:uint;
	private var type:uint;
	private var kicksNum:uint;
	public var iNum:Object;
	
	public function UserShareItem(obj:Object, window:*) {
		
		this.type = obj.t;
		this.sID = obj.sID;
		this.kicks = window.info.mkicks[sID].c;
		this.item = App.data.storage[sID];
		this.kicksNum = window.info.mkicks[sID].k;
		this.window = window;
		
		bg = Window.backing(135, 170, 20, 'itemBacking');
		addChild(bg);
		
		bitmap = new Bitmap();
		addChild(bitmap);
		
		Load.loading(Config.getIcon(item.type, item.preview), onLoad);
		
		drawTitle();
		drawLabel();
		drawkicksNum();
		
		tip = function():Object {
			return {
				title: Locale.__e(item.title),
				text: Locale.__e(item.description)
			}
		}
	}
	
	private function drawBttn():void {
		var bttnSettings:Object = {
			caption:window.getTextFormInfo('text7'),
			width:120,
			height:38,
			fontSize:23
		}
		
		if(item.real == 0 || type == 1){
			bttnSettings['borderColor'] = [0xaff1f9, 0x005387];
			bttnSettings['bgColor'] = [0x70c6fe, 0x765ad7];
			bttnSettings['fontColor'] = 0x453b5f;
			bttnSettings['countText'] = item.real;
		}
		
		bttn = new Button(bttnSettings);		
		addChild(bttn);
		bttn.x = (bg.width - bttn.width) / 2;
		bttn.y = bg.height - bttn.height + 20;
		bttn.addEventListener(MouseEvent.CLICK, onClick);
		
		if (item.real == 0 && App.user.friends.data[App.owner.id]['energy'] <= 0 &&App.user.stock.data[Stock.GUESTFANTASY] <= 0){
			bttn.state = Button.DISABLED;
		}
	}
	
	private function onFind(e:MouseEvent):void {
		if (e.currentTarget.mode == Button.DISABLED) return;
		Window.closeAll();
		if (!ShopWindow.findMaterialSource(sID)) {
			TravelWindow( { find:[1907] } );
		}
	}
	
	private function onClick(e:MouseEvent):void {
		if (e.currentTarget.mode == Button.DISABLED) return;
		
		switch(type) {
			case 2:
				if (!App.user.stock.check(Stock.FANT, item.real)) 
					return;
			break;
			case 3:
				if (!App.user.stock.check(sID, 1)) 
					return;
			break;
		}
		
		bttn.state = Button.DISABLED;
		window.settings.mKickEvent(sID, onKickEventComplete, type);
	}
	
	private function onKickEventComplete(bonus:Object = null):void {
		var sID:uint;
		var price:uint;
		if (type == 1) {
			window.close();
			return;
		}
		else if (type == 2) {
			sID = Stock.FANT;
			price = item.price[Stock.FANT];
		}
		else if (type == 3) {
			sID = this.sID;
			price = 1;
		}	
		
		if (bonus){
			flyBonus(bonus);
		}
		bttn.state = Button.NORMAL;
		
		var X:Number = App.self.mouseX - bttn.mouseX + bttn.width / 2;
		var Y:Number = App.self.mouseY - bttn.mouseY;
		Hints.minus(sID, price, new Point(X, Y), false, App.self.tipsContainer);
		
		if (label) label.text = Locale.__e('flash:1409236136005') + ' ' + String(App.user.stock.count(sID));
		if (type == 3 && !App.user.stock.check(sID, 1)) { 
			findBttn.visible = true;
			bttn.visible = false;
		}
		//window.settings.target.kicks += kicksNum;
		window.updateItems();
	}	
	
	private function flyBonus(data:Object):void {
		var targetPoint:Point = Window.localToGlobal(bttn);
		targetPoint.y += bttn.height / 2;
		for (var _sID:Object in data)
		{
			var sID:uint = Number(_sID);
			for (var _nominal:* in data[sID])
			{
				var nominal:uint = Number(_nominal);
				var count:uint = Number(data[sID][_nominal]);
			}
			
			var item:*;
			
			for (var i:int = 0; i < count; i++)
			{
				item = new BonusItem(sID, nominal);
				App.user.stock.add(sID, nominal);	

				item.cashMove(targetPoint, App.self.windowContainer)
			}			
		}
		SoundsManager.instance.playSFX('reward_1');
	}
	
	private function onLoad(data:Bitmap):void {
		bitmap.bitmapData = data.bitmapData;	
		Size.size(bitmap, 100, 100);
		bitmap.x = (bg.width - bitmap.width) / 2;
		bitmap.y = (bg.height - bitmap.height) / 2 - 10;
	}
	
	
	public function dispose():void {
		bttn.removeEventListener(MouseEvent.CLICK, onClick);
	}
	
	private var title:TextField; 	
	public function drawTitle():void {
		title = Window.drawText(String(item.title), {
			color:0x6d4b15,
			borderColor:0xfcf6e4,
			textAlign:"center",
			autoSize:"center",
			fontSize:20,
			textLeading:-6,
			multiline:true
		});
		title.wordWrap = true;
		title.width = bg.width - 10;
		title.height = title.textHeight;
		title.y = 5;
		title.x = 5;
		addChild(title);		
	}
	
	private var kicksNumLable:TextField; 
	private var kicksNumAmount:int; 	
	private function drawkicksNum():void {
		kicksNumAmount = kicksNum;
		kicksNumLable = Window.drawText("+"+String(kicksNumAmount),{
			fontSize		:22,
			color			:0x814f31,
			borderColor		:0xffffff,
			autoSize		:"left"
		});		
		addChildAt(kicksNumLable, 3);
		kicksNumLable.y = title.y + title.height - 2;
		kicksNumLable.x = (title.x + (title.width / 2)) - 15;
	}
	
	private var label:TextField;
	private var count_txt:TextField; 
	public function drawLabel():void {
		var bttnSettings:Object = {
			caption:window.getTextFormInfo('text7'),
			width:120,
			height:38,
			fontSize:23
		}
		
		if (App.user.mode == User.OWNER) bttnSettings['caption'] = Locale.__e('flash:1461683580268');
		
		var price:PriceLabel;
		var text:String = '';
		var hasButton:Boolean = true;
		if (type == 2) { // за кристалы
			bttnSettings["bgColor"] = [0x97c9fe, 0x5e8ef4];
			bttnSettings["borderColor"] = [0xffdad3, 0xc25c62];
			bttnSettings["bevelColor"] = [0xb3dcfc, 0x376dda];
			bttnSettings["fontColor"] = 0xffffff;			
			bttnSettings["fontBorderColor"] = 0x395db3;
			bttnSettings["greenDotes"] = false;
			bttnSettings["diamond"] = "diamond";
			if (item.price && !bttnSettings["countText"]) 
			{
				bttnSettings["countText"] = item.price[Stock.FANT];
			}
			price = new PriceLabel(item.price);
			addChild(price);
			price.x = (bg.width - price.width) / 2;
			price.y = 110;
		}
		else if (type == 3) {// со склада			
			var count:int; 
			count = App.user.stock.count(sID);
			count_txt = Window.drawText("x"+String(count),{
				fontSize		:30,
				color			:0xffffff,
				borderColor		:0x6d4b15,
				autoSize:"left"
			});
			
			count_txt.x = (bg.width - count_txt.width) / 2;
			count_txt.y = 106;
			addChild(count_txt);
		}
		else if (type == 1) { // за фантазию
			var guests:Object = window.settings.target.guests;
			
			if (guests.hasOwnProperty(App.user.id) && guests[App.user.id] > 0 && guests[App.user.id] > App.midnight) {
				text = Locale.__e("flash:1382952380288");//Один раз в день
				hasButton = false;
			}
			else if (window.settings.target is Bar && window.settings.target.items <= 0) {	
				text = Locale.__e("flash:1383041104026"); //Нет
				hasButton = false;
			}
			else {
				var prOb:Object = new Object();
				prOb[Stock.GUESTFANTASY] = 1;
				price = new PriceLabel(prOb);
				addChild(price);
				price.x = (bg.width - price.width) / 2;
				price.y = 110;
			}
		}
		
		if(text != '')
		{
			label = Window.drawText(text, {
				color:0x6d4b15,
				borderColor:0xfcf6e4,
				textAlign:"center",
				autoSize:"center",
				fontSize:20,
				textLeading:-6,
				multiline:true
			});
			
			label.wordWrap = true;
			label.width = bg.width - 10;
			label.height = label.textHeight;
			label.y = 140;
			label.x = 5;
			addChild(label);
		}
		
		bttn = new Button(bttnSettings);
		if (!hasButton)
			return;
			
		addChild(bttn);
		bttn.x = (bg.width - bttn.width) / 2;
		bttn.y = bg.height - bttn.height + 12;
		bttn.addEventListener(MouseEvent.CLICK, onClick);
		
		bttnSettings['caption'] = Locale.__e('flash:1405687705056');
		
		findBttn = new Button(bttnSettings);
		addChild(findBttn);
		findBttn.x = (bg.width - findBttn.width) / 2;
		findBttn.y = bg.height - findBttn.height + 12;
		findBttn.addEventListener(MouseEvent.CLICK, onFind);
		findBttn.visible = false;
		
		if(type == 2 && App.user.stock.data["27"] <= item.price["27"]){
			//bttn.state = Button.DISABLED;
		}else if(type == 3) {
			if (App.user.stock.count(sID) <= 0) {
				bttn.visible = false;
				findBttn.visible = true;
			} else {
				bttn.visible = true;
				findBttn.visible = false;
			}
		}
		
		if (!window.info.tower[window.floor + 1]) {
			bttn.state = Button.DISABLED;
		}
	}
}

