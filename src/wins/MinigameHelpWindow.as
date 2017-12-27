package wins 
{
	import buttons.Button;
	import core.Load;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.text.TextField;
	import ui.BitmapLoader;
	
	public class MinigameHelpWindow extends Window 
	{
		public function MinigameHelpWindow(settings:Object)
		{
			settings['title'] 			= settings['title'];
			settings['width'] 			= settings['width'] || 760;
			settings['popup'] 			= true;
			settings['hasArrows'] 		= true,
			settings['hasPaginator']	= true;
			settings['hasButtons'] 		= false;
			settings['itemsOnPage']		= settings['itemsOnPage'] || 3,
			settings['background'] 		= settings['background'] || 'alertBacking';
			
			if (settings.itemsOnPage == 2) settings['width'] = 560;
			
			
			super(settings);
		}
		
		override public function titleText(settings:Object):Sprite
		{
			var titleCont:Sprite = new Sprite();
			var mirrorDec:String = 'titleDecRose';
			var indent:int = 0;
			if (App.user.worldID == Travel.SAN_MANSANO || this.settings.background == 'goldBacking') {
				mirrorDec = 'goldTitleDec2';
				indent = -10;
			}
			
			var textLabel:TextField = Window.drawText(settings.title, settings);
			if (this.settings.hasTitle == true && this.settings.titleDecorate == true) {
				drawMirrowObjs(mirrorDec, textLabel.x + (textLabel.width - textLabel.textWidth) / 2 - 75, textLabel.x + (textLabel.width - textLabel.textWidth) / 2 + textLabel.textWidth + 75, textLabel.y + (textLabel.height - 40) / 2 + indent, false, false, false, 1, 1, titleCont);
			}
			
			titleCont.mouseChildren = false;
			titleCont.mouseEnabled = false;
			titleCont.addChild(textLabel);
			
			return titleCont;
		}
		
		override public function drawBody():void {
			exit.x = settings.width - 50;
			exit.y = 16;
			
			if (settings.hasOwnProperty('description')) {
				var desc:TextField = drawText(settings.description, {
					width:settings.width - 100,
					textAlign:'center',
					multiline:true,
					wrap:true,
					fontSize:22,
					color:0xffffff,
					borderColor:0x663816
				});
				desc.x = 50;
				desc.y = 9;
				bodyContainer.addChild(desc);
			}
			
			createContent();
			contentChange();
		}
		
		override public function drawArrows():void {	
			super.drawArrows();
			paginator.arrowLeft.y -= 50;
			paginator.arrowRight.y -= 50;
			
		}
		
		public function createContent(query:String = ""):Object {
			content = settings.content;
			return content;
		}
		
		public var items:Array = [];
		private var container:Sprite = new Sprite();
		override public function contentChange():void {
			var item:MiniGameItem;
			
			for each(var _item:* in items) {
				item = items.shift() as MiniGameItem;
				item.dispose();
				container.removeChild(_item);
			}
			
			items = [];
			
			for (var i:int = paginator.startCount; i < paginator.finishCount; i++){
				item = new MiniGameItem(content[i], onClose);
				item.x = 220 * items.length;
				container.addChild(item);
				items.push(item);
			}
			
			bodyContainer.addChild(container);
			settings.page = paginator.page;
			
			container.x = (settings.width - container.width) / 2;
			container.y = 50;
		}
		
		public function onClose():void{
			close();
		}
	}
}


import buttons.Button;
import core.Load;
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.text.TextField;
import ui.BitmapLoader;
import ui.Hints;
import wins.Window;

internal class MiniGameItem extends LayerX {
	
	private var bitmap:BitmapLoader;
	private var titleText:TextField;
	private var button:Button;
	private var link:*;
	private var target:Object;
	private var func:Function;
	private var callback:Function;
	
	public function MiniGameItem(item:* = null, callback:Function = null):void {
		this.link = item.link;
		this.func = item.func;
		this.target = item.target;
		this.callback = callback;
		
		drawSprite();
		
		tip = function():Object {
			return {
				title:	target.title,
				text:	target.description
			}
		}
	}
	
	private var currWidth:int = 220;
	private var currHeight:int = 320;
	private function drawSprite():void {
		
		bitmap = new BitmapLoader(link, currWidth, currHeight);
		addChild(bitmap);
		
		titleText = Window.drawText(target.title,{
			width		:140,
			fontSize	:36,
			textAlign	:'center',
			color		:0xffffff,
			borderColor	:0x643a00,
			multiline	:true,
			wrap		:true
		});
		titleText.x = (currWidth - titleText.width) * 0.5;
		titleText.y = (currHeight - titleText.textHeight) * 0.1;
		addChild(titleText);
		
		button = new Button( {
			onClick:		onClick,
			caption:		target.count,	// Цена за открытие точки с частью подарка
			width:			158,
			height:			56,
			fontSize:		36,
			fontColor:		0xffe349,
			fontBorderColor:0x614605,
			diamond:		true,
			countText:		target.count
		});
		button.textLabel.x += 15;
		button.textLabel.y += 2;
		button.x = (currWidth - button.width) / 2;
		button.y = currHeight - button.height * 0.4;
		button.state = (func == null) ? Button.DISABLED : Button.NORMAL;
		
		
		var currencyIcon:BitmapLoader = new BitmapLoader(target.sid, 42, 42);
		currencyIcon.x = 20;
		currencyIcon.y = 8;
		button.addChild(currencyIcon);
		addChild(button);
	}
	
	private function onClick(e:MouseEvent = null):void {
		if (button.mode == Button.DISABLED) {
			Hints.text(Locale.__e('flash:1472808354478'), 9, new Point(App.self.mouseX, App.self.mouseY));
			return;
		}
		
		func();
		if (callback != null)
			callback();
	}
	
	public function dispose():void{
		button.dispose();
	}
}