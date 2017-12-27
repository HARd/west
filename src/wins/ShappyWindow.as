package wins 
{
	import buttons.Button;
	import buttons.ImageButton;
	import core.Load;
	import core.Numbers;
	import core.Post;
	import core.Size;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import units.Shappy;

	public class ShappyWindow extends Window 
	{
		public var target:Shappy;
		public var helpBttn:ImageButton;
		public var topBttn:ImageButton;
		public var myPoints:TextField;
		public var myPointsIcon:Bitmap;
		public var startButton:Button;
		public function ShappyWindow(settings:Object=null) 
		{
			if (settings == null) {
				settings = new Object();
			}
			
			target = settings.target;
			
			settings['width']			= 780;
			settings['height'] 			= 630;
			settings['background'] 		= 'topBacking';
			settings['hasButtons'] 		= false;
			settings['title'] 			= target.info.title;
			settings['content']			= [];
			settings['itemsOnPage']		= 4;
			settings['mirrorDecor'] 	= 'decEldorado';
			
			super(settings);
			
			createContent();			
		}
		
		public function createContent():void {
			var topInfo:Object = App.data.top[target.topID];
			for (var i:* in topInfo.league.abonus[1].p) {
				settings.content.push({id:i, points:topInfo.league.abonus[1].p[i], treasure:topInfo.league.abonus[1].t[i]});
			}
		}
		
		override public function drawBackground():void {
			if (!background) {
				background = new Bitmap();
				layer.addChild(background);
			}
			background.bitmapData = Window.backing(settings.width, settings.height, 50, settings.background).bitmapData;
			
			var backing:Bitmap = Window.backing(settings.width, 350, 50, settings.background);
			backing.x = 0;
			backing.y = 0;
			layer.addChild(backing);
			
			//drawMirrowObjs('decWeb', 10, settings.width - 10, 330 - 115,false,false,false,1,1,layer);
			//drawMirrowObjs('decWeb', 10, settings.width - 10, settings.height - 115,false,false,false,1,1,layer);
		}
		
		override public function drawArrows():void {			
			paginator.drawArrow(bodyContainer, Paginator.LEFT,  0, 0, { scaleX: -1, scaleY:1 } );
			paginator.drawArrow(bodyContainer, Paginator.RIGHT, 0, 0, { scaleX:1, scaleY:1 } );
			
			var y:Number = (settings.height - paginator.arrowLeft.height) / 2 - settings.height / 4 + 30;
			paginator.arrowLeft.x = -paginator.arrowLeft.width / 2 + 16;
			paginator.arrowLeft.y = y;
			
			paginator.arrowRight.x = settings.width-paginator.arrowRight.width/2 - 16;
			paginator.arrowRight.y = y;
			
		}
		
		override public function drawBody():void {
			//bodyContainer.y += 100;
			var bg:Bitmap = Window.backing(settings.width - 150, 85, 50, 'fadeOutWhite');
			bg.alpha = 0.3;
			bg.x = 75;
			bg.y = 15;
			bodyContainer.addChild(bg);
			
			var desc:TextField = drawText(App.data.top[target.topID].description, {
				width:settings.width - 200,
				textAlign:'center',
				multiline:true,
				wrap:true,
				color:0xffffff,
				borderColor:0x704705,
				fontSize:25
			});
			desc.x = 100;
			desc.y = 20;
			bodyContainer.addChild(desc);
			
			helpBttn = new ImageButton(Window.texture('interHelpBttn'));
			helpBttn.x = settings.width - 120;
			helpBttn.y = -40;
			bodyContainer.addChild(helpBttn);
			helpBttn.addEventListener(MouseEvent.CLICK, onHelp);
			
			drawTimer();
			drawTopElements();
			
			startButton = new Button( {
				width:200,
				height:55,
				caption:Locale.__e('flash:1476200052263')
			});
			startButton.x = (settings.width - startButton.width) / 2;
			startButton.y = settings.height - startButton.height * 1.2;
			bodyContainer.addChild(startButton);
			startButton.addEventListener(MouseEvent.CLICK, onStart);
			
			if (settings.content.length != 0) {
				//if (ExchangeWindow.find != 0) {
					//for (var i:int = 0; i < settings.content.length; i++) {
						//if (settings.content[i].sid == ExchangeWindow.find) {
							//paginator.page = int(int(i) / settings.itemsOnPage);
							//break;
						//}							
					//}
				//}
				paginator.itemsCount = settings.content.length;
				paginator.update();
				paginator.onPageCount = settings.itemsOnPage;
			}
			contentChange();
		}
		
		private var timerBacking:Bitmap;
		private var timerDescLabel:TextField;
		private var timerLabel:TextField;
		private function drawTimer():void {
			timerBacking = new Bitmap(Window.textures.iconGlow, 'auto', true);
			timerBacking.scaleX = 0.6;
			timerBacking.scaleY = 1;
			timerBacking.x = 30;
			timerBacking.y = -50;
			timerBacking.alpha = 0.7;
			bodyContainer.addChild(timerBacking);
			
			var text:String = Locale.__e('flash:1382952379794').replace('%s', '');
			timerDescLabel = drawText(text, {
				width:			timerBacking.width,
				textAlign:		'center',
				fontSize:		25,
				color:			0xfdfde5,
				borderColor:	0x7c523a,
				shadowSize:		1
			});
			timerDescLabel.x = timerBacking.x + (timerBacking.width - timerDescLabel.width) / 2;
			timerDescLabel.y = timerBacking.y + 20;
			bodyContainer.addChild(timerDescLabel);
			
			timerLabel = drawText('', {
				width:			200,
				textAlign:		'center',
				fontSize:		38,
				color:			0xfde676,
				borderColor:	0x743e1a,
				shadowSize:		2
			});
			timerLabel.x = timerDescLabel.x + timerDescLabel.width * 0.5 - timerLabel.width * 0.5;
			timerLabel.y = timerDescLabel.y + timerDescLabel.height - 5;
			bodyContainer.addChild(timerLabel);
			
			App.self.setOnTimer(timer);
		}
		private function timer():void {
			if (timerLabel) {
				var time:int = target.expire - App.time;
				if (time < 0) {
					App.self.setOffTimer(timer);
					timerLabel.visible = false;
					timerBacking.visible = false;
					timerDescLabel.visible = false;
					time = 0;
					
					//if (Exchange.take == 0)
						//infoBttn.showGlowing();
				}
				timerLabel.text = TimeConverter.timeToStr(time);
				
				if (time <= 0) {
					App.self.setOffTimer(timer);
					timerLabel.visible = false;
					timerDescLabel.visible = false;
					timerBacking.visible = false;
				}
			}
		}
		private var offset:int = 20;
		private function drawTopElements():void {
			var bg:Bitmap = Window.backing(400, 40, 50, 'fadeOutWhite');
			bg.alpha = 0.3;
			bg.x = 50;
			bg.y = 305 + offset;
			bodyContainer.addChild(bg);
			
			var desc:TextField = drawText(Locale.__e('flash:1476175567132'), {
				width:400,
				textAlign:'center',
				multiline:true,
				wrap:true,
				color:0xffffff,
				borderColor:0x704705,
				fontSize:22
			});
			desc.x = 55;
			desc.y = 310  + offset;
			bodyContainer.addChild(desc);
			
			topBttn = new ImageButton(Window.texture('homeBttn'));
			topBttn.scaleX = topBttn.scaleY = 0.8;
			topBttn.x = 550;
			topBttn.y = 330;
			bodyContainer.addChild(topBttn);
			
			var topBttnText:TextField = Window.drawText(Locale.__e('flash:1440154414885'), {
				textAlign:		'center',
				fontSize:		32,
				color:			0xFFFFFF,
				borderColor:	0x631d0b,
				shadowSize:		1
			});
			topBttnText.x = 20;
			topBttnText.y = (topBttn.height - topBttnText.height) / 2 + 10;
			topBttn.addChild(topBttnText);
			
			topBttn.addEventListener(MouseEvent.CLICK, openTop);
			App.user.top
			var Xs:int = 340;
			for (var i:* in App.data.top[target.topID].league.tbonus[1].t) {
				var item:ShappyItem = new ShappyItem(this, {treasure:App.data.top[target.topID].league.tbonus[1].t[i]});
				item.x = Xs;
				item.y = 380  + offset;
				bodyContainer.addChild(item);
				
				var topDesc:TextField = drawText(App.data.top[target.topID].league.tbonus[1].d[i], {
					width:item.background.width,
					textAlign:'center',
					multiline:true,
					wrap:true,
					color:0xfde358,
					borderColor:0x6f3a06,
					fontSize:28
				});
				topDesc.x = Xs;
				topDesc.y = 350;
				bodyContainer.addChild(topDesc);
				
				Xs -= item.background.width + 10;
			}
			
			var background:Bitmap = Window.backing(210, 130, 10, 'itemBackingYellow');
			background.x = 500;
			background.y = 400;
			bodyContainer.addChild(background);
			
			var youHave:TextField = drawText(Locale.__e('flash:1440494930989') + ':', {
				color:0xffffff,
				borderColor:0x5c2810,
				fontSize:24
			});
			youHave.x = background.x + 25;
			youHave.y = background.y + 20;
			bodyContainer.addChild(youHave);
			App.user.top
			var points:int = 0;
			//if (!App.user.top.hasOwnProperty(target.topID) && target.expire > App.time) 
				//App.user.top[target.topID] = { count:App.user.stock.count(App.data.top[target.topID].target) };
			if (App.user.top.hasOwnProperty(target.topID) && App.user.top[target.topID].hasOwnProperty('count')) 
				points = App.user.top[target.topID].count;
			myPoints = drawText(String(points), {
				color:0xfdcab7,
				borderColor:0x7c3114,
				fontSize:32
			});
			myPoints.x = youHave.x + youHave.textWidth + 10;
			myPoints.y = youHave.y;
			bodyContainer.addChild(myPoints);
			
			myPointsIcon = new Bitmap();
			Load.loading(Config.getIcon(App.data.storage[App.data.top[target.topID].target].type, App.data.storage[App.data.top[target.topID].target].preview), function(data:*):void {
				myPointsIcon.bitmapData = data.bitmapData;
				Size.size(myPointsIcon, 40, 40);
				myPointsIcon.smoothing = true;
				myPointsIcon.x = myPoints.x + myPoints.textWidth + 15;
				myPointsIcon.y = myPoints.y - 5;
				bodyContainer.addChild(myPointsIcon);
			});
			
			var separator:Bitmap = Window.backingShort(background.width - 50, 'dividerLine', false);
			separator.x = background.x + 25;
			separator.y = background.y + background.height / 2;
			separator.alpha = 0.5;
			bodyContainer.addChild(separator);
			
			var yourPlace:TextField = drawText(Locale.__e('flash:1476196510936'), {
				color:0xffffff,
				borderColor:0x5c2810,
				fontSize:24,
				multiline:true,
				wrap:true,
				width:100
			});
			yourPlace.x = background.x + 25;
			yourPlace.y = separator.y + 5;
			bodyContainer.addChild(yourPlace);
			
			var p:String = '-';
			if (Shappy.position != 0) p = String(Shappy.position);
			var place:TextField = drawText(p, {
				color:0xfda300,
				borderColor:0x502400,
				fontSize:36
			});
			place.x = yourPlace.x + yourPlace.textWidth + 15;
			place.y = yourPlace.y + 5;
			bodyContainer.addChild(place);
		}
		
		private function onHelp(e:MouseEvent):void {
			if (helpBttn.mode == Button.DISABLED)
				return;
				
			new InfoWindow( {
				popup:true,
				qID:'halloween',
				background:'eldoradoTopBacking',
				mirrorDecor:'decEldorado'
			}).show();
		}
		
		private function onStart(e:MouseEvent):void {
			//App.data[top
			//Find.find(App.data.top[target.topID].target);
			if (Find.find(App.data.top[target.topID].target))
			{
				return;
			}
			//var invaders:Array = Map.findUnitsByType(['Invader']);
			//
			//Window.closeAll();
			//if (invaders.length > 0 )
				//App.map.focusedOn(invaders[0], true, null);
			//else 
				new SimpleWindow({
					text:	Locale.__e('flash:1382952379745')
				}).show();
		}
		
		protected function openTop(e:MouseEvent = null):void {
			if (Shappy.rateChecked == 0) {
				Shappy.rateChecked = App.time;
				target.getRate(openTop);
				return;
			}
			
			Shappy.rateChecked = 0;
			
			new TopWindow( {
				title:			App.data.top[target.topID].title,
				description:	App.data.top[target.topID].description,
				target:			target,
				points:			Shappy.rate,
				max:			100,
				content:		Shappy.rates,
				material:		null,
				popup:			true,
				top:			target.topID,
				background:		'eldoradoTopBacking',
				mirrorDecor: 	'decEldorado',
				onInfo:			function():void {
					
				}
			}).show();
		}
		
		public var items:Array = [];
		private var itemsContainer:Sprite = new Sprite();
		override public function contentChange():void {
			ShappyItem.isEnabled = false;
			for each(var _item:* in items) {
				itemsContainer.removeChild(_item);
				_item.dispose();
			}
			items = [];
			
			var X:int = 73;
			var Xs:int = 0;
			var Ys:int = 0;
			bodyContainer.addChild(itemsContainer);
			itemsContainer.x = X;
			itemsContainer.y = 110;
			if (settings.content.length < 1) return;
			for (var i:int = paginator.startCount; i < paginator.finishCount; i++)
			{
				var item:ShappyItem = new ShappyItem(this, settings.content[i]);
				item.x = Xs;
				item.y = Ys;
				items.push(item);
				itemsContainer.addChild(item);
				
				Xs += item.background.width + 15;
			}
			if (items.length < 4) itemsContainer.x = (settings.width - itemsContainer.width) / 2 + 27;
		}
		
		override public function dispose():void {
			App.self.setOffTimer(timer);
			
			super.dispose();
		}
		
	}

}
import buttons.Button;
import com.greensock.TweenLite;
import core.Load;
import core.Post;
import core.Size;
import fl.motion.easing.Cubic;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.text.TextField;
import flash.utils.setTimeout;
import wins.Window;

