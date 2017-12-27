package wins 
{
	import adobe.utils.CustomActions;
	import com.greensock.easing.Linear;
	import com.greensock.plugins.BezierThroughPlugin;
	import com.greensock.plugins.TweenPlugin;
	import com.greensock.TweenLite;
	import core.Load;
	import core.Numbers;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public class ProgressWindow extends Window 
	{
		
		private var backing:Bitmap,
					chapterImage:Bitmap,
					chapterImages:Array = ['chapter1', 'chapter2'],
					chapterCount:int = 0,
					pages:Array = [];
		
		public static var chapters:Object = { };
		
		public function ProgressWindow(settings:Object = null) 
		{
			TweenPlugin.activate([BezierThroughPlugin]);
			
			if (!settings) settings = { };
			settings['width'] = settings['width'] || 793;
			settings['height'] = settings['height'] || 640;
			settings['title'] = settings['title'] || Locale.__e('flash:1411981629403');
			
			settings['hasPaginator'] = true;
			settings['hasButtons'] = false;
			settings['background'] = 'chapterBacking';
			settings['onPageCount'] = 1;
			
			init();
			
			super(settings);
		}
		
		private function init():void {
			chapters = { };
			
			// Добавить первое обновление которое никуда не подвязано
			var firstUpdate:String = '';
			var firstForOrder:int = Numbers.countProps(App.data.updatelist);
			for (var s:String in App.data.updatelist[App.social]) {
				if (App.data.updates[s].order < firstForOrder) {
					firstForOrder = App.data.updates[s].order;
					firstUpdate = s;
				}
			}
			
			var code:Array = App.data.updates[firstUpdate].pos.split(';');
			chapters[firstUpdate] = {
				id:		firstUpdate,
				quests:		[],
				quests_complete:[],
				update:		App.data.updates[firstUpdate],
				x:			int(code[1]),
				y:			int(code[2]),
				page:		int(code[0]),
				order:		App.data.updates[firstUpdate].order
			};
			pages.push(chapters[firstUpdate].page);
			
			for (s in App.data.quests) {
				var quest:Object = App.data.quests[s];
				if (quest.update.length > 0 && App.data.updatelist[App.social].hasOwnProperty(quest.update) && App.data.updates[quest.update].enabled) {
					if (!chapters.hasOwnProperty(quest.update)) {
						code = App.data.updates[quest.update].pos.split(';');
						
						chapters[quest.update] = {
							id:			quest.update,
							quests:		[],
							quests_complete:[],
							update:		App.data.updates[quest.update],
							x:			int(code[1]),
							y:			int(code[2]),
							page:		int(code[0]),
							order:		App.data.updates[quest.update].order
						};
						
						if (pages.indexOf(int(chapters[quest.update].page)) < 0)
							pages.push(int(chapters[quest.update].page));
					}
					
					chapters[quest.update].quests.push(s);
					
					if (App.user.quests.data.hasOwnProperty(s) && App.user.quests.data[s].finished > 0)
						chapters[quest.update].quests_complete.push(s);
				}
			}
		}
		
		override public function drawBackground():void {
			var b:Shape = new Shape();
			b.graphics.beginFill(0xf1ba8a, 1);
			b.graphics.drawRect(36, 36, settings.width - 72, settings.height - 72);
			b.graphics.endFill();
			layer.addChild(b);
			
			super.drawBackground();
		}
		
		override public function drawBody():void {
			drawMirrowObjs('diamondsTop', settings.width / 2 - settings.titleWidth / 2 - 10, settings.width / 2 + settings.titleWidth / 2 + 10, titleLabel.y - 28, true, true);
			
			// Backing
			backing = new Bitmap();
			backing.alpha = 0;
			bodyContainer.addChild(backing);
			
			// Page image
			chapterImage = new Bitmap();
			bodyContainer.addChild(chapterImage);
			
			decorCont = new Sprite();
			bodyContainer.addChild(decorCont);
			
			container = new Sprite();
			bodyContainer.addChild(container);
			
			paginator.onPageCount = 1;
			paginator.itemsCount = pages.length;
			paginator.page = 0;
			paginator.update();
			
			Load.loading(Config.getImage('chapters', 'chapters', 'jpg'), function(data:Bitmap):void {
				backing.bitmapData = data.bitmapData;
				backing.x = 36;
				backing.y = -6;
				
				TweenLite.to(backing, 0.5, { alpha:1, onComplete:function():void {
					contentChange();
				}} );
			});
			
		}
		
		public var items:Vector.<ProgressItem> = new Vector.<ProgressItem>;
		private var container:Sprite;
		private var decorCont:Sprite;
		override public function contentChange():void {
			clear();
			
			for (var s:String in chapters) {
				if (chapters[s].page == paginator.page + 1) {
					var item:ProgressItem = new ProgressItem(chapters[s]);
					items.push(item);
					container.addChild(item);
				}
			}
			items.sort(sorter);
			beginShow();
			
			Load.loading(Config.getImage('chapters', chapterImages[paginator.page % chapterImages.length], 'jpg'), onChapterLoad);
		}
		private function sorter(a:ProgressItem, b:ProgressItem):int {
			if (a.order > b.order) {
				return 1;
			}else if (a.order < b.order) {
				return -1;
			}else {
				return 0;
			}
		}
		private function onChapterLoad(data:Bitmap):void {
			var bmd:BitmapData = new BitmapData(data.width, data.height, true, 0);
			bmd.draw(data);
			chapterImage.bitmapData = bmd;
			chapterImage.bitmapData.fillRect(new Rectangle(0, 0, 1, chapterImage.height), 0x00000000);
			chapterImage.x = 152;
			chapterImage.y = 97;
		}
		
		public var drawing:Boolean = false;
		private var lastPointPoint:Point = new Point(); 					// :)
		private var drawNow:Vector.<ProgressItem> = new Vector.<ProgressItem>;
		private const POINT_DIST:Number = 24;
		private const UPDATE_RADIUS:int = 52;
		private function beginShow():void {
			drawing = true;
			
			var path:Array = [];
			var from:ProgressItem = getFirstItem();
			//drawAtShadow(from);
			showPoint(path, from);
			
			
			
			/*var from:ProgressItem = getFirstItem();
			from.show();
			onPointsComplete(from);*/
		}
		private function drawFrom(update:ProgressItem = null):void {
			var from:ProgressItem = update;
			var to:Vector.<ProgressItem> = getChilds(from);
			
			
			var isChildOf:Array = notInContainer([from.update.parent]);
			var parentOf:Array = notInContainer(childOf(from.updateID));
			var tpoint:Point;
			var args:Array;
			
			if (isChildOf.length > 0) {
				args = chapters[isChildOf[0]].update.pos.split(';');
				tpoint = new Point(args[1] + 900, args[2]);
			}
			if (parentOf.length > 0) {
				args = chapters[parentOf[0]].update.pos.split(';');
				tpoint = new Point(args[1] - 900, args[2]);
			}
			if (tpoint)
				drawAtShadow(from, tpoint);
			
			
			if (from && to.length > 0) {
				
				for (var i:int = 0; i < to.length; i++) {
					var distance:Number = Math.sqrt((from.x - to[i].x) * (from.x - to[i].x) + (from.y - to[i].y) * (from.y - to[i].y));
					var path:Array = [];
					var curve:Number = 0.25;
					
					if (distance - UPDATE_RADIUS * 2 > 0) {
						var pos:int = 0;
						var value:Number = 0;
						while (true) {
							if (distance - UPDATE_RADIUS * 2 > pos * POINT_DIST) {
								value = (UPDATE_RADIUS + pos * POINT_DIST) / distance;
								var point:Point = new Point(from.x - (from.x - to[i].x) * value, from.y - (from.y - to[i].y) * value);
								//point.x += Math.sin(value * Math.PI) * curve * (from.y - to[i].y);
								//point.y += Math.sin(value * Math.PI) * curve * (from.x - to[i].x);
								path.push(point);
							}else {
								/*var align:Number = ((distance - UPDATE_RADIUS * 2) - (path.length * POINT_DIST)) / 2;
								value = align / distance;
								for (var j:int = 0; j < path.length; j++) {
									path[j].x += (from.x - to[i].x) * value;
									path[j].y += (from.y - to[i].y) * value;
								}*/
								if (point) {
									var compDist:Number = Math.sqrt((point.x - to[i].x) * (point.x - to[i].x) + (point.y - to[i].y) * (point.y - to[i].y));
									value = ((compDist - UPDATE_RADIUS) / distance) / 2;
									for (var j:int = 0; j < path.length; j++) {
										path[j].x -= (from.x - to[i].x) * value;
										path[j].y -= (from.y - to[i].y) * value;
									}
								}
								
								break;
							}
							
							pos++;
						}
					}
					
					drawNow.push(to[i]);
					showPoint(path, to[i]);
				}
			}else {
				drawing = false;
			}
		}
		
		
		private function showPoint(path:Array, to:ProgressItem):void {
			if (path.length > 0) {
				var point:Point = path.shift();
				var pointCont:Sprite = new Sprite();
				var bitmap:Bitmap = new Bitmap(Window.textures.pathPoint, 'auto', true);
				bitmap.x = point.x - int(bitmap.width / 2);
				bitmap.y = point.y - int(bitmap.height / 2);
				pointCont.alpha = 0;
				pointCont.addChild(bitmap);
				decorCont.addChild(pointCont);
				
				TweenLite.to(pointCont, 0.06, { alpha:1, onCompleteParams:[path, to], onComplete:function(... args):void {
					showPoint(args[0], args[1]);
				}});
			}else {
				to.show();
				drawFrom(to);
			}
		}
		
		private function getChilds(parent:ProgressItem):Vector.<ProgressItem> {
			var items:Vector.<ProgressItem> = new Vector.<ProgressItem>;
			for (var i:int = 0; i < container.numChildren; i++) {
				var _item:ProgressItem = container.getChildAt(i) as ProgressItem;
				if (_item.update.parent == parent.updateID) {
					items.push(_item);
				}
			}
			
			return items;
		}
		private function getFirstItem():ProgressItem {
			var lower:int = -1;
			var item:ProgressItem;
			for (var i:int = 0; i < container.numChildren; i++) {
				var _item:ProgressItem = container.getChildAt(i) as ProgressItem;
				if (_item.order < lower || lower < 0) {
					lower = _item.order;
					item = _item;
				}
			}
			
			return item;
		}
		/*private function showPoints(from:ProgressItem, to:ProgressItem):void {
			var fromX:Number = from.x;
			var fromY:Number = from.y;
			var toX:Number = to.x;
			var toY:Number = to.y;
			var distance:Number = Math.sqrt((fromX - toX) * (fromX - toX) + (fromY - toY) * (fromY - toY));
			var duration:Number = distance / 700;
			var bezierThrough:Array = [{x:toX, y:toY}];
			
			to.x = fromX;
			to.y = fromY;
			
			drawNow.push(to);
			TweenLite.to(to, duration, {
				ease:				Linear.easeNone,
				bezierThrough:		bezierThrough,
				orientToBezier:		false,
				onCompleteParams:	[to],
				onComplete:			onPointsComplete,
				onUpdateParams:		[fromX, fromY, toX, toY, to],
				onUpdate:			onPointsUpdate
			});
		}
		private function onPointsUpdate(... args):void {
			var distanceFrom:Number = Math.sqrt((args[0] - args[4].x) * (args[0] - args[4].x) + (args[1] - args[4].y) * (args[1] - args[4].y));
			var distanceTo:Number = Math.sqrt((args[2] - args[4].x) * (args[2] - args[4].x) + (args[3] - args[4].y) * (args[3] - args[4].y));
			var distancePoint:Number = Math.sqrt((lastPointPoint.x - args[4].x) * (lastPointPoint.x - args[4].x) + (lastPointPoint.y - args[4].y) * (lastPointPoint.y - args[4].y));
			
			if (distanceFrom > UPDATE_RADIUS && distanceTo > UPDATE_RADIUS * 0.95 && distancePoint > POINT_DIST) {
				putPathPointAt(new Point(args[4].x, args[4].y));
				lastPointPoint.x = args[4].x;
				lastPointPoint.y = args[4].y;
			}
		}
		private function onPointsComplete(... args):void {
			var from:ProgressItem = args[0] as ProgressItem;
			var to:Vector.<ProgressItem> = getChilds(from);
			
			if (drawNow.indexOf(to) >= 0)
				drawNow.splice(drawNow.indexOf(to), 1);
			
			from.show();
			
			for (var i:int = 0; i < to.length; i++) {
				showPoints(from, to[i]);
			}
		}*/
		private function putPathPointAt(point:Point, alpha:Number = 1):void {
			var pointCont:Sprite = new Sprite();
			var bitmap:Bitmap = new Bitmap(Window.textures.pathPoint, 'auto', true);
			bitmap.x = point.x - int(bitmap.width / 2);
			bitmap.y = point.y - int(bitmap.height / 2);
			pointCont.alpha = alpha;
			pointCont.addChild(bitmap);
			decorCont.addChild(pointCont);
			
			//TweenLite.to(pointCont, 0.1, { alpha:1 });
		}
		private function drawAtShadow(item:ProgressItem, point:Point):void {
			var count:int = 5;
			var distance:Number = Math.sqrt((item.x - point.x) * (item.x - point.x) + (item.y - point.y) * (item.y - point.y));
			var dX:Number = int(Math.abs(item.x - point.x) / POINT_DIST);
			var dY:Number = int(Math.abs(item.y - point.y) / POINT_DIST);
			var currPos:Number = UPDATE_RADIUS + 6;
			while (true) {
				if (count <= 0) break;
				if (currPos >= UPDATE_RADIUS) {
					count--;
					var div:Number = currPos / distance;
					putPathPointAt(new Point(item.x + (item.x - point.x) * div, item.y + (item.y - point.y) * div), count / 5);
				}
				currPos += POINT_DIST;
			}
		}
		private function childOf(id:String):Array {
			var list:Array = [];
			for (var s:String in chapters) {
				if (id == chapters[s].update.parent && chapters[s].update.parent.length > 0)
					list.push(s);
			}
			
			return list;
		}
		private function notInContainer(updates:Array):Array {
			var result:Array = [];
			for (var i:int = 0; i < updates.length; i++) {
				var atCont:Boolean = false;
				for each (var item:ProgressItem in items) {
					if (item.updateID == updates[i])
						atCont = true;
				}
				
				if (!atCont && updates[i].length > 0)
					result.push(updates[i])
			}
			return result;
		}
		
		override public function drawArrows():void {
			super.drawArrows();
			
			paginator.arrowLeft.x = 100;
			paginator.arrowRight.x = settings.width - 200;
			paginator.arrowLeft.y = paginator.arrowRight.y = 250;
		}
		
		private function clear():void {
			if (drawing) {
				if (drawNow.length > 0) {
					for (var i:int = 0; i < drawNow.length; i++) {
						TweenLite.killTweensOf(drawNow[i]);
					}
					drawNow = null;
				}
			}
			
			while (decorCont.numChildren > 0) {
				var sprite:Sprite = decorCont.getChildAt(0) as Sprite;
				decorCont.removeChild(sprite);
			}
			
			while (container.numChildren > 0) {
				var item:ProgressItem = container.getChildAt(0) as ProgressItem;
				if (items.indexOf(item) >= 0) items.splice(items.indexOf(item), 1);
				item.dispose();
			}
		}
		
		override public function dispose():void {
			clear();
			
			super.dispose();
		}
	}

}

