package wins 
{
	import buttons.Button;
	import buttons.ImageButton;
	import buttons.MoneyButton;
	import core.Load;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import ui.Hints;
	import ui.UserInterface;
	import wins.elements.OutItem;
	import wins.elements.UnlockItem;
	
	public class OpenWorldWindow extends Window
	{
		public static const OPEN_ZONE:uint = 1;
		public static const OPEN_WORLD:uint = 2;
		
		public var item:Object;
		
		public var bitmap:Bitmap;
		public var title:TextField;
		public var applyBttn:Button;
		
		private var progressBar:ProgressBar;
		private var buyBttn:MoneyButton;
		
		private var leftTime:int;
		private var started:int;
		private var totalTime:int;
		
		private var sID:uint;
		private var unlock:Object;
		private var container:Sprite;
		
		private var partList:Array = [];
		private var padding:int = 10;
		private var outItem:OutItem;
		
		private var mode:uint;
		
		public function OpenWorldWindow(settings:Object = null):void
		{
			if (settings == null) {
				settings = new Object();
			}
			
			settings['sID'] = settings.sID || 0;
			
			settings["width"] = 637;
			settings["height"] = 280;
			settings["popup"] = true;
			settings["fontSize"] = 30;
			settings["callback"] = settings["callback"] || null;
			settings["hasPaginator"] = false;
			
			settings["description"] = Locale.__e("flash:1382952380232");
			
			//formula = App.data.crafting[settings.fID];
			sID = settings.sID;
			
			settings["title"] = App.data.storage[sID].title;
			
			unlock = settings["unlock"];
			
			super(settings);
		}
		
		public function drawDescription():void {
			var descriptionLabel:TextField = drawText(settings.description, {
				fontSize:22,
				color:0x5a524c,
				borderColor:0xfaf1df
			});
			descriptionLabel.width = descriptionLabel.textWidth + 5;
			descriptionLabel.x = (settings.width - descriptionLabel.width) / 2;
			descriptionLabel.y = 10;
			
			bodyContainer.addChild(descriptionLabel);
		}
		
		override public function drawBackground():void {
			//var background:Bitmap = backing(settings.width, settings.height, 30, "windowBacking");
			//layer.addChild(background);
		}
		
		override public function drawExit():void {
			super.drawExit();
			
			exit.x = settings.width - exit.width + 12;
			exit.y = -12;
		}
		
		override public function drawBody():void {
			
			titleLabel.y = 2;
			createItems();
			
			var backgroundWidth:int = partList.length * (partList[0].background.width + 5) - 5;
			background = Window.backing(backgroundWidth, 190, 10, "itemBacking");
			bodyContainer.addChildAt(background, 0);
			background.x = padding;
			background.y = 36;
			
			settings.width = padding + backgroundWidth + padding;//5 + partList[0].background.width + 
			drawDescription();
			
			var _background:Bitmap = backing(settings.width+100, settings.height+130, 80, "windowActionBacking");//"greenBacking"
			layer.addChild(_background);
			_background.x = (settings.width - _background.width) / 2;
			_background.y = -50;
			
			
			var background:Bitmap = backing(settings.width, settings.height, 30, "windowDarkBacking");//"greenBacking"
			layer.addChild(background);
			
			exit.x = settings.width - exit.width + 12;
			titleLabel.x = (settings.width - titleLabel.width) * .5;
			
			container.x = padding;
			container.y = 36;
			
			outItem.x = (settings.width - outItem.width) / 2;
			outItem.y += 70;
			
			var bitmap:Bitmap = new Bitmap(settings.bitmapData);
			layer.addChild(bitmap);
			bitmap.x = (settings.width - bitmap.width) / 2;
			bitmap.y = -bitmap.height/2;
		}
		
		private function createItems():void
		{
			container = new Sprite();
			
			var offsetX:int = 0;
			var offsetY:int = 0;
			var dX:int = 5;
			
			var pluses:Array = [];
			
			var count:int = 0;
			for (var sID:* in settings.require) {
				
				if (App.data.storage[sID].type == "Zones") continue;
				var inItem:MaterialItem = new MaterialItem({
					sID:sID,
					need:settings.require[sID],
					window:this, 
					type:MaterialItem.IN,
					bitmapDY:-10
				});
				
				inItem.checkStatus();
				inItem.addEventListener(WindowEvent.ON_CONTENT_UPDATE, onUpdateOutMaterial)
				
				partList.push(inItem);
				
				container.addChild(inItem);
				inItem.x = offsetX;
				inItem.y = offsetY;
				
				offsetX += inItem.background.width + dX;
				inItem.background.visible = false;
				
				if (count > 0) addPlus(container, inItem);
				
				count++;
			}
			
			var unlockItem:UnlockItem
			// Добавляем требование по друзьям
			if (unlock && unlock.friends != 0)
			{
				unlockItem = new UnlockItem( {
					title:Locale.__e("flash:1382952380181"),
					description:"",
					need:unlock.friends,
					count:App.user.friends.keys.length,
					iconUrl:Config.getIcon("Material", 'friends'),
					window:this, 
					type:MaterialItem.IN,
					bitmapDY:-10
				});
				
				unlockItem.checkStatus();
				unlockItem.addEventListener(WindowEvent.ON_CONTENT_UPDATE, onUpdateOutMaterial)
				
				partList.push(unlockItem);
				
				container.addChild(unlockItem);
				unlockItem.x = offsetX;
				unlockItem.y = offsetY;
				
				offsetX += unlockItem.background.width + dX;
				unlockItem.background.visible = false;
				
				addPlus(container, unlockItem);
			}
			
			// Добавляем требование по уровню
			if (unlock.level != 0)
			{
				unlockItem = new UnlockItem( {
					title:Locale.__e("flash:1382952380233"),
					description:"",
					need:unlock.level,
					count:App.user.level,
					window:this, 
					iconUrl:Config.getIcon("Material", 'level'),
					type:MaterialItem.IN,
					bitmapDY:-10
				});
				
				unlockItem.checkStatus();
				unlockItem.addEventListener(WindowEvent.ON_CONTENT_UPDATE, onUpdateOutMaterial)
				
				partList.push(unlockItem);
				
				container.addChild(unlockItem);
				unlockItem.x = offsetX;
				unlockItem.y = offsetY;
				
				offsetX += unlockItem.background.width + dX;
				unlockItem.background.visible = false;
				
				addPlus(container, unlockItem);
			}
			
			function addPlus(container:Sprite, inItem:*):void
			{
				var plus:Bitmap = new Bitmap(Window.textures.plus);
				container.addChild(plus);
				pluses.push(plus)
				plus.x = inItem.x - plus.width / 2;
				plus.y = inItem.background.height / 2 - plus.height/2;
			}
			
			
			var buyBttnSettings:Object = {
				bttnText:Locale.__e("flash:1382952379890"),
				hasBuyBttn:true,
				onBuy:onBuy
			}
			
			//if (mode == OPEN_WORLD)
			//	buyBttnSettings['hasBuyBttn'] = false;
			
			outItem = new OutItem(onCook, buyBttnSettings);
			
			//outItem.change({out:this.sID, iconUrl:Config.getIcon("Zones", 'zone')});
			container.addChild(outItem);
			
			outItem.x = offsetX;
			outItem.y = offsetY;
			
			outItem.background.visible = false;
			outItem.bitmap.visible = false;
			outItem.title.visible = false;
			
			/*var equality:Bitmap = new Bitmap(Window.textures.equality);
			container.addChild(equality);
			equality.x = outItem.x - equality.width / 2 - 2;
			equality.y = outItem.background.height / 2 - equality.height/2;*/
			
			bodyContainer.addChild(container);
			
			inItem.dispatchEvent(new WindowEvent(WindowEvent.ON_CONTENT_UPDATE));
		}
		
		public function onUpdateOutMaterial(e:WindowEvent):void {
			var outState:int = MaterialItem.READY;
			for each(var item:* in partList) {
				if(item.status != MaterialItem.READY){
					outState = item.status;
				}
			}
			
			if (outState == MaterialItem.UNREADY) 
			{
				outItem.recipeBttn.state = Button.DISABLED;
				outItem.recipeBttn.visible = false;
				if(outItem.buyBttn) outItem.buyBttn.visible = true;
			}	
			else
			{
				outItem.recipeBttn.state = Button.NORMAL;
				outItem.recipeBttn.visible = true;
				if(outItem.buyBttn) outItem.buyBttn.visible = false;
			}	
		}
		
		private function onCook(e:MouseEvent):void
		{
			if (e.currentTarget.mode == Button.DISABLED) return;
			settings.openZone(sID);
			close();
		}
		
		private function onBuy(e:MouseEvent):void
		{
			if (e.currentTarget.mode == Button.DISABLED) return;
			settings.openZone(sID, true);
			close();
		}
		
		override public function dispose():void
		{
			super.dispose();
		}
	}		
}