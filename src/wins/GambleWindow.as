package wins 
{
	import buttons.Button;
	import buttons.MenuButton;
	import buttons.MoneyButton;
	import com.greensock.easing.Strong;
	import com.greensock.TweenLite;
	import com.greensock.TweenMax;
	import core.Load;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.utils.setTimeout;
	import ui.Hints;
	import ui.UserInterface;
	import units.Hut;

	public class GambleWindow extends Window
	{
		public var playBttn:MoneyButton;
		public var playFreeBttn:Button;
		public var items:Array = [];
		
		public function GambleWindow(settings:Object = null)
		{
			if (settings == null) {
				settings = new Object();
			}
			
			settings['width'] = 380;
			settings['height'] = 320;
			settings['faderAsClose'] = false;
			settings['faderClickable'] = false;
			settings['fontSize'] = 54;
			if (settings.hasOwnProperty('target'))
				settings['title'] = settings.target.info.title;
			else if (settings.hasOwnProperty('sID'))
				settings['title'] = App.data.storage[settings.sID].title;
			
			settings['hasPaginator'] = false;
			settings['hasButtons'] = false;
				
			//if (!settings.target.tribute)
				//settings['height'] = 350;
				
			if (settings.hasOwnProperty('target'))
				settings.content = settings.target.info.items;
			else if (settings.hasOwnProperty('sID'))
				settings.content = App.data.storage[settings.sID].items;
				
			super(settings);
		}
		
		public var dX:uint = 160
		override public function drawBody():void {
			if (exit != null)
			{
				exit.x = background.x + background.width - exit.width * (3 / 4) - 15;
			}
			
			var text:String = Locale.__e("flash:1382952380126");
			
			var descriptionLabel:TextField = drawText(text, {
				fontSize:22,
				autoSize:"center",
				textAlign:"center",
				color:0x78370f,
				borderColor:0xf5f3e4,
				borderSize:5,
				width:350,
				wrap:true,
				multiline:true
			});
			
			descriptionLabel.wordWrap = true;
			descriptionLabel.width = back.width - 75;
			descriptionLabel.x = background.x + (background.width - descriptionLabel.width) / 2;
			descriptionLabel.y = back.y + 30;
			
			bodyContainer.addChild(descriptionLabel);
			drawBttns();
			Load.loading(Config.getImageIcon('Gamble', 'wheel'), drawWheel);
			
			if (settings.hasOwnProperty('target')) {
				if (!settings.target.tribute) {
					playFreeBttn.visible = false;
					playBttn.visible = true;
					drawTime();
				}
				else
				{
					playFreeBttn.visible = true;
					playBttn.visible = false;
				}
			}
			
			bodyContainer.addChild(wheel);
			drawArrow();
		}
		
		private var timeConteiner:Sprite;
		private var timerText:TextField;
		private var descriptionLabel:TextField;
		public function drawTime():void {
			
			timeConteiner = new Sprite();
						
			descriptionLabel = drawText(Locale.__e('flash:1382952380127'), {
				fontSize:20,
				textAlign:"center",
				color:0xfff9fa,
				borderColor:0x4c3604
			});
			
			descriptionLabel.width = 230;
			descriptionLabel.x = (descriptionLabel.width - 230)/2;
			descriptionLabel.y = 25;
			timeConteiner.addChild(descriptionLabel);
			
			var time:int = App.nextMidnight - App.time;
			timerText = Window.drawText(TimeConverter.timeToStr(time), {
				color:0xffdb4b,
				letterSpacing:3,
				textAlign:"center",
				fontSize:32,
				borderColor:0x492318
			});
			timerText.width = 230;
			timerText.y = 53;
			timerText.x = 0;
			timeConteiner.addChild(timerText);
			
			timeConteiner.x = background.x + (background.width - timeConteiner.width)/2;
			timeConteiner.y = back.width/2 + back.y;
			bodyContainer.addChild(timeConteiner);
			
			App.self.setOnTimer(updateDuration);
		}
		
		private function updateDuration():void {
			var time:int = App.nextMidnight - App.time;
				timerText.text = TimeConverter.timeToStr(time);
			
			if (time <= 0 || settings.target.played == 0) {
				descriptionLabel.visible = false;
				timerText.visible = false;
				playFreeBttn.visible = true;
				playBttn.visible = false;
			}
		}
		
		override public function drawTitle():void {
			titleLabel = titleText( {
				title				: settings.title,
				color				: settings.fontColor,
				multiline			: settings.multiline,			
				fontSize			: settings.fontSize,				
				textLeading	 		: settings.textLeading,				
				borderColor 		: settings.fontBorderColor,			
				borderSize 			: settings.fontBorderSize,	
				shadowColor			: settings.shadowColor,
				width				: settings.width - 140,
				textAlign			: 'center',
				sharpness 			: 50,
				thickness			: 50,
				border				: true,
				shadowSize			:4,
				autoSize			:'left'
			});
			titleLabel.x = (settings.width - titleLabel.width) * .5;
			titleLabel.y = - 15;
			titleLabel.mouseChildren = titleLabel.mouseEnabled = false;
			headerContainer.addChild(titleLabel);
			headerContainer.y = 17;
			headerContainer.mouseEnabled = false;
		}
		
		public var back:Bitmap;
		override public function drawBackground():void
		{
			background = Window.backing(settings.width, settings.height, 50, "alertBacking");
			layer.addChild(background);
			background.x += 220;
			titleLabel.x = background.x + ((background.width - titleLabel.width) / 2) + 70;
			
			back = Window.backing(background.width - 55, 180, 30, 'dialogueBacking');
			back.x = (background.width - back.width)/2 + 220;
			back.y = titleLabel.y + 10;
			back.alpha = 0;
			
			//titleLabel.x = back.x + ((back.width - titleLabel.width) / 2) + 55;
			//titleLabel.y -= 20;
			//bodyContainer.addChild(titleLabel);
			bodyContainer.addChild(back);
		}
		
		private function drawBttns():void {
			if (!settings.hasOwnProperty('target')) return;
			playBttn = new MoneyButton({
				caption		:Locale.__e("flash:1382952380128"),
				width		:170,
				height		:47,	
				fontSize	:26,
				countText	:settings.target.info.skip
			});
			
			playFreeBttn = new Button( {
				caption		:Locale.__e("flash:1382952380129"),
				width		:170,
				height		:42
			});
			
			bodyContainer.addChild(playBttn);
			bodyContainer.addChild(playFreeBttn);
			
			playBttn.x = background.x + (background.width - playBttn.width) / 2;
			playBttn.y = back.y + back.height - playBttn.height - 20;
			
			playFreeBttn.x = playBttn.x;
			playFreeBttn.y = playBttn.y;
			
			playBttn.addEventListener(MouseEvent.CLICK, onPlayClick);
			playFreeBttn.addEventListener(MouseEvent.CLICK, onPlayFreeClick);
			
			playFreeBttn.state = Button.DISABLED;	
			playBttn.state = Button.DISABLED;	
		}
		
		public var wheel:Sprite = new Sprite();
		private function drawWheel(data:*):void {
			var wheelImg:Bitmap = new Bitmap(data.bitmapData);
			wheelImg.smoothing = true;
			wheelImg.x = -wheelImg.width / 2;
			wheelImg.y = -wheelImg.height / 2;
			
			wheel.addChild(wheelImg);
			wheel.rotation += (360 / 12) / 2;
			wheel.x = 100;
			wheel.y = settings.height / 2 - 20;
			
			drawItems();
			
			if (!settings.hasOwnProperty('target')) return;
			
			if (!settings.target.tribute)
				wheel.y = settings.height / 2 - 40
				
			playFreeBttn.state = Button.NORMAL;	
			playBttn.state = Button.NORMAL;	
			
			//titleLabel.x = (settings.width - titleLabel.width) * .5 + wheelImg.width / 1.5;
		}
		
		public var arrow:Bitmap
		private function drawArrow():void {
			arrow = new Bitmap(UserInterface.textures.wheelArrow);
			bodyContainer.addChild(arrow);
			arrow.x += 78;
			arrow.y -= 92;
		}
		
		private function drawItems():void {
			
			var num:uint = 0;
			for (var id:* in settings.content) {
				var itm:* = settings.content[id];
				var sid:uint;
				var count:uint;
				for (var i:* in itm) {
					sid = i;
					count = itm[i];
				}
				var item:WheelItem = new WheelItem(sid, count, this);
				items.push(item);
				
				wheel.addChild(item);
				var angle:Number = num * 360 / 12;
				item.angle 		= angle;
				item.rotation 	= angle;
				num ++;
			}
		}
		
		private function onPlayFreeClick(e:MouseEvent):void {
			
			if (e.currentTarget.mode == Button.DISABLED)
				return;
				
			exit.visible = false;
			e.currentTarget.state = Button.DISABLED;
			settings.onPlay(0, onPlayComplete);
		}
		
		private function onPlayClick(e:MouseEvent):void {
			if (e.currentTarget.mode == Button.DISABLED)
				return;
			
			exit.visible = false;	
			e.currentTarget.state = Button.DISABLED;
			var X:Number = App.self.mouseX - e.currentTarget.mouseX + e.currentTarget.width / 2;
			var Y:Number = App.self.mouseY - e.currentTarget.mouseY;
				
			Hints.minus(Stock.FANT, settings.target.info.skip, new Point(X, Y), false, App.self.tipsContainer);
			
			settings.onPlay(1, onPlayComplete);
		}
		
		public function onPlayComplete(bonus:Object):void {
			var count:uint;
			for (var sID:* in bonus) {
				count = bonus[sID];
			}
			
			for each(var item:* in items) {
				if (item.sID == sID && item.count == count) {
					setWheelStopPoint(item);
				}
			}
		}
		
		private var winItem:WheelItem;
		private function setWheelStopPoint(item:WheelItem):void {
			
			trace(App.data.storage[item.sID].title);
			trace(item.count);
			trace(item.angle);
			winItem = item;
			
			var needRot:Number = 0 - item.angle + int(Math.random()*14) - 97;
			var circles:int = int(Math.random() * 5) + 3;
			var time:Number = 8;
			
			setTimeout(takeReward, (time - 1)*1000);
			TweenLite.to(wheel, time, { rotation:needRot + circles*360 , ease:Strong.easeOut} );
		}
		
		private function takeReward():void {
			winItem.take();
			exit.visible = true;
		}
		
		public function onWheelStop():void
		{
			playBttn.state = Button.NORMAL;
			playBttn.visible = true;
			playFreeBttn.visible = false;
			if (timerText) timerText.visible = true;
			if (descriptionLabel) descriptionLabel.visible = true;

			
		}
		
		public override function dispose():void{
			if(playFreeBttn) playFreeBttn.removeEventListener(MouseEvent.CLICK, onPlayFreeClick);
			if (playBttn) playBttn.removeEventListener(MouseEvent.CLICK, onPlayClick);
			App.self.setOffTimer(updateDuration);
			super.dispose();
		}
	}
}

