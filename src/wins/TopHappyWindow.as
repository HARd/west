package wins 
{
	import adobe.utils.CustomActions;
	import buttons.Button;
	import core.Load;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.text.TextField;
	public class TopHappyWindow extends Window 
	{
		
		private var descLabel:TextField;
		private var back:Bitmap;
		private var container:Sprite;
		private var showMeBttn:Button;
		
		public var sections:int = 0;
		public var max:int = 100;
		
		public function TopHappyWindow(settings:Object=null) 
		{
			if (!settings) settings = { };
			
			settings['width'] = settings['width'] || 790;
			settings['height'] = settings['height'] || 660;
			settings['title'] = (settings.hasOwnProperty('target')) ? settings.target.info.title : '';
			settings['true'] = false;
			settings['description'] = settings['description'];
			//settings['background'] = 'questBacking';
			
			max = settings['max'] || 100;
			sections = settings['sections'] || 5;
			
			var ownerHere:Boolean = false;
			for (var i:int = 0; i < settings.content.length; i++) {
				if (settings.content[i].uID == App.user.id) {
					ownerHere = true;
					settings.content[i].attraction = settings.target.kicks;
				}
				/*if (settings.content[i].attraction < settings.target.kicksMax && settings.target.sid != 2004) {
					settings.content.splice(i, 1);
					i--;
				}*/
			}
			settings.content.sortOn('attraction', Array.NUMERIC | Array.DESCENDING);
			
			if (settings.content.length > max)
				settings.content.splice(max, settings.content.length - max);
			
			for (i = 0; i < settings.content.length; i++) {
				settings.content[i]['num'] = String(i + 1);
			}
			
			super(settings);
			
		}
		
		public const MARGIN:int = 5;
		override public function drawBody():void 
		{
			titleLabel.y += 10;
			
			back = new Bitmap(new BitmapData(settings.width - 106, 450, true, 0xffff00));
			back.x = settings.width/2 - back.width/2;
			back.y = 85;
			bodyContainer.addChild(back);
			
			descLabel = drawText(settings.description, {
				textAlign:		'center',
				//autoSize:		'center',
				fontSize:		21,
				color:			0xe8e8e6,
				borderColor:	0x542f14,
				multiline:		true,
				wrap:			true,
				width:			400
			});
			descLabel.x = (settings.width - descLabel.width) / 2;
			descLabel.y = 25;
			bodyContainer.addChild(descLabel);
			
			//flash:1440499603885
			
			var separator:Bitmap = Window.backingShort(back.width - 10, 'dividerLine', false);
			separator.x = back.x + 10;
			separator.y = back.y;
			separator.alpha = 0.5;
			bodyContainer.addChild(separator);
			
			var separator2:Bitmap = Window.backingShort(back.width - 10, 'dividerLine', false);
			separator2.x = back.x + 10;
			separator2.y = back.y + back.height;
			separator2.alpha = 0.5;
			bodyContainer.addChild(separator2);
			
			var skip:Boolean = true;
			var posY:int = 0;
			for (var i:int = 0; i < sections; i++) {
				var height:int = Math.floor((back.height - MARGIN * 2) / sections);
				if (i == 0 || i == sections - 1) height += MARGIN;
				var bmd:BitmapData = new BitmapData(back.width, height, true, 0x66FFFFFF);
				
				if (!skip) {
					back.bitmapData.draw(bmd, new Matrix(1, 0, 0, 1, 0, posY));
					skip = true;
				}else {
					skip = false;
				}
				posY += bmd.height;
			}
			
			container = new Sprite();
			container.x = back.x;
			container.y = back.y;
			bodyContainer.addChild(container);
			
			/*showMeBttn = new Button( {
				width:		100,
				height:		36,
				caption:	Locale.__e('flash:1419439510724'),
				radius:		12,
				fontSize:	20
			});
			showMeBttn.x = 60;
			showMeBttn.y = settings.height - showMeBttn.height - 60;
			showMeBttn.addEventListener(MouseEvent.CLICK, showMe);
			bodyContainer.addChild(showMeBttn);*/
			
			/*infoBttn = new Button({
				width:		150,
				height:		45,
				fontSize:	20,
				caption:	Locale.__e('flash:1393579618588')
			});
			infoBttn.x = descLabel.x + descLabel.width - 20;
			infoBttn.y = descLabel.y + descLabel.height * 0.5 - infoBttn.height * 0.5;
			bodyContainer.addChild(infoBttn);
			infoBttn.addEventListener(MouseEvent.CLICK, onInfo);
			
			if (Exchange.take) {
				infoBttn.state = Button.DISABLED;
			} else {
				if (settings.target.expire - App.time <= 0 ) {
					infoBttn.showPointing('bottom', infoBttn.width / 2 - 70, infoBttn.height + 60, bodyContainer);
				}
			}*/
			
			var cont:Sprite = new Sprite();
			bodyContainer.addChild(cont);
			
			var rateDescLabel:TextField = drawText(Locale.__e('flash:1440494930989') + ':', {
				autoSize:		'center',
				textAlign:		'center',
				color:			0xf0feff,
				borderColor:	0x562d19,
				fontSize:		21
			});
			rateDescLabel.x = 0;
			rateDescLabel.y = 4;
			cont.addChild(rateDescLabel);
			
			var rateIcon:Bitmap;
			/*if (material) {
				rateIcon = new Bitmap();
				cont.addChild(rateIcon);
				Load.loading(Config.getIcon(material.type, material.preview), function(data:Bitmap):void {
					rateIcon.bitmapData = data.bitmapData;
					rateIcon.smoothing = true;
					Size.size(rateIcon, 30, 30);
					rateIcon.x = rateDescLabel.x + rateDescLabel.width + 6;
					rateIcon.y = rateDescLabel.y + rateDescLabel.height * 0.5 - rateIcon.height * 0.5;
				});
			}*/
			
			var rateLabel:TextField = drawText(String(settings.target.kicks), {
				width:			200,
				textAlign:		'left',
				color:			0x77feff,
				borderColor:	0x043b74,
				fontSize:		28
			});
			rateLabel.x = (rateIcon) ? rateDescLabel.x + rateDescLabel.width + 40 : rateDescLabel.x + rateDescLabel.width + 10;
			cont.addChild(rateLabel);
			cont.x = 90;
			cont.y = settings.height - cont.height - 80;
			
			
			paginator.onPageCount = sections;
			paginator.itemsCount = settings.content.length;
			paginator.update();
			paginator.x -= 40;
			paginator.y += 12;
			
			//drawTimer();
			
			contentChange();
		}
		
		public function showMe(e:MouseEvent):void {
			for (var i:int = 0; i < settings.content.length; i++) {
				if (String(settings.content[i].uID) == App.user.id) {
					break;
				}
			}
			
			if (paginator.page != Math.floor(i / sections)) {
				paginator.page = Math.floor(i / sections);
				paginator.update();
				contentChange();
			}
		}
		
		public var items:Vector.<TopItem> = new Vector.<TopItem>;
		override public function contentChange():void {
			clear();
			
			for (var i:int = 0; i < sections; i++) {
				if (paginator.page * sections + i >= settings.content.length) continue;
				var params:Object = settings.content[paginator.page * sections + i];
				
				params['width'] = back.width;
				params['height'] = Math.floor((back.height - MARGIN * 2) / sections);
				
				var item:TopItem = new TopItem(params, this);
				item.x = 0;
				item.y = MARGIN + i * Math.floor((back.height - MARGIN * 2) / sections);
				container.addChild(item);
				items.push(item);
			}
			
		}
		private function clear():void {
			while (items.length > 0) {
				var item:TopItem = items.shift();
				item.dispose();
			}
		}
		
		override public function dispose():void {
			clear();
			//showMeBttn.removeEventListener(MouseEvent.CLICK, showMe);
			
			super.dispose();
		}
	}

}
import buttons.Button;
import core.AvaLoad;
import core.Load;
import core.Size;
import flash.display.Bitmap;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.text.TextField;
import ui.UserInterface;
import wins.TopHappyWindow;
import wins.TopWindow;
import wins.Window;

