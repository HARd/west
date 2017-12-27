package wins 
{
	import buttons.Button;
	import com.adobe.images.BitString;
	import core.Load;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.utils.setTimeout;
	import units.Missionhouse;
	import wins.elements.PersonageIcon;
	/**
	 * ...
	 * @author 
	 */
	public class PersonageInfoWindow extends Window
	{
		public static const MODE_PERS:int = 1;
		public static const MODE_TRESURE:int = 2;
		
		public static var persSid:int;
		public static var isOpen:Boolean;
		
		public var mode:int;
		
		public var bitmap:Bitmap = new Bitmap();
	
		private var roomId:int;
		private var instanceId:int;
		
		private var preloader:Preloader = new Preloader();
		private var isFocus:Boolean = false;
		private var pers:PersonageIcon;
		
		public function PersonageInfoWindow(mode:int, settings:Object = null) 
		{
			this.mode = mode;
			
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
			settings['popup'] = true;
			settings['hasExit'] = false;
			
			persSid = settings.sid;
			pers = settings.pers;
			isOpen = true;
			
			for (var ind:* in App.user.rooms ) {
				for (var pers:* in App.user.rooms[ind].pers) {
					if (settings.sid == App.user.rooms[ind].pers[pers]) {
						roomId = ind;
						break;
					}
				}
			}
			
			for (ind in App.data.storage) {
				if (App.data.storage[ind].type == 'Missionhouse') {
					for (var rm:* in App.data.storage[ind].rooms) {
						if (roomId == App.data.storage[ind].rooms[rm]) {
							instanceId = ind;
						}
					}
				}
			}
			
			super(settings);
			
			
			Load.loading(Config.getIcon(App.data.storage[instanceId].type, App.data.storage[instanceId].preview), onPreviewComplete);
			
			App.self.addEventListener(AppEvent.ON_CLOSE_INFO, doClose);
			
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
				if (pers && pers.isFocused)
				return;
			close();
			}, 200);
			
			pers.isFocused = false;
		}
		
		private function onOver(e:MouseEvent):void 
		{
			pers.isFocused = true;
		}
		
		private function onPreviewComplete(data:Bitmap):void 
		{
			if(bodyContainer.contains(preloader))bodyContainer.removeChild(preloader);
			preloader = null;
			
			bitmap.bitmapData = data.bitmapData;
			bitmap.smoothing = true;
			bitmap.scaleX = bitmap.scaleY = 0.6;
			bitmap.x = 10;
			bitmap.y = (settings.height - bitmap.height) / 2;
		}
		
		override public function drawBody():void 
		{
			this.x += settings.x - App.self.stage.stageWidth/2 //+ settings.width/2;
			this.y += settings.y - App.self.stage.stageHeight / 2 + settings.height/2;
			
			if(preloader){
				bodyContainer.addChild(preloader);
				preloader.x = 50;
				preloader.y = 60;
			}
			
			bodyContainer.addChild(bitmap);
			
			drawDesc();
			
			drawBttn();
			
			if(mode == MODE_PERS)App.self.setOnTimer(update);
		}
		
		private var descCont:Sprite = new Sprite;
		private var timeTxt:TextField;
		private var leftTxt:TextField;
		private var nameInstance:TextField;
		
		private function drawDesc():void 
		{
			var txtTitle:String;
			if (mode == MODE_PERS) {
				txtTitle = Locale.__e("flash:1394010266686");
			}else {
				txtTitle = Locale.__e("flash:1394454775828");
			}
			var title:TextField = Window.drawText(txtTitle, {
				fontSize:18,
				color:0xFFFFFF,
				autoSize:"left",
				borderColor:0x44240f
			});
			descCont.addChild(title);
			
			nameInstance = Window.drawText(App.data.storage[roomId].title, { 
				fontSize:24,
				color:0xffe760,
				autoSize:"left",
				borderColor:0x53330a
			});
			descCont.addChild(nameInstance);
			nameInstance.x = (title.textWidth - nameInstance.textWidth) / 2;
			nameInstance.y = title.y + title.textHeight;
			
			if (mode == MODE_PERS) {
				leftTxt = Window.drawText(Locale.__e("flash:1393581955601"), { 
					fontSize:18,
					color:0xFFFFFF,
					autoSize:"left",
					borderColor:0x592f16
				});
				descCont.addChild(leftTxt);
				leftTxt.x = (title.textWidth - leftTxt.textWidth) / 2;
				leftTxt.y = nameInstance.y + nameInstance.textHeight + 2;
				
				timeTxt = Window.drawText(TimeConverter.timeToStr(100), { 
					fontSize:26,
					color:0xFFFFFF,
					autoSize:"left",
					borderColor:0x592f16
				});
				descCont.addChild(timeTxt);
				timeTxt.x = (title.textWidth - timeTxt.textWidth) / 2;
				timeTxt.y = leftTxt.y + leftTxt.textHeight ;
			}
			
			bodyContainer.addChild(descCont);
			descCont.x = (settings.width - descCont.width) / 2 + 38;
			descCont.y = 6;
			
			if(mode == MODE_PERS)update();
		}
		
		private function addTresuareIcon():void
		{
			var icon:Bitmap = new Bitmap();
			Load.loading(Config.getImage('interface', 'box_open'), function(data:*):void { 
				
				if (leftTxt && leftTxt.parent) {
					leftTxt.parent.removeChild(leftTxt);
					leftTxt = null;
				
				}
				if (timeTxt && timeTxt.parent) {
					timeTxt.parent.removeChild(timeTxt);
				}
				
				icon.bitmapData = data.bitmapData;
				icon.smoothing = true;
				
				descCont.addChildAt(icon, 0);
				icon.x = (descCont.width - icon.width) / 2;
				icon.y = nameInstance.y + nameInstance.textHeight - 20;
			});
		}
		
		private var travelBttn:Button;
		private function drawBttn():void 
		{
			var txt:String;
			var txtWidth:int
			if (mode == MODE_PERS) {
				txtWidth = 130;
				txt = Locale.__e("flash:1394010224398");
			}
			else {
				txtWidth = 150;
				txt = Locale.__e("flash:1393579618588");
			}
			travelBttn = new Button( {
				caption:txt,
				fontSize:24,
				width:txtWidth,
				height:36,
				hasDotes:false
			});
			
			layer.addChild(travelBttn);
			travelBttn.x = (settings.width - travelBttn.width) / 2;
			travelBttn.y = settings.height - travelBttn.height - 6;
			
			travelBttn.addEventListener(MouseEvent.CLICK, onTravel);
			travelBttn.addEventListener(MouseEvent.MOUSE_OVER, onOver);
			travelBttn.addEventListener(MouseEvent.MOUSE_OUT, onOut);
		}
		
		private function onTravel(e:MouseEvent):void 
		{
			if(mode == MODE_PERS){
				var arrInstance:Array = Map.findUnits([instanceId]);
				
				if (arrInstance.length > 0) {
					var instance:Missionhouse = arrInstance[0];
					App.map.focusedOn({x:instance.x + 20, y:instance.y + 50}, false, function():void {
						if(!instance.hasProduct && !instance.hasPresent && instance.hasBuilded){
							new InstancePassingWindow( {
							roomInfo:instance.roomInfo,
							target:instance,
							friendsData:instance.friendsData,
							onClose:instance.onCloseWindow,
							crafting:instance.crafting
							}).show();							
							//new InstanceWindow( {
								//roomInfo:instance.roomInfo,
								//target:instance,
								//friendsData:instance.friendsData,
								//onClose:instance.onCloseWindow,
								//crafting:instance.crafting
							//}).show();
						}
					}, true, 1.1);
				}else {
					Travel.goTo(App.data.storage[instanceId].land);
				}
			}
			close();
		}
		
		override public function drawTitle():void 
		{
				
		}
		
		public function update():void
		{
			var time:int = settings.startTime + settings.endTime - App.time;
			if (time < 0) {
				time = 0;
				App.self.setOffTimer(update);
				addTresuareIcon();
			}
			timeTxt.text = TimeConverter.timeToStr(time);
		}
		
		private function doClose(e:AppEvent):void 
		{
			if(!isFocus)
				close();
		}
		
		override public function dispose():void
		{
			persSid = 0;
			pers = null;
			isOpen = false;
			
			App.self.removeEventListener(AppEvent.ON_CLOSE_INFO, doClose);
			removeEventListener(MouseEvent.MOUSE_OVER, onOver);
			removeEventListener(MouseEvent.MOUSE_OUT, onOut);
			
			if(travelBttn){
				travelBttn.removeEventListener(MouseEvent.CLICK, onTravel);
				travelBttn.removeEventListener(MouseEvent.MOUSE_OVER, onOver);
				travelBttn.removeEventListener(MouseEvent.MOUSE_OUT, onOut);
				travelBttn.dispose();
				travelBttn = null;
			}
			App.self.setOffTimer(update);
			super.dispose();
		}
		
	}

}