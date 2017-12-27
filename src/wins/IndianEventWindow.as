package wins 
{
	import buttons.ImageButton;
	import buttons.MoneyButton;
	import core.Size;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import units.Exchange;
	public class IndianEventWindow extends SemiEventWindow 
	{
		private var bttn:MoneyButton;
		public var topBttn:ImageButton;
		public var prize:PrizeItem ;
		
		public function IndianEventWindow(settings:Object=null) 
		{
			if (settings == null) {
				settings = new Object();
			}
			
			info = settings.target.info;
			
			settings['width'] = 650;
			settings['height'] = 550;
			settings['shadowSize'] = 3;
			settings['shadowBorderColor'] = 0x554234;
			settings['shadowColor'] = 0x554234;
			
			settings['title'] = info.title;
			settings['hasPaginator'] = false;
			settings['hasButtons'] = false;
			
			if (settings.target.hasOwnProperty('floor'))
				floor = settings.target.floor;
			else
				floor = settings.target.level;
			
			settings['content'] = [];
			for (var sID:* in info.kicks) {
				var obj:Object = { sID:sID, count:info.kicks[sID].c };
				if (info.kicks[sID].hasOwnProperty('t')) {
					obj['t'] = info.kicks[sID].t;
				}
				if (info.kicks[sID].hasOwnProperty('o')) {
					obj['o'] = info.kicks[sID].o;
				}
				if (info.kicks[sID].hasOwnProperty('k')) {
					obj['k'] = info.kicks[sID].k;
				}
				settings['content'].push(obj);
			}
				
			settings['content'].sortOn('o', Array.NUMERIC);
			
			super(settings);	
			
			if (!info.tower.hasOwnProperty(floor + 1)) {
				floor = settings.target.totalFloors - 1;
			}
			
			if (settings.target.kicks >= info.tower[floor + 1].c) {
				blockItems(true);
			}
		}
		
		private var counterContainer:Sprite = new Sprite();
		override public function drawBody():void 
		{			
			topBttn = new ImageButton(Window.texture('homeBttn'));
			topBttn.scaleX = topBttn.scaleY = 0.8;
			topBttn.x = 75;
			topBttn.y = 30;
			bodyContainer.addChild(topBttn);
			//topBttn.showGlowing();
			
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
			
			var description:TextField = Window.drawText(Locale.__e('flash:1443175349139'), {
				color:0x532b07,
				border:true,
				borderColor:0xfde1c9,
				fontSize:24,
				multiline:true,
				autoSize: 'center',
				textAlign:"center",
				thickness: 30
			});
			description.wordWrap = true;
			description.width = 320;
			description.x = 75;
			description.y = topBttn.y + topBttn.height + 10;
			bodyContainer.addChild(description);
			
			bodyContainer.addChild(counterContainer);
			
			counterText = Window.drawText(Locale.__e('flash:1436184507316'), {
				color:0xffffff,
				borderColor:0x744207,
				fontSize:22,
				multiline:true,
				autoSize: 'center',
				textAlign:"center"
			});
			counterText.width = counterText.textWidth + 10;
			counterText.wordWrap = true;
			counterText.x = (settings.width - counterText.width) / 2 - 60;
			counterText.y = 35 - 10;
			counterContainer.addChild(counterText);
			
			var bttnSettings:Object = {
				caption:Locale.__e("flash:1382952380104"),
				width:100,
				height:40,
				fontSize:18
			};
			
			bttnSettings['bgColor'] = [0xa8f749, 0x74bc17];
			bttnSettings['borderColor'] = [0x5b7385, 0x5b7385];
			bttnSettings['bevelColor'] = [0xcefc97, 0x5f9c11];
			bttnSettings['fontColor'] = 0xffffff;			
			bttnSettings['fontBorderColor'] = 0x4d7d0e;
			bttnSettings['fontCountColor'] = 0xc7f78e;
			bttnSettings['fontCountBorder'] = 0x40680b;		
			bttnSettings['countText']	= info.tskip[Stock.FANT];
			
			bttn = new MoneyButton(bttnSettings);
			bttn.x = settings.width - bttn.width - 55;
			bttn.y = 35 - 20;
			bttn.addEventListener(MouseEvent.CLICK, onSpeed);
			counterContainer.addChild(bttn);
			
			prize = new PrizeItem(this, { info:App.data.storage[27], sID: 27 } );
			prize.x = settings.width - prize.width - 75;
			prize.y = 50;
			bodyContainer.addChild(prize);
			
			var textFloor:int = (settings.target.floor + 1 > settings.target.totalFloors) ? settings.target.floor : settings.target.floor + 1;
			var phase:TextField = Window.drawText(Locale.__e('flash:1436188159724', String(textFloor)) + '/' + settings.target.totalFloors, {
				color:0xffffff,
				borderColor:0x744207,
				fontSize:28,
				multiline:true,
				autoSize: 'center',
				textAlign:"center"
			});
			phase.wordWrap = true;
			phase.width = phase.textWidth + 10;
			phase.x = prize.x + (prize.width - phase.width) / 2;
			phase.y = 20;
			bodyContainer.addChild(phase);
			
			if (!settings.target.info.tower.hasOwnProperty(settings.target.floor + 1)) {
				var pointsContainer:Sprite = new Sprite();
				pointsContainer.x = 175;
				pointsContainer.y = description.y + description.textHeight + 10;
				bodyContainer.addChild(pointsContainer);
				
				var youHave:TextField = Window.drawText(Locale.__e('flash:1443192620496'), {
					color:0xffffff,
					fontSize:26,
					autoSize: 'center',
					borderColor:0x76410d
				});
				pointsContainer.addChild(youHave);
				
				var points:TextField = Window.drawText(settings.target.kicks, {
					color:0xffeb7e,
					fontSize:36,
					autoSize: 'center',
					borderColor:0x76410d
				});
				points.x = youHave.x + youHave.width + 10;
				pointsContainer.addChild(points);
			}else {
				progressBacking = Window.backingShort(330, "progBarBacking");
				progressBacking.x = 75;
				progressBacking.y = description.y + description.textHeight + 10;
				bodyContainer.addChild(progressBacking);
				
				progressBar = new ProgressBar({win:this, width:346, isTimer:false});
				progressBar.x = progressBacking.x - 8;
				progressBar.y = progressBacking.y - 4;
				bodyContainer.addChild(progressBar);
				progressBar.progress = settings.target.kicks / info.tower[floor + 1].c;
				progressBar.start();
				
				progressTitle = drawText(progressData, {
					fontSize:32,
					autoSize:"left",
					textAlign:"center",
					color:0xffffff,
					borderColor:0x6b340c,
					shadowColor:0x6b340c,
					shadowSize:1
				});
				progressTitle.x = progressBacking.x + progressBacking.width / 2 - progressTitle.width / 2;
				progressTitle.y = progressBacking.y - 2;
				progressTitle.width = 80;
				bodyContainer.addChild(progressTitle);
			}
			
			drawTime();			
			drawItems();
			
			if (settings.target.timer == 0 || settings.target.timer + info.time - App.time <= 0) {
				counterContainer.visible = false;
			} else {
				blockItems(true);
			}
			
			if (settings.target.kicks >= settings.target.info.tower[floor + 1].c) {
				blockItems(true);
			}
		}
		
		override public function drawItems():void {
			super.drawItems();
			
			itemsContainer.y += 20;
		}
		
		override public function updateCount():void {
			super.updateCount();
			
			prize.checkButton();
		}
		
		protected function openTop(e:MouseEvent):void {
			/*if (rateChecked == 0) return;
			
			new TopWindow( {
				title:			settings.title,
				description:	Locale.__e('flash:1440518562248'),
				target:			settings.target,
				points:			Exchange.rate,
				max:			topx,
				content:		Exchange.rates,
				material:		currency,
				popup:			true,
				onInfo:			function():void {
					if (settings.target.expire - App.time <= 0)
						settings.target.onTakeBonus();
					else {
						new InfoWindow( {
							popup:true,
							qID:100500
						}).show();
					}
				}
			}).show();*/
		}
		
	}

}

