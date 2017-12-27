package wins {
	
	import buttons.Button;
	import buttons.ImageButton;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.text.TextField;
	import ui.UserInterface;
	
	public class RewardWindow extends Window {
		
		public var items:Array = new Array();
		public var bitmap:Bitmap;
		public var image:BitmapData;
		public var okBttn:Button;
		private var myBackground:Bitmap;
		private var bg:Bitmap;
		
		public function RewardWindow(settings:Object = null) {
			if (settings == null) {
				settings = new Object();
			}		
			//settings["bonus"] = settings.bonus || [];
			settings["bonus"] = settings.bonus || {3:100, 5:200, 2:300};
			
			settings['width'] = 550;
			settings['height'] = 380;
			settings['title'] = Locale.__e("flash:1404394075014");
			settings['hasPaginator'] = false;
			settings['hasExit'] = false;
			
			super(settings);
		}
		
		override public function drawBackground():void {
			myBackground = Window.backing(settings.width, settings.height, 30, "alertBackingEmpty");
			layer.addChild(myBackground);
			
			bg = Window.backing(480, 255, 20, 'dialogueBacking');
			bg.x = myBackground.x + (myBackground.width - bg.width) / 2;
			bg.y = 95;
			layer.addChild(bg);
		}
		
		override public function drawTitle():void {
			titleLabel = titleText( {
				title				: settings.title,
				color				: 0xffffff,
				multiline			: settings.multiline,			
				fontSize			: 46,
				textLeading	 		: settings.textLeading,	
				border				: true,
				borderColor 		: 0xc4964e,			
				borderSize 			: 4,	
				shadowColor			: 0x503f33,
				shadowSize			: 4,
				width				: settings.width - 140,
				textAlign			: 'center',
				sharpness 			: 50,
				thickness			: 50
			});
			titleLabel.x = (settings.width - titleLabel.width) / 2 + 40;
			titleLabel.y = 35;
			titleLabel.mouseChildren = titleLabel.mouseEnabled = false;
			headerContainer.addChild(titleLabel);
			headerContainer.mouseEnabled = false;
		}
		
		public var rewardSprite:Sprite;
		override public function drawBody():void {
			var topGlow:Bitmap = new Bitmap(Window.textures.glowShine, "auto", true);
			topGlow.x = myBackground.x + (myBackground.width - topGlow.width) / 2;
			topGlow.y = -100;
			topGlow.alpha = 0.5;
			layer.addChildAt(topGlow, 1);
			
			var giftLabel:Bitmap = new Bitmap(Window.textures.treasure, "auto", true);
			giftLabel.x = myBackground.x + (myBackground.width - giftLabel.width) / 2;
			giftLabel.y = -50;
			layer.addChildAt(giftLabel, 2);
			
			var descText:TextField = drawText(Locale.__e("flash:1382952380261"),{
				color				:0x542d0a,
				borderColor			:0xf8e6d2,
				multiline			: true,
				fontSize			: 26,
				autoSize			: "center"
			});
			descText.x = myBackground.x + (myBackground.width - descText.textWidth) / 2;
			descText.y = bg.y - 5;
			bodyContainer.addChild(descText);
			
			var up_devider:Bitmap = new Bitmap(Window.textures.dividerLine);
			up_devider.x = 85;
			up_devider.y = descText.y + descText.height + 5;
			up_devider.width = settings.width - 170;
			up_devider.alpha = 0.3;
			bodyContainer.addChild(up_devider);
			
			var down_devider:Bitmap = new Bitmap(Window.textures.dividerLine);
			down_devider.x = up_devider.x;
			down_devider.width = up_devider.width;
			down_devider.y = up_devider.y + 165;
			down_devider.alpha = 0.3;
			bodyContainer.addChild(down_devider);
			
			rewardSprite = new Sprite();
			var itemNum:int = 0;
			for (var sID:* in settings.bonus){
				var item:RewardItem = new RewardItem(sID, settings.bonus[sID], {fontSize:26, widthTxt:100, titlefontSize:24, titleColor:0xffffff, titleBorderColor:0x814f31, titleShadowColor:0x814f31, shadowColor:0x754108}, true);
				item.x = itemNum * (item.width + 30) ;
				itemNum++;
				rewardSprite.addChild(item);
			}
			rewardSprite.x = bg.x + (bg.width - rewardSprite.width) / 2 + 5;
			rewardSprite.y = 150;
			bodyContainer.addChild(rewardSprite);
			
			okBttn = new Button( {
				caption:Locale.__e('flash:1404394519330'),
				fontSize:28,
				width:170,
				height:50
			});
			okBttn.name = 'RewardWindow_okBttn';
			okBttn.x = myBackground.x + (myBackground.width - okBttn.width) / 2;
			okBttn.y = myBackground.height - okBttn.height;
			bottomContainer.addChild(okBttn);
			okBttn.addEventListener(MouseEvent.CLICK, onOkBttn);
		}
		
		override public function drawExit():void {
			var exit:ImageButton = new ImageButton(textures.closeBttn);
			headerContainer.addChild(exit);
			exit.x = settings.width - 20;
			exit.y = -5;
			exit.addEventListener(MouseEvent.CLICK, close);
		}
		
		public function take():void {
			var childs:int = rewardSprite.numChildren;
			
			while(childs--) {
				var reward:RewardItem = rewardSprite.getChildAt(childs) as RewardItem;
				
				//App.user.stock.add(reward.sID, reward.count);
				
				if (reward.sID == 5 && App.user.mode == User.GUEST) continue;
				var item:BonusItem = new BonusItem(reward.sID, reward.count);					
				var point:Point = Window.localToGlobal(reward);
				item.cashMove(point, App.self.windowContainer);
				
				
			}
		}
		
		private function onOkBttn(e:MouseEvent):void {
			take();
			close();
		}
		
		override public function dispose():void {
			super.dispose();
		}
	}
}