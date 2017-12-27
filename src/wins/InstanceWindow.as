package wins 
{
	import api.ExternalApi;
	import buttons.Button;
	import buttons.ImageButton;
	import buttons.ImagesButton;
	import buttons.MoneyButton;
	import com.adobe.images.BitString;
	import com.flashdynamix.motion.extras.BitmapTiler;
	import com.greensock.TweenLite;
	import com.greensock.TweenMax;
	import core.Post;
	import core.TimeConverter;
	import core.WallPost;
	import flash.display.Bitmap;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.utils.setTimeout;
	import silin.utils.Color;
	import ui.Cursor;
	import ui.Hints;
	import ui.SystemPanel;
	import ui.UserInterface;
	import units.Hero;
	import units.Missionhouse;
	import units.Personage;
	import wins.actions.BanksWindow;
	import wins.elements.BankMenu;
	/**
	 * ...
	 * @author ...
	 */
	public class InstanceWindow extends BuildingWindow
	{
		public static const IMPROVE_CHANCE:int = 239;
		public static const IMPROVE_TIME:int = 238;
		
		public var isWork:Boolean = false;
		
		public var needRecources:Object = { };
		public var takeResources:Object = { };
		
		public var price:int = 0;
		public var roomID:int;
		
		private var timeToEnd:int;
		private var bottomsContainer:Sprite;
		
		public static var isTutorial:Boolean = false;
		
		public function InstanceWindow(settings:Object = null)
		{
			bottomsContainer = new Sprite();
			settings['hasPaginator'] = false;
			settings['title'] = '';
			super(settings);
			
			Missionhouse.windowOpened = true;
			
			if (App.user.quests.data[36] != null && App.user.quests.data[36].finished == 0) {
				isTutorial = true;
			}
			
			this.addEventListener(MouseEvent.MOUSE_DOWN, onThisClick);
			App.self.addEventListener(AppEvent.ON_MAP_CLICK, doCloseClick);
			App.self.addEventListener(AppEvent.ON_MAP_TOUCH, doCloseTouch);
			
			//App.self.setOnEnterFrame(onEnterFrame);
			
			App.ui.systemPanel.mouseChildren = App.ui.systemPanel.mouseEnabled = false;
			
			roomID = settings.roomInfo.id;
			var _hero:Hero
			
			timeToEnd = settings.roomInfo.time - App.data.storage[roomID].term * getNumFriends();
			
			
			if (settings.crafting) {
				isWork = true;
				startTime = settings.target.startTime;
			}
			
			if ((settings.target.startTime + timeToEnd) > App.time) {
				isWork = true;
				startTime = settings.target.startTime;
			}
			
			if (!isWork) {
				showPersonages();
				for each(_hero in App.user.personages) {
					_hero.visible = false;
				}
				//App.user.addPersonagesAtPoint(new Point(settings.target.coords.x - 8, settings.target.coords.z - 1));
			}
						
			for (var res:* in settings.roomInfo.require) {
				if (!App.user.stock.check(res, settings.roomInfo.require[res])) {
					var needCount:int = settings.roomInfo.require[res] - App.user.stock.count(res);
					needRecources[res] = needCount;
					
					if (res == Stock.FANTASY) {
						var needEfir:int = settings.roomInfo.require[res] - App.user.stock.data[Stock.FANTASY];
						
						if (needEfir <= 0)
							continue;
						
						if (takeResources[Stock.FANT] != null)
							takeResources[Stock.FANT] += Math.ceil(needEfir / 30);
						else	
							takeResources[Stock.FANT] = Math.ceil(needEfir / 30);
						
						price += Math.ceil(needEfir / 30);
					}else {
						for (var need:* in App.data.storage[res].price) {
							if (takeResources.need != null)
								takeResources[need] += App.data.storage[res].price[need] * settings.roomInfo.require[res];
							else	
								takeResources[need] = App.data.storage[res].price[need] * settings.roomInfo.require[res];
								
							price += App.data.storage[res].price[need] * settings.roomInfo.require[res];
						}
					}
					
					//for (var need:* in App.data.storage[res].price) {
						//if (takeResources.need != null)
							//takeResources[need] += App.data.storage[res].price[need] * settings.roomInfo.require[res];
						//else	
							//takeResources[need] = App.data.storage[res].price[need] * settings.roomInfo.require[res];
							//
						//price += App.data.storage[res].price[need] * settings.roomInfo.require[res];
					//}
				}
			}
			
			if (isWork) arrHeroesSids = settings.target.arrHeroesSids;
			
			App.user.onStopEvent();
			
			App.ui.leftPanel.questsPanel.visible = false;
			App.ui.salesPanel.visible = false;
		}
		
		private var persItems:Array = [];
		
		private var persPositions:Array = [
			{x:	42, y:-184},
			{x: -40, y:-118},
			{x: -97, y:-36},
			{x: -150, y:75-30 },
			{x: -200, y:125 },
			{x: -250, y:170 }
			
		];
		
		private var container:Sprite;
		private function showPersonages():void {
			container = new Sprite();
			var count:int = 0;
			var persContainer:Sprite = new Sprite();
			var perEnabled:Boolean = true;
			var arrPers:Array = App.user.aliens.concat(App.user.characters);
			
			
			for each(var pers:Object in arrPers) {
				if (App.user.arrHeroesInRoom.indexOf(pers.sid) == -1){
					perEnabled = true;
				}else
					perEnabled = false;
				
				var persItem:PersonageItem = new PersonageItem(this,perEnabled);
				
				if (App.user.arrHeroesInRoom.indexOf(pers.sid) == -1)
					persItem.add(pers.sid);
				else {
					
						persItem.add(pers.sid/*, false*/);
						//persItem.alpha = 0.2;
					}
					
				persItems.push(persItem);
				
				var r:int = 200;
				
				var dx:int = 50*arrPers.length;
				var dy:int = -5*arrPers.length;
				var alpha:Number = count * (90 / (arrPers.length))
				var px:int = r * Math.cos(Math.PI * (90 + alpha) / 180);
				var py:int = r * Math.cos(Math.PI * (90 + alpha) / 180);
				
				container.addChild(persItem);
				container.x = 0;
				container.y = -125;
				persItem.x = persPositions[count].x + dx;
				persItem.y = persPositions[count].y + dy;
				//persItem.x = px + dx;
				//persItem.y = -py + dy;
				
				count++;
			}
			bottomsContainer.addChild(container);

			//resizePers();
			
			if(InstanceWindow.isTutorial)
				startTutorial();
		}
		
		public function startTutorial():void {
			for each(var _persItem:PersonageItem in persItems) 
			{
				if (_persItem.sid == User.PRINCE){
					/*App.user.quests.currentTarget = _persItem.icon;
					App.user.quests.lock = false;*/
					_persItem.showPointing('right',-10,0,_persItem.parent);
					_persItem.showGlowing();
					//Tutorial.watchOn(_persItem, 'top', false, {dy:-35});
					break;
				}
			}
		}
		
		public function hidePersonage(sid:uint):void {
			for each(var persItem:PersonageItem in persItems) {
				if (persItem.sid == sid) {
					persItem./*anim.*/visible = false;
				}
			}
		}
		public function showPersonage(sid:uint):void {
			for each(var persItem:PersonageItem in persItems) {
				if (persItem.sid == sid) {
					persItem./*anim.*/visible = true;
				}
			}
		}
		
		private function onMouseUp(e:MouseEvent):void 
		{
			
		}
		
		private function doCloseTouch(e:AppEvent):void 
		{
			App.self.removeEventListener(AppEvent.ON_MAP_TOUCH, doCloseTouch);
			close();
		}
		
		private function doCloseClick(e:AppEvent):void 
		{
			App.self.removeEventListener(AppEvent.ON_MAP_CLICK, doCloseClick);
			close();
		}
		
		override public function dispose():void {
			
			App.ui.leftPanel.questsPanel.visible = true;
			App.ui.salesPanel.visible = true;
			
			settings.target.windowOpened = false;	
			
			App.ui.systemPanel.mouseChildren = App.ui.systemPanel.mouseEnabled = true;
			
			Missionhouse.windowOpened = false;
			Cursor.type = 'default';
			App.self.setOffTimer(work);
			
			App.self.removeEventListener(AppEvent.ON_MAP_CLICK, doCloseClick);
			App.self.removeEventListener(AppEvent.ON_MAP_TOUCH, doCloseTouch);
			
			
			for each(var _hero:Hero in App.user.personages) {
				_hero.visible = true;
			}
			
			if (iconCont) {
				iconCont.removeEventListener(MouseEvent.CLICK, onShowFriens);
				iconCont.dispose();
			}
			if (btnnBuyReq) {
				btnnBuyReq.removeEventListener(MouseEvent.CLICK, onBuyClick);
				btnnBuyReq.dispose();
			}
			if (btnnStartReq) {
				btnnStartReq.removeEventListener(MouseEvent.CLICK, onStartClick);
				btnnStartReq.dispose();
			}
			if (inviteBttn) {
				inviteBttn.removeEventListener(MouseEvent.CLICK, onInvite);
				inviteBttn.dispose();
			}
			if (bttnImproveTime) {
				bttnImproveTime.removeEventListener(MouseEvent.CLICK, onImproveTime);
				bttnImproveTime.dispose();
			}
			if (bttnImproveChance) {
				bttnImproveChance.removeEventListener(MouseEvent.CLICK, onImproveChance);
				bttnImproveChance.dispose();
			}
			
			bttnImproveTime = null;
			bttnImproveChance = null;
			btnnBuyReq = null;
			btnnStartReq = null;
			inviteBttn = null;
			//if(requireCont && requireCont.parent)requireCont.parent.removeChild(requireCont);
			if(requireCont && requireCont.parent)bottomsContainer.removeChild(requireCont);
			requireCont = null;
			
			var i:int = 0;
			if (arrOutItems) {
				for ( i = 0; i < arrOutItems.length; i++ ) {
					arrOutItems[i].dispose();
					arrOutItems[i] = null;
				}
				arrOutItems.splice(0, arrOutItems.length);
				arrOutItems = null;
			}
			
			if(arrHeroes){
				for ( i = 0; i < arrHeroes.length; i++ ) {
					arrHeroes[i].dispose();
					arrHeroes[i] = null;
				}
				arrHeroes.splice(0, arrHeroes.length);
				arrHeroes = null;
			}
			
			if (settings.onClose != null) settings.onClose(isWork);
			
			//if (settings.target.sid == 250) {
				//App.map.focusedOn( { x:settings.target.x - 170 + 20, y:settings.target.y + 50 }, false, null, true, 	SystemPanel.scaleValue);
			//}else {
				//App.map.focusedOn( { x:settings.target.x + 20, y:settings.target.y + 50 }, false, null, true, 	SystemPanel.scaleValue);
			//}
			super.dispose();
		}
		
		public function reject(e:* = null):void {
			Post.send({
				ctr:'missionhouse',
				act:'reject',
				uID:App.user.id,
				rID:settings.roomInfo.id
			}, function(error:int, data:Object, params:Object):void {
				trace();
			});
		}
		
		override public function drawExit():void 
		{
			//exit = new ImageButton(textures.closeBttn);
			//bottomsContainer.addChild(exit);
			//exit.x = bottomsContainer.width + 545;
			//exit.y = bottomsContainer.y - 10;
			//exit.addEventListener(MouseEvent.CLICK, close);
			
			
			/*var rejectBttn:ImageButton = new ImageButton(textures.closeBttn);
			addChild(rejectBttn);
			rejectBttn.x = App.self.stage.stageWidth / 2 + 370;
			rejectBttn.y = App.self.stage.stageHeight - 336;
			rejectBttn.addEventListener(MouseEvent.CLICK, reject);*/
		}
		
		private function onThisClick(e:MouseEvent):void 
		{
			Cursor.type = 'instance';
		}
		
		public var arrHeroesSids:Array = [];
		public function setHeroInto(sid:int, addNow:Boolean = false):void 
		{
			/*if (isWork && !addNow) return;
			
			var totalPers:int = App.user.aliens.length;
			var leftPers:int = App.user.personages.length - arrHeroesSids.length;
			
			if (leftPers <= 1 && !isWork && arrHeroesSids.length != arrHeroes.length) {
				new SimpleWindow( {
					label:SimpleWindow.ATTENTION,
					title:Locale.__e("flash:1396256043113"),
					text:Locale.__e("flash:1396256053577"),
					popup:true
				}).show();
				return;
			}
			
			var isPlased:Boolean = false;
			for ( var i:int = 0; i < arrHeroes.length; i++ ) {
				if (arrHeroes[i].empty) {
					arrHeroes[i].addHero(sid);
					arrHeroesSids.push(sid)
					updateOuts();
					updateBttns();
					// Убираем перса из списа
					hidePersonage(sid);
					
					isPlased = true;
					break;
				}
			}
			
			if (!isPlased && arrHeroes.length > 0) {
				arrHeroes[0].onClose();
				arrHeroes[0].addHero(sid);
				arrHeroesSids.push(sid)
				updateOuts();
				updateBttns();
				// Убираем перса из списа
				hidePersonage(sid);
			}
			
			checkChooseText();
			
			if (App.user.quests.tutorial)
				App.tutorial.focusOnInstanseStart();*/
				
				if (isWork && !addNow) return;
			
			//var totalPers:int = App.user.aliens.length;
			//
			//var canAdd:Boolean = true;
			//var countPers:int = 0;
			//
			//for (var j:int = 0; j < App.user.aliens.length; j++ ) {
				//
				//if (sid == App.user.aliens[j].sid)
					//countPers++;
					//
				//for (var i:int = 0; i < arrHeroesSids.length; i++) {	
					//if (App.user.aliens[j].sid == arrHeroesSids[i])
						//countPers++;
				//}
			//}
			
			//if (App.user.personages.length - countPers <= 0)
				//canAdd = false;
			
			//if (!canAdd && !isWork/* && arrHeroesSids.length != arrHeroes.length*/) {
				//new SimpleWindow( {
					//label:SimpleWindow.ATTENTION,
					//title:Locale.__e("flash:1396256043113"),
					//text:Locale.__e("flash:1396256053577"),
					//popup:true
				//}).show();
				//return;
			//}
			
			var isPlased:Boolean = false;
			for ( var i:int = 0; i < arrHeroes.length; i++ ) {
				if (arrHeroes[i].empty) {
					arrHeroes[i].addHero(sid);
					arrHeroesSids.push(sid)
					updateOuts();
					updateBttns();
					// Убираем перса из списка
					hidePersonage(sid);
					
					isPlased = true;
					break;
				}
			}
			
			if (!isPlased && arrHeroes.length > 0) {
				arrHeroes[0].onClose();
				arrHeroes[0].addHero(sid);
				arrHeroesSids.push(sid)
				updateOuts();
				updateBttns();
				// Убираем перса из списка
				hidePersonage(sid);
			}
			
			checkChooseText();
			
			if(InstanceWindow.isTutorial){
				for each(var _persItem:PersonageItem in persItems) {
					_persItem.hidePointing();
					_persItem.hideGlowing();
				}
			}
		}
		
		private function checkChooseText():void 
		{
			if (chooseCont.visible && arrHeroesSids.length >= App.data.storage[roomID].count) {
				chooseCont.visible = false;
				chooseCont.hideAlphaEff();
			}else if (!chooseCont.visible && arrHeroesSids.length == 0) {
				chooseCont.visible = true;
				chooseCont.alpha = 0;
				chooseCont.startAlphaEff();
			}else if (chooseCont.visible && arrHeroesSids.length == 0 && !chooseCont.__hasGlowing) {
				chooseCont.alpha = 0;
				chooseCont.startAlphaEff();
			}
			
			if (isWork) {
				chooseCont.hideAlphaEff();
				chooseCont.visible = false;
			}
		}
		
		private function updateBttns():void 
		{
			if (!btnnStartReq) return;
			
			if (arrHeroesSids.length >= App.data.storage[roomID].count) {
				btnnStartReq.state = Button.NORMAL;
			}else {
				btnnStartReq.state = Button.DISABLED;
			}
		}
		
		public function updateOuts(chance:int = 00):void 
		{
			for (var i:int = 0; i < arrOutItems.length; i++ ) {
				arrOutItems[i].updateProgress(chance);
			}
		}
		
		public function removeHero(sid:int):void
		{
			for (var i:int = 0; i < arrHeroesSids.length; i++ ) {
				if (arrHeroesSids[i] == sid) {
					arrHeroesSids.splice(i, 1);
					//updateBttns();
				}
			}
			//App.user.addOnePersonag(sid, new Point(settings.target.coords.x - 8, settings.target.coords.z - 1));
			showPersonage(sid);
			
			/*for each(var _hero:Hero in App.user.personages) {
				if (_hero.sid == sid) {
					_hero.startGlowing(0x56ffff);
					break;
				}
			}*/
			
			updateBttns();
			checkChooseText();
		}
		
		override public function startOpenAnimation():void {
				finishOpenAnimation()
				layer.x = (App.self.stage.stageWidth - settings.width) / 2;
				layer.y = (App.self.stage.stageHeight - settings.height) / 2;
				layer.visible = true;
				/*
				layer.x = (App.self.stage.stageWidth - settings.width*.3) / 2;
				layer.y = (App.self.stage.stageHeight - settings.height*.3) / 2;
				
				layer.visible = true;
							
				layer.scaleX = layer.scaleY = 0.3;
				
				TweenLite.to(layer, settings.animationShowSpeed, { x:finishX, y:finishY, scaleX:1, scaleY:1, ease:Strong.easeOut, onComplete:finishOpenAnimation } );
				*/
				//finishOpenAnimation()
			}
		
		override public function drawBackground():void
		{
				
		}
		
		private var bottomBg:Bitmap;
		private var bottomBg2:Bitmap;
		private var bottomBg3:Bitmap;
		
		override public function drawBody():void 
		{
			fader.visible = false;
			if (!isWork) {
				bottomBg = new Bitmap(Window.textures.blueBannerBacking);
				bottomBg2 = new Bitmap(Window.textures.blueBannerBacking);
				bottomBg3= new Bitmap(Window.textures.purpleBannerBacking);
					bottomsContainer.addChild(bottomBg);
					bottomsContainer.addChild(bottomBg2);
					bottomsContainer.addChild(bottomBg3);
					bottomBg3.x = 265;
					bottomBg3.y = 65;
					bottomBg2.x = 530;
				
				exit = new ImageButton(textures.closeBttn);
					bottomsContainer.addChild(exit);
					exit.x = bottomBg2.x + bottomBg2.width - 50;
					exit.y = bottomBg2.y - 30;
					exit.addEventListener(MouseEvent.CLICK, close);
					
				addChild(bottomsContainer);
					bottomsContainer.y = App.self.stage.stageHeight - bottomBg3.height + 25;
					
				drawOuts();
				drawOther();
				drawFriendsInfo();
				drawRequires();
				drawHeroes();
			
				for (var key:* in App.user.rooms) {
					if (key == settings.target.roomInfo.id) {
						for (var hr:* in App.user.rooms[key].pers) {
							setHeroInto(App.user.rooms[key].pers[hr], true);
						}
					}
				}
			}
		}
		
		private var arrow:Bitmap;
		private function drawArrow():void 
		{
			
			var point:Sprite = new Sprite();
			point.graphics.beginFill(0xFFFF00, 1);
			point.graphics.drawRect(0, 0, 5, 5);
			point.graphics.endFill();
			bodyContainer.addChild(point);
		}
		
		public var arrOutItems:Array = [];
		private var outsCont:Sprite = new Sprite();
		public function drawOuts():void
		{
			arrOutItems = [];
			var bgWidth:int = 242;
			var bgHeight:int = 0;
			
			var outsTitle:TextField = Window.drawText(Locale.__e("flash:1393580758703"), {
				fontSize:28,
				color:0xFFFFFF,
				autoSize:"left",
				borderColor:0x6a3e17
			});
			outsCont.addChild(outsTitle);
			outsTitle.x = (bgWidth - outsTitle.textWidth) / 2 - 15;
			outsTitle.y = - outsTitle.textHeight / 2;
			
			var itemsCont:Sprite = new Sprite();
			var count:int = 0;
			for (var key:* in settings.roomInfo.outs) {
				var item:OutItem = new OutItem({id:key, count:settings.roomInfo.outs[key], target:this});
				item.updateProgress();
				arrOutItems.push(item);
				itemsCont.addChild(item);
				count++;
			}
			
			if (count > 4) {
				bgHeight = 270
			}
			else if (count > 2) {
				bgHeight = 210;
			}else {
				bgHeight = 150;
			}
			
			var underBg:Bitmap = Window.backing2(236, 280, 45, 'questTaskBackingTop', 'questTaskBackingBot');
			underBg.alpha = 0.7;
			outsCont.addChildAt(underBg, 0);
			underBg.x = -22;
			
			
			underBgMini = Window.backing2(250, 105, 45, 'questTaskBackingTop', 'questTaskBackingBot');
			underBgMini.alpha = 0.7;
			outsCont.addChildAt(underBgMini, 0);
			underBgMini.x = 236;
			underBgMini.y = 95;
			
			var arr:Array = [];
			for (var i:int = 0; i < arrOutItems.length; i++ ) {
				if (arrOutItems[i].count > 1) {
					arr.push(arrOutItems[i]);
					arrOutItems.splice(i, 1);
					i--;
				}
			}
			for ( i = 0; i < arrOutItems.length; i++ ) {
				arr.push(arrOutItems[i]);
			}
			arrOutItems.splice(0, arrOutItems.length);
			
			arrOutItems = arr;
			
			setPosition();
			outsCont.addChild(itemsCont);
			itemsCont.x = (bgWidth - itemsCont.width) / 2 - 15;
			itemsCont.y = 16;
			
			//outsCont.x = App.self.stage.stageWidth / 2 - 370;
			//outsCont.y = bottomBg.y + 32;
			outsCont.x = 79;
			outsCont.y = bottomBg.y + 36;
			//outsCont.y = 50;
			bottomsContainer.addChild(outsCont);
			
		}
		
		public function reDrawRequires():void
		{
			btnnBuyReq.removeEventListener(MouseEvent.CLICK, onBuyClick);
			btnnStartReq.removeEventListener(MouseEvent.CLICK, onStartClick);
			btnnBuyReq.dispose();
			btnnStartReq.dispose();
			btnnBuyReq = null;
			btnnStartReq = null;
			bottomsContainer.removeChild(requireCont);
			requireCont = null;
			requireCont = new Sprite();
			
			drawRequires();
		}
		
		private var btnnBuyReq:MoneyButton;
		public var btnnStartReq:Button;
		private var requireCont:Sprite = new Sprite();
		public function drawRequires():void
		{
			var bgWidth:int;
			var bgHeight:int = 100;

			var reqTitle:TextField = Window.drawText(Locale.__e("flash:1393580776135"), {
				fontSize:28,
				color:0xFFFFFF,
				autoSize:"left",
				borderColor:0x693f15
			});
			requireCont.addChild(reqTitle);
			reqTitle.x = - reqTitle.textWidth/2;

			//33
			var count:int = 0;
			var itemsCont:Sprite = new Sprite();
			var xPos:int = 0;
			for (var key:* in settings.roomInfo.require) {
				var item:ReqItem = new ReqItem( { id:key, count:settings.roomInfo.require[key], callBack:function():void {
					var posX:int = 0;
					for (var i:int = 0; i < itemsCont.numChildren; i++ ) {
						var itm:* = itemsCont.getChildAt(i);
						if (itm is ReqItem) {
							itm.x = posX;
							posX += itm.width + 25;
						}
					}
					itemsCont.x = - itemsCont.width / 2;
					itemsCont.y = reqTitle.y + reqTitle.textHeight + 6;
				}});
				item.x = xPos- 15;
				itemsCont.addChild(item);
				count++;
				xPos += item.width + 25;
			}
			if (count == 1)
			{
				item.x = xPos- 75;
			}
			requireCont.addChild(itemsCont);
			itemsCont.x = - itemsCont.width / 2;
			itemsCont.y = reqTitle.y + reqTitle.textHeight + 6;
			
			bgWidth = 90 * count;
			if (bgWidth < 110) bgWidth = 110;
			
			//var underBg:Bitmap = Window.backing2(bgWidth, bgHeight, 45, 'questsSmallBackingTopPiece', 'questsSmallBackingBottomPiece');
			//underBg.alpha = 0.2;
			//requireCont.addChildAt(underBg, 0);
			//underBg.x = - underBg.width / 2;
			//underBg.y = reqTitle.y + reqTitle.textHeight + 6;
			
			btnnStartReq = new Button( {
				caption:        Locale.__e('flash:1393581021929'),
				width:          180,
				height:         52,
				fontSize:32,
				radius: 24
			});
			requireCont.addChild(btnnStartReq);
			btnnStartReq.x =  - btnnStartReq.width/2;
			btnnStartReq.y = 150;

			//btnnStartReq.state = Button.DISABLED;
			
			btnnBuyReq = new MoneyButton( {
				caption:Locale.__e('flash:1393581054047'),
				countText:String(price),
				width:180,
				height:52,
				shadow:true,
				fontCountSize:28,
				fontSize:26,
				type:"green",
				radius:22,
				bgColor:[0xa8f84a, 0x74bc17],
				bevelColor:[0xcdfb97, 0x5f9c11],
				fontBorderColor:0x4d7d0e,
				fontCountBorder:0x40680b,
				iconScale:0.8,
				fontCountSize:36
			});
			requireCont.addChild(btnnBuyReq);
			//btnnBuyReq.countLabel.x += 8;
			//btnnBuyReq.countLabel.y += 6;
//
			//btnnBuyReq.textLabel.x -= 6;
//
			//btnnBuyReq.coinsIcon.x -= 10;

			btnnBuyReq.x =  - btnnBuyReq.width/2;
			btnnBuyReq.y = 150;

			bottomsContainer.addChild(requireCont);
			//requireCont.x = App.self.stage.stageWidth / 2;
			//requireCont.y = bottomBg.y + 90;
			requireCont.x = 440;
			requireCont.y = bottomBg.y + 105;
			btnnBuyReq.addEventListener(MouseEvent.CLICK, onBuyClick);
			btnnStartReq.addEventListener(MouseEvent.CLICK, onStartClick);

			setNeedBttn();
			updateBttns();
		}
		
		private function setNeedBttn():void
		{
			if (App.user.stock.checkAll(settings.roomInfo.require)) {
				btnnBuyReq.visible = false;
				btnnStartReq.visible = true;
			}else {
				btnnBuyReq.visible = true;
				btnnStartReq.visible = false;
			}
		}
		
		public override function close(e:MouseEvent = null):void {
			if (InstanceWindow.isTutorial) {
				//App.tutorial.hide();
			}
			
			this.removeEventListener(MouseEvent.MOUSE_DOWN, onThisClick);
			
			
			super.close();
		}
		
		private function onStartClick(e:MouseEvent):void 
		{
			if (btnnStartReq.mode == Button.DISABLED) return;
			if (!App.user.stock.takeAll(settings.roomInfo.require)) {
				close();
				BankMenu._currBtn = BankMenu.REALS;
				BanksWindow.history = { section:'Reals', page:0 };
				new BanksWindow().show();
				return;
			}
			
			for each(var _hero:Hero in App.user.personages) {
				_hero.hideGlowing();
			}
			
			btnnStartReq.state = Button.DISABLED;
			updateHeroItems();
			
			settings.target.onStart(arrHeroesSids, onStartEvent);
		}
		
		private var startTime:int;
		private function onStartEvent(startTime:int):void
		{
			isWork = true;
			
			//this.startTime = startTime;
			//App.self.setOnTimer(work);
			
			addCloudToTarget();
			
			requireCont.visible = false;
			//drawImprovement();
			
			//updateNumFriends();
			
			//removePers();
			
			if (InstanceWindow.isTutorial) {
				App.user.quests.stopTrack();
				close();
				App.user.quests.unlockFuckAll();
				InstanceWindow.isTutorial = false;
			}
				
			//if (App.social == 'FB') {						
				//ExternalApi._6epush([ "_event", { "event": "use", "item": "investigate_" + App.data.storage[settings.target.sid].view} ]);
			//}
			//for (var j:int = 0; j < App.ui.upPanel.personageIcons.length; j++ ) {
				//if(!App.ui.upPanel.personageIcons[j].isBusy){
				//App.ui.upPanel.personageIcons[j].update();
				//}
			//}
			close();
			new InstancePassingWindow(this.settings).show();
			dispose();
			
			//App.ui.upPanel.setTimeToPersIcons(startTime, timeToEnd, settings.target.sid);
		}
		
		private function removePers():void 
		{
			for (var i:int = 0; i < persItems.length; i++) {
				var pers:PersonageItem = persItems[i];
				pers.clear();
				if (pers.parent) pers.parent.removeChild(pers);
				pers = null;
			}
			persItems.splice(0, persItems.length);
		}
		
		private function addCloudToTarget():void 
		{
			settings.target.addCloud(arrHeroesSids);
		}
		
		private function updateHeroItems():void 
		{
			for (var i:int = 0; i < arrHeroes.length; i++) {
				arrHeroes[i].itemOff();
			}
		}
		
		public function work():void 
		{
			var time:int = startTime + timeToEnd - App.time;
			if (time < 0) time = 0;
			timeWork.text = TimeConverter.timeToStr(time);
			timeWork.x = -timeWork.width / 2;
			
			if (time <= 0) {
				//isWork = false;
				close();
			}
		}
		
		private function onBuyClick(e:MouseEvent):void 
		{
			if (btnnBuyReq.mode == Button.DISABLED) return;
			
			if (!App.user.stock.takeAll(takeResources)) {
				if (!App.user.stock.takeAll( { 5:price } )) {
					close();
					BankMenu._currBtn = BankMenu.REALS;
					BanksWindow.history = { section:'Reals', page:0 };
					new BanksWindow().show();
					return;
				}
				
				return;
			}
			
			btnnBuyReq.state = Button.DISABLED;
			
			var newRecources:Object = { };
			
			for (var id:* in needRecources) {
				if (id == Stock.FANTASY) {
					//App.user.stock.pack(this.sID);
					
					var settingsSend:Object = { 
						ctr:'stock',
						act:'pack',
						uID:App.user.id,
						sID:172
					};
					
					var object:Object = App.data.storage[172];
					//var priceR:Object;
					
					var _price:int;
					var _count:int = needRecources[id];
					if (_count > 0) _price = Math.ceil(_count / 30);
					else _price = 0;
					
					settingsSend['price'] = _price;
					settingsSend['count'] = _count;
					
					//priceR = { };
					//priceR[Stock.FANT] = _price;
					
					//if (App.user.stock.takeAll(price)) {
						
					if(settings.ctr == "stock")App.user.stock.add(id, _count);
					
					Post.send(settingsSend, function(error:*, result:*, params:*):void {
						
						if (error) {
							Errors.show(error, result);
							return;
						}
						
						App.self.dispatchEvent(new AppEvent(AppEvent.ON_AFTER_PACK));
					});
						
					//}
				}else {
					newRecources[id] = needRecources[id];
				}
			}
			
			
			App.user.stock.bulkPost(newRecources, onBulkEvent);//needRecources
			
		}
		
		public function onBulkEvent():void
		{
			//setNeedBttn();
			App.user.stock.addAll(needRecources);
			
			reDrawRequires();
		}
		
		private var inviteBttn:Button;
		private var friendsCont:Sprite = new Sprite();
		private var iconCont:ImagesButton;
		private var descFriends:TextField;
		private var rewardFriendsCont:Sprite = new Sprite();
		private var descFriendBonus:TextField;
		private var countFriends:TextField;
		public function drawFriendsInfo():void
		{
			var underBg:Bitmap = Window.backing2(236, 280, 45, 'questTaskBackingTop', 'questTaskBackingBot');
			underBg.alpha = 0.7;
			underBg.x = -2;
			friendsCont.addChild(underBg);
			
			var title:TextField = Window.drawText(Locale.__e("flash:1393580724851") + ":", {
				fontSize:28,
				color:0xffffff,
				autoSize:"left",
				borderColor:0x734418
			});
			friendsCont.addChild(title);
			
			title.x = (underBg.width - title.textWidth) / 2;
			title.y = -title.textHeight / 2;
			
			countFriends = Window.drawText(String(getNumFriends()), {
				fontSize:40,
				color:0xffffff,
				autoSize:"left",
				borderColor:0x734418
			});
			friendsCont.addChild(countFriends);
			//iconCont.addChild(countFriends);
			
			
			iconCont = new ImagesButton( Window.textures.buildingsSlot, UserInterface.textures.friendsIcon, { 
				description		:"Облачко",
				params			:{ }
			});
			iconCont.iconBmp.y -= 10;
			iconCont.addEventListener(MouseEvent.CLICK, onShowFriens);
			
			iconCont.iconBmp.x += 3;
			iconCont.iconBmp.y += 4;
			
			iconCont.x = (underBg.width - iconCont.width) / 2 - 20;
			iconCont.y = title.textHeight + 2;
			friendsCont.addChild(iconCont);
			countFriends.x = iconCont.x + iconCont.width + 10;
			countFriends.y = iconCont.y + iconCont.height/2 - countFriends.textHeight/2;
			
			iconCont.tip = function():Object {
				return {
					title: Locale.__e('flash:1393580830674'),
					text: Locale.__e('flash:1393580862810')
				}
			};
				
			descFriends = Window.drawText(Locale.__e("flash:1393580882265"), {
				fontSize:24,
				color:0xfde6b2,
				autoSize:"left",
				borderColor:0x605118,
				multiline:true
			});
			descFriends.wordWrap = true;
			descFriends.width = 150;
			friendsCont.addChild(descFriends);
			
			descFriends.x = (underBg.width - descFriends.textWidth) / 2;
			descFriends.y = iconCont.y + iconCont.height + 16;
			
			inviteBttn = new Button( {
				caption:        Locale.__e('flash:1382952380230'),
				width:          130,
				height:         52,
				fontSize:		28,
				bgColor:		[0xffdf92,0xfdaf64],	
				borderColor:	[0xffeed8,0xc37841],
				bevelColor:		[0xffeed8,0xc37841],
				fontColor:0xffffff,
				fontBorderColor:0x9d5b38
			});
			friendsCont.addChild(inviteBttn);
			inviteBttn.x = (underBg.width - inviteBttn.width) / 2;
			inviteBttn.y = descFriends.y + descFriends.textHeight + 22;
			
			inviteBttn.addEventListener(MouseEvent.CLICK, onInvite);
			
			descFriendBonus = Window.drawText(Locale.__e("flash:1393580922905"), {
				fontSize:24,
				color:0xfefefe,
				autoSize:"left",
				borderColor:0x734318,
				multiline:true
			});
			friendsCont.addChild(descFriendBonus);
			descFriendBonus.x = (underBg.width - descFriendBonus.textWidth) / 2;
			descFriendBonus.y = iconCont.y + iconCont.height - 6;
			
			var iconChance:Bitmap = new Bitmap(UserInterface.textures.clever);
			var iconTime:Bitmap = new Bitmap(Window.textures.timerYellow);
			//iconTime.scaleX = iconTime.scaleY = 1.2;
			iconTime.smoothing = true;
			
			var chanceTxt:TextField = Window.drawText(String(getNumFriends()), {
				fontSize:34,
				color:0xfef015,
				autoSize:"left",
				borderColor:0x574003,
				multiline:true
			});
			
			var timeTxt:TextField = Window.drawText(String(getNumFriends()), {
				fontSize:34,
				color:0xfef015,
				autoSize:"left",
				borderColor:0x574003,
				multiline:true
			});
			
			chanceTxt.x = iconChance.width + 3;
			chanceTxt.y = 3;
			
			iconTime.x = chanceTxt.x + chanceTxt.textWidth + 38;
			
			timeTxt.x = iconTime.x + iconTime.width + 3;
			timeTxt.y = 3;
			
			rewardFriendsCont.addChild(iconChance);
			rewardFriendsCont.addChild(iconTime);
			rewardFriendsCont.addChild(chanceTxt);
			rewardFriendsCont.addChild(timeTxt);
			
			friendsCont.addChild(rewardFriendsCont);
			rewardFriendsCont.y = descFriendBonus.y + descFriendBonus.textHeight + 6;
			rewardFriendsCont.x = (underBg.width - rewardFriendsCont.width) / 2;
			
			if (getNumFriends() == 0) {
				changeVisFriends(false);
			}else {
				changeVisFriends(true);
			}
			
			//friendsCont.x = App.self.stage.stageWidth/2 + 140;
			friendsCont.y = bottomBg.y + 36;
			friendsCont.x = 589;
			bottomsContainer.addChild(friendsCont);
			bottomsContainer.x = App.self.stage.stageWidth/2 - bottomsContainer.width/2 /*+ 50*/;
		}
		
		private function onShowFriens(e:MouseEvent):void 
		{
			new InstanceInfoWindow({instance:settings.target, target:this, friends:settings.friendsData}).show();
		}
		
		public function updateNumFriends():void
		{
			countFriends.text = String(getNumFriends());
		}
		
		public function getNumFriends():int 
		{
			var numFriends:int = 0;
			
			for (var key:* in settings.friendsData) {
				numFriends++;
			}
			
			if (numFriends > settings.roomInfo.limit) numFriends = settings.roomInfo.limit;
			
			return numFriends;
		}
		
		public function changeVisFriends(value:Boolean):void
		{
			rewardFriendsCont.visible = value;
			descFriendBonus.visible = value;
			descFriends.visible = !value;
		}
		
		private var otherCont:Sprite = new Sprite();
		private function onInvite(e:MouseEvent):void 
		{
			new AskWindow(AskWindow.MODE_INVITE, {
				target:settings.target,
				title:Locale.__e('flash:1382952380197'), 
				friendException:settings.friendsData, 
				inviteTxt:Locale.__e("flash:1395846352679"),
				desc:Locale.__e("flash:1395846372271")
			} ).show();
		}
		
		private var arrHeroes:Array = [];
		private var heroesCont:Sprite = new Sprite();
		public function drawHeroes():void
		{
			var xMargin:int = 60;
			var yMargin:int = 80;
			var paddingX:int = 0;
			var paddingY:int = 0;
			
			for (var i:int = 0; i < settings.roomInfo.count; i++ ) {
				var hero:HeroItem = new HeroItem(i + 1, {target:this});
				arrHeroes.push(hero);
				if (i == 1) {
					paddingX = 23;
					paddingY = 37;
				}else if(i == 0){
					paddingX = 13;
					paddingY = 18;
				}else {
					paddingX = -40;
					paddingY = -20;
				}
				hero.x = xMargin * i + paddingX;
				hero.y = yMargin * i - paddingY;
				heroesCont.addChild(hero);
			}
			
			bottomsContainer.addChild(heroesCont);
			//heroesCont.y = App.self.stage.stageHeight / 2 - 500;
			//heroesCont.x = App.self.stage.stageWidth / 2 + 150;
			heroesCont.x = 650;
			heroesCont.y = -175;
		}
		
		private var timeWork:TextField;
		private var chooseCont:LayerX = new LayerX();
		public function drawOther():void
		{
			var desc:TextField = Window.drawText(Locale.__e("flash:1393580944680"), {
				fontSize:40,
				color:0xFFFFFF,
				autoSize:"left",
				borderColor:0x6a3e17
			});
			chooseCont./*bottomsContainer.*/addChild(desc);
			desc.x = 440;
			desc.y = -50;
			//otherCont.addChild(chooseCont);
			bottomsContainer.addChild(chooseCont);
			chooseCont.x = -chooseCont.width / 2;
			
			checkChooseText();
			var timeCont:Sprite = new Sprite();
			timeWork = Window.drawText(TimeConverter.timeToStr(timeToEnd), {//TimeConverter.timeToCuts(settings.roomInfo.time, true, true), {
				fontSize:40,
				color:0xFFFFFF,
				fontBorderSize:5,
				autoSize:"left",
				borderColor:0xa2632e
			});
			
			
			timeCont.addChild(timeWork);
			timeCont.filters = [new GlowFilter(0x6a3a0a, 1, 6, 6, 10, 1)];
			bottomsContainer.addChild(timeCont);
			timeCont.x = 435;
			timeCont.y = -85;
			timeWork.x = - timeWork.textWidth / 2;
			timeWork.y = desc.textHeight + 65;
			
			otherCont.x = App.self.stage.stageWidth / 2;
			otherCont.y = bottomBg.y - otherCont.height/2 + 10;
			bottomsContainer.addChild(otherCont);
		}
		
		protected var bttnImproveChance:MoneyButton = null;
		protected var bttnImproveTime:MoneyButton = null;
		private var improvementCont:Sprite = new Sprite();
		
		private var timeTxt:TextField;
		private var chanceTxt:TextField;
		
		private var underIcon1:Bitmap;
		private var underIcon2:Bitmap;
		private var underBgMini:Bitmap;
		
		public function drawImprovement():void
		{
			var title:TextField = Window.drawText(Locale.__e("flash:1393580965018"), {
				fontSize:28,
				color:0xf9fefa,
				autoSize:"left",
				borderColor:0x68421b
			});
			improvementCont.addChild(title);
			title.x = - title.textWidth / 2 - 25;
			
			var cont:Sprite = new Sprite();
			var iconChance:Bitmap = new Bitmap(UserInterface.textures.clever);
			var iconTime:Bitmap = new Bitmap(Window.textures.timerYellow);
			underIcon1 = new Bitmap(Window.textures.boost);
			underIcon2 = new Bitmap(Window.textures.boost);
			
			
			if (!App.user.rooms[roomID].drop) App.user.rooms[roomID]['drop'] = 0;
			if(App.user.rooms[roomID].drop == 0)TweenMax.to(underIcon1, 0.01, {colorTransform:{tint:0x777655, tintAmount:0.3}});
			
			iconChance.x = (underIcon1.width - iconChance.width) / 2;
			iconChance.y = (underIcon1.height - iconChance.height) / 2;
			
			iconTime.scaleX = iconTime.scaleY = 1.2;
			iconTime.smoothing = true;
			
			chanceTxt = Window.drawText(String(int(App.user.rooms[roomID]['drop']) / App.data.storage[roomID].percent), {//App.data.storage[IMPROVE_CHANCE].capacity
				fontSize:34,
				color:0xffd822,
				autoSize:"left",
				borderColor:0x68421b,
				multiline:true
			});
			
			if (!App.user.rooms[roomID].times) App.user.rooms[roomID]['times'] = 0;
			
			if(App.user.rooms[roomID].times == 0)TweenMax.to(underIcon2, 0.01, {colorTransform:{tint:0x777655, tintAmount:0.3}});
			
			timeTxt = Window.drawText(String(App.user.rooms[roomID].times), {//App.data.storage[IMPROVE_TIME].capacity
				fontSize:34,
				color:0xffd822,
				autoSize:"left",
				borderColor:0x68421b,
				multiline:true
			});
			
			
			chanceTxt.x = underIcon1.width;
			chanceTxt.y = 26;
			
			underIcon2.x = chanceTxt.x + chanceTxt.textWidth + 18;
			
			iconTime.x = underIcon2.x + (underIcon2.width - iconTime.width) / 2;
			iconTime.y = (underIcon2.height - iconTime.height) / 2 - 3;
			
			timeTxt.x = underIcon2.x + underIcon2.width/* + 3*/;
			timeTxt.y = 26;
			
			cont.addChild(underIcon1);
			cont.addChild(underIcon2);
			cont.addChild(iconChance);
			cont.addChild(iconTime);
			cont.addChild(chanceTxt);
			cont.addChild(timeTxt);
			
			cont.x = -cont.width / 2 - 25;
			cont.y = title.y + title.textHeight + 10;
			
			improvementCont.addChild(cont);
			
			//
			var bttnCont:Sprite = new Sprite();
			
			var chanceBttnTxt:TextField = Window.drawText(Locale.__e("flash:1402926446034"), {
				fontSize:28,
				color:0xFFFFFF,
				autoSize:"left",
				borderColor:0x713928
			});
			bttnCont.addChild(chanceBttnTxt);
			
			
			var timeBttnTxt:TextField = Window.drawText(Locale.__e("flash:1383229215303"), {
				fontSize:28,
				color:0xFFFFFF,
				autoSize:"left",
				borderColor:0x713928
			});
			bttnCont.addChild(timeBttnTxt);
			
			
			
			bttnImproveChance = new MoneyButton({
					caption		:Locale.__e('flash:1382952379751'),
					width		:102,
					height		:63,	
					fontSize	:24,
					countText	:String(Math.ceil(App.data.storage[roomID].percent/5) * App.data.options.DropPrice),
					multiline	:true,
					radius:20,
					iconScale:0.67,
					fontBorderColor:0x4d7d0e,
					fontCountBorder:0x4d7d0e
			});
			bttnCont.addChild(bttnImproveChance);
			
			bttnImproveChance.textLabel.y -= 12;
			bttnImproveChance.textLabel.x = 0;
			
			bttnImproveChance.coinsIcon.y += 12;
			bttnImproveChance.coinsIcon.x = 2;
			
			bttnImproveChance.countLabel.y += 12;
			bttnImproveChance.countLabel.x = bttnImproveChance.coinsIcon.x + bttnImproveChance.coinsIcon.width + 6;
			
			var txtWidth:int = bttnImproveChance.textLabel.width;
			if ((bttnImproveChance.coinsIcon.width + 6 + bttnImproveChance.countLabel.width) > txtWidth) {
				txtWidth = bttnImproveChance.coinsIcon.width + 6 + bttnImproveChance.countLabel.width;
				bttnImproveChance.textLabel.x = (txtWidth - bttnImproveChance.textLabel.width) / 2;
			}
			
			bttnImproveChance.topLayer.x = (bttnImproveChance.settings.width - txtWidth)/2;
			
			bttnImproveTime = new MoneyButton({
					caption		:Locale.__e('flash:1382952379751'),
					width		:102,
					height		:63,	
					fontSize	:24,
					countText	:String(Math.ceil(App.data.storage[roomID].term / App.data.options.SpeedUpPrice)),
					multiline	:true,
					radius:20,
					iconScale:0.67,
					fontBorderColor:0x4d7d0e,
					fontCountBorder:0x4d7d0e
			});
			bttnCont.addChild(bttnImproveTime);
			
			bttnImproveTime.textLabel.y -= 12;
			bttnImproveTime.textLabel.x = 0;
			
			bttnImproveTime.coinsIcon.y += 12;
			bttnImproveTime.coinsIcon.x = 2;
			
			bttnImproveTime.countLabel.y += 12;
			bttnImproveTime.countLabel.x = bttnImproveTime.coinsIcon.x + bttnImproveTime.coinsIcon.width + 6;
			
			txtWidth = bttnImproveTime.textLabel.width;
			if ((bttnImproveTime.coinsIcon.width + 6 + bttnImproveTime.countLabel.width) > txtWidth) {
				txtWidth = bttnImproveTime.coinsIcon.width + 6 + bttnImproveTime.countLabel.width;
				bttnImproveTime.textLabel.x = (txtWidth - bttnImproveTime.textLabel.width) / 2;
			}
			
			bttnImproveTime.topLayer.x = (bttnImproveTime.settings.width - txtWidth)/2;
			
			
			//coords
			bttnImproveChance.y = chanceBttnTxt.textHeight + 6;
			bttnImproveTime.y = bttnImproveChance.y;
			bttnImproveTime.x = bttnImproveChance.width + 20;
			chanceBttnTxt.x = (bttnImproveChance.width - chanceBttnTxt.textWidth) / 2;
			timeBttnTxt.x = bttnImproveTime.x + (bttnImproveTime.width - timeBttnTxt.textWidth) / 2;
			
			improvementCont.addChild(bttnCont);
			bttnCont.x = - bttnCont.width / 2 - 25;
			bttnCont.y = cont.y + cont.height - 10;
			//
			
			//improvementCont.x = App.self.stage.stageWidth / 2;
			//improvementCont.y = bottomBg.y + 90;
			
			improvementCont.x = 460//(bottomsContainer.width - improvementCont.width)/2 + 135;
			improvementCont.y = bottomBg.y + 90;
			
			bottomsContainer.addChild(improvementCont);
			
			bttnImproveTime.addEventListener(MouseEvent.CLICK, onImproveTime);
			bttnImproveChance.addEventListener(MouseEvent.CLICK, onImproveChance);
		}
		
		private function onImproveChance(e:MouseEvent):void 
		{
			if (bttnImproveChance.mode == Button.DISABLED) return;
			
			var price:int = Math.ceil(App.data.storage[roomID].percent / 5) * App.data.options.DropPrice;
			if (!App.user.stock.takeAll( { 5:price } )) {
				close();
				BankMenu._currBtn = BankMenu.REALS;
				BanksWindow.history = { section:'Reals', page:0 };
				new BanksWindow().show();
				return;
			}
			
			Hints.minus(Stock.FANT, price, Window.localToGlobal(bttnImproveChance), true, this);
			bttnImproveChance.state = Button.DISABLED;
			
			Post.send({
				ctr:'missionhouse',
				act:'boost',
				uID:App.user.id,
				rID:settings.roomInfo.id,
				type:'drop'	
			}, function(error:int, data:Object, params:Object):void {
				if (error) {
					Errors.show(error, data, params);
					return;
				}
				var time:int = startTime + timeToEnd - App.time;
				if (time > 0)
					bttnImproveChance.state = Button.NORMAL;
				
				if(App.user.rooms[roomID].drop == 0)TweenMax.to(underIcon1, 0.5, {colorTransform:{tint:0x777655, tintAmount:0}});
				
				if(App.user.rooms[roomID]['drop'])
					App.user.rooms[roomID]['drop'] += App.data.storage[roomID].percent;
				else 
					App.user.rooms[roomID]['drop'] = App.data.storage[roomID].percent;
				
				chanceTxt.text = String(int(App.user.rooms[roomID]['drop']) / App.data.storage[roomID].percent);
				updateOuts();
			});
		}
		
		private function onImproveTime(e:MouseEvent):void 
		{
			if (bttnImproveTime.mode == Button.DISABLED) return;
			
			var price:int = Math.ceil(App.data.storage[roomID].term / App.data.options.SpeedUpPrice);
			if (!App.user.stock.takeAll( { 5:price } )) {
				close();
				BankMenu._currBtn = BankMenu.REALS;
				BanksWindow.history = { section:'Reals', page:0 };
				new BanksWindow().show();
				return;
			}
			
			Hints.minus(Stock.FANT, price, Window.localToGlobal(bttnImproveTime), true, this);
			bttnImproveTime.state = Button.DISABLED;
			
			Post.send({
				ctr:'missionhouse',
				act:'boost',
				uID:App.user.id,
				rID:settings.roomInfo.id,
				type:'time'
			}, onImproveTimeComplete);
		}
		
		private function onImproveTimeComplete(error:int, data:Object, params:Object):void {
				if (error) {
					Errors.show(error, data, params);
					return;
				}
				
				if(App.user.rooms[roomID].times == 0)TweenMax.to(underIcon2, 0.5, {colorTransform:{tint:0x777655, tintAmount:0}});
				
				if(App.user.rooms[roomID]['times'])
					App.user.rooms[roomID]['times'] ++;
				else
					App.user.rooms[roomID]['times'] = 1;
				
				timeTxt.text = App.user.rooms[roomID]['times'];
				startTime -= App.data.storage[roomID].term;
				settings.target.updateTime(startTime);
				App.user.rooms[roomID].time = startTime;
				
				var time:int = startTime + timeToEnd - App.time;
				if (time > 0 && bttnImproveTime)
					bttnImproveTime.state = Button.NORMAL;
		}
		
		override protected function onRefreshPosition(e:Event = null):void
		{ 		
			bottomsContainer.x = App.self.stage.stageWidth / 2 - bottomsContainer.width / 2;
			bottomsContainer.y = App.self.stage.stageHeight - bottomBg3.height + 25;
		}
		
		private function setPosition():void
		{
			var posX:int = 0;
			var posy:int = 0;
			var Xs:int = 0;
			var Ys:int = 0;
			var count:int = 0;
			
			for (var i:int = 0; i < arrOutItems.length; i++ ) {
				
				arrOutItems[i].x = Xs;
				arrOutItems[i].y = Ys;
				
				Xs += arrOutItems[i].bg.width+20;
				if (count == 1)	{
					Xs = posX;
					Ys += arrOutItems[i].bg.height + 10;
					count = 0;
				}else {
					count++;
				}
			}
			opened = false;
		}
	}
}

