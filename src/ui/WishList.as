package ui 
{
	import core.Post;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import wins.Window;
	
	
	/**
	 * ...
	 * @author 
	 */
	public class WishList extends Sprite
	{
		
		public var lastSID:uint;
		public var count:uint = 4;
		private var items:Array = [];
		private var childs:Sprite = new Sprite();
		private var fader:Sprite = new Sprite();
		
		public function WishList()
		{
			
		}
		
		private function showFader():void { 
			fader = new Sprite();
					
			fader.graphics.beginFill(0x000000,0);
			fader.graphics.drawRect(0, 0, App.self.stage.stageWidth, App.self.stage.stageHeight);
			fader.graphics.endFill();

			addChildAt(fader, 0);
			fader.addEventListener(MouseEvent.CLICK, onHideEvent);
		}
		
		protected function onKeyDown(e:KeyboardEvent):void {
			if (Number(e.keyCode.toString()) == 27) {
				dispose();
			}
		}
		
		
		private function onHideEvent(e:MouseEvent):void {
			dispose();
		}
		
		public function close():void {
			dispose();
		}
		
		public function show(sID:int, e:MouseEvent):void
		{
			showFader();
			
			lastSID = sID;
			
			childs = new Sprite();
			addChild(childs);
			
			childs.x = e.stageX;
			childs.y = e.stageY;
			
			//var bg:Bitmap = Window.backing2(234, 70, 3, "cursorsPanelBg", "cursorsPanelBg2");  //bonusBacking
			var bg:Bitmap = Window.backing2(256, 69+6, 15, "cursorsPanelBg2", "cursorsPanelBg3");			
			childs.addChild(bg);
			//bg.alpha = 0.5;
			bg.y = 5;
			bg.x = 5;
			
			var offsetX:int = 10+3;
			var offsetY:int = 10+3;
			var dX:int = 5;
			
			for (var i:int = 0; i < count; i++)
			{
				var item:WishListItem = new WishListItem();
				items.push(item);
				childs.addChild(item);
				
				item.x = offsetX;
				item.y = offsetY;
				
				item.addEventListener(MouseEvent.CLICK, onClick);
				
				offsetX += item.bg.width + dX;
			}
			
			for (var j:* in App.user.wishlist)
			{
				if (!App.data.storage.hasOwnProperty(App.user.wishlist[j])) continue;
				items[j].sID = App.user.wishlist[j];
			}
			
			if (childs.x + childs.width > App.self.stage.stageWidth) {
				childs.x -= (childs.x + childs.width) - App.self.stage.stageWidth + 10;
			}
			
			if (childs.y + childs.height > App.self.stage.stageHeight) {
				childs.y -= (childs.y + childs.height) - App.self.stage.stageHeight + 10;
			}
			
			App.self.windowContainer.addChild(this);
			App.self.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		}
		
		public function dispose():void
		{
			App.self.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			
			if (contains(fader)) removeChild(fader);
			fader.removeEventListener(MouseEvent.CLICK, onHideEvent);
			fader = null;
			
			if (App.self.windowContainer.contains(this)) App.self.windowContainer.removeChild(this);
			
			if (contains(childs)) removeChild(childs);
			
			lastSID = 0;
			
			for each(var item:* in items)
			{
				item.removeEventListener(MouseEvent.CLICK, onClick);
			}
			items = [];
		}
		
		private function onClick(e:MouseEvent):void
		{
			var sID:uint = e.currentTarget.sID;
			if (sID == 0) 
			{
				if(add(lastSID)) e.currentTarget.sID = lastSID;
			}
			else
			{
				e.currentTarget.sID = 0;
				remove(sID);
			}
			
			var item:* = e.currentTarget;
			if (item.__hasGlowing) item.hideGlowing();
			if (item.__hasPointing) item.hidePointing();
		}
		
		
		public function add(sID:uint):Boolean
		{
			//if (App.data.storage[sID].type == "Energy")
				//return false;
			var id:uint = 0;
			for each(var _sID:* in App.user.wishlist)
			{
				if (sID == _sID) return false;
				id ++;
			}
			
			if (App.user.wishlist.length < count)
			{
				// Добавляем в лист
				App.user.wishlist.push(sID)
				
				Post.send( {
						ctr:'wishlist',
						act:'add',
						uID:App.user.id,
						sID:sID
					}, function():void{});
				
				return true;
			}
			else
			{
				return false;
			}
		}
		
		public function remove(sID:uint):void
		{
			for (var i:String in App.user.wishlist)
			{
				if (sID == App.user.wishlist[i])
				{
					App.user.wishlist.splice(i, 1);
					Post.send( {
						ctr:'wishlist',
						act:'remove',
						uID:App.user.id,
						sID:sID
					}, function():void{});
				}
			}
		}
		
		public function findFree():void {
			if (App.self.windowContainer.contains(this) && items.length > App.user.wishlist.length) {
				var item:WishListItem = items[App.user.wishlist.length] as WishListItem;
				item.showPointing('bottom', 0, 70, childs);
				item.showGlowing();
			}
		}
	}
}

import buttons.ImageButton;
import core.Load;
import flash.display.Bitmap;
import flash.display.BitmapData;
import wins.Window;
import ui.WishList;
import ui.UserInterface;

internal class WishListItem extends LayerX
{
	public var bg:ImageButton;
	private var _sID:uint = 0;
	public var bitmap:Bitmap;
	public const emptyBD:BitmapData = UserInterface.textures.wishlistPlusBttn;
	public const placedBD:BitmapData = Window.textures.cursorsPanelItemBg;
	
	private var preloader:Preloader = new Preloader();
	
	public function WishListItem()
	{
		//var bmp:Bitmap = Window.backing(60, 60, 8, "bonusBacking");
		var bmp:Bitmap = new Bitmap(emptyBD);
		
		bg = new ImageButton(bmp.bitmapData);
		addChild(bg);
		
		tip = function():Object {
			return {
				title: _sID > 0?Locale.__e('flash:1382952379836'): Locale.__e('flash:1382952379837')
			}
		}
		mouseChildren = false;
	}
	
	public function set sID(value:uint):void
	{
		_sID = value;
		if (_sID == 0)
		{
			bg.bitmap.bitmapData = emptyBD;
			removeChild(bitmap);
			bitmap = null;
		}
		else
		{
			bg.bitmap.bitmapData = placedBD;
			addChild(preloader);
			preloader.scaleX = preloader.scaleY = 0.6;
			preloader.x = 60 / 2;
			preloader.y = 60 / 2;
			
			Load.loading(Config.getIcon(App.data.storage[_sID].type, App.data.storage[_sID].preview), onLoad);
		}	
	}
	
	public function get sID():uint
	{
		return _sID;
	}
	
	private function onLoad(data:Bitmap):void
	{
		removeChild(preloader);
		
		bitmap = new Bitmap();
		addChild(bitmap);
		bitmap.bitmapData = data.bitmapData;
		var scale:Number = 45 / data.height;
		bitmap.width 	*= scale;
		bitmap.height 	*= scale;
		bitmap.smoothing = true;
		
		bitmap.x = (bg.width - bitmap.width) / 2;
		bitmap.y = (bg.height - bitmap.height) / 2;
	}
}