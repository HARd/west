package wins 
{
	import buttons.Button;
	import buttons.MoneyButton;
	import com.greensock.easing.Cubic;
	import com.greensock.plugins.BezierThroughPlugin;
	import com.greensock.plugins.TweenPlugin;
	import com.greensock.TweenLite;
	import com.greensock.TweenMax;
	import core.Post;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.BlurFilter;
	import flash.filters.DropShadowFilter;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	import silin.utils.Hint;
	import ui.Hints;
	import units.Thimbles;
	
	public class ThimbleWindow extends Window 
	{
		
		public static const WAIT:String = 'wait';
		public static const PRESHUFFLE:String = 'preshuffle';
		public static const SHUFFLE:String = 'shuffle';
		public static const CHOOSE:String = 'choose';
		public static const CHOOSED:String = 'choosed';
		
		private var backing:Bitmap;
		private var playBttn:Button;
		private var buyPlayBttn:MoneyButton;
		private var container:Sprite;
		private var descLabel:TextField;
		private var timerDescLabel:TextField;
		private var timerLabel:TextField;
		private var chooseBoxLabel:TextField;
		
		private var treasures:Array;
		private var thimbles:Vector.<Thimble> = new Vector.<Thimble>;
		public var target:Thimbles;
		
		private var _state:String = WAIT;
		
		public function ThimbleWindow(settings:Object = null) 
		{
			
			//var that:* = this;
				//Treasures.bonus({{"2":{"1":3},"5":{"1":1},"48":{"1":1}}, new Point(that.x, that.y));
			
			if (!settings) settings = { };
			settings['width'] = settings['width'] || 650;
			settings['height'] = settings['height'] || 465;
			settings['hasPaginator'] = false;
			settings['title'] = settings.target.info.title;
			//settings['faderClickable'] = false;
			target = settings.target;
			
			super(settings);
			
			TweenPlugin.activate([BezierThroughPlugin]);
			
			App.self.setOnTimer(timer);
		}
		
		public function timer():void {
			var time:int = App.nextMidnight - App.time;
			if (timerLabel) {
				if (target.played < App.midnight && timerLabel.alpha > 0) {
					timerHide();
				}else{
					timerLabel.text = TimeConverter.timeToStr(time);
				}
			}
			
		}
		
		public function set state(value:String):void {
			if (value != WAIT) {
				TweenMax.to(playBttn, 0.25, { alpha:0} );
				TweenMax.to(buyPlayBttn, 0.25, { alpha:0} );
				TweenLite.to(exit, 0.25, {alpha:0, onComplete:function():void {
					playBttn.visible = false;
					buyPlayBttn.visible = false;
					exit.visible = false;
				}})
			}else {
				exit.visible = true;
				TweenMax.to(playBttn, 0.25, { alpha:1 } );
				TweenMax.to(buyPlayBttn, 0.25, { alpha:1 } );
				TweenMax.to(exit, 0.25, { alpha:1 } );
			}
			
			_state = value;
		}
		public function get state():String {
			return _state;
		}
		
		override public function drawBackground():void {
			background = backing2(settings.width, settings.height, 100, 'stockBackingTopWithoutSlate', 'stockBackingBot');
			layer.addChild(background);
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
				shadowSize			:4
			});
			titleLabel.x = (settings.width - titleLabel.width) * .5;
			titleLabel.y = - 15;
			titleLabel.mouseChildren = titleLabel.mouseEnabled = false;
			headerContainer.addChild(titleLabel);
			headerContainer.y = 37;
			headerContainer.mouseEnabled = false;
		}
		
		override public function drawBody():void {
			backing = Window.backing(520, 220);
			backing.alpha = 0;
			backing.x = (settings.width - backing.width) / 2;
			backing.y = 72;
			bodyContainer.addChild(backing);
			
			exit.y -= 15;
			
			descLabel = drawText(Locale.__e('flash:1437729425192'), {
				autoSize:		'center',
				fontSize:		28,
				color:			0xffffff,
				borderColor:	0x8d4d32
			});
			descLabel.x = (settings.width - descLabel.width) / 2;
			descLabel.y = 60;
			bodyContainer.addChild(descLabel);
			
			timerDescLabel = drawText(Locale.__e('flash:1437747696574'), {
				autoSize:		'center',
				fontSize:		22,
				color:			0xffffff,
				borderColor:	0x8d4d32,
				borderSize:     5
			});
			timerDescLabel.x = (settings.width - timerDescLabel.width) / 2;
			timerDescLabel.y = backing.y + backing.height - 10;
			bodyContainer.addChild(timerDescLabel);
			
			timerLabel = drawText('', {
				width:			300,
				textAlign:		'center',
				fontSize:		42,
				color:			0x634428,
				borderColor:	0xf1e8c1,
				filters:		[new DropShadowFilter(2, 90, 0x5f481c, 1, 0, 0)]
			});
			timerLabel.x = (settings.width - timerLabel.width) / 2;
			timerLabel.y = timerDescLabel.y + timerDescLabel.height - 10;
			bodyContainer.addChild(timerLabel);
			timer();
			
			chooseBoxLabel = drawText(Locale.__e('flash:1437744645044'), {
				width:			300,
				textAlign:		'center',
				fontSize:		28,
				color:			0xffffff,
				borderColor:	0x8d4d32
			});
			chooseBoxLabel.x = (settings.width - chooseBoxLabel.width) / 2;
			chooseBoxLabel.y = backing.y + backing.height + 12;
			bodyContainer.addChild(chooseBoxLabel);
			chooseBoxLabel.visible = false;
			
			playBttn = new Button( {
				caption:	Locale.__e('flash:1437729611472'),
				width:		180,
				height:		55
			});
			playBttn.x = (settings.width - playBttn.width) / 2;
			playBttn.y = settings.height - playBttn.height - 42;
			bodyContainer.addChild(playBttn);
			playBttn.addEventListener(MouseEvent.CLICK, onPlay);
			playBttn.visible = false;
			
			buyPlayBttn = new MoneyButton( {
				caption:	Locale.__e('flash:1437729611472'),
				countText:	target.info.skip,
				fontSize:	26,
				width:		160,
				height:		48
			});
			buyPlayBttn.x = (settings.width - buyPlayBttn.width) / 2;
			buyPlayBttn.y = settings.height - buyPlayBttn.height - 42; // - 40
			bodyContainer.addChild(buyPlayBttn);
			buyPlayBttn.addEventListener(MouseEvent.CLICK, onPlay);
			buyPlayBttn.visible = false;
			buyPlayBttn.textLabel.x += 10;
			
			container = new Sprite();
			container.y = 203;
			bodyContainer.addChild(container);
			
			createPole();
		}
		
		private var paid:Boolean = false;
		private function onPlay(e:MouseEvent):void {
			if (state == WAIT) {
				if (target.played > App.midnight) {
					Hints.minus(Stock.FANT, target.info.skip, new Point(playBttn.x + playBttn.width / 2, playBttn.y), false, bodyContainer);
					target.playEvent(1, onTake);
					paid = true;
				}else {
					target.playEvent(0, onTake);
				}
				
				startShow();
			}
		}
		
		private function createPole():void {
			clear();
			generateTresuare();
			
			// Buttons
			if (target.played > App.midnight) {
				playBttn.visible = false;
				buyPlayBttn.visible = true;
				timerShow();
			}else {
				playBttn.visible = true;
				buyPlayBttn.visible = false;
				timerHide();
			}
			
			var space:int = int((settings.width - 140) / treasures.length);
			var dy:int = -20;
			if (target.sid == 1045) dy = -30;
			for (var i:int = 0; i < treasures.length; i++) {
				var thimble:Thimble = new Thimble( {
					count:treasures[i].count,
					sid:treasures[i].sid,
					id:i,
					onClick:onClick,
					window:this
				});
				thimble.x = 70 + int((space / 2) + i * space);
				thimble.y = dy;
				thimble.alpha = 0;
				container.addChild(thimble);
				thimbles.push(thimble);
				thimblePositions.push({x:thimble.x, y:0});
			}
			
			timeout = setTimeout(showThimble, 1000);
		}
		
		private var choose:Boolean = false;
		private var chooseID:int;
		private function onClick(id:int):void {
			if (id >= 0 && id < treasures.length) {
				if (state == CHOOSE) {
					chooseID = id;
					target.treasure = treasures[id];
					target.storageEvent();
					TweenLite.to(chooseBoxLabel, 0.3, { alpha:0, onComplete:function():void { chooseBoxLabel.visible = false; }} );
				}else if (state == WAIT) {
					glowButton();
				}
			}
		}
		private function glowButton():void {
			if (playBttn.visible) {
				//playBttn.glowTimes = 1;
				playBttn.startGlowing();
			}else if (buyPlayBttn.visible) {
				//buyPlayBttn.glowTimes = 1;
				buyPlayBttn.startGlowing();
			}
		}
		
		
		private function clear():void {
			thimblePositions = [];
			while (thimbles.length > 0) {
				var thimble:Thimble = thimbles.shift();
				thimble.dispose();
			}
		}
		
		private function generateTresuare():void {
			treasures = [];
			
			for (var s:String in target.info.devel.thimbles) {
				var object:Object = { tID:s, iID:'', sid:0, count:0 };
				var list:Array = [];
				for (var prop:String in target.info.devel.thimbles[s])
					list.push(prop);
				
				object.iID = list[Math.floor(Math.random() * list.length)];
				for (prop in target.info.devel.thimbles[s][object.iID]) {
					object.sid = prop;
					object.count = target.info.devel.thimbles[s][object.iID][prop];
				}
				/*object.sid = int(object.iID);
				object.count = target.info.thimbles[s][object.iID];*/
				
				treasures.push(object);
			}
		}
		
		// Time hide
		private function timerHide():void {
			TweenLite.to(timerDescLabel, 0.4, { alpha:0 } );
			TweenLite.to(timerLabel, 0.4, { alpha:0 } );
		}
		private function timerShow():void {
			TweenLite.to(timerDescLabel, 0.4, { alpha:1 } );
			TweenLite.to(timerLabel, 0.4, { alpha:1 } );
		}
		
		// On create thimbles
		private function showThimble():void {
			var find:Boolean = false;
			for (var i:int = 0; i < thimbles.length; i++ ) {
				if (thimbles[i].alpha == 0) {
					find = true;
					timeout = setTimeout(showThimble, 100);
					TweenLite.to(thimbles[i], 0.2, {y:0, alpha:1, ease:Cubic.easeIn} );
					break;
				}
			}
			
			if (!find && state == CHOOSED) {
				state = WAIT;
			}
		}
		
		
		// Show
		private var timeout:int = 0, currThimble:int = 0, currStep:int = 0, currTimeout:int = 500, maxSteps:int = 60, direction:int = -1, toOut:int = 0;
		private function startShow():void {
			state = PRESHUFFLE;
			currThimble = 0;
			
			timerHide();
			
			timeout = setTimeout(showThimbleReward, 150);
		}
		private function showThimbleReward():void {
			if (thimbles.length > currThimble) {
				thimbles[currThimble].show();
				currThimble++;
				timeout = setTimeout(showThimbleReward, 150);
			}else {
				currThimble = 0;
				timeout = setTimeout(hideThimbleReward, 2000);
			}
		}
		private function hideThimbleReward():void {
			if (thimbles.length > currThimble) {
				thimbles[currThimble].hide();
				currThimble++;
				timeout = setTimeout(hideThimbleReward, 150);
			}else {
				timeout = 0;
				state = SHUFFLE;
				startShuffle();
			}
		}
		
		// Choose
		private function startChoose():void {
			state = CHOOSE;
			chooseBoxLabel.visible = true;
			chooseBoxLabel.alpha = 0;
			TweenLite.to(chooseBoxLabel, 0.3, { alpha:1 } );
		}
		
		// Take
		private function onTake(rewards:Object):void {
			if (!thimbles[chooseID].showed) {
				// Входит первый раз после того как пришел успешный ответ о забранном подарке
				state = CHOOSED;
				thimbles[chooseID].show();
				timeout = setTimeout(function():void {
					thimbles[chooseID].moveToStock();
					timeout = setTimeout(onTake, 500, rewards);
				}, 1000);
				return;
			}else {
				var showed:Boolean = false;
				for (var i:int = 0; i < thimbles.length; i++) {
					if (!thimbles[i].showed) {
						thimbles[i].show();
						showed = true;
						break;
					}
				}
				
				if (!showed) {
					timeout = setTimeout(takeReward, 500);
					return;
				}
			}
			
			timeout = setTimeout(onTake, 300, rewards);
		}
		private function takeReward():void {
			timeout = setTimeout(removeThimbles, 300);
		}
		private function removeThimbles():void {
			if (thimbles.length > 0) {
				var thimble:Thimble = thimbles.shift();
				timeout = setTimeout(removeThimbles, 150);
				TweenLite.to(thimble, 0.2, {scaleX:0.5, scaleY:0.5, alpha:0, onCompleteParams:[thimble], onComplete:function(...args):void {
					args[0].dispose();
					
					if (container.numChildren == 0)
						createPole();
				}});
			}
		}
		
		
		// Shuffle
		private function startShuffle():void {
			currStep = 0;
			currTimeout = 500;
			timeout = setTimeout(shuffler, currTimeout);
		}
		
		private var frees:Array;
		private var aways:Vector.<Thimble> = new Vector.<Thimble>;
		private var thimblePositions:Array = [];
		private function shuffler():void {
			
			if (aways.length > 0 && toOut < 0) {
				var index:int = int(Math.random() * aways.length);
				move(aways[index]);
				aways.splice(index, 1);
				if (aways.length == 0 && currStep >= maxSteps) {
					startChoose();
					return;
				}
			}else {
				frees = listOf();
				if (frees.length > 0) {
					var thimble:Thimble = thimbles[frees[int(Math.random() * frees.length)]];
					move(thimble);
				}
			}
			
			// Счетчики
			currStep++;
			toOut--;
			if (currStep > maxSteps) {
				toOut = -1;
			}else if (currStep > 40) {
				currTimeout += currTimeout * 0.75;
				if (currTimeout > 500) {
					currTimeout = 500;
					currStep = maxSteps;
				}
			}else if (currStep > 20) {
				//
			}else if (currStep > 0) {
				currTimeout -= currTimeout * 0.5;
				if (currTimeout < 100) currTimeout = 100;
			}
			
			timeout = setTimeout(shuffler, currTimeout);
			
			function listOf(state:uint = 0):Array {
				var list:Array = [];
				for (var i:int = 0; i < thimbles.length; i++) {
					if (thimbles[i].state == Thimble.SLACK)
						list.push(i);
				}
				return list;
			}
			
			function getFreeRandomPosition():Object {
				var except:Array = [];
				for (var j:int = 0; j < thimblePositions.length; j++) {
					if (except.indexOf(j) != -1) continue;
					
					var busy:Boolean = false;
					for (var i:int = 0; i < thimbles.length; i++) {
						if (thimbles[i].x == thimblePositions[j].x && thimbles[i].y == thimblePositions[j].y)
							busy = true;
					}
					
					if (!busy) return thimblePositions[j];
				}
				
				return null;
			}
			
			function getRandomNearPosition():Object {
				return { x: 100 + int((settings.width - 300) * Math.random()), y:24 - 48 * Math.round(Math.random()) };
			}
			
			function move(thimble:Thimble):void {
				var position:Object;
				var away:Boolean = false;
				var bezierThrough:Array;
				
				position = getFreeRandomPosition();
				if (position == null) {
					bezierThrough = [getRandomNearPosition()];
					away = true;
					aways.push(thimble);
					toOut = 3 + int(Math.random() * 12);
				}else {
					bezierThrough = [position];
					
					if(aways.length > 0 && aways[0] != thimble)
						bezierThrough.unshift( { x:(position.x + thimble.x) / 2, y:int(Math.abs(position.x - thimble.x) / 20) * (1 - 2 * Math.round(Math.random())) } );
				}
				
				thimble.state = Thimble.MOVE;
				TweenMax.to(thimble, currTimeout * 0.75 / 1000, { bezierThrough:bezierThrough, orientToBezier:false, ease:Cubic.easeInOut, onCompleteParams:[thimble, (away) ? Thimble.AWAY : Thimble.SLACK], onComplete:function(...args):void {
					args[0].state = args[1];
					args[0].filters = [];
				}, onUpdateParams:[thimble], onUpdate:function(...args):void {
					args[0].scaleX = args[0].scaleY = 1 + args[0].y / 150;
					args[0].filters = [new BlurFilter(Math.abs(args[0].lastX - args[0].x) / 4, Math.abs(args[0].lastY - args[0].y), 2)];
					args[0].lastX = args[0].x;
					args[0].lastY = args[0].y;
					
					countDepths();
				}} );
			}
			
			function countDepths():void {
				var index:int = 0;
				while (index < container.numChildren - 1) {
					if (container.getChildAt(index).y > container.getChildAt(index + 1).y) {
						container.swapChildrenAt(index, index + 1);
						index = 0;
					}
					
					index++;
				}
			}
		}
		
		override public function close(e:MouseEvent = null):void {
			
			if (state == PRESHUFFLE || state == SHUFFLE || state == CHOOSE) {
				settings['faderClickable'] = true;
			}else {
				settings['faderClickable'] = false;
				super.close(e);
			}
		}
		
		override public function dispose():void {
			super.dispose();
			clearTimeout(timeout);
			App.self.setOffTimer(timer);
			clear();
		}
	}

}

