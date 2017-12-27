package wins.actions 
{
	import buttons.Button;
	import core.Load;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.text.TextField;
	import wins.AddWindow;
	
	public class WanimalWindow extends AddWindow 
	{
		
		private var titleLable:TextField;
		public var presentView:Bitmap;
		public var ribbonView:Bitmap;
		public var glowView:Bitmap;
		public var itemCont:Sprite;
		public var itemList:Vector.<ActionItem> = new Vector.<ActionItem>;
		
		public var endTime:int = 0;
		public var list:Array = [];
		
		public function WanimalWindow(settings:Object = null) 
		{
			if (!settings) settings = { };
			
			action = App.data.bigsale[settings.pID];
			action['id'] = settings.pID;
			for (var s:String in action.items) {
				action.items[s]['id'] = s;
				list.push(action.items[s]);
			}
			list.sortOn('o', Array.NUMERIC);
			
			settings['width'] = settings['width'] || 730;
			settings['height'] = settings['height'] || 390;
			settings['hasTitle'] = true;
			settings['hasPaginator'] = false;
			settings['fontSize'] =  40;
			settings['title'] = action.title;
			settings['promoPanel'] = true;
			
			super(settings);
		}
		
		override public function drawBackground():void {
			background = new Bitmap();
			layer.addChild(background);
			background.bitmapData = backing(settings.width, settings.height, 50, 'shopMainBacking').bitmapData;
			
			var   background2:Bitmap = new Bitmap();
			
			layer.addChild(background2);
			
			background2.bitmapData = backing(settings.width - 65, settings.height - 90, 50, 'shopDarkBacking').bitmapData;
			
			background2.x =(background.width - background2.width) / 2;
			background2.y = (background.height - background2.height) / 2;
			background2.y += 12.5;
			
			var backRibbon:Bitmap = backingShort(800, 'questRibbon');
			backRibbon.y -= 20;
			backRibbon.x -= 35;
			layer.addChild(backRibbon);
	
		}
		
		override public function drawBody():void {
			//glowView = new Bitmap(Window.textures.glow, 'auto', true);
			//glowView.scaleX = glowView.scaleY = 2.25;
			//glowView.x = (settings.width - glowView.width) / 2;
			//glowView.y = -80;
			//bodyContainer.addChild(glowView);
			
			presentView = new Bitmap();
			bodyContainer.addChild(presentView);
			Load.loading(Config.getImage('content', 'cats_preview'), function(data:Bitmap):void {
				presentView.bitmapData = data.bitmapData;
				presentView.smoothing = true;
				presentView.x = (settings.width - presentView.width) / 2;
				presentView.y = -160;
			});
			
			ribbonView = new Bitmap();
			bodyContainer.addChild(ribbonView);
			Load.loading(Config.getImage('content', 'ribbon'), function(data:Bitmap):void {
				ribbonView.bitmapData = data.bitmapData;
				ribbonView.smoothing = true;
				ribbonView.x = (settings.width - ribbonView.width) / 2;
				ribbonView.y = 110;
			});
			
			//titleLable = drawText(settings.title, {
				//width:		settings.width - 60,
				//color:		0x604729,
				//borderColor:0xf7f2de,
				//fontSize:	38,
				//textAlign:	'center',
				//filters:	[new DropShadowFilter(3, 90, 0x604729, 1, 0, 0)]
			//});
			//titleLable.x = (settings.width - titleLable.width) / 2;
			//titleLable.y = 125;
			//bodyContainer.addChild(titleLable);
			titleLabel.y += 5;
			contentChange();
			exit.x -= 20;
			exit.y -= 40;
			
			drawMirrowObjs('diamondsTop', settings.width / 2 - settings.titleWidth / 2 - 5, settings.width / 2 + settings.titleWidth / 2 + 5, -34, true, true);
			drawMirrowObjs('diamonds',background.x + 20, background.width - 20, background.height - 115);
		}
		
		override public function drawFader():void {
			//super.drawFader();
			//this.y += 80;
			//fader.y -= 80;
			//
			//layer.swapChildren(headerContainer, bodyContainer);
		}
		
		override public function contentChange():void {
			if (!itemCont || !bodyContainer.contains(itemCont))
				bodyContainer.addChild(itemCont = new Sprite());
			
			clear();
			
			for (var i:int = 0; i < list.length; i++) {
				var item:ActionItem = new ActionItem( {
					item:		list[i],
					target:		this
				});
				item.x = 50 + 212 * (i % 3);
				item.y = 40;
				itemCont.addChild(item);
				itemList.push(item);
			}
		}
		
		public function block(value:Boolean = true):void {
			var i:int;
			if (value) {
				for (i = 0; i < itemList.length; i++)
					itemList[i].buyBttn.state = Button.DISABLED;
			}else {
				for (i = 0; i < itemList.length; i++)
					itemList[i].buyBttn.state = Button.NORMAL;
			}
		}
		
		private function clear():void {
			while (itemList.length > 0) {
				var item:ActionItem = itemList.shift();
				item.dispose();
				itemCont.removeChild(item);
			}
		}
		//public static function 
	}
}


