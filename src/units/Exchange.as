package units 
{
	import com.greensock.TweenLite;
	import core.Numbers;
	import core.Post;
	import flash.display.Bitmap;
	import flash.geom.Point;
	import wins.ConstructWindow;
	import wins.ExchangeWindow;
	import wins.Window;
	
	public class Exchange extends Barter 
	{
		
		public static var take:int = 0;
		public static var rate:int = 0;
		public static var rates:Object = { };
		
		public var top:int;
		public var currency:int = 0;
		public var expire:int = 1443110400;
		
		public function Exchange(object:Object) 
		{
			super(object);
			
			//if (App.isSocial('FB', 'HV', 'NK'))
				//expire = info.expire[App.social];
			if (sid == 797)
				level = 1;
			
			currency =  info['in'] || 0;
			
			if (object.hasOwnProperty('take'))
				Exchange.take = object.take;
			
			removable = false;
			
			// Определение топа
			for (var topID:* in App.data.top) {
				var storageTop:Object = App.data.top[topID];
				if (storageTop.unit == sid && storageTop.expire.e > App.time) {
					expire = storageTop.expire.e;
					top = topID;
				}
			}
			
			if (top == 0) {
				for (var tpID:* in App.data.top) {
					if (App.data.top[tpID].unit == sid) {
						if (tpID > top) {
							expire = App.data.top[tpID].expire.e;
							top = tpID;
						}
					}
				}
			}
			//top = 10;
		}
		
		override public function click():Boolean {			
			if (App.user.mode == User.GUEST) {
				guestClick();
				return true;
			}
			
			openProductionWindow();
			
			return true;
		}
		
		override public function openProductionWindow(settings:Object = null):void {
			new ExchangeWindow( {
				onExchange:onExchange,
				target:this,
				find:0,
				top:top
			}).show();
		}
		
		override public function openConstructWindow():Boolean {
			
			if ((craftLevels == 0 && level < totalLevels) || (craftLevels > 0 && level < totalLevels - craftLevels + 1))
			{
				if (App.user.mode == User.OWNER)
				{
					if (hasUpgraded)
					{
						new ConstructWindow( {
							title:			info.title,
							upgTime:		info.devel.req[level + 1].t,
							request:		info.devel.obj[level + 1],
							reward:			info.devel.reward[level + 1],
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
		
		override public function onExchange(bID:int, callback:Function = null):void {
			
			var barter:Object = App.data.barter[bID];
			if (!barter) return;
			
			if (!App.user.stock.takeAll(barter.out)) return;
			
			Post.send({
				ctr:type,
				act:'exchange',
				uID:App.user.id,
				sID:this.sid,
				id:id,
				bID:bID,
				wID:App.map.id
			}, function(error:int, data:Object, params:Object):void {
				if (error) {
					Errors.show(error, data);
					return;
				}	
				
				App.user.stock.addAll(barter.items);
				
				if (callback != null) callback();
			});
		}
		
		public function onChange(iID:int, callback:Function = null):void {
			if (!info.devel.exchange[level][iID]) return;
			
			var change:Object = info.devel.exchange[level][iID];
			
			if (!App.user.stock.take(currency, change.price)) return;
			
			Post.send({
				ctr:type,
				act:'change',
				uID:App.user.id,
				sID:this.sid,
				id:id,
				iID:iID,
				wID:App.map.id
			}, function(error:int, data:Object, params:Object):void {
				if (error) {
					Errors.show(error, data);
					return;
				}
				
				
				
				if (data.hasOwnProperty('bonus'))
					App.user.stock.addAll(data.bonus);
				
				App.ui.upPanel.update();
				
				if (callback != null) callback();
			});
		}
		
		public function onTakeBonus():void {
			var that:* = this;
			
			Post.send( {
				ctr:'Top',
				act:'tbonus',
				tID:top,
				uID:App.user.id
			},function(error:int, data:Object, params:Object):void {
				if (error) {
					Errors.show(error, data);
					return;
				}	
				
				Window.closeAll();
				
				Exchange.take = 1;
				
				if (data.hasOwnProperty("bonus")) {
					Treasures.bonus(data.bonus, new Point(that.x, that.y));
				}
			});
		}
		
		private var usedStage:int = 0;
		override public function updateLevel(checkRotate:Boolean = false, mode:int = -1):void 
		{
			if (textures == null) return;
			
			var levelData:Object;
			if (this.level && info.devel && info.devel.req.hasOwnProperty(this.level) && info.devel.req[this.level].hasOwnProperty("s") && textures.sprites[info.devel.req[this.level].s]) {
				usedStage = info.devel.req[this.level].s;
			}else if (textures.sprites[this.level]) {
				usedStage = this.level;
			}
			
			levelData = textures.sprites[usedStage];
			
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
				
				App.ui.flashGlowing(this, 0xFFF000);
				
				TweenLite.to(bitmap, 0.4, { alpha:1, onComplete:function():void {
					removeChild(backBitmap);
					backBitmap = null;
				}});
				
				gloweble = false;
			}
			
			if (levelData) draw(levelData.bmp, levelData.dx, levelData.dy);
			
			checkOnAnimationInit();
		}
		
		override public function checkOnAnimationInit():void {			
			if (textures && textures['animation']) {
				initAnimation();
				
				if (level == totalLevels) startAnimation();
			}
		}
		
		override public function remove(_callback:Function = null):void {
			if ([797].indexOf(int(sid)) != -1) {
				var data:int = int(App.user.storageRead('building_' + sid, 0));
				if (data > 0) data -= 1;
				App.user.storageStore('building_' + sid, data, true);
			}
			
			super.remove(_callback);
		}
	}

}