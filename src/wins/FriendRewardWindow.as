package wins 
{
	import api.com.odnoklassniki.sdk.events.Events;
	import buttons.Button;
	import core.Post;
	import flash.display.Bitmap;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import ui.UserInterface;
	//import FriendRewardItem;
	/**
	 * ...
	 * @author ...
	 */
	public class FriendRewardWindow extends Window
	{
		private var guestIcon:Bitmap;
		private var priceBttn:Button;
		private var reward:Object;
		public var count:int;
		public var sid:int;
		
		public function FriendRewardWindow(settings:*=null,ID:*=null) 
		{
			if (settings == null) {
				settings = new Object();
			}
			settings['width'] = 285;
			settings['height'] = 280;
			settings['title'] = Locale.__e('flash:1382952380000');
			settings['hasTitle'] = false;
			settings['background'] = 'alertBacking';
			settings['hasPaginator'] = false;
			settings['titlePading'] = 70;
			settings['hasExit'] = false;
			settings['popup'] = true;
			settings['forcedClosing'] = true;
			settings['faderAsClose'] = false;
			settings['faderClickable'] = false;
			settings['ID'] = ID || '';
			//reward = settings;/*||App.user.currentGuestReward*/;
			super(settings);
		}
		override public function drawBody():void 
		{
			drawReward();
			drawButton();
		}
		
		private function drawReward():void 
		{
			var item:FriendRewardItem = new FriendRewardItem(settings, this);
			bodyContainer.addChild(item);
			item.x = (settings.width - item.width) / 2;
			item.y = (settings.height - item.height) / 2 -15;
			item.scaleX = item.scaleY = 1; 
		
			this.sid = item.sID; 
			this.count = item.count;
		}
		
		private function drawButton():void 
		{
			var bttnSettings:Object = {
				caption:Locale.__e("flash:1382952379737"),
				fontSize:28,
				width:136,
				height:43,
				hasDotes:false
			};
			priceBttn = new Button(bttnSettings);
			bodyContainer.addChild(priceBttn);
			priceBttn.x = (settings.width - priceBttn.width) / 2;
			priceBttn.y = (settings.height - priceBttn.height) - 5;
			priceBttn.addEventListener(MouseEvent.CLICK, take);
			
		}
		
		public function take(target:* = null):void {
			var sendObject:Object = {
				ctr:'freebie',
				act:'take',
				uID:App.user.id,
				fID:/*(App.user.freebie.status+1)//*/settings.ID
			}
			
			Post.send( sendObject, function(error:int, data:Object, params:Object):void {
				if (error) {
					Errors.show(error, data);
					return;
				}
				
				App.user.stock.addAll(data.bonus);
				var item:BonusItem = new BonusItem(sid, count);
				var point:Point = Window.localToGlobal(priceBttn);
				item.cashMove(point, App.self.windowContainer);
				//BonusItem.takeRewards(data.bonus, (target != null) ? target : this);
				App.user.freebie.status++;
				
				if (App.user.freebie.status < 5/*FreebieWindow.freebieMaxValue*/) {
					//drawState();
					close();
				}else {
					close();
					//App.ui.rightPanel.hideFreebie();
				}
			});
			
		}
	}

}

import adobe.utils.CustomActions;
import core.Load;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.filters.GlowFilter;
import flash.geom.ColorTransform;
import flash.geom.Matrix;
import flash.text.TextField;
import flash.utils.clearInterval;
import flash.utils.setInterval;
import ui.UserInterface;
import wins.FriendRewardWindow;
import wins.Window;
	

internal class FriendRewardItem extends LayerX {
	
	private var item:Object;
	public var circle:Shape;
	public var win:FriendRewardWindow;
	private var title:TextField;
	public var sID:uint;
	public var count:uint;
	private var bitmap:Bitmap;
	private var status:int = 0;
	public var itemDay:int;
	private var layer:LayerX;
	private var intervalPluck:int;
	public var isCurrent:Boolean = false;
	
