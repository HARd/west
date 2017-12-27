package wins 
{
	import buttons.Button;
	import flash.display.Bitmap;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	public class TopRewardWindow extends Window 
	{
		private var rewards:Array = [
			{desc:Locale.__e('flash:1450197853736'), sid1:1290, sid2:1306, place:'1'},
			{desc:Locale.__e('flash:1450254673894'), sid1:1290, sid2:1305, place:'2-10'},
			{desc:Locale.__e('flash:1450254694053'), sid1:1289, sid2:1304, place:'11-50'},
			{desc:Locale.__e('flash:1450254707452'), sid1:1289, sid2:1303, place:'51-100'}
		];
		private var rewards3:Array = [
			{desc:Locale.__e('flash:1452604384319'), sid1:1417, sid2:1420, place:'1'},
			{desc:Locale.__e('flash:1452604424563'), sid1:1417, sid2:1421, place:'2-10'},
			{desc:Locale.__e('flash:1452604473440'), sid1:1419, sid2:1422, place:'11-50'},
			{desc:Locale.__e('flash:1452604492922'), sid1:1419, sid2:1423, place:'51-100'},
			{desc:Locale.__e('flash:1452604510159'), sid1:Stock.FANT, sid2:Stock.FANT, place:''}
		];
		private var rewardsLoc:Array = [];
		public function TopRewardWindow(settings:Object=null) 
		{
			if (settings == null) {
				settings = new Object();
			}
			
			settings['background'] 		= 'winterBacking';
			settings['width'] 			= 730;
			settings['height'] 			= 485;
			settings['title'] 			= Locale.__e('flash:1382952380254');
			settings['hasPaginator'] 	= false;
			settings['hasExit'] 		= false;
			settings['hasTitle'] 		= true;
			settings['faderClickable'] 	= true;
			settings['popup'] 			= true;
			settings['topID'] 			= settings.topID || 1;
			
			if (settings.topID == 3)
				settings.background = 'alertBacking';
			
			if (settings.topID == 3) rewardsLoc = rewards3;
			else rewardsLoc = rewards;
			
			settings['height'] = 50 + 92 * (rewardsLoc.length + 1);
			
			super(settings);
		}
		
		override public function drawBody():void {
			var placePrms:Object = {
				color			:0x5a2e09,
				border			:false,
				width			:280,
				multiline		:true,
				wrap			:true,
				textAlign		:'center',
				fontSize		:28
			};
			var placeLabel:TextField = Window.drawText(Locale.__e('flash:1450254945739'), placePrms);
			placeLabel.x = -25;
			placeLabel.y = 40;
			bodyContainer.addChild(placeLabel);
			
			var rewardsLoc:Array = [];
			if (settings.topID == 3) {
				rewardsLoc = rewards3;
			} else {
				rewardsLoc = rewards;
			}
			for (var i:int = 1; i <= rewardsLoc.length; i++) {
				var topItem:TopRewardItem = new TopRewardItem(rewardsLoc[i-1].desc, rewardsLoc[i-1].sid1, rewardsLoc[i-1].sid2, rewardsLoc[i-1].place);
				topItem.x = 53;
				topItem.y = 50 + (i - 1) * (topItem.background.height + 5);
				bodyContainer.addChild(topItem);
				
				if (i != rewardsLoc.length) {
					var up_devider:Bitmap = new Bitmap(Window.textures.dividerLine);
					up_devider.x = 53 + 30;
					up_devider.y = topItem.y + topItem.background.height;
					up_devider.width = topItem.background.width - 100;
					up_devider.alpha = 0.6;
					bodyContainer.addChild(up_devider);
				}
			}
			
			var bttn:Button = new Button( {  width:194, height:53, caption:Locale.__e('flash:1382952380298') } );
			bodyContainer.addChild(bttn);
			bttn.x = (settings.width - bttn.width) / 2;
			bttn.y = background.height - bttn.height;
			bttn.addEventListener(MouseEvent.CLICK, onClick);
		}
		
		public function onClick(e:MouseEvent):void {
			if (settings.callback) settings.callback();
			close();
		}
		
	}

}

import buttons.ImageButton;
import core.Load;
import core.Size;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.text.TextField;
import ui.UserInterface;
import wins.InfoWindow;
import wins.GambleWindow;
import wins.Window;

internal class TopRewardItem extends Sprite {
	
	public var background:Shape = new Shape();
	public var iconBitmap:Bitmap = new Bitmap();
	public var iconSecondBitmap:Bitmap = new Bitmap();
	public var light:Bitmap;
	public var descriptionLabel:TextField;
	public var descText:String;
	public var sID1:int;
	public var sID2:int;
	
