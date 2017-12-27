package core 
{
	import buttons.ImageButton;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.text.TextField;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	import wins.Window;
	
	public class Admin extends Sprite 
	{
		
		public function Admin() 
		{
			super();
			
		}
		
		private static var __admin:Admin;
		public static function get admin():Admin {
			if (!__admin) {
				__admin = new Admin();
				__admin.draw();
			}
			
			
			return __admin;
		}
		
		public static function show():void {
			if (!App.self.windowContainer.contains(admin)) {
				App.self.windowContainer.addChild(admin);
				App.map.visible = false;
				App.ui.visible = false;
				
				admin.resize();
			}else{
				close();
			}
		}
		
		public static function close():void {
			if (admin)
				admin.close();
			
		}
		
		public static function chooseStorageID(sid:*, type:*):void {
			admin.chooseStorageID(sid, type);
		}
		
		public static function branch(branch:Array):void {
			admin.parseBranch(branch);
		}
		
		
		
		// Draw
		private var backing:Shape;
		private var searchLabel:TextField;
		private var tree:Tree;
		private var extendedView:ExtebdedView;
		private var exit:ImageButton;
		
		private var branchFilter:String;
		
		public function draw():void {
			
			/*function abcd(...args):void {
				trace(args);
			}
			
			abcd.apply('a', ['b','c',1]);
			
			return;*/
			
			Extended.parse(App.data);
			
			backing = new Shape();
			backing.graphics.beginFill(0x000000, 0.75);
			backing.graphics.drawRect(0, 0, App.self.stage.stageWidth, App.self.stage.stageHeight);
			backing.graphics.endFill();
			addChild(backing);
			
			searchLabel = Window.drawText('', {
				fontFamily:		'Arial',
				input:			true,
				width:			220,
				fieldBorder:	true,
				embedFonts:		false,
				fontSize:		13,
				color:			0xdddddd,
				borderSize:		0,
				bold:			true
			});
			searchLabel.x = 2;
			searchLabel.y = 26;
			searchLabel.borderColor = 0xdddddd;
			searchLabel.addEventListener(TextEvent.TEXT_INPUT, onTextInputEvent);
			addChild(searchLabel);
			
			var next:QueueList = new QueueList(['Next'], 100, { click:function(...args):void { tree.focusOnNext(); } } );
			next.x = searchLabel.x + searchLabel.width + 3;
			next.y = searchLabel.y + 1;
			addChild(next);
			
			var vars:QueueList = new QueueList(['All', 'Storage', 'Quests', 'Updates'], 300, {
				click:		onFilterClick
			});
			vars.x = 2;
			vars.y = 2;
			addChild(vars);
			
			tree = new Tree(App.self.stage, 300, App.self.stage.stageHeight - 50);
			tree.y = 50;
			addChild(tree);
			
			tree.init(App.data);
			
			
			extendedView = new ExtebdedView(App.self.stage.stageWidth - 310, App.self.stage.stageHeight);
			extendedView.x = 310;
			addChild(extendedView);
			
			//extendedView.draw(133);
			
			
			var closeShape:Shape = new Shape();
			closeShape.graphics.lineStyle(1, 0xffffff);
			closeShape.graphics.drawRect(0, 0, 16, 16);
			closeShape.graphics.moveTo(3, 3);
			closeShape.graphics.lineTo(14, 14);
			closeShape.graphics.moveTo(14, 3);
			closeShape.graphics.lineTo(3, 14);
			
			var closeBitmapData:BitmapData = new BitmapData(closeShape.width, closeShape.height, true, 0);
			closeBitmapData.draw(closeShape);
			
			exit = new ImageButton(closeBitmapData);
			exit.x = App.self.stage.stageWidth - exit.width - 3;
			exit.y = 3;
			addChild(exit);
			exit.addEventListener(MouseEvent.CLICK, close);
			
		}
		
		public function resize():void {
			backing.graphics.clear();
			backing.graphics.beginFill(0x000000, 0.75);
			backing.graphics.drawRect(0, 0, App.self.stage.stageWidth, App.self.stage.stageHeight);
			backing.graphics.endFill();
			
			tree.currWidth = 300;
			tree.currHeight = App.self.stage.stageHeight - 50;
			
			extendedView.currWidth = App.self.stage.stageWidth - 310;
			extendedView.currHeight = App.self.stage.stageHeight;
			
			exit.x = App.self.stage.stageWidth - exit.width - 3;
			exit.y = 3;
		}
		
		private function onFilterClick(item:*):void {
			
			if (!item.hasOwnProperty('params')) return;
			
			searchLabel.text = '';
			
			switch (item.params.sid) {
				case 'Storage':
					tree.init(App.data.storage);
					branchFilter = 'storage';
					break;
				case 'Quests':
					tree.init(App.data.quests);
					branchFilter = 'quests';
					break;
				case 'Updates':
					tree.init(App.data.updates);
					branchFilter = 'updates';
					break;
				default:
					tree.init(App.data);
					branchFilter = null;
			}
		}
		
		public function chooseStorageID(sid:*, type:*):void {
			switch(type) {
				case 'updates':	extendedView.drawUpdates(sid); break;
				case 'quests':	extendedView.drawQuest(sid); break;
				default:		extendedView.draw(sid);
			}
			
		}
		
		public function parseBranch(link:Array):void {
			if (link.length >= 2 && link[0] == 'storage' && link[1] is int) {
				extendedView.draw(link[1]);
			}else if (link.length >= 2 && link[0] == 'quests' && link[1] is int) {
				extendedView.drawQuest(link[1]);
			}else if (link.length >= 2 && link[0] == 'updates' && App.data.updates[link[1]]) {
				extendedView.drawUpdates(link[1]);
			}
			
			if (branchFilter && branchFilter == 'storage' && link[0] is int) {
				extendedView.draw(link[0]);
			}else if (branchFilter && branchFilter == 'quests' && link[0] is int) {
				extendedView.drawQuest(link[0]);
			}else if (branchFilter && branchFilter == 'updates' && App.data.updates[link[0]]) {
				extendedView.drawUpdates(link[0]);
			}
		}
		
		public function close(e:* = null):void {
			if (App.self.windowContainer.contains(this))
				App.self.windowContainer.removeChild(this);
			
			App.map.visible = true;
			App.ui.visible = true;
		}
		
		private var searchTimeout:int = 0;
		private function onTextInputEvent(e:TextEvent):void {
			
			if (searchTimeout) clearTimeout(searchTimeout);
			searchTimeout = setTimeout(search, 200);
			
			function search():void {
				tree.find(e.target.text);
				tree.update();
			}
		}
	}
}

