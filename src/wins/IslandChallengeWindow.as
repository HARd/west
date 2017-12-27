package wins 
{
	import adobe.utils.CustomActions;
	import buttons.Button;
	import buttons.ImageButton;
	import core.Load;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import ui.UserInterface;
	import units.Thappy;
	
	public class IslandChallengeWindow extends Window
	{
		
		private var leftTeamContainer:Sprite;
		private var rightTeamContainer:Sprite;
		
		private var descriptionLabel:TextField		
		
		private var giftsBacking:Number;
		private var helpBttn:ImageButton;
		private var sid:int;
		public static const OPEN:int = 1;
		public static const CHALLENGE:int = 2;
		public var mode:int = 1;
		public function IslandChallengeWindow(settings:Object=null) 
		{	
			if (!settings) settings = { };
			
			settings.onSelect;
			settings['width'] = settings['width'] || 830;
			settings['height'] = settings['height'] || 570;
			settings['title'] = settings.title ||Locale.__e ( "flash:1467191768995");
			settings['hasPaginator'] = false;
			settings['description'] = settings['description'] || Locale.__e ("flash:1382952380241");
			sid = settings.target.sid;	
			mode = settings.mode || 1;
			
			if (mode == IslandChallengeWindow.CHALLENGE) {
				settings['height'] = 450;
			}
			
			super(settings);
		}
		override public function drawBackground():void {
			background =  backing(settings.width, settings.height, 50, "alertBacking");;
			layer.addChild(background);
		}
		
		
		private var selectedTeam:int = 0;
		public function selectTeam(teamID:int):void {
			selectedTeam = teamID;
			close();
		}
		
		override public function close(e:MouseEvent = null):void {
			if (selectedTeam > 0) {
				if(settings.onSelect != null) settings.onSelect(selectedTeam);
			}else {
				if(settings.onClose != null) settings.onClose();
			}
			super.close()
		}
		
		
		override public function drawBody ():void 
		{
			leftTeamContainer		= new Sprite();
			rightTeamContainer		= new Sprite();
			leftTeamContainer.x		= bodyContainer.x + 100;
			rightTeamContainer.x	= bodyContainer.x + settings.width / 2 + 48;
			
			descriptionLabel = drawText(settings.description, {
					fontSize:24,
					autoSize:"center",
					textAlign:"center",
					multiline:true,
					color:0xffffff,
					borderColor:0x7a4b1f
				});	
			descriptionLabel.wordWrap	 = true;
			descriptionLabel.width		 = settings.width - 60 + settings.descWidthMarging;
			descriptionLabel.x			 = (settings.width - descriptionLabel.width) / 2;
			descriptionLabel.y			 = 0;
			
			var leftTeam:TeamItem	 = new TeamItem(Thappy.LEFT, this);
			var rigthTeam:TeamItem	 = new TeamItem(Thappy.RIGHT, this);
			
			leftTeamContainer.addChild(leftTeam);
			rightTeamContainer.addChild(rigthTeam);
			
			helpBttn = new ImageButton(Window.textures.interHelpBttn);
			helpBttn.x =  exit.x - 15 - helpBttn.width;// exit.x - exit.width - 6;;
			helpBttn.y = -34;
			bodyContainer.addChild(helpBttn);
			helpBttn.addEventListener(MouseEvent.CLICK, onHelp);
				
			bodyContainer.addChild (leftTeamContainer);
			bodyContainer.addChild (rightTeamContainer);
		}		
		
		private function onHelp(e:MouseEvent):void {
			/*new SimpleWindow( {
				title:		settings.title,
				text:		App.data.storage[sid].text1,
				popup:		true,
				height:		420
			}).show();*/
			new InfoWindow( {
				popup:true,
				qID:'tophelp13'
			}).show();
		}

	}	
}

import buttons.Button;
import core.Load;
import core.Numbers;
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.text.TextField;
import units.Thappy;
import wins.BonusList;
import wins.IslandChallengeWindow;
import wins.Window;
import wins.TeamsRewardItems;
internal class TeamItem extends LayerX {
	public var bitmap:Bitmap;
	
