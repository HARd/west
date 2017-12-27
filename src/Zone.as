package 
{
	import com.demonsters.debugger.IMonsterDebuggerConnection;
	import com.greensock.TweenLite;
	import core.IsoConvert;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.TimerEvent;
	import flash.filters.BlurFilter;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.sampler.NewObjectSample;
	import flash.text.TextField;
	import flash.utils.Timer;
	import wins.Window;
	
	/**
	 * ...
	 * @author 
	 */
	public class Zone extends LayerX
	{
		public static var tochedZone:Zone = null;
		public static var openZoneImage:BitmapData = null;
		
		public var fader:Bitmap;
		public var border:Shape;
		
		private var dX:Number;
		private var dY:Number;
		
		private var minX:Number = 0;
		private var minY:Number = 0;
		
		private var informer:Sprite;
		private var sID:uint;
		
		private var glowing:GlowFilter = new GlowFilter(0x88ffed, 1, 1, 1, 4, 1, false, true);
		private var showed:Boolean = false;
		private var timer:Timer = new Timer(50, 1);
		
		public function Zone(sID:uint, obj:Object)
		{
			this.sID = sID;
			fader = drawFader(obj.points);
			
			addChild(fader);
			
			if (sID == 232) {
				minX -= 40;
				minY -= 40;
			}
			
			this.x = dX + minX;
			this.y = dY + minY;
			
			App.map.mTreasure.addChild(this);
			this.mouseEnabled = false;
			this.mouseChildren = false;
			
			drawInformer();
			timer.addEventListener(TimerEvent.TIMER, showInformer);
			
			App.map.mTreasure.mouseEnabled = false;
		}
		
		private function drawInformer():void
		{
			if(App.user.mode == User.GUEST) return;
			
			informer = new Sprite()
			var container:Sprite = new Sprite();
			informer.addChild(container);
			
			var textSettings:Object = 
			{
				fontSize	:40,
				textAlign	:'center',
				multiline	:true,
				textLeading	:-6,
				color		:0xFFFFFF,
				borderColor	:0x2b3b64
			}
			
			var titleText:TextField = Window.drawText(App.data.storage[sID].title, textSettings);
			titleText.width = 120;
			titleText.wordWrap = true;
			titleText.height = titleText.textHeight + 5;				
			
			var bg:Bitmap = Window.backing2(220, titleText.height + 50, 45, "questsSmallBackingTopPiece", "questsSmallBackingBottomPiece");
			container.addChildAt(bg, 0);
			//Window.addMirrowObjs(container, 'diamondsTop', bg.width / 2 - 50, bg.width / 2 + 50, -10, true, true);
			//Window.addMirrowObjs(container, 'diamonds', -30, bg.width + 30, bg.height - 80);
			
			titleText.x = (bg.width - titleText.width)/2 - 34;
			titleText.y = (bg.height - titleText.height)/2 - 16;
			
			container.scaleX = container.scaleY = 0.7;
			
			informer.addChild(titleText);
			
			addChild(informer);	
			informer.x = (fader.width - informer.width) / 2;
			informer.y = (fader.height - informer.height) / 2;
			
			if (App.user.quests.tutorial) {
				informer.visible = false;
			}
			
		}
		
		private function drawElements(array:Array):void
		{
			for (var i:int = 0; i < array.length; i++)
			{
				var glow:Shape = new Shape();
				glow.graphics.beginFill(0x8de8b6, 1);//
				glow.graphics.drawEllipse(0, 0, 300, 150);
				glow.graphics.endFill();
				
				glow.filters = [new BlurFilter(100, 100, 3)];
				
				var padding:int = 80;
				var cont:Sprite = new Sprite();
				cont.addChild(glow);
				glow.x = padding;
				glow.y = padding;
				
				var scale:Number = (int(Math.random() * 50) + 50) / 100;
				glow.scaleX = glow.scaleY = scale;
				
				var bmd:BitmapData = new BitmapData(glow.width+2*padding, glow.height+2*padding, true, 0);
				bmd.draw(cont);
				
				var bitmap:Bitmap = new Bitmap(bmd);
				var point:Object = IsoConvert.isoToScreen(array[i].x, array[i].z, true);
				var copyPoint:Point = new Point(point.x - dX - minX - bitmap.width/2, point.y - dY - minY - bitmap.height/2)
				//var copyPoint:Point = new Point(0, 0);
				fader.bitmapData.copyPixels(bmd, bmd.rect, copyPoint, null, null, true);
			}
		}
		
		public function dispose():void
		{
			//App.map.mLand.removeChild(border);
			//App.map.mTreasure.removeChild(fader);
			App.map.mTreasure.removeChild(this);
			timer.removeEventListener(TimerEvent.TIMER, showInformer);
		}
		
		private function drawFader(array:Array):Bitmap
		{
			var p0:Object = array[0];
			var point0:Object = IsoConvert.isoToScreen(p0.x, p0.z, true);
				
			dX = point0.x;
			dY = point0.y;
			
			var p:Object;
			var point:Object;
			
			var fader:Sprite = new Sprite();
			fader.graphics.beginFill(0x8de8b6, 0.5);
			fader.graphics.moveTo(point0.x - dX, point0.y - dY);
			
			var L:uint = array.length;
			for (var i:int = 1; i < L; i++)
			{
				p = array[i];
				point = IsoConvert.isoToScreen(p.x, p.z, true);
				fader.graphics.lineTo(point.x - dX, point.y - dY);
				
				if (point.x - dX < minX) minX = point.x - dX;
				if (point.y - dY < minY) minY = point.y - dY;
			}
			
			fader.graphics.lineTo(point0.x - dX, point0.y - dY);
			fader.graphics.endFill();
			
			fader.filters = [ new BlurFilter(70, 70, 1) ];
			
			//var bmd:BitmapData = new BitmapData(cont.width, cont.height, true, 0);
			//bmd.draw(cont);
			
			var bitmap:Bitmap = new Bitmap(snapClip(fader));
			//bitmap.blendMode = BlendMode.MULTIPLY;
			
			return bitmap;
		}
		
		private function drawBorder(array:Array):Shape
		{
			var p0:Object = array[0];
			var point0:Object = IsoConvert.isoToScreen(p0.x, p0.z, true);
				
			var p:Object;
			var point:Object;
			
			var border:Shape = new Shape();
			border.graphics.lineStyle(2, 0xFFFF00, 1);
			border.graphics.moveTo(point0.x, point0.y);
			
			var L:uint = array.length;
			for (var i:int = 1; i < L; i++)
			{
				p = array[i];
				point = IsoConvert.isoToScreen(p.x, p.z, true);
				border.graphics.lineTo(point.x, point.y);
			}
			
			border.graphics.lineTo(point0.x, point0.y);
			border.graphics.endFill();
			
			return border;
		}
		
		public function set touch(value:Boolean):void
		{
			if (App.user.mode == User.GUEST) return;
			
			if (value){
				timer.start();
			}else{
				timer.reset();
				hideInformer();
			}
		}
		
		private function showInformer(e:* = null):void
		{
			if (showed || App.user.mode == User.GUEST) return;
			showed = true;
			
			if(!App.user.quests.tutorial)
			informer.visible = true;
			//informer.alpha = 0;
			///TweenLite.to(informer, 1, { alpha:1 } );
			fader.filters = [glowing];
		}
		
		private function hideInformer():void
		{
			if (!showed) return;
			showed = false;
			
			//informer.visible = false;
			fader.filters = [];
		}
		
		public static function untouches():void
		{
			var world:World;
			
			try{
				if (App.user.mode == User.OWNER)
					world = App.user.world;
				else	
					world = App.owner.world;
					
				for each(var zone:Zone in world.faders)
				{
					zone.touch = false;
				}
			}catch (e:Error) {
				
			}
			
			tochedZone = null;
		}
		
		public static function touches():Boolean
		{
			var node:* = World.nodeDefinion(App.map.mouseX, App.map.mouseY);
			
			
			if (node == null) return false;
			
			var world:World;
			var zoneID:uint = node.z;
			
			if (App.user.mode == User.OWNER)
				world = App.user.world;
			else	
				world = App.owner.world;
			
			if (world.faders[zoneID] != null)
			{
				if (tochedZone != null)
				{
					if (tochedZone != world.faders[zoneID])
					{
						tochedZone.touch = false;
						tochedZone = world.faders[zoneID];
						tochedZone.touch = true;
						return true;
					}
					
					return true;
				}
				
				tochedZone = world.faders[zoneID];
				tochedZone.touch = true;
				return true;
			}
			else
			{
				if (tochedZone != null)
				{
					tochedZone.touch = false;
					tochedZone = null;
				}
			}
			
			return false;
		}
		
		public static function snapClip(clip:*, delta:int = 100):BitmapData
		{
			var bounds:Rectangle = clip.getBounds (clip);
			var bmd:BitmapData = new BitmapData (int (bounds.width+delta), int (bounds.height + delta), true, 0);
			bmd.draw (clip, new Matrix (1, 0, 0, 1, -bounds.x + delta/2, -bounds.y + delta/2));
			return bmd;
		}
		
		
		public static function createFog():void {
			
			if ((App.user.id == "1" && App.user.worldID == 359) || 
				(App.owner != null && App.owner.id == "1" && App.owner.worldID == 359))
			{
				
			}
			else
			{
				return;
			}
			
			
			var L:int = 10;
			var array:Array = [
				{x: 5, y: 54},
				{x: 24, y: 67},
				{x: 39, y: 68},
				//{x: 26, y: 52},
				{x: 47, y: 59},
				{x: 70, y: 67},
				{x: 55, y: 32},
				{x: 62, y: 17},
				{x: 52, y: 2},
				{x: 35, y: 4},
				{x: 3, y: 34 },
				{x: 32, y: 31},
				{x: 30, y: 17},
				//{x: 38, y: 13},
				{x: 37, y: 20},
				{x: 24, y: 2},
				{x: 10, y: 3},
				//{x: 2, y: 14},
				{x: 28, y: 45 },
				//{x: 42, y: 42},
				{x: 41, y: 33},
				{x: 47, y: 41},
				//{x: 55, y: 41}
			];
			
			for (var i:int = 0; i < array.length; i++) {
				var element:Bitmap = createFogElement();
				App.map.mTreasure.addChild(element);
				var point:Object = IsoConvert.isoToScreen(array[i].x, array[i].y, true);
				element.x = point.x - element.width/2;
				element.y = point.y - element.height/2;
			}
		}
		
		public static function createFogElement():Bitmap
		{
			var glow:Shape = new Shape();
			glow.graphics.beginFill(0x8de8b6, 1);//0x8de8b6
			glow.graphics.drawEllipse(0, 0, 300, 150);
			glow.graphics.endFill();
			
			glow.filters = [new BlurFilter(100, 100, 3)];
			
			var padding:int = 80;
			var cont:Sprite = new Sprite();
			cont.addChild(glow);
			glow.x = padding;
			glow.y = padding;
			
			var scale:Number = (int(Math.random() * 50) + 50) / 100;
			glow.scaleX = glow.scaleY = scale;
			
			var bmd:BitmapData = new BitmapData(glow.width + 2 * padding, glow.height + 2 * padding, true, 0);
			bmd.draw(cont);
			return new Bitmap(bmd);
		}
	}
}