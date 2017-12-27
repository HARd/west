package wins 
{
	import buttons.Button;
	import buttons.UpgradeButton;
	import core.Load;
	import core.Numbers;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import ui.UserInterface;
	import units.Castle;
	/**
	 * ...
	 * @author ...
	 */
	public class CastleWindow extends Window 
	{
		
		private var countLabel:TextField;
		private var descLabel:TextField;
		private var tributeLabel:TextField;
		private var tributeIcon:Bitmap;
		private var inviteBttn:Button;
		private var storageBttn:UpgradeButton;
		private var avaBack:Bitmap;
		private var avaImage:Bitmap;
		
		public var target:Castle;
		public var container:Sprite;
		public var tributeCont:Sprite;
		
		public function CastleWindow(settings:Object=null) 
		{
			settings['hasPaginator'] = settings['hasPaginator'] || false;
			settings['hasPages'] = settings['hasPages'] || true;
			settings['background'] = "questBacking" || true;
			settings['width'] = settings['width'] || 420;
			settings['height'] = settings['height'] || 280;
			settings['title'] = settings.target.info.title || '';
			
			super(settings);
			
			target = settings.target;
			
			content = {};
			for (var s:String in target.info.form.view) {
				content[s] = target.info.form.view[s];
			}
		}
	
		override public function drawBody():void {
			
			var separator:Bitmap = Window.backingShort(settings.width - 60, 'divider');
			separator.alpha = 0.8;
			separator.x = (settings.width - separator.width) / 2;
			separator.y = 110;
			bodyContainer.addChild(separator);
			
			drawMirrowObjs('diamondsTop', settings.width / 2 - settings.titleWidth / 2 - 5, settings.width / 2 + settings.titleWidth / 2 + 5, -54, true, true);
			drawMirrowObjs('storageWoodenDec', -4, settings.width + 4, 38, false, false, false, 1, -1);
			drawMirrowObjs('storageWoodenDec', -4, settings.width + 4, settings.height - 74, false, false, true, 1, 1);
			
			titleLabel.y -= 10;
			exit.x += 2;
			exit.y -= 20;
			
			
			var upCont:Sprite = new Sprite();
			bodyContainer.addChild(upCont);
			
			avaBack = new Bitmap(Window.textures.referalRoundBacking, 'auto', true);
			avaBack.scaleX = avaBack.scaleY = 0.6;
			avaBack.x = -8;
			avaBack.y = 6;
			upCont.addChild(avaBack);
			
			avaImage = new Bitmap(UserInterface.textures.friendsIcon, 'auto', true);
			upCont.addChild(avaImage);
			
			countLabel = drawText(Locale.__e('flash:1416567120448', [0]), {
				autoSize:		'center',
				color:			0xfdfdff,
				borderColor:	0x5b3200,
				fontSize:		26
			});
			countLabel.x = avaImage.x + avaImage.width + 20;
			countLabel.y = 10;
			upCont.addChild(countLabel);
			
			inviteBttn = new Button( {
				width:		150,
				height:		46,
				caption:	Locale.__e('flash:1382952380197')
			});
			inviteBttn.x = countLabel.x + (countLabel.width - inviteBttn.width) / 2;
			inviteBttn.y = countLabel.y + countLabel.height + 10;
			upCont.addChild(inviteBttn);
			inviteBttn.addEventListener(MouseEvent.CLICK, onInvite);
			
			upCont.x = (settings.width - upCont.width) / 2;
			upCont.y = -10;
			
			
			// Доход
			descLabel = drawText(Locale.__e('flash:1416568873162'), {
				autoSize:		'center',
				color:			0xfdfdff,
				borderColor:	0x5b3200,
				fontSize:		36
			});
			descLabel.x = separator.x + (separator.width - descLabel.width) / 2;
			descLabel.y = separator.y + (separator.height - descLabel.height) / 2;
			bodyContainer.addChild(descLabel);
			
			tributeCont = new Sprite();
			bodyContainer.addChild(tributeCont);
			
			tributeIcon = new Bitmap();
			tributeCont.addChild(tributeIcon);
			
			tributeLabel = drawText(Locale.__e('flash:1382952380278', [target.tribute, target.limit]), {
				//width:			140,
				autoSize:		'center',
				color:			0xfed41e,
				borderColor:	0x744d00,
				fontSize:		40
			});
			tributeLabel.x = 50;
			tributeLabel.y = 0;
			tributeCont.addChild(tributeLabel);
			
			tributeCont.y = separator.y + separator.height + 10;
			
			Load.loading(url(3), function(data:Bitmap):void {
				tributeIcon.bitmapData = data.bitmapData;
				tributeIcon.smoothing = true;
				tributeIcon.width = 40;
				tributeIcon.scaleY = tributeIcon.scaleX;
			});
			
			storageBttn = new UpgradeButton(UpgradeButton.TYPE_ON,{
				caption: Locale.__e("flash:1382952380146"),
				width:236,
				height:55,
				icon:null, //Window.textures.upgradeArrow,
				fontBorderColor:0x002932,
				countText:"",
				fontSize:28,
				iconScale:0.95,
				radius:30,
				textAlign:'left',
				autoSize:'left',
				widthButton:230
			});
			storageBttn.addEventListener(MouseEvent.CLICK, storageAction);
			storageBttn.x = (settings.width - storageBttn.width) / 2;
			storageBttn.y = settings.height - storageBttn.height + 30;
			bodyContainer.addChild(storageBttn);
			
			update();
			drawViews();
		}
		
		public function update():void {
			var count:int = 0;
			for (var s:* in target.friends) count++;
			countLabel.text = Locale.__e('flash:1416567120448', [count]);
			tributeLabel.text = Locale.__e('flash:1382952380278', [target.tribute, target.limit]);
			tributeCont.x = (settings.width - tributeCont.width) / 2;
			
			if (target.tribute > 0) {
				storageBttn.state = Button.NORMAL;
			}else {
				storageBttn.state = Button.DISABLED;
			}
		}
		
		public function url(sid:*):String {
			if (App.data.storage.hasOwnProperty(sid)) {
				return Config.getIcon(App.data.storage[sid].type, App.data.storage[sid].preview);
			}else {
				return '';
			}
		}
		
		private function storageAction(e:MouseEvent):void {
			if (storageBttn.mode == Button.DISABLED) return;
			
			if (settings.storageAction != null) {
				storageBttn.state = Button.DISABLED;
				settings.storageAction(function():void {
					if (opened) {
						storageBttn.state = Button.NORMAL;
						update();
					}
				});
			}
		}
		private function onInvite(e:MouseEvent):void {
			close();
			
			new AskWindow(AskWindow.MODE_INVITE, {
				target:settings.target,
				title:Locale.__e('flash:1382952380197'), 
				friendException:function(... args):void {
					trace(args);
				},
				inviteTxt:Locale.__e("flash:1395846352679"),
				desc:Locale.__e("flash:1417100492324"),
				noAllFriends:true
			} ).show();
			
			//new AskWindow(AskWindow.MODE_NOTIFY, {
				//target:settings.target,
				//title:Locale.__e('flash:1382952380197'), 
				//friendException:settings.friendsData,
				//inviteTxt:Locale.__e("flash:1417020589452"),
				//desc:Locale.__e("flash:1417020589452")
			//} ).show();
		}
		
		override public function drawFader():void {
			super.drawFader();
			
			this.y -= 100;
			fader.y += 100;
		}
		
		public var items:Array = [];
		private var ANGLE:Number = 8.5;
		private function drawViews():void {
			clear();
			
			container = new Sprite();
			bodyContainer.addChild(container);
			container.x = settings.width / 2;
			container.y = settings.height;
			
			var angle:Number = 5;
			var nums:int = Numbers.countProps(content);
			var pos:int = 0;
			for (var s:* in content) {
				var item:CastleIcon = new CastleIcon( {
					id:				s,
					title:			target.info.form.req[s].n,
					lock:			(target.views.indexOf(int(s)) == -1) ? false : true,
					onClick:		onIconClick,
					window:			this,
					bitmapData:		getBitmapData(s)
				});
				items.push(item);
				container.addChild(item);
				
				item.x = 1100 * Math.sin((-((nums - 1) * ANGLE / 2) + ANGLE * pos) * Math.PI / 180);
				item.y = -1000 + 1100 * Math.cos((-((nums - 1) * ANGLE / 2) + ANGLE * pos) * Math.PI / 180);
				pos ++;
				
				if (target.view == int(s))
					setFocusView(s);
			}
			
			/*list = new MoveList( {
				items:		items,
				window:		this
			})*/
		}
		private function onIconClick(e:MouseEvent):void {
			var item:CastleIcon = e.currentTarget as CastleIcon;
			target.setView(item.name, item.onOpen);
		}
		public function setFocusView(id:*):void {
			for (var s:* in items) {
				if (items[s].id == id) {
					items[s].glow();
				}else {
					items[s].hide();
				}
			}
		}
		public function clear():void {
			while (items.length > 0) {
				var item:* = items.shift();
				item.dispose();
			}
		}
		
		public function getBitmapData(s:*):BitmapData {
			return target.textures.sprites[target.level - 1 + int(s) - 1].bmp;
		}
		
		override public function dispose():void {
			storageBttn.removeEventListener(MouseEvent.CLICK, storageAction);
			storageBttn.dispose();
			inviteBttn.removeEventListener(MouseEvent.CLICK, onInvite);
			inviteBttn.dispose();
			super.dispose();
		}
	}
}


