package wins 
{
	import buttons.Button;
	import buttons.ImageButton;
	import buttons.MoneyButton;
	import core.Numbers;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.utils.setTimeout;
	import ui.Cursor;
	import units.Mhelper;
	/**
	 * ...
	 * @author ...
	 */
	public class MhelperWindow extends Window
	{
		private var mhelper:Mhelper;
		public function MhelperWindow(settings:Object) 
		{
			settings['background'] = "shopBackingTop";
			settings['width'] = 765;
			settings['height'] = 615;
			settings['title'] = settings.target.info.title;
			settings['hasPaginator'] = true;
			settings['hasButtons'] = true;
			settings['hasArrow'] = true;
			settings['itemsOnPage'] = 8;	
			settings['content'] = [];
			super(settings);
			mhelper = settings.target;
		}
		private function showTargets():void
		{
			Window.closeAll();
			var txt:String;
			Mhelper.waitWorker = settings.target;
			Mhelper.chooseTargets = [];
			Mhelper.clickCounter = 0;
			Mhelper.waitForTarget = true;
			//Mhelper.countOfTargets = settings.target.info.stacks;
			App.ui.upPanel.showCancel(Mhelper.waitWorker.onCancel);
			App.ui.upPanel.showConfirm(Mhelper.waitWorker.onConfirm);
			txt = Locale.__e('flash:1441181269694');
			App.ui.upPanel.showHelp(Locale.__e('flash:1455616106139') + ' ' + (Mhelper.waitWorker.targetsLength) + "/" +  Mhelper.waitWorker.stacks, 0);
			
			setTimeout(function():void {
				App.self.addEventListener(MouseEvent.CLICK, Mhelper.waitWorker.unselectPossibleTargets);
			}, 100);
		}
		
		override public function drawBackground():void {
			if (!background) {
				background = new Bitmap();
				layer.addChild(background);
			}
			background.bitmapData = backing2(settings.width, settings.height, 50, "shopBackingTop","shopBackingBot").bitmapData;
		}
		
		override public function drawBody():void 
		{
			super.drawBody();
			createContent();
			paginator.page = 0;
			paginator.itemsCount = settings.content.length;
			paginator.update();
			//drawMirrowObjs('diamondsTop', settings.width / 2 - settings.titleWidth / 2 - 5, settings.width / 2 + settings.titleWidth / 2 + 5, -40, true, true);
			//drawMirrowObjs('diamonds', 22, settings.width - 22, 46, false, false, false, 1, -1); // top
			//drawMirrowObjs('diamonds', 22, settings.width - 21, settings.height - 121 ); // bottom
			//var itemsBack:Bitmap = backing(715, 460, 50, 'shopBackingSmall');
			//itemsCont.addChildAt(itemsBack, 0);
			itemsCont.x = 25;
			itemsCont.y = 57;
			bodyContainer.addChild (itemsCont);
			//infoSlots = drawText(Locale.__e('flash:1455616106139') + ' ' + (mhelper.targetsLength) + "/" +  mhelper.stacks,
				//{
					//textAlign:		'center',
					//autoSize:		'center',
					//fontSize:		34,
					//color:			0x5e430c,
					//borderColor:	0xFFFFFF,
					//shadowSize:		1,
					//width:			174,
					//height:			44,
					//bgColor:		[0xfdefe4,0xfeb163],
					//borderColor:	[0xfadc93,0xfdb163] 
				//}
			//);
			//infoSlots.x = 195;
			//infoSlots.y = settings.height - 103;
			drawButtons();
			contentChange();
			paginator.x = ( settings.width - paginator.width) / 2 - 35;
			paginator.y = settings.height - 32;
			
			
			//bodyContainer.addChild(infoSlots);
			
			
		}
		public var items:Vector.<MhelperWindowItem> = new Vector.<MhelperWindowItem>();
		private function createContent():void
		{
			settings.content.splice (0, settings.content.length);
			var count:int = 0;
			for each(var item:* in settings.target.targets) {
				settings.content.push(item);
				count++;
			}
			var slot:Object = null;
			for ( ; count < mhelper.info.stacks; count ++ )
			{
				settings.content.push(slot);
			}
		}
		private var itemsCont:Sprite = new Sprite();
		override public function contentChange():void 
		{
			super.contentChange();
			for each(var _item:MhelperWindowItem in items) {
				itemsCont.removeChild(_item);
				_item.dispose();
				_item = null;
			}
			var counter:int = 0;
			items = new Vector.<MhelperWindowItem>();
			for (var i:int = paginator.startCount; i < paginator.finishCount; i++)
			{
				var item:MhelperWindowItem = new MhelperWindowItem(settings.content[i], this, i);
				
				itemsCont.addChild(item);
					
				items.push(item);

				item.x = (item.bg.width + 7)  * (counter % (settings.itemsOnPage / 2)) + 17;
				item.y = (item.bg.height + 20) * ( Math.floor(counter / (settings.itemsOnPage / 2)) ) + 15;
				counter++;
			}
			
			settings.page = paginator.page;
			blockAll(isBlock);
			//infoSlots.text = Locale.__e('flash:1455616106139') + ' ' + (mhelper.targetsLength) + "/" +  mhelper.stacks;
			buttnsCheak();
		}
		private function buttnsCheak():void
		{
			//if ( mhelper.targetsLength >= mhelper.info.stacks )
			//{
				//slotsBttn.visible = false;
				//slotsBttn.removeEventListener(MouseEvent.CLICK, slotsEvent);
				////infoSlots.x = (settings.width + infoSlots.width) / 2;
			//}
			if (detachMode)
			{
				attachBttn.state = Button.DISABLED;
				detachBttn.state = Button.DISABLED;
				speed.state = Button.DISABLED;
				collect.state = Button.DISABLED;
				return;
			}
			//else
			//{
				//attachBttn.state = Button.NORMAL;
				//detachBttn.state = Button.NORMAL;
				//speed.state = Button.NORMAL;
				//collect.state = Button.NORMAL;
			//}
			//
			
			if (speed)
			{
				speed.countLabelText = mhelper.getPriceItems();
				if ( mhelper.getPriceItems() <= 1)
					speed.state = Button.DISABLED;
				else
					speed.state = Button.NORMAL;
			}
			if ( collect )
			{
				var count:int = Numbers.countProps(mhelper.findCollect());
				if ( count >0/* && App.user.stock.data[Stock.FANTASY] > count*/ )
					collect.state = Button.NORMAL;
				else
					collect.state = Button.DISABLED;
			}
			if ( mhelper.targetsLength >= mhelper.stacks )
			{
				attachBttn.state = Button.DISABLED;
			}
			else
			{
				attachBttn.state = Button.NORMAL;
			}
			if ( mhelper.targetsLength <= 0 )
			{
				detachBttn.state = Button.DISABLED;
				
			}
			else
			{
				detachBttn.state = Button.NORMAL;
			}
			
		}
		override public function drawArrows():void 
		{
			super.drawArrows();
			
			paginator.arrowLeft.x = -paginator.arrowLeft.width / 2 + 25;
			paginator.arrowRight.x = settings.width-paginator.arrowRight.width/2 - 25;
			paginator.arrowLeft.y = 235;
			paginator.arrowRight.y = 235;
		}
		private function drawButtons():void
		{
			helpButton = new ImageButton(Window.textures.interHelpBttn);
			//helpButton.scaleX = helpButton.scaleY = 0.75;
			helpButton.x = exit.x - helpButton.width -3;
			exit.y -= 10;
			helpButton.y = exit.y;
			headerContainer.addChild(helpButton);
			helpButton.onMouseDown = showHelp;
			var buttonSettings:Object = {
				textAlign:		'center',
				autoSize:		'center',
				fontSize:		26,
				color:			0x5e430c,
				borderColor:	0xFFFFFF,
				shadowSize:		1,
				width:			163,
				height:			44,
				//bgColor:		[0xfdefe4,0xfeb163],
				//bevelColor:		[0xfadc93, 0xfdb163],
				fontBorderColor:0xa26137
			};
			buttonSettings['caption'] = Locale.__e ("flash:1455612395643");
			collect = new Button(buttonSettings);
			buttonSettings['caption'] = Locale.__e ("flash:1382952379978");
			attachBttn = new Button(buttonSettings);
			attachBttn.y = 23;
			bodyContainer.addChild(attachBttn);
			attachBttn.addEventListener(MouseEvent.CLICK, attachEvent );
			buttonSettings['caption'] = Locale.__e ("flash:1382952380210");
			detachBttn = new Button(buttonSettings);
			detachBttn.y = 23;
			bodyContainer.addChild(detachBttn);
			detachBttn.addEventListener(MouseEvent.CLICK, detachEvent);
			
			
			//buttonSettings['bgColor'] = 		[0xfba89b, 0xf2868b];
			//buttonSettings['bevelColor']=		[0xfebfaf, 0xcb6b66],
			//buttonSettings['fontBorderColor'] =	0xae3f41;
			//buttonSettings['fontCountBorder'] =	0xae3f41;
			buttonSettings['caption'] = Locale.__e ("flash:1455612453434");
			speed = new MoneyButton(buttonSettings);
			speed.countLabelText = mhelper.getPriceItems();
			collect.y = speed.y = 23;
			bodyContainer.addChild (speed);
			bodyContainer.addChild (collect);
			speed.addEventListener(MouseEvent.CLICK, speedAction);
			collect.addEventListener(MouseEvent.CLICK, collectAction);
			
			
			
			//buttonSettings['caption'] = Locale.__e ('flash:1382952379751'); /*Locale.__e ("flash:1396962973677") + (mhelper.stacks + 1)*/;
			//buttonSettings['width'] = 200;
			//buttonSettings['height'] = 38;
			//slotsBttn = new  MoneyButton(buttonSettings);
			//slotsBttn.x = infoSlots.x + infoSlots.textWidth + 15 ;
			//slotsBttn.y = infoSlots.y ;
			//slotsBttn.countLabelText = mhelper.info.extra[ins];
			//bodyContainer.addChild(slotsBttn);
			//slotsBttn.addEventListener(MouseEvent.CLICK, slotsEvent);
			detachBttn.x = (settings.width + speed.width - detachBttn.width) / 2+2;
			speed.x = (settings.width - speed.width - collect.width) / 2 -2;
			collect.x = -collect.width + speed.x-4;
			attachBttn.x = detachBttn.x + detachBttn.width + 4;
			
			if (settings.target.sid == 1648) {
				speed.visible = false;
				
				collect.x = (settings.width - detachBttn.width) / 4 - 15;
				detachBttn.x = collect.x + collect.width + 4;
				attachBttn.x = detachBttn.x + detachBttn.width + 4;
			}
		}
		
		private var helpButton:ImageButton;
		public var detachMode:Boolean = false;
		private function detachEvent(e:MouseEvent = null):void
		{
			//if ( e.target.mode == Button.DISABLED )
				//return;
			detachMode = !detachMode;
			contentChange();
			blockAll(detachMode);
			//mhelper.startDetach(
		}
		
		private function showHelperTargets(possibleSIDs:Array = null):void {
			if (!possibleSIDs) possibleSIDs = [];
		
			possibleTargets = Map.findUnits(possibleSIDs);
			for each(var res:* in possibleTargets)
			{
				if (/*res.info.block ||*//* res.hasProduct ||*/ res.lock) continue;
				
				if (settings.target.permittedTargets != null) {
					var skip:Boolean = true;
					for each (var targ:* in settings.target.permittedTargets) {
						if (res.sid == targ) {
							skip = false;
							res.lock = false;
							break;
						}
						res.lock = true;
					}
					
					if (!skip) res.state = res.HIGHLIGHTED;
				} else {
					res.state = res.HIGHLIGHTED;
				}
			}
		}
		private function attachEvent(e:MouseEvent = null):void
		{
			if ( e.target.mode == Button.DISABLED )
				return;
			//mhelper.startAttch();
			settings.target.lockExludes();
			showHelperTargets(settings.target.posibleTargets);
			showTargets();
			blockAll(true);
			Cursor.type = 'mhelper';
		}
		private function speedAction(e:MouseEvent):void {
			if ( speed.mode == Button.DISABLED )
				return;
			mhelper.speedAction(this);
			blockAll(true);
		}
		private function collectAction(e:MouseEvent):void {
			if (e.target.mode == Button.DISABLED)
				return;
			mhelper.collectAction(this);
			blockAll(true);
		}
		private function showHelp(e:MouseEvent):void
		{
			if (settings.target.sid == 1648) new InfoWindow( { qID:'100100', popup:true } ).show();
			else new InfoWindow( { qID:'100200', popup:true } ).show();
		}
		private var isBlock:Boolean = false;
		private var collect:Button;
		private var speed:MoneyButton;
		private var possibleTargets:Array;
		private var attachBttn:Button;
		private var detachBttn:Button;
		//private var slotsBttn:MoneyButton;
		//private var infoSlots:TextField;
		public function blockAll(value:Boolean):void
		{
			
			isBlock = value;
			for each (var item:MhelperWindowItem in items)
			{
				item.block(value);
			}
		}
		//private var queue:Array = new Array();
		override public function dispose():void 
		{
			super.dispose();
			for each (var item:MhelperWindowItem in items)
			{
				item.dispose();
			}
		}
	}

}
import buttons.Button;
import buttons.MoneyButton;
import core.Load;
import core.Numbers;
import core.TimeConverter;
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.text.TextField;
import ui.UserInterface;
import units.Anime2;
import units.Mhelper;
import units.Personage;
import wins.MhelperWindow;
import wins.Window;
internal class MhelperWindowItem extends LayerX
{
	private var icon:Bitmap = new Bitmap();
	public var bg:Bitmap;
	private var win:MhelperWindow;
	private var item:Object;
	private var txtTime:TextField;
	private var stockBttn:Button;
	private var boostBttn:MoneyButton;
	private var mhelper:Mhelper;
	private var detachBttn:Button;
	private var index:int = 0;
	private var preloader:Preloader = new Preloader();
	public function MhelperWindowItem(_item:Object, _win:MhelperWindow,_index:int) 
	{
		
		item = _item;
	
		win = _win;
		mhelper = win.settings.target;
		index = _index;
		var backing:String = 'itemBacking';
			
		//if (item.info.hasOwnProperty('backview') && item.info.backview != '')
			//backing = item.info.backview;
		//else
		//{
			//if (item.info.type == 'Golden')
				//backing = 'shopSpecialBacking';
			//if (item.info.type == 'Gamble')
				//backing = 'blueItemBacking';
			//if (item.info.type == 'Helper')
				//backing = "itemGoldenBacking";
		//}
		
		bg = Window.backing(165, 200, 45,  backing);
		bg.x = 0;
		bg.y = 0;
		sprite = new LayerX();
		
		sprite.tip = function():Object {
			var check:Object = mhelper.cheackState(item);
			if (check.isReady == Mhelper.READY){
				return {
					title:item.info.title,
					text:Locale.__e("flash:1382952379966") + '\n'
				};
			}
			return {
				title:item.info.title,
				text:Locale.__e("flash:1382952379839", [TimeConverter.timeToStr(item.crafted - App.time)]) + '\n',
				timer:true
			};
		}
		preloader.x = (bg.width)/ 2;
		preloader.y = (bg.height)/ 2 - 15;
		addChildAt(bg, 0);
		sprite.addChild(icon);
		addChild(sprite);
		if (item) {	
			
			item.info = App.data.storage[item.sid];
			//item.type = item.info.type;
			addChild(preloader);
			//if (item.type == "Golden" ) {
				//
				////Load.loading(Config.getSwf(item.type, item.view), onLoadAnimate);
				//Load.loading(Config.getSwf(item.info.type, item.info.view), onLoadObj);
			//}else if (item.type == "Walkgolden") {
				//Load.loading(Config.getSwf(item.info.type, item.info.view), onLoadAnimate);
			//}
			Load.loading (Config.getIcon(item.info.type, item.info.view),onLoadObj);
			drawTimer();
			checkState();
		}else{
			drawSlot();
		}
		
	}
	
