package wins.elements 
{
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
	import wins.TopWindow;
	import wins.Window;

	public class TopItem extends LayerX {
		
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
		public var window:TopWindow;
		
		public function TopItem(params:Object, window:TopWindow) {
			
			uID = params['uID'];
			this.window = window;
			
			if (uID == App.user.id) {
				bgColor = 0x33cc00;
				bgAlpha = 0.2;
			}
			
			backing = new Shape();
			backing.x = 5;
			backing.graphics.beginFill(bgColor, 1);
			backing.graphics.drawRoundRect(0, 0, (params.width || 100) - 10, (params.height || 100), 20, 20); //drawRect(0, 0, params.width, params.height);
			backing.graphics.endFill();
			addChild(backing);
			backing.alpha = bgAlpha;
			
			var color:uint = 0x7a4004;
			var backColor:uint = 0xffffff;
			switch(params.num) {
				case '1':
					color = 0xdfc60a;
					backColor = 0x5a3413;
					break;
				case '2':
					color = 0xcdcccc;
					backColor = 0x5a3413;
					break;
				case '3':
					color = 0xffa24b;
					backColor = 0x5a3413;
					break;
			}
			numLabel = Window.drawText(params.num, {
				color:			color,
				borderColor:	backColor,
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
			if (window.material) {
				rateIcon = new Bitmap();
				rateIcon.x = nameLabel.x + 150;
				addChild(rateIcon);
				Load.loading(Config.getIcon(window.material.type, window.material.preview), function(data:Bitmap):void {
					rateIcon.bitmapData = data.bitmapData;
					rateIcon.smoothing = true;
					Size.size(rateIcon, 50, 50);
					rateIcon.y = (backing.height - rateIcon.height) / 2;
				});
			}
			
			rateLabel = Window.drawText(params.points, {
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

}