import buttons.Button;
import buttons.ImageButton;
import buttons.SimpleButton;
import com.greensock.easing.Bounce;
import com.greensock.TweenLite;
import com.greensock.TweenMax;
import core.Load;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.filters.GlowFilter;
import flash.geom.ColorTransform;
import flash.text.TextField;
import flash.utils.setTimeout;
import ui.Cursor;
import ui.UserInterface;
import units.AnimationItem;
import units.Personage;
import wins.Window;

internal class OutItem extends Sprite {
	
	public var settings:Object = { };
	public var bg:Bitmap;
	public var progressBar:Bitmap;
	public var progressBarColor:Bitmap;
	
	public var count:int;
	
	private var countTxt:TextField;
	
	public var maskProgress:Sprite;
	public var sprTip:LayerX = new LayerX();
	
	public function OutItem(settings:Object) {
		
		this.settings = settings;
		count = settings.count;
		
		drawBody();
		
		updateProgress();
		
		sprTip.tip = function():Object {
			return {
				title: App.data.storage[settings.id].title,
				text: App.data.storage[settings.id].description
			};
		}
		
		Load.loading(Config.getIcon(App.data.storage[settings.id].type, App.data.storage[settings.id].preview), onPreviewComplete);
	}
	
	private function onPreviewComplete(data:Bitmap):void 
	{
		var icon:Bitmap = data;
		
		switch(settings.id) {
			case Stock.COINS:
				icon.height = bg.height - 18;
				icon.scaleX = icon.scaleY;
			break;
			case Stock.EXP:
				icon.height = bg.height - 18;
				icon.scaleX = icon.scaleY;
			break;
			case Stock.FANTASY:
				icon = new Bitmap(UserInterface.textures.energyIcon/*, "auto"*/);
				icon.height = bg.height - 18;
				icon.scaleX = icon.scaleY;
			break;
			default:
				if (icon.width > icon.height) {
					icon.width = bg.width - 5;
					icon.scaleY = icon.scaleX;
				}else{
					icon.height = bg.height - 5;
					icon.scaleX = icon.scaleY;
				}
		}
		icon.smoothing = true;
		addChildAt(sprTip, 2);
		sprTip.addChild(icon);
		sprTip.x = (bg.width - sprTip.width) / 2;
		sprTip.y = (bg.height - sprTip.height) / 2 - 3;
	}
	
