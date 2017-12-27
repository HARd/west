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
	
	public class SelectRewardWindow extends Window {
		
		public var items:Array = new Array();
		public var bitmap:Bitmap;
		public var image:BitmapData;
		private var myBackground:Bitmap;
		
		public function SelectRewardWindow(settings:Object = null) {
			if (settings == null) {
				settings = new Object();
			}		
			
			settings["bonus"] = settings.bonus || {3:100, 5:200, 2:300};
			
			settings['width'] = 550;
			settings['height'] = 380;
			settings['title'] = settings.title || Locale.__e("flash:1404394075014");
			settings['hasPaginator'] = false;
			settings['hasExit'] = false;
			
			super(settings);
		}
		
		override public function drawBackground():void {
			myBackground = Window.backing(settings.width, settings.height, 30, "alertBacking");
			layer.addChild(myBackground);
			
			//bg = Window.backing(settings.width, settings.height, 20, 'dialogueBacking');
			//bg.x = myBackground.x + (myBackground.width - bg.width) / 2;
			//bg.y = 35;
		}
		
		override public function drawTitle():void {
			titleLabel = titleText( {
				title				: settings.title,
				color				: 0xffffff,
				multiline			: settings.multiline,			
				fontSize			: 46,
				textLeading	 		: settings.textLeading,	
				border				: true,
				borderColor 		: 0xc4964e,			
				borderSize 			: 4,	
				shadowColor			: 0x503f33,
				shadowSize			: 4,
				width				: settings.width - 140,
				textAlign			: 'center',
				sharpness 			: 50,
				thickness			: 50
			});
			titleLabel.x = (settings.width - titleLabel.width) / 2;
			titleLabel.y = 0;
			titleLabel.mouseChildren = titleLabel.mouseEnabled = false;
			headerContainer.addChild(titleLabel);
			headerContainer.mouseEnabled = false;
		}
		
		public var rewardSprite:Sprite;
		override public function drawBody():void {
			var descText:TextField = drawText(Locale.__e("flash:1480003657125"),{
				color				:0x542d0a,
				borderColor			:0xf8e6d2,
				multiline			: true,
				fontSize			: 26,
				autoSize			: "center"
			});
			descText.x = myBackground.x + (myBackground.width - descText.textWidth) / 2;
			descText.y = 30;
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
			for (var sID:* in settings.bonus){
				var item:SelectRewardItem = new SelectRewardItem(this, settings.bonus[sID], {fontSize:26, widthTxt:100, titlefontSize:24, titleColor:0xffffff, titleBorderColor:0x814f31, titleShadowColor:0x814f31, shadowColor:0x754108}, true, settings.callback);
				item.x = itemNum * (item.width + 30) ;
				itemNum++;
				rewardSprite.addChild(item);
			}
			rewardSprite.x = myBackground.x + (myBackground.width - settings.width) / 2 + (settings.width - rewardSprite.width) / 2 + 5;
			rewardSprite.y = 120;
			bodyContainer.addChild(rewardSprite);
		}
		
		override public function drawExit():void {
			var exit:ImageButton = new ImageButton(textures.closeBttn);
			headerContainer.addChild(exit);
			exit.x = settings.width - 20;
			exit.y = -5;
			exit.addEventListener(MouseEvent.CLICK, close);
		}
		
		public function take():void {
			var childs:int = rewardSprite.numChildren;
			
			while(childs--) {
				var reward:SelectRewardItem = rewardSprite.getChildAt(childs) as SelectRewardItem;
				
				//App.user.stock.add(reward.sID, reward.count);
				
				if (reward.sID == 5 && App.user.mode == User.GUEST) continue;
				var item:BonusItem = new BonusItem(reward.sID, reward.count);					
				var point:Point = Window.localToGlobal(reward);
				item.cashMove(point, App.self.windowContainer);
				
				
			}
		}
		
		private function onOkBttn(e:MouseEvent):void {
			take();
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

internal class SelectRewardItem extends Sprite 
{
	public var bitmap:Bitmap
	public var countLabel:TextField;
	public var title:TextField;
	public var count:int;
	public var sID:int;
	public var treasure:*;
	
	private var iconCont:LayerX = new LayerX();
	private var okBttn:Button;
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
	
	public function SelectRewardItem(window:*, sID:*, settings:Object = null, hasCircleBg:Boolean = false, callback:Function = null)
	{
		this.treasure = sID;
		this.callback = callback;
		this.window = window;
		var treasure:Object = App.data.treasures[sID][sID];
		for (var index:* in treasure.item)
		{
			if (App.data.storage[treasure.item[index]].type == "Walkgolden")
			{
				this.sID = treasure.item[index];
				count = treasure.count[index];
				break;
			}
			this.sID = treasure.item[index];
			count = treasure.count[index];
		}
		
		if (settings != null) {
			for (var obj:* in settings) {
				if(settings[obj] != null)
					this.settings[obj] = settings[obj];
			}
		}
		
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
		
		iconCont.tip = function():Object {
			return {
				title:App.data.storage[this.sID].title,
				text:App.data.storage[this.sID].description
			}
		} 
		
		drawCount();
		drawTakeBtn();
		title = Window.drawText(item.title, {
			color:settings.titleColor || 0x804926,
			borderColor:settings.titleBorderColor || 0xffffff,
			borderSize:2,
			textAlign:"center",
			fontSize:settings.titlefontSize || 24,
			multiline:true,
			shadowColor:settings.titleShadowColor || 0xf8e6d2,
			shadowSize:2
			//word:true,
			//width:widthTxt
		});
		title.wordWrap = true;
		title.width = this.settings.widthTxt;
		title.height = title.textHeight + 5;
		title.y = -20;
		title.x = 5;
		//title.border = true;
		addChild(title);
	}
	
	private function drawTakeBtn():void
	{
		okBttn = new Button( {
				caption:Locale.__e('flash:1382952379978'),
				fontSize:28,
				width:140,
				height:50
			});
		okBttn.x = 0 + (110 - okBttn.width) / 2;
		okBttn.y = 120;
		okBttn.addEventListener(MouseEvent.CLICK, okClick);
		addChild(okBttn);
	}
	
	private function okClick(e:MouseEvent):void
	{
		callback(treasure);
		window.close();
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
		bg.x = (110 - bg.width)/2;
		bg.y = 120 - 30;
	}
	
	
	private function onLoad(data:*):void{
		bitmap.bitmapData = data.bitmapData;
		bitmap.smoothing = true
		bitmap.scaleX = bitmap.scaleY = 0.9;
		
		iconCont.x = (110 - bitmap.width) / 2;
		iconCont.y = (110 - bitmap.height) / 2 + 5;
	}
}