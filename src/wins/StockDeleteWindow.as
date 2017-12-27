package wins 
{
	import buttons.Button;
	import buttons.ImageButton;
	import buttons.PageButton;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import ui.UserInterface;
	/**
	 * ...
	 * @author 
	 */
	public class StockDeleteWindow extends Window
	{
		
		public var OkBttn:Button;
		public var ConfirmBttn:Button;
		public var CancelBttn:Button;
		
		public var textLabel:TextField = null;
		public var _titleLabel:TextField = null;
		
		private var bitmapLabel:Bitmap = null;
		private var dY:int = 0;
		private var dX:int = 0;
		private var textLabel_dY:int = 0;
		private var titleLabel_dY:int = 0;
		
		private var plus:PageButton;
		private var minus:PageButton;
		private var _counter:Sprite;
		private var stockCountBg:Sprite;
		
		public var icon:Icon;
		
		public function StockDeleteWindow(settings:Object = null)
		{
			if (settings == null) {
				settings = new Object();
			}
			
			//settings['background']      = "";
			settings['hasTitle']		= settings.hasTitle || false;
			settings["label"] 			= settings.label || null;
			settings['text'] 			= settings.text || '';
			settings['textAlign'] 		= settings.textAlign || 'center';
			settings['autoSize'] 		= settings.autoSize || 'center';
			settings['textSize'] 		= settings.textSize || 32;
			settings['padding'] 		= settings.padding || 20;
			
			settings['hasButtons']		= settings['hasButtons'] == null ? true : settings['hasButtons'];
			settings['dialog']			= settings['dialog'] || false;
			settings['buttonText']		= settings['buttonText'] || Locale.__e('flash:1382952380298');
			settings['confirmText']		= settings['confirmText'] || Locale.__e('flash:1382952380299');
			settings['cancelText']		= settings['cancelText'] || Locale.__e('flash:1383041104026');
		
			settings['confirm']			= settings.confirm || null;
			settings['cancel']			= settings.cancel || null;
			settings['ok']				= settings.ok || null;
			
			settings["width"]			= settings.width || 510;// 380;
			settings["height"] 			= settings.height || 250;// 365;
			
			settings["hasPaginator"] 	= false;
			settings["hasArrows"]		= false;
			
			settings["fontSize"]		= 38;
			
			settings["hasPaper"]	 	= true;
			settings["hasTitle"]		= true;
			settings["hasExit"]			= settings.hasExit || false;
			
			settings["fontColor"]       = 0xffffff//0xf5cf57;
			
			settings["hasExit"]         = true;
			
			settings["bitmap"]	 		= settings.bitmap || null;
			if (!settings.hasOwnProperty("closeAfterOk"))
			{
				settings["closeAfterOk"] = true
			}
			
			textLabel_dY = 0;
			
			super(settings);
		}
		
		override public function drawBackground():void {
				
			//var background:Bitmap = backing2(settings.width, settings.height, 45, "questsSmallBackingTopPiece", 'questsSmallBackingBottomPiece');
			//bodyContainer.addChild(background);
			//background.y -= 20;
		}
		
		override public function drawExit():void 
		{
			exit = new ImageButton(textures.closeBttn);
			headerContainer.addChild(exit);
			exit.x = settings.width - 44;
			exit.y = -5;
			exit.addEventListener(MouseEvent.CLICK, close);
		}
		
		override public function drawBody():void {
			
			/*switch(settings.label) {
				case SimpleWindow.ERROR:
					bitmapLabel = new Bitmap(Window.textures.errorLabel);
				break;	
				case SimpleWindow.CRYSTALS:
					bitmapLabel = new Bitmap();
					bitmapLabel.bitmapData = Load.getCache(Config.getImage('promo/images', 'crystals')).bitmapData;
				break;
				case SimpleWindow.ATTENTION:
					bitmapLabel = new Bitmap(Window.textures.alarmLabel);
				break;	
				case SimpleWindow.TREASURE:
					bitmapLabel = new Bitmap(Window.textures.treasuresLabel);
				break;	
				case SimpleWindow.MATERIAL:
					bitmapLabel = new Bitmap(new BitmapData(10,10,true,0));
					Load.loading(Config.getIcon(App.data.storage[settings.sID].type, App.data.storage[settings.sID].preview), 
						function(data:Bitmap):void
						{
							dY = 40;
							bitmapLabel.bitmapData = data.bitmapData;
							bitmapLabel.x = (settings.width - bitmapLabel.width) / 2;
							bitmapLabel.y = - bitmapLabel.height / 2 + dY;
						});
				break;
				case SimpleWindow.BUILDING:
					bitmapLabel = new Bitmap(new BitmapData(10,10,true,0));
					Load.loading(Config.getIcon(App.data.storage[settings.sID].type, App.data.storage[settings.sID].preview), 
						function(data:Bitmap):void
						{
							dY = 40;
							
							bitmapLabel.bitmapData = data.bitmapData;
							
							if (bitmapLabel.height > 120) {
								var ratio:Number = 120 / bitmapLabel.height;
								bitmapLabel.smoothing = true;
								bitmapLabel.scaleX = bitmapLabel.scaleY = ratio;
							}
							
							bitmapLabel.x = (settings.width - bitmapLabel.width) / 2;
							bitmapLabel.y = - bitmapLabel.height / 2 + dY;
						});	
				break;	
			}
			
			if (bitmapLabel != null) {
				bitmapLabel.x = (settings.width - bitmapLabel.width) / 2;
				bitmapLabel.y = - bitmapLabel.height / 2 + dY;
				layer.addChild(bitmapLabel);
			}*/
			
			//var back:Bitmap = backing(settings.width - 22, settings.height - 16, 75, 'questsMainBacking2');
			var back:Bitmap = backing2(settings.width, settings.height, 45, "questsSmallBackingTopPiece", 'questsSmallBackingBottomPiece');
			back.x = (settings.width - back.width) / 2;
			back.y = (settings.height - back.height) / 2 -22;
			bodyContainer.addChildAt(back, 0);
			drawMirrowObjs('storageWoodenDec', -10, settings.width + 10, settings.height - 92);
			
			if (settings.isImg) {
				//var robotIcom:Bitmap = new Bitmap(UserInterface.textures.alert_storage);
				var robotIcom:Bitmap = new Bitmap(Window.textures.errorStorage);
				//bodyContainer.addChild(robotIcom);
				robotIcom.x = -110;
				robotIcom.y = -90;
			}
			
			drawBttns();
			
			titleLabel.y = 10;
			if (settings.label == null)
					titleLabel.y -= 50;
			
			textLabel = Window.drawText(settings.text, {
				color:0x65371b,
				borderColor:0x2b3b64,
				borderSize:0,
				fontSize:settings.textSize,
				textAlign:settings.textAlign,
				autoSize:settings.autoSize,
				multiline:true
			});
			
			textLabel.wordWrap = true;
			textLabel.mouseEnabled = false;
			textLabel.mouseWheelEnabled = false;
			textLabel.width = 240;//settings.width - 100;
			textLabel.height = textLabel.textHeight + 4;
			//textLabel.border = true;
			
			var y1:int = titleLabel.y + titleLabel.height;
			var y2:int = bottomContainer.y;
			
			textLabel.y = (y1 + (y2 - y1) / 2 - textLabel.height/2 - 20) + 15;
			textLabel.x = settings.width - textLabel.width - 30;//(settings.width - textLabel.width) / 2;
			//var bgText:Bitmap = backing2(textLabel.width + 30, textLabel.height + 40, 30, "cursorsPanelBg", "cursorsPanelBg2");
			//bodyContainer.addChildAt(bgText, 0);
			//bgText.x = textLabel.x - 15;
			//bgText.y = textLabel.y - 18;
			
			bodyContainer.addChild(textLabel);
			
			drawMirrowObjs('diamondsTop', settings.width / 2 - settings.titleWidth / 2 - 5, settings.width / 2 + settings.titleWidth / 2 + 5, settings.titleHeight/2 + titleLabel.y + 3, true, true, true);
			
			icon = new Icon(this);
			bodyContainer.addChild(icon);
			icon.x = 30;
			icon.y = 15;
			
			icon.change(settings.sid);
		}
		
		override public function drawTitle():void 
		{
			titleLabel = titleText( {
				title				: settings.title,
				color				: settings.fontColor,
				multiline			: true,			
				fontSize			: settings.fontSize,				
				textLeading	 		: settings.textLeading,				
				borderColor 		: settings.fontBorderColor,			
				borderSize 			: settings.fontBorderSize,	
				
				shadowBorderColor	: settings.shadowBorderColor || settings.fontColor,
				width				: settings.width - 80,
				autoSize			: 'center',
				textAlign			: 'center',
				sharpness 			: 50,
				thickness			: 50,
				border				: true
			})
			
			titleLabel.x = (settings.width - titleLabel.width) * .5 + 5;
			titleLabel.y = 12; //12
			bodyContainer.addChild(titleLabel);
		}
		
		public function drawBttns():void 
		{
			if (settings.hasButtons)
			{
				if(settings.dialog == false){
					OkBttn = new Button( {
						caption:settings.buttonText,
						fontSize:22,
						textAlign:"center",
						autoSize:"center",
						width:170,
						hasDotes:false,
						height:48
					});
					OkBttn.addEventListener(MouseEvent.CLICK, onConfirmBttn);//onOkBttn
				
					bottomContainer.addChild(OkBttn);
					OkBttn.x = settings.width / 2 - OkBttn.width / 2;
					
				}else{
					
					var confirmSettings:Object = {
						caption:settings.confirmText,
						fontSize:32,
						textAlign:"left",
						autoSize:"left",
						width:165,
						hasDotes:false,
						height:48
					}
					
					var cancelSettings:Object = {
						caption:settings.cancelText,
						fontSize:32,
						/*textAlign:"center",
						autoSize:"center",*/
						width:165,
						hasDotes:false,
						height:48
					}
					
					if (settings.hasOwnProperty('confirmSettings'))
						confirmSettings = settings.confirmSettings;
						
					if (settings.hasOwnProperty('cancelSettings'))
						cancelSettings = settings.cancelSettings;
					
					ConfirmBttn = new Button(confirmSettings);
					ConfirmBttn.addEventListener(MouseEvent.CLICK, onConfirmBttn);
					
					CancelBttn = new Button(cancelSettings);
					CancelBttn.addEventListener(MouseEvent.CLICK, onCancelBttn);
					
					ConfirmBttn.x = settings.width / 2 - ConfirmBttn.width - 10;
					CancelBttn.x = settings.width / 2 + 10;
					
					bottomContainer.addChild(ConfirmBttn);
					bottomContainer.addChild(CancelBttn);
				}
			}
			
			bottomContainer.y = settings.height - bottomContainer.height + 15;
			bottomContainer.x = 0;
		}
		
		public function onOkBttn(e:MouseEvent):void {
			if (settings.ok is Function) {
				settings.ok();
			}
			if(settings.closeAfterOk)
				close();
		}
		
		public function onConfirmBttn(e:MouseEvent):void {
			if (settings.confirm is Function) {
				settings.confirm(icon.count);
			}
			close();
		}

		public function onCancelBttn(e:MouseEvent):void {
			if (settings.cancel is Function) {
				settings.cancel();
			}
			close();
		}
		
		override public function dispose():void {
			if(OkBttn != null){
				OkBttn.removeEventListener(MouseEvent.CLICK, onOkBttn);
			}
			if(ConfirmBttn!= null){
				ConfirmBttn.removeEventListener(MouseEvent.CLICK, onConfirmBttn);
			}
			if(CancelBttn != null){
				CancelBttn.removeEventListener(MouseEvent.CLICK, onCancelBttn);
			}
			
			super.dispose();
		}
	}
}



