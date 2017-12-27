package wins 
{
	import buttons.Button;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import units.Sphere;

	public class SelectAnimalWindow extends Window
	{
		public var items:Array = new Array();
		public var handler:Function; 
		
		
		public function SelectAnimalWindow(settings:Object = null) 
		{
			var defaults:Object = {
				width: 716,
				height:610,
				hasPaper:true,
				title:Locale.__e("flash:1382952380267"),
				titleScaleX:0.76,
				titleScaleY:0.76,
				hasPaginator:true,
				hasArrows:true,
				hasButtons:true,
				itemsOnPage:8,
				description:Locale.__e("flash:1382952380274")
			};
			
			if (settings == null) {
				settings = new Object();
			}
			
			for (var property:* in settings) {
				defaults[property] = settings[property];
			}
			settings = defaults;
			
			handler = settings.callback;
			
			settings['content'] = createContent(settings.sphere);
			
			super(settings);
		}
		
		public function createContent(sphere:Sphere):Array{
			var list:Array = new Array();
				
			for (var sID:* in App.data.storage) {
				var object:Object = App.data.storage[sID];
				object['sID'] = sID;
				if (object.visible == 0) continue;
				if (object.type == 'Animal')
				{
					list.push(object);
				}
			}
			list.sortOn("order", Array.NUMERIC);
			list.sortOn(["base", "order"], Array.NUMERIC);
			if(sphere.base == 1) 
				list.reverse();
				
			return list;
		}
		
		override public function dispose():void {
			for (var i:int = 0; i < items.length; i++)
			{
				if (items[i] != null)
				{
				items[i].dispose();
				items[i] = null;
				}
			}
			super.dispose();
		}
		
		public function drawDescription():void {
			var descriptionLabel:TextField = drawText(settings.description, {
				fontSize:24,
				autoSize:"left",
				textAlign:"center",
				multiline:true,
				color:0x5a524c,
				borderColor:0xfaf1df
			});
			descriptionLabel.x = (settings.width - descriptionLabel.width) / 2;
			descriptionLabel.y = 30;
						
			descriptionLabel.width = settings.width - 80;
			
			bodyContainer.addChild(descriptionLabel);
		}
		
		override public function drawBody():void {
			drawDescription();
			
			createItems();
			contentChange();
		}
		
		override public function drawArrows():void {
			super.drawArrows();
			paginator.arrowLeft.y -= 36;
			paginator.arrowRight.y -= 36;
		}
		
		override public function contentChange():void {
			for (var i:int = 0; i < items.length; i++)
			{
				items[i].visible = false;
			}
			var itemNum:int = 0
			var dy:uint = 64;
			if(items.length){
				for (i = paginator.startCount; i < paginator.finishCount; i++)
				{
					items[i].y = dy;
					items[i].x = 52 + itemNum * items[i].width + 8*itemNum;
					itemNum++;
					items[i].visible = true;
					
					if (itemNum == 4) {
						itemNum = 0;
						dy += items[i].height + 10;
					}
				}
			}
		}
		
		public function createItems():void {
			
			for (var i:int = 0; i < settings.content.length; i++) {
				var sid:uint = settings.content[i].sID;
				var item:PurchaseItem = new PurchaseItem(sid, handler, this);
				item.visible = false;
				bodyContainer.addChild(item);
				items.push(item);
				
				
				if (App.data.storage[sid].base != settings.sphere.base) {
					//item.selectBttn.state = Button.DISABLED;
					item.selectBttn.visible = false;
					item.alpha = 0.6;
				}
			}
		}
		
	}

}

import buttons.Button;
import buttons.MoneyButton;
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.text.TextField;
import ui.UserInterface;
import wins.Window;
import core.Load;
import com.greensock.*;
import LayerX;
	
internal class PurchaseItem extends Sprite
{ 
	
	public var callback:Function;
	public var background:Bitmap;
	public var title:TextField;
	public var sID:int;
	public var bitmap:Bitmap;
	public var layer:LayerX;
	public var selectBttn:Button;
	public var window:*;
	
	private var object:Object;
	private var preloader:Preloader = new Preloader();
	
