package wins 
{
	import buttons.Button;
	import buttons.MoneyButton;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	public class TrapWindow extends Window 
	{
		public var item:MaterialItem;
		public var itemSprite:Sprite = new Sprite();
		public var speedSprite:Sprite = new Sprite();
		private var progressBar:ProgressBar;
		public var boostBttn:MoneyButton;
		public function TrapWindow(settings:Object=null) 
		{
			if (settings == null) {
				settings = new Object();
			}
			
			settings["width"] = 560;
			settings["height"] = 370;
			settings["background"] = 'goldBacking';
			settings["hasPaginator"] = false;
			settings["hasArrows"] = false;
			settings['target'] = settings.target;
			
			super(settings);			
		}
		
		override public function drawBody():void {
			bodyContainer.addChild(itemSprite);
			bodyContainer.addChild(speedSprite);
			
			var desc:TextField = drawText(settings.target.info.description, {
				width:settings.width - 150,
				multiline:true,
				wrap:true,
				fontSize:22,
				textAlign:'center',
				color:0x5c3d1e,
				border:false
			});
			desc.x = 75;
			desc.y = 10;
			bodyContainer.addChild(desc);
			
			item = new MaterialItem(this, settings.target.info['in']);
			item.x = (settings.width - item.width) / 2;
			item.y = settings.height - item.height - 65;
			itemSprite.addChild(item);
			
			var progressBacking:Bitmap = Window.backingShort(370, "progBarBacking");
			progressBacking.x = (settings.width - progressBacking.width) / 2;
			progressBacking.y = 150;
			speedSprite.addChild(progressBacking);
			
			progressBar = new ProgressBar({win:this, width:progressBacking.width + 16, isTimer:true});
			progressBar.x = progressBacking.x - 8;
			progressBar.y = progressBacking.y - 4;
			speedSprite.addChild(progressBar);			
			progressBar.start();
			progress();
			App.self.setOnTimer(progress);
			
			boostBttn = new MoneyButton( {
				caption:Locale.__e("flash:1382952380104"),
				countText:String(settings.target.info.skip),
				width:200,
				height:46,
				fontSize:30,
				fontCountSize:32,
				radius:26,
				
				bgColor:[0xa8f84a, 0x73bb16],
				borderColor:[0xffffff, 0xffffff],
				bevelColor:[0xcefc97, 0x5f9c11],	
				
				fontColor:0xffffff,			
				fontBorderColor:0x2b784f,
			
				fontCountColor:0xffffff,				
				fontCountBorder:0x2b784f,
				iconScale:0.8
			});
			boostBttn.x = (settings.width - boostBttn.width) / 2;
			boostBttn.y = 200;
			speedSprite.addChild(boostBttn);
			boostBttn.addEventListener(MouseEvent.CLICK, onBoostClick);
			
			checkState();
		}
		
		private function progress():void
		{
			if (!progressBar) return;
			if (settings.target.started + settings.target.info.time > App.time) {
				progressBar.progress = Math.abs((App.time - settings.target.started) / settings.target.info.time);
				progressBar.time = settings.target.started + settings.target.info.time - App.time;
				
			}else {
				checkState();
			}
		}
		
		public function checkState():void {
			if (settings.target.started > 0 && settings.target.started + settings.target.info.time > App.time ) {
				speedSprite.visible = true;
				itemSprite.visible = false;
			} else if (settings.target.started > 0 && settings.target.started + settings.target.info.time <= App.time) {
				speedSprite.visible = false;
				itemSprite.visible = false;
				close();
			}
			else {
				speedSprite.visible = false;
				itemSprite.visible = true;
			}
		}
		
		public function onBoostClick(e:MouseEvent):void {
			if (e.currentTarget.mode == Button.DISABLED) return;
			settings.target.boostAction();
			close();
		}
		
		override public function dispose():void {
			item.dispose();
			App.self.setOffTimer(progress);
			boostBttn.removeEventListener(MouseEvent.CLICK, onBoostClick);
			super.dispose();
		}
		
	}

}
import buttons.Button;
import buttons.MoneyButton;
import core.Load;
import core.Size;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.text.TextField;
import wins.ShopWindow;
import wins.Window;

