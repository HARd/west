package wins 
{
	import buttons.Button;
	import buttons.ImageButton;
	import buttons.MoneyButton;
	import core.Load;
	import core.Size;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.geom.Matrix;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.AntiAliasType;
	import flash.text.TextFormatAlign;
	import flash.filters.GlowFilter;	
	import ui.Cursor;
	import ui.UserInterface;
	import units.Anime;

	public class SimpleWindow extends Window
	{
		public static const MATERIAL:int = 1;
		public static const ERROR:int = 6;
		public static const COLLECTION:int = 8;
		public static const ATTENTION:int = 9;
		public static const BUILDING:int = 10;
		public static const TREASURE:int = 11;
		public static const CRYSTALS:int = 12;
		public static const DAYLICS:int = 13;
		
		public var OkBttn:Button;
		public var ConfirmBttn:Button;
		public var MoneyBttn:MoneyButton;
		public var CancelBttn:Button;
		
		public var textLabel:TextField = null;
		public var _titleLabel:TextField = null;
		
		private var bitmapLabel:Bitmap = null;
		private var dY:int = 0;
		private var dX:int = 0;
		private var textLabel_dY:int = 0;
		private var titleLabel_dY:int = 0;
		
		public function SimpleWindow(settings:Object = null)
		{
			if (settings == null) {
				settings = new Object();
			}
			//settings['background']      = "";
			settings['hasTitle']		= settings.hasTitle || false;
			settings['title'] 			= settings.title;
			settings["label"] 			= settings.label || null;
			settings['text'] 			= settings.text || '';
			settings['textAlign'] 		= settings.textAlign || 'center';
			settings['autoSize'] 		= settings.autoSize || 'center';
			settings['textSize'] 		= settings.textSize || 28;
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
			settings["height"] 			= settings.height || 300;// 365;
			settings["hasPaginator"] 	= false;
			settings["hasArrows"]		= false;
			settings["fontSize"]		= 38;
			settings["hasPaper"]	 	= true;
			settings["hasTitle"]		= true;
			settings["hasExit"]			= settings.hasExit || false;
			settings["fontColor"]       = 0xffffff//0xf5cf57;
			settings["hasExit"]         = true;
			settings["bitmap"]	 		= settings.bitmap || null;
			settings["background"]	 	= 'alertBacking';
			settings["sid"]	 			= settings.sid || null;
			settings["showCoin"]	 	= settings.showCoin || false;
			settings["showBucks"]	 	= settings.showBucks || false;
			settings["moneyButton"]	 	= settings.moneyButton || false;
			
			settings['shadowColor'] = 0x513f35;
			settings['shadowSize'] = 4;
		
			if (!settings.hasOwnProperty("closeAfterOk"))
			{
				settings["closeAfterOk"] = true;
			}
			
			if (App.user.worldID == Travel.SAN_MANSANO) {
				settings['background'] = 'goldBacking';
			}
			
			textLabel_dY = 0;
			
			super(settings);
		}
		
		override public function drawExit():void {
			//
		}
		
		override public function drawBody():void {		
			if (settings.isImg) {
				var robotIcom:Bitmap = new Bitmap(UserInterface.textures.errorPic);
				robotIcom.x = 0;
				robotIcom.y = 30;
				bodyContainer.addChild(robotIcom);
			}
			
			if (settings.bitmap && App.data.storage[settings.sid].type != 'Golden') {
				var imgCont:Sprite = new Sprite();
				imgCont.x = 65;
				imgCont.y = 65;
				
				var img:Bitmap = new Bitmap(settings.bitmap.bitmapData);
				Size.size(img, 150, 150);
				img.smoothing = true;
				
				imgCont.addChild(img);
				
				img.x = (150-img.width) / 2;
				img.y = (150-img.height) / 2;
				
				bodyContainer.addChild(imgCont);
			}
			
			drawBttns();
			
			var textFontSize:int;
			if (settings.title != null)
			{
				textFontSize = settings.textSize;
			} else {
				textFontSize = settings.textSize + 8;
			}
			
			var textSettings:Object = {
				color:0x552703,
				borderSize:3,
				borderColor:0xFFFFFF,
				textLeading:2,
				fontSize:textFontSize,
				textAlign:settings.textAlign,
				autoSize:settings.autoSize,
				multiline:true
			};
			
			var textSettings2:Object = {
				color:0x552d09,
				border:false,
				textLeading:3,
				fontSize:textFontSize,
				textAlign:settings.textAlign,
				autoSize:settings.autoSize,
				multiline:true
			};
			
			var textSettingsError:Object = {
				size:30,
				color:0x532903,
				border:false,
				textLeading:3,
				fontSize:textFontSize,
				textAlign:settings.textAlign,
				autoSize:settings.autoSize,
				multiline:true
			};
			
			if (settings.sid && App.data.storage[settings.sid].type == 'Golden')
			{
				Load.loading(Config.getSwf(App.data.storage[settings.sid].type, App.data.storage[settings.sid].view), onAnimComplete);
				textLabel = Window.drawText(settings.text, textSettings2);
				textLabel.wordWrap = true;
				textLabel.mouseEnabled = false;
				textLabel.mouseWheelEnabled = false;
				textLabel.width = 230;
				textLabel.height = textLabel.textHeight + 4;
				textLabel.x = background.x + (background.width - textLabel.width) / 2 + 75;
				textLabel.y = background.y + (background.height - textLabel.height) / 2 - 15;
			} else if (settings.bitmap) {
				textLabel = Window.drawText(settings.text, textSettings2);
				textLabel.wordWrap = true;
				textLabel.mouseEnabled = false;
				textLabel.mouseWheelEnabled = false;
				textLabel.width = 230;
				textLabel.height = textLabel.textHeight + 4;
				textLabel.x = background.x + (background.width - textLabel.width) / 2 + 75;
				textLabel.y = background.y + (background.height - textLabel.height) / 2 - 15;
			} else if (settings.isImg) {
				textLabel = Window.drawText(settings.text, textSettingsError);
				textLabel.wordWrap = true;
				textLabel.mouseEnabled = false;
				textLabel.mouseWheelEnabled = false;
				textLabel.width = 230;
				textLabel.height = textLabel.textHeight + 4;
				textLabel.x = background.x + (background.width - textLabel.width) / 2 + 75;
				textLabel.y = background.y + (background.height - textLabel.height) / 2 - 15;
			} else {
				textLabel = Window.drawText(settings.text, textSettings);
				textLabel.wordWrap = true;
				textLabel.mouseEnabled = false;
				textLabel.mouseWheelEnabled = false;
				textLabel.width = settings.width - 100;
				textLabel.height = textLabel.textHeight + 4;
				textLabel.x = background.x + (background.width - textLabel.width) / 2;
				textLabel.y = background.y + (background.height - textLabel.height) / 2 - 5;
			}
			bodyContainer.addChild(textLabel);
			
			if (settings.isImg) {
				textLabel.x = background.x + (background.width - textLabel.width) / 2 + 75;
			}
			
			if (settings.showCoin) {
				textLabel.y += 20;
				
				var coin:Bitmap = new Bitmap();
				bodyContainer.addChild(coin);
				
				Load.loading(Config.getIcon(App.data.storage[RouletteWindow.CURRENCY].type, App.data.storage[RouletteWindow.CURRENCY].preview), function(data:*):void {
					coin.bitmapData = data.bitmapData;
					coin.smoothing = true;
					Size.size(coin, 70, 70);
					coin.x = (settings.width - coin.width) / 2;
					coin.y = 45;
				});
			}
			
			if (settings.showBucks) {
				textLabel.y += 20;
				
				var bucks:Bitmap = new Bitmap();
				bodyContainer.addChild(bucks);
				
				Load.loading(Config.getIcon(App.data.storage[Stock.FANT].type, App.data.storage[Stock.FANT].preview), function(data:*):void {
					bucks.bitmapData = data.bitmapData;
					bucks.smoothing = true;
					Size.size(bucks, 70, 70);
					bucks.x = (settings.width - bucks.width) / 2;
					bucks.y = 45;
				});
			}
			
			var exit:ImageButton = new ImageButton(textures.closeBttn);
			exit.x = background.x + background.width - 70;
			exit.y = background.y - 5;
			bodyContainer.addChild(exit);
			exit.addEventListener(MouseEvent.CLICK, close)
			
			if (settings.title != null) {
				//drawMirrowObjs('diamondsTop', settings.width / 2 - settings.titleWidth / 2 - 5, settings.width / 2 + settings.titleWidth / 2 + 5, settings.titleHeight/2 + titleLabel.y + 2, true, true, true);
			}
			
			if (settings.hasOwnProperty('timer')) {
				drawTimer();
			}
			
			if (settings.hasOwnProperty('showBonus') && settings.showBonus == true) {
				var extra:ExtraItem = new ExtraItem();
				extra.x = settings.width - extra.width + 30;
				extra.y = settings.height - extra.height;
				bodyContainer.addChild(extra);
			}
		}
		
		private function onAnimComplete(swf:*):void 
		{
			var anime:Anime = new Anime(swf, { w:background.width - 20, h:background.height - 40 } );
			if (settings.sid == 750) anime.scaleX = anime.scaleY = 0.5;
			anime.x = (250-anime.width) / 2;
			anime.y = (background.height - anime.height) / 2;
			bodyContainer.addChild(anime);
		}
		
		private var timer:TextField
		private function drawTimer():void 
		{
			textLabel.y -= 20;
			timer = Window.drawText(TimeConverter.timeToStr(settings.timer), {
				color:0xffffff,
				letterSpacing:3,
				textAlign:"center",
				fontSize:35,
				borderColor:0x502f06
			});
			timer.width = settings.width - 60;
			timer.x = 30;
			timer.y = textLabel.y + textLabel.height + 10;
			
			var glowing:Bitmap = new Bitmap(Window.textures.actionGlow);
			glowing.alpha = 0.8;
			
			bodyContainer.addChildAt(glowing,0);
			glowing.x = (settings.width - glowing.width) / 2;
			glowing.y = timer.y + (timer.textHeight - glowing.height) / 2 - 25;
			
			bodyContainer.addChild(timer);
			
			App.self.setOnTimer(update);
		}
		
		private function update():void {
			settings.timer --;
			timer.text = TimeConverter.timeToStr(settings.timer);
		}
		
		override public function drawTitle():void 
		{
			titleLabel = titleText( {
				title				: settings.title,
				color				: settings.fontColor,
				multiline			: true,			
				fontSize			: 44,				
				textLeading	 		: settings.textLeading,				
				borderColor 		: settings.fontBorderColor,
				borderSize 			: settings.fontBorderSize,	
				width				: settings.width - 80,
				textAlign			: 'center',
				sharpness 			: 50,
				thickness			: 50,
				border				: true,
				//shadowBorderColor	: 0x4f3f32,
				shadowColor			: 0x513f31,
				shadowSize			:4
			});
			
			titleLabel.x = (settings.width - titleLabel.width) * .5;
			titleLabel.y = - 7;
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
						width:160,
						height:45,
						hasDotes:false,
						height:45
					});
					OkBttn.addEventListener(MouseEvent.CLICK, onConfirmBttn);//onOkBttn
				
					OkBttn.x = settings.width / 2 - OkBttn.width / 2 + 15;
					if (!settings.bitmap)
						OkBttn.y = 25;
					bottomContainer.addChild(OkBttn);
				}else{
					
					var confirmSettings:Object = {
						caption:settings.confirmText,
						width:140,
						hasDotes:false,
						height:45
					}
					
					var cancelSettings:Object = {
						caption:settings.cancelText,
						width:140,
						hasDotes:false,
						height:45
					}
					
					if (settings.hasOwnProperty('confirmSettings'))
						confirmSettings = settings.confirmSettings;
						
					if (settings.hasOwnProperty('cancelSettings'))
						cancelSettings = settings.cancelSettings;
					
					if (settings.moneyButton) {
						confirmSettings['countText'] = settings.moneyCount;
						confirmSettings['width'] = 160;
						MoneyBttn = new MoneyButton(confirmSettings);
						MoneyBttn.addEventListener(MouseEvent.CLICK, onConfirmBttn);
						MoneyBttn.x = settings.width / 2 - MoneyBttn.width/* + 4*/-4;
						bottomContainer.addChild(MoneyBttn);
					}else {
						ConfirmBttn = new Button(confirmSettings);
						ConfirmBttn.addEventListener(MouseEvent.CLICK, onConfirmBttn);
						ConfirmBttn.x = settings.width / 2 - ConfirmBttn.width/* + 4*/-4;
						bottomContainer.addChild(ConfirmBttn);
					}
					
					CancelBttn = new Button(cancelSettings);
					CancelBttn.addEventListener(MouseEvent.CLICK, onCancelBttn);
					
					CancelBttn.x = settings.width / 2/* - 4*/+4;
					bottomContainer.addChild(CancelBttn);
				}
			}
			
			bottomContainer.y = settings.height - bottomContainer.height - 36;
			bottomContainer.x = 0;
			
			if (settings.bitmap || settings.sid) {
				bottomContainer.y = settings.height - bottomContainer.height - 10;
			}
		}
		
		public function onOkBttn(e:MouseEvent):void {
			if (settings.ok is Function) {
				settings.ok();
			}
			if(settings.closeAfterOk)
				close();
		}
		
		private var pressTimes:int = 0;
		public function onConfirmBttn(e:MouseEvent):void {
			pressTimes ++;
			
			if (pressTimes <= 1 && (settings.confirm is Function)) {
				settings.confirm();
			}
			
			close();
		}

		public function onCancelBttn(e:MouseEvent):void {
			if (settings.cancel is Function) {
				settings.cancel();
			}
			close();
		}
		
		override public function close(e:MouseEvent = null):void {
			super.close();
			
			if (settings.hasOwnProperty('needCancelAfterClose') && settings.needCancelAfterClose == true) {
				if (settings.cancel is Function) {
					settings.cancel();
				}
			}
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
			
			App.self.setOffTimer(update);
			super.dispose();
		}
	}
}

