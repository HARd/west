package wins {
	
	import api.com.odnoklassniki.sdk.events.Events;
	import buttons.Button;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import ui.UserInterface;
	import wins.elements.GuestRewardItem;
	
	public class GuestRewardWindow extends Window {
		
		private var guestIcon:Bitmap;
		private var priceBttn:Button;
		private var desc:TextField = new TextField();
		private var reward:Object;
		public var count:int;
		public var sid:int;
		
		public function GuestRewardWindow() {
			if (settings == null) {
				settings = new Object();
			}
			settings['width'] = 320;
			settings['height'] = 290;
			settings['title'] = String(App.user.currentGuestLimit) + ' ' + Locale.__e('flash:1427275297200');
			//settings['title'] = '25' + ' ' + Locale.__e('flash:1427275297200');
			settings['titleDecorate'] = false;
			settings['background'] = 'alertBacking';
			settings['hasPaginator'] = false;
			//settings['titlePading'] = 70;
			settings['hasExit'] = false;
			settings['popup'] = true;
			settings['forcedClosing'] = true;
			settings['faderAsClose'] = false;
			settings['faderClickable'] = false;
			
			reward = App.user.currentGuestReward;
			super(settings);
		}
		
		override public function drawTitle():void {
			titleLabel = titleText( {
				title				: settings.title,
				color				: 0xffffff,
				multiline			: settings.multiline,			
				fontSize			: 40,
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
			titleLabel.x = (settings.width - titleLabel.width) / 2;
			titleLabel.y = 0;
			titleLabel.mouseChildren = titleLabel.mouseEnabled = false;
			headerContainer.addChild(titleLabel);
			headerContainer.mouseEnabled = false;
		}
		
		override public function drawBody():void {
			var circleB:Shape = new Shape();
			circleB.graphics.beginFill(0xffecd4, 1);
			circleB.graphics.drawCircle(30, 30, 33);
			circleB.graphics.endFill();
			headerContainer.addChild(circleB);
			
			var circleS:Shape = new Shape();
			circleS.graphics.beginFill(0x9ab3b0, 1);
			circleS.graphics.drawCircle(30, 30, 30);
			circleS.graphics.endFill();
			headerContainer.addChild(circleS);
			
			guestIcon  = new Bitmap(UserInterface.textures.guestEnergy);
			guestIcon.scaleX = guestIcon.scaleY = 0.6;
			guestIcon.smoothing = true;
			guestIcon.x = titleLabel.x - guestIcon.width - 15;
			guestIcon.y = titleLabel.y;
			headerContainer.addChild(guestIcon);
			
			drawDesc();
			drawReward();
			drawButton();
		}
		
		private function drawDesc():void {
			desc = Window.drawText(Locale.__e('flash:1382952380000'), {
				color:			0xffda72,
				borderColor:	0x613719,
				borderSize:		2,
				shadowColor:	0x613719,
				shadowSize:		2,
				fontSize:		34,
				width: 			180
			});
			desc.x = (settings.width - desc.textWidth) / 2;
			desc.y = 20;
			bodyContainer.addChild(desc);
		}
		
		private function drawReward():void {
			var item:GuestRewardItem = new GuestRewardItem(reward.sid, reward, this, true, false, false);
			bodyContainer.addChild(item);
			item.x = (settings.width - item.width) / 2;
			item.y = desc.y + desc.height + 5;
			//item.scaleX = item.scaleY = 1; 
			
			this.sid = item.sid; 
			this.count = item.count;
		}
		
		private function drawButton():void {
			var bttnSettings:Object = {
				caption:Locale.__e("flash:1382952380242"),
				bgColor:[0xf5d058, 0xeeb331],
				bevelColor:[0xfff17f, 0xbf7e1a],
				borderColor:[0xc0aa8d, 0x393a01],
				fontSize:30,
				fontBorderColor:0x814f31,
				width:140,
				height:48,
				hasDotes:false
			};
			priceBttn = new Button(bttnSettings);
			bodyContainer.addChild(priceBttn);
			priceBttn.x = (settings.width - priceBttn.width) / 2;
			priceBttn.y = (settings.height - priceBttn.height) - 40;
			priceBttn.addEventListener(MouseEvent.CLICK, takeReward);
		}
		
		private function takeReward(e:MouseEvent = null):void {
			var item:BonusItem = new BonusItem(sid, count);
			var point:Point = Window.localToGlobal(e.currentTarget);
			item.cashMove(point, App.self.windowContainer);
			App.user.stock.add(sid, count);
			close();
		}
	}
}