package wins 
{
	import buttons.Button;
	import buttons.ImageButton;
	import core.Load;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.StageDisplayState;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import ui.UserInterface;
	import units.Hero;
	import units.Personage;

	public class HeroWindow extends Window
	{
		
		public var femaleBttn:ImageButton;
		public var maleBttn:ImageButton;
		public var saveBttn:Button;
		public var akaField:TextField;
		public var hero:Personage;
		
		public var saveSttings:Object = { };
		
		public var preloader:Preloader = new Preloader();
		
		public function HeroWindow(settings:Object = null) 
		{
			if (settings == null) {
				settings = new Object();
			}
			
			settings['sID'] = settings.sID || 0;
			
			settings["width"] = 260;
			settings["height"] = 384;
			settings["fontSize"] = 30;
			settings["hasPaginator"] = false;
			
			settings["title"] = Locale.__e("Я");
			
			saveSttings['sex'] = App.user.sex || 'm';
			saveSttings['aka'] = App.user.aka || App.user.first_name;
			
			super(settings);	
		}
		
		override public function drawBackground():void {
			//var background:Bitmap = backing(settings.width, settings.height, 30, "itemBacking");
			//layer.addChild(background);
		}
		
		override public function drawBody():void {
			
			titleLabel.y = -14;
			
			var background:Bitmap = backing(settings.width, settings.height, 30, "windowBacking");
			layer.addChild(background);
			
			exit.x = settings.width - exit.width + 12;
			titleLabel.x = (settings.width - titleLabel.width) * .5;
			
			var akaBg:Shape = new Shape();
			akaBg.graphics.lineStyle(2, 0x5d5321, 1, true);
			akaBg.graphics.beginFill(0xddd7ae,1);
			akaBg.graphics.drawRoundRect(0, 0, 160, 25, 15, 15);
			akaBg.graphics.endFill();
			akaBg.x = (settings.width - akaBg.width) / 2;;
			akaBg.y = 10;
			bodyContainer.addChild(akaBg);
			
			akaField = Window.drawText(saveSttings.aka, {
				color:0x4f4f4f,
				borderColor:0xfcf6e4,
				border:false,
				textAlign:"left",
				fontSize:20,
				multiline:true,
				input:true
			});
			akaField.height = 22;
			akaField.maxChars = 20;
			akaField.x = akaBg.x + 6;
			akaField.y = akaBg.y + 1;
			bodyContainer.addChild(akaField);
			
			akaField.addEventListener(FocusEvent.FOCUS_IN, onFocusInEvent);
			akaField.addEventListener(FocusEvent.FOCUS_OUT, onFocusOutEvent);
			
			var heroBg:Bitmap = backing(180, 200, 30, "itemBacking");
			bodyContainer.addChild(heroBg);
			heroBg.x = (settings.width - heroBg.width) / 2;
			heroBg.y = 40;
			
			hero = new Personage( { sid:Personage.HERO, x:10, z:10 } );
			hero.uninstall();
			hero.touchable = false;
			hero.clickable = false;
			bodyContainer.addChild(hero);
			hero.framesType = 'walk';
			//hero.startAnimation();
			hero.x = heroBg.x + 90;
			hero.y = heroBg.y + 140;
			
			var sexLabel:TextField = Window.drawText(Locale.__e("Пол:"), {
				fontSize:20,
				autoSize:"left"
			});
			bodyContainer.addChild(sexLabel);
			sexLabel.x = (settings.width - sexLabel.width) / 2;
			sexLabel.y = heroBg.y + heroBg.height + 2; 
			
			var sexBg:Bitmap = backing(160, 76, 30, "bonusBacking");
			bodyContainer.addChild(sexBg);
			sexBg.x = (settings.width - sexBg.width) / 2;
			sexBg.y = sexLabel.y + sexLabel.height - 4;
			
			femaleBttn = new ImageButton(UserInterface.textures.female);
			maleBttn = new ImageButton(UserInterface.textures.male);
			
			femaleBttn.addEventListener(MouseEvent.CLICK, onFemaleClick);
			maleBttn.addEventListener(MouseEvent.CLICK, onMaleClick);
			
			bodyContainer.addChild(maleBttn);
			maleBttn.x = sexBg.x + 10;
			maleBttn.y = sexBg.y + 12;
			
			bodyContainer.addChild(femaleBttn);
			femaleBttn.x = sexBg.x + 10 + maleBttn.width;
			femaleBttn.y = sexBg.y + 12;
			
			if (saveSttings.sex == 'm') {
				onMaleClick();
			}else {
				onFemaleClick();
			}
			
			saveBttn = new Button( {
				width:100,
				height:30,
				fontSize:22,
				caption:Locale.__e("Сохранить")
			});
			saveBttn.x = (settings.width - saveBttn.width) / 2;
			saveBttn.y = sexBg.y + sexBg.height + 6;
			
			bodyContainer.addChild(saveBttn);
			saveBttn.addEventListener(MouseEvent.CLICK, onSaveEvent);
		}
		
		private function onFemaleClick(e:MouseEvent = null ):void {
			saveSttings.sex = 'f';
			maleBttn.filters = [];
			femaleBttn.filters = [new GlowFilter(0xfbd9df, 1, 10, 10, 4)];
			
			hero.stopAnimation();
			Load.loading(Config.getSwf(hero.type, 'girl'), hero.onLoad);
		}
		private function onMaleClick(e:MouseEvent = null):void {
			saveSttings.sex = 'm';
			femaleBttn.filters = [];
			maleBttn.filters = [new GlowFilter(0xd5edf8, 1, 10, 10, 4)];
			
			hero.stopAnimation();
			Load.loading(Config.getSwf(hero.type, 'boy'), hero.onLoad);
		}
		
		private function onFocusInEvent(e:Event):void {

			if (App.self.stage.displayState != StageDisplayState.NORMAL) {
				App.self.stage.displayState = StageDisplayState.NORMAL;
			}
			
			if(e.currentTarget.text == saveSttings.aka)	e.currentTarget.text = "";
		}
		private function onFocusOutEvent(e:Event):void {
			if(e.currentTarget.text == "" || e.currentTarget.text == " ") e.currentTarget.text = saveSttings.aka;
		}
		
		
		override public function drawExit():void {
			super.drawExit();
			
			exit.x = settings.width - exit.width + 12;
			exit.y = -12;
		}
		
		
		private function onSaveEvent(e:MouseEvent):void {
			saveSttings.aka = akaField.text;
			App.user.sex = saveSttings.sex;
			App.user.onProfileUpdate(saveSttings);
			App.user.hero.textures = hero.textures;
			close();
		}
		
		override public function dispose():void {	
			super.dispose();
			
			hero.stopAnimation();
			hero = null;
			
			akaField.removeEventListener(FocusEvent.FOCUS_IN, onFocusInEvent);
			akaField.removeEventListener(FocusEvent.FOCUS_OUT, onFocusOutEvent);
			
			femaleBttn.removeEventListener(MouseEvent.CLICK, onFemaleClick);
			maleBttn.removeEventListener(MouseEvent.CLICK, onMaleClick);
			
			saveBttn.removeEventListener(MouseEvent.CLICK, onSaveEvent);
		}
			
		
	}

}