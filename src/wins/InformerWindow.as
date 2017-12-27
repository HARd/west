package wins 
{
	import buttons.Button;
	import buttons.MenuButton;
	import buttons.MoneyButton;
	import core.Load;
	import core.Numbers;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.Font;
	import flash.text.TextField;
	import flash.text.TextFormatAlign;
	import flash.text.TextLineMetrics;
	import flash.utils.setTimeout;
	import units.Anime;
	import units.Hut;
	import units.Unit;
	import wins.actions.BanksWindow;

	public class InformerWindow extends Window
	{
		private var items:Array = new Array();
		private var container:Sprite;
		private var priceBttn:Button;
		private var okBttn:Button;
		private var descriptionLabel:TextField;
		private var informer:Object = { };
		public var windowType:int = 0;
		public var animate:Boolean = false;
		
		private const IMAGE_INDENT:int = 60;
		private const IMAGE_WIDTH:int = 70;
		
		public function InformerWindow(settings:Object = null)
		{
			if (settings == null) {
				settings = new Object();
			}
			
			informer = settings.informer;
			informer['utype'] = App.data.storage[informer.object].type;
			informer['uview'] = App.data.storage[informer.object].view;
			settings['width'] = settings.width || ((informer.winwidth) ? informer.winwidth : ((informer.type == 0) ? 450 : 650));
			settings['height'] = settings.height || ((informer.winheight) ? informer.winheight : 330);
			
			descriptionLabel = drawText(informer.text, {
				fontSize:26,
				autoSize:"left",
				textAlign:TextFormatAlign.LEFT,
				color:0x502f06,
				borderColor:0x502f06,
				border:false,
				multiline:true
			});
			descriptionLabel.wordWrap = true;
			descriptionLabel.x = informer.left;
			//descriptionLabel.y = informer.padding;
			descriptionLabel.width = informer.width;
			descriptionLabel.height = descriptionLabel.textHeight;
			
			if (descriptionLabel.numLines > 7 && !informer.winwidth)
			{
				var delta:int = (descriptionLabel.numLines - 7) * descriptionLabel.getLineMetrics(0).height;
				settings['height'] = 330 + delta;
			}
			
			settings['title'] = informer.title;
			settings['hasExit'] = false;
			settings['hasPaginator'] = false;
			settings['hasButtons'] = false;
			settings['fontColor'] = 0xfffef5;
			settings['fontSize'] = 60;
			settings['fontBorderColor'] = 0xb98659;
			settings['shadowBorderColor'] = 0x342411;
			//settings['fontBorderSize'] = 5;
			settings['autoClose'] = false;
			
			/*if (informer.utype == 'Golden')
				animate = true;*/
			
			super(settings);
		}
		
		override public function drawTitle():void 
		{
			titleLabel = titleText( {
					title				: settings.title,
					color				: settings.fontColor,
					multiline			: settings.multiline,
					fontSize			: settings.fontSize,
					textLeading	 		: settings.textLeading,
					borderColor 		: settings.fontBorderColor,
					borderSize 			: settings.fontBorderSize,
					shadowSize			: settings.shadowSize,
					shadowColor			: settings.shadowColor,
					
					shadowBorderColor	: settings.shadowBorderColor || settings.fontColor,
					width				: (settings.hasExit)?settings.width - 140:settings.width,
					textAlign			: 'center',
					sharpness 			: 50,
					thickness			: 50,
					border				: true,
					mirrorDecor			: settings.mirrorDecor
				});
				
				titleLabel.x = (settings.width - titleLabel.width) * .5;
				titleLabel.y = -16;
				titleContainer.addChild(titleLabel);
				titleContainer.mouseEnabled = false;
				titleContainer.mouseChildren = false;
		}
		
		public static var showed:Boolean = false;
		public static function init():void {
			if (showed || !App.data.hasOwnProperty('inform')) return;
			
			var informers:Array = [];
			for (var s:String in App.data.inform) {
				var isSocial:Boolean = false;
				if (App.data.inform[s]['social']) {
					for each(var soc:String in App.data.inform[s].social) {
						if ((soc is String) && soc == App.social)
							isSocial = true;
					}
				}
				
				if (isSocial && App.data.inform[s].enabled && App.data.inform[s].start < App.time && App.data.inform[s].finish > App.time) {
					App.data.inform[s]['id'] = s;
					informers.push(App.data.inform[s]);
				}
			}
			informers.sortOn('order', Array.NUMERIC);
			showed = true;
			
			if (informers.length > 0) {
				var count:int = App.user.storageRead('informer' + informers[informers.length - 1].id, 0);
				if (informers[informers.length - 1].hasOwnProperty('count') && informers[informers.length - 1].count!= '' && informers[informers.length - 1].count > count) {
					setTimeout(function(object:Object):void {
						new InformerWindow( {
							informer:	object
						}).show();
					}, 10000, informers[informers.length - 1]);
				}
			}
		}
		
		override public function drawBackground():void {
			var background:Bitmap = backing(settings.width, settings.height, 50, 'alertBacking');
			layer.addChild(background);
		}
		
		
		override public function drawBody():void {
			
			titleLabel.x = (settings.width - titleLabel.width) / 2 /*+ 60*/;
			//titleLabel.y = 10;
			
			/*drawMirrowObjs('diamondsTop', settings.width / 2 - settings.titleWidth / 2 - 5, settings.width / 2 + settings.titleWidth / 2 + 5, titleLabel.y + 10, true, true);
			drawMirrowObjs('storageWoodenDec', -5, settings.width + 5, 75, false, false, false, 1, -1);
			drawMirrowObjs('storageWoodenDec', -5, settings.width + 5, settings.height - 70);*/
			
			//descriptionLabel.y = titleLabel.y + titleLabel.height + 10;
			descriptionLabel.y = informer.padding;
			
			bodyContainer.addChild(titleLabel);
			bodyContainer.addChild(descriptionLabel);
			drawImage();
			
			okBttn = new Button( {
				caption:getBttnCaption(),	// Закрыть
				//caption:Locale.__e('flash:1382952380228'),	// Показать
				fontSize:22,
				width:200,
				height:50
			});
			
			bodyContainer.addChild(okBttn);
			if (informer.type == 2) {
				okBttn.x = (settings.width - okBttn.width) / 2;
				okBttn.y = settings.height - okBttn.height - 15;
			}else{
				okBttn.x = (settings.width - okBttn.width) / 2;
				okBttn.y = settings.height - okBttn.height - 15;
			}
			
			okBttn.addEventListener(MouseEvent.CLICK, onOkBttn);
			
			if (descriptionLabel.height < bodyContainer.height) {
				descriptionLabel.y = Math.floor((bodyContainer.height - descriptionLabel.height) / 2) + 10;
			}
		}
		
		private function getBttnCaption():String {
			if (informer['type'] && informer.type == 2) {
				return Locale.__e('flash:1382952380228');
			}
			
			return Locale.__e('flash:1382952379995');
		}
		
		private function onOkBttn(e:MouseEvent):void {
			
			switch(informer['type']) {
				case 3:
					break;
				case 2:
					new BanksWindow().show();
					break;
				case 1:
					/*if (App.user.mode == User.OWNER && App.user.worldID == 171) {
						var list:Array = Map.findUnits([1095]);
						if (list.length > 0) {
							list[0].find = informer.object;
							App.map.focusedOn(list[0], true, null, true);
							this.close();
						}else if(User.inUpdate(1095)){
							new ShopWindow( { find:[1095] } ).show();
						}
					}
					break;*/
				case 0:
					ShopWindow.show( { find:[informer.object] } );
					break;
				default:
					//
					
			}
			
			close();
		}
		
		
		private function drawImage():void {
			if (animate) {
				Load.loading(Config.getSwf(informer.utype, informer.uview), function(data:*):void {
					var framesType:String = informer.view;
					for (framesType in data.animation.animations) break;
					
					var image:Sprite = new Sprite();
					image.x = informer.X;
					image.y = informer.Y;
					image.scaleX = image.scaleY = informer.scale;
					bodyContainer.addChildAt(image, 0);
					
					var bitmap:Bitmap = new Bitmap(data.sprites[data.sprites.length - 1].bmp, 'auto', true);
					bitmap.x = data.sprites[data.sprites.length - 1].dx;
					bitmap.y = data.sprites[data.sprites.length - 1].dy;
					image.addChild(bitmap);
					
					var anime:Anime = new Anime(data/*, framesType, data.animation.ax, data.animation.ay*/);
					image.addChild(anime);
					//anime.frame = 0;
					//anime.animate();
					//anime.startAnimation();
					
					/*var glow:Bitmap = new Bitmap(Window.textures.actionGlow, 'auto', true);
					glow.scaleX = glow.scaleY = 1.1;
					glow.x = informer.X + (anime.width - glow.width) / 2;
					glow.y = informer.Y + (anime.height - glow.height) / 2;
					bodyContainer.addChildAt(glow, 0);*/
				});
			}else{
				Load.loading(Config.resources + informer.image, function(data:Bitmap):void {
					var image:Bitmap = new Bitmap(data.bitmapData);
					image.smoothing = true;
					image.x = informer.X;
					image.y = informer.Y;
					image.scaleX = image.scaleY = informer.scale;
					bodyContainer.addChild(image);
					
					var glow:Bitmap = new Bitmap(Window.textures.glow, 'auto', true);
					glow.scaleX = glow.scaleY = 1.1;
					glow.x = image.x + (image.width - glow.width) / 2;
					glow.y = image.y + (image.height - glow.height) / 2;
					bodyContainer.addChild(glow);
					
					bodyContainer.swapChildren(image, glow);
				});
			}
		}
		
		override public function dispose():void {
			while (bodyContainer.numChildren > 0) {
				bodyContainer.removeChildAt(0);
			}
			
			if (informer.hasOwnProperty('count') && informer.count != '') {
				var count:int = App.user.storageRead('informer' + informer.id, 0);
				count++;
				App.user.storageStore('informer' + informer.id, count, true);	
			}
			
			super.dispose();
		}
	}
}