	public function FriendRewardItem(item:Object, win:FriendRewardWindow,numb:int = 0) {
		
		this.win = win;
		this.item = item;
		
		if (numb > App.user.freebie.status) {
			status = 2;
		}
		if (numb < App.user.freebie.status) {
			status = 0;
		}
		
		if (numb == App.user.freebie.status) {
			status = 1;
			isCurrent = true;
		}
		
		circle = new Shape();
		
		if (status == 1) {
			circle.graphics.beginFill(0xb1c0b9, 1);
			circle.graphics.drawCircle(80, 100, 65);
			circle.graphics.endFill();
		} else {
			circle.graphics.beginFill(0xb1c0b9, 1);
			circle.graphics.drawCircle(80, 100, 55);
			circle.graphics.endFill();
		}
		
		addChild(circle);
		circle.x -= 25;
		
		layer = new LayerX();
		addChild(layer);
		bitmap = new Bitmap();
		if (isCurrent) {
			var gf:GlowEffect = new GlowEffect();
			gf.scaleX = gf.scaleY = 1.2;
			gf.x = 164 / 2;
			gf.y = 200/ 2;
			layer.addChild(gf);
			gf.start();
		}
		layer.addChild(bitmap);
		
		if (item == null) return;
		
		for (var _sID:* in item.bonus) break;
			sID = _sID;
		count = item.bonus[_sID];
		
		drawCount();		
		
		Load.loading(Config.getIcon(App.data.storage[sID].type, App.data.storage[sID].preview), function(data:Bitmap):void {
			bitmap.bitmapData = data.bitmapData;
			var needScale:Number = Math.max(data.width / circle.width, data.height / circle.height);
			if (needScale > 1){
				var scale:Number = 1 / needScale;
				var matrix:Matrix = new Matrix();
				matrix.scale(scale, scale);
				var smallBMD:BitmapData = new BitmapData(data.width * scale, data.height * scale, true, 0x000000);
				smallBMD.draw(data, matrix, null, null, null, true);
				bitmap.bitmapData = smallBMD;
			}
			if(sID == Stock.EXP)
				bitmap.scaleX = bitmap.scaleY = 0.8;
			else
				bitmap.scaleX = bitmap.scaleY = 0.9;
			bitmap.smoothing = true;
			bitmap.x = (circle.width - bitmap.width) / 2;
			bitmap.y = (200 - bitmap.height) / 2;
			if (status == 1) startPluck();
			if (sID == Stock.FANT) return;
		});
		if (status == 2) {
			UserInterface.effect(circle, 0, 0.4);
		}
	}
	
	private function drawCount():void
	{
		var countText:TextField = Window.drawText("x" + String(count), {
			color:0xffffff,
			borderColor:0x682f1e,
			textAlign:"left",
			autoSize:"center",
			fontSize:28,
			textLeading: -6,
			width:80
		});
		countText.y = 150 - countText.height / 2;
		countText.x = 164 / 2;
		addChild(countText)
		
	}
	
	public function startPluck():void {
		intervalPluck = setInterval(randomPluck, Math.random()* 5000 + 2000);
	}
	
	private function randomPluck():void
	{
		layer.pluck(30, layer.width / 2, layer.height / 2 + 50);
	}
	
	public function dispose():void {
		clearInterval(intervalPluck);
		layer.pluckDispose();
	}
}

internal class GlowEffect extends Sprite {
	private var glowBitmap:Bitmap = new Bitmap(Window.textures.iconGlow);
	private var glowCont:Sprite = new Sprite();
	
	public function GlowEffect():void {
		addChild(glowCont);
		glowBitmap.x = -glowBitmap.width / 2;
		glowBitmap.y = -glowBitmap.height / 2;
		glowCont.addChild(glowBitmap);
	}
	
	public function start():void {
		var that:GlowEffect = this;
		
		App.self.setOnEnterFrame(function():void {
			if (that && that.parent) {
				glowCont.rotation++;
			}else {
				App.self.setOffEnterFrame(arguments.callee);
			}
		});
	}
	
}