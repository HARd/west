package wins
{
	import buttons.MoneyButton;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	
	/**
	 * ...
	 * @author 
	 */
	public class ProgressBar extends Sprite
	{
		private var barL:Bitmap = new Bitmap(Window.textures.progressBar);
		private var barM:Bitmap;
		private var barR:Bitmap;
		
		//private var cookingPanelBarBg:Bitmap = new Bitmap(Window.textures.cookingPanelBarBg);
		
		private var buyBttn:MoneyButton;
		public var timer:TextField;
		private var win:*;
		private var w:int;
		private var maska:Shape;
		
		private var Xs:int = 0;
		private var Xf:int = 0;
		
		public var bar:CookingPanelBar;
		private var delta:int;
		private var barWidth:int;
		
		private var timeFormat:uint = TimeConverter.H_M_S;
		
		private var isTimer:Boolean = true;
		
		private var timeSize:int;
		private var timeColor:int;
		private var timeborderColor:int;
		
		private var typeLine:String;
		
		public function ProgressBar(settings:Object)
		{
			
			barM = new Bitmap(new BitmapData(1,barL.bitmapData.height,true,0x33ff0000));
			barM.bitmapData.copyPixels(barL.bitmapData, new Rectangle(barL.bitmapData.width - 1, 0, barL.bitmapData.width, barL.bitmapData.height), new Point());
			barR = new Bitmap(new BitmapData(barL.bitmapData.width,barL.bitmapData.height,true,0x33ff0000));
			barR.bitmapData.draw(barL.bitmapData, new Matrix(-1, 0, 0, 1));
			
			this.w = settings.width;
			this.win = settings.win;
			timeSize = settings.timeSize || 28;
			timeborderColor = /*settings.borderColor || */0x613200;
			timeColor = /*settings.color || 0x38342c*/0xffffff;
			typeLine = settings.typeLine || 'progressBarLine';
			
			if(settings.hasOwnProperty('isTimer'))isTimer = settings.isTimer;
			
			timeFormat = settings.timeFormat || TimeConverter.H_M_S
			
			var container:Sprite = new Sprite();
			container.addChild(barL);
			container.addChild(barM);
			container.addChild(barR);
			
			var mediumBitmapData:BitmapData = new BitmapData(1, barM.height, true, 0);
			mediumBitmapData.copyPixels(barR.bitmapData, new Rectangle(0, 0, 1, barR.height), new Point(0, 0)); 
			barM.bitmapData = mediumBitmapData;
			
			barR.x = w - barL.width;
			barM.x = barL.width;
			barM.width = w - barR.width - barL.width;
			barM.y = 0;
			
			var bgBarBMD:BitmapData = new BitmapData(container.width, container.height, true, 0);
			bgBarBMD.draw(container);
			
			var bgBar:Bitmap = new Bitmap(bgBarBMD);
			container = null;
			//addChild(bgBar);
			
			barWidth = settings.width - 24;
			bar = new CookingPanelBar(barWidth, typeLine);
			addChild(bar);
			
			bar.x = 12;
			bar.y = 9;
			
			delta = -bar.width + 12;
			
			maska = new Shape();
			maska.graphics.beginFill(0x000000, 0.6);
			maska.graphics.drawRect(0, 0, barWidth+2, bar.height+1);
			maska.graphics.endFill();
			addChild(maska);
			maska.x = 12; 
			maska.y = 9;
			
			bar.mask = maska;
			bar.visible = false;
		
			if(isTimer){
				timer = Window.drawText(TimeConverter.timeToStr(127), {
					width:			w,
					color:			timeColor,
					borderColor:	timeborderColor,
					fontSize:		timeSize,
					textAlign:		'center',
					shadowSize:		2
				});
				
				addChild(timer);
				timer.y = bar.height - timer.textHeight / 2 - 2;
				
				if (timeFormat == TimeConverter.H_M_S)
					timer.x = settings.width / 2 - 24;
				else
					timer.x = settings.width / 2 - 16;
				
				timer.x = (settings.width - timer.width) / 2;
				timer.height = timer.textHeight;
				
				timer.visible = false;
			}
		}
		
		public function start():void
		{
			if(timer) timer.visible = true;
			bar.visible = true;
		}
		
		public function set time(value:int):void
		{
			if (timeFormat == 3) {		// Percents
				timer.text = String(value) + ' %';
			}else if(timeFormat == TimeConverter.H_M_S) {
				timer.text = TimeConverter.timeToStr(value);
			}else{
				timer.text = TimeConverter.minutesToStr(value);
			}
		}
		
		public function set progress(value:Number):void {
			maska.width = barWidth * value;
		}
		public function get progress():Number {
			return maska.width / barWidth;
		}
		
		public function dispose():void
		{
			win = null;
		}
	}
}

import flash.display.Bitmap;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.Event;
import wins.Window;

internal class CookingPanelBar extends Sprite 
{
	
	public function CookingPanelBar(_width:int, typeLine:String)
	{
		var progress:Bitmap = Window.backingShort(_width, typeLine);
		addChild(progress);
	}
	
}

