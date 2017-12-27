package wins 
{
	import buttons.Button;
	import com.greensock.TweenMax;
	import core.Numbers;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.GradientType;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.net.SharedObject;
	import flash.text.TextField;
	import flash.utils.setTimeout;
	import ui.UpPanel;
	import ui.UserInterface;
	import units.Hut;
	import units.Techno;
	import units.WorkerUnit;

	public class HutWindow extends Window
	{
		
		public var slots:Vector.<WorkerSlot> = new Vector.<WorkerSlot>;
		
		public var hut:Hut = null;
		public var workerCount:int = 0;
		private var items:Vector.<WorkerSlot> = new Vector.<WorkerSlot>;
		public var state:uint;
		
		public function HutWindow(settings:Object = null) 
		{
			if (settings == null) {
				settings = new Object();
			}
			
			state = settings['state'] || 0;
			
			hut = settings.target;
			workerCount = hut.workerCount;
			
			if (state == Hut.KLIDE_HOUSE)
				workerCount = 1;
			
			if (workerCount <= 0) workerCount = Numbers.countProps(hut.workers);
			
			settings['width'] = (workerCount >= 3) ? 690 : 500;
			settings['height'] = (workerCount > 3) ? 680 : 410;
			settings['hasPaper'] = true;
			settings['title'] = hut.info.title;
			settings['background'] = 'shopBackingTop';
			settings['titleScaleX'] = 0.76;
			settings['titleScaleY'] = 0.76;
			settings['hasPaginator'] = true;
			settings['onPageCount'] = 6;
			settings['description'] = Locale.__e("flash:1382952380164");
			settings['shadowColor'] = 0x513f35;
			settings['shadowSize'] = 4;
			
			settings['questHelp'] = settings.questHelp || false;
			settings['helpSID'] = settings.helpSID || 0;
			
			
			super(settings);
		}
		
		public var upgradeButton:Button;
		public var treatButton:Button;
		public var cont:Sprite;
		override public function drawBody():void 
		{
			exit.x += 6;
			exit.y -= 4;
			
			drawInfo();
			cont = new Sprite();
			bodyContainer.addChild(cont);
			contentChange();
			cont.x = (settings.width - cont.width) / 2;
			cont.y = 120;
			
			App.self.setOnTimer(timer);
			
			var upgradeParams:Object = {
				caption:Locale.__e('flash:1425574338255'),
				bgColor:[0x7bc9f9, 0x60aedf],
				bevelColor:[0xa5ddfb, 0x266fad],
				borderColor:[0xd5c2a9, 0xbca486],
				fontSize:26,
				fontBorderColor:0x40505f,
				shadowColor:0x40505f,
				shadowSize:4,
				width:210,
				height:52
			};
			upgradeButton = new Button(upgradeParams);
			upgradeButton.x = (settings.width - upgradeButton.width) / 2;
			upgradeButton.y = 20;////settings.height -  upgradeButton.height - 80;
			
			var treatParams:Object = {
				caption:Locale.__e('flash:1437031110156'),
				bgColor:[0x7bc9f9, 0x60aedf],
				bevelColor:[0xa5ddfb, 0x266fad],
				borderColor:[0xd5c2a9, 0xbca486],
				fontSize:26,
				fontBorderColor:0x7f4c2f,
				shadowColor:0x7f4c2f,
				shadowSize:4,
				width:180,
				height:52
			};
			treatButton = new Button(treatParams);
			treatButton.x = (settings.width - treatButton.width) / 2;
			treatButton.y = settings.height - 80;
			bodyContainer.addChild(treatButton);
			treatButton.addEventListener(MouseEvent.CLICK, onTreatButtonEvent);
			
			if (settings.questHelp == true) {
				treatButton.showGlowing();
			}
			
			var feedParams:Object = {
				caption:Locale.__e('flash:1428408092399'),
				bgColor:[0xfed444, 0xf4aa27],
				bevelColor:[0xfde96c, 0xc67d0c],
				borderColor:[0xd4c4ab, 0xc4b29c],
				fontSize:26,
				fontBorderColor:0x7f4c2f,
				shadowColor:0x7f4c2f,
				shadowSize:4,
				width:180,
				height:52
			};
			if (hut.workers[0].worker.sid == Techno.LELIK || hut.workers[0].worker.sid == Techno.BOLIK) feedParams.caption = Locale.__e('flash:1439220742762');
			feedButton = new Button(feedParams);
			feedButton.x = (settings.width - feedButton.width) / 2;
			feedButton.y = settings.height - 80;
			bodyContainer.addChild(feedButton);
			feedButton.addEventListener(MouseEvent.CLICK, onFeedButtonEvent);
			
			//if (App.isSocial('FB', 'NK')) {
				//treatButton.visible = false;
				//feedButton.visible = true;
			//} else {
				feedButton.visible = true;
				feedButton.x = 65;
				treatButton.visible = true;
				treatButton.x = feedButton.x + feedButton.width + 10;
			//}
			
			if (hut.level == hut.totalLevels || state == Hut.KLIDE_HOUSE)
				return;
			
			bodyContainer.addChild(upgradeButton);
			upgradeButton.addEventListener(MouseEvent.CLICK, onUpgradeButtonEvent);
			
			if ((settings.target == App.user.quests.currentTarget) && App.user.quests.data.hasOwnProperty(72) && App.user.quests.data[72].finished == 0) {
				App.user.quests.currentTarget = null;
				glowing();
			}
			
			if (settings.glowUpgrade) {
				glowing();
			}
		}
		
		private function glowing():void {
			if (upgradeButton) {
				if (!App.user.quests.tutorial) {
					customGlowing(upgradeButton, glowing);
				}
			}
		}
		
		private function customGlowing(target:*, callback:Function = null):void {
			TweenMax.to(target, 1, { glowFilter: { color:0xFFFF00, alpha:0.8, strength: 7, blurX:12, blurY:12 }, onComplete:function():void {
				TweenMax.to(target, 0.8, { glowFilter: { color:0xFFFF00, alpha:0.6, strength: 7, blurX:6, blurY:6 }, onComplete:function():void {
					if (callback != null) {
						callback();
					}
				}});	
			}});
		}
		
		public var feedButton:Button;
		private function onTreatButtonEvent(e:MouseEvent):void {
			close();
			new TreatWindow( {
				target: hut,
				helpSID: settings.helpSID
			}).show();
			/*new HutHireWindow( {
				target:		hut,
				sID:		Techno.TECHNO
			}).show();*/
		}
		
		private function onFeedButtonEvent(e:MouseEvent):void {
			if (hut.info.devel.req[hut.level].time + App.time <= hut.workers[0].finished) {
				new SimpleWindow( {
					title: Locale.__e('flash:1382952379828'),
					text: Locale.__e('flash:1436954683396'),
					popup: true
				}).show();
				return;
			}
			close();
			/*new HutHireWindow( {
				target:		hut,
				sID:		Techno.TECHNO
			}).show();*/
			
			if (hut) {
				hut.openHireWindow();
			}
		}
		
		private function onUpgradeButtonEvent(e:MouseEvent):void {
			var sidNextKettle:int;
			switch(hut.level + 1) {
				case 2:
					sidNextKettle = 316;
				break;
				case 3:
					sidNextKettle = 317;
				break;
				default:
					sidNextKettle = 316;
			}
			
			hut.openUpgradeWindow(sidNextKettle);
			close();
		}
		
		override public function drawArrows():void {
			super.drawArrows();
			
			paginator.x -= 30;
			paginator.y += 40;
			paginator.arrowLeft.x -= 15;
			paginator.arrowLeft.y -= 15;
			paginator.arrowRight.x += 15;
			paginator.arrowRight.y -= 15;
		}
		
		override public function contentChange():void {
			contentClear();
			
			var skiped:Array = [];
			var workers:Array = [];
			for (var s:* in hut.workers) {
				workers.push( { worker:hut.workers[s], id:hut.workers[s].workerID } );
			}
			workers.sortOn('id', Array.NUMERIC);
			
			if (paginator) {
				paginator.itemsCount = workerCount;
				paginator.update();
				
				if (paginator.itemsCount <= paginator.onPageCount) {
					paginator.visible = false;
				}else {
					paginator.visible = true;
				}
			}
			
			for (var i:int = 0; i < paginator.onPageCount; i++) {
				if (paginator.page * paginator.onPageCount + i >= workerCount) continue;
				
				var item:WorkerSlot = new WorkerSlot( {
					width:		180,
					height: 	250,
					worker:		(workers[paginator.page * paginator.onPageCount + i]) ? workers[paginator.page * paginator.onPageCount + i].worker : null
				}, this);
				item.x = /*66 + */190 * (i % 3);
				item.y = /*70 + */int(i / 3) * 260;
				cont.addChild(item);
				slots.push(item);
			}
			
			function getWorker():Object {
				for (var s:* in hut.workers) {
					if (skiped.indexOf(s) < 0) {
						skiped.push(s);
						return hut.workers[s];
					}
				}
				return null;
			}
		}
		private function contentClear():void {
			while (slots.length > 0) {
				var item:WorkerSlot = slots.shift();
				item.dispose();
			}
		}
		
		private var onHireCallback:Function;
		public function hire(callback:Function = null):void {
			//onHireCallback = callback;
			
			/*new HutHireWindow( {
				sID:		getWorkerSID(),
				target:		hut,
				popup:		true,
				onHire:		callback
			}).show();*/
			
			function getWorkerSID():int {
				//if (hut.info.hasOwnProperty('outs') && Numbers.countProps(hut.info.outs) > 0) {
					//for (var sid:* in hut.info.outs) {
						//return int(sid);
					//}
				//}
				
				return Techno.TECHNO;
			}
		}
		
		public function fire(worker:Techno):void {
			hut.removeWorker(worker);
			contentChange();
		}
		
		private function timer():void {
			for (var i:int = 0; i < slots.length; i++) {
				slots[i].timer();
			}
		}
		
		private function drawInfo():void 
		{
			var container:Sprite = new Sprite();
			
			if (state == Hut.KLIDE_HOUSE) {
				var text3:TextField = drawText(Locale.__e('flash:1425054392659'), {
					autoSize:		'left',
					color:			0xffffff,
					borderColor:	0x553317,
					fontSize:		23,
					shadowSize:		1.5
				});
				container.addChild(text3);
			}else{
				var text1:TextField = drawText(Locale.__e('flash:1424959564860'), {
					autoSize:		'left',
					color:			0xffffff,
					borderColor:	0x553317,
					fontSize:		23,
					shadowSize:		1.5
				});
				container.addChild(text1);
				
				var clock:Bitmap = new Bitmap(Window.textures.timerSmall);
				clock.x = text1.x + text1.width + 6;
				clock.y = -2;
				container.addChild(clock);
				
				var _time:int = hut.info.devel.req[hut.level].time;
				var text2:TextField = drawText(TimeConverter.timeToCuts(_time, false, true), {
					autoSize:		'left',
					color:			0xffffff,
					borderColor:	0x553317,
					fontSize:		23,
					shadowSize:		1.5
				});
				text2.x = clock.x + clock.width + 6;
				container.addChild(text2);
			}
			
			var matrix:Matrix = new Matrix();
			matrix.createGradientBox(container.width + 40, 30);
			
			var shape:Shape = new Shape();
			shape.graphics.beginGradientFill(GradientType.LINEAR, [0xffffff, 0xffffff, 0xffffff, 0xffffff], [0, 0.4, 0.4, 0], [0, 32, 223, 255], matrix);
			shape.graphics.drawRect(0, 0, container.width + 40, 30);
			shape.graphics.endFill();
			bodyContainer.addChild(shape);
			bodyContainer.addChild(container);
			
			shape.x = (settings.width - shape.width) / 2;
			shape.y = 26 + 60;
			container.x = shape.x + (shape.width - container.width) / 2;
			container.y = shape.y + (shape.height - container.height) / 2 + 2;
		}
		
		override public function dispose():void {
			super.dispose();
			
			App.self.setOffTimer(timer);
		}
		
	}
}


