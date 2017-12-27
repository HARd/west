package wins 
{
	import buttons.Button;
	import buttons.MoneyButton;
	import flash.display.Bitmap;
	import flash.events.MouseEvent;
	import flash.text.TextField;

	public class CollectorWindow extends Window
	{
		public var items:Array = new Array();
	
		public function CollectorWindow(settings:Object = null) 
		{
			if (settings == null) {
				settings = new Object();
			}
			
			settings['width'] = 600;
			settings['height'] = 280;
			settings['title'] = settings.target.info.title;
			settings['hasPaginator'] = false;
			settings['hasButtons'] = false;
			
			super(settings);
		}
		
		public var descriptionLabel1:TextField;
		public var descriptionLabel2:TextField;
		public var mode:uint = 0;
		public var sID:uint = 0;
		public var bitmap1:Bitmap;
		public var bitmap2:Bitmap;
		override public function drawBody():void {
			
			exit.y -= 10;
			exit.x += 40;
			
			if (settings.target.started > 0)
			{
				
				if (settings.target.mID > 0)
				{
					sID = settings.target.mID
					mode = CollectionWindow.SELECT_ELEMENT;
				}
				else
				{
					sID = settings.target.cID
					mode = CollectionWindow.SELECT_COLLECTION;
				}
				showWork();
				return;
			}
			
			drawBttns();
			
			bitmap1 = new Bitmap(Window.textures.bagCollector);
			bodyContainer.addChild(bitmap1);
			bitmap1.x = axe1 - bitmap1.width/2;;
			//bitmap1.y = back_1.y - 80;
			
			bitmap2 = new Bitmap(Window.textures.mapCollector);
			bodyContainer.addChild(bitmap2);
			bitmap2.x = axe2 - bitmap2.width/2;;
			//bitmap2.y = back_2.y - 70;
			
			var text1:String = Locale.__e("flash:1382952380016");
			
			descriptionLabel1 = drawText(text1, {
				fontSize:22,
				autoSize:"center",
				textAlign:"center",
				color:0x604729,
				borderColor:0xfaf1df,
				multiline:true
			});
			descriptionLabel1.wordWrap = true;
			descriptionLabel1.width = WIDTH;
			descriptionLabel1.height = descriptionLabel1.textHeight;
			
			descriptionLabel1.x = axe1 - descriptionLabel1.width/2;
			descriptionLabel1.y = bttn1.y - descriptionLabel1.textHeight - 10;
			
			bodyContainer.addChild(descriptionLabel1);
			
			var text2:String = Locale.__e("flash:1382952380019");
			
			descriptionLabel2 = drawText(text2, {
				fontSize:22,
				autoSize:"center",
				textAlign:"center",
				color:0x604729,
				borderColor:0xfaf1df,
				multiline:true
			});
			descriptionLabel2.wordWrap = true;
			descriptionLabel2.width = WIDTH;
			descriptionLabel2.height = descriptionLabel2.textHeight;
			
			descriptionLabel2.x = axe2 - descriptionLabel2.width/2;
			descriptionLabel2.y = bttn2.y - descriptionLabel2.textHeight - 10;
			
			bodyContainer.addChild(descriptionLabel2);
		}
		
		public var progressBar:ProgressBar;
		public var totalTime:uint;
		public var started:uint;
		public var buyAllBttn:MoneyButton;
		public var back_3:Bitmap;
		
		public function showWork():void {
			
			back_3 = Window.backing(settings.width - 40, 200, 10, "itemBacking");
			bodyContainer.addChild(back_3);
			back_3.x = 20;
			back_3.y = 50;
			
			totalTime = settings.target.time;
			progressBar = new ProgressBar( { win:this, width:settings.width - 202} );
			progress();
			progressBar.x = (settings.width - progressBar.width) / 2 +20;
			progressBar.y = 170;
			bodyContainer.addChild(progressBar);
			App.self.setOnTimer(progress);
			progressBar.start();
			back_1.visible = false;
			back_2.visible = false;
			
			var skipPrice:uint = settings.target.info.skip;

			buyAllBttn = new MoneyButton({
				caption		:Locale.__e("flash:1382952380021"),
				width		:190,
				height		:42,	
				fontSize	:26,
				countText	:skipPrice
			});
			buyAllBttn.x = (settings.width - buyAllBttn.width) / 2;
			buyAllBttn.y = 220;
			
			bodyContainer.addChild(buyAllBttn);
			
			buyAllBttn.addEventListener(MouseEvent.CLICK, buyAllEvent);
			buyAllBttn.visible = true;
			
			drawInfo();
		}
		
		private function drawInfo():void {
			
			var sIDs:Object = {};
			var text:String = "";
			if (mode == CollectionWindow.SELECT_COLLECTION) {
				text = Locale.__e('flash:1382952380022');
				for each(var mID:* in App.data.storage[sID].materials)
					sIDs[mID] = 0;
			}else{
				text = Locale.__e('flash:1382952380026');
				sIDs[sID] = 0;
			}
			
			var label:TextField = drawText(text, {
				fontSize:22,
				autoSize:"center",
				textAlign:"center",
				color:0x604729,
				borderColor:0xfaf1df,
				multiline:true
			});
			label.wordWrap = true;
			label.width = settings.width;
			label.height = label.textHeight;
			
			label.x = 0;
			label.y = back_3.y + 10;
			
			var bonusList:BonusList = new BonusList(sIDs, false, {
				hasTitle:false,
				size:60
			});
			
			bonusList.x = (settings.width - bonusList.width) / 2;
			bonusList.y = label.y + 35;
			
			bodyContainer.addChild(bonusList);
			bodyContainer.addChild(label);
		}
		
		private function buyAllEvent(e:MouseEvent):void 
		{
			if (e.currentTarget.mode == Button.DISABLED) return;
			e.currentTarget.state = Button.DISABLED;
			
			settings.target.onBoostEvent();
			close();
		}
		
		private function progress():void
		{
			var leftTime:uint = totalTime - (App.time - settings.target.started);
			progressBar.time = leftTime;
			
			if (leftTime <= 0) { 
				App.self.setOffTimer(progress);
				close();
			}
			progressBar.progress = (App.time - settings.target.started) / totalTime;
		}
		
		public var bttn1:Button;
		public var bttn2:Button;
		
		public function drawBttns():void {
			bttn1 = new Button( {
				caption:Locale.__e("flash:1382952380027"),
				fontSize:25,
				width:180,
				height:50
			});
			
			bodyContainer.addChild(bttn1);
			bttn1.x = axe1 - bttn1.width/2;
			bttn1.y = 180;
			
			bttn1.addEventListener(MouseEvent.CLICK, onClick1);
			
			bttn2 = new Button( {
				caption:Locale.__e("flash:1382952380028"),
				fontSize:25,
				width:180,
				height:50
			});
			
			bodyContainer.addChild(bttn2);
			bttn2.x = axe2 - bttn2.width/2;
			bttn2.y = 180;
			
			bttn2.addEventListener(MouseEvent.CLICK, onClick2);
		}
		
		public function onClick1(e:MouseEvent):void {
			if (e.currentTarget.mode == Button.DISABLED) return;
			
			new CollectionWindow( {
				mode:CollectionWindow.SELECT_COLLECTION,
				popup:true,
				onSearch:onSearch
			}).show();
		}
		
		public function onClick2(e:MouseEvent):void {
			if (e.currentTarget.mode == Button.DISABLED) return;
			
			new CollectionWindow( {
				mode:CollectionWindow.SELECT_ELEMENT,
				popup:true,
				onSearch:onSearch
			}).show();
		}
		
		private var axe1:int = 0;
		private var axe2:int = 0;
		private var WIDTH:uint;
		private var back_1:Bitmap;
		private var back_2:Bitmap;
		
		override public function drawBackground():void
		{
			var backing:Bitmap = Window.backing(settings.width, settings.height, 50, 'windowBacking');
			layer.addChild(backing);
			backing.y = 40;
			
			WIDTH = (backing.width - 75)/2;
			
			back_1 = Window.backing(WIDTH, 200, 10, "itemBacking");
			back_2 = Window.backing(WIDTH, 200, 10, "itemBacking");
			layer.addChild(back_1);
			layer.addChild(back_2);
			
			back_1.x = backing.x + 25;
			back_1.y = backing.y + 50;
			axe1 = back_1.x + back_1.width / 2;
			
			back_2.x = back_1.x + WIDTH + 25;
			back_2.y = back_1.y;
			axe2 = back_2.x + back_2.width / 2;
			
			bitmap1.y = back_1.y - 80;
			bitmap2.y = back_2.y - 70;
		}
		
		public override function dispose():void
		{
			super.dispose();
		}
		
		private function onSearch(mode:uint, sID:uint):void {
			
			if (mode == CollectionWindow.SELECT_ELEMENT)
			{
				if (!App.user.stock.take(Stock.FANT, App.data.storage[sID].real))
					return;
			}
			
			descriptionLabel1.visible = false;
			descriptionLabel2.visible = false;
			back_1.visible = false;
			back_2.visible = false;
			bitmap1.visible = false;
			bitmap2.visible = false;
			bttn1.visible = false;
			bttn2.visible = false;
			settings.onSearch(mode, sID);
			this.mode = mode;
			this.sID = sID;
			showWork();
		}
	}
}