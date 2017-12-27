package wins 
{
	import buttons.Button;
	import com.greensock.TweenLite;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.utils.setTimeout;
	import ui.UserInterface;
	import units.Hero;
	import wins.elements.DialogElement;
	/**
	 * ...
	 * @author 
	 */
	public class DialogWindow extends Window
	{
		
		private static var positions:Object = {
			0:{
				posX: -180,
				posY: -25,
				txtWidth:230,
				mode:DialogElement.MODE_LEFT
			},
			1:{
				posX:444 + 20,
				posY: 150,
				txtWidth:320,
				mode:DialogElement.MODE_RIGHT
			},
			2:{
				posX:-180,
				posY:320,
				txtWidth:230,
				mode:DialogElement.MODE_LEFT
			}
		}
		
		public function DialogWindow(settings:Object = null) 
		{
			if (settings == null) {
				settings = new Object();
			}
			
			settings['width'] = 444;
			settings['height'] = 500;
			settings['hasPaginator'] = false;
			settings['hasButtons'] = false;
			settings['hasExit']	= false;
			settings['hasPaginator'] = false;
			settings['hasTitle'] = false;
			
			settings['faderAsClose'] = false;
			settings['faderClickable'] = false;
			settings['escExit'] = false;
			
			super(settings);
		}
		
		override public function drawBackground():void {
				
		}
		
		private var arrPersInds:Array = [];
		private var arrIcons:Array = [];
		override public function drawBody():void 
		{
			var count:int = 0;
			for (var id:* in settings.pers) {
				
				arrPersInds.push(id);
				
				var data:Object = settings.pers[id];
				
				var icon:IconHero = new IconHero(this,positions[count].mode, data);
				bodyContainer.addChild(icon);
				arrIcons.push(icon);
				
				var dX:int = data.dX || 0;
				var dY:int = data.dY || 0;
				
				icon.x = positions[count].posX + dX;
				icon.y = positions[count].posY + dY;
				//if (data.pers == 162)
					//{
						//icon.y += 10;
						//trace("");
					//}
				icon.alpha = 0;
				
				count++;
			}
			
			//setTimeout(function():void { TweenLite.to(arrIcons[0], 0.5, { alpha:1, onComplete:drawMessage } ) }, 100);
		}
		
		private var numWindow:int = 0;
		private function drawMessage():void 
		{
			var posX:int;
			var posY:int;
			
			var mode:int;
			
			var data:Object = settings.pers[numWindow];
			
			var sett:Object = {
				bttnWidth:180,
				bttnHeight:40,
				fontSizeBttn:30
			};
			
			var icon:Sprite = arrIcons[numWindow];
				
			sett['desc'] = Locale.__e(data.text);
			sett['textWidth'] = positions[numWindow].txtWidth;
			sett['isBttn'] = data.isBttn;
			
			/*if(data.pers != 206)
				SoundsManager.instance.playSFX(Hero.randomSound(data.pers, 'voice'), null, 0, 3);*/
			
			var element:DialogElement = new DialogElement(positions[numWindow].mode, sett, onConfirm);
			bodyContainer.addChild(element);
			
			switch(positions[numWindow].mode) {
				case DialogElement.MODE_LEFT:
					posX = icon.x + icon.width - 6;
					posY = icon.y + icon.height - element.height - 40;
				break;
				case DialogElement.MODE_RIGHT:
					posX = icon.x - element.width + 6;
					posY = icon.y + icon.height - element.height - 40;
				break;
			}
			
			element.x = posX;
			element.y = posY;
			
			element.alpha = 0;
			
			numWindow++;
			
			TweenLite.to(element, 0.5, { alpha:1, onComplete:function():void {
				if (numWindow < arrIcons.length)
					TweenLite.to(arrIcons[numWindow], 0.5, {alpha:1, onComplete:drawMessage});
			}});
			
		}
		
		private function onConfirm():void {
			
			switch(settings.qID) {
				case 90:
				case 91:
				case 92:
				case 93:
				case 94:
				case 95:
					App.user.quests.readEvent(settings.qID, function():void {});
				break;
				/*case 0:
					App.user.step3();
				break;
				case 75:
					App.user.quests.helpEvent(settings.qID, settings.mID);
					break;
				case 112:
					App.user.quests.readEvent(settings.qID, function():void {});
					break;	
				case 108:
					App.tutorial.addFullScreenBttn();
					break;		
				case 79:
					App.tutorial.personagesMoveToCat();
					break;		
				case 123:
				case 129:
				case 130:
				case 131:
				case 132:
				case 137:
				case 138:
					//App.user.quests.lockFuckAll();
					App.user.quests.readEvent(settings.qID, function():void {});
					break;	*/
				/*case 6:
					App.tutorial.nextStep(6, 1);
					break;		*/	
			}
			close();
		}
		
	}

}
import flash.display.Bitmap;
import flash.display.MovieClip;
import flash.text.TextField;
import ui.UserInterface;
import wins.DialogWindow;
import wins.elements.DialogElement;
import wins.Window;
import flash.display.Sprite;

