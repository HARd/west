package wins 
{
	import buttons.MixedButton2;
	import flash.display.Bitmap;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import wins.elements.PlantationItem;
	import wins.elements.ProductionItem;
	/**
	 * ...
	 * @author ...
	 */
	public class PlantationWindow extends Window
	{
		public var items:Array = new Array();
		
		private var background:Bitmap;
		
		private var _arrData:Array = [];
		
		public static var history:int = 0;
		
		private var upgradeBttn:MixedButton2;
		private var neddLvlBttn:MixedButton2;
		
		protected var subTitle:TextField = null;
		
		public function PlantationWindow(settings:Object = null) 
		{
			if (settings == null) {
				settings = new Object();
			}
			
			settings['sID'] = settings.sID || 0;
			
			settings['page'] = history;
			settings["width"] = 663;
			settings["height"] = 600;//558;
			settings["popup"] = true;
			settings["fontSize"] = 44;
			settings["callback"] = settings["callback"] || null;
			settings['hasPaginator'] = false;
			
			super(settings);	
		}
		
		override public function drawBody():void
		{
			
			background = Window.backing(618, 488, 40, "shopBackingSmall");
			bodyContainer.addChild(background);
			background.x = (settings.width - background.width)/2;
			background.y = 40;
			
			var underTitle:Bitmap = Window.backingShort(180, "orangeStripPiece");
			underTitle.x = (settings.width - underTitle.width) / 2;
			underTitle.y = background.y - underTitle.height;
			bodyContainer.addChild(underTitle);
			
			subTitle = Window.drawText(Locale.__e("flash:1396608622333", [settings.target.level]), {
				fontSize:24,
				color:0xFFFFFF,
				autoSize:"left",
				borderColor:0xb56a17
			});
			bodyContainer.addChild(subTitle);
			subTitle.x = settings.width / 2 - subTitle.width / 2;
			subTitle.y = background.y - subTitle.textHeight - 8;
			
			drawMirrowObjs('diamondsTop', settings.width / 2 - settings.titleWidth / 2 - 5, settings.width / 2 + settings.titleWidth / 2 + 5, -44, true, true);
			drawMirrowObjs('diamonds',-24, settings.width + 24, settings.height - 118);
			
			createItems();
			//paginator.itemsCount = 0;
			
			var lvlRec:int = 0;
			if (settings.target.info.hasOwnProperty('devel') ) {
				for each(var obj:* in settings.target.info.devel.open) {
					lvlRec += 1;
					for (var fID:* in obj) {
						_arrData.push({fid:fID, lvl:lvlRec});
					}
				}
			}
			_arrData.sortOn("lvl", Array.NUMERIC);
			
			var separator:Bitmap = Window.backingShort(180, 'separator3');
			separator.x = 35;
			separator.y = 32;
			separator.alpha = 0.5;
			layer.addChild(separator);
			
			var separator2:Bitmap = Window.backingShort(180, 'separator3');
			separator2.y = 32;
			separator2.alpha = 0.5;
			separator2.x = settings.width - 35 - separator2.width
			layer.addChild(separator2);
			
			//paginator.itemsCount = _arrData.length; 
			//
			//paginator.page = settings.page;
			//paginator.update();
			//
			//paginator.y += 38;
			
			if (settings.target.level >= settings.target.totalLevels) {}
			else if(settings.target.info.devel.req[settings.target.level + 1].l <= App.user.level)
				drawUpgradeBttn();
			else 
				drawNeedLvlBttn();
			
			contentChange();
		}
		
		private function drawNeedLvlBttn():void 
		{
			var icon:Bitmap = new Bitmap(Window.textures.star, "auto", true);
			
			neddLvlBttn = new MixedButton2(icon,{
				title: Locale.__e("flash:1393579961766"),
				width:236,
				height:55,
				countText:settings.target.info.devel.req[settings.target.level + 1].l,
				hasText2:true,
				fontSize:24,
				iconScale:0.95,
				radius:20,
				bgColor:[0xe4e4e4, 0x9f9f9f],
				bevelColor:[0xfdfdfd, 0x777777],
				fontColor:0xffffff,
				fontBorderColor:0x575757,
				fontCountColor:0xffffff,
				fontCountBorder:0x575757
				
			})
			
			bodyContainer.addChild(neddLvlBttn);
			neddLvlBttn.x = (settings.width - neddLvlBttn.width)/2 + 32;
			neddLvlBttn.y = settings.height - neddLvlBttn.height - 10;
			
			//neddLvlBttn.textLabel.x += 2;
			
			neddLvlBttn.coinsIcon.x += 198;
			neddLvlBttn.coinsIcon.y -= 2;
			neddLvlBttn.countLabel.x += 267; neddLvlBttn.countLabel.y += 10;
			neddLvlBttn.textLabel.x += 4;
		}
		
		private function drawUpgradeBttn():void 
		{
			var icon:Bitmap = new Bitmap(Window.textures.diamond, "auto", true);
			var icon2:Bitmap = new Bitmap(Window.textures.diamond, "auto", true);
			upgradeBttn = new MixedButton2(icon, {
				title: Locale.__e("flash:1393579980702"),// flash:1382952380253"),
				width:236,
				height:55,
				countText:"",
				fontSize:28,
				iconScale:0.95,
				radius:30
				
			}, icon2)
			
			bodyContainer.addChild(upgradeBttn);
			upgradeBttn.x = (settings.width - upgradeBttn.width) / 2 + 4;
			upgradeBttn.y = settings.height - upgradeBttn.height - 14;
			
			upgradeBttn.textLabel.x += 18;
			
			upgradeBttn.coinsIcon.x += 23;
			upgradeBttn.icon2.x -= 10;
			upgradeBttn.countLabel.x += 82; upgradeBttn.countLabel.y += 10;
			upgradeBttn.textLabel.x += 6;
			
			upgradeBttn.addEventListener(MouseEvent.CLICK, onUpgradeEvent);
		}
		
		private function onUpgradeEvent(e:MouseEvent):void 
		{
			new ConstructWindow( {
				title:settings.target.info.title,
				upgTime:settings.upgTime,
				request:settings.target.info.devel.obj[settings.target.level + 1],
				target:settings.target,
				win:this,
				onUpgrade:onUpgradeAction,
				hasDescription:true
			}).show();
		}
		private function onUpgradeAction():void
		{
			settings.target.upgradeEvent(settings.target.info.devel.obj[settings.target.level + 1]);
			close();
		}
		
		public var itemsX:int;
		public var itemsY:int;
		
		private var itemsPaddingY:int = 13;
		
		private var itemsMarginX:int = 12;
		private var itemsMarginY:int;
		
		private var itemWidth:int = 286;
		private var itemHeight:int = 212;
		public function createItems():void {
			
			var itemsPerRow:int = int(settings.itemsOnPage / 2);
			itemsX = (settings.width - (itemWidth * itemsPerRow + itemsMarginX * (itemsPerRow - 1))) / 2;
			
			itemsY = background.y + itemsPaddingY;
			
			itemsMarginY = (background.height - (itemHeight * (int(settings.itemsOnPage) / itemsPerRow) + itemsPaddingY * 2)) - 13; 
			
			var Xs:int = itemsX;
			
			for (var i:int = 0; i < settings.itemsOnPage;  i++)
			{
				var item:PlantationItem = new PlantationItem(this, {height:itemHeight, width:itemWidth});
				
				bodyContainer.addChild(item);
				items.push(item);
				
				item.x = itemsX;
				item.y = itemsY;
				
				itemsX += item.background.width + itemsMarginX;
				if (i == int(settings.itemsOnPage / 2) - 1)
				{
					itemsX = Xs;
					itemsY += item.background.height + itemsMarginY;
				}
			}
		}
		
		override public function contentChange():void 
		{
			
			for (var i:int = 0; i < items.length; i++)
			{
				items[i].visible = false;
			}
			
			var itemNum:int = 0
			
			//for (i = paginator.startCount; i < paginator.finishCount; i++)
			for (i = 0; i < items.length; i++)
			{
				items[itemNum].change(_arrData[i].fid, _arrData[i].lvl);
				items[itemNum].visible = true;
				itemNum++;
			}
			
			//settings.page = paginator.page;
			//history = settings.page;
		}
		
		public function onCookEvent(fID:uint):void 
		{
			settings.onCraftAction(fID);
			close();
			SoundsManager.instance.playSFX('production');	
		}
		
	}

}