package wins 
{
	import buttons.MoneyButton;
	import core.Load;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.text.TextField;
	/**
	 * ...
	 * @author ...
	 */
	public class AnimalProgressWindow extends Window
	{
		public var bitmap:Bitmap;
		
		private var leftTime:int;
		private var startTime:int;
		private var endTime:int;
		private var totalTime:int;
		
		private var efir:int;
		private var outItem:int;
		
		private var pid:int;
		private var sid:int;
		
		private var progressBar:ProgressBar;
		private var boostBttn:MoneyButton;
		
		private var priceSpeed:int = 0;
		private var priceBttn:int = 0;
		
		public function AnimalProgressWindow(settings:Object = null) 
		{
			if (settings == null) {
				settings = new Object();
			}
			
			settings['sID'] = settings.sID || 0;
			
			settings["width"] = 366;
			settings["height"] = 402;
			settings["popup"] = true;
			settings["fontSize"] = 36;
			settings["callback"] = settings["callback"] || null;
			
			settings["hasPaginator"] = false;
			
			pid = settings.pid;
			sid = settings.sid;
			
			endTime = settings.endTime;
			startTime = endTime - App.data.crafting[pid].time;
			totalTime = endTime - startTime;
			
			super(settings);	
		}
		
		public function progress():void
		{
			leftTime = endTime-App.time;
			
			progressBar.time = leftTime;
			progressBar.progress =  (totalTime - (leftTime)) / totalTime;
			
			priceSpeed = Math.ceil(leftTime / App.data.options['SpeedUpPrice']);
			if (boostBttn && priceBttn != priceSpeed && priceSpeed != 0) {
				priceBttn = priceSpeed;
				boostBttn.count = String(priceSpeed);
			}
		}
		
		override public function drawBackground():void {
			var background:Bitmap = backing2(settings.width, settings.height, 40, "questsSmallBackingTopPiece", "questsSmallBackingBottomPiece");
			layer.addChild(background);
		}
		
		override public function drawExit():void {
			super.drawExit();
			
			exit.x = settings.width - exit.width + 12;
			exit.y = -12;
		}
		
		
		private var preloader:Preloader = new Preloader();
		override public function drawBody():void {
			
			titleLabel.y -= 6;
			
			
			background = Window.backing(296, 260, 10, "itemBacking");
			bodyContainer.addChild(background);
			background.x = (settings.width - background.width)/2;
			background.y = 26;
			
			var lvlLbg:Bitmap = Window.backingShort(170, "orangeStripPiece");
			bodyContainer.addChild(lvlLbg);
			lvlLbg.x = background.x + (background.width - lvlLbg.width)/2;
			lvlLbg.y = -16;
			
			var lvlLabel:TextField = Window.drawText(Locale.__e("flash:1396608622333", [settings.target.level]),{
					fontSize:24,
					autoSize:"left",
					textAlign:"center",
					multiline:true,
					color:0xffffff,
					borderColor:0xb56a17	
				});
			bodyContainer.addChild(lvlLabel);
			lvlLabel.x = lvlLbg.x + (lvlLbg.width - lvlLabel.textWidth) / 2;
			lvlLabel.y = -7;
			
			
			var nameItem:TextField = Window.drawText(Locale.__e(App.data.crafting[pid].title),{
					fontSize:24,
					autoSize:"left",
					textAlign:"center",
					multiline:true,
					color:0x6d3f23,
					borderColor:0xfaf9ec	
				});
				nameItem.width = background.width - 10;
				nameItem.wordWrap = true;
			bodyContainer.addChild(nameItem);
			nameItem.x = background.x + (background.width - nameItem.width) / 2;
			nameItem.y = background.y + 10;
			
			drawImage();
			
			var progressBacking:Bitmap = Window.backingShort(310, "prograssBarBacking3");
			progressBacking.x = (settings.width - progressBacking.width) / 2;
			progressBacking.y = 289;
			bodyContainer.addChild(progressBacking);
			
			progressBar = new ProgressBar( { win:this, width:300, timeSize:30, color:0xffffff, borderColor:0x2b3b64, typeLine:'progressBarPiece' } );
			progressBar.x = (settings.width - 300) / 2;
			progressBar.y = 289;
			progressBar.visible = false;
			
			bodyContainer.addChild(progressBar);
			
			progressBar.visible = true;
			
			drowBttns();
			
			progress();
			
			App.self.setOnTimer(progress);
			progressBar.start();
		}
		
		public function drawImage():void 
		{
			Load.loading(Config.getIcon(App.data.storage[App.data.crafting[sid].out].type, App.data.storage[App.data.crafting[sid].out].preview), onLoadImage);
		}
		
		private function onLoadImage(data:Object):void
		{
			bitmap = new Bitmap();
				bitmap.bitmapData = data.bitmapData;
				bitmap.smoothing = true;	
				bitmap.x = (settings.width - bitmap.width) / 2;
				bitmap.y = background.y + (background.height - bitmap.height) / 2;
			
				bodyContainer.addChild(bitmap);
		}
		
		public function drowBttns():void
		{
			var icon:Bitmap = new Bitmap(Window.textures.diamond, "auto", true);
			var icon2:Bitmap = new Bitmap(Window.textures.diamond, "auto", true);
			boostBttn = new MoneyButton( {
				title: Locale.__e("flash:1382952380104"),
				countText:String(priceSpeed),
				width:192,
				height:56,
				fontSize:30,
				fontCountSize:32,
				radius:20,
				hasDotes:false,
				greenDotes:false,
				iconScale:0.45,
				
				bgColor:[0xa8f84a, 0x73bb16],
				bevelColor:[0xaed888, 0x5f9c11],	
				
				fontColor:0xffffff,			
				fontBorderColor:0x4d7d0e,
			
				fontCountColor:0xffffff,				
				fontCountBorder:0x4d7d0e,
				iconScale:0.8
			})
			
			bodyContainer.addChild(boostBttn);
			boostBttn.x = (settings.width - boostBttn.width)/2;
			boostBttn.y = settings.height - boostBttn.height - 10;
			boostBttn.countLabel.width = boostBttn.countLabel.textWidth + 5;
			
			boostBttn.addEventListener(MouseEvent.CLICK, onUpgradeEvent);
		}
		
		private function onLoadIcon(obj:Object):void 
		{
			var container:Sprite = new Sprite();
			
			var descTxt:TextField = Window.drawText(Locale.__e("flash:1382952380034"),{
					fontSize:28,
					autoSize:"left",
					textAlign:"center",
					multiline:true,
					color:0x9a144f,
					borderColor:0xfffef1
				});
			container.addChild(descTxt);
			descTxt.y = 14;
			
			var efirIcon:Bitmap = new Bitmap(obj.bitmapData);
			efirIcon.scaleX = efirIcon.scaleY = 0.38;
			efirIcon.smoothing = true;
			efirIcon.x = descTxt.textWidth + 12;
			container.addChild(efirIcon);
			
			var shadowFilter:DropShadowFilter = new DropShadowFilter(1,90,0x453059,1,2,4,2,1);
			efirIcon.filters = [shadowFilter];	
			
			var giveTxt:TextField = Window.drawText(Locale.__e(String(efir)),{
					fontSize:32,
					autoSize:"left",
					textAlign:"center",
					multiline:true,
					color:0xfebde8,
					borderColor:0x940b40
				});
			container.addChild(giveTxt);
			giveTxt.x = efirIcon .x + efirIcon.width + 10;
			giveTxt.y = 8;
			
			
			bodyContainer.addChild(container);
			
			container.x = (settings.width - container.width) / 2;
			container.y = settings.height - container.height - 126;
		}
		
		private function onUpgradeEvent(e:MouseEvent):void 
		{
			settings.target.onBoostEvent(priceBttn);
			close();
		}
		
		override public function dispose():void
		{
			progressBar.dispose();
			App.self.setOffTimer(progress);
			super.dispose();
		}
	
	}		

}