	public function drawBody():void
	{
		bg = new Bitmap(Window.textures.productBacking2);
		bg.width = 72; bg.height = 76;
		bg.smoothing = true;
		addChild(bg);
		
		progressBar = new Bitmap(Window.textures.roundProgressBar);
		progressBar.x = (bg.width - progressBar.width) / 2;
		progressBar.y = bg.height / 2 - 4;
		//progressBar.smoothing = true;
		
		progressBarColor = new Bitmap(Window.textures.roundProgressBarGreen);
		progressBarColor.x = (bg.width - progressBarColor.width) / 2;
		progressBarColor.y = bg.height / 2 -2;
		//progressBarColor.smoothing = true;
		progressBarColor.visible = false;
		
		addChild(progressBar);
		addChild(progressBarColor);
		
		
		if(settings.count > 1){
			countTxt = Window.drawText(String(settings.count), {
				fontSize:24,
				color:0xfff116,
				autoSize:"left",
				borderColor:0x3d2500
			});
			addChild(countTxt);
			countTxt.x = (bg.width - countTxt.textWidth) / 2 - 2;
			countTxt.y = bg.height - countTxt.textHeight - 20;
		}
	}
	
	private var percent:int = 0;
	public function updateProgress(value:int = 0):void
	{
		var doGlow:Boolean = true;
		if (percent == 100) doGlow = false;
		
		if (maskProgress && contains(maskProgress)) removeChild(maskProgress);
		
		percent = 0;
		var value:int = 0;
	
		if (App.user.rooms && App.user.rooms[settings.target.roomID]) {
			//увеличение дропа, от нажатия кнопки увеличить шанс
			value = App.user.rooms[settings.target.roomID]['drop'];
			percent += value;
			
			//увеличение за счет друзей
			percent +=  settings.target.getNumFriends() * App.data.storage[settings.target.roomID].percent;
		}
		
		
		for (var i:int = 0; i < settings.target.arrHeroesSids.length; i++ ) {
			var key:int = settings.target.arrHeroesSids[i];
			if(App.data.storage[settings.id].personages[key])
				percent += App.data.storage[settings.id].personages[key];	
		}
		
		if (percent > 100)
			percent = 100;
		
		var posRadius:int = 180 - Math.round(1.8 * percent);
		
		var color:uint = setProgressColor(percent);
		
		maskProgress = drawSegment(posRadius, 180, bg.height / 2 + 5, bg.width / 2, bg.width / 2, 2, 0xEEEEEE, 0x003da8);
		addChildAt(maskProgress, 0);
		
		progressBarColor.mask = maskProgress;
		progressBarColor.visible = true;
		
		if(doGlow)customGlowing(progressBarColor, color);
	}
	
