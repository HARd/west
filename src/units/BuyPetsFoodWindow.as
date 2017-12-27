package units {
	
	import adobe.utils.CustomActions;
	import buttons.ImageButton;
	import com.greensock.TweenMax;
	import core.Load;
	import core.Size;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.text.TextField;
	import ui.BitmapLoader;
	import ui.UserInterface;
	import units.Techno;
	import units.Ttechno;
	import wins.elements.PurchaseItem;
	import wins.elements.ShopItem;
	import wins.InfoWindow;
	import wins.SimpleWindow;
	import wins.Window;
	import wins.Paginator;
	import core.Post;
	
	public class BuyPetsFoodWindow extends Window {
		
		public var items:Array = new Array();
		public var handler:Function; 
		private var find:int = 0;
		private var down_devider:Bitmap;
		private var currencyLabels:Array = [];
		private var currencies:Array = [];
		
		private var helpBttn:ImageButton;
		
		public function BuyPetsFoodWindow(settings:Object = null) {
			var defaults:Object = {
				width: 750,
				height:350,
				hasPaper:true,
				//Покупка нектара
				title:Locale.__e("flash:1382952380240"),
				//titleScaleX:0.76,
				//titleScaleY:0.76,
				hasPaginator:true,
				hasArrows:true,
				hasButtons:false,
				shortWindow:false,
				useText:false,
				hasDescription:false,
				itemsOnPage:3,
				descWidthMarging:0,
				description:Locale.__e("flash:1382952380241"),
				closeAfterBuy:true,
				autoClose:true,
				popup:true,
				borderColor:0xd49848,
				borderSize:2,
				shadowColor:0x553c2f,
				shadowSize:4,
				background:'alertBacking',
				hasTitle:true,
				titleDecorate:true
			};
			
			if (App.user.worldID == Travel.SAN_MANSANO) 
			defaults['background'] = 'goldBacking';
			
			settings.width = 144 + settings.itemsOnPage * 150;
			
			if (settings == null) {
				settings = new Object();
			}
			
			for (var property:* in settings) {
				defaults[property] = settings[property];
			}
			settings = defaults;
			
			if (settings.hasDescription) {
				settings.height += 65;
			}
			
			settings["noDesc"] = settings.noDesc || false;
			
			handler = settings.callback;
			
			if (settings.find != undefined) this.find = settings.find;
			
			settings['content'];
			super(settings);
		}
		
		override public function drawTitle():void {
			titleLabel = titleText( {
				title				: Locale.__e('flash:1478593499474'),
				color				: settings.fontColor,
				multiline			: true,			
				fontSize			: settings.fontSize,				
				textLeading	 		: settings.textLeading,				
				borderColor 		: 0xc09a53,			
				borderSize 			: settings.fontBorderSize,	
				
				shadowBorderColor	: 0x503e32,
				shadowSize			: 2,
				width				: settings.width - 60,
				textAlign			: 'center',
				sharpness 			: 50,
				thickness			: 50,
				border				: true
			});
			titleLabel.x = (settings.width - titleLabel.width) * .5;
			titleLabel.y = -16;
			
			titleContainer.addChild(titleLabel);
			titleContainer.mouseEnabled = false;
			titleContainer.mouseChildren = false;
			//titleLabel.visible = false;
		}
		
		public static function createContent(type:String, params:Object = null):Array {
			var list:Array = new Array();
			var makeGlow:Boolean = false;	
			
			for (var sID:* in App.data.storage) {
				var object:Object = App.data.storage[sID];
				object['sID'] = sID;
				
				if (sID == 3021)
					trace();
				
				if (params != null) {
					var _continue:Boolean = false;
					for (var prop:* in params) {
						if (object[prop] == undefined || object[prop] != params[prop]) {
							_continue = true;
							break;
						}
					}
					if (_continue) {
						continue;
					}
				}
				
				if (sID == 1051) continue;
				
				if (object.type == type && App.user.id == "7584561" || object.type == type && User.inUpdate(sID)) {
					list.push( { sID:sID, order:object.order, glow:makeGlow } );
				}
			}
			
			list.sortOn("order", Array.NUMERIC);
			return list;
		}
		
		override public function dispose():void {
			removeItems();
			App.self.removeEventListener(AppEvent.ON_CHANGE_STOCK, onStockChange);
			super.dispose();
		}
		
		public function removeItems():void {
			for (var i:int = 0; i < items.length; i++) {
				if (items[i] != null) {
					items[i].dispose();
					items[i] = null;
				}
			}
			items.splice(0, items.length);
		}
		
		public function drawDescription():void {
			var up_devider:Bitmap = new Bitmap(Window.textures.dividerLine);
			up_devider.x = 78;
			up_devider.y = 30;
			up_devider.width = settings.width - 160;
			up_devider.alpha = 0.6;
			
			var bgW:Bitmap = Window.backing(up_devider.width, 54, 50, 'fadeOutWhite');
			//bgW.alpha = 0.3;
			bgW.x = (settings.width - bgW.width) / 2;
			bgW.y = up_devider.y;
			//bodyContainer.addChild(bgW);
			
			bodyContainer.addChild(up_devider);
			
			down_devider = new Bitmap(Window.textures.dividerLine);
			down_devider.x = up_devider.x;
			down_devider.width = up_devider.width;
			down_devider.y = up_devider.y + 50;
			down_devider.alpha = 0.6;
			bodyContainer.addChild(down_devider);
			
			var descSize:int = 24;
			do
			{
				var descriptionLabel:TextField = drawText(settings.description, {
					fontSize:descSize,
					autoSize:"left",
					textAlign:"center",
					multiline:true,
					color:0x592c05,
					border:false
					//wrap:true,
					//width:settings.width - 160
				});
				descSize -= 1;
			} while (descriptionLabel.textWidth > settings.width - 120)
			
			//descriptionLabel.width = settings.width - 60;
			descriptionLabel.x = (settings.width - descriptionLabel.width) / 2;
			descriptionLabel.y = up_devider.y + 15;
			bodyContainer.addChild(descriptionLabel);
		}
		
		private var descriptionLabel:TextField;
		private var currency:int;
		
		private var currencyLabel:TextField;
		private var currencyLabel2:TextField;
		
		override public function drawBody():void {
			if (settings.useText) {
				descriptionLabel = drawText(settings.description, {
					fontSize:24,
					autoSize:"center",
					textAlign:"center",
					multiline:true,
					color:0xffffff,
					borderColor:0x7a4b1f
				});
				descriptionLabel.wordWrap = true;
				descriptionLabel.width = settings.width - 60 + settings.descWidthMarging;
				if (settings.title == "Фури") {
					descriptionLabel.x = (settings.width - descriptionLabel.width) / 2 + 50;
				} else {
					descriptionLabel.x = (settings.width - descriptionLabel.width) / 2;
				}
				
				descriptionLabel.y = -8;
				
				bodyContainer.addChild(descriptionLabel);
				settings.height += descriptionLabel.textHeight - 18;
			}
			
			//var titleText:TextField = drawText(settings.title, {
				//color				: 0xffffff,
				//multiline			: settings.multiline,			
				//fontSize			: 46,
				//textLeading	 		: settings.textLeading,	
				//border				: true,
				//borderColor 		: 0xc4964e,			
				//borderSize 			: 4,	
				//shadowColor			: 0x503f33,
				//shadowSize			: 4,
				//width				: settings.width,
				//textAlign			: 'center',
				//sharpness 			: 50,
				//thickness			: 50
			//});
			//titleText.y = -35;
			//bodyContainer.addChild(titleText);
			
			var help:Boolean = true;
			
			currency = 0;
			currencies = [];
			var bitmaps:Array = [];
			if (settings.content.length > 0) {
				for (var j:int = 0; j < settings.content.length; j++) {
					var elem:int = App.data.storage[settings.content[j].sID].out;
					if (elem == 0) continue;
					if (elem == Stock.VAUCHER) help = true;
					if ((currencies.length == 0 && elem != Techno.TECHNO && elem != Ttechno.TECHNO && elem != Techno.ETERNAL_TECHNO && elem != Stock.ENERGY) || (currencies.length != 0 && !containsElement(currencies,elem))){
						currencies.push(elem);
					}
				}
			}
			if (currencies.length > 0) {
				var contBack:Sprite = new Sprite();
				bodyContainer.addChild(contBack);
				
				var back:Bitmap = new Bitmap();
				var back2:Bitmap = new Bitmap();
				
				var contentSprite:Sprite = new Sprite();
				contBack.addChild(contentSprite);
				
				var text:TextField = drawText(Locale.__e('flash:1425978184363'), {
					color:      	0xffe641,
					borderColor: 	0x804d32,
					fontSize:		28,
					textAlign:		'left'
				});
				contentSprite.addChild(text);
				
				var text2:TextField = drawText(Locale.__e('flash:1479196824909'), {
					color:      	0xffe641,
					borderColor: 	0x804d32,
					fontSize:		28,
					textAlign:		'left',
					width:100
				});
				contentSprite.addChild(text2);
				
				var Xs:int = 80;
				for (var i:int = 0; i < currencies.length; i++) {
					
					
					/*Load.loading(Config.getIcon(App.data.storage[currencies[i]].type, App.data.storage[currencies[i]].preview), function(data:Bitmap):void {
						var currencyIco:Bitmap = new Bitmap(new BitmapData(60,60,true,0));
						currencyIco.bitmapData.draw(data, new Matrix(0.5, 0, 0, 0.5));
						Size.size(currencyIco, 36, 36);
						currencyIco.smoothing = true;
						currencyIco.y = 5;
						contentSprite.addChild(currencyIco);
						
						bitmaps.push(currencyIco);
						
						if (bitmaps.length == currencies.length) {
							for (var s:int = 0; s < bitmaps.length; s++) {
								bitmaps[s].x = text.textWidth + 13 + Xs * s;
							}
						}
					});*/
					
					var labelSettings:Object =  {
						color:      	0xfffffd,
						borderColor: 	0x7c3f06,
						fontSize:		36
					};
					currencyLabel = drawText(String(App.user.stock.count(currencies[i])), labelSettings);
					currencyLabel.x = text.textWidth + 55 + Xs * i;
					currencyLabel.y += 10;
					contentSprite.addChild(currencyLabel);
					
					var icon:BitmapLoader = new BitmapLoader(currencies[i], 36, 36);
					icon.x = text.x + text.textWidth + 15;
					icon.y = 10;
					contentSprite.addChild(icon);
					
					if (i == currencies.length - 1) {
						var w:int = 40;
						if (currencies[0] == 2196) w = 100;
						back = Window.backing(text.textWidth + Xs * currencies.length + w + 35, 60, 50, 'itemBacking');
						
						contBack.addChildAt(back, 0);
						contBack.x = settings.width / 2 - contBack.width;
						contBack.y = settings.height - contBack.height * 1.5;
						text.x = back.x + 5;
						text.y = (back.height - text.textHeight ) / 2;
						
						contentSprite.x = (contBack.width - (text.textWidth + Xs * currencies.length)) / 2 - 15;
						App.self.addEventListener(AppEvent.ON_CHANGE_STOCK, onStockChange);
						
						back2 = Window.backing(text.textWidth + Xs * currencies.length + w + 20 + 35, 60, 50, 'itemBacking');
						contBack.addChildAt(back2, 0);
						back2.x = back.width + 10;
						text2.x = back2.x - 10;
						text2.y = (back2.height - text2.textHeight ) / 2;
						
						currencyLabel2 = drawText(String(App.user.pet.energy), labelSettings);
						currencyLabel2.x = text2.x + text2.textWidth + 55 + Xs * i;
						currencyLabel2.y += 10;
						contentSprite.addChild(currencyLabel2);
						
						var icon2:Bitmap = new Bitmap(Window.texture("petEnergyIcon"));
						icon2.x = text2.x + text2.textWidth + 5;
						icon2.y = 10;
						contentSprite.addChild(icon2);
					}
				}				
			}
			
			if (settings.hasDescription) {
				drawDescription();
			}
			
			if (help) {
				helpBttn = drawHelp();
				helpBttn.x = exit.x - helpBttn.width;
				helpBttn.y = exit.y + 20;
				helpBttn.addEventListener(MouseEvent.CLICK, onHelpEvent);
				bodyContainer.addChild(helpBttn);
			}
			
			createItems();
			contentChange();
			
			function containsElement(arr:Array, element:int):Boolean {
				for (var i:int = 0; i < arr.length; i++) {
					if (arr[i] == element && element != Techno.TECHNO && element != Techno.ETERNAL_TECHNO && element != Stock.ENERGY) return true;
				}
				return false;
			}
			
			//function onLoadBitmap(data:Object
		}
		
		public function onHelpEvent(e:MouseEvent = null):void {
			new InfoWindow({qID:'pet_house'}).show();
		}
		
		private function onStockChange(e:AppEvent):void {
			for (var i:int = 0; i < currencyLabels.length; i++) {
				currencyLabels[i].text = String(App.user.stock.count(currencies[i]));
			}
		}
		
		override public function drawArrows():void {
			//if(items.length){
				paginator.drawArrow(bottomContainer, Paginator.LEFT,  0, 0, { scaleX: -0.8, scaleY:0.8 } );
				paginator.drawArrow(bottomContainer, Paginator.RIGHT, 0, 0, { scaleX:0.8, scaleY:0.8 } );
				
				var y:int = (settings.height - paginator.arrowLeft.height) / 2;
				if (settings.title == "Фури") {
					paginator.arrowLeft.x = paginator.arrowLeft.width - 77 + 50;
					paginator.arrowRight.x = settings.width - paginator.arrowRight.width + 25 + 50;
				} else {
					paginator.arrowLeft.x = paginator.arrowLeft.width - 77;
					paginator.arrowRight.x = settings.width - paginator.arrowRight.width + 25;
				}
				
				paginator.arrowLeft.y = y;
				paginator.arrowRight.y = y;
			//}
		}
		
		override public function contentChange():void {
			for (var i:int = 0; i < items.length; i++) {
				items[i].visible = false;
			}
			
			var itemNum:int = 0
			var yPos:int = 40; 
			
			if (settings.useText) {
				yPos = descriptionLabel.y + descriptionLabel.textHeight + 10;
			}
			
			if (settings.hasDescription) {
				yPos = down_devider.y + 35;
			}
			
			if(items.length) {
				for (i = paginator.startCount; i < paginator.finishCount; i++) {
					items[i].y = 10 + yPos;
					if (settings.title == "Фури") {
						items[i].x = 49 + itemNum * items[i].bgWidth + 10*itemNum + 50;
					} else {
						items[i].x = 72 + itemNum * items[i].bgWidth + 5 * itemNum;
					}
					
					itemNum++;
					items[i].visible = true;
				}
			}
		}
		
		public function feedPet(sid:int, amount:int):void
		{
			PetHouse.feedPet(sid, amount, updateViews);
		}
		
		public function updateViews():void
		{
			for (var i:int = 0; i < currencies.length; i++) {
			currencyLabel.text = String(App.user.stock.count(currencies[i]));
			}
			
			createItems();
			contentChange();
		}
		
		public function createItems():void {
			var glow:Boolean = false;
			
			for (var j:int = 0; j < items.length; j++) {
				bodyContainer.removeChild(items[j]);
				items[i].dispose();
			}
			items = [];
			settings.content.sortOn("order");
			for (var i:int = 0; i < settings.content.length; i++) {
				if (App.data.storage[settings.content[i].sID].out == find) glow = true;
				var item:PetFoodPurchaseItem = new PetFoodPurchaseItem(settings.content[i].sID, handler, this, i, glow, settings.shortWindow, settings.noDesc, feedPet);
				item.visible = false;
				bodyContainer.addChild(item);
				items.push(item);
				glow = false;
			}
			sortItems();
			
			/*if (App.data.storage[settings.content[0].sID].out == Stock.SILVER_COIN) {
				titleLabel.x += 25;
			}*/
		}
		
		private function sortItems():void {
			
			var arr:Array = [];
			for ( var i:int = 0; i < items.length; i++ ) {
				if (items[i].doGlow) {
					arr.push(items[i]);
					items.splice(i, 1);
					i--;
				}
			}
			for ( i = 0; i < items.length; i++ ) {
				arr.push(items[i]);
			}
			items.splice(0, items.length);
			items = arr;
		}
		
		public function set callback(handler:Function):void {
			this.handler = handler;
		}
		
		public function blokItems(value:Boolean):void {
			var item:*;
			if (value)	for each(item in items) item.state = Window.ENABLED;
			else 		for each(item in items) item.state = Window.DISABLED;
		}
	}
}