package wins {
	
	import buttons.Button;
	import buttons.ImageButton;
	import core.Load;
	import core.Numbers;
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import units.Mfield;
	
	public class WindowMegaField extends Window {
		
		private static const CLOSE_BUTTON_X_OFFSET:int = 12;
		private static const CLOSE_BUTTON_Y_OFFSET:int = -28;
		
		private static const WINDOW_WIDTH:int = 700;
		private static const WINDOW_HEIGHT:int = 510;
		
		private static const LIST_START_X:int = 55;
		private static const LIST_START_Y:int = 22;
		private static const LIST_INTERVAL_H:int = 5;
		
		private static const SELECTED_ITEM_X:int = 70;
		private static const SELECTED_ITEM_Y:int = 255;
		
		private var _callerMfield:Mfield;
		private var _itemViews:Vector.<PlantItem>;
		
		//private var _viewSelectedItem:SelectedPlantSubview;
		private var _viewGrowingItem:GrowingPlantSubview;
		
		private var plantItems:Array = [];
		
		private var upgradeButton:Button;
		public var plantPaginator:Paginator;
		
		public function WindowMegaField(settings:Object = null, caller:Mfield = null) {
			if (!settings) {
				settings = { };
			}
			
			settings['width'] = WINDOW_WIDTH;
			settings['height'] = WINDOW_HEIGHT;
			settings['hasPaginator'] = true;
			settings['hasArrows'] = true;
			settings['itemsOnPage'] = 1;
			settings['hasButtons'] = false;
			settings['hasTitle'] = true;
			settings['faderAlpha'] = 0.6;
			
			_itemViews = new Vector.<PlantItem>();
			
			_callerMfield = caller;
			
			settings['content'] = [];
			for each (var plant:Object in caller.plants) {
				settings.content.push(plant);
			}
			
			super(settings);
		}
		
		override public function drawBackground():void {
			if (!background) {
				background = new Bitmap();
				layer.addChild(background);
			}
			background.bitmapData = backing2(settings.width, settings.height, 50, "shopBackingTop","shopBackingBot").bitmapData;
		}
		
		override public function drawBody():void {
			exit.x += CLOSE_BUTTON_X_OFFSET;
			exit.y += CLOSE_BUTTON_Y_OFFSET;
			
			content = initContent();
			
			updatePaginator();
			contentChange();
			
			createPlantPaginator();
			onPlantPageChange();
			
			drawFertilizer();
			
			if (_callerMfield && _callerMfield.level >= _callerMfield.totalLevels) return;
			
			var upgradeParams:Object = {
				caption:Locale.__e('flash:1425574338255'),
				bgColor:[0x7bc9f9, 0x60aedf],
				bevelColor:[0xa5ddfb, 0x266fad],
				borderColor:[0xd5c2a9, 0xbca486],
				fontSize:26,
				fontBorderColor:0x40505f,
				shadowColor:0x40505f,
				shadowSize:4,
				width:210,
				height:52
			};
			upgradeButton = new Button(upgradeParams);
			upgradeButton.x = (settings.width - upgradeButton.width) / 2;
			upgradeButton.y = settings.height - upgradeButton.height * 1.5 - 10;
			bodyContainer.addChild(upgradeButton);
			upgradeButton.addEventListener(MouseEvent.CLICK, onUpgradeButtonEvent);	
		}
		
		private var fertCount:TextField;
		private function drawFertilizer():void {
			var backFert:Bitmap = Window.backing(145, 175, 50, 'itemBacking');
			backFert.x = 505;
			backFert.y = SELECTED_ITEM_Y - 30;
			bodyContainer.addChild(backFert);
			
			var fertilizer:Bitmap = new Bitmap();
			bodyContainer.addChild(fertilizer);
			
			var title:TextField = drawText(App.data.storage[Stock.FERTILIZER].title, {
				fontSize:22,
				autoSize:"left",
				textAlign:"center",
				color:			0xffffff,
				borderColor:	0x814f31,
				width:100
			})
			title.x = backFert.x + (backFert.width - title.width) / 2;
			title.y = backFert.y + 10;
			bodyContainer.addChild(title);
			
			fertCount = drawText('x' + String(App.user.stock.count(Stock.FERTILIZER)), {
				fontSize:24,
				autoSize:"left",
				textAlign:"center",
				color:			0xffffff,
				borderColor:	0x814f31,
				width:100
			});
			fertCount.x = backFert.x + backFert.width - fertCount.width - 15;
			fertCount.y = backFert.y + backFert.height - 40;
			bodyContainer.addChild(fertCount);
			
			var addBttn:ImageButton = new ImageButton(Window.texture('interAddBttnGreen'));
			addBttn.x = backFert.x + (backFert.width - addBttn.width) / 2;
			addBttn.y = backFert.y + backFert.height - 20;
			bodyContainer.addChild(addBttn);
			
			addBttn.addEventListener(MouseEvent.CLICK, onAddMoney);
			
			App.self.addEventListener(AppEvent.ON_CHANGE_STOCK, onStockChange);
			
			Load.loading(Config.getIcon(App.data.storage[Stock.FERTILIZER].type, App.data.storage[Stock.FERTILIZER].view), function(data:*):void {
				fertilizer.bitmapData = data.bitmapData;
				fertilizer.smoothing = true;
				fertilizer.x = backFert.x + (backFert.width - fertilizer.width) / 2;
				fertilizer.y = backFert.y + (backFert.height - fertilizer.height) / 2;
			});
		}
		
		private function onAddMoney(e:MouseEvent):void {
			new PurchaseWindow( {
				width:595,
				itemsOnPage:3,
				content:PurchaseWindow.createContent("Boost", {view:'boost_compost'}),
				title:Locale.__e("flash:1406209151924"),
				fontBorderColor:0xd49848,
				shadowColor:0x553c2f,
				shadowSize:4,
				description:Locale.__e("flash:1382952379757"),
				popup: true,
				closeAfterBuy: false,
				callback:function(sID:int):void {
				}
			}).show();
		}
		
		private function onStockChange(e:AppEvent):void 
		{
			fertCount.text = 'x' + String(App.user.stock.count(Stock.FERTILIZER));
		}
		
		private function createPlantPaginator():void {
			plantPaginator = new Paginator(_callerMfield.info.devel.req[_callerMfield.level].c, 1, 9);
			plantPaginator.addEventListener(WindowEvent.ON_PAGE_CHANGE, onPlantPageChange);
			bodyContainer.addChild(plantPaginator);
			drawPlantArrows();
			plantPaginator.update();
		}
		
		private function onPlantPageChange(e:WindowEvent = null):void {
			for each (var plant:SelectedPlantSubview in plantItems) {
				layer.removeChild(plant);
				plant.dispose();
			}
			if (_viewGrowingItem) {
				layer.removeChild(_viewGrowingItem);
				_viewGrowingItem = null;
			}
			plantItems = [];
			
			for (var i:int = plantPaginator.startCount; i < plantPaginator.finishCount; i++) {
				var _viewSelectedItem:SelectedPlantSubview = new SelectedPlantSubview(_callerMfield, this);
				_viewSelectedItem.visible = false;
				layer.addChild(_viewSelectedItem);
				_viewSelectedItem.x = SELECTED_ITEM_X;
				_viewSelectedItem.y = SELECTED_ITEM_Y;
				
				_viewSelectedItem.addEventListener(Event.COMPLETE, onPlantComplete);
				
				plantItems.push(_viewSelectedItem);
				
				if (_callerMfield && _callerMfield.plants[i].plant != null) {
					drawGrowingPlantSubview();
				}
				
				_itemViews[0].dispatchEvent(new Event(Event.SELECT));
			}
		}
		
		private function onUpgradeButtonEvent(e:MouseEvent):void {
			_callerMfield.openConstructWindow();
			close();
		}
		
		private function drawGrowingPlantSubview():void {
			var obj:Object = App.data.storage[_callerMfield.plants[plantPaginator.startCount].plant.sid];
			var itemPrice:Object = getItemPrice(obj);
			for (var sid:* in obj.outs) {
				if ((sid == Stock.COINS || sid == 320) && App.self.getLength(obj.outs) > 1) {
					// nothing
				} else {
					break;
				}
			}
			var plantModel:PlantItemModel = new PlantItemModel(App.data.storage[sid].type, App.data.storage[sid].view, _callerMfield.plants[plantPaginator.startCount].plant.sid, obj.title, itemPrice.count, obj.levelTime, obj.experience, itemPrice.mID, obj.levels);
			_viewGrowingItem = new GrowingPlantSubview(plantModel, _callerMfield, this);
			_viewGrowingItem.x = 50;
			_viewGrowingItem.y = 265;
			layer.addChild(_viewGrowingItem);
			
			_viewGrowingItem.addEventListener(Event.COMPLETE, onHarvestComplete);
		}
		
		private function initContent():Array {
			var result:Array = [];
			var extentions:Array = [];
			
			for (var sID:* in App.data.storage) {
				var item:Object = App.data.storage[sID];
				if (item.type && item.type == "Plant" && item.visible && User.inUpdate(item.sID) && extentions.indexOf(item.sID) == -1) {
					var itemPrice:Object = getItemPrice(item);
					for (var sid:* in item.outs) {
						if ((sid == Stock.EXP || sid == Stock.COINS || sid == 320) && App.self.getLength(item.outs) > 1) {
							// nothing
						} else {
							break;
						}
					}
					if (itemPrice.mID != Stock.COINS) {
						continue;
					}
					if (sID == 2812)
						trace();
					var itemModel:PlantItemModel = new PlantItemModel(App.data.storage[sid].type, App.data.storage[sid].view, sID, item.title, itemPrice.count, item.levelTime, item.experience, itemPrice.mID, item.levels);
					result.push(itemModel);
				}
			}
			
			paginator.onPageCount = 1;
			return result;
		}
		
		/**
		 * Parses item and returns in price and money type
		 * @param	item - item to get it proce
		 * @return object that contains fiels
		 * 			-mID - id of money type
		 * 			-count - count of money
		 */
		private function getItemPrice(item:Object):Object {
			var moneyID:int;
			var moneyCount:int;
			
			if (item.price && Numbers.countProps(item.price) > 0) {
				if (Numbers.firstProp(item.price).key == Stock.COINS) {
					moneyID = Stock.COINS;
					moneyCount = item.price[moneyID];// Numbers.firstProp(item.price).val;
				} else if (Numbers.firstProp(item.price).key == Stock.FANT) {
					moneyID = Stock.FANT;
					moneyCount = item.price[moneyID];;// Numbers.firstProp(item.price).val;
				}
			}
			
			return { mID:moneyID, count:moneyCount };
		}
		
		private function updatePaginator():void {
			paginator.itemsCount = content.length;
			paginator.update();
		}
		
		override public function contentChange():void {
			var numItemViews:int = _itemViews.length;
			var oldItemView:PlantItem;
			for (var i:int = 0; i < numItemViews; i++) {
				oldItemView = _itemViews.shift();
				oldItemView.removeEventListener(Event.SELECT, onItemSelected);
				oldItemView.dispose();
			}
			
			var startX:int = LIST_START_X;
			var startY:int = LIST_START_Y;
			
			var newItemView:PlantItem;
			
			for (var j:int = paginator.startCount; j < paginator.finishCount + 3; j++) {
				newItemView = new PlantItem(content[j], this);
				newItemView.x = startX + _itemViews.length * (newItemView.width + LIST_INTERVAL_H);
				newItemView.y = startY;
				
				_itemViews.push(newItemView);
				
				newItemView.addEventListener(Event.SELECT, onItemSelected);
				
				bodyContainer.addChild(newItemView);
			}
			
			if (paginator.finishCount >= content.length - 3) {
				paginator.arrowRight.visible = false
				return;
			}
		}
		
		override public function show():void {
			super.show();
			_itemViews[0].dispatchEvent(new Event(Event.SELECT));
		}
		
		private function onItemSelected(event:Event):void {
			if (!_callerMfield.plants[plantPaginator.startCount].plant) {
				var selectedItemModel:PlantItemModel = (event.currentTarget as PlantItem).model;
				plantItems[0].updateModel(selectedItemModel);
				plantItems[0].visible = true;
			}
		}
		
		private function onPlantComplete(e:Event):void {
			plantItems[0].visible = false;
			plantItems[0].removeEventListener(Event.COMPLETE, onPlantComplete);
			
			drawGrowingPlantSubview();
		}
		
		private function onHarvestComplete(e:Event):void {
			close(null);
		}
		
		override public function drawArrows():void {
			paginator.drawArrow(bodyContainer, Paginator.LEFT,  0, 0, { scaleX: -1, scaleY:1 } );
			paginator.drawArrow(bodyContainer, Paginator.RIGHT, 0, 0, { scaleX:1, scaleY:1 } );
			
			paginator.arrowLeft.x = -paginator.arrowLeft.width / 2;
			paginator.arrowLeft.y = 80;
			
			paginator.arrowRight.x = settings.width - paginator.arrowRight.width / 2;
			paginator.arrowRight.y = 80;
		}
		
		public function drawPlantArrows():void {
			plantPaginator.drawArrow(bodyContainer, Paginator.LEFT,  0, 0, { scaleX: -1, scaleY:1 } );
			plantPaginator.drawArrow(bodyContainer, Paginator.RIGHT, 0, 0, { scaleX:1, scaleY:1 } );
			
			plantPaginator.arrowLeft.x = -plantPaginator.arrowLeft.width / 2;
			plantPaginator.arrowLeft.y = 280;
			
			plantPaginator.arrowRight.x = settings.width - plantPaginator.arrowRight.width / 2;
			plantPaginator.arrowRight.y = 280;
			
			plantPaginator.x = int((settings.width - plantPaginator.width)/2 - 40);
			plantPaginator.y = int(settings.height - plantPaginator.height - 30);
		}
		
		override public function dispose():void {
			var numPlantItems:int = _itemViews.length;
			
			for (var i:int = 0; i < numPlantItems; i++) {
				_itemViews[i].removeEventListener(Event.SELECT, onItemSelected);
				_itemViews[i].dispose();
			}
			
			if (plantItems.length > 0) {
				for each (var plant:SelectedPlantSubview in plantItems) {
					layer.removeChild(plant);
					plant.dispose();
				}
			}
			
			if (_viewGrowingItem) {
				_viewGrowingItem.removeEventListener(Event.COMPLETE, onPlantComplete);
				_viewGrowingItem.dispose();
			}
			
			super.dispose();
		}
	}
}