internal class ShappyItem extends LayerX
{
	public var window:*;
	public var background:Bitmap;
	private var bitmap:Bitmap;
	private var count:int;
	private var points:int = 0;
	private var id:int = -1;
	private var takeBttn:Button;
	
	public function ShappyItem(window:*, item:Object)
	{
		this.window = window;
		if (item.hasOwnProperty('points')) this.points = item.points;
		if (item.hasOwnProperty('id')) this.id = item.id;
		
		var backing:String = 'itemBacking';
		
		background = Window.backing(140, 150, 10, backing);
		addChild(background);
		
		var items:Array = [];
		var tes:Object = App.data.treasures[item.treasure];
		if (App.data.treasures[item.treasure][item.treasure].item is Array) {
			items = App.data.treasures[item.treasure][item.treasure].item;
		}else {
			for each (var it:* in App.data.treasures[item.treasure][item.treasure].item) {
				items.push(it);
			}
			items.reverse();
		}
		for (var index:* in App.data.treasures[item.treasure][item.treasure].count)
		{
			count = App.data.treasures[item.treasure][item.treasure].count[index] * App.data.treasures[item.treasure][item.treasure]['try'][index]; 
		}
		//count = App.data.treasures[item.treasure][item.treasure].count[0];
		Load.loading(Config.getIcon(App.data.storage[items[0]].type, App.data.storage[items[0]].preview), onLoad);
		
		drawTitle(App.data.storage[items[0]].title);
		
		tip = function():Object {
			return {
				title:App.data.storage[items[0]].title,
				text:App.data.storage[items[0]].description
			}
		}
		
		if (points != 0) {
			drawCount();
			drawButton();
			//if(App.user.top.hasOwnProperty(App.user.topID) && App.user.top[App.user.topID].count >= points)
				//takeBttn.visible = true;
			//else
				//takeBttn.visible = false;
		}
		else
		{
			drawCount();
		}
	}
	
