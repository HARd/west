package wins 
{
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

	public class QuestMsgWindow extends Window
	{
		public var missions:Array = [];
		
		public var okBttn:Button;
		
		public var quest:Object = { };
		private var titleQuest:TextField;
		private var titleShadow:TextField;
		private var descLabel:TextField;
		
		public var sprite:Sprite = new Sprite();
		public var character:Bitmap = new Bitmap();
		
		public function QuestMsgWindow(settings:Object = null) 
		{
			settings['width'] = 244;
			settings['height'] = 500;
			
			settings['hasTitle'] = false;
			settings['hasButtons'] = false;
			settings['hasPaginator'] = false;
			settings['hasExit'] = false;
			settings['faderClickable'] = false;
			settings['faderAsClose'] = false;
			settings['escExit'] = false;
			
			
			settings['qID'] = settings.qID || 2;
			quest = App.data.quests[settings.qID];
			super(settings);
			
			settings.content = App.user.quests.opened;
			
			if(App.user.quests.tutorial){
				App.user.quests.stopTrack();
			}
			
		}
		
		override public function drawBackground():void {
			
		}
		
		
		private var preloader:Preloader = new Preloader();
				
		override public function drawBody():void {
			
			drawMessage();
			
			okBttn = new Button( {
				width:138,
				height:38,
				fontSize:26,
				caption:Locale.__e("flash:1382952380242")
			});
			bodyContainer.addChild(okBttn);
			
			okBttn.addEventListener(MouseEvent.CLICK, onReadEvent);
			
			bodyContainer.addChild(preloader);
			preloader.x = 38;
			preloader.y = 84;
			
			Load.loading(Config.getQuestIcon('preview', App.data.personages[quest.character].preview), function(data:*):void { 
				bodyContainer.removeChild(preloader);
				
				character.bitmapData = data.bitmapData;
				character.x = -(character.width / 4) * 3;
				character.y = -70;
				if (App.data.personages[quest.character].preview == 'bunny') {
					character.x += 30;	
				}
				if (App.data.personages[quest.character].preview == 'bat') {
					character.x += 70;	
					character.y -= 40;	
				}
				bodyContainer.addChild(character);
			});
			
			
			okBttn.x = (settings.width - okBttn.width) / 2 + 100;
			okBttn.y = sprite.y+sprite.height - 10;
			
			settings.height = okBttn.y + okBttn.height + 16;
		}
		
		private function onReadEvent(e:MouseEvent):void {
			okBttn.removeEventListener(MouseEvent.CLICK, onReadEvent);
			
			App.user.quests.readEvent(settings.qID, function():void {
				close();
			});
		}
		
		
		private function drawMessage():void {
			
			titleQuest = Window.drawText(quest.title, {
				color:0x604729,
				borderColor:0xf7f2de,
				borderSize:4,
				fontSize:30,
				multiline:true,
				textAlign:"center"
			});
			titleQuest.wordWrap = true;
			titleQuest.width = 254;
			titleQuest.height = titleQuest.textHeight + 10; 
			
		
			titleShadow = Window.drawText(quest.title, {
				color:0xf7f2de,
				borderColor:0x604729,
				borderSize:4,
				fontSize:30,
				multiline:true,
				textAlign:"center"
			});
			
			titleShadow.wordWrap = true;
			titleShadow.width = 254;
			titleShadow.height = titleShadow.textHeight + 10; 
			titleShadow.x = titleQuest.x;
			titleShadow.y = titleQuest.y + 3;
			
			descLabel = Window.drawText(quest.description.replace(/\r/g,""), {
				color:0x604729,
				border:false,
				fontSize:22,
				multiline:true,
				textAlign:"center"
			});
			
			descLabel.wordWrap = true;
			descLabel.width = 280;
			descLabel.height = descLabel.textHeight + 10;
			
			var top:Bitmap = new Bitmap(Window.textures.questHeaderTop);
			var bottom:Bitmap = new Bitmap(Window.textures.questHeaderBottom);
			
			var maxHeight:int = titleQuest.height + descLabel.height + 58 - top.height - bottom.height;
			
			if(maxHeight>0){
				var fill:BitmapData = new BitmapData(Window.textures.questHeaderTop.width, 1, true, 0);
				fill.copyPixels(Window.textures.questHeaderTop, new Rectangle(0, Window.textures.questHeaderTop.height - 1, Window.textures.questHeaderTop.width, Window.textures.questHeaderTop.height), new Point());	
				
				var shp:Shape;
				shp = new Shape();
				shp.graphics.beginBitmapFill(fill);
				shp.graphics.drawRect(0, 0, Window.textures.questHeaderTop.width, maxHeight);
				shp.graphics.endFill();
				
				sprite.addChild(shp);
				shp.y = top.height;
			}
			
			
			sprite.addChild(top);
			sprite.addChild(bottom);
			
			if(maxHeight>0){
				bottom.y = shp.height + top.height - 1;
			}else {
				bottom.y = top.height - 1;
			}
			bottom.x = 6;
			
			sprite.addChild(titleShadow);
			titleShadow.y = 42;
			titleShadow.x = (top.width - titleQuest.width) / 2;
			
			sprite.addChild(titleQuest);
			titleQuest.y = 40;
			titleQuest.x = (top.width - titleQuest.width) / 2;
			
			sprite.addChild(descLabel);
			descLabel.x = (top.width - descLabel.width) / 2;
			descLabel.y = titleQuest.y + titleQuest.height + 6;
			
			bodyContainer.addChild(sprite);
			
			sprite.x = (settings.width - sprite.width) / 2 + 100;
			sprite.y = 86 - sprite.height;
			
		}
		
		override public function dispose():void {
			okBttn.removeEventListener(MouseEvent.CLICK, close);
			
			super.dispose();
		}
		
	}

}