internal class IconHero extends Sprite
{
	public var window:DialogWindow;
	
	private var data:Object;
	
	private var mode:int;
	
	public function IconHero(win:DialogWindow, mode:int, data:Object) {
		
		window = win;
		this.data = data;
		this.mode = mode;
		
		drawBody();
	}
	
	private function drawBody():void 
	{
		var icon:Bitmap;
		//var eyes:MovieClip;
		switch(data.pers) {
			case User.PRINCE:
				icon = new Bitmap(Window.textures.tutorialPrince);
				icon.smoothing = true;
				addChild(icon);
			break;
			case User.PRINCESS:
				icon = new Bitmap(Window.textures.tutorialPrincess);
				icon.smoothing = true;
				addChild(icon);
			break;
			//case User.LEA:  //малышка
				////icon = new Bitmap(UserInterface.textures.tutorialChar3);
				////eyes = new TutorialChar3;
			//break;
			//case User.SPARK:  //кот
				//icon = new Bitmap(UserInterface.textures.tutorialChar4);
				//icon.smoothing = true;
				//addChild(icon);
			//break;
		}
		
		if (mode == DialogElement.MODE_RIGHT) {
			if(icon){
				icon.scaleX = -1;
				icon.x += icon.width;
				icon.y += 20;
			}
		}
			//if(eyes){
				//eyes.scaleX = -1;
				//eyes.x += eyes.width;
			//}
		
		//if (eyes) {
			//addChild(eyes);
		//}
		
		var namePers:TextField = Window.drawText(App.data.storage[data.pers].title, {
			color:0xffffff,
			borderColor:0x8a572a,
			textAlign:"center",
			autoSize:"center",
			fontSize:26,
			textLeading:-6,
			multiline:true
		});
		namePers.width = namePers.textWidth + 10;
		addChild(namePers);
		
		var strWidth:int = namePers.width + 24;
		if (strWidth < 56) strWidth = 56;
		  
		//var stripe:Bitmap = Window.backingShort(strWidth, "tutorialRibbon");
		var stripe:Bitmap = new Bitmap(Window.textures.tutorialCharsBacking);
		addChildAt(stripe, 0);
		
		var strpX:int;
		var strpY:int;
		
		if (icon) {
			if (mode == DialogElement.MODE_RIGHT)
			{
				strpX = (icon.width - stripe.width) / 2 + 25;
				icon.x += 25;
				icon.y -= 10;
				strpY = icon.y + 10;
			}else if (data.pers == 162) {
				strpX = (icon.width - stripe.width) / 2;
				strpY = icon.y + 9;
			}else{
				strpX = (icon.width - stripe.width) / 2;
				strpY = icon.y + 13;
			}
			
		}//else {
			//strpX = (eyes.width - stripe.width) / 2;
			//strpY = eyes.height - 18;
		//}
		
		stripe.x = strpX;//(icon.width - stripe.width) / 2;
		stripe.y = strpY;//icon.height - 18;
		
		namePers.x = stripe.x + (stripe.width - namePers.width) / 2 - 2;
		namePers.y = stripe.y + (stripe.height - 38);
	}
}