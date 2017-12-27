package wins.elements 
{
	import buttons.Button;
	import com.greensock.TweenMax;
	import core.Load;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.BlurFilter;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.text.TextField;
	import ui.Cursor;
	import wins.Window;

	public class TimerUnit extends LayerX {
		
		public var background:Bitmap;
		public var bitmap:Bitmap;
		public var titleLabel:TextField;
		public var timeLabel:TextField;
		public var time:Object = {};
		
		private var settings:Object = {
			width:200,
			height:100,
			time:{started:0,duration:0},
			backGround:'collectionRewardBacking',
			timerTextPars: {
				fontSize:34,
				textAlign:"center",
				letterSpacing:3,
				color:0xffe779,
				borderColor:0x6f3817,
				shadowColor:0x6f3817,
				shadowSize:1
			},
			titleTextPars: {
				fontSize:26,
				textAlign:"center",
				//letterSpacing:3,
				color:0xfffbe2,
				borderColor:0x814f31,
				shadowColor:0x814f31,
				shadowSize:1
			}
		};
		
		public function TimerUnit(settings:Object = null) {
			for (var prop:* in settings) {
				this.settings[prop] = settings[prop];
			}
			time.started = settings.time.started;
			time.duration = settings.time.duration;
			if(settings.backGround != 'none'){
				drawBackground();
			}
				
			if(settings.hasOwnProperty('label'))
				drawTitle(settings.label, settings.titleColor, settings.titleBorderColor, settings.titleFontSize);
			else
				drawTitle();
				
			if(settings.hasOwnProperty('pX') || settings.hasOwnProperty('pY'))
				drawTime(settings.pX, settings.pY, settings.color, settings.borderColor, settings.fontSize);
			else
				drawTime();
				
			if (settings.backGround == 'glow') {
				if (!timeLabel)
					return;
				background.height = settings.height + titleLabel.height / 2;
				background.width = Math.max(settings.width,titleLabel.width,timeLabel.width);
				background.y = titleLabel.y;
			}
		}
		
		public function drawTitle(title:String = 'flash:1393581955601', color:uint = 0xfffbe2, borderColor:uint = 0x6f3817, fontSize:int = 34):void {
			if (title== null || title== '')
				title = 'flash:1393581955601';
			
			settings.titleTextPars.fontSize = fontSize;
			settings.titleTextPars.color=color;
			settings.titleTextPars.borderColor = borderColor;
			
			titleLabel = Window.drawText(Locale.__e(title), settings.titleTextPars);
			titleLabel.width = titleLabel.textWidth + 5;
			titleLabel.height = titleLabel.textHeight + 5;
			titleLabel.x = (settings.width - titleLabel.width) / 2;
			titleLabel.y = -titleLabel.height / 2;
			
			addChild(titleLabel);
		}
		
		public function start():void {
			this.visible = true;
			App.self.setOnTimer(updateDuration);
		}
		
		public function drawBackground():void {
			if (settings.backGround == 'none')
				return;
			
			if (settings.backGround == 'glow') {
				background = new Bitmap(Window.textures[settings.backGround]);
			}else{
				background = Window.backing(settings.width, settings.height, 25, settings.backGround);
			}
			addChild(background);
		}
		
		public function drawTime(pX:int = 3141251, pY:int = 3141251, color:uint = 0xffe779, borderColor:uint = 0x6f3817, fontSize:int = 34):void {
			//потом поменять обратно на 3600
			//var timeVal:int = time.duration * 3600 - (App.time - time.started);
			var timeVal:int = time.duration * 3600 - (App.time - time.started);
			settings.timerTextPars['width'] = settings.width;
			settings.timerTextPars.color = color;
			settings.timerTextPars.borderColor = borderColor;
			settings.timerTextPars.fontSize = fontSize;
			
			timeLabel = Window.drawText(TimeConverter.timeToStr(timeVal), settings.timerTextPars);
			addChild(timeLabel);
			
			if (pX != 3141251 && pY != 3141251)
			{
				timeLabel.x = titleLabel.x + titleLabel.width + pX;
				timeLabel.y = titleLabel.y - titleLabel.height / 2+ pY;
			}
			else
				timeLabel.y = (settings.height - timeLabel.height) / 2 + 2;
		}
		
		public function updateDuration():void {
			//var timeVal:int = time.duration * 3600 - (App.time - time.started);
			var timeVal:int = time.duration * 3600 - (App.time - time.started);
			timeLabel.text = TimeConverter.timeToStr(timeVal);
			if (timeVal <= 0) {
				App.self.setOffTimer(updateDuration);
				if (settings.hasOwnProperty('callback')) {
					settings['callback']();
				}else {
					this.visible = false;
				}
			}
		}
		
	}
}	