	public function TopRewardItem(descText:String, sID1:int, sID2:int, place:String):void {		
		this.descText = descText;
		this.sID1 = sID1;
		this.sID2 = sID2;
		background.graphics.beginFill(0xffffff, 0);
		background.graphics.drawRect(0, 0, 630, 92);
		background.graphics.endFill();
		addChild(background);
		
		drawCircles();
		
		light = new Bitmap(Window.texture('glow'));
		light.scaleX = light.scaleY = 0.3;
		light.x = circle.x - circle.width / 2 - light.width;
		light.y = -10;
		addChild(light);
		
		var cloud:Bitmap = new Bitmap(UserInterface.textures.saleLabelBank);
		cloud.scaleX = cloud.scaleY = 0.8;
		cloud.x = 10;
		cloud.y = (background.height - cloud.height) / 2 + 5;
		addChild(cloud);
		
		var placePrms:Object = {
			color			:0xffffff,
			borderColor		:0x5a2e09,
			width			:cloud.width,
			multiline		:true,
			wrap			:true,
			textAlign		:'left',
			fontSize		:30
		};
		var placeLabel:TextField = Window.drawText(place, placePrms);
		placeLabel.x = cloud.x + (cloud.width - placeLabel.textWidth) / 2;
		placeLabel.y = cloud.y + (cloud.height - placeLabel.textHeight) / 2;
		addChild(placeLabel);
		
		addChild(iconBitmap);
		addChild(iconSecondBitmap);
		drawDescription();
		
		if (sID2 == sID1) {
			light.visible = false;
			cloud.visible = false;
			Load.loading(Config.getIcon(App.data.storage[sID1].type, App.data.storage[sID1].view), onLoad);
			
			if (sID2 == Stock.FANT) {
				Load.loading(Config.getIcon(App.data.storage[Stock.ACTION].type, App.data.storage[Stock.ACTION].view), onLoadAction);
			}
		} else {
			Load.loading(Config.getIcon(App.data.storage[sID1].type, App.data.storage[sID1].view), onLoad);
			Load.loading(Config.getIcon(App.data.storage[sID2].type, App.data.storage[sID2].view), onLoadSecond);
		}
	}
	
	private var circle:Shape;
	public function drawCircles():void {
		circle = new Shape();
		circle.graphics.beginFill(0xb1c0b9, 1);
		circle.graphics.drawCircle(0, 0, 46);
		circle.graphics.endFill();
		circle.x = background.width - 70;
		circle.y = background.height / 2;
		addChild(circle);
	}
	
	public function drawDescription():void {
		var numPrms:Object = {
				color			:0xf7ffe8,
				borderColor		:0xb77e24,
				shadowColor		:0x50413e,
				shadowSize		:4,
				multiline		:true,
				wrap			:true,
				textAlign		:'center',
				fontSize		:70
		};
		var numberLabel:TextField = Window.drawText('', numPrms);
		numberLabel.width = numberLabel.textWidth + 5;
		numberLabel.x = 30;
		numberLabel.y = (background.height - numberLabel.textHeight) / 2;
		addChild(numberLabel);
		
		var textSize:int = 26;
		do {
			var descPrms:Object = {
					color			:0x5a2e09,
					border			:false,
					width			:280,
					multiline		:true,
					wrap			:true,
					textAlign		:'left',
					fontSize		:textSize
			};
			descriptionLabel = Window.drawText(descText, descPrms);
			descriptionLabel.x = 130;
			descriptionLabel.y = (background.height - descriptionLabel.height) / 2 + 2;
			textSize--;
		}while (descriptionLabel.height >= 85)
		addChild(descriptionLabel);
	}
	
	private var sprite:LayerX = new LayerX();
	public function onLoad(data:Bitmap):void {
		addChild(sprite);
		
		iconBitmap.bitmapData = data.bitmapData;
		Size.size(iconBitmap, 80, 80);
		iconBitmap.smoothing = true;
		
		sprite.x = circle.x - iconBitmap.width / 2;
		sprite.y = circle.y - iconBitmap.height / 2;
		
		sprite.tip = function():Object { 
			return {
				title:App.data.storage[sID1].title,
				text:App.data.storage[sID1].description
			};
		};
		
		sprite.addChild(iconBitmap);
		
		if (sID1 == Stock.FANT) {
			var actionPrms:Object = {
				color			:0xffffff,
				borderColor		:0x5a2e09,
				width			:iconBitmap.width,
				multiline		:true,
				wrap			:true,
				textAlign		:'left',
				fontSize		:30
			};
			var actionLabel:TextField = Window.drawText('x10', actionPrms);
			actionLabel.x = iconBitmap.x + iconBitmap.width - actionLabel.textWidth + 10;
			actionLabel.y = iconBitmap.y + iconBitmap.height - actionLabel.textHeight;
			sprite.addChild(actionLabel);
		}
	}
	
	private var spriteSecond:LayerX = new LayerX();
	public function onLoadSecond(data:Bitmap):void {
		addChild(spriteSecond);
		
		iconSecondBitmap.bitmapData = data.bitmapData;
		Size.size(iconSecondBitmap, 90, 90);
		iconSecondBitmap.smoothing = true;
		
		spriteSecond.x = light.x + (light.width - iconSecondBitmap.width) / 2;
		spriteSecond.y = light.y + (light.height - iconSecondBitmap.height) / 2;
		
		spriteSecond.tip = function():Object { 
			return {
				title:App.data.storage[sID2].title,
				text:App.data.storage[sID2].description
			};
		};
		
		spriteSecond.addChild(iconSecondBitmap);
	}
	
	private var spriteAction:LayerX = new LayerX();
	public function onLoadAction(data:Bitmap):void {
		addChild(spriteAction);
		
		var iconAction:Bitmap = new Bitmap();
		iconAction.bitmapData = data.bitmapData;
		Size.size(iconAction, 90, 90);
		iconAction.smoothing = true;
		
		spriteAction.x = 10;
		spriteAction.y = (background.height - iconAction.height) / 2 + 5;
		
		spriteAction.addChild(iconAction);
		
		var actionPrms:Object = {
			color			:0xffffff,
			borderColor		:0x5a2e09,
			width			:iconAction.width,
			multiline		:true,
			wrap			:true,
			textAlign		:'left',
			fontSize		:30
		};
		var actionLabel:TextField = Window.drawText('x100', actionPrms);
		actionLabel.x = iconAction.x + iconAction.width - actionLabel.textWidth + 10;
		actionLabel.y = iconAction.y + iconAction.height - actionLabel.textHeight;
		spriteAction.addChild(actionLabel);
	}
}