import adobe.utils.CustomActions;
import buttons.Button;
import buttons.ImageButton;
import core.Admin;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.Shape;
import flash.display.Sprite;
import flash.display.Stage;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.text.TextField;
import flash.text.TextFieldType;
import flash.text.TextFormat;
import flash.utils.clearTimeout;
import flash.utils.getTimer;
import flash.utils.setTimeout;
import ui.Hints;
import wins.Window;
import core.Load;
import core.Size;

internal class Tree extends Sprite {
	
	public static const WIDTH:uint = 300;
	public static const HEIGHT:uint = 18;
	
	public static var plus:BitmapData;
	public static var minus:BitmapData;
	public static var hand:BitmapData;
	
	public var source:Object;	// оригинальные данные
	public var data:Array;		// Данные древа
	public var activeList:Array;
	
	public var currWidth:int = 0;
	public var currHeight:int = 0;
	public var currStage:Stage;
	
	private var container:Sprite;
	private var scroller:Sprite;
	private var maska:Shape;
	
	public function Tree(stage:Stage, width:int, height:int) {
		
		currWidth = width;
		currHeight = height;
		currStage = stage;
		
		addEventListener(MouseEvent.CLICK, onClick);
		addEventListener(MouseEvent.MOUSE_MOVE, onMove);
		addEventListener(MouseEvent.MOUSE_WHEEL, onWheel);
		
	}
	
	public function init(data:Object = null):void {
		if (!Tree.plus) {
			var plus:BitmapData = new BitmapData(11, 11, true, 0xffffffff);
			plus.fillRect(new Rectangle(1, 1, 9, 9), 0x00ffffff);
			plus.fillRect(new Rectangle(5, 3, 1, 5), 0xffffffff);
			plus.fillRect(new Rectangle(3, 5, 5, 1), 0xffffffff);
			
			Tree.plus = plus;
		}
		
		if (!Tree.minus) {
			var minus:BitmapData = new BitmapData(11, 11, true, 0xffffffff);
			minus.fillRect(new Rectangle(1, 1, 9, 9), 0x00ffffff);
			minus.fillRect(new Rectangle(3, 5, 5, 1), 0xffffffff);
			
			Tree.minus = minus;
		}
		
		if (!Tree.hand) {
			var hand:BitmapData = new BitmapData(11, 11, true, 0x00ffffff);
			hand.fillRect(new Rectangle(5, 5, 6, 1), 0xffffffff);
			hand.fillRect(new Rectangle(5, 0, 1, 6), 0xffffffff);
			
			Tree.hand = hand;
		}
		
		clear();
		
		if (!this.data) this.data = [];
		if (!data) data = { };
		if (!activeList) activeList = [];
		
		this.data = parse(this.data, data);
		
		redraw();
		
	}
	
	private function parse(result:Array, object:Object, key:* = null, level:int = 0):* {
		
		for (var s:* in object) {
			var child:Object = {
				value:	[],
				key:	s,
				open:	(!key) ? true : false,
				level:	level,
				find:	false					// Поисковый регистр
			};
			child.value = (typeof(object[s]) == 'object') ? parse(child.value, object[s], s, level + 1) : object[s];
			result.push(child);
		}
		
		return result;
		
	}
	
	public function find(value:*):void {
		
		function findInBranch(value:*, list:Array):Boolean {
			var finded:Boolean = false;
			for (var i:int = 0; i < list.length; i++ ) {
				list[i].find = false;
				
				if (list[i].value is Array && findInBranch(value, list[i].value)) {
					list[i].find = true;
					finded = true;
				}else if (String(list[i].key).indexOf(value) != -1 || (!(list[i].value is Array) && String(list[i].value).indexOf(value) != -1)) {
					list[i].find = true;
					finded = true;
				}
				
			}
			
			return finded;
		}
		
		findInBranch(value, data);
		
		focusReset();
		focusOnNext();
	}
	
	
	// Фокусировка и перефокусировка по пунктам списка
	private var focusedIndex:int = 0;
	private var focusedCount:int = 0;
	public function focusOnNext():void {
		
		var index:int = focusedIndex;
		var finded:Boolean = false;
		
		focusedIndex ++;
		focusedCount = 0;
		
		for (var i:int = 0; i < activeList.length; i++) {
			if (activeList[i].find) {
				focusedCount ++;
				
				if (index == 0) {
					container.y = -HEIGHT * i + int(currHeight * 0.5);
					normalizeContainer();
					update();
				}
				
				index --;
			}
		}
		
		if (focusedCount > 0 && index > 0) {
			focusReset();
			focusOnNext();
		}
	}
	private function focusReset():void {
		focusedIndex = 0;
		focusedCount = 0;
	}
	
	
	public function redraw():void {
		
		function parseBranch(object:Object):void {
			if (object is Array) {
				if (object.length > 0 && object[0].key is Number) {
					object.sortOn('key', Array.NUMERIC);
				}else{
					object.sortOn('key');
				}
			}
			
			for (var s:* in object) {
				if (object[s].open) {
					activeList.push(object[s]);
					
					if (object[s].value is Array)
						parseBranch(object[s].value);
					
				}
			}
		}
		
		activeList.length = 0;
		
		parseBranch(data);
		update();
		drawMask();
		
		normalizeContainer();
		createScroller();
	}
	
	private function drawMask():void {
		if (!maska) {
			maska = new Shape();
			addChild(maska);
		}
		
		maska.graphics.clear();
		maska.graphics.beginFill(0xff0000, 1);
		maska.graphics.drawRect(0, 0, currWidth, currHeight);
		maska.graphics.endFill();
		
		container.mask = maska;
	}
	
