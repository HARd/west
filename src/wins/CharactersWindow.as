package wins 
{
	import api.ExternalApi;
	import buttons.Button;
	import core.Load;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import units.Boss;
	/**
	 * ...
	 * @author ...
	 */
	public class CharactersWindow extends Window
	{
		private var titleQuest:TextField;
		private var titleShadow:TextField;
		private var descLabel:TextField;
		
		private var winContainer:Sprite;
		private var titleFilterContainer:Sprite;
		private var confirmBttn:Button;
		public var quest:Object = { };
		
		private var dontRead:Boolean = false;
		private var sub:uint;
		
		public function CharactersWindow(settings:Object = null) 
		{
			if (settings == null) {
				settings = new Object();
			}
			
			settings['width'] = 444;
			settings['height'] = 500;
			settings['hasPaginator'] = false;				//Окно с пагинацией
			settings['hasButtons'] = false;
			settings['hasExit']	= false;
			settings['hasPaginator'] = false;
			settings['hasTitle'] = false;
			
			settings['faderAsClose'] = false;
			settings['faderClickable'] = false;
			settings['escExit'] = settings.escExit || false;
			sub = settings['sub'];
			super(settings);
			
			if (settings.hasOwnProperty('quest')) {
				dontRead = true;
				quest = settings.quest;
			}else
				quest = App.data.quests[settings.qID];
		}
		
		
		private var preloader:Preloader = new Preloader();
		private var titleQuestContainer:Sprite;
		
		override public function drawBackground():void {
				
		}
		
		override public function drawBody():void 
		{
			
			var character:Bitmap = new Bitmap();
			
			bodyContainer.addChild(preloader);
			preloader.x = 38;
			preloader.y = 84;
			
			drawMessage();
			drawBttns((App.data.personages[quest.character].preview));
			
			bodyContainer.addChildAt(character,2);
			
			Load.loading(Config.getQuestIcon('preview', App.data.personages[quest.character].preview), function(data:*):void { //cat_teleport    aborigine   old_alien   old_techno
				bodyContainer.removeChild(preloader);
				
				character.bitmapData = data.bitmapData;
				
				switch(App.data.personages[quest.character].preview) {
					case 'dragon':
						character.x = -(character.width / 4) * 3 + 120;
						character.y = -90;
					break;
					case 'druid':
						character.x = -(character.width / 4) * 3 + 140;
						character.y = -80;
					break;
					case 'engineer':
						character.x = -(character.width / 4) * 3 + 100;
						character.y = -40;
					break;
					case 'evil':
						character.x = -(character.width / 4) * 3 + 250;
						character.y = -70;
					break;
					case 'minion':
						character.x = -(character.width / 4) * 3 + 90;
						character.y = -36;
					break;
					case 'ranger':
						character.x = -(character.width / 4) * 3 + 90;
						character.y = -36;
					break;
					case 'AI':
						character.x = -character.width + 400;
						character.y = -70;
					break;
				}
				
				//bodyContainer.addChildAt(character, 0);
				//bodyContainer.addChildAt(character,1);
			});
		}
		
		private function drawBttns(type:String = null):void 
		{
			var bttnSettings:Object;
			if (type != 'evil') 
			{
			bttnSettings = {
				caption:Locale.__e("flash:1394546313785"),
				fontSize:30,
				width:170,
				height:46,
				hasDotes:false
			};	
			}
			else 
			{
			bttnSettings = {
				caption:Locale.__e("flash:1413820223844"),
				fontSize:30,
				width:170,
				height:46,
				hasDotes:false
			};		
			}
			
			
			confirmBttn = new Button(bttnSettings);
			/*confirmBttn.tip = function():Object { 
				return {
					title:"",
					text:Locale.__e("flash:1382952380242")
				};
			};*/
		
			confirmBttn.x = (winContainer.width - confirmBttn.width)/2 - 5;
			confirmBttn.y = winContainer.height - confirmBttn.height - 20;
			
			winContainer.addChild(confirmBttn);
			
			confirmBttn.addEventListener(MouseEvent.CLICK, closeThis);
		}
		
		private function closeThis(e:MouseEvent):void 
		{
			if (e.currentTarget.mode == Button.DISABLED)
				return;
				
			if (dontRead)
				close();
				
			if (settings.hasOwnProperty('callback')) {
				settings.callback();
			}
				
			e.currentTarget.state = Button.DISABLED;
			var bs:Boss = Map.findUnits([sub])[0];
			Map.focused = true ;
			if (Boss.bosses && Boss.bosses.length) {			
				var focusFunc:Function = function():void
					{
						App.map.focusedOn(Boss.bosses[0]);
						if (!Map.focused)
						{
							App.self.setOffEnterFrame(focusFunc)
						};

					};
				App.self.setOnEnterFrame(focusFunc);
			}
			confirmBttn.removeEventListener(MouseEvent.CLICK, closeThis);
			
			if (settings.qID == 144) {
				if(App.user.friends.keys.length > 0){
					new GiftWindow({
						sID:		293,
						iconMode:	GiftWindow.FREE_GIFTS,
						itemsMode:	GiftWindow.FRIENDS,
						tutorial:   true
					}).show();
				}else if (App.social != 'OK'){
					if (['ML','FB','NK'].indexOf(App.social) != -1)
						ExternalApi.apiInviteEvent();
					//else
						//new InviteLostFriendsWindow( {desc:Locale.__e('flash:1407752973464'), tutorial:true } ).show();
				}
				App.user.storageStore('tutViral', 'finish');
				App.user.quests.readEvent(settings.qID, function():void {});
				close();
			}else{
				App.user.quests.readEvent(settings.qID, function():void {
					close();
				});
			}
		}
		
		private function drawMessage():void 
		{
			var titlePadding:int = 20;
			var descPadding:int = 30;
			
			var descMarginX:int = 10;
			
			winContainer = new Sprite();
			titleFilterContainer = new Sprite();
			
			var fontSize:int = 50;
			do{
				titleQuest = Window.drawText(quest.title, {
					color:0xffffff,
					borderColor:0xb98659,
					borderSize:4,
					fontSize:fontSize,
					multiline:true,
					textAlign:"center"
				});
				titleQuest.autoSize = TextFieldAutoSize.CENTER;
				titleQuest.y = -15;
				fontSize -= 1;
			}
			while (titleQuest.width >= 380);
			
			descLabel = Window.drawText(quest.description, {
				color:0x65371b, 
				borderColor:0xffe8ba,
				fontSize:26,
				multiline:true,
				textAlign:"center"
			});
			descLabel.wordWrap = true;
			descLabel.width = 360;
			descLabel.height = descLabel.textHeight + 10;
			
			var curHeight:int = titleQuest.height + descLabel.height + titlePadding*2 + 50;
			
			if (curHeight < 200) curHeight = 200;
			
			var bg:Bitmap = Window.backing(settings.width, curHeight, 50, 'alertBacking');
			
			titleQuest.x = (bg.width - titleQuest.width) / 2;

			descLabel.y = titleQuest.y + titleQuest.height - 15;
			descLabel.x = (bg.width - descLabel.width)/2 + 180;
			winContainer.addChild(bg);
			
			titleFilterContainer.addChild(titleQuest);
			
			var myGlow:GlowFilter = new GlowFilter();
			myGlow.inner = false;
			myGlow.color = 0x855729;
			myGlow.blurX = 5;
			myGlow.blurY = 5;
			myGlow.strength = 20;
			myGlow.alpha = 0.8;
			titleFilterContainer.filters = [myGlow];
			
			
			winContainer.addChild(titleFilterContainer);			
			
			bodyContainer.addChild(winContainer);
			bodyContainer.addChild(descLabel);
			winContainer.x = (settings.width - winContainer.width) / 2 + 180;
			winContainer.y = -25;
			drawMirrowObjs('diamondsTop', bg.width / 2 - titleQuest.width / 2 + 175, bg.width / 2 + titleQuest.width / 2 + 185, -30, true, true);

		}
		
		
	}

}