	private function customGlowing(target:*, color:uint):void {
		TweenMax.to(target, 0.6, { glowFilter: { color:color, alpha:0.8, strength: 7, blurX:12, blurY:12 }, onComplete:function():void {
			TweenMax.to(target, 0.5, { glowFilter: { color:color, alpha:0, strength:1, blurX:1, blurY:1 }, onComplete:function():void {
			}});
		}});
	}
	
	private function setProgressColor(percent:int):uint 
	{
		var color:uint;
		if (percent >= 86) {
			color = 0x73bb16;//0x18a117;
		}else if (percent >= 60) {
			color = 0x99bf38;
		}else if (percent >= 40) {
			color = 0xf3c21a;
		}else if (percent > 20) {
			color = 0xd65d22;
		}else {
			color = 0xf03d21;
		}
		
		var colorTr:ColorTransform = new ColorTransform();
		colorTr.color = color;
		
		progressBarColor.transform.colorTransform = colorTr;
		
		return color;
	}
	
	public function drawSegment(startAngle:Number, endAngle:Number, segmentRadius:Number, xpos:Number, ypos:Number, step:Number, lineColor:Number, fillColor:Number):Sprite {
		 var holder:Sprite = new Sprite();
		 
		 holder.graphics.lineStyle(2, lineColor);
		 holder.graphics.beginFill(fillColor);
		 
		 var originalEnd:Number = -1;
		 if(startAngle > endAngle){
			  originalEnd = endAngle;
			  endAngle = 360;
		 }
		 var degreesPerRadian:Number = Math.PI / 180;
		 var theta:Number;
		 startAngle *= degreesPerRadian;
		 endAngle *= degreesPerRadian;
		 step *= degreesPerRadian;

		 
		 holder.graphics.moveTo(xpos, ypos);
		 for (theta = startAngle; theta < endAngle; theta += Math.min(step, (endAngle - theta))) {
			  holder.graphics.lineTo(xpos + segmentRadius * Math.cos(theta), ypos + segmentRadius * Math.sin(theta));
		 }
		 holder.graphics.lineTo(xpos + segmentRadius * Math.cos(endAngle), ypos + segmentRadius * Math.sin(endAngle));

		 if(originalEnd > -1){ 
			  startAngle = 0;
			  endAngle = originalEnd * degreesPerRadian;
			  for (theta = startAngle; theta < endAngle; theta += Math.min(step, endAngle - theta)) {
				   holder.graphics.lineTo(xpos + segmentRadius * Math.cos(theta), ypos + segmentRadius * Math.sin(theta));
			  }
			  holder.graphics.lineTo(xpos + segmentRadius * Math.cos(endAngle), ypos + segmentRadius * Math.sin(endAngle));
		 }
		 holder.graphics.lineTo(xpos, ypos);
		 holder.graphics.endFill();
		 
		return holder;
    }
	
