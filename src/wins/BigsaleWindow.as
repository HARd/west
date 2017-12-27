package wins 
{
	import api.ExternalApi;
	import buttons.Button;
	import core.Load;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.text.TextField;

	public class BigsaleWindow extends Window
	{
		public var action:Object;
		private var items:Array = new Array(),
					container:Sprite,
					priceBttn:Button,
					timerText:TextField,
					descriptionLabel:TextField,
					sID:int,
					timeConteiner:Sprite,
					back:Bitmap;
			
		public static function startAction(sID:int, sale:Object):void {
			//Load.loading(Config.getQuestIcon('preview', App.data.personages[sale.image].preview), function(data:*):void { 
				//if (App.user.quests.chapters.indexOf(2) != -1) {
					//new BigsaleWindow( { sID:sID } ).show();
				//}
			//});
		}
		
		public function BigsaleWindow(settings:Object = null)
		{
			if (settings == null) {
				settings = new Object();
			}
			sID = settings['sID'];
			action = App.data.bigsale[sID];
			action.id = sID;
			
			settings['width'] = 593;
			settings['height'] = 468;
			settings['title'] = action.title;
			settings['hasTitle'] = false;
			settings['hasPaginator'] = true;
			settings['hasButtons'] = false;
			settings['hasExit'] = true;
			settings['fontColor'] = 0xffcc00;
			settings['fontSize'] = 60;
			settings['fontBorderColor'] = 0x705535;
			settings['shadowBorderColor'] = 0x342411;
			settings['fontBorderSize'] = 8;
			settings['itemsOnPage'] = 3;
			
			settings.content = initContent(action.items);
			
			super(settings);
		}
		
		private function initContent(data:Object):Array
		{
			var result:Array = [];
			for (var id:* in data)
				result.push({id:id, sID:data[id].sID, count:data[id].c, order:data[id].o, price_new:data[id].pn, price_old:data[id].po});
			
			result.sortOn('order', Array.NUMERIC);
			return result;
		}
		
		private var axeX:int
		private var character:Bitmap;
		override public function drawBody():void 
		{
			back = backing(settings.width - 60, 264, 50, "shopBackingSmall1");
				back.x = 30;
				back.y = (settings.height - back.height) / 2 + 70;
				bodyContainer.addChildAt(back,0);
				
			drawMirrowObjs('diamonds', 20, settings.width - 20, settings.height - 85, false, false, false, 1,1/*,bodyContainer*/);
			drawMirrowObjs('diamonds', 20, settings.width - 20, 80, false, false, false, 1, -1/*,bodyContainer*/);
			
			character = new Bitmap();
				//bodyContainer.addChild(character);
				
			drawMessage();
				
			Load.loading(Config.getQuestIcon('preview', App.data.personages[action.image].preview), function(data:*):void { 
				character.bitmapData = data.bitmapData;
				character.x = 20;
				character.y = 10;
				character.scaleX = character.scaleY = 0.7;
				character.smoothing = true;	
				switch (action.image) 
				{
					case 1:
						character.x = -110;
						character.y = -70;
						character.scaleX = character.scaleY = 1;
					break;
					case 2:
						character.x = -120;
						character.y = -50;
						character.scaleX = character.scaleY = 1;
					break;
					case 3:
						character.x = -180;
						character.y = -70;
						character.scaleX = character.scaleY = 1;
					break;
					default:
						character.x = -110;
						character.y = -70;
						character.scaleX = character.scaleY = 1;
				}
			});
			
			container = new Sprite();
				container.y = 210;
				bodyContainer.addChild(container);
				
				
			if(settings['L'] <= 3)
				axeX = settings.width - 170;
			else
				axeX = settings.width - 190;
				
			contentChange();
			
			App.self.setOnTimer(updateDuration);
			
			exit.parent.removeChild(exit);
				exit.x += 0;
				exit.y -= 15;
				bodyContainer.addChild(exit);
		}
		
		override public function close(e:MouseEvent=null):void {
			super.close();
		}
		
		override public function drawArrows():void 
		{
			paginator.drawArrow(bodyContainer, Paginator.LEFT,  0, 0, { scaleX: -1, scaleY:1 } );
			paginator.drawArrow(bodyContainer, Paginator.RIGHT, 0, 0, { scaleX:1, scaleY:1 } );
			
			var y:Number = settings.height/2 - paginator.arrowLeft.height
			paginator.arrowLeft.x = 0;
			paginator.arrowLeft.y = y;
			
			paginator.arrowRight.x = settings.width - paginator.arrowLeft.width;
			paginator.arrowRight.y = y;
		}
		
		public override function contentChange():void 
		{
			for each(var _item:BigsaleItem in items)
			{
				container.removeChild(_item);
				_item = null;
			}
			
			items = [];
			
			var Xs:int = -13;
			var Ys:int = 20;
			var X:int = 0;
			
			var itemNum:int = 0;
			for (var i:int = paginator.startCount; i < paginator.finishCount; i++)
			{
				var item:BigsaleItem = new BigsaleItem(settings.content[i], this);
				
				container.addChild(item);
				item.x = Xs;
				item.y = Ys;
								
				items.push(item);
				Xs += item.background.width + 23;
				
				itemNum++;
			}
			
			container.x = back.x + (back.width - container.width) / 2 + 12;
		}
		
		override public function drawBackground():void {
			var background:Bitmap = backing(settings.width, settings.height, 50, "shopBackingMain");
			layer.addChild(background);
		}
		
		private function drawMessage():void {
			
			var sprite:Sprite = new Sprite();
			var title:TextField;
			var titleSprite:Sprite = new Sprite();
			var titleShadow:TextField;
			title = Window.drawText(App.data.bigsale[sID].title, {
				color:0xfcd954,
				borderColor:0xac692d,
				borderSize:4,
				fontSize:36,
				multiline:true,
				textAlign:"center"
			});
			title.wordWrap = true;
			title.width = 254;
			title.height = title.textHeight + 10; 
			titleSprite.addChild(title);
			
			titleSprite.filters = [new GlowFilter(0x914e26, 1, 4, 4,4,1)];
			
			drawTime();
			
			var timeBack:Bitmap = Window.backing(321,190,10,'questsSmallBackingTopPiece');
			var textBack:Bitmap = Window.backing(165,60,15,"timerBacking");
			
			sprite.addChild(timeBack);
			sprite.addChild(textBack);
			textBack.x = (timeBack.width - textBack.width) / 2;
			textBack.y = 110;
			
			sprite.addChild(titleSprite);
			titleSprite.y = 20;
			titleSprite.x = (timeBack.width - title.width) / 2;
			
			sprite.addChild(timeConteiner);
			timeConteiner.x = timeBack.x + (timeBack.width - timeConteiner.width) / 2;
			timeConteiner.y = timeBack.y + (timeBack.height - timeConteiner.height) / 2 + 35;
			
			bodyContainer.addChild(sprite);
			bodyContainer.addChild(character);
			sprite.x = (settings.width - sprite.width) / 2 + 100;
			sprite.y = 35;
			
		}
		
		public function drawTime():void {
			
			timeConteiner = new Sprite();
			
			descriptionLabel = drawText(Locale.__e('flash:1393581955601'), {
				fontSize:26,
				textAlign:"center",
				color:0xf0e6c1,
				borderColor:0x502f06
			});
			descriptionLabel.width = 230;
			descriptionLabel.x = (descriptionLabel.width - 230)/2;
			descriptionLabel.y = 8;
			timeConteiner.addChild(descriptionLabel);
			
			var time:int = action.duration * 60 * 60 - (App.time - action.time);
			timerText = Window.drawText(TimeConverter.timeToStr(time), {
				color:0xf8d74c,
				letterSpacing:3,
				textAlign:"center",
				fontSize:42,
				borderColor:0x43180a
			});
			timerText.width = 230;
			timerText.y = 35;
			timerText.x = 0;
			timeConteiner.addChild(timerText);
		}
		
		private function updateDuration():void {
			var time:int = action.duration * 60 * 60 - (App.time - action.time);
				timerText.text = TimeConverter.timeToStr(time);
			
			if (time <= 0) {
				App.self.setOffTimer(updateDuration);
				App.ui.salesPanel.createPromoPanel();
				close();
			}
		}
		
		public override function dispose():void
		{
			for each(var _item:BigsaleItem in items)
			{
				_item = null;
			}
			
			App.self.setOffTimer(updateDuration);
			super.dispose();
		}
	}
}

