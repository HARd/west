package wins 
{
	import api.ExternalApi;
	import buttons.Button;
	import buttons.EnergyButton;
	import buttons.ImageButton;
	import com.greensock.TweenLite;
	import core.Load;
	import core.Size;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import ui.UserInterface;
	import units.Animal;
	import units.Unit;
	import wins.elements.Bar;

	public class CreateAnimalWindow extends Window
	{
		private var leftPanel:Bitmap;
		private var rightPanel:Bitmap
		private var animal:Object;
		
		public var items:Array = new Array();
		public var friends:Object = { };
		public var handler:Function;		
		public var energyBttn:EnergyButton;
		public var createBttn:Button;
		public var animalEnergy:Bar;
		public var userEnergy:Bar;
		public var energyBefore:int;
		public var textLabel:TextField;
		public var fillBttn:EnergyButton;
		public var plusBttn:EnergyButton;
		public var minusBttn:Button;
		public var minusBttn10:Button;
		public var plusBttn10:Button;
		
		private var progUserEnergyBar:ProgressBar;
		public var progUserEnergyBacking:Bitmap;
		public var progUserEnergyTitle:TextField;
		
		public function CreateAnimalWindow(settings:Object = null) 
		{
			if (settings == null) {
				settings = new Object();
			}
			
			settings['width'] 			= 660;
			settings['height'] 			= 650;
			settings['sID'] 			= settings.sID || 0;
			settings['sphere'] 			= settings.sphere || null;
			settings['background'] 		= 'goldBacking';
			settings['title'] 			= App.data.storage[settings.sphere.sid].title;
			settings['hasPaginator'] 	= true;
			settings['hasButtons']		= false;
			settings['itemsOnPage'] 	= 9;
			settings['content'] 		= createContent(App.user.friends.keys);
			
			super(settings);
			
			App.self.addEventListener(AppEvent.ON_AFTER_PACK, updateEvent);
		}
		
		private function createContent(_keys:Array):Array 
		{
			var result:Array = [];
			var Length:int = App.user.friends.keys.length;
			var slave:Object;
			for (var i:int = 0; i < Length; i++) {
				var friend:Object = App.user.friends.keys[i];
				var obj:Object = { uid:friend.uid, level:friend.level};
				
				
				result.push(obj);
			}
			
			result.unshift({ uid:1, level:50 });
			return result;
		}
		
		override public function drawExit():void 
		{
			exit = new ImageButton(textures.closeBttn);
			headerContainer.addChild(exit);
			exit.x = settings.width - 47;
			exit.y = -8;
			exit.addEventListener(MouseEvent.CLICK, close);
		}
		
		override public function dispose():void 
		{
			App.self.removeEventListener(AppEvent.ON_AFTER_PACK, updateEvent);
			
			for (var i:int = 0; i < items.length; i++)
			{
				if (items[i] != null)
				{
				items[i].dispose();
				items[i] = null;
				}
			}
			super.dispose();
		}
		
		public function drawDescription():void 
		{			
			var separator:Bitmap = Window.backingShort(310, 'dividerLine', false);
			separator.x = 310;
			separator.y = 8;
			separator.alpha = 0.5;
			bodyContainer.addChild(separator);
			
			var separator2:Bitmap = Window.backingShort(310, 'dividerLine', false);
			separator2.scaleY = -1;
			separator2.x = separator.x;
			separator2.y = 41;
			separator2.alpha = 0.5;
			bodyContainer.addChild(separator2);
			
			var selfLabel:TextField = drawText(Locale.__e("flash:1382952380030"), {
				fontSize:22,
				autoSize:"left",
				textAlign:"center",
				multiline:true,
				color:0x643916,
				borderColor:0xfffff3
			});
			selfLabel.x = rightPanel.x + (rightPanel.width - selfLabel.width) / 2;
			selfLabel.y = 11;						
			selfLabel.width = settings.width - 80;
			
			bodyContainer.addChild(selfLabel);			
			
			var separator3:Bitmap = Window.backingShort(310, 'dividerLine', false);
			separator3.x = separator.x;
			separator3.y = 158;
			separator3.alpha = 0.5;
			bodyContainer.addChild(separator3);
			
			var separator4:Bitmap = Window.backingShort(310, 'dividerLine', false);
			separator4.scaleY = -1;
			separator4.x = separator.x;
			separator4.y = 191;
			separator4.alpha = 0.5;
			bodyContainer.addChild(separator4);
			
			var friendsLabel:TextField = drawText(Locale.__e("flash:1382952380031"), {
				fontSize:22,
				autoSize:"left",
				textAlign:"center",
				multiline:true,
				color:0x643916,
				borderColor:0xfffff3
			});
			friendsLabel.x = rightPanel.x + (rightPanel.width - friendsLabel.width) / 2;
			friendsLabel.y = 161;						
			friendsLabel.width = settings.width - 80;
			
			bodyContainer.addChild(friendsLabel);
			
			drawAnimalDescription();
		}
		
		private function drawAnimalDescription():void
		{
			var descZone:LayerX = new LayerX();
			var deltaY:int = 254;
			
			var leftFormat:Object = new Object();
				leftFormat.fontSize = 36;
				leftFormat.color = 0xfffff3;
				leftFormat.borderColor = 0x62370d;
				leftFormat.textAlign = 'left';
				
			var Format:Object = new Object();
				Format.fontSize = 48;
				Format.color = 0xf1eec5;
				Format.borderColor = 0x202020;
				Format.textAlign = 'left';
			
			var rightFormat:Object = new Object()
				rightFormat.fontSize = 21;
				rightFormat.color = 0x502f06;
				rightFormat.borderColor = 0xf8f2e0;
				rightFormat.textAlign = 'left';
			
			var text:String = TimeConverter.timeToCuts(App.data.storage[settings.sID].jobtime);			
			text = TimeConverter.timeToCuts(App.data.storage[settings.sID].time);
			
			var out:Object;
			var materialLabel_L:TextField = drawText(Locale.__e("flash:1382952380034"), leftFormat);			
			var materialLabel_R:TextField = drawText(text, rightFormat);			
			materialLabel_R.wordWrap = true;
			
			materialLabel_L.width = materialLabel_L.textWidth + 5;
			materialLabel_L.height = materialLabel_L.textHeight;
			materialLabel_R.height = materialLabel_R.textHeight + 20;
			
			materialLabel_L.x = 150 - materialLabel_L.width / 2;
			materialLabel_R.x = materialLabel_L.x + materialLabel_L.width + 5;
			materialLabel_L.y = materialLabel_R.y = deltaY +30;
			
			var icon:Bitmap = new Bitmap();
			descZone.addChild(icon);
			
			var materialCount:TextField = drawText(("+ "+settings.sphere.slaveCount), Format);			
			materialCount.x = materialLabel_L.x -40;
			materialCount.y = materialLabel_L.y + 85;
			descZone.addChild(materialCount);
			descZone.addChild(materialLabel_L);
			descZone.addChild(materialLabel_R);
			bodyContainer.addChild(descZone);
		
			Load.loading(Config.getIcon('Ttechno', App.data.storage[settings.sID].preview), function(data:Bitmap):void
			{
				icon.bitmapData = data.bitmapData;
				icon.scaleX = icon.scaleY = 1;
				icon.smoothing = true;
				icon.x = 170 - icon.width / 2;
				icon.y = deltaY + 140 - icon.height / 2;
			});
			
		}
		
		override public function drawBody():void {
			drawPanels();
			drawButtons();
			drawDescription();
			contentChange();		
		}
		
		public function updateEvent(e:AppEvent):void {
			
			userEnergy.have += App.user.stock.count(Stock.FANTASY) - energyBefore;
			userEnergy.counter = String(userEnergy.have);
			energyBefore = App.user.stock.count(Stock.FANTASY);
		}
		
		private var ava:FriendItem;
		private var wigwam:Object;
		public function drawPanels():void {
			
			var descZoneUp:LayerX = new LayerX();
			animal = App.data.storage[settings.sID];
			
			wigwam = App.data.storage[settings.sphere.sid];
			animal['energy'] = 0;
			leftPanel = Window.backing(250, settings.height - 100,10,"buildingDarkBacking");
			leftPanel.x = 20;
			leftPanel.y = 0;
			//bodyContainer.addChild(leftPanel);
			
			rightPanel = Window.backing(settings.width - leftPanel.width - 40, 374,10,'buildingDarkBacking');
			rightPanel.x = leftPanel.x + leftPanel.width + 5;
			rightPanel.y = 150;
			//bodyContainer.addChild(rightPanel);			
			
			var iconBg:Bitmap = Window.backing(180, 180, 10, "itemBacking");
			iconBg.x = 60;
			iconBg.y = 20;
			
			var icon:Bitmap = new Bitmap(null, "auto", true);
			bodyContainer.addChild(descZoneUp);
			descZoneUp.addChild(icon);
			Load.loading(Config.getIcon(settings.sphere.type, wigwam.view), function(data:*):void {
				icon.bitmapData = data.bitmapData;
				Size.size(icon, 200, 200);
				icon.x = iconBg.x + (iconBg.width - icon.width) / 2;
				icon.y = iconBg.y + (iconBg.height - icon.height) / 2;
			});
			descZoneUp.tip = function():Object {
				return {
					title:wigwam.title,
					text:wigwam.description
				}
			}
			
			ava = new FriendItem(this, App.user.id, true);
			ava.x = 315;
			ava.y = 50;
			bodyContainer.addChild(ava);
			
			energyBttn = new EnergyButton({ caption:Locale.__e("flash:1382952380035") } );
			energyBttn.name = "UserEnergyBttn";
			energyBttn.x = ava.x + 125;
			energyBttn.y = ava.y + (100 - energyBttn.height) / 2 + 20 -100;
			//bodyContainer.addChild(energyBttn);
			
			energyBttn.addEventListener(MouseEvent.CLICK, onTakeEnergy);
			
			animalEnergy = new Bar( animal.energy + ' / ' + settings.sphere.energy, animal.energy, settings.sphere.energy,'energyIcon','progressBarAction','progressBarActionLine');	
			animalEnergy.x = iconBg.x + (iconBg.width - animalEnergy.width) / 2 + 82; 
			animalEnergy.y = iconBg.y + iconBg.height + 40;
			
			bodyContainer.addChild(animalEnergy);
			
			var maxEnergy:int = App.data.levels[App.user.level].energy;
			var energy:int = App.user.stock.count(Stock.FANTASY);
			
			//Запоминаем начальное значение энергии
			energyBefore = energy;
			
			userEnergy = new Bar(String(energy), energy, energy,'energyIcon','progressBarAction','progressBarActionLine');	
			userEnergy.x = ava.x + 145;
			userEnergy.y = ava.y + (100 - energyBttn.height) / 2 - 25;
			
			bodyContainer.addChild(userEnergy);
		}
		
		
		private function drawButtons():void {
			createBttn = new Button( {
				caption:Locale.__e("flash:1382952380036"),
				fontSize:34,
				width:215,
				height:75
			});
			
			bodyContainer.addChild(createBttn);
			createBttn.x = 55;
			createBttn.y = 495;			
			
			if (animalEnergy.have < animalEnergy.all) {
				//createBttn.visible = false;
				//createBttnBuy.visible = true;
			}
			
			createBttn.addEventListener(MouseEvent.CLICK, onCreateEvent);
			
			var PosX:int = 330;
			var PosY:int = 95;
			
			minusBttn10 = new Button({
				caption		:"- 10",
				radius: 15,
				width: 40,
				height: 25,
				fontSize:16,
				fontColor:0xffffff,
				fontBorderColor:0x7e5038,
				fontBorderSize:2,
				bgColor:[0xf9f071,0xc27d18],
				borderColor:[0xf9f071, 0xc27d18],
				bevelColor:	[0xf9f071, 0xc27d18]
			});
		
			minusBttn10.x = PosX;
			minusBttn10.y = PosY;
			
			minusBttn = new Button({
				caption		:" -",
				radius: 15,
				width: 40,
				height: 25,
				fontSize:16,
				fontColor:0xffffff,
				fontBorderColor:0x7e5038,
				fontBorderSize:2,
				bgColor:[0xf9f071,0xc27d18],
				borderColor:[0xf9f071, 0xc27d18],
				bevelColor:	[0xf9f071, 0xc27d18]
			});
				minusBttn.x = minusBttn10.x + minusBttn10.width +5;
				minusBttn.y = PosY;
				
				fillBttn = new EnergyButton({
				caption		:"",//Locale.__e("+ "+friendEnergy),
				width: 88,
				height: 38,
				fontSize:22,
				fontColor:0xf4fbff,
				fontBorderColor:0x093b52,
				fontBorderSize:2,
				bgColor:[0xb5d8f6, 0x396bde],
				borderColor:[0xb9d5ea, 0x416ad3],
				bevelColor:	[0xb9d5ea,0x416ad3]
				//onClick:onSelectClick
			});
		
			//	fillBttn = new ImageButton(UserInterface.textures.vigCounterBacking);
				//App.ui.staticGlow(fillBttn,{color:0xf6e4ca,size:4});
				fillBttn.x = minusBttn.x + minusBttn.width +5;
				fillBttn.y = PosY;
			
				var energy:Bitmap = new Bitmap(UserInterface.textures.energyIcon, "auto", true);
				energy.scaleX = 0.7;
				energy.scaleY = 0.7;
				energy.x = /*fillBttn.x +*/ fillBttn.width  - energy.width + 3;
				energy.y = /*fillBttn.y +*/ (fillBttn.height - energy.height) / 2 ;
				textLabel = Window.drawText(Locale.__e("flash:1382952380035"), {
				color:settings.fontColor,
				borderColor:'0x013d59',
				fontSize:28,
				textAlign:settings.textAlign,
				width:70});
				textLabel.mouseEnabled = false;
				textLabel.mouseWheelEnabled = false;
				textLabel.x = 10;
				textLabel.width = fillBttn.width - energy.width;
				textLabel.height = textLabel.textHeight+6;;
				textLabel.y = 6;// (settings.height - textLabel.textHeight) / 2 + 2;
				textLabel.text ="+ "+String(animalEnergy.all - animalEnergy.have);
				//textLabel.border = true;
				
				
				plusBttn = new EnergyButton({
				caption		:"+ 1",//Locale.__e("+ "+friendEnergy),
				width: 88,
				height: 38,
				fontSize:22,
				fontColor:settings.fontColor,
				fontBorderColor:0x013d59,
				fontBorderSize:4,
				bgColor:[0xb5d8f6, 0x396bde],
				borderColor:[0xb9d5ea, 0x416ad3],
				bevelColor:	[0xb9d5ea,0x416ad3]
				//onClick:onSelectClick
			});

			plusBttn.x = fillBttn.x + fillBttn.width + 5;;
			plusBttn.y = PosY;
			
			plusBttn10 = new Button({
				caption		:"+ 10",
				radius: 15,
				width: 40,
				height: 25,
				fontSize:16,
				fontColor:0xffffff,
				fontBorderColor:0x7e5038,
				fontBorderSize:2,
				bgColor:[0xf9f071,0xc27d18],
				borderColor:[0xf9f071, 0xc27d18],
				bevelColor:	[0xf9f071, 0xc27d18]
				//onClick:onSelectClick
			});
			plusBttn10.scaleX = 1; 
			plusBttn10.x = plusBttn.x + plusBttn.width + 5;
			plusBttn10.y = PosY;
			//plusBttn10.y = 194;	
			
			minusBttn.state = Button.DISABLED;
			minusBttn10.state = Button.DISABLED;
			plusBttn.addEventListener(MouseEvent.CLICK, onPlusEvent);
			plusBttn10.addEventListener(MouseEvent.CLICK, onPlus10Event);
			minusBttn.addEventListener(MouseEvent.CLICK, onMinusEvent);
			minusBttn10.addEventListener(MouseEvent.CLICK, onMinus10Event);
			fillBttn.addEventListener(MouseEvent.CLICK, onTakeEnergy);
			
			bodyContainer.addChild(plusBttn);
			bodyContainer.addChild(fillBttn);
			fillBttn.addChild(textLabel);
			
		}
		
		private function onCreateBuyEvent(e:MouseEvent):void 
		{
			var canTakeEnergy:int = energyBefore - userEnergy.have;			
			var needToBuy:int = Math.ceil((animalEnergy.all - animalEnergy.have) / App.data.options['SpeedUpEnergy'])
			
			if (needToBuy > 0) {
					new PurchaseWindow( {
					content:PurchaseWindow.createContent("Energy", {view:'Energy'}),
					title:Locale.__e("flash:1382952379756"),
					popup:true,
					description:Locale.__e("flash:1382952379757"),
					width:558,
					closeAfterBuy:false,
					autoClose:false,
					itemsOnPage:3
				}).show();	
			}
		}
		
		private function onFillEvent(e:MouseEvent):void 
		{
			
		}
		
		private function onMinus10Event(e:MouseEvent):void 
		{
				if (animalEnergy.have >= 10) {
				
				var energyIcon:Bitmap	= new Bitmap(UserInterface.textures.energyIcon);
				energyIcon.scaleX = energyIcon.scaleY = 0.7;
				energyIcon.x = animalEnergy.point.x;
				energyIcon.y = animalEnergy.point.y;
				bodyContainer.addChild(energyIcon);
				
				userEnergy.have+= 10;
				userEnergy.counter = String(userEnergy.have);
				
				animalEnergy.have-=10;
				animalEnergy.counter = (animalEnergy.have) + ' / ' + animalEnergy.all;
				textLabel.text ="+ "+String(animalEnergy.all - animalEnergy.have);
				
				//createBttn.visible = false;
				//createBttnBuy.visible = true;
				
			//	textCount.text = String(Math.ceil(animalEnergy.all - animalEnergy.have) / App.data.options['SpeedUpEnergy']);
				
				if (animalEnergy.have < 1) {
					minusBttn.state = Button.DISABLED;
					
				}
			
				if (animalEnergy.have < 10) {
					minusBttn10.state = Button.DISABLED;
					
				}
			
				TweenLite.to(energyIcon, 0.8, { x:userEnergy.x-2, y:userEnergy.y-5, onComplete:function():void {
					bodyContainer.removeChild(energyIcon);
					energyIcon = null;
					animalEnergy.glowing();
					
				}});
			}
		}
		
		private function onMinusEvent(e:MouseEvent):void 
		{
			if (animalEnergy.have > 0) {
				
				var energyIcon:Bitmap	= new Bitmap(UserInterface.textures.energyIcon);
				energyIcon.scaleX = energyIcon.scaleY = 0.7;
				energyIcon.x = animalEnergy.point.x;
				energyIcon.y = animalEnergy.point.y;
				bodyContainer.addChild(energyIcon);
				
				userEnergy.have+= 1;
				userEnergy.counter = String(userEnergy.have);
				
				animalEnergy.have-=1;
				animalEnergy.counter = (animalEnergy.have) + ' / ' + animalEnergy.all;
				textLabel.text ="+ "+ String(animalEnergy.all - animalEnergy.have);
			//	createBttn.visible = false;
			//	createBttnBuy.visible = true;
				//	textCount.text = String(Math.ceil(animalEnergy.all - animalEnergy.have) / App.data.options['SpeedUpEnergy']);
				
				if (animalEnergy.have < 1) {
					minusBttn.state = Button.DISABLED;
					
				}
				
				if (animalEnergy.have < 10)
				{
					minusBttn10.state = Button.DISABLED;
				}
			
				TweenLite.to(energyIcon, 0.8, { x:userEnergy.x-2, y:userEnergy.y-5, onComplete:function():void {
					bodyContainer.removeChild(energyIcon);
					energyIcon = null;
					animalEnergy.glowing();
					
				}});
			}
			
		
		}
		
		private function onPlus10Event(e:MouseEvent):void 
		{
			if (animalEnergy.have >= animalEnergy.all) {
				return;
			}
			
			if (userEnergy.have >= 10) {
				
				var energyIcon:Bitmap	= new Bitmap(UserInterface.textures.energyIcon);
				energyIcon.scaleX = energyIcon.scaleY = 0.7;
				energyIcon.x = userEnergy.point.x;
				energyIcon.y = userEnergy.point.y;
				bodyContainer.addChild(energyIcon);
				
				userEnergy.have-=10;
				userEnergy.counter = String(userEnergy.have);
				
				animalEnergy.have+=10;
				animalEnergy.counter = (animalEnergy.have) + ' / ' + animalEnergy.all;
				textLabel.text ="+ "+ String(animalEnergy.all - animalEnergy.have);
				//	textCount.text = String(Math.ceil(animalEnergy.all - animalEnergy.have) / App.data.options['SpeedUpEnergy']);
				
				if (animalEnergy.have >= animalEnergy.all) {
					userEnergy.have+=animalEnergy.have - animalEnergy.all;
					userEnergy.counter = String(userEnergy.have);
					animalEnergy.have = animalEnergy.all;
					animalEnergy.counter = String(animalEnergy.have);
				//	createBttnBuy.visible = false;
				//	createBttn.visible = true;
					App.ui.flashGlowing(createBttn);
					textLabel.text ="+ "+String(animalEnergy.all - animalEnergy.have);
				}
				if (animalEnergy.have>0) 
				{
				minusBttn.state = Button.NORMAL;
				
				if (animalEnergy.have>=10) 
				{
					minusBttn10.state = Button.NORMAL;
				}
				
				}
				TweenLite.to(energyIcon, 0.8, { x:animalEnergy.x-2, y:animalEnergy.y-5, onComplete:function():void {
					bodyContainer.removeChild(energyIcon);
					energyIcon = null;
					animalEnergy.glowing();
					
				}});
			}else {
				new PurchaseWindow( {
					content:PurchaseWindow.createContent("Energy", {view:'Energy'}),
					title:Locale.__e("flash:1382952379756"),
					popup:true,
					description:Locale.__e("flash:1382952379757"),
					width:558,
					closeAfterBuy:false,
					autoClose:false,
					itemsOnPage:3
				}).show();
			}
			
		}	
		
		
		private function onPlusEvent(e:MouseEvent):void 
		{
		{
						
			if (animalEnergy.have >= animalEnergy.all) {
				return;
			}
			
			if (userEnergy.have > 0) {
				
				var energyIcon:Bitmap	= new Bitmap(UserInterface.textures.energyIcon);
				energyIcon.scaleX = energyIcon.scaleY = 0.7;
				energyIcon.x = userEnergy.point.x;
				energyIcon.y = userEnergy.point.y;
				bodyContainer.addChild(energyIcon);
				
				userEnergy.have-=1;
				userEnergy.counter = String(userEnergy.have);
				
				animalEnergy.have+=1;
				animalEnergy.counter = (animalEnergy.have) + ' / ' + animalEnergy.all;
				textLabel.text ="+ "+ String(animalEnergy.all - animalEnergy.have);
				//	textCount.text = String(Math.ceil(animalEnergy.all - animalEnergy.have) / App.data.options['SpeedUpEnergy']);
				
				if (animalEnergy.have >= animalEnergy.all) {
					animalEnergy.have = animalEnergy.all;
				//	createBttnBuy.visible = false;
				//	createBttn.visible = true;
					App.ui.flashGlowing(createBttn);
					textLabel.text ="+ "+String(animalEnergy.all - animalEnergy.have);
				}
				if (animalEnergy.have>0) 
				{
				minusBttn.state = Button.NORMAL;
				
				if (animalEnergy.have>=10) 
				{
					minusBttn10.state = Button.NORMAL;
				}
				
				}
				TweenLite.to(energyIcon, 0.8, { x:animalEnergy.x-2, y:animalEnergy.y-5, onComplete:function():void {
					bodyContainer.removeChild(energyIcon);
					energyIcon = null;
					animalEnergy.glowing();
					
				}});
			}else {
				new PurchaseWindow( {
					content:PurchaseWindow.createContent("Energy", {view:'energy'}),
					title:Locale.__e("flash:1382952379756"),
					popup:true,
					description:Locale.__e("flash:1382952379757"),
					width:558,
					closeAfterBuy:false,
					autoClose:false,
					itemsOnPage:3
				}).show();
			}
			
		}	
		}
		
		
		private function onCreateEvent(e:MouseEvent):void {
			/*if (createBttn.mode == Button.DISABLED) {
				App.ui.flashGlowing(animalEnergy, 0xd20707);
				return;
			}*/
			if (animalEnergy.have < animalEnergy.all) {
				App.ui.flashGlowing(fillBttn)
				for (var i:int = 0; i < items.length; i++) {
					App.ui.flashGlowing(items[i].selectBttn);	
				}				
				return;
			}
			//Пытаемся отнять у пользователя энергию
			var canTakeEnergy:int = energyBefore - userEnergy.have;
				
			var ids:Array = [];
			for (var ID:* in friends) {
				if(friends[ID].used){
					ids.push(ID);
				}
			}
			
			if (App.user.stock.check(Stock.FANTASY, canTakeEnergy)) {
				for each(ID in ids) {
					canTakeEnergy += App.data.options['FriendEnergy'];
				}
				var needEnergy:int = App.data.storage[settings.sID].energy;
				if (canTakeEnergy >= needEnergy) {
					App.user.stock.take(Stock.FANTASY, energyBefore - userEnergy.have);
					for each(ID in ids) {
						App.user.friends.updateOne(ID, 'wigwam', friends[ID].time);
					}
				}else {
					//TODO показываем окно об ошибке
					close();
				}

			}
			//settings.sphere.addLevel()
			//settings.sphere.addSlaves()
		//	createBttn.visible = false;
		//	createBttnBuy.visible = true;
			close();
			//settings.sphere.remove(function():void {

				//Делаем push в _6e
				if (App.social == 'FB') {
					var animalView:String = App.data.storage[settings.sID].view;
					ExternalApi._6epush([ "_event", { "event": "gain", "item": animalView } ]);
				}
			
			//	var unit:* = Unit.add( { sid:settings.sphere.sid, x:settings.sphere.coords.x, z:settings.sphere.coords.z } );				

				settings.sphere.create( {
					energy:energyBefore - userEnergy.have,
					friends:ids,
					sphere:settings.sphere
				});
			
			//	settings.sphere.uninstall();
			//});
		}
		
		private function onAnotherEvent(e:MouseEvent):void {
			close();
			settings.sphere.animal = 0;
			settings.sphere.click();
		}		
		
		private function onTakeEnergy(e:MouseEvent):void {
			if (animalEnergy.have >= animalEnergy.all) {
				return;
			}
			
			if (userEnergy.have > 0) {				
				var energyIcon:Bitmap	= new Bitmap(UserInterface.textures.energyIcon);
				energyIcon.scaleX = energyIcon.scaleY = 0.7;
				energyIcon.x = userEnergy.point.x;
				energyIcon.y = userEnergy.point.y;
				bodyContainer.addChild(energyIcon);				
				
				animalEnergy.have+=userEnergy.have;
				animalEnergy.counter = (animalEnergy.have) + ' / ' + animalEnergy.all;
				
				userEnergy.have = 0;
				userEnergy.counter = String(userEnergy.have);
				textLabel.text = "+ " + String(animalEnergy.all - animalEnergy.have);
				
				if (animalEnergy.have >= animalEnergy.all) {
					userEnergy.have+=animalEnergy.have - animalEnergy.all;
					userEnergy.counter = String(userEnergy.have);
					animalEnergy.have = animalEnergy.all;
					animalEnergy.counter = String(animalEnergy.have);
				//	createBttnBuy.visible = false;
				//	createBttn.visible = true;
					App.ui.flashGlowing(createBttn);
					textLabel.text ="+ "+String(animalEnergy.all - animalEnergy.have);
				}
				
				if (animalEnergy.have > 0) {
					minusBttn.state = Button.NORMAL;
					
					if (animalEnergy.have >= 10) {
						minusBttn10.state = Button.NORMAL;
					}
				}
				
				TweenLite.to(energyIcon, 0.8, { x:animalEnergy.x-2, y:animalEnergy.y-5, onComplete:function():void {
					bodyContainer.removeChild(energyIcon);
					energyIcon = null;
					animalEnergy.glowing();
					
				}});
			}else {
				new PurchaseWindow( {
					content:PurchaseWindow.createContent("Energy", {view:'energy'}),
					title:Locale.__e("flash:1382952379756"),
					popup:true,
					description:Locale.__e("flash:1382952379757"),
					width:558,
					closeAfterBuy:false,
					autoClose:false,
					itemsOnPage:3
				}).show();
			}
			
		}
		
		override public function drawArrows():void {
			super.drawArrows();
			paginator.arrowLeft.scaleX = paginator.arrowRight.scaleX = paginator.arrowLeft.scaleY = paginator.arrowRight.scaleY = 0.8;
			
			paginator.arrowLeft.x = rightPanel.x - paginator.arrowLeft.width / 2 - 5;
			paginator.arrowRight.x = rightPanel.x + rightPanel.width - paginator.arrowLeft.width / 2 + 15;
			
			paginator.arrowLeft.y = rightPanel.y + rightPanel.height / 2 + 5;
			paginator.arrowRight.y = paginator.arrowLeft.y;
			
			if (settings.content.length == 0) {
				paginator.arrowLeft.visible = false;
				paginator.arrowRight.visible = false;
			}
		}
		
		override public function contentChange():void {
			for each(var _item:* in items) {
				bodyContainer.removeChild(_item);
				_item.dispose();
			}
			items = [];
			
			var Xs:int = rightPanel.x + 28;
			var Ys:int = rightPanel.y + 50;
			
			var itemNum:int = 0;
			
			if (settings.content.length > 0){
				for (var i:int = paginator.startCount; i < paginator.finishCount; i++) {
					var item:FriendItem = new FriendItem(this, settings.content[i]);
					
					bodyContainer.addChild(item);
					item.x = Xs;
					item.y = Ys;
					
					items.push(item);
					Xs += item.bg.width + 20;					
					
					if (itemNum == 2 || itemNum == 5){
						Xs = rightPanel.x + 28;
						Ys += item.bg.height + 28;
					}
					itemNum++;
				}
				
				settings.page = paginator.page;
			}
		}
		
	}

}