	public function dispose():void
	{
		if (bg && contains(bg)) removeChild(bg);
		bg = null;
		
		if (progressBar && contains(progressBar)) removeChild(progressBar);
		progressBar = null;
		
		if (progressBarColor && contains(progressBarColor)) removeChild(progressBarColor);
		progressBarColor = null;
		
		if (countTxt && contains(countTxt)) removeChild(countTxt);
		countTxt = null;
		
		if (maskProgress && contains(maskProgress)) removeChild(maskProgress);
		maskProgress = null;
	}
}


import core.Load;
import flash.display.Bitmap;
import flash.display.Sprite;
import wins.Window;
import wins.PersonageInfoWindow;

internal class ReqItem extends Sprite {
	
	public var settings:Object = { };
	public var countTxt:TextField;
	
	public var sprTip:LayerX = new LayerX();
	public function ReqItem(settings:Object) {
		
		this.settings = settings;
		
		var count:int = App.user.stock.count(settings.id);
		
		var txtSettings:Object = {
			fontSize:22,
			color:0xf4ce54,
			autoSize:"left",
			borderColor:0x623126
		};
		
		if (count < settings.count) {
			txtSettings['color'] = 0xef7563;
		}
		
		sprTip.tip = function():Object {
			return {
				title: App.data.storage[settings.id].title,
				text: App.data.storage[settings.id].description
			};
		}
		
		countTxt = Window.drawText(String(count) + " / " + String(settings.count), txtSettings);
		
		
		Load.loading(Config.getIcon(App.data.storage[settings.id].type, App.data.storage[settings.id].preview), onPreviewComplete);
	}
	
