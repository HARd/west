package ui
{
	
	import com.greensock.TweenLite;
	import flash.display.Bitmap;
	import flash.display.GradientType;
	import flash.display.Sprite;
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.events.TimerEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.utils.Timer;
	import units.Unit;
	import wins.Window;
	
	public class Tips extends Sprite
	{
		private static const sizes:Object = {"90":1,'180':3,'240':5,'320':6};
		
		private static const fontSize:uint = 17;
		
		private static const padding:uint = 3;
		private static const color:uint = 0x000000;
		
		private static var textLabel:TextField;
		private static var titleLabel:TextField;
		private static var descLabel:TextField;
		private static var countLabel:TextField;
		
		private static var icon:Bitmap;
		private static var icons:Array = [];
		
		private var target:DisplayObject;
		
		private var timer:Timer = new Timer(400,1);
		private var tween:TweenLite;
		
		public static var self:Tips;
		
		public function Tips() 
		{
			
			textLabel = Window.drawText("", {
				color:0x413116,
				multiline:true,
				border:false,
				fontSize:fontSize,
				textLeading:-5
			});
			
			textLabel.wordWrap = true;
			
			titleLabel = Window.drawText("", {
				color:0x413116,
				multiline:true,
				border:false,
				fontSize:fontSize+5
			}); 
			
			descLabel = Window.drawText("", {
				color:0x413116,
				multiline:true,
				border:false,
				fontSize:fontSize+2
			}); 
			
			countLabel = Window.drawText("", {
				color:0xffdb65,
				borderColor:0x775002,
				multiline:true,
				fontSize:fontSize+3
			}); 
		}
		
		public function init():void {
			
			textLabel = Window.drawText("", {
				color:0x413116,
				multiline:true,
				border:false,
				fontSize:fontSize,
				textLeading: -5
			});
			
			textLabel.wordWrap = true;
			
			titleLabel = Window.drawText("", {
				color:0x413116,
				multiline:true,
				border:false,
				fontSize:fontSize+2
			}); 
		}
		
		private function dispose():void {
			timer.stop();
			if(tween){
				tween.complete(true);
				tween.kill();
				tween = null;
			}
			if(App.self.tipsContainer && App.self.tipsContainer.contains(this)){
				App.self.tipsContainer.removeChild(this);
			}
			while (numChildren > 0) {
				removeChildAt(0);
			}
			target = null;
			App.self.setOffTimer(rewrite);
		}
		
		public function hide():void {
			dispose();
		}
		
		public function show(object:DisplayObject):void {
			
			if (App.user.quests.tutorial) return;
			
			while (true) {
				if (!(object is LayerX) && object.parent != null) {
					object = object.parent;
				}else {
					if (!object.hasOwnProperty('tip') || object['tip'] == null ) {
						dispose();
						return;
					}
					break;
				}
			}
			
			if (object is Bitmap && Bitmap(object).bitmapData.getPixel(object.mouseX, object.mouseY) == 0) {
				dispose();
				return;
			}else if (object && object is Unit){
				var unit:Unit = object as Unit;
				var bmp:Bitmap = unit.bmp;
				if(bmp.bitmapData.getPixel(bmp.mouseX, bmp.mouseY) == 0) {
					dispose();
					return;			
				}
			}
			
			//Если мышка передвинулась, а объект не изменился, то только передвигаем подсказку
			if (target && target == object) {
				relocate();
				return;
			}else {
				dispose();
			}
			
			target = object;
			
			timer.addEventListener(TimerEvent.TIMER, onTimerEvent);
			timer.start();
		}
		
		private function onTimerEvent(e:TimerEvent):void {
			draw();
			alpha = 0;
			tween = TweenLite.to(this, 0.2, { alpha:1} );
		}
		
		private function draw():void {
			var iconScale:Number;
			
			var title:String = '';
			var text:String = '';
			var desc:String = '';
			var count:String = '';
			var counts:Array = [];
			var sprite:Sprite;
			if (target['tip'] is Function) {
				var tip:Object = target['tip']();
				if (!tip) return;
				
				title = tip.title || "";
				text = tip.text || "";
				desc = tip.desc || "";
				count = tip.count || "";
				counts = tip.counts || null;
				icon = tip.icon || null;
				icons = tip.icons || null;
				sprite = tip.sprite || null;
				iconScale = tip.iconScale || 1;
				
				if (tip.timer) {
					App.self.setOnTimer(rewrite);
				}
			}else {
				text = target['tip'] as String;
			}
			
			for (var w:String in sizes) {
				var textWidth:int = int(w);
				var lineCount:int = Math.round((text.length * fontSize) / textWidth);
				//if (lineCount < sizes['width']) {
					//break;
				//}
			}
			
			titleLabel.text = title;
			titleLabel.autoSize = TextFieldAutoSize.LEFT;
			
			textLabel.text = text;
			textLabel.autoSize = TextFieldAutoSize.LEFT;
			textLabel.width = textWidth;
			
			descLabel.text = desc;
			descLabel.autoSize = TextFieldAutoSize.LEFT;
			
			countLabel.text = count;
			descLabel.autoSize = TextFieldAutoSize.LEFT;
			
			var iconW:Number = 0;
			var icn:Bitmap;
			if (icon) iconW = icon.width * iconScale;
			if (icons && icons.length > 0) {
				for each (icn in icons) {
					iconW += icn.width * iconScale;
				}
			}
			var maxWidth:int = Math.max(titleLabel.textWidth, textLabel.textWidth, descLabel.textWidth + iconW + countLabel.textWidth + 11) + padding * 2;
			textLabel.width = maxWidth + 5;
			var iconH:Number = 0;
			if (icon) iconH = icon.height * iconScale; // 25;
			if (icons && icons.length > 0) {
				for each (icn in icons) {
					iconH = icn.height * iconScale;
				}
			}
			
			var maxHeight:int = titleLabel.height + textLabel.height + Math.max(descLabel.textHeight, iconH + 4, countLabel.textHeight)/*descLabel.textHeight + iconH*/;
			//maxWidth = Math.max(titleLabel.textWidth, textLabel.textWidth) + padding*2;
			
			var matrix:Matrix = new Matrix();
			matrix.createGradientBox(maxWidth + padding * 2, maxHeight + padding, (Math.PI / 180) * 90, 0, 0);
			
			var shape:Shape = new Shape();
			//shape.graphics.lineStyle(2, 0x2a2509, 0.8, true);//0xc4e7f3, 0xb8e4f3
			shape.graphics.beginGradientFill(GradientType.LINEAR, [0xeed4a6, 0xeed4a6], [1, 1], [0, 255], matrix);  //[0xe9e0ce, 0xd5c09f]
			shape.graphics.drawRoundRect(0, 0, maxWidth + padding * 2, maxHeight + padding, 15);
			shape.graphics.endFill();
			shape.filters = [new GlowFilter(0x4c4725, 1, 4, 4, 3, 1)];
			shape.alpha = 0.8;
			addChild(shape);
			
			titleLabel.x = padding;
			titleLabel.y = padding;
			
			textLabel.x = padding;
			textLabel.y = titleLabel.height;
			
			descLabel.x = padding;
			descLabel.y = textLabel.y + textLabel.height;
			
			if (sprite) {
				addChild(sprite);
			}
			
			else if (icon) {
				icon.scaleX = icon.scaleY = iconScale;
				icon.smoothing = true;
				
				addChild(icon);
				icon.x = descLabel.x + descLabel.textWidth + 8;
				icon.y = textLabel.y + textLabel.height + 2;
				countLabel.x = icon.x + icon.width + 3;
				countLabel.y = icon.y + (icon.height - countLabel.textHeight) / 2;
				
				descLabel.y = icon.y + (icon.height - descLabel.textHeight) / 2 - 3;
			}else {
				countLabel.x = descLabel.x;
				countLabel.y = descLabel.y + descLabel.height;
			}
			addChild(descLabel);
			addChild(countLabel);
			
			if(titleLabel.text != ""){
				addChild(titleLabel);
			}else {
				textLabel.y = padding;
			}
			
			addChild(textLabel);
			
			if (icons && icons.length > 0) {
				for (var i:int = 0; i < icons.length; i++) {
					var ic:Bitmap = new Bitmap(icons[i].bitmapData);
					
					ic.scaleX = ic.scaleY = iconScale;
					ic.smoothing = true;
					
					addChild(ic);
					ic.x = (descLabel.x + descLabel.textWidth + 8) * (i + 1);
					ic.y = textLabel.y + textLabel.height + 2;
					
					if (counts && counts.length > i) {
						var cntLabel:TextField = Window.drawText(counts[i], {
							color:0xffdb65,
							borderColor:0x775002,
							multiline:true,
							fontSize:fontSize+3
						});
						addChild(cntLabel);
						cntLabel.x = ic.x + ic.width + 3;
						cntLabel.y = ic.y + (ic.height - cntLabel.textHeight) / 2;
					}
				}
			}
			
			relocate();
			
			App.self.tipsContainer.addChild(this);
		}
		
		public function rewrite():void {
			
			var tip:Object = target['tip']();
			
			textLabel.text = tip.text;
			textLabel.autoSize = TextFieldAutoSize.LEFT;
			
			if (tip.timer != null && tip.timer == false) {
				var target:* = this.target;
				dispose();
				show(target);
				App.self.setOffTimer(rewrite);
			}
		}
		
		public function relocate():void {
			
			x = App.self.stage.mouseX + 32;
			y = App.self.stage.mouseY + 32;
			
			if (App.self.stage.stageWidth - App.self.stage.mouseX < width + 20) {
				x -= width + 45;
			}
			
			if (App.self.stage.stageHeight - App.self.stage.mouseY < height + 50) {
				y -= height + 45;
			}
		}
		
	}

}