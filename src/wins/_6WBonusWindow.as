package wins 
{
	import api.ExternalApi;
	import buttons.Button;
	import buttons.ImageButton;
	import core.Load;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import strings.Strings;

	public class _6WBonusWindow extends Window
	{
		public var okBttn:Button;
		public var tellBttn:Button;
		
		private var titleQuest:TextField;
		private var titleShadow:TextField;
		private var descLabel:TextField;
		private var bonusList:RewardList;

		
		public function _6WBonusWindow(settings:Object = null) 
		{
			settings['width'] = 444;
			settings['height'] = 340;
			
			//settings['hasTitle'] = false;
			settings['title'] = Locale.__e("flash:1382952380249");
			settings['hasButtons'] = false;
			settings['hasPaginator'] = false;
			settings['fontColor'] = 0xffcc00;
			settings['fontSize'] = 58;
			settings['fontBorderColor'] = 0x705535;
			settings['shadowBorderColor'] = 0x342411;
			settings['fontBorderSize'] = 8;
			
			settings['bonus'] = settings.bonus || {};
			super(settings);
			
			SoundsManager.instance.playSFX("questComplete");
		}
		
		override public function drawBackground():void {
			var background:Bitmap = backing(settings.width, settings.height, 50, "itemBacking");
			layer.addChildAt(background, 0);
		}
		
		private var preloader:Preloader = new Preloader();
				
		override public function drawBody():void {
			titleLabel.y -= 40;
			
			exit.x += 30;
			exit.y -= 30;
			
			descLabel = Window.drawText(Locale.__e("You've received a special reward!\nIt has been added to your total already!"), {
				color:0x604729,
				border:false,
				fontSize:28,
				multiline:true,
				textAlign:"center"
			});
			
			descLabel.wordWrap = true;
			descLabel.width = settings.width - 60;
			descLabel.height = descLabel.textHeight + 10;
			
			bodyContainer.addChild(descLabel);
			descLabel.x = (settings.width - descLabel.width) / 2;
			descLabel.y = 6;
			
			
			okBttn = new Button( {
				//borderColor:			[0x9f9171,0x9f9171],
				//fontColor:				0x4c4404,
				//fontBorderColor:		0xefe7d4,
				//bgColor:				[0xe3d5b5, 0xc0b292],
				width:138,
				height:38,
				fontSize:26,
				caption:Locale.__e("flash:1382952380242")
			});
			bodyContainer.addChild(okBttn);
			
			okBttn.addEventListener(MouseEvent.CLICK, close);
			
			
			contentChange();
			
			okBttn.x = (settings.width - okBttn.width)/2;
			okBttn.y = settings.height - okBttn.height - 48;
			
		}
		
		
		override public function contentChange():void {
			
			bonusList = new RewardList(settings.bonus, true, settings.width - 50, 'flash:1382952380000');
			bodyContainer.addChild(bonusList);
			bonusList.x = 25;//(settings.width - bonusList.width) / 2;
			bonusList.y = 66;
			
		}
		
		override public function dispose():void {
			okBttn.removeEventListener(MouseEvent.CLICK, close);
			
			super.dispose();
		}
		
	}

}