	private function onPreviewComplete(data:Bitmap):void 
	{
		var icon:Bitmap = data;
		icon.scaleX = icon.scaleY = 0.6;
		icon.smoothing = true;
		//addChildAt(icon, 0);
		
		addChildAt(sprTip, 0);
		sprTip.addChild(icon);
		
		addChild(countTxt);
		countTxt.x = (icon.width - countTxt.textWidth) / 2;
		countTxt.y = 62;
		
		if (settings.callBack != null)
			settings.callBack();
	}
}

import wins.InstanceWindow;
internal class PersonageItem extends LayerX 
{
	public var anim:AnimationItem;
	public var icon:ImageButton;
	private var stand:Bitmap;
	public var sid:uint;
	private var window:InstanceWindow;
	private var persEnabled:Boolean;
	
	//private var roomID:int;
	//private var startTime:int;
	//private var roomTime:int;
	
	public function PersonageItem(_window:InstanceWindow, _persEnabled:Boolean) {
		window = _window
		persEnabled = _persEnabled;
		//for (var ind:* in App.user.rooms ) {
				//for (var pers:* in App.user.rooms[ind].pers) {
					//roomID = ind;
					//startTime = App.user.rooms[ind].time;
					//roomTime = App.data.storage[ind].time;
					//if (sid == App.user.rooms[ind].pers[pers]) { 
						//break;
					//}
				//}
			//}
		addEventListener(MouseEvent.MOUSE_OVER, onMouseOverHandler);
		addEventListener(MouseEvent.MOUSE_OUT, onMouseOutHandler);
	}
	private function addStand():void
	{
		if (persEnabled == true) {
			stand = new Bitmap(Window.textures.buildingsActiveBacking);
		}else
		{
			stand = new Bitmap(Window.textures.buildingsLockedBacking);
			stand.alpha = 0.8;
		}
		addChild(stand);
		stand.width = stand.height = 83;
		stand.smoothing = true;
		stand.x = -stand.width / 2 + 35;
		stand.y = -1 * stand.height / 5 + 27;
	}
	private function onMouseOverHandler(e:MouseEvent):void 
	{
		if (persEnabled == true) {
			removeArrow();
			drawArrow();
		}/*else {
			if (PersonageInfoWindow.persSid != pers.sid) {
				App.self.dispatchEvent(new AppEvent(AppEvent.ON_CLOSE_INFO));
				setTimeout(function():void { if (!PersonageInfoWindow.isOpen) new PersonageInfoWindow(PersonageInfoWindow.MODE_PERS, { 
					sid:sid, 
					x:stand.x + stand.width / 2 + 50, 
					y:stand.y + stand.height / 2 + 50,
					startTime:startTime, 
					endTime:startTime - App.time + roomTime 
					pers:pers } ).show()} , 200);
			}
		}*/
		
	}
	