import buttons.Button;
import buttons.PageButton;
import com.flashdynamix.motion.extras.BitmapTiler;
import core.Load;
import flash.display.Bitmap;
import flash.display.Shape;
import flash.events.MouseEvent;
import flash.text.TextField;
import ui.UserInterface;
import wins.Window;
import buttons.ImageButton;
import flash.display.Sprite;

internal class Icon extends Sprite
{
	public var info:Object;
	public var win:*;
	public var bitmap:Bitmap;
	public var title:TextField;
	public var countText:TextField;
	public var stockCountText:TextField;
	public var sID:uint;
	public var ID:*;
	public var uid:String;
	
	private var plus:PageButton;
	private var minus:PageButton;
	private var _counter:Sprite;
	private var stockCountBg:Bitmap;
	
	private var stockCount:uint = 0;
	public var count:uint = 0;
	public var shape:Shape;
	public var sprite:Sprite;
	public var avatar:Bitmap;
	
	private var preloader:Preloader = new Preloader();
	
	public function Icon(window:*)
	{
		win 		= window;
		
		var bgIcon:Bitmap = Window.backing(163, 177, 20, "shopBackingSmall2");
		bgIcon.x = 15;
		bgIcon.y = -3;
		bgIcon.alpha = 0.7;
		addChild(bgIcon);
		
		bitmap = new Bitmap();
		addChild(bitmap);
		
		//title = Window.drawText("", {
				//color:0xffffff,
				//borderColor:0x2b3b64,
				//textAlign:"center",
				//autoSize:"center",
				//fontSize:24,
				//multiline:true
			//});
			
		//title.wordWrap = true;
		//title.width = 150;
			
			
		drawCounter();
		
		//addChild(title);
	}
	
	
	private function drawCounter():void
	{
		_counter = new Sprite();
		plus = new PageButton({caption:'+', height:25});//ImageButton(UserInterface.textures.coinsPlusBttn);
		minus = new PageButton({caption:'-', height:25});//ImageButton(UserInterface.textures.coinsMinusBttn);
		
		plus.addEventListener(MouseEvent.CLICK, onPlus);
		minus.addEventListener(MouseEvent.CLICK, onMinus);
		
		minus.x = -minus.width - 22;
		plus.x = 22;
		minus.y = -30;
		plus.y = -30;
		
		//var countBg:Bitmap = Window.backing(70, 40, 10, "smallBacking");
		var countBg:Sprite = new Sprite();
		countBg.graphics.beginFill(0xc59e5d);
        countBg.graphics.drawCircle(18, 18, 18);
        countBg.graphics.endFill();
		countBg.x =	-countBg.width/2;
		countBg.y = -37;
		
		_counter.visible = false;
		
		countText = Window.drawText("", {
				color:0xffffff,
				fontSize:20,
				borderColor:0x59331c,
				autoSize:"center"
			}
		);
			
		countText.x = countBg.x + (countBg.width + countText.textWidth)/2 - 13;
		countText.y = countBg.y + (countBg.height + countText.textHeight)/2 - 11;
		countText.width = countBg.width - 10;
		
		trace("countBg -= " + countBg.x + "    countText-= " + countText.x);
		
		stockCountBg = new Bitmap(Window.textures.itemNumRoundBakingLight)
		stockCountBg.x = 145;
		stockCountBg.y = -7;
		
		stockCountText = Window.drawText("", {
					color:0xffffff,
					fontSize:24,
					borderColor:0x855729,
					autoSize:"center"
				}
			);	
			
		stockCountText.x = stockCountBg.x + (stockCountBg.width + stockCountText.textWidth) / 2 - 1;
		stockCountText.y = stockCountBg.y + 8;
		
		counter = false;
		
		//if (App.social != 'FB')
		//{
			_counter.addChild(countBg);
			_counter.addChild(plus);
			_counter.addChild(minus);
			_counter.addChild(countText);
			
			addChild(_counter);
		//}	
		
		_counter.x = 100 - 6;
		_counter.y = 200 - _counter.height - 4+3;
		
		
		addChild(stockCountBg);
		addChild(stockCountText);
	}
	