	public function update():void {
		
		if (!container) {
			container = new Sprite();
			addChild(container);
		}else {
			container.removeChildren();
		}
		
		var from:int = -container.y / HEIGHT - currHeight / HEIGHT;
		var to:int = from + 3 * currHeight / HEIGHT;
		for (var i:int = from; i < to; i++) {
			if (!activeList[i]) continue;
			
			var treeItem:TreeItem = new TreeItem(activeList[i]);
			treeItem.x = 20 * activeList[i].level;
			treeItem.y = HEIGHT * i;
			container.addChild(treeItem);
		}
		
	}
	
	private function normalizeContainer():void {
		if (container.y > 0) {
			container.y = 0;
		}else if (container.y < -activeList.length * HEIGHT + currHeight) {
			container.y = -activeList.length * HEIGHT + currHeight;
		}
	}
	
	private function createScroller():void {
		if (!scroller) {
			scroller = new Sprite();
			addChild(scroller);
			
			currStage.addEventListener(MouseEvent.MOUSE_DOWN, onScrollerDown);
			currStage.addEventListener(MouseEvent.MOUSE_UP, onScrollerUp);
		}
		
		if (HEIGHT * activeList.length < currHeight) {
			scroller.visible = false;
			return;
		}
		
		var scrollHeight:int = currHeight * currHeight / (HEIGHT * activeList.length);
		if (scrollHeight < 30) scrollHeight = 30;
		
		scroller.visible = true;
		scroller.graphics.clear();
		scroller.graphics.beginFill(0xffffff, 1);
		scroller.graphics.drawRect(0, 0, 6, scrollHeight);
		scroller.graphics.endFill();
		
		scroller.x = currWidth;
		scroller.y = -container.y * (currHeight - scroller.height) / (HEIGHT * activeList.length - currHeight);
		
		function onScrollerDown(e:MouseEvent):void {
			var clickedOnScroller:Boolean = false;
			var list:Array = currStage.getObjectsUnderPoint(new Point(currStage.mouseX, currStage.mouseY));
			for (var i:int = 0; i < list.length; i++) {
				if (list[i] == scroller) {
					clickedOnScroller = true;
				}
			}
			
			if (!clickedOnScroller) return;
			
			if (!moving) {
				moving = true;
				scroller.startDrag(false, new Rectangle(scroller.x, 0, 0, currHeight - scroller.height));
			}
			
		}
		
		function onScrollerUp(e:MouseEvent):void {
			scroller.stopDrag();
			moving = false;
		}
		
	}
	
	private function onScrollerMove(e:Event):void {
		container.y = -scroller.y * (HEIGHT * activeList.length - currHeight) / (currHeight - scroller.height);
		update();
	}
	
	private var __moving:Boolean = false;
	public function set moving(value:Boolean):void {
		if (__moving == value) return;
		
		__moving = value;
		
		if (__moving) {
			currStage.addEventListener(Event.ENTER_FRAME, onScrollerMove);
		}else {
			currStage.removeEventListener(Event.ENTER_FRAME, onScrollerMove);
		}
	}
	public function get moving():Boolean {
		return __moving;
	}
	
	private var updateTimeout:int;
	private function onWheel(e:MouseEvent):void {
		container.y += (e.delta > 0) ? currHeight * 0.75 : -currHeight * 0.75;
		
		normalizeContainer();
		
		scroller.y = -container.y * (currHeight - scroller.height) / (HEIGHT * activeList.length - currHeight);
		
		if (updateTimeout > 0) clearTimeout(updateTimeout);
		updateTimeout = setTimeout(function():void {
			updateTimeout = 0;
			update();
		}, 100);
	}
	
	private function onMove(e:MouseEvent):void {
		if (container.mouseX > WIDTH) return;
		
		var pos:int = int(container.mouseY / HEIGHT);
		
		container.graphics.clear();
		container.graphics.beginFill(0x000000, 0.4);
		container.graphics.drawRect(0, pos * HEIGHT, WIDTH, HEIGHT);
		container.graphics.endFill();
		
	}
	
	private function onClick(e:MouseEvent):void {
		var pos:int = int(container.mouseY / HEIGHT);
		
		if (pos >= 0 && activeList.length > pos && container.mouseX < WIDTH) {
			if (activeList[pos].value is Array) {
				
				// Определение ветвей древа
				var link:Array = [activeList[pos].key];
				var level:int = activeList[pos].level;
				for (var i:int = pos; i > -1; i--) {
					if (activeList[i].level < level) {
						level = activeList[i].level;
						link.unshift(activeList[i].key);
					}
					
					if (level <= 0) break;
				}
				
				// Открытие/закрытие ветви древа
				var array:Array = (activeList[pos].value as Array);
				for (i = 0; i < array.length; i++) {
					array[i].open = !array[i].open;
				}
				
				redraw();
				
				Admin.branch(link);
			}
		}
	}
	
	public function clear():void {
		if (container) {
			container.removeChildren();
			container = null;
		}
		
		if (maska) {
			maska.graphics.clear();
			maska = null;
		}
		
		source = null;
		data = null;
		activeList = null;
	}
	
	public function dispose():void {
		clear();
		
		if (parent)
			parent.removeChild(this);
		
	}
	
}

internal class TreeItem extends Sprite {
	
	private var object:Object;
	
	public function TreeItem(object:Object) {
		
		this.object = object;
		
		if (isObject) {
			var bitmap:Bitmap = new Bitmap();
			bitmap.x = 3;
			bitmap.y = 3;
			addChild(bitmap);
			
			if (object.value is Array && object.value.length > 0 && object.value[0].open) {
				bitmap.bitmapData = Tree.minus;
			}else {
				bitmap.bitmapData = Tree.plus;
			}
		}
		
		if (object.find) {
			var shape:Shape = new Shape();
			shape.graphics.beginFill(0xff0000, 0.4);
			shape.graphics.drawRect(0, 0, Tree.WIDTH, Tree.HEIGHT);
			shape.graphics.endFill();
			addChild(shape);
		}
		
		var text:TextField = Window.drawText(value, {
			fontFamily:		'Arial',
			width:			Tree.WIDTH,
			embedFonts:		false,
			fontSize:		11,
			color:			0xdddddd,
			borderSize:		0,
			bold:			true,
			scaleable:		false
		});
		text.x = 16;
		addChild(text);
		
		
	}
	
