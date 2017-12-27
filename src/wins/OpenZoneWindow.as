package wins {
	
	import buttons.Button;
	import buttons.MoneyButton;
	import core.Load;
	import core.Numbers;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import units.Efloors;
	import units.Rbuilding;
	import wins.Window;
	
	public class OpenZoneWindow extends Window {
		
		private const LEFT_MARGIN:int = 60;
		private const ITEM_WIDTH:int = 160;
		
		private var upgradeBttn:Button;
		private var boostBttn:MoneyButton;
		
		public var items:Vector.<MaterialItem> = new Vector.<MaterialItem>;
		
		private var requires:Object;
		private var onUpgradeZoneGuide:Function;
		private var onBuild :Function;
		private var onBoostZoneGuide:Function;
		private var stageLabel:TextField;
		
		public function OpenZoneWindow(settings:Object = null):void {
			if (settings == null) settings = { };
			settings['width'] = settings['width'] || 560;
			settings['height'] = settings['height'] || 395;
			settings['title'] = settings['title'] || Locale.__e('flash:1424098500433');
			settings['hasPaginator'] = true;
			settings['hasButtons'] = false;
			
			requires = settings['requires'] || { };
			onUpgradeZoneGuide = settings['onUpgrade'];
			onBuild = settings['onBuild'];
			onBoostZoneGuide = settings['onBoost'];
			
			if (!settings.hasOwnProperty('target')) {
				var cnt:int = 0;
				for (var s:* in requires) {
					if (App.data.storage[s].type == 'Zones') continue;
					cnt++;
				}
				settings['width'] = LEFT_MARGIN * 2 + cnt * ITEM_WIDTH;
			} else {
				settings['width'] = LEFT_MARGIN * 2 + Numbers.countProps(requires) * ITEM_WIDTH;
			}
			//if (settings['width'] < 600) settings['width'] = 600;
			
			var testDescLabel:TextField = drawText(settings['description'], {
				width:			settings.width - (LEFT_MARGIN + 20) * 2,
				color:			0,
				borderColor:	0,
				textAlign:		'center',
				fontSize:		24,
				multiline:		true,
				wrap:			true
			});
			settings['contentMarginY'] = 65 + testDescLabel.height;
			settings['height'] += testDescLabel.height;
			
			settings['content'] = [];			
			settings['content'].push(settings.requires);
			if (settings.hasOwnProperty('additionalPrice')) {
				settings['content'].push(settings.additionalPrice);
			}
			
			super(settings);
			
			App.self.addEventListener(AppEvent.ON_CHANGE_STOCK, onChangeStock);
		}
		
		override public function drawTitle():void 
		{
			titleLabel = titleText( {
				title				: settings.title,
				color				: 0xffffff,
				multiline			: settings.multiline,			
				fontSize			: 48,				
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
			titleLabel.y = - 10;
			titleLabel.mouseChildren = titleLabel.mouseEnabled = false;
			headerContainer.addChild(titleLabel);
			headerContainer.y = 0;
			headerContainer.mouseEnabled = false;
		}
		
		override public function drawBody():void {
			stageLabel = Window.drawText(Locale.__e("flash:1382952380004", [settings["level"], settings["totalLevels"]]), {
				color				: 0xfffea5,
				fontSize			: 32,
				borderColor 		: 0x4e2811,
				borderSize 			: 4,
				textAlign			: 'center',
				autoSize			: 'center',
				border				: true,
				shadowColor			: 0x4e2811,
				shadowSize			: 1
			});
			stageLabel.width = stageLabel.textWidth + 5;
			stageLabel.x = (settings.width - stageLabel.width) / 2;
			stageLabel.y = 7;
			
			var bgW1:Bitmap = Window.backing(224, 34, 50, 'fadeOutWhite');
			bgW1.alpha = 0.3;
			bgW1.x = (settings.width - bgW1.width) / 2;
			bgW1.y = 7;
			bodyContainer.addChild(bgW1);
			
			if(settings.hasOwnProperty('level'))
				bodyContainer.addChild(stageLabel);
				
			if (settings.sID == 774) {
				stageLabel.text = Locale.__e('flash:1440771778773');
				bodyContainer.addChild(stageLabel);
			}
			
			var up_devider:Bitmap = new Bitmap(Window.textures.dividerLine);
			up_devider.x = (LEFT_MARGIN + 20);
			up_devider.y = 47;
			up_devider.width = settings.width - (LEFT_MARGIN + 20) * 2;
			up_devider.alpha = 0.6;
			
			var bgW2:Bitmap = Window.backing(up_devider.width, 46, 50, 'fadeOutWhite');
			bgW2.alpha = 0.3;
			bgW2.x = (settings.width - bgW2.width) / 2;
			bgW2.y = up_devider.y;
			bodyContainer.addChild(bgW2);
			
			bodyContainer.addChild(up_devider);
			
			var descLabel:TextField = drawText(settings['description'], {
				width:			up_devider.width,
				color:			0x5b2e04,
				borderColor:	0xfce7d2,
				textAlign:		'center',
				fontSize:		24,
				multiline:		true,
				wrap:			true
			});
			descLabel.x = LEFT_MARGIN + 20;
			descLabel.y = up_devider.y + 10;
			bodyContainer.addChild(descLabel);
			
			var down_devider:Bitmap = new Bitmap(Window.textures.dividerLine);
			down_devider.x = up_devider.x;
			down_devider.width = up_devider.width;
			down_devider.y = int(descLabel.y + descLabel.height + 4);
			down_devider.alpha = 0.6;
			bodyContainer.addChild(down_devider);
			
			//img
			var icon:Bitmap = new Bitmap();
			bodyContainer.addChild(icon);
			if (settings.zoneID) {
				Load.loading(Config.getIcon(App.data.storage[settings.zoneID].type, App.data.storage[settings.zoneID].preview), function(data:Bitmap):void
				{
					icon.bitmapData = data.bitmapData;
					icon.x = -30;
					icon.y = -50;
				});
			}
			
			var upgradeBttnCaption:String = Locale.__e('flash:1382952379890');
			if (settings.hasOwnProperty('target') && settings.target != null && [3195,3196,3197,3198,3179].indexOf (settings.target.sid))
				upgradeBttnCaption = Locale.__e('flash:1481730450868');
			if (settings.zoneID == 114) {
				upgradeBttnCaption = Locale.__e('flash:1428408092399');
			}
			if (settings.zoneID == 115) {
				upgradeBttnCaption = Locale.__e('flash:1428408285691');
			}
			if (settings.sID == 774) {
				upgradeBttnCaption = Locale.__e('flash:1382952379890');
			}
			
			if (settings.hasOwnProperty('target') && (settings.target is Efloors))
				upgradeBttnCaption = Locale.__e('flash:1393580216438');
			
			upgradeBttn = new Button( {
				width:		250,
				height:		62,
				caption:	upgradeBttnCaption
			});
			upgradeBttn.x = (settings.width - upgradeBttn.width) / 2;
			upgradeBttn.y = settings.height - 105;
			upgradeBttn.addEventListener(MouseEvent.CLICK, onUpgrade);
			bodyContainer.addChild(upgradeBttn);
			
			boostBttn = new MoneyButton({
				width:		250,
				height:		62,
				fontSize:	34,
				fontCountSize:34,
				iconScale:	0.9,
				countText:	settings['skipPrice'],
				caption:	Locale.__e('flash:1426069533465')
			});
			boostBttn.x = (settings.width - boostBttn.width) / 2;
			boostBttn.y = settings.height - 98;
			boostBttn.textLabel.x -= 5;
			boostBttn.textLabel.y -= 3;
			//boostBttn.addEventListener(MouseEvent.CLICK, onBoost);
			//bodyContainer.addChild(boostBttn);
			
			if (settings.content.length != 0) {
				paginator.itemsCount = settings.content.length;
				paginator.update();
				paginator.onPageCount = 1;
			}
			
			contentChange();
			//checkState();
		}
		
		private function onUpgrade(e:MouseEvent):void {
			if (upgradeBttn.mode == Button.DISABLED) return;
			
			if (paginator.startCount == 1) {
				settings.openZone(settings.sID, true);
				close();
				blockAll();
				return;
			}
			
			if (onUpgradeZoneGuide != null)
				onUpgradeZoneGuide();
			else if (onBuild != null) {
				onBuild(settings.request);
				close();
			}else if (settings.openZone != null) {
				settings.openZone(settings.sID);
				close();
			}
			
			blockAll();
		}
		
		private function onBoost(e:MouseEvent):void {
			if (boostBttn.mode == Button.DISABLED) return;
			
			if (onBoostZoneGuide != null)
				onBoostZoneGuide(settings.content[paginator.startCount]);
			
			blockAll();
		}
		
		private function onChangeStock(e:AppEvent = null):void {
			checkState();
		}
		
		private function checkState():void {
			var hasItems:Boolean = true;
			if (paginator) {
				for (var s:* in settings.content[paginator.startCount]) {
					if ((settings.content[paginator.startCount][s] is Object)  && settings.hasOwnProperty('target') && (settings.target is Rbuilding)) {
						var count:int = 0;
						for (var sID:* in settings.content[paginator.startCount][s]) {
							count = settings.content[paginator.startCount][s][sID];
						}
						if (App.data.storage[int(sID)].type == 'Zones') continue;
						if (!App.user.stock.check(int(sID), count, true))
							hasItems = false;
					} else {
						if (App.data.storage[int(s)].type == 'Zones') continue;
						if (!App.user.stock.check(int(s), settings.content[paginator.startCount][s], true))
							hasItems = false;
					}
				}
			}
			
			if (opened) {
				if (hasItems) {
					boostBttn.visible = false;
					upgradeBttn.visible = true;
				} else {
					boostBttn.visible = true;
					upgradeBttn.visible = false;
				}
			}
		}
		
		private function blockAll():void {
			upgradeBttn.state = Button.DISABLED;
			boostBttn.state = Button.DISABLED;
		}
		
		override public function contentChange():void {
			if (items) {
				for each(var _item:* in items) {
					bodyContainer.removeChild(_item);
					_item.dispose();
				}
			}
			items = new Vector.<MaterialItem>;
			
			var list:Array = [];
			for (var s:* in settings.content[paginator.startCount]) {
				if ((settings.content[paginator.startCount][s] is Object) && settings.hasOwnProperty('target') && (settings.target is Rbuilding)) {
					var count:int = 0;
					for (var sID:* in settings.content[paginator.startCount][s]) {
						count = settings.content[paginator.startCount][s][sID];
					}
					if (App.data.storage[int(sID)].type == 'Zones') continue;
					list.push( {
						order:int(s),
						sid:int(sID),
						count:count
					});
				}else {
					if (App.data.storage[int(s)].type == 'Zones') continue;
					list.push( {
						order:int(s),
						sid:int(s),
						count:settings.content[paginator.startCount][s]
					});
				}
				list.sortOn('order', Array.NUMERIC);
			}
			
			for (var i:int = 0; i < list.length; i++) {
				var item:MaterialItem = new MaterialItem( {
					sID:list[i].sid,
					need:list[i].count,
					window:this,
					type:MaterialItem.IN,
					backingColor:0xc9cbbe
				});
				item.x = LEFT_MARGIN + 10 + i * ITEM_WIDTH;
				if (list.length == 1) item.x = (settings.width - item.width) / 2;
				item.y = settings.contentMarginY + 15;
				items.push(item);
				item.addEventListener("onContentUpdate", onContentUpdate);
				bodyContainer.addChild(item);
			}
			
			checkState();
		}
		
		private function onContentUpdate(e:WindowEvent):void {
			checkState();
		}
		
		private function clear():void {
			while (items.length) {
				var item:MaterialItem = items.shift();
				item.dispose();
				item = null;
			}
		}
		
		override public function close(e:MouseEvent = null):void {
			clear();
			
			upgradeBttn.removeEventListener(MouseEvent.CLICK, onUpgrade);
			boostBttn.removeEventListener(MouseEvent.CLICK, onBoost);
			App.self.removeEventListener(AppEvent.ON_CHANGE_STOCK, onChangeStock);
			
			super.close(e);
		}
	}		
}