import buttons.Button;
import buttons.ImageButton;
import buttons.MoneyButton;
import com.flashdynamix.motion.extras.BitmapTiler;
import com.greensock.easing.Cubic;
import com.greensock.TweenLite;
import core.Load;
import core.Numbers;
import core.Size;
import core.TimeConverter;
import effects.Effect;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.filters.GlowFilter;
import flash.geom.Point;
import flash.text.TextField;
import mx.utils.StringUtil;
import ui.UserInterface;
import units.Mfield;
import wins.Window;
import wins.ProgressBar;

internal class PlantItem extends Sprite {
	
	private static const ITEM_WIDTH:int = 145;
	private static const ITEM_HEIGHT:int = 175;
	private static const ITEM_PADDING:int = 10;
	
	private static const BUTTON_WIDTH:int = 106;
	private static const BUTTON_HEIGHT:int = 40;
	
	private static const PREVIEW_SIZE:int = 105;
	
	private var _model:PlantItemModel;
	private var _window:Window;
	private var _background:Bitmap;
	private var _preloader:Preloader;
	private var _bitmapPreview:Bitmap;
	private var _textTitle:TextField;
	public var _buttonSelect:Button;
	
	public function PlantItem(model:PlantItemModel, window:Window) {
		_model = model;
		
		drawBody();
		drawPreloader();
		drawView();
		drawTitle();
		drawButton();
		
		addEventListener(MouseEvent.MOUSE_OVER, onOver);
		addEventListener(MouseEvent.MOUSE_OUT, onOut);
	}
	