	private function get isObject():Boolean {
		if (object.value is Number || object.value is String || object is Boolean)
			return false;
		
		return true;
	}
	
	private function get value():String {
		if (!isObject)
			return String(object.key) + ': ' + String(object.value);
		
		return String(object.key);
	}
	
}


internal class Extended {
	
	public static const BUILDING:String = 'Building';
	public static const RESOURCE:String = 'Resource';
	public static const PLANT:String = 'Plant';
	public static const ANIMAL:String = 'Animal';
	public static const DECOR:String = 'Decor';
	public static const GOLDEN:String = 'Golden';
	public static const WALKGOLDEN:String = 'Wanimal';
	public static const QUESTS:String = 'Quests';
	public static const UPDATES:String = 'Updates';
	//public static const QUESTS:String = 'Quests';
	
	private static var list:Object;
	
	public static function parse(data:Object):void {
		
		list = { };
		
		var info:Object;
		var sid:*;
		var	a:*;
		var	b:*;
		var sid2:*;
		var out:*;
		
		for (sid in data.storage) {
			list[sid] = { };
		}
		
		for (sid in data.storage) {
			info = data.storage[sid];
			
			if (info.hasOwnProperty('outs')) {
				for (out in info.outs) break;
			}
			
			if (info.type == BUILDING) {
				
				// Крафтинг
				if (info.crafting) {
					
					for each(a in info.crafting) {
						
						// Результат крафта
						sid2 = data.crafting[a].out;
						
						if (!list[sid2][BUILDING])
							list[sid2][BUILDING] = { };
						
						if (!list[sid2][BUILDING]['craft'])
							list[sid2][BUILDING]['craft'] = [];
						
						list[sid2][BUILDING]['craft'].push(sid);
						
						// Элементы крафта
						for (b in data.crafting[a].items) {
							
							if (!list[b][BUILDING])
								list[b][BUILDING] = { };
							
							if (!list[b][BUILDING]['component'])
								list[b][BUILDING]['component'] = [];
							
							if (list[b][BUILDING]['component'].indexOf(sid) == -1)
								list[b][BUILDING]['component'].push(sid);
						}
						
					}
					
				}
				
			}
			
			if (info.type == RESOURCE) {
				
				if (!list[out][RESOURCE])
					list[out][RESOURCE] = { };
				
				if (!list[out][RESOURCE]['out'])
					list[out][RESOURCE]['out'] = [];
				
				if (list[out][RESOURCE]['out'].indexOf(sid) == -1)
					list[out][RESOURCE]['out'].push(sid);
				
			}
			
			if (info.type == PLANT) {
				
				if (!list[out][PLANT])
					list[out][PLANT] = { };
				
				if (!list[out][PLANT]['out'])
					list[out][PLANT]['out'] = [];
				
				list[out][PLANT]['out'].push(sid);
				
			}
			
			if (info.type == ANIMAL) {
				
				if (!list[out][ANIMAL])
					list[out][ANIMAL] = { };
				
				if (!list[out][ANIMAL]['out'])
					list[out][ANIMAL]['out'] = [];
				
				if (list[out][ANIMAL]['out'].indexOf(sid) == -1)
					list[out][ANIMAL]['out'].push(sid);
				
			}
			
			if (info.type == GOLDEN || info.type == WALKGOLDEN) {
				
				if (info.shake && data.treasures[info.shake] && data.treasures[info.shake][info.shake]) {
					
					if (data.treasures[info.shake][info.shake].item) {
						for each(a in data.treasures[info.shake][info.shake].item) {
							
							if (!list[a])
								continue;
							
							if (!list[a][DECOR])
								list[a][DECOR] = { };
							
							if (!list[a][DECOR]['reward'])
								list[a][DECOR]['reward'] = [];
							
							if (list[a][DECOR]['reward'].indexOf(sid) == -1)
								list[a][DECOR]['reward'].push(sid);
							
						}
					}else {
						trace(sid)
					}
					
				}
				
			}
			
		}
		
		for (sid in data.quests) {
			
			info = data.quests[sid];
			
			if (sid == 1103)
				trace();
			
			if (info.parent && data.quests[info.parent]) {
				
				if (!data.quests[info.parent]['child'])
					data.quests[info.parent]['child'] = [];
				
				if (data.quests[info.parent].child.indexOf(sid) == -1)
					data.quests[info.parent].child.push(sid);
				
			}
			
			for (a in info.missions) {
				
				for each(b in info.missions[a].map) {
					
					if (!list[b])
						continue;
					
					if (!list[b][QUESTS])
						list[b][QUESTS] = { };
					
					if (!list[b][QUESTS]['target'])
						list[b][QUESTS]['target'] = [];
					
					if (list[b][QUESTS]['target'].indexOf(sid) == -1)
						list[b][QUESTS]['target'].push(sid);
					
				}
				
				if (info.bonus && info.bonus.materials) {
					for (b in info.bonus.materials) {
						
						if (!list[b][QUESTS])
							list[b][QUESTS] = { };
						
						if (!list[b][QUESTS]['bonus'])
							list[b][QUESTS]['bonus'] = [];
						
						if (list[b][QUESTS]['bonus'].indexOf(sid) == -1)
							list[b][QUESTS]['bonus'].push(sid);
						
					}
				}
				
			}
			
		}
		
		for (sid in data.updates) {
			
			info = data.updates[sid];
			
			if (info.items) {
				for (a in info.items) {
					if (!list[a])
						continue;
					
					if (!list[a][UPDATES])
						list[a][UPDATES] = { };
					
					if (!list[a][UPDATES]['updates'])
						list[a][UPDATES]['updates'] = [];
					
					list[a][UPDATES]['updates'].push(sid);
				}
			}
		}
		
		//trace(list);
		
	}
	
	public static function getInfo(sid:*):Object {
		return list[sid];
	}
	
}