import buttons.Button;
import buttons.MoneyButton;
import core.Load;
import core.Size;
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.text.TextField;
import ui.Hints;
import ui.UserInterface;
import wins.IndianEventWindow;
import wins.SemiEventWindow;
import wins.SimpleWindow;
import wins.ShopWindow;
import wins.Window;

internal class PrizeItem extends Sprite
{
	public var window:*;
	public var item:Object;
	public var bg:Bitmap;
	private var bitmap:Bitmap;
	private var sID:uint;
	private var info:Object;
	public var bttn:Button;
	
	public function PrizeItem(window:IndianEventWindow, data:Object)
	{
		this.info = data.info;
		this.sID = data.sID;
		this.item = App.data.storage[data.sID];
		this.window = window;
		
		bg = Window.backing(140, 175, 10, 'itemBacking');
		addChild(bg);
		
		Load.loading(Config.getIcon(item.type, item.preview), onLoad);
		
		drawTitle();
		drawBttn();
		//drawCount();
	}
	
	private function onClick(e:MouseEvent):void 
	{
		if (e.currentTarget.mode == Button.DISABLED) return;
		
		/*var sendObject:Object = {
			act:'kick',
			uID:App.user.id,
			wID:App.user.worldID,
			guest:App.user.id
		};*/
		
		window.blockItems(true);
		window.updateLevel();
		//window.settings.kickEvent(sID, onKickEventComplete, info.t, sendObject, info.count);
	}

	
	public function onStorageEventComplete(sID:uint, price:uint, bonus:Object = null):void {	
		if (bonus) {
			flyBonus(bonus);
		}
		
		window.updateCount();
		
		if (price == 0 ) {
			//window.close();
			return;
		}
		
		var X:Number = App.self.mouseX - bttn.mouseX + bttn.width / 2;
		var Y:Number = App.self.mouseY - bttn.mouseY;
		Hints.minus(sID, price, new Point(X, Y), false, App.self.tipsContainer);
		//window.close();
	}
	