import buttons.Button;
import buttons.EnergyButton;
import com.greensock.TweenLite;
import core.AvaLoad;
import core.Load;
import core.TimeConverter;
import flash.display.Bitmap;
import flash.display.Shape;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.text.TextField;
import ui.UserInterface;
import wins.CreateAnimalWindow;
import wins.Window;

internal class FriendItem extends LayerX
{
	private var window:CreateAnimalWindow;
	public var bg:Bitmap;
	public var friend:Object;
	
	private var title:TextField
	private var infoText:TextField
	private var sprite:LayerX = new LayerX();
	private var avatar:Bitmap = new Bitmap();
	public var selectBttn:EnergyButton;
	public var _animal:uint = 0;
	
	public var friendEnergy:int = App.data.options['FriendEnergy'] || 5;
	public var restoreTime:int = App.data.options['TimeEnergy'] || 7200;
	
	public var used:Boolean = false;
	
	public function FriendItem(window:CreateAnimalWindow, data:Object, self:Boolean = false)
	{
		this.window = window;
		
		if (self) {
			this.friend = App.user;
			bg = new Bitmap(Window.textures.friendSlot);
		}else {
			this.friend = App.user.friends.data[data.uid];
			bg = new Bitmap(Window.textures.friendSlot);
		}
		addChild(bg);
		addChild(sprite);
		sprite.addChild(avatar);
		
		sprite.tip = function():Object
		{
			var text:String;
			
			if (_animal)
				text = Locale.__e("flash:1470317281734")
			else
				text= Locale.__e("flash:1470317242975")
			
			return {
				text:text
			}
		}
		
		var first_Name:String = '';
		if (friend.first_name && friend.first_name.length > 0)
			first_Name = friend.first_name;
		else if (friend.aka && friend.aka.length > 0) {
			first_Name = friend.aka;
		}
		
		//Log.alert('FIRST NAME' + first_Name);
		if (first_Name.indexOf(' ') > 0) first_Name = first_Name.substring(0, first_Name.indexOf(' '));
		if (App.isSocial("SP")) 
		{
			if (friend.hasOwnProperty("uid") && friend.uid == "1") 
			{
				title = Window.drawText(!self?(first_Name):Locale.__e("flash:1382952380041") , {
					fontSize:23,
					color:0xf8f2e0,
					borderColor:0x502f06,
					textAlign:"center"
				});	
			}else 
			{
				title = Window.drawText(!self?(first_Name):Locale.__e("flash:1382952380041") , {
					fontSize:23,
					color:0xf8f2e0,
					borderColor:0x502f06,
					textAlign:"center"
				});
			}			
		}else 
		{
			title = Window.drawText(!self?(first_Name):Locale.__e("flash:1382952380041") , {
				fontSize:26,
				color:0xf8f2e0,
				borderColor:0x502f06,
				textAlign:"center"
			});	
		}		
		
		
		addChild(title);		
		title.width = bg.width;
		title.height = title.textHeight;
		title.x = 0;
		title.y = -5;
		
		new AvaLoad(friend.photo, onLoad);
		
		selectBttn = new EnergyButton({
			caption		:Locale.__e("+ " + friendEnergy),
			width: 88,
			height: 36,
			fontSize:22,
			fontColor:0xf4fbff,
			fontBorderColor:0x093b52,
			fontBorderSize:2,
			bgColor:[0xb5d8f6, 0x396bde],
			borderColor:[0xb9d5ea, 0x416ad3],
			bevelColor:	[0xb9d5ea,0x416ad3]
			//onClick:onSelectClick
		});
		selectBttn.addEventListener(MouseEvent.CLICK, onSelectClick);
		selectBttn.name = "EnergyFriendBttn";
		
		if(!self){
			addChild(selectBttn);		
		}
		selectBttn.x = (bg.width - selectBttn.width) / 2 + 2;
		selectBttn.y = bg.height - selectBttn.height + 21;
		
		infoText = Window.drawText("",{
			fontSize:20,
			color:0x898989,//0x502f06,
			borderColor:0xf8f2e0
		});
		
		addChild(infoText);		
		infoText.x = (bg.width - infoText.textWidth) / 2
		infoText.y = bg.height - infoText.textHeight - 5;	
		
		if(!self){
			if (window.friends[friend.uid] == undefined) {
						
				if (!friend.hasOwnProperty("wigwam")){
					animal = 0;
				}else{
					animal = friend.wigwam + restoreTime < App.time ? 0 : friend.wigwam;
				}
			}else {
				animal = window.friends[friend.uid].time;
			}
		}
	}
	
