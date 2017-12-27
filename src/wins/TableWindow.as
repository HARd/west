package wins
{
	import adobe.utils.CustomActions;
	import buttons.Button;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	/**
	 * ...
	 * @author 
	 */
	public class TableWindow extends Window
	{
		
		public function TableWindow(settings:Object = null)  
		{
			settings['width'] = settings.target.info.count * 100 + 100;
			if (settings['width'] <= 400) settings['width'] = 400;
				
			settings['height'] = 360;
			settings['title'] = settings.target.info.title;
			settings['hasButtons'] = false;
			settings['hasPaginator'] = false;
			
			super(settings);
		}
		
		override public function drawBody():void {
			drawLabel(settings.target.textures.sprites[settings.target.totalLevels].bmp, 0.8);
			titleLabel.y += 20;
			titleLabelImage.y += 10;
			
			super.drawBody();
			
			var title:TextField = Window.drawText(Locale.__e("flash:1382952380308"), {
				fontSize:28,
				color:0x502f06,
				borderColor:0xf0e6c1,
				textAlign:"center"
			});	
			title.width = title.textWidth + 5;
			title.height = title.textHeight;
			bodyContainer.addChild(title);
			title.x = (settings.width - title.width) / 2;
			title.y = 70;
			
			drawItems();
			
			storageBttn = new Button( { 
				width:220,
				caption:Locale.__e('flash:1382952380309')
			});
			bodyContainer.addChild(storageBttn);
			storageBttn.x = (settings.width - storageBttn.width) / 2;
			storageBttn.y = cont.y + cont.height + 20;
			
			storageBttn.addEventListener(MouseEvent.CLICK, onStorageClick);
			
			if (!settings.target.hasProfit)
				storageBttn.state = Button.DISABLED;
		}
		
		private function onStorageClick(e:MouseEvent):void {
			if (storageBttn.mode == Button.DISABLED) return;
			
			close();
			settings.onStorage();
		}
		
		private var storageBttn:Button;
		private var cont:Sprite;
		private var items:Array = [];
		private function drawItems():void {
			
			cont = new Sprite();
			var X:int = 0;
			for (var i:int = 0; i < settings.target.info.count; i++) //i < 3; i++)//
			{
				var item:TableItem = new TableItem(this);
				items.push(item);
				item.x = X;
				item.alpha = 0.5;
				X += item.width;
				cont.addChild(item);
			}
			
			for (var id:* in settings.target.guests)
			{
				var uid:String = String(settings.target.guests[id])
				if(items[id] != null){
					items[id].change(uid);
					items[id].alpha = 1;
				}
			}	
				
			bodyContainer.addChild(cont);
			cont.x = (settings.width - cont.width) / 2;
			cont.y = 100;
		}
		
		public override function dispose():void {
			storageBttn.removeEventListener(MouseEvent.CLICK, onStorageClick);
			super.dispose();
		}
	}
}

import core.AvaLoad;
import core.Load;
import flash.display.Bitmap;
import flash.display.Shape;
import flash.display.Sprite;
import wins.Window;

internal class TableItem extends LayerX {
	
	public var window:*;
	public var uid:String;
	public var time:uint;
	public var bg:Bitmap;
	private var bitmap:Bitmap;
	private var maska:Shape;
	
	public var ava_width:int = 80;
	
	public function TableItem(window:*) {
		
		this.window = window;
		
		bg = Window.backing(100, 100, 20, 'textSmallBacking');
		addChild(bg);
		
		maska = new Shape();
		maska.graphics.beginFill(0xFFFFFF, 1);
		maska.graphics.drawRoundRect(0,0,ava_width,ava_width,15,15);
		maska.graphics.endFill();
		
		addChild(maska);
		maska.visible = false;
	}
	
	public function change(uid:String):void {
		
		this.uid = uid;
		
		if (!App.user.friends.data.hasOwnProperty(uid)) {
			
			tip = function():Object {
				return {
					title	:Locale.__e('flash:1382952380310')
				}
			}
			
			Load.loading(Config.getIcon('Material', 'friends'), onLoad);
			
		}
		else
		{
			tip = function():Object {
				return {
					title	:App.user.friends.data[uid].first_name + " " +App.user.friends.data[uid].last_name
				}
			}
			
			new AvaLoad(App.user.friends.data[uid].photo, onLoad);
		}
	}
	
	private function onLoad(data:Bitmap):void {
		bitmap = new Bitmap(data.bitmapData);
		addChild(bitmap);
		
		bitmap.width = ava_width;
		bitmap.height = ava_width;
		bitmap.smoothing = true;
		
		bitmap.x = (bg.width - bitmap.width) / 2;
		bitmap.y = (bg.height - bitmap.height) / 2;
		
		maska.x = bitmap.x;
		maska.y = bitmap.y;
		bitmap.mask = maska;
		
		maska.visible = true;
	}
	
	public function dispose():void {
		
	}
}