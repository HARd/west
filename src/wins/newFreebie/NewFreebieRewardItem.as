package wins.newFreebie 
{
	import buttons.Button;
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import wins.Window;
	/**
	 * ...
	 * @author ...
	 */
	public class NewFreebieRewardItem extends LayerX 
	{
		private var _bg:Bitmap;
		private var _title:TextField;
		
		private var _getRewardBttn:Button;
		private var _bountyData:BountyForLevel;
		
		private var _glow:Bitmap;
		
		private var _iconName:String;
		private var _icon:Bitmap;
		
		public function NewFreebieRewardItem(bountyData:BountyForLevel, iconName:String = null) 
		{
			super();
			
			_bountyData = bountyData;
			_iconName = iconName;
			
			drawBackground()
			drawBody();
			
			NewFreebieModel.instance.addEventListener(Event.CHANGE, onModelChange);
		}
		
		private function onModelChange(e:Event):void 
		{
			updateUI();
		}
		
		private function drawBackground():void
		{
			_bg = Window.backing(150, 195, 50, "itemBacking");
			addChild(_bg);
		}
		
		private function drawBody():void
		{	
			_glow = new Bitmap(Window.textures["iconGlow"]);
			_glow.x = (width - _glow.width) * 0.5;
			_glow.y = (height - _glow.height) * 0.5;
			addChild(_glow);
			
			if (_iconName && _iconName != "" && Window.textures.hasOwnProperty(_iconName))
			{
				_icon = new Bitmap(Window.textures[_iconName]);
				_icon.x = (width - _icon.width) * 0.5;
				_icon.y = (height - _icon.height) * 0.5;
				addChild(_icon);
			}
			
			_title = Window.drawText(Locale.__e("flash:1458913928355", [String(_bountyData.level)]), {
				wrap:true,
				multiline:true,
				textAlign:"center",
				color:0x7B4D29,
				borderColor:0xFFF8E6,
				fontSize:20,
				width:_bg.width - 10
			});
			_title.x = (width - _title.width) * .5;
			_title.y = 5;
			addChild(_title);
			
			_getRewardBttn = new Button({
				width:100,
				height:40,
				fontSize:24,
				caption:Locale.__e("flash:1382952379737")
			});
			
			_getRewardBttn.x = (width - _getRewardBttn.width) * .5;
			_getRewardBttn.y = height - (_getRewardBttn.height * 0.65);
			_getRewardBttn.addEventListener(MouseEvent.CLICK, onGetRewardBttnClick);
			addChild(_getRewardBttn);
		}
		
		private function updateUI():void
		{
			
		}
		
		private function onGetRewardBttnClick(e:MouseEvent):void 
		{
			new NewFreebieRewardWindow( _bountyData, { popup:true } ).show();
		}
		
		public function dispose():void
		{
			_getRewardBttn.removeEventListener(MouseEvent.CLICK, onGetRewardBttnClick);
			NewFreebieModel.instance.removeEventListener(Event.CHANGE, onModelChange);
		}
		
		public function get currentStep():int 
		{	
			var result:int;
			
			for (var key:String in _bountyData.itemsForUsers)
			{
				if (NewFreebieModel.instance.isBountyTaken(_bountyData.level, int(key)))
					result++;
			}
			
			return result;
		}
	}
}