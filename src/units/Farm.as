package units 
{
	import api.ExternalApi;
	import com.greensock.TweenLite;
	import core.Post;
	import flash.display.Bitmap;
	//import wins.FarmWindow;

	public class Farm extends Building
	{
		
		public var plantTextures:Object;
		
		public var capacity:int = 0;
		
		public function Farm(object:Object) 
		{
			capacity = object.capacity || 0;
			
			layer = Map.LAYER_SORT;
			
			super(object);
			
			if (object.fID > 0) {
				formula = App.data.farming[object.fID];
				formula['time'] = App.data.storage[formula.plant].levels * App.data.storage[formula.plant].levelTime;
			}
			
			if (object.fID > 0) {
				createPlants(object.fID);
			}
			
			setCloudPosition(0, -30);
		}
		
		override public function updateLevel(checkRotate:Boolean = false):void {
			var levelData:Object = textures.sprites[this.level];			
			
			if (checkRotate && rotate == true) {
				flip();
			}
			
			if (this.level != 0 && gloweble)
			{
				var backBitmap:Bitmap = new Bitmap(bitmap.bitmapData)
				backBitmap.x = bitmap.x;
				backBitmap.y = bitmap.y;
				addChildAt(backBitmap, 0);
				
				bitmap.alpha = 0;
				
				App.ui.flashGlowing(this);
				
				TweenLite.to(bitmap, 1, { alpha:1, onComplete:function():void {
					removeChild(backBitmap);
					backBitmap = null;
				}});
				
				gloweble = false;
			}
			
			draw(levelData.bmp, levelData.dx, levelData.dy);
			
			/*if (textures.hasOwnProperty('animation')){
				
				if (level == totalLevels){
					for (var frameType:String in textures.animation.animations){
						framesTypes.push(frameType);
					}
					if (formula) {
						addMultipleAnimation(false, 1);
					}else{
						addMultipleAnimation(false, numChildren);
					}
					
					if (crafted && !animated) {
						startMultipleAnimation(true);
					}else {
						animateMultiple();
					}
				}	
			}*/
		}
		
		override public function openProductionWindow():void {
			// Открываем окно продукции
			/*new FarmWindow( {
				title:			info.title,
				crafting:		info.farming,
				target:			this,
				onCraftAction:	onCraftAction
			}).show();*/
		}
		
		
		override public function onCraftAction(fID:uint):void
		{
			beginCraft(fID, App.time);
			var formula:Object = App.data.farming[fID];
			
			if(capacity >= formula.spoons){
				capacity -= formula.spoons;
			}else {
				return;
			}
			
			var plant:Object = App.data.storage[formula.plant];
			if(App.user.stock.take(Stock.COINS, plant.coins*3)){
			
				Post.send({
					ctr:this.type,
					act:'crafting',
					uID:App.user.id,
					id:this.id,
					wID:App.user.worldID,
					sID:this.sid,
					fID:fID
				}, onCraftEvent);
				
				createPlants(fID);
				
				startAnimation(true);
			}
		}
		
		override public function onBoostEvent(count:int = 0):void {
			
			if (App.user.stock.take(Stock.FANT, info.skip)){//  || App.user.stock.take(Stock.FANT, count)) {
				
				//crafted -= formula['time'];
				crafted = 0;
				var that:Farm = this;
				var length:uint = numChildren;
				while(length--) {
					var child:* = getChildAt(length);
					if (child is FarmPlant) {
						child.planted = crafted;
						var level:int = child.level;
					}
				}
				
				Post.send({
					ctr:this.type,
					act:'boost',
					uID:App.user.id,
					id:this.id,
					wID:App.user.worldID,
					sID:this.sid
				}, function(error:*, data:*, params:*):void {
					
					if (!error && data) {
						crafted = 0;
						App.ui.flashGlowing(that);
					}
				});
				
			}
			
		}
		
		public function createPlants(fID:uint):void {
			
			var formula:Object = App.data.farming[fID];
					
			var point:Object;
			for (var i:int = 0; i < 3; i++) {
				switch(i) {
					case 0: point = {x:-80, y:48}; break;
					case 1: point = {x:84, y:48}; break;
					case 2: point = {x:0, y:90}; break;
				}
				
				var plant:FarmPlant = new FarmPlant( {
					sid:formula.plant,
					planted:crafted,
					farm:this,
					point:point
				});
				addChild(plant);
			}
		}
		
		public function addJam(jsID:uint):Boolean {
			
			if(App.user.stock.check(jsID)){
				
				App.user.stock.take(jsID, 1);
				
				capacity += App.data.storage[jsID].capacity;
				
				Post.send( {
					ctr:this.type,
					act:'addjam',
					uID:App.user.id,
					wID:App.user.worldID,
					sID:this.sid,
					id:id,
					jsID:jsID
				}, onAddJamEvent);
			
				return true;
			}else {
				return false;
			}
		}
		
		private function onAddJamEvent(error:*, data:*, params:*):void {
			
		}
		
		override public function get progress():Boolean {
			
			//var formula:Object = App.data.farming[fID];
			//var time:int = App.data.storage[formula.plant].levels * App.data.storage[formula.plant].levelTime;
			
			if (crafted + formula.time <= App.time)
			{
				stopAnimation();
				// flash:1382952379984вершаем проflash:1382952379993водство
				onProductionComplete();
				return true;
			}
			return false;
		}
		
		override public function storageEvent(value:int = 0):void
		{
			super.storageEvent();
			var length:uint = numChildren;
			while(length--) {
				var child:* = getChildAt(length);
				if (child is FarmPlant) {
					removeChild(child);
				}
			}
		}
		
		override protected function beginCraft(fID:uint, crafted:uint):void
		{
			this.fID = fID;
			this.crafted = crafted;
			hasProduct = false
			crafting = true;
			
			formula = App.data.farming[fID];
			formula['time'] = App.data.storage[formula.plant].levels * App.data.storage[formula.plant].levelTime;
			
			//Делаем push в _6e
			//if (App.social == 'FB') {
				//var out:String = App.data.storage[formula.out].view;
				//ExternalApi._6epush([ "_event", { "event": "gain", "item":out } ]);
			//}
			
			App.self.setOnTimer(production);
		}
	}

}