	//private function onLoadObj(swf:*):void 
	//{
		//removeChild(preloader);
		//var _animal:Boolean = (item.type == 'Walkgolden' ||  item.type == 'Animal' /*|| item.type == 'Golden'*/);
		//var anime:Anime2 = new Anime2(swf, { w:bg.width - 20, h:bg.height - 40, animal: _animal });
		//anime.x = (bg.width - anime.width) / 2;
		//anime.y = (bg.height - anime.height) / 2;
		//sprite.addChild(anime);
		//drawTitle();
	//}
	//
	//private function onLoadAnimate(swf:*):void {
		//removeChild(preloader);
		//var anime2:Anime2;
//
		//anime2 = new Anime2(swf, { animal:true, framesType:Personage.STOP ,  w:bg.width - 20, h:bg.height - 40} );
		//anime2.x = ( bg.width -  anime2.width ) / 2;
		//anime2.y = ( bg.height -  anime2.height ) / 2  ;
	//
		//sprite.addChild(anime2);
		//drawTitle();
	//}
	private function onLoadObj(data:Bitmap):void
	{
		removeChild(preloader);
		
	
		icon.bitmapData = data.bitmapData;
		icon.height = 130;
		icon.scaleX = icon.scaleY;
		if ( icon.width > 150 )
		{
			icon.width = 150;
			icon.scaleY = icon.scaleX;
		}
		icon.smoothing = true;
		icon.x = (bg.width - icon.width)/2;
		icon.y =  (bg.height - icon.height) / 2;
		drawTitle();

	}
	private function drawTitle ():void
	{
		var title:TextField = Window.drawText(item.info.title, {
			width:			bg.width - 10,
			textAlign:		'center',
			fontSize:		20,
			textLeading:	-9,
			multiline:		true,
			color:			0x7f5130,
			borderColor:	0xf3d8ab,
			borderSize:		2,
			wrap:			true
		});
		//title.width = title.textWidth + 5;
		title.x = (bg.width - title.width) / 2 + 5;	
		title.y = 10;
		addChild(title);
	}
	private function slotsEvent(e:MouseEvent):void
	{
		if ( e.target.mode == Button.DISABLED )
			return;
		win.blockAll(true);
		mhelper.extendAction(win);
	}
	private var plus:Bitmap = new Bitmap();
	private var plusBttn:MoneyButton;
	private var sprite:LayerX;
	private function drawSlot():void
	{
		plus.bitmapData = Window.textures.plus;
		plus.x = (bg.width - plus.width) / 2;
		plus.y = (bg.height - plus.height) / 2;
		addChild(plus);
		if ( index >= mhelper.targetsLength && mhelper.stacks > index )
		{
			bg.alpha = 1;
			if (plusBttn )
				plusBttn.visible = false;
		}
		else
		{
			for ( var ins:Object in mhelper.info.extra )
				break;
			bg.alpha = 0.7;
			if (plusBttn )
				plusBttn.visible = true;
			
			plusBttn = new MoneyButton({
				textAlign:			'center',
				autoSize:			'center',
				fontSize:			22,
				caption:			Locale.__e("flash:1382952379890"),
				color:				0x5e430c,
				borderColor:		0xFFFFFF,
				shadowSize:			1,
				width:				134,
				countText:			mhelper.info.extra[ins]
			});
			plusBttn.x = (bg.width - plusBttn.width ) / 2;
			plusBttn.y = 175;
			addChild (plusBttn);
			plusBttn.addEventListener(MouseEvent.CLICK,slotsEvent);
		}
	}
	private function drawTimer():void
	{
		var textSettings:Object = {
			text:Locale.__e("flash:1382952379793"),
			color:0xffda20,
			fontSize:24,
			borderColor:0x734e24,
			//scale:0.5,
			textAlign:'center'
		}
		
		txtTime = Window.drawText(TimeConverter.timeToStr(getTime()), textSettings);
		
		txtTime.x = (bg.width - txtTime.width ) / 2;
		txtTime.y = 145;
		addChild(txtTime);
		App.self.setOnTimer(updateDuration);
		if ( getTime() <= 0 )
		{
			txtTime.visible = false;
			App.self.setOffTimer(updateDuration);
		}
	}
	private function updateDuration():void
	{
		txtTime.text = TimeConverter.timeToStr(getTime());
		if ( getTime() <= 0 )
		{
			checkState();
		}
	}
	private function getTime():int
	{
		return mhelper.getTime(item);
	}
	private function checkState():void
	{
		var textSettings:Object = {
			text:		Locale.__e("flash:1382952379793"),
			color:		0xffffff,
			fontSize:	18,
			borderColor:0xfc0000,
			//scale:0.5,
			width:		190,
			textAlign:	'center',
			shadowSize:		1
		}
		if (  win.detachMode)
		{
			if (!detachBttn)
			{
				detachBttn = new Button ({
					textAlign:		'center',
					autoSize:		'center',
					fontSize:		28,
					caption:		Locale.__e("flash:1382952380210"),
					color:			0x5e430c,
					borderColor:	0xFFFFFF,
					shadowSize:		1,
					width:			120
				});
				detachBttn.addEventListener(MouseEvent.CLICK, detachEvent);
				addChild(detachBttn);
				detachBttn.x = (bg.width - detachBttn.width) / 2;
				detachBttn.y = 175;
			}
			return;
		}
		var check:Object = mhelper.cheackState(item);
		if ( check.isReady == Mhelper.READY )
		{
			txtTime.visible = false;
			App.self.setOffTimer(updateDuration);
			if (!stockBttn)
			{
				stockBttn = new Button (
					{
						textAlign:		'center',
						autoSize:		'center',
						fontSize:		28,
						caption:		Locale.__e("flash:1382952380146"),
						color:			0x5e430c,
						borderColor:	0xFFFFFF,
						shadowSize:		1,
						width:			120
					}
				);
				stockBttn.addEventListener(MouseEvent.CLICK, storageEvent);
				addChild(stockBttn);
				stockBttn.x = (bg.width - stockBttn.width) / 2;
				stockBttn.y = 175;
			}
		}
		if (check.isBoost == Mhelper.UNBOOST)
		{
			//txtTime.visible = false;
			//App.self.setOffTimer(updateDuration);
			var inform:TextField =  Window.drawText(Locale.__e('flash:1455701570918'), textSettings);
			inform.x = (bg.width - inform.width ) / 2;
			inform.y = 135;
			txtTime.y = 155;
			if (check.isReady == Mhelper.READY)
			{
				inform.y = 145;
			}
			addChild(inform);
		}
		if ( check.isReady == Mhelper.UNREADY && check.isBoost == Mhelper.BOOST)
		{
			if (!boostBttn)
			{
				boostBttn = new MoneyButton (
					{
						textAlign:		'center',
						autoSize:		'center',
						fontSize:		22,
						caption:		Locale.__e("flash:1382952380104"),
						color:			0x5e430c,
						borderColor:	0xFFFFFF,
						shadowSize:		1,
						width:			134,
						countText:		mhelper.getPriceItems(item)
					}
				);
				boostBttn.addEventListener(MouseEvent.CLICK, boostEvent);
				addChild(boostBttn);
				boostBttn.x = (bg.width - boostBttn.width) / 2;
				boostBttn.y = 175;
			}
		}
	}
	public function block(value:Boolean):void
	{
		if ( !item )
		{
			if ( plusBttn )
			{
				if (value)
					plusBttn.state = Button.DISABLED;
				else 
					plusBttn.state = Button.NORMAL;
			}
			return;
		}
		if (stockBttn)
			stockBttn.visible = !value;
		if ( txtTime )
			txtTime.visible = !value;
		if ( boostBttn )
			boostBttn.visible = !value;
		if (!value && item)
			checkState();
	}
	private function storageEvent(e:MouseEvent):void 
	{
		win.blockAll(true);
		mhelper.collectAction(win,item);
	}
	private function detachEvent(e:MouseEvent):void 
	{
		win.close();
		mhelper.startDetach(item);
	}
	private function boostEvent(e:MouseEvent):void 
	{
		win.blockAll(true);
		mhelper.speedAction(win,item);
	}
	public function dispose():void
	{
		App.self.setOffTimer(updateDuration);
	}
	
}

