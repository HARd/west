package wins 
{
	import buttons.Button;
	import buttons.ImageButton;
	import buttons.MoneyButton;
	import core.Load;
	import core.Numbers;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.text.TextField;
	import ui.Hints;
	import ui.UserInterface;
	import wins.elements.OutItem;
	
	public class EventWindow extends Window
	{
		public var item:Object;
		
		public var bitmap:Bitmap;
		public var title:TextField;
		
		private var buyBttn:MoneyButton;
		
		private var sIDs:Object;
		private var sID:uint;
		private var need:uint;
		private var container:Sprite;
		
		private var partList:Array = [];
		private var padding:int = 10;
		public var outItem:OutItem;
		public var eventBttn:Button;
		
		public function EventWindow(settings:Object = null):void
		{
			if (settings == null) {
				settings = new Object();
			}
			
			settings['sID'] = settings.sID || 0;
			
			settings["width"] = 350;
			settings["height"] = 370;
			settings["popup"] = true;
			settings["hasTitle"] = false;
			settings["callback"] = settings["callback"] || null;
			settings["hasPaginator"] = false;
			settings["bttnCaption"] = settings.bttnCaption || Locale.__e("flash:1382952380090");
			settings['background'] = 'alertBacking';
			
			if (settings.hasDescription) settings.height += 40;
			
			sIDs = settings.sIDs;
			if (Numbers.countProps(sIDs) > 0) {
				for (var s:* in sIDs) {
					sID = int(s);
					need = sIDs[s];
					break;
				}
				
				settings["width"] = 210 + Numbers.countProps(sIDs) * 150 + (Numbers.countProps(sIDs) - 1) * 10;
			}
			
			settings["title"] = settings.target.info.title;
			super(settings);	
		}
		
		override public function drawExit():void {
			super.drawExit();
			
			exit.x = settings.width - exit.width + 12;
			exit.y = -12;
		}
		
		override public function drawBody():void {
			for each(var item:* in settings.target.textures.sprites){}
			drawLabel(item.bmp, 0.75);
			titleLabelImage.y -= 15;
			
			var titleText:TextField = Window.drawText(settings.title, {
				color:0xfffef6,
				borderColor:0xb98659,
				borderSize:2,
				textAlign:"center",
				autoSize:"center",
				fontSize:32,
				textLeading:-6,
				multiline:true
			});
			titleText.x = (settings.width - titleText.width) / 2;
			titleText.y = -titleText.height/2 + 14;
			bodyContainer.addChild(titleText);
			titleText.filters = titleText.filters.concat(new GlowFilter(0x855729, 1, 4, 4, 16));
			
			drawDescription();
			
			container = new Sprite();
			bodyContainer.addChild(container);
			
			createItems();
			
			container.x = (settings.width - container.width) * .5;
			container.y = 72;
			
			exit.x = settings.width - exit.width + 12;
			
			eventBttn = new Button({
				caption		:settings.bttnCaption,
				width		:185,
				height		:53,	
				fontSize	:26
			});
			
			drawMirrowObjs('storageWoodenDec', -4, settings.width + 4, settings.height - 71);
			
			bodyContainer.addChild(eventBttn);
			eventBttn.x = (settings.width - eventBttn.width) / 2;
			eventBttn.y = settings.height - eventBttn.height - 7;
			
			if (App.user.stock.data[sID] < need)
				eventBttn.visible = false; //eventBttn.state = Button.DISABLED;
				
			eventBttn.addEventListener(MouseEvent.CLICK, onClick);	
			drawMirrowObjs('diamondsTop', titleText.x + 15, titleText.x + titleText.width - 15, titleText.y, true, true);
		}
		
		override public function drawLabel(bmd:BitmapData, scale:Number = 1):void {
			titleLabelImage = new Bitmap(bmd);
			bodyContainer.addChild(titleLabelImage);
			if (titleLabelImage.height > 260 && scale == 1) 
				scale = 260 / titleLabelImage.height;
			
			titleLabelImage.scaleX = titleLabelImage.scaleY = scale;
			titleLabelImage.smoothing = true;
			
			titleLabelImage.x = (settings.width - titleLabelImage.width)/2;
			titleLabelImage.y = -titleLabelImage.height / 2;
		}
		
		private function onClick(e:MouseEvent):void {
			if (e.currentTarget.mode == Button.DISABLED) return;
			e.currentTarget.state = Button.DISABLED;
			
			settings.onWater();
			close();
		}
		
		private function drawDescription():void {
			
			var text1:TextField = drawText(Locale.__e(settings.description), {
				fontSize:22,
				color:0xfff8eb,
				borderColor:0x977533,
				textAlign:'center',
				multiline:true
			});
			
			text1.width = settings.width;
			bodyContainer.addChild(text1);
			text1.x = 0;
			text1.y = 50;
		}
		
		private var items:Vector.<MaterialItem> = new Vector.<MaterialItem>;
		private function createItems():void
		{
			var currX:int = 0;
			for (var s:* in sIDs) {
				var inItem:MaterialItem = new MaterialItem({
					background:"shopBackingSmall2",
					sID:int(s),
					need:sIDs[s],
					window:this,
					type:MaterialItem.IN,
					bitmapDY:-10
				});
				
				items.push(inItem);
				inItem.checkStatus();
				inItem.addEventListener(WindowEvent.ON_CONTENT_UPDATE, onUpdateOutMaterial);
				inItem.x = currX;
				inItem.y = 40;
				currX += inItem.width + 10;
				
				container.addChild(inItem);
			}
		}
		
		public function onUpdateOutMaterial(e:WindowEvent):void {
			if (App.user.stock.data[sID] >= need)
				eventBttn.visible = true;//eventBttn.state = Button.NORMAL;
		}
		
		override public function dispose():void
		{
			super.dispose();
		}
	}		
}
