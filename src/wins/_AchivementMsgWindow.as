package wins 
{
	import buttons.Button;
	import buttons.ImageButton;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import ui.Cursor;
	import ui.UserInterface;
	/**
	 * ...
	 * @author ...
	 */
	
	public class _AchivementMsgWindow extends Window
	{
		public static var isShowed:Boolean = false;
		
		public static var showed:Array = [];
		public var achive:Object;
		public var indMission:int;
		public function _AchivementMsgWindow(achive:Object, indMission:int, settings:Object = null) 
		{
			if (settings == null) {
				settings = new Object();
			}
			
			this.achive = achive;
			this.indMission = indMission;
			showed.push(achive.ID);
			settings['width'] = 240;
			settings['height'] = 224;
			settings['background'] = 'achievementBacking';
			settings['hasPaginator'] = false;
			
			settings['hasFader'] = false;
			settings['faderClickable'] = false;
			//settings['popup'] = true;
			settings['faderAlpha'] = 1;
			settings['autoClose'] = true;
			
			settings['title'] = achive.description || 'Остров пасхи';
			
			
			settings['totalStars'] = settings.totalStars || 3;
			//settings['openStars'] = indMission || 3;
			
			super(settings);
			
			isShowed = true;
		}
		
		override public function drawBody():void 
		{
			exit.x += 10;		
			exit.y -= 10;	
			
			var ribbon:Bitmap = backingShort(0, 'blueRibbon');
			ribbon.x = (settings.width - ribbon.width) / 2;
			ribbon.y = -20;
			bodyContainer.addChild(ribbon);
			
			drawInfo();
			
			drawBttn();
			
			drawStars();
			
			this.x = -int(App.self.stage.stageWidth/2) + this.width/2 + 80;
			this.y = int(App.self.stage.stageHeight/2) - this.height + 5;
			
			opened = false;
		}
		
		private function drawStars():void 
		{
			var container:Sprite = new Sprite();
			
			var i:int;
			var posX:int = 0;
			var posY:int = 0;
			
			for ( i = 0; i < settings.totalStars; i++ ) {
				var star:Bitmap = new Bitmap(textures.emptyStarSlot);
				star.scaleX = star.scaleY = 0.78;
				star.smoothing = true;
				star.alpha = 0.5;
				container.addChild(star);
				star.x = posX;
				star.y = posY;
				
				posX += star.width + 6;
				if (i == 0) posY = -3;
				else posY = 0;
			}
			
			posX = 2;
			posY = 0;
			for (i = 0; i < getMission() - 1; i++ ) {
				var star2:Bitmap = new Bitmap(UserInterface.textures.expIcon);
				//star2.scaleX = star2.scaleY = 0.78;
				star2.smoothing = true;
				//star2.alpha = 0.5;
				container.addChild(star2);
				star2.x = posX;
				star2.y = posY;
				
				posX += star2.width + 8;
				if (i == 0) posY = -3;
				else posY = 0;
			}
			
			
			
			bodyContainer.addChild(container);
			container.x = (settings.width - container.width) / 2;
			container.y = -15;
		}
		
		private function getMission():int 
		{
			var num:int = 1;
			for (var cnt:* in achive.missions) {
				//if (num == 0) num = cnt;
				if (App.user.ach[achive.ID][cnt] > 1000000000)
					num++;
			}
			
			if (num == 0) num = 1;
			return num;
		}
		
		private var takeBttn:Button;
		private function drawBttn():void 
		{
			takeBttn = new Button( {
				caption:Locale.__e("flash:1393579618588"),
				fontSize:24,
				width:190,
				hasDotes:true,
				height:44,
				greenDotes:true,
				bgColor:				[0xa8f84a,0x74bc17],	
				borderColor:			[0x4d7b83,0x4d7b83],	
				bevelColor:				[0xc8fa8f, 0x5f9c11],
				fontColor:				0xffffff,				
				fontBorderColor:		0x4d7d0e
			});
			bodyContainer.addChild(takeBttn);
			takeBttn.x = (settings.width - takeBttn.width) / 2;
			takeBttn.y = settings.height - takeBttn.height - 36;
			
			takeBttn.addEventListener(MouseEvent.MOUSE_DOWN, onTake);
		}
		
		private function onTake(e:MouseEvent):void 
		{
			close();
			new AchivementsWindow( { find:achive.ID } ).show();
			e.stopImmediatePropagation();
		}
		
		private function drawInfo():void 
		{
			var descTitle:TextField = Window.drawText(achive.title, {
				fontSize:32,
				color:0xffe760,
				textAlign:"left",
				borderColor:0x3e2a26
			});
			descTitle.width = descTitle.textWidth + 5;
			bodyContainer.addChild(descTitle);
			descTitle.x = (settings.width - descTitle.textWidth) / 2;
			descTitle.y = 44;
			
			var descInfo1:TextField = Window.drawText(Locale.__e("flash:1393579648825"), {
				fontSize:23,
				color:0xffffff,
				textAlign:"left",
				borderColor:0x242631,
				borderSize:3.4,
				distShadow:0
			});
			descInfo1.width = settings.width - 10;
			bodyContainer.addChild(descInfo1);
			descInfo1.x = (settings.width - descInfo1.textWidth) / 2;
			descInfo1.y = descTitle.y + descTitle.textHeight + 6;
			
			
			var descInfo2:TextField = Window.drawText(Locale.__e("flash:1393579682708"), {
				fontSize:23,
				color:0xffffff,
				textAlign:"left",
				borderColor:0x242631,
				borderSize:3.4,
				distShadow:0
			});
			descInfo2.width = settings.width - 10;
			bodyContainer.addChild(descInfo2);
			descInfo2.x = (settings.width - descInfo2.textWidth) / 2;
			descInfo2.y = descInfo1.y + descInfo1.textHeight;
		}
		
		override public function drawBackground():void 
		{
			var background:Bitmap = backing(settings.width, settings.height, 32, settings.background);
			layer.addChild(background);
		}
		
		override public function drawTitle():void 
		{
				
		}
		
		override protected function onRefreshPosition(e:Event = null):void
		{ 		
			super.onRefreshPosition(e);
			
			this.x = -int(App.self.stage.stageWidth/2) + this.width/2 + 60;
			this.y = int(App.self.stage.stageHeight/2) - this.height;
		}
		
		override public function drawExit():void {
			exit = new ImageButton(textures.closeBttn);
			headerContainer.addChild(exit);
			exit.x = settings.width - 50;
			exit.y = 0;
			exit.addEventListener(MouseEvent.MOUSE_DOWN, close);
		}
		
		override public function close(e:MouseEvent=null):void {
				
			if (settings.hasAnimations == true) {
				startCloseAnimation();
			}else {
				dispatchEvent(new WindowEvent("onBeforeClose"));
				dispose();			
			}	
			
			if(e != null)
				e.stopImmediatePropagation();
		}
		
		override public function dispose():void {
				
			//MouseCursor.switchVisibleCursor(Connection.lastCursorType);
			
			isShowed = false;
			
			if (takeBttn) {
				takeBttn.removeEventListener(MouseEvent.CLICK, onTake);
				takeBttn.dispose();
				takeBttn = null;
			}
			
			if (fader != null && fader.hasEventListener(MouseEvent.CLICK)) {
				fader.removeEventListener(MouseEvent.CLICK, onFaderClick);
				fader = null;
			}
			
			if (this.stage != null)
			{
				this.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
				this.stage.removeEventListener(Event.RESIZE, onRefreshPosition);
			}
			
			if(settings.hasExit && exit){
				exit.removeEventListener(MouseEvent.MOUSE_DOWN, close);
			}
			
			if (settings.hasPaginator && paginator != null) {
				paginator.dispose();
			}
			
			if (this.parent != null) {
				this.parent.removeChild(this);
			}else {
				if(App.self.windowContainer.contains(this)){
					App.self.windowContainer.removeChild(this);
				}
			}
			
			//uiBuffer.bigWinOpen = false;

			for (var i:int = 0; i < App.self.windowContainer.numChildren; i++) {
				var backWindow:* = App.self.windowContainer.getChildAt(i);

				if (backWindow is Window && !(backWindow is InstanceWindow) && !(backWindow is AchivementMsgWindow) && backWindow.opened == false) {
					//try{
						backWindow.create();
					//}catch (e:Error) {
						//trace(e.message);
					//}
					break;
				}else if(backWindow is Window)
				{
					break;
				}
			}
			
			if(settings.returnCursor && Cursor.type != "stock" && Cursor.type != "water"){
				Cursor.type = Cursor.prevType;
			}
			
			dispatchEvent(new WindowEvent("onAfterClose"));		
			
			if (clearQuestsTargets) {
				Quests.help = false;
			}
				
		}
		
		
	}

}