	private function drawPreloader():void {
		_preloader = new Preloader();
		_preloader.x = _background.width * 0.5;
		_preloader.y = _background.height * 0.5;
		addChild(_preloader);
	}
	
	private function drawBody():void {
		_background = Window.backing(ITEM_WIDTH, ITEM_HEIGHT, ITEM_PADDING, "itemBacking");
		addChild(_background);
	}
	
	private function drawView():void {
		_bitmapPreview = new Bitmap();
		addChild(_bitmapPreview);
		
		Load.loading(Config.getIcon(_model.type, _model.previewID), onViewLoadComplete);
	}
	
	private function onViewLoadComplete(data:Bitmap):void {
		if (_preloader.parent == this) {
			removeChild(_preloader);
		}
		
		_bitmapPreview.bitmapData = data.bitmapData;
		Size.size(_bitmapPreview, PREVIEW_SIZE, PREVIEW_SIZE);
		_bitmapPreview.smoothing = true;
		
		_bitmapPreview.x = (_background.width - _bitmapPreview.width) * 0.5;
		_bitmapPreview.y = (_background.height - _bitmapPreview.height) * 0.5;
	}
	
	private function drawTitle():void {
		var textTitleSettings:Object = { 
			fontSize:22,
			autoSize:"left",
			textAlign:"center",
			color:			0xffffff,
			borderColor:	0x814f31,
			width:100
		};
		_textTitle = Window.drawText(_model.title, textTitleSettings);
		_textTitle.x = (_background.width - _textTitle.width) * 0.5;
		_textTitle.y = 10;
		addChild(_textTitle);
	}
	
	private function drawButton():void {
		_buttonSelect = new Button({
			width:BUTTON_WIDTH,
			height:BUTTON_HEIGHT,
			caption:Locale.__e("flash:1382952379978"),
			fontSize:24
		});
		_buttonSelect.x = (_background.width - _buttonSelect.width) * 0.5;
		_buttonSelect.y = _background.height - (_buttonSelect.height * 0.7);
		addChild(_buttonSelect);
		_buttonSelect.addEventListener(MouseEvent.CLICK, onButtonSelectClick);
	}
	
