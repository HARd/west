package wins 
{
	import buttons.Button;
	import buttons.MixedButton2;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	/**
	 * ...
	 * @author ...
	 */
	public class FactoryWindow extends Window
	{
		public var upgBttn:Button;
		
		public function FactoryWindow(settings:Object = null) 
		{
			settings['width'] = 370;
			settings['height'] = 402;
			settings['fontSize'] = 36;
			settings['hasButtons'] = false;
			settings['hasPaginator'] = false;
			
			settings['upgTime'] = settings.upgTime;
			settings['request'] = settings.request;
			settings['onUpgrade'] = settings.onUpgrade;
			
			super(settings);
		}
		
		override public function drawBackground():void {
			background = backing2(settings.width, settings.height, 45, "questsSmallBackingTopPiece", "questsSmallBackingBottomPiece");
			layer.addChildAt(background, 0);
		}
		
		private var underDesc:Bitmap;
		override public function drawBody():void {
			exit.y -= 10;
			titleLabel.y -= 2;
			drawBackgrounds();
			drawDesc();
			drawBttn();
		}
		
		private function drawBttn():void
		{
			if(settings.target.level < settings.target.totalLevels && settings.target.info.devel.req[settings.target.level+1].l <= App.user.level){
				upgBttn = new Button( {
					width:182,
					height:54,
					fontSize:28,
					hasDotes:false,
					bgColor:[0xf5d058,0xeeb331],
					caption:Locale.__e("flash:1393580410391")
				});
				bodyContainer.addChild(upgBttn);
				upgBttn.x = (settings.width - upgBttn.width) / 2;
				upgBttn.y = settings.height - upgBttn.height / 2 - 37;
				
				upgBttn.addEventListener(MouseEvent.CLICK, onUpgrade);
			}else {
				var icon:Bitmap = new Bitmap(Window.textures.star, "auto", true);
			
				var neddLvlBttn:MixedButton2 = new MixedButton2(icon,{
					title: Locale.__e("flash:1393579961766") + "    " + settings.target.info.devel.req[settings.target.level + 1].l,// flash:1382952380253"),
					width:236,
					height:55,
					countText:"",
					fontSize:24,
					iconScale:0.95,
					hasDotes:false,
					grayDotes:false,
					radius:20,
					bgColor:[0xe4e4e4, 0x9f9f9f],
					bevelColor:[0xfdfdfd, 0x777777],
					fontColor:0xffffff,
					fontBorderColor:0x575757,
					fontCountColor:0xffffff,
					fontCountBorder:0x575757
				})
				
				bodyContainer.addChild(neddLvlBttn);
				neddLvlBttn.x = (settings.width - neddLvlBttn.width)/2 + 4;
				neddLvlBttn.y = settings.height - neddLvlBttn.height - 10;
				
				neddLvlBttn.textLabel.x += 16;
				
				neddLvlBttn.coinsIcon.x += 209;
				neddLvlBttn.coinsIcon.y -= 4;
				neddLvlBttn.countLabel.x += 86; neddLvlBttn.countLabel.y += 10;
				neddLvlBttn.textLabel.x += 12;
				//neddLvlBttn.state = Button.DISABLED;
			}
		}
		
		private function drawBackgrounds():void
		{
			var bg:Bitmap = Window.backing(294, 262, 56, "itemBacking");
			bodyContainer.addChild(bg);
			bg.y = -2;
			bg.x = (settings.width - bg.width) / 2;
			
			var bitmap:Bitmap = new Bitmap(settings.target.bitmap.bitmapData);
			bodyContainer.addChild(bitmap);
			bitmap.height = bg.height - 30;
			bitmap.scaleX = bitmap.scaleY;
			bitmap.smoothing = true;
			bitmap.x = bg.x + (bg.width - bitmap.width) / 2;
			bitmap.y = bg.y + (bg.height - bitmap.height) / 2;
			
			var separator:Bitmap = Window.backingShort(320, "separator2");
			separator.x = (settings.width - separator.width) / 2;
			separator.y = settings.height - separator.height - 86;
			separator.alpha = 0.5;
			bodyContainer.addChild(separator);
			
			underDesc = Window.backingShort(210, "underPiece");
			underDesc.x = (settings.width - underDesc.width) / 2;
			underDesc.y = settings.height - underDesc.height - 72;
			bodyContainer.addChild(underDesc);
		}
		
		public function drawDesc():void 
		{
			var descContainer:Sprite = new Sprite();
			
			var available:TextField = Window.drawText(Locale.__e("flash:1382952380212"), {
				color:0xffffff, 
				borderColor:0x2b3b64,
				fontSize:30,
				textAlign:"left"
			});
			available.width = available.textWidth + 10;
			available.height = available.textHeight + 10;
			available.y = 10;
			descContainer.addChild(available);
			
			//var icon:Bitmap = new Bitmap(Window.textures.techno);
			//icon.x = available.x + available.width + 4;
			//icon.y = 6;
			//descContainer.addChild(icon);
			
			//var countTxt:TextField = Window.drawText(settings.target.level, {
				//color:0xffffff, 
				//borderColor:0x2b3b64,
				//fontSize:30,
				//textAlign:"left"
			//});
			//countTxt.width = countTxt.textWidth + 10;
			//countTxt.height = countTxt.textHeight + 10;
			//descContainer.addChild(countTxt);
			//countTxt.x = icon.x + icon.width + 6;
			//countTxt.y = available.y;
			
			
			bodyContainer.addChild(descContainer);
			descContainer.x = underDesc.x + (underDesc.width - descContainer.width) / 2;
			descContainer.y = underDesc.y;
		}
		
		private function onUpgrade(e:MouseEvent):void 
		{
			new ConstructWindow( {
				title:settings.target.info.title,
				upgTime:settings.upgTime,
				request:settings.request,
				target:settings.target,
				win:this,
				onUpgrade:onUpgradeAction,
				hasDescription:true
			}).show();
		}
		
		public function onUpgradeAction():void
		{
			close();
			settings.target.upgradeEvent(settings.request);
		}
		
		override public function dispose():void
		{
			underDesc = null;
			background = null;
			upgBttn = null;
			
			super.dispose();
		}
		
		
	}

}