	public function change(data:*):void
	{
		this.ID = data;
		info = App.data.storage[ID];
		//title.text = info.title;
		
		addChild(preloader);
		preloader.x = 100;
		preloader.y = 850;
		
		Load.loading(Config.getIcon(info.type, info.preview), onLoad);
			
			
		stockCount = App.user.stock.data[ID];
		count = 10;
		
		if (stockCount < 10) count = stockCount;
		
		counter = false;
		refreshCounters();
			
		
		
		//title.x = 100 - title.width / 2;
		//title.y = 8;
	}
		
	public function onLoad(data:Bitmap):void
	{
		if(contains(preloader)){
			removeChild(preloader);
		}
		
		bitmap.bitmapData = data.bitmapData;
		bitmap.x = 100 - bitmap.width / 2;
								
		bitmap.y = 65 - bitmap.height / 2;
	}
	
	private function onLoadAvatar(data:Bitmap):void
	{
		if(contains(preloader)){
			removeChild(preloader);
		}
		
		avatar.bitmapData = data.bitmapData;
		avatar.smoothing = true;
		
		avatar.width = 100;
		avatar.height = 100;
	}
	
	private function set counter(value:Boolean):void
	{
		//if (value){
				_counter.visible 		= true;
				stockCountText.visible 	= true;
				stockCountBg.visible 	= true;
		//}else{
				//_counter.visible 		= false;
				//stockCountText.visible 	= false;
				//stockCountBg.visible 	= false;
		//}
	}
	