internal class ExtebdedView extends Sprite {
	
	public static var addBitmapData:BitmapData;
	public static var deleteBitmapData:BitmapData;
	public static var completeBitmapData:BitmapData;
	
	public var currWidth:int;
	public var currHeight:int;
	private var sid:*;
	
	private var maska:Shape;
	public var container:Sprite;
	private var subtitle1:TextField;
	private var subtitle2:TextField;
	private var subtitle3:TextField;
	private var subtitle4:TextField;
	private var subtitle5:TextField;
	private var sublist1:QueueList;
	private var sublist2:QueueList;
	private var sublist3:QueueList;
	private var sublist4:QueueList;
	
	public function ExtebdedView(width:int, height:int) {
		
		currWidth = width;
		currHeight = height;
		
		graphics.beginFill(0xff0000, 0.0);
		graphics.drawRect(0,0,currWidth,currHeight);
		graphics.endFill();
		
		if (!addBitmapData) {
			var shape:Shape = new Shape();
			shape.graphics.beginFill(0xffaa00);
			shape.graphics.drawCircle(16, 16, 16);
			shape.graphics.endFill();
			shape.graphics.lineStyle(4, 0xffffff, 1);
			shape.graphics.moveTo(16,10);
			shape.graphics.lineTo(16,22);
			shape.graphics.moveTo(10,16);
			shape.graphics.lineTo(22,16);
			
			addBitmapData = new BitmapData(shape.width, shape.height, true, 0x00ffffff);
			addBitmapData.draw(shape);
			
			shape.graphics.clear();
			shape.graphics.beginFill(0xaa0000);
			shape.graphics.drawCircle(16, 16, 16);
			shape.graphics.endFill();
			shape.graphics.lineStyle(4, 0xffffff, 1);
			shape.graphics.moveTo(12,12);
			shape.graphics.lineTo(20,20);
			shape.graphics.moveTo(12,20);
			shape.graphics.lineTo(20,12);
			
			deleteBitmapData = new BitmapData(shape.width, shape.height, true, 0x00ffffff);
			deleteBitmapData.draw(shape);
			
			shape.graphics.clear();
			shape.graphics.beginFill(0x55bb22);
			shape.graphics.drawCircle(16, 16, 16);
			shape.graphics.endFill();
			shape.graphics.lineStyle(4, 0xffffff, 1);
			shape.graphics.moveTo(10,16);
			shape.graphics.lineTo(14,20);
			shape.graphics.lineTo(22,12);
			
			completeBitmapData = new BitmapData(shape.width, shape.height, true, 0x00ffffff);
			completeBitmapData.draw(shape);
		}
		
		container = new Sprite();
		addChild(container);
		
		addEventListener(MouseEvent.MOUSE_WHEEL, onWheel);
	}
	
	protected function onWheel(e:MouseEvent):void {
		container.y += e.delta * 50;
		
		if (container.y > 0) {
			container.y = 0;
		}else if (container.height > currHeight && container.y < currHeight - container.height) {
			container.y = currHeight - container.height;
		}
	}
	
	public function resize(width:int, height:int):void {
		currWidth = width;
		currHeight = height;
		
		draw(sid);
	}
	
	private function updateButtonStates():void {
		if (!addBttn || !deleteBttn || !completeBttn) return;
		
		if (App.user.quests.data.hasOwnProperty(sid)) {
			addBttn.state = Button.DISABLED;
			deleteBttn.state = Button.NORMAL;
			completeBttn.state = (App.user.quests.isOpen(sid)) ? Button.NORMAL : Button.DISABLED;
		}else {
			addBttn.state = Button.NORMAL;
			deleteBttn.state = Button.DISABLED;
			completeBttn.state = Button.DISABLED;
		}
	}
	
	private function onQuestAdd(e:MouseEvent):void {
		if (addBttn.mode == Button.DISABLED) return;
		App.user.quests.openQuest([sid]);
		
		setTimeout(updateButtonStates, 1000);
	}
	private function onQuestDelete(e:MouseEvent):void {
		if (deleteBttn.mode == Button.DISABLED) return;
		//App.user.quests.deleteQuest(sid);
		
		setTimeout(updateButtonStates, 1000);
	}
	private function onQuestComplete(e:MouseEvent):void {
		if (completeBttn.mode == Button.DISABLED) return;
		//App.user.quests.finishQuests([sid]);
		
		setTimeout(updateButtonStates, 1000);
	}
	
