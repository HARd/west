package wins.elements 
{
	import buttons.Button;
	import core.Load;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.utils.setTimeout;
	import units.Missionhouse;
	import wins.InstanceWindow;
	import wins.Window;
	/**
	 * ...
	 * @author 
	 */
	public class TresureInfoWindow extends Window
	{
		public static const MODE_PERS:int = 1;
		public static const MODE_TRESURE:int = 2;
		
		public static var persSid:int;
		public static var isOpen:Boolean;
	
		private var roomId:int;
		private var instanceId:int;
		
		public var bitmap:Bitmap = new Bitmap();
		
		private var preloader:Preloader = new Preloader();
		
		private var isFocus:Boolean = false;
		
		private var tresure:TresureIcon;
		
		public function TresureInfoWindow(settings:Object = null) 
		{
			if (settings == null) {
				settings = new Object();
			}
			App.data.storage
			settings['width'] = 214;
			settings['height'] = 170;
			settings['background'] = 'questRewardBackingMini';
			settings['hasPaginator'] = false;
			settings['autoClose']= true;
			
			settings['hasFader'] = false;
			//settings['faderClickable'] = false;
			settings['popup'] = true;
			//settings['faderAlpha'] = 0;
			settings['hasExit'] = false;
			
			persSid = settings.sid;
			isOpen = true;
			
			tresure = settings.pers;
			
			/*for (var ind:* in App.user.rooms ) {
				for (var pers:* in App.user.rooms[ind].pers) {
					if (settings.sid == App.user.rooms[ind].pers[pers]) {
						roomId = ind;
						break;
					}
				}
			}*/
			
			instanceId = persSid;
			roomId = settings.roomSid;
			App.user.rooms
			//for (var ind:* in App.data.storage) {
				//if (App.data.storage[ind].type == 'Missionhouse') {
					//for (var rm:* in App.data.storage[ind].rooms) {
						//if (roomId == App.data.storage[ind].rooms[rm]) {
							//instanceId = ind;
						//}
					//}
				//}
			//}
			
			super(settings);
			
			
			Load.loading(Config.getIcon(App.data.storage[instanceId].type, App.data.storage[instanceId].preview), onPreviewComplete);
			
			App.self.addEventListener(AppEvent.ON_CLOSE_INFO_TRES, doClose);
			
			//mouseChildren = false;
			//backgroundContainer.mouseChildren = false;
			bodyContainer.mouseChildren = false;
			bodyContainer.mouseEnabled = false;
			this.addEventListener(MouseEvent.MOUSE_OVER, onOver);
			this.addEventListener(MouseEvent.MOUSE_OUT, onOut);
		}
		
		override public function drawBackground():void 
		{
			var background:Bitmap = backing(settings.width, settings.height, 20, settings.background);
			background.alpha = 0.8;
			layer.addChildAt(background, 0);
		}
		
		private function onOut(e:MouseEvent):void 
		{
			setTimeout(function():void {
				if (tresure && tresure.isFocused)
				return;
			close();
			}, 200);
			
			tresure.isFocused = false;
		}
		
		private function onOver(e:MouseEvent):void 
		{
			tresure.isFocused = true;
		}
		
		private function onPreviewComplete(data:Bitmap):void 
		{
			if(bodyContainer.contains(preloader))bodyContainer.removeChild(preloader);
			preloader = null;
			
			bitmap.bitmapData = data.bitmapData;
			bitmap.smoothing = true;
			bitmap.scaleX = bitmap.scaleY = 0.6;
			//bitmap.x = 36 - bitmap.width/2;
			bitmap.x = 65;
			bitmap.y = settings.height - bitmap.height - 46;
		}
		
		override public function drawBody():void 
		{
			//this.x += settings.x - App.self.stage.stageWidth/2 //+ settings.width/2;
			//this.y += settings.y - App.self.stage.stageHeight / 2 + settings.height/2;
			
			this.x += tresure.x + tresure.parent.x - App.self.stage.stageWidth / 2 ;
			this.y += tresure.y + tresure.parent.y - App.self.stage.stageHeight / 2 - settings.height/2;
			
			
			if(preloader){
				bodyContainer.addChild(preloader);
				preloader.x = 50;
				preloader.y = 60;
			}
			
			bodyContainer.addChild(bitmap);
			
			drawDesc();
			
			drawBttn();
			
		}
		
		private var descCont:Sprite = new Sprite;
		private var timeTxt:TextField;
		private var leftTxt:TextField;
		private var nameInstance:TextField;
		
		private function drawDesc():void 
		{
			var txtTitle:String;
			txtTitle = Locale.__e("flash:1394454775828");
			
			var title:TextField = Window.drawText(txtTitle, {
				fontSize:18,
				color:0xFFFFFF,
				autoSize:"left",
				borderColor:0x523209
			});
			descCont.addChild(title);
			
			nameInstance = Window.drawText(App.data.storage[roomId].title, { // поставить сюда название инстанса
				fontSize:24,
				color:0xfee65f,
				autoSize:"left",
				borderColor:0x523209
			});
			descCont.addChild(nameInstance);
			title.y = -20;
			nameInstance.x = (title.textWidth - nameInstance.textWidth) / 2;
			nameInstance.y = title.y + title.textHeight;
			
			if (nameInstance.textWidth > title.textWidth) {
				title.x = (nameInstance.textWidth - title.textWidth) / 2 - 10;
				nameInstance.x = 0;
			}
			
			bodyContainer.addChild(descCont);
			descCont.x = settings.width - descCont.width - 20;
			descCont.y = 30;
			
		}
		
		private var travelBttn:Button;
		private function drawBttn():void 
		{
			var txt:String;
			var txtWidth:int
		
			txtWidth = 150;
			txt = Locale.__e("flash:1393579618588");
			
			travelBttn = new Button( {
				caption:txt,
				fontSize:24,
				width:txtWidth,
				height:36,
				hasDotes:false
			});
			
			//bodyContainer.addChild(travelBttn);
			layer.addChild(travelBttn);
			travelBttn.x = (settings.width - travelBttn.width) / 2;
			travelBttn.y = settings.height - travelBttn.height - 6;
			
			travelBttn.addEventListener(MouseEvent.CLICK, onTravel);
			travelBttn.addEventListener(MouseEvent.MOUSE_OVER, onOver);
			travelBttn.addEventListener(MouseEvent.MOUSE_OUT, onOut);
		}
		
		private function onTravel(e:MouseEvent):void 
		{
			
			var arrInstance:Array = Map.findUnits([instanceId]);
				
			if (arrInstance.length > 0) {
				var instance:Missionhouse = arrInstance[0];
				App.map.focusedOn( { x:instance.x + 20, y:instance.y + 50 }, false);
				
			}else {
				Travel.goTo(App.data.storage[instanceId].land);
			}
			
			close();
			
		}
		
		override public function drawTitle():void 
		{
				
		}
		
		private function doClose(e:AppEvent):void 
		{
			if(!isFocus)
				close();
		}
		
		override public function dispose():void
		{
			persSid = 0;
			tresure = null;
			isOpen = false;
			
			App.self.removeEventListener(AppEvent.ON_CLOSE_INFO_TRES, doClose);
			removeEventListener(MouseEvent.MOUSE_OVER, onOver);
			removeEventListener(MouseEvent.MOUSE_OUT, onOut);
			
			if(travelBttn){
				travelBttn.removeEventListener(MouseEvent.CLICK, onTravel);
				travelBttn.removeEventListener(MouseEvent.MOUSE_OVER, onOver);
				travelBttn.removeEventListener(MouseEvent.MOUSE_OUT, onOut);
				travelBttn.dispose();
				travelBttn = null;
			}
			super.dispose();
		}
		
		
	}

}