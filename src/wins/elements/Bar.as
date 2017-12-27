package wins.elements 
{

	import com.greensock.TweenMax;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.text.TextField;
	import ui.UserInterface;
	import wins.Window;	
	
	public class Bar extends Sprite{
		
		public var bar:Bitmap;
		public var icon:Bitmap;
		public var _counter:TextField;
		public var slider:Sprite = new Sprite();
		public var have:int;
		public var all:int;
		private var sliderBmd:String = "energySlider";
			
		public function Bar(counter:String, have:int, all:int, icon:String = "energyIcon", bar:String = "prograssBarBacking3", slider:String = "energySlider") {
			
			this.have = have;
			this.all = all;
			
			sliderBmd = slider;
			
			if(UserInterface.textures[icon] != undefined){
				this.icon = new Bitmap(UserInterface.textures[icon]);
			}else {
				this.icon = new Bitmap(Window.textures[icon]);
			}
			
			
			this.bar = Window.backingShort(119 , bar);
			//this.bar.scaleX = this.bar.scaleY = 1.5;
			this.bar.height = 22;
			this.bar.smoothing = true;
			_counter = Window.drawText(counter, {
				color:0xffffff,
				borderColor:0x764210,
				fontSize:24,
				textAlign:"center"
			});
			
			_counter.width = 82;
			_counter.height = _counter.textHeight;
			
			UserInterface.slider(this.slider, have, all, slider);
			
			this.icon.x = this.bar.x - 21;
			this.icon.y = this.bar.y - 6;
			
			this.slider.x = this.bar.x + 6;
			this.slider.y = this.bar.y + 4;
			
			_counter.x = this.bar.x + 17;
			_counter.y = this.bar.y - 1;
			
			addChild(this.bar);
			addChild(this.slider);
			addChild(this.icon);
			addChild(_counter);
			
		}
		
		public function set counter(counter:String):void {
			_counter.text = counter;
			UserInterface.slider(this.slider, have, all, sliderBmd);	
		}
		
		public function glowing():void {
			TweenMax.to(icon, 0.3, { glowFilter: { color:0xa56eee, alpha:0.8, strength: 2, blurX:12, blurY:12 }, onComplete:function():void {
				
				TweenMax.to(icon, 0.2, { glowFilter: { color:0xa56eee, alpha:0, strength: 2, blurX:12, blurY:12 }, onComplete:function():void {
					icon.filters = [];
				}});
			}});
		}
		
		public function get point():Object {
			return { x:x, y:y };
		}
		
	}

}