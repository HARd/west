package wins 
{
	import buttons.Button;
	import core.Load;
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.utils.setTimeout;
	
	public class HelpWindow extends Window 
	{
		
		private var priceBttn:Button;
		private var type:int;
		
		public function HelpWindow(settings:Object=null) 
		{
			if (!settings) settings = {};
			settings['width'] = settings['width'] || 500;
			settings['height'] = settings['height'] || 400;
			settings['title'] = settings['title'] || Locale.__e('flash:1413366714819');
			settings['hasPaginator'] = false;
			settings['background'] = 'questBacking';
			type = settings['type'] || 0;
			
			super(settings);
		}
		
		public static function testToShow(type:int, params:Object):void {
			if (type == 1) {
				if (params['qID'] == 36) {
					setTimeout(function():void {
						new HelpWindow( { type:1 } ).show();
					}, 5000);
				}
			}
		}
		
		override public function drawBody():void {
			exit.y -= 20;
			exit.x += 4;
			
			var effect:Bitmap = Window.backingShort(400, 'magicFog');
			bodyContainer.addChild(effect);
			effect.x = (settings.width - effect.width) / 2;
			effect.y = (settings.height - effect.height) / 2;
			
			drawMirrowObjs('storageWoodenDec', -4, settings.width + 4, 44, false, false, false, 1, -1);
			drawMirrowObjs('storageWoodenDec', -4, settings.width + 4, settings.height - 68, false, false, true, 1, 1);
			
			loadingContent();
			
			for (var s:String in texts) {
				var textField:TextField = Window.drawText(texts[s].txt, {
					textAlign:		'center',
					width:			300,
					color:			0xfdf0d0,
					borderColor:	0x734917,
					fontSize:		texts[s].size,
					multiline:		true,
					wrap:			true
				});
				textField.x = texts[s].x;
				textField.y = texts[s].y;
				bodyContainer.addChild(textField);
			}
			
			drawMirrowObjs('diamondsTop', settings.width / 2 - settings.titleWidth / 2 - 5, settings.width / 2 + settings.titleWidth / 2 + 5, -34, true, true);
			
			drawBttn();
		}
		
		private function drawBttn():void 
		{
			var bttnSettings:Object = {
				fontSize:36,
				width:186,
				height:52,
				caption:Locale.__e('flash:1404394519330')
				//hasDotes:true
			};
			
			var text:String;
			
			if (priceBttn != null)
				bodyContainer.removeChild(priceBttn);
			
			priceBttn = new Button(bttnSettings);
			priceBttn.x = (settings.width - priceBttn.width) / 2;
			priceBttn.y = (settings.height - 50);
			bodyContainer.addChild(priceBttn);
			
			priceBttn.addEventListener(MouseEvent.CLICK, close);
		}
		
		private var texts:Object = {
			0:{txt:Locale.__e('flash:1413366794950'), bmd:null, scale:0.6, x:189, y:2, size:32},		// Не знаешь что делать,\n без Нектара?
			1:{txt:Locale.__e('flash:1413366904893'), bmd:null, scale:0.6, x:214, y:78, size:27},		// Сажай грядки!
			2:{txt:Locale.__e('flash:1413366942901'), bmd:null, scale:0.6, x:-9, y:227, size:29},		// Поливай деревья
			3:{txt:Locale.__e('flash:1413366997778'), bmd:null, scale:0.6, x:12, y:265, size:30}		// Эти действия не требуют Нектара!
		}
		private var info:Array = [
			{x:-57, y:-37, type:'promo', preview:'images/fermer_pack_2'},
			{x:60, y:22, type:'promo', preview:'images/fermer_pack_0'},
			{x:302, y:124, type:'promo', preview:'images/tree_0'}
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