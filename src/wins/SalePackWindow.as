package wins 
{
	import api.ExternalApi;
	import buttons.Button;
	import core.Load;
	import core.Post;
	import flash.display.Bitmap;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import ui.UserInterface;
	
	public class SalePackWindow extends AddWindow 
	{
		private var textLabel:TextField;
		
		public function SalePackWindow(settings:Object=null) 
		{
			settings['width'] = settings['width'] || 500;
			settings['height'] = settings['height'] || 390;
			settings['title'] = settings['title'] || Locale.__e('flash:1413283414386');
			settings['hasPaginator'] = false;
			settings['background'] = 'questBacking';
			settings['promoPanel'] = true;
			
			action = App.data.actions[settings.pID];
			action['id'] = settings.pID;
			
			super(settings);
			
		}
		
		override public function drawBody():void {
			exit.y -= 20;
			exit.x += 4;
			
			loadingContent();
			
			for (var s:String in texts) {
				var bitmap:Bitmap = new Bitmap(texts[s].bmd, 'auto', true);
				bitmap.scaleX = 1;// texts[s].scale;
				bitmap.scaleY = texts[s].scale;
				bitmap.x = texts[s].x;
				bitmap.y = texts[s].y;
				bodyContainer.addChild(bitmap);
				
				var textField:TextField = Window.drawText(texts[s].txt, {
					autoSize:		'center',
					color:			0xfdf0d0,
					borderColor:	0x734917,
					fontSize:		36
				});
				textField.x = bitmap.x + (bitmap.width - textField.width) / 2;
				textField.y = bitmap.y + (bitmap.height - textField.height) / 2;
				bodyContainer.addChild(textField);
			}
			
			var stripe:Bitmap = Window.backingShort(settings.width + 160, 'questRibbon');
			bodyContainer.addChild(stripe);
			stripe.x = (settings.width - stripe.width) / 2;
			stripe.y = settings.height - stripe.height + 25;
			
			textLabel = Window.drawText(Locale.__e('flash:1413283255440'), {
				width:		settings.width - 20,
				color:		0xffffff,
				borderColor:0x823ea1,
				fontSize:	25,
				textAlign:	'center'
			})
			textLabel.x = (settings.width - textLabel.width) / 2;
			textLabel.y = stripe.y + (stripe.height - textLabel.height) / 2 - 16;
			bodyContainer.addChild(textLabel);
			
			drawMirrowObjs('diamondsTop', settings.width / 2 - settings.titleWidth / 2 - 5, settings.width / 2 + settings.titleWidth / 2 + 5, -34, true, true);
			drawMirrowObjs('storageWoodenDec', -4, settings.width + 4, 44, false, false, false, 1, -1);
			//drawMirrowObjs('storageWoodenDec', -4, settings.width + 4, settings.height - 68, false, false, true, 1, 1);
			var bttnSettings:Object = {
				fontSize:36,
				width:186,
				height:52,
				x:(settings.width - 186) / 2,
				y:(settings.height - 25),
				caption:Payments.price(action.price[App.social]),
				callback:buyEvent,
				addBtnContainer:false,
				addLogo:true
			};
			
			drawButton(bttnSettings);
		}
		
		private var texts:Object = {
			0:{txt:Locale.__e('flash:1413283200991', [2]), bmd:Window.texture('saleTextBacking'), scale:0.6, x:-50, y:68},
			1:{txt:Locale.__e('flash:1413283164842', [50]), bmd:Window.texture('saleTextBacking'), scale:0.6, x:260, y:40},
			2:{txt:Locale.__e('flash:1413283096501', [1]), bmd:Window.texture('saleTextBacking'), scale:0.6, x:140, y:245}
		}
		private var info:Array = [
			{x:300, y:-100, type:'promo', preview:'images/fermer_pack_1'},
			{x:47, y:-20, type:'promo', preview:'images/fermer_pack_2'},
			{x:-54, y:120, type:'promo', preview:'images/fermer_pack_0'},
			{x:165, y:110, type:'promo', preview:'images/fermer_pack_3'}
		]
		public function loadingContent():void {
			for (var i:int = 0; i < info.length; i++) {
				var image:Image = new Image(info[i]);
				image.x = info[i].x;
				image.y = info[i].y;
				bodyContainer.addChild(image);
			}
		}
	}

}


import core.Load;
import flash.display.Bitmap;
import flash.display.Sprite;

internal class Image extends Sprite {
	
	public var bitmap:Bitmap;
	
	public function Image(info:Object) {
		Load.loading(Config.getImageIcon(info.type, info.preview), onLoad);
	}
	
	public function onLoad(data:Bitmap):void {
		bitmap = new Bitmap();
		bitmap.bitmapData = data.bitmapData;
		bitmap.smoothing = true;
		addChild(bitmap);
	}
	
}