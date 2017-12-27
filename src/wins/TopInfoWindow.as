package wins 
{
	import buttons.Button;
	import core.Numbers;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	/**
	 * ...
	 * @author ...
	 */
	public class TopInfoWindow extends Window 
	{
		public var leaguesName:Array = [Locale.__e('flash:1457968002169'),Locale.__e('flash:1457968020193'),Locale.__e('flash:1457968031528')];
		public function TopInfoWindow(settings:Object=null) 
		{
			if (settings == null) {
				settings = new Object();
			}
			
			settings['background'] 		= (App.user.worldID == Travel.SAN_MANSANO) ? 'goldBacking' : 'alertBacking';
			settings['width'] 			= 585;
			settings['height'] 			= 485;
			settings['title'] 			= '';// Locale.__e('flash:1382952380254');
			settings['hasPaginator'] 	= true;
			settings['hasButtons']		= false;
			settings['itemsOnPage'] 	= 1;
			settings['hasExit'] 		= false;
			settings['hasTitle'] 		= true;
			settings['faderClickable'] 	= true;
			settings['faderAlpha'] 		= 0.6;
			settings['popup'] 			= true;
			settings['caption'] 		= settings.caption || Locale.__e('flash:1382952380298');
			settings['content']			= [];
			
			if (settings.hasOwnProperty('topID')) {
				for (var leg:* in App.data.top[settings.topID].league.tbonus) {
					var content:Object = { };				
					for (var i:* in App.data.top[settings.topID].league.tbonus[leg].d) {
						content[i + 1] = { };
						content[i + 1]['text'] = App.data.top[settings.topID].league.tbonus[leg].d[i];
						content[i + 1]['icon'] = App.data.top[settings.topID].league.tbonus[leg].i[i];	
					}
					settings.content.push(content);
				}
			}
			
			if (settings.content.length > 0) {
				if (Numbers.countProps(settings.content[0]) == 2) {
					settings['height'] = 20 + 92 * (Numbers.countProps(settings.content[0]) + 2);
				}else {
					settings['height'] = 50 + 92 * (Numbers.countProps(settings.content[0]) + 2);
				}
			}
			
			super(settings);
			
		}
		
		override public function drawTitle():void {
			if (titleLabel) {
				headerContainer.removeChild(titleLabel);
				titleLabel = null;
			}
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
			titleLabel.y = - titleLabel.height / 2;
			titleLabel.mouseChildren = titleLabel.mouseEnabled = false;
			headerContainer.addChild(titleLabel);
			
			headerContainer.y = 32;
			headerContainer.mouseEnabled = false;
		}
		
		override public function drawBody():void {			
			var bttn:Button = new Button( {  width:194, height:53, caption:settings.caption } );
			bodyContainer.addChild(bttn);
			bttn.x = (settings.width - bttn.width) / 2;
			bttn.y = settings.height - bttn.height - 25;
			bttn.addEventListener(MouseEvent.CLICK, onClick);
			
			if (settings.content.length != 0) {
				paginator.itemsCount = settings.content.length;
				paginator.update();
				paginator.onPageCount = 1;
			}
			
			contentChange();
		}
		
		private var items:Array;
		private var itemsContainer:Sprite = new Sprite();
		override public function contentChange():void {
			if (items) {
				for each(var _item:* in items) {
					itemsContainer.removeChild(_item);
				}
			}
			items = [];
			
			bodyContainer.addChild(itemsContainer);
			var item:HelpItem;
			for (var i:int = paginator.startCount; i < paginator.finishCount; i++) {
				for (var j:* in settings.content[i]) {
					item = new HelpItem(j, settings.content[i][j], settings.content[i][j].text);
					item.x = 53;
					item.y = 40 + (j - 1) * (item.background.height + 20);
					itemsContainer.addChild(item);
					
					items.push(item);
				}
			}
			
			settings['title'] = leaguesName[i - 1];
			drawTitle();
		}
		
		public function onClick(e:MouseEvent):void {
			if (settings.callback) settings.callback();
			close();
		}
		
		override public function close(e:MouseEvent = null):void {
			App.user.onStopEvent();
			super.close();
		}
		
		public override function dispose():void {
			if (items) {
				for each(var _item:* in items) {
					itemsContainer.removeChild(_item);
				}
			}
			items = [];
			
			super.dispose();
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

internal class HelpItem extends Sprite {
	
	public var background:Shape = new Shape();
	public var iconBitmap:Bitmap = new Bitmap();
	public var descriptionLabel:TextField;
	public var helpObj:Object;
	public var helpNum:int;
	public var descText:String;
	public var qID:String;
	
	public function HelpItem(helpNum:int, helpObj:Object, descText:String):void {		
		this.helpObj = helpObj;
		this.helpNum = helpNum;
		this.descText = descText;
		this.qID = qID;
		background.graphics.beginFill(0xffffff, 0);
		background.graphics.drawRect(0, 0, 480, 92);
		background.graphics.endFill();
		addChild(background);
		
		var up_devider:Bitmap = new Bitmap(Window.textures.dividerLine);
		up_devider.x = 75;
		up_devider.y = 0;
		up_devider.width = background.width - 200;
		up_devider.alpha = 0.6;
		addChild(up_devider);
		
		var down_devider:Bitmap = new Bitmap(Window.textures.dividerLine);
		down_devider.x = up_devider.x;
		down_devider.width = up_devider.width;
		down_devider.y = background.height - 4;
		down_devider.alpha = 0.6;
		addChild(down_devider);
		
		drawCircles();
		addChild(iconBitmap);
		drawDescription();
		

		if (helpObj.icon is int) {
			Load.loading(Config.getIcon(App.data.storage[helpObj.icon].type, App.data.storage[helpObj.icon].preview), onLoad);
		}else {
			Load.loading(Config.getImageIcon('help', helpObj.icon, 'png'), onLoad);
		}
	}
	
	private function showHelp(e:MouseEvent):void {
		new GambleWindow( {
			sID:1151,
			popup:true
		}).show();
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
		var numberLabel:TextField = Window.drawText(String(helpNum), numPrms);
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
			descriptionLabel.x = 80;
			descriptionLabel.y = (background.height - descriptionLabel.height) / 2 + 2;
			textSize--;
		}while (descriptionLabel.height >= 85)
		addChild(descriptionLabel);
	}
	
	private var scaleCirc:Number = 1.2;
	private var sprite:LayerX = new LayerX();
	public function onLoad(data:Bitmap):void {
		addChild(sprite);
		
		iconBitmap.bitmapData = data.bitmapData;
		Size.size(iconBitmap, 100, 100);
		iconBitmap.x = circle.x - iconBitmap.width / 2;
		iconBitmap.y = circle.y - iconBitmap.height / 2;
		
		sprite.tip = function():Object { 
				if (helpObj.icon is int) {
					return {
						title:App.data.storage[helpObj.icon].title,
						text:App.data.storage[helpObj.icon].description
					};
				}
			
			return null;
		};
		
		sprite.addChild(iconBitmap);
	}
}