import buttons.Button;
import buttons.ImageButton;
import com.greensock.TweenLite;
import core.Load;
import core.TimeConverter;
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.text.TextField;
import ui.UserInterface;
import units.AnimationItem;
import units.Hut;
import units.Personage;
import units.Techno;
import units.Unit;
import units.WorkerUnit;
import wins.elements.TimeIcon;
import wins.Window;
import wins.HutWindow;
//showshopwnmport wins.JamWindow;
import wins.WindowEvent;
import wins.ProgressBar;
import wins.SimpleWindow;

internal class WorkerSlot extends LayerX {
	
	public static const FREE:uint = 0;
	public static const BUSY:uint = 1;
	
	private var image:Bitmap;
	private var backing:ImageButton;
	private var addBttn:Button;
	private var fireBttn:Button;
	private var removeBttn:ImageButton;
	private var timeIcon:TimeIcon
	private var workerLabel:TextField;
	private var progressBar:ProgressBar;
	
	private var _state:uint = FREE;
	
	public var workerInfo:Object;
	public var window:*;
	public var worker:Techno;
	public var aboutWorker:Object;
	
	public var boostIco:Bitmap;
	public var boostSprite:LayerX;
	
	public function WorkerSlot(workerInfo:Object, window:*):void {
		this.workerInfo = workerInfo;
		this.window = window;
		
		if (workerInfo.worker) {
			worker = workerInfo.worker.worker;
		}
		
		if (worker) {
			state = BUSY;
		}
		
		aboutWorker = (worker) ? App.data.storage[worker.sid] : App.data.storage[Stock.TECHNO];
		
		draw();
		
		addEventListener(MouseEvent.CLICK, onBackClick, false, -10);
		
		tip = function():Object {
			if (worker && worker.workStatus == WorkerUnit.FREE) {
				return {
					title:		aboutWorker.title,
					text:		Locale.__e('flash:1424951404354')
				}
			}else if (worker && worker.workStatus == WorkerUnit.BUSY && worker.target) {
				//return {
					//title:		aboutWorker.title,
					//text:		Locale.__e('flash:1424951587878', [App.data.storage[worker.target.formula.out].title]) + '\n' + Locale.__e('flash:1424961447021') + ': ' + TimeConverter.timeToCuts((worker.target.crafted > App.time) ? (worker.target.crafted - App.time) : 0, true, true),
					//timer:		true
				//}
			}
			
			return {
				title:		aboutWorker.title,
				text:		Locale.__e('flash:1424781985804')
			}
		}
	}
	