	private var addBttn:ImageButton;
	private var deleteBttn:ImageButton;
	private var completeBttn:ImageButton;
	public function drawQuest(qid:*):void {
		
		if (!App.data.quests[qid]) return;
		
		dispose();
		
		this.sid = qid;
		
		var quest:Object = App.data.quests[qid];
		var position:int = 0;
		
		addBttn = new ImageButton(addBitmapData, { onClick:onQuestAdd });
		deleteBttn = new ImageButton(deleteBitmapData, { onClick:onQuestDelete });
		completeBttn = new ImageButton(completeBitmapData, { onClick:onQuestComplete });
		
		deleteBttn.x = 34;
		completeBttn.x = 68;
		addBttn.y = deleteBttn.y = completeBttn.y = 4;
		
		container.addChild(addBttn);
		container.addChild(deleteBttn);
		container.addChild(completeBttn);
		
		updateButtonStates();
		
		position = 40;
		
		var title:TextField = Window.drawText(quest.title + ' ' + qid, {
			fontFamily:		'Arial',
			autoSize:		'left',
			embedFonts:		false,
			fontSize:		24,
			color:			0xcccccc,
			borderSize:		0,
			bold:			true
		});
		title.selectable = true;
		title.mouseEnabled = true;
		title.y = position;
		container.addChild(title);
		
		position += title.height + 6;
		
		var description:TextField = Window.drawText(quest.description, {
			width:			currWidth - 20,
			fontFamily:		'Arial',
			autoSize:		'left',
			embedFonts:		false,
			fontSize:		14,
			color:			0xcccccc,
			borderSize:		0,
			bold:			true,
			multiline:		true,
			wrap:			true
		});
		description.selectable = true;
		description.mouseEnabled = true;
		description.y = position;
		container.addChild(description);
		
		position += description.height;
		
		var parentTitle:TextField = Window.drawText('Родители:', {
			fontFamily:		'Arial',
			autoSize:		'left',
			embedFonts:		false,
			fontSize:		16,
			color:			0xcccccc,
			borderSize:		0,
			bold:			true
		});
		parentTitle.y = position;
		container.addChild(parentTitle);
		
		position += parentTitle.height;
		
		var parentList:QueueList = new QueueList((quest.parent) ? [quest.parent] : [], currWidth, getObject(Extended.QUESTS));
		//parentList.x = posLabel.x;
		parentList.y = position + 4;
		container.addChild(parentList);
		
		position += parentList.height + 4;
		
		var childTitle:TextField = Window.drawText('Дети:', {
			fontFamily:		'Arial',
			autoSize:		'left',
			embedFonts:		false,
			fontSize:		16,
			color:			0xcccccc,
			borderSize:		0,
			bold:			true
		});
		childTitle.y = position;
		container.addChild(childTitle);
		
		position += childTitle.height;
		
		var childList:QueueList = new QueueList((quest.child && !(quest.child is Array)) ? [quest.child] : quest.child, currWidth, getObject(Extended.QUESTS));
		childList.y = position + 4;
		container.addChild(childList);
		
		position += childList.height + 8;
		
		
		var count:int = 1;
		if (quest.missions) {
			for (var m:* in quest.missions) {
				var mission:Object = quest.missions[m];
				
				var missionTitle:TextField = Window.drawText(count + '. ' + mission.title, {
					fontFamily:		'Arial',
					autoSize:		'left',
					embedFonts:		false,
					fontSize:		16,
					color:			0xcccccc,
					borderSize:		0,
					bold:			true
				});
				missionTitle.x = 10;
				missionTitle.y = position;
				container.addChild(missionTitle);
				
				count ++;
				position += missionTitle.height;
				
				// Цели
				if (mission.target) {
					var targetTitle:TextField = Window.drawText('Цели:', {
						fontFamily:		'Arial',
						autoSize:		'left',
						embedFonts:		false,
						fontSize:		12,
						color:			0xcccccc,
						borderSize:		0,
						bold:			true
					});
					targetTitle.x = 20;
					targetTitle.y = position;
					container.addChild(targetTitle);
					
					position += targetTitle.height;
					
					var targetList:QueueList = new QueueList(mission.target, currWidth, getObject(Extended.BUILDING));
					targetList.x = 20;
					targetList.y = position;
					container.addChild(targetList);
					
					position += targetList.height;
				}
				
				// Объекты на карте
				if (mission.map) {
					var mapTitle:TextField = Window.drawText('Объекты на карте:', {
						fontFamily:		'Arial',
						autoSize:		'left',
						embedFonts:		false,
						fontSize:		12,
						color:			0xcccccc,
						borderSize:		0,
						bold:			true
					});
					mapTitle.x = 20;
					mapTitle.y = position;
					container.addChild(mapTitle);
					
					position += mapTitle.height;
					
					var mapList:QueueList = new QueueList(mission.map, currWidth, getObject(Extended.BUILDING));
					mapList.x = 20;
					mapList.y = position;
					container.addChild(mapList);
					
					position += mapList.height;
				}
				
				var controllerLabel:TextField = Window.drawText('Контроллер: ' + mission.controller, {
					fontFamily:		'Arial',
					autoSize:		'left',
					embedFonts:		false,
					fontSize:		12,
					color:			0xcccccc,
					borderSize:		0,
					bold:			true
				});
				controllerLabel.x = 20;
				controllerLabel.y = position;
				container.addChild(controllerLabel);
				
				position += controllerLabel.height;
				
				var actionLabel:TextField = Window.drawText('Действие: ' + mission.event, {
					fontFamily:		'Arial',
					autoSize:		'left',
					embedFonts:		false,
					fontSize:		12,
					color:			0xcccccc,
					borderSize:		0,
					bold:			true
				});
				actionLabel.x = 20;
				actionLabel.y = position;
				container.addChild(actionLabel);
				
				position += actionLabel.height;
				position += 6;
			}
		}
		
	}
	
	
	// рисование обновлений
	public function drawUpdates(uid:*):void {
		if (!App.data.updates[uid]) return;
		
		dispose();
		
		this.sid = uid;
		
		var info:Object = App.data.updates[uid];
		var position:int = 0;
		
		var title:TextField = Window.drawText(info.title + ' ' + uid, {
			fontFamily:		'Arial',
			autoSize:		'left',
			embedFonts:		false,
			fontSize:		24,
			color:			0xcccccc,
			borderSize:		0,
			bold:			true
		});
		title.selectable = true;
		title.mouseEnabled = true;
		container.addChild(title);
		
		position = title.y + title.height + 4;
		
		// Общая инфа
		var subtitle3:TextField = Window.drawText((info.enabled) ? 'Включена' : 'Отключена', {
			fontFamily:		'Arial',
			autoSize:		'left',
			embedFonts:		false,
			fontSize:		24,
			color:			(info.enabled) ? 0x66dd33 : 0xcc0000,
			borderSize:		0,
			bold:			true
		});
		subtitle3.x = 20;
		subtitle3.y = position;
		container.addChild(subtitle3);
		
		position += subtitle3.height + 6;
		
		// Соц.сети
		subtitle1 = Window.drawText('Соц.сети:', {
			fontFamily:		'Arial',
			autoSize:		'left',
			embedFonts:		false,
			fontSize:		18,
			color:			0xcccccc,
			borderSize:		0,
			bold:			true
		});
		subtitle1.y = position;
		container.addChild(subtitle1);
		
		position += subtitle1.height + 1;
		
		sublist1 = new QueueList(info.social, currWidth, getObject('social'));
		sublist1.y = position + 4;
		container.addChild(sublist1);
		
		position += sublist1.height + 8;
		
		// Объекты
		subtitle2 = Window.drawText('Объекты:', {
			fontFamily:		'Arial',
			autoSize:		'left',
			embedFonts:		false,
			fontSize:		18,
			color:			0xcccccc,
			borderSize:		0,
			bold:			true
		});
		subtitle2.y = position;
		container.addChild(subtitle2);
		
		position += subtitle2.height + 1;
		
		var items:Array = [];
		for (var s:* in info.items) {
			items.push(s);
		}
		items.sort();
		
		sublist2 = new QueueList(items, currWidth, getObject(Extended.DECOR));
		sublist2.y = position + 4;
		container.addChild(sublist2);
		
		position += sublist2.height + 8;
		
		// Квесты
		subtitle4 = Window.drawText('Квесты:', {
			fontFamily:		'Arial',
			autoSize:		'left',
			embedFonts:		false,
			fontSize:		14,
			color:			0xcccccc,
			borderSize:		0,
			bold:			true
		});
		subtitle4.y = position;
		container.addChild(subtitle4);
		
		position += subtitle4.height + 1;
		
		sublist3 = new QueueList((info.quests_all) ? info.quests_all : [], currWidth, getObject(Extended.QUESTS));
		sublist3.y = position + 4;
		container.addChild(sublist3);
		
		position += sublist3.height + 8;
		
		// Все обновления
		subtitle5 = Window.drawText('Все обновления:', {
			fontFamily:		'Arial',
			autoSize:		'left',
			embedFonts:		false,
			fontSize:		14,
			color:			0xcccccc,
			borderSize:		0,
			bold:			true
		});
		subtitle5.y = position;
		container.addChild(subtitle5);
		
		position += subtitle5.height + 4;
		
		items.length = 0;
		var temp:Array = [];
		for (s in App.data.updatelist[App.social]) {
			temp.push({u:s, o:App.data.updatelist[App.social][s]});
		}
		temp.sortOn('o', Array.NUMERIC);
		
		for (var i:int = 0; i < temp.length; i++) {
			items.push(temp[i].u);
		}
		
		// Обновления
		sublist4 = new QueueList(items, currWidth, getObject(Extended.UPDATES));
		sublist4.y = position + 4;
		container.addChild(sublist4);
		
		position += sublist4.height + 8;
		
	}
	
	
	// Рисование описания 
	public function draw(sid:*):void {
		
		if (!App.data.storage[sid]) return;
		
		dispose();
		
		this.sid = sid;
		
		var info:Object = App.data.storage[sid];
		var position:int = 0;
		
		var buyImage:BitmapData = new BitmapData(75, 26, true, 0xffeeeeee);
		
		subtitle1 = Window.drawText('Купить', {
			fontFamily:		'Arial',
			autoSize:		'left',
			embedFonts:		false,
			fontSize:		16,
			color:			0x111111,
			borderSize:		0,
			bold:			true
		});
		buyImage.draw(subtitle1, new Matrix(1,0,0,1,8,2));
		
		var buyBttn:ImageButton = new ImageButton(buyImage);
		buyBttn.y = 3;
		buyBttn.addEventListener(MouseEvent.CLICK, function(e:*):void {
			App.user.stock.buy(sid, 1, function(... args):void {
				Hints.plus(sid, 1, new Point(App.self.mouseX, App.self.mouseY), false, App.self);
			});
		});
		container.addChild(buyBttn);
		
		var title:TextField = Window.drawText(info.title + ' (' + info.type + ') ' + sid, {
			fontFamily:		'Arial',
			autoSize:		'left',
			embedFonts:		false,
			fontSize:		24,
			color:			0xcccccc,
			borderSize:		0,
			bold:			true
		});
		title.x = 80;
		title.selectable = true;
		title.mouseEnabled = true;
		container.addChild(title);
		
		position = title.y + title.height + 6;
		
		var object:Object = Extended.getInfo(sid);
		
		for (var s:* in object) {
			var text:TextField = Window.drawText(String(s), {
				fontFamily:		'Arial',
				autoSize:		'left',
				embedFonts:		false,
				fontSize:		15,
				color:			0xcccccc,
				borderSize:		0,
				bold:			true
			});
			text.y = position;
			container.addChild(text);
			
			position += text.height + 1;
			
			for (var ss:* in object[s]) {
				if (!(object[s][ss] is Array)) continue;
				
				var posLabel:TextField = Window.drawText(getSubTitle(s, ss), {
					fontFamily:		'Arial',
					autoSize:		'left',
					embedFonts:		false,
					fontSize:		12,
					color:			0xcccccc,
					borderSize:		0,
					bold:			true
				});
				posLabel.x = 10;
				posLabel.y = position;
				container.addChild(posLabel);
				
				position += posLabel.height + 1;
				
				var list:QueueList = new QueueList(object[s][ss], currWidth - posLabel.x, getObject(s, ss));
				list.x = posLabel.x;
				list.y = position + 4;
				container.addChild(list);
				
				position += list.height + 8;
			}
			
		}
		
	}
	