	private function onButtonSelectClick(e:MouseEvent):void {
		dispatchEvent(new Event(Event.SELECT));
	}
	
	private function onOver(e:MouseEvent):void {
		this.filters = [new GlowFilter(0xFFFF00,1, 6, 6, 7)];
	}
	
	private function onOut(e:MouseEvent):void {
		this.filters = [];
	}
	
	public function dispose():void {
		removeChild(_background);
		
		if (_preloader.parent == this) {
			removeChild(_preloader);
		}
		
		if (_bitmapPreview.parent == this) {
			removeChild(_bitmapPreview);
		}
		
		removeChild(_textTitle);
		removeChild(_buttonSelect);
		
		removeEventListener(MouseEvent.CLICK, onButtonSelectClick);
		removeEventListener(MouseEvent.MOUSE_OVER, onOver);
		removeEventListener(MouseEvent.MOUSE_OUT, onOut);
	}
	
	public function get model():PlantItemModel {
		return _model;
	}
}

internal class SelectedPlantSubview extends Sprite {
	
	private static const BACK_WIDTH:int = 255;
	private static const BACK_HEIGHT:int = 190;
	private static const BACK_PADDING:int = 20;
	
	private static const PREVIEW_SIZE:int = 110;
	
	private static const TEXT_TITLE_WIDTH:int = 200;
	private static const TEXT_TITLE_HEIGHT:int = 25;
	
	private static const TEXT_TITLE_X:int = 25;
	private static const TEXT_TITLE_Y:int = 9;
	
	private static const MAX_COUNT:int = 50;
	
	private var _callerMfield:Mfield;
	private var _model:PlantItemModel;
	
	private var _selectedCount:int;
	
	private var _bitmapBackground:Bitmap;
	private var _bitmapCountBack:Bitmap;
	private var _bitmapPreview:Bitmap;
	private var _bitmapCoin:Bitmap;
	private var _bitmapFantasy:Bitmap;
	
	private var _buttonMinus10:Button;
	private var _buttonPlus10:Button;
	
	private var _buttonMinus1:Button;
	private var _buttonPlus1:Button;
	
	private var _textTitle:TextField;
	private var _textCurrentCount:TextField;
	private var _textSelectCount:TextField;
	
	private var _textGrowTime:TextField;
	
	private var _textFullPrice:TextField;
	private var _textFullPriceValue:TextField;
	
	private var _textFantasyCostValue:TextField;
	
	private var _textSelectedCount:TextField;
	private var _bitmapSelectedCountBack:Bitmap;
	
	private var _buttonPlantIt:Button;
	private var win:*;
	
	public function SelectedPlantSubview(caller:Mfield, win:*) {
		_callerMfield = caller;
		this.win = win;
		
		drawBody();
		drawView();
		drawTextFields()
		drawButtons();
	}
	
	private function drawBody():void {
		var circle:Shape = new Shape();
		circle.graphics.beginFill(0xb1c0b9, 1);
		circle.graphics.drawCircle(80, 100, 55);
		circle.graphics.endFill();	
		circle.x -= 7;
		circle.y -= 13;
		addChild(circle);
		
		_bitmapSelectedCountBack = Window.backing(40, 35, 10, "smallBacking");
		_bitmapSelectedCountBack.x = 109;
		_bitmapSelectedCountBack.y = 145;
		addChild(_bitmapSelectedCountBack);
		
		Load.loading(Config.getIcon(App.data.storage[Stock.COINS].type, App.data.storage[Stock.COINS].preview), onMoneyIconLoadComplete);
		Load.loading(Config.getIcon(App.data.storage[Stock.FANTASY].type, App.data.storage[Stock.FANTASY].preview), onBitmapFanatasyLoadComplete)
	}
	
	private function onMoneyIconLoadComplete(data:Bitmap):void {
		if (_bitmapCoin && _bitmapCoin.parent == this) {
			removeChild(_bitmapCoin);
		}
		
		_bitmapCoin = data;
		Size.size(_bitmapCoin, 27, 27);
		_bitmapCoin.smoothing = true;
		
		_bitmapCoin.y = 100;
		
		addChild(_bitmapCoin);
	}
	
	private function onBitmapFanatasyLoadComplete(data:Bitmap):void {
		_bitmapFantasy = data;
		Size.size(_bitmapFantasy, 27, 27);
		_bitmapFantasy.smoothing = true;
		
		if (!_textFullPrice) {
			_bitmapFantasy.x = 345;
		} else {
			_bitmapFantasy.x = _textFullPrice.x + _textFullPrice.textWidth + 8;
		}
		
		_bitmapFantasy.y = 65;
		
		addChild(_bitmapFantasy);
	}
	
	private function drawView():void {
		_bitmapPreview = new Bitmap();
		addChild(_bitmapPreview);
	}
	
