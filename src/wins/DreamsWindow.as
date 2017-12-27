package wins 
{
	
	public class DreamsWindow  extends Window
	{
		
		public var items:Array = [];
		
		public function DreamsWindow(settings:Object = null) 
		{
			if (settings == null) {
				settings = new Object();
			}		
			settings['width'] = 700;
			settings['height'] = 650;
			
			settings['title'] = Locale.__e("flash:1382952380046");
			
			settings['hasPaginator'] = true;
			settings['itemsOnPage'] = 6;
			
			settings.content = [];
			for (var sID:* in App.data.storage) {
				var item:Object = App.data.storage[sID];
				if (item.type == "Dreams") {
					settings.content.push(sID);
				}
			}
			
			super(settings);
			
		}
		
		override public function drawBody():void {
			//createItems();
			contentChange();
		}
		
		override public function contentChange():void {
			for each(var _item:* in items) {
				bodyContainer.removeChild(_item);
				_item.dispose();
			}
			items = [];
			var X:int = 75;
			var Xs:int = 75;
			var Ys:int = 95;
			
			var itemNum:int = 0;
			for (var i:int = paginator.startCount; i < paginator.finishCount; i++){
				
				var item:DreamItem = new DreamItem(settings.content[i], this);
				
				bodyContainer.addChild(item);
				item.x = Xs;
				item.y = Ys;
								
				items.push(item);
				
				Xs += item.background.width+10;
				if (itemNum == int(settings.itemsOnPage / 2) - 1)	{
					Xs = X;
					Ys += item.background.height + 10;
				}
				itemNum++;
			}
			
			settings.page = paginator.page;
		}
		
	}

}


import buttons.Button;
import core.Load;
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.text.TextField;
import ui.SystemPanel;
import units.Lantern;
import wins.DreamsWindow;
import wins.Window;
import wins.WindowEvent;
import wins.VisitWindow;
internal class DreamItem extends Sprite
{
	public var sID:int;
	public var window:DreamsWindow;
	public var item:Object;
	public var goBttn:Button;
	public var closeBttn:Button;
	public var background:Bitmap;
	public var bitmap:Bitmap;
	public var title:TextField;
	private var preloader:Preloader = new Preloader();
	private var sprite:LayerX;
	public function DreamItem(sID:int, window:*) {
		this.sID = sID;
		item = App.data.storage[sID];
		
		this.window = window;
		
		background = Window.backing(150, 180, 10, "itemBacking");
		addChild(background);
		
		sprite = new LayerX();
		addChild(sprite);
		
		bitmap = new Bitmap();
		sprite.addChild(bitmap);
		
		sprite.tip = function():Object { 
			return {
				title:item.title,
				text:item.description
			};
		};
		
		drawTitle();
		
		addChild(preloader);
		preloader.x = (background.width)/ 2;
		preloader.y = (background.height)/ 2 - 15;
		
		Load.loading(Config.getIcon(item.type, item.preview), onPreviewComplete);
	}
	
	private function onPreviewComplete(data:*):void
	{
		removeChild(preloader);
		
		bitmap.bitmapData = data.bitmapData;
		bitmap.scaleX = bitmap.scaleY = 0.8;
		bitmap.smoothing = true;
		bitmap.x = (background.width - bitmap.width)/ 2;
		bitmap.y = (background.height - bitmap.height)/ 2 - 15;
	}
	
	public function drawTitle():void {
		title = Window.drawText(String(item.title), {
			color:0x6d4b15,
			borderColor:0xfcf6e4,
			textAlign:"center",
			autoSize:"center",
			fontSize:20,
			textLeading:-6,
			multiline:true
		});
		title.wordWrap = true;
		title.width = background.width - 50;
		title.y = 10;
		title.x = 25;
		addChild(title);
		
		drawDesc();
	}
	
	
	private function drawDesc():void {
		var text:String = "";
		var textSettings:Object = { };
		if (App.user.worlds[sID] != undefined) {
			drawGoBttn();
		}else {
			text = Locale.__e("flash:1382952380047");
			textSettings = {
				fontSize:20,
				multiline:true,
				textAlign:"center"
			}
		}
		
		var descLabel:TextField = Window.drawText(text, textSettings);
		descLabel.wordWrap = true;
		descLabel.width = background.width - 20;
		descLabel.height = descLabel.textHeight + 10;
		addChild(descLabel);
		descLabel.x = background.x + 10;
		descLabel.y = background.height - 60;
	}
	
	
	public function drawGoBttn():void {
		
		var icon:Bitmap;
		
		var settings:Object = { fontSize:16, autoSize:"left" };
		var bttnSettings:Object = {
			caption:Locale.__e("flash:1382952380048"),
			fontSize:22,
			width:94,
			height:30
		};
		
		goBttn = new Button(bttnSettings);
		addChild(goBttn);
		goBttn.x = background.width/2 - goBttn.width/2;
		goBttn.y = background.height - 54;
		
		goBttn.addEventListener(MouseEvent.CLICK, onDreamEvent);
	}
	
	
	private var visitWindow:VisitWindow;
	private function onDreamEvent(e:MouseEvent):void {
		window.close();
		
		App.user.onStopEvent();
		
		visitWindow = new VisitWindow({title:Locale.__e('flash:1382952380050',[item.title])});
		visitWindow.addEventListener(WindowEvent.ON_AFTER_OPEN, onLoadUser);
		visitWindow.show();	
	}
	
	private function onLoadUser(e:WindowEvent):void {
		visitWindow.removeEventListener(WindowEvent.ON_AFTER_OPEN, onLoadUser);
		
		App.self.addEventListener(AppEvent.ON_USER_COMPLETE, onUserComplete);
		App.user.world.dispose();
		App.user.dreamEvent(sID);
	}
	
	private function onUserComplete(e:AppEvent):void {
		App.self.removeEventListener(AppEvent.ON_USER_COMPLETE, onUserComplete);
		
		App.map.dispose();
		App.map = null;
		App.self.addEventListener(AppEvent.ON_MAP_COMPLETE, onMapComplete);
		
		App.user.mode = User.OWNER;
		App.map = new Map(App.user.worldID, App.user.units, false);
		App.map.load();
	}
	
	private function onMapComplete(e:AppEvent):void {
		App.self.removeEventListener(AppEvent.ON_MAP_COMPLETE, onMapComplete);
		//Вызываем событие окончания flash:1382952379984грузки игры, можно раставлять теперь объекты на карте
		dispatchEvent(new AppEvent(AppEvent.ON_GAME_COMPLETE));
		
		if(visitWindow != null){
			visitWindow.close();
			visitWindow = null;
		}
		
		App.user.addPersonag();
		App.map.scaleX = App.map.scaleY = SystemPanel.scaleValue;
		App.map.center();
		
		Lantern.init();
	}
}