	private function flyBonus(data:Object):void {
		var targetPoint:Point = Window.localToGlobal(bttn);
			targetPoint.y += bttn.height / 2;
			for (var _sID:Object in data)
			{
				var sID:uint = Number(_sID);
				for (var _nominal:* in data[sID])
				{
					var nominal:uint = Number(_nominal);
					var count:uint = Number(data[sID][_nominal]);
				}
				
				var item:*;
				
				for (var i:int = 0; i < count; i++)
				{
					item = new BonusItem(sID, nominal);
					App.user.stock.add(sID, nominal);	

					item.cashMove(targetPoint, App.self.windowContainer)
				}			
			}
			SoundsManager.instance.playSFX('reward_1');
	}
	
	private var sprite:LayerX;
	private function onLoad(data:Bitmap):void {
		sprite = new LayerX();
		sprite.tip = function():Object {
			return {
				title: item.title,
				text: item.description
			};
		}
		
		bitmap = new Bitmap(data.bitmapData);
		Size.size(bitmap, 110, 110);
		sprite.x = (bg.width - bitmap.width) / 2;
		sprite.y = (bg.height - bitmap.height) / 2 + 35;
		sprite.addChild(bitmap);
		addChildAt(sprite, 1);
		bitmap.y = (bg.height - bitmap.height) / 2 - 80;
		bitmap.smoothing = true;
	}
	
	private function drawBttn():void 
	{
		var bttnSettings:Object = {
			caption:Locale.__e("flash:1382952379737"),
			width:105,
			height:35,
			fontSize:22
		}
		
		bttn = new Button(bttnSettings);
		
		addChild(bttn);
		bttn.x = (bg.width - bttn.width) / 2;
		bttn.y = bg.height - bttn.height - 5;
		bttn.addEventListener(MouseEvent.CLICK, onClick);
		
		checkButton();
	}
	
	public function checkButton():void {
		if (!window.settings.target.info.tower.hasOwnProperty(window.settings.target.floor + 1)) {
			bttn.state = Button.DISABLED;
			return;
		}
		if (window.settings.target.kicks >= window.settings.target.info.tower[window.floor + 1].c) {
			bttn.state = Button.NORMAL;
			window.blockItems(true);
		}else {
			bttn.state = Button.DISABLED;
		}
	}
	
	public function drawTitle():void {
		var sprite:Sprite = new Sprite();
		
		var textTitle:TextField = Window.drawText(item.title, {
			color:0x743d16,
			fontSize:18,
			borderColor:0xffffff
		});
		textTitle.width = textTitle.textWidth + 10;
		textTitle.x = 5;
		sprite.addChild(textTitle);
		
		sprite.x = (bg.width - sprite.width) / 2;
		sprite.y += 10;
		addChild(sprite);
	}
	
	public function drawCount():void {		
		var textCount:TextField = Window.drawText('+' + info.k, {
			color:0xffffff,
			fontSize:30,
			borderColor:0x7b3e07
		});
		textCount.width = textCount.textWidth + 10;
		textCount.x = bg.x + bg.width - textCount.width;
		textCount.y = bg.y + bg.height - 10;
		addChild(textCount);
	}
	
	
	public function dispose():void {
		if (bttn) bttn.removeEventListener(MouseEvent.CLICK, onClick);
	}
}
