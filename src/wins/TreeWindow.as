package wins 
{
	import api.ExternalApi;
	import buttons.Button;
	import buttons.MenuButton;
	import buttons.MoneyButton;
	import core.Load;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.ProgressEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import ui.Hints;
	import ui.UserInterface;
	import units.Hut;

	public class TreeWindow extends Window
	{
		private var items:Array = new Array();
		private var info:Object;
		public var back:Bitmap;
		public var buyAllBttn:MoneyButton;
		public var kickBttn:Button;
		public var progressBacking:Bitmap;
		
		public var started:uint;
		public var totalTime:uint;
		public var skipPrice:int;
		
		public function TreeWindow(settings:Object = null)
		{
			if (settings == null) {
				settings = new Object();
			}
			
			info = settings.target.info;
			
			//settings['fontColor'] = 0xffcc00;
			settings["fontSize"] = 46;
			settings["fontBorderSize"] = 1;
			settings["fontBorderGlow"] = 1;
			
			settings['width'] = 550;
			settings['height'] = 410;
			settings['title'] = info.title;
			settings['hasPaginator'] = true;
			settings['hasButtons'] = false;
			settings['hasArrow'] = true;
			settings['itemsOnPage'] = 10;
			settings['background'] = 'alertBacking';
			
			settings['content'] = [];
			
			var uid:uint;
			for (var id:* in settings.target._free) {
				uid = settings.target._free[id];
				if (!App.user.friends.data.hasOwnProperty(uid)) continue;
				settings['content'].push(uid)
			}
			
			for (id in settings.target._paid) {
				uid = settings.target._paid[id];
				if (!App.user.friends.data.hasOwnProperty(uid)) continue;
				settings['content'].push(uid)
			}
			
			started = settings.started;
			totalTime = settings.time;
			skipPrice = settings.skip;
			
			super(settings);
		}
		
		
		public var progressBar:ProgressBar;
		private function drawStageInfo():void {
			
			var back:Bitmap = Window.backing(settings.width - 100, 80, 20, 'bonusBacking');
			back.x = 50;
			back.y = 230;
			
			var text:String = Locale.__e('flash:1382952380320');
			var label:TextField = drawText(text, {
				fontSize:26,
				autoSize:"center",
				textAlign:"center",
				color:0xf0e6c1,
				borderColor:0x502f06,
				border:true
			});
			
			label.width = settings.width - 50;
			label.height = label.textHeight;
			label.x = (settings.width - label.width) / 2;
			label.y = back.y - 10;
			
			bodyContainer.addChild(back);
			bodyContainer.addChild(label);
			
			progressBacking = Window.backingShort(340, "prograssBarBacking3");
			progressBacking.x = (settings.width - progressBacking.width) / 2;
			progressBacking.y = back.y + 24;
			bodyContainer.addChild(progressBacking);
			
			progressBar = new ProgressBar( { win:this, width:progressBacking.width + 6 } );
			progressBar.start();
			progressBar.x = progressBacking.x + (progressBacking.width - progressBar.width) / 2;
			progressBar.y = progressBacking.y - 2;
			progress();
			
			App.self.setOnTimer(progress);
			bodyContainer.addChild(progressBar);
		}
		
		private var leftTime:uint;
		private function progress():void
		{
			leftTime = totalTime - (App.time - started);
			progressBar.time = leftTime;
			
			if (leftTime <= 0) { 
				App.self.setOffTimer(progress);
				close();
			}
			progressBar.progress = (App.time - started) / totalTime;
		}
		
		override public function drawBody():void {
			
			exit.x -= 10;
			exit.y -= 5;
			
			drawLabel(settings.target.textures.sprites[1].bmp, 1);
			titleLabel.y += 20;
			titleLabelImage.y -= 20;
			
			drawVisitors();
			drawStageInfo();
			
			if (settings.content.length == 0)
			{
				var descriptionLabel:TextField = drawText(Locale.__e("flash:1382952380322"), {
					fontSize:22,
					autoSize:"left",
					textAlign:"center",
					//color:0x502f06,
					//border:false,
					color:0x5d450f,
					borderColor:0xefe5c3,
					textLeading:-9
				});
				
				descriptionLabel.x = (settings.width - descriptionLabel.width) / 2;
				descriptionLabel.y = back.y + (back.height - descriptionLabel.height) / 2 - 2;
				descriptionLabel.width = settings.width - 80;
				
				bodyContainer.addChild(descriptionLabel);
			}
			
			drawBttns();
			
			drawMirrowObjs('diamondsTop', settings.width / 2 - settings.titleWidth / 2 - 5, settings.width / 2 + settings.titleWidth / 2 + 5, -24, true, true);
			drawMirrowObjs('storageWoodenDec', 8, settings.width - 8, 58, false, false, false, 1, -1);
			drawMirrowObjs('storageWoodenDec', 8, settings.width - 8, settings.height - 78, false, false, true, 1, 1);
		}
		
		override public function drawLabel(bmd:BitmapData, scale:Number = 1):void {
			titleLabelImage = new Bitmap(bmd);
			bodyContainer.addChild(titleLabelImage);
			if (titleLabelImage.height > 260 && scale == 1) 
				scale = 260 / titleLabelImage.height;
			
			titleLabelImage.scaleX = titleLabelImage.scaleY = scale;
			titleLabelImage.smoothing = true;
			
			titleLabelImage.x = (settings.width - titleLabelImage.width)/2;
			titleLabelImage.y = -titleLabelImage.height / 2;
		}
		
		private function drawBttns():void {
			
			buyAllBttn = new MoneyButton({
				caption		:Locale.__e("flash:1382952380021"),
				width		:190,
				height		:42,	
				fontSize	:26,
				countText	:skipPrice
			});
			buyAllBttn.x = (settings.width - buyAllBttn.width) / 2;
			buyAllBttn.y = 315;
			
			bodyContainer.addChild(buyAllBttn);
			
			buyAllBttn.addEventListener(MouseEvent.CLICK, buyAllEvent);
			buyAllBttn.visible = true;
		}
		
		private function buyAllEvent(e:MouseEvent):void {
			if (e.currentTarget.mode == Button.DISABLED) return;
			e.currentTarget.state = Button.DISABLED;
			
			settings.target.onBoostEvent();
			close();
		}
		
		private function kickEvent(e:MouseEvent):void {
			if (e.currentTarget.mode == Button.DISABLED) return;
			e.currentTarget.state = Button.DISABLED;
			settings.storageEvent(0, onStorageEventComplete);
		}
		
		public function onStorageEventComplete(sID:uint, price:uint):void {
			
			if (price == 0 ) {
				close();
				return;
			}
			var X:Number = App.self.mouseX - kickBttn.mouseX + kickBttn.width / 2;
			var Y:Number = App.self.mouseY - kickBttn.mouseY;
			Hints.minus(sID, price, new Point(X, Y), false, App.self.tipsContainer);
			close();
		}
		
		private function drawVisitors():void {
			
			back = Window.backing(settings.width - 100, 160, 20, 'bonusBacking');
			back.x = 50;
			back.y = 40;
			
			var text:String = Locale.__e('flash:1382952380325');
			var label:TextField = drawText(text, {
				fontSize:26,
				autoSize:"center",
				textAlign:"center",
				//color:0x502f06,
				color:0xf0e6c1,
				borderColor:0x502f06,
				border:true
			});
			
			label.width = settings.width - 50;
			label.height = label.textHeight;
			label.x = (settings.width - label.width) / 2;
			label.y = back.y - 14;
			
			bodyContainer.addChild(back);
			bodyContainer.addChild(label);	
			
			if (settings['content'].length > 0){
				contentChange();
				drawNotif();
			}else{
				drawNotif();
			}	
		}
		
		public var notifBttn:Button = null;
		
		private function drawNotif():void {
			
			var bttnSettings:Object = {
				caption		:Locale.__e("flash:1382952380289"),
				width		:190,
				height		:38,	
				fontSize	:26
			}
			
			if (settings['content'].length > 0) {
				bttnSettings['width'] = 160;
				bttnSettings['height'] = 30;
				bttnSettings['fontSize'] = 22;
				bttnSettings['caption'] = Locale.__e("flash:1382952379977");
			}
			
			notifBttn = new Button(bttnSettings);
			notifBttn.x = back.x + (back.width - notifBttn.width) / 2;
			notifBttn.y = back.y + back.height - 20;
			
			bodyContainer.addChild(notifBttn);
			notifBttn.addEventListener(MouseEvent.CLICK, onNotifClick);
		}
		
		private function onNotifClick(e:MouseEvent):void {
			switch(App.self.flashVars.social) {
				case 'VK':
				case 'DM':	
				case 'FB':
						//new NotifWindow( { target:settings.target } ).show();
						new AskWindow(AskWindow.MODE_INVITE, {
							target:settings.target,
							title:Locale.__e('flash:1382952380197'), 
							friendException:function(... args):void {
								trace(args);
							},
							inviteTxt:Locale.__e("flash:1395846352679"),
							desc:Locale.__e("flash:1413984616954"),
							noAllFriends:true
						} ).show();
					break;
				case 'OK':
				case 'ML':	
						ExternalApi.apiInviteEvent();
					break;
			}
		}
		
		override public function drawArrows():void {
				
			paginator.drawArrow(bodyContainer, Paginator.LEFT,  0, 0, { scaleX: -1, scaleY:1 } );
			paginator.drawArrow(bodyContainer, Paginator.RIGHT, 0, 0, { scaleX:1, scaleY:1 } );
			
			var y:Number = back.y + back.height / 2 - paginator.arrowLeft.height / 2;
			paginator.arrowLeft.x = -paginator.arrowLeft.width/2 + 26;
			paginator.arrowLeft.y = y;
			
			paginator.arrowRight.x = settings.width-paginator.arrowRight.width/2 - 26;
			paginator.arrowRight.y = y;
		}
		
		public override function contentChange():void {
			
			for each(var _item:* in items)
			{
				_item.dispose();
				if (_item && _item.parent)
					_item.parent.removeChild(_item)
				//bodyContainer.removeChild(_item);
			}
			
			items = [];
			
			var cont:Sprite = new Sprite();
			
			var X:int = 0;
			var Xs:int = X;
			var Y:int = 0;
			var itemNum:int = 0;
			
			for (var i:int = 0; i < 3; i++)
			{
				var item:TreeItem;
				
				item = new TreeItem(this);
			
				items.push(item);
				cont.addChild(item)
				
				item.x = X;
				item.y = Y;
				
				X += item.bg.width + 3;
				
				itemNum++;
			}
			
			var L:int = settings.content.length;
			if (L > 3) L = 3;
			for (i = 0; i < L; i++) {
				items[i].change(settings.content[i]);
			}
			
			bodyContainer.addChild(cont);
			cont.x = (settings.width - cont.width) / 2;
			cont.y = back.y + 15;
		}
		
		override public function dispose():void {
			
			buyAllBttn.removeEventListener(MouseEvent.CLICK, buyAllEvent);
			if (notifBttn != null) notifBttn.addEventListener(MouseEvent.CLICK, onNotifClick);
			
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

internal class TreeItem extends LayerX {
	
	public var window:*;
	public var uid:uint;
	public var time:uint;
	public var bg:Bitmap;
	private var bitmap:Bitmap;
	private var maska:Shape;
	
	public var ava_width:int = 80;
	
	public function TreeItem(window:*) {
		
		this.window = window;
		
		bg = Window.backing(120, 120, 20, 'timerBacking');
		addChild(bg);
		
		maska = new Shape();
		maska.graphics.beginFill(0xFFFFFF, 1);
		maska.graphics.drawRoundRect(0,0,ava_width,ava_width,15,15);
		maska.graphics.endFill();
		
		addChild(maska);
		maska.visible = false;
	}
	
	public function change(uid:uint):void {
		
		this.uid = uid;
		
		tip = function():Object {
			return {
				title	:App.user.friends.data[uid].first_name + " " +App.user.friends.data[uid].last_name
			}
		}
		
		//Load.loading(App.user.friends.data[uid].photo, onLoad);
		new AvaLoad(App.user.friends.data[uid].photo, onLoad);
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

