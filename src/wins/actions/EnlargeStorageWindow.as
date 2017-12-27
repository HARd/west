package wins.actions 
{
	import api.ExternalApi;
	import buttons.Button;
	import com.flashdynamix.motion.extras.BitmapTiler;
	import core.Load;
	import core.Post;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.text.TextField;
	import ui.Hints;
	import wins.AddWindow;
	import wins.Window;
	import wins.SimpleWindow;
	/**
	 * ...
	 * @author ...
	 */
	public class EnlargeStorageWindow extends AddWindow 
	{
		private var back:Bitmap;
		private var preloader:Preloader = new Preloader();
		private var bitmap:Bitmap;
		private var sID:String;
		private var actionCounter:int;
					
		public function EnlargeStorageWindow(settings:Object=null) 
		{
			settings['width'] = 505;
			settings['height'] = 345;
			settings['title'] = settings.title || Locale.__e('flash:1396521604876');
			settings['hasPaginator'] = false;
			settings['hasButtons'] = false;
			settings['promoPanel'] = true;
			super(settings);	
			
			action = App.data.actions[settings.pID];
			action.id = settings.pID;
			for (var sid:* in action.items) {
				sID = sid;
			}
			countAction();
		}
		
		private function countAction():void
		{
			if (App.user.stock.count(365) > 0) {
				actionCounter = 2;
			}else {
				actionCounter = 1;
			}
			/*
			if (actionCounter<2) 
			{
				if (App.user.stock.count(365)) {
					actionCounter += App.user.stock.count(365);
				}
				if (actionCounter<2) 
				{
					if (World.getBuildingCount(365)) {
					actionCounter += World.getBuildingCount(365);
					}	
				}
				if (actionCounter >= 2) {
					actionCounter = 2;
				}
				if (actionCounter == 0) {
					actionCounter = 1;
				}
			}*/
		}
		
		override public function drawBackground():void
		{
			var background:Bitmap = backing(settings.width, settings.height, 25, 'questBacking');
			layer.addChild(background);
		}
		
		override public function drawBody():void
		{
			exit.y -= 20;
			drawIcon();
			
			back = backing(288, 220, 20, 'dialogueBacking');
				back.x = (settings.width - back.width) / 2 + 85;
				back.y = (settings.height - back.height) / 2 - 50;
				bodyContainer.addChild(back);
			
			var ribbon:Bitmap = backingShort(settings.width + 100, 'questRibbon');
				ribbon.x = (settings.width - ribbon.width) / 2;
				ribbon.y = 245;
				bodyContainer.addChild(ribbon);
			
			//Tylko za...
			var textCont:Sprite = new Sprite();
			var ribbonText:TextField = drawText(Locale.__e("flash:1408441188465"), {
				fontSize	:34,
				autoSize	:"left",
				textAlign	:"center",
				color		:0xffffff,
				borderColor	:0x8140a7
			}); 
				textCont.addChild(ribbonText);
				textCont.filters = [new GlowFilter(0xab71cd, 1, 4, 4, 2, 1)];
				textCont.x = ribbon.x + (ribbon.width - textCont.width) / 2;
				textCont.y = ribbon.y + (ribbon.height - textCont.height) / 2 - 18;
				bodyContainer.addChild(textCont);
			
			//Daje elementy...
			var title:TextField = drawText(App.data.storage[sID].title, {
				fontSize	:32,
				autoSize	:"left",
				textAlign	:"center",
				color		:0xffffff,
				borderColor	:0x855729
			}); 
				title.x = back.x + (back.width - title.width) / 2;
				title.y = back.y + 20;
				bodyContainer.addChild(title);
			
			//Daje nectar...
			var description:TextField = drawText(App.data.storage[sID].description, {
				fontSize	:26,
				autoSize	:"center",
				textAlign	:"center",
				color		:0x624512,
				width		:260,
				wrap		:true,
				multiline	:true,
				borderSize	:0
			}); 
				description.x = back.x + (back.width - description.width) / 2;
				description.y = back.y + (back.height - description.height) / 2 + 15;
				bodyContainer.addChild(description);
			
			var bttnSettings:Object = {
				fontSize:36,
				width:186,
				height:52,
				hasDotes:false,
				caption:formatPrice(),
				x:(settings.width - 186) / 2,
				y:settings.height - 52/ 2 - 15,
				callback:buyEvent,
				addBtnContainer:false,
				addLogo:false
			};
			drawButton(bttnSettings);
		}
		
		private function formatPrice():String
		{
			var text:String = '';
			
			switch(App.self.flashVars.social) {
				
				case "VK":
				case "DM":
						text = 'flash:1382952379972';
					break;
				case "OK":
						text = '%d ОК';
					break;	
				case "ML":
						text = '[%d мэйлик|%d мэйлика|%d мэйликов]';
					break;
				case "NK":
					text = '%d €GB'; 
				break;	
				case "PL":
				case "YB":
						text = '%d';	
					break;
				case "FB":
						var price:Number = action.price[App.self.flashVars.social];
						price = price * App.network.currency.usd_exchange_inverse;
						price = int(price * 100 * (actionCounter)) / 100;
						text = price + ' ' + App.network.currency.user_currency;	
					break;
			}
			
			return Locale.__e(text, [int(action.price[App.self.flashVars.social]) * actionCounter]);
		}
		
		private function drawIcon():void 
		{
			drawMirrowObjs('diamondsTop', settings.width / 2 - settings.titleWidth / 2 - 5, settings.width / 2 + settings.titleWidth / 2 + 5, -40, true, true);
			drawMirrowObjs('storageWoodenDec', 0, settings.width, 45, false, false, false, 1, -1);
			
			var iconBack:Bitmap = new Bitmap(Window.textures.productionReadyBacking2);
			
			var icon:Bitmap;
			switch (int(sID)) 
			{
				case 139:
					icon = new Bitmap(Window.textures.warehouse);
					icon.x = -40;
					icon.y = (settings.height - icon.height) / 2 - 90;
					iconBack.x = icon.x + (icon.width - iconBack.width) / 2;
					iconBack.y = icon.y + (icon.height - iconBack.height) / 2;
				break;
				case 365:
					icon = new Bitmap(Window.textures.nectarsource);
					icon.x = -40;
					icon.y = (settings.height - icon.height) / 2 - 120;
					iconBack.x = icon.x + (icon.width - iconBack.width) / 2 - 30;
					iconBack.y = icon.y + (icon.height - iconBack.height) / 2 + 20;
				break;
			}
			if(iconBack)
				bodyContainer.addChild(iconBack);
			if (icon)
				bodyContainer.addChild(icon);
		}
		
	}

}