	private function onMouseOutHandler(e:MouseEvent):void 
	{
		if (persEnabled == true) {
			removeArrow();
		}
		
	}

	private var shadowCont:LayerX = new LayerX();
	private var shadow:Bitmap;
	
	private var arrow:MovieClip;
	
	private function drawArrow():void
	{
		arrow = new MovieClip();// blueArrow(); 
		arrow.mouseEnabled = false;
		arrow.alpha = 0;
	
		if (arrow != null){
			addChild(arrow);
			TweenLite.to(arrow, 0.5, { alpha:1, ease:Bounce.easeInOut } );
			arrow.scaleX = -1;
		}
		
		switch (sid) 
		{
			case 162:
				arrow.x = 205;
				arrow.y = 100;
				arrow.rotation = 25;
			break;
			case 163:
				arrow.x = 210;
				arrow.y = 75;
				arrow.rotation = 15;
			break;
			case 292:
				arrow.rotation = 5;
				arrow.x = 210;
				arrow.y = 40;
			break;
			case 532:
				arrow.rotation = 5;
				arrow.x = 210;
				arrow.y = 40;
			break;
			default:
				arrow.rotation = 5;
				arrow.x = 210;
				arrow.y = 40;
			break;
		}

		arrow.mouseEnabled = false;
	}
	