	private var labelSettings:Object = { 
		fontSize		:26,
		autoSize		:"center",
		textAlign		:"center",
		color			:0xffffff,
		borderColor		:0x6e401e,
		borderSize		:4 
	};
	
	private var showBttn:Button;
	private var selectBttn:Button;
	private var teamNameLabel:TextField;
	private var teamID:int;
	private var window:*;
	private var bg:Bitmap;
	private var bonus:Object = { };
	private var treasures:Object = {
		"1":{0:2316,1:2318,2:2317},
		"2":{0:2312,1:2319,2:2320}
	};
	public function TeamItem(teamID:int, window:*) 
	{
		this.teamID = teamID;
		this.window = window;
		var bitmap:Bitmap = new Bitmap();
		
		var text:String = App.data.storage[window.settings.target.sid].teams[teamID].info.title;
		teamNameLabel	=  Window.drawText(text, labelSettings );
		
		selectBttn = new Button( {
			width:		140,
			height:		43,
			caption:	Locale.__e ('flash:1406302453974')
		});
		selectBttn.addEventListener(MouseEvent.CLICK, createButtonClick);
		
		
		selectBttn.y = 440;
		selectBttn.x = 60;
		
		teamNameLabel.x = selectBttn.x + selectBttn.width / 2 - teamNameLabel.width / 2
		teamNameLabel.y = 220;
		
		addChild(bitmap);
		Load.loading(Config.getImage("Thappy", window.settings.target.viewTeam[teamID]), function(data:Bitmap):void {
			bitmap.bitmapData = data.bitmapData;
			bitmap.x = selectBttn.x + selectBttn.width / 2 - bitmap.width / 2;
			bitmap.y = 10;
		});
		
		
		addChild(teamNameLabel);
		
		if (window.mode == IslandChallengeWindow.CHALLENGE) {
			labelSettings['fontSize'] = 60;
			
			var scores:int = window.settings.target.rate[teamID];			
			var teamPoints:TextField	=  Window.drawText(String(scores), labelSettings );
			teamPoints.width = 150;
			teamPoints.x = selectBttn.x + selectBttn.width / 2 - teamPoints.width / 2;
			teamPoints.y = selectBttn.y - 130;
			addChild(teamPoints);
			
			Load.loading(Config.getImage("Thappy", "scoreBacking"), function(data:Bitmap):void {
				var scoreBacking:Bitmap = new Bitmap
				scoreBacking.bitmapData = data.bitmapData;
				
				scoreBacking.x = teamPoints.x + teamPoints.width / 2 - scoreBacking.width / 2;
				scoreBacking.y = - 5 + teamPoints.y + teamPoints.height / 2 - scoreBacking.height / 2;
				addChildAt (scoreBacking, 0);
			});
			
			if (teamID == window.settings.target.team) {
				var myCommandText:TextField = Window.drawText(Locale.__e('flash:1467722331020'), {
					fontSize:		32,
					color:			0x6f3213,
					borderColor:	0xffffff
				});
				myCommandText.width = myCommandText.textWidth + 10;
				myCommandText.x = selectBttn.x + selectBttn.width / 2 - myCommandText.width / 2;
				myCommandText.y = 275;
				addChild(myCommandText);
			}
			return;
		}
		
		var giftTreasure:String = App.data.storage[window.settings.target.sid].teams[teamID].info.win;
		var giftItems:Object = treasures[teamID];// App.data.treasures[giftTreasure][giftTreasure].item;
		var giftCounts:Object = App.data.treasures[giftTreasure][giftTreasure].count;
		for (var s:* in giftItems) {
			bonus[giftItems[s]] = giftCounts[s];
		}
		
		addChild(selectBttn);
		
		var separator:Bitmap = Window.backingShort(270, 'dividerLine', false);
		separator.x = 5;
		separator.y = 290;
		separator.alpha = 0.5;
		addChild(separator);
		
		var separator2:Bitmap = Window.backingShort(270, 'dividerLine', false);
		separator2.x = 5;
		separator2.y = 415;
		separator2.alpha = 0.5;
		addChild(separator2);
		
		bg = Window.backing(270, 120, 50, 'fadeOutWhite');
		bg.alpha = 0.4;
		bg.y = 295;
		addChild(bg);
		
		var title:TextField = Window.drawText(Locale.__e('flash:1440499603885'), {
			color:0x7b3e07,
			fontSize:30,
			borderColor:0xffffff
		});
		title.width = title.textWidth + 10;
		title.x = bg.x + (bg.width - title.width)/2;
		title.y = 275;
		addChild(title);
		
		contentChange();
	}
	