//import buttons.Button;
//import flash.display.Bitmap;
//import flash.events.MouseEvent;
//import flash.text.TextField;
//
//internal class InfoWindow extends Window
//{
	//protected var descriptionLabel:TextField;
	//public var descText:String;
	////public var background:Bitmap = Window.backing2(490, 110, 44, 'questTaskBackingTop', 'questTaskBackingBot');
	//public function InfoWindow(settings:Object = null){
		//if (settings == null) {
			//settings = new Object();
		//}
		//settings['background'] 		= 'questBacking';
		//settings['width'] 			= 580;
		//settings['height'] 			= 510;
		//settings['title'] 			= Locale.__e('flash:1382952380254');
		//settings['hasPaginator'] 	= false;
		//settings['hasExit'] 		= true;
		//settings['hasTitle'] 		= true;
		//settings['faderClickable'] 	= true;
		//settings['faderAlpha'] 		= 0.6;
		//
		//super(settings);
	//}
	//
	//override public function drawBody():void {
		//
		//drawDecorations();
		//
		//var bttn:Button = new Button( {  width:194, height:53, caption:Locale.__e('flash:1382952380298') } );
		//bodyContainer.addChild(bttn);
		//bttn.x = (settings.width - bttn.width) / 2;
		//bttn.y = settings.height - bttn.height - 20;
		//bttn.addEventListener(MouseEvent.CLICK, close);
		//
		//exit.y -= 20;
		//var descPrms:Object = {
				//color			:0xffffff,
				//borderColor		:0x7a471c,
				//width			:520,
				//multiline		:true,
				//wrap			:true,
				//textAlign		:'center',
				//fontSize		:28
			//}
		//descriptionLabel = Window.drawText(Locale.__e('flash:1453892102696')/*settings.target.info.description*/, descPrms);
		//descriptionLabel.x = bodyContainer.x + 30;
		//descriptionLabel.y = bodyContainer.y + 30;
		//descriptionLabel.width = bodyContainer.width - 60;
		//if(!descriptionLabel.parent)
			//bodyContainer.addChild(descriptionLabel);
	//}
	//
	//
	//protected function drawDecorations():void {
		//drawMirrowObjs('diamondsTop', settings.width / 2 - settings.titleWidth / 2 - 5, settings.width / 2 + settings.titleWidth / 2 + 5, -44, true, true);
		//drawMirrowObjs('storageWoodenDec', 0, settings.width - 0, settings.height - 120 + 6);
		//drawMirrowObjs('storageWoodenDec', 0, settings.width - 0, 35, false, false, false, 1, -1);
	//}
//}