	private function drawTextFields():void {
		var textSettings:Object = { 
			width:			TEXT_TITLE_WIDTH,
			height:			TEXT_TITLE_HEIGHT,
			fontSize:		24,
			textAlign:		"center",
			color:			0xffffff,
			borderColor:	0x814f31
		};
		_textTitle = Window.drawText("",textSettings);
		_textTitle.x = TEXT_TITLE_X;
		_textTitle.y = TEXT_TITLE_Y;
		addChild(_textTitle);
		
		var dX:int = 280;
		if (App.lang == 'jp') dX = 255;
		
		textSettings.width = 180;
		textSettings.height = 25;
		textSettings.fontSize = 26;
		textSettings.textAlign = "left";
		textSettings.color = 0xffffff;
		textSettings.borderColor = 0x5a2a11;
		
		_textGrowTime = Window.drawText("", textSettings);
		_textGrowTime.x = dX;
		_textGrowTime.y = 25;
		addChild(_textGrowTime);
		
		textSettings.fontSize = 26;
		textSettings.width = 95;
		_textFullPrice = Window.drawText(Locale.__e("flash:1382952380131"), textSettings);
		_textFullPrice.x = dX;
		_textFullPrice.y = 60;
		addChild(_textFullPrice);
		
		textSettings.fontSize = 28;
		textSettings.width = 105;
		textSettings.height = 30;
		textSettings.color = 0xffffff;
		textSettings.borderColor = 0x5a2a11;
		
		_textFullPriceValue = Window.drawText("", textSettings);
		_textFullPriceValue.x = _textFullPrice.x + _textFullPrice.textWidth + _bitmapCoin.width + 5;
		_textFullPriceValue.y = 100;
		addChild(_textFullPriceValue);
		
		_textFantasyCostValue = Window.drawText("", textSettings);
		_textFantasyCostValue.x = _textFullPrice.x + _textFullPrice.textWidth + _bitmapCoin.width + 5;
		_textFantasyCostValue.y = 60;
		addChild(_textFantasyCostValue);
		
		_bitmapCoin.x = _textFullPrice.x + _textFullPrice.textWidth + 3;
		
		textSettings.fontSize = 36;
		textSettings.width = 90;
		textSettings.height = 40;
		textSettings.color = 0xffffff;
		textSettings.borderColor = 0x814f31;
		textSettings.textAlign = "center";
		
		_textCurrentCount = Window.drawText("1/50", textSettings);
		_textCurrentCount.x = 135;
		_textCurrentCount.y = 70;
		addChild(_textCurrentCount);
		
		textSettings.fontSize = 20;
		textSettings.color = 0xfffbff;
		textSettings.borderColor = 0x614605;
		textSettings.width = 35;
		textSettings.height = 30;
		
		_textSelectedCount = Window.drawText("", textSettings);
		_textSelectedCount.x = 111;
		_textSelectedCount.y = 152;
		addChild(_textSelectedCount);
		
		if (_bitmapCoin) {
			_bitmapCoin.x = _textFullPrice.x + _textFullPrice.textWidth + 3;
		}
		
		if (_bitmapFantasy) {
			_bitmapFantasy.x = _textFullPrice.x + _textFullPrice.textWidth + 8;
		}
	}
	
	private function drawButtons():void {
		var buttonSettings:Object = {
			width:145,
			height:50,
			caption:Locale.__e("flash:1396612366738")
		};
		
		_buttonPlantIt = new Button(buttonSettings);
		_buttonPlantIt.x = 280;
		_buttonPlantIt.y = 140;
		addChild(_buttonPlantIt);
		
		var buttonsBitmap:Bitmap = new Bitmap(BitmapData(UserInterface.textures.optionsBacking));
		
		buttonSettings.width = 35;
		buttonSettings.height = 25;
		buttonSettings.caption = "-10";
		buttonSettings.fontSize = 15;
		buttonSettings.bgColor = [0xC18A65, 0xF3BFA6];
		buttonSettings.textAlign = "center";
		buttonSettings.borderColor = [0xC9C9C9, 0x777A81];
		buttonSettings.textLeading = 0;
		buttonSettings.fontColor = 0xfffbff;
		buttonSettings.fontBorderColor = 0x614605;
		
		_buttonMinus10 = new Button(buttonSettings);
		_buttonMinus10.x = 40;
		_buttonMinus10.y = 150;
		addChild(_buttonMinus10);
		
		buttonSettings.caption = " -1";
		_buttonMinus1 = new Button(buttonSettings);
		_buttonMinus1.x = 75;
		_buttonMinus1.y = 150;
		addChild(_buttonMinus1);
		
		buttonSettings.caption = " +1";
		_buttonPlus1 = new Button(buttonSettings);
		_buttonPlus1.x = 150;
		_buttonPlus1.y = 150;
		addChild(_buttonPlus1);
		
		buttonSettings.caption = "+10"
		_buttonPlus10 = new Button(buttonSettings);
		_buttonPlus10.x = 185;
		_buttonPlus10.y = 150;
		addChild(_buttonPlus10);
		
		_buttonPlantIt.addEventListener(MouseEvent.CLICK, onButtonPlantClick);
		_buttonMinus10.addEventListener(MouseEvent.CLICK, onCounterButtonClick);
		_buttonMinus1.addEventListener(MouseEvent.CLICK, onCounterButtonClick);
		_buttonPlus1.addEventListener(MouseEvent.CLICK, onCounterButtonClick);
		_buttonPlus10.addEventListener(MouseEvent.CLICK, onCounterButtonClick);
	}
	
	private function onCounterButtonClick(e:MouseEvent):void {
		var callerButton:Button = e.currentTarget as Button;
		
		var newCount:int = _selectedCount;
		switch (callerButton) {
			case _buttonMinus10:
				if (newCount >= 10) {
					newCount -= 10;
				}
				break;
			case _buttonMinus1:
				if (newCount >= 1) {
					newCount -= 1;
				}
				break;
			case _buttonPlus1:
				newCount += 1;
				break;
			case _buttonPlus10:
				newCount += 10;
				break;
		}
		
		if (newCount > MAX_COUNT) newCount = MAX_COUNT;
		
		var hasFunds:Boolean = checkMoney(newCount * _model.price) && checkFantasy(newCount);
		
		if (hasFunds && newCount != _selectedCount && newCount <= MAX_COUNT) {
			_selectedCount = newCount;
			
			updateButtons();
			updateTextFields();
		}
	}
	
	private function onButtonPlantClick(e:MouseEvent):void {
		if (_selectedCount > 0) {
			_callerMfield.plant(_model.sID, _selectedCount, win.plantPaginator.startCount, onPlanted);
		}
	}
	
	private function onPlanted():void {
		App.user.stock.take(_model.moneyType, _model.price * _selectedCount);
		App.user.stock.take(Stock.FANTASY, _selectedCount);
		dispatchEvent(new Event(Event.COMPLETE));
	}
	
	public function updateModel(model:PlantItemModel):void {
		_model = model;
		
		_selectedCount = 0;
		
		updatePreview();
		updateTextFields();
		updateButtons();
		updateMoneyIcon();
	}
	
	private function updateMoneyIcon():void {
		Load.loading(Config.getIcon(App.data.storage[_model.moneyType].type, App.data.storage[_model.moneyType].preview), onMoneyIconLoadComplete);
	}
	