import core.Load;
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.filters.GlowFilter;
import flash.text.TextField;
import silin.filters.ColorAdjust;
import wins.Window;

internal class MoveList extends Sprite {
	
	public var params:Object = {
		align:					'center',  // center, left
		numOnPage:				4,
		moveStep:				1,			// Количество прокручиваемых иконок
		speed:					0.3
	}
	
	public function MoveList(params:Object = null):void {
		if (params) {
			for (var s:* in params) this.params[s] = params[s];
		}
		
		if (params.items != null && params.items is Array) {
			draw();
		}
	}
	
	public function draw():void {
		//clear();
	}
	
}

internal class CastleIcon extends LayerX {
	
	public var id:*;
	private var titleLabel:TextField;
	private var lock:Bitmap;
	private var back:Bitmap;
	private var icon:Bitmap;
	private var preloader:Preloader;
	private var colorAdjust:ColorAdjust;
	
	public var params:Object = {
		scale:		1
	}
	
	public function CastleIcon (params:Object):void {
		
		if (params) {
			for (var s:* in params)
				this.params[s] = params[s];
		}
		
		id = params.id;
		
		draw();
		
		this.scaleX = this.scaleY = this.params.scale;
		this.name = this.params.name || this.params.id;
	}
	
	public function draw():void {
		colorAdjust = new ColorAdjust();
		this.filters = [colorAdjust.filter];
		
		back = new Bitmap(Window.textures.referalRoundBacking, 'auto', true);
		back.x = -back.width / 2;
		back.y = -back.height / 2;
		addChild(back);
		
		/*preloader = new Preloader();
		preloader.scaleX = preloader.scaleY = this.params.scale;
		addChild(preloader);*/
		
		icon = new Bitmap(params.bitmapData, 'auto', true);
		icon.width = back.width * 0.8;
		icon.scaleY = icon.scaleX;
		icon.x = -icon.width / 2;
		icon.y = -icon.height / 2;
		addChild(icon);
		
		lock = new Bitmap(Window.textures.lock, 'auto', true);
		lock.x = -lock.width / 2;
		lock.y = back.height / 2 - lock.height + 12;
		if (params['lock'] == false) {
			addChild(lock);
			
			/*var mtrx:ColorAdjust = new ColorAdjust();
			mtrx.saturation(0);
			icon.filters = [mtrx.filter];*/
		}
		
		titleLabel = Window.drawText(params.title, {
			width:			back.width,
			textAlign:		'center',
			color:			0xfffef8,
			borderColor:	0x5a3200,
			fontSize:		25
		});
		titleLabel.x = -titleLabel.width / 2;
		titleLabel.y = -back.height / 2 - 10;
		addChild(titleLabel);
		
		//Load.loading(url, onLoad);
		
		addEventListener(MouseEvent.CLICK, onClick);
		addEventListener(MouseEvent.ROLL_OVER, onOver);
		addEventListener(MouseEvent.ROLL_OUT, onOut);
	}
	
