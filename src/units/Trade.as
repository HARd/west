package units 
{
	import com.greensock.easing.Back;
	import com.greensock.TweenLite;
	import core.Post;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.utils.setTimeout;
	import wins.ConstructWindow;
	import wins.ErrorWindow;
	import wins.PortWindow;
	import wins.TradeWindow;
	import wins.Window;
	/**
	 * ...
	 * @author ...
	 */
	public class Trade extends Building
	{
		public static const TRADE_ID:int = 179;
		
		public static var saleItemId:int = 0;
		
		//public static var trade:Trade;
		
		//public static function onSell(trade:*, tradeItems:Object):void 
		//{
			//Trade.trade.canTrade = false;
			//Trade.trade.setReward(trade, tradeItems);
		//}
		//
		//public static function visMark(ind:int):void
		//{
			//trade.arrMarks[ind].visible = true;
		//}
		//
		//public static function unVisMark(ind:int):void
		//{
			//trade.arrMarks[ind].visible = false;
		//}
		
		//public var cloudBonus:CloudsMenu;
		public var canTrade:Boolean = true;
		public var animContainer:Sprite = new Sprite();
		public var arrMarks:Array = [];
		private var countMarks:int = 9;
		
		public var isBonus:Boolean = false;
		
		public var trades:Object;
		
		public function Trade(object:Object) 
		{
			if (object.sid != 279)
				super(object);
			
			if (object.sid == 279) 
			{
				if(App.user.mode == User.OWNER){
					Post.send( {
						ctr:'Trade',
						act:'remove',
						uID:App.user.id,
						wID:App.user.worldID,
						sID:object.sid,
						id:object.id
					}, function(error:int, data:Object, params:Object):void {
						var newTradeShop:* = Unit.add( { sid:350, id:1, x:158, z:69 } );
						newTradeShop.buyAction();
					});
				}
				
				return;
			}
			
			//super(object);
			
			trades = object.trades;
			/*if (sid == 279) 
			{
				trace();
				//this.visible = false;
			}*/
			//Trade.trade = this;
			multiple = false;
			rotateable = true;
			removable = false;
			moveable = true;
			
			tip = function():Object {
				return {
					title:info.title,
					text:info.description
				}
			}
			
			for (var i:int = 1; i < countMarks + 1; i++ ) {
				var markCont:LayerX = new LayerX();
				var mark:Bitmap = new Bitmap(Window.textures.chestCheckMark);
				markCont.addChild(mark);
				mark.smoothing = true;
				markCont.visible = false;
				addChild(markCont);
				setMarkPos(markCont, i);
				arrMarks.push(markCont);
			}
			
			//var count:int = 0;
			//for each(var item:* in App.user.trades) {
				//if (App.user.stock.checkAll(item.items) && item.time <= App.time && level == totalLevels) {
					//arrMarks[count].visible = true;
				//}
				//count++;
			//}
			checkMarks();
			
			setPluckAnim();
			
			if(App.user.mode == User.OWNER)
				App.self.addEventListener(AppEvent.ON_CHANGE_STOCK, checkMarks);
			
			//App.ui.bottomPanel.updateTradeCounter();
		}
		
		public function checkMarks(e:AppEvent = null):void
		{
			var count:int = 0;
			for each(var item:* in trades) {
				if (App.user.stock.checkAll(item.items) && item.time <= App.time && level == totalLevels) {
					arrMarks[count].visible = true;
				}else{
					arrMarks[count].visible = false;
				}
				count++;
			}
		}
		
		public function onSell(trade:*, tradeItems:Object, callBack:Function = null):void 
		{
			saleItemId = tradeItems.ID;
			
			canTrade = false;
			setReward(trade, tradeItems);
			bonusEvent(callBack);
		}
		
		public function visMark(ind:int):void
		{
			//trade.arrMarks[ind].visible = true;
			arrMarks[ind].visible = true;
		}
		
		public function unVisMark(ind:int):void
		{
			//trade.arrMarks[ind].visible = false;
			arrMarks[ind].visible = false;
		}
		
		private var trade:*;
		private var tradeItems:Object;
		public function setReward(_trade:*, _tradeItems:Object):void
		{
			trade = _trade;
			tradeItems = _tradeItems;
			
			//bonusEvent();
			
			//flyAway();
		}
		
		private function getReward():void 
		{
			//flag = 'coins';
			/*isBonus = true;
			cloudBonus = new CloudsMenu(bonusEvent, this, Stock.COINS, { scaleIcon:0.42 } );// , tint:isTint } );
			cloudBonus.create("productBacking2");
			cloudBonus.doIconEff();
			cloudBonus.y -= 70;
			cloudBonus.show();
			setFlyAnim();
			App.self.dispatchEvent(new AppEvent(AppEvent.ON_TRADE_FLY_BACK));*/
		}
		
		//private var bonusData:Object = {};
		private var bonusClicked:Boolean = false;
		override public function click():Boolean 
		{	
			if (bonusClicked) return false;
			if (isBonus) {
				bonusEvent();
				//takeBonus();
				return true;
			}
			//if (!canTrade ) return false;
			openProductionWindow();
			//super.click();
			return true;
		}
		
		/*private function takeBonus():void
		{
			Treasures.bonus(Treasures.convert(bonusData), new Point(this.x, this.y) );
			canTrade = true;
			bonusClicked = false;
			
			if (cloudBonus) {
				cloudBonus.dispose();
				cloudBonus = null;
			}
			isBonus = false;
			bonusData = { };
		}*/
		
		public function bonusEvent(callBack:Function = null):void
		{
			
			//bonusClicked = true;
			bonusClicked = false;
			var that:Trade = this;
			
			Post.send({
			ctr:this.type,
			act:'sell',
			uID:App.user.id,
			tID:tradeItems.ID,
			wID:App.user.worldID,
			sID:sid,
			id:id
			}, function(error:int, data:Object, params:Object):void {
				if (error)
				{
					Errors.show(error, data);
					return;
				}
				
				for (var trdObj:* in trades) {
					if (trades[trdObj].ID == trade.ID) {
						break;
					}
				}
				
				if(data.cells != false){
					trades[trdObj]['items'] = data.cells[0].items;
					trades[trdObj]['reward'] = data.cells[0].reward;
					trades[trdObj]['ID'] = data.cells[0].ID;
					trades[trdObj]['time'] = data.cells[0].time;
					trades[trdObj]['urgent'] = data.cells[0].urgent;

					if (data.cells[0].urgent == 1) {
						var urgentTime:int = App.data.trades[data.cells[0].ID].time + data.cells[0].time;// + App.user.trades[data.cells[0].ID]['time'];
						trades[trdObj]['urgentTime'] = urgentTime;
					}
				}else if (data.cells == false) {
					trace();
				}
				
				for (var i:int = 0; i < arrMarks.length; i++) {
					arrMarks[i].visible = false;
				}
				
				checkMarks();
				
				if (callBack != null && data.cells != false)
					callBack(trades[trdObj]);
				
				//App.ui.bottomPanel.updateTradeCounter();
				
				//takeBonus();
				App.user.stock.addAll(data.bonus);
				
				isBonus = false;
				canTrade = true;
				bonusClicked = false;
				
				/*if (cloudBonus) {
					cloudBonus.dispose();
					cloudBonus = null;
				}*/
				
				saleItemId = 0;
			});	
		}
		
		private function setPluckAnim():void 
		{
			var count:int = 1;
			for (var i:int = 0; i < arrMarks.length; i++ ) {
				if (arrMarks[i].visible) {
					arrMarks[i].pluck(1000 * (count + 1), arrMarks[i].x + 10, arrMarks[i].y + 10);
					count++;
				}
			}
			
			setTimeout(setPluckAnim, (Math.random() * 5 * 1000 + 7000));
		}
		
		private var deltaY:int = -14;
		private var deltaX:int = -8;
		private function setMarkPos(mark:Sprite, num:int):void
		{
			switch(num) {
				case 1:
					mark.x = -65 + deltaX;
					mark.y = 2 + deltaY;
				break
				case 2:
					mark.x = -49 + deltaX;
					mark.y = -6 + deltaY;
				break;
				case 3:
					mark.x = -33 + deltaX;
					mark.y = -14 + deltaY;
				break;
				case 4:
					mark.x = -64 + deltaX;
					mark.y = 24 + deltaY;
				break;
				case 5:
					mark.x = -48 + deltaX;
					mark.y = deltaY + 17;
				break;
				case 6:
					mark.x = -32 + deltaX;
					mark.y = 7 + deltaY;
				break;
				case 7:
					mark.x = -65 + deltaX;
					mark.y = 35 + 19 + deltaY;
				break;
				case 8:
					mark.x = -48 + deltaX;
					mark.y = 38 + deltaY;
				break;
				case 9:
					mark.x = -33 + deltaX;
					mark.y = 33 + deltaY;
				break;
			}
		}
		//private var isRefresh:Boolean = false;
		override public function openProductionWindow(settings:Object = null):void
		{
			
			//if (sid == 279) 
			//{
				//trace();
				//new PortWindow(/*mode, */{
					//title:"Порт"
					////target:this,
					////onSell:onSell
					//}).show();
			//}
			
			
			if (App.user.mode == User.GUEST) {
				guestClick();
				return
			}	
			if (level >= totalLevels - craftLevels)
			{
				var isRefresh:Boolean = false;
				
				if (!trades)
					isRefresh = true;
				else {
					var cnt:int = 0;
					for (var _cnt:* in trades) {
						cnt++;
					}
					if (cnt == 0)
						isRefresh = true;
				}
				
				if (isRefresh) {
					isRefresh = false;
					if (sid == 279) 
						{
							//trace();
							//this.visible = false;
							//new ErrorWindow().show();
							
						}
					Post.send({
						ctr:this.type,
						act:'refresh',
						uID:App.user.id,
						wID:App.user.worldID,
						sID:sid,
						id:id
						}, function(error:int, data:Object, params:Object):void {
							if (error)
							{
								Errors.show(error, data);
								return;
							}
							
							if (data.cells) {
								trades = data.cells;
								realOpenWindow();
							}
						});	
					return;
				}else {
					realOpenWindow();
					return;
				}
			}
				
			new ConstructWindow( {
				title			:info.title,
				upgTime			:info.devel.req[level + 1].t,
				request			:info.devel.obj[level + 1],
				target			:this,
				onUpgrade		:function():void {
					upgradeEvent(info.devel.obj[level + 1]);
				},
				hasDescription	:true
			}).show();
		}
		
		private function realOpenWindow():void
		{
			new TradeWindow( {
				target:this,
				onSell:onSell,
				visMark:visMark,
				unVisMark:unVisMark
				}).show();
			return;
		}
		
		override public function checkOnAnimationInit():void {
			if (level > 1) {
				initAnimation();
				crafting = true;
				beginAnimation();
			}	
		}
		
		override public function addAnimation():void
		{
			ax = textures.animation.ax;
			ay = textures.animation.ay;
			
			clearAnimation();
			
			for each(var name:String in framesTypes) {
				multipleAnime[name] = { bitmap:new Bitmap(), cadr: -1 };
				animContainer.addChild(multipleAnime[name].bitmap);
				
				if (textures.animation.animations[name]['unvisible'] != undefined && textures.animation.animations[name]['unvisible'] == true) {
					multipleAnime[name].bitmap.visible = false;
				}
				multipleAnime[name]['length'] = textures.animation.animations[name].chain.length;
				multipleAnime[name]['frame'] = 0;
			}
			bitmapContainer.addChild(animContainer);
			animContainer.y = minPos;
			
			removeFly();
			setFlyAnim();
		}
		
		override public function clearAnimation():void {
			stopAnimation();
			for (var _name:String in multipleAnime) {
				animContainer.removeChild(multipleAnime[_name].bitmap);
				//bitmapContainer.removeChild(animContainer);
			}
		}
		
		//private var flyUpTween:TweenLite;
		//private var flyDownTween:TweenLite;
		private function setFlyAnim():void 
		{	
			//flyUpTween = TweenLite.to(animContainer, 2, { y: -20, /*ease:Back.easeInOut,*/ onComplete:function():void {
				//
					//flyDownTween = TweenLite.to(animContainer, 2, { y:10, /*ease:Back.easeInOut,*/ onComplete:function():void {
					//setFlyAnim();
					//
				//
				//}});
			//}});
			
			App.self.setOnEnterFrame(doFly);
		}
		
		private var minPos:int = 11;
		private var centerPos:int = -7;
		private var maxpos:int = -24;
		private var moveY:Number = 0.4;
		private var deltaMoveY:Number = 0.02;
		private var moveUp:Boolean = true;
		private var changeSpeed:Boolean = true;
		private function doFly(e:Event):void
		{
			if (moveUp) {
				animContainer.y -= moveY;
			}else{
				animContainer.y += moveY;
			}
			moveY += deltaMoveY;
			
			if ((changeSpeed && moveUp && animContainer.y <= centerPos) || (changeSpeed && !moveUp && animContainer.y >= centerPos)) {
				deltaMoveY = deltaMoveY * -1;
				changeSpeed = false;
			}
			
			if (moveUp && animContainer.y < maxpos) {//moveY <= 0
				moveUp = false;
				deltaMoveY = 0.02;
				moveY = 0.4
				animContainer.y = maxpos;
				changeSpeed = true;
			}else if(!moveUp &&  animContainer.y > minPos){//moveY <= 0
				moveUp = true;
				
				moveY = 0.4
				deltaMoveY = 0.02;
				animContainer.y = minPos;
				changeSpeed = true;
			}
		}
		
		private function removeFly():void
		{
			App.self.setOffEnterFrame(doFly);
			moveY = 0.4;
			deltaMoveY = 0.019;
			moveUp = false;
		}
		
		public function flyAway():void
		{
			removeFly();
			
			var sighn:int;
			if (Math.random() > 0.5) sighn = 1;
			else sighn = -1;
			var point1:Point = new Point(sighn * (Math.random() * 100 + 150), -(Math.random() * 100 + 50));
			
			setTimeout(function():void {
				SoundsManager.instance.playSFX('map_sound_6');
			}, 100);
			
			var point2:Point = new Point(0, point1.y * 2);
			
			
			var point3:Point = new Point(- point1.x*2, point1.y);
			
			if (sighn == 1) sighn = -1;
			else sighn = 1;
			
			var point4:Point = new Point((this.x + Map.deltaX + 50)*sighn, point3.y - (Math.random()*100 + 50));
			
			if (sighn == 1) sighn = -1;
			else sighn = 1;
			var point5:Point = new Point(200 * sighn, -500);
			
			getReward();
		}
		
		override public function uninstall():void {
			
			App.self.removeEventListener(AppEvent.ON_CHANGE_STOCK, checkMarks);
			super.uninstall();
			
			//App.ui.bottomPanel.updateTradeCounter();
		}
		
		override public function finishUpgrade():void {
			//
		}
		
	}
}