internal class TopItem extends LayerX {
	
	private var backing:Shape;
	private var imageBack:Sprite;
	public var image:Sprite;
	private var photoBack:Shape;
	private var numLabel:TextField;
	private var nameLabel:TextField;
	private var rateLabel:TextField;
	private var preloader:Preloader;
	private var travelBttn:Button;
	
	private var bgColor:uint = 0xFFFFFF;
	private var bgAlpha:Number = 0;
	
	public var uID:*;
	public var window:TopHappyWindow;
	
	public function TopItem(params:Object, window:TopHappyWindow) {
		
		uID = params['uID'];
		this.window = window;
		
		if (uID == App.user.id) {
			bgColor = 0x33cc00;
			bgAlpha = 0.2;
		}
		
		backing = new Shape();
		backing.x = 5;
		backing.graphics.beginFill(bgColor, 1);
		backing.graphics.drawRoundRect(0, 0, params.width - 10, params.height, 20, 20); //drawRect(0, 0, params.width, params.height);
		backing.graphics.endFill();
		addChild(backing);
		backing.alpha = bgAlpha;
		
		numLabel = Window.drawText(params.num, {
			color:			0x7a4004,
			borderColor:	0xffffff,
			fontSize:		40,
			textAlign:		'center',
			width:			140
		});
		numLabel.x = -20;
		numLabel.y = (backing.height - numLabel.height) / 2 + 4;
		addChild(numLabel);
		
		var name:String = '';
		if (params['aka']) {
			name = params.aka;
			name = name.replace(' ', '\n');
		}else {
			name = params.first_name + '\n' + params.last_name;
		}
		
		nameLabel = Window.drawText(name, {
			color:			0x723d1b,
			borderColor:	0xfff8f3,
			fontSize:		26,
			textAlign:		'left',
			autoSize:		'left',
			multiline:		true,
			wrap:			true
		});
		//nameLabel.width = 160;
		//nameLabel.wordWrap = true;
		nameLabel.x = 180;
		nameLabel.y = (backing.height - nameLabel.height) / 2 - 2;
		addChild(nameLabel);
		
		var rateIcon:Bitmap;
		/*if (window.material) {
			rateIcon = new Bitmap();
			rateIcon.x = nameLabel.x + 150;
			addChild(rateIcon);
			Load.loading(Config.getIcon(window.material.type, window.material.preview), function(data:Bitmap):void {
				rateIcon.bitmapData = data.bitmapData;
				rateIcon.smoothing = true;
				Size.size(rateIcon, 50, 50);
				rateIcon.y = (backing.height - rateIcon.height) / 2;
			});
		}*/
		
		rateLabel = Window.drawText(params.attraction, {
			color:			0x77feff,
			borderColor:	0x043b74,
			borderSize:		2,
			fontSize:		40,
			textAlign:		'left',
			autoSize:		'center',
			width:			240,
			shadowSize:		2
		});
		rateLabel.x = (rateIcon) ? (rateIcon.x + 60) : (nameLabel.x + 160);
		rateLabel.y = (backing.height - rateLabel.height) / 2 + 4;
		addChild(rateLabel);
		
		travelBttn = new Button( {
			width:		130,
			height:		47,
			caption:	Locale.__e('flash:1419440810299'),
			fontSize:	21,
			radius:		12
		});
		travelBttn.x = backing.width - travelBttn.width - 25;
		travelBttn.y = (backing.height - travelBttn.height) / 2;
		travelBttn.addEventListener(MouseEvent.CLICK, travel);
		addChild(travelBttn);
		
		if (params['take'] == 1) {
			var checkMark:Bitmap = new Bitmap(Window.textures.checkMark);
			checkMark.x = backing.width - checkMark.width - 50;
			checkMark.y = backing.y + (backing.height - checkMark.height) / 2;
			addChild(checkMark);
			
			travelBttn.visible = false;
			
		}else if (App.user.id == String(uID) || !App.user.friends.data.hasOwnProperty(uID)) {
			travelBttn.state = Button.DISABLED;
			travelBttn.y = (backing.height - travelBttn.height) / 2 - 8;
			
			var infoLabel:TextField = Window.drawText((uID == App.user.id) ? Locale.__e('flash:1419500839285') : Locale.__e('flash:1419500809271'), {
				color:			0x7a4004,
				borderColor:	0xffffff,
				fontSize:		20,
				textAlign:		'center',
				autoSize:		'center'
			});
			infoLabel.x = travelBttn.x + (travelBttn.width - infoLabel.width) / 2;
			infoLabel.y = travelBttn.y + travelBttn.height + 2;
			addChild(infoLabel);
		}
		
		imageBack = new Sprite();
		imageBack.graphics.beginFill(0xba944d, 1);
		imageBack.graphics.drawRoundRect(0, 0, 68, 68, 20, 20);
		imageBack.graphics.endFill();
		imageBack.x = 95;
		imageBack.y = (backing.height - imageBack.height) / 2;
		addChild(imageBack);
		
		image = new Sprite();
		addChild(image);
		
		preloader = new Preloader();
		preloader.scaleX = preloader.scaleY = 0.6;
		preloader.x = imageBack.x + imageBack.width / 2;
		preloader.y = imageBack.y + imageBack.height / 2;
		addChild(preloader);
		
		new AvaLoad(params.photo, onLoad);
		
		var star:Bitmap = new Bitmap(UserInterface.textures.expIcon);
		star.smoothing = true;
		star.scaleX = star.scaleY = 0.8;
		star.x = imageBack.x + imageBack.width - star.width + 6;
		star.y = imageBack.y + imageBack.height - star.height + 4;
		addChild(star);
		
		var level:TextField = Window.drawText(String(params.level || 0), {
			fontSize:		20,
			color:			0x643113,
			borderSize:		0,
			autoSize:		'left',
			multiline:		true,
			wrap:			true
		});
		level.x = star.x + star.width / 2 - level.width / 2 - 1;
		level.y = star.y + 4;
		addChild(level);
		
		addEventListener(MouseEvent.MOUSE_OVER, onOver);
		addEventListener(MouseEvent.MOUSE_OUT, onOut);
	}
	