import com.greensock.easing.Back;
import com.greensock.easing.Cubic;
import com.greensock.TweenLite;
import core.Load;
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.filters.GlowFilter;
import flash.text.TextField;
import flash.utils.clearTimeout;
import wins.Window;
import wins.ThimbleWindow;

internal class Thimble extends Sprite {
	
	public static const SLACK:uint = 0;
	public static const MOVE:uint = 1;
	public static const AWAY:uint = 2;
	
	public var lastX:int = 0;
	public var lastY:int = 0;
	
	public var reward:Bitmap;
	public var box:Bitmap;
	public var boxOpen:Bitmap;
	public var backingOpen:Bitmap;
	public var countLabel:TextField;
	private var preloader:Preloader;
	private var glow:Bitmap;
	
	private var _state:uint = SLACK;
	private var boxCont:Sprite;
	private var rewardCont:Sprite;
	
	public var params:Object = { };
	
	public function Thimble(params:Object) {
		
		for (var s:String in params)
			this.params[s] = params[s];
		
		boxCont = new Sprite();
		addChild(boxCont);
		
		rewardCont = new Sprite();
		rewardCont.alpha = 0;
		rewardCont.y = 45;
		addChild(rewardCont);
		
		preloader = new Preloader();
		preloader.scaleX = preloader.scaleY = 0.75;
		addChild(preloader);
		
		box = new Bitmap();
		var boxClosedImage:String = 'supriseBox';
		if (params.window.target.sid == 1045) boxClosedImage = 'WhitchHatClosed';
		Load.loading(Config.getImage('content', boxClosedImage), onBoxLoad);
		
		boxOpen = new Bitmap();
		boxOpen.alpha = 0;
		var boxOpenImage:String = 'supriseBoxOpen';
		if (params.window.target.sid == 1045) boxOpenImage = 'WhitchHatOpen';
		Load.loading(Config.getImage('content', boxOpenImage), onBoxOpenLoad);
		
		glow = new Bitmap(Window.textures.glow, 'auto', true);
		glow.scaleX = glow.scaleY = 0.48;
		glow.alpha = 0.6;
		glow.x = -glow.width / 2;
		glow.y = -glow.height / 2;
		rewardCont.addChild(glow);
		
		
		reward = new Bitmap();
		rewardCont.addChild(reward);
		Load.loading(Config.getIcon(App.data.storage[params.sid].type, App.data.storage[params.sid].preview), onLoad);
		
		countLabel = Window.drawText('x' + params.count, {
			color:			0x634428,
			borderColor:	0xf1e8c1,
			fontSize:		26,
			autoSize:		'center'
		});
		countLabel.x = 25;
		countLabel.y = 90;
		rewardCont.addChild(countLabel);
		
		boxCont.addChild(box);
		boxCont.addChild(boxOpen);
		
		addEventListener(MouseEvent.CLICK, onClick);
		addEventListener(MouseEvent.ROLL_OVER, onOver);
		addEventListener(MouseEvent.ROLL_OUT, onOut);
	}
	