	private var items:Array;
	public var itemsContainer:Sprite = new Sprite();
	private function contentChange():void {
		if (items) {
			for each(var _item:* in items) {
				itemsContainer.removeChild(_item);
				_item.dispose();
			}
		}
		items = [];
		
		addChild(itemsContainer);
		var X:int = 0;
		var Xs:int = X;
		var Ys:int = 310;
		itemsContainer.y = Ys;
		for (var i:* in bonus)
		{
			var item:PrizeItem = new PrizeItem(i, bonus[i], this);
			item.x = Xs;
			items.push(item);
			itemsContainer.addChild(item);
			
			Xs += item.background.width + 10;
		}
		
		itemsContainer.x = bg.x + (bg.width - itemsContainer.width) / 2;
	}
	
	private function showButtonClick(e:MouseEvent):void {
		new TeamsRewardItems( teamID, window.settings).show();
	}
	
	private function createButtonClick(e:MouseEvent):void {
		window.selectTeam(teamID);
	}
}

import core.Load;
import core.Size;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Shape;
import flash.text.TextField;
import wins.Window;
internal class PrizeItem extends LayerX {
	public var background:Bitmap = new Bitmap();
	private var shape:Shape;
	private var window:*;
	public function PrizeItem(sID:int, count:int, window:*, settings:Object = null) {
		this.window = window;	
		
		background = new Bitmap(new BitmapData(100, 100, true, 0xffffff));
		addChild(background);
		
		shape = new Shape();
		shape.graphics.beginFill(0xc6c7b9, 1);
		shape.graphics.drawCircle(50, 50, 50);
		shape.graphics.endFill();
		background.bitmapData.draw(shape);
		
		var prizeIcon:Bitmap = new Bitmap();
		addChild(prizeIcon);
		
		if (count != 0) {
			//drawCount(count);
		}
		
		drawTitle(sID);
		
		Load.loading(Config.getIcon(App.data.storage[sID].type, App.data.storage[sID].preview), function(data:*):void {
			prizeIcon.bitmapData = data.bitmapData;
			Size.size(prizeIcon, 80, 80);
			prizeIcon.x = (background.width - prizeIcon.width) / 2;
			prizeIcon.y = 10;
			prizeIcon.smoothing = true;			
		});
		
		tip = function():Object {
			return {
				title:App.data.storage[sID].title,
				text:App.data.storage[sID].description
			}
		}
	}
	
	private function drawCount(count:int):void {
		var textCount:TextField = Window.drawText('x' + String(count) , {
			color:0x7b3e07,
			fontSize:26,
			borderColor:0xffffff
		});
		textCount.width = textCount.textWidth + 10;
		textCount.x = background.x + background.width - textCount.width;
		textCount.y = background.y + background.height - 25;
		addChild(textCount);
	}
	
	private function drawTitle(sid:int):void {
		var textCount:TextField = Window.drawText(App.data.storage[sid].title, {
			color:0xffffff,
			fontSize:20,
			borderColor:0x7b3e07,
			multiline:true,
			textAlign:'center',
			width:shape.width
		});
		textCount.wordWrap = true;
		textCount.x = background.x + (background.width - textCount.width)/2;
		textCount.y = 0;
		addChild(textCount);
	}
}