import flash.display.Bitmap;
import flash.display.Sprite;
import flash.text.TextField;
import wins.Window;
import wins.RewardList;

internal class ExtraItem extends Sprite {
	
	public var extra:Object;
	public var bg:Bitmap;
	
	public function ExtraItem() {
		if (!App.data.options.hasOwnProperty('friendalertBonus') || App.user.quests.tutorial) return;
		
		extra = JSON.parse(App.data.options.friendalertBonus);
		
		bg = Window.backing(164, 85, 38, "shareBonusBacking");
		addChild(bg);
		drawTitle();
		drawReward();
	}
	
	private function drawTitle():void {
		var title:TextField = Window.drawText(Locale.__e("flash:1449655508990"), {
			fontSize	:17,
			color		:0x673a1f,
			borderColor	:0xffffff,
			textAlign   :'center',
			multiline   :true,
			wrap        :true
		});
		title.width = bg.width - 10;
		title.x = 5
		title.y = 6;
		addChild(title);
	}
	
	private function drawReward():void {
		var reward:RewardList = new RewardList(extra, false, 0, '', 1, 30, 16, 32, "x", 0.5, -8, 7, false, true);
		addChild(reward);
		reward.x = -10;
		reward.y = bg.height - reward.height - 10;
	}
	
	public function get newsBonus():Object {
		return extra;
	}
}