	private function onSelectClick(e:MouseEvent):void
	{
		if (window.animalEnergy.have >= window.animalEnergy.all) {
			return;
		}
		
		animal = App.time;
		window.friends[friend.uid] = {time:_animal, used:true};
		
					
		var energyIcon:Bitmap	= new Bitmap(UserInterface.textures.energyIcon);
		energyIcon.scaleX = energyIcon.scaleY = 0.7;
		var p:Point = new Point(window.bodyContainer.mouseX, window.bodyContainer.mouseY);
		energyIcon.x = p.x;
		energyIcon.y = p.y;
		window.bodyContainer.addChild(energyIcon);
		
				
		var have:int = window.animalEnergy.have += friendEnergy;
		if (window.animalEnergy.have >= window.animalEnergy.all) {
			window.animalEnergy.have = window.animalEnergy.all;
		//	window.createBttnBuy.visible = false;
		//	window.createBttn.visible = true;
			App.ui.flashGlowing(window.createBttn);
		}
		window.animalEnergy.counter = window.animalEnergy.have + ' / ' + window.animalEnergy.all;
		//window.textCount.text = String(Math.ceil(window.animalEnergy.all - window.animalEnergy.have) / App.data.options['SpeedUpEnergy']);
				window.textLabel.text ="+ "+ String(window.animalEnergy.all - window.animalEnergy.have);
		
		TweenLite.to(energyIcon, 0.8, { x:window.animalEnergy.x-2, y:window.animalEnergy.y-5, onComplete:function():void {
			window.bodyContainer.removeChild(energyIcon);
			energyIcon = null;
			window.animalEnergy.glowing();
			
		}});
		
		//window.settings.onSelectFriend(friend);
		//window.settings.onClose = null;
		//window.close();
	}
	
