package wins.elements
{
	import api.ExternalApi;
	import buttons.Button;
	import core.Load;
	import core.Post;
	import core.Size;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import ui.UserInterface;
	import units.Field;
	import units.*;
	import wins.Window;
	import wins.SimpleWindow;

	public class BigSaleItem extends LayerX {
		
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
						6:{ min :100000,  max :-1, val :227 }
					},
				164: {
						1:{ min :1,  max :1, val :220 },
						2:{ min :2,  max :2, val :221 },
						3:{ min :3,  max :3, val :222 }
					},
				5: 	{
						1:{ min :1,  max :100, val :270 },
						2:{ min :100,  max :200, val :271 },
						3:{ min :200,  max :300, val :272 },
						4:{ min :100,  max :199, val :272 },
						5:{ min :200,  max :499, val :344 },
						6:{ min :500,  max :-1, val :272 }
					},
				2:	{
						1:{ min :1,  max :30, val :2 },
						2:{ min :31,  max :300, val :170 },
						3:{ min :301,  max :499, val :171 },
						4:{ min :500,  max :-1, val :172 }
					}
				};
				
		public function getDifferVal(sId:uint,vl:uint):uint {
			var valueList:Object = differList[sId];
			for (var itm:* in valueList) {
				if ((vl >= valueList[itm].min) && ((vl <= valueList[itm].max) || (valueList[itm].max == -1)))
					return valueList[itm].val;
			}
			return sId;
		}
		
		public function getHeight():int {
			return this.height;
		}
		
		public function BigSaleItem(item:Object) {
			
			sID = item.sID;
			count = item.count;
			price_new = item.price_new;
			price_old = item.price_old;
			
			this.item = item;
			this.window = item.window;
			
			var rad:int = 70;
			var circle:Shape = new Shape();
			circle.graphics.beginFill(0xc8cabc,1);
			circle.graphics.drawCircle(rad, rad, rad);
			circle.graphics.endFill();
			
			background = new Bitmap(new BitmapData(circle.width, circle.height, true, 0xffffff));
			background.bitmapData.draw(circle);
			addChild(background);
			
			drawTitle(sID);
			
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
		
		public function drawTitle(sid:int):void 
		{
			//title = Window.drawText(String(App.data.storage[sid].title), {
			title = Window.drawText(String(App.data.storage[sID].title), {
				fontSize:24,
				textAlign:"center",
				autoSize:"center",
				color:0xffffff,
				borderColor:0x814f31,
				shadowColor:0x814f31,
				shadowSize:1,
				multiline:true,
				width:150
			});
			title.wordWrap = true;
			//title.width = title.textWidth + 5;
			title.x = background.x + background.width / 2 - title.width / 2 - 5;
			title.y = - 20;
			addChild(title);
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
			bitmap.x = background.x + (background.width - bitmap.width)/ 2;
			bitmap.y = background.y + (background.height - bitmap.height)/ 2;;// - 20;
			if (App.data.storage[sID].hasOwnProperty('out') && App.data.storage[sID].out == 1529) {
				countLabel = Window.drawText("+ " + String(App.data.storage[sID].count), {
					color:0xffefc3,
					autoSize:'center',
					borderColor:0x5e300c,
					fontSize:32,
					shadowColor:0x5e300c,
					shadowSize:1
				});
				countLabel.x = background.width / 2 - 50;
				countLabel.y = background.y + background.height + 25;
				countLabel.width = countLabel.textWidth + 5;
				addChild(countLabel);
			
				var iconWorker:Bitmap = new Bitmap(UserInterface.textures.iconWorker);
				iconWorker.x = countLabel.x + countLabel.width + 5;
				iconWorker.y = countLabel.y;
				addChild(iconWorker);
				
				bitmap.y += 10;
				background.y += 10;
			} else if (sID == 5) {
				countLabel = Window.drawText("+ " + String(count), {
					color:0xffffff,
					autoSize:'center',
					borderColor:0x3453c6,
					fontSize:32,
					shadowColor:0x3453c6,
					shadowSize:1
				});
				countLabel.x = background.width / 2 - 50;
				countLabel.y = background.y + background.height - 15;
				countLabel.width = countLabel.textWidth + 5;
				addChild(countLabel);
			
				var iconEfir:Bitmap = new Bitmap(UserInterface.textures.energyIcon);
				iconEfir.x = countLabel.x + countLabel.width + 5;
				iconEfir.y = countLabel.y;
				addChild(iconEfir);
			} else if (App.data.storage[sID].type == 'Luckybag') {
				var iconPrize:Bitmap = new Bitmap(Window.textures.rouletteGiftIco);
					iconPrize.smoothing = true;
					Size.size(iconPrize, 40, 40);
					iconPrize.x = background.width / 2 - 35;
					iconPrize.y = background.y + background.height - 15;
					addChild(iconPrize);
					
					countLabel = Window.drawText("+ " + String(App.data.storage[sID].count), {
						color:0xffffff,
						autoSize:'center',
						borderColor:0x7c3e0b,
						fontSize:32,
						shadowColor:0x3453c6,
						shadowSize:1
					});
					countLabel.x = iconPrize.x + iconPrize.width + 5;
					countLabel.y = background.y + background.height - 15;
					countLabel.width = countLabel.textWidth + 5;
					addChild(countLabel);
			}else {
				countLabel = Window.drawText("+ " + String(count), {
					color:0xd0ff74,
					autoSize:'center',
					borderColor:0x26600a,
					fontSize:32,
					shadowColor:0x3453c6,
					shadowSize:1
				});
				countLabel.x = background.width / 2 - 35;
				countLabel.y = background.y + background.height - 15;
				countLabel.width = countLabel.textWidth + 5;
				addChild(countLabel);
			}
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
			if (App.data.storage[sID].type == 'Luckybag') {
				bttnSettings['width'] = 146
			}
			priceBttn = new Button(bttnSettings);
			priceBttn.x = background.width/2 - priceBttn.width/2;
			priceBttn.y = background.y + background.height + 75;
			addChild(priceBttn);
			priceBttn.addEventListener(MouseEvent.CLICK, onBuyEvent);
			
			if (App.data.storage[sID].type == 'Luckybag') {
				priceBttn.y = background.y + background.height + 55;
			}
			
			if (App.isSocial('MX')) {
				var mxLogo:Bitmap = new Bitmap(UserInterface.textures.mixieLogo);
				mxLogo.scaleX = mxLogo.scaleY = 0.6;
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
		}
		
		private function onBuyEvent(e:MouseEvent):void{
			if (e.currentTarget.mode == Button.DISABLED) return;				
				
			Payments.buy( {
				count:			count,
				type:			'bigsale',
				id:				window.action.id+'_'+item.id,
				price:			price_new,
				title: 			Locale.__e('flash:1382952379996'),
				description: 	Locale.__e('flash:1382952379997'),
				callback: 		onBuyComplete
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
			/*switch(App.social) {
				
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
			}*/
			
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
			
			newPrice = Payments.price(price_new); //Locale.__e(text, [price_new]), settings;
			settings['fontSize'] = 20;
			
			var priceLabel1:TextField = Window.drawText(Payments.price(price_old)/*Locale.__e(text, [price_old])*/, settings);
				priceLabel1.x = (background.width - priceLabel1.width - delta - 2) / 2;
				priceLabel1.y = background.y + background.height + 40;
				
				addChild(priceLabel1);
			
			/*switch(App.social) {
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
			}*/
			
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
			
			if (App.data.storage[sID].type == 'Luckybag' || (App.data.storage[sID].hasOwnProperty('out') && App.data.storage[sID].out == 1529)) {
				priceLabel1.visible = false;
				line.visible = false;
			}
		}
	}
}