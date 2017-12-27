package units 
{
	import com.greensock.TweenLite;
	import core.Load;
	import core.Post;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.geom.Point;
	import ui.Hints;
	import ui.UserInterface;
	import wins.ConstructWindow;
	import wins.ErrorWindow;
	import wins.ShopWindow;
	import wins.SpeedWindow;
	import wins.StockWindow;
	import wins.TributeWindow;
	import wins.Window;

	import com.demonsters.debugger.MonsterDebugger;
	/**
	 * ...
	 * @author ...
	 */
	public class Mining extends Tribute
	{
		public var _capacity:uint;
		
		private var _isWork:Boolean = false;
		private var _hasBuildBonus:Boolean = false;
		private var _isBoost:Boolean = false;
		
		private var _created:int = 0;
		private var _timeBuildItem:int;
		public var _boostStarted:int;
		private var _itemsPerTime:int;
		private var _itemsKoef:int;
		
		
		public function Mining(object:Object) 
		{
			super(object);
			
			removable = true;
			
			setParams(level);
			
			started = object.started;
			
			if(level > 0)
				setParams(level);
					
				
			if (level > totalLevels - craftLevels && isBuilded() && isUpgrade() && started > 0 && !hasProduct) {
				_isWork = true;
				beforeWork();
				_leftTime = _timeBuildItem;
				App.self.setOnTimer(work);
			}
			
			_boostStarted = object.boost;
			_itemsKoef = info.count;
			
			if (started != 0) {
				if (checkBoost()) {
					
					var interval:int = (_boostStarted - info.time) - started;
					
					if (interval > 0) {
						_created = Math.floor(((_boostStarted - info.time) - started) / _timeBuildItem) * _itemsPerTime;
						var boostItems:int = Math.floor((App.time - (_boostStarted - info.time)) / _timeBuildItem) * _itemsPerTime * _itemsKoef;
						_leftTime = Math.ceil(_timeBuildItem - (App.time - (_boostStarted - info.time)) /  boostItems);
						_created += boostItems;
						
					}else {
						_created = Math.floor((App.time - started) / _timeBuildItem) * _itemsPerTime * _itemsKoef;
						_leftTime = Math.ceil(_timeBuildItem - (App.time - _created / _itemsPerTime * _timeBuildItem - started));
					}
					_itemsPerTime *= _itemsKoef;
					
				}else {
					_created = Math.floor((App.time - started) / _timeBuildItem) * _itemsPerTime;
					_leftTime = Math.ceil(_timeBuildItem -  (App.time - _created / _itemsPerTime * _timeBuildItem - started));
				}
				
				//_created = App.user.stock.boosted(Stock.FANTASY, _created);
			}
			
			if (_created > _capacity) _created = _capacity;
			
			if (formed && _created > 0 && !hasPresent && hasUpgraded) {
				checkIcon();
			}
			if (!hasUpgraded)_created = 0;
			MonsterDebugger.trace(info.title + Locale.__e('flash:1411740981919'),Locale);
			tip = function():Object 
			{
				if (created > 0 && !hasBuilded) {
					
					return {
						title:info.title,
						text:Locale.__e('flash:1395412587100') + '\n' + TimeConverter.timeToStr(created - App.time),
						timer:true
					}
				}else if (upgradedTime > 0 && !hasUpgraded) {
					
					return {
						title:info.title,
						text:Locale.__e('flash:1395412562823') + '\n' + TimeConverter.timeToStr(upgradedTime-App.time),
						timer:true
					}
				}
				
				var times:Number = _itemsPerTime;
				if (times < 0 || times == Infinity) times = 0;
				var format:String = String(times);
				if (App.lang == 'ru')
					format = Locale.__e('flash:1411740679937', [times]);
				
				return {
					title:info.title,
					text:_created +'/' + _capacity,
					timer:true
				};
				
			}
			
			touchableInGuest = true;
			App.self.addEventListener(AppEvent.ON_CHANGE_FANTASY, checkIcon);
			App.self.addEventListener(AppEvent.ON_CHANGE_STOCK, checkIcon);
		}
		
		override protected function onStockAction(error:int, data:Object, params:Object):void {
			super.onStockAction(error, data, params);
			//setFlag("constructing", isPresent, { target:this, roundBg:false, addGlow:false } );
			hasUpgraded = true;
		}
		
		private function checkIcon(e:AppEvent = null):void 
		{
			showIcon();
		}
		
		private function setParams(lvl:int):void
		{
			if (info.devel.req.hasOwnProperty(lvl)) {
				capacity = info.devel.req[lvl].c;
				_timeBuildItem = info.devel.req[lvl].tm;
				_itemsPerTime = info.devel.req[lvl].cm;
			}
		}
		
		override public function updateLevel(checkRotate:Boolean = false, mode:int = -1):void 
		{
			if (textures == null) return;
			
			if (level == 0) {
				Load.loading(Config.getSwf(type, info.devel.req[1].v), onGraphicsLoad);
			}else {
				Load.loading(Config.getSwf(type, info.devel.req[level].v), onGraphicsLoad);
			}
			
			setParams(level);
		}
		
		private function onGraphicsLoad(data:*):void 
		{
			textures = data;
			updateGraphics();
		}
		
		private function updateGraphics():void{
						
			if (textures.sprites[level] == null)
				textures.sprites[level] = textures.sprites[0];
			
			var levelData:Object = textures.sprites[level];
			
			/*if (checkRotate && rotate == true) {
				flip();
			}*/
			
			if (this.level == 1 && gloweble)
			{
				var backBitmap:Bitmap = new Bitmap(bitmap.bitmapData);
				backBitmap.x = bitmap.x;
				backBitmap.y = bitmap.y;
				addChildAt(backBitmap, 0);
				
				bitmap.alpha = 0;
				
				App.ui.flashGlowing(this, 0x6fefff);
				
				TweenLite.to(bitmap, 2, { alpha:1, onComplete:function():void {
					removeChild(backBitmap);
					backBitmap = null;
				}});
				
				gloweble = false;
			}
			draw(levelData.bmp, levelData.dx, levelData.dy);
			onGraphicsUpdated();
		}
		
		private function onGraphicsUpdated():void 
		{
			if (level > 0 ) {
				initAnimation();
				beginAnimation();
			}
			if (_created >= _capacity || hasPresent || !hasUpgraded) {
				finishAnimation();
			}
		}
		
		public function checkBoost():Boolean
		{
			if (_boostStarted > App.time) {
				_isBoost = true;
				return true;
			}
			return false;
		}
		
		override public function init():void 
		{
			started = 1;
			
			if (level == totalLevels){
				touchableInGuest = true;
			}
			
			//Load.loading(Config.getImage('Material', App.data.storage[Stock.COINS].view), onOutLoad);
		}
		
		override public function click():Boolean 
		{
			if (App.user.mode == User.GUEST) {
				guestClick();
				return true;
			}
			
			if (isPresent()) return true;
			
			if (level <= totalLevels - craftLevels)
			{
				if (App.user.mode == User.OWNER)
				{
					if (hasUpgraded)
					{
						// Открываем окно постройки
						new ConstructWindow( {
						title:			info.title,
						upgTime:		info.devel.req[level + 1].t,
						request:		info.devel.obj[level + 1],
						target:			this,
						win:			this,
						onUpgrade:		upgradeEvent,
						hasDescription:	true,
						notChecks:true
						}).show();
						
						return true;
					}
					
				}
			}			
			
			/*haloEffect();
			return false;
			*/
			if (!clickable || id == 0 || (App.user.mode == User.GUEST && touchableInGuest == false)) return false;
			
			var finishTime:int = -1;
			var totalTime:int = -1;
			if (created > 0 && !hasBuilded){ // еще строится
				var curLevel:int = level + 1;
				if (curLevel >= totalLevels) curLevel = totalLevels;
				finishTime = created;
				totalTime = App.data.storage[sid].devel.req[1].t;
			}else if (upgradedTime >0 && !hasUpgraded) { // еще апгрeйдится
				finishTime = upgradedTime;
				totalTime = App.data.storage[sid].devel.req[level+1].t;
			}	
				
			if(finishTime >0){
				new SpeedWindow( {
					title:info.title,
					target:this,
					info:info,
					finishTime:finishTime,
					totalTime:totalTime
				}).show();
				return false;	
			}		
			
			App.tips.hide();
			
			if (hasPresent) {
				hasPresent = false;
				_leftTime = _timeBuildItem;
				
				var sendObject:Object = {
					ctr:this.type,
					act:'reward',
					uID:App.user.id,
					id:this.id,
					wID:App.user.worldID,
					sID:this.sid
				}
				
				if (App.user.quests.tutorial) {
					started = App.time - 60;
					sendObject['time'] = App.time - 60;
				}
				Post.send(sendObject, onBonusEvent);
				
			}else {
				new TributeWindow({
					title:info.title,
					target:this,
					started:started,
					info:info,
					time:_timeBuildItem,
					full:isFull(),
					itemsPerTime:_itemsPerTime,
					capasity:_capacity,
					leftTime:_leftTime,
					created:_created,
					boost:checkBoost()
				}).show();
			}
			
			return true;
		}
		
		private function isFull():Boolean
		{
			if (_created >= _capacity) return true;
			return false;
		}
		
		override public function onBonusEvent(error:int, data:Object, params:Object):void
		{
			if (error)
			{
				Errors.show(error, data);
				return;
			}
			removeEffect();
			setParams(level);
			//flag = false;
			
			//started = App.time;
			
			Treasures.bonus(Treasures.convert(info.devel.rew[level]), new Point(this.x, this.y));
			
			if (App.user.quests.tutorial) {
				_created = Math.floor((App.time - started) / _timeBuildItem) * _itemsPerTime;
				_leftTime = _timeBuildItem -  (App.time - _created / _itemsPerTime * _timeBuildItem - started);
			}
			else {
				_leftTime = _timeBuildItem;
				_created = 0;
				started = App.time;
			}
			
			_isWork = true;
			beforeWork();
			removeEffect();
			
			/*if(!isPhase())
				App.self.setOnTimer(work);*/
		}
		
		private var isClodTake:Boolean = false;
		private function takeEfir():void 
		{
			isClodTake = false;
			efirEvent();
		}
		
		private function takeEfirCloud(value:int = 0):void
		{
			isClodTake = true;
			efirEvent();
		}
		
		public function efirEvent():void
		{
			if (App.user.mode == User.OWNER) {
				
				var canAddedToStock:int;
				
				switch(info.out) {
					case Stock.FANTASY:
						canAddedToStock = App.user.stock.count(Stock.FANTASY);
					break;
					case Stock.COINS:
						canAddedToStock = _created;
					break;
					default:
						canAddedToStock = 0;
				}
				
				if (App.user.quests.tutorial)
					canAddedToStock = 100;
					
				//var canAddedToStock:int = Stock.efirLimit - App.user.stock.count(Stock.FANTASY);
				if (canAddedToStock <= 0) {
					if(!isClodTake){
						new TributeWindow({
							title:info.title,
							target:this,
							started:started,
							info:info,
							time:_timeBuildItem,
							full:isFull(),
							itemsPerTime:_itemsPerTime,
							capasity:_capacity,
							leftTime:_leftTime,
							created:_created,
							boost:checkBoost(),
							notChecks:true
						}).show();
					}else{
						var winSettings:Object = {
							title				:Locale.__e('flash:1396250443959'),
							text				:Locale.__e('flash:1396250585579'),
							buttonText			:Locale.__e('flash:1393577477211'),
							hasStorageBtn		:true,
							storageBtnText		:Locale.__e('flash:1393580216438'),
							//image				:UserInterface.textures.alert_storage,
							image				:Window.textures.errorStorage,
							imageX				:-78,
							imageY				: -76,
							textPaddingY        : -18,
							textPaddingX        : -10,
							hasExit             :true,
							faderAsClose        :true,
							faderClickable      :true,
							closeAfterOk        :true,
							forcedClosing       :true,
							bttnPaddingY        :25,
							ok					:function():void {
								new ShopWindow( { find:[Storehouse.STOREHOUSE_1], forcedClosing:true } ).show();
							},
							onStorage					:function():void {}
						};
						
						if (info.out == Stock.FANTASY) {
							new ErrorWindow(winSettings).show();
						}else {
							winSettings['text'] = Locale.__e('flash:1399371326756');
							winSettings['buttonText'] = Locale.__e('');
							winSettings['ok'] = function():void { new StockWindow().show();};
							new ErrorWindow(winSettings).show();
						}
					}
					
					return;
				}
				var taken:int = Math.ceil(_created);
				if (_created > canAddedToStock)
					taken = canAddedToStock;
				
				if (_created > _capacity)_created = _capacity;
				
				var left:int = _created - taken;
				var time:int = info.devel.req[level].tm * int((left / _itemsPerTime));
				var newStarted:uint = App.time - time;
				
				
				var that:Mining = this;
				
				Post.send({
					ctr:this.type,
					act:'storage',
					uID:App.user.id,
					id:this.id,
					wID:App.user.worldID,
					sID:this.sid,
					time:newStarted,
					count:taken
				}, function(error:int, data:Object, params:Object):void {
					if (error)
					{
						Errors.show(error, data);
						return;
					}
					
					var typeOut:int = info.out;
					var out:Object = { };
						out[info.out] = data.count; 
						
					Treasures.bonus(Treasures.convert(out), new Point(that.x, that.y));
					//haloEffect();
					
					if (left > _capacity) {
						left = _capacity - data.count;
					}
					
					_created = left;
					
					started = newStarted;
					_leftTime = _timeBuildItem;
					
					if(textures)finishAnimation();
					App.self.setOffTimer(work);
					
					beforeWork();
					App.self.setOnTimer(work);
					
				});
			}
		}
		
		private function showShop():void 
		{
			new ShopWindow( { find:[Storehouse.STOREHOUSE_1], forcedClosing:true } ).show();
		}
		
		private function beforeWork():void
		{
			if (textures && level > totalLevels - craftLevels) beginAnimation();
		}
		
		private var _leftTime:int;
		override public function work():void
		{
			if (!hasUpgraded || hasPresent) return;
			
			_leftTime --;//= _timeBuildItem - (App.time - started - _created/_itemsPerTime * _timeBuildItem);
			if (_leftTime <= 0) {
				_created += _itemsPerTime;
				_leftTime = _timeBuildItem;
			}
			
			if (_created >= _capacity) {
				_created = _capacity;
				if (textures) finishAnimation();
				_leftTime = _timeBuildItem;
				App.self.setOffTimer(work);
				
				return;
			}
			
			if (_isBoost && !checkBoost()) {
				_isBoost = false;
				_itemsPerTime = info.devel.req[level].cm;
				removeEffect();
			}
		}
		
		public function boostEvent():void
		{
			Post.send({
					ctr:this.type,
					act:'boost',
					uID:App.user.id,
					id:this.id,
					wID:App.user.worldID,
					sID:this.sid
				}, onBoostedEvent);
		}
		
		private function onBoostedEvent(error:int, data:Object, params:Object):void 
		{
			if (error)
			{
				Errors.show(error, data);
				return;
			}
			
			var price:Object = { }
			price[Stock.FANT] = info.boost;
			
			if (!App.user.stock.takeAll(price))	return;
			
			Hints.minus(Stock.FANT, info.boost, new Point(this.x * App.map.scaleX + App.map.x, this.y * App.map.scaleY + App.map.y), true);
			_boostStarted = data.boost;
			_isBoost = true;
			_itemsPerTime *= _itemsKoef;
			
			//addEffect(Building.BOOST);
		}
		
		override public function onUpgradeEvent(error:int, data:Object, params:Object):void 
		{
			if (error){
				Errors.show(error, data);
				return;
			}else {
				finishAnimation();
				App.self.setOffTimer(work);
				//addProgressBar();
				addEffect(Building.BUILD);
				
				super.onUpgradeEvent(error, data, params);
			}
		}
		
		public override function onStorageEvent(error:int, data:Object, params:Object):void 
		{
			if(data.hasOwnProperty('started')){
				beforeWork();
			}
			
			_leftTime = _timeBuildItem;
			_created = 0;
			started = App.time;
			
			super.onStorageEvent(error, data, params);
		}
		
		public function set capacity(value:uint):void 
		{
			_capacity = value;
		}
		
		public function get capacity():uint 
		{
			return _capacity;
		}
		
		override public function uninstall():void {
			super.uninstall();
		}
		
		override public function onRemoveFromStage(e:Event):void {
			super.onRemoveFromStage(e);
			
			App.self.removeEventListener(AppEvent.ON_CHANGE_FANTASY, checkIcon);
			App.self.removeEventListener(AppEvent.ON_CHANGE_STOCK, checkIcon);
		}
		
		override public function onBuildComplete():void {
			//
		}
		
		override public function setCraftLevels():void
		{
			
			for each(var obj:* in info.devel.req) {
				if(obj.c > 0)
					craftLevels++;
			}
			
		}
	}
}