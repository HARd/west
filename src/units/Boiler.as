package units
{
	import api.ExternalApi;
	import core.Load;
	import core.Post;
	import flash.display.Bitmap;
	import flash.geom.Point;
	import ui.Hints;
	import wins.RecipeWindow;
	import wins.RepairWindow;
	import wins.SimpleWindow;
	import wins.TributeWindow;
	
	public class Boiler extends Building
	{
		public static const FREE:uint 		= 0; 
		public static const BUSY:uint 		= 1; 
		public static const DAMAGED:uint 	= 2; 
		
		public var old:int = 0;
		public var additionalBitmap:Bitmap;
		
		public function Boiler(object:Object) 
		{	
			additionalBitmap = new Bitmap();
			additionalBitmap.visible = false;
			
			super(object);
			touchableInGuest = false;
			
			
			if (object.hasOwnProperty('old'))
			{
				old = object.old;
				if (old >= info.limit) 
				{
					level = DAMAGED;
					flag = "needRepair";
					if(textures) updateLevel(true);
				}
			}	
			
			addChild(additionalBitmap);
			setCloudPosition(20, -50);
		}
		
		override public function onAfterBuy(e:AppEvent):void
		{
			removeEventListener(AppEvent.AFTER_BUY, onAfterBuy);
						
			App.user.stock.add(Stock.EXP, App.data.storage[sid].experience);
			Hints.plus(Stock.EXP, App.data.storage[sid].experience, new Point(this.x + App.map.x, this.y + App.map.y), true);
			
			App.ui.flashGlowing(this);
			
			new SimpleWindow( {
				title:info.title,
				label:SimpleWindow.BUILDING,
				text:Locale.__e("flash:1382952379883"),
				sID:sid,
				ok:makePost
			}).show();
			
			//Делаем push в _6e
			//if (App.social == 'FB') {						
				//ExternalApi._6epush([ "_event", { "event": "gain", "item": info.view } ]);
			//}
		}
		
		override public function updateLevel(checkRotate:Boolean = false):void
		{
			var levelData:Object = textures.sprites[this.level];
			
			if (checkRotate && rotate == true) {
				flip();
			}
			
			draw(levelData.bmp, levelData.dx, levelData.dy);
			
			addAnimation();
			framesType = 'cook';
			if (crafting) {
				startAnimation();
				animationBitmap.visible = true;
				additionalBitmap.visible = false;
			}else {
				stopAnimation();
				animationBitmap.visible = false;
				additionalBitmap.visible = true;
			}
		}
		
		override public function click():Boolean{
			if (!clickable || (App.user.mode == User.GUEST && touchableInGuest == false)) return false;
			
			App.tips.hide();
			
			if (hasProduct)
			{
				/*var price:Object = { };
				price[Stock.FANTASY] = 1;*/
							
				//if (!App.user.stock.checkAll(price))	return false;
				
				// Отправляем персонажа на сбор
				App.user.hero.addTarget( {
					target		:this,
					callback	:storageEvent,
					event		:Personage.HARVEST,
					jobPosition	:findJobPosition()
				});
				
				ordered = true;
			}
			else
			{
				if (crafting)
				{
					new TributeWindow( {
						title:info.title,
						target:this,
						started:crafted,
						time:formula.time
					}).show();
				}
				else
				{
					if (old >= info.limit)
					{
						new RepairWindow({
							title:Locale.__e("flash:1382952379886"),
							price:info.price,
							onRepair:repairEvent,
							popup:true
						}).show();
						return false;		
					}			
						
					new RecipeWindow( {
						title:Locale.__e("flash:1382952380065")+':',
						fID:info.crafting[0],
						onCook:onCraftAction,
						busy:level
					}).show();
				}
			}
			return true;
		}
		
		override public function storageEvent(value:int = 0):void
		{
			Post.send({
				ctr:this.type,
				act:'storage',
				uID:App.user.id,
				id:this.id,
				wID:App.user.worldID,
				sID:this.sid,
				fID:fID
			}, onStorageEvent);
		}
		
		public override function onStorageEvent(error:int, data:Object, params:Object):void {
			
			old = data.old;
			delete data['old'];
				
			if (old >= info.limit)
			{
				new RepairWindow({
					title			:Locale.__e("flash:1382952379886"),
					price			:info.price,
					onRepair		:repairEvent,
					popup			:false,
					forcedClosing	:true
				}).show();
					
				level = DAMAGED;	
				updateLevel(true);
			}
			
			if (error)
			{
				Errors.show(error, data);
				return;
			}
			
			ordered = false;
			
			hasProduct = false;
			crafting = false;
			
			fID = 0;
			
			var bonus:Object = { };
			bonus[formula.out] = { 1:formula.count };
			
			Treasures.bonus(bonus, new Point(this.x, this.y));
		}
		
		private function repairEvent():void
		{
			if (!App.user.stock.takeAll(info.price)) return;
			var that:* = this;	
			old = 0;
				
				Post.send( {
					ctr:this.type,
					act:'repair',
					uID:App.user.id,
					wID:App.user.worldID,
					sID:this.sid,
					id:this.id
				}, function(error:int, data:Object, params:Object = null):void
				{
					if (error)
					{
						Errors.show(error, data);
						return;
					}
					
					// Зачисляем на склад
					Treasures.bonus(data.bonus, new Point(this.x, this.y));
					
					App.ui.flashGlowing(that);
				});
				
			crafting = false;
		}
		
		public override function onProductionComplete():void
		{
			hasProduct = true;
			crafting = false;
			crafted = 0;
			
			switch(formula.out) {	
				case 55: 	
				case 52: 	
					flag = "noJam";
					break;
				case 623: 	
				case 625: 	
				case 626: 	
					flag = "noFish";
					break;
			}
		}
		
		public override function get crafting():Boolean
		{
			return _crafting;
		}
		
		public override function set crafting(value:Boolean):void
		{
			_crafting = value;
			
			if (_crafting == false) {
				stopAnimation();
				if(animationBitmap){
					animationBitmap.visible = false;
				}
				stopSound();
			}else{
				startSound();
			}
			
			if (_crafting || hasProduct)
				level = BUSY;
			else
				level = FREE;
				
			changeAdditionalBitmap();
				
			flag = false;
			if (old >= info.limit)
			{
				level = DAMAGED;	
				flag = "needRepair";
			}
				
			if(textures) updateLevel(true);
		}
		
		private function changeAdditionalBitmap():void {
			
			if (textures == null || !textures.hasOwnProperty('additionals')) 
				return;
			
			var object:Object;
			additionalBitmap.visible = true;
			
			if (_crafting){
				additionalBitmap.visible = false;
			}else if (hasProduct) {
				object = textures.additionals[1];
			}else{
				object = textures.additionals[0];
			}
			
			if (object == null) return;
			additionalBitmap.bitmapData = object.bmp;
			additionalBitmap.x = object.dx;
			additionalBitmap.y = object.dy;
		}
		
		private function startSound():void
		{
			//SoundsManager.instance.addDinamicEffect('jamCrafting', this);
		}
		
		private function stopSound():void
		{
			SoundsManager.instance.removeDinamicEffect(this);
		}
		
		public override function findJobPosition():Object
		{
			var Y:int = -1;
			if (coords.z + Y < 0)
				Y = 0;
			
			return {
				x:int(info.area.w/2),
				y: Y,
				direction:0,
				flip:0
			}		
		}
		
		override public function onLoad(data:*):void 
		{
			super.onLoad(data);
			changeAdditionalBitmap();
		}
	}
}