package wins 
{
	import buttons.Button;
	import flash.display.Bitmap;
	import flash.events.MouseEvent;
	import core.Load;
	import flash.geom.Point;
	import flash.text.TextField;
	/**
	 * ...
	 * @author ...
	 */
	public class ConciergeHelpWindow extends Window
	{
		private var bttn:Button;
		
		public var icon1:Bitmap = new Bitmap();
		public var icon2:Bitmap = new Bitmap();
		
		public function ConciergeHelpWindow(settings:Object = null) 
		{
			settings['title'] = settings.title;
			settings['width'] = 500;
			settings['height'] = (settings.hasOwnProperty('type')&&settings.type=='description1')?480:310;
			settings['popup']  = true;
			settings['hasPaginator']  = false;
			settings['background'] = 'questsSmallBackingTopPiece';
			
			super(settings);
			
		}
		
		public static function init(callback:Function):void {
			Load.loading(Config.getIcon('Furkies', 'twoMasters'), function(data:*):void {
				callback();
			});
		}
		
		private var shine:Bitmap = new Bitmap();
		private function putShine(pt:Point = null):void {
			if (!pt)
			pt = new Point(15, -40);
			shine = new Bitmap(Window.textures.productionReadyBacking);
			shine.scaleX = shine.scaleY = 1.7;
			shine.y = pt.x;
			shine.x = pt.y;
			bodyContainer.addChild(shine);
		}
		
		public function onPreviewCompleteLeft(data:Bitmap):void
		{
			//var centerY:int = 90;
			var bitmap:Bitmap = new Bitmap();
			
			bitmap.bitmapData = data.bitmapData;
			//bitmap.smoothing = true;

			icon1 = new Bitmap(bitmap.bitmapData);
			bodyContainer.addChild(icon1);
			icon1.x = 409;
			icon1.y = 100;
			icon2.x = -147;
			icon2.y = -70;
		}

		public function onPreviewCompleteRight(data:Bitmap):void
		{
			//var centerY:int = 90;
			var bitmap:Bitmap = new Bitmap();
			bitmap.bitmapData = data.bitmapData;
			//bitmap.smoothing = true;
			
			icon2 = new Bitmap(bitmap.bitmapData);

			bodyContainer.addChild(icon2);
			icon1.x = 409;
			icon1.y = 100;
			icon2.x = -147;
			icon2.y = -70;
		}
		
		override public function drawBody():void
		{
			exit.y -= 10;
			if (settings.type == 'furkies') {
				settings.width = 488;
				settings.height = 332;
			}
			drawMirrowObjs('diamondsTop', settings.width / 2 - settings.titleWidth / 2 - 5, settings.width / 2 + settings.titleWidth / 2 + 5, -45, true, true);
			drawMirrowObjs('storageWoodenDec', 12, settings.width - 12, settings.height - 120);
			var descPos:Point = new Point(0, 0);

			var locale1Val:String = "flash:1410423986359";
			var locale2Val:String = "flash:1410424020110";
			var buttTxt:String = "flash:1382952380298";
			
			var bg:Bitmap = new Bitmap();
			if (settings.type == 'furkies') {
				buttTxt = "flash:1382952380228";
				Load.loading(Config.getIcon('Furkies', 'master'), onPreviewCompleteLeft);
				Load.loading(Config.getIcon('Furkies', 'twoMasters'), onPreviewCompleteRight);
				bg = Window.backing(380,  300, 80, 'dialogueBacking');
				descPos.x = 100;
				bg.x += descPos.x;

				locale1Val = "flash:1414157294334";
				locale2Val = "flash:1414157484590";
			}else{
			if (settings.type == 'description1') {
				bg = Window.backing(380,  300, 80, 'dialogueBacking');
				descPos.x = 100;
				bodyContainer.addChild(bg);
				bg.x += descPos.x;
				putShine(new Point(-50,50));
				icon1 = new Bitmap(Window.textures.doorMan3);
				icon1.x = 50;
				icon1.y = -50;
				bodyContainer.addChild(icon1);
			}else {
				icon1 = new Bitmap(Window.textures.doorMan3);
				icon1.x = - icon1.width/2 + 20;
				icon1.y = -145;
				bodyContainer.addChild(icon1);
				
				icon2 = new Bitmap(Window.textures.moneymanBig);
				icon2.x = settings.width -  icon1.width/2 - 30;
				icon2.y = settings.height - 210;
				bodyContainer.addChild(icon2);
			}
			}
			
			var txtInfo1:TextField = Window.drawText(Locale.__e(locale1Val), {
				fontSize:26,
				textLeading:2,
				color:0x65371b,
				borderColor:0xeed3a4,
				multiline:true,
				textAlign:"center"
			});
			
			txtInfo1.wordWrap = true;
			txtInfo1.width = 330;
			txtInfo1.height = txtInfo1.textHeight + 10;
			bodyContainer.addChild(txtInfo1);
			if (settings.type == 'furkies') {
				txtInfo1.x = descPos.x + 50;
			}else {
				txtInfo1.x = descPos.x + 130;
			}
			txtInfo1.y = 6;
			
			var separator:Bitmap = Window.backingShort(240, 'divider');
			separator.alpha = 0.5;
			bodyContainer.addChild(separator);
			separator.x = (settings.width - separator.width)/2 + 60;
			separator.y = 110;
			
			var txtInfo2:TextField = Window.drawText(Locale.__e(locale2Val), {
				fontSize:26,
				textLeading:2,
				color:0x65371b,
				borderColor:0xeed3a4,
				multiline:true,
				textAlign:"center"
			});
			txtInfo2.wordWrap = true;
			txtInfo2.width = (settings.type == 'furkies')?260:330;
			txtInfo2.height = txtInfo2.textHeight + 10;
			bodyContainer.addChild(txtInfo2);
			txtInfo2.x = descPos.x+40;
			txtInfo2.y = 140;

			var bttnSettings:Object = {
				caption:Locale.__e(buttTxt),
				fontSize:26,
				width:154,
				height:45
			};
			
			if (settings.type == 'description1') {
				txtInfo1.x = 40;
			}
			
			if (App.SERVER == 'NK' || App.SOCIAL == 'NK') {
				bttnSettings.width += 35;
			}
			
			bttn = new Button(bttnSettings);
			
			if (settings.type == 'furkies'){
				bttn.x = (settings.width - bttn.width) / 2;
			}else {
				bttn.x = descPos.x +(settings.width - bttn.width) / 2;
			}

			bttn.y = settings.height - bttn.height - 20;
			//if(settings.type == 'furkies')
			bodyContainer.addChild(bttn);
			icon1.x = 409;
			icon1.y = 100;
			icon2.x = -147;
			icon2.y = -100;
			
			if (settings.type == 'furkies') {
				txtInfo2.x += 5;
				separator.y += 30;
				separator.x -= 20;
				txtInfo2.y += 40;
			}
			bttn.addEventListener(MouseEvent.CLICK, onClick);
		}
		
		private function onClick(e:MouseEvent):void {
			if (settings.type == 'furkies') {
				ShopWindow.show( {find:[589,590,591]} );
			}
			close();
		}
		
		override public function close(e:MouseEvent = null):void
		{
			bttn.removeEventListener(MouseEvent.CLICK, close);
			bttn.dispose();
			bttn = null;
			
			super.close(e);
		}
	}
}