package ui 
{
	import com.greensock.TweenLite;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.setTimeout;
	/**
	 * ...
	 * @author 
	 */
	public class CursorShleif extends Sprite
	{
		private var cursorSheilf:CursorShleif;
		
		public var countItems:int = 20;
		
		public var items:Array = [];
		
		private var target:*;
		
		private var isStart:Boolean = false;
		
		public function CursorShleif() 
		{
			if (cursorSheilf)
				throw new Error("Уже создали, прекрати");
			else
				cursorSheilf = this;
		}
		
		public function start(target:*):void
		{
			//if (isStart) return;
			//
			this.target = target;
			App.self.addChild(this);
			//drawItems();
			//App.self.stage.addEventListener(MouseEvent.MOUSE_MOVE, reDraw);
			
			doStaff();
		}
		
		private function doStaff():void
		{
			//var starSingl:MovieClip = new starSingle();
			//starSingl.x = App.self.mouseX;
			//starSingl.y = App.self.mouseY;
			//
			//addChild(starSingl);
			
			var finish:Object = Tutorial.getAbsCoords(target);
			
			var finishX:int = finish.x;
			var finishY:int = finish.y;
			
			var rnd:int = 100//Math.random() * 50 + 80;
			
			var _scale:Number = Math.random() + 0.2;
			
			var starSingl:MovieClip = new starSingle();
			starSingl.x = App.self.mouseX - 4;
			starSingl.y = App.self.mouseY;
			//starSingl.scaleX = starSingl.scaleY = _scale;
			
			addChild(starSingl);
			
			var starSingl2:MovieClip = new starSingle();
			starSingl2.x = App.self.mouseX + 4;
			starSingl2.y = App.self.mouseY;
			//starSingl2.scaleX = starSingl2.scaleY = _scale;
			
			addChild(starSingl2);
			
			//var koef:int = 1;
			//
			//if (i == 1)
				//koef = -1;
				
			//if (Math.random() < 0.5)
				//koef = -1;
			
			
				
			//var centerP1X:int = (App.self.mouseX + finish.x) / 2 + -4;
			//var centerP1Y:int = (App.self.mouseY + finish.y) / 2 + rnd / 2;
			
			var centerP1_2X:int = (App.self.mouseX + finish.x) / 2 + rnd*(-1);
			var centerP1_2Y:int = (App.self.mouseY + finish.y) / 2 + rnd / 2;
			
			//var centerP2X:int = (App.self.mouseX + finish.x) / 2 + 4;
			//var centerP2Y:int = (App.self.mouseY + finish.y) / 2 + rnd / 2 * ( -1);
			
			var centerP2_2X:int = (App.self.mouseX + finish.x) / 2 + rnd;
			var centerP2_2Y:int = (App.self.mouseY + finish.y) / 2 + rnd/2 * (-1);
			
			
			TweenLite.to(starSingl, 1.5, {bezier:[{x:centerP1_2X, y:centerP1_2Y}/*, {x:centerP1_2X, y:centerP1_2Y}*/, {x:finishX, y:finishY}]/*, x:finishX, y:finishY*/, onComplete:function():void { if (starSingl) cursorSheilf.removeChild(starSingl); starSingl = null; }} );
			TweenLite.to(starSingl2, 1.5, {bezier:[{x:centerP2_2X, y:centerP2_2Y}/*, {x:centerP2_2X, y:centerP2_2Y}*/, {x:finishX, y:finishY}]/*, x:finishX, y:finishY*/, onComplete:function():void { if (starSingl2) cursorSheilf.removeChild(starSingl2); starSingl2 = null; }} );
			
			setTimeout(doStaff, 90);
			
		}
		
		public function stop():void
		{
			//if (!isStart) return;
			//
			//App.self.stage.removeEventListener(MouseEvent.MOUSE_MOVE, reDraw);
			//removeItems();
			//items = null;
			//App.self.removeChild(this);
			//target = null;
		}
		
		private function drawItems():void 
		{
			var itemScale:Number = 0.2;
			
			var coords:Array = [];
			
			var X:int = App.self.mouseX;
			var Y:int = App.self.mouseY;
			
			var finish:Object = Tutorial.getAbsCoords(target);
			
			var finishX:int = finish.x;
			var finishY:int = finish.y;
			
			var distX:int = int(X - finishX);
			var distY:int = int(Y - finishY);
			
			var dist:int = Math.sqrt(distX * distX + distY * distY);
			
			var periodX:int = int(distX / countItems);
			var periodY:int = int(distY / countItems);
			
			for (i = 0; i <= countItems; i++) {
				coords.push( { x:X-periodX, y:Y-periodY } );
				X -= periodX;
				Y -= periodY;
			}
			
			coords = coords.reverse();
			coords.shift();
			
			for (var i:int = 0; i < countItems; i++ ) {
				var item:MovieClip = new Item();
				item.scaleX = item.scaleY = itemScale;
				
				item.x = coords[i].x;
				item.y = coords[i].y;
				
				addChild(item);
				
				itemScale += 0.04;
				
				items.push(item);
			}
		}
		
		public function reDraw(e:MouseEvent):void
		{
			var coords:Array = [];
			
			var X:int = App.self.mouseX;
			var Y:int = App.self.mouseY;
			
			var finish:Object = Tutorial.getAbsCoords(target);
			
			var finishX:int = finish.x;
			var finishY:int = finish.y;
			
			var distX:int = int(X - finishX);
			var distY:int = int(Y - finishY);
			
			var dist:int = Math.sqrt(distX * distX + distY * distY);
			
			var periodX:int = int(distX / countItems);
			var periodY:int = int(distY / countItems);
			
			for (i = 0; i <= countItems; i++) {
				coords.push( { x:X-periodX, y:Y-periodY } );
				X -= periodX;
				Y -= periodY;
			}
			
			coords = coords.reverse();
			coords.shift();
			
			var time:Number = 0.1;
			
			for (var i:int = 0; i < items.length; i++ ) {
				var item:Item = items[i];
				item.move(coords[i].x, coords[i].y, time);
				
				if(i < items.length/2)
					time += 0.08;
				else	
					time -= 0.08;
			}
		}
		
		private function removeItems():void
		{
			for (var i:int = 0; i < items.length; i++ ) {
				var item:Item = items[i];
				item.dispose();
				item = null;
			}
			items = [];
		}
		
		public function dispose():void
		{
			App.self.stage.removeEventListener(MouseEvent.MOUSE_MOVE, reDraw);
			removeItems();
			items = null;
			App.self.removeChild(this);
		}
		
	}

}
import com.greensock.easing.Back;
import com.greensock.TweenLite;

internal class Item extends star {
	
	private var tween:TweenLite;
	public function Item() {
		
	}
	
	public function move(_x:int, _y:int, time:Number):void
	{
		if (tween) {
			tween.kill();
			tween = null;
		}
	
		tween = TweenLite.to(this, time, {x:_x, y:_y, ease:Back.easeOut});
	}
	
	public function dispose():void
	{
		if (tween) {
			tween.kill();
			tween = null;
		}
		
		if (this.parent)
			this.parent.removeChild(this);
	}
	

}
	



