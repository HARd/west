package wins.elements 
{

	import buttons.Button;
	import buttons.MoneyButton;
	import core.Load;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import wins.Window;

	//Вспомогательный класс
	public class OutItem extends Sprite{
		
		public var background:Bitmap = null;
		public var bitmap:Bitmap = null;
		public var sID:String;
		
		public var title:TextField = null;
		public var timeText:TextField = null;
		public var recipeText:TextField = null;
		public var recipeBttn:Button;
		public var icon:Bitmap
		public var buyBttn:MoneyButton
		public var fontSize:int = 22;
		private var price:uint = 0;
		public var preloader:Preloader = new Preloader();
		public var sprTip:LayerX = new LayerX();
		public var formula:Object;
		
		
		private var settings:Object = { 
			bttnText:Locale.__e("flash:1382952380036"),
			hasBuyBttn:false,
			onBuy:function():void { } 
		};
		
		public function OutItem(onCook:Function, settings:Object = null)
		{
			if (settings != null) {
				for (var key:* in settings)
					this.settings[key] = settings[key];
			}
			
			this.formula = settings['formula'];
			settings['bttnText'] = settings.recipeBttnName;
			
			background = new Bitmap(new BitmapData(110, 110, true, 0));
			background.x = 20;
			background.y = 40;
			addChild(background);
			
			var shape:Shape = new Shape();
			shape.graphics.beginFill(0xc7cabf, 1);
			shape.graphics.drawCircle(55, 55, 55);
			shape.graphics.endFill();
			background.bitmapData.draw(shape);
			
			if (contains(sprTip)) {
				removeChild(sprTip);
				sprTip = new LayerX();
			}
			bitmap = new Bitmap();
			sprTip.addChild(bitmap);
			addChild(sprTip);
			
			title = Window.drawText(App.data.storage[formula.out].title, {
				fontSize:24,
				color:0x814f31,
				borderColor:0xfaf9ec,
				textLeading: -6,
				multiline:true,
				textAlign:"center",
				autoSize:"center",
				width:background.width,
				wrap:true
			});
			title.x = background.x + (background.width - title.width) / 2;
			title.y = 0;
			addChild(title);
			
			
			addChild(preloader);
			preloader.x = (background.width) / 2;
			preloader.y = (background.height) / 2;
			
			// Timer
			if (formula.time)
			{
				var timeIcon:TimeIcon = new TimeIcon(formula.time);
				addChild(timeIcon);
				timeIcon.x = background.x + (background.width - timeIcon.width) / 2;
				timeIcon.y = background.y + background.height + 6;
			} else
			{
				var time:TextField = Window.drawText(Locale.__e("flash:1428061669314"), {
					color:0xFFFFFF,
					borderColor:0x763b18,
					fontSize:26,
					borderSize:4,
					letterSpacing:1,
					autoSize:"left"
				});
				addChild(time);
				time.x = background.x + (background.width - time.width) / 2;
				time.y = background.y + background.height + 6;
			}
			
			
			// Recipe
			recipeBttn = new Button( {
				width:128,
				fontSize:26,
				radius:14,
				caption:Locale.__e("flash:1382952380036"),
				fontSize:20,
				height:44
			});
			
			recipeBttn.x = background.x + (background.width - recipeBttn.width) / 2;
			recipeBttn.y = background.y + background.height + 45;
			recipeBttn.name = 'rw_craft';
			recipeBttn.addEventListener(MouseEvent.CLICK, onCook);
			addChild(recipeBttn);
			
			if (settings.hasOwnProperty('formula') && settings.formula.count > 1)
				drawCount();
			
			sID = formula.out;
			if (App.user.level <= 4 || this.settings['find'] == sID) {
				recipeBttn.showGlowing();
				if (App.user.level < 3)
					recipeBttn.showPointing('bottom', 0, recipeBttn.height + 30, this);
			}
			
			var iconUrl:String;
			if (formula.hasOwnProperty('iconUrl'))
				iconUrl = formula.iconUrl;
			else
				iconUrl = Config.getIcon(App.data.storage[formula.out].type, App.data.storage[formula.out].preview); 
				
			Load.loading(iconUrl, onPreviewComplete);
		}
		
		public function drawCount():void {
			//var counterSprite:LayerX = new LayerX();
			//counterSprite.tip = function():Object { 
				//return {
					//title:"",
					//text:Locale.__e("flash:1382952380064")
				//};
			//};
			
			var countOnStock:TextField = Window.drawText("x"+settings.formula.count, {
				color:0xFFFFFF,
				borderColor:0x763b18,
				fontSize:34,
				borderSize:4,
				letterSpacing:1,
				autoSize:"left"
			});
			addChild(countOnStock);
			countOnStock.x = background.x + background.width - 30;
			countOnStock.y = background.y + background.height - 30;
			
			//var width:int = countOnStock.width + 24 > 30?countOnStock.width + 24:30;
			//var bg:Bitmap = Window.backing(width, 40, 10, "smallBacking");
			//
			//
			//counterSprite.addChild(bg);
			//addChild(counterSprite);
			//counterSprite.x = background.width - counterSprite.width + 8;
			//counterSprite.y = 36;
			//
			//addChild(countOnStock);
			//countOnStock.x = counterSprite.x + (counterSprite.width - countOnStock.width) / 2;
			//countOnStock.y = counterSprite.y + 10;
		}
		
		public function flyMaterial():void
		{
			var item:BonusItem = new BonusItem(uint(sID), 0);
			
			var point:Point = Window.localToGlobal(bitmap);
			point.y += bitmap.height / 2;
			
			item.cashMove(point, App.self.windowContainer);
			
			App.user.stock.add(int(sID), settings.formula.count);
		}
			
		public function onPreviewComplete(obj:Object):void
		{
			removeChild(preloader);
			
			bitmap.bitmapData = obj.bitmapData;
			bitmap.smoothing = true;
			sprTip.x = background.x + (background.width - bitmap.width) / 2;
			sprTip.y = background.y + (background.height - bitmap.height) / 2 - 5;
		}
	}
}