import api.ExternalApi;
import buttons.Button;
import com.flashdynamix.motion.extras.BitmapTiler;
import com.greensock.loading.core.DisplayObjectLoader;
import core.Load;
import core.Post;
import flash.display.Bitmap;
import flash.display.DisplayObject;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.text.TextField;
import ui.UserInterface;
import wins.Window;
import wins.actions.PromoWindow;
import wins.actions.WanimalWindow;
import wins.SimpleWindow;

internal class ActionItem extends Sprite {
	
	public var buyBttn:Button;
	private var backing:Bitmap;
	private var glow:Bitmap;
	private var image:Bitmap;
	private var imageCont:LayerX;
	private var titleLabel:TextField;
	private var descriptionLabel:TextField;
	
	private var offerLabel:TextField;
	private var oldOfferLabel:TextField;
	
	public var price:Number = 0;
	public var window:WanimalWindow;
	public var item:Object;
	public var info:Object;
	private var title:String;
	private var description:String;
	
	
	public var params:Object = {
		width:		208,
		height:		275
	}
	
	public function ActionItem(params:Object = null) {
		if (params) {
			for (var s:String in params)
				this.params[s] = params[s];
		}
		
		item = params.item;
		info = App.data.storage[item.sID];
		title = info.title;
		description = info.description;
		price = item.pn;
		window = params.target;
		
		draw();
	}
	
	public function draw():void {
		
		backing = Window.backing(params.width, params.height, 50, 'itemBacking');
		addChild(backing);
		
		//var glowmask:Shape = new Shape();
		//glowmask.graphics.beginFill(0, 1);
		//glowmask.graphics.drawRoundRect(5, 5, backing.width - 10, backing.height - 10, 12, 12);
		//glowmask.graphics.endFill();
		//
		//glow = new Bitmap(Window.textures.glow, 'auto', true);
		//glow.scaleX  = glow.scaleY = 0.85;
		//glow.x = (backing.width - glow.width) / 2;
		//glow.y = (backing.height - glow.height) / 2 - 15;
		//glow.mask = glowmask;
		//addChild(glow);
		//addChild(glowmask);
		
		imageCont = new LayerX();
		addChild(imageCont);
		image = new Bitmap();
		imageCont.addChild(image);
		//Load.loading(Config.getIcon(info.type, info.preview + '_mod'), onLoad, 0, false, function():void {
			
		Load.loading(Config.getImage('furry', info.preview), onLoad);
		//});
		imageCont.tip = function():Object {
			return {
				title:	info.title,
				text:	info.description
			}
		}
		
		if (item.po && item.po > item.pn) {
			oldOfferLabel = Window.drawText(PromoWindow.formatPrice(item.po), {
				width:			backing.width - 10,
				fontSize:		22,
				color:			0xffe468,
				borderColor:	0x604b29,
				autoSize:		'center'
			});
			oldOfferLabel.x = (backing.width - oldOfferLabel.width) / 2;
			oldOfferLabel.y = backing.height - oldOfferLabel.height - 62;
			//addChild(oldOfferLabel);
			
			var shape:Shape = new Shape();
			shape.graphics.lineStyle(2, 0xDD0000);
			shape.graphics.moveTo(oldOfferLabel.x - 2, oldOfferLabel.y + oldOfferLabel.height / 2);
			shape.graphics.lineTo(oldOfferLabel.x + oldOfferLabel.width + 2, oldOfferLabel.y + oldOfferLabel.height / 2);
			//addChild(shape);
		}
		
		var priceCont:Sprite = new Sprite();
		
		if (App.isSocial('PL')) {
			var fant:Bitmap = new Bitmap(UserInterface.textures.fantsIcon, 'auto', true);
			priceCont.addChild(fant);
		}
		
		offerLabel = Window.drawText(PromoWindow.formatPrice(price), {
			autoSize:		'center',
			fontSize:		28,
			color:			0xfedb38,
			borderColor:	0x6d4b15,
			textAlign:		'center'
		});
		offerLabel.x = priceCont.width + 4;
		offerLabel.y = 5;
		//priceCont.addChild(offerLabel);
		
		priceCont.x = (backing.width - priceCont.width) / 2;
		priceCont.y = backing.height - priceCont.height - 34;
		addChild(priceCont);
		drawTexts();
		drawBttn();
	}
	
