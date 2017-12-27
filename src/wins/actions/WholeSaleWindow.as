package wins.actions {
	
	import api.ExternalApi;
	import buttons.Button;
	import buttons.ImageButton;
	import core.Load;
	import core.Numbers;
	import core.Post;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import ui.UserInterface;
	import wins.AddWindow;
	import wins.Window;
	import wins.SimpleWindow;
	
	public class WholeSaleWindow extends AddWindow {
		private var descText:TextField;
		private var textJust:TextField;
		private var numItems:int;
		private var items:Array = new Array();
		
		public function WholeSaleWindow(settings:Object = null) {
			if (settings == null) {
				settings = new Object();
			}
			
			settings['background'] 		= 'alertBacking';
			settings['width'] 			= 590;
			settings['height'] 			= 400;
			settings['title'] 			= Locale.__e('flash:1382952380262');
			settings["description"] 	= settings["description"] || '';
			settings['content']			= [];
			settings['hasPaginator'] 	= false;
			settings['hasExit'] 		= false;
			settings['hasTitle'] 		= true;
			settings['faderClickable'] 	= true;
			settings['faderAlpha'] 		= 0.6;
			settings['popup'] 			= true;
			settings['promoPanel'] = true;
			
			super(settings);
			
			initContent();
			
			numItems = settings.content.length;
		}
		
		override public function drawBackground():void {
			//
		}
		
		override public function drawExit():void {
			//
		}
		
		override public function drawTitle():void {
			titleLabel = titleText( {
				title				: settings.title,
				color				: 0xffffff,
				multiline			: settings.multiline,			
				fontSize			: 46,
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
			titleLabel.y = - titleLabel.height / 2 - 14;
			titleLabel.mouseChildren = titleLabel.mouseEnabled = false;
			headerContainer.addChild(titleLabel);
			
			headerContainer.y = 32;
			headerContainer.mouseEnabled = false;
		}
		
		private function initContent():void {
			action = App.data.actions[settings.pID];
			action['id'] = settings.pID;
			
			if (Numbers.countProps(action.items) > 0) {
				for (var sID:* in action.items) {
					settings.content.push({sID:sID, count:action.items[sID], order:action.iorder[sID]});
				}
			}
			
			if (Numbers.countProps(action.bonus) > 0) {
				for (var sID2:* in action.bonus) {
					settings.content.push({sID:sID2, count:action.bonus[sID2], order:action.iorder[sID2]});
				}
			}
			
			settings.content.sortOn('order');
		}
		
		override public function drawBody():void {
			settings.width = 100 + numItems * 150;
			//if (numItems == 3) settings.width = 590;
			//if (numItems == 4) settings.width = 700;
			
			var background:Bitmap = backing(settings.width, settings.height, 45, 'alertBacking');
			layer.addChild(background);
			
			exit = new ImageButton(textures.closeBttn);
			headerContainer.addChild(exit);
			exit.x = settings.width - 65;
			exit.y = -35;
			exit.addEventListener(MouseEvent.CLICK, close);
			
			titleLabel.x = (settings.width - titleLabel.width) / 2;
			
			var up_devider:Bitmap = new Bitmap(Window.textures.dividerLine);
			up_devider.x = 90;
			up_devider.y = 35;
			up_devider.width = background.width - 180;
			up_devider.alpha = 0.6;
			bodyContainer.addChild(up_devider);
			
			descText = drawText(settings.description, {
				color				:0x542d0a,
				border				:false,
				fontSize			:26,
				autoSize			:"center",
				textAlign			:"center"
			});
			descText.width = 400;
			descText.x = (settings.width - descText.textWidth) / 2;
			descText.y = up_devider.y + 10;
			bodyContainer.addChild(descText);
			
			var down_devider:Bitmap = new Bitmap(Window.textures.dividerLine);
			down_devider.x = up_devider.x;
			down_devider.width = up_devider.width;
			down_devider.y = descText.y + descText.height + 5;
			down_devider.alpha = 0.6;
			bodyContainer.addChild(down_devider);
			
			var fonGlow:Bitmap = new Bitmap(Window.textures.glowShine, "auto", true);
			fonGlow.scaleX = fonGlow.scaleY = 1.3;
			fonGlow.smoothing = true;
			fonGlow.alpha = 0.5;
			fonGlow.x = (settings.width - fonGlow.width) / 2;
			fonGlow.y = 50;
			bodyContainer.addChild(fonGlow);
			
			contentChange();
			
			container.x = (settings.width - container.width) / 2;
			container.y = 90;
			bodyContainer.addChild(container);
			
			textJust = drawText(Locale.__e('flash:1408441188465'), {
				color				:0x542d0a,
				border				:false,
				fontSize			:26,
				autoSize			:"center",
				textAlign			:"center"
			});
			textJust.width = 140;
			textJust.x = (settings.width - textJust.textWidth) / 2;
			textJust.y = settings.height - textJust.height - 90;
			bodyContainer.addChild(textJust);
			
			drawPrice2();
			
			var imgName:String = action.image;
			Load.loading(Config.getImage('wholeSale', imgName), function(data:Bitmap):void {
				var imageLeft:Bitmap = new Bitmap(data.bitmapData);
				imageLeft.x = - imageLeft.width + 90;
				imageLeft.y = settings.height - imageLeft.height;
				if (imgName == 'sheep') {
					imageLeft.scaleX = -1;
					imageLeft.x += imageLeft.width;
				}
				bodyContainer.addChildAt(imageLeft, bodyContainer.numChildren - 1);
			});
		}
		
		private var container:Sprite = new Sprite();
		override public function contentChange():void {
			for each(var _item:ActionItem in items) {
				container.removeChild(_item);
				_item = null;
			}
			
			items = [];
			var pluses:Array = [];
			
			var Xs:int = 0;
			var Ys:int = 0;
			var X:int = 0;
			
			for (var i:int = 0; i < numItems; i++) {
				var item:ActionItem = new ActionItem(settings.content[i], this);
				item.x = Xs;
				item.y = Ys;
				container.addChild(item);
				
				items.push(item);
				Xs += item.background.width;
				item.background.visible = false;
				
				var plus:Bitmap = new Bitmap(Window.textures.plus);
				plus.x = item.x - plus.width / 2;
				plus.y = item.background.height / 2 - plus.height / 2;
				container.addChild(plus);
				pluses.push(plus)
				
				if (App.isSocial('NK') && numItems > 3 && i == 0) {
					item.title.x += 10;
				}
			}
			
			var firstPlus:Bitmap = pluses.shift();
			container.removeChild(firstPlus);
		}
		
		private var cont:Sprite;
		
		public function drawPrice2():void {
			
			var bttnSettings:Object = {
				fontSize:30,
				width:194,
				height:53
			};
			
			if (priceBttn != null)
				bodyContainer.removeChild(priceBttn);
				
			bttnSettings['caption'] = Payments.price(action.price[App.social]);
			
			priceBttn = new Button(bttnSettings);
			priceBttn.x = (settings.width - priceBttn.width) / 2;
			priceBttn.y = settings.height - priceBttn.height - 35;
			bodyContainer.addChild(priceBttn);
			priceBttn.addEventListener(MouseEvent.CLICK, buyEvent);
			//priceBttn.addEventListener(MouseEvent.CLICK, close);
			
			if (App.isSocial('MX')) {
				var mxLogo:Bitmap = new Bitmap(UserInterface.textures.mixieLogo);
				mxLogo.scaleX = mxLogo.scaleY = 0.8;
				priceBttn.addChild(mxLogo);
				mxLogo.y = priceBttn.textLabel.y - (mxLogo.height - priceBttn.textLabel.height)/2;
				mxLogo.x = priceBttn.textLabel.x-10;
				priceBttn.textLabel.x = mxLogo.x + mxLogo.width + 5;
			}
			if (App.isSocial('SP')) {
				var spLogo:Bitmap = new Bitmap(UserInterface.textures.fantsIcon);
				priceBttn.addChild(spLogo);
				spLogo.y = priceBttn.textLabel.y - (spLogo.height - priceBttn.textLabel.height)/2;
				spLogo.x = priceBttn.textLabel.x-10;
				priceBttn.textLabel.x = spLogo.x + spLogo.width + 5;
			}
			
			if (cont != null)
				bodyContainer.removeChild(cont);
				
			cont = new Sprite();
			cont.x = priceBttn.x + priceBttn.width / 2 - cont.width / 2;
			cont.y = priceBttn.y - 30;
			bodyContainer.addChild(cont);
		}
		
		override public function getIconUrl(promo:Object):String {
			if (promo.hasOwnProperty('iorder')) {
				var _items:Array = [];
				for (var sID:* in promo.items) {
					_items.push( { sID:sID, order:promo.iorder[sID] } );
				}
				_items.sortOn('order');
				sID = _items[0].sID;
			}else {
				sID = promo.items[0].sID;
			}
			
			return Config.getIcon(App.data.storage[sID].type, App.data.storage[sID].preview);
		}
		
		override public function dispose():void {
			for each(var _item:ActionItem in items) {
				_item = null;
			}
			super.dispose();
		}
	}
}

import core.Load;
import core.Size;
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.text.TextField;
import wins.Window;

internal class ActionItem extends Sprite {
	
	public var count:uint;
	public var sID:uint;
	public var background:Bitmap;
	public var bitmap:Bitmap;
	public var title:TextField;
	public var window:*;
	private var preloader:Preloader = new Preloader();
	private var sprite:LayerX;
	
	public function ActionItem(item:Object, window:*) {
		sID = item.sID;
		count = item.count;
		this.window = window;
		
		background = Window.backing(150, 190, 10, 'itemBacking');
		addChild(background);
		
		sprite = new LayerX();
		addChild(sprite);
		
		bitmap = new Bitmap();
		sprite.addChild(bitmap);
		
		preloader.x = (background.width)/ 2;
		preloader.y = (background.height) / 2;
		addChild(preloader);
		Load.loading(Config.getIcon(App.data.storage[sID].type, App.data.storage[sID].preview), onPreviewComplete);
		
		drawTitle();
		if (count > 1) {
			drawCount();
		}
	}
	
	
	public function onPreviewComplete(data:Bitmap):void {
		removeChild(preloader);
		
		bitmap.bitmapData = data.bitmapData;
		Size.size(bitmap, 140, 140);
		bitmap.smoothing = true;
		bitmap.x = (background.width - bitmap.width) / 2;
		bitmap.y = (background.height - bitmap.height) / 2;
	}
	
	public function drawTitle():void {
		title = Window.drawText(String(App.data.storage[sID].title), {
			fontSize:24,
			color:0xfffaf1,
			borderColor:0x542d0a,
			textAlign:"center",
			autoSize:"center",
			textLeading:-6,
			multiline:true
		});
		title.wordWrap = true;
		title.width = background.width - 10;
		title.x = 5;
		title.y = background.height - 40;
		addChild(title);
	}
	
	private var spCount:Sprite = new Sprite();
	private var countText:TextField;
	public function drawCount():void {
		countText = Window.drawText('x' + String(count), {
			fontSize:30,
			color:0xffffff,
			borderColor:0x794106,
			textAlign:"center",
			autoSize:"center",
			textLeading:-6,
			multiline:true
		});
		countText.wordWrap = true;
		countText.width = countText.textWidth + 10;
		countText.height = countText.textHeight;
		spCount.addChild(countText);
		
		spCount.x = (background.width - spCount.width) / 2 + 40;
		spCount.y = 15;
		addChild(spCount);
		
		/*if (App.data.storage[sID].view == "Energy") {
			Load.loading(Config.getIcon(App.data.storage[sID].type, App.data.storage[sID].view), onLoadOut);
		} else {
			spCount.x = (background.width - spCount.width) / 2 + 40;
			spCount.y = 20;
			addChild(spCount);
		}*/
	}
	
	/*private function onLoadOut(data:*):void {
		var iconEfir:Bitmap = new Bitmap(data.bitmapData);
		iconEfir.x = countText.x + countText.width;
		Size.size(iconEfir, 35, 35);
		iconEfir.smoothing = true;
		spCount.addChild(iconEfir);
		
		spCount.x = (background.width - spCount.width) / 2 + 40;
		spCount.y = 20;
		addChild(spCount);
	}*/
}