import com.greensock.TweenLite;
import core.Load;
import core.Post;
import flash.display.Bitmap;
import flash.display.Shape;
import flash.events.MouseEvent;
import wins.ProgressWindow;
import wins.Window;
import wins.ProgressViewWindow;


internal class ProgressItem extends LayerX {
	
	public static const CLOSE:uint = 0;
	public static const PROGRESS:uint = 1;
	public static const COMPLETE:uint = 2;
	
	public var updateID:String;
	public var order:int = 0;
	public var update:Object;
	public var window:ProgressWindow;
	
	private var params:Object = { };
	private var _state:uint = CLOSE;
	
	private var overlay:Bitmap;
	private var ring:Bitmap;
	private var wreath:Bitmap;		// Венок
	private var image:Bitmap;
	private var imageMask:Shape;
	public var percent:Number = 1;
	
	public function ProgressItem(params:Object, window:ProgressWindow = null):void {
		if (params) {
			for (var s:String in params)
				this.params[s] = params[s];
		}
		
		order = params.order;
		update = params.update;
		this.window = window;
		updateID = params.id;
		
		if (params.quests.length > 0) {
			percent = params.quests_complete.length / params.quests.length;
		}
		
		draw();
		
		addEventListener(MouseEvent.CLICK, onClick);
	}
	