	private function drawTexts():void {
		
		var twidth:int = params.width - 25;
		titleLabel = Window.drawText(title, {
			autoSize:		'center',
			fontSize:		25,
			wrap				: true,
			color:			0xffffff,
			borderColor:	0x773c18,
			width				: twidth,
			textAlign:		'center'
		});
		addChild(titleLabel);
		titleLabel.x = (backing.width - twidth) / 2;
		descriptionLabel = Window.drawText(description, {
			autoSize:		'center',
			fontSize:		21,
			wrap				: true,
			color:			0x65371b,
			borderColor:	0xeed3a4,
			width				: twidth,
			textAlign:		'center'
		});
		addChild(descriptionLabel);
		descriptionLabel.x = (backing.width - twidth) / 2;
		descriptionLabel.y = backing.y + backing.height - descriptionLabel.height - 35;
		titleLabel.y = descriptionLabel.y - titleLabel.height;
	}
	private function drawBttn():void {
		var name:String = offerLabel.text;
		
		buyBttn = new Button( {
			caption:	name,
			width:		135,
			height:		40
		});
		buyBttn.x = (backing.width - buyBttn.width) / 2;
		buyBttn.y = backing.height - 32;
		buyBttn.addEventListener(MouseEvent.CLICK, onBuy);
		addChild(buyBttn);
	}
	
	
	private function onLoad(data:Bitmap):void {;
		image.bitmapData = data.bitmapData;
		image.smoothing = true;
		image.x = (backing.width - image.width) / 2;
		//image.y = (backing.height - image.height) / 2 - ((oldOfferLabel) ? 100 : 28);
		image.y = (backing.height - image.height) / 2 - 60;// ((oldOfferLabel) ? 100 : 28);
	}
	
	public function onBuy(e:MouseEvent):void {
		window.block();
		//onBuyComplete(e);
		var object:Object;
		switch(App.social) {
			
			case 'PL':
			case 'YB':
			case 'NN':
				buyBttn.state = Button.NORMAL;
				if(item.sID != Stock.FANT){
				
					if(App.user.stock.take(Stock.FANT, item.pn)){
						Post.send({
							ctr:'Stock',
							act:'bigsale',
							uID:App.user.id,
							sID:window.action.id,
							pos:item.id
						},function(error:*, data:*, params:*):void {
							if(!error){
								//App.user.stock.add(item.sID,count, true);
								onBuyComplete();
							}
						});
					}else {
						window.close();
					}
					return;
					
				}else {
					//Если покупаем кристаллы, то покупаем за реал
					object = {
						id:		 	'bigsale_' + window.action.id + '#' + item.id,
						price:		item.pn,
						type:		'bigsale',
						count: 		item.c,
						title:		window.action.title
					};
					
					// Забрасываем сразу на склад
					var items:Object = { };
					items[item.b] = item.bc;
					if (window.action.type == 1) object['rewards'] = items;
				}
				
				break;
			case 'FB':
				object = {
					id:		 		window.action.id+'#'+item.id,
					type:			'bigsale',
					callback:		onBuyComplete
				};
				break;
			default:
				object = {
					count:			item.c,
					money:			'bigsale',
					type:			'item',
					item:			'bigsale_'+window.action.id+'_'+item.id,
					votes:			item.pn,
					title: 			Locale.__e('flash:1382952379996'),
					description: 	Locale.__e('flash:1382952379997'),
					callback: 		onBuyComplete
				}
				break;
		}
		ExternalApi.apiBalanceEvent(object);
	}
	
	private function onBuyComplete(e:* = null):void {
		window.block(false);
		
		for (var s:* in item.items) {
			if (Storage.isShopLimited(s))
				Storage.shopLimitBuy(s, item.items[s]);
		}
		
		item['items'] = { };
		if(item.hasOwnProperty('b') && item.b != '') item.items[item.b] = item.bc;
		item.items[item.sID] = item.c;
		App.user.stock.addAll(item.items);
		
		BonusItem.takeRewards(item.items, buyBttn, 50);
		window.close();
		
		new SimpleWindow( {
			label:SimpleWindow.ATTENTION,
			title:Locale.__e("flash:1382952379735"),
			text:Locale.__e("flash:1382952379990")
		}).show();
		
	}
	
	public function dispose():void {
		buyBttn.removeEventListener(MouseEvent.CLICK, onBuy);
	}
}