	public function onPlus(e:MouseEvent = null):void
	{
		if (e.currentTarget.mode == Button.DISABLED) return;
		
		if (stockCount - count - 10 >= 0)
		{
			count		+= 10;
			refreshCounters();
		}else {
			count		+= stockCount - count;
			refreshCounters();
		}
	}
	
	public function onMinus(e:MouseEvent = null):void
	{
		if (e.currentTarget.mode == Button.DISABLED) return;
		
		if (count - 10 >= 0)
		{
			count		-= 10;
			if (count > 0 && count < 10) count = 10;
			refreshCounters();
		}
	}
	
	private function refreshCounters():void
	{
		if (count <= 10) 			minus.state = Button.DISABLED;
		else 						minus.state = Button.NORMAL;
		
		if (count == stockCount) 	plus.state = Button.DISABLED;
		else	 					plus.state = Button.NORMAL;
		
		countText.text 		= String(count);
		stockCountText.text = String(stockCount - count);
		
		if (stockCount - count <= 0 || _counter.visible == false) {
			stockCountText.visible 	= false;
			stockCountBg.visible 	= false;
		}
		else
		{
			stockCountText.visible 	= true;
			stockCountBg.visible 	= true;
		}
		
	}
	
	public function dispose():void
	{
		plus.removeEventListener(MouseEvent.CLICK, onPlus);
		minus.removeEventListener(MouseEvent.CLICK, onMinus);
	}
}