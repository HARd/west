package wins 
{
	import buttons.MixedButton2;
	import buttons.UpgradeButton;
	import core.Load;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.text.TextField;
	/**
	 * ...
	 * @author ...
	 */
	public class StoreHouseWindow extends Window
	{
		public var bitmap:Bitmap;
		public var title:TextField;
		
		public var capasitySprite:LayerX = new LayerX();
		private var capasitySlider:Sprite = new Sprite();
		public var capasityBar:Bitmap;
		private var upgradeBttn:UpgradeButton;
		private var neddLvlBttn:UpgradeButton;
		
		public function StoreHouseWindow(settings:Object = null) 
		{
			settings["width"] = 366;
			settings["height"] = 402;
			settings["fontSize"] = 50;
			settings["fontBorderSize"] = 1;
			settings["fontBorderGlow"] = 1;
			settings["hasPaginator"] = false;
			
			super(settings);
		}
		
		override public function drawBackground():void {
			var background:Bitmap = backing2(settings.width, settings.height, 40, "questsSmallBackingTopPiece", "questsSmallBackingBottomPiece");
			layer.addChild(background);
		}
		
		private var preloader:Preloader = new Preloader();
		override public function drawBody():void {
			titleLabel.y += 4;
			drawMirrowObjs('diamondsTop', titleLabel.x/* + 120*/,titleLabel.x + titleLabel.width/* - 120*/, -35, true, true);
			
			background = Window.backing(296, 260, 10, "itemBacking");
			bodyContainer.addChild(background);
			background.x = (settings.width - background.width)/2;
			background.y = 2;
			
			var lvlLbg:Bitmap = Window.backingShort(210, "yellowRibbon");
			bodyContainer.addChild(lvlLbg);
			lvlLbg.x = background.x + (background.width - lvlLbg.width)/2;
			lvlLbg.y = -2;
			
			bitmap = new Bitmap();
			
			settings.target.textures
			
				bitmap.bitmapData = settings.target.bitmap.bitmapData;//data.bitmapData;
				bitmap.smoothing = true;	
				bitmap.x = (settings.width - bitmap.width) / 2;
				bitmap.y = 130 - bitmap.height / 2;
			
			bodyContainer.addChild(bitmap);
			
			
			var lvlLabel:TextField = Window.drawText(Locale.__e("flash:1396608622333", [settings.target.level]),{
					fontSize:24,
					autoSize:"left",
					textAlign:"center",
					multiline:true,
					color:0xffffff,
					borderColor:0x814f31	
				});
			bodyContainer.addChild(lvlLabel);
			lvlLabel.x = lvlLbg.x + (lvlLbg.width - lvlLabel.textWidth) / 2;
			lvlLabel.y = 4;
			
			
			
			addSlider();
			
			if (settings.target.level <= settings.target.totalLevels) {
				drawDescription();
			}
				
			
			if (settings.target.level >= settings.target.totalLevels) {}
			//else if(settings.target.info.devel.req[settings.target.level + 1].l <= App.user.level)
			else	
				drawUpgradeBttn();
			//else 
				//drawNeedLvlBttn();
		}
		
		private function drawNeedLvlBttn():void 
		{
			neddLvlBttn = new UpgradeButton(UpgradeButton.TYPE_OFF,{
				caption: Locale.__e("flash:1393579961766"),
				width:236,
				height:55,
				icon:Window.textures.star,
				countText:String(settings.target.info.devel.req[settings.target.level + 1].l),
				fontSize:24,
				iconScale:0.95,
				radius:20,
				bgColor:[0xe4e4e4, 0x9f9f9f],
				bevelColor:[0xfdfdfd, 0x777777],
				fontColor:0xffffff,
				fontBorderColor:0x575757,
				fontCountColor:0xffffff,
				fontCountBorder:0x575757,
				fontCountSize:24,
				fontBorderCountSize:4
			})
			
			bodyContainer.addChild(neddLvlBttn);
			neddLvlBttn.x = (settings.width - neddLvlBttn.width)/2;
			neddLvlBttn.y = settings.height - neddLvlBttn.height/2 - 6;
		}
		
		private function drawUpgradeBttn():void 
		{
			upgradeBttn = new UpgradeButton(UpgradeButton.TYPE_ON,{
				caption: Locale.__e("flash:1393580216438"),
				widthButton:278,
				height:55,
				icon:Window.textures.upgradeArrow,
				fontBorderColor:0x002932,
				countText:"",
				fontSize:28,
				iconScale:0.95,
				radius:30,
				textAlign:'left',
				autoSize:'left',
				widthButton:230
			});
			
			bodyContainer.addChild(upgradeBttn);
			upgradeBttn.x = (settings.width - upgradeBttn.width) / 2;
			upgradeBttn.y = settings.height - upgradeBttn.height + 55;
			upgradeBttn.textLabel.x  = (upgradeBttn.width - upgradeBttn.textLabel.width) / 2 - 5;
			upgradeBttn.coinsIcon.x = upgradeBttn.textLabel.x + upgradeBttn.textLabel.width + 5;
			upgradeBttn.coinsIcon.smoothing = true;
			
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
		private function onUpgradeAction(obj:Object = null, count:int = 0):void
		{
			settings.target.upgradeEvent(settings.target.info.devel.obj[settings.target.level + 1], count);
			close();
		}
		override public function drawExit():void {
			super.drawExit();
			
			exit.x = settings.width - exit.width + 12;
			exit.y = -12;
		}
		private function addSlider():void
		{
			capasityBar = Window.backingShort(300, "prograssBarBacking3");
			capasityBar.x = 5;
			capasityBar.y = -5;
			Window.slider(capasitySlider, 60, 60, "yellowProgBarPiece", true, 280);
			
			bodyContainer.addChild(capasitySprite);
			
			
			capasitySprite.mouseChildren = false;
			capasitySprite.addChild(capasityBar);
			capasitySprite.addChild(capasitySlider);
			
			capasitySlider.x = 15; capasitySlider.y = 1;
			
			capasitySprite.x = settings.width / 2 - capasityBar.width / 2; 
			capasitySprite.y = settings.height - capasitySprite.height - 70;
			
			updateCapasity(settings.capasity, settings.totalCapacity);
		}
		
		public function updateCapasity(currValue:int, maxValue:int):void
		{
			Window.slider(capasitySlider, currValue, maxValue, "yellowProgBarPiece", true, 280);
		}
		
		private var _capasityLabel:TextField;
		public function drawDescription():void 
		{
			Load.loading(Config.getIcon(App.data.storage[2].type, App.data.storage[2].preview), onLoadIcon);
		}
		
		private function onLoadIcon(obj:Object):void 
		{
			var container:Sprite = new Sprite();
			
			var efirIcon:Bitmap = new Bitmap(obj.bitmapData);
			efirIcon.scaleX = efirIcon.scaleY = 0.42;
			efirIcon.smoothing = true;
			container.addChild(efirIcon);
			
			var shadowFilter:DropShadowFilter = new DropShadowFilter(1,90,0x453059,1,2,4,2,1);
			efirIcon.filters = [shadowFilter];	
			
			_capasityLabel = Window.drawText(Locale.__e(String(settings.capasity) + "/" + String(settings.totalCapacity)),{
					fontSize:32,
					autoSize:"left",
					textAlign:"center",
					multiline:true,
					color:0xffffff,
					borderColor:0x775002
				});
			container.addChild(_capasityLabel);
			_capasityLabel.x = efirIcon.width + 6;
			_capasityLabel.y = 5;
			
			
			bodyContainer.addChild(container);
			
			container.x = (settings.width - container.width) / 2;
			container.y = settings.height - container.height - 130;
		}
		
	}

}