	private function onLoad(data:Bitmap):void {
		bitmap = new Bitmap(data.bitmapData);
		Size.size(bitmap, 90, 90);
		addChildAt(bitmap, 1);
		bitmap.x = (background.width - bitmap.width) / 2;
		bitmap.y = (background.height - bitmap.height) / 2;
		bitmap.smoothing = true;
	}
	
	private function drawTitle(text:String):void {
		var title:TextField = Window.drawText(text, {
			width:background.width,
			textAlign:'center',
			miltiline:true,
			wrap:true,
			color:0x773513,
			borderColor:0xffffff,
			fontSize:21
		});
		title.y = 5;
		addChild(title);
	}
	
	private function drawCount():void {
		var countTxt:TextField = Window.drawText('x' + String(count), {
			width:background.width,
			textAlign:'center',
			miltiline:true,
			wrap:true,
			color:0x773513,
			borderColor:0xffffff,
			fontSize:23
		});
		countTxt.x = 50;
		countTxt.y = 80;
		addChild(countTxt);
	}
	
	private var pointsSprite:Sprite;
	private var takedSprite:Sprite = new Sprite();
	private function drawButton():void {
		takeBttn = new Button( {
			caption:Locale.__e('flash:1382952379737'),
			width:110,
			height:38
		});
		takeBttn.x = (background.width - takeBttn.width) / 2;
		takeBttn.y = 120;
		addChild(takeBttn);
		takeBttn.addEventListener(MouseEvent.CLICK, onTake);
		
		pointsSprite = new Sprite();
		addChild(pointsSprite);
		var icon:Bitmap = new Bitmap();
		Load.loading(Config.getIcon(App.data.storage[App.data.top[window.target.topID].target].type, App.data.storage[App.data.top[window.target.topID].target].preview), function (data:*):void {
			icon.bitmapData = data.bitmapData;
			Size.size(icon, 35, 35);
			icon.smoothing = true;
			icon.x = 20;
			icon.y = background.height - icon.height - 5;
			pointsSprite.addChild(icon);
		});
		var textPoints:TextField = Window.drawText(String(points), {
			color:0x7e3a13,
			borderColor:0xffffff,
			fontSize:27
		});
		textPoints.x = 60;
		textPoints.y = 115;
		pointsSprite.addChild(textPoints);
		pointsSprite.x = (background.width - pointsSprite.width) / 2;
		
		addChild(takedSprite);
		var takedText:TextField = Window.drawText(Locale.__e('flash:1476192070661'), {
			color:0xffffff,
			borderColor:0x5d4401,
			fontSize:20
		});
		takedText.x = 5;
		takedText.y = 115;
		takedSprite.addChild(takedText);
		takedSprite.visible = false;
		var takeIcon:Bitmap = new Bitmap(Window.texture('checkMark'));
		takeIcon.x = 75;
		takeIcon.y = 95;
		takedSprite.addChild(takeIcon);
		
		if (!App.user.top.hasOwnProperty(window.target.topID)) {
			takeBttn.visible = false;
			pointsSprite.visible = true;
		} else if (App.user.top[window.target.topID].count < points) {
			takeBttn.visible = false;
			pointsSprite.visible = true;
		}else if (App.user.top[window.target.topID].hasOwnProperty('abonus')) {
			if (App.user.top[window.target.topID].abonus >= this.id) {
				takeBttn.visible = false;
				pointsSprite.visible = false;
				takedSprite.visible = true;
			}else {
				if (!isEnabled)
				{
					isEnabled = true;
					takeBttn.visible = true;
					pointsSprite.visible = false;
				}
				else
				{
					takeBttn.visible = false;
					pointsSprite.visible = true;
				}
			}
			} else {
			if (!isEnabled)
			{
				isEnabled = true;
				takeBttn.visible = true;
				pointsSprite.visible = false;
			}
			else
			{
				takeBttn.visible = false;
				pointsSprite.visible = true;
			}
			pointsSprite.visible = false;
		}
	}
	