import core.Load;
import core.Numbers;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.filters.GlowFilter;
import flash.geom.Point;
import flash.text.TextField;
import ui.UserInterface;
import wins.Window;

internal class WheelItem extends Sprite
{
	private var text:TextField;
	private var icon:Bitmap;
	public var sID:uint;
	public var count:uint;
	public var angle:Number;
	public var bitmap:Bitmap;
	public var window:*;
	
	public function WheelItem(sID:uint, count:uint, window:*) {
		
		this.window = window;
		//for (var sID:* in data) {
			//var count:uint = data[sID];
		//}
		
		this.sID = sID;
		
		var material:Object = App.data.storage[sID];
		this.count = count;
		text = Window.drawText(Numbers.moneyFormat(count), {
			color:0xffffff,
			borderColor:0x3f3430,
			fontSize:22,
			textAlign:"center"
		});
		text.width = 80;
		text.height = text.textHeight;
		
		var cont:Sprite = new Sprite();
		cont.addChild(text);
		
		var bmd:BitmapData = new BitmapData(text.width, text.height, true, 0);
		bmd.draw(cont);
		
		bitmap = new Bitmap(bmd);
		addChild(bitmap);
		bitmap.x = 46;
		bitmap.y = -bitmap.height / 2;
		bitmap.smoothing = true;
		
		Load.loading(Config.getIcon(material.type, material.preview), onLoad);
	}
	
	public function take():void {
		
		var that:* = this;
		App.ui.flashGlowing(this, 0xFFFF00, function():void {
			var item:BonusItem = new BonusItem(that.sID, that.count);
			//var point:Point = Window.localToGlobal(that);
			var point:Point = new Point();
			
			point.x = window.width/2 - 25;
			point.y = window.height/2 - 150;
			
			App.user.stock.add(sID, count);
			
			item.cashMove(point, App.self.windowContainer);
			
			that.window.onWheelStop();
		});
	}
	
	private function onLoad(data:Bitmap):void 
	{
		icon = new Bitmap(data.bitmapData);
		icon.scaleX = icon.scaleY = 0.45;
		icon.smoothing = true;
		addChild(icon);
		icon.x = bitmap.x + bitmap.width + 10 - icon.width/2;
		icon.y = -icon.height / 2;
		icon.filters = [new GlowFilter(0xffffff, 1)];
	}
}