import api.ExternalApi;
import buttons.Button;
import core.Load;
import core.Post;
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.text.TextField;
import ui.UserInterface;
import units.Field;
import units.*;
import wins.Window;
import wins.SimpleWindow;

internal class BigsaleItem extends LayerX {
		
		public var count:uint;
		public var sID:uint;
		public var background:Bitmap;
		public var bitmap:Bitmap;
		public var title:TextField;
		public var window:*;
		public var item:Object;
		public var price_new:Number;
		public var price_old:Number;
		public var priceLabel1:TextField;
		public var priceLabel2:TextField;
		
		private var preloader:Preloader = new Preloader();
		private var newPrice:String;
		private var sprite:LayerX;
		
		public var differList:Object = {
				3: 	{
						1:{ min :1,  max :3000, val :223 },
						2:{ min :3001,  max :7999, val :224 },
						3:{ min :7500,  max :14999, val :225 },
						4:{ min :15000,  max :49999, val :226 },
						5:{ min :50000,  max :99999, val :227 },
						6:{ min :100000,  max :-1, val :228 }
					},
				164: {
						1:{ min :1,  max :1, val :220 },
						2:{ min :2,  max :2, val :221 },
						3:{ min :3,  max :3, val :222 }
					},
				5: 	{
						1:{ min :1,  max :19, val :234 },
						2:{ min :20,  max :40, val :233 },
						3:{ min :41,  max :99, val :232 },
						4:{ min :100,  max :199, val :231 },
						5:{ min :200,  max :499, val :230 },
						6:{ min :500,  max :-1, val :229 }
					},
				2:	{
						1:{ min :1,  max :30, val :2 },
						2:{ min :31,  max :300, val :170 },
						3:{ min :301,  max :499, val :171 },
						4:{ min :500,  max :-1, val :172 }
					}
				}
				
