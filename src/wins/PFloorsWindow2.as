package wins {
	
	import units.Share;
	import api.ExternalApi;
	import buttons.Button;
	import buttons.MoneyButton;
	import core.Load;
	import core.Log;
	import core.Numbers;
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
	import core.Numbers;
	import ui.UserInterface;
	import core.Post;
	
	public class PFloorsWindow2 extends Window {
		
		private var items:Array = new Array();
		public var info:Object;
		public var back:Bitmap;
		public var backSmall:Bitmap;
		public var hitBttn:Button;
		public var upgradeBttn:Button;
		private var accelerateBttn:MoneyButton
		public var contentManager:ContentManager;
		public var notifBttn:Button = null;
		public var whatToPlaceTextLabel:TextField;
		public var bar:ProgressBar;
		public var visitorsBar:ProgressBar;
		public var itemsNum:int;
		public var rewardTextLabel:TextField;
		public var type:int = Floors.ONE_SIDE_KICK;
		
		public function PFloorsWindow2(settings:Object = null) {
			if (settings == null) {
				settings = new Object();
			}
			info = settings.target.info;
			//info["additionalBonuses"] = ["77_floors_kick_1", "77_floors_kick_2", "77_floors_kick_3" ]
			settings['itemsNum'] = Numbers.countProps(settings.target.info.kicks);
			//settings['background'] = "questBacking";
			settings['background'] = "alertBacking";
			settings['width'] = (settings['itemsNum'] == 4)?526 + 160:526 + 100;
			settings['height'] = 654;
			
			settings['title'] = info.title;
			settings['hasPaginator'] = true;
			settings['hasButtons'] = false;
			settings['hasArrow'] = true;
			settings['itemsOnPage'] = 7;			
			settings['content'] = [];
			settings['kicks'] = [];
			settings['cols'] = 7;
			
			type = Floors.TWO_SIDE_KICK;
			settings['height'] = 670;
			
			itemsNum = settings.itemsNum;
			
			for (var _uid:* in settings.target.guests) {
				if (!App.user.friends.data.hasOwnProperty(_uid)) continue;
				//for (var u:int = 0; u < 20; u++ )
				settings['content'].push( { uid:_uid, time:settings.target.guests[_uid], addParams:[this] } );
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
			
			settings['kicks'].sortOn('o', Array.NUMERIC);
			
			contentManager = new ContentManager( { from:0, to:settings['itemsOnPage'], cols:settings['cols'], content:settings['content'], itemType:'FriendItem', margin:0 } );
			
			if (settings.target.hasOwnProperty('floor')) {
				floor = settings.target.floor
			} else {
				floor = settings.target.level
			}
			if (!info.tower[floor + 1]) {
				settings['height'] = 450;
				settings['width'] = 500;
			}
			super(settings);
		}
		
		public var floor:int = 0;
		public var titleTxt:Sprite;
		
		public function drawProgress():void {
			if (!info.tower[floor + 1]) return;
			var progressBacking:Bitmap = Window.backingShort(400, "progBarBacking");
			progressBacking.x = (settings.width - progressBacking.width) / 2;
			progressBacking.y = 100;
			bodyContainer.addChild(progressBacking);
			
			var barSettings:Object = {
				width:416,
				win:this.parent,
				isTimer:false
			};
			
			bar = new ProgressBar(barSettings);
			bar.x = progressBacking.x - 8;
			bar.y = progressBacking.y - 4;
			bodyContainer.addChild(bar);
				
			bar.start();
			
			txtS = drawText('', {
				width:bar.width,
				fontSize:26,
				color:0xFFFFFF,
				autoSize:"center",
				borderColor:0x704a26
			});
			txtS.x = (settings.width - txtS.width) / 2;
			txtS.y = bar.y + 4;
			bodyContainer.addChild(txtS);
			
			var progressBacking2:Bitmap = Window.backingShort(400, "progBarBacking");
			progressBacking2.x = (settings.width - progressBacking2.width) / 2;
			progressBacking2.y = back.y - progressBacking2.height - 15;
			bodyContainer.addChild(progressBacking2);
			
			var barSettings2:Object = {
				width:416,
				win:this.parent,
				isTimer:false
			};
			
			visitorsBar = new ProgressBar(barSettings2);
			visitorsBar.x = progressBacking2.x - 8;
			visitorsBar.y = progressBacking2.y - 4;
			bodyContainer.addChild(visitorsBar);
				
			visitorsBar.start();
			
			txtSVisitiors = drawText('', {
				width:visitorsBar.width,
				fontSize:26,
				color:0xFFFFFF,
				autoSize:"center",
				borderColor:0x704a26
			});
			txtSVisitiors.x = (settings.width - txtSVisitiors.width) / 2;
			txtSVisitiors.y = visitorsBar.y + 4;
			bodyContainer.addChild(txtSVisitiors);
			
			progress();
			
			var inviteText:TextField = drawText(Locale.__e("flash:1479208878873"), {
				width:400,
				fontSize:26,
				color:0xFFFFFF,
				autoSize:"center",
				borderColor:0x704a26
			});
			
			inviteText.x = (settings.width - inviteText.width) / 2;
			inviteText.y = progressBacking2.y - inviteText.height - 10;
			bodyContainer.addChild(inviteText);
		}
		private var txtS:TextField;		
		private var txtSVisitiors:TextField;	
		public function progress():void {
			if (info.tower[floor + 1]) {
				if (bar)
				{
					bar.progress = settings.target.mykicks / info.tower[settings.target.floor + 1].m;
					if (txtS) {
						txtS.text =  (info.tower.hasOwnProperty(floor + 1)) 
							? Locale.__e("flash:1382952380278", [settings.target.mykicks, info.tower[settings.target.floor + 1].m])
							: ''
					}
				}
				
				if (visitorsBar)
				{
					visitorsBar.progress = settings.target.kicks / info.tower[settings.target.floor + 1].c;
					if (txtSVisitiors) {
						txtSVisitiors.text =  (info.tower.hasOwnProperty(floor + 1)) 
							? Locale.__e("flash:1382952380278", [settings.target.kicks, info.tower[settings.target.floor + 1].c])
							: ''
					}
				}
			}			
		}
		
		public function get kickTextPosY():int {
			return settings.height - 200 / 2 - 90;
		}
		
		public function get kickTextPosX():int {
			return (settings.width - 200) / 2;
		}
		
		public function stageInfoAlign():void {
			var _text:String = (info.tower[floor + 1] != undefined)
						?getTextFormInfo('text3') +' '+ Locale.__e("flash:1382952380278", [settings.target.kicks, info.tower[floor + 1].c])
						:getTextFormInfo('text9');
			var _title:TextField = drawText(_text, {
				fontSize:36
			});
		}
		
		override public function drawBody():void {
			exit.y -= 26;
			//drawMirrowObjs('diamondsTop', settings.width / 2 - settings.titleWidth / 2 - 5, settings.width / 2 + settings.titleWidth / 2 + 5, -50, true, true);
			//drawMirrowObjs('storageWoodenDec', -4, settings.width + 0, settings.height - 109);
			//drawMirrowObjs('storageWoodenDec', -4, settings.width + 0, 39, false, false, false, 1, -1);
			
			drawVisitors();
			
			if (settings.content.length == 0) {
				var descText:String = 'text4';
				if (floor > 0) {
					if (info.tower[floor + 1] == undefined ) {
						descText = 'text9'
					}
				}
				var descriptionLabel:TextField = drawText(getTextFormInfo(descText), {
					fontSize:28,
					textAlign:"center",
					color:0xffffff,
					borderColor:0x624512,
					textLeading:-9
				});
				descriptionLabel.width = descriptionLabel.textWidth + 10;
				descriptionLabel.height = descriptionLabel.textHeight + 10;
				descriptionLabel.x = (settings.width - descriptionLabel.width) / 2;
				descriptionLabel.y = 110 - bodyContainer.y + (170 - descriptionLabel.textHeight)/2;
			}
			drawBttns();
			
			var levelTextTabel:TextField = Window.drawText(Locale.__e("flash:1442499086598") + " " +  (settings.target.floor + 1) + "/" + (settings.target.totalFloors + 1), {
				fontSize:30,
				color:0x763b18,
				autoSize:"left",
				borderColor:0xfffae8
			});
			levelTextTabel.x = settings.width / 2 - levelTextTabel.width / 2;
			levelTextTabel.y = 15;
			bodyContainer.addChild(levelTextTabel);
			
			var descriptionTextTabel:TextField = Window.drawText(Locale.__e("flash:1479223903184"), {
				fontSize:24,
				color:0x763b18,
				autoSize:"left",
				borderColor:0xfffae8
			});
			descriptionTextTabel.x = settings.width / 2 - descriptionTextTabel.width / 2;
			descriptionTextTabel.y = levelTextTabel.y + levelTextTabel.height + 5;
			bodyContainer.addChild(descriptionTextTabel);
			
			fixContentManager();
			bodyContainer.addChild(contentManager);
			
			backSmall = Window.backing((settings.itemsNum == 4)?320 + 297:320, 220, 50, 'stoneMainInnerBacking');
			backSmall.x = (settings.width - backSmall.width) / 2;
			backSmall.y = 100 - 18;
			backSmall.alpha = 1;
			//bodyContainer.addChild(backSmall);
			
			if (upgradeBttn.visible || !info.tower[floor + 1]) {
				//bodyContainer.removeChild(backSmall);
			}
			
			whatToPlaceTextLabel = drawText('', {
				fontSize:26,
				autoSize:"center",
				textAlign:"center",
				color:0xfffae8,
				borderColor:0x5f4629,
				border:true
			});
			whatToPlaceTextLabel.x = backSmall.x + (backSmall.width / 2) - (whatToPlaceTextLabel.width / 2);
			whatToPlaceTextLabel.y = backSmall.y - 14;
			bodyContainer.addChild(whatToPlaceTextLabel);	
			
			var upgradeText:String = getTextFormInfo('text9');
			
			var textSett:Object = {
				width		:400,
				height		:400,
				fontSize	:27,
				//textAlign	:"left",
				textAlign	:"center",
				color		:0xffffff,
				borderColor:0x784727,
				multiline	:true,
				wrap		:true
			}
			
			rewardTextLabel = Window.drawText(upgradeText, textSett);	
			bodyContainer.addChild(rewardTextLabel);
			rewardTextLabel.visible = false
			
			if (upgradeBttn.visible) {
				bodyContainer.removeChild(whatToPlaceTextLabel);
				rewardTextLabel.visible = true;
				rewardTextLabel.x = (settings.width - rewardTextLabel.width) / 2;
				rewardTextLabel.y = upgradeBttn.y - 100;
				//rewardTextLabel.y = 110 - bodyContainer.y + (170 - rewardTextLabel.textHeight)/2;;
			}
			
			drawProgress();
			drawItems();
			if (!info.tower[floor + 1]) {
				rewardTextLabel.visible = true;
				rewardTextLabel.x = (settings.width - rewardTextLabel.width) / 2;
				rewardTextLabel.y = (settings.height - rewardTextLabel.height) / 2 - bodyContainer.y;
				if (bar && bar.parent) {
					bar.parent.removeChild(bar);
				}
				if (whatToPlaceTextLabel && whatToPlaceTextLabel.parent) {
					whatToPlaceTextLabel.parent.removeChild(whatToPlaceTextLabel);
				}
			}
		}
		
		private var back2:Bitmap
		public var container:Sprite = new Sprite();
		public function drawItems():void {
			for (var j:int = 0; j < items.length; j++) {
				container.removeChild(items[j]);
				items[j].dispose();
			}
			items = [];
			if (!info.tower[floor + 1]) {
				return;
			}
			var X:int = 0;
			var Y:int = 0;
			
			settings.kicks.sortOn('o', Array.NUMERIC);
			for (var i:int = 0; i < settings.kicks.length; i++) {
				var _item:UserShareItem = new UserShareItem(settings.kicks[i], this);
				container.addChild(_item);
				_item.x = X;
				_item.y = Y;
				items.push(_item);
				
				X += _item.bg.width + 28;
			}
			
			container.x = (settings.width - container.width) / 2;
			container.y = 160;
			bodyContainer.addChild(container);
			
			if (!back2)
			{
				var separator:Bitmap = Window.backingShort(settings.width - 95, 'dividerLine', false);
				separator.x = back.x + 3;
				separator.y = container.height + container.y + 5;
				separator.alpha = 0.7;
				bodyContainer.addChild(separator);
				
				var separator2:Bitmap = Window.backingShort(settings.width - 95, 'dividerLine', false);
				separator2.x = back.x + 3;
				separator2.y = container.y - 15;
				separator2.alpha = 0.7;
				bodyContainer.addChild(separator2);
				
				back2 = Window.backing(settings.width - 95, container.height + 20, 20, 'fadeOutWhite');
				back2.x = back.x + 3;
				back2.y = container.y - 15;
				back2.alpha = 0.3;
				bodyContainer.addChildAt(back2, 0);
			}
			if (upgradeBttn.visible) {
				bodyContainer.removeChild(container);
				notifBttn.visible = false;
			}
			else
			{
				notifBttn.visible = true;
			}
		}
		
		public function disableItems():void {
			if (info.tower[floor + 1] && info.tower[floor + 1].m <= settings.target.mykicks) {
				for (var i:* in items) {
					items[i].bttn.state = Button.DISABLED;
				}
			}
		}
		
		private function drawBttns():void {
			upgradeBttn = new Button({
				caption		:getTextFormInfo('text2'),
				width		:190,
				height		:52,	
				fontSize	:26
			});
			
			hitBttn = new Button({
				caption		:getTextFormInfo('text5'),
				width		:190,
				height		:52,	
				fontSize	:36
			});
			hitBttn.x = (settings.width - hitBttn.width) / 2;
			hitBttn.y = settings.height - upgradeBttn.height / 2 - 80;
			
			upgradeBttn.x = (settings.width - upgradeBttn.width) / 2;
			upgradeBttn.y = settings.height - upgradeBttn.height / 2 - 20 - 30;
			bodyContainer.addChild(upgradeBttn);
			upgradeBttn.showGlowing();
			bodyContainer.addChild(hitBttn);
			hitBttn.showGlowing();
			
			var skipPrice:int = 0
			if (info.tower[floor + 1] != null) {
				skipPrice = settings.target.info.kskip * (info.tower[floor + 1].c - settings.target.kicks);
				if (skipPrice < 0) skipPrice = 0;
			}
			
			accelerateBttn = new MoneyButton({
				caption			:Locale.__e('flash:1382952379751'),
				width			:192,
				height			:50,	
				fontSize		:26,
				fontCountSize	:26,
				radius			:18,
				countText		:skipPrice,
				iconScale		:0.8,
				multiline		:true
			});
			if (info.tower[floor+1] && info.tower[floor + 1].c <= settings.target.kicks) {
				accelerateBttn.state = Button.DISABLED;
			}
			upgradeBttn.addEventListener(MouseEvent.CLICK, kickEvent);
			hitBttn.addEventListener(MouseEvent.CLICK, buyAllEvent);
			accelerateBttn.addEventListener(MouseEvent.CLICK, buyKickEvent);
			
			accelerateBttn.x = ((settings.width - accelerateBttn.width) / 2) + 300;
			accelerateBttn.y = settings.height - accelerateBttn.height / 2 - 35;
			
			upgradeBttn.visible = false;
			hitBttn.visible = false;
			accelerateBttn.visible = false;
			
			if (floor > 0 || canBeUpgraded) {
				if (info.tower[floor+1] != undefined && !canBeUpgraded){
					hitBttn.visible = true;
					accelerateBttn.visible = true;
				} else if (info.tower[floor + 1] == undefined) {
					upgradeBttn.visible = false;
					hitBttn.visible = true;
				} else {
					upgradeBttn.visible = true;
					upgradeBttn.y -= 350 - 30;
				}
			} else {
				accelerateBttn.visible = true;
				
			}
			bodyContainer.addChild(accelerateBttn);
			var padd:int = 20;
			if(notifBttn){
				var sumWd:int = accelerateBttn.width + padd + (notifBttn?notifBttn.width:0);
				accelerateBttn.x = back.x + (back.width) / 2 - sumWd / 2;
				if(accelerateBttn.visible){
					notifBttn.x = accelerateBttn.x + accelerateBttn.width + padd;
				}else {
					notifBttn.x = back.x + back.width / 2 - notifBttn.width / 2;
				}
				accelerateBttn.y = notifBttn.y;
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
			
			if(visitorsBar){
				upgradeBttn.y = visitorsBar.y - upgradeBttn.height - 20;
			}else {
				upgradeBttn.y = (settings.height - upgradeBttn.height) / 2 - bodyContainer.y - 30;
			}
		}
		
		public var skipPrice:int;
		private function buyAllEvent(e:MouseEvent):void {
			if (e.currentTarget.mode == Button.DISABLED) return;
			e.currentTarget.state = Button.DISABLED;
			
			if (info.hasOwnProperty("bonus") && info.bonus)
			{
				var bonus:Object = { };
				
				for (var i:String in info.bonus)
				{
					var treasure:Object = App.data.treasures[info.bonus[i]][info.bonus[i]];
					bonus[treasure.item[0]] = treasure.count[0];
				}
				new SelectRewardWindow( {bonus:info.bonus,
					title:getTextFormInfo('text5'),
					callback:selectItemEvent,
					popup:true
				}).show();
			}
			//settings.storageEvent(0, onStorageEventComplete);
		}
		
		private function selectItemEvent(id:*):void
		{
			trace();
			
			var self:Share = settings.target;
			
			for (var index:String in settings.target.info.bonus)
			{
				if (settings.target.info.bonus[index] == id)
				{
					settings.storageEvent(int(index), onStorageEventComplete);
					
					//var sendObject:Object = {
						//ctr:settings.target.type,
						//act:'storage',
						//uID:App.user.id,
						//wID:App.user.worldID,
						//sID:settings.target.sid,
						//id:settings.target.id,
						//iID:index
					//}
				}
			}
			
			//Post.send(sendObject,
			//function(error:int, data:Object, params:Object):void {
				//
				//if (error) {
					//Errors.show(error, data);
					//return;
				//}
				//
				//var bonus:Object = { };
				//
				//if (data.hasOwnProperty('bonus'))
					//bonus = data.bonus;
				//
				//if (data.hasOwnProperty('timer'))
					//(self as Floors).timer = data.timer;
				//else 
					//(self as Floors).timer = App.time;
				//
				//callback(Stock.FANT, boost, bonus);
				//
				//if (data.hasOwnProperty(Stock.FANT))
					//App.user.stock.data[Stock.FANT] = data[Stock.FANT];
				//
				//if (data.hasOwnProperty('bonus') && type == "Pfloors")
					//Treasures.packageBonus(data.bonus, new Point(self.x, self.y));
//
				//
				//if (info.burst == BURST_ONLY_ON_COMPLETE)
				//{
					//if (type == "Pfloors")
					//{
						////floor = -1;
						////updateLevel();
					//}
					//free();
					//changeOnDecor();
					//take();
				//}else if (info.burst == BURST_ON_TIME) {
					//floor = 0;
					//kicks = 0;
					//totalFloors = 1;
					//kicksLimit = info.tower[totalFloors].c;
				//}else{
					//uninstall();
				//}
				//
				//self = null;
			//});
		}
		
		private function kickEvent(e:MouseEvent):void {
			if (e.currentTarget.mode == Button.DISABLED) return;
			e.currentTarget.state = Button.DISABLED;
			settings.upgradeEvent( {} );
			settings.content = [];
			close();
		}
		
		override public function close(e:MouseEvent = null):void {
			if (settings.hasAnimations == true) {
				startCloseAnimation();
			} else {
				dispatchEvent(new WindowEvent("onBeforeClose"));
				new SimpleWindow({title:"ВСё",text:"Строили мы строили..",description:'И ,наконец, построили!'});
				dispose();
			}
		}
		
		private var price:int;
		private function buyKickEvent(e:MouseEvent):void {
			if (accelerateBttn.mode == Button.DISABLED) return;
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
			
			progress();
			
			Hints.minus(Stock.FANT, price, Window.localToGlobal(accelerateBttn), false/*, this*/);
			App.user.stock.take(Stock.FANT, price);
			updateItems();
			if(canBeUpgraded){
				upgradeBttn.visible = true;
				accelerateBttn.state = Button.DISABLED;
			}
		}
		
		public function onStorageEventComplete(sID:uint, price:uint, bonus:Object = null):void {
			if (price == 0 ) {
				close();
				return;
			}
			var X:Number = App.self.mouseX - upgradeBttn.mouseX + upgradeBttn.width / 2;
			var Y:Number = App.self.mouseY - upgradeBttn.mouseY;
			Hints.minus(sID, price, new Point(X, Y), false, App.self.tipsContainer);
			close();
		}
		
		private function drawVisitors():void {
			if (!info.tower[floor + 1]) return;
			if (!back)
			{
				back = Window.backing(settings.width - 95, 130, 20, 'fadeOutWhite');
				back.x = (settings.width - back.width) / 2;
				back.y = 390 + moveContentY;
				back.alpha = 0.3;
				bodyContainer.addChild(back);
				
				var separator:Bitmap = Window.backingShort(settings.width - 95, 'dividerLine', false);
				separator.x = back.x + 3;
				separator.y = back.y;
				separator.alpha = 0.7;
				bodyContainer.addChild(separator);
				
				var separator2:Bitmap = Window.backingShort(settings.width - 95, 'dividerLine', false);
				separator2.x = back.x + 3;
				separator2.y = back.y + back.height - separator2.height / 2;
				separator2.alpha = 0.6;
				bodyContainer.addChild(separator2);
			}
			var text:String = Locale.__e(settings.target.info.text1);
			var label:TextField = drawText(text, {
				fontSize:28,
				autoSize:"center",
				textAlign:"center",
				color:0xfffae8,
				borderColor:0x5f4629,
				border:true
			});
			label.width = settings.width - 50;
			label.height = label.textHeight;
			label.x = (settings.width - label.width) / 2;
			label.y = back.y - 13;
			bodyContainer.addChild(label);
			
			if (settings['content'].length > 0) {
				contentChange();
			}
			drawNotif();
		}
		
		private function drawNotif():void {
			if (info.tower[floor + 1] == undefined){
				if (notifBttn && notifBttn.parent) notifBttn.parent.removeChild(notifBttn);
				return;
			}
			
			var bttnSettings:Object = {
				caption		:Locale.__e("flash:1382952379977"),//Пригласить
				width		:170 - 3,
				height		:55 - 5,
				fontSize	:25
			}
			
			if (settings['content'].length > 0) {
				bttnSettings['width'] = 180;
				bttnSettings['height'] = 50;
				bttnSettings['fontSize'] = 26;
				bttnSettings['caption'] = Locale.__e("flash:1382952379977");//Пригласить ещё
			}
			
			notifBttn = new Button(bttnSettings);
			
			notifBttn.x = back.x + (back.width - notifBttn.width) / 2;
			
			if (settings['content'].length > 0) {
				notifBttn.y = back.y + back.height;
			} else {
				notifBttn.y = back.y + back.height;
			}
			
			bodyContainer.addChild(notifBttn);
			notifBttn.addEventListener(MouseEvent.CLICK, onNotifClick);
		}
		
		private function onNotifClick(e:MouseEvent):void {
			
			switch(App.self.flashVars.social) {
				case 'VK':
				case 'DM':	
				case 'YB':	
				case 'NN':	
				case 'AI':
				case 'FB':
				case 'NK':
				case 'OK':
				case 'ML':	
				case 'FS':
				case 'MX':
				case 'GN':
					new NotifWindow( { target:settings.target } ).show();
					break;
				case 'PL':
						ExternalApi.apiInviteEvent();
					break;
			}
		}
		
		override public function drawArrows():void {
			
			paginator.drawArrow(bodyContainer, Paginator.LEFT,  0, 0, { scaleX: -1, scaleY:1 } );
			paginator.drawArrow(bodyContainer, Paginator.RIGHT, 0, 0, { scaleX:1, scaleY:1 } );
			var arrY:Number = 0;
			if (back) {
				arrY = back.y + back.height / 2 - paginator.arrowLeft.height / 2;
			}else {
				arrY = 100
			}
			
			paginator.arrowLeft.x = 0 -  + paginator.arrowLeft.width / 2;
			paginator.arrowLeft.y = arrY;
			
			paginator.arrowRight.x = settings.width - paginator.arrowRight.width + paginator.arrowRight.width / 2;
			paginator.arrowRight.y = arrY;
			if (!contentManager.content.length) {
				paginator.arrowLeft.visible = false;
				paginator.arrowRight.visible = false;
			}
		}
		
		public function get canBeUpgraded():Boolean {
			if(settings.target.kicks >= info.tower[floor + 1].c && settings.target.mykicks >= info.tower[floor + 1].m) {
				return true;
			}
			return false;
		}
		
		
		public function updateItems():void {
			if (floor > 0 || canBeUpgraded) {
				if (info.tower[floor + 1] != undefined && !canBeUpgraded){
					hitBttn.visible = true;
					accelerateBttn.visible = true;
				} else if (info.tower[floor + 1] == undefined) {
					upgradeBttn.visible = false;
					hitBttn.visible = true;
				} else {
					upgradeBttn.visible = true;
					upgradeBttn.y -= 350 - 30;
				}
			} else {
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
				rewardTextLabel.x = upgradeBttn.x - 70;
				rewardTextLabel.y = upgradeBttn.y - 100;
			}
			
			if (info.tower[floor + 1].c <= settings.target.kicks && accelerateBttn) {
				accelerateBttn.state = Button.DISABLED;
			}
			
			if (!info.tower[floor + 1]) {
				//updateItems();
			}else {
				drawItems();
			}
			progress();
			
			
			if (type == Floors.TWO_SIDE_KICK) {
				upgradeBttn.y = visitorsBar.y - upgradeBttn.height - 20- 30;
				rewardTextLabel.y = upgradeBttn.y - 100;
				if (!accelerateBttn.visible) {
					notifBttn.x = back.x + back.width / 2 - notifBttn.width / 2;
				}
			}
			disableItems();
		}
		
		public override function contentChange():void {
			if (!info.tower[floor + 1]) return;
			contentManager.update(paginator.startCount, paginator.finishCount);	
			contentManager.x = (settings.width - contentManager.width)/2;
			fixContentManager();
		}
		
		private var moveContentY:int = 50;
		public function fixContentManager():void {
			if(settings.hasTitle){
					bodyContainer.y = headerContainer.height / 2;
				}
			if (!info.tower[floor + 1]) return;
			contentManager.y = 375 - bodyContainer.y + (206 - contentManager.height) / 2 + moveContentY;
		}
		
		override public function dispose():void {
			upgradeBttn.removeEventListener(MouseEvent.CLICK, kickEvent);
			hitBttn.removeEventListener(MouseEvent.CLICK, buyAllEvent);
			if (notifBttn != null) notifBttn.addEventListener(MouseEvent.CLICK, onNotifClick);
			super.dispose();
		}
		
		public function disposeProgress():void {
			bodyContainer.removeChild(bar);
		}
		
		public function getTextFormInfo(value:String):String {
			var text:String = settings.target.info[value];
			text = text.replace(/\r/, "");
			return Locale.__e(text);
		}
	}
}
//
//import core.AvaLoad;
//import core.IsoConvert;
//import core.Load;
//import core.Numbers;
//import flash.display.Bitmap;
//import flash.display.BitmapData;
//import flash.display.Shape;
//import flash.display.Sprite;
//import flash.geom.Matrix;
//import flash.geom.Rectangle;
//import ui.UserInterface;
//import units.Floors;
//import wins.Window;
//import wins.PFloorsWindow2;
//
//internal class ShareItem extends LayerX {
	//
	//public var window:*;
	//public var uid:*;
	//public var time:uint;
	//public var bg:Bitmap;
	//private var bitmap:Bitmap;
	//private var maska:Shape;
	//
	//public function ShareItem(obj:Object, window:*) {
		//
		//this.uid = obj.uid;
		//this.time = obj.time;
		//this.window = window;
		//
		//bg = Window.backing(72, 77, 20, 'textSmallBacking');
		//addChild(bg);
		//
		//maska = new Shape();
		//maska.graphics.beginFill(0xFFFFFF, 1);
		//maska.graphics.drawRoundRect(0,0,50,50,15,15);
		//maska.graphics.endFill();
		//
		//addChild(maska);
		//
		//new AvaLoad(App.user.friends.data[uid].photo, onLoad);
		//
		//var count:int = int(Math.random() * 10) + 1;
		//
		//tip = function():Object {
			//return {
				//title	:App.user.friends.data[uid].first_name + " " +App.user.friends.data[uid].last_name
			//}
		//}
	//}
	//
	//public function get itemRect():Object {
		//return {width:70,height:80};
	//}
	//
	//private function onLoad(data:Bitmap):void {
		//bitmap = new Bitmap(data.bitmapData);
		//addChild(bitmap);
		//bitmap.x = (bg.width - bitmap.width) / 2;
		//bitmap.y = (bg.height - bitmap.height) / 2;
		//
		//maska.x = bitmap.x;
		//maska.y = bitmap.y;
		//bitmap.mask = maska;
	//}
	//
	//public function dispose():void {
		//
	//}
	//
	//public function getHeight():int {
		//return this.height;
	//}
//}

import core.AvaLoad;
import core.Load;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Shape;
import flash.display.Sprite;
import flash.geom.Matrix;
import flash.text.TextField;
import wins.Window;

internal class FriendItem extends Sprite {
	
	public var bg:Bitmap;
	public var friend:Object;
	public var mode:int;
	private var title:TextField;
	private var sprite:Sprite = new Sprite();
	private var avatar:Bitmap = new Bitmap();
	private var data:Object;
	private var callBack:Function;
	
	public function FriendItem(data:Object) {
		this.data = data;
		this.friend = App.user.friends.data[data.uid];
		//bg = new Bitmap(UserInterface.textures.frSlot);//93x100
		bg = Window.backing(110, 110, 20, "itemBacking");
		addChild(bg);
		/*bg.width = 72;
		bg.height = 77;*/
		bg.smoothing = true;
		addChild(sprite);
		sprite.addChild(avatar);
		
		if (friend.first_name != null || friend.aka != null || friend.photo != null) {
			drawAvatar();
		} else {
			App.self.setOnTimer(checkOnLoad);
		}
		
		var txtBttn:String;
	}
	
	private function drawAvatar():void {
		var nmTxt:String = (friend.first_name)?friend.first_name:(friend.aka)?friend.aka:"undefined";
		title = Window.drawText(nmTxt.substr(0, 15), App.self.userNameSettings({
			fontSize:20,
			color:0x502f06,
			borderColor:0xf8f2e0,
			textAlign:'center'
		}));
		title.width = bg.width + 10;
		title.x = (bg.width - title.width) / 2;
		title.y = -5;
		addChild(title);
		
		new AvaLoad(friend.photo, onLoad);
	}
	
	private function checkOnLoad():void {
		if (friend && friend.first_name != null) {
			App.self.setOffTimer(checkOnLoad);
			drawAvatar();
		}
	}
	
	public function get itemRect():Object {
		return {width:70,height:80};
	}
	
	public function set state(value:int):void {
		
	}
	
	private function onLoad(data:*):void {
		var shape:Shape = new Shape();
		shape.graphics.beginFill(0x000000, 1);
		shape.graphics.drawRoundRect(0, 0, 90, 90, 20, 20);
		shape.graphics.endFill();
		sprite.mask = shape;
		sprite.addChild(shape);
		var avW:int = shape.width;
		var avH:int = shape.height;
		var scale_x:Number = avW / data.bitmapData.width;
		var scale_y:Number = avH / data.bitmapData.height;
		var matrix:Matrix = new Matrix();
		matrix.scale(scale_x, scale_y);
		
		var smallBMD:BitmapData = new BitmapData(avW , avH , true, 0x000000);
		smallBMD.draw(data.bitmapData, matrix, null, null, null, true);
		
		avatar.bitmapData = smallBMD;
/*		avatar.x = (shape.width - avatar.width) / 2;
		avatar.y = (shape.height - avatar.height) / 2;*/
		avatar.x = shape.x = (110 - shape.width) / 2;
		avatar.y = shape.y = (110 - shape.height) / 2;
		avatar.smoothing = true;
	}
	
	public function dispose():void {
		callBack = null;
		App.self.setOffTimer(checkOnLoad);
	}
}

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
import wins.Window;
import wins.ShopWindow;
import core.Numbers;
	import ui.UserInterface;
	import wins.SimpleWindow;
	
internal class UserShareItem extends LayerX {
	
	public var window:*;
	public var item:Object;
	public var bg:Shape;
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
		//this.kicksNum = window.info.kicks[sID].p;
		this.window = window;
		
		//bg = Window.backing(145, 185, 20, 'itemBacking');
		//bg = Window.backing(145, 185, 20, 'itemBackingMain');3
		bg = new Shape();
		bg.graphics.beginFill(0xc9cec2, 1);
		bg.graphics.drawCircle(60, 60, 60);
		bg.graphics.endFill();
		addChild(bg);
		
		/*if (window.upgradeBttn) {
			removeChild(bg);
		}*/
		
		bitmap = new Bitmap();
		addChild(bitmap);
		
		Load.loading(Config.getIcon(item.type, item.preview), onLoad);
		
		drawTitle();
		drawLabel();
		
		tip = function():Object {
			return {
				title: Locale.__e(item.title),
				text: Locale.__e(item.description)
			}
		}
		
		//drawCount()
	}
	
	private function onClick(e:MouseEvent):void {
		//if (window.settings.target.mykicks >= window.info.tower[window.floor + 1].m) {
		if (window.info.tower[window.floor + 1] && window.settings.target.mykicks >= window.info.tower[window.floor + 1].m) {
			bttn.state = Button.DISABLED;
		}
		if (e.currentTarget.mode == Button.DISABLED) return;
		
		switch(type) {
			case 2:
				if (!App.user.stock.check(Stock.FANT, item.real)) 
					return;
					
					var moneyCount:int;
		if (item.hasOwnProperty('real') && item.real > 0) {
			moneyCount = item.real;
		} else if (item.hasOwnProperty('price') )
		{
			for each (var __item:Object in item.price)
				moneyCount = int(__item);
		}
			if(App.isSocial(["YB","YBD","GN","AI","MX"]))
					new SimpleWindow( {
				cancelText:		Locale.__e('flash:1382952380008'),
				title:			Locale.__e('flash:1448466133780'),
				text:			Locale.__e('flash:1449154820140', String(moneyCount)),
				confirmText:	Locale.__e('flash:1448466285460'),
				dialog:			true,
				popup:			true,
				confirm:		onConfirm,
				cancel:			onCancel,
				needCancelAfterClose:	true,
				showBucks:		true
			}).show();
			else
			onConfirm();
			return;
			break;
			case 3:
				if (!App.user.stock.check(sID, 1)) 
					return;
			break;
		}
		
		bttn.state = Button.DISABLED;
		/*var boost:int = 0;
		if(item.real > 0)
			boost = 1;*/
		
		//window.blockItems(true);
		window.settings.mKickEvent(sID, onKickEventComplete, type);
	}
	
	private function onCancel():void
	{
		
	}
	
	private function onConfirm():void
	{
		bttn.state = Button.DISABLED;
		/*var boost:int = 0;
		if(item.real > 0)
			boost = 1;*/
		
		//window.blockItems(true);
		window.settings.mKickEvent(sID, onKickEventComplete, type);
	}
	
	private function onKickEventComplete(params:Object = null):void {//sID:uint, price:uint
		//window.disposeProgress();
		
		var sID:uint;
		var price:uint;
		
		var moneyCount:int;
		if (item.hasOwnProperty('real') && item.real > 0) {
			moneyCount = item.real;
		} else if (item.hasOwnProperty('price') )
		{
			for each (var __item:Object in item.price)
				moneyCount = int(__item);
		}
		
		if (params && params.bonus) {
			for(var b:* in params.bonus){
				var itm:* = new BonusItem(b, Numbers.firstProp(params.bonus[b]).key);
				itm.cashMove(localToGlobal(new Point(bg.width / 2, bg.height / 2)), App.self.windowContainer);
			}
		}
		
		if (type == 1) {
			window.close();
			return;
		}
		
		else if (type == 2) {
			sID = Stock.FANT;
			price = moneyCount;
		} else if (type == 3) {
			sID = this.sID;
			//sID = Stock.GUESTFANTASY;
			price = 1;
		}	
		
		bttn.state = Button.NORMAL;
		
		var X:Number = App.self.mouseX - bttn.mouseX + bttn.width / 2;
		var Y:Number = App.self.mouseY - bttn.mouseY;
		Hints.minus(sID, price, new Point(X, Y), false, App.self.tipsContainer);
		
		//window.close();
		window.updateItems();
		//window.drawItems();
	}	
	
	private function onLoad(data:Bitmap):void {
		bitmap.bitmapData = data.bitmapData;		
		bitmap.x = (bg.width - bitmap.width) / 2;
		bitmap.y = (bg.height - bitmap.height) / 2 - 10;
	}
	
	public function dispose():void {
		bttn.removeEventListener(MouseEvent.CLICK, onClick);
		if(findBttn) findBttn.removeEventListener(MouseEvent.CLICK, onClick);
	}
	
	private var title:TextField; 
	public function drawTitle():void {
		title = Window.drawText(String(item.title) + "  +"+kicksNum, {
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
		title.y = -10;
		title.x = 5;
		addChild(title);		
	}
	
	private var kicksNumLable:TextField; 
	private var kicksNumAmount:int; 
	private function drawkicksNum():void {
		kicksNumAmount = kicksNum;
		kicksNumLable = Window.drawText("+"+String(kicksNumAmount), {
			fontSize		:22,
			color			:0x814f31,
			borderColor		:0xffffff,
			autoSize		:"left"
		});		
		addChildAt(kicksNumLable, 3);
		kicksNumLable.y = title.y + title.height - 2;
		kicksNumLable.x = (title.x + (title.width / 2)) - 15;
	}
	
	public function drawLabel():void {
		var bttnSettings:Object = {
			caption:window.getTextFormInfo('text7'),
			width:100+7,
			height:34+10,
			fontSize:23
		}
		
		var price:PriceLabel;
		var text:String = '';
		var hasButton:Boolean = true;
		
		var moneyCount:int;
		if (item.hasOwnProperty('real') && item.real > 0) {
			moneyCount = item.real;
		} else if (item.hasOwnProperty('price') ) {
			for each (var __item:Object in item.price)
				moneyCount = int(__item);
		}
		
		if (type == 2) { // за кристалы
			bttnSettings['fontSize'] = 30;
			bttnSettings['caption'] = '     ' + moneyCount;
			bttnSettings['bgColor'] = [0xa5d835, 0x8fbd29];	//Цвета градиента
			bttnSettings['borderColor'] = [0xd0e69e, 0x71811e];	
			bttnSettings['fontColor'] = 0xdbfa9d;
			bttnSettings['fontBorderColor'] = 0x335206;
		} else if (type == 3) { // со склада
			var count:int; 
			var count_txt:TextField; 
			count = App.user.stock.count(sID);
			count_txt = Window.drawText("x" + String(count), {
				fontSize		:28,
				color			:0xfffae8,
				borderColor		:0x763b18,
				autoSize:"left"
			});
			count_txt.x = ((bg.x + bg.width)- count_txt.width) / 2;
			count_txt.y = (bg.y + bg.height) * 0.75;
			addChild(count_txt);
		} else if (type == 1) { // за фантазию
			var guests:Object = window.settings.target.guests;
			
			if (guests.hasOwnProperty(App.user.id) && guests[App.user.id] > 0 && guests[App.user.id] > App.midnight) {
				text = Locale.__e("flash:1382952380288");//Один раз в день
				hasButton = false;
			} else if (window.settings.target is Bar && window.settings.target.items <= 0) {
				text = Locale.__e("flash:1383041104026"); //Нет
				hasButton = false;
			} else {
				var prOb:Object = new Object();
				prOb[Stock.GUESTFANTASY] = 1;
				price = new PriceLabel(1);
				addChild(price);
				price.x = (bg.x + bg.width - price.width) / 2;
				price.y = (bg.y + bg.height) * 0.75;
			}
		}
		
		var label:TextField;
		if(text != '') {
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
		if (window.info.tower[window.floor + 1] && window.settings.target.mykicks >= window.info.tower[window.floor + 1].m) {
			bttn.state = Button.DISABLED;
		}
		if (!hasButton)
			return;
		
		bttn.x = (bg.width - bttn.width) / 2;
		bttn.y = bg.height;
		addChild(bttn);
		
		bttn.addEventListener(MouseEvent.CLICK, onClick);
		
		if (type == 2) {
			var icon:Bitmap = new Bitmap(UserInterface.textures.fantsIcon, 'auto', true);
			icon.scaleX = icon.scaleY = 0.8;
			icon.x = 25;
			icon.y = 3;
			bttn.addChild(icon);
		}
		
		if(type == 2 && App.user.stock.data[Stock.FANT] <= moneyCount) {
			//bttn.state = Button.DISABLED;
		} else if(type == 3) {
			if (App.user.stock.count(sID) <= 0) {
				bttn.state = Button.DISABLED;
				
				bttnSettings["caption"] = Locale.__e("flash:1405687705056"),
				bttnSettings["fontSize"] = 15;
				bttnSettings["radius"] = 10;
				bttnSettings["fontColor"] = 0xffffff;
				bttnSettings["fontBorderColor"] = 0x475465;
				bttnSettings["borderColor"] = [0xfff17f, 0xbf8122];
				bttnSettings["bgColor"] = [0x75c5f6, 0x62b0e1];
				bttnSettings["bevelColor"] = [0xc6edfe, 0x2470ac];
				bttnSettings["width"] = 100 + 7;
				bttnSettings["height"] = 35;
				bttnSettings["fontSize"] = 23;
				bttnSettings["fontSize"] = 15;
				
				findBttn = new Button(bttnSettings);
				findBttn.x = bttn.x + (bttn.width - findBttn.width) / 2;
				findBttn.y = bttn.y - findBttn.height - 5;
				addChild(findBttn);
				findBttn.addEventListener(MouseEvent.CLICK, onFindClick)
				if (count_txt) {
					count_txt.y -= findBttn.height + 5;
				}
			}
		}
		
		if (!window.info.tower[window.floor + 1]) {
			bttn.state = Button.DISABLED
		}
	}
	
	private function onFindClick(e:MouseEvent):void {
			ShopWindow.findMaterialSource(sID);
	}
}