	private function removeArrow():void
	{
		if (arrow && arrow.parent)
		{
			removeChild(arrow);
			arrow = null;
		}
	}
	
	public function add(sid:uint, hasPers:Boolean = true):void {
		clear();
		
		this.sid = sid;
		if (!hasPers) {
			//shadow = getShadow(sid);
			//addChild(shadow);
			//shadow.x = -shadow.width / 2 - 6;
			//shadow.y = -shadow.height + 20;
			//var instanceId:int = 0;
			var roomId:int = 0;
			for (var ind:* in App.user.rooms ) {
				for (var pers:* in App.user.rooms[ind].pers) {
					if (sid == App.user.rooms[ind].pers[pers]) {
						roomId = ind;
						break;
					}
				}
			}
			//for (ind in App.data.storage) {
				//if (App.data.storage[ind].type == 'Missionhouse') {
					//for (var rm:* in App.data.storage[ind].rooms) {
						//if (roomId == App.data.storage[ind].rooms[rm]) {
							//instanceId = ind;
						//}
					//}
				//}
			//}
			//shadowCont.addChild(shadow);
			//shadowCont.x = -shadowCont.width / 2 - 6;
			//shadowCont.y = -shadowCont.height + 20;
			//addChild(shadowCont);
			
			var txt:String;
			if (roomId > 0) txt = Locale.__e("flash:1394017542970") + " " + App.data.storage[roomId].title;
			else Locale.__e("flash:1394017554554")
			
			shadowCont.tip = function():Object {
				return {
					title:App.data.storage[sid].title,
					text:txt
				}
			}
			return;
		}
		
		switch(App.data.storage[sid].preview) {
			case "man":
				icon =  new ImageButton(UserInterface.textures.manIcon);
				icon.y += 5;
			break;
			case "woman":
				icon =  new ImageButton(UserInterface.textures.womanIcon);
			break;
			case "stumpy":
				icon =  new ImageButton(UserInterface.textures.stumpyInstanceIco);
				icon.y -= 6;
				icon.x += 1;
			break;
			case "bronco":
				icon =  new ImageButton(UserInterface.textures.engineerInstanceIco);
				icon.y -= 6;
				icon.x += 1;
			break;
			default:
				icon =  new ImageButton(UserInterface.textures.womanIcon);
		}
		addStand();
		if (persEnabled == false) {
			//icon.mouseEnabled = false;
			icon.tip = function():Object { return { title:Locale.__e("flash:1394017554554"), text:Locale.__e("flash:1393584125850") }; }
			icon.alpha = 0.8;
		}
		addChild(icon);
		if (persEnabled == true) {
			icon.addEventListener(MouseEvent.MOUSE_OVER, onOver);
			icon.addEventListener(MouseEvent.CLICK, onClick);
			icon.addEventListener(MouseEvent.CLICK, onBeforeClick, false, 500);
			icon.addEventListener(MouseEvent.MOUSE_OUT, onOut);
		}
		
	}
	
	
	private function onBeforeClick(e:MouseEvent):void {
			
		if (Quests.lockButtons) {
			e.stopImmediatePropagation();
			Quests.lockButtons = false;
		}
	}
	
	private function onOver(e:MouseEvent):void {
		icon.bitmap.filters = [new GlowFilter(0xFFFF00, 1, 10, 10, 6)];
	}
	
	private function onOut(e:MouseEvent):void {
		icon.bitmap.filters = [];
	}
	
	private function onClick(e:MouseEvent):void {
		window.setHeroInto(sid);
	}
	
	public function clear():void {
		if (icon == null)
			return;
		
		if (shadowCont && shadowCont.parent)
			shadowCont.parent.removeChild(shadowCont);
		shadowCont = null;
			
		icon.removeEventListener(MouseEvent.MOUSE_OVER, onOver);
		icon.removeEventListener(MouseEvent.CLICK, onClick);
		icon.removeEventListener(MouseEvent.MOUSE_OUT, onOut);
		icon.dispose();
		//removeChild(icon);
		icon = null;
	}
}

internal class HeroItem extends Sprite {
	
	public static const TYPE_1:int = 1;
	public static const TYPE_2:int = 2;
	public static const TYPE_3:int = 3;
	
	public var settings:Object = { };
	public var type:int;
	
	public var exit:ImageButton	= null;
	private var container:SimpleButton = new SimpleButton();//Sprite = new Sprite();
	
	private var _empty:Boolean = true;
	public var heroSid:int = 0;
	
	public function HeroItem(type:int, settings:Object = null) {
		
		this.settings = settings;
		this.type = type;
		drawBody();
	}
	
	//private var icon:Bitmap;
	private var icon:AnimationItem;
	private var bg:Bitmap;
	private function drawBody():void 
	{
		bg = new Bitmap(Window.textures.stand);
		//bg.width = 72; bg.height = 76;
		bg.x = -bg.width / 2;
		bg.y = -1 * bg.height / 5;
		bg.smoothing = true;
		
		exit = new ImageButton(Window.textures.closeBttn);
		exit.scaleX = exit.scaleY = 0.5;
		exit.x = bg.width - 17;
		//exit.onClick = onClose;
		
		exit.addEventListener(MouseEvent.MOUSE_UP, onClose);
		exit.visible = false;
		
		container.addChild(bg);
		container.addEventListener(MouseEvent.MOUSE_UP, onClose);
		addChild(container);
		container.mouseEnabled = false;

		//addChild(exit);
	}
	
	public function addHero(sid:int):void
	{
		var heroType:String = (App.data.storage[sid].view != 'man' && App.data.storage[sid].view != 'woman' && App.data.storage[sid].type == 'Personage')?'Clothes':App.data.storage[sid].type;
		//var minf:* = 0; App.user.personages[0].info
		//var winf:* = minf;
		//if(App.user.personages.length > 1)
			//winf = App.user.personages[1].info;
		
		icon = new AnimationItem( {
			type:	heroType,
			view:	App.data.storage[sid].view,
			framesType:Personage.STOP,
			direction:0,
			flip:1
		}); 
		icon.x = (bg.width - icon.width) / 2 - 15;
		icon.y = (bg.height - icon.height) / 2 + 45;
		if (sid == 162) {
			switch(App.data.storage[sid].view) {
				case 'man_dracula':
					icon.y = -31;
					icon.x = -5;
					break;
				case 'man':
					icon.y = +5;
					icon.x = -1;
					break;
				default:
					break;
			}
		}
		if (sid == 163)
		{
			icon.scaleX *= -0.8;
			icon.scaleY *= 0.8;
			switch(App.data.storage[sid].view) {
				case 'woman_halloween':
					icon.y = -16;
					icon.x = -2;
					break;
				case 'woman':
					icon.y = +7;
					icon.x = -5;
					break;
				default:
					break;
			}

		}else if (sid == 292) {
			icon.x = (bg.width - icon.width) / 2  + 10;
			icon.scaleX *= -1;
		}else {
			icon.scaleX *= -1;
		}

		heroSid = sid;
		
		container.addChild(icon);
		empty = false;
		
		if (!settings.target.isWork) exit.visible = true;
		
		App.ui.flashGlowing(container, 0x56ffff);
	}
	
	public function onClose(e:MouseEvent = null):void 
	{
		//if(InstanceWindow.isTutorial)
			//return;
		
		if (icon) {
			settings.target.removeHero(heroSid);
			settings.target.updateOuts();
			
			container.removeChild(icon);
			icon = null;
			empty = true;
			heroSid = 0;
			exit.visible = false;
		}
	}
	
	public function itemOff():void
	{
		this.visible = false;
	}
	
	public function exitOff():void
	{
		exit.visible = false;
	}
	
	public function getHeroSid():int
	{
		return heroSid;
	}
	
	public function get empty():Boolean 
	{
		return _empty;
	}
	
	public function set empty(value:Boolean):void 
	{
		_empty = value;
	}
	
	public function dispose():void
	{
		if (exit) {
			exit.removeEventListener(MouseEvent.MOUSE_UP, onClose);
			exit.dispose();
		}
		exit = null;
		
		if (container) {
			container.removeEventListener(MouseEvent.MOUSE_UP, onClose);
			container.dispose();
			if (contains(container)) removeChild(container);
		}
		container = null;
		
		if (bg && contains(bg) ) removeChild(bg);
		bg = null;
	}
	
}