	private function onOver(e:MouseEvent):void {
		backing.alpha += 0.1;
	}
	private function onOut(e:MouseEvent):void {
		backing.alpha = bgAlpha;
	}
	
	private function travel(e:MouseEvent):void {
		if (travelBttn.mode == Button.DISABLED) return;
		
		//App.ui.bottomPanel.showFriendsPanel();
		Travel.friend = App.user.friends.data[uID];
		//Travel.trustFriendOpenWorld = 861;
		Travel.onVisitEvent(User.HOME_WORLD); // Ёлочный остров
		window.close();
	}
	
	private function onLoad(data:*):void {
		removeChild(preloader);
		preloader = null;
		
		var bitmap:Bitmap = new Bitmap(data.bitmapData, 'auto', true);
		bitmap.width = bitmap.height = 64;
		image.addChild(bitmap);
		
		var maska:Shape = new Shape();
		maska.graphics.beginFill(0xba944d, 1);
		maska.graphics.drawRoundRect(0, 0, 64, 64, 18, 18);
		maska.graphics.endFill();
		image.addChild(maska);
		
		bitmap.mask = maska;
		
		image.x = imageBack.x + (imageBack.width - image.width) / 2;
		image.y = imageBack.y + (imageBack.height - image.height) / 2;
	}
	
	public function dispose():void {
		removeEventListener(MouseEvent.MOUSE_OVER, onOver);
		removeEventListener(MouseEvent.MOUSE_OUT, onOut);
		
		if (parent) parent.removeChild(this);
	}
}