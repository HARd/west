package wins.actions 
{
	import buttons.Button;
	import core.Load;
	import core.Log;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import wins.elements.ContentManager;
	import wins.elements.RibbonItem;
	import wins.elements.TimerUnit;
	import wins.AddWindow;
	import wins.Window;
	import wins.LuckyBagWindow;
	
	/**
	 * ...
	 * @author ...
	 */
	public class AnySalesWindow extends AddWindow 
	{
		public static const DECOR:uint = 1,
							SALES:uint = 2,
							LIMITED:uint = 3,
							UNIQUE:uint = 4,
							THEMATIC:uint = 5,
							PACK:uint = 6;
		
		public var ribbon:RibbonItem;
		
		private var itemsArr:Array = [];
		private var mode:uint = DECOR;
		private var thematicTitleLabel:TextField;
		private var thematicTitleLabel2:TextField;
		public var title:String = Locale.__e('flash:1382952380262');
		private var timer:TimerUnit;
		private var contentManager:ContentManager;
		public var bulkID:*;
		private var descriptionLucky:TextField;
		private var openBagBttn:Button;
		
		public function get itemType():String {
			switch(mode) {
				case DECOR:
					return 'DecorItem';
					break;
				case PACK:
					return 'PackItem';
					break;
				case THEMATIC:
					return 'BigSaleItem';
					break;
			}
			return 'DecorItem';
		}
		
		public function AnySalesWindow(settings:Object=null) 
		{			
			if (settings == null) {
				settings = new Object();
			}
			mode = settings.hasOwnProperty('mode')?settings.mode:DECOR;
			if(settings.hasOwnProperty('action')){
				action = settings.action;
				if (mode == THEMATIC){
					action.id = settings.sID;
					title =  action.title;
				}
			}
			
			settings['width'] = int(mode == DECOR) * 720 + 
								int(mode == PACK) * 645 +
								int(mode == THEMATIC) * 625;
								
			settings['height'] = int(mode == DECOR) * 640 +
								 int(mode == PACK) * 545 +
								 int(mode == THEMATIC) * 500;
								
			settings['title'] = Locale.__e('flash:1382952379996');//title;
			settings['hasTitle'] = (mode != DECOR) && (mode != PACK) && (mode != THEMATIC);
			settings['hasPaginator'] = true;
			settings['hasButtons'] = true;
			settings['hasExit'] = true;
			settings['fontColor'] = 0xffffff;
			settings['fontSize'] = 52;
			settings['fontBorderColor'] = 0xb58255;
			settings['shadowBorderColor'] = 0x342411;
			settings['fontBorderSize'] = 4;
			settings['promoPanel'] = true;
			settings['itemsOnPage'] = int(mode == DECOR) * 4 +
										int(mode == PACK) * 3 +
										int(mode == THEMATIC) * 3;
			
			bulkID = settings.pID;
			
			//action.type = 1;
			if (mode == THEMATIC && action.type == 1) {
				settings['height'] = int(mode == THEMATIC) * 540;
				settings['title'] = Locale.__e('flash:1452848012209');
			}
			
			for (var itemW:* in action.items) {
				if ([1628, 1629, 1630].indexOf(int(action.items[itemW].sID)) != -1) {
					settings['title'] = action.title;
				}
			}
			
			super(settings);
			
			var fixArr:Array = [];
			if(action && action.hasOwnProperty('items')){
			for (var item:* in action.items) {
				if ([360,402,461].indexOf(int(item)) != -1) {
					fixArr.push( { sid:item } );
				} else {
					itemsArr.push( { sid:item } );
				}
			}}
			if (mode == PACK) {
			for (var sid:* in App.data.bulks[bulkID].items) {
				itemsArr.push({_itemSid:App.data.bulks[bulkID].items[sid], bulkID:bulkID});
			}}
			if (mode == THEMATIC) {
				itemsArr = initBigsaleContent(action.items);
			}
			var cols:int = int(mode == DECOR) * 2 +
							int(mode == PACK) +
							int(mode == THEMATIC) * 3;
			
			itemsArr.sortOn('sid', Array.NUMERIC | Array.DESCENDING);
			if (fixArr.length != 0) {
				var buf:Array = fixArr.concat(itemsArr);
				itemsArr = buf;
			}
			if (mode == PACK) {
				itemsArr.sortOn('_itemSid', Array.NUMERIC | Array.DESCENDING);
			}
			contentManager = new ContentManager( { from:0, to:settings['itemsOnPage'],cols:cols, content:itemsArr, itemType:itemType, margin:10 + int(mode == PACK) * 35 } );
		}
		
		override public function drawBackground():void
		{
			background = backing2(settings.width, settings.height, 150, "stockBackingTopWithoutSlate","stockBackingBot");
			switch(mode) {
				case DECOR:
					background = backing2(settings.width, settings.height, 150, "stockBackingTopWithoutSlate","stockBackingBot");
				break;
				case PACK:
					background = backing(settings.width, settings.height, 150, "alertBacking");
				break;
				case THEMATIC:
					var mainBg:Bitmap = backing(settings.width, settings.height, 150, "alertBacking");
					var bgW:int = 480;
					var bgH:int = 195;
					var bgSprite:Sprite = new Sprite();
					bgSprite.addChild(mainBg);
					var devider1:Bitmap = new Bitmap(Window.textures.dividerLine);
					devider1.width = bgW;
					devider1.x = 70;
					devider1.y = 160;
					if (action.type == 1) {
						devider1.y = 190;
					}
					devider1.alpha = 0.4;
					bgSprite.addChild(devider1);
					var devider2:Bitmap = new Bitmap(Window.textures.dividerLine);
					devider2.width = bgW;
					devider2.x = devider1.x;
					devider2.y = devider1.y + bgH - devider2.height + 5;
					devider2.scaleY = -1;
					devider2.alpha = 0.4;
					bgSprite.addChild(devider2);
					background = new Bitmap(new BitmapData(settings.width, settings.height, true, 0xffffff));
					background.bitmapData.draw(bgSprite);
				break;
			}
			layer.addChild(background);
		}
		
		override public function drawBody():void
		{
			paginator.visible = mode == THEMATIC;
			paginator.itemsCount = itemsArr.length;
			paginator.onPageCount = settings['itemsOnPage'];
			paginator.update();
			bodyContainer.addChild(contentManager);
			if(mode == THEMATIC)
				drawThematicTitle();
			contentChange();
			drawRibbon();
			drawTime();
			setCoords();
			
			if (mode == THEMATIC) {
				for (var item:* in action.items) {
					if ([1628, 1629, 1630].indexOf(int(action.items[item].sID)) != -1) {
						Load.loading(Config.getImage('content', 'TimerEgerPic'), function(data:Bitmap):void {
							var imageEger:Bitmap = new Bitmap(data.bitmapData);
							imageEger.x = 40;
							imageEger.y = -20;
							bodyContainer.addChildAt(imageEger, 1);
						});
						return;
					} 
				}
				Load.loading(Config.getImage('level', 'LevelUpAnimalsLeft'), function(data:Bitmap):void {
					var imageLeft:Bitmap = new Bitmap(data.bitmapData);
					imageLeft.x = - imageLeft.width + 90;
					imageLeft.y = settings.height - imageLeft.height;
					bodyContainer.addChildAt(imageLeft, bodyContainer.numChildren - 1);
				});
				
				Load.loading(Config.getImage('level', 'LevelUpAnimalsRight'), function(data:Bitmap):void {
					var imageRight:Bitmap = new Bitmap(data.bitmapData);
					imageRight.x = settings.width - 70;
					imageRight.y = settings.height - imageRight.height;
					bodyContainer.addChildAt(imageRight, bodyContainer.numChildren - 1);
				});
			}
		}
		
		public function drawThematicTitle():void 
		{
			thematicTitleLabel = Window.drawText(settings.title, {
				color				: 0xffffff,
				multiline			: true,
				fontSize			: 36,
				borderColor 		: 0xd49848,
				borderSize 			: 4,
				textAlign			: 'center',
				border				: true,
				shadowColor			: 0x553c2f,
				shadowSize			: 4
			});
			thematicTitleLabel.width = thematicTitleLabel.textWidth + 6;
			thematicTitleLabel.x = (settings.width - thematicTitleLabel.width) / 2 + 50;
			thematicTitleLabel.y = 60;		
			
			if (action.type == 1) {
				thematicTitleLabel.y = 50;	
				
				descriptionLucky = Window.drawText(Locale.__e('flash:1452787054872'), {
					width		:360,
					fontSize	:22,
					textAlign	:"center",
					autoSize	:"center",
					color		:0x6e492f,
					borderColor	:0x844e28,
					multiline	:true,
					wrap		:true,
					border		:false
				});
				
				descriptionLucky.x = settings.width / 2 + backgroundContainer.x - descriptionLucky.width / 2 + 70;
				descriptionLucky.y = 98;
				
				var openBagBttnSettings:Object = {
					width:150,
					height:42,
					fontSize:28,
					caption:Locale.__e("flash:1452787076489"),
					x:settings.width - 150 - 160,
					y:145,
					callback:onOpenBag,
					addBtnContainer:false,
					addLogo:false
				};
				
				bodyContainer.addChild(descriptionLucky);
				
				drawButton(openBagBttnSettings);
			}
			
			for (var item:* in action.items) {
				if ([1628, 1629, 1630].indexOf(int(action.items[item].sID)) != -1) {
					thematicTitleLabel.x += 25;
					thematicTitleLabel.y -= 25;
					//thematicTitleLabel.text = action.title;
					var descriptionWorkers:TextField = Window.drawText(Locale.__e('flash:1456237951209'), {
						width		:300,
						fontSize	:24,
						textAlign	:"center",
						autoSize	:"center",
						color		:0x6e492f,
						borderColor	:0x844e28,
						multiline	:true,
						wrap		:true,
						border		:false
					});
					
					descriptionWorkers.x = settings.width / 2 + backgroundContainer.x - descriptionWorkers.width / 2 + 75;
					descriptionWorkers.y = 85;
					
					bodyContainer.addChild(descriptionWorkers);
					break;
				} 
			}
			
			drawMirrowObjs('titleDecRose', thematicTitleLabel.x + 24, thematicTitleLabel.x + thematicTitleLabel.width - 21, thematicTitleLabel.y + 4, true, true, false);
			
			bodyContainer.addChild(thematicTitleLabel);
			
			/*if (['11','12','13','14','15'].indexOf(settings.sID) != 0) {
				thematicTitleLabel2 = Window.drawText(Locale.__e('flash:1434361671615'), {
					color				: 0xffffff,
					multiline			: true,
					fontSize			: 42,
					borderColor 		: 0xd49848,
					borderSize 			: 4,
					textAlign			: 'center',
					border				: true,
					shadowColor			: 0x553c2f,
					shadowSize			: 4
				});
				thematicTitleLabel2.x = (settings.width - thematicTitleLabel2.width) / 2 + 65;
				thematicTitleLabel2.y = 100;
				thematicTitleLabel2.width = thematicTitleLabel2.textWidth + 5;
				bodyContainer.addChild(thematicTitleLabel2);
			}*/
		}
		
		private function onOpenBag (e:MouseEvent = null):void {
			new LuckyBagWindow({ 
				popup: true,
				items: App.data.storage[1425].items				
			}).show();
		}
		
		private function drawRibbon():void {
			/*title:Locale.__e('flash:1382952380262');
			title:Locale.__e('flash:1424964186545');*/
			if (mode == PACK) {
				ribbon = new RibbonItem( { title:title, width:settings['width'], hasDescription:true, description:Locale.__e('flash:1393582651596') } );
			} else if (mode == THEMATIC) {
				//none
			} else {
				ribbon = new RibbonItem( { title:title, width:settings['width'] } );
			}
			
			if(mode != THEMATIC)
				bodyContainer.addChild(ribbon);
			//ribbon.background.visible = mode != THEMATIC;
		}
		
		private function setCoords():void {
			if (mode != THEMATIC) {
				ribbon.y = int(mode == DECOR) * 10 +
							int(mode == PACK) * ( -25);
			}
			
			contentManager.x = int(mode == DECOR) * 50 +
								int(mode == PACK) * 75 +
								int(mode == THEMATIC) * 75;
			contentManager.y = int(mode == DECOR) * 115 +
								int(mode == PACK) * 115 +
								int(mode == THEMATIC) * 180;
								
			if (mode == THEMATIC && action.type == 1) {
				contentManager.y = int(mode == THEMATIC) * 210;
			}
								
			timer.x = int(mode == DECOR) * -10 +
						int(mode == PACK) * (-10) +
						int(mode == THEMATIC) * 70;
			timer.y = int(mode == DECOR) * 45 +
						int(mode == PACK) * 10 +
						int(mode == THEMATIC) * 90;
			exit.x += int(mode == DECOR) * 20 +
						int(mode == PACK) * 50 +
						int(mode == THEMATIC) * 0;
			exit.y += int(mode == DECOR) * 10 +
						int(mode == PACK) * (-25) +
						int(mode == THEMATIC) * 0;
		}
		
		private function drawTime():void
		{
			timer = new TimerUnit( {width:140,height:60,backGround:'glow', time:{started:action.time, duration:action.duration} } );
			bodyContainer.addChild(timer);
			timer.start();
		}
		
		override public function contentChange():void {
			contentManager.update(paginator.startCount, paginator.finishCount);
			settings.page = paginator.page;
			paginator.visible = paginator.itemsCount != paginator.onPageCount;
		}
		
		private function setPaginatorCount():void
		{
			paginator.itemsCount = itemsArr.length;
		}
		
		override public function drawArrows():void {
			super.drawArrows();
			paginator.x = (settings.width - paginator.width) / 2 - 30;
			paginator.y = settings.height - 65;
		}
		
		private function initBigsaleContent(data:Object):Array
		{
			var result:Array = [];
			for (var id:* in data)
				result.push({id:id, sID:data[id].sID, count:data[id].c, order:data[id].o, price_new:data[id].pn, price_old:data[id].po,window:this});
			
			result.sortOn('order', Array.NUMERIC);
			return result;
		}
		
	}
}