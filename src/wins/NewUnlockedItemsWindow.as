package wins {
	
	import buttons.Button;
	import buttons.ImageButton;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.text.TextField;
	import ui.UserInterface;
	
	public class NewUnlockedItemsWindow extends Window {
		
		public var items:Array = new Array();
		public var bitmap:Bitmap;
		public var image:BitmapData;
		private var myBackground:Bitmap;
		private var bg:Bitmap;
		public var okBttn:Button;
		
		public function NewUnlockedItemsWindow(settings:Object = null) {
			if (settings == null) {
				settings = new Object();
			}		
			//settings["bonus"] = settings.bonus || [];
			settings["bonus"] = settings.bonus || {3:100, 5:200, 2:300};
			
			settings['width'] = 550;
			settings['height'] = 380;
			settings['title'] = settings.title || Locale.__e("flash:1480327379978");
			settings['hasPaginator'] = false;
			settings['hasExit'] = false;
			
			super(settings);
		}
		
		override public function drawBackground():void {
			myBackground = Window.backing(settings.width, settings.height, 30, "alertBacking");
			layer.addChild(myBackground);
			
			bg = Window.backing(settings.width, settings.height, 20, 'dialogueBacking');
			bg.x = myBackground.x + (myBackground.width - bg.width) / 2;
			bg.y = 35;
			//layer.addChild(bg);
		}
		
		override public function drawTitle():void {
			titleLabel = titleText( {
				title				: settings.title,
				color				: settings.fontColor,
				multiline			: true,			
				fontSize			: settings.fontSize,				
				textLeading	 		: settings.textLeading,				
				borderColor 		: 0xc09a53,			
				borderSize 			: settings.fontBorderSize,	
				
				shadowBorderColor	: 0x503e32,
				shadowSize			: 2,
				width				: settings.width - 60,
				textAlign			: 'center',
				sharpness 			: 50,
				thickness			: 50,
				border				: true
			});
			titleLabel.x = (settings.width - titleLabel.width) * .5;
			titleLabel.y = -16;
			
			titleContainer.addChild(titleLabel);
			titleContainer.mouseEnabled = false;
			titleContainer.mouseChildren = false;
			//titleLabel.visible = false;
		}
		
		public var rewardSprite:Sprite;
		override public function drawBody():void {
			var descText:TextField = drawText(Locale.__e("flash:1480327240827"),{
				color				:0x542d0a,
				borderColor			:0xf8e6d2,
				multiline			: true,
				fontSize			: 26,
				autoSize			: "center"
			});
			descText.x = myBackground.x + (myBackground.width - descText.textWidth) / 2;
			descText.y = bg.y + descText.height;
			bodyContainer.addChild(descText);
			
			var up_devider:Bitmap = new Bitmap(Window.textures.dividerLine);
			up_devider.x = 85;
			up_devider.y = descText.y + descText.height + 5;
			up_devider.width = settings.width - 170;
			up_devider.alpha = 0.3;
			//bodyContainer.addChild(up_devider);
			
			var down_devider:Bitmap = new Bitmap(Window.textures.dividerLine);
			down_devider.x = up_devider.x;
			down_devider.width = up_devider.width;
			down_devider.y = up_devider.y + 165;
			down_devider.alpha = 0.3;
			//bodyContainer.addChild(down_devider);
			
			rewardSprite = new Sprite();
			var itemNum:int = 0;
			for (var index:* in settings.bonus){
				var item:NewUnlockedItem = new NewUnlockedItem(this, settings.bonus[index], {fontSize:26, widthTxt:100, titlefontSize:24, titleColor:0xffffff, titleBorderColor:0x814f31, titleShadowColor:0x814f31, shadowColor:0x754108}, true, settings.callback);
				item.x = itemNum * (item.width + 30) ;
				itemNum++;
				rewardSprite.addChild(item);
			}
			rewardSprite.x = bg.x + (bg.width - rewardSprite.width) / 2 + 5;
			rewardSprite.y = 150;
			bodyContainer.addChild(rewardSprite);
			
			okBttn = new Button( {
				caption:Locale.__e('flash:1404394519330'),
				fontSize:28,
				width:170,
				height:50
			});
			okBttn.name = 'RewardWindow_okBttn';
			okBttn.x = myBackground.x + (myBackground.width - okBttn.width) / 2;
			okBttn.y = myBackground.height - okBttn.height;
			bottomContainer.addChild(okBttn);
			okBttn.addEventListener(MouseEvent.CLICK, onOkBttn);
		}
		
		override public function drawExit():void {
			var exit:ImageButton = new ImageButton(textures.closeBttn);
			headerContainer.addChild(exit);
			exit.x = settings.width - 20;
			exit.y = -5;
			exit.addEventListener(MouseEvent.CLICK, close);
		}
		
		private function onOkBttn(e:MouseEvent):void {
			close();
		}
		
		override public function dispose():void {
			super.dispose();
		}
	}
}

