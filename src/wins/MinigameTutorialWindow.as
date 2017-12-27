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
	import units.Boss;

	public class MinigameTutorialWindow extends Window
	{
		public var missions:Array = [];
		
		public var okBttn:Button;
		
		public var quest:Object = { };
		private var titleQuest:TextField;
		private var titleShadow:TextField;
		private var descLabel:TextField;
		
		private var callback:Function = null;
		public var sprite:Sprite = new Sprite();
		public var character:Bitmap = new Bitmap();
		
		public function MinigameTutorialWindow(settings:Object = null) 
		{
			settings['width'] = 500;
			settings['height'] = settings.height || 244;
			
			settings['hasTitle'] = false;
			settings['hasButtons'] = false;
			settings['hasPaginator'] = false;
			settings['hasExit'] = false;
			settings['faderClickable'] = false;
			settings['faderAsClose'] = false;
			settings['title'] = Locale.__e('flash:1464618051785');
			settings['character'] = settings.character || 'CharPirate';
			
			settings['qID'] = settings.qID || 2;
			quest = App.data.quests[settings.qID];
			
			callback = settings['callback'];
			super(settings);
			
			settings.content = App.user.quests.opened;
		}
		
		override public function drawBackground():void {
			if (!background) {
				background = new Bitmap();
				layer.addChild(background);
			}
			background.bitmapData = backing(settings.width, settings.height, 50, 'alertBacking').bitmapData;
		}
		
		
		private var preloader:Preloader = new Preloader();				
		override public function drawBody():void {
			drawMessage();
			
			okBttn = new Button( {
				width:138,
				height:44,
				fontSize:26,
				caption:Locale.__e("flash:1382952380242")
			});
			bodyContainer.addChild(okBttn);
			
			okBttn.addEventListener(MouseEvent.CLICK, onReadEvent);
			
			bodyContainer.addChild(preloader);
			preloader.x = 38;
			preloader.y = 84;
			
			var preview:String = (App.data.personages.hasOwnProperty(quest.character)) ? App.data.personages[quest.character].preview : '';
			Load.loading(Config.getImage('content',settings.character), function(data:*):void { 
				bodyContainer.removeChild(preloader);
				
				character.bitmapData = data.bitmapData;
				character.x = -(character.width / 4) * 3 + 100;
				character.y = -170;
				bodyContainer.addChild(character);
				
				if (settings.character == 'Miner') {
					character.x = -(character.width / 4) * 3 + 50;
				character.y = -120;
				}
			});			
			
			okBttn.x = settings.width / 2 - okBttn.width / 2 + 15;
			okBttn.y = settings.height - 40;
		}
		
		private function onReadEvent(e:MouseEvent):void {
			okBttn.removeEventListener(MouseEvent.CLICK, onReadEvent);
			
			if(callback != null)
				callback();
			
			close();
			
			/*App.user.quests.readEvent(settings.qID, function():void {
				var list:Array;
				if (settings.qID == 2037) {
					list = Map.findUnits([4354]);
					if (list.length > 0) {
						App.map.focusedOn(list[0], true);
					}
				}
				
				if (settings.qID == 2050) {
					list = Map.findUnits([4414]);
					if (list.length > 0) {
						App.map.focusedOn(list[0], true);
					}
				}
				
				close();
			});*/
		}
		
		
		private function drawMessage():void {
			titleQuest = Window.drawText(settings.title, {
				color:0x604729,
				borderColor:0xf7f2de,
				borderSize:4,
				fontSize:32,
				multiline:true,
				textAlign:"center"
			});
			titleQuest.wordWrap = true;
			titleQuest.width = 254;
			titleQuest.height = titleQuest.textHeight + 10; 
			titleQuest.y = 5;
			titleQuest.x = (settings.width - titleQuest.width) / 2;
			bodyContainer.addChild(titleQuest);
			
			titleShadow = Window.drawText(settings.title, {
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
			
			descLabel = Window.drawText(settings.description, {
				color:0x604729,
				border:false,
				fontSize:22,
				multiline:true,
				textAlign:"center"
			});
			
			descLabel.wordWrap = true;
			descLabel.width = 280;
			descLabel.height = descLabel.textHeight + 10;
			descLabel.x = (settings.width - descLabel.width) / 2 + 30;
			descLabel.y = titleQuest.y + titleQuest.height + 6;
			bodyContainer.addChild(descLabel);
			
			/*var top:Bitmap = new Bitmap(Window.textures.progressBarAction);
			var bottom:Bitmap = new Bitmap(Window.textures.progressBarAction);
			
			var maxHeight:int = titleQuest.height + descLabel.height + 58 - top.height - bottom.height;
			
			if(maxHeight>0){
				var fill:BitmapData = new BitmapData(Window.textures.progressBarAction.width, 1, true, 0);
				fill.copyPixels(Window.textures.progressBarAction, new Rectangle(0, Window.textures.progressBarAction.height - 1, Window.textures.progressBarAction.width, Window.textures.progressBarAction.height), new Point());	
				
				var shp:Shape;
				shp = new Shape();
				shp.graphics.beginBitmapFill(fill);
				shp.graphics.drawRect(0, 0, Window.textures.progressBarAction.width, maxHeight);
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
			sprite.y = 86 - sprite.height;*/
			
		}
		
		override public function dispose():void {
			if(okBttn) {
				okBttn.removeEventListener(MouseEvent.CLICK, close);
			}
			super.dispose();
		}
		
	}

}