	private function getObject(source:*, type:* = null):Object {
		var object:Object;
		
		switch(source) {
			case Extended.PLANT:
			case Extended.BUILDING:
			case Extended.ANIMAL:
			case Extended.RESOURCE:
			case Extended.DECOR:
				object = {
					type:		'storage',
					getLink:	getIcon,
					click:		onClick
				}
				break;
			case Extended.QUESTS:
				object = {
					type:		'quests',
					getLink:	getQuestIcon,
					click:		onClick
				}
				break;
			case Extended.UPDATES:
				object = {
					type:		'updates',
					getLink:	getUpdateIcon,
					getTitle:	getUpdateTitle,
					click:		onClick,
					width:		60,
					height:		74
				}
				break;
			
		}
		
		return object;
	}
	
	// External functional for items
	private function getIcon(sid:*):String {
		return (App.data.storage[sid]) ? Config.getIcon(App.data.storage[sid].type, App.data.storage[sid].preview) : '';
	}
	private function getQuestIcon(qid:*):String {
		return (App.data.quests[qid]) ? Config.getQuestIcon('icons', App.data.personages[App.data.quests[qid].character].preview) : '';
	}
	private function getUpdateIcon(uid:*):String {
		return (App.data.updates[uid]) ? Config.getImageIcon('updates/images', App.data.updates[uid].preview) : '';
	}
	private function getUpdateTitle(uid:*):String {
		return (App.data.updates[uid]) ? App.data.updates[uid].title : uid;
	}
	
