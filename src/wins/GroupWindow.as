package wins {
	
	import api.ExternalApi;
	import buttons.Button;
	import buttons.CheckboxButton;
	import core.Load;
	import core.Log;
	import core.Post;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.filters.DropShadowFilter;
	import flash.geom.ColorTransform;
	import flash.net.navigateToURL;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.utils.setTimeout;
	
	public class GroupWindow extends Window {
		
		private var bitmapImage:Bitmap;
		private var bitmapTitle:Bitmap;
		private var descLabel:TextField;
		private var desc2Label:TextField;
		private var checkBttn:CheckboxButton;
		private var enterBttn:Button;
		public static var inGroup:Boolean = false;
		public static var groupLink:String = '';
		
		public function GroupWindow(settings:Object = null) {
			if (!settings) settings = { };
			settings['width'] = settings['width'] || 590;
			settings['height'] = settings['height'] || 410;
			settings['title'] = Locale.__e('flash:1427453937987');
			settings['hasPaginator'] = false;
			settings['background'] = 'alertBacking';
			
			super(settings);
		}
		
		override public function drawTitle():void {
			var textSize:int = 30;
			switch(App.lang) {
				case 'ru':
					textSize = 46;
					break;
				case 'en':
					textSize = 30;
					break;
				case 'fr':
					textSize = 26;
					break;
				case 'es':
					textSize = 26;
					break;
				case 'pl':
					textSize = 46;
					break;
				case 'nl':
					textSize = 30;
					break;
				case 'de':
					textSize = 46;
					break;
				case 'it':
					textSize = 46;
					break;
				case 'pt':
					textSize = 46;
					break;
			}
			//do {
				titleLabel = titleText( {
					title				: settings.title,
					color				: 0xffffff,
					multiline			: settings.multiline,			
					fontSize			: textSize,
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
				titleLabel.y = - titleLabel.height / 2;
				titleLabel.mouseChildren = titleLabel.mouseEnabled = false;
				
				textSize--;
			//} while (titleLabel.getChildAt(0).width > 50)
			headerContainer.addChild(titleLabel);
			
			headerContainer.y = 20;
			headerContainer.mouseEnabled = false;
		}
		
		public static function addWindow():void {
			//if (App.isSocial('VK', 'OK', 'MM', 'FB') && App.user.level >= 4 && App.user.storageRead('gw', 1) == 1) {
				//// Найти ссылку на группу для соцсети
				//if (App.data.options.hasOwnProperty('GroupLinks')) {
					//var soc:Object = JSON.parse(App.data.options.GroupLinks);
					//if (soc.hasOwnProperty(App.social))
						//groupLink = soc[App.social];
				//}
				//
				//// Если ссылки нет (groupLink == null) не показываем окно
				//if (groupLink.length == 0) return;
				//
				//// Проверяем наличие в группе и показываем окно
				//if (ExternalInterface.available) {
					//ExternalApi.checkGroupMember(function(param:*):void {
						//if (param == 1)
							//inGroup = true;
					//});
					//setTimeout(function():void {
						//if (!inGroup) {
							//new GroupWindow().show();
						//}
					//}, 5000);
				//}else {
					new GroupWindow().show();
				//}
			//}
		}
		
		override public function drawBackground():void {
			var background:Bitmap = backing(settings.width, settings.height, 50, settings.background);
			layer.addChild(background);
		}
		
		override public function drawBody():void {
			super.drawBody();
			
			exit.y = -20;
			
			// Рисование элементов
			var imageP:Preloader = new Preloader();
			imageP.x = settings.width / 2;
			imageP.y = 120;
			bodyContainer.addChild(imageP);
			
			bitmapImage = new Bitmap();
			bodyContainer.addChild(bitmapImage);
			
			descLabel = Window.drawText(Locale.__e('flash:1427454582064'), {
				width:			400,
				textAlign:		'center',
				fontSize:		26,
				color:			0xfcffc7,
				borderColor:	0x432503,
				borderSize:		4,
				shadowColor:	0x50413e,
				shadowSize:		1,
				textLeading:	-9,
				multiline:      true
			});
			descLabel.wordWrap = true;
			descLabel.x = (settings.width - descLabel.width) / 2;
			descLabel.y = 220;
			bodyContainer.addChild(descLabel);
			
			// блок выбора - показывать окно в следующий раз или нет
			var checkCont:Sprite = new Sprite();
			checkBttn = new CheckboxButton( {
				width: 150,
				multiline:false,
				wordWrap:false,
				fontSize:20,
				captionChecked:Locale.__e('flash:1427455600184'),
				captionUnchecked:Locale.__e('flash:1427455600184')
				//state:		CheckboxButton.PASSIVE
			});
			checkCont.addChild(checkBttn);
			
			checkCont.x = (settings.width - checkCont.width) / 2 + 30;
			//checkCont.y = descLabel.y + descLabel.height + 5;
			bodyContainer.addChild(checkCont);
			
			enterBttn = new Button( {
				fontSize:	32,
				width:		186,
				height:		50,
				caption:	Locale.__e('flash:1406302453974')
			});
			enterBttn.x = (settings.width - enterBttn.width) / 2;
			enterBttn.y = settings.height - enterBttn.height * 2 + 10;//checkCont.y + checkCont.height + 5;
			bodyContainer.addChild(enterBttn);
			enterBttn.addEventListener(MouseEvent.CLICK, onEnter);
			
			checkCont.y = enterBttn.y - checkCont.height - 10;
			checkBttn.checked = CheckboxButton.UNCHECKED;
			
			Load.loading(Config.getImage('promo/images', 'GroupPic'), function(data:Bitmap):void {
				if (bodyContainer.contains(imageP)) bodyContainer.removeChild(imageP);
				
				bitmapImage.bitmapData = data.bitmapData;
				bitmapImage.smoothing = true;
				bitmapImage.x = (settings.width - bitmapImage.width) / 2;
				bitmapImage.y = titleLabel.y + titleLabel.height;
			});
		}
		
		public function onEnter(e:MouseEvent = null):void {
			Log.alert('Group link ' + App.self.flashVars.group);
			if (checkBttn.checked == CheckboxButton.CHECKED) App.user.storageStore('gw', 1);
			//if (groupLink.length > 0)
				navigateToURL(new URLRequest(App.self.flashVars.group), "_blank");
			
			close();
		}
		
		override public function close(e:MouseEvent = null):void {
			if (checkBttn) {
				if (checkBttn.checked == CheckboxButton.CHECKED) App.user.storageStore('gw', 1);
			}
			super.close();
		}
		
		override public function dispose():void {
			super.dispose();
			
			if (enterBttn) enterBttn.removeEventListener(MouseEvent.CLICK, onEnter);
		}
	}
}