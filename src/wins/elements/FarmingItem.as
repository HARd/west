package wins.elements 
{

	import com.greensock.TweenMax;
	import core.Load;
	import core.TimeConverter;
	import flash.events.MouseEvent;
	import wins.FarmingWindow;
	import wins.Window;

	//Вспомогательный класс
	public class FarmingItem extends ProductionItem{
		
		public var spoons:int = 0;
	
		public function FarmingItem(win:*)
		{
			this.win = win
			super(win);
		}
		
				
		private var preloader:Preloader = new Preloader();
		override public function change(fID:*, lvlNeed:int = 0, isHelp:Boolean = false):void
		{
			var formula:Object = App.data.farming[fID];
			
			this.sID 		= formula.out;
			this.fID 		= int(fID);
			this.count 		= formula.count;
			this.recipe 	= formula.plant;
			this.spoons 	= formula.spoons;
			
			var plantSID:Object = App.data.farming[fID].plant;
			var plantObject:Object = App.data.storage[plantSID];
			
			var totalTime:int = plantObject.levels * plantObject.levelTime;
			
			title.text = App.data.storage[sID].title;
			title.x = (background.width - title.width) / 2;
			
			addChild(preloader);
			preloader.x = (background.width)/ 2;
			preloader.y = (background.height)/ 2 - 5;
			Load.loading(Config.getIcon("Material", App.data.storage[sID].preview), onPreviewComplete);
			
			timeText.text = TimeConverter.timeToCuts(totalTime);
			
			if (Quests.help) {
				var qID:int = App.user.quests.currentQID;
				var mID:int = App.user.quests.currentMID;
				var targets:Object = App.data.quests[qID].missions[mID].target;
				for each(var sid:* in targets){
					if(this.sID == sid){
						stopGlowing = false;
						glowing();
					}
				}
			}
		}
		
		override public function onPreviewComplete(obj:Object):void
		{
			if(contains(preloader)){
				removeChild(preloader);
			}
			bitmap.bitmapData = obj.bitmapData;
			bitmap.smoothing = true;
			bitmap.scaleX = bitmap.scaleY = 0.8;
			bitmap.x = (background.width - bitmap.width) / 2;
			bitmap.y = (background.height - bitmap.height) / 2 - 5;
		}
		
		override protected function onRecipeBttnClick(e:MouseEvent):void
		{
			new FarmingWindow( {
				fID:fID,
				win:win,
				onCook:win.onCookEvent,
				busy:win.busy,
				capacity:win.settings.target.capacity,
				hasDescription:true
			}).show();
		}
		
		private function glowing():void {
			customGlowing(background, glowing);
			if (recipeBttn) {
				customGlowing(recipeBttn);
			}
		}
		
		private var stopGlowing:Boolean = false;
		private function customGlowing(target:*, callback:Function = null):void {
			TweenMax.to(target, 1, { glowFilter: { color:0xFFFF00, alpha:0.8, strength: 7, blurX:12, blurY:12 }, onComplete:function():void {
				if (stopGlowing) {
					target.filters = null;
					return;
				}
				TweenMax.to(target, 0.8, { glowFilter: { color:0xFFFF00, alpha:0.6, strength: 7, blurX:6, blurY:6 }, onComplete:function():void {
					if (!stopGlowing && callback != null) {
						callback();
					}
					if (stopGlowing) {
						target.filters = null;
					}
				}});	
			}});
		}		
			
	}

}