internal class MaterialItem extends Sprite {
	
	public var bg:Bitmap;
	public var icon:Bitmap;
	public var sID:int;
	public var count:int;
	public var window:*;
	
	public var bttn:Button;
	public var findBttn:Button;
	public var buyBttn:MoneyButton;
	public function MaterialItem(window:*, data:Object):void {
		this.window = window;
		
		bg = Window.backing(140, 180, 50, 'itemBacking');
		addChild(bg);
		
		for (var s:* in data) {
			sID = int(s);
			count = data[sID];
		}
		Load.loading(Config.getIcon(App.data.storage[sID].type, App.data.storage[sID].preview), onLoad);
		
		drawTitle();
		drawButtons();
	}
	
	private function onLoad(data:*):void {
		icon = new Bitmap(data.bitmapData);
		Size.size(icon, 100, 100);
		icon.smoothing = true;
		icon.x = (bg.width - icon.width) / 2;
		icon.y = 30;
		addChild(icon);
	}
	
	private function drawTitle():void {
		var title:TextField = Window.drawText(App.data.storage[sID].title, {
			width:bg.width,
			color:0x7c3e0f,
			borderColor:0xffffff,
			fontSize:22,
			textAlign:'center'
		});
		title.y = 5;
		addChild(title);
		
	}
	
	private function drawButtons():void {
		bttn = new Button( {
			caption:Locale.__e('flash:1461683580268'),
			width:bg.width - 20,
			height:35,
			fontSize:24
		});			
		addChild(bttn);
		bttn.x = (bg.width - bttn.width) / 2;
		bttn.y = bg.height - bttn.height;
		bttn.addEventListener(MouseEvent.CLICK, onClick);
		
		findBttn = new Button( {
			caption:Locale.__e('flash:1405687705056'),
			width:bg.width - 20,
			height:35,
			fontSize:24,
			radius:10,
			//fontColor:		0xffffff,
			fontBorderColor:0x475465,
			borderColor:	[0xfff17f, 0xbf8122],
			bgColor:		[0x75c5f6,0x62b0e1],
			bevelColor:		[0xc6edfe,0x2470ac]
		});
		addChild(findBttn);
		findBttn.x = (bg.width - findBttn.width) / 2;
		findBttn.y = bg.height - findBttn.height + 25;
		findBttn.addEventListener(MouseEvent.CLICK, onFind);
		
		buyBttn = new MoneyButton( {
			caption		:Locale.__e('flash:1382952379751'),
			width		:112,
			height		:36,
			fontSize	:22,
			radius		:16,
			countText	:App.data.storage[sID].price[Stock.FANT],
			multiline	:true
		});
		addChild(buyBttn);
		buyBttn.x = (bg.width - buyBttn.width) / 2;
		buyBttn.y = bg.height - findBttn.height - buyBttn.height + 23;
		buyBttn.addEventListener(MouseEvent.CLICK, onBuy);
		
		checkButtons();
	}
	
	private function checkButtons():void {
		if (App.user.stock.check(sID, count)) {
			bttn.visible = true,
			findBttn.visible = false;
			buyBttn.visible = false;
		}else {
			bttn.visible = false,
			findBttn.visible = true;
			buyBttn.visible = true;
		}
	}
	
	private function onClick(e:MouseEvent):void {
		if (e.currentTarget.mode == Button.DISABLED) return;
		window.settings.target.kickEvent();
		Window.closeAll();
	}
	
	private function onFind(e:MouseEvent):void {
		if (e.currentTarget.mode == Button.DISABLED) return;
		Window.closeAll();
		ShopWindow.findMaterialSource(sID); 
	}
	
	private function onBuy(e:MouseEvent):void
	{
		if (e.currentTarget.mode == Button.DISABLED) return;		
		e.currentTarget.state = Button.DISABLED;
		App.user.stock.buy(sID, count, onBuyEvent);
	}
	
	private function onBuyEvent(price:Object):void
	{		
		checkButtons();
	}
	
	public function dispose():void {
		bttn.removeEventListener(MouseEvent.CLICK, onClick);
		findBttn.removeEventListener(MouseEvent.CLICK, onFind);
	}
}