	public static var isEnabled:Boolean = false;
	private function onTake(e:MouseEvent):void {
		takeBttn.visible = false;
		takedSprite.visible = true;
		Post.send( {
			ctr:		'top',
			act:		'abonus',
			uID:		App.user.id,
			tID:		window.target.topID
		}, function(error:int, data:Object, params:Object):void {
			if (error) return;
			
			if (data.hasOwnProperty('bonus')) {
				//App.user.stock.addAll(data.bonus);
				take(data.bonus);
			}
				
			if (App.user.top[App.user.topID].hasOwnProperty('abonus')) {
				App.user.top[App.user.topID].abonus = App.user.top[App.user.topID].abonus + 1;
			} else {
				App.user.top[App.user.topID]['abonus'] = 0;
			}
			isEnabled = false;
			window.contentChange();
			//App.data.top App.time
		});
	}
	
	private function take(items:Object):void {
		for(var i:String in items) { 			
			Load.loading(Config.getIcon(App.data.storage[i].type, App.data.storage[i].preview), function(data:Bitmap):void {
				rewardW = new Bitmap;
				rewardW.bitmapData = data.bitmapData;
				App.user.stock.add(int(i), count);
				wauEffect();
			});
		}
	}
	
	public var rewardW:Bitmap;
	private function wauEffect(e:MouseEvent =  null):void {
		if (rewardW.bitmapData != null) {
			var rewardCont:Sprite = new Sprite();
			App.self.windowContainer.addChild(rewardCont);
			
			var glowCont:Sprite = new Sprite();
			glowCont.alpha = 0.6;
			glowCont.scaleX = glowCont.scaleY = 0.5;
			rewardCont.addChild(glowCont);
			
			var glow:Bitmap = new Bitmap(Window.textures.actionGlow);
			glow.x = -glow.width / 2;
			glow.y = -glow.height + 90;
			glowCont.addChild(glow);
			
			var glow2:Bitmap = new Bitmap(Window.textures.actionGlow);
			glow2.scaleY = -1;
			glow2.x = -glow2.width / 2;
			glow2.y = glow.height - 90;
			glowCont.addChild(glow2);
			
			var bitmap:Bitmap = new Bitmap(new BitmapData(rewardW.width, rewardW.height, true, 0));
			bitmap.bitmapData = rewardW.bitmapData;
			bitmap.smoothing = true;
			bitmap.x = -bitmap.width / 2;
			bitmap.y = -bitmap.height / 2;
			rewardCont.addChild(bitmap);
			
			var countText:TextField = Window.drawText('x' + String(count), {
				fontSize:		32,
				color:			0xffffff
			});
			countText.x = bitmap.x + bitmap.width - countText.textWidth;
			countText.y = bitmap.y + bitmap.height - 10;
			rewardCont.addChild(countText);
			
			if (e) {
				rewardCont.x = e.target.parent.x + e.target.parent.width / 2 ;
				rewardCont.y = e.target.parent.y + e.target.parent.height / 2 ;
			} else {
				rewardCont.x = rewardCont.y = 0;
			}
			
			function rotate():void {
				glowCont.rotation += 1.5;
			}
			
			App.self.setOnEnterFrame(rotate);
			
			count = 0;
			TweenLite.to(rewardCont, 0.5, { x:App.self.stage.stageWidth / 2, y:App.self.stage.stageHeight / 2, scaleX:1.25, scaleY:1.25, ease:Cubic.easeInOut, onComplete:function():void {
				setTimeout(function():void {
					App.self.setOffEnterFrame(rotate);
					glowCont.alpha = 0;
					var bttn:* = App.ui.bottomPanel.bttnMainStock;
					var _p:Object = { x:App.ui.bottomPanel.x + bttn.parent.x + bttn.x + bttn.width / 2, y:App.ui.bottomPanel.y + bttn.parent.y + bttn.y + bttn.height / 2};
					SoundsManager.instance.playSFX('takeResource');
					TweenLite.to(rewardCont, 0.3, { ease:Cubic.easeOut, scaleX:0.7, scaleY:0.7, x:_p.x, y:_p.y, onComplete:function():void {
						TweenLite.to(rewardCont, 0.1, { alpha:0, onComplete:function():void {App.self.windowContainer.removeChild(rewardCont);}} );
					}} );
				}, 3000)
			}} );
		}
	}
	
	public function dispose():void {
		if(takeBttn)
			takeBttn.removeEventListener(MouseEvent.CLICK, onTake);
	}
}