import buttons.Button;
import core.Load;
import flash.display.Bitmap;
import flash.display.Shape;
import flash.display.Sprite;
import flash.text.TextField;
import wins.Window;
import flash.events.MouseEvent;

internal class NewUnlockedItem extends Sprite 
{
	public var background:Bitmap
	public var bitmap:Bitmap
	public var countLabel:TextField;
	public var title:TextField;
	public var count:int;
	public var sID:int;
	public var treasure:*;
	
	private var iconCont:LayerX = new LayerX();
	private var callback:Function;
	
	private var settings:Object = {
		fontSize : 22,
		widthTxt : 100,
		shadowColor:0x754108,
		titlefontSize:24,
		titleColor:0x6d4b15,
		titleBorderColor:0xfcf6e4,
		titleShadowColor:0x814f31,
		borderSize:1
	};
	
	private var circle:Shape;
	private var window:Window;
	
	public function NewUnlockedItem(window:*, sID:*, settings:Object = null, hasCircleBg:Boolean = false, callback:Function = null)
	{
		this.sID = sID;
		this.callback = callback;
		this.window = window;
		
		if (settings != null) {
			for (var obj:* in settings) {
				if(settings[obj] != null)
					this.settings[obj] = settings[obj];
			}
		}
		
		
		
		background = Window.backing(110, 120, 10, "textBacking");
		//addChild(background);
		
		if (hasCircleBg) {
			circle = new Shape();
			circle.graphics.beginFill(0xc8cabc, 1);
			circle.graphics.drawCircle(55, 60, 60);
			circle.graphics.endFill();
			addChild(circle);
		}
		
		bitmap = new Bitmap(null, "auto", true);
		
		var item:Object = App.data.storage[this.sID];
		Load.loading(Config.getIcon(item.type, item.preview), onLoad);
	
		addChild(iconCont);
		
		iconCont.addChild(bitmap);
		
		//iconCont.tip = function():Object {
			//return {
				//title:App.data.storage[this.sID].title,
				//text:App.data.storage[this.sID].description
			//}
		//} 
		
		drawCount();
		
		title = Window.drawText(item.title, {
			color:settings.titleColor || 0x804926,
			borderColor:settings.titleBorderColor || 0xffffff,
			borderSize:2,
			textAlign:"center",
			fontSize:settings.titlefontSize || 24,
			multiline:true,
			wrap:true,
			autoSize:"center",
			shadowColor:settings.titleShadowColor || 0xf8e6d2,
			shadowSize:2
			//word:true,
			//width:widthTxt
		});
		//title.wordWrap = true;
		
		title.y = -20;
		title.x = (settings.width - title.width) / 2;
		//title.border = true;
		addChild(title);
	}
	
	public function drawCount():void {
		
		countLabel = Window.drawText(String(count), {
			fontSize		:settings.fontSize || 32,
			color			:0xffffff,
			borderColor		:0x774702,
			borderSize:2,
			autoSize:"center",
			shadowColor:settings.shadowColor || 0xf8e6d2,
			shadowSize:2
		});
		
		
		var width:int = countLabel.width + 24 > 30?countLabel.width + 24:30;
		var bg:Bitmap = Window.backing(width, 40, 10, "smallBacking");
		
		//addChild(bg);
		bg.x = (background.width - bg.width)/2;
		bg.y = background.height - 30;
		
		//addChild(countLabel);
		countLabel.x = bg.x + (bg.width - countLabel.width) / 2;
		countLabel.y = bg.y - countLabel.height / 2;
	}
	
	
	private function onLoad(data:*):void{
		bitmap.bitmapData = data.bitmapData;
		bitmap.smoothing = true
		bitmap.scaleX = bitmap.scaleY = 0.9;
		
		//bitmap.x = (background.width - bitmap.width) / 2;
		//bitmap.y = (background.width - bitmap.height) / 2 + 5;
		
		iconCont.x = (background.width - bitmap.width) / 2;
		iconCont.y = (background.width - bitmap.height) / 2 + 5;
	}
}