	//
	private function onClick(object:*):void {
		
		if (object.params.type == 'storage' || object.params.type == 'quests' || object.params.type == 'updates')
			Admin.chooseStorageID(object.params.sid, object.params.type);
		
	}
	
	private function getSubTitle(source:*, type:*):String {
		switch(source) {
			case Extended.RESOURCE:
				return 'Добывается в ресурсах:';
			case Extended.BUILDING:
				if (type == 'craft') {
					return 'Крафтится в зданиях:';
				}else if (type == 'component') {
					return 'Используется в крафте в зданиях:';
				}
			case Extended.RESOURCE:
				return 'Добывается в ресурсах:';
			case Extended.DECOR:
				return 'Падает из декора:';
			case Extended.ANIMAL:
				return 'Падает из животного:';
			case Extended.PLANT:
				return 'Можно вырастить:';
			case Extended.QUESTS:
				if (type == 'target') {
					return 'Используесть в квестах:';
				}else if (type == 'bonus') {
					return 'Дается бонусом за квесты:';
				}
				break;
			case Extended.UPDATES:
				return 'Обновления'
				break;
		}
		
		return String(type);
	}
	
	
	public function dispose():void {
		
		container.y = 0;
		
		while (container.numChildren) {
			var child:* = container.getChildAt(0);
			if (child is QueueList) {
				child.dispose();
			}else {
				container.removeChild(child);
			}
		}
	}
	
}

internal class QueueList extends Sprite {
	
	private var itemList:Vector.<QueueItem> = new Vector.<QueueItem>;
	
	public function QueueList(list:*, width:int = 200, extra:Object = null):void {
		
		var marginX:int = 0;
		var marginY:int = 0;
		var maxHeight:int = 0;
		
		if (!extra) extra = { };
		
		for each(var sid:* in list) {
			
			// Иконка
			var params:Object = {
				sid:		sid,
				text:		sid.toString()
			}
			
			if (extra) {
				for (var s:* in extra) {
					params[s] = extra[s];
				}
			}
			
			if (extra.getLink != null)
				params['link'] = extra.getLink(sid);
			
			if (extra.getTitle != null)
				params['text'] = extra.getTitle(sid);
			
			var item:QueueItem = new QueueItem(params);
			item.x = marginX;
			item.y = marginY;
			addChild(item);
			
			itemList.push(item);
			
			// Рассчет смещения
			if (item.height > maxHeight)
				maxHeight = item.height;
			
			marginX += item.width + 2;
			if (marginX + item.width > width) {
				marginY += maxHeight + 2;
				marginX = 0;
				maxHeight = 0;
			}
			
			//
		}
		
	}
	
	public function dispose():void {
		while (itemList.length) {
			itemList.shift().dispose();
		}
		
		if (parent) parent.removeChild(this);
	}
	
}

internal class QueueItem extends Sprite {
	
	private var image:Bitmap;
	private var textField:TextField;
	
	public var params:Object = {
		text:		'',
		backColor:	0xcccccc,
		fontColor:	0x111111,
		link:		null,
		width:		40,
		height:		50
	}
	
	public function QueueItem(params:Object = null) {
		
		if (params) {
			for (var s:* in params) {
				this.params[s] = params[s];
			}
		}
		
		textField = Window.drawText(text, {
			fontFamily:		'Arial',
			autoSize:		'left',
			embedFonts:		false,
			fontSize:		11,
			color:			fontColor,
			borderSize:		0,
			bold:			true
		});
		
		if (link) {
			image = new Bitmap();
			addChild(image);
			
			Load.loading(link, function(data:Bitmap):void {
				image.bitmapData = data.bitmapData;
				image.smoothing = true;
				Size.size(image, currWidth, currHeight);
				image.x = currWidth * 0.5 - image.width * 0.5;
				image.y = currHeight * 0.5 - image.height * 0.5;
			});
			
			if (textField.width > currWidth) {
				var textFormat:TextFormat = textField.getTextFormat();
				while (textField.width > currWidth && textFormat.size > 2) {
					textFormat.size = int(textFormat.size) - 1;
					textField.setTextFormat(textFormat);
				}
			}
			textField.x = currWidth * 0.5 - textField.width * 0.5;
			textField.y = currHeight - textField.height;
		}
		
		addChild(textField);
		
		graphics.beginFill(backColor);
		graphics.drawRect(0, 0, currWidth, currHeight);
		graphics.endFill();
		
		addEventListener(MouseEvent.CLICK, onClick);
		addEventListener(MouseEvent.MOUSE_OVER, onOver);
		addEventListener(MouseEvent.MOUSE_OUT, onOut);
	}
	
	protected function get text():String {
		return params.text;
	}
	protected function get link():String {
		return params.link;
	}
	protected function get backColor():uint {
		return params.backColor;
	}
	protected function get fontColor():uint {
		return params.fontColor;
	}
	protected function get currWidth():uint {
		return (link) ? params.width : textField.width;
	}
	protected function get currHeight():uint {
		return (link) ? params.height : textField.height;
	}
	
	private function onClick(e:MouseEvent):void {
		if (params.click != null && params.click is Function) {
			params.click(this);
		}
		
		//Admin.chooseStorageID(params.sid, params.type);
	}
	private function onOver(e:MouseEvent):void {
		graphics.beginFill(0xffffff);
		graphics.drawRect(0, 0, currWidth, currHeight);
		graphics.endFill();
	}
	private function onOut(e:MouseEvent):void {
		graphics.beginFill(backColor);
		graphics.drawRect(0, 0, currWidth, currHeight);
		graphics.endFill();
	}
	
	public function dispose():void {
		removeEventListener(MouseEvent.CLICK, onClick);
		removeEventListener(MouseEvent.MOUSE_OVER, onOver);
		removeEventListener(MouseEvent.MOUSE_OUT, onOut);
		
		if (parent) parent.removeChild(this);
	}

	
	
}