	public function draw():void {
		clear();
		
		workerInfo.height -= 50
		var _backing:Bitmap = Window.backing(workerInfo.width, workerInfo.height, 50, 'itemBacking');
		backing = new ImageButton(_backing.bitmapData);
		addChild(backing);
		
		image = new Bitmap();
		addChild(image);
		
		//Load.loading(Config.getIcon(aboutWorker.type, aboutWorker.preview), onLoad);
		
		var _framesType:String = 'rest1';
		if (worker && worker.workStatus == WorkerUnit.BUSY)
			_framesType = Personage.HARVEST;
		
		var _worker:AnimationItem = new AnimationItem( {
			type:aboutWorker.type,
			view:aboutWorker.view,
			direction:0,
			framesType:_framesType
		});
		addChild(_worker);
		_worker.mouseEnabled = false;
		_worker.mouseChildren = false;
		
		//_worker.scaleX = _worker.scaleY = 1.1;
		
		_worker.x = (backing.width) / 2;
		_worker.y = (backing.height) / 2 + 20;
		
		if (worker.sid == Techno.LELIK) _worker.y = (backing.height) / 2 - 25;
		if (worker.sid == Techno.BOLIK) _worker.y = (backing.height) / 2 - 10;
		
		if (window.state == Hut.KLIDE_HOUSE) return;
		
		//if (!App.isSocial('FB')) {
			boostSprite = new LayerX();
			
			boostIco = new Bitmap(Window.textures.foodIcoBoost);
			boostSprite.x = backing.width - boostIco.width - 5;
			boostSprite.y = 10;
			boostSprite.addChild(boostIco);
			addChild(boostSprite);
			
			boostSprite.tip = function():Object {
				return {
					text: Locale.__e('flash:1437038519529')
				};
			}
			
			if (window.settings.target.food) {
				boostSprite.visible = true;
			} else {
				boostSprite.visible = false;
			}
		//}
		if (state == BUSY) {
			
			var progressContainer:Sprite = new Sprite();
			progressContainer.scaleX = progressContainer.scaleY = 0.78;
			addChild(progressContainer);
			
			var progressBarBacking:Bitmap = Window.backingShort(180, 'progBarBacking');
			progressContainer.addChild(progressBarBacking);
			
			progressBar = new ProgressBar( {
				width:			194,
				win:			window,
				isTimer:		false
			});
			progressBar.x = progressBarBacking.x - 8;
			progressBar.y = progressBarBacking.y - 4;
			progressContainer.addChild(progressBar);
			progressBar.start();
			
			timeIcon = new TimeIcon(0, backing.width - 30);
			timeIcon.timeLabel.y -= 14;
			timeIcon.x = (backing.width - timeIcon.width) / 2 - 25;
			//timeIcon.y = backing.height - 95;
			timeIcon.y = workerInfo.height - 50;
			addChild(timeIcon);
			timer();
			
			progressContainer.x = timeIcon.x + (timeIcon.width - progressContainer.width) / 2 + 5 - 5;
			progressContainer.y = timeIcon.y + (timeIcon.height - progressContainer.height) / 2 + 2;
			
			if (window.state == 0) {
				fireBttn = new Button({
					width:			126,
					height:			38,
					fontSize:		22,
					caption:		Locale.__e('flash:1382952379774'),
					bgColor:		[0xfecbac, 0xce4c2a],	//Цвета градиента
					borderColor:	[0x000000, 0x000000],	//Цвета градиента
					bevelColor:		[0xffa56a, 0xd14b28],
					fontColor:		0xfffcff,
					borderColor:	0x7f3218
				});
				fireBttn.x = backing.x + (backing.width - fireBttn.width) / 2;
				fireBttn.y = backing.height - fireBttn.height - 14;
				//addChild(fireBttn);
				fireBttn.addEventListener(MouseEvent.CLICK, onFire);
				
				removeBttn = new ImageButton(Window.textures.closeBttn);
				removeBttn.scaleX = removeBttn.scaleY = 0.6;
				removeBttn.x = backing.x + backing.width - removeBttn.width + 1;
				//addChild(removeBttn);
				removeBttn.addEventListener(MouseEvent.CLICK, onFire);
			}
			
		}else {
			
			
			timeIcon = new TimeIcon(0);
			addChild(timeIcon);
			
			timeIcon.x = (backing.width - timeIcon.width) / 2;
			timeIcon.y = backing.height - 95;
			
			addBttn = new Button( {
				width:			126,
				height:			38,
				fontSize:		22,
				caption:		Locale.__e('flash:1396367321622'),
				onClick:		onAdd
			});
			addChild(addBttn);
			image.alpha = 0.5;
			
			addBttn.x = (backing.width - addBttn.width) / 2;
			addBttn.y = backing.height - addBttn.height - 14;
		}
		
	}
	