	private function draw():void {
		alpha = 0;
		
		image = new Bitmap(null, 'auto', true);
		imageMask = new Shape();
		imageMask.graphics.beginFill(0x000000, 1);
		imageMask.graphics.drawCircle(0, 0, 35);
		imageMask.graphics.endFill();
		image.mask = imageMask;
		addChild(image);
		addChild(imageMask);
		
		Load.loading(Config.getImageIcon('updates', 'icons/' + update.preview, 'jpg'), function(data:Bitmap):void {
			image.bitmapData = data.bitmapData;
			image.smoothing = true;
			image.width = imageMask.width;
			image.scaleY = image.scaleX;
			image.x = int( -image.width / 2);
			image.y = image.x - 4;
		});
		
		overlay = new Bitmap(Window.textures.chapterSmallLensOverlay, 'auto', true);
		overlay.x = int( -overlay.width / 2);
		overlay.y = int( -overlay.height / 2);
		overlay.alpha = 0.4;
		addChild(overlay);
		
		ring = new Bitmap(Window.textures.chapterSmallRing, 'auto', true);
		ring.x = int( -ring.width / 2);
		ring.y = int( -ring.height / 2);
		addChild(ring);
		
		if (percent >= 1) {
			wreath = new Bitmap(Window.textures.chapterPremium, 'auto', true);
			wreath.x = int( -wreath.width / 2);
			wreath.y = int( -wreath.height / 2) + 5;
			addChild(wreath);
		}
		
		this.x = params.x;
		this.y = params.y;
		
		/*if (Config.admin) {
			this.addEventListener(MouseEvent.MOUSE_DOWN, onDown);
			this.addEventListener(MouseEvent.MOUSE_UP, onUp);
		}*/
	}
	
	public function get state():uint {
		return _state;
	}
	public function set state(value:uint):void {
		_state = value;
	}
	
	private function onDown(e:MouseEvent):void {
		startDrag(false);
	}
	private function onUp(e:MouseEvent):void {
		stopDrag();
		Post.addToArchive(update.title + ' ' + String(x) + ';' + String(y));
	}
	
	public function show():void {
		TweenLite.to(this, 0.2, { alpha:1 } );
	}
	
	private function onClick(e:MouseEvent):void {
		new ProgressViewWindow( {
			percent:	percent,
			update:		update,
			image:		image
		}).show();
	}
	
	public function dispose():void {
		if (parent) parent.removeChild(this);
	}
	
}