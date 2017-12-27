package wins 
{
	import buttons.MenuButton;
	import com.greensock.easing.Elastic;
	import com.greensock.TweenLite;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.geom.ColorTransform;
	import flash.text.TextField;
	import flash.utils.setTimeout;
	import ui.Cursor;
	import ui.UserInterface;
	import wins.elements.BankMenu;
	import wins.elements.BankItem;
	/**
	 * ...
	 * @author 
	 */
	public class BankSaleWindow extends Window
	{
		
		public static const COINS:String = 'Coins';
		public static const REALS:String = 'Reals';
		public static const SETS:String = 'Sets';
		
		public static var shop:Object;
		public static var history:Object = {section:'Reals',page:0};
		
		public var sections:Array = new Array();
		public var news:Object = {items:[],page:0};
		public var icons:Array = new Array();
		public var items:Array = [];
		
		private static var _currentBuyObject:Object = { type:null, sid:null };
		
		public function BankSaleWindow(settings:Object = null)
		{		
			_currentBuyObject.type = null;
			_currentBuyObject.sid = null;
			
			if (settings == null) {
				settings = new Object();
			}
			settings["section"] = settings.section || history.section; 
			settings["page"] = settings.page || history.page;
			settings["popup"] = true;
			
			settings["find"] = settings.find || null;
			
			settings["title"] = Locale.__e("flash:1382952380262");
			
			settings["width"] = 660;
			settings["height"] = 400;
			
			settings["hasPaginator"] = true;
			settings["hasArrows"] = true;
			settings["itemsOnPage"] = 3;
			settings["returnCursor"] = false;
			settings['hasButtons'] = false;
			
			history.section		= settings.section;
			//history.page		= settings.page;
			
			//findTargetPage(settings);
			
			super(settings);
		}
		
		/*private function findTargetPage(settings:Object):void {
			for (var section:* in shop){
				for (var i:* in shop[section].data) {
					
					var sid:int = shop[section].data[i].sid;
					if (settings.find != null && settings.find.indexOf(sid) != -1) {
						
						history.section = section;
						history.page = int(int(i) / settings.itemsOnPage);
						
						settings.section = history.section;
						settings.page = history.page;
						return;
					}
				}
			}
		}*/
		
		private function checkUpdate(updateID:String):Boolean {
			
			var update:Object = App.data.updates[updateID];
			if (!update.hasOwnProperty('social') || !update.social.hasOwnProperty(App.social)) {
				
				for (var sID:* in App.data.updates[updateID].items) {
					if ((update.ext != null && update.ext.hasOwnProperty(App.social)) && (update.stay != null && update.stay[sID] != null))
					{
						
					}
					else
					{
						App.data.storage[sID].visible = 0;
					}
				}
				
				return false;
			}
			
			return true;
		}
		
		override public function dispose():void {
			
			for each(var item:* in items) {
				bodyContainer.removeChild(item);
				item.dispose();
				item = null;
			}
			
			for each(var icon:* in icons) {
				//bodyContainer.removeChild(icon);
				icon.dispose();
				icon = null;
			}
			
			super.dispose();
		}
		
		override public function drawBody():void {
			
			drawBacking();
			drawMenu();
			
			setContentSection(history.section,settings.page);
			contentChange();
			
			exit.y -= 15;
			titleLabel.y -= 4;
			
			drawMirrowObjs('diamondsTop', settings.width / 2 - settings.titleWidth / 2 - 5, settings.width / 2 + settings.titleWidth / 2 + 5, -40, true, true);
			drawMirrowObjs('diamonds', 6, settings.width - 6, settings.height - 110);
			drawMirrowObjs('diamonds', 4, settings.width -4, 39, false, false, false, 1, -1);
			
			checkAction();
		}
		
		private var actionCont:LayerX = new LayerX();
		private var actionTime:TextField;
		private var actionTitle:TextField;
		
		private var timeToActionEnd:int = 0;
		private function checkAction():void 
		{
			if ((App.data.money && App.time >= App.data.money.date_from && App.time < App.data.money.date_to && App.data.money.enabled == 1) || App.user.money > App.time) {
				
				if(App.data.money && App.time >= App.data.money.date_from && App.time < App.data.money.date_to && App.data.money.enabled == 1)
					timeToActionEnd = App.data.money.date_to;
				else if (App.user.money > App.time)
					timeToActionEnd = App.user.money;
					
				var btmd:BitmapData = textures.iconEff;
				var invertTransform:ColorTransform = new ColorTransform();
				invertTransform.color = 0xffffff;
				btmd.colorTransform(btmd.rect, invertTransform);
				var glowBg:Bitmap = new Bitmap(btmd);
				glowBg.scaleX = glowBg.scaleY = 1.5;
				glowBg.smoothing = true;
				actionCont.addChild(glowBg);
			
				actionTitle = drawText(Locale.__e("flash:1382952379793"), {
					color:0xffffff,
					borderColor:0x7a4003,
					textAlign:"center",
					autoSize:"center",
					fontSize:32
				});
				actionTitle.y = 50;
				actionTitle.width = actionTitle.textWidth + 10;
				actionCont.addChild(actionTitle);
				
				actionTime = drawText(TimeConverter.timeToStr(timeToActionEnd - App.time), {
					color:0xffd950,
					borderColor:0x402016,
					textAlign:"center",
					autoSize:"center",
					fontSize:40
				});
				actionTime.y = actionTitle.y + actionTitle.textHeight - 4;
				actionTime.x = (glowBg.width - actionTime.width) / 2;
				actionTime.width = actionTime.textWidth + 10;
				actionCont.addChild(actionTime);
				
				actionTitle.x = actionTime.x + (actionTime.width - actionTitle.textWidth) / 2;
				
				App.self.setOnTimer(updateTimeAction);
				
				bodyContainer.addChild(actionCont);
				actionCont.rotation = -25;
				actionCont.x = -60;
				actionCont.y = -40;
			}
		}
		
		private function updateTimeAction():void
		{
			var timeAction:int = timeToActionEnd - App.time;
			if (timeAction < 0) {
				timeAction = 0;
				App.self.setOffTimer(updateTimeAction);
				actionCont.visible = false;
				contentChange();
				return;
			}
			actionTime.text = TimeConverter.timeToStr(timeAction);
		}
		
		private var menu:BankMenu;
		public function drawMenu():void 
		{
			menu = new BankMenu(this);
			bodyContainer.addChild(menu);
		}
		
		
		public function setContentSection(section:*, page:Number = -1):Boolean
		{
			for each(var icon:MenuButton in icons) {
				icon.selected = false;
				if (icon.type == section) {
					icon.selected = true;
				}
			}
			
			settings.content.splice(0, settings.content.length);
			
			for (var sID:* in App.data.storage) {
				var object:Object = App.data.storage[sID];
				object['sid'] = sID;
				
				if (object.type == section && object.extra && object.extra > 0)// && ((App.time >= App.data.money.date_from && App.time < App.data.money.date_to && App.data.money.enabled == 1) || App.data.money.level == App.user.level))
				{
					settings.content.push(object); 
				}
			}
			history.section = section;
			history.page = 0;// page;
			paginator.page = 0;
			
			paginator.itemsCount = settings.content.length;
			paginator.update();
			
			paginator.update();
			contentChange();
			return true;
		}
		
		public function setContentNews(data:Array):Boolean
		{
			for each(var icon:MenuButton in icons) {
				icon.selected = false;
			}
			
			settings.content = data
			paginator.page = 0;
			
			settings.section = 101;
			paginator.onPageCount = settings.itemsOnPage;
			paginator.itemsCount = settings.content.length;
			paginator.update();
				
			contentChange();
			return true;
		}
		
		public function drawBacking():void {
			var backing:Bitmap = Window.backing(settings.width-54, 282, 25, 'shopBackingSmall');
			bodyContainer.addChild(backing);
			backing.x = settings.width/2 - backing.width/2;
			backing.y = 52;
		}
		
		override public function contentChange():void {
			for each(var _item:* in items) {
				bodyContainer.removeChild(_item);
				_item.dispose();
			}
			
			for (var i:int = 0; i < arrLabels.length; i++ ) {
				bodyContainer.removeChild(arrLabels[i]);
				arrLabels[i] = null;
			}
			arrLabels.splice(0, arrLabels.length);
			arrLabels = [];
			
			for (i = 0; i < arrHoles.length; i++ ) {
				bodyContainer.removeChild(arrHoles[i]);
				arrHoles[i] = null;
			}
			arrHoles.splice(0, arrHoles.length);
			arrHoles = [];
			
			
			items = [];
			var X:int = 43;
			var Xs:int = X;
			var Ys:int = 68;
			
			//if (settings.section != 101 && settings.section != 100 && settings.section != 3) 
			settings.content.sortOn('order', Array.NUMERIC);
			
			var itemNum:int = 0;
			for (i = paginator.startCount; i < paginator.finishCount; i++){
			
				var item:*
					item = new BankItem(settings.content[i], this, { height:240, width:190, sale:true } );
				
				bodyContainer.addChild(item);
				item.x = Xs;
				item.y = Ys;
				
				items.push(item);
				
				Xs += item.background.width + 2;
				//if (itemNum == int(settings.itemsOnPage / 2) - 1)	{
					//Xs = X;
					//Ys += item.background.height + 12;
				//}
				itemNum++;
				
				setItemLabel(item);
			}
			
			
			if (settings.section == 101)
				return;
			
			
			//settings.page = paginator.page;
		}
		
		private var arrLabels:Array = [];
		private var arrHoles:Array = [];
		private function setItemLabel(item:BankItem):void 
		{
			//if (item.isLabel1) {
				//makeLabel(item, UserInterface.textures.labelBD1);
			//}
			//if (item.isLabel2) {
				//makeLabel(item, UserInterface.textures.labelUC1);
			//}
			
			
			if (item.isLabel1) {
				if (App.lang != 'ru') {
					makeLabel(item, UserInterface.textures.labelBDEng);
				}else {
					makeLabel(item, UserInterface.textures.labelBD1);
				}
			}
			if (item.isLabel2) {
				if (App.lang != 'ru') {
					makeLabel(item, UserInterface.textures.labelUCEng);
				}else {
					makeLabel(item, UserInterface.textures.labelUC1);
				}
			}
			
			addLabels();
		}
		
		private function addLabels():void 
		{
			for (var i:int = 0; i < arrLabels.length; i++ ) {
				var label:Sprite = arrLabels[i];
				bodyContainer.addChild(label);
			}
		}
		
		private function makeLabel(item:BankItem, btmd:BitmapData):void
		{
			var cont:Sprite = new Sprite();
			var hole:Bitmap = new Bitmap(UserInterface.textures.hole);
			hole.x = item.x + item.width - 30;
			hole.y = item.y + 13;
			bodyContainer.addChild(hole);
			arrHoles.push(hole);
			
			var label:Bitmap = new Bitmap(btmd);
			label.smoothing = true;
			//label.rotation = -50;
			cont.addChild(label);
			
			cont.rotation = -50;
			cont.x = item.x + item.width - 48 + 4;
			cont.y = item.y + 32 + 8;
			
			setTimeout(function():void {
				TweenLite.to(cont, 2, {x:cont.x - 6, y:cont.y - 8, rotation: -30, ease:Elastic.easeOut } );
			}, 200);
			
			arrLabels.push(cont);
		}
		
		override public function drawArrows():void {
			
			paginator.drawArrow(bodyContainer, Paginator.LEFT,  0, 0, { scaleX: -1, scaleY:1 } );
			paginator.drawArrow(bodyContainer, Paginator.RIGHT, 0, 0, { scaleX:1, scaleY:1 } );
			
			var y:Number = (settings.height - paginator.arrowLeft.height) / 2 - 10;
			paginator.arrowLeft.x = -44;
			paginator.arrowLeft.y = y + 45;
			
			paginator.arrowRight.x = settings.width - paginator.arrowLeft.width + 44;
			paginator.arrowRight.y = y + 45;
			
			paginator.y = settings.height - 44;
		}
		
		static public function set currentBuyObject(value:Object):void
		{
			_currentBuyObject = value;
		}
		
		static public function get currentBuyObject():Object
		{
			return _currentBuyObject;
		}
		
	}
}