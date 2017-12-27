package wins.actions 
{
	import buttons.Button;
	import buttons.ImageButton;
	import core.Load;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormatAlign;
	import flash.display.Sprite;
	import core.Post;
	import api.ExternalApi;
	import ui.UserInterface;
	import wins.AddWindow;
	import wins.SimpleWindow;
	import wins.Window;
	/**
	 * ...
	 * @author ...
	 */
	public class ShareHeroWindow extends AddWindow 
	{
		public var missions:Array = [];
		
		public var okBttn:Button;
		
		public var quest:Object = { };
		private var titleQuest:TextField;
		private var titleShadow:TextField;
		private var descLabel:TextField;
		private var timerText:TextField;
		
		private var arrowLeft:ImageButton;
		private var arrowRight:ImageButton;
		
		private var prev:int = 0;
		private var next:int = 0;
		private var _startMissionPosY:int = 140;
		
		private var _winContainer:Sprite;
		
		public var isDuration:Boolean = false;
		
		private var back:Bitmap;
		
		private var descriptionLabel:TextField;
		private var descriptionLabelBronko:TextField;
		private var axeX:int
		public var items:Array = new Array();
		public var container:Sprite;
		
		public function ShareHeroWindow(settings:Object=null) 
		{
			action = App.data.actions[settings.pID];
			action['id'] = settings.pID;
			settings['width'] = 429;
			settings['height'] = 410;
			settings['hasTitle'] = false;
			settings['hasButtons'] = false;
			settings['hasPaginator'] = false;
			settings["background"] = 'questBacking';  //questsSmallBackingTopPiece   questsMainBacking
			
			settings['hasFader'] = true;
			
/*			action['texts'] = [
				'Давай я покажу, как нада обращаться с этими механизмами! Не зря у меня самый большой циркуль в Королевстве!',
				'Инженер Бронко умеет находить редкие предметы, а также приносить елементы Инженерной колекции.',
				'Новый персонаж вего за:'
			]*/
			
			descriptionLabel = drawText(action.text1, {
				color:0x624614,
				borderColor:0xfee8b9,
				fontSize:30,
				multiline:true,
				textAlign:"center",
				leading: 25,
				wrap:true,
				width:260		
			});
			descriptionLabel.x = 40;
			descriptionLabel.wordWrap = true;
			
			
			
			descriptionLabelBronko = drawText(action.text2, {
				color:0xfefce5,
				borderColor:0x784820,
				fontSize:27,
				multiline:true,
				textAlign:"center",
				leading:-4,
				wrap:true,
				width:260		
			});
			descriptionLabelBronko.wordWrap = true;
			
			super(settings);
		}
		
		
		/*override public function drawBackground():void 
		{
			if (missions.length == 3)
			{
				bodyContainer.y += 40;
				exit.y += 40;
			}
		}*/
		

		
		private function drawBttn():void {
			okBttn = new Button( {
				width:180,
				height:57,
				fontSize:33,
				hasDotes:false,
				caption:"1 голос"
			});
			okBttn.x = (settings.width - okBttn.width) / 2;
			okBttn.y = (settings.height);
			bodyContainer.addChild(okBttn);
			
			okBttn.addEventListener(MouseEvent.CLICK, close);
		}
		
		private var cont:Sprite;
		public function drawPrice2():void {
			
			var bttnSettings:Object = {
				fontSize:36,
				width:186,
				height:52,
				hasDotes:false
			};
			
			if (priceBttn != null)
				bodyContainer.removeChild(priceBttn);
			
			bttnSettings['caption'] = Payments.price(action.price[App.social]);
			priceBttn = new Button(bttnSettings);
			bodyContainer.addChild(priceBttn);
			priceBttn.x = axeX - priceBttn.width / 2 -25;
			priceBttn.y = settings.height - priceBttn.height / 2 + 30;//135;
			
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
			
			priceBttn.addEventListener(MouseEvent.CLICK, buyEvent);
			
			if (cont != null)
				bodyContainer.removeChild(cont);
				
			cont = new Sprite();
			
			bodyContainer.addChild(cont);
			cont.x = priceBttn.x + priceBttn.width / 2 - cont.width / 2;
			cont.y = priceBttn.y - 30;
		}
		
		private var preloader:Preloader = new Preloader();
		override public function drawBody():void 
		{
			drawMessage();
			
			var character:Bitmap = new Bitmap();
			bodyContainer.addChild(character);
			bodyContainer.addChild(preloader);
			preloader.x = -138;
			preloader.y = 184;
			
			Load.loading(Config.getQuestIcon('preview', action.image), function(data:*):void { 
				bodyContainer.removeChild(preloader);
				
				character.bitmapData = data.bitmapData;
				var addY:int;
				if (missions.length == 3)
				{
					addY = 40;	
				}
				switch(action.image) {
					case 'dragon':
						character.x = -(character.width / 4) * 3 - 50/* + 120*/;
						character.y = -90 + addY;
					break;
					case 'druid':
						character.x = -(character.width / 4) * 3 - 20;
						character.y = -80 + addY;
					break;
					case 'engineer':
						character.x = -(character.width / 4) * 2 - 12;
						character.y = -60 + addY;
					break;
					case 'evil':
						character.x = -(character.width / 4) * 3 + 250;
						character.y = -70 + addY;
					break;
					case 'minion':
						character.x = -(character.width / 4) * 3 - 50;
						character.y = -90 + addY;
					break;
					case 'ranger':
						character.x = -(character.width / 4) * 3 - 37;
						character.y = -120 + addY;
					break;
					case 'AI':
						character.x = -(character.width / 4) * 3 - 20;
						character.y = -72 + addY;
					break;
					default:
						character.x = -character.width + 60;
						character.y = 0 + addY;
						break;
				}
				
			});
			
			descriptionLabel.y = 10;
			
			descriptionLabel.width =  350;
			descriptionLabel.height =  280;
			
			
			descriptionLabelBronko.y = 	settings.height - descriptionLabelBronko.height - 75;
			descriptionLabelBronko.x =  (settings.width - descriptionLabelBronko.width) / 2 + 20;
			bodyContainer.addChild(descriptionLabel);
			bodyContainer.addChild(descriptionLabelBronko);
			
			var ribbon:Bitmap = backingShort(settings.width + 210, 'questRibbon');
			ribbon.y = settings.height - ribbon.height / 2;
			ribbon.x = (settings.width - ribbon.width) / 2;
			
			bodyContainer.addChild(ribbon);
			var ribbonText:TextField = drawText(action.text3, {
				fontSize	:27,
				autoSize	:"left",
				textAlign	:"center",
				color		:0xffffff,
				borderColor	:0x8140a7
			});
			
			ribbonText.y = 	settings.height - ribbonText.height;
			ribbonText.x =  (settings.width - ribbonText.width) / 2;;
			
			bodyContainer.addChild(ribbonText);
			if(settings['L'] <= 3)
				axeX = settings.width - 170;
			else
				axeX = settings.width - 190;
				
			drawPrice2();
			
		}
		
		private function drawMessage():void 
		{
			var titlePadding:int = 20;
			var descPadding:int = 51;
			var descMarginX:int = 10;
			
			_winContainer = new Sprite();
			titleQuestContainer = new Sprite();
			titleQuest = Window.drawText(Locale.__e("flash:1396521604876"), {
				color:0xFFFFFF,
				borderColor:0xa9784b,
				fontSize:50,
				multiline:true,
				textAlign:"center",
				wrap:true,
				width:260		
			});
			titleQuest.wordWrap = true;
			
			var myGlow:GlowFilter = new GlowFilter();
			myGlow.strength = 20;
			myGlow.blurX = 5;
			myGlow.blurY = 5;
			myGlow.color = 0x916234;
			
			titleQuest.wordWrap = true;
			titleQuest.width;
			
			var descSize:int = 28;
			
			do{
				descLabel = Window.drawText(quest.description, {//quest.description.replace(/\r/g,""), {
					color:0x624512, 
					border:false,
					fontSize:descSize,
					multiline:true,
					textAlign:"center"
				});
				
				descLabel.wordWrap = true;
				descLabel.width = 300;
				descLabel.height = descLabel.textHeight + 40;
				descSize -= 1;	
			}
			while (descLabel.height > 140) 
		
			var curHeight:int;
			if (titleQuest.height < 60) {
				curHeight = titleQuest.height + descLabel.height + titlePadding;
			}else
			{
				curHeight = titleQuest.height + descLabel.height + titlePadding - 25;
			}
			
			var marginSpriteY:int = 65;

			bg = Window.backing(380,  225, 80, 'dialogueBacking');
			bg.y = _startMissionPosY + marginSpriteY - bg.height;
			bg.x = -50;
			titleQuest.height = titleQuest.textHeight + 10; 
			titleQuest.y = bg.y - titleQuest.height / 2 + 10;
			titleQuest.y += 10;
			titleQuest.x = bg.x + bg.width/2 - titleQuest.width/2;
			
			//descLabel.y = (titleQuest.y + titleQuest.height) - descSize/2 + 10;
			//descLabel.y = (titleQuest.y + descLabel.height/2) - 20;
			descLabel.y = titleQuest.y + titleQuest.height - 7;
			if (titleQuest.height >= 70)
			{
				descLabel.y = titleQuest.y + titleQuest.height - 10;
			}
			
			var star1:Bitmap = new Bitmap(Window.textures.productionReadyBacking2);
			star1.y += 120;
			star1.x += 40;
			star1.scaleY = 0.8;
			bodyContainer.addChild(star1);
			descLabel.x = descMarginX - 22;
			
			//if (descSize >= 26)
			//{
				//descLabel.y = (titleQuest.y + titleQuest.height) - 20;
			//}
			
			
			
			_winContainer.addChild(bg);
			titleQuestContainer.addChild(titleQuest);
			_winContainer.addChild(titleQuestContainer);
			_winContainer.addChild(descLabel);
			titleQuestContainer.filters = [myGlow];
			bodyContainer.addChild(_winContainer);
			titleQuest.textWidth
			
			_winContainer.x = (settings.width - _winContainer.width) / 2 + 50;
			_winContainer.y = (settings.height - _winContainer.height*1.8);
			
			
			
			var rose:Bitmap = new Bitmap(Window.textures.diamondsTop);
			_winContainer.addChild(rose);
			rose.x = titleQuest.x;
			rose.y = titleQuest.y + titleQuest.height/2 - rose.height/2;
			
			var rose2:Bitmap = new Bitmap(Window.textures.diamondsTop);
			_winContainer.addChild(rose2); rose2.scaleX = -1;
			rose2.x = titleQuest.x + titleQuest.width;
			rose2.y = rose.y;
			
			exit.x -= 8;
			exit.y -= 70;
			
		}
		
		
		
		private var titleQuestContainer:Sprite;
		private var bg:Bitmap;
		
		
		
		override public function dispose():void {
			if (okBttn)
				okBttn.removeEventListener(MouseEvent.CLICK, close);
			if (_winContainer && _winContainer.parent)_winContainer.parent.removeChild(_winContainer);
			_winContainer = null;
			super.dispose();
		}
		
	}

}


