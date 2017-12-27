package wins 
{
	import buttons.Button;
	import com.protobuf.TextFormat;
	import core.Load;
	import core.Size;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import ui.UserInterface;
	public class OnceOfferWindow extends AddWindow 
	{
		public var pID:String = '';
		public var price:Number = 0;
		public var sid:String;
		public var lsid:String;
		public var titleImage:Bitmap;
		public var actionImage:Bitmap;
		
		public function OnceOfferWindow(settings:Object=null) 
		{
			if (!settings) 
				settings = { };
				
			settings['hasPaginator'] = false;
			settings['width'] = 480;
			settings['height'] = 560;
			settings['hasTitle'] = false;
			settings['popup'] = true;
			settings['promoPanelPosY'] = -40;
			
			pID = settings['pID'] || '';
			
			super(settings);
			
			action = App.data.actions[pID];
			for (sid in action.items) break;
			lsid = action.rel;
		}
		
		override public function drawBody():void {
			var title:TextField = drawText(Locale.__e('flash:1456495299670'), {
				width:settings.width,
				textAlign:'center',
				fontSize:28,
				color:0x7b3916,
				borderColor:0xffffff
			});
			title.y = 45;
			bodyContainer.addChild(title);
			
			var imageLayer:LayerX = new LayerX();
			imageLayer.tip = function():Object {
				return {
					title:	App.data.storage[sid].title,
					text:	App.data.storage[sid].description
				}
			}
			bodyContainer.addChild(imageLayer);
			
			var centralImage:Bitmap = new Bitmap();
			imageLayer.addChild(centralImage);
			Load.loading(Config.getImage('content', 'SaleEndedMaterialsPic','jpg'), function(data:*):void {
				centralImage.bitmapData = data.bitmapData;
				centralImage.x = (settings.width - centralImage.width) / 2;
				centralImage.y = 180;
			});
			
			actionImage = new Bitmap();
			imageLayer.addChild(actionImage);
			
			var titleLayer:LayerX = new LayerX();
			titleLayer.tip = function():Object {
				return {
					title:	App.data.storage[lsid].title,
					text:	App.data.storage[lsid].description
				}
			}
			bodyContainer.addChild(titleLayer);
			
			var circle:Sprite = new Sprite();
			circle.graphics.beginFill(0xcbd4cf);
			circle.graphics.drawCircle(50, 100, 50);
			circle.graphics.endFill();
			circle.x = (settings.width - circle.width) / 2;
			circle.y = 25;
			titleLayer.addChild(circle);
			
			titleImage = new Bitmap();
			titleLayer.addChild(titleImage);
			
			if (lsid)
				Load.loading(Config.getIcon(App.data.storage[lsid].type, App.data.storage[lsid].preview), function(data:*):void {
					titleImage.bitmapData = data.bitmapData;
					Size.size(titleImage, 75, 75);
					titleImage.x = circle.x + (circle.width - titleImage.width) / 2;
					titleImage.y = circle.y + (circle.height - titleImage.height) / 2 + 50;
				});
			
			var separator:Bitmap = Window.backingShort(settings.width - 120, 'dividerLine', false);
			separator.x = (settings.width - separator.width) / 2;;
			separator.y = 410;
			separator.alpha = 0.5;
			bodyContainer.addChild(separator);
			
			var separator2:Bitmap = Window.backingShort(settings.width - 120, 'dividerLine', false);
			separator2.scaleY = -1;
			separator2.x = (settings.width - separator2.width) / 2;;
			separator2.y = 490;
			separator2.alpha = 0.5;
			bodyContainer.addChild(separator2);
			
			var bg:Bitmap = Window.backing(settings.width - 120, 70, 50, 'fadeOutWhite');
			bg.x = (settings.width - bg.width) / 2;
			bg.y = separator.y + 5;
			bg.alpha = 0.4;
			bodyContainer.addChild(bg);
			
			var desc:TextField = drawText(App.data.storage[sid].description, {
				width:settings.width - 100,
				textAlign:'center',
				color:0x753e29,
				borderColor:0xffffff,
				fontSize:32,
				textLeading:1
			});
			desc.wordWrap = true;
			desc.x = 50;
			desc.y = 430;
			bodyContainer.addChild(desc);
			
			if (sid)
				Load.loading(Config.getIcon(App.data.storage[sid].type, App.data.storage[sid].preview), function(data:*):void {
					actionImage.bitmapData = data.bitmapData;
					actionImage.x = (settings.width - actionImage.width) / 2;
					actionImage.y = 180 + (230 - actionImage.height) / 2;
				});
			
			var bttnSettings:Object = {
				fontSize:30,
				width:194,
				height:53,
				x:(settings.width - 194) / 2, 
				y:settings.height - 53 - 5,
				caption:Payments.price(action.price[App.social]),
				callback:buyEvent,
				addBtnContainer:false,
				addLogo:true
			};
			
			drawButton(bttnSettings);
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
		
	}

}