	public function PurchaseItem(sID:int, callback:Function, window:*)
	{
		
		this.sID = sID;
		this.callback = callback;
		this.window = window;
		
		background = Window.backing(147, 191, 10, "itemBacking");
		addChild(background)
		
		layer = new LayerX();
		addChild(layer);
		
		bitmap = new Bitmap(null,"auto", true);
		layer.addChild(bitmap);
		
		addChild(preloader);
		preloader.x = (background.width)/ 2;
		preloader.y = (background.height)/ 2 - 15;
		
		layer.tip = function():Object
		{
			return {
				title:App.data.storage[sID].title,
				text:App.data.storage[sID].description
			};
		}
		
		object = App.data.storage[sID];
		Load.loading(Config.getIcon(object.type, object.view), onLoad);
		
		title = Window.drawText(object.title, {
			multiline:true,
			autoSize:"left",
			textAlign:"center",
			fontSize:22,
			color:0x6d4b15,
			borderColor:0xfcf6e4
		});
		title.y = 13;
		title.wordWrap = true;
		title.height = 32;
		title.width = background.width - 40;
		
		title.x = (background.width - title.width) / 2;
		addChild(title);
		
		var sprite:Sprite = new Sprite();
		
		
		var label:TextField = Window.drawText(Locale.__e("flash:1383042563368"), {
			color:0x4A401F,
			borderSize:0,
			fontSize:18,
			autoSize:"left"
		});
		sprite.addChild(label);
		
		var icon:Bitmap = new Bitmap(UserInterface.textures.energyIcon, "auto", true);
		icon.scaleX = icon.scaleY = 0.7;
		icon.x = label.width;
		icon.y = -8;

		sprite.addChild(icon);
				
		var count:TextField = Window.drawText(String(App.data.storage[sID].energy), {
			fontSize:20, 
			autoSize:"left",
			color:0x38342c,
			borderColor:0xf0e9db
		});
		
		sprite.addChild(count);
		count.x = icon.x + icon.width;
		count.y = 0;
		
		addChild(sprite);
		sprite.x = (background.width - sprite.width) / 2;
		sprite.y = 132;
		
		drawSelectBttn();
		
		
		if (Quests.help) {
			var qID:int = App.user.quests.currentQID;
			var mID:int = App.user.quests.currentMID;
			var targets:Object = App.data.quests[qID].missions[mID].target;
			for each(var sid:* in targets){
				if(this.sID == sid){
					stopGlowing = false;
					glowing();
				}
			}
		}
	}
	
	
	
	private function drawSelectBttn():void
	{
		selectBttn = new Button( {
			width:125,
			height:40,
			fontSize:24,
			caption:Locale.__e("flash:1382952379978")
		});
		selectBttn.name = "SelectAnimalBttn";
		addChild(selectBttn);
		selectBttn.x = (this.width - selectBttn.width)/2;
		selectBttn.y = 160;
				
		selectBttn.addEventListener(MouseEvent.CLICK, onSelectClick)
	}
	
	
	
	public function dispose():void {

		if(selectBttn != null){
			selectBttn.removeEventListener(MouseEvent.CLICK, onSelectClick)
		}
		if (this.parent != null) {
			this.parent.removeChild(this);
		}
	}
	
	public function onSelectClick(e:MouseEvent):void
	{
		if(callback != null) callback(this.sID);
		window.close();
	}
	
	
	public function onLoad(data:*):void
	{
		removeChild(preloader);
		bitmap.bitmapData = data.bitmapData;
		bitmap.x = (background.width - bitmap.width) / 2;
		bitmap.y = (background.height - bitmap.height) / 2 - 20;
	}
	
	private function glowing():void {
		customGlowing(background, glowing);
		if (selectBttn) {
			customGlowing(selectBttn);
		}
	}
	
	private var stopGlowing:Boolean = false;
	private function customGlowing(target:*, callback:Function = null):void {
		TweenMax.to(target, 1, { glowFilter: { color:0xFFFF00, alpha:0.8, strength: 7, blurX:12, blurY:12 }, onComplete:function():void {
			if (stopGlowing) {
				target.filters = null;
				return;
			}
			TweenMax.to(target, 0.8, { glowFilter: { color:0xFFFF00, alpha:0.6, strength: 7, blurX:6, blurY:6 }, onComplete:function():void {
				if (!stopGlowing && callback != null) {
					callback();
				}
				if (stopGlowing) {
					target.filters = null;
				}
			}});	
		}});
	}	
}