	private function onLoad(data:*):void {
		image.bitmapData = data.bitmapData;
		image.smoothing = true;
		
		if (window.state == Hut.KLIDE_HOUSE) {
			image.x = (backing.width - image.width) / 2;
			image.y = (backing.height - image.height) / 2;
		}else {
			image.x = (backing.width - image.width) / 2;
			image.y = (backing.height - image.height) / 2 - 20;
		}
	}
	
	public function updateState():void {
		if (worker && state == FREE) {
			state = BUSY;
			draw();
		}else if (!worker && state == BUSY) {
			state = FREE;
			draw();
		}
	}
	
	private function onAdd(e:MouseEvent = null):void {
		window.hire(onHire);
	}
	private function onHire(worker:Techno):void {
		//this.worker = worker;
		window.contentChange();
	}
	private function onFire(e:MouseEvent = null):void {
		new SimpleWindow( {
			dialog:		true,
			popup:		true,
			title:		aboutWorker.title,
			text:		Locale.__e('flash:1425047185149'),
			confirm:	function():void {
				window.fire(worker);
			}
		}).show();
		
		if (e) e.stopImmediatePropagation();
	}
	private function onBackClick(e:MouseEvent = null):void {
		if (worker) {
			App.map.focusedOn(worker, true);
			window.close();
		}
	}
	
	
	// State
	public function get state():uint {
		return _state;
	}
	public function set state(value:uint):void {
		if (_state == value) return;
		_state = value;
	}
	
	
	// Add worker
	public function addWorker(workerInfo:Object = null):void {
		if (!workerInfo) return;
		this.workerInfo = workerInfo;
		
		draw();
	}
	