	public function set animal(value:uint):void
	{
		_animal = value;
		if (window.friends[friend.uid] != undefined && window.friends[friend.uid]['used'] != undefined) {
			
		}else{
			window.friends[friend.uid] = { time:_animal, used:false };
		}
		
		if (_animal != 0){
			selectBttn.visible = false;
			infoText.visible = true;
			onTimerEvent();
			App.self.setOnTimer(onTimerEvent);
		}
		else
		{
			selectBttn.visible = true;
			infoText.visible = false;
		}
	}
	
	private function onTimerEvent():void {
		infoText.text = TimeConverter.timeToStr(_animal + restoreTime - App.time);
		infoText.x = 20
		infoText.y = bg.height - infoText.textHeight - 5;	
	}
	
	private function onLoad(data:*):void {
		avatar.bitmapData = data.bitmapData;
		avatar.smoothing = true;
				
		var shape:Shape = new Shape();
		shape.graphics.beginFill(0x000000, 1);
		shape.graphics.drawRoundRect(0, 0, 50, 50, 12, 12);
		shape.graphics.endFill();
		sprite.mask = shape;
		sprite.addChild(shape);
		
		var scale:Number = 1.5;
		
		sprite.width *= scale;
		sprite.height *= scale;
		
		sprite.x = (bg.width - sprite.width) / 2;
		sprite.y = (bg.height - sprite.height) / 2;
	}
	
	public function dispose():void
	{
		selectBttn.removeEventListener(MouseEvent.CLICK, onSelectClick);
		App.self.setOffTimer(onTimerEvent);
		selectBttn.dispose();
	}
}