	private function onBoxLoad(data:Bitmap):void {
		box.bitmapData = data.bitmapData;
		box.smoothing = true;
		box.x = -int(box.width / 2);
		box.y = -int(box.height / 2);
	}
	private function onBoxOpenLoad(data:Bitmap):void {
		boxOpen.bitmapData = data.bitmapData;
		boxOpen.smoothing = true;
		boxOpen.x = -int(boxOpen.width / 2);
		boxOpen.y = -int(boxOpen.height / 2);
	}
	private function onLoad(data:Bitmap):void {
		if (contains(preloader))
			removeChild(preloader);
		
		reward.bitmapData = data.bitmapData;
		reward.smoothing = true;
		
		if (reward.width > 90) {
			reward.width = 90;
			reward.scaleY = reward.scaleX;
			if (reward.height > 90) {
				reward.height = 90;
				reward.scaleX = reward.scaleY;
			}
		}
		
		reward.x = -reward.width / 2;
		reward.y += reward.height / 3;
		glow.y += reward.height / 2;
		//reward.y = -reward.height / 2 + reward.height / 3;
	}
	
	
	public function get state():uint {
		return _state;
	}
	public function set state(value:uint):void {
		_state = value;
	}
	
	private function onClick(e:MouseEvent):void {
		if (params.onClick != null)
			params.onClick(params.id);
	}
	private function onOver(e:MouseEvent):void {
		if (params.window.state == ThimbleWindow.WAIT || params.window.state == ThimbleWindow.CHOOSE)
			filters = [new GlowFilter(0xFFFF00, 1, 4, 4, 16, 2)];
	}
	private function onOut(e:MouseEvent):void {
		filters = null;
	}
	