	// Clear
	public function clear():void {
		for (var i:int = numChildren - 1; i > -1; i--) {
			var child:* = getChildAt(i);
			if (child is Button) {
				child.dispose();
			}
			if (contains(child)) removeChild(child);
			child = null;
		}
	}
	
	public function timer():void {
		if (state == BUSY) {
			var time:int = 0;
			if (window.state != Hut.KLIDE_HOUSE) {
				/*time = worker.ended - App.time;
				if (time < 0) time = 0;
				timeIcon.timeLabel.text = TimeConverter.timeToStr(time);
				*/
				time = workerInfo.worker.finished - App.time;
				
				if (time < 0) time = 0;
				timeIcon.timeLabel.text = TimeConverter.timeToStr(time);
				
				if (progressBar) {
					progressBar.progress = 1 - time / window.hut.info.devel.req[window.hut.level].time;
				}
			}else {
				/*time = worker.target.crafted - App.time;
				if (time < 0) time = 0;
				timeIcon.timeLabel.text = TimeConverter.timeToStr(time);
				
				if (progressBar) {
					progressBar.progress = 1 - (worker.ended - App.time) / window.hut.info.time;
				}*/
			}
		}
		
	}
	
	public function dispose():void {
		clear();
		
		removeEventListener(MouseEvent.CLICK, onBackClick);
		if (removeBttn) removeBttn.removeEventListener(MouseEvent.CLICK, onFire);
		if (fireBttn) fireBttn.removeEventListener(MouseEvent.CLICK, onFire);
		if (parent) parent.removeChild(this);
	}
}