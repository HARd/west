package wins 
{
	import buttons.Button;
	import buttons.MoneyButton;
	import core.Load;
	import flash.geom.Point;
	import ui.Hints;
	import ui.UserInterface;
	import wins.elements.ProductionItem;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;

	public class ProductionWindow extends Window
	{
		protected var topBg:Bitmap = null;
		protected var bottomBg:Bitmap = null;
		protected var subTitle:TextField = null;
		protected var itemsContainer:Sprite = null;
		public var items:Array = new Array();
		protected var partList:Array = new Array();
		protected var outItem:MaterialItem = null;
		protected var currentItem:ProductionItem = null;
		
		protected var cookBttn:Button = null;
		protected var cookingTitle:TextField = null;
		protected var cookingBar:ProgressBar;
		protected var accelerateBttn:MoneyButton;
		protected var productIcon:Sprite;
		
		public var crafted:uint;
		public var totalTime:uint;
		public var progressBacking:Bitmap;
		
		public var busy:Boolean = false;
		
		public static var history:int = 0;
		
		public function ProductionWindow(settings:Object = null) 
		{
			settings['width'] = settings.width || 600;
			settings['height'] = settings.height || 620;
			
			settings['hasPaginator'] = true;
			settings['hasArrows'] = true;
			settings['hasButtons'] = false;
			settings['itemsOnPage'] = 6;
			settings['page'] = history;
			
			var crafting:Object = settings.crafting;
			settings.crafting = [];
			for each(var fID:* in crafting)
			{
				settings.crafting.push(fID);
			}
			
			super(settings);
		}
		
		override public function drawBody():void {
			
			topBg = Window.backing(490, 390, 50, "windowDarkBacking");
			topBg.x = (settings.width - topBg.width) / 2;
			topBg.y = 58;
			bodyContainer.addChild(topBg);
			
			progressBacking = Window.backing(490, 80, 10, "bonusBacking");
			progressBacking.x = (settings.width - progressBacking.width) / 2;
			progressBacking.y = topBg.y + topBg.height + 5;
			bodyContainer.addChild(progressBacking);
			
			subTitle = Window.drawText(Locale.__e("flash:1382952379994"), {
				fontSize:26,
				color:0x502f06,
				autoSize:"left",
				borderColor:0xf0e6c1
			});
			bodyContainer.addChild(subTitle);
			
			subTitle.x = settings.width / 2 - subTitle.width / 2;
			subTitle.y = topBg.y - subTitle.textHeight - 2;
			
			
			createItems();
			paginator.itemsCount = 0;
			for each(var fID:* in settings.crafting) paginator.itemsCount ++;
			
			paginator.page = settings.page;
			paginator.update();
			
			contentChange();
			showProgressBar();
		}
		
		public function showProgressBar():void
		{
			//Создаем пустой прогресс бар
			cookingTitle = Window.drawText(Locale.__e("Сейчас ничего не производится"), {
				fontSize:24,
				color:0xfbf4e4,
				textAlign:"center",
				borderColor:0x604b22
			});
			bodyContainer.addChild(cookingTitle);
			
			cookingTitle.width = 490
			cookingTitle.height = cookingTitle.textHeight;
			cookingTitle.x = (settings.width - 490) / 2;
			cookingTitle.y = topBg.y + topBg.height + 16;
			
			var barWidth:int = 330;
			cookingBar = new ProgressBar({win:this, width:barWidth});
			bodyContainer.addChild(cookingBar);
			cookingBar.x = (settings.width - barWidth)/2;
			cookingBar.y = topBg.y + topBg.height + 38;
			
			if (settings.target.crafted)
			{
				startProgress(settings.target.fID);
			}	
		}
		
		public function startProgress(fID:uint):void
		{
			accelerateBttn = new MoneyButton({
				caption		:Locale.__e('flash:1382952380104'),
				width		:74,
				height		:54,	
				fontSize	:18,
				radius		:15,
				countText	:settings.target.info.skip,
				iconScale	:0.8,
				multiline	:true
			});
			
			cookingTitle.text = Locale.__e("flash:1382952380105");
				
			bodyContainer.addChild(accelerateBttn);
			accelerateBttn.x = settings.width  - accelerateBttn.width + 22;
			accelerateBttn.y = cookingBar.y - 24;
			
			accelerateBttn.textLabel.x = 10;
			accelerateBttn.textLabel.y = 3;
			
			accelerateBttn.countLabel.x = -22;
			accelerateBttn.countLabel.y = 24;
			
			accelerateBttn.coinsIcon.x = 40;
			accelerateBttn.coinsIcon.y = 22;
			
			accelerateBttn.addEventListener(MouseEvent.CLICK, onAccelerateEvent);
			
			productIcon = new Sprite();
			var bitmap:Bitmap = new Bitmap();
			productIcon.addChild(bitmap);
			bodyContainer.addChild(productIcon);
			productIcon.x = 90;
			productIcon.y = 470;
			
			Load.loading(
				Config.getIcon("Material", App.data.storage[App.data.crafting[fID].out].preview),
				function(data:Bitmap):void{
					bitmap.bitmapData = data.bitmapData;
					bitmap.scaleX = bitmap.scaleY = 0.7;
					bitmap.smoothing = true;
					bitmap.x = -bitmap.width / 2 + 10;
					bitmap.y = -10;
					//bitmap.x = -bitmap.height / 2;
				}
			);
			
			crafted = settings.target.crafted;
			totalTime = App.data.crafting[fID].time;
			progress();
			cookingBar.start();
			
			App.self.setOnTimer(progress);
			busy = true;
		}
		
		public function onAccelerateEvent(e:MouseEvent):void {
			settings.target.onBoostEvent();
			close();
		}
		
		public function createItems():void {
			
			var X:int = 76;
			var Xs:int = X;
			var Y:int = 70;
			
			for (var i:int = 0; i < settings.itemsOnPage;  i++)
			{
				var item:ProductionItem = new ProductionItem(this);
				
				bodyContainer.addChild(item);
				items.push(item);
				
				item.x = X;
				item.y = Y;
				
				X += item.background.width + 12;
				if (i == int(settings.itemsOnPage / 2) - 1)
				{
					X = Xs;
					Y += item.background.height + 20;
				}
			}
		}
		
		override public function drawArrows():void {
			
			paginator.drawArrow(bodyContainer, Paginator.LEFT,  0, 0, { scaleX: -1, scaleY:1 } );
			paginator.drawArrow(bodyContainer, Paginator.RIGHT, 0, 0, { scaleX:1, scaleY:1 } );
			
			var y:int = (topBg.height - paginator.arrowLeft.height) / 2 + topBg.y;
			paginator.arrowLeft.x = topBg.x - paginator.arrowLeft.width + 20;
			paginator.arrowLeft.y = y;
			
			paginator.arrowRight.x = (topBg.x + topBg.width) - 20;
			paginator.arrowRight.y = y;
		}
		
		override public function contentChange():void {
			
			for (var i:int = 0; i < items.length; i++)
			{
				items[i].visible = false;
			}
			
			var itemNum:int = 0
			
			for (i = paginator.startCount; i < paginator.finishCount; i++)
			{
				items[itemNum].change(settings.crafting[i]);
				items[itemNum].visible = true;
				itemNum++;
			}
			
			settings.page = paginator.page;
			history = settings.page;
		}
		
		public function onCookEvent(fID:uint):void {
			
			settings.onCraftAction(fID);
			startProgress(fID);
			contentChange();
			App.ui.flashGlowing(progressBacking, 0xFFFF00);
		}
		
		protected function progress():void
		{
			var leftTime:int = totalTime - (App.time - crafted);
			if (leftTime <= 0) 
			{
				cookingBar.time = 0;
				cookingBar.progress = 1;
				App.self.setOffTimer(progress);
				close();
				return;
			}	
			cookingBar.progress = (App.time - crafted) / totalTime;
			cookingBar.time		= leftTime;
			
			dispatchEvent(new WindowEvent("onProgress"));
		}
		
		override public function dispose():void {
			super.dispose();
			App.self.setOffTimer(progress);
		}
		
		public function glowQuest():void {
			var qID:* = App.user.quests.currentQID;
			var mID:* = App.user.quests.currentMID;
			var targets:* = App.data.quests[qID].missions[mID].target;
			
			for each(var sID:* in targets) {
				for each(var item:ProductionItem in items) {
					if (item.sID == sID) {
						item.select();
					}
				}
			}
		}
	}
}
