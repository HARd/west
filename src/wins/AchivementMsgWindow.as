package wins 
{
	import buttons.Button;
	import buttons.ImageButton;
	import com.greensock.easing.Elastic;
	import com.greensock.TweenLite;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.utils.clearInterval;
	import flash.utils.setInterval;
	import ui.Cursor;
	import ui.UserInterface;
	/**
	 * ...
	 * @author ...
	 */
	
	public class AchivementMsgWindow extends Window
	{
		public static var isShowed:Boolean = false;
		
		public static var showed:Array = [];
		public var achive:Object;
		public var indMission:int;
		
		private var intervalClose:int;
		public function AchivementMsgWindow(achive:Object, indMission:int, settings:Object = null) 
		{
			if (settings == null) {
				settings = new Object();
			}
			
			this.achive = achive;
			this.indMission = indMission;
			showed.push(achive.ID);
			settings['width'] = 240;
			settings['height'] = 224;
			settings['background'] = 'achievementUnlockBacking';
			settings['hasPaginator'] = false;
			
			settings['hasFader'] = false;
			settings['faderClickable'] = false;
			settings['faderAlpha'] = 1;
			settings['autoClose'] = true;
			settings['hasExit'] = false;
			settings['title'] = achive.description || 'Остров пасхи';
			
			settings['totalStars'] = settings.totalStars || 3;
			
			super(settings);
			
			isShowed = true;
			
			intervalClose = setInterval(doClose, 5500);
		}
		
		private var tweenClose:TweenLite;
		private function doClose():void
		{
			clearInterval(intervalClose);
			tweenClose = TweenLite.to(this, 0.3, { x:this.x + 220, y:this.y + 200, scaleX:0.5, scaleY:0.5, alpha:0, onComplete:function():void { close(); }} );
		}
		
		override public function drawBackground():void {
			var background:Bitmap = new Bitmap(Window.textures.achievementUnlockBacking);
			layer.addChild(background);
		}
		
		override public function drawBody():void 
		{
			drawInfo();
			
			drawStars();
			
			this.x = -int(App.self.stage.stageWidth/2) + this.width/2 + 380;
			this.y = int(App.self.stage.stageHeight/2) - this.height - 70;
			
			opened = false;
		}
		
		private function drawInfo():void 
		{
			var descTitle:TextField = Window.drawText(achive.title, {
				fontSize:24,
				color:0xffe96f,
				textAlign:"left",
				borderColor:0x543612
			});
			descTitle.width = descTitle.textWidth + 5;
			bodyContainer.addChild(descTitle);
			descTitle.x = (settings.width - descTitle.width) / 2 - 25;
			descTitle.y = 3;
		}
		
		private function drawStars():void 
		{
			var container:Sprite = new Sprite();
			
			var i:int;
			var posX:int = 1;
			var posY:int = 1;
			
			for ( i = 0; i < settings.totalStars; i++ ) {
				var star:Bitmap = new Bitmap(UserInterface.textures.achieveEmptyStar);
				star.scaleX = star.scaleY = 0.78;
				star.smoothing = true;
				star.alpha = 0.8;
				container.addChild(star);
				star.x = posX;
				star.y = posY;
				
				posX += star.width + 6;
			}
			
			posX = 5;
			posY = 5;
			var numMis:int = getMission();
			var starGlow:Bitmap;
			for (i = 0; i < numMis; i++ ) {
				var star2:Bitmap = new Bitmap(UserInterface.textures.expIcon);
				star2.smoothing = true;
				container.addChild(star2);
				star2.x = posX;
				star2.y = posY;
				
				posX += star2.width + 11;
				if (i == 0) posY = -3;
				else {
					posX -= 1;
					posY = 4;
				}
				
				if (i == numMis - 1) {
					star2.alpha = 0;
					starGlow = star2;
				}
			}
			
			tweenStart = TweenLite.to(starGlow, 0.5, {onComplete:function():void { starGlow.alpha = 0; glowStar(starGlow); }} ); 
			
			bodyContainer.addChild(container);
			container.x = 12;
			container.y = 30;
		}
		
		private var tweenStart:TweenLite;
		private var margX:int = 4;
		private var margY:int = 4;
		private var tweenGlow1:TweenLite;
		private var tweenGlow2:TweenLite;
		private function glowStar(star:Bitmap):void
		{
			tweenGlow1 = TweenLite.to(star, 0.8, {x:star.x-margX, y:star.y-margY, alpha:1, scaleX:1.2, scaleY:1.2, ease:Elastic.easeOut, onComplete:function():void {
				tweenGlow2 = TweenLite.to(star, 0.8, {x:star.x+margX, y:star.y+margY, alpha:0, scaleX:1, scaleY:1, /*ease:Elastic.easeIn,*/ onComplete:function():void {
					glowStar(star);
				}});
			}});
		}
		
		private function getMission():int 
		{
			var num:int = 1;
			for (var cnt:* in achive.missions) {
				if (App.user.ach[achive.ID][cnt] > 1000000000)
					num++;
			}
			
			if (num == 0) num = 1;
			return num;
		}
		
		private function onTake(e:MouseEvent):void 
		{
			close();
			new AchivementsWindow( { find:achive.ID } ).show();
			e.stopImmediatePropagation();
		}
		
		override public function drawTitle():void 
		{
		}
		
		override protected function onRefreshPosition(e:Event = null):void
		{ 		
			super.onRefreshPosition(e);
			
			this.x = -int(App.self.stage.stageWidth/2) + this.width/2 + 133;
			this.y = int(App.self.stage.stageHeight/2) - this.height + 35;
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
			clearInterval(intervalClose);
			
			if (tweenStart) {
				tweenStart.kill();
				tweenStart = null;
			}
			if (tweenClose) {
				tweenClose.kill();
				tweenClose = null;
			}
			
			if (tweenGlow1) {
				tweenGlow1.kill();
				tweenGlow1 = null;
			}
			if (tweenGlow2) {
				tweenGlow2.kill();
				tweenGlow2 = null;
			}
			
			isShowed = false;
			
			if (fader != null && fader.hasEventListener(MouseEvent.CLICK)) {
				fader.removeEventListener(MouseEvent.CLICK, onFaderClick);
				fader = null;
			}
			
			if (this.stage != null)
			{
				this.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
				this.stage.removeEventListener(Event.RESIZE, onRefreshPosition);
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
			
			for (var i:int = 0; i < App.self.windowContainer.numChildren; i++) {
				var backWindow:* = App.self.windowContainer.getChildAt(i);

				if (backWindow is Window && !(backWindow is InstanceWindow) && !(backWindow is AchivementMsgWindow) && backWindow.opened == false) {
					backWindow.create();
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