package units 
{
	import com.greensock.easing.Linear;
	import com.greensock.TweenLite;
	import core.IsoConvert;
	import core.Load;
	import core.Post;
	import flash.display.Bitmap;
	import flash.display.BlendMode;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.utils.clearInterval;
	import flash.utils.setInterval;
	import ui.SystemPanel;
	import wins.ConstructWindow;
	import wins.PortOrderWindow;
	import wins.PortWindow;
	import wins.SimpleWindow;
	/**
	 * ...
	 * @author 
	 */
	
	public class Tradeshop extends Building
	{
		public static const MODE_FREE:int = 1;
		public static const MODE_BUSY:int = 2;
		public static const MODE_DONE:int = 3;
		
		public static var countShips:int = 0;
		
		public var ships:Object = {}
		
		//public var currBoat:TradeBoat;
		public var shipAnim:Sprite = new Sprite();
		//public var ship:Sprite = new Sprite();
		
		public var mode:int;
		
		public var startedTrade:int = 0;
		
		public var dataUsers:Object = { };
		
		public var countShips:int;
		
		public var boats:Vector.<TradeBoat> = new Vector.<TradeBoat>;
		
		public function Tradeshop(object:Object) 
		{
			countShips += 1;
			
			super(object);
		
			multiple = false;
			rotateable = false;
			removable = true;
			//removable = true;
			moveable = false;
			transable = false;
			//return
			tip = function():Object {
				return {
					title:info.title,
					text:info.description
				}
			}
			
			var isTrade:Boolean = false;
			
			totalLevels = 1;
			countShips = level - totalLevels + 1;
			
			//Load.loading(Config.getSwf("Ships", "trade_boat_1"), onLoadShip);
			
			
			ships = App.user.tradeshop;
			
			//createShips();
			
			if(App.user.mode == User.OWNER){
				Post.send({
					ctr:this.type,
					act:'check',
					uID:App.user.id,
					wID:App.user.worldID
				}, function(error:int, data:Object, params:Object):void {
					if (error){
						Errors.show(error, data);
						return;
					}
					ships = data.ships;
					App.user.tradeshop = ships;
					
					createShips();
					
					checkShips();
				});	
			}
			
			//checkShips();
			
			/* var center:Shape = new Shape();
			 center.graphics.beginFill(0xFFFFFF, 1);
			 center.graphics.drawCircle(0, 0, 5);
			 center.graphics.endFill();
			 addChild(center);*/
		}
		
		override protected function onBuyAction(error:int, data:Object, params:Object):void 
		{
			if (error) {
				Errors.show(error, data);
				return;
			}
			
			this.id = data.id;
		}
		
		private var boatsCoords:Object = { 
			1:{x:100, y:120},
			2:{x:300, y:60},
			3:{x:440, y:-40}
		};
		
		private function createShips():void 
		{
			var countBoats:int = level;
			for (var i:int = 0; i < countBoats; i++ ) {
				
				var boat:TradeBoat = new TradeBoat( { id:i+1 } );
				
				boat.x = this.x + boatsCoords[i+1].x;
				boat.y = this.y + boatsCoords[i+1].y;
				
				boats.push(boat);
			}
			addBoats();
		}
		
		override public function onUpgradeEvent(error:int, data:Object, params:Object):void 
		{
			if (error){
				Errors.show(error, data);
				return;
			}else {
				hasUpgraded = false;
				hasBuilded = true;
				upgradedTime = data.upgrade;
				App.self.setOnTimer(upgraded);
				//addProgressBar();
				addEffect(Building.BUILD);
				
				adBoat();
			}
		}
		
		private function addBoats():void
		{
			for (var i:int = boats.length-1; i >= 0; i-- ) {
				App.map.mUnits.addChild(boats[i]);
			}
		}
		
		private function adBoat():void
		{
			var idBoat:int = boats.length + 1;
			
			var boat:TradeBoat = new TradeBoat( { id:idBoat } );
			
			boat.x = this.x + boatsCoords[idBoat].x;
			boat.y = this.y + boatsCoords[idBoat].y;
			
			boats.push(boat);
			addBoats();
		}
		
		private var isFreeShip:Boolean = false;
		private function checkShips():void 
		{
			//return
			var counter:int = 0;
			isFreeShip = false;
			for (var key:* in App.user.tradeshop) {
				if (key == 'start') continue;
				counter++;
				if (App.user.tradeshop[key].start + App.data.storage[sid].time * 3600 <= App.time) {
					setBonusIcon();
					moveShip(int(key), true);
				}else {
					if (boats[int(key)-1].typeMove != TradeBoat.STRAIGHT)
						moveShip(int(key));
				}
			}
			
			//if (counter < countShips)
				//isFreeShip = true;
				
		}
		
		private function checkShip(ind:int):void 
		{
			if (App.user.tradeshop[ind]) {
				if (App.user.tradeshop[ind].start + App.data.storage[sid].time * 3600 <= App.time) {
					setBonusIcon();
					moveShip(ind, true);
				}else {
					if (boats[ind-1].typeMove != TradeBoat.STRAIGHT)
						moveShip(ind);
				}
			}
		}
		
		override public function updateLevel(checkRotate:Boolean = false):void 
		{
			if (textures == null) return;
			totalLevels = 1;
			var ind:int = this.level;
			if (ind > totalLevels)
				ind = totalLevels;
			
			var levelData:Object = textures.sprites[ind];
			
			
			if (checkRotate && rotate == true) {
				flip();
			}
			
			if (this.level != 0 && gloweble)
			{
				var backBitmap:Bitmap = new Bitmap(bitmap.bitmapData);
				backBitmap.x = bitmap.x;
				backBitmap.y = bitmap.y;
				addChildAt(backBitmap, 0);
				
				bitmap.alpha = 0;
				
				App.ui.flashGlowing(this, 0x6fefff);
				
				TweenLite.to(bitmap, 0.4, { alpha:1, onComplete:function():void {
					removeChild(backBitmap);
					backBitmap = null;
				}});
				
				gloweble = false;
			}
			
			draw(levelData.bmp, levelData.dx, levelData.dy);
			
			checkOnAnimationInit();
		}
		
		
		//public var axS:int = 0;
		//public var ayS:int = 0;
		//public var multipleAnimeShip:Object = {};
		//public var framesTypesShip:Array = [];
		//private var texturesShip:Object;
		//private function onLoadShip(obj:Object):void 
		//{
			//texturesShip = obj;
			//
			//initAnimation();
			//startAnimation();
			//
			//ship.addChild(shipAnim);
			//shipAnim.visible = false;
			//
			//var shipBtm:Bitmap = new Bitmap(obj.sprites[0].bmp);
			//shipBtm.smoothing = true;
			//ship.addChild(shipBtm);
			//shipBtm.y = -ship.height/2 + 6;
			//shipBtm.x = -148;
			//
			//App.map.mUnits.addChild(ship);
			//ship.x = this.x + 200;
			//ship.y = this.y + 130;
			//
			//if (mode == MODE_BUSY) {
				//ship.alpha = 0;
			//}
		//}
		
		//override public function initAnimation():void {
			//framesTypesShip = [];
			//if (texturesShip && texturesShip.hasOwnProperty('animation')) {
				//for (var frameType2:String in texturesShip.animation.animations) {
					//framesTypesShip.push(frameType2);
				//}
				//addAnimation()
				//animate();
			//}
		//}
		
		//override public function addAnimation():void
		//{
			//if (texturesShip == null) return;
			//
			//axS = texturesShip.animation.ax;
			//ayS = texturesShip.animation.ay;
			//
			//clearAnimation();
			//
			//var arrSorted:Array = [];
			//for each(var nm2:String in framesTypesShip) {
				//arrSorted.push(nm2); 
			//}
			//arrSorted.sort();
			//
			//for (var i:int = 0; i < arrSorted.length; i++ ) {
				//name = arrSorted[i];
				//multipleAnimeShip[name] = { bitmap:new Bitmap(), cadr: -1 };
				//shipAnim.addChild(multipleAnimeShip[name].bitmap);
				//
				//if (texturesShip.animation.animations[name]['unvisible'] != undefined && texturesShip.animation.animations[name]['unvisible'] == true) {
					//multipleAnimeShip[name].bitmap.visible = false;
				//}
				//multipleAnimeShip[name]['length'] = texturesShip.animation.animations[name].chain.length;
				//multipleAnimeShip[name]['frame'] = 0;
			//}
		//}
		
		//override public function clearAnimation():void {
			//stopAnimation();
			//
			//for (var _name2:String in multipleAnimeShip) {
				//shipAnim.removeChild(multipleAnimeShip[_name2].bitmap);
			//}
		//}
		
		//override public function animate(e:Event = null):void
		//{
			//if (!SystemPanel.animate) return;
			//
			//for each(name in framesTypesShip) {
				//var frame:* 			= multipleAnimeShip[name].frame;
				//var cadr:uint 			= texturesShip.animation.animations[name].chain[frame];
				//if (multipleAnimeShip[name].cadr != cadr) {
					//multipleAnimeShip[name].cadr = cadr;
					//var frameObject:Object 	= texturesShip.animation.animations[name].frames[cadr];
					//
					//multipleAnimeShip[name].bitmap.bitmapData = frameObject.bmd;
					//multipleAnimeShip[name].bitmap.smoothing = true;
					//multipleAnimeShip[name].bitmap.x = frameObject.ox+axS;
					//multipleAnimeShip[name].bitmap.y = frameObject.oy+ayS;
				//}
				//multipleAnimeShip[name].frame++;
				//if (multipleAnimeShip[name].frame >= multipleAnimeShip[name].length)
				//{
					//multipleAnimeShip[name].frame = 0;
				//}
			//}
		//}
		
		override public function addEffect(type:String):void 
		{
			var layer:int = 0;
			if (type == BUILD) {
				var effect:AnimationItem = new AnimationItem( { type:'Effects', view:type, params:AnimationItem.getParams(type, info.view) } );
				effect.blendMode = BlendMode.HARDLIGHT;
				layer = 1;
			}else if (type == BOOST) {
				effect = new AnimationItem( { type:'Effects', view:type, params:AnimationItem.getParams(type, info.view) } );
			}
			addChildAt(effect, layer);
			var pos:Object = IsoConvert.isoToScreen(int(cells / 2), int(rows / 2), true, true);
			effect.x = pos.x + 60;
			effect.y = pos.y - 5;
		}
		
		//private var tween1:TweenLite;
		//private var tween2:TweenLite;
		
		private var tweens:Object = { 
			1: { },
			2: { },
			3: { }
		};
		
		private var intervalAnimShow:int;
		public function moveShip(boatId:int, isBack:Boolean = false):void
		{
			clearTweens(boatId);
			if (boats.length > 0)
			{
				var currBoat:TradeBoat = boats[boatId-1];
				
				if (isBack) {
					
					currBoat.alpha = 0;
					
					currBoat.x = this.x + boatsCoords[boatId].x;
					currBoat.y = this.y + boatsCoords[boatId].y;
					
					var that:Tradeshop = this;
					tweens[boatId]['3'] = TweenLite.to(currBoat, 1, { alpha:1 } );
				}else {
					
					currBoat.start();
					currBoat.typeMove = TradeBoat.STRAIGHT;
					
					currBoat.alpha = 1;
					
					currBoat.x = this.x + boatsCoords[boatId].x;
					currBoat.y = this.y + boatsCoords[boatId].y;
					tweens[boatId]['1'] = TweenLite.to(currBoat, 4, { x:currBoat.x + 340, y:currBoat.y + 400, ease:Linear.easeNone, onComplete:function():void {
						tweens[boatId]['2'] = TweenLite.to(currBoat, 2, { x:currBoat.x + 60, y:currBoat.y + 60, alpha:0, onComplete:function():void {
							currBoat.alpha = 0;
							currBoat.stop();
							currBoat.typeMove = TradeBoat.DEFAULT;
						}});
					} } );
				}
			}
		}
		
		private function clearTweens(ind:int, all:Boolean = false):void
		{
			if (all) {
				for each(var tw:* in tweens) {
					if (tw[1])
						tw[1].complete();
					tw[1] = null;
					if (tw[2])
						tw[2].complete();
					tw[2] = null;
					if (tw[3])
						tw[3].complete();
					tw[3] = null;
				}
				return;
			}
			
			for (var i:int = 1; i < 4; i++) 
			{
				if (tweens[ind] && tweens[ind][i]) {
					tweens[ind][i].complete();
					tweens[ind][i] = null;
				}
			}
			
			
			//if (tween1) {
				//tween1.complete();
				//tween1 = null;
			//}
			//
			//if (tween2) {
				//tween2.complete();
				//tween2 = null;
			//}
		}
		
		private var intervalUpdate:int;
		public var canUpdate:Boolean = true;
		private var isClicked:Boolean = false;
		private function setUsersData():void 
		{
			Post.send({
				ctr:this.type,
				act:'check',
				uID:App.user.id,
				wID:App.user.worldID
			}, onUsersDataComplete);	
			
			//if (canUpdate) {
				//canUpdate = false;
				//
				//intervalUpdate = setInterval(function():void { clearInterval(intervalUpdate); canUpdate = true }, 30000);
				//
				//isClicked = true;
				//
				//Post.send({
					//'ctr':this.type,
					//'act':'users',
					//'uID':App.user.id,
					//'sID':sid
				//}, onUsersDataComplete);
			//}else {
				//openWindow();
			//}
		}
		
		private function onUsersDataComplete(error:int, data:Object, params:Object):void 
		{
			if (error){
				Errors.show(error, data);
				return;
			}
			
			if (data.hasOwnProperty('ships')) {
				ships = data.ships;
				App.user.tradeshop = ships;
				openWindow();
			}else {
				new SimpleWindow({title:info.title,text:Locale.__e('flash:1415625677392')}).show();
			}
			
			//App.user.tradeshop.items = data.items;
			
			//dataUsers = data.users;
			
		}
		
		private function openWindow():void
		{
			isClicked = false;
			
			//if(mode == MODE_DONE){
				//new PortOrderWindow(PortOrderWindow.MODE_DONE, {target:this, started:startedTrade}).show();
			//}else {
				new PortWindow(/*mode, */{
					target:this,
					onSell:onSell
					}).show();
				return;
			//}
		}
		
		//private function working():void 
		//{
			//var time:int = startedTrade + App.data.storage[sid].time * 3600 - App.time;
			//
			//if (time <= 0) {
				//App.self.setOffTimer(working);
				//setBonusIcon();
				//moveShip(true);
			//}
		//}
		
		override public function click():Boolean 
		{	
			if (App.user.view)
				return true;
			
			if (isClicked && level == totalLevels) 
				return true;
			
			super.click();
			return true;
		}
		
		override public function openConstructWindow():Boolean 
		{
			if (level < totalLevels || level == 0)
			{
				if (App.user.mode == User.OWNER)
				{
					if (hasUpgraded)
					{
						new ConstructWindow( {
							title:			info.title,
							upgTime:		info.devel.req[level + 1].t,
							request:		info.devel.obj[level + 1],
							target:			this,
							win:			this,
							onUpgrade:		upgradeEvent,
							hasDescription:	true
						}).show();
						
						return true;
					}
				}
			}
			return false;
		}
		
		override public function onBonusEvent(error:int, data:Object, params:Object):void 
		{
			super.onBonusEvent(error, data, params);
			isClicked = false;
		}
		
		override public function openProductionWindow():void
		{
			if (level >=  totalLevels)
			{
				setUsersData();
				return;
			}
			
			isClicked = false;
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
		
		public function onSell(shipId:int, data:Array):void 
		{
			var objItems:Object = { };
			
			for (var i:int = 0; i < data.length; i++ ) {
				if(objItems[data[i].sid])
					objItems[data[i].sid] += data[i].count;
				else	
					objItems[data[i].sid] = data[i].count;
			}
			
			if (!App.user.stock.takeAll(objItems)) return;
			
			Post.send({
				'ctr':'tradeshop',
				'act':'start',
				'uID':App.user.id,
				'sID':sid,
				'wID':App.user.worldID,
				'items':JSON.stringify(data),
				'photo':App.user.photo,
				'ship':shipId,
				'level':App.user.level
			}, onSellComplete, {shipId:shipId});
		}
		
		private function onSellComplete(error:int, data:Object, params:Object):void 
		{
			if (error){
				Errors.show(error, data);
				return;
			}else {
				//mode = MODE_BUSY;
				startedTrade = data.start;
				//App.self.setOnTimer(working);
				App.user.tradeshop[params.shipId] = data;
				
				checkShip(params.shipId);
				
			}
		}
		
		public function onBoost(shipId:int, callBack:Function):void
		{
			Post.send({
				'ctr':'tradeshop',
				'act':'boost',
				'uID':App.user.id,
				'sID':this.sid,
				'ship':shipId,
				'wID':App.user.worldID
			}, onBoostComplete, {shipId:shipId, callBack:callBack});
		}
		
		private function onBoostComplete(error:int, data:Object, params:Object):void 
		{
			if (error){
				Errors.show(error, data);
				return;
			}else {
				
				var minusFant:int = App.user.stock.count(Stock.FANT) - data['5'];
				var price:Object = { }
				price[Stock.FANT] = minusFant;
				
				if (!App.user.stock.takeAll(price))	return;
				
				App.user.tradeshop[params.shipId].start = App.time - App.data.storage[sid].time * 3600 - 10;
				checkShip(params.shipId);
				
				params.callBack();
			}
		}
		
		public function onTake(shipInd:int, dataItems:Object, callBack:Function):void
		{	
			for each(var _item:* in dataItems) {
				
				if (_item.sold)
					continue;
				
				var dataIt:Object = { };
				dataIt[_item.sid] = _item.count;
			}
			
			Post.send({
				ctr:type,
				act:'storage',
				uID:App.user.id,
				sID:sid,
				wID:App.user.worldID,
				ship:shipInd
			}, onTakeEvent, {shipInd:shipInd, callBack:callBack});		
		}
		
		private function onTakeEvent(error:int, data:Object, params:Object):void 
		{
			if (error)
			{
				Errors.show(error, data);
				return;
			}
			
			
			var that:* = this;
			spit(function():void{
				Treasures.bonus(Treasures.convert(data.items), new Point(that.x, that.y));
			}, bitmapContainer);
			
			setFree(params.shipInd);
			
			params.callBack();
		}
		
		public function buyShip(shipInd:int, callBack:Function):void
		{
			if (!App.user.stock.take(Stock.FANT, info.devel.obj[level + 1][Stock.FANT])) return;
			
			Post.send({
				ctr:this.type,
				act:'up',
				uID:App.user.id,
				sID:sid,
				wID:App.user.worldID,
				id:id
			}, onBuyShip, {callBack:callBack});
		}
		
		private function onBuyShip(error:int, data:Object, params:Object):void 
		{
			if (error)
			{
				Errors.show(error, data);
				return;
			}
			
			this.level = data.level;
			
			adBoat();
			
			params.callBack();
		}
		
		public function setFree(shipInd:int):void
		{
			//App.self.setOffTimer(working);
			
			delete App.user.tradeshop[shipInd];
			
		}
		
		public function setBonusIcon():void
		{
			//
		}
		
		private function openSaleWindow():void 
		{
			new PortWindow(/*mode, */{
				target:this,
				onSell:onSell
			}).show();
			return;
		}
		
		override public function uninstall():void 
		{	 
			clearTweens(0, true);
			clearInterval(intervalUpdate);
			
			super.uninstall();
		}
	}

}