	private function updatePreview():void {
		Load.loading(Config.getIcon(_model.type, _model.previewID), onViewLoadComplete);
	}
	
	private function updateTextFields():void {
		var localizedString:String = Locale.__e("flash:1382952380297", [TimeConverter.timeToStr(_model.growTime * _model.levels)/*, String(_model.exp * _selectedCount), sellPrice()*/]);
		
		_textTitle.text = _model.title;
		_textGrowTime.text = localizedString;
		_textGrowTime.height = 100;
		
		_textFullPriceValue.text = (_model.price * _selectedCount).toString();
		
		_textFantasyCostValue.text = (_selectedCount).toString();
		
		_textCurrentCount.text = StringUtil.substitute("{0}/50", _selectedCount.toString());
		_textSelectedCount.text = _selectedCount.toString();
	}
	
	private function sellPrice():String {
		var count:int = 0;
		for (var id:* in App.data.storage[_model.sID].outs) {
			if (App.data.storage[id].type == 'Material' && id != Stock.COINS) {
				count += App.data.storage[id].cost;
			}
		}
		return String(count * _selectedCount);
	}
	
	private function checkMoney(count:int):Boolean {
		var userCoins:int = App.user.stock.count(_model.moneyType);
		return (count <= userCoins);
	}
	
	private function checkFantasy(count:int):Boolean {
		var userFantasy:int = App.user.stock.count(Stock.FANTASY);
		return (count <= userFantasy);
	}
	
	private function updateButtons():void {
		if ((_selectedCount - 10) < 0) {
			_buttonMinus10.disable();
		} else {
			_buttonMinus10.enable();
		}
		
		if ((_selectedCount - 1) < 0) {
			_buttonMinus1.disable();
		} else {
			_buttonMinus1.enable();
		}
		
		if (!checkMoney((_selectedCount + 1) * _model.price) || !checkFantasy(_selectedCount + 1) || (_selectedCount + 1) > MAX_COUNT) {
			_buttonPlus1.disable();
		} else {
			_buttonPlus1.enable();
		}
		
		if (!checkMoney((_selectedCount + 10) * _model.price) || !checkFantasy(_selectedCount + 10) || (_selectedCount + 10) > MAX_COUNT) {
			_buttonPlus10.disable();
		} else {
			_buttonPlus10.enable();
		}
		
		if (_selectedCount == 0) {
			_buttonPlantIt.disable();
		} else {
			_buttonPlantIt.enable();
		}
	}
	
	private function onViewLoadComplete(data:Bitmap):void {
		_bitmapPreview.bitmapData = data.bitmapData;
		Size.size(_bitmapPreview, PREVIEW_SIZE, PREVIEW_SIZE);
		_bitmapPreview.smoothing = true;
		
		_bitmapPreview.x = (/*_bitmapBackground.x + */((BACK_WIDTH * 0.5) - _bitmapPreview.width));
		_bitmapPreview.y = (BACK_WIDTH * 0.35) - (_bitmapPreview.height * 0.5);
	}
	
	public function dispose():void {
		_buttonPlantIt.removeEventListener(MouseEvent.CLICK, onButtonPlantClick);
		_buttonMinus10.removeEventListener(MouseEvent.CLICK, onCounterButtonClick);
		_buttonMinus1.removeEventListener(MouseEvent.CLICK, onCounterButtonClick);
		_buttonPlus1.removeEventListener(MouseEvent.CLICK, onCounterButtonClick);
		_buttonPlus10.removeEventListener(MouseEvent.CLICK, onCounterButtonClick);
	}
}

import wins.Window;
import wins.PurchaseWindow;

internal class GrowingPlantSubview extends Sprite {
	
	public var win:*;
	
	private var _model:PlantItemModel;
	private var _caller:Mfield;
	
	private var _textStatus:TextField;
	private var _textTitle:TextField;
	private var _textGrowTime:TextField;
	private var _textMultiplier:TextField;
	
	private var _backing:Bitmap = new Bitmap();
	private var _bitmapPreview:Bitmap;
	private var _bitmapGlow:Bitmap;
	
	private var _progressBacking:Bitmap;
	private var _progressBar:ProgressBar;
	
	private var _buttonSpeedUp:MoneyButton;
	private var _buttonHarvest:Button;
	private var circle:Shape;
	
	public function GrowingPlantSubview(model:PlantItemModel, caller:Mfield, win:*):void {
		_model = model;
		_caller = caller;
		this.win = win;
		
		circle = new Shape();
		circle.graphics.beginFill(0xb1c0b9, 1);
		circle.graphics.drawCircle(80, 100, 55);
		circle.graphics.endFill();	
		circle.x = 130;
		circle.y = -20;
		addChild(circle);
		
		drawPreview();
		drawProgress();
		drawButtons();
		drawTextFields();
		
		checkState();
	}
	
	private function drawTextFields():void {
		var textSettings:Object = { 
			width:			117,
			height:			37,
			fontSize:		36,
			textAlign:		"left",
			color:			0xffffff,
			borderColor:	0x814f31
		};
		
		_textStatus = Window.drawText(Locale.__e("flash:1446221219960"), textSettings);
		_textStatus.x = 10;
		_textStatus.y = 35;
		addChild(_textStatus);
		
		textSettings.fontSize = 26;
		textSettings.width = 220;
		textSettings.height = 25;
		textSettings.textAlign = "center";
		_textTitle = Window.drawText(_model.title, textSettings);
		_textTitle.x = 94;
		_textTitle.y = -6;
		addChild(_textTitle);
		
		textSettings.fontSize = 26;
		textSettings.textAlign = "left";
		textSettings.width = 190;
		textSettings.borderColor = 0x5a2a11;
		
		//var text:String = Locale.__e("flash:1382952380297", [TimeConverter.timeToStr(_model.growTime * _model.levels), int(_model.exp * _caller.count).toString(), _model.price.toString()]);
		//var text:String = Locale.__e("flash:1382952380075", [TimeConverter.timeToStr(_model.growTime * _model.levels), int(_model.exp * _caller.count)]);
		var text:String = Locale.__e("flash:1382952380297", [TimeConverter.timeToStr(_model.growTime * _model.levels)/*, String(_model.exp * _caller.plants[win.plantPaginator.startCount].count), sellPrice()*/]);
		_textGrowTime = Window.drawText(text, textSettings);
		_textGrowTime.x = 290;
		if (App.lang == 'jp') _textGrowTime.x = 275;
		_textGrowTime.y = 35;
		addChild(_textGrowTime);
		
		textSettings.width = 45;
		textSettings.height = 25;
		textSettings.fontSize = 26;
		textSettings.borderColor = 0x814f31;
		
		text = StringUtil.substitute("x{0}", _caller.plants[win.plantPaginator.startCount].count.toString());
		_textMultiplier = Window.drawText(text, textSettings);
		_textMultiplier.x = 254;
		_textMultiplier.y = 106;
		addChild(_textMultiplier);
	}
	