	/*private function onLoad(data:Bitmap):void {
		removeChild(preloader);
		preloader = null;
		
		icon.bitmapData = data.bitmapData;
		icon.smoothing = true;
		icon.x = -icon.width / 2;
		icon.y = -icon.height / 2;
	}*/
	
	private function get url():String {
		return params.link || '';
	}
	
	private function onClick(e:MouseEvent):void {
		if (params.onClick != null)
			params.onClick(e);
	}
	private function onOver(e:MouseEvent):void {
		var mtrx:ColorAdjust = new ColorAdjust();
		mtrx.brightness(0.1);
		this.filters = [mtrx.filter];
	}
	private function onOut(e:MouseEvent):void {
		var mtrx:ColorAdjust = new ColorAdjust();
		mtrx.brightness(0);
		this.filters = [mtrx.filter];
	}
	
	public function glow():void {
		back.filters = [new GlowFilter(0xfff492, 1, 24, 24, 4)];
	}
	public function hide():void {
		back.filters = null;
	}
	
	public function onOpen():void {
		if (lock && !contains(lock))
			addChild(lock);
		
		/*var mtrx:ColorAdjust = new ColorAdjust();
		mtrx.saturation(1);
		icon.filters = [mtrx.filter];*/
		
		params.window.close();
	}
	
	public function dispose():void {
		removeEventListener(MouseEvent.CLICK, onClick);
		removeEventListener(MouseEvent.ROLL_OVER, onOver);
		removeEventListener(MouseEvent.ROLL_OUT, onOut);
	}
}