		public function getDifferVal(sId:uint,vl:uint):uint {
			var valueList:Object = differList[sId];
			for (var itm:* in valueList) {
				if ((vl >= valueList[itm].min) && ((vl <= valueList[itm].max) || (valueList[itm].max == -1)))
					return valueList[itm].val;
			}
			return sId;
		}

		public function BigsaleItem(item:Object, window:*) {
			
			sID = item.sID;
			count = item.count;
			price_new = item.price_new;
			price_old = item.price_old;
			
			this.item = item;
			this.window = window;
			
			background = Window.backing(154, 195, 10, 'itemBacking');
			addChild(background);
			
			sprite = new LayerX();
			addChild(sprite);
			
			bitmap = new Bitmap();
			sprite.addChild(bitmap);
			
			drawCount();
			drawBttn();
			
			addChild(preloader);
			preloader.x = background.width/2;
			preloader.y = (background.height) / 2 - 35;
			
			var itemSID:int = sID;
			if (differList.hasOwnProperty(sID))	{
				itemSID = getDifferVal(sID,count);
			}
			
			if (['Golden','Gamble','Animal'].indexOf(App.data.storage[itemSID].type) >= 0) {
				Load.loading(Config.getSwf(App.data.storage[itemSID].type, App.data.storage[itemSID].view), onLoadAnimate);
			}else{
				Load.loading(Config.getIcon(App.data.storage[itemSID].type, App.data.storage[itemSID].preview), onPreviewComplete);
			}
			
			if(App.data.storage[sID].type == 'Golden'){
				var label:Bitmap = new Bitmap(Window.textures.goldLabel);
				addChild(label);
				label.smoothing = true;
				label.x = -11;
				label.y = 20;
			}
			
			sprite.tip = _tip;
		}
		
		private function _tip():Object {
			return {
					title:App.data.storage[sID].title,
					text:App.data.storage[sID].description
				}
		}
		
		public var countLabel:TextField;
		public function onPreviewComplete(data:Bitmap):void
		{
			removeChild(preloader);
			bitmap.bitmapData = data.bitmapData;
			
			bitmap.smoothing = true;
			bitmap.x = (background.width - bitmap.width)/ 2;
			bitmap.y = 20;// - 20;
			
			countLabel = Window.drawText("x" + String(count), {
				color:0xffffff,
				autoSize:'center',
				borderColor:0x41332b,
				fontSize:32
			});
			countLabel.border = false;
			countLabel.wordWrap = true;
			
			countLabel.y = background.y + 10;
			countLabel.x = background.width/2 - 45;
			addChild(countLabel);
		}
		private function onLoadAnimate(swf:*):void {
			removeChild(preloader);
			
			var anime:Anime = new Anime(swf, {w:background.width - 20, h:background.height - 20});
			anime.x = (background.width - anime.width) / 2;
			anime.y = (background.height - anime.height) / 2 - 10;
			sprite.addChild(anime);
		}
		