	public var showed:Boolean = false;
	public function show():void {
		showed = true;
		TweenLite.to(boxCont, 0.4, { y:40, ease:Cubic.easeInOut } );
		TweenLite.to(box, 0.2, { alpha:0} );
		TweenLite.to(boxOpen, 0.2, { alpha:1} );
		TweenLite.to(rewardCont, 0.8, { y:5,  alpha:1, ease:Back.easeOut} );
	}
	public function hide():void {
		showed = false;
		TweenLite.to(boxCont, 0.25, { y:0, ease:Cubic.easeInOut } );
		TweenLite.to(box, 0.15, { alpha:1} );
		TweenLite.to(boxOpen, 0.15, { alpha:0} );
		TweenLite.to(rewardCont, 0.25, { y:45,  alpha:0, ease:Back.easeOut} );
	}
	
	public function moveToStock():void {
		TweenLite.to(reward, 0.4, {x:200, y:200, alpha:0, ease:Cubic.easeIn} ) ;
		TweenLite.to(countLabel, 0.1, {alpha:0} ) ;
	}
	
	
	public function dispose():void {
		removeEventListener(MouseEvent.CLICK, onClick);
		removeEventListener(MouseEvent.ROLL_OVER, onOver);
		removeEventListener(MouseEvent.ROLL_OUT, onOut);
		if (parent) parent.removeChild(this);
	}
}