package wins 
{
	import buttons.Button;
	import buttons.UpgradeButton;
	import com.greensock.easing.Strong;
	import com.greensock.TweenLite;
	import core.IsoConvert;
	import core.Load;
	import effects.Particles;
	import flash.display.Bitmap;
	import flash.display.GradientType;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.utils.clearInterval;
	import flash.utils.setInterval;
	import flash.utils.setTimeout;
	/**
	 * ...
	 * @author ...
	 */
	public class GoalWindow extends Window
	{
		private var captionText:String;
		public var preloader:Preloader = new Preloader();
		
		public function GoalWindow(settings:Object = null) 
		{
			if (settings == null) {
				settings = new Object();
			}
			settings['width'] = settings.width || 595;
			settings['height'] = settings.height || 360;
			settings.background = 'alertBacking'
			settings['hasTitle'] = false;
			settings.animationShowSpeed = 0.5;
			settings.hasExit = false;
			settings.hasPaginator  = false;
			settings.faderAsClose = false;
			settings.faderClickable = false;
			settings.escExit = false;
			super(settings);
		}
		
		public var backGradient:Shape;
		override public function drawFader():void {
		super.drawFader();
			var matrix:Matrix = new Matrix();
			matrix.createGradientBox(App.self.stage.stageWidth, App.self.stage.stageHeight, 1.5, 0, 0);
			backGradient = new Shape();
			backGradient.graphics.beginGradientFill(GradientType.LINEAR, [0x8cf6ff , 0x255f9a], [1, 1], [0, 255], matrix);
			backGradient.graphics.drawRect(0, 0, App.self.stage.stageWidth, App.self.stage.stageHeight);
			backGradient.graphics.endFill();
			addChildAt(backGradient, 0);
			//backGradient.filters = [new GlowFilter(0x4c4725, 1, 4, 4, 3, 1)];
			backGradient.alpha = 0;
		}
		
		public var goalIcon:Bitmap;
		//public var bttnMainHome:UpgradeButton;
		public var underBg:Bitmap;
		override public function drawBackground():void {
			super.drawBackground();
			
			background.x = - 70;
			
			switch (settings.quest.character)
			{
				case 1:
					goalIcon = new Bitmap(Window.textures.goalsChatsHuntsman, "auto", true);
				break;
				case 2:
					goalIcon = new Bitmap(Window.textures.goalsChatsLady, "auto", true);
				break;
				case 5:
					goalIcon = new Bitmap(Window.textures.goalsChatsWoodcutter, "auto", true);
				break;
				case 6:
					goalIcon = new Bitmap(Window.textures.goalsChatsSailor, "auto", true);
				case 7:
					goalIcon = new Bitmap(Window.textures.goalsChatsTommy, "auto", true);
				break;
				case 9:
					goalIcon = new Bitmap(Window.textures.goalsChatsGuide, "auto", true);
				break;
				case 10:
					goalIcon = new Bitmap(Window.textures.goalsChatsMiner, "auto", true);
				break;
				case 11:
					goalIcon = new Bitmap(Window.textures.goalsChatsBigMarie, "auto", true);
				break;
				case 12:
					goalIcon = new Bitmap(Window.textures.goalsChatsSheriff, "auto", true);
				break;
				case 13:
					goalIcon = new Bitmap(Window.textures.goalsChatsShepherd, "auto", true);
				break;
				case 15:
					goalIcon = new Bitmap(Window.textures.goalsChatsBandit, "auto", true);
				break;
				case 16:
					goalIcon = new Bitmap(Window.textures.goalsChatsLadyPink, "auto", true);
				break;
				case 17:
					goalIcon = new Bitmap(Window.textures.goalsChatsNewBoy, "auto", true);
				break;
				default:
					goalIcon = new Bitmap(Window.textures.goalsChatsHuntsman, "auto", true);
				break;
			}
			goalIcon.visible = false;
			goalIcon.x = 0;// (App.self.stage.stageWidth - settings.width) / 2 - goalIcon.width - layer.x;
			//goalIcon.y -= (goalIcon.height - settings.height) / 2 - layer.y;
			goalIcon.y = 0;// (goalIcon.height - settings.height) / 2 - layer.y;
			addChild(effContainer);
			addChild(goalIcon);
		}
		
		public var finishX:int; 
		public var finishY:int;
		public var finishGoalX:int;
		public var finishGoalY:int;
		public var mask2:Shape = new Shape();
		override public function startOpenAnimation():void {
			/*drawFader();
			drawHeader();
			drawBottom();
			drawBody();
			drawBackground();*/
			
			/*background.alpha = 0;
			bodyContainer.visible = false;
			headerContainer.visible = false;
			headerContainerSplit.visible = false;*/
			
			layer.x = -layer.width;// (App.self.stage.stageWidth - settings.width * .3) / 2;
			layer.y = (App.self.stage.stageHeight - settings.height*.3) / 2;
			goalIcon.x = (App.self.stage.stageWidth - settings.width*.3) / 2;
			goalIcon.y = (App.self.stage.stageHeight - settings.height*.3) / 2;
			
			finishX = (App.self.stage.stageWidth - settings.width+200) / 2;
			finishY = (App.self.stage.stageHeight - settings.height) / 2;
			finishGoalX = (App.self.stage.stageWidth - settings.width - 240) / 2;
			finishGoalY = (App.self.stage.stageHeight - goalIcon.height) / 2;
			
			mask2.graphics.beginFill(0x000000, 1);
			mask2.graphics.drawRect( finishGoalX + goalIcon.width/2,0,App.self.stage.stageWidth , App.self.stage.stageHeight);
			mask2.graphics.endFill();
			
			addChild(mask2);
			layer.mask = mask2;
			layer.visible = true;
			goalIcon.visible = false;
			goalIcon.scaleX = goalIcon.scaleY = 0.3;			
			layer.scaleX = layer.scaleY = 0.3;
			
		//	finishX = 250;
		//	finishY = 250;
			if (settings.quest.type == 3) {
				finishBackGradient();
			} else {
				TweenLite.to(backGradient, 1, { ease:Strong.easeOut, alpha:1, onComplete:finishBackGradient } );
			}
			// 1 second +
			// 1 second +
			//finishOpenLayer();
			//finishOpenAnimation()
			// 3 second +
		}
		
		public var timer:uint = 0;
		private function finishBackGradient():void 
		{
			/*timer = setTimeout(function():void {*/
				goalIcon.visible = true;
			TweenLite.to(goalIcon, 1, { x:finishGoalX+240, y:finishGoalY,ease:Strong.easeOut, alpha:1,scaleX:1,scaleY:1,onComplete:continueGoalIcon} );
			/*},500);*/
		}
		
		private function continueGoalIcon():void 
		{
			/*timer = setTimeout(function():void {*/
			goalIcon.visible = true;
			TweenLite.to(goalIcon, 1, { x:finishGoalX, y:finishGoalY, ease:Strong.easeOut, alpha:1, scaleX:1, scaleY:1, onComplete:finishGoalIcon } );
			TweenLite.to(layer, 1, { x:finishX+20, y:finishY, scaleX:1, scaleY:1, ease:Strong.easeOut, onComplete:finishOpenLayer } );
			/*},500);*/
		}
		
		private function finishGoalIcon():void 
		{
			/*timer = setTimeout(function():void {*/
			/*},200);*/
		}
		
		private var effContainer:LayerX = new LayerX()
		private function finishOpenLayer():void 
		{
			if (settings.quest.type == 3) {
				finishOpenAnimation();
			} else {
				timer = setTimeout(function():void {
				TweenLite.to(backGradient, 2/*,settings.animationShowSpeed*/, { ease:Strong.easeOut, alpha:0, onComplete:finishOpenAnimation } );
				},1500);
			}
			if (settings.quest.type == 4) {
				effContainer.x = layer.x;
				effContainer.y = layer.y+100;
				intervalEff = setInterval(function():void {
				var particle:Particles = new Particles();
				particle.init(effContainer, new Point(coordsEff[countEff].x, coordsEff[countEff].y));
				countEff++;
				if (countEff == 12)
					clearInterval(intervalEff);
			},2);
			
			setTimeout(function():void {
				addMore()
			},1000)
			}
		}
		
		private function addMore():void {
			countEff2 = 0;
			intervalEff2 = setInterval(function():void {
				var particle:Particles = new Particles();
				particle.init(effContainer, new Point(coordsEff[countEff2].x, coordsEff[countEff2].y));
				countEff2++;
				if (countEff2 == 12)
				clearInterval(intervalEff2);
				
			},2);
		}
		
		private var countEff:int = 0;
		private var countEff2:int = 0;
		private var intervalEff:int;
		private var intervalEff2:int;
		private var coordsEff:Object = { 
			/*0:{x:40, y:-100},
			1:{x:100, y:-110},
			2:{x:160, y:-110},
			3:{x:220, y:-120},
			4:{x:380, y:-100},
			5:{x:260, y:-120},
			6:{x:190, y:-110},
			7:{x:60, y:-100},
			8:{x:120, y:-110},
			9:{x:200, y:-120},
			10:{x:250, y:-120},
			11:{x:360, y:-100},
			12:{x:220, y:-120}*/
			0:{x:40-100, y:-100},
			1:{x:100-100, y:-110},
			2:{x:160, y:-110},
			3:{x:220-100, y:-120},
			4:{x:380+100, y:-100},
			5:{x:260, y:-120},
			6:{x:190, y:-110},
			7:{x:60, y:-100},
			8:{x:120-100, y:-110},
			9:{x:200, y:-120},
			10:{x:250+100, y:-120},
			11:{x:360+100, y:-100},
			12:{x:220, y:-120}
		};
		
		private var descLabel:TextField;
		private var bitmap:Bitmap;
		private var titleTxt:TextField;
		public var bonusList:RewardList;
		private function drawBonusInfo():void {
			bonusList = new RewardList(settings.quest.bonus['materials'], false, 0, Locale.__e("flash:1382952380000"), 1, 36, 10, 40, '', 0.8, 0, 0, true);
			bonusList.x = descLabel.x + 80;
			bonusList.y = descLabel.y + 60;
			
			var separator:Bitmap = Window.backingShort(395, 'dividerLine', false);
			separator.x = bonusList.x - 95;
			separator.y = bonusList.y + 52;
			separator.alpha = 0.4;
			bodyContainer.addChild(separator);
			
			var separator2:Bitmap = Window.backingShort(390, 'dividerLine', false);
			separator2.x = bonusList.x - 90;
			separator2.y = bonusList.y + 170;
			separator2.alpha = 0.4;
			bodyContainer.addChild(separator2);
			
			bodyContainer.addChild(bonusList);
		}
		
		override protected function onRefreshPosition(e:Event = null):void {
			super.onRefreshPosition();
			goalIcon.x = (App.self.stage.stageWidth - settings.width - 240) / 2;
			goalIcon.y = (App.self.stage.stageHeight - goalIcon.height) / 2;
			
			layer.x = (App.self.stage.stageWidth - settings.width+200) / 2 +20;
			layer.y = (App.self.stage.stageHeight - settings.height) / 2;
			//goalIcon.visible = false;
			mask2.x = goalIcon.x + (goalIcon.width / 2);
			mask2.height = App.self.stage.stageHeight;
			mask2.visible = false;
			layer.mask = null;
			/*var stageWidth:int = App.self.stage.stageWidth;
			var stageHeight:int = App.self.stage.stageHeight;
			
			layer.x = (stageWidth - settings.width) / 2;
			layer.y = (stageHeight - settings.height) / 2;
			
			if(settings.hasTitle){
				layer.y += headerContainer.height / 4;
			}
			
			if(fader){
				fader.width = stageWidth;
				fader.height = stageHeight;
			}*/
		}
		
		
		public var circle:Shape;
		private var myButton:Button;
		override public function drawBody():void {
			var globalOffsetX:int = 20;
			
			var title:TextField = Window.drawText(settings.quest.title, {
				color				:0xffffff,
				borderColor			:0xd49848,
				borderSize			:4,
				fontSize			:46,
				autoSize			:"center",
				shadowColor			: 0x553c2f,
				shadowSize			: 4
			});
			
			if (settings.quest.type == 2 || settings.quest.type == 4) {
				title.x = (settings.width - title.width) / 2 - 50;
				title.y = - 10;
			} else {
				title.x = (settings.width - title.width) / 2 - 50;
				title.y = - 10;
			}
			
			drawMirrowObjs('titleDecRose', title.x + 24, title.x + title.width -21, title.y + 12 , true, true, false);
			bodyContainer.addChild(title);
			
			switch (settings.quest.type) {
				case 1:
				//captionText = Locale.__e('flash:1424770409895');
				captionText = 'Текст 1';
				break;
				case 2:
				captionText = Locale.__e('flash:1382952380242');
				break;
				case 3:
				captionText = Locale.__e('flash:1382952380242');
				break;
				case 4:
				captionText = Locale.__e('flash:1404394519330');
				break;
			}
			
			var btnParams:Object = {
				caption:captionText,
				bgColor:[0xf5d058, 0xeeb331],
				bevelColor:[0xfff17f, 0xbf7e1a],
				borderColor:[0xc0aa8d, 0x214d68],
				fontSize:32,
				fontBorderColor:0x814f31,
				shadowColor:0x814f31,
				shadowSize:4,
				width:164,
				height:54
			};
			if (App.lang == 'jp') btnParams.fontSize = 24;
			myButton = new Button(btnParams);
			myButton.name = 'gw_bttn';
			myButton.x = (settings.width - myButton.width)/2 - 40;
			myButton.y = settings.height - 60;
			bottomContainer.addChild(myButton);
			myButton.addEventListener(MouseEvent.CLICK, bttnEvent);
			
			var descSize:int = 32;
			do {
				descLabel = Window.drawText(settings.quest.description, {//quest.description.replace(/\r/g,""), {
					color:0x542d0a, 
					border:false,
					fontSize:descSize,
					//fontSize:28,
					autoSize:'center',
					multiline:true,
					textAlign:"center",
					borderColor:0xf8e6d2,
					borderSize:2
				});
				descLabel.wordWrap = true;
				descLabel.width = 350;
				descLabel.height = descLabel.textHeight + 40;
				descSize -= 1;	
			}
			while (descLabel.height > 80);// (settings.height - title.height - btnParams.height));
			
			bodyContainer.addChild(descLabel);
			
			switch (settings.quest.type) {
				case 2:
					descLabel.x = (settings.width - descLabel.width) / 2 + globalOffsetX - 60;
					descLabel.y = title.y + title.height + 20;
					
					underBg = Window.backing(360, 130, 50, 'fadeOutWhite');
					underBg.x = (settings.width - underBg.width) / 2 - 20;
					//underBg.y = descLabel.y + descLabel.textHeight + globalOffsetX + 10;
					underBg.y = descLabel.y + descLabel.textHeight + globalOffsetX- 6;
					underBg.alpha = 0.2;
					bodyContainer.addChild(underBg);
					
					var separator:Bitmap = Window.backingShort(underBg.width, 'dividerLine', false);
					separator.x = underBg.x;
					separator.y = underBg.y;
					separator.alpha = 0.5;
					bodyContainer.addChild(separator);
					
					var separator2:Bitmap = Window.backingShort(underBg.width, 'dividerLine', false);
					separator2.x = underBg.x;
					separator2.y = underBg.y + underBg.height - 4;
					separator2.alpha = 0.5;
					bodyContainer.addChild(separator2);
					
					var rad:int = 50;
					circle = new Shape();
					circle.graphics.beginFill(0xc7cdbf, 1);
					circle.graphics.drawCircle(underBg.x + underBg.width/2 - 10, underBg.y + underBg.height/2, rad);
					circle.graphics.endFill();
					bodyContainer.addChild(circle);
					
					preloader.x = underBg.x +(underBg.width) / 2;
					preloader.y = underBg.y +(underBg.height) / 2;
					bodyContainer.addChild(preloader);
					
					Load.loading(Config.getIcon(App.data.storage[settings.quest.target].type, App.data.storage[settings.quest.target].preview), onPreviewComplete);
				break;
				case 3:
					descLabel.x = (settings.width - descLabel.width) / 2 + globalOffsetX - 60;
					descLabel.y = title.y + title.height + 65;
				break;
				case 4:
					descLabel.x = (settings.width - descLabel.width) / 2 + globalOffsetX - 60;
					descLabel.y = title.y + title.height + 20;
					drawBonusInfo();
				break;
			}
		}
		
		public function onPreviewComplete(data:Object):void
		{
			if (preloader) {
				bodyContainer.removeChild(preloader);
				preloader = null;
			}
			bitmap = new Bitmap();
			var itemContainer:LayerX = new LayerX;
			itemContainer.addChild(bitmap);
			bodyContainer.addChild(itemContainer);
			bitmap.bitmapData = data.bitmapData;
			var scale:Number = 75 / data.height;
			bitmap.width 	*= scale;
			bitmap.height 	*= scale;
			bitmap.smoothing = true;
			itemContainer.tip = function():Object { 
					return {
						title:App.data.storage[settings.quest.target].title
						
					};
			}
			titleTxt = Window.drawText(settings.quest.goal, {
				fontSize:24,
				color:0xffffff,
				textAlign:"center",
				borderColor:0x603508,
				width:200
			});
			//levelTxt.width = 120;
			itemContainer.addChild(titleTxt);
			itemContainer.x = underBg.x +(underBg.width - bitmap.width) / 2 - 10;
			itemContainer.y = underBg.y + (underBg.height - bitmap.height) / 2 + 5;
			titleTxt.x = bitmap.x + (bitmap.width - titleTxt.width) / 2 ;
			titleTxt.y -= 30;
		}
		
		private function bttnEvent(e:MouseEvent):void {
			switch (settings.quest.type) {
				case 2:
					App.user.quests.readEvent(settings.quest.ID, function():void { }) ;
				break;
				case 3:
					App.user.quests.readEvent(settings.quest.ID, function():void { }) ;
				break;
				case 4:
					var position:Object = App.map.heroPosition;
					var position2:* = IsoConvert.isoToScreen(position.x, position.z,true);
					Treasures.bonus(Treasures.convert(settings.quest.bonus['materials']), new Point(position2.x, position2.y));
					
					App.user.quests.readEvent(settings.quest.ID, function():void { }) ;
				break;
			}
			
			close();
		}
	}
}