		public var priceBttn:Button
		public function drawBttn():void {
			var bttnSettings:Object = {
				caption:newPrice,
				fontSize:26,
				width:126,
				height:43
			};
			
			priceBttn = new Button(bttnSettings);
			addChild(priceBttn);
			priceBttn.x = background.width/2 - priceBttn.width/2;
			priceBttn.y = background.height - 22;
			
			priceBttn.addEventListener(MouseEvent.CLICK, onBuyEvent);
		}
		
		private function onBuyEvent(e:MouseEvent):void{
			if (e.currentTarget.mode == Button.DISABLED) return;				
			
			Payments.buy( {
				type:			'bigsale',
				id:				window.action.id+'_'+item.id,
				price:			price_new,
				count:			count,
				title: 			Locale.__e('flash:1382952379996'),
				description: 	Locale.__e('flash:1382952379997'),
				callback:		onBuyComplete,
				icon:			''
			});
		}
		
		private function onBuyComplete(e:* = null):void 
		{
			priceBttn.state = Button.DISABLED;
			if(sID != Stock.FANT){
				App.user.stock.add(sID, count, true);
			}
			
			var bonus:BonusItem = new BonusItem(sID, count);
			var point:Point = Window.localToGlobal(this);
			bonus.cashMove(point, App.self.windowContainer);
			
			window.close();
			
			new SimpleWindow( {
				label:SimpleWindow.ATTENTION,
				title:Locale.__e("flash:1382952379735"),
				text:Locale.__e("flash:1382952379990")
			}).show();
		}
		
		public function drawCount():void {
			var text:String;
			var textSettings:Object = { };
			switch(App.social) {
				
				case "VK":
				case "DM":
						text = 'flash:1382952379972';
					break;
				case "OK":
						text = '%d ОК';
					break;	
				case "ML":
						text = '[%d мэйлик|%d мэйлика|%d мэйликов]';
					break;
					
				case "NK":
					text = '%d €GB'; 
				break;
				case "PL":
				case "YB":
						text = '%d';	
					break;
				case "FB":
						price_old = price_old * App.network.currency.usd_exchange_inverse;
						price_old = int(price_old * 100) / 100;
					
						price_new = price_new * App.network.currency.usd_exchange_inverse;
						price_new = int(price_new * 100) / 100;
						
						text = '%d ' + App.network.currency.user_currency;	
					break;
			}
			
			var settings:Object = {
				fontSize:22,
				autoSize:"left",
				color:0xffffff,
				borderColor:0x773c18
			}
			
			var delta:int = 0;
			switch(App.social) {
				case "PL":
				case "YB":
					delta = 32;
					break;
				default: 
					delta = 0;
					break;
			}
			
			newPrice = Locale.__e(text, [price_new]), settings;
			settings['fontSize'] = 20;
			
			var priceLabel1:TextField = Window.drawText(Locale.__e(text, [price_old]), settings);
				priceLabel1.x = (background.width - priceLabel1.width - delta - 2) / 2;
				priceLabel1.y = 144;
				addChild(priceLabel1);
			
			switch(App.social) {
				case "PL":
				case "YB":
					var crystals1:Bitmap = new Bitmap(UserInterface.textures.fantsIcon, "auto", true);
					var crystals2:Bitmap = new Bitmap(UserInterface.textures.fantsIcon, "auto", true);
					
					addChild(crystals1);
					addChild(crystals2);
						
					crystals1.scaleX = crystals1.scaleY = 28/crystals1.width;
					crystals2.scaleX = crystals2.scaleY = 28/crystals2.width;
					
					crystals1.x = priceLabel1.x + priceLabel1.width + 4;
					crystals1.y = priceLabel1.y - 2;
					crystals2.x = priceLabel2.x + priceLabel2.width + 4;
					crystals2.y = priceLabel2.y - 2;
				
					break;
				default: 
					break;
			}
			
			var startCoords:Object = {
				x:priceLabel1.x - 1,
				y:priceLabel1.y + 1
			}
			
			var endCoords:Object = {
				x:priceLabel1.x + priceLabel1.width + delta  + 1,
				y:priceLabel1.y + priceLabel1.textHeight - 1
			}
				
			var line:Sprite = new Sprite();	
			line.graphics.lineStyle(2, 0xFF0000);
			line.graphics.moveTo(startCoords.x, startCoords.y);
			line.graphics.lineTo(endCoords.x, endCoords.y);
			
			addChild(line);
		}
}