	private function sellPrice():String {
		var count:int = 0;
		for (var id:* in App.data.storage[_model.sID].outs) {
			if (App.data.storage[id].type == 'Material' && id != Stock.COINS) {
				count += App.data.storage[id].cost;
			}
		}
		return String(count * _caller.plants[win.plantPaginator.startCount].count);
	}
	
	private function drawPreview():void {
		_bitmapGlow = new Bitmap(Window.textures.iconGlow);
		_bitmapGlow.x = 212 - (_bitmapGlow.width / 2);
		_bitmapGlow.y = 80 - (_bitmapGlow.height / 2);
		addChild(_bitmapGlow);
		_bitmapGlow.visible = false;
		Load.loading(Config.getIcon(_model.type, _model.previewID), onViewLoadComplete);
	}
	
	private function onViewLoadComplete(data:Bitmap):void {
		_bitmapPreview = data;
		Size.size(_bitmapPreview, 105, 105);
		_bitmapPreview.smoothing = true;
		_bitmapPreview.x = 150;
		_bitmapPreview.y = 34;
		addChild(_bitmapPreview);
	}
	
	private function drawProgress():void {
		_progressBacking = Window.backingShort(300, "progBarBacking");
		_progressBacking.x = 7;
		_progressBacking.y = 140;
		_progressBacking.smoothing = true;
		addChild(_progressBacking);
		
		var barSettings:Object = {
			width:291,
			win:this.parent
		};
		_progressBar = new ProgressBar(barSettings);
		_progressBar.x = _progressBacking.x - 8;
		_progressBar.y = _progressBacking.y - 4;
		_progressBar.start();
		addChild(_progressBar);
		
		App.self.setOnTimer(onTimer);
	}
	
	private function drawButtons():void {
		var buttonSettings:Object = {
			caption		:Locale.__e("flash:1382952380104"),
			width		:130,
			height		:55,
			fontSize	:22,
			radius		:15,
			countText	:_caller.plants[win.plantPaginator.startCount].count,
			multiline	:true,
			type		:'eventCoin'
		};
		
		_buttonSpeedUp = new MoneyButton(buttonSettings);
		_buttonSpeedUp.x = 320;
		_buttonSpeedUp.y = 125;
		_buttonSpeedUp.addEventListener(MouseEvent.CLICK, onButtonSpeedUpClick);
		_buttonSpeedUp.coinsIcon.visible = false;
		addChild(_buttonSpeedUp);
		
		Load.loading(Config.getIcon(App.data.storage[Stock.FERTILIZER].type, App.data.storage[Stock.FERTILIZER].view), function(data:Bitmap):void {
			_buttonSpeedUp.coinsIcon.bitmapData = data.bitmapData;
			Size.size(_buttonSpeedUp.coinsIcon, 25, 25);
			_buttonSpeedUp.coinsIcon.y -= 2;
			_buttonSpeedUp.coinsIcon.visible = true;
			_buttonSpeedUp.coinsIcon.smoothing = true;
		});
		
		
		
		buttonSettings.width = 154;
		buttonSettings.height = 44;
		buttonSettings.fontSize = 30;
		buttonSettings.caption = Locale.__e("flash:1382952379737");
		buttonSettings.bgColor = [0xffd448, 0xf5a922];
		buttonSettings.bevelColor = [0xfff17f, 0xc67d0d];
		buttonSettings.borderColor = [0xba9a51, 0xa7865a];
		buttonSettings.fontBorderColor = 0x814f31;
		
		_buttonHarvest = new Button(buttonSettings);
		_buttonHarvest.x = 130;
		_buttonHarvest.y = 135;
		_buttonHarvest.addEventListener(MouseEvent.CLICK, onButtonHarvestClick);
		_buttonHarvest.visible = false;
		_buttonHarvest.textLabel.height += 5;
		
		addChild(_buttonHarvest);
	}
	
	private function onTimer():void {
		checkState();
	}
	
	private function checkState():void {
		var currentTime:int = App.time;
		var plantTime:int = 0;// _caller.plants[win.plantPaginator.startCount].plant.planted;
		if (_caller.plants[win.plantPaginator.startCount].plant != null) {
			plantTime = _caller.plants[win.plantPaginator.startCount].plant.planted;
		}
		var growTime:int = _model.growTime * _model.levels;
		var progressTime:int = currentTime - plantTime;
		var leftTime:int = growTime - progressTime;
		
		if (leftTime <= 0) {
			setReadyState();
			_progressBar.progress = progressTime / growTime;
			_progressBar.time = leftTime;
		} else {
			setProgressState();
			_progressBar.progress = progressTime / growTime;
			_progressBar.time = leftTime;
		}
	}
	
	private function setProgressState():void {
		_backing.visible = true;
		_progressBacking.visible = true;
		_progressBar.visible = true;
		_buttonSpeedUp.visible = true;
		_buttonHarvest.visible = false;
		
		_textGrowTime.visible = true;
		
		_bitmapGlow.visible = false;
		_backing.visible = true;
	}
	
	private function setReadyState():void {
		circle.visible = false;
		_backing.visible = false;
		_progressBacking.visible = false;
		_progressBar.visible = false;
		_buttonSpeedUp.visible = false;
		_buttonHarvest.visible = true;
		
		_textGrowTime.visible = false;
		_textStatus.visible = false;
		
		_bitmapGlow.visible = true;
		_backing.visible = false;
	}
	
	private function onButtonHarvestClick(e:MouseEvent):void {
		_caller.harvest(win.plantPaginator.startCount, harvestCallback);
	}
	
	private function harvestCallback(slot:int, bonus:Object = null):void {
		if (bonus) {
			for (var sid:* in bonus) {
				for (var sidOUT:* in _caller.plants[slot].plant.info.outs) {
					if (sid == sidOUT && sid != Stock.COINS && sid != Stock.EXP) {
						for (var num:* in bonus[sid]) {
							var cnt:int = int(bonus[sid][num]);
						}
						addBonusItems(cnt, sid, new Point(_caller.x, _caller.y));
						delete(bonus[sid]);
						/*var nominal:int = 5;
						for (var cnt:* in bonus[sid]) {
							var num:int = int(bonus[sid][cnt]);
						}
						var count:int = num / nominal;
						if (count < 1) continue;
						bonus[sid] = { };
						bonus[sid][nominal] = count;*/
					}
				} 
			}
			Treasures.bonus(/*Treasures.convert(*/bonus/*)*/, new Point(_caller.x, _caller.y));
		}else {
			var rewardObj:Object = { };
			for (var sID:* in _caller.plants[slot].plant.info.outs) {
				rewardObj[sID] = _caller.plants[slot].plant.info.outs[sID]*_caller.plants[slot].count;	
			}
			rewardObj[Stock.EXP] = _caller.plants[slot].plant.info.experience * _caller.plants[slot].count;
			
			//App.user.stock.addAll(rewardObj);
			//BonusItem.takeRewards(rewardObj, _bitmapPreview,0);
			Treasures.bonus(Treasures.convert(rewardObj), new Point(_caller.x, _caller.y));
		}
		
		dispatchEvent(new Event(Event.COMPLETE));
	}
	
	private static var timeToDrop:int = 0;
	public static function addBonusItems(count:int, sid:int, targetPoint:Point):void
	{
		var item:*;
		
		var i:int = 0;
		
		var nominalType1:int = 1;
		var nominalType2:int = 5;
		//var nominalType3:int = 10;
		
		var countType1:int = 0;
		var countType2:int = 0;
		//var countType3:int = 0;
		
		var leftCount:int = count ;
		
		if (count < nominalType2) {
			countType1 = count;
		}else /*if (count < nominalType3) */{
			countType2 = Math.floor(count / nominalType2);
			countType1 = count - countType2 * nominalType2;
		}/*else {
			countType3 = Math.floor(count / nominalType3);
			leftCount -= countType3 * nominalType3;
			countType2 = Math.floor(leftCount / nominalType2);
			countType1 = leftCount - countType2 * nominalType2;
		}*/
		
		for (i = 0; i < countType1; i++ ) {
			addItem(sid, nominalType1);
		}
		
		for (i = 0; i < countType2; i++ ) {
			addItem(sid, nominalType2);
		}
		
		/*for (i = 0; i < countType3; i++ ) {
			addItem(sid, nominalType3);
		}*/
	
		App.user.stock.add(sid, count);
		
		function addItem(_sid:int, _nominal:int):void
		{
			item = new BonusItem(_sid, _nominal);
			item.x = targetPoint.x;
			item.y = targetPoint.y;
			App.map.mTreasure.addChild(item);
			item.move(timeToDrop);
			timeToDrop += Treasures.TIME_DELAY;
		}
	}
	
	private function onButtonSpeedUpClick(e:MouseEvent):void {
		if (e.currentTarget.mode == Button.DISABLED) return;
		e.currentTarget.state = Button.DISABLED;
		
		// Снятие леек за ускорение
		if (!App.user.stock.check(Stock.FERTILIZER, _caller.plants[win.plantPaginator.startCount].count)) {
			win.close();
			new PurchaseWindow({
				width:395,
				itemsOnPage:2,
				content:PurchaseWindow.createContent("Boost"),
				title:Locale.__e("flash:1446562303157"),
				returnCursor:false,
				noDesc:false,
				description:Locale.__e("flash:1424688304987")
			}).show();
			return;
		}
		
		App.user.stock.take(Stock.FERTILIZER, _caller.plants[win.plantPaginator.startCount].count);
		
		_caller.boost(win.plantPaginator.startCount, boostCallback);
	}
	
	private function boostCallback():void {
		checkState();
	}
	
	public function dispose():void {
		App.self.setOffTimer(onTimer);
		
		_buttonSpeedUp.removeEventListener(MouseEvent.CLICK, onButtonSpeedUpClick);
		_buttonHarvest.removeEventListener(MouseEvent.CLICK, onButtonHarvestClick);
	}
}

internal class PlantItemModel {
	
	private var _type:String;
	private var _previewID:String;
	private var _sID:int;
	private var _title:String;
	private var _price:int;
	private var _growTime:int;
	private var _exp:int;
	private var _boostPrice:int
	private var _moneyType:int;
	private var _levels:int;
	
	public function PlantItemModel(type:String, previewID:String, sID:int, title:String, price:int, growTime:int, exp:int, moneyType:int, levels:int = 1) {
		_type = type;
		_previewID = previewID;
		_sID = sID;
		_title = title;
		_price = price;
		_growTime = growTime;
		_exp = exp;
		_boostPrice = boostPrice;
		_moneyType = moneyType;
		
		_levels = levels;
	}
	
	public function get type():String {
		return _type;
	}
	
	public function get previewID():String {
		return _previewID;
	}
	
	public function get sID():int {
		return _sID;
	}
	
	public function get title():String {
		return _title;
	}
	
	public function get price():int {
		return _price;
	}
	
	public function get growTime():int {
		return _growTime;
	}
	
	public function get exp():int {
		return _exp;
	}
	
	public function get boostPrice():int {
		return _boostPrice;
	}
	
	public function get moneyType():int {
